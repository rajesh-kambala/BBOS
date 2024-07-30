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
using Microsoft.Win32.SafeHandles;
using Sage.CRM.Controls;
using Sage.CRM.Data;
using Sage.CRM.UI;
using Sage.CRM.Utils;
using System;
using System.IO;    // For StreamReader
using System.Runtime.InteropServices;
using static System.Net.WebRequestMethods;

namespace BBSI.CRM
{
    public class BusinessValuationRequest: CRMBase
    {
        [DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
        public static extern bool LogonUser(String lpszUsername, String lpszDomain, String lpszPassword,
                int dwLogonType, int dwLogonProvider, out SafeAccessTokenHandle phToken);

        public override void BuildContents()
        {
            bDebug = false; 

            try
            {
                SetRequestName("BusinessValuationRequest");

                AddContent(HTML.Form());
                AddContent("<script type='text/javascript' src='/crm/CustomPages/TravantCRMScripts/BusinessValuation.js'></script>");

                string prbv_BusinessValuationID = Dispatch.QueryField("prbv_BusinessValuationID");
                Record recBusinessValuation = FindRecord("PRBusinessValuation", "prbv_BusinessValuationID = " + prbv_BusinessValuationID);

                string prbv_FileName = recBusinessValuation.GetFieldAsString("prbv_FileName");
                string prbv_DiskFileName = recBusinessValuation.GetFieldAsString("prbv_DiskFileName");

                string HiddenIsNewFile = Dispatch.EitherField("HiddenIsNewFile");
                if (HiddenIsNewFile == null)
                    HiddenIsNewFile = "";

                string HiddenValuationEmailAddress = Dispatch.EitherField("HiddenValuationEmailAddress");
                if (HiddenValuationEmailAddress == null)
                    HiddenValuationEmailAddress = "";

                string hMode = Dispatch.EitherField("HiddenMode");
                DEBUG("hMode", hMode, false);

                if (hMode == "Delete")
                {
                    recBusinessValuation.DeleteRecord = true;
                    recBusinessValuation.SaveChanges();

                    Dispatch.Redirect(UrlDotNet(ThisDotNetDll, "RunBusinessValuationRequestListing"));
                    return;
                }

                if (hMode == "SendValuationToRequestor")
                {
                    string sEmail = SendValuationReportEmail(recBusinessValuation.GetFieldAsString("prbv_CompanyID"), recBusinessValuation.GetFieldAsString("prbv_PersonID"));
                    string sEncodedEmail = System.Web.HttpUtility.UrlEncode(sEmail);
                    hMode = "View";

                    recBusinessValuation.SetField("prbv_StatusCode", "S");
                    recBusinessValuation.SetField("prbv_SentDateTime", DateTime.Now);
                    recBusinessValuation.SetField("prbv_ProcessedBy", GetContextInfo("User", "user_userid"));
                    recBusinessValuation.SaveChanges();

                    
                    Dispatch.Redirect(UrlDotNet(ThisDotNetDll, "RunBusinessValuationRequest") + $"&prbv_BusinessValuationID={prbv_BusinessValuationID}&sr=\"{sEncodedEmail}\"");
                    return;
                }

                if (hMode == "SendValuationToEmail")
                {
                    string sEmail = SendValuationReportEmail(recBusinessValuation.GetFieldAsString("prbv_CompanyID"), recBusinessValuation.GetFieldAsString("prbv_PersonID"), HiddenValuationEmailAddress);
                    string sEncodedEmail = System.Web.HttpUtility.UrlEncode(sEmail);
                    hMode = "View";

                    Dispatch.Redirect(UrlDotNet(ThisDotNetDll, "RunBusinessValuationRequest") + $"&prbv_BusinessValuationID={prbv_BusinessValuationID}&sr=\"{sEncodedEmail}\"");
                    return;
                }

                EntryGroup screenBusinessValuationRequest = new EntryGroup("PRBusinessValuation");
                for(int i=0; i<screenBusinessValuationRequest.Count; i++) 
                    screenBusinessValuationRequest[i].ReadOnly = true;

                if (hMode == "Save")
                {
                    screenBusinessValuationRequest.Fill(recBusinessValuation);
                    recBusinessValuation.SaveChanges();

                    if (HiddenIsNewFile != "")
                    {
                        ProcessFile(recBusinessValuation);
                    }

                    Dispatch.Redirect(UrlDotNet(ThisDotNetDll, "RunBusinessValuationRequest") + $"&prbv_BusinessValuationID={prbv_BusinessValuationID}");
                    return;
                }

                if (string.IsNullOrEmpty(hMode))
                {
                    hMode = "View";
                }

                if (hMode == "Change")
                {
                    screenBusinessValuationRequest.GetHtmlInEditMode(recBusinessValuation);
                }
                else if (hMode == "View")
                {
                    screenBusinessValuationRequest.GetHtmlInViewMode(recBusinessValuation);
                }

                screenBusinessValuationRequest.Title = "Business Valuation Request Details";

                VerticalPanel vpMainPanel = new VerticalPanel();
                vpMainPanel.AddAttribute("width", "100%");
                vpMainPanel.Add(screenBusinessValuationRequest);
                AddContent(vpMainPanel);

                AddContent(HTML.InputHidden("HiddenMode", string.Empty));
                AddContent(HTML.InputHidden("HiddenIsNewFile", HiddenIsNewFile));
                AddContent(HTML.InputHidden("HiddenValuationEmailAddress", string.Empty));

                if (hMode == "Change")
                    AddButtonContent(BuildDragAndDrop_SimpleDragDroppedCallback());

                string statusCode = recBusinessValuation.GetFieldAsString("prbv_StatusCode");

                //Add Buttons
                if (hMode == "View")
                {
                    AddUrlButton("Continue", "Continue.gif", UrlDotNet(ThisDotNetDll, "RunBusinessValuationRequestListing"));
                    if (statusCode != "S")
                    {
                        if (statusCode != "P")
                            AddUrlButton("Upload Business Valuation", "Save.gif", "javascript:change_button();");

                        AddUrlButton("Delete", "Delete.gif", "javascript:businessValuationConfirmDelete();");
                    }

                    if (recBusinessValuation.GetFieldAsString("prbv_FileName") != "")
                    {
                        //Display button to send the valuation to the customer.
                        AddUrlButton("Send Valuation to Requestor", "Email.gif", "javascript:sendValuationToRequestor();");

                        //Display button to send the valuation to a different email address.  Prompt for the email address to send it to.
                        AddUrlButton("Send Valuation to Another Email", "Email.gif", "javascript:sendValuationToEmail();");
                    }
                }
                else if (hMode == "Change")
                {
                    AddUrlButton("Save", "Save.gif", "javascript:save_button();");
                    AddUrlButton("Cancel", "cancel.gif", UrlDotNet(ThisDotNetDll, "RunBusinessValuationRequest") + $"&prbv_BusinessValuationID={prbv_BusinessValuationID}");
                }

                //Files
                AddFilePanel(prbv_BusinessValuationID);

                //Business Valuation
                if(prbv_DiskFileName != "")
                    AddBusinessValuationPanel(prbv_BusinessValuationID, prbv_FileName, prbv_DiskFileName);

                AddContent("<script>document.getElementById('EWARE_TOP').style='display:none;';</script>");

                string sentRequestEmail = Dispatch.EitherField("sr");
                if (!string.IsNullOrEmpty(sentRequestEmail))
                {
                    AddContent($"<script>alert('The Business Valuation email has been sent to {sentRequestEmail}.');</script>");
                }
            }
            catch (Exception eX)
            {
                TravantLogMessage(eX.Message);
                AddContent(HandleException(eX));
            }
        }

        const string SQL_GET_LIBRARY_FILES = @"SELECT Library.Libr_FilePath, Libr_FileName, Libr_Note, libr_communicationId, libr_PRFileId, cmli_comm_companyid FROM Communication 
                    INNER JOIN Comm_Link ON cmli_comm_CommunicationId = comm_CommunicationId
	                INNER JOIN Library ON libr_communicationid = Comm_CommunicationId
                    WHERE comm_PRCategory='SS' AND comm_PRSubcategory='BV' AND comm_PRFileId={0}";
        private void AddFilePanel(string prbv_BusinessValuationID)
        {
            VerticalPanel vpFiles = new VerticalPanel();
            vpFiles.AddAttribute("width", "100%");

            QuerySelect recFiles = new QuerySelect();
            recFiles.SQLCommand = string.Format(SQL_GET_LIBRARY_FILES, prbv_BusinessValuationID);

            TravantLogMessage($"recFiles.SQLCommand = {recFiles.SQLCommand}");
            recFiles.ExecuteReader();

            string fileContent = "<table border=\"0\">";
            fileContent += "<tr><th>FileName</th><th>&nbsp</th><th>Notes</th></tr>";

            while (!recFiles.Eof())
            {
                string sFileNameAndPath = $"{recFiles.FieldValue("libr_FilePath")}/{recFiles.FieldValue("libr_FileName")}";
                string sEncodedFileName = System.Web.HttpUtility.UrlEncode(sFileNameAndPath);
                string sSID = Dispatch.QueryField("SID");
                string sCompanyID = recFiles.FieldValue("cmli_comm_companyid");

                string sURL = $"/crm/eware.dll/do/{sEncodedFileName}?SID={sSID}&Act=1282&Mode=0&CLk=T&Key0=1&Key1={sCompanyID}&func=baseUrl&FileName={sEncodedFileName}";

                fileContent += "<tr>";
                fileContent += $"<td><span class=\"VIEWBOXCAPTION\"><a href=\"{sURL}\" target=\"_blank\">{recFiles.FieldValue("libr_FileName")}</a></span><br/><span class=\"VIEWBOX\"></span></td>";
                fileContent += $"<td>&nbsp;</td>";
                fileContent += $"<td>{recFiles.FieldValue("libr_Note")}</span></td>";
                fileContent += "</tr>";
                recFiles.Next();
            }

            fileContent += "</table>";
            ContentBox cbFiles = new ContentBox();
            cbFiles.Title = $"<strong>User Submitted Files</strong><br/>";
            cbFiles.Inner = new HTMLString(fileContent);

            vpFiles.Add(cbFiles);
            AddContent(vpFiles.ToHtml());
        }

        private void AddBusinessValuationPanel(string prbv_BusinessValuationID, string prbv_FileName, string prbv_DiskFileName)
        {
            VerticalPanel vpFiles = new VerticalPanel();
            vpFiles.AddAttribute("width", "100%");

            string fileContent = "<table border=\"0\">";
            fileContent += "<tr><th>\r\nBusiness Valuation Filename:</th><th>&nbsp</th></tr>";

            string sURL = string.Format("{0}Campaigns/BusinessValuations/{1}/{2}", GetBBOSURL(), prbv_BusinessValuationID, prbv_DiskFileName);

            fileContent += "<tr>";
            fileContent += $"<td><span class=\"VIEWBOXCAPTION\"><a href=\"{sURL}\" target=\"_blank\">{prbv_FileName}</a></span><br/><span class=\"VIEWBOX\"></span></td>";
            fileContent += "</tr>";

            fileContent += "</table>";
            ContentBox cbFiles = new ContentBox();
            cbFiles.Title = $"<strong>Business Valuation Files</strong><br/>";
            cbFiles.Inner = new HTMLString(fileContent);

            vpFiles.Add(cbFiles);
            AddContent(vpFiles.ToHtml());
        }

        private void ProcessFile(Record recBusinessValuation)
        {
            string prbv_FileName = Dispatch.EitherField("_HIDDENprbv_filename");
            string prbv_DiskFileName = prbv_FileName;

            if (!string.IsNullOrEmpty(prbv_DiskFileName))
            {
                string szEmailType = "BusinessValuations";
                string szBusinessValuationID = recBusinessValuation.GetFieldAsString("prbv_BusinessValuationID");

                // Move our file from the temp area to the email image area
                string sourceFile = Path.Combine(TEMP_FILE_PATH, prbv_FileName);
                string targetFolder = Path.Combine(TEMP_FILE_PATH, szEmailType, szBusinessValuationID);

                //CHW created a BBSMonitor process FileMoveEvent that moves the files every 5 minutes, to circumvent a QA file permissions issue creating the folders at runtime
                //Be sure folder structure in D:\Applications\CRM\WWWRoot\TempReports\BusinessValuations is up to date to be moved every 5 minutes
                //FileMoveEvent.cs does the move
                string szMovedFileName = MoveFile(sourceFile, targetFolder, bForceUniqueFileName: false, bDebug: true);

                recBusinessValuation.SetField("prbv_DiskFileName", szMovedFileName);
                recBusinessValuation.SaveChanges();
            }
        }

        protected string SendValuationReportEmail(string CompanyID, string PersonID, string OverrideEmailAddress = null)
        {
            string personEmail;
            string personName;
            string prwu_Culture = "en-us";

            QuerySelect recPersonInfo = GetQuery();
            recPersonInfo.SQLCommand = $"SELECT emai_EmailAddress, dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, NULL, pers_Suffix) as PersonName, prwu_Culture FROM PRWebUser WITH(NOLOCK) INNER JOIN Person_Link WITH(NOLOCK) ON prwu_PersonLinkID = PeLi_PersonLinkId INNER JOIN Person ON Pers_PersonId = PeLi_PersonId INNER JOIN vPersonEmail ON Pers_PersonId = ELink_RecordID WHERE ELink_RecordID={PersonID} AND emai_CompanyID={CompanyID}";
            recPersonInfo.ExecuteReader();
            personEmail = recPersonInfo.FieldValue("emai_EmailAddress");
            personName = recPersonInfo.FieldValue("PersonName");
            prwu_Culture = recPersonInfo.FieldValue("prwu_Culture");

            if (!string.IsNullOrEmpty(OverrideEmailAddress))
            {
                personEmail = OverrideEmailAddress;
                personName = OverrideEmailAddress;
            }

            string szLanguage = "Capt_US";
            if (prwu_Culture.ToLower() == "es-mx")
                szLanguage = "Capt_ES";

            string BBOS_URL = GetCustomCaptionValue("Choices", "BBOS", "URL") + "MembershipSummary.aspx";

            string subject = GetCustomCaptionValue("Choices", "SendValuationReport", "Subject", szLanguage);
            string body = GetCustomCaptionValue("Choices", "SendValuationReport", "Body", szLanguage);
            body = string.Format(body, BBOS_URL);

            string formattedEmail = GetFormattedEmail(Convert.ToInt32(CompanyID), Convert.ToInt32(PersonID), subject, body, personName, prwu_Culture, "");
            formattedEmail = formattedEmail.Replace("'", "''");

            QuerySelect createEmail = GetQuery();
            createEmail.SQLCommand = $"usp_CreateEmail @Subject='{subject}', @Content='{formattedEmail}', @DoNotRecordCommunication='1', @Source='Send Business Valuation', @Content_Format='HTML', @To='{personEmail}', @Action='EmailOut'";
            createEmail.ExecuteNonQuery();

            return personEmail;
        }
    }
}
