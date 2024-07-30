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

 ClassName: MembershipBase.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using PRCo.EBB.BusinessObjects;
using TSI.Arch;
using TSI.BusinessObjects;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Provides the common functionality for the
    /// membership selection pages.
    /// </summary>
    public class MembershipBase : PageBase
    {
        public const string MEMBERSHIP_PRODUCT_ID = "ProductID";
        public const string ADDITIONAL_BLUE_BOOKS = "AddBlueBooks";
        public const string ADDITIONAL_REF_GUIDE = "AddRefGuide";
        public const string ADDITIONAL_BLUEPRINTS = "AddBluePrints";
        public const string ADDITIONAL_LSS = "AddLSS";
        public const string ADDITIONAL_LSS_LICENSE = "AddLSSLicenese";

        public const string ADDITIONAL_COMPANY_UPDATES = "CompanyUpdates";

        protected const string SQL_SELECT_MEMBERSHIP_PRODUCT =
            @"SELECT prod_ProductID, RTRIM(prod_Code) AS prod_Code, ISNULL({0},prod_Name) as prod_Name, ISNULL({1},prod_PRDescription) as prod_PRDescription, prod_PRWebUsers, 
                     prod_PRWebAccessLevel, ISNULL(TaxClass, '') TaxClass, StandardUnitPrice
                FROM NewProduct WITH (NOLOCK)
                     INNER JOIN MAS_PRC.dbo.CI_Item WITH (NOLOCK) ON prod_code = ItemCode 
               WHERE prod_ProductID=@prod_ProductID";

        public const string SQL_SELECT_MEMBERSHIP_PRODUCTS =
            @"SELECT prod_ProductID, RTRIM(prod_Code) AS prod_Code, RTRIM(ISNULL({0}, prod_Name)) as prod_Name, ISNULL({1}, prod_PRDescription) as prod_PRDescription, prod_PRServiceUnits, 
                     prod_PRWebAccessLevel, ISNULL(TaxClass, '') TaxClass, ISNULL(StandardUnitPrice, 0) StandardUnitPrice, prod_PRSequence
                FROM NewProduct WITH (NOLOCK)
                     LEFT OUTER JOIN MAS_PRC.dbo.CI_Item WITH (NOLOCK) ON prod_code = ItemCode 
               WHERE prod_ProductFamilyID=@prod_ProductFamilyID 
                 AND prod_IndustryTypeCode LIKE @prod_IndustryTypeCode 
                 AND prod_PurchaseInBBOS='Y' 
            ORDER BY prod_PRSequence";

        public const string SQL_SELECT_MEMBERSHIP_PRODUCTS_ITA =
            @"DECLARE @pric_PriceCode varchar(500)
                SET @pric_PriceCode = (select prcta_TradeAssociationCode from prcompanytradeassociation where prcta_Companyid = @comp_CompanyID) 
                SELECT prod_ProductID, RTRIM(prod_Code) AS prod_Code, RTRIM(ISNULL({0}, prod_Name)) as prod_Name, ISNULL({1}, prod_PRDescription) as prod_PRDescription, prod_PRServiceUnits, 
	                prod_PRWebAccessLevel,
                    'IT' AS TaxClass
	                dbo.ufn_GetBBS200MembershipPrice(@comp_CompanyID) StandardUnitPrice,
	                prod_PRSequence,
	                pric_PriceCode
                FROM NewProduct WITH (NOLOCK)
	                LEFT OUTER JOIN Pricing WITH (NOLOCK) ON prod_ProductID = pric_ProductID
                WHERE prod_ProductFamilyID=@prod_ProductFamilyID 
                    AND prod_IndustryTypeCode LIKE @prod_IndustryTypeCode 
                    AND prod_PurchaseInBBOS='Y' 
	                AND prod_Code = 'BBS200'
	                AND ISNULL(pric_PriceCode, '') = ISNULL(@pric_PriceCode, '')
                ORDER BY prod_PRSequence";

        protected const string SQL_SELECT_MEMBERSHIP_PRODUCT_ITA =
            @"DECLARE @pric_PriceCode varchar(500)
                SET @pric_PriceCode = (select prcta_TradeAssociationCode from prcompanytradeassociation where prcta_Companyid = @comp_CompanyID) 
                SELECT prod_ProductID, RTRIM(prod_Code) AS prod_Code, RTRIM(ISNULL({0}, prod_Name)) as prod_Name, ISNULL({1}, prod_PRDescription) as prod_PRDescription, prod_PRWebUsers,
	                prod_PRWebAccessLevel,
                    'IT' AS TaxClass,
	                dbo.ufn_GetBBS200MembershipPrice(@comp_CompanyID) StandardUnitPrice
                FROM NewProduct WITH (NOLOCK)
	                LEFT OUTER JOIN Pricing WITH (NOLOCK) ON prod_ProductID = pric_ProductID
                WHERE 
                    prod_ProductID=@prod_ProductID
	                AND ISNULL(pric_PriceCode, '') = ISNULL(@pric_PriceCode, '')";

        public const string SQL_SELECT_MEMBERSHIP_PRICE_ITA =
            @"SELECT dbo.ufn_GetBBS200MembershipPrice(@comp_CompanyID)";

        protected const string SQL_SELECT_PRODUCT_PRICE_OLD =
            @"SELECT dbo.ufn_GetProductPrice(prod_ProductID, @PricingListID) as pric_Price 
                FROM NewProduct WITH (NOLOCK) 
               WHERE prod_ProductID=@prod_ProductID";

        protected const string SQL_SELECT_PRODUCT_PRICE =
            @"SELECT StandardUnitPrice 
                FROM NewProduct WITH (NOLOCK) 
                     INNER JOIN MAS_PRC.dbo.CI_Item WITH (NOLOCK) ON prod_code = ItemCode 
               WHERE prod_ProductID=@prod_ProductID";


        protected const string SQL_SELECT_PRODUCT =
            @"SELECT prod_ProductID, RTRIM(prod_Code) AS prod_Code, RTRIM(prod_Name) as prod_Name, prod_PRDescription, prod_PRServiceUnits, 
                     prod_PRWebAccessLevel, TaxClass, ISNULL(StandardUnitPrice, pric_price) as StandardUnitPrice, prod_PRSequence, prod_PRWebUsers, RTRIM(ISNULL(prod_Name_ES, prod_Name)) AS prod_Name_ES, prod_PRDescription_ES
                FROM NewProduct WITH (NOLOCK)
                     LEFT OUTER JOIN MAS_PRC.dbo.CI_Item WITH (NOLOCK) ON prod_code = ItemCode 
                     LEFT OUTER JOIN Pricing ON prod_ProductID = pric_PricingID AND pric_PricingListID=16010
               WHERE prod_ProductID=@prod_ProductID";

        protected void GetProductPriceData(int productID, string culture, out decimal price, out string taxClass)
        {
            string productCode = null;
            string productName = null;
            GetProductPriceData(productID, culture, out price, out taxClass, out productCode, out productName);
        }

        protected void GetProductPriceData(int productID, string culture, out decimal price, out string taxClass, out string productCode, out string productName)
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
                if(culture == SPANISH_CULTURE)
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

        protected const string SQL_HAS_EXPRESS_UPDATES =
                  @"SELECT 'x' FROM PRService WHERE prse_ServiceCode='EXUPD' AND (@CompanyID=prse_HQID or @CompanyID=prse_CompanyID)";

        protected bool HasExpressUpdates(int companyID)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", companyID));

            using (IDataReader oReader = GetDBAccess().ExecuteReader(SQL_HAS_EXPRESS_UPDATES, oParameters, CommandBehavior.CloseConnection, null))
            {
                if (oReader.Read())
                    return true;
                else
                    return false;
            }
        }

        /// <summary>
        /// Returns the price for the specified product.  We never want to hide
        /// this on the page.
        /// </summary>
        /// <param name="szProductID"></param>
        /// <returns></returns>
        protected decimal GetProductPrice(string szProductID)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prod_ProductID", szProductID));
            return (decimal)GetDBAccess().ExecuteScalar(SQL_SELECT_PRODUCT_PRICE, oParameters);
        }

        /// <summary>
        /// Returns the CreditCardProductInfo object from the current 
        /// CreditCardInfo object for the specified product ID.
        /// </summary>
        /// <param name="szProductID"></param>
        /// <returns></returns>
        protected CreditCardProductInfo GetCreditCardProductInfo(string szProductID)
        {
            CreditCardPaymentInfo oCCPaymentInfo = GetCreditCardPaymentInfo();
            foreach (CreditCardProductInfo oCCProductInfo in oCCPaymentInfo.Products)
            {
                if (oCCProductInfo.ProductID == Convert.ToInt32(szProductID))
                {
                    return oCCProductInfo;
                }
            }

            CreditCardProductInfo oCCProductInfo2 = new CreditCardProductInfo();
            oCCProductInfo2.ProductID = Convert.ToInt32(szProductID);
            oCCPaymentInfo.Products.Add(oCCProductInfo2);
            return oCCProductInfo2;
        }

        /// <summary>
        /// Removes the specified ProductID from the current CreditCardInfo
        /// object.
        /// </summary>
        /// <param name="szProductID"></param>
        protected void RemoveCreditCardProductInfo(string szProductID)
        {
            CreditCardProductInfo oRemove = null;
            CreditCardPaymentInfo oCCPaymentInfo = GetCreditCardPaymentInfo();
            foreach (CreditCardProductInfo oCCProductInfo in oCCPaymentInfo.Products)
            {
                if (oCCProductInfo.ProductID == Convert.ToInt32(szProductID))
                {
                    oRemove = oCCProductInfo;
                }
            }

            if (oRemove != null)
            {
                oCCPaymentInfo.Products.Remove(oRemove);
            }
        }

        /// <summary>
        /// Adds the specified product information to the current CreditCaredInfo object.
        /// </summary>
        /// <param name="szProductID"></param>
        /// <param name="iQuantity"></param>
        protected void AddCreditCardProductInfo(string szProductID, int iQuantity)
        {
            AddCreditCardProductInfo(szProductID, iQuantity, GetProductPrice(szProductID), null);
        }

        /// <summary>
        /// Adds the specified product information to the current CreditCaredInfo object.
        /// </summary>
        /// <param name="szProductID"></param>
        /// <param name="iQuantity"></param>
        /// <param name="dPrice"></param>
        /// <param name="taxClass"></param>
        protected void AddCreditCardProductInfo(string szProductID, int iQuantity, decimal dPrice, string taxClass)
        {
            CreditCardProductInfo oCCProductInfo = GetCreditCardProductInfo(szProductID);
            oCCProductInfo.PriceListID = PRICING_LIST_ONLINE;
            oCCProductInfo.Quantity = iQuantity;
            oCCProductInfo.Price = dPrice;
            oCCProductInfo.TaxClass = taxClass;
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

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            RemoveMembershipParamaters();
            Response.Redirect(PageConstants.BBOS_HOME);
        }

        /// <summary>
        /// Removes all of the parameters stored in the session and
        /// elsewhere by the membership wizard.
        /// </summary>
        protected void RemoveMembershipParamaters()
        {
            Session.Remove("oCreditCardPayment");
            Session.Remove("ReturnURL");
            Session.Remove("IsMembership");
            Session.Remove("lMembershipUsers");
            Session.Remove("NewMembership");

            SortedList slAdditionalLicenses = (SortedList)Session["slAdditionalLicenses"];
            if (slAdditionalLicenses != null)
            {
                foreach (int iKey in slAdditionalLicenses.Keys)
                {
                    Session.Remove("lAdditionalUsers_" + iKey.ToString());
                }
            }
            Session.Remove("slAdditionalLicenses");

            RemoveRequestParameter("ProductID");
            RemoveRequestParameter("MembershipUsers");
            RemoveRequestParameter("MembershipAccessLevel");
            RemoveRequestParameter(ADDITIONAL_BLUE_BOOKS);
            RemoveRequestParameter(ADDITIONAL_REF_GUIDE);
            RemoveRequestParameter(ADDITIONAL_BLUEPRINTS);
            RemoveRequestParameter(ADDITIONAL_COMPANY_UPDATES);
            RemoveRequestParameter("AdditionalUserCount");
        }

        /// <summary>
        /// Creates a list of Person objects for the number of specified users.
        /// If a list already exists, it makes sure that it is contrained to 
        /// the specified number.
        /// </summary>
        /// <param name="szCacheKey"></param>
        /// <param name="iMaxUsers"></param>
        /// <param name="iAccessLevel"></param>
        protected void ProcessLicenses(string szCacheKey, int iMaxUsers, int iAccessLevel)
        {
            List<Person> lLicensePersons = (List<Person>)Session[szCacheKey];
            if (lLicensePersons == null)
            {
                lLicensePersons = new List<Person>();
                Session[szCacheKey] = lLicensePersons;
            }

            int maxLicenseCount = iMaxUsers;
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
                oPerson.AccessLevel = iAccessLevel;
            }

            int j = lLicensePersons.Count;
            while (j > iMaxUsers)
            {
                j--;
                lLicensePersons.RemoveAt(j);
            }
        }

        /// <summary>
        /// Returns a single list of Person objects representing
        /// license users.  This list is comprised of those associated
        /// with the Membership users and any additionally purchased
        /// user licenses.
        /// </summary>
        /// <returns></returns>
        protected List<Person> GetCombinedPersonList()
        {
            List<Person> lPersons = new List<Person>();
            lPersons.AddRange((List<Person>)Session["lMembershipUsers"]);

            SortedList slAdditionalLicenses = (SortedList)Session["slAdditionalLicenses"];
            if (slAdditionalLicenses != null)
            {
                foreach (int iKey in slAdditionalLicenses.Keys)
                {
                    lPersons.AddRange((List<Person>)Session["lAdditionalUsers_" + iKey.ToString()]);
                }
            }

            return lPersons;
        }

        protected override bool IsAuthorizedForPage()
        {
            return true;
        }

        protected override bool IsAuthorizedForData()
        {
            return true;
        }
    }
}
