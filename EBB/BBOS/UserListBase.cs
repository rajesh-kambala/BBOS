/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: UserListBase
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/

using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Text;
using TSI.Arch;
using TSI.BusinessObjects;
using TSI.DataAccess;

namespace PRCo.BBOS.UI.Web
{
    public class UserListBase : PageBase
    {
        protected const string CODE_LIST_TYPE_AUS = "AUS";
        protected const string CODE_LIST_TYPE_CONNECTIONLIST = "CL";
        protected const string CODE_LIST_TYPE_CUSTOM = "CU";

        protected IDbTransaction oTran = null;

        #region Select Functions
        protected const string SQL_GET_USER_LIST_COMPANY_IDS =
            @"SELECT prwuld_AssociatedID 
                FROM PRWebUserListDetail WITH (NOLOCK) 
               WHERE prwuld_WebUserListID = {0} 
                 AND prwuld_AssociatedType = 'C' 
                 AND prwuld_Deleted IS NULL";


        protected const string SQL_GET_WEB_USER_LIST_DATA =
            @"SELECT prwucl_Name, prwucl_Description, 
                     prwucl_IsPrivate, prwucl_TypeCode, prwucl_WebUserID, 
                     dbo.ufn_FormatPerson(Pers_FirstName, Pers_LastName, Pers_MiddleName, pers_PRNickname1, Pers_Suffix) AS CreatedBy, 
                     dbo.ufn_GetWebUserLocation(prwucl_CreatedBy) AS CreatedByLocation, 
                     dbo.ufn_FormatPerson(Pers_FirstName, Pers_LastName, Pers_MiddleName, pers_PRNickname1, Pers_Suffix) AS UpdatedBy, 
                     dbo.ufn_GetWebUserLocation(prwucl_UpdatedBy) AS UpdatedByLocation, 
                     prwucl_Pinned, prwucl_CategoryIcon
                FROM PRWebUserList WITH (NOLOCK)
                     LEFT OUTER JOIN PRWebUser WITH (NOLOCK) ON prwucl_WebUserID = prwu_WebUserID 
                     LEFT OUTER JOIN Person_Link WITH (NOLOCK) ON prwu_PersonLinkID = PeLi_PersonLinkId  
                     LEFT OUTER JOIN Person WITH (NOLOCK) ON Person_Link.PeLi_PersonId = Pers_PersonId 
               WHERE prwucl_WebUserListID = {0} 
                 AND ((prwucl_WebUserID = {1} AND prwucl_IsPrivate = 'Y') 
                     OR (prwucl_HQID = {2} AND prwucl_IsPrivate IS NULL))";

        protected const string SQL_EXCLUDE_CUSTOM_LISTS = " AND prwucl_TypeCode <> '" + CODE_LIST_TYPE_CUSTOM + "'";

        /// <summary>
        /// Helper method used to retrieve the associated company ids for the 
        /// specified user list.
        /// </summary>
        /// <param name="iListID"></param>
        /// <returns>Comma-delimited list of associated company ids</returns>
        protected string GetUserListCompanyIDs(int iListID)
        {
            StringBuilder sbList = new StringBuilder();

            // We want our own connection to avoid conflicts with
            // an open DataReader
            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            oDBAccess.Logger = _oLogger;

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prwuld_WebUserListID", iListID));

            string szSQL = GetObjectMgr().FormatSQL(SQL_GET_USER_LIST_COMPANY_IDS, oParameters);
            IDataReader oReader = oDBAccess.ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            try
            {
                while (oReader.Read())
                {
                    if (sbList.Length > 0)
                        sbList.Append(",");
                    sbList.Append(oReader.GetInt32(0).ToString());
                }
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }

            // This is used in an IN clause so 
            // returning an empty string causes a SQL exception.
            // Instead specify an ID that does not exist.
            if (sbList.Length == 0)
            {
                sbList.Append("0");
            }

            return sbList.ToString();
        }


        protected HashSet<Int32> GetUserListCompanyIDAsHashSet(int iListID)
        {
            HashSet<Int32> companyIDs = new HashSet<int>();

            // We want our own connection to avoid conflicts with
            // an open DataReader
            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            oDBAccess.Logger = _oLogger;

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prwuld_WebUserListID", iListID));

            string szSQL = GetObjectMgr().FormatSQL(SQL_GET_USER_LIST_COMPANY_IDS, oParameters);
            IDataReader oReader = oDBAccess.ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            try
            {
                while (oReader.Read())
                {
                    companyIDs.Add(oReader.GetInt32(0));
                }
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }
            return companyIDs;
        }

        private const string SQL_RECORD_EXISTS_PRWEBUSERLIST =
            @"SELECT COUNT(1) AS RecordCount 
                FROM PRWebUserList WITH (NOLOCK) 
               WHERE prwucl_Name = {0} 
                 AND prwucl_Deleted IS NULL";

        private const string SQL_WHERE_PRIVATE_LIST_FOR_USER = " AND (prwucl_WebUserID={1} AND prwucl_IsPrivate = 'Y')";
        private const string SQL_WHERE_PUBLIC_LIST_FOR_COMPANY = " AND (prwucl_HQID = {1} AND prwucl_IsPrivate IS NULL)";

        /// <summary>
        /// Helper method used to determine if the list name entered on the form is unique.  Names
        /// for public lists must be unique within the user's company.  Names for private lists must be
        /// unique for the user.
        /// </summary>
        /// <param name="szListName">List Name</param>
        /// <param name="bIsPrivate">Is Private</param>
        /// <returns></returns>
        protected bool IsListNameUnique(string szListName, bool bIsPrivate)
        {
            bool bUniqueName = false;
            string szSQL;

            ArrayList oParameters = new ArrayList();

            oParameters.Add(new ObjectParameter("prwucl_Name", szListName));

            // If this is a private list names must be unique for the user
            if (bIsPrivate)
            {
                oParameters.Add(new ObjectParameter("prwucl_WebUserID", _oUser.prwu_WebUserID));
                szSQL = GetObjectMgr().FormatSQL(SQL_RECORD_EXISTS_PRWEBUSERLIST + SQL_WHERE_PRIVATE_LIST_FOR_USER, oParameters);
            }
            // else, public list - the name must be unique within the user's company
            else
            {
                oParameters.Add(new ObjectParameter("prwucl_HQID", _oUser.prwu_HQID));
                szSQL = GetObjectMgr().FormatSQL(SQL_RECORD_EXISTS_PRWEBUSERLIST + SQL_WHERE_PUBLIC_LIST_FOR_COMPANY, oParameters);
            }

            IDBAccess oDataAccess = DBAccessFactory.getDBAccessProvider();
            oDataAccess.Logger = _oLogger;

            int iCount = (int)oDataAccess.ExecuteScalar(szSQL, oParameters);

            if (iCount > 0)
                bUniqueName = false;
            else
                bUniqueName = true;

            return bUniqueName;
        }


        private const string SQL_AUTHORIZED_FOR_EDIT =
            @"SELECT COUNT(1) AS RecordCount 
                FROM PRWebUserList WITH (NOLOCK)
               WHERE ((prwucl_HQID = {0} AND prwucl_IsPrivate IS NULL) 
                      OR (prwucl_WebUserID={1} AND prwucl_IsPrivate = 'Y')) 
                 AND prwucl_Deleted IS NULL";

        /// <summary>
        /// Helper method used to determine if the current user is authorized to edit the
        /// user list.  Private user lists owned by the current user and public user lists 
        /// associated with the current user's enterprise can be edited.
        /// </summary>
        /// <param name="iListID"></param>
        /// <returns></returns>
        protected bool IsAuthorizedForEdit(int iListID)
        {
            bool bRecordFound = false;

            ArrayList oParameters = new ArrayList();

            oParameters.Add(new ObjectParameter("prwucl_HQID", _oUser.prwu_HQID));
            oParameters.Add(new ObjectParameter("prwucl_WebUserID", _oUser.prwu_WebUserID));

            string szSQL = GetObjectMgr().FormatSQL(SQL_AUTHORIZED_FOR_EDIT, oParameters);

            IDBAccess oDataAccess = DBAccessFactory.getDBAccessProvider();
            oDataAccess.Logger = _oLogger;

            int iCount = (int)oDataAccess.ExecuteScalar(szSQL, oParameters);

            if (iCount > 0)
                bRecordFound = true;
            else
                bRecordFound = false;

            return bRecordFound;
        }

        private const string SQL_AUTHORIZED_FOR_DELETE =
            @"SELECT 'x' AS RecordCount 
               FROM PRWebUserList WITH (NOLOCK) 
              WHERE ((prwucl_HQID = {0} AND prwucl_IsPrivate IS NULL) 
                     OR (prwucl_WebUserID={1} AND prwucl_IsPrivate = 'Y')) 
                AND prwucl_Deleted IS NULL 
                AND prwucl_WebUserListID = {2} 
                AND prwucl_TypeCode NOT IN ('AUS', 'CL')";

        /// <summary>
        /// Helper method used to determine if the current user is authorized to delete the
        /// user list.  Private user lists owned by the current user and public user lists 
        /// associated with the current user's enterprise can be deleted.
        /// </summary>
        /// <param name="iListID"></param>
        /// <returns></returns>
        protected bool IsAuthorizedForDelete(int iListID)
        {
            ArrayList oParameters = new ArrayList();

            oParameters.Add(new ObjectParameter("prwucl_HQID", _oUser.prwu_HQID));
            oParameters.Add(new ObjectParameter("prwucl_WebUserID", _oUser.prwu_WebUserID));
            oParameters.Add(new ObjectParameter("prwucl_WebUserListID", iListID));

            string szSQL = GetObjectMgr().FormatSQL(SQL_AUTHORIZED_FOR_DELETE, oParameters);

            IDBAccess oDataAccess = DBAccessFactory.getDBAccessProvider();
            oDataAccess.Logger = _oLogger;

            object oExists = oDataAccess.ExecuteScalar(szSQL, oParameters);

            if ((oExists == null) || (oExists == DBNull.Value))
            {
                return false;
            }

            return true;
        }
        #endregion

        #region Insert Functions
        protected void AddPRWebUserList(string szName, string szDescription, bool bIsPrivate, bool pinned, string icon, IDbTransaction oTran)
        {
            GetObjectMgr().InsertWebUserList(CODE_LIST_TYPE_CUSTOM,
                                             szName,
                                             szDescription,
                                             bIsPrivate,
                                             pinned,
                                             icon,
                                             oTran);
        }


        protected int _iAUSListID = -2;
        private const string SQL_GET_AUSLIST_ID =
                @"SELECT prwucl_WebUserListID 
                   FROM PRWebUserList WITH (NOLOCK) 
                  WHERE prwucl_WebUserID={0} 
                    AND prwucl_TypeCode = 'AUS'";

        /// <summary>
        /// Returns the ID of the AUS List.  If none is found, -1 is returned.
        /// This shouldn't happen, but has in the past, and since the user cannot
        /// do anything about it, there is no point in blowing up for them.
        /// </summary>
        /// <returns></returns>
        protected int GetAUSListID()
        {

            if (_iAUSListID > -2)
            {
                return _iAUSListID;
            }


            ArrayList oParameters = new ArrayList();

            oParameters.Add(new ObjectParameter("prwucl_WebUserID", _oUser.prwu_WebUserID));
            string szSQL = GetObjectMgr().FormatSQL(SQL_GET_AUSLIST_ID, oParameters);


            try
            {
                IDBAccess oDataAccess = DBAccessFactory.getDBAccessProvider();
                oDataAccess.Logger = _oLogger;

                object oID = oDataAccess.ExecuteScalar(szSQL, oParameters);

                if ((oID == null) || (oID == DBNull.Value))
                {
                    // If this is a new user that just purchased a membership, they
                    // have not been configured yet for an AUS list.
                    if (_oUser.prwu_BBID == 0)
                        return -1;

                    throw new ApplicationUnexpectedException("Unable to find AUS List for user: " + _oUser.prwu_WebUserID.ToString());
                }

                _iAUSListID = Convert.ToInt32(oID);
            }
            catch (Exception eX)
            {
                // There's nothing the end user can do about this so
                // just log it and keep moving.
                LogError(eX);

                if (Configuration.ThrowDevExceptions)
                {
                    throw;
                }

                _iAUSListID = -1;
            }

            return _iAUSListID;
        }

        #endregion

        #region Update Functions
        private const string SQL_UPDATE_PRWEBUSERLIST =
            @"UPDATE PRWebUserList SET 
                     prwucl_UpdatedBy={0}, prwucl_UpdatedDate={1}, prwucl_Timestamp={2}, 
                     prwucl_Name={3}, 
                     prwucl_Description={4}, 
                     prwucl_IsPrivate={5},
                     prwucl_Pinned={7}, 
                     prwucl_CategoryIcon={8} 
               WHERE prwucl_WebUserListID = {6}";

        /// <summary>
        /// Updates an existing PRWebUserList record.
        /// </summary>
        /// <param name="iListID"></param>
        /// <param name="szName"></param>
        /// <param name="szDescription"></param>
        /// <param name="bIsPrivate"></param>
        /// <param name="bPinned"></param>
        /// <param name="icon"></param>
        protected void UpdatePRWebUserList(int iListID, string szName, string szDescription, bool bIsPrivate, bool bPinned, string icon)
        {
            ArrayList oParameters = new ArrayList();

            oParameters.Add(new ObjectParameter("prwucl_UpdatedBy", _oUser.prwu_WebUserID));
            oParameters.Add(new ObjectParameter("prwucl_UpdatedDate", DateTime.Now));
            oParameters.Add(new ObjectParameter("prwucl_TimeStamp", DateTime.Now));

            oParameters.Add(new ObjectParameter("prwucl_Name", szName));
            oParameters.Add(new ObjectParameter("prwucl_Description", szDescription));

            if (bIsPrivate)
                oParameters.Add(new ObjectParameter("prwucl_IsPrivate", "Y"));
            else
                oParameters.Add(new ObjectParameter("prwucl_IsPrivate", null));

            oParameters.Add(new ObjectParameter("prwucl_WebUserListID", iListID));


            if (bPinned)
                oParameters.Add(new ObjectParameter("prwucl_Pinned", "Y"));
            else
                oParameters.Add(new ObjectParameter("prwucl_Pinned", null));

            oParameters.Add(new ObjectParameter("prwucl_CategoryIcon", icon));


            string szSQL = GetObjectMgr().FormatSQL(SQL_UPDATE_PRWEBUSERLIST, oParameters);
            GetDBAccess().ExecuteNonQuery(szSQL, oParameters, oTran);
        }

        #endregion

        #region Delete Functions
        private const string SQL_DELETE_PRWEBUSERLISTDETAIL =
            @"DELETE FROM PRWebUserListDetail 
               WHERE prwuld_WebUserListID = {0}
                 AND prwuld_AssociatedID = {1}
                 AND prwuld_AssociatedType = 'C'";

        /// <summary>
        /// Deleted the corresponding PRWebUserListDetail Record.
        /// </summary>
        /// <param name="iListID"></param>
        /// <param name="iAssocCompanyID"></param>
        protected void DeletePRWebUserListDetail(int iListID, int iAssocCompanyID)
        {
            ArrayList oParameters = new ArrayList();

            oParameters.Add(new ObjectParameter("prwuld_WebUserListID", iListID));
            oParameters.Add(new ObjectParameter("prwuld_AssociatedID", iAssocCompanyID));

            string szSQL = GetObjectMgr().FormatSQL(SQL_DELETE_PRWEBUSERLISTDETAIL, oParameters);
            GetDBAccess().ExecuteNonQuery(szSQL, oParameters, oTran);
        }

        private const string SQL_DELETE_PRWEBUSERLIST =
            @"DELETE FROM PRWebUserList 
               WHERE prwucl_WebUserListID = {0} ";

        /// <summary>
        /// Deleted the corresponding PRWebUserList Record.
        /// </summary>
        /// <param name="iListID"></param>
        protected void DeletePRWebUserList(int iListID)
        {
            // Delete the PRWebUserListDetail records for this list
            DeletePRWebUserListDetail(iListID);

            // Delete the PRWebUserList record for this list
            ArrayList oParameters = new ArrayList();

            oParameters.Add(new ObjectParameter("prwucl_WebUserListID", iListID));

            string szSQL = GetObjectMgr().FormatSQL(SQL_DELETE_PRWEBUSERLIST, oParameters);
            GetDBAccess().ExecuteNonQuery(szSQL, oParameters, oTran);
        }

        private const string SQL_DELETE_PRWEBUSERLISTDETAIL_ALL =
            @"DELETE FROM PRWebUserListDetail 
               WHERE prwuld_WebUserListID = {0}";

        /// <summary>
        /// Deleted all the corresponding PRWebUserListDetail records for this list.
        /// </summary>
        /// <param name="iListID"></param>
        protected void DeletePRWebUserListDetail(int iListID)
        {
            ArrayList oParameters = new ArrayList();

            oParameters.Add(new ObjectParameter("prwuld_WebUserListID", iListID));

            string szSQL = GetObjectMgr().FormatSQL(SQL_DELETE_PRWEBUSERLISTDETAIL_ALL, oParameters);
            GetDBAccess().ExecuteNonQuery(szSQL, oParameters, oTran);
        }
        #endregion
    }
}
