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

 ClassName: Error
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Text;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using TSI.Utils;
using TSI.DataAccess;

namespace PRCo.BBOS.UI.Web.UserManagement {

    /// <summary>
    /// Handles the application level errors.  The OnError handler executes a
    /// server.transfer to this page in order to log and handle the unexpected, 
    /// i.e. unhandled exceptions, correctly.
    /// </summary>
    public partial class Error : PageBase {
        override protected void Page_Load(object sender, EventArgs e) {
            base.Page_Load(sender, e);
            
            if (!IsPostBack) {
                DisplayErrorMsg();
            }
        }

        /// <summary>
        /// Display the error message
        /// </summary>
        protected void DisplayErrorMsg() {

            Exception oCurrentException = Server.GetLastError();

            StringBuilder sbMsg = new StringBuilder();
            string szTitle = "An Unexpected Error Has Occurred";
            bool bLogError = true;
            
            if (oCurrentException == null) {
                sbMsg.Append(string.Format("UnexpectedErrorMsg", Utilities.GetConfigValue("EMailSupportAddress")) + Environment.NewLine);
                bLogError = false;
            } else if (!Utilities.GetBoolConfigValue("OnErrorDisplayAllInfo", false)) {
                sbMsg.Append(string.Format("A system error has occurred.  BBOS support has been notified.  If the problem persists, please contact <a href=\"mailto:{0}\">BBOS support.</a>", Utilities.GetConfigValue("EMailSupportAddress")) + Environment.NewLine);
            } else {

                sbMsg.Append(oCurrentException.Message + Environment.NewLine);

                if (oCurrentException is DBException) {
                    DBException oDBException = (DBException)oCurrentException;
                
                    sbMsg.Append("<br>" + Environment.NewLine);
                    sbMsg.Append(oDBException.InnerException.Message + Environment.NewLine);
                    sbMsg.Append("<p><b>SQL</b>:<br>" + Environment.NewLine);
                    sbMsg.Append(oDBException.SQLStatement + Environment.NewLine);
                    
                    if ((oDBException.SQLParameters != null) &&
                        (oDBException.SQLParameters.Count > 0)) {
                        sbMsg.Append("<p><b>SQL Parameters</b>:<br>" + Environment.NewLine);
                        
                        foreach(DBParameter oParameter in oDBException.SQLParameters) {
                            sbMsg.Append(oParameter.Name);
                            sbMsg.Append("=");
                            if (oParameter.Value == null) {
                                sbMsg.Append("null");
                            } else{
                                sbMsg.Append(oParameter.Value.ToString());
                            }
                            sbMsg.Append("<br>" + Environment.NewLine);
                        }
                    }
                    
                } else if (oCurrentException.InnerException != null) {
                    sbMsg.Append("<br>" + Environment.NewLine);
                    sbMsg.Append(oCurrentException.InnerException.Message + Environment.NewLine);
                }

                sbMsg.Append("<p>QueryString Parms<br>" + Environment.NewLine);
                sbMsg.Append("==================<br>" + Environment.NewLine);
                sbMsg.Append(FormatQueryStringParms(false));
                sbMsg.Append(Environment.NewLine + Environment.NewLine);

                sbMsg.Append("<p>Cookie Data<br>" + Environment.NewLine);
                sbMsg.Append("==================<br>" + Environment.NewLine);
                sbMsg.Append(FormatCookieData(true, "<br>"));
                sbMsg.Append(Environment.NewLine + Environment.NewLine);


                sbMsg.Append("<p>Session Data<br>" + Environment.NewLine);
                sbMsg.Append("==================<br>" + Environment.NewLine);
                sbMsg.Append(FormatSessionData(true, "<br>"));
                sbMsg.Append(Environment.NewLine + Environment.NewLine);

                sbMsg.Append("<p>Stack Trace<br>" + Environment.NewLine);
                sbMsg.Append("===========<br>" + Environment.NewLine);
                sbMsg.Append("<PRE>" + Environment.NewLine);
                sbMsg.Append(oCurrentException.StackTrace);
                sbMsg.Append("</PRE>" + Environment.NewLine);

            }
            
            //Server.ClearError();

            if (bLogError) {
                StringBuilder sbAdditionalInformation = new StringBuilder();

                sbAdditionalInformation.Append(Environment.NewLine);
                if (_oUser != null) {
                    sbAdditionalInformation.Append("User: " + _oUser.Name + " (" + _oUser.UserID + ")" + Environment.NewLine);
                    sbAdditionalInformation.Append("HQ ID: " + _oUser.prwu_HQID.ToString() + Environment.NewLine);
                    sbAdditionalInformation.Append("Access Level: " + _oUser.prwu_AccessLevel.ToString()  + Environment.NewLine);
                } else {
                    sbAdditionalInformation.Append("User: Not Logged In" + Environment.NewLine);
                }

                string szReferer = Request.ServerVariables["HTTP_REFERER"];
                if (string.IsNullOrEmpty(szReferer)) {
                    sbAdditionalInformation.Append("Referrer: Not Found" + Environment.NewLine);
                } else {
                    sbAdditionalInformation.Append("Referrer: " + szReferer + Environment.NewLine);
                }

                sbAdditionalInformation.Append(Environment.NewLine);
                sbAdditionalInformation.Append("Browser: " + Request.Browser.Browser + " " + Request.Browser.Version + " on " + Request.Browser.Platform + Environment.NewLine);
                sbAdditionalInformation.Append("User Agent: " + Request.ServerVariables["HTTP_USER_AGENT"] + Environment.NewLine);


                sbAdditionalInformation.Append(Environment.NewLine);
                sbAdditionalInformation.Append("QueryString Parms" + Environment.NewLine);
                sbAdditionalInformation.Append("=================" + Environment.NewLine);
                sbAdditionalInformation.Append(FormatQueryStringParms(true));

                sbAdditionalInformation.Append(Environment.NewLine);
                sbAdditionalInformation.Append("Cookie Data" + Environment.NewLine);
                sbAdditionalInformation.Append("============" + Environment.NewLine);
                sbAdditionalInformation.Append(FormatCookieData(true, Environment.NewLine));

                sbAdditionalInformation.Append(Environment.NewLine);
                sbAdditionalInformation.Append("Session Data" + Environment.NewLine);
                sbAdditionalInformation.Append("============" + Environment.NewLine);
                sbAdditionalInformation.Append(FormatSessionData(true, Environment.NewLine));


                LogError(oCurrentException, sbAdditionalInformation.ToString());
            }

            SetPageTitle(string.Format("{0} Error", "BBOS User Management"), szTitle);
            litErrorMsg.Text = GetFormattedErrorDisplay(szTitle, sbMsg.ToString(), false);
        }

        /// <summary>
        /// Formats the query string parameters into a name
        /// value pair for display.
        /// </summary>
        /// <returns>Formatted Parameters</returns>
        protected string FormatSessionData(bool bAddLineBreak, string szLineBreak) {

            StringBuilder sbParms = new StringBuilder();
            foreach (string szKey in Session.Keys) {
                sbParms.Append(szKey);
                sbParms.Append("=");

                if (szKey.ToLower().Contains("password")) {
                    sbParms.Append("*****");
                } else {
                    if (Session[szKey] == null) {
                        sbParms.Append("NULL");
                    } else {
                        sbParms.Append(Session[szKey].ToString());
                    }
                }

                if (bAddLineBreak) {
                    sbParms.Append(szLineBreak);
                }
            }

            return sbParms.ToString();
        }


        /// <summary>
        /// Formats the cookie data into a name
        /// value pair for display.
        /// </summary>
        /// <returns>Formatted Parameters</returns>
        protected string FormatCookieData(bool bAddLineBreak, string szLineBreak) {

            StringBuilder sbParms = new StringBuilder();
            
            
            foreach (string szKey in Request.Cookies[COOKIE_ID].Values.Keys) {
                sbParms.Append(szKey);
                sbParms.Append("=");

                if (szKey.ToLower().Contains("password")) {
                    sbParms.Append("*****");
                } else {
                    if (Request.Cookies[COOKIE_ID].Values[szKey] == null) {
                        sbParms.Append("NULL");
                    } else {
                        sbParms.Append(Request.Cookies[COOKIE_ID].Values[szKey]);
                    }
                }

                if (bAddLineBreak) {
                    sbParms.Append(szLineBreak);
                }
            }

            return sbParms.ToString();
        }

    }
}
