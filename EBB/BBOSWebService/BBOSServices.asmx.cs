/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: BBOSServices.asmx.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.IO;
using System.Text;
using System.Web.Services;
using System.Web.Services.Protocols;
using System.Xml.Serialization;
using PRCo.EBB.BusinessObjects;
using PRCo.BBS;

using TSI.Arch;
using TSI.BusinessObjects;
using TSI.DataAccess;
using TSI.Utils;
using System.Resources;
using System.Runtime.Remoting.Messaging;

namespace PRCo.BBOS.WebServices {

    /// <summary>
    /// This web services provides B2B access to Blue Book Services data.  Only
    /// listed companies are ever returned.  There are a variety of methods
    /// an external component can request listing data.
    /// 
    /// <remarks>
    /// The XML returned is intentionally configured so that if a data element is
    /// NULL or not present, the corresponding XML nodes are not returned.  While we
    /// could return empty nodes, this is innefficent for our purposes.  The consumer
    /// application may be required to check for NULL nodes.
    /// </remarks>
    /// </summary>
    [WebService(Namespace = "http://www.bluebookprco.com/bbwebservices", Name = "Blue Book Web Services", Description = "The BBOS web services provices a B2B mechanism for members to easily extract data from the BBOS and import into local system.  A license key is required to access this service.  For more information, please contact Blue Book Services, Inc. at 630-668-3500 or <a href=\"mailto:info@bluebookservices.com\">info@bluebookservices.com</a>.")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [ToolboxItem(false)]
    public class BBOSServices : System.Web.Services.WebService {

        protected IPRWebUser _oWebUser = null;
        protected ILogger _oLogger = null;
        protected IDBAccess _oDBAccess = null;
        protected GeneralDataMgr _oObjectMgr = null;
        
        protected int _iLicenseHQID = 0;
        protected string _licenseKeyIndustryTypeCodes = null;

        [WebMethod(Description = "Returns the BBID for the specified user.")]
        public int GetUserBBID(string LicenseKey,
                               string LicensePassword,
                               string UserLoginID,
                               string UserPassword)
        {

            try
            {
                int iAccessLevel = Authenticate(LicenseKey,
                                                LicensePassword,
                                                UserLoginID,
                                                UserPassword,
                                                "GetUserBBID",
                                                -1);

                return _oWebUser.prwu_BBID;
            }
            catch (ApplicationExpectedException exExpected)
            {
                // Throw a SOAP Exception here to set the client fault code.
                throw new SoapException(exExpected.Message, SoapException.ClientFaultCode);
            }
            catch (Exception e)
            {
                // Log the error, and throw a new exception so the stack trace
                // is not sent to the client.
                GetLogger().LogError(e);
                throw new ApplicationException("A system error has occurred.  Blue Book Services support has been notified.");
            }
            finally
            {
                GetLogger().LogMessage("Finished");
            }
        }



        [WebMethod(Description = "Returns a list of HQ companies matching the specified criteria")]
        public CompanyFindResult[] FindCompany(string LicenseKey,
                                     string LicensePassword,
                                     string UserLoginID,
                                     string UserPassword,
                                     string CompanyName,
                                     string City,
                                     string State,
                                     string CompanyPhone1,
                                     string CompanyPhone2,
                                     string CompanyPhone3,
                                     string CompanyEmail,
                                     string Website)
        {

            try
            {
                int iAccessLevel = Authenticate(LicenseKey,
                                                LicensePassword,
                                                UserLoginID,
                                                UserPassword,
                                                "FindCompany",
                                                1);

                if (IsTestInstance())
                    return GetTestFindCompany("FindCompany");

                List<CompanyFindResult> lCompanies = FindCompany(CompanyName, City, State,
                                                       CompanyPhone1, CompanyPhone2, CompanyPhone3,
                                                       CompanyEmail, Website);
                return lCompanies.ToArray();
            }
            catch (ApplicationExpectedException exExpected)
            {
                // Throw a SOAP Exception here to set the client fault code.
                throw new SoapException(exExpected.Message, SoapException.ClientFaultCode);
            }
            catch (Exception e)
            {
                // Log the error, and throw a new exception so the stack trace
                // is not sent to the client.
                GetLogger().LogError(e);
                throw new ApplicationException("A system error has occurred.  Blue Book Services support has been notified.");
            }
            finally
            {
                GetLogger().LogMessage("Finished");
            }
        }


        /// <summary>
        /// Returns data for the specified BBID.  The user is authenticated
        /// and only listed BBIDs are returned.
        /// </summary>
        /// <param name="LicenseKey"></param>
        /// <param name="LicensePassword"></param>
        /// <param name="UserLoginID"></param>
        /// <param name="UserPassword"></param>
        /// <param name="BBID"></param>
        /// <returns></returns>
        [WebMethod (Description = "Returns listing data for a single company.")]
        public Company GetListingDataForCompany(string LicenseKey,
                                                string LicensePassword,
                                                string UserLoginID,
                                                string UserPassword,
                                                int BBID) {
            try {                                                
                int iAccessLevel = Authenticate(LicenseKey, 
                                                LicensePassword, 
                                                UserLoginID, 
                                                UserPassword, 
                                                "GetListingDataForCompany", 
                                                1);
        
                if (IsTestInstance()) 
                    return GetTestCompany("GetListingDataForCompany");

                List<Company> lCompanies = GetCompanyData(BBID, iAccessLevel);
                GetLogger().LogMessage("Data retrieved. Now returning it.");
                
                if (lCompanies.Count > 0) {                                                      
                    return lCompanies[0];
                }
                
                return null;
            }
            catch (ApplicationExpectedException exExpected) {
                // Throw a SOAP Exception here to set the client fault code.
                throw new SoapException(exExpected.Message, SoapException.ClientFaultCode);
            } catch (Exception e) {
                // Log the error, and throw a new exception so the stack trace
                // is not sent to the client.
                GetLogger().LogError(e);
                throw new ApplicationException("A system error has occurred.  Blue Book Services support has been notified.");
            } finally {
                GetLogger().LogMessage("Finished");             
            }
        }

        protected const string SQL_USERLIST_SELECT = "SELECT prwucl_WebUserListID FROM PRWebUserList WITH (NOLOCK) WHERE prwucl_Name = {0} AND ((prwucl_HQID={1} AND prwucl_IsPrivate IS NULL) OR (prwucl_WebUserID={2} AND prwucl_IsPrivate = 'Y'))";
        
        /// <summary>
        /// Returns listing data for all listed companies in the specified watchdog list name. The user
        /// is authenticated and only listed companies are returned.
        /// </summary>
        /// <param name="LicenseKey"></param>
        /// <param name="LicensePassword"></param>
        /// <param name="UserLoginID"></param>
        /// <param name="UserPassword"></param>
        /// <param name="WatchdogListName"></param>
        /// <returns></returns>
        [WebMethod(Description = "Returns listing data for all listed companies in the specified watchdog list name.")]
        public Company[] GetListingDataForWatchdogList(string LicenseKey,
                                                       string LicensePassword,
                                                       string UserLoginID,
                                                       string UserPassword,
                                                       string WatchdogListName) {

            try {
                int iAccessLevel = Authenticate(LicenseKey,
                                                LicensePassword,
                                                UserLoginID,
                                                UserPassword,
                                                "GetListingDataForWatchdogList",
                                                1);

                if (string.IsNullOrEmpty(WatchdogListName)) {
                    throw new ApplicationExpectedException("Empty WatchdogListName value specified.");
                }

                if (IsTestInstance()) {
                    return GetTestCompanies("GetListingDataForWatchdogList");
                }


                ArrayList oParameters = new ArrayList();
                oParameters.Add(new ObjectParameter("prwucl_Name", WatchdogListName));
                oParameters.Add(new ObjectParameter("prwucl_HQID", _oWebUser.prwu_HQID));
                oParameters.Add(new ObjectParameter("prwucl_WebUserID", _oWebUser.prwu_WebUserID));
                string szSQL = GetObjectMgr().FormatSQL(SQL_USERLIST_SELECT, oParameters);

                object oListID = GetDBAccess().ExecuteScalar(szSQL, oParameters);                            
                if (oListID == null) {
                    throw new ApplicationExpectedException("Specified watchdog list name not found.");
                }

                List<Company> lCompanies = GetCompanyData(null, Convert.ToInt32(oListID), iAccessLevel);
                GetLogger().LogMessage("Data retrieved. Now returning it.");
                return lCompanies.ToArray();
            }
            catch (ApplicationExpectedException exExpected) {
                // Throw a SOAP Exception here to set the client fault code.
                throw new SoapException(exExpected.Message, SoapException.ClientFaultCode);
            }
            catch (Exception e) {
                // Log the error, and throw a new exception so the stack trace
                // is not sent to the client.
                GetLogger().LogError(e);
                throw new ApplicationException("A system error has occurred.  Blue Book Services support has been notified.");
            } finally {
                GetLogger().LogMessage("Finished");
            }
        }

        /// <summary>
        /// Returns listing data for all listed companies in the specified list.  
        /// The BB #s should be delimited by commas.  The user
        /// is authenticated and only listed companies are returned.
        /// </summary>
        /// <param name="LicenseKey"></param>
        /// <param name="LicensePassword"></param>
        /// <param name="UserLoginID"></param>
        /// <param name="UserPassword"></param>
        /// <param name="CompanyIDList"></param>
        /// <returns></returns>
        [WebMethod(Description = "Returns listing data for all listed companies in the specified list.  The BB #s should be delimited by commas.")]
        public Company[] GetListingDataForCompanyList(string LicenseKey,
                                                      string LicensePassword,
                                                      string UserLoginID,
                                                      string UserPassword,
                                                      string CompanyIDList) {
            try {
                if ((CompanyIDList == null) ||
                    (CompanyIDList.Length == 0)) {
                    throw new ApplicationExpectedException("Empty CompanyIDs list specified.");
                }

                List<string> szBBIDs = new List<string>();
                string[] aszCompanyIDs = CompanyIDList.Split(',');
                foreach (string szBBID in aszCompanyIDs) {
                    szBBIDs.Add(szBBID.Trim());
                }

                int iAccessLevel = Authenticate(LicenseKey,
                                                LicensePassword,
                                                UserLoginID,
                                                UserPassword,
                                                "GetListingDataForCompanyList",
                                                szBBIDs.Count);


                if (IsTestInstance()) {
                    return GetTestCompanies("GetListingDataForCompanyList");
                }

                List<Company> lCompanies = GetCompanyData(szBBIDs, iAccessLevel);
                GetLogger().LogMessage("Data retrieved. Now returning it.");
                return lCompanies.ToArray();
            }
            catch (ApplicationExpectedException exExpected) {
                // Throw a SOAP Exception here to set the client fault code.
                throw new SoapException(exExpected.Message, SoapException.ClientFaultCode);
            }
            catch (Exception e) {
                // Log the error, and throw a new exception so the stack trace
                // is not sent to the client.
                GetLogger().LogError(e);
                throw new ApplicationException("A system error has occurred.  Blue Book Services support has been notified.");
            }
            finally {
                GetLogger().LogMessage("Finished");
            }
                
        }

        /// <summary>
        /// Returns data for all listed BBIDs.  The user is authenticated
        /// and only listed BBIDs are returned.
        /// </summary>
        /// <param name="LicenseKey"></param>
        /// <param name="LicensePassword"></param>
        /// <param name="UserLoginID"></param>
        /// <param name="UserPassword"></param>
        /// <returns></returns>
        [WebMethod(Description = "Returns listing data for all listed companies.")]
        public Company[] GetListingDataForAllCompanies(string LicenseKey,
                                                       string LicensePassword,
                                                       string UserLoginID,
                                                       string UserPassword) {
            try {
                int iAccessLevel = Authenticate(LicenseKey,
                                                LicensePassword,
                                                UserLoginID,
                                                UserPassword,
                                                "GetListingDataForAllCompanies",
                                                -1);

                if (IsTestInstance()) {
                    return GetTestCompanies("GetListingDataForAllCompanies");
                }
               
                TimeSpan tsStartTime = new TimeSpan(Utilities.GetIntConfigValue("GetListingDataForAllCompaniesStartWindowHour", 20),
                                                    Utilities.GetIntConfigValue("GetListingDataForAllCompaniesStartWindowMinute", 0),
                                                    0);
                DateTime dtStartDateTime = DateTime.Today.Add(tsStartTime);

                TimeSpan tsEndTime = new TimeSpan(Utilities.GetIntConfigValue("GetListingDataForAllCompaniesEndWindowHour", 5),
                                                    Utilities.GetIntConfigValue("GetListingDataForAllCompaniesEndWindowMinute", 0),
                                                    0);
                DateTime dtEndDateTime = DateTime.Today.Add(tsEndTime);                                                    

               
                if ((DateTime.Now < dtStartDateTime) &&
                    (DateTime.Now > dtEndDateTime)) {
                    string szMsg = "This web method is only available before " + dtEndDateTime.ToString("h:mm tt") + " and after " + dtStartDateTime.ToString("h:mm tt") + " central time.";
                    throw new ApplicationExpectedException(szMsg);
                }


                List<Company> lCompanies = GetCompanyData(iAccessLevel);
                GetLogger().LogMessage("Data retrieved. Now returning it.");
                
                return lCompanies.ToArray();
            }
            catch (ApplicationExpectedException exExpected) {
                // Throw a SOAP Exception here to set the client fault code.
                throw new SoapException(exExpected.Message, SoapException.ClientFaultCode);
            }
            catch (Exception e) {
                // Log the error, and throw a new exception so the stack trace
                // is not sent to the client.
                GetLogger().LogError(e);
                throw new ApplicationException("A system error has occurred.  Blue Book Services support has been notified.");
            }
            finally {
                GetLogger().LogMessage("Finished");
            }
        }


        [WebMethod(Description = "Returns listing and person data for all listed companies.")]
        public Company[] GetListingAndPersonDataForAllCompanies(string LicenseKey,
                                                       string LicensePassword,
                                                       string UserLoginID,
                                                       string UserPassword)
        {
            try
            {
                int iAccessLevel = Authenticate(LicenseKey,
                                                LicensePassword,
                                                UserLoginID,
                                                UserPassword,
                                                "GetListingAndPersonDataForAllCompanies",
                                                -1);

                if (IsTestInstance())
                {
                    return GetTestCompanies("GetListingAndPersonDataForAllCompanies");
                }

                List<Company> lCompanies = GetCompanyData(null, 0, iAccessLevel, true);

                GetLogger().LogMessage("Data retrieved. Now returning it.");

                return lCompanies.ToArray();

            }
            catch (ApplicationExpectedException exExpected)
            {
                // Throw a SOAP Exception here to set the client fault code.
                throw new SoapException(exExpected.Message, SoapException.ClientFaultCode);
            }
            catch (Exception e)
            {
                // Log the error, and throw a new exception so the stack trace
                // is not sent to the client.
                GetLogger().LogError(e);
                throw new ApplicationException("A system error has occurred.  Blue Book Services support has been notified.");
            }
            finally
            {
                GetLogger().LogMessage("Finished");
            }
        }

        /// <summary>
        /// Returns listing data for all listed companies in the specified list.  
        /// The BB #s should be delimited by commas.  The user
        /// is authenticated and only listed companies are returned.
        /// </summary>
        /// <param name="LicenseKey"></param>
        /// <param name="LicensePassword"></param>
        /// <param name="UserLoginID"></param>
        /// <param name="UserPassword"></param>
        /// <param name="CompanyIDList"></param>
        /// <returns></returns>
        [WebMethod(Description = "Returns general company data for all listed companies in the specified list.  The BB #s should be delimited by commas.")]
        public Company[] GetGeneralCompanyData(string LicenseKey,
                                               string LicensePassword,
                                               string UserLoginID,
                                               string UserPassword,
                                               string CompanyIDList) {

            try {
                if ((CompanyIDList == null) ||
                    (CompanyIDList.Length == 0)) {
                    throw new ApplicationExpectedException("Empty CompanyIDs list specified.");
                }

                List<string> szBBIDs = new List<string>();
                string[] aszCompanyIDs = CompanyIDList.Split(',');
                foreach (string szBBID in aszCompanyIDs) {
                    szBBIDs.Add(szBBID.Trim());
                }

                int iAccessLevel = Authenticate(LicenseKey,
                                                LicensePassword,
                                                UserLoginID,
                                                UserPassword,
                                                "GetGeneralCompanyData",
                                                szBBIDs.Count);

                if (IsTestInstance()) {
                    return GetTestCompanies("GetGeneralCompanyData");
                }



                List<Company> lCompanies = GetCompanyData(szBBIDs, iAccessLevel);
                GetLogger().LogMessage("Data retrieved. Now returning it.");
                return lCompanies.ToArray();
            }
            catch (ApplicationExpectedException exExpected) {
                // Throw a SOAP Exception here to set the client fault code.
                throw new SoapException(exExpected.Message, SoapException.ClientFaultCode);
            }
            catch (Exception e) {
                // Log the error, and throw a new exception so the stack trace
                // is not sent to the client.
                GetLogger().LogError(e);
                throw new ApplicationException("A system error has occurred.  Blue Book Services support has been notified.");
            }
            finally {
                GetLogger().LogMessage("Finished");
            }
        }



        /// <summary>
        /// Returns listing data for all listed companies in the specified list.  
        /// The BB #s should be delimited by commas.  The user
        /// is authenticated and only listed companies are returned.
        /// </summary>
        /// <param name="LicenseKey"></param>
        /// <param name="LicensePassword"></param>
        /// <param name="UserLoginID"></param>
        /// <param name="UserPassword"></param>
        /// <param name="CompanyIDList"></param>
        /// <returns></returns>
        [WebMethod(Description = "Returns general and rating company data for all listed companies in the specified list.  The BB #s should be delimited by commas.")]
        public Company[] GetRatingCompanyData(string LicenseKey,
                                              string LicensePassword,
                                              string UserLoginID,
                                              string UserPassword,
                                              string CompanyIDList) {

            try {
                if ((CompanyIDList == null) ||
                    (CompanyIDList.Length == 0)) {
                    throw new ApplicationExpectedException("Empty CompanyIDs list specified.");
                }

                List<string> szBBIDs = new List<string>();
                string[] aszCompanyIDs = CompanyIDList.Split(',');
                foreach (string szBBID in aszCompanyIDs) {
                    szBBIDs.Add(szBBID.Trim());
                }

                int iAccessLevel = Authenticate(LicenseKey,
                                                LicensePassword,
                                                UserLoginID,
                                                UserPassword,
                                                "GetRatingCompanyData",
                                                szBBIDs.Count);

                if (IsTestInstance()) {
                    return GetTestCompanies("GetRatingCompanyData");
                }

                List<Company> lCompanies = GetCompanyData(szBBIDs, iAccessLevel);
                GetLogger().LogMessage("Data retrieved. Now returning it.");
                return lCompanies.ToArray();
            }
            catch (ApplicationExpectedException exExpected) {
                // Throw a SOAP Exception here to set the client fault code.
                throw new SoapException(exExpected.Message, SoapException.ClientFaultCode);
            }
            catch (Exception e) {
                // Log the error, and throw a new exception so the stack trace
                // is not sent to the client.
                GetLogger().LogError(e);
                throw new ApplicationException("A system error has occurred.  Blue Book Services support has been notified.");
            }
            finally {
                GetLogger().LogMessage("Finished");
            }
        }

        [WebMethod(Description = "Returns a Business Report PDF file on the specified subject company.")]
        public byte[] GetBusinessReport(string LicenseKey,
                                        string LicensePassword,
                                        string UserLoginID,
                                        string UserPassword,
                                        int BBID)
        {
            try
            {
                int iAccessLevel = Authenticate(LicenseKey,
                                                LicensePassword,
                                                UserLoginID,
                                                UserPassword,
                                                "GetBusinessReport",
                                                1);

                if (IsTestInstance())
                {
                    // If lumber only, then return a lumber BR.
                    if (IsLumber())
                        BBID = Utilities.GetIntConfigValue("SampleBusinessReportLUmberCompanyID", 211322);
                    else
                        BBID = Utilities.GetIntConfigValue("SampleBusinessReportProduceCompanyID", 102030);
                }

                List<Company> lCompanies = GetCompanyData(BBID, iAccessLevel);
                if (lCompanies.Count == 0)
                    return null;

                bool bIncludeBalanceSheet = false;
                bool bIncludeSurvey = false;

                int iReportLevel = 3;
                int iRequestID = 0;
                bool bIsEligibleForEquifaxData = false;

                ReportInterface reportInteface = new ReportInterface();
                byte[] businessReport = reportInteface.GenerateBusinessReport(BBID.ToString(), iReportLevel, bIncludeBalanceSheet, bIncludeSurvey, iRequestID, bIsEligibleForEquifaxData, _iLicenseHQID);

                return businessReport;
            }
            catch (ApplicationExpectedException exExpected)
            {
                // Throw a SOAP Exception here to set the client fault code.
                throw new SoapException(exExpected.Message, SoapException.ClientFaultCode);
            }
            catch (Exception e)
            {
                // Log the error, and throw a new exception so the stack trace
                // is not sent to the client.
                GetLogger().LogError(e);
                throw new ApplicationException("A system error has occurred.  Blue Book Services support has been notified.");
            }
            finally
            {
                GetLogger().LogMessage("Finished");
            }
        }

        #region GetCompanyData Methods
        protected const string SQL_SELECT_COMPANIES =
            @"SELECT comp_CompanyID, comp_PRHQID, comp_PRBookTradestyle, prci_City, prst_State, prcn_Country, dbo.ufn_GetCustomCaptionValue('comp_PRIndustryType', comp_PRIndustryType, '{0}') As comp_PRIndustryType, em.emai_EmailAddress, ws.emai_PRWebAddress, dbo.ufn_GetCustomCaptionValue(CASE comp_PRIndustryType WHEN 'L' THEN 'prcp_VolumeL' ELSE 'prcp_Volume' END, prcp_Volume, '{0}') As prcp_Volume, dbo.ufn_GetCustomCaptionValue('comp_PRType', comp_PRType, '{0}') As comp_PRType, comp_PRTradestyle1, comp_PRTradestyle2, 
                    comp_PRFinancialStatementDate, dbo.ufn_GetCustomCaptionValue('prfs_Type', prfs_Type, '{0}') As prfs_Type, comp_PRCorrTradestyle, ISNULL(comp_PRTMFMAward, 'N') comp_PRTMFMAward, comp_PRTMFMAwardDate,
                    AveIntegrity, IndustryAveIntegrity, dbo.ufn_getPreviousRatingLine(comp_CompanyID) PreviousRatingLine, compRating.prra_Date,
                    dbo.ufn_GetCustomCaptionValue('NumEmployees', prcp_FTEmployees, '{0}') As prcp_FTEmployees
                FROM Company WITH (NOLOCK) 
                     INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID 
                     LEFT OUTER JOIN vCompanyEmail ws WITH (NOLOCK) ON comp_CompanyID = ws.elink_RecordID AND ws.elink_Type='W' AND ws.emai_PRPreferredPublished='Y' 
                     LEFT OUTER JOIN vCompanyEmail em WITH (NOLOCK) ON comp_CompanyID = em.elink_RecordID AND em.elink_Type='E' AND em.emai_PRPreferredPublished='Y' 
                     LEFT OUTER JOIN PRCompanyProfile WITH (NOLOCK) ON comp_CompanyID = prcp_CompanyID 
                     LEFT OUTER JOIN PRWebUserCustomData WITH (NOLOCK) ON comp_CompanyID = prwucd_AssociatedID AND prwucd_AssociatedType='C' AND prwucd_LabelCode = '1' AND prwucd_HQID={1} 
                     LEFT OUTER JOIN PRFinancial WITH (NOLOCK) ON comp_CompanyID = prfs_CompanyID AND comp_PRFinancialStatementDate = prfs_StatementDate 
                     LEFT OUTER JOIN 
                     (
                        SELECT prtr_SubjectID, 
                            AVG(CAST(prin_Weight as decimal(6,3))) as AveIntegrity,       
                            CASE WHEN capt_US IS NULL THEN '0' ELSE capt_US END AS IndustryAveIntegrity
						FROM PRTradeReport WITH (NOLOCK)
                            INNER JOIN PRIntegrityRating WITH (NOLOCK) ON prtr_IntegrityId = prin_IntegrityRatingId
							INNER JOIN Company C1 WITH (NOLOCK) ON Comp_CompanyId = prtr_SubjectId
							LEFT OUTER JOIN custom_captions WITH (NOLOCK) ON capt_family = 'IndustryAverageRatings_'  + C1.comp_PRIndustryType AND capt_code = 'IntegrityAverage_Current'
						WHERE prtr_Date >= DATEADD(month, -6, GETDATE())
							AND prtr_Duplicate IS NULL
						GROUP BY prtr_SubjectID, capt_us
                     ) TAS ON TAS.prtr_SubjectID = Comp_CompanyId
                    LEFT OUTER JOIN vPRCurrentRating compRating WITH (NOLOCK) ON comp_CompanyID = compRating.prra_CompanyID 
               WHERE comp_PRListingStatus IN ('L', 'H') 
                 AND comp_PRLocalSource IS NULL
                 AND comp_PRIndustryType IN ({2})";

        protected const string SQL_SELECT_USERLIST_DETAILS = "SELECT prwuld_AssociatedID FROM PRWebUserListDetail WITH (NOLOCK) WHERE prwuld_WebUserListID={0} AND prwuld_AssociatedType = 'C'";
        
        protected const string SQL_SELECT_ALL_COMPANIES =
            @"SELECT comp_CompanyID 
                FROM Company WITH (NOLOCK) 
               WHERE comp_PRListingStatus IN ('L', 'H')  
                 AND comp_PRLocalSource IS NULL
                 AND comp_PRIndustryType IN ({0}) ";

        /// <summary>
        /// Returns the company data for the specified company.
        /// </summary>
        /// <param name="iBBID"></param>
        /// <param name="iAccessLevel"></param>
        /// <returns></returns>
        private List<Company> GetCompanyData(int iBBID, int iAccessLevel) {
            List<string> lszBBIDs = new List<string>();
            lszBBIDs.Add(iBBID.ToString());
            return GetCompanyData(lszBBIDs, 0, iAccessLevel);
        }
        
        /// <summary>
        /// Returns the company data for all companies.
        /// </summary>
        /// <param name="iAccessLevel"></param>
        /// <returns></returns>
        private List<Company> GetCompanyData(int iAccessLevel) {
            return GetCompanyData(null, 0, iAccessLevel);
        }

        /// <summary>
        /// Returns the company data for the specified comma-delimited
        /// list.
        /// </summary>
        /// <param name="lszBBIDs"></param>
        /// <param name="iAccessLevel"></param>
        /// <returns></returns>
        private List<Company> GetCompanyData(List<String> lszBBIDs, int iAccessLevel) {
            return GetCompanyData(lszBBIDs, 0, iAccessLevel);
        }


        private string _szCompanySelectionClause = null;

        /// <summary>
        /// The core method for retrieving company data and populating our object
        /// instances.
        /// </summary>
        /// <param name="lszBBIDs"></param>
        /// <param name="iUserListID"></param>
        /// <param name="iAccessLevel"></param>
        /// <returns></returns>
        private List<Company> GetCompanyData(List<String> lszBBIDs, int iUserListID, int iAccessLevel) {
            return GetCompanyData(lszBBIDs, iUserListID, iAccessLevel, false);
        }

        /// <summary>
        /// The core method for retrieving company data and populating our object
        /// instances.
        /// </summary>
        /// <param name="lszBBIDs"></param>
        /// <param name="iUserListID"></param>
        /// <param name="iAccessLevel"></param>
        /// <param name="bIncludePersonData"></param>
        /// <returns></returns>
        private List<Company> GetCompanyData(List<String> lszBBIDs, int iUserListID, int iAccessLevel, bool bIncludePersonData)
        {
            List<Company> lCompanies = new List<Company>();

            string szSQL = string.Format(SQL_SELECT_COMPANIES, GetCulture(), GetHQID(), _licenseKeyIndustryTypeCodes);
            
            // If we have a list of BBIDs, then
            // use them.
            if ((lszBBIDs != null) &&
                (lszBBIDs.Count > 0)) {
                string szBBIDList = ValidateBBIDs(lszBBIDs);

                _szCompanySelectionClause = szBBIDList;
                szSQL += string.Format(" AND comp_CompanyID IN ({0})", _szCompanySelectionClause);
            }
            
            if (iUserListID > 0) {
                _szCompanySelectionClause = string.Format(SQL_SELECT_USERLIST_DETAILS, iUserListID);
                szSQL += string.Format(" AND comp_CompanyID IN ({0})", _szCompanySelectionClause);
            }

            if (string.IsNullOrEmpty(_szCompanySelectionClause))
                _szCompanySelectionClause = string.Format(SQL_SELECT_ALL_COMPANIES, _licenseKeyIndustryTypeCodes);

            szSQL += " ORDER BY comp_CompanyID";

            int iCount = 0;
            int iThreshold = Utilities.GetIntConfigValue("LogCompanyCountThrehsold", 1000);

            using (IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection)) { 
                while (oReader.Read())
                {
                    Company oCompany = new Company();
                    oCompany.Load(oReader, iAccessLevel, _oWebUser.prwu_AccessLevel);
                    lCompanies.Add(oCompany);
                }
            }
            
            // Now that we're done with the creating the initial Company
            // objects with the primary reader, iterate through them populating
            // the remaining attributes. 
            IDbConnection oConn = GetDBAccess().Open();
            try {
                foreach(Company oCompany in lCompanies) {
                    PopulateAddresses(oCompany);
                    PopulatePhones(oCompany);
                    PopulateStockExchange(oCompany);

                    if (!oCompany.IsLumber)
                        PopulateLicenses(oCompany);

                    PopulateBusinessStartDates(oCompany);

                    if (iAccessLevel >= 2) {
                        PopulateRatings(oCompany);
                        PopulateRatingDefinitions(oCompany);

                        if (!oCompany.IsLumber)
                            PopulateClaims(oCompany);
                        else
                            PopulatePayRatings(oCompany);
                    }

                    if (iAccessLevel >= 3) {
                        PopulateClassifications(oCompany);
                        
                        if (!oCompany.IsLumber)
                            PopulateBrands(oCompany);

                        if (oCompany.IsLumber)
                        {
                            PopulateSpecies(oCompany);
                            PopulateProducts(oCompany);
                            PopulateServices(oCompany);
                        } else
                            PopulateCommodities(oCompany);

                        if ((_oWebUser != null) &&
                            (_oWebUser.HasPrivilege(SecurityMgr.Privilege.ViewBBScore).HasPrivilege)) {
                            PopulateBBScore(oCompany);
                        }
                    }

                    if (bIncludePersonData)
                        PopulatePerson(oCompany);

                    iCount++;
                    if ((iCount % iThreshold) == 0) {
                        GetLogger().LogMessage("Processed " + iCount.ToString("###,###") + " Companies...");
                    }

                }
                return lCompanies;
            } finally {
                oConn.Close();
            }        
        }
        #endregion


        protected const string SQL_SELECT_FIND_COMPANIES =
            @"SELECT comp_CompanyID, comp_PRHQID, comp_PRBookTradestyle, em.emai_EmailAddress, ws.emai_PRWebAddress, comp_PRCorrTradestyle
                FROM Company WITH (NOLOCK) 
                     INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID 
                     LEFT OUTER JOIN vCompanyEmail ws WITH (NOLOCK) ON comp_CompanyID = ws.elink_RecordID AND ws.elink_Type='W' AND ws.emai_PRPreferredPublished='Y' 
                     LEFT OUTER JOIN vCompanyEmail em WITH (NOLOCK) ON comp_CompanyID = em.elink_RecordID AND em.elink_Type='E' AND em.emai_PRPreferredPublished='Y' 
               WHERE comp_PRListingStatus IN ('L', 'H') 
                 AND comp_PRLocalSource IS NULL
                 AND comp_PRIndustryType IN ({1})
                 AND comp_CompanyID IN ({0})";

        private List<CompanyFindResult> FindCompany(string CompanyName,
                                          string City,
                                          string State,
                                          string Phone1,
                                          string Phone2,
                                          string Phone3,
                                          string Email,
                                          string Website)
        {

            string industryTypeClause = _licenseKeyIndustryTypeCodes.Replace("'", string.Empty);
            List<CompanyFindResult> lCompanies = new List<CompanyFindResult>();

            ArrayList parameters = new ArrayList();
            AddParameter(parameters, "CompanyName", CompanyName);
            AddParameter(parameters, "City", City);
            AddParameter(parameters, "State", State);
            AddParameter(parameters, "Phone1", Phone1);
            AddParameter(parameters, "Phone2", Phone2);
            AddParameter(parameters, "Phone3", Phone3);
            AddParameter(parameters, "Email", Email);
            AddParameter(parameters, "Website", Website);
            string sql = $"SELECT * FROM ufn_FindCompanyMatch(@CompanyName, @City, @State, @Phone1, @Phone2, @Phone3, NULL, @Email, @WebSite, '{industryTypeClause}', 'L,H', 1)";

            _szCompanySelectionClause = string.Empty;
            using (IDataReader oReader = GetDBAccess().ExecuteReader(sql, parameters, CommandBehavior.CloseConnection, null))
            {
                while (oReader.Read())
                {
                    if (_szCompanySelectionClause.Length > 0)
                        _szCompanySelectionClause += ",";

                    _szCompanySelectionClause += oReader.GetInt32(0).ToString();
                }
            }

            if (string.IsNullOrEmpty(_szCompanySelectionClause))
                return lCompanies;

            sql = string.Format(SQL_SELECT_FIND_COMPANIES, _szCompanySelectionClause, _licenseKeyIndustryTypeCodes);
            using (IDataReader oReader = GetDBAccess().ExecuteReader(sql, parameters, CommandBehavior.CloseConnection, null))
            {
                while (oReader.Read())
                {
                    CompanyFindResult oCompany = new CompanyFindResult();
                    oCompany.Load(oReader);
                    lCompanies.Add(oCompany);
                }
            }

            using (IDbConnection oConn = GetDBAccess().Open())
            {
                foreach (CompanyFindResult oCompany in lCompanies)
                {
                    PopulateAddresses(oCompany);
                    PopulatePhones(oCompany);
                }
            }

            return lCompanies;
        }

        private void AddParameter(ArrayList parameters, string name, string value)
        {
            if (string.IsNullOrWhiteSpace(value))
                parameters.Add(new ObjectParameter(name, DBNull.Value));
            else
                parameters.Add(new ObjectParameter(name, value));
        }

        private const string SQL_SELECT_LICENSE_KEY = 
            @"SELECT * 
                FROM PRWebServiceLicenseKey WITH (NOLOCK) 
               WHERE prwslk_LicenseKey = @prwslk_LicenseKey 
                 AND prwslk_Password = dbo.ufnclr_EncryptText(@Password)";

        private const string SQL_CONFIRM_WEBMETHOD_ACCESS = 
             @"SELECT 'x' 
                 FROM PRWebServiceLicenseKeyWM WITH (NOLOCK) 
                WHERE prwslkwm_WebServiceLicenseID=@prwslkwm_WebServiceLicenseID 
                  AND prwslkwm_WebMethodName=@prwslkwm_WebMethodName";

        /// <summary>
        /// Authenticates the license and user.
        /// </summary>
        /// <param name="szLicenseKey"></param>
        /// <param name="szPassword"></param>
        /// <param name="szUserLogin"></param>
        /// <param name="szUserPassword"></param>
        /// <param name="szWebMethodName"></param>
        /// <param name="iRequestedBBIDCount"></param>
        /// <returns></returns>
        private int Authenticate(string szLicenseKey, 
                                  string szPassword, 
                                  string szUserLogin, 
                                  string szUserPassword, 
                                  string szWebMethodName,
                                  int iRequestedBBIDCount) {

            GetLogger().RequestName = szWebMethodName;
                                 
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prwslk_LicenseKey", szLicenseKey));
            oParameters.Add(new ObjectParameter("Password", szPassword));

            int iLicenseKeyID = 0;
            int iAccessLevel = 0;
            int iMaxRequestsPerMethod = 0;
            bool bUserAuthRequired = false;
            bool bUserAssociatedWithCompanyRequired = false;
            bool bIsTestOnly = false;
            string szEncryptedPassword = null;
            DateTime dtExpirationDate = new DateTime();

            
            IDataReader oReader = null;
            try {
                oReader = GetDBAccess().ExecuteReader(SQL_SELECT_LICENSE_KEY, oParameters, CommandBehavior.CloseConnection, null);
           
                        
                if (!oReader.Read()) {
                    throw new ApplicationExpectedException("An invalid license key / password combination has been specified.");
                }

                iLicenseKeyID = GetDBAccess().GetInt32(oReader, "prwslk_WebServiceLicenseID");
                szEncryptedPassword = GetDBAccess().GetString(oReader, "prwslk_Password");
                iMaxRequestsPerMethod = GetDBAccess().GetInt32(oReader, "prwslk_MaxRequestsPerMethod");
                bUserAuthRequired = GetObjectMgr().GetBool(oReader["prwslk_UserAuthRequired"]);
                bUserAssociatedWithCompanyRequired = GetObjectMgr().GetBool(oReader["prwslk_UserAssociatedWithCompanyRequired"]);
                iAccessLevel = GetDBAccess().GetInt32(oReader, "prwslk_AccessLevel");
                dtExpirationDate = GetDBAccess().GetDateTime(oReader, "prwslk_ExpirationDate");
                bIsTestOnly = GetObjectMgr().GetBool(oReader["prwslk_IsTestOnly"]);
                _iLicenseHQID = GetDBAccess().GetInt32(oReader, "prwslk_HQID");
                _licenseKeyIndustryTypeCodes = GetDBAccess().GetString(oReader, "prwslk_IndustryTypeCodes"); ;
            } finally {
                if (oReader != null) {
                    oReader.Close();
                }
            }

            if (dtExpirationDate < DateTime.Now) {
                throw new ApplicationExpectedException("The license key has expired.");
            }

            if (bIsTestOnly && !IsTestInstance()) {
                throw new ApplicationExpectedException("Test license keys are not authorized for production use.");
            }
        
        
            if (bUserAuthRequired) {
                try {
                    _oWebUser = new PRWebUserMgr(_oLogger, null).GetByEmail(szUserLogin);
                } catch (ObjectNotFoundException) {
                    throw new ApplicationExpectedException("An invalid user login / password combination has been specified."); 
                }

                if (!_oWebUser.Authenticate(szUserPassword)) {
                    throw new ApplicationExpectedException("An invalid user login / password combination has been specified."); 
                }

                if ((bUserAssociatedWithCompanyRequired) &&
                    (_iLicenseHQID != _oWebUser.prwu_HQID))
                    throw new ApplicationExpectedException("An invalid user has been specified."); 

                if (!_oWebUser.HasAccess(PRWebUser.SECURITY_LEVEL_LIMITED_ACCESS)) 
                    throw new ApplicationExpectedException("Specified user not authorized for web service.");                 

                if (_oWebUser.prci2_Suspended)
                    throw new ApplicationExpectedException(Utilities.GetConfigValue("EnterpriseSuspendedMsg"));

                if ((!szLicenseKey.StartsWith("BlueBookServices")) &&
                    !_licenseKeyIndustryTypeCodes.Contains(_oWebUser.prwu_IndustryType))
                    throw new ApplicationExpectedException("An invalid user has been specified.  Industry type mismatch.");

                GetObjectMgr().User = _oWebUser;
                GetLogger().UserID = _oWebUser.prwu_WebUserID.ToString();
                GetLogger().LogMessage(szWebMethodName + " Authenticated");
            }


            // Now make sure this license key has access to 
            // this web method.
            if (szWebMethodName != "GetUserBBID")
            {
                oParameters = new ArrayList();
                oParameters.Add(new ObjectParameter("prwslkwm_WebServiceLicenseID", iLicenseKeyID));
                oParameters.Add(new ObjectParameter("prwslkwm_WebMethodName", szWebMethodName));
            
                if (GetDBAccess().ExecuteScalar(SQL_CONFIRM_WEBMETHOD_ACCESS, oParameters) == null) {
                    throw new ApplicationExpectedException("Access to web method denied."); 
                }
            }            
            
            
            // Now make sure this license key allows the number
            // of requested BBID.  -1 Means unlimited.
            if (iMaxRequestsPerMethod != -1) {
                if (iRequestedBBIDCount > iMaxRequestsPerMethod) {
                    throw new ApplicationExpectedException("Too many BB #s requested."); 
                }
            }

            GetObjectMgr().InsertWebServiceAuditTrail(szWebMethodName, iLicenseKeyID, iRequestedBBIDCount);            
            return iAccessLevel;
        }
        
        /// <summary>
        /// Helper method that validates the specified BBIDs
        /// </summary>
        /// <param name="lszBBIDs"></param>
        private string ValidateBBIDs(List<string> lszBBIDs) {
        
            if (lszBBIDs == null) {
                return null;
            }
        
            StringBuilder sbBBIDs = new StringBuilder();
        
            foreach(string szBBID in lszBBIDs) {
                int iBBID = 0;
                if (!Int32.TryParse(szBBID, out iBBID)) {
                    throw new ApplicationExpectedException("Invalid BBID:" + szBBID);
                }
                if (iBBID < 100000) {
                    throw new ApplicationExpectedException("Invalid BBID:" + szBBID);
                }
                
                if (sbBBIDs.Length > 0) {
                    sbBBIDs.Append(",");
                }

                sbBBIDs.Append(szBBID);
            }
            
            return sbBBIDs.ToString();
        }

        /// <summary>
        /// Authenticates the user and ensures the user has the appropriate
        /// level of access.
        /// </summary>
        /// <param name="szEmail"></param>
        /// <param name="szPassword"></param>
        /// <returns></returns>
        protected bool AuthenticateUser(string szEmail, string szPassword) {

            try {
                _oWebUser = new PRWebUserMgr(GetLogger(), null).GetByEmail(szEmail);
            } catch (ObjectNotFoundException) {
                return false;
            }

            if (!_oWebUser.Authenticate(szPassword)) {
                return false;
            }


            if (!_oWebUser.HasPrivilege(SecurityMgr.Privilege.WebServices).HasPrivilege)
            {
                return false;
            }

            GetLogger().UserID = _oWebUser.prwu_WebUserID.ToString();
            
            return true;
        }        


        #region Populate Company Methods    
    
        protected const string SQL_SELECT_PERSONS =
               @"SELECT pers_PersonID, peli_CompanyID, RTRIM(pers_FirstName), RTRIM(pers_LastName), RTRIM(pers_MiddleName), RTRIM(pers_Suffix), peli_PRTitle, RTRIM(Emai_EmailAddress) 
                  FROM Person WITH (NOLOCK) 
                       INNER JOIN Person_Link WITH (NOLOCK) ON pers_PersonID = peli_PersonID 
                       LEFT OUTER JOIN vPersonEmail WITH (NOLOCK) ON peli_PersonID = elink_RecordID AND peli_CompanyID = emai_CompanyID AND elink_Type = 'E' AND emai_PRPublish = 'Y' 
                 WHERE peli_PREBBPublish = 'Y' 
                   AND peli_PRStatus IN (1, 2) 
                   AND peli_CompanyID IN ({0}) 
                   ORDER BY peli_CompanyID";
        
        protected DataView _dvPersons = null;
        protected DataSet _dsPersons = null;

        /// <summary>
        /// Populates the Person objects for the specified company.
        /// </summary>
        /// <param name="oCompany"></param>
        protected void PopulatePerson(Company oCompany)
        {

            if (_dvPersons == null)
            {
                _oLogger.LogMessage("Begin Populate Persons Query");
                string szSQL = string.Format(SQL_SELECT_PERSONS, _szCompanySelectionClause);
                _dsPersons = GetDBAccess().ExecuteSelect(szSQL);

                _dvPersons = new DataView(_dsPersons.Tables[0]);
                _dvPersons.Sort = "peli_CompanyID";
                _oLogger.LogMessage("End Populate Persons Query");
            }

            DataRowView[] adrPersonLink = _dvPersons.FindRows(oCompany.BBID);
            foreach (DataRowView drRow in adrPersonLink)
            {
                if (oCompany.Persons == null)
                {
                    oCompany.Persons = new List<Person>();
                }

                Person oPerson = new Person();
                oPerson.Load(drRow);
                PopulatePhones(oCompany, oPerson);
                oCompany.Persons.Add(oPerson);
            }
        }

        protected const string SQL_SELECT_CLAIMS =
            @"SELECT * 
                FROM (SELECT prss_RespondentCompanyId CompanyID,
			                 COUNT(CASE WHEN prss_Status='O' THEN 'x' ELSE NULL END) as OpenClaims,
			                 COUNT(CASE WHEN prss_OpenedDate > DATEADD(year, -2, GETDATE()) THEN 'x' ELSE NULL END) as TotalClaims2Years,
			                 COUNT(CASE WHEN prss_OpenedDate > DATEADD(year, -2, GETDATE()) AND prss_Meritorious='Y' THEN 'x' ELSE NULL END) as TotalMertioriousClaims2Years
		                FROM PRSSFile WITH (NOLOCK)
                       WHERE prss_RespondentCompanyId > 0
                         AND prss_RespondentCompanyId IN ({0})
	                GROUP BY prss_RespondentCompanyId) T1
               WHERE (OpenClaims > 0 OR TotalClaims2Years > 0 OR TotalMertioriousClaims2Years > 0)
            ORDER BY CompanyID";

        protected DataView _dvClaims = null;

        protected void PopulateClaims(Company oCompany)
        {

            if (_dvClaims == null)
            {
                _oLogger.LogMessage("Begin Populate Claims Query");
                string szSQL = string.Format(SQL_SELECT_CLAIMS, _szCompanySelectionClause);
                DataSet dsClaims = GetDBAccess().ExecuteSelect(szSQL);

                _dvClaims = new DataView(dsClaims.Tables[0]);
                _dvClaims.Sort = "CompanyID";
                _oLogger.LogMessage("End Populate Claims Query");
            }

            DataRowView[] adrClaims = _dvClaims.FindRows(oCompany.BBID);
            foreach (DataRowView drRow in adrClaims)
            {
                if (drRow[1] != DBNull.Value)
                    oCompany.OpenClaims = Convert.ToInt32(drRow[1]);

                if (drRow[2] != DBNull.Value)
                    oCompany.TotalClaims2Years = Convert.ToInt32(drRow[2]);

                if (drRow[3] != DBNull.Value)
                    oCompany.TotalMertioriousClaims2Years = Convert.ToInt32(drRow[3]);
            }
        }


        protected const string SQL_SELECT_RATING = "SELECT dbo.ufn_GetCustomCaptionValue('prcw_Name', prcw_Name, '{0}') As CreditWorth, prcw_Name, " +
                                                   "dbo.ufn_GetCustomCaptionValue('prin_Name', prin_Name, '{0}') As Integrity, prin_Name, " +
                                                   "dbo.ufn_GetCustomCaptionValue('prpy_Name', prpy_Name, '{0}') As Pay, prpy_Name,  " +
                                                   "prra_RatingLine, prra_CompanyID " + 
                                             "FROM vPRCurrentRating  " +
                                            "WHERE prra_CompanyID IN ({1})";
        protected DataView _dvRatings = null;
                                              
        /// <summary>
        /// Populates the rating portion of the 
        /// Company.
        /// </summary>
        /// <param name="oCompany"></param>
        protected void PopulateRatings(Company oCompany) {

            if (_dvRatings == null)
            {
                _oLogger.LogMessage("Begin Populate Ratings Query");
                string szSQL = string.Format(SQL_SELECT_RATING, GetCulture(), _szCompanySelectionClause);
                DataSet dsRatings = GetDBAccess().ExecuteSelect(szSQL);

                _dvRatings = new DataView(dsRatings.Tables[0]);
                _dvRatings.Sort = "prra_CompanyID";
                _oLogger.LogMessage("End Populate Ratings Query");
            }

            DataRowView[] adrRatings = _dvRatings.FindRows(oCompany.BBID);
            foreach (DataRowView drRow in adrRatings)
            {
                if (drRow[0] != DBNull.Value)
                {
                    CreditWorthRating oCreditWorth = new CreditWorthRating();
                    oCreditWorth.Load(drRow);
                    oCompany.CreditWorthRating = oCreditWorth;
                }

                if (!oCompany.IsLumber)
                {
                    if (drRow[2] != DBNull.Value)
                    {
                        IntegrityRating oIntegrityRating = new IntegrityRating();
                        oIntegrityRating.Load(drRow);
                        oCompany.IntegrityRating = oIntegrityRating;
                    }

                    if (drRow[4] != DBNull.Value)
                    {
                        PayRating oPayRating = new PayRating();
                        oPayRating.Load(drRow);
                        oCompany.PayRating = oPayRating;
                    }
                }

                if (drRow[6] != DBNull.Value)
                {
                    oCompany.RatingLine = drRow[6].ToString();
                }
            }
        }

        protected const string SQL_SELECT_RATING_NUMERAL = "SELECT prrn_Name, dbo.ufn_GetCustomCaptionValue('prrn_Name', prrn_Name, '{0}') As NumeralName, prra_CompanyID  " +
                                                             "FROM PRRating WITH (NOLOCK) " +
                                                             "     INNER JOIN PRRatingNumeralAssigned WITH (NOLOCK) ON prra_RatingID = pran_RatingID " +
                                                             "     INNER JOIN PRRatingNumeral WITH (NOLOCK) ON pran_RatingNumeralID = prrn_RatingNumeralID " +
                                                            "WHERE prra_CompanyID IN ({1}) " +
                                                               "AND prra_Current = 'Y'";
        protected DataView _dvRatingNumerals = null;

        /// <summary>
        /// Populates the rating definition portion of the 
        /// Company.
        /// </summary>
        /// <param name="oCompany"></param>
        protected void PopulateRatingDefinitions(Company oCompany) {

            if (_dvRatingNumerals == null)
            {
                _oLogger.LogMessage("Begin Populate RatingDefinitions Query");
                string szSQLSelect = string.Format(SQL_SELECT_RATING_NUMERAL, GetCulture(), _szCompanySelectionClause);
                DataSet dsRatingNumerals = GetDBAccess().ExecuteSelect(szSQLSelect);

                _dvRatingNumerals = new DataView(dsRatingNumerals.Tables[0]);
                _dvRatingNumerals.Sort = "prra_CompanyID";
                _oLogger.LogMessage("End Populate RatingDefinitions Query");
            }

            DataRowView[] adrRatingNumerals = _dvRatingNumerals.FindRows(oCompany.BBID);
            foreach (DataRowView drRow in adrRatingNumerals)
            {
                if (oCompany.RatingNumerals == null) {
                    oCompany.RatingNumerals = new List<RatingNumeral>();
                }

                RatingNumeral oRatingNumeral = new RatingNumeral();
                oRatingNumeral.Load(drRow);
                oCompany.RatingNumerals.Add(oRatingNumeral);
            }

        }


        protected const string SQL_SELECT_PAY_INDICATOR =
            @"SELECT prcpi_CompanyID, prcpi_PayIndicator, prcpi_PayIndicatorScore, dbo.ufn_GetCustomCaptionValue('PayIndicatorDescription', prcpi_PayIndicator, '{0}') As PayIndicator
                FROM PRCompanyPayIndicator WITH (NOLOCK)
               WHERE prcpi_Current='Y' 
                 AND prcpi_PayIndicator IS NOT NULL
                 AND prcpi_CompanyID IN ({1})";

        protected DataView _dvPayIndicators = null;

        /// <summary>
        /// Populates the pay indicator portion of the 
        /// Company.
        /// </summary>
        /// <param name="oCompany"></param>
        protected void PopulatePayRatings(Company oCompany)
        {

            if (_dvPayIndicators == null)
            {
                _oLogger.LogMessage("Begin Populate Pay Indicator Query");
                string szSQL = string.Format(SQL_SELECT_PAY_INDICATOR, GetCulture(), _szCompanySelectionClause);
                DataSet dsPayIndicators = GetDBAccess().ExecuteSelect(szSQL);

                _dvPayIndicators = new DataView(dsPayIndicators.Tables[0]);
                _dvPayIndicators.Sort = "prcpi_CompanyID";
                _oLogger.LogMessage("End Populate Pay Indicator Query");
            }

            DataRowView[] adrRatings = _dvPayIndicators.FindRows(oCompany.BBID);
            foreach (DataRowView drRow in adrRatings)
            {
                if (drRow[0] != DBNull.Value)
                {
                    PayIndicator payIndicator = new PayIndicator();
                    payIndicator.Load(drRow);
                    oCompany.PayIndicator = payIndicator;
                }
            }
        }


        protected const string SQL_SELECT_BUSINESS_START_DATE =
            @"SELECT * FROM (
	            SELECT prbe_CompanyId,
	                   prbe_DisplayedEffectiveDate,
		               ROW_NUMBER() OVER (PARTITION BY prbe_CompanyId ORDER BY CASE WHEN prbe_BusinessEventTypeId=9 THEN 1 WHEN prbe_BusinessEventTypeId=42 THEN 2 WHEN prbe_BusinessEventTypeId=8 THEN 3 END) RowNum
	            FROM PRBusinessEvent WITH(NOLOCK)
	            WHERE prbe_BusinessEventTypeId IN (9, 42, 8)
	            AND ((prbe_BusinessEventTypeID <> 8) OR (prbe_BusinessEventTypeID=8 AND prbe_DetailedType NOT IN ('1', '2', '3')))
	            AND prbe_CompanyId IN ({0})
            ) T1
            WHERE RowNum = 1
            ORDER BY prbe_CompanyId";

        protected DataView _dvBusinessStartDates = null;

        /// <summary>
        /// Populates the pay indicator portion of the 
        /// Company.
        /// </summary>
        /// <param name="oCompany"></param>
        protected void PopulateBusinessStartDates(Company oCompany)
        {

            if (_dvBusinessStartDates == null)
            {
                _oLogger.LogMessage("Begin Populate Business Start Date Query");
                string szSQL = string.Format(SQL_SELECT_BUSINESS_START_DATE, _szCompanySelectionClause);
                DataSet dsBusinessStartDates = GetDBAccess().ExecuteSelect(szSQL);

                _dvBusinessStartDates = new DataView(dsBusinessStartDates.Tables[0]);
                _dvBusinessStartDates.Sort = "prbe_CompanyId";
                _oLogger.LogMessage("End Populate usiness Start DateQuery");
            }

            DataRowView[] adrBusinesssStartDates = _dvBusinessStartDates.FindRows(oCompany.BBID);
            foreach (DataRowView drRow in adrBusinesssStartDates)
            {
                if (drRow[0] != DBNull.Value) { 
                    oCompany.DateBusinessStarted = Utils.GetString(drRow, 1);
                    break;
                }
            }
        }


        protected const string SQL_SELECT_ADDRESS =
            @"SELECT dbo.ufn_GetCustomCaptionValue('adli_TypeCompany', adli_Type, '{0}') As adli_Type, RTRIM(addr_Address1), RTRIM(addr_Address2), RTRIM(addr_Address3), RTRIM(addr_Address4), RTRIM(prci_City), RTRIM(prst_State), RTRIM(addr_PostCode), RTRIM(prcn_Country), adli_CompanyID 
                FROM Address WITH (NOLOCK) 
                     INNER JOIN Address_Link WITH (NOLOCK) on addr_AddressID = adli_AddressID 
                     INNER JOIN vPRLocation on addr_PRCityID = prci_CityID 
               WHERE adli_CompanyID IN ({1}) 
                 AND adli_Type IN ('M', 'PH') 
                 AND addr_PRPublish='Y'
            ORDER BY adli_Type;";

        protected DataView _dvAddresses = null;

        /// <summary>
        /// Populates the address portion of the 
        /// Company.
        /// </summary>
        /// <param name="oCompany"></param>
        protected void PopulateAddresses(Company oCompany) {

            if (_dvAddresses == null)
            {
                _oLogger.LogMessage("Begin Populate Addresses Query");
                string szSQLSelect = string.Format(SQL_SELECT_ADDRESS, GetCulture(),_szCompanySelectionClause);
                DataSet dsAddresses = GetDBAccess().ExecuteSelect(szSQLSelect);

                _dvAddresses = new DataView(dsAddresses.Tables[0]);
                _dvAddresses.Sort = "adli_CompanyID";
                _oLogger.LogMessage("End Populate Addresses Query");
            }

            DataRowView[] adrAddresses = _dvAddresses.FindRows(oCompany.BBID);
            foreach (DataRowView drRow in adrAddresses)
            {
                if (oCompany.Addresses == null)
                    oCompany.Addresses = new List<Address>();

                Address oAddress = new Address();
                oAddress.Load(drRow);
                oCompany.Addresses.Add(oAddress);
            }
        }

        protected void PopulateAddresses(CompanyFindResult oCompany)
        {
            if (_dvAddresses == null)
            {
                _oLogger.LogMessage("Begin Populate Addresses Query");
                string szSQLSelect = string.Format(SQL_SELECT_ADDRESS, GetCulture(), _szCompanySelectionClause);
                DataSet dsAddresses = GetDBAccess().ExecuteSelect(szSQLSelect);

                _dvAddresses = new DataView(dsAddresses.Tables[0]);
                _dvAddresses.Sort = "adli_CompanyID";
                _oLogger.LogMessage("End Populate Addresses Query");
            }

            DataRowView[] adrAddresses = _dvAddresses.FindRows(oCompany.BBID);
            foreach (DataRowView drRow in adrAddresses)
            {
                if (oCompany.Addresses == null)
                    oCompany.Addresses = new List<Address>();

                Address oAddress = new Address();
                oAddress.Load(drRow);
                oCompany.Addresses.Add(oAddress);
                break;
            }
        }

        protected const string SQL_SELECT_PHONE =
            @"SELECT dbo.ufn_GetCustomCaptionValue('Phon_TypeCompany', plink_Type, '{0}') As plink_Type, RTRIM(phon_CountryCode), RTRIM(phon_AreaCode), phon_Number, plink_RecordID, phon_PRDescription, phon_PRPreferredPublished, phon_PRIsPhone
                FROM vPRCompanyPhone WITH (NOLOCK) 
               WHERE plink_RecordID IN ({1}) 
                     AND phon_PRPublish='Y' 
                ORDER BY plink_RecordID, plink_Type";

        protected DataView _dvPhones = null;
        /// <summary>
        /// Populates the phone portion of the 
        /// Company.
        /// </summary>
        /// <param name="oCompany"></param>
        protected void PopulatePhones(Company oCompany) {

            if (_dvPhones == null)
            {
                _oLogger.LogMessage("Begin Populate Phones Query");
                string szSQLSelect = string.Format(SQL_SELECT_PHONE, GetCulture(), _szCompanySelectionClause);
                DataSet dsPhones = GetDBAccess().ExecuteSelect(szSQLSelect);

                _dvPhones = new DataView(dsPhones.Tables[0]);
                _dvPhones.Sort = "plink_RecordID";
                _oLogger.LogMessage("End Populate Phones Query");
            }

            DataRowView[] adrPhones = _dvPhones.FindRows(oCompany.BBID);
            foreach (DataRowView drRow in adrPhones)
            {
                if (oCompany.Phones == null)
                    oCompany.Phones = new List<Phone>();

                Phone oPhone = new Phone();
                oPhone.Load(drRow);
                oCompany.Phones.Add(oPhone);
            }
        }


        protected void PopulatePhones(CompanyFindResult oCompany)
        {

            if (_dvPhones == null)
            {
                _oLogger.LogMessage("Begin Populate Phones Query");
                string szSQLSelect = string.Format(SQL_SELECT_PHONE, GetCulture(), _szCompanySelectionClause);
                DataSet dsPhones = GetDBAccess().ExecuteSelect(szSQLSelect);

                _dvPhones = new DataView(dsPhones.Tables[0]);
                _dvPhones.Sort = "plink_RecordID";
                _oLogger.LogMessage("End Populate Phones Query");
            }

            DataRowView[] adrPhones = _dvPhones.FindRows(oCompany.BBID);
            foreach (DataRowView drRow in adrPhones)
            {
                if (oCompany.Phones == null)
                    oCompany.Phones = new List<Phone>();

                // If preferred published and isPhone
                if ((Convert.ToString(drRow[6]) == "Y") && (Convert.ToString(drRow[7]) == "Y"))
                {
                    Phone oPhone = new Phone();
                    oPhone.Load(drRow);
                    oCompany.Phones.Add(oPhone);
                }
            }
        }


        protected const string SQL_SELECT_PERSON_PHONE =
            @"SELECT dbo.ufn_GetCustomCaptionValue('Phon_TypePerson', plink_Type, '{0}') As PhoneType, RTRIM(phon_CountryCode), RTRIM(phon_AreaCode), phon_Number, peli_CompanyID, plink_RecordID, phon_PRDescription, plink_Type
                FROM vPRPersonPhone WITH (NOLOCK) 
                     INNER JOIN Person_Link ON plink_RecordID = peli_PersonID AND peli_CompanyID = phon_CompanyID AND peli_PRStatus IN ('1', '2')
               WHERE peli_CompanyID IN ({1}) 
                     AND phon_PRPublish='Y' ";

        protected DataView _dvPersonPhones = null;
        /// <summary>
        /// Populates the phone portion of the 
        /// Person.
        /// </summary>
        /// <param name="oCompany"></param>
        /// <param name="oPerson"></param>
        protected void PopulatePhones(Company oCompany,
                                      Person oPerson)
        {

            if (_dvPersonPhones == null)
            {
                _oLogger.LogMessage("Begin Person Populate Phones Query");
                string szSQLSelect = string.Format(SQL_SELECT_PERSON_PHONE, GetCulture(), _szCompanySelectionClause);
                DataSet dsPhones = GetDBAccess().ExecuteSelect(szSQLSelect);

                _dvPersonPhones = new DataView(dsPhones.Tables[0]);
                _dvPersonPhones.Sort = "plink_RecordID";
                _oLogger.LogMessage("End Person Populate Phones Query");
            }

            DataRowView[] adrPhones = _dvPersonPhones.FindRows(oPerson.PersonID);
            foreach (DataRowView drRow in adrPhones)
            {
                if (oCompany.BBID == Convert.ToInt32(drRow[4]))
                {
                    if (oPerson.Phones == null)
                    {
                        oPerson.Phones = new List<Phone>();
                    }

                    Phone oPhone = new Phone();
                    oPhone.Load(drRow);
                    oPerson.Phones.Add(oPhone);
                }
            }
        }


        protected const string SQL_SELECT_LICENSE = "SELECT 'DRC', prdr_LicenseNumber, prdr_CompanyID As CompanyID FROM PRDRCLicense WITH (NOLOCK) WHERE prdr_CompanyID IN ({0}) AND prdr_Publish = 'Y' " +
                                                    "UNION " +
                                                    "SELECT 'PACA', prpa_LicenseNumber, prpa_CompanyID As CompanyID FROM PRPACALicense WITH (NOLOCK) WHERE prpa_CompanyID IN ({0}) AND prpa_Publish = 'Y' AND prpa_Current = 'Y' " +
                                                    "UNION " +
                                                    "SELECT prli_Type, prli_Number, prli_CompanyId As CompanyID FROM PRCompanyLicense WITH (NOLOCK) WHERE prli_CompanyId IN ({0}) AND prli_Publish = 'Y' ";

        protected DataView _dvLicenses = null;

        /// <summary>
        /// Populates the license portion of the 
        /// Company.
        /// </summary>
        /// <param name="oCompany"></param>
        protected void PopulateLicenses(Company oCompany) {

            if (_dvLicenses == null)
            {
                _oLogger.LogMessage("Begin Populate Licenses Query");
                string szSQLSelect = string.Format(SQL_SELECT_LICENSE, _szCompanySelectionClause);
                DataSet dsLicenses = GetDBAccess().ExecuteSelect(szSQLSelect);

                _dvLicenses = new DataView(dsLicenses.Tables[0]);
                _dvLicenses.Sort = "CompanyID";
                _oLogger.LogMessage("End Populate Licenses Query");

            }

            DataRowView[] adrLicenses= _dvLicenses.FindRows(oCompany.BBID);
            foreach (DataRowView drRow in adrLicenses)
            {

                if (oCompany.Licenses == null) {
                    oCompany.Licenses = new List<License>();
                }

                License oLicense = new License();
                oLicense.Load(drRow);
                oCompany.Licenses.Add(oLicense);
            }
        }


        protected const string SQL_CLASSIFICATIONS_SELECT = "SELECT prcl_Abbreviation, {0} As Description, prc2_CompanyID, prcl_Name " +
                                                              "FROM PRCompanyClassification WITH (NOLOCK) " +
                                                                    "INNER JOIN PRClassification WITH (NOLOCK) ON prc2_ClassificationID = prcl_ClassificationID " +
                                                             "WHERE prc2_CompanyID IN ({1})";

        protected DataView _dvClassifications = null;
        /// <summary>
        /// Populates the phone portion of the 
        /// Company.
        /// </summary>
        /// <param name="oCompany"></param>
        protected void PopulateClassifications(Company oCompany)
        {

            if (_dvClassifications == null)
            {
                _oLogger.LogMessage("Begin Populate Classifications Query");
                string szSQLSelect = string.Format(SQL_CLASSIFICATIONS_SELECT, 
                                                   GetObjectMgr().GetLocalizedColName("prcl_Description"),
                                                   _szCompanySelectionClause);
                DataSet dsClassifications = GetDBAccess().ExecuteSelect(szSQLSelect);

                _dvClassifications = new DataView(dsClassifications.Tables[0]);
                _dvClassifications.Sort = "prc2_CompanyID";
                _oLogger.LogMessage("End Populate Classifications Query");
            }

            //DataRow[] adrClassifications = _dsClassifications.Tables[0].Select("prc2_CompanyID = " + oCompany.BBID.ToString());
            DataRowView[] adrClassifications = _dvClassifications.FindRows(oCompany.BBID);
            foreach (DataRowView drRow in adrClassifications)
            {
                if (oCompany.Classifications == null)
                    oCompany.Classifications = new List<Classification>();

                Classification oClassification = new Classification();
                oClassification.Load(drRow, oCompany.IsLumber);
                oCompany.Classifications.Add(oClassification);
            }
        }

        protected const string SQL_SPECIE_SELECT = 
            @"SELECT prspc_Name, prcspc_CompanyID 
                FROM PRCompanySpecie WITH (NOLOCK) 
                     INNER JOIN PRSpecie WITH (NOLOCK) ON prcspc_SpecieID = prspc_SpecieID
                WHERE prcspc_CompanyID IN ({0})";

        protected DataView _dvSpecies = null;
        /// <summary>
        /// Populates the phone portion of the 
        /// Company.
        /// </summary>
        /// <param name="oCompany"></param>
        protected void PopulateSpecies(Company company)
        {

            if (_dvSpecies == null)
            {
                _oLogger.LogMessage("Begin Populate Species Query");
                string szSQLSelect = string.Format(SQL_SPECIE_SELECT,
                                                   _szCompanySelectionClause);
                DataSet dsSpecies = GetDBAccess().ExecuteSelect(szSQLSelect);

                _dvSpecies = new DataView(dsSpecies.Tables[0]);
                _dvSpecies.Sort = "prcspc_CompanyID";
                _oLogger.LogMessage("End Populate Species Query");
            }

            DataRowView[] adrSpecie = _dvSpecies.FindRows(company.BBID);
            foreach (DataRowView drRow in adrSpecie)
            {
                if (company.Species == null)
                    company.Species = new List<Specie>();

                Specie specie = new Specie();
                specie.Load(drRow);
                company.Species.Add(specie);
            }
        }


        protected const string SQL_PRODUCT_SELECT =
            @"SELECT prprpr_Name, prcprpr_CompanyID 
                FROM PRCompanyProductProvided WITH (NOLOCK) 
                     INNER JOIN PRProductProvided WITH (NOLOCK) ON prcprpr_ProductProvidedID = prprpr_ProductProvidedID
               WHERE prcprpr_CompanyID IN ({0})";

        protected DataView _dvProducts = null;
        /// <summary>
        /// Populates the phone portion of the 
        /// Company.
        /// </summary>
        /// <param name="oCompany"></param>
        protected void PopulateProducts(Company company)
        {

            if (_dvProducts == null)
            {
                _oLogger.LogMessage("Begin Populate Products Query");
                string szSQLSelect = string.Format(SQL_PRODUCT_SELECT,
                                                   _szCompanySelectionClause);
                DataSet dsProducts = GetDBAccess().ExecuteSelect(szSQLSelect);

                _dvProducts = new DataView(dsProducts.Tables[0]);
                _dvProducts.Sort = "prcprpr_CompanyID";
                _oLogger.LogMessage("End Populate Products Query");
            }

            DataRowView[] adrProducts = _dvProducts.FindRows(company.BBID);
            foreach (DataRowView drRow in adrProducts)
            {
                if (company.Products == null)
                    company.Products = new List<Product>();

                Product product = new Product();
                product.Load(drRow);
                company.Products.Add(product);
            }
        }

        protected const string SQL_SERVICE_SELECT =
            @"SELECT prserpr_Name, prcserpr_CompanyID 
                  FROM PRCompanyServiceProvided WITH (NOLOCK) 
                       INNER JOIN PRServiceProvided WITH (NOLOCK) ON prcserpr_ServiceProvidedID = prserpr_ServiceProvidedID
                 WHERE prcserpr_CompanyID IN ({0})";

        protected DataView _dvServices = null;
        /// <summary>
        /// Populates the phone portion of the 
        /// Company.
        /// </summary>
        /// <param name="oCompany"></param>
        protected void PopulateServices(Company company)
        {

            if (_dvServices == null)
            {
                _oLogger.LogMessage("Begin Populate Services Query");
                string szSQLSelect = string.Format(SQL_SERVICE_SELECT,
                                                   _szCompanySelectionClause);
                DataSet dsServices = GetDBAccess().ExecuteSelect(szSQLSelect);

                _dvServices = new DataView(dsServices.Tables[0]);
                _dvServices.Sort = "prcserpr_CompanyID";
                _oLogger.LogMessage("End Populate Services Query");
            }

            DataRowView[] adrServices = _dvServices.FindRows(company.BBID);
            foreach (DataRowView drRow in adrServices)
            {
                if (company.Services == null)
                    company.Services = new List<Service>();

                Service service = new Service();
                service.Load(drRow);
                company.Services.Add(service);
            }
        }

        protected const string SQL_COMMODITIES_SELECT = "SELECT DISTINCT prcca_PublishedDisplay, prcx_Description, prcca_CompanyID " +
                                                          "FROM PRCommodityTranslation WITH (NOLOCK) " +
                                                               "INNER JOIN PRCompanyCommodityAttribute WITH (NOLOCK) ON prcca_PublishedDisplay = prcx_Abbreviation " +
                                                         "WHERE prcca_Publish='Y' AND prcca_CompanyID IN ({1})";
        protected DataView _dvCommodities = null;

        /// <summary>
        /// Populates the commodity portion of the 
        /// Company.
        /// </summary>
        /// <param name="oCompany"></param>
        protected void PopulateCommodities(Company oCompany) {

            if (_dvCommodities == null)
            {
                _oLogger.LogMessage("Begin Populate Commodities Query");
                string szSQLSelect = string.Format(SQL_COMMODITIES_SELECT,
                                                   GetObjectMgr().GetLocalizedColName("prcm_Name"),
                                                   _szCompanySelectionClause);
                DataSet dsCommodities = GetDBAccess().ExecuteSelect(szSQLSelect);

                _dvCommodities = new DataView(dsCommodities.Tables[0]);
                _dvCommodities.Sort = "prcca_CompanyID";
                _oLogger.LogMessage("End Populate Commodities Query");
            }

            DataRowView[] adrCommodities = _dvCommodities.FindRows(oCompany.BBID);
            foreach (DataRowView drRow in adrCommodities)
            {
                if (oCompany.Commodities == null) {
                    oCompany.Commodities = new List<Commodity>();
                }
            
                Commodity oCommodity = new Commodity();
                oCommodity.Load(drRow);
                oCompany.Commodities.Add(oCommodity);
            }
        }

        protected const string SQL_BRANDS_SELECT = "SELECT prc3_Brand, prc3_CompanyID FROM PRCompanyBrand WITH (NOLOCK) WHERE prc3_Publish = 'Y' AND prc3_CompanyID IN ({0})";
        protected DataView _dvBrands = null;

        /// <summary>
        /// Populates the brand portion of the 
        /// Company.
        /// </summary>
        /// <param name="oCompany"></param>
        protected void PopulateBrands(Company oCompany) {

            if (_dvBrands == null)
            {
                _oLogger.LogMessage("Begin Populate Brands Query");
                string szSQL = string.Format(SQL_BRANDS_SELECT,
                                             _szCompanySelectionClause);
                DataSet dsBrands = GetDBAccess().ExecuteSelect(szSQL);

                _dvBrands = new DataView(dsBrands.Tables[0]);
                _dvBrands.Sort = "prc3_CompanyID";
                _oLogger.LogMessage("End Populate Brands Query");
            }

            DataRowView[] adrBrands = _dvBrands.FindRows(oCompany.BBID);
            foreach (DataRowView drRow in adrBrands)
            {
                if (oCompany.Brands == null) {
                    oCompany.Brands = new List<Brand>();    
                }
            
                Brand oBrand = new Brand();
                oBrand.Load(drRow);
                oCompany.Brands.Add(oBrand);
            }
        }

        protected const string SQL_STOCK_EXCHANGE_SELECT = "SELECT prex_Name, prc4_Symbol1, prc4_CompanyID FROM vPRCompanyStockExchange WITH (NOLOCK) WHERE  prc4_CompanyID IN ({0})";
        protected DataView _dvStockExchange = null;

        /// <summary>
        /// Populates the brand portion of the 
        /// Company.
        /// </summary>
        /// <param name="oCompany"></param>
        protected void PopulateStockExchange(Company oCompany)
        {

            if (_dvStockExchange == null)
            {
                _oLogger.LogMessage("Begin Populate StockExchange Query");
                string szSQL = string.Format(SQL_STOCK_EXCHANGE_SELECT,
                                             _szCompanySelectionClause);
                DataSet dsStockExchanges = GetDBAccess().ExecuteSelect(szSQL);

                _dvStockExchange = new DataView(dsStockExchanges.Tables[0]);
                _dvStockExchange.Sort = "prc4_CompanyID";
                _oLogger.LogMessage("End Populate StockExchange Query");
            }

            DataRowView[] adrStockExchange = _dvStockExchange.FindRows(oCompany.BBID);
            foreach (DataRowView drRow in adrStockExchange)
            {
                StockExchange stockExchange = new StockExchange();
                stockExchange.Load(drRow);
                oCompany.StockExchange = stockExchange;
                break;
            }
        }

        protected const string SQL_BBSCORE_SELECT = "SELECT prbs_BBScore, prbs_CompanyID FROM PRBBScore WITH (NOLOCK) INNER JOIN Company WITH (NOLOCK) ON prbs_CompanyId=comp_CompanyId  WHERE prbs_CompanyID IN ({0}) AND prbs_Current='Y' AND prbs_PRPublish='Y' AND comp_PRPublishBBScore='Y'";
        protected DataView _dvBBScore = null;
        /// <summary>
        /// Populates the BBScore for the current company.
        /// </summary>
        /// <param name="oCompany"></param>
        protected void PopulateBBScore(Company oCompany) {

            if (_dvBBScore == null)
            {
                _oLogger.LogMessage("Begin Populate BBScore Query");
                string szSQL = string.Format(SQL_BBSCORE_SELECT,
                                            _szCompanySelectionClause);
                DataSet dsBBScore = GetDBAccess().ExecuteSelect(szSQL);

                _dvBBScore = new DataView(dsBBScore.Tables[0]);
                _dvBBScore.Sort = "prbs_CompanyID";
                _oLogger.LogMessage("End Populate BBScore Query");
            }

            DataRowView[] adrBBScore = _dvBBScore.FindRows(oCompany.BBID);
            foreach (DataRowView drRow in adrBBScore)
            {
                BlueBookScore oBBScore = new BlueBookScore();
                oBBScore.Load(drRow);
                oCompany.BlueBookScore = oBBScore;
                break;
            }
        }


        #endregion


        #region Helper Methods
        /// <summary>
        /// Helper method that returns an GeneralDataMgr object.  This is
        /// cached in a member variable.
        /// </summary>
        /// <returns></returns>
        public GeneralDataMgr GetObjectMgr() {
            if (_oObjectMgr == null) {
                _oObjectMgr = new GeneralDataMgr(GetLogger(), _oWebUser);
            }
            return _oObjectMgr;
        }

        /// <summary>
        /// Helper method that returns a DBAccess object.  This is
        /// cached in a member variable.
        /// </summary>
        /// <returns></returns>
        protected IDBAccess GetDBAccess() {
            if (_oDBAccess == null) {
                _oDBAccess = DBAccessFactory.getDBAccessProvider();
                _oDBAccess.Logger = GetLogger();
            }

            return _oDBAccess;
        }

        /// <summary>
        /// Helper method that returns a Logger object.  This is
        /// cached in a member variable.
        /// </summary>
        /// <returns></returns>
        protected ILogger GetLogger() {
            if (_oLogger == null) {
                _oLogger = LoggerFactory.GetLogger();
                if (_oWebUser != null) {
                    _oLogger.UserID = _oWebUser.UserID;
                }
            }

            return _oLogger;
        }
        
        /// <summary>
        /// Helper method that returns the culture to use.
        /// If we don't have a current user, us-en is returned.
        /// </summary>
        /// <returns></returns>
        protected string GetCulture() {
            if (_oWebUser == null) {
                return "en-us";
            }
            return _oWebUser.prwu_Culture;
        }
        
        /// <summary>
        /// Returns the HQID for the current request.  If
        /// we don't have a current user, the HQ of the license
        /// is returned.
        /// </summary>
        /// <returns></returns>
        protected int GetHQID() {
            if (_oWebUser == null) {
                return _iLicenseHQID;
            }
            return _oWebUser.prwu_HQID;
        }
        
        /// <summary>
        /// Determines if this instance of the web services is a
        /// test instance, which affects web method behavior.
        /// </summary>
        /// <returns></returns>
        protected bool IsTestInstance() {
            return Utilities.GetBoolConfigValue("IsTestInstance", false);
        }

        protected bool IsLumber()
        {
            return _licenseKeyIndustryTypeCodes == "'L'";
        }

        /// <summary>
        /// Returns a company instance populated with test data.
        /// The test data is read from disk using the web method
        /// as the file name.
        /// </summary>
        /// <param name="szWebMethodName"></param>
        /// <returns></returns>
        protected Company GetTestCompany(string szWebMethodName) {
            XmlSerializer xs = new XmlSerializer(typeof(Company));
            StringReader xmlStringReader = new StringReader(GetTestFile(szWebMethodName));

            Company oCompany = (Company)xs.Deserialize(xmlStringReader);
            xmlStringReader.Close();

            return oCompany;
        }

        protected CompanyFindResult[] GetTestFindCompany(string szWebMethodName)
        {
            XmlSerializer xs = new XmlSerializer(typeof(CompanyFindResult[]));
            StringReader xmlStringReader = new StringReader(GetTestFile(szWebMethodName));

            CompanyFindResult[] oCompany = (CompanyFindResult[])xs.Deserialize(xmlStringReader);
            xmlStringReader.Close();

            return oCompany;
        }

        /// <summary>
        /// Returns company instances populated with test data.
        /// The test data is read from disk using the web method
        /// as the file name.
        /// </summary>
        /// <param name="szWebMethodName"></param>
        /// <returns></returns>
        protected Company[] GetTestCompanies(string szWebMethodName) {
            XmlSerializer xs = new XmlSerializer(typeof(Company[]));
            StringReader xmlStringReader = new StringReader(GetTestFile(szWebMethodName));
            Company[] aCompany = (Company[])xs.Deserialize(xmlStringReader);
            xmlStringReader.Close();
            return aCompany;
        }
        
        /// <summary>
        /// Reads an XML of test data based on the specified 
        /// web method name.
        /// </summary>
        /// <param name="szWebMethodName"></param>
        /// <returns></returns>
        protected string GetTestFile(string szWebMethodName) {

            string industry = string.Empty;
            if (IsLumber())
                industry = "_Lumber";

            using (StreamReader srTestFile = new StreamReader(Utilities.GetConfigValue("TestFilePath") + szWebMethodName + industry + ".xml")) {
                return srTestFile.ReadToEnd();
            }
        }

        protected Company[] SerializeArray(Company[] aCompanies) {
            StringBuilder sbXML = new StringBuilder();

            XmlSerializer xs = new XmlSerializer(typeof(Company[]));
            StringWriter xmlTextWriter = new StringWriter(sbXML);
            xs.Serialize(xmlTextWriter, aCompanies);
            xmlTextWriter.Close();

            string szTest = sbXML.ToString();
            using (StreamWriter srTestFile = new StreamWriter(Utilities.GetConfigValue("TestFilePath") + "a.xml")) {
                srTestFile.Write(szTest);
            }
            //using (StreamReader srTestFile = new StreamReader(Utilities.GetConfigValue("TestFilePath") + "GetListingDataForWatchdogList.xml")) {
            //    szTest = srTestFile.ReadToEnd();
            //}


            //return GetTestCompanies("GetListingDataForWatchdogList");
            //szTest = GetTestFile("GetListingDataForWatchdogList");
            //StringReader xmlStringReader = new StringReader(szTest);
            //Company[] aCompany = (Company[])xs.Deserialize(xmlStringReader);
            //xmlStringReader.Close();

            //return aCompany;
            
            return null;
        
        }
        #endregion
    }
}
