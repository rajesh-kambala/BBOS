/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2022-2022

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: PageBase.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.IO;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using PRCo.EBB.Util;
using TSI.Arch;
using TSI.BusinessObjects;
using TSI.DataAccess;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Provides common functionality for all Code-Behind pages
    /// in the application.
    /// </summary>
    public class PageBase : Page
    {
        /// <summary>
        /// A formatted CSS link to ensure the proper syntax is used.
        /// </summary>
        protected const string CSS_LINK = "<link href=\"{0}{1}\" type=\"text/css\" rel=\"stylesheet\" />";

        /// <summary>
        /// The main application CSS file.
        /// </summary>
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

        public IPRWebUser _oUser = null;
        protected GeneralDataMgr _oObjectMgr;
        protected IDBAccess _oDBAccess;
        protected bool _isErrorPage = false;

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
        //protected const string MOUSE_OVER_CURSOR = "onmouseover=\"this.style.cursor='hand'\" onmouseout=\"this.style.cursor='auto'\"";
        protected const string EMAIL_URL = "<a href=\"mailto:{0}\">{1}</a>";

        /// <summary>
        /// JavaScript function to fire the onclick event for the button that
        /// needs to respond to the ENTER key.
        /// </summary>
        protected const string JS_ENTER_SUBMITS = "<script type=\"text/javascript\">document.onkeydown = function(e) {{ e = e || window.event; if (e.keyCode == 13) {{ __doPostBack('{0}', ''); }} }};</script>";

        //protected string _szLocalizationURL;
        public const string DEFAULT_CULTURE = "en-us";
        public const string ENGLISH_CULTURE = "en-us";

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
            Error += new System.EventHandler(this.OnError);
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
        public static void LogMessage(string szMessage)
        {
            if (LoggerFactory.GetLogger() != null)
            {
                LoggerFactory.GetLogger().LogMessage(szMessage);
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

        protected void LogError(Exception e, string szAdditionalInformation)
        {
            if (_oLogger != null)
            {
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
                ILogger oLogger = LoggerFactory.GetLogger();
                Session["Logger"] = oLogger;
            }

            // Setup our Tracing Provider
            _oLogger = (ILogger)Session["Logger"];
            _oLogger.RequestName = Request.ServerVariables.Get("SCRIPT_NAME");

            if (!IsPostBack)
            {
                if ((!Request.IsSecureConnection) &&
                    (PageRequiresSecureConnection()))
                {

                    string url = Request.Url.ToString(); ;
                    url = url.Replace("http://", "https://");
                    Response.Redirect(url);
                }
            }

            // Check to see if we have a current user.
            if ((Session["oUser"] == null) &&
                (HttpContext.Current.User.Identity.IsAuthenticated))
            {
                // For whatever reason, our session got dumped but the
                // current user's auth cookie is still valid.  Re-initialize
                // our session.
                if (!InitializeUser(HttpContext.Current.User.Identity.Name))
                {
                    // If we couldn't initialize the user, then send them
                    // to the login page.
                    Response.Redirect($"{PageConstants.LOGIN}?logoff=1");
                    return;
                }

                RemoveSessionTracker(((IPRWebUser)Session["oUser"]).prwu_WebUserID);
            }

            // Even though we initialized the user, we still may not have a valid
            // object if this is not a secured page.
            _oUser = (IPRWebUser)Session["oUser"];
            if (_oUser != null)
            {
                _oLogger.UserID = _oUser.UserID;
                ((Sales.BBSI)Master).SetUserName(_oUser);
            }

            LogMessage("Page_Load");
            SetCulture(_oUser);

            // Check security before going any further.
            // There's no point in continuing the page setup
            // if the user cannot view it.
            if (!IsAuthorizedForPage())
            {
                throw new AuthorizationException(GetUnauthorizedForPageMsg());
            }

            if (!IsAuthorizedForData())
            {
                throw new AuthorizationException(GetUnauthorizedForPageMsg());
            }

            if ((_oUser != null) &&
                (_oUser.prwu_SecurityDisabled) &&
                (!_isErrorPage))
            {
                // Display a generic message, but we don't want this logged and floodign our support inbox.
                throw new ApplicationExpectedException(string.Format(Resources.Global.UnexpectedErrorMsg, Utilities.GetConfigValue("EMailSupportAddress")));
            }

            // Even though we initialized the user, we still may not have a valid
            // object if this is not a secured page.
            if (_oUser != null)
            {
                if (!IsPostBack)
                {
                    ValidateSession();
                    ExpireSessionTrackers();

                    _oUser.LogPage(Request.ServerVariables.Get("SCRIPT_NAME"), GetWebAuditTrailAssociatedID());
                    _oUser.CheckPageAccessCount();
                    _oUser.CheckPageAccessForSerialiedData();
                }
            }

            if (SessionTimeoutForPageEnabled())
            {
                if (Page != null && Page.Header != null)
                {
                    string szContent = ((Session.Timeout - 1) * 60).ToString() + ";url=" + PageConstants.AUTO_LOGOFF;

                    HtmlMeta RedirectMetaTag = new HtmlMeta();
                    RedirectMetaTag.HttpEquiv = "Refresh";
                    RedirectMetaTag.Content = szContent;
                    Page.Header.Controls.Add(RedirectMetaTag);
                }
            }
        }

        /// <summary>
        /// Determine if the current user is
        /// authorized to view this page.
        /// Should be overridden by all sub-classes
        /// </summary>
        /// <returns></returns>
        virtual protected bool IsAuthorizedForPage()
        {
            return false;
        }

        /// <summary>
        /// Ensures the Company/Person data being referenced is “listed”.
        /// Should be overridden by all sub-classes.
        /// </summary>
        /// <returns></returns>
        virtual protected bool IsAuthorizedForData()
        {
            return false;
        }

        /// <summary>
        /// The default error handler for the application.  Only
        /// unexpected errors should make it this far.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void OnError(object sender, System.EventArgs e)
        {
            // Transfer to Error.aspx to handle the appropriate display.
            Server.Transfer(PageConstants.ERROR);
        }

        private const string ERROR_BOX =
            "<h2>{0}</h2><div class=\"small_horizontal_box_content\">{1}{2}</div>";

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

            StringBuilder buttons = new StringBuilder();
            string button = string.Empty;
            if (bDisplayButtons)
            {
                if (bDisplayButtons)
                {
                    buttons.Append("<br/>&nbsp;<div align=\"right\">" + Environment.NewLine);
                    buttons.Append("<input type=\"button\" value=\"Previous Page\" onclick=\"history.go(-1);\" style=\"width:100px;\">" + Environment.NewLine);
                    buttons.Append("&nbsp;<input type=\"button\" value=\"Home\" onclick=\"location.href='default.aspx';\" style=\"width:100px;\">" + Environment.NewLine);
                }
            }

            return string.Format(ERROR_BOX, szBoxTitle, szMsg, buttons.ToString());
        }

        /// <summary>
        /// Generates the default page footer displaying the
        /// specified message and specified user ID.
        /// </summary>
        /// <returns>HTML Code</returns>
        virtual public void PreparePageFooter()
        {
            if (Master != null)
            {
                Literal litFooterDuration = ((Literal)Master.FindControl("litFooterDuration"));
                if (litFooterDuration != null)
                {
                    DateTime dtRequestEnd = DateTime.Now;
                    TimeSpan oTS = dtRequestEnd.Subtract(dtRequestStart);
                    litFooterDuration.Text = oTS.TotalMilliseconds.ToString();
                }
            }

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
                buffer.Append("<script type=\"text/javascript\">" + Environment.NewLine);
                foreach (string szMsg in _oUserMessages)
                {
                    LogMessage("Index: " + szMsg.IndexOf("'").ToString());
                    string szTmp = szMsg.Replace("'", "\\'");
                    //buffer.Append("alert('" + szTmp + "'.replace(/NEWLINE/g, \"\\n\"));" + Environment.NewLine);
                    buffer.Append("bootbox.alert('" + szTmp + "'.replace(/NEWLINE/g, \"\\n\"));" + Environment.NewLine);   //Implemented bootbox messages
                }

                buffer.Append("</script>" + Environment.NewLine);
            }

            // We may have messages from other requests
            if (Session[USER_MSG_ID] != null)
            {
                string _szUserMessage = (string)Session[USER_MSG_ID];
                buffer.Append("<script language=JavaScript>" + Environment.NewLine);
                buffer.Append("bootbox.alert('" + _szUserMessage + "'.replace(/NEWLINE/g, \"\\n\"));" + Environment.NewLine);
                buffer.Append("</script>" + Environment.NewLine);
                Session["szUserMessage"] = null;
            }

            return buffer.ToString();
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
                return "Yes";
            else
                return "No";
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

        /// <summary>
        /// Initializes the session with specific user
        /// values.
        /// </summary>
        /// <param name="szEmail">Email Address</param>
        /// <returns>Success Indicator</returns>
        virtual protected bool InitializeUser(string szEmail)
        {
            IPRWebUser oUser = null;
            try
            {
                oUser = GetUser(szEmail);
            }
            catch (ObjectNotFoundException)
            {
                return false;
            }
            return InitializeUser(oUser);
        }

        /// <summary>
        /// Initializes the session with specific user
        /// values.
        /// </summary>
        /// <param name="oUser">User object</param>
        /// <returns>Success Indicator</returns>
        virtual protected bool InitializeUser(IPRWebUser oUser)
        {
            _oLogger.UserID = oUser.UserID;
            LogMessage("InitializeUser: " + oUser.Email);

            // Stash our info in session.
            Session["oUser"] = oUser;
            SetCulture(oUser);
            oUser.UpdateLoginStats();

            return true;
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
                if (szKey == null)
                {
                    continue;
                }

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
        public void AddUserMessage(string szMsg)
        {
            AddUserMessage(szMsg, false);
        }

        /// <summary>
        /// Add a message to the queue to display to
        /// the user when the page is rendered.
        /// </summary>
        /// <param name="szMsg"></param>
        /// <param name="bInSession">Indicates if the Session should be used to transmit the message</param>
        public void AddUserMessage(string szMsg, bool bInSession)
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

        static public void SetListValue(ListControl oList, string szSelectedValue)
        {
            ListItem oItem = oList.Items.FindByValue(szSelectedValue);
            if (oItem != null)
            {
                oItem.Selected = true;
            }
        }

        protected void SetListValues(ListControl oList, string szIDValues)
        {
            if (string.IsNullOrEmpty(szIDValues))
            {
                return;
            }

            string[] aszValues = szIDValues.Split(new char[] { ',' });
            foreach (string szValue in aszValues)
            {
                if (!String.IsNullOrEmpty(szValue))
                {
                    SetListValue(oList, szValue);
                }
            }
        }

        /// <summary>
        /// Adds the specified value to the string build, delimiting it with a comma.
        /// </summary>
        /// <param name="sbList"></param>
        /// <param name="szValue"></param>
        static public void AddDelimitedValue(StringBuilder sbList, string szValue)
        {
            AddDelimitedValue(sbList, szValue, ",");
        }

        /// <summary>
        ///  Adds the specified value to the string build
        /// </summary>
        /// <param name="sbList"></param>
        /// <param name="szValue"></param>
        /// <param name="szDelimiter"></param>
        static public void AddDelimitedValue(StringBuilder sbList, string szValue, string szDelimiter)
        {
            if (string.IsNullOrEmpty(szValue))
            {
                return;
            }

            if (sbList.Length > 0)
            {
                sbList.Append(szDelimiter);
            }
            sbList.Append(szValue);
        }

        /// <summary>
        /// Iterates the items in the specified control and returns a comma-delimited
        /// list of the selected item values.
        /// </summary>
        /// <param name="oListControl"></param>
        /// <returns></returns>
        static public string GetSelectedValues(ListControl oListControl)
        {
            StringBuilder sbSelectedValues = new StringBuilder();
            foreach (ListItem oListItem in oListControl.Items)
            {
                if (oListItem.Selected)
                {
                    if (sbSelectedValues.Length > 0)
                        sbSelectedValues.Append(",");
                    sbSelectedValues.Append(oListItem.Value);
                }
            }
            return sbSelectedValues.ToString();
        }

        /// <summary>
        /// Determines if Session Tracker is enabled
        /// </summary>
        /// <returns>Indicator</returns>
        static public bool SessionTrackerEnabled()
        {
            return Utilities.GetBoolConfigValue("SessionTracker.Enabled", false);
        }

        /// <summary>
        /// Returns the Required Field Indicator html for display
        /// on forms.
        /// </summary>
        /// <returns>Required Field Indicator</returns>
        static public string GetRequiredFieldIndicator()
        {
            return Utilities.GetConfigValue("RequiredFieldIndicator");
        }

        /// <summary>
        /// Returns the Required Field html mess for display on forms.  
        /// Incorporates the Required Field Indicator in the message.
        /// </summary>
        /// <returns>Required Field Message</returns>
        static public string GetRequiredFieldMsg()
        {
            if (_szRequiredFieldMsg == null)
            {
                _szRequiredFieldMsg = string.Format(Resources.Global.RequiredFieldsMsg, GetRequiredFieldIndicator());
            }
            return _szRequiredFieldMsg;
        }

        /// <summary>
        /// Returns the Wildcard Field Indicator html for display
        /// on forms.
        /// </summary>
        /// <returns>Wildcard Field Indicator</returns>
        static public string GetWildcardFieldIndicator()
        {
            return Utilities.GetConfigValue("WildcardFieldIndicator");
        }

        /// <summary>
        /// Returns the Wildcard Field html mess for display on forms.  
        /// Incorporates the Wildcard Field Indicator in the message.
        /// </summary>
        /// <returns>Wildcard Field Message</returns>
        static public string GetWildcardFieldMsg()
        {
            if (_szWildcardFieldMsg == null)
            {
                _szWildcardFieldMsg = string.Format(Utilities.GetConfigValue("WildcardFieldMsg"), GetWildcardFieldIndicator());
            }
            return _szWildcardFieldMsg;
        }

        /// <summary>
        /// Returns the ApplicationName configuration value.
        /// </summary>
        /// <returns></returns>
        static public string GetApplicationNameAbbr()
        {
            return Resources.Global.ApplicationAbbreviation;
        }

        /// <summary>
        /// Returns the NoResultsFoundMsg configuration value.
        /// </summary>
        /// <returns></returns>
        static public string GetNoResultsFoundMsg(string szName)
        {
            return string.Format(Resources.Global.NoResultsFoundMsg, szName);
        }

        /// <summary>
        /// Returns the message to display if the user cannot view
        /// a page.
        /// </summary>
        /// <returns></returns>
        static public string GetUnauthorizedForPageMsg()
        {
            return Resources.Global.UnauthorizedForPageMsg;
        }

        /// <summary>
        /// Returns the set of LookupValue objects for the
        /// specified value name.
        /// </summary>
        /// <param name="szName">Value Name</param>
        /// <returns>LookupValue objects</returns>
        public IBusinessObjectSet GetReferenceData(string szName)
        {
            return GetReferenceData(szName, GetCurrentCulture(_oUser));
        }

        /// <summary>
        /// Returns the set of LookupValue objects for the
        /// specified value name.
        /// </summary>
        /// <param name="szName">Value Name</param>
        /// <param name="szCulture">The culture to use when retrieving the data</param>
        /// <returns>LookupValue objects</returns>
        static public IBusinessObjectSet GetReferenceData(string szName, string szCulture)
        {
            string szCacheName = string.Format(REF_DATA_NAME, szName, szCulture);

            IBusinessObjectSet oRefData = (BusinessObjectSet)HttpRuntime.Cache[szCacheName];
            if (oRefData == null)
            {
                switch (szName)
                {
                    case "IntegrityRating":
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT prin_IntegrityRatingID, prin_Name FROM PRIntegrityRating WITH (NOLOCK) WHERE prin_IsNumeral IS NULL ORDER BY prin_Order desc");
                        break;
                    case "IntegrityRating2_Display":
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT prin_IntegrityRatingID As Code, prin_Name + ' - ' + dbo.ufn_GetCustomCaptionValue('prin_Name', prin_Name, '" + szCulture + "') As Meaning FROM PRIntegrityRating WITH (NOLOCK) WHERE prin_IntegrityRatingID NOT IN (3,4) ORDER BY prin_Order DESC");
                        break;
                    case "IntegrityRating2_All":
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT prin_IntegrityRatingID As Code, prin_Name + ' - ' + dbo.ufn_GetCustomCaptionValue('prin_Name', prin_Name, '" + szCulture + "') As Meaning FROM PRIntegrityRating WITH (NOLOCK) ORDER BY prin_Order DESC");
                        break;
                    case "IntegrityRating3":
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT prin_IntegrityRatingID As Code, prin_Name + ' - ' + dbo.ufn_GetCustomCaptionValue('prin_Name', prin_Name, '" + szCulture + "') As Meaning FROM PRIntegrityRating WITH (NOLOCK) WHERE prin_IsNumeral IS NULL ORDER BY prin_Order DESC");
                        break;
                    case "TESPayRating":
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT prpy_PayRatingId, prpy_TradeReportDescription FROM PRPayRating WITH (NOLOCK) WHERE prpy_IsNumeral IS NULL AND prpy_Deleted IS NULL ORDER BY prpy_Order");
                        break;
                    case "CreditWorthRating":
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT prcw_CreditWorthRatingID, prcw_Name FROM PRCreditWorthRating WITH (NOLOCK) WHERE prcw_IsNumeral IS NULL ORDER BY prcw_Order desc");
                        break;
                    case "CreditWorthRating2": // Non-Lumber Credit Worth Ratings
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT prcw_CreditWorthRatingId  As Code, prcw_Name As Meaning FROM PRCreditWorthRating WITH (NOLOCK) WHERE prcw_IndustryType LIKE '%,P,%' AND prcw_IsNumeral IS NULL ORDER BY prcw_Order DESC");
                        break;
                    case "CreditWorthRating2L": // Lumber Credit Worth Ratings
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT prcw_CreditWorthRatingId  As Code, prcw_Name As Meaning FROM PRCreditWorthRating WITH (NOLOCK) WHERE prcw_IndustryType LIKE '%,L,%' AND prcw_IsNumeral IS NULL ORDER BY prcw_Order DESC");
                        break;
                    case "PayRating2":
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT prpy_PayRatingId As Code, prpy_Name + ' - ' + dbo.ufn_GetCustomCaptionValue('prpy_Name', prpy_Name, '" + szCulture + "') As Meaning FROM PRPayRating WITH (NOLOCK) WHERE prpy_IsNumeral IS NULL AND prpy_Deleted IS NULL ORDER BY prpy_Order");
                        break;
                    case "DLPhrases":
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT prdlp_DLPhraseID, prdlp_Phrase FROM PRDLPhrase WITH (NOLOCK) ORDER BY prdlp_Order");
                        break;
                    case "StockExchanges":
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT prex_StockExchangeId, prex_Name FROM PRStockExchange WITH (NOLOCK) WHERE prex_Publish = 'Y' ORDER BY prex_Order");
                        break;
                    case "PayIndicator":
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT capt_code As Code, capt_code + ' - ' + cast(capt_us as varchar(max)) As Meaning FROM Custom_Captions WHERE capt_family = 'PayIndicatorDescription' ORDER BY capt_Order");
                        break;
                    case "NewProduct":
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT prod_code, prod_name, prod_productfamilyid FROM NewProduct WHERE prod_productfamilyid = 5 ORDER BY prod_PRSequence");
                        break;
                    case "NewProduct_Lumber":
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT prod_code, prod_code as prod_name, prod_productfamilyid, prod_IndustryTypeCode FROM NewProduct WHERE prod_productfamilyid = 5 AND prod_IndustryTypeCode LIKE '%L%' ORDER BY prod_PRSequence ");
                        break;
                    case "NewProduct_Produce":
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT prod_code, prod_code as prod_name, prod_productfamilyid, prod_IndustryTypeCode FROM NewProduct WHERE prod_productfamilyid = 5 AND prod_IndustryTypeCode not LIKE '%L%' ORDER BY prod_PRSequence");
                        break;
                    case "prci_SalesTerritory":
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT capt_code As Code, capt_code + ' ' + cast(capt_us as varchar(max)) As Meaning FROM Custom_Captions WHERE capt_family = 'prci_SalesTerritory' ORDER BY capt_Order");
                        break;
                    case "NumEmployees":
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT capt_code As Code, cast(capt_us as varchar(max)) As Meaning FROM Custom_Captions WHERE capt_family = 'NumEmployees' AND capt_code <> '0' ORDER BY capt_Order");
                        break;

                    default:
                        if (_oCustom_CaptionMgr == null)
                        {
                            _oCustom_CaptionMgr = new Custom_CaptionMgr();
                        }
                        oRefData = new Custom_CaptionMgr().GetByName(szName);
                        break;
                }

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
            return GetRequestParameter(szName, bRequired, false, false);
        }

        protected string GetRequestParameter(string szName, bool bRequired, bool bThrowBookmarkError)
        {
            return GetRequestParameter(szName, bRequired, bThrowBookmarkError, false);
        }

        protected string GetRequestParameter(string szName, bool bRequired, bool bThrowBookmarkError, bool redirectToHome)
        {
            // Pass 1: Look in the request, i.e. querystring and form input
            if ((Request[szName] != null) &&
                (Request[szName].Length > 0))
            {
                return Request[szName];
            }

            // Pass 2: Look in the session
            if ((Session[szName] != null) &&
                (Session[szName].ToString().Length > 0))
            {
                return Session[szName].ToString();
            }

            // Pass 3: Look for a client cookie
            if (Request.Cookies != null)
            {
                if ((Request.Cookies[szName] != null) &&
                    (Request.Cookies[szName].Value.Length > 0))
                {
                    return Request.Cookies[szName].Value;
                }
            }

            if (bRequired)
            {
                if (redirectToHome)
                {
                    Response.Redirect(PageConstants.BBOS_MOBILE_SALES_HOME);
                    return null;
                }

                if (bThrowBookmarkError)
                    throw new ApplicationExpectedException(Resources.Global.BookmarkError);
                else
                    throw new ApplicationUnexpectedException(string.Format(Resources.Global.ErrorParameterMissing, szName, Request.RawUrl));
            }

            return null;
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

        public void SetPageTitle(string szTitle, string szSubTitle)
        {
            SetPageTitle(szTitle, szSubTitle, false);
        }

        /// <summary>
        ///  Sets the page title and sub-title
        /// </summary>
        public void SetPageTitle(string szTitle, string szSubTitle, bool bShowPrintButton)
        {
            if (Master != null && Master.FindControl("pageHeader") != null)
            {
                ((Literal)Master.FindControl("pageHeader")).Text = szTitle;

                if (Master.FindControl("btnPrint") != null)
                    ((ImageButton)Master.FindControl("btnPrint")).Visible = bShowPrintButton;
            }

            if (!string.IsNullOrEmpty(szSubTitle))
            {
                if (Master != null && Master.FindControl("pageSubheader") != null)
                {
                    ((Literal)Master.FindControl("pageSubheader")).Text = " / " + szSubTitle;
                }
            }

            if (Header != null)
            {
                Header.Title = GetApplicationNameAbbr() + " " + szTitle;
            }
        }

        /// <summary>
        /// Helper method that returns the associated ID for the PRWebAuditTrail
        /// record.  May be overridden by sub-classes when needed.
        /// </summary>
        /// <returns></returns>
        virtual protected string GetWebAuditTrailAssociatedID()
        {
            if (Request["CompanyID"] == "undefined")
            {
                DeleteCookie("CompanyID");
                return null;
            }

            if (!String.IsNullOrEmpty(Request["CompanyID"]))
            {
                int iCompanyID = 0;
                if (!int.TryParse(Request["CompanyID"], out iCompanyID))
                {
                    if (!_isErrorPage)
                    {
                        LogError(new ArgumentException($"Invalid CompanyID parameter specified: {Request["CompanyID"]}"));
                        return null;
                    }
                    else
                        return null;
                }


                if (iCompanyID < Utilities.GetIntConfigValue("MinCompanyID", 100000))
                {
                    if (!_isErrorPage)
                    {
                        LogError(new ArgumentException($"Invalid CompanyID parameter specified: {Request["CompanyID"]}"));
                        return null;
                    }
                    else
                        return null;
                }

                return Request["CompanyID"];
            }

            if (!String.IsNullOrEmpty(Request["PersonID"]))
            {
                int iPersonID = 0;
                if (!int.TryParse(Request["PersonID"], out iPersonID))
                    throw new ArgumentException($"Invalid PersonID parameter specified: {Request["PersonID"]}");

                if (iPersonID < Utilities.GetIntConfigValue("MinPersonID", 1))
                    throw new ArgumentException($"Invalid PersonID parameter specified: {Request["PersonID"]}");

                return Request["PersonID"];
            }

            return null;
        }

        protected void DeleteCookie(string name)
        {
            HttpCookie aCookie = new HttpCookie(name);
            aCookie.Expires = DateTime.Now.AddDays(-1);
            Response.Cookies.Add(aCookie);
        }

        /// <summary>
        /// Helper method that returns the associated type for the PRWebAuditTrail
        /// record.  May be overridden by sub-classes when needed.
        /// </summary>
        /// <returns></returns>
        virtual protected string GetWebAuditTrailAssociatedType()
        {
            if (!String.IsNullOrEmpty(Request["CompanyID"]))
            {
                return "C";
            }

            if (!String.IsNullOrEmpty(Request["PersonID"]))
            {
                return "P";
            }

            return null;
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
            if (_oObjectMgr == null)
            {
                _oObjectMgr = new GeneralDataMgr(_oLogger, _oUser);
            }

            // Always make sure we have a user object.  In some cases
            // this method is called before we have a valid user.  So
            // we end up with an ObjectMgr instance w/o a user.  So
            // always set to handle those cases.
            _oObjectMgr.User = _oUser;
            return _oObjectMgr;
        }

        /// <summary>
        /// Modifies the form control to enable the field validation
        /// JavaScript library.
        /// </summary>
        protected void EnableFormValidation()
        {
            Form.Attributes.Add("onsubmit", "return formOnSubmit(document.getElementById('" + Form.Name + "'));");
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_VALIDATION_FILE));
        }

        /// <summary>
        /// Only create the web audit trail upon first load, not everytime
        /// the page is posted back.
        /// </summary>
        virtual protected void InsertWebAudit()
        {
            if (!IsPostBack)
            {
                GetObjectMgr().InsertWebAuditTrail(Request.ServerVariables.Get("SCRIPT_NAME"),
                                                 FormatQueryStringParms(false),
                                                 GetWebAuditTrailAssociatedID(),
                                                 GetWebAuditTrailAssociatedType(),
                                                 Request.Browser.Browser,
                                                 Request.Browser.Version,
                                                 Request.Browser.Platform,
                                                 Request.ServerVariables["REMOTE_ADDR"],
                                                 Request.UserAgent);
            }
        }

        public void AddCacheValue(string szKey, object oData)
        {
            string szCacheName = string.Format(REF_DATA_NAME, szKey, GetCurrentCulture(_oUser));
            HttpContext.Current.Cache.Insert(szCacheName, oData, null, System.Web.Caching.Cache.NoAbsoluteExpiration, TimeSpan.FromHours(2));
        }

        public object GetCacheValue(string szKey)
        {
            string szCacheName = string.Format(REF_DATA_NAME, szKey, GetCurrentCulture(_oUser));
            return HttpContext.Current.Cache[szCacheName];
        }

        private string SESSION_TRACKER_LOCK = "x";
        /// <summary>
        /// Determines if the user has a valid session.  The goal is to minimize account sharing
        /// so we will stash a GUID on the client.  Each subsequent request validates that GUID
        /// against what we have in memory.
        /// </summary>
        protected void ValidateSession()
        {
            if (!EnableSessionTrackerForPage())
            {
                return;
            }

            Hashtable htSessionTracker = GetSessionTrackers();

            // Do we have a session tracker?  If not, create one and
            // send the user on their merry way...
            if (!htSessionTracker.ContainsKey(_oUser.prwu_WebUserID))
            {
                CreateSessionTracker();
                return;
            }

            SessionTracker oSessionTracker = (SessionTracker)htSessionTracker[_oUser.prwu_WebUserID];

            // Has our Session expired?  If so, create a new one
            // and send the user on their merry way.
            if (oSessionTracker.Expiration < DateTime.Now)
            {
                htSessionTracker.Remove(_oUser.prwu_WebUserID);
                CreateSessionTracker();
                return;
            }

            // Our session has not expired, so now check the GUID and SessionID's. If they are not the same
            // then we probably have a shared login. Note that most of the time this will be caught by the
            // GUID. Using the session as well gives an extra check that cannot be modified by the user.
            const string SessionTrackerIDCheckEnabled = "SessionTrackerIDCheckEnabled";

            if (Utilities.GetBoolConfigValue(SessionTrackerIDCheckEnabled, true) && (!_oUser.SessionTrackerIDCheckDisabled))
            {
                string cookie_guid = ((Request.Cookies[PageConstants.BBOS_MOBILE_SALES_SESSIONID] != null) ? Request.Cookies[PageConstants.BBOS_MOBILE_SALES_SESSIONID].Value : String.Empty);
                if ((cookie_guid != oSessionTracker.GUID) || Session.SessionID != oSessionTracker.SessionID)
                {

                    oSessionTracker.ViolationCount++;

                    if (Utilities.GetBoolConfigValue("SessionTrackerEnableNotification", true))
                    {
                        StringBuilder sbSessionTrackerDetails = new StringBuilder("The following user failed the BBOS security check:" + Environment.NewLine);
                        sbSessionTrackerDetails.Append(Environment.NewLine);
                        sbSessionTrackerDetails.Append($"{DateTime.Now}" + Environment.NewLine);
                        sbSessionTrackerDetails.Append($"{_oUser.FirstName} {_oUser.LastName} ({_oUser.prwu_WebUserID}): {_oUser.Email.Trim()}" + Environment.NewLine);
                        sbSessionTrackerDetails.Append($"User IP Address: {Request.ServerVariables["REMOTE_ADDR"]}" + Environment.NewLine);
                        sbSessionTrackerDetails.Append($"User Browser: {Request.Browser.Browser}" + Environment.NewLine);
                        sbSessionTrackerDetails.Append($"User Browser Version: {Request.Browser.Version}" + Environment.NewLine);
                        sbSessionTrackerDetails.Append($"User Browser Platform: {Request.Browser.Platform}" + Environment.NewLine);
                        sbSessionTrackerDetails.Append($"User Browser UserAgent: {Request.UserAgent}" + Environment.NewLine);

                        sbSessionTrackerDetails.Append(Environment.NewLine);
                        sbSessionTrackerDetails.Append($"If both GUID and Session IDs below do not match, we get this security alert." + Environment.NewLine);
                        sbSessionTrackerDetails.Append($"Cookie GUID: {cookie_guid}" + Environment.NewLine);
                        sbSessionTrackerDetails.Append($"SessionTracker GUID: {oSessionTracker.GUID}" + Environment.NewLine);
                        sbSessionTrackerDetails.Append($"Session SessionID: {Session.SessionID}" + Environment.NewLine);
                        sbSessionTrackerDetails.Append($"SessionTracker SessionID: {oSessionTracker.SessionID}" + Environment.NewLine);

                        sbSessionTrackerDetails.Append(Environment.NewLine);
                        sbSessionTrackerDetails.Append($"SessionTracker UserID: {oSessionTracker.UserID}" + Environment.NewLine);
                        sbSessionTrackerDetails.Append($"SessionTracker FirstAccess: {oSessionTracker.FirstAccess}" + Environment.NewLine);
                        sbSessionTrackerDetails.Append($"SessionTracker LastRequest: {oSessionTracker.LastRequest}" + Environment.NewLine);
                        sbSessionTrackerDetails.Append($"SessionTracker Email: {oSessionTracker.Email}" + Environment.NewLine);
                        sbSessionTrackerDetails.Append($"SessionTracker PageCount: {oSessionTracker.PageCount}" + Environment.NewLine);
                        sbSessionTrackerDetails.Append($"SessionTracker IP Address: {oSessionTracker.IPAddress}" + Environment.NewLine);
                        sbSessionTrackerDetails.Append($"SessionTracker Browser UserAgent: {oSessionTracker.BrowserUserAgent}" + Environment.NewLine);


                        if (oSessionTracker.ViolationCount > Utilities.GetIntConfigValue("SessionTrackerViolationThreshold", 5))
                        {

                            try
                            {
                                //Defect 6973 - emails via stored proc
                                GetObjectMgr().SendEmail_Text(Utilities.GetConfigValue("SessionTrackingNotificationEmail", "bbossessionalert@bluebookservices.com"),
                                        Utilities.GetConfigValue("SessionTrackingNotificationSubject", string.Format("BBOS Security Violation: {0}", _oUser.Email)),
                                        sbSessionTrackerDetails.ToString(),
                                        "PageBase.cs",
                                        null);
                            }
                            catch (Exception eX)
                            {
                                // Don't display anything to the user.
                                _oLogger.LogError($"Error emailing session tracker info.", eX);
                            }
                        }

                        string file = null;
                        try
                        {
                            file = Path.Combine(Utilities.GetConfigValue("SessionTrackingLogFolder", @"C:\Temp"), $"{_oUser.Email.Trim()}_{DateTime.Now:yyyyMMdd-HHmmss}.txt");
                            System.IO.File.WriteAllText(file, sbSessionTrackerDetails.ToString());
                        }
                        catch (Exception eX)
                        {
                            // Don't display anything to the user.
                            _oLogger.LogError($"Error writing session tracker info to file: {file}.", eX);
                        }
                    }



                    // We are going to allow some number of violations before causing problems for the user
                    // We are finding that some legitimate users are having new cookies or new session IDs and we're
                    // not sure if we are triggering it somehow on the server by updating the config, etc.
                    if (oSessionTracker.ViolationCount > Utilities.GetIntConfigValue("SessionTrackerViolationThreshold", 5))
                    {
                        // The login page should never get here, but we'll do
                        // a little check in case it does so that we don't try
                        // to redirect back to ourself.
                        if (Request.Path != FormsAuthentication.LoginUrl)
                        {
                            LogoffWithMessage("1");
                            return;
                        }
                    }
                    else
                    {
                        // Recreate the session with the current info, 
                        // but save the violation count
                        htSessionTracker.Remove(_oUser.prwu_WebUserID);
                        SessionTracker newSession = CreateSessionTracker();
                        newSession.ViolationCount = oSessionTracker.ViolationCount;
                        newSession.PageCount = oSessionTracker.PageCount;
                        newSession.FirstAccess = oSessionTracker.FirstAccess;
                        oSessionTracker = newSession;
                    }
                }
            }

            oSessionTracker.PageCount++;
            oSessionTracker.LastRequest = DateTime.Now;
            SetSessionTrackerCookie(oSessionTracker);
        }

        protected void LogoffWithMessage(string msgID)
        {
            Session.Remove("oUser");
            FormsAuthentication.SignOut();
            string login_uri = FormsAuthentication.LoginUrl;
            login_uri += ((login_uri.IndexOf('?') > 0) ? "&" : "?") + "MsgID=" + msgID;
            Response.Redirect(login_uri);
        }

        /// <summary>
        /// Ensure that there is a session tracker existing in the application object
        /// </summary>
        protected Hashtable GetSessionTrackers()
        {
            Hashtable htSessionTracker = (Hashtable)Application[PageConstants.SESSION_TRACKER];
            if (htSessionTracker == null)
            {
                htSessionTracker = new Hashtable();
                Application.Lock();
                Application.Add(PageConstants.SESSION_TRACKER, htSessionTracker);
                Application.UnLock();
            }
            return htSessionTracker;
        }

        /// <summary>
        /// Creates the SessionTracker object for the current user and
        /// stores the GUID on the client.
        /// </summary>
        protected SessionTracker CreateSessionTracker()
        {
            SessionTracker oSessionTracker = new SessionTracker();

            lock (SESSION_TRACKER_LOCK)
            {
                // This handles double-clicks, etc. 
                if (((Hashtable)Application[PageConstants.SESSION_TRACKER]).ContainsKey(_oUser.prwu_WebUserID))
                    return (SessionTracker)((Hashtable)Application[PageConstants.SESSION_TRACKER])[_oUser.prwu_WebUserID];

                oSessionTracker.SessionID = Session.SessionID;
                oSessionTracker.FirstAccess = DateTime.Now;
                oSessionTracker.LastRequest = DateTime.Now;
                oSessionTracker.UserID = _oUser.prwu_WebUserID;
                oSessionTracker.Email = _oUser.Email;
                oSessionTracker.PageCount = 1;
                oSessionTracker.GUID = System.Guid.NewGuid().ToString();
                oSessionTracker.BrowserUserAgent = Request.UserAgent;
                oSessionTracker.IPAddress = Request.ServerVariables["REMOTE_ADDR"];

                ((Hashtable)Application[PageConstants.SESSION_TRACKER]).Add(_oUser.prwu_WebUserID, oSessionTracker);
            }

            SetSessionTrackerCookie(oSessionTracker);

            return oSessionTracker;
        }

        protected void SetSessionTrackerCookie(SessionTracker oSessionTracker)
        {
            oSessionTracker.Expiration = DateTime.Now.AddHours(Utilities.GetIntConfigValue("SessionTrackerCookieHours", 8));
            Response.Cookies[PageConstants.BBOS_MOBILE_SALES_SESSIONID].Value = oSessionTracker.GUID;
            Response.Cookies[PageConstants.BBOS_MOBILE_SALES_SESSIONID].Expires = DateTime.Now.AddHours(Utilities.GetIntConfigValue("SessionTrackerCookieHours", 8));
        }

        /// <summary>
        /// Removes the specified SessionTracker from memory.  Note: similar
        /// code exists in the EBB.Master Logout method.
        /// </summary>
        /// <param name="iUserID"></param>
        protected void RemoveSessionTracker(int iUserID)
        {
            Hashtable htSessionTracker = (Hashtable)Application[PageConstants.SESSION_TRACKER];
            if (htSessionTracker != null)
            {
                if (((Hashtable)Application[PageConstants.SESSION_TRACKER]).ContainsKey(iUserID))
                {

                    lock (SESSION_TRACKER_LOCK)
                    {
                        ((Hashtable)Application[PageConstants.SESSION_TRACKER]).Remove(iUserID);
                    }

                    // Response.Cookies.Remove(PageConstants.BBOS_SESSIONID); -- does not work on all browsers
                    Response.Cookies[PageConstants.BBOS_MOBILE_SALES_SESSIONID].Expires = DateTime.Now.AddYears(-1);
                }
            }
        }

        protected void ResetSessionTracker(int iUserID)
        {
            Hashtable htSessionTracker = GetSessionTrackers();
            if (((Hashtable)Application[PageConstants.SESSION_TRACKER]).ContainsKey(iUserID))
            {
                SessionTracker oSessionTracker = (SessionTracker)((Hashtable)Application[PageConstants.SESSION_TRACKER])[iUserID];
                oSessionTracker.SessionID = Session.SessionID;
            }
        }

        /// <summary>
        /// Iterates through the sessions and removes any that have expired.
        /// </summary>
        protected void ExpireSessionTrackers()
        {
            if (!EnableSessionTrackerForPage())
            {
                return;
            }

            try
            {
                List<Int32> lRemoveIDs = new List<int>();
                Hashtable htSessionTracker = (Hashtable)Application[PageConstants.SESSION_TRACKER];
                if (htSessionTracker != null)
                {

                    lock (SESSION_TRACKER_LOCK)
                    {
                        IDictionaryEnumerator oEnum = htSessionTracker.GetEnumerator();
                        while (oEnum.MoveNext())
                        {
                            SessionTracker oSessionTracker = (SessionTracker)oEnum.Value;

                            if (oSessionTracker.Expiration < DateTime.Now)
                            {
                                lRemoveIDs.Add(oSessionTracker.UserID);
                            }
                        }
                    }
                }

                // Now remove the expired sessions.
                if (lRemoveIDs.Count > 0)
                {

                    lock (SESSION_TRACKER_LOCK)
                    {
                        foreach (int iID in lRemoveIDs)
                        {
                            htSessionTracker.Remove(iID);
                        }
                    }
                }

            }
            catch
            {

                if (Configuration.ThrowDevExceptions)
                {
                    throw;
                }
            }
        }

        /// <summary>
        /// Deterimines if Session Tracking is enabled. If not,
        /// then the mechanism to prevent the sharing of User IDs
        /// is disabled.
        /// </summary>
        /// <returns></returns>
        virtual protected bool EnableSessionTrackerForPage()
        {
            return Utilities.GetBoolConfigValue("SessionTrackerEnabled", true);
        }

        virtual protected bool SessionTimeoutForPageEnabled()
        {
            return Utilities.GetBoolConfigValue("SessionTimeoutForPageEnabled", false);
        }

        /// <summary>
        /// Indicates if the current user is
        /// a PRCo user.  Used for admin type
        /// functionality.
        /// </summary>
        /// <returns></returns>
        protected bool IsPRCoUser()
        {
            if (_oUser == null)
            {
                return false;
            }

            IBusinessObjectSet osCompanyIDs = GetReferenceData("InternalHQID");
            foreach (ICustom_Caption oCC in osCompanyIDs)
            {
                if (_oUser.prwu_BBID == Convert.ToInt32(oCC.Code))
                {
                    return true;
                }
            }


            if (Session["IsPRCOUser"] != null)
            {
                return true;
            }

            return false;
        }
        protected bool IsPRCoUser(IPRWebUser oUser)
        {
            if (oUser == null)
            {
                return false;
            }

            IBusinessObjectSet osCompanyIDs = GetReferenceData("InternalHQID");
            foreach (ICustom_Caption oCC in osCompanyIDs)
            {
                if (oUser.prwu_BBID == Convert.ToInt32(oCC.Code))
                {
                    return true;
                }
            }


            if (Session["IsPRCOUser"] != null)
            {
                return true;
            }

            return false;
        }

        /// <summary>
        /// Indicates the request page requires a secure (SSL)
        /// connection.  Even if the application requires it,
        /// some pages such as the Error.aspx page, need to override
        /// this so that a) we're not caught in an exceptoin loop and
        /// b) we can notify the user of what the problem is.
        /// </summary>
        /// <returns></returns>
        virtual protected bool PageRequiresSecureConnection()
        {
            return Utilities.GetBoolConfigValue("SSLRequired", true);
        }
        virtual protected string GetURLProtocol()
        {
            if (PageRequiresSecureConnection())
            {
                return "https://";
            }
            return "http://";
        }
    }
}