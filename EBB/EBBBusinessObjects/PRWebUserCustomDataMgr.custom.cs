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
    /// Data Manager for the PRWebUserCustomData class.
    /// </summary>
    [Serializable]
    public partial class PRWebUserCustomDataMgr : EBBObjectMgr
    {
        public IPRWebUserCustomData GetFieldValue(int customFieldID, int companyID)
        {
            IList parmList = GetParmList("CustomFieldID", customFieldID);
            parmList.Add(new ObjectParameter("AssociatedID", companyID));

            IBusinessObjectSet results = GetObjects(FormatSQL("prwucd_WebUserCustomFieldID={0} AND prwucd_AssociatedID={1}", parmList), null, parmList);
            if (results.Count == 0) {
                return null;
            }

            return (IPRWebUserCustomData)results[0];
        }

        public int DeleteByLookupValue(int customFieldLookupID, System.Data.IDbTransaction oTran)
        {
            IList parmList = GetParmList("CustomFieldLookupID", customFieldLookupID);
            return GetDBAccess().ExecuteNonQuery(FormatSQL("DELETE FROM PRWebUserCustomData WHERE prwucd_WebUserCustomFieldLookupID = {0}", parmList), parmList, oTran);
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
