/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2014-2024

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
using PRCo.EBB.BusinessObjects;
using PRCo.EBB.Util;
using Stripe;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Data;
using System.IO;
using System.Net;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.UI;
using TSI.BusinessObjects;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web.PublicProfiles
{
    public partial class Payment : MembershipBase
    {
        protected CreditCardPaymentInfo _oCCPayment = null;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            _oCCPayment = (CreditCardPaymentInfo)Session["oCreditCardPayment"];

            if (_oCCPayment != null)
            {
                switch (_oCCPayment.RequestType)
                {
                    case "BR":
                        Master.SetFormClass("purchase-report");
                        break;
                    case "Membership":
                        Master.SetFormClass("member step-4 payment");
                        break;
                }
            }

            if (IsPostBack)
            {
                // Handle Stripe payments
                NameValueCollection nvc = Request.Form;
                string hfStripeToken = nvc["hfStripeToken"];
                if (!string.IsNullOrEmpty(hfStripeToken))
                {
                    btnPurchaseOnClick(hfStripeToken);
                    return;
                }
            }

            Page.Server.ScriptTimeout = (5*60);

            if ((_oCCPayment != null) &&
                (!string.IsNullOrEmpty(_oCCPayment.AuthorizationCode))) {
                // This payment has already been processed.    
                switch (_oCCPayment.RequestType)
                {
                    case "BR":
                        Response.Redirect("CompanyProfile.aspx?CompanyID=" + _oCCPayment.SelectedIDs);
                        break;
                    case "Membership":
                        Response.Redirect("MembershipSelect.aspx" + GetQueryString());
                        break;
                }
                return;
            }

            if (!IsPostBack)
            {
                cddCountry.ServicePath = GetWebServiceURL();
                cddState.ServicePath = GetWebServiceURL();

                cddCountry.ContextKey = "1";  //USA
                cddState.ContextKey = string.Empty;

                SetListDefaultValue(ddlCountry, "1");
                SetListDefaultValue(ddlState, "14");

                cddCountry_Mailing.ServicePath = GetWebServiceURL();
                cddState_Mailing.ServicePath = GetWebServiceURL();

                cddCountry_Mailing.ContextKey = "1";  //USA
                cddState_Mailing.ContextKey = string.Empty;

                SetListDefaultValue(ddlCountry_Mailing, "1");
                SetListDefaultValue(ddlState_Mailing, "14");

                string szCulture;
                if (IsSpanish())
                    szCulture = SPANISH_CULTURE;
                else
                    szCulture = ENGLISH_CULTURE;

                if (Utilities.GetConfigValue("IndustryType") == "P") {
                    pnlHowLearned.Visible = true;
                    BindLookupValues(ddlHowLearned, GetReferenceData("ProduceHowLearned", szCulture), true);

                    BindLookupValues(ddlTypeofBusiness, GetReferenceData("TypeofBusiness", szCulture), true);
                    pnlTypeofBusiness.Visible = true;
                }
                else if (Utilities.GetConfigValue("IndustryType") == "L")
                {
                    pnlHowLearned.Visible = true;
                    BindLookupValues(ddlHowLearned, GetReferenceData("LumberHowLearned", szCulture), true);
                }

                PopulateForm();
            }

            if (_oCCPayment == null)
            {
                btnCancel.Visible = false;
                Response.Redirect(Utilities.GetConfigValue("MarketingSiteURL"));
            }
            else 
            {
                switch (_oCCPayment.RequestType)
                {
                    case "BR":
                        btnCancel.NavigateUrl = "/find-companies/company-profile/?ID=" + GetRequestParameter("CompanyID");
                        break;
                    case "Membership":
                        btnCancel.NavigateUrl = GetMarketingSiteURL() + "/join-today/";
                        break;
                }
            }
        }

        /// <summary>
        /// Populates the form controls.
        /// </summary>
        protected void PopulateForm()
        {
            // Only membership products have shipping charges
            // and have associated taxes.
            btnRecalc.Visible = false;

            if ((_oCCPayment == null) &&
                (GetRequestParameter("CompanyID", false) != null))
            {
                _oCCPayment = new CreditCardPaymentInfo();
                _oCCPayment.RequestType = "BR";
                Session["oCreditCardPayment"] = _oCCPayment;
            }

            if (_oCCPayment == null) {
                return;
            }

            _oCCPayment.IndustryType = GetIndustryType();

            if (_oCCPayment.RequestType == "BR")
            {
                divMembership.Visible = false;
                contactInfo.Visible = false;
                divBR.Visible = true;
                divBRDelivery.Visible = true;
                ArrayList oParameters = new ArrayList();
                oParameters.Add(new ObjectParameter("prod_ProductID", Utilities.GetIntConfigValue("BRProductID", 50)));

                using (IDataReader oReader = GetDBAccess().ExecuteReader(SQL_SELECT_PRODUCT, oParameters, CommandBehavior.CloseConnection, null))
                {
                    oReader.Read();

                    if (oReader[7] != DBNull.Value)
                    {
                        BRPrice.Text =  GetFormattedCurrency(oReader.GetDecimal(7));
                    }
                }

                _oCCPayment.SelectedIDs = GetRequestParameter("CompanyID");
                BRCompany.Text = GetCompanyName(Convert.ToInt32(GetRequestParameter("CompanyID")));
                return;
            }

            if (_oCCPayment.RequestType == "Membership")
            {
                divMembership.Visible = true;
                contactInfo.Visible = true;
                divBR.Visible = false;
                lblProduct.Text = GetObjectMgr().GetProductDescriptions(_oCCPayment);

                txtSpecialInstructions.Text = _oCCPayment.SpecialInstructions;

                divCounty.Visible = true;
                txtCounty.Enabled = false;
                btnRecalc.Visible = true;
                pnlMailingAddress.Visible = true;
                CalculateCharges();

                pnlAgreement.Visible = true;
                string szTemplateFolder = string.Format(Utilities.GetConfigValue("TemplateFolder"), GetCulture());

                using (StreamReader srTerms = new StreamReader(Path.Combine(szTemplateFolder, "MembershipAgreement.html")))
                {
                    agreementText.Text = srTerms.ReadToEnd();
                }

                _oCCPayment.TotalPrice = _oCCPayment.GetCost() + _oCCPayment.Shipping + _oCCPayment.TaxAmount;

                lblSubTotal.Text = GetFormattedCurrency(_oCCPayment.GetCost(), 0M);
                lblShipping.Text = GetFormattedCurrency(_oCCPayment.Shipping, 0M);
                lblSalesTax.Text = GetFormattedCurrency(_oCCPayment.TaxAmount, 0M);
                lblTotal.Text = GetFormattedCurrency(_oCCPayment.TotalPrice, 0M);

                txtCity.Attributes.Add("onchange", "processAddress()");
                //ddlState.Attributes.Add("onchange", "processAddress()");
                txtPostalCode.Attributes.Add("onchange", "processAddress()");
            }
        }

        protected void CalculateCharges(object sender, EventArgs e)
        {
            OkButton2.Visible = true;
            OkButton.Visible = false;
            mpeMultipleCounties.OkControlID = OkButton2.ID;

            CalculateCharges();
        }

        protected bool CalculateCharges()
        {
            if (_oCCPayment.RequestType == "Membership")
            {
                membershipHeader.Visible = true;
                btnPrevious.Visible = true;

                _oCCPayment.CountryID = 1;
                if (!string.IsNullOrEmpty(ddlCountry.SelectedValue)) {
                    _oCCPayment.CountryID = Convert.ToInt32(ddlCountry.SelectedValue);
                }

                //_oCCPayment.StateID = 14;
                if (!string.IsNullOrEmpty(ddlState.SelectedValue)) {
                    _oCCPayment.StateID = Convert.ToInt32(ddlState.SelectedValue);
                }

                if (IsPostBack)
                {
                    cddCountry.ContextKey = ddlCountry.SelectedValue;
                    cddState.ContextKey = ddlState.SelectedValue;
                }

                _oCCPayment.County = txtCounty.Text;
                _oCCPayment.City = txtCity.Text;
                _oCCPayment.PostalCode = txtPostalCode.Text.Trim();
                if (_oCCPayment.PostalCode.Length > 5)
                    _oCCPayment.PostalCode = _oCCPayment.PostalCode.Substring(0, 5); //handle zip+4 codes such as 18062-1300

                if ((string.IsNullOrEmpty(_oCCPayment.County)) &&
                    (!string.IsNullOrEmpty(_oCCPayment.PostalCode)))
                {

                    txtCounty.Enabled = true;

                    List<string> counties = GetObjectMgr().GetCounty(_oCCPayment.City, _oCCPayment.StateID, _oCCPayment.PostalCode);

                    if (counties.Count == 1)
                    {
                        _oCCPayment.County = counties[0];
                        txtCounty.Text = counties[0];
                    }
                    else if (counties.Count > 1)
                    {
                        repCounties.DataSource = counties;
                        repCounties.DataBind();
                        mpeMultipleCounties.Show();

                        
                        return false;
                    }
                }

                taxUpdated.Visible = false;

                // Compute out our tax using the User values
                _oCCPayment.GetTaxedCost();

                if ((lblSalesTax.Text != string.Empty) &&
                    (lblSalesTax.Text != GetFormattedCurrency(_oCCPayment.TaxAmount, 0M)))
                {
                    taxUpdated.Text = Resources.Global.SalesTaxAmountUpdated + "<br>";
                    taxUpdated.Visible = true;
                }

                lblSalesTax.Text = GetFormattedCurrency(_oCCPayment.TaxAmount, 0M);

                // Compute shipping for each product
                lblShipping.Text = GetFormattedCurrency(_oCCPayment.GetShippingRate(), 0M);

                _oCCPayment.TotalPrice = _oCCPayment.GetCost() + _oCCPayment.Shipping + _oCCPayment.TaxAmount;
                lblTotal.Text = GetFormattedCurrency(_oCCPayment.TotalPrice, 0M);
            }

            return true;
        }

        protected void btnPurchaseOnClick(object sender, EventArgs e)
        {
            NameValueCollection nvc = Request.Form;
            string hfStripeToken = nvc["hfStripeToken"];

            btnPurchaseOnClick(hfStripeToken);
        }

        protected void btnPurchaseOnClick(string stripeToken)
        {
            if (!ValidateCaptcha())
                throw new HttpRequestValidationException("Captcha verification failed.");

            OkButton2.Visible = false;
            OkButton.Visible = true;
            mpeMultipleCounties.OkControlID = null;

            // Get our RequestID.  This will be our "OOTN" to include
            int iPaymentID = GetObjectMgr().GetRecordID("PRPayment");
            int iRequestID = 0;
            int iMembershipPurchaseID = 0;
            CreditCardProductInfo ccProductInfo = null;

            _oCCPayment = (CreditCardPaymentInfo)Session["oCreditCardPayment"];

            // Build our BR purchase objects
            if (_oCCPayment.RequestType == "BR")
            {
                productID.Value = Utilities.GetIntConfigValue("BRProductID", 50).ToString();
                ccProductInfo = AddCreditCardProductInfo(Utilities.GetIntConfigValue("BRProductID", 50), 1);

                if (!isValidEmail(BREmailAddress.Text))
                {
                    errMsg.Text = "The specified email addresses is invalid.";
                    return;
                }

                if (BREmailAddress.Text != BREmailAddressConfirm.Text) {
                    errMsg.Text = "The specified email addresses do not match.";
                    return;
                }
            }

            if (_oCCPayment.RequestType == "Membership")
            {
                if (!isValidEmail(txtSubmitterEmail.Text))
                {
                    errMsg.Text = "The specified email addresses is invalid.";
                    return;
                }

                // Re Compute out our tax in case the user changed thier
                // billing location.
                if (!CalculateCharges())
                {
                    return;
                }

                _oCCPayment.HowLearned = ddlHowLearned.SelectedValue;
                _oCCPayment.HowLearnedOther = txtProduceHowLearnedOther.Text;
                _oCCPayment.ReferralPerson = txtReferralPerson.Text;
                _oCCPayment.ReferralCompany = txtReferralCompany.Text;
            }

            _oCCPayment.TotalPrice = _oCCPayment.GetCost() + _oCCPayment.Shipping + _oCCPayment.TaxAmount;

            // If the system is configured to use verisign credit card processing then
            // attempt to process credit card payment.

            if (!ExecutePayment(iPaymentID, stripeToken))
            {
                errMsg.Text = "The credit card transaction has been denied. Please review the information you provided for accuracy. If this error persists, please contact Blue Book Services at 630 668-3500.";
                return;
            }

            IDbTransaction oTran = GetObjectMgr().BeginTransaction();
            try
            {
                switch (_oCCPayment.RequestType)
                {
                    case "BR":

                        string msg = "BR PURCHASE";
                        if (cbMoreInfo.Checked)
                            msg += " / MEMBERSHIP INTEREST";

                        NotifyInternalUsers(iPaymentID,
                                            Utilities.GetIntConfigValue("BRPurchaseUnknownCityPRCoUserID", 24),
                                            Utilities.GetIntConfigValue("BRPurchaseEmailAcctUserID", 1029),
                                            msg,
                                            string.Empty,
                                            Utilities.GetConfigValue("BRPurchaseCategory", string.Empty),
                                            Utilities.GetConfigValue("BRPurchaseSubcategory", string.Empty),
                                            Utilities.GetConfigValue("BRPurchaseEmailSubject", "Business Report Purchased from Marketing Site"),
                                            oTran);
                        break;

                    case "Membership":

                        GetObjectMgr().ProcessMembership(_oCCPayment, iPaymentID, oTran);

                        NotifyInternalUsers(iPaymentID,
                                            Utilities.GetIntConfigValue("MembershipPurchaseUnknownCityPRCoUserID", 24),
                                            Utilities.GetIntConfigValue("MembershipPurchaseEmailAcctUserID", 1029),
                                            "MEMBERSHIP ORDER",
                                            string.Empty,
                                            Utilities.GetConfigValue("MembershipPurchaseCategory", string.Empty),
                                            Utilities.GetConfigValue("MembershipPurchaseSubcategory", string.Empty),
                                            GetMembershipPurchaseEmailSubject(),
                                            oTran);
                        break;
                }

                CreatePayment(iPaymentID, iRequestID, iMembershipPurchaseID, oTran);

                oTran.Commit();
            }
            catch
            {
                if (oTran != null)
                    oTran.Rollback();

                throw;
            }

            // Set these values so that our receipt screen 
            // can display them.
            if (_oCCPayment.RequestType == "Membership")
            {
                _oCCPayment.FullName = txtFirstName.Text + " " + txtLastName.Text;
                _oCCPayment.Phone = txtSubmitterPhone.Text;
                _oCCPayment.Email = txtSubmitterEmail.Text;
            }
            else
            {
                _oCCPayment.FullName = txtNameOnCard.Text;
                _oCCPayment.Email = BREmailAddress.Text;
            }

            _oCCPayment.Street1 = txtStreet1.Text;
            _oCCPayment.Street2 = txtStreet2.Text;
            _oCCPayment.City = txtCity.Text;
            _oCCPayment.StateID = Convert.ToInt32(ddlState.SelectedValue);
            _oCCPayment.CountryID = Convert.ToInt32(ddlCountry.SelectedValue);
            _oCCPayment.PostalCode = txtPostalCode.Text;

            if (_TrxnStripeCharge == null)
                _oCCPayment.AuthorizationCode = "TEST";
            else
                _oCCPayment.AuthorizationCode = _TrxnStripeCharge.Id;

            _oCCPayment.PaymentID = iPaymentID;
            _oCCPayment.CreditCardNumber = _TrxnStripeCharge.PaymentMethodDetails.Card.Last4;
            _oCCPayment.CreditCardType = EBB.BusinessObjects.Stripe.GetCreditCardType(_TrxnStripeCharge.PaymentMethodDetails.Card.Brand);

            // We do these outside of the transaction because
            // they send emails.  It wouldn't be good to rollback the
            // data but still send these out.
            if (_oCCPayment.RequestType == "Membership")
            {
                SendMembershipEmail();
                CreateBBOSUsers();
            }

            if (_oCCPayment.RequestType == "BR")
                CreateBRPurchase(ccProductInfo, iPaymentID, _oCCPayment.SelectedIDs);

            SavePaymentInfoToSession();

            //For produce membership, we want to go to BOR.aspx
            //else just the receipt page
            if ((Utilities.GetConfigValue("IndustryType") == GeneralDataMgr.INDUSTRY_TYPE_PRODUCE)  &&
                (_oCCPayment.RequestType == "Membership"))
            {
                //Response.Redirect("/payment-receipt/");
                
                if (IsSpanish())
                    ClientScript.RegisterStartupScript(this.GetType(), "redirect", "redirectToReceiptPage(true)", true);
                else
                    ClientScript.RegisterStartupScript(this.GetType(), "redirect", "redirectToReceiptPage(false)", true);

                SetRequestParameter("type", ddlTypeofBusiness.SelectedValue);
            } else
                Response.Redirect("PaymentReceipt.aspx" + GetQueryString());
        }

        private string GetMembershipPurchaseEmailSubject()
        {
            return Utilities.GetConfigValue("MembershipPurchaseEmailSubject", "Membership Purchased from Marketing Site");
        }

        private void SavePaymentInfoToSession()
        {
            Session[SESSION_COMPANYNAME] = txtCompanyName.Text;
            Session[SESSION_SUBMITTERPHONE] = txtSubmitterPhone.Text;
            Session[SESSION_STREET1] = txtStreet1.Text;
            Session[SESSION_STREET2] = txtStreet2.Text;

            Session[SESSION_CITY] = txtCity.Text;
            Session[SESSION_STATE] = ddlState.SelectedItem.Value;
            Session[SESSION_ZIP] = txtPostalCode.Text;
            Session[SESSION_COUNTRY] = ddlCountry.SelectedItem.Value;
        }

        protected void NotifyInternalUsers(int iPaymentID,
                                           int UnknownCityUserID,
                                           int AccountingUserID,
                                           string taskMessage,
                                           string taskBody,
                                           string taskCategory,
                                           string taskSubcategory,
                                           string emailSubject,
                                           IDbTransaction oTran)
        {
            int iPRCoSpecialistID = GetObjectMgr().GetPRCoSpecialistID(txtCity.Text,
                                                                       Convert.ToInt32(ddlState.SelectedValue),
                                                                       GeneralDataMgr.PRCO_SPECIALIST_INSIDE_SALES,
                                                                       GetIndustryType(),
                                                                       oTran);

            if (iPRCoSpecialistID == 0)
                iPRCoSpecialistID = UnknownCityUserID;

            string szMsg = GetTaskMsg(taskMessage, iPaymentID);
            szMsg = Regex.Replace(szMsg, @"^(?!\s\s)", "  ", RegexOptions.Multiline); //https://stackoverflow.com/questions/247546/outlook-autocleaning-my-line-breaks-and-screwing-up-my-email-format
            szMsg += Environment.NewLine + taskBody;

            GetObjectMgr().CreateTask(iPRCoSpecialistID,
                                        "Pending",
                                        szMsg,
                                        taskCategory,
                                        taskSubcategory,
                                        0, 
                                        0,
                                        0,
                                        "OnlineIn",
                                        emailSubject,
                                        oTran);

            List<string> lstAttachments = new List<string>();

            if (Session["PublishedLogoFile"] != null)
            {
                //Write file to disk
                string szFilePath = (string)GetDBAccess().ExecuteScalar("SELECT Capt_US FROM Custom_Captions WHERE Capt_Family='TempReports' AND Capt_Code='Share'");
                string szFileName = Path.Combine(szFilePath, (string)Session["PublishedLogoFileName"]);
                
                byte[] arrPublishedLogo = (byte[])Session["PublishedLogoFile"];
                MemoryStream memStream = new MemoryStream(arrPublishedLogo);

                using (FileStream file = new FileStream(szFileName, FileMode.Create, System.IO.FileAccess.Write))
                {
                    memStream.CopyTo(file);
                }

                lstAttachments.Add(szFileName);
            }

            Session["PublishedLogoFile"] = null;
            Session["PublishedLogoFileName"] = null;

            GeneralDataMgr oMgr = new GeneralDataMgr(_oLogger, null);
            oMgr.SendEmail(GetObjectMgr().GetPRCoUserEmail(AccountingUserID, oTran),
                                EmailUtils.GetFromAddress(),
                                emailSubject,
                                szMsg,
                                false,
                                lstAttachments,
                                "Payment.aspx",
                                oTran);

            //Defect 7396 - send email to all Sales People (default ('TJR', 'JBL', 'LEL') -- Jeff Lair, Leticia Lima, Tim Reardon
            SendEmailToSales(emailSubject,
                            szMsg,
                            "Payment.aspx",
                            oTran);

            //cleanup Files
            foreach (string lstAttachment in lstAttachments)
            {
                System.IO.File.Delete(lstAttachment);
            }

        }

        Charge _TrxnStripeCharge= null;
     
        protected bool ExecutePayment(int paymentID, string stripeToken)
        {
            //force TLS 1.2 to be active
            System.Net.ServicePointManager.SecurityProtocol =
                   SecurityProtocolType.Tls | SecurityProtocolType.Tls11 | SecurityProtocolType.Tls12;
            System.Net.ServicePointManager.SecurityProtocol = System.Net.SecurityProtocolType.Tls12;

            var myCharge = new ChargeCreateOptions
            {
                // convert the amount of $15.95 to pennies i.e. 1595
                Amount = (int)(_oCCPayment.TotalPrice * 100),
                Currency = "USD",
                Description = "PRPaymentID: " + paymentID.ToString(),
                Source = stripeToken
            };

            var stripeClient = new StripeClient(Utilities.GetConfigValue("Stripe_Secret_Key"));
            var chargeService = new ChargeService(stripeClient);
            Charge stripeCharge;
            string szError = "";
            try
            {
                stripeCharge = chargeService.Create(myCharge);
                _TrxnStripeCharge = stripeCharge;
                LogMessage("Stripe Results:" + stripeCharge.StripeResponse);
                if (stripeCharge.StripeResponse.StatusCode == HttpStatusCode.OK)
                {
                    return true;
                }
            }
            catch (StripeException ex)
            {
                StripeError stripeError = ex.StripeError;
                // Handle error
                LogMessage("Stripe Error: " + stripeError.Message);
                szError = stripeError.Message;
            }

            // If we made it here, then we were not authorized
            string szSubject = "Credit Card Authorization Failure";

            string szMsg = "Product Information" + Environment.NewLine;
            szMsg += lblProduct.Text.Replace("<br />", Environment.NewLine) + Environment.NewLine;
            szMsg += FormatCreditCardInfo(paymentID);
            szMsg += szError;

            // Send an email to PRCo to notify someone of the failure.
            GeneralDataMgr oMgr = new GeneralDataMgr(_oLogger, null);
            oMgr.SendEmail(Utilities.GetConfigValue("CreditCardFailureNotifyAddress", "bluebookservices@bluebookservices.com"),
                            EmailUtils.GetFromAddress(),
                            szSubject,
                            szMsg,
                            false,
                            null,
                            "Payment.aspx",
                            null);

            return false;
        }

        protected string FormatCreditCardInfo(int paymentID)
        {
            StringBuilder sbCreditCardInfo = new StringBuilder(Environment.NewLine);

            if (!string.IsNullOrEmpty(txtFirstName.Text))
            {
                sbCreditCardInfo.Append("First Name: " + txtFirstName.Text + Environment.NewLine);
                sbCreditCardInfo.Append("Last Name: " + txtLastName.Text + Environment.NewLine);
                sbCreditCardInfo.Append("Submitter Email: " + txtSubmitterEmail.Text + Environment.NewLine);
                sbCreditCardInfo.Append("Submitter Phone: " + txtSubmitterPhone.Text + Environment.NewLine);
            }

            if (!string.IsNullOrEmpty(BREmailAddress.Text))
            {
                sbCreditCardInfo.Append("Submitter Email: " + BREmailAddress.Text + Environment.NewLine);
            }
            sbCreditCardInfo.Append("Company Name: " + txtCompanyName.Text + Environment.NewLine);


            sbCreditCardInfo.Append(Environment.NewLine);
            sbCreditCardInfo.Append("Name On Card: " + txtNameOnCard.Text + Environment.NewLine);

            if (_TrxnStripeCharge != null && _TrxnStripeCharge.PaymentMethodDetails != null && _TrxnStripeCharge.PaymentMethodDetails.Card != null && _TrxnStripeCharge.PaymentMethodDetails.Card.Brand != null)
            {
                sbCreditCardInfo.Append("Credit Card Type: " + _TrxnStripeCharge.PaymentMethodDetails.Card.Brand + Environment.NewLine);
                sbCreditCardInfo.Append("Credit Card #: " + _TrxnStripeCharge.PaymentMethodDetails.Card.Last4 + Environment.NewLine);
                sbCreditCardInfo.Append($"Expiration: {_TrxnStripeCharge.PaymentMethodDetails.Card.ExpMonth}/{_TrxnStripeCharge.PaymentMethodDetails.Card.ExpYear}" + Environment.NewLine);
            }

            sbCreditCardInfo.Append("Amount: " + GetFormattedCurrency(_oCCPayment.TotalPrice, 0M) + Environment.NewLine);
            sbCreditCardInfo.Append("Payment ID: " + paymentID.ToString() + Environment.NewLine);

            sbCreditCardInfo.Append(Environment.NewLine);
            sbCreditCardInfo.Append("Billing Street 1: " + txtStreet1.Text + Environment.NewLine);
            sbCreditCardInfo.Append("Billing Street 2: " + txtStreet2.Text + Environment.NewLine);
            sbCreditCardInfo.Append("Billing City: " + txtCity.Text + Environment.NewLine);
            sbCreditCardInfo.Append("Billing State: " + ddlState.SelectedItem.Text + Environment.NewLine);
            sbCreditCardInfo.Append("Billing Postal: " + txtPostalCode.Text + Environment.NewLine);
            sbCreditCardInfo.Append("Billing Country: " + ddlCountry.SelectedItem.Text + Environment.NewLine);

            sbCreditCardInfo.Append(Environment.NewLine);
            if (!cbMailingAddressDifferent.Checked)
                sbCreditCardInfo.Append("Mailing Address: Same as Billing Address" + Environment.NewLine);
            else
            {
                sbCreditCardInfo.Append("Mailing Street 1: " + txtStreet1_Mailing.Text + Environment.NewLine);
                sbCreditCardInfo.Append("Mailing Street 2: " + txtStreet2_Mailing.Text + Environment.NewLine);
                sbCreditCardInfo.Append("Mailing City: " + txtCity_Mailing.Text + Environment.NewLine);
                sbCreditCardInfo.Append("Mailing State: " + ddlState_Mailing.SelectedItem.Text + Environment.NewLine);
                sbCreditCardInfo.Append("Mailing Postal: " + txtPostalCode_Mailing.Text + Environment.NewLine);
                sbCreditCardInfo.Append("Mailing Country: " + ddlCountry_Mailing.SelectedItem.Text + Environment.NewLine);
            }

            sbCreditCardInfo.Append(Environment.NewLine);
            sbCreditCardInfo.Append("Transaction Date/Time: " + DateTime.Now.ToString() + Environment.NewLine);
            sbCreditCardInfo.Append("Submitter IP Address: " + Request.ServerVariables["REMOTE_ADDR"] + Environment.NewLine);

            sbCreditCardInfo.Append(Environment.NewLine);
            sbCreditCardInfo.Append("Transaction Amount Details:" + Environment.NewLine);
            sbCreditCardInfo.Append("   Sub Total: " + GetFormattedCurrency(_oCCPayment.GetCost(), 0M) + Environment.NewLine);
            sbCreditCardInfo.Append("   Sales Tax: " + GetFormattedCurrency(_oCCPayment.TaxAmount, 0M) + Environment.NewLine);
            sbCreditCardInfo.Append("    Shipping: " + GetFormattedCurrency(_oCCPayment.Shipping, 0M) + Environment.NewLine);
            sbCreditCardInfo.Append("========================" + Environment.NewLine);
            sbCreditCardInfo.Append("Total Amount: " + GetFormattedCurrency(_oCCPayment.TotalPrice, 0M) + Environment.NewLine);

            sbCreditCardInfo.Append(Environment.NewLine);
            sbCreditCardInfo.Append("Stripe Response Codes:" + Environment.NewLine);
            sbCreditCardInfo.Append(FormatStripeResults());

            return sbCreditCardInfo.ToString();
        }


        /// <summary>
        /// Returns a formated string of any additional membership users
        /// specified by the user in the membership wizard.
        /// </summary>
        /// <returns></returns>
        protected string GetAdditionalUsersList()
        {
            if (_oCCPayment.RequestType != "Membership")
            {
                return string.Empty;
            }


            List<EBB.BusinessObjects.Person> lMembershipUsers = (List<EBB.BusinessObjects.Person>)Session["lMembershipUsers"];
            if (lMembershipUsers == null)
            {
                return string.Empty;
            }

            StringBuilder sbAddUsers = new StringBuilder();

            foreach (EBB.BusinessObjects.Person oPerson in lMembershipUsers)
            {
                if ((string.IsNullOrEmpty(oPerson.FirstName)) &&
                    (string.IsNullOrEmpty(oPerson.LastName)) &&
                    (string.IsNullOrEmpty(oPerson.Email)))
                {
                    continue;
                }

                sbAddUsers.Append(GetReferenceValue("prwu_AccessLevel", oPerson.AccessLevel.ToString()));
                sbAddUsers.Append(" - ");
                sbAddUsers.Append(oPerson.Title);
                sbAddUsers.Append(" ");
                sbAddUsers.Append(oPerson.FirstName);
                sbAddUsers.Append(" ");
                sbAddUsers.Append(oPerson.LastName);
                sbAddUsers.Append(" - ");
                sbAddUsers.Append(oPerson.Email);
                sbAddUsers.Append(Environment.NewLine);
            }

            if (sbAddUsers.Length > 0)
            {
                sbAddUsers.Insert(0, Environment.NewLine + "Specified Additional Users" + Environment.NewLine);
            }

            return sbAddUsers.ToString();
        }

        protected string GetTaskMsg(string szOrderMsg, int paymentID)
        {
            StringBuilder sbMsg = new StringBuilder();
            sbMsg.Append(szOrderMsg + Environment.NewLine + Environment.NewLine);
            sbMsg.Append("Product Information" + Environment.NewLine);
            sbMsg.Append(GetFormattedProductList(_oCCPayment, Environment.NewLine) + Environment.NewLine);

            if (cbMoreInfo.Visible && cbMoreInfo.Checked)
            {
                sbMsg.Append("Requested Membership Info: Y" + Environment.NewLine);
            }

            if (BRCompany.Visible && !string.IsNullOrEmpty(BRCompany.Text))
            {
                sbMsg.Append("Subject Company: " + BRCompany.Text  + " " + _oCCPayment.SelectedIDs + Environment.NewLine);
            }

            if (ddlHowLearned.Visible && !string.IsNullOrEmpty(ddlHowLearned.SelectedValue))
            {
                sbMsg.Append(Environment.NewLine + "How Learned: " + ddlHowLearned.SelectedValue + Environment.NewLine);
                if (txtProduceHowLearnedOther.Visible && !string.IsNullOrEmpty(txtProduceHowLearnedOther.Text))
                {
                    sbMsg.Append("How Learned Other: " + txtProduceHowLearnedOther.Text + Environment.NewLine);
                }
            }

            if (txtReferralPerson.Visible && !string.IsNullOrEmpty(txtReferralPerson.Text))
            {
                sbMsg.Append("Referral Person: " + txtReferralPerson.Text + Environment.NewLine);
            }

            if (txtReferralCompany.Visible && !string.IsNullOrEmpty(txtReferralCompany.Text))
            {
                sbMsg.Append("Referral Company: " + txtReferralCompany.Text + Environment.NewLine);
            }

            if (txtSpecialInstructions.Visible && !string.IsNullOrEmpty(txtSpecialInstructions.Text))
            {
                sbMsg.Append("Special Instructions" + Environment.NewLine);
                sbMsg.Append(txtSpecialInstructions.Text + Environment.NewLine + Environment.NewLine);
            }

            sbMsg.Append(FormatCreditCardInfo(paymentID));
            sbMsg.Append(GetAdditionalUsersList());

            return sbMsg.ToString();
        }

        protected string FormatStripeResults()
        {

            if (_TrxnStripeCharge == null)
            {
                return string.Empty;
            }

            StringBuilder sbStripeResults = new StringBuilder();

            if (!string.IsNullOrEmpty(_TrxnStripeCharge.AuthorizationCode))
            {
                sbStripeResults.Append("Stripe Authorization Code: " + _TrxnStripeCharge.AuthorizationCode + Environment.NewLine);
            }

            if (!string.IsNullOrEmpty(_TrxnStripeCharge.Status))
            {
                sbStripeResults.Append("Stripe Status Message: " + _TrxnStripeCharge.Status + Environment.NewLine);
            }

            return sbStripeResults.ToString();
        }

        protected const string SQL_PRPAYMENT_INSERT = "INSERT INTO PRPayment (prpay_PaymentID, prpay_RequestID, prpay_MembershipPurchaseID, prpay_NameOnCard, prpay_CreditCardType, prpay_CreditCardNumber, prpay_ExpirationMonth, prpay_ExpirationYear, prpay_AuthorizationCode, prpay_AVSAddr, prpay_AVSPostal, prpay_IPAddress, prpay_ItemCount, prpay_Amount, prpay_ShippingAmount, prpay_TaxAmount, prpay_Street1, prpay_Street2, prpay_City, prpay_StateID, prpay_CountryID, prpay_PostalCode, prpay_County, prpay_TaxedAmount, prpay_CreatedBy, prpay_CreatedDate, prpay_UpdatedBy, prpay_UpdatedDate, prpay_Timestamp) VALUES ({0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16},{17},{18},{19},{20},{21},{22},{23},{24},{25},{26},{27},{28})";
        protected const string SQL_PRPAYMENTPRODUCT_INSERT = "INSERT INTO PRPaymentProduct (prpayprod_PaymentID, prpayprod_ProductID, prpayprod_Quantity, prpayprod_Price, prpayprod_CreatedBy, prpayprod_CreatedDate, prpayprod_UpdatedBy, prpayprod_UpdatedDate, prpayprod_Timestamp) VALUES ({0},{1},{2},{3},{4},{5},{6},{7},{8})";

        /// <summary>
        /// Creates the PRPyament records.
        /// </summary>
        /// <param name="iPaymentID"></param>
        /// <param name="iRequestID"></param>
        /// <param name="iMembershipPurchaseID"></param>
        /// <param name="oTran"></param>
        protected void CreatePayment(int iPaymentID, int iRequestID, int iMembershipPurchaseID, IDbTransaction oTran)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prpay_PaymentID", iPaymentID));
            oParameters.Add(new ObjectParameter("prpay_RequestID", iRequestID));
            //oParameters.Add(new ObjectParameter("prpay_ServiceUnitAllocationID", _iServiceUnitAllocationID));
            oParameters.Add(new ObjectParameter("prpay_NameOnCard", iMembershipPurchaseID));
            oParameters.Add(new ObjectParameter("prpay_MembershipPurchaseID", txtNameOnCard.Text));

            if (_TrxnStripeCharge != null)
            {
                oParameters.Add(new ObjectParameter("prpay_CreditCardType", EBB.BusinessObjects.Stripe.GetCreditCardType(_TrxnStripeCharge.PaymentMethodDetails.Card.Brand)));
                oParameters.Add(new ObjectParameter("prpay_CreditCardNumber", _TrxnStripeCharge.PaymentMethodDetails.Card.Last4));
                oParameters.Add(new ObjectParameter("prpay_ExpirationMonth", _TrxnStripeCharge.PaymentMethodDetails.Card.ExpMonth));
                oParameters.Add(new ObjectParameter("prpay_ExpirationYear", _TrxnStripeCharge.PaymentMethodDetails.Card.ExpYear));
                oParameters.Add(new ObjectParameter("prpay_AuthorizationCode", _TrxnStripeCharge.Id));
            }
            else
            {
                oParameters.Add(new ObjectParameter("prpay_CreditCardType", null));
                oParameters.Add(new ObjectParameter("prpay_CreditCardNumber", null));
                oParameters.Add(new ObjectParameter("prpay_ExpirationMonth", null));
                oParameters.Add(new ObjectParameter("prpay_ExpirationYear", null));
                oParameters.Add(new ObjectParameter("prpay_AuthorizationCode", null));
            }
            oParameters.Add(new ObjectParameter("prpay_AVSAddr", null));
            oParameters.Add(new ObjectParameter("prpay_AVSPostal", null));

            oParameters.Add(new ObjectParameter("prpay_IPAddress", Request.ServerVariables["REMOTE_ADDR"]));
            oParameters.Add(new ObjectParameter("prpay_ItemCount", _oCCPayment.Products.Count));
            oParameters.Add(new ObjectParameter("prpay_Amount", _oCCPayment.TotalPrice));
            oParameters.Add(new ObjectParameter("prpay_ShippingAmount", _oCCPayment.Shipping));
            oParameters.Add(new ObjectParameter("prpay_TaxAmount", _oCCPayment.TaxAmount));
            oParameters.Add(new ObjectParameter("prpay_Street1", txtStreet1.Text));
            oParameters.Add(new ObjectParameter("prpay_Street2", txtStreet2.Text));
            oParameters.Add(new ObjectParameter("prpay_City", txtCity.Text));
            oParameters.Add(new ObjectParameter("prpay_StateID", ddlState.SelectedValue));
            oParameters.Add(new ObjectParameter("prpay_CountryID", ddlCountry.SelectedValue));
            oParameters.Add(new ObjectParameter("prpay_PostalCode", txtPostalCode.Text));
            oParameters.Add(new ObjectParameter("prpay_County", txtCounty.Text));
            oParameters.Add(new ObjectParameter("prpay_TaxedAmount", _oCCPayment.GetTaxedCost()));
            GetObjectMgr().AddAuditTrailParametersForInsert(oParameters, "prpay");

            string szSQL = GetObjectMgr().FormatSQL(SQL_PRPAYMENT_INSERT, oParameters);
            GetObjectMgr().ExecuteInsert("PRPayment", szSQL, oParameters, oTran);

            foreach (CreditCardProductInfo oProductInfo in _oCCPayment.Products)
            {
                oParameters.Clear();

                oParameters.Add(new ObjectParameter("prpayprod_PaymentID", iPaymentID));
                oParameters.Add(new ObjectParameter("prpayprod_ProductID", oProductInfo.ProductID));
                oParameters.Add(new ObjectParameter("prpayprod_Quantity", oProductInfo.Quantity));
                oParameters.Add(new ObjectParameter("prpayprod_Price", oProductInfo.Price));
                GetObjectMgr().AddAuditTrailParametersForInsert(oParameters, "prpayprod");

                szSQL = GetObjectMgr().FormatSQL(SQL_PRPAYMENTPRODUCT_INSERT, oParameters);
                GetObjectMgr().ExecuteIdentityInsert("PRPaymentProduct", szSQL, oParameters, oTran);
            }
        }

    private string GetQueryString()
        {
            string szQry = LangQueryString();
            return szQry;
        }

        protected void btnPreviousOnClick(object sender, EventArgs e)
        {
            if (_oCCPayment == null)
            {
                Response.Redirect("MembershipSelect.aspx" + GetQueryString());
                return;
            }

            if (_oCCPayment.RequestType == "Membership")
                Response.Redirect("MembershipUsers.aspx" + GetQueryString());
        }

        protected void btnCancelOnClick(object sender, EventArgs e)
        {
            Session.Remove("oCreditCardPayment");

            switch (_oCCPayment.RequestType)
            {
                case "BR":
                    Response.Redirect("/find-companies/company-profile/?ID=" + GetRequestParameter("CompanyID"));
                    break;
                case "Membership":
                    Response.Redirect(GetMarketingSiteURL() + "/join-today/");
                    break;
            }
        }

        protected void CreateBBOSUsers()
        {
            CreditCardProductInfo ccProductInfo = GetProductInfo(_oCCPayment, Utilities.GetIntConfigValue("MembershipProductFamily", 5), 0);
            PRWebUserMgr bbosUserMgr = new PRWebUserMgr(_oLogger, null);
            
            List<EBB.BusinessObjects.Person> lPersons = (List<EBB.BusinessObjects.Person>)Session["lMembershipUsers"];
            foreach (EBB.BusinessObjects.Person person in lPersons)
            {
                if (!string.IsNullOrEmpty(person.Email))
                {
                    IPRWebUser BBOSUser = null;
                    if (bbosUserMgr.UserExists(person.Email, 0, false))
                    {
                        BBOSUser = (IPRWebUser)bbosUserMgr.GetByEmail(person.Email, false);
                        BBOSUser.prwu_Disabled = false;
                    }
                    else
                    {
                        BBOSUser = (IPRWebUser)bbosUserMgr.CreateObject();
                    }

                    BBOSUser.prwu_AccessLevel = ccProductInfo.AccessLevel;
                    BBOSUser.Email = person.Email;
                    BBOSUser.FirstName = person.FirstName;
                    BBOSUser.LastName = person.LastName;
                    BBOSUser.prwu_IndustryType = GetIndustryType();
                    BBOSUser.prwu_Culture = "en-us";
                    BBOSUser.prwu_UICulture = "en-us";
                    BBOSUser.prwu_DefaultCompanySearchPage = "CompanySearch.aspx";
                    BBOSUser.prwu_CompanyUpdateMessageType = "All";
                    BBOSUser.prwu_Timezone = "Eastern Standard Time";
                    BBOSUser.GeneratePassword();

                    BBOSUser.Save();
                    BBOSUser.EmailPassword();
                }
            }
        }

        public void SendMembershipEmail()
        {
            string suffix = string.Empty;
            if (GetIndustryType() == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                suffix = "L";
            }

            string subject = GetReferenceValue("MembershipPurchaseEmail" + suffix, "Subject");
            string body = GetReferenceValue("MembershipPurchaseEmail" + suffix, "Body");
            string email = GetObjectMgr().GetFormattedEmail(0, 0, 0, subject, body, "en-us", _oCCPayment.IndustryType);

            GeneralDataMgr oMgr = new GeneralDataMgr(_oLogger, null);
            oMgr.SendEmail(txtSubmitterEmail.Text,
                            EmailUtils.GetFromAddress(),
                            subject,
                            email,
                            true,
                            null,
                            "Payment.aspx",
                            null);
        }

        public void CreateBRPurchase(CreditCardProductInfo oProductInfo, int paymentID, string companyID)
        {
            IPRBusinessReportPurchase brPurchase = (IPRBusinessReportPurchase)new PRBusinessReportPurchaseMgr(_oLogger, null).CreateObject();
            brPurchase.prbrp_SubmitterEmail = BREmailAddress.Text;
            brPurchase.prbrp_IndustryType = _oCCPayment.IndustryType;
            brPurchase.prbrp_PaymentID = paymentID;
            brPurchase.prbrp_ProductID = oProductInfo.ProductID;
            brPurchase.prbrp_CompanyID = Convert.ToInt32(companyID);

            if (cbMoreInfo.Checked)
                brPurchase.prbrp_RequestsMembershipInfo = "Y";

            brPurchase.Save();
            brPurchase.SendBREmail(oProductInfo.ProductCode);
            //brPurchase.CreateCRMTask(_oCCPayment, oProductInfo);
        }

        protected string GetBRChecked(int productID)
        {
            CreditCardProductInfo ccProductInfo = GetProductInfo(_oCCPayment, Utilities.GetIntConfigValue("BRProductFamily", 3), 0);
            if (ccProductInfo != null)
            {
                if (productID == ccProductInfo.ProductID)
                {
                    return "checked=\"checked\"";
                }
            }
            return string.Empty;
        }

        protected string GetCompanyName(int companyID)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", companyID));
            return (string)GetDBAccess().ExecuteScalar("SELECT comp_PRCorrTradestyle FROM Company WITH (NOLOCK) WHERE comp_CompanyID=@CompanyID", oParameters);
        }

        protected void cbMailingAddressDifferent_CheckedChanged(object sender, EventArgs e)
        {
            pnlMailingAddressDifferent.Visible = cbMailingAddressDifferent.Checked;
        }
    }
}