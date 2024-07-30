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

using PRCo.EBB.BusinessObjects;
using PRCo.EBB.Util;

namespace PRCo.BBOS.UI.Web.UserManagement
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
        /// A formatted CSS link to ensure the proper syntax is used.
        /// </summary>
        protected const string CSS_LINK = "<LINK href=\"{0}{1}\" type=\"text/css\" rel=\"stylesheet\">";

        /// <summary>
        /// The main application CSS file.
        /// </summary>
        protected static string CSS_FILE = "ebb.css";

        public static string COOKIE_ID = "PRCo.BBOS";
        public static string USER_MSG_ID = "szUserMessage";


        /// <summary>
        /// Text displayed at the top of a form explaining the required field display.
        /// </summary>
        protected static string _szRequiredFieldMsg = null;

        /// <summary>
        /// Display text to indicate a field accepts wildcard characters.
        /// </summary>
        protected static string _szWildcardFieldMsg = null;

        /// <summary>
        /// Used to hold messages to display to the user
        /// via JS when the page is loaded.
        /// </summary>
        protected List<String> _oUserMessages = null;

        /// <summary>
        /// The Logger this page should use.
        /// </summary>
        protected ILogger _oLogger = null;

        protected IPRWebUser _oUser = null;
        protected GeneralDataMgr _oObjectMgr;
        protected IDBAccess _oDBAccess;

        /// <summary>
        /// Data manager instance for our lookup codes.
        /// </summary>
        static protected Custom_CaptionMgr _oCustom_CaptionMgr = null;

        /// <summary>
        /// Generic counter used when building custom display constructs
        /// with a repeater.
        /// </summary>
        protected int _iRepeaterCount;
        protected int _iRepeaterRowCount = 1;

        /// <summary>
        /// JS that sets the pointer style when the mouse hovers of the control this
        /// is applied to.  Usually used with toggling fieldsets.
        /// </summary>
        protected const string MOUSE_OVER_CURSOR = "onmouseover=\"this.style.cursor='hand'\" onmouseout=\"this.style.cursor='auto'\"";

        protected const string EMAIL_URL = "<a href=\"mailto:{0}\">{1}</a>";

        /// <summary>
        /// JavaScript function to fire the onclick event for the button that
        /// needs to respond to the ENTER key.
        /// </summary>
        protected const string JS_ENTER_SUBMITS = "<script language=\"JavaScript\">function SubmitOnEnter() {{ if (event.keyCode == 13) {{var e = document.getElementById('{0}');e.click();event.keyCode=0;return false;}} }}document.onkeydown = SubmitOnEnter;</script>";

        protected static string LOCK_NFU_REF = "x";

        protected const string TASK_STATUS_PENDING = "Pending";

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
        /// Fires off when the page is about to render.
        /// </summary>
        /// <param name="e"></param>
        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);
            PreparePageFooter();
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

            // Check to see if we have a current user.
            if ((Session["oUser"] == null) &&
                (HttpContext.Current.User.Identity.IsAuthenticated))
            {

                // For whatever reason, our session got dumped but the
                // current user's auth cookie is still valid.  Re-initialize
                // our session.
                InitializeUser(Convert.ToInt32(HttpContext.Current.User.Identity.Name));
            }


            LogMessage("Page_Load");
            // Even though we initialized the user, we still may not have a valid
            // object if this is not a secured page.
            if (Session["PersonLinkID"] != null)
            {
                _oLogger.UserID = Session["PersonLinkID"].ToString();

                //// Only create the web audit trail upon first load, not everytime
                //// the page is posted back.
                if (!IsPostBack) {
                    //InsertWebAudit();
                }
                
            }
        }


        /// <summary>
        /// The default error handler for the application.  Only
        /// unexpected errors should make it this far.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void OnError(object sender, System.EventArgs e)
        {

            //bool bLogError = true;
            //Exception oCurrentException = Server.GetLastError();
            //if (oCurrentException is AuthorizationException) {
            //    bLogError = false;
            //}

            //if (bLogError) {
            //    LogError(oCurrentException);
            //}

            // Transfer to Error.aspx to handle the appropriate display.
            
            //LogError(Server.GetLastError());
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

            sbBuffer.Append("<table width=\"500\" style=\"border: 1px outset #C0C0C0;\" align=\"center\" cellspacing=0 cellpadding=0>" + Environment.NewLine);
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
        /// Generates the default page footer displaying the
        /// specified message and specified user ID.
        /// </summary>
        /// <returns>HTML Code</returns>
        virtual public void PreparePageFooter()
        {
            DateTime dtRequestEnd = DateTime.Now;
            TimeSpan oTS = dtRequestEnd.Subtract(dtRequestStart);
            ((Literal)Master.FindControl("litFooterDuration")).Text = oTS.TotalMilliseconds.ToString();

            Page.ClientScript.RegisterStartupScript(this.GetType(), "UserMessages", GetUserMessagesScript());
        }

        /// <summary>
        /// Generates the HTML to display messages
        /// to the user.
        /// </summary>
        /// <returns></returns>
        protected string GetUserMessagesScript()
        {
            StringBuilder buffer = new StringBuilder();

            if ((_oUserMessages != null) &&
                (_oUserMessages.Count > 0))
            {
                buffer.Append("<script language=JavaScript>" + Environment.NewLine);
                foreach (string szMsg in _oUserMessages)
                {
                    LogMessage("Index: " + szMsg.IndexOf("'").ToString());
                    string szTmp = szMsg.Replace("'", "\\'");
                    buffer.Append("alert('" + szTmp + "'.replace(/NEWLINE/g, \"\\n\"));" + Environment.NewLine);
                }

                buffer.Append("</script>" + Environment.NewLine);
            }

            // We may have messages from other requests
            if (Session[USER_MSG_ID] != null)
            {
                string _szUserMessage = (string)Session[USER_MSG_ID];
                buffer.Append("<script language=JavaScript>" + Environment.NewLine);
                buffer.Append("alert('" + _szUserMessage + "'.replace(/NEWLINE/g, \"\\n\"));" + Environment.NewLine);
                buffer.Append("</script>" + Environment.NewLine);
                Session["szUserMessage"] = null;
            }

            return buffer.ToString();
        }

        /// <summary>
        /// Creates a properly formatted e-mail link.
        /// </summary>
        /// <param name="szEmailAddress">The EMail Address</param>
        /// <returns>HTML Code</returns>
        static public string FormatEmailLink(string szEmailAddress)
        {
            return FormatEmailLink(szEmailAddress, szEmailAddress);
        }

        /// <summary>
        /// Creates a properly formatted e-mail link.
        /// </summary>
        /// <param name="szEmailAddress">The EMail Address</param>
        /// <param name="szEmailText">The text that is hyperlinked.</param>
        /// <returns>HTML Code</returns>
        static public string FormatEmailLink(string szEmailAddress, string szEmailText)
        {
            return FormatEmailLink(szEmailAddress, szEmailText, null);
        }

        /// <summary>
        /// Creates a properly formatted e-mail link.
        /// </summary>
        /// <param name="szEmailAddress">The EMail Address</param>
        /// <param name="szEmailText">The text that is hyperlinked.</param>
        /// <param name="szSubject">Subject of the email</param>
        /// <returns>HTML Code</returns>
        static public string FormatEmailLink(string szEmailAddress, string szEmailText, string szSubject)
        {
            string szHref = HttpUtility.HtmlEncode(szEmailAddress);
            if (!string.IsNullOrEmpty(szSubject))
            {
                szHref += "&Subject=" + HttpUtility.HtmlEncode(szSubject);
            }

            return string.Format(EMAIL_URL, szHref, HttpUtility.HtmlEncode(szEmailText));
        }

        /// <summary>
        /// Retrieves the lookup value based on the specified
        /// lookup code.
        /// </summary>
        /// <param name="szRefDataType">Reference Data Type</param>
        /// <param name="iRefDataCode">Reference Data Code</param>
        /// <returns>Reference Data Value</returns>
        public string GetReferenceValue(object szRefDataType, object iRefDataCode)
        {
            return GetReferenceValue(Convert.ToString(szRefDataType), Convert.ToString(iRefDataCode));
        }

        /// <summary>
        /// Retrieves the lookup value based on the specified
        /// lookup code.
        /// </summary>
        /// <param name="szRefDataType">Reference Data Type</param>
        /// <param name="szRefDataCode">Reference Data Code</param>
        /// <returns>Reference Data Value</returns>
        public string GetReferenceValue(string szRefDataType, string szRefDataCode)
        {

            if (string.IsNullOrEmpty(szRefDataCode))
            {
                return "Unknown";
            }

            IBusinessObjectSet osRefData = GetReferenceData(szRefDataType);
            foreach (ICustom_Caption oLC in osRefData)
            {
                if (oLC.Code == szRefDataCode)
                {
                    return oLC.Meaning;
                }
            }

            throw new ApplicationUnexpectedException("Unable to find meaning for code - " + szRefDataType + ":" + szRefDataCode);
        }

        /// <summary>
        /// Formats a boolean for end-user
        /// display
        /// </summary>
        /// <param name="bValue"></param>
        /// <returns></returns>
        public static string BoolToString(bool bValue)
        {
            if (bValue)
            {
                return "Yes";
            }
            else
            {
                return "No";
            }
        }

        /// <summary>
        /// Returns the appropriate string value from the
        /// object in the mm/dd/yyyy format.
        /// </summary>
        /// <param name="oValue">The value to evaluate</param>
        /// <returns>String representation of DateTime</returns>
        static public string GetStringFromDate(Object oValue)
        {
            return GetStringFromDate(oValue, string.Empty);
        }

        /// <summary>
        /// Returns the appropriate string value from the
        /// object in the specified format.
        /// </summary>
        /// <param name="oValue">The value to evaluate</param>
        /// <param name="szDefault">The value to return if NULL</param>
        /// <returns>String representation of DateTime</returns>
        static public string GetStringFromDate(Object oValue, string szDefault)
        {
            return GetStringFromDateTime(oValue, szDefault, "d");
        }

        /// <summary>
        /// Formats the DateTime into a string.
        /// </summary>
        /// <param name="oValue">The value to evaluate</param>
        /// <returns>String representation of DateTime</returns>
        static public String GetStringFromDateTime(Object oValue)
        {
            return GetStringFromDateTime(oValue, string.Empty);
        }

        /// <summary>
        /// Formats the DateTime into a string.
        /// </summary>
        /// <param name="oValue">The value to evaluate</param>
        /// <param name="szDefault">Default value if null</param>
        /// <returns>String representation of DateTime</returns>
        static public String GetStringFromDateTime(Object oValue, string szDefault)
        {
            return GetStringFromDateTime(oValue, szDefault, "g");
        }


        /// <summary>
        /// Returns the appropriate string value from the
        /// object in the specified format.
        /// </summary>
        /// <param name="oValue">The value to evaluate</param>
        /// <param name="szFormat">The format to use</param>
        /// <param name="szDefault">The value to return if NULL</param>
        /// <returns>String representation of DateTime</returns>
        static public string GetStringFromDateTime(Object oValue, string szDefault, string szFormat)
        {
            if ((oValue == null) ||
                 (oValue.ToString().Length == 0))
            {
                return szDefault;
            }

            DateTime dtValue = (DateTime)oValue;

            // HACK: Using DateTime.MinValue instead of NULL.
            if (dtValue.Equals(DateTime.MinValue))
            {
                return szDefault;
            };

            return dtValue.ToString(szFormat);
        }



        /// <summary>
        /// Retrieve the user based on the specified email address.
        /// </summary>
        /// <param name="szEmail">Email Address</param>
        /// <returns>IUser</returns>
        virtual protected IPRWebUser GetUser(string szEmail)
        {
            return new PRWebUserMgr().GetByEmail(szEmail);
        }

        private IPRWebUser GetTestUser()
        {
            PRWebUser oUser = new PRWebUser();
            oUser.prwu_WebUserID = 1;
            oUser.FirstName = "Test";
            oUser.LastName = "User";
            oUser.Email = "cwalls@travant.com";
            oUser.prwu_Culture = Utilities.GetConfigValue("TestUserCulture", "en-us");
            oUser.prwu_AccessLevel = Utilities.GetIntConfigValue("TestUserAccessLevel", PRWebUser.SECURITY_LEVEL_ADMIN);

            return oUser;
        }


        protected const string SQL_INIT_USER = "SELECT peli_PersonLinkID, peli_CompanyID, comp_PRHQID, peli_PersonID, dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_PRNickname1, NULL, pers_Suffix) As PersonName FROM Person_Link INNER JOIN PERSON on peli_PersonID = pers_PersonID INNER JOIN Company ON peli_CompanyID = comp_CompanyID WHERE peli_PersonLinkID=@peli_PersonLinkID";
        /// <summary>
        /// Initializes the session with specific user
        /// values.
        /// </summary>
        /// <param name="szEmail">Email Address</param>
        /// <returns>Success Indicator</returns>
        virtual protected bool InitializeUser(int iPersonLinkID)
        {

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("peli_PersonLinkID", iPersonLinkID));

            IDataReader oReader = GetDBAccess().ExecuteReader(SQL_INIT_USER, oParameters, CommandBehavior.CloseConnection, null);
            try {
                if (!oReader.Read()) {
                    return false;
                }

                Session["PersonLinkID"] = oReader.GetInt32(0);
                Session["BBID"] = oReader.GetInt32(1);
                Session["HQID"] = oReader.GetInt32(2);
                Session["PersonID"] = oReader.GetInt32(3);
                Session["PersonName"] = oReader.GetString(4);

                return true;
            } finally {
                oReader.Close();
            }
        }

        /// <summary>
        /// Formats text for HTML by replacing CR (Char(10))
        ///  w/&gt;BR&lt; and spaces with nbsp;
        /// </summary>
        /// <param name="szText">Input Text</param>
        /// <returns>HTML Formatted Text</returns>
        static public string FormatTextForHTML(string szText)
        {
            if ((szText == null) ||
                (szText.Length == 0))
            {
                return "&nbsp;";
            }

            szText = HttpUtility.HtmlEncode(szText);
            szText = szText.Replace("\r\n", "<br>");
            szText = szText.Replace("  ", " &nbsp;");

            return szText;
        }


        /// <summary>
        /// Stores the record count with the specified
        /// DataGrid
        /// </summary>
        /// <param name="oGridView">GridView</param>
        /// <param name="iRecordCount">Record Count</param>
        virtual protected void SetRecordCount(GridView oGridView, int iRecordCount)
        {
            oGridView.Attributes["RecordCount"] = iRecordCount.ToString();
        }

        /// <summary>
        /// Retrieves the record count from the specified
        /// DataGrid
        /// </summary>
        /// <param name="oGridView">GridView</param>
        /// <returns>Record Count</returns>
        virtual protected int GetRecordCount(GridView oGridView)
        {
            return Convert.ToInt32(oGridView.Attributes["RecordCount"]);
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
        /// Add a message to the queue to display to
        /// the user when the page is rendered.
        /// </summary>
        /// <param name="szMsg"></param>
        protected void AddUserMessage(string szMsg)
        {
            AddUserMessage(szMsg, false);
        }

        /// <summary>
        /// Add a message to the queue to display to
        /// the user when the page is rendered.
        /// </summary>
        /// <param name="szMsg"></param>
        /// <param name="bInSession">Indicates if the Session should be used to transmit the message</param>
        protected void AddUserMessage(string szMsg, bool bInSession)
        {
            string szTemp = szMsg.Replace("\n", "NEWLINE");

            if (bInSession)
            {
                Session[USER_MSG_ID] = szTemp;
            }
            else
            {
                if (_oUserMessages == null)
                {
                    _oUserMessages = new List<string>();
                }

                _oUserMessages.Add(szTemp);
            }
        }

        /// <summary>
        /// Clear all user messages from
        /// the queue.
        /// </summary>
        protected void ClearUserMessages()
        {
            _oUserMessages = null;
        }



        /// <summary>
        /// Bind the specified collection to the specified 
        /// list.
        /// </summary>
        /// <param name="oList">List Control</param>
        /// <param name="oCollection">Collection to Bind</param>
        static public void BindLookupValues(ListControl oList,
                                            ICollection oCollection)
        {
            BindLookupValues(oList, oCollection, null);
        }

        /// <summary>
        /// Bind the specified collection to the specified 
        /// list.
        /// </summary>
        /// <param name="oList">List Control</param>
        /// <param name="oCollection">Collection to Bind</param>
        /// <param name="bAddSelectOneItem">Indicator to add a "select one" option</param>
        static public void BindLookupValues(ListControl oList,
                                            ICollection oCollection,
                                            bool bAddSelectOneItem)
        {
            BindLookupValues(oList, oCollection, null, bAddSelectOneItem);
        }

        /// <summary>
        /// Bind the specified collection to the specified 
        /// list setting the specified values as the currently
        /// selected value.
        /// </summary>
        /// <param name="oList">List Control</param>
        /// <param name="oCollection">Collection to Bind</param>
        /// <param name="szSelectedValue">Current Value</param>
        static public void BindLookupValues(ListControl oList,
                                            ICollection oCollection,
                                            string szSelectedValue)
        {
            BindLookupValues(oList, oCollection, szSelectedValue, false);
        }

        /// <summary>
        /// Binds the specified collection to the specified list, setting
        /// the specified value as the default optionally adding a 
        /// "select one" item.
        /// </summary>
        /// <param name="oList">List Control</param>
        /// <param name="oCollection">Collection to Bind</param>
        /// <param name="szSelectedValue">Current Value</param>
        /// <param name="bAddSelectOneItem">Indicator to add a "select one" option</param>
        static public void BindLookupValues(ListControl oList,
                                            ICollection oCollection,
                                            string szSelectedValue,
                                            bool bAddSelectOneItem)
        {
            oList.DataSource = oCollection;
            oList.DataTextField = "Meaning";
            oList.DataValueField = "Code";
            oList.DataBind();

            if (bAddSelectOneItem)
            {
                oList.Items.Insert(0, new ListItem(string.Empty, string.Empty));
            }

            if ((szSelectedValue != null) &&
                (szSelectedValue.Length > 0))
            {
                SetListDefaultValue(oList, szSelectedValue);
            }
        }

        /// <summary>
        /// Set the SelectedIndex on the specified control to
        /// the index that corresponds to the specified selected
        /// value.
        /// </summary>
        /// <param name="oList">List Control</param>
        /// <param name="iSelectedValue">Current Value</param>
        static public void SetListDefaultValue(ListControl oList,
                                               int iSelectedValue)
        {
            SetListDefaultValue(oList, iSelectedValue.ToString());
        }

        /// <summary>
        /// Set the SelectedIndex on the specified control to
        /// the index that corresponds to the specified selected
        /// value.
        /// </summary>
        /// <param name="oList">List Control</param>
        /// <param name="bSelectedValue">Current Value</param>
        static public void SetListDefaultValue(ListControl oList,
                                               bool bSelectedValue)
        {
            SetListDefaultValue(oList, bSelectedValue.ToString());
        }

        /// <summary>
        /// Set the SelectedIndex on the specified control to
        /// the index that corresponds to the specified selected
        /// value.
        /// </summary>
        /// <param name="oList">List Control</param>
        /// <param name="szSelectedValue">Current Value</param>
        static public void SetListDefaultValue(ListControl oList,
                                               string szSelectedValue)
        {
            oList.SelectedIndex = oList.Items.IndexOf(oList.Items.FindByValue(szSelectedValue));
        }


        /// <summary>
        /// Returns the virtual path to the current
        /// application
        /// </summary>
        /// <returns></returns>
        static public string GetVirtualPath()
        {
            return Utilities.GetConfigValue("VirtualPath");
        }


        /// <summary>
        /// Returns a formatted CSS link with the appropriate
        /// virtual path.
        /// </summary>
        /// <param name="szFileName">CSS file</param>
        /// <returns>Formatted CSS Link</returns>
        public string GetCSSFile(string szFileName)
        {
            return string.Format(CSS_LINK, GetVirtualPath(), szFileName);
        }



        /// <summary>
        /// Returns the ApplicationNameAbbr configuration value.
        /// </summary>
        /// <returns></returns>
        static public string GetApplicationVersion()
        {
            return Utilities.GetConfigValue("ApplicationVersion");
        }


        /// <summary>
        /// Returns the UnsupportedBrowserMsg configuration value.
        /// </summary>
        /// <returns></returns>
        static public string GetUnsupportedBrowserMsg()
        {
            return Utilities.GetConfigValue("UnsupportedBrowserMsg");
        }



        /// <summary>
        /// Returns the set of LookupValue objects for the
        /// specified value name.
        /// </summary>
        /// <param name="szName">Value Name</param>
        /// <returns>LookupValue objects</returns>
        public IBusinessObjectSet GetReferenceData(string szName)
        {
            return GetReferenceData(szName, "en-us");
        }

        /// <summary>
        /// Returns the set of LookupValue objects for the
        /// specified value name.
        /// </summary>
        /// <param name="szName">Value Name</param>
        /// <param name="szCulture">The culture to use when retrieving the data</param>
        /// <returns>LookupValue objects</returns>
        static protected IBusinessObjectSet GetReferenceData(string szName, string szCulture)
        {
            string szCacheName = string.Format(REF_DATA_NAME, szName, szCulture);

            IBusinessObjectSet oRefData = (BusinessObjectSet)HttpRuntime.Cache[szCacheName];
            if (oRefData == null)
            {

                if (_oCustom_CaptionMgr == null) {
                    _oCustom_CaptionMgr = new Custom_CaptionMgr();
                }
                oRefData = new Custom_CaptionMgr().GetByName(szName);

                if (oRefData.Count > 0)
                {
                    HttpRuntime.Cache.Insert(szCacheName, oRefData);
                }
            }

            if (oRefData.Count == 0)
            {
                throw new ApplicationUnexpectedException("No values found for reference data named '" + szName + "' and culture '" + szCulture + "'.");
            }

            // We want to make a copy of our lookup set because some of our
            // callers manipulate the set which we don't want affecting
            // others.
            IBusinessObjectSet oNewSet = new BusinessObjectSet(oRefData);

            return oNewSet;
        }

        /// <summary>
        /// Builds a set of Custom_Caption objects that is not queried from the 
        /// custom_caption table.  The specified SQL is expected to have the 
        /// code in position 0 and the meaning in position 1.
        /// </summary>
        /// <param name="szName">The name to give to the custom caption</param>
        /// <param name="szSQL"></param>
        /// <returns></returns>
        protected static IBusinessObjectSet GetNonCustomCaptionRefData(string szName, string szSQL)
        {
            IBusinessObjectSet oList = new BusinessObjectSet();

            IDataReader oReader = DBAccessFactory.getDBAccessProvider().ExecuteReader(szSQL, CommandBehavior.CloseConnection);
            try
            {
                while (oReader.Read())
                {
                    ICustom_Caption oCaption = new Custom_Caption();
                    oCaption.Name = szName;
                    oCaption.Code = oReader[0].ToString().Trim();
                    oCaption.Meaning = oReader[1].ToString().Trim();
                    oList.Add(oCaption);
                }
                return oList;
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }
        }



        /// <summary>
        /// Iterates through the items HtmlEncoding the displayed
        /// text.
        /// </summary>
        /// <param name="oListControl">List Control</param>
        virtual protected void PrepareForDisplay(ListControl oListControl)
        {
            foreach (ListItem item in oListControl.Items)
            {
                item.Text = Server.HtmlEncode(item.Text);
            }
        }


        /// <summary>
        /// Increments the internal counter for controlling the current column 
        /// index when processing a repeater control.
        /// </summary>
        /// <returns></returns>
        virtual protected string IncrementRepeaterCount()
        {
            _iRepeaterCount++;
            return string.Empty;
        }

        virtual protected string ResetRepeaterCount() {
            _iRepeaterCount = 0;
            return string.Empty;
        }

        virtual protected string ResetRepeaterRowCount() {
            _iRepeaterRowCount = 1;
            return string.Empty;
        }


        /// <summary>
        /// Return the element begin separator for a N column table
        /// row in a repeater based on the item count.
        /// </summary>
        /// <param name="iCount">Current Item Count</param>
        /// <param name="dNumCols">Number of Columns</param>
        /// <param name="szWidth">Width of Columns</param>
        /// <returns></returns>
        virtual protected string GetBeginSeparator(int iCount, decimal dNumCols, string szWidth) {
            return GetBeginSeparator(iCount, dNumCols, szWidth, false);
        }

        /// <summary>
        /// Return the element begin separator for a N column table
        /// row in a repeater based on the item count.
        /// </summary>
        /// <param name="iCount">Current Item Count</param>
        /// <param name="dNumCols">Number of Columns</param>
        /// <param name="szWidth">Width of Columns</param>
        /// <param name="bUseShadeRow"></param>
        /// <returns></returns>
        virtual protected string GetBeginSeparator(int iCount, decimal dNumCols, string szWidth, bool bUseShadeRow)
        {
            string szSeparator = string.Empty;

            if ((iCount == 1) ||
                ((iCount - 1) % dNumCols == 0))
            {
                if (bUseShadeRow) {
                    szSeparator = "<tr " + UIUtils.GetShadeClass(_iRepeaterRowCount) + ">";
                } else {
                    szSeparator = "<tr>";
                }
                
                _iRepeaterRowCount++;
            }

            szSeparator = szSeparator + "<td width=\"" + szWidth + "\" valign=\"top\">";
            return szSeparator;
        }

        /// <summary>
        /// Returns the element end separator for a N column table
        /// row in a repeater based on the item count.
        /// </summary>
        /// <param name="iCount">Record Count</param>
        /// <param name="dNumCols">Number of Columns</param>
        /// <returns>Separator</returns>
        virtual protected string GetEndSeparator(int iCount, decimal dNumCols)
        {
            string szSeparator = "</td>";
            if ((iCount % dNumCols) == 0)
            {
                szSeparator = szSeparator + "</tr>";
            }
            return szSeparator;
        }

        /// <summary>
        /// Returns the element complete separator for a N column table
        /// row in a repeater based on the item count.
        /// </summary>
        /// <param name="iCount">Record Count</param>
        /// <param name="dNumCols">Column Count</param>
        /// <returns>Separator</returns>
        virtual protected string GetCompleteSeparator(int iCount, decimal dNumCols)
        {
            if ((iCount % dNumCols) != 0)
            {
                return "</tr>";
            }
            return string.Empty;
        }


        /// <summary>
        /// Generates a JS function that detects the ENTER key and then invokes
        /// the specified button's onclick handler. This functionality is automatically 
        /// provided as part of the formfunctions.js file.  
        /// </summary>
        /// <param name="oButtonControl"></param>
        public static void SetEnterSubmitsForm(System.Web.UI.Control oButtonControl)
        {
            oButtonControl.Page.ClientScript.RegisterClientScriptBlock(oButtonControl.Page.GetType(), "EnterSubmits", string.Format(JS_ENTER_SUBMITS, oButtonControl.UniqueID));
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
            Response.Cookies[szName].Value = szValue;
        }

        protected void RemoveRequestParameter(string szName) {
            Session.Remove(szName);
            Response.Cookies[szName].Expires = DateTime.Now.AddDays(-1);
            
        }

        /// <summary>
        /// Helper method that removes the specified code
        /// from the Reference Set
        /// </summary>
        /// <param name="oLookupSet">Set of Lookup Values</param>
        /// <param name="szRemoveCode">Code to Remove</param>
        protected void RemoveReferenceCode(IBusinessObjectSet oLookupSet, string szRemoveCode)
        {
            ICustom_Caption oRemove = null;
            foreach (ICustom_Caption oCustom_Caption in oLookupSet)
            {
                if (oCustom_Caption.Code == szRemoveCode)
                {
                    oRemove = oCustom_Caption;
                    break;
                }
            }

            oLookupSet.Remove(oRemove);
        }

        /// <summary>
        /// Helper method that returns the value from the specified
        /// IDictionary that has the specified key.  If no value is
        /// found, and empty string is returned.
        /// </summary>
        /// <param name="szKey">Key</param>
        /// <param name="_htData">Data</param>
        /// <returns></returns>
        protected string GetValue(string szKey, IDictionary _htData)
        {
            if (_htData.Contains(szKey))
            {
                return Convert.ToString(_htData[szKey]);
            }

            return string.Empty;
        }

        /// <summary>
        /// Sets the page title
        /// </summary>
        /// <param name="szTitle"></param>
        /// <returns></returns>
        public void SetPageTitle(string szTitle)
        {
            SetPageTitle(szTitle, string.Empty);
        }

        /// <summary>
        ///  Sets the page title and sub-title
        /// </summary>
        /// <param name="szTitle"></param>
        /// <param name="szSubTitle"></param>
        public void SetPageTitle(string szTitle, string szSubTitle)
        {
            ((Label)this.Master.FindControl("lblPageHeader")).Text = szTitle;
            ((Label)this.Master.FindControl("lblPageSubheader")).Text = szSubTitle;
            Header.Title = "BBOS " + szTitle;
        }



        /// <summary>
        /// Helper method that returns the CSSClass
        /// for shading a row or not, depending on 
        /// the _iRepeaterCount.
        /// </summary>
        /// <returns></returns>
        protected string GetRowClass()
        {
            return GetRowClass(_iRepeaterCount);
        }

        /// <summary>
        /// Helper method that returns the CSSClass
        /// for shading a row or not, depending on 
        /// the specified count.
        /// </summary>
        /// <param name="iCount"></param>
        /// <returns></returns>
        protected string GetRowClass(int iCount)
        {
            if ((iCount % 2) == 0)
            {
                return "class=shaderow";
            }
            return string.Empty;
        }

        /// <summary>
        /// Adds client-side JS to prevent button double-clicks
        /// </summary>
        /// <param name="btnButton">Button to prevent double-clicking</param>
        protected void AddDoubleClickPreventionJS(WebControl btnButton)
        {
            //AddDoubleClickPreventionJS(btnButton, string.Empty);
            btnButton.Attributes.Add("tsiDisable", "true");
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
        /// Helper method that returns an EBBObjectMgr object.  This is
        /// cached in a member variable.
        /// </summary>
        /// <returns></returns>
        public GeneralDataMgr GetObjectMgr()
        {
            if (_oObjectMgr == null) {
                _oObjectMgr = new GeneralDataMgr(_oLogger, _oUser);
            }

            if (_oUser == null) {
                _oUser = new PRWebUser();
                _oUser.UserID = "-135";
                _oUser.prwu_WebUserID = -135;
            }

            // Always make sure we have a user object.  In some cases
            // this method is called before we have a valid user.  So
            // we end up with an ObjectMgr instance w/o a user.  So
            // always set to handle those cases.
           _oObjectMgr.User = _oUser;
           
           
           
            return _oObjectMgr;
        }

        /// <summary>
        /// Does a cascading lookup for the ReturnURL parameter.  The
        /// order of resolution is Request object, Session, then the
        /// specified default value.
        /// </summary>
        /// <param name="szDefaultURL"></param>
        /// <returns></returns>
        protected string GetReturnURL(string szDefaultURL)
        {
            string szReturnURL = null;
            if (!string.IsNullOrEmpty(Request["ReturnURL"]))
            {
                szReturnURL = Request["ReturnURL"];
            }

            if (string.IsNullOrEmpty(szReturnURL))
            {
                if (!string.IsNullOrEmpty((string)Session["ReturnURL"]))
                {
                    szReturnURL = (string)Session["ReturnURL"];
                }
            }

            if (string.IsNullOrEmpty(szReturnURL))
            {
                szReturnURL = szDefaultURL;
            }

            return szReturnURL;
        }

        /// <summary>
        /// Modifies the form control to enable the field validation
        /// JavaScript library.
        /// </summary>
        protected void EnableFormValidation()
        {
            Form.Attributes.Add("onsubmit", "return formOnSubmit(this);");
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_VALIDATION_FILE));
        }



        /// <summary>
        /// If true, JS is generated that translates the multipart ASP.NET
        /// client control names to the specified client name.
        /// </summary>
        /// <returns></returns>
        public virtual bool EnableJSClientIDTranslation()
        {
            return false;
        }



        /// <summary>
        /// Enables the client-side row highlighting for
        /// the specified grid view.
        /// </summary>
        /// <param name="gvGridView"></param>
        virtual protected void EnableRowHighlight(GridView gvGridView)
        {
            if (gvGridView.Rows.Count > 0)
            {
                Page.ClientScript.RegisterStartupScript(this.GetType(),
                                                        gvGridView.ID + "EnableRowHighlight",
                                                        "EnableRowHighlight(document.getElementById('" + gvGridView.ClientID + "'));",
                                                        true);
            }
        }

        /// <summary>
        /// Logs the user off of the system.  This must be public
        /// for user controls to access it.
        /// </summary>
        virtual public void LogoffUser()
        {
            FormsAuthentication.SignOut();
            Session.Abandon();
            Response.Redirect(Utilities.GetConfigValue("WebSiteHome", "Login.aspx"));
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

        protected const string SQL_BBOSUSERS_AUDIT = "INSERT INTO PRBBOSUserAudit (prbbosua_BBOSUserAuditID, prbbosua_HQID, prbbosua_CompanyID, prbbosua_PersonID, prbbosua_PageName, prbbosua_Action, prbbosua_ModifiedEmails, prbbosua_ModifiedAccess, prbbosua_CreatedBy, prbbosua_CreatedDate, prbbosua_UpdatedBy, prbbosua_UpdatedDate, prbbosua_TimeStamp) VALUES ({0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12})";
        /// <summary>
        /// Only create the web audit trail upon first load, not everytime
        /// the page is posted back.
        /// </summary>
        virtual protected void InsertBBOSUsersAudit(string szAction,
                                                    bool bModifiedEmails,
                                                    bool bModifiedAccess,
                                                    IDbTransaction oTran) {

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prbbosua_BBOSUserAuditID", GetObjectMgr().GetRecordID("PRBBOSUserAudit", oTran)));
            oParameters.Add(new ObjectParameter("prbbosua_HQID", Session["HQID"]));
            oParameters.Add(new ObjectParameter("prbbosua_CompanyID", Session["BBID"]));
            oParameters.Add(new ObjectParameter("prbbosua_PersonID", Session["PersonID"]));
            oParameters.Add(new ObjectParameter("prbbosua_PageName", Request.ServerVariables.Get("SCRIPT_NAME")));
            oParameters.Add(new ObjectParameter("prbbosua_Action", szAction));
            oParameters.Add(new ObjectParameter("prbbosua_ModifiedEmails", GetObjectMgr().GetPIKSCoreBool(bModifiedEmails)));
            oParameters.Add(new ObjectParameter("prbbosua_ModifiedAccess", GetObjectMgr().GetPIKSCoreBool(bModifiedAccess)));
            GetObjectMgr().AddAuditTrailParametersForInsert(oParameters, "prbbosua");

            GetDBAccess().ExecuteNonQuery(GetObjectMgr().FormatSQL(SQL_BBOSUSERS_AUDIT, oParameters), oParameters, oTran);
        }

        
        //protected const string CURRENT_MEMBERSHIP_MSG = "Your organization currently has a {0} which provides {1}  BBOS user licenses";
        //protected const string ADDL_USERS_MSG = " and {0} additional {1} licenses";

        //protected const string SQL_SELECT_MEMBERSHIP = "SELECT prod_Name, prod_PRWebUsers FROM PRService INNER JOIN NewProduct ON prse_ServiceCode = prod_code WHERE prod_ProductFamilyID=@ProductFamilyID AND prse_CancelCode IS NULL AND prse_HQID = @HQID";
        //protected string SetMembershipValues() {
        //    ArrayList oParameters = new ArrayList();
        //    oParameters.Add(new ObjectParameter("ProductFamilyID", Utilities.GetIntConfigValue("MembershipProductFamily", 5)));
        //    oParameters.Add(new ObjectParameter("HQID", Session["HQID"]));

        //    int iUserCount = 0;
        //    int iAddlUserCount = 0;
        //    string szMembershipName = "Unknown membership";
        //    string szAddlLicenseName = null;

        //    IDataReader oReader = GetDBAccess().ExecuteReader(SQL_SELECT_MEMBERSHIP, oParameters, CommandBehavior.CloseConnection, null);
        //    try {
        //        if (oReader.Read()) {
        //            iUserCount = oReader.GetInt32(1);
        //            szMembershipName = oReader.GetString(0);
        //        } else {
        //            AddUserMessage("No primary membership found.");
        //        }


        //    } finally {
        //        oReader.Close();
        //    }

        //    string szMsg = string.Format(CURRENT_MEMBERSHIP_MSG, szMembershipName, iUserCount);

        //    // The assumption here is that at this point, the company has the same type of additional
        //    // user licenses.
        //    oParameters = new ArrayList();
        //    oParameters.Add(new ObjectParameter("ProductFamilyID", Utilities.GetIntConfigValue("AdditionalUsersProductFamily", 6)));
        //    oParameters.Add(new ObjectParameter("HQID", Session["HQID"]));

        //    oReader = GetDBAccess().ExecuteReader(SQL_SELECT_MEMBERSHIP, oParameters, CommandBehavior.CloseConnection, null);
        //    try {
        //        while (oReader.Read()) {
        //            iAddlUserCount++;
        //            szAddlLicenseName = oReader.GetString(0);
        //        }

        //    } finally {
        //        oReader.Close();
        //    }

        //    if (iAddlUserCount > 0) {
        //        szMsg += string.Format(ADDL_USERS_MSG, iAddlUserCount, szAddlLicenseName);
        //    }

        //    Session["MaxLicenses"] = (iUserCount + iAddlUserCount);
        //    return szMsg + ".  Please confirm which individuals should receive a BBOS license by first entering their e-mail address and then selecting the \"Grant BBOS License\" checkbox.";
        //}

        protected bool IsBBOSProductionMode() {
            return Utilities.GetBoolConfigValue("BBOSProductionMode", false);
        }
        
    }
}