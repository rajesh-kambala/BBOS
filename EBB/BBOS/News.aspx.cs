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
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

using PRCo.EBB.BusinessObjects;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This page displays are PRPublicationArticles that are flagged for
    /// news display.  MembersOnly articles are only displayed for, well, 
    /// members only.
    /// </summary>
    public partial class News : PublishingBase
    {
        int _intPageNum = 1;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if (Request.QueryString["p"] == null)
                Response.Redirect(string.Format("{0}?p={1}", PageConstants.NEWS, PageNum));
            else
                PageNum = Convert.ToInt32(Request.QueryString["p"]);

            SetPageTitle(Resources.Global.News);

            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_TOGGLE_FUNCTIONS_FILE));

            Advertisement.Logger = _oLogger;
            Advertisement.WebUser = _oUser;
            Advertisement.LoadAds();

            ucPublicationArticles.Logger = _oLogger;
            ucPublicationArticles.WebUser = _oUser;

            if (!IsPostBack)
            {
                PopulateForm();
            }
        }

        /*
            {0}=PageSize, 
            {1}=PageNum, 
            {2}=UserID, 
            {3}=wp_posts, 
            {4}=wp_postmeta
        */
        protected const string SQL_SEARCH_WORDPRESS_ARTICLES =
          @"SELECT post_status,
		       post_type,
		       guid,
		       CAST(ID as int) AS prpbar_PublicationArticleID, 
               'WPNEWS' AS prpbar_PublicationCode,
		       post_date AS prpbar_PublishDate,
               CASE WHEN post_content LIKE '<p>%' THEN 
                  SUBSTRING(post_content, 0, CHARINDEX('</p>', post_content)+4)
               ELSE 
                  SUBSTRING(post_content, 0, PATINDEX('%' + CHAR(13) + CHAR(10) + '%', post_content))
               END AS prpbar_Abstract,
		       post_title as prpbar_Name,
			   {4}.meta_key,
			   {4}.meta_value,
               x.UserReadCount,
               Category
		    FROM {3} WITH (NOLOCK)
			    LEFT OUTER JOIN {4} WITH (NOLOCK) ON {3}.ID = {4}.post_id AND meta_key = 'associated-companies'
                LEFT OUTER JOIN (SELECT prpar_PublicationArticleID, COUNT(*) UserReadCount FROM PRPublicationArticleRead WITH (NOLOCK) WHERE prpar_WebUserID = {2} GROUP BY prpar_PublicationArticleID) x ON prpar_PublicationArticleID = {3}.ID
                CROSS APPLY CRM.dbo.ufn_GetWordPressPostDetails4(ID,'{6}') wpd 
		    WHERE post_type = 'post'
		        AND post_status in('publish')
                AND id NOT IN (SELECT post_ID FROM {4} WHERE meta_key = 'blueprintEdition' and meta_value <> '{5}') --exclude blueprintEditions that are default empty value
            ORDER BY post_date DESC
            OFFSET {0} * ({1} - 1) ROWS
            FETCH NEXT {0} ROWS ONLY;";

        /// <summary>
        /// Populates the outer repeater with those categories that have articles.
        /// </summary>
        protected void PopulateForm()
        {
            ArrayList oParameters = new ArrayList();
            object[] oArgs;
            
            if(_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                oArgs = new object[] { PageSize, PageNum, _oUser.UserID, Configuration.WordPressLumber_posts, Configuration.WordPressLumber_postmeta, PageControlBaseCommon.EMPTY_BLUEPRINT_EDITION_TEXT, GeneralDataMgr.INDUSTRY_TYPE_LUMBER };
            else
                oArgs = new object[] { PageSize, PageNum, _oUser.UserID, Configuration.WordPressProduce_posts, Configuration.WordPressProduce_postmeta, PageControlBaseCommon.EMPTY_BLUEPRINT_EDITION_TEXT, GeneralDataMgr.INDUSTRY_TYPE_SUPPLY };

            string szSQL = string.Format(SQL_SEARCH_WORDPRESS_ARTICLES, oArgs);

            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                szSQL = szSQL.Replace("Category", "CASE WHEN Category='Uncategorized' THEN 'General News' ELSE Category END AS Category");


            DataSet dsArticles = GetDBAccess().ExecuteSelect(szSQL, oParameters);
            ucPublicationArticles.dsArticles = dsArticles;
        }

        public int PageSize
        {
            get
            {
                return Configuration.NewsPageSize;
            }
        }
        public int PageNum
        {
            get { return _intPageNum; }
            set
            {
                _intPageNum = value;
                if (_intPageNum == 1)
                    hlViewNewerArticles.Visible = false;

                hlViewOlderArticles.NavigateUrl = string.Format("{0}?p={1}", PageConstants.NEWS, _intPageNum + 1);
                hlViewNewerArticles.NavigateUrl = string.Format("{0}?p={1}", PageConstants.NEWS, _intPageNum - 1);
            }
        }


        protected override bool IsAuthorizedForPage()
        {
            return true;
        }

        protected override bool IsAuthorizedForData()
        {
            return true;
        }

        protected void repNews_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            string articleName = (DataBinder.Eval(e.Item.DataItem, "prpbar_Name")).ToString();
            string publicationCode = (DataBinder.Eval(e.Item.DataItem, "prpbar_PublicationCode")).ToString();
            string publicationArticleID = (DataBinder.Eval(e.Item.DataItem, "prpbar_PublicationArticleID")).ToString();
            string read = (DataBinder.Eval(e.Item.DataItem, "Read")).ToString();
            string category = (DataBinder.Eval(e.Item.DataItem, "Category")).ToString();
            string publicationEditionID = (DataBinder.Eval(e.Item.DataItem, "prpbar_PublicationEditionID")).ToString();

            Image imgRead = (Image)e.Item.FindControl("imgRead");
            HyperLink lnkArticleName = (HyperLink)e.Item.FindControl("lnkArticleName");
            LinkButton lnkCategory = (LinkButton)e.Item.FindControl("lnkCategory");
            Label lblCategory = (Label)e.Item.FindControl("lblCategory");
            Literal litPublishDate1 = (Literal)e.Item.FindControl("litPublishDate1");

            lnkArticleName.Text = articleName;

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

            if (publicationCode == "BBN")
            {
                lnkArticleName.NavigateUrl = "NewsArticle.aspx?ArticleID=" + publicationArticleID + "&SourceID=" + publicationArticleID + "&SourceEntityType=PRPublicationArticle&PublicationCode=" + publicationCode;
                lblCategory.Visible = true;
                lnkCategory.Visible = false;
                lblCategory.Text = category;
            }
            else
            {
                lnkArticleName.NavigateUrl = PageConstants.GET_PUBLICATION_FILE + "?PublicationArticleID=" + publicationArticleID + "&SourceID=" + publicationArticleID + "&SourceEntityType=PRPublicationArticle";
                lnkArticleName.Attributes.Add("target", "_blank");
                lnkArticleName.Attributes.Add("onclick", "toggleRead(this);");

                lblCategory.Visible = false;
                lnkCategory.Visible = true;
                lnkCategory.Text = category;

                switch (publicationCode)
                {
                    case "BBR":
                        lnkCategory.PostBackUrl = PageConstants.BLUEBOOK_REFERENCE;
                        break;

                    case "BBS":
                        lnkCategory.PostBackUrl = PageConstants.BLUEBOOK_SERVICES;
                        break;

                    //case "BP":
                    //    lnkCategory.PostBackUrl = PageConstants.Format(PageConstants.BLUEPRINTS_EDITION, publicationEditionID);
                    //    break;

                    case "BPO":
                        lnkCategory.PostBackUrl = PageConstants.BLUEPRINTS_ONLINE;
                        break;

                    default:
                        lblCategory.Visible = true;
                        lnkCategory.Visible = false;
                        lblCategory.Text = category;
                        break;
                }
            }

            string szPublishDate = UIUtils.GetStringFromDate(DataBinder.Eval(e.Item.DataItem, "prpbar_PublishDate"));

            if (!string.IsNullOrEmpty(szPublishDate))
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
        }
    }
}
