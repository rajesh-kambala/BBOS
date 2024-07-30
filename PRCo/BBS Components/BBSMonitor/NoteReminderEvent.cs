/***********************************************************************
 Copyright Produce Reporter Company 2014

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: NoteReminderEvent.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;
using System.Timers;

using TSI.Utils;
using TSI.BusinessObjects;
using PRCo.EBB.BusinessObjects;

namespace PRCo.BBS.BBSMonitor
{
    public class NoteReminderEvent : BBSMonitorEvent
    {
        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex)
        {
            _szName = "NoteReminderEvent";

            base.Initialize(iIndex);

            try
            {
                //
                // Configure our NoteReminder Event
                //
                // Defaults to 25 minutes.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("NoteReminderInterval", 25)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("NoteReminder Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("NoteReminderStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("NoteReminder Start: " + _dtNextDateTime.ToString());

            }
            catch (Exception e)
            {
                LogEventError("Error initializing NoteReminder event.", e);
                throw;
            }
        }

        /// <summary>
        /// Looks to delete any "exprired" files.
        /// </summary>
        override public void ProcessEvent()
        {
            DateTime dtExecutionStartDate = DateTime.Now;

            StringBuilder sbErrorLog = new StringBuilder();

            string reminderType = "Email";
            int successCount = 0;
            int errorCount = 0;

            try
            {
                PRWebUserMgr webUserMgr = new PRWebUserMgr(_oLogger, null);
                PRWebUserNoteMgr webUserNoteMgr = new PRWebUserNoteMgr(_oLogger, null);

                IBusinessObjectSet users = webUserMgr.GetUsersWithPendingNoteReminders(reminderType);
                foreach (IPRWebUser user in users)
                {
                    IBusinessObjectSet notes = webUserNoteMgr.GetPendingNotifications(user.prwu_WebUserID, reminderType);
                    foreach (IPRWebUserNote note in notes)
                    {

                        try
                        {
                            note.SendReminderEmail(user);
                            note.DismissReminder(user, reminderType);
                            successCount++;
                        }
                        catch (Exception e)
                        {
                            errorCount++;
                            sbErrorLog.Append(user.Name + "," + user.prwu_WebUserID.ToString() + "," + note.prwun_WebUserNoteID.ToString() + "," + e.Message + "\n");
                        }
                    }
                }


                if (Utilities.GetBoolConfigValue("NoteReminderWriteResultsToEventLog", true))
                {
                    if (errorCount == 0)
                    {
                        _oBBSMonitorService.LogEvent("NoteReminder Executed Successfully.");
                    }
                    else
                    {
                        _oBBSMonitorService.LogEvent("NoteReminder Executed With Errors.  " + errorCount.ToString("###,##0") + " note reminders had errors.");
                    }

                }

                if (errorCount > 0)
                {
                    SendMail("NoteReminder Executed With Errors", "NoteReminder Executed With Errors.\n\n" + sbErrorLog.ToString());
                }
                else
                {
                    if (Utilities.GetBoolConfigValue("NoteReminderSendResultsToSupport", false))
                    {
                        SendMail("NoteReminder Executed Successfully", "NoteReminder Executed Successfully.");
                    }
                }
            }
            catch (Exception e)
            {
                LogEventError("NoteReminderEvent Exception", e);
            }
        }
    }
}
