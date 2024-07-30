/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2011-2023

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: KnowYourCommodity.aspx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Data;
using PRCo.EBB.BusinessObjects;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    public partial class KnowYourCommodity : PublishingBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            SetPageTitle(Resources.Global.KnowYourCommodity);
            //litReferenceSearch.Text = string.Format(Resources.Global.LearningCenterSearchText, PageConstants.LEARNING_CENTER);

            Advertisement.Logger = _oLogger;
            Advertisement.WebUser = _oUser;
            Advertisement.LoadAds();

            if (!IsPostBack)
            {
                PopulateForm();
            }
        }

        protected const string SQL_SELECT_REFERENCE_WP =
            @"SELECT ID, post_date, post_title, ThumbnailImg, KYCThumbnailImage
                FROM {0} wp WITH (NOLOCK)
                CROSS APPLY CRM.dbo.ufn_GetWordPressPostDetails4(wp.ID,'{1}') wpd
                WHERE post_type = 'KYC'
                    AND post_status = 'publish'
                    AND post_date <= GETDATE()
                    AND ThumbnailImg IS NOT NULL
                ORDER BY post_title";

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
            string szSQL_SELECT_REFERENCE_WP = string.Format(SQL_SELECT_REFERENCE_WP, Configuration.WordPressProduce_posts, GeneralDataMgr.INDUSTRY_TYPE_PRODUCE);
            repKYC.DataSource = GetDBAccess().ExecuteReader(szSQL_SELECT_REFERENCE_WP, CommandBehavior.CloseConnection);
            repKYC.DataBind();
            repKYC.EnableViewState = false;

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
        }

        protected override bool IsAuthorizedForPage()
        {
            return _oUser.IsLimitado || _oUser.HasPrivilege(SecurityMgr.Privilege.KnowYourCommodityPage).HasPrivilege;
        }
    }
}
