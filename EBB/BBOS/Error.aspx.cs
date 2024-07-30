/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2007-2017

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: Error.aspx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Web;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Handles the application level errors.  The OnError handler executes a
    /// server.transfer to this page in order to log and handle the unexpected, 
    /// i.e. unhandled exceptions, correctly.
    /// </summary>
    public partial class Error : PageBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            _isErrorPage = true;

            Exception oCurrentException = null;
            try
            {
                oCurrentException = Server.GetLastError();
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
                if (oCurrentException != null)
                {
                    LogError(oCurrentException);
                }

                LogError(eX);
                SetPageTitle("System Error");
            }
        }

        /// <summary>
        /// Display the error message
        /// </summary>
        protected void DisplayErrorMsg()
        {
            Exception oCurrentException = Server.GetLastError();
            if (oCurrentException == null)
            {
                if (GetRequestParameter("ex", false) != null)
                {
                    if (GetRequestParameter("ex") == "HRVE")
                    {
                        oCurrentException = new HttpRequestValidationException();
                    }
                }
            }

            error.DisplayException(oCurrentException);
        }

        protected override bool IsAuthorizedForData()
        {
            return true;
        }

        protected override bool IsAuthorizedForPage()
        {
            return true;
        }

        protected override bool PageRequiresSecureConnection()
        {
            return false;
        }

        protected override bool SessionTimeoutForPageEnabled()
        {
            return false;
        }
    }
}
