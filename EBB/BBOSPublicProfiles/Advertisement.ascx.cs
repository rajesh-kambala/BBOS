
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

 ClassName: Advertisement.ascx
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

namespace PRCo.EBB.UI.Web {

    /// <summary>
    /// User control that determines what advertisements gets displayed based on the 
    /// specified pagename, ad campaign type, and maximum number of ads.
    /// 
    /// <remarks>
    /// This component is shared with the marketing web site so we should avoid using
    /// resource files if possible. 
    /// </remarks>
    /// </summary>
    public partial class Advertisement : UserControlBase {
    
        public string Title;
        public string CompanyIDList;
        public string CampaignType;
        public int SearchAuditID;
        public IPRWebUserSearchCriteria WebUserSearchCritiera;
        public int MaxAdCount;
        public int MinAdCount;
        public bool GenerateAdsOnLoad = false;
        public bool DisplayFullBorder = false;
        
        public string LPAFootHeader;
        public string LPAFootText;

        public int DisplayedAdCount;
        
        protected StringBuilder _sbAdvertisments;
        protected List<Int32> _lCampaignIDs;
        protected List<Int32> _lTopSpotCampaignIDs;
        protected string _adTypeINClause = string.Empty;

        protected StringBuilder _sbIncludedCompanyIDs;

        override protected void Page_Load(object sender, EventArgs e) {
            base.Page_Load(sender, e);
            
            if (GenerateAdsOnLoad) {
                LoadAds();
            }
        }

        private const string SQL_SELECT_ADS =
            @"SELECT TOP {0} pradch_CompanyID, pradc_AdCampaignID, pracf_FileName,
                pradc_PeriodImpressionCount, pradc_TargetURL, ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)) AS RandomNumber,
                pracf_FileName_Disk
            FROM PRAdCampaignHeader WITH (NOLOCK)
                     INNER JOIN PRAdCampaign WITH (NOLOCK) ON pradc_AdCampaignHeaderID = pradch_AdCampaignHeaderID
                    LEFT OUTER JOIN PRAdCampaignFile ON pracf_AdCampaignID = pradc_AdCampaignID AND pracf_FileTypeCode='DI'
            WHERE pradc_AdCampaignTypeDigital IN ({2})
                 AND GETDATE() BETWEEN pradc_StartDate AND ISNULL(pradc_EndDate, DATEADD(day, 1, GETDATE())) 
                 AND pradc_CreativeStatus='A'
                 {1} 
            ORDER BY ISNULL(pradc_TopSpotCount, 0), {3}";


        private const string SQL_SELECT_IMAGE_AD =
            @"SELECT TOP {0} pradc_AdCampaignID
	            FROM PRAdCampaign WITH (NOLOCK) 
               WHERE 
	             pradc_AdCampaignTypeDigital IN ({1})
	             AND GETDATE() BETWEEN pradc_StartDate AND ISNULL(pradc_EndDate, DATEADD(day, 1, GETDATE()))
                 AND pradc_CreativeStatus='A'
            ORDER BY ISNULL(pradc_AlwaysDisplay, 'Z'), pradc_PeriodImpressionCount";

        private const string SQL_AD_CAMPAIGN_LIST = " AND pradc_AdCampaignID IN ({0}) ";
        private const string SQL_COMPANY_LIST = " AND pradch_CompanyID IN ({0}) ";
        private const string SQL_COMPANY_EXCLUDE_LIST = " AND pradch_CompanyID NOT IN ({0}) ";
        private const string SQL_COMMODITY_CLAUSE = " AND pradch_CompanyID IN ({0}) ";

        /// <summary>
        /// Queries the database and loads the advertisements based on the specified
        /// pagename, ad campaign type, and maximum number of ads.  
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
                    UpdateCampaignParms();

                    ArrayList oParameters = new ArrayList();

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

                    string szOrderBy = "pradc_PeriodImpressionCount";

                    string szAdCampaignIDListFilter = string.Empty;
                    string adCampaignIDs = GetAdCampaignList(oParameters, _adTypeINClause);
                    if (!string.IsNullOrEmpty(adCampaignIDs))
                    {
                        szAdCampaignIDListFilter = string.Format(SQL_AD_CAMPAIGN_LIST, adCampaignIDs);
                    }
                    szOrderBy = "RandomNumber";

                    // Go generate the ads.
                    string szSQL = string.Format(SQL_SELECT_ADS,
                                                 MaxAdCount,
                                                 szAdCampaignIDListFilter + szCompanyIDListFilter,
                                                 _adTypeINClause, szOrderBy);
                    iAdCount = GenerateAds(szSQL, oParameters, oTrans);

                    // Make sure the impression counts are updated.
                    // Exclude the PRCo company from any auditing
                    if ((!IsPRCoUser()) ||
                        (Configuration.AdCampaignTesting))
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

                    tdBodyRight.Visible = DisplayFullBorder;
                    trBodyBottom.Visible = DisplayFullBorder;

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

        private const string AD_LINK = "<a href=\"{0}?AdCampaignID={1}&AdAuditTrailID={2}\" {4} />{3}</a>";

        /// <summary>
        /// Builds the specific advertisement HTML based on the ad campaign type.
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

            string szAdImageHTML = "<img src=\"" + Configuration.AdImageVirtualFolder + ((string)oAdImageName).Replace('\\', '/') + $"\" border=\"0\" alt=\"BB #: {iCompanyID} {szCompanyName} {szCommodityName}\">";

            string szAd = null;
            object[] oArgs = {Configuration.AdClickURL,
                                    iAdCampaignID, 
                                    iAdAuditTrailID, 
                                    szAdImageHTML, 
                                    szTarget};

            szAd = string.Format(AD_LINK, oArgs); 

            szAdHTML.Append("<tr><td style=\"text-align:center;vertical-align:middle;\">");
            szAdHTML.Append(szAd);
            szAdHTML.Append("</td></tr>");
            szAdHTML.Append(Environment.NewLine);

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
                                                                  CommandBehavior.Default, oTrans))
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
        /// Unless overrides are specified, retreives the page level
        /// campaign parameters.
        /// </summary>
        protected void UpdateCampaignParms() {
        
            if (MaxAdCount > 0) {
                return;
            }

            // If multiple ad campaign types are specified
            // the calling page has to handle the page settings.
            if (CampaignType.IndexOf(",") > -1)
            {
                return;
            }
        }

        /// <summary>
        /// Executes the specified SQL to retrieve the appropriate ad campaigns.  Iterates
        /// through the set building each ad.
        /// </summary>
        protected int GenerateAds(string szSQL, 
                                  ArrayList oParameters, 
                                  IDbTransaction oTran) {
            int iAdCount = 0;
            int iAdAuditTrailID = 0;
            
            _sbIncludedCompanyIDs = new StringBuilder();
            
            IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            try {
                while (oReader.Read()) {


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
                    
                    if (_sbIncludedCompanyIDs.Length > 0) {
                        _sbIncludedCompanyIDs.Append(",");
                    }
                    _sbIncludedCompanyIDs.Append(oReader.GetInt32(0).ToString());

                    if ((!IsPRCoUser())
                          || (Configuration.AdCampaignTesting))
                    {
                        // Add the audit trail first beacause we need it to 
                        // build any hyperlinks.
                        // Exclude the PRCo company from any auditing
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
                                                    Convert.ToString(oReader[5]),
                                                    oTran));

                    // Add the campaign ID to a list so we can update
                    // the impression count later.
                    _lCampaignIDs.Add(oReader.GetInt32(1));


                    if (iAdCount <= Configuration.AdCampaignTopSpotThreshold) {
                        _lTopSpotCampaignIDs.Add(oReader.GetInt32(1));
                    }


                    if (iAdCount >= MaxAdCount) {
                        break;
                    }
                }
                
                return iAdCount;
            } finally {
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

        /// <summary>
        /// The critiera used to determine if an image ad is displayed on a page, from a
        /// SQL perspective, conflicts with the criteria used to order the Ads. So we have
        /// to break this into a two-step process.
        /// </summary>
        protected string GetAdCampaignList(ArrayList oParameters, string _adTypeINClause)
        {
            StringBuilder sbAdCampaignIDs = new StringBuilder();
            using (IDataReader oReader = GetDBAccess().ExecuteReader(string.Format(SQL_SELECT_IMAGE_AD, MaxAdCount, _adTypeINClause), oParameters, CommandBehavior.CloseConnection, null))
            {
                while (oReader.Read()) {
                    if (sbAdCampaignIDs.Length > 0) {
                        sbAdCampaignIDs.Append(",");
                    }
                    sbAdCampaignIDs.Append(oReader.GetInt32(0).ToString());
                }
            }

            return sbAdCampaignIDs.ToString();
        }
    }
}
