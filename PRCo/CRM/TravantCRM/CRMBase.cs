/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, Inc. 2020-2024

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written permission of Blue Book Services, Inc.  is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Blue Book Services, Inc.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Text;

using Sage.CRM.Blocks;
using Sage.CRM.Controls;
using Sage.CRM.Data;
using Sage.CRM.HTML;
using Sage.CRM.Utils;
using Sage.CRM.WebObject;
using Sage.CRM.UI;

using TSI.Utils;
using System.IO;

namespace BBSI.CRM
{
    public class CRMBase : Web
    {
        public const string TEMP_FILE_PATH = @"D:\Applications\CRM\WWWRoot\TempReports";
        protected bool _bDebug = false;

        public override void BuildContents()
        {
            throw new NotImplementedException();
        }

        public bool bDebug
        {
            set { _bDebug = value; }
            get { return _bDebug; }
        }

        protected void DEBUG(string sMessage, bool blnLogAlso = false)
        {
            if (_bDebug)
            {
                string szMsg = $"<p>DEBUG: {sMessage}</p>";
                AddContent(szMsg);
                if(blnLogAlso)
                    TravantLogMessage("DEBUG: " + sMessage);
            }
        }
        protected void DEBUG(string sField, string sMessage, bool blnLogAlso = false)
        {
            if (_bDebug)
            {
                string szMsg = $"<p>DEBUG: {sField} = {sMessage}</p>";
                AddContent(szMsg);
                if(blnLogAlso)
                    TravantLogMessage("DEBUG: " + sMessage);
            }
        }

        public string PushHiddenField(string szField)
        {
            string hidField = Dispatch.EitherField(szField);
            if (hidField == null)
                hidField = "";
            AddContent(HTML.InputHidden(szField, hidField));

            return hidField;
        }

        /// <summary>
        /// Determines if the current user is in the specified
        /// group either as their primary channel or assigned to
        /// that channel
        /// </summary>
        /// <param name="sGroupId"></param>
        /// <returns></returns>
        protected bool IsUserInGroup(string sGroupId)
        {
            bool bReturn = false;
            string sUserGroupIDs = GetGroupsForCurrentUser();

            if (sGroupId.IndexOf(",") > -1)
            {
                var sSplit = sGroupId.Split(',');
                for (var i = 0; i < sSplit.Length; i++)
                {
                    if (sUserGroupIDs.IndexOf("," + sSplit[i] + ",") > -1)
                    {
                        bReturn = true;
                        break;
                    }
                }

            }
            else
            {
                if (sUserGroupIDs.IndexOf("," + sGroupId + ",") > -1)
                    bReturn = true;
            }
            return bReturn;
        }

        protected string GetGroupsForCurrentUser()
        {
            string sUserGroupIds = ",";

            var user_userid = GetContextInfo("User", "User_UserId");
            var recUser = FindRecord("User", "User_UserId=" + user_userid);
            if (recUser.GetFieldAsStringOrNull("user_PrimaryChannelId") != null)
                sUserGroupIds += recUser.GetFieldAsString("user_PrimaryChannelId") + ",";

            // now add the entries from Display Teams in the Admin interface
            var recChannelLink = FindRecord("Channel_Link", "chli_User_id=" + user_userid);
            while (!recChannelLink.Eof())
            {
                sUserGroupIds += recChannelLink.GetFieldAsString("chli_Channel_Id") + ",";
                recChannelLink.GoToNext();
            }

            return sUserGroupIds;
        }

        protected string HandleException(Exception eX)
        {
            TravantLogMessage(eX.Message);
            TravantLogMessage(eX.StackTrace);
            GetLogger().LogError(eX);

            string exception = $"<p>EXCEPTION: {eX.Message}<br/>";
            exception += $"<pre>{eX.StackTrace}</pre></p>";

            if (eX.InnerException != null)
            {
                exception = $"<p>INNER EXCEPTION: {eX.InnerException.Message}<br/>";
                exception += $"<pre>{eX.InnerException.StackTrace}</pre></p>";
            }

            return exception;
        }

        protected string _requestName = "Unknown";
        protected void SetRequestName(string requestName)
        {
            _requestName = requestName;
        }
        private FileLogger _logger = null;
        protected ILogger GetLogger()
        {
            if (_logger == null)
            {
                _logger = new FileLogger(false);
                _logger.FileName = Metadata.GetTranslation("TravantCRMLogger", "FileName");
                _logger.ErrorFileName = Metadata.GetTranslation("TravantCRMLogger", "ErrorFileName");
                _logger.TraceLevel = Convert.ToInt32(Metadata.GetTranslation("TravantCRMLogger", "TraceLevel"));
                _logger.UserID = GetContextInfo("User", "user_logon");
                _logger.ApplicationName = Metadata.GetTranslation("TravantCRMLogger", "ApplicationName");
                _logger.TimestampFormat = "MM/dd/yy HH:mm:ss:fff";
                _logger.RequestName = _requestName;
                _logger.IsEnabled = GetBoolValue(Metadata.GetTranslation("TravantCRMLogger", "IsEnabled"));

                _logger.EmailError = GetBoolValue(Metadata.GetTranslation("TravantCRMLogger", "EmailError")); ;
                _logger.SMTPServer = Metadata.GetTranslation("TravantCRMLogger", "EMailSMTPServer");
                _logger.EMailSupportAddress = Metadata.GetTranslation("TravantCRMLogger", "EMailSupportAddress");
                _logger.EMailSupportSubject = Metadata.GetTranslation("TravantCRMLogger", "EMailSupportSubject");
                _logger.EMailFromAddress = Metadata.GetTranslation("TravantCRMLogger", "EMailFromAddress");
            }

            return _logger;
        }

        public bool GetBoolValue(string value)
        {
            if (value == "Y")
                return true;

            return false;
        }

        protected void TravantLogMessage(string message)
        {
            LogMessage("TravantLog", $"{_requestName}: {message}", 1);

            try
            {
                GetLogger().LogMessage(message);
            }
            catch (Exception eX)
            {
                AddContent($"<p>{eX.Message}</p>");
            }
        }

        protected string _sortBy = string.Empty;
        protected string _sortDesc = "FALSE";


        protected string BuildColumnHeader(string fieldName, string caption)
        {
            return BuildColumnHeader(fieldName, caption, false, null, null);
        }

        protected string BuildColumnHeader(string fieldName, string caption, bool allowSort, string currentSortFieldName, string currentSortDesc)
        {
            StringBuilder columnHeader = new StringBuilder($"<td class=\"GRIDHEAD\" colname=\"{fieldName}\">");

            if (allowSort)
                columnHeader.Append($"<a class=\"GRIDHEADLINK\" onclick=\"document.EntryForm.HIDDENORDERBY.value = '{fieldName}';\" href=\"javascript:document.EntryForm.HIDDENORDERBY.value='{fieldName}';document.EntryForm.submit();\">");

            columnHeader.Append($"{caption}");

            if (allowSort)
            {
                columnHeader.Append("</a>");
                if (fieldName == currentSortFieldName)
                {
                    if (currentSortDesc == "TRUE")
                        columnHeader.Append(" <img title=\"\" align=\"TOP\" src=\"/crm/Themes/img/ergonomic/Buttons/down.gif\" border=\"0\" hspace=\"0\">");
                    else
                        columnHeader.Append(" <img title=\"\" align=\"TOP\" src=\"/crm/Themes/img/ergonomic/Buttons/up.gif\" border=\"0\" hspace=\"0\">");
                }
            }

            columnHeader.Append("&nbsp;</td>");

            return columnHeader.ToString();
        }

        protected string RemoveKey(string sQString, string sKey)
        {
            var sReturn = sQString;
            sQString = sQString.ToLower();
            sKey = sKey.ToLower();
            
            int ndx = sQString.IndexOf("&" + sKey + "=");

            if (ndx == -1)
                ndx = sQString.IndexOf("?" + sKey + "=");

            if (ndx == -1)
            {
                if (sQString.IndexOf(sKey + "=") == 0)
                    ndx = 0;
            }

            if (ndx >= 0)
            {
                int ndxNext = sQString.IndexOf("&", ndx + 2 + sKey.Length);
                if (ndxNext == -1)
                    ndxNext = sQString.Length;

                sReturn = sReturn.Substring(0, ndx) + sReturn.Substring(ndxNext);
            }

            return sReturn;
        }

        protected string ChangeKey(string sQString, string sKey, string value)
        {
            string sReturn = RemoveKey(sQString, sKey);
            sReturn += "&" + sKey + "=" + value;
            return sReturn;
        }

        #region Interaction Methods
        protected const string ICON_ATTACHMENT = "<img title=\"\" align=\"MIDDLE\" src=\"/crm/Themes/img/ergonomic/Buttons/Attachmentsmall.gif\" border=\"0\" valign=\"MIDDLE\">";
        protected const string ICON_COMPLETE = "<img title=\"\" align=\"MIDDLE\" src=\"/crm/Themes/img/ergonomic/Choices/Comm_Status/Complete.gif\" border=\"0\" valign=\"MIDDLE\">";
        protected const string ICON_PENDING = "<img title=\"\" align=\"MIDDLE\" src=\"/crm/Themes/img/ergonomic/Choices/Comm_Status/Pending.gif\" border=\"0\" valign=\"MIDDLE\">";
        protected const string ICON_CANCELLED = "<img title=\"\" align=\"MIDDLE\" src=\"/crm/Themes/img/ergonomic/Choices/Comm_Status/Cancelled.gif\" border=\"0\" valign=\"MIDDLE\">";
        protected const string ICON_DEFAULT = "<img title=\"\" align=\"MIDDLE\" src=\"/crm/Themes/img/ergonomic/Choices/Comm_Status/Default.gif\" border=\"0\" valign=\"MIDDLE\">";

        protected const string ICON_ACTION = "<img title=\"{0}\" align=\"MIDDLE\" src=\"{1}\" border=\"0\">";
        protected const string ICON_TODO = "/crm/Themes/img/ergonomic/Choices/Comm_Action/ToDo.gif";
        protected const string ICON_EMAIL_OUT = "/crm/Themes/img/ergonomic/Choices/Comm_Action/EmailOut.gif";
        protected const string ICON_EMAIL_IN = "/crm/Themes/img/ergonomic/Choices/Comm_Action/EmailIn.gif";
        protected const string ICON_LETTER_OUT = "/crm/Themes/img/ergonomic/Choices/Comm_Action/LetterOut.gif";
        protected const string ICON_LETTER_IN = "/crm/Themes/img/ergonomic/Choices/Comm_Action/LetterIn.gif";
        protected const string ICON_FAX_OUT = "/crm/Themes/img/ergonomic/Choices/Comm_Action/FaxOut.gif";
        protected const string ICON_FAX_IN = "/crm/Themes/img/ergonomic/Choices/Comm_Action/FaxIn.gif";
        protected const string ICON_NOTE = "/crm/Themes/img/ergonomic/Choices/Comm_Action/Note.gif";
        protected const string ICON_MEETING = "/crm/Themes/img/ergonomic/Choices/Comm_Action/Meeting.gif";

        protected const string ICON_ONLINE_IN = "/crm/Themes/img/ergonomic/Choices/Comm_Action/OnlineIn.gif";
        protected const string ICON_PHONE_IN = "/crm/Themes/img/ergonomic/Choices/Comm_Action/PhoneIn.gif";
        protected const string ICON_PHONE_OUT = "/crm/Themes/img/ergonomic/Choices/Comm_Action/PhoneOut.gif";

        protected ContentBox BuildInteractionListingGrid(string sqlSelect)
        {
            return BuildInteractionListingGrid(sqlSelect, null, false, "comm_datetime", true);
        }

        protected ContentBox BuildInteractionListingGrid(string sqlSelect, string defaultUserID, bool includeCompanyColumns, string defaultSortField, bool defaultSortDesc)
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
            displayTable.Append(BuildColumnHeader("comm_datetime", "Date / Time", true, _sortBy, _sortDesc));
            displayTable.Append(BuildColumnHeader("comm_action", "Action", true, _sortBy, _sortDesc));

            if (includeCompanyColumns)
            {
                displayTable.Append(BuildColumnHeader("comp_Name", "Company", true, _sortBy, _sortDesc));
                displayTable.Append(BuildColumnHeader("prci_City", "Listing City", true, _sortBy, _sortDesc));
                displayTable.Append(BuildColumnHeader("State", "Listing State", true, _sortBy, _sortDesc));
                displayTable.Append(BuildColumnHeader("prcn_Country", "Listing Country", true, _sortBy, _sortDesc));
            }

            displayTable.Append(BuildColumnHeader("Pers_FullName", "Person"));
            displayTable.Append(BuildColumnHeader("comm_subject", "Subject"));
            displayTable.Append(BuildColumnHeader("UserName", "User"));
            displayTable.Append(BuildColumnHeader("Category", "Category", true, _sortBy, _sortDesc));
            displayTable.Append(BuildColumnHeader("Subcategory", "Subcategory", true, _sortBy, _sortDesc));
            displayTable.Append(BuildColumnHeader("Staus", "Status", true, _sortBy, _sortDesc));
            displayTable.Append("</tr>");
            displayTable.Append("</thead>");
            displayTable.Append("<tbody>");

            string rowClass = "ROW1";
            int recordCount = 0;

            QuerySelect recInteractionInfo = GetQuery();
            string filter = BuildFilter(defaultUserID);
            recInteractionInfo.SQLCommand = $"{sqlSelect} {filter} ORDER BY {_sortBy} {sortOrder}";

            //TravantLogMessage($"{recInteractionInfo.SQLCommand}");
            recInteractionInfo.ExecuteReader();

            while (!recInteractionInfo.Eof())
            {
                recordCount++;

                DateTime comm_datetime = recInteractionInfo.FieldValueAsDate("comm_datetime");
                int communicationID = Convert.ToInt32(recInteractionInfo.FieldValue("comm_communicationid"));
                string comm_action = recInteractionInfo.FieldValue("Action");
                string comm_note = recInteractionInfo.FieldValue("comm_note");

                int companyID = 0;
                if (!string.IsNullOrEmpty(recInteractionInfo.FieldValue("comp_CompanyId")))
                    companyID = Convert.ToInt32(recInteractionInfo.FieldValue("comp_CompanyId"));
                string companyName = recInteractionInfo.FieldValue("comp_Name");
                string city = recInteractionInfo.FieldValue("prci_City");
                string state = recInteractionInfo.FieldValue("State");
                string country = recInteractionInfo.FieldValue("prcn_Country");
                string companyURL = Url("200") + $"&key0=1&key1={companyID}";

                int personID = 0;
                if (!string.IsNullOrEmpty(recInteractionInfo.FieldValue("Pers_PersonId")))
                    personID = Convert.ToInt32(recInteractionInfo.FieldValue("Pers_PersonId"));
                string personName = recInteractionInfo.FieldValue("Pers_FullName");
                string subject = recInteractionInfo.FieldValue("comm_subject");
                string user = recInteractionInfo.FieldValue("UserName");
                string category = recInteractionInfo.FieldValue("Category");
                string subcategory = recInteractionInfo.FieldValue("Subcategory");
                string action = recInteractionInfo.FieldValue("Action");
                string status = recInteractionInfo.FieldValue("Staus");
                string hasAttachments = recInteractionInfo.FieldValue("comm_hasattachments");

                string personURL = Url("220") + $"&key0=2&key2={personID}";
                string interactionURL = Url("PRGeneral/PRInteraction.asp") + $"&comm_communicationid={communicationID}";

                string attachmentIcon = string.Empty;
                if (hasAttachments == "Y")
                {
                    string filePath = System.Web.HttpUtility.UrlEncode(recInteractionInfo.FieldValue("Libr_FilePath"));
                    string fileName = System.Web.HttpUtility.UrlEncode(recInteractionInfo.FieldValue("Libr_FileName"));
                    string attachmentURL = Url("1282") + $"&FileName={filePath}{fileName}";

                    if (!string.IsNullOrEmpty(fileName))
                    {
                        attachmentURL = attachmentURL.Replace("/Do?", $"/do/{filePath}{fileName}?");
                        attachmentURL = attachmentURL.Replace("&Mode=1&", $"&Mode=0&");
                        attachmentIcon = $"<a href=\"{attachmentURL}\" target=\"new\">{ICON_ATTACHMENT}</a>";
                    }
                }

                string statusURL = interactionURL;
                string statusIcon = string.Empty;
                switch (status)
                {
                    case "Complete":
                        statusIcon = ICON_COMPLETE;
                        statusURL += "&NS=Pending";
                        break;
                    case "Pending":
                        statusIcon = ICON_PENDING;
                        statusURL += "&NS=Complete";
                        break;
                    case "Cancelled":
                        statusIcon = ICON_CANCELLED;
                        statusURL += "&NS=Cancelled";
                        break;
                    default:
                        statusIcon = ICON_DEFAULT;
                        break;
                }


                string actionIcon = string.Empty;
                switch (action)
                {
                    case "Internal Note":
                        actionIcon = ICON_NOTE;
                        break;
                    case "E-mail In":
                    case "Email In":
                        actionIcon = ICON_EMAIL_IN;
                        break;
                    case "E-mail Out":
                    case "Email Out":
                        actionIcon = ICON_EMAIL_OUT;
                        break;
                    case "To Do":
                        actionIcon = ICON_TODO;
                        break;
                    case "Letter In":
                        actionIcon = ICON_LETTER_IN;
                        break;
                    case "Letter Out":
                        actionIcon = ICON_LETTER_OUT;
                        break;
                    case "Fax In":
                        actionIcon = ICON_FAX_IN;
                        break;
                    case "Fax Out":
                        actionIcon = ICON_FAX_OUT;
                        break;
                    case "Online In":
                        actionIcon = ICON_ONLINE_IN;
                        break;
                    case "Phone In":
                        actionIcon = ICON_PHONE_IN;
                        break;
                    case "Phone Out":
                        actionIcon = ICON_PHONE_OUT;
                        break;
                    case "Meeting":
                        actionIcon = ICON_MEETING;
                        break;
                }

                string actionImg = string.Format(ICON_ACTION, string.Empty, actionIcon);


                if (rowClass == "ROW1")
                    rowClass = "ROW2";
                else
                    rowClass = "ROW1";

                displayTable.Append("<tr>");
                displayTable.Append($"<td class=\"{rowClass}\" align=\"center\">{attachmentIcon}</td>");
                displayTable.Append($"<td class=\"{rowClass}\">{comm_datetime:MM/dd/yyyy<br/>h:mm tt}</td>");
                displayTable.Append($"<td class=\"{rowClass}\" title=\"{comm_note}\">{actionImg} {comm_action}</td>");

                if (includeCompanyColumns)
                {
                    displayTable.Append($"<td class=\"{rowClass}\"><a href=\"{companyURL}\">{companyName}</a></td>");
                    displayTable.Append($"<td class=\"{rowClass}\">{city}</td>");
                    displayTable.Append($"<td class=\"{rowClass}\">{state}</td>");
                    displayTable.Append($"<td class=\"{rowClass}\">{country}</td>");
                }

                displayTable.Append($"<td class=\"{rowClass}\"><a href=\"{personURL}\">{personName}</a></td>");
                displayTable.Append($"<td class=\"{rowClass}\"><a href=\"{interactionURL}\">{subject}</a></td>");
                displayTable.Append($"<td class=\"{rowClass}\">{user}</td>");
                displayTable.Append($"<td class=\"{rowClass}\">{category}</td>");
                displayTable.Append($"<td class=\"{rowClass}\">{subcategory}</td>   ");
                displayTable.Append($"<td class=\"{rowClass}\" align=\"center\"><a href=\"{statusURL}\">{statusIcon}</a></td>");
                displayTable.Append("</tr>\n");

                recInteractionInfo.Next();
            }
            displayTable.Append("</tbody>");
            displayTable.Append("</table>\n");

            pageBuffer.Append(displayTable);

            cbGrid.Title = $"<strong>{recordCount:###,##0} interactions found.</strong><br/>";
            cbGrid.Inner = new HTMLString(pageBuffer.ToString());

            return cbGrid;
        }

        protected string BuildFilter(string defaultUserID)
        {
            string filter = string.Empty;
            string hMode = Dispatch.EitherField("HiddenMode");

            string fromDate = Dispatch.ContentField("comm_datetime_start");
            string endDate = Dispatch.ContentField("comm_datetime_end");
            string subject = Dispatch.ContentField("comm_subject");
            string userID = Dispatch.ContentField("cmli_comm_userid");

            if (hMode == "Save")
            {
                if (!string.IsNullOrEmpty(fromDate))
                    filter = $" AND comm_datetime >= '{fromDate}'";

                if (!string.IsNullOrEmpty(endDate))
                    filter += $" AND comm_datetime <= '{endDate}'";

                if (!string.IsNullOrEmpty(subject))
                    filter += $" AND comm_subject LIKE '%{subject}%'";

                if (!string.IsNullOrEmpty(userID))
                    filter += $" AND cmli_comm_userid = {userID}";
            }

            // This is for MyCRM
            if (string.IsNullOrEmpty(userID) && !string.IsNullOrEmpty(defaultUserID))
                filter += $" AND cmli_comm_userid = {defaultUserID}";


            return filter;
        }

        protected string BuildDragAndDrop_PRInteraction()
        {
            string interactionURL = Url("PRGeneral/PRInteraction.asp") + $"&comm_communicationid=-1&filename=";
            string szFileUploadCallbackScript = string.Format("location.href='{0}' + filename;", interactionURL);
            return BuildDragAndDrop(szFileUploadCallbackScript);
        }
        
        protected string BuildDragAndDrop_SimpleDragDroppedCallback()
        {
            return BuildDragAndDrop("imageDragDropped(filename);");
        }


        protected string BuildDragAndDrop(string szFileUploadCallbackScript)
        {
            StringBuilder output = new StringBuilder();
            output.Append("<div style=\"margin-top:20px;\">");
            output.Append("<iframe src=\"/CRM/CustomPages/PRGeneral/FileUpload.aspx\" width=\"175\" height=\"175\" scrolling=\"no\" seamless=\"seamless\" border=\"0\" frameborder=\"0\"></iframe>\n");
            output.Append("<script>");
            output.Append("     function fileUploadCallback(filename) {");
            output.Append($"         {szFileUploadCallbackScript}");
            output.Append("     }");
            output.Append("</script>");
            output.Append("</div>");
            return output.ToString();
        }

        protected string GetCustomCaptionValue(string szFamilyType, string szFamily, string szCode)
        {
            var recCustomCaption = FindRecord("Custom_Captions", $"capt_FamilyType='{szFamilyType}' AND Capt_Family='{szFamily}' AND Capt_Code='{szCode}'");
            if (!recCustomCaption.Eof())
                return recCustomCaption.GetFieldAsString("Capt_US");

            return "";
        }


        // szLanguage can be Capt_US, Capt_ES, etc.
        protected string GetCustomCaptionValue(string szFamilyType, string szFamily, string szCode, string szLanguage)
        {
            var recCustomCaption = FindRecord("Custom_Captions", $"capt_FamilyType='{szFamilyType}' AND Capt_Family='{szFamily}' AND Capt_Code='{szCode}'");
            if (!recCustomCaption.Eof())
            {
                if (szLanguage.ToLower() == "capt_us")
                    return recCustomCaption.GetFieldAsString("Capt_US");
                else
                    return recCustomCaption.GetFieldAsString(szLanguage);
            }

            return "";
        }

        protected string GetBBOSURL()
        {
            return GetCustomCaptionValue("Choices", "BBOS", "URL");
        }

        /// <summary>
        /// Move a file from one location to another.
        /// Optionally create folder structure
        /// Avoid file duplication by adding 1, 2, 3, etc. to the original filename if there is a collision
        /// Return the new filename back as output after the file is moved
        /// </summary>
        /// <param name="sourceFile">D:\Applications\CRM\WWWRoot\TempReports\test.jpg</param>
        /// <param name="targetFolder">C:\Folder\6000\</param>
        /// <param name="bCreateFolders"></param>
        /// <returns></returns>
        protected string MoveFile(string sourceFile, string targetFolder, bool bCreateFolders=true, bool bCopyOnly=false, bool bForceUniqueFileName=false, bool bDebug=false)
        {
            if (bDebug) DEBUG($"MoveFile() from {sourceFile} to {targetFolder}", true);
            string szOriginalFileName = Path.GetFileName(sourceFile);
            string szOriginalFileExtension = Path.GetExtension(sourceFile);
            
            if (bCreateFolders)
            {
                if (!Directory.Exists(targetFolder))
                {
                    if(bDebug) DEBUG($"Creating folder {targetFolder}", true);
                    Directory.CreateDirectory(targetFolder);
                    if (bDebug) DEBUG($"Done creating folder {targetFolder}", true);
                }
            }

            string szNewFileName = szOriginalFileName;
            string szNewFilePathAndName = Path.Combine(targetFolder, szOriginalFileName);

            if (bForceUniqueFileName)
            {
                int count = 1;

                bool fileExists = File.Exists(szNewFilePathAndName);
                while (fileExists)
                {
                    if (bDebug) DEBUG($"File exists {szNewFilePathAndName}", true);
                    string fileext = Path.GetExtension(szNewFileName);
                    string filenameWOExt = szNewFileName.Substring(0, (szNewFileName.Length - (fileext.Length + 1)));

                    count++;
                    szNewFileName = filenameWOExt + count.ToString() + fileext;
                    szNewFilePathAndName = Path.Combine(targetFolder, szNewFileName);
                    fileExists = File.Exists(szNewFilePathAndName);
                }
            }

            if (bCopyOnly)
            {
                if (bDebug) DEBUG($"Copying {sourceFile} to {szNewFilePathAndName}", true);
                File.Copy(sourceFile, szNewFilePathAndName);
            }
            else
            {
                if (bDebug) DEBUG($"Moving {sourceFile} to {szNewFilePathAndName}", true);
                File.Move(sourceFile, szNewFilePathAndName);
            }

            if (bDebug) DEBUG($"Returned FileName = {szNewFileName}", true);
            return szNewFileName;
        }

        #endregion

        virtual protected string GetFormattedEmail(int companyID, int personID, string subject, string text, string overrideAddressee, string culture, string industryType)
        {
            QuerySelect recFormattedEmail = GetQuery();
            recFormattedEmail.SQLCommand = $"SELECT dbo.ufn_GetFormattedEmail3({companyID}, {personID}, 0, '{subject}', '{text}', '{overrideAddressee}', '{culture}', '{industryType}', null, null) as FormattedEmail";

            //TravantLogMessage($"{recFormattedEmail.SQLCommand}");
            recFormattedEmail.ExecuteReader();
            return recFormattedEmail.FieldValue("FormattedEmail");
        }

        protected int CreatePersonEmailRecord(int personID, int companyID, string emailAddress)
        {
            Record email = new Record("Email");
            email.SetField("emai_EmailAddress", emailAddress);
            email.SetField("emai_CompanyID", companyID);
            email.SaveChanges();

            Record emailLink = new Record("EmailLink");
            emailLink.SetField("elink_EntityID", "13");
            emailLink.SetField("elink_RecordID", personID);
            emailLink.SetField("elink_EmailID", email.GetFieldAsInt("emai_EmailID"));
            emailLink.SetField("elink_Type", "E");
            emailLink.SaveChanges();

            return email.GetFieldAsInt("emai_EmailID");
        }

        protected int CreatePersonRecord(int companyID, string firstName, string lastName, out int personLinkID)
        {
            Record person = new Record("Person");
            person.SetField("pers_FirstName", firstName);
            person.SetField("pers_LastName", lastName);
            person.SetField("pers_CompanyID", companyID);
            person.SetField("pers_PRStatus", "1");
            person.SaveChanges();

            Record person_link = new Record("Person_Link");
            person_link.SetField("peli_PersonID", person.GetFieldAsInt("pers_PersonID"));
            person_link.SetField("peli_CompanyID", companyID);
            person_link.SaveChanges();

            personLinkID = person_link.GetFieldAsInt("peli_PersonLinkID");
            return person.GetFieldAsInt("pers_PersonID");
        }

        protected string GetPersonName(int personID)
        {
            var recPerson = FindRecord("Person", $"pers_PersonID={personID}");
            var firstName = recPerson.GetFieldAsString("pers_FirstName").Trim();
            var lastName = recPerson.GetFieldAsString("pers_LastName").Trim();

            return $"{firstName} {lastName}";
        }

        //Ex:  NP12345 means a new person record with parent new person add being ChangeQueueID 12345
        protected string GetPersonName(string NewPersonString)
        {
            if (!NewPersonString.StartsWith("NP:"))
                return "";
            int intChangeQueueID = Convert.ToInt32(NewPersonString.Substring(3));

            var recFirstName = FindRecord("vPRChangeQueueDetail", $"prchrqd_ChangeQueueID={intChangeQueueID} AND prchrqd_FieldName='pers_FirstName'");
            var firstName = recFirstName.GetFieldAsString("prchrqd_NewValue").Trim();

            var recLastName = FindRecord("vPRChangeQueueDetail", $"prchrqd_ChangeQueueID={intChangeQueueID} AND prchrqd_FieldName='pers_LastName'");
            var lastName = recLastName.GetFieldAsString("prchrqd_NewValue").Trim();

            return $"{firstName} {lastName}";
        }

        protected int CreatePhoneRecord(int companyID, string phoneNumber, string phoneType)
        {
            if (string.IsNullOrEmpty(phoneNumber))
                return 0;

            Record phone = new Record("Phone");
            phone.SetField("phon_Number", phoneNumber);
            phone.SaveChanges();

            Record phoneLink = new Record("PhoneLink");
            phoneLink.SetField("plink_EntityID", "5");
            phoneLink.SetField("plink_RecordID", companyID);
            phoneLink.SetField("plink_PhoneID", phone.GetFieldAsInt("phon_PhoneID"));
            phoneLink.SetField("plink_Type", phoneType);
            phoneLink.SaveChanges();

            return phone.GetFieldAsInt("phon_PhoneID");

        }
    }
}
