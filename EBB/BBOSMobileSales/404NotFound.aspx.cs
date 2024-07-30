/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2022-2022

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: 404NotFound.aspx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using TSI.Arch;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Custom error page to handle the 404 Not Found conditions.
    /// </summary>
    public partial class _04NotFound : PageBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            string szQuery = Request.ServerVariables["QUERY_STRING"];
            string szReferer = Request.ServerVariables["HTTP_REFERER"];
            string szPageNotFound = GetRequestParameter("aspxerrorpath");

            string szLogMsg = "Page not found error: " + szPageNotFound + Environment.NewLine;

            if (string.IsNullOrEmpty(szReferer))
            {
                szLogMsg += "No Referrer Found" + Environment.NewLine;
            }
            else
            {
                szLogMsg += "Referrer: " + szReferer + Environment.NewLine;
            }

            if (_oUser != null)
            {
                szLogMsg += "User: " + _oUser.Name + " (" + _oUser.UserID + ")" + Environment.NewLine;
            }
            else
            {
                szLogMsg += "User: Not Logged In" + Environment.NewLine;
            }

            if (szPageNotFound.Contains(".axd"))
            {
                if (Utilities.GetBoolConfigValue("LogPageNotFound_axd", false))
                {
                    LogError(new ApplicationUnexpectedException(szLogMsg));
                }

            }
            else
            {
                if (Utilities.GetBoolConfigValue("LogPageNotFound", false))
                {
                    LogError(new ApplicationUnexpectedException(szLogMsg));
                }
            }

            // Now display something warm and friendly.
            litNotFound.Text = GetFormattedErrorDisplay(Resources.Global.PageNotFoundTitle, string.Format(Resources.Global.PageNotFoundMsg, GetApplicationNameAbbr()), false);
        }

        protected override bool IsAuthorizedForData()
        {
            return true;
        }

        protected override bool IsAuthorizedForPage()
        {
            return true;
        }
    }
}
