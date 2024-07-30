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

 ClassName: PRWebSiteVisitor
 Description:	

 Notes:	Created By TSI Class Generator on 4/7/2014 8:51:54 AM

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
    /// Data Manager for the PRWebSiteVisitor class.
    /// </summary>
    public partial class PRWebSiteVisitorMgr : EBBObjectMgr
    {
        public const string COL_PRWSV_CREATED_DATE			= "prwsv_CreatedDate";
        public const string COL_PRWSV_TIME_STAMP			= "prwsv_TimeStamp";
        public const string COL_PRWSV_UPDATED_DATE			= "prwsv_UpdatedDate";
        public const string COL_PRWSV_CREATED_BY			= "prwsv_CreatedBy";
        public const string COL_PRWSV_DELETED				= "prwsv_Deleted";
        public const string COL_PRWSV_SECTERR				= "prwsv_Secterr";
        public const string COL_PRWSV_UPDATED_BY			= "prwsv_UpdatedBy";
        public const string COL_PRWSV_WEB_SITE_VISITOR_ID	= "prwsv_WebSiteVisitorID";
        public const string COL_PRWSV_WORKFLOW_ID			= "prwsv_WorkflowId";
        public const string COL_PRWSV_PRIMARY_FUNCTION		= "prwsv_PrimaryFunction";
        public const string COL_PRWSV_COMPANY_NAME			= "prwsv_CompanyName";
        public const string COL_PRWSV_SUBMITTER_EMAIL		= "prwsv_SubmitterEmail";
        public const string COL_PRWSV_SUBMITTER_IP_ADDRESS  = "prwsv_SubmitterIPAddress";
        public const string COL_PRWSV_COMPANY_ID            = "prwsv_CompanyID";
        public const string COL_PRWSV_INDUSTRY_TYPE         = "prwsv_IndustryType";
        public const string COL_PRWSV_REFERRER              = "prwsv_Referrer";
        public const string COL_PRWSV_REQUEST_MEMBERSHIP_INFO = "prwsv_RequestsMembershipInfo";

        public const string COL_PRWSV_SUBMITTER_NAME = "prwsv_SubmitterName";
        public const string COL_PRWSV_SUBMITTER_PHONE = "prwsv_SubmitterPhone";
        public const string COL_PRWSV_STATE = "prwsv_State";
        public const string COL_PRWSV_COUNTRY = "prwsv_Country";

        /// <summary>
        /// Override the standard TSI audit column names with the
        /// Sage CRM names.
        /// </summary>
        new public const string COL_CREATED_USER_ID = "prwsv_CreatedBy";
        new public const string COL_UPDATED_USER_ID = "prwsv_UpdatedBy";
        new public const string COL_CREATED_DATETIME = "prwsv_CreatedDate";
        new public const string COL_UPDATED_DATETIME = "prwsv_UpdatedDate";
        public const string COL_TIMESTAMP = "prwsv_TimeStamp";


        #region TSI Framework Generated Code
        /// <summary>
        /// Constructor to initalize data manager
        /// </summary>
        /// <returns></returns>
        public PRWebSiteVisitorMgr(){}

        /// <summary>
        /// Constructor to initalize data manager
        /// </summary>
        /// <param name="oLogger">Logger</param>
        /// <param name="oUser">Current User</param>
        public PRWebSiteVisitorMgr(ILogger oLogger,
                                IUser oUser): base(oLogger, oUser){}

        /// <summary>
        /// Constructor to initalize data manager
        /// </summary>
        /// <param name="oConn">DB Connection</param>
        /// <param name="oLogger">Logger</param>
        /// <param name="oUser">Current User</param>
        public PRWebSiteVisitorMgr(IDbConnection oConn,
                                ILogger oLogger,
                                IUser oUser): base(oConn, oLogger, oUser){}

        /// <summary>
        /// Constructor using the Logger, User, and Transaction
        /// of the specified Manager to initialize this manager.
        /// </summary>
        /// <param name="oBizObjMgr">Business Object Manager</param>
        public PRWebSiteVisitorMgr(BusinessObjectMgr oBizObjMgr): base(oBizObjMgr){}

        /// <summary>
        /// Creates an instance of the PRWebSiteVisitor business object
        /// </summary>
        /// <returns>IBusinessObject</returns>
        override protected IBusinessObject InstantiateBusinessObject(IDictionary oData) {
            return new PRWebSiteVisitor();
        }


        /// <summary>
        /// The name of the table our business object
        /// is mapped to.
        /// </summary>
        /// <returns>Table Name</returns>
        override public string GetTableName() {
            return "PRWebSiteVisitor";
        }

        /// <summary>
        /// The name of the business object class.
        /// </summary>
        /// <returns>Business Object Name</returns>
        override public string GetBusinessObjectName() {
            return "PRCo.EBB.BusinessObjects.PRWebSiteVisitor";
        }

        /// <summary>
        /// The fields that uniquly identify this object.
        /// </summary>
        /// <returns>IList</returns>
        override public IList GetKeyFields() {
            return new String[] {COL_PRWSV_WEB_SITE_VISITOR_ID};
        }
        #endregion

    }
}
