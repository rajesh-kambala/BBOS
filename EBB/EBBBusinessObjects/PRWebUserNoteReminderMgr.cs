/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2014-2020

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
using System.Data;
using TSI.Arch;
using TSI.BusinessObjects;
using TSI.Utils;
using TSI.Security;
using TSI.DataAccess;

namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Data Manager for the PRWebUserNoteReminder class.
    /// </summary>
    public partial class PRWebUserNoteReminderMgr : EBBObjectMgr
    {
        public const string COL_PRWUNR_CREATED_DATE					= "prwunr_CreatedDate";
        public const string COL_PRWUNR_DATE							= "prwunr_Date";
        public const string COL_PRWUNR_DATE_UTC						= "prwunr_DateUTC";
        public const string COL_PRWUNR_SENT_DATE_TIME				= "prwunr_SentDateTime";
        public const string COL_PRWUNR_SENT_DATE_TIME_UTC			= "prwunr_SentDateTimeUTC";
        public const string COL_PRWUNR_TIME_STAMP					= "prwunr_TimeStamp";
        public const string COL_PRWUNR_UPDATED_DATE					= "prwunr_UpdatedDate";
        public const string COL_PRWUNR_CREATED_BY					= "prwunr_CreatedBy";
        public const string COL_PRWUNR_DELETED						= "prwunr_Deleted";
        public const string COL_PRWUNR_SECTERR						= "prwunr_Secterr";
        public const string COL_PRWUNR_UPDATED_BY					= "prwunr_UpdatedBy";
        public const string COL_PRWUNR_WEB_USER_ID					= "prwunr_WebUserID";
        public const string COL_PRWUNR_WEB_USER_NOTE_ID				= "prwunr_WebUserNoteID";
        public const string COL_PRWUNR_WEB_USER_NOTE_REMINDER_ID	= "prwunr_WebUserNoteReminderID";
        public const string COL_PRWUNR_WORKFLOW_ID					= "prwunr_WorkflowId";
        public const string COL_PRWUNR_AMPM							= "prwunr_AMPM";
        public const string COL_PRWUNR_EMAIL						= "prwunr_Email";
        public const string COL_PRWUNR_HOUR							= "prwunr_Hour";
        public const string COL_PRWUNR_MINUTE						= "prwunr_Minute";
        public const string COL_PRWUNR_PHONE						= "prwunr_Phone";
        public const string COL_PRWUNR_THRESHOLD					= "prwunr_Threshold";
        public const string COL_PRWUNR_TIMEZONE						= "prwunr_Timezone";
        public const string COL_PRWUNR_TYPE							= "prwunr_Type";

        #region TSI Framework Generated Code
        /// <summary>
        /// Constructor to initalize data manager
        /// </summary>
        /// <returns></returns>
        public PRWebUserNoteReminderMgr(){}

        /// <summary>
        /// Constructor to initalize data manager
        /// </summary>
        /// <param name="oLogger">Logger</param>
        /// <param name="oUser">Current User</param>
        public PRWebUserNoteReminderMgr(ILogger oLogger,
                                IUser oUser): base(oLogger, oUser){}

        /// <summary>
        /// Constructor to initalize data manager
        /// </summary>
        /// <param name="oConn">DB Connection</param>
        /// <param name="oLogger">Logger</param>
        /// <param name="oUser">Current User</param>
        public PRWebUserNoteReminderMgr(IDbConnection oConn,
                                ILogger oLogger,
                                IUser oUser): base(oConn, oLogger, oUser){}

        /// <summary>
        /// Constructor using the Logger, User, and Transaction
        /// of the specified Manager to initialize this manager.
        /// </summary>
        /// <param name="oBizObjMgr">Business Object Manager</param>
        public PRWebUserNoteReminderMgr(BusinessObjectMgr oBizObjMgr): base(oBizObjMgr){}

        /// <summary>
        /// Creates an instance of the PRWebUserNoteReminder business object
        /// </summary>
        /// <returns>IBusinessObject</returns>
        override protected IBusinessObject InstantiateBusinessObject(IDictionary oData) {
            return new PRWebUserNoteReminder();
        }

        /// <summary>
        /// The name of the table our business object
        /// is mapped to.
        /// </summary>
        /// <returns>Table Name</returns>
        override public string GetTableName() {
            return "PRWebUserNoteReminder";
        }

        /// <summary>
        /// The name of the business object class.
        /// </summary>
        /// <returns>Business Object Name</returns>
        override public string GetBusinessObjectName() {
            return "PRCo.EBB.BusinessObjects.PRWebUserNoteReminder";
        }

        /// <summary>
        /// The fields that uniquly identify this object.
        /// </summary>
        /// <returns>IList</returns>
        override public IList GetKeyFields() {
            return new String[] {COL_PRWUNR_WEB_USER_NOTE_REMINDER_ID};
        }
        #endregion

    }
}
