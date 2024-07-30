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

 ClassName: PRWebUserCustomData
 Description:	

 Notes:	Created By TSI Class Generator on 7/18/2014 11:35:00 AM

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using TSI.Arch;
using TSI.BusinessObjects;

namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Provides the functionality for the PRWebUserCustomData.
    /// </summary>
    public partial class PRWebUserCustomData : EBBObject, IPRWebUserCustomData
    {
        protected DateTime	_prwucd_CreatedDate;
        protected DateTime	_prwucd_TimeStamp;
        protected DateTime	_prwucd_UpdatedDate;
        protected int		_prwucd_AssociatedID;
        protected int		_prwucd_CompanyID;
        protected int		_prwucd_CreatedBy;
        protected int		_prwucd_CustomDataID;
        protected int		_prwucd_Deleted;
        protected int		_prwucd_HQID;
        protected int		_prwucd_Secterr;
        protected int		_prwucd_sequence;
        protected int		_prwucd_UpdatedBy;
        protected int		_prwucd_WebUserCustomFieldID;
        protected int		_prwucd_WebUserCustomFieldLookupID;
        protected int		_prwucd_WebUserID;
        protected int		_prwucd_WorkflowId;
        protected object	_prwucd_AssociatedType;
        protected object	_prwucd_LabelCode;
        protected string	_prwucd_Value;

        /// <summary>
        /// Constructor
        /// </summary>
        public PRWebUserCustomData() {}

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
                _oKeyValues.Add(prwucd_CustomDataID);
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
            prwucd_CustomDataID = 0;
        }

        /// <summary>
        /// Sets the key values for this object based
        /// on the specified list of values.  The list of
        /// values must be in the same order the keys are
        /// defined in GetKeyValues();
        /// </summary>
        /// <param name="oKeyValues">IList</param>
        override public void SetKeyValues(IList oKeyValues) {
            prwucd_CustomDataID = Convert.ToInt32(oKeyValues[0]);
        }

        /// <summary>
        /// Accessor for the prwucd_CreatedDate property.
        /// </summary>
        public DateTime prwucd_CreatedDate {
            get {return _prwucd_CreatedDate;}
            set {SetDirty(_prwucd_CreatedDate, value);
                 _prwucd_CreatedDate = value;}
        }

        /// <summary>
        /// Accessor for the prwucd_TimeStamp property.
        /// </summary>
        public DateTime prwucd_TimeStamp {
            get {return _prwucd_TimeStamp;}
            set {SetDirty(_prwucd_TimeStamp, value);
                 _prwucd_TimeStamp = value;}
        }

        /// <summary>
        /// Accessor for the prwucd_UpdatedDate property.
        /// </summary>
        public DateTime prwucd_UpdatedDate {
            get {return _prwucd_UpdatedDate;}
            set {SetDirty(_prwucd_UpdatedDate, value);
                 _prwucd_UpdatedDate = value;}
        }

        /// <summary>
        /// Accessor for the prwucd_AssociatedID property.
        /// </summary>
        public int prwucd_AssociatedID {
            get {return _prwucd_AssociatedID;}
            set {SetDirty(_prwucd_AssociatedID, value);
                 _prwucd_AssociatedID = value;}
        }

        /// <summary>
        /// Accessor for the prwucd_CompanyID property.
        /// </summary>
        public int prwucd_CompanyID {
            get {return _prwucd_CompanyID;}
            set {SetDirty(_prwucd_CompanyID, value);
                 _prwucd_CompanyID = value;}
        }

        /// <summary>
        /// Accessor for the prwucd_CreatedBy property.
        /// </summary>
        public int prwucd_CreatedBy {
            get {return _prwucd_CreatedBy;}
            set {SetDirty(_prwucd_CreatedBy, value);
                 _prwucd_CreatedBy = value;}
        }

        /// <summary>
        /// Accessor for the prwucd_CustomDataID property.
        /// </summary>
        public int prwucd_CustomDataID {
            get {return _prwucd_CustomDataID;}
            set {SetDirty(_prwucd_CustomDataID, value);
                 _prwucd_CustomDataID = value;}
        }

        /// <summary>
        /// Accessor for the prwucd_Deleted property.
        /// </summary>
        public int prwucd_Deleted {
            get {return _prwucd_Deleted;}
            set {SetDirty(_prwucd_Deleted, value);
                 _prwucd_Deleted = value;}
        }

        /// <summary>
        /// Accessor for the prwucd_HQID property.
        /// </summary>
        public int prwucd_HQID {
            get {return _prwucd_HQID;}
            set {SetDirty(_prwucd_HQID, value);
                 _prwucd_HQID = value;}
        }

        /// <summary>
        /// Accessor for the prwucd_Secterr property.
        /// </summary>
        public int prwucd_Secterr {
            get {return _prwucd_Secterr;}
            set {SetDirty(_prwucd_Secterr, value);
                 _prwucd_Secterr = value;}
        }

        /// <summary>
        /// Accessor for the prwucd_sequence property.
        /// </summary>
        public int prwucd_sequence {
            get {return _prwucd_sequence;}
            set {SetDirty(_prwucd_sequence, value);
                 _prwucd_sequence = value;}
        }

        /// <summary>
        /// Accessor for the prwucd_UpdatedBy property.
        /// </summary>
        public int prwucd_UpdatedBy {
            get {return _prwucd_UpdatedBy;}
            set {SetDirty(_prwucd_UpdatedBy, value);
                 _prwucd_UpdatedBy = value;}
        }

        /// <summary>
        /// Accessor for the prwucd_WebUserCustomFieldID property.
        /// </summary>
        public int prwucd_WebUserCustomFieldID {
            get {return _prwucd_WebUserCustomFieldID;}
            set {SetDirty(_prwucd_WebUserCustomFieldID, value);
                 _prwucd_WebUserCustomFieldID = value;}
        }

        /// <summary>
        /// Accessor for the prwucd_WebUserCustomFieldLookupID property.
        /// </summary>
        public int prwucd_WebUserCustomFieldLookupID {
            get {return _prwucd_WebUserCustomFieldLookupID;}
            set {SetDirty(_prwucd_WebUserCustomFieldLookupID, value);
                 _prwucd_WebUserCustomFieldLookupID = value;}
        }

        /// <summary>
        /// Accessor for the prwucd_WebUserID property.
        /// </summary>
        public int prwucd_WebUserID {
            get {return _prwucd_WebUserID;}
            set {SetDirty(_prwucd_WebUserID, value);
                 _prwucd_WebUserID = value;}
        }

        /// <summary>
        /// Accessor for the prwucd_WorkflowId property.
        /// </summary>
        public int prwucd_WorkflowId {
            get {return _prwucd_WorkflowId;}
            set {SetDirty(_prwucd_WorkflowId, value);
                 _prwucd_WorkflowId = value;}
        }

        /// <summary>
        /// Accessor for the prwucd_AssociatedType property.
        /// </summary>
        public object prwucd_AssociatedType {
            get {return _prwucd_AssociatedType;}
            set {SetDirty(_prwucd_AssociatedType, value);
                 _prwucd_AssociatedType = value;}
        }

        /// <summary>
        /// Accessor for the prwucd_LabelCode property.
        /// </summary>
        public object prwucd_LabelCode {
            get {return _prwucd_LabelCode;}
            set {SetDirty(_prwucd_LabelCode, value);
                 _prwucd_LabelCode = value;}
        }

        /// <summary>
        /// Accessor for the prwucd_Value property.
        /// </summary>
        public string prwucd_Value {
            get {return _prwucd_Value;}
            set {SetDirty(_prwucd_Value, value);
                 _prwucd_Value = value;}
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
                _htFieldColMapping.Add("prwucd_CreatedDate",				PRWebUserCustomDataMgr.COL_PRWUCD_CREATED_DATE);
                _htFieldColMapping.Add("prwucd_TimeStamp",					PRWebUserCustomDataMgr.COL_PRWUCD_TIME_STAMP);
                _htFieldColMapping.Add("prwucd_UpdatedDate",				PRWebUserCustomDataMgr.COL_PRWUCD_UPDATED_DATE);
                _htFieldColMapping.Add("prwucd_AssociatedID",				PRWebUserCustomDataMgr.COL_PRWUCD_ASSOCIATED_ID);
                _htFieldColMapping.Add("prwucd_CompanyID",					PRWebUserCustomDataMgr.COL_PRWUCD_COMPANY_ID);
                _htFieldColMapping.Add("prwucd_CreatedBy",					PRWebUserCustomDataMgr.COL_PRWUCD_CREATED_BY);
                _htFieldColMapping.Add("prwucd_CustomDataID",				PRWebUserCustomDataMgr.COL_PRWUCD_CUSTOM_DATA_ID);
                _htFieldColMapping.Add("prwucd_Deleted",					PRWebUserCustomDataMgr.COL_PRWUCD_DELETED);
                _htFieldColMapping.Add("prwucd_HQID",						PRWebUserCustomDataMgr.COL_PRWUCD_HQID);
                _htFieldColMapping.Add("prwucd_Secterr",					PRWebUserCustomDataMgr.COL_PRWUCD_SECTERR);
                _htFieldColMapping.Add("prwucd_sequence",					PRWebUserCustomDataMgr.COL_PRWUCD_SEQUENCE);
                _htFieldColMapping.Add("prwucd_UpdatedBy",					PRWebUserCustomDataMgr.COL_PRWUCD_UPDATED_BY);
                _htFieldColMapping.Add("prwucd_WebUserCustomFieldID",		PRWebUserCustomDataMgr.COL_PRWUCD_WEB_USER_CUSTOM_FIELD_ID);
                _htFieldColMapping.Add("prwucd_WebUserCustomFieldLookupID",	PRWebUserCustomDataMgr.COL_PRWUCD_WEB_USER_CUSTOM_FIELD_LOOKUP_ID);
                _htFieldColMapping.Add("prwucd_WebUserID",					PRWebUserCustomDataMgr.COL_PRWUCD_WEB_USER_ID);
                _htFieldColMapping.Add("prwucd_WorkflowId",					PRWebUserCustomDataMgr.COL_PRWUCD_WORKFLOW_ID);
                _htFieldColMapping.Add("prwucd_AssociatedType",				PRWebUserCustomDataMgr.COL_PRWUCD_ASSOCIATED_TYPE);
                _htFieldColMapping.Add("prwucd_LabelCode",					PRWebUserCustomDataMgr.COL_PRWUCD_LABEL_CODE);
                _htFieldColMapping.Add("prwucd_Value",						PRWebUserCustomDataMgr.COL_PRWUCD_VALUE);
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

            _prwucd_CreatedBy = _oMgr.GetInt(oData[PRWebUserCustomDataMgr.COL_PRWUCD_CREATED_BY]);
            _prwucd_CreatedDate					 = _oMgr.GetDateTime(oData[PRWebUserCustomDataMgr.COL_PRWUCD_CREATED_DATE]);
            _prwucd_TimeStamp					 = _oMgr.GetDateTime(oData[PRWebUserCustomDataMgr.COL_PRWUCD_TIME_STAMP]);
            _prwucd_UpdatedDate					 = _oMgr.GetDateTime(oData[PRWebUserCustomDataMgr.COL_PRWUCD_UPDATED_DATE]);
            _prwucd_UpdatedBy = _oMgr.GetInt(oData[PRWebUserCustomDataMgr.COL_PRWUCD_UPDATED_BY]);

            _prwucd_AssociatedID				 = _oMgr.GetInt(oData[PRWebUserCustomDataMgr.COL_PRWUCD_ASSOCIATED_ID]);
            _prwucd_CompanyID					 = _oMgr.GetInt(oData[PRWebUserCustomDataMgr.COL_PRWUCD_COMPANY_ID]);
            _prwucd_CustomDataID				 = _oMgr.GetInt(oData[PRWebUserCustomDataMgr.COL_PRWUCD_CUSTOM_DATA_ID]);
            _prwucd_HQID						 = _oMgr.GetInt(oData[PRWebUserCustomDataMgr.COL_PRWUCD_HQID]);
            _prwucd_sequence					 = _oMgr.GetInt(oData[PRWebUserCustomDataMgr.COL_PRWUCD_SEQUENCE]);
            _prwucd_WebUserCustomFieldID		 = _oMgr.GetInt(oData[PRWebUserCustomDataMgr.COL_PRWUCD_WEB_USER_CUSTOM_FIELD_ID]);
            _prwucd_WebUserCustomFieldLookupID	 = _oMgr.GetInt(oData[PRWebUserCustomDataMgr.COL_PRWUCD_WEB_USER_CUSTOM_FIELD_LOOKUP_ID]);
            _prwucd_WebUserID					 = _oMgr.GetInt(oData[PRWebUserCustomDataMgr.COL_PRWUCD_WEB_USER_ID]);
            _prwucd_AssociatedType				 = _oMgr.GetObject(oData[PRWebUserCustomDataMgr.COL_PRWUCD_ASSOCIATED_TYPE]);
            _prwucd_LabelCode					 = _oMgr.GetObject(oData[PRWebUserCustomDataMgr.COL_PRWUCD_LABEL_CODE]);
            _prwucd_Value						 = _oMgr.GetString(oData[PRWebUserCustomDataMgr.COL_PRWUCD_VALUE]);
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
            if (iOptions != PRWebUserCustomDataMgr.OPT_LOAD_SAVE) {
                oData.Add(PRWebUserCustomDataMgr.COL_PRWUCD_CUSTOM_DATA_ID,						_prwucd_CustomDataID);
            }

            oData.Add(PRWebUserCustomDataMgr.COL_PRWUCD_CREATED_DATE,                       _dtCreatedDateTime);
            oData.Add(PRWebUserCustomDataMgr.COL_PRWUCD_CREATED_BY,                         _szCreatedUserID);
            oData.Add(PRWebUserCustomDataMgr.COL_PRWUCD_TIME_STAMP,                         DateTime.Now);
            oData.Add(PRWebUserCustomDataMgr.COL_PRWUCD_UPDATED_DATE,                       _dtUpdatedDateTime);
            oData.Add(PRWebUserCustomDataMgr.COL_PRWUCD_UPDATED_BY,                         _szUpdatedUserID);
            
            oData.Add(PRWebUserCustomDataMgr.COL_PRWUCD_ASSOCIATED_ID,						_prwucd_AssociatedID);
            oData.Add(PRWebUserCustomDataMgr.COL_PRWUCD_COMPANY_ID,							_prwucd_CompanyID);
            oData.Add(PRWebUserCustomDataMgr.COL_PRWUCD_HQID,								_prwucd_HQID);
            oData.Add(PRWebUserCustomDataMgr.COL_PRWUCD_SEQUENCE,							_prwucd_sequence);
            
            oData.Add(PRWebUserCustomDataMgr.COL_PRWUCD_WEB_USER_CUSTOM_FIELD_ID,			_prwucd_WebUserCustomFieldID);
            oData.Add(PRWebUserCustomDataMgr.COL_PRWUCD_WEB_USER_CUSTOM_FIELD_LOOKUP_ID,	_prwucd_WebUserCustomFieldLookupID);
            oData.Add(PRWebUserCustomDataMgr.COL_PRWUCD_WEB_USER_ID,						_prwucd_WebUserID);
            oData.Add(PRWebUserCustomDataMgr.COL_PRWUCD_ASSOCIATED_TYPE,					_prwucd_AssociatedType);
            oData.Add(PRWebUserCustomDataMgr.COL_PRWUCD_LABEL_CODE,							_prwucd_LabelCode);
            oData.Add(PRWebUserCustomDataMgr.COL_PRWUCD_VALUE,								_prwucd_Value);
        }
        #endregion

    }
}
