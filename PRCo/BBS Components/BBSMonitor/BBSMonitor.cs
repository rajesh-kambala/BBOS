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

 ClassName: BBSMonitor.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.ServiceProcess;
using TSI.Utils;

namespace PRCo.BBS.BBSMonitor
{

    public partial class BBSMonitor : ServiceBase
    {

        private List<IBBSMonitorEvent> _lBBSMonitorEvents;
        private int _iEventCount;

        private ILogger _oLogger;

        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        public BBSMonitor()
        {
            InitializeComponent();

            //System.Threading.Thread.Sleep(8000); //TODO: delay if not debugging (when needed to set breakpoints)

            _lBBSMonitorEvents = new List<IBBSMonitorEvent>();
            _iEventCount = 0;

            try
            {
                _oLogger = LoggerFactory.GetLogger();
                _oLogger.RequestName = "Initialize";

                _oLogger.LogMessage("Loading Events");

                // Look at our config file for which BBS Monitor Event 
                // classes we need to load.
                string szBBSEventClassName = Utilities.GetConfigValue("BBSMonitorEventName" + _iEventCount.ToString(), string.Empty);
                while (szBBSEventClassName.Length > 0)
                {
                    InitializeEvent(szBBSEventClassName);

                    _iEventCount++;
                    szBBSEventClassName = Utilities.GetConfigValue("BBSMonitorEventName" + _iEventCount.ToString(), string.Empty);
                }

                _oLogger.LogMessage("Started " + _iEventCount.ToString() + " Events");

            }
            catch (Exception e)
            {
                LogEventError("Error initializing service.", e);
                throw;
            }
        }

        /// <summary>
        /// Instantiates and initilizes the specified BBS Event
        /// </summary>
        /// <param name="szBBSEventType"></param>
        protected void InitializeEvent(string szBBSEventType)
        {
            Type oBBSEventType = Type.GetType(szBBSEventType);
            if (oBBSEventType == null)
            {
                throw new ApplicationException("Invalid BBS Event Type found: " + szBBSEventType);
            }

            IBBSMonitorEvent oBBSMonitorEvent = (IBBSMonitorEvent)Activator.CreateInstance(oBBSEventType);
            oBBSMonitorEvent.BBSMonitorService = this;
            oBBSMonitorEvent.Initialize(_iEventCount);
            _lBBSMonitorEvents.Add(oBBSMonitorEvent);

        }

        /// <summary>
        /// Writes an error message to the Event Log.
        /// </summary>
        /// <param name="szMessage">Message</param>
        /// <param name="oEventType">Event Type</param>
        public void LogEvent(string szMessage, EventLogEntryType oEventType)
        {

            if (szMessage.Length > 32700)
                szMessage = szMessage.Substring(0, 32700) + "\nTRUNCATED";

            _oEventLog.WriteEntry(szMessage, oEventType);
        }

        /// <summary>
        /// Writes the information message to the Event Log.
        /// </summary>
        /// <param name="szMessage">Message</param>
        public void LogEvent(string szMessage)
        {
            LogEvent(szMessage, EventLogEntryType.Information);
        }

        /// <summary>
        /// Writes an error message to the Event Log.
        /// </summary>
        /// <param name="szMessage">Message</param>
        /// <param name="e">Exception</param>
        public void LogEventError(string szMessage, Exception e)
        {
            _oLogger.LogError(szMessage, e);
            LogEvent(szMessage + " " + e.Message, EventLogEntryType.Error);
        }

        /// <summary>
        /// Time to light this candle!
        /// </summary>
        /// <param name="args"></param>
        protected override void OnStart(string[] args)
        {
            //_oLogger.RequestName = "OnStart";
            try
            {
                foreach (IBBSMonitorEvent oBBSMonitorEvent in _lBBSMonitorEvents)
                {
                    oBBSMonitorEvent.OnStart();
                }

            }
            catch (Exception e)
            {
                LogEventError("Error starting service.", e);
                throw;
            }

        }

        /// <summary>
        /// Whoa, hold the horses!
        /// </summary>
        protected override void OnStop()
        {
            //_oLogger.RequestName = "OnStop";
            try
            {
                foreach (IBBSMonitorEvent oBBSMonitorEvent in _lBBSMonitorEvents)
                {
                    oBBSMonitorEvent.OnStop();
                }

            }
            catch (Exception e)
            {
                LogEventError("Error stopping service.", e);
                throw;
            }
        }
    }
}
