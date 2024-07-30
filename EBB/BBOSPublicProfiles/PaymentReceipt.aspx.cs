/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2014-2020

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: Payment.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;

using PRCo.EBB.BusinessObjects;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web.PublicProfiles
{
    public partial class PaymentReceipt : MembershipBase
    {
        protected CreditCardPaymentInfo _oCCPayment = null;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            _oCCPayment = (CreditCardPaymentInfo)Session["oCreditCardPayment"];

            if (_oCCPayment == null)
            {
                Response.Redirect(GetMarketingSiteURL());
            }

            if (!IsPostBack)
            {
                PopulateForm();
            }
        }


        /// <summary>
        /// Populates the form controls.
        /// </summary>
        protected void PopulateForm()
        {

            lblMsg1.Text = string.Format(lblMsg1.Text, _oCCPayment.Email);
            switch (_oCCPayment.RequestType)
            {
                case "BR":
                    pnlBR.Visible = true;
                    break;
                case "Membership":
                    pnlMembership.Visible = true;
                    hlAGTools.NavigateUrl = Utilities.GetConfigValue("AGToolsURL", "https://bluebook.ag.tools/home");
                    break;
            }

            if (Utilities.GetConfigValue("IndustryType") == "L")
                divAGTools.Visible = false; //DEFECT 6803

            // Set User Information
            lblCustomerName.Text = _oCCPayment.FullName;

            lblBillingAddress.Text = _oCCPayment.Street1 + "<br/>";
            if (!string.IsNullOrEmpty(_oCCPayment.Street2)) {
                lblBillingAddress.Text += _oCCPayment.Street1 + "<br/>";                     
            }
            lblBillingAddress.Text += _oCCPayment.City + ", " + GetObjectMgr().GetStateAbbr(_oCCPayment.StateID) + " " + _oCCPayment.PostalCode;
            if (_oCCPayment.CountryID > 1)
            {
                lblBillingAddress.Text += "<br/>" + GetObjectMgr().GetCountryName(_oCCPayment.CountryID);
            }
                     
            lblAuthorization.Text = _oCCPayment.AuthorizationCode;
            lblCreditCardNumber.Text = _oCCPayment.CreditCardNumber;
            lblCreditCardType.Text = _oCCPayment.CreditCardType;

            if (_oCCPayment.Products.Count > 0) {
              lblProduct.Text = GetObjectMgr().GetProductDescriptions(_oCCPayment);
            }

            lblPaymentID.Text = _oCCPayment.PaymentID.ToString();
            lblSubTotal.Text = GetFormattedCurrency(_oCCPayment.GetCost(), 0M);
            lblShipping.Text = GetFormattedCurrency(_oCCPayment.Shipping, 0M);
            lblSalesTax.Text = GetFormattedCurrency(_oCCPayment.TaxAmount, 0M);
            lblTotal.Text = GetFormattedCurrency(_oCCPayment.TotalPrice, 0M);

            hidRequestType.Text = _oCCPayment.RequestType;
        }
    }
}