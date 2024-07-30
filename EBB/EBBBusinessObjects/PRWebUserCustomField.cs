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

 ClassName: PRWebUserCustomField
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
    /// Provides the functionality for the PRWebUserCustomField.
    /// </summary>
    public partial class PRWebUserCustomField : EBBObject, IPRWebUserCustomField
    {
        protected DateTime	_prwucf_CreatedDate;
        protected DateTime	_prwucf_TimeStamp;
        protected DateTime	_prwucf_UpdatedDate;
        protected int		_prwucf_CompanyID;
        protected int		_prwucf_CreatedBy;
        protected int		_prwucf_Deleted;
        protected int		_prwucf_HQID;
        protected int		_prwucf_Secterr;
        protected int		_prwucf_Sequence;
        protected int		_prwucf_UpdatedBy;
        protected int		_prwucf_WebUserCustomFieldID;
        protected int		_prwucf_WorkflowId;
        protected string	_prwucf_FieldTypeCode;
        protected bool	    _prwucf_Hide;
        protected bool      _prwucf_Pinned;
        protected string	_prwucf_Label;

        /// <summary>
        /// Constructor
        /// </summary>
        public PRWebUserCustomField() {}

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
                _oKeyValues.Add(prwucf_WebUserCustomFieldID);
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
            prwucf_WebUserCustomFieldID = 0;
        }

        /// <summary>
        /// Sets the key values for this object based
        /// on the specified list of values.  The list of
        /// values must be in the same order the keys are
        /// defined in GetKeyValues();
        /// </summary>
        /// <param name="oKeyValues">IList</param>
        override public void SetKeyValues(IList oKeyValues) {
            prwucf_WebUserCustomFieldID = Convert.ToInt32(oKeyValues[0]);
        }

        /// <summary>
        /// Accessor for the prwucf_CreatedDate property.
        /// </summary>
        public DateTime prwucf_CreatedDate {
            get {return _prwucf_CreatedDate;}
            set {SetDirty(_prwucf_CreatedDate, value);
                 _prwucf_CreatedDate = value;}
        }

        /// <summary>
        /// Accessor for the prwucf_TimeStamp property.
        /// </summary>
        public DateTime prwucf_TimeStamp {
            get {return _prwucf_TimeStamp;}
            set {SetDirty(_prwucf_TimeStamp, value);
                 _prwucf_TimeStamp = value;}
        }

        /// <summary>
        /// Accessor for the prwucf_UpdatedDate property.
        /// </summary>
        public DateTime prwucf_UpdatedDate {
            get {return _prwucf_UpdatedDate;}
            set {SetDirty(_prwucf_UpdatedDate, value);
                 _prwucf_UpdatedDate = value;}
        }

        /// <summary>
        /// Accessor for the prwucf_CompanyID property.
        /// </summary>
        public int prwucf_CompanyID {
            get {return _prwucf_CompanyID;}
            set {SetDirty(_prwucf_CompanyID, value);
                 _prwucf_CompanyID = value;}
        }

        /// <summary>
        /// Accessor for the prwucf_CreatedBy property.
        /// </summary>
        public int prwucf_CreatedBy {
            get {return _prwucf_CreatedBy;}
            set {SetDirty(_prwucf_CreatedBy, value);
                 _prwucf_CreatedBy = value;}
        }

        /// <summary>
        /// Accessor for the prwucf_Deleted property.
        /// </summary>
        public int prwucf_Deleted {
            get {return _prwucf_Deleted;}
            set {SetDirty(_prwucf_Deleted, value);
                 _prwucf_Deleted = value;}
        }

        /// <summary>
        /// Accessor for the prwucf_HQID property.
        /// </summary>
        public int prwucf_HQID {
            get {return _prwucf_HQID;}
            set {SetDirty(_prwucf_HQID, value);
                 _prwucf_HQID = value;}
        }

        /// <summary>
        /// Accessor for the prwucf_Secterr property.
        /// </summary>
        public int prwucf_Secterr {
            get {return _prwucf_Secterr;}
            set {SetDirty(_prwucf_Secterr, value);
                 _prwucf_Secterr = value;}
        }

        /// <summary>
        /// Accessor for the prwucf_Sequence property.
        /// </summary>
        public int prwucf_Sequence {
            get {return _prwucf_Sequence;}
            set {SetDirty(_prwucf_Sequence, value);
                 _prwucf_Sequence = value;}
        }

        /// <summary>
        /// Accessor for the prwucf_UpdatedBy property.
        /// </summary>
        public int prwucf_UpdatedBy {
            get {return _prwucf_UpdatedBy;}
            set {SetDirty(_prwucf_UpdatedBy, value);
                 _prwucf_UpdatedBy = value;}
        }

        /// <summary>
        /// Accessor for the prwucf_WebUserCustomFieldID property.
        /// </summary>
        public int prwucf_WebUserCustomFieldID {
            get {return _prwucf_WebUserCustomFieldID;}
            set {SetDirty(_prwucf_WebUserCustomFieldID, value);
                 _prwucf_WebUserCustomFieldID = value;}
        }

        /// <summary>
        /// Accessor for the prwucf_WorkflowId property.
        /// </summary>
        public int prwucf_WorkflowId {
            get {return _prwucf_WorkflowId;}
            set {SetDirty(_prwucf_WorkflowId, value);
                 _prwucf_WorkflowId = value;}
        }

        /// <summary>
        /// Accessor for the prwucf_FieldTypeCode property.
        /// </summary>
        public string prwucf_FieldTypeCode {
            get {return _prwucf_FieldTypeCode;}
            set {SetDirty(_prwucf_FieldTypeCode, value);
                 _prwucf_FieldTypeCode = value;}
        }

        /// <summary>
        /// Accessor for the prwucf_Hide property.
        /// </summary>
        public bool prwucf_Hide {
            get {return _prwucf_Hide;}
            set {SetDirty(_prwucf_Hide, value);
                 _prwucf_Hide = value;}
        }

        /// <summary>
        /// Accessor for the prwucf_Pinned property.
        /// </summary>
        public bool prwucf_Pinned
        {
            get {return _prwucf_Pinned;}
            set {SetDirty(_prwucf_Pinned, value);
                 _prwucf_Pinned = value;}
        }

        /// <summary>
        /// Accessor for the prwucf_Label property.
        /// </summary>
        public string prwucf_Label {
            get {return _prwucf_Label;}
            set {SetDirty(_prwucf_Label, value);
                 _prwucf_Label = value;}
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
                _htFieldColMapping.Add("prwucf_CreatedDate",				PRWebUserCustomFieldMgr.COL_PRWUCF_CREATED_DATE);
                _htFieldColMapping.Add("prwucf_TimeStamp",					PRWebUserCustomFieldMgr.COL_PRWUCF_TIME_STAMP);
                _htFieldColMapping.Add("prwucf_UpdatedDate",				PRWebUserCustomFieldMgr.COL_PRWUCF_UPDATED_DATE);
                _htFieldColMapping.Add("prwucf_CompanyID",					PRWebUserCustomFieldMgr.COL_PRWUCF_COMPANY_ID);
                _htFieldColMapping.Add("prwucf_CreatedBy",					PRWebUserCustomFieldMgr.COL_PRWUCF_CREATED_BY);
                _htFieldColMapping.Add("prwucf_HQID",						PRWebUserCustomFieldMgr.COL_PRWUCF_HQID);
                _htFieldColMapping.Add("prwucf_Sequence",					PRWebUserCustomFieldMgr.COL_PRWUCF_SEQUENCE);
                _htFieldColMapping.Add("prwucf_UpdatedBy",					PRWebUserCustomFieldMgr.COL_PRWUCF_UPDATED_BY);
                _htFieldColMapping.Add("prwucf_WebUserCustomFieldID",		PRWebUserCustomFieldMgr.COL_PRWUCF_WEB_USER_CUSTOM_FIELD_ID);
                _htFieldColMapping.Add("prwucf_FieldTypeCode",				PRWebUserCustomFieldMgr.COL_PRWUCF_FIELD_TYPE_CODE);
                _htFieldColMapping.Add("prwucf_Hide",						PRWebUserCustomFieldMgr.COL_PRWUCF_HIDE);
                _htFieldColMapping.Add("prwucf_Pinned",						PRWebUserCustomFieldMgr.COL_PRWUCF_PINNED);
                _htFieldColMapping.Add("prwucf_Label",						PRWebUserCustomFieldMgr.COL_PRWUCF_LABEL);
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

            _prwucf_CreatedBy                    = _oMgr.GetInt(oData[PRWebUserCustomFieldMgr.COL_PRWUCF_CREATED_BY]);
            _prwucf_CreatedDate					 = _oMgr.GetDateTime(oData[PRWebUserCustomFieldMgr.COL_PRWUCF_CREATED_DATE]);
            _prwucf_UpdatedBy                    = _oMgr.GetInt(oData[PRWebUserCustomFieldMgr.COL_PRWUCF_UPDATED_BY]);
            _prwucf_UpdatedDate                  = _oMgr.GetDateTime(oData[PRWebUserCustomFieldMgr.COL_PRWUCF_UPDATED_DATE]);
            _prwucf_TimeStamp					 = _oMgr.GetDateTime(oData[PRWebUserCustomFieldMgr.COL_PRWUCF_TIME_STAMP]);
            
            _prwucf_CompanyID					 = _oMgr.GetInt(oData[PRWebUserCustomFieldMgr.COL_PRWUCF_COMPANY_ID]);
            _prwucf_HQID						 = _oMgr.GetInt(oData[PRWebUserCustomFieldMgr.COL_PRWUCF_HQID]);
            _prwucf_Sequence					 = _oMgr.GetInt(oData[PRWebUserCustomFieldMgr.COL_PRWUCF_SEQUENCE]);
            _prwucf_WebUserCustomFieldID		 = _oMgr.GetInt(oData[PRWebUserCustomFieldMgr.COL_PRWUCF_WEB_USER_CUSTOM_FIELD_ID]);
            _prwucf_FieldTypeCode				 = _oMgr.GetString(oData[PRWebUserCustomFieldMgr.COL_PRWUCF_FIELD_TYPE_CODE]);
            _prwucf_Hide                         = ((PRWebUserCustomFieldMgr)_oMgr).TranslateFromCRMBool(oData[PRWebUserCustomFieldMgr.COL_PRWUCF_HIDE]);
            _prwucf_Pinned                       = ((PRWebUserCustomFieldMgr)_oMgr).TranslateFromCRMBool(oData[PRWebUserCustomFieldMgr.COL_PRWUCF_PINNED]);
            _prwucf_Label						 = _oMgr.GetString(oData[PRWebUserCustomFieldMgr.COL_PRWUCF_LABEL]);
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
            if (iOptions != PRWebUserCustomFieldMgr.OPT_LOAD_SAVE) {
                oData.Add(PRWebUserCustomFieldMgr.COL_PRWUCF_WEB_USER_CUSTOM_FIELD_ID,			_prwucf_WebUserCustomFieldID);
            }

            oData.Add(PRWebUserCustomFieldMgr.COL_PRWUCF_CREATED_BY, _szCreatedUserID);
            oData.Add(PRWebUserCustomFieldMgr.COL_PRWUCF_CREATED_DATE,					    _dtCreatedDateTime);
            oData.Add(PRWebUserCustomFieldMgr.COL_PRWUCF_UPDATED_BY, _szUpdatedUserID);
            oData.Add(PRWebUserCustomFieldMgr.COL_PRWUCF_UPDATED_DATE, _dtUpdatedDateTime);
            oData.Add(PRWebUserCustomFieldMgr.COL_PRWUCF_TIME_STAMP,						DateTime.Now);

            oData.Add(PRWebUserCustomFieldMgr.COL_PRWUCF_COMPANY_ID,						_prwucf_CompanyID);
            oData.Add(PRWebUserCustomFieldMgr.COL_PRWUCF_HQID,								_prwucf_HQID);
            oData.Add(PRWebUserCustomFieldMgr.COL_PRWUCF_SEQUENCE,							_prwucf_Sequence);
            oData.Add(PRWebUserCustomFieldMgr.COL_PRWUCF_FIELD_TYPE_CODE,					_prwucf_FieldTypeCode);
            oData.Add(PRWebUserCustomFieldMgr.COL_PRWUCF_HIDE,								((PRWebUserCustomFieldMgr)_oMgr).GetPIKSCoreBool(_prwucf_Hide));
            oData.Add(PRWebUserCustomFieldMgr.COL_PRWUCF_PINNED,							((PRWebUserCustomFieldMgr)_oMgr).GetPIKSCoreBool(_prwucf_Pinned));
            oData.Add(PRWebUserCustomFieldMgr.COL_PRWUCF_LABEL,								_prwucf_Label);


 
        }
        #endregion

    }
}
