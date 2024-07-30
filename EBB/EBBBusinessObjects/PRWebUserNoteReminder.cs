/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2014-2015

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Blue Book Services, Inc..  Contact
 by e-mail at chris@wallsfamily.com

 ClassName: PRWebUserNoteReminder
 Description:	

 Notes:	Created By TSI Class Generator on 1/30/2015 10:28:52 AM

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using TSI.Arch;
using TSI.BusinessObjects;

namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Provides the functionality for the PRWebUserNoteReminder.
    /// </summary>
    public partial class PRWebUserNoteReminder : EBBObject, IPRWebUserNoteReminder
    {
        protected DateTime	_prwunr_CreatedDate;
        protected DateTime	_prwunr_Date;
        protected DateTime	_prwunr_DateUTC;
        protected DateTime	_prwunr_SentDateTime;
        protected DateTime	_prwunr_SentDateTimeUTC;
        protected DateTime	_prwunr_TimeStamp;
        protected DateTime	_prwunr_UpdatedDate;
        protected int		_prwunr_CreatedBy;
        protected int		_prwunr_Deleted;
        protected int		_prwunr_Secterr;
        protected int		_prwunr_UpdatedBy;
        protected int		_prwunr_WebUserID;
        protected int		_prwunr_WebUserNoteID;
        protected int		_prwunr_WebUserNoteReminderID;
        protected int		_prwunr_WorkflowId;
        protected string	_prwunr_AMPM;
        protected string	_prwunr_Email;
        protected string	_prwunr_Hour;
        protected string	_prwunr_Minute;
        protected string	_prwunr_Phone;
        protected string	_prwunr_Threshold;
        protected string	_prwunr_Timezone;
        protected string	_prwunr_Type;

        /// <summary>
        /// Constructor
        /// </summary>
        public PRWebUserNoteReminder() {}

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
                _oKeyValues.Add(prwunr_WebUserNoteReminderID);
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
            prwunr_WebUserNoteReminderID = 0;
        }

        /// <summary>
        /// Sets the key values for this object based
        /// on the specified list of values.  The list of
        /// values must be in the same order the keys are
        /// defined in GetKeyValues();
        /// </summary>
        /// <param name="oKeyValues">IList</param>
        override public void SetKeyValues(IList oKeyValues) {
            prwunr_WebUserNoteReminderID = Convert.ToInt32(oKeyValues[0]);
        }

        /// <summary>
        /// Accessor for the prwunr_CreatedDate property.
        /// </summary>
        public DateTime prwunr_CreatedDate {
            get {return _prwunr_CreatedDate;}
            set {SetDirty(_prwunr_CreatedDate, value);
                 _prwunr_CreatedDate = value;}
        }

        /// <summary>
        /// Accessor for the prwunr_Date property.
        /// </summary>
        public DateTime prwunr_Date {
            get {return _prwunr_Date;}
            set {SetDirty(_prwunr_Date, value);
                 _prwunr_Date = value;}
        }

        /// <summary>
        /// Accessor for the prwunr_DateUTC property.
        /// </summary>
        public DateTime prwunr_DateUTC {
            get {return _prwunr_DateUTC;}
            set {SetDirty(_prwunr_DateUTC, value);
                 _prwunr_DateUTC = value;}
        }

        /// <summary>
        /// Accessor for the prwunr_SentDateTime property.
        /// </summary>
        public DateTime prwunr_SentDateTime {
            get {return _prwunr_SentDateTime;}
            set {SetDirty(_prwunr_SentDateTime, value);
                 _prwunr_SentDateTime = value;}
        }

        /// <summary>
        /// Accessor for the prwunr_SentDateTimeUTC property.
        /// </summary>
        public DateTime prwunr_SentDateTimeUTC {
            get {return _prwunr_SentDateTimeUTC;}
            set {SetDirty(_prwunr_SentDateTimeUTC, value);
                 _prwunr_SentDateTimeUTC = value;}
        }

        /// <summary>
        /// Accessor for the prwunr_TimeStamp property.
        /// </summary>
        public DateTime prwunr_TimeStamp {
            get {return _prwunr_TimeStamp;}
            set {SetDirty(_prwunr_TimeStamp, value);
                 _prwunr_TimeStamp = value;}
        }

        /// <summary>
        /// Accessor for the prwunr_UpdatedDate property.
        /// </summary>
        public DateTime prwunr_UpdatedDate {
            get {return _prwunr_UpdatedDate;}
            set {SetDirty(_prwunr_UpdatedDate, value);
                 _prwunr_UpdatedDate = value;}
        }

        /// <summary>
        /// Accessor for the prwunr_CreatedBy property.
        /// </summary>
        public int prwunr_CreatedBy {
            get {return _prwunr_CreatedBy;}
            set {SetDirty(_prwunr_CreatedBy, value);
                 _prwunr_CreatedBy = value;}
        }

        /// <summary>
        /// Accessor for the prwunr_Deleted property.
        /// </summary>
        public int prwunr_Deleted {
            get {return _prwunr_Deleted;}
            set {SetDirty(_prwunr_Deleted, value);
                 _prwunr_Deleted = value;}
        }

        /// <summary>
        /// Accessor for the prwunr_Secterr property.
        /// </summary>
        public int prwunr_Secterr {
            get {return _prwunr_Secterr;}
            set {SetDirty(_prwunr_Secterr, value);
                 _prwunr_Secterr = value;}
        }

        /// <summary>
        /// Accessor for the prwunr_UpdatedBy property.
        /// </summary>
        public int prwunr_UpdatedBy {
            get {return _prwunr_UpdatedBy;}
            set {SetDirty(_prwunr_UpdatedBy, value);
                 _prwunr_UpdatedBy = value;}
        }

        /// <summary>
        /// Accessor for the prwunr_WebUserID property.
        /// </summary>
        public int prwunr_WebUserID {
            get {return _prwunr_WebUserID;}
            set {SetDirty(_prwunr_WebUserID, value);
                 _prwunr_WebUserID = value;}
        }

        /// <summary>
        /// Accessor for the prwunr_WebUserNoteID property.
        /// </summary>
        public int prwunr_WebUserNoteID {
            get {return _prwunr_WebUserNoteID;}
            set {SetDirty(_prwunr_WebUserNoteID, value);
                 _prwunr_WebUserNoteID = value;}
        }

        /// <summary>
        /// Accessor for the prwunr_WebUserNoteReminderID property.
        /// </summary>
        public int prwunr_WebUserNoteReminderID {
            get {return _prwunr_WebUserNoteReminderID;}
            set {SetDirty(_prwunr_WebUserNoteReminderID, value);
                 _prwunr_WebUserNoteReminderID = value;}
        }

        /// <summary>
        /// Accessor for the prwunr_WorkflowId property.
        /// </summary>
        public int prwunr_WorkflowId {
            get {return _prwunr_WorkflowId;}
            set {SetDirty(_prwunr_WorkflowId, value);
                 _prwunr_WorkflowId = value;}
        }

        /// <summary>
        /// Accessor for the prwunr_AMPM property.
        /// </summary>
        public string prwunr_AMPM {
            get {return _prwunr_AMPM;}
            set {SetDirty(_prwunr_AMPM, value);
                 _prwunr_AMPM = value;}
        }

        /// <summary>
        /// Accessor for the prwunr_Email property.
        /// </summary>
        public string prwunr_Email {
            get {return _prwunr_Email;}
            set {SetDirty(_prwunr_Email, value);
                 _prwunr_Email = value;}
        }

        /// <summary>
        /// Accessor for the prwunr_Hour property.
        /// </summary>
        public string prwunr_Hour {
            get {return _prwunr_Hour;}
            set {SetDirty(_prwunr_Hour, value);
                 _prwunr_Hour = value;}
        }

        /// <summary>
        /// Accessor for the prwunr_Minute property.
        /// </summary>
        public string prwunr_Minute {
            get {return _prwunr_Minute;}
            set {SetDirty(_prwunr_Minute, value);
                 _prwunr_Minute = value;}
        }

        /// <summary>
        /// Accessor for the prwunr_Phone property.
        /// </summary>
        public string prwunr_Phone {
            get {return _prwunr_Phone;}
            set {SetDirty(_prwunr_Phone, value);
                 _prwunr_Phone = value;}
        }

        /// <summary>
        /// Accessor for the prwunr_Threshold property.
        /// </summary>
        public string prwunr_Threshold {
            get {return _prwunr_Threshold;}
            set {SetDirty(_prwunr_Threshold, value);
                 _prwunr_Threshold = value;}
        }

        /// <summary>
        /// Accessor for the prwunr_Timezone property.
        /// </summary>
        public string prwunr_Timezone {
            get {return _prwunr_Timezone;}
            set {SetDirty(_prwunr_Timezone, value);
                 _prwunr_Timezone = value;}
        }

        /// <summary>
        /// Accessor for the prwunr_Type property.
        /// </summary>
        public string prwunr_Type {
            get {return _prwunr_Type;}
            set {SetDirty(_prwunr_Type, value);
                 _prwunr_Type = value;}
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
                _htFieldColMapping.Add("prwunr_CreatedDate",			PRWebUserNoteReminderMgr.COL_PRWUNR_CREATED_DATE);
                _htFieldColMapping.Add("prwunr_Date",					PRWebUserNoteReminderMgr.COL_PRWUNR_DATE);
                _htFieldColMapping.Add("prwunr_DateUTC",				PRWebUserNoteReminderMgr.COL_PRWUNR_DATE_UTC);
                _htFieldColMapping.Add("prwunr_SentDateTime",			PRWebUserNoteReminderMgr.COL_PRWUNR_SENT_DATE_TIME);
                _htFieldColMapping.Add("prwunr_SentDateTimeUTC",		PRWebUserNoteReminderMgr.COL_PRWUNR_SENT_DATE_TIME_UTC);
                _htFieldColMapping.Add("prwunr_TimeStamp",				PRWebUserNoteReminderMgr.COL_PRWUNR_TIME_STAMP);
                _htFieldColMapping.Add("prwunr_UpdatedDate",			PRWebUserNoteReminderMgr.COL_PRWUNR_UPDATED_DATE);
                _htFieldColMapping.Add("prwunr_CreatedBy",				PRWebUserNoteReminderMgr.COL_PRWUNR_CREATED_BY);
                _htFieldColMapping.Add("prwunr_Deleted",				PRWebUserNoteReminderMgr.COL_PRWUNR_DELETED);
                _htFieldColMapping.Add("prwunr_Secterr",				PRWebUserNoteReminderMgr.COL_PRWUNR_SECTERR);
                _htFieldColMapping.Add("prwunr_UpdatedBy",				PRWebUserNoteReminderMgr.COL_PRWUNR_UPDATED_BY);
                _htFieldColMapping.Add("prwunr_WebUserID",				PRWebUserNoteReminderMgr.COL_PRWUNR_WEB_USER_ID);
                _htFieldColMapping.Add("prwunr_WebUserNoteID",			PRWebUserNoteReminderMgr.COL_PRWUNR_WEB_USER_NOTE_ID);
                _htFieldColMapping.Add("prwunr_WebUserNoteReminderID",	PRWebUserNoteReminderMgr.COL_PRWUNR_WEB_USER_NOTE_REMINDER_ID);
                _htFieldColMapping.Add("prwunr_WorkflowId",				PRWebUserNoteReminderMgr.COL_PRWUNR_WORKFLOW_ID);
                _htFieldColMapping.Add("prwunr_AMPM",					PRWebUserNoteReminderMgr.COL_PRWUNR_AMPM);
                _htFieldColMapping.Add("prwunr_Email",					PRWebUserNoteReminderMgr.COL_PRWUNR_EMAIL);
                _htFieldColMapping.Add("prwunr_Hour",					PRWebUserNoteReminderMgr.COL_PRWUNR_HOUR);
                _htFieldColMapping.Add("prwunr_Minute",					PRWebUserNoteReminderMgr.COL_PRWUNR_MINUTE);
                _htFieldColMapping.Add("prwunr_Phone",					PRWebUserNoteReminderMgr.COL_PRWUNR_PHONE);
                _htFieldColMapping.Add("prwunr_Threshold",				PRWebUserNoteReminderMgr.COL_PRWUNR_THRESHOLD);
                _htFieldColMapping.Add("prwunr_Timezone",				PRWebUserNoteReminderMgr.COL_PRWUNR_TIMEZONE);
                _htFieldColMapping.Add("prwunr_Type",					PRWebUserNoteReminderMgr.COL_PRWUNR_TYPE);
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

            _prwunr_CreatedDate				 = _oMgr.GetDateTime(oData[PRWebUserNoteReminderMgr.COL_PRWUNR_CREATED_DATE]);
            _prwunr_Date					 = _oMgr.GetDateTime(oData[PRWebUserNoteReminderMgr.COL_PRWUNR_DATE]);
            _prwunr_DateUTC					 = _oMgr.GetDateTime(oData[PRWebUserNoteReminderMgr.COL_PRWUNR_DATE_UTC]);
            _prwunr_SentDateTime			 = _oMgr.GetDateTime(oData[PRWebUserNoteReminderMgr.COL_PRWUNR_SENT_DATE_TIME]);
            _prwunr_SentDateTimeUTC			 = _oMgr.GetDateTime(oData[PRWebUserNoteReminderMgr.COL_PRWUNR_SENT_DATE_TIME_UTC]);
            _prwunr_TimeStamp				 = _oMgr.GetDateTime(oData[PRWebUserNoteReminderMgr.COL_PRWUNR_TIME_STAMP]);
            _prwunr_UpdatedDate				 = _oMgr.GetDateTime(oData[PRWebUserNoteReminderMgr.COL_PRWUNR_UPDATED_DATE]);
            _prwunr_CreatedBy				 = _oMgr.GetInt(oData[PRWebUserNoteReminderMgr.COL_PRWUNR_CREATED_BY]);
            _prwunr_Deleted					 = _oMgr.GetInt(oData[PRWebUserNoteReminderMgr.COL_PRWUNR_DELETED]);
            _prwunr_Secterr					 = _oMgr.GetInt(oData[PRWebUserNoteReminderMgr.COL_PRWUNR_SECTERR]);
            _prwunr_UpdatedBy				 = _oMgr.GetInt(oData[PRWebUserNoteReminderMgr.COL_PRWUNR_UPDATED_BY]);
            _prwunr_WebUserID				 = _oMgr.GetInt(oData[PRWebUserNoteReminderMgr.COL_PRWUNR_WEB_USER_ID]);
            _prwunr_WebUserNoteID			 = _oMgr.GetInt(oData[PRWebUserNoteReminderMgr.COL_PRWUNR_WEB_USER_NOTE_ID]);
            _prwunr_WebUserNoteReminderID	 = _oMgr.GetInt(oData[PRWebUserNoteReminderMgr.COL_PRWUNR_WEB_USER_NOTE_REMINDER_ID]);
            _prwunr_WorkflowId				 = _oMgr.GetInt(oData[PRWebUserNoteReminderMgr.COL_PRWUNR_WORKFLOW_ID]);
            _prwunr_AMPM					 = _oMgr.GetString(oData[PRWebUserNoteReminderMgr.COL_PRWUNR_AMPM]);
            _prwunr_Email					 = _oMgr.GetString(oData[PRWebUserNoteReminderMgr.COL_PRWUNR_EMAIL]);
            _prwunr_Hour					 = _oMgr.GetString(oData[PRWebUserNoteReminderMgr.COL_PRWUNR_HOUR]);
            _prwunr_Minute					 = _oMgr.GetString(oData[PRWebUserNoteReminderMgr.COL_PRWUNR_MINUTE]);
            _prwunr_Phone					 = _oMgr.GetString(oData[PRWebUserNoteReminderMgr.COL_PRWUNR_PHONE]);
            _prwunr_Threshold				 = _oMgr.GetString(oData[PRWebUserNoteReminderMgr.COL_PRWUNR_THRESHOLD]);
            _prwunr_Timezone				 = _oMgr.GetString(oData[PRWebUserNoteReminderMgr.COL_PRWUNR_TIMEZONE]);
            _prwunr_Type					 = _oMgr.GetString(oData[PRWebUserNoteReminderMgr.COL_PRWUNR_TYPE]);
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
            if (iOptions != PRWebUserNoteReminderMgr.OPT_LOAD_SAVE) {
                oData.Add(PRWebUserNoteReminderMgr.COL_PRWUNR_WEB_USER_NOTE_REMINDER_ID,	_prwunr_WebUserNoteReminderID);
            }

            oData.Add(PRWebUserNoteReminderMgr.COL_PRWUNR_CREATED_DATE,					_prwunr_CreatedDate);
            oData.Add(PRWebUserNoteReminderMgr.COL_PRWUNR_DATE,							_prwunr_Date);
            oData.Add(PRWebUserNoteReminderMgr.COL_PRWUNR_DATE_UTC,						_prwunr_DateUTC);
            oData.Add(PRWebUserNoteReminderMgr.COL_PRWUNR_SENT_DATE_TIME,				_prwunr_SentDateTime);
            oData.Add(PRWebUserNoteReminderMgr.COL_PRWUNR_SENT_DATE_TIME_UTC,			_prwunr_SentDateTimeUTC);
            oData.Add(PRWebUserNoteReminderMgr.COL_PRWUNR_TIME_STAMP,					_prwunr_TimeStamp);
            oData.Add(PRWebUserNoteReminderMgr.COL_PRWUNR_UPDATED_DATE,					_prwunr_UpdatedDate);
            oData.Add(PRWebUserNoteReminderMgr.COL_PRWUNR_CREATED_BY,					_prwunr_CreatedBy);
            oData.Add(PRWebUserNoteReminderMgr.COL_PRWUNR_DELETED,						_prwunr_Deleted);
            oData.Add(PRWebUserNoteReminderMgr.COL_PRWUNR_SECTERR,						_prwunr_Secterr);
            oData.Add(PRWebUserNoteReminderMgr.COL_PRWUNR_UPDATED_BY,					_prwunr_UpdatedBy);
            oData.Add(PRWebUserNoteReminderMgr.COL_PRWUNR_WEB_USER_ID,					_prwunr_WebUserID);
            oData.Add(PRWebUserNoteReminderMgr.COL_PRWUNR_WEB_USER_NOTE_ID,				_prwunr_WebUserNoteID);
            oData.Add(PRWebUserNoteReminderMgr.COL_PRWUNR_WORKFLOW_ID,					_prwunr_WorkflowId);
            oData.Add(PRWebUserNoteReminderMgr.COL_PRWUNR_AMPM,							_prwunr_AMPM);
            oData.Add(PRWebUserNoteReminderMgr.COL_PRWUNR_EMAIL,						_prwunr_Email);
            oData.Add(PRWebUserNoteReminderMgr.COL_PRWUNR_HOUR,							_prwunr_Hour);
            oData.Add(PRWebUserNoteReminderMgr.COL_PRWUNR_MINUTE,						_prwunr_Minute);
            oData.Add(PRWebUserNoteReminderMgr.COL_PRWUNR_PHONE,						_prwunr_Phone);
            oData.Add(PRWebUserNoteReminderMgr.COL_PRWUNR_THRESHOLD,					_prwunr_Threshold);
            oData.Add(PRWebUserNoteReminderMgr.COL_PRWUNR_TIMEZONE,						_prwunr_Timezone);
            oData.Add(PRWebUserNoteReminderMgr.COL_PRWUNR_TYPE,							_prwunr_Type);
        }
        #endregion

    }
}
