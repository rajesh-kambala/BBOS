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

 Notes:	Created By TSI Class Generator on 7/18/2014 9:36:57 AM

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
    /// Data Manager for the PRWebUserCustomFieldLookup class.
    /// </summary>
    [Serializable]
    public partial class PRWebUserCustomFieldLookupMgr : EBBObjectMgr
    {
        /// <summary>
        /// Override the standard TSI audit column names with the
        /// Sage CRM names.
        /// </summary>
        new public const string COL_CREATED_USER_ID = "prwucfl_CreatedBy";
        new public const string COL_UPDATED_USER_ID = "prwucfl_UpdatedBy";
        new public const string COL_CREATED_DATETIME = "prwucfl_CreatedDate";
        new public const string COL_UPDATED_DATETIME = "prwucfl_UpdatedDate";


        public IBusinessObjectSet GetByCustomField(int customFieldID)
        {
            IList parmList = GetParmList("CustomFieldID", customFieldID);
            IList sortList = GetSortList("prwucfl_Sequence", true);
            sortList.Add(new SortCriterion("prwucfl_LookupValue", true));

            return GetObjects(FormatSQL("prwucfl_WebUserCustomFieldID = {0}", parmList), sortList, parmList);
        }


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
    }
}
