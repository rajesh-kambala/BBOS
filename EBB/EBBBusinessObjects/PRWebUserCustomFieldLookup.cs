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

 ClassName: PRWebUserCustomFieldLookup
 Description:	

 Notes:	Created By TSI Class Generator on 7/18/2014 2:10:14 PM

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using TSI.Arch;
using TSI.BusinessObjects;

namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Provides the functionality for the PRWebUserCustomFieldLookup.
    /// </summary>
    public partial class PRWebUserCustomFieldLookup : EBBObject, IPRWebUserCustomFieldLookup
    {
        protected DateTime	_prwucfl_CreatedDate;
        protected DateTime	_prwucfl_TimeStamp;
        protected DateTime	_prwucfl_UpdatedDate;
        protected int		_prwucfl_CreatedBy;
        protected int		_prwucfl_Deleted;
        protected int		_prwucfl_Secterr;
        protected int		_prwucfl_Sequence;
        protected int		_prwucfl_UpdatedBy;
        protected int		_prwucfl_WebUserCustomFieldID;
        protected int		_prwucfl_WebUserCustomFieldLookupID;
        protected int		_prwucfl_WorkflowId;
        protected string	_prwucfl_LookupValue;

        /// <summary>
        /// Constructor
        /// </summary>
        public PRWebUserCustomFieldLookup() {}

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
                _oKeyValues.Add(prwucfl_WebUserCustomFieldLookupID);
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
            prwucfl_WebUserCustomFieldLookupID = 0;
        }

        /// <summary>
        /// Sets the key values for this object based
        /// on the specified list of values.  The list of
        /// values must be in the same order the keys are
        /// defined in GetKeyValues();
        /// </summary>
        /// <param name="oKeyValues">IList</param>
        override public void SetKeyValues(IList oKeyValues) {
            prwucfl_WebUserCustomFieldLookupID = Convert.ToInt32(oKeyValues[0]);
        }

        /// <summary>
        /// Accessor for the prwucfl_CreatedDate property.
        /// </summary>
        public DateTime prwucfl_CreatedDate {
            get {return _prwucfl_CreatedDate;}
            set {SetDirty(_prwucfl_CreatedDate, value);
                 _prwucfl_CreatedDate = value;}
        }

        /// <summary>
        /// Accessor for the prwucfl_TimeStamp property.
        /// </summary>
        public DateTime prwucfl_TimeStamp {
            get {return _prwucfl_TimeStamp;}
            set {SetDirty(_prwucfl_TimeStamp, value);
                 _prwucfl_TimeStamp = value;}
        }

        /// <summary>
        /// Accessor for the prwucfl_UpdatedDate property.
        /// </summary>
        public DateTime prwucfl_UpdatedDate {
            get {return _prwucfl_UpdatedDate;}
            set {SetDirty(_prwucfl_UpdatedDate, value);
                 _prwucfl_UpdatedDate = value;}
        }

        /// <summary>
        /// Accessor for the prwucfl_CreatedBy property.
        /// </summary>
        public int prwucfl_CreatedBy {
            get {return _prwucfl_CreatedBy;}
            set {SetDirty(_prwucfl_CreatedBy, value);
                 _prwucfl_CreatedBy = value;}
        }

        /// <summary>
        /// Accessor for the prwucfl_Deleted property.
        /// </summary>
        public int prwucfl_Deleted {
            get {return _prwucfl_Deleted;}
            set {SetDirty(_prwucfl_Deleted, value);
                 _prwucfl_Deleted = value;}
        }

        /// <summary>
        /// Accessor for the prwucfl_Secterr property.
        /// </summary>
        public int prwucfl_Secterr {
            get {return _prwucfl_Secterr;}
            set {SetDirty(_prwucfl_Secterr, value);
                 _prwucfl_Secterr = value;}
        }

        /// <summary>
        /// Accessor for the prwucfl_Sequence property.
        /// </summary>
        public int prwucfl_Sequence {
            get {return _prwucfl_Sequence;}
            set {SetDirty(_prwucfl_Sequence, value);
                 _prwucfl_Sequence = value;}
        }

        /// <summary>
        /// Accessor for the prwucfl_UpdatedBy property.
        /// </summary>
        public int prwucfl_UpdatedBy {
            get {return _prwucfl_UpdatedBy;}
            set {SetDirty(_prwucfl_UpdatedBy, value);
                 _prwucfl_UpdatedBy = value;}
        }

        /// <summary>
        /// Accessor for the prwucfl_WebUserCustomFieldID property.
        /// </summary>
        public int prwucfl_WebUserCustomFieldID {
            get {return _prwucfl_WebUserCustomFieldID;}
            set {SetDirty(_prwucfl_WebUserCustomFieldID, value);
                 _prwucfl_WebUserCustomFieldID = value;}
        }

        /// <summary>
        /// Accessor for the prwucfl_WebUserCustomFieldLookupID property.
        /// </summary>
        public int prwucfl_WebUserCustomFieldLookupID {
            get {return _prwucfl_WebUserCustomFieldLookupID;}
            set {SetDirty(_prwucfl_WebUserCustomFieldLookupID, value);
                 _prwucfl_WebUserCustomFieldLookupID = value;}
        }

        /// <summary>
        /// Accessor for the prwucfl_WorkflowId property.
        /// </summary>
        public int prwucfl_WorkflowId {
            get {return _prwucfl_WorkflowId;}
            set {SetDirty(_prwucfl_WorkflowId, value);
                 _prwucfl_WorkflowId = value;}
        }

        /// <summary>
        /// Accessor for the prwucfl_LookupValue property.
        /// </summary>
        public string prwucfl_LookupValue {
            get {return _prwucfl_LookupValue;}
            set {SetDirty(_prwucfl_LookupValue, value);
                 _prwucfl_LookupValue = value;}
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
                _htFieldColMapping.Add("prwucfl_CreatedDate",					PRWebUserCustomFieldLookupMgr.COL_PRWUCFL_CREATED_DATE);
                _htFieldColMapping.Add("prwucfl_TimeStamp",						PRWebUserCustomFieldLookupMgr.COL_PRWUCFL_TIME_STAMP);
                _htFieldColMapping.Add("prwucfl_UpdatedDate",					PRWebUserCustomFieldLookupMgr.COL_PRWUCFL_UPDATED_DATE);
                _htFieldColMapping.Add("prwucfl_CreatedBy",						PRWebUserCustomFieldLookupMgr.COL_PRWUCFL_CREATED_BY);
                _htFieldColMapping.Add("prwucfl_Deleted",						PRWebUserCustomFieldLookupMgr.COL_PRWUCFL_DELETED);
                _htFieldColMapping.Add("prwucfl_Secterr",						PRWebUserCustomFieldLookupMgr.COL_PRWUCFL_SECTERR);
                _htFieldColMapping.Add("prwucfl_Sequence",						PRWebUserCustomFieldLookupMgr.COL_PRWUCFL_SEQUENCE);
                _htFieldColMapping.Add("prwucfl_UpdatedBy",						PRWebUserCustomFieldLookupMgr.COL_PRWUCFL_UPDATED_BY);
                _htFieldColMapping.Add("prwucfl_WebUserCustomFieldID",			PRWebUserCustomFieldLookupMgr.COL_PRWUCFL_WEB_USER_CUSTOM_FIELD_ID);
                _htFieldColMapping.Add("prwucfl_WebUserCustomFieldLookupID",	PRWebUserCustomFieldLookupMgr.COL_PRWUCFL_WEB_USER_CUSTOM_FIELD_LOOKUP_ID);
                _htFieldColMapping.Add("prwucfl_WorkflowId",					PRWebUserCustomFieldLookupMgr.COL_PRWUCFL_WORKFLOW_ID);
                _htFieldColMapping.Add("prwucfl_LookupValue",					PRWebUserCustomFieldLookupMgr.COL_PRWUCFL_LOOKUP_VALUE);
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

            _prwucfl_CreatedBy = _oMgr.GetInt(oData[PRWebUserCustomFieldLookupMgr.COL_PRWUCFL_CREATED_BY]);
            _prwucfl_CreatedDate = _oMgr.GetDateTime(oData[PRWebUserCustomFieldLookupMgr.COL_PRWUCFL_CREATED_DATE]);
            _prwucfl_UpdatedBy = _oMgr.GetInt(oData[PRWebUserCustomFieldLookupMgr.COL_PRWUCFL_UPDATED_BY]);
            _prwucfl_UpdatedDate = _oMgr.GetDateTime(oData[PRWebUserCustomFieldLookupMgr.COL_PRWUCFL_UPDATED_DATE]);
            _prwucfl_TimeStamp = _oMgr.GetDateTime(oData[PRWebUserCustomFieldLookupMgr.COL_PRWUCFL_TIME_STAMP]);

            _prwucfl_Sequence					 = _oMgr.GetInt(oData[PRWebUserCustomFieldLookupMgr.COL_PRWUCFL_SEQUENCE]);
            _prwucfl_WebUserCustomFieldID		 = _oMgr.GetInt(oData[PRWebUserCustomFieldLookupMgr.COL_PRWUCFL_WEB_USER_CUSTOM_FIELD_ID]);
            _prwucfl_WebUserCustomFieldLookupID	 = _oMgr.GetInt(oData[PRWebUserCustomFieldLookupMgr.COL_PRWUCFL_WEB_USER_CUSTOM_FIELD_LOOKUP_ID]);
            _prwucfl_LookupValue				 = _oMgr.GetString(oData[PRWebUserCustomFieldLookupMgr.COL_PRWUCFL_LOOKUP_VALUE]);
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
            if (iOptions != PRWebUserCustomFieldLookupMgr.OPT_LOAD_SAVE) {
                oData.Add(PRWebUserCustomFieldLookupMgr.COL_PRWUCFL_WEB_USER_CUSTOM_FIELD_LOOKUP_ID,	_prwucfl_WebUserCustomFieldLookupID);
            }

            oData.Add(PRWebUserCustomFieldLookupMgr.COL_PRWUCFL_CREATED_BY, _szCreatedUserID);
            oData.Add(PRWebUserCustomFieldLookupMgr.COL_PRWUCFL_CREATED_DATE, _dtCreatedDateTime);
            oData.Add(PRWebUserCustomFieldLookupMgr.COL_PRWUCFL_UPDATED_BY, _szUpdatedUserID);
            oData.Add(PRWebUserCustomFieldLookupMgr.COL_PRWUCFL_UPDATED_DATE, _dtUpdatedDateTime);
            oData.Add(PRWebUserCustomFieldLookupMgr.COL_PRWUCFL_TIME_STAMP, DateTime.Now);

            oData.Add(PRWebUserCustomFieldLookupMgr.COL_PRWUCFL_WEB_USER_CUSTOM_FIELD_ID, _prwucfl_WebUserCustomFieldID);
            oData.Add(PRWebUserCustomFieldLookupMgr.COL_PRWUCFL_LOOKUP_VALUE, _prwucfl_LookupValue);
            oData.Add(PRWebUserCustomFieldLookupMgr.COL_PRWUCFL_SEQUENCE,							_prwucfl_Sequence);
        }
        #endregion

    }
}
