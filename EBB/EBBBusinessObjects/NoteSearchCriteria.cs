/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2014-2015

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Blue Book Services, Inc..  Contact
 by e-mail at chris@wallsfamily.com

 ClassName: NoteSearchCriteria
 Description:	

 

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Text;

using TSI.BusinessObjects;

namespace PRCo.EBB.BusinessObjects
{
    [Serializable]
    public class NoteSearchCriteria: SearchCriteriaBase
    {
        public string Keywords;
        public int AssociatedID;
        public string AssociatedType;
        public string Subject;
        public DateTime DateFrom;
        public DateTime DateTo;
        public bool PrivateOnly;

        //public IPRWebUser WebUser;
        //public string SortField;
        //public bool SortAsc;



        public string GetSearchWhere(IList parmList)
        {
            parmList.Add(new ObjectParameter("prwun_HQID", WebUser.prwu_HQID));
            parmList.Add(new ObjectParameter("prwun_WebUserID", WebUser.prwu_WebUserID));


            StringBuilder sbWhereCondition = new StringBuilder();
            if (!string.IsNullOrEmpty(Keywords))
            {
                string[] aszTokens = Keywords.Split(new char[] { ' ' });
                foreach (string szToken in aszTokens)
                {
                    AddORCondition(sbWhereCondition, parmList, "prwun_Note", "Like", "%" + szToken + "%");
                }

                sbWhereCondition.Insert(0, "(");
                sbWhereCondition.Append(")");
            }


            if (PrivateOnly)
            {
                AddCondition(sbWhereCondition, parmList, "prwun_IsPrivate", "=", "Y");
            }

            if (AssociatedID > 0)
            {
                AddCondition(sbWhereCondition, parmList, "prwun_AssociatedID", "=", AssociatedID);
            }


            if (!string.IsNullOrEmpty(AssociatedType))
            {
                AddCondition(sbWhereCondition, parmList, "prwun_AssociatedType", "=", AssociatedType);
            }

            if (!string.IsNullOrEmpty(Subject))
            {
                AddCondition(sbWhereCondition, parmList, "Subject", "Like", "%" + Subject + "%");
            }

            if (DateFrom != DateTime.MinValue)
            {
                AddCondition(sbWhereCondition, parmList, "prwun_NoteUpdatedDateTime", ">=", DateFrom);
            }

            // Make sure our end date goes to 11:59:PM
            if (DateTo != DateTime.MinValue)
            {
                DateTime dtDateTo = DateTo;
                dtDateTo = dtDateTo.AddHours(23);
                dtDateTo = dtDateTo.AddMinutes(59);
                dtDateTo = dtDateTo.AddSeconds(59);

                AddCondition(sbWhereCondition, parmList, "prwun_NoteUpdatedDateTime", "<=", dtDateTo);
            }

            if (sbWhereCondition.Length > 0)
            {
                sbWhereCondition.Insert(0, " AND ");
            }

            return sbWhereCondition.ToString();
        }

    }
}
