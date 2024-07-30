/***********************************************************************
 Copyright Blue Book Services, Inc. 2023-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: StripeController
 Description:	

 Notes:

***********************************************************************
***********************************************************************/
using Stripe;
using System;
using System.IO;

using System.Web.Http;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Linq;
using PRCo.EBB.BusinessObjects;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json;
using TSI.BusinessObjects;
using TSI.Utils;

namespace StripePayments.Controllers
{
    public class StripeController : ControllerBase
    {
        //api/Stripe/HelloWorld
        [Route("api/StripeController/helloworld")]
        [HttpGet]
        public string HelloWorld()
        {
            return "Hello World";
        }

        // This is your Stripe CLI webhook secret for testing your endpoint locally.
        

        [Route("webhook")]
        [HttpPost]
        public async Task<IHttpActionResult> Index()
        {
            string webhookEndpointSecret = Utilities.GetConfigValue("Stripe_Webhook_Endpoint_Secret_Key");

            SetLoggerMethod("Stripe Webhook");
            
            var json = await Request.Content.ReadAsStringAsync();

            try
            {
                IEnumerable<string> headerValues;
                var stripeSignature = string.Empty;
                if (Request.Headers.TryGetValues("Stripe-Signature", out headerValues))
                {
                    stripeSignature = headerValues.FirstOrDefault();
                }

                var stripeEvent = EventUtility.ConstructEvent(json,
                    stripeSignature, webhookEndpointSecret);

                //Handle the event
                switch(stripeEvent.Type)
                {
                    case Events.InvoicePaid:
                        var invoicePaid = stripeEvent.Data.Object as Invoice;

                        StripeConfiguration.ApiKey = Utilities.GetConfigValue("Stripe_Secret_Key");

                        Charge charge;
                        var chargeService = new ChargeService();
                        charge = chargeService.Get(invoicePaid.ChargeId);

                        try
                        {
                            PRInvoiceMgr oMgr = new PRInvoiceMgr();
                            PRInvoice oPRInvoice = oMgr.GetByStripeInvoiceId(invoicePaid.Id);
                            //oPRInvoice.prinv_PaymentDateTime = invoicePaid.Created;
                            oPRInvoice.prinv_PaymentDateTime = charge.Created;

                            if (invoicePaid.ChargeId.StartsWith("ch"))
                                oPRInvoice.prinv_PaymentMethodCode = PRINV_PAYMENT_METHOD_CODE_CREDIT_CARD_STRIPE;
                            else if(invoicePaid.ChargeId.StartsWith("py"))
                                oPRInvoice.prinv_PaymentMethodCode = PRINV_PAYMENT_METHOD_CODE_ACH_STRIPE;

                            oPRInvoice.prinv_PaymentMethod = invoicePaid.ChargeId;
                            oPRInvoice.prinv_PaymentBrand = charge.PaymentMethodDetails.Card?.Brand; //visa, mastercard, etc.

                            oPRInvoice.Save();

                            GetLogger().LogMessage($"InvoicePaid for invoice {invoicePaid.Description} {invoicePaid.Id}");
                        }
                        catch (ObjectNotFoundException ex)
                        {
                            GetLogger().LogError($"Invoice not found for invoice {invoicePaid.Description} {invoicePaid.Id}", ex);
                        }
                        catch (Exception ex)
                        {
                            GetLogger().LogError($"InvoicePaid Error for invoice {invoicePaid.Description} {invoicePaid.Id}", ex);
                        }

                        break;

                    default:
                        Console.WriteLine("Unhandled event type: {0}", stripeEvent.Type);
                        break;
                }

                return Ok();
            }
            catch (StripeException e)
            {
                GetLogger().LogError(e);
                return BadRequest();
            }
        }
    }
}