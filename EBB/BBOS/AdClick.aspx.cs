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

 ClassName: AdClick.ascx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using PRCo.EBB.BusinessObjects;
using System;
using System.Collections;
using System.Data;
using System.Web;
using TSI.Arch;
using TSI.BusinessObjects;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web {

    /// <summary>
    /// Updates the appropriate Advertising records to record that the
    /// user clicked on an Ad.  Then takes the user to the appropriate
    /// destination.
    /// </summary>
    public partial class AdClick : PageBase {

        protected const string SQL_SELECT_CAMPAIGN =
            @"SELECT pradch_CompanyID, pradc_AdCampaignTypeDigital, pradc_TargetURL 
                FROM PRAdCampaignHeader WITH (NOLOCK)
                INNER JOIN PRAdCampaign WITH (NOLOCK) ON pradc_AdCampaignHeaderID	= pradch_AdCampaignHeaderID
               WHERE pradc_AdCampaignID = @AdCampaignID ";

	    protected const string SQL_UPDATE_AD_AUDIT_TRAIL = 
            @"UPDATE PRAdCampaignAuditTrail 
                 SET pradcat_Clicked='Y' 
               WHERE pradcat_AdCampaignAuditTrailID = @AdAuditTrailID";

        protected const string SQL_UPDATE_AD_CAMPAIGN = 
            @"UPDATE PRAdCampaign 
                 SET pradc_ClickCount = ISNULL(pradc_ClickCount, 0) + 1, 
                     pradc_PeriodClickCount = ISNULL(pradc_PeriodClickCount, 0) + 1  
               WHERE pradc_AdCampaignID  = @AdCampaignID";

        override protected void Page_Load(object sender, EventArgs e) {

            if (IsBot())
                return;

            base.Page_Load(sender, e);

            int iAdCampaignID = 0;
            int iAdAuditTrailID = 0;

            if ((GetRequestParameter("AdCampaignID", false) == null) ||
                (GetRequestParameter("AdAuditTrailID", false) == null))
            {
                if ((_oUser == null) &&
                    (Utilities.GetBoolConfigValue("SuppressPublicParameterExceptions", true)))
                    return;

                throw new ApplicationUnexpectedException("Invalid IDs found.");
            }

            if ((!Int32.TryParse(GetRequestParameter("AdCampaignID"), out iAdCampaignID)) ||
                (!Int32.TryParse(GetRequestParameter("AdAuditTrailID"), out iAdAuditTrailID))) {

                if ((_oUser == null) &&
                    (Utilities.GetBoolConfigValue("SuppressPublicParameterExceptions", true)))
                    return;

                throw new ApplicationUnexpectedException("Invalid IDs found.");
            }

            ArrayList oParameters = new ArrayList();

            bool bGenerateUpdateClickCounts = true;

            // Exclude the PRCo company from any auditing
            if ((IsPRCoUser()) && (!Configuration.AdCampaignTesting)) {
                bGenerateUpdateClickCounts = false;
            }

            if (bGenerateUpdateClickCounts) {
                IDbTransaction oTrans = GetObjectMgr().BeginTransaction();
                try {
                    // Update our Ad Campaign record to increment the click count.
                    oParameters.Add(new ObjectParameter("AdCampaignID", iAdCampaignID));
                    GetDBAccess().ExecuteNonQuery(SQL_UPDATE_AD_CAMPAIGN, oParameters, oTrans);

                    oParameters.Clear();

                    // Update the audit trail record to indicate it was clicked.
                    if (iAdAuditTrailID > 0)
                    {
                        oParameters.Add(new ObjectParameter("AdAuditTrailID", iAdAuditTrailID));
                        GetDBAccess().ExecuteNonQuery(SQL_UPDATE_AD_AUDIT_TRAIL, oParameters, oTrans);
                    }
                    oTrans.Commit();

                } catch {
                    if (oTrans != null) {
                        oTrans.Rollback();
                    }

                    throw;
                }
            }
            oParameters.Clear();
            oParameters.Add(new ObjectParameter("AdCampaignID", iAdCampaignID));

            int iCompanyID = 0;
            string szCampaignType = null;
            string szURL = null;

            using (IDataReader oReader = GetDBAccess().ExecuteReader(SQL_SELECT_CAMPAIGN, oParameters, CommandBehavior.CloseConnection, null))
            {
                if (!oReader.Read())
                    return;
                
                iCompanyID = GetDBAccess().GetInt32(oReader, "pradch_CompanyID");
                szCampaignType = GetDBAccess().GetString(oReader, 1);
                szURL = GetDBAccess().GetString(oReader, 2);
            }

            if (string.IsNullOrEmpty(szURL))
            {
                Response.Redirect(PageConstants.Format(PageConstants.COMPANY_DETAILS_SUMMARY, iCompanyID));
            }
            else
            {
                if (szURL.ToLower().StartsWith("mailto:") || szURL.Contains("://"))
                {
                    //URL is not decoded yet, so decode it (else it would have %3a%2f%2f)
                    //Fixes issue with special chars like # that might be in the URL
                    szURL = HttpUtility.UrlEncode(szURL);
                }

                Response.Redirect(PageConstants.Format(PageConstants.EXTERNAL_LINK_TRIGGER,
                                                       szURL,
                                                       iCompanyID,
                                                       "C",
                                                       GetReferer()));
            }
        }

        protected override bool IsAuthorizedForPage() {
            return true;
        }

        protected override bool IsAuthorizedForData() {
            return true;
        }

        protected bool IsBot()
        {
            try
            {
                return Request.UserAgent.ToLower().Contains("bingbot");
            } catch { 
                // if we don't have a user agent, then something
                // is wrong.
                return true;
            }
        }
    }
}
