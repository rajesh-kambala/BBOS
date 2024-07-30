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
using System.Collections.Generic;
using TSI.Security;

namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Interface definition for the PRWebUser class.
    /// </summary>
    public interface IPRWebUser : IUser {
        #region TSI Framework Generated Code
        /// <summary>
        /// Accessor for the prwu_AcceptedTerms property.
        /// </summary>
        bool prwu_AcceptedTerms {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwu_IsNewUser property.
        /// </summary>
        bool prwu_IsNewUser {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwu_MailListOptIn property.
        /// </summary>
        bool prwu_MailListOptIn {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwu_MembershipInterest property.
        /// </summary>
        bool prwu_MembershipInterest {
            get;
            set;
        }

        bool prwu_Disabled
        {
            get;
            set;
        }


        /// <summary>
        /// Accessor for the prwu_LastPasswordChange property.
        /// </summary>
        DateTime prwu_LastPasswordChange {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwu_PasswordChangeGuid property.
        /// </summary>
        string prwu_PasswordChangeGuid
        {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwu_PasswordChangeGuidExpirationDate property.
        /// </summary>
        DateTime prwu_PasswordChangeGuidExpirationDate
        {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwu_TrialExpirationDate property.
        /// </summary>
        DateTime prwu_TrialExpirationDate {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwu_BBID property.
        /// </summary>
        int prwu_BBID {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwu_CountryID property.
        /// </summary>
        int prwu_CountryID {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwu_FailedAttemptCount property.
        /// </summary>
        int prwu_FailedAttemptCount {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwu_HQID property.
        /// </summary>
        int prwu_HQID {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwu_LastCompanySearchID property.
        /// </summary>
        int prwu_LastCompanySearchID {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwu_LastCreditSheetSearchID property.
        /// </summary>
        int prwu_LastCreditSheetSearchID {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwu_LastClaimsActivitySearchID property.
        /// </summary>
        int prwu_LastClaimsActivitySearchID
        {
            get;
            set;
        }
        
        int prwu_PreviousAccessLevel
        {
            get;
        }

        /// <summary>
        /// Accessor for the prwu_LastPersonSearchID property.
        /// </summary>
        int prwu_LastPersonSearchID {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwu_PersonLinkID property.
        /// </summary>
        int prwu_PersonLinkID {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwu_PRServiceID property.
        /// </summary>
        int prwu_PRServiceID {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwu_StateID property.
        /// </summary>
        int prwu_StateID {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwu_AccessLevel property.
        /// </summary>
        int prwu_AccessLevel {
            get;
            set;
        }


        /// <summary>
        /// Accessor for the prwu_WebUserID property.
        /// </summary>
        int prwu_WebUserID {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwu_CDSWBBID property.
        /// </summary>
        int prwu_CDSWBBID {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwu_Address1 property.
        /// </summary>
        string prwu_Address1 {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwu_Address2 property.
        /// </summary>
        string prwu_Address2 {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwu_City property.
        /// </summary>
        string prwu_City {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwu_County property.
        /// </summary>
        string prwu_County {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwu_CompanyData property.
        /// </summary>
        string prwu_CompanyData {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwu_CompanyName property.
        /// </summary>
        string prwu_CompanyName {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwu_CompanySize property.
        /// </summary>
        string prwu_CompanySize {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwu_Culture property.
        /// </summary>
        string prwu_Culture {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwu_DefaultCompanySearchPage property.
        /// </summary>
        string prwu_DefaultCompanySearchPage {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwu_FaxAreaCode property.
        /// </summary>
        string prwu_FaxAreaCode {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwu_FaxNumber property.
        /// </summary>
        string prwu_FaxNumber {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwu_Gender property.
        /// </summary>
        string prwu_Gender {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwu_HowLearned property.
        /// </summary>
        string prwu_HowLearned {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwu_IndustryClassification property.
        /// </summary>
        string prwu_IndustryClassification {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwu_PhoneAreaCode property.
        /// </summary>
        string prwu_PhoneAreaCode {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwu_PhoneNumber property.
        /// </summary>
        string prwu_PhoneNumber {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwu_PostalCode property.
        /// </summary>
        string prwu_PostalCode {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwu_TitleCode property.
        /// </summary>
        string prwu_TitleCode {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwu_UICulture property.
        /// </summary>
        string prwu_UICulture {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwu_WebSite property.
        /// </summary>
        string prwu_WebSite {
            get;
            set;
        }

        string prwu_CompanyUpdateMessageType
        {
            get;
            set;
        }

        string prwu_Timezone
        {
            get;
            set;
        }

        string prwu_LocalSourceSearch
        {
            get;
            set;
        }
        string prwu_ARReportsThrehold
        {
            get;
            set;
        }

        #endregion

        ///<summary>
        /// Accessor for the Session Tracker Disabled flag
        ///</summary>
        bool SessionTrackerIDCheckDisabled
        {
            get;
        }

        bool prwu_DontDisplayZeroResultsFeedback
        {
            get;
            set;
        }

        bool prci2_Suspended
        {
            get;
        }

        bool prci2_SuspensionPending
        {
            get;
        }
        /// <summary>
        /// Generate an email to the this user with
        /// the decrypted password.
        /// </summary>
        /// <param name="szMessage">Message of the email.  Expecto {0} to be replaced with the password.</param>
        /// <param name="szSubject">Subject of the Email</param>
        void EmailPassword(string szSubject, string szMessage);
        void EmailPassword();
        void EmailPasswordChangeLink(string szPasswordChangeEmailSubject, string szPasswordChangeEmailBody);

        int peli_PersonID {
            get;
        }

        string prwu_IndustryType
        {
            get;
            set;
        }

        int prwu_BBIDLoginCount {
            get;
            set;
        }
        
        bool HasAccess(int iAccessLevel);
        SecurityMgr.SecurityResult HasPrivilege(SecurityMgr.Privilege privilge);

        bool prwu_AcceptedMemberAgreement {
            get;
            set;
        }

        bool prcta_IsIntlTradeAssociation
        {
            get;
            set;
        }

        bool HideBRPurchaseConfirmationMsg
        {
            get;
            set;
        }

        bool IsLimitado
        {
            get;
            set;
        }

        void ClearLimitado();

        string prwu_ServiceCode
        {
            get;
            set;
        }

        DateTime prwu_AcceptedMemberAgreementDate {
            get;
            set;
        }

        DateTime prwu_AcceptedTermsDate {
            get;
            set;
        }

        int? prwu_CompanyUpdateDaysOld
        {
            get;
            set;
        }

        string prwu_DefaultCommoditySearchLayout
        {
            get;
            set;
        }

        bool IsTrialUser();
        bool IsTrialPeriodActive();

        bool IsLumber_BASIC();
        bool IsLumber_BASIC_PLUS();
        bool IsLumber_STANDARD();
        bool IsLumber_ADVANCED();

        int MessageLoginCount
        {
            get;
            set;
        }

        int MemberMessageLoginCount
        {
            get;
            set;
        }

        int NonMemberMessageLoginCount
        {
            get;
            set;
        }

        string prwu_LinkedInToken
        {
            get;
            set;
        }

        string prwu_LinkedInTokenSecret
        {
            get;
            set;
        }

        bool prwu_EmailPurchases
        {
            get;
            set;
        }

        bool prwu_CompressEmailedPurchases
        {
            get;
            set;
        }

        bool prwu_CompanyLinksNewTab
        {
            get;
            set;
        }

        int prwu_LastBBOSPopupID
        {
            get;
            set;
        }

        DateTime prwu_LastBBOSPopupViewDate
        {
            get;
            set;
        }

        string prwu_MobileGUID
        {
            get;
            set;
        }

        DateTime prwu_MobileGUIDExpiration
        {
            get;
            set;
        }

        void UpdateLoginStats();
        void GeneratePassword();

        DateTime ConvertToLocalDateTime(DateTime value);
        DateTime ConvertToLocalDateTime(string sourceTimeZone, DateTime value);

        bool HasLocalSourceDataAccess();
        string GetLocalSourceDataAccessServiceCodes();
        string GetLocalSourceDataAccessRegionIDs();
        HashSet<Int32> GetLocalSourceDataAccessRegions();

        bool prwu_SecurityDisabled
        {
            get;
            set;
        }

        string prwu_SecurityDisabledReason
        {
            get;
            set;
        }

        DateTime prwu_SecurityDisabledDate
        {
            get;
            set;
        }

        int SecuredPageCount
        {
            get;
        }
        string OpenInvoiceNbr
        {
            get;
            set;
        }

        string OpenInvoicePaymentURL
        {
            get;
            set;
        }

        DateTime OpenInvoiceDueDate
        {
            get;
            set;
        }

        void LogPage(string request, string associatedID);
        void CheckPageAccessCount();
        void CheckPageAccessForSerialiedData();
        bool CheckDataExportCount();
        bool CheckDataExportCount(int exportCount);

        int GetDataExportCount();
        int GetRemainingDataExportCount();

        bool IsRecentPurchase(int iObjectID, string szRequestType);
        List<Int32> GetRecentPurchases(string szRequestType);
        void RefreshRecentPurchases();

        int GetAvailableReports();
        int GetAllocatedUnits();
        int GetDataExportCount_Lumber_Current_Month();
        int GetDataExportCount_Company_Lumber_Current_Month();
        int GetDataExportCount_Company_Lumber_Current_Day();
        int GetNotesShareCompanyCount();
        int GetWatchdogCustomCount();

        string GetOpenInvoiceMessageCode();
    }
}
