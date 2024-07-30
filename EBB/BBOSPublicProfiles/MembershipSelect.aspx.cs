/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2014-2023

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: MembershipPurchase.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Data;
using System.Collections;

using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web.PublicProfiles
{
    public partial class MembershipSelect : MembershipBase
    {
        protected const string SQL_SELECT_BR_PRICE =
            @" SELECT pric_price 
                 FROM NewProduct 
                      INNER JOIN Pricing ON prod_ProductID = pric_ProductID
                WHERE pric_PricingListID = 16010
                  AND prod_ProductID=@prod_ProductID";

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            Master.SetFormClass("member step-1 select-membership");

            if (!IsPostBack)
            {
                PopulateForm();
            }

            btnCancel.NavigateUrl = GetMarketingSiteURL() + "/join-today/";
        }

        protected void PopulateForm()
        {
            int iMembershipProductFamily = 5;

            // If we have a CreditCardPayment object and it 
            // has been processed, reset everything.
            if ((Session["oCreditCardPayment"] != null) &&
                (!string.IsNullOrEmpty(((CreditCardPaymentInfo)Session["oCreditCardPayment"]).AuthorizationCode)))
            {
                Session["oCreditCardPayment"] = null;
            }

            CreditCardProductInfo ccProductInfo = GetProductInfo((CreditCardPaymentInfo)Session["oCreditCardPayment"], Utilities.GetIntConfigValue("MembershipProductFamily", iMembershipProductFamily), 0);
            if (ccProductInfo != null)
            {
                productID.Value = ccProductInfo.ProductID.ToString();
            }

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prod_IndustryTypeCode", "%," + GetIndustryType() + ",%"));
            oParameters.Add(new ObjectParameter("prod_ProductFamilyID", Utilities.GetIntConfigValue("MembershipProductFamily", iMembershipProductFamily)));

            string szSQL;
            if (IsSpanish())
                szSQL = string.Format(SQL_SELECT_PRODUCTS, "prod_Name_ES", "prod_PRDescription_ES");
            else
                szSQL = string.Format(SQL_SELECT_PRODUCTS, "prod_Name", "prod_PRDescription");

            repMemberships.DataSource = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            repMemberships.DataBind();

            if (GetIndustryType() == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                LumberMsg.Visible = true;
            }
        }

        protected void SaveMembership()
        {
            CreditCardPaymentInfo oCCPayment = null;
            if (Session["oCreditCardPayment"] == null)
            {
                oCCPayment = new CreditCardPaymentInfo();
                Session["oCreditCardPayment"] = oCCPayment;
            }
            else
            {
                oCCPayment = (CreditCardPaymentInfo)Session["oCreditCardPayment"];
            }

            CreditCardProductInfo ccProductInfo = GetProductInfo(oCCPayment, Utilities.GetIntConfigValue("MembershipProductFamily", 5), 0);
            if ((ccProductInfo != null) &&
                (ccProductInfo.ProductID.ToString() != GetRequestParameter("rbProductID")))
            {
                oCCPayment.Products.Remove(ccProductInfo);
                ccProductInfo = null;
            }

            if (ccProductInfo == null)
            {
                ArrayList oParameters = new ArrayList();
                oParameters.Add(new ObjectParameter("prod_ProductID", Utilities.GetIntConfigValue("MemberBusinessReportProductID",47)));
                int brPrice = Convert.ToInt32(GetDBAccess().ExecuteScalar(SQL_SELECT_BR_PRICE, oParameters));

                oParameters.Clear();
                oParameters.Add(new ObjectParameter("prod_ProductID", GetRequestParameter("rbProductID")));

                using (IDataReader oReader = GetDBAccess().ExecuteReader(SQL_SELECT_PRODUCT, oParameters, CommandBehavior.CloseConnection, null))
                {
                    oReader.Read();

                    oCCPayment.RequestType = "Membership";
                    ccProductInfo = GetCreditCardProductInfo(Convert.ToInt32(GetRequestParameter("rbProductID")));
                    ccProductInfo.ProductFamilyID = Utilities.GetIntConfigValue("MembershipProductFamily", 5);
                    ccProductInfo.Quantity = 1;
                    ccProductInfo.TaxClass = oReader.GetString(6);
                    ccProductInfo.Price = oReader.GetDecimal(7);

                    ccProductInfo.FormattedPrice = GetProductPrice(oReader.GetString(1), ccProductInfo.Price);
                    if (GetOverridePrice(oReader.GetString(1)) > 0)
                    {
                        ccProductInfo.Price = _overridePrice;
                    }
                    
                    ccProductInfo.BusinessReports = oReader.GetInt32(4) / brPrice;

                    if (oReader[9] != DBNull.Value)
                    {
                        ccProductInfo.Users = oReader.GetInt32(9);
                        ccProductInfo.AccessLevel = oReader.GetInt32(5);
                        ccProductInfo.AccessLevelDesc = GetReferenceValue("prwu_AccessLevel", oReader.GetInt32(5).ToString());
                        ProcessLicenses("lMembershipUsers", ccProductInfo);
                    }

                    if(GetCulture() == SPANISH_CULTURE)
                        SetRequestParameter("MembershipName", oReader.GetString(10)); //English is 2; Spanish is 10
                    else
                        SetRequestParameter("MembershipName", oReader.GetString(2)); //English is 2; Spanish is 10

                    SetRequestParameter("MembershipProductID", oReader.GetInt32(0).ToString());
                }
            }
        }

        private string GetQueryString()
        {
            string szQry = LangQueryString();
            return szQry;
        }

        protected void btnSelectOnClick(object sender, EventArgs e)
        {
            if (GetRequestParameter("rbProductID", false) == null)
            {
                Response.Redirect("MembershipSelect.aspx" + GetQueryString());
                return;
            }

            SaveMembership();

            if (Utilities.GetConfigValue("IndustryType") == "P")
            {
                Response.Redirect("MembershipOptions.aspx" + GetQueryString());
            }
            else
            {
                Response.Redirect("MembershipUsers.aspx" + GetQueryString());
            }
        }

        //protected void btnCancelOnClick(object sender, EventArgs e)
        //{
        //    Session.Remove("oCreditCardPayment");
        //    Response.Redirect(GetMarketingSiteURL() + "/join-today/");
        //}
    }
}