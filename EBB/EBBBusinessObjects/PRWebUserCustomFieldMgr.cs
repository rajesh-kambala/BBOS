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

 ClassName: PRWebUserCustomField
 Description:	

 Notes:	Created By TSI Class Generator on 7/18/2014 11:35:00 AM

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
    /// Data Manager for the PRWebUserCustomField class.
    /// </summary>
    public partial class PRWebUserCustomFieldMgr : EBBObjectMgr
    {
        public const string COL_PRWUCF_CREATED_DATE						= "prwucf_CreatedDate";
        public const string COL_PRWUCF_TIME_STAMP						= "prwucf_TimeStamp";
        public const string COL_PRWUCF_UPDATED_DATE						= "prwucf_UpdatedDate";
        public const string COL_PRWUCF_COMPANY_ID						= "prwucf_CompanyID";
        public const string COL_PRWUCF_CREATED_BY						= "prwucf_CreatedBy";
        public const string COL_PRWUCF_DELETED							= "prwucf_Deleted";
        public const string COL_PRWUCF_HQID								= "prwucf_HQID";
        public const string COL_PRWUCF_SECTERR							= "prwucf_Secterr";
        public const string COL_PRWUCF_SEQUENCE							= "prwucf_Sequence";
        public const string COL_PRWUCF_UPDATED_BY						= "prwucf_UpdatedBy";
        public const string COL_PRWUCF_WEB_USER_CUSTOM_FIELD_ID			= "prwucf_WebUserCustomFieldID";
        public const string COL_PRWUCF_WORKFLOW_ID						= "prwucf_WorkflowId";
        public const string COL_PRWUCF_FIELD_TYPE_CODE					= "prwucf_FieldTypeCode";
        public const string COL_PRWUCF_HIDE								= "prwucf_Hide";
        public const string COL_PRWUCF_PINNED							= "prwucf_Pinned";
        public const string COL_PRWUCF_LABEL							= "prwucf_Label";

        #region TSI Framework Generated Code
        /// <summary>
        /// Constructor to initalize data manager
        /// </summary>
        /// <returns></returns>
        public PRWebUserCustomFieldMgr(){}

        /// <summary>
        /// Constructor to initalize data manager
        /// </summary>
        /// <param name="oLogger">Logger</param>
        /// <param name="oUser">Current User</param>
        public PRWebUserCustomFieldMgr(ILogger oLogger,
                                IUser oUser): base(oLogger, oUser){}

        /// <summary>
        /// Constructor to initalize data manager
        /// </summary>
        /// <param name="oConn">DB Connection</param>
        /// <param name="oLogger">Logger</param>
        /// <param name="oUser">Current User</param>
        public PRWebUserCustomFieldMgr(IDbConnection oConn,
                                ILogger oLogger,
                                IUser oUser): base(oConn, oLogger, oUser){}

        /// <summary>
        /// Constructor using the Logger, User, and Transaction
        /// of the specified Manager to initialize this manager.
        /// </summary>
        /// <param name="oBizObjMgr">Business Object Manager</param>
        public PRWebUserCustomFieldMgr(BusinessObjectMgr oBizObjMgr): base(oBizObjMgr){}

        /// <summary>
        /// Creates an instance of the PRWebUserCustomField business object
        /// </summary>
        /// <returns>IBusinessObject</returns>
        override protected IBusinessObject InstantiateBusinessObject(IDictionary oData) {
            return new PRWebUserCustomField();
        }

        /// <summary>
        /// The name of the table our business object
        /// is mapped to.
        /// </summary>
        /// <returns>Table Name</returns>
        override public string GetTableName() {
            return "PRWebUserCustomField";
        }

        /// <summary>
        /// The name of the business object class.
        /// </summary>
        /// <returns>Business Object Name</returns>
        override public string GetBusinessObjectName() {
            return "PRCo.EBB.BusinessObjects.PRWebUserCustomField";
        }

        /// <summary>
        /// The fields that uniquly identify this object.
        /// </summary>
        /// <returns>IList</returns>
        override public IList GetKeyFields() {
            return new String[] {COL_PRWUCF_WEB_USER_CUSTOM_FIELD_ID};
        }
        #endregion

    }
}
