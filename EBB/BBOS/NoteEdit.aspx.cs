/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2014-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: NoteEdit.aspx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Data;

using PRCo.EBB.BusinessObjects;

using TSI.BusinessObjects;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web
{
    public partial class NoteEdit : PageBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            EnableFormValidation();
            SetPopover();

            if (!IsPostBack)
            {
                txtDate.Attributes.Add("placeholder", PageControlBaseCommon.GetCultureInfo_ShortDatePattern().ToUpper());
                ceDate.Format = PageControlBaseCommon.GetCultureInfo_ShortDatePattern(false); //force popup date field to respect culture and Spanish globalization
                BindLookupValues();
                PopulateForm();
            }
        }

        protected void SetPopover()
        {
            //popPinNote.Attributes.Add("data-bs-title", Resources.Global.OneNotePinned);
            //lbWhatIsPinned.Attributes.Add("data-bs-title", Resources.Global.OneNotePinned);
        }

        protected void BindLookupValues()
        {
            DateTime defaultDate = _oUser.ConvertToLocalDateTime(new DateTime(DateTime.Now.Ticks, DateTimeKind.Unspecified));
            int hour = defaultDate.Hour;
            string ampm = "AM";

            int minutes = defaultDate.Minute;
            string sMinutes = "15";
            if (minutes >= 45)
            {
                sMinutes = "00";
                hour++;

                if (hour > 24)
                {
                    hour = 1;
                }
            }
            if (minutes >= 30 && minutes < 45)
            {
                sMinutes = "45";
            }
            if (minutes >= 15 && minutes < 30)
            {
                sMinutes = "30";
            }

            if (hour > 11)
            {
                ampm = "PM";
            }

            if (hour > 12)
            {
                hour = hour - 12;
            }

            BindLookupValues(ddlHour, GetReferenceData("prwun_Hour"), hour.ToString());
            BindLookupValues(ddlMinute, GetReferenceData("prwun_Minute"), sMinutes);
            BindLookupValues(ddlAMPM, GetReferenceData("prwun_AMPM"), ampm);
        }

        IPRWebUserNote _note;

        protected IPRWebUserNote GetObject()
        {
            if (_note == null)
            {
                if (GetRequestParameter("NoteID", false) == null)
                {
                    SetNewNote();
                }
                else
                {
                    try
                    {
                        _note = (IPRWebUserNote)new PRWebUserNoteMgr(_oLogger, _oUser).GetObjectByKey(GetRequestParameter("NoteID"));
                    }
                    catch(ObjectNotFoundException)
                    {
                        // This note id no longer exists and was deleted.  Treat it as a new note.
                        // Fixes weird group of exception emails from July 2024
                        SetNewNote();
                    }
                }
            }

            return _note;
        }

        private void SetNewNote()
        {
            btnDelete.Visible = false;
            Print.Visible = false;

            _note = (IPRWebUserNote)new PRWebUserNoteMgr(_oLogger, _oUser).CreateObject();
            _note.prwun_HQID = _oUser.prwu_HQID;
            _note.prwun_CompanyID = _oUser.prwu_BBID;
            _note.prwun_WebUserID = _oUser.prwu_WebUserID;
            _note.prwun_AssociatedID = Convert.ToInt32(Session["CompanyHeader_szCompanyID"]);
            _note.prwun_AssociatedType = "C";

            _note.prwun_NoteUpdatedDateTime = new DateTime(DateTime.Now.Ticks, DateTimeKind.Unspecified);
            _note.prwun_NoteUpdatedBy = _oUser.prwu_WebUserID;
            _note.prwun_CreatedBy = _oUser.prwu_WebUserID;
        }

        protected void PopulateForm()
        {
            if (!Utilities.GetBoolConfigValue("NoteTextReminderEnabled", false))
            {
                trCell.Visible = false;
                ReminderType.Items.Remove(ReminderType.Items.FindByValue("Text"));
            }

            GetObject();

            switch (Request["Return"])
            {
                case "c":
                    returnURL.Value = PageConstants.Format(PageConstants.COMPANY_DETAILS_SUMMARY, _note.prwun_AssociatedID);
                    break;

                case "nl":
                    // We only want this criteria available if coming
                    // from this screen.  Thus the dance between two session variables.
                    Session["NotesSearchCriteria2"] = Session["NotesSearchCriteria"];
                    returnURL.Value = PageConstants.BROWSE_NOTES + "?ExecuteLastSearch=true";
                    break;

                default:
                    returnURL.Value = PageConstants.Format(PageConstants.COMPANY_NOTES_BBOS9, _note.prwun_AssociatedID);
                    break;
            }

            // Only one note can be pinned.  A pinned note must be unpinned before
            // a different note can be pinned.
            PinAvailable.Value = "true";
            int pinnedCount = new PRWebUserNoteMgr(_oLogger, _oUser).GetPinnedFieldCount(_oUser.prwu_HQID, _note.prwun_AssociatedID);
            if ((pinnedCount >= 1) &&
                (!_note.prwun_Key))
            {
                //cbPinned.Enabled = false;
                PinAvailable.Value = "false";
            }

            txtNote.Text = _note.prwun_Note;
            cbIsPrivate.Checked = _note.prwun_IsPrivate;
            if ((_note.IsInDB) &&
                (!_note.prwun_IsPrivate))
            {
                cbIsPrivate.Enabled = false;
            }

            cbPinned.Checked = _note.prwun_Key;
            Print.CommandArgument = _note.prwun_WebUserNoteID.ToString();

            txtEmail.Text = _oUser.Email;
            litTimeZone.Text = GetReferenceValue("prwu_TimezoneDisplay", _oUser.prwu_Timezone);

            IBusinessObjectSet reminders = _note.GetReminders(_oUser);
            foreach (IPRWebUserNoteReminder reminder in reminders)
            {
                cbRemindMe.Checked = true;
                txtDate.Text = UIUtils.GetStringFromDate(reminder.prwunr_Date);
                SetListDefaultValue(ddlHour, reminder.prwunr_Hour);
                SetListDefaultValue(ddlMinute, reminder.prwunr_Minute);
                SetListDefaultValue(ddlAMPM, reminder.prwunr_AMPM);
                litTimeZone.Text = GetReferenceValue("prwu_TimezoneDisplay", reminder.prwunr_Timezone);

                switch (reminder.prwunr_Type)
                {
                    case "BBOS":
                        ReminderType.Items.FindByValue("BBOS").Selected = true;
                        break;  

                    case "Email":
                        ReminderType.Items.FindByValue("Email").Selected = true;
                        txtEmail.Text = reminder.prwunr_Email;
                        break;

                    case "Text":
                        if (Utilities.GetBoolConfigValue("NoteTextReminderEnabled", false))
                        {
                            ReminderType.Items.FindByValue("Text").Selected = true;
                            txtCell.Text = reminder.prwunr_Phone;
                        }
                        break;
                }
            }

            PopulateNoteHeader(_note.prwun_AssociatedID);
            PopulateUpdatedBy(_note.prwun_NoteUpdatedBy, _note.prwun_NoteUpdatedDateTime);

            // Only the creater can make a public note
            // private.  This prevents another use effectively
            // hiding a note from the creator.
            if (_note.prwun_CreatedBy != _oUser.prwu_WebUserID)
            {
                cbIsPrivate.Enabled = false;
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            GetObject();
            _note.prwun_IsPrivate = cbIsPrivate.Checked;

            if (cbPinned.Checked)
            {
                new PRWebUserNoteMgr(_oLogger, _oUser).RemoveKeyNote(_oUser.prwu_HQID, Convert.ToInt32(Session["CompanyHeader_szCompanyID"]), _note.prwun_WebUserNoteID);
            }
            _note.prwun_Key = cbPinned.Checked;

            _note.prwun_Note = txtNote.Text;

            _note.prwun_Date = UIUtils.GetDateTime(txtDate.Text, PageControlBaseCommon.GetCultureInfo(_oUser));
            _note.prwun_Hour = ddlHour.SelectedValue;
            _note.prwun_Minute = ddlMinute.SelectedValue;
            _note.prwun_AMPM = ddlAMPM.SelectedValue;
            _note.prwun_Timezone = _oUser.prwu_Timezone;

            if (_note.prwun_IsPrivate)
            {
                _note.prwun_Key = false;
            }

            if (cbRemindMe.Checked)
            {
                SetReminder("BBOS");
                SetReminder("Email");

                if (Utilities.GetBoolConfigValue("NoteTextReminderEnabled", false))
                {
                    SetReminder("Text");
                }
            }
            else
            {
                _note.GetReminders(_oUser).Delete();
            }

            _note.Save();

            Session.Remove("CompanyHeader_szCompanyID");
            Close();
        }

        protected void SetReminder(string reminderType)
        {
            IPRWebUserNoteReminder reminder = _note.GetReminder(_oUser, reminderType);

            if (ReminderType.Items.FindByValue(reminderType).Selected)
            {
                if (reminder == null)
                {
                    reminder = _note.AddReminder(_oUser, reminderType);
                }

                reminder.prwunr_Date = UIUtils.GetDateTime(txtDate.Text, PageControlBaseCommon.GetCultureInfo(_oUser));
                reminder.prwunr_Hour = ddlHour.SelectedValue;
                reminder.prwunr_Minute = ddlMinute.SelectedValue;
                reminder.prwunr_AMPM = ddlAMPM.SelectedValue;
                reminder.prwunr_Timezone = _oUser.prwu_Timezone;
                reminder.prwunr_Email = txtEmail.Text;
            }
            else
            {
                if (reminder != null)
                {
                    reminder.Delete();
                }
            }
        }

        protected const string SQL_COMPANY_HEADER_SELECT =
                @"SELECT comp_PRBookTradestyle, CityStateCountryShort
                    FROM Company WITH (NOLOCK) 
                         INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID 
                   WHERE comp_CompanyID={0}";

        protected void PopulateNoteHeader(int companyID)
        {
            // If not, query for them.
            string szSQL = string.Format(SQL_COMPANY_HEADER_SELECT, companyID);
            using (IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection))
            {
                if (oReader.Read())
                {
                    lblCompanyID.Text = companyID.ToString();
                    lblCompanyName.Text = GetDBAccess().GetString(oReader, 0);
                    lblLocation.Text = GetDBAccess().GetString(oReader, 1);
                }
            }
        }

        protected void PopulateUpdatedBy(int webUserID, DateTime updatedDate)
        {
            IPRWebUser user = null;
            if ((_oUser.prwu_WebUserID == webUserID) ||
                (!_oUser.IsInDB))
            {
                user = _oUser;
            }
            else
            {
                // Use the overloaded method that takes a string.
                try
                {
                    user = (IPRWebUser)new PRWebUserMgr(_oLogger, _oUser).GetUser(webUserID.ToString());
                }
                catch (ObjectNotFoundException)
                {
                    user = null;
                }
            }

            if (user != null)
            {
                lblUpdatedBy.Text = user.Name;
                lblUpdatedDate.Text = UIUtils.GetStringFromDateTime(_oUser.ConvertToLocalDateTime(updatedDate));
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            GetObject();
            _note.Delete();
            Session.Remove("CompanyHeader_szCompanyID");
            Close();
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Close();
        }

        protected void Close()
        {
            ClientScript.RegisterStartupScript(this.GetType(), "close", "closeReload() ", true);
        }

        protected override bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.Notes).HasPrivilege;
        }

        protected override bool IsAuthorizedForData()
        {
            GetObject();
            return _note.IsUserAuthorized(_oUser);
        }
    }
}