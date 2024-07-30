/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2018-2019

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: BlueprintsFlipBookArchive.aspx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Data;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This is the main Blueprints flipbook page that has links to the various
    /// blueprint flipbook editions. 
    /// </summary>
    public partial class BlueprintsFlipBookArchive : PublishingBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            SetPageTitle(Resources.Global.BlueprintsFlipbookArchive);

            if (!IsPostBack)
            {
                PopulateForm();
            }

            Advertisement.Logger = _oLogger;
            Advertisement.WebUser = _oUser;
            Advertisement.LoadAds();
        }

        protected const string SQL_SELECT_BLUEPRINT_FLIPBOOK_EDITION_ARTICLES =
            @"SELECT * FROM
                (
								SELECT prpbar_PublicationEditionID, prpbar_PublicationArticleID, prpbar_PublicationCode, prpbar_CoverArtFileName, prpbar_FileName, prpbed_PublishDate AS prpbar_PublishDate, 1 AS prpbar_Sequence, prpbar_Name
                 FROM PRPublicationArticle pa WITH (NOLOCK) 
			                     INNER JOIN PRPublicationEdition pe WITH (NOLOCK) ON pe.prpbed_PublicationEditionID = pa.prpbar_PublicationEditionID
                              WHERE
                                 prpbar_FileName IS NOT NULL AND prpbar_PublicationCode = 'BPFB'
																 AND prpbed_PublishDate <= GETDATE()
                UNION
                SELECT prpbar_PublicationEditionID, prpbar_PublicationArticleID, prpbar_PublicationCode, prpbar_CoverArtFileName, prpbar_FileName, pe.prpbed_PublishDate AS prpbar_PublishDate, prpbar_Sequence, prpbar_Name
                    FROM PRPublicationArticle pa WITH (NOLOCK) 
		                INNER JOIN PRPublicationEdition pe WITH (NOLOCK) ON pe.prpbed_PublicationEditionID = pa.prpbar_PublicationEditionID
                    WHERE prpbar_PublicationEditionID 
				                IN (SELECT prpbar_PublicationEditionID
							                FROM PRPublicationArticle pa WITH (NOLOCK) 
								                INNER JOIN PRPublicationEdition pe WITH (NOLOCK) ON pe.prpbed_PublicationEditionID = pa.prpbar_PublicationEditionID
							                WHERE
                                 prpbar_FileName IS NOT NULL AND prpbar_PublicationCode = 'BPFB')
				                AND prpbar_FileName IS NOT NULL
				                AND prpbar_CoverArtFileName IS NOT NULL
                        AND prpbar_PublicationCode = 'BPFBS'
												AND pe.prpbed_PublishDate <= GETDATE()
	                ) T1
                ORDER BY prpbar_PublishDate DESC, prpbar_Sequence DESC";

        /// <summary>
        /// Populate with the most recent edition, the online archive, and then
        /// the print archive.
        /// </summary>
        protected void PopulateForm()
        {
            ArrayList oParameters = new ArrayList();

            DataSet dsArticles = GetDBAccess().ExecuteSelect(SQL_SELECT_BLUEPRINT_FLIPBOOK_EDITION_ARTICLES, oParameters);
            repBPFPA.DataSource = dsArticles;
            repBPFPA.DataBind();
        }
    }
}
