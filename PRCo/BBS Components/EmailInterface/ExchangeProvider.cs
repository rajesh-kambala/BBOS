/***********************************************************************
 Copyright Blue Book Services, Inc. 2014-2016

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: ExchangeProvider.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.IO;

using System.Text.RegularExpressions;
using System.Xml;
using Microsoft.Exchange.WebServices.Data;

using TSI.Utils;

namespace PRCo.BBOS.EmailInterface
{
    public class ExchangeProvider
    {

        private const string MatchEmailPattern =
                   @"(([\w-]+\.)+[\w-]+|([a-zA-Z]{1}|[\w-]{2,}))@"
                   + @"((([0-1]?[0-9]{1,2}|25[0-5]|2[0-4][0-9])\.([0-1]?[0-9]{1,2}|25[0-5]|2[0-4][0-9])\."
                     + @"([0-1]?[0-9]{1,2}|25[0-5]|2[0-4][0-9])\.([0-1]?[0-9]{1,2}|25[0-5]|2[0-4][0-9])){1}|"
                   + @"([a-zA-Z]+[\w-]+\.)+[a-zA-Z]{2,4})";

        public static List<EmailResult> GetBouncedMessages(string userName, string userPassword, string publicFolderName,
                                                    DateTime startDate, DateTime endDate)
        {
            List<EmailResult> eamilResults = new List<EmailResult>();

            ExchangeService service = new ExchangeService(ExchangeVersion.Exchange2013_SP1);

            // Optional flags to indicate the requests and responses to trace.
            //service.TraceListener = new TraceListener();
            //service.TraceFlags = TraceFlags.EwsRequest | TraceFlags.EwsResponse;
            //service.TraceEnabled = true;

            service.Credentials = new WebCredentials(userName, userPassword);
            service.AutodiscoverUrl(userName, RedirectionUrlValidationCallback);

            FolderView folderView = new FolderView(500);
            SearchFilter searchFilterByFolderName = new SearchFilter.ContainsSubstring(FolderSchema.DisplayName, publicFolderName);
            FindFoldersResults findFolderResults = service.FindFolders(WellKnownFolderName.PublicFoldersRoot, searchFilterByFolderName, folderView);

            Folder targetFolder = null;

            //find specific folder
            foreach (Folder f in findFolderResults)
            {
                if (f.DisplayName == publicFolderName)
                {
                    f.Load();
                    targetFolder = f;
                    break;
                }
            }

            if (targetFolder == null)
            {
                throw new ApplicationException("Unable to find specified public folder: " + publicFolderName);
            }


            PropertySet _customPropertySet = new PropertySet(BasePropertySet.FirstClassProperties, AppointmentSchema.MyResponseType, AppointmentSchema.IsMeeting, AppointmentSchema.ICalUid);
            _customPropertySet.RequestedBodyType = BodyType.Text;


            targetFolder.Load();

            ItemView view = new ItemView(Int32.MaxValue);

            SearchFilter greaterthanfilter = new SearchFilter.IsGreaterThanOrEqualTo(ItemSchema.DateTimeReceived, startDate );
            SearchFilter lessthanfilter = new SearchFilter.IsLessThan(ItemSchema.DateTimeReceived, endDate);
            SearchFilter filter = new SearchFilter.SearchFilterCollection(LogicalOperator.And, greaterthanfilter, lessthanfilter);


            FindItemsResults<Item> findResults = targetFolder.FindItems(filter, view);

            foreach (EmailMessage mailMessage in findResults)
            {
                // We want the text representation of the body, not the 
                // HTML version.
                PropertySet psPropset = new PropertySet();
                psPropset.RequestedBodyType = BodyType.Text;
                psPropset.BasePropertySet = BasePropertySet.FirstClassProperties;
                EmailMessage mailMessage2 = EmailMessage.Bind(service, mailMessage.Id, psPropset);

                //mailMessage.Load();

                if (Utilities.GetBoolConfigValue("ExchangeProviderWriteEmailToDiskEnabled", false))
                {
                    object[] displayArgs = new object[] {
                                mailMessage2.DateTimeSent,
                                mailMessage2.DateTimeReceived,
                                mailMessage2.Subject,
                                mailMessage2.Sender.Address,
                                mailMessage2.DisplayTo,
                                mailMessage2.ToRecipients.Count > 0 ? mailMessage2.ToRecipients[0] : string.Empty,
                                mailMessage2.HasAttachments,
                                mailMessage2.Body};

                    string tempName = mailMessage2.DisplayTo.Replace('/', '_');
                    string emailFileName = Path.Combine(Utilities.GetConfigValue("ExchangeProviderWriteEmailToDiskPath"), tempName + ".txt");

                    int fileCount = 1;

                    while (File.Exists(emailFileName))
                    {
                        fileCount++;
                        emailFileName = Path.Combine(Utilities.GetConfigValue("ExchangeProviderWriteEmailToDiskPath"), mailMessage2.DisplayTo + "_" + fileCount.ToString() + ".txt");
                    }

                    using (StreamWriter enailFile = new System.IO.StreamWriter(emailFileName))
                    {
                        enailFile.WriteLine(string.Format("{0},{1},{2},{3},{4},{5},{7}", displayArgs));
                    }
                }

                EmailResult emailResult = new EmailResult();
                emailResult.FromAddress = mailMessage2.Sender.Address;
                emailResult.ToAddress = Find("To: ", mailMessage2.Body);
                emailResult.Subject = Find("Subject: ", mailMessage2.Body);

                string sendDateTime = Find("Date: ", mailMessage2.Body);
                DateTime.TryParse(sendDateTime, out emailResult.SentDateTime);
                if (emailResult.SentDateTime == DateTime.MinValue)
                    emailResult.SentDateTime = mailMessage2.DateTimeSent;

                emailResult.ErrorMessage = FindErrorMsg(mailMessage2.Body);
                if (string.IsNullOrEmpty(emailResult.ToAddress))
                    emailResult.ToAddress = Find("RCPT To:", mailMessage2.Body);

                // If we still don't have a "To" address, search the body text for any email
                // address excluding the BBSI email addresses.
                if ((string.IsNullOrEmpty(emailResult.ToAddress)) &&
                    (!string.IsNullOrEmpty(mailMessage2.Body)))
                {
                    Regex rx = new Regex(MatchEmailPattern, RegexOptions.Compiled | RegexOptions.IgnoreCase);
                    MatchCollection matches = rx.Matches(mailMessage2.Body);
                    foreach (Match match in matches)
                    {
                        if (!match.ToString().ToLower().EndsWith("@bluebookservices.com"))
                        {
                            emailResult.ToAddress = match.ToString();
                            break;
                        }
                    }

                }

                emailResult.PrepareResult();
                eamilResults.Add(emailResult);
            }

            return eamilResults;
        }


        private static void IsBounceBack(EmailResult emailResult)
        {
            if (!string.IsNullOrEmpty(emailResult.FromAddress))
            {
                if (emailResult.FromAddress.ToLower().StartsWith("postmaster@"))
                {
                    emailResult.IsBouncedEmail = true;
                    return;
                }

                if (emailResult.FromAddress.ToLower().StartsWith("mailer-daemon@"))
                {
                    emailResult.IsBouncedEmail = true;
                    return;
                }
            }

            if (!string.IsNullOrEmpty(emailResult.ErrorMessage))
            {
                emailResult.IsBouncedEmail = true;
                return;
            }

        }


        private static string Find(string prefix, string text)
        {
            return Find(prefix, text, true);
        }

        private static string Find(string prefix, string text, bool addNewLine)
        {
            if (string.IsNullOrEmpty(text))
            {
                return null;
            }

            string tmpWork = prefix;

            if (addNewLine)
            {
                tmpWork = Environment.NewLine + prefix;
            }

            int startPos = text.IndexOf(tmpWork);
            if (startPos == -1)
            {
                return null;
            }

            startPos += tmpWork.Length;
            int endPos = text.IndexOf(Environment.NewLine, startPos);

            return text.Substring(startPos, endPos - startPos);
        }


        private static List<string> _errMsgs = new List<string>();

        private static string FindErrorMsg(string text)
        {
            if (string.IsNullOrEmpty(text))
            {
                return null;
            }

            string errMsg = Find("Reason: ", text);
            if (!string.IsNullOrEmpty(errMsg))
            {
                return errMsg;
            }

            errMsg = Find("Remote Server returned ", text);
            if (!string.IsNullOrEmpty(errMsg))
            {
                return errMsg;
            }

            errMsg = Find("Remote host said: ", text);
            if (!string.IsNullOrEmpty(errMsg))
            {
                return errMsg;
            }

            _errMsgs.Add("does not exist");
            _errMsgs.Add("mailbox is full");
            _errMsgs.Add("user is over quota");
            _errMsgs.Add("mailbox unavailable");
            _errMsgs.Add("Maximum hop count exceeded");
            _errMsgs.Add("There is no one at this address");
            _errMsgs.Add("the user's mailfolder is full");
            _errMsgs.Add("Message rejected");

            string work = text.ToLower();
            foreach (string errMsg2 in _errMsgs)
            {
                if (work.IndexOf(errMsg2.ToLower()) > 0)
                {
                    return errMsg2;
                }
            }


            errMsg = Find("550 ", text, false);
            if (!string.IsNullOrEmpty(errMsg))
            {
                return errMsg;
            }


            return null;
        }

        private static bool RedirectionUrlValidationCallback(string redirectionUrl)
        {
            // The default for the validation callback is to reject the URL.
            bool result = false;

            Uri redirectionUri = new Uri(redirectionUrl);

            // Validate the contents of the redirection URL. In this simple validation
            // callback, the redirection URL is considered valid if it is using HTTPS
            // to encrypt the authentication credentials. 
            if (redirectionUri.Scheme == "https")
            {
                result = true;
            }
            return result;
        }


    }


    class TraceListener : ITraceListener
    {
        #region ITraceListener Members

        public void Trace(string traceType, string traceMessage)
        {
            CreateXMLTextFile(traceType, traceMessage.ToString());
        }

        #endregion

        private void CreateXMLTextFile(string fileName, string traceContent)
        {
            // Create a new XML file for the trace information.
            try
            {
                // If the trace data is valid XML, create an XmlDocument object and save.
                XmlDocument xmlDoc = new XmlDocument();
                xmlDoc.Load(traceContent);
                xmlDoc.Save(fileName + ".xml");
            }
            catch
            {
                // If the trace data is not valid XML, save it as a text document.
                System.IO.File.WriteAllText(fileName + ".txt", traceContent);
            }
        }
    }
}
