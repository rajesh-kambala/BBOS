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

namespace BBSI.CRM
{
    public class BackgroundCheck : CompanyBase
    {
        public override void BuildContents()
        {
            SetRequestName("BackgroundCheck");

            AddContent(HTML.Form());
            GetTabs("Company", "Background Checks");
            AddContent("<script type='text/javascript' src='/crm/CustomPages/TravantCRMScripts/BackgroundCheck.js'></script>");

            string prbc_BackgroundCheckID = Dispatch.QueryField("prbc_BackgroundCheckID");
            string prbc_SubjectCompanyID = string.Empty;
            string prbc_SubjectPersonID = string.Empty;
            string prbcr_BackgroundCheckRequestID = Dispatch.EitherField("prbcr_BackgroundCheckRequestID");

            string hMode = Dispatch.EitherField("HiddenMode");
            DEBUG("hMode", hMode, false);

            Record recBackgroundCheck = null;
            if (prbc_BackgroundCheckID == "0")
            {
                prbc_SubjectCompanyID = Dispatch.QueryField("prbc_SubjectCompanyID");
                prbc_SubjectPersonID = "0";
                switch (hMode)
                {
                    case "Save":
                        recBackgroundCheck = new Record("PRBackgroundCheck");
                        break;

                    default:
                        hMode = "Change";
                        break;
                }
            }
            else
            {
                recBackgroundCheck = FindRecord("PRBackgroundCheck", "prbc_BackgroundCheckID = " + prbc_BackgroundCheckID);
                prbc_SubjectCompanyID = recBackgroundCheck.GetFieldAsString("prbc_SubjectCompanyID");
                prbc_SubjectPersonID = recBackgroundCheck.GetFieldAsString("prbc_SubjectPersonID");

                TravantLogMessage($"recBackgroundCheck");
            }

            TravantLogMessage($"prbc_SubjectPersonID={prbc_SubjectPersonID}");

            if (hMode == "Delete")
            {
                recBackgroundCheck.DeleteRecord = true;
                recBackgroundCheck.SaveChanges();

                Dispatch.Redirect(GetReturnURL(prbc_SubjectCompanyID, prbcr_BackgroundCheckRequestID));
                return;
            }

            if (hMode == "Save")
            {
                Save(prbc_BackgroundCheckID, recBackgroundCheck, prbc_SubjectCompanyID);
                Dispatch.Redirect(GetReturnURL(prbc_SubjectCompanyID, prbcr_BackgroundCheckRequestID));
                return;
            }

            if (string.IsNullOrEmpty(hMode))
                hMode = "View";

            VerticalPanel vpMainPanel = new VerticalPanel();
            vpMainPanel.AddAttribute("width", "100%");

            HorizontalPanel rowPanel = new HorizontalPanel();
            rowPanel.AddAttribute("width", "100%");
            rowPanel.HTMLId = "tblResponses";

            TravantLogMessage($"hMode={hMode}");
            if (hMode == "View")
            {
                TravantLogMessage($"Hello");
                EntryGroup screenBackgroundCheck = new EntryGroup("PRBackgroundCheck");
                screenBackgroundCheck.Title = "Background Check";
                screenBackgroundCheck.GetHtmlInViewMode(recBackgroundCheck);
                vpMainPanel.Add(screenBackgroundCheck);

                List companyBackgroundCheckResponseGrid = new List("PRBackgroundCheckResponseGrid");
                companyBackgroundCheckResponseGrid.Title = "Company Responses";
                companyBackgroundCheckResponseGrid.Filter = $"prbcr2_BackgroundCheckID={prbc_BackgroundCheckID} AND prbcr2_SubjectCode='C'";

                VerticalPanel pnlCompany = new VerticalPanel();
                pnlCompany.AddAttribute("width", "100%");
                pnlCompany.Add(companyBackgroundCheckResponseGrid);
                rowPanel.Add(pnlCompany);

                if (!string.IsNullOrEmpty(prbc_SubjectPersonID))
                {
                    List personBackgroundCheckResponseGrid = new List("PRBackgroundCheckResponseGrid");
                    personBackgroundCheckResponseGrid.Title = "Person Responses";
                    personBackgroundCheckResponseGrid.Filter = $"prbcr2_BackgroundCheckID={prbc_BackgroundCheckID} AND prbcr2_SubjectCode='P'";

                    VerticalPanel pnlPerson = new VerticalPanel();
                    pnlPerson.AddAttribute("width", "100%");
                    pnlPerson.Add(personBackgroundCheckResponseGrid);

                    rowPanel.Add(pnlPerson);
                }

                AddUrlButton("Continue", "Save.gif", GetReturnURL(prbc_SubjectCompanyID, prbcr_BackgroundCheckRequestID));
                AddUrlButton("Change", "Save.gif", "javascript:change_button();");
            }
            else if (hMode == "Change")
            {
                vpMainPanel.Add(BuildEditPage(prbc_BackgroundCheckID, prbc_SubjectCompanyID, prbc_SubjectPersonID));

                AddUrlButton("Save", "Save.gif", "javascript:save_button();");
                AddUrlButton("Cancel", "cancel.gif", UrlDotNet(ThisDotNetDll, "RunBackgroundCheckRequest") + $"&prbcr_BackgroundCheckRequestID={prbcr_BackgroundCheckRequestID}");
            }

            AddContent(vpMainPanel);
            AddContent(rowPanel);

            AddContent(HTML.InputHidden("HiddenMode", string.Empty));
            AddContent(HTML.InputHidden("prbcr_BackgroundCheckRequestID", prbcr_BackgroundCheckRequestID));
            AddContent("<script>setResponsePanelWidths();</script>");
        }

        public string GetReturnURL(string prbc_SubjectCompanyID, string prbcr_BackgroundCheckRequestID)
        {
            if (!string.IsNullOrEmpty(prbcr_BackgroundCheckRequestID))
                return UrlDotNet(ThisDotNetDll, "RunBackgroundCheckRequest") + $"&prbcr_BackgroundCheckRequestID={prbcr_BackgroundCheckRequestID}";

            return UrlDotNet(ThisDotNetDll, "RunBackgroundCheckListing") + $"&key0-1&key1={prbc_SubjectCompanyID}";
        }

        public ContentBox BuildEditPage(string backgroundCheckID, string subjectCompanyID, string subjectPersonID)
        {
            ContentBox cbGrid = new ContentBox();
            StringBuilder pageBuffer = new StringBuilder();


            pageBuffer.Append("<table style=\"width:100%\">");
            pageBuffer.Append("<tr>");
            pageBuffer.Append($"<th style=\"width:50%\">Company Check</th>");
            pageBuffer.Append($"<th style=\"width:50%\">Person Check</th>");
            pageBuffer.Append("</tr>");

            string companyName = null;
            QuerySelect reqCompanyName = GetQuery();
            reqCompanyName.SQLCommand = $"SELECT comp_Name FROM Company WHERE comp_CompanyID={subjectCompanyID}";
            reqCompanyName.ExecuteReader();
            if (!reqCompanyName.Eof())
                companyName = reqCompanyName.FieldValue("comp_Name");


            pageBuffer.Append("<tr>");
            pageBuffer.Append($"<td>{companyName}</td>");
            pageBuffer.Append($"<td>{BuildPersonDropDown(subjectCompanyID, subjectPersonID)}</td>");
            pageBuffer.Append("</tr>");

            pageBuffer.Append("<tr>");

            string questionType = "prbcr2_QuestionCodeCompany";
            pageBuffer.Append($"<td style=\"vertical-align:top\">" + BuildQuestionList(backgroundCheckID, questionType) +  "</td>");

            questionType = "prbcr2_QuestionCodePerson";
            pageBuffer.Append($"<td style=\"vertical-align:top\">" + BuildQuestionList(backgroundCheckID, questionType) + "</td>");
            pageBuffer.Append("</tr>");

            cbGrid.Inner = new HTMLString(pageBuffer.ToString());

            return cbGrid;
        }

        private string BuildQuestionList(string backgroundCheckID, string questionType)
        {
            string rowClass = "ROW1";
            int recordCount = 0;

            StringBuilder displayTable = new StringBuilder(HTML.StartTable() + "\n");
            displayTable.Append("<tbody>");

            QuerySelect reqQuestions = GetQuery();
            reqQuestions.SQLCommand = $"SELECT capt_code, capt_us FROM Custom_Captions WHERE capt_family = '{questionType}' ORDER BY capt_order";

            //TravantLogMessage($"{reqQuestions.SQLCommand}");
            reqQuestions.ExecuteReader();

            while (!reqQuestions.Eof())
            {
                recordCount++;
                string code = reqQuestions.FieldValue("capt_code");
                string display = reqQuestions.FieldValue("capt_us");
                string currentValue = GetCurrentResponseValue(backgroundCheckID, code);

                if (rowClass == "ROW1")
                    rowClass = "ROW2";
                else
                    rowClass = "ROW1";

                displayTable.Append("<tr>");
                displayTable.Append($"<td class=\"{rowClass}\" style=\"width:110px\">" + BuildResponseControl(code, currentValue) + "</td>");
                displayTable.Append($"<td class=\"{rowClass}\">{display}</td>");
                displayTable.Append("</tr>\n");

                reqQuestions.Next();
            }

            displayTable.Append("</tbody>");
            displayTable.Append("</table>\n");

            return displayTable.ToString();
        }

        private Dictionary<string, string> _dResponses;
        private const string SQL_SELECT_RESPONSES = "SELECT * FROM PRBackgroundCheckResponse WHERE prbcr2_BackgroundCheckID = {0}";

        private string GetCurrentResponseValue(string backgroundCheckID, string questionCode)
        {
            if (_dResponses == null)
            {
                _dResponses = new Dictionary<string, string>();
                QuerySelect reqResponse = GetQuery();
                reqResponse.SQLCommand = string.Format(SQL_SELECT_RESPONSES, backgroundCheckID);
                reqResponse.ExecuteReader();

                while (!reqResponse.Eof())
                {
                    _dResponses.Add(reqResponse.FieldValue("prbcr2_QuestionCode"), reqResponse.FieldValue("prbcr2_ResponseCode"));
                    reqResponse.Next();
                }
            }

            if (!_dResponses.ContainsKey(questionCode))
                return "";

            return _dResponses[questionCode];
        }

        private string BuildResponseControl(string questionCode, string selectedValue)
        {
            string responseRadioButtons = "";

            string selected = "";
            if (selectedValue == "Y")
                selected = "checked=\"true\"";

            responseRadioButtons += $"<input type=\"radio\" name=\"rb{questionCode}\" id=\"rb{questionCode}Y\" class=\"EDIT\" Value=\"Y\" {selected}><label for=\"rb{questionCode}Y\">Yes</label>";

            selected = "";
            if (selectedValue == "N")
                selected = "checked=\"true\"";

            responseRadioButtons += $"&nbsp;<input type=\"radio\" name=\"rb{questionCode}\" id=\"rb{questionCode}N\" class=\"EDIT\" Value=\"N\" {selected}> <label for=\"rb{questionCode}N\">No</label>";

            return responseRadioButtons;
        }

        private const string SQL_SELECT_PERSONS =
            @"SELECT peli_CompanyID, pers_PersonID, dbo.ufn_FormatPerson2(Pers_FirstName, Pers_LastName, Pers_MiddleName, pers_PRNickname1, Pers_Suffix, 1) AS Pers_FullName,
                   ISNULL(peli_PRTitle, '') peli_PRTitle, peli_PRTitleCode, capt_US GenericTitle
             FROM Person
                  INNER JOIN Person_Link ON pers_PersonID = peli_PersonID
                  INNER JOIN Custom_Captions ON peli_PRTitleCode = capt_code AND capt_family = 'pers_TitleCode'
            WHERE peli_CompanyID = {0}
              AND peli_PRStatus = '1'
            ORDER BY capt_order";

        private string BuildPersonDropDown(string companyID, string personID)
        {
            string personDropDown = $"<SELECT id=\"ddlPersonID\" name=\"ddlPersonID\" class=\"EDIT\">";
            personDropDown += $"<option id=\"0\"></option>";

            QuerySelect reqPersons = GetQuery();
            reqPersons.SQLCommand = string.Format(SQL_SELECT_PERSONS, companyID);

            TravantLogMessage($"{reqPersons.SQLCommand}");
            reqPersons.ExecuteReader();

            while (!reqPersons.Eof())
            {
                string pers_PersonID = reqPersons.FieldValue("pers_PersonID");
                string Pers_FullName = reqPersons.FieldValue("Pers_FullName");
                string peli_PRTitle = reqPersons.FieldValue("peli_PRTitle");

                string selected = string.Empty;
                if (pers_PersonID == personID)
                    selected = "selected=\"true\" ";

                personDropDown += $"<option value=\"{pers_PersonID}\" {selected}>{Pers_FullName} - {peli_PRTitle}</option>";
                reqPersons.Next();
            }

            personDropDown += "</select>";
            return personDropDown;
        }

        private void Save(string backgroundCheckID, Record recBackgroundCheck, string companyID)
        {
            string personID = Dispatch.ContentField("ddlPersonID");
            TravantLogMessage($"personID={personID}");

            recBackgroundCheck.SetField("prbc_SubjectCompanyID", companyID);
            recBackgroundCheck.SetField("prbc_SubjectPersonID", personID);
            recBackgroundCheck.SetField("prbc_BackgroundCheckDate", DateTime.Now);
            recBackgroundCheck.SetField("prbc_CheckCreatedBy", GetContextInfo("User", "user_userid"));
            recBackgroundCheck.SaveChanges();

            if (backgroundCheckID != "0")
            {
                QuerySelect reqDelete = GetQuery();
                reqDelete.SQLCommand = $"DELETE FROM PRBackgroundCheckResponse WHERE prbcr2_BackgroundCheckID = {backgroundCheckID}";
                //TravantLogMessage($"{reqDelete.SQLCommand}");
                reqDelete.ExecuteNonQuery();
            }

            backgroundCheckID = recBackgroundCheck.GetFieldAsString("prbc_BackgroundCheckID");
            SaveResponses(backgroundCheckID, "prbcr2_QuestionCodeCompany", "C");

            if (!string.IsNullOrEmpty(personID))
                SaveResponses(backgroundCheckID, "prbcr2_QuestionCodePerson", "P");
        }

        private void SaveResponses(string backgroundCheckID, string questionType, string subjectCode)
        {
            QuerySelect reqResponse = GetQuery();
            reqResponse.SQLCommand = $"SELECT capt_code, capt_us FROM Custom_Captions WHERE capt_family = '{questionType}' ORDER BY capt_order";

            //TravantLogMessage($"{reqResponse.SQLCommand}");
            reqResponse.ExecuteReader();

            while (!reqResponse.Eof())
            {
                string code = reqResponse.FieldValue("capt_code");
                //string response = Dispatch.ContentField($"ddl{code}");
                string response = Dispatch.ContentField($"rb{code}");

                Record recBackgroundCheckResponse = new Record("PRBackgroundCheckResponse");
                recBackgroundCheckResponse.SetField("prbcr2_BackgroundCheckID", backgroundCheckID);
                recBackgroundCheckResponse.SetField("prbcr2_SubjectCode", subjectCode);
                recBackgroundCheckResponse.SetField("prbcr2_QuestionCode", code);
                recBackgroundCheckResponse.SetField("prbcr2_ResponseCode", response);
                recBackgroundCheckResponse.SaveChanges();

                reqResponse.Next();
            }

        }
    }
}
