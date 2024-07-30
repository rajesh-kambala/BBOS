/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2023

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: SearchCriteriaBase
 Description:	

 Notes:	Created By Sharon Cole on 7/17/2007 2:11:32 PM

***********************************************************************
***********************************************************************/

using System;
using System.Collections;
using System.Data;
using System.Text;
using System.Text.RegularExpressions;
using System.Xml.Serialization;

using TSI.BusinessObjects;
using TSI.DataAccess;


namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// This class provides functionality common to all
    /// of the Search Criteria classes.
    /// </summary>
    [Serializable]
    public class SearchCriteriaBase
    {
        protected int _iBBID;
        protected int _iSearchWizardID;
        protected int _iRadius = -1;

        protected string _szCompanyName;
        protected string _szIndustryType;
        protected bool   _bIndustryTypeSkip = false;
        protected bool   _bIndustryTypeNotEqual = false;
        protected string _szSortField;
        protected string _szUserListIDs;

        protected string _szListingCountryIDs;
        protected string _szListingStateIDs;
        protected string _szListingCity;
        protected string _szListingCounty;
        protected string _szListingPostalCode;
        protected string _szTerminalMarketIDs;
        protected string _szRadiusType;

        protected string _szCustomIdentifier;
        protected bool _bCustomIdentifierNotNull;
        protected bool _bHasNotes;

        protected bool _bIsQuickSearch;
        protected bool _bIsDirty;
        protected bool _bSortAsc;
        protected bool _bUseOrConnector = false;
        
        protected IPRWebUser _oUser;
        protected BusinessObjectMgr _oMgr;

        protected IDBAccess _oDBAccess;

        public const string CODE_PUBLISHED = "Y";
        public const string CODE_CURRENT = "Y";
        public const string CODE_PRIVATE = "Y";

        // CRM Company Table Constants
        public const string TAB_COMPANY = "Company";

        public const string COL_COMPANY_COMPANYID = "Comp_CompanyID";

        // CRM PRCompanySearch Table Constants
        public const string TAB_PRCOMPANYSEARCH = "PRCompanySearch";

        public const string COL_PRCOMPANYSEARCH_NAMEALPHAONLY = "prcse_NameAlphaOnly";
        public const string COL_PRCOMPANYSEARCH_COMPANYID = "prcse_CompanyId";

        // CRM PRWebUserListDetail Table Constants
        public const string TAB_PRWEBUSERLISTDETAIL = "PRWebUserListDetail";

        public const string COL_PRWEBUSERLISTDETAIL_ASSOCIATEDID = "prwuld_AssociatedId";
        public const string COL_PRWEBUSERLISTDETAIL_WEBUSERLISTID = "prwuld_WebUserListID";
        public const string COL_PRWEBUSERLISTDETAIL_ASSOCIATEDTYPE = "prwuld_AssociatedType";

        public const string CODE_ASSOCIATEDTYPE_COMPANY = "C";

        // CRM PRWebUserNote table constants
        public const string TAB_PRWEBUSERNOTE = "PRWebUserNote";

        public const string COL_PRWEBUSERNOTE_COMPANYID = "prwun_AssociatedID";
        public const string COL_PRWEBUSERNOTE_PERSONID = "prwun_AssociatedID";
        public const string COL_PRWEBUSERNOTE_TYPECODE = "prwun_AssociatedType";
        public const string COL_PRWEBUSERNOTE_CREATEDBY = "prwun_CreatedBy";
        public const string COL_PRWEBUSERNOTE_PRIVATE = "prwun_IsPrivate";
        public const string COL_PRWEBUSERNOTE_WEBUSERID = "prwun_WebUserID";
        public const string COL_PRWEBUSERNOTE_HQID = "prwun_HQID";

        public const string CODE_PRWEBUSERNOTE_TYPECOMPANY = "C";
        public const string CODE_PRWEBUSERNOTE_TYPEPERSON = "P";


        // CRM PRWebUserCustomData table constants
        public const string TAB_PRWEBUSERCUSTOMDATA = "PRWebUserCustomData";

        public const string COL_PRWEBUSERCUSTOMDATA_COMPANYID = "prwucd_AssociatedID";
        public const string COL_PRWEBUSERCUSTOMDATA_VALUE = "prwucd_Value";
        public const string COL_PRWEBUSERCUSTOMDATA_LABELCODE = "prwucd_LabelCode";

        public const string CODE_LABELCODE_CUSTOMIDENTIFIER = "1";


        // CRM Phone Table Constants
        public const string TAB_PHONE = "Phone";

        //public const string COL_PHONE_COMPANYID = "Phon_CompanyID";
        public const string COL_PHONE_AREACODE = "Phon_AreaCode";
        public const string COL_PHONE_NUMBER = "Phon_Number";
        public const string COL_PHONE_PHONE_MATCH = "Phon_PhoneMatch";
        public const string COL_PHONE_TYPE = "plink_Type";
        //public const string COL_PHONE_PERSONID = "Phon_PersonID";
        public const string COL_PHONE_PUBLISH = "Phon_PRPublish";

        // SQL String Constants
        protected const string SQL_COMPANY_SEARCH = "SELECT Comp_CompanyID FROM Company WHERE ";
        protected const string SQL_SUB_SELECT_COMPANY_ID = COL_COMPANY_COMPANYID + " IN (SELECT {0} FROM {1} WHERE {2})";
        protected const string SQL_SUB_SELECT_NOT_COMPANY_ID = COL_COMPANY_COMPANYID + " NOT IN (SELECT {0} FROM {1} WHERE {2})";
        protected const string SQL_SUB_SELECT_HAVING_COUNT = COL_COMPANY_COMPANYID + " IN (SELECT {0} FROM {1} GROUP BY {2} HAVING COUNT(*) {3} {4})";
        protected const string SQL_SUB_SELECT_PERSON_ID = "peli_PersonID IN (SELECT {0} FROM {1} WHERE {2})";
        public const string CODE_WILDCARD = "*";

        protected const string SQL_SELECT_TOP = "SELECT TOP {0} * FROM ({1}) T1 {2}";
        /// <summary>
        /// Constructor
        /// </summary>
        public SearchCriteriaBase() 
        {
            _oDBAccess = DBAccessFactory.getDBAccessProvider();
        }

        #region Property Accessors

        [XmlIgnore]
        public IPRWebUser WebUser {
            get { return _oUser; }
            set { _oUser = value; }
        }

        [XmlIgnore]
        public bool IsDirty {
            get { return _bIsDirty; }
            set { _bIsDirty = value; }
        }
        
        /// <summary>
        /// Accessor for the BBID property.
        /// </summary>
        public int BBID
        {
            get { return _iBBID; }
            set {SetDirty(value, _iBBID); 
                 _iBBID = value; }
        }

        /// <summary>
        /// Accessor for the SearchWizardID property.
        /// </summary>
        public int SearchWizardID
        {
            get { return _iSearchWizardID; }
            set {
                SetDirty(value, _iSearchWizardID);
                _iSearchWizardID = value;
            }
        }

        /// <summary>
        /// Accessor for the CompanyName property.
        /// </summary>
        public string CompanyName
        {
            get { return _szCompanyName; }
            set {
                SetDirty(value, _szCompanyName);
                _szCompanyName = value;
            }
        }


        /// <summary>
        /// Accessor for the IndustryType property
        /// </summary>
        public string IndustryType
        {
            get { return _szIndustryType; }
            set
            {
                SetDirty(value, _szIndustryType);
                _szIndustryType = value;
            }
        }

        /// <summary>
        /// Accessor for the IndustryTypeSkip property
        /// </summary>
        public bool IndustryTypeSkip
        {
            get { return _bIndustryTypeSkip; }
            set
            {
                SetDirty(value, _bIndustryTypeSkip);
                _bIndustryTypeSkip = value;
            }
        }

        /// <summary>
        /// Accessor for the IndustryTypeNotEqual property
        /// </summary>
        public bool IndustryTypeNotEqual
        {
            get { return _bIndustryTypeNotEqual; }
            set
            {
                SetDirty(value, _bIndustryTypeNotEqual);
                _bIndustryTypeNotEqual = value;
            }
        }

        /// <summary>
        /// Accessor for the IsQuickSearch property
        /// </summary>
        public bool IsQuickSearch
        {
            get { return _bIsQuickSearch; }
            set
            {
                SetDirty(value, _bIsQuickSearch);
                _bIsQuickSearch = value;
            }
        }

        /// <summary>
        /// Accessor for the SortField property.
        /// </summary>
        public string SortField
        {
            get { return _szSortField; }
            set { _szSortField = value;}
        }

        /// <summary>
        /// Accessor for the UserListIDs property.
        /// </summary>
        public string UserListIDs
        {
            get { return _szUserListIDs; }
            set {
                SetDirty(value, _szUserListIDs);
                _szUserListIDs = value;
            }
        }

        /// <summary>
        /// Accessor for the SortAsc property.
        /// </summary>
        public bool SortAsc
        {
            get { return _bSortAsc; }
            set { _bSortAsc = value; }
        }


        /// <summary>
        /// Accessor for the ListingCountryIDs property
        /// </summary>
        public string ListingCountryIDs
        {
            get { return _szListingCountryIDs; }
            set
            {
                SetDirty(value, _szListingCountryIDs);
                _szListingCountryIDs = value;
            }
        }

        /// <summary>
        /// Accessor for the ListingStateIDs property
        /// </summary>
        public string ListingStateIDs
        {
            get { return _szListingStateIDs; }
            set
            {
                SetDirty(value, _szListingStateIDs);
                _szListingStateIDs = value;
            }
        }

        /// <summary>
        /// Accessor for the ListingCity property
        /// </summary>
        public string ListingCity
        {
            get { return _szListingCity; }
            set
            {
                SetDirty(value, _szListingCity);
                _szListingCity = value;
            }
        }

        /// <summary>
        /// Accessor for the ListingCounty property
        /// </summary>
        public string ListingCounty
        {
            get { return _szListingCounty; }
            set
            {
                SetDirty(value, _szListingCounty);
                _szListingCounty = value;
            }
        }

        /// <summary>
        /// Accessor for the ListingPostalCode property
        /// </summary>
        public string ListingPostalCode
        {
            get { return _szListingPostalCode; }
            set
            {
                SetDirty(value, _szListingPostalCode);
                _szListingPostalCode = value;
            }
        }

        /// <summary>
        /// Accessor for the TerminalMarketIDs property
        /// </summary>
        public string TerminalMarketIDs
        {
            get { return _szTerminalMarketIDs; }
            set
            {
                SetDirty(value, _szTerminalMarketIDs);
                _szTerminalMarketIDs = value;
            }
        }

        /// <summary>
        /// Accessor for the RadiusType property
        /// </summary>
        public string RadiusType
        {
            get { return _szRadiusType; }
            set
            {
                SetDirty(value, _szRadiusType);
                _szRadiusType = value;
            }
        }


        /// <summary>
        /// Accessor for the Radius property
        /// </summary>
        public int Radius
        {
            get { return _iRadius; }
            set
            {
                SetDirty(value, _iRadius);
                _iRadius = value;
            }
        }


        /// <summary>
        /// Accessor for the HasNotes property
        /// </summary>
        public bool HasNotes
        {
            get { return _bHasNotes; }
            set
            {
                SetDirty(value, _bHasNotes);
                _bHasNotes = value;
            }
        }


        /// <summary>
        /// Accessor for the CustomIdentifierNotNull property
        /// </summary>
        public bool CustomIdentifierNotNull
        {
            get { return _bCustomIdentifierNotNull; }
            set
            {
                SetDirty(value, _bCustomIdentifierNotNull);
                _bCustomIdentifierNotNull = value;
            }
        }

        /// <summary>
        /// Accessor for the CustomIdentifier property
        /// </summary>
        public string CustomIdentifier
        {
            get { return _szCustomIdentifier; }
            set
            {
                SetDirty(value, _szCustomIdentifier);
                _szCustomIdentifier = value;
            }
        }

        protected string _szIncludeLocalSource;
        public string IncludeLocalSource
        {
            get { return _szIncludeLocalSource; }
            set
            {
                SetDirty(value, _szIncludeLocalSource);
                _szIncludeLocalSource = value;
            }
        }


        protected bool _bIsLocalSourceCountOverride;
        public bool IsLocalSourceCountOverride
        {
            get
            {
                return _bIsLocalSourceCountOverride;
            }
            set
            {
                _bIsLocalSourceCountOverride = value;
            }
        }
        #endregion


        protected GeneralDataMgr _oObjectMgr;
        /// <summary>
        /// Helper method that returns an EBBObjectMgr object.  This is
        /// cached in a member variable.
        /// </summary>
        /// <returns></returns>
        public GeneralDataMgr GetObjectMgr()
        {
            if (_oObjectMgr == null)
            {
                _oObjectMgr = new GeneralDataMgr(null, _oUser);
            }

            // Always make sure we have a user object.  In some cases
            // this method is called before we have a valid user.  So
            // we end up with an ObjectMgr instance w/o a user.  So
            // always set to handle those cases.
            _oObjectMgr.User = _oUser;
            return _oObjectMgr;
        }


        /// <summary>
        /// Generates the Search SQL based on the Search
        /// Criteria.
        /// </summary>
        /// <returns>Search SQL String</returns>
        public virtual string GetSearchSQL(out ArrayList oParams)
        {
            oParams = new ArrayList();
            string szWhere = BuildWhereClause(oParams);
            string szOrderBy = BuildOrderByClause();
            string szSQL = SQL_COMPANY_SEARCH + szWhere + szOrderBy;


            return szSQL;
        }


        protected virtual string BuildWhereClause(IList oParameters) {
            return BuildWhereClause(oParameters, true);
        }

        protected virtual string BuildWhereClause(IList oParameters, bool bUseSubSelectForNameAlphaSearch)
        {
            return BuildWhereClause(oParameters, bUseSubSelectForNameAlphaSearch, true);
        }

        /// <summary>
        /// Builds the appropriate WHERE clause based on the criteria
        /// specified.
        /// </summary>
        /// <param name="oParameters">Parameter List</param>
        /// <param name="bUseSubSelectForNameAlphaSearch"></param>
        /// <param name="bIncludeIndustryTypeCriteria"></param>
        /// <returns>WHERE Clause</returns>
        protected virtual string BuildWhereClause(IList oParameters, 
                                                  bool bUseSubSelectForNameAlphaSearch,
                                                  bool bIncludeIndustryTypeCriteria)
        {
            StringBuilder sbWhereClause = new StringBuilder();
            StringBuilder sbSubSelectWhere = new StringBuilder();

            // BB # Criteria
            if (_iBBID > 0)
            {
                AddCondition(sbWhereClause, oParameters, COL_COMPANY_COMPANYID, "=", _iBBID);
            }

            // Company Name Criteria
            if (!String.IsNullOrEmpty(_szCompanyName))
            {
                // If the name is surrounded by double quotes, we want to search the
                // company name field, not the search field that strips all punctuation.
                if (IsExactSearch(_szCompanyName)) {

                    SetOrConnector();
                    AddNameSearchCondition(sbWhereClause, oParameters, "comp_PRBookTradestyle", "LIKE", " " + _szCompanyName.Substring(1, _szCompanyName.Length-2) + " ", false);
                    ResetConnector();

                } else {

                    if (sbWhereClause.Length > 0)
                    {
                        sbWhereClause.Append(" OR");
                    }
                    sbWhereClause.Append(" (");

                    
                    string parmValue = prepareName(_szCompanyName, true);
                    oParameters.Add(new ObjectParameter("CompanyName", _oDBAccess.TranslateWildCards(parmValue)));

                    SetOrConnector();
                    if (bUseSubSelectForNameAlphaSearch) {
                        sbSubSelectWhere.Length = 0;

                        AddNameSearchCondition(sbSubSelectWhere, "CompanyName", "prcse_NameMatch", "LIKE");
                        AddNameSearchCondition(sbSubSelectWhere, "CompanyName", "prcse_LegalNameMatch", "LIKE");
                        //AddNameSearchCondition(sbSubSelectWhere, "CompanyName", "prcse_CorrTradestyleMatch", "LIKE");
                        AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, COL_PRCOMPANYSEARCH_COMPANYID, TAB_PRCOMPANYSEARCH, sbSubSelectWhere);
                    } else {
                        AddNameSearchCondition(sbWhereClause, "CompanyName", "prcse_NameMatch", "LIKE");
                        AddNameSearchCondition(sbWhereClause, "CompanyName", "prcse_LegalNameMatch", "LIKE");
                        //AddNameSearchCondition(sbWhereClause, "CompanyName", "prcse_CorrTradestyleMatch", "LIKE");
                    }

                    sbSubSelectWhere.Length = 0;
                    AddNameSearchCondition(sbSubSelectWhere, "CompanyName", "pral_NameAlphaOnly", "LIKE");
                    AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, "pral_CompanyId", "PRCompanyAlias", sbSubSelectWhere);
                    ResetConnector();

                    sbWhereClause.Append(")");


                }
            }

            // User List IDs Criteria
            if (!String.IsNullOrEmpty(_szUserListIDs))
            {
                sbSubSelectWhere.Length = 0;
                AddInCondition(sbSubSelectWhere, COL_PRWEBUSERLISTDETAIL_WEBUSERLISTID, _szUserListIDs);
                AddCondition(sbSubSelectWhere, oParameters, COL_PRWEBUSERLISTDETAIL_ASSOCIATEDTYPE, "=", CODE_ASSOCIATEDTYPE_COMPANY);
                AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, COL_PRWEBUSERLISTDETAIL_ASSOCIATEDID, TAB_PRWEBUSERLISTDETAIL, sbSubSelectWhere);
            }

            if (bIncludeIndustryTypeCriteria)
            {
                if (WebUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                {
                    AddCondition(sbWhereClause, oParameters, "comp_PRIndustryType", "=", GeneralDataMgr.INDUSTRY_TYPE_LUMBER);
                }
                else
                {
                    AddCondition(sbWhereClause, oParameters, "comp_PRIndustryType", "<>", GeneralDataMgr.INDUSTRY_TYPE_LUMBER);
                }
            }
            return sbWhereClause.ToString();
        }

        /// <summary>
        /// Builds the appropriate ORDER BY clause based on the criteria
        /// specified.
        /// </summary>
        /// <returns>ORDER BY clause</returns>
        protected string BuildOrderByClause()
        {
            StringBuilder sbSortBy = new StringBuilder();

            // Sort Field
            if(!String.IsNullOrEmpty(_szSortField))
            {
                sbSortBy.Append(" ORDER BY ");
                sbSortBy.Append(_szSortField);

                // Sort ASC
                if (_bSortAsc)
                    sbSortBy.Append(" ASC ");
                else
                    sbSortBy.Append(" DESC ");  
            }            

            return sbSortBy.ToString();
        }

        #region Helper Methods
        /// <summary> 
        /// Adds a condition to the current SQL string. 
        /// Helper method for building the search SQL. 
        /// </summary> 
        /// <param name="sbSQL">Search SQL</param> 
        /// <param name="oParameters">Parameter List</param> 
        /// <param name="szColumn">Column Name To Add</param> 
        /// <param name="szCondition">Condition To Add</param> 
        /// <param name="oValue">Value to Add</param> 
        protected void AddCondition(StringBuilder sbSQL,
            IList oParameters,
            string szColumn,
            string szCondition,
            object oValue)
        {

            sbSQL = AddConnector(sbSQL);

            sbSQL.Append(szColumn);
            sbSQL.Append(" ");
            sbSQL.Append(szCondition);
            sbSQL.Append(" ");
            sbSQL.Append(_oDBAccess.PrepareParmName("Param" + oParameters.Count.ToString()));

            oParameters.Add(new ObjectParameter("Param" + oParameters.Count.ToString(), oValue));
        }


        /// <summary>
        /// Adds a condition to the current SQL string.
        /// Helper method for building the search SQL.
        /// </summary>
        /// <param name="sbSQL">Search SQL</param>
        /// <param name="oParameters">Parameter List</param>
        /// <param name="szColumn">Column Name To Add</param>
        /// <param name="szCondition">Condition To Add</param>
        /// <param name="oValue">Value to Add</param>
        virtual public void AddORCondition(StringBuilder sbSQL,
                                    IList oParameters,
                                    string szColumn,
                                    string szCondition,
                                    object oValue)
        {

            if (sbSQL.Length > 0)
            {
                sbSQL.Append(" OR ");
            }

            sbSQL.Append(szColumn);
            sbSQL.Append(" ");
            sbSQL.Append(szCondition);
            sbSQL.Append(" {");
            sbSQL.Append(oParameters.Count.ToString());
            sbSQL.Append("}");


            oParameters.Add(new ObjectParameter("Parm" + oParameters.Count.ToString(), oValue));
        }

        /// <summary> 
        /// Adds a sub-select to the where clause. 
        /// Helper method for building the search SQL. 
        /// </summary> 
        /// <param name="sbWhereClause">Where clause to add sub-select to</param> 
        /// <param name="szSubSelectSQL">Sub select structure to use</param>
        /// <param name="szColumnName">Column to return in sub-select</param>
        /// <param name="szTable">Table name for the sub-select</param> 
        /// <param name="sbSubSelectWhereClause">Where clause for the sub-select</param> 
        protected void AddSubSelect(StringBuilder sbWhereClause, 
            string szSubSelectSQL, 
            string szColumnName, 
            string szTable, 
            StringBuilder sbSubSelectWhereClause)
        {
            AddSubSelect(sbWhereClause, szSubSelectSQL, szColumnName, szTable, sbSubSelectWhereClause, true);
        }

        protected void AddSubSelect(StringBuilder sbWhereClause,
            string szSubSelectSQL,
            string szColumnName,
            string szTable,
            StringBuilder sbSubSelectWhereClause,
            bool bAddNoLock
            )
        {
            if (sbSubSelectWhereClause.Length > 0)
            {
                sbWhereClause = AddConnector(sbWhereClause);

                sbWhereClause.Append(string.Format(szSubSelectSQL, szColumnName, szTable + (string)(bAddNoLock?GetNoLock():""), sbSubSelectWhereClause.ToString()));
            }
        }

        /// <summary> 
        /// Adds an IS NOT NULL condition to the current SQL string. 
        /// Helper method for building the search SQL. 
        /// </summary> 
        /// <param name="sbSQL">Search SQL</param> 
        /// <param name="szColumn">Column Name To Add</param> 
        protected void AddIsNotNullCondition(StringBuilder sbSQL,            
            string szColumn)
        {
            sbSQL = AddConnector(sbSQL);

            sbSQL.Append(szColumn);
            sbSQL.Append(" IS NOT NULL");
        }

        /// <summary> 
        /// Adds an IS NULL condition to the current SQL string. 
        /// Helper method for building the search SQL. 
        /// </summary> 
        /// <param name="sbSQL">Search SQL</param> 
        /// <param name="szColumn">Column Name To Add</param> 
        protected void AddIsNullCondition(StringBuilder sbSQL,
            string szColumn)
        {
            sbSQL = AddConnector(sbSQL);

            sbSQL.Append(szColumn);
            sbSQL.Append(" IS NULL");
        }

        /// <summary> 
        /// Adds an IN condition to the current SQL string. 
        /// Helper method for building the search SQL. 
        /// </summary> 
        /// <param name="sbSQL">Search SQL</param> 
        /// <param name="szColumn">Column Name To Add</param> 
        /// <param name="szValueList">Comma delimited value list to Generate an IN clause for</param> 
        protected void AddInCondition(StringBuilder sbSQL,
                string szColumn,
                string szValueList)
        {
            sbSQL = AddConnector(sbSQL);            

            sbSQL.Append(szColumn);
            sbSQL.Append(" IN ");
            sbSQL.Append("(");
            sbSQL.Append(szValueList);
            sbSQL.Append(")");
        }

        /// <summary> 
        /// Adds an IN condition to the current SQL string. 
        /// Helper method for building the search SQL. 
        /// </summary> 
        /// <param name="sbSQL">Search SQL</param> 
        /// <param name="szColumn">Column Name To Add</param> 
        /// <param name="szValueList">Comma delimited value list to Generate an IN clause for</param> 
        /// <param name="bStringValues">Set if value list contains string values</param>
        protected void AddInCondition(StringBuilder sbSQL,
                                        string szColumn,
                                        string szValueList,
                                        bool bStringValues)
        {
            AddInCondition(sbSQL, szColumn, szValueList, bStringValues, false);
        }

        protected void AddInCondition(StringBuilder sbSQL,
                string szColumn,
                string szValueList,
                bool bStringValues,
                bool bIsNot)
        {
            sbSQL = AddConnector(sbSQL);

            sbSQL.Append(szColumn);
            if (bIsNot)
            {
                sbSQL.Append(" NOT ");
            }
            sbSQL.Append(" IN ");
            
            sbSQL.Append("(");
            if (bStringValues)
            {
                // Add ' for string
                string[] szValues = szValueList.Split(new char[] {','});
                string szStringValueList = "";
                foreach (string szValue in szValues)
                {
                    if (szStringValueList.Length > 0)
                        szStringValueList += ",";
                    szStringValueList += "'" + szValue + "'";
                }
                sbSQL.Append(szStringValueList);
            }
            else
            {
                sbSQL.Append(szValueList);
            }
            sbSQL.Append(")");
        }

        /// <summary> 
        /// Adds a condition to search for the company name to the current SQL string. 
        /// Helper method for building the search SQL. 
        /// </summary> 
        /// <param name="sbSQL">Search SQL</param> 
        /// <param name="oParameters">Parameter List</param> 
        /// <param name="szColumn">Column Name To Add</param> 
        /// <param name="szCondition">Condition To Add</param>
        /// <param name="szValue">Value to Add</param> 
        /// <param name="bClean"></param>
        protected void AddNameSearchCondition(StringBuilder sbSQL,
            IList oParameters,
            string szColumn,
            string szCondition,
            string szValue,
            bool bClean)
        {
            AddNameSearchCondition(sbSQL,
                                   "Param" + oParameters.Count.ToString(),
                                   szColumn,
                                   szCondition);

            // Prepare value for NameSearch table
            szValue = prepareName(szValue, bClean);            
            oParameters.Add(new ObjectParameter("Param" + oParameters.Count.ToString(), _oDBAccess.TranslateWildCards(szValue)));

        }
        protected void AddNameSearchCondition(StringBuilder sbSQL,
            string szParmName,
            string szColumn,
            string szCondition)
        {
            sbSQL = AddConnector(sbSQL);

            sbSQL.Append(szColumn);
            sbSQL.Append(" ");
            sbSQL.Append(szCondition);
            sbSQL.Append(" ");
            sbSQL.Append(_oDBAccess.PrepareParmName(szParmName));  
          
        }

        protected string prepareName(string szValue, bool bClean)
        {
            if (bClean)
            {
                szValue = CleanString(szValue);
            }

            return CODE_WILDCARD + szValue.ToLower() + CODE_WILDCARD;  
        }

        /// <summary>
        /// Appends a string search condition to the specified Where SQL string.
        /// Translates the wildcard characters.  
        /// Helper method for building the search SQL. 
        /// </summary>
        /// <param name="sbSQL">SQL String</param>
        /// <param name="oParameters">Parameters</param>
        /// <param name="szColumn">Column Name</param>
        /// <param name="szValue">Value</param>
        virtual protected void AddStringCondition(StringBuilder sbSQL,
            IList oParameters,
            string szColumn,
            string szValue)
        {
            AddCondition(sbSQL, oParameters, szColumn, "LIKE", _oDBAccess.TranslateWildCards(CODE_WILDCARD + szValue + CODE_WILDCARD));
        }

        /// <summary> 
        /// Adds a condition to search for the company by radius. 
        /// Helper method for building the search SQL. 
        /// </summary> 
        /// <param name="sbSQL">Search SQL</param> 
        /// <param name="oParameters">Parameter List</param> 
        /// <param name="szColumn">Column Name To Add</param> 
        /// <param name="szValuePostalCode">Zip Code to search near</param>
        /// <param name="iValueRadius">Radius in miles</param>
        protected void AddRadiusSearchCondition(StringBuilder sbSQL,
            IList oParameters,
            string szColumn,
            string szValuePostalCode,
            int iValueRadius)
        {
            // This function may be called several times so
            // we have to use dynamic parameter names.
            string szParmSuffix = oParameters.Count.ToString();
            
            sbSQL = AddConnector(sbSQL);

            sbSQL.Append(szColumn);
            sbSQL.Append(" IN ");
            sbSQL.Append("(");
            sbSQL.Append("SELECT CompanyID FROM dbo.ufn_GetCompaniesWithinRadius(" + _oDBAccess.PrepareParmName("ListingPostalCode" + szParmSuffix) + ", " + _oDBAccess.PrepareParmName("Radius" + szParmSuffix) + ")");
            sbSQL.Append(")");            

            oParameters.Add(new ObjectParameter("ListingPostalCode" + szParmSuffix, szValuePostalCode));
            oParameters.Add(new ObjectParameter("Radius" + szParmSuffix, iValueRadius));
        }

        /// <summary> 
        /// Adds a condition to search for the company by radius. 
        /// Helper method for building the search SQL. 
        /// </summary> 
        /// <param name="sbSQL">Search SQL</param> 
        /// <param name="oParameters">Parameter List</param> 
        /// <param name="szColumn">Column Name To Add</param> 
        /// <param name="szSubSelect">Sub select used to retrieve zip codes</param>
        /// <param name="iValueRadius">Radius in Miles</param>
        protected void AddRadiusSearchCondition(StringBuilder sbSQL,
            IList oParameters,
            string szColumn,
            StringBuilder szSubSelect,
            int iValueRadius)
        {
            sbSQL = AddConnector(sbSQL);

            sbSQL.Append(szColumn);
            sbSQL.Append(" IN ");
            sbSQL.Append("(");
            sbSQL.Append("SELECT CompanyID FROM dbo.ufn_GetCompaniesWithinRadius((" + szSubSelect.ToString() + "), " + _oDBAccess.PrepareParmName("Radius") + ")");
            sbSQL.Append(")");

            oParameters.Add(new ObjectParameter("Radius", iValueRadius));
         }

         /// <summary> 
         /// Adds a sub-select with a having clause to the sql string. 
         /// Helper method for building the search SQL. 
         /// </summary> 
         /// <param name="sbSQL">Search SQL</param> 
         /// <param name="szSubSelectSQL">Sub select structure to use</param>
         /// <param name="szColumnName">Column to return in sub-select</param>
         /// <param name="szTable">Table name for the sub-select</param> 
         /// <param name="szGroupBy">Column to use in Group By</param>
         /// <param name="szHavingCondition">Condition for count</param>
         /// <param name="szHavingValue">Value for count comparison</param>
         protected void AddHavingCountSubSelect(StringBuilder sbSQL,
             string szSubSelectSQL,
             string szColumnName,
             string szTable,
             string szGroupBy,
             string szHavingCondition,
             string szHavingValue)             
         {
             sbSQL = AddConnector(sbSQL);

             sbSQL.Append(string.Format(szSubSelectSQL, szColumnName, szTable, szGroupBy, szHavingCondition, szHavingValue));
        }

        /// <summary>
        /// Set the sql connector to OR instead of using the AND default
        /// </summary>
        protected void SetOrConnector()
        {
            _bUseOrConnector = true;
        }

        /// <summary>
        /// Resets the sql connector to use the default of AND
        /// </summary>
        protected void ResetConnector()
        {
            _bUseOrConnector = false;
        }

        /// <summary>
        /// Appends the appropriate AND/OR connector to the current 
        /// SQL string.
        /// </summary>
        /// <param name="sbSQL">SQL String to append to</param>
        protected StringBuilder AddConnector(StringBuilder sbSQL)
        {
            string szSQLString;

            // Check if other clauses already exist in the sql
            if (sbSQL.Length > 0)
            {
                // Check if this is the start of a clause grouping
                szSQLString = sbSQL.ToString();
                if (!szSQLString.EndsWith("("))
                {
                    // Check if another connector already exists
                    if ((!szSQLString.Trim().EndsWith(" OR")) && 
                         !szSQLString.Trim().EndsWith(" AND"))
                    {
                        if (_bUseOrConnector)
                            sbSQL.Append(" OR ");
                        else
                            sbSQL.Append(" AND ");
                    }
                }
            }

            return sbSQL;
        }

        /// <summary>
        /// Helper method that removes any whitespace or punctuation from the 
        /// given string.
        /// </summary>
        /// <param name="szInput"></param>
        /// <returns></returns>
        public static string CleanString(string szInput)
        {

            szInput = RemoveCompanyEntity(szInput);

            // Remove all white space
            Regex rexWhiteSpace = new Regex( @"\s");
            // Remove all punctuation
            Regex rexPunctuation = new Regex(@"[^a-zA-Z0-9*]");

            szInput = rexWhiteSpace.Replace(szInput, "");
            szInput = rexPunctuation.Replace(szInput, "");
            
            return szInput;
        }        

        /// <summary>
        /// This strips off company entity abbreviations from the
        /// end of the company name.  This mirrors ufn_PrepareCompanyName,
        /// which couldn't be used here due to how the code was already
        /// structured.
        /// </summary>
        /// <param name="szName"></param>
        /// <returns></returns>
        public static string RemoveCompanyEntity(string szName)
        {
            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyName", szName));
            string szPreparedName = (string)oDBAccess.ExecuteScalar("SELECT dbo.ufn_PrepareCompanyName(@CompanyName)", oParameters);
            if (szPreparedName != null)
                return szPreparedName;

            return szName;
        }
        #endregion

        /// <summary>
        /// Sets the bDirty flag if the two values are 
        /// different.  
        /// </summary>
        /// <param name="oValue1"></param>
        /// <param name="oValue2"></param>
        virtual protected void SetDirty(object oValue1, object oValue2) {
            if ((!_bIsDirty) &&
                (GetMgr() != null)) {
                if (GetMgr().AreObjectsEqual(oValue1, oValue2)) {
                    return;
                }
                _bIsDirty = true;
            }
        }

        virtual protected BusinessObjectMgr GetMgr() {
            if (_oMgr == null) {
                _oMgr = new PRWebUserSearchCriteriaMgr();
            }
            return _oMgr;
        }


        virtual public string GetSearchCountSQL(out ArrayList oParams) {
            oParams = null;
            return string.Empty;
        }

        virtual protected string GetNoLock() {
            return ((EBBObjectMgr)GetMgr()).GetNoLock();
        }
        
        
        protected bool IsExactSearch(string szCompanyName) {
            if ((szCompanyName.StartsWith("\"")) &&
                (szCompanyName.EndsWith("\""))) {
                return true;
            }
            
            return false;
        }


        // CRM vPRLocation View Constants
        //public const string VIEW_PRLOCATION = "vPRLocation";
        public const string COL_VPRLOCATION_CITYID = "vPRLocation.prci_CityId";
        public const string COL_VPRLOCATION_COUNTRYID = "vPRLocation.prst_CountryId";
        public const string COL_VPRLOCATION_STATEID = "vPRLocation.prst_StateId";
        public const string COL_VPRLOCATION_CITY = "vPRLocation.prci_City";

				public const string COL_VPRLOCATION_SALES_TERRITORY = "prci_SalesTerritory";

				public const string COL_VPRADDRESS_COUNTY = "vPRAddress.addr_PRCounty";
        public const string CODE_RADIUSTYPE_LISTINGPOSTALCODE = "Listing Postal Code";
        public const string CODE_RADIUSTYPE_TERMINALMARKET = "Terminal Market";
        public const string TAB_PRCOMPANYTERMINALMARKET = "PRCompanyTerminalMarket";
        public const string COL_PRCOMPANYTERMINALMARKET_COMPANYID = "prct_CompanyId";
        public const string COL_PRCOMPANYTERMINALMARKET_TERMINALMARKETID = "prct_TerminalMarketId";

        
        protected void BuildLocationCriteria(StringBuilder sbWhereClause,
                                             IList oParameters)
        {
            StringBuilder sbSubSelectWhere = new StringBuilder();

            // Listing Country IDs Criteria
            // Listing State IDs Criteria
            // Listing City Criteria
            // NOTE: The Country, State, and City criteria will be consolidated since each is executed 
            // against the vPRLocation view
            if (!String.IsNullOrEmpty(_szListingCountryIDs) ||
                !String.IsNullOrEmpty(_szListingStateIDs) ||
                !String.IsNullOrEmpty(_szListingCity))
            {
                sbSubSelectWhere.Length = 0;
                if (!String.IsNullOrEmpty(_szListingCountryIDs))
                {
                    AddInCondition(sbWhereClause, COL_VPRLOCATION_COUNTRYID, _szListingCountryIDs);
                }

                if (!String.IsNullOrEmpty(_szListingStateIDs))
                {
                    AddInCondition(sbWhereClause, COL_VPRLOCATION_STATEID, _szListingStateIDs);
                }

                if (!String.IsNullOrEmpty(_szListingCity))
                {
                    AddStringCondition(sbWhereClause, oParameters, COL_VPRLOCATION_CITY, _szListingCity);
                }
            }

            if (!String.IsNullOrEmpty(_szListingCounty))
            {
                // Listing where here.
                AddCondition(sbWhereClause, oParameters, COL_VPRADDRESS_COUNTY, "=", _szListingCounty);
            }

            // Listing Postal Code Criteria
            if (!String.IsNullOrEmpty(_szListingPostalCode))
            {
                // Listing Postal code must be used with radius search 
                if (!String.IsNullOrEmpty(_szRadiusType) &&
                    _szRadiusType == CODE_RADIUSTYPE_LISTINGPOSTALCODE)
                {
                    AddRadiusSearchCondition(sbWhereClause, oParameters, COL_COMPANY_COMPANYID, _szListingPostalCode, _iRadius);
                }
            }

            // Terminal Market IDs Criteria
            if (!String.IsNullOrEmpty(_szTerminalMarketIDs))
            {
                // Check if this should be a radius search
                if (!String.IsNullOrEmpty(_szRadiusType) &&
                    _szRadiusType == CODE_RADIUSTYPE_TERMINALMARKET &&
                    _iRadius >= 0)
                {

                    sbWhereClause.Append(" AND(");
                    string szSQL = "SELECT prtm_zip FROM PRTerminalMarket WHERE prtm_TerminalMarketId IN (" + _szTerminalMarketIDs + ")";
                    IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();

                    IDataReader oReader = oDBAccess.ExecuteReader(szSQL, CommandBehavior.CloseConnection);
                    try
                    {
                        while (oReader.Read())
                        {
                            SetOrConnector();
                            AddRadiusSearchCondition(sbWhereClause, oParameters, COL_COMPANY_COMPANYID, oReader.GetString(0), _iRadius);
                            ResetConnector();
                        }
                    }
                    finally
                    {
                        oReader.Close();
                    }
                    sbWhereClause.Append(") ");

                }
                else
                {
                    sbSubSelectWhere.Length = 0;
                    AddInCondition(sbSubSelectWhere, COL_PRCOMPANYTERMINALMARKET_TERMINALMARKETID, _szTerminalMarketIDs);
                    AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, COL_PRCOMPANYTERMINALMARKET_COMPANYID, TAB_PRCOMPANYTERMINALMARKET, sbSubSelectWhere);
                }
            }
        }


    }
}
