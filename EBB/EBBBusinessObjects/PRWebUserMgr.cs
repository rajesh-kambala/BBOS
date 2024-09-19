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

 ClassName: PRWebUser
 Description:	

 Notes:	Created By TSI Class Generator on 6/26/2007 9:40:32 AM

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using TSI.Arch;
using TSI.BusinessObjects;
using TSI.Security;
using TSI.Utils;
using System.IO;
namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Data Manager for the PRWebUser class.
    /// </summary>
    [Serializable]
    public class PRWebUserMgr : EBBObjectMgr
    {
        /// <summary>
        /// SQL executed by ObjectNameExists
        /// </summary>
        protected const string SQL_USER_EXISTS = COL_PRWU_EMAIL + "={0} AND " + COL_PRWU_WEB_USER_ID + "<>{1}";
        protected const string SQL_PASSWORD_CHANGE_GUID_USER_EXISTS = COL_PRWU_PASSWORD_CHANGE_GUID + "={0}";

        public const string UNABLE_TO_RETRIEVE_USER = "Unable to retrieve user.  Duplicate email addressess found:";

        /// <summary>
        /// Only a limited number of columns are retreived since this object is stored in the
        /// session. 
        /// </summary>
        protected const string SQL_SELECT_FROM =
                @"SELECT ISNULL(RTRIM(pers_FirstName), prwu_FirstName) As FirstName, ISNULL(RTRIM(pers_LastName), prwu_LastName) As LastName, 
                       Case When comp_PRSessionTrackerIDCheckDisabled = 'Y' Or prwu_SessionTrackerIDCheckDisabled = 'Y' Then 'Y' Else 'N' End As SessionTrackerIDCheckDisabled, 
                       peli_PRSubmitTES, peli_PRUpdateCL, peli_PersonID, peli_PRUseServiceUnits, peli_PRUseSpecialServices,prwu_WebUserID, 
                       prwu_CreatedBy,prwu_CreatedDate,prwu_UpdatedBy,prwu_UpdatedDate,prwu_TimeStamp, 
                       prwu_Email,prwu_Password,prwu_BBID,prwu_HQID,ISNULL(comp_Name, prwu_CompanyName) As prwu_CompanyName, 
                       prwu_PersonLinkID,prwu_Culture,prwu_UICulture,prwu_LastLoginDateTime,prwu_LoginCount,prwu_FailedAttemptCount, 
                       prwu_LastPasswordChange,prwu_TrialExpirationDate,prwu_AccessLevel,prwu_ServiceCode, prwu_AcceptedTerms,prwu_IsNewUser, 
                       prwu_LastCompanySearchID,prwu_LastPersonSearchID,prwu_LastCreditSheetSearchID,prwu_DefaultCompanySearchPage, 
                       prwu_CompanyData,prwu_CountryID, prwu_StateID, prwu_HowLearned, prwu_CDSWBBID, prwu_BBIDLoginCount, 
                       prwu_CompanyUpdateDaysOld, ISNULL(comp_PRIndustryType, prwu_IndustryTypeCode) As prwu_IndustryTypeCode, 
                       prwu_DefaultCommoditySearchLayout, prwu_MembershipInterest, prwu_Address1, prwu_Address2, 
                       prwu_City, prwu_County, prwu_CompanySize, prwu_FaxAreaCode, prwu_FaxNumber, prwu_Gender, 
                       prwu_PhoneAreaCode, prwu_PhoneNumber, prwu_PostalCode, prwu_TitleCode, prwu_WebSite, prwu_IndustryClassification, 
                       prwu_DontDisplayZeroResultsFeedback, prwu_MessageLoginCount, prwu_PreviousAccessLevel, 
                       prwu_LinkedInToken, prwu_LinkedInTokenSecret, prwu_MemberMessageLoginCount, prwu_NonMemberMessageLoginCount,
                       prci2_Suspended, prci2_SuspensionPending, prwu_EmailPurchases, prwu_CompressEmailedPurchases, prwu_LastBBOSPopupID, prwu_LastBBOSPopupViewDate,
                       prwu_LastClaimsActivitySearchID, prwu_CompanyUpdateMessageType, prwu_Timezone, peli_PREditListing,
                       prwu_MobileGUID, prwu_MobileGUIDExpiration, prwu_Disabled, prwu_LocalSourceSearch, prc5_PRARReportAccess, prwu_ARReportsThrehold,
                       prwu_SecurityDisabled,
                       CASE WHEN comp_PRIsIntlTradeAssociation IS NOT NULL THEN 'Y' ELSE 'N' END AS IsIntlTradeAssociation,
                       prwu_PasswordChangeGuid,
                       prwu_PasswordChangeGuidExpirationDate,
                       prwu_CompanyLinksNewTab,
                       prwu_HideBRPurchaseConfirmationMsg   
                  FROM PRWebUser WITH (NOLOCK) 
                       LEFT OUTER JOIN person_link WITH (NOLOCK) ON prwu_PersonLinkID = peli_PersonLinkID 
                       LEFT OUTER JOIN person WITH (NOLOCK) ON peli_PersonID = pers_PersonID 
                       LEFT OUTER JOIN Company WITH (NOLOCK) ON prwu_BBID = comp_CompanyID
                       LEFT OUTER JOIN PRCompanyIndicators WITH (NOLOCK) ON comp_PRHQID = prci2_CompanyID 
                       LEFT OUTER JOIN PRCompanyInfoProfile WITH(NOLOCK) ON prc5_CompanyID = comp_CompanyID ";

        protected const string SQL_GET_BY_BBID_PASSWORD = SQL_SELECT_FROM + "WHERE prwu_BBID = {0} AND prwu_Password = dbo.ufnclr_EncryptText({1}) AND prwu_Disabled IS NULL";
        //protected const string SQL_GET_BY_EMAIL = SQL_SELECT_FROM + "WHERE prwu_Email = {0} AND prwu_Disabled IS NULL";
        protected const string SQL_GET_BY_EMAIL = SQL_SELECT_FROM + "WHERE prwu_Email = {0}";
        protected const string SQL_GET_BY_MOBILE_GUID = SQL_SELECT_FROM + "WHERE prwu_MobileGUID = {0} AND prwu_Disabled IS NULL";
        protected const string SQL_GET_BY_PASSWORD_CHANGE_GUID = SQL_SELECT_FROM + "WHERE prwu_PasswordChangeGuid = {0} AND prwu_Disabled IS NULL";
        protected const string SQL_GET_BY_KEY = SQL_SELECT_FROM + "WHERE prwu_WebUserID = {0} AND prwu_Disabled IS NULL";
        protected const string SQL_GET_BY_KEY_ALL = SQL_SELECT_FROM + "WHERE prwu_WebUserID = {0}";
        
        public const string COL_PRWU_ACCEPTED_TERMS					= "prwu_AcceptedTerms";
        public const string COL_PRWU_IS_NEW_USER					= "prwu_IsNewUser";
        public const string COL_PRWU_MAIL_LIST_OPT_IN				= "prwu_MailListOptIn";
        public const string COL_PRWU_MEMBERSHIP_INTEREST			= "prwu_MembershipInterest";
        public const string COL_PRWU_LAST_LOGIN_DATE_TIME			= "prwu_LastLoginDateTime";
        public const string COL_PRWU_LAST_PASSWORD_CHANGE			= "prwu_LastPasswordChange";
        public const string COL_PRWU_TRIAL_EXPIRATION_DATE			= "prwu_TrialExpirationDate";
        public const string COL_PRWU_BBID							= "prwu_BBID";
        public const string COL_PRWU_COUNTRY_ID						= "prwu_CountryID";
        public const string COL_PRWU_FAILED_ATTEMPT_COUNT			= "prwu_FailedAttemptCount";
        public const string COL_PRWU_HQID                           = "prwu_HQID";
        public const string COL_PRWU_LAST_COMPANY_SEARCH_ID			= "prwu_LastCompanySearchID";
        public const string COL_PRWU_LAST_CREDIT_SHEET_SEARCH_ID	= "prwu_LastCreditSheetSearchID";
        public const string COL_PRWU_LAST_PERSON_SEARCH_ID			= "prwu_LastPersonSearchID";
        public const string COL_PRWU_LOGIN_COUNT					= "prwu_LoginCount";
        public const string COL_PRWU_PERSON_LINK_ID					= "prwu_PersonLinkID";
        public const string COL_PRWU_PRSERVICE_ID					= "prwu_ServiceID";
        public const string COL_PRWU_STATE_ID						= "prwu_StateID";
        public const string COL_PRWU_WEB_USER_ID					= "prwu_WebUserID";
        public const string COL_PRWU_ACCESS_LEVEL					= "prwu_AccessLevel";
        public const string COL_PRWU_SERVICE_CODE                   = "prwu_ServiceCode";
        public const string COL_PRWU_ADDRESS1						= "prwu_Address1";
        public const string COL_PRWU_ADDRESS2						= "prwu_Address2";
        public const string COL_PRWU_CITY							= "prwu_City";
        public const string COL_PRWU_COUNTY                         = "prwu_County";
        public const string COL_PRWU_COMPANY_DATA					= "prwu_CompanyData";
        public const string COL_PRWU_COMPANY_NAME					= "prwu_CompanyName";
        public const string COL_PRWU_COMPANY_SIZE					= "prwu_CompanySize";
        public const string COL_PRWU_CULTURE						= "prwu_Culture";
        public const string COL_PRWU_DEFAULT_COMPANY_SEARCH_PAGE	= "prwu_DefaultCompanySearchPage";
        public const string COL_PRWU_EMAIL							= "prwu_Email";
        public const string COL_PRWU_PASSWORD_CHANGE_GUID           = "prwu_PasswordChangeGuid";
        public const string COL_PRWU_PASSWORD_CHANGE_GUID_ExpirationDate = "prwu_PasswordChangeGuidExpirationDate";
        public const string COL_PRWU_FAX_AREA_CODE					= "prwu_FaxAreaCode";
        public const string COL_PRWU_FAX_NUMBER						= "prwu_FaxNumber";
        public const string COL_PRWU_FIRST_NAME						= "prwu_FirstName";
        public const string COL_PRWU_GENDER							= "prwu_Gender";
        public const string COL_PRWU_HOW_LEARNED					= "prwu_HowLearned";
        public const string COL_PRWU_INDUSTRY_CLASSIFICATION		= "prwu_IndustryClassification";
        public const string COL_PRWU_LAST_NAME						= "prwu_LastName";
        public const string COL_PRWU_PASSWORD						= "prwu_Password";
        public const string COL_PRWU_PHONE_AREA_CODE				= "prwu_PhoneAreaCode";
        public const string COL_PRWU_PHONE_NUMBER					= "prwu_PhoneNumber";
        public const string COL_PRWU_POSTAL_CODE					= "prwu_PostalCode";
        public const string COL_PRWU_TITLE_CODE						= "prwu_TitleCode";
        public const string COL_PRWU_UICULTURE						= "prwu_UICulture";
        public const string COL_PRWU_WEB_SITE						= "prwu_WebSite";
        public const string COL_PRWU_CDSWBBID                       = "prwu_CDSWBBID";
        public const string COL_PRWU_BBIDLOGINCOUNT                 = "prwu_BBIDLoginCount";
        public const string COL_PRWU_DONTDISPLAYZERORESULTSFEEDBACK = "prwu_DontDisplayZeroResultsFeedback";
        public const string COL_PRWU_COMPANY_UDPATES_MESSAGE_TYPE   = "prwu_CompanyUpdateMessageType";
        public const string COL_PRWU_MOBILE_GUID                    = "prwu_MobileGUID";
        public const string COL_PRWU_MOBILE_GUID_EXPIRATION         = "prwu_MobileGUIDExpiration";
        public const string COL_PRWU_LOCAL_SOURCE_SEARCH            = "prwu_LocalSourceSearch";

        public const string COL_PRWU_SECURITY_DISABLED              = "prwu_SecurityDisabled";
        public const string COL_PRWU_SECURITY_DISABLED_DATE         = "prwu_SecurityDisabledDate";
        public const string COL_PRWU_SECURITY_DISABLED_REASON       = "prwu_SecurityDisabledReason";


        public const string COL_PRWU_DEFAULT_COMMODITY_SEARCH_LAYOUT = "prwu_DefaultCommoditySearchLayout";

        public const string COL_PRWU_ACCEPTED_MEMBER_AGREEMENT = "prwu_AcceptedMemberAgreement";
        public const string COL_PRWU_ACCEPTED_MEMBER_AGREEMENT_DATE = "prwu_AcceptedMemberAgreementDate";
        public const string COL_PRWU_ACCEPTED_TERMS_DATE = "prwu_AcceptedTermsDate";

        public const string COL_PELI_PERSONID                       = "peli_PersonID";
        public const string COL_PELI_PRSUBMITTES                    = "peli_PRSubmitTES";
        public const string COL_PELI_PRUPDATECL                     = "peli_PRUpdateCL";
        public const string COL_PELI_USESERVICEUNITS                = "peli_PRUseServiceUnits";
        public const string COL_PELI_USESPECIALSERVICES             = "peli_PRUseSpecialServices";
        public const string COL_PELI_PREDITLISTING                  = "peli_PREditListing";
        public const string COL_COMP_PRAR_REPORT_ACCESS = "prc5_PRARReportAccess";

        public const string COL_PRWU_FIRSTNAME = "prwu_FirstName";
        public const string COL_PRWU_LASTNAME = "prwu_LastName";

        public const string COL_PRWU_COMPANYUPDATE_DAYS_OLD = "prwu_CompanyUpdateDaysOld";
        public const string COL_SESSIONTRACKER_ID_CHECKDISABLED = "SessionTrackerIDCheckDisabled";
        public const string COL_PRWU_INDUSTRY_TYPE = "prwu_IndustryTypeCode";

        public const string COL_PRWU_MESSAGE_LOGIN_COUNT = "prwu_MessageLoginCount";
        public const string COL_PRWU_MEMBER_MESSAGE_LOGIN_COUNT = "prwu_MemberMessageLoginCount";
        public const string COL_PRWU_NONMEMBER_MESSAGE_LOGIN_COUNT = "prwu_NonMemberMessageLoginCount";
        public const string COL_PRWU_PREVIOUS_ACCESS_LEVEL = "prwu_PreviousAccessLevel";

        public const string COL_PRWU_LINKED_IN_TOKEN = "prwu_LinkedInToken";
        public const string COL_PRWU_LINKED_IN_TOKEN_SECRET = "prwu_LinkedInTokenSecret";

        public const string COL_PRCI2_SUSPENDED = "prci2_Suspended";
        public const string COL_PRCI2_SUSPENDSION_PENDING = "prci2_SuspensionPending";

        public const string COL_PRWU_EMAIL_PURCHASES = "prwu_EmailPurchases";
        public const string COL_PRWU_COMPRESS_EMAILED_PURCHASES = "prwu_CompressEmailedPurchases";
        public const string COL_PRWU_COMPANY_LINKS_NEW_TAB = "prwu_CompanyLinksNewTab";

        public const string COL_PRWU_LAST_BBOS_POPUP_ID = "prwu_LastBBOSPopupID";
        public const string COL_PRWU_LAST_BBOS_POPUP_VIEW_DATE = "prwu_LastBBOSPopupViewDate";


        public const string COL_PRWU_LAST_CLAIMS_ACTIVITY_SEARCH_ID = "prwu_LastClaimsActivitySearchID";

        public const string COL_PRWU_TIMEZONE = "prwu_Timezone";
        public const string COL_PRWU_DISABLED = "prwu_Disabled";
        public const string COL_PRWU_AR_REPORTS_THRESHOLD = "prwu_ARReportsThrehold";

        public const string COL_PRCTA_IS_INTL_TRADE_ASSOCIATION = "IsIntlTradeAssociation";
        public const string COL_PRWU_HIDE_BR_PURCHASE_CONFIRMATION_MSG = "prwu_HideBRPurchaseConfirmationMsg";

        /// <summary>
        /// Override the standard TSI audit column names with the
        /// Sage CRM names.
        /// </summary>
        new public const string COL_CREATED_USER_ID = "prwu_CreatedBy";
        new public const string COL_UPDATED_USER_ID = "prwu_UpdatedBy";
        new public const string COL_CREATED_DATETIME = "prwu_CreatedDate";
        new public const string COL_UPDATED_DATETIME = "prwu_UpdatedDate";
        public const string COL_TIMESTAMP = "prwu_Timestamp";



        #region TSI Framework Generated Code
        /// <summary>
        /// Constructor to initalize data manager
        /// </summary>
        /// <returns></returns>
        public PRWebUserMgr(){}

        /// <summary>
        /// Constructor to initalize data manager
        /// </summary>
        /// <param name="oLogger">Logger</param>
        /// <param name="oUser">Current User</param>
        public PRWebUserMgr(ILogger oLogger,
                                IUser oUser): base(oLogger, oUser){}

        /// <summary>
        /// Constructor to initalize data manager
        /// </summary>
        /// <param name="oConn">DB Connection</param>
        /// <param name="oLogger">Logger</param>
        /// <param name="oUser">Current User</param>
        public PRWebUserMgr(IDbConnection oConn,
                                ILogger oLogger,
                                IUser oUser): base(oConn, oLogger, oUser){}

        /// <summary>
        /// Constructor using the Logger, User, and Transaction
        /// of the specified Manager to initialize this manager.
        /// </summary>
        /// <param name="oBizObjMgr">Business Object Manager</param>
        public PRWebUserMgr(BusinessObjectMgr oBizObjMgr): base(oBizObjMgr){}

        /// <summary>
        /// Creates an instance of the PRWebUser business object
        /// </summary>
        /// <returns>IBusinessObject</returns>
        override protected IBusinessObject InstantiateBusinessObject(IDictionary oData) {
            return new PRWebUser();
        }

        /// <summary>
        /// The name of the table our business object
        /// is mapped to.
        /// </summary>
        /// <returns>Table Name</returns>
        override public string GetTableName() {
            return "PRWebUser";
        }

        /// <summary>
        /// The name of the business object class.
        /// </summary>
        /// <returns>Business Object Name</returns>
        override public string GetBusinessObjectName() {
            return "PRCo.EBB.BusinessObjects.PRWebUser";
        }

        /// <summary>
        /// The fields that uniquly identify this object.
        /// </summary>
        /// <returns>IList</returns>
        override public IList GetKeyFields() {
            return new String[] {COL_PRWU_WEB_USER_ID};
        }
        #endregion

        /// <summary>
        /// Returns the PAISUser for the specified
        /// email address.
        /// </summary>
        /// <param name="szEmail">Email Address</param>
        /// <returns>PAISUser</returns>
        public IPRWebUser GetByEmail(string szEmail) {

            return GetByEmail(szEmail, true);
        }


        public IPRWebUser GetByEmail(string szEmail, bool excludeDisabled)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("Parm01", szEmail));

            string szSQL = FormatSQL(SQL_GET_BY_EMAIL, oParameters);
            if (excludeDisabled)
                szSQL += " AND prwu_Disabled IS NULL";

            try
            {
                return (IPRWebUser)GetObjectByCustomSQL(szSQL, oParameters);
            } catch (ApplicationUnexpectedException auEx) {
                if (auEx.Message.StartsWith("Too many objects found"))
                    throw new ApplicationUnexpectedException(UNABLE_TO_RETRIEVE_USER + " " + szEmail, auEx);

                throw;
            }
        }

        /// <summary>
        /// Returns the PAISUser for the specified
        /// mobileGuid.
        /// </summary>
        /// <param name="mobileGuid">mobileGuid Address</param>
        /// <returns>PAISUser</returns>
        public IPRWebUser GetByMobileGuid(string mobileGuid)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("Parm01", mobileGuid));

            string szSQL = FormatSQL(SQL_GET_BY_MOBILE_GUID, oParameters);
            return (IPRWebUser)GetObjectByCustomSQL(szSQL, oParameters);
        }

        /// <summary>
        /// Returns the User for the specified passwordChangeGuid
        /// </summary>
        /// <param name="passwordChangeGuid">passwordChangeGuid</param>
        /// <returns>IPRWebUser</returns>
        public IPRWebUser GetByPasswordChangeGuid(string passwordChangeGuid)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("Parm01", passwordChangeGuid));

            string szSQL = FormatSQL(SQL_GET_BY_PASSWORD_CHANGE_GUID, oParameters);
            return (IPRWebUser) GetObjectByCustomSQL(szSQL, oParameters);
        }

        public IPRWebUser GetByBBID(int iBBID, string szPassword) {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("Parm01", iBBID));
            oParameters.Add(new ObjectParameter("Parm02", szPassword));

            string szSQL = FormatSQL(SQL_GET_BY_BBID_PASSWORD, oParameters);
            return (IPRWebUser)GetObjectByCustomSQL(szSQL, oParameters);
        }        

        /// <summary>
        /// Determines if a User with the specified email
        /// already exists, excluding the specified user.
        /// </summary>
        /// <param name="szEmail">Email Address</param>
        /// <param name="iUserID">User to exclude</param>
        /// <returns></returns>
        public bool UserExists(string szEmail, int iUserID) {
            return UserExists(szEmail, 0, true);
        }

        public bool UserExists(string szEmail, int iUserID, bool excludeDisabled)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("Parm01", szEmail));
            oParameters.Add(new ObjectParameter("Parm02", iUserID));

            string szSQL = FormatSQL(SQL_USER_EXISTS, oParameters);
            if (excludeDisabled)
            {
                szSQL += " AND prwu_Disabled IS NULL";
            }

            return IsObjectExist(szSQL, oParameters);
        }

        public bool PasswordChangeGuidExists(string szPasswordChangeGuid)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("Parm01", szPasswordChangeGuid));

            string szSQL = FormatSQL(SQL_PASSWORD_CHANGE_GUID_USER_EXISTS, oParameters);

            return IsObjectExist(szSQL, oParameters);
        }

        public override IBusinessObject GetObjectByKey(string szKeyValue) {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("Parm01", szKeyValue));

            string szSQL = FormatSQL(SQL_GET_BY_KEY, oParameters);
            return GetObjectByCustomSQL(szSQL, oParameters);
        }


        public IBusinessObject GetUser(string szKeyValue)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("Parm01", szKeyValue));

            string szSQL = FormatSQL(SQL_GET_BY_KEY_ALL, oParameters);
            return GetObjectByCustomSQL(szSQL, oParameters);
        }

        public void EmailPassword(IPRWebUser oWebUser)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("WebUserID", oWebUser.prwu_WebUserID));

            GetDBAccess().ExecuteNonQuery("usp_SendBBOSPassword", oParameters, null, CommandType.StoredProcedure);
        }

        public void ProcessDuplicateUser(string email)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("Email", email));
            oParameters.Add(new ObjectParameter("Commit", 1));

            GetDBAccess().ExecuteNonQuery("usp_ProcessDuplicateUser", oParameters, null, CommandType.StoredProcedure);
        }

        public string GeneratePassword()
        {

            SqlConnection sqlconn = (SqlConnection)GetDBAccess().Open();

            using (SqlCommand cmd = new SqlCommand("usp_GeneratePassword", sqlconn))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.Add(new SqlParameter("@Password", SqlDbType.VarChar));
                cmd.Parameters["@Password"].Direction = ParameterDirection.Output;
                cmd.Parameters["@Password"].Size = 100;

                //sqlconn.Open();
                cmd.ExecuteNonQuery();  // *** since you don't need the returned data - just call ExecuteNonQuery
                string password = (string)cmd.Parameters["@Password"].Value;
                //sqlconn.Close();

                return password;
            }
        }

        protected const string SQL_GET_PENDING_NOTE_REMINDERS = SQL_SELECT_FROM +
                @"WHERE prwu_Disabled IS NULL AND prwu_WebUserID IN (
                        SELECT DISTINCT prwunr_WebUserID
                          FROM PRWebUserNote WITH (NOLOCK)
                               INNER JOIN PRWebUserNoteReminder WITH (NOLOCK) ON prwunr_WebUserNoteID = prwun_WebUserNoteID
                         WHERE prwunr_SentDateTime IS NULL
                                AND prwunr_DateUTC <= GETUTCDATE()                  
                                AND prwunr_Type = {0}) ";

        public IBusinessObjectSet GetUsersWithPendingNoteReminders(string notificationType)
        {
            IList parmList = GetParmList("prwunr_Type", notificationType);
            return GetObjectsByCustomSQL(FormatSQL(SQL_GET_PENDING_NOTE_REMINDERS, parmList), parmList);
        }

        protected const string SQL_GET_LOCAL_SOURCE_ACCESS =
            @"SELECT prwuls_ServiceCode FROM PRWebUserLocalSource WHERE prwuls_WebUserID=@prwuls_WebUserID";

        public string GetLocalSourceDataAccess(int webUserID)
        {
            StringBuilder results = new StringBuilder();

            IList parmList = GetParmList("prwuls_WebUserID", webUserID);
            using (IDataReader reader = GetDBAccessFullRights().ExecuteReader(SQL_GET_LOCAL_SOURCE_ACCESS, parmList, CommandBehavior.CloseConnection, null))
            {
                while (reader.Read())
                {
                    if (results.Length > 0)
                    {
                        results.Append(",");
                    }
                    results.Append("'" + reader.GetString(0) + "'");
                }
            }

            // We need to release this reference
            // in order to allow the PRWebUser object
            // to be serialized.
            _oDBAccessFullRights = null;

            return results.ToString();
        }


        protected const string SQL_GET_LOCAL_SOURCE_ACCESS_REGION =
            @"SELECT prlsr_StateID FROM PRLocalSourceRegion WHERE prlsr_ServiceCode IN ({0});";

        public HashSet<Int32> GetLocalSourceDataAccessRegion(int webUserID, string serviceCodes)
        {
            HashSet<Int32> results = new HashSet<Int32>();

            using (IDataReader reader = GetDBAccessFullRights().ExecuteReader(string.Format(SQL_GET_LOCAL_SOURCE_ACCESS_REGION, serviceCodes), CommandBehavior.CloseConnection))
            {
                while (reader.Read())
                {
                    results.Add(reader.GetInt32(0));
                }
            }

            // We need to release this reference
            // in order to allow the PRWebUser object
            // to be serialized.
            _oDBAccessFullRights = null;

            return results;
        }

        private const string SQL_DATA_EXPORT_COUNT =
            @"SELECT COUNT(DISTINCT prrc_AssociatedID) as [Company Count]
	            FROM PRRequest WITH (NOLOCK)
		            INNER JOIN PRRequestDetail WITH (NOLOCK) ON prreq_RequestID = prrc_RequestID
            WHERE prreq_WebUserID = @WebUserID
              AND prreq_CreatedDate BETWEEN @FromDate AND @ToDate
              AND prreq_RequestTypeCode IN ('CAE', 'CEC', 'CEH', 'CEA', 'CDE', 'CCE', 'CE', 'PE', 'CSE','BBSR')";

        public int GetDataExportCount(int webUserID, int minutesOld)
        {
            IList parmList = GetParmList("WebUserID", webUserID);
            parmList.Add(new ObjectParameter("FromDate", DateTime.Now.AddMinutes(0-minutesOld)));
            parmList.Add(new ObjectParameter("ToDate", DateTime.Now));

            object result = GetDBAccess().ExecuteScalar(SQL_DATA_EXPORT_COUNT, parmList);
            if ((result == DBNull.Value) ||
                (result == null))
            {
                return 0;
            }

            return Convert.ToInt32(result);
        }

        private const string SQL_DATA_EXPORT_COUNT_LUMBER_CURRENT_MONTH =
            @"SELECT COUNT(DISTINCT prrc_AssociatedID) as [Company Count]
	            FROM PRRequest WITH (NOLOCK)
		            INNER JOIN PRRequestDetail WITH (NOLOCK) ON prreq_RequestID = prrc_RequestID
            WHERE prreq_WebUserID = @WebUserID
                AND MONTH(prrc_CreatedDate) = MONTH(GetDate())
                AND YEAR(prrc_CreatedDate) = YEAR(GetDate())
              AND prreq_RequestTypeCode IN ('CCE','CEL','CE','CDEL','CDE','BBSi_IE')";

        public int GetDataExportCount_Lumber_Current_Month(int webUserID)
        {
            IList parmList = GetParmList("WebUserID", webUserID);

            object result = GetDBAccess().ExecuteScalar(SQL_DATA_EXPORT_COUNT_LUMBER_CURRENT_MONTH, parmList);
            if ((result == DBNull.Value) ||
                (result == null))
            {
                return 0;
            }

            return Convert.ToInt32(result);
        }

        private const string SQL_DATA_EXPORT_COUNT_COMPANY_LUMBER_CURRENT_MONTH =
            @"SELECT COUNT(DISTINCT prrc_AssociatedID) as [Company Count]
	            FROM PRRequest WITH (NOLOCK)
		            INNER JOIN PRRequestDetail WITH (NOLOCK) ON prreq_RequestID = prrc_RequestID
            WHERE prreq_CompanyID = @BBID
                AND MONTH(prrc_CreatedDate) = MONTH(GetDate())
                AND YEAR(prrc_CreatedDate) = YEAR(GetDate())
              AND prreq_RequestTypeCode IN ('CCE','CEL','CE','CDEL','CDE','BBSi_IE')";

        public int GetDataExportCount_Company_Lumber_Current_Month(int BBID)
        {
            IList parmList = GetParmList("BBID", BBID);

            object result = GetDBAccess().ExecuteScalar(SQL_DATA_EXPORT_COUNT_COMPANY_LUMBER_CURRENT_MONTH, parmList);
            if ((result == DBNull.Value) ||
                (result == null))
            {
                return 0;
            }

            return Convert.ToInt32(result);
        }

        private const string SQL_DATA_EXPORT_COUNT_COMPANY_LUMBER_CURRENT_DAY =
            @"SELECT COUNT(DISTINCT prrc_AssociatedID) as [Company Count]
	            FROM PRRequest WITH (NOLOCK)
		            INNER JOIN PRRequestDetail WITH (NOLOCK) ON prreq_RequestID = prrc_RequestID
            WHERE prreq_CompanyID = @BBID
                AND DAY(prrc_CreatedDate) = DAY(GetDate())
                AND MONTH(prrc_CreatedDate) = MONTH(GetDate())
                AND YEAR(prrc_CreatedDate) = YEAR(GetDate())
              AND prreq_RequestTypeCode IN ('CCE','CEL','CE','CDEL','CDE','BBSi_IE')";

        public int GetDataExportCount_Company_Lumber_Current_Day(int BBID)
        {
            IList parmList = GetParmList("BBID", BBID);

            object result = GetDBAccess().ExecuteScalar(SQL_DATA_EXPORT_COUNT_COMPANY_LUMBER_CURRENT_DAY, parmList);
            if ((result == DBNull.Value) ||
                (result == null))
            {
                return 0;
            }

            return Convert.ToInt32(result);
        }

        private const string SQL_NOTES_SHARE_COMPANY_COUNT =
            @"SELECT COUNT(DISTINCT(prwun_AssociatedID)) FROM PRWebUserNote WHERE prwun_WebUserID = @WebUserID";

        public int GetNotesShareCompanyCount(int webUserID)
        {
            IList parmList = GetParmList("WebUserID", webUserID);

            object result = GetDBAccess().ExecuteScalar(SQL_NOTES_SHARE_COMPANY_COUNT, parmList);
            if ((result == DBNull.Value) ||
                (result == null))
            {
                return 0;
            }

            return Convert.ToInt32(result);
        }

        private const string SQL_WATCHDOG_CUSTOM_COUNT =
            @"SELECT COUNT(*) FROM PRWebUserList WHERE prwucl_WebUserID = @WebUserID AND prwucl_TypeCode='CU'";

        public int GetWatchdogCustomCount(int webUserID)
        {
            IList parmList = GetParmList("WebUserID", webUserID);

            object result = GetDBAccess().ExecuteScalar(SQL_WATCHDOG_CUSTOM_COUNT, parmList);
            if ((result == DBNull.Value) ||
                (result == null))
            {
                return 0;
            }

            return Convert.ToInt32(result);
        }

        //E or S for CommunicationLanguage
        //L for lumber
        protected const string SQL_SELECT_RATING_KEY_NUMERALS_PUBLICATION_ARTICLE_ID =
            @"  SELECT
	                CASE WHEN '{0}'='L' THEN p2.prpbar_PublicationArticleID ELSE p1.prpbar_PublicationArticleID END
                FROM PRWebUser
                INNER JOIN PRPublicationArticle p1 WITH (NOLOCK) ON prpbar_FileName LIKE '%MG Rating Key Numerals%' 
	                AND prpbar_CommunicationLanguage = CASE WHEN '{1}'='en-us' THEN 'E' ELSE 'S' END
                INNER JOIN PRPublicationArticle p2 WITH (NOLOCK) ON p2.prpbar_FileName LIKE '%Lumber Rating Key Numerals%'";

        public int GetRatingKeyNumeralsPublicationArticleID(string szIndustryType, string szCulture)
        {
            string szSQL = string.Format(SQL_SELECT_RATING_KEY_NUMERALS_PUBLICATION_ARTICLE_ID, szIndustryType, szCulture);
            object result = GetDBAccess().ExecuteScalar(szSQL);

            if ((result == DBNull.Value) ||
                (result == null))
            {
                return 0;
            }

            return Convert.ToInt32(result);
        }

        public int GetAvailableReports(int prwu_HQID)
        {
            return (int)GetDBAccess().ExecuteScalar(string.Format("SELECT dbo.ufn_GetAvailableUnits({0})", prwu_HQID));
        }

        public int GetAllocatedUnits(int prwu_HQID)
        {
            return (int)GetDBAccess().ExecuteScalar(string.Format("SELECT dbo.ufn_GetAllocatedUnits({0})", prwu_HQID));
        }

        public string GetPrimaryMembership(int prwu_BBID)
        {
            return (string)GetDBAccess().ExecuteScalar(string.Format("SELECT dbo.ufn_GetPrimaryService({0})", prwu_BBID));
        }

        protected const string SQL_GET_RECENT_PURCHASES =
            @"SELECT DISTINCT prrc_AssociatedID 
				FROM PRRequest WITH (NOLOCK)
					 INNER JOIN PRRequestDetail WITH (NOLOCK) ON prreq_RequestID = prrc_RequestID 
			   WHERE prreq_RequestTypeCode = {0} 
				 AND prreq_HQID = {1} 
				 AND prreq_CreatedDate >= {2} ";

        protected const string SQL_GET_WEB_USERS_LIST = @"SELECT prwu_Email,prwu_Password FROM PRWebUser";
        /// <summary>
        /// Return a list of the objects recently purchased by the user's HQ
        /// for the specified request type within the threshold.  The threshold
        /// is a config value.
        /// </summary>
        public List<Int32> GetRecentPurchases(string szRequestTypeCode, int prwu_HQID)
        {
            List<Int32> lIDs = new List<Int32>();
            DateTime dtThreshold = DateTime.Now.AddHours(0 - Utilities.GetIntConfigValue("RecentPurchasesAvailabilityThreshold", 72));

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prreq_RequestTypeCode", szRequestTypeCode));
            oParameters.Add(new ObjectParameter("prreq_HQID", prwu_HQID));
            oParameters.Add(new ObjectParameter("prreq_CreatedDate", dtThreshold));

            string szSQL = FormatSQL(SQL_GET_RECENT_PURCHASES, oParameters);

            using (IDataReader oReader = GetDBAccessFullRights().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null))
            {
                while (oReader.Read())
                {
                    lIDs.Add(oReader.GetInt32(0));
                }
            }

            // We need to release this reference
            // in order to allow the PRWebUser object
            // to be serialized.
            _oDBAccessFullRights = null;

            return lIDs;
        }

        protected const string SQL_GET_BY_CROSS_INDUSTRY = SQL_SELECT_FROM + " INNER JOIN PRCompanyRelationship ON prcr_LeftCompanyId = prwu_BBID OR prcr_RightCompanyId = prwu_BBID " +
                    " WHERE prwu_Email = {0} AND prwu_Disabled IS NULL AND prcr_Type = '36' AND prcr_Active = 'Y' ORDER BY prwu_LastLoginDateTime DESC";

        public IBusinessObjectSet GetUsersByCrossIndustry(string szEmail)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("Parm01", szEmail));

            string szSQL = FormatSQL(SQL_GET_BY_CROSS_INDUSTRY, oParameters);
            return (IBusinessObjectSet)GetObjectsByCustomSQL(szSQL, oParameters);
        }


        private const string SQL_OPEN_INVOICE =
            @"SELECT CustomerNo, UDF_MASTER_INVOICE, MAX(InvoiceDate) InvoiceDate, MAX(InvoiceDueDate) InvioceDueDate, SUM(Balance) AmountDue, prinv_StripePaymentURL,
                     MAX(prinv_SentDateTime) prinv_SentDateTime, prci2_StripeCustomerId
                FROM (
                    SELECT ihh.CustomerNo, UDF_MASTER_INVOICE, ihh.InvoiceDate, ihh.InvoiceDueDate, oi.Balance, 
                           prinv_StripePaymentURL, prinv_SentDateTime, prci2_StripeCustomerId, ROW_NUMBER() OVER (PARTITION BY prinv_InvoiceNbr ORDER BY prinv_SentDateTime DESC) RowNum
		              FROM MAS_PRC.dbo.AR_InvoiceHistoryHeader ihh WITH (NOLOCK) 
			               INNER JOIN MAS_PRC.dbo.AR_OpenInvoice oi WITH (NOLOCK) ON ihh.InvoiceNo = oi.InvoiceNo
					       INNER JOIN MAS_PRC.dbo.SO_SalesOrderHistoryHeader sohh WITH (NOLOCK) ON ihh.SalesOrderNo = sohh.SalesOrderNo
					       INNER JOIN CRM.dbo.PRCompanyIndicators WITH (NOLOCK) ON ihh.CustomerNo = prci2_CompanyID
					       INNER JOIN CRM.dbo.PRInvoice WITH (NOLOCK) ON ihh.CustomerNo = prinv_CompanyID AND UDF_MASTER_INVOICE = prinv_InvoiceNbr
		             WHERE oi.Balance > 0
				       AND sohh.MasterRepeatingOrderNo <> ''
				       AND prci2_DoNotSuspend IS NULL
				       AND oi.CustomerNo = @HQID) T1
               WHERE RowNum = 1
            GROUP BY CustomerNo, UDF_MASTER_INVOICE, prinv_StripePaymentURL, prci2_StripeCustomerId
              HAVING SUM(Balance) > 0
            ORDER BY InvoiceDate";


        public void GetOpenInvoice(int hqID, out string invoiceNumber, out DateTime invoiceDueDate, out string paymentURL, out DateTime invoiceSentDate, out string stripeCustomerID)
        {
            // Set this to an empty string as NULL is
            // the indicator that we need to query for this.
            invoiceNumber = string.Empty;
            invoiceDueDate = DateTime.MinValue;
            paymentURL = string.Empty;
            invoiceSentDate = DateTime.MinValue;
            stripeCustomerID = null;

            try
            {
                IList parameters = GetParmList("HQID", hqID);
                using (IDataReader reader = GetDBAccessFullRights().ExecuteReader(SQL_OPEN_INVOICE, parameters, CommandBehavior.CloseConnection, null))
                {
                    if (reader.Read())
                    {
                        invoiceNumber = reader.GetString(1);
                        invoiceDueDate = reader.GetDateTime(3);

                        if (reader[5] != DBNull.Value)
                            paymentURL = reader.GetString(5);

                        invoiceSentDate = reader.GetDateTime(6);

                        if (reader[7] != DBNull.Value)
                            stripeCustomerID = reader.GetString(7);

                    }
                }
            }
            finally { 
            // We need to release this reference
            // in order to allow the PRWebUser object
            // to be serialized.
            _oDBAccessFullRights = null;
        }
        }
        [Serializable]
        public class WebUserData
        {
            public string EmailId;
            public string DecryptPassword;
            public string EncryptedPassword;
        }
        public List<WebUserData> GetDecryptPasswords()
        {
            List<WebUserData> oWebUserData = new List<WebUserData>();
            using (IDataReader reader = GetDBAccess().ExecuteReader(SQL_GET_WEB_USERS_LIST))
            {
                while (reader.Read()) // Changed to while to read all records
                {
                    oWebUserData.Add(
                        new WebUserData
                        {
                            EmailId = GetDBAccess().GetString(reader, "prwu_Email"),
                            EncryptedPassword = GetDBAccess().GetString(reader, "prwu_Password"),
                            DecryptPassword = DecryptedAuthenticate(GetDBAccess().GetString(reader, "prwu_Password"))
                        });
                }
            }
            string filePath = "C:\\Users\\Gapi Krishna\\Users.csv"; // Specify the path where you want to save the file
            WriteToCsv(oWebUserData, filePath);
            return oWebUserData;
        }

        virtual protected string DecryptedAuthenticate(string szPassword)
        {
            IEncryptionProvider oEncryption = EncryptionFactory.GetEncryptionProvider();
            return oEncryption.Decrypt(szPassword);
        }

        private static void WriteToCsv(List<WebUserData> users, string filePath)
        {
            StringBuilder csvData = new StringBuilder();
            csvData.AppendLine("EmailId,DecryptPassword,EncryptedPassword"); // CSV Header

            foreach (var user in users)
            {
                csvData.AppendLine($"{EscapeCsv(user.EmailId)},{EscapeCsv(user.DecryptPassword)},{EscapeCsv(user.EncryptedPassword)}");
            }

            File.WriteAllText(filePath, csvData.ToString(), Encoding.UTF8);
        }

        private static string EscapeCsv(string value)
        {
            if (value.Contains(",") || value.Contains("\""))
            {
                value = "\"" + value.Replace("\"", "\"\"") + "\""; // Escape quotes
            }
            return value;
        }
    }
}
