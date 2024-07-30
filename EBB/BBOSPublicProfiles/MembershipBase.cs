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

 ClassName: MembershipBase.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Text;
using System.Threading;
using System.Web;

using PRCo.EBB.BusinessObjects;
using PRCo.EBB.Util;
using TSI.Arch;
using TSI.BusinessObjects;
using TSI.DataAccess;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web.PublicProfiles
{
    public class MembershipBase: PageBase
    {
        public const string MEMBERSHIP_PRODUCT_ID = "ProductID";
        public const string ADDITIONAL_BLUE_BOOKS = "AddBlueBooks";
        public const string ADDITIONAL_REF_GUIDE = "AddRefGuide";
        public const string ADDITIONAL_BLUEPRINTS = "AddBluePrints";

        public const string ADDITIONAL_COMPANY_UPDATES = "CompanyUpdates";
        public const string ADDITIONAL_COMPANY_UPDATES_FAX = "CompanyUpdateTypeFax";
        public const string ADDITIONAL_COMPANY_UPDATES_EMAIL = "CompanyUpdateTypeEmail";
        public const string ADDITIONAL_COMPANY_UPDATES_FAX_AC = "CompanyUpdateTypeFaxAreaCode";
        public const string ADDITIONAL_COMPANY_UPDATES_FAX_NUMBER = "CompanyUpdateTypeFaxNumber";
        public const string ADDITIONAL_COMPANY_UPDATES_EMAIL_ADDRESS = "CompanyUpdateTypeEmailAddress";

        public const string SESSION_COMPANYNAME = "pmt_txtCompanyName";
        public const string SESSION_SUBMITTERPHONE = "pmt_txtSubmitterPhone";
        public const string SESSION_STREET1 = "pmt_txtStreet1";
        public const string SESSION_STREET2 = "pmt_txtStreet2";
        public const string SESSION_COUNTRY = "pmt_txtCountry";
        public const string SESSION_CITY = "pmt_txtCity";
        public const string SESSION_STATE = "pmt_txtState";
        public const string SESSION_ZIP = "pmt_txtZip";

        protected const string SQL_SELECT_PRODUCT =
            @"SELECT prod_ProductID, RTRIM(prod_Code) AS prod_Code, RTRIM(prod_Name) as prod_Name, prod_PRDescription, prod_PRServiceUnits, 
                     prod_PRWebAccessLevel, ISNULL(TaxClass, '') TaxClass, ISNULL(StandardUnitPrice, pric_price) as StandardUnitPrice, prod_PRSequence, prod_PRWebUsers, RTRIM(ISNULL(prod_Name_ES, prod_Name)) AS prod_Name_ES, prod_PRDescription_ES
                FROM NewProduct WITH (NOLOCK)
                     LEFT OUTER JOIN MAS_PRC.dbo.CI_Item WITH (NOLOCK) ON prod_code = ItemCode 
                     LEFT OUTER JOIN Pricing ON prod_ProductID = pric_PricingID AND pric_PricingListID=16010
               WHERE prod_ProductID=@prod_ProductID";

        protected const string SQL_SELECT_PRODUCTS =
            @"SELECT prod_ProductID, RTRIM(prod_Code) AS prod_Code, RTRIM({0}) AS prod_Name, RTRIM({1}) AS prod_PRDescription, prod_PRServiceUnits, 
                     prod_PRWebAccessLevel, ISNULL(TaxClass, '') TaxClass, ISNULL(StandardUnitPrice, pric_price) as StandardUnitPrice, prod_PRSequence, prod_PRWebUsers 
                FROM NewProduct WITH (NOLOCK)
                     LEFT OUTER JOIN MAS_PRC.dbo.CI_Item WITH (NOLOCK) ON prod_code = ItemCode 
					 LEFT OUTER JOIN Pricing ON prod_ProductID = pric_PricingID AND pric_PricingListID=16010
               WHERE prod_ProductFamilyID=@prod_ProductFamilyID
                 AND prod_IndustryTypeCode LIKE @prod_IndustryTypeCode 
                 AND prod_PurchaseInBBOS = 'Y'
            ORDER BY prod_PRSequence";

        protected override void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
            
            if (!Page.ClientScript.IsClientScriptIncludeRegistered("customformshelper"))
                Page.ClientScript.RegisterClientScriptInclude("customformshelper", ResolveUrl("javascript/CustomFormsHelper.js"));
        }

        /// <summary>
        /// Creates a list of Person objects for the number of specified users.
        /// If a list already exists, it makes sure that it is contrained to 
        /// the specified number.
        /// </summary>
        /// <param name="szCacheKey"></param>
        /// <param name="ccProductInfo"></param>
        protected void ProcessLicenses(string szCacheKey, CreditCardProductInfo ccProductInfo)
        {
            List<Person> lLicensePersons = (List<Person>)Session[szCacheKey];
            if (lLicensePersons == null)
            {
                lLicensePersons = new List<Person>();
                Session[szCacheKey] = lLicensePersons;
            }

            int maxLicenseCount = ccProductInfo.Users;
            if (maxLicenseCount > 50)
                maxLicenseCount = 50;

            Person oPerson = null;
            for (int i = 0; i < maxLicenseCount; i++)
            {
                if (i < lLicensePersons.Count)
                {
                    oPerson = lLicensePersons[i];
                }
                else
                {
                    oPerson = new Person();
                    lLicensePersons.Add(oPerson);
                }
                oPerson.AccessLevel = ccProductInfo.AccessLevel;
            }

            int j = lLicensePersons.Count;
            while (j > ccProductInfo.Users)
            {
                j--;
                lLicensePersons.RemoveAt(j);
            }
        }


        /// <summary>
        /// Returns the current CreditCardPayment object used to track the current
        /// user selections.
        /// </summary>
        /// <returns></returns>
        protected CreditCardPaymentInfo GetCreditCardPaymentInfo()
        {
            if (Session["oCreditCardPayment"] == null)
            {
                throw new ApplicationUnexpectedException("oCreditCardPayment not found in session");
            }

            return (CreditCardPaymentInfo)Session["oCreditCardPayment"];
        }

        protected CreditCardProductInfo GetProductInfo(CreditCardPaymentInfo oCCPayment, int productFamilyID, int productID)
        {
            if (oCCPayment == null)
            {
                return null;
            }

            foreach (CreditCardProductInfo ccProductInfo in oCCPayment.Products)
            {
                if ((productFamilyID > 0) &&
                    (ccProductInfo.ProductFamilyID == 5))
                {
                    return ccProductInfo;
                }

                if (ccProductInfo.ProductID == productID)
                {
                    return ccProductInfo;
                }
            }

            return null;
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
            CreditCardPaymentInfo oCCPaymentInfo = GetCreditCardPaymentInfo();

            foreach (CreditCardProductInfo oCCProductInfo in oCCPaymentInfo.Products)
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
            oCCPaymentInfo.Products.Add(oCCProductInfo2);
            return oCCProductInfo2;
        }

        /// <summary>
        /// Removes the specified ProductID from the current CreditCardInfo
        /// object.
        /// </summary>
        /// <param name="productID"></param>
        protected void RemoveCreditCardProductInfo(int productID)
        {
            CreditCardPaymentInfo oCCPaymentInfo = GetCreditCardPaymentInfo();
            CreditCardProductInfo oRemove = GetCreditCardProductInfo(productID);
            if (oRemove != null)
            {
                oCCPaymentInfo.Products.Remove(oRemove);

            }
        }


        protected void GetProductPriceData(int productID, out decimal price, out string taxClass)
        {
            string productCode = null;
            string productName = null;
            GetProductPriceData(productID, out price, out taxClass, out productCode, out productName);
        }

        protected void GetProductPriceData(int productID, out decimal price, out string taxClass, out string productCode, out string productName)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prod_ProductID", productID));

            price = 0M;
            taxClass = null;
            productName = null;

            using (IDataReader oReader = GetDBAccess().ExecuteReader(SQL_SELECT_PRODUCT, oParameters, CommandBehavior.CloseConnection, null))
            {
                oReader.Read();

                productCode = oReader.GetString(1);
                if(IsSpanish())
                    productName = oReader.GetString(10); //English is 2; Spanish is 10
                else
                    productName = oReader.GetString(2); //English is 2; Spanish is 10

                if (oReader[7] != DBNull.Value)
                {
                    price = oReader.GetDecimal(7);
                }

                if (oReader[6] != DBNull.Value)
                {
                    taxClass = oReader.GetString(6);
                }
            }

        }

        protected CreditCardProductInfo AddCreditCardProductInfo(int productID, int quantity)
        {
            decimal price = 0M;
            string taxClass = null;
            string productCode = null;
            string productName = null;

            GetProductPriceData(productID, out price, out taxClass, out productCode, out productName);

            CreditCardProductInfo oCCProductInfo = GetCreditCardProductInfo(productID);
            oCCProductInfo.Quantity = quantity;
            oCCProductInfo.Price = price;
            oCCProductInfo.TaxClass = taxClass;
            oCCProductInfo.ProductCode = productCode;
            oCCProductInfo.Name = productName;

            return oCCProductInfo;
        }

        protected string GetFormattedProductList(CreditCardPaymentInfo oCCPaymentInfo, string lineBreak)
        {
            StringBuilder sbProductDescription = new StringBuilder();
            foreach (CreditCardProductInfo oProductInfo in oCCPaymentInfo.Products)
            {
                if (sbProductDescription.Length > 0)
                {
                    sbProductDescription.Append(lineBreak);
                }

                sbProductDescription.Append(oProductInfo.Quantity.ToString() + " - " + HttpUtility.HtmlDecode(oProductInfo.Name));
            }

            return sbProductDescription.ToString();
        }

        protected bool HasOverridePrice(string productCode, out decimal price, out string description)
        {
            if (string.IsNullOrEmpty(Utilities.GetConfigValue("MembershipOverridePrice" + productCode, string.Empty)))
            {
                price = 0;
                description = null;
                return false;
            }

            if (IsSpanish())
            {
                price = Utilities.GetDecimalConfigValue("MembershipOverridePrice" + productCode + "_ES");
                description = Utilities.GetConfigValue("MembershipOverrideDesc" + productCode + "_ES");
            }
            else
            {
                price = Utilities.GetDecimalConfigValue("MembershipOverridePrice" + productCode);
                description = Utilities.GetConfigValue("MembershipOverrideDesc" + productCode);
            }

            return true;
        }

        protected string _overrideProductCode = null;
        protected decimal _overridePrice = 0M;
        protected string _overrideDesription = null;

        protected string GetOverrideDescription(string productCode)
        {
            if (productCode != _overrideProductCode)
            {
                HasOverridePrice(productCode, out _overridePrice, out _overrideDesription);
                _overrideProductCode = productCode;
            }

            return _overrideDesription;
        }

        protected decimal GetOverridePrice(string productCode)
        {
            if (productCode != _overrideProductCode)
            {
                HasOverridePrice(productCode, out _overridePrice, out _overrideDesription);
                _overrideProductCode = productCode;
            }

            return _overridePrice;
        }
        protected string GetProductPrice(string productCode, decimal price)
        {
            if (GetOverridePrice(productCode) > 0)
            {
                return "<span class=\"overrideOld\">" + GetFormattedCurrency(price) + "</span> <span class=\"overrideNew\">" + GetFormattedCurrency(_overridePrice) + "</span> ";
            }
            return GetFormattedCurrency(price);
        }

        protected string GetOverrideDescriptionDisplay(string productCode)
        {
            if (string.IsNullOrEmpty(GetOverrideDescription(productCode)))
            {
                return "display:none;";
            }

            return string.Empty;
        }

        public const string DEFAULT_CULTURE = "en-us";
        public const string ENGLISH_CULTURE = "en-us";
        public const string SPANISH_CULTURE = "es-mx";

        protected override void InitializeCulture()
        {
            //Look for lang=es on querystring to force Spanish
            //else default to English
            string szCulture = DEFAULT_CULTURE;

            var lang = Request.QueryString["lang"];
            if (!string.IsNullOrEmpty(lang))
            {
                szCulture = lang;
                switch(lang)
                {
                    case SPANISH_CULTURE:
                        szCulture = SPANISH_CULTURE;
                        break;
                    default:
                        szCulture = ENGLISH_CULTURE;
                        break;
                }
            }

            Thread.CurrentThread.CurrentUICulture = new CultureInfo(szCulture);
            Thread.CurrentThread.CurrentCulture = new CultureInfo(szCulture);
        }

        /// <summary>
        /// Return en-us or es-mx
        /// </summary>
        /// <returns></returns>
        protected string GetCulture()
        {
            var lang = Request.QueryString["lang"];
            if (!string.IsNullOrEmpty(lang))
            {
                return lang;
            }
            else
                return DEFAULT_CULTURE; //english
        }

        protected bool IsSpanish()
        {
            var lang = Request.QueryString["lang"];
            if (!string.IsNullOrEmpty(lang))
            {
                if (lang == SPANISH_CULTURE)
                    return true;
            }
            return false;
        }

        protected string LangQueryString()
        {
            if (IsSpanish())
                return "?lang=" + SPANISH_CULTURE;
            else
                return "";
        }
    }
}