/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2015

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: PersonSearchCriteria
 Description:	

 Notes:	Created By Sharon Cole on 7/17/2007 2:28:32 PM

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Text;

using TSI.Utils;


namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Provides the functionality for the PersonSearchCriteria
    /// </summary>
    [Serializable]
    public class PersonSearchCriteria : SearchCriteriaBase
    {
        protected string _szFirstName;
        protected string _szLastName;
        protected string _szTitle;
        protected string _szPhoneAreaCode;
        protected string _szPhoneNumber;
        protected string _szEmail;
        protected string _szRole;


        protected StringBuilder sbPRWUCWhere;



        // CRM Company table constants
        protected const string COL_COMPANY_LISTINGSTATUS = "Comp_PRListingStatus";
        protected const string COL_COMPANY_COMPANYNAME = "comp_PRBookTradestyle";
        protected const string COL_COMPANY_LISTINGCITYID = "Comp_PRListingCityId";

        protected const string CODE_LISTINGSTATUS_LISTED = "L";
        protected const string CODE_LISTINGSTATUS_ONHOLD = "H";

        // CRM Person table constants
        protected const string TAB_PERSON = "Person";

        protected const string COL_PERSON_PERSONID = "Pers_PersonId";
        protected const string COL_PERSON_FIRSTNAME = "Pers_FirstName";
        protected const string COL_PERSON_LASTNAME = "Pers_LastName";
        protected const string COL_PERSON_MIDDLENAME = "Pers_MiddleName";
        protected const string COL_PERSON_NICKNAME = "Pers_PRNickname1";
        protected const string COL_PERSON_SUFFIX = "Pers_Suffix";
        protected const string COL_PERSON_PHONEAREACODE = "Pers_PhoneAreaCode";
        protected const string COL_PERSON_PHONENUMBER = "Pers_PhoneNumber";
        protected const string COL_PERSON_EMAIL = "Pers_EmailAddress";

        // CRM Person_Link table constants
        protected const string TAB_PERSONLINK = "Person_Link";

        protected const string COL_PERSONLINK_PERSONID = "PeLi_PersonId";
        protected const string COL_PERSONLINK_COMPANYID = "PeLi_CompanyId";
        protected const string COL_PERSONLINK_STATUS = "peli_PRStatus";
        protected const string COL_PERSONLINK_PUBLISH = "peli_PREBBPublish";
        protected const string COL_PERSONLINK_PRTITLE = "peli_PRTitle";

        protected const string CODE_STATUS_ACTIVE = "1";

        // CRM PRWebUserContact table constants
        protected const string TAB_PRWEBUSERCONTACT = "PRWebUserContact";

        protected const string COL_PRWEBUSERCONTACT_PERSONID = "prwuc_WebUserID";
        protected const string COL_PRWEBUSERCONTACT_COMPANYID = "prwuc_CompanyId";
        protected const string COL_PRWEBUSERCONTACT_FIRSTNAME = "prwuc_FirstName";
        protected const string COL_PRWEBUSERCONTACT_LASTNAME = "prwuc_LastName";
        protected const string COL_PRWEBUSERCONTACT_MIDDLENAME = "prwuc_MiddleName";
        protected const string COL_PRWEBUSERCONTACT_NICKNAME = "null";
        protected const string COL_PRWEBUSERCONTACT_SUFFIX = "prwuc_Suffix";
        protected const string COL_PRWEBUSERCONTACT_TITLE = "prwuc_Title";
        protected const string COL_PRWEBUSERCONTACT_PHONEAREACODE = "prwuc_PhoneAreaCode";
        protected const string COL_PRWEBUSERCONTACT_PHONENUMBER = "prwuc_PhoneNumber";
        protected const string COL_PRWEBUSERCONTACT_EMAIL = "prwuc_Email";
        protected const string COL_PRWEBUSERCONTACT_ISPRIVATE = "prwuc_IsPrivate";
        protected const string COL_PRWEBUSERCONTACT_HQID = "prwuc_HQID";

        // CRM vPRLocation view constants
        protected const string VIEW_PRLOCATION = "vPRLocation";

        protected const string COL_PRLOCATION_LOCATION = "CityStateCountryShort";
        protected const string COL_PRLOCATION_LISTINGCITYID = "prci_CityId";

        // CRM vPRBBOSCompanyList view constants 
        protected const string VIEW_PRBBOSCOMPANYLIST = "vPRBBOSCompanyList";

        public const string TAB_EMAIL = "Email";

        public const string COL_EMAIL_EMAILADDRESS = "Emai_EmailAddress";
        public const string COL_EMAIL_PERSONID = "elink_RecordID";
        public const string COL_EMAIL_TYPE = "elink_Type";

        public const string CODE_EMAILTYPE_E = "E";

        // Field name constants
        protected const string FIELD_PERSONID = "PersonId";
        protected const string FIELD_COMPANYID = "CompanyId";
        protected const string FIELD_FIRSTNAME = "FirstName";
        protected const string FIELD_LASTNAME = "LastName";
        protected const string FIELD_PERSONNAME = "PersonName";
        protected const string FIELD_COMPANYNAME = "CompanyName";
        protected const string FIELD_LOCATION = "Location";
        protected const string FIELD_TITLE = "Title";
        protected const string FIELD_PHONEAREACODE = "PhoneAreaCode";
        protected const string FIELD_PHONENUMBER = "PhoneNumber";
        protected const string FIELD_EMAIL = "Email";
        protected const string FIELD_SOURCETABLE = "SourceTable";
      
        // SQL constants
        protected const string SQL_PERSON_SEARCH =
            @"SELECT DISTINCT Pers_FirstName AS FirstName, Pers_LastName AS LastName, 'Person' AS SourceTable, Pers_PersonId AS PersonId, 
                               dbo.ufn_FormatPerson(Pers_FirstName, Pers_LastName, Pers_MiddleName, Pers_PRNickname1, Pers_Suffix) As PersonName, 
                               dbo.ufn_HasNote({0}, {1}, pers_PersonID, 'P') As HasNote ";

        protected const string SQL_PERSON_SEARCH_FROM =
             @" FROM Person WITH (NOLOCK)
                     INNER JOIN Person_Link WITH (NOLOCK) ON Pers_PersonId = peli_PersonID 
                     INNER JOIN vPRBBOSCompanyList ON peli_CompanyID = comp_CompanyID AND comp_PRListingStatus <> 'N3'
                     {0}
                WHERE "; //DEFECT 4443 added the <> 'N3' criteria

        protected const string SQL_PRWEBUSERCONTACT_SEARCH =
            @"SELECT prwuc_FirstName AS FirstName, prwuc_LastName AS LastName, 'PRWebUserContact' AS SourceTable, prwuc_WebUserID AS PersonId, 
                     dbo.ufn_FormatPerson(prwuc_FirstName, prwuc_LastName, prwuc_MiddleName, null, prwuc_Suffix) As PersonName,
                     NULL as HasNote ";

         protected const string SQL_PRWEBUSERCONTACT_SEARCH_FROM =
             @" FROM PRWebUserContact WITH (NOLOCK)
                     INNER JOIN vPRBBOSCompanyList ON prwuc_CompanyId = comp_CompanyID
                     {0}
                WHERE ";

        new protected const string SQL_SUB_SELECT_PERSON_ID = "Pers_PersonId IN (SELECT DISTINCT {0} FROM {1} WHERE {2})";

        /// <summary>
        /// Constructor
        /// </summary>
        public PersonSearchCriteria() { }

        #region Property Accessors
        /// <summary>
        /// Accessor for the FirstName property.
        /// </summary>
        public string FirstName
        {
            get { return _szFirstName; }
            set {
                SetDirty(value, _szFirstName);
                _szFirstName = value;
            }
        }

        /// <summary>
        /// Accessor for the LastName property.
        /// </summary>
        public string LastName
        {
            get { return _szLastName; }
            set {
                SetDirty(value, _szLastName);
                _szLastName = value;
            }
        }

        /// <summary>
        /// Accessor for the Title property.
        /// </summary>
        public string Title
        {
            get { return _szTitle; }
            set {
                SetDirty(value, _szTitle);
                _szTitle = value;
            }
        }

        /// <summary>
        /// Accessor for the PhoneAreaCode property.
        /// </summary>
        public string PhoneAreaCode
        {
            get { return _szPhoneAreaCode; }
            set {
                SetDirty(value, _szPhoneAreaCode);
                _szPhoneAreaCode = value;
            }
        }

        /// <summary>
        /// Accessor for the PhoneNumber property.
        /// </summary>
        public string PhoneNumber
        {
            get { return _szPhoneNumber; }
            set {
                SetDirty(value, _szPhoneNumber);
                _szPhoneNumber = value;
            }
        }

        /// <summary>
        /// Accessor for the Email property.
        /// </summary>
        public string Email
        {
            get { return _szEmail; }
            set {
                SetDirty(value, _szEmail);
                _szEmail = value;
            }
        }

        public string Role
        {
            get { return _szRole; }
            set {
                SetDirty(value, _szRole);
                _szRole = value;
            }
        }

        
        #endregion

        /// <summary>
        /// Generates the Search SQL based on the Search
        /// Criteria.
        /// </summary>
        /// <param name="oParams">Parameter List</param>
        /// <returns>Search SQL String</returns>
        override public string GetSearchSQL(out ArrayList oParams)
        {
            oParams = new ArrayList();
            string szWhere = BuildWhereClause(oParams);
            string szOrderBy = BuildOrderByClause();

            string szFromLocation = string.Empty;
            if ((!string.IsNullOrEmpty(_szListingCountryIDs)) ||
                (!string.IsNullOrEmpty(_szListingStateIDs)) ||
                (!string.IsNullOrEmpty(_szListingCity)))
            {
                szFromLocation = " INNER JOIN vPRLocation " + GetNoLock() + " ON comp_PRListingCityID = vPRLocation.prci_CityID ";
            }

            if (!string.IsNullOrEmpty(_szListingCounty))
            {
                szFromLocation += " INNER JOIN vPRAddress " + GetNoLock() + " On comp_CompanyID = vPRAddress.adli_CompanyID ";
            }

            string szSQL = string.Format(SQL_PERSON_SEARCH, _oUser.prwu_WebUserID, _oUser.prwu_HQID) + 
                           string.Format(SQL_PERSON_SEARCH_FROM, szFromLocation)
                           + szWhere +  
                " UNION ALL " + 
                SQL_PRWEBUSERCONTACT_SEARCH +
                string.Format(SQL_PRWEBUSERCONTACT_SEARCH_FROM, szFromLocation) + 
                sbPRWUCWhere.ToString();


            

            return string.Format(SQL_SELECT_TOP,
                                 Utilities.GetConfigValue("PersonSearchMaxResults", "2000"),
                                 szSQL,
                                 szOrderBy);
        }

        /// <summary>
        /// Returns SQL that returns only the PersonIDs that match the 
        /// specified criteria.
        /// </summary>
        /// <param name="oParams"></param>
        /// <returns></returns>
        public string GetPersonIDsSQL(out ArrayList oParams)
        {
            oParams = new ArrayList();
            string szWhere = BuildWhereClause(oParams);
            string szOrderBy = BuildOrderByClause();

            string szFromLocation = string.Empty;
            if ((!string.IsNullOrEmpty(_szListingCountryIDs)) ||
                (!string.IsNullOrEmpty(_szListingStateIDs)) ||
                (!string.IsNullOrEmpty(_szListingCity)))
            {
                szFromLocation = " INNER JOIN vPRLocation " + GetNoLock() + " ON comp_PRListingCityID = vPRLocation.prci_CityID ";
            }

            if (!string.IsNullOrEmpty(_szListingCounty))
            {
                szFromLocation += " INNER JOIN vPRAddress " + GetNoLock() + " ON comp_CompanyID = vPRAddress.adli_CompanyID ";
            }

            string szSQL = "SELECT DISTINCT pers_PersonID AS PersonId, Pers_FirstName AS FirstName, Pers_LastName AS LastName" +
                           string.Format(SQL_PERSON_SEARCH_FROM, szFromLocation)
                           + szWhere;

            return string.Format(SQL_SELECT_TOP,
                                 Utilities.GetConfigValue("PersonSearchMaxResults", "2000"),
                                 szSQL,
                                 szOrderBy);
        }

        public string GetPersonIDSubSQL(out ArrayList oParams)
        {
            oParams = new ArrayList();
            string szWhere = BuildWhereClause(oParams);
            string szOrderBy = BuildOrderByClause();

            string szFromLocation = string.Empty;
            if ((!string.IsNullOrEmpty(_szListingCountryIDs)) ||
                (!string.IsNullOrEmpty(_szListingStateIDs)) ||
                (!string.IsNullOrEmpty(_szListingCity)))
            {
                szFromLocation = " INNER JOIN vPRLocation " + GetNoLock() + " ON comp_PRListingCityID = vPRLocation.prci_CityID ";
            }

            if (!string.IsNullOrEmpty(_szListingCounty))
            {
                szFromLocation += " INNER JOIN vPRAddress " + GetNoLock() + " ON comp_CompanyID = vPRAddress.adli_CompanyID ";
            }

            string szSQL = "SELECT DISTINCT pers_PersonID" +
                           string.Format(SQL_PERSON_SEARCH_FROM, szFromLocation)
                           + szWhere
                           + szOrderBy;

            return szSQL;
        }

        /// <summary>
        /// Returns SQL that returns only the WebUserContactIDs that match the 
        /// specified criteria.
        /// </summary>
        /// <param name="oParams"></param>
        /// <returns></returns>
        public string GetWebUserContactIDsSQL(out ArrayList oParams)
        {
            oParams = new ArrayList();
            BuildWhereClause(oParams);
            string szOrderBy = BuildOrderByClause();

            string szFromLocation = string.Empty;
            if ((!string.IsNullOrEmpty(_szListingCountryIDs)) ||
                (!string.IsNullOrEmpty(_szListingStateIDs)) ||
                (!string.IsNullOrEmpty(_szListingCity)))
            {
                szFromLocation = " INNER JOIN vPRLocation " + GetNoLock() + " ON comp_PRListingCityID = vPRLocation.prci_CityID ";
            }

            if (!string.IsNullOrEmpty(_szListingCounty))
            {
                szFromLocation += " INNER JOIN vPRAddress " + GetNoLock() + " ON comp_CompanyID = vPRAddress.adli_CompanyID ";
            }

            string szSQL = "SELECT DISTINCT prwuc_WebUserID AS PersonId, prwuc_FirstName AS FirstName, prwuc_LastName AS LastName " +
                           string.Format(SQL_PRWEBUSERCONTACT_SEARCH_FROM, szFromLocation)
                           + sbPRWUCWhere.ToString();


            // Double the search limit to include those persons associated with multiple companies

            return string.Format(SQL_SELECT_TOP,
                                 Utilities.GetConfigValue("PersonSearchMaxResults", "2000"),
                                 szSQL,
                                 szOrderBy);
        }

        /// <summary>
        /// Returns the SQL to count the number of rows that would be 
        /// returned by the specified criteria.
        /// </summary>
        /// <param name="oParams"></param>
        /// <returns></returns>
        override public string GetSearchCountSQL(out ArrayList oParams) {
            oParams = new ArrayList();
            string szWhere = BuildWhereClause(oParams);

            string szFromLocation = string.Empty;
            if ((!string.IsNullOrEmpty(_szListingCountryIDs)) ||
                (!string.IsNullOrEmpty(_szListingStateIDs)) ||
                (!string.IsNullOrEmpty(_szListingCity)))
            {
                szFromLocation = " INNER JOIN vPRLocation " + GetNoLock() + " ON comp_PRListingCityID = vPRLocation.prci_CityID ";
            }

            string szSQL = 
                "SELECT COUNT(DISTINCT pers_PersonID) As Cnt " + string.Format(SQL_PERSON_SEARCH_FROM, szFromLocation) + szWhere +
                " UNION ALL " +
                "SELECT COUNT(DISTINCT prwuc_WebUserContactID) As Cnt " + string.Format(SQL_PRWEBUSERCONTACT_SEARCH_FROM, szFromLocation) + sbPRWUCWhere.ToString();


            return "SELECT SUM(Cnt) As Cnt FROM (" + szSQL + ") T1 ";
        }

        /// <summary>
        /// Builds the appropriate WHERE clause for the table based on the criteria
        /// specified.
        /// </summary>
        /// <param name="oParameters">Parameter List</param>
        /// <returns>WHERE Clause</returns>
        override protected string BuildWhereClause(IList oParameters)
        {
            StringBuilder sbWhereClause = new StringBuilder();
            StringBuilder sbSubSelectWhere = new StringBuilder();

            string szBaseSearchSQL = "";

            sbPRWUCWhere = new StringBuilder();

            szBaseSearchSQL = base.BuildWhereClause(oParameters);
            sbWhereClause.Append(szBaseSearchSQL);
            sbWhereClause.Replace(COL_COMPANY_COMPANYID, COL_PERSONLINK_COMPANYID);

            sbPRWUCWhere.Append(szBaseSearchSQL);
            sbPRWUCWhere.Replace(COL_COMPANY_COMPANYID, COL_PRWEBUSERCONTACT_COMPANYID);

            // Industry Type Criteria
            if (!string.IsNullOrEmpty(_szIndustryType))
            {
                AddCondition(sbWhereClause, oParameters, "comp_PRIndustryType", "=", _szIndustryType);
            }


            // First Name Criteria
            if (!String.IsNullOrEmpty(_szFirstName))
            {

                sbSubSelectWhere.Length = 0;
                AddStringCondition(sbSubSelectWhere, oParameters, COL_PERSON_FIRSTNAME, _szFirstName);
                _bUseOrConnector = true;
                AddStringCondition(sbSubSelectWhere, oParameters, COL_PERSON_NICKNAME, _szFirstName);
                _bUseOrConnector = false;

                sbWhereClause.Append(" AND (");
                sbWhereClause.Append(sbSubSelectWhere.ToString());
                sbWhereClause.Append(")");

                AddStringCondition(sbPRWUCWhere, oParameters, COL_PRWEBUSERCONTACT_FIRSTNAME, _szFirstName);
            }

            // Last Name Criteria
            if (!String.IsNullOrEmpty(_szLastName))
            {
                AddStringCondition(sbWhereClause, oParameters, COL_PERSON_LASTNAME, _szLastName);
                AddStringCondition(sbPRWUCWhere, oParameters, COL_PRWEBUSERCONTACT_LASTNAME, _szLastName);
            }

            // Title Criteria
            if (!String.IsNullOrEmpty(_szTitle))
            {
                AddStringCondition(sbWhereClause, oParameters, COL_PERSONLINK_PRTITLE, _szTitle);
                AddStringCondition(sbPRWUCWhere, oParameters, COL_PRWEBUSERCONTACT_TITLE, _szTitle); 
            }

            // Phone Area Code Criteria
            if (!String.IsNullOrEmpty(_szPhoneAreaCode))
            {
                AddCondition(sbPRWUCWhere, oParameters, COL_PRWEBUSERCONTACT_PHONEAREACODE, "=", _szPhoneAreaCode);
            }

            // Phone Number Criteria
            if (!String.IsNullOrEmpty(_szPhoneNumber))
            {
                AddCondition(sbPRWUCWhere, oParameters, COL_PRWEBUSERCONTACT_PHONENUMBER, "=", _szPhoneNumber);
            }

            // Phone Area Code Criteria
            if ((!string.IsNullOrEmpty(_szPhoneAreaCode)) || (!string.IsNullOrEmpty(_szPhoneNumber)))
            {
                sbSubSelectWhere.Length = 0;
                if ((!string.IsNullOrEmpty(_szPhoneAreaCode)))
                {
                    AddCondition(sbSubSelectWhere, oParameters, COL_PHONE_AREACODE, "=", _szPhoneAreaCode);
                }

                if (!string.IsNullOrEmpty(_szPhoneNumber))
                {
                    AddCondition(sbSubSelectWhere, oParameters, COL_PHONE_NUMBER, "=", _szPhoneNumber);
                }

                AddCondition(sbSubSelectWhere, oParameters, "phon_PRIsPhone", "=", "Y");
                AddCondition(sbSubSelectWhere, oParameters, "phon_PRPreferredPublished", "=", CODE_PUBLISHED);
                AddIsNotNullCondition(sbSubSelectWhere, "phon_PersonID");

                AddSubSelect(sbWhereClause, SQL_SUB_SELECT_PERSON_ID, "phon_PersonID", "vPRPhone", sbSubSelectWhere);
            }


            // Email Criteria
            if (!String.IsNullOrEmpty(_szEmail))
            {
                sbSubSelectWhere.Length = 0;
                AddStringCondition(sbSubSelectWhere, oParameters, COL_EMAIL_EMAILADDRESS, _szEmail);
                AddCondition(sbSubSelectWhere, oParameters, COL_EMAIL_TYPE, "=", CODE_EMAILTYPE_E);
                AddSubSelect(sbWhereClause, SQL_SUB_SELECT_PERSON_ID, COL_EMAIL_PERSONID, "vPersonEmail", sbSubSelectWhere);

                AddStringCondition(sbPRWUCWhere, oParameters, COL_PRWEBUSERCONTACT_EMAIL, _szEmail);
            }

            // Add additional system criteria
            // Person Link Status = Active
            AddCondition(sbWhereClause, oParameters, COL_PERSONLINK_STATUS, "=", CODE_STATUS_ACTIVE);

            // Person Link Published 
            AddCondition(sbWhereClause, oParameters, COL_PERSONLINK_PUBLISH, "=", CODE_PUBLISHED);

            // Listing status = listed or listed on hold - This will be filtered 
            // using the join to the vPRBBOSCompanyList

            // When querying for Personal Contacts, include contacts for the current user and also
            // the public contact for other users for the same company            
            if (sbPRWUCWhere.Length > 0) {
                sbPRWUCWhere.Append(" AND ");
            }
            sbPRWUCWhere.Append(" ((");
            AddCondition(sbPRWUCWhere, oParameters, COL_PRWEBUSERCONTACT_PERSONID, "=", _oUser.prwu_WebUserID);
            sbPRWUCWhere.Append(") OR (");
            AddCondition(sbPRWUCWhere, oParameters, COL_PRWEBUSERCONTACT_HQID, "=", _oUser.prwu_HQID);
            AddIsNullCondition(sbPRWUCWhere, COL_PRWEBUSERCONTACT_ISPRIVATE);
            sbPRWUCWhere.Append("))");


            #region Location Search Criteria
            BuildLocationCriteria(sbWhereClause, oParameters);
            BuildLocationCriteria(sbPRWUCWhere, oParameters);
            #endregion


            // User List IDs Criteria
            if (!String.IsNullOrEmpty(_szUserListIDs))
            {
                sbSubSelectWhere.Length = 0;
                AddInCondition(sbSubSelectWhere, COL_PRWEBUSERLISTDETAIL_WEBUSERLISTID, _szUserListIDs);
                AddCondition(sbSubSelectWhere, oParameters, COL_PRWEBUSERLISTDETAIL_ASSOCIATEDTYPE, "=", CODE_ASSOCIATEDTYPE_COMPANY);
                AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, COL_PRWEBUSERLISTDETAIL_ASSOCIATEDID, TAB_PRWEBUSERLISTDETAIL, sbSubSelectWhere);
                AddSubSelect(sbPRWUCWhere, SQL_SUB_SELECT_COMPANY_ID, COL_PRWEBUSERLISTDETAIL_ASSOCIATEDID, TAB_PRWEBUSERLISTDETAIL, sbSubSelectWhere);
            }


            #region Custom Search Criteria
            // Has Notes
            if (_bHasNotes)
            {
                // If HasNotes is specified, limit the result set to those Persons that have an 
                // associated note that the user can see
                sbSubSelectWhere.Length = 0;
                AddCondition(sbSubSelectWhere, oParameters, COL_PRWEBUSERNOTE_TYPECODE, "=", CODE_PRWEBUSERNOTE_TYPEPERSON);
                sbSubSelectWhere.Append(" AND ((");

                AddCondition(sbSubSelectWhere, oParameters, COL_PRWEBUSERNOTE_WEBUSERID, "=", _oUser.prwu_WebUserID);
                AddCondition(sbSubSelectWhere, oParameters, COL_PRWEBUSERNOTE_PRIVATE, "=", CODE_PRIVATE);

                sbSubSelectWhere.Append(") OR (");
                AddCondition(sbSubSelectWhere, oParameters, COL_PRWEBUSERNOTE_HQID, "=", _oUser.prwu_HQID);
                AddIsNullCondition(sbSubSelectWhere, COL_PRWEBUSERNOTE_PRIVATE);
                sbSubSelectWhere.Append("))");

                AddSubSelect(sbWhereClause, SQL_SUB_SELECT_PERSON_ID, COL_PRWEBUSERNOTE_PERSONID, TAB_PRWEBUSERNOTE, sbSubSelectWhere);
                
            }

            // Custom Identifier Criteria
            //if (!String.IsNullOrEmpty(_szCustomIdentifier))
            //{
            //    sbSubSelectWhere.Length = 0;
            //    AddStringCondition(sbSubSelectWhere, oParameters, COL_PRWEBUSERCUSTOMDATA_VALUE, _szCustomIdentifier);
            //    AddCondition(sbSubSelectWhere, oParameters, COL_PRWEBUSERCUSTOMDATA_LABELCODE, "=", CODE_LABELCODE_CUSTOMIDENTIFIER);
            //    AddCondition(sbSubSelectWhere, oParameters, "prwucd_HQID", "=", _oUser.prwu_HQID);

            //    AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, COL_PRWEBUSERCUSTOMDATA_COMPANYID, TAB_PRWEBUSERCUSTOMDATA, sbSubSelectWhere);
            //    AddSubSelect(sbPRWUCWhere, SQL_SUB_SELECT_COMPANY_ID, COL_PRWEBUSERCUSTOMDATA_COMPANYID, TAB_PRWEBUSERCUSTOMDATA, sbSubSelectWhere);
            //}

            //// Custom Identifier Not Null Criteria
            //if (_bCustomIdentifierNotNull)
            //{
            //    sbSubSelectWhere.Length = 0;
            //    AddIsNotNullCondition(sbSubSelectWhere, COL_PRWEBUSERCUSTOMDATA_VALUE);
            //    AddCondition(sbSubSelectWhere, oParameters, COL_PRWEBUSERCUSTOMDATA_LABELCODE, "=", CODE_LABELCODE_CUSTOMIDENTIFIER);
            //    AddCondition(sbSubSelectWhere, oParameters, "prwucd_HQID", "=", _oUser.prwu_HQID);
                
            //    AddSubSelect(sbWhereClause, SQL_SUB_SELECT_COMPANY_ID, COL_PRWEBUSERCUSTOMDATA_COMPANYID, TAB_PRWEBUSERCUSTOMDATA, sbSubSelectWhere);
            //    AddSubSelect(sbPRWUCWhere, SQL_SUB_SELECT_COMPANY_ID, COL_PRWEBUSERCUSTOMDATA_COMPANYID, TAB_PRWEBUSERCUSTOMDATA, sbSubSelectWhere);
            //}
            #endregion            
            

            // Role
            if (!string.IsNullOrEmpty(_szRole))
            {
                sbSubSelectWhere.Length = 0;
                string[] aRoles = _szRole.Split(new char[] { ',' });
                foreach (string role in aRoles)
                {
                    if (sbSubSelectWhere.Length > 0)
                    {
                        sbSubSelectWhere.Append(" OR ");
                    }

                    sbSubSelectWhere.Append("peli_PRRole LIKE '%," + role + ",%'");
                }

                if (sbWhereClause.Length > 0)
                {
                    sbWhereClause.Append(" AND ");
                }
                sbWhereClause.Append("(");
                sbWhereClause.Append(sbSubSelectWhere);
                sbWhereClause.Append(")");

            }

            AddConnector(sbWhereClause);
            sbWhereClause.Append(GetObjectMgr().GetLocalSourceCondition());
            AddConnector(sbWhereClause);
            sbWhereClause.Append(GetObjectMgr().GetIntlTradeAssociationCondition());

            return sbWhereClause.ToString();
        }
    }
}
