/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, LLC. 2024

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written permission of Blue Book Services, LLC is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Blue Book Services, LLC.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Text;
using System.Net.Http;
using System.Net;
using System.IO;    // For StreamReader
using Sage.CRM.Blocks;
using Sage.CRM.Controls;
using Sage.CRM.Data;
using Sage.CRM.HTML;
using Sage.CRM.Utils;
using Sage.CRM.WebObject;
using Sage.CRM.UI;
using System.Data.SqlClient;
using System.Runtime.InteropServices;
using System.Security;
using System.Security.Principal;
using Microsoft.Win32.SafeHandles;

namespace BBSI.CRM
{
    public class BackgroundCheckRequest: CRMBase
    {
        [DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
        public static extern bool LogonUser(String lpszUsername, String lpszDomain, String lpszPassword,
                int dwLogonType, int dwLogonProvider, out SafeAccessTokenHandle phToken);

        public override void BuildContents()
        {
            bDebug = false;

            try
            {
                SetRequestName("BackgroundCheckRequest");

                AddContent(HTML.Form());
                AddContent("<script type='text/javascript' src='/crm/CustomPages/TravantCRMScripts/BackgroundCheck.js'></script>");

                string prbcr_BackgroundCheckRequestID = Dispatch.QueryField("prbcr_BackgroundCheckRequestID");
                Record recBackgroundCheckRequest = FindRecord("PRBackgroundCheckRequest", "prbcr_BackgroundCheckRequestID = " + prbcr_BackgroundCheckRequestID);

                string hMode = Dispatch.EitherField("HiddenMode");
                if (hMode == "Delete")
                {
                    recBackgroundCheckRequest.DeleteRecord = true;
                    recBackgroundCheckRequest.SaveChanges();

                    Dispatch.Redirect(UrlDotNet(ThisDotNetDll, "RunBackgroundCheckRequestListing"));
                    return;
                }

                if (hMode == "SendBackgroundCheck")
                {
                    SendBusinessReport(recBackgroundCheckRequest.GetFieldAsString("prbcr_RequestingCompanyID"), recBackgroundCheckRequest.GetFieldAsString("prbcr_RequestingPersonD"), recBackgroundCheckRequest.GetFieldAsString("prbcr_SubjectCompanyID"));
                    hMode = "View";

                    recBackgroundCheckRequest.SetField("prbcr_StatusCode", "S");
                    recBackgroundCheckRequest.SetField("prbcr_SentDateTime", DateTime.Now);
                    recBackgroundCheckRequest.SetField("prbcr_ProcessedBy", GetContextInfo("User", "user_userid"));
                    recBackgroundCheckRequest.SaveChanges();
                    Dispatch.Redirect(UrlDotNet(ThisDotNetDll, "RunBackgroundCheckRequestListing") + $"&sr={prbcr_BackgroundCheckRequestID}");
                    return;
                }


                EntryGroup screenBackgroundCheckRequest = new EntryGroup("PRBackgroundCheckRequest");

                if (hMode == "Save")
                {
                    screenBackgroundCheckRequest.Fill(recBackgroundCheckRequest);
                    recBackgroundCheckRequest.SaveChanges();
                    Dispatch.Redirect(UrlDotNet(ThisDotNetDll, "RunBackgroundCheckRequestListing"));
                    return;
                }

                if (string.IsNullOrEmpty(hMode))
                    hMode = "View";

                screenBackgroundCheckRequest.Title = "Background Request Details";
                screenBackgroundCheckRequest.GetHtmlInViewMode(recBackgroundCheckRequest);
    
                VerticalPanel vpMainPanel = new VerticalPanel();
                vpMainPanel.AddAttribute("width", "100%");
                vpMainPanel.Add(screenBackgroundCheckRequest);
                AddContent(vpMainPanel);

                AddContent(HTML.InputHidden("HiddenMode", string.Empty));

                string statusCode = recBackgroundCheckRequest.GetFieldAsString("prbcr_StatusCode");

                //Add Buttons
                if (hMode == "View")
                {
                    AddUrlButton("Continue", "Continue.gif", UrlDotNet(ThisDotNetDll, "RunBackgroundCheckRequestListing"));

                    if ((statusCode == "IP") || (statusCode == "P"))
                    {
                        AddUrlButton("Create Background Check", "Email.gif", UrlDotNet(ThisDotNetDll, "RunBackgroundCheck") + $"&prbc_BackgroundCheckID=0&prbc_SubjectCompanyID={recBackgroundCheckRequest.GetFieldAsString("prbcr_SubjectCompanyID")}&prbcr_BackgroundCheckRequestID={prbcr_BackgroundCheckRequestID}");
                        AddUrlButton("Send Business Report with Background Check", "Email.gif", "javascript:sendBusinessReport();");
                    }

                    if (statusCode != "S")
                        AddUrlButton("Delete", "Delete.gif", "javascript:delete_button();");
                }

                VerticalPanel vpBackgroundChecks = new VerticalPanel();
                vpBackgroundChecks.AddAttribute("width", "100%");
                vpBackgroundChecks.Add(BuildBackgroundCheckGrid(prbcr_BackgroundCheckRequestID, recBackgroundCheckRequest.GetFieldAsString("prbcr_SubjectCompanyID"), "prbc_BackgroundCheckDate", true));
                AddContent(vpBackgroundChecks.ToHtml());
                AddContent(HTML.InputHidden("HIDDENORDERBY", _sortBy));
                AddContent(HTML.InputHidden("HIDDENORDERBYDESC", _sortDesc));

                AddContent("<script>document.getElementById('EWARE_TOP').style='display:none;';</script>");

            }
            catch (Exception eX)
            {
                TravantLogMessage(eX.Message);
                AddContent(HandleException(eX));
            }
        }

        private void MoveFile(string source, string target)
        {
            const int LOGON32_PROVIDER_DEFAULT = 0;
            //This parameter causes LogonUser to create a primary token.   
            const int LOGON32_LOGON_INTERACTIVE = 2;

            // Call LogonUser to obtain a handle to an access token.   
            SafeAccessTokenHandle safeAccessTokenHandle;
            bool returnValue = LogonUser("rsuser", "Enterprise", "rs_1901",
                LOGON32_LOGON_INTERACTIVE, LOGON32_PROVIDER_DEFAULT,
                out safeAccessTokenHandle);

            if (false == returnValue)
            {
                int ret = Marshal.GetLastWin32Error();
                throw new System.ComponentModel.Win32Exception(ret);
            }

            WindowsIdentity.RunImpersonated(
                safeAccessTokenHandle,
                // User action  
                () =>
                {
                    if (File.Exists(target))
                        File.Delete(target);

                    File.Move(source, target);
                }
                );
        }

        protected ContentBox BuildBackgroundCheckGrid(string prbcr_BackgroundCheckRequestID, string subjectCompanyID, string defaultSortField, bool defaultSortDesc)
        {
            ContentBox cbGrid = new ContentBox();
            StringBuilder pageBuffer = new StringBuilder();

            string _sortBy = Dispatch.ContentField("HIDDENORDERBY");
            if (string.IsNullOrEmpty(_sortBy))
                _sortBy = defaultSortField;

            string sortDesc = Dispatch.ContentField("HIDDENORDERBYDESC");
            if (string.IsNullOrEmpty(sortDesc))
            {
                // These get swapped below, so
                // reverse them here.
                if (defaultSortDesc)
                    sortDesc = "FALSE";
                else
                    sortDesc = "TRUE";
            }

            string sortOrder = null;
            if (sortDesc == "TRUE")
            {
                _sortDesc = "FALSE";
                sortOrder = "ASC";
            }
            else
            {
                _sortDesc = "TRUE";
                sortOrder = "DESC";
            }

            StringBuilder displayTable = new StringBuilder(HTML.StartTable() + "\n");
            displayTable.Append("<thead>");
            displayTable.Append("<tr>");
            displayTable.Append(BuildColumnHeader(string.Empty, string.Empty));
            displayTable.Append(BuildColumnHeader("prbc_BackgroundCheckDate", "Created Date / Time", true, _sortBy, _sortDesc));
            displayTable.Append(BuildColumnHeader("comp_Name", "Subject Company", true, _sortBy, _sortDesc));
            displayTable.Append(BuildColumnHeader("Pers_FullName", "Subject Person", true, _sortBy, _sortDesc));
            displayTable.Append(BuildColumnHeader("UserName", "User"));
            displayTable.Append("</tr>");
            displayTable.Append("</thead>");
            displayTable.Append("<tbody>");

            string rowClass = "ROW1";
            int recordCount = 0;

            QuerySelect recBackgroundChecks = GetQuery();
            recBackgroundChecks.SQLCommand = $"SELECT * FROM vPRBackgroundCheck WHERE prbc_SubjectCompanyID = {subjectCompanyID} ORDER BY {_sortBy} {sortOrder}";

            //TravantLogMessage($"{recBackgroundChecks.SQLCommand}");
            recBackgroundChecks.ExecuteReader();

            while (!recBackgroundChecks.Eof())
            {
                recordCount++;

                int prbc_BackgroundCheckID = Convert.ToInt32(recBackgroundChecks.FieldValue("prbc_BackgroundCheckID"));
                DateTime prbc_BackgroundCheckDate = recBackgroundChecks.FieldValueAsDate("prbc_BackgroundCheckDate");
                string companyName = recBackgroundChecks.FieldValue("comp_Name");
                string companyURL = Url("200") + $"&Key0=1&Key1={subjectCompanyID}";
                string listingLocation = recBackgroundChecks.FieldValue("CityStateCountryShort");

                int personID = 0;
                if (!string.IsNullOrEmpty(recBackgroundChecks.FieldValue("Pers_PersonId")))
                    personID = Convert.ToInt32(recBackgroundChecks.FieldValue("Pers_PersonId"));
                string personName = recBackgroundChecks.FieldValue("Pers_FullName");
                string user = recBackgroundChecks.FieldValue("UserName");

                string personURL = Url("220") + $"&key0=2&key2={personID}";

                if (rowClass == "ROW1")
                    rowClass = "ROW2";
                else
                    rowClass = "ROW1";

                displayTable.Append("<tr>");
                displayTable.Append($"<td class=\"{rowClass}\" align=\"center\"><input type=radio value={prbc_BackgroundCheckID} name=rbBackgroundCheck style=rbBackgroundCheck></td>");
                displayTable.Append($"<td class=\"{rowClass}\"><a href=\"{UrlDotNet(ThisDotNetDll, "RunBackgroundCheck")}&Key0=1&Key1={subjectCompanyID}&prbc_BackgroundCheckID={prbc_BackgroundCheckID}&prbcr_BackgroundCheckRequestID={prbcr_BackgroundCheckRequestID}\">{prbc_BackgroundCheckDate:MM/dd/yyyy<br/>h:mm tt}</a></td>");
                displayTable.Append($"<td class=\"{rowClass}\"><a href=\"{companyURL}\">{companyName}</a></td>");
                //displayTable.Append($"<td class=\"{rowClass}\">{listingLocation}</td>");

                displayTable.Append($"<td class=\"{rowClass}\"><a href=\"{personURL}\">{personName}</a></td>");
                displayTable.Append($"<td class=\"{rowClass}\">{user}</td>");
                displayTable.Append("</tr>\n");

                recBackgroundChecks.Next();
            }
            displayTable.Append("</tbody>");
            displayTable.Append("</table>\n");

            pageBuffer.Append(displayTable);

            cbGrid.Title = $"<strong>{recordCount:###,##0} backgound checks found.</strong><br/>";
            cbGrid.Inner = new HTMLString(pageBuffer.ToString());

            return cbGrid;
        }

        protected void SendBusinessReport(string requestingCompanyID, string requestingPersonID, string subjectCompanyID)
        {
            string reportServerURL = GetCustomCaptionValue("Choices", "SSRS", "URL");
            string reportURL = $"{reportServerURL}/BusinessReport/BusinessReport&rc:Parameters=false&rs:Format=PDF&CompanyID={subjectCompanyID}&RequestingCompanyID={requestingCompanyID}&ReportLevel=3&IncludeBalanceSheet=false&IncludeSurvey=false&RequestID=0&IncludeEquifaxData=false&IncludeBackgroundCheckData=true";

            string fileName = $"Blue Book ID {subjectCompanyID} Background Check.pdf";

            string targetFolder = GetCustomCaptionValue("Choices", "TempReports", "Share");
            string targetfileName = $"{targetFolder}\\{fileName}";

            string localFolder = @"D:\Applications\CRM\WWWRoot\TempReports";
            string localfileName = $"{localFolder}\\{fileName}";

            using (WebClient webClient = new WebClient())
            {
                webClient.Credentials = new NetworkCredential("rsuser", "rs_1901");
                webClient.DownloadFile(reportURL, localfileName);
            }

            //TravantLogMessage($"localfileName={localfileName}");

            MoveFile(localfileName, targetfileName);

            QuerySelect recPersonEmail = GetQuery();
            recPersonEmail.SQLCommand = $"SELECT emai_EmailAddress FROM vPRPersonEmail WHERE ELink_RecordID={requestingPersonID} AND emai_CompanyID={requestingCompanyID}";
            recPersonEmail.ExecuteReader();
            string personEmail = recPersonEmail.FieldValue("emai_EmailAddress");

            string subject = GetCustomCaptionValue("Choices", "PurchaseBR", "Subject");
            string body = GetCustomCaptionValue("Choices", "PurchaseBR", "Body2");
            string formattedEmail = GetFormattedEmail(Convert.ToInt32(requestingCompanyID), Convert.ToInt32(requestingPersonID), subject, body, personEmail, "en-us", "");
            formattedEmail = formattedEmail.Replace("'", "''");

            string sqlReportsFolder = @"D:\Applications\TempReports\";


            QuerySelect createEmail = GetQuery();
            createEmail.SQLCommand = $"usp_CreateEmail @Subject='{subject}', @Content='{formattedEmail}', @DoNotRecordCommunication='1', @Source='Send Background Check', @Content_Format='HTML', @To='{personEmail}', @Action='EmailOut', @AttachmentFileName='{Path.Combine(sqlReportsFolder, fileName)}'";
            createEmail.ExecuteNonQuery();
        }
    }
}
