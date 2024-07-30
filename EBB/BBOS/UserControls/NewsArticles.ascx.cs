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

 ClassName: NewsArticles
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using TSI.Utils;
using System.Data;
using System.Web.UI.WebControls;
using System.Web.UI;
using System.IO;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;
using System.Text.RegularExpressions;
using PRCo.EBB.BusinessObjects;
using System.Web.UI.HtmlControls;
using System.Web;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// User control that displays the company header, or "banner" information
    /// on each of the company detail pages.
    /// 
    /// NOTE: This user control is also being used to display the company header information
    /// on each of the edit my company wizard pages.
    /// </summary>
    public partial class NewsArticles : UserControlBase
    {
        //protected string _szLocation = null;
        protected string _szCompanyID;
        protected string _szTitle = Resources.Global.NewsArticles; //"News/Articles"
        protected string _szSQL;
        protected NewsType _eNewsType;

        protected bool _bDisplayStatusColumn = false;
        protected bool _bDisplaySourceColumn = false;
        protected bool _bDisplayFeedColumn = false;
        protected bool _bDisplayCategoryColumn = false;
        protected bool _bDisplayViewAllButton = true;
        protected bool _bIsAbstract = true; //determines if > 99 chars is replaced by ...
        protected bool _bAllowSorting = false;
        protected bool _bDisplayRecordCounts = false;
        protected bool _bShowHyphensAfterDate = true;
        protected bool _bDisplayAbstract = true;

        protected int _iNewsArticlesDisplayed = 2;
        protected int _iMaxMonthsOld = 0;
        protected string _szEmptyTableRowText = Resources.Global.NoArticlesFound;
        protected string _szPublishArticleColName = ""; //pren_Name or prpbar_Name but change as needed
        protected string _szPublishDateTimeColName = ""; //prpbar_PublishDate or pren_PublishDateTime but change as needed
        protected string _szSummaryNameSingular = Resources.Global.Article; 
        protected string _szSummaryNamePlural = Resources.Global.Articles;

        protected int _iNewsCount = 0;

        private bool _bCondensed = false;

        public const int MAX_ARTICLES = 1000000;
        public bool hideAbstract = false;

        public enum NewsType
        {
            GENERAL_NEWS_SUMMARY = 1,
            GENERAL_NEWS_COMPANY_DETAILS_NEWS = 2
        }

        public enum NewsFormatType
        {
            NEWS_FORMAT_ORIG = 1,
            NEWS_FORMAT_BBOS9 = 2
        }

        protected NewsFormatType _eFormat = NewsFormatType.NEWS_FORMAT_ORIG; //default to original style

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if (!Page.IsPostBack)
            {
                SetVisibility();
            }
            
            divViewAll.Visible = DisplayViewAllButton;
        }

        public string companyID
        {
            set
            {
                _szCompanyID = value;
                //PopulateNewsArticles(WebUser);
            }
            get { return _szCompanyID; }
        }

        public int NewsCount
        {
            set
            {
                _iNewsCount = value;
            }
            get { return _iNewsCount; }
        }

        public string Title
        {
            set
            {
                _szTitle = value;
                litTitle.Text = value;
            }
            get { return _szTitle; }
        }

        public string SQL
        {
            set
            {
                _szSQL = value;
            }
            get { return _szSQL; }
        }


        public string EmptyTableRowText
        {
            set { _szEmptyTableRowText = value; }
            get { return _szEmptyTableRowText; }
        }

        public string PublishDateTimeColName
        {
            set { _szPublishDateTimeColName = value; }
            get { return _szPublishDateTimeColName; }
        }

        public string PublishArticleColName
        {
            set { _szPublishArticleColName = value; }
            get { return _szPublishArticleColName; }
        }

        public string SummaryNameSingular
        {
            set { _szSummaryNameSingular = value; }
            get { return _szSummaryNameSingular ; }
        }

        public string SummaryNamePlural
        {
            set { _szSummaryNamePlural = value; }
            get { return _szSummaryNamePlural; }
        }

        public NewsType Style
        {
            get { return _eNewsType; }
            set
            {
                _eNewsType = value;

                if (!Page.IsPostBack)
                {
                }

                string SQLPart1_WPNewsCombined;
                string SQLPart1_SHORT_WPNewsCombined;

                if (WebUser.prwu_IndustryType == "L")
                {
                    //New news formats Defect 4584
                    SQLPart1_WPNewsCombined = string.Format(SQL_SELECT_NEWS_WORDPRESS_COMBINED, string.Empty, WebUser.UserID, companyID, WebUser.prwu_Culture, WebUser.prwu_IndustryType, Configuration.WordPressLumber_posts, Configuration.WordPressLumber_postmeta);
                    SQLPart1_SHORT_WPNewsCombined = string.Format(SQL_SELECT_NEWS_WORDPRESS_SHORT_COMBINED, string.Empty, WebUser.UserID, companyID, WebUser.prwu_Culture, WebUser.prwu_IndustryType, Configuration.WordPressLumber_posts, Configuration.WordPressLumber_postmeta);
                }
                else
                {
                    //New news formats Defect 4584
                    SQLPart1_WPNewsCombined = string.Format(SQL_SELECT_NEWS_WORDPRESS_COMBINED, string.Empty, WebUser.UserID, companyID, WebUser.prwu_Culture, WebUser.prwu_IndustryType, Configuration.WordPressProduce_posts, Configuration.WordPressProduce_postmeta);
                    SQLPart1_SHORT_WPNewsCombined = string.Format(SQL_SELECT_NEWS_WORDPRESS_SHORT_COMBINED, string.Empty, WebUser.UserID, companyID, WebUser.prwu_Culture, WebUser.prwu_IndustryType, Configuration.WordPressProduce_posts, Configuration.WordPressProduce_postmeta);
                }

                string szSQL;

                switch (value)
                {
                    case NewsType.GENERAL_NEWS_SUMMARY:
                        PublishDateTimeColName = "prpbar_PublishDate";
                        PublishArticleColName = "prpbar_Name";

                        szSQL = string.Format("SELECT * FROM ({0}) T2 ORDER BY T2.SortPriority, T2.prpbar_PublishDate DESC", SQLPart1_SHORT_WPNewsCombined);
                        if (WebUser.prwu_IndustryType == "L")
                            szSQL = szSQL.Replace(PublicationArticles.PUBLICATIONCODE_WPBA, PublicationArticles.PUBLICATIONCODE_WPNEWS);

                        SQL = szSQL;

                        EmptyTableRowText = GetNoResultsFoundMsg(Resources.Global.News);
                        
                        break;

                    case NewsType.GENERAL_NEWS_COMPANY_DETAILS_NEWS:
                        PublishDateTimeColName = "prpbar_PublishDate";
                        PublishArticleColName = "prpbar_Name";

                        szSQL = string.Format("{0} ORDER BY prpbar_PublishDate DESC", SQLPart1_WPNewsCombined);
                        if (WebUser.prwu_IndustryType == "L")
                            szSQL = szSQL.Replace(PublicationArticles.PUBLICATIONCODE_WPBA, PublicationArticles.PUBLICATIONCODE_WPNEWS);

                        SQL = szSQL;

                        NewsArticlesDisplayed = MAX_ARTICLES;

                        EmptyTableRowText = Resources.Global.NoBBOSNewsArticlesFound; // "No BBOS News Articles were found.";
                        
                        break;
                }
            }
        }

        public int NewsArticlesDisplayed
        {
            set { _iNewsArticlesDisplayed = value; }
            get { return _iNewsArticlesDisplayed; }
        }

        public int MaxMonthsOld
        {
            set { _iMaxMonthsOld = value; }
            get { return _iMaxMonthsOld; }
        }

        public bool DisplaySourceColumn
        {
            set
            {
                _bDisplaySourceColumn = value;
            }
            get { return _bDisplaySourceColumn; }
        }

        public bool DisplayFeedColumn
        {
            set
            {
                _bDisplayFeedColumn = value;
            }
            get { return _bDisplayFeedColumn; }
        }

        public bool DisplayCategoryColumn
        {
            set
            {
                _bDisplayCategoryColumn = value;
            }
            get { return _bDisplayCategoryColumn; }
        }

        public bool DisplayStatusColumn
        {
            set
            {
                _bDisplayStatusColumn = value;
            }
            get { return _bDisplayStatusColumn; }
        }

        public bool DisplayViewAllButton
        {
            set
            {
                _bDisplayViewAllButton = value;
                divViewAll.Visible = value;
            }
            get { return _bDisplayViewAllButton; }
        }

        public bool DisplayAbstract
        {
            set
            {
                _bDisplayAbstract = value;
                divViewAll.Visible = value;
            }
            get { return _bDisplayAbstract; }
        }

        public bool DisplayRecordCounts
        {
            set
            {
                _bDisplayRecordCounts = value;
            }
            get
            {
                return _bDisplayRecordCounts;
            }
        }

        public bool ShowHyphensAfterDate
        {
            set
            {
                _bShowHyphensAfterDate = value;
            }
            get
            {
                return _bShowHyphensAfterDate;
            }
        }

        public bool IsAbstract
        {
            set
            {
                _bIsAbstract = value;
            }
            get { return _bIsAbstract; }
        }

        public bool AllowSorting
        {
            set
            {
                _bAllowSorting = value;
            }
            get { return _bAllowSorting; }
        }

        public bool Condensed
        {
            set { _bCondensed = value; }
            get { return _bCondensed; }
        }

        public NewsFormatType Format
        {
            set
            {
                _eFormat = value;
                SetVisibility();
            }
            get { return _eFormat; }
        }

        private void SetVisibility()
        {
            switch (Format)
            {
                case NewsFormatType.NEWS_FORMAT_BBOS9: 
                    pNews1.Visible = false;
                    pNews2.Visible = true;
                    break;

                default:
                    pNews1.Visible = true;
                    pNews2.Visible = false;
                    break;
            }
        }

        protected string SQL_SELECT_NEWS_WORDPRESS_COMBINED =
            @"SELECT 
                post_status,
                post_type,
                CAST(ID as int) AS prpbar_PublicationArticleID, 
                NULL AS pren_ExternalNewsID,

				CASE 
					WHEN bpe.post_id IS NULL THEN 'WPBA'
					ELSE 'WPNEWS'
				END AS prpbar_PublicationCode,
				CASE 
					WHEN bpe.post_id IS NULL THEN 'WPBA'
					ELSE 'WPNEWS'
				END AS prpbar_CategoryCode_WP,
                wpd.CategoryCode as prpbar_CategoryCode,

		        post_date AS prpbar_PublishDate,
		        CASE WHEN post_content LIKE '<p>%' THEN 
				    SUBSTRING(post_content, 0, CHARINDEX('</p>', post_content)+4)
				ELSE 
					SUBSTRING(post_content, 0, PATINDEX('%' + CHAR(13) + CHAR(10) + '%', post_content))
				END AS prpbar_Abstract,
		        post_title as prpbar_Name,
				CASE
                    WHEN bpe.post_id IS NULL THEN dbo.ufn_GetCustomCaptionValue('prpbar_PublicationCode', 'WPBA', '{3}')
					ELSE '" + Resources.Global.NewsArticle + @"'
                END AS Publication,

				 				 
                3 AS SortPriority,
                NULL AS prpbar_PublicationEditionID,
                {6}.meta_key,
                {6}.meta_value,
                userread.UserReadCount,
				CASE 
					WHEN userread.UserReadCount IS NULL THEN NULL
					WHEN userread.UserReadCount = 0 THEN NULL
					ELSE 'Y'
				END AS [Read],
                Category
            FROM {5} WITH (NOLOCK)
                LEFT OUTER JOIN {6} WITH (NOLOCK) ON {5}.ID = {6}.post_id AND meta_key = 'associated-companies'
                LEFT OUTER JOIN (SELECT prpar_PublicationArticleID, COUNT(*) UserReadCount FROM PRPublicationArticleRead WITH (NOLOCK) WHERE prpar_WebUserID = {1} GROUP BY prpar_PublicationArticleID) userread ON userread.prpar_PublicationArticleID = {5}.ID
                LEFT OUTER JOIN (SELECT post_ID FROM {6} WHERE meta_key='blueprintEdition') bpe ON bpe.post_ID = {5}.ID
                CROSS APPLY CRM.dbo.ufn_GetWordPressPostDetails4({5}.ID,'{4}') AS wpd
            WHERE post_type = 'post'
                AND post_status in('publish')
				AND {6}.meta_value LIKE '%{2}%'
                {0}";

        protected string SQL_SELECT_NEWS_WORDPRESS_SHORT_COMBINED =
            @"SELECT 
                post_status,
                post_type,
                CAST(ID as int) AS prpbar_PublicationArticleID, 
                NULL AS pren_ExternalNewsID,

				CASE 
					WHEN bpe.post_id IS NULL THEN 'WPBA'
					ELSE 'WPNEWS'
				END AS prpbar_PublicationCode,
				CASE 
					WHEN bpe.post_id IS NULL THEN 'WPBA'
					ELSE 'WPNEWS'
				END AS prpbar_CategoryCode_WP,
                wpd.CategoryCode as prpbar_CategoryCode,

		        post_date AS prpbar_PublishDate,
		        CASE WHEN post_content LIKE '<p>%' THEN 
				    SUBSTRING(post_content, 0, CHARINDEX('</p>', post_content)+4)
				ELSE 
					SUBSTRING(post_content, 0, PATINDEX('%' + CHAR(13) + CHAR(10) + '%', post_content))
				 END AS prpbar_Abstract,
		        post_title as prpbar_Name,
				 				 
                CASE WHEN post_date > DATEADD(month, -3, GETDATE()) THEN 1 ELSE 3 END as SortPriority,				 				 
                NULL AS prpbar_PublicationEditionID,
                {6}.meta_key,
                {6}.meta_value,
                userread.UserReadCount,
				CASE 
					WHEN userread.UserReadCount IS NULL THEN NULL
					WHEN userread.UserReadCount = 0 THEN NULL
					ELSE 'Y'
				END AS [Read],
                NULL AS pren_URL,
                Category,
                Author
            FROM {5} WITH (NOLOCK)
                LEFT OUTER JOIN {6} WITH (NOLOCK) ON {5}.ID = {6}.post_id AND meta_key = 'associated-companies'
                LEFT OUTER JOIN (SELECT prpar_PublicationArticleID, COUNT(*) UserReadCount FROM PRPublicationArticleRead WITH (NOLOCK) WHERE prpar_WebUserID = {1} GROUP BY prpar_PublicationArticleID) userread ON userread.prpar_PublicationArticleID = {5}.ID
                LEFT OUTER JOIN (SELECT post_ID FROM {6} WHERE meta_key='blueprintEdition') bpe ON bpe.post_ID = {5}.ID
                CROSS APPLY CRM.dbo.ufn_GetWordPressPostDetails4({5}.ID,'{4}') AS wpd
            WHERE post_type = 'post'
                AND post_status in('publish')
				AND {6}.meta_value LIKE '%{2}%'
                {0}";

        /// <summary>
        /// Populates the info.
        /// </summary>
        public void PopulateNewsArticles(CompanyDataNews ocdn=null)
        {
            DataTable dtNews = new DataTable();

            if (ocdn == null || ocdn.dtNews == null)
            {
                IDataReader oReader = GetDBAccess().ExecuteReader(SQL, CommandBehavior.CloseConnection);

                //Because DataReaders are forward only cursors, we need to use DataTable
                //so that we can determine counts for the header column and status columns
                dtNews.Load(oReader);
                if (oReader != null)
                    oReader.Close();
            }
            else
            {
                dtNews = ocdn.dtNews;
            }

            NewsCount = dtNews.Rows.Count;

            if(ocdn != null)
            {
                ocdn.dtNews = dtNews;
                // Stash these in the cache.  Most likely the user will be clicking through the company pages so let's not query
                // for these if we don't need to.
                HttpContext.Current.Session[COMPANY_NEWS_DATA_KEY] = ocdn;
            }

            if (NewsArticlesDisplayed > 0 && NewsCount > NewsArticlesDisplayed)
            {
                dtNews = TopDataRow(dtNews, NewsArticlesDisplayed);
            }

            DataView dvNews = dtNews.DefaultView;

            if(MaxMonthsOld > 0)
            {
                dvNews.RowFilter = string.Format("prpbar_PublishDate > '{0}'",DateTime.Now.AddMonths(-MaxMonthsOld));
            }

            switch(Format)
            {
                case NewsFormatType.NEWS_FORMAT_ORIG:
                    repNews.DataSource = dvNews;
                    repNews.DataBind();
                    break;
                case NewsFormatType.NEWS_FORMAT_BBOS9:
                    repNews2.DataSource = dvNews;
                    repNews2.DataBind();
                    break;
            }

            
            lblInternalNewsRecordCount.Text = dvNews.Count + " " + (dvNews.Count == 1 ? SummaryNameSingular : SummaryNamePlural) + " " + Resources.Global.Found.ToLower();
            

            if (DisplayRecordCounts)
                divRecordCounts.Visible = true;

            if (DisplayViewAllButton)
            {
                object oNewsCount = 0;

                if (NewsArticlesDisplayed == MAX_ARTICLES)
                    oNewsCount = dvNews.Count;
                else
                    oNewsCount = NewsCount;

                int newsCount = oNewsCount != DBNull.Value ? Convert.ToInt32(oNewsCount) : 0;

                litViewAll.Text = Resources.Global.ViewAll + " " + newsCount.ToString();
                lnkViewAll.PostBackUrl = PageConstants.FormatFromRoot(PageConstants.COMPANY_NEWS_BBOS9, companyID);
                
                lnkViewAll2.HRef = PageConstants.FormatFromRoot(PageConstants.COMPANY_NEWS_BBOS9, companyID);
                lnkViewAll2.Visible = true;
            }

            if (_bCondensed)
            {
                lnkViewAll.Visible = false;
                lnkViewAll2.Visible = false;
            }
        }

        public DataTable TopDataRow(DataTable dt, int count)
        {
            DataTable dtn = dt.Clone();
            int i = 0;
            foreach (DataRow row in dt.Rows)
            {
                if (i < count)
                {
                    dtn.ImportRow(row);
                    i++;
                }
                if (i > count)
                    break;
            }
            return dtn;
        }

        protected void repNews_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            LinkButton lnkCategory = (LinkButton)e.Item.FindControl("lnkCategory");
            Label lblCategory = (Label)e.Item.FindControl("lblCategory");
            Label lblNewsAbstract1 = (Label)e.Item.FindControl("lblAbstract1");
            HyperLink lnkArticleName1 = (HyperLink)e.Item.FindControl("lnkArticleName1");
            Label lblArticleName1 = (Label)e.Item.FindControl("lblArticleName1");
            Literal litPublishDate1 = (Literal)e.Item.FindControl("litPublishDate1");

            Literal litSourceName = (Literal)e.Item.FindControl("litSourceName");
            Image imgRead = (Image)e.Item.FindControl("imgRead");
            Label lblSourceCodeText = (Label)e.Item.FindControl("lblSourceCodeText");
            Image imgSourceCodeLogo = (Image)e.Item.FindControl("imgSourceCodeLogo");

            //BBOS9 Format controls
            Literal litArticleName2 = (Literal)e.Item.FindControl("litArticleName2");
            HtmlAnchor lnkArticleName2 = (HtmlAnchor)e.Item.FindControl("lnkArticleName2");
            Literal litPublishDate2 = (Literal)e.Item.FindControl("litPublishDate2");
            Literal litAuthor2 = (Literal)e.Item.FindControl("litAuthor2");
            Literal litCategory2 = (Literal)e.Item.FindControl("litCategory2");

            Literal litHyphens = (Literal)e.Item.FindControl("litHyphens");
            if (litHyphens != null)
                litHyphens.Visible = ShowHyphensAfterDate;

            string newsAbstract = UIUtils.DataBinderEval_String(e.Item.DataItem, "prpbar_Abstract");

            string categoryCode = UIUtils.DataBinderEval_String(e.Item.DataItem, "prpbar_CategoryCode");
            string categoryCode_WP = UIUtils.DataBinderEval_String(e.Item.DataItem, "prpbar_CategoryCode_WP");
            string category = UIUtils.DataBinderEval_String(e.Item.DataItem, "Category");

            string articleName = UIUtils.DataBinderEval_String(e.Item.DataItem, "prpbar_Name");

            if (articleName == "")
                articleName = UIUtils.DataBinderEval_String(e.Item.DataItem, "pren_Name");
            string editionName = UIUtils.DataBinderEval_String(e.Item.DataItem, "prpbed_Name");
            string publicationCode = UIUtils.DataBinderEval_String(e.Item.DataItem, "prpbar_PublicationCode");
            int publicationArticleID = UIUtils.DataBinderEval_Int(e.Item.DataItem, "prpbar_PublicationArticleID");

            string szMarketingWebSite;
            if (WebUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                szMarketingWebSite = Utilities.GetConfigValue("LumberWebSite");
            else
                szMarketingWebSite = Utilities.GetConfigValue("ProduceWebSite");
            string szArticleURL = string.Format("{0}?p={1}", szMarketingWebSite, publicationArticleID);

            string secondarySourceName = UIUtils.DataBinderEval_String(e.Item.DataItem, "pren_SecondarySourceName");
            int newsAbstractLengthLimit = Convert.ToInt32(Utilities.GetConfigValue("NewsAbstractLengthLimit", "99"));

            Panel panelAbstract = (Panel)e.Item.FindControl("panelAbstract");
            if (panelAbstract != null)
                panelAbstract.Visible = _bDisplayAbstract;

            if (lnkArticleName1 != null)
            {
                if (!string.IsNullOrEmpty(categoryCode_WP) && categoryCode_WP == PublicationArticles.PUBLICATIONCODE_WPBA)
                {
                    lnkArticleName1.Text = editionName + ' ' + articleName;
                }
                else
                {
                    lnkArticleName1.Text = articleName;
                    lblArticleName1.Text = articleName;
                }
            }
            if (litArticleName2 != null)
            {
                if (!string.IsNullOrEmpty(categoryCode_WP) && categoryCode_WP == PublicationArticles.PUBLICATIONCODE_WPBA)
                {
                    litArticleName2.Text = editionName + ' ' + articleName;
                }
                else
                {
                    litArticleName2.Text = articleName;
                }
            }

            if (publicationCode == "BBN")
            {
                switch (Style)
                {
                    case NewsType.GENERAL_NEWS_COMPANY_DETAILS_NEWS:
                        if (lnkArticleName1 != null)
                            lnkArticleName1.NavigateUrl = PageConstants.FormatFromRoot(PageConstants.NEWS_ARTICLE, publicationArticleID) + "&SourceID=" + publicationArticleID + "&SourceEntityType=PRPublicationArticle&PublicationCode=" + publicationCode;

                        if (lnkArticleName2 != null)
                            lnkArticleName2.HRef = PageConstants.FormatFromRoot(PageConstants.NEWS_ARTICLE, publicationArticleID) + "&SourceID=" + publicationArticleID + "&SourceEntityType=PRPublicationArticle&PublicationCode=" + publicationCode;

                        if (lblCategory != null)
                        {
                            lblCategory.Visible = true;
                            lblCategory.Text = (DataBinder.Eval(e.Item.DataItem, "Category")).ToString();
                        }
                        if (lnkCategory != null)
                            lnkCategory.Visible = false;
                        break;
                    default:
                        if (lnkArticleName1 != null)
                            lnkArticleName1.NavigateUrl = "~/NewsArticle.aspx?ArticleID=" + publicationArticleID + "&SourceID=" + companyID + "&SourceEntityType=Company&PublicationCode=" + publicationCode;

                        if (lnkArticleName2 != null)
                            lnkArticleName2.HRef = "~/NewsArticle.aspx?ArticleID=" + publicationArticleID + "&SourceID=" + companyID + "&SourceEntityType=Company&PublicationCode=" + publicationCode;
                        break;
                }
            }
            else
            {
                switch (Style)
                {
                    case NewsType.GENERAL_NEWS_COMPANY_DETAILS_NEWS:
                        if (lnkArticleName1 != null)
                        {
                            if (!string.IsNullOrEmpty(categoryCode_WP) && categoryCode_WP == PublicationArticles.PUBLICATIONCODE_WPBA)
                            {
                                lnkArticleName1.NavigateUrl = "~/" + string.Format(PageConstants.BLUEPRINTS_VIEW, publicationArticleID);
                            }
                            else if (!string.IsNullOrEmpty(categoryCode_WP) && categoryCode_WP == PublicationArticles.PUBLICATIONCODE_WPNEWS)
                            {
                                lnkArticleName1.NavigateUrl = szArticleURL; // "~/" + string.Format(PageConstants.NEWS_ARTICLE_VIEW, publicationArticleID);
                                lnkArticleName1.Attributes.Add("target", "_blank");
                            }
                            else
                            {
                                lnkArticleName1.NavigateUrl = "~/" + PageConstants.GET_PUBLICATION_FILE + "?PublicationArticleID=" + publicationArticleID + "&SourceID=" + publicationArticleID + "&SourceEntityType=PRPublicationArticle";
                                lnkArticleName1.Attributes.Add("target", "_blank");
                            }

                            lnkArticleName1.Attributes.Add("onclick", "toggleRead(this);");
                        }
                        
                        if (lnkArticleName2 != null)
                        {
                            if (!string.IsNullOrEmpty(categoryCode_WP) && categoryCode_WP == PublicationArticles.PUBLICATIONCODE_WPBA)
                            {
                                lnkArticleName2.HRef = "~/" + string.Format(PageConstants.BLUEPRINTS_VIEW, publicationArticleID);
                            }
                            else if (!string.IsNullOrEmpty(categoryCode_WP) && categoryCode_WP == PublicationArticles.PUBLICATIONCODE_WPNEWS)
                            {
                                lnkArticleName2.HRef = szArticleURL; // "~/" + string.Format(PageConstants.NEWS_ARTICLE_VIEW, publicationArticleID);
                                lnkArticleName2.Attributes.Add("target", "_blank");
                            }
                            else
                            {
                                lnkArticleName2.HRef = "~/" + PageConstants.GET_PUBLICATION_FILE + "?PublicationArticleID=" + publicationArticleID + "&SourceID=" + publicationArticleID + "&SourceEntityType=PRPublicationArticle";
                                lnkArticleName2.Attributes.Add("target", "_blank");
                            }

                            lnkArticleName2.Attributes.Add("onclick", "toggleRead(this);");
                        }

                        if (lblCategory != null)
                            lblCategory.Visible = false;
                        if (lnkCategory != null)
                        {
                            lnkCategory.Visible = true;
                            lnkCategory.Text = (DataBinder.Eval(e.Item.DataItem, "Category")).ToString();
                        }

                        switch (publicationCode)
                        {
                            case "BBR":
                                if (lnkCategory != null)
                                    lnkCategory.PostBackUrl = "~/" + PageConstants.BLUEBOOK_REFERENCE;
                                break;

                            case "BBS":
                                if (lnkCategory != null)
                                    lnkCategory.PostBackUrl = "~/" + PageConstants.BLUEBOOK_SERVICES;
                                break;

                            case "BP":
                            case "BPS":
                                if (!string.IsNullOrEmpty(categoryCode_WP) && categoryCode_WP == PublicationArticles.PUBLICATIONCODE_WPBA)
                                {
                                    if (lnkCategory != null)
                                    {
                                        lnkCategory.Visible = false;
                                    }
                                    if (lblCategory != null)
                                    {
                                        lblCategory.Visible = true;
                                        lblCategory.Text = (DataBinder.Eval(e.Item.DataItem, "Category")).ToString();
                                    }
                                }
                                else
                                {
                                    //if(lnkCategory != null)
                                    //  lnkCategory.PostBackUrl = PageConstants.FormatFromRoot(PageConstants.BLUEPRINTS_EDITION, (DataBinder.Eval(e.Item.DataItem, "prpbar_PublicationEditionID")));
                                }
                                break;

                            case "BPO":
                                if (lnkCategory != null)
                                    lnkCategory.PostBackUrl = "~/" + PageConstants.BLUEPRINTS_ONLINE;
                                break;

                            default:
                                if (lblCategory != null)
                                {
                                    lblCategory.Visible = true;
                                    lblCategory.Text = (DataBinder.Eval(e.Item.DataItem, "Category")).ToString();
                                }
                                if (lnkCategory != null)
                                    lnkCategory.Visible = false;

                                break;
                        }
                        break;

                    case NewsType.GENERAL_NEWS_SUMMARY:
                        if (lnkArticleName1 != null)
                        {
                            if (!string.IsNullOrEmpty(categoryCode_WP) && categoryCode_WP == PublicationArticles.PUBLICATIONCODE_WPBA)
                            {
                                lnkArticleName1.NavigateUrl = "~/" + PublicationArticles.GetWordPressArticleName(articleName, publicationArticleID, blnUrlOnly: true);
                            }
                            else if (!string.IsNullOrEmpty(categoryCode_WP) && categoryCode_WP == PublicationArticles.PUBLICATIONCODE_WPNEWS)
                            {
                                lnkArticleName1.NavigateUrl = szArticleURL; //"~/" + PublicationArticles.GetWordPressNewsArticleName(articleName, publicationArticleID, blnUrlOnly:true);
                                lnkArticleName1.Attributes.Add("target", "_blank");
                            }
                            else
                            {
                                lnkArticleName1.NavigateUrl = "~/" + PageConstants.GET_PUBLICATION_FILE + "?PublicationArticleID=" + publicationArticleID + "&SourceID=" + publicationArticleID + "&SourceEntityType=PRPublicationArticle";
                                lnkArticleName1.Attributes.Add("target", "_blank");
                            }
                        }
                        if (lnkArticleName2 != null)
                        {
                            if (!string.IsNullOrEmpty(categoryCode_WP) && categoryCode_WP == PublicationArticles.PUBLICATIONCODE_WPBA)
                            {
                                lnkArticleName2.HRef = "~/" + PublicationArticles.GetWordPressArticleName(articleName, publicationArticleID, blnUrlOnly: true);
                            }
                            else if (!string.IsNullOrEmpty(categoryCode_WP) && categoryCode_WP == PublicationArticles.PUBLICATIONCODE_WPNEWS)
                            {
                                lnkArticleName2.HRef = szArticleURL; //"~/" + PublicationArticles.GetWordPressNewsArticleName(articleName, publicationArticleID, blnUrlOnly:true);
                                lnkArticleName2.Attributes.Add("target", "_blank");
                            }
                            else
                            {
                                lnkArticleName2.HRef = "~/" + PageConstants.GET_PUBLICATION_FILE + "?PublicationArticleID=" + publicationArticleID + "&SourceID=" + publicationArticleID + "&SourceEntityType=PRPublicationArticle";
                                lnkArticleName2.Attributes.Add("target", "_blank");
                            }
                        }

                        break;

                    default:
                        if (publicationArticleID != 0)
                        {
                            if (lnkArticleName1 != null)
                                lnkArticleName1.NavigateUrl = "~/GetPublicationFile.aspx?PublicationArticleID=" + publicationArticleID + "&SourceID=" + companyID + "&SourceEntityType=Company&PublicationCode=" + publicationCode;

                            if (lnkArticleName2 != null)
                                lnkArticleName2.HRef = "~/GetPublicationFile.aspx?PublicationArticleID=" + publicationArticleID + "&SourceID=" + companyID + "&SourceEntityType=Company&PublicationCode=" + publicationCode;
                        }

                        break;
                }
            }

            if (lblCategory != null && lblCategory.Visible && string.IsNullOrEmpty(lblCategory.Text))
            {
                if (litHyphens != null)
                    litHyphens.Visible = false;
            }

            if (lnkCategory != null && lnkCategory.Visible && string.IsNullOrEmpty(lnkCategory.Text))
            {
                if (litHyphens != null)
                    litHyphens.Visible = false;
            }

            if (!string.IsNullOrEmpty(categoryCode_WP) && categoryCode_WP == PublicationArticles.PUBLICATIONCODE_WPBA)
            {
                if (lblNewsAbstract1 != null)
                    lblNewsAbstract1.Text = newsAbstract;
            }

            if (lblNewsAbstract1 != null)
            {
                if (IsAbstract && newsAbstract.Length > newsAbstractLengthLimit)
                {
                    string szNewsAbstractNoTags = Regex.Replace(newsAbstract, "<.*?>", string.Empty);
                    //make sure we don't break in the middle of a tag (such as a href tag) or it might mess up formatting on page
                    //strip tags out since this will be a condensed abstract listing


                    if (szNewsAbstractNoTags.Length <= newsAbstractLengthLimit)
                        lblNewsAbstract1.Text = newsAbstract;
                    else
                        lblNewsAbstract1.Text = szNewsAbstractNoTags.Remove(newsAbstractLengthLimit).Insert(newsAbstractLengthLimit, "...");
                }
                else
                {
                    lblNewsAbstract1.Text = newsAbstract;
                }
            }

            string szPublishDate = UIUtils.GetStringFromDate(DataBinder.Eval(e.Item.DataItem, PublishDateTimeColName));

            if (litPublishDate1 != null && !string.IsNullOrEmpty(szPublishDate))
            {
                DateTime dtPublishDate = DateTime.Parse(szPublishDate);

                //format date like July 31st, 2017
                litPublishDate1.Text = string.Format("{0:MMMM} {1}{2}, {0:yyyy}", dtPublishDate, dtPublishDate.Day,
                    (
                        (dtPublishDate.Day % 10 == 1 && dtPublishDate.Day != 11) ? "st"
                        : (dtPublishDate.Day % 10 == 2 && dtPublishDate.Day != 12) ? "nd"
                        : (dtPublishDate.Day % 10 == 3 && dtPublishDate.Day != 13) ? "rd"
                        : "th"
                    )
                );
            }

            if (litPublishDate2 != null && !string.IsNullOrEmpty(szPublishDate))
            {
                DateTime dtPublishDate = DateTime.Parse(szPublishDate);

                //format date like July 31st, 2017
                litPublishDate2.Text = string.Format("{0:MMMM} {1}, {0:yyyy}", dtPublishDate, dtPublishDate.Day);
            }

            string szAuthor = UIUtils.GetString(SafeEval(e.Item.DataItem, "Author"));
            if (litAuthor2 != null)
            {
                litAuthor2.Text = szAuthor;
            }

            string szCategory = UIUtils.GetString(DataBinder.Eval(e.Item.DataItem, "Category"));
            if (litCategory2 != null)
            {
                litCategory2.Text = szCategory;
            }

            if (imgRead != null)
            {
                if (DisplayStatusColumn)
                {
                    string read = (DataBinder.Eval(e.Item.DataItem, "Read")).ToString();

                    if (read == "Y")
                    {
                        imgRead.ImageUrl = UIUtils.GetImageURL("read.png");
                        imgRead.AlternateText = Resources.Global.Read;
                        imgRead.ToolTip = Resources.Global.Read;
                    }
                    else
                    {
                        imgRead.ImageUrl = UIUtils.GetImageURL("unread.png");
                        imgRead.AlternateText = Resources.Global.Unread;
                        imgRead.ToolTip = Resources.Global.Unread;
                    }
                }
                else
                    imgRead.Visible = false;
            }

            if (DisplaySourceColumn)
            {
                if(litSourceName != null)
                    litSourceName.Text = secondarySourceName;
            }

            if (DisplayFeedColumn)
            {
                string primarySourceCode = (DataBinder.Eval(e.Item.DataItem, "pren_PrimarySourceCode")).ToString();
                string sourceCodeLogo = UIUtils.GetImageURL(primarySourceCode + ".gif");
                string physicalImagePath = Server.MapPath(sourceCodeLogo);

                if (File.Exists(physicalImagePath))
                {
                    if (lblSourceCodeText != null)
                    {
                        lblSourceCodeText.Visible = false;
                    }
                    if (imgSourceCodeLogo != null)
                    {
                        imgSourceCodeLogo.Visible = true;
                        imgSourceCodeLogo.ImageUrl = sourceCodeLogo;
                    }
                }
                else
                {
                    if (lblSourceCodeText != null)
                    {
                        lblSourceCodeText.Visible = true;
                        lblSourceCodeText.Text = (DataBinder.Eval(e.Item.DataItem, "pren_PrimarySourceCode")).ToString();
                    }

                    if (imgSourceCodeLogo != null)
                    {
                        imgSourceCodeLogo.Visible = false;
                    }
                }
            }
        }

        public static object SafeEval(object container, string expression)
        {
            try
            {
                return DataBinder.Eval(container, expression);
            }
            catch (Exception e)
            {
            }

            return "";
        }
    }
}