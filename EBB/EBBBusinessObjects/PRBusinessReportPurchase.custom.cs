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

 ClassName: PRBusinessReportPurchase
 Description:	

 Notes:	Created By TSI Class Generator on 4/15/2014 12:55:44 PM

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.IO;
using System.Net.Mail;
using System.Text;

using PRCo.BBS;
using PRCo.EBB.Util;

using TSI.Utils;

namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Provides the functionality for the PRBusinessReportPurchase.
    /// </summary>
    public partial class PRBusinessReportPurchase : EBBObject, IPRBusinessReportPurchase
    {

        public void CreateCRMTask(CreditCardPaymentInfo oCCPayment, CreditCardProductInfo oProductInfo)
        {
            StringBuilder taskMsg = new StringBuilder();
            taskMsg.Append("BUSINESS REPORT PURCHASE:" + Environment.NewLine + Environment.NewLine);
            AddField(taskMsg, "Name", oCCPayment.FullName);
            AddField(taskMsg, "Email", prbrp_SubmitterEmail);
            AddField(taskMsg, "Street1", oCCPayment.Street1);
            AddField(taskMsg, "Street2", oCCPayment.Street2);
            AddField(taskMsg, "City", oCCPayment.City);
            AddField(taskMsg, "State", GetObjectMgr().GetStateAbbr(Convert.ToInt32(oCCPayment.StateID)));
            AddField(taskMsg, "Postal Code", oCCPayment.PostalCode);
            AddField(taskMsg, "Requested Membership Info", _prbrp_RequestsMembershipInfo);
            AddField(taskMsg, "Subject Company BB #", _prbrp_CompanyID.ToString());
            AddField(taskMsg, "Business Report Type", oProductInfo.ProductCode);
            
            taskMsg.Append(Environment.NewLine);

            int salesUserID = GetObjectMgr().GetPRCoSpecialistID(oCCPayment.City, oCCPayment.StateID, GeneralDataMgr.PRCO_SPECIALIST_INSIDE_SALES, null);

            GetObjectMgr().CreateTask(salesUserID,
                                    "Pending",
                                    taskMsg.ToString(),
                                    Utilities.GetConfigValue("BRPurchaseTaskCategory", "SM"),
                                    Utilities.GetConfigValue("BRPurchaseTaskCategory", string.Empty),
                                    0,
                                    0,
                                    null);
        }


        public void SendBREmail()
        {
            string productCode = (string)GetObjectMgr().GetDBAccessFullRights().ExecuteScalar("SELECT prod_Code FROM NewProduct WHERE prod_ProductID=" + _prbrp_ProductID);
            SendBREmail(productCode);
        }

        public void SendBREmail(string productCode)
        {
            string subject = GetCustomCaptionMgr().GetMeaning("PurchaseBR", "Subject");
            string body = GetCustomCaptionMgr().GetMeaning("PurchaseBR", "Body");
            string email = GetObjectMgr().GetFormattedEmail(0, 0, 0, subject, body, "en-us", prbrp_IndustryType);


            List<Attachment> attachments = new List<Attachment>();
            byte[] renderedReport = GetBusinessReport(productCode);
            string reportName = string.Format("{0} Blue Book ID {1} Business Report.pdf", "", _prbrp_CompanyID);

            attachments.Add(new Attachment(new MemoryStream(renderedReport), reportName));

            body = GetObjectMgr().GetFormattedEmail(0, 0, 0, subject, body, "en-us", prbrp_IndustryType);
            EmailUtils.SendHtmlMail(_prbrp_SubmitterEmail,
                                    subject,
                                    body,
                                    attachments);

            //GetObjectMgr().InsertCommunicationLog(reportName, "Web Site BR Purchase", subject);
        }


        protected ReportInterface _oRI;
        /// <summary>
        /// Interfaces with SSRS to generate the business report.
        /// </summary>
        /// <param name="requestTypeCode"></param>
        /// <returns></returns>
        protected byte[] GetBusinessReport(string requestTypeCode)
        {

            if (_oRI == null)
            {
                _oRI = new ReportInterface();
            }

            int iReportLevel = Convert.ToInt32(requestTypeCode.Replace("BR", ""));

            bool bIncludeBalanceSheet = false;
            bool IsEligibleForEquifaxData = false;


            return _oRI.GenerateBusinessReport(_prbrp_CompanyID.ToString(), iReportLevel, bIncludeBalanceSheet, false, 0, IsEligibleForEquifaxData, 0);
        }

    }
}
