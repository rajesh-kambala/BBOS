/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2007-2023

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com
     
 ClassName: News.ascx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/

using System;
using System.Data;
using PRCo.EBB.BusinessObjects;
using TSI.Arch;
using TSI.DataAccess;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web.UserControls
{
    public partial class News : UserControlBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if (!IsPostBack)
            {
                if (WebUser.IsLimitado)
                {
                    this.Visible = false;
                    return;
                }

                PopulateForm();
            }


            string szNewsUrl;
            if (WebUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                szNewsUrl = Utilities.GetConfigValue("LumberWebSite");
            else
                szNewsUrl = Utilities.GetConfigValue("ProduceWebSite");

            hlNews3.HRef = szNewsUrl;
        }   

        protected const string SQL_SELECT_NEWS_WP =
            @"SELECT TOP 2 post_status,
		       post_type,
		       CAST(ID as int) AS prpbar_PublicationArticleID, 
               'WPNEWS' AS prpbar_PublicationCode,
		       post_date AS prpbar_PublishDate,
		       CASE WHEN post_content LIKE '<p>%' THEN 
				    SUBSTRING(post_content, 0, CHARINDEX('</p>', post_content)+4)
			   ELSE 
					SUBSTRING(post_content, 0, PATINDEX('%' + CHAR(13) + CHAR(10) + '%', post_content))
			   END AS prpbar_Abstract,
		       post_title as prpbar_Name,
			   {1}.meta_key,
			   {1}.meta_value,
               Category
		    FROM {0} WITH (NOLOCK)
			    LEFT OUTER JOIN {1} WITH (NOLOCK) ON {0}.ID = {1}.post_id AND meta_key = 'associated-companies'
                CROSS APPLY CRM.dbo.ufn_GetWordPressPostDetails4(ID,'{3}') wpd
		    WHERE post_type = 'post'
		        AND post_status in('publish')
            AND id NOT IN (SELECT post_ID FROM {1} WHERE meta_key = 'blueprintEdition' and meta_value <> '{2}')
            ORDER BY post_date DESC";


        protected void PopulateForm()
        {
            string sql = null;
            string szMarketingWebSite;
            object[] oArgs;
            if (WebUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                oArgs = new object[] { Configuration.WordPressLumber_posts, Configuration.WordPressLumber_postmeta, PageControlBaseCommon.EMPTY_BLUEPRINT_EDITION_TEXT, WebUser.prwu_IndustryType };
                szMarketingWebSite = Utilities.GetConfigValue("LumberWebSite");
            }
            else
            {
                oArgs = new object[] { Configuration.WordPressProduce_posts, Configuration.WordPressProduce_postmeta, PageControlBaseCommon.EMPTY_BLUEPRINT_EDITION_TEXT, WebUser.prwu_IndustryType };
                szMarketingWebSite = Utilities.GetConfigValue("ProduceWebSite");
            }

            sql = string.Format(SQL_SELECT_NEWS_WP, oArgs);

            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            oDBAccess.Logger = GetLogger();

            using (IDataReader reader = oDBAccess.ExecuteReader(sql, CommandBehavior.CloseConnection))
            {
                int x = 0;
                while (reader.Read())
                {
                    x++;
                    if (x > 2)
                        break;

                    int articleID = GetDBAccess().GetInt32(reader, "prpbar_PublicationArticleID");
                    string szName = GetDBAccess().GetString(reader, "prpbar_Name");
                    
                    string szArticleURL = string.Format("{0}?p={1}", szMarketingWebSite, articleID);

                    const int MAX_LENGTH = 47;
                    if (szName.Length > MAX_LENGTH)
                        szName = szName.Substring(0, MAX_LENGTH) + "...";

                    switch (x)
                    {
                        case 1:
                            newsArticle1.Text = szName;
                            newsArticle1.NavigateUrl = szArticleURL; //newsArticle1.NavigateUrl = "~/" + PublicationArticles.GetWordPressNewsArticleName("", articleID, blnUrlOnly: true);
                            newsArticle1.Visible = true;
                            break;
                        case 2:
                            newsArticle2.Text = szName;
                            newsArticle2.NavigateUrl = szArticleURL; //newsArticle2.NavigateUrl = "~/" + PublicationArticles.GetWordPressNewsArticleName("", articleID, blnUrlOnly: true);
                            newsArticle2.Visible = true;
                            break;
                    }
                }
            }
        }
    }
}