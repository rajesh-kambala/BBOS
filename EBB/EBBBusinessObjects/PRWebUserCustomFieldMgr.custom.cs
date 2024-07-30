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
    /// Data Manager for the PRWebUserCustomField class.
    /// </summary>
    [Serializable]
    public partial class PRWebUserCustomFieldMgr : EBBObjectMgr
    {
        /// <summary>
        /// Override the standard TSI audit column names with the
        /// Sage CRM names.
        /// </summary>
        new public const string COL_CREATED_USER_ID = "prwucf_CreatedBy";
        new public const string COL_UPDATED_USER_ID = "prwucf_UpdatedBy";
        new public const string COL_CREATED_DATETIME = "prwucf_CreatedDate";
        new public const string COL_UPDATED_DATETIME = "prwucf_UpdatedDate";


        private const string SQL_GET_BY_HQ =
            @"SELECT prwucf_WebUserCustomFieldID,prwucf_CreatedBy,prwucf_CreatedDate,prwucf_UpdatedBy,prwucf_UpdatedDate,prwucf_TimeStamp,prwucf_HQID,prwucf_CompanyID,prwucf_FieldTypeCode,prwucf_Label,prwucf_Pinned,prwucf_Sequence,prwucf_Hide, 
			         COUNT(DISTINCT prwucd_AssociatedID) as CompanyCount, COUNT(DISTINCT prwucfl_WebUserCustomFieldLookupID) as ValueCount
                FROM PRWebUserCustomField WITH (NOLOCK)
                     LEFT OUTER JOIN PRWebUserCustomData WITH (NOLOCK) ON prwucf_WebUserCustomFieldID = prwucd_WebUserCustomFieldID
                     LEFT OUTER JOIN PRWebUserCustomFieldLookup WITH (NOLOCK) ON  prwucf_WebUserCustomFieldID = prwucfl_WebUserCustomFieldID
               WHERE prwucf_HQID = {0}
			GROUP BY prwucf_WebUserCustomFieldID,prwucf_CreatedBy,prwucf_CreatedDate,prwucf_UpdatedBy,prwucf_UpdatedDate,prwucf_TimeStamp,prwucf_HQID,prwucf_CompanyID,prwucf_FieldTypeCode,prwucf_Label,prwucf_Pinned,prwucf_Sequence,prwucf_Hide
            ORDER BY prwucf_Sequence, prwucf_Label";

        public IBusinessObjectSet GetByHQ(int hqID)
        {
            IList parmList = GetParmList("HQID", hqID);
            return GetObjectsByCustomSQL(FormatSQL(SQL_GET_BY_HQ, parmList),  parmList);
        }

        private const string SQL_GET_BY_ASSOCCIATED_COMPANY =
            @"SELECT PRWebUserCustomField.*, prwucd_Value, prwucfl_LookupValue
                FROM PRWebUserCustomField WITH (NOLOCK)
                     LEFT OUTER JOIN PRWebUserCustomData WITH (NOLOCK) ON prwucf_WebUserCustomFieldID = prwucd_WebUserCustomFieldID AND prwucd_AssociatedID = {1}
                     LEFT OUTER JOIN PRWebUserCustomFieldLookup WITH (NOLOCK) ON prwucd_WebUserCustomFieldLookupID = prwucfl_WebUserCustomFieldLookupID  
               WHERE prwucf_HQID = {0}  
                 AND prwucf_Hide IS NULL
            ORDER BY prwucf_Sequence, prwucf_Label";

        public IBusinessObjectSet GetByAssociatedCompany(int hqID, int companyID)
        {
            IList parmList = GetParmList("HQID", hqID);
            parmList.Add(new ObjectParameter("AssociatedID", companyID));

            return GetObjectsByCustomSQL(FormatSQL(SQL_GET_BY_ASSOCCIATED_COMPANY, parmList), parmList);
        }

        private const string SQL_GET_BY_ASSOCCIATED_COMPANY_PINNED =
            @"SELECT PRWebUserCustomField.*, prwucd_Value, prwucfl_LookupValue
                FROM PRWebUserCustomField WITH (NOLOCK)
                     LEFT OUTER JOIN PRWebUserCustomData WITH (NOLOCK) ON prwucf_WebUserCustomFieldID = prwucd_WebUserCustomFieldID AND prwucd_AssociatedID = {1}
                     LEFT OUTER JOIN PRWebUserCustomFieldLookup WITH (NOLOCK) ON prwucd_WebUserCustomFieldLookupID = prwucfl_WebUserCustomFieldLookupID  
               WHERE prwucf_HQID = {0}  
                 AND ISNULL(prwucf_Pinned, 'N') = ISNULL({2}, 'N')            
                 AND prwucf_Hide IS NULL
            ORDER BY prwucf_Sequence, prwucf_Label";


        public IBusinessObjectSet GetByAssociatedCompany(int hqID, int companyID, bool pinned)
        {
            IList parmList = GetParmList("HQID", hqID);
            parmList.Add(new ObjectParameter("AssociatedID", companyID));
            parmList.Add(new ObjectParameter("Pinned", GetPIKSCoreBool(pinned)));

            return GetObjectsByCustomSQL(FormatSQL(SQL_GET_BY_ASSOCCIATED_COMPANY_PINNED, parmList), parmList);
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

        public int GetPinnedFieldCount(int hqID)
        {
            IList parmList = GetParmList("HQID", hqID);
            return (int)GetDBAccess().ExecuteScalar(FormatSQL("SELECT COUNT(1) FROM PRWebUserCustomField WTIH (NOLOCK) WHERE prwucf_HQID = {0} AND prwucf_Pinned='Y'", parmList), parmList);
        }
    }


}
