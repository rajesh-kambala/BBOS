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

 ClassName: PRGetListedRequest
 Description:	

 Notes:	Created By TSI Class Generator on 3/17/2014 2:42:33 PM

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.IO;
using System.Net.Mail;
using System.Text;
using PRCo.EBB.Util;
using TSI.Utils;

namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Provides the functionality for the PRGetListedRequest.
    /// </summary>
    public partial class PRGetListedRequest : EBBObject, IPRGetListedRequest
    {

        public void CreateCRMTask()
        {
            StringBuilder taskMsg = new StringBuilder();
            taskMsg.Append("GET LISTED");

            if (prglr_RequestsMembershipInfo == "Y")
            {
                taskMsg.Append("  / MEMBERSHIP INTEREST");
            }
            taskMsg.Append(Environment.NewLine + Environment.NewLine);

            AddField(taskMsg, "Submitter Name", prglr_SubmitterName);
            AddField(taskMsg, "Submitter Phone", prglr_SubmitterPhone);
            AddField(taskMsg, "Submitter Email", prglr_SubmitterEmail);
            AddField(taskMsg, "CompanyName", prglr_CompanyName);
            AddField(taskMsg, "Street1", prglr_Street1);
            AddField(taskMsg, "Street2", prglr_Street2);
            AddField(taskMsg, "City", prglr_City);
            AddField(taskMsg, "State", GetObjectMgr().GetStateAbbr(Convert.ToInt32(prglr_State)));
            AddField(taskMsg, "Postal Code", prglr_PostalCode);
            AddField(taskMsg, "Company Phone", prglr_CompanyPhone);
            AddField(taskMsg, "Company Email", prglr_CompanyEmail);
            AddField(taskMsg, "Company Website", prglr_CompanyWebsite);

            string customCaptionName = "prglr_PrimaryFunction";
            if (prglr_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                customCaptionName = "prglr_PrimaryFunctionL";
            }
            AddField(taskMsg, "Primary Function", GetCustomCaptionMgr().GetMeaning(customCaptionName, prglr_PrimaryFunction));

            customCaptionName = "prwu_HowLearned";
            if (prglr_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER) {
                customCaptionName = "prwu_HowLearnedL";
            }
            
            AddField(taskMsg, "How learned", GetCustomCaptionMgr().GetMeaning(customCaptionName, prglr_HowLearned));


            AddField(taskMsg, "Requested Membership Info", prglr_RequestsMembershipInfo);
            AddField(taskMsg, "Submitter Is Owner", prglr_SubmitterIsOwner);
            AddField(taskMsg, "Principals", prglr_Principals);

            taskMsg.Append(Environment.NewLine);

            List<string> matchedCompanies = ((PRGetListedRequestMgr)_oMgr).GetFuzzyMatchCompanies(this._prglr_CompanyName);
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
            
            int salesUserID = GetObjectMgr().GetPRCoSpecialistID(prglr_City, Convert.ToInt32(prglr_State), GeneralDataMgr.PRCO_SPECIALIST_INSIDE_SALES, prglr_IndustryType, null);

            GetObjectMgr().CreateTask(salesUserID,
                                    "Pending",
                                    taskMsg.ToString(),
                                    Utilities.GetConfigValue("GetListedTaskCategory", "SM"),
                                    Utilities.GetConfigValue("GetListedTaskCategory", "LI"),
                                    0,
                                    0,
                                    0,
                                    "OnlineIn",
                                    "Get Listed request received from Marketing Site",
                                    null);
        }


        public void SendThankYouEmail()
        {

            if (string.IsNullOrEmpty(_prglr_SubmitterEmail))
            {
                return;
            }

            string suffix = string.Empty;
            if (prglr_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                suffix = "L";
            }

            string subject = GetCustomCaptionMgr().GetMeaning("GetListedEmail" + suffix, "Subject");
            string body = GetCustomCaptionMgr().GetMeaning("GetListedEmail" + suffix, "Body");


            string email = GetObjectMgr().GetFormattedEmail(0, 0, 0, subject, body, "en-us", prglr_IndustryType);


            List<Attachment> attachments = new List<Attachment>();

            string getListedAttachement = Path.Combine(Utilities.GetConfigValue("TemplateFolder"), Utilities.GetConfigValue("GetListedAttachementFile" + suffix, "GetListed.pdf"));
            if (File.Exists(getListedAttachement)) {
                //Attachment attachment = new Attachment(getListedAttachement, Utilities.GetConfigValue("GetListedAttachementName", "BBSI Get Listed FAQ.pdf"));
                System.Net.Mime.ContentType contentType = new System.Net.Mime.ContentType();
                contentType.MediaType = System.Net.Mime.MediaTypeNames.Application.Octet;
                contentType.Name = Utilities.GetConfigValue("GetListedAttachementName" + suffix, "BBSI Get Listed FAQ.pdf");
                Attachment attachment = new Attachment(getListedAttachement, contentType);
                attachments.Add(attachment);
            }
            

            //GetObjectMgr().SendEmail(_prglr_SubmitterEmail, subject, email, "GetListed");
            EmailUtils.SendHtmlMail(_prglr_SubmitterEmail, subject, email, attachments);
        }

    }
}
