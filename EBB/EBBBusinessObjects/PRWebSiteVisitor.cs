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

 ClassName: PRWebSiteVisitor
 Description:	

 Notes:	Created By TSI Class Generator on 4/7/2014 8:51:54 AM

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using TSI.Arch;
using TSI.BusinessObjects;

namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Provides the functionality for the PRWebSiteVisitor.
    /// </summary>
    public partial class PRWebSiteVisitor : EBBObject, IPRWebSiteVisitor
    {
        protected DateTime	_prwsv_CreatedDate;
        protected DateTime	_prwsv_TimeStamp;
        protected DateTime	_prwsv_UpdatedDate;
        protected int		_prwsv_CreatedBy;
        protected int		_prwsv_Deleted;
        protected int		_prwsv_Secterr;
        protected int		_prwsv_UpdatedBy;
        protected int		_prwsv_WebSiteVisitorID;
        protected int		_prwsv_WorkflowId;
        protected int       _prwsv_CompanyID;
        protected string    _prwsv_PrimaryFunction;
        protected string    _prwsv_RequestsMembershipInfo;
        protected string	_prwsv_CompanyName;
        protected string	_prwsv_SubmitterEmail;
        protected string    _prwsv_SubmitterIPAddress;
        protected string    _prwsv_IndustryType;
        protected string    _prwsv_Referrer;
        protected string    _prwsv_SubmitterName;
        protected string    _prwsv_SubmitterPhone;
        protected string    _prwsv_State;
        protected string    _prwsv_Country;

        /// <summary>
        /// Constructor
        /// </summary>
        public PRWebSiteVisitor() {}

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
                _oKeyValues.Add(prwsv_WebSiteVisitorID);
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
            prwsv_WebSiteVisitorID = 0;
        }

        /// <summary>
        /// Sets the key values for this object based
        /// on the specified list of values.  The list of
        /// values must be in the same order the keys are
        /// defined in GetKeyValues();
        /// </summary>
        /// <param name="oKeyValues">IList</param>
        override public void SetKeyValues(IList oKeyValues) {
            prwsv_WebSiteVisitorID = Convert.ToInt32(oKeyValues[0]);
        }

        /// <summary>
        /// Accessor for the prwsv_CreatedDate property.
        /// </summary>
        public DateTime prwsv_CreatedDate {
            get {return _prwsv_CreatedDate;}
            set {SetDirty(_prwsv_CreatedDate, value);
                 _prwsv_CreatedDate = value;}
        }

        /// <summary>
        /// Accessor for the prwsv_TimeStamp property.
        /// </summary>
        public DateTime prwsv_TimeStamp {
            get {return _prwsv_TimeStamp;}
            set {SetDirty(_prwsv_TimeStamp, value);
                 _prwsv_TimeStamp = value;}
        }

        /// <summary>
        /// Accessor for the prwsv_UpdatedDate property.
        /// </summary>
        public DateTime prwsv_UpdatedDate {
            get {return _prwsv_UpdatedDate;}
            set {SetDirty(_prwsv_UpdatedDate, value);
                 _prwsv_UpdatedDate = value;}
        }

        /// <summary>
        /// Accessor for the prwsv_CreatedBy property.
        /// </summary>
        public int prwsv_CreatedBy {
            get {return _prwsv_CreatedBy;}
            set {SetDirty(_prwsv_CreatedBy, value);
                 _prwsv_CreatedBy = value;}
        }

        /// <summary>
        /// Accessor for the prwsv_Deleted property.
        /// </summary>
        public int prwsv_Deleted {
            get {return _prwsv_Deleted;}
            set {SetDirty(_prwsv_Deleted, value);
                 _prwsv_Deleted = value;}
        }

        /// <summary>
        /// Accessor for the prwsv_Secterr property.
        /// </summary>
        public int prwsv_Secterr {
            get {return _prwsv_Secterr;}
            set {SetDirty(_prwsv_Secterr, value);
                 _prwsv_Secterr = value;}
        }

        /// <summary>
        /// Accessor for the prwsv_UpdatedBy property.
        /// </summary>
        public int prwsv_UpdatedBy {
            get {return _prwsv_UpdatedBy;}
            set {SetDirty(_prwsv_UpdatedBy, value);
                 _prwsv_UpdatedBy = value;}
        }

        /// <summary>
        /// Accessor for the prwsv_WebSiteVisitorID property.
        /// </summary>
        public int prwsv_WebSiteVisitorID {
            get {return _prwsv_WebSiteVisitorID;}
            set {SetDirty(_prwsv_WebSiteVisitorID, value);
                 _prwsv_WebSiteVisitorID = value;}
        }

        /// <summary>
        /// Accessor for the prwsv_WorkflowId property.
        /// </summary>
        public int prwsv_WorkflowId {
            get {return _prwsv_WorkflowId;}
            set {SetDirty(_prwsv_WorkflowId, value);
                 _prwsv_WorkflowId = value;}
        }

        public int prwsv_CompanyID
        {
            get { return _prwsv_CompanyID; }
            set
            {
                SetDirty(_prwsv_CompanyID, value);
                _prwsv_CompanyID = value;
            }
        }

        /// <summary>
        /// Accessor for the prwsv_PrimaryFunction property.
        /// </summary>
        public string prwsv_PrimaryFunction {
            get {return _prwsv_PrimaryFunction;}
            set {SetDirty(_prwsv_PrimaryFunction, value);
                 _prwsv_PrimaryFunction = value;}
        }

        public string prwsv_RequestsMembershipInfo
        {
            get { return _prwsv_RequestsMembershipInfo; }
            set
            {
                SetDirty(_prwsv_RequestsMembershipInfo, value);
                _prwsv_RequestsMembershipInfo = value;
            }
        }

        /// <summary>
        /// Accessor for the prwsv_CompanyName property.
        /// </summary>
        public string prwsv_CompanyName {
            get {return _prwsv_CompanyName;}
            set {SetDirty(_prwsv_CompanyName, value);
                 _prwsv_CompanyName = value;}
        }

        /// <summary>
        /// Accessor for the prwsv_SubmitterEmail property.
        /// </summary>
        public string prwsv_SubmitterEmail {
            get {return _prwsv_SubmitterEmail;}
            set {SetDirty(_prwsv_SubmitterEmail, value);
                 _prwsv_SubmitterEmail = value;}
        }

        public string prwsv_SubmitterIPAddress
        {
            get { return _prwsv_SubmitterIPAddress; }
            set
            {
                SetDirty(_prwsv_SubmitterIPAddress, value);
                _prwsv_SubmitterIPAddress = value;
            }
        }

        public string prwsv_IndustryType
        {
            get { return _prwsv_IndustryType; }
            set
            {
                SetDirty(_prwsv_IndustryType, value);
                _prwsv_IndustryType = value;
            }
        }


        public string prwsv_Referrer
        {
            get { return _prwsv_Referrer; }
            set
            {
                SetDirty(_prwsv_Referrer, value);
                _prwsv_Referrer = value;
            }
        }

        public string prwsv_SubmitterName
        {
            get { return _prwsv_SubmitterName; }
            set
            {
                SetDirty(_prwsv_SubmitterName, value);
                _prwsv_SubmitterName = value;
            }
        }

        public string prwsv_SubmitterPhone
        {
            get { return _prwsv_SubmitterPhone; }
            set
            {
                SetDirty(_prwsv_SubmitterPhone, value);
                _prwsv_SubmitterPhone = value;
            }
        }

        public string prwsv_State
        {
            get { return _prwsv_State; }
            set
            {
                SetDirty(_prwsv_State, value);
                _prwsv_State = value;
            }
        }

        public string prwsv_Country
        {
            get { return _prwsv_Country; }
            set
            {
                SetDirty(_prwsv_Country, value);
                _prwsv_Country = value;
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
                _htFieldColMapping.Add("prwsv_CreatedDate",			PRWebSiteVisitorMgr.COL_PRWSV_CREATED_DATE);
                _htFieldColMapping.Add("prwsv_TimeStamp",			PRWebSiteVisitorMgr.COL_PRWSV_TIME_STAMP);
                _htFieldColMapping.Add("prwsv_UpdatedDate",			PRWebSiteVisitorMgr.COL_PRWSV_UPDATED_DATE);
                _htFieldColMapping.Add("prwsv_CreatedBy",			PRWebSiteVisitorMgr.COL_PRWSV_CREATED_BY);
                _htFieldColMapping.Add("prwsv_Deleted",				PRWebSiteVisitorMgr.COL_PRWSV_DELETED);
                _htFieldColMapping.Add("prwsv_Secterr",				PRWebSiteVisitorMgr.COL_PRWSV_SECTERR);
                _htFieldColMapping.Add("prwsv_UpdatedBy",			PRWebSiteVisitorMgr.COL_PRWSV_UPDATED_BY);
                _htFieldColMapping.Add("prwsv_WebSiteVisitorID",	PRWebSiteVisitorMgr.COL_PRWSV_WEB_SITE_VISITOR_ID);
                _htFieldColMapping.Add("prwsv_WorkflowId",			PRWebSiteVisitorMgr.COL_PRWSV_WORKFLOW_ID);
                _htFieldColMapping.Add("prwsv_PrimaryFunction",		PRWebSiteVisitorMgr.COL_PRWSV_PRIMARY_FUNCTION);
                _htFieldColMapping.Add("prwsv_CompanyName",			PRWebSiteVisitorMgr.COL_PRWSV_COMPANY_NAME);
                _htFieldColMapping.Add("prwsv_SubmitterEmail",		PRWebSiteVisitorMgr.COL_PRWSV_SUBMITTER_EMAIL);
                _htFieldColMapping.Add("prwsv_SubmitterIPAddress",  PRWebSiteVisitorMgr.COL_PRWSV_SUBMITTER_IP_ADDRESS);
                _htFieldColMapping.Add("prwsv_CompanyID",           PRWebSiteVisitorMgr.COL_PRWSV_COMPANY_ID);
                _htFieldColMapping.Add("prwsv_IndustryType",        PRWebSiteVisitorMgr.COL_PRWSV_INDUSTRY_TYPE);
                _htFieldColMapping.Add("prwsv_Referrer",            PRWebSiteVisitorMgr.COL_PRWSV_REFERRER);
                _htFieldColMapping.Add("prwsv_RequestsMembershipInfo", PRWebSiteVisitorMgr.COL_PRWSV_REQUEST_MEMBERSHIP_INFO);
                _htFieldColMapping.Add("prwsv_SubmitterName",       PRWebSiteVisitorMgr.COL_PRWSV_SUBMITTER_NAME);
                _htFieldColMapping.Add("prwsv_SubmitterPhone",      PRWebSiteVisitorMgr.COL_PRWSV_SUBMITTER_PHONE);
                _htFieldColMapping.Add("prwsv_State",               PRWebSiteVisitorMgr.COL_PRWSV_STATE);
                _htFieldColMapping.Add("prwsv_Country",             PRWebSiteVisitorMgr.COL_PRWSV_COUNTRY);
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

            _prwsv_CreatedDate		     = _oMgr.GetDateTime(oData[PRWebSiteVisitorMgr.COL_PRWSV_CREATED_DATE]);
            _prwsv_TimeStamp		     = _oMgr.GetDateTime(oData[PRWebSiteVisitorMgr.COL_PRWSV_TIME_STAMP]);
            _prwsv_UpdatedDate		     = _oMgr.GetDateTime(oData[PRWebSiteVisitorMgr.COL_PRWSV_UPDATED_DATE]);
            _prwsv_CreatedBy		     = _oMgr.GetInt(oData[PRWebSiteVisitorMgr.COL_PRWSV_CREATED_BY]);
            //_prwsv_Deleted			 = _oMgr.GetInt(oData[PRWebSiteVisitorMgr.COL_PRWSV_DELETED]);
            //_prwsv_Secterr			 = _oMgr.GetInt(oData[PRWebSiteVisitorMgr.COL_PRWSV_SECTERR]);
            _prwsv_UpdatedBy		     = _oMgr.GetInt(oData[PRWebSiteVisitorMgr.COL_PRWSV_UPDATED_BY]);
            _prwsv_WebSiteVisitorID	    = _oMgr.GetInt(oData[PRWebSiteVisitorMgr.COL_PRWSV_WEB_SITE_VISITOR_ID]);
            //_prwsv_WorkflowId		     = _oMgr.GetInt(oData[PRWebSiteVisitorMgr.COL_PRWSV_WORKFLOW_ID]);
            _prwsv_CompanyID            = _oMgr.GetInt(oData[PRWebSiteVisitorMgr.COL_PRWSV_COMPANY_ID]);
            _prwsv_PrimaryFunction      = _oMgr.GetString(oData[PRWebSiteVisitorMgr.COL_PRWSV_PRIMARY_FUNCTION]);
            _prwsv_RequestsMembershipInfo = _oMgr.GetString(oData[PRWebSiteVisitorMgr.COL_PRWSV_REQUEST_MEMBERSHIP_INFO]);
            _prwsv_CompanyName		    = _oMgr.GetString(oData[PRWebSiteVisitorMgr.COL_PRWSV_COMPANY_NAME]);
            _prwsv_SubmitterEmail	    = _oMgr.GetString(oData[PRWebSiteVisitorMgr.COL_PRWSV_SUBMITTER_EMAIL]);
            _prwsv_SubmitterIPAddress   = _oMgr.GetString(oData[PRWebSiteVisitorMgr.COL_PRWSV_SUBMITTER_IP_ADDRESS]);
            _prwsv_IndustryType         = _oMgr.GetString(oData[PRWebSiteVisitorMgr.COL_PRWSV_INDUSTRY_TYPE]);
            _prwsv_Referrer             = _oMgr.GetString(oData[PRWebSiteVisitorMgr.COL_PRWSV_REFERRER]);
            _prwsv_SubmitterName        = _oMgr.GetString(oData[PRWebSiteVisitorMgr.COL_PRWSV_SUBMITTER_NAME]);
            _prwsv_SubmitterPhone       = _oMgr.GetString(oData[PRWebSiteVisitorMgr.COL_PRWSV_SUBMITTER_PHONE]);
            _prwsv_State                = _oMgr.GetString(oData[PRWebSiteVisitorMgr.COL_PRWSV_STATE]);
            _prwsv_Country              = _oMgr.GetString(oData[PRWebSiteVisitorMgr.COL_PRWSV_COUNTRY]);



            // Handle the audit fields
            _szCreatedUserID = _oMgr.GetString(oData[PRWebSiteVisitorMgr.COL_CREATED_USER_ID]);
            _szUpdatedUserID = _oMgr.GetString(oData[PRWebSiteVisitorMgr.COL_UPDATED_USER_ID]);
            _dtCreatedDateTime = _oMgr.GetDateTime(oData[PRWebSiteVisitorMgr.COL_CREATED_DATETIME]);
            _dtUpdatedDateTime = _oMgr.GetDateTime(oData[PRWebSiteVisitorMgr.COL_UPDATED_DATETIME]);
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
            if (iOptions != PRWebSiteVisitorMgr.OPT_LOAD_SAVE) {
                oData.Add(PRWebSiteVisitorMgr.COL_PRWSV_WEB_SITE_VISITOR_ID,	_prwsv_WebSiteVisitorID);
            }

            //oData.Add(PRWebSiteVisitorMgr.COL_PRWSV_CREATED_DATE,			_prwsv_CreatedDate);
            //oData.Add(PRWebSiteVisitorMgr.COL_PRWSV_TIME_STAMP,				_prwsv_TimeStamp);
            //oData.Add(PRWebSiteVisitorMgr.COL_PRWSV_UPDATED_DATE,			_prwsv_UpdatedDate);
            //oData.Add(PRWebSiteVisitorMgr.COL_PRWSV_CREATED_BY,				_prwsv_CreatedBy);
            //oData.Add(PRWebSiteVisitorMgr.COL_PRWSV_DELETED,				_prwsv_Deleted);
            //oData.Add(PRWebSiteVisitorMgr.COL_PRWSV_SECTERR,				_prwsv_Secterr);
            //oData.Add(PRWebSiteVisitorMgr.COL_PRWSV_UPDATED_BY,				_prwsv_UpdatedBy);
            //oData.Add(PRWebSiteVisitorMgr.COL_PRWSV_WORKFLOW_ID,			_prwsv_WorkflowId);
            oData.Add(PRWebSiteVisitorMgr.COL_PRWSV_PRIMARY_FUNCTION,		_prwsv_PrimaryFunction);
            oData.Add(PRWebSiteVisitorMgr.COL_PRWSV_COMPANY_NAME,			_prwsv_CompanyName);
            oData.Add(PRWebSiteVisitorMgr.COL_PRWSV_SUBMITTER_EMAIL,		_prwsv_SubmitterEmail);
            oData.Add(PRWebSiteVisitorMgr.COL_PRWSV_SUBMITTER_IP_ADDRESS,   _prwsv_SubmitterIPAddress);
            oData.Add(PRWebSiteVisitorMgr.COL_PRWSV_COMPANY_ID,             _prwsv_CompanyID);
            oData.Add(PRWebSiteVisitorMgr.COL_PRWSV_INDUSTRY_TYPE,          _prwsv_IndustryType);
            oData.Add(PRWebSiteVisitorMgr.COL_PRWSV_REFERRER,               _prwsv_Referrer);
            oData.Add(PRWebSiteVisitorMgr.COL_PRWSV_REQUEST_MEMBERSHIP_INFO, _prwsv_RequestsMembershipInfo);
            oData.Add(PRWebSiteVisitorMgr.COL_PRWSV_SUBMITTER_NAME,         _prwsv_SubmitterName);
            oData.Add(PRWebSiteVisitorMgr.COL_PRWSV_SUBMITTER_PHONE,        _prwsv_SubmitterPhone);
            oData.Add(PRWebSiteVisitorMgr.COL_PRWSV_STATE,                  _prwsv_State);
            oData.Add(PRWebSiteVisitorMgr.COL_PRWSV_COUNTRY,                _prwsv_Country);

            // Handle the audit fields
            oData.Add(PRWebSiteVisitorMgr.COL_CREATED_USER_ID, _szCreatedUserID);
            oData.Add(PRWebSiteVisitorMgr.COL_UPDATED_USER_ID, _szUpdatedUserID);
            oData.Add(PRWebSiteVisitorMgr.COL_CREATED_DATETIME, _dtCreatedDateTime);
            oData.Add(PRWebSiteVisitorMgr.COL_UPDATED_DATETIME, _dtUpdatedDateTime);
        }
        #endregion

    }
}
