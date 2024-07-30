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
using System.Linq;
using PRCo.EBB.Util;
using TSI.Utils;
using TSI.Security;
using TSI.BusinessObjects;
using Stripe;
using System.Data.SqlClient;
using System.Data;
using PRCo.BBS;
using System.Configuration;


namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Provides the functionality for the PRWebUser.
    /// </summary>
    [Serializable]
    public class PRWebUser : EBBObject, IPRWebUser
    {
        protected bool _bIsAuthenticated;

        protected bool		_bprwu_AcceptedTerms;
        protected bool		_bprwu_IsNewUser;
        protected bool		_bprwu_MailListOptIn;
        protected bool		_bprwu_MembershipInterest;
        protected bool		_bprwu_Disabled;
        protected bool      _prcta_IsIntlTradeAssociation;
        protected bool      _bprwuHideBRPurchaseConfirmationMsg;
        protected DateTime	_dtprwu_LastLoginDateTime;
        protected DateTime	_dtprwu_LastPasswordChange;
        protected DateTime	_dtprwu_TrialExpirationDate;
        protected DateTime  _dtprwu_Timestamp;
        protected int		_iprwu_BBID;
        protected int		_iprwu_CountryID;
        protected int		_iprwu_FailedAttemptCount;
        protected int       _iprwu_HQID;
        protected int		_iprwu_LastCompanySearchID;
        protected int		_iprwu_LastCreditSheetSearchID;
        protected int		_iprwu_LastPersonSearchID;
        protected int       _iprwu_LastClaimsActivitySearchID;
        protected int		_iprwu_LoginCount;
        protected int		_iprwu_PersonLinkID;
        protected int		_iprwu_PRServiceID;
        protected int		_iprwu_StateID;
        protected int		_iprwu_WebUserID;
        protected int	    _iprwu_AccessLevel;
        protected int       _iprwu_CDSWBBID;
        protected int       _iprwu_BBIDLoginCount;
        protected int       _iprwu_MessageLoginCount;
        protected int       _iprwu_MemberMessageLoginCount;
        protected int       _iprwu_NonMemberMessageLoginCount;
        protected int?      _iprwu_CompanyUpdateDaysOld;
        protected int       _iprwu_PreviousAccessLevel;


        protected string    _szprwu_ServiceCode;
        protected string	_szprwu_Address1;
        protected string	_szprwu_Address2;
        protected string	_szprwu_City;
        protected string    _szprwu_County;
        protected string	_szprwu_CompanyData;
        protected string	_szprwu_CompanyName;
        protected string	_szprwu_CompanySize;
        protected string	_szprwu_Culture;
        protected string	_szprwu_DefaultCompanySearchPage;
        protected string	_szprwu_Email;
        protected string	_szprwu_FaxAreaCode;
        protected string	_szprwu_FaxNumber;
        protected string	_szprwu_FirstName;
        protected string	_szprwu_Gender;
        protected string	_szprwu_HowLearned;
        protected string	_szprwu_IndustryClassification;
        protected string	_szprwu_LastName;
        protected string	_szprwu_Password;
        protected string	_szprwu_PhoneAreaCode;
        protected string	_szprwu_PhoneNumber;
        protected string	_szprwu_PostalCode;
        protected string	_szprwu_TitleCode;
        protected string	_szprwu_UICulture;
        protected string	_szprwu_WebSite;
        protected string    _szClearTextPassword;
        protected string    _szIndustryType;
        protected string    _szprwu_CompanyUpdateMessageType;
        protected string    _szprwu_Timezone;
        protected string    _szprwu_MobileGUID;
        protected DateTime  _dtprwu_MobileGUIDExpiration;
        protected string _szprwu_LocalSourceSearch = "ILS"; //Defect 4426 - Include Local Source is default
        protected string _szprwu_ARReportsThrehold;

        protected string _szprwu_PasswordChangeGuid;
        protected DateTime _dtprwu_PasswordChangeGuidExpirationDate;

        protected int         _iprwu_LastBBOSPopupID;
        protected DateTime    _dtprwu_LastBBOSPopupViewDate;
        
        protected string    _szprwu_DefaultCommoditySearchLayout = "H";

        protected string _szprwu_LinkedInToken;
        protected string _szprwu_LinkedInTokenSecret;

        protected bool _bprwu_AcceptedMemberAgreement;
        protected bool _bprwu_DontDisplayZeroResultsFeedback;
        protected DateTime _dtprwu_AcceptedMemberAgreementDate;
        protected DateTime _dtprwu_AcceptedTermsDate;

        protected int       _ipeli_PersonID;
        protected bool		_bpeli_PRSubmitTES;
        protected bool		_bpeli_PRUpdateCL;
        protected bool		_bpeli_PRUseServiceUnits;
        protected bool		_bpeli_PRUseSpecialServices;
        protected bool      _bpeli_PREditListing;
        protected bool      _bprci2_Suspended;
        protected bool      _bprci2_SuspensionPending;
        protected bool      _bprwu_EmailPurchases;
        protected bool      _bprwu_CompressEmailedPurchases;
        protected bool      _bprwu_CompanyLinksNewTab;
        protected bool      _bprc5_PRARReportAccess;

        protected bool      _prwu_SecurityDisabled;
        protected DateTime  _prwu_SecurityDisabledDate;
        protected string    _prwu_SecurityDisabledReason;

        protected bool      _bSessionTrackerIDCheckDisabled;

        protected bool?     _bIsLimitado = null;
        

        protected List<Int32> _lRecentPurchases = null;

        public const string ROLE_SUBMIT_TES = "SubmitTES";
        public const string ROLE_UPDATE_CL = "UpdateConnectionList";
        public const string ROLE_USE_SERVICE_UNITS = "UseServiceUnits";
        public const string ROLE_USE_SPECIAL_SERVICES = "UseSpecialServices";
        public const string ROLE_EDIT_LISTING = "EditListing";
        public const string ROLE_LOCAL_SOURCE_DATA_ACCESS = "LocalSourceDataAccess";
        public const string ROLE_AR_RERPORT_ACCESS = "ARReportAccess";

        public const int SECURITY_LEVEL_TRADE_ASSOCIATION_ACCESS = 100;
        public const int SECURITY_LEVEL_LIMITED_ACCESS = 200;
        public const int SECURITY_LEVEL_BASIC_ACCESS = 300; //L100 lumber access level
        public const int SECURITY_LEVEL_BASIC_PLUS = 350; //L150 lumber access level for Madison
        public const int SECURITY_LEVEL_STANDARD = 400; //L200/L201 lumber access level moved to here (was 500 before along with L300)
        public const int SECURITY_LEVEL_ADVANCED = 500; //L300/L301 lumber
        public const int SECURITY_LEVEL_ADVANCED_PLUS = 600;
        public const int SECURITY_LEVEL_PREMIUM = 700;

        public const int SECURITY_LEVEL_PRODUCE_BASIC = 300;
        public const int SECURITY_LEVEL_PRODUCE_STANDARD = 400;
        public const int SECURITY_LEVEL_PRODUCE_PREMIUM = 700;
        public const int SECURITY_LEVEL_ADMIN = 999999;

        public const string OPEN_INVOICE_MESSAGE_CODE_COMINGDUE = "ComingDue";
        public const string OPEN_INVOICE_MESSAGE_CODE_PAYMENTDUE = "PaymentDue";
        public const string OPEN_INVOICE_MESSAGE_CODE_PASTDUE = "PastDue";
        public const string OPEN_INVOICE_MESSAGE_CODE_SUSPEND = "Suspend";

        /// <summary>
        /// Constructor
        /// </summary>
        public PRWebUser() {
            _bUsesSmartUpdate = true;
        }

        #region TSI Framework Generated Code
        /// <summary>
        /// Returns the key values of the current
        /// instance in the same order as the key
        /// fields.
        /// </summary>
        /// <returns>IList</returns>
        override public IList GetKeyValues() {
            if (_oKeyValues == null) {
                _oKeyValues = new ArrayList();
                _oKeyValues.Add(prwu_WebUserID);
            }
	          return _oKeyValues;
        }

        /// <summary>
        /// Sets the key values for this object based
        /// on the specified list of values.  The list of
        /// values must be in the same order the keys are
        /// defined in GetKeyValues();
        /// </summary>
        /// <param name="oKeyValues">IList</param>
        override public void SetKeyValues(IList oKeyValues) {
            prwu_WebUserID = Convert.ToInt32(oKeyValues[0]);
            _oKeyValues = (ArrayList)oKeyValues;
        }

        /// <summary>
        /// Required by base class
        /// </summary>
        public override void ClearKeyValues() { 
        }

        /// <summary>
        /// Accessor for the prwu_AcceptedTerms property.
        /// </summary>
        public bool prwu_AcceptedTerms {
            get {return _bprwu_AcceptedTerms;}
            set {SetDirty(_bprwu_AcceptedTerms, value);
                 _bprwu_AcceptedTerms = value;}
        }

        /// <summary>
        /// Accessor for the prcta_IsIntlTradeAssociation property.
        /// </summary>
        public bool prcta_IsIntlTradeAssociation
        {
            get { return _prcta_IsIntlTradeAssociation; }
            set
            {
                SetDirty(_prcta_IsIntlTradeAssociation, value);
                _prcta_IsIntlTradeAssociation = value;
            }
        }

        /// <summary>
        /// Accessor for the prcta_IsIntlTradeAssociation property.
        /// </summary>
        public bool HideBRPurchaseConfirmationMsg
        {
            get { return _bprwuHideBRPurchaseConfirmationMsg; }
            set
            {
                SetDirty(_bprwuHideBRPurchaseConfirmationMsg, value);
                _bprwuHideBRPurchaseConfirmationMsg = value;
            }
        }

        /// <summary>
        /// Accessor for whether the user has ITA security access
        /// Somewhat deprecated when IsLimitado method was added in 09/2019
        /// </summary>
        public bool IsIntlTradeAssociationUser
        {
            get { return (prwu_AccessLevel == SECURITY_LEVEL_TRADE_ASSOCIATION_ACCESS); }
        }

        /// <summary>
        /// Accessor for whether the user is considered Limitado or not
        /// Initially based on service code ITALIC
        /// </summary>
        public bool IsLimitado
        {
            get {
                if (_bIsLimitado != null)
                    return _bIsLimitado.Value;

                string szLimitadoServiceCodes = Utilities.GetConfigValue("LimitadoServiceCodes", "ITALIC");
                if (string.IsNullOrEmpty(szLimitadoServiceCodes))
                {
                    _bIsLimitado = false;
                    return _bIsLimitado.Value;
                }
                else
                {
                    if (string.IsNullOrEmpty(prwu_ServiceCode))
                    {
                        _bIsLimitado = false;
                        return _bIsLimitado.Value;
                    }

                    foreach (string szServiceCode in szLimitadoServiceCodes.Split(','))
                    {
                        if (prwu_ServiceCode.Trim().ToUpper() == szServiceCode.Trim().ToUpper())
                        {
                            _bIsLimitado = true;
                            return _bIsLimitado.Value;
                        }
                    }

                    _bIsLimitado = false;
                    return _bIsLimitado.Value;
                }
            }
            set
            {
                _bIsLimitado = value;
            }
        }

        public void ClearLimitado()
        {
            _bIsLimitado = null;
        }

        public bool prwu_DontDisplayZeroResultsFeedback
        {
            get { return _bprwu_DontDisplayZeroResultsFeedback; }
            set
            {
                SetDirty(_bprwu_DontDisplayZeroResultsFeedback, value);
                _bprwu_DontDisplayZeroResultsFeedback = value;
            }
        }

        public bool prwu_AcceptedMemberAgreement {
            get { return _bprwu_AcceptedMemberAgreement; }
            set {
                SetDirty(_bprwu_AcceptedMemberAgreement, value);
                _bprwu_AcceptedMemberAgreement = value;
            }
        }

        /// <summary>
        /// Accessor for the prwu_IsNewUser property.
        /// </summary>
        public bool prwu_IsNewUser {
            get {return _bprwu_IsNewUser;}
            set {SetDirty(_bprwu_IsNewUser, value);
                 _bprwu_IsNewUser = value;}
        }

        /// <summary>
        /// Accessor for the prwu_MailListOptIn property.
        /// </summary>
        public bool prwu_MailListOptIn {
            get {return _bprwu_MailListOptIn;}
            set {SetDirty(_bprwu_MailListOptIn, value);
                 _bprwu_MailListOptIn = value;}
        }

        /// <summary>
        /// Accessor for the prwu_MembershipInterest property.
        /// </summary>
        public bool prwu_MembershipInterest {
            get {return _bprwu_MembershipInterest;}
            set {SetDirty(_bprwu_MembershipInterest, value);
                 _bprwu_MembershipInterest = value;}
        }

        /// <summary>
        /// Accessor for the prwu_Disabled property.
        /// </summary>
        public bool prwu_Disabled
        {
            get { return _bprwu_Disabled; }
            set
            {
                SetDirty(_bprwu_Disabled, value);
                _bprwu_Disabled = value;
            }
        }

        public bool prwu_SecurityDisabled
        {
            get { return _prwu_SecurityDisabled; }
            set
            {
                SetDirty(_prwu_SecurityDisabled, value);
                _prwu_SecurityDisabled = value;
            }
        }

        public DateTime prwu_SecurityDisabledDate
        {
            get { return _prwu_SecurityDisabledDate; }
            set
            {
                SetDirty(_prwu_SecurityDisabledDate, value);
                _prwu_SecurityDisabledDate = value;
            }
        }

        public string prwu_SecurityDisabledReason
        {
            get { return _prwu_SecurityDisabledReason; }
            set
            {
                SetDirty(_prwu_SecurityDisabledReason, value);
                _prwu_SecurityDisabledReason = value;
            }
        }

        public bool prci2_Suspended
        {
            get { return _bprci2_Suspended; }
        }


        public bool prci2_SuspensionPending
        {
            get { return _bprci2_SuspensionPending; }
        }

        public bool prwu_EmailPurchases
        {
            get { return _bprwu_EmailPurchases; }
            set
            {
                SetDirty(_bprwu_EmailPurchases, value);
                _bprwu_EmailPurchases = value;
            }
        }

        public bool prwu_CompressEmailedPurchases
        {
            get { return _bprwu_CompressEmailedPurchases; }
            set
            {
                SetDirty(_bprwu_CompressEmailedPurchases, value);
                _bprwu_CompressEmailedPurchases = value;
            }
        }

        public bool prwu_CompanyLinksNewTab
        {
            get { return _bprwu_CompanyLinksNewTab; }
            set
            {
                SetDirty(_bprwu_CompanyLinksNewTab, value);
                _bprwu_CompanyLinksNewTab = value;
            }
        }

        /// <summary>
        /// Accessor for the prwu_LastLoginDateTime property.
        /// </summary>
        public DateTime LastLoginDate {
            get {return _dtprwu_LastLoginDateTime;}
            set {SetDirty(_dtprwu_LastLoginDateTime, value);
                 _dtprwu_LastLoginDateTime = value;}
        }

        /// <summary>
        /// Accessor for the prwu_LastPasswordChange property.
        /// </summary>
        public DateTime prwu_LastPasswordChange {
            get {return _dtprwu_LastPasswordChange;}
            set {SetDirty(_dtprwu_LastPasswordChange, value);
                 _dtprwu_LastPasswordChange = value;}
        }

        /// <summary>
        /// Accessor for the prwu_PasswordChangeGuid property.
        /// </summary>
        public string prwu_PasswordChangeGuid
        {
            get { return _szprwu_PasswordChangeGuid; }
            set
            {
                SetDirty(_szprwu_PasswordChangeGuid, value);
                _szprwu_PasswordChangeGuid = value;
            }
        }

        /// <summary>
        /// Accessor for the prwu_PasswordChangeGuid property.
        /// </summary>
        public DateTime prwu_PasswordChangeGuidExpirationDate
        {
            get { return _dtprwu_PasswordChangeGuidExpirationDate; }
            set
            {
                SetDirty(_dtprwu_PasswordChangeGuidExpirationDate, value);
                _dtprwu_PasswordChangeGuidExpirationDate = value;
            }
        }

        /// <summary>
        /// Accessor for the prwu_TrialExpirationDate property.
        /// </summary>
        public DateTime prwu_TrialExpirationDate {
            get {return _dtprwu_TrialExpirationDate;}
            set {SetDirty(_dtprwu_TrialExpirationDate, value);
                 _dtprwu_TrialExpirationDate = value;}
        }

        public DateTime prwu_AcceptedMemberAgreementDate {
            get { return _dtprwu_AcceptedMemberAgreementDate; }
            set {
                SetDirty(_dtprwu_AcceptedMemberAgreementDate, value);
                _dtprwu_AcceptedMemberAgreementDate = value;
            }
        }
        
        public DateTime prwu_AcceptedTermsDate {
            get { return _dtprwu_AcceptedTermsDate; }
            set {
                SetDirty(_dtprwu_AcceptedTermsDate, value);
                _dtprwu_AcceptedTermsDate = value;
            }
        }

        /// <summary>
        /// Accessor for the prwu_BBID property.
        /// </summary>
        public int prwu_BBID {
            get {return _iprwu_BBID;}
            set {SetDirty(_iprwu_BBID, value);
                 _iprwu_BBID = value;}
        }

        /// <summary>
        /// Accessor for the prwu_CountryID property.
        /// </summary>
        public int prwu_CountryID {
            get {return _iprwu_CountryID;}
            set {SetDirty(_iprwu_CountryID, value);
                 _iprwu_CountryID = value;}
        }

        /// <summary>
        /// Accessor for the prwu_FailedAttemptCount property.
        /// </summary>
        public int prwu_FailedAttemptCount {
            get {return _iprwu_FailedAttemptCount;}
            set {SetDirty(_iprwu_FailedAttemptCount, value);
                 _iprwu_FailedAttemptCount = value;}
        }

        /// <summary>
        /// Accessor for the prwu_HQID property.
        /// </summary>
        public int prwu_HQID {
            get { return _iprwu_HQID; }
            set {
                SetDirty(_iprwu_HQID, value);
                _iprwu_HQID = value;
            }
        }

        /// <summary>
        /// Accessor for the prwu_LastCompanySearchID property.
        /// </summary>
        public int prwu_LastCompanySearchID {
            get {return _iprwu_LastCompanySearchID;}
            set {SetDirty(_iprwu_LastCompanySearchID, value);
                 _iprwu_LastCompanySearchID = value;}
        }

        /// <summary>
        /// Accessor for the prwu_LastCreditSheetSearchID property.
        /// </summary>
        public int prwu_LastCreditSheetSearchID {
            get {return _iprwu_LastCreditSheetSearchID;}
            set {SetDirty(_iprwu_LastCreditSheetSearchID, value);
                 _iprwu_LastCreditSheetSearchID = value;}
        }

        /// <summary>
        /// Accessor for the prwu_LastPersonSearchID property.
        /// </summary>
        public int prwu_LastPersonSearchID {
            get {return _iprwu_LastPersonSearchID;}
            set {SetDirty(_iprwu_LastPersonSearchID, value);
                 _iprwu_LastPersonSearchID = value;}
        }


        /// <summary>
        /// Accessor for the prwu_LastClaimsActivitySearchID property.
        /// </summary>
        public int prwu_LastClaimsActivitySearchID
        {
            get { return _iprwu_LastClaimsActivitySearchID; }
            set
            {
                SetDirty(_iprwu_LastClaimsActivitySearchID, value);
                _iprwu_LastClaimsActivitySearchID = value;
            }
        }


        /// <summary>
        /// Accessor for the prwu_LoginCount property.
        /// </summary>
        public int LoginCount {
            get {return _iprwu_LoginCount;}
            set {SetDirty(_iprwu_LoginCount, value);
                 _iprwu_LoginCount = value;}
        }

        /// <summary>
        /// Accessor for the prwu_MessageLoginCount property.
        /// </summary>
        public int MessageLoginCount
        {
            get { return _iprwu_MessageLoginCount; }
            set
            {
                SetDirty(_iprwu_MessageLoginCount, value);
                _iprwu_MessageLoginCount = value;
            }
        }
        /// <summary>
        /// Accessor for the prwu_MemberMessageLoginCount property.
        /// </summary>
        public int MemberMessageLoginCount
        {
            get { return _iprwu_MemberMessageLoginCount; }
            set
            {
                SetDirty(_iprwu_MemberMessageLoginCount, value);
                _iprwu_MemberMessageLoginCount = value;
            }
        }
        /// <summary>
        /// Accessor for the prwu_MessageLoginCount property.
        /// </summary>
        public int NonMemberMessageLoginCount
        {
            get { return _iprwu_NonMemberMessageLoginCount; }
            set
            {
                SetDirty(_iprwu_NonMemberMessageLoginCount, value);
                _iprwu_NonMemberMessageLoginCount = value;
            }
        }
        /// <summary>
        /// Accessor for the prwu_PersonLinkID property.
        /// </summary>
        public int prwu_PersonLinkID {
            get {return _iprwu_PersonLinkID;}
            set {SetDirty(_iprwu_PersonLinkID, value);
                 _iprwu_PersonLinkID = value;}
        }

        /// <summary>
        /// Accessor for the prwu_PRServiceID property.
        /// </summary>
        public int prwu_PRServiceID {
            get {return _iprwu_PRServiceID;}
            set {SetDirty(_iprwu_PRServiceID, value);
                 _iprwu_PRServiceID = value;}
        }

        /// <summary>
        /// Accessor for the prwu_StateID property.
        /// </summary>
        public int prwu_StateID {
            get {return _iprwu_StateID;}
            set {SetDirty(_iprwu_StateID, value);
                 _iprwu_StateID = value;}
        }

        /// <summary>
        /// Accessor for the prwu_WebUserID property.
        /// </summary>
        public int prwu_WebUserID {
            get {return _iprwu_WebUserID;}
            set {SetDirty(_iprwu_WebUserID, value);
                 _iprwu_WebUserID = value;}
        }

        /// <summary>
        /// Accessor for the UserID property.
        /// </summary>
        public string UserID {
            get { return _iprwu_WebUserID.ToString(); }
            set {}
        }

        /// <summary>
        /// Accessor for the prwu_AccessLevel property.
        /// </summary>
        public int prwu_AccessLevel {
            get {return _iprwu_AccessLevel;}
            set {SetDirty(_iprwu_AccessLevel, value);
                 _iprwu_AccessLevel = value;}
        }

        /// <summary>
        /// Accessor for the prwu_ServiceCode property.
        /// </summary>
        public string prwu_ServiceCode
        {
            get { return _szprwu_ServiceCode; }
            set
            {
                SetDirty(_szprwu_ServiceCode, value);
                _szprwu_ServiceCode = value;
            }
        }

        /// <summary>
        /// Accessor for the prwu_PreviousAccessLevel property.
        /// </summary>
        public int prwu_PreviousAccessLevel
        {
            get { return _iprwu_PreviousAccessLevel; }
        }

        /// <summary>
        /// Accessor for the prwu_CDSWBBID property.
        /// </summary>
        public int prwu_CDSWBBID {
            get { return _iprwu_CDSWBBID; }
            set {
                SetDirty(_iprwu_CDSWBBID, value);
                _iprwu_CDSWBBID = value;
            }
        }

        /// <summary>
        /// Accessor for the _iprwu_BBIDLoginCount property.
        /// </summary>
        public int prwu_BBIDLoginCount {
            get { return _iprwu_BBIDLoginCount; }
            set {
                SetDirty(_iprwu_BBIDLoginCount, value);
                _iprwu_BBIDLoginCount = value;
            }
        }

        /// <summary>
        /// Accessor for the prwu_DefaultCommoditySearchLayout property.
        /// </summary>
        public string prwu_DefaultCommoditySearchLayout
        {
            get
            {
                return _szprwu_DefaultCommoditySearchLayout; // _szprwu_DefaultCommoditySearchLayout; 
            }
            set
            {
                SetDirty(_szprwu_DefaultCommoditySearchLayout, value);
                _szprwu_DefaultCommoditySearchLayout = value;
            }
        }

        /// <summary>
        /// Accessor for the prwu_Address1 property.
        /// </summary>
        public string prwu_Address1 {
            get {return _szprwu_Address1;}
            set {SetDirty(_szprwu_Address1, value);
                 _szprwu_Address1 = value;}
        }

        /// <summary>
        /// Accessor for the prwu_Address2 property.
        /// </summary>
        public string prwu_Address2 {
            get {return _szprwu_Address2;}
            set {SetDirty(_szprwu_Address2, value);
                 _szprwu_Address2 = value;}
        }

        /// <summary>
        /// Accessor for the prwu_City property.
        /// </summary>
        public string prwu_City {
            get {return _szprwu_City;}
            set {SetDirty(_szprwu_City, value);
                 _szprwu_City = value;}
        }

        /// <summary>
        /// Accessor for the prwu_CompanyData property.
        /// </summary>
        public string prwu_CompanyData {
            get {return _szprwu_CompanyData;}
            set {SetDirty(_szprwu_CompanyData, value);
                 _szprwu_CompanyData = value;}
        }

        /// <summary>
        /// Accessor for the prwu_CompanyName property.
        /// </summary>
        public string prwu_CompanyName {
            get {return _szprwu_CompanyName;}
            set {SetDirty(_szprwu_CompanyName, value);
                 _szprwu_CompanyName = value;}
        }

        /// <summary>
        /// Accessor for the prwu_CompanySize property.
        /// </summary>
        public string prwu_CompanySize {
            get {return _szprwu_CompanySize;}
            set {SetDirty(_szprwu_CompanySize, value);
                 _szprwu_CompanySize = value;}
        }

        /// <summary>
        /// Accessor for the prwu_County property.
        /// </summary>
        public string prwu_County {
            get {return _szprwu_County;}
            set {SetDirty(_szprwu_County, value);
                 _szprwu_County = value;}
        }
        
        /// <summary>
        /// Accessor for the prwu_Culture property.
        /// </summary>
        public string prwu_Culture {
            get {return _szprwu_Culture;}
            set {SetDirty(_szprwu_Culture, value);
                 _szprwu_Culture = value;}
        }

        /// <summary>
        /// Accessor for the prwu_DefaultCompanySearchPage property.
        /// </summary>
        public string prwu_DefaultCompanySearchPage {
            get {return _szprwu_DefaultCompanySearchPage;}
            set {SetDirty(_szprwu_DefaultCompanySearchPage, value);
                 _szprwu_DefaultCompanySearchPage = value;}
        }

        /// <summary>
        /// Accessor for the prwu_Email property.
        /// </summary>
        public string Email {
            get {return _szprwu_Email;}
            set {SetDirty(_szprwu_Email, value);
                 _szprwu_Email = value;}
        }

        /// <summary>
        /// Accessor for the prwu_FaxAreaCode property.
        /// </summary>
        public string prwu_FaxAreaCode {
            get {return _szprwu_FaxAreaCode;}
            set {SetDirty(_szprwu_FaxAreaCode, value);
                 _szprwu_FaxAreaCode = value;}
        }

        /// <summary>
        /// Accessor for the prwu_FaxNumber property.
        /// </summary>
        public string prwu_FaxNumber {
            get {return _szprwu_FaxNumber;}
            set {SetDirty(_szprwu_FaxNumber, value);
                 _szprwu_FaxNumber = value;}
        }

        /// <summary>
        /// Accessor for the prwu_FirstName property.
        /// </summary>
        public string FirstName {
            get {return _szprwu_FirstName;}
            set {SetDirty(_szprwu_FirstName, value);
                 _szprwu_FirstName = value;}
        }

        /// <summary>
        /// Accessor for the prwu_Gender property.
        /// </summary>
        public string prwu_Gender {
            get {return _szprwu_Gender;}
            set {SetDirty(_szprwu_Gender, value);
                 _szprwu_Gender = value;}
        }

        /// <summary>
        /// Accessor for the prwu_HowLearned property.
        /// </summary>
        public string prwu_HowLearned {
            get {return _szprwu_HowLearned;}
            set {SetDirty(_szprwu_HowLearned, value);
                 _szprwu_HowLearned = value;}
        }

        /// <summary>
        /// Accessor for the prwu_IndustryClassification property.
        /// </summary>
        public string prwu_IndustryClassification {
            get {return _szprwu_IndustryClassification;}
            set {SetDirty(_szprwu_IndustryClassification, value);
                 _szprwu_IndustryClassification = value;}
        }

        /// <summary>
        /// Accessor for the prwu_LastName property.
        /// </summary>
        public string LastName {
            get {return _szprwu_LastName;}
            set {SetDirty(_szprwu_LastName, value);
                 _szprwu_LastName = value;}
        }

        /// <summary>
        /// Accessor for the prwu_Password property.
        /// </summary>
        public string Password {
            get {return _szprwu_Password;}
            
			set {string szNewPassword = value;
				 _szClearTextPassword = szNewPassword;
				 if (szNewPassword != null) {
					IEncryptionProvider oEncryption = EncryptionFactory.GetEncryptionProvider();
					szNewPassword = oEncryption.Encrypt(szNewPassword);
				}
                SetDirty(_szprwu_Password, szNewPassword);
                _szprwu_Password = szNewPassword;
			} 
        }

        /// <summary>
        /// Accessor for the prwu_PhoneAreaCode property.
        /// </summary>
        public string prwu_PhoneAreaCode {
            get {return _szprwu_PhoneAreaCode;}
            set {SetDirty(_szprwu_PhoneAreaCode, value);
                 _szprwu_PhoneAreaCode = value;}
        }

        /// <summary>
        /// Accessor for the prwu_PhoneNumber property.
        /// </summary>
        public string prwu_PhoneNumber {
            get {return _szprwu_PhoneNumber;}
            set {SetDirty(_szprwu_PhoneNumber, value);
                 _szprwu_PhoneNumber = value;}
        }

        /// <summary>
        /// Accessor for the prwu_PostalCode property.
        /// </summary>
        public string prwu_PostalCode {
            get {return _szprwu_PostalCode;}
            set {SetDirty(_szprwu_PostalCode, value);
                 _szprwu_PostalCode = value;}
        }

        /// <summary>
        /// Accessor for the prwu_TitleCode property.
        /// </summary>
        public string prwu_TitleCode {
            get {return _szprwu_TitleCode;}
            set {SetDirty(_szprwu_TitleCode, value);
                 _szprwu_TitleCode = value;}
        }

        /// <summary>
        /// Accessor for the prwu_UICulture property.
        /// </summary>
        public string prwu_UICulture {
            get {return _szprwu_UICulture;}
            set {SetDirty(_szprwu_UICulture, value);
                 _szprwu_UICulture = value;}
        }

        /// <summary>
        /// Accessor for the prwu_WebSite property.
        /// </summary>
        public string prwu_WebSite {
            get {return _szprwu_WebSite;}
            set {SetDirty(_szprwu_WebSite, value);
                 _szprwu_WebSite = value;}
        }

        public string prwu_LinkedInToken
        {
            get { return _szprwu_LinkedInToken; }
            set
            {
                SetDirty(_szprwu_LinkedInToken, value);
                _szprwu_LinkedInToken = value;
            }
        }

        public string prwu_LinkedInTokenSecret
        {
            get { return _szprwu_LinkedInTokenSecret; }
            set
            {
                SetDirty(_szprwu_LinkedInTokenSecret, value);
                _szprwu_LinkedInTokenSecret = value;
            }
        }


        public string prwu_CompanyUpdateMessageType
        {
            get { return _szprwu_CompanyUpdateMessageType; }
            set
            {
                SetDirty(_szprwu_CompanyUpdateMessageType, value);
                _szprwu_CompanyUpdateMessageType = value;
            }
        }


        public string prwu_Timezone
        {
            get { return _szprwu_Timezone; }
            set
            {
                SetDirty(_szprwu_Timezone, value);
                _szprwu_Timezone = value;
            }
        }


        public string prwu_LocalSourceSearch
        {
            get { return _szprwu_LocalSourceSearch; }
            set
            {
                SetDirty(_szprwu_LocalSourceSearch, value);
                _szprwu_LocalSourceSearch = value;
            }
        }

        public string prwu_ARReportsThrehold
        {
            get { if (string.IsNullOrEmpty(_szprwu_ARReportsThrehold))
                    {
                        prwu_ARReportsThrehold = "24";
                    }
                    return _szprwu_ARReportsThrehold; }
            set
            {
                SetDirty(_szprwu_ARReportsThrehold, value);
                _szprwu_ARReportsThrehold = value;
            }
        }

        /// <summary>
        /// Accessor for the prwu_CompanyUpdateDaysOld property.
        /// </summary>
        public int? prwu_CompanyUpdateDaysOld
        {
            get { return _iprwu_CompanyUpdateDaysOld; }
            set
            {
                SetDirty(_iprwu_CompanyUpdateDaysOld, value);
                _iprwu_CompanyUpdateDaysOld = value;
            }
        }

        /// <summary>
        /// Accessor for the LastBBOSPopupID property.
        /// </summary>
        public int prwu_LastBBOSPopupID
        {
            get { return _iprwu_LastBBOSPopupID; }
            set
            {
                SetDirty(_iprwu_LastBBOSPopupID, value);
                _iprwu_LastBBOSPopupID = value;
            }
        }


        /// <summary>
        /// Accessor for the prwu_LastBBOSPopupViewDate property.
        /// </summary>
        public DateTime prwu_LastBBOSPopupViewDate
        {
            get { return _dtprwu_LastBBOSPopupViewDate; }
            set
            {
                SetDirty(_dtprwu_LastBBOSPopupViewDate, value);
                _dtprwu_LastBBOSPopupViewDate = value;
            }
        }


        /// <summary>
        /// Accessor for the prwu_MobileGUID property.
        /// </summary>
        public string prwu_MobileGUID
        {
            get { return _szprwu_MobileGUID; }
            set
            {
                SetDirty(_szprwu_MobileGUID, value);
                _szprwu_MobileGUID = value;
            }
        }


        /// <summary>
        /// Accessor for the prwu_MobileGUIDExpiration property.
        /// </summary>
        public DateTime prwu_MobileGUIDExpiration
        {
            get { return _dtprwu_MobileGUIDExpiration; }
            set
            {
                SetDirty(_dtprwu_MobileGUIDExpiration, value);
                _dtprwu_MobileGUIDExpiration = value;
            }
        }

        /// <summary>
        /// Return a Dictionary of Field to Column mappings with the field
        /// as the key based on the Load/Unload options specified.
        /// </summary>
        /// <returns>IDictionary</returns>
        override public IDictionary GetFieldColMapping() {
            bool bCreateMapping = false;
            if (_htFieldColMapping == null) {
                bCreateMapping = true;
            }

            base.GetFieldColMapping();

            if (bCreateMapping) {
                _htFieldColMapping.Add("prwu_AcceptedTerms",			PRWebUserMgr.COL_PRWU_ACCEPTED_TERMS);
                _htFieldColMapping.Add("prwu_IsNewUser",				PRWebUserMgr.COL_PRWU_IS_NEW_USER);
                _htFieldColMapping.Add("prwu_MailListOptIn",			PRWebUserMgr.COL_PRWU_MAIL_LIST_OPT_IN);
                _htFieldColMapping.Add("prwu_MembershipInterest",		PRWebUserMgr.COL_PRWU_MEMBERSHIP_INTEREST);
                _htFieldColMapping.Add("prwu_Disabled",                 PRWebUserMgr.COL_PRWU_DISABLED);
                _htFieldColMapping.Add("prwu_HideBRPurchaseConfirmationMsg", PRWebUserMgr.COL_PRWU_HIDE_BR_PURCHASE_CONFIRMATION_MSG);

                _htFieldColMapping.Add("prwu_LastLoginDateTime",		PRWebUserMgr.COL_PRWU_LAST_LOGIN_DATE_TIME);
                _htFieldColMapping.Add("prwu_LastPasswordChange",		PRWebUserMgr.COL_PRWU_LAST_PASSWORD_CHANGE);
                _htFieldColMapping.Add("prwu_TrialExpirationDate",		PRWebUserMgr.COL_PRWU_TRIAL_EXPIRATION_DATE);
                _htFieldColMapping.Add("prwu_BBID",						PRWebUserMgr.COL_PRWU_BBID);
                _htFieldColMapping.Add("prwu_CountryID",				PRWebUserMgr.COL_PRWU_COUNTRY_ID);
                _htFieldColMapping.Add("prwu_FailedAttemptCount",		PRWebUserMgr.COL_PRWU_FAILED_ATTEMPT_COUNT);
                _htFieldColMapping.Add("prwu_HQID",                     PRWebUserMgr.COL_PRWU_HQID);
                _htFieldColMapping.Add("prwu_LastCompanySearchID",		PRWebUserMgr.COL_PRWU_LAST_COMPANY_SEARCH_ID);
                _htFieldColMapping.Add("prwu_LastCreditSheetSearchID",	PRWebUserMgr.COL_PRWU_LAST_CREDIT_SHEET_SEARCH_ID);
                _htFieldColMapping.Add("prwu_LastPersonSearchID",		PRWebUserMgr.COL_PRWU_LAST_PERSON_SEARCH_ID);
                _htFieldColMapping.Add("prwu_LastClaimsActivitySearchID",      PRWebUserMgr.COL_PRWU_LAST_CLAIMS_ACTIVITY_SEARCH_ID);
                _htFieldColMapping.Add("prwu_LoginCount",				PRWebUserMgr.COL_PRWU_LOGIN_COUNT);
                _htFieldColMapping.Add("prwu_PersonLinkID",				PRWebUserMgr.COL_PRWU_PERSON_LINK_ID);
                _htFieldColMapping.Add("prwu_PRServiceID",				PRWebUserMgr.COL_PRWU_PRSERVICE_ID);
                _htFieldColMapping.Add("prwu_StateID",					PRWebUserMgr.COL_PRWU_STATE_ID);
                _htFieldColMapping.Add("prwu_WebUserID",				PRWebUserMgr.COL_PRWU_WEB_USER_ID);
                _htFieldColMapping.Add("prwu_AccessLevel",				PRWebUserMgr.COL_PRWU_ACCESS_LEVEL);
                _htFieldColMapping.Add("prwu_PreviousAccessLevel",      PRWebUserMgr.COL_PRWU_PREVIOUS_ACCESS_LEVEL);
                _htFieldColMapping.Add("prwu_Address1",					PRWebUserMgr.COL_PRWU_ADDRESS1);
                _htFieldColMapping.Add("prwu_Address2",					PRWebUserMgr.COL_PRWU_ADDRESS2);
                _htFieldColMapping.Add("prwu_City",						PRWebUserMgr.COL_PRWU_CITY);
                _htFieldColMapping.Add("prwu_County",                   PRWebUserMgr.COL_PRWU_COUNTY);
                _htFieldColMapping.Add("prwu_CompanyData",				PRWebUserMgr.COL_PRWU_COMPANY_DATA);
                _htFieldColMapping.Add("prwu_CompanyName",				PRWebUserMgr.COL_PRWU_COMPANY_NAME);
                _htFieldColMapping.Add("prwu_CompanySize",				PRWebUserMgr.COL_PRWU_COMPANY_SIZE);
                _htFieldColMapping.Add("prwu_Culture",					PRWebUserMgr.COL_PRWU_CULTURE);
                _htFieldColMapping.Add("prwu_DefaultCompanySearchPage",	PRWebUserMgr.COL_PRWU_DEFAULT_COMPANY_SEARCH_PAGE);
                _htFieldColMapping.Add("prwu_Email",					PRWebUserMgr.COL_PRWU_EMAIL);
                _htFieldColMapping.Add("prwu_FaxAreaCode",				PRWebUserMgr.COL_PRWU_FAX_AREA_CODE);
                _htFieldColMapping.Add("prwu_FaxNumber",				PRWebUserMgr.COL_PRWU_FAX_NUMBER);
                _htFieldColMapping.Add("prwu_FirstName",				PRWebUserMgr.COL_PRWU_FIRST_NAME);
                _htFieldColMapping.Add("prwu_Gender",					PRWebUserMgr.COL_PRWU_GENDER);
                _htFieldColMapping.Add("prwu_HowLearned",				PRWebUserMgr.COL_PRWU_HOW_LEARNED);
                _htFieldColMapping.Add("prwu_IndustryClassification",	PRWebUserMgr.COL_PRWU_INDUSTRY_CLASSIFICATION);
                _htFieldColMapping.Add("prwu_LastName",					PRWebUserMgr.COL_PRWU_LAST_NAME);
                _htFieldColMapping.Add("prwu_Password",					PRWebUserMgr.COL_PRWU_PASSWORD);
                _htFieldColMapping.Add("prwu_PhoneAreaCode",			PRWebUserMgr.COL_PRWU_PHONE_AREA_CODE);
                _htFieldColMapping.Add("prwu_PhoneNumber",				PRWebUserMgr.COL_PRWU_PHONE_NUMBER);
                _htFieldColMapping.Add("prwu_PostalCode",				PRWebUserMgr.COL_PRWU_POSTAL_CODE);
                _htFieldColMapping.Add("prwu_TitleCode",				PRWebUserMgr.COL_PRWU_TITLE_CODE);
                _htFieldColMapping.Add("prwu_UICulture",				PRWebUserMgr.COL_PRWU_UICULTURE);
                _htFieldColMapping.Add("prwu_WebSite",					PRWebUserMgr.COL_PRWU_WEB_SITE);
                _htFieldColMapping.Add("prwu_BBIDLoginCount",			PRWebUserMgr.COL_PRWU_BBIDLOGINCOUNT);
                _htFieldColMapping.Add("prwu_AcceptedMemberAgreement",  PRWebUserMgr.COL_PRWU_ACCEPTED_MEMBER_AGREEMENT);
                _htFieldColMapping.Add("prwu_AcceptedMemberAgreementDate", PRWebUserMgr.COL_PRWU_ACCEPTED_MEMBER_AGREEMENT_DATE);
                _htFieldColMapping.Add("prwu_AcceptedTermsDate",        PRWebUserMgr.COL_PRWU_ACCEPTED_TERMS_DATE);

                _htFieldColMapping.Add("prwu_CompanyUpdateDaysOld",     PRWebUserMgr.COL_PRWU_COMPANYUPDATE_DAYS_OLD);
                _htFieldColMapping.Add("prwu_IndustryType",             PRWebUserMgr.COL_PRWU_INDUSTRY_TYPE);
                _htFieldColMapping.Add("prwu_DefaultCommoditySearchLayout", PRWebUserMgr.COL_PRWU_DEFAULT_COMMODITY_SEARCH_LAYOUT);
                _htFieldColMapping.Add("prwu_DontDisplayZeroResultsFeedback", PRWebUserMgr.COL_PRWU_DONTDISPLAYZERORESULTSFEEDBACK);
                _htFieldColMapping.Add("prwu_MessageLoginCount",        PRWebUserMgr.COL_PRWU_MESSAGE_LOGIN_COUNT);
                _htFieldColMapping.Add("prwu_MemberMessageLoginCount", PRWebUserMgr.COL_PRWU_MEMBER_MESSAGE_LOGIN_COUNT);
                _htFieldColMapping.Add("prwu_NonMemberMessageLoginCount", PRWebUserMgr.COL_PRWU_NONMEMBER_MESSAGE_LOGIN_COUNT);
                _htFieldColMapping.Add("prwu_LinkedInToken",            PRWebUserMgr.COL_PRWU_LINKED_IN_TOKEN);
                _htFieldColMapping.Add("prwu_LinkedInTokenSecret",      PRWebUserMgr.COL_PRWU_LINKED_IN_TOKEN_SECRET);

                _htFieldColMapping.Add("prwu_EmailPurchases",           PRWebUserMgr.COL_PRWU_EMAIL_PURCHASES);
                _htFieldColMapping.Add("prwu_CompressEmailedPurchases", PRWebUserMgr.COL_PRWU_COMPRESS_EMAILED_PURCHASES);
                _htFieldColMapping.Add("prwu_CompanyLinksNewTab",       PRWebUserMgr.COL_PRWU_COMPANY_LINKS_NEW_TAB);

                _htFieldColMapping.Add("prwu_LastBBOSPopupID",          PRWebUserMgr.COL_PRWU_LAST_BBOS_POPUP_ID);
                _htFieldColMapping.Add("prwu_LastBBOSPopupViewDate",    PRWebUserMgr.COL_PRWU_LAST_BBOS_POPUP_VIEW_DATE);
                _htFieldColMapping.Add("prwu_CompanyUpdateMessageType", PRWebUserMgr.COL_PRWU_COMPANY_UDPATES_MESSAGE_TYPE);
                _htFieldColMapping.Add("prwu_Timezone",                 PRWebUserMgr.COL_PRWU_TIMEZONE);
                _htFieldColMapping.Add("prwu_MobileGUID",               PRWebUserMgr.COL_PRWU_MOBILE_GUID);
                _htFieldColMapping.Add("prwu_MobileGUIDExpiration",     PRWebUserMgr.COL_PRWU_MOBILE_GUID_EXPIRATION);

                // Handle the audit fields
                _htFieldColMapping.Add("prwu_CreatedBy",                PRWebUserMgr.COL_CREATED_USER_ID);
                _htFieldColMapping.Add("prwu_UpdatedBy",                PRWebUserMgr.COL_UPDATED_USER_ID);
                _htFieldColMapping.Add("prwu_CreatedDate",              PRWebUserMgr.COL_CREATED_DATETIME);
                _htFieldColMapping.Add("prwu_UpdatedDate",              PRWebUserMgr.COL_UPDATED_DATETIME);
                _htFieldColMapping.Add("prwu_Timestamp",                PRWebUserMgr.COL_TIMESTAMP);
            }
            return _htFieldColMapping;
        }

        /// <summary>
        /// Populates the object from the Dictionary
        /// specified.
        /// </summary>
        /// <param name="oData">Dictionary of Data</param>
        /// <param name="iOptions">Load Option</param>
        override public void LoadObject(IDictionary oData, int iOptions) {
            base.LoadObject(oData, iOptions);

            _bprwu_AcceptedTerms                = ((PRWebUserMgr)_oMgr).TranslateFromCRMBool(oData[PRWebUserMgr.COL_PRWU_ACCEPTED_TERMS]);
            _bprwu_IsNewUser                    = ((PRWebUserMgr)_oMgr).TranslateFromCRMBool(oData[PRWebUserMgr.COL_PRWU_IS_NEW_USER]);
            _bprwu_MailListOptIn                = ((PRWebUserMgr)_oMgr).TranslateFromCRMBool(oData[PRWebUserMgr.COL_PRWU_MAIL_LIST_OPT_IN]);
            _bprwu_MembershipInterest           = ((PRWebUserMgr)_oMgr).TranslateFromCRMBool(oData[PRWebUserMgr.COL_PRWU_MEMBERSHIP_INTEREST]);
            _bprwu_Disabled                     = ((PRWebUserMgr)_oMgr).TranslateFromCRMBool(oData[PRWebUserMgr.COL_PRWU_DISABLED]);
            
            _prcta_IsIntlTradeAssociation       = ((PRWebUserMgr)_oMgr).TranslateFromCRMBool(oData[PRWebUserMgr.COL_PRCTA_IS_INTL_TRADE_ASSOCIATION]);
            _bprwuHideBRPurchaseConfirmationMsg = ((PRWebUserMgr)_oMgr).TranslateFromCRMBool(oData[PRWebUserMgr.COL_PRWU_HIDE_BR_PURCHASE_CONFIRMATION_MSG]);

            _dtprwu_LastLoginDateTime			= _oMgr.GetDateTime(oData[PRWebUserMgr.COL_PRWU_LAST_LOGIN_DATE_TIME]);
            _dtprwu_LastPasswordChange			= _oMgr.GetDateTime(oData[PRWebUserMgr.COL_PRWU_LAST_PASSWORD_CHANGE]);
            _dtprwu_TrialExpirationDate			= _oMgr.GetDateTime(oData[PRWebUserMgr.COL_PRWU_TRIAL_EXPIRATION_DATE]);
            _iprwu_BBID							= _oMgr.GetInt(oData[PRWebUserMgr.COL_PRWU_BBID]);
            _iprwu_CountryID					= _oMgr.GetInt(oData[PRWebUserMgr.COL_PRWU_COUNTRY_ID]);
            _iprwu_FailedAttemptCount			= _oMgr.GetInt(oData[PRWebUserMgr.COL_PRWU_FAILED_ATTEMPT_COUNT]);
            _iprwu_HQID                         = _oMgr.GetInt(oData[PRWebUserMgr.COL_PRWU_HQID]);
            _iprwu_LastCompanySearchID			= _oMgr.GetInt(oData[PRWebUserMgr.COL_PRWU_LAST_COMPANY_SEARCH_ID]);
            _iprwu_LastCreditSheetSearchID		= _oMgr.GetInt(oData[PRWebUserMgr.COL_PRWU_LAST_CREDIT_SHEET_SEARCH_ID]);
            _iprwu_LastPersonSearchID			= _oMgr.GetInt(oData[PRWebUserMgr.COL_PRWU_LAST_PERSON_SEARCH_ID]);
            _iprwu_LastClaimsActivitySearchID   = _oMgr.GetInt(oData[PRWebUserMgr.COL_PRWU_LAST_CLAIMS_ACTIVITY_SEARCH_ID]);

            _iprwu_LoginCount					= _oMgr.GetInt(oData[PRWebUserMgr.COL_PRWU_LOGIN_COUNT]);
            _iprwu_PersonLinkID					= _oMgr.GetInt(oData[PRWebUserMgr.COL_PRWU_PERSON_LINK_ID]);
            _iprwu_CDSWBBID                     = _oMgr.GetInt(oData[PRWebUserMgr.COL_PRWU_CDSWBBID]);
            //_iprwu_PRServiceID					= _oMgr.GetInt(oData[PRWebUserMgr.COL_PRWU_PRSERVICE_ID]);
            _iprwu_StateID						= _oMgr.GetInt(oData[PRWebUserMgr.COL_PRWU_STATE_ID]);
            _iprwu_WebUserID					= _oMgr.GetInt(oData[PRWebUserMgr.COL_PRWU_WEB_USER_ID]);
            _iprwu_AccessLevel                  = _oMgr.GetInt(oData[PRWebUserMgr.COL_PRWU_ACCESS_LEVEL]);
            _szprwu_ServiceCode                  = _oMgr.GetString(oData[PRWebUserMgr.COL_PRWU_SERVICE_CODE]);
            _iprwu_PreviousAccessLevel          = _oMgr.GetInt(oData[PRWebUserMgr.COL_PRWU_PREVIOUS_ACCESS_LEVEL]);
            _szprwu_Address1					= _oMgr.GetString(oData[PRWebUserMgr.COL_PRWU_ADDRESS1]);
            _szprwu_Address2					= _oMgr.GetString(oData[PRWebUserMgr.COL_PRWU_ADDRESS2]);
            _szprwu_City						= _oMgr.GetString(oData[PRWebUserMgr.COL_PRWU_CITY]);
            _szprwu_County                      = _oMgr.GetString(oData[PRWebUserMgr.COL_PRWU_COUNTY]);
            _szprwu_CompanyData					= _oMgr.GetString(oData[PRWebUserMgr.COL_PRWU_COMPANY_DATA]);
            _szprwu_CompanyName					= _oMgr.GetString(oData[PRWebUserMgr.COL_PRWU_COMPANY_NAME]);
            _szprwu_CompanySize					= _oMgr.GetString(oData[PRWebUserMgr.COL_PRWU_COMPANY_SIZE]);
            _szprwu_Culture						= _oMgr.GetString(oData[PRWebUserMgr.COL_PRWU_CULTURE]);
            _szprwu_DefaultCompanySearchPage	= _oMgr.GetString(oData[PRWebUserMgr.COL_PRWU_DEFAULT_COMPANY_SEARCH_PAGE]);
            _szprwu_Email						= _oMgr.GetString(oData[PRWebUserMgr.COL_PRWU_EMAIL]);
            _szprwu_FaxAreaCode					= _oMgr.GetString(oData[PRWebUserMgr.COL_PRWU_FAX_AREA_CODE]);
            _szprwu_FaxNumber					= _oMgr.GetString(oData[PRWebUserMgr.COL_PRWU_FAX_NUMBER]);
            _szprwu_FirstName                   = _oMgr.GetString(oData["FirstName"]);
            _szprwu_Gender						= _oMgr.GetString(oData[PRWebUserMgr.COL_PRWU_GENDER]);
            _szprwu_HowLearned					= _oMgr.GetString(oData[PRWebUserMgr.COL_PRWU_HOW_LEARNED]);
            _szprwu_IndustryClassification		= _oMgr.GetString(oData[PRWebUserMgr.COL_PRWU_INDUSTRY_CLASSIFICATION]);
            _szprwu_LastName                    = _oMgr.GetString(oData["LastName"]);
            _szprwu_Password					= _oMgr.GetString(oData[PRWebUserMgr.COL_PRWU_PASSWORD]);

            _szprwu_PasswordChangeGuid = _oMgr.GetString(oData[PRWebUserMgr.COL_PRWU_PASSWORD_CHANGE_GUID]);
            _dtprwu_PasswordChangeGuidExpirationDate = _oMgr.GetDateTime(oData[PRWebUserMgr.COL_PRWU_PASSWORD_CHANGE_GUID_ExpirationDate]);

            _szprwu_PhoneAreaCode				= _oMgr.GetString(oData[PRWebUserMgr.COL_PRWU_PHONE_AREA_CODE]);
            _szprwu_PhoneNumber					= _oMgr.GetString(oData[PRWebUserMgr.COL_PRWU_PHONE_NUMBER]);
            _szprwu_PostalCode					= _oMgr.GetString(oData[PRWebUserMgr.COL_PRWU_POSTAL_CODE]);
            _szprwu_TitleCode					= _oMgr.GetString(oData[PRWebUserMgr.COL_PRWU_TITLE_CODE]);
            _szprwu_UICulture					= _oMgr.GetString(oData[PRWebUserMgr.COL_PRWU_UICULTURE]);
            _szprwu_WebSite						= _oMgr.GetString(oData[PRWebUserMgr.COL_PRWU_WEB_SITE]);
            _iprwu_BBIDLoginCount               = _oMgr.GetInt(oData[PRWebUserMgr.COL_PRWU_BBIDLOGINCOUNT]);
            _bprwu_AcceptedMemberAgreement      = ((PRWebUserMgr)_oMgr).TranslateFromCRMBool(oData[PRWebUserMgr.COL_PRWU_ACCEPTED_MEMBER_AGREEMENT]);
            _dtprwu_AcceptedMemberAgreementDate = _oMgr.GetDateTime(oData[PRWebUserMgr.COL_PRWU_ACCEPTED_MEMBER_AGREEMENT_DATE]);
            _dtprwu_AcceptedTermsDate           = _oMgr.GetDateTime(oData[PRWebUserMgr.COL_PRWU_ACCEPTED_TERMS_DATE]);
            _szprwu_CompanyUpdateMessageType    = _oMgr.GetString(oData[PRWebUserMgr.COL_PRWU_COMPANY_UDPATES_MESSAGE_TYPE]);
            _szprwu_Timezone                    = _oMgr.GetString(oData[PRWebUserMgr.COL_PRWU_TIMEZONE]);
            _szprwu_LocalSourceSearch           = _oMgr.GetString(oData[PRWebUserMgr.COL_PRWU_LOCAL_SOURCE_SEARCH]);
            _szprwu_ARReportsThrehold           = _oMgr.GetString(oData[PRWebUserMgr.COL_PRWU_AR_REPORTS_THRESHOLD]);
            _szprwu_DefaultCommoditySearchLayout = _oMgr.GetString(oData[PRWebUserMgr.COL_PRWU_DEFAULT_COMMODITY_SEARCH_LAYOUT]);

            _ipeli_PersonID                     = _oMgr.GetInt(oData[PRWebUserMgr.COL_PELI_PERSONID]);
            _bpeli_PRSubmitTES                  = _oMgr.GetBool(oData[PRWebUserMgr.COL_PELI_PRSUBMITTES]);
            _bpeli_PRUpdateCL                   = _oMgr.GetBool(oData[PRWebUserMgr.COL_PELI_PRUPDATECL]);
            _bpeli_PRUseServiceUnits            = _oMgr.GetBool(oData[PRWebUserMgr.COL_PELI_USESERVICEUNITS]);
            _bpeli_PRUseSpecialServices         = _oMgr.GetBool(oData[PRWebUserMgr.COL_PELI_USESPECIALSERVICES]);
            _bpeli_PREditListing                = _oMgr.GetBool(oData[PRWebUserMgr.COL_PELI_PREDITLISTING]);
            _bprwu_DontDisplayZeroResultsFeedback = _oMgr.GetBool(oData[PRWebUserMgr.COL_PRWU_DONTDISPLAYZERORESULTSFEEDBACK]);
            _bprci2_Suspended                    = _oMgr.GetBool(oData[PRWebUserMgr.COL_PRCI2_SUSPENDED]);
            _prwu_SecurityDisabled              = _oMgr.GetBool(oData[PRWebUserMgr.COL_PRWU_SECURITY_DISABLED]);
            _prwu_SecurityDisabledDate = _oMgr.GetDateTime(oData[PRWebUserMgr.COL_PRWU_SECURITY_DISABLED_DATE]);
            _prwu_SecurityDisabledReason = _oMgr.GetString(oData[PRWebUserMgr.COL_PRWU_SECURITY_DISABLED_REASON]);
            _bprci2_SuspensionPending           = _oMgr.GetBool(oData[PRWebUserMgr.COL_PRCI2_SUSPENDSION_PENDING]);
            _bprwu_EmailPurchases               = _oMgr.GetBool(oData[PRWebUserMgr.COL_PRWU_EMAIL_PURCHASES]);
            _bprwu_CompressEmailedPurchases     = _oMgr.GetBool(oData[PRWebUserMgr.COL_PRWU_COMPRESS_EMAILED_PURCHASES]);
            _bprwu_CompanyLinksNewTab           = _oMgr.GetBool(oData[PRWebUserMgr.COL_PRWU_COMPANY_LINKS_NEW_TAB]);

            _bprc5_PRARReportAccess             = _oMgr.GetBool(oData[PRWebUserMgr.COL_COMP_PRAR_REPORT_ACCESS]);

            _szprwu_MobileGUID                  = _oMgr.GetString(oData[PRWebUserMgr.COL_PRWU_MOBILE_GUID]);
            _dtprwu_MobileGUIDExpiration        = _oMgr.GetDateTime(oData[PRWebUserMgr.COL_PRWU_MOBILE_GUID_EXPIRATION]);

            // _iprwu_CompanyUpdateDaysOld = _oMgr.GetInt(oData[PRWebUserMgr.COL_PRWU_COMPANYUPDATE_DAYS_OLD]);
            _iprwu_CompanyUpdateDaysOld = (int?)_oMgr.GetObject(oData[PRWebUserMgr.COL_PRWU_COMPANYUPDATE_DAYS_OLD]);
            _bSessionTrackerIDCheckDisabled = ((PRWebUserMgr)_oMgr).TranslateFromCRMBool(oData[PRWebUserMgr.COL_SESSIONTRACKER_ID_CHECKDISABLED]);

            _szIndustryType = _oMgr.GetString(oData[PRWebUserMgr.COL_PRWU_INDUSTRY_TYPE]);
            _szprwu_LinkedInToken = _oMgr.GetString(oData[PRWebUserMgr.COL_PRWU_LINKED_IN_TOKEN]);
            _szprwu_LinkedInTokenSecret = _oMgr.GetString(oData[PRWebUserMgr.COL_PRWU_LINKED_IN_TOKEN_SECRET]);

            _iprwu_MessageLoginCount = _oMgr.GetInt(oData[PRWebUserMgr.COL_PRWU_MESSAGE_LOGIN_COUNT]);
            _iprwu_MemberMessageLoginCount = _oMgr.GetInt(oData[PRWebUserMgr.COL_PRWU_MEMBER_MESSAGE_LOGIN_COUNT]);
            _iprwu_NonMemberMessageLoginCount = _oMgr.GetInt(oData[PRWebUserMgr.COL_PRWU_NONMEMBER_MESSAGE_LOGIN_COUNT]);

            _iprwu_LastBBOSPopupID = _oMgr.GetInt(oData[PRWebUserMgr.COL_PRWU_LAST_BBOS_POPUP_ID]);
            _dtprwu_LastBBOSPopupViewDate = _oMgr.GetDateTime(oData[PRWebUserMgr.COL_PRWU_LAST_BBOS_POPUP_VIEW_DATE]);

            // Handle the audit fields
            _szCreatedUserID = _oMgr.GetString(oData[PRWebUserMgr.COL_CREATED_USER_ID]);
            _szUpdatedUserID = _oMgr.GetString(oData[PRWebUserMgr.COL_UPDATED_USER_ID]);
            _dtCreatedDateTime = _oMgr.GetDateTime(oData[PRWebUserMgr.COL_CREATED_DATETIME]);
            _dtUpdatedDateTime = _oMgr.GetDateTime(oData[PRWebUserMgr.COL_UPDATED_DATETIME]);
            _dtprwu_Timestamp = _oMgr.GetDateTime(oData[PRWebUserMgr.COL_TIMESTAMP]);
        }

        /// <summary>
        /// Populates the specified Dictionary from the Object.
        /// </summary>
        /// <param name="oData">Dictionary of Data</param>
        /// <param name="iOptions">Unload Option</param>
        /// <returns>IDictionary</returns>
        override public void UnloadObject(IDictionary oData, int iOptions) {
            base.UnloadObject(oData, iOptions);

            oData.Add(PRWebUserMgr.COL_PRWU_ACCEPTED_TERMS,                     ((PRWebUserMgr)_oMgr).GetPIKSCoreBool(_bprwu_AcceptedTerms));
            oData.Add(PRWebUserMgr.COL_PRWU_IS_NEW_USER,                        ((PRWebUserMgr)_oMgr).GetPIKSCoreBool(_bprwu_IsNewUser));
            oData.Add(PRWebUserMgr.COL_PRWU_MAIL_LIST_OPT_IN,                   ((PRWebUserMgr)_oMgr).GetPIKSCoreBool(_bprwu_MailListOptIn));
            oData.Add(PRWebUserMgr.COL_PRWU_MEMBERSHIP_INTEREST,                ((PRWebUserMgr)_oMgr).GetPIKSCoreBool(_bprwu_MembershipInterest));
            oData.Add(PRWebUserMgr.COL_PRWU_DISABLED,                           ((PRWebUserMgr)_oMgr).GetPIKSCoreBool(_bprwu_Disabled));
            oData.Add(PRWebUserMgr.COL_PRWU_HIDE_BR_PURCHASE_CONFIRMATION_MSG,  ((PRWebUserMgr)_oMgr).GetPIKSCoreBool(_bprwuHideBRPurchaseConfirmationMsg));

            oData.Add(PRWebUserMgr.COL_PRWU_LAST_LOGIN_DATE_TIME,			_dtprwu_LastLoginDateTime);
            oData.Add(PRWebUserMgr.COL_PRWU_LAST_PASSWORD_CHANGE,			_dtprwu_LastPasswordChange);
            oData.Add(PRWebUserMgr.COL_PRWU_TRIAL_EXPIRATION_DATE,			_dtprwu_TrialExpirationDate);
            oData.Add(PRWebUserMgr.COL_PRWU_BBID,							_iprwu_BBID);
            oData.Add(PRWebUserMgr.COL_PRWU_COUNTRY_ID,						_iprwu_CountryID);
            oData.Add(PRWebUserMgr.COL_PRWU_FAILED_ATTEMPT_COUNT,			_iprwu_FailedAttemptCount);
            oData.Add(PRWebUserMgr.COL_PRWU_HQID,                           _iprwu_HQID);
            oData.Add(PRWebUserMgr.COL_PRWU_LAST_COMPANY_SEARCH_ID,			_iprwu_LastCompanySearchID);
            oData.Add(PRWebUserMgr.COL_PRWU_LAST_CREDIT_SHEET_SEARCH_ID,	_iprwu_LastCreditSheetSearchID);
            oData.Add(PRWebUserMgr.COL_PRWU_LAST_PERSON_SEARCH_ID,			_iprwu_LastPersonSearchID);
            oData.Add(PRWebUserMgr.COL_PRWU_LAST_CLAIMS_ACTIVITY_SEARCH_ID, _iprwu_LastClaimsActivitySearchID);
            oData.Add(PRWebUserMgr.COL_PRWU_LOGIN_COUNT,					_iprwu_LoginCount);
            oData.Add(PRWebUserMgr.COL_PRWU_PERSON_LINK_ID,					_iprwu_PersonLinkID);
            oData.Add(PRWebUserMgr.COL_PRWU_CDSWBBID,                       _iprwu_CDSWBBID);
            //oData.Add(PRWebUserMgr.COL_PRWU_PRSERVICE_ID,					_iprwu_PRServiceID);
            oData.Add(PRWebUserMgr.COL_PRWU_STATE_ID,						_iprwu_StateID);
            oData.Add(PRWebUserMgr.COL_PRWU_WEB_USER_ID,					_iprwu_WebUserID);
            oData.Add(PRWebUserMgr.COL_PRWU_ACCESS_LEVEL,					_iprwu_AccessLevel);
            oData.Add(PRWebUserMgr.COL_PRWU_SERVICE_CODE,                   _szprwu_ServiceCode);

            oData.Add(PRWebUserMgr.COL_PRWU_ADDRESS1,						_szprwu_Address1);
            oData.Add(PRWebUserMgr.COL_PRWU_ADDRESS2,						_szprwu_Address2);
            oData.Add(PRWebUserMgr.COL_PRWU_CITY,							_szprwu_City);
            oData.Add(PRWebUserMgr.COL_PRWU_COUNTY,                         _szprwu_County);
            oData.Add(PRWebUserMgr.COL_PRWU_COMPANY_DATA,					_szprwu_CompanyData);
            oData.Add(PRWebUserMgr.COL_PRWU_COMPANY_NAME,					_szprwu_CompanyName);
            oData.Add(PRWebUserMgr.COL_PRWU_COMPANY_SIZE,					_szprwu_CompanySize);
            oData.Add(PRWebUserMgr.COL_PRWU_CULTURE,						_szprwu_Culture);
            oData.Add(PRWebUserMgr.COL_PRWU_DEFAULT_COMPANY_SEARCH_PAGE,	_szprwu_DefaultCompanySearchPage);
            oData.Add(PRWebUserMgr.COL_PRWU_EMAIL,							_szprwu_Email);
            oData.Add(PRWebUserMgr.COL_PRWU_FAX_AREA_CODE,					_szprwu_FaxAreaCode);
            oData.Add(PRWebUserMgr.COL_PRWU_FAX_NUMBER,						_szprwu_FaxNumber);
            oData.Add(PRWebUserMgr.COL_PRWU_FIRST_NAME,						_szprwu_FirstName);
            oData.Add(PRWebUserMgr.COL_PRWU_GENDER,							_szprwu_Gender);
            oData.Add(PRWebUserMgr.COL_PRWU_HOW_LEARNED,					_szprwu_HowLearned);
            oData.Add(PRWebUserMgr.COL_PRWU_INDUSTRY_CLASSIFICATION,		_szprwu_IndustryClassification);
            oData.Add(PRWebUserMgr.COL_PRWU_LAST_NAME,						_szprwu_LastName);
            oData.Add(PRWebUserMgr.COL_PRWU_PASSWORD,						_szprwu_Password);

            oData.Add(PRWebUserMgr.COL_PRWU_PASSWORD_CHANGE_GUID, _szprwu_PasswordChangeGuid);
            oData.Add(PRWebUserMgr.COL_PRWU_PASSWORD_CHANGE_GUID_ExpirationDate, _dtprwu_PasswordChangeGuidExpirationDate);

            oData.Add(PRWebUserMgr.COL_PRWU_PHONE_AREA_CODE,				_szprwu_PhoneAreaCode);
            oData.Add(PRWebUserMgr.COL_PRWU_PHONE_NUMBER,					_szprwu_PhoneNumber);
            oData.Add(PRWebUserMgr.COL_PRWU_POSTAL_CODE,					_szprwu_PostalCode);
            oData.Add(PRWebUserMgr.COL_PRWU_TITLE_CODE,						_szprwu_TitleCode);
            oData.Add(PRWebUserMgr.COL_PRWU_UICULTURE,						_szprwu_UICulture);
            oData.Add(PRWebUserMgr.COL_PRWU_WEB_SITE,						_szprwu_WebSite);
            oData.Add(PRWebUserMgr.COL_PRWU_BBIDLOGINCOUNT,                 _iprwu_BBIDLoginCount);
            oData.Add(PRWebUserMgr.COL_PRWU_ACCEPTED_MEMBER_AGREEMENT,      ((PRWebUserMgr)_oMgr).GetPIKSCoreBool(_bprwu_AcceptedMemberAgreement));
            oData.Add(PRWebUserMgr.COL_PRWU_ACCEPTED_MEMBER_AGREEMENT_DATE, _dtprwu_AcceptedMemberAgreementDate);
            oData.Add(PRWebUserMgr.COL_PRWU_ACCEPTED_TERMS_DATE,            _dtprwu_AcceptedTermsDate);
            oData.Add(PRWebUserMgr.COL_PRWU_COMPANYUPDATE_DAYS_OLD,         _iprwu_CompanyUpdateDaysOld);
            oData.Add(PRWebUserMgr.COL_PRWU_INDUSTRY_TYPE,                  _szIndustryType);
            oData.Add(PRWebUserMgr.COL_PRWU_DEFAULT_COMMODITY_SEARCH_LAYOUT, _szprwu_DefaultCommoditySearchLayout);
            oData.Add(PRWebUserMgr.COL_PRWU_DONTDISPLAYZERORESULTSFEEDBACK, ((PRWebUserMgr)_oMgr).GetPIKSCoreBool(_bprwu_DontDisplayZeroResultsFeedback));

            oData.Add(PRWebUserMgr.COL_PRWU_MESSAGE_LOGIN_COUNT,            _iprwu_MessageLoginCount);
            oData.Add(PRWebUserMgr.COL_PRWU_MEMBER_MESSAGE_LOGIN_COUNT,     _iprwu_MemberMessageLoginCount);
            oData.Add(PRWebUserMgr.COL_PRWU_NONMEMBER_MESSAGE_LOGIN_COUNT,  _iprwu_NonMemberMessageLoginCount);
            oData.Add(PRWebUserMgr.COL_PRWU_LINKED_IN_TOKEN,                _szprwu_LinkedInToken);
            oData.Add(PRWebUserMgr.COL_PRWU_LINKED_IN_TOKEN_SECRET,         _szprwu_LinkedInTokenSecret);

            oData.Add(PRWebUserMgr.COL_PRWU_EMAIL_PURCHASES,                _bprwu_EmailPurchases);
            oData.Add(PRWebUserMgr.COL_PRWU_COMPRESS_EMAILED_PURCHASES,     _bprwu_CompressEmailedPurchases);
            oData.Add(PRWebUserMgr.COL_PRWU_COMPANY_LINKS_NEW_TAB, _bprwu_CompanyLinksNewTab);

            oData.Add(PRWebUserMgr.COL_PRWU_LAST_BBOS_POPUP_ID,             _iprwu_LastBBOSPopupID);
            oData.Add(PRWebUserMgr.COL_PRWU_LAST_BBOS_POPUP_VIEW_DATE,      _dtprwu_LastBBOSPopupViewDate);
            oData.Add(PRWebUserMgr.COL_PRWU_COMPANY_UDPATES_MESSAGE_TYPE,   _szprwu_CompanyUpdateMessageType);
            oData.Add(PRWebUserMgr.COL_PRWU_TIMEZONE,                       _szprwu_Timezone);
            oData.Add(PRWebUserMgr.COL_PRWU_LOCAL_SOURCE_SEARCH,            _szprwu_LocalSourceSearch);
            oData.Add(PRWebUserMgr.COL_PRWU_AR_REPORTS_THRESHOLD,           _szprwu_ARReportsThrehold);
            oData.Add(PRWebUserMgr.COL_PRWU_SECURITY_DISABLED,              ((PRWebUserMgr)_oMgr).GetPIKSCoreBool(_prwu_SecurityDisabled));
            oData.Add(PRWebUserMgr.COL_PRWU_SECURITY_DISABLED_DATE,         _prwu_SecurityDisabledDate);
            oData.Add(PRWebUserMgr.COL_PRWU_SECURITY_DISABLED_REASON,       _prwu_SecurityDisabledReason);

            oData.Add(PRWebUserMgr.COL_PRWU_MOBILE_GUID,                _szprwu_MobileGUID);
            oData.Add(PRWebUserMgr.COL_PRWU_MOBILE_GUID_EXPIRATION,     _dtprwu_MobileGUIDExpiration);

            // Handle the audit fields
            oData.Add(PRWebUserMgr.COL_CREATED_USER_ID, _szCreatedUserID);
            oData.Add(PRWebUserMgr.COL_UPDATED_USER_ID, _szUpdatedUserID);
            oData.Add(PRWebUserMgr.COL_CREATED_DATETIME, _dtCreatedDateTime);
            oData.Add(PRWebUserMgr.COL_UPDATED_DATETIME, _dtUpdatedDateTime);
            oData.Add(PRWebUserMgr.COL_TIMESTAMP, _dtprwu_Timestamp);
        }
        #endregion

        /// <summary>
        /// Accessor for Session Tracker ID check
        /// </summary>
        virtual public bool SessionTrackerIDCheckDisabled
        {
            get { return _bSessionTrackerIDCheckDisabled; }
        }

        /// <summary>
        /// Accessor for the AuthenticationType property.
        /// </summary>
        virtual public string AuthenticationType {
            get { return "Custom Authentication"; }
        }

        /// <summary>
        /// Accessor for the IsAuthenticated property.
        /// </summary>
        virtual public bool IsAuthenticated {
            get { return _bIsAuthenticated; }
        }


        /// <summary>
        /// Accessor for the UserID property.
        /// </summary>
        virtual public string Name {
            get { return _szprwu_LastName + ", " + _szprwu_FirstName; }
            set { }
        }

        virtual public bool HasAccess(int iAccessLevel) {
            return iAccessLevel <= _iprwu_AccessLevel;
        }

        public SecurityMgr.SecurityResult HasPrivilege(SecurityMgr.Privilege privilge)
        {
            return SecurityMgr.HasPrivilege(this, privilge);
        }
        
        /// <summary>
        /// Authenticates the user based on the specified password.  
        /// Uses an EncryptionProvider to encrypt the specified 
        /// password and compare it to the current password.  If 
        /// successful, updates the login statistics.
        /// </summary>
        /// <param name="szPassword">Password to Authenticate</param>
        /// <returns>Authentication Indicator</returns>
        virtual public bool Authenticate(string szPassword) {

            _bIsAuthenticated = EncryptedAuthenticate(szPassword);

            if (_bIsAuthenticated) {
                UpdateLoginStats();
            } else {
                UpdateFailedLoginStats();
            }

            return _bIsAuthenticated;
        }

        /// <summary>
        /// Encrypts the specified password and then compares
        /// it to the current password.
        /// </summary>
        /// <param name="szPassword">Password to Authenticate</param>
        /// <returns>Authentication Indicator</returns>
        virtual protected bool EncryptedAuthenticate(string szPassword) {

            // Encrypt the specified password and then compare.  This way
            // we avoid having the actual password in memeory in plain text.
            IEncryptionProvider oEncryption = EncryptionFactory.GetEncryptionProvider();
            return PlainTextAuthenticate(oEncryption.Encrypt(szPassword));
        }

        /// <summary>
        /// Compares the specified password to the current password.
        /// </summary>
        /// <param name="szPassword">Password to Authenticate</param>
        /// <returns>Authentication Indicator</returns>
        virtual protected bool PlainTextAuthenticate(string szPassword) {
            if (szPassword == _szprwu_Password) {
                return true;
            } else {
                return false;
            }
        }

        /// <summary>
        /// Updates the repository with the login statistics
        /// for current user.
        /// </summary>
        virtual public void UpdateLoginStats() {
            LoginCount++;
            LastLoginDate = DateTime.Now;
            MessageLoginCount++;
            MemberMessageLoginCount++;

            _oMgr.SaveObject(this);
        }

        /// <summary>
        /// Updates the repository with the login statistics
        /// for current user.
        /// </summary>
        virtual protected void UpdateFailedLoginStats() {
            prwu_FailedAttemptCount++;
            _oMgr.SaveObject(this);
        }

        /// <summary>
        /// Roles accessor
        /// </summary>
        public ArrayList Roles {
			get {return null;}
			set {}
        }

        /// <summary>
        /// Adds the role to the current user.
        /// </summary>
        /// <param name="szRole">Role Name</param>
        virtual public void AddRole(string szRole) {
            // Unused
        }

        /// <summary>
        /// Determines if the user is in the specified
        /// role.
        /// </summary>
        /// <param name="szRole"></param>
        /// <returns></returns>
        virtual public bool IsInRole(string szRole) {
			switch(szRole) {
				case ROLE_SUBMIT_TES:
					return _bpeli_PRSubmitTES;
				case ROLE_UPDATE_CL:
					return _bpeli_PRUpdateCL;
				case ROLE_USE_SERVICE_UNITS:
					return _bpeli_PRUseServiceUnits;
				case ROLE_USE_SPECIAL_SERVICES:
					return _bpeli_PRUseSpecialServices;
                case ROLE_EDIT_LISTING:
                    return _bpeli_PREditListing;
                case ROLE_LOCAL_SOURCE_DATA_ACCESS:
                    return HasLocalSourceDataAccess();
                case ROLE_AR_RERPORT_ACCESS:
                    return _bprc5_PRARReportAccess;
            }

			throw new ArgumentException("Invalid Role Specified", "Role");
        }


        /// <summary>
        /// Generate an email to the this user with
        /// the decrypted password.
        /// </summary>
        /// <param name="szMessage">Message of the email.  Expecto {0} to be replaced with the password.</param>
        /// <param name="szSubject">Subject of the Email</param>
        virtual public void EmailPassword(string szSubject, string szMessage) {
            IEncryptionProvider oEncryption = EncryptionFactory.GetEncryptionProvider();
            string szPassword = oEncryption.Decrypt(Password);

            string szMsg = string.Format(szMessage, this.Email, szPassword);
            EmailUtils.SendHtmlMail(Email, szSubject, szMsg);
        }

        virtual public void EmailPassword()
        {
            ((PRWebUserMgr)_oMgr).EmailPassword(this);
        }

        public const string PASSWORD_CHANGE = "PasswordChange.aspx?qk={0}";

        virtual public void EmailPasswordChangeLink(string szSubject, string szBody)
        {
            int iPasswordChangeExpirationHours = Utilities.GetIntConfigValue("PasswordChangeExpirationHours", 24);
            string szGuid = CreateGuid();
            string szUrl = new Custom_CaptionMgr(_oMgr).GetMeaning("BBOS", "URL") + string.Format(PASSWORD_CHANGE, szGuid);

            szBody = string.Format(szBody, szUrl, iPasswordChangeExpirationHours);

            this.prwu_PasswordChangeGuid = szGuid;
            this.prwu_PasswordChangeGuidExpirationDate = DateTime.Now.AddHours(iPasswordChangeExpirationHours);
            this.Save();

            string szMessage = GetObjectMgr().GetFormattedEmail(prwu_BBID, peli_PersonID, prwu_WebUserID, szSubject, szBody, prwu_Culture, prwu_IndustryType);

            GetObjectMgr().SendEmail(Email, szSubject, szMessage, "Send BBOS Password Change Link");
        }

        /// <summary>
        /// Creates a 16-character random alpha-numeric string to be used like a GUID
        /// </summary>
        public string CreateGuid()
        {
            var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
            var random = new Random();
            var result = new string(
                Enumerable.Repeat(chars, 16)
                          .Select(s => s[random.Next(s.Length)])
                          .ToArray());
            return result;
        }

        public int peli_PersonID {
            get {return _ipeli_PersonID;}
        }
        
 
        public string prwu_IndustryType
        {
            get { return _szIndustryType; }
            set
            {
                SetDirty(_szIndustryType, value);
                _szIndustryType = value;
            }
        }

        public bool IsTrialUser()
        {
            if (prwu_TrialExpirationDate > DateTime.MinValue)
            {
                return true;
            }
            return false;
        }

        public bool IsTrialPeriodActive()
        {
            if (prwu_TrialExpirationDate >= DateTime.Now) {
                return true;
            }

            return false;
        }

        public bool IsLumber_ADVANCED()
        {
            if (prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER && prwu_AccessLevel == PRWebUser.SECURITY_LEVEL_ADVANCED)
                return true;

            return false;
        }
        public bool IsLumber_STANDARD()
        {
            if (prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER && prwu_AccessLevel == PRWebUser.SECURITY_LEVEL_STANDARD)
                return true;

            return false;
        }

        public bool IsLumber_BASIC()
        {
            if (prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER && prwu_AccessLevel == PRWebUser.SECURITY_LEVEL_BASIC_ACCESS)
                return true;

            return false;
        }

        public bool IsLumber_BASIC_PLUS()
        {
            if (prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER && prwu_AccessLevel == PRWebUser.SECURITY_LEVEL_BASIC_PLUS)
                return true;

            return false;
        }

        public void GeneratePassword()
        {
            Password = ((PRWebUserMgr)_oMgr).GeneratePassword();
        }

        public DateTime ConvertToLocalDateTime(DateTime value)
        {
            return ConvertToLocalDateTime("Central Standard Time", value);
        }

        public DateTime ConvertToLocalDateTime(string sourceTimeZone, DateTime value)
        {
            TimeZoneInfo tszSourceTimeZone = TimeZoneInfo.FindSystemTimeZoneById(sourceTimeZone);
            DateTime temp = TimeZoneInfo.ConvertTimeToUtc(value, tszSourceTimeZone);

            TimeZoneInfo tszTargetTimeZone = TimeZoneInfo.FindSystemTimeZoneById(_szprwu_Timezone);
            return TimeZoneInfo.ConvertTimeFromUtc(temp, tszTargetTimeZone);
        }

        private bool _retreievedLocalSource = false;
        private bool _hasLocalSourceDataAccess = false;
        private string _localSourceDataAccessServiceCodes = null;
        private HashSet<Int32> _localSourceRegion = new HashSet<Int32>();
        private string _localSourceDataAccessRegionIDs = null;

        private void GetLocalSourceDataAccess()
        {
            if (_retreievedLocalSource)
            {
                return;
            }

            _localSourceDataAccessServiceCodes = ((PRWebUserMgr)_oMgr).GetLocalSourceDataAccess(_iprwu_WebUserID);
            if (!string.IsNullOrEmpty(_localSourceDataAccessServiceCodes))
            {
                _hasLocalSourceDataAccess = true;
            }

            if (_hasLocalSourceDataAccess)
            {
                _localSourceRegion = ((PRWebUserMgr)_oMgr).GetLocalSourceDataAccessRegion(_iprwu_WebUserID, _localSourceDataAccessServiceCodes);
                _localSourceDataAccessRegionIDs = String.Join<Int32>(",", _localSourceRegion);
            }

            _retreievedLocalSource = true;
        }

        public bool HasLocalSourceDataAccess() {
            GetLocalSourceDataAccess();
            return _hasLocalSourceDataAccess;
        }

        public string GetLocalSourceDataAccessServiceCodes()
        {
            GetLocalSourceDataAccess();
            return _localSourceDataAccessServiceCodes;
        }

        public string GetLocalSourceDataAccessRegionIDs()
        {
            GetLocalSourceDataAccess();
            return _localSourceDataAccessRegionIDs;
        }

        public HashSet<Int32> GetLocalSourceDataAccessRegions()
        {
            GetLocalSourceDataAccess();
            return _localSourceRegion;
        }

        private List<PageTracker> _securedPages = new List<PageTracker>();
        private List<PageTracker> _securedPagesSerailizedData = new List<PageTracker>();

        public int SecuredPageCount
        {
            get { return _securedPages.Count; }
        }

        public void LogPage(string request, string associatedID)
        {
            if (!Utilities.GetBoolConfigValue("SecurityPageAccessCheckEnabled", true))
                return;

            if (_securedPages == null)
            {
                LogError(new ApplicationException("Found null _securePages"));
                _securedPages = new List<PageTracker>();
            } else
                ExpireSecuredPages();

            if (_securedPagesSerailizedData == null)
            {
                LogError(new ApplicationException("Found null _securedPagesSerailizedData"));
                _securedPagesSerailizedData = new List<PageTracker>();
            }
            else
                ExpireSecuredPagesSerialiedData();


            PageTracker pageTracker = new PageTracker();
            pageTracker.Request = request;
            pageTracker.Accessed = DateTime.Now;
            pageTracker.AssociatedID = associatedID;

            _securedPagesSerailizedData.Add(pageTracker);

            if ((!request.ToLower().Contains("companydetails")) &&
                (!request.ToLower().Contains("persondetails")))
                return;

            _securedPages.Add(pageTracker);
           
        }

        private void ExpireSecuredPages()
        {
            DateTime expireThreshold = DateTime.Now.AddMinutes(0 - Utilities.GetIntConfigValue("SecurityPageAccessAgeThreshold", 2));
            List<PageTracker> newList = _securedPages.Where(pt => pt.Accessed >= expireThreshold).ToList();
            _securedPages = newList;
        }

        public void CheckPageAccessCount()
        {
            if (SecuredPageCount > Utilities.GetIntConfigValue("SecurityPageAccessCountThreshold", 50))
            {
                DisableForSecurity("Excessive Page Access Count");

                object[] args = { _szprwu_FirstName, 
                                  _szprwu_LastName,
                                  _szprwu_Email,
                                  SecuredPageCount,
                                  Utilities.GetIntConfigValue("SecurityPageAccessAgeThreshold", 2)};
                string msg = string.Format("BBOS user {0} {1} ({2}) has accessed BBOS {3} times in the past {4} minutes.  This user has been flagged 'Security Disabled' and cannot access BBOS until this flag is removed.", args);

                EmailUtils.SendHtmlMail(Utilities.GetConfigValue("SecurityCheckEmail", "security@bluebookservices.com"),
                                        Utilities.GetConfigValue("SecurityCheckEmailSubject", "Suspicious BBOS Activity Detected"), 
                                        msg);
            }
        }


        private void ExpireSecuredPagesSerialiedData()
        {
            DateTime expireThreshold = DateTime.Now.AddMinutes(0 - Utilities.GetIntConfigValue("SecurityPageAccessSerialiedDataAgeThreshold", 5));
            List<PageTracker> newList = _securedPagesSerailizedData.Where(pt => pt.Accessed >= expireThreshold).ToList();
            _securedPagesSerailizedData = newList;
        }

        /// <summary>
        /// We are looking for a usage pattern where the same company or person page is
        /// access repeatedly, without any other pages accessed in between, but for different
        /// record IDs.  We are looking for bots harvesting the data.
        /// </summary>
        public void CheckPageAccessForSerialiedData()
        {
            if (_securedPagesSerailizedData.Count < Utilities.GetIntConfigValue("SecurityPageAccessSerialiedDataThreshold", 10))
                return;

            int matchCount = 0;
            int index = 0;

            PageTracker previousPage = null;

            foreach(PageTracker pageTracker in _securedPagesSerailizedData)
            {
                index++;

                if (index == 1)
                {
                    previousPage = pageTracker;
                    continue;
                }

                // If it's the same page, but a different ID, then increment our count.
                // Otherwise reset the count.
                if ((pageTracker.Request.ToLower() == previousPage.Request.ToLower()) &&
                    (pageTracker.AssociatedID != previousPage.Request.ToLower()))
                    matchCount++;
                else
                    matchCount = 0;

                if (matchCount >= Utilities.GetIntConfigValue("SecurityPageAccessSerialiedDataThreshold", 10))
                {
                    DisableForSecurity("Excessive Serialized Page Access Count");

                    object[] args = { _szprwu_FirstName,
                                      _szprwu_LastName,
                                      _szprwu_Email,
                                      pageTracker.Request,
                                      matchCount,
                                      Utilities.GetIntConfigValue("SecurityPageAccessSerialiedDataAgeThreshold", 5)};

                    string msg = string.Format("BBOS user {0} {1} ({2}) has accessed the BBOS {3} page {4} times in a row in the past {5} minutes with different record IDs, without accessing any other pages.  This user has been flagged 'Security Disabled' and cannot access BBOS until this flag is removed.", args);

                    EmailUtils.SendHtmlMail(Utilities.GetConfigValue("SecurityCheckEmail", "security@bluebookservices.com"),
                                            Utilities.GetConfigValue("SecurityCheckEmailSubject", "Suspicious BBOS Activity Detected"),
                                            msg);

                    break;
                }
            }
        }

        public bool CheckDataExportCount()
        {
            return CheckDataExportCount(GetDataExportCount());
        }

        public bool CheckDataExportCount(int exportCount)
        {
            if (exportCount > Utilities.GetIntConfigValue("SecurityDataExportCountThreshold", 2000))
            {
                string userDisabledMsg = null;
                if (Utilities.GetBoolConfigValue("SecurityDataExportDisableUser", false))
                {
                    DisableForSecurity("Excessive Data Exports");
                    userDisabledMsg = "  This user has been flagged 'Security Disabled' and cannot access BBOS until this flag is removed.";
                }
                else
                {
                    userDisabledMsg = "  This user is still active in BBOS.";
                }

                object[] args = { _szprwu_FirstName,
                                  _szprwu_LastName,
                                  _szprwu_Email,
                                  exportCount,
                                  Utilities.GetIntConfigValue("SecurityDataExportAgeThreshold", 1440)};
                string msg = string.Format("BBOS user {0} {1} ({2}) has tried to export {3} unique records from BBOS with the past {4} minutes." + userDisabledMsg, args);

                EmailUtils.SendHtmlMail(Utilities.GetConfigValue("SecurityCheckEmail", "security@bluebookservices.com"),
                                        Utilities.GetConfigValue("SecurityCheckEmailSubject", "Suspicious BBOS Activity Detected"),
                                        msg);

                return true;
            }

            return false;
        }

        public int GetDataExportCount()
        {
            return ((PRWebUserMgr)_oMgr).GetDataExportCount(_iprwu_WebUserID, Utilities.GetIntConfigValue("SecurityDataExportAgeThreshold", 1440));
        }

        public int GetDataExportCount_Lumber_Current_Month()
        {
            return ((PRWebUserMgr)_oMgr).GetDataExportCount_Lumber_Current_Month(_iprwu_WebUserID);
        }
        
        public int GetDataExportCount_Company_Lumber_Current_Month()
        {
            return ((PRWebUserMgr)_oMgr).GetDataExportCount_Company_Lumber_Current_Month(_iprwu_BBID);
        }

        public int GetDataExportCount_Company_Lumber_Current_Day()
        {
            return ((PRWebUserMgr)_oMgr).GetDataExportCount_Company_Lumber_Current_Day(_iprwu_BBID);
        }

        public int GetNotesShareCompanyCount()
        {
            return ((PRWebUserMgr)_oMgr).GetNotesShareCompanyCount(_iprwu_WebUserID);
        }

        public int GetRemainingDataExportCount()
        {
            int dataExportCount = GetDataExportCount();

            if (dataExportCount > Utilities.GetIntConfigValue("SecurityDataExportCountThreshold", 2000))
            {
                return 0;
            }

            return Utilities.GetIntConfigValue("SecurityDataExportCountThreshold", 2000) - dataExportCount;
        }

       public int GetAvailableReports()
        {
            return ((PRWebUserMgr)_oMgr).GetAvailableReports(prwu_HQID);
        }

        public int GetAllocatedUnits()
        {
            return ((PRWebUserMgr)_oMgr).GetAllocatedUnits(prwu_HQID);
        }

        public string GetPrimaryMembership()
        {
            return ((PRWebUserMgr)_oMgr).GetPrimaryMembership(prwu_HQID);
        }

        /// <summary>
        /// Determines if the specified Object was recently purchased.  
        /// </summary>
        /// <param name="iObjectID"></param>
        /// <param name="szRequestType"></param>
        /// <returns></returns>
        public bool IsRecentPurchase(int iObjectID, string szRequestType)
        {
            List<Int32> lRecentPurchases = GetRecentPurchases(szRequestType);
            return lRecentPurchases.Contains(iObjectID);
        }

        /// <summary>
        /// Returns command delimited list of recent purchases
        /// </summary>
        /// <param name="szRequestType"></param>
        public List<Int32> GetRecentPurchases(string szRequestType)
        {
            _lRecentPurchases = ((PRWebUserMgr)_oMgr).GetRecentPurchases(szRequestType, prwu_HQID);
            return _lRecentPurchases;
        }

        /// <summary>
        /// Returns command delimited list of recent purchases
        /// </summary>
        public void RefreshRecentPurchases()
        {
            _lRecentPurchases = null;
        }

        public int GetWatchdogCustomCount()
        {
            return ((PRWebUserMgr)_oMgr).GetWatchdogCustomCount(_iprwu_WebUserID);
        }
        

        private void DisableForSecurity(string reason)
        {
            prwu_SecurityDisabled = true;
            prwu_SecurityDisabledDate = DateTime.Now;
            prwu_SecurityDisabledReason = reason;
            Save();
        }


        protected string _openInvoiceNbr = null;
        protected DateTime _openInvoiceDueDate;
        protected string _openInvoicePaymentURL = null;
        protected string _openInvoiceMessageCode = null;
        protected DateTime _openInvoiceSentDate;
        protected string _stripeCustomerID = null;

        public string OpenInvoiceNbr
        {
            get { return _openInvoiceNbr; }
            set { _openInvoiceNbr = value; }
        }

        public DateTime OpenInvoiceDueDate
        {
            get { return _openInvoiceDueDate; }
            set { _openInvoiceDueDate = value; }
        }

        public string OpenInvoicePaymentURL
        {
            get { return _openInvoicePaymentURL; }
            set { _openInvoicePaymentURL = value; }
        }

        public DateTime OpenInvoiceSentDate
        {
            get { return _openInvoiceSentDate; }
            set { _openInvoiceSentDate = value; }
        }
        public string StripeCustomerID
        {
            get { return _stripeCustomerID; }
            set { _stripeCustomerID = value; }
        }

        private void GetOpenInvoice()
        {
            if (OpenInvoiceNbr == null)
                ((PRWebUserMgr)_oMgr).GetOpenInvoice(_iprwu_HQID, out _openInvoiceNbr, out _openInvoiceDueDate, out _openInvoicePaymentURL, out _openInvoiceSentDate, out _stripeCustomerID);
        }

        public string GetOpenInvoiceMessageCode()
        {
            // Added a feature flag in case we continue to encounter "too many redirect" issues.
            if (!Utilities.GetBoolConfigValue("OpenInvoiceOnlinePaymentEnabled", true))
                return string.Empty;

            if ((_openInvoiceMessageCode != null) &&
                (_openInvoiceMessageCode != OPEN_INVOICE_MESSAGE_CODE_SUSPEND))
                return _openInvoiceMessageCode;

            GetOpenInvoice();

            // CHW- Used for unit testing
            // TODO:JMT for debugging
            //OpenInvoiceNbr = "x";
            //OpenInvoiceDueDate = DateTime.Today.AddDays(-31);  // Suspend
            //OpenInvoiceDueDate = DateTime.Today.AddDays(-22);  // Past Due
            //OpenInvoiceDueDate = DateTime.Today.AddDays(16); // Payment Is Due
            //OpenInvoiceDueDate = DateTime.Today.AddDays(13); // Coming Due.
            //OpenInvoicePaymentURL = "https://invoice.stripe.com/i/acct_1Mf7lAGKB453XnfL/live_YWNjdF8xTWY3bEFHS0I0NTNYbmZMLF9QZWF3SUtaWEFicE5xOVVDVUJ1OElmU2dnVGhhUWN5LDk5Nzg1MjE302004ETmuphl?s=ap;";

            // If we don't find an invoice, just return;
            if (_openInvoiceNbr == string.Empty)
                return _openInvoiceMessageCode;

            int daysUntilDue = _openInvoiceDueDate.Subtract(DateTime.Today).Days;

            if (daysUntilDue <= (0 - Utilities.GetIntConfigValue("OpenInvoiceSuspendedMsgDays", 31)))
            {
                _openInvoiceMessageCode = OPEN_INVOICE_MESSAGE_CODE_SUSPEND;
                CheckStripeHostedURL();
                return _openInvoiceMessageCode;
            }

            if (daysUntilDue <= (0 - Utilities.GetIntConfigValue("OpenInvoicePastDueMsgDays", 1)))
            {
                _openInvoiceMessageCode = OPEN_INVOICE_MESSAGE_CODE_PASTDUE;
                CheckStripeHostedURL();
                return _openInvoiceMessageCode;
            }

            if (daysUntilDue <= Utilities.GetIntConfigValue("OpenInvoiceDueMsgDays", 15))
            {
                _openInvoiceMessageCode = OPEN_INVOICE_MESSAGE_CODE_PAYMENTDUE;
                CheckStripeHostedURL();
                return _openInvoiceMessageCode;
            }

            if (daysUntilDue <= (Utilities.GetIntConfigValue("OpenInvoiceDueMsgDays", 15)) + Utilities.GetIntConfigValue("OpenInvoiceComingDueMsgDays", 14))
            {
                _openInvoiceMessageCode  = OPEN_INVOICE_MESSAGE_CODE_COMINGDUE;
                CheckStripeHostedURL();
                return _openInvoiceMessageCode;
            }

            // Not all open invoice dates return a message;
            _openInvoiceMessageCode = "";
            return _openInvoiceMessageCode;
        }

        protected void CheckStripeHostedURL()
        {
            if ((!string.IsNullOrEmpty(OpenInvoicePaymentURL)) && 
                (DateTime.Today.Subtract(_openInvoiceSentDate).TotalDays <= Utilities.GetIntConfigValue("StripeInvoiceLinkExpiration", 29)))
                return;

            string sql = string.Format(SQL_SELECT_INVOICE, _openInvoiceNbr);
            string szConnection = ConfigurationManager.ConnectionStrings["DBConnectionStringFullRights"].ConnectionString;
            SqlConnection dbConn = new SqlConnection(szConnection);

            try
            {
                dbConn.Open();
                SqlCommand cmdInvoices = new SqlCommand(sql, dbConn);
                cmdInvoices.CommandTimeout = 600;

                using (IDataReader drInvoices = cmdInvoices.ExecuteReader(CommandBehavior.Default))
                {
                    if (drInvoices.Read())
                    {
                        string stripeCustomerID = null;
                        if (drInvoices["prci2_StripeCustomerId"] != DBNull.Value)
                            stripeCustomerID = (string)drInvoices["prci2_StripeCustomerId"];

                        OpenInvoicePaymentURL = GetStripeHostedURL(Convert.ToString(_iprwu_BBID), stripeCustomerID, drInvoices);
                    }
                }

            }
            finally
            {
                dbConn.Close();
                dbConn = null;
            }
        }

        protected string GetStripeHostedURL(string customerNo, string stripeCustomerId, IDataReader drInvoices)
        {
            string szConnection = ConfigurationManager.ConnectionStrings["DBConnectionStringFullRights"].ConnectionString;
            SqlConnection dbConn = new SqlConnection(szConnection);
            try
            {
                //using (SqlConnection _dbConn = new SqlConnection(szConnection))
                //{
                    dbConn.Open();
                    int _iUserID = 0;

                    if (stripeCustomerId == null)
                    {
                        //Create a stripe customer
                        StripeError stripeCustomerError;
                        Customer stripeCustomer = Stripe.Customer_Create(customerNo,
                                                            (string)drInvoices["BillToName"],
                                                            (string)drInvoices["BillToAddress1"],
                                                            (string)drInvoices["BillToAddress2"],
                                                            (string)drInvoices["BillToCity"],
                                                            (string)drInvoices["BillToState"],
                                                            (string)drInvoices["BillToZipCode"],
                                                            "", //TODO:JMT phone from where??
                                                            (string)drInvoices["EmailAddress"],
                                                            out stripeCustomerError);

                        if (stripeCustomerError != null)
                            throw new Exception(stripeCustomerError.Message);

                        Stripe.StripeCustomerId_Update(customerNo, stripeCustomer.Id, _iUserID, dbConn);
                        stripeCustomerId = stripeCustomer.Id;
                    }

                    DateTime? nextAnniversaryDate = null;
                    if (drInvoices["prse_NextAnniversaryDate"] != DBNull.Value)
                        nextAnniversaryDate = Convert.ToDateTime(drInvoices["prse_NextAnniversaryDate"]);

                    decimal salesTaxAmt = (decimal)drInvoices["SalesTaxAmt"];

                    DataRowView[] drvDetails = GetInvoiceDetails(dbConn, (string)drInvoices["UDF_MASTER_INVOICE"]);

                    //Create stripe invoice
                    StripeError stripeInvoiceError;
                    Invoice stripeInvoice = Stripe.Invoice_Create(stripeCustomerId, customerNo, (string)drInvoices["UDF_MASTER_INVOICE"], nextAnniversaryDate, salesTaxAmt, drvDetails, out stripeInvoiceError);
                    if (stripeInvoiceError != null)
                        throw new Exception(stripeInvoiceError.Message);

                    //Create PRInvoice record
                    string szSentMethodCode = "";
                    if (!string.IsNullOrEmpty((string)drInvoices["EmailAddress"]))
                        szSentMethodCode = Stripe.PRINV_SENT_METHOD_CODE_EMAIL;
                    else if (!string.IsNullOrEmpty((string)drInvoices["FaxNo"]))
                        szSentMethodCode = Stripe.PRINV_SENT_METHOD_CODE_FAX;

                    Stripe.PRInvoice_Insert(customerNo,
                                            (string)drInvoices["UDF_MASTER_INVOICE"],
                                            szSentMethodCode,
                                            DateTime.Now,
                                            stripeInvoice.HostedInvoiceUrl,
                                            stripeInvoice.Id,
                                            _iUserID, dbConn);

                    return stripeInvoice.HostedInvoiceUrl;
               //}
            }
            finally
            {
                dbConn.Close();
                dbConn = null;
            }
        }

        protected string _invoiceNbr = string.Empty;

        protected const string SQL_SELECT_INVOICE =
            @"SELECT vBBSiMasterInvoices.*, comp_PRCommunicationLanguage, comp_PRIndustryType,
        'AttnName' = CASE WHEN (prattn_PersonID IS NULL AND prattn_CustomLine IS NULL) THEN ContactName ELSE 'Attn: ' + ISNULL(prattn_CustomLine, dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, null, pers_Suffix)) END,
                        Balance, SalesTaxAmt, Total,
                        prse_NextAnniversaryDate,
                        prci2_StripeCustomerId
                   FROM MAS_PRC.dbo.vBBSiMasterInvoices 
                        INNER JOIN Company WITH (NOLOCK) ON CAST(BillToCustomerNo As Int) = comp_CompanyID
         LEFT OUTER JOIN PRAttentionLine WITH (NOLOCK) ON prattn_CompanyID = SUBSTRING(BillToCustomerNo,2,6) AND prattn_ItemCode = 'ADVBILL' 
         LEFT OUTER JOIN vPRAddress bl WITH (NOLOCK) ON prattn_AddressID = bl.Addr_AddressId
         LEFT OUTER JOIN vPerson pers WITH (NOLOCK) ON pers.Pers_PersonId = prattn_PersonID
                        LEFT OUTER JOIN PRService ON comp_CompanyID = prse_CompanyID AND prse_Primary='Y' 
                  WHERE UDF_MASTER_INVOICE = '{0}'
                   AND (FaxNo <> '' OR EmailAddress <> '')";


        private const string  SQL_INVOICE_DETAILS =
             @"SELECT ihh.UDF_MASTER_INVOICE, ihh.CustomerNo, PRCompanySearch.prcse_FullName AS ServiceLocation, ihd.ItemCodeDesc, ExtensionAmt,
                       QuantityOrdered, ItemCodeDesc, ISNULL(prod_PRRecurring,'') IsRecognition,
                       PRCompanySearch.prcse_FullName AS ServiceLocation,
                 ISNULL(LAG(PRCompanySearch.prcse_FullName, 1) OVER(ORDER BY UDF_MASTER_INVOICE, ISNULL(T1.PrimarySort, 9999), ShipToState, ShipToCity, DetailSeqNo), '') ServiceLocation_Prev,
                       ISNULL(T1.PrimarySort, 9999) PrimarySort, ShipToState, ShipToCity, DetailSeqNo
                  FROM MAS_PRC.dbo.AR_InvoiceHistoryHeader ihh WITH (NOLOCK) 
                       INNER JOIN MAS_PRC.dbo.AR_InvoiceHistoryDetail ihd WITH (NOLOCK) ON ihh.InvoiceNo = ihd.InvoiceNo AND ihh.HeaderSeqNo = ihd.HeaderSeqNo
                     INNER JOIN PRCompanySearch WITH (NOLOCK) ON PRCompanySearch.prcse_CompanyId = CustomerNo
                       INNER JOIN CRM.dbo.Company WITH (NOLOCK) ON Comp_CompanyId = prcse_CompanyId
                       INNER JOIN CRM.dbo.vPRLocation ON comp_PRListingCityID = prci_CityID
                       LEFT OUTER JOIN NewProduct  WITH (NOLOCK) ON prod_code = ItemCode AND prod_PRRecurring='Y' AND Prod_ProductID <> 85 -- Exclude the old L100 code
                       LEFT OUTER JOIN (
                  SELECT DISTINCT CustomerNo As PrimaryCompanyID, 1 as PrimarySort
                    FROM MAS_PRC.dbo.AR_InvoiceHistoryHeader ihh WITH (NOLOCK)
                      INNER JOIN MAS_PRC.dbo.AR_InvoiceHistoryDetail ihd WITH (NOLOCK) ON ihh.InvoiceNo = ihd.InvoiceNo AND ihh.HeaderSeqNo = ihd.HeaderSeqNo 
                      INNER JOIN MAS_PRC.dbo.CI_Item ON ihd.ItemCode = CI_Item.ItemCode
                   WHERE Category2 = 'PRIMARY') T1 ON CustomerNo = PrimaryCompanyID
                 WHERE UDF_MASTER_INVOICE = @InvoiceNbr 
                   AND ExplodedKitItem <> 'C'
              ORDER BY ihh.UDF_MASTER_INVOICE, ISNULL(T1.PrimarySort, 9999), ShipToState, ShipToCity, DetailSeqNo";

        protected DataRowView[] GetInvoiceDetails(SqlConnection sqlConnection, string invoiceNumber)
        {
            try
            {
                SqlDataAdapter adapter = new SqlDataAdapter(SQL_INVOICE_DETAILS, sqlConnection);
                adapter.SelectCommand.CommandTimeout = 180;
                adapter.SelectCommand.Parameters.AddWithValue("InvoiceNbr", invoiceNumber);

                DataSet ds = new DataSet();
                adapter.Fill(ds);

                DataView dvInvoiceDetails = new DataView(ds.Tables[0]);
                dvInvoiceDetails.Sort = "UDF_MASTER_INVOICE";
                _invoiceNbr = invoiceNumber;

                DataRowView[] adrRows = dvInvoiceDetails.FindRows(invoiceNumber);

                adapter = null;
                dvInvoiceDetails = null;
                return adrRows;
            } catch (Exception eX)
            {
                var message = eX.Message;
                throw;
            }
        }

        private const string SQL_MOST_RECENT_PAYMENT_URL =
            @"SELECT TOP 1 prinv_StripePaymentURL, prinv_CreatedDate
                   FROM PRInvoice WITH (NOLOCK)
                  WHERE prinv_InvoiceNbr = @InvoiceNbr
                    AND prinv_StripePaymentURL IS NOT NULL
               ORDER BY prinv_CreatedDate DESC";

        protected string GetMostRecentStripePaymentURL(SqlConnection sqlConnection, string invoiceNumber)
        {
            SqlCommand cmdMostRecentURL = new SqlCommand(SQL_MOST_RECENT_PAYMENT_URL, sqlConnection);
            cmdMostRecentURL.Parameters.AddWithValue("InvoiceNbr", invoiceNumber);

            using (IDataReader reader = cmdMostRecentURL.ExecuteReader(CommandBehavior.Default))
            {
                if (reader.Read())
                {
                    string paymentURL = reader.GetString(0);
                    DateTime createdDateTime = reader.GetDateTime(1);

                    if (DateTime.Today.Subtract(createdDateTime).TotalDays < Utilities.GetIntConfigValue("StripeInvoiceLinkExpiration", 28))
                        return paymentURL;
                }
            }

            return null;
        }


        [Serializable]
        private class PageTracker
        {
            public string Request;
            public DateTime Accessed;
            public string AssociatedID;
        }
    }
}
