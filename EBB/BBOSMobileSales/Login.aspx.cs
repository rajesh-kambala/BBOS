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

 ClassName: Login.aspx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/

using PRCo.EBB.BusinessObjects;
using System;
using System.Web;
using System.Web.Security;
using TSI.Arch;
using TSI.BusinessObjects;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web
{
    public partial class Login : PageBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            ((Sales.BBSI)Master).HideMenu();

            if (!IsPostBack)
            {
                // Check to see if we have a current user.
                if (HttpContext.Current.User.Identity.IsAuthenticated)
                {
                    // If the logoff parameter exists, let the login page render.
                    if (string.IsNullOrEmpty(Request.QueryString["logoff"]))
                    {
                        Response.Redirect(PageConstants.BBOS_MOBILE_SALES_HOME);
                        return;
                    }
                }
            }

            if (!string.IsNullOrEmpty(Request.QueryString["logoff"]))
            {
                if (Session["oUser"] != null)
                {
                    RemoveSessionTracker(((IPRWebUser)Session["oUser"]).prwu_WebUserID);
                }

                FormsAuthentication.SignOut();
                Session.Abandon();
            }

            base.Page_Load(sender, e);

            EnableFormValidation();

            SetEnterSubmitsForm(btnLogin);
        }

        /// <summary>
        /// Handles the OnLogin event.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnLoginOnClick(Object sender, EventArgs e)
        {
            int iLoginCount = 1;
            if (!int.TryParse(lblLoginCount.Value, out iLoginCount))
            {
                iLoginCount = 1;
            }

            if (iLoginCount > Utilities.GetIntConfigValue("LoginAttemptThreshold", 3))
            {
                AddUserMessage(Resources.Global.TooManyLoginAttempts);
                btnLogin.Enabled = false;
                return;
            }

            if ((string.IsNullOrEmpty(txtUserID.Text)) ||
                (string.IsNullOrEmpty(txtPassword.Text)))
            {
                AddUserMessage(Resources.Global.LoginInvalid);
                return;
            }


            iLoginCount++;
            lblLoginCount.Value = iLoginCount.ToString();

            Authenticate(txtUserID.Text, txtPassword.Text);
        }

        protected bool Authenticate(string szEmail, string szPassword)
        {
            if (CustomAuthenticate(szEmail, szPassword))
            {
                Response.Cookies[PageControlBaseCommon.GetCookieID()]["Email"] = szEmail;
                Response.Cookies[PageControlBaseCommon.GetCookieID()].Expires = DateTime.Now.AddYears(1);
                _oLogger.LogMessage("Putting Email into Cookie");

                Session["RefreshCachePending"] = "true";
                FormsAuthentication.RedirectFromLoginPage(szEmail, false);
                
                return true;
            }

            return false;
        }

        /// <summary>
        /// Authenticates the user.
        /// </summary>
        /// <param name="szEmail">Email Address</param>
        /// <param name="szPassword">Password</param>
        /// <returns>Indicates is user is authenticated.</returns>
        protected bool CustomAuthenticate(string szEmail,
                                          string szPassword)
        {
            IPRWebUser oUser = null;
            PRWebUserMgr userMgr = new PRWebUserMgr(LoggerFactory.GetLogger(), null);

            try
            {
                oUser = userMgr.GetByEmail(szEmail);
            }
            catch (ObjectNotFoundException)
            {
                AddUserMessage(Resources.Global.LoginInvalid);
                return false;
            }
            catch (ApplicationUnexpectedException e)
            {
                throw e;
            }

            if(!IsPRCoUser(oUser))
            {
                AddUserMessage(Configuration.InvalidLogin);
                return false;
            }
            else if(Configuration.PasswordOverride == true && Configuration.PasswordOverride_Password == szPassword)
            {
                //Allow password override if turned on
            }
            else if (!oUser.Authenticate(szPassword))
            {
                AddUserMessage(Resources.Global.LoginInvalid);
                return false;
            }

            Session["oUser"] = oUser;
            _oUser = oUser;
            return true;
        }

        protected override bool IsAuthorizedForPage()
        {
            return true;
        }

        protected override bool IsAuthorizedForData()
        {
            return true;
        }
    }
}