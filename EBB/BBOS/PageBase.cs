/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2007-2024

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
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Diagnostics;
using System.Globalization;
using System.Text;
using System.IO;
using System.Threading;
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
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Net;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Provides common functionality for all Code-Behind pages
    /// in the application.
    /// </summary>
    public class PageBase : Page
    {
        public const int PRICING_LIST_ONLINE = 16010;

        /// <summary>
        /// Prefix used to mark reference data in the cache
        /// </summary>
        protected const string REF_DATA_PREFIX = "RefData";
        protected const string REF_DATA_NAME = REF_DATA_PREFIX + "_{0}_{1}";

        /// <summary>
        /// A formatted CSS link to ensure the proper syntax is used.
        /// </summary>
        protected const string CSS_LINK = "<link href=\"{0}{1}\" type=\"text/css\" rel=\"stylesheet\" />";

        /// <summary>
        /// The main application CSS file.
        /// </summary>
        public static string CSS_FILE = "bbos.css";

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
        protected const string JS_ENTER_SUBMITS = "<script type=\"text/javascript\">document.onkeydown = function(e) {{ e = e || window.event; if (e.keyCode == 13) {{ __doPostBack('{0}', ''); }} }};</script>";

        protected string _szLocalizationURL;
        public const string DEFAULT_CULTURE = "en-us";
        public const string ENGLISH_CULTURE = "en-us";
        public const string SPANISH_CULTURE = "es-mx";

        protected const string TOGGLE_ALL_LINKS = "[<a href=# onclick=\"ToggleAll(true);\">Expand All</a> | <a href=# onclick=\"ToggleAll(false);\">Collapse All</a>]";

        protected static string LOCK_NFU_REF = "x";

        protected const string TASK_STATUS_PENDING = "Pending";

        protected const string SOURCE_TABLE_PERSON = "Person";
        protected const string SOURCE_TABLE_PRWEBUSERCONTACT = "PRWebUserContact";

        protected bool _isErrorPage = false;

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

            // Even though we initialized the user, we still may not have a valie
            // object if this is not a secured page.
            _oUser = (IPRWebUser)Session["oUser"];
            if (_oUser != null)
            {
                _oLogger.UserID = _oLogger.UserID;
            }

            LogMessage("Page_Load");
            SetCulture(_oUser);

            if (CheckForMaintenanceRedirect())
            {
                return;
            }

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

            // Go find some various controls on the master page
            // so we can set some behaviors.  Not all pages will have these
            // controls as dialog windows don't use the master page.

            // TRAVANT TODO
            //MenuBar oMenuBar = null;
            QuickFind oQuickFind = null;
            if (Master != null)
            {
                //oMenuBar = (MenuBar)Master.FindControl("MenuBar");
                oQuickFind = (QuickFind)this.Master.FindControl("QuickFind");

                HtmlImage oLogoBottom = (HtmlImage)this.Master.FindControl("logobottom");
                if (oLogoBottom != null)
                {
                    oLogoBottom.Src = UIUtils.GetImageURL("logo-int-btm.gif");
                }
            }

            // Even though we initialized the user, we still may not have a valid
            // object if this is not a secured page.
            if (_oUser != null)
            {
                // If the user has not yet accepted the terms, force them
                // to the Terms page.  Some pages are exempt from this, such
                // as the Terms page itself so we don't get caught in a loop.
                if ((!_oUser.prwu_AcceptedTerms) &&
                    (!IsTermsExempt()))
                {
                    Response.Redirect(PageConstants.TERMS);
                    return;
                }

                if (!IsPostBack) {
                    if ((_oUser.prci2_Suspended && !IsTermsExempt()) || _oUser.GetOpenInvoiceMessageCode() == PRWebUser.OPEN_INVOICE_MESSAGE_CODE_SUSPEND)
                        RedirectIfNotDefault();

                    if (DisplayInvoiceMessage())
                    {
                        if (Session["InvoiceMessage_SentDate"] == null || ((DateTime)Session["InvoiceMessage_SentDate"]).AddDays(1).CompareTo(DateTime.Now) < 0)
                            RedirectIfNotDefault();
                    }
                }

                //// Only create the web audit trail upon first load, not everytime
                //// the page is posted back.
                if (!IsPostBack)
                {
                    InsertWebAudit();
                    ValidateSession();
                    ExpireSessionTrackers();

                    _oUser.LogPage(Request.ServerVariables.Get("SCRIPT_NAME"), GetWebAuditTrailAssociatedID());
                    _oUser.CheckPageAccessCount();
                    _oUser.CheckPageAccessForSerialiedData();
                }

                if (Master != null)
                {
                    LinkButton logoff = (LinkButton)this.Master.FindControl("btnLogoff");
                    if (logoff != null)
                        logoff.Visible = true;
                }

                if (oQuickFind != null)
                    oQuickFind.SetWebUser(_oUser);

                if ((Master != null) &&
                    (Master is BBOS))
                {
                    if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                        ((BBOS)Master).SetFooterContactUsURL(Utilities.GetConfigValue("LumberWebSite") + "/contact-us/");
                    else
                        ((BBOS)Master).SetFooterContactUsURL(Utilities.GetConfigValue("ProduceWebSite") + "/contact-us/");
                }

                if (Request.Cookies != null)
                {
                    if ((Request.Cookies["displayZeroResults"] != null) &&
                        (Request.Cookies["displayZeroResults"].Value.Length > 0))
                    {
                        _oUser.prwu_DontDisplayZeroResultsFeedback = UIUtils.GetBool(Request.Cookies["displayZeroResults"].Value);
                        _oUser.Save();
                    }
                }
            }
            else
            {
                if (oQuickFind != null)
                {
                    oQuickFind.Visible = false;
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

        protected void RedirectIfNotDefault()
        {
            //Defect 6877
            string szUrl = Request.Url.ToString().ToLower();
            if (szUrl.EndsWith(PageConstants.BBOS_DEFAULT.ToLower())
                || szUrl.EndsWith(PageConstants.TERMS.ToLower())
                )
            {
                // Do nothing for the above pages to prevent "too many redirects" error
                return;
            }
            else
            {
                Response.Redirect(PageConstants.BBOS_HOME);
                return;
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
            "<div style=\"width:800px;\" class=\"box_left\"><h2>{0}</h2><div class=\"small_horizontal_box_content\">{1}{2}</div></div>";

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

                Panel pnlImpersonation = (Panel)Master.FindControl("pnlImpersonation");

                if (pnlImpersonation != null)
                {
                    if ((IsImpersonating()) &&
                        (_oUser != null))
                    {
                        pnlImpersonation.Visible = true;
                        Literal litImpersonation = ((Literal)Master.FindControl("litImpersonation"));
                        litImpersonation.Text = "Impersonating BB# " + _oUser.prwu_HQID.ToString() + " " + _oUser.FirstName + " " + _oUser.LastName;
                    }
                    else
                    {
                        pnlImpersonation.Visible = false;
                    }
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
                buffer.Append("$(document).ready(function() {" + Environment.NewLine);
                foreach (string szMsg in _oUserMessages)
                {
                    LogMessage("Index: " + szMsg.IndexOf("'").ToString());
                    string szTmp = szMsg.Replace("'", "\\'");
                    //buffer.Append("alert('" + szTmp + "'.replace(/NEWLINE/g, \"\\n\"));" + Environment.NewLine);
                    buffer.Append("bootbox.alert('" + szTmp + "'.replace(/NEWLINE/g, \"\\n\"));" + Environment.NewLine);   //Implemented bootbox messages
                }
                buffer.Append("});" + Environment.NewLine);
                buffer.Append("</script>" + Environment.NewLine);
            }

            // We may have messages from other requests
            if (Session[USER_MSG_ID] != null)
            {
                string _szUserMessage = (string)Session[USER_MSG_ID];
                buffer.Append("<script language=JavaScript>" + Environment.NewLine);
                buffer.Append("$(document).ready(function() {" + Environment.NewLine);
                buffer.Append("bootbox.alert('" + _szUserMessage + "'.replace(/NEWLINE/g, \"\\n\"));" + Environment.NewLine);
                buffer.Append("});" + Environment.NewLine);
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
            PRWebUserMgr userMgr = new PRWebUserMgr();

            try
            {
                return userMgr.GetByEmail(szEmail);
            }
            catch (ApplicationUnexpectedException e)
            {
                if (e.Message.StartsWith(PRWebUserMgr.UNABLE_TO_RETRIEVE_USER))
                {
                    try
                    {
                        bool bProcessedFirst = false;
                        IPRWebUser oCrossIndustryUser = null;
                        IPRWebUser oCrossIndustryUserNonAuthenticate = null;
                        IBusinessObjectSet crossIndustryUsers = (IBusinessObjectSet)userMgr.GetUsersByCrossIndustry(szEmail);
                        foreach (IPRWebUser user in crossIndustryUsers)
                        {
                            if (!bProcessedFirst)
                            {
                                oCrossIndustryUser = user;
                                bProcessedFirst = true;
                            } else {
                                oCrossIndustryUserNonAuthenticate = user;
                            }
                        }

                        if (oCrossIndustryUser != null)
                        {
                            Session["CrossIndustryUser"] = oCrossIndustryUserNonAuthenticate;
                            Session["CrossIndustryCheck"] = "Y";
                            return oCrossIndustryUser; //Use the Cross-Industry user to login with
                        }
                    }
                    catch
                    {
                        throw new ApplicationUnexpectedException("Duplicate web user records found: " + szEmail);
                    }
                }

                throw;
            }
        }

        private IPRWebUser GetTestUser()
        {
            PRWebUser oUser = new PRWebUser();
            oUser.prwu_WebUserID = 1;
            oUser.FirstName = "Test";
            oUser.LastName = "User";
            oUser.Email = "cwalls@travant.com";
            oUser.prwu_Culture = Utilities.GetConfigValue("TestUserCulture", ENGLISH_CULTURE);
            oUser.prwu_IndustryType = Utilities.GetConfigValue("TestUserIndustryType", "P");
            oUser.prwu_AccessLevel = Utilities.GetIntConfigValue("TestUserAccessLevel", PRWebUser.SECURITY_LEVEL_ADMIN);

            return oUser;
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

            if (!IsImpersonating())
            {
                oUser.UpdateLoginStats();
            }

            return true;
        }

        static public string FormatTextForHTML(object szText)
        {
            return FormatTextForHTML(Convert.ToString(szText));
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
            szText = szText.Replace("\r\n", "<br/>");
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
        /// Returns the virtual path to the samples 
        /// directory.
        /// </summary>
        /// <returns></returns>
        static public string GetSamplesPath()
        {
            return GetVirtualPath() + Utilities.GetConfigValue("SamplePath");
        }

        public string GetSamplesPath(string szFileName)
        {
            //string szFolder = null;
            //if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            //{
            //    szFolder = "Lumber/";
            //} else {
            //    szFolder = "Produce/";
            //}

            return GetSamplesPath() + GetIndustryPath(_oUser.prwu_IndustryType) + "/" + szFileName;
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
            _szRequiredFieldMsg = string.Format(Resources.Global.RequiredFieldsMsg, GetRequiredFieldIndicator());
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
        /// Returns the CompanyName configuration value.
        /// </summary>
        /// <returns></returns>
        static public string GetCompanyName()
        {
            return Resources.Global.CompanyNameActual;
        }

        /// <summary>
        /// Returns the ApplicationName configuration value.
        /// </summary>
        /// <returns></returns>
        static public string GetApplicationName()
        {
            return Resources.Global.ApplicationName;
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
        /// Returns the ApplicationNameAbbr configuration value.
        /// </summary>
        /// <returns></returns>
        static public string GetApplicationVersion()
        {
            return Utilities.GetConfigValue("ApplicationVersion");
        }

        /// <summary>
        /// Returns the MaxResultsMsg configuration value.
        /// </summary>
        /// <returns></returns>
        static public string GetMaxResultsMsg()
        {
            return Resources.Global.MaxResultsMsg;
        }

        /// <summary>
        /// Returns the OptLockFailureMsg configuration value.
        /// </summary>
        /// <returns></returns>
        static public string GetOptLockFailureMsg()
        {
            return Utilities.GetConfigValue("OptLockFailureMsg");
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
        /// Returns the UnsupportedBrowserMsg configuration value.
        /// </summary>
        /// <returns></returns>
        static public string GetUnsupportedBrowserMsg()
        {
            return Utilities.GetConfigValue("UnsupportedBrowserMsg");
        }

        /// <summary>
        /// Returns the ObjectExists configuration value.
        /// </summary>
        /// <returns></returns>
        static public string GetObjectExistsMsg()
        {
            return GetObjectExistsMsg(Resources.Global.Name);
        }

        /// <summary>
        /// Returns the ObjectExists configuration value.
        /// </summary>
        /// <param name="szModifier">Modifier to format the string with.</param>
        /// <returns></returns>
        static public string GetObjectExistsMsg(string szModifier)
        {
            return string.Format(Resources.Global.ObjectExistsMsg, szModifier);
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
        /// Returns the message to display if the user cannot view a 
        /// specific object.
        /// </summary>
        /// <returns></returns>
        static public string GetUnauthorizedForActionMsg()
        {
            return Resources.Global.UnauthorizedForActionMsg;
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

        virtual protected string ResetRepeaterCount()
        {
            _iRepeaterCount = 0;
            return string.Empty;
        }

        virtual protected string ResetRepeaterRowCount()
        {
            _iRepeaterRowCount = 1;
            return string.Empty;
        }

        virtual protected string GetBeginColumnSeparator(int count, int columns)
        {
            return GetBeginColumnSeparator(count, columns, _iRepeaterCount);
        }

        virtual protected string GetBeginColumnSeparator(int count, int columns, int index)
        {
            int perColCount = count / columns;
            if (count % 2 != 0)
            {
                perColCount++;
            }

            if (_iRepeaterRowCount == 1)
            {
                return "<td valign='top' width='50%'><table class='table noborder_all'>";
            }
            return string.Empty;
        }

        virtual protected string GetEndColumnSeparator(int count, int columns)
        {
            return GetEndColumnSeparator(count, columns, _iRepeaterCount);
        }

        virtual protected string GetEndColumnSeparator(int count, int columns, int index)
        {
            int perColCount = count / columns;
            if (count % 2 != 0)
            {
                perColCount++;
            }

            if ((index == count) ||
                (_iRepeaterRowCount == perColCount) ||
                (count == 0))
            {
                _iRepeaterRowCount = 0;
                return "</table></div>";

            }
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
        virtual protected string GetBeginSeparator(int iCount, decimal dNumCols, string szWidth)
        {
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
            return GetBeginSeparator(iCount, dNumCols, szWidth, bUseShadeRow, null);
        }

        virtual protected string GetBeginSeparator(int iCount, decimal dNumCols, string szWidth, bool bUseShadeRow, string szClassName)
        {
            string szSeparator = string.Empty;

            if ((iCount == 1) ||
                ((iCount - 1) % dNumCols == 0))
            {
                if (bUseShadeRow)
                {
                    szSeparator = "<tr " + UIUtils.GetShadeClass(_iRepeaterRowCount) + ">";
                }
                else
                {
                    szSeparator = "<tr>";
                }

                _iRepeaterRowCount++;
            }

            if (!string.IsNullOrEmpty(szClassName))
            {
                szClassName = "class=\"" + szClassName + "\"";
            }

            szSeparator = szSeparator + "<td style=\"width:" + szWidth + ";vertical-align:top;\" " + szClassName + ">";
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
        /// Generates a table listing the data by column, then
        /// by row.
        /// </summary>
        /// <param name="oTable">The table control to populate</param>
        /// <param name="oSet">A list containing the cell contents</param>
        /// <param name="iColCount">Number of columns</param>
        virtual protected void GenerateTable(Table oTable,
                                            IList oSet,
                                            int iColCount)
        {
            // Compute how many rows we need.
            int iRowCount = oSet.Count / iColCount;
            int iWholeCount = iRowCount;
            if (iWholeCount == 0)
            {
                iWholeCount = 1;
            }

            // Re-adjust our row count for partial rows.
            if ((oSet.Count % (decimal)iColCount) > 0)
            {
                iRowCount++;
            }

            // Build our table first.
            for (int i = 0; i < iRowCount; i++)
            {
                TableRow oRow = new TableRow();
                oTable.Rows.Add(oRow);

                // For each column
                for (int j = 0; j < iColCount; j++)
                {
                    TableCell oCell = new TableCell();
                    //oCell.Width = Unit.Percentage(100/iColCount);
                    oRow.Cells.Add(oCell);
                }
            }

            int iExtra = oSet.Count - (iWholeCount * iColCount);
            int iRow = 0;
            int iCol = 0;

            bool bExtra = false;

            // Spin through each entry
            foreach (string szValue in oSet)
            {

                // Have we filled our "whole" rows?
                if (iRow >= iWholeCount)
                {

                    // If not in "Extra" mode and we
                    // still have extra items, go
                    // one more row
                    if ((!bExtra) &&
                        (iExtra > 0))
                    {
                        iExtra--;
                        bExtra = true;
                    }
                    else
                    {
                        bExtra = false;
                        iRow = 0;
                        iCol++;
                    }
                }

                oTable.Rows[iRow].Cells[iCol].Text = szValue;
                iRow++;
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
        /// Optimizes the ViewState for the specified
        /// GridView by disabling the view state on
        /// each row.
        /// </summary>
        /// <param name="oGridView"></param>
        protected void OptimizeViewState(GridView oGridView)
        {

            foreach (GridViewRow oRow in oGridView.Rows)
            {
                oRow.EnableViewState = false;
            }
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
                    Response.Redirect(PageConstants.BBOS_HOME);
                    return null;
                }

                if (bThrowBookmarkError)
                    throw new ApplicationExpectedException(Resources.Global.BookmarkError);
                else
                    throw new ApplicationUnexpectedException(string.Format(Resources.Global.ErrorParameterMissing, szName, Request.RawUrl));
            }

            return null;
        }

        protected void RedirectToHomeIfCompanyMissing(string szCompanyID)
        {
            // Redirect to home page if invalid or missing companyid
            int companyID = 0;
            if (!Int32.TryParse(szCompanyID, out companyID))
            {
                Response.Redirect(PageConstants.BBOS_HOME);
            }
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
        /// Returns the configured number of items per page.
        /// </summary>
        /// <returns>Items Per Page</returns>
        protected int GetItemsPerPage()
        {
            return Utilities.GetIntConfigValue("ItemsPerPageCount", 50);
        }

        /// <summary>
        /// Returns the configured maximum number of items to retrieve
        /// from the repository for a listing, such as a search.
        /// </summary>
        /// <returns>Items Per Page</returns>
        protected int GetMaxResultsCount()
        {
            return Utilities.GetIntConfigValue("GetMaxResultsCount", 2000);
        }

        /// <summary>
        /// Adds a "[Any]" option with a value of 0 t the specified
        /// list control.
        /// </summary>
        /// <param name="oList"></param>
        protected void AddSelectAllOption(ListControl oList)
        {
            oList.Items.Insert(0, new ListItem(Resources.Global.SelectAny, "0")); //"[Any]"
        }

        protected const string CHECK_ALL_CHECKBOX = "<input type=\"checkbox\" onclick=\"CheckAll('{0}', this.checked);{1}\" id=\"cbCheckAll\" />";
        /// <summary>
        /// Helper method that formats and returns the string to create
        /// the "CheckAll" checkbox.
        /// </summary>
        /// <param name="szCheckboxesName">The name of the checkboxes to check</param>
        /// <returns></returns>
        public static string GetCheckAllCheckbox(string szCheckboxesName)
        {
            return GetCheckAllCheckbox(szCheckboxesName, string.Empty);
        }

        public static string GetCheckAllCheckbox(string szCheckboxesName, string secondFunctionName)
        {
            return string.Format(CHECK_ALL_CHECKBOX, szCheckboxesName, secondFunctionName);
        }

        /// <summary>
        /// Helper method to prefix the specified string with the specified
        /// characters.  If the string is empty, it will not be prefixed.
        /// </summary>
        /// <param name="szString">String to prefix</param>
        /// <param name="iLength">Desired length</param>
        /// <param name="szChar">Prefix character</param>
        /// <returns></returns>
        protected string PrefixString(string szString, int iLength, string szChar)
        {
            // If our string is empty, return it empty.
            if (szString.Length == 0)
            {
                return szString;
            }

            if (szString.Length < iLength)
            {
                int iDiff = iLength - szString.Length;
                for (int i = 0; i < iDiff; i++)
                {
                    szString = szString.Insert(0, szChar);
                }
            }

            return szString;
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

        /*
                /// <summary>
                /// Adds client-side JS to prevent button double-clicks
                /// </summary>
                /// <param name="btnButton">Button to prevent double-clicking</param>
                /// <param name="szOnClickPrefix">Onclick JS to add to button</param>
                //protected void AddDoubleClickPreventionJS(WebControl btnButton, string szOnClickPrefix)
                //{
                //    string szDblClickPrevention = string.Format(JS_DBL_CLK_PREVENTION5, btnButton.ClientID);
                //    this.ClientScript.RegisterClientScriptBlock(this.GetType(), btnButton.ClientID + "DoubleClickPrevention", szDblClickPrevention);
                //    btnButton.Attributes.Add("onClick", szOnClickPrefix + ";return " + btnButton.ClientID + "click();");
                //}
        */

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
                    if (!_isErrorPage) {
                        LogError(new ArgumentException($"Invalid CompanyID parameter specified: {Request["CompanyID"]}"));
                        return null;
                    } else
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
        /// Parses the specified string value into comma-separated values.
        /// Handles string values enclosed in double-quotes that havea a
        /// comma-within them.
        /// </summary>
        /// <param name="szInputLine"></param>
        /// <returns></returns>
        protected string[] ParseCSVValues(string szInputLine)
        {
            return ParseCSVValues(szInputLine, ',');
        }

        /// <summary>
        /// Parses the specified string value into comma-separated values.
        /// Handles string values enclosed in double-quotes that havea a
        /// delimiter them.
        /// </summary>
        /// <param name="szInputLine"></param>
        /// <param name="cDelimiterChar"></param>
        /// <returns></returns>
        protected string[] ParseCSVValues(string szInputLine, char cDelimiterChar)
        {
            string[] aszInputValues = szInputLine.Split(cDelimiterChar);

            ArrayList alInputValues = new ArrayList();
            string szWork = null;

            foreach (string szValue in aszInputValues)
            {
                if (szWork == null)
                {
                    if ((szValue.StartsWith("\"")) &&
                        (szValue.EndsWith("\"")))
                    {
                        // Our value starts and ends with double-quotes so
                        // remove them.
                        alInputValues.Add(szValue.Substring(1, szValue.Length - 2));

                    }
                    else if (szValue.StartsWith("\""))
                    {
                        // Our value starts with double-quotes, but does not end with
                        // them.  Thus the original value must have had a delimiter embedded in
                        // it.  Save this portion of the value so we can rebuild it.
                        szWork = szValue;
                    }
                    else
                    {
                        alInputValues.Add(szValue);
                    }
                }
                else
                {
                    // We have something in our work area so we rebuilding a value.
                    // If our current value ends in a double quote, we're done rebuilding
                    // and add it to the array.  Otherwise keep rebuilding.
                    szWork += cDelimiterChar + szValue;
                    if (szValue.EndsWith("\""))
                    {
                        alInputValues.Add(szWork.Substring(1, szWork.Length - 2));
                        szWork = null;
                    }
                }
            } // End Foreach


            return (string[])alInputValues.ToArray(string.Empty.GetType());
        }

        /// <summary>
        /// Returns a oWebUserSearchCriteria object either newly created or an existing one from
        /// the session if a matching one is found.
        /// </summary>
        /// <param name="iSearchCritieraID"></param>
        /// <param name="szSearchType"></param>
        /// <returns></returns>
        protected IPRWebUserSearchCriteria GetSearchCritieria(int iSearchCritieraID, string szSearchType)
        {
            return GetSearchCritieria(iSearchCritieraID, szSearchType, false);
        }

        /// <summary>
        /// Returns a oWebUserSearchCriteria object either newly created or an existing one from
        /// the session if a matching one is found.
        /// </summary>
        /// <param name="iSearchCritieraID"></param>
        /// <param name="szSearchType"></param>
        /// <param name="bReturnNullIfNotFound"></param>
        /// <returns></returns>
        protected IPRWebUserSearchCriteria GetSearchCritieria(int iSearchCritieraID, string szSearchType, bool bReturnNullIfNotFound)
        {
            IPRWebUserSearchCriteria oWebUserSearchCriteria = (IPRWebUserSearchCriteria)Session["oWebUserSearchCriteria"];
            PRWebUserSearchCriteriaMgr oWebUserSearchCriteriaMgr = new PRWebUserSearchCriteriaMgr(_oLogger, _oUser);

            // If and ID is specified, then go get that 
            // PRWebUserSearchCriteria instance
            if (iSearchCritieraID > 0)
            {

                // If we either don't have a PRWebUserSearchCriteria object in the session
                // of if we do, but it doesn't have the specified ID, go retrieve the object
                // with the specified ID.
                if ((oWebUserSearchCriteria == null) ||
                    (oWebUserSearchCriteria.prsc_SearchCriteriaID != iSearchCritieraID))
                {
                    oWebUserSearchCriteria = (IPRWebUserSearchCriteria)oWebUserSearchCriteriaMgr.GetObjectByKey(iSearchCritieraID);
                }

            }
            else
            {
                // Did we find a PRWebUserSearchCriteria object in the session?
                if (oWebUserSearchCriteria != null)
                {

                    // If the PRWebUserSearchCriteria found in the session doesn't match our
                    // type or if it has an ID (at this point we don't), then reset
                    // our object pointer so a new instance gets created
                    if (oWebUserSearchCriteria.prsc_SearchType != szSearchType)
                    {
                        oWebUserSearchCriteria = null;
                    }
                    else
                    {
                        if ((oWebUserSearchCriteria.prsc_SearchCriteriaID != 0) &&
                            (!oWebUserSearchCriteria.prsc_IsLastUnsavedSearch))
                        {
                            oWebUserSearchCriteria = null;
                        }
                    }
                }
            }

            if ((oWebUserSearchCriteria == null) &&
                (bReturnNullIfNotFound))
            {
                return null;
            }

            if (oWebUserSearchCriteria == null)
            {
                oWebUserSearchCriteria = (IPRWebUserSearchCriteria)oWebUserSearchCriteriaMgr.CreateObject();
                oWebUserSearchCriteria.prsc_SearchType = szSearchType;

                // Initialize this property to a "Magic Number" indicating no
                // criteria.
                if (szSearchType == PRWebUserSearchCriteria.SEARCH_TYPE_COMPANY)
                {
                    ((CompanySearchCriteria)oWebUserSearchCriteria.Criteria).PayReportCount = -1;

                    if (_oUser.HasLocalSourceDataAccess())
                    {
                        ((CompanySearchCriteria)oWebUserSearchCriteria.Criteria).IncludeLocalSource = _oUser.prwu_LocalSourceSearch;
                    }
                }
            }

            oWebUserSearchCriteria.WebUser = _oUser;

            Session["oWebUserSearchCriteria"] = oWebUserSearchCriteria;
            return oWebUserSearchCriteria;
        }

        /// <summary>
        /// Clears the specified search oWebUserSearchCriteria from the session if
        /// it exists there.
        /// </summary>
        /// <param name="iSearchCritieraID"></param>
        /// <param name="szSearchType"></param>
        protected void ClearSearchCriteria(int iSearchCritieraID, string szSearchType)
        {
            IPRWebUserSearchCriteria oWebUserSearchCriteria = (IPRWebUserSearchCriteria)Session["oWebUserSearchCriteria"];
            if (oWebUserSearchCriteria == null)
            {
                return;
            }

            if (iSearchCritieraID > 0)
            {
                if (oWebUserSearchCriteria.prsc_SearchCriteriaID == iSearchCritieraID)
                {
                    ClearSearchCritiera();
                }
            }
            else
            {
                if ((oWebUserSearchCriteria.prsc_SearchCriteriaID == 0) &&
                    (oWebUserSearchCriteria.prsc_SearchType == szSearchType))
                {
                    ClearSearchCritiera();
                }
            }
        }

        protected void ClearSearchCritiera()
        {
            Session["oWebUserSearchCriteria"] = null;
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

        protected void SetReturnURL(string szURL)
        {
            Session["ReturnURL"] = szURL;
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
        /// Returns the level 1 classifications as custom_captions.
        /// </summary>
        /// <returns></returns>
        protected List<ICustom_Caption> GetLevel1Classifications(string szIndustryType)
        {
            string szSQL = null;

            if (szIndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                szSQL = "SELECT prcl_ClassificationID, " + GetObjectMgr().GetLocalizedColName("prcl_Name") + " AS prcl_Name FROM PRClassification WHERE prcl_level=1 AND prcl_BookSection = 3";
            }
            else
            {
                szSQL = "SELECT prcl_ClassificationID, " + GetObjectMgr().GetLocalizedColName("prcl_Name") + " AS prcl_Name FROM PRClassification WHERE prcl_level=1 AND prcl_BookSection <> 3";
            }
            List<ICustom_Caption> lLookupValues = new List<ICustom_Caption>();

            IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection);
            try
            {

                while (oReader.Read())
                {
                    ICustom_Caption oCustom_Caption = new Custom_Caption();
                    oCustom_Caption.Code = oReader.GetInt32(0).ToString();
                    oCustom_Caption.Meaning = GetDBAccess().GetString(oReader, 1);
                    lLookupValues.Add(oCustom_Caption);
                }

                return lLookupValues;
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
        /// If SSL is enabled (SSLEnabled config value) then a fully
        /// qualified HTTPS URL is returned.  Otherwise the specified
        /// Page url is returned.
        /// </summary>
        /// <param name="szPage"></param>
        /// <returns></returns>
        protected string GetFullSSLURL(string szPage)
        {
            if ((Utilities.GetBoolConfigValue("SSLEnabled", true) ||
                (Utilities.GetBoolConfigValue("SSLRequired", true))))
            {
                return "https://" + Request.ServerVariables["SERVER_NAME"] + GetVirtualPath() + szPage;
            }

            return szPage;
        }



        protected void SetRatingLink(IPRWebUser oUser)
        {
            if (Master == null)
                return;

            HyperLink linkRating = ((HyperLink)this.Master.FindControl("lnkRatingKey"));
            if (linkRating == null)
            {
                return;
            }

            linkRating.Visible = true;

            int publicationArticleID;

            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                publicationArticleID = Convert.ToInt32(Utilities.GetConfigValue("LumberRatingArticle", "7732"));
            else
                publicationArticleID = Convert.ToInt32(Utilities.GetConfigValue("NonLumberRatingArticle", "6214"));

            linkRating.NavigateUrl = "GetPublicationFile.aspx?PublicationArticleID=" + publicationArticleID;
            linkRating.Attributes.Add("target", "_blank");
        }

        public static string GetIndustryPath(string szIndustryCode)
        {
            if (szIndustryCode == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                return "Lumber";
            }
            else
            {
                return "Produce";
            }
        }

        public const string SQL_COMPANY_CELL_SELECT =
            @"SELECT comp_PRBookTradeStyle, comp_PRLegalName, CityStateCountryShort, comp_PRLastPublishedCSDate, comp_PRListingStatus,
                         dbo.ufn_HasNewClaimActivity(comp_PRHQID, {1}) as HasNewClaimActivity, 
                         dbo.ufn_HasMeritoriousClaim(comp_PRHQID, {2}) as HasMeritoriousClaim,
                         dbo.ufn_HasCertification(comp_PRHQID) as HasCertification,
                         dbo.ufn_HasCertification_Organic(comp_PRHQID) as HasCertification_Organic,
                         dbo.ufn_HasCertification_FoodSafety(comp_PRHQID) as HasCertification_FoodSafety
                FROM Company WITH (NOLOCK) 
                     INNER JOIN vPRLocation on comp_PRListingCityID = prci_CityID  
               WHERE comp_CompanyID={0}";

        /// <summary>
        /// Helper method used to populate the company name cell
        /// </summary>
        protected string GetCompanyDataForCell(int iCompanyID, bool bIncludeCompanyIcons = true, bool bIncludeCompanyNameLink = true)
        {
            string szCompanyName = null;
            string szLegalName = null;
            string szLocation = null;
            string szListingStatus = null;
            DateTime dtLastCDSate = new DateTime();
            bool bHasNewClaim = false;
            bool bHasMeritoriouisClaim = false;
            bool bHasCertification = false;
            bool bHasCertification_Organic = false;
            bool bHasCertification_FoodSafety = false;

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("comp_CompanyID", iCompanyID));

            //Handle spanish globalization of date fields
            CultureInfo m_UsCulture = new CultureInfo("en-us");
            string szDate1 = DateTime.Today.AddDays(0 - Configuration.ClaimActivityNewThresholdIndicatorDays).ToString(m_UsCulture);
            string szDate2 = DateTime.Today.AddDays(0 - Utilities.GetIntConfigValue("ClaimActivityMeritoriousThresholdIndicatorDays", 60)).ToString(m_UsCulture);

            oParameters.Add(new ObjectParameter("NewClaimThresholdDate", szDate1));
            oParameters.Add(new ObjectParameter("MeritoriousClaimThesholdDate", szDate2));

            string szSQL = GetObjectMgr().FormatSQL(SQL_COMPANY_CELL_SELECT, oParameters);

            // Use our own DBAccess object to 
            // avoid conflicts with open readers.
            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            oDBAccess.Logger = _oLogger;

            IDataReader oReader = oDBAccess.ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            try
            {
                if (oReader.Read())
                {
                    szCompanyName = GetDBAccess().GetString(oReader, 0);
                    szLegalName = GetDBAccess().GetString(oReader, 1);
                    szLocation = GetDBAccess().GetString(oReader, 2);
                    dtLastCDSate = GetDBAccess().GetDateTime(oReader, "comp_PRLastPublishedCSDate");
                    szListingStatus = GetDBAccess().GetString(oReader, "comp_PRListingStatus");
                    bHasNewClaim = GetObjectMgr().TranslateFromCRMBool(oReader["HasNewClaimActivity"]);
                    bHasMeritoriouisClaim = GetObjectMgr().TranslateFromCRMBool(oReader["HasMeritoriousClaim"]);
                    bHasCertification = GetObjectMgr().TranslateFromCRMBool(oReader["HasCertification"]);
                    bHasCertification_Organic = GetObjectMgr().TranslateFromCRMBool(oReader["HasCertification_Organic"]);
                    bHasCertification_FoodSafety = GetObjectMgr().TranslateFromCRMBool(oReader["HasCertification_FoodSafety"]);
                }
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }

            return GetCompanyDataForCell(iCompanyID,
                                        szCompanyName,
                                        szLegalName,
                                        false,
                                        dtLastCDSate,
                                        szListingStatus,
                                        true,
                                        bHasNewClaim,
                                        bHasMeritoriouisClaim,
                                        bHasCertification,
                                        bHasCertification_Organic,
                                        bHasCertification_FoodSafety,
                                        bIncludeCompanyIcons,
                                        bIncludeCompanyNameLink);
        }

        public const string COMPANY_LISTING_ICON = "<img src=\"{0}\" title=\"{1}\"  alt=\"{1}\" border=\"0\" class=\"Icon\" align=\"middle\" {2} {3} {4} />";
        public const string NOTE_ICON = "<a href=\"{0}\"><img src=\"{1}\" title=\"{2}\" alt=\"{2}\" border=\"0\" class=\"Icon\" align=\"middle\" /></a>";
        public const string MATERIAL_NOTE_ICON = "<a href=\"{0}\"><span class=\"msicon notranslate\" title=\"{1}\">demography</span></a>";
        public const string COMPANY_CHANGED_ICON = "<a href=\"{0}\"><img src=\"{1}\" title=\"{2}\" alt=\"{2}\" border=\"0\" align=\"middle\" /></a>";
        public const string DATA_FOR_CELL = "<a href=\"{0}\" class='explicitlink'>{1}</a>{2}";
        public const string DATA_FOR_CELL_NEW_TAB = "<a href=\"{0}\" class='explicitlink' target='_blank'>{1}</a>{2}";
        public const string CERTIFICATION_ICON = "<a href=\"{0}\"><img src=\"{1}\" title=\"{2}\" alt=\"{2}\" border=\"0\" class=\"Icon\" align=\"middle\" /></a>";
        public const string IS_ON_WATCHDOG_ICON = "<img src=\"{0}\" title=\"{1}\"  alt=\"{1}\" border=\"0\" class=\"Icon\" align=\"middle\" />";

        /// <summary>
        /// Helper method that builds the basic contents of a company name cell
        /// including the listing and note icons for all companies including non-Listed companies.
        /// </summary>
        protected string GetCompanyDataForCell(int iCompanyID,
            string szCompanyName,
            string szCompanyLegalName,
            bool bIncludeNotesIcon,
            DateTime dtLastChanged,
            string szListingStatus,
            bool bIncludeListingIcon,
            bool bIncludeNewClaimIcon,
            bool bIncludeMeritoriousClaimIcon,
            bool bIncludeCertificationIcon,
            bool bHasCertification_Organic,
            bool bHasCertification_FoodSafety,
            bool bIncludeCompanyIcons,
            bool bIncludeCompanyNameLink = true,
            bool bCompanyLinksNewTab = false,
            bool bIsOnWatchdog = false,
            string szWatchdogList = null
            )
        {
            // if the company is not listed, don't include the icon.
            if ((szListingStatus != "L") && (szListingStatus != "H") && (szListingStatus != "LUV"))
            {
                bIncludeListingIcon = false;
            }

            if (!_oUser.HasPrivilege(SecurityMgr.Privilege.ViewCompanyListing).HasPrivilege)
            {
                bIncludeListingIcon = false;
            }

            // otherwise, return the standard company data for cell
            return GetCompanyDataForCell(iCompanyID,
                                        szCompanyName,
                                        szCompanyLegalName,
                                        bIncludeNotesIcon,
                                        dtLastChanged,
                                        bIncludeListingIcon,
                                        bIncludeNewClaimIcon,
                                        bIncludeMeritoriousClaimIcon,
                                        bIncludeCertificationIcon,
                                        bHasCertification_Organic,
                                        bHasCertification_FoodSafety,
                                        bIncludeCompanyIcons,
                                        bIncludeCompanyNameLink,
                                        bCompanyLinksNewTab,
                                        bIsOnWatchdog,
                                        szWatchdogList);
        }

        protected string GetCompanyNameForCell(int iCompanyID, string szCompanyName, string szCompanyLegalName)
        {
            if(!string.IsNullOrEmpty(szCompanyLegalName))
                szCompanyLegalName = ParenWrap(szCompanyLegalName);

            string szCompanyNameForCell = null;

            string szPage = PageConstants.COMPANY;

            // Removed by Pjohnson 2/8/2024 to solve issue 56 where company name does not display in Recent Views page
            //if (_oUser.IsLimitado)
            szCompanyNameForCell = string.Format(DATA_FOR_CELL,
                                        PageConstants.Format(szPage, iCompanyID),
                                        Server.HtmlEncode(szCompanyName),
                                        szCompanyLegalName);
            return szCompanyNameForCell;
        }

        //Return a string enclosed in parenthesis, or blank if original string is null or empty
        public static string ParenWrap(object oVal, bool blnIncludeBR = false)
        {
            string strVal = String.Empty;

            if (oVal != null)
            {
                strVal = ((string)oVal).Trim();
                if (strVal.Length == 0)
                    strVal = String.Empty;
                else
                {
                    strVal = string.Format("({0})", strVal.Trim());
                    if (blnIncludeBR)
                        strVal += "<br/>";
                }
            }

            return strVal;
        }

        protected string GetCompanyDataForCellForUnlistedCompanies(int iCompanyID,
                        string szCompanyName,
                        string szCompanyLegalName,
                        bool bIncludeNotesIcon,
                        DateTime dtLastChanged,
                        string szListingStatus,
                        bool bIncludeNewClaimIcon,
                        bool bIncludeMeritoriousClaimIcon,
                        bool bIncludeCertificationIcon,
                        bool bHasCertification_Organic,
                        bool bHasCertification_FoodSafety,
                        bool bIncludeCompanyIcons,
                        bool bIncludeCompanyNameLink = true)
        {
            // if the name is not present, return empty 
            if (szCompanyName == null || szCompanyName.Length == 0)
                return "&nbsp;";

            // if the company is not listed, just return the company name
            if (string.IsNullOrEmpty(szListingStatus) || "L,H,N3,N5,N6".IndexOf(szListingStatus) == -1)
            {
                if (bIncludeCompanyNameLink)
                    return szCompanyName;
                else
                    return String.Empty;
            }

            bool bIncludeListingIcon = true;
            // if the company is not listed, don't include the icon.
            if ((szListingStatus == "N3") ||
                (szListingStatus == "N5") ||
                (szListingStatus == "N6"))
            {
                bIncludeListingIcon = false;
            }

            // otherwise, return the standard company data for cell
            return GetCompanyDataForCell(iCompanyID,
                szCompanyName,
                szCompanyLegalName,
                bIncludeNotesIcon,
                dtLastChanged,
                bIncludeListingIcon,
                bIncludeNewClaimIcon,
                bIncludeMeritoriousClaimIcon,
                bIncludeCertificationIcon,
                bHasCertification_Organic,
                bHasCertification_FoodSafety,
                bIncludeCompanyIcons,
                bIncludeCompanyNameLink);
        }


        /// <summary>
        /// Helper method that builds the basic contents of a company name cell
        /// including the listing and note icons.
        /// </summary>
        /// <param name="iCompanyID"></param>
        /// <param name="szCompanyName"></param>
        /// <param name="szCompanyLegalName"></param>
        /// <param name="bIncludeNotesIcon"></param>
        /// <param name="dtLastChanged"></param>
        /// <param name="bIncludeListingIcon"></param>
        /// <param name="bIncludeNewClaimIcon"></param>
        /// <param name="bIncludeMeritoriousClaimIcon"></param>
        /// <returns></returns>
        protected string GetCompanyDataForCell(int iCompanyID,
                                string szCompanyName,
                                string szCompanyLegalName,
                                bool bIncludeNotesIcon,
                                DateTime dtLastChanged,
                                bool bIncludeListingIcon,
                                bool bIncludeNewClaimIcon,
                                bool bIncludeMeritoriousClaimIcon,
                                bool bIncludeCertificationIcon,
                                bool bHasCertification_Organic,
                                bool bHasCertification_FoodSafety,
                                bool bIncludeCompanyIcons,
                                bool bIncludeCompanyNameLink = true,
                                bool bCompanyLinksNewTab = false,
                                bool bIsOnWatchdog = false,
                                string szWatchdogList=null)
        {
            StringBuilder sbCompanyCell = new StringBuilder();

            if (bIncludeListingIcon && Configuration.ListingPopupVisible)
            {
                string szNewWindowClick = string.Empty;
                string szPopupOpen = string.Empty;
                string szPopupClose = string.Empty;

                if (Utilities.GetBoolConfigValue("ListingNewWindowEnabled", true))
                    szNewWindowClick = "onclick=\"openListing('" + PageConstants.Format(PageConstants.COMPANY_LISTING, iCompanyID) + "');\"";

                EnableListingPopup();
                if (Utilities.GetBoolConfigValue("ListingPopupEnabled", true))
                    szPopupOpen = "onmouseover=\"showListing(this, '" + iCompanyID.ToString() + "');\"";

                if (Utilities.GetBoolConfigValue("ListingPopupAutoCloseEnabled", false))
                    szPopupClose = "onmouseout=\"hideListing();\"";

                sbCompanyCell.Append(string.Format(COMPANY_LISTING_ICON,
                                                   UIUtils.GetImageURL("icon-listing.gif"),
                                                   Resources.Global.CompanyListingTitle,
                                                   szNewWindowClick,
                                                   szPopupOpen,
                                                   szPopupClose));
            }

            if (bIncludeNotesIcon)
            {
                string strUrl = "";
                if (_oUser.HasPrivilege(SecurityMgr.Privilege.CompanyDetailsCustomPage).Enabled)
                {
                    strUrl = PageConstants.Format(PageConstants.COMPANY_NOTES_BBOS9, iCompanyID);
                }
                else
                    strUrl = JAVASCRIPT_VOID;

                sbCompanyCell.Append(string.Format(NOTE_ICON,
                                                   strUrl,
                                                   UIUtils.GetImageURL("icon-note.gif"),
                                                   Resources.Global.ViewNote));
            }


            if (bIncludeCompanyIcons && bIncludeNewClaimIcon)
            {
                string strUrl = "";
                if (_oUser.HasPrivilege(SecurityMgr.Privilege.CompanyDetailsClaimActivityPage).Enabled)
                {
                    strUrl = PageConstants.Format(PageConstants.COMPANY_CLAIMS_ACTIVITY_BBOS9, iCompanyID);
                }
                else
                    strUrl = JAVASCRIPT_VOID;

                sbCompanyCell.Append(string.Format(NOTE_ICON,
                                                   strUrl,
                                                   UIUtils.GetImageURL("ClaimActivity-New.png"),
                                                   Resources.Global.NewClaimOpened));
            }

            if (bIncludeCompanyIcons && bIncludeMeritoriousClaimIcon)
            {
                string strUrl = "";
                if (_oUser.HasPrivilege(SecurityMgr.Privilege.CompanyDetailsClaimActivityPage).Enabled)
                {
                    strUrl = PageConstants.Format(PageConstants.COMPANY_CLAIMS_ACTIVITY_BBOS9, iCompanyID);
                }
                else
                    strUrl = JAVASCRIPT_VOID;

                sbCompanyCell.Append(string.Format(NOTE_ICON,
                                                   strUrl,
                                                   UIUtils.GetImageURL("ClaimActivity-Meritorious.png"),
                                                   Resources.Global.ClaimRecentlyFlaggedMeritorious));
            }

            if (bIncludeCompanyIcons && bIncludeCertificationIcon)
            {
                string szAltTag = "";

                if (bHasCertification_Organic && bHasCertification_FoodSafety)
                    szAltTag = Resources.Global.CertifiedOrganicAndFoodSafety;
                else if (bHasCertification_Organic)
                    szAltTag = Resources.Global.CertifiedOrganic;
                else if (bHasCertification_FoodSafety)
                    szAltTag = Resources.Global.CertifiedFoodSafety;

                string strUrl = "";
                if (_oUser.HasPrivilege(SecurityMgr.Privilege.CompanyDetailsClassificationsCommoditesPage).Enabled ||
                   _oUser.HasPrivilege(SecurityMgr.Privilege.CompanyDetailsClassificationsCommoditesProductSerivcesSpeciesPage).Enabled)
                {
                    strUrl = PageConstants.Format(PageConstants.COMPANY, iCompanyID);
                }
                else
                    strUrl = JAVASCRIPT_VOID;

                sbCompanyCell.Append(string.Format(CERTIFICATION_ICON,
                                                   strUrl,
                                                   UIUtils.GetImageURL("icon-certified16.png"),
                                                   szAltTag));
            }

            if (bIncludeCompanyIcons && dtLastChanged > DateTime.MinValue)
            {
                TimeSpan oTS = DateTime.Now.Subtract(dtLastChanged);
                int iDays = oTS.Days + 1;
                if (iDays < Configuration.CompanyLastChangeThreshold)
                {
                    string strUrl = "";
                    if (_oUser.HasPrivilege(SecurityMgr.Privilege.CompanyDetailsUpdatesPage).HasPrivilege)
                    {
                        strUrl = PageConstants.Format(PageConstants.COMPANY_UPDATES_BBOS9, iCompanyID) + "&do=" + Configuration.CompanyLastChangeThreshold.ToString();
                    }
                    else
                        strUrl = JAVASCRIPT_VOID;

                    sbCompanyCell.Append(string.Format(COMPANY_CHANGED_ICON,
                                                       strUrl,
                                                       UIUtils.GetImageURL("icon-changed.gif"),
                                                       string.Format(Resources.Global.CompanyChangedMsg, iDays)));
                }
            }

            if (bIsOnWatchdog)
            {
                string szTitle = string.Empty;
                if (!string.IsNullOrEmpty(szWatchdogList))
                    szTitle = szWatchdogList;
                sbCompanyCell.Append(string.Format(IS_ON_WATCHDOG_ICON,
                                                   UIUtils.GetImageURL("icon_on_watchdog.png"),
                                                   szTitle));
            }

            if (!string.IsNullOrEmpty(szCompanyLegalName))
                szCompanyLegalName = "(" + Server.HtmlEncode(szCompanyLegalName) + ")";

            if (bIncludeCompanyNameLink)
            {
                string strUrl = "";

                if (_oUser.HasPrivilege(SecurityMgr.Privilege.CompanyDetailsListingPage).Enabled)
                    strUrl = PageConstants.Format(PageConstants.COMPANY, iCompanyID);
                else
                    strUrl = JAVASCRIPT_VOID;

                string szCompanyNameForCell = null;

                if (bCompanyLinksNewTab)
                {
                    szCompanyNameForCell = string.Format(DATA_FOR_CELL_NEW_TAB,
                                strUrl,
                                Server.HtmlEncode(szCompanyName),
                                szCompanyLegalName);
                }
                else
                {
                    szCompanyNameForCell = string.Format(DATA_FOR_CELL,
                                                    strUrl,
                                                    Server.HtmlEncode(szCompanyName),
                                                    szCompanyLegalName);
                }
                sbCompanyCell.Append(szCompanyNameForCell);
            }

            return sbCompanyCell.ToString();
        }

        protected bool bpnlListingContainerVisible = false;
        protected void EnableListingPopup()
        {
            // Since this will be called in a list, let's only invoke
            // FindControl once.
            if (!bpnlListingContainerVisible)
            {
                bpnlListingContainerVisible = true;
                string szListingButtonsEnabled = "false";
                if (Master != null)
                {
                    Master.FindControl("pnlListingContainer").Visible = true;
                    if (_oUser.HasPrivilege(SecurityMgr.Privilege.CompanyDetailsListingPage).HasPrivilege)
                    {
                        szListingButtonsEnabled = "true";
                    }

                    ClientScript.RegisterStartupScript(this.GetType(), "ListingPopupSecurity", "var bListingButtonsEnabled=" + szListingButtonsEnabled + "; ", true);
                }
            }
        }

        /// <summary>
        /// Helper method that builds the basic contents of a person name cell
        /// including the note icon.
        /// </summary>
        protected string GetPersonDataForCell(int iPersonID, string szPersonName, bool bIncludeNotesIcon, bool bIncludePersonNameLink = true)
        {
            StringBuilder sbPersonCell = new StringBuilder();

            if (bIncludeNotesIcon)
            {
                string strUrl = "";
                if (_oUser.HasPrivilege(SecurityMgr.Privilege.PersonDetailsPage).HasPrivilege)
                    strUrl = PageConstants.Format(PageConstants.PERSON_DETAILS, iPersonID);
                else
                    strUrl = JAVASCRIPT_VOID;

                sbPersonCell.Append(string.Format(MATERIAL_NOTE_ICON,
                                                   strUrl,
                                                   Resources.Global.ViewPersonNotes));
            }

            if (bIncludePersonNameLink)
            {
                string szPersonNameForCell = null;

                if (_oUser.HasPrivilege(SecurityMgr.Privilege.PersonDetailsPage).HasPrivilege)
                {
                    string strUrl = PageConstants.Format(PageConstants.PERSON_DETAILS, iPersonID);

                    szPersonNameForCell = string.Format(DATA_FOR_CELL,
                                                   strUrl,
                                                   szPersonName,
                                                   string.Empty);
                }
                else
                {
                    szPersonNameForCell = szPersonName;
                }

                sbPersonCell.Append(szPersonNameForCell);
            }

            return sbPersonCell.ToString();
        }

        /// <summary>
        /// Helper method that builds the basic contents of a person name cell
        /// including the note icon.
        /// </summary>
        /// <param name="iPersonID"></param>
        /// <param name="szPersonName"></param>
        /// <returns></returns>
        protected string GetPersonNameForCell(int iPersonID, string szPersonName)
        {
            StringBuilder sbPersonCell = new StringBuilder();

            string szPersonNameForCell = null;

            if (_oUser.HasPrivilege(SecurityMgr.Privilege.PersonDetailsPage).HasPrivilege)
            {
                szPersonNameForCell = string.Format(DATA_FOR_CELL,
                                               PageConstants.Format(PageConstants.PERSON_DETAILS, iPersonID),
                                               szPersonName,
                                               string.Empty);
            }
            else
            {
                szPersonNameForCell = szPersonName;
            }

            sbPersonCell.Append(szPersonNameForCell);

            return sbPersonCell.ToString();
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
        /// If true, the GoogleAdServices JS code is available
        /// to be included with the page.
        /// </summary>
        /// <returns></returns>
        public virtual bool EnableGoogleAdServices()
        {
            return false;
        }

        /// <summary>
        /// Saves the specified note.  If the iNoteID is zero (0),
        /// then a new Note record is created.          
        /// </summary>
        /// <param name="iAssociatedID"></param>
        /// <param name="szAssociatedType"></param>
        /// <param name="iNoteID"></param>
        /// <param name="szNote"></param>
        /// <param name="IsPrivate"></param>
        virtual protected void SaveNote(int iAssociatedID, string szAssociatedType, int iNoteID, string szNote, bool IsPrivate)
        {

            if (string.IsNullOrEmpty(szNote))
            {
                if (iNoteID > 0)
                {
                    GetObjectMgr().DeleteNote(iNoteID, null);
                }
            }
            else
            {
                if (iNoteID == 0)
                {
                    GetObjectMgr().InsertNote(iAssociatedID,
                                              szAssociatedType,
                                              szNote,
                                              IsPrivate,
                                              null);
                }
                else
                {
                    GetObjectMgr().UpdateNote(iNoteID, szNote, null);
                }
            }
        }

        /// <summary>
        /// Logs the user off of the system.  This must be public
        /// for user controls to access it.
        /// </summary>
        virtual public void LogoffUser()
        {
            RemoveSessionTracker(_oUser.prwu_WebUserID);
            FormsAuthentication.SignOut();
            Session.Abandon();
            Response.Redirect(Configuration.WebSiteHome);
        }


        protected const string SQL_SELECT_USER_LIST_COMPANIES =
            @"SELECT comp_PRBookTradestyle 
                FROM Company WITH (NOLOCK) 
                     INNER JOIN PRWebUserListDetail WITH (NOLOCK) ON comp_CompanyID = prwuld_AssociatedID and prwuld_AssociatedType='C' 
               WHERE prwuld_WebUserListID={0} 
            ORDER BY comp_PRBookTradestyle";

        protected const string SQL_SELECT_USER_LIST_COMPANIES_COUNT =
            @"SELECT COUNT(1) 
                FROM PRWebUserListDetail WITH (NOLOCK)
               WHERE prwuld_WebUserListID={0}";

        /// <summary>
        /// Helper method used by the GridView used to populate the
        /// contents of the user list.
        /// </summary>
        /// <param name="iListID"></param>
        /// <param name="iMaxColCount"></param>
        /// <returns></returns>
        virtual protected string GetUserListCompanies(int iListID, int iMaxColCount)
        {
            // We want our own connection to avoid conflicts with
            // an open DataReader
            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            oDBAccess.Logger = _oLogger;

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prwuld_WebUserListID", iListID));

            int perColCount = Int32.MaxValue;
            string colWidth = string.Empty;
            if (iMaxColCount > 1)
            {
                string szCountSQL = GetObjectMgr().FormatSQL(SQL_SELECT_USER_LIST_COMPANIES_COUNT, oParameters);
                int listCount = Convert.ToInt32(oDBAccess.ExecuteScalar(szCountSQL, oParameters));

                perColCount = listCount / iMaxColCount;
                if ((listCount % iMaxColCount) != 0)
                {
                    perColCount++;
                }
            }

            StringBuilder sbList = new StringBuilder("<table style='width:100%; border-style:none' cellpadding='0' cellspacing='0'><tr><td style='vertical-align:top;'><ul class='Watchdog'>");
            int count = 0;

            string szSQL = GetObjectMgr().FormatSQL(SQL_SELECT_USER_LIST_COMPANIES, oParameters);
            IDataReader oReader = oDBAccess.ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            try
            {
                while (oReader.Read())
                {
                    sbList.Append("<li>");
                    sbList.Append(oReader.GetString(0));
                    sbList.Append("</li>");

                    count++;
                    if (count >= perColCount)
                    {
                        sbList.Append("</ul></td><td style='vertical-align:top;'><ul class='Watchdog'>");
                        count = 0;
                    }
                }
                sbList.Append("</ul></td></tr></table>");
                return sbList.ToString();
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }
        }

        protected const string SQL_SELECT_USER_LIST =
            @"SELECT prwucl_WebUserListID, prwucl_Name, prwucl_IsPrivate, MAX(prwucl_UpdatedDate) AS UpdatedDate, prwucl_CategoryIcon, COUNT(1) As CompanyCount 
                FROM PRWebUserList WITH (NOLOCK)
                     INNER JOIN PRWebUserListDetail WITH (NOLOCK) ON prwucl_WebUserListID = prwuld_WebUserListID 
                     INNER JOIN Company WITH (NOLOCK) ON prwuld_AssociatedID = comp_CompanyID
               WHERE ((prwucl_HQID = {0} AND prwucl_IsPrivate IS NULL) OR (prwucl_WebUserID={1} AND prwucl_IsPrivate = 'Y')) 
                 AND comp_PRListingStatus IN ('L', 'H', 'N3', 'N5', 'N6', 'LUV')
            GROUP BY prwucl_WebUserListID, prwucl_Name, prwucl_IsPrivate, prwucl_CategoryIcon";

        /// <summary>
        /// Populates the UserList section of the page.
        /// </summary>
        protected void PopulateUserLists(GridView gvUserList)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prwucl_HQID", _oUser.prwu_HQID));           //oParameters.Add(new ObjectParameter("prwucl_HQID", 100002));
            oParameters.Add(new ObjectParameter("prwucl_WebUserID", _oUser.prwu_WebUserID)); //oParameters.Add(new ObjectParameter("prwucl_WebUserID", 10013)); 

            string[] aszKeyName = { "prwucl_WebUserListID" };

            string szSQL = GetObjectMgr().FormatSQL(SQL_SELECT_USER_LIST, oParameters);
            szSQL += GetOrderByClause(gvUserList);

            //((EmptyGridView)gvUserList).EmptyTableRowText = GetNoResultsFoundMsg(Resources.Global.WatchdogLists);
            gvUserList.ShowHeaderWhenEmpty = true;
            gvUserList.EmptyDataText = GetNoResultsFoundMsg(Resources.Global.WatchdogLists);

            gvUserList.DataKeyNames = aszKeyName;
            gvUserList.DataSource = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            gvUserList.DataBind();
            EnableBootstrapFormatting(gvUserList);

            //EnableRowHighlight(gvUserList); 
        }

        /// <summary>
        /// Returns the Referrer page name without the host name or
        /// query string parameters.
        /// </summary>
        /// <returns></returns>
        internal string GetReferer()
        {
            if (string.IsNullOrEmpty(Request.ServerVariables.Get("HTTP_REFERER")))
            {
                return null;
            }

            string szPage = Request.ServerVariables.Get("HTTP_REFERER");
            string szHost = Request.ServerVariables.Get("HTTP_HOST");

            Uri uriReferrer = Request.UrlReferrer;

            // If we don't find our host, then this came from an external
            // site.  Return the entire URL.
            if (szPage.IndexOf(szHost) == -1)
            {
                return szPage;
            }

            return uriReferrer.LocalPath;  //ex: /BBOS/CompanySearchResults.aspx
        }

        virtual protected bool IsTermsExempt()
        {
            string szUrl = Request.Url.ToString().Trim().ToLower();
            if (szUrl.EndsWith(PageConstants.TERMS.ToLower()))
                return true;

            return false;
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

        protected List<ServiceUnitPaymentInfo> _lServiceUnitPaymentInfo = null;
        /// <summary>
        /// Returns a List of ServiceUnitPaymentInfo objects for use when calculating
        /// prices.  These are used to communicate the appropriate data to the 
        /// ServiceUnitPayment.aspx page.
        /// </summary>
        /// <returns></returns>
        internal protected List<ServiceUnitPaymentInfo> GetServiceUnitPaymentInfo()
        {
            if (_lServiceUnitPaymentInfo == null)
            {
                if (Session["lServiceUnitPaymentInfo"] == null)
                {
                    _lServiceUnitPaymentInfo = new List<ServiceUnitPaymentInfo>();

                    if (PersistPaymentInfo())
                    {
                        Session["lServiceUnitPaymentInfo"] = _lServiceUnitPaymentInfo;
                    }
                }
                else
                {
                    _lServiceUnitPaymentInfo = (List<ServiceUnitPaymentInfo>)Session["lServiceUnitPaymentInfo"];
                }
            }

            return _lServiceUnitPaymentInfo;
        }

        virtual protected bool PersistPaymentInfo()
        {
            return false;
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

        private const string SQL_GET_COMMODITIES = @"
            SELECT prcm_RootParentID,
                   prcm_CommodityId,
                   prcm_ParentId,
                   prcm_Level,
                   CASE WHEN {0} IS NULL THEN prcm_Name ELSE {0} END AS prcm_Name,
                   CASE WHEN {1} IS NULL THEN prcm_FullName ELSE {1} END AS prcm_FullName,
                   prcm_CommodityCode
              FROM PRCommodity WITH (NOLOCK)
          ORDER BY prcm_RootParentID, prcm_FullName;";

        /// <summary>
        /// Retrieves and stores the current commodities list from the database
        /// </summary>
        /// <returns>DataTable of current PRCommodity values</returns>
        public DataTable GetCommodityList()
        {
            string szCacheName = string.Format("dtCommodityList_{0}", GetCulture(_oUser));
            if (GetCacheValue(szCacheName) == null)
            {
                DataSet dsCommodityList = GetDBAccess().ExecuteSelect(string.Format(SQL_GET_COMMODITIES,
                    GetObjectMgr().GetLocalizedColName("prcm_Name"),
                    GetObjectMgr().GetLocalizedColName("prcm_FullName")));

                DataTable dtCommodityList = dsCommodityList.Tables[0];

                // Store in Session
                AddCacheValue(szCacheName, dtCommodityList);
                return dtCommodityList;
            }
            else
            {
                return (DataTable)GetCacheValue(szCacheName);
            }
        }

        #region "SetTableValues"
        /// <summary>
        /// Helper function to set control values in the specified table based on the 
        /// current selected value list.
        /// </summary>
        /// <param name="aszValueList">List of selected values</param>
        /// <param name="tblTable">Table containing controls to select</param>
        /// <param name="szControlGroupPrefix">Naming prefix used for control list</param>
        protected void SetTableValues(string[] aszValueList, Table tblTable, string szControlGroupPrefix)
        {
            SetTableValues(aszValueList, tblTable, szControlGroupPrefix, true);
        }
        protected void SetTableValues_Bootstrap(string[] aszValueList, Control phTable, string szControlGroupPrefix)
        {
            SetTableValues_Bootstrap(aszValueList, phTable, szControlGroupPrefix, true);
        }

        protected void SetTableValues(string[] aszValueList, Table tblTable, string szControlGroupPrefix, bool bTableEnabled)
        {
            SetTableValues(aszValueList, tblTable, szControlGroupPrefix, bTableEnabled, true);
        }

        protected void SetTableValues_Bootstrap(string[] aszValueList, Control phTable, string szControlGroupPrefix, bool bTableEnabled)
        {
            SetTableValues_Bootstrap(aszValueList, phTable, szControlGroupPrefix, bTableEnabled, true);
        }

        protected void SetTableValues(string[] aszValueList, Table tblTable, string szControlGroupPrefix, bool bTableEnabled, bool bDisableChildIfParentChecked)
        {
            SetTableValues(aszValueList, tblTable, szControlGroupPrefix, bTableEnabled, bDisableChildIfParentChecked, true);
        }

        protected void SetTableValues_Bootstrap(string[] aszValueList, Control phTable, string szControlGroupPrefix, bool bTableEnabled, bool bDisableChildIfParentChecked)
        {
            SetTableValues_Bootstrap(aszValueList, phTable, szControlGroupPrefix, bTableEnabled, bDisableChildIfParentChecked, true);
        }

        protected void SetTableValues(string[] aszValueList, Table tblTable, string szControlGroupPrefix, bool bTableEnabled, bool bDisableChildIfParentChecked, bool bCheckChildIfParentChecked)
        {
            foreach (string szValue in aszValueList)
            {
                //if (!String.IsNullOrEmpty(szValue)) {
                foreach (TableRow oRow in tblTable.Rows)
                {
                    foreach (TableCell oCell in oRow.Cells)
                    {
                        foreach (Control oControl in oCell.Controls)
                        {
                            if ((!string.IsNullOrEmpty(oControl.ID)) &&
                                (oControl.ID.Contains("CHK_" + szControlGroupPrefix)))
                            {

                                CheckBox oCheckbox = (CheckBox)oControl;
                                if (oCheckbox.Attributes["Value"].ToString() == szValue)
                                {
                                    oCheckbox.Checked = true;
                                }
                                else
                                {
                                    if (oCheckbox.InputAttributes["ParentID"] != null)
                                    {
                                        string szParentControlID = oCheckbox.InputAttributes["ParentID"].ToString();
                                        CheckBox oParentCheckbox = (CheckBox)this.Master.FindControl("form1").FindControl("contentMain").FindControl(szParentControlID);

                                        if ((bDisableChildIfParentChecked) &&
                                            (oParentCheckbox.Checked))
                                        {
                                            oCheckbox.Enabled = false;
                                        }
                                        else
                                        {
                                            oCheckbox.Enabled = bTableEnabled;
                                        }

                                        if ((bCheckChildIfParentChecked) &&
                                            (oParentCheckbox.Checked))
                                        {
                                            oCheckbox.Checked = true;
                                        }
                                    }
                                }
                            }
                            else
                            {
                                // Process Child tables
                                if ((!string.IsNullOrEmpty(oControl.ID)) &&
                                    (oControl.ID.Contains("TBL_")))
                                {
                                    SetTableValues(aszValueList, (Table)oControl, szControlGroupPrefix, bTableEnabled, bDisableChildIfParentChecked, bCheckChildIfParentChecked);
                                }
                            }
                        }
                    }
                    // }
                }
            }
        }

        protected void SetTableValues_Bootstrap(string[] aszValueList, Control phTable, string szControlGroupPrefix, bool bTableEnabled, bool bDisableChildIfParentChecked, bool bCheckChildIfParentChecked)
        {
            foreach (string szValue in aszValueList)
            {
                foreach (CheckBox oCheckBox in phTable.FindDescendants<CheckBox>())
                {
                    if (oCheckBox.ID.Contains("CHK_" + szControlGroupPrefix))
                    {
                        if (oCheckBox.Attributes["Value"].ToString() == szValue)
                        {
                            oCheckBox.Checked = true;
                        }
                        else
                        {
                            if (oCheckBox.InputAttributes["ParentID"] != null)
                            {
                                string szParentControlID = oCheckBox.InputAttributes["ParentID"].ToString();

                                CheckBox oParentCheckbox = null;

                                foreach (CheckBox oCB in this.Master.FindControl("form1").FindControl("contentMain").FindDescendants<CheckBox>())
                                {
                                    if (oCB.ClientID.EndsWith(szParentControlID))
                                    {
                                        oParentCheckbox = oCB;
                                        break;
                                    }
                                }

                                if ((oParentCheckbox != null && bDisableChildIfParentChecked) &&
                                    (oParentCheckbox.Checked))
                                {
                                    oCheckBox.Enabled = false;
                                }
                                else
                                {
                                    oCheckBox.Enabled = bTableEnabled;
                                }

                                if ((oParentCheckbox != null && bCheckChildIfParentChecked) &&
                                    (oParentCheckbox.Checked))
                                {
                                    oCheckBox.Checked = true;
                                }
                            }
                        }
                    }
                }
            }
        }
        #endregion
        #region "SetPlaceholderValues"
        protected void SetPlaceholderValues(string[] aszValueList, Control phControl, string szControlGroupPrefix)
        {
            foreach (string szValue in aszValueList)
            {
                foreach (Control oSpan in phControl.Controls)
                {
                    foreach (Control oControl in oSpan.Controls)
                    {
                        if ((!string.IsNullOrEmpty(oControl.ID)) &&
                                        (oControl.ID.Contains("CHK_" + szControlGroupPrefix)))
                        {

                            CheckBox oCheckbox = (CheckBox)oControl;
                            if (oCheckbox.Attributes["Value"].ToString() == szValue)
                            {
                                oCheckbox.Checked = true;
                            }
                        }
                    }
                }
            }
        }
        #endregion

        #region "GetTable..."
        /// <summary>
        /// Helper method used to retrieve values from a table of checkbox controls.  
        /// This function will recursively parse any subtable controls found in the table and 
        /// retrieve their checkbox control values as well.
        /// </summary>
        /// <param name="tblTable">Table containing control values to retrieve</param>
        /// <param name="szControlGroupPrefix">Naming prefix used for controls to retrieve</param>
        /// <returns>Comma-delimited list of checked commodities</returns>
        protected string GetTableValues(Table tblTable, string szControlGroupPrefix)
        {
            StringBuilder sbValueList = new StringBuilder();

            foreach (TableRow oRow in tblTable.Rows)
            {
                foreach (TableCell oCell in oRow.Cells)
                {
                    foreach (Control oControl in oCell.Controls)
                    {
                        if ((!string.IsNullOrEmpty(oControl.ID)) &&
                            (oControl.ID.Contains("CHK_" + szControlGroupPrefix)))
                        {
                            CheckBox oCheckbox = (CheckBox)oControl;
                            if (oCheckbox.Checked)
                            {
                                AddDelimitedValue(sbValueList, oCheckbox.Attributes["Value"].ToString());
                            }
                        }
                        else
                        {
                            // If there is a child table, 
                            // loop through and retrieve those values
                            if ((!string.IsNullOrEmpty(oControl.ID)) &&
                                (oControl.ID.Contains("TBL_")))
                            {
                                string szChildValues = "";
                                szChildValues = GetTableValues((Table)oControl, szControlGroupPrefix);

                                if (szChildValues.Length > 0)
                                {
                                    AddDelimitedValue(sbValueList, szChildValues);
                                }
                            }
                        }
                    }
                }
            }

            return sbValueList.ToString();
        }
        protected string GetCheckboxValues_Bootstrap(Control phHolder, string szControlGroupPrefix)
        {
            StringBuilder sbValueList = new StringBuilder();

            foreach (CheckBox oCheckbox in phHolder.FindDescendants<CheckBox>())
            {
                if (oCheckbox.ID.Contains("CHK_" + szControlGroupPrefix))
                {
                    if (oCheckbox.Checked)
                        AddDelimitedValue(sbValueList, oCheckbox.Attributes["Value"].ToString());
                }
            }

            return sbValueList.ToString();
        }
        #endregion

        #region "GetPlaceholder..."
        protected string GetPlaceholderValues(Control phControl, string szControlGroupPrefix)
        {
            StringBuilder sbValueList = new StringBuilder();
            foreach(Control oSpan in phControl.Controls)
            {
                foreach (Control oControl in oSpan.Controls)
                {
                    if (!string.IsNullOrEmpty(oControl.ID) &&
                        oControl.ID.Contains("CHK_" + szControlGroupPrefix))
                    {
                        CheckBox oCheckBox = (CheckBox)oControl;
                        if(oCheckBox.Checked)
                        {
                            AddDelimitedValue(sbValueList, oCheckBox.Attributes["value"].ToString());
                        }

                    }
                }
            }

            //TODO handle sub-table
            //            }
            //            else
            //            {
            //                // If there is a child table, 
            //                // loop through and retrieve those values
            //                if ((!string.IsNullOrEmpty(oControl.ID)) &&
            //                    (oControl.ID.Contains("TBL_")))
            //                {
            //                    string szChildValues = "";
            //                    szChildValues = GetTableValues((Table)oControl, szControlGroupPrefix);

            //                    if (szChildValues.Length > 0)
            //                    {
            //                        AddDelimitedValue(sbValueList, szChildValues);
            //                    }
            //                }
            //            }
            //        }
            //    }
            //}

            return sbValueList.ToString();
        }
        #endregion

        /// <summary>
        /// Helper method that manually creates the FormsAuthentication ticket so
        /// the user isn't asked to log in a 2nd time.
        /// </summary>
        /// <param name="szEmail"></param>
        /// <param name="szPassword"></param>
        protected void CreateAuthenticationTicket(string szEmail, string szPassword)
        {
            FormsAuthenticationTicket AuthTicket = new FormsAuthenticationTicket(szEmail,
                                                                                 false,
                                                                                 Utilities.GetIntConfigValue("FormAuthTimeout", 60));

            string szCookieValue = FormsAuthentication.Encrypt(AuthTicket);
            HttpCookie oCookie = new HttpCookie(FormsAuthentication.FormsCookieName, szCookieValue);

            oCookie.Path = FormsAuthentication.FormsCookiePath;
            Response.Cookies.Add(oCookie);
        }


        #region Product/Pricing Constants and Functions
        protected const string CODE_PRICINGLIST_ONLINE_DELIVERY = "16010";

        public const string SQL_GET_PRODUCTS_BY_FAMILY =
            @"SELECT RTRIM(ISNULL({1},prod_Name)) prod_Name, RTRIM(prod_code) prod_code, 
                     prod_productfamilyid, prod_ProductID, ISNULL({2},prod_PRDescription) prod_PRDescription, dbo.ufn_GetProductPrice(prod_ProductID, 16010) As pric_price, 
                     prod_IndustryTypeCode 
                FROM NewProduct     
               WHERE prod_Deleted IS NULL AND prod_Active = 'Y' 
                 AND prod_productfamilyid = {0} 
            ORDER BY prod_PRSequence";

        /// <summary>
        /// Helper method used to retrieve the available products for the specified product 
        /// family.
        /// </summary>
        /// <returns>Product DataTable contain: prod_Name, prod_code, prod_productfamilyid, 
        /// prod_ProductID, prod_PRDescription, pric_Price</returns>
        public DataTable GetProductsByFamily(int iProductFamilyID, string szCulture)
        {
            string szCacheName = string.Format("dtProducts{0}_{1}", iProductFamilyID, szCulture);

            if (GetCacheValue(szCacheName) == null)
            {
                // We want our own connection to avoid conflicts with
                // an open DataReader
                IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
                oDBAccess.Logger = _oLogger;

                string szPRName = null;
                string szPRDescription = null;

                switch(szCulture)
                {
                    case ENGLISH_CULTURE:
                        szPRName = "prod_name";
                        szPRDescription = "prod_PRDescription";
                        break;
                    case SPANISH_CULTURE:
                        szPRName = "prod_Name_ES";
                        szPRDescription = "prod_PRDescription_ES";

                        break;
                }

                // Retrieve Product List from Database
                string szSQL = String.Format(SQL_GET_PRODUCTS_BY_FAMILY, iProductFamilyID,
                    szPRName,
                    szPRDescription);

                DataSet dsProductList;
                DataTable dtProductList;

                dsProductList = oDBAccess.ExecuteSelect(szSQL);
                dtProductList = dsProductList.Tables[0];

                // Store in Session
                AddCacheValue(szCacheName, dtProductList);
                return dtProductList;
            }
            else
            {
                return (DataTable)GetCacheValue(szCacheName);
            }
        }


        /// <summary>
        /// Helper method that returns names/descriptions
        /// for the specified product IDs.
        /// </summary>
        /// <returns></returns>
        protected string GetProductDescriptions(CreditCardPaymentInfo oCCPaymentInfo)
        {
            string szProductIDs = string.Empty;
            foreach (CreditCardProductInfo oProductInfo in oCCPaymentInfo.Products)
            {
                if (szProductIDs.Length > 0)
                {
                    szProductIDs += ",";
                }
                szProductIDs += oProductInfo.ProductID.ToString();
            }

            Hashtable htProductDescription = new Hashtable();

            string szSQL = "SELECT Prod_ProductID, RTRIM(" + GetObjectMgr().GetLocalizedColName("prod_name") + ") AS prod_name FROM NewProduct WHERE Prod_ProductID IN (" + szProductIDs + ")";

            IDataReader oReader = null;
            try
            {
                oReader = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection);
                while (oReader.Read())
                {
                    htProductDescription.Add(oReader.GetInt32(0), (oReader.GetString(1)));
                }

            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }

            StringBuilder sbProductDescription = new StringBuilder();
            foreach (CreditCardProductInfo oProductInfo in oCCPaymentInfo.Products)
            {
                if (sbProductDescription.Length > 0)
                {
                    sbProductDescription.Append("<br />");
                }

                if (oProductInfo.ProductFamilyID != 8)
                {
                    sbProductDescription.Append(UIUtils.GetStringFromInt(oProductInfo.Quantity));
                    sbProductDescription.Append(" ");
                }
                sbProductDescription.Append((string)htProductDescription[oProductInfo.ProductID]);

                // Handle Company Updates
                if (oProductInfo.ProductID == Convert.ToInt32(Configuration.ExpressUpdateProductID))
                {
                    //sbProductDescription.Append(" (" + GetReferenceValue("prmp_DeliveryCode", oProductInfo.DeliveryCode) + ": " + oProductInfo.DeliveryDestination + ")");
                }
            }

            return sbProductDescription.ToString();
        }
        #endregion

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
                string cookie_guid = ((Request.Cookies[PageConstants.BBOS_SESSIONID] != null) ? Request.Cookies[PageConstants.BBOS_SESSIONID].Value : String.Empty);
                if ((cookie_guid != oSessionTracker.GUID) || Session.SessionID != oSessionTracker.SessionID) {

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
            Response.Cookies[PageConstants.BBOS_SESSIONID].Value = oSessionTracker.GUID;
            Response.Cookies[PageConstants.BBOS_SESSIONID].Expires = DateTime.Now.AddHours(Utilities.GetIntConfigValue("SessionTrackerCookieHours", 8));
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
                    Response.Cookies[PageConstants.BBOS_SESSIONID].Expires = DateTime.Now.AddYears(-1);
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

        /// <summary>
        /// Returns the file name for the Pricing Chart depending
        /// on the level of access the current user has.
        /// </summary>
        /// <returns></returns>
        protected string GetPricingChartPDF()
        {
            return Utilities.GetConfigValue("PricingChartFileMembers");
        }

        /// <summary>
        /// This function essentially replaces the old ServiceUnitPayment.aspx's 
        /// btnPurchaseOnClick event.  That page is gone, but now instead 
        /// </summary>
        /// <param name="_lServiceUnitPaymentInfo"></param>
        /// <param name="iTotalCost"></param>
        /// <param name="szRequestType"></param>
        /// <param name="szUsageType"></param>
        /// <param name="szTriggerPage"></param>
        /// <param name="szSourceID"></param>
        /// <param name="szSourceEntityType"></param>
        internal int ExecutePurchaseWithUnits(List<ServiceUnitPaymentInfo> _lServiceUnitPaymentInfo,
                                        int iTotalCost,
                                        string szRequestType,
                                        string szUsageType,
                                        string szTriggerPage,
                                        string szSourceID,
                                        string szSourceEntityType)
        {
            int iProductID = 0;

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("HQID", _oUser.prwu_HQID));
            oParameters.Add(new ObjectParameter("CompanyID", _oUser.prwu_BBID));
            oParameters.Add(new ObjectParameter("PersonID", _oUser.peli_PersonID));
            oParameters.Add(new ObjectParameter("UsageType", szUsageType));
            oParameters.Add(new ObjectParameter("SourceType", "O"));  // Always Online
            oParameters.Add(new ObjectParameter("PricingListID", PRICING_LIST_ONLINE)); // Always Web
            oParameters.Add(new ObjectParameter("RequestorInfo", _oUser.Name));
            oParameters.Add(new ObjectParameter("ProductID", null));
            oParameters.Add(new ObjectParameter("RegardingCompanyID", null));
            oParameters.Add(new ObjectParameter("RegardingObjectID", null));
            oParameters.Add(new ObjectParameter("RequestID", null));

            int iRequestID = 0;

            GeneralDataMgr oGeneralDataMgr = new GeneralDataMgr(_oLogger, _oUser);
            oGeneralDataMgr.User = _oUser;

            IDbTransaction oTran = oGeneralDataMgr.BeginTransaction();
            try
            {
                StringBuilder sbRequestIDs = new StringBuilder();

                // First build a list of the Object IDs.
                foreach (ServiceUnitPaymentInfo oPaymentInfo2 in _lServiceUnitPaymentInfo)
                {
                    if (oPaymentInfo2.IncludeInRequest)
                    {
                        if (sbRequestIDs.Length > 0)
                        {
                            sbRequestIDs.Append(",");
                        }
                        sbRequestIDs.Append(oPaymentInfo2.ObjectID.ToString());
                    }
                }

                // Now create the Request records.
                if (sbRequestIDs.Length > 0)
                {
                    iRequestID = oGeneralDataMgr.CreateRequest(szRequestType,
                                                               (decimal)iTotalCost,
                                                               sbRequestIDs.ToString(),
                                                               iProductID,
                                                               PRICING_LIST_ONLINE,
                                                               szTriggerPage,
                                                               szSourceID,
                                                               szSourceEntityType,
                                                               oTran);
                }

                // If we have a Request ID, then include it
                // when invoking the "Consume Units" usp.
                if (iRequestID > 0)
                {
                    ((ObjectParameter)oParameters[10]).Value = iRequestID;
                }

                foreach (ServiceUnitPaymentInfo oPaymentInfo in _lServiceUnitPaymentInfo)
                {
                    if (oPaymentInfo.IncludeInRequest)
                    {
                        // When paying by service units, only a single
                        // product can be purchased at a time.
                        iProductID = oPaymentInfo.ProductID;
                    }

                    if (oPaymentInfo.Charge)
                    {
                        ((ObjectParameter)oParameters[7]).Value = oPaymentInfo.ProductID;

                        if (szUsageType == "OBR")
                        {
                            ((ObjectParameter)oParameters[8]).Value = oPaymentInfo.ObjectID;
                            ((ObjectParameter)oParameters[9]).Value = null;
                        }
                        else
                        {
                            ((ObjectParameter)oParameters[8]).Value = null;
                            ((ObjectParameter)oParameters[9]).Value = oPaymentInfo.ObjectID;
                        }

                        GetDBAccess().ExecuteNonQuery("usp_ConsumeServiceUnits", oParameters, oTran, CommandType.StoredProcedure);
                    }
                }
                oTran.Commit();
            }
            catch
            {
                oTran.Rollback();
                throw;
            }

            Session["ServiceUnitPaymentPaymentID"] = iRequestID.ToString();
            Session.Remove("lServiceUnitPaymentInfo");

            return iRequestID;
        }

        protected const string SQL_GET_IS_COMPANY_ELIGIBLE_FOR_EQUIFAX = "SELECT comp_PRIsEligibleForEquifaxData FROM Company WITH (NOLOCK) WHERE comp_PRHQID={0}";
        public bool IsEligibleForEquifaxData()
        {
            // We need to know if the current user's HQ is eligible to view
            // Equifax Data.  Look once and stash the answer in the session.
            if (Session["szIsEligibleForEquifaxData"] == null)
            {
                object oIsEligibleForEquifaxData = GetDBAccess().ExecuteScalar(string.Format(SQL_GET_IS_COMPANY_ELIGIBLE_FOR_EQUIFAX, _oUser.prwu_HQID));
                if (oIsEligibleForEquifaxData == DBNull.Value)
                {
                    Session["szIsEligibleForEquifaxData"] = "N";
                }
                else
                {
                    Session["szIsEligibleForEquifaxData"] = "Y";
                }
            }

            if (((string)Session["szIsEligibleForEquifaxData"]) == "Y")
            {
                return true;
            }

            return false;
        }

        protected const string SQL_GET_IS_COMPANY_ELIGIBLE_AS_EQUIFAX_SUBJECT = "SELECT comp_PRExcludeAsEquifaxSubject FROM Company WITH (NOLOCK) WHERE comp_PRHQID={0}";
        public bool IsEligibleAsEquifaxSubject()
        {

            // We need to know if the subject company is eligibile for
            // equifax data.
            if (Session["szIsEligibleAsEquifaxSubject"] == null)
            {
                object oIsEligibleForEquifaxData = GetDBAccess().ExecuteScalar(string.Format(SQL_GET_IS_COMPANY_ELIGIBLE_AS_EQUIFAX_SUBJECT, _oUser.prwu_HQID));
                if (oIsEligibleForEquifaxData == DBNull.Value)
                {
                    Session["szIsEligibleAsEquifaxSubject"] = "N";
                }
                else
                {
                    Session["szIsEligibleAsEquifaxSubject"] = "Y";
                }
            }

            if (((string)Session["szIsEligibleAsEquifaxSubject"]) == "Y")
            {
                return true;
            }

            return false;
        }

        virtual protected bool SessionTimeoutForPageEnabled()
        {
            return Utilities.GetBoolConfigValue("SessionTimeoutForPageEnabled", false);
        }

        /// <summary>
        /// Helper method that generates the "read more >" link if the article has
        /// a body.  If so, the appropriate link is constructed based on the 
        /// publication code.
        /// </summary>
        /// <param name="bMore"></param>
        /// <param name="szPublicationCode"></param>
        /// <param name="iArticleID"></param>
        /// <param name="oEditionID"></param>
        /// <returns></returns>
        protected string GetMoreLink(bool bMore, string szPublicationCode, int iArticleID, object oEditionID)
        {

            string szMore = "<a href=\"{0}\" class='explicitlink'>" + Resources.Global.ReadMore + " ></a>";
            string szURL = null;
            switch (szPublicationCode)
            {
                case "BBN":
                    szURL = PageConstants.Format(PageConstants.NEWS_ARTICLE, iArticleID);
                    break;
                //case "BP":
                //    szURL = PageConstants.Format(PageConstants.BLUEPRINTS_EDITION, Convert.ToInt32(oEditionID));
                //    break;
                case "BBR":
                    szURL = PageConstants.BLUEBOOK_REFERENCE;
                    break;
                case "BBS":
                    szURL = PageConstants.BLUEBOOK_SERVICES;
                    break;
                case "BPO":
                    szURL = PageConstants.Format(PageConstants.BLUEPRINTS_ONLINE_ARTICLE, iArticleID);
                    break;
                default:
                    throw new ApplicationUnexpectedException("Invalid Publication Code Found: " + szPublicationCode);
            }

            return string.Format(szMore, szURL);
        }

        protected string _szWebSite = null;
        public string GetMarketingSiteURL(string szPageName)
        {
            if (string.IsNullOrEmpty(szPageName))
            {
                return "#";
            }

            if (string.IsNullOrEmpty(_szWebSite))
            {
                if (_oUser == null)
                {
                    _szWebSite = Utilities.GetConfigValue("CorporateWebSite");
                }
                else if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                {
                    _szWebSite = Utilities.GetConfigValue("LumberWebSite");
                }
                else
                {
                    _szWebSite = Utilities.GetConfigValue("ProduceWebSite");
                }

                _szWebSite += "/";
            }

            return _szWebSite + szPageName;
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

        protected const string SQL_IS_TMFM_MEMBER =
            "SELECT 'x' FROM Company WITH (NOLOCK) WHERE comp_CompanyID=@CompanyID AND comp_PRTMFMAward = 'Y' AND comp_PRIndustryType IN ('P', 'T')";
        protected bool IsTMFMMember(int iCompanyID)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", iCompanyID));

            object oResult = GetDBAccess().ExecuteScalar(SQL_IS_TMFM_MEMBER, oParameters);
            if ((oResult == null) ||
                (oResult == DBNull.Value))
            {
                return false;
            }

            return true;
        }

        protected bool CheckForMaintenanceRedirect()
        {
            bool redirect = false;

            if (Utilities.GetBoolConfigValue("MaintenanceEnabled", false))
            {
                redirect = true;
                if ((GetRequestParameter("BBSiMO", false) == "Y") ||
                    (((string)Session["BBSiMO"]) == "Y"))
                {

                    Session["BBSiMO"] = "Y";
                    redirect = false;
                }

                if (redirect)
                {
                    Response.Redirect(Utilities.GetConfigValue("MaintenanceRedirectURL"));
                }
            }

            return redirect;
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

        protected const string SQL_VALIDATE_TES_SUBJECT =
            "SELECT dbo.ufn_IsEligibleForManualTES2({0}, {1}, {2})";

        internal bool IsValidTESSubject(IPRWebUser user, int subjectCompanyID)
        {
            int result = Convert.ToInt32(GetDBAccess().ExecuteScalar(string.Format(SQL_VALIDATE_TES_SUBJECT, user.prwu_BBID, subjectCompanyID, 0))); //ignore TES exclusion list, per defect 7500
            if (result == 0)
            {
                return false;
            }

            return true;
        }

        private const string SQL_GET_FORMATTED_EMAIL = "SELECT dbo.ufn_GetFormattedEmail(@CompanyID, @PersonID, 0, @Title, @Body, null)";
        virtual protected string GetFormattedEmail(IPRWebUser user, string subject, string text)
        {
            IList parameters = new ArrayList();
            parameters.Add(new ObjectParameter("CompanyID", user.prwu_BBID));
            parameters.Add(new ObjectParameter("PersonID", user.peli_PersonID));
            parameters.Add(new ObjectParameter("Title", subject));
            parameters.Add(new ObjectParameter("Body", text));
            return (string)GetDBAccess().ExecuteScalar(SQL_GET_FORMATTED_EMAIL, parameters);

        }

        protected const string PERSON_COMPANIES_CELL = "<tr><td style='text-align:center;'>{0}</td><td style='text-align:right;'>{1}</td><td>{2}</td></tr>";
        protected const string BOOTSTRAP_ROW_TEMPLATE = "<tr><td class=\"{0}\">{1}</td></tr>";

        protected const string SQL_GET_PERSON_COMPANIES =
            @"SELECT peli_PersonID, vPRBBOSCompanyList.*, peli_PRTitle, dbo.ufn_HasNote({0}, {1}, comp_CompanyID, 'C') As HasNote,
                     dbo.ufn_HasNewClaimActivity(comp_PRHQID, '{3}') as HasNewClaimActivity, 
                     dbo.ufn_HasMeritoriousClaim(comp_PRHQID, '{4}') as HasMeritoriousClaim,
                     dbo.ufn_HasCertification(comp_PRHQID) as HasCertification,
                     dbo.ufn_HasCertification_Organic(comp_PRHQID) as HasCertification_Organic,
                     dbo.ufn_HasCertification_FoodSafety(comp_PRHQID) as HasCertification_FoodSafety
                FROM Person_Link WITH (NOLOCK)
                     INNER JOIN vPRBBOSCompanyList ON peli_CompanyID = comp_CompanyID 
               WHERE peli_PersonID IN ({2}) 
                 AND peli_PRStatus='1' 
                 AND peli_PREBBPublish='Y' 
                 AND {5} AND {6} 
            ORDER BY peli_PersonID, comp_PRBookTradestyle";

        protected const string SQL_PRWEBUSERCONTACT_COMPANIES =
            @"SELECT prwuc_WebUserID, vPRBBOSCompanyList.*, dbo.ufn_HasNote({0}, {1}, comp_CompanyID, 'C') As HasNote,
                     dbo.ufn_HasNewClaimActivity(comp_PRHQID, '{3}') as HasNewClaimActivity, 
                     dbo.ufn_HasMeritoriousClaim(comp_PRHQID, '{4}') as HasMeritoriousClaim,
                     dbo.ufn_HasCertification(comp_PRHQID) as HasCertification,
                     dbo.ufn_HasCertification_Organic(comp_PRHQID) as HasCertification_Organic,
                     dbo.ufn_HasCertification_FoodSafety(comp_PRHQID) as HasCertification_FoodSafety
                FROM PRWebUserContact 
                     INNER JOIN vPRBBOSCompanyList ON prwuc_CompanyId = comp_CompanyID 
               WHERE prwuc_WebUserID IN ({2})
            ORDER BY comp_PRBookTradestyle";


        protected DataView _dvPersonCompanies = null;
        protected DataView _dvWebContactCompanies = null;

        protected string GetPersonCompanies(int iPersonID, string szSourceTable, string personIDList)
        {
            StringBuilder sbCell = new StringBuilder("<table cellpadding=\"0\" cellspacing=\"0\" style=\"margin:0;\">");

            DataRowView[] adrPersonCompanies = GetPersonCompanyData(iPersonID, szSourceTable, personIDList);

            foreach (DataRowView drRow in adrPersonCompanies)
            {
                object[] oArgs = {drRow["comp_CompanyID"],
                                  GetCompanyDataForCell((int)drRow["comp_CompanyID"],
                                                            (string)drRow["comp_PRBookTradestyle"],
                                                            (string)drRow["comp_PRLegalName"],
                                                            UIUtils.GetBool(drRow["HasNote"]),
                                                            UIUtils.GetDateTime(drRow["comp_PRLastPublishedCSDate"]),
                                                            (string)drRow["comp_PRListingStatus"],
                                                            true,
                                                            true,
                                                            UIUtils.GetBool(drRow["HasNewClaimActivity"]),
                                                            UIUtils.GetBool(drRow["HasMeritoriousClaim"]),
                                                            UIUtils.GetBool(drRow["HasCertification"]),
                                                            UIUtils.GetBool(drRow["HasCertification_Organic"]),
                                                            UIUtils.GetBool(drRow["HasCertification_FoodSafety"])
                                                          ),
                                    drRow["CityStateCountryShort"]};

                sbCell.Append(string.Format(PERSON_COMPANIES_CELL, oArgs));
            }

            sbCell.Append("</table>");
            return sbCell.ToString();
        }

        protected string GetBBNumbers(int iPersonID, string szSourceTable, string personIDList)
        {
            DataRowView[] adrPersonCompanies = GetPersonCompanyData(iPersonID, szSourceTable, personIDList);

            StringBuilder sbBBNumbers = new StringBuilder();

            foreach (DataRowView drRow in adrPersonCompanies)
            {
                string brs = "<br/>";
                if((drRow["comp_PRLegalName"] != null && !drRow["comp_PRLegalName"].ToString().Equals(""))) brs += "<br/>";
                sbBBNumbers.Append(string.Format("{0}" + brs, drRow["comp_CompanyID"]));
            }

            return sbBBNumbers.ToString();
        }

        protected string GetCompanyNames(int iPersonID, string szSourceTable, string personIDList, bool bIncludeIcons, bool bIncludeCompanyNameLink, bool bCompanyLinksNewTab)
        {
            DataRowView[] adrPersonCompanies = GetPersonCompanyData(iPersonID, szSourceTable, personIDList);

            StringBuilder sbCompanyNames = new StringBuilder();

            foreach (DataRowView drRow in adrPersonCompanies)
            {
                string szCompanyData = GetCompanyDataForCell((int)drRow["comp_CompanyID"],
                                                           (string)drRow["comp_PRBookTradestyle"],
                                                           (string)drRow["comp_PRLegalName"],
                                                           bIncludeIcons?UIUtils.GetBool(drRow["HasNote"]) : false,
                                                           UIUtils.GetDateTime(drRow["comp_PRLastPublishedCSDate"]),
                                                           (string)drRow["comp_PRListingStatus"],
                                                           bIncludeIcons,
                                                           bIncludeIcons?UIUtils.GetBool(drRow["HasNewClaimActivity"]) : false,
                                                           bIncludeIcons?UIUtils.GetBool(drRow["HasMeritoriousClaim"]) : false,
                                                           bIncludeIcons?UIUtils.GetBool(drRow["HasCertification"]) : false,
                                                           bIncludeIcons ? UIUtils.GetBool(drRow["HasCertification_Organic"]) : false,
                                                           bIncludeIcons ? UIUtils.GetBool(drRow["HasCertification_FoodSafety"]) : false,
                                                           bIncludeIcons,
                                                           bIncludeCompanyNameLink:bIncludeCompanyNameLink,
                                                           bCompanyLinksNewTab: bCompanyLinksNewTab
                                                           );

                sbCompanyNames.Append(string.Format("{0}", szCompanyData));
            }

            return sbCompanyNames.ToString();
        }

        protected string GetCompanyLocations(int iPersonID, string szSourceTable, string personIDList)
        {
            DataRowView[] adrPersonCompanies = GetPersonCompanyData(iPersonID, szSourceTable, personIDList);

            StringBuilder sbCompanyLocations = new StringBuilder();

            foreach (DataRowView drRow in adrPersonCompanies)
            {
                sbCompanyLocations.Append(string.Format("{0}<br/>", drRow["CityStateCountryShort"]));
            }

            return sbCompanyLocations.ToString();
        }

        private DataRowView[] GetPersonCompanyData(int iPersonID, string szSourceTable, string personIDList)
        {
            DataRowView[] adrPersonCompanies = null;
            if (szSourceTable == SOURCE_TABLE_PRWEBUSERCONTACT)
            {
                if (_dvWebContactCompanies == null)
                {
                    object[] args = {_oUser.prwu_WebUserID,
                                     _oUser.prwu_HQID,
                                     iPersonID,
                                     DateTime.Today.AddDays(0 - Configuration.ClaimActivityNewThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss"),
                                     DateTime.Today.AddDays(0 - Configuration.ClaimActivityMeritoriousThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss")};

                    string szSQL = string.Format(SQL_PRWEBUSERCONTACT_COMPANIES, args);

                    IDBAccess oDataAccess = DBAccessFactory.getDBAccessProvider();
                    oDataAccess.Logger = _oLogger;
                    DataSet _dsWebContactCompanies = oDataAccess.ExecuteSelect(szSQL);
                    _dvWebContactCompanies = new DataView(_dsWebContactCompanies.Tables[0]);
                    _dvWebContactCompanies.Sort = "prwuc_WebUserID";
                }
                adrPersonCompanies = _dvWebContactCompanies.FindRows(iPersonID);
            }
            else
            {
                if (_dvPersonCompanies == null)
                {
                    object[] args = {_oUser.prwu_WebUserID,
                                     _oUser.prwu_HQID,
                                     personIDList,
                                     DateTime.Today.AddDays(0 - Configuration.ClaimActivityNewThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss"),
                                     DateTime.Today.AddDays(0 - Configuration.ClaimActivityMeritoriousThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss"),
                                     GetObjectMgr().GetLocalSourceCondition(),
                                     GetObjectMgr().GetIntlTradeAssociationCondition()};

                    string szSQL = string.Format(SQL_GET_PERSON_COMPANIES,
                                                args);

                    IDBAccess oDataAccess = DBAccessFactory.getDBAccessProvider();
                    oDataAccess.Logger = _oLogger;
                    DataSet _dsPersonCompanies = oDataAccess.ExecuteSelect(szSQL);
                    _dvPersonCompanies = new DataView(_dsPersonCompanies.Tables[0]);
                    _dvPersonCompanies.Sort = "peli_PersonID";

                }

                adrPersonCompanies = _dvPersonCompanies.FindRows(iPersonID);
            }

            return adrPersonCompanies;
        }

        private const string CUSTOM_CONTACT_ICON = "<a href=\"{0}\"><img src=\"{1}\" alt=\"{2}\" border==\"0=\" class==\"Icon=\" align==\"middle=\"></a>&nbsp;";
        /// <summary>
        /// Helper method that builds the basic contents of a person name cell
        /// including the note icon.  Also displays a custom contact icon for 
        /// user records coming from the PRWebUserContact table
        /// </summary>
        /// <param name="iPersonID">Person ID</param>
        /// <param name="szPersonName">Person Name</param>
        /// <param name="bIncludeNotesIcon">Should Notes icon be included?</param>
        /// <param name="szSourceTable"></param>
        /// <returns>HTML for person data cell</returns>
        protected string GetPersonDataForCell(int iPersonID, string szPersonName, bool bIncludeNotesIcon, string szSourceTable)
        {
            StringBuilder sbPersonCell = new StringBuilder();

            if (szSourceTable == SOURCE_TABLE_PRWEBUSERCONTACT)
            {
                // Include custom contact Icon
                sbPersonCell.Append(string.Format(CUSTOM_CONTACT_ICON,
                    PageConstants.Format(PageConstants.USER_CONTACT, iPersonID),
                    UIUtils.GetImageURL("icon-personal-contact.gif"),
                    Resources.Global.ViewContact));
            }

            if (bIncludeNotesIcon)
            {
                string strUrl = "";
                if (_oUser.HasPrivilege(SecurityMgr.Privilege.PersonDetailsPage).HasPrivilege)
                    strUrl = PageConstants.Format(PageConstants.PERSON_DETAILS, iPersonID);
                else
                    strUrl = JAVASCRIPT_VOID;

                sbPersonCell.Append(string.Format(MATERIAL_NOTE_ICON,
                                                   strUrl,
                                                   Resources.Global.ViewPersonNotes));
            }

            string szPersonNameForCell = null;
            if (_oUser.HasPrivilege(SecurityMgr.Privilege.PersonDetailsPage).HasPrivilege)
            {
                if (szSourceTable == SOURCE_TABLE_PERSON)
                {
                    szPersonNameForCell = string.Format(DATA_FOR_CELL,
                                                   PageConstants.Format(PageConstants.PERSON_DETAILS, iPersonID),
                                                   szPersonName,
                                                   string.Empty);
                }
                else
                {
                    szPersonNameForCell = string.Format(DATA_FOR_CELL,
                                                   PageConstants.Format(PageConstants.USER_CONTACT, iPersonID),
                                                   szPersonName,
                                                   string.Empty);
                }
            }
            else
            {
                szPersonNameForCell = szPersonName;
            }

            sbPersonCell.Append(szPersonNameForCell);

            return sbPersonCell.ToString();
        }

        protected const string SQL_GET_SELECTED_COMPANIES =
            @"SELECT *, 
                     dbo.ufn_GetCustomCaptionValue('comp_PRIndustryType', comp_PRIndustryType, '{0}') As IndustryType, 
                     dbo.ufn_GetCustomCaptionValue('comp_PRType_BBOS', comp_PRType, '{0}') As CompanyType, 
                     dbo.ufn_HasNote({1}, {2}, comp_CompanyID, 'C') As HasNote,
                     dbo.ufn_HasNewClaimActivity(comp_PRHQID, '{4}') as HasNewClaimActivity, 
                     dbo.ufn_HasMeritoriousClaim(comp_PRHQID, '{5}') as HasMeritoriousClaim,
                     dbo.ufn_HasCertification(comp_PRHQID) as HasCertification,
                     dbo.ufn_HasCertification_Organic(comp_PRHQID) as HasCertification_Organic,
                     dbo.ufn_HasCertification_FoodSafety(comp_PRHQID) as HasCertification_FoodSafety
                FROM vPRBBOSCompanyList
               WHERE comp_CompanyID IN ({3})
                 AND {6} AND {7} ";

        protected const string SQL_GET_SELECTED_COMPANIES_WITH_RATINGS =
            @"SELECT *, 
                     dbo.ufn_GetCustomCaptionValue('comp_PRIndustryType', comp_PRIndustryType, '{0}') As IndustryType, 
                     dbo.ufn_GetCustomCaptionValue('comp_PRType_BBOS', comp_PRType, '{0}') As CompanyType, 
                     dbo.ufn_HasNote({1}, {2}, comp_CompanyID, 'C') As HasNote,
                     dbo.ufn_HasNewClaimActivity(comp_PRHQID, '{4}') as HasNewClaimActivity, 
                     dbo.ufn_HasMeritoriousClaim(comp_PRHQID, '{5}') as HasMeritoriousClaim,
                     dbo.ufn_HasCertification(comp_PRHQID) as HasCertification,
                     dbo.ufn_HasCertification_Organic(comp_PRHQID) as HasCertification_Organic,
                     dbo.ufn_HasCertification_FoodSafety(comp_PRHQID) as HasCertification_FoodSafety,
                     CASE WHEN comp_PRType = 'B' THEN CASE WHEN compRating.prra_RatingID IS NOT NULL THEN 'N' ELSE 'Y' END ELSE 'N' END AS IsHQRating,
                     CASE WHEN comp_PRType = 'B' THEN CASE WHEN compRating.prra_RatingID IS NOT NULL THEN compRating.prra_RatingID ELSE hqRating.prra_RatingID END ELSE hqRating.prra_RatingID END AS prra_RatingID,
                     CASE WHEN comp_PRType = 'B' THEN CASE WHEN compRating.prra_RatingID IS NOT NULL THEN compRating.prra_RatingLine ELSE hqRating.prra_RatingLine END ELSE hqRating.prra_RatingLine END AS prra_RatingLine
                FROM vPRBBOSCompanyList_ALL
                     LEFT OUTER JOIN vPRCurrentRating compRating ON comp_CompanyID = compRating.prra_CompanyID 
                     LEFT OUTER JOIN vPRCurrentRating hqRating ON comp_PRHQID = hqRating.prra_CompanyID 
               WHERE comp_CompanyID IN ({3})
                 AND {6} AND {7} ";

        /// <summary>
        /// Helper method that returns the note subject based on the
        /// associated type.
        /// </summary>
        /// <param name="iAssociatedID"></param>
        /// <param name="szAssociatedType"></param>
        /// <param name="szName"></param>
        /// <returns></returns>
        protected string GetNoteSubject(int iAssociatedID, string szAssociatedType, string szName, bool bIncludeIcons, bool bIncludeCompanyNameLink)
        {
            switch (szAssociatedType)
            {
                case "C":
                    return GetCompanyDataForCell(iAssociatedID, bIncludeIcons, bIncludeCompanyNameLink);
                case "P":
                    return UIUtils.GetHyperlink(PageConstants.Format(PageConstants.PERSON_DETAILS, iAssociatedID), szName);
                case "PC":
                    return UIUtils.GetHyperlink(PageConstants.Format(PageConstants.USER_CONTACT, iAssociatedID), szName);
            }

            return szName;
        }

        /// <summary>
        /// Helper method that returns the companylist info 
        /// </summary>
        public const string SQL_GET_CITYSTATECOUNTRYSHORT = "SELECT * FROM vPRBBOSCompanyList where Comp_CompanyId = {0}";
        protected string GetCompanyCityStateCountryShort(int iAssociatedID)
        {
            object[] args = {iAssociatedID};

            string szSQL = string.Format(SQL_GET_CITYSTATECOUNTRYSHORT, args);

            IDBAccess oDataAccess = DBAccessFactory.getDBAccessProvider();
            oDataAccess.Logger = _oLogger;
            DataSet dsCompanyList = oDataAccess.ExecuteSelect(szSQL);
            DataView dvCompanyList = null;
            dvCompanyList = new DataView(dsCompanyList.Tables[0]);

            if (dvCompanyList.Count > 0)
                return (dvCompanyList[0]["CityStateCountryShort"]).ToString();
            else
                return "";
        }


        protected void btnPrintNote_Click(object sender, EventArgs e)
        {
            string reportID = ((LinkButton)sender).CommandArgument.ToString();
            GenerateNotesReport(reportID);
        }

        protected void GenerateNotesReport(string noteIDList)
        {
            Session["NoteIDList"] = noteIDList;
            Session["PersonID"] = Request["PersonID"];
            Response.Redirect(PageConstants.Format(PageConstants.GET_REPORT, GetReport.NOTES_REPORT));
        }

        protected string GetRatingCell(object ratingID, object ratingLine, object isHQRating)
        {
            if (ratingID == DBNull.Value)
            {
                return string.Empty;
            }

            string szPopupOpen = "onclick=\"showRatingDef(this, '" + ratingID.ToString() + "');\"";
            string szPopupClose = string.Empty;

            string prefix = string.Empty;
            if (isHQRating.ToString() == "Y")
            {
                prefix = "HQ: ";
            }

            return prefix + "<span class='PopupLink2 explicitlink' " + szPopupOpen + " " + szPopupClose + ">" + ratingLine + "</span>";
        }

        //protected string GetCommmodityChecboxClass()
        //{
        //    LogMessage("UserAgent: " + Request.UserAgent);

        //    if (Request.Browser.Browser == "IE")
        //    {
        //        if ((Request.Browser.Version == "10.0") ||
        //            (Request.Browser.Version == "9.1") ||
        //            (Request.Browser.Version == "9.0"))
        //        {
        //            return "smallcheckCMDIE";
        //        }
        //    }

        //    if ((Request.UserAgent.IndexOf(" MSIE 10.6;") > 0) ||
        //        (Request.UserAgent.IndexOf(" MSIE 10.0;") > 0) ||
        //        (Request.UserAgent.IndexOf(" MSIE 9.0;") > 0))
        //    {
        //        return "smallcheckCMDIE";
        //    }

        //    return "smallcheckCMD";
        //}

        internal void ApplySecurity(Control control, SecurityMgr.Privilege privilege, bool bForceAllowed = false)
        {
            ApplySecurity(control, control, privilege, bForceAllowed);
        }

        internal void ApplySecurity(Control containerControl, Control actionControl, SecurityMgr.Privilege privilege, bool bForceAllowed = false)
        {
            SecurityMgr.SecurityResult result = null;
            if (bForceAllowed)
            {
                result = new SecurityMgr.SecurityResult();
                result.HasPrivilege = true;
                result.Enabled = true;
                result.Visible = true;
            }
            else
            {
                result = _oUser.HasPrivilege(privilege);
            }

            if(containerControl != null)
                containerControl.Visible = result.Visible;

            if (actionControl != null && actionControl is WebControl)
            {
                ((WebControl)actionControl).Enabled = result.Enabled;
            }
            else
            {
                ((HtmlControl)actionControl).Disabled = !result.Enabled;
            }
        }

        public static void ApplyReadOnlyCheck(HyperLink control)
        {
            if (Configuration.ReadOnlyEnabled)
            {
                control.NavigateUrl = "javascript:void(0)";
                control.Attributes.Add("onclick", "displayReadOnlyMsg(this);");
            }
        }

        internal static void ApplyReadOnlyCheck(LinkButton control)
        {
            if (Configuration.ReadOnlyEnabled)
            {
                control.OnClientClick = "return displayReadOnlyMsg(this);";
            }
        }

        internal static void ApplyReadOnlyCheck(HtmlButton control)
        {
            if (Configuration.ReadOnlyEnabled)
            {
                control.Attributes.Add("onclick", "return displayReadOnlyMsg(this);");
            }
        }

        protected void AddSubmenuItem(List<SubMenuItem> oMenuItems, string menuText, string menuURL, SecurityMgr.Privilege privilege)
        {
            SecurityMgr.SecurityResult result = _oUser.HasPrivilege(privilege);
            if (result.Visible)
            {
                oMenuItems.Add(new SubMenuItem(menuText, menuURL, result.Enabled));
            }
        }

        protected void AddSubmenuItemButton(List<SubMenuItem> oMenuItems, string menuText, string buttonID, SecurityMgr.Privilege? privilege, string szTooltip = "", bool bHasPrivilegeForced = false)
        {
            bool blnResultVisible = false;
            bool blnResultEnabled = false;

            if (privilege.HasValue)
            {
                SecurityMgr.SecurityResult result = _oUser.HasPrivilege(privilege.Value);
                blnResultVisible = result.Visible;
                blnResultEnabled = result.Enabled;
            }
            else
            {
                blnResultVisible = true;
                blnResultEnabled = true;
            }

            if(bHasPrivilegeForced)
            {
                blnResultVisible = true;
                blnResultEnabled = true;
            }

            if (blnResultVisible)
            {
                oMenuItems.Add(new SubMenuItem(menuText, null, buttonID, blnResultEnabled, szTooltip));
            }
        }

        protected bool IsImpersonating()
        {
            if (Session["PRCOUser.Impersonating"] == null)
            {
                return false;
            }

            return (bool)Session["PRCOUser.Impersonating"];
        }

        protected void DisplayLocalSource(GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                string isLocalSource = Convert.ToString(((IDataRecord)(e.Row.DataItem))["comp_PRLocalSource"]);

                if (isLocalSource == "Y")
                {
                    if (e.Row.RowState == DataControlRowState.Alternate)
                    {
                        e.Row.CssClass = "shaderow";
                    }

                    e.Row.CssClass += " LocalSourceRow";
                }
            }
        }

        protected void CheckDataExport(int selectedRecordCount)
        {
            if (IsPRCoUser())
            {
                return;
            }

            int exportCount = selectedRecordCount + _oUser.GetDataExportCount();
            if (_oUser.CheckDataExportCount(exportCount))
            {
                throw new ApplicationExpectedException(Resources.Global.DataExportLimitExceeded);
            }
        }

        public static string Base64Encode(string text)
        {
            var bytes = System.Text.UTF8Encoding.UTF8.GetBytes(text);
            return System.Convert.ToBase64String(bytes);
        }

        public static string Base64Decode(string encodedText)
        {
            var bytes = System.Convert.FromBase64String(encodedText);
            return System.Text.UTF8Encoding.UTF8.GetString(bytes);
        }


        protected bool HasPrivilege_ITA_Always_True(SecurityMgr.Privilege privilege)
        {
            return _oUser.HasPrivilege(privilege).HasPrivilege;
        }

        protected const string SQL_SELECT_PRIMARY_MEMBERSHIP =
           @"SELECT ISNULL(prod_ProductID,0) prod_ProductID, ISNULL(prod_PRSequence, 0) prod_PRSequence, prod_Name, prod_Code
                FROM PRService WITH (NOLOCK) 
                     INNER JOIN NewProduct WITH (NOLOCK) ON prse_ServiceCode = prod_code 
               WHERE prse_HQID=@prse_HQID 
                 AND prse_Primary = 'Y'";
        /// <summary>
        /// Helper method that queries for the current user's
        /// primary membership.
        /// </summary>
        protected string GetPrimaryMembership()
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prse_HQID", _oUser.prwu_HQID));

            IDBAccess _oDBAccess = DBAccessFactory.getDBAccessProvider();
            _oDBAccess.Logger = _oLogger;

            using (IDataReader drPrimary = _oDBAccess.ExecuteReader(SQL_SELECT_PRIMARY_MEMBERSHIP, oParameters))
            {
                if (drPrimary.Read())
                {
                    return drPrimary.GetString(3);
                }
            }

            return "";
        }

        protected int GetExportsMax_Produce()
        {
            string szPrimaryMembership = GetPrimaryMembership();
            switch (szPrimaryMembership)
            {
                case PROD_CODE_STANDARD:
                    return Utilities.GetIntConfigValue("ExportsMax_STANDARD_PRODUCE", 250);
                case PROD_CODE_PREMIUM:
                    return Utilities.GetIntConfigValue("ExportsMax_PREMIUM_PRODUCE", 500);
                case PROD_CODE_ENTERPRISE:
                    return Utilities.GetIntConfigValue("ExportsMax_ENTERPRISE_PRODUCE", 2000);
                default:
                    return Utilities.GetIntConfigValue("ExportsMax_BASIC_PRODUCE", 0);
            }
        }

        protected int GetExportsMax_Lumber()
        {
            switch (_oUser.prwu_AccessLevel)
            {
                case PRWebUser.SECURITY_LEVEL_STANDARD:
                    //STANDARD - L200
                    return Utilities.GetIntConfigValue("ExportsMax_STANDARD_LUMBER", 500);
                case PRWebUser.SECURITY_LEVEL_ADVANCED:
                    //ADVANCED - L300
                    return Utilities.GetIntConfigValue("ExportsMax_ADVANCED_LUMBER", 2000);
                default:
                    //BASIC
                    return Utilities.GetIntConfigValue("ExportsMax_BASIC_LUMBER", 0);

            }
        }

        /// <summary>
        /// Defect 7396 - send email to all Sales People
        /// PTS orders only, not Lumber
        /// </summary>
        /// <param name="subject"></param>
        /// <param name="content"></param>
        /// <param name="source"></param>
        /// <param name="oTran"></param>
        protected void SendEmailToSales(string subject, string content, string source, IPRWebUser oUser, IDbTransaction oTran)
        {
            if (_oUser == null || oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                return;
            }

            string szSalesEmailRecipientIDs = Utilities.GetConfigValue("SalesEmailRecipientIDs", "24,35,1012"); //(TJR,JBL,LEL) --Jeff Lair, Leticia Lima, Tim Reardon
            var salesPersonIDs = szSalesEmailRecipientIDs.Split(new[] { ',' }, System.StringSplitOptions.RemoveEmptyEntries);

            foreach (string salesPerson in salesPersonIDs)
            {
                GetObjectMgr().SendEmail_Text(GetObjectMgr().GetPRCoUserEmail(Convert.ToInt32(salesPerson), oTran),
                    subject,
                    content,
                    source,
                    oTran);
            }
        }

        protected void ExportsManagement(HiddenField hidExportsPeriod, HiddenField hidExportsMax, HiddenField hidExportsUsed)
        {
            //Exports management
            hidExportsPeriod.Value = "D";

            if (_oUser.prwu_BBID == 100002 || _oUser.prwu_BBID == 204482)
            {
                hidExportsMax.Value = "9999999";
                hidExportsUsed.Value = "0";
            }
            else
            {
                switch (_oUser.prwu_IndustryType)
                {
                    case GeneralDataMgr.INDUSTRY_TYPE_LUMBER:
                        hidExportsMax.Value = GetExportsMax_Lumber().ToString();

                        switch (_oUser.prwu_AccessLevel)
                        {
                            case PRWebUser.SECURITY_LEVEL_BASIC_ACCESS:
                                //BASIC - L100
                                hidExportsUsed.Value = _oUser.GetDataExportCount_Company_Lumber_Current_Day().ToString();
                                hidExportsPeriod.Value = "D";
                                break;
                            case PRWebUser.SECURITY_LEVEL_STANDARD:
                                //STANDARD - L200
                                hidExportsUsed.Value = _oUser.GetDataExportCount_Company_Lumber_Current_Month().ToString();
                                hidExportsPeriod.Value = "M";
                                break;
                            case PRWebUser.SECURITY_LEVEL_ADVANCED:
                                //ADVANCED - L300
                                hidExportsUsed.Value = _oUser.GetDataExportCount_Company_Lumber_Current_Day().ToString();
                                hidExportsPeriod.Value = "D";
                                break;
                        }
                        break;
                    default:
                        hidExportsUsed.Value = _oUser.GetDataExportCount().ToString();
                        hidExportsPeriod.Value = "D";
                        hidExportsMax.Value = GetExportsMax_Produce().ToString();
                        break;
                }
            }
        }

        protected const string SQL_INSERT_LIBRARY = "INSERT INTO Library " +
            "(libr_CreatedBy, libr_CreatedDate, libr_UpdatedBy, libr_UpdatedDate, libr_TimeStamp, " +
            "libr_CompanyId, libr_PersonId, libr_UserId, libr_FilePath, libr_FileName, libr_Note, " +
            "libr_CommunicationId, libr_FileSize, libr_PRFileId, libr_LibraryId) " +
            "VALUES " +
            "({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14})";

        internal string simulateSageFileUpload(string sSSFileId, string szSourceFile, string szFileName, int iAssignedToId, string sTaskNotes, string sCommSubject, int iChannelIdOverride, string sSubCategory, IDbTransaction oTran)
        {
            // this is a 3 step process
            // 1) save the file
            string szFilePath = null;
            string szFullFileName = null;
            try
            {
                // store the file in the company's Library folder
                // path is Custom_SysParams.DocStore \ first char of company name \ company name \ document
                string sCompanyName = _oUser.prwu_CompanyName;
                string sDocStore = Configuration.CRMLibraryRoot;
                string sChar1 = sCompanyName[0].ToString();

                // ensure the full file upload path exists
                szFilePath = sChar1 + "\\" + sCompanyName;
                // If this directory does not already exist, create it
                if (!System.IO.Directory.Exists(sDocStore + "\\" + szFilePath))
                    System.IO.Directory.CreateDirectory(sDocStore + "\\" + szFilePath);

                // Create the new file 
                int iNameIndex = szFileName.LastIndexOf("\\");
                if (iNameIndex > -1)
                {
                    szFileName = szFileName.Substring(iNameIndex + 1);
                }
                szFullFileName = sDocStore + "\\" + szFilePath + "\\" + szFileName;

                // Check if a file with this name already exists
                if (System.IO.File.Exists(szFullFileName))
                {
                    // Append random number to end of string to make this a file name unique
                    int iExtIndex = szFileName.LastIndexOf(".");
                    Random Rnd = new Random();
                    int iNum = Rnd.Next(9999);
                    szFileName = szFileName.Substring(0, iExtIndex) +
                                    "_" + iNum.ToString() +
                                    szFileName.Substring(iExtIndex);
                    szFullFileName = sDocStore + "\\" + szFilePath + "\\" + szFileName;
                }

                // Save the uploaded file to disk
                File.Move(szSourceFile, szFullFileName);
            }
            catch (Exception ex)
            {
                throw new ApplicationUnexpectedException(String.Format(Resources.Global.ErrorFileUpload, ex.Message));
            }

            // 2) create a communication/comm_link record
            string sCommId = createSSFileCommunicationRecord(sSSFileId, sCommSubject, sTaskNotes, iAssignedToId, iChannelIdOverride, sSubCategory, oTran);

            // 3) Create a Library record
            ArrayList oParameters = new ArrayList();

            oParameters.Add(new ObjectParameter("libr_CreatedBy", _oUser.prwu_WebUserID));
            oParameters.Add(new ObjectParameter("libr_CreatedDate", DateTime.Now));
            oParameters.Add(new ObjectParameter("libr_UpdatedBy", _oUser.prwu_WebUserID));
            oParameters.Add(new ObjectParameter("libr_UpdatedDate", DateTime.Now));
            oParameters.Add(new ObjectParameter("libr_TimeStamp", DateTime.Now));

            oParameters.Add(new ObjectParameter("libr_CompanyId", _oUser.prwu_BBID));
            oParameters.Add(new ObjectParameter("libr_PersonId", _oUser.prwu_WebUserID));
            oParameters.Add(new ObjectParameter("libr_UserId", iAssignedToId));
            oParameters.Add(new ObjectParameter("libr_FilePath", szFilePath.Replace('\\', '/') + '/'));
            oParameters.Add(new ObjectParameter("libr_FileName", szFileName));
            oParameters.Add(new ObjectParameter("libr_Note", sTaskNotes));

            oParameters.Add(new ObjectParameter("libr_CommunicationId", sCommId));
            oParameters.Add(new ObjectParameter("libr_FileSize", new FileInfo(szFullFileName).Length));

            oParameters.Add(new ObjectParameter("libr_PRFileId", sSSFileId));
            oParameters.Add(new ObjectParameter("libr_LibraryId", GetObjectMgr().GetRecordID("Library", oTran)));

            string szSQL = GetObjectMgr().FormatSQL(SQL_INSERT_LIBRARY, oParameters);
            GetObjectMgr().ExecuteInsert("Library", szSQL, oParameters, oTran);

            return szFullFileName;
        }

        internal string createSSFileCommunicationRecord(string sSSFileId, string subject, string sTaskNotes, int iAssignedToId, int iChannelIdOverride, string sSubCategory, IDbTransaction oTran)
        {
            // this is a simple call to usp_CreateTask to create a communication and comm_link record

            string szReturn = "";
            SqlCommand cmdCreate = null;
            SqlParameter parm = null;

            // Create the command
            cmdCreate = new SqlCommand("usp_CreateTask", (SqlConnection)GetObjectMgr().DBConnection, (SqlTransaction)oTran);
            cmdCreate.CommandType = CommandType.StoredProcedure;

            // clear all stored procedure parameters
            cmdCreate.Parameters.Clear();

            // create the return parameter
            parm = cmdCreate.Parameters.Add("ReturnValue", SqlDbType.Int);
            parm.Direction = ParameterDirection.ReturnValue;

            // load the parameters for the stored procedure
            cmdCreate.Parameters.AddWithValue("@StartDateTime", DateTime.Now);
            cmdCreate.Parameters.AddWithValue("@CreatorUserId", _oUser.prwu_WebUserID);
            cmdCreate.Parameters.AddWithValue("@AssignedToUserId", iAssignedToId);
            cmdCreate.Parameters.AddWithValue("@TaskNotes", sTaskNotes);
            cmdCreate.Parameters.AddWithValue("@RelatedCompanyId", _oUser.prwu_BBID);
            cmdCreate.Parameters.AddWithValue("@RelatedPersonId", _oUser.peli_PersonID);
            cmdCreate.Parameters.AddWithValue("@Type", "BBOS Upload");
            cmdCreate.Parameters.AddWithValue("@Action", "LetterIn");
            cmdCreate.Parameters.AddWithValue("@PRCategory", "SS");

            if(!string.IsNullOrEmpty(sSubCategory))
                cmdCreate.Parameters.AddWithValue("@PRSubcategory", sSubCategory);

            cmdCreate.Parameters.AddWithValue("@PRFileId", int.Parse(sSSFileId));
            cmdCreate.Parameters.AddWithValue("@HasAttachments", "Y");
            cmdCreate.Parameters.AddWithValue("@Subject", subject);

            if(iChannelIdOverride > 0)
                cmdCreate.Parameters.AddWithValue("ChannelIdOverride", iChannelIdOverride);

            cmdCreate.ExecuteNonQuery();

            szReturn = Convert.ToString(cmdCreate.Parameters["ReturnValue"].Value);
            return szReturn;
        }

        protected string createEmailCommunicationRecord(string sSSFileId, string subject, string sTaskNotes, int iAssignedToId, string sPRCategory, string sPRSubcategory, IDbTransaction oTran)
        {
            // this is a simple call to usp_CreateTask to create a communication and comm_link record
            string szReturn = "";
            SqlCommand cmdCreate = null;
            SqlParameter parm = null;

            // Create the command
            cmdCreate = new SqlCommand("usp_CreateTask", (SqlConnection)GetObjectMgr().DBConnection, (SqlTransaction)oTran);
            cmdCreate.CommandType = CommandType.StoredProcedure;

            // clear all stored procedure parameters
            cmdCreate.Parameters.Clear();

            // create the return parameter
            parm = cmdCreate.Parameters.Add("ReturnValue", SqlDbType.Int);
            parm.Direction = ParameterDirection.ReturnValue;

            // load the parameters for the stored procedure
            cmdCreate.Parameters.AddWithValue("@StartDateTime", DateTime.Now);
            cmdCreate.Parameters.AddWithValue("@CreatorUserId", _oUser.prwu_WebUserID);
            cmdCreate.Parameters.AddWithValue("@AssignedToUserId", iAssignedToId);
            cmdCreate.Parameters.AddWithValue("@TaskNotes", sTaskNotes);
            cmdCreate.Parameters.AddWithValue("@RelatedCompanyId", _oUser.prwu_BBID);

            cmdCreate.Parameters.AddWithValue("@Action", "EmailOut");
            cmdCreate.Parameters.AddWithValue("@PRCategory", sPRCategory);
            cmdCreate.Parameters.AddWithValue("@PRSubcategory", sPRSubcategory);
            cmdCreate.Parameters.AddWithValue("@PRFileId", int.Parse(sSSFileId));
            cmdCreate.Parameters.AddWithValue("@Subject", subject);
            cmdCreate.Parameters.AddWithValue("@Status", "Complete");

            cmdCreate.ExecuteNonQuery();

            szReturn = Convert.ToString(cmdCreate.Parameters["ReturnValue"].Value);
            return szReturn;
        }

        /// <summary>
        /// Check once per day via Session variables whether Invoices are overdue (Defect 7559 for pay online)
        /// </summary>
        /// <returns></returns>
        protected bool DisplayInvoiceMessage()
        {
            if (!string.IsNullOrEmpty(_oUser.GetOpenInvoiceMessageCode()))
            {
                Session["DisplayInvoiceMessage"] = true;
                return true;
            }

            Session["DisplayInvoiceMessage"] = false;
            return false;
        }
    }
}