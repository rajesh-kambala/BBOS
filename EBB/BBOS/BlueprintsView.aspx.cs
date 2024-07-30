/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2018-2022

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: BlueprintsView.aspx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Data;
using System.Text;
using System.Web.UI;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This is the main Blueprints page that has links to the various
    /// blueprint editions.  The current edition is displayed prominantly
    /// and the most recent additions to the archive are also listed.
    /// </summary>
    public partial class BlueprintsView : PublishingBase
    {
        protected string _szArticleID;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            SetPageTitle(Resources.Global.BlueprintsQuarterlyJournalArticle);

            //Configure WordPress article control
            ArticleID = GetRequestParameter("ArticleID", true);
            ucWordPressArticle.ArticleID = ArticleID;
            ucWordPressArticle.BaseUrl = Request.RawUrl.Substring(0, Request.RawUrl.IndexOf("?"));
            ucWordPressArticle.ArticleType = WordPressArticle.ArticleEnum.BluePrint;
            ucWordPressArticle.DatePrefix = "Blueprint Edition Date:&nbsp;";

            pnlNewsLink.Visible = HasNonBlueprintsCategories(ArticleID);

            string szPageNum = GetRequestParameter("p", false);
            if (!string.IsNullOrEmpty(szPageNum))
                ucWordPressArticle.PageNum = Convert.ToInt32(szPageNum);

            if (!IsPostBack)
            {
                PopulateForm();
            }

            Advertisement.Logger = _oLogger;
            Advertisement.WebUser = _oUser;
            Advertisement.LoadAds();

            //Flag the WordPress article as read
            string szEntityType = "WPPublicationArticle";
            GetObjectMgr().InsertPublicationArticleRead(Convert.ToInt32(_szArticleID),
                                            0,
                                            szEntityType,
                                            GetReferer(),
                                            PublicationArticles.PUBLICATIONCODE_WPBA,
                                            null);
        }

        public string ArticleID
        {
            get { return _szArticleID; }
            set { _szArticleID = value; }
        }

        /// <summary>
        /// Populate with the most recent edition, the online archive, and then
        /// the print archive.
        /// </summary>
        protected void PopulateForm()
        {
            ArrayList oParameters = new ArrayList();
            StringBuilder sbSQL = new StringBuilder();

            string szSQL1 = string.Format(SQL_SELECT_EDITION, 1, string.Empty);
            ucBluePrintsSideBar.Data = GetDBAccess().ExecuteSelect(szSQL1);
        }

        protected const string SQL_POST_TERMS =
            @"SELECT post_content, t.name 
                FROM WordPressProduce.dbo.wp_posts p WITH (NOLOCK)
                    LEFT JOIN {1} rel ON rel.object_id = p.ID
                    LEFT JOIN {2} tax ON tax.term_taxonomy_id = rel.term_taxonomy_id
                    LEFT JOIN {3} t ON t.term_id = tax.term_id
                WHERE ID = {0}
                    AND tax.taxonomy = 'Category'";

        private bool HasNonBlueprintsCategories(string ArticleID)
        {
            string szSQL = string.Format(SQL_POST_TERMS, ArticleID, Configuration.WordPressProduce_term_relationships, Configuration.WordPressProduce_term_taxonomy, Configuration.WordPressProduce_terms);
            int count = 0;
            using (IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection))
            {
                while (oReader.Read())
                {
                    if (oReader["name"] != System.DBNull.Value && (string)oReader["name"] != "Produce Blueprints")
                        count++;
                }
            }

            return count>0;
        }

        protected void btnNews_Click(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.NEWS);
        }
    }
}
