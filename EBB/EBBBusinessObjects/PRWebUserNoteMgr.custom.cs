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

 ClassName: PRWebUserNote
 Description:	

 Notes:	Created By TSI Class Generator on 8/20/2014 7:40:16 AM

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using TSI.BusinessObjects;

namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Data Manager for the PRWebUserNote class.
    /// </summary>
    public partial class PRWebUserNoteMgr : EBBObjectMgr
    {
        /// <summary>
        /// Override the standard TSI audit column names with the
        /// Sage CRM names.
        /// </summary>
        new public const string COL_CREATED_USER_ID = "prwun_CreatedBy";
        new public const string COL_UPDATED_USER_ID = "prwun_UpdatedBy";
        new public const string COL_CREATED_DATETIME = "prwun_CreatedDate";
        new public const string COL_UPDATED_DATETIME = "prwun_UpdatedDate";

        public override bool UsesIdentity
        {
            get
            {
                return true;
            }
            set
            {
                base.UsesIdentity = value;
            }
        }

        public override bool UsesOptLock
        {
            get
            {
                return false;
            }
            set
            {
                base.UsesOptLock = value;
            }
        }

        public IPRWebUserNote GetKeyNote(int hqID, int subjectCompanyID)
        {
            IList parmList = GetParmList("prwun_HQID", hqID);
            parmList.Add(new ObjectParameter("prwun_AssociatedID", subjectCompanyID));
            parmList.Add(new ObjectParameter("prwun_AssociatedType", "C"));
            parmList.Add(new ObjectParameter("prwun_Key", "Y"));

            IBusinessObjectSet results = GetObjectsByCustomSQL(FormatSQL("SELECT * FROM vPRWebUserNote WHERE prwun_HQID={0} AND prwun_AssociatedID={1} AND prwun_AssociatedType={2} AND prwun_Key={3}", parmList), parmList);
            if (results.Count == 0)
            {
                return null;
            }

            return (IPRWebUserNote)results[0];
        }

        public bool HasKeyNote(int hqID, int subjectCompanyID)
        {
            IList parmList = GetParmList("prwun_HQID", hqID);
            parmList.Add(new ObjectParameter("prwun_AssociatedID", subjectCompanyID));
            parmList.Add(new ObjectParameter("prwun_AssociatedType", "C"));
            parmList.Add(new ObjectParameter("prwun_Key", "Y"));

            return IsObjectExist(FormatSQL("prwun_HQID={0} AND prwun_AssociatedID={1} AND prwun_AssociatedType={2} AND prwun_Key={3}", parmList), parmList);
        }


        private const string SQL_BY_COMPANY =
            @"SELECT vPRWebUserNote.*,
                     dbo.ufn_GetNoteReminderList(prwun_WebUserNoteID, {1}, '<br/>') as ReminderTypes,
                     dbo.ufn_GetCustomCaptionValue('prwun_AssociatedType', prwun_AssociatedType, 'en-us') AS NoteType
                FROM vPRWebUserNote 
               WHERE ((prwun_HQID = {0}  AND prwun_IsPrivate IS NULL) OR (prwun_WebUserID={1} AND prwun_IsPrivate = 'Y')) ";

        public IBusinessObjectSet Search(NoteSearchCriteria searchCriteria)
        {
            IList parmList = new ArrayList();
            string whereClause = searchCriteria.GetSearchWhere(parmList);

            // Sort Field
            if (!String.IsNullOrEmpty(searchCriteria.SortField))
            {
                whereClause += " ORDER BY ";
                whereClause += searchCriteria.SortField;

                // Sort ASC
                if (!searchCriteria.SortAsc)
                    whereClause += " DESC ";
                    
            }

            string sql = FormatSQL(SQL_BY_COMPANY + whereClause, parmList);
            return GetObjectsByCustomSQL(sql, parmList);
        }

        private const string SQL_SEARCH_COUNT =
            @"SELECT COUNT(1) as Cnt
                FROM vPRWebUserNote 
               WHERE ((prwun_HQID = {0}  AND prwun_IsPrivate IS NULL) OR (prwun_WebUserID={1} AND prwun_IsPrivate = 'Y')) ";


        public int SearchCount(NoteSearchCriteria searchCriteria)
        {
            IList parmList = new ArrayList();
            string whereClause = searchCriteria.GetSearchWhere(parmList);
            string sql = FormatSQL(SQL_BY_COMPANY + whereClause, parmList);
            object result = GetDBAccess().ExecuteScalar(sql, parmList);

            if (result == null)
            {
                return 0;
            }

            return (int)result;
        }



        private const string SQL_REMINDERS =
            @"SELECT vPRWebUserNote.*,
                     dbo.ufn_GetNoteReminderList(prwun_WebUserNoteID, {0}, '<br/>') as ReminderTypes,
                     dbo.ufn_GetCustomCaptionValue('prwun_AssociatedType', prwun_AssociatedType, 'en-us') AS NoteType
                FROM vPRWebUserNote 
                     INNER JOIN PRWebUserNoteReminder WITH (NOLOCK) ON prwunr_WebUserNoteID = prwun_WebUserNoteID
               WHERE prwunr_SentDateTime IS NULL
                 AND prwunr_DateUTC <= GETUTCDATE()                  
                 AND prwunr_WebUserID = {0}                 
                 AND prwunr_Type = {1}
            ORDER BY prwunr_DateUTC";

        private const string SQL_REMINDERS_COUNT =
            @"SELECT COUNT(1)
                FROM PRWebUserNote  WITH (NOLOCK)
                     INNER JOIN PRWebUserNoteReminder WITH (NOLOCK) ON prwunr_WebUserNoteID = prwun_WebUserNoteID
               WHERE prwunr_SentDateTime IS NULL
                 AND prwun_DateUTC <= GETUTCDATE()                  
                 AND prwunr_WebUserID = {0}                 
                 AND prwunr_Type = {1}";

        public IBusinessObjectSet GetPendingNotifications(int webUserID, string notificationType)
        {
            IList parmList = GetParmList("webUserID", webUserID);
            parmList.Add(new ObjectParameter("prwunr_Type", notificationType));

            return GetObjectsByCustomSQL(FormatSQL(SQL_REMINDERS, parmList), parmList);
        }

        public int GetPendingNotificationsCount(int webUserID, string notificationType)
        {
            IList parmList = GetParmList("webUserID", webUserID);
            parmList.Add(new ObjectParameter("prwunr_Type", notificationType));

            return (int)GetObjectCountByCustomSQL(FormatSQL(SQL_REMINDERS_COUNT, parmList), parmList);
        }

        /*
         *  Used to generate auto-reminders
         */
        private const string SQL_REMINDERS_2 =
            @"SELECT vPRWebUserNote.*
                FROM vPRWebUserNote 
                     INNER JOIN PRWebUserNoteReminder WITH (NOLOCK) ON prwunr_WebUserNoteID = prwun_WebUserNoteID
               WHERE prwunr_SentDateTime IS NULL
                 AND prwunr_DateUTC <= GETUTCDATE()                  
                 AND prwunr_Type = {0}
            ORDER BY prwun_DateUTC";

        public IBusinessObjectSet GetPendingNotifications(string notificationType)
        {
            IList parmList = GetParmList("prwunr_Type", notificationType);
            return GetObjectsByCustomSQL(FormatSQL(SQL_REMINDERS_2, parmList), parmList);
        }


        private const string SQL_BY_ID_LIST =
             @"SELECT vPRWebUserNote.*
                 FROM vPRWebUserNote 
                WHERE prwun_WebUserNoteID IN ({0})
             ORDER BY prwun_DateUTC";

        public IBusinessObjectSet GetByNoteIDList(string noteIDList)
        {
            return GetObjectsByCustomSQL(string.Format(SQL_BY_ID_LIST, noteIDList));
        }

        public int GetPinnedFieldCount(int hqID, int subjectCompanyID)
        {
            IList parmList = GetParmList("HQID", hqID);
            parmList.Add(new ObjectParameter("prwun_AssociatedID", subjectCompanyID));
            parmList.Add(new ObjectParameter("prwun_AssociatedType", "C"));

            object result = GetDBAccess().ExecuteScalar(FormatSQL("SELECT COUNT(1) FROM PRWebUserNote WTIH (NOLOCK) WHERE prwun_HQID = {0} AND prwun_AssociatedID = {1} AND prwun_AssociatedType = {2} AND prwun_Key='Y'", parmList), parmList);

            if (result == null) {
                return 0;
            }

            return (int)result;
        }

        public void RemoveKeyNote(int hqID, int subjectCompanyID, int currentKeyNoteID)
        {
            IList parmList = GetParmList("prwun_HQID", hqID);
            parmList.Add(new ObjectParameter("prwun_AssociatedID", subjectCompanyID));
            parmList.Add(new ObjectParameter("prwun_AssociatedType", "C"));
            parmList.Add(new ObjectParameter("prwun_Key", "Y"));
            parmList.Add(new ObjectParameter("NoteID", currentKeyNoteID));

            GetDBAccess().ExecuteNonQuery(FormatSQL("UPDATE PRWebUserNote SET prwun_Key = NULL WHERE prwun_HQID={0} AND prwun_AssociatedID={1} AND prwun_AssociatedType={2} AND prwun_Key={3} AND prwun_WebUserNoteID <>{4}", parmList), parmList);
        }
    }
}
