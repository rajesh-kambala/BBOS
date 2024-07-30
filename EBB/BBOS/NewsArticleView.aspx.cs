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

 ClassName: NewsArticleview.aspx.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Data;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This page displays a news article along with information on
    /// any related companies.  The user can also subscribe to the RSS
    /// feed from this page.
    /// </summary>
    public partial class NewsArticleView : PageBase
    {
        protected string _szArticleID;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            SetPageTitle(Resources.Global.NewsArticle);

            //Configure WordPress article control
            ArticleID = GetRequestParameter("ArticleID", true);

            //Defect 4666 - redirect to BluePrintsView.aspx if article has blueprintedition defined
            if(HasBlueprintEdition(ArticleID))
            {
                string strURL = string.Format(PageConstants.BLUEPRINTS_VIEW, ArticleID);
                Response.Redirect(strURL);
            }
            ucWordPressArticle.ArticleID = ArticleID;
            ucWordPressArticle.BaseUrl = Request.RawUrl.Substring(0, Request.RawUrl.IndexOf("?"));
            ucWordPressArticle.ArticleType = WordPressArticle.ArticleEnum.News; //WordPressArticle.ArticleEnum.BluePrint;
            ucWordPressArticle.ShowDate = true;

            string szPageNum = GetRequestParameter("p", false);
            if (!string.IsNullOrEmpty(szPageNum))
                ucWordPressArticle.PageNum = Convert.ToInt32(szPageNum);

            if (!IsPostBack)
            {
                Session["ReturnURL"] = PageConstants.Format(PageConstants.NEWS_ARTICLE_VIEW, GetRequestParameter("ArticleID"));
                PopulateForm();
            }

            PopulateCompanyListing();

            Advertisement.Logger = _oLogger;
            Advertisement.WebUser = _oUser;
            Advertisement.LoadAds();

            //Flag the WordPress article as read
            string szEntityType = "WPPublicationArticle";
            GetObjectMgr().InsertPublicationArticleRead(Convert.ToInt32(_szArticleID),
                                            0,
                                            szEntityType,
                                            GetReferer(),
                                            PublicationArticles.PUBLICATIONCODE_WPNEWS,
                                            null);

            // Add Additional javascript functions required for this page
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_FUNCTIONS2_FILE));
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_VALIDATION_FILE));
            btnBusinessReport.Attributes.Add("onclick", "return confirmSelect('" + Resources.Global.Company + "', 'cbCompanyID')");
        }

        /// <summary>
        /// Display the article, prepare the RSS link, and query
        /// for the related companies.
        /// </summary>
        protected void PopulateForm()
        {
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

        public string ArticleID
        {
            get { return _szArticleID; }
            set { _szArticleID = value; }
        }

        /*
            {0}=prwu_Culture,
            {1}=prwu_WebUserID,
            {2}=GetRequestParameter("ArticleID")),
            {3}=DateTime.Today.AddDays(0 - Configuration.ClaimActivityNewThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss"),
            {4}=DateTime.Today.AddDays(0 - Configuration.ClaimActivityMeritoriousThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss")};
            {5}=wp_posts
            {6}=wp_postmeta
         */
        protected const string SQL_SELECT_COMPANIES_WP =
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
                     WHERE comp_companyid IN (SELECT value FROM {6} CROSS APPLY CRM.dbo.Tokenize(meta_value, ',') WHERE post_id={2} AND meta_key='associated-companies')";

        /// <summary>
        /// Queries for the related companies and displays them
        /// on the page.
        /// </summary>
        protected void PopulateCompanyListing()
        {
            ArrayList oParameters = new ArrayList();

            object[] args;

            if (_oUser.prwu_IndustryType == "L")
            {
                args = new object[]{_oUser.prwu_Culture,
                             _oUser.prwu_WebUserID,
                             Convert.ToInt32(GetRequestParameter("ArticleID")),
                             DateTime.Today.AddDays(0 - Configuration.ClaimActivityNewThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss"),
                             DateTime.Today.AddDays(0 - Configuration.ClaimActivityMeritoriousThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss"),
                             Configuration.WordPressLumber_posts,
                             Configuration.WordPressLumber_postmeta};
            }
            else
            {
                args = new object[]{_oUser.prwu_Culture,
                             _oUser.prwu_WebUserID,
                             Convert.ToInt32(GetRequestParameter("ArticleID")),
                             DateTime.Today.AddDays(0 - Configuration.ClaimActivityNewThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss"),
                             DateTime.Today.AddDays(0 - Configuration.ClaimActivityMeritoriousThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss"),
                             Configuration.WordPressProduce_posts,
                             Configuration.WordPressProduce_postmeta};
        }

            string szSQL = string.Format(SQL_SELECT_COMPANIES_WP, args);
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

        protected const string SQL_POST_DETAILS =
            @"SELECT * FROM dbo.ufn_GetWordPressPostDetails4({0},'{1}') wpd";

        private bool HasBlueprintEdition(string ArticleID)
        {
            string szSQL = string.Format(SQL_POST_DETAILS,ArticleID, _oUser.prwu_IndustryType);
            using (IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection))
            {
                while (oReader.Read())
                {
                    if (oReader["BlueprintEdition"] != System.DBNull.Value && (string)oReader["BlueprintEdition"] != PageControlBaseCommon.EMPTY_BLUEPRINT_EDITION_TEXT)
                        return true;
                }
            }

            return false;
        }
    }
}
