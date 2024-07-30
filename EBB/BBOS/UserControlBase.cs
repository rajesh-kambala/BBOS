/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2007-2020

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: UserControlBase
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using PRCo.EBB.BusinessObjects;
using TSI.DataAccess;
using TSI.Utils;
using System.Data;
using System.Collections;
using TSI.BusinessObjects;
using System.Web;
using System.Text;
using TSI.Arch;
using PRCo.EBB.Util;
using System.Web.UI;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Provides the common functionality needed by the user controls
    /// </summary>
    public class UserControlBase : UserControl
    {
        /// <summary>
        /// Prefix used to mark reference data in the cache
        /// </summary>
        protected const string REF_DATA_PREFIX = "RefData";
        protected const string REF_DATA_NAME = REF_DATA_PREFIX + "_{0}_{1}";
        protected const string REF_AD_CAMPAIGN = "AdCampaign {0}";

        /// <summary>
        /// Data manager instance for our lookup codes.
        /// </summary>
        static protected Custom_CaptionMgr _oCustom_CaptionMgr = null;

        public IPRWebUser WebUser;
        public ILogger Logger;

        protected IDBAccess _oDBAccess;
        protected GeneralDataMgr _oObjectMgr;

        /// <summary>
        /// Generic counter used when building custom display constructs
        /// with a repeater.
        /// </summary>
        protected int _iRepeaterCount;
        protected int _iRepeaterRowCount = 1;

        virtual protected void Page_Load(object sender, EventArgs e)
        {
            InitControl();
        }

        virtual protected void Page_Init(object sender, EventArgs e)
        {
            InitControl();
        }

        protected void InitControl()
        {
            WebUser = (IPRWebUser)Session["oUser"];
            Logger = (ILogger)Session["Logger"];
        }

        /// <summary>
        /// Helper method that returns an EBBObjectMgr object.  This is
        /// cached in a member variable.
        /// </summary>
        /// <returns></returns>
        public GeneralDataMgr GetObjectMgr()
        {
            if (_oObjectMgr == null)
            {
                _oObjectMgr = new GeneralDataMgr(GetLogger(), WebUser);
            }
            return _oObjectMgr;
        }

        protected IDBAccess GetDBAccess()
        {
            if (_oDBAccess == null)
            {
                _oDBAccess = DBAccessFactory.getDBAccessProvider();
                _oDBAccess.Logger = GetLogger();
            }

            return _oDBAccess;
        }

        protected ILogger GetLogger()
        {
            if (Logger == null)
            {
                Logger = LoggerFactory.GetLogger();
                if (WebUser != null)
                {
                    Logger.UserID = WebUser.UserID;
                }
                Logger.RequestName = Request.ServerVariables.Get("SCRIPT_NAME");
            }

            return Logger;
        }

        /// <summary>
        /// Log an error to the application log
        /// </summary>
        /// <param name="e"></param>
        protected void LogError(Exception e)
        {
            if (Logger != null)
            {
                Logger.LogError(e);
            }
        }

        protected const string SQL_COMPANY_HEADER_SELECT =
                    @"SELECT comp_PRCorrTradestyle, CityStateCountryShort, comp_PRListedDate, comp_PRListingStatus, comp_PRIndustryType, 
                         dbo.ufn_HasNote({1}, {2}, comp_CompanyID, 'C') As HasNote, comp_PRLastPublishedCSDate, comp_PRType, comp_PRHQID, 
                         comp_PRPublishPayIndicator, prcpi_PayIndicator, compRating.prra_RatingLine, compRating.prra_AssignedRatingNumerals, 
                         hqRating.prra_RatingLine As HQRatingLine, 
                         prbs_BBScore, prbs_PRPublish, comp_PRLocalSource, comp_PRDelistedDate,
                         comp_PRTMFMAward,
                         comp_PRTMFMAwardDate,
                         comp_PRPublishBBScore
                    FROM Company WITH (NOLOCK) 
                         INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID 
                         LEFT OUTER JOIN vPRCurrentRating compRating ON comp_CompanyID = compRating.prra_CompanyID 
                         LEFT OUTER JOIN vPRCurrentRating hqRating ON comp_PRHQID = hqRating.prra_CompanyID 
                         LEFT OUTER JOIN PRCompanyPayIndicator WITH (NOLOCK) ON comp_CompanyID = prcpi_CompanyID AND prcpi_Current='Y' 
                         LEFT OUTER JOIN PRBBScore WITH (NOLOCK) ON comp_CompanyID = prbs_CompanyID AND prbs_Current='Y' 
                   WHERE comp_CompanyID={0}";

        protected const string SQL_SELECT_COMPANY =
              @"SELECT TOP 1 *
                FROM vPRBBOSCompany
               WHERE comp_CompanyID=@comp_CompanyID";

        public const string COMPANY_DATA_KEY = "CompanyHeader_CompanyData";
        public const string COMPANY_DATA_KEY_HQ = "CompanyHeader_CompanyData_HQ";

        protected const string SQL_SELECT_LISTING_ABBR =
            @"SELECT comp_PRBookTradestyle, phon_PRDescription, dbo.ufn_FormatPhone(phon_CountryCode, phon_AreaCode, phon_Number, phon_PRExtension)  As Phone, 
                  dbo.ufn_FormatAddress('<br/>', 
                  RTRIM(ph.Addr_PRDescription),RTRIM(ph.Addr_Address1),RTRIM(ph.Addr_Address2), RTRIM(ph.Addr_Address3),RTRIM(ph.Addr_Address4),RTRIM(ph.Addr_Address5), 
                  ph.prci_CityID, RTRIM(ph.prci_City), ph.prst_StateID, ISNULL(RTRIM(ph.prst_Abbreviation), RTRIM(ph.prst_State)), ph.prcn_CountryID, RTRIM(ph.prcn_Country), RTRIM(ph.Addr_PostCode), 
                  comp_PRListingCityId, ph.adli_Type, 34, 34, 0) as PhysicalAddress,
                  dbo.ufn_FormatAddress('<br/>', 
                  RTRIM(mail.Addr_PRDescription),RTRIM(mail.Addr_Address1),RTRIM(mail.Addr_Address2), RTRIM(mail.Addr_Address3),RTRIM(mail.Addr_Address4),RTRIM(mail.Addr_Address5), 
                  mail.prci_CityID, RTRIM(mail.prci_City), mail.prst_StateID, ISNULL(RTRIM(mail.prst_Abbreviation), RTRIM(mail.prst_State)), mail.prcn_CountryID, RTRIM(mail.prcn_Country), RTRIM(mail.Addr_PostCode), 
                  comp_PRListingCityId, mail.adli_Type, 34, 34, 0) as MailingAddress,
                  ll.CityStateCountryShort
            FROM Company WITH (NOLOCK) 
                  LEFT OUTER JOIN vPRAddress ph ON comp_CompanyID = ph.adli_CompanyID AND ph.adli_Type = 'PH' AND  ph.addr_PRPublish='Y' 
                  LEFT OUTER JOIN vPRAddress mail ON comp_CompanyID = mail.adli_CompanyID AND mail.adli_Type = 'M' AND  mail.addr_PRPublish='Y' 
                  LEFT OUTER JOIN vPRLocation ll on comp_PRListingCityID = ll.prci_CityID 
                  LEFT OUTER JOIN vPRCompanyPhone phone WITH (NOLOCK) ON comp_CompanyID = phone.PLink_RecordID AND phone.phon_PRIsPhone='Y' AND phone.phon_PRPreferredPublished='Y' 
            WHERE comp_CompanyID=@CompanyID;";

        protected string GetBasicListing(string companyID)
        {
            IList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", companyID));
            string szSQL = GetObjectMgr().FormatSQL(SQL_SELECT_LISTING_ABBR, oParameters);
            using (IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null))
            {
                if (oReader.Read())
                {

                    StringBuilder listing = new StringBuilder(GetDBAccess().GetString(oReader, "CityStateCountryShort") + "<br/>");
                    listing.Append(Resources.Global.BBNumber);
                    listing.Append(companyID + "<br/>");
                    listing.Append(GetDBAccess().GetString(oReader, "comp_PRBookTradestyle") + "<br/>");

                    if (!string.IsNullOrEmpty(GetDBAccess().GetString(oReader, "PhysicalAddress")))
                    {
                        listing.Append(GetDBAccess().GetString(oReader, "PhysicalAddress") + "<br/>");
                    }
                    if (!string.IsNullOrEmpty(GetDBAccess().GetString(oReader, "MailingAddress")))
                    {
                        listing.Append(GetDBAccess().GetString(oReader, "MailingAddress") + "<br/>");
                    }

                    if (!string.IsNullOrEmpty(GetDBAccess().GetString(oReader, "phon_PRDescription")))
                    {
                        listing.Append(GetDBAccess().GetString(oReader, "phon_PRDescription"));
                        listing.Append(" ");
                        listing.Append(GetDBAccess().GetString(oReader, "Phone"));
                    }

                    return listing.ToString();
                }
                else
                    return "";
            }
        }

        /// <summary>
        /// Retrieves the lookup value based on the specified
        /// lookup code.
        /// </summary>
        /// <param name="szRefDataType">Reference Data Type</param>
        /// <param name="iRefDataCode">Reference Data Code</param>
        /// <returns>Reference Data Value</returns>
        public string GetReferenceValue(object szRefDataType, object iRefDataCode)
        {
            return GetReferenceValue(Convert.ToString(szRefDataType), Convert.ToString(iRefDataCode));
        }

        /// <summary>
        /// Retrieves the lookup value based on the specified
        /// lookup code.
        /// </summary>
        /// <param name="szRefDataType">Reference Data Type</param>
        /// <param name="szRefDataCode">Reference Data Code</param>
        /// <returns>Reference Data Value</returns>
        public string GetReferenceValue(string szRefDataType, string szRefDataCode)
        {
            if (string.IsNullOrEmpty(szRefDataCode))
            {
                return "Unknown";
            }

            IBusinessObjectSet osRefData = GetReferenceData(szRefDataType);
            foreach (ICustom_Caption oLC in osRefData)
            {
                if (oLC.Code == szRefDataCode)
                {
                    return oLC.Meaning;
                }
            }

            throw new ApplicationUnexpectedException("Unable to find meaning for code - " + szRefDataType + ":" + szRefDataCode);
        }

        /// <summary>
        /// Returns the set of LookupValue objects for the
        /// specified value name.
        /// </summary>
        /// <param name="szName">Value Name</param>
        /// <returns>LookupValue objects</returns>
        public IBusinessObjectSet GetReferenceData(string szName)
        {
            return GetReferenceData(szName, GetCurrentCulture(WebUser));
        }

        /// <summary>
        /// Returns the set of LookupValue objects for the
        /// specified value name.
        /// </summary>
        /// <param name="szName">Value Name</param>
        /// <param name="szCulture">The culture to use when retrieving the data</param>
        /// <returns>LookupValue objects</returns>
        static public IBusinessObjectSet GetReferenceData(string szName, string szCulture)
        {
            string szCacheName = string.Format(REF_DATA_NAME, szName, szCulture);

            IBusinessObjectSet oRefData = (BusinessObjectSet)HttpRuntime.Cache[szCacheName];
            if (oRefData == null)
            {
                switch (szName)
                {
                    case "IntegrityRating":
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT prin_IntegrityRatingID, prin_Name FROM PRIntegrityRating WITH (NOLOCK) WHERE prin_IsNumeral IS NULL ORDER BY prin_Order desc");
                        break;
                    case "IntegrityRating2_Display":
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT prin_IntegrityRatingID As Code, prin_Name + ' - ' + dbo.ufn_GetCustomCaptionValue('prin_Name', prin_Name, '" + szCulture + "') As Meaning FROM PRIntegrityRating WITH (NOLOCK) WHERE prin_IntegrityRatingID NOT IN (3,4) ORDER BY prin_Order DESC");
                        break;
                    case "IntegrityRating2_All":
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT prin_IntegrityRatingID As Code, prin_Name + ' - ' + dbo.ufn_GetCustomCaptionValue('prin_Name', prin_Name, '" + szCulture + "') As Meaning FROM PRIntegrityRating WITH (NOLOCK) ORDER BY prin_Order DESC");
                        break;
                    case "IntegrityRating3":
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT prin_IntegrityRatingID As Code, prin_Name + ' - ' + dbo.ufn_GetCustomCaptionValue('prin_Name', prin_Name, '" + szCulture + "') As Meaning FROM PRIntegrityRating WITH (NOLOCK) WHERE prin_IsNumeral IS NULL ORDER BY prin_Order DESC");
                        break;
                    case "TESPayRating":
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT prpy_PayRatingId, prpy_TradeReportDescription FROM PRPayRating WITH (NOLOCK) WHERE prpy_IsNumeral IS NULL AND prpy_Deleted IS NULL ORDER BY prpy_Order");
                        break;
                    case "CreditWorthRating":
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT prcw_CreditWorthRatingID, prcw_Name FROM PRCreditWorthRating WITH (NOLOCK) WHERE prcw_IsNumeral IS NULL ORDER BY prcw_Order desc");
                        break;
                    case "CreditWorthRating2": // Non-Lumber Credit Worth Ratings
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT prcw_CreditWorthRatingId  As Code, prcw_Name As Meaning FROM PRCreditWorthRating WITH (NOLOCK) WHERE prcw_IndustryType LIKE '%,P,%' AND prcw_IsNumeral IS NULL ORDER BY prcw_Order DESC");
                        break;
                    case "CreditWorthRating2L": // Lumber Credit Worth Ratings
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT prcw_CreditWorthRatingId  As Code, prcw_Name As Meaning FROM PRCreditWorthRating WITH (NOLOCK) WHERE prcw_IndustryType LIKE '%,L,%' AND prcw_IsNumeral IS NULL ORDER BY prcw_Order DESC");
                        break;
                    case "PayRating2":
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT prpy_PayRatingId As Code, prpy_Name + ' - ' + dbo.ufn_GetCustomCaptionValue('prpy_Name', prpy_Name, '" + szCulture + "') As Meaning FROM PRPayRating WITH (NOLOCK) WHERE prpy_IsNumeral IS NULL AND prpy_Deleted IS NULL ORDER BY prpy_Order");
                        break;
                    case "DLPhrases":
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT prdlp_DLPhraseID, prdlp_Phrase FROM PRDLPhrase WITH (NOLOCK) ORDER BY prdlp_Order");
                        break;
                    case "StockExchanges":
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT prex_StockExchangeId, prex_Name FROM PRStockExchange WITH (NOLOCK) WHERE prex_Publish = 'Y' ORDER BY prex_Order");
                        break;
                    case "PayIndicator":
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT capt_code As Code, capt_code + ' - ' + cast(capt_us as varchar(max)) As Meaning FROM Custom_Captions WHERE capt_family = 'PayIndicatorDescription' ORDER BY capt_Order");
                        break;
                    case "NewProduct":
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT prod_code, prod_name, prod_productfamilyid FROM NewProduct WHERE prod_productfamilyid = 5 ORDER BY prod_PRSequence");
                        break;
                    case "NewProduct_Lumber":
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT prod_code, REPLACE(prod_name, 'Blue Book Service: ', 'BBS-'), prod_productfamilyid, prod_IndustryTypeCode FROM NewProduct WHERE prod_productfamilyid = 5 AND prod_IndustryTypeCode LIKE '%L%' ORDER BY prod_PRSequence ");
                        break;
                    case "NewProduct_Produce":
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT prod_code, REPLACE(prod_name, 'Blue Book Service: ', 'BBS-'), prod_productfamilyid, prod_IndustryTypeCode FROM NewProduct WHERE prod_productfamilyid = 5 AND prod_IndustryTypeCode not LIKE '%L%' ORDER BY prod_PRSequence");
                        break;
                    case "prci_SalesTerritory":
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT capt_code As Code, capt_code + ' ' + cast(capt_us as varchar(max)) As Meaning FROM Custom_Captions WHERE capt_family = 'prci_SalesTerritory' ORDER BY capt_Order");
                        break;
                    case "NumEmployees":
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT capt_code As Code, cast(capt_us as varchar(max)) As Meaning FROM Custom_Captions WHERE capt_family = 'NumEmployees' AND capt_code <> '0' ORDER BY capt_Order");
                        break;

                    default:
                        if (_oCustom_CaptionMgr == null)
                        {
                            _oCustom_CaptionMgr = new Custom_CaptionMgr();
                        }
                        oRefData = new Custom_CaptionMgr().GetByName(szName);
                        break;
                }

                if (oRefData.Count > 0)
                {
                    HttpRuntime.Cache.Insert(szCacheName, oRefData);
                }
            }

            if (oRefData.Count == 0)
            {
                throw new ApplicationUnexpectedException("No values found for reference data named '" + szName + "' and culture '" + szCulture + "'.");
            }

            // We want to make a copy of our lookup set because some of our
            // callers manipulate the set which we don't want affecting
            // others.
            IBusinessObjectSet oNewSet = new BusinessObjectSet(oRefData);

            return oNewSet;
        }

        static public int IncrementCacheCount(string szCacheName)
        {
            int intCacheCount = 0;

            if (HttpRuntime.Cache[szCacheName] == null)
                intCacheCount = 1;
            else
                intCacheCount = Convert.ToInt32(HttpRuntime.Cache[szCacheName]) + 1;

            HttpRuntime.Cache[szCacheName] = intCacheCount;
            return intCacheCount;
        }

        /// <summary>
        /// Builds a set of Custom_Caption objects that is not queried from the 
        /// custom_caption table.  The specified SQL is expected to have the 
        /// code in position 0 and the meaning in position 1.
        /// </summary>
        /// <param name="szName">The name to give to the custom caption</param>
        /// <param name="szSQL"></param>
        /// <returns></returns>
        protected static IBusinessObjectSet GetNonCustomCaptionRefData(string szName, string szSQL)
        {
            IBusinessObjectSet oList = new BusinessObjectSet();

            IDataReader oReader = DBAccessFactory.getDBAccessProvider().ExecuteReader(szSQL, CommandBehavior.CloseConnection);
            try
            {
                while (oReader.Read())
                {
                    ICustom_Caption oCaption = new Custom_Caption();
                    oCaption.Name = szName;
                    oCaption.Code = oReader[0].ToString().Trim();
                    oCaption.Meaning = oReader[1].ToString().Trim();
                    oList.Add(oCaption);
                }
                return oList;
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }
        }

        /// <summary>
        /// Returns the NoResultsFoundMsg configuration value.
        /// </summary>
        /// <returns></returns>
        static public string GetNoResultsFoundMsg(string szName)
        {
            return string.Format(Resources.Global.NoResultsFoundMsg, szName);
        }

        virtual protected string GetBeginColumnSeparator(int count, int columns)
        {
            return GetBeginColumnSeparator(count, columns, _iRepeaterCount);
        }

        virtual protected string GetBeginColumnSeparator(int count, int columns, int index)
        {
            int perColCount = count / columns;
            if (count % 2 != 0)
            {
                perColCount++;
            }

            if (_iRepeaterRowCount == 1)
            {
                return "<td valign=\"top\" width=\"50%\"><table>";
            }
            return string.Empty;
        }

        virtual protected string GetEndColumnSeparator(int count, int columns)
        {
            return GetEndColumnSeparator(count, columns, _iRepeaterCount);
        }

        virtual protected string GetEndColumnSeparator(int count, int columns, int index)
        {
            int perColCount = count / columns;
            if (count % 2 != 0)
            {
                perColCount++;
            }

            if ((index == count) ||
                (_iRepeaterRowCount == perColCount) ||
                (count == 0))
            {
                _iRepeaterRowCount = 0;
                return "</table></td>";

            }
            return string.Empty;
        }

        protected void SetReturnURL(string szURL)
        {
            Session["ReturnURL"] = szURL;
        }

        /// <summary>
        /// Add a message to the queue to display to
        /// the user when the page is rendered.
        /// </summary>
        public void AddUserMessage(string szMsg)
        {
            string szTemp = szMsg.Replace("\n", "NEWLINE");

            HttpContext.Current.Session[PageBase.USER_MSG_ID] = szTemp;
        }
    }
}
