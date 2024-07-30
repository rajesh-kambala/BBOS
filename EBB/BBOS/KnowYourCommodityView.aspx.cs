/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2018-2019

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: KnowYourCommodityView.aspx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Data;
using TSI.Utils;
using PRCo.EBB.BusinessObjects;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    public partial class KnowYourCommodityView : PublishingBase
    {
        protected string _szArticleID;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            SetPageTitle(Resources.Global.KnowYourCommodity);

            //Configure WordPress article control
            ArticleID = GetRequestParameter("ArticleID", true);
            ucWordPressArticle.ArticleID = ArticleID;
            ucWordPressArticle.BaseUrl = Request.RawUrl.Substring(0, Request.RawUrl.IndexOf("?"));
            ucWordPressArticle.ShowBackToKYCButton = true;

            string szPageNum = GetRequestParameter("p", false);
            if(!string.IsNullOrEmpty(szPageNum))
                ucWordPressArticle.PageNum = Convert.ToInt32(szPageNum);

            Advertisement.Logger = _oLogger;
            Advertisement.WebUser = _oUser;
            Advertisement.LoadAds();

            if (!IsPostBack)
            {
                //Flag the commodity article as read
                string szEntityType = "WPPublicationArticle";
                GetObjectMgr().InsertPublicationArticleRead(Convert.ToInt32(_szArticleID),
                                                0,
                                                szEntityType,
                                                GetReferer(),
                                                PublicationArticles.PUBLICATIONCODE_WPKYC,
                                                null);

                PopulateForm();
            }
        }

        public string ArticleID
        {
            get { return _szArticleID; }
            set { _szArticleID = value; }
        }

        protected const string SQL_SELECT_MOST_RECENT_KYCGFB =
               @"SELECT TOP 1 prpbar_PublicationArticleID, prpbar_FileName, prpbar_CoverArtFileName, prpbar_PublicationCode
			        FROM PRPublicationArticle WITH (NOLOCK)
			        WHERE prpbar_PublicationCode = 'KYCGFB'
			        AND prpbar_PublishDate <= GETDATE()
                    ORDER BY prpbar_PublishDate DESC";

        /// <summary>
        /// Populates the forms with the reference material found in
        /// the PRPublicationArticle table.
        /// </summary>
        protected void PopulateForm()
        {
            using (IDataReader drKYCGFB = GetDBAccess().ExecuteReader(SQL_SELECT_MOST_RECENT_KYCGFB, CommandBehavior.CloseConnection))
            {
                if (drKYCGFB.Read())
                {
                    aKYC.NavigateUrl = (string)GetImageURL(drKYCGFB["prpbar_FileName"]);
                    imgKYC.ImageUrl = (string)GetImageURL(drKYCGFB["prpbar_CoverArtFileName"]);
                }
                else
                    pnlKYCFP.Visible = false;
            }

            litAdWidget.Text = Utilities.GetConfigValue("WidgetsRootURL") + "javascript/GetAdsWidget.min.js";
        }

        protected override bool IsAuthorizedForPage()
        {
            return _oUser.IsLimitado || _oUser.HasPrivilege(SecurityMgr.Privilege.KnowYourCommodityPage).HasPrivilege;
        }
    }
}
