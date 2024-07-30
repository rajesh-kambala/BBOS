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

 ClassName: PRWebUserNote
 Description:	

 Notes:	Created By TSI Class Generator on 8/20/2014 8:41:03 AM

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using TSI.Arch;
using TSI.BusinessObjects;

namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Provides the functionality for the PRWebUserNote.
    /// </summary>
    public partial class PRWebUserNote : EBBObject, IPRWebUserNote
    {
        protected bool		_prwun_IsPrivate;
        protected bool		_prwun_Key;
        protected DateTime	_prwun_CreatedDate;
        protected DateTime	_prwun_Date;
        protected DateTime	_prwun_DateUTC;
        protected DateTime	_prwun_TimeStamp;
        protected DateTime	_prwun_UpdatedDate;
        protected int		_prwun_AssociatedID;
        protected int		_prwun_CompanyID;
        protected int		_prwun_CreatedBy;
        protected int		_prwun_HQID;
        protected int		_prwun_UpdatedBy;
        protected int		_prwun_WebUserID;
        protected int		_prwun_WebUserNoteID;
        protected string	_prwun_AMPM;
        protected string	_prwun_AssociatedType;
        protected string	_prwun_Hour;
        protected string	_prwun_Minute;
        protected string	_prwun_Note;
        protected string	_prwun_Subject;
        protected string	_prwun_Timezone;
        protected DateTime _prwun_NoteUpdatedDateTime;
        protected int _prwun_NoteUpdatedBy;

        /// <summary>
        /// Constructor
        /// </summary>
        public PRWebUserNote() {}

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
                _oKeyValues.Add(prwun_WebUserNoteID);
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
            prwun_WebUserNoteID = 0;
        }

        /// <summary>
        /// Sets the key values for this object based
        /// on the specified list of values.  The list of
        /// values must be in the same order the keys are
        /// defined in GetKeyValues();
        /// </summary>
        /// <param name="oKeyValues">IList</param>
        override public void SetKeyValues(IList oKeyValues) {
            prwun_WebUserNoteID = Convert.ToInt32(oKeyValues[0]);
        }

        /// <summary>
        /// Accessor for the prwun_IsPrivate property.
        /// </summary>
        public bool prwun_IsPrivate {
            get {return _prwun_IsPrivate;}
            set {SetDirty(_prwun_IsPrivate, value);
                 _prwun_IsPrivate = value;}
        }

        /// <summary>
        /// Accessor for the prwun_Key property.
        /// </summary>
        public bool prwun_Key {
            get {return _prwun_Key;}
            set {SetDirty(_prwun_Key, value);
                 _prwun_Key = value;}
        }

        /// <summary>
        /// Accessor for the prwun_CreatedDate property.
        /// </summary>
        public DateTime prwun_CreatedDate {
            get {return _prwun_CreatedDate;}
            set {SetDirty(_prwun_CreatedDate, value);
                 _prwun_CreatedDate = value;}
        }

        /// <summary>
        /// Accessor for the prwun_Date property.
        /// </summary>
        public DateTime prwun_Date {
            get {return _prwun_Date;}
            set {SetDirty(_prwun_Date, value);
                 _prwun_Date = value;}
        }

        /// <summary>
        /// Accessor for the prwun_DateUTC property.
        /// </summary>
        public DateTime prwun_DateUTC {
            get {return _prwun_DateUTC;}
            set {SetDirty(_prwun_DateUTC, value);
                 _prwun_DateUTC = value;}
        }

        /// <summary>
        /// Accessor for the prwun_TimeStamp property.
        /// </summary>
        public DateTime prwun_TimeStamp {
            get {return _prwun_TimeStamp;}
            set {SetDirty(_prwun_TimeStamp, value);
                 _prwun_TimeStamp = value;}
        }

        /// <summary>
        /// Accessor for the prwun_UpdatedDate property.
        /// </summary>
        public DateTime prwun_UpdatedDate {
            get {return _prwun_UpdatedDate;}
            set {SetDirty(_prwun_UpdatedDate, value);
                 _prwun_UpdatedDate = value;}
        }

        /// <summary>
        /// Accessor for the prwun_AssociatedID property.
        /// </summary>
        public int prwun_AssociatedID {
            get {return _prwun_AssociatedID;}
            set {SetDirty(_prwun_AssociatedID, value);
                 _prwun_AssociatedID = value;}
        }

        /// <summary>
        /// Accessor for the prwun_CompanyID property.
        /// </summary>
        public int prwun_CompanyID {
            get {return _prwun_CompanyID;}
            set {SetDirty(_prwun_CompanyID, value);
                 _prwun_CompanyID = value;}
        }

        /// <summary>
        /// Accessor for the prwun_CreatedBy property.
        /// </summary>
        public int prwun_CreatedBy {
            get {return _prwun_CreatedBy;}
            set {SetDirty(_prwun_CreatedBy, value);
                 _prwun_CreatedBy = value;}
        }

        /// <summary>
        /// Accessor for the prwun_HQID property.
        /// </summary>
        public int prwun_HQID {
            get {return _prwun_HQID;}
            set {SetDirty(_prwun_HQID, value);
                 _prwun_HQID = value;}
        }

        /// <summary>
        /// Accessor for the prwun_UpdatedBy property.
        /// </summary>
        public int prwun_UpdatedBy {
            get {return _prwun_UpdatedBy;}
            set {SetDirty(_prwun_UpdatedBy, value);
                 _prwun_UpdatedBy = value;}
        }

        /// <summary>
        /// Accessor for the prwun_WebUserID property.
        /// </summary>
        public int prwun_WebUserID {
            get {return _prwun_WebUserID;}
            set {SetDirty(_prwun_WebUserID, value);
                 _prwun_WebUserID = value;}
        }

        /// <summary>
        /// Accessor for the prwun_WebUserNoteID property.
        /// </summary>
        public int prwun_WebUserNoteID {
            get {return _prwun_WebUserNoteID;}
            set {SetDirty(_prwun_WebUserNoteID, value);
                 _prwun_WebUserNoteID = value;}
        }

        /// <summary>
        /// Accessor for the prwun_AMPM property.
        /// </summary>
        public string prwun_AMPM {
            get {return _prwun_AMPM;}
            set {SetDirty(_prwun_AMPM, value);
                 _prwun_AMPM = value;}
        }

        /// <summary>
        /// Accessor for the prwun_AssociatedType property.
        /// </summary>
        public string prwun_AssociatedType {
            get {return _prwun_AssociatedType;}
            set {SetDirty(_prwun_AssociatedType, value);
                 _prwun_AssociatedType = value;}
        }

        /// <summary>
        /// Accessor for the prwun_Hour property.
        /// </summary>
        public string prwun_Hour {
            get {return _prwun_Hour;}
            set {SetDirty(_prwun_Hour, value);
                 _prwun_Hour = value;}
        }

        /// <summary>
        /// Accessor for the prwun_Minute property.
        /// </summary>
        public string prwun_Minute {
            get {return _prwun_Minute;}
            set {SetDirty(_prwun_Minute, value);
                 _prwun_Minute = value;}
        }

        /// <summary>
        /// Accessor for the prwun_Note property.
        /// </summary>
        public string prwun_Note {
            get {return _prwun_Note;}
            set {SetDirty(_prwun_Note, value);

                    if (_prwun_Note != value)
                    {
                        _noteTextChanged = true;
                    }

                 _prwun_Note = value;}
        }

        /// <summary>
        /// Accessor for the prwun_Subject property.
        /// </summary>
        public string prwun_Subject {
            get {return _prwun_Subject;}
            set {SetDirty(_prwun_Subject, value);
                 _prwun_Subject = value;}
        }

        /// <summary>
        /// Accessor for the prwun_Timezone property.
        /// </summary>
        public string prwun_Timezone {
            get {return _prwun_Timezone;}
            set {SetDirty(_prwun_Timezone, value);
                 _prwun_Timezone = value;}
        }

        public DateTime prwun_NoteUpdatedDateTime
        {
            get { return _prwun_NoteUpdatedDateTime; }
            set
            {
                SetDirty(_prwun_NoteUpdatedDateTime, value);
                _prwun_NoteUpdatedDateTime = value;
            }
        }

        public int prwun_NoteUpdatedBy
        {
            get { return _prwun_NoteUpdatedBy; }
            set
            {
                SetDirty(_prwun_NoteUpdatedBy, value);
                _prwun_NoteUpdatedBy = value;
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
                _htFieldColMapping.Add("prwun_IsPrivate",		PRWebUserNoteMgr.COL_PRWUN_IS_PRIVATE);
                _htFieldColMapping.Add("prwun_Key",				PRWebUserNoteMgr.COL_PRWUN_KEY);
                _htFieldColMapping.Add("prwun_CreatedDate",		PRWebUserNoteMgr.COL_PRWUN_CREATED_DATE);
                _htFieldColMapping.Add("prwun_Date",			PRWebUserNoteMgr.COL_PRWUN_DATE);
                _htFieldColMapping.Add("prwun_DateUTC",			PRWebUserNoteMgr.COL_PRWUN_DATE_UTC);
                _htFieldColMapping.Add("prwun_TimeStamp",		PRWebUserNoteMgr.COL_PRWUN_TIME_STAMP);
                _htFieldColMapping.Add("prwun_UpdatedDate",		PRWebUserNoteMgr.COL_PRWUN_UPDATED_DATE);
                _htFieldColMapping.Add("prwun_AssociatedID",	PRWebUserNoteMgr.COL_PRWUN_ASSOCIATED_ID);
                _htFieldColMapping.Add("prwun_CompanyID",		PRWebUserNoteMgr.COL_PRWUN_COMPANY_ID);
                _htFieldColMapping.Add("prwun_CreatedBy",		PRWebUserNoteMgr.COL_PRWUN_CREATED_BY);
                _htFieldColMapping.Add("prwun_HQID",			PRWebUserNoteMgr.COL_PRWUN_HQID);
                _htFieldColMapping.Add("prwun_UpdatedBy",		PRWebUserNoteMgr.COL_PRWUN_UPDATED_BY);
                _htFieldColMapping.Add("prwun_WebUserID",		PRWebUserNoteMgr.COL_PRWUN_WEB_USER_ID);
                _htFieldColMapping.Add("prwun_WebUserNoteID",	PRWebUserNoteMgr.COL_PRWUN_WEB_USER_NOTE_ID);
                _htFieldColMapping.Add("prwun_AMPM",			PRWebUserNoteMgr.COL_PRWUN_AMPM);
                _htFieldColMapping.Add("prwun_AssociatedType",	PRWebUserNoteMgr.COL_PRWUN_ASSOCIATED_TYPE);
                _htFieldColMapping.Add("prwun_Hour",			PRWebUserNoteMgr.COL_PRWUN_HOUR);
                _htFieldColMapping.Add("prwun_Minute",			PRWebUserNoteMgr.COL_PRWUN_MINUTE);
                _htFieldColMapping.Add("prwun_Note",			PRWebUserNoteMgr.COL_PRWUN_NOTE);
                _htFieldColMapping.Add("prwun_Subject",			PRWebUserNoteMgr.COL_PRWUN_SUBJECT);
                _htFieldColMapping.Add("prwun_Timezone",		PRWebUserNoteMgr.COL_PRWUN_TIMEZONE);
                _htFieldColMapping.Add("prwun_NoteUpdatedDateTime", PRWebUserNoteMgr.COL_PRWUN_NOTE_UPDATE_DATE_TIME);
                _htFieldColMapping.Add("prwun_NoteUpdatedBy", PRWebUserNoteMgr.COL_PRWUN_NOTE_UPDATE_BY);
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

            _prwun_IsPrivate		 = _oMgr.GetBool(oData[PRWebUserNoteMgr.COL_PRWUN_IS_PRIVATE]);
            _prwun_Key				 = _oMgr.GetBool(oData[PRWebUserNoteMgr.COL_PRWUN_KEY]);
            _prwun_CreatedDate		 = _oMgr.GetDateTime(oData[PRWebUserNoteMgr.COL_PRWUN_CREATED_DATE]);
            _prwun_Date				 = _oMgr.GetDateTime(oData[PRWebUserNoteMgr.COL_PRWUN_DATE]);
            _prwun_DateUTC			 = _oMgr.GetDateTime(oData[PRWebUserNoteMgr.COL_PRWUN_DATE_UTC]);
            _prwun_TimeStamp		 = _oMgr.GetDateTime(oData[PRWebUserNoteMgr.COL_PRWUN_TIME_STAMP]);
            _prwun_UpdatedDate		 = _oMgr.GetDateTime(oData[PRWebUserNoteMgr.COL_PRWUN_UPDATED_DATE]);
            _prwun_AssociatedID		 = _oMgr.GetInt(oData[PRWebUserNoteMgr.COL_PRWUN_ASSOCIATED_ID]);
            _prwun_CompanyID		 = _oMgr.GetInt(oData[PRWebUserNoteMgr.COL_PRWUN_COMPANY_ID]);
            _prwun_CreatedBy		 = _oMgr.GetInt(oData[PRWebUserNoteMgr.COL_PRWUN_CREATED_BY]);
            _prwun_HQID				 = _oMgr.GetInt(oData[PRWebUserNoteMgr.COL_PRWUN_HQID]);
            _prwun_UpdatedBy		 = _oMgr.GetInt(oData[PRWebUserNoteMgr.COL_PRWUN_UPDATED_BY]);
            _prwun_WebUserID		 = _oMgr.GetInt(oData[PRWebUserNoteMgr.COL_PRWUN_WEB_USER_ID]);
            _prwun_WebUserNoteID	 = _oMgr.GetInt(oData[PRWebUserNoteMgr.COL_PRWUN_WEB_USER_NOTE_ID]);
            _prwun_AMPM				 = _oMgr.GetString(oData[PRWebUserNoteMgr.COL_PRWUN_AMPM]);
            _prwun_AssociatedType	 = _oMgr.GetString(oData[PRWebUserNoteMgr.COL_PRWUN_ASSOCIATED_TYPE]);
            _prwun_Hour				 = _oMgr.GetString(oData[PRWebUserNoteMgr.COL_PRWUN_HOUR]);
            _prwun_Minute			 = _oMgr.GetString(oData[PRWebUserNoteMgr.COL_PRWUN_MINUTE]);
            _prwun_Note				 = _oMgr.GetString(oData[PRWebUserNoteMgr.COL_PRWUN_NOTE]);
            _prwun_Subject			 = _oMgr.GetString(oData[PRWebUserNoteMgr.COL_PRWUN_SUBJECT]);
            _prwun_Timezone			 = _oMgr.GetString(oData[PRWebUserNoteMgr.COL_PRWUN_TIMEZONE]);
            _prwun_NoteUpdatedDateTime = _oMgr.GetDateTime(oData[PRWebUserNoteMgr.COL_PRWUN_NOTE_UPDATE_DATE_TIME]);
            _prwun_NoteUpdatedBy    = _oMgr.GetInt(oData[PRWebUserNoteMgr.COL_PRWUN_NOTE_UPDATE_BY]);
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
            if (iOptions != PRWebUserNoteMgr.OPT_LOAD_SAVE) {
                oData.Add(PRWebUserNoteMgr.COL_PRWUN_WEB_USER_NOTE_ID,	_prwun_WebUserNoteID);
            }

            oData.Add(PRWebUserNoteMgr.COL_PRWUN_CREATED_BY, _szCreatedUserID);
            oData.Add(PRWebUserNoteMgr.COL_PRWUN_CREATED_DATE, _dtCreatedDateTime);
            oData.Add(PRWebUserNoteMgr.COL_PRWUN_UPDATED_BY, _szUpdatedUserID);
            oData.Add(PRWebUserNoteMgr.COL_PRWUN_UPDATED_DATE, _dtUpdatedDateTime);
            oData.Add(PRWebUserNoteMgr.COL_PRWUN_TIME_STAMP, DateTime.Now);

            oData.Add(PRWebUserNoteMgr.COL_PRWUN_IS_PRIVATE,        ((PRWebUserNoteMgr)_oMgr).GetPIKSCoreBool(_prwun_IsPrivate));
            oData.Add(PRWebUserNoteMgr.COL_PRWUN_KEY,               ((PRWebUserNoteMgr)_oMgr).GetPIKSCoreBool(_prwun_Key));
            oData.Add(PRWebUserNoteMgr.COL_PRWUN_DATE,				_prwun_Date);
            oData.Add(PRWebUserNoteMgr.COL_PRWUN_DATE_UTC,			_prwun_DateUTC);
            oData.Add(PRWebUserNoteMgr.COL_PRWUN_ASSOCIATED_ID,		_prwun_AssociatedID);
            oData.Add(PRWebUserNoteMgr.COL_PRWUN_COMPANY_ID,		_prwun_CompanyID);
            oData.Add(PRWebUserNoteMgr.COL_PRWUN_HQID,				_prwun_HQID);
            oData.Add(PRWebUserNoteMgr.COL_PRWUN_WEB_USER_ID,		_prwun_WebUserID);
            oData.Add(PRWebUserNoteMgr.COL_PRWUN_AMPM,				_prwun_AMPM);
            oData.Add(PRWebUserNoteMgr.COL_PRWUN_ASSOCIATED_TYPE,	_prwun_AssociatedType);
            oData.Add(PRWebUserNoteMgr.COL_PRWUN_HOUR,				_prwun_Hour);
            oData.Add(PRWebUserNoteMgr.COL_PRWUN_MINUTE,			_prwun_Minute);
            oData.Add(PRWebUserNoteMgr.COL_PRWUN_NOTE,				_prwun_Note);
            oData.Add(PRWebUserNoteMgr.COL_PRWUN_SUBJECT,			_prwun_Subject);
            oData.Add(PRWebUserNoteMgr.COL_PRWUN_TIMEZONE,			_prwun_Timezone);
            oData.Add(PRWebUserNoteMgr.COL_PRWUN_NOTE_UPDATE_DATE_TIME, _prwun_NoteUpdatedDateTime);
            oData.Add(PRWebUserNoteMgr.COL_PRWUN_NOTE_UPDATE_BY, _prwun_NoteUpdatedBy);
        }
        #endregion

    }
}
