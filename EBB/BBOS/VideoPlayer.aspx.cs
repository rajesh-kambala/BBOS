/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2009-2018

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: VideoPlayer.aspx.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Web.UI;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    public partial class VideoPlayer : PublishingBase
    {
        public string VideoURL = null;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
            Page.Header.DataBind();

            int publicationArticleID = Convert.ToInt32(GetRequestParameter("PublicationArticleID", true));
            int sourceID = Convert.ToInt32(GetRequestParameter("SourceID", false));
            string sourceEntityType = GetRequestParameter("SourceEntityType", false);
            string triggerPage = GetRequestParameter("TriggerPage", false);
            string publicationCode = GetRequestParameter("PublicationCode", false);

            VideoURL = GetArticleFileName(publicationArticleID, LoggerFactory.GetLogger());

            // If the video URL starts with TRN/, then we're assuming this
            // is a flash file stored locally.  Otherwise we assume it is
            // a Vimeo URL.
            if (VideoURL.StartsWith("TRN/"))
            {
                pnlVimeo.Visible = false;
                VideoURL = "LearningCenter/" + VideoURL;
            }
            else
            {
                pnlFlash.Visible = false;
            }

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
        }

        protected override bool IsAuthorizedForPage()
        {
            return true;
        }

        protected override bool IsAuthorizedForData()
        {
            return true;
        }

        public override void PreparePageFooter()
        {
            // Do nothing
        }

        protected override bool PageRequiresSecureConnection()
        {
            return false;
        }
    }
}
