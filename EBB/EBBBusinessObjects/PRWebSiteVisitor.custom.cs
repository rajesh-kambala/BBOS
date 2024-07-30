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

 ClassName: PRWebSiteVisitor
 Description:	

 Notes:	Created By TSI Class Generator on 4/7/2014 8:51:54 AM

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Text;
using TSI.Utils;

namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Provides the functionality for the PRWebSiteVisitor.
    /// </summary>
    public partial class PRWebSiteVisitor : EBBObject, IPRWebSiteVisitor
    {

        public void CreateCRMTask()
        {
            StringBuilder taskMsg = new StringBuilder();
            taskMsg.Append("VISITOR INFO / MEMBERSHIP INTEREST" + Environment.NewLine + Environment.NewLine);

            AddField(taskMsg, "Submitter Email", prwsv_SubmitterEmail);
            AddField(taskMsg, "CompanyName", prwsv_CompanyName);
            AddField(taskMsg, "Primary Function", GetCustomCaptionMgr().GetMeaning("prglr_PrimaryFunction", prwsv_PrimaryFunction));
            AddField(taskMsg, "CompanyName", prwsv_CompanyName);

            taskMsg.Append(Environment.NewLine);

            List<string> matchedCompanies = ((PRGetListedRequestMgr)_oMgr).GetFuzzyMatchCompanies(this._prwsv_CompanyName);
            if (matchedCompanies.Count == 0)
            {
                taskMsg.Append("No matching companies found." + Environment.NewLine);
            }
            else
            {
                taskMsg.Append(string.Format("Found {0} potential matching companies:" + Environment.NewLine, matchedCompanies.Count));
                foreach (string matchedCompany in matchedCompanies)
                {
                    taskMsg.Append(" - " + matchedCompany + Environment.NewLine);
                }
            }

            int salesUserID = 0;
            //int salesUserID = GetObjectMgr().GetPRCoSpecialistID(prglr_City, Convert.ToInt32(prglr_State), GeneralDataMgr.PRCO_SPECIALIST_INSIDE_SALES, null);

            GetObjectMgr().CreateTask(salesUserID,
                                    "Pending",
                                    taskMsg.ToString(),
                                    Utilities.GetConfigValue("GetListedTaskCategory", "SM"),
                                    Utilities.GetConfigValue("GetListedTaskSubategory", "LI"),
                                    0,
                                    0,
                                    0,
                                    "OnineIn",
                                    "Membership interest expressed via Marketing Site",
                                    null);
            
        }
    }
}
