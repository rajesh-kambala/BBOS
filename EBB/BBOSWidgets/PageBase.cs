/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2012

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: PageBase
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Configuration;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Web;
using System.Web.Security;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Text;
using System.Threading;
using System.Globalization;

using TSI.Utils;
using TSI.Arch;
using TSI.DataAccess;
using TSI.BusinessObjects;

namespace PRCo.BBOS.UI.Web.Widgets
{
    /// <summary>
    /// Provides common functionality for all Code-Behind pages
    /// in the application.
    /// </summary>
    public class PageBase : System.Web.UI.Page
    {
    
        /// <summary>
        /// Prefix used to mark reference data in the cache
        /// </summary>
        protected const string REF_DATA_PREFIX = "RefData";
        protected const string REF_DATA_NAME = REF_DATA_PREFIX + "_{0}_{1}";

        /// <summary>
        /// The Logger this page should use.
        /// </summary>
        protected ILogger _oLogger = null;

        protected IDBAccess _oDBAccess;

        /// <summary>
        /// Provides common functionality for all pages
        /// in the application.
        /// </summary>
        public PageBase() { }

        /// <summary>
        /// Initialize the component
        /// </summary>
        /// <param name="e"></param>
        override protected void OnInit(EventArgs e)
        {
            base.OnInit(e);

            // Setup our Global Error Handler
            this.Error += new System.EventHandler(this.OnError);
        }



        /// <summary>
        /// Writes a message to the application log.
        /// </summary>
        /// <param name="szMessage"></param>
        protected void LogMessage(string szMessage)
        {
            if (_oLogger != null)
            {
                _oLogger.LogMessage(szMessage);
            }
        }

        /// <summary>
        /// Writes the message to the application log
        /// with the specified trace level.
        /// </summary>
        /// <param name="szMessage"></param>
        /// <param name="iTraceLevel"></param>
        protected void LogMessage(string szMessage, int iTraceLevel)
        {
            if (_oLogger != null)
            {
                _oLogger.LogMessage(szMessage, iTraceLevel);
            }
        }

        /// <summary>
        /// Log an error to the application log
        /// </summary>
        /// <param name="e"></param>
        protected void LogError(Exception e)
        {
            if (_oLogger != null)
            {
                _oLogger.LogError(e);
            }
        }

        protected void LogError(Exception e, string szAdditionalInformation) {
            if (_oLogger != null) {
                _oLogger.LogError(null, e, szAdditionalInformation);
            }
        }

        /// <summary>
        /// Set the response.cache so that our 
        /// page is in no way cached.
        /// </summary>
        virtual protected void SetCacheOptions()
        {
            HttpCachePolicy oCachePolicy = Response.Cache;
            oCachePolicy.SetCacheability(HttpCacheability.NoCache);
            oCachePolicy.SetExpires(DateTime.Now.AddYears(-1));
            oCachePolicy.SetNoServerCaching();
            oCachePolicy.SetNoStore();
        }

        protected DateTime dtRequestStart;

        /// <summary>
        /// Provides base page_load functionality in populating various
        /// member variables including logging and the current user.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected virtual void Page_Load(object sender, System.EventArgs e)
        {
            dtRequestStart = DateTime.Now;
            SetCacheOptions();

            if (Session["Logger"] == null)
            {
                throw new ApplicationUnexpectedException("Logger Object Not Found in Session");
            }

            // Setup our Tracing Provider
            _oLogger = (ILogger)Session["Logger"];
            _oLogger.RequestName = Request.ServerVariables.Get("SCRIPT_NAME");


            LogMessage("Page_Load");

        }

        /// <summary>
        /// Determine if the current user is
        /// authorized to view this page.
        /// Should be overridden by all sub-classes
        /// </summary>
        /// <returns></returns>
        virtual protected bool IsAuthorizedForPage()
        {
            return true;
        }


        /// <summary>
        /// Ensures the Company/Person data being referenced is “listed”.
        /// Should be overridden by all sub-classes.
        /// </summary>
        /// <returns></returns>
        virtual protected bool IsAuthorizedForData()
        {
            return true;
        }


        /// <summary>
        /// The default error handler for the application.  Only
        /// unexpected errors should make it this far.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void OnError(object sender, System.EventArgs e)
        {

            Server.Transfer("Error.aspx");
        }

        /// <summary>
        /// Returns a formatted error table.
        /// </summary>
        /// <param name="szBoxTitle">Title of the error table</param>
        /// <param name="szMsg">Message to display</param>
        /// <param name="bDisplayButtons"></param>
        /// <returns>Formatted html table for display</returns>
        protected string GetFormattedErrorDisplay(string szBoxTitle,
                                                  string szMsg,
                                                  bool bDisplayButtons)
        {

            StringBuilder sbBuffer = new StringBuilder();

            sbBuffer.Append("<p>" + Environment.NewLine);
            sbBuffer.Append("<div>" + Environment.NewLine);

            sbBuffer.Append("<table width=\"300px\" style=\"border: 1px outset #C0C0C0;margin-left:auto;margin-right:auto\" cellspacing=0 cellpadding=0>" + Environment.NewLine);
            sbBuffer.Append("<tr><td class=\"errorHeader\">" + szBoxTitle + "</td></tr>" + Environment.NewLine);
            sbBuffer.Append("<tr><td class=\"errorMessage\">" + Environment.NewLine);

            sbBuffer.Append(szMsg + Environment.NewLine);

            if (bDisplayButtons)
            {
                sbBuffer.Append("<br>&nbsp;<div align=right>" + Environment.NewLine);
                sbBuffer.Append("<input type=button value=\"Previous Page\" onclick=\"history.go(-1);\" style=\"width:100;\">" + Environment.NewLine);
                sbBuffer.Append("&nbsp;<input type=button value=\"Home\" onclick=\"location.href='default.aspx';\" style=\"width:100;\">" + Environment.NewLine);
            }

            sbBuffer.Append("</div>" + Environment.NewLine);
            sbBuffer.Append("</td></tr>" + Environment.NewLine);
            sbBuffer.Append("</table>" + Environment.NewLine);
            sbBuffer.Append("</div>&nbsp;<p>" + Environment.NewLine);

            return sbBuffer.ToString();
        }



        /// <summary>
        /// Formats the query string parameters into a name
        /// value pair for display.
        /// </summary>
        /// <returns>Formatted Parameters</returns>
        protected string FormatQueryStringParms(bool bAddLineBreak)
        {

            StringBuilder sbParms = new StringBuilder();
            foreach (string szKey in Request.QueryString.Keys)
            {
                if (sbParms.Length > 0)
                {
                    sbParms.Append("&");
                }
                sbParms.Append(szKey);
                sbParms.Append("=");

                if (szKey.ToLower().Contains("password"))
                {
                    sbParms.Append("*****");
                }
                else
                {
                    sbParms.Append(Request.Params[szKey].ToString());
                }

                if (bAddLineBreak)
                {
                    sbParms.Append(Environment.NewLine);
                }
            }

            return sbParms.ToString();
        }


        /// <summary>
        /// Returns the specified parameter.  If not found
        /// returns null.
        /// </summary>
        /// <param name="szName">Parameter Name</param>
        /// <returns></returns>
        protected string GetRequestParameter(string szName)
        {
            return GetRequestParameter(szName, true);
        }

        /// <summary>
        /// Returns the specified parameter.  If required and not found,
        /// an ApplicationUnexpectedException is thrown.  Otherwise
        /// returns null.
        /// </summary>
        /// <param name="szName">Parameter Name</param>
        /// <param name="bRequired">Required Indicator</param>
        /// <returns></returns>
        protected string GetRequestParameter(string szName, bool bRequired)
        {
            // Pass 1: Look in the request, i.e. querystring and form input
            if ((Request[szName] != null) &&
                (Request[szName].Length > 0)) {
                return Request[szName];
            }
            
            // Pass 2: Look in the session
            if ((Session[szName] != null) &&
                (Session[szName].ToString().Length > 0)) {
                return Session[szName].ToString();
            } 
            
            // Pass 3: Look for a client cookie
            if (Request.Cookies != null) {
                if ((Request.Cookies[szName] != null) &&
                    (Request.Cookies[szName].Value.Length > 0)) {
                    return Request.Cookies[szName].Value;
                } 
            }
            
            if (bRequired) {
                throw new ApplicationUnexpectedException(string.Format("Parameter value '{0}' not found in URL: {1}", szName, Request.RawUrl));
            }

            return null;
        }

        protected void SetRequestParameter(string szName, string szValue) {
            Session[szName] = szValue;
        }

        protected void RemoveRequestParameter(string szName) {
            Session.Remove(szName);
        }

        /// <summary>
        /// Helper method that returns a IDBAccess object.  This is
        /// cached in a member variable.
        /// </summary>
        /// <returns></returns>
        public IDBAccess GetDBAccess()
        {
            if (_oDBAccess == null)
            {
                _oDBAccess = DBAccessFactory.getDBAccessProvider();
                _oDBAccess.Logger = _oLogger;
            }
            return _oDBAccess;
        }

        /// <summary>
        /// Returns the Referrer page name without the host name or
        /// query string parameters.
        /// </summary>
        /// <returns></returns>
        protected string GetReferer()
        {
            if (string.IsNullOrEmpty(Request.ServerVariables.Get("HTTP_REFERER")))
            {
                return null;
            }

            string szPage = Request.ServerVariables.Get("HTTP_REFERER");
            string szHost = Request.ServerVariables.Get("HTTP_HOST");
            int iStart = szPage.IndexOf(szHost) + szHost.Length;

            int iLength = 0;
            int iEnd = szPage.IndexOf("?");
            if (iEnd < 0)
            {
                iLength = szPage.Length - iStart;
            }
            else
            {
                iLength = iEnd - iStart;
            }

            return szPage.Substring(iStart, iLength);
        }



        public static string GetCookieID()
        {
            return Utilities.GetConfigValue("CookieID", "BBSi.BBOSMobile");
        }
    }
}