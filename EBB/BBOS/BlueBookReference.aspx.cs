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

 ClassName: BlueBookReference.aspx
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
    /// <summary>
    /// This page displays all Publication Articles with a code
    /// of "BBR".  They are ordered by the sequence and the level
    /// is honored.
    /// </summary>
    public partial class BlueBookReference : PublishingBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            SetPageTitle(Resources.Global.ReferenceGuide);

            ucPublicationArticles.Logger = _oLogger;
            ucPublicationArticles.WebUser = _oUser;

            Advertisement.Logger = _oLogger;
            Advertisement.WebUser = _oUser;
            Advertisement.LoadAds();

            if (!IsPostBack)
            {
                PopulateForm();
            }
        }

        protected const string SQL_SELECT_REFERENCE = "SELECT prpbar_PublicationArticleID, prpbar_Name, prpbar_Abstract, prpbar_MediaTypeCode, COALESCE(prpbar_FileName, '') As prpbar_FileName, COALESCE(prpbar_Level, 1) As prpbar_Level FROM PRPublicationArticle WHERE prpbar_PublicationCode = 'BBR' ORDER BY prpbar_Sequence";
        /// <summary>
        /// Populates the forms with the reference material found in
        /// the PRPublicationArticle table.
        /// </summary>
        protected void PopulateForm()
        {
            DataSet dsArticles = GetDBAccess().ExecuteSelect(SQL_SELECT_REFERENCE);
            ucPublicationArticles.DisplayReadMore = false; //Kathi #223 don't display Read More link on this page
            ucPublicationArticles.dsArticles = dsArticles;
            rowArticles.Visible = true;
            ucPublicationArticles.EnableViewState = false;

            //TTG
            using (IDataReader drTTGGFB = GetDBAccess().ExecuteReader(SQL_SELECT_MOST_RECENT_TTGFB, CommandBehavior.CloseConnection))
            {
                if (drTTGGFB.Read())
                {
                    aTTG.NavigateUrl = (string)GetImageURL(drTTGGFB["prpbar_FileName"]);
                    imgTTG.ImageUrl = (string)GetImageURL(drTTGGFB["prpbar_CoverArtFileName"]);
                }
                else
                    pnlTTGFP.Visible = false;
            }
        }

        protected const string SQL_SELECT_MOST_RECENT_TTGFB =
               @"SELECT TOP 1 prpbar_PublicationArticleID, prpbar_FileName, prpbar_CoverArtFileName, prpbar_PublicationCode
			        FROM PRPublicationArticle WITH (NOLOCK)
			        WHERE prpbar_PublicationCode = 'TTGFB'
			        AND prpbar_PublishDate <= GETDATE()
                    ORDER BY prpbar_PublishDate DESC";

        protected override bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.ReferenceGuidePage).HasPrivilege;
        }
    }
}
