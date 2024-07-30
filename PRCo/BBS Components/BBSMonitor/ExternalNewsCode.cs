/***********************************************************************
 Copyright Produce Reporter Company 2006-2010

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: ExternalNewsCode.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Timers;
using TSI.Utils;
using PRCo.BBOS.ExternalNews;

namespace PRCo.BBS.BBSMonitor
{
    public class ExternalNewsCode : BBSMonitorEvent
    {

        /// <summary>
        /// Initializes the service setting up the logger, timer, etc.
        /// </summary>
        override public void Initialize(int iIndex)
        {
            _szName = "ExternalNewsCode";

            base.Initialize(iIndex);

            try
            {

                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("ExternalNewsCodeInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("External News Code Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("ExternalNewsCodeStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("External News Code Start: " + _dtNextDateTime.ToString());

            }
            catch (Exception e)
            {
                LogEventError("Error initializing ExternalNewsCode event.", e);
                throw;
            }
        }

        /// <summary>
        /// Refreshes the external news codes.
        /// </summary>
        override public void ProcessEvent()
        {      
            try
            {
                ExternalNewsMgr externalNewsManager = new ExternalNewsMgr();
                externalNewsManager.RefreshCodes();
            }
            catch (Exception e)
            {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("External News Manager Refresh Codes Failed.", e);
            }
            
        }

    }
}
