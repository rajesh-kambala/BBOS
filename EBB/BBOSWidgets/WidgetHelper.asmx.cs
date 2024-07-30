/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2011-2023

 The use, disclosure, reproduction, modification, transfer, or
 transmittal of  this work for any purpose in any form or by any
 means without the written  permission of Blue Book Services, Inc. is
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: AJAXHelper
 Description:

 Notes:

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Text;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;
using TSI.DataAccess;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web.Widgets
{

    /// <summary>
    /// Summary description for WidgetHelper
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    [System.Web.Script.Services.ScriptService]
    public class WidgetHelper : System.Web.Services.WebService
    {
        protected IDBAccess _oDBAccess;
        protected ILogger _oLogger;
        protected string _szRequestName = null;


        protected const string SQL_SELECT_COMPANY_AUTH =
            @"SELECT comp_CompanyID, comp_PRCorrTradestyle, comp_PRTMFMAward, comp_PRTMFMAwardDate, comp_PRIndustryType, dbo.ufn_GetPrimaryService(comp_CompanyID) as PrimaryServiceCode, prra_IntegrityId
                FROM Company WITH (NOLOCK)
                     LEFT OUTER JOIN PRRating WITH (NOLOCK) ON comp_CompanyID = prra_RatingID AND prra_Current = 'Y'
               WHERE comp_CompanyID = @CompanyID";


        [WebMethod]
        [ScriptMethod(UseHttpGet = true, ResponseFormat = ResponseFormat.Json)]
        public string GetCompanyAuthWidget(string key)
        {
            try
            {
                return GetCompanyAuth(key);
            }
            catch (Exception eX)
            {
                GetLogger().LogError(eX);
                return string.Empty;
            }
        }

        public string GetCompanyAuth(string key)
        {
            _szRequestName = "CompanyAuth";

            int iCompanyID = 0;
            if (!new KeyUtils().ValidateKey("CompanyAuth", key, out iCompanyID))
            {
                return string.Empty;
            }

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", iCompanyID));

            IDataReader oReader = null;
            string szCompanyName = null;
            string szTMFMAward = null;
            DateTime dtTMFMAwardDate = DateTime.MinValue;
            string szIndustryType = null;
            string szPrimaryServiceCode = null;
            int iIntegrityID = 0;

            try
            {
                oReader = GetDBAccess().ExecuteReader(SQL_SELECT_COMPANY_AUTH, oParameters, CommandBehavior.CloseConnection, null);
                while (oReader.Read())
                {
                    szCompanyName = GetDBAccess().GetString(oReader, "comp_PRCorrTradestyle");
                    szTMFMAward = GetDBAccess().GetString(oReader, "comp_PRTMFMAward");
                    dtTMFMAwardDate = GetDBAccess().GetDateTime(oReader, "comp_PRTMFMAwardDate");
                    szIndustryType = GetDBAccess().GetString(oReader, "comp_PRIndustryType");
                    szPrimaryServiceCode = GetDBAccess().GetString(oReader, "PrimaryServiceCode");
                    iIntegrityID = GetDBAccess().GetInt32(oReader, "prra_IntegrityId");
                }
            }
            catch (Exception e)
            {
                GetLogger().LogError(e);
                return string.Empty;
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }

            if (szPrimaryServiceCode == null)
            {

                GetLogger().LogError(new ApplicationException("Unable to find a primary service code for Company ID " + iCompanyID.ToString() + "."));
                return string.Empty;
            }

            // Default to the general seal
            string szImageName = string.Empty;
            string szMemberType = string.Empty;
            string szMemberYear = string.Empty;
            string szCompanyPopupURL = string.Empty;
            string szHRef = string.Empty;

            if (szTMFMAward == "Y")
            {
                szMemberYear = "Since " + dtTMFMAwardDate.Year.ToString();
                szCompanyPopupURL = string.Format(Utilities.GetConfigValue("CompanyAuthPopupURL"), key);
                szHRef = "href=\"#\"";

                switch (szIndustryType)
                {
                    case "P":
                        szImageName = "seal_trade.svg";
                        szMemberType = "Trading Member";
                        break;
                    case "T":
                        szImageName = "seal_transport.svg";
                        szMemberType = "Transporation Member";
                        break;
                }
            }
            else
            {
                // If the user has a license key for this widget, they must have been a TMFM member at
                // some point.  They no longer have that award.  If their integrity rating is below
                // our threshold, then return nothing.  Otherwise display a generic seal.
                if (iIntegrityID < Utilities.GetIntConfigValue("CompanyAuthIntegrityIDThreshold", 5))
                {
                    return string.Empty;
                }
                else
                {
                    szImageName = "Seal_Member.gif";
                }
            }

            string szTemplate = null;
            using (StreamReader srTemplate = new StreamReader(Path.Combine(Utilities.GetConfigValue("TemplateFolder"), Utilities.GetConfigValue("CompanyAuthTemplateFile", "CompanyAuth.htm"))))
            {
                szTemplate = srTemplate.ReadToEnd();
            }

            string[] args = {szCompanyPopupURL,
                             Utilities.GetConfigValue("ImagesURL") + szImageName,
                             szCompanyName,
                             szMemberType,
                             szMemberYear,
                             szHRef};


            _oLogger.LogMessage("Returning");
            return string.Format(szTemplate, args);
        }

        [WebMethod]
        [ScriptMethod(UseHttpGet = true, ResponseFormat = ResponseFormat.Json)]
        public string GetAdsWidget(string key, string pageName, string adTypes, int maxCount, string pageRequestID, int webUserID)
        {
            try
            {
                return GetAds(key, pageName, adTypes, maxCount, pageRequestID, webUserID, false, "P");
            }
            catch (Exception eX)
            {
                GetLogger().LogError(eX);
                return string.Empty;
            }
        }

        [WebMethod]
        [ScriptMethod(UseHttpGet = true, ResponseFormat = ResponseFormat.Json)]
        public string GetAdsWidget(string key, string pageName, string adTypes, int maxCount, string pageRequestID, int webUserID, bool mobileDevice, string industryType)
        {
            try
            {
                return GetAds(key, pageName, adTypes, maxCount, pageRequestID, webUserID, mobileDevice, industryType);
            }
            catch (Exception eX)
            {
                GetLogger().LogError(eX);
                return string.Empty;
            }
        }


        [WebMethod]
        [ScriptMethod(UseHttpGet = true, ResponseFormat = ResponseFormat.Json)]
        public string GetKYCDAdsWidget(string key, int articleID, string placement, string pageRequestID, int webUserID)
        {
            try
            {
                return GetKYCDAds(key, articleID, placement, pageRequestID, webUserID);
            }
            catch (Exception eX)
            {
                GetLogger().LogError(eX);
                return string.Empty;
            }
        }

        [WebMethod]
        [ScriptMethod(UseHttpGet = true, ResponseFormat = ResponseFormat.Json)]
        public string GetKYCMobileAdsWidget(string key, string pageRequestID)
        {
            try
            {
                return GetKYCMobileAds(key, pageRequestID);
            }
            catch (Exception eX)
            {
                GetLogger().LogError(eX);
                return string.Empty;
            }
        }

        [WebMethod]
        [ScriptMethod(UseHttpGet = true, ResponseFormat = ResponseFormat.Json)]
        public int IncrementKYCPageView(string ArticleID)
        {
            try
            {
                _szRequestName = "IncrementKYCPageView";

                int iCompanyID = 0;
                if (!new KeyUtils().ValidateKey("IncrementKYCPageView", _szRequestName, out iCompanyID))
                {
                    return 0;
                }

                //Flag the commodity article as read
                string szEntityType = "WPPublicationArticle";

                return InsertPublicationArticleRead(Convert.ToInt32(ArticleID),
                                                0,
                                                szEntityType,
                                                HttpContext.Current.Request.Url.ToString(),
                                                "WPKYC");
            }
            catch (Exception eX)
            {
                GetLogger().LogError(eX);
                return 0;
            }
        }

        protected const string SQL_PRPUBLICATIONARTICLEREAD_INSERT =
                 "INSERT INTO PRPublicationArticleRead (prpar_PublicationArticleID, prpar_SourceID, prpar_SourceEntityType, prpar_TriggerPage, prpar_PublicationCode) " +
                  "VALUES ({0},{1},'{2}','{3}','{4}')";

        public int InsertPublicationArticleRead(int iArticleID,
                                                 int iSourceID,
                                                 string szSourceEntityType,
                                                 string szTriggerPage,
                                                 string szPublicationCode)
        {
            string szFormattedSQL = string.Format(SQL_PRPUBLICATIONARTICLEREAD_INSERT, iArticleID, iSourceID, szSourceEntityType, szTriggerPage.Replace("'", "''"), szPublicationCode) + ";SELECT SCOPE_IDENTITY();";
            object oID = GetDBAccess().ExecuteScalar(szFormattedSQL);
            return Convert.ToInt32(oID);
        }


        private const string SQL_AD_CAMPAIGN_LIST = " AND pradc_AdCampaignID IN ({0}) ";

        private List<int> _lCampaignIDs = null;
        private StringBuilder _sbAdvertisments = null;
        private AdUtils _adUtils = null;

        //private const string SQL_SELECT_ADS2 =
        //    @"SELECT TOP {0} pradch_CompanyID,
		      //  pradc_AdCampaignID,
		      //  pracf_FileName,
		      //  ISNULL(pradc_PeriodImpressionCount,0) AS pradc_PeriodImpressionCount,
		      //  pradc_TargetURL,
		      //  ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)) AS RandomNumber
        //    FROM vPRAdCampaign
        //    WHERE pradc_AdCampaignTypeDigital IN ({2})
		      //AND GETDATE() BETWEEN pradc_StartDate AND ISNULL(pradc_EndDate, DATEADD(day, 1, GETDATE()))
        //      AND pradc_CreativeStatus='A'
        //      AND pracf_FileTypeCode = '{4}'
	       //   {1}
        //    ORDER BY CASE WHEN pradch_CompanyID = {3} THEN 999999 ELSE ISNULL(pradc_PeriodImpressionCount, 0) END, RandomNumber";

        private const string SQL_SELECT_ADS =
            @"SELECT TOP {0} pradch_CompanyID,
		        pradc_AdCampaignID,
		        pracf_FileName,
		        ISNULL(pradc_PeriodImpressionCount,0) AS pradc_PeriodImpressionCount,
		        pradc_TargetURL,
		        ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)) AS RandomNumber,
                pracf_FileName_Disk
          FROM PRAdCampaignHeader WITH (NOLOCK)
              INNER JOIN PRAdCampaign WITH (NOLOCK) ON pradch_AdCampaignHeaderID = pradc_AdCampaignHeaderID
	          INNER JOIN (SELECT pracf_AdCampaignID, pracf_FileTypeCode, pracf_FileName, pracf_FileName_Disk, ROW_NUMBER() OVER (PARTITION BY pracf_AdCampaignID ORDER BY pracf_FileTypeCode {4}) as RowNum
                            FROM PRAdCampaignFile WITH (NOLOCK)) T1 ON pradc_AdCampaignID = pracf_AdCampaignID
					                                                AND RowNum = 1
         WHERE pradch_TypeCode IN ('D')
           AND pradc_AdCampaignTypeDigital IN ({2})
		      AND GETDATE() BETWEEN pradc_StartDate AND ISNULL(pradc_EndDate, DATEADD(day, 1, GETDATE()))
              AND pradc_CreativeStatus='A'
              AND pradc_IndustryType LIKE '{5}'
	          {1}
            ORDER BY CASE WHEN pradch_CompanyID = {3} THEN 999999 ELSE ISNULL(pradc_PeriodImpressionCount, 0) END, RandomNumber";

        private const string SQL_EXCLUDE_PAGE_ID =
            @"AND pradc_AdCampaignID NOT IN (SELECT DISTINCT pradcat_AdCampaignID FROM PRAdCampaignAuditTrail WITH (NOLOCK) WHERE pradcat_PageRequestID IS NOT NULL AND pradcat_PageRequestID='{0}' AND pradcat_CreatedDate >= '{1}')";

        public string GetAds(string key, string pageName, string campaignTypes, int maxCount, string pageRequestID, int webUserID, bool isPhone, string industryType)
        {
            _szRequestName = "GetAds";

            int iCompanyID = 0;
            if (!new KeyUtils().ValidateKey("GetAds", key, out iCompanyID))
                return string.Empty;

            _lCampaignIDs = new List<int>();
            _sbAdvertisments = new StringBuilder();

            if (webUserID == 0)
                _adUtils = new AdUtils(_oLogger, null);
            else
                _adUtils = new AdUtils(_oLogger, webUserID);

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("PageName", pageName));


            string szAdCampaignIDListFilter = string.Empty;
            if (!string.IsNullOrEmpty(pageRequestID))
                szAdCampaignIDListFilter = string.Format(SQL_EXCLUDE_PAGE_ID, pageRequestID, DateTime.Today.ToString());

            string adTypeINClause = string.Empty;
            string[] types = campaignTypes.Split(',');
            foreach (string adType in types)
            {
                // Check for sql injection
                char firstCharacter = adType.ToCharArray()[0];
                if (!char.IsLetterOrDigit(firstCharacter))
                    return String.Empty;

                if (adType.Length > 20)
                    return String.Empty;


                if (adTypeINClause.Length > 0)
                    adTypeINClause += ",";
                adTypeINClause += "'" + adType + "'";
            }

            if (string.IsNullOrWhiteSpace(industryType))
                return string.Empty;

            if (industryType.Length > 1)
                return string.Empty;

            string industryClause = $"%,{industryType},%";


            // The sorting is going to help us here.  We use sorting to select
            // the correct image when isPhone.  If the ad campaign does not have
            // a mobile image, then display the regular image instead.
            string imageSort = "ASC";
            if (isPhone)
                imageSort = "DESC";

            // Go generate the ads.
            string szSQL = string.Format(SQL_SELECT_ADS,
                                        maxCount,
                                        szAdCampaignIDListFilter,
                                        adTypeINClause,
                                        Utilities.GetIntConfigValue("BBISAdCompanyID", 0),
                                        imageSort,
                                        industryClause);

            using (IDbConnection oConn = GetDBAccess().Open())
            {
                IDbTransaction oTrans = oConn.BeginTransaction();
                try
                {
                    List<IInternalAdRec> lstAds = GenerateAds(szSQL, oParameters, campaignTypes, pageRequestID, oTrans);

                    int iAdCount = 0;
                    int iAdAuditTrailID = 0;

                    foreach (IInternalAdRec oAd in lstAds)
                    {
                        iAdCount++;
                        iAdAuditTrailID = _adUtils.InsertAdAuditTrail(oAd.AdCampaignID,
                                                                        oAd.EligiblePageID,
                                                                        iAdCount,
                                                                        null,
                                                                        0,
                                                                        pageRequestID,
                                                                        oTrans);
                        // Go build the Ad HTML.
                        if ((!string.IsNullOrEmpty(oAd.TargetUrl)) &&
                            (oAd.TargetUrl.ToLower().StartsWith("mailto:")))
                        {
                            _sbAdvertisments.Append(BuildAd_MailTo(oAd.AdCampaignID,
                                                            iAdAuditTrailID,
                                                            oAd.FileName_Disk,
                                                            oAd.TargetUrl,
                                                            oTrans));
                        }
                        else
                        {
                            _sbAdvertisments.Append(BuildAd(oAd.AdCampaignID,
                                                            iAdAuditTrailID,
                                                            oAd.FileName_Disk,
                                                            oAd.TargetUrl,
                                                            oTrans));
                        }
                    }

                    // Make sure the impression counts are updated.
                    _adUtils.UpdateImpressionCount(_lCampaignIDs, oTrans);
                    oTrans.Commit();
                    return _sbAdvertisments.ToString();
                }
                catch (Exception)
                {
                    oTrans.Rollback();
                    throw;
                }
            }
        }

        private const string SQL_SELECT_KYCD_ADS =
            @" SELECT TOP 1 pradch_CompanyID,
		        pradc_AdCampaignID,
		        pracf_FileName,
		        0 [pradc_PeriodImpressionCount],
		        pradc_TargetURL,
		        ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)) AS RandomNumber,
                pracf_FileName_Disk
            FROM vPRAdCampaignKYC
            WHERE
                prkycc_ArticleID = @ArticleID
                AND pradc_Placement = @Placement
                AND pracf_FileTypeCode = 'DI'
		        AND GETDATE() BETWEEN pradc_StartDate AND ISNULL(pradc_EndDate, DATEADD(day, 1, GETDATE()))";

        public string GetKYCDAds(string key, int articleID, string placement, string pageRequestID, int webUserID)
        {
            _szRequestName = "GetKYCDAds";

            int iCompanyID = 0;
            if (!new KeyUtils().ValidateKey("GetAds", key, out iCompanyID))
            {
                return string.Empty;
            }

            _lCampaignIDs = new List<int>();
            _sbAdvertisments = new StringBuilder();

            if (webUserID == 0)
                _adUtils = new AdUtils(_oLogger, null);
            else
                _adUtils = new AdUtils(_oLogger, webUserID);

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("ArticleID", articleID));
            oParameters.Add(new ObjectParameter("Placement", placement));

            using (IDbConnection oConn = GetDBAccess().Open())
            {
                IDbTransaction oTrans = oConn.BeginTransaction();
                try
                {
                    // Go generate the ads.
                    List<IInternalAdRec> lstAds = GenerateAds(SQL_SELECT_KYCD_ADS, oParameters, string.Empty, pageRequestID, oTrans);

                    int iAdCount = 0;
                    int iAdAuditTrailID = 0;

                    foreach (IInternalAdRec oAd in lstAds)
                    {
                        iAdCount++;
                        iAdAuditTrailID = _adUtils.InsertAdAuditTrail(oAd.AdCampaignID,
                                                                        oAd.EligiblePageID,
                                                                        iAdCount,
                                                                        null,
                                                                        0,
                                                                        pageRequestID,
                                                                        oTrans);

                        // Go build the Ad HTML.
                        _sbAdvertisments.Append(BuildAd(oAd.AdCampaignID,
                                                        iAdAuditTrailID,
                                                        oAd.FileName_Disk,
                                                        oAd.TargetUrl,
                                                        oTrans));
                    }

                    // Make sure the impression counts are updated.
                    _adUtils.UpdateImpressionCount(_lCampaignIDs, oTrans);
                    oTrans.Commit();
                    return _sbAdvertisments.ToString();
                }
                catch
                {
                    oTrans.Rollback();
                    throw;
                }
            }
        }

        private const string SQL_SELECT_KYC_MOBILE_ADS =
            @" SELECT pradch_CompanyID,
	                pradc_AdCampaignID,
	                pracf_FileName,
	                0 [pradc_PeriodImpressionCount],
	                pradc_TargetURL,
	                ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)) AS RandomNumber,
                    pracf_FileName_Disk
                FROM PRAdCampaignHeader WITH (NOLOCK)
	                INNER JOIN PRAdCampaign WITH (NOLOCK) ON pradch_AdCampaignHeaderID = pradc_AdCampaignHeaderID
	                INNER JOIN PRAdCampaignFile WITH (NOLOCK) ON pradc_AdCampaignID = pracf_AdCampaignID
                WHERE
	                pradch_TypeCode = 'KYC'
	                AND pracf_FileTypeCode = 'DI'
	                AND GETDATE() BETWEEN pradc_StartDate AND ISNULL(pradc_EndDate, DATEADD(day, 1, GETDATE()))
	                AND pradc_KYCMobileHomeDisplay='Y'
                ORDER BY RandomNumber";

        public string GetKYCMobileAds(string key, string pageRequestID)
        {
            _szRequestName = "GetKYCMobileAds";

            int iCompanyID = 0;
            if (!new KeyUtils().ValidateKey("GetAds", key, out iCompanyID))
            {
                return string.Empty;
            }

            _lCampaignIDs = new List<int>();
            _sbAdvertisments = new StringBuilder();

            _adUtils = new AdUtils(_oLogger, null);

            ArrayList oParameters = new ArrayList();

            using (IDbConnection oConn = GetDBAccess().Open())
            {
                IDbTransaction oTrans = oConn.BeginTransaction();
                try
                {
                    // Go generate the ads.
                    List<IInternalAdRec> lstAds = GenerateAds(SQL_SELECT_KYC_MOBILE_ADS, oParameters, string.Empty, pageRequestID, oTrans);

                    int iAdCount = 0;
                    int iAdAuditTrailID = 0;
                    bool bFirst = true;

                    foreach (IInternalAdRec oAd in lstAds)
                    {
                        iAdCount++;
                        iAdAuditTrailID = _adUtils.InsertAdAuditTrail(oAd.AdCampaignID,
                                                                        oAd.EligiblePageID,
                                                                        iAdCount,
                                                                        null,
                                                                        0,
                                                                        pageRequestID,
                                                                        oTrans);

                        // Go build the Ad HTML.
                        _sbAdvertisments.Append(BuildMobileAd(oAd.AdCampaignID,
                                                        iAdAuditTrailID,
                                                        oAd.FileName_Disk,
                                                        oAd.TargetUrl,
                                                        oTrans,
                                                        bFirst));

                        bFirst = false;
                    }

                    // Make sure the impression counts are updated.
                    _adUtils.UpdateImpressionCount(_lCampaignIDs, oTrans);
                    oTrans.Commit();
                    return _sbAdvertisments.ToString();
                }
                catch
                {
                    oTrans.Rollback();
                    throw;
                }
            }
        }

        protected class IInternalAdRec
        {
            public IInternalAdRec() { }
            public IInternalAdRec(int iAdCampaignID, string szFileName, string szFileName_Disk, int iEligiblePageID, string szTargetUrl)
            {
                AdCampaignID = iAdCampaignID;
                FileName = szFileName;
                FileName_Disk = szFileName_Disk;
                EligiblePageID = iEligiblePageID;
                TargetUrl = szTargetUrl;
            }

            public int AdCampaignID { get; set; }
            public string FileName { get; set; }
            public string FileName_Disk { get; set; }
            public int EligiblePageID { get; set; }
            public string TargetUrl { get; set; }
        }

        protected List<IInternalAdRec> GenerateAds(string szSQL,
                                ArrayList oParameters,
                                string campaignType,
                                string pageRequestID,
                                IDbTransaction oTrans)
        {
            List<IInternalAdRec> lstAds = new List<IInternalAdRec>();

            IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.Default, oTrans);
            try
            {
                while (oReader.Read())
                {
                    if ((campaignType != "LPA") &&
                        (oReader[2] == DBNull.Value))
                    {
                        GetLogger().LogError(new ApplicationException("Advertisement found without an image for company: " + oReader.GetInt32(0).ToString()));
                        continue;
                    }

                    // Add the audit trail first beacause we need it to
                    // build any hyperlinks.
                    // have to do this outside the ExecuteReader() loop since it is forward only and we need the same transaction
                    // so using custom List<> to use outside this ExecuteReader()
                    string targetURL = null;
                    if (oReader[4] != DBNull.Value)
                        targetURL = oReader.GetString(4);

                    IInternalAdRec oAd = new IInternalAdRec(oReader.GetInt32(1), oReader.GetString(2), oReader.GetString(6), oReader.GetInt32(3), targetURL);
                    lstAds.Add(oAd);

                    // Add the campaign ID to a list so we can update
                    // the impression count later.
                    _lCampaignIDs.Add(oAd.AdCampaignID);
                }

                return lstAds;
            }
            finally
            {
                oReader.Close();
            }
        }

        const string SQL_GET_AD_CAMPAIGN_INFO = 
            @"SELECT comp_CompanyID, comp_Name, pradc_AdCampaignType, prcm_FullName FROM PRAdCampaign WITH (NOLOCK) 
                     INNER JOIN Company WITH (NOLOCK) ON Comp_CompanyId = pradc_CompanyID
                     LEFT OUTER JOIN PRKYCCommodity WITH (NOLOCK) ON prkycc_KYCCommodityID = pradc_KYCCommodityID
                     LEFT OUTER JOIN PRCommodity WITH (NOLOCK) ON prkycc_CommodityID = prcm_CommodityId
               WHERE pradc_AdCampaignID = @AdCampaignID";

        private void GetAdCampaignInfo(int AdCampaignID, IDbTransaction oTrans, out int iCompanyID, out string szCompanyName, out string szAdCampaignType, out string szCommodityName)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("AdCampaignID", AdCampaignID));

            using (IDataReader oReader = GetDBAccess().ExecuteReader(SQL_GET_AD_CAMPAIGN_INFO,
                                                                  oParameters,
                                                                  CommandBehavior.Default, oTrans))
            {
                szCompanyName = "";
                iCompanyID = 0;
                szAdCampaignType = "";
                szCommodityName = "";

                oReader.Read();

                if (!oReader.IsDBNull(0))
                    iCompanyID = oReader.GetInt32(0); // comp_CompanyID

                if (!oReader.IsDBNull(1))
                    szCompanyName = oReader.GetString(1); //comp_name

                if (!oReader.IsDBNull(2))
                    szAdCampaignType = oReader.GetString(2); //pradc_AdCampaignType

                if (!oReader.IsDBNull(3))
                    szCommodityName = oReader.GetString(3); //prcm_FullName
            }
        }

        private string GetImageHTMLLink(int iAdCampaignID, string szAdImageName, IDbTransaction oTrans)
        {
            int iCompanyID;
            string szCompanyName;
            string szAdCampaignType;
            string szCommodityName;
            GetAdCampaignInfo(iAdCampaignID, oTrans, out iCompanyID, out szCompanyName, out szAdCampaignType, out szCommodityName);

            return "<img src=\"" + Utilities.GetConfigValue("AdImageRootURL", "Campaigns/") + szAdImageName + $"\" border=\"0\" style=\"margin-bottom:10px\" alt=\"BB #: {iCompanyID} {szCompanyName} {szCommodityName}\">";
        }


        private const string AD_LINK = "<a href=\"{0}?AdCampaignID={1}&AdAuditTrailID={2}\" {4} >{3}</a>";
        private string BuildAd(int iAdCampaignID, int iAdAuditTrailID, object oAdImageName, string szTargetURL, IDbTransaction oTrans)
        {
            string szTarget = string.Empty;

            // If a target URL is specified, be sure to open the
            // Ad in a new window
            if (!string.IsNullOrEmpty(szTargetURL))
            {
                szTarget = "target=_blank";
            }

            string szAdImageHTML = GetImageHTMLLink(iAdCampaignID, (string)oAdImageName, oTrans);

            if (string.IsNullOrEmpty(szTargetURL))
            {
                return szAdImageHTML;
            }

            object[] oArgs = {Utilities.GetConfigValue("AdClickURL", "https://qaapps.bluebookservices.com/BBOS/AdClick.aspx"),
                                    iAdCampaignID,
                                    iAdAuditTrailID,
                                    szAdImageHTML,
                                    szTarget};

            return string.Format(AD_LINK, oArgs);
        }

        private const string AD_LINK_MAILTO = "<a href=\"{0}\" {2} >{1}</a>";

        private string BuildAd_MailTo(int iAdCampaignID, int iAdAuditTrailID, object oAdImageName, string szTargetURL, IDbTransaction oTrans)
        {
            string szTarget = string.Empty;

            // If a target URL is specified, be sure to open the
            // Ad in a new window
            if (!string.IsNullOrEmpty(szTargetURL))
            {
                szTarget = "target=_blank";
            }

            string szAdImageHTML = GetImageHTMLLink(iAdCampaignID, (string)oAdImageName, oTrans);

            if (string.IsNullOrEmpty(szTargetURL))
            {
                return szAdImageHTML;
            }


            object[] oArgs = {szTargetURL,
                                    szAdImageHTML,
                                    szTarget};

            return string.Format(AD_LINK_MAILTO, oArgs);

        }

        private const string MOBILE_AD_LINK = "<div class='item {4}' data-interval='3000'><a href='{0}?AdCampaignID={1}&AdAuditTrailID={2}' target='_blank' rel='noopener'>{3}</a></div>";

        private string BuildMobileAd(int iAdCampaignID, int iAdAuditTrailID, object oAdImageName, string szTargetURL, IDbTransaction oTrans, bool bActive=false)
        {
            string szAdImageHTML = GetImageHTMLLink(iAdCampaignID, (string)oAdImageName, oTrans);

            string szActive = "";
            if (bActive)
                szActive = " active";

            object[] oArgs = {Utilities.GetConfigValue("AdClickURL", "https://qaapps.bluebookservices.com/BBOS/AdClick.aspx"),
                                    iAdCampaignID,
                                    iAdAuditTrailID,
                                    szAdImageHTML,
                                    szActive
                                };

            return string.Format(MOBILE_AD_LINK, oArgs);
        }


        protected const string SQL_QUICKFIND_AUTOCOMPLETE =
            @"SELECT DISTINCT TOP {0} comp_CompanyID, comp_PRCorrTradestyle, ISNULL(comp_PRLegalName, '') comp_PRLegalName, CityStateCountryShort, comp_PRType, comp_PRLocalSource, prce_WordPressSlug, 1 as Seq
                FROM vPRBBOSCompanyList
                     INNER JOIN PRCompanySearch WITH (NOLOCK) on comp_CompanyID = prcse_CompanyID
                     LEFT OUTER JOIN PRCompanyAlias WITH (NOLOCK) ON comp_CompanyID = pral_CompanyID
               WHERE ({1})
                 AND {2}
                 AND comp_PRListingStatus IN ('L','H','LUV', 'N5')
            ORDER BY comp_PRCorrTradestyle, comp_PRType DESC";

        /// <summary>
        /// Returns the auto-complete list for the QuickFind control.
        /// </summary>
        /// <param name="prefixText"></param>
        /// <param name="count"></param>
        /// <param name="contextKey">Industry Type</param>
        /// <returns></returns>
        [WebMethod(EnableSession = true)]
        public string[] GetQuickFindCompletionList(string prefixText, int count, string contextKey)
        {
            char[] acDelimiter = { '|' };
            string[] aszTokens = prefixText.Split(acDelimiter);

            string szWhere = string.Empty;

            IList lParms = new ArrayList();
            foreach (string szToken in aszTokens)
            {
                if (szWhere.Length > 0)
                {
                    szWhere += " OR ";
                }

                string szCleanToken = SearchCriteriaBase.CleanString(szToken);
                string szStartsWith = "StartsWith" + lParms.Count.ToString();
                lParms.Add(new ObjectParameter(szStartsWith, szCleanToken + "%"));

                szWhere += "(prcse_NameMatch LIKE @" + szStartsWith + " OR ISNULL(prcse_LegalNameMatch, '') LIKE @" + szStartsWith + " OR prcse_CorrTradestyleMatch LIKE @" + szStartsWith + " OR pral_NameAlphaOnly LIKE @" + szStartsWith + ")";
            }

            string szIndustryClause = null;
            if (contextKey == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                szIndustryClause = "comp_PRIndustryType = 'L'";
            }
            else if (contextKey == GeneralDataMgr.INDUSTRY_TYPE_WINEGRAPE)
            {
                szIndustryClause = "comp_PRIndustryType = 'W'";
            }
            else
            {
                szIndustryClause = "comp_PRIndustryType <> 'L'";
            }

            szIndustryClause += " AND comp_PRLocalSource IS NULL";


            object[] args = { count, szWhere, szIndustryClause };
            using (IDataReader oReader = GetDBAccess().ExecuteReader(string.Format(SQL_QUICKFIND_AUTOCOMPLETE, args),
                                                                  lParms,
                                                                  CommandBehavior.CloseConnection,
                                                                  null))
            {
                List<String> lReturnList = new List<string>();
                while (oReader.Read())
                {
                    string type = oReader.GetString(4);
                    lReturnList.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(oReader.GetString(1) + "|" + oReader.GetString(2) + "|" + type + "|" + oReader.GetString(3), oReader.GetString(6)));
                }

                return lReturnList.ToArray();
            }
        }

        #region Helper Methods

        /// <summary>
        /// Returns an isntance of a DBAccess
        /// </summary>
        /// <returns></returns>
        protected IDBAccess GetDBAccess()
        {
            if (_oDBAccess == null)
            {
                _oDBAccess = DBAccessFactory.getDBAccessProvider();
                _oDBAccess.Logger = GetLogger();
            }
            return _oDBAccess;
        }

        /// <summary>
        /// Returns an instance of a Logger
        /// </summary>
        /// <returns></returns>
        protected ILogger GetLogger()
        {
            if (_oLogger == null)
            {
                _oLogger = LoggerFactory.GetLogger();
                _oLogger.RequestName = _szRequestName;
            }

            return _oLogger;
        }



        #endregion Helper Methods
    }
}
