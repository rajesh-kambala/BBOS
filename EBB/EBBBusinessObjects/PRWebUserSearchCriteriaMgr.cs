/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2020

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
using System.Data;
using PRCo.EBB.Util;
using TSI.Arch;
using TSI.BusinessObjects;
using TSI.Security;
using TSI.Utils;

namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Data Manager for the PRWebUserSearchCriteria class.
    /// </summary>
    [Serializable]
    public class PRWebUserSearchCriteriaMgr : EBBObjectMgr
    {
        public const string SQL_GET_LAST_EXECUTED = "SELECT * FROM PRWebUserSearchCriteria WHERE prsc_SearchCriteriaID={0}";

        public const string SQL_GET_LAST_UNSAVED_SEARCH = "SELECT * " +
            " FROM " + TAB_PRWEBUSERSEARCHCRITERIA +
            " WHERE " + COL_PRSC_WEB_USER_ID + " = {0}" +
            " AND " + COL_PRSC_IS_LAST_UNSAVED_SEARCH + " = 'Y'" +
            " AND " + COL_PRSC_SEARCH_TYPE + " = {1}";

        protected IPRWebUser _oWebUser;

        public const string TAB_PRWEBUSERSEARCHCRITERIA = "PRWebUserSearchCriteria";

        public const string COL_PRSC_SEARCH_CRITERIA_ID = "prsc_SearchCriteriaID";
        public const string COL_PRSC_WEB_USER_ID = "prsc_WebUserID";
        public const string COL_PRSC_COMPANY_ID = "prsc_CompanyID";

        public const string COL_PRSC_NAME = "prsc_Name";

        public const string COL_PRSC_LAST_EXECUTION_DATE_TIME = "prsc_LastExecutionDateTime";
        public const string COL_PRSC_EXECUTION_COUNT = "prsc_ExecutionCount";
        public const string COL_PRSC_LAST_EXECUTION_RESULT_COUNT = "prsc_LastExecutionResultCount";

        public const string COL_PRSC_SEARCH_TYPE = "prsc_SearchType";
        public const string COL_PRSC_CRITERIA = "prsc_Criteria";

        public const string COL_PRSC_SELECTED_IDS = "prsc_SelectedIDs";

        public const string COL_PRSC_DELETED = "prsc_Deleted";

        public const string COL_PRSC_IS_PRIVATE = "prsc_IsPrivate";
        public const string COL_PRSC_IS_LAST_UNSAVED_SEARCH = "prsc_IsLastUnsavedSearch";

        public const string COL_PRSC_HQID = "prsc_HQID";

        public const string COL_PRSC_CREATED_DATE = "prsc_CreatedDate";
        public const string COL_PRSC_UPDATED_DATE = "prsc_UpdatedDate";
        public const string COL_PRSC_CREATED_BY = "prsc_CreatedBy";
        public const string COL_PRSC_UPDATED_BY = "prsc_UpdatedBy";
        public const string COL_PRSC_TIME_STAMP = "prsc_TimeStamp";


        #region TSI Framework Generated Code
        /// <summary>
        /// Constructor to initalize data manager
        /// </summary>
        /// <returns></returns>
        public PRWebUserSearchCriteriaMgr() {}

        /// <summary>
        /// Constructor to initalize data manager
        /// </summary>
        /// <param name="oLogger">Logger</param>
        /// <param name="oUser">Current User</param>
        public PRWebUserSearchCriteriaMgr(ILogger oLogger,
                                IUser oUser)
            : base(oLogger, oUser) { }

        /// <summary>
        /// Constructor to initalize data manager
        /// </summary>
        /// <param name="oConn">DB Connection</param>
        /// <param name="oLogger">Logger</param>
        /// <param name="oUser">Current User</param>
        public PRWebUserSearchCriteriaMgr(IDbConnection oConn,
                                ILogger oLogger,
                                IUser oUser)
            : base(oConn, oLogger, oUser) { }

        /// <summary>
        /// Constructor using the Logger, User, and Transaction
        /// of the specified Manager to initialize this manager.
        /// </summary>
        /// <param name="oBizObjMgr">Business Object Manager</param>
        public PRWebUserSearchCriteriaMgr(BusinessObjectMgr oBizObjMgr) : base(oBizObjMgr) { }

        /// <summary>
        /// Creates an instance of the PRWebUserSearchCriteria business object
        /// </summary>
        /// <returns>IBusinessObject</returns>
        override protected IBusinessObject InstantiateBusinessObject(IDictionary oData)
        {
            return new PRWebUserSearchCriteria();
        }

        /// <summary>
        /// The name of the table our business object
        /// is mapped to.
        /// </summary>
        /// <returns>Table Name</returns>
        override public string GetTableName()
        {
            return "PRWebUserSearchCriteria";
        }

        /// <summary>
        /// The name of the business object class.
        /// </summary>
        /// <returns>Business Object Name</returns>
        override public string GetBusinessObjectName()
        {
            return "PRCo.EBB.BusinessObjects.PRWebUserSearchCriteria";
        }

        /// <summary>
        /// The fields that uniquly identify this object.
        /// </summary>
        /// <returns>IList</returns>
        override public IList GetKeyFields()
        {
            return new String[] { COL_PRSC_SEARCH_CRITERIA_ID };
        }

        /// <summary>
        /// Executes the search based on the current criteria set on the 
        /// PRWebUserSearchCriteria object
        /// </summary>
        /// <param name="oWebUserSearchCriteria">PRWebUserSearchCriteria Object</param>
        /// <returns>Data Reader</returns>
        public IDataReader Search(IPRWebUserSearchCriteria oWebUserSearchCriteria)
        {
            ArrayList oParameters = new ArrayList();

            string szSQL = oWebUserSearchCriteria.Criteria.GetSearchSQL(out oParameters);

            IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);

            return oReader;
        }

        /// <summary>
        /// Saves the corresponding PRWebUserSearchCriteria object
        /// </summary>
        /// <param name="oWebUserSearchCriteria"></param>
        public void Save(IPRWebUserSearchCriteria oWebUserSearchCriteria)
        {
            oWebUserSearchCriteria.Save();
        }

        /// <summary>
        /// Update the corresponding field related to search statistics 
        /// and save the current object.
        /// </summary>
        /// <param name="oSearchCriteria"></param>
        /// <param name="oTran"></param>
        public void SaveStats(IPRWebUserSearchCriteria oSearchCriteria, IDbTransaction oTran)
        {
            if (oSearchCriteria.prsc_SearchCriteriaID > 0)
            {
                ArrayList oParameters = new ArrayList();
                oParameters.Add(new ObjectParameter("prsc_IsLastUnsavedSearch", oSearchCriteria.prsc_IsLastUnsavedSearch));
                oParameters.Add(new ObjectParameter("prsc_LastExecutionDateTime", oSearchCriteria.prsc_LastExecutionDateTime));
                oParameters.Add(new ObjectParameter("prsc_LastExecutionResultCount", oSearchCriteria.prsc_LastExecutionResultCount));
                oParameters.Add(new ObjectParameter("prsc_ExecutionCount", oSearchCriteria.prsc_ExecutionCount));
                oParameters.Add(new ObjectParameter("prsc_SearchCriteriaID", oSearchCriteria.prsc_SearchCriteriaID));

                string szSQL = FormatSQL("Update PRWebUserSearchCriteria SET prsc_IsLastUnsavedSearch={0}, prsc_LastExecutionDateTime={1}, prsc_LastExecutionResultCount={2}, prsc_ExecutionCount={3} WHERE prsc_SearchCriteriaID={4}",
                                         oParameters);

                GetDBAccess().ExecuteNonQuery(szSQL, oParameters, oTran);
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="oSearchCriteria"></param>
        /// <param name="oTran"></param>
        public void SaveSelected(IPRWebUserSearchCriteria oSearchCriteria, IDbTransaction oTran)
        {
            if (oSearchCriteria.prsc_SearchCriteriaID > 0)
            {
                ArrayList oParameters = new ArrayList();
                oParameters.Add(new ObjectParameter("prsc_SelectedIDs", oSearchCriteria.prsc_SelectedIDs));
                oParameters.Add(new ObjectParameter("prsc_SearchCriteriaID", oSearchCriteria.prsc_SearchCriteriaID));

                string szSQL = FormatSQL("Update PRWebUserSearchCriteria SET prsc_SelectedIDs={0} WHERE prsc_SearchCriteriaID={1}",
                                         oParameters);

                GetDBAccess().ExecuteNonQuery(szSQL, oParameters, oTran);
            }
        }

        /// <summary>
        /// Saves the last search executed and updates the PRWebUser record accordingly.
        /// </summary>
        /// <param name="oWebUserSearchCriteria"></param>
        /// <param name="oTran"></param>
        public void SaveLastSearch(IPRWebUserSearchCriteria oWebUserSearchCriteria, IDbTransaction oTran)
        {
            IPRWebUserSearchCriteria oLastSearch;
            _oWebUser = (IPRWebUser)_oUser;            
                    
            // If our criteria has not changed, then we are executing
            // a saved search so just use that instance.                    
            if (!oWebUserSearchCriteria.Criteria.IsDirty) {
                oWebUserSearchCriteria.Save();
                oLastSearch = oWebUserSearchCriteria;
            } else {

                oLastSearch = GetLastUnsavedSearch(oWebUserSearchCriteria.prsc_SearchType);

                // If this is a previously saved search
                if (oWebUserSearchCriteria.prsc_SearchCriteriaID > 0)
                {
                    // This could already be the last saved search
                    if (oWebUserSearchCriteria.prsc_IsLastUnsavedSearch)
                    {
                        oLastSearch = oWebUserSearchCriteria;
                    }
                    else
                    {
                        if (oLastSearch == null) {
                            oLastSearch = (IPRWebUserSearchCriteria)oWebUserSearchCriteria.Copy();
                            oLastSearch.prsc_SearchCriteriaID = 0;
                        } else {
                            // Copy Object
                            int iLastSearchID = oLastSearch.prsc_SearchCriteriaID;
                            oLastSearch = (IPRWebUserSearchCriteria)oWebUserSearchCriteria.Copy();
                            oLastSearch.prsc_SearchCriteriaID = iLastSearchID;
                            oLastSearch.IsInDB = true;
                        }
                    }
                }
                else
                {
                    if (oLastSearch == null) 
                    {
                        oLastSearch = oWebUserSearchCriteria;
                    }
                    else
                    {
                        // Copy search criteria object
                        int iLastSearchID = oLastSearch.prsc_SearchCriteriaID;
                        oLastSearch = (IPRWebUserSearchCriteria)oWebUserSearchCriteria.Copy();
                        oLastSearch.prsc_SearchCriteriaID = iLastSearchID;
                        oLastSearch.IsInDB = true;
                    }
                }

                if (oLastSearch != null)
                {
                    Custom_CaptionMgr _oCCMgr = new Custom_CaptionMgr(this);
                    string szUnsavedName = _oCCMgr.GetMeaning("LastUnsavedSearch", "1");
                    string szSearchType = _oCCMgr.GetMeaning("prsc_SearchType", oWebUserSearchCriteria.prsc_SearchType);

                    oLastSearch.prsc_Name = string.Format(szUnsavedName, szSearchType);
                    oLastSearch.prsc_IsPrivate = true;
                    oLastSearch.prsc_IsLastUnsavedSearch = true;
                    oLastSearch.Save();
                }
            }
            
            
            // Make sure we save the ID of the last
            // executed search by type.
            switch (oWebUserSearchCriteria.prsc_SearchType)
            {
                case PRWebUserSearchCriteria.SEARCH_TYPE_COMPANY:
                    _oWebUser.prwu_LastCompanySearchID = oLastSearch.prsc_SearchCriteriaID;
                    break;
                case PRWebUserSearchCriteria.SEARCH_TYPE_COMPANY_UPDATE:
                    _oWebUser.prwu_LastCreditSheetSearchID = oLastSearch.prsc_SearchCriteriaID;
                    break;
                case PRWebUserSearchCriteria.SEARCH_TYPE_PERSON:
                    _oWebUser.prwu_LastPersonSearchID = oLastSearch.prsc_SearchCriteriaID;
                    break;
                case PRWebUserSearchCriteria.SEARCH_TYPE_CLAIM_ACTIVITY:
                    _oWebUser.prwu_LastClaimsActivitySearchID = oLastSearch.prsc_SearchCriteriaID;
                    break;

            }

            _oWebUser.Save();
        }


        /// <summary>
        /// 
        /// </summary>
        /// <param name="szSearchType"></param>
        public IPRWebUserSearchCriteria GetLastExecuted(string szSearchType)
        {
            ArrayList oParameters = new ArrayList();

            IPRWebUser oWebUser = (IPRWebUser)_oUser;
            int iSearchID = 0;
            switch (szSearchType)
            {
                case PRWebUserSearchCriteria.SEARCH_TYPE_COMPANY:
                    iSearchID = oWebUser.prwu_LastCompanySearchID;
                    break;
                case PRWebUserSearchCriteria.SEARCH_TYPE_PERSON:
                    iSearchID = oWebUser.prwu_LastPersonSearchID;
                    break;
                case PRWebUserSearchCriteria.SEARCH_TYPE_COMPANY_UPDATE:
                    iSearchID = oWebUser.prwu_LastCreditSheetSearchID;
                    break;
                default:
                    throw new ApplicationUnexpectedException("Invalid Search Type");
            }

            oParameters.Add(new ObjectParameter("Parm01", iSearchID));

            string szSQL = FormatSQL(SQL_GET_LAST_EXECUTED, oParameters);
            
            IPRWebUserSearchCriteria oSearchCriteria = (IPRWebUserSearchCriteria)GetObjectByKey(iSearchID);
            
            if (oSearchCriteria != null) {
                oSearchCriteria.Criteria.WebUser = oWebUser;
            }

            return oSearchCriteria;

        }

        private PRWebUserSearchCriteria GetLastUnsavedSearch(string szSearchType)
        {
            ArrayList oParameters = new ArrayList();

            oParameters.Add(new ObjectParameter("Parm02", _oWebUser.prwu_WebUserID));
            oParameters.Add(new ObjectParameter("Parm01", szSearchType));

            string szSQL = FormatSQL(SQL_GET_LAST_UNSAVED_SEARCH, oParameters);

            IBusinessObjectSet oSet = GetObjectsByCustomSQL(szSQL, oParameters);
            if (oSet.Count == 0)
            {
                return null;
            }
            else
            {
                return (PRWebUserSearchCriteria)oSet[0];
            }
        }
        #endregion


        public override bool UsesIdentity {
            get {return true; }
        }
    }
}
