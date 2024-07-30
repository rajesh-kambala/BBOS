/***********************************************************************
 Copyright Blue Book Services, Inc. 2014-2018

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: ConcordFaxProvider.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;

using System.IO;
using PRCo.BBOS.FaxInterface.ConcordFaxService;
using PRCo.BBOS.FaxInterface.ConcordReportingService;

namespace PRCo.BBOS.FaxInterface
{
    public class ConcordFaxProvider
    {

        public static FaxResult SendFax(string fromUserName, string fromPassword, string notificationEmail,
                                        string toFaxNumber, string toName,
                                        string faxFileName)
        {

            FaxResult faxResult = new FaxResult();
            faxResult.FaxNumber = toFaxNumber;

            using(FaxWS ws = new FaxWS())
            {

                FaxJob jobDetails = new FaxJob();
                jobDetails.JobScheduleStartType = 1;
                jobDetails.NotifyType = 1;
                jobDetails.NotifyDestination = notificationEmail;

                FaxJobRecipient[] recipients = new FaxJobRecipient[1];
                recipients[0] = new FaxJobRecipient();
                recipients[0].RecipName = toName;
                recipients[0].RecipFaxNumber = toFaxNumber; // FaxNumber

                FaxJobFile[] faxFiles = new FaxJobFile[1];
                faxFiles[0] = new FaxJobFile();

                FileStream inputFile = new FileStream(faxFileName, FileMode.Open, FileAccess.Read);
                faxFiles[0].FileData = new Byte[inputFile.Length];
                faxFiles[0].FileIndex = 1; // first file in the list
                faxFiles[0].FileTypeId = GetFileTypeCode(faxFileName);

                inputFile.Read(faxFiles[0].FileData, 0, (int)inputFile.Length); // Read file
                inputFile.Close();

                FaxJobId[] faxJobIdList = null;
                long ttfp = 0;

                WSError wsError = null;

                try
                {

                    if (ws.SendFaxEx(fromUserName, fromPassword, recipients, faxFiles, jobDetails, out faxJobIdList, out ttfp, out wsError))
                    {
                        faxResult.ResultCode = FaxResult.SUCCESS;
                        faxResult.ResultMessage = "Estimated Time To Free Port: " + ttfp;
                        faxResult.FaxID = faxJobIdList[0].JobId;
                        faxResult.TranslateFaxID();
                    }
                    else
                    {
                        faxResult.ResultCode = wsError.ErrorCode;
                        faxResult.ResultMessage = wsError.ErrorString;
                    }

                }
                catch(Exception ex)
                {
                    faxResult.ResultCode = 1;
                    faxResult.ResultMessage = ex.Message;
                    faxResult.FaxException = ex;
                }
            }

            return faxResult;
        }


        public static FaxResult GetFaxStatus(string fromUserName, string fromPassword, string jobID)
        {
            FaxResult faxResult = new FaxResult();

            using (FaxWS ws = new FaxWS())
            {
                WSError wsError = null;

                FaxJobId[] faxJobIds = new FaxJobId[1];
                faxJobIds[0] = new FaxJobId();
                faxJobIds[0].JobId = jobID; // Job id to request status for

                FaxStatus[] faxStatusList = null;

                try
                {

                    if (ws.GetFaxStatus(fromUserName, fromPassword, faxJobIds, out faxStatusList, out wsError))
                    {
                        faxResult.ResultCode = FaxResult.SUCCESS;
                        faxResult.StatusID = faxStatusList[0].FaxJobStatusId;
                        faxResult.StatusMessage = faxStatusList[0].StatusDescription;
                        faxResult.ErrorMessage = faxStatusList[0].Error.ErrorString;
                    }
                    else
                    {
                        faxResult.ResultCode = wsError.ErrorCode;
                        faxResult.ResultMessage = wsError.ErrorString;
                    }

                }
                catch (Exception ex)
                {
                    faxResult.ResultCode = 1;
                    faxResult.ResultMessage = ex.Message;
                    faxResult.FaxException = ex;
                }

            }

            return faxResult;
        }


        public static List<FaxResult> GetFaxResponseReport(string username, string password, int customerID,
                                                           DateTime startDate, DateTime endDate)
        {

            List<FaxResult> faxErrors = new List<FaxResult>();

            using (AccountManagementReportingWebservice ws = new AccountManagementReportingWebservice())
            {
                Authentication auth = new Authentication();
                auth.Username = username;
                auth.Password = password;

                ListOutboundActivityRequest request = new ListOutboundActivityRequest();
                request.Authentication = auth;
                request.CustomerId = customerID;
                request.StartDate = startDate;
                request.EndDate = endDate;
                request.ExcludeSubLevelEntries = false;
                request.Filters = null;
                request.PageSize = 1000;
                request.PageIndex = 1;

                int failureCount = 0;
                bool eof = false;
                while (!eof)
                {

                    ListOutboundActivityResponse response = ws.ListOutboundActivity(request);

                    if (response.OutboundMessageList == null)
                    {
                        break;
                    }

                    foreach (om outboundMsg in response.OutboundMessageList)
                    {
                        if (outboundMsg.stat == "Failed")
                        {
                            FaxResult faxResult = new FaxResult();
                            faxResult.Failed = "Y";
                            faxResult.TranslatedFaxID = outboundMsg.id;

                            if ((faxResult.TranslatedFaxID.EndsWith("-1")) ||
                                (faxResult.TranslatedFaxID.EndsWith("-2")))
                            {

                                faxResult.TranslatedFaxID = faxResult.TranslatedFaxID.Substring(0, (faxResult.TranslatedFaxID.Length - 2));
                            }


                            faxErrors.Add(faxResult);

                            GetOutboundDetailRequest requestDetail = new GetOutboundDetailRequest();
                            requestDetail.Authentication = auth;
                            requestDetail.JobId = outboundMsg.id;

                            GetOutboundDetailResponse responseDetail = ws.GetOutboundDetail(requestDetail);

                            if (responseDetail.OutboundFaxMessage.Length > 0)
                            {

                                faxResult.FailedMsg = responseDetail.OutboundFaxMessage[0].ErrorMessage;

                                string errMsg = responseDetail.OutboundFaxMessage[0].ErrorMessage;
                                string faxNumber = responseDetail.OutboundFaxMessage[0].FaxNumber;

                                //Console.WriteLine(string.Format("Job ID: {0}, Fax Number: {1}, Error Message: {2}", requestDetail.JobId, faxNumber, errMsg));

                                //if (responseDetail.OutboundFaxMessage.Length > 1)
                                //{
                                //    Console.WriteLine(string.Format("Job ID: {0}, Multple Error Messages}", requestDetail.JobId));
                                //}

                            }


                            failureCount++;

                        }
                    }

                    if (response.OutboundMessageList.Length < request.PageSize)
                    {
                        eof = true;
                    }
                    else
                    {
                        request.PageIndex++;
                    }

                    
                }
            }

            return faxErrors;
        }


        /// <summary>
        /// returns the file type based on file extension
        /// </summary>
        /// <param name="filename"></param>
        /// <returns></returns>
        public static int GetFileTypeCode(string filename)
        {
            switch (Path.GetExtension(filename)) {
                case ".doc":
                case ".docx":
                    return 100;
                case ".pdf":
                    return 101;
                case ".rtf":
                    return 102;
                case ".xls":
                case ".xlsx":
                    return 103;
                case ".ppt":
                    return 104;
                case ".txt":
                    return 105;
                case ".html":
                case ".htm":
                    return 111;
                case ".mhtml":
                case ".mht":
                    return 112;
                default:
                    return 1;
            }
        }
    }
}
