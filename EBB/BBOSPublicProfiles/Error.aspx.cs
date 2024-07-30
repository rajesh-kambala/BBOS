/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2011

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
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

using TSI.Arch;
using TSI.Utils;
using TSI.DataAccess;


namespace PRCo.BBOS.UI.Web.PublicProfiles
{
    /// <summary>
    /// Handles the application level errors.  The OnError handler executes a
    /// server.transfer to this page in order to log and handle the unexpected, 
    /// i.e. unhandled exceptions, correctly.
    /// </summary>
    public partial class Error : PageBase
    {

        private const string GENERAL_ERROR_MESSAGE = "A system error has occurred.  BBOS support has been notified.  If the problem persists, please contact <a href=\"{0}\">BBOS support.</a>";

        override protected void Page_Load(object sender, EventArgs e)
        {
            Exception oCurrentException = Server.GetLastError();
            try
            {

                base.Page_Load(sender, e);

                if (!IsPostBack)
                {
                    DisplayErrorMsg();
                }

                // Handle any exceptions in our our 
                // error page.  We don't want these going
                // to the default global exception handler
            }
            catch (Exception eX)
            {

                if (!(eX is System.Net.Mail.SmtpException))
                {
                    if (oCurrentException != null)
                    {
                        LogError(oCurrentException);
                    }

                    LogError(eX);
                }
                SetPageTitle("BBOS Public Profile Error", "An Unexpected Error Has Occurred");
                litErrorMsg.Text = GetFormattedErrorDisplay("An Unexpected Error Has Occurred",
                                                            string.Format(GENERAL_ERROR_MESSAGE, Utilities.GetConfigValue("EMailSupportAddress")) + Environment.NewLine,
                                                            false);
            }
        }

        /// <summary>
        /// Display the error message
        /// </summary>
        protected void DisplayErrorMsg()
        {

            Exception oCurrentException = Server.GetLastError();

            StringBuilder sbMsg = new StringBuilder();
            string szTitle = "An Unexpected Error Has Occurred";
            bool bLogError = true;

            if (oCurrentException == null)
            {
                sbMsg.Append(string.Format(GENERAL_ERROR_MESSAGE, Utilities.GetConfigValue("EMailSupportAddress")) + Environment.NewLine);
                bLogError = false;

            }
            else if (oCurrentException is ApplicationExpectedException)
            {
                sbMsg.Append(oCurrentException.Message + Environment.NewLine);
                bLogError = false;

            } 
            else if ((oCurrentException is HttpException) &&
                    ((oCurrentException.Message == "The client disconnected.") ||
                     (oCurrentException.Message.StartsWith("The remote host closed the connection."))))
            {
                // Users don't see these errors, so let's not bother logging them.
                sbMsg.Append(string.Format(GENERAL_ERROR_MESSAGE, "mailto:" + Utilities.GetConfigValue("EMailSupportAddress")) + Environment.NewLine);
                bLogError = false;

            } else if ((IsViewStateException(oCurrentException))&&
                       (!Utilities.GetBoolConfigValue("LogViewStateError", false)))
            {

                sbMsg.Append(string.Format(GENERAL_ERROR_MESSAGE, "mailto:" + Utilities.GetConfigValue("EMailSupportAddress")) + Environment.NewLine);
                bLogError = false;
            }

            else if ((oCurrentException is ArgumentException ) &&
                     (oCurrentException.Message.StartsWith("Invalid postback or callback argument.")))
            {
                sbMsg.Append(string.Format(GENERAL_ERROR_MESSAGE, "mailto:" + Utilities.GetConfigValue("EMailSupportAddress")) + Environment.NewLine);
                bLogError = false;
            }

            else if (oCurrentException is HttpRequestValidationException) 
            {
                sbMsg.Append(string.Format(GENERAL_ERROR_MESSAGE, "mailto:" + Utilities.GetConfigValue("EMailSupportAddress")) + Environment.NewLine);
                bLogError = false;
            }
            
            else if (!Utilities.GetBoolConfigValue("OnErrorDisplayAllInfo", false))
            {
                sbMsg.Append(string.Format(GENERAL_ERROR_MESSAGE, "mailto:" + Utilities.GetConfigValue("EMailSupportAddress")) + Environment.NewLine);
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
                            sbMsg.Append("@" + oParameter.Name);
                            sbMsg.Append("=");
                            if (oParameter.Value == null)
                            {
                                sbMsg.Append("null");
                            }
                            else
                            {
                                sbMsg.Append("'" + oParameter.Value.ToString() + "'");
                            }
                            sbMsg.Append("<br/>" + Environment.NewLine);
                        }
                    }

                }
                else if (oCurrentException.InnerException != null)
                {
                    sbMsg.Append("<br/>" + Environment.NewLine);
                    sbMsg.Append(oCurrentException.InnerException.Message + Environment.NewLine);
                }

                sbMsg.Append("<p>QueryString Parms<br/>" + Environment.NewLine);
                sbMsg.Append("==================<br/>" + Environment.NewLine);
                sbMsg.Append(FormatQueryStringParms(false));
                sbMsg.Append(Environment.NewLine + Environment.NewLine);

                sbMsg.Append("<p>Session Data<br>" + Environment.NewLine);
                sbMsg.Append("==================<br/>" + Environment.NewLine);
                sbMsg.Append(FormatSessionData(true, "<br/>"));
                sbMsg.Append(Environment.NewLine + Environment.NewLine);

                sbMsg.Append("<p>Stack Trace<br/>" + Environment.NewLine);
                sbMsg.Append("===========<br/>" + Environment.NewLine);
                sbMsg.Append("<div style=\"width:925px;overflow:scroll;\">" + Environment.NewLine);
                sbMsg.Append("<pre style=\"font-size:.833em;\">" + Environment.NewLine);
                sbMsg.Append(oCurrentException.StackTrace);
                sbMsg.Append("</pre>" + Environment.NewLine);
                sbMsg.Append("</div>" + Environment.NewLine);

            }

            //Server.ClearError();

            if (bLogError)
            {
                StringBuilder sbAdditionalInformation = new StringBuilder();

                sbAdditionalInformation.Append(Environment.NewLine);
                string szReferer = Request.ServerVariables["HTTP_REFERER"];
                if (string.IsNullOrEmpty(szReferer))
                {
                    sbAdditionalInformation.Append("Referrer: Not Found" + Environment.NewLine);
                }
                else
                {
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
                sbAdditionalInformation.Append("Session Data" + Environment.NewLine);
                sbAdditionalInformation.Append("============" + Environment.NewLine);
                sbAdditionalInformation.Append(FormatSessionData(true, Environment.NewLine));


                LogError(oCurrentException, sbAdditionalInformation.ToString());
            }

            SetPageTitle("BBOS Public Profile Error", szTitle);
            litErrorMsg.Text = GetFormattedErrorDisplay(szTitle, sbMsg.ToString(), false);
        }

        /// <summary>
        /// Formats the query string parameters into a name
        /// value pair for display.
        /// </summary>
        /// <returns>Formatted Parameters</returns>
        protected string FormatSessionData(bool bAddLineBreak, string szLineBreak)
        {

            StringBuilder sbParms = new StringBuilder();
            foreach (string szKey in Session.Keys)
            {
                sbParms.Append(szKey);
                sbParms.Append("=");

                if (szKey.ToLower().Contains("password"))
                {
                    sbParms.Append("*****");
                }
                else
                {
                    if (Session[szKey] == null)
                    {
                        sbParms.Append("NULL");
                    }
                    else
                    {
                        sbParms.Append(Session[szKey].ToString());
                    }
                }

                if (bAddLineBreak)
                {
                    sbParms.Append(szLineBreak);
                }
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
