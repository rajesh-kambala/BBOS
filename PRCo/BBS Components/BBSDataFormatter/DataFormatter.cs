/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Company 2006

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: DataFormatter
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Configuration;
using System.Data;
using System.IO;
using System.Text;
using Microsoft.Win32;
using System.Security.Permissions;


namespace PRCO.BBS
{
	/// <summary>
	/// Provides data formatting functionality to those environments
	/// where complex formatting is lacking.
	/// </summary>
    public class DataFormatter {

        private const string CONN_STRING = "server={0};User ID={1};Password={2};Initial Catalog={3};Application Name=BBSDataFormatter";

        // SQL Statements executed by the Data Formatter
        protected const string SQL_SELECT_BUSINESS_EVENT = "SELECT * FROM PRBusinessEvent WHERE prbe_BusinessEventID=@Parm01";
        protected const string SQL_SELECT_BUSINESS_EVENT_COMPANY = "SELECT Comp_PRCorrTradestyle, prci_City, prst_State, prcn_Country FROM PRState INNER JOIN PRCity ON prst_StateId = prci_StateId LEFT OUTER JOIN PRCountry ON prst_CountryId = prcn_CountryId RIGHT OUTER JOIN Company ON prci_CityId = comp_PRListingCityId WHERE Comp_CompanyId = @Parm01";
        protected const string SQL_SELECT_CUSTOM_CAPTIONS = "SELECT Capt_Code, Capt_US FROM Custom_Captions  WHERE Capt_Family=@Parm01";
        protected const string SQL_SELECT_STATE = "SELECT prst_State FROM PRState WHERE prst_StateId = @Parm01";
        protected const string SQL_SELECT_PERSON = "SELECT Pers_FirstName, Pers_PRNickname1, Pers_MiddleName, Pers_LastName, Pers_Suffix FROM Person WHERE Pers_PersonID = @Parm01";
        protected const string SQL_SELECT_PERSON_EVENT = "SELECT * FROM PRPersonEvent WHERE prpe_PersonEventId=@Parm01";

        protected static Hashtable _htCustomCaptionCache = new Hashtable();

        protected static string _szConnectionString;

        #region Business Event Constants

        protected const int BUSINESS_EVENT_REPORT_TYPE_RECENT = 0;
        protected const int BUSINESS_EVENT_REPORT_TYPE_BUSINESS_EVENTS = 1;
        protected const int BUSINESS_EVENT_REPORT_TYPE_BANKRUPTCY = 2;

        protected const string BUSINESS_EVENT_ACQUISTION_TYPE_OTHER = "6";

        // Business Event Text Strings
        protected const string BUSINESS_EVENT_ACQUISTION_TEXT = "Subject company acquired {1} of {2}, {3}.";
        protected const string BUSINESS_EVENT_AGREEMENT_IN_PRINCIPLE_TEXT = "An agreement in priciple was reach with {1}, {2} to {3} {4}.";
        protected const string BUSINESS_EVENT_ASSIGNMENT_BENEFIT_CREDITORS_TEXT_01 = "Subject company reported assignment of all/certain assets made for the benefit of creditors.  ";
        protected const string BUSINESS_EVENT_ASSIGNMENT_BENEFIT_CREDITORS_TEXT_02 = "Assignee named to this case is {1}, {2}, {3}.";
        protected const string BUSINESS_EVENT_US_BANKRUPTCY_TEXT_01 = "Subject company filed a {1} petition in bankruptcy under Chapter {2}.  ";
        protected const string BUSINESS_EVENT_US_BANKRUPTCY_TEXT_02 = "The bankruptcy was filed as a {3} case with the {4} under the case number {5}.  Attorney for the debtor is {6}, {7}.  Trustee assigned to the case is {8}, {9}.  Assets were reported in the amount of {10:c} and liabilities in the amount of {11:c}.";
        protected const string BUSINESS_EVENT_CANADIAN_BANKRUPTCY_TEXT = "Subject company filed {1}.";
        protected const string BUSINESS_EVENT_BUSINESS_CLOSED_TEXT_88 = "Subject company ceased operations with all obligations handled in full.";
        protected const string BUSINESS_EVENT_BUSINESS_CLOSED_TEXT_108 = "Subject company was reported liquidating.";
        protected const string BUSINESS_EVENT_BUSINESS_CLOSED_TEXT_113 = "Subject company suspended operations with obligations not fully liquidated.";
        protected const string BUSINESS_EVENT_BUSINESS_CLOSED_TEXT_INACTIVE = "Subject company inactivated operatations.";
        protected const string BUSINESS_EVENT_BUSINESS_ENTITY_CHANGED_TEXT = "Subject company converted to a {1} {2}.";
        protected const string BUSINESS_EVENT_BUSINESS_STARTED_TEXT = "Subject company was established as a {1} {2}.";
        protected const string BUSINESS_EVENT_INDIVIDUAL_OWNERSHIP_CHANGE_TEXT = "{1} sold {2:##0.00}% of the business {3} to {4}.";
        protected const string BUSINESS_EVENT_DIVESTITURE_TEXT = "Subject company sold {1} to {2}, {3}.";
        protected const string BUSINESS_EVENT_DRC_ISSUE_TEXT_155 = "A fine or civil penalty was levied by the government or regulatory agency against subject company.";
        protected const string BUSINESS_EVENT_DRC_ISSUE_TEXT_156 = "The Disupte Resolution Corporation (DRC) membership of subject company was suspended.";
        protected const string BUSINESS_EVENT_DRC_ISSUE_TEXT_157 = "The Dispute Resolution Corporation (DRC) membership of subject company was revoked.";
        protected const string BUSINESS_EVENT_DRC_ISSUE_TEXT_158 = "The Dispute Resolution Corporation (DRC) membership of subject company was reinstated.";
        protected const string BUSINESS_EVENT_EXTENSION_COMPROMISE_TEXT_1 = "Subject company was reported asking general extension.";
        protected const string BUSINESS_EVENT_EXTENSION_COMPROMISE_TEXT_2 = "Subject company was reported granted general extension.";
        protected const string BUSINESS_EVENT_EXTENSION_COMPROMISE_TEXT_3 = "Subject company was reported asking one or more creditors for temporary extension.";
        protected const string BUSINESS_EVENT_EXTENSION_COMPROMISE_TEXT_4 = "Subject company was reported was granted temporary extension by one or more creditors";
        protected const string BUSINESS_EVENT_EXTENSION_COMPROMISE_TEXT_5 = "Subject company was reported offering to compromise.";
        protected const string BUSINESS_EVENT_EXTENSION_COMPROMISE_TEXT_7 = "Subject company was reported compromised with creditors.";
        protected const string BUSINESS_EVENT_INDICTMENT_TEXT = "Subject company was reported indicted.";
        protected const string BUSINESS_EVENT_INDICTMENT_CLOSED_TEXT = "The indictment on subject company was reported closed.";
        protected const string BUSINESS_EVENT_INJUNCTIONS_TEXT = "An injunction was issued against subject company at {1}, under the case number {2}.  Attorney assigned to the case is {3}, {4}.";
        protected const string BUSINESS_EVENT_JUDGEMENT_TEXT = "A judgement was reported on subject company in the amount of {1:c}.  Creditor: {2} {3}.";
        protected const string BUSINESS_EVENT_LETTER_OF_INTENT_TEXT = "A letter of intent was signed between subject company and {1}, {2} to {3}, {4}.";
        protected const string BUSINESS_EVENT_LIEN_TEXT = "A lien of public record was entered against subject company for {1:c} in favor of {2}, {3}.";
        protected const string BUSINESS_EVENT_NATURAL_DISASTER_TEXT = "Subject company suffered a {1} due to a {2}.  Damages were estimated at {3:c}.";
        protected const string BUSINESS_EVENT_NOT_HANDLING_PRODUCE_TEXT = "Subject company reportedly discontinued handling fresh produce.";
        protected const string BUSINESS_EVENT_PACA_LICENSE_SUSPENDED_TEXT_1 = "An Agricultural Marketing Service (AMS) news release dated {1:MM/dd/yyyy} reported that the USDA cited subject company for failure to pay a {2:c} award in favor of a {3} seller under the Perishable Agricultural Commodities Act.  Subject company was barred from operating in the produce industry until the award was paid, and {4} could not be employed or affiliated with a PACA licensee without USDA approval.";
        protected const string BUSINESS_EVENT_PACA_LICENSE_SUSPENDED_TEXT_2 = "An Agricultural Marketing Service (AMS) news release dated {1:MM/dd/yyyy} reported that the USDA cited subject company for \"willful, repeated and flagrant violations of the Perishable Agricultural Commodities Act.\"  Subject company failed to pay promptly and in full {2:c} for perishable agricultural commodities purchased, received and accepted from {3} sellers in the course of interstate commerce from {4} through {5}.  The firm could not operate in the produce industry until {6:MM/dd/yyyy} and then only if it obtained a PACA license.  {7} could not be employed or affiliated with a PACA licensee until {8:MM/dd/yyyy} and then only with the posting of a USDA-approved surety bond.";
        protected const string BUSINESS_EVENT_PACA_LICENSE_REINSTATED_TEXT = "The PACA license of subject company was reinstated.";
        protected const string BUSINESS_EVENT_PACA_TRUST_PROCEDURE_TEXT = "{1}, {2} filed an action to preserve its PACA trust rights in the amount of {3:c} against subject company.";
        protected const string BUSINESS_EVENT_RECEIVERSHIP_APPLIED_FOR_TEXT = "A receiver {1} was applied for by {2}.";
        protected const string BUSINESS_EVENT_RECEIVERSHIP_APPOINTED_TEXT = "A receiver {1} was appointed by {2}.";
        protected const string BUSINESS_EVENT_TREASURY_STOCK_TEXT_1 = "Subject company repurchased shared of its captial stock and retired it to treasury{1}.";
        protected const string BUSINESS_EVENT_TREASURY_STOCK_TEXT_2 = " in a transaction valued at {0:c}";
        protected const string BUSINESS_EVENT_TRO_TEXT = "A temporary restraining order was granted against the subject at {1}.  Case number is {2}.  Plaintiff, {3} {4}, is seeking {5:c}.";

        protected const string BUSINESS_EVENT_UNDER_LAW = "under {0} law";
        protected const string BUSINESS_EVENT_BANKRUPTCY_TEXT = "Additional details are documented in the Business Background section of this report.";

        // Business Event Type IDs
        protected const int BUSINESS_EVENT_ACQUISTION = 1;
        protected const int BUSINESS_EVENT_AGREEMENT_IN_PRINCIPLE = 2;
        protected const int BUSINESS_EVENT_ASSIGNMENT_BENEFIT_CREDITORS = 3;
        protected const int BUSINESS_EVENT_BANKRUPTCY = 4;
        protected const int BUSINESS_EVENT_US_BANKRUPTCY = 5;
        protected const int BUSINESS_EVENT_CANADIAN_BANKRUPTCY = 6;
        protected const int BUSINESS_EVENT_BUSINESS_CLOSED = 7;
        protected const int BUSINESS_EVENT_BUSINESS_ENTITY_CHANGED = 8;
        protected const int BUSINESS_EVENT_BUSINESS_STARTED = 9;
        protected const int BUSINESS_EVENT_INDIVIDUAL_OWNERSHIP_CHANGE = 10;
        protected const int BUSINESS_EVENT_DIVESTITURE = 11;
        protected const int BUSINESS_EVENT_DRC_ISSUE = 12;
        protected const int BUSINESS_EVENT_EXTENSION_COMPROMISE = 13;
        protected const int BUSINESS_EVENT_FINANCIAL_EVENT = 14;
        protected const int BUSINESS_EVENT_INDICTMENT = 15;
        protected const int BUSINESS_EVENT_INDICTMENT_CLOSED = 16;
        protected const int BUSINESS_EVENT_INJUNCTIONS = 17;
        protected const int BUSINESS_EVENT_JUDGEMENT = 18;
        protected const int BUSINESS_EVENT_LETTER_OF_INTENT = 19;
        protected const int BUSINESS_EVENT_LIEN = 20;
        protected const int BUSINESS_EVENT_LOCATION_CHANGE = 21;
        protected const int BUSINESS_EVENT_MERGER = 22;
        protected const int BUSINESS_EVENT_NATURAL_DISASTER = 23;
        protected const int BUSINESS_EVENT_NOT_HANDLING_PRODUCE = 24;
        protected const int BUSINESS_EVENT_OTHER_LEGAL_ACTION = 25;
        protected const int BUSINESS_EVENT_OTHER = 26;
        protected const int BUSINESS_EVENT_OTHER_PACA = 27;
        protected const int BUSINESS_EVENT_PACA_LICENSE_SUSPENDED = 28;
        protected const int BUSINESS_EVENT_PACA_LICENSE_REINSTATED = 29;
        protected const int BUSINESS_EVENT_PACA_TRUST_PROCEDURE = 30;
        protected const int BUSINESS_EVENT_PARTNERSHIP_DISOLUTION = 31;
        protected const int BUSINESS_EVENT_RECEIVERSHIP_APPLIED_FOR = 32;
        protected const int BUSINESS_EVENT_RECEIVERSHIP_APPOINTED = 33;
        protected const int BUSINESS_EVENT_SEC_ACTIONS = 34;
        protected const int BUSINESS_EVENT_PUBLIC_STOCK = 35;
        protected const int BUSINESS_EVENT_TREASURY_STOCK = 36;
        protected const int BUSINESS_EVENT_TRO = 37;
        #endregion

        #region Person Event Constants
        protected const string PERSON_EVENT_EDUCATION_TEXT = "On {0:MM/dd/yyyy}, {1} reportedly earned a {2} from {3}.";
        protected const string PERSON_EVENT_BANKRUPTCY_FILED_TEXT = "On {0:MM/dd/yyyy}, {1} filed a personal {2} {3} petition in bankruptcy.  The bankruptcy was filed with the {4} under the case number {5}.";
        protected const string PERSON_EVENT_BANKRUPTCY_DISMISSED_TEXT = "On {0:MM/dd/yyyy}, the personal {1} bankruptcy petition filed by {2} was reported {3} by the court.";

        protected const int PERSON_EVENT_DRC_VIOLATION = 1;
        protected const int PERSON_EVENT_PACA_VIOLATIONS = 2;
        protected const int PERSON_EVENT_EDUCATION = 3;
        protected const int PERSON_EVENT_BANKRUPTCY_FILED = 4;
        protected const int PERSON_EVENT_BANKRUPTCY_DISMISSED = 5;
        protected const int PERSON_EVENT_OTHER_LEGAL = 6;
        protected const int PERSON_EVENT_OTHER = 7;
        #endregion

        public DataFormatter() { }

        #region Business Event Methods

        /// <summary>
        /// Returns the formatted Business Event Verbiage based
        /// on the event type.  Will query for the appropriate PRBusinessEvent
        /// fields along with any extra tables it may need to construct
        /// the verbiage.
        /// </summary>
        /// <param name="iPRBusinessEventID">Business Event ID</param>
        /// <returns></returns>
        public string GetBusinessEventText(int iPRBusinessEventID) {
            return GetBusinessEventText(iPRBusinessEventID, BUSINESS_EVENT_REPORT_TYPE_BUSINESS_EVENTS);
        }


        /// <summary>
        /// Returns the formatted Business Event Verbiage based
        /// on the event type.  Will query for the appropriate PRBusinessEvent
        /// fields along with any extra tables it may need to construct
        /// the verbiage.
        /// </summary>
        /// <param name="iPRBusinessEventID">Business Event ID</param>
        /// <param name="iReportType"></param>
        /// <returns></returns>
        public string GetBusinessEventText(int iPRBusinessEventID, int iReportType) {

            //return GetNameLong(iPRBusinessEventID, iReportType);

            string szReturn = string.Empty;

            try {
                System.Data.SqlClient.SqlClientPermission permission = new System.Data.SqlClient.SqlClientPermission(System.Security.Permissions.PermissionState.Unrestricted);
                permission.Assert();   // Assert security permission! 
            } catch (Exception e) {
                return "ERROR Asserting SQL Permission: " + e.Message;
            }

            string szConnectionString = null;
            try {
                szConnectionString = GetConnectionString(szConnectionString);
            } catch (Exception e) {
                return "ERROR Getting Connection String: " + e.Message;
            }

            IDbConnection oConn = new System.Data.SqlClient.SqlConnection(szConnectionString);
            try {

                oConn.Open();

                Hashtable htBusinessEventValues = new Hashtable();
                string szEventText = string.Empty;

                ArrayList alArgList = new ArrayList();


                IDataReader oReader = null;
                try {

                    DBParameter oParm = new DBParameter("@Parm01", iPRBusinessEventID);
                    object[] oParmList = { oParm };

                    oReader = ExecuteReader(oConn, SQL_SELECT_BUSINESS_EVENT, oParmList);
                    if (!oReader.Read()) {
                        return "ERROR: Specified prbeBusinessEventID (" + iPRBusinessEventID.ToString() + ") was not found.";
                    }

                    // Put our values in a hashtable since we can only have
                    // one reader open at a time.  Depending upon the event type
                    // we may have to query for additional data.
                    for (int i = 0; i < oReader.FieldCount; i++) {
                        htBusinessEventValues.Add(oReader.GetName(i), oReader[i]);
                    }
                } catch (Exception e) {

                    return "ERROR: Error retrieving PRBusinessEvent record: " + e.Message;
                } finally {
                    if (oReader != null) {
                        oReader.Close();
                    }
                }

                alArgList.Add(Convert.ToDateTime(htBusinessEventValues["prbe_EffectiveDate"]));

                int iEventType = Convert.ToInt32(htBusinessEventValues["prbe_BusinessEventTypeId"]);
                switch (iEventType) {
                    case BUSINESS_EVENT_ACQUISTION:
                        szReturn = HandleAcquistionEvent(oConn, alArgList, htBusinessEventValues, iEventType);
                        break;
                    case BUSINESS_EVENT_AGREEMENT_IN_PRINCIPLE:
                        szReturn = HandleAgreementInPrincipleEvent(oConn, alArgList, htBusinessEventValues, iEventType);
                        break;
                    case BUSINESS_EVENT_ASSIGNMENT_BENEFIT_CREDITORS:
                        szReturn = HandleAssignmentBenefitCreditorsEvent(oConn, alArgList, htBusinessEventValues, iReportType);
                        break;
                    case BUSINESS_EVENT_US_BANKRUPTCY:
                        szReturn = HandleUSBankruptcyEvent(oConn, alArgList, htBusinessEventValues, iReportType);
                        break;
                    case BUSINESS_EVENT_CANADIAN_BANKRUPTCY:
                        szReturn = HandleCanadianBankruptcyEvent(oConn, alArgList, htBusinessEventValues);
                        break;
                    case BUSINESS_EVENT_BUSINESS_CLOSED:
                        szReturn = HandleBusinessClosedEvent(oConn, alArgList, htBusinessEventValues);
                        break;
                    case BUSINESS_EVENT_BUSINESS_ENTITY_CHANGED:
                        szReturn = HandleBusinessEntityChangeEvent(oConn, alArgList, htBusinessEventValues);
                        break;
                    case BUSINESS_EVENT_BUSINESS_STARTED:
                        szReturn = HandleBusinessStartedEvent(oConn, alArgList, htBusinessEventValues);
                        break;
                    case BUSINESS_EVENT_INDIVIDUAL_OWNERSHIP_CHANGE:
                        szReturn = HandleIndividualOwnershipChangeEvent(oConn, alArgList, htBusinessEventValues);
                        break;
                    case BUSINESS_EVENT_DIVESTITURE:
                        szReturn = HandleDivestitureEvent(oConn, alArgList, htBusinessEventValues);
                        break;
                    case BUSINESS_EVENT_DRC_ISSUE:
                        szReturn = HandleDRCIssueEvent(oConn, alArgList, htBusinessEventValues);
                        break;
                    case BUSINESS_EVENT_EXTENSION_COMPROMISE:
                        szReturn = HandleExtensionCompromiseEvent(oConn, alArgList, htBusinessEventValues);
                        break;
                    case BUSINESS_EVENT_INDICTMENT:
                        szReturn = string.Format(BUSINESS_EVENT_INDICTMENT_TEXT, alArgList.ToArray());
                        break;
                    case BUSINESS_EVENT_INDICTMENT_CLOSED:
                        szReturn = string.Format(BUSINESS_EVENT_INDICTMENT_CLOSED_TEXT, alArgList.ToArray());
                        break;
                    case BUSINESS_EVENT_INJUNCTIONS:
                        szReturn = HandleInjunctionsEvent(oConn, alArgList, htBusinessEventValues);
                        break;
                    case BUSINESS_EVENT_JUDGEMENT:
                        szReturn = HandleJudgementEvent(oConn, alArgList, htBusinessEventValues);
                        break;
                    case BUSINESS_EVENT_LETTER_OF_INTENT:
                        szReturn = HandleLetterOfIntentEvent(oConn, alArgList, htBusinessEventValues);
                        break;
                    case BUSINESS_EVENT_LIEN:
                        szReturn = HandleLienEvent(oConn, alArgList, htBusinessEventValues);
                        break;
                    case BUSINESS_EVENT_NATURAL_DISASTER:
                        szReturn = HandleNaturalDisasterEvent(oConn, alArgList, htBusinessEventValues);
                        break;
                    case BUSINESS_EVENT_NOT_HANDLING_PRODUCE:
                        szReturn = BUSINESS_EVENT_NOT_HANDLING_PRODUCE_TEXT;
                        break;
                    case BUSINESS_EVENT_PACA_LICENSE_SUSPENDED:
                        szReturn = HandlePACALicenseSuspendedEvent(oConn, alArgList, htBusinessEventValues);
                        break;
                    case BUSINESS_EVENT_PACA_LICENSE_REINSTATED:
                        szReturn = BUSINESS_EVENT_PACA_LICENSE_REINSTATED_TEXT;
                        break;
                    case BUSINESS_EVENT_PACA_TRUST_PROCEDURE:
                        szReturn = HandlePACATrustProcedureEvent(oConn, alArgList, htBusinessEventValues);
                        break;
                    case BUSINESS_EVENT_RECEIVERSHIP_APPLIED_FOR:
                        szReturn = HandleReceivershipAppliedForEvent(oConn, alArgList, htBusinessEventValues);
                        break;
                    case BUSINESS_EVENT_RECEIVERSHIP_APPOINTED:
                        szReturn = HandleReceivershipAppointedEvent(oConn, alArgList, htBusinessEventValues);
                        break;
                    case BUSINESS_EVENT_TREASURY_STOCK:
                        szReturn = HandleTreasuryStockEvent(oConn, alArgList, htBusinessEventValues);
                        break;
                    case BUSINESS_EVENT_TRO:
                        szReturn = HandleTROEvent(oConn, alArgList, htBusinessEventValues);
                        break;
                }

                if (htBusinessEventValues["prbe_PublishedAnalysis"] != DBNull.Value) {
                    szReturn += " " + Convert.ToString(htBusinessEventValues["prbe_PublishedAnalysis"]);
                }

                return szReturn;

            } catch (Exception e) {
                return "ERROR: Exception in GetBusinessEventText. " + e.Message;
            } finally {
                oConn.Close();
            }
        }

        /// <summary>
        /// Helper method for the GetBusinessEventText method.  Returns
        /// an array of company values based on the specified event type. 
        /// This array is used to format the business event verbiage.
        /// </summary>
        /// <param name="oConn">DBAccess object</param>
        /// <param name="iEventType">Event Type</param>
        /// <param name="iCompanyID">Company ID</param>
        /// <returns></returns>
        protected ArrayList GetCompanyInfo(IDbConnection oConn, int iEventType, int iCompanyID) {

            DBParameter oParm = new DBParameter("@Parm01", iCompanyID);
            object[] oParmList = { oParm };

            IDataReader oReader = ExecuteReader(oConn, SQL_SELECT_BUSINESS_EVENT_COMPANY, oParmList);
            try {
                if (!oReader.Read()) {
                    throw new ApplicationException("Company ID not found. (" + iCompanyID.ToString() + ")");
                }

                ArrayList oArgList = new ArrayList();
                switch (iEventType) {
                    case BUSINESS_EVENT_RECEIVERSHIP_APPLIED_FOR:
                    case BUSINESS_EVENT_RECEIVERSHIP_APPOINTED:
                        oArgList.Add(oReader["Comp_PRCorrTradestyle"]);
                        break;
                    default:
                        oArgList.Add(oReader["Comp_PRCorrTradestyle"]);
                        oArgList.Add(FormatCityStateCountry(oReader["prci_City"].ToString(),
                            oReader["prst_State"].ToString(),
                            oReader["prcn_Country"].ToString()));
                        break;
                }
                return oArgList;
            } finally {
                if (oReader != null) {
                    oReader.Close();
                }
            }
        }

        /// <summary>
        /// Helper method that returns the specified text
        /// handling the "Other" scenario.
        /// </summary>
        /// <param name="oConn"></param>
        /// <param name="htBusinessEventValues"></param>
        /// <param name="szCustomCaptFamily"></param>
        /// <param name="szCodeOther"></param>
        /// <returns></returns>
        protected string GetTypeValue(IDbConnection oConn, Hashtable htBusinessEventValues, string szCustomCaptFamily, string szCodeOther) {

            string szType = Convert.ToString(htBusinessEventValues["prbe_DetailedType"]);
            if (szType == szCodeOther) {
                return Convert.ToString(htBusinessEventValues["prbe_OtherDescription"]);
            } else {
                return GetCustomCaption(oConn, szCustomCaptFamily, szType);
            }
        }

        /// <summary>
        /// Helper method that returns the specified Acquisition text
        /// handling the "Other" scenario.
        /// </summary>
        /// <param name="oConn"></param>
        /// <param name="iStateID"></param>
        /// <returns></returns>
        protected string GetState(IDbConnection oConn, int iStateID) {
            DBParameter oParm = new DBParameter("@Parm01", iStateID);
            object[] oParmList = { oParm };

            return (string)ExecuteScalar(oConn, SQL_SELECT_STATE, oParmList);
        }

        /// <summary>
        /// Helper method that returns the custom caption for the
        /// specified family and code.
        /// </summary>
        /// <param name="oConn">Database Access</param>
        /// <param name="szFamily">Custom Caption Family</param>
        /// <param name="szCode">Custom Caption Code</param>
        /// <returns></returns>
        protected string GetCustomCaption(IDbConnection oConn, string szFamily, string szCode) {

            if (!_htCustomCaptionCache.ContainsKey(szFamily)) {
                DBParameter oParm = new DBParameter("@Parm01", szFamily);
                object[] oParmList = { oParm };

                IDataReader oReader = ExecuteReader(oConn, SQL_SELECT_CUSTOM_CAPTIONS, oParmList);
                try {

                    Hashtable htCodes = new Hashtable();
                    while (oReader.Read()) {
                        htCodes.Add(oReader["Capt_Code"].ToString().Trim(), oReader["Capt_US"].ToString().Trim());
                    }
                    _htCustomCaptionCache.Add(szFamily, htCodes);
                } finally {
                    if (oReader != null) {
                        oReader.Close();
                    }
                }
            }

            return Convert.ToString(((Hashtable)_htCustomCaptionCache[szFamily])[szCode]);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="oConn"></param>
        /// <param name="szName"></param>
        /// <param name="htBusinessEventValues"></param>
        /// <returns></returns>
        protected string GetCustomCaption(IDbConnection oConn, string szName, Hashtable htBusinessEventValues) {
            return GetCustomCaption(oConn, szName, Convert.ToString(htBusinessEventValues[szName]));
        }

        /// <summary>
        /// Helper method that formats the text for the
        /// Acquistion business event.
        /// </summary>
        /// <param name="oConn">DBAccess instance</param>
        /// <param name="alArgList">Argument List</param>
        /// <param name="htBusinessEventValues">Business Event Data Attributes</param>
        /// <param name="iEventType">Business Event Type ID</param>
        /// <returns></returns>
        protected string HandleAcquistionEvent(IDbConnection oConn, ArrayList alArgList, Hashtable htBusinessEventValues, int iEventType) {

            if ((IsStringEmpty(htBusinessEventValues["prbe_DetailedType"])) ||
                (IsStringEmpty(htBusinessEventValues["prbe_RelatedCompany1Id"]))) {
                return string.Empty;
            }

            alArgList.Add(GetTypeValue(oConn, htBusinessEventValues, "prbe_AcquisitionType", BUSINESS_EVENT_ACQUISTION_TYPE_OTHER));
            alArgList.AddRange(GetCompanyInfo(oConn, iEventType, Convert.ToInt32(htBusinessEventValues["prbe_RelatedCompany1Id"])));
            return string.Format(BUSINESS_EVENT_ACQUISTION_TEXT, alArgList.ToArray());
        }

        /// <summary>
        /// Helper method that formats the text for the
        /// Agreement in Principle business event.
        /// </summary>
        /// <param name="oConn">DBAccess instance</param>
        /// <param name="alArgList">Argument List</param>
        /// <param name="htBusinessEventValues">Business Event Data Attributes</param>
        /// <param name="iEventType">Business Event Type ID</param>
        /// <returns></returns>
        protected string HandleAgreementInPrincipleEvent(IDbConnection oConn, ArrayList alArgList, Hashtable htBusinessEventValues, int iEventType) {

            if ((IsStringEmpty(htBusinessEventValues["prbe_DetailedType"])) ||
                (IsStringEmpty(htBusinessEventValues["prbe_RelatedCompany1Id"])) ||
                (IsStringEmpty(htBusinessEventValues["prbe_AgreementCategory"]))) {
                return string.Empty;
            }

            alArgList.AddRange(GetCompanyInfo(oConn, iEventType, Convert.ToInt32(htBusinessEventValues["prbe_RelatedCompany1Id"])));
            alArgList.Add(GetCustomCaption(oConn, "prbe_AgreementCategory", Convert.ToString(htBusinessEventValues["prbe_AgreementCategory"])));
            alArgList.Add(GetTypeValue(oConn, htBusinessEventValues, "prbe_AcquisitionType", BUSINESS_EVENT_ACQUISTION_TYPE_OTHER));
            return string.Format(BUSINESS_EVENT_AGREEMENT_IN_PRINCIPLE_TEXT, alArgList.ToArray());
        }

        /// <summary>
        /// Helper method that formats the text for the
        /// Assignment for the Benefit of Creditors business event.
        /// </summary>
        /// <param name="oConn">DBAccess instance</param>
        /// <param name="alArgList">Argument List</param>
        /// <param name="htBusinessEventValues">Business Event Data Attributes</param>
        /// <param name="iReportType"></param>
        /// <returns></returns>
        protected string HandleAssignmentBenefitCreditorsEvent(IDbConnection oConn, ArrayList alArgList, Hashtable htBusinessEventValues, int iReportType) {

            if ((IsStringEmpty(htBusinessEventValues["prbe_AssigneeTrusteeName"])) ||
                (IsStringEmpty(htBusinessEventValues["prbe_AssigneeTrusteeAddress"])) ||
                (IsStringEmpty(htBusinessEventValues["prbe_AssigneeTrusteePhone"]))) {
                return string.Empty;
            }

            alArgList.Add(htBusinessEventValues["prbe_AssigneeTrusteeName"]);
            alArgList.Add(htBusinessEventValues["prbe_AssigneeTrusteeAddress"]);
            alArgList.Add(htBusinessEventValues["prbe_AssigneeTrusteePhone"]);

            if (iReportType == BUSINESS_EVENT_REPORT_TYPE_BANKRUPTCY) {
                return string.Format(BUSINESS_EVENT_ASSIGNMENT_BENEFIT_CREDITORS_TEXT_01 + BUSINESS_EVENT_BANKRUPTCY_TEXT, alArgList.ToArray());
            } else {
                return string.Format(BUSINESS_EVENT_ASSIGNMENT_BENEFIT_CREDITORS_TEXT_01 + BUSINESS_EVENT_ASSIGNMENT_BENEFIT_CREDITORS_TEXT_02, alArgList.ToArray());
            }
        }

        /// <summary>
        /// Helper method that formats the text for the
        /// UA Bankruptcy business event.
        /// </summary>
        /// <param name="oConn">DBAccess instance</param>
        /// <param name="alArgList">Argument List</param>
        /// <param name="htBusinessEventValues">Business Event Data Attributes</param>
        /// <param name="iReportType"></param>
        /// <returns></returns>
        protected string HandleUSBankruptcyEvent(IDbConnection oConn, ArrayList alArgList, Hashtable htBusinessEventValues, int iReportType) {

            if ((IsStringEmpty(htBusinessEventValues["prbe_USBankruptcyVoluntary"])) ||
                (IsStringEmpty(htBusinessEventValues["prbe_DetailedType"])) ||
                (IsStringEmpty(htBusinessEventValues["prbe_USBankruptcyCourt"])) ||
                (IsStringEmpty(htBusinessEventValues["prbe_CourtDistrict"])) ||
                (IsStringEmpty(htBusinessEventValues["prbe_CaseNumber"])) ||
                (IsStringEmpty(htBusinessEventValues["prbe_AttorneyName"])) ||
                (IsStringEmpty(htBusinessEventValues["prbe_AttorneyPhone"])) ||
                (IsStringEmpty(htBusinessEventValues["prbe_AssigneeTrusteeName"])) ||
                (IsStringEmpty(htBusinessEventValues["prbe_AssigneeTrusteePhone"])) ||
                (IsStringEmpty(htBusinessEventValues["prbe_AssetAmount"])) ||
                (IsStringEmpty(htBusinessEventValues["prbe_LiabilityAmount"]))) {
                return string.Empty;
            }


            if ("Y" == Convert.ToString(htBusinessEventValues["prbe_USBankruptcyVoluntary"])) {
                alArgList.Add("volunatry");
            } else {
                alArgList.Add("involuntary");
            }
            alArgList.Add(htBusinessEventValues["prbe_DetailedType"]);
            alArgList.Add(GetCustomCaption(oConn, "prbe_USBankruptcyCourt", Convert.ToString(htBusinessEventValues["prbe_USBankruptcyCourt"])));
            alArgList.Add(htBusinessEventValues["prbe_CourtDistrict"]);
            alArgList.Add(htBusinessEventValues["prbe_CaseNumber"]);
            alArgList.Add(htBusinessEventValues["prbe_AttorneyName"]);
            alArgList.Add(htBusinessEventValues["prbe_AttorneyPhone"]);
            alArgList.Add(htBusinessEventValues["prbe_AssigneeTrusteeName"]);
            alArgList.Add(htBusinessEventValues["prbe_AssigneeTrusteePhone"]);
            alArgList.Add(htBusinessEventValues["prbe_AssetAmount"]);
            alArgList.Add(htBusinessEventValues["prbe_LiabilityAmount"]);

            if (iReportType == BUSINESS_EVENT_REPORT_TYPE_BANKRUPTCY) {
                return string.Format(BUSINESS_EVENT_US_BANKRUPTCY_TEXT_01 + BUSINESS_EVENT_BANKRUPTCY_TEXT, alArgList.ToArray());
            } else {
                return string.Format(BUSINESS_EVENT_US_BANKRUPTCY_TEXT_01 + BUSINESS_EVENT_US_BANKRUPTCY_TEXT_02, alArgList.ToArray());
            }
        }

        /// <summary>
        /// Helper method that formats the text for the
        /// Canadian Bankruptcy business event.
        /// </summary>
        /// <param name="oConn">DBAccess instance</param>
        /// <param name="alArgList">Argument List</param>
        /// <param name="htBusinessEventValues">Business Event Data Attributes</param>
        /// <returns></returns>
        protected string HandleCanadianBankruptcyEvent(IDbConnection oConn, ArrayList alArgList, Hashtable htBusinessEventValues) {

            if (IsStringEmpty(htBusinessEventValues["prbe_DetailedType"])) {
                return string.Empty;
            }

            alArgList.Add(GetCustomCaption(oConn, "prbe_CanBankruptcyType", Convert.ToString(htBusinessEventValues["prbe_DetailedType"])));
            return string.Format(BUSINESS_EVENT_CANADIAN_BANKRUPTCY_TEXT, alArgList.ToArray());
        }

        /// <summary>
        /// Helper method that formats the text for the
        /// Business Closed business event.
        /// </summary>
        /// <param name="oConn">DBAccess instance</param>
        /// <param name="alArgList">Argument List</param>
        /// <param name="htBusinessEventValues">Business Event Data Attributes</param>
        /// <returns></returns>
        protected string HandleBusinessClosedEvent(IDbConnection oConn, ArrayList alArgList, Hashtable htBusinessEventValues) {

            if (IsStringEmpty(htBusinessEventValues["prbe_DetailedType"])) {
                return string.Empty;
            }

            string szType = Convert.ToString(htBusinessEventValues["prbe_DetailedType"]).Trim();
            string szText = null;
            switch (szType) {
                case "1":
                    szText = BUSINESS_EVENT_BUSINESS_CLOSED_TEXT_88;
                    break;
                case "2":
                    szText = BUSINESS_EVENT_BUSINESS_CLOSED_TEXT_108;
                    break;
                case "3":
                    szText = BUSINESS_EVENT_BUSINESS_CLOSED_TEXT_113;
                    break;
                case "4":
                    szText = BUSINESS_EVENT_BUSINESS_CLOSED_TEXT_INACTIVE;
                    break;
                default:
                    szText = "ERROR: Invalid prbe_DetailedType value found (" + szType + ")";
                    break;
            }
            return string.Format(szText, alArgList.ToArray());
        }

        /// <summary>
        /// Helper method that formats the text for the
        /// Entity Change business event.
        /// </summary>
        /// <param name="oConn">DBAccess instance</param>
        /// <param name="alArgList">Argument List</param>
        /// <param name="htBusinessEventValues">Business Event Data Attributes</param>
        /// <returns></returns>
        protected string HandleBusinessEntityChangeEvent(IDbConnection oConn, ArrayList alArgList, Hashtable htBusinessEventValues) {

            if (IsStringEmpty(htBusinessEventValues["prbe_DetailedType"])) {
                return string.Empty;
            }

            alArgList.Add(GetTypeValue(oConn, htBusinessEventValues, "prbe_NewEntityType", string.Empty));
            alArgList.Add(GetUnderLawText(oConn, htBusinessEventValues));
            return string.Format(BUSINESS_EVENT_BUSINESS_ENTITY_CHANGED_TEXT, alArgList.ToArray());
        }

        /// <summary>
        /// Helper method that formats the text for the
        /// Business Started business event.
        /// </summary>
        /// <param name="oConn">DBAccess instance</param>
        /// <param name="alArgList">Argument List</param>
        /// <param name="htBusinessEventValues">Business Event Data Attributes</param>
        /// <returns></returns>
        protected string HandleBusinessStartedEvent(IDbConnection oConn, ArrayList alArgList, Hashtable htBusinessEventValues) {

            if (IsStringEmpty(htBusinessEventValues["prbe_DetailedType"])) {
                return string.Empty;
            }

            alArgList.Add(GetTypeValue(oConn, htBusinessEventValues, "prbe_NewEntityType", string.Empty));
            alArgList.Add(GetUnderLawText(oConn, htBusinessEventValues));
            return string.Format(BUSINESS_EVENT_BUSINESS_STARTED_TEXT, alArgList.ToArray());
        }

        /// <summary>
        /// Helper method that formats the text for the
        /// Individual Ownership Change business event.
        /// </summary>
        /// <param name="oConn">DBAccess instance</param>
        /// <param name="alArgList">Argument List</param>
        /// <param name="htBusinessEventValues">Business Event Data Attributes</param>
        /// <returns></returns>
        protected string HandleIndividualOwnershipChangeEvent(IDbConnection oConn, ArrayList alArgList, Hashtable htBusinessEventValues) {

            if ((IsStringEmpty(htBusinessEventValues["prbe_IndividualSellerId"])) ||
                (IsStringEmpty(htBusinessEventValues["prbe_PercentSold"])) ||
                (IsStringEmpty(htBusinessEventValues["prbe_DetailedType"])) ||
                (IsStringEmpty(htBusinessEventValues["prbe_IndividualBuyerId"]))) {
                return string.Empty;
            }

            alArgList.Add(GetPersonName(oConn, Convert.ToInt32(htBusinessEventValues["prbe_IndividualSellerId"])));
            alArgList.Add(htBusinessEventValues["prbe_PercentSold"]);
            alArgList.Add(GetTypeValue(oConn, htBusinessEventValues, "prbe_SaleType", string.Empty));
            alArgList.Add(GetPersonName(oConn, Convert.ToInt32(htBusinessEventValues["prbe_IndividualBuyerId"])));
            return string.Format(BUSINESS_EVENT_INDIVIDUAL_OWNERSHIP_CHANGE_TEXT, alArgList.ToArray());
        }

        /// <summary>
        /// Helper method that formats the text for the
        /// Divestiture/Sale of Business/Assets business event.
        /// </summary>
        /// <param name="oConn">DBAccess instance</param>
        /// <param name="alArgList">Argument List</param>
        /// <param name="htBusinessEventValues">Business Event Data Attributes</param>
        /// <returns></returns>
        protected string HandleDivestitureEvent(IDbConnection oConn, ArrayList alArgList, Hashtable htBusinessEventValues) {

            if ((IsStringEmpty(htBusinessEventValues["prbe_DetailedType"])) ||
                (IsStringEmpty(htBusinessEventValues["prbe_RelatedCompany1Id"]))) {
                return string.Empty;
            }

            alArgList.Add(GetTypeValue(oConn, htBusinessEventValues, "prbe_AcquisitionType", BUSINESS_EVENT_ACQUISTION_TYPE_OTHER));
            alArgList.AddRange(GetCompanyInfo(oConn, BUSINESS_EVENT_DIVESTITURE, Convert.ToInt32(htBusinessEventValues["prbe_RelatedCompany1Id"])));
            return string.Format(BUSINESS_EVENT_DIVESTITURE_TEXT, alArgList.ToArray());
        }

        /// <summary>
        /// Helper method that formats the text for the
        /// DRC Issue business event.
        /// </summary>
        /// <param name="oConn">DBAccess instance</param>
        /// <param name="alArgList">Argument List</param>
        /// <param name="htBusinessEventValues">Business Event Data Attributes</param>
        /// <returns></returns>
        protected string HandleDRCIssueEvent(IDbConnection oConn, ArrayList alArgList, Hashtable htBusinessEventValues) {

            if (IsStringEmpty(htBusinessEventValues["prbe_DetailedType"])) {
                return string.Empty;
            }

            string szType = Convert.ToString(htBusinessEventValues["prbe_DetailedType"]).Trim();
            string szText = null;
            switch (szType) {
                case "1":
                    szText = BUSINESS_EVENT_DRC_ISSUE_TEXT_155;
                    break;
                case "2":
                    szText = BUSINESS_EVENT_DRC_ISSUE_TEXT_156;
                    break;
                case "3":
                    szText = BUSINESS_EVENT_DRC_ISSUE_TEXT_157;
                    break;
                case "4":
                    szText = BUSINESS_EVENT_DRC_ISSUE_TEXT_158;
                    break;
                default:
                    szText = "ERROR: Invalid prbe_DRCType value found (" + szType + ")";
                    break;
            }
            return string.Format(szText, alArgList.ToArray());
        }


        /// <summary>
        /// Helper method that formats the text for the
        /// Extension Compromise business event.
        /// </summary>
        /// <param name="oConn">DBAccess instance</param>
        /// <param name="alArgList">Argument List</param>
        /// <param name="htBusinessEventValues">Business Event Data Attributes</param>
        /// <returns></returns>
        protected string HandleExtensionCompromiseEvent(IDbConnection oConn, ArrayList alArgList, Hashtable htBusinessEventValues) {

            if (IsStringEmpty(htBusinessEventValues["prbe_DetailedType"])) {
                return string.Empty;
            }

            string szType = Convert.ToString(htBusinessEventValues["prbe_DetailedType"]).Trim();
            string szText = null;
            switch (szType) {
                case "1":
                    szText = BUSINESS_EVENT_EXTENSION_COMPROMISE_TEXT_1;
                    break;
                case "2":
                    szText = BUSINESS_EVENT_EXTENSION_COMPROMISE_TEXT_2;
                    break;
                case "3":
                    szText = BUSINESS_EVENT_EXTENSION_COMPROMISE_TEXT_3;
                    break;
                case "4":
                    szText = BUSINESS_EVENT_EXTENSION_COMPROMISE_TEXT_4;
                    break;
                case "5":
                    szText = BUSINESS_EVENT_EXTENSION_COMPROMISE_TEXT_5;
                    break;
                case "7":
                    szText = BUSINESS_EVENT_EXTENSION_COMPROMISE_TEXT_7;
                    break;
                default:
                    szText = "ERROR: Invalid prbe_ExtensionType value found (" + szType + ")";
                    break;
            }
            return string.Format(szText, alArgList.ToArray());
        }

        /// <summary>
        /// Helper method that formats the text for the
        /// Injunction business event.
        /// </summary>
        /// <param name="oConn">DBAccess instance</param>
        /// <param name="alArgList">Argument List</param>
        /// <param name="htBusinessEventValues">Business Event Data Attributes</param>
        /// <returns></returns>
        protected string HandleInjunctionsEvent(IDbConnection oConn, ArrayList alArgList, Hashtable htBusinessEventValues) {

            if ((IsStringEmpty(htBusinessEventValues["prbe_CourtDistrict"])) ||
                (IsStringEmpty(htBusinessEventValues["prbe_CaseNumber"])) ||
                (IsStringEmpty(htBusinessEventValues["prbe_AttorneyName"])) ||
                (IsStringEmpty(htBusinessEventValues["prbe_AttorneyPhone"]))) {
                return string.Empty;
            }


            alArgList.Add(htBusinessEventValues["prbe_CourtDistrict"]);
            alArgList.Add(htBusinessEventValues["prbe_CaseNumber"]);
            alArgList.Add(htBusinessEventValues["prbe_AttorneyName"]);
            alArgList.Add(htBusinessEventValues["prbe_AttorneyPhone"]);
            return string.Format(BUSINESS_EVENT_INJUNCTIONS_TEXT, alArgList.ToArray());
        }

        /// <summary>
        /// Helper method that formats the text for the
        /// Judgement business event.
        /// </summary>
        /// <param name="oConn">DBAccess instance</param>
        /// <param name="alArgList">Argument List</param>
        /// <param name="htBusinessEventValues">Business Event Data Attributes</param>
        /// <returns></returns>
        protected string HandleJudgementEvent(IDbConnection oConn, ArrayList alArgList, Hashtable htBusinessEventValues) {

            if ((IsStringEmpty(htBusinessEventValues["prbe_Amount"])) ||
                (IsStringEmpty(htBusinessEventValues["prbe_RelatedCompany1Id"]))) {
                return string.Empty;
            }

            alArgList.Add(htBusinessEventValues["prbe_Amount"]);
            alArgList.AddRange(GetCompanyInfo(oConn, BUSINESS_EVENT_JUDGEMENT, Convert.ToInt32(htBusinessEventValues["prbe_RelatedCompany1Id"])));
            return string.Format(BUSINESS_EVENT_JUDGEMENT_TEXT, alArgList.ToArray());
        }

        /// <summary>
        /// Helper method that formats the text for the
        /// Letter of Intent business event.
        /// </summary>
        /// <param name="oConn">DBAccess instance</param>
        /// <param name="alArgList">Argument List</param>
        /// <param name="htBusinessEventValues">Business Event Data Attributes</param>
        /// <returns></returns>
        protected string HandleLetterOfIntentEvent(IDbConnection oConn, ArrayList alArgList, Hashtable htBusinessEventValues) {

            if ((IsStringEmpty(htBusinessEventValues["prbe_RelatedCompany1Id"])) ||
                (IsStringEmpty(htBusinessEventValues["prbe_AgreementCategory"])) ||
                (IsStringEmpty(htBusinessEventValues["prbe_DetailedType"]))) {
                return string.Empty;
            }

            alArgList.AddRange(GetCompanyInfo(oConn, BUSINESS_EVENT_LETTER_OF_INTENT, Convert.ToInt32(htBusinessEventValues["prbe_RelatedCompany1Id"])));
            alArgList.Add(GetCustomCaption(oConn, "prbe_AgreementCategory", Convert.ToString(htBusinessEventValues["prbe_AgreementCategory"])));
            alArgList.Add(GetTypeValue(oConn, htBusinessEventValues, "prbe_AcquisitionType", BUSINESS_EVENT_ACQUISTION_TYPE_OTHER));
            return string.Format(BUSINESS_EVENT_LETTER_OF_INTENT_TEXT, alArgList.ToArray());
        }

        /// <summary>
        /// Helper method that formats the text for the
        /// Lien business event.
        /// </summary>
        /// <param name="oConn">DBAccess instance</param>
        /// <param name="alArgList">Argument List</param>
        /// <param name="htBusinessEventValues">Business Event Data Attributes</param>
        /// <returns></returns>
        protected string HandleLienEvent(IDbConnection oConn, ArrayList alArgList, Hashtable htBusinessEventValues) {

            if ((IsStringEmpty(htBusinessEventValues["prbe_Amount"])) ||
                (IsStringEmpty(htBusinessEventValues["prbe_RelatedCompany1Id"]))) {
                return string.Empty;
            }

            alArgList.Add(htBusinessEventValues["prbe_Amount"]);
            alArgList.AddRange(GetCompanyInfo(oConn, BUSINESS_EVENT_LETTER_OF_INTENT, Convert.ToInt32(htBusinessEventValues["prbe_RelatedCompany1Id"])));
            return string.Format(BUSINESS_EVENT_LIEN_TEXT, alArgList.ToArray());
        }

        /// <summary>
        /// Helper method that formats the text for the
        /// Natural Disaster business event.
        /// </summary>
        /// <param name="oConn">DBAccess instance</param>
        /// <param name="alArgList">Argument List</param>
        /// <param name="htBusinessEventValues">Business Event Data Attributes</param>
        /// <returns></returns>
        protected string HandleNaturalDisasterEvent(IDbConnection oConn, ArrayList alArgList, Hashtable htBusinessEventValues) {

            if ((IsStringEmpty(htBusinessEventValues["prbe_Amount"])) ||
                (IsStringEmpty(htBusinessEventValues["prbe_DisasterImpact"])) ||
                (IsStringEmpty(htBusinessEventValues["prbe_DetailedType"]))) {
                return string.Empty;
            }

            alArgList.Add(GetCustomCaption(oConn, "prbe_DisasterImpact", (string)htBusinessEventValues["prbe_DisasterImpact"]));
            alArgList.Add(GetTypeValue(oConn, htBusinessEventValues, "prbe_DisasterType", "7"));
            alArgList.Add(htBusinessEventValues["prbe_Amount"]);
            return string.Format(BUSINESS_EVENT_NATURAL_DISASTER_TEXT, alArgList.ToArray());
        }


        /// <summary>
        /// Helper method that formats the text for the
        /// PACA License Suspended business event.
        /// </summary>
        /// <param name="oConn">DBAccess instance</param>
        /// <param name="alArgList">Argument List</param>
        /// <param name="htBusinessEventValues">Business Event Data Attributes</param>
        /// <returns></returns>
        protected string HandlePACALicenseSuspendedEvent(IDbConnection oConn, ArrayList alArgList, Hashtable htBusinessEventValues) {

            string szType = Convert.ToString(htBusinessEventValues["prbe_DetailedType"]);
            if (szType == "1") {

                if ((IsStringEmpty(htBusinessEventValues["prbe_EffectiveDate"])) ||
                    (IsStringEmpty(htBusinessEventValues["prbe_Amount"])) ||
                    (IsStringEmpty(htBusinessEventValues["prbe_StateId"])) ||
                    (IsStringEmpty(htBusinessEventValues["prbe_Names"]))) {
                    return string.Empty;
                }

                alArgList.Add(htBusinessEventValues["prbe_EffectiveDate"]);
                alArgList.Add(htBusinessEventValues["prbe_Amount"]);
                alArgList.Add(GetState(oConn, Convert.ToInt32(htBusinessEventValues["prbe_StateID"])));
                alArgList.Add(htBusinessEventValues["prbe_Names"]);
                return string.Format(BUSINESS_EVENT_PACA_LICENSE_SUSPENDED_TEXT_1, alArgList.ToArray());

            } else if (szType == "2") {
                if ((IsStringEmpty(htBusinessEventValues["prbe_EffectiveDate"])) ||
                    (IsStringEmpty(htBusinessEventValues["prbe_Amount"])) ||
                    (IsStringEmpty(htBusinessEventValues["prbe_NumberSellers"])) ||
                    (IsStringEmpty(htBusinessEventValues["prbe_NonPromptStart"])) ||
                    (IsStringEmpty(htBusinessEventValues["prbe_NonPromptEnd"])) ||
                    (IsStringEmpty(htBusinessEventValues["prbe_BusinessOperateUntil"])) ||
                    (IsStringEmpty(htBusinessEventValues["prbe_Names"])) ||
                    (IsStringEmpty(htBusinessEventValues["prbe_IndividualOperateUntil"]))) {
                    return string.Empty;
                }

                alArgList.Add(htBusinessEventValues["prbe_EffectiveDate"]);
                alArgList.Add(htBusinessEventValues["prbe_Amount"]);
                alArgList.Add(htBusinessEventValues["prbe_NumberSellers"]);
                alArgList.Add(htBusinessEventValues["prbe_NonPromptStart"]);
                alArgList.Add(htBusinessEventValues["prbe_NonPromptEnd"]);
                alArgList.Add(htBusinessEventValues["prbe_BusinessOperateUntil"]);
                alArgList.Add(htBusinessEventValues["prbe_Names"]);
                alArgList.Add(htBusinessEventValues["prbe_IndividualOperateUntil"]);
                return string.Format(BUSINESS_EVENT_PACA_LICENSE_SUSPENDED_TEXT_2, alArgList.ToArray());

            } else {
                return "ERROR: Invalid prbe_PACASuspensionType found (" + szType + ")";
            }
        }

        /// <summary>
        /// Helper method that formats the text for the
        /// PACA Trust Procedure business event.
        /// </summary>
        /// <param name="oConn">DBAccess instance</param>
        /// <param name="alArgList">Argument List</param>
        /// <param name="htBusinessEventValues">Business Event Data Attributes</param>
        /// <returns></returns>
        protected string HandlePACATrustProcedureEvent(IDbConnection oConn, ArrayList alArgList, Hashtable htBusinessEventValues) {

            if ((IsStringEmpty(htBusinessEventValues["prbe_RelatedCompany1Id"])) ||
                (IsStringEmpty(htBusinessEventValues["prbe_Amount"]))) {
                return string.Empty;
            }

            alArgList.AddRange(GetCompanyInfo(oConn, BUSINESS_EVENT_PACA_TRUST_PROCEDURE, Convert.ToInt32(htBusinessEventValues["prbe_RelatedCompany1Id"])));
            alArgList.Add(htBusinessEventValues["prbe_Amount"]);
            return string.Format(BUSINESS_EVENT_PACA_TRUST_PROCEDURE_TEXT, alArgList.ToArray());
        }

        /// <summary>
        /// Helper method that formats the text for the
        /// Receivership Applied For business event.
        /// </summary>
        /// <param name="oConn">DBAccess instance</param>
        /// <param name="alArgList">Argument List</param>
        /// <param name="htBusinessEventValues">Business Event Data Attributes</param>
        /// <returns></returns>
        protected string HandleReceivershipAppliedForEvent(IDbConnection oConn, ArrayList alArgList, Hashtable htBusinessEventValues) {

            if ((IsStringEmpty(htBusinessEventValues["prbe_RelatedCompany1Id"])) ||
                (IsStringEmpty(htBusinessEventValues["prbe_RelatedCompany2Id"]))) {
                return string.Empty;
            }

            alArgList.AddRange(GetCompanyInfo(oConn, BUSINESS_EVENT_RECEIVERSHIP_APPLIED_FOR, Convert.ToInt32(htBusinessEventValues["prbe_RelatedCompany1Id"])));
            alArgList.AddRange(GetCompanyInfo(oConn, BUSINESS_EVENT_RECEIVERSHIP_APPLIED_FOR, Convert.ToInt32(htBusinessEventValues["prbe_RelatedCompany2Id"])));
            return string.Format(BUSINESS_EVENT_RECEIVERSHIP_APPLIED_FOR_TEXT, alArgList.ToArray());
        }

        /// <summary>
        /// Helper method that formats the text for the
        /// Receivership Appointed business event.
        /// </summary>
        /// <param name="oConn">DBAccess instance</param>
        /// <param name="alArgList">Argument List</param>
        /// <param name="htBusinessEventValues">Business Event Data Attributes</param>
        /// <returns></returns>
        protected string HandleReceivershipAppointedEvent(IDbConnection oConn, ArrayList alArgList, Hashtable htBusinessEventValues) {

            if ((IsStringEmpty(htBusinessEventValues["prbe_RelatedCompany1Id"])) ||
                (IsStringEmpty(htBusinessEventValues["prbe_RelatedCompany2Id"]))) {
                return string.Empty;
            }

            alArgList.AddRange(GetCompanyInfo(oConn, BUSINESS_EVENT_RECEIVERSHIP_APPOINTED, Convert.ToInt32(htBusinessEventValues["prbe_RelatedCompany1Id"])));
            alArgList.AddRange(GetCompanyInfo(oConn, BUSINESS_EVENT_RECEIVERSHIP_APPOINTED, Convert.ToInt32(htBusinessEventValues["prbe_RelatedCompany2Id"])));
            return string.Format(BUSINESS_EVENT_RECEIVERSHIP_APPOINTED_TEXT, alArgList.ToArray());
        }

        /// <summary>
        /// Helper method that formats the text for the
        /// Treasury Stock business event.
        /// </summary>
        /// <param name="oConn">DBAccess instance</param>
        /// <param name="alArgList">Argument List</param>
        /// <param name="htBusinessEventValues">Business Event Data Attributes</param>
        /// <returns></returns>
        protected string HandleTreasuryStockEvent(IDbConnection oConn, ArrayList alArgList, Hashtable htBusinessEventValues) {

            string szAmountClause = string.Empty;
            if (!IsStringEmpty(htBusinessEventValues["prbe_Amount"])) {
                szAmountClause = string.Format(BUSINESS_EVENT_TREASURY_STOCK_TEXT_2, htBusinessEventValues["prbe_Amount"]);
            }

            alArgList.Add(szAmountClause);
            return string.Format(BUSINESS_EVENT_TREASURY_STOCK_TEXT_1, alArgList.ToArray());
        }

        /// <summary>
        /// Helper method that formats the text for the
        /// TRO business event.
        /// </summary>
        /// <param name="oConn">DBAccess instance</param>
        /// <param name="alArgList">Argument List</param>
        /// <param name="htBusinessEventValues">Business Event Data Attributes</param>
        /// <returns></returns>
        protected string HandleTROEvent(IDbConnection oConn, ArrayList alArgList, Hashtable htBusinessEventValues) {

            if ((IsStringEmpty(htBusinessEventValues["prbe_CourtDistrict"])) ||
                (IsStringEmpty(htBusinessEventValues["prbe_CaseNumber"])) ||
                (IsStringEmpty(htBusinessEventValues["prbe_RelatedCompany1Id"])) ||
                (IsStringEmpty(htBusinessEventValues["prbe_Amount"]))) {
                return string.Empty;
            }

            alArgList.Add(htBusinessEventValues["prbe_CourtDistrict"]);
            alArgList.Add(htBusinessEventValues["prbe_CaseNumber"]);
            alArgList.AddRange(GetCompanyInfo(oConn, BUSINESS_EVENT_TRO, Convert.ToInt32(htBusinessEventValues["prbe_RelatedCompany1Id"])));
            alArgList.Add(htBusinessEventValues["prbe_Amount"]);

            return string.Format(BUSINESS_EVENT_TRO_TEXT, alArgList.ToArray());
        }


        /// <summary>
        /// Helper method that returns the appropriate "Under law"
        /// clause based on the company's entity type.
        /// </summary>
        /// <param name="oConn"></param>
        /// <param name="htBusinessEventValues"></param>
        /// <returns></returns>
        protected string GetUnderLawText(IDbConnection oConn, Hashtable htBusinessEventValues) {

            if ((IsStringEmpty(htBusinessEventValues["prbe_DetailedType"])) ||
                (IsStringEmpty(htBusinessEventValues["prbe_StateId"]))) {
                return string.Empty;
            }

            string szEntityType = Convert.ToString(htBusinessEventValues["prbe_DetailedType"]);

            if ((szEntityType == "1") ||
                (szEntityType == "2") ||
                (szEntityType == "3") ||
                (szEntityType == "4")) {

                string szState = GetState(oConn, Convert.ToInt32(htBusinessEventValues["prbe_StateId"]));
                string[] aArgList = { szState };
                return string.Format(BUSINESS_EVENT_UNDER_LAW, aArgList);
            }

            return string.Empty;
        }

        /// <summary>
        /// Helper method that returns the name for the specified
        /// person.
        /// </summary>
        /// <param name="oConn"></param>
        /// <param name="iPersonID"></param>
        /// <returns></returns>
        protected string GetPersonName(IDbConnection oConn, int iPersonID) {
            DBParameter oParm = new DBParameter("@Parm01", iPersonID);
            object[] oParmList = { oParm };

            IDataReader oReader = ExecuteReader(oConn, SQL_SELECT_PERSON, oParmList);
            try {
                oReader.Read();
                return FormatName(oReader[0].ToString(), oReader[1].ToString(), oReader[2].ToString(), oReader[3].ToString(), oReader[4].ToString());
            } finally {
                if (oReader != null) {
                    oReader.Close();
                }
            }
        }

        #endregion

        #region General Data Formatted Methods
        /// <summary>
        /// Returns a single formatted string
        /// for the City and State.
        /// </summary>
        /// <param name="szCity"></param>
        /// <param name="szState"></param>
        /// <returns></returns>
        static public string FormatCityState(string szCity, string szState) {
            StringBuilder sbResult = new StringBuilder();

            if ((szCity != null) &&
                (!szCity.Equals(DBNull.Value))) {
                sbResult.Append(szCity);
                sbResult.Append(", ");
            }

            sbResult.Append(szState);
            return sbResult.ToString();
        }

        /// <summary>
        /// Returns a single string formatted
        /// for the City, State, and Postal Code
        /// </summary>
        /// <param name="szCity"></param>
        /// <param name="szState"></param>
        /// <param name="szPostal"></param>
        /// <returns></returns>
        static public string FormatCityStatePostal(string szCity, string szState, string szPostal) {
            StringBuilder sbResult = new StringBuilder(FormatCityState(szCity, szState));

            if (sbResult.Length > 0) {
                sbResult.Append(" ");
            }

            sbResult.Append(szPostal);
            return sbResult.ToString();
        }


        /// <summary>
        /// Returns a single string formatted
        /// for the City, State, and Country.  If the
        /// country is US or Canada, it will omitted.
        /// </summary>
        /// <param name="szCity"></param>
        /// <param name="szState"></param>
        /// <param name="szCountry"></param>
        /// <returns></returns>
        static public string FormatCityStateCountry(string szCity, string szState, string szCountry) {
            StringBuilder sbResult = new StringBuilder(FormatCityState(szCity, szState));

            if ((szCountry != null) &&
                (!szCountry.Equals(DBNull.Value))) {

                if (sbResult.Length > 0) {
                    sbResult.Append(" ");
                }

                sbResult.Append(szCountry);
            }

            return sbResult.ToString();
        }

        /// <summary>
        /// Returns a formatted Award string
        /// </summary>
        /// <param name="iIsAwardMember"></param>
        /// <param name="dtAwardDate"></param>
        /// <returns></returns>
        static public string FormatAward(int iIsAwardMember, DateTime dtAwardDate) {
            if (iIsAwardMember == 0) {
                return string.Empty;
            }

            StringBuilder sbResult = new StringBuilder();
            switch (iIsAwardMember) {
                case 1:
                    sbResult.Append("Trading");
                    break;
                case 2:
                    sbResult.Append("Transporation");
                    break;

            }

            sbResult.Append(" Member since ");
            sbResult.Append(dtAwardDate.ToString("yyyy"));
            return sbResult.ToString();
        }

        /// <summary>
        /// Returns a single formatted string
        /// for the First, Middle, and Last Names
        /// </summary>
        /// <param name="szFirstName"></param>
        /// <param name="szNickname"></param>
        /// <param name="szMiddleName"></param>
        /// <param name="szLastName"></param>
        /// <param name="szSuffix"></param>
        /// <returns></returns>
        static public string FormatName(string szFirstName,
                                        string szNickname,
                                        string szMiddleName,
                                        string szLastName,
                                        string szSuffix) {
            StringBuilder sbResult = new StringBuilder();

            if (!IsStringEmpty(szFirstName)) {
                sbResult.Append(szFirstName.Trim());
            }

            if (!IsStringEmpty(szNickname)) {
                sbResult.Append(" (");
                sbResult.Append(szNickname.Trim());
                sbResult.Append(")");
            }

            if (!IsStringEmpty(szMiddleName)) {
                sbResult.Append(" ");
                sbResult.Append(szMiddleName.Trim());
            }

            if (!IsStringEmpty(szLastName)) {
                sbResult.Append(" ");
                sbResult.Append(szLastName.Trim());
            }

            if (!IsStringEmpty(szSuffix)) {
                if (!szSuffix.StartsWith(",")) {
                    sbResult.Append(" ");
                }

                sbResult.Append(szSuffix.Trim());
            }

            return sbResult.ToString();
        }

        /// <summary>
        /// Formats the phone number for both domestic
        /// and international formats.
        /// </summary>
        /// <param name="szCountryCode"></param>
        /// <param name="szAreaCode"></param>
        /// <param name="szPhone"></param>
        /// <param name="szExtension"></param>
        /// <returns></returns>
        static public string FormatPhone(string szCountryCode, string szAreaCode, string szPhone, string szExtension) {
            StringBuilder sbResult = new StringBuilder();

            if ((!IsStringEmpty(szCountryCode)) &&
                (szCountryCode.Trim() != "1")) {
                sbResult.Append(szCountryCode.Trim());
                sbResult.Append(" ");
            }

            if (!IsStringEmpty(szAreaCode)) {
                sbResult.Append(szAreaCode.Trim());
                sbResult.Append("-");
            }

            sbResult.Append(szPhone);

            if (!IsStringEmpty(szExtension)) {
                sbResult.Append(" ext ");
                sbResult.Append(szExtension.Trim());
            }

            return sbResult.ToString();
        }

        /// <summary>
        /// Helper method to determine if a string is
        /// null or zero (0) length.
        /// </summary>
        /// <param name="szValue"></param>
        /// <returns></returns>
        static public bool IsStringEmpty(string szValue) {
            return ((szValue == null) || DBNull.Value.Equals(szValue) || (szValue.Length == 0));
        }

        static public bool IsStringEmpty(object oValue) {
            return IsStringEmpty(Convert.ToString(oValue));
        }
        #endregion

        /// <summary>
        /// It seems we cannot put OR filters on tables so we translate
        /// the root classification IDs to an even higher indicator.
        /// </summary>
        /// <param name="szRootClassifications"></param>
        /// <returns></returns>
        public static string GetClassificationIndicator(string szRootClassifications) {
            if (IsStringEmpty(szRootClassifications)) {
                return "ERROR: Empty Root Classification Found.";
            }

            if ((szRootClassifications.IndexOf("1") > -1) ||
                (szRootClassifications.IndexOf("2") > -1) ||
                (szRootClassifications.IndexOf("3") > -1)) {
                return "P";
            }

            if ((szRootClassifications.IndexOf("4") > -1) ||
                (szRootClassifications.IndexOf("6") > -1)) {
                return "S";
            }

            if (szRootClassifications.IndexOf("5") > -1) {
                return "T";
            }

            return "ERROR: Invalid Root Classification Found (" + szRootClassifications + ").";
        }

        /// <summary>
        /// Used in the finanical information matrix, used to format data from
        /// the pivot.  
        /// </summary>
        /// <param name="szDataType">C = Currency, R = Ratio, S = String</param>
        /// <param name="oValue"></param>
        /// <returns></returns>
        public static string GetFinancialFormattedValue(string szDataType, object oValue) {

            if (oValue == null) {
                return "0";
            }

            switch (szDataType) {
                case "C": // Currency
                    return Convert.ToDecimal(oValue).ToString("###,###,##0");
                case "R": // Ration
                    return Convert.ToDecimal(oValue).ToString("###,##0.00");
                default:
                    return Convert.ToString(oValue);
            }
        }

        /// <summary>
        /// Returns the formatted bank string
        /// </summary>
        /// <param name="szName"></param>
        /// <param name="szPhone"></param>
        /// <param name="szURL"></param>
        /// <returns></returns>
        public static string GetBankInfo(string szName, string szPhone, string szURL) {
            StringBuilder sbBank = new StringBuilder(szName);

            if (!IsStringEmpty(szPhone)) {
                sbBank.Append(", ");
                sbBank.Append(szPhone);
            }

            if (!IsStringEmpty(szURL)) {
                sbBank.Append(", ");
                sbBank.Append(szURL);
            }

            return sbBank.ToString();
        }

        /// <summary>
        /// Formats the start-end years for the person background
        /// section of the report.
        /// </summary>
        /// <param name="szStart"></param>
        /// <param name="szEnd"></param>
        /// <param name="szPeliStatus"></param>
        /// <returns></returns>
        public static string GetPersonBackgroundDate(string szStart, string szEnd, string szPeliStatus) {
            if ((DataFormatter.IsStringEmpty(szStart)) &&
                (DataFormatter.IsStringEmpty(szEnd))) {
                return "Not Avail.";
            }

            StringBuilder sbResult = new StringBuilder();

            if (DataFormatter.IsStringEmpty(szStart)) {
                sbResult.Append("Not Avail.");
            } else {
                sbResult.Append(szStart);
            }

            sbResult.Append(" - ");

            if (DataFormatter.IsStringEmpty(szEnd)) {
                if (szPeliStatus == "3") {
                    sbResult.Append("Not Avail.");
                } else {
                    sbResult.Append("Current");
                }
            } else {
                sbResult.Append(szEnd);
            }

            return sbResult.ToString();
        }


        #region Data Access Methods
        /// <summary>
        /// Opens a data reader using the specified connection, SQL, and
        /// SQL parameters.
        /// </summary>
        /// <param name="oConn"></param>
        /// <param name="szSQL"></param>
        /// <param name="oParameters"></param>
        /// <returns></returns>
        protected IDataReader ExecuteReader(IDbConnection oConn, string szSQL, IList oParameters) {

            IDbCommand oCommand = oConn.CreateCommand();
            oCommand.CommandText = szSQL;
            oCommand.CommandType = CommandType.Text;

            if (oParameters != null) {
                foreach (DBParameter oParm in oParameters) {
                    IDataParameter oDataParm = CreateParameter(oParm.Name, oParm.Value);
                    oCommand.Parameters.Add(oDataParm);
                }
            }

            return oCommand.ExecuteReader();
        }

        /// <summary>
        /// Executes a scalar command using the specified connection, SQL, and
        /// SQL parameters.
        /// </summary>
        /// <param name="oConn"></param>
        /// <param name="szSQL"></param>
        /// <param name="oParameters"></param>
        /// <returns></returns>
        protected object ExecuteScalar(IDbConnection oConn, string szSQL, IList oParameters) {

            IDbCommand oCommand = oConn.CreateCommand();
            oCommand.CommandText = szSQL;
            oCommand.CommandType = CommandType.Text;

            if (oParameters != null) {
                foreach (DBParameter oParm in oParameters) {
                    IDataParameter oDataParm = CreateParameter(oParm.Name, oParm.Value);
                    oCommand.Parameters.Add(oDataParm);
                }
            }

            try {
                return oCommand.ExecuteScalar();
            } finally {
                oConn.Close();
            }
        }

        /// <summary>
        /// Creates a parameter object from the specified name
        /// and value.
        /// </summary>
        /// <param name="szName">Parm Name</param>
        /// <param name="oValue">Parm Value</param>
        /// <returns>Parameter Object</returns>
        protected IDataParameter CreateParameter(string szName,
            object oValue) {

            System.Data.SqlClient.SqlParameter oParm = new System.Data.SqlClient.SqlParameter();
            oParm.ParameterName = szName;

            if (oValue == null) {
                oParm.Value = DBNull.Value;
            } else {

                oParm.Value = oValue;

                if (oParm.Value is string) {
                    oParm.SqlDbType = SqlDbType.NVarChar;
                } else if (oParm.Value is DateTime) {

                    if (((DateTime)oParm.Value).Equals(DateTime.MinValue)) {
                        oParm.Value = DBNull.Value;
                    }

                    oParm.SqlDbType = SqlDbType.DateTime;
                } else if (oParm.Value is Int32) {
                    oParm.SqlDbType = SqlDbType.Int;
                } else if (oParm.Value is Int64) {
                    oParm.SqlDbType = SqlDbType.BigInt;
                } else if (oParm.Value is float) {
                    oParm.SqlDbType = SqlDbType.Float;
                } else if (oParm.Value is Decimal) {
                    oParm.SqlDbType = SqlDbType.Decimal;
                } else if (oParm.Value is Boolean) {
                    oParm.SqlDbType = SqlDbType.Bit;
                } else {
                    throw new DataException("Unsupported Data Type: " + oParm.Value.ToString());
                }
            }
            return oParm;
        }
        #endregion

        #region Person Event Methods

        /// <summary>
        /// Returns the formatted Person Event Verbiage based
        /// on the event type.  Will query for the appropriate PRPersonEvent
        /// fields along with any extra tables it may need to construct
        /// the verbiage.
        /// </summary>
        /// <param name="iPRPersonEventID">Person Event ID</param>
        /// <returns></returns>
        public string GetPersonEventText(int iPRPersonEventID) {


            System.Data.SqlClient.SqlClientPermission permission = new System.Data.SqlClient.SqlClientPermission(System.Security.Permissions.PermissionState.Unrestricted);
            permission.Assert();   // Assert security permission! 

            string szConnectionString = null;
            try {
                szConnectionString = GetConnectionString(szConnectionString);
            } catch (Exception e) {
                return "ERROR Getting Connection String: " + e.Message;
            }

            IDbConnection oConn = new System.Data.SqlClient.SqlConnection(szConnectionString);
            try {

                oConn.Open();

                Hashtable htPersonEventValues = new Hashtable();
                string szEventText = string.Empty;

                ArrayList alArgList = new ArrayList();


                IDataReader oReader = null;
                try {

                    DBParameter oParm = new DBParameter("@Parm01", iPRPersonEventID);
                    object[] oParmList = { oParm };

                    oReader = ExecuteReader(oConn, SQL_SELECT_PERSON_EVENT, oParmList);
                    if (!oReader.Read()) {
                        return "ERROR: Specified prpe_PersonEventId (" + iPRPersonEventID.ToString() + ") was not found.";
                    }

                    // Put our values in a hashtable since we can only have
                    // one reader open at a time.  Depending upon the event type
                    // we may have to query for additional data.
                    for (int i = 0; i < oReader.FieldCount; i++) {
                        htPersonEventValues.Add(oReader.GetName(i), oReader[i]);
                    }
                } catch (Exception e) {

                    return "ERROR: Error retrieving PRPersonEvent record: " + e.Message;
                } finally {
                    if (oReader != null) {
                        oReader.Close();
                    }
                }

                alArgList.Add(Convert.ToDateTime(htPersonEventValues["prpe_Date"]));

                int iEventType = Convert.ToInt32(htPersonEventValues["prpe_PersonEventTypeId"]);
                switch (iEventType) {
                    case PERSON_EVENT_EDUCATION:
                        return HandlePersonEducationEvent(oConn, alArgList, htPersonEventValues);

                    case PERSON_EVENT_BANKRUPTCY_FILED:
                        return HandlePersonBankruptcyFiledEvent(oConn, alArgList, htPersonEventValues);

                    case PERSON_EVENT_BANKRUPTCY_DISMISSED:
                        return HandlePersonBankruptcyDimsisedEvent(oConn, alArgList, htPersonEventValues);

                    case PERSON_EVENT_DRC_VIOLATION:
                    case PERSON_EVENT_PACA_VIOLATIONS:
                    case PERSON_EVENT_OTHER_LEGAL:
                    case PERSON_EVENT_OTHER:
                        return Convert.ToString(htPersonEventValues["prpe_PublishedAnalysis"]);
                }

                return "ERROR: Invalid person event type found (" + iEventType.ToString() + ").";

            } catch (Exception e) {
                return "ERROR: Exception in GetPersonEventText. " + e.Message;
            } finally {
                oConn.Close();
            }
        }

        /// <summary>
        /// Helper method that formats the text for the
        /// Education person event.
        /// </summary>
        /// <param name="oConn">DBAccess instance</param>
        /// <param name="alArgList">Argument List</param>
        /// <param name="htPersonEventValues">Person Event Data Attributes</param>
        /// <returns></returns>
        protected string HandlePersonEducationEvent(IDbConnection oConn, ArrayList alArgList, Hashtable htPersonEventValues) {

            if ((IsStringEmpty(htPersonEventValues["prpe_EducationalDegree"])) ||
                (IsStringEmpty(htPersonEventValues["prpe_EducationalInstitution"]))) {
                return string.Empty;
            }

            alArgList.Add(GetPersonName(oConn, Convert.ToInt32(htPersonEventValues["prpe_PersonId"])));
            alArgList.Add(htPersonEventValues["prpe_EducationalDegree"]);
            alArgList.Add(htPersonEventValues["prpe_EducationalInstitution"]);
            return string.Format(PERSON_EVENT_EDUCATION_TEXT, alArgList.ToArray());
        }

        /// <summary>
        /// Helper method that formats the text for the
        /// Bankruptcy Filed person event.
        /// </summary>
        /// <param name="oConn">DBAccess instance</param>
        /// <param name="alArgList">Argument List</param>
        /// <param name="htPersonEventValues">Person Event Data Attributes</param>
        /// <returns></returns>
        protected string HandlePersonBankruptcyFiledEvent(IDbConnection oConn, ArrayList alArgList, Hashtable htPersonEventValues) {

            if ((IsStringEmpty(htPersonEventValues["prpe_USBankruptcyVoluntary"])) ||
                (IsStringEmpty(htPersonEventValues["prpe_BankruptcyType"])) ||
                (IsStringEmpty(htPersonEventValues["prpe_USBankruptcyCourt"])) ||
                (IsStringEmpty(htPersonEventValues["prpe_CaseNumber"]))) {
                return string.Empty;
            }

            alArgList.Add(GetPersonName(oConn, Convert.ToInt32(htPersonEventValues["prpe_PersonId"])));

            if ("Y" == Convert.ToString(htPersonEventValues["prpe_USBankruptcyVoluntary"])) {
                alArgList.Add("volunatry");
            } else {
                alArgList.Add("involuntary");
            }

            alArgList.Add(GetPersonTypeValue(oConn, htPersonEventValues, "prpe_BankruptcyType"));
            alArgList.Add(htPersonEventValues["prpe_USBankruptcyCourt"]);
            alArgList.Add(htPersonEventValues["prpe_CaseNumber"]);
            return string.Format(PERSON_EVENT_BANKRUPTCY_FILED_TEXT, alArgList.ToArray());
        }


        /// <summary>
        /// Helper method that formats the text for the
        /// Bankruptcy Diumissed person event.
        /// </summary>
        /// <param name="oConn">DBAccess instance</param>
        /// <param name="alArgList">Argument List</param>
        /// <param name="htPersonEventValues">Person Event Data Attributes</param>
        /// <returns></returns>
        protected string HandlePersonBankruptcyDimsisedEvent(IDbConnection oConn, ArrayList alArgList, Hashtable htPersonEventValues) {

            if ((IsStringEmpty(htPersonEventValues["prpe_BankruptcyType"])) ||
                (IsStringEmpty(htPersonEventValues["prpe_DischargeType"]))) {
                return string.Empty;
            }

            alArgList.Add(GetPersonTypeValue(oConn, htPersonEventValues, "prpe_BankruptcyType"));
            alArgList.Add(GetPersonName(oConn, Convert.ToInt32(htPersonEventValues["prpe_PersonId"])));
            alArgList.Add(GetPersonTypeValue(oConn, htPersonEventValues, "prpe_DischargeType"));
            return string.Format(PERSON_EVENT_BANKRUPTCY_DISMISSED_TEXT, alArgList.ToArray());
        }


        /// <summary>
        /// Helper method that returns the specified text
        /// handling the "Other" scenario.
        /// </summary>
        /// <param name="oConn"></param>
        /// <param name="htPersonEventValues"></param>
        /// <param name="szTypeName"></param>
        /// <returns></returns>
        protected string GetPersonTypeValue(IDbConnection oConn, Hashtable htPersonEventValues, string szTypeName) {
            string szType = Convert.ToString(htPersonEventValues[szTypeName]);
            return GetCustomCaption(oConn, szTypeName, szType);
        }

        #endregion


        /// <summary>
        /// Helper method to retreive the DB connection information
        /// from the registry.
        /// </summary>
        /// <param name="szConnectionString"></param>
        /// <returns></returns>
        public string GetConnectionString(string szConnectionString) {
            if (!IsStringEmpty(szConnectionString)) {
                return szConnectionString;
            }

            string szUserID = null;
            string szPassword = null;
            string szServer = null;
            string szDatabase = null;

            RegistryPermission regPermission = new RegistryPermission(RegistryPermissionAccess.Read, @"HKEY_LOCAL_MACHINE\SOFTWARE\eware\Config;HKEY_LOCAL_MACHINE\SOFTWARE\eware\Config\/CRM");
            regPermission.Assert();

            RegistryKey regCRM = Registry.LocalMachine;
            regCRM = regCRM.OpenSubKey(@"SOFTWARE\eware\Config");

            szUserID = (string)regCRM.GetValue("BBSDatabaseUserID");
            szPassword = (string)regCRM.GetValue("BBSDatabasePassword");
            regCRM.Close();

            RegistryKey regCRM2 = Registry.LocalMachine;
            regCRM2 = regCRM2.OpenSubKey(@"SOFTWARE\eware\Config\/CRM");

            szDatabase = (string)regCRM2.GetValue("DefaultDatabase");
            szServer = (string)regCRM2.GetValue("DefaultDatabaseServer");
            regCRM2.Close();

            string[] aArgs = { szServer, szUserID, szPassword, szDatabase };
            return string.Format(CONN_STRING, aArgs);

        }
    }
	#region Helper Classes
	/// <summary>
	/// Container for Name / Parameter pairs.
	/// </summary>
	public class DBParameter {
		public  string	Name;
		public object	Value;

		public DBParameter(string szName, object oValue) {
			Name = szName;
			Value = oValue;
		}
	}		
	#endregion
}
