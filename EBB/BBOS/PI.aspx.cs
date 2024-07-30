/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2023-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: PI
 Description: Redirects user to a stripe invoice link such as
   https://apps.bluebookservices.com/PI.aspx?k=QQQQQQQQQQQQQQQ.  Takes 
    in paramater k=QQQQQQQQQQQQQQQ which is stored in the PRInvoice table

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using PRCo.EBB.BusinessObjects;
using TSI.Arch;
using TSI.BusinessObjects;
using TSI.Utils;
using PRCo.BBS;

namespace PRCo.BBOS.UI.Web
{
    public partial class Payment : PageBase
    {
        const string MSG_MISSING_INVALID_KEY = "This invoice payment link is missing the invoice key or the invoice key is invalid. The invoice key is a 9-character string that uniquely identifies your invoice.  Please check the payment link from the invoice to make sure you have the entire link. If you have any questions, please contact customer service at 630 668-3500.";

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if (Request.QueryString["k"] == null)
                throw new ApplicationExpectedException(MSG_MISSING_INVALID_KEY);

            if ((Request.QueryString["a"] != null) &&
                (Request.QueryString["a"] == "d")) {
                DownloadInvoice();
                return;
            }

            RedirectToStripe();
        }

        protected void DownloadInvoice()
        {
            PRInvoice oInvoice = null;
            try
            {
                PRInvoiceMgr oMgr = new PRInvoiceMgr(_oLogger, _oUser);
                oInvoice = (PRInvoice)oMgr.GetByPaymentURLKey(Request.QueryString["k"]);
            }
            catch (ObjectNotFoundException)
            {
                throw new ApplicationExpectedException(MSG_MISSING_INVALID_KEY);
            }


            ReportInterface oRI = new ReportInterface();
            byte[] abReport = oRI.GenerateInvoiceStripe(oInvoice.prinv_InvoiceNbr);
            string invoiceFileName = string.Format(Utilities.GetConfigValue("GenerateInvoicesFileName", "BBS Invoice {0}.pdf"), oInvoice.prinv_InvoiceNbr);

            Response.ClearContent();
            Response.ClearHeaders();
            Response.AddHeader("Content-Disposition", "attachment; filename=\"" + invoiceFileName + "\"");
            Response.ContentType = "application/pdf";
            Response.BinaryWrite(abReport);
        }

        protected void RedirectToStripe()
        {
            try
            {
                PRInvoiceMgr oMgr = new PRInvoiceMgr(_oLogger, _oUser);
                PRInvoice oInvoice = (PRInvoice)oMgr.GetByPaymentURLKey(Request.QueryString["k"]);
                Response.Redirect(oInvoice.prinv_StripePaymentURL);
            }
            catch (ObjectNotFoundException)
            {
                throw new ApplicationExpectedException(MSG_MISSING_INVALID_KEY);
            }
        }

        /// <summary>
        /// Determines who is authorized to view this page.
        /// </summary>
        /// <returns></returns>
        override protected bool IsAuthorizedForPage()
        {
            return true;
        }

        override protected bool IsAuthorizedForData()
        {
            return true;
        }
    }
}