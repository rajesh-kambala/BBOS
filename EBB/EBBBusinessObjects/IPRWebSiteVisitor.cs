/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2014

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
using TSI.BusinessObjects;

namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Interface definition for the PRWebSiteVisitor class.
    /// </summary>
    public partial interface IPRWebSiteVisitor : IEBBObject
    {
         #region TSI Framework Generated Code
        /// <summary>
        /// Accessor for the prwsv_CreatedDate property.
        /// </summary>
        DateTime prwsv_CreatedDate {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwsv_TimeStamp property.
        /// </summary>
        DateTime prwsv_TimeStamp {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwsv_UpdatedDate property.
        /// </summary>
        DateTime prwsv_UpdatedDate {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwsv_CreatedBy property.
        /// </summary>
        int prwsv_CreatedBy {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwsv_Deleted property.
        /// </summary>
        int prwsv_Deleted {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwsv_Secterr property.
        /// </summary>
        int prwsv_Secterr {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwsv_UpdatedBy property.
        /// </summary>
        int prwsv_UpdatedBy {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwsv_WebSiteVisitorID property.
        /// </summary>
        int prwsv_WebSiteVisitorID {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwsv_WorkflowId property.
        /// </summary>
        int prwsv_WorkflowId {
            get;
            set;
        }

        int prwsv_CompanyID
        {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwsv_PrimaryFunction property.
        /// </summary>
        string prwsv_PrimaryFunction {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwsv_CompanyName property.
        /// </summary>
        string prwsv_CompanyName {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwsv_SubmitterEmail property.
        /// </summary>
        string prwsv_SubmitterEmail {
            get;
            set;
        }

        string prwsv_SubmitterIPAddress
        {
            get;
            set;
        }

        string prwsv_IndustryType
        {
            get;
            set;
        }

        string prwsv_RequestsMembershipInfo
        {
            get;
            set;
        }

        string prwsv_Referrer
        {
            get;
            set;
        }

        string prwsv_SubmitterName
        {
            get;
            set;
        }

        string prwsv_SubmitterPhone
        {
            get;
            set;
        }

        string prwsv_State
        {
            get;
            set;
        }

        string prwsv_Country
        {
            get;
            set;
        }
         #endregion
    }
}
