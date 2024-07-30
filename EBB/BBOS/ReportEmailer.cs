/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2012-2022

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: ReportEmailer
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Net.Mail;
using ICSharpCode.SharpZipLib.Zip;
using PRCo.BBS;
using PRCo.EBB.BusinessObjects;
using PRCo.EBB.Util;
using TSI.BusinessObjects;
using TSI.DataAccess;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This class is intended to be executed in its own thread in order to generate and 
    /// send the reports without having to make the user wait.
    /// </summary>
    public class ReportEmailer
    {
        public IPRWebUser WebUser = null;
        public ILogger Logger = null;
        public bool IsEligibleForEquifaxData = false;
        public string Email;
        public string TemplateFile;
        public List<Report> Reports;
        public bool ZipFiles = false;

        public void SendEmailAttachments()
        {
            MemoryStream outputMS = null;
            ZipOutputStream zipOutputStream = null;

            try
            {
                string attachmentName = null;

                string szEmailBody = null;
                using (StreamReader srEmail = new StreamReader(TemplateFile))
                {
                    szEmailBody = srEmail.ReadToEnd();
                }

                string companyName = null;

                if (ZipFiles)
                {
                    outputMS = new System.IO.MemoryStream();
                    zipOutputStream = new ZipOutputStream(outputMS);
                    zipOutputStream.SetLevel(9);
                    zipOutputStream.IsStreamOwner = true;
                }

                List<Attachment> attachments = new List<Attachment>();
                foreach (Report report in Reports)
                {
                    byte[] renderedReport = null;
                    string reportName = null;

                    switch (report.ReportType)
                    {
                        case GetReport.BUSINESS_REPORT:
                            renderedReport = GetBusinessReport(report.CompanyID, report.RequestID, report.RequestTypeCode);
                            reportName = string.Format(Resources.Global.BusinessReportName, PageBase.GetApplicationNameAbbr(), report.CompanyID);
                            break;
                        default:
                            throw new ApplicationException("Unknown Report Type Code Specified: " + report.RequestTypeCode);
                    }

                    if (ZipFiles)
                    {
                        addZipEntry(zipOutputStream, reportName, renderedReport);
                    }
                    else
                    {
                        attachmentName = reportName;
                        attachments.Add(new Attachment(new MemoryStream(renderedReport), reportName));
                    }

                    companyName = (string)GetDBAccess().ExecuteScalar("SELECT prcse_FullName FROM PRCompanySearch WITH (NOLOCK) WHERE prcse_CompanyId=" + report.CompanyID);
                }

                if (ZipFiles)
                {
                    attachmentName = "BBOS Business Reports.zip";

                    // Now that we're done building the zip file, mark
                    // it finished and reset the memory stream to the beginning
                    // so the email client can read it.
                    zipOutputStream.Finish();
                    outputMS.Seek(0, SeekOrigin.Begin);
                    attachments.Add(new Attachment(outputMS, Utilities.GetConfigValue("ReportEmailerZipFileName", attachmentName)));
                }
                else
                {
                    if (Reports.Count > 1)
                    {
                        attachmentName = "[multi]";
                    }
                }

                string subject = Utilities.GetConfigValue("ReportEmailerSubject", "Your Blue Book Business Reports Attached");
                if (Reports.Count == 1)
                {
                    subject = string.Format(Utilities.GetConfigValue("ReportEmailerSingleSubject", "BBOS Business Report: {0}"), companyName);
                }

                szEmailBody = GetFormattedEmail(WebUser, subject, szEmailBody);

                //Save each attachment to disk so SQL server mail can get to it
                string szFilePath = (string)GetDBAccess().ExecuteScalar("SELECT Capt_US FROM Custom_Captions WHERE Capt_Family='TempReports' AND Capt_Code='Share'");
                List<string> lstAttachments = new List<string>();

                foreach (Attachment oAttachment in attachments)
                {
                    //Write files to disk
                    string szFileName = Path.Combine(szFilePath, oAttachment.Name);

                    using (var fs = new FileStream(szFileName, FileMode.Create))
                    {
                        oAttachment.ContentStream.CopyTo(fs);
                    }

                    lstAttachments.Add(szFileName);
                }

                if (string.IsNullOrEmpty(Email))
                    Email = WebUser.Email;

                GeneralDataMgr oMgr = new GeneralDataMgr(Logger, WebUser);
                oMgr.SendEmail(Email,
                                EmailUtils.GetFromAddress(),
                                subject,
                                szEmailBody,
                                true,
                                lstAttachments,
                                "ReportEmailer.cs",
                                null);

                GetObjectMgr().InsertCommunicationLog(attachmentName, "Email Purchases", Utilities.GetConfigValue("ReportEmailerSubject", "BBOS Purchases"));
            }
            catch (Exception e)
            {
                Logger.LogError("Error sending email attachments.", e);
            }
            finally
            {
                if (ZipFiles)
                {
                    zipOutputStream.Close();
                }
            }
        }

        protected ReportInterface _oRI;
        /// <summary>
        /// Interfaces with SSRS to generate the business report.
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="requestID"></param>
        /// <param name="requestTypeCode"></param>
        /// <returns></returns>
        protected byte[] GetBusinessReport(string companyID, string requestID, string requestTypeCode)
        {

            if (_oRI == null)
            {
                _oRI = new ReportInterface();
            }

            int nNumber;
            int iReportLevel = int.TryParse(requestTypeCode.Replace("BR", ""), out nNumber) ? nNumber : 4;
            
            // Only supply companies have the balance
            // sheet included when the subject's Financials
            // are not confidential
            bool bIncludeBalanceSheet = false;
            if (WebUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_SUPPLY)
            {
                object oReturn = GetDBAccess().ExecuteScalar("SELECT comp_PRConfidentialFS FROM Company WITH (NOLOCK) WHERE comp_CompanyID=" + companyID);
                if (oReturn == DBNull.Value)
                {
                    bIncludeBalanceSheet = true;
                }
            }

            return _oRI.GenerateBusinessReport(companyID, iReportLevel, bIncludeBalanceSheet, false, Convert.ToInt32(requestID), IsEligibleForEquifaxData, WebUser.prwu_HQID);
        }

        protected IDBAccess _oDBAccess;
        private IDBAccess GetDBAccess()
        {
            if (_oDBAccess == null)
            {
                _oDBAccess = DBAccessFactory.getDBAccessProvider();
            }
            return _oDBAccess;
        }

        protected GeneralDataMgr _oObjectMgr;
        public GeneralDataMgr GetObjectMgr()
        {
            if (_oObjectMgr == null)
            {
                _oObjectMgr = new GeneralDataMgr(Logger, WebUser);
            }

            return _oObjectMgr;
        }

        /// <summary>
        /// Helper function that adds a file in the byte array
        /// into the zip stream.
        /// </summary>
        /// <param name="zipOutputStream"></param>
        /// <param name="fileName"></param>
        /// <param name="renderedReport"></param>
        protected void addZipEntry(ZipOutputStream zipOutputStream, string fileName, byte[] renderedReport)
        {
            ZipEntry zipEntry = new ZipEntry(fileName);
            zipEntry.DateTime = DateTime.Now;
            zipOutputStream.PutNextEntry(zipEntry);
            zipOutputStream.Write(renderedReport, 0, renderedReport.Length);
        }

        private const string SQL_GET_FORMATTED_EMAIL = "SELECT dbo.ufn_GetFormattedEmail(@CompanyID, @PersonID, 0, @Title, @Body, null)";
        virtual protected string GetFormattedEmail(IPRWebUser user, string subject, string text)
        {
            IList parameters = new ArrayList();
            parameters.Add(new ObjectParameter("CompanyID", user.prwu_BBID));
            parameters.Add(new ObjectParameter("PersonID", user.peli_PersonID));
            parameters.Add(new ObjectParameter("Title", subject));
            parameters.Add(new ObjectParameter("Body", text));
            return (string)GetDBAccess().ExecuteScalar(SQL_GET_FORMATTED_EMAIL, parameters);
        }
    }

    /// <summary>
    /// Helper class that communicates the reports and their paramters
    /// that need to be rendered and emailed.
    /// </summary>
    [Serializable]
    public class Report
    {
        public string ReportType;
        public string CompanyID;
        public string RequestID;
        public string RequestTypeCode;

        public Report(string reportType, string companyID, string requestID, string requestTypeCode)
        {
            ReportType = reportType;
            CompanyID = companyID;
            RequestID = requestID;
            RequestTypeCode = requestTypeCode;
        }

    }
}