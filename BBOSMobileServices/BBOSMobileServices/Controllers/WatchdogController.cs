/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2015-2016

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission ofBlue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: WatchdogController
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web.Http;
using BBOSMobile.ServiceModels.Common;
using BBOSMobile.ServiceModels.Requests;
using BBOSMobile.ServiceModels.Responses;
using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;
using TSI.Utils;


namespace BBSI.BBOSMobileServices.Controllers
{
    public class WatchdogController : ControllerBase
    {

        [Route("api/watchdog/getgroups")]
        [HttpPost]
        [HttpGet]
        public GetWatchdogGroupResponse GetWatchdogGroups(GetWatchdogGroupRequest request)
        {
            GetWatchdogGroupResponse response = new GetWatchdogGroupResponse();

            SetLoggerMethod("GetWatchdogGroups");
            try
            {
                IPRWebUser user = GetUserByGuid(request.UserId);
                if (user == null)
                {
                    return (GetWatchdogGroupResponse)SetInvalidUserResponse(response);
                }

                SetLoggerUser(user);

                response.WatchdogGroups = GetWatchdogLists(user, request.BBID);
                response.ResultCount = response.WatchdogGroups.Count();
                InsertAuditRecord(user, "api/watchdog/getgroups");
                return (GetWatchdogGroupResponse)SetSuccessResponse(response, user);
            }
            catch (Exception e)
            {
                return (GetWatchdogGroupResponse)HandleException(response, e);
            }

        }


        [Route("api/watchdog/getgroup")]
        [HttpPost]
        [HttpGet]
        public GetWatchdogGroupDetailsResponse GetWatchdogGroup(GetWatchdogGroupCompaniesRequest request)
        {
            GetWatchdogGroupDetailsResponse response = new GetWatchdogGroupDetailsResponse();

            SetLoggerMethod("GetWatchdogGroups");
            try
            {
                IPRWebUser user = GetUserByGuid(request.UserId);
                if (user == null)
                {
                    return (GetWatchdogGroupDetailsResponse)SetInvalidUserResponse(response);
                }

                SetLoggerUser(user);
                response.WatchdogGroup = GetWatchdogList(user, request.WatchdogGroupId);
                InsertAuditRecord(user, "api/watchdog/getgroup");
                return (GetWatchdogGroupDetailsResponse)SetSuccessResponse(response, user);
            }
            catch (Exception e)
            {
                return (GetWatchdogGroupDetailsResponse)HandleException(response, e);
            }

        }


        [Route("api/watchdog/savecompany")]
        [HttpPost]
        [HttpGet]
        public ResponseBase SaveCompany(SaveCompanyToWatchdogGroupRequest request)
        {
            GetLogger("SaveCompany").LogMessage("Hello");

            ResponseBase response = new ResponseBase();

            SetLoggerMethod("SaveCompany");
            try
            {
                IPRWebUser user = GetUserByGuid(request.UserId);
                if (user == null)
                {
                    return SetInvalidUserResponse(response);
                }

                SetLoggerUser(user);

                int BBID = Convert.ToInt32(request.BBID);
                HashSet<Int32> currentWatchdogIDs = GetWatchdogListsWithCompany(user, BBID);

                foreach (int listID in request.WatchdogGroupIds)
                {
                    // Check if a PRWebUserListDetail record already exists
                    //if (!IsCompanyInList(listID, BBID))
                    if (!currentWatchdogIDs.Contains(listID))
                    {
                        // Insert new PRWebUserListDetail record for this company and list
                        GetObjectMgr(user).AddPRWebUserListDetail(listID, BBID, GetAUSListID(user), null);
                    }
                }

                // Delete from any lists that weren't sent from the client.
                
                foreach (int listID in currentWatchdogIDs)
                {
                    if (!request.WatchdogGroupIds.Contains(listID))
                    {
                        GetObjectMgr(user).DeletePRWebUserListDetail(listID, BBID, null);
                    }
                }



                InsertAuditRecord(user, "api/watchdog/savecompany");
                return SetSuccessResponse(response, user);
            }
            catch (Exception e)
            {
                return HandleException(response, e);
            }

        }

        [Route("api/watchdog/addcompany")]
        [HttpPost]
        [HttpGet]
        public ResponseBase AddCompany(WatchdogUpdateRequest request)
        {
            ResponseBase response = new ResponseBase();

            SetLoggerMethod("AddCompany");
            try
            {
                IPRWebUser user = GetUserByGuid(request.UserId);
                if (user == null)
                {
                    return SetInvalidUserResponse(response);
                }

                SetLoggerUser(user);

                int BBID = Convert.ToInt32(request.BBID);

                // Check if a PRWebUserListDetail record already exists
                if (!IsCompanyInList(request.WatchdogID, request.BBID))
                {
                    GetObjectMgr(user).AddPRWebUserListDetail(request.WatchdogID, request.BBID, GetAUSListID(user), null);
                }

                InsertAuditRecord(user, "api/watchdog/addcompany");
                return SetSuccessResponse(response, user);
            }
            catch (Exception e)
            {
                return HandleException(response, e);
            }
        }

        [Route("api/watchdog/removecompany")]
        [HttpPost]
        [HttpGet]
        public ResponseBase RemoveCompany(WatchdogUpdateRequest request)
        {
            GetLogger("RemoveCompany").LogMessage("Hello World");
            ResponseBase response = new ResponseBase();

            SetLoggerMethod("RemoveCompany");

            try
            {
                IPRWebUser user = GetUserByGuid(request.UserId);
                if (user == null)
                {
                    return SetInvalidUserResponse(response);
                }

                SetLoggerUser(user);

                int BBID = Convert.ToInt32(request.BBID);

                // Check if a PRWebUserListDetail record already exists
                if (IsCompanyInList(request.WatchdogID, request.BBID))
                {
                    GetLogger().LogMessage("Found Company");
                    GetObjectMgr(user).DeletePRWebUserListDetail(request.WatchdogID, request.BBID, null);
                    GetLogger().LogMessage("Removed Company");
                }

                GetLogger().LogMessage("Setting Success Response");

                InsertAuditRecord(user, "api/watchdog/removecompany");
                return SetSuccessResponse(response, user);
            }
            catch (Exception e)
            {
                GetLogger().LogMessage("Handling Exception");
                return HandleException(response, e);
            }
        }

        #region DataAccess
        private const string SQL_GET_USER_LISTS_ALL =
                  @"SELECT prwucl_WebUserListID, 
                     prwucl_Name, 
                     prwucl_IsPrivate, 
                     prwucl_Pinned, 
                     prwucl_CategoryIcon,
                     prwucl_TypeCode,
                     MAX(prwucl_UpdatedDate) AS UpdatedDate, 
                     COUNT(prwuld_WebUserListDetailID) As CompanyCount 
                FROM PRWebUserList WITH (NOLOCK) 
                     LEFT OUTER JOIN PRWebUserListDetail WITH (NOLOCK) ON prwucl_WebUserListID = prwuld_WebUserListID AND prwuld_Deleted IS NULL 
                     LEFT OUTER JOIN Company WITH (NOLOCK) ON prwuld_AssociatedID = comp_CompanyID
                                                          AND comp_PRListingStatus IN ('L', 'H', 'N3', 'N5', 'LUV') 
               WHERE ((prwucl_HQID = @HQID AND prwucl_IsPrivate IS NULL) 
                      OR (prwucl_WebUserID=@WebUserID AND prwucl_IsPrivate = 'Y'))
                AND prwucl_Deleted IS NULL";

        private const string SQL_EXCLUDE_CUSTOM_LISTS = " AND prwucl_TypeCode <> 'CU'";
        private const string SQL_GROUP_BY = " GROUP BY prwucl_WebUserListID, prwucl_Name, prwucl_IsPrivate, prwucl_Pinned, prwucl_CategoryIcon, prwucl_TypeCode";

        protected List<WatchdogGroup> GetWatchdogLists(IPRWebUser user, int BBID)
        {

            HashSet<Int32> currentWatchdogIDs = null;

            if (BBID > 0)
            {
                currentWatchdogIDs = GetWatchdogListsWithCompany(user, BBID);
            }


            ArrayList parameters = new ArrayList();
            parameters.Add(new ObjectParameter("HQID", user.prwu_HQID));
            parameters.Add(new ObjectParameter("WebUserID", user.prwu_WebUserID));

            string sql = SQL_GET_USER_LISTS_ALL;

            // Intermediate access is required to view custom user lists
            if (!user.HasAccess(PRWebUser.SECURITY_LEVEL_STANDARD))
                sql += SQL_EXCLUDE_CUSTOM_LISTS;

            sql += SQL_GROUP_BY;
            sql += " ORDER BY prwucl_Name";

            List<WatchdogGroup> watchdogGroups = new List<WatchdogGroup>();

            using (IDataReader reader = GetDBAccess().ExecuteReader(sql, parameters, CommandBehavior.CloseConnection, null))
            {
                while (reader.Read())
                {
                    WatchdogGroup watchdog = new WatchdogGroup();
                    watchdog.WatchdogGroupId = GetDBAccess().GetInt32(reader, "prwucl_WebUserListID");
                    watchdog.Name = GetDBAccess().GetString(reader, "prwucl_Name");
                    watchdog.IsPrivate = GetBool(GetDBAccess().GetString(reader, "prwucl_IsPrivate"));
                    watchdog.TypeCode = GetDBAccess().GetString(reader, "prwucl_TypeCode");
                    watchdog.Count = GetDBAccess().GetInt32(reader, "CompanyCount");

                    if (BBID > 0)
                    {
                        if (currentWatchdogIDs.Contains(watchdog.WatchdogGroupId))
                        {
                            watchdog.InGroup = true;
                        }
                    }
                    
                    watchdogGroups.Add(watchdog);
                }
            }

            return watchdogGroups;
        }


        private const string SQL_GET_USER_LISTS_WITH_COMPANY =
            @"SELECT prwucl_WebUserListID
                  FROM PRWebUserList WITH (NOLOCK)
                       INNER JOIN PRWebUserListDetail WITH (NOLOCK) ON prwucl_WebUserListID = prwuld_WebUserListID
                WHERE ((prwucl_HQID = @HQID AND prwucl_IsPrivate IS NULL) 
                        OR (prwucl_WebUserID=@WebUserID AND prwucl_IsPrivate = 'Y'))
                  AND prwuld_AssociatedID = @CompanyID
                  AND prwuld_AssociatedType = 'C'";

        protected HashSet<Int32> GetWatchdogListsWithCompany(IPRWebUser user, int companyID)
        {
            ArrayList parameters = new ArrayList();
            parameters.Add(new ObjectParameter("HQID", user.prwu_HQID));
            parameters.Add(new ObjectParameter("WebUserID", user.prwu_WebUserID));
            parameters.Add(new ObjectParameter("CompanyID", companyID));

            string sql = SQL_GET_USER_LISTS_WITH_COMPANY;

            HashSet<Int32> watchdogGroups = new HashSet<Int32>();
            

            using (IDataReader reader = GetDBAccess().ExecuteReader(sql, parameters, CommandBehavior.CloseConnection, null))
            {
                while (reader.Read())
                {
                    watchdogGroups.Add(GetDBAccess().GetInt32(reader, "prwucl_WebUserListID"));
                }
            }

            return watchdogGroups;
        }



        protected const string SQL_GET_WEB_USER_LIST_DATA =
            @"SELECT prwucl_WebUserListID,
                     prwucl_Name, prwucl_Description, 
                     prwucl_IsPrivate, prwucl_TypeCode, prwucl_WebUserID, 
                     dbo.ufn_FormatPerson(Pers_FirstName, Pers_LastName, Pers_MiddleName, pers_PRNickname1, Pers_Suffix) AS CreatedBy, 
                     dbo.ufn_GetWebUserLocation(prwucl_CreatedBy) AS CreatedByLocation, prwucl_Pinned, prwucl_CategoryIcon
                FROM PRWebUserList WITH (NOLOCK)
                     LEFT OUTER JOIN PRWebUser WITH (NOLOCK) ON prwucl_WebUserID = prwu_WebUserID 
                     LEFT OUTER JOIN Person_Link WITH (NOLOCK) ON prwu_PersonLinkID = PeLi_PersonLinkId  
                     LEFT OUTER JOIN Person WITH (NOLOCK) ON Person_Link.PeLi_PersonId = Pers_PersonId 
               WHERE prwucl_WebUserListID = @ListID
                 AND  ((prwucl_HQID = @HQID AND prwucl_IsPrivate IS NULL) 
                      OR (prwucl_WebUserID=@WebUserID AND prwucl_IsPrivate = 'Y'))";

        protected const string SQL_GET_WEB_USER_LIST_COMPANIES =
            @"FROM vPRBBOSCompanyList
                   INNER JOIN PRWebUserListDetail WITH (NOLOCK) ON comp_CompanyID = prwuld_AssociatedID
                   LEFT OUTER JOIN vPRCurrentRating compRating ON comp_CompanyID = compRating.prra_CompanyID 
			       LEFT OUTER JOIN vPRCurrentRating hqRating ON comp_PRHQID = hqRating.prra_CompanyID 
             WHERE prwuld_WebUserListID=@ListID
               AND {0}";

        protected WatchdogGroup GetWatchdogList(IPRWebUser user, int watchdogListID)
        {

            ArrayList parameters = new ArrayList();
            parameters.Add(new ObjectParameter("ListID", watchdogListID));
            parameters.Add(new ObjectParameter("HQID", user.prwu_HQID));
            parameters.Add(new ObjectParameter("WebUserID", user.prwu_WebUserID));

            WatchdogGroup watchdog = new WatchdogGroup();
            using (IDataReader reader = GetDBAccess().ExecuteReader(SQL_GET_WEB_USER_LIST_DATA, 
                                                                    parameters, 
                                                                    CommandBehavior.CloseConnection, null))
            {
                while (reader.Read())
                {
                    watchdog.WatchdogGroupId = GetDBAccess().GetInt32(reader, "prwucl_WebUserListID");
                    watchdog.Name = GetDBAccess().GetString(reader, "prwucl_Name");
                    watchdog.IsPrivate = GetBool(GetDBAccess().GetString(reader, "prwucl_IsPrivate"));
                    watchdog.Description = GetDBAccess().GetString(reader, "prwucl_Description");
                    watchdog.CreatedBy = GetDBAccess().GetString(reader, "CreatedBy");
                    watchdog.TypeCode = GetDBAccess().GetString(reader, "prwucl_TypeCode");
                }
            }

            // Reuse the same parameters.
            string sql = string.Format(SQL_COMPANY_BASE_SELECT + SQL_GET_WEB_USER_LIST_COMPANIES + " ORDER BY comp_PRBookTradestyle", GetObjectMgr(user).GetLocalSourceCondition());

            watchdog.Companies = PopulateCompanyBase(sql, parameters);
            watchdog.Count = watchdog.Companies.Count();

            return watchdog;
        }


        protected const string SQL_GET_USER_LIST_COMPANY_IDS =
            @"SELECT prwuld_AssociatedID 
                FROM PRWebUserListDetail WITH (NOLOCK) 
               WHERE prwuld_WebUserListID = @ListID 
                 AND prwuld_AssociatedID = @CompanyID
                 AND prwuld_AssociatedType = 'C' 
                 AND prwuld_Deleted IS NULL";

        protected bool IsCompanyInList(int iListID, int companyID)
        {
            ArrayList parameters = new ArrayList();
            parameters.Add(new ObjectParameter("ListID", iListID));
            parameters.Add(new ObjectParameter("CompanyID", companyID));

            object result = GetDBAccess().ExecuteScalar(SQL_GET_USER_LIST_COMPANY_IDS, parameters);
            if ((result == null) ||
                (result == DBNull.Value))
            {
                return false;
            }

            return true;
        }


        protected int _iAUSListID = -2;
        private const string SQL_GET_AUSLIST_ID =
                @"SELECT prwucl_WebUserListID 
                   FROM PRWebUserList WITH (NOLOCK) 
                  WHERE prwucl_WebUserID=@UserID 
                    AND prwucl_TypeCode = 'AUS'";

        /// <summary>
        /// Returns the ID of the AUS List.  If none is found, -1 is returned.
        /// This shouldn't happen, but has in the past, and since the user cannot
        /// do anything about it, there is no point in blowing up for them.
        /// </summary>
        /// <returns></returns>
        protected int GetAUSListID(IPRWebUser user)
        {

            if (_iAUSListID > -2)
            {
                return _iAUSListID;
            }

            try {
                ArrayList parameters = new ArrayList();
                parameters.Add(new ObjectParameter("UserID", user.prwu_WebUserID));

                object oID = GetDBAccess().ExecuteScalar(SQL_GET_AUSLIST_ID, parameters);
                if ((oID == null) || 
                    (oID == DBNull.Value))
                {
                    _iAUSListID = - 1;
                }
                else
                {
                    _iAUSListID = Convert.ToInt32(oID);
                }

            }
            catch (Exception eX)
            {
                // There's nothing the end user can do about this so
                // just log it and keep moving.
                GetLogger().LogError(eX);

                if (Utilities.GetBoolConfigValue("ThrowDevExceptions", false))
                {
                    throw;
                }

                _iAUSListID = -1;
            }

            return _iAUSListID;
        }

        #endregion
    }
}
