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

 ClassName: PRBusinessReportPurchase
 Description:	

 Notes:	Created By TSI Class Generator on 4/15/2014 12:55:44 PM

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
    /// Data Manager for the PRBusinessReportPurchase class.
    /// </summary>
    public partial class PRBusinessReportPurchaseMgr : EBBObjectMgr
    {
        public const string COL_PRBRP_TIME_STAMP					= "prbrp_TimeStamp";
        public const string COL_PRBRP_BUSINESS_REPORT_PURCHASE_ID	= "prbrp_BusinessReportPurchaseID";
        public const string COL_PRBRP_PAYMENT_ID					= "prbrp_PaymentID";
        public const string COL_PRBRP_PRODUCT_ID					= "prbrp_ProductID";
        public const string COL_PRBRP_REQUESTS_MEMBERSHIP_INFO		= "prbrp_RequestsMembershipInfo";
        public const string COL_PRBRP_SUBMITTER_EMAIL				= "prbrp_SubmitterEmail";
        public const string COL_PRBRP_INDUSTRY_TYPE                 = "prbrp_IndustryType";
        public const string COL_PRBRP_COMPANY_ID                    = "prbrp_CompanyID";

        #region TSI Framework Generated Code
        /// <summary>
        /// Constructor to initalize data manager
        /// </summary>
        /// <returns></returns>
        public PRBusinessReportPurchaseMgr(){}

        /// <summary>
        /// Constructor to initalize data manager
        /// </summary>
        /// <param name="oLogger">Logger</param>
        /// <param name="oUser">Current User</param>
        public PRBusinessReportPurchaseMgr(ILogger oLogger,
                                IUser oUser): base(oLogger, oUser){}

        /// <summary>
        /// Constructor to initalize data manager
        /// </summary>
        /// <param name="oConn">DB Connection</param>
        /// <param name="oLogger">Logger</param>
        /// <param name="oUser">Current User</param>
        public PRBusinessReportPurchaseMgr(IDbConnection oConn,
                                ILogger oLogger,
                                IUser oUser): base(oConn, oLogger, oUser){}

        /// <summary>
        /// Constructor using the Logger, User, and Transaction
        /// of the specified Manager to initialize this manager.
        /// </summary>
        /// <param name="oBizObjMgr">Business Object Manager</param>
        public PRBusinessReportPurchaseMgr(BusinessObjectMgr oBizObjMgr): base(oBizObjMgr){}

        /// <summary>
        /// Creates an instance of the PRBusinessReportPurchase business object
        /// </summary>
        /// <returns>IBusinessObject</returns>
        override protected IBusinessObject InstantiateBusinessObject(IDictionary oData) {
            return new PRBusinessReportPurchase();
        }

        /// <summary>
        /// The name of the table our business object
        /// is mapped to.
        /// </summary>
        /// <returns>Table Name</returns>
        override public string GetTableName() {
            return "PRBusinessReportPurchase";
        }

        /// <summary>
        /// The name of the business object class.
        /// </summary>
        /// <returns>Business Object Name</returns>
        override public string GetBusinessObjectName() {
            return "PRCo.EBB.BusinessObjects.PRBusinessReportPurchase";
        }

        /// <summary>
        /// The fields that uniquly identify this object.
        /// </summary>
        /// <returns>IList</returns>
        override public IList GetKeyFields() {
            return new String[] {COL_PRBRP_BUSINESS_REPORT_PURCHASE_ID};
        }
        #endregion

    }
}
