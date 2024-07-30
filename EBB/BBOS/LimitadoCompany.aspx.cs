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

 ClassName: LimitadoCompany
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using PRCo.EBB.BusinessObjects;
using System;
using System.Collections;
using System.Data;
using TSI.BusinessObjects;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Displays the basic company data and listing.
    /// </summary>
    public partial class LimitadoCompany : CompanyDetailsBase
    {
        protected const string SQL_SELECT_COMPANY =
            @"SELECT TOP 1 *
                FROM vPRBBOSCompanyLocalized
               WHERE comp_CompanyID=@comp_CompanyID
               AND prwu_WebUserID = @prwu_WebUserID ";

        public const string SQL_SELECT_AUS_LIST_BY_WEBUSERID =
            @"SELECT prwucl_WebUserListID, prwucl_Name, COUNT(prwuld_WebUserListDetailID) AS CompanyCount 
                FROM PRWebUserList WITH(NOLOCK)
	            LEFT OUTER JOIN PRWebUserListDetail WITH (NOLOCK) ON prwucl_WebUserListID = prwuld_WebUserListID 
                WHERE prwucl_TypeCode='AUS'
	            AND prwucl_WebUserID={0}
                GROUP BY prwucl_WebUserListID, prwucl_Name";

        protected int _prwucl_WebUserListID;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            // Set page title, sub-title
            SetPageTitle(Resources.Global.CompanyDetails, Resources.Global.ListingSummary, true);

            _prwucl_WebUserListID = GetAUSList().WebUserListID;

            if (!IsPostBack)
            {
                hidCompanyID.Text = GetRequestParameter("CompanyID", true, true);
                Session["ReturnURL"] = PageConstants.Format(PageConstants.COMPANY_DETAILS_SUMMARY, hidCompanyID.Text);

                PopulateForm();
                ApplySecurity();
            }

            RedirectToHomeIfCompanyMissing(hidCompanyID.Text);

            //Set user controls
            ucCompanyDetails.WebUser = _oUser;
            ucCompanyDetails.companyID = hidCompanyID.Text;

            ucCompanyListing.WebUser = _oUser;
            ucCompanyListing.companyID = hidCompanyID.Text;

            ucCompanyDetailsHeader.WebUser = _oUser;

            ucClassifications.WebUser = _oUser;
            ucClassifications.CompanyID = hidCompanyID.Text;

            ucCommodities.WebUser = _oUser;
            ucCommodities.IndustryType = hidIndustryType.Text;
            ucCommodities.CompanyID = hidCompanyID.Text;
        }

        /// <summary>
        /// Populates the form controls for the specified
        /// company
        /// </summary>
        protected void PopulateForm()
        {
            int iRatingID = 0;

            ArrayList oParameters = new ArrayList();

            oParameters.Add(new ObjectParameter("comp_CompanyID", hidCompanyID.Text));
            oParameters.Add(new ObjectParameter("prwu_WebUserID", _oUser.prwu_WebUserID));

            using (IDataReader oReader = GetDBAccess().ExecuteReader(SQL_SELECT_COMPANY, oParameters, CommandBehavior.CloseConnection, null))
            {
                oReader.Read();

                hidIndustryType.Text = GetDBAccess().GetString(oReader, "comp_PRIndustryType");
                iRatingID = GetDBAccess().GetInt32(oReader, "prra_RatingID");

                if (hidIndustryType.Text != GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                {
                    hidRatingID.Text = iRatingID.ToString();
                }
            }

            PopulateButtons();
        }

        private void PopulateButtons()
        {
            btnPromo1.Text = Resources.Global.btnPromoBecomeAMember;
            btnPromo2.Text = Resources.Global.btnPromoGetBusinessReport;
            btnPromo3.Text = Resources.Global.btnPromoGetHelpCollecting;

            if (!GeneralDataMgr.PRWebUserListDetailRecordExists(_prwucl_WebUserListID, Convert.ToInt32(hidCompanyID.Text), null))
                btnAlertRemove.Visible = false;
            else
                btnAlertAdd.Visible = false;
        }

        /// <summary>
        /// Apply security to the various screen components
        /// based on the current user's access level and role.
        /// </summary>
        protected void ApplySecurity()
        {
        }

        protected override string GetCompanyID()
        {
            if (IsPostBack)
            {
                return hidCompanyID.Text;
            }
            else
            {
                return GetRequestParameter("CompanyID");
            }
        }

        protected override CompanyDetailsHeader GetCompanyDetailsHeader()
        {
            return ucCompanyDetailsHeader;
        }

        public override bool EnableJSClientIDTranslation()
        {
            return true;
        }

        override protected bool IsAuthorizedForPage()
        {
            return _oUser.IsLimitado || _oUser.HasPrivilege(SecurityMgr.Privilege.CompanyDetailsListingPage).Enabled;
        }

        protected void hlViewMap_Click(object sender, EventArgs e)
        {
            Response.Redirect(Request.RawUrl);
        }

        protected void btnPromo1_Click(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.PURCHASE_MEMBERSHIP);
        }

        protected void btnPromo2_Click(object sender, EventArgs e)
        {
            SetRequestParameter("CompanyIDList", hidCompanyID.Text);
            Response.Redirect(string.Format(PageConstants.BUSINESS_REPORT_CONFIRM_SELECTIONS, hidCompanyID.Text, "Company"));
        }

        protected void btnPromo3_Click(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.PURCHASE_MEMBERSHIP);
        }


        private class AUSList
        {
            public int WebUserListID;
            public string Name;
            public int CompanyCount;
        }

        private AUSList GetAUSList()
        {
            AUSList oAUSList = new AUSList();
            string szSQL = string.Format(SQL_SELECT_AUS_LIST_BY_WEBUSERID, _oUser.prwu_WebUserID);
            using (IDataReader dr = GetDBAccess().ExecuteReader(szSQL))
            {
                if (dr.Read())
                {
                    oAUSList.WebUserListID = (int)dr["prwucl_WebUserListID"];
                    oAUSList.Name = (string)dr["prwucl_Name"];
                    oAUSList.CompanyCount = (int)dr["CompanyCount"];
                }
            }

            return oAUSList;
        }

        protected void btnAlertAdd_Click(object sender, EventArgs e)
        {
            int iCompanyID = Convert.ToInt32(hidCompanyID.Text);

            IDbTransaction oTran = GetObjectMgr().BeginTransaction();
            try
            {
                if (!GeneralDataMgr.PRWebUserListDetailRecordExists(_prwucl_WebUserListID, iCompanyID, oTran))
                {
                    // Insert new PRWebUserListDetail record for this company and list
                    GetObjectMgr().AddPRWebUserListDetail(_prwucl_WebUserListID, iCompanyID, _prwucl_WebUserListID, oTran);
                    GetObjectMgr().UpdatePRWebUserList(_prwucl_WebUserListID, oTran);
                }

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

            btnAlertAdd.Visible = false;
            btnAlertRemove.Visible = true;

            Response.Redirect(Request.RawUrl);
        }

        protected void btnAlertRemove_Click(object sender, EventArgs e)
        {
            int iCompanyID = Convert.ToInt32(hidCompanyID.Text);

            IDbTransaction oTran = GetObjectMgr().BeginTransaction();
            try
            {
                if (GeneralDataMgr.PRWebUserListDetailRecordExists(_prwucl_WebUserListID, iCompanyID, oTran))
                {
                    // Remove PRWebUserDetail Record
                    GetObjectMgr().DeletePRWebUserListDetail(_prwucl_WebUserListID, iCompanyID, oTran);
                    GetObjectMgr().UpdatePRWebUserList(_prwucl_WebUserListID, oTran);
                }

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

            btnAlertAdd.Visible = true;
            btnAlertRemove.Visible = false;

            Response.Redirect(Request.RawUrl);
        }

        protected void btnManageAlerts_Click(object sender, EventArgs e)
        {
            SetReturnURL(Request.RawUrl);
            Response.Redirect(PageConstants.Format(PageConstants.USER_LIST, _prwucl_WebUserListID)); 
        }
    }
}
