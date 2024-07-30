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

        public override bool UsesIdentity
        {
            get
            {
                return true;
            }
            set
            {
                base.UsesIdentity = value;
            }
        }

        /// <summary>
        /// Override the standard TSI audit column names with the
        /// Sage CRM names.
        /// </summary>
        new public const string COL_CREATED_USER_ID = "prglr_CreatedBy";
        new public const string COL_UPDATED_USER_ID = "prglr_UpdatedBy";
        new public const string COL_CREATED_DATETIME = "prglr_CreatedDate";
        new public const string COL_UPDATED_DATETIME = "prglr_UpdatedDate";
        public const string COL_TIMESTAMP = "prglr_Timestamp";
    }
}
