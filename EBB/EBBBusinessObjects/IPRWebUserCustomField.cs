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

 ClassName: PRWebUserCustomField
 Description:	

 Notes:	Created By TSI Class Generator on 7/18/2014 11:35:00 AM

***********************************************************************
***********************************************************************/
using System;
using TSI.BusinessObjects;

namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Interface definition for the PRWebUserCustomField class.
    /// </summary>
    public partial interface IPRWebUserCustomField : IEBBObject
    {
         #region TSI Framework Generated Code
        /// <summary>
        /// Accessor for the prwucf_CreatedDate property.
        /// </summary>
        DateTime prwucf_CreatedDate {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucf_TimeStamp property.
        /// </summary>
        DateTime prwucf_TimeStamp {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucf_UpdatedDate property.
        /// </summary>
        DateTime prwucf_UpdatedDate {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucf_CompanyID property.
        /// </summary>
        int prwucf_CompanyID {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucf_CreatedBy property.
        /// </summary>
        int prwucf_CreatedBy {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucf_Deleted property.
        /// </summary>
        int prwucf_Deleted {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucf_HQID property.
        /// </summary>
        int prwucf_HQID {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucf_Secterr property.
        /// </summary>
        int prwucf_Secterr {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucf_Sequence property.
        /// </summary>
        int prwucf_Sequence {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucf_UpdatedBy property.
        /// </summary>
        int prwucf_UpdatedBy {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucf_WebUserCustomFieldID property.
        /// </summary>
        int prwucf_WebUserCustomFieldID {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucf_WorkflowId property.
        /// </summary>
        int prwucf_WorkflowId {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucf_FieldTypeCode property.
        /// </summary>
        string prwucf_FieldTypeCode {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucf_Hide property.
        /// </summary>
        bool prwucf_Hide {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucf_Pinned property.
        /// </summary>
        bool prwucf_Pinned
        {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucf_Label property.
        /// </summary>
        string prwucf_Label {
            get;
            set;
        }

         #endregion
    }
}
