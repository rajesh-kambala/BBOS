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

 ClassName: PRGetListedRequest
 Description:	

 Notes:	Created By TSI Class Generator on 3/17/2014 2:42:33 PM

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
    /// Data Manager for the PRGetListedRequest class.
    /// </summary>
    public partial class PRGetListedRequestMgr : EBBObjectMgr
    {
        public const string COL_PRGLR_CREATED_DATE				= "prglr_CreatedDate";
        public const string COL_PRGLR_TIME_STAMP				= "prglr_TimeStamp";
        public const string COL_PRGLR_UPDATED_DATE				= "prglr_UpdatedDate";
        public const string COL_PRGLR_CREATED_BY				= "prglr_CreatedBy";
        public const string COL_PRGLR_DELETED					= "prglr_Deleted";
        public const string COL_PRGLR_GET_LISTED_REQUEST_ID		= "prglr_GetListedRequestID";
        public const string COL_PRGLR_SECTERR					= "prglr_Secterr";
        public const string COL_PRGLR_UPDATED_BY				= "prglr_UpdatedBy";
        public const string COL_PRGLR_WORKFLOW_ID				= "prglr_WorkflowId";
        public const string COL_PRGLR_HOW_LEARNED				= "prglr_HowLearned";
        public const string COL_PRGLR_PRIMARY_FUNCTION			= "prglr_PrimaryFunction";
        public const string COL_PRGLR_REQUESTS_MEMBERSHIP_INFO	= "prglr_RequestsMembershipInfo";
        public const string COL_PRGLR_SUBMITTER_IS_OWNER		= "prglr_SubmitterIsOwner";
        public const string COL_PRGLR_CITY						= "prglr_City";
        public const string COL_PRGLR_COMPANY_EMAIL				= "prglr_CompanyEmail";
        public const string COL_PRGLR_COMPANY_NAME				= "prglr_CompanyName";
        public const string COL_PRGLR_COMPANY_PHONE				= "prglr_CompanyPhone";
        public const string COL_PRGLR_COMPANY_WEBSITE			= "prglr_CompanyWebsite";
        public const string COL_PRGLR_COUNTRY					= "prglr_Country";
        public const string COL_PRGLR_POSTAL_CODE				= "prglr_PostalCode";
        public const string COL_PRGLR_PRINCIPALS				= "prglr_Principals";
        public const string COL_PRGLR_STATE						= "prglr_State";
        public const string COL_PRGLR_STREET1					= "prglr_Street1";
        public const string COL_PRGLR_STREET2					= "prglr_Street2";
        public const string COL_PRGLR_SUBMITTER_EMAIL			= "prglr_SubmitterEmail";
        public const string COL_PRGLR_SUBMITTER_IPADDRESS		= "prglr_SubmitterIPAddress";
        public const string COL_PRGLR_SUBMITTER_NAME			= "prglr_SubmitterName";
        public const string COL_PRGLR_SUBMITTER_PHONE			= "prglr_SubmitterPhone";
        public const string COL_PRGLR_INDUSTRY_TYPE             = "prglr_IndustryType";
        

        #region TSI Framework Generated Code
        /// <summary>
        /// Constructor to initalize data manager
        /// </summary>
        /// <returns></returns>
        public PRGetListedRequestMgr(){}

        /// <summary>
        /// Constructor to initalize data manager
        /// </summary>
        /// <param name="oLogger">Logger</param>
        /// <param name="oUser">Current User</param>
        public PRGetListedRequestMgr(ILogger oLogger,
                                IUser oUser): base(oLogger, oUser){}

        /// <summary>
        /// Constructor to initalize data manager
        /// </summary>
        /// <param name="oConn">DB Connection</param>
        /// <param name="oLogger">Logger</param>
        /// <param name="oUser">Current User</param>
        public PRGetListedRequestMgr(IDbConnection oConn,
                                ILogger oLogger,
                                IUser oUser): base(oConn, oLogger, oUser){}

        /// <summary>
        /// Constructor using the Logger, User, and Transaction
        /// of the specified Manager to initialize this manager.
        /// </summary>
        /// <param name="oBizObjMgr">Business Object Manager</param>
        public PRGetListedRequestMgr(BusinessObjectMgr oBizObjMgr): base(oBizObjMgr){}

        /// <summary>
        /// Creates an instance of the PRGetListedRequest business object
        /// </summary>
        /// <returns>IBusinessObject</returns>
        override protected IBusinessObject InstantiateBusinessObject(IDictionary oData) {
            return new PRGetListedRequest();
        }

        /// <summary>
        /// The name of the table our business object
        /// is mapped to.
        /// </summary>
        /// <returns>Table Name</returns>
        override public string GetTableName() {
            return "PRGetListedRequest";
        }

        /// <summary>
        /// The name of the business object class.
        /// </summary>
        /// <returns>Business Object Name</returns>
        override public string GetBusinessObjectName() {
            return "PRCo.EBB.BusinessObjects.PRGetListedRequest";
        }

        /// <summary>
        /// The fields that uniquly identify this object.
        /// </summary>
        /// <returns>IList</returns>
        override public IList GetKeyFields() {
            return new String[] {COL_PRGLR_GET_LISTED_REQUEST_ID};
        }
        #endregion

    }
}
