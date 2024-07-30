/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: Global.asax
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Specialized;
using System.ComponentModel;
using System.Configuration;
using System.Data;
using System.IO;
using System.Globalization;
using System.Text;
using System.Threading;
using System.Web;
using System.Web.SessionState;
using System.Web.Caching;

using PRCo.EBB.BusinessObjects;
using TSI.Utils;


namespace PRCo.BBOS.UI.Web.UserManagement {
	/// <summary>
	/// Provides global event handling functionality for the application
	/// including logging initialization and caching lookup values.
	/// </summary>
	public class Global : System.Web.HttpApplication {
		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.IContainer components = null;

		public Global() {
			InitializeComponent();
		}	
		
		/// <summary>
		/// Fires when the application domain is first loaded.  Logs
		/// this event to the trace file.
		/// </summary>
		/// <param name="sender"></param>
		/// <param name="e"></param>
		protected void Application_Start(Object sender, EventArgs e) {
			LogMessage("Application_Start", string.Empty);
			HttpRuntime.Cache["ApplicationStart"] = DateTime.Now;
		}
 
		/// <summary>
		/// Fires when a new session has been created.  Logs this
		/// event to the trace file.
		/// </summary>
		/// <param name="sender"></param>
		/// <param name="e"></param>
		protected void Session_Start(Object sender, EventArgs e) {
			ILogger oLogger = LoggerFactory.GetLogger();
			oLogger.RequestName = "UNKNOWN";
			oLogger.LogMessage("Session_Start", oLogger.TRACE_LEVEL_ARCH);

			Session["Logger"] = oLogger;
		}

		/// <summary>
		/// Fires prior to executing the request.  Logs this event
		/// to the trace file along with input variables.
		/// </summary>
		/// <param name="sender"></param>
		/// <param name="e"></param>
		protected void Application_BeginRequest(Object sender, EventArgs e) {
			LogMessage("*****", Request.ServerVariables.Get("SCRIPT_NAME"));
			LogMessage("Application_BeginRequest", Request.ServerVariables.Get("SCRIPT_NAME"));
            LogMessage("Memory Usage: " + GetMemoryInMB(System.Environment.WorkingSet), Request.ServerVariables.Get("SCRIPT_NAME"));
			
			foreach (string szKey in Request.QueryString.AllKeys) {
				LogMessage("QueryString: " + szKey + "=" + Request.Params[szKey], Request.ServerVariables.Get("SCRIPT_NAME"));
			}

            foreach (string szKey in Request.Form.AllKeys) {
                if (szKey != null) {
                    if (!szKey.StartsWith("__")) {
                        if (szKey.ToLower().EndsWith("password")) {
                            LogMessage("Form: " + szKey + "=**********", Request.ServerVariables.Get("SCRIPT_NAME"));
                        } else {
                            LogMessage("Form: " + szKey + "=" + Request.Params[szKey], Request.ServerVariables.Get("SCRIPT_NAME"));
                        }
                    }
                }
            }
		}
        
		/// <summary>
		/// Fires when the request has completed processing.  Logs the
		/// event to the trace file.
		/// </summary>
		/// <param name="sender"></param>
		/// <param name="e"></param>
		protected void Application_EndRequest(Object sender, EventArgs e) {
            LogMessage("Memory Usage: " + GetMemoryInMB(System.Environment.WorkingSet), Request.ServerVariables.Get("SCRIPT_NAME"));
			LogMessage("Application_EndRequest", Request.ServerVariables.Get("SCRIPT_NAME"));
			LogMessage("*****",  Request.ServerVariables.Get("SCRIPT_NAME"));
		}

		/// <summary>
		/// Fires when the session object is destroyed.  Logs the event
		/// to the trace file.
		/// </summary>
		/// <param name="sender"></param>
		/// <param name="e"></param>
		protected void Session_End(Object sender, EventArgs e) {
			LogMessage("Session_End", string.Empty);
		}

		/// <summary>
		/// Fires when the app domain is being unloaded.  Logs the event 
		/// to the trace file.
		/// </summary>
		/// <param name="sender"></param>
		/// <param name="e"></param>
		protected void Application_End(Object sender, EventArgs e) {
            LogMessage("Application_End", string.Empty);
		}

		/// <summary>
		/// Writes the specified message to the application trace file.
		/// </summary>
		/// <param name="szMessage"></param>
		/// <param name="szRequestName"></param>
		protected void LogMessage(string szMessage, string szRequestName) {
            ILogger oLogger = LoggerFactory.GetLogger();
            oLogger.RequestName = szRequestName;
            oLogger.LogMessage(szMessage, oLogger.TRACE_LEVEL_ARCH);
		}

        protected string GetMemoryInMB(long iBytes) {
            decimal dMemory = ((decimal)iBytes) / 1048576;
            return dMemory.ToString("###,##0.00 MB");
        }
			
		#region Web Form Designer generated code
		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{    
			this.components = new System.ComponentModel.Container();
		}
		#endregion
	}
}

