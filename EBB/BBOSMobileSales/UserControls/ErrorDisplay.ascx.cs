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

 ClassName: ErrorDisplay.ascx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Web;
using System.Web.UI;
using System.Text;
using TSI.Arch;
using TSI.Security;
using TSI.Utils;
using TSI.DataAccess;

namespace PRCo.BBOS.UI.Web
{
    public partial class ErrorDisplay : System.Web.UI.UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        private static string aSystemErrorHasOccurred = "A system error has occurred. {0} support has been notified.  If the problem persists, please contact <a class=\"explicitlink\" href=\"mailto:{1}\">Error support.</a>";

        public void DisplayException(Exception oCurrentException)
        {
            StringBuilder sbMsg = new StringBuilder("<p>");
            string szTitle = "A System Error Has Occurred";
            bool bLogError = true;

            if (oCurrentException == null)
            {
                sbMsg.Append(string.Format(aSystemErrorHasOccurred, PageBase.GetApplicationNameAbbr(), Utilities.GetConfigValue("EMailSupportAddress")) + Environment.NewLine);
                bLogError = false;
            }
            else if (oCurrentException is AuthorizationException)
            {
                szTitle = "Unauthorized Access";
                sbMsg.Append(oCurrentException.Message);
                bLogError = false;
            }
            else if (oCurrentException is ApplicationExpectedException)
            {
                szTitle = "An Error Has Occurred";
                sbMsg.Append(oCurrentException.Message);
                bLogError = false;
            }
            else if (oCurrentException is HttpRequestValidationException)
            {
                szTitle = "Invalid Data Entry";
                sbMsg.Append("The system detected invalid data entered into a form field.  HTML and scripting tags are not allowed.");
                bLogError = false;
            }
            else if ((oCurrentException is System.ArgumentException) &&
                     (oCurrentException.Message.StartsWith("Invalid postback or callback argument.")) &&
                     (!Utilities.GetBoolConfigValue("LogEventValidationError", false)))
            {
                sbMsg.Append(string.Format(aSystemErrorHasOccurred, PageBase.GetApplicationNameAbbr(), Utilities.GetConfigValue("EMailSupportAddress")) + Environment.NewLine);
                bLogError = false;

            }
            else if ((oCurrentException is HttpException) &&
                    ((oCurrentException.Message == "The client disconnected.") ||
                     (oCurrentException.Message.StartsWith("The remote host closed the connection."))))
            {
                // Users don't see these errors, so let's not bother logging them.
                sbMsg.Append(string.Format(aSystemErrorHasOccurred, PageBase.GetApplicationNameAbbr(), Utilities.GetConfigValue("EMailSupportAddress")) + Environment.NewLine);
                bLogError = false;

            }
            else if ((IsViewStateException(oCurrentException)) &&
                     (!Utilities.GetBoolConfigValue("LogViewStateError", false)))
            {
                sbMsg.Append(string.Format(aSystemErrorHasOccurred, PageBase.GetApplicationNameAbbr(), Utilities.GetConfigValue("EMailSupportAddress")) + Environment.NewLine);
                bLogError = false;

            }
            else if (!Utilities.GetBoolConfigValue("OnErrorDisplayAllInfo", false))
            {
                //displayButtons = true;
                sbMsg.Append("A system error has occurred and " + PageBase.GetApplicationNameAbbr() + " support has been notified.");
            }
            else
            {
                sbMsg.Append(oCurrentException.Message + Environment.NewLine);

                if (oCurrentException is DBException)
                {
                    DBException oDBException = (DBException)oCurrentException;

                    sbMsg.Append("<br/>" + Environment.NewLine);
                    sbMsg.Append(oDBException.InnerException.Message + Environment.NewLine);
                    sbMsg.Append("<p><b>SQL</b>:<br/>" + Environment.NewLine);
                    sbMsg.Append(oDBException.SQLStatement + Environment.NewLine);

                    if ((oDBException.SQLParameters != null) &&
                        (oDBException.SQLParameters.Count > 0))
                    {
                        sbMsg.Append("<p><b>SQL Parameters</b>:<br/>" + Environment.NewLine);

                        foreach (DBParameter oParameter in oDBException.SQLParameters)
                        {
                            sbMsg.Append(oParameter.GetSQLDefinition());
                            sbMsg.Append("<br/>" + Environment.NewLine);
                        }
                    }
                }
                else if (oCurrentException.InnerException != null)
                {
                    sbMsg.Append("<br>" + Environment.NewLine);
                    sbMsg.Append(oCurrentException.InnerException.Message + Environment.NewLine);
                }

                sbMsg.Append("<p>QueryString Parms<br/>" + Environment.NewLine);
                sbMsg.Append("==================<br/>" + Environment.NewLine);
                sbMsg.Append(FormatQueryStringParms(false));
                sbMsg.Append("</p>");
                sbMsg.Append(Environment.NewLine + Environment.NewLine);

                sbMsg.Append("<p>Cookie Data<br/>" + Environment.NewLine);
                sbMsg.Append("==================<br/>" + Environment.NewLine);
                sbMsg.Append(FormatCookieData(true, "<br/>"));
                sbMsg.Append("</p>");
                sbMsg.Append(Environment.NewLine + Environment.NewLine);

                sbMsg.Append("<p>Session Data<br>" + Environment.NewLine);
                sbMsg.Append("==================<br/>" + Environment.NewLine);
                sbMsg.Append(FormatSessionData(true, "<br/>"));
                sbMsg.Append("</p>");
                sbMsg.Append(Environment.NewLine + Environment.NewLine);

                sbMsg.Append("<p>Stack Trace<br/>" + Environment.NewLine);
                sbMsg.Append("===========<br/>" + Environment.NewLine);
                sbMsg.Append("<div style=\"width:975px;overflow:scroll;\">" + Environment.NewLine);
                sbMsg.Append("<pre style=\"font-size:.833em;\">" + Environment.NewLine);
                sbMsg.Append(oCurrentException.StackTrace);
                sbMsg.Append("</pre>" + Environment.NewLine);
                sbMsg.Append("</div>" + Environment.NewLine);
                sbMsg.Append("</p>" + Environment.NewLine);
            }

            if (bLogError)
            {
                StringBuilder sbAdditionalInformation = new StringBuilder();

                sbAdditionalInformation.Append(Environment.NewLine);

                IUser user = (IUser)HttpContext.Current.Session["oUser"];
                if (user != null)
                {
                    sbAdditionalInformation.Append("User: " + user.Name + " (" + user.UserID + ")" + Environment.NewLine);
                }
                else
                {
                    sbAdditionalInformation.Append("User: Not Logged In" + Environment.NewLine);
                }

                string szReferer = HttpContext.Current.Request.ServerVariables["HTTP_REFERER"];
                if (string.IsNullOrEmpty(szReferer))
                {
                    sbAdditionalInformation.Append("Referrer: Not Found" + Environment.NewLine);
                }
                else
                {
                    sbAdditionalInformation.Append("Referrer: " + szReferer + Environment.NewLine);
                }

                sbAdditionalInformation.Append(Environment.NewLine);
                sbAdditionalInformation.Append("Browser: " + HttpContext.Current.Request.Browser.Browser + " " + HttpContext.Current.Request.Browser.Version + " on " + HttpContext.Current.Request.Browser.Platform + Environment.NewLine);
                sbAdditionalInformation.Append("User Agent: " + HttpContext.Current.Request.ServerVariables["HTTP_USER_AGENT"] + Environment.NewLine);

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

                ILogger logger = (ILogger)HttpContext.Current.Session["Logger"];
                if (logger != null)
                {
                    logger.LogError(null, oCurrentException, sbAdditionalInformation.ToString());
                }
            }

            lblHeader.Text = szTitle;
            lblMsg.Text = sbMsg.ToString();
        }

        /// <summary>
        /// Formats the query string parameters into a name
        /// value pair for display.
        /// </summary>
        /// <returns>Formatted Parameters</returns>
        protected string FormatQueryStringParms(bool bAddLineBreak)
        {
            StringBuilder sbParms = new StringBuilder();
            foreach (string szKey in HttpContext.Current.Request.QueryString.Keys)
            {
                if (szKey == null)
                    continue;

                if (sbParms.Length > 0)
                {
                    sbParms.Append("&");
                }

                sbParms.Append(FormatNameValueData(szKey, HttpContext.Current.Request.Params[szKey].ToString(), bAddLineBreak, Environment.NewLine));
            }

            return sbParms.ToString();
        }


        /// <summary>
        /// Formats the query string parameters into a name
        /// value pair for display.
        /// </summary>
        /// <returns>Formatted Parameters</returns>
        protected string FormatSessionData(bool bAddLineBreak, string szLineBreak)
        {
            StringBuilder sbParms = new StringBuilder();
            foreach (string szKey in HttpContext.Current.Session.Keys)
            {
                string value = null;
                if (HttpContext.Current.Session[szKey] != null)
                {
                    value = HttpContext.Current.Session[szKey].ToString();
                }

                sbParms.Append(FormatNameValueData(szKey, value, bAddLineBreak, szLineBreak));
            }

            return sbParms.ToString();
        }

        /// <summary>
        /// Formats the cookie data into a name
        /// value pair for display.
        /// </summary>
        /// <returns>Formatted Parameters</returns>
        protected string FormatCookieData(bool bAddLineBreak, string szLineBreak)
        {
            if (HttpContext.Current.Request.Cookies[PageBase.COOKIE_ID] == null)
            {
                return string.Empty;
            }

            StringBuilder sbParms = new StringBuilder();
            foreach (string szKey in HttpContext.Current.Request.Cookies[PageBase.COOKIE_ID].Values.Keys)
            {
                sbParms.Append(FormatNameValueData(szKey, HttpContext.Current.Request.Cookies[PageBase.COOKIE_ID].Values[szKey], bAddLineBreak, szLineBreak));
            }

            return sbParms.ToString();
        }

        protected string FormatNameValueData(string name, string value, bool bAddLineBreak, string szLineBreak)
        {
            StringBuilder sbParms = new StringBuilder();

            sbParms.Append(name);
            sbParms.Append("=");

            if (name.ToLower().Contains("password"))
            {
                sbParms.Append("*****");
            }
            else
            {
                if (value == null)
                {
                    sbParms.Append("NULL");
                }
                else
                {
                    sbParms.Append(value);
                }
            }

            if (bAddLineBreak)
            {
                sbParms.Append(szLineBreak);
            }

            return sbParms.ToString();
        }

        protected bool IsViewStateException(Exception oCurrentException)
        {
            Exception oException = oCurrentException;

            while (oException != null)
            {
                if (oException is ViewStateException)
                {
                    return true;
                }
                oException = oException.InnerException;
            }

            return false;
        }
    }
}