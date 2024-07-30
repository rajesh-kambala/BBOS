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

 ClassName: PRWebUserCustomFieldLookup
 Description:	

 Notes:	Created By TSI Class Generator on 7/18/2014 2:10:14 PM

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
    /// Data Manager for the PRWebUserCustomFieldLookup class.
    /// </summary>
    public partial class PRWebUserCustomFieldLookupMgr : EBBObjectMgr
    {
        public const string COL_PRWUCFL_CREATED_DATE					= "prwucfl_CreatedDate";
        public const string COL_PRWUCFL_TIME_STAMP						= "prwucfl_TimeStamp";
        public const string COL_PRWUCFL_UPDATED_DATE					= "prwucfl_UpdatedDate";
        public const string COL_PRWUCFL_CREATED_BY						= "prwucfl_CreatedBy";
        public const string COL_PRWUCFL_DELETED							= "prwucfl_Deleted";
        public const string COL_PRWUCFL_SECTERR							= "prwucfl_Secterr";
        public const string COL_PRWUCFL_SEQUENCE						= "prwucfl_Sequence";
        public const string COL_PRWUCFL_UPDATED_BY						= "prwucfl_UpdatedBy";
        public const string COL_PRWUCFL_WEB_USER_CUSTOM_FIELD_ID		= "prwucfl_WebUserCustomFieldID";
        public const string COL_PRWUCFL_WEB_USER_CUSTOM_FIELD_LOOKUP_ID	= "prwucfl_WebUserCustomFieldLookupID";
        public const string COL_PRWUCFL_WORKFLOW_ID						= "prwucfl_WorkflowId";
        public const string COL_PRWUCFL_LOOKUP_VALUE					= "prwucfl_LookupValue";

        #region TSI Framework Generated Code
        /// <summary>
        /// Constructor to initalize data manager
        /// </summary>
        /// <returns></returns>
        public PRWebUserCustomFieldLookupMgr(){}

        /// <summary>
        /// Constructor to initalize data manager
        /// </summary>
        /// <param name="oLogger">Logger</param>
        /// <param name="oUser">Current User</param>
        public PRWebUserCustomFieldLookupMgr(ILogger oLogger,
                                IUser oUser): base(oLogger, oUser){}

        /// <summary>
        /// Constructor to initalize data manager
        /// </summary>
        /// <param name="oConn">DB Connection</param>
        /// <param name="oLogger">Logger</param>
        /// <param name="oUser">Current User</param>
        public PRWebUserCustomFieldLookupMgr(IDbConnection oConn,
                                ILogger oLogger,
                                IUser oUser): base(oConn, oLogger, oUser){}

        /// <summary>
        /// Constructor using the Logger, User, and Transaction
        /// of the specified Manager to initialize this manager.
        /// </summary>
        /// <param name="oBizObjMgr">Business Object Manager</param>
        public PRWebUserCustomFieldLookupMgr(BusinessObjectMgr oBizObjMgr): base(oBizObjMgr){}

        /// <summary>
        /// Creates an instance of the PRWebUserCustomFieldLookup business object
        /// </summary>
        /// <returns>IBusinessObject</returns>
        override protected IBusinessObject InstantiateBusinessObject(IDictionary oData) {
            return new PRWebUserCustomFieldLookup();
        }

        /// <summary>
        /// The name of the table our business object
        /// is mapped to.
        /// </summary>
        /// <returns>Table Name</returns>
        override public string GetTableName() {
            return "PRWebUserCustomFieldLookup";
        }

        /// <summary>
        /// The name of the business object class.
        /// </summary>
        /// <returns>Business Object Name</returns>
        override public string GetBusinessObjectName() {
            return "PRCo.EBB.BusinessObjects.PRWebUserCustomFieldLookup";
        }

        /// <summary>
        /// The fields that uniquly identify this object.
        /// </summary>
        /// <returns>IList</returns>
        override public IList GetKeyFields() {
            return new String[] {COL_PRWUCFL_WEB_USER_CUSTOM_FIELD_LOOKUP_ID};
        }
        #endregion

    }
}
