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

 ClassName: PRWebUserCustomData
 Description:	

 Notes:	Created By TSI Class Generator on 7/18/2014 11:35:00 AM

***********************************************************************
***********************************************************************/
using System;
using TSI.BusinessObjects;

namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Interface definition for the PRWebUserCustomData class.
    /// </summary>
    public partial interface IPRWebUserCustomData : IEBBObject
    {
         #region TSI Framework Generated Code
        /// <summary>
        /// Accessor for the prwucd_CreatedDate property.
        /// </summary>
        DateTime prwucd_CreatedDate {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucd_TimeStamp property.
        /// </summary>
        DateTime prwucd_TimeStamp {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucd_UpdatedDate property.
        /// </summary>
        DateTime prwucd_UpdatedDate {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucd_AssociatedID property.
        /// </summary>
        int prwucd_AssociatedID {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucd_CompanyID property.
        /// </summary>
        int prwucd_CompanyID {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucd_CreatedBy property.
        /// </summary>
        int prwucd_CreatedBy {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucd_CustomDataID property.
        /// </summary>
        int prwucd_CustomDataID {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucd_Deleted property.
        /// </summary>
        int prwucd_Deleted {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucd_HQID property.
        /// </summary>
        int prwucd_HQID {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucd_Secterr property.
        /// </summary>
        int prwucd_Secterr {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucd_sequence property.
        /// </summary>
        int prwucd_sequence {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucd_UpdatedBy property.
        /// </summary>
        int prwucd_UpdatedBy {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucd_WebUserCustomFieldID property.
        /// </summary>
        int prwucd_WebUserCustomFieldID {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucd_WebUserCustomFieldLookupID property.
        /// </summary>
        int prwucd_WebUserCustomFieldLookupID {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucd_WebUserID property.
        /// </summary>
        int prwucd_WebUserID {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucd_WorkflowId property.
        /// </summary>
        int prwucd_WorkflowId {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucd_AssociatedType property.
        /// </summary>
        object prwucd_AssociatedType {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucd_LabelCode property.
        /// </summary>
        object prwucd_LabelCode {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucd_Value property.
        /// </summary>
        string prwucd_Value {
            get;
            set;
        }

         #endregion
    }
}
