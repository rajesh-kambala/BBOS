/***********************************************************************
 Copyright Produce Reporter Company 2006-2007

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: BBSMonitor.cs
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


namespace PRCo.BBS.BBSMonitor {

    /// <summary>
    /// Provides the functionality to clean up files in
    /// specified folders.
    /// </summary>
    public class FileCleanupEvent : BBSMonitorEvent {


        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex) {
            _szName = "FileCleanupEvent";

            base.Initialize(iIndex);

            try {
                //
                // Configure our Filecleanup Event
                //
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("FileCleanupInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("FileCleanup Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("FileCleanupStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("FileCleanup Start: " + _dtNextDateTime.ToString());

            } catch (Exception e) {
                LogEventError("Error initializing FileCleanup event.", e);
                throw;
            }
        }

        /// <summary>
        /// Looks to delete any "exprired" files.
        /// </summary>
        override public void ProcessEvent() {

            DateTime dtExecutionStartDate = DateTime.Now;

            int iFolderCount = Utilities.GetIntConfigValue("FileCleanupFolderCount", 0);

            for (int iIndex = 0; iIndex < iFolderCount; iIndex++) {
                string szFolderName = null;
                try {
                    szFolderName = Utilities.GetConfigValue("FileCleanupFolderName" + iIndex.ToString());    
                    int iDeleteThreshold = Utilities.GetIntConfigValue("FileCleanupDeleteThreshold" + iIndex.ToString(), 1440);
                    DateTime dtNow = DateTime.Now;

                    DirectoryInfo oDirInfo = new DirectoryInfo(szFolderName);
                    FileInfo[] aszFileInfo = oDirInfo.GetFiles();

                    foreach (FileInfo oFileInfo in aszFileInfo) {
                        TimeSpan oTS = dtNow.Subtract(oFileInfo.CreationTime);
                        if (oTS.TotalMinutes > iDeleteThreshold) {
                            oFileInfo.Delete();
                        }
                    }
                } catch (Exception e) {
                    if (szFolderName == null) {
                        szFolderName = "[UNKNOWN]";
                    }
                    LogEventError("Folder: " + szFolderName, e);
                }
            }
        }
    }
}
