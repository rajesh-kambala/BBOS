/***********************************************************************
 Copyright Produce Reporter Company 2006-2020

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: GenerateBankruptcyReportEvent.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.IO;
using System.Timers;
using TSI.Utils;

namespace PRCo.BBS.BBSMonitor {

    /// <summary>
    /// Generates the Bankruptcy report and stores it on disk
    /// for easy retrieval.  It is essentially a fairly static report
    /// so there is no need to regenerate it every time a user
    /// requests it.  
    /// </summary>
    class BankruptcyReportEvent : BBSMonitorEvent {

        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex) {
            _szName = "BankruptcyReport";

            base.Initialize(iIndex);

            try {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("BankruptcyReportInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("BankruptcyReportCount Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("BankruptcyReportStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("BankruptcyReport Start: " + _dtNextDateTime.ToString());

            } catch (Exception e) {
                LogEventError("Error initializing BankruptcyReport event.", e);
                throw;
            }
        }
        
        /// <summary>
        /// Go generate our file and save it
        /// to disk.
        /// </summary>
        override public void ProcessEvent() {
        
            try {
                //byte[] abReport = GetTestReport();
                
                ReportInterface oReportInterface = new ReportInterface();

                //Produce Bankruptcy report
                byte[] abReport = oReportInterface.GenerateBankruptcyReport("en-us", 
                                                                            DateTime.Today.AddDays(0 - Utilities.GetIntConfigValue("BankruptyReportStartDaysOld", 365)),
                                                                            DateTime.Today,
                                                                            string.Empty,
                                                                            "Produce");

                string szFileName = Utilities.GetConfigValue("BankruptcyReportReportName", "BBOS Bankruptcy Report.pdf");
                string szFullName = Path.Combine(Utilities.GetConfigValue("BBOSReportPath"), szFileName);
                using (FileStream oFStream = File.Create(szFullName, abReport.Length)) {
                    oFStream.Write(abReport, 0, abReport.Length);
                }

                //Lumber Bankruptcy report
                byte[] abReportLumber = oReportInterface.GenerateBankruptcyReport("en-us",
                                                                            DateTime.Today.AddDays(0 - Utilities.GetIntConfigValue("BankruptyReportStartDaysOld", 365)),
                                                                            DateTime.Today,
                                                                            string.Empty,
                                                                            "Lumber");

                string szFileName2 = Utilities.GetConfigValue("BankruptcyReportLumberReportName", "BBOS Lumber Bankruptcy Report.pdf");
                string szFullName2 = Path.Combine(Utilities.GetConfigValue("BBOSReportPath"), szFileName2);
                using (FileStream oFStream = File.Create(szFullName2, abReportLumber.Length))
                {
                    oFStream.Write(abReportLumber, 0, abReportLumber.Length);
                }

                //PACA/DRC Violators Report
                byte[] pvReportPACADRC = oReportInterface.GeneratePACADRCViolatorsReport(DateTime.Today.AddYears(0-Utilities.GetIntConfigValue("PACADRCViolatorsReportStartYearsOld", 3)),
                                                                            DateTime.Today,
                                                                            string.Empty);

                string szFileName3 = Utilities.GetConfigValue("PACADRCViolatorsReportName", "PACA DRC Violators Report.pdf");
                string szFullName3 = Path.Combine(Utilities.GetConfigValue("BBOSReportPath"), szFileName3);
                using (FileStream oFStream = File.Create(szFullName3, pvReportPACADRC.Length))
                {
                    oFStream.Write(pvReportPACADRC, 0, pvReportPACADRC.Length);
                }

                if (Utilities.GetBoolConfigValue("BankruptcyReportWriteResultsToEventLog", true)) {
                    LogEvent("BankruptcyReport Executed Successfully.");
                }

                if (Utilities.GetBoolConfigValue("BankruptcyReportSendResultsToSupport", false)) {
                    SendMail("BankruptcyReport Success", "BankruptcyReport Executed Successfully.");
                }
            } catch (Exception e) {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error Procesing BankruptcyReport Event.", e);
            }
        }
    }
}
