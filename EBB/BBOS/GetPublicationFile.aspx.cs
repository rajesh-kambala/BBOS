/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2010-2018

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: GetPublicationFile.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Data;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web
{
    public partial class GetPublicationFile : PageBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            int publicationArticleID = Convert.ToInt32(GetRequestParameter("PublicationArticleID", true));
            int sourceID = Convert.ToInt32(GetRequestParameter("SourceID", false));
            string sourceEntityType = GetRequestParameter("SourceEntityType", false);
            string triggerPage = GetTriggerPage();
            string publicationCode = GetRequestParameter("PublicationCode", false);

            if(publicationCode == null)
            {
                string SQL_SELECT_ARTICLE =
                @"SELECT prpbar_PublicationArticleID,  prpbar_PublicationEditionID, prpbar_Name, prpbar_Abstract, prpbar_FileName, prpbar_NoChargeExpiration, prpbar_ProductID, prpbar_Sequence, prpbar_PublicationCode
                    FROM PRPublicationArticle WITH (NOLOCK) 
                    WHERE prpbar_PublicationArticleID = {0}";

                string szSQL = string.Format(SQL_SELECT_ARTICLE, publicationArticleID);

                using (IDataReader dr = GetDBAccess().ExecuteReader(szSQL))
                {
                    if (dr.Read())
                    {
                        publicationCode = (string)dr["prpbar_PublicationCode"];
                    }
                }
            }

            string coverArtFileName = null;
            string mediaTypeCode = null;

            string fileName = PublishingBase.GetArticleFileName(publicationArticleID, out coverArtFileName, out mediaTypeCode, _oLogger);

            // If the caller is looking for the cover art, then
            // reset our filename
            if (GetRequestParameter("CAFN", false) == "Y")
            {
                fileName = coverArtFileName;
            }

            if (string.IsNullOrEmpty(fileName))
            {
                return;
            }

            // Before returning the file, record that the user
            // read it.
            try
            {
                GetObjectMgr().InsertPublicationArticleRead(publicationArticleID, sourceID, sourceEntityType, triggerPage, publicationCode, null);
            }
            catch (Exception eX)
            {
                GetObjectMgr().Rollback();

                // There's nothing the end user can do about this so
                // just log it and keep moving.
                LogError(eX);

                if (Configuration.ThrowDevExceptions)
                {
                    throw;
                }
            }

            if (mediaTypeCode == "URL")
            {
                string url = fileName.ToLower();
                if ((!url.ToLower().StartsWith("http://")) &&
                    (!url.ToLower().StartsWith("https://")))
                {
                    url = "http://" + url;
                }

                Response.Redirect(url, false);
                return;
            }

            if (fileName.EndsWith(".html") || fileName.EndsWith(".htm"))
            {
                Response.Redirect(Utilities.GetConfigValue("LearningCenterVirtualFolder") + fileName, false);
                return;
            }

            string physicalPath = Utilities.GetConfigValue("LearningCenterIndexPath") + fileName;

            Response.ClearContent();
            Response.ClearHeaders();

            int pdfExtension = 0;
            int csvExtension = 0;
            string contentType = string.Empty;

            pdfExtension = fileName.IndexOf(".pdf");
            csvExtension = fileName.IndexOf(".csv");

            if (pdfExtension > -1)
                contentType = "application/pdf";
            else if (csvExtension > -1)
                contentType = "application/csv";

            if (!string.IsNullOrEmpty(contentType))
                Response.ContentType = contentType;

            Response.WriteFile(physicalPath);
        }

        protected override bool IsAuthorizedForPage()
        {
            return true;
        }

        protected override bool IsAuthorizedForData()
        {
            return true;
        }

        protected string GetTriggerPage()
        {
            string triggerPage = GetRequestParameter("TriggerPage", false);

            if (string.IsNullOrEmpty(triggerPage))
                triggerPage = GetReferer();

            return triggerPage;
        }
    }
}
