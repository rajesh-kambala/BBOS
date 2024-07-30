
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

 ClassName: Advertisements.ascx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/

using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Text;
using PRCo.EBB.BusinessObjects;
using PRCo.EBB.Util;
using TSI.BusinessObjects;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// User control that determines what advertisements gets displayed based on the 
    /// specified ad campaign type, and maximum number of ads.
    /// 
    /// <remarks>
    /// This component is shared with the marketing web site so we should avoid using
    /// resource files if possible. 
    /// </remarks>
    /// </summary>
    public partial class Advertisements : UserControlBase
    {
        public string Title;
        public string CompanyIDList;
        public string CampaignType;
        public int SearchAuditID;
        public IPRWebUserSearchCriteria WebUserSearchCritiera;
        public int MaxAdCount;
        public int MinAdCount;
        public bool GenerateAdsOnLoad = false;

        public string LPAFootHeader;
        public string LPAFootText;

        public int DisplayedAdCount;

        protected StringBuilder _sbAdvertisments;
        protected List<Int32> _lCampaignIDs;
        protected List<Int32> _lTopSpotCampaignIDs;
        protected string _adTypeINClause = string.Empty;

        protected StringBuilder _sbIncludedCompanyIDs;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if (GenerateAdsOnLoad)
            {
                LoadAds();
            }
        }

        private const string SQL_SELECT_CAMPAIGN_ADS =
            @"SELECT TOP {0} pradch_CompanyID, 
		        pradc_AdCampaignID, 
                pracf_FileName,
		        ISNULL(pradc_PeriodImpressionCount,0) pradc_PeriodImpressionCount,
		        ISNULL(pradc_TopSpotCount,0) pradc_TopSpotCount,
                pradc_TargetURL,
                ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)) AS RandomNumber,
                pracf_FileName_Disk 
            FROM vPRAdCampaign
            WHERE pradc_AdCampaignTypeDigital IN ({2})
	            AND GETDATE() BETWEEN pradc_StartDate AND ISNULL(pradc_EndDate, DATEADD(day, 1, GETDATE()))
                AND pradc_CreativeStatus='A'
	            {1}
            ORDER BY ISNULL(pradc_TopSpotCount, 0), {3}";

        private const string SQL_COMPANY_LIST = " AND pradch_CompanyID IN ({0}) ";

        /// <summary>
        /// Queries the database and loads the advertisements based on the specified
        /// ad campaign type, and maximum number of ads.  
        /// </summary>
        /// <returns></returns>
        public int LoadAds()
        {
            _sbAdvertisments = new StringBuilder();
            _lCampaignIDs = new List<int>();
            _lTopSpotCampaignIDs = new List<int>();
            int iAdCount = 0;

            // Lumber users don't see advertisements
            if ((WebUser != null) &&
                (WebUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER))
            {
                this.Visible = false;
                return 0;
            }

            if (string.IsNullOrEmpty(Title))
            {
                trAdTitleRow.Visible = false;
            }

            using (IDbTransaction oTrans = GetObjectMgr().BeginTransaction())
            {
                try
                {
                    // Make sure we have the appropriate campaign settings for this
                    // page.
                    //UpdateCampaignParms();

                    string[] types = CampaignType.Split(',');
                    foreach (string adType in types)
                    {
                        if (_adTypeINClause.Length > 0)
                        {
                            _adTypeINClause += ",";
                        }

                        _adTypeINClause += "'" + adType + "'";
                    }

                    // If we have companyIDs, limit our advertisements to those companies
                    string szCompanyIDListFilter = string.Empty;
                    if (!string.IsNullOrEmpty(CompanyIDList))
                    {
                        szCompanyIDListFilter = string.Format(SQL_COMPANY_LIST, CompanyIDList);
                    }

                    string szOrderBy = "RandomNumber";

                    string szSQL = string.Format(SQL_SELECT_CAMPAIGN_ADS,
                                                    MaxAdCount,
                                                    szCompanyIDListFilter,
                                                    _adTypeINClause,
                                                    szOrderBy);

                    iAdCount = GenerateAds(szSQL, oTrans);

                    // Make sure the impression counts are updated.
                    // Exclude the PRCo company from any auditing
                    if (!IsPRCoUser()
                        || (Configuration.AdCampaignTesting))
                    {
                        AdUtils _adUtils = new AdUtils(LoggerFactory.GetLogger(), WebUser);

                        _adUtils.UpdateImpressionCount(_lCampaignIDs, oTrans);
                        _adUtils.UpdateTopSpotCount(_lTopSpotCampaignIDs, oTrans);
                    }

                    litAdvertisement.Text = _sbAdvertisments.ToString();

                    // If we don't have any ads to display,
                    // then hide the control.
                    if (_sbAdvertisments.Length == 0)
                    {
                        this.Visible = false;
                    }

                    oTrans.Commit();
                    return iAdCount;
                }
                catch(Exception)
                {
                    if (oTrans != null)
                    {
                        oTrans.Rollback();
                    }
                    throw;
                }
            }
        }

        public static string AD_LINK = "<a href=\"{0}?AdCampaignID={1}&AdAuditTrailID={2}\" {4} />{3}</a>";

        /// <summary>
        /// Builds the specific advertisement HTML based on the ad campaign type.
        /// Uses bootstrap div formatting instead of the old control that used html table formatting
        /// </summary>
        /// <param name="iCompanyID"></param>
        /// <param name="iAdCampaignID"></param>
        /// <param name="iAdAuditTrailID"></param>
        /// <param name="oAdImageName"></param>
        /// <param name="szTargetURL"></param>
        /// <returns></returns>
        private string BuildAd(int iCompanyID, int iAdCampaignID, int iAdAuditTrailID, object oAdImageName, string szTargetURL, IDbTransaction oTrans)
        {
            string szCompanyName;
            string szAdCampaignType;
            string szCommodityName;
            GetAdCampaignInfo(iAdCampaignID, oTrans, out szCompanyName, out szAdCampaignType, out szCommodityName);

            StringBuilder szAdHTML = new StringBuilder();

            string szTarget = string.Empty;

            // If a target URL is specified, be sure to open the
            // Ad in a new window
            if (!string.IsNullOrEmpty(szTargetURL))
            {
                szTarget = "target=_blank";
            }

            string szAdImageHTML = "<img src=\"" + Configuration.AdImageVirtualFolder + ((string)oAdImageName).Replace('\\', '/') + $"\" border=\"0\" class='nooverflowimage' alt=\"BB #: {iCompanyID} {szCompanyName} {szCommodityName}\">";

            string szAd = null;
            object[] oArgs = {Configuration.AdClickURL,
                                    iAdCampaignID,
                                    iAdAuditTrailID,
                                    szAdImageHTML,
                                    szTarget};

            szAd = string.Format(AD_LINK, oArgs);

            //szAdHTML.Append("<tr><td style='text-align:center;vertical-align:middle;padding-bottom:10px;'>");
            szAdHTML.Append("<div class='tw-flex tw-justify-center'>");
            szAdHTML.Append(szAd);
            szAdHTML.Append("</div>");
            //szAdHTML.Append(Environment.NewLine);

            DisplayedAdCount++;
            return szAdHTML.ToString();
        }

        const string SQL_GET_AD_CAMPAIGN_INFO = @"SELECT comp_CompanyID, comp_Name, pradc_AdCampaignType, prcm_FullName FROM PRAdCampaign INNER JOIN Company ON Comp_CompanyId = pradc_CompanyID
                                                    LEFT OUTER JOIN PRKYCCommodity ON prkycc_KYCCommodityID = pradc_KYCCommodityID
                                                    LEFT OUTER JOIN PRCommodity ON prkycc_CommodityID = prcm_CommodityId
                                                  WHERE pradc_AdCampaignID = @AdCampaignID";
        private void GetAdCampaignInfo(int AdCampaignID, IDbTransaction oTrans, out string szCompanyName, out string szAdCampaignType, out string szCommodityName)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("AdCampaignID", AdCampaignID));

            using (IDataReader oReader = GetDBAccess().ExecuteReader(SQL_GET_AD_CAMPAIGN_INFO,
                                                                  oParameters,
                                                                  CommandBehavior.Default,
                                                                  oTrans))
            {
                szCompanyName = "";
                szAdCampaignType = "";
                szCommodityName = "";

                oReader.Read();

                if (!oReader.IsDBNull(1))
                    szCompanyName = oReader.GetString(1); //comp_name

                if (!oReader.IsDBNull(2))
                    szAdCampaignType = oReader.GetString(2); //pradc_AdCampaignType

                if (!oReader.IsDBNull(3))
                    szCommodityName = oReader.GetString(3); //prcm_FullName
            }
        }

        /// <summary>
        /// Executes the specified SQL to retrieve the appropriate ad campaigns.  Iterates
        /// through the set building each ad.
        /// </summary>
        /// <param name="szSQL"></param>
        /// <param name="oTran"></param>
        /// <returns></returns>
        protected int GenerateAds(string szSQL,
                                  IDbTransaction oTran)
        {
            int iAdCount = 0;
            int iAdAuditTrailID = 0;

            _sbIncludedCompanyIDs = new StringBuilder();

            IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, null, CommandBehavior.CloseConnection, null);
            try
            {
                while (oReader.Read())
                {
                    if ((CampaignType != "LPA") &&
                        (oReader["pracf_FileName_Disk"] == DBNull.Value))
                    {
                        string szCacheName = string.Format(REF_AD_CAMPAIGN, oReader.GetInt32(1));
                        //Only send email every 25th error
                        if (IncrementCacheCount(szCacheName) % Utilities.GetIntConfigValue("Advertisement_Email_Threshhold", 25) == 0)
                        {
                            LogError(new ApplicationException("Advertisement found without an image for company: " + oReader.GetInt32(0).ToString()));
                        }

                        continue;
                    }

                    iAdCount++;

                    if (_sbIncludedCompanyIDs.Length > 0)
                    {
                        _sbIncludedCompanyIDs.Append(",");
                    }
                    _sbIncludedCompanyIDs.Append(oReader.GetInt32(0).ToString());

                    if ((!IsPRCoUser()) ||
                        (Configuration.AdCampaignTesting))
                    {
                        // Exclude the PRCo company from any auditing
                        // Add the audit trail first beacause we need it to 
                        // build any hyperlinks.
                        AdUtils _adUtils = new AdUtils(LoggerFactory.GetLogger(), WebUser);

                        iAdAuditTrailID = _adUtils.InsertAdAuditTrail(oReader.GetInt32(1),
                                                             oReader.GetInt32(3),
                                                             iAdCount,
                                                             null,
                                                             SearchAuditID,
                                                             oTran);
                    }

                    // Go build the Ad HTML.
                    _sbAdvertisments.Append(BuildAd(oReader.GetInt32(0),
                                                    oReader.GetInt32(1),
                                                    iAdAuditTrailID,
                                                    oReader["pracf_FileName_Disk"],
                                                    Convert.ToString(oReader["pradc_TargetURL"]),
                                                    oTran));

                    // Add the campaign ID to a list so we can update
                    // the impression count later.
                    _lCampaignIDs.Add(oReader.GetInt32(1));

                    if (iAdCount <= Configuration.AdCampaignTopSpotThreshold)
                    {
                        _lTopSpotCampaignIDs.Add(oReader.GetInt32(1));
                    }

                    if (iAdCount >= MaxAdCount)
                    {
                        break;
                    }
                }

                return iAdCount;
            }
            finally
            {
                oReader.Close();
            }
        }

        IBusinessObjectSet _osCompanyIDs = null;

        /// <summary>
        /// Indicates if the current user is
        /// a PRCo user.  Used for admin type
        /// functionality.
        /// </summary>
        /// <returns></returns>
        protected bool IsPRCoUser()
        {
            if (Configuration.AdCampaignTesting)
            {
                return false;
            }

            if (WebUser == null)
            {
                return false;
            }

            if (_osCompanyIDs == null)
            {
                Custom_CaptionMgr _oCustom_CaptionMgr = new Custom_CaptionMgr();
                _osCompanyIDs = new Custom_CaptionMgr().GetByName("InternalHQID");
            }

            foreach (ICustom_Caption oCC in _osCompanyIDs)
            {
                if (WebUser.prwu_BBID == Convert.ToInt32(oCC.Code))
                {
                    return true;
                }
            }

            if (Session["IsPRCOUser"] != null)
            {
                return true;
            }

            return false;
        }
    }
}
