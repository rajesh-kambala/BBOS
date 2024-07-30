/***********************************************************************
***********************************************************************
 Copyright Blue Book Services 2023

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Blue Book Services.  Contact
 by e-mail at info@travant.com

 ClassName: PRInvoice
 Description:	

 Notes:	Created By TSI Class Generator on 5/15/2023 8:13:35 AM

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
    /// Data Manager for the PRInvoice class.
    /// </summary>
    public partial class PRInvoiceMgr : EBBObjectMgr
    {
        public const string COL_PRINV_CREATED_DATE			= "prinv_CreatedDate";
        public const string COL_PRINV_PAYMENT_DATE_TIME		= "prinv_PaymentDateTime";
        public const string COL_PRINV_SENT_DATE_TIME		= "prinv_SentDateTime";
        public const string COL_PRINV_UPDATED_DATE			= "prinv_UpdatedDate";
        public const string COL_PRINV_COMPANY_ID			= "prinv_CompanyID";
        public const string COL_PRINV_CREATED_BY			= "prinv_CreatedBy";
        public const string COL_PRINV_DELETED				= "prinv_Deleted";
        public const string COL_PRINV_INVOICE_ID			= "prinv_InvoiceID";
        public const string COL_PRINV_SECTERR				= "prinv_Secterr";
        public const string COL_PRINV_UPDATED_BY			= "prinv_UpdatedBy";
        public const string COL_PRINV_WORKFLOW_ID			= "prinv_WorkflowId";
        public const string COL_PRINV_INVOICE_NBR			= "prinv_InvoiceNbr";
        public const string COL_PRINV_PAYMENT_METHOD		= "prinv_PaymentMethod";
        public const string COL_PRINV_PAYMENT_METHOD_CODE	= "prinv_PaymentMethodCode";
        public const string COL_PRINV_PAYMENT_BRAND         = "prinv_PaymentBrand";
        public const string COL_PRINV_PAYMENT_IMPORTED_INTO_MAS = "prinv_PaymentImportedIntoMAS";
        public const string COL_PRINV_STRIPE_PAYMENT_URL	= "prinv_StripePaymentURL";
        public const string COL_PRINV_STRIPE_INVOICE_ID     = "prinv_StripeInvoiceId";
        public const string COL_PRINV_SENT_METHOD_CODE		= "prinv_SentMethodCode";

        #region TSI Framework Generated Code
        /// <summary>
        /// Constructor to initalize data manager
        /// </summary>
        /// <returns></returns>
        public PRInvoiceMgr(){}

        /// <summary>
        /// Constructor to initalize data manager
        /// </summary>
        /// <param name="oLogger">Logger</param>
        /// <param name="oUser">Current User</param>
        public PRInvoiceMgr(ILogger oLogger,
                                IUser oUser): base(oLogger, oUser){}

        /// <summary>
        /// Constructor to initalize data manager
        /// </summary>
        /// <param name="oConn">DB Connection</param>
        /// <param name="oLogger">Logger</param>
        /// <param name="oUser">Current User</param>
        public PRInvoiceMgr(IDbConnection oConn,
                                ILogger oLogger,
                                IUser oUser): base(oConn, oLogger, oUser){}

        /// <summary>
        /// Constructor using the Logger, User, and Transaction
        /// of the specified Manager to initialize this manager.
        /// </summary>
        /// <param name="oBizObjMgr">Business Object Manager</param>
        public PRInvoiceMgr(BusinessObjectMgr oBizObjMgr): base(oBizObjMgr){}

        /// <summary>
        /// Creates an instance of the PRInvoice business object
        /// </summary>
        /// <returns>IBusinessObject</returns>
        override protected IBusinessObject InstantiateBusinessObject(IDictionary oData) {
            return new PRInvoice();
        }

        /// <summary>
        /// The name of the table our business object
        /// is mapped to.
        /// </summary>
        /// <returns>Table Name</returns>
        override public string GetTableName() {
            return "PRInvoice";
        }

        /// <summary>
        /// The name of the business object class.
        /// </summary>
        /// <returns>Business Object Name</returns>
        override public string GetBusinessObjectName() {
            return "PRCo.EBB.BusinessObjects.PRInvoice";
        }

        /// <summary>
        /// The fields that uniquly identify this object.
        /// </summary>
        /// <returns>IList</returns>
        override public IList GetKeyFields() {
            return new String[] {COL_PRINV_INVOICE_ID};
        }
        #endregion

    }
}
