/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2022

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: Blueprints.aspx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Data;
using System.Text;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This is the main Blueprints page that has links to the various
    /// blueprint editions.  The current edition is displayed prominantly
    /// and the most recent additions to the archive are also listed.
    /// </summary>
    public partial class Blueprints : PublishingBase
    {
        int _intPageNum = 1;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if (Request.QueryString["p"] == null)
                Response.Redirect(string.Format("{0}?p={1}", PageConstants.BLUEPRINTS, PageNum));
            else
                PageNum = Convert.ToInt32(Request.QueryString["p"]);

            SetPageTitle(Resources.Global.ProduceBlueprintsMagazine);

            ucPublicationArticles.Logger = _oLogger;
            ucPublicationArticles.WebUser = _oUser;

            if (!IsPostBack)
            {
                PopulateForm();
            }

            Advertisement.Logger = _oLogger;
            Advertisement.WebUser = _oUser;
            Advertisement.LoadAds();
        }

        public int PageNum
        {
            get { return _intPageNum; }
            set
            {
                _intPageNum = value;
                if (_intPageNum == 1)
                    hlViewNewerArticles.Visible = false;

                hlViewOlderArticles.NavigateUrl = string.Format("{0}?p={1}", PageConstants.BLUEPRINTS, _intPageNum+1);
                hlViewNewerArticles.NavigateUrl = string.Format("{0}?p={1}", PageConstants.BLUEPRINTS, _intPageNum - 1);
            }
        }

        public int PageSize
        {
            get
            {
                return Configuration.BluePrintPageSize;
            }
        }

        protected const string SQL_SEARCH_WORDPRESS_BP_ARTICLES =
        @"SELECT 
                'WPBA' AS prpbar_PublicationCode,
				meta_value AS Publication,
                post_status,
                meta_key,
                meta_value,
                guid,
	            CAST(ID as int) AS prpbar_PublicationArticleID, 
	            post_date AS prpbar_PublishDate,
	            CASE WHEN post_content LIKE '<p>%' THEN 
				    SUBSTRING(post_content, 0, CHARINDEX('</p>', post_content)+4)
				ELSE 
					SUBSTRING(post_content, 0, PATINDEX('%' + CHAR(13) + CHAR(10) + '%', post_content))
				 END AS prpbar_Abstract,
	            post_title as prpbar_Name,
                Category,
                dbo.ufn_GetWordPressCategories2(ID,'{6}') Categories
            FROM {2} WITH (NOLOCK)
	             INNER JOIN {3} WITH (NOLOCK) ON {2}.ID = {3}.post_id
                 INNER JOIN {4}  WITH (NOLOCK) ON {2}.ID = Object_ID AND term_taxonomy_id={5}
                 CROSS APPLY CRM.dbo.ufn_GetWordPressPostDetails4(ID,'{6}') wpd
        WHERE meta_key = 'blueprintEdition'
            	AND post_status in('publish')
                AND meta_value <> '{7}'
                AND post_date <= GETDATE()
            ORDER BY post_date DESC
            OFFSET {0} * ({1} - 1) ROWS
            FETCH NEXT {0} ROWS ONLY;";

        /// <summary>
        /// Populate with the most recent edition, the online archive, and then
        /// the print archive.
        /// </summary>
        protected void PopulateForm()
        {
            ArrayList oParameters = new ArrayList();
            StringBuilder sbSQL = new StringBuilder();

            string szSQL = string.Format(SQL_SELECT_EDITION, 1, string.Empty);
            ucBluePrintsSideBar.Data = GetDBAccess().ExecuteSelect(szSQL);

            object[] oArgs = { PageSize, PageNum, Configuration.WordPressProduce_posts, Configuration.WordPressProduce_postmeta, Configuration.WordPressProduce_term_relationships, Configuration.WordPress_Term_Taxonomy_ID, _oUser.prwu_IndustryType, PageControlBaseCommon.EMPTY_BLUEPRINT_EDITION_TEXT };

            sbSQL.Append(string.Format(SQL_SEARCH_WORDPRESS_BP_ARTICLES, oArgs));

            DataSet dsArticles = GetDBAccess().ExecuteSelect(sbSQL.ToString(), oParameters);
            ucPublicationArticles.dsArticles = dsArticles;
        }
    }
}
