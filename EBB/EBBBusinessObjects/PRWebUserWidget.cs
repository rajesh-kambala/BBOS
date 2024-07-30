/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2018

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Blue Book Services, Inc..  Contact
 by e-mail at info@travant.com

 ClassName: PRWebUserWidget
 Description:	

 Notes:	Created By TSI Class Generator on 8/10/2018 11:59:27 AM

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using TSI.Arch;
using TSI.BusinessObjects;

namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Provides the functionality for the PRWebUserWidget.
    /// </summary>
    public partial class PRWebUserWidget : EBBObject
    {
        protected DateTime	_prwuw_CreatedDate;
        protected DateTime	_prwuw_TimeStamp;
        protected DateTime	_prwuw_UpdatedDate;
        protected int		_prwuw_CreatedBy;
        protected int		_prwuw_Deleted;
        protected int		_prwuw_Secterr;
        protected int		_prwuw_Sequence;
        protected int		_prwuw_UpdatedBy;
        protected int		_prwuw_WebUserID;
        protected int		_prwuw_WebUserWidgetID;
        protected int		_prwuw_WorkflowId;
        protected string	_prwuw_WidgetCode;

        /// <summary>
        /// Constructor
        /// </summary>
        public PRWebUserWidget() {}

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
                _oKeyValues.Add(prwuw_WebUserWidgetID);
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
            prwuw_WebUserWidgetID = 0;
        }

        /// <summary>
        /// Sets the key values for this object based
        /// on the specified list of values.  The list of
        /// values must be in the same order the keys are
        /// defined in GetKeyValues();
        /// </summary>
        /// <param name="oKeyValues">IList</param>
        override public void SetKeyValues(IList oKeyValues) {
            prwuw_WebUserWidgetID = Convert.ToInt32(oKeyValues[0]);
        }

        /// <summary>
        /// Accessor for the prwuw_CreatedDate property.
        /// </summary>
        public DateTime prwuw_CreatedDate {
            get {return _prwuw_CreatedDate;}
            set {SetDirty(_prwuw_CreatedDate, value);
                 _prwuw_CreatedDate = value;}
        }

        /// <summary>
        /// Accessor for the prwuw_TimeStamp property.
        /// </summary>
        public DateTime prwuw_TimeStamp {
            get {return _prwuw_TimeStamp;}
            set {SetDirty(_prwuw_TimeStamp, value);
                 _prwuw_TimeStamp = value;}
        }

        /// <summary>
        /// Accessor for the prwuw_UpdatedDate property.
        /// </summary>
        public DateTime prwuw_UpdatedDate {
            get {return _prwuw_UpdatedDate;}
            set {SetDirty(_prwuw_UpdatedDate, value);
                 _prwuw_UpdatedDate = value;}
        }

        /// <summary>
        /// Accessor for the prwuw_CreatedBy property.
        /// </summary>
        public int prwuw_CreatedBy {
            get {return _prwuw_CreatedBy;}
            set {SetDirty(_prwuw_CreatedBy, value);
                 _prwuw_CreatedBy = value;}
        }

        /// <summary>
        /// Accessor for the prwuw_Deleted property.
        /// </summary>
        public int prwuw_Deleted {
            get {return _prwuw_Deleted;}
            set {SetDirty(_prwuw_Deleted, value);
                 _prwuw_Deleted = value;}
        }

        /// <summary>
        /// Accessor for the prwuw_Secterr property.
        /// </summary>
        public int prwuw_Secterr {
            get {return _prwuw_Secterr;}
            set {SetDirty(_prwuw_Secterr, value);
                 _prwuw_Secterr = value;}
        }

        /// <summary>
        /// Accessor for the prwuw_Sequence property.
        /// </summary>
        public int prwuw_Sequence {
            get {return _prwuw_Sequence;}
            set {SetDirty(_prwuw_Sequence, value);
                 _prwuw_Sequence = value;}
        }

        /// <summary>
        /// Accessor for the prwuw_UpdatedBy property.
        /// </summary>
        public int prwuw_UpdatedBy {
            get {return _prwuw_UpdatedBy;}
            set {SetDirty(_prwuw_UpdatedBy, value);
                 _prwuw_UpdatedBy = value;}
        }

        /// <summary>
        /// Accessor for the prwuw_WebUserID property.
        /// </summary>
        public int prwuw_WebUserID {
            get {return _prwuw_WebUserID;}
            set {SetDirty(_prwuw_WebUserID, value);
                 _prwuw_WebUserID = value;}
        }

        /// <summary>
        /// Accessor for the prwuw_WebUserWidgetID property.
        /// </summary>
        public int prwuw_WebUserWidgetID {
            get {return _prwuw_WebUserWidgetID;}
            set {SetDirty(_prwuw_WebUserWidgetID, value);
                 _prwuw_WebUserWidgetID = value;}
        }

        /// <summary>
        /// Accessor for the prwuw_WorkflowId property.
        /// </summary>
        public int prwuw_WorkflowId {
            get {return _prwuw_WorkflowId;}
            set {SetDirty(_prwuw_WorkflowId, value);
                 _prwuw_WorkflowId = value;}
        }

        /// <summary>
        /// Accessor for the prwuw_WidgetCode property.
        /// </summary>
        public string prwuw_WidgetCode {
            get {return _prwuw_WidgetCode;}
            set {SetDirty(_prwuw_WidgetCode, value);
                 _prwuw_WidgetCode = value;}
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
                _htFieldColMapping.Add("prwuw_CreatedDate",		PRWebUserWidgetMgr.COL_PRWUW_CREATED_DATE);
                _htFieldColMapping.Add("prwuw_TimeStamp",		PRWebUserWidgetMgr.COL_PRWUW_TIME_STAMP);
                _htFieldColMapping.Add("prwuw_UpdatedDate",		PRWebUserWidgetMgr.COL_PRWUW_UPDATED_DATE);
                _htFieldColMapping.Add("prwuw_CreatedBy",		PRWebUserWidgetMgr.COL_PRWUW_CREATED_BY);
                _htFieldColMapping.Add("prwuw_Deleted",			PRWebUserWidgetMgr.COL_PRWUW_DELETED);
                _htFieldColMapping.Add("prwuw_Secterr",			PRWebUserWidgetMgr.COL_PRWUW_SECTERR);
                _htFieldColMapping.Add("prwuw_Sequence",		PRWebUserWidgetMgr.COL_PRWUW_SEQUENCE);
                _htFieldColMapping.Add("prwuw_UpdatedBy",		PRWebUserWidgetMgr.COL_PRWUW_UPDATED_BY);
                _htFieldColMapping.Add("prwuw_WebUserID",		PRWebUserWidgetMgr.COL_PRWUW_WEB_USER_ID);
                _htFieldColMapping.Add("prwuw_WebUserWidgetID",	PRWebUserWidgetMgr.COL_PRWUW_WEB_USER_WIDGET_ID);
                _htFieldColMapping.Add("prwuw_WorkflowId",		PRWebUserWidgetMgr.COL_PRWUW_WORKFLOW_ID);
                _htFieldColMapping.Add("prwuw_WidgetCode",		PRWebUserWidgetMgr.COL_PRWUW_WIDGET_CODE);
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

            _prwuw_CreatedDate		 = _oMgr.GetDateTime(oData[PRWebUserWidgetMgr.COL_PRWUW_CREATED_DATE]);
            _prwuw_TimeStamp		 = _oMgr.GetDateTime(oData[PRWebUserWidgetMgr.COL_PRWUW_TIME_STAMP]);
            _prwuw_UpdatedDate		 = _oMgr.GetDateTime(oData[PRWebUserWidgetMgr.COL_PRWUW_UPDATED_DATE]);
            _prwuw_CreatedBy		 = _oMgr.GetInt(oData[PRWebUserWidgetMgr.COL_PRWUW_CREATED_BY]);
            _prwuw_Deleted			 = _oMgr.GetInt(oData[PRWebUserWidgetMgr.COL_PRWUW_DELETED]);
            _prwuw_Secterr			 = _oMgr.GetInt(oData[PRWebUserWidgetMgr.COL_PRWUW_SECTERR]);
            _prwuw_Sequence			 = _oMgr.GetInt(oData[PRWebUserWidgetMgr.COL_PRWUW_SEQUENCE]);
            _prwuw_UpdatedBy		 = _oMgr.GetInt(oData[PRWebUserWidgetMgr.COL_PRWUW_UPDATED_BY]);
            _prwuw_WebUserID		 = _oMgr.GetInt(oData[PRWebUserWidgetMgr.COL_PRWUW_WEB_USER_ID]);
            _prwuw_WebUserWidgetID	 = _oMgr.GetInt(oData[PRWebUserWidgetMgr.COL_PRWUW_WEB_USER_WIDGET_ID]);
            _prwuw_WorkflowId		 = _oMgr.GetInt(oData[PRWebUserWidgetMgr.COL_PRWUW_WORKFLOW_ID]);
            _prwuw_WidgetCode		 = _oMgr.GetString(oData[PRWebUserWidgetMgr.COL_PRWUW_WIDGET_CODE]);
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
            if (iOptions != PRWebUserWidgetMgr.OPT_LOAD_SAVE) {
                oData.Add(PRWebUserWidgetMgr.COL_PRWUW_WEB_USER_WIDGET_ID,	_prwuw_WebUserWidgetID);
            }

            oData.Add(PRWebUserWidgetMgr.COL_PRWUW_CREATED_DATE,		_prwuw_CreatedDate);
            oData.Add(PRWebUserWidgetMgr.COL_PRWUW_TIME_STAMP,			_prwuw_TimeStamp);
            oData.Add(PRWebUserWidgetMgr.COL_PRWUW_UPDATED_DATE,		_prwuw_UpdatedDate);
            oData.Add(PRWebUserWidgetMgr.COL_PRWUW_CREATED_BY,			_prwuw_CreatedBy);
            oData.Add(PRWebUserWidgetMgr.COL_PRWUW_DELETED,				_prwuw_Deleted);
            oData.Add(PRWebUserWidgetMgr.COL_PRWUW_SECTERR,				_prwuw_Secterr);
            oData.Add(PRWebUserWidgetMgr.COL_PRWUW_SEQUENCE,			_prwuw_Sequence);
            oData.Add(PRWebUserWidgetMgr.COL_PRWUW_UPDATED_BY,			_prwuw_UpdatedBy);
            oData.Add(PRWebUserWidgetMgr.COL_PRWUW_WEB_USER_ID,			_prwuw_WebUserID);
            oData.Add(PRWebUserWidgetMgr.COL_PRWUW_WORKFLOW_ID,			_prwuw_WorkflowId);
            oData.Add(PRWebUserWidgetMgr.COL_PRWUW_WIDGET_CODE,			_prwuw_WidgetCode);
        }
        #endregion

    }
}
