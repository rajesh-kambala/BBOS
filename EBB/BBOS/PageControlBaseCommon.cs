/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2017-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: PageControlBaseCommon
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using PRCo.EBB.BusinessObjects;
using TSI.DataAccess;
using System.Data;
using System.Collections;
using TSI.BusinessObjects;
using System.Web;
using PRCo.EBB.Util;
using System.Threading;
using System.Web.UI.WebControls;
using System.Web.UI;
using TSI.Utils;
using System.Web.UI.DataVisualization.Charting;
using System.Globalization;
using System.Text;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Drawing;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Provides the common functionality needed by the user controls
    /// </summary>
    public class PageControlBaseCommon
    {
        /// <summary>
        /// Prefix used to mark reference data in the cache
        /// </summary>
        public const string REF_DATA_PREFIX = "RefData";
        public const string REF_DATA_NAME = REF_DATA_PREFIX + "_{0}_{1}";

        public const string JAVASCRIPT_VOID = "javascript:void(0);";

        public const string EMPTY_BLUEPRINT_EDITION_TEXT = "a:1:{i:0;a:1:{s:4:\"date\";s:0:\"\";}}"; //DEFECT 4584

        /// <summary>
        /// Data manager instance for our lookup codes.
        /// </summary>
        static protected PageBase _oPageBase = new PageBase();

        protected const string SQL_COMPANY_HEADER_SELECT =
            @"SELECT comp_PRCorrTradestyle, CityStateCountryShort, comp_PRListedDate, comp_PRListingStatus, comp_PRIndustryType, 
                    dbo.ufn_HasNote({1}, {2}, comp_CompanyID, 'C') As HasNote, 
                    comp_PRLastPublishedCSDate, comp_PRType, comp_PRHQID, 
                    comp_PRPublishPayIndicator, prcpi_PayIndicator, prcpi_CompanyPayIndicatorID, 
                    
                    compRating.prra_AssignedRatingNumerals, 
                    compRating.prra_RatingLine, compRating.prra_Date AS Comp_prra_Date, compRating.prcw_Name, compRating.prin_Name, compRating.prpy_Name,
                    hqRating.prra_RatingLine As HQRatingLine,  hqRating.prra_Date AS HQ_prra_Date, hqRating.prcw_Name as HQ_prcw_Name, hqRating.prin_Name AS HQ_prin_Name, hqRating.prpy_Name AS HQ_prpy_Name,

                    prbs_BBScore, prbs_PRPublish, comp_PRLocalSource, comp_PRDelistedDate,
                    comp_PRTMFMAward,
                    comp_PRTMFMAwardDate,
                    prst_StateID,
                    prst_CountryID,
					prcp_Organic,
					prcp_FoodSafetyCertified,
                    comp_PRPublishBBScore,
                    comp_PRFinancialStatementDate,
                    OnWatchdogList,
                    dbo.ufn_HasCSG(comp_CompanyID) As HasCSG,
                    prbs_Model,

					AveIntegrity,       
					TradeReportCount,
                    IndustryAveIntegrity,
                    dbo.ufn_GetListingBankBlock2(comp_CompanyID,NULL,NULL) as Bank,
                    prcp_SalvageDistressedProduce

            FROM Company WITH (NOLOCK) 
                    INNER JOIN vPRLocation WITH (NOLOCK) ON comp_PRListingCityID = prci_CityID 
                    LEFT OUTER JOIN vPRCurrentRating compRating WITH (NOLOCK) ON comp_CompanyID = compRating.prra_CompanyID 
                    LEFT OUTER JOIN vPRCurrentRating hqRating WITH (NOLOCK) ON comp_PRHQID = hqRating.prra_CompanyID 
                    LEFT OUTER JOIN PRCompanyPayIndicator WITH (NOLOCK) ON comp_CompanyID = prcpi_CompanyID AND prcpi_Current='Y' 
                    LEFT OUTER JOIN PRBBScore WITH (NOLOCK) ON comp_CompanyID = prbs_CompanyID AND prbs_Current='Y' 
                    LEFT OUTER JOIN PRCompanyProfile WITH (NOLOCK) ON comp_CompanyID =prcp_CompanyID
	                LEFT OUTER JOIN (SELECT DISTINCT prwuld_AssociatedID, 'Y' As OnWatchdogList
                                        FROM PRWebUserList WITH (NOLOCK) 
                                            INNER JOIN PRWebUserListDetail WITH (NOLOCK) ON prwucl_WebUserListID = prwuld_WebUserListID AND prwuld_Deleted IS NULL 
                                        WHERE ((prwucl_HQID = {2} AND prwucl_IsPrivate IS NULL) 
                                            OR (prwucl_WebUserID={1} AND prwucl_IsPrivate = 'Y'))) tblWD ON prwuld_AssociatedID = comp_CompanyID
                    LEFT OUTER JOIN (SELECT prtr_SubjectID, AVG(CAST(prin_Weight as decimal(6,3))) as AveIntegrity,       
                                            COUNT(prin_Weight) as TradeReportCount,
                                            CASE WHEN capt_US IS NULL THEN '0' ELSE capt_US END AS IndustryAveIntegrity
                                        FROM PRTradeReport WITH (NOLOCK)
										    INNER JOIN PRIntegrityRating WITH (NOLOCK) ON prtr_IntegrityId = prin_IntegrityRatingId
                                            INNER JOIN Company C1 WITH (NOLOCK) ON Comp_CompanyId = prtr_SubjectId
                                            LEFT OUTER JOIN custom_captions WITH (NOLOCK) ON capt_family = 'IndustryAverageRatings_'  + C1.comp_PRIndustryType AND capt_code = 'IntegrityAverage_Current'
                                        WHERE prtr_Date >= DATEADD(month, -6, GETDATE())
										    AND prtr_SubjectID = comp_CompanyID
                                            AND prtr_Duplicate IS NULL
                                            AND prtr_ExcludeFromAnalysis IS NULL
                                        GROUP BY prtr_SubjectID, capt_us
								    ) tblTR ON prtr_SubjectID = comp_CompanyID
            WHERE comp_CompanyID={0}";

        protected const string SQL_COMPANY_INCORPORATION_DATE_STATE_V2 =
            @"SELECT TOP 1 
				     prbe_CompanyID, 
				     prbe_BusinessEventTypeId, 
				     prbe_DisplayedEffectiveDate AS BusinessStartDate,
				     prst_State AS BusinessStartState,
				     MIN(prbe_EffectiveDate) prbe_EffectiveDate,
				     [Priority]= CASE WHEN prbe_BusinessEventTypeId=9 THEN 1 
					  		          WHEN prbe_BusinessEventTypeId=42 THEN 2 
								      WHEN prbe_BusinessEventTypeId=8 THEN 3
							     END
	           FROM PRBusinessEvent WITH(NOLOCK)
		            LEFT OUTER JOIN PRState WITH (NOLOCK) ON prbe_StateID = prst_StateID
              WHERE prbe_BusinessEventTypeId IN (9, 42, 8)
                AND prbe_CompanyId={0}
           GROUP BY prbe_CompanyID, prbe_BusinessEventTypeId, prbe_EffectiveDate, prbe_DisplayedEffectiveDate, prst_State, prbe_DetailedType
           ORDER BY prbe_CompanyID, Priority ASC, prbe_EffectiveDate ASC";

        protected const string SQL_SELECT_COMPANY =
              @"SELECT TOP 1 *, 
                    ISNULL(dbo.ufn_GetCustomCaptionValue('prcw_Name', prcw_Name, '{0}'), '') As CreditWorthRatingDescription,
                    ISNULL(dbo.ufn_GetCustomCaptionValue('prrn_Name_Insight', prcw_Name, '{0}'), '') As CreditWorthRatingInsight
                FROM vPRBBOSCompany WITH (NOLOCK)
               WHERE comp_CompanyID=@comp_CompanyID";

        public const string COMPANY_DATA_KEY = "CompanyHeader_CompanyData";
        public const string COMPANY_DATA_KEY_HQ = "CompanyHeader_CompanyData_HQ";

        public const string COMPANY_NEWS_DATA_KEY = "CompanyNews_Data";

        /// <summary>
        /// Replacement for old LoadCompanyHeader and session logic
        /// When converting from old code, if you run into any Session errors look here
        /// </summary>
        public static CompanyData GetCompanyData(string szCompanyID, IPRWebUser oWebUser, IDBAccess dbAccess, GeneralDataMgr objectMgr, bool bHQ = false)
        {
            // Let's make sure we have a valid company ID since we're
            // embedding it in the SQL.  The user could tamper with the
            // query string.
            int companyID = 0;
            if (!Int32.TryParse(szCompanyID, out companyID))
                throw new ApplicationException(string.Format("Invalid company ID specified: {0}", szCompanyID == null ? "NULL" : szCompanyID));

            string szCompanyDataKey = COMPANY_DATA_KEY;
            if (bHQ)
                szCompanyDataKey = COMPANY_DATA_KEY_HQ;

            CompanyData companyData = null;

            // See if we have our values cached
            if (HttpContext.Current.Session[szCompanyDataKey] != null)
            {
                companyData = (CompanyData)HttpContext.Current.Session[szCompanyDataKey];
                if (companyData.szCompanyID == szCompanyID)
                    return companyData;
            }

            // If we're here, create a new object for our data.
            companyData = new CompanyData();

            // If not, query for them.
            string szSQL = string.Format(SQL_COMPANY_HEADER_SELECT, szCompanyID, oWebUser.prwu_WebUserID, oWebUser.prwu_HQID);
            using (IDataReader oReader = dbAccess.ExecuteReader(szSQL, CommandBehavior.CloseConnection))
            {
                if (oReader.Read())
                {
                    companyData.szCompanyID = szCompanyID;
                    companyData.szCompanyName = dbAccess.GetString(oReader, 0);
                    companyData.szLocation = dbAccess.GetString(oReader, 1);
                    companyData.dtListedDate = dbAccess.GetDateTime(oReader, "comp_PRListedDate");
                    companyData.dtDelistedDate = dbAccess.GetDateTime(oReader, "comp_PRDelistedDate");
                    companyData.szListingStatus = dbAccess.GetString(oReader, 3);
                    companyData.szIndustryType = dbAccess.GetString(oReader, 4);
                    companyData.bHasNote = UIUtils.GetBool(oReader["HasNote"]);
                    companyData.bHasCSG = UIUtils.GetBool(oReader["HasCSG"]);
                    companyData.bIsCertifiedOrganic = UIUtils.GetBool(oReader["prcp_Organic"]);
                    companyData.bIsFoodSafetyCertified = UIUtils.GetBool(oReader["prcp_FoodSafetyCertified"]);
                    companyData.dtLastChanged = dbAccess.GetDateTime(oReader, "comp_PRLastPublishedCSDate");
                    companyData.szCompanyType = dbAccess.GetString(oReader, 7);
                    companyData.iHQID = dbAccess.GetInt32(oReader, "comp_PRHQID");

                    if (oReader["prbs_BBScore"] != DBNull.Value)
                    {
                        companyData.szBBScore = Convert.ToInt32(oReader["prbs_BBScore"]).ToString("###");
                        GetBBScoreRiskData(companyData, Convert.ToInt32(companyData.szBBScore));
                    }
                    if (oReader["prbs_Model"] != DBNull.Value)
                        companyData.szBBScoreModel = Convert.ToString(oReader["prbs_Model"]);
                    else
                        companyData.szBBScoreModel = "";

                    companyData.bBBScorePublished = objectMgr.TranslateFromCRMBool(oReader["prbs_PRPublish"]);
                    companyData.bCompBBScorePublished = objectMgr.TranslateFromCRMBool(oReader["comp_PRPublishBBScore"]);
                    companyData.bLocalSource = objectMgr.TranslateFromCRMBool(oReader["comp_PRLocalSource"]);
                    companyData.iRegionID = dbAccess.GetInt32(oReader, "prst_StateID");
                    companyData.iCountryID = dbAccess.GetInt32(oReader, "prst_CountryID");
                    companyData.bPRTMFMAward = objectMgr.TranslateFromCRMBool(oReader["comp_PRTMFMAward"]);
                    companyData.dtPRTMFMAwardDate = dbAccess.GetDateTime(oReader, "comp_PRTMFMAwardDate");

                    if (companyData.szIndustryType != GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                    {
                        // If this is a branch and does not have a rating line,
                        // query for the HQ's rating line
                        if ((companyData.szCompanyType == "B") &&
                            ((oReader["prra_RatingLine"] == DBNull.Value) ||
                             (string.IsNullOrEmpty(Convert.ToString(oReader["prra_RatingLine"])))))
                        {
                            companyData.szRatingLine = dbAccess.GetString(oReader, "HQRatingLine");
                            companyData.szPRCW_Name = dbAccess.GetString(oReader, "HQ_prcw_Name");
                            companyData.szPRIN_Name = dbAccess.GetString(oReader, "HQ_prin_Name");
                            companyData.szPRPY_Name = dbAccess.GetString(oReader, "HQ_prpy_Name");
                            companyData.szRatingLineLabel = Resources.Global.HQRating; // "HQ Rating";
                            companyData.dtPRRA_DateTime = dbAccess.GetDateTime(oReader, "HQ_prra_Date");
                        }
                        else
                        {
                            companyData.szRatingLine = dbAccess.GetString(oReader, "prra_RatingLine");
                            companyData.szPRCW_Name = dbAccess.GetString(oReader, "prcw_Name");
                            companyData.szPRIN_Name = dbAccess.GetString(oReader, "prin_Name");
                            companyData.szPRPY_Name = dbAccess.GetString(oReader, "prpy_Name");
                            companyData.szRatingLineLabel = Resources.Global.Rating; // "Rating";
                            companyData.dtPRRA_DateTime = dbAccess.GetDateTime(oReader, "Comp_prra_Date");
                        }

                        GetRatingData(companyData, companyData.szPRIN_Name);
                    }
                    else
                    {
                        companyData.szRatingNumerals = dbAccess.GetString(oReader, "prra_AssignedRatingNumerals");
                        companyData.bPublishPayIndicator = objectMgr.TranslateFromCRMBool(oReader["comp_PRPublishPayIndicator"]);

                        if (companyData.bPublishPayIndicator) //objectMgr.TranslateFromCRMBool(oReader["comp_PRPublishPayIndicator"]))
                        {
                            companyData.szPayIndicator = dbAccess.GetString(oReader, "prcpi_PayIndicator");
                        }

                        companyData.iCompanyPayIndicatorID = dbAccess.GetInt32(oReader, "prcpi_CompanyPayIndicatorID");
                    }

                    companyData.dtPRFinancialStatementDate = dbAccess.GetDateTime(oReader, "comp_PRFinancialStatementDate");
                    companyData.bOnWatchdogList = objectMgr.TranslateFromCRMBool(oReader["OnWatchdogList"]);

                    //Trade Activity (X Rating)
                    companyData.decAveIntegrity = dbAccess.GetDecimal(oReader, "AveIntegrity");
                    companyData.iTradeReportCount = dbAccess.GetInt32(oReader, "TradeReportCount");
                    companyData.szIndustryAveIntegrity = dbAccess.GetString(oReader, "IndustryAveIntegrity");
                    GetTradeActivityInsightData(companyData, companyData.decAveIntegrity);

                    //Pay Description
                    GetPayDescriptionInsightData(companyData, companyData.szPRPY_Name);

                    //Other Information
                    companyData.szBank = dbAccess.GetString(oReader, "Bank");
                    GetARDetails(companyData, oWebUser);
                    companyData.szSalvageDistressedProduce = dbAccess.GetString(oReader, "prcp_SalvageDistressedProduce");
                    GetLicenseData(companyData);
                    GetVolumeData(companyData);
                    GetBranchData(companyData, oWebUser);
                    GetAffiliationData(companyData, oWebUser);
                }
            }

            GetBusinessStartData(companyData, szCompanyID, dbAccess);
            // If this is a branch and we don't have our business start
            // data, query for the HQ's.
            if ((companyData.szCompanyType == "B") &&
                (string.IsNullOrEmpty(companyData.BusinessStartDate)))
            {
                GetBusinessStartData(companyData, companyData.iHQID.ToString(), dbAccess);
            }

            //vPRBBOSCompany data
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("comp_CompanyID", szCompanyID));
            szSQL = string.Format(SQL_SELECT_COMPANY, oWebUser.prwu_Culture);

            using (IDataReader oReader = dbAccess.ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null))
            {
                if (oReader.Read())
                {
                    companyData.szPreparedName = dbAccess.GetString(oReader, "PreparedName");
                    companyData.bSuppressLinkedInWidget = objectMgr.TranslateFromCRMBool(oReader["comp_PRHideLinkedInWidget"]);
                    companyData.szWebAddress = dbAccess.GetString(oReader, "emai_PRWebAddress");
                    companyData.szEmailAddress = dbAccess.GetString(oReader, "Email");
                    companyData.szTollFreePhone = dbAccess.GetString(oReader, "TollFree");
                    companyData.szPhone = dbAccess.GetString(oReader, "Phone");
                    companyData.szFax = dbAccess.GetString(oReader, "Fax");
                    companyData.szIndustryTypeName = dbAccess.GetString(oReader, "IndustryType");
                    companyData.szListingStatusName = dbAccess.GetString(oReader, "ListingStatus");
                    companyData.szIsHQRating = dbAccess.GetString(oReader, "IsHQRating");
                    companyData.iRatingID = dbAccess.GetInt32(oReader, "prra_RatingID");
                    companyData.szPRPublishLogo = dbAccess.GetString(oReader, "comp_PRPublishLogo");
                    companyData.szPRLogo = dbAccess.GetString(oReader, "comp_PRLogo");
                    companyData.szCreditWorthRating = dbAccess.GetString(oReader, "prcw_Name");
                    companyData.szCreditWorthRatingDescription = dbAccess.GetString(oReader, "CreditWorthRatingDescription");
                    companyData.szCreditWorthRatingInsight = dbAccess.GetString(oReader, "CreditWorthRatingInsight");
                    if (string.IsNullOrEmpty(companyData.szCreditWorthRatingInsight))
                        companyData.szCreditWorthRatingInsight = Resources.Global.CreditWorthEstimateInsight;

                    companyData.szAssignedRatingNumerals = dbAccess.GetString(oReader, "prra_AssignedRatingNumerals");
                    companyData.iPayReportCount = dbAccess.GetInt32(oReader, "PayReportCount");
                }
            }

            //Additional ufn data ex:HasNewClaimActivity)
            oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("comp_CompanyID", szCompanyID));

            //Handle spanish globalization of date fields
            CultureInfo m_UsCulture = new CultureInfo("en-us");
            string szDate1 = DateTime.Today.AddDays(0 - Configuration.ClaimActivityNewThresholdIndicatorDays).ToString(m_UsCulture);
            string szDate2 = DateTime.Today.AddDays(0 - Utilities.GetIntConfigValue("ClaimActivityMeritoriousThresholdIndicatorDays", 60)).ToString(m_UsCulture);

            oParameters.Add(new ObjectParameter("NewClaimThresholdDate", szDate1));
            oParameters.Add(new ObjectParameter("MeritoriousClaimThesholdDate", szDate2));

            szSQL = objectMgr.FormatSQL(PageBase.SQL_COMPANY_CELL_SELECT, oParameters);

            using (IDataReader oReader = dbAccess.ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null))
            {
                if (oReader.Read())
                {
                    companyData.bHasNewClaimActivity = objectMgr.TranslateFromCRMBool(oReader["HasNewClaimActivity"]);
                    companyData.bHasMeritoriousClaim = objectMgr.TranslateFromCRMBool(oReader["HasMeritoriousClaim"]);
                    companyData.bHasCertification = objectMgr.TranslateFromCRMBool(oReader["HasCertification"]);
                    companyData.bHasCertification_Organic = objectMgr.TranslateFromCRMBool(oReader["HasCertification_Organic"]);
                    companyData.bHasCertification_FoodSafety = objectMgr.TranslateFromCRMBool(oReader["HasCertification_FoodSafety"]);
                }
            }

            // Stash these in the cache.  Most likely the user will be
            // clicking through the company pages so let's not query
            // for these if we don't have too.
            HttpContext.Current.Session[szCompanyDataKey] = companyData;

            return companyData;
        }

        public static void ResetCompanyDataSession()
        {
            HttpContext.Current.Session[COMPANY_DATA_KEY] = null;
            HttpContext.Current.Session[COMPANY_DATA_KEY_HQ] = null;
        }

        public static void ResetCompanyDataNewsSession()
        {
            HttpContext.Current.Session[COMPANY_NEWS_DATA_KEY] = null;
        }

        public static CompanyDataNews GetCompanyDataNews(string szCompanyID, IPRWebUser oWebUser, IDBAccess dbAccess, GeneralDataMgr objectMgr)
        {
            // Let's make sure we have a valid company ID since we're
            // embedding it in the SQL.  The user could tamper with the
            // query string.
            int companyID = 0;
            if (!Int32.TryParse(szCompanyID, out companyID))
                throw new ApplicationException(string.Format("Invalid company ID specified: {0}", szCompanyID == null ? "NULL" : szCompanyID));

            string szCompanyNewsDataKey = COMPANY_NEWS_DATA_KEY;

            CompanyDataNews companyDataNews = null;

            // See if we have our values cached
            if (HttpContext.Current.Session[szCompanyNewsDataKey] != null)
            {
                companyDataNews = (CompanyDataNews)HttpContext.Current.Session[szCompanyNewsDataKey];
                if (companyDataNews.szCompanyID == szCompanyID)
                    return companyDataNews;
            }

            // If we're here, create a new object for our data.
            companyDataNews = new CompanyDataNews();
            companyDataNews.szCompanyID = szCompanyID;

            //Populate dtNews elsewhere in background lazy load thread since it takes 90% of total load time
            //and we don't want to do it inline

            // Stash these in the cache.  Most likely the user will be clicking through the company pages so let's not query
            // for these if we don't need to.
            HttpContext.Current.Session[szCompanyNewsDataKey] = companyDataNews;

            return companyDataNews;
        }


        public static void GetBBScoreRiskData(CompanyData companyData, int iBBScore)
        {
            string szRisk = "";
            string szInsight = "";

            string CreditScore_HighRisk_Text = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "Credit_Score_HighRisk_Text");
            int CreditScore_HighRisk_Min = Convert.ToInt32(_oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "Credit_Score_HighRisk_Min"));
            int CreditScore_HighRisk_Max = Convert.ToInt32(_oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "Credit_Score_HighRisk_Max"));
            string CreditScore_HighRisk_Insight = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "Credit_Score_HighRisk_Insight");
            
            string CreditScore_ModerateHighRisk_Text = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "Credit_Score_ModerateHighRisk_Text");
            int CreditScore_ModerateHighRisk_Min = Convert.ToInt32(_oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "Credit_Score_ModerateHighRisk_Min"));
            int CreditScore_ModerateHighRisk_Max = Convert.ToInt32(_oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "Credit_Score_ModerateHighRisk_Max"));
            string CreditScore_ModerateHighRisk_Insight = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "Credit_Score_ModerateHighRisk_Insight");

            string CreditScore_ModerateRisk_Text = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "Credit_Score_ModerateRisk_Text");
            int CreditScore_ModerateRisk_Min = Convert.ToInt32(_oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "Credit_Score_ModerateRisk_Min"));
            int CreditScore_ModerateRisk_Max = Convert.ToInt32(_oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "Credit_Score_ModerateRisk_Max"));
            string CreditScore_ModerateRisk_Insight = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "Credit_Score_ModerateRisk_Insight");

            string CreditScore_ModerateLowRisk_Text = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "Credit_Score_ModerateLowRisk_Text");
            int CreditScore_ModerateLowRisk_Min = Convert.ToInt32(_oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "Credit_Score_ModerateLowRisk_Min"));
            int CreditScore_ModerateLowRisk_Max = Convert.ToInt32(_oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "Credit_Score_ModerateLowRisk_Max"));
            string CreditScore_ModerateLowRisk_Insight = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "Credit_Score_ModerateLowRisk_Insight");

            string CreditScore_LowRisk_Text = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "Credit_Score_LowRisk_Text");
            int CreditScore_LowRisk_Min = Convert.ToInt32(_oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "Credit_Score_LowRisk_Min"));
            int CreditScore_LowRisk_Max = Convert.ToInt32(_oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "Credit_Score_LowRisk_Max"));
            string CreditScore_LowRisk_Insight = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "Credit_Score_LowRisk_Insight");

            if(iBBScore <= CreditScore_HighRisk_Max)
            {
                szRisk = CreditScore_HighRisk_Text;
                szInsight = CreditScore_HighRisk_Insight;
            }
            else if (iBBScore <= CreditScore_ModerateHighRisk_Max)
            {
                szRisk = CreditScore_ModerateHighRisk_Text;
                szInsight = CreditScore_ModerateHighRisk_Insight;
            }
            else if (iBBScore <= CreditScore_ModerateRisk_Max)
            {
                szRisk = CreditScore_ModerateRisk_Text;
                szInsight = CreditScore_ModerateRisk_Insight;
            }
            else if (iBBScore <= CreditScore_ModerateLowRisk_Max)
            {
                szRisk = CreditScore_ModerateLowRisk_Text;
                szInsight = CreditScore_ModerateLowRisk_Insight;
            }
            else if (iBBScore <= CreditScore_LowRisk_Max)
            {
                szRisk = CreditScore_LowRisk_Text;
                szInsight = CreditScore_LowRisk_Insight;
            }

            companyData.szBBScoreRisk = szRisk;
            companyData.szBBScoreInsight = szInsight;
        }

        public static void GetTradeActivityInsightData(CompanyData companyData, decimal decIntegrity)
        {
            string szRisk = "";
            string szInsight = "";

            string TradeActivity_Poor_Text = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "TradeActivity_Score_Poor_Text");
            decimal TradeActivity_Poor_Min = Convert.ToDecimal(_oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "TradeActivity_Score_Poor_Min"));
            decimal TradeActivity_Poor_Max = Convert.ToDecimal(_oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "TradeActivity_Score_Poor_Max"));
            string TradeActivity_Poor_Insight = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "TradeActivity_Score_Poor_Insight");

            string TradeActivity_Unsat_Text = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "TradeActivity_Score_Unsat_Text");
            decimal TradeActivity_Unsat_Min = Convert.ToDecimal(_oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "TradeActivity_Score_Unsat_Min"));
            decimal TradeActivity_Unsat_Max = Convert.ToDecimal(_oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "TradeActivity_Score_Unsat_Max"));
            string TradeActivity_Unsat_Insight = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "TradeActivity_Score_Unsat_Insight");

            string TradeActivity_Fair_Text = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "TradeActivity_Score_Fair_Text");
            decimal TradeActivity_Fair_Min = Convert.ToDecimal(_oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "TradeActivity_Score_Fair_Min"));
            decimal TradeActivity_Fair_Max = Convert.ToDecimal(_oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "TradeActivity_Score_Fair_Max"));
            string TradeActivity_Fair_Insight = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "TradeActivity_Score_Fair_Insight");

            string TradeActivity_Good_Text = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "TradeActivity_Score_Good_Text");
            decimal TradeActivity_Good_Min = Convert.ToDecimal(_oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "TradeActivity_Score_Good_Min"));
            decimal TradeActivity_Good_Max = Convert.ToDecimal(_oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "TradeActivity_Score_Good_Max"));
            string TradeActivity_Good_Insight = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "TradeActivity_Score_Good_Insight");

            string TradeActivity_Excellent_Text = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "TradeActivity_Score_Excellent_Text");
            decimal TradeActivity_Excellent_Min = Convert.ToDecimal(_oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "TradeActivity_Score_Excellent_Min"));
            decimal TradeActivity_Excellent_Max = Convert.ToDecimal(_oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "TradeActivity_Score_Excellent_Max"));
            string TradeActivity_Excellent_Insight = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "TradeActivity_Score_Excellent_Insight");

            if (decIntegrity <= TradeActivity_Poor_Max)
            {
                szRisk = TradeActivity_Poor_Text;
                szInsight = TradeActivity_Poor_Insight;
            }
            else if (decIntegrity <= TradeActivity_Unsat_Max)
            {
                szRisk = TradeActivity_Unsat_Text;
                szInsight = TradeActivity_Unsat_Insight;
            }
            else if (decIntegrity <= TradeActivity_Fair_Max)
            {
                szRisk = TradeActivity_Fair_Text;
                szInsight = TradeActivity_Fair_Insight;
            }
            else if (decIntegrity <= TradeActivity_Good_Max)
            {
                szRisk = TradeActivity_Good_Text;
                szInsight = TradeActivity_Good_Insight;
            }
            else if (decIntegrity <= TradeActivity_Excellent_Max)
            {
                szRisk = TradeActivity_Excellent_Text;
                szInsight = TradeActivity_Excellent_Insight;
            }

            companyData.szTradeReportRisk = szRisk;
            companyData.szTradeReportInsight = szInsight;
        }

        public static void GetPayDescriptionInsightData(CompanyData companyData, string szPRPY_Name)
        {
            string szRisk = "";
            string szInsight = "";
            string szMeaning = "";

            string PayDescription_AA_Text = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "PayDescription_AA_Text");
            string PayDescription_AA_Insight = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "PayDescription_AA_Insight");

            string PayDescription_A_Text = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "PayDescription_A_Text");
            string PayDescription_A_Insight = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "PayDescription_A_Insight");

            string PayDescription_B_Text = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "PayDescription_B_Text");
            string PayDescription_B_Insight = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "PayDescription_B_Insight");

            string PayDescription_C_Text = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "PayDescription_C_Text");
            string PayDescription_C_Insight = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "PayDescription_C_Insight");

            string PayDescription_D_Text = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "PayDescription_D_Text");
            string PayDescription_D_Insight = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "PayDescription_D_Insight");

            string PayDescription_E_Text = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "PayDescription_E_Text");
            string PayDescription_E_Insight = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "PayDescription_E_Insight");

            string PayDescription_F_Text = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "PayDescription_F_Text");
            string PayDescription_F_Insight = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "PayDescription_F_Insight");

            string PayDescription_149_Text = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "PayDescription_149_Text");
            string PayDescription_149_Meaning = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "PayDescription_149_Meaning");
            string PayDescription_149_Insight = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "PayDescription_149_Insight");
            
            string PayDescription_81_Text = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "PayDescription_81_Text");
            string PayDescription_81_Meaning = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "PayDescription_81_Meaning");
            string PayDescription_81_Insight = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "PayDescription_81_Insight");

            if (!string.IsNullOrEmpty(szPRPY_Name))
            {
                switch (szPRPY_Name.ToUpper())
                {
                    case "AA":
                        szRisk = PayDescription_AA_Text;
                        szInsight = PayDescription_AA_Insight;
                        break;
                    case "A":
                        szRisk = PayDescription_A_Text;
                        szInsight = PayDescription_A_Insight;
                        break;
                    case "B":
                        szRisk = PayDescription_B_Text;
                        szInsight = PayDescription_B_Insight;
                        break;
                    case "C":
                        szRisk = PayDescription_C_Text;
                        szInsight = PayDescription_C_Insight;
                        break;
                    case "D":
                        szRisk = PayDescription_D_Text;
                        szInsight = PayDescription_D_Insight;
                        break;

                    case "E":
                        szRisk = PayDescription_E_Text;
                        szInsight = PayDescription_E_Insight;
                        break;
                    case "F":
                        szRisk = PayDescription_F_Text;
                        szInsight = PayDescription_F_Insight;
                        break;
                    case "(149)":
                        szRisk = PayDescription_149_Text;
                        szMeaning = PayDescription_149_Meaning;
                        szInsight = PayDescription_149_Insight;
                        break;
                    case "(81)":
                        szRisk = PayDescription_81_Text;
                        szMeaning = PayDescription_81_Meaning;
                        szInsight = PayDescription_81_Insight;
                        break;
                }
            }

            companyData.szPayDescriptionRisk = szRisk;
            companyData.szPayDescriptionMeaning = szMeaning;
            companyData.szPayDescriptionInsight = szInsight;
        }

        public static void GetRatingData(CompanyData companyData, string szRating)
        {
            string szRatingText = "";
            string szRatingInsight = "";
            string szRatingMeaning = "";

            string Rating_X_Text = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "Rating_X_Text");
            string Rating_X_Meaning = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "Rating_X_Meaning");
            string Rating_X_Insight = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "Rating_X_Insight");

            string Rating_XX_Text = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "Rating_XX_Text");
            string Rating_XX_Meaning = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "Rating_XX_Meaning");
            string Rating_XX_Insight = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "Rating_XX_Insight");

            string Rating_XXX_Text = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "Rating_XXX_Text");
            string Rating_XXX_Meaning = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "Rating_XXX_Meaning");
            string Rating_XXX_Insight = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "Rating_XXX_Insight");

            string Rating_XXXX_Text = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "Rating_XXXX_Text");
            string Rating_XXXX_Meaning = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "Rating_XXXX_Meaning");
            string Rating_XXXX_Insight = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "Rating_XXXX_Insight");

            string Rating_XX147_Text = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "Rating_XX147_Text");
            string Rating_XX147_Meaning = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "Rating_XX147_Meaning");
            string Rating_XX147_Insight = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "Rating_XX147_Insight");

            string Rating_XXX148_Text = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "Rating_XXX148_Text");
            string Rating_XXX148_Meaning = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "Rating_XXX148_Meaning");
            string Rating_XXX148_Insight = _oPageBase.GetReferenceValue("BBOSPerformanceIndicators", "Rating_XXX148_Insight");

            if (szRating.ToUpper() == "X")
            {
                szRatingText = Rating_X_Text;
                szRatingMeaning = Rating_X_Meaning;
                szRatingInsight = Rating_X_Insight;
            }
            else if (szRating.ToUpper() == "XX")
            {
                szRatingText = Rating_XX_Text;
                szRatingMeaning = Rating_XX_Meaning;
                szRatingInsight = Rating_XX_Insight;
            }
            else if (szRating.ToUpper() == "XXX")
            {
                szRatingText = Rating_XXX_Text;
                szRatingMeaning = Rating_XXX_Meaning;
                szRatingInsight = Rating_XXX_Insight;
            }
            else if (szRating.ToUpper() == "XXXX")
            {
                szRatingText = Rating_XXXX_Text;
                szRatingMeaning = Rating_XXXX_Meaning;
                szRatingInsight = Rating_XXXX_Insight;
            }
            else if (szRating.ToUpper() == "XX147")
            {
                szRatingText = Rating_XX147_Text;
                szRatingMeaning = Rating_XX147_Meaning;
                szRatingInsight = Rating_XX147_Insight;
            }
            else if (szRating.ToUpper() == "XXX148")
            {
                szRatingText = Rating_XXX148_Text;
                szRatingMeaning = Rating_XXX148_Meaning;
                szRatingInsight = Rating_XXX148_Insight;
            }

            companyData.szRatingDescription = szRatingText;
            companyData.szRatingMeaning = szRatingMeaning;
            companyData.szRatingInsight = szRatingInsight;
        }

        private static void GetBusinessStartData(CompanyData companyData, string szCompanyID, IDBAccess dbAccess)
        {
            //Series 250 -- replace Toll Free with Incorporated Date/State
            string szSQL = string.Format(SQL_COMPANY_INCORPORATION_DATE_STATE_V2, szCompanyID);
            using (IDataReader oReader = dbAccess.ExecuteReader(szSQL, CommandBehavior.CloseConnection))
            {
                if (oReader.Read())
                {
                    companyData.BusinessStartDate = dbAccess.GetString(oReader, "BusinessStartDate");
                    companyData.BusinessStartState = dbAccess.GetString(oReader, "BusinessStartState");
                }
            }
        }

        private static void GetARDetails(CompanyData companyData, IPRWebUser oUser)
        {
            string threshold = GetARThreshold(oUser);
            
            IList parms = new ArrayList();
            parms.Add(new ObjectParameter("SubjectCompanyID", companyData.szCompanyID));
            parms.Add(new ObjectParameter("Threshold", threshold));
            parms.Add(new ObjectParameter("IndustryType", companyData.szIndustryType));

            using (IDataReader reader = GetDBAccess().ExecuteReader("usp_GetBBOSARSummary", parms, CommandBehavior.CloseConnection, null, CommandType.StoredProcedure))
            {
                if (reader.Read())
                {
                    companyData.szAR_Threshold = threshold;
                    companyData.szAR_AvgMonthlyBalance = UIUtils.GetFormattedCurrency(reader["AvgMonthlyBalance"]);
                    companyData.szAR_HighBalance = UIUtils.GetFormattedCurrency(reader["MaxMonthlyBalance"]);
                    companyData.szAR_TotalNumCompanies = UIUtils.GetFormattedInt((int)reader["ReportingCompanies"]);
                }
            }
        }
        private static string GetARThreshold(IPRWebUser oUser)
        {
            //Get cached company data
            CompanyData ocd = GetCompanyDataFromSession();

            string threshold = oUser.prwu_ARReportsThrehold;
            if ((ocd.szIndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER))
            {
                threshold = Utilities.GetConfigValue("CompanyDetailsARAgingThresholdLumber", "3");
            }

            return threshold;
        }

        protected const string SQL_LICENSES_SELECT =
        @"SELECT * FROM (
             SELECT dbo.ufn_GetListingLicenseSeq('PACA') AS Seq, 'PACA' AS Name, prpa_LicenseNumber As License
               FROM PRPACALicense WITH(NOLOCK)
             WHERE prpa_CompanyID = {0}
                AND prpa_Deleted IS NULL
                AND prpa_Publish = 'Y'
             UNION
             SELECT dbo.ufn_GetListingLicenseSeq('DRC'), 'DRC', CASE WHEN prdr_LicenseNumber IS NOT NULL THEN 'DRC Member' ELSE NULL END As prdr_LicenseNumber
               FROM PRDRCLicense WITH(NOLOCK)
             WHERE prdr_CompanyID = {0}
                AND prdr_Publish = 'Y'
                AND prdr_Deleted IS NULL
             UNION
             SELECT dbo.ufn_GetListingLicenseSeq(prli_Type),
                       COALESCE(cast(capt_us as varchar) + ' ', ''), prli_Number
               FROM PRCompanyLicense WITH(NOLOCK)
                    INNER JOIN custom_captions on capt_family = 'prli_Type' and capt_code = prli_Type
             WHERE prli_CompanyID = {0}
                AND prli_Publish = 'Y'
                AND prli_Deleted IS NULL
             ) TABLE1
       ORDER BY SEQ";

        private static void GetLicenseData(CompanyData companyData)
        {
            string szSQL = string.Format(SQL_LICENSES_SELECT, companyData.szCompanyID);
            companyData.dtLicenses = GetDBAccess().ExecuteSelect(szSQL).Tables[0];
        }

        protected const string SQL_VOLUME_SELECT =
           @"SELECT prcp_Volume, Capt_US VolumeName FROM PRCompanyProfile WITH(NOLOCK) 
	            INNER JOIN Company WITH(NOLOCK) ON Comp_CompanyId = prcp_CompanyId
	            INNER JOIN Custom_Captions WITH(NOLOCK) ON Capt_Code = prcp_Volume AND Capt_Family= CASE WHEN comp_PRIndustryType='L' THEN 'prcp_VolumeL' ELSE 'prcp_Volume' END
                WHERE prcp_CompanyId = {0}";
        private static void GetVolumeData(CompanyData companyData)
        {
            string szSQL = string.Format(SQL_VOLUME_SELECT, companyData.szCompanyID);
            companyData.dtVolume = GetDBAccess().ExecuteSelect(szSQL).Tables[0];
        }

        protected const string SQL_COMPANY_HQ_SELECT = "SELECT comp_CompanyID, comp_PRBookTradestyle, CityStateCountryShort, comp_PRListingStatus FROM Company WITH (NOLOCK) INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID WHERE comp_CompanyID = dbo.ufn_BRGetHQID({0})";
        protected const string SQL_BRANCHES_1 =
                 @"SELECT *, 
                             dbo.ufn_GetCustomCaptionValue('comp_PRIndustryType', comp_PRIndustryType, '{0}') As IndustryType, 
                             dbo.ufn_HasNote({1}, {2}, comp_CompanyID, 'C') As HasNote, 
                             dbo.ufn_FormatPhone(phone.phon_CountryCode, phone.phon_AreaCode, phone.phon_Number, phone.phon_PRExtension) as Phone,
                             dbo.ufn_HasNewClaimActivity(comp_PRHQID, '{4}') as HasNewClaimActivity, 
                             dbo.ufn_HasMeritoriousClaim(comp_PRHQID, '{5}') as HasMeritoriousClaim,
                             dbo.ufn_HasCertification(comp_PRHQID) as HasCertification,
                             dbo.ufn_HasCertification_Organic(comp_PRHQID) as HasCertification_Organic,
                             dbo.ufn_HasCertification_FoodSafety(comp_PRHQID) as HasCertification_FoodSafety
                        FROM vPRBBOSCompanyList
                             LEFT OUTER JOIN vPRCompanyPhone phone WITH (NOLOCK) ON comp_CompanyID = phone.PLink_RecordID AND phone.phon_PRIsPhone='Y' AND phone.phon_PRPreferredPublished='Y' 
                       WHERE comp_CompanyID IN ({3}) ";

        protected const string SQL_BRANCHES_2 = "SELECT comp_CompanyID FROM Company WITH (NOLOCK) WHERE comp_PRHQID ={0} AND comp_PRType = 'B' AND comp_PRListingStatus IN ({1})";

        private static void GetBranchData(CompanyData companyData, IPRWebUser oUser)
        {
            int iHQID = 0;
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", companyData.szCompanyID));

            string qhListingStatus = null;

            string szSQL = string.Format(SQL_COMPANY_HQ_SELECT, companyData.szCompanyID);

            using (IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null))
            {
                oReader.Read();
                iHQID = GetDBAccess().GetInt32(oReader, "comp_CompanyID");

                qhListingStatus = GetDBAccess().GetString(oReader, "comp_PRListingStatus");
            }

            string listingStatus = "'L', 'H', 'LUV'";
            if ((qhListingStatus == "N3") ||
                (qhListingStatus == "N5") ||
                (qhListingStatus == "N6"))
            {
                listingStatus += ",'N3','N5','N6'";
            }

            oParameters.Clear();

            szSQL = string.Format(SQL_BRANCHES_2, iHQID, listingStatus);

            object[] args =  {oUser.prwu_Culture,
                              oUser.prwu_WebUserID,
                              oUser.prwu_HQID,
                              szSQL,
                              DateTime.Today.AddDays(0 - Configuration.ClaimActivityNewThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss"),
                              DateTime.Today.AddDays(0 - Configuration.ClaimActivityMeritoriousThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss")};

            szSQL = string.Format(SQL_BRANCHES_1,
                                  args);

            szSQL += " AND " + GetLocalSourceCondition(oUser);
            szSQL += " AND " + GetIntlTradeAssociationCondition(oUser);

            companyData.dtBranch = GetDBAccess().ExecuteSelect(szSQL, oParameters).Tables[0];
        }

        protected const string SQL_AFFILIATES_1 =
            @"SELECT *, 
                    dbo.ufn_GetCustomCaptionValue('comp_PRIndustryType', comp_PRIndustryType, '{0}') As IndustryType, 
                    dbo.ufn_GetCustomCaptionValue('comp_PRType_BBOS', comp_PRType, '{0}') As CompanyType, 
                    dbo.ufn_HasNote({1}, {2}, comp_CompanyID, 'C') As HasNote, 
                    compRating.prra_RatingLine,
                    dbo.ufn_FormatPhone(phone.phon_CountryCode, phone.phon_AreaCode, phone.phon_Number, phone.phon_PRExtension) as Phone, 
                    emai_PRWebAddress,
                    dbo.ufn_HasNewClaimActivity(comp_PRHQID, '{4}') as HasNewClaimActivity, 
                    dbo.ufn_HasMeritoriousClaim(comp_PRHQID, '{5}') as HasMeritoriousClaim,
                    dbo.ufn_HasCertification(comp_PRHQID) as HasCertification,
                    dbo.ufn_HasCertification_Organic(comp_PRHQID) as HasCertification_Organic,
                    dbo.ufn_HasCertification_FoodSafety(comp_PRHQID) as HasCertification_FoodSafety,
                    CASE WHEN comp_PRType = 'B' THEN CASE WHEN compRating.prra_RatingID IS NOT NULL THEN 'N' ELSE 'Y' END ELSE 'N' END AS IsHQRating,
                    CASE WHEN comp_PRType = 'B' THEN CASE WHEN compRating.prra_RatingID IS NOT NULL THEN compRating.prra_RatingID ELSE hqRating.prra_RatingID END ELSE hqRating.prra_RatingID END AS prra_RatingID,
                    CASE WHEN comp_PRType = 'B' THEN CASE WHEN compRating.prra_RatingID IS NOT NULL THEN compRating.prra_RatingLine ELSE hqRating.prra_RatingLine END ELSE hqRating.prra_RatingLine END AS prra_RatingLine
                FROM vPRBBOSCompanyList
                    LEFT OUTER JOIN vPRCurrentRating compRating ON comp_CompanyID = compRating.prra_CompanyID 
                    LEFT OUTER JOIN vPRCurrentRating hqRating ON comp_PRHQID = hqRating.prra_CompanyID 
                    LEFT OUTER JOIN vCompanyEmail WITH (NOLOCK) ON comp_CompanyID = elink_RecordID AND elink_Type = 'W' AND emai_PRPreferredPublished = 'Y' 
                    LEFT OUTER JOIN vPRCompanyPhone phone WITH (NOLOCK) ON comp_CompanyID = phone.PLink_RecordID AND phone.phon_PRIsPhone='Y' AND phone.phon_PRPreferredPublished='Y' 
                WHERE comp_CompanyID IN ({3}) AND comp_PRListingStatus IN ('L', 'H', 'LUV')";

        protected const string SQL_AFFILIATES_2 = "SELECT CASE WHEN prcr_LeftCompanyID={0} THEN prcr_RightCompanyID ELSE prcr_LeftCompanyID END As CompanyID" +
                                            "  FROM PRCompanyRelationship WITH (NOLOCK) " +
                                            " WHERE (prcr_LeftCompanyID = {0} OR prcr_RightCompanyID={0})" +
                                            "   AND prcr_Type IN (27, 28, 29)" +
                                            "   AND prcr_Active = 'Y'" +
                                            "   AND prcr_Deleted IS NULL";
        private static void GetAffiliationData(CompanyData companyData, IPRWebUser oUser)
        {
            string szSQL = string.Format(SQL_AFFILIATES_2, companyData.szCompanyID);

            object[] args =  {oUser.prwu_Culture,
                              oUser.prwu_WebUserID,
                              oUser.prwu_HQID,
                              szSQL,
                              DateTime.Today.AddDays(0 - Configuration.ClaimActivityNewThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss"),
                              DateTime.Today.AddDays(0 - Configuration.ClaimActivityMeritoriousThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss")};

            szSQL = string.Format(SQL_AFFILIATES_1, args);
            szSQL += " AND " + GetLocalSourceCondition(oUser);
            szSQL += " AND " + GetIntlTradeAssociationCondition(oUser);

            companyData.dtAffiliation = GetDBAccess().ExecuteSelect(szSQL).Tables[0];
        }

        public static string GetLocalSourceCondition(IPRWebUser oUser)
        {
            if (((IPRWebUser)oUser).HasLocalSourceDataAccess())
            {
                return string.Format("(LocalSourceStateID IS NULL OR LocalSourceStateID IN (SELECT DISTINCT prlsr_StateID FROM PRLocalSourceRegion WITH (NOLOCK) WHERE prlsr_ServiceCode IN ({0})))", ((IPRWebUser)oUser).GetLocalSourceDataAccessServiceCodes());
            }
            else
            {
                return "comp_PRLocalSource IS NULL";
            }
        }

        public static string GetIntlTradeAssociationCondition(IPRWebUser oUser)
        {
            //3.1.2.1	Add GetIntlTradeAssociationCondition(): Model on GetLocalSourceCondition().  If the User.IsIntrlTradeAssocationUser, then return “comp_PRImporter = ‘Y’”.  Else return null.
            if (((IPRWebUser)oUser).prcta_IsIntlTradeAssociation)
            {
                return "comp_PRImporter = 'Y'";
            }
            else
            {
                return "1=1";
            }
        }

        public static CompanyData GetCompanyDataFromSession(bool bHQ = false)
        {
            string szCompanyDataKey = COMPANY_DATA_KEY;
            if (bHQ)
                szCompanyDataKey = COMPANY_DATA_KEY_HQ;

            CompanyData ocd = null;
            if (HttpContext.Current.Session[szCompanyDataKey] != null)
                ocd = (CompanyData)HttpContext.Current.Session[szCompanyDataKey];

            if (ocd == null)
                ocd = new CompanyData();

            return ocd;
        }

        /// <summary>
        /// Call after DataBind() method
        /// </summary>
        /// <param name="oGrid"></param>
        public static void EnableBootstrapFormatting(GridView oGrid)
        {
            //This replaces <td> with <th>    
            oGrid.UseAccessibleHeader = true;

            if (oGrid.HeaderRow != null)
            {
                //This will add the <thead> and <tbody> elements    
                oGrid.HeaderRow.TableSection = TableRowSection.TableHeader; //force creating of <thead> tag for bootstrap so that formatting turns out properly
            }

            if (oGrid.FooterRow != null)
            {
                //This adds the <tfoot> element. Remove if you don't have a footer row    
                oGrid.FooterRow.TableSection = TableRowSection.TableFooter;
            }

            if (oGrid.TopPagerRow != null)
                oGrid.TopPagerRow.TableSection = TableRowSection.TableHeader;

            if (oGrid.BottomPagerRow != null)
                oGrid.BottomPagerRow.TableSection = TableRowSection.TableFooter;
        }

        /// <summary>
        /// Callback used to modify the header of the column being sorted.
        /// Assumes the other "GetSort*" callbacks are used to store the
        /// current sort field and ASC indicator.
        /// </summary>
        /// <param name="oGridView">DataGrid</param>
        /// <param name="e"></param>
        public static void SetSortIndicator(GridView oGridView, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.Header)
            {
                if (!string.IsNullOrEmpty(GetSortField(oGridView)))
                {
                    LiteralControl sortIndicator = new LiteralControl();
                    
                    sortIndicator.Text = "<span class=\"msicon notranslate\">{0}</span>";
                    if (GetSortAsc(oGridView))
                    {
                        sortIndicator.Text = string.Format(sortIndicator.Text, "expand_less");
                    }
                    else
                    {
                        sortIndicator.Text = string.Format(sortIndicator.Text, "expand_more");
                    }

                    int iColumnIndex = 0;

                    for (int i = 0; i < oGridView.Columns.Count; i++)
                    {
                        if (oGridView.Columns[i].SortExpression == GetSortField(oGridView))
                        {
                            iColumnIndex = i;
                            break;
                        }
                    }

                    e.Row.Cells[iColumnIndex].Controls.Add(new LiteralControl(" "));
                    e.Row.Cells[iColumnIndex].Controls.Add(sortIndicator);
                }
            }
        }

        /// <summary>
        /// Retrieves the specified Sort Field Name from the
        /// specified DataGrid.
        /// </summary>
        /// <param name="oGridView">GridView</param>
        /// <returns>Current Sort Field</returns>
        public static string GetSortField(GridView oGridView)
        {
            if (oGridView.Attributes["SortField"] == null)
            {
                return string.Empty;
            }
            return oGridView.Attributes["SortField"];
        }

        /// <summary>
        /// Retrieves the specified Asc Sort Indicator from the
        /// specified DataGrid.
        /// </summary>
        /// <param name="oGridView">GridView</param>
        /// <returns>Current Asc Sort Indicator</returns>
        public static bool GetSortAsc(GridView oGridView)
        {
            if (oGridView.Attributes["SortAsc"] == null)
            {
                return true;
            }
            return Convert.ToBoolean(oGridView.Attributes["SortAsc"]);
        }

        /// <summary>
        /// Stores the current Asc sort indicator with the specified
        /// DataGrid
        /// </summary>
        /// <param name="oGridView">GridView</param>
        /// <param name="bSortAsc">Asc Sort Indicator</param>
        public static void SetSortAsc(GridView oGridView, bool bSortAsc)
        {
            oGridView.Attributes["SortAsc"] = bSortAsc.ToString();
        }

        /// <summary>
        /// Helper method that helps with bi-directional sorting.  Its
        /// sets the sort field and sort direction in attributes of the
        /// GridView.  This can then be used by subsequent methods to
        /// generate an ORDER BY clause.
        /// </summary>
        /// <param name="oGridView"></param>
        /// <param name="e"></param>
        public static void SetSortingAttributes(GridView oGridView, GridViewSortEventArgs e)
        {
            if (e.SortExpression == GetSortField(oGridView))
            {
                SetSortAsc(oGridView, !GetSortAsc(oGridView));
            }
            else
            {
                SetSortAsc(oGridView, true);
            }

            SetSortField(oGridView, e.SortExpression);
        }


        /// <summary>
        /// Helper method assumes the other sort helper methods are used to
        /// store current sort information on the specified GridView.
        /// </summary>
        /// <param name="oGridView"></param>
        /// <returns></returns>
        public static string GetOrderByClause(GridView oGridView)
        {
            return GetOrderByClause(oGridView, true);
        }

        public static string GetOrderByClause(GridView oGridView, bool includeOrderBy)
        {
            string szSQL = string.Empty;
            // Now handle our sorting
            if (!string.IsNullOrEmpty(GetSortField(oGridView)))
            {
                if (includeOrderBy)
                {
                    szSQL += " ORDER BY";
                }
                szSQL += " " + GetSortField(oGridView);

                if (!GetSortAsc(oGridView))
                {
                    szSQL += " DESC";
                }
            }

            return szSQL;
        }

        /// <summary>
        /// Stores the current sort field name with the specified
        /// DataGrid
        /// </summary>
        /// <param name="oGridView">GridView</param>
        /// <param name="szFieldName">Sort Field Name</param>
        public static void SetSortField(GridView oGridView, string szFieldName)
        {
            oGridView.Attributes["SortField"] = szFieldName;
        }

        public static void RemoveRequestParameter(string szName)
        {
            HttpContext.Current.Session.Remove(szName);
            //Response.Cookies[szName].Expires = DateTime.Now.AddDays(-1);
        }

        public static void SetRequestParameter(string szName, string szValue)
        {
            HttpContext.Current.Session[szName] = szValue;
            //Response.Cookies[szName].Value = szValue;
        }

        public static string GetCategoryIcon(object icon, object categoryName)
        {
            if (icon == DBNull.Value)
            {
                return string.Empty;
            }

            return "<img src=\"" + UIUtils.GetImageURL((string)icon) + "\" alt=\"" + categoryName + "\">";
        }

        public static string GetCurrentCulture(IPRWebUser oUser)
        {
            if (oUser != null)
            {
                return oUser.prwu_Culture;
            }

            return Thread.CurrentThread.CurrentCulture.Name.ToLower();
        }

        [Serializable]
        public class CompanyData
        {
            public string szCompanyID;
            public string szCompanyName;
            public string szLocation;
            public string szListingStatus;
            public string szListingStatusName;

            public DateTime dtListedDate;
            public DateTime dtDelistedDate;
            public string szIndustryType;
            public string szIndustryTypeName;
            public string szCompanyType;

            public bool bHasNote;
            public bool bHasCSG;
            public DateTime dtLastChanged;
            public int iHQID;
            public string szBBScore;
            public string szBBScoreModel;
            public bool bBBScorePublished;
            public bool bCompBBScorePublished;
            public string szBBScoreRisk;
            public string szBBScoreInsight;

            public string szRatingLineLabel;
            public string szRatingLine;
            public string szPRCW_Name;
            public string szPRIN_Name;
            public string szPRPY_Name;
            public string szRatingNumerals;
            public string szPayIndicator;
            public string szIsHQRating;
            public int iRatingID;

            public string szRatingDescription;
            public string szRatingMeaning;
            public string szRatingInsight;

            public bool bLocalSource;
            public int iRegionID; //prst_StateID
            public int iCountryID; //prst_CountryID
            public bool bPRTMFMAward;
            public DateTime dtPRTMFMAwardDate;
            public string szPreparedName;
            public bool bSuppressLinkedInWidget;
            public string szWebAddress;
            public string szEmailAddress;
            public string szTollFreePhone;
            public string szPhone;
            public string szFax;

            public string szPRPublishLogo;
            public string szPRLogo;
            public bool bIsCertifiedOrganic;
            public bool bIsFoodSafetyCertified;
            public string szCreditWorthRating;
            public string szCreditWorthRatingDescription;
            public string szCreditWorthRatingInsight;

            public string szAssignedRatingNumerals;
            public bool bPublishPayIndicator;
            public int iCompanyPayIndicatorID;
            public int iPayReportCount;
            public DateTime dtPRFinancialStatementDate;
            public DateTime dtPRRA_DateTime;
            public string BusinessStartDate;
            public string BusinessStartState;
            public bool bOnWatchdogList;

            public bool bHasNewClaimActivity;
            public bool bHasMeritoriousClaim;
            public bool bHasCertification;
            public bool bHasCertification_Organic;
            public bool bHasCertification_FoodSafety;

            public decimal  decAveIntegrity;
            public int      iTradeReportCount;
            public string   szIndustryAveIntegrity;
            public string   szTradeReportRisk;
            public string   szTradeReportInsight;

            public string szPayDescriptionRisk;
            public string szPayDescriptionMeaning;
            public string szPayDescriptionInsight;

            //Other Information
            public string szBank;
            public string szSalvageDistressedProduce;
            //AR
            public string szAR_Threshold;
            public string szAR_AvgMonthlyBalance;
            public string szAR_HighBalance;
            public string szAR_TotalNumCompanies;
            //DataTables
            public DataTable dtLicenses;
            public DataTable dtVolume;
            public DataTable dtBranch;
            public DataTable dtAffiliation;
        }

        [Serializable]
        public class CompanyDataNews
        {
            public string szCompanyID;
            public DataTable dtNews;
        }

        #region "BBScoreChart"

        public const string SESSION_BBSCORE_HISTORY_DS = "SESSION_BBSCORE_HISTORY_DS";
        public const string SESSION_BBSCORE_HISTORY_BBID = "SESSION_BBSCORE_HISTORY_BBID";
        public static void PopulateBBScoreChart(int companyID, string industryType, Chart chartBBScore, System.Web.UI.WebControls.Image imgBBScoreText, Literal litBBScoreText, int prwu_AccessLevel, string szBBScore, string prwu_Culture, string szBBScoreModel, bool blnSkipIfPopulated = true)
        {
            DataSet dsBBScoreHistory_Session = null;
            string bbid_Session = "";

            //Calculate which BBScore jpg file to display
            string szFileExtras = ""; //the param portion of "BBScore_Text_{0}.jpg"
            if (industryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                szFileExtras = string.Format("{0}_Lumber", Convert.ToDecimal(szBBScore).ToString("###"));
            else
                szFileExtras = string.Format("{0}", Convert.ToDecimal(szBBScore).ToString("###"));

            //New ranges and images implemented Dec 2021 - use BBScoreGauge3 folder
            if (szBBScoreModel.ToLower() == Configuration.CurrentBBScoreModelName)
                imgBBScoreText.ImageUrl = UIUtils.GetImageURL(string.Format(Utilities.GetConfigValue("BBScoreImageFile").Replace("BBScoreGauge/", "BBScoreGauge3/"), szFileExtras));
            else
                imgBBScoreText.ImageUrl = UIUtils.GetImageURL(string.Format(Utilities.GetConfigValue("BBScoreImageFile"), szFileExtras));

            if (litBBScoreText != null)
                litBBScoreText.Text = szBBScore;

            if (blnSkipIfPopulated)
            {
                if (HttpContext.Current.Session[SESSION_BBSCORE_HISTORY_BBID] != null)
                    bbid_Session = (HttpContext.Current.Session[SESSION_BBSCORE_HISTORY_BBID]).ToString();
                if (HttpContext.Current.Session[SESSION_BBSCORE_HISTORY_DS] != null)
                    dsBBScoreHistory_Session = (DataSet)HttpContext.Current.Session[SESSION_BBSCORE_HISTORY_DS];

                if (bbid_Session == companyID.ToString() && dsBBScoreHistory_Session != null)
                {
                    //rebind the data we just got from session
                    BindChartData(chartBBScore, dsBBScoreHistory_Session, industryType);
                    chartBBScore.DataBind();
                    return;
                }
            }

            if (!Utilities.GetBoolConfigValue("BBScoreChartEnabled", false))
                return;

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", companyID));
            oParameters.Add(new ObjectParameter("IndustryType", industryType));
            oParameters.Add(new ObjectParameter("Culture", prwu_Culture));

            if (prwu_AccessLevel >= PRWebUser.SECURITY_LEVEL_ADVANCED_PLUS)
            {
                //Series 250 / Advanced Plus change # of items on chart
                oParameters.Add(new ObjectParameter("BBScoreChartCount", Utilities.GetIntConfigValue("BBScoreChartCountPlus", 12)));
            }
            else
            {
                oParameters.Add(new ObjectParameter("BBScoreChartCount", Utilities.GetIntConfigValue("BBScoreChartCount", 4)));
            }

            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();

            DataSet dsBBScoreHistory = oDBAccess.ExecuteStoredProcedure("usp_BRBBScoreHistoryRank", oParameters);
            BindChartData(chartBBScore, dsBBScoreHistory, industryType);
            chartBBScore.DataBind();

            HttpContext.Current.Session[SESSION_BBSCORE_HISTORY_DS] = dsBBScoreHistory;
            HttpContext.Current.Session[SESSION_BBSCORE_HISTORY_BBID] = companyID;
        }

        public static void SetBBScoreChartSession(int companyID, string industryType, int prwu_AccessLevel, string prwu_Culture)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", companyID));
            oParameters.Add(new ObjectParameter("IndustryType", industryType));
            oParameters.Add(new ObjectParameter("Culture", prwu_Culture));

            if (prwu_AccessLevel >= PRWebUser.SECURITY_LEVEL_ADVANCED_PLUS)
            {
                //Series 250 / Advanced Plus change # of items on chart
                oParameters.Add(new ObjectParameter("BBScoreChartCount", Utilities.GetIntConfigValue("BBScoreChartCountPlus", 12)));
            }
            else
            {
                oParameters.Add(new ObjectParameter("BBScoreChartCount", Utilities.GetIntConfigValue("BBScoreChartCount", 4)));
            }

            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();

            DataSet dsBBScoreHistory = oDBAccess.ExecuteStoredProcedure("usp_BRBBScoreHistoryRank", oParameters);
            HttpContext.Current.Session[SESSION_BBSCORE_HISTORY_DS] = dsBBScoreHistory;
            HttpContext.Current.Session[SESSION_BBSCORE_HISTORY_BBID] = companyID;
        }

        protected const string SQL_BBS_Use_Both_Models_For_Line_Chart =
            @"SELECT dbo.ufn_GetCustomCaptionValue('BBSUseBothModelsForLineChart','BBSUseBothModelsForLineChart', 'en-us')";

        public static bool BBSUseBothModelsForLineChart()
        {
            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            object oValue = oDBAccess.ExecuteScalar(SQL_BBS_Use_Both_Models_For_Line_Chart);

            // If we don't have a value, return false
            if ((oValue == DBNull.Value) ||
                (string.IsNullOrEmpty((string)oValue)))
                return false;

            return bool.Parse((string)oValue);
        }

        public static void BindChartData(Chart chartBBScore, DataSet dsBBScoreHistory, string industryType)
        {
            chartBBScore.Series.Clear();

            Series series1 = new Series("BB Score");
            series1.ChartType = SeriesChartType.Line;
            series1.XValueMember = "RunDateDescription";
            series1.YValueMembers = "BBScore";
            series1.IsValueShownAsLabel = true;
            series1.ChartArea = "ChartArea1";
            series1.MarkerStyle = MarkerStyle.Square;
            series1.Color = ColorTranslator.FromHtml("#00008B"); //Color.DarkBlue;
            series1.BorderWidth = 2;
            series1.Font = new Font("Microsoft Sans Serif", 9, FontStyle.Bold);

            Series series2 = new Series("Retired BBScore");
            series2.ChartType = SeriesChartType.Line;
            series2.XValueMember = "RunDateDescription";
            series2.YValueMembers = "OldBBScore";
            series2.IsValueShownAsLabel = true;
            series2.ChartArea = "ChartArea1";
            series2.MarkerStyle = MarkerStyle.Square;
            series2.Color = ColorTranslator.FromHtml("#8b8bff"); //lighter shade of darkblue
            series2.LabelForeColor = ColorTranslator.FromHtml("#8b8bff"); //lighter shade of darkblue
            series2.BorderWidth = 1;
            series2.Font = new Font("Microsoft Sans Serif", 7);
            

            //series 1
            List<string> xvals1 = new List<string>();
            List<int?> yvals1 = new List<int?>();
            foreach (DataRow dr in dsBBScoreHistory.Tables[0].Rows)
            {
                xvals1.Add(dr["RunDateDescription"].ToString());
                if (DBNull.Value.Equals(dr["BBScore"]))
                    yvals1.Add(null);
                else
                    yvals1.Add(Convert.ToInt32(dr["BBScore"]));
            }
            series1.XValueType = ChartValueType.String;
            series1.YValueType = ChartValueType.Auto;
            series1.Points.DataBindXY(xvals1.ToArray(), yvals1.ToArray());

            //If Lumber or both models flag is not set, limit chart to single series only then bail
            if (industryType == "L" || !BBSUseBothModelsForLineChart())
            {
                chartBBScore.Series.Add(series1);
                return;
            }

            //series 2
            List<string> xvals2 = new List<string>();
            List<int?> yvals2 = new List<int?>();

            foreach (DataRow dr in dsBBScoreHistory.Tables[0].Rows)
            {
                xvals2.Add(dr["RunDateDescription"].ToString());
                if (DBNull.Value.Equals(dr["OldBBScore"]))
                {
                    yvals2.Add(null);
                }
                else
                {
                    yvals2.Add(Convert.ToInt32(dr["OldBBScore"]));
                }
            }
            series2.XValueType = ChartValueType.String;
            series2.YValueType = ChartValueType.Auto;
            series2.Points.DataBindXY(xvals2.ToArray(), yvals2.ToArray());

            //legend 1
            Legend legend1 = new Legend("BB Score");
            legend1.Docking = Docking.Bottom;
            legend1.Position.Auto = false;
            legend1.Position = new ElementPosition(1, 90, 20, 10);
            series1.Legend = "BB Score";
            series1.IsVisibleInLegend = true;

            //legend 2
            Legend legend2 = new Legend("Retired BBScore");
            legend2.Docking = Docking.Bottom;
            legend2.Position.Auto = false;
            legend2.Position = new ElementPosition(21, 90, 20, 10);
            series2.Legend = "Retired BBScore";
            series2.IsVisibleInLegend = true;

            chartBBScore.Legends.Add(legend1);
            chartBBScore.Legends.Add(legend2);

            chartBBScore.Series.Add(series1);
            chartBBScore.Series.Add(series2);
        }

        /// <summary>
        /// Ties an event to call JavaScript to open pnlBBScoreChart1 when the provided updatepanel refreshes
        /// </summary>
        /// <param name="upnlBBScoreChart"></param>
        public static void RegisterPopupJS(UpdatePanel upnlBBScoreChart)
        {
            System.Web.UI.ScriptManager.RegisterStartupScript(upnlBBScoreChart, upnlBBScoreChart.GetType(), "PopupBBScoreChart", "$('#pnlBBScoreChart1').modal('show');", true);
        }
        #endregion

        /// <summary>
        /// Helper method that sets the current thread's culture using
        /// the user object.
        /// </summary>
        /// <param name="oUser"></param>
        public static void SetCulture(IPRWebUser oUser)
        {
            if (oUser == null)
            {
                return;
            }

            Thread.CurrentThread.CurrentUICulture = new CultureInfo(oUser.prwu_Culture);
            Thread.CurrentThread.CurrentCulture = new CultureInfo(oUser.prwu_Culture);

            HttpContext.Current.Response.Cookies[GetCookieID()]["Culture"] = oUser.prwu_Culture;
            HttpContext.Current.Response.Cookies[GetCookieID()]["UICulture"] = oUser.prwu_UICulture;
            HttpContext.Current.Response.Cookies[GetCookieID()]["Email"] = oUser.Email;
            //Response.Cookies[COOKIE_ID]["UserID"] = oUser.UserID;
            HttpContext.Current.Response.Cookies[GetCookieID()].Expires = DateTime.Now.AddYears(1);
        }

        public static void SetCulture(string szCulture)
        {
            Thread.CurrentThread.CurrentUICulture = new CultureInfo(szCulture);
            Thread.CurrentThread.CurrentCulture = new CultureInfo(szCulture);

            HttpContext.Current.Response.Cookies[GetCookieID()]["Culture"] = szCulture;
            HttpContext.Current.Response.Cookies[GetCookieID()]["UICulture"] = szCulture;
        }

        public static string GetCookieID()
        {
            return Utilities.GetConfigValue("CookieID", "PRCo.BBOS");
        }

        public static string GetIndustryTypeHeader(IPRWebUser oUser)
        {
            if (oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                return Resources.Global.Type;
            }

            return Resources.Global.Type + "/" + Resources.Global.Industry;
        }

        public static string GetIndustryTypeData(string type, string industry, object isLocalSource, IPRWebUser oUser)
        {
            if (oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                return type;
            }

            if (isLocalSource != DBNull.Value && (string)isLocalSource == "Y" && industry == Resources.Global.Produce) //Produce or Producto
                return Resources.Global.LocalSourceData;  //"Local Source"
            else
                return GetCompanyType(type, isLocalSource) + "-" + industry;
        }

        public static string GetCompanyType(string type, bool bIsLocalSource)
        {
            if (bIsLocalSource)
                return Resources.Global.LocalSource;
            else
                return type;
        }

        public static string GetCompanyType(string type, object isLocalSource)
        {
            if ((isLocalSource == DBNull.Value) ||
                (isLocalSource == null))
            {
                return type;
            }

            return Resources.Global.LocalSource;
        }

        /// <summary>
        /// Returns the virtual path to the current
        /// application
        /// </summary>
        /// <returns></returns>
        static public string GetVirtualPath()
        {
            return Utilities.GetConfigValue("VirtualPath");
        }

        /// <summary>
        /// Helper method returns the full URL to the specified file
        /// </summary>
        public static string GetFileDownloadURL(int publicationArticleID, string publicationCode)
        {
            return GetFileDownloadURL(publicationArticleID, 0, null, publicationCode);
        }

        /// <summary>
        /// Helper method returns the full URL to the specified file
        /// </summary>
        /// <param name="publicationArticleID"></param>
        /// <param name="sourceID"></param>
        /// <returns></returns>
        public static string GetFileDownloadURL(int publicationArticleID, int sourceID)
        {
            return GetFileDownloadURL(publicationArticleID, sourceID, null, null);
        }

        /// <summary>
        /// Helper method returns the full URL to the specified file
        /// </summary>
        /// <param name="publicationArticleID"></param>
        /// <param name="sourceID"></param>
        /// <returns></returns>
        public static string GetFileDownloadURL(int publicationArticleID, int sourceID, string sourceEntityType)
        {
            return GetFileDownloadURL(publicationArticleID, sourceID, sourceEntityType, null);
        }

        /// <summary>
        /// Helper method returns the full URL to the specified file
        /// </summary>
        /// <param name="publicationArticleID"></param>
        /// <param name="sourceID"></param>
        /// <param name="sourceEntityType"></param>
        /// <returns></returns>
        public static string GetFileDownloadURL(int publicationArticleID, int sourceID, string sourceEntityType, string publicationCode)
        {
            StringBuilder url = new StringBuilder();
            url.Append(PageConstants.GET_PUBLICATION_FILE);
            url.Append("?PublicationArticleID=" + publicationArticleID);

            if (sourceID > 0)
            {
                url.Append("&SourceID=" + sourceID);
            }

            if (!string.IsNullOrEmpty(sourceEntityType))
            {
                url.Append("&SourceEntityType=" + sourceEntityType);
            }

            if (!string.IsNullOrEmpty(publicationCode))
            {
                url.Append("&PublicationCode=" + publicationCode);
            }

            return url.ToString();
        }

        protected const string SQL_SELECT_RECENT_BPEDITION =
        @"SELECT TOP 1 prpbed_PublicationEditionID 
					FROM PRPublicationEdition (NOLOCK) 
				   WHERE GETDATE() >= prpbed_PublishDate 
				ORDER BY prpbed_PublishDate DESC";

        protected const string SQL_SELECT_EDITION_ARTICLE =
            @"SELECT {0}
                FROM PRPublicationArticle WITH (NOLOCK) 
               WHERE prpbar_PublicationEditionID = {1}
                 AND prpbar_PublicationCode = '{2}'
            ORDER BY prpbar_Sequence";

        /// <summary>
        /// Determines what the current BlueprintsEdition ID is.
        /// </summary>
        /// <returns></returns>
        public static int GetCurrentBluePrintsEdition()
        {
            object oID = GetDBAccess().ExecuteScalar(SQL_SELECT_RECENT_BPEDITION);

            if (oID == null)
            {
                return 0;
            }

            return Convert.ToInt32(oID);
        }

        public static string GetCurrentBluePrintsEditionLink(int intEditionID)
        {
            using (IDataReader reader = GetDBAccess().ExecuteReader(string.Format(SQL_SELECT_EDITION_ARTICLE, "prpbar_PublicationArticleID, prpbar_Name, prpbar_CoverArtFileName", intEditionID, "BPFB"), CommandBehavior.CloseConnection))
            {
                if (reader.Read())
                    return PageControlBaseCommon.GetFileDownloadURL(reader.GetInt32(0), intEditionID, "PRPublicationEdition");
                else
                    return string.Empty;
            }
        }

        public static string GetCurrentBluePrintsEditionCover(int intEditionID)
        {
            using (IDataReader reader = GetDBAccess().ExecuteReader(string.Format(SQL_SELECT_EDITION_ARTICLE, "prpbar_PublicationArticleID, prpbar_Name, prpbar_CoverArtFileName", intEditionID, "BPFB"), CommandBehavior.CloseConnection))
            {
                if (reader.Read())
                {
                    if (reader["prpbar_CoverArtFileName"] == DBNull.Value)
                        return string.Empty;

                    return (string)reader["prpbar_CoverArtFileName"];
                }
                else
                    return string.Empty;
            }
        }

        /// <summary>
        /// Helper method used to determine if we should display
        /// the company count value.
        /// </summary>
        /// <param name="iCount"></param>
        /// <param name="bIncludeCount"></param>
        /// <returns></returns>
        public static string GetCompanyCount(int iCount, bool bIncludeCount)
        {
            if (bIncludeCount)
            {
                return " (" + iCount.ToString() + ")";
            }
            else
            {
                return string.Empty;
            }
        }

        /// <summary>
        /// Helper method that returns a IDBAccess object.  This is
        /// cached in a member variable.
        /// </summary>
        /// <returns></returns>
        public static IDBAccess GetDBAccess()
        {
            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            oDBAccess.Logger = LoggerFactory.GetLogger();
            return oDBAccess;
        }

        public static Control FindControlRecursive(Control control, string id)
        {
            if (control == null) return null;
            //try to find the control at the current level
            Control ctrl = control.FindControl(id);

            if ((ctrl != null) &&
                (ctrl.ID != id))
            {
                return null;
            }

            if (ctrl == null)
            {
                //search the children
                foreach (Control child in control.Controls)
                {
                    ctrl = FindControlRecursive(child, id);

                    if (ctrl != null) break;
                }
            }
            return ctrl;
        }

        public const string DEFAULT_CULTURE = "en-us";
        public const string ENGLISH_CULTURE = "en-us";
        public const string SPANISH_CULTURE = "es-mx";

        public const int CODE_PRODUCTFAMILY_MEM_BR = 2;
        public const int CODE_PRODUCTFAMILY_NON_MEM_BR = 3;
        public const int CODE_PRODUCTFAMILY_MARKETING_LIST = 4;
        public const int CODE_PRODUCTFAMILY_MARKETING_LIST_MINS = 13;
        public const int CODE_PRODUCTFAMILY_ITA_BR = 16;

        public const string PROD_CODE = "BR4";
        public const string PROD_CODE_FREE = "BRF";

        public const string PROD_CODE_BASIC = "BASIC";
        public const string PROD_CODE_STANDARD = "STANDARD";
        public const string PROD_CODE_PREMIUM = "PREMIUM";
        public const string PROD_CODE_ENTERPRISE = "ENTERPRISE";

        public static string ForceEnglishDate(string szDate, string szCulture)
        {
            if (szCulture.ToLower() == SPANISH_CULTURE)
            {
                var dtSpanishFormat = DateTime.ParseExact(szDate, "dd/MM/yyyy", CultureInfo.InvariantCulture);
                string americanFormat = dtSpanishFormat.ToString("MM/dd/yyyy");

                return americanFormat;
            }
            else
                return szDate;
        }

        public static string GetCulture(IPRWebUser oUser)
        {
            if (oUser == null)
                return DEFAULT_CULTURE;
            else
                return oUser.prwu_Culture;
        }

        public static CultureInfo GetCultureInfo(IPRWebUser oUser)
        {
            return new CultureInfo(GetCulture(oUser));
        }

        public static string GetCultureInfo_ShortDatePattern(bool bLower = true)
        {
            CultureInfo oCulture = Thread.CurrentThread.CurrentCulture;
            string strPattern;

            strPattern = oCulture.DateTimeFormat.ShortDatePattern;
            if (bLower)
                strPattern = strPattern.ToLower();

            return NormalizeDatePattern(strPattern);
        }

        public static string GetCultureInfo_LongDatePattern()
        {
            CultureInfo oCulture = Thread.CurrentThread.CurrentCulture;
            string strPattern = oCulture.DateTimeFormat.LongDatePattern.ToLower();

            return NormalizeDatePattern(strPattern);
        }

        private static string NormalizeDatePattern(string strPattern)
        {
            if (strPattern.EndsWith("/yy"))
                strPattern = strPattern.Replace("/yy", "/yyyy");

            if (strPattern.StartsWith("m/"))
                strPattern = strPattern.Replace("m/", "mm/");
            else if (strPattern.StartsWith("d/"))
                strPattern = strPattern.Replace("d/", "dd/");

            if (strPattern.Contains("/m/"))
                strPattern = strPattern.Replace("/m/", "/mm/");
            else if (strPattern.Contains("/d/"))
                strPattern = strPattern.Replace("/d/", "/dd/");

            return strPattern;
        }

        public static DateTime EnglishDate(DateTime dt)
        {
            CultureInfo m_UsCulture = new CultureInfo("en-us");
            string szDate = dt.ToString(m_UsCulture);

            DateTime dtEnglish = DateTime.Parse(szDate, new CultureInfo(ENGLISH_CULTURE));
            return dtEnglish;
        }

        /// <summary>
        /// We are re-using the "ufn_IsAddressValidForRadius" function
        /// </summary>
        protected const string SQL_SELECT_ADDRESS_FOR_MAP =
            @"SELECT RTRIM(addr_Address1), RTRIM(addr_Address2), prci_City, ISNULL(prst_Abbreviation, prst_State) As State, addr_PostCode, prcn_Country 
                FROM Address WITH (NOLOCK) 
                     INNER JOIN Address_Link WITH (NOLOCK) on addr_AddressID = adli_AddressID 
                     INNER JOIN vPRLocation ON addr_PRCityID = prci_CityID 
               WHERE adli_Type IN ('PH', 'S', 'M', 'W', 'I', 'O') 
                 AND adli_CompanyID={0} 
                 AND dbo.ufn_IsAddressValidForRadius(adli_CompanyID, addr_AddressID) = 'Y';";
        static internal string GetAddressForMap(string CompanyID, out string szEmbeddedMap)
        {
            if (!string.IsNullOrEmpty(CompanyID))
                return GetAddressForMap(Convert.ToInt32(CompanyID), out szEmbeddedMap);

            szEmbeddedMap = "";
            return "";
        }
        static internal string GetAddressForMap(int CompanyID, out string szEmbeddedMap)
        {
            string szMapText = "";
            szEmbeddedMap = "";
            string szSQL = string.Format(SQL_SELECT_ADDRESS_FOR_MAP, CompanyID);
            IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection);
            try
            {
                if (oReader.Read())
                {

                    string[] args = {GetDBAccess().GetString(oReader, 0).Trim(),
                                     GetDBAccess().GetString(oReader, 1).Trim(),
                                     GetDBAccess().GetString(oReader, 2).Trim(),
                                     GetDBAccess().GetString(oReader, 3).Trim(),
                                     GetDBAccess().GetString(oReader, 4).Trim(),
                                     GetDBAccess().GetString(oReader, 5).Trim()};

                    string szEncodedAddress;
                    if (args[1] == "")
                    {
                        //param 1 omitted Defect 7463
                        szEncodedAddress = HttpUtility.UrlEncode(string.Format("{0}, {2}, {3}, {4}, {5}", args)); 
                        szMapText = string.Format("{0}, {2}, {3}, {4}, {5}", args);
                    }
                    else
                    {
                        szEncodedAddress = HttpUtility.UrlEncode(string.Format("{0}, {1}, {2}, {3}, {4}, {5}", args));
                        szMapText = string.Format("{0}, {1}, {2}, {3}, {4}, {5}", args);
                    }

                    szEmbeddedMap = string.Format(Utilities.GetConfigValue("MapURLEmbed"), szEncodedAddress);
                }

                return szMapText;
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }
        }

        static internal bool HasBusinessValuation_CurrentYear(IPRWebUser oWebUser, string statusCode=null)
        {
            BusinessValuation.BusinessValuationData oBVData = GetBusinessValuationData(oWebUser);
            return (oBVData.BusinessValuationID > 0);
        }

        protected const string SQL_BUSINESS_VALUATION_DATA =
            @"SELECT * FROM PRWebUser WITH(NOLOCK) 
	            INNER JOIN Person_Link WITH(NOLOCK) ON peli_PersonLinkID = prwu_personlinkid
	            LEFT OUTER JOIN PRBusinessValuation WITH(NOLOCK) ON (prbv_CompanyID=prwu_HQID OR prbv_CompanyID=prwu_BBID) AND YEAR(prbv_CreatedDate) = YEAR(GETDATE()) AND prbv_Deleted IS NULL 
              WHERE prwu_WebUserID = @WebUserID";

        static internal BusinessValuation.BusinessValuationData GetBusinessValuationData(IPRWebUser oWebUser)
        {
            BusinessValuation.BusinessValuationData oBVData = new BusinessValuation.BusinessValuationData();
            if (oWebUser == null)
                return oBVData;

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("WebUserID", oWebUser.prwu_WebUserID));

            using (IDataReader reader = GetDBAccess().ExecuteReader(SQL_BUSINESS_VALUATION_DATA, oParameters))
            {
                if (reader.Read())
                {
                    oBVData.oWebUser = oWebUser;
                    oBVData.CanViewBusinessValuations = (GetDBAccess().GetString(reader, "peli_PRCanViewBusinessValuations") == "Y");
                    oBVData.BusinessValuationID = GetDBAccess().GetInt32(reader, "prbv_BusinessValuationID");
                    oBVData.CreatedBy = GetDBAccess().GetInt32(reader, "prbv_CreatedBy");
                    oBVData.CreatedDate = GetDBAccess().GetDateTime(reader, "prbv_CreatedDate");
                    oBVData.CompanyID = GetDBAccess().GetInt32(reader, "prbv_CompanyID");
                    oBVData.PersonID = GetDBAccess().GetInt32(reader, "prbv_PersonID");
                    oBVData.FileName = GetDBAccess().GetString(reader, "prbv_FileName");
                    oBVData.DiskFileName = GetDBAccess().GetString(reader, "prbv_DiskFileName");
                    oBVData.StatusCode = GetDBAccess().GetString(reader, "prbv_StatusCode");
                    
                    oBVData.SentDateTime = GetDBAccess().GetDateTime(reader, "prbv_SentDateTime");
                    oBVData.ProcessedBy= GetDBAccess().GetInt32(reader, "prbv_ProcessedBy");
                    oBVData.Guid = GetDBAccess().GetString(reader, "prbv_Guid");
                }
            }

            return oBVData;
        }

        protected const string SQL_BUSINESS_VALUATION_DATA_BY_GUID =
            @"SELECT * FROM PRBusinessValuation WITH(NOLOCK) WHERE prbv_Guid=@Guid";

        static internal BusinessValuation.BusinessValuationData GetBusinessValuationData(string szGuid)
        {
            BusinessValuation.BusinessValuationData oBVData = new BusinessValuation.BusinessValuationData();

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("Guid", szGuid));

            using (IDataReader reader = GetDBAccess().ExecuteReader(SQL_BUSINESS_VALUATION_DATA_BY_GUID, oParameters))
            {
                if (reader.Read())
                {
                    oBVData.BusinessValuationID = GetDBAccess().GetInt32(reader, "prbv_BusinessValuationID");
                    oBVData.CreatedBy = GetDBAccess().GetInt32(reader, "prbv_CreatedBy");
                    oBVData.CreatedDate = GetDBAccess().GetDateTime(reader, "prbv_CreatedDate");
                    oBVData.CompanyID = GetDBAccess().GetInt32(reader, "prbv_CompanyID");
                    oBVData.PersonID = GetDBAccess().GetInt32(reader, "prbv_PersonID");
                    oBVData.FileName = GetDBAccess().GetString(reader, "prbv_FileName");
                    oBVData.DiskFileName = GetDBAccess().GetString(reader, "prbv_DiskFileName");
                    oBVData.StatusCode = GetDBAccess().GetString(reader, "prbv_StatusCode");

                    oBVData.SentDateTime = GetDBAccess().GetDateTime(reader, "prbv_SentDateTime");
                    oBVData.ProcessedBy = GetDBAccess().GetInt32(reader, "prbv_ProcessedBy");
                    oBVData.Guid = GetDBAccess().GetString(reader, "prbv_Guid");
                }
            }

            return oBVData;
        }

        protected const string SQL_HAS_BUSINESS_VALUATION_PURCHASED_CURRENT_YEAR =
                 @"SELECT COUNT(*) FROM PRRequest WITH(NOLOCK) 
                WHERE prreq_CompanyID = @prreq_HQID 
                    AND prreq_RequestTypeCode = 'BV' 
                    AND YEAR(prreq_CreatedDate) = YEAR(GETDATE())";
        /// <summary>
        /// Helper method that determines if HQ has purchased a Business Valuation in the current calendar year
        /// </summary>
        static internal bool HasBusinessValuationPurchased_CurrentYear(IPRWebUser oWebUser)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prreq_HQID", oWebUser.prwu_HQID));

            IDBAccess _oDBAccess = DBAccessFactory.getDBAccessProvider();

            object hasBVp = _oDBAccess.ExecuteScalar(SQL_HAS_BUSINESS_VALUATION_PURCHASED_CURRENT_YEAR, oParameters);
            if (hasBVp == null)
                return false;

            return ((int)hasBVp > 0);
        }
    }

    public class CheckBoxItem
    {
        public string id { get; set; }
        public string name { get; set; }
        public int level { get; set; }
        public string parentId { get; set; }
        public int count { get; set; }
        public string checkboxId { get; set; }
    }

    public class CheckBoxGroup
    {
        public CheckBoxItem root = new CheckBoxItem();
        public List<CheckBoxItem> lstItems = new List<CheckBoxItem>();
    }

    static class DataRowExtensions
    {
        public static object GetValue(this DataRow row, string column)
        {
            return GetValue(row, column, null);
        }
        public static object GetValue(this DataRow row, string column, object oDefault)
        {
            return row.Table.Columns.Contains(column) ? row[column] : oDefault;
        }
    }

    /// <summary>
    /// Provide utilities methods related to <see cref="Control"/> objects
    /// </summary>
    public static class ControlUtilities
    {
        /// <summary>
        /// Find the first ancestor of the selected control in the control tree
        /// </summary>
        /// <typeparam name="TControl">Type of the ancestor to look for</typeparam>
        /// <param name="control">The control to look for its ancestors</param>
        /// <returns>The first ancestor of the specified type, or null if no ancestor is found.</returns>
        public static TControl FindAncestor<TControl>(this Control control) where TControl : Control
        {
            if (control == null) throw new ArgumentNullException("control");

            Control parent = control;
            do
            {
                parent = parent.Parent;
                var candidate = parent as TControl;
                if (candidate != null)
                {
                    return candidate;
                }
            } while (parent != null);
            return null;
        }

        /// <summary>
        /// Finds all descendants of a certain type of the specified control.
        /// </summary>
        /// <typeparam name="TControl">The type of descendant controls to look for.</typeparam>
        /// <param name="parent">The parent control where to look into.</param>
        /// <returns>All corresponding descendants</returns>
        public static IEnumerable<TControl> FindDescendants<TControl>(this Control parent) where TControl : Control
        {
            if (parent == null) throw new ArgumentNullException("control");

            if (parent.HasControls())
            {
                foreach (Control childControl in parent.Controls)
                {
                    var candidate = childControl as TControl;
                    if (candidate != null) yield return candidate;

                    foreach (var nextLevel in FindDescendants<TControl>(childControl))
                    {
                        yield return nextLevel;
                    }
                }
            }
        }
    }

    public delegate IEnumerable MustAddaRowHandler(IEnumerable data);
}
