/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2019

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: PurchaseMembership.aspx.cs
 Description:	

 Notes:	New screens for Limatado users wanting to upgrade to BBOS200 memberships.
 Simplified and streamlined process to make it as easy as possible.
 Pricing adjusted based on company's trade association status.
 Pricing from Pricing tables and not MAS

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Data;
using System.IO;
using System.Web.UI;
using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;
using TSI.DataAccess;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This page allows the user to either select a new membership (if not
    /// a member user) or upgrade their current membership.
    /// </summary>
    public partial class PurchaseMembership : MembershipBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            SetPageTitle(Resources.Global.PurchaseMembership);
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_FUNCTIONS2_FILE));
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_VALIDATION_FILE));
            //btnSelect.Attributes.Add("onclick", "return confirmSelect('" + Resources.Global.Product + "', 'rbProductID')");

            //hlMembershipComparison.NavigateUrl = Utilities.GetConfigValue("MembershipComparisonFile", "#");

            if (!IsPostBack)
            {
                Session.Remove("PurchaseMembership");
                PopulateForm();
            }
        }

        /// <summary>
        /// Populates the grid listing the different additional unit
        /// packages available.
        /// </summary>
        protected void PopulateForm()
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("comp_companyid", _oUser.prwu_BBID));
            object pric_price = GetDBAccess().ExecuteScalar(SQL_SELECT_MEMBERSHIP_PRICE_ITA, oParameters);

            string szTemplateFile = "PurchaseMembership.htm";
            string szText;
            using (StreamReader srTemplate = new StreamReader(Server.MapPath(UIUtils.GetTemplateURL(szTemplateFile))))
            {
                szText = srTemplate.ReadToEnd();
            }

            litMembershipSelect.Text = string.Format(szText, string.Format("{0:C2}", pric_price));
        }

        /// <summary>
        /// Helper method determines if the specified product
        /// code should be disabled.  This is true for current members
        /// when the code is "lower" than thier current membership.
        /// </summary>
        /// <param name="iSequence"></param>
        /// <returns></returns>
        protected string GetDisabled(int iSequence)
        {
            GetPrimaryMembership();

            if (iSequence < _iCurrentSequence)
            {
                return " disabled ";
            }

            return string.Empty;
        }

        /// <summary>
        /// Helper method determines if the specified product ID 
        /// has been previously selected.
        /// </summary>
        /// <param name="iProductID"></param>
        /// <returns></returns>
        protected string GetChecked(int iProductID)
        {
            // Look to see if we already have selected product, i.e. coming back
            // to this page from subsequent wizard pages.
            if (GetRequestParameter(MEMBERSHIP_PRODUCT_ID, false) != null)
            {
                if (iProductID.ToString() == GetRequestParameter(MEMBERSHIP_PRODUCT_ID))
                {
                    return " checked ";
                }
            }
            else
            {

                GetPrimaryMembership();
                if (iProductID == _iCurrentProductID)
                {
                    return " checked ";
                }
            }

            return string.Empty;
        }


        protected int _iCurrentProductID = -1;
        protected int _iCurrentSequence = -1;
        protected const string SQL_SELECT_PRIMARY_MEMBERSHIP =
            @"SELECT ISNULL(prod_ProductID,0), ISNULL(prod_PRSequence, 0) 
                FROM PRService WITH (NOLOCK) 
                     INNER JOIN NewProduct WITH (NOLOCK) ON prse_ServiceCode = prod_code 
               WHERE prse_HQID=@prse_HQID 
                 AND prse_Primary = 'Y'";
        /// <summary>
        /// Helper method that queries for the current user's
        /// primary membership.
        /// </summary>
        protected void GetPrimaryMembership()
        {
            if ((_iCurrentProductID > -1) ||
                (_oUser.prwu_HQID == 0))
            {
                return;
            }

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prse_HQID", _oUser.prwu_HQID));

            IDBAccess _oDBAccess = DBAccessFactory.getDBAccessProvider();
            _oDBAccess.Logger = _oLogger;

            using (IDataReader drPrimary = _oDBAccess.ExecuteReader(SQL_SELECT_PRIMARY_MEMBERSHIP, oParameters))
            {
                if (drPrimary.Read())
                {
                    _iCurrentProductID = drPrimary.GetInt32(0);
                    _iCurrentSequence = drPrimary.GetInt32(1);
                }
            }

            SetRequestParameter("CurrentProductID", _iCurrentProductID.ToString());
        }

        protected void btnLoginOnClick(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.LOGIN);
        }

        protected void btnPurchaseOnClick(object sender, EventArgs e)
        {
            string szProductID = Utilities.GetConfigValue("MembershipProductFamily", "5");
            SetRequestParameter(MEMBERSHIP_PRODUCT_ID, szProductID);

            CreditCardPaymentInfo oCCPayment = new CreditCardPaymentInfo();

            ArrayList oParameters = new ArrayList();

            oParameters.Add(new ObjectParameter("prod_ProductID", GetRequestParameter(MEMBERSHIP_PRODUCT_ID)));
            oParameters.Add(new ObjectParameter("comp_CompanyID", _oUser.prwu_BBID));

            string szSQL = string.Format(SQL_SELECT_MEMBERSHIP_PRODUCT_ITA,
                                         GetObjectMgr().GetLocalizedColName("prod_Name"),
                                         GetObjectMgr().GetLocalizedColName("prod_PRDescription"));
            IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            try
            {
                if (oReader.Read())
                {
                    if (oReader[4] != DBNull.Value)
                    {
                        SetRequestParameter("MembershipUsers", oReader.GetInt32(4).ToString());
                        ProcessLicenses("lMembershipUsers", oReader.GetInt32(4), oReader.GetInt32(5));
                    }

                    if (oReader[5] != DBNull.Value)
                    {
                        SetRequestParameter("MembershipAccessLevel", oReader.GetInt32(5).ToString());
                        SetRequestParameter("MembershipAccessLevelName", GetReferenceValue("prwu_AccessLevel", oReader.GetInt32(5).ToString()));
                    }

                    oCCPayment.RequestType = "Membership";

                    CreditCardProductInfo ccProductInfo = new CreditCardProductInfo();
                    ccProductInfo.ProductID = Convert.ToInt32(szProductID);
                    ccProductInfo.ProductFamilyID = Utilities.GetIntConfigValue("MembershipProductFamily", 5);
                    ccProductInfo.PriceListID = PRICING_LIST_ONLINE;
                    ccProductInfo.Quantity = 1;
                    ccProductInfo.TaxClass = oReader.GetString(6);
                    ccProductInfo.Price = oReader.GetDecimal(7);
                    oCCPayment.Products.Add(ccProductInfo);
                }
            }
            finally
            {
                oReader.Close();
            }

            Session["oCreditCardPayment"] = oCCPayment;
            Session["ReturnURL"] = PageConstants.PURCHASE_MEMBERSHIP;
            Session["IsMembership"] = "true";

            //if ((_oUser.prwu_AccessLevel == PRWebUser.SECURITY_LEVEL_REGISTERED_USER) ||
            //    (_oUser.prwu_AccessLevel == PRWebUser.SECURITY_LEVEL_RESTRICTED_USER) ||
            //    (_oUser.prwu_AccessLevel == PRWebUser.SECURITY_LEVEL_RESTRICTED_ACCESS_PLUS))
            //{
            //    Session["NewMembership"] = "true";
            //}

            //Set flag so MembershipUsers screen knows to process this as ITA with adjusted pricing levels

            Response.Redirect(PageConstants.MEMBERSHIP_USERS);
        }
    }
}
