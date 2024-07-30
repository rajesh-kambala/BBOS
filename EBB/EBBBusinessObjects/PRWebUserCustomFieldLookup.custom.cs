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
using TSI.Arch;
using TSI.BusinessObjects;

namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Provides the functionality for the PRWebUserCustomFieldLookup.
    /// </summary>
    [Serializable]
    public partial class PRWebUserCustomFieldLookup : EBBObject, IPRWebUserCustomFieldLookup
    {
        public override void OnAfterLoad(IDictionary oData, int iOptions)
        {
            base.OnAfterLoad(oData, iOptions);
            _dtCreatedDateTime = _oMgr.GetDateTime(oData[PRWebUserCustomFieldLookupMgr.COL_PRWUCFL_CREATED_DATE]);
            _szCreatedUserID = _oMgr.GetString(oData[PRWebUserCustomFieldLookupMgr.COL_PRWUCFL_CREATED_BY]);
        }
    }
}
