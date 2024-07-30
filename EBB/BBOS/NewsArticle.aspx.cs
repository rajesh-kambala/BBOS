/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2023

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: News.aspx.cs
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
using TSI.Arch;
using TSI.BusinessObjects;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This page displays a news article along with information on
    /// any related companies.  The user can also subscribe to the RSS
    /// feed from this page.
    /// </summary>
    public partial class NewsArticle : PageBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if (GetRequestParameter("ArticleID", false) == null)
            {
                Response.Redirect(PageConstants.NEWS);
            }

            SetPageTitle(Resources.Global.NewsArticle);

            Advertisement.Logger = _oLogger;
            Advertisement.WebUser = _oUser;
            Advertisement.LoadAds();

            if (!IsPostBack)
            {
                Session["ReturnURL"] = PageConstants.Format(PageConstants.NEWS_ARTICLE, GetRequestParameter("ArticleID"));
                PopulateForm();
            }

            // Add Additional javascript functions required for this page
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_FUNCTIONS2_FILE));
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_VALIDATION_FILE));
            btnBusinessReport.Attributes.Add("onclick", "return confirmSelect('" + Resources.Global.Company + "', 'cbCompanyID')");
        }

        protected const string SQL_SELECT_ARTICLE =
            @"SELECT prpbar_Name, prpbar_Abstract, prpbar_Body, prpbar_ExpirationDate 
                FROM PRPublicationArticle WITH (NOLOCK) 
               WHERE prpbar_News = 'Y'  
                 AND {1} >= prpbar_PublishDate 
                 AND prpbar_PublicationArticleID = {0} ";
        /// <summary>
        /// Display the article, prepare the RSS link, and query
        /// for the related companies.
        /// </summary>
        protected void PopulateForm()
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prpbar_PublicationArticleID", GetRequestParameter("ArticleID")));

            // When in Preview mode, we need to ignore the publish date so we 
            // can view future articles.
            if (IsPreview())
            {
                oParameters.Add(new ObjectParameter("PublishDate", DateTime.Today.AddYears(1)));
            }
            else
            {
                oParameters.Add(new ObjectParameter("PublishDate", DateTime.Today));
            }

            string szSQL = GetObjectMgr().FormatSQL(SQL_SELECT_ARTICLE, oParameters);
            IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            try
            {
                if (!oReader.Read())
                {
                    throw new ApplicationUnexpectedException("Article Not Found.");
                }

                litName.Text = GetDBAccess().GetString(oReader, "prpbar_Name");
                litBody.Text = GetDBAccess().GetString(oReader, "prpbar_Body");

                if (string.IsNullOrEmpty(litBody.Text))
                {
                    litBody.Text = GetDBAccess().GetString(oReader, "prpbar_Abstract");
                }

                if (IsPreview())
                {
                    litPreviewName.Text = litName.Text;

                    string szMore = string.Empty;

                    if (!string.IsNullOrEmpty(GetDBAccess().GetString(oReader, "prpbar_Body")))
                    {
                        szMore = " &nbsp;<a href=\"#\" class=newsmorelink>" + Resources.Global.ReadMore + " ></a>";
                    }
                    litPreviewAbstract.Text = UIUtils.TruncateString(GetDBAccess().GetString(oReader, "prpbar_Abstract"), Utilities.GetIntConfigValue("NewsItemMaxLength", 75)) + szMore;

                    pnlPreview.Visible = true;
                }

                int iSourceID = 0;
                if (GetRequestParameter("SourceID", false) != null)
                {
                    iSourceID = Convert.ToInt32(GetRequestParameter("SourceID"));
                }

                try
                {
                    GetObjectMgr().InsertPublicationArticleRead(Convert.ToInt32(GetRequestParameter("ArticleID")),
                                                                iSourceID,
                                                                GetRequestParameter("SourceEntityType", false),
                                                                GetReferer(),
                                                                GetRequestParameter("PublicationCode", false),
                                                                null);
                }
                catch (Exception eX)
                {
                    // There's nothing the end user can do about this so
                    // just log it and keep moving.
                    LogError(eX);

                    if (Utilities.GetBoolConfigValue("ThrowDevExceptions", false))
                    {
                        throw;
                    }
                }
            }
            finally
            {
                oReader.Close();
            }

            PopulateCompanyListing();

            try
            {
                if (GetRequestParameter("Preview", false) == null)
                {
                    GetObjectMgr().UpdateArticleViewCount(Convert.ToInt32(GetRequestParameter("ArticleID")));
                }
            }
            catch (Exception eX)
            {
                // There's nothing the end user can do about this so
                // just log it and keep moving.
                LogError(eX);

                if (Utilities.GetBoolConfigValue("ThrowDevExceptions", false))
                {
                    throw;
                }
            }
        }

        protected const string SQL_SELECT_COMPANIES =
            @"SELECT *, 
                     dbo.ufn_GetCustomCaptionValue('comp_PRIndustryType', comp_PRIndustryType, '{0}') As IndustryType, 
                     dbo.ufn_GetCustomCaptionValue('comp_PRType_BBOS', comp_PRType, '{0}') As CompanyType, 
                     dbo.ufn_HasNote({1}, {2}, comp_CompanyID, 'C') As HasNote,
                     dbo.ufn_HasNewClaimActivity(comp_PRHQID, '{3}') as HasNewClaimActivity, 
                     dbo.ufn_HasMeritoriousClaim(comp_PRHQID, '{4}') as HasMeritoriousClaim,
                     dbo.ufn_HasCertification(comp_PRHQID) as HasCertification,
                     dbo.ufn_HasCertification_Organic(comp_PRHQID) as HasCertification_Organic,
                     dbo.ufn_HasCertification_FoodSafety(comp_PRHQID) as HasCertification_FoodSafety
                FROM vPRBBOSCompanyList 
                     INNER JOIN PRPublicationArticleCompany WITH (NOLOCK) ON comp_CompanyID = prpbarc_CompanyID 
               WHERE prpbarc_PublicationArticleID = {2}";

        /// <summary>
        /// Queries for the related companies and displays them
        /// on the page.
        /// </summary>
        protected void PopulateCompanyListing()
        {
            ArrayList oParameters = new ArrayList();

            object[] args = {_oUser.prwu_Culture,
                             _oUser.prwu_WebUserID,
                             Convert.ToInt32(GetRequestParameter("ArticleID")),
                             DateTime.Today.AddDays(0 - Configuration.ClaimActivityNewThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss"),
                             DateTime.Today.AddDays(0 - Configuration.ClaimActivityMeritoriousThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss")};
            string szSQL = string.Format(SQL_SELECT_COMPANIES,
                                         args);
            
            szSQL += GetOrderByClause(gvCompanies);

            // Execute search and bind results to grid
            gvCompanies.DataSource = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            gvCompanies.DataBind();
            EnableBootstrapFormatting(gvCompanies);

            OptimizeViewState(gvCompanies);

            if (gvCompanies.Rows.Count == 0)
            {
                gvCompanies.Visible = false;
            }
            else
            {
                btnBusinessReport.Visible = true;
                if (!_oUser.IsInRole(PRWebUser.ROLE_USE_SERVICE_UNITS))
                {
                    btnBusinessReport.Enabled = false;
                }
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnBusinessReport_Click(object sender, EventArgs e)
        {
            SetRequestParameter("CompanyIDList", GetRequestParameter("cbCompanyID"));
            Response.Redirect(string.Format(PageConstants.BUSINESS_REPORT_CONFIRM_SELECTIONS, GetRequestParameter("ArticleID"), "PRPublicationArticle"));
        }

        protected void btnNews_Click(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.NEWS);
        }

        /// <summary>
        /// Helper method that helps with bi-directional sorting
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void GridView_Sorting(Object sender, GridViewSortEventArgs e)
        {
            SetSortingAttributes((GridView)sender, e);
            PopulateForm();
        }

        /// <summary>
        /// Adds the sort indicator to the appropriate column
        /// header.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void GridView_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            SetSortIndicator((GridView)sender, e);
        }

        protected override bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.NewsPage).HasPrivilege;
        }

        protected const string SQL_SELECT_MEMBER_LEVEL = "SELECT prpbar_MembersOnly FROM PRPublicationArticle WITH (NOLOCK) WHERE prpbar_News='Y' AND prpbar_PublicationArticleID={0}";
        protected override bool IsAuthorizedForData()
        {
            return true;
        }

        protected override string GetWebAuditTrailAssociatedID()
        {
            if (GetRequestParameter("ArticleID", false) == null)
            {
                Response.Redirect(PageConstants.NEWS);
                return "0";
            }

            return GetRequestParameter("ArticleID");
        }

        protected override string GetWebAuditTrailAssociatedType()
        {
            return "PA";
        }

        protected bool IsPreview()
        {
            if (GetRequestParameter("Preview", false) != null)
            {
                return true;
            }

            return false;
        }
    }
}
