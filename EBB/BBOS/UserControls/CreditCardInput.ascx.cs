/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2018-2023

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CreditCardInput.ascx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/

using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Net;
using System.Text;
using PRCo.EBB.BusinessObjects;
using PRCo.EBB.Util;
using Stripe;
using TSI.BusinessObjects;
using TSI.DataAccess;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web.UserControls
{
    public partial class CreditCardInput : UserControlBase
    {
        protected IPRWebUser _oCCUser = null;
        protected CreditCardPaymentInfo _oCCPayment = null;

        protected int _iPaymentID = 0;
        protected int _iRequestID = 0;
        protected int _iServiceUnitAllocationID;
        protected int _iMembershipPurchaseID;
        protected string _szAVSPostal;
        protected string _szAVSAddr;
        protected string _szAuthCode;
        protected string _szResultCode;

        protected bool _bBillingCountyVisible = true;
        protected string _szProductLabel = "";

        public string ADD_UNITS_MSG = "An additional business reports order was placed by the following company.  Please review and add the order to MAS.";
        public string MEMBERSHIP_MSG = "A membership order was placed by the following company.  Please add the order to MAS and process online access settings in CRM.";
        public string ALACARTE_MSG = "A ala carte order was placed by the following company.";

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            SetPopover();

            if (!IsPostBack)
            {
                LoadLookupValues();

                // Setup our "context", or default values, for our cascading
                // dropdown lists.
                cddCountry.ContextKey = GetCCUser().prwu_CountryID.ToString();
                cddState.ContextKey = GetCCUser().prwu_StateID.ToString();

                PopulateForm();
            }
        }

        protected void PopulateForm()
        {
            // Set User Information
            GetCCUser();
            txtNameOnCard.Text = _oCCUser.FirstName + " " + _oCCUser.LastName;
            txtStreet1.Text = _oCCUser.prwu_Address1;
            txtStreet2.Text = _oCCUser.prwu_Address2;
            txtCity.Text = _oCCUser.prwu_City;
            txtCounty.Text = _oCCUser.prwu_County;
            txtPostalCode.Text = _oCCUser.prwu_PostalCode;
        }

        public IPRWebUser CCUser
        {
            get
            {
                return GetCCUser();
            }
        }

        public Charge TrxnStripeCharge
        {
            get
            {
                return _TrxnStripeCharge;
            }
        }

        /// <summary>
        /// Helper method that retreives a full
        /// user object.  The one in the session is only
        /// partially populated since many of the attribute are 
        /// only needed occassionally.
        /// </summary>
        /// <returns></returns>
        protected IPRWebUser GetCCUser()
        {
            if (_oCCUser == null)
            {
                _oCCUser = (IPRWebUser)new PRWebUserMgr(GetLogger(), WebUser).GetObjectByKey(WebUser.UserID);
            }
            return _oCCUser;
        }

        protected void SetPopover()
        {
            WhatIsCVV.Attributes.Add("data-bs-title", Resources.Global.CVVDefinition);
        }

        /// <summary>
        /// Loads all of the databound controls setting 
        /// thier default values.
        /// </summary>
        protected void LoadLookupValues()
        {
        }

        /// <summary>
        /// Helper method that formats the credit card information
        /// used in the Verisign transaction including the Verisign
        /// response codes.
        /// </summary>
        /// <returns></returns>
        public string FormatCreditCardInfo()
        {
            StringBuilder sbCreditCardInfo = new StringBuilder(Environment.NewLine);

            sbCreditCardInfo.Append("BBOS User: " + _oCCUser.Name + Environment.NewLine);
            sbCreditCardInfo.Append("City: " + txtCity.Text + Environment.NewLine);
            sbCreditCardInfo.Append("State: " + ddlState.SelectedItem.Text + Environment.NewLine);
            sbCreditCardInfo.Append("Name On Card: " + txtNameOnCard.Text + Environment.NewLine);
            
            sbCreditCardInfo.Append("Credit Card Type: " + _TrxnStripeCharge.PaymentMethodDetails.Card.Brand + Environment.NewLine);
            sbCreditCardInfo.Append("Credit Card #: " + _TrxnStripeCharge.PaymentMethodDetails.Card.Last4 + Environment.NewLine);
            sbCreditCardInfo.Append($"Expiration: {_TrxnStripeCharge.PaymentMethodDetails.Card.ExpMonth}/{_TrxnStripeCharge.PaymentMethodDetails.Card.ExpYear}" + Environment.NewLine);
            
            sbCreditCardInfo.Append("Amount: " + UIUtils.GetFormattedCurrency(_oCCPayment.TotalPrice, 0M) + Environment.NewLine);
            sbCreditCardInfo.Append("Payment ID: " + _iPaymentID.ToString() + Environment.NewLine);

            sbCreditCardInfo.Append("Transaction Date/Time: " + DateTime.Now.ToString() + Environment.NewLine);
            sbCreditCardInfo.Append("User's IP Address: " + Request.ServerVariables["REMOTE_ADDR"] + Environment.NewLine);

            sbCreditCardInfo.Append(Environment.NewLine);
            sbCreditCardInfo.Append("Transaction Amount Details:" + Environment.NewLine);
            sbCreditCardInfo.Append("   Sub Total: " + UIUtils.GetFormattedCurrency(_oCCPayment.GetCost(), 0M) + Environment.NewLine);
            sbCreditCardInfo.Append("   Sales Tax: " + UIUtils.GetFormattedCurrency(_oCCPayment.TaxAmount, 0M) + Environment.NewLine);
            sbCreditCardInfo.Append("    Shipping: " + UIUtils.GetFormattedCurrency(_oCCPayment.Shipping, 0M) + Environment.NewLine);
            sbCreditCardInfo.Append("========================" + Environment.NewLine);
            sbCreditCardInfo.Append("Total Amount: " + UIUtils.GetFormattedCurrency(_oCCPayment.TotalPrice, 0M) + Environment.NewLine);

            sbCreditCardInfo.Append(Environment.NewLine);
            sbCreditCardInfo.Append(FormatStripeResults());

            return sbCreditCardInfo.ToString();
        }

        /// <summary>
        /// Helper method used to format the Verisign repsonse
        /// codes.
        /// </summary>
        /// <returns></returns>
        protected string FormatStripeResults()
        {
            if (_TrxnStripeCharge == null)
            {
                return string.Empty;
            }

            StringBuilder sbStripeResults = new StringBuilder();

            if (!string.IsNullOrEmpty(_TrxnStripeCharge.Id))
            {
                sbStripeResults.Append("Stripe Authorization Code: " + _TrxnStripeCharge.Id + Environment.NewLine);
            }

            if (!string.IsNullOrEmpty(_TrxnStripeCharge.Status))
            {
                sbStripeResults.Append("Stripe Status Message: " + _TrxnStripeCharge.Status + Environment.NewLine);
            }

            return sbStripeResults.ToString();
        }

        Charge _TrxnStripeCharge = null;
        /// <summary>
        /// Interface with Verisign to process the credit card
        /// transaction.
        /// </summary>
        /// <returns></returns>
        public bool ExecutePayment(string stripeToken)
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
                Description = "PRPaymentID: " + _iPaymentID.ToString(),
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
                PageBase.LogMessage("Stripe Results:" + stripeCharge.StripeResponse); 
                if (stripeCharge.StripeResponse.StatusCode == HttpStatusCode.OK)
                {
                    return true;
                }
            }
            catch (StripeException ex)
            {
                StripeError stripeError = ex.StripeError;
                PageBase.LogMessage("Stripe Error: " + stripeError.Message);
                szError = stripeError.Message;
            }

            // If we made it here, then we were not authorized
            string szSubject = "Credit Card Authorization Failure";

            string szMsg = "Product Information" + Environment.NewLine;
            szMsg += ProductLabel.Replace("<br />", Environment.NewLine) + Environment.NewLine;
            szMsg += FormatCreditCardInfo();
            szMsg += szError;

            //Defect 6973 - emails via stored proc
            // Send an email to PRCo
            // to notify someone of the failure.
            GetObjectMgr().SendEmail_Text(Utilities.GetConfigValue("CreditCardFailureNotifyAddress", "bluebookservices@bluebookservices.com"),
                      szSubject,
                      szMsg,
                      "CreditCardInput.ascx",
                      null);

            return false;
        }

        protected string GetNameOnCard()
        {
            if (NameOnCard.Length <= 30)
            {
                return NameOnCard;
            }

            return NameOnCard.Substring(0, 30);
        }

        protected const string SQL_PRPAYMENT_INSERT = "INSERT INTO PRPayment (prpay_PaymentID, prpay_RequestID, prpay_ServiceUnitAllocationID, prpay_MembershipPurchaseID, prpay_NameOnCard, prpay_CreditCardType, prpay_CreditCardNumber, prpay_ExpirationMonth, prpay_ExpirationYear, prpay_AuthorizationCode, prpay_AVSAddr, prpay_AVSPostal, prpay_IPAddress, prpay_ItemCount, prpay_Amount, prpay_ShippingAmount, prpay_TaxAmount, prpay_Street1, prpay_Street2, prpay_City, prpay_StateID, prpay_CountryID, prpay_PostalCode, prpay_County, prpay_TaxedAmount, prpay_CreatedBy, prpay_CreatedDate, prpay_UpdatedBy, prpay_UpdatedDate, prpay_Timestamp) VALUES ({0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16},{17},{18},{19},{20},{21},{22},{23},{24},{25},{26},{27},{28},{29})";
        protected const string SQL_PRPAYMENTPRODUCT_INSERT = "INSERT INTO PRPaymentProduct (prpayprod_PaymentID, prpayprod_ProductID, prpayprod_Quantity, prpayprod_Price, prpayprod_CreatedBy, prpayprod_CreatedDate, prpayprod_UpdatedBy, prpayprod_UpdatedDate, prpayprod_Timestamp) VALUES ({0},{1},{2},{3},{4},{5},{6},{7},{8})";

        /// <summary>
        /// Creates the PRPyament records.
        /// </summary>
        /// <param name="oTran"></param>
        public void CreatePayment(IDbTransaction oTran)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prpay_PaymentID", _iPaymentID));
            oParameters.Add(new ObjectParameter("prpay_RequestID", _iRequestID));
            oParameters.Add(new ObjectParameter("prpay_ServiceUnitAllocationID", _iServiceUnitAllocationID));
            oParameters.Add(new ObjectParameter("prpay_NameOnCard", _iMembershipPurchaseID));
            oParameters.Add(new ObjectParameter("prpay_MembershipPurchaseID", NameOnCard));

            if (_TrxnStripeCharge != null)
            {
                oParameters.Add(new ObjectParameter("prpay_CreditCardType", EBB.BusinessObjects.Stripe.GetCreditCardType(_TrxnStripeCharge.PaymentMethodDetails.Card.Brand)));
                oParameters.Add(new ObjectParameter("prpay_CreditCardNumber", _TrxnStripeCharge.PaymentMethodDetails.Card.Last4));
                oParameters.Add(new ObjectParameter("prpay_ExpirationMonth", _TrxnStripeCharge.PaymentMethodDetails.Card.ExpMonth));
                oParameters.Add(new ObjectParameter("prpay_ExpirationYear", _TrxnStripeCharge.PaymentMethodDetails.Card.ExpYear));
                oParameters.Add(new ObjectParameter("prpay_AuthorizationCode", TrxnStripeCharge.Id)); 
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
            oParameters.Add(new ObjectParameter("prpay_ItemCount", CCPayment.Products.Count));
            oParameters.Add(new ObjectParameter("prpay_Amount", CCPayment.TotalPrice));
            oParameters.Add(new ObjectParameter("prpay_ShippingAmount", CCPayment.Shipping));
            oParameters.Add(new ObjectParameter("prpay_TaxAmount", CCPayment.TaxAmount));
            oParameters.Add(new ObjectParameter("prpay_Street1", Street1));
            oParameters.Add(new ObjectParameter("prpay_Street2", Street2));
            oParameters.Add(new ObjectParameter("prpay_City", City));
            oParameters.Add(new ObjectParameter("prpay_StateID", State_Value));
            oParameters.Add(new ObjectParameter("prpay_CountryID", Country_Value));
            oParameters.Add(new ObjectParameter("prpay_PostalCode", PostalCode));
            oParameters.Add(new ObjectParameter("prpay_County", County));
            oParameters.Add(new ObjectParameter("prpay_TaxedAmount", CCPayment.GetTaxedCost()));
            GetObjectMgr().AddAuditTrailParametersForInsert(oParameters, "prpay");

            string szSQL = GetObjectMgr().FormatSQL(SQL_PRPAYMENT_INSERT, oParameters);
            GetObjectMgr().ExecuteInsert("PRPayment", szSQL, oParameters, oTran);

            foreach (CreditCardProductInfo oProductInfo in CCPayment.Products)
            {
                oParameters.Clear();

                oParameters.Add(new ObjectParameter("prpayprod_PaymentID", _iPaymentID));
                oParameters.Add(new ObjectParameter("prpayprod_ProductID", oProductInfo.ProductID));
                oParameters.Add(new ObjectParameter("prpayprod_Quantity", oProductInfo.Quantity));
                oParameters.Add(new ObjectParameter("prpayprod_Price", oProductInfo.Price));
                GetObjectMgr().AddAuditTrailParametersForInsert(oParameters, "prpayprod");

                szSQL = GetObjectMgr().FormatSQL(SQL_PRPAYMENTPRODUCT_INSERT, oParameters);
                GetObjectMgr().ExecuteIdentityInsert("PRPaymentProduct", szSQL, oParameters, oTran);
            }
        }

        /// <summary>
        /// Allocates the specified number of units.
        /// </summary>
        /// <param name="oTran"></param>
        /// <returns></returns>
        public int ProcessAdditionalUnits(IDbTransaction oTran)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", CCUser.prwu_BBID));
            oParameters.Add(new ObjectParameter("PersonID", CCUser.peli_PersonID));
            oParameters.Add(new ObjectParameter("Units", CCPayment.AdditionalUnits));
            oParameters.Add(new ObjectParameter("SourceType", "O"));
            oParameters.Add(new ObjectParameter("AllocationType", "A"));
            oParameters.Add(new ObjectParameter("CRMUserID", CCUser.UserID));
            oParameters.Add(new ObjectParameter("HQID", CCUser.prwu_HQID));

            _iServiceUnitAllocationID = (int)GetDBAccess().ExecuteScalar("usp_AllocateServiceUnits",
                                                                 oParameters,
                                                                 oTran,
                                                                 CommandType.StoredProcedure);
            return _iServiceUnitAllocationID;
        }

        /// <summary>
        /// Helper method that formats the transaction details
        /// for a BBS CRM user task.
        /// </summary>
        /// <param name="szOrderMsg"></param>
        /// <returns></returns>
        public string GetTaskMsg(string szOrderMsg)
        {
            StringBuilder sbMsg = new StringBuilder();

            sbMsg.Append(szOrderMsg + Environment.NewLine);
            sbMsg.Append(GetUserInfoForTask() + Environment.NewLine);
            sbMsg.Append("Product Information" + Environment.NewLine);
            sbMsg.Append(ProductLabel.Replace("<br />", Environment.NewLine) + Environment.NewLine);
            sbMsg.Append(FormatCreditCardInfo());
            sbMsg.Append(GetAdditionalUsersList());

            return sbMsg.ToString();
        }

        /// <summary>
        /// Helper method that formats the user data for inclusion
        /// in a BBS CRM task.
        /// </summary>
        /// <returns></returns>
        protected string GetUserInfoForTask()
        {
            StringBuilder sbMsg = new StringBuilder();

            sbMsg.Append(CCUser.Name + Environment.NewLine);
            sbMsg.Append(CCUser.prwu_CompanyName + Environment.NewLine);

            if (CCUser.prwu_BBID > 0)
            {
                sbMsg.Append("BB #: " + CCUser.prwu_BBID.ToString() + Environment.NewLine);
            }
            if (CCUser.prwu_HQID > 0)
            {
                sbMsg.Append("HQ BB #: " + CCUser.prwu_HQID.ToString() + Environment.NewLine);
            }

            sbMsg.Append(Street1 + Environment.NewLine);
            sbMsg.Append(Street2 + Environment.NewLine);
            sbMsg.Append(City + " " + State_Text + ", " + PostalCode + Environment.NewLine);
            sbMsg.Append(Country_Text + Environment.NewLine);
            sbMsg.Append(CCUser.prwu_PhoneAreaCode + "-" + CCUser.prwu_PhoneNumber + Environment.NewLine);
            sbMsg.Append(CCUser.Email + Environment.NewLine);
            sbMsg.Append(CCUser.prwu_WebSite + Environment.NewLine);

            return sbMsg.ToString();
        }

        /// <summary>
        /// Returns a formated string of any additional membership users
        /// specified by the user in the membership wizard.
        /// </summary>
        /// <returns></returns>
        protected string GetAdditionalUsersList()
        {
            List<EBB.BusinessObjects.Person> lMembershipUsers = (List<EBB.BusinessObjects.Person>)Session["lMembershipUsers"];
            if (lMembershipUsers == null)
            {
                return string.Empty;
            }

            StringBuilder sbAddUsers = new StringBuilder(Environment.NewLine + "Specified Additional Users" + Environment.NewLine);
            foreach (EBB.BusinessObjects.Person oPerson in lMembershipUsers)
            {
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

            return sbAddUsers.ToString();
        }

        public int GetPRCoSpecialistID(int iSpecialistType, int iDefaultUserID, string industryType, IDbTransaction oTran)
        {
            if ((State_Value == "0") ||
                (string.IsNullOrEmpty(City)))
            {
                return iDefaultUserID;
            }
            else
            {
                return GetObjectMgr().GetPRCoSpecialistID(City, Convert.ToInt32(State_Value), iSpecialistType, industryType, oTran);
            }
        }

        public CreditCardProductInfo AddCreditCardProductInfo(int familyID, int productID, int quantity)
        {
            //decimal price = 0M;
            //string taxClass = null;
            //string productCode = null;
            //string productName = null;

            // Retrieve the report data based on the selected report type
            DataTable dtProductList = GetProductsByFamily(familyID, PageControlBaseCommon.GetCulture(WebUser));

            DataRow[] adrProduct = dtProductList.Select("prod_ProductID = '" + productID + "'");
            DataRow drProduct = adrProduct[0];

            decimal dPerReportPrice = Convert.ToDecimal(drProduct["pric_price"]);
            //int iProductID = Utilities.GetIntConfigValue("BRProductID", 50);

            //GetProductPriceData(productID, out price, out taxClass, out productCode, out productName);

            CreditCardProductInfo oCCProductInfo = new CreditCardProductInfo(); // GetCreditCardProductInfo(productID);
            oCCProductInfo.Quantity = quantity;
            oCCProductInfo.Price = Convert.ToDecimal(drProduct["pric_price"]);
            oCCProductInfo.TaxClass = "";
            oCCProductInfo.ProductCode = (string)drProduct["prod_code"];
            oCCProductInfo.ProductFamilyID = familyID;
            oCCProductInfo.ProductID = productID;
            oCCProductInfo.TotalAmount = oCCProductInfo.Quantity * oCCProductInfo.Price;
            oCCProductInfo.Name = (string)drProduct["prod_name"];

            return oCCProductInfo;
        }

        /// <summary>
        /// Helper method used to retrieve the available products for the specified product 
        /// family.
        /// </summary>
        /// <returns>Product DataTable contain: prod_Name, prod_code, prod_productfamilyid, 
        /// prod_ProductID, prod_PRDescription, pric_Price</returns>
        public DataTable GetProductsByFamily(int iProductFamilyID, string szCulture)
        {
                IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
                oDBAccess.Logger = GetLogger();

                string szPRName = null;
                string szPRDescription = null;

                switch (szCulture)
                {
                    case PageBase.ENGLISH_CULTURE:
                        szPRName = "prod_name";
                        szPRDescription = "prod_PRDescription";
                        break;
                    case PageBase.SPANISH_CULTURE:
                        szPRName = "prod_Name_ES";
                        szPRDescription = "prod_PRDescription_ES";
                    break;
                }

                // Retrieve Product List from Database
                string szSQL = String.Format(PageBase.SQL_GET_PRODUCTS_BY_FAMILY, iProductFamilyID,
                    szPRName,
                    szPRDescription);

                DataSet dsProductList;
                DataTable dtProductList;

                dsProductList = oDBAccess.ExecuteSelect(szSQL);
                dtProductList = dsProductList.Tables[0];

                return dtProductList;
        }

        protected void GetProductPriceData(int productID, out decimal price, out string taxClass)
        {
            string productCode = null;
            string productName = null;
            GetProductPriceData(productID, out price, out taxClass, out productCode, out productName);
        }

        protected const string SQL_SELECT_PRODUCT =
            @"SELECT prod_ProductID, RTRIM(prod_Code) AS prod_Code, RTRIM(prod_Name) as prod_Name, prod_PRDescription, prod_PRServiceUnits, 
                     prod_PRWebAccessLevel, TaxClass, ISNULL(StandardUnitPrice, pric_price) as StandardUnitPrice, prod_PRSequence, prod_PRWebUsers
                FROM NewProduct WITH (NOLOCK)
                     LEFT OUTER JOIN MAS_PRC.dbo.CI_Item WITH (NOLOCK) ON prod_code = ItemCode 
                     LEFT OUTER JOIN Pricing ON prod_ProductID = pric_PricingID AND pric_PricingListID=16010
               WHERE prod_ProductID=@prod_ProductID";

        protected void GetProductPriceData(int productID, out decimal price, out string taxClass, out string productCode, out string productName)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prod_ProductID", productID));

            price = 0M;
            taxClass = null;
            productName = null;

            using (IDataReader oReader = GetDBAccess().ExecuteReader(SQL_SELECT_PRODUCT, oParameters, CommandBehavior.CloseConnection, null))
            {
                if (oReader.Read())
                {
                    productCode = oReader.GetString(1);
                    productName = oReader.GetString(2);

                    if (oReader[7] != DBNull.Value)
                    {
                        price = oReader.GetDecimal(7);
                    }

                    if (oReader[6] != DBNull.Value)
                    {
                        taxClass = oReader.GetString(6);
                    }
                }
                else
                {
                    productCode = "";
                    productName = "";
                    price = 0;
                    taxClass = "";
                }
            }
        }

        /// <summary>
        /// Returns the CreditCardProductInfo object from the current 
        /// CreditCardInfo object for the specified product ID.
        /// </summary>
        /// <param name="productID"></param>
        /// <returns></returns>
        protected CreditCardProductInfo GetCreditCardProductInfo(int productID)
        {
            return GetCreditCardProductInfo(productID, false);
        }

        protected CreditCardProductInfo GetCreditCardProductInfo(int productID, bool returnNullIfNotFound)
        {
            //CreditCardPaymentInfo oCCPaymentInfo = GetCreditCardPaymentInfo();

            foreach (CreditCardProductInfo oCCProductInfo in CCPayment.Products)
            {
                if (oCCProductInfo.ProductID == productID)
                {
                    return oCCProductInfo;
                }
            }

            if (returnNullIfNotFound)
            {
                return null;
            }

            CreditCardProductInfo oCCProductInfo2 = new CreditCardProductInfo();
            oCCProductInfo2.ProductID = productID;
            CCPayment.Products.Add(oCCProductInfo2);
            return oCCProductInfo2;
        }

        public void NotifyInternalUsers(int iPaymentID,
                                                 int UnknownCityUserID,
                                                 int AccountingUserID,
                                                 string taskMessage,
                                                 string taskBody,
                                                 string taskCategory,
                                                 string taskSubcategory,
                                                 string emailSubject,
                                                 IDbTransaction oTran,
                                                 bool bCreateEmail = false)
        {
            int iPRCoSpecialistID = GetObjectMgr().GetPRCoSpecialistID(txtCity.Text,
                                                                       Convert.ToInt32(ddlState.SelectedValue),
                                                                       GeneralDataMgr.PRCO_SPECIALIST_INSIDE_SALES,
                                                                       Utilities.GetConfigValue("IndustryType"),
                                                                       oTran);

            if (iPRCoSpecialistID == 0)
            {
                iPRCoSpecialistID = UnknownCityUserID;
            }

            string szMsg = GetTaskMsg(taskMessage);
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

            if (bCreateEmail)
            {
                //Defect 6973 - emails via stored proc
                GetObjectMgr().SendEmail_Text(GetObjectMgr().GetPRCoUserEmail(iPRCoSpecialistID, oTran),
                          emailSubject,
                          szMsg,
                          "CreditCardInput.ascx",
                          oTran);

                GetObjectMgr().SendEmail_Text(GetObjectMgr().GetPRCoUserEmail(AccountingUserID, oTran),
                          emailSubject,
                          szMsg,
                          "CreditCardInput.ascx",
                          oTran);
            }
        }


        #region "Properties"

        public CreditCardPaymentInfo CCPayment
        {
            get { return _oCCPayment; }
            set { _oCCPayment = value; }
        }

        public int PaymentID
        {
            get { return _iPaymentID; }
            set { _iPaymentID = value; }
        }
       
        public string NameOnCard
        {
            get { return txtNameOnCard.Text; }
        }

        public string City
        {
            get { return txtCity.Text; }
        }

        public string State_Text
        {
            get { return ddlState.SelectedItem.Text; }
        }

        public string State_Value
        {
            get { return ddlState.SelectedValue; }
        }

        public string County
        {
            get { return txtCounty.Text; }
        }

        public string Country_Text
        {
            get { return ddlCountry.SelectedItem.Text; }
        }

        public string Country_Value
        {
            get { return ddlCountry.SelectedValue; }
        }

        public string PostalCode
        {
            get { return txtPostalCode.Text; }
        }

        public string Street1
        {
            get { return txtStreet1.Text; }
        }
        public string Street2
        {
            get { return txtStreet2.Text; }
        }

        public bool BillingCountyVisible
        {
            get { return _bBillingCountyVisible; }
            set
            {
                _bBillingCountyVisible = value;
                trBillingCounty.Visible = value;
            }
        }

        public string ProductLabel
        {
            get { return _szProductLabel; }
            set { _szProductLabel = value; }
        }

        public string cddCountry_ContextKey
        {
            get { return cddCountry.ContextKey; }
            set { cddCountry.ContextKey = value; }
        }

        public string cddState_ContextKey
        {
            get { return cddState.ContextKey; }
            set { cddState.ContextKey = value; }
        }

        public string AuthCode
        {
            get { return _szAuthCode; }
            set { _szAuthCode = value; }
        }

        public int RequestID
        {
            get { return _iRequestID; }
            set { _iRequestID = value; }
        }

        public int MembershipPurchaseID
        {
            get { return _iMembershipPurchaseID; }
            set { _iMembershipPurchaseID = value; }
        }
        #endregion
    }
}