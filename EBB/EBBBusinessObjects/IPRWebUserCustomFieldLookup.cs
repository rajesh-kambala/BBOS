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

 ClassName: PRWebUserCustomFieldLookup
 Description:	

 Notes:	Created By TSI Class Generator on 7/18/2014 2:10:14 PM

***********************************************************************
***********************************************************************/
using System;
using TSI.BusinessObjects;

namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Interface definition for the PRWebUserCustomFieldLookup class.
    /// </summary>
    public partial interface IPRWebUserCustomFieldLookup : IEBBObject
    {
         #region TSI Framework Generated Code
        /// <summary>
        /// Accessor for the prwucfl_CreatedDate property.
        /// </summary>
        DateTime prwucfl_CreatedDate {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucfl_TimeStamp property.
        /// </summary>
        DateTime prwucfl_TimeStamp {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucfl_UpdatedDate property.
        /// </summary>
        DateTime prwucfl_UpdatedDate {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucfl_CreatedBy property.
        /// </summary>
        int prwucfl_CreatedBy {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucfl_Deleted property.
        /// </summary>
        int prwucfl_Deleted {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucfl_Secterr property.
        /// </summary>
        int prwucfl_Secterr {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucfl_Sequence property.
        /// </summary>
        int prwucfl_Sequence {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucfl_UpdatedBy property.
        /// </summary>
        int prwucfl_UpdatedBy {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucfl_WebUserCustomFieldID property.
        /// </summary>
        int prwucfl_WebUserCustomFieldID {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucfl_WebUserCustomFieldLookupID property.
        /// </summary>
        int prwucfl_WebUserCustomFieldLookupID {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucfl_WorkflowId property.
        /// </summary>
        int prwucfl_WorkflowId {
            get;
            set;
        }

        /// <summary>
        /// Accessor for the prwucfl_LookupValue property.
        /// </summary>
        string prwucfl_LookupValue {
            get;
            set;
        }

         #endregion
    }
}
