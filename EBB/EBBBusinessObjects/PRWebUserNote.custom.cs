/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2014-2019

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Blue Book Services, Inc..  Contact
 by e-mail at chris@wallsfamily.com

 ClassName: PRWebUserNote
 Description:	

 Notes:	Created By TSI Class Generator on 8/20/2014 7:40:16 AM

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using TSI.Arch;
using TSI.BusinessObjects;

namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Provides the functionality for the PRWebUserNote.
    /// </summary>
    public partial class PRWebUserNote : EBBObject, IPRWebUserNote
    {
        protected bool _noteTextChanged = false;


        public bool IsUserAuthorized(IPRWebUser user)
        {
            if (prwun_IsPrivate)
            {
                if (prwun_WebUserID != user.prwu_WebUserID)
                {
                    return false;
                }
            }
            else
            {
                if (prwun_HQID != user.prwu_HQID)
                {
                    return false;
                }
            }

            return true;
        }


        public void DismissReminder(IPRWebUser user, string type)
        {
            IPRWebUserNoteReminder reminder = GetReminder(user, type);
            if (reminder != null)
            {
                reminder.prwunr_SentDateTime = DateTime.Now;
                reminder.prwunr_SentDateTimeUTC = DateTime.UtcNow;
                reminder.Save();
            }
        }


        public IPRWebUserNoteReminder GetReminder(IPRWebUser user, string type)
        {
            foreach (IPRWebUserNoteReminder reminder in GetReminders(user))
            {
                if (reminder.prwunr_Type == type)
                {
                    return reminder;
                }
            }

            return null;
        }

        public bool HasReminder(IPRWebUser user)
        {
            if (GetReminders(user).Count > 0)
            {
                return true;
            }

            return false;
        }


        public IPRWebUserNoteReminder AddReminder(IPRWebUser user, string type)
        {
            IPRWebUserNoteReminder reminder = (IPRWebUserNoteReminder)new PRWebUserNoteReminderMgr(_oMgr).CreateObject();
            reminder.prwunr_Type = type;
            reminder.prwunr_WebUserID = user.prwu_WebUserID;

            GetReminders(user).Add(reminder);
            return reminder;
        }


        protected IBusinessObjectSet _reminders = null;
        public IBusinessObjectSet GetReminders(IPRWebUser user)
        {
            if (_reminders == null)
            {
                _reminders = new PRWebUserNoteReminderMgr(_oMgr).GetByUser(_prwun_WebUserNoteID, user.prwu_WebUserID);
            }

            return _reminders;
        }

        public string GetTruncatedText(int maxLength)
        {
            string szPreparedNote = null;
            if (_prwun_Note.Length <= maxLength)
            {
                szPreparedNote = _prwun_Note;
            }
            else
            {
                int iSpaceIndex = _prwun_Note.Substring(0, maxLength).LastIndexOf(' ');

                //int iEndTagIndex = _prwun_Note.LastIndexOf('>', 0, iSpaceIndex);
                //int iBeginTagIndex = _prwun_Note.LastIndexOf('<', 0, iSpaceIndex);

                //// If we have a BeginTag
                //if (iBeginTagIndex > -1)
                //{
                //    // And it came after the End Tag
                //    if (iBeginTagIndex > iEndTagIndex)
                //    {
                //        // Reset our truncation position.
                //        iSpaceIndex = iBeginTagIndex;
                //    }
                //}


                // If the text doesn't have a space, then just truncate it
                // at the limit.
                if (iSpaceIndex < 0)
                {
                    iSpaceIndex = maxLength;
                }
                szPreparedNote = _prwun_Note.Substring(0, iSpaceIndex);
            }

            return szPreparedNote;
        }

        public override void Save(System.Data.IDbTransaction oTran)
        {
            bool bLocalTran = false;
            try
            {

                // Make sure we have a transaction
                // open
                if (oTran == null)
                {
                    oTran = _oMgr.BeginTransaction();
                    bLocalTran = true;
                }

                if (_noteTextChanged)
                {
                    prwun_NoteUpdatedDateTime = DateTime.Now;
                    prwun_NoteUpdatedBy = Convert.ToInt32(_oMgr.User.UserID);
                }


                if (_prwun_Date != DateTime.MinValue)
                {
                    
                    DateTime dtDateTime = _prwun_Date;

                    dtDateTime = dtDateTime.AddHours(Convert.ToInt32(_prwun_Hour));
                    dtDateTime = dtDateTime.AddMinutes(Convert.ToInt32(_prwun_Minute));
                    
                    if (_prwun_AMPM == "PM") {
                        dtDateTime = dtDateTime.AddHours(12);
                    }

                    prwun_DateUTC = ConvertToUTC(dtDateTime, _prwun_Timezone);
                }



                base.Save(oTran);

                if (_reminders != null)
                {
                    foreach (IPRWebUserNoteReminder reminder in _reminders)
                    {
                        reminder.prwunr_WebUserNoteID = _prwun_WebUserNoteID;
                        reminder.Save(oTran);
                    }
                }

                if (bLocalTran)
                {
                    _oMgr.Commit();
                }
            }
            catch
            {
                if (bLocalTran)
                {
                    _oMgr.Rollback();
                }
                throw;
            }
        }


        public override void Delete(System.Data.IDbTransaction oTran)
        {
            bool bLocalTran = false;
            try
            {

                // Make sure we have a transaction
                // open
                if (oTran == null)
                {
                    oTran = _oMgr.BeginTransaction();
                    bLocalTran = true;
                }

                IBusinessObjectSet reminders = new PRWebUserNoteReminderMgr(_oMgr).GetByNote(_prwun_WebUserNoteID);
                reminders.Delete(oTran);

                base.Delete(oTran);


                if (bLocalTran)
                {
                    _oMgr.Commit();
                }
            }
            catch
            {
                if (bLocalTran)
                {
                    _oMgr.Rollback();
                }
                throw;
            }
        }


        protected string _subject = null;
        protected string _updatedBy = null;
        protected string _updatedLocation = null;
        protected string _reminderTypes = null;
        protected string _noteType = null;

        public override void OnAfterLoad(IDictionary oData, int iOptions)
        {
            base.OnAfterLoad(oData, iOptions);

            _subject = _oMgr.GetString(oData["Subject"]);
            _updatedBy = _oMgr.GetString(oData["UpdatedBy"]);
            _updatedLocation = _oMgr.GetString(oData["UpdatedByLocation"]);
            _reminderTypes = _oMgr.GetString(oData["ReminderTypes"]);
            _noteType = _oMgr.GetString(oData["NoteType"]);

            _dtCreatedDateTime = _oMgr.GetDateTime(oData[PRWebUserNoteMgr.COL_PRWUN_CREATED_DATE]);
            _szCreatedUserID = _oMgr.GetString(oData[PRWebUserNoteMgr.COL_PRWUN_CREATED_BY]);
        }

        

            
        public string NoteType
        {
            get
            {
                return _noteType;
            }
        }


        public string Subject
        {
            get
            {
                return _subject;
            }
        }

        public string UpdatedBy
        {
            get
            {
                return _updatedBy;
            }
        }

        public string UpdatedByLocation
        {
            get
            {
                return _updatedLocation;
            }
        }

        public string ReminderTypes
        {
            get
            {
                return _reminderTypes;
            }
        }

        public string GetFormattedDateTime()
        {
            return GetFormattedDateTime(" ");
        }

        public string GetFormattedDateTime(string lineBreak)
        {
            if (_prwun_Date == DateTime.MinValue)
            {
                return string.Empty;
            }

            return _prwun_Date.ToString("d") + lineBreak +
                    GetCustomCaptionMgr().GetMeaning("prwun_Hour", _prwun_Hour) + ":" +
                    GetCustomCaptionMgr().GetMeaning("prwun_Minute", _prwun_Minute) + " " +
                    GetCustomCaptionMgr().GetMeaning("prwun_AMPM", _prwun_AMPM) + " " +
                    GetCustomCaptionMgr().GetMeaning("prwu_TimezoneDisplay", _prwun_Timezone);
        }

        public void SendReminderEmail(IPRWebUser user)
        {
            string emailSubject = GetCustomCaptionMgr().GetMeaning("NoteReminderEmail", "Subject");
            string template = GetCustomCaptionMgr().GetMeaning("NoteReminderEmail", "Body");
            string bbosURL = GetCustomCaptionMgr().GetMeaning("BBOS", "URL");


            string bbosSubject = null;
            if (prwun_AssociatedType == "C")
            {
                bbosSubject = "<a href=\"" + bbosURL + "CompanyDetailsSummary.aspx?CompanyID=" + prwun_AssociatedID + "\">" + Subject + "</a>";
                emailSubject = string.Format(emailSubject, prwun_AssociatedID, ((PRWebUserNoteMgr)_oMgr).GetCompanyName(prwun_AssociatedID));
            }
            else
            {
                bbosSubject = "<a href=\"" + bbosURL + "PersonDetails.aspx?PersonID=" + prwun_AssociatedID + "\">" + Subject + "</a>";
            }

            string formattedMessage = string.Format(template, bbosSubject, GetFormattedDateTime(), prwun_Note);


            string formattedEmail = ((PRWebUserNoteMgr)_oMgr).GetFormattedEmail(user.prwu_BBID, user.peli_PersonID, user.prwu_WebUserID, emailSubject, formattedMessage, user.prwu_Culture, user.prwu_IndustryType);
            ((PRWebUserNoteMgr)_oMgr).SendEmail(user.Email, emailSubject, formattedEmail, "Note Reminder");
        }
    }
}
