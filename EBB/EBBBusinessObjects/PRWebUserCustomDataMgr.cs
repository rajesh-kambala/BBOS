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

 ClassName: PRWebUserCustomData
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
    /// Data Manager for the PRWebUserCustomData class.
    /// </summary>
    public partial class PRWebUserCustomDataMgr : EBBObjectMgr
    {
        public const string COL_PRWUCD_CREATED_DATE						= "prwucd_CreatedDate";
        public const string COL_PRWUCD_TIME_STAMP						= "prwucd_TimeStamp";
        public const string COL_PRWUCD_UPDATED_DATE						= "prwucd_UpdatedDate";
        public const string COL_PRWUCD_ASSOCIATED_ID					= "prwucd_AssociatedID";
        public const string COL_PRWUCD_COMPANY_ID						= "prwucd_CompanyID";
        public const string COL_PRWUCD_CREATED_BY						= "prwucd_CreatedBy";
        public const string COL_PRWUCD_CUSTOM_DATA_ID					= "prwucd_CustomDataID";
        public const string COL_PRWUCD_DELETED							= "prwucd_Deleted";
        public const string COL_PRWUCD_HQID								= "prwucd_HQID";
        public const string COL_PRWUCD_SECTERR							= "prwucd_Secterr";
        public const string COL_PRWUCD_SEQUENCE							= "prwucd_sequence";
        public const string COL_PRWUCD_UPDATED_BY						= "prwucd_UpdatedBy";
        public const string COL_PRWUCD_WEB_USER_CUSTOM_FIELD_ID			= "prwucd_WebUserCustomFieldID";
        public const string COL_PRWUCD_WEB_USER_CUSTOM_FIELD_LOOKUP_ID	= "prwucd_WebUserCustomFieldLookupID";
        public const string COL_PRWUCD_WEB_USER_ID						= "prwucd_WebUserID";
        public const string COL_PRWUCD_WORKFLOW_ID						= "prwucd_WorkflowId";
        public const string COL_PRWUCD_ASSOCIATED_TYPE					= "prwucd_AssociatedType";
        public const string COL_PRWUCD_LABEL_CODE						= "prwucd_LabelCode";
        public const string COL_PRWUCD_VALUE							= "prwucd_Value";

        #region TSI Framework Generated Code
        /// <summary>
        /// Constructor to initalize data manager
        /// </summary>
        /// <returns></returns>
        public PRWebUserCustomDataMgr(){}

        /// <summary>
        /// Constructor to initalize data manager
        /// </summary>
        /// <param name="oLogger">Logger</param>
        /// <param name="oUser">Current User</param>
        public PRWebUserCustomDataMgr(ILogger oLogger,
                                IUser oUser): base(oLogger, oUser){}

        /// <summary>
        /// Constructor to initalize data manager
        /// </summary>
        /// <param name="oConn">DB Connection</param>
        /// <param name="oLogger">Logger</param>
        /// <param name="oUser">Current User</param>
        public PRWebUserCustomDataMgr(IDbConnection oConn,
                                ILogger oLogger,
                                IUser oUser): base(oConn, oLogger, oUser){}

        /// <summary>
        /// Constructor using the Logger, User, and Transaction
        /// of the specified Manager to initialize this manager.
        /// </summary>
        /// <param name="oBizObjMgr">Business Object Manager</param>
        public PRWebUserCustomDataMgr(BusinessObjectMgr oBizObjMgr): base(oBizObjMgr){}

        /// <summary>
        /// Creates an instance of the PRWebUserCustomData business object
        /// </summary>
        /// <returns>IBusinessObject</returns>
        override protected IBusinessObject InstantiateBusinessObject(IDictionary oData) {
            return new PRWebUserCustomData();
        }

        /// <summary>
        /// The name of the table our business object
        /// is mapped to.
        /// </summary>
        /// <returns>Table Name</returns>
        override public string GetTableName() {
            return "PRWebUserCustomData";
        }

        /// <summary>
        /// The name of the business object class.
        /// </summary>
        /// <returns>Business Object Name</returns>
        override public string GetBusinessObjectName() {
            return "PRCo.EBB.BusinessObjects.PRWebUserCustomData";
        }

        /// <summary>
        /// The fields that uniquly identify this object.
        /// </summary>
        /// <returns>IList</returns>
        override public IList GetKeyFields() {
            return new String[] {COL_PRWUCD_CUSTOM_DATA_ID};
        }
        #endregion

    }
}
