/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2023

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CreditCardPaymentReciept
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.IO;
using System.Text;

using TSI.Arch;
using TSI.Utils;
using PRCo.EBB.BusinessObjects;
using PRCo.EBB.Util;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Generates the notifications to the user that the
    /// transaction has been processed.
    /// </summary>
    public partial class CreditCardPaymentReceipt : PageBase
    {
        protected CreditCardPaymentInfo _oCCPayment = null;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
            SetPageTitle(Resources.Global.PaymentConfirmation);

            if (!IsPostBack)
            {
                if (Session["oCreditCardPayment"] == null)
                {
                    if (Session["CreditCardPaymentPaymentID"] == null)
                    {
                        throw new ApplicationUnexpectedException("Invalid Credit Card Transaction found.");
                    }
                    else
                    {
                        pnlMain.Visible = false;
                        litDupPurchase.Text = GetFormattedErrorDisplay(Resources.Global.DuplicateOrderFound, Resources.Global.DuplicateOrderFoundMsg, false);
                        return;
                    }
                }

                _oCCPayment = (CreditCardPaymentInfo)Session["oCreditCardPayment"];

                PopulateForm();
                SendConfirmationEmail(_oCCPayment, _oUser, Server, GetObjectMgr());
            }
        }

        /// <summary>
        /// Populates the form controls.
        /// </summary>
        protected void PopulateForm()
        {
            lblMsg1.Text = string.Format(Resources.Global.PaymentConfirmationMsg1, _oUser.Email);
            lblMsg2.Text = string.Format(Resources.Global.PaymentConfirmationMsg2, FormatEmailLink(Utilities.GetConfigValue("PaymentReceiptPRCoEmail", "sales@bluebookservices.com")));

            // Set User Information
            lblCustomerName.Text = _oUser.FirstName + " " + _oUser.LastName;
            lblStreet1.Text = _oCCPayment.Street1;
            lblStreet2.Text = _oCCPayment.Street2;
            lblCity.Text = _oCCPayment.City;
            lblCountry.Text = GetObjectMgr().GetCountryName(_oCCPayment.CountryID);
            lblState.Text = GetObjectMgr().GetStateAbbr(_oCCPayment.StateID);
            lblPostalCode.Text = _oCCPayment.PostalCode;

            lblAuthorization.Text = _oCCPayment.AuthorizationCode;
            lblCreditCardNumber.Text = _oCCPayment.CreditCardNumber;
            lblCreditCardType.Text = _oCCPayment.CreditCardType;

            lblProduct.Text = _oCCPayment.ProductDescriptions;

            lblPaymentID.Text = _oCCPayment.PaymentID.ToString();
            lblSubTotal.Text = UIUtils.GetFormattedCurrency(_oCCPayment.GetCost(), 0M);
            lblShipping.Text = UIUtils.GetFormattedCurrency(_oCCPayment.Shipping, 0M);
            lblSalesTax.Text = UIUtils.GetFormattedCurrency(_oCCPayment.TaxAmount, 0M);
            lblTotal.Text = UIUtils.GetFormattedCurrency(_oCCPayment.TotalPrice, 0M);

            hidRequestType.Text = _oCCPayment.RequestType;

            if (_oCCPayment.RequestType == "Membership")
            {
                pnlMembershipTracking.Visible = true;
            }

            if ((_oCCPayment.RequestType.StartsWith("BR")) ||
                (_oCCPayment.RequestType.StartsWith("ML")))
            {
                pnlAlaCarteTracking.Visible = true;
            }

            // Now destroy our CCPayment object so that the
            // user cannot accidentally go back and re-submit
            // the payment
            Session["CreditCardPaymentPaymentID"] = _oCCPayment.PaymentID.ToString();
            Session.Remove("oCreditCardPayment");
        }

        /// <summary>
        /// Takes the user to the next page in the process depending upon
        /// what they purchased.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnContinueOnClick(object sender, EventArgs e)
        {
            string szPage = null;

            switch (hidRequestType.Text)
            {
                case "Membership":
                    if(GetRequestParameter("ITAMode")=="true")
                        szPage = PageConstants.BBOS_HOME;
                    else
                        szPage = PageConstants.MEMBERSHIP_COMPLETE;
                    break;
                case "AddUnits":
                    szPage = PageConstants.MEMBERSHIP_SUMMARY;
                    break;
                case "BV":
                    SetRequestParameter("DisplayThanks", "true");
                    szPage = PageConstants.BUSINESS_VALUATION;
                    break;
                default:
                    szPage = PageConstants.BROWSE_PURCHASES;
                    break;
            }

            SetRequestParameter("ITAMode", "false");
            Response.Redirect(szPage);
        }

        /// <summary>
        /// Sends the purchase confirmation email to the user.
        /// </summary>
        public static void SendConfirmationEmail(CreditCardPaymentInfo oCCPI, IPRWebUser oUser, System.Web.HttpServerUtility server, GeneralDataMgr objectMgr)
        {
            StringBuilder sbMsg = new StringBuilder();

            sbMsg.Append(Resources.Global.Date + ": " + DateTime.Now.ToShortDateString() + " " + DateTime.Now.ToShortTimeString() + Environment.NewLine);
            sbMsg.Append(Resources.Global.BBOSOrderNumber + ": " + oCCPI.PaymentID.ToString() + Environment.NewLine);
            sbMsg.Append(Resources.Global.CustomerName + ": " + oUser.FirstName + " " + oUser.LastName + Environment.NewLine);

            sbMsg.Append(Environment.NewLine);
            sbMsg.Append(Resources.Global.SubTotal + ": " + UIUtils.GetFormattedCurrency(oCCPI.GetCost(), 0M) + Environment.NewLine);
            sbMsg.Append(Resources.Global.SalesTax + ": " + UIUtils.GetFormattedCurrency(oCCPI.TaxAmount, 0M) + Environment.NewLine);
            sbMsg.Append(Resources.Global.Shipping + ": " + UIUtils.GetFormattedCurrency(oCCPI.Shipping, 0M) + Environment.NewLine);
            sbMsg.Append("=======================" + Environment.NewLine);
            sbMsg.Append(Resources.Global.TotalAmount + ": " + UIUtils.GetFormattedCurrency(oCCPI.TotalPrice, 0M) + Environment.NewLine);

            sbMsg.Append(Environment.NewLine);
            sbMsg.Append(Resources.Global.AuthorizationNumber + ": " + oCCPI.AuthorizationCode + Environment.NewLine);
            sbMsg.Append(Resources.Global.CreditCardType + ": " + oCCPI.CreditCardType + Environment.NewLine);
            sbMsg.Append(Resources.Global.CreditCardNumber + ": " + oCCPI.CreditCardNumber + Environment.NewLine);

            sbMsg.Append(Resources.Global.BillingAddressLine1 + ": " + oCCPI.Street1 + Environment.NewLine);
            sbMsg.Append(Resources.Global.BillingAddressLine2 + ": " + oCCPI.Street2 + Environment.NewLine);
            sbMsg.Append(Resources.Global.BillingCity + ": " + oCCPI.City + Environment.NewLine);
            sbMsg.Append(Resources.Global.BillingState + ": " + objectMgr.GetStateAbbr(oCCPI.StateID) + Environment.NewLine);
            sbMsg.Append(Resources.Global.BillingPostalCode + ": " + oCCPI.PostalCode + Environment.NewLine);
            sbMsg.Append(Resources.Global.BillingCountry + ": " + objectMgr.GetCountryName(oCCPI.CountryID) + Environment.NewLine);


            sbMsg.Append(Environment.NewLine);
            sbMsg.Append(Resources.Global.Product + ": " + Environment.NewLine);
            sbMsg.Append(oCCPI.ProductDescriptions.Replace("<br>", Environment.NewLine) + Environment.NewLine);

            string szEmailBody = null;
            using (StreamReader srEmail = new StreamReader(server.MapPath(UIUtils.GetTemplateURL("EmailCreditCardPurchaseReceipt.txt"))))
            {
                szEmailBody = srEmail.ReadToEnd();
            }

            string szEmail = string.Format(szEmailBody, oCCPI.PaymentID.ToString(), sbMsg.ToString());

            //Defect 6973 - emails via stored proc
            objectMgr.SendEmail_Text(oUser.Email,
                            Resources.Global.PaymentConfirmationEmailSubject,
                            szEmail,
                            "CreditCardPaymentReceipt.aspx",
                            null);

            
        }

        /// <summary>
        /// All users can view this page.
        /// </summary>
        /// <returns></returns>
        override protected bool IsAuthorizedForPage()
        {
            return true;
        }

        /// <summary>
        /// All users can view this data.
        /// </summary>
        /// <returns></returns>
        protected override bool IsAuthorizedForData()
        {
            return true;
        }
    }
}