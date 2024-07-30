/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2018-2020

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Blue Book Services, Inc..  Contact
 by e-mail at info@travant.com

 ClassName: PRWebUserWidget
 Description:	

 Notes:	Created By TSI Class Generator on 8/10/2018 11:59:27 AM

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
    /// Data Manager for the PRWebUserWidget class.
    /// </summary>
    public partial class PRWebUserWidgetMgr : EBBObjectMgr
    {
        public const string COL_PRWUW_CREATED_DATE			= "prwuw_CreatedDate";
        public const string COL_PRWUW_TIME_STAMP			= "prwuw_TimeStamp";
        public const string COL_PRWUW_UPDATED_DATE			= "prwuw_UpdatedDate";
        public const string COL_PRWUW_CREATED_BY			= "prwuw_CreatedBy";
        public const string COL_PRWUW_DELETED				= "prwuw_Deleted";
        public const string COL_PRWUW_SECTERR				= "prwuw_Secterr";
        public const string COL_PRWUW_SEQUENCE				= "prwuw_Sequence";
        public const string COL_PRWUW_UPDATED_BY			= "prwuw_UpdatedBy";
        public const string COL_PRWUW_WEB_USER_ID			= "prwuw_WebUserID";
        public const string COL_PRWUW_WEB_USER_WIDGET_ID	= "prwuw_WebUserWidgetID";
        public const string COL_PRWUW_WORKFLOW_ID			= "prwuw_WorkflowId";
        public const string COL_PRWUW_WIDGET_CODE			= "prwuw_WidgetCode";

        #region TSI Framework Generated Code
        /// <summary>
        /// Constructor to initalize data manager
        /// </summary>
        /// <returns></returns>
        public PRWebUserWidgetMgr(){}

        /// <summary>
        /// Constructor to initalize data manager
        /// </summary>
        /// <param name="oLogger">Logger</param>
        /// <param name="oUser">Current User</param>
        public PRWebUserWidgetMgr(ILogger oLogger,
                                IUser oUser): base(oLogger, oUser){}

        /// <summary>
        /// Constructor to initalize data manager
        /// </summary>
        /// <param name="oConn">DB Connection</param>
        /// <param name="oLogger">Logger</param>
        /// <param name="oUser">Current User</param>
        public PRWebUserWidgetMgr(IDbConnection oConn,
                                ILogger oLogger,
                                IUser oUser): base(oConn, oLogger, oUser){}

        /// <summary>
        /// Constructor using the Logger, User, and Transaction
        /// of the specified Manager to initialize this manager.
        /// </summary>
        /// <param name="oBizObjMgr">Business Object Manager</param>
        public PRWebUserWidgetMgr(BusinessObjectMgr oBizObjMgr): base(oBizObjMgr){}

        /// <summary>
        /// Creates an instance of the PRWebUserWidget business object
        /// </summary>
        /// <returns>IBusinessObject</returns>
        override protected IBusinessObject InstantiateBusinessObject(IDictionary oData) {
            return new PRWebUserWidget();
        }

        /// <summary>
        /// The name of the table our business object
        /// is mapped to.
        /// </summary>
        /// <returns>Table Name</returns>
        override public string GetTableName() {
            return "PRWebUserWidget";
        }

        /// <summary>
        /// The name of the business object class.
        /// </summary>
        /// <returns>Business Object Name</returns>
        override public string GetBusinessObjectName() {
            return "PRCo.EBB.BusinessObjects.PRWebUserWidget";
        }

        /// <summary>
        /// The fields that uniquly identify this object.
        /// </summary>
        /// <returns>IList</returns>
        override public IList GetKeyFields() {
            return new String[] {COL_PRWUW_WEB_USER_WIDGET_ID};
        }
        #endregion

        protected const string SQL_GET_BY_WEBUSERID = "SELECT * FROM PRWebUserWidget WHERE prwuw_WebUserID={0}";

        public IPRWebUser GetByWebUserId(int prwuw_WebUserId)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("Parm01", prwuw_WebUserId));
            return (IPRWebUser)GetObjectByCustomSQL(SQL_GET_BY_WEBUSERID, oParameters);
        }
    }
}
