/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, Inc. 2020

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
using System.IO;

namespace BBSI.CRM
{
    public class PersonAlertImport : PersonBase
    {
        string hidAlertImportFileName;
        string hidBBID;
        string hidReplaceExisting;

        public override void BuildContents()
        {
            _bDebug = true;

            try
            {
                TravantLogMessage($"Begin BuildContents");

                SetRequestName("PersonAlertImport");

                AddContent(HTML.Form());
                AddContent("<script type='text/javascript' src='/crm/CustomPages/TravantCRMScripts/PersonAlertImport.js'></script>");

                ContentBox cbContents = new ContentBox();
                StringBuilder sbContents = new StringBuilder();
                cbContents.Title = "Alerts Import List";

                PushHiddenFields();

                string hMode = Dispatch.EitherField("HiddenMode");
                if (hMode == "Import")
                {
                    ImportAlerts();
                }

                var personID = GetPersonID();

                const string SQL_GET_DISTINCT_BBID = @"SELECT DISTINCT prwu_bbid, prwu_WebUserID, (Comp_Name + ' (' + CAST(Comp_CompanyId as varchar(50)) + ')') as DisplayName FROM PRWebUser
	                                                    INNER JOIN Person_Link ON prwu_PersonLinkID=PeLi_PersonLinkId
	                                                    INNER JOIN Person ON Pers_PersonId = PeLi_PersonId
	                                                    INNER JOIN Company ON Comp_CompanyId = prwu_bbid
                                                    WHERE pers_PersonID = {0}
                                                    AND prwu_Disabled IS NULL
                                                    ORDER BY DisplayName";
                QuerySelect recCompanies = new QuerySelect();
                recCompanies.SQLCommand = $"{string.Format(SQL_GET_DISTINCT_BBID, personID)}";
                recCompanies.ExecuteReader();

                Dictionary<string, string> dictBBID = new Dictionary<string, string>();
                while (!recCompanies.Eof())
                {
                    string prwu_BBID = recCompanies.FieldValue("prwu_BBID");
                    string prwu_WebUserID = recCompanies.FieldValue("prwu_WebUserID");
                    string DisplayName = recCompanies.FieldValue("DisplayName");
                    dictBBID.Add(prwu_BBID, DisplayName);

                    recCompanies.Next();
                }
                
                StringBuilder sbDropdown = new StringBuilder();
                sbDropdown.Append("<select id='ddlBBID' class=\"EDIT\">");
                if(dictBBID.Count > 1)
                    sbDropdown.Append("<option value=''>Select Company</option>");

                foreach (KeyValuePair<string, string> keyValue in dictBBID)
                {
                    string szSelected = "";
                    string prwu_BBID = keyValue.Key;
                    string DisplayName = keyValue.Value;
                    if (hidBBID == prwu_BBID)
                        szSelected = "SELECTED";
                    else
                        szSelected = "";

                    sbDropdown.Append(string.Format("<option value='{0}' {2}>{1}</option>", prwu_BBID, DisplayName, szSelected));
                }

                sbDropdown.Append("</select>");

                sbContents.Append("<div style='padding:10px'>");
                sbContents.Append("<div><b>Company</b></div>");
                sbContents.Append(sbDropdown.ToString());
                sbContents.Append("<br/><br/>");
                sbContents.Append("<input type='checkbox' id='cbReplaceExisting'" + (hidReplaceExisting=="true"?" checked":"") + "/> <b>Replace Existing List</b>");
                sbContents.Append("<br/><br/>");
                sbContents.Append("<div><b>Alert File</b></div>");

                string szDisplayFileName = hidAlertImportFileName;
                if (hidAlertImportFileName == "")
                    szDisplayFileName = "None";
                sbContents.Append("<div id='txtAlertImportFileName'>" + szDisplayFileName + "</div>");
                sbContents.Append("</div>");

                GetTabs("Person","Alerts List");

                AddContent(HTML.InputHidden("HiddenMode", string.Empty));
                AddButtonContent(BuildDragAndDrop_SimpleDragDroppedCallback());

                string importURL = "javascript:importAlerts();";
                AddUrlButton("Import", "Search.gif", importURL);
                AddUrlButton("Cancel", "Cancel.gif", Url("PRPerson/PRPersonAUSListing.asp") + "");

                cbContents.Inner = new HTMLString(sbContents.ToString());
                AddContent(cbContents.ToHtml());

                TravantLogMessage($"End BuildContents");
            }
            catch (Exception eX)
            {
                AddContent(HandleException(eX));
            }
        }

        private void ImportAlerts()
        {
            string prwu_WebUserID = GetWebUserID();
            string AUSListID = GetAUSListID(prwu_WebUserID);
            string flags = "";

            TravantLogMessage($"Begin ImportAlerts");

            //DEBUG("AUSListID=" + AUSListID);

            string sourceFile = Path.Combine(TEMP_FILE_PATH, hidAlertImportFileName);
            if (!ValidateSourceFile(sourceFile))
            {
                AddContent("<label style='color:red; font-weight:bold'>Invalid Alert File.<br><br></label>");
                return;
            }

            if(hidReplaceExisting=="true")
            {
                //delete all companies from the person’s alert list.
                ClearAUSList(AUSListID);
                flags += "&CLEAR=Y";
            }
            
            const Int32 BufferSize = 128;
            int count = 0;
            using (var fileStream = File.OpenRead(sourceFile))
                using (var streamReader = new StreamReader(fileStream, Encoding.UTF8, true, BufferSize))
                {
                    string companyID;
                    while ((companyID = streamReader.ReadLine()) != null)
                    {
                        if (!string.IsNullOrEmpty(companyID))
                        {
                            int result = InsertRecord(AUSListID, companyID);
                            if(result>0)
                                count++;
                        }
                    }
                }

            flags += $"&INSERTEDCOUNT={count}";
            Dispatch.Redirect(Url("PRPerson/PRPersonAUSListing.asp?msg=custom" + flags)); //flags back could be CLEAR and INSERTEDCOUNT
        }

        private bool ValidateSourceFile(string sourceFile)
        {
            try
            {
                const Int32 BufferSize = 128;
                int count = 0;
                using (var fileStream = File.OpenRead(sourceFile))
                    using (var streamReader = new StreamReader(fileStream, Encoding.UTF8, true, BufferSize))
                    {
                        string companyID;
                        while ((companyID = streamReader.ReadLine()) != null)
                        {
                            if (!string.IsNullOrEmpty(companyID))
                            {
                                int iCompanyId = Convert.ToInt32(companyID);
                                count++;
                            }
                        }
                    }
                    
                    if(count==0)
                        return false;

                    return true;
                }
            catch(Exception ex)
            {
                TravantLogMessage($"ValidateSourceFile Error: {ex.Message}");
                return false;
            }
        }

        private string GetWebUserID()
        {
            const string SQL_GET_WEBUSER_ID = @"SELECT prwu_WebUserID FROM Person
	                                            INNER JOIN person_link ON peli_personid	= Pers_PersonId
	                                            INNER JOIN PRWebUser ON prwu_PersonLinkID = PeLi_PersonLinkId
	                                            INNER JOIN Company ON comp_companyid = prwu_bbid
                                            WHERE Pers_PersonId = {0}
                                            AND Comp_CompanyId = {1}";
            QuerySelect recWebUserID = new QuerySelect();
            recWebUserID.SQLCommand = $"{string.Format(SQL_GET_WEBUSER_ID, GetPersonID(), hidBBID)}";
            recWebUserID.ExecuteReader();
            return recWebUserID.FieldValue("prwu_WebUserID");
        }

        private void ClearAUSList(string AUSListID)
        {
            const string SQL_CLEAR_AUS_LIST = @"DELETE FROM PRWebUserListDetail WHERE prwuld_WebUserListID = {0}";
            QuerySelect recAUSListID = new QuerySelect();
            recAUSListID.SQLCommand = $"{string.Format(SQL_CLEAR_AUS_LIST, AUSListID)}";
            recAUSListID.ExecuteNonQuery();
        }

        private string GetAUSListID(string prwu_WebUserID)
        {
            const string SQL_GET_WEBUSER_ID = @"SELECT prwucl_WebUserListID FROM PRWebUserList WHERE prwucl_CompanyID={0}
                                                AND prwucl_WebUserID = {1}
                                                AND prwucl_TypeCode='AUS'";
            QuerySelect recAUSListID = new QuerySelect();
            recAUSListID.SQLCommand = $"{string.Format(SQL_GET_WEBUSER_ID, hidBBID, prwu_WebUserID)}";
            recAUSListID.ExecuteReader();
            return recAUSListID.FieldValue("prwucl_WebUserListID");
        }

        /// <summary>
        /// Insert a record into PRWebUserListDetail
        /// </summary>
        /// <param name="AUSListID"></param>
        /// <param name="AssociateID"></param>
        /// <returns># of records added -- if could be 0 if the record already existed</returns>
        private int InsertRecord(string AUSListID, string AssociateID)
        {
            const string SQL_INSERT_RECORD = @"IF NOT EXISTS(SELECT * FROM PRWebUserListDetail WHERE prwuld_WebUserListID={0} AND prwuld_AssociatedID={1}) 
                                                BEGIN
	                                                INSERT INTO PRWebUserListDetail(prwuld_WebUserListID, prwuld_AssociatedID, prwuld_AssociatedType)
	                                                VALUES ({0}, {1}, 'C')
                                                END";
            QuerySelect recAUSListID = new QuerySelect();
            recAUSListID.SQLCommand = $"{string.Format(SQL_INSERT_RECORD, AUSListID, AssociateID)}";
            return recAUSListID.ExecuteNonQuery();
        }

        private void PushHiddenFields()
        {
            hidAlertImportFileName = PushHiddenField("hidAlertImportFileName");
            hidBBID = PushHiddenField("hidBBID");
            hidReplaceExisting = PushHiddenField("hidReplaceExisting");
        }
    }
}
