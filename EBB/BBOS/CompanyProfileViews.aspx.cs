/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2024-2024

 The use, disclosure, reproduction, modification, transfer, or
 transmittal of  this work for any purpose in any form or by any
 means without the written  permission of Produce Reporter Co is
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CompanyProfileViews
 Description:

 Notes:

***********************************************************************
***********************************************************************/

using System;
using System.Collections;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This page contains the general search fields for searching companies
    /// including the company name, bb #, type, listing status, company phone, company fax,
    /// company email, and new listings.
    /// </summary>
    public partial class CompanyProfileViews : PageBase
    {
        /// <summary>
        /// Calls page functions required to build and process this page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
            Page.Title = Resources.Global.BlueBookService;
            ((BBOS)Master).HideOldTopMenu();

            if (!IsPostBack)
            {
                Session["ReturnURL"] = PageConstants.COMANY_PROFILE_VIEWS;
                PopulateForm();
            }
        }

        /// <summary>
        /// Check users page level authorization
        /// </summary>
        /// <returns></returns>
        override protected bool IsAuthorizedForPage()
        {
            return true;
        }

        /// <summary>
        /// Check users control/data level authorization
        /// </summary>
        /// <returns></returns>
        protected override bool IsAuthorizedForData()
        {
            return true;
        }

        protected const string SQL_PROFILE_VIEWS =
           @"SELECT TOP(@Top) 
	            viewedByHQ.comp_PRBookTradestyle, 
	            compRating.prra_RatingLine,
	            CityStateCountryShort,
	            viewedByHQ.comp_PRHQID ViewedByCompanyID, 
	            MAX(prwsat_CreatedDate) MostRecentViewedDate,
	            viewedbyHQ.comp_PRPublishLogo,
	            viewedbyHQ.comp_PRLogo
            FROM PRWebAuditTrail WITH (NOLOCK)
                   INNER JOIN Company subjectHQ WITH (NOLOCK) ON prwsat_AssociatedID = subjectHQ.Comp_CompanyId
                   INNER JOIN Company viewedByHQ WITH (NOLOCK) ON prwsat_CompanyID = viewedByHQ.Comp_CompanyId
	               INNER JOIN vPRLocation ON viewedByHQ.comp_PRListingCityID = prci_CityID 
	               LEFT OUTER JOIN vPRCurrentRating compRating ON viewedByHQ.comp_CompanyID = compRating.prra_CompanyID 
            WHERE (prwsat_PageName LIKE '%CompanyDetailsSummary.aspx'
                   OR prwsat_PageName LIKE '%CompanyView.aspx'
                   OR prwsat_PageName LIKE '%getcompany'
	               OR prwsat_PageName LIKE '%Company.aspx')
               AND prwsat_AssociatedID = @SubjectCompanyID 
               AND prwsat_AssociatedType = 'C'  
               AND viewedByHQ.comp_PRHQID <> @UserHQID
               AND viewedBYHQ.Comp_PRHQID NOT IN (100002, 204482) --exclude Travant and BBS
               AND viewedByHQ.comp_PRListingStatus IN ('L','LUV','H')
            GROUP BY viewedByHQ.comp_PRHQID, viewedByHQ.comp_PRBookTradestyle, CityStateCountryShort, compRating.prra_RatingLine, viewedbyHQ.comp_PRPublishLogo, viewedbyHQ.comp_PRLogo
            HAVING MAX(prwsat_CreatedDate) > DATEADD(day,-@Days,getdate())
            ORDER BY MAX(prwsat_CreatedDate) DESC;";

        /// <summary>
        /// Populates the form controls.
        /// </summary>
        protected void PopulateForm()
        {
            int iCompanyProfileViewsCount = Utilities.GetIntConfigValue("CompanyProfileViewsCount", 20);

            if (!HasFeature())
            {
                divNotEnabled.Visible = true;
                divPopulated.Visible = false;
                divEmpty.Visible = false;
                return;
            }
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("UserHQID", _oUser.prwu_HQID));
            oParameters.Add(new ObjectParameter("SubjectCompanyID", _oUser.prwu_BBID));
            oParameters.Add(new ObjectParameter("Top", iCompanyProfileViewsCount));
            oParameters.Add(new ObjectParameter("Days", Utilities.GetIntConfigValue("CompanyProfileViewDays", 90)));

            repRows.DataSource = GetDBAccess().ExecuteReader(SQL_PROFILE_VIEWS, oParameters, CommandBehavior.CloseConnection, null);
            repRows.DataBind();
            if(repRows.Items.Count == 0)
            {
                divPopulated.Visible = false;
                divEmpty.Visible = true;
                return;
            }

            litRollingList.Text = string.Format(Resources.Global.RollingListRecentViews, iCompanyProfileViewsCount);
        }

        private bool HasFeature()
        {
            string szPrimaryMembershipCode = GetPrimaryMembership();
            switch(szPrimaryMembershipCode)
            {
                case PROD_CODE_PREMIUM:
                case PROD_CODE_ENTERPRISE:
                    return true;
            }

            if (HasProV(Convert.ToInt32(_oUser.prwu_BBID)))
                return true;

            return false;
        }

        protected void repRows_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                string comp_PRPublishLogo = Convert.ToString(DataBinder.Eval(e.Item.DataItem, "comp_PRPublishLogo"));
                string comp_PRLogo = Convert.ToString(DataBinder.Eval(e.Item.DataItem, "comp_PRLogo"));

                Image imgLogo = (Image)e.Item.FindControl("imgLogo");
                if (!string.IsNullOrEmpty(comp_PRPublishLogo))
                {
                    imgLogo.Visible = true;
                    imgLogo.ImageUrl = string.Format(Configuration.CompanyLogoURLRawSize, comp_PRLogo);
                }

                HyperLink hlCompanyDetails = (HyperLink)e.Item.FindControl("hlCompanyDetails");
                int iCompanyID = Convert.ToInt32(DataBinder.Eval(e.Item.DataItem, "ViewedByCompanyID"));

                if (_oUser.prwu_CompanyLinksNewTab)
                    hlCompanyDetails.Target = "_blank";

                if (_oUser.IsLimitado)
                    hlCompanyDetails.NavigateUrl = string.Format("~/LimitadoCompany.aspx?CompanyID={0}", iCompanyID);
                else
                    hlCompanyDetails.NavigateUrl = string.Format("~/Company.aspx?CompanyID={0}", iCompanyID);
            }
        }

        protected const string SQL_HAS_PROV =
          @"SELECT 'x' FROM PRService WHERE prse_ServiceCode IN ('PROV-B', 'PROV-S') AND (@CompanyID=prse_HQID or @CompanyID=prse_CompanyID)";

        protected bool HasProV(int companyID)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", companyID));

            using (IDataReader oReader = GetDBAccess().ExecuteReader(SQL_HAS_PROV, oParameters, CommandBehavior.CloseConnection, null))
            {
                if (oReader.Read())
                    return true;
                else
                    return false;
            }
        }
    }
}