/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007

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

 Notes:	Created By TSI Class Generator on 7/17/2007 1:11:32 PM

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Xml;
using System.Xml.Serialization;

using TSI.Arch;
using TSI.DataAccess;
using TSI.BusinessObjects;
using TSI.Utils;

using PRCo.EBB.Util;

namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Provides the functionality for the PRWebUserSearchCriteria.
    /// </summary>
    [Serializable]
    public class PRWebUserSearchCriteria : EBBObject, IPRWebUserSearchCriteria
    {
    
        public const string SEARCH_TYPE_COMPANY = "Company";
        public const string SEARCH_TYPE_PERSON = "Person";        
        public const string SEARCH_TYPE_COMPANY_UPDATE = "CompanyUpdate";
        public const string SEARCH_TYPE_CLAIM_ACTIVITY = "ClaimActivity";
    
        protected int _iprsc_SearchCriteriaID;

        protected DateTime	_dtprsc_LastExecutionDateTime;
        protected DateTime _dtprsc_TimeStamp;
        
        protected int		_iprsc_CompanyID;
        protected int		_iprsc_ExecutionCount;
        protected int		_iprsc_HQID;
        protected int		_iprsc_LastExecutionResultCount;
        protected int       _iprsc_WebUserID;

        protected string	_szprsc_Criteria;
        protected string    _szprsc_Name;
        protected string    _szprsc_SearchType;
        protected string    _szprsc_SelectedIDs;

        protected bool	_bprsc_IsLastUnsavedSearch;
        protected bool	_bprsc_IsPrivate;

        protected SearchCriteriaBase _oCriteria;
        protected bool _bIsCriteriaDirty;

        protected IPRWebUser _oWebUser;

        /// <summary>
        /// Constructor
        /// </summary>
        public PRWebUserSearchCriteria() { }

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
                _oKeyValues.Add(prsc_SearchCriteriaID);
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
            prsc_SearchCriteriaID = Convert.ToInt32(oKeyValues[0]);
        }

        /// <summary>
        /// Accessor for the prsc_LastExecutionDateTime property.
        /// </summary>
        public DateTime prsc_LastExecutionDateTime {
            get {return _dtprsc_LastExecutionDateTime;}
            set {SetDirty(_dtprsc_LastExecutionDateTime, value);
                 _dtprsc_LastExecutionDateTime = value;}
        }


        /// <summary>
        /// Accessor for the prsc_CompanyID property.
        /// </summary>
        public int prsc_CompanyID {
            get {return _iprsc_CompanyID;}
            set {SetDirty(_iprsc_CompanyID, value);
                 _iprsc_CompanyID = value;}
        }


        /// <summary>
        /// Accessor for the prsc_ExecutionCount property.
        /// </summary>
        public int prsc_ExecutionCount {
            get {return _iprsc_ExecutionCount;}
            set {SetDirty(_iprsc_ExecutionCount, value);
                 _iprsc_ExecutionCount = value;}
        }

        /// <summary>
        /// Accessor for the prsc_HQID property.
        /// </summary>
        public int prsc_HQID {
            get {return _iprsc_HQID;}
            set {SetDirty(_iprsc_HQID, value);
                 _iprsc_HQID = value;}
        }

        /// <summary>
        /// Accessor for the prsc_LastExecutionResultCount property.
        /// </summary>
        public int prsc_LastExecutionResultCount {
            get {return _iprsc_LastExecutionResultCount;}
            set {SetDirty(_iprsc_LastExecutionResultCount, value);
                 _iprsc_LastExecutionResultCount = value;}
        }

        /// <summary>
        /// Accessor for the prsc_SearchCriteriaID property.
        /// </summary>
        public int prsc_SearchCriteriaID {
            get {return _iprsc_SearchCriteriaID;}
            set {SetDirty(_iprsc_SearchCriteriaID, value);
                 _iprsc_SearchCriteriaID = value;
                 _oKeyValues = null;}
        }


        /// <summary>
        /// Accessor for the prsc_WebUserID property.
        /// </summary>
        public int prsc_WebUserID {
            get {return _iprsc_WebUserID;}
            set {SetDirty(_iprsc_WebUserID, value);
                 _iprsc_WebUserID = value;}
        }


        /// <summary>
        /// Accessor for the prsc_Criteria property.
        /// </summary>
        public string prsc_Criteria {
            get {return _szprsc_Criteria;}
            set {SetDirty(_szprsc_Criteria, value);
                 _szprsc_Criteria = value;}
        }

        /// <summary>
        /// Accessor for the prsc_IsLastUnsavedSearch property.
        /// </summary>
        public bool prsc_IsLastUnsavedSearch {
            get {return _bprsc_IsLastUnsavedSearch;}
            set {SetDirty(_bprsc_IsLastUnsavedSearch, value);
                 _bprsc_IsLastUnsavedSearch = value;}
        }

        /// <summary>
        /// Accessor for the prsc_IsPrivate property.
        /// </summary>
        public bool prsc_IsPrivate {
            get {return _bprsc_IsPrivate;}
            set {SetDirty(_bprsc_IsPrivate, value);
                 _bprsc_IsPrivate = value;}
        }

        /// <summary>
        /// Accessor for the prsc_Name property.
        /// </summary>
        public string prsc_Name {
            get {return _szprsc_Name;}
            set {SetDirty(_szprsc_Name, value);
                 _szprsc_Name = value;}
        }

        /// <summary>
        /// Accessor for the prsc_SearchType property.
        /// </summary>
        public string prsc_SearchType {
            get {return _szprsc_SearchType;}
            set {SetDirty(_szprsc_SearchType, value);
                 _szprsc_SearchType = value;}
        }

        /// <summary>
        /// Accessor for the prsc_SelectedIDs property.
        /// </summary>
        public string prsc_SelectedIDs {
            get {return _szprsc_SelectedIDs;}
            set {SetDirty(_szprsc_SelectedIDs, value);
                 _szprsc_SelectedIDs = value;}
        }

        /// <summary>
        /// Accessor for the Criteria property
        /// </summary>
        public SearchCriteriaBase Criteria
        {
            get {   if (_oCriteria == null) {
                        switch(_szprsc_SearchType) {
                            case SEARCH_TYPE_COMPANY:
                                _oCriteria = new CompanySearchCriteria();
                                break;
                            case SEARCH_TYPE_PERSON:
                                _oCriteria = new PersonSearchCriteria();
                                break;
                            case SEARCH_TYPE_COMPANY_UPDATE:
                                _oCriteria = new CreditSheetSearchCriteria();
                                break;
                            case SEARCH_TYPE_CLAIM_ACTIVITY:
                                _oCriteria = new ClaimActivitySearchCriteria();
                                break;
                            default:
                                throw new ApplicationUnexpectedException("Invalid Search Type");
                        }
                    }

                    _oCriteria.WebUser = _oWebUser;
                    return _oCriteria; 
                }
            set
            {
                SetDirty(_oCriteria, value);
                IsCriteriaDirty = true;
                _oCriteria = value;
            }
        }

        /// <summary>
        /// Accessor for the IsCriteriaDirty property
        /// </summary>
        public bool IsCriteriaDirty
        {
            get { return _bIsCriteriaDirty; }
            set {_bIsCriteriaDirty = value; }
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
                _htFieldColMapping.Add("prsc_LastExecutionDateTime",	PRWebUserSearchCriteriaMgr.COL_PRSC_LAST_EXECUTION_DATE_TIME);
                _htFieldColMapping.Add("prsc_CompanyID",				PRWebUserSearchCriteriaMgr.COL_PRSC_COMPANY_ID);
                _htFieldColMapping.Add("prsc_ExecutionCount",			PRWebUserSearchCriteriaMgr.COL_PRSC_EXECUTION_COUNT);
                _htFieldColMapping.Add("prsc_HQID",						PRWebUserSearchCriteriaMgr.COL_PRSC_HQID);
                _htFieldColMapping.Add("prsc_LastExecutionResultCount",	PRWebUserSearchCriteriaMgr.COL_PRSC_LAST_EXECUTION_RESULT_COUNT);
                _htFieldColMapping.Add("prsc_SearchCriteriaID",			PRWebUserSearchCriteriaMgr.COL_PRSC_SEARCH_CRITERIA_ID);
                _htFieldColMapping.Add("prsc_WebUserID",				PRWebUserSearchCriteriaMgr.COL_PRSC_WEB_USER_ID);
                _htFieldColMapping.Add("prsc_Criteria",					PRWebUserSearchCriteriaMgr.COL_PRSC_CRITERIA);
                _htFieldColMapping.Add("prsc_IsLastUnsavedSearch",		PRWebUserSearchCriteriaMgr.COL_PRSC_IS_LAST_UNSAVED_SEARCH);
                _htFieldColMapping.Add("prsc_IsPrivate",				PRWebUserSearchCriteriaMgr.COL_PRSC_IS_PRIVATE);
                _htFieldColMapping.Add("prsc_Name",						PRWebUserSearchCriteriaMgr.COL_PRSC_NAME);
                _htFieldColMapping.Add("prsc_SearchType",				PRWebUserSearchCriteriaMgr.COL_PRSC_SEARCH_TYPE);
                _htFieldColMapping.Add("prsc_SelectedIDs",				PRWebUserSearchCriteriaMgr.COL_PRSC_SELECTED_IDS);

                // Handle the audit fields
                _htFieldColMapping.Add("prsc_CreatedBy", PRWebUserSearchCriteriaMgr.COL_PRSC_CREATED_BY);
                _htFieldColMapping.Add("prsc_UpdatedBy", PRWebUserSearchCriteriaMgr.COL_PRSC_UPDATED_BY);
                _htFieldColMapping.Add("prsc_CreatedDate", PRWebUserSearchCriteriaMgr.COL_PRSC_CREATED_DATE);
                _htFieldColMapping.Add("prsc_UpdatedDate", PRWebUserSearchCriteriaMgr.COL_PRSC_UPDATED_DATE);
                _htFieldColMapping.Add("prsc_Timestamp", PRWebUserSearchCriteriaMgr.COL_PRSC_TIME_STAMP);
                
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

            _iprsc_SearchCriteriaID = _oMgr.GetInt(oData[PRWebUserSearchCriteriaMgr.COL_PRSC_SEARCH_CRITERIA_ID]);
            _iprsc_WebUserID = _oMgr.GetInt(oData[PRWebUserSearchCriteriaMgr.COL_PRSC_WEB_USER_ID]);
            _iprsc_CompanyID = _oMgr.GetInt(oData[PRWebUserSearchCriteriaMgr.COL_PRSC_COMPANY_ID]);
            _szprsc_Name = _oMgr.GetString(oData[PRWebUserSearchCriteriaMgr.COL_PRSC_NAME]);
            _dtprsc_LastExecutionDateTime	= _oMgr.GetDateTime(oData[PRWebUserSearchCriteriaMgr.COL_PRSC_LAST_EXECUTION_DATE_TIME]);
            _iprsc_ExecutionCount = _oMgr.GetInt(oData[PRWebUserSearchCriteriaMgr.COL_PRSC_EXECUTION_COUNT]);
            _iprsc_LastExecutionResultCount = _oMgr.GetInt(oData[PRWebUserSearchCriteriaMgr.COL_PRSC_LAST_EXECUTION_RESULT_COUNT]);
            _szprsc_SelectedIDs = _oMgr.GetString(oData[PRWebUserSearchCriteriaMgr.COL_PRSC_SELECTED_IDS]);
            _szprsc_Criteria = _oMgr.GetString(oData[PRWebUserSearchCriteriaMgr.COL_PRSC_CRITERIA]);
            _szprsc_SearchType = _oMgr.GetString(oData[PRWebUserSearchCriteriaMgr.COL_PRSC_SEARCH_TYPE]);
            _bprsc_IsPrivate = ((EBBObjectMgr)_oMgr).TranslateFromCRMBool(oData[PRWebUserSearchCriteriaMgr.COL_PRSC_IS_PRIVATE]);
            _bprsc_IsLastUnsavedSearch = ((EBBObjectMgr)_oMgr).TranslateFromCRMBool(oData[PRWebUserSearchCriteriaMgr.COL_PRSC_IS_LAST_UNSAVED_SEARCH]);
            
            // Additional fields on table
            _iprsc_HQID						= _oMgr.GetInt(oData[PRWebUserSearchCriteriaMgr.COL_PRSC_HQID]);            
            
            // Audit fields
            
            
            _dtCreatedDateTime = _oMgr.GetDateTime(oData[PRWebUserSearchCriteriaMgr.COL_PRSC_CREATED_DATE]);
            _dtUpdatedDateTime = _oMgr.GetDateTime(oData[PRWebUserSearchCriteriaMgr.COL_PRSC_UPDATED_DATE]);
            _szCreatedUserID = _oMgr.GetString(oData[PRWebUserSearchCriteriaMgr.COL_PRSC_CREATED_BY]);
            _szUpdatedUserID = _oMgr.GetString(oData[PRWebUserSearchCriteriaMgr.COL_PRSC_UPDATED_BY]);
            _dtprsc_TimeStamp = _oMgr.GetDateTime(oData[PRWebUserSearchCriteriaMgr.COL_PRSC_TIME_STAMP]);

            // Desearialize the Criteria Object
            Criteria = Deserialize(_szprsc_Criteria); 
            Criteria.IsDirty = false;
        }

        /// <summary>
        /// Populates the specified Dictionary from the Object.
        /// </summary>
        /// <param name="oData">Dictionary of Data</param>
        /// <param name="iOptions">Unload Option</param>
        /// <returns>IDictionary</returns>
        override public void UnloadObject(IDictionary oData, int iOptions) {
            base.UnloadObject(oData, iOptions);

            _szprsc_Criteria = Serialize(Criteria);

            oData.Add(PRWebUserSearchCriteriaMgr.COL_PRSC_CREATED_DATE, _dtCreatedDateTime);
            oData.Add(PRWebUserSearchCriteriaMgr.COL_PRSC_LAST_EXECUTION_DATE_TIME,		_dtprsc_LastExecutionDateTime);
            oData.Add(PRWebUserSearchCriteriaMgr.COL_PRSC_TIME_STAMP,					_dtprsc_TimeStamp);
            oData.Add(PRWebUserSearchCriteriaMgr.COL_PRSC_UPDATED_DATE,                 _dtUpdatedDateTime);
            oData.Add(PRWebUserSearchCriteriaMgr.COL_PRSC_COMPANY_ID,					_iprsc_CompanyID);
            oData.Add(PRWebUserSearchCriteriaMgr.COL_PRSC_CREATED_BY,					_szCreatedUserID);
            oData.Add(PRWebUserSearchCriteriaMgr.COL_PRSC_EXECUTION_COUNT,				_iprsc_ExecutionCount);
            oData.Add(PRWebUserSearchCriteriaMgr.COL_PRSC_HQID,							_iprsc_HQID);
            oData.Add(PRWebUserSearchCriteriaMgr.COL_PRSC_LAST_EXECUTION_RESULT_COUNT,	_iprsc_LastExecutionResultCount);
            oData.Add(PRWebUserSearchCriteriaMgr.COL_PRSC_UPDATED_BY,                   _szUpdatedUserID);
            oData.Add(PRWebUserSearchCriteriaMgr.COL_PRSC_WEB_USER_ID,					_iprsc_WebUserID);
            oData.Add(PRWebUserSearchCriteriaMgr.COL_PRSC_CRITERIA,						_szprsc_Criteria);
            oData.Add(PRWebUserSearchCriteriaMgr.COL_PRSC_NAME,							_szprsc_Name);
            oData.Add(PRWebUserSearchCriteriaMgr.COL_PRSC_SEARCH_TYPE,					_szprsc_SearchType);
            oData.Add(PRWebUserSearchCriteriaMgr.COL_PRSC_SELECTED_IDS,					_szprsc_SelectedIDs);
            oData.Add(PRWebUserSearchCriteriaMgr.COL_PRSC_IS_LAST_UNSAVED_SEARCH,       ((EBBObjectMgr)_oMgr).GetPIKSCoreBool(_bprsc_IsLastUnsavedSearch));
            oData.Add(PRWebUserSearchCriteriaMgr.COL_PRSC_IS_PRIVATE,                   ((EBBObjectMgr)_oMgr).GetPIKSCoreBool(_bprsc_IsPrivate));
        }
        #endregion

        /// <summary>
        /// Serializes the data in the SearchCriteria object
        /// to XML.
        /// </summary>
        /// <param name="oSearchCriteria"></param>
        /// <returns></returns>
        protected string Serialize(Object oSearchCriteria)
        {
            StringBuilder sbXML = new StringBuilder();
            XmlSerializer xs = null;
            StringWriter xmlTextWriter = null;

            switch (_szprsc_SearchType) {
                case SEARCH_TYPE_COMPANY:
                    xs = new XmlSerializer(typeof(CompanySearchCriteria));
                    break;
                
                case SEARCH_TYPE_PERSON:
                    xs = new XmlSerializer(typeof(PersonSearchCriteria));
                    break;

                case SEARCH_TYPE_COMPANY_UPDATE:
                    xs = new XmlSerializer(typeof(CreditSheetSearchCriteria));
                    break;

                case SEARCH_TYPE_CLAIM_ACTIVITY:
                    xs = new XmlSerializer(typeof(ClaimActivitySearchCriteria));
                    break;
            }

            xmlTextWriter = new StringWriter(sbXML);
            xs.Serialize(xmlTextWriter, oSearchCriteria);
            xmlTextWriter.Close();
            
            return sbXML.ToString();
        }

        /// <summary>
        /// Deserializes the specified XML data into a new
        /// CompanySubmission object.
        /// </summary>
        /// <param name="szXML"></param>
        /// <returns></returns>
        protected SearchCriteriaBase Deserialize(string szXML)
        {
            SearchCriteriaBase oSearch = null;
            XmlSerializer xs = null;
            StringReader xmlStringReader;


            switch (_szprsc_SearchType) {
                case SEARCH_TYPE_COMPANY:
                    xs = new XmlSerializer(typeof(CompanySearchCriteria));
                    xmlStringReader = new StringReader(szXML);
                    CompanySearchCriteria companySearchCriteria = (CompanySearchCriteria)xs.Deserialize(xmlStringReader);
                    xmlStringReader.Close();
                    return companySearchCriteria;
            
                case SEARCH_TYPE_PERSON:
            
                    xs = new XmlSerializer(typeof(PersonSearchCriteria));
                    xmlStringReader = new StringReader(szXML);
                    PersonSearchCriteria personSearchCriteria = (PersonSearchCriteria)xs.Deserialize(xmlStringReader);
                    xmlStringReader.Close();
                    return personSearchCriteria;
            
                case SEARCH_TYPE_COMPANY_UPDATE:
            
                    xs = new XmlSerializer(typeof(CreditSheetSearchCriteria));
                    xmlStringReader = new StringReader(szXML);
                    CreditSheetSearchCriteria creditSheetSearchCriteria = (CreditSheetSearchCriteria)xs.Deserialize(xmlStringReader);
                    xmlStringReader.Close();
                    return creditSheetSearchCriteria;

                case SEARCH_TYPE_CLAIM_ACTIVITY:

                    xs = new XmlSerializer(typeof(ClaimActivitySearchCriteria));
                    xmlStringReader = new StringReader(szXML);
                    ClaimActivitySearchCriteria claimActivitySearchCriteria = (ClaimActivitySearchCriteria)xs.Deserialize(xmlStringReader);
                    xmlStringReader.Close();
                    return claimActivitySearchCriteria;
            }            

            return oSearch;
        }


        public IPRWebUser WebUser
        {
            set
            {
                _oWebUser = value;

                if (prsc_WebUserID == 0)
                {
                    prsc_CompanyID = _oWebUser.prwu_BBID;
                    prsc_HQID = _oWebUser.prwu_HQID;
                    prsc_WebUserID = _oWebUser.prwu_WebUserID;
                }
            }

            get { return _oWebUser; }
        }
    }
}