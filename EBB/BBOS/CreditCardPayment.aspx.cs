/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CreditCardPayment
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using PRCo.EBB.BusinessObjects;
using PRCo.EBB.Util;
using TSI.Arch;
using TSI.BusinessObjects;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;
using Stripe;
using System.Collections.Specialized;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Handles the credit card payment authorization and subsequent saving
    /// of purchase information.  This includes creating PRPurchase, PRPayement,
    /// PRRequest records as well as the appropriate tasks in BBS CRM.  
    /// 
    /// This pages expects to find a CreditCardPaymentInfo  object in the 
    /// Session["oCreditCardPayment"]. 
    ///
    /// To test this, refer to Chapter 5 of the PayflowPro_Guide.pdf document for details.
    /// A MasterCard value of 5555555555554444 can be used for testing.
    /// </summary>
    public partial class CreditCardPayment : PageBase
    {
        //protected CreditCardPaymentInfo _oCCPayment = null;
        protected string _szResponseMsg;
        protected string _szRequestType;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if (Session["oCreditCardPayment"] == null)
            {
                throw new ApplicationUnexpectedException("Invalid Credit Card Transaction found.");
            }

            ucCCI.CCPayment = (CreditCardPaymentInfo)Session["oCreditCardPayment"];

            if (ucCCI.CCPayment.RequestType.StartsWith("BR") && ucCCI.CCPayment.Products.Count == 0)
                Response.Redirect(PageConstants.BROWSE_PURCHASES);

            if (IsPostBack)
            {
                // Handle Stripe payments
                NameValueCollection nvc = Request.Form;
                string hfStripeToken = nvc["hfStripeToken"];
                if (!string.IsNullOrEmpty(hfStripeToken))
                {
                    btnPurchaseOnClick(hfStripeToken);
                }
            }

            //GetCCUser();

            SetPageTitle(Resources.Global.PaymentInformation);

            EnableFormValidation();
            btnCancel.OnClientClick = "bEnableValidation=false;";

            if (!IsPostBack)
            {
                PopulateForm();

                ucCCI.ProductLabel = lblProduct.Text;
            }
        }

        /// <summary>
        /// Populates the form controls.
        /// </summary>
        protected void PopulateForm()
        {
            //// Set User Information
            lblProduct.Text = GetProductDescriptions(ucCCI.CCPayment);

            // Only membership products have shipping charges
            // and have associated taxes.
            if (ucCCI.CCPayment.RequestType == "Membership")
            {
                CalculateCharges(null, null);
            }

            //Hide county for online business report purchases
            if (ucCCI.CCPayment.RequestType.StartsWith("BR") || ucCCI.CCPayment.RequestType == "AddUnits" || ucCCI.CCPayment.RequestType == "BV")
                ucCCI.BillingCountyVisible = false; 

            ucCCI.CCPayment.TotalPrice = ucCCI.CCPayment.GetCost() + ucCCI.CCPayment.Shipping + ucCCI.CCPayment.TaxAmount;

            lblSubTotal.Text = UIUtils.GetFormattedCurrency(ucCCI.CCPayment.GetCost(), 0M);
            lblShipping.Text = UIUtils.GetFormattedCurrency(ucCCI.CCPayment.Shipping, 0M);
            lblSalesTax.Text = UIUtils.GetFormattedCurrency(ucCCI.CCPayment.TaxAmount, 0M);
            lblTotal.Text = UIUtils.GetFormattedCurrency(ucCCI.CCPayment.TotalPrice, 0M);
        }

        protected void CalculateCharges(object sender, EventArgs e)
        {
            if (ucCCI.CCPayment.RequestType == "Membership")
            {
                ucCCI.CCPayment.CountryID = _oUser.prwu_CountryID;
                if (!string.IsNullOrEmpty(ucCCI.Country_Value))
                {
                    ucCCI.CCPayment.CountryID = Convert.ToInt32(ucCCI.Country_Value);
                    ucCCI.cddCountry_ContextKey = ucCCI.Country_Value;
                }

                ucCCI.CCPayment.StateID = _oUser.prwu_StateID;
                if (!string.IsNullOrEmpty(ucCCI.State_Value))
                {
                    ucCCI.CCPayment.StateID = Convert.ToInt32(ucCCI.State_Value);
                    ucCCI.cddState_ContextKey = ucCCI.State_Value;
                }

                ucCCI.CCPayment.County = ucCCI.County;
                ucCCI.CCPayment.City = ucCCI.City;
                ucCCI.CCPayment.PostalCode = ucCCI.PostalCode;

                // Compute out our tax using the User values
                ucCCI.CCPayment.GetTaxedCost();
                lblSalesTax.Text = UIUtils.GetFormattedCurrency(ucCCI.CCPayment.TaxAmount, 0M);

                // Compute shipping for each product
                lblShipping.Text = UIUtils.GetFormattedCurrency(ucCCI.CCPayment.GetShippingRate(), 0M);

                ucCCI.CCPayment.TotalPrice = ucCCI.CCPayment.GetCost() + ucCCI.CCPayment.Shipping + ucCCI.CCPayment.TaxAmount;
                lblTotal.Text = UIUtils.GetFormattedCurrency(ucCCI.CCPayment.TotalPrice, 0M);
            }
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

        /// <summary>
        /// Returns the user to the specified ReturnURL
        /// parameter.  If not specified, then the user is returned
        /// to the company search results executing the last search.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnCancelOnClick(object sender, EventArgs e)
        {
            Session.Remove("oCreditCardPayment");
            Response.Redirect(GetReturnURL(PageConstants.COMPANY_SEARCH_RESULTS_EXECUTE_LAST));
        }

        /// <summary>
        /// Returns the user to the specified ReturnURL
        /// parameter.  If not specified, then the user is returned
        /// to the company search results executing the last search.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnReviseOnClick(object sender, EventArgs e)
        {
            Response.Redirect(GetReturnURL(PageConstants.COMPANY_SEARCH_RESULTS_EXECUTE_LAST));
        }


        const string PRODUCT_INFORMATION = "Product Information";

        protected void btnPurchaseOnClick(object sender, EventArgs e)
        {
            NameValueCollection nvc = Request.Form;
            string hfStripeToken = nvc["hfStripeToken"];

            btnPurchaseOnClick(hfStripeToken);
        }

        protected void btnPurchaseOnClick(string stripeToken)
        {
            // Get our RequestID.  This will be our "OOTN" to include
            // in the Verisign transaction
            ucCCI.PaymentID = GetObjectMgr().GetRecordID("PRPayment");

            List<Int32> lIDs = new List<int>();
            foreach (CreditCardProductInfo oProductInfo in ucCCI.CCPayment.Products)
            {
                lIDs.Add(oProductInfo.ProductID);
            }

            if (ucCCI.CCPayment.RequestType == "Membership")
            {
                // Re Compute out our tax in case the user changed thier
                // billing location.
                CalculateCharges(null, null);
            }


            if (!ucCCI.ExecutePayment(stripeToken))
            {
                AddUserMessage(Resources.Global.CreditCardDeniedMsg);
                return;
            }

            ucCCI.AuthCode = ucCCI.TrxnStripeCharge.Id;
            ucCCI.CCPayment.TotalPrice = ucCCI.CCPayment.GetCost() + ucCCI.CCPayment.Shipping + ucCCI.CCPayment.TaxAmount;

            IDbTransaction oTran = GetObjectMgr().BeginTransaction();

            try
            {
                // Create the Request if the request type warrants it.
                if ((ucCCI.CCPayment.RequestType != "Membership") &&
                    (ucCCI.CCPayment.RequestType != "AddUnits"))
                {
                    int iProductID = ucCCI.CCPayment.Products[0].ProductID;
                    ucCCI.RequestID = GetObjectMgr().CreateRequest(ucCCI.CCPayment.RequestType,
                                                               ucCCI.CCPayment.GetCost(),
                                                               ucCCI.CCPayment.Name,
                                                               ucCCI.CCPayment.SelectedIDs,
                                                               iProductID,
                                                               PRICING_LIST_ONLINE,
                                                               ucCCI.CCPayment.TriggerPage,
                                                               null,
                                                               null,
                                                               oTran);
                }

                // Process the Additional Units type
                if (ucCCI.CCPayment.RequestType == "AddUnits")
                {
                    int Alloc_ID = ucCCI.ProcessAdditionalUnits(oTran);

                    string szMsg = ucCCI.GetTaskMsg(ucCCI.ADD_UNITS_MSG);
                    int related_company = 0;
                    int related_person = 0;
                    int sales_person = 0;

                    CreditCardPaymentInfo oCCPI = (CreditCardPaymentInfo)Session["oCreditCardPayment"];
                    if(oCCPI != null)
                    {
                        if (oCCPI.RequestType == "AddUnits")
                        {
                            szMsg = szMsg.Replace(PRODUCT_INFORMATION + Environment.NewLine,
                                PRODUCT_INFORMATION + Environment.NewLine + oCCPI.AdditionalUnits + " Additional Online Business Reports" + Environment.NewLine);
                        }
                    }

                    if (_oUser != null)
                    {
                        related_company = _oUser.prwu_BBID;
                        related_person = _oUser.peli_PersonID;
                    }

                    // Note: GetPRCoSpecialistID will crash if related_company is not in the DB.
                    sales_person = related_company > 0 ?
                            GetObjectMgr().GetPRCoSpecialistID(related_company,
                                                               GeneralDataMgr.PRCO_SPECIALIST_CSR, oTran)
                            : Utilities.GetIntConfigValue("AdditionalUnitsPurchaseUserID", 1);

                    GetObjectMgr().CreateTask(sales_person,
                                              "Pending",
                                              szMsg,
                                              Utilities.GetConfigValue("AdditionalUnitsPurchaseCategory", string.Empty),
                                              Utilities.GetConfigValue("AdditionalUnitsPurchaseSubcategory", string.Empty),
                                              related_company,
                                              related_person,
                                              0,
                                              "OnlineIn",
                                              oTran);

                    ////Defect 6973 - emails via stored proc
                    //GetObjectMgr().SendEmail_Text(GetObjectMgr().GetPRCoUserEmail(sales_person, oTran),
                    //                           Utilities.GetConfigValue("AdditionalUnitsPurchaseEmailSubject", "Additional Business Reports Purchased via BBOS"),
                    //                           szMsg,
                    //                           "CreditCardPayment.aspx",
                    //                           oTran);

                    GetObjectMgr().SendEmail_Text(GetObjectMgr().GetPRCoUserEmail(Utilities.GetIntConfigValue("AdditionalUnitsPurchaseEmailAcctUserID", 1029), oTran),
                                                Utilities.GetConfigValue("AdditionalUnitsPurchaseEmailSubject", "Additional Business Reports Purchased via BBOS"),
                                                szMsg,
                                                "CreditCardPayment.aspx",
                                                oTran);

                    //Defect 7396 - send email to all Sales People (default ('TJR', 'JBL', 'LEL') -- Jeff Lair, Leticia Lima, Tim Reardon
                    SendEmailToSales(Utilities.GetConfigValue("AdditionalUnitsPurchaseEmailSubject", "Additional Business Reports Purchased via BBOS"),
                            szMsg,
                            "CreditCardPayment.aspx",
                            _oUser,
                            oTran);
                }

                // If this is an "ala-carte" order for a Business Report or
                // Marketing List, create the appropriate task.
                if (ucCCI.CCUser.prwu_AccessLevel == PRWebUser.SECURITY_LEVEL_TRADE_ASSOCIATION_ACCESS)
                {
                    if ((ucCCI.CCPayment.RequestType.StartsWith("BR")) ||
                        (ucCCI.CCPayment.RequestType.StartsWith("ML")))
                    {
                        int iPRCoSpecialistID = ucCCI.GetPRCoSpecialistID(GeneralDataMgr.PRCO_SPECIALIST_INSIDE_SALES,
                                                                    Utilities.GetIntConfigValue("AlacartePurchaseUnknownCityPRCoUserID", 24),
                                                                    ucCCI.CCUser.prwu_IndustryType,
                                                                    oTran);

                        string szMsg = ucCCI.GetTaskMsg(ucCCI.ALACARTE_MSG);
                        
                        szMsg = szMsg.Replace(PRODUCT_INFORMATION + Environment.NewLine, 
                            PRODUCT_INFORMATION + Environment.NewLine + "Alacarte Business Report purchased for: " + ucCCI.CCPayment.SelectedIDs + Environment.NewLine);

                        GetObjectMgr().CreateTask(iPRCoSpecialistID,
                                                  "Pending",
                                                  szMsg,
                                                  Utilities.GetConfigValue("AlaCartePurchaseCategory", string.Empty),
                                                  Utilities.GetConfigValue("AlaCartePurchaseSubcategory", string.Empty),
                                                  oTran);

                        ////Defect 6973 - emails via stored proc
                        //GetObjectMgr().SendEmail_Text(GetObjectMgr().GetPRCoUserEmail(iPRCoSpecialistID, oTran),
                        //    Utilities.GetConfigValue("AlaCartePurchaseEmailSubject", "Ala Carte Purchase via BBOS"),
                        //    szMsg,
                        //    "CreditCardPayment.aspx",
                        //    oTran);

                        GetObjectMgr().SendEmail_Text(GetObjectMgr().GetPRCoUserEmail(Utilities.GetIntConfigValue("AlaCartePurchaseEmailAcctUserID", 1029), oTran),
                            Utilities.GetConfigValue("AlaCartePurchaseEmailSubject", "Ala Carte Purchase via BBOS"),
                            szMsg,
                            "CreditCardPayment.aspx",
                            oTran);

                        //Defect 7396 - send email to all Sales People (default ('TJR', 'JBL', 'LEL') -- Jeff Lair, Leticia Lima, Tim Reardon
                        SendEmailToSales(Utilities.GetConfigValue("AlaCartePurchaseEmailSubject", "Ala Carte Purchase via BBOS"),
                                szMsg,
                                "CreditCardPayment.aspx",
                                _oUser,
                                oTran);
                    }
                }

                // If this is a membership purchase...
                if (ucCCI.CCPayment.RequestType == "Membership")
                {
                    ProcessMembership(oTran);
                    UpdateCompany(oTran);

                    string szMsg = ucCCI.GetTaskMsg(ucCCI.MEMBERSHIP_MSG);

                    int iPRCoSpecialistID = ucCCI.GetPRCoSpecialistID(GeneralDataMgr.PRCO_SPECIALIST_INSIDE_SALES,
                                                                Utilities.GetIntConfigValue("MembershipPurchaseUnknownCityPRCoUserID", 24),
                                                                ucCCI.CCUser.prwu_IndustryType,
                                                                oTran);
                    GetObjectMgr().CreateTask(iPRCoSpecialistID,
                                              "Pending",
                                              szMsg,
                                              Utilities.GetConfigValue("MembershipPurchaseCategory", string.Empty),
                                              Utilities.GetConfigValue("MembershipPurchaseSubcategory", string.Empty),
                                              oTran);

                    //Defect 6973 - emails via stored proc
                    //GetObjectMgr().SendEmail_Text(GetObjectMgr().GetPRCoUserEmail(iPRCoSpecialistID, oTran),
                    //        Utilities.GetConfigValue("MembershipPurchaseEmailSubject", "Membership Purchase via BBOS"),
                    //        szMsg,
                    //        "CreditCardPayment.aspx",
                    //        oTran);

                    GetObjectMgr().SendEmail_Text(GetObjectMgr().GetPRCoUserEmail(Utilities.GetIntConfigValue("MembershipPurchaseEmailAcctUserID", 1029), oTran),
                            Utilities.GetConfigValue("MembershipPurchaseEmailSubject", "Membership Purchase via BBOS"),
                            szMsg,
                            "CreditCardPayment.aspx",
                            oTran);

                    //Defect 7396 - send email to all Sales People (default ('TJR', 'JBL', 'LEL') -- Jeff Lair, Leticia Lima, Tim Reardon
                    SendEmailToSales(Utilities.GetConfigValue("MembershipPurchaseEmailSubject", "Membership Purchase via BBOS"),
                            szMsg,
                            "CreditCardPayment.aspx",
                            _oUser,
                            oTran);

                }

                ucCCI.CCUser.Save(oTran);
                Session["oUser"] = ucCCI.CCUser;

                ucCCI.CreatePayment(oTran);

                oTran.Commit();
            }
            catch
            {
                if (oTran != null)
                {
                    oTran.Rollback();
                }
                throw;
            }

            if (ucCCI.CCPayment.RequestType == "Membership" && _oUser.IsLimitado)
            {
                ProcessLimitado();
            }

            if (ucCCI.CCPayment.RequestType == "BV")
            {
                string szMsg = ucCCI.GetTaskMsg(ucCCI.ALACARTE_MSG);
                szMsg = szMsg.Replace(PRODUCT_INFORMATION + Environment.NewLine,
                    PRODUCT_INFORMATION + Environment.NewLine + "Alacarte Business Valuation purchased for: " + ucCCI.CCPayment.SelectedIDs + Environment.NewLine);

                //Send Emails
                GetObjectMgr().SendEmail_Text(GetObjectMgr().GetPRCoUserEmail(Utilities.GetIntConfigValue("AlaCartePurchaseEmailAcctUserID", 1029), oTran),
                    Utilities.GetConfigValue("AlaCarteBusinessValuationPurchaseEmailSubject", "Ala Carte Business Valuation Purchase via BBOS"),
                    szMsg,
                    "CreditCardPayment.aspx",
                    oTran);

                //Defect 7396 - send email to all Sales People (default ('TJR', 'JBL', 'LEL') -- Jeff Lair, Leticia Lima, Tim Reardon
                SendEmailToSales(Utilities.GetConfigValue("AlaCarteBusinessValuationPurchaseEmailSubject", "Ala Carte Business Valuation Purchase via BBOS"),
                        szMsg,
                        "CreditCardPayment.aspx",
                        _oUser,
                        oTran);

                ProcessBusinessValuation();
            }

            // Set these values so that our receipt screen 
            // can display them.
            ucCCI.CCPayment.Street1 = ucCCI.Street1;
            ucCCI.CCPayment.Street2 = ucCCI.Street2;
            ucCCI.CCPayment.City = ucCCI.City;
            ucCCI.CCPayment.StateID = Convert.ToInt32(ucCCI.State_Value);
            ucCCI.CCPayment.CountryID = Convert.ToInt32(ucCCI.Country_Value);
            ucCCI.CCPayment.PostalCode = ucCCI.PostalCode;
            ucCCI.CCPayment.AuthorizationCode = ucCCI.AuthCode; //_szAuthCode;
            ucCCI.CCPayment.PaymentID = ucCCI.PaymentID; //_iPaymentID;
            ucCCI.CCPayment.ProductDescriptions = lblProduct.Text;

            ucCCI.CCPayment.CreditCardNumber = ucCCI.TrxnStripeCharge.PaymentMethodDetails.Card.Last4;
            ucCCI.CCPayment.CreditCardType = EBB.BusinessObjects.Stripe.GetCreditCardType(ucCCI.TrxnStripeCharge.PaymentMethodDetails.Card.Brand);

            Response.Redirect(PageConstants.CREDIT_CARD_PAYMENT_RECEIPT);
        }

        private void ProcessLimitado()
        {
            GetObjectMgr().SetCompanyITAAccessFlag(false); //SET company ITAAccessFlag to NULL
            _oUser.prwu_ServiceCode = null; //remove ITALIC from this user

            _oUser.prwu_AccessLevel = Convert.ToInt32(GetRequestParameter("MembershipAccessLevel"));
            _oUser.prwu_AcceptedTerms = true;
            _oUser.prcta_IsIntlTradeAssociation = false;
            _oUser.Save();
            Session["oUser"] = _oUser;

            SetRequestParameter("ITAMode", "true");
        }

        private void ProcessBusinessValuation()
        {
            SetRequestParameter("DisplayThanks", "true");
            SetRequestParameter("BusinessValuationSetIP", "true");
            Response.Redirect(PageConstants.BUSINESS_VALUATION);
        }

        protected const string SQL_PRMEMBERSHIPPURCHASE_INSERT = "INSERT INTO PRMembershipPurchase (prmp_PaymentID, prmp_ProductID, prmp_Quantity, prmp_DeliveryCode, prmp_DeliveryDestination, prmp_CreatedBy, prmp_CreatedDate, prmp_UpdatedBy, prmp_UpdatedDate, prmp_Timestamp) VALUES ({0},{1},{2},{3},{4},{5},{6},{7},{8},{9})";
        /// <summary>
        /// Creates the PRPyament records.
        /// </summary>
        /// <param name="oTran"></param>
        protected void ProcessMembership(IDbTransaction oTran)
        {
            ArrayList oParameters = new ArrayList();

            foreach (CreditCardProductInfo oProductInfo in ucCCI.CCPayment.Products)
            {
                oParameters.Clear();
                oParameters.Add(new ObjectParameter("prmp_PaymentID", ucCCI.PaymentID));
                oParameters.Add(new ObjectParameter("prmp_ProductID", oProductInfo.ProductID));
                oParameters.Add(new ObjectParameter("prmp_Quantity", oProductInfo.Quantity));
                oParameters.Add(new ObjectParameter("prmp_DeliveryCode", oProductInfo.DeliveryCode));
                oParameters.Add(new ObjectParameter("prmp_DeliveryDestination", oProductInfo.DeliveryDestination));
                GetObjectMgr().AddAuditTrailParametersForInsert(oParameters, "prmp");

                string szSQL = GetObjectMgr().FormatSQL(SQL_PRMEMBERSHIPPURCHASE_INSERT, oParameters);
                int iID = GetObjectMgr().ExecuteIdentityInsert("PRMembershipPurchase", szSQL, oParameters, oTran);

                // We want to return the ID of the primary membership
                // product purchase.
                if (oProductInfo.ProductFamilyID == Utilities.GetIntConfigValue("MembershipProductFamily", 5))
                {
                    ucCCI.MembershipPurchaseID = iID;
                }
            }
        }

        /// <summary>
        /// Helper method updates the associated company indicating when the terms
        /// where accepted and by whom.
        /// </summary>
        /// <param name="oTran"></param>
        protected void UpdateCompany(IDbTransaction oTran)
        {
            if (ucCCI.CCUser.prwu_PersonLinkID == 0)
            {
                return;
            }

            GetObjectMgr().SetAcceptedTerms();
        }

        public override bool EnableJSClientIDTranslation()
        {
            return true;
        }
    }
}
