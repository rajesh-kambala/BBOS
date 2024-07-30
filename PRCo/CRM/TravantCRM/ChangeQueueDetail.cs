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


using Sage.CRM.Blocks;
using Sage.CRM.Controls;
using Sage.CRM.Data;
using Sage.CRM.HTML;
using Sage.CRM.Utils;
using Sage.CRM.WebObject;
using Sage.CRM.UI;

namespace BBSI.CRM
{
    public class ChangeQueueDetail : CRMBase
    {
        private string _companyID;
        private string _personID;
        private string _notes;

        public override void BuildContents()
        {
            DateTime StartDate = DateTime.Now;
            TravantLogMessage("BuildContents - START");
            try
            {
                SetRequestName("ChangeQueueDetail");

                List<KeyValuePair<string, string>> fields = Dispatch.ContentFields();
                foreach (KeyValuePair<string, string> formContent in fields)
                {
                    TravantLogMessage($"{formContent.Key}={formContent.Value}");
                }

                string changeQueueID = Dispatch.EitherField("prchrq_ChangeQueueID");
                Record recChangeQueue = FindRecord("vPRChangeQueue", $"prchrq_ChangeQueueID={changeQueueID}");
                _companyID = recChangeQueue.GetFieldAsString("prchrq_CompanyID");

                string mode = Dispatch.ContentField("HiddenMode");
                TravantLogMessage($"Mode: {mode}");

                if (!string.IsNullOrEmpty(mode))
                {
                    AddToCommNote($"{recChangeQueue.GetFieldAsString("BBOSUserFullName")} requested the following changes:");

                    _personID = recChangeQueue.GetFieldAsString("prchrq_PersonID");
                    _notes = recChangeQueue.GetFieldAsString("prchrq_Notes");

                    if (!string.IsNullOrEmpty(_notes))
                    {
                        AddToCommNote($"Notes: {_notes}");
                    }

                    handleMode(mode, changeQueueID);

                    TravantLogMessage($"Redirect");
                    TravantLogMessage($"BuildContents - END - Elapsed Time: {(DateTime.Now - StartDate).TotalSeconds} seconds");

                    Dispatch.Redirect(UrlDotNet(ThisDotNetDll, "RunChangeQueueListing"));
                    return;
                }

                bool newPerson = IsNewPerson(changeQueueID);
                TravantLogMessage($"newPerson={newPerson}");

                AddContent(HTML.Form());
                AddContent("<script type='text/javascript' src='/crm/CustomPages/TravantCRMScripts/ChangeQueue.js'></script>");

                EntryGroup summaryBox = new EntryGroup("PRChangeSummary");
                summaryBox.AddAttribute("width", "100%");
                summaryBox.Title = "Change Information";
                summaryBox.Fill(recChangeQueue);

                VerticalPanel vpMainPanel = new VerticalPanel();
                vpMainPanel.AddAttribute("width", "100%");
                vpMainPanel.Add(summaryBox);
                vpMainPanel.Add(BuildChangeQueueDetailGrid(changeQueueID, newPerson));

                if (newPerson)
                {
                    vpMainPanel.Add(BuildPersonSearchGrid(changeQueueID));
                }

                AddContent(vpMainPanel.ToHtml());
                AddContent(HTML.InputHidden("HiddenMode", string.Empty));

                AddUrlButton("Continue", "Continue.gif", UrlDotNet(ThisDotNetDll, "RunChangeQueueListing"));

                if (newPerson)
                {
                    string newPersonUrl = Url("PRCompany/PRCompanyPeopleQuickAdd.asp") + $"&prchrq_ChangeQueueID={changeQueueID}&Key1=new";
                    //newPersonUrl = ChangeKey(newPersonUrl, "Key0", "1");
                    //newPersonUrl = ChangeKey(newPersonUrl, "Key1", _companyID);
                    newPersonUrl = ChangeKey(newPersonUrl, "comp_companyid", _companyID);
                    AddUrlButton("Add New Person", "Save.gif", newPersonUrl);

                    AddUrlButton("Update Person", "Save.gif", "javascript:updatePerson();");
                    AddUrlButton("Delete", "Delete.gif", "javascript:changeQueueConfirmDeleteAll();");
                }
                else
                {
                    if (IsApproveEnabled(changeQueueID))
                    {
                        AddUrlButton("Approve All", "Save.gif", "javascript:changeQueueConfirmApproveAll();");
                        AddUrlButton("Approve Selected", "Save.gif", "javascript:changeQueueConfirmApproveSelected();");
                    }
                    AddUrlButton("Delete All", "Delete.gif", "javascript:changeQueueConfirmDeleteAll();");
                    AddUrlButton("Delete Selected", "Delete.gif", "javascript:changeQueueConfirmDeleteSelected();");
                }

                TravantLogMessage($"BuildContents - END - Elapsed Time: {(DateTime.Now - StartDate).TotalSeconds} seconds");
            }
            catch (Exception eX)
            {
                TravantLogMessage(eX.Message);
                AddContent(HandleException(eX));
            }
        }

        private void handleMode(string mode, string changeQueueID)
        {
            DateTime StartDate = DateTime.Now;
            TravantLogMessage($"handleMode - START {mode}");

            switch (mode)
            {
                case "ApproveAll":
                    ApproveAll(changeQueueID);
                    SaveCommunication(sbCommNote.ToString());
                    break;
                case "ApproveSelected":
                    ApproveSelected(changeQueueID);
                    SaveCommunication(sbCommNote.ToString());
                    break;
                case "DeleteAll":
                    DeleteAll(changeQueueID);
                    break;
                case "DeleteSelected":
                    DeleteSelected(changeQueueID);
                    break;
            }

            TravantLogMessage($"handleMode - END - Elapsed Time: {(DateTime.Now - StartDate).TotalSeconds} seconds");
        }

        private void ApproveSelected(string changeQueueID)
        {
            DateTime StartDate = DateTime.Now;
            TravantLogMessage("ApproveSelected - START");
            ProcessSelected(changeQueueID, "A");
            TravantLogMessage($"ApproveSelected - END - Elapsed Time: {(DateTime.Now - StartDate).TotalSeconds} seconds");
        }

        private void DeleteSelected(string changeQueueID)
        {
            ProcessSelected(changeQueueID, "D");
        }

        private void ApproveAll(string changeQueueID)
        {
            DateTime StartDate = DateTime.Now;
            TravantLogMessage("ApproveAll - START");

            if (IsNewPerson(changeQueueID))
                HandleNewPerson(changeQueueID);
            else
            {
                QuerySelect recChangeQueueDetail = GetQuery();
                recChangeQueueDetail.SQLCommand = $"SELECT * FROM PRChangeQueueDetail WHERE prchrqd_ChangeQueueID={changeQueueID} ORDER BY prchrqd_CreatedDate";

                recChangeQueueDetail.ExecuteReader();
                while (!recChangeQueueDetail.Eof())
                {
                    UpdateCRM(recChangeQueueDetail.FieldValue("prchrqd_ChangeQueueDetailID"));
                    recChangeQueueDetail.Next();
                }
            }

            DeleteAll(changeQueueID);
            TravantLogMessage($"ApproveAll - END - Elapsed Time: {(DateTime.Now - StartDate).TotalSeconds} seconds");
        }

        private void DeleteAll(string changeQueueID)
        {
            DateTime StartDate = DateTime.Now;
            TravantLogMessage("DeleteAll - START");

            DeleteAllDetails(changeQueueID);
            DeleteHeader(changeQueueID);

            TravantLogMessage($"DeleteAll - END - Elapsed Time: {(DateTime.Now - StartDate).TotalSeconds} seconds");
        }

        private void ProcessSelected(string changeQueueID, string actionCode)
        {
            DateTime StartDate = DateTime.Now;
            TravantLogMessage("ProcessSelected - START");

            QuerySelect recChangeQueueDetail = GetQuery();
            recChangeQueueDetail.SQLCommand = $"SELECT * FROM PRChangeQueueDetail WHERE prchrqd_ChangeQueueID={changeQueueID} ORDER BY prchrqd_CreatedDate";

            recChangeQueueDetail.ExecuteReader();
            while (!recChangeQueueDetail.Eof())
            {
                string changeQueueDetailID = recChangeQueueDetail.FieldValue("prchrqd_ChangeQueueDetailID");
                string detailSelected = Dispatch.ContentField($"cb{changeQueueDetailID}");
                TravantLogMessage($"detailSelected: {detailSelected}");
                if (!string.IsNullOrEmpty(detailSelected))
                {
                    if (actionCode == "A")
                        UpdateCRM(changeQueueDetailID);

                    DeleteDetail(changeQueueDetailID);
                }

                recChangeQueueDetail.Next();
            }

            DeleteHeader(changeQueueID);

            TravantLogMessage($"ProcessSelected - END - Elapsed Time: {(DateTime.Now - StartDate).TotalSeconds} seconds");
        }

        private void DeleteAllDetails(string changeQueueID)
        {
            QuerySelect recChangeQueueDetail = GetQuery();
            recChangeQueueDetail.SQLCommand = $"DELETE FROM PRChangeQueueDetail WHERE prchrqd_ChangeQueueID={changeQueueID}";
            recChangeQueueDetail.ExecuteNonQuery();
        }

        private void DeleteDetail(string changeQueueDetailID)
        {
            TravantLogMessage($"DeleteDetail");
            QuerySelect recChangeQueueDetail = GetQuery();
            recChangeQueueDetail.SQLCommand = $"DELETE FROM PRChangeQueueDetail WHERE prchrqd_ChangeQueueDetailID={changeQueueDetailID}";
            recChangeQueueDetail.ExecuteNonQuery();
        }

        private void DeleteHeader(string changeQueueID)
        {
            DateTime StartDate = DateTime.Now;
            TravantLogMessage($"DeleteHeader - START");

            QuerySelect recChangeQueueDetail = GetQuery();
            recChangeQueueDetail.SQLCommand = $"SELECT COUNT(1) as DetailCount FROM PRChangeQueueDetail WHERE prchrqd_ChangeQueueID={changeQueueID}";
            recChangeQueueDetail.ExecuteReader();
            if (!recChangeQueueDetail.Eof())
            {
                int count = Convert.ToInt32(recChangeQueueDetail.FieldValue("DetailCount"));
                if (count > 0)
                {
                    TravantLogMessage($"DeleteHeader - END - Elapsed Time: {(DateTime.Now - StartDate).TotalSeconds} seconds");
                    return;
                }
            }

            QuerySelect recChangeQueue = GetQuery();
            recChangeQueue.SQLCommand = $"DELETE FROM PRChangeQueue WHERE prchrq_ChangeQueueID={changeQueueID}";
            recChangeQueue.ExecuteNonQuery();

            TravantLogMessage($"DeleteHeader - END - Elapsed Time: {(DateTime.Now - StartDate).TotalSeconds} seconds");
        }

        private void UpdateCRM(string changeQueueDetailID)
        {
            DateTime StartDate = DateTime.Now;
            TravantLogMessage("UpdateCRM - START");

            Record recChangeQueue = FindRecord("vPRChangeQueueDetail", $"prchrqd_ChangeQueueDetailID={changeQueueDetailID}");

            string entityID = recChangeQueue.GetFieldAsString("prchrqd_EntityID");
            string recordID = recChangeQueue.GetFieldAsString("prchrqd_RecordID");
            string fieldCaption = recChangeQueue.GetFieldAsString("FieldCaption");
            string fieldName = recChangeQueue.GetFieldAsString("prchrqd_FieldName").ToLower();
            string oldValue = recChangeQueue.GetFieldAsString("prchrqd_OldValue");
            string newValue = recChangeQueue.GetFieldAsString("prchrqd_NewValue");
            string companyID = recChangeQueue.GetFieldAsString("prchrq_CompanyID");
            string personID = recChangeQueue.GetFieldAsString("prchrq_PersonID");
            string type = recChangeQueue.GetFieldAsString("prchrqd_Type");

            TableInfo tableInfo = GetTableName(entityID);

            if (entityID == "14")
                HandlePhoneUpdate(recordID, newValue, companyID, personID, type);
            else if (entityID == "6")
                HandleEmailUpdate(recordID, newValue, companyID, personID, type);
            else
            {
                Record entityRecord = null;
                if (recordID == "0")
                    entityRecord = new Record(tableInfo.Name);
                else
                    entityRecord = FindRecord(tableInfo.Name, $"{tableInfo.IdField}={recordID}");

                string newValue_DB = CustomEntryTypeMapping(fieldName, newValue);
                entityRecord.SetField(fieldName, newValue_DB);

                entityRecord.SaveChanges();

                if (entityID == "1")
                    FlagCompanyUpdated(companyID);
            }

            string oldValueDisplay = oldValue;
            if (string.IsNullOrEmpty(oldValueDisplay))
                oldValueDisplay = "no value";
            string newValueDisplay = newValue;
            if (string.IsNullOrEmpty(newValueDisplay))
                newValueDisplay = "no value";


            //3.4.1.5 -- if new peliType is empty, invoke DeletePersonLink -- if old value is empty invoke InsertPersonLink()
            if (fieldName == "peli_type")
            {
                TravantLogMessage($"UpdateCRM() --> peli_type --> oldValue={oldValue}; newValue={newValue}; ");
                if (string.IsNullOrEmpty(newValue))
                {
                    TravantLogMessage($"DeletePersonLink()");
                    DeletePersonLink(companyID, personID, type);
                }

                if (string.IsNullOrEmpty(oldValue))
                {
                    TravantLogMessage($"InsertPersonLink()");
                    InsertPersonLink(companyID, personID, type);
                }
            }

            TravantLogMessage($"UpdateCRM - END - Elapsed Time: {(DateTime.Now - StartDate).TotalSeconds} seconds");
        }

        private int GetEntryType(string fieldName)
        {
            QuerySelect recEntryType = GetQuery();
            recEntryType.SQLCommand = $"SELECT colp_EntryType FROM Custom_Edits WHERE ColP_ColName = '{fieldName}'";
            recEntryType.ExecuteReader();
            if (!recEntryType.Eof())
            {
                return Convert.ToInt32(recEntryType.FieldValue("colp_EntryType"));
            }

            return 0;
        }

        //Convert custom values for certain EntryTypes
        //Ex: Checkboxes should be Y/NULL not True/False in the database
        private string CustomEntryTypeMapping(string fieldName, string newValue)
        {
            string newValue_DB = newValue;
            int entryType = GetEntryType(fieldName);
            switch (entryType)
            {
                case 45: //Checkbox
                    switch (newValue.ToLower())
                    {
                        case "true":
                        case "1":
                            newValue_DB = "Y";
                            break;
                        case "false":
                        case "0":
                            newValue_DB = ""; //SetField converts this to null when saved
                            break;
                    }
                    break;
            }

            return newValue_DB;
        }

        private void CreateUpdateSystemUser(string companyID, string personID)
        {
            DateTime StartDate = DateTime.Now;
            TravantLogMessage("CreateUpdateSystemUser - START");

            Record drcExistingSystemUser = FindRecord("DRCSystemUser", $"drcsu_PersonID={personID} AND drcsu_CompanyID={companyID}");
            if ((drcExistingSystemUser != null) &&
                (!drcExistingSystemUser.Eof()))
            {
                //Update existing DRCSystemUser record
                drcExistingSystemUser.SetField("drcsu_IsMember", "Y");
                drcExistingSystemUser.SetField("drcsu_ManageCases", "Y");
                drcExistingSystemUser.SetField("drcsu_ManageContacts", "Y");
                drcExistingSystemUser.SetField("drcsu_ManageDocuments", "Y");
                drcExistingSystemUser.SetField("drcsu_ManageInvoices", "Y");
                drcExistingSystemUser.SaveChanges();
            }
            else
            {
                //Create new DRCSystemUser record
                Record portalUserRec = FindRecord("vDRCPortalUsers", $"pers_PersonID={personID} AND pers_CompanyID={companyID}");

                Record personRec = FindRecord("Person", $"pers_PersonID={personID}");
                Record companyRec = FindRecord("Company", $"comp_CompanyID={companyID}");

                string language = "en-ca";
                if (personRec.GetFieldAsString("pers_language") == "ES")
                    language = "es-mx";
                if (personRec.GetFieldAsString("pers_language") == "FR")
                    language = "fr-ca";

                Record newSystemUser = new Record("DRCSystemUser");
                newSystemUser.SetField("drcsu_PersonID", personID);
                newSystemUser.SetField("drcsu_CompanyID", companyID);
                newSystemUser.SetField("drcsu_FirstName", portalUserRec.GetFieldAsString("pers_FirstName"));
                newSystemUser.SetField("drcsu_LastName", portalUserRec.GetFieldAsString("pers_LastName"));
                newSystemUser.SetField("drcsu_Email", portalUserRec.GetFieldAsString("Emai_EmailAddress"));
                newSystemUser.SetField("drcsu_CompanyName", companyRec.GetFieldAsString("comp_Name"));
                newSystemUser.SetField("drcsu_Language", language);
                newSystemUser.SetField("drcsu_IsMember", "Y");
                newSystemUser.SetField("drcsu_ManageCases", "Y");
                newSystemUser.SetField("drcsu_ManageContacts", "Y");
                newSystemUser.SetField("drcsu_ManageDocuments", "Y");
                newSystemUser.SetField("drcsu_ManageInvoices", "Y");
                newSystemUser.SaveChanges();
            }

            TravantLogMessage($"CreateUpdateSystemUser - END - Elapsed Time: {(DateTime.Now - StartDate).TotalSeconds} seconds");
        }

        private void DeletePersonLink(string companyID, string personID, string type)
        {
            if (string.IsNullOrEmpty(type))
                return;

            QuerySelect recChangeQueueDetail = GetQuery();
            recChangeQueueDetail.SQLCommand = $"DELETE FROM Person_Link WHERE PeLi_PersonId={personID} AND PeLi_CompanyID={companyID} AND PeLi_Type='{type}'";
            recChangeQueueDetail.ExecuteNonQuery();
        }

        private void InsertPersonLink(string companyID, string personID, string type)
        {
            if (string.IsNullOrEmpty(type))
                return;

            Record person_Link = new Record("Person_Link");
            person_Link.SetField("peli_CompanyId", _companyID);
            person_Link.SetField("peli_PersonId", personID);
            person_Link.SetField("peli_Type", type);

            person_Link.SaveChanges();
        }

        private void HandlePhoneUpdate(string recordID, string newValue, string companyID, string personID, string type)
        {
            Record phone = null;
            Record phoneLink = null;

            if (recordID == "0")
            {
                phone = new Record("Phone");

                phoneLink = new Record("PhoneLink");
                phoneLink.SetField("plink_Type", type);

                // In this case the entity ID is for the associated
                // company or person
                phoneLink.SetField("plink_EntityID", GetEntityID(personID, companyID));

                // In this case the record ID is for the associated
                // company or person
                phoneLink.SetField("plink_RecordID", GetRecordID(personID, companyID));
            }
            else
            {
                phone = FindRecord("Phone", $"phon_PhoneID={recordID}");
            }

            if (newValue.Length == 10)
            {
                newValue = newValue.Substring(0, 3) + "-" + newValue.Substring(3, 3) + "-" + newValue.Substring(6, 4);
            }

            phone.SetField("Phon_Number", newValue);

            if (personID != null)
                phone.SetField("Phon_CompanyId", companyID);

            phone.SaveChanges();

            if (phoneLink != null)
            {
                phoneLink.SetField("plink_PhoneID", phone.GetFieldAsInt("phon_PhoneID"));
                phoneLink.SaveChanges();
            }
        }

        private void HandleEmailUpdate(string recordID, string newValue, string companyID, string personID, string type)
        {
            Record email = null;
            Record emailLink = null;

            if (recordID == "0")
            {
                email = new Record("Email");

                emailLink = new Record("EmailLink");
                emailLink.SetField("elink_Type", type);

                // In this case the entity ID is for the associated
                // company or person
                emailLink.SetField("elink_EntityID", GetEntityID(personID, companyID));

                // In this case the record ID is for the associated
                // company or person
                emailLink.SetField("elink_RecordID", GetRecordID(personID, companyID));
            }
            else
            {
                email = FindRecord("Email", $"Emai_EmailId={recordID}");
            }

            email.SetField("emai_EmailAddress", newValue);

            if (personID != null)
                email.SetField("emai_CompanyId", companyID);

            email.SaveChanges();

            if (emailLink != null)
            {
                emailLink.SetField("elink_EmailID", email.GetFieldAsInt("emai_EmailID"));
                emailLink.SaveChanges();
            }
        }

        private string GetEntityID(string personID, string companyID)
        {
            if ((!string.IsNullOrEmpty(personID)) &&
                (personID != "0"))
                return "13";

            return "5";
        }

        private string GetRecordID(string personID, string companyID)
        {
            if ((!string.IsNullOrEmpty(personID)) &&
                (personID != "0"))
                return personID;

            return companyID;
        }

        private bool IsNewPerson(string changeQueueID)
        {
            Record recChangeQueue = FindRecord("vPRChangeQueueDetail", $"prchrqd_ChangeQueueID={changeQueueID} AND prchrqd_FieldName='peli_CompanyID' AND prchrq_PersonID=-1 AND prchrqd_EntityID=13");
            if ((recChangeQueue != null) &&
                (!recChangeQueue.Eof()))
            {
                return true;
            }

            return false;
        }

        private bool IsApproveEnabled(string changeQueueID)
        {
            Record recChangeQueue = FindRecord("vPRChangeQueueDetail", $"prchrqd_ChangeQueueID={changeQueueID} AND prchrqd_FieldName='comp_PrimaryPersonID' AND prchrq_PersonID=-1 AND prchrqd_NewValue LIKE 'NP:%'");
            if ((recChangeQueue != null) &&
                (!recChangeQueue.Eof()))
            {
                return false;
            }

            return true;
        }

        private void HandleNewPerson(string changeQueueID)
        {
            DateTime StartDate = DateTime.Now;
            TravantLogMessage("HandleNewPerson - START");

            _companyID = GetNewPersonCompanyID(changeQueueID);

            Record person_Link = new Record("Person_Link");
            Record person = new Record("Person");

            person.SetField("pers_CompanyId", _companyID);
            SetFieldValue(changeQueueID, person, "pers_Salutation");
            SetFieldValue(changeQueueID, person, "pers_FirstName");
            SetFieldValue(changeQueueID, person, "pers_LastName");
            SetFieldValue(changeQueueID, person, "pers_Title");
            SetFieldValue(changeQueueID, person, "pers_Language");
            SetFieldValue(changeQueueID, person, "pers_Newsletter");
            SetFieldValue(changeQueueID, person, "pers_ConType");
            SetFieldValue(changeQueueID, person, "pers_Status");
            person.SaveChanges();
            _personID = person.GetFieldAsInt("pers_PersonId").ToString();

            person_Link.SetField("peli_CompanyId", _companyID);
            person_Link.SetField("peli_PersonId", person.GetFieldAsInt("pers_PersonId"));
            person_Link.SaveChanges();

            QuerySelect recChangeQueueDetail = GetQuery();
            recChangeQueueDetail.SQLCommand = $"SELECT * FROM vPRChangeQueueDetail WHERE prchrqd_ChangeQueueID={changeQueueID} AND prchrqd_FieldName IN ('phon_Number', 'emai_EmailAddress') ORDER BY prchrqd_CreatedDate";
            recChangeQueueDetail.ExecuteReader();
            while (!recChangeQueueDetail.Eof())
            {
                string fieldName = recChangeQueueDetail.FieldValue("prchrqd_FieldName").ToLower();
                string newValue = recChangeQueueDetail.FieldValue("prchrqd_NewValue");
                string type = recChangeQueueDetail.FieldValue("prchrqd_Type");

                if (fieldName == "emai_emailaddress")
                    HandleEmailUpdate("0", newValue, _companyID, _personID, type);

                if (fieldName == "phon_number")
                    HandlePhoneUpdate("0", newValue, _companyID, _personID, type);

                recChangeQueueDetail.Next();
            }

            AddToCommNote($"- This person record was added from BBOS.");

            //If there is an NP: change for IsPrimary checkbox, update it to the new PersonID
            Record recChangeQueueDetail2 = FindRecord("PRChangeQueueDetail", $"prchrqd_RecordID={_companyID} AND prchrqd_FieldName='comp_PrimaryPersonID' AND prchrqd_NewValue='NP:{changeQueueID}'");
            if ((recChangeQueueDetail2 != null) &&
                (!recChangeQueueDetail2.Eof()))
            {
                recChangeQueueDetail2.SetField("prchrqd_NewValue", _personID);
                recChangeQueueDetail2.SaveChanges();
            }

            TravantLogMessage($"HandleNewPerson - END - Elapsed Time: {(DateTime.Now - StartDate).TotalSeconds} seconds");
        }

        private Record FindChangeQueueDetailRecord(string changeQueueID, string fieldName)
        {
            return FindRecord("vPRChangeQueueDetail", $"prchrqd_ChangeQueueID={changeQueueID} AND prchrqd_FieldName='{fieldName}'");
        }

        private string GetNewPersonCompanyID(string changeQueueID)
        {
            Record recCompanyID = FindChangeQueueDetailRecord(changeQueueID, "peli_CompanyID");
            return recCompanyID.GetFieldAsString("prchrqd_NewValue");
        }

        private void FlagCompanyUpdated(string companyID)
        {
            DateTime now = DateTime.Now;

            Record company = FindRecord("Company", $"comp_CompanyID={companyID}");
            company.SetField("comp_TimeStamp", now);
            company.SetField("comp_UpdatedDate", now);
            company.SaveChanges();
        }

        private void SetFieldValue(string changeQueueID, Record record, string fieldName)
        {
            Record fieldRecord = FindChangeQueueDetailRecord(changeQueueID, fieldName);
            if ((fieldRecord != null) &&
                (!fieldRecord.Eof()))
            {
                string newValue_DB = CustomEntryTypeMapping(fieldName, fieldRecord.GetFieldAsString("prchrqd_NewValue"));
                record.SetField(fieldName, newValue_DB);
            }
        }

        private StringBuilder sbCommNote;
        private void AddToCommNote(string msg)
        {
            if (sbCommNote == null)
                sbCommNote = new StringBuilder();

            sbCommNote.Append(msg + Environment.NewLine);
        }

        private void SaveCommunication(string note)
        {
            DateTime StartDate = DateTime.Now;
            TravantLogMessage("SaveCommunication - START");

            DateTime StartDateTemp = DateTime.Now;
            Record CompRec = FindRecord("Company", $"comp_CompanyId={_companyID}");
            TravantLogMessage($"  FindRecord: {(DateTime.Now - StartDateTemp).TotalSeconds} seconds");

            StartDateTemp = DateTime.Now;
            Record CommRec = new Record("Communication");
            CommRec.SetField("Comm_Subject", "Member Portal Change Request Approved");
            CommRec.SetField("Comm_Type", "Task");
            CommRec.SetField("Comm_Status", "Complete");
            CommRec.SetField("Comm_DateTime", DateTime.Now);
            CommRec.SetField("Comm_note", note);
            CommRec.SetField("comm_Action", "MemberPortal");
            CommRec.SetField("Comm_Priority", "Normal");
            CommRec.SaveChanges();
            TravantLogMessage($"  CommRec.SaveChanges: {(DateTime.Now - StartDateTemp).TotalSeconds} seconds");

            StartDateTemp = DateTime.Now;
            Record CmLiRec = new Record("Comm_Link");
            CmLiRec.SetField("CmLi_Comm_CommunicationId", CommRec.GetFieldAsInt("Comm_CommunicationId"));
            CmLiRec.SetField("Cmli_Comm_UserId", GetContextInfo("User", "user_userid"));
            CmLiRec.SetField("Cmli_Comm_CompanyId", _companyID);
            if (!string.IsNullOrEmpty(_personID) && _personID != "0" && _personID != "-1")
                CmLiRec.SetField("Cmli_Comm_PersonId", _personID);
            CmLiRec.SaveChanges();
            TravantLogMessage($"  CmLiRec.SaveChanges: {(DateTime.Now - StartDateTemp).TotalSeconds} seconds");

            TravantLogMessage($"SaveCommunication - END - Elapsed Time: {(DateTime.Now - StartDate).TotalSeconds} seconds");
        }

        private TableInfo GetTableName(string entityID)
        {
            Record tables = FindRecord("Custom_Tables", $"Bord_TableId={entityID}");
            string tableName = tables.GetFieldAsString("Bord_Name");
            return Metadata.GetTableInfo(tableName);
        }

        private ContentBox BuildChangeQueueDetailGrid(string changeQueueID, bool newPerson)
        {
            ContentBox cbGrid = new ContentBox();

            StringBuilder pageBuffer = new StringBuilder();

            StringBuilder displayTable = new StringBuilder(HTML.StartTable() + "\n");
            displayTable.Append("<thead>");
            displayTable.Append("<tr>");
            if (!newPerson)
                displayTable.Append(BuildColumnHeader(string.Empty, string.Empty));
            displayTable.Append(BuildColumnHeader("FieldCaption", "Field"));
            displayTable.Append(BuildColumnHeader("prchrqd_OldValue", "Old Value"));
            displayTable.Append(BuildColumnHeader("prchrqd_NewValue", "New Value"));
            displayTable.Append(BuildColumnHeader("prchrqd_Type", "Type"));
            displayTable.Append("</tr>");
            displayTable.Append("</thead>");
            displayTable.Append("<tbody>");

            string rowClass = "ROW1";
            int recordCount = 0;

            QuerySelect recChangeQueueDetail = GetQuery();
            recChangeQueueDetail.SQLCommand = $"SELECT * FROM vPRChangeQueueDetail WHERE prchrqd_ChangeQueueID={changeQueueID} ORDER BY prchrqd_CreatedDate";

            TravantLogMessage($"{recChangeQueueDetail.SQLCommand}");
            recChangeQueueDetail.ExecuteReader();

            while (!recChangeQueueDetail.Eof())
            {
                recordCount++;

                //TravantLogMessage($"Record {recordCount}");

                string changeDetailID = recChangeQueueDetail.FieldValue("prchrqd_ChangeQueueDetailID");
                string fieldCaption = recChangeQueueDetail.FieldValue("FieldCaption");
                string oldValue = recChangeQueueDetail.FieldValue("prchrqd_OldValue");
                string newValue = recChangeQueueDetail.FieldValue("prchrqd_NewValue");
                string type = recChangeQueueDetail.FieldValue("prchrqd_Type");
                string colName = recChangeQueueDetail.FieldValue("ColP_ColName").ToLower();

                if (fieldCaption == "Primary Person Id")
                {
                    fieldCaption = "Primary Contact";

                    if ((string.IsNullOrEmpty(oldValue)) ||
                        (oldValue == "0"))
                        oldValue = string.Empty;
                    else
                        oldValue = GetPersonName(Convert.ToInt32(oldValue));

                    if (newValue.StartsWith("NP:"))
                    {
                        newValue = GetPersonName(newValue);
                    }
                    else
                        newValue = GetPersonName(Convert.ToInt32(newValue));
                }

                if (colName == "comp_language" || colName == "pers_language")
                {
                    QuerySelect recLanguageOld = GetQuery();
                    recLanguageOld.SQLCommand = $"SELECT Capt_US FROM Custom_Captions WHERE Capt_Family='comp_language' AND Capt_Code='{oldValue}'";
                    TravantLogMessage($"{recLanguageOld.SQLCommand}");
                    recLanguageOld.ExecuteReader();

                    while (!recLanguageOld.Eof())
                    {
                        oldValue = recLanguageOld.FieldValue("Capt_US");
                        recLanguageOld.Next();
                    }

                    QuerySelect recLanguageNew = GetQuery();
                    recLanguageNew.SQLCommand = $"SELECT Capt_US FROM Custom_Captions WHERE Capt_Family='comp_language' AND Capt_Code='{newValue}'";
                    TravantLogMessage($"{recLanguageNew.SQLCommand}");
                    recLanguageNew.ExecuteReader();

                    while (!recLanguageNew.Eof())
                    {
                        newValue = recLanguageNew.FieldValue("Capt_US");
                        recLanguageNew.Next();
                    }
                }

                if (fieldCaption == "Phone Number")
                {
                    if (newValue.Length == 10)
                    {
                        newValue = newValue.Substring(0, 3) + "-" + newValue.Substring(3, 3) + "-" + newValue.Substring(6, 4);
                    }
                }


                if (rowClass == "ROW1")
                    rowClass = "ROW2";
                else
                    rowClass = "ROW1";

                displayTable.Append("<tr>");
                if (!newPerson)
                    displayTable.Append($"<td class=\"{rowClass}\" style=\"text-align:center;width:50px;\" ><input type=\"checkbox\" name=\"cb{changeDetailID}\" value=\"on\"></td>");
                displayTable.Append($"<td class=\"{rowClass}\">{fieldCaption}</td>");
                displayTable.Append($"<td class=\"{rowClass}\">{oldValue}</td>");
                displayTable.Append($"<td class=\"{rowClass}\">{newValue}</td>");
                displayTable.Append($"<td class=\"{rowClass}\">{type}</td>");
                displayTable.Append("</tr>\n");

                recChangeQueueDetail.Next();
            }
            displayTable.Append("</tbody>");
            displayTable.Append("</table>\n");

            pageBuffer.Append(displayTable);

            cbGrid.Title = $"<strong>{recordCount:###,##0} change details found.</strong><br/>";
            cbGrid.Inner = new HTMLString(pageBuffer.ToString());

            return cbGrid;
        }

        private const string SQL_PERSON_SEARCH =
            "SELECT Pers_PersonId, Pers_FullName, Pers_LastName, Pers_FirstName, Pers_EmailAddress, comp_companyid, comp_Name, CityStateCountryShort, comp_PRIndustryType " +
              "FROM vSearchListPerson " +
            "WHERE (pers_LastName='{0}' AND pers_FirstName LIKE '{1}')" +
                "OR Pers_EmailAddress = '{2}'" +
            " ORDER BY pers_LastName, pers_FirstName";

        private ContentBox BuildPersonSearchGrid(string changeQueueID)
        {
            string lastName = null;
            string firstName = null;
            string email = null;

            QuerySelect recPersonNames = GetQuery();
            recPersonNames.SQLCommand = $"SELECT * FROM vPRChangeQueueDetail WHERE prchrqd_ChangeQueueID={changeQueueID} AND prchrqd_FieldName IN ('pers_FirstName', 'pers_LastName', 'Pers_EmailAddress')";
            recPersonNames.ExecuteReader();

            while (!recPersonNames.Eof())
            {
                lastName = GetChangeValue(recPersonNames, "pers_LastName", lastName);
                firstName = GetChangeValue(recPersonNames, "pers_FirstName", firstName);
                email = GetChangeValue(recPersonNames, "Pers_EmailAddress", email);

                recPersonNames.Next();
            }

            ContentBox cbGrid = new ContentBox();

            StringBuilder pageBuffer = new StringBuilder();

            StringBuilder displayTable = new StringBuilder(HTML.StartTable() + "\n");
            displayTable.Append("<thead>");
            displayTable.Append("<tr>");
            displayTable.Append(BuildColumnHeader(string.Empty, string.Empty));
            displayTable.Append(BuildColumnHeader("Pers_FullName", "Person"));
            displayTable.Append(BuildColumnHeader("Pers_PersonId", "Person ID"));
            displayTable.Append(BuildColumnHeader("Pers_LastName", "Last Name"));
            displayTable.Append(BuildColumnHeader("Pers_FirstName", "First Name"));
            displayTable.Append(BuildColumnHeader("Pers_EmailAddress", "Business Email"));
            displayTable.Append(BuildColumnHeader("comp_companyid", "Company ID"));
            displayTable.Append(BuildColumnHeader("comp_Name", "Company Name"));
            displayTable.Append(BuildColumnHeader("CityStateCountryShort", "Location"));
            displayTable.Append(BuildColumnHeader("comp_PRIndustryType", "Industry"));
            displayTable.Append("</tr>");
            displayTable.Append("</thead>");
            displayTable.Append("<tbody>");

            string rowClass = "ROW1";
            int recordCount = 0;

            string firstNameCriteria = firstName.Substring(0, 2) + '%';
            QuerySelect recChangeQueueDetail = GetQuery();
            recChangeQueueDetail.SQLCommand = string.Format(SQL_PERSON_SEARCH, lastName, firstNameCriteria, email);

            TravantLogMessage($"Person Search SQL: {recChangeQueueDetail.SQLCommand}");

            TravantLogMessage($"{recChangeQueueDetail.SQLCommand}");
            recChangeQueueDetail.ExecuteReader();

            while (!recChangeQueueDetail.Eof())
            {
                recordCount++;

                //TravantLogMessage($"Record {recordCount}");

                string fullName = recChangeQueueDetail.FieldValue("Pers_FullName");
                string personID = recChangeQueueDetail.FieldValue("Pers_PersonId");
                string perFirstName = recChangeQueueDetail.FieldValue("Pers_FirstName");
                string perLastName = recChangeQueueDetail.FieldValue("Pers_LastName");
                string perEmail = recChangeQueueDetail.FieldValue("Pers_EmailAddress");
                string companyID = recChangeQueueDetail.FieldValue("comp_companyid");
                string companyName = recChangeQueueDetail.FieldValue("comp_Name");
                string location = recChangeQueueDetail.FieldValue("CityStateCountryShort");
                string industryType = recChangeQueueDetail.FieldValue("comp_PRIndustryType");

                if (rowClass == "ROW1")
                    rowClass = "ROW2";
                else
                    rowClass = "ROW1";

                displayTable.Append("<tr>");
                displayTable.Append($"<td class=\"{rowClass}\" style=\"text-align:center;width:50px;\" ><input type=\"radio\" name=\"rbPersonID\" value=\"{personID}\"></td>");
                displayTable.Append($"<td class=\"{rowClass}\">{fullName}</td>");
                displayTable.Append($"<td class=\"{rowClass}\">{personID}</td>");
                displayTable.Append($"<td class=\"{rowClass}\">{perFirstName}</td>");
                displayTable.Append($"<td class=\"{rowClass}\">{perLastName}</td>");
                displayTable.Append($"<td class=\"{rowClass}\">{perEmail}</td>");
                displayTable.Append($"<td class=\"{rowClass}\">{companyID}</td>");
                displayTable.Append($"<td class=\"{rowClass}\">{companyName}</td>");
                displayTable.Append($"<td class=\"{rowClass}\">{location}</td>");
                displayTable.Append($"<td class=\"{rowClass}\">{industryType}</td>");
                displayTable.Append("</tr>\n");

                recChangeQueueDetail.Next();
            }
            displayTable.Append("</tbody>");
            displayTable.Append("</table>\n");

            pageBuffer.Append(displayTable);

            cbGrid.Title = $"<strong>{recordCount:###,##0} potential person matches found.</strong><br/>";
            cbGrid.Inner = new HTMLString(pageBuffer.ToString());

            return cbGrid;
        }

        /// <summary>
        /// Because we're looping once change per record, if we previously found the field,
        /// and this record is for a different field, return the current value so we don't
        /// reset previously set fields to NULL.
        /// </summary>
        /// <param name="query"></param>
        /// <param name="fieldName"></param>
        /// <param name="currentValue"></param>
        /// <returns></returns>
        protected string GetChangeValue(QuerySelect query, string fieldName, string currentValue)
        {
            string changeFieldName = query.FieldValue("prchrqd_FieldName");

            if (fieldName == changeFieldName)
                return query.FieldValue("prchrqd_NewValue");

            return currentValue;
        }
    }
}