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

 ClassName: MembershipSelect.aspx.cs
 Description:	

 Notes:	

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
    public partial class MembershipSelect : MembershipBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            SetPageTitle(Resources.Global.SelectMembershipPackage);
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_FUNCTIONS2_FILE));
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_VALIDATION_FILE));
            btnSelect.Attributes.Add("onclick", "return confirmSelect('" + Resources.Global.Product + "', 'rbProductID')");

            if (_oUser.prwu_Culture == SPANISH_CULTURE)
                hlMembershipComparison.NavigateUrl = Utilities.GetConfigValue("MembershipComparisonFile_Spanish", "#");
            else
                hlMembershipComparison.NavigateUrl = Utilities.GetConfigValue("MembershipComparisonFile", "#");

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
            string szTemplateFile = "MembershipSelect.htm";
            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                szTemplateFile = "MembershipSelectL.htm";
                rowMembershipComparison.Visible = false; //hlMembershipComparison.Visible = false;
                litMembershipSelectMsg2.Visible = false;
            }

            using (StreamReader srTemplate = new StreamReader(Server.MapPath(UIUtils.GetTemplateURL(szTemplateFile))))
            {
                litMembershipSelect.Text = srTemplate.ReadToEnd();
            }

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("PricingListID", PRICING_LIST_ONLINE));
            oParameters.Add(new ObjectParameter("prod_ProductFamilyID", Utilities.GetIntConfigValue("MembershipProductFamily", 5)));
            oParameters.Add(new ObjectParameter("prod_IndustryTypeCode", "%," + _oUser.prwu_IndustryType + ",%"));

            string szSQL = string.Format(SQL_SELECT_MEMBERSHIP_PRODUCTS,
                                         GetObjectMgr().GetLocalizedColName("prod_Name"),
                                         GetObjectMgr().GetLocalizedColName("prod_PRDescription"));

            repMemberships.DataSource = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            repMemberships.DataBind();
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

        protected void btnSelectOnClick(object sender, EventArgs e)
        {
            SetRequestParameter(MEMBERSHIP_PRODUCT_ID, GetRequestParameter("rbProductID"));

            CreditCardPaymentInfo oCCPayment = new CreditCardPaymentInfo();

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("PricingListID", PRICING_LIST_ONLINE));
            oParameters.Add(new ObjectParameter("prod_ProductID", GetRequestParameter("rbProductID")));

            string szSQL = string.Format(SQL_SELECT_MEMBERSHIP_PRODUCT,
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
                    if (GetRequestParameter("rbProductID") != GetRequestParameter("CurrentProductID", false))
                    {
                        CreditCardProductInfo ccProductInfo = new CreditCardProductInfo();
                        ccProductInfo.ProductID = Convert.ToInt32(GetRequestParameter("rbProductID"));
                        ccProductInfo.ProductFamilyID = Utilities.GetIntConfigValue("MembershipProductFamily", 5);
                        ccProductInfo.PriceListID = PRICING_LIST_ONLINE;
                        ccProductInfo.Quantity = 1;
                        ccProductInfo.TaxClass = oReader.GetString(6);
                        ccProductInfo.Price = oReader.GetDecimal(7);
                        oCCPayment.Products.Add(ccProductInfo);
                    }
                }
            }
            finally
            {
                oReader.Close();
            }

            Session["oCreditCardPayment"] = oCCPayment;
            Session["ReturnURL"] = PageConstants.MEMBERSHIP_SELECT;
            Session["IsMembership"] = "true";

            //if ((_oUser.prwu_AccessLevel == PRWebUser.SECURITY_LEVEL_REGISTERED_USER) ||
            //    (_oUser.prwu_AccessLevel == PRWebUser.SECURITY_LEVEL_RESTRICTED_USER) ||
            //    (_oUser.prwu_AccessLevel == PRWebUser.SECURITY_LEVEL_RESTRICTED_ACCESS_PLUS))
            //{
            //    Session["NewMembership"] = "true";
            //}

            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                Response.Redirect(PageConstants.MEMBERSHIP_ADDTIONAL_LICENSES);
            }
            else
            {
                Response.Redirect(PageConstants.MEMBERSHIP_SELECT_OPTION);
            }
        }
    }
}
