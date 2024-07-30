/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2014

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Blue Book Services, Inc..  Contact
 by e-mail at chris@wallsfamily.com

 ClassName: PRGetListedRequest
 Description:	

 Notes:	Created By TSI Class Generator on 3/17/2014 2:42:33 PM

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using TSI.Arch;
using TSI.BusinessObjects;

namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Provides the functionality for the PRGetListedRequest.
    /// </summary>
    public partial class PRGetListedRequest : EBBObject, IPRGetListedRequest
    {
        protected DateTime	_prglr_CreatedDate;
        protected DateTime	_prglr_TimeStamp;
        protected DateTime	_prglr_UpdatedDate;
        protected int		_prglr_CreatedBy;
        protected int       _prglr_UpdatedBy;
        protected int		_prglr_GetListedRequestID;
        protected string    _prglr_HowLearned;
        protected string    _prglr_PrimaryFunction;
        protected string    _prglr_RequestsMembershipInfo;
        protected string    _prglr_SubmitterIsOwner;
        protected string	_prglr_City;
        protected string	_prglr_CompanyEmail;
        protected string	_prglr_CompanyName;
        protected string	_prglr_CompanyPhone;
        protected string	_prglr_CompanyWebsite;
        protected string	_prglr_Country;
        protected string	_prglr_PostalCode;
        protected string	_prglr_Principals;
        protected string	_prglr_State;
        protected string	_prglr_Street1;
        protected string	_prglr_Street2;
        protected string	_prglr_SubmitterEmail;
        protected string	_prglr_SubmitterIPAddress;
        protected string	_prglr_SubmitterName;
        protected string	_prglr_SubmitterPhone;
        protected string    _prglr_IndustryType;

        /// <summary>
        /// Constructor
        /// </summary>
        public PRGetListedRequest() {}

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
                _oKeyValues.Add(prglr_GetListedRequestID);
            }
	          return _oKeyValues;
        }

        /// <summary>
        /// Sets the key values for this object based
        /// on the specified list of values.  The list of
        /// values must be in the same order the keys are
        /// defined in GetKeyValues()
        /// </summary>
        override public void ClearKeyValues() {
            prglr_GetListedRequestID = 0;
        }

        /// <summary>
        /// Sets the key values for this object based
        /// on the specified list of values.  The list of
        /// values must be in the same order the keys are
        /// defined in GetKeyValues();
        /// </summary>
        /// <param name="oKeyValues">IList</param>
        override public void SetKeyValues(IList oKeyValues) {
            prglr_GetListedRequestID = Convert.ToInt32(oKeyValues[0]);
        }

        /// <summary>
        /// Accessor for the prglr_CreatedDate property.
        /// </summary>
        public DateTime prglr_CreatedDate {
            get {return _prglr_CreatedDate;}
            set {SetDirty(_prglr_CreatedDate, value);
                 _prglr_CreatedDate = value;}
        }

        /// <summary>
        /// Accessor for the prglr_TimeStamp property.
        /// </summary>
        public DateTime prglr_TimeStamp {
            get {return _prglr_TimeStamp;}
            set {SetDirty(_prglr_TimeStamp, value);
                 _prglr_TimeStamp = value;}
        }

        /// <summary>
        /// Accessor for the prglr_UpdatedDate property.
        /// </summary>
        public DateTime prglr_UpdatedDate {
            get {return _prglr_UpdatedDate;}
            set {SetDirty(_prglr_UpdatedDate, value);
                 _prglr_UpdatedDate = value;}
        }

        /// <summary>
        /// Accessor for the prglr_CreatedBy property.
        /// </summary>
        public int prglr_CreatedBy {
            get {return _prglr_CreatedBy;}
            set {SetDirty(_prglr_CreatedBy, value);
                 _prglr_CreatedBy = value;}
        }


        /// <summary>
        /// Accessor for the prglr_GetListedRequestID property.
        /// </summary>
        public int prglr_GetListedRequestID {
            get {return _prglr_GetListedRequestID;}
            set {SetDirty(_prglr_GetListedRequestID, value);
                 _prglr_GetListedRequestID = value;}
        }

        /// <summary>
        /// Accessor for the prglr_UpdatedBy property.
        /// </summary>
        public int prglr_UpdatedBy {
            get {return _prglr_UpdatedBy;}
            set {SetDirty(_prglr_UpdatedBy, value);
                 _prglr_UpdatedBy = value;}
        }

        /// <summary>
        /// Accessor for the prglr_HowLearned property.
        /// </summary>
        public string prglr_HowLearned {
            get {return _prglr_HowLearned;}
            set {SetDirty(_prglr_HowLearned, value);
                 _prglr_HowLearned = value;}
        }

        /// <summary>
        /// Accessor for the prglr_PrimaryFunction property.
        /// </summary>
        public string prglr_PrimaryFunction
        {
            get {return _prglr_PrimaryFunction;}
            set {SetDirty(_prglr_PrimaryFunction, value);
                 _prglr_PrimaryFunction = value;}
        }

        /// <summary>
        /// Accessor for the prglr_RequestsMembershipInfo property.
        /// </summary>
        public string prglr_RequestsMembershipInfo
        {
            get {return _prglr_RequestsMembershipInfo;}
            set {SetDirty(_prglr_RequestsMembershipInfo, value);
                 _prglr_RequestsMembershipInfo = value;}
        }

        /// <summary>
        /// Accessor for the prglr_SubmitterIsOwner property.
        /// </summary>
        public string prglr_SubmitterIsOwner
        {
            get {return _prglr_SubmitterIsOwner;}
            set {SetDirty(_prglr_SubmitterIsOwner, value);
                 _prglr_SubmitterIsOwner = value;}
        }

        /// <summary>
        /// Accessor for the prglr_City property.
        /// </summary>
        public string prglr_City {
            get {return _prglr_City;}
            set {SetDirty(_prglr_City, value);
                 _prglr_City = value;}
        }

        /// <summary>
        /// Accessor for the prglr_CompanyEmail property.
        /// </summary>
        public string prglr_CompanyEmail {
            get {return _prglr_CompanyEmail;}
            set {SetDirty(_prglr_CompanyEmail, value);
                 _prglr_CompanyEmail = value;}
        }

        /// <summary>
        /// Accessor for the prglr_CompanyName property.
        /// </summary>
        public string prglr_CompanyName {
            get {return _prglr_CompanyName;}
            set {SetDirty(_prglr_CompanyName, value);
                 _prglr_CompanyName = value;}
        }

        /// <summary>
        /// Accessor for the prglr_CompanyPhone property.
        /// </summary>
        public string prglr_CompanyPhone {
            get {return _prglr_CompanyPhone;}
            set {SetDirty(_prglr_CompanyPhone, value);
                 _prglr_CompanyPhone = value;}
        }

        /// <summary>
        /// Accessor for the prglr_CompanyWebsite property.
        /// </summary>
        public string prglr_CompanyWebsite {
            get {return _prglr_CompanyWebsite;}
            set {SetDirty(_prglr_CompanyWebsite, value);
                 _prglr_CompanyWebsite = value;}
        }

        /// <summary>
        /// Accessor for the prglr_Country property.
        /// </summary>
        public string prglr_Country {
            get {return _prglr_Country;}
            set {SetDirty(_prglr_Country, value);
                 _prglr_Country = value;}
        }

        /// <summary>
        /// Accessor for the prglr_PostalCode property.
        /// </summary>
        public string prglr_PostalCode {
            get {return _prglr_PostalCode;}
            set {SetDirty(_prglr_PostalCode, value);
                 _prglr_PostalCode = value;}
        }

        /// <summary>
        /// Accessor for the prglr_Principals property.
        /// </summary>
        public string prglr_Principals {
            get {return _prglr_Principals;}
            set {SetDirty(_prglr_Principals, value);
                 _prglr_Principals = value;}
        }

        /// <summary>
        /// Accessor for the prglr_State property.
        /// </summary>
        public string prglr_State {
            get {return _prglr_State;}
            set {SetDirty(_prglr_State, value);
                 _prglr_State = value;}
        }

        /// <summary>
        /// Accessor for the prglr_Street1 property.
        /// </summary>
        public string prglr_Street1 {
            get {return _prglr_Street1;}
            set {SetDirty(_prglr_Street1, value);
                 _prglr_Street1 = value;}
        }

        /// <summary>
        /// Accessor for the prglr_Street2 property.
        /// </summary>
        public string prglr_Street2 {
            get {return _prglr_Street2;}
            set {SetDirty(_prglr_Street2, value);
                 _prglr_Street2 = value;}
        }

        /// <summary>
        /// Accessor for the prglr_SubmitterEmail property.
        /// </summary>
        public string prglr_SubmitterEmail {
            get {return _prglr_SubmitterEmail;}
            set {SetDirty(_prglr_SubmitterEmail, value);
                 _prglr_SubmitterEmail = value;}
        }

        /// <summary>
        /// Accessor for the prglr_SubmitterIPAddress property.
        /// </summary>
        public string prglr_SubmitterIPAddress {
            get {return _prglr_SubmitterIPAddress;}
            set {SetDirty(_prglr_SubmitterIPAddress, value);
                 _prglr_SubmitterIPAddress = value;}
        }

        /// <summary>
        /// Accessor for the prglr_SubmitterName property.
        /// </summary>
        public string prglr_SubmitterName {
            get {return _prglr_SubmitterName;}
            set {SetDirty(_prglr_SubmitterName, value);
                 _prglr_SubmitterName = value;}
        }

        /// <summary>
        /// Accessor for the prglr_SubmitterPhone property.
        /// </summary>
        public string prglr_SubmitterPhone {
            get {return _prglr_SubmitterPhone;}
            set {SetDirty(_prglr_SubmitterPhone, value);
                 _prglr_SubmitterPhone = value;}
        }

        public string prglr_IndustryType
        {
            get { return _prglr_IndustryType; }
            set
            {
                SetDirty(_prglr_IndustryType, value);
                _prglr_IndustryType = value;
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
                _htFieldColMapping.Add("prglr_CreatedDate",				PRGetListedRequestMgr.COL_PRGLR_CREATED_DATE);
                _htFieldColMapping.Add("prglr_TimeStamp",				PRGetListedRequestMgr.COL_PRGLR_TIME_STAMP);
                _htFieldColMapping.Add("prglr_UpdatedDate",				PRGetListedRequestMgr.COL_PRGLR_UPDATED_DATE);
                _htFieldColMapping.Add("prglr_CreatedBy",				PRGetListedRequestMgr.COL_PRGLR_CREATED_BY);
                _htFieldColMapping.Add("prglr_GetListedRequestID",		PRGetListedRequestMgr.COL_PRGLR_GET_LISTED_REQUEST_ID);
                _htFieldColMapping.Add("prglr_UpdatedBy",				PRGetListedRequestMgr.COL_PRGLR_UPDATED_BY);
                _htFieldColMapping.Add("prglr_HowLearned",				PRGetListedRequestMgr.COL_PRGLR_HOW_LEARNED);
                _htFieldColMapping.Add("prglr_PrimaryFunction",			PRGetListedRequestMgr.COL_PRGLR_PRIMARY_FUNCTION);
                _htFieldColMapping.Add("prglr_RequestsMembershipInfo",	PRGetListedRequestMgr.COL_PRGLR_REQUESTS_MEMBERSHIP_INFO);
                _htFieldColMapping.Add("prglr_SubmitterIsOwner",		PRGetListedRequestMgr.COL_PRGLR_SUBMITTER_IS_OWNER);
                _htFieldColMapping.Add("prglr_City",					PRGetListedRequestMgr.COL_PRGLR_CITY);
                _htFieldColMapping.Add("prglr_CompanyEmail",			PRGetListedRequestMgr.COL_PRGLR_COMPANY_EMAIL);
                _htFieldColMapping.Add("prglr_CompanyName",				PRGetListedRequestMgr.COL_PRGLR_COMPANY_NAME);
                _htFieldColMapping.Add("prglr_CompanyPhone",			PRGetListedRequestMgr.COL_PRGLR_COMPANY_PHONE);
                _htFieldColMapping.Add("prglr_CompanyWebsite",			PRGetListedRequestMgr.COL_PRGLR_COMPANY_WEBSITE);
                _htFieldColMapping.Add("prglr_Country",					PRGetListedRequestMgr.COL_PRGLR_COUNTRY);
                _htFieldColMapping.Add("prglr_PostalCode",				PRGetListedRequestMgr.COL_PRGLR_POSTAL_CODE);
                _htFieldColMapping.Add("prglr_Principals",				PRGetListedRequestMgr.COL_PRGLR_PRINCIPALS);
                _htFieldColMapping.Add("prglr_State",					PRGetListedRequestMgr.COL_PRGLR_STATE);
                _htFieldColMapping.Add("prglr_Street1",					PRGetListedRequestMgr.COL_PRGLR_STREET1);
                _htFieldColMapping.Add("prglr_Street2",					PRGetListedRequestMgr.COL_PRGLR_STREET2);
                _htFieldColMapping.Add("prglr_SubmitterEmail",			PRGetListedRequestMgr.COL_PRGLR_SUBMITTER_EMAIL);
                _htFieldColMapping.Add("prglr_SubmitterIPAddress",		PRGetListedRequestMgr.COL_PRGLR_SUBMITTER_IPADDRESS);
                _htFieldColMapping.Add("prglr_SubmitterName",			PRGetListedRequestMgr.COL_PRGLR_SUBMITTER_NAME);
                _htFieldColMapping.Add("prglr_SubmitterPhone",			PRGetListedRequestMgr.COL_PRGLR_SUBMITTER_PHONE);
                _htFieldColMapping.Add("prglr_IndustryType",            PRGetListedRequestMgr.COL_PRGLR_INDUSTRY_TYPE);
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

            _prglr_GetListedRequestID		 = _oMgr.GetInt(oData[PRGetListedRequestMgr.COL_PRGLR_GET_LISTED_REQUEST_ID]);
            _prglr_HowLearned                = _oMgr.GetString(oData[PRGetListedRequestMgr.COL_PRGLR_HOW_LEARNED]);
            _prglr_PrimaryFunction			 = _oMgr.GetString(oData[PRGetListedRequestMgr.COL_PRGLR_PRIMARY_FUNCTION]);
            _prglr_RequestsMembershipInfo	 = _oMgr.GetString(oData[PRGetListedRequestMgr.COL_PRGLR_REQUESTS_MEMBERSHIP_INFO]);
            _prglr_SubmitterIsOwner			 = _oMgr.GetString(oData[PRGetListedRequestMgr.COL_PRGLR_SUBMITTER_IS_OWNER]);
            _prglr_City						 = _oMgr.GetString(oData[PRGetListedRequestMgr.COL_PRGLR_CITY]);
            _prglr_CompanyEmail				 = _oMgr.GetString(oData[PRGetListedRequestMgr.COL_PRGLR_COMPANY_EMAIL]);
            _prglr_CompanyName				 = _oMgr.GetString(oData[PRGetListedRequestMgr.COL_PRGLR_COMPANY_NAME]);
            _prglr_CompanyPhone				 = _oMgr.GetString(oData[PRGetListedRequestMgr.COL_PRGLR_COMPANY_PHONE]);
            _prglr_CompanyWebsite			 = _oMgr.GetString(oData[PRGetListedRequestMgr.COL_PRGLR_COMPANY_WEBSITE]);
            _prglr_Country					 = _oMgr.GetString(oData[PRGetListedRequestMgr.COL_PRGLR_COUNTRY]);
            _prglr_PostalCode				 = _oMgr.GetString(oData[PRGetListedRequestMgr.COL_PRGLR_POSTAL_CODE]);
            _prglr_Principals				 = _oMgr.GetString(oData[PRGetListedRequestMgr.COL_PRGLR_PRINCIPALS]);
            _prglr_State					 = _oMgr.GetString(oData[PRGetListedRequestMgr.COL_PRGLR_STATE]);
            _prglr_Street1					 = _oMgr.GetString(oData[PRGetListedRequestMgr.COL_PRGLR_STREET1]);
            _prglr_Street2					 = _oMgr.GetString(oData[PRGetListedRequestMgr.COL_PRGLR_STREET2]);
            _prglr_SubmitterEmail			 = _oMgr.GetString(oData[PRGetListedRequestMgr.COL_PRGLR_SUBMITTER_EMAIL]);
            _prglr_SubmitterIPAddress		 = _oMgr.GetString(oData[PRGetListedRequestMgr.COL_PRGLR_SUBMITTER_IPADDRESS]);
            _prglr_SubmitterName			 = _oMgr.GetString(oData[PRGetListedRequestMgr.COL_PRGLR_SUBMITTER_NAME]);
            _prglr_SubmitterPhone			 = _oMgr.GetString(oData[PRGetListedRequestMgr.COL_PRGLR_SUBMITTER_PHONE]);
            _prglr_IndustryType              = _oMgr.GetString(oData[PRGetListedRequestMgr.COL_PRGLR_INDUSTRY_TYPE]);


            // Handle the audit fields
            _szCreatedUserID = _oMgr.GetString(oData[PRGetListedRequestMgr.COL_CREATED_USER_ID]);
            _szUpdatedUserID = _oMgr.GetString(oData[PRGetListedRequestMgr.COL_UPDATED_USER_ID]);
            _dtCreatedDateTime = _oMgr.GetDateTime(oData[PRGetListedRequestMgr.COL_CREATED_DATETIME]);
            _dtUpdatedDateTime = _oMgr.GetDateTime(oData[PRGetListedRequestMgr.COL_UPDATED_DATETIME]);
            _prglr_TimeStamp = _oMgr.GetDateTime(oData[PRGetListedRequestMgr.COL_TIMESTAMP]);
        }

        /// <summary>
        /// Populates the specified Dictionary from the Object.
        /// </summary>
        /// <param name="oData">Dictionary of Data</param>
        /// <param name="iOptions">Unload Option</param>
        /// <returns>IDictionary</returns>
        override public void UnloadObject(IDictionary oData, int iOptions) {
            base.UnloadObject(oData, iOptions);

            // If we're saving this object, don't include the
            // key as part of the data since we use an
            // identity field.
            if (iOptions != PRGetListedRequestMgr.OPT_LOAD_SAVE) {
                oData.Add(PRGetListedRequestMgr.COL_PRGLR_GET_LISTED_REQUEST_ID,	_prglr_GetListedRequestID);
            }

            oData.Add(PRGetListedRequestMgr.COL_PRGLR_HOW_LEARNED,				_prglr_HowLearned);
            oData.Add(PRGetListedRequestMgr.COL_PRGLR_PRIMARY_FUNCTION,			_prglr_PrimaryFunction);
            oData.Add(PRGetListedRequestMgr.COL_PRGLR_REQUESTS_MEMBERSHIP_INFO,	_prglr_RequestsMembershipInfo);
            oData.Add(PRGetListedRequestMgr.COL_PRGLR_SUBMITTER_IS_OWNER,		_prglr_SubmitterIsOwner);
            oData.Add(PRGetListedRequestMgr.COL_PRGLR_CITY,						_prglr_City);
            oData.Add(PRGetListedRequestMgr.COL_PRGLR_COMPANY_EMAIL,			_prglr_CompanyEmail);
            oData.Add(PRGetListedRequestMgr.COL_PRGLR_COMPANY_NAME,				_prglr_CompanyName);
            oData.Add(PRGetListedRequestMgr.COL_PRGLR_COMPANY_PHONE,			_prglr_CompanyPhone);
            oData.Add(PRGetListedRequestMgr.COL_PRGLR_COMPANY_WEBSITE,			_prglr_CompanyWebsite);
            oData.Add(PRGetListedRequestMgr.COL_PRGLR_COUNTRY,					_prglr_Country);
            oData.Add(PRGetListedRequestMgr.COL_PRGLR_POSTAL_CODE,				_prglr_PostalCode);
            oData.Add(PRGetListedRequestMgr.COL_PRGLR_PRINCIPALS,				_prglr_Principals);
            oData.Add(PRGetListedRequestMgr.COL_PRGLR_STATE,					_prglr_State);
            oData.Add(PRGetListedRequestMgr.COL_PRGLR_STREET1,					_prglr_Street1);
            oData.Add(PRGetListedRequestMgr.COL_PRGLR_STREET2,					_prglr_Street2);
            oData.Add(PRGetListedRequestMgr.COL_PRGLR_SUBMITTER_EMAIL,			_prglr_SubmitterEmail);
            oData.Add(PRGetListedRequestMgr.COL_PRGLR_SUBMITTER_IPADDRESS,		_prglr_SubmitterIPAddress);
            oData.Add(PRGetListedRequestMgr.COL_PRGLR_SUBMITTER_NAME,			_prglr_SubmitterName);
            oData.Add(PRGetListedRequestMgr.COL_PRGLR_SUBMITTER_PHONE,			_prglr_SubmitterPhone);
            oData.Add(PRGetListedRequestMgr.COL_PRGLR_INDUSTRY_TYPE,            _prglr_IndustryType);

            // Handle the audit fields
            oData.Add(PRGetListedRequestMgr.COL_CREATED_USER_ID, _szCreatedUserID);
            oData.Add(PRGetListedRequestMgr.COL_UPDATED_USER_ID, _szUpdatedUserID);
            oData.Add(PRGetListedRequestMgr.COL_CREATED_DATETIME, _dtCreatedDateTime);
            oData.Add(PRGetListedRequestMgr.COL_UPDATED_DATETIME, _dtUpdatedDateTime);
            oData.Add(PRGetListedRequestMgr.COL_TIMESTAMP, _prglr_TimeStamp);
        }
        #endregion

    }
}
