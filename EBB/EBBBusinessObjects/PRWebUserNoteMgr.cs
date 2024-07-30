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

 ClassName: PRWebUserNote
 Description:	

 Notes:	Created By TSI Class Generator on 8/20/2014 8:41:03 AM

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
    /// Data Manager for the PRWebUserNote class.
    /// </summary>
    public partial class PRWebUserNoteMgr : EBBObjectMgr
    {
        public const string COL_PRWUN_IS_PRIVATE		= "prwun_IsPrivate";
        public const string COL_PRWUN_KEY				= "prwun_Key";
        public const string COL_PRWUN_CREATED_DATE		= "prwun_CreatedDate";
        public const string COL_PRWUN_DATE				= "prwun_Date";
        public const string COL_PRWUN_DATE_UTC			= "prwun_DateUTC";
        public const string COL_PRWUN_TIME_STAMP		= "prwun_TimeStamp";
        public const string COL_PRWUN_UPDATED_DATE		= "prwun_UpdatedDate";
        public const string COL_PRWUN_ASSOCIATED_ID		= "prwun_AssociatedID";
        public const string COL_PRWUN_COMPANY_ID		= "prwun_CompanyID";
        public const string COL_PRWUN_CREATED_BY		= "prwun_CreatedBy";
        public const string COL_PRWUN_DELETED			= "prwun_Deleted";
        public const string COL_PRWUN_HQID				= "prwun_HQID";
        public const string COL_PRWUN_SECTERR			= "prwun_Secterr";
        public const string COL_PRWUN_UPDATED_BY		= "prwun_UpdatedBy";
        public const string COL_PRWUN_WEB_USER_ID		= "prwun_WebUserID";
        public const string COL_PRWUN_WEB_USER_NOTE_ID	= "prwun_WebUserNoteID";
        public const string COL_PRWUN_WORKFLOW_ID		= "prwun_WorkflowId";
        public const string COL_PRWUN_AMPM				= "prwun_AMPM";
        public const string COL_PRWUN_ASSOCIATED_TYPE	= "prwun_AssociatedType";
        public const string COL_PRWUN_HOUR				= "prwun_Hour";
        public const string COL_PRWUN_MINUTE			= "prwun_Minute";
        public const string COL_PRWUN_NOTE				= "prwun_Note";
        public const string COL_PRWUN_SUBJECT			= "prwun_Subject";
        public const string COL_PRWUN_TIMEZONE			= "prwun_Timezone";
        public const string COL_PRWUN_NOTE_UPDATE_DATE_TIME      = "prwun_NoteUpdatedDateTime";
        public const string COL_PRWUN_NOTE_UPDATE_BY = "prwun_NoteUpdatedBy";
        

        #region TSI Framework Generated Code
        /// <summary>
        /// Constructor to initalize data manager
        /// </summary>
        /// <returns></returns>
        public PRWebUserNoteMgr(){}

        /// <summary>
        /// Constructor to initalize data manager
        /// </summary>
        /// <param name="oLogger">Logger</param>
        /// <param name="oUser">Current User</param>
        public PRWebUserNoteMgr(ILogger oLogger,
                                IUser oUser): base(oLogger, oUser){}

        /// <summary>
        /// Constructor to initalize data manager
        /// </summary>
        /// <param name="oConn">DB Connection</param>
        /// <param name="oLogger">Logger</param>
        /// <param name="oUser">Current User</param>
        public PRWebUserNoteMgr(IDbConnection oConn,
                                ILogger oLogger,
                                IUser oUser): base(oConn, oLogger, oUser){}

        /// <summary>
        /// Constructor using the Logger, User, and Transaction
        /// of the specified Manager to initialize this manager.
        /// </summary>
        /// <param name="oBizObjMgr">Business Object Manager</param>
        public PRWebUserNoteMgr(BusinessObjectMgr oBizObjMgr): base(oBizObjMgr){}

        /// <summary>
        /// Creates an instance of the PRWebUserNote business object
        /// </summary>
        /// <returns>IBusinessObject</returns>
        override protected IBusinessObject InstantiateBusinessObject(IDictionary oData) {
            return new PRWebUserNote();
        }

        /// <summary>
        /// The name of the table our business object
        /// is mapped to.
        /// </summary>
        /// <returns>Table Name</returns>
        override public string GetTableName() {
            return "PRWebUserNote";
        }

        /// <summary>
        /// The name of the business object class.
        /// </summary>
        /// <returns>Business Object Name</returns>
        override public string GetBusinessObjectName() {
            return "PRCo.EBB.BusinessObjects.PRWebUserNote";
        }

        /// <summary>
        /// The fields that uniquly identify this object.
        /// </summary>
        /// <returns>IList</returns>
        override public IList GetKeyFields() {
            return new String[] {COL_PRWUN_WEB_USER_NOTE_ID};
        }
        #endregion

    }
}
