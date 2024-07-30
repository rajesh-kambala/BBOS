/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2007-2022

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

using System;
using System.Web;
using System.Web.UI;
using System.Web.Security;
using PRCo.EBB.BusinessObjects;
using TSI.Arch;
using TSI.BusinessObjects;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;
using System.Globalization;

namespace PRCo.BBOS.UI.Web
{
    public partial class Login : PageBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            #region "Limitado Coookie"
            //If ITA cookie found, redirect to Limitado.aspx
            HttpCookie oLimitadoCookie = Request.Cookies[Limitado.LIMITADO_COOKIE_NAME];
            if (oLimitadoCookie != null && oLimitadoCookie.Value=="true")
                Response.Redirect(PageConstants.LIMITADO);
            #endregion

            if (!IsPostBack)
            {
                // Check to see if we have a current user.
                if (HttpContext.Current.User.Identity.IsAuthenticated)
                {
                    // If the logoff parameter exists, let the login page render.
                    if (string.IsNullOrEmpty(Request.QueryString["logoff"])) {
                        Response.Redirect(PageConstants.BBOS_HOME);
                        return;
                    }
                }
            }

            if (!string.IsNullOrEmpty(Request.QueryString["logoff"]))
            {
                if (Session["oUser"] != null)
                    RemoveSessionTracker(((IPRWebUser)Session["oUser"]).prwu_WebUserID);
                
                FormsAuthentication.SignOut();
                Session.Abandon();
            }

            base.Page_Load(sender, e);

            EnableFormValidation();

            PageBase.SetEnterSubmitsForm(btnLogin);

            pnlMsg.Visible = false;
            string msgid = ((!string.IsNullOrEmpty(Request.QueryString["MsgID"]) ? Request.QueryString["MsgID"] : "0"));
            switch (msgid)
            {
                case "1":
                    pnlMsg.Visible = true;
                    litMsg.Text = Resources.Global.SessionTrackerError;
                    break;
                case "2":
                    //AddUserMessage(Utilities.GetConfigValue("EnterpriseSuspendedMsg"));
                    Response.Redirect(PageConstants.BBOS_HOME); //Defect 6877
                    break;
            }

            //Process RL (Reference Link) to see if this came from Content Management
            //If so the screen will look different
            //Sample link: <a href="https://azqa.apps.bluebookservices.com/bbos/CompanyDetailsSummary.aspx?RL=CM&amp;CompanyID=102030
            if (IsRLProduce() || IsRLLumber()) //Content Management (cm=produce, cml=lumber)
            {
                pnlVisitorsFindOutMore.Visible = false;
                const string RL_DIV_FORMAT = "col-lg-3 offset-lg-3 col-md-5 offset-md-2 col-sm-8 offset-sm-1 col-xs-12";

                divLogin.Attributes["class"] = RL_DIV_FORMAT;
                //divForgot.Attributes["class"] = RL_DIV_FORMAT;

                litTitle.Text = Resources.Global.BlueBookMemberLogin;

                if (IsRLProduce())
                {
                    pnlRLInfoProduce.Visible = true;
                    pnlRLSidebarProduce.Visible = true;
                }
                else if (IsRLLumber())
                {
                    pnlRLInfoLumber.Visible = true;
                    pnlRLSidebarLumber.Visible = true;
                }
            }

            btnEmailPassword.Attributes.Add("onClick", "EmailPasswordOnClick();");
            Page.SetFocus(txtUserID);

            if (!IsPostBack)
            {

                if (lblLoginCount.Value == string.Empty)
                {
                    lblLoginCount.Value = "1";
                }

                if ((!string.IsNullOrEmpty(Request["txtEmail"])) &&
                    (!string.IsNullOrEmpty(Request["EmailPassword"])))
                {
                    txtUserID.Text = Request["txtEmail"];
                    btnEmailPasswordOnClick(null, null);
                }
                else
                {

                    if ((Request.Cookies[GetCookieID()] != null) &&
                        (Request.Cookies[GetCookieID()]["Email"] != null))
                    {
                        txtUserID.Text = Request.Cookies[PageControlBaseCommon.GetCookieID()]["Email"];
                        Page.SetFocus(txtPassword);
                    }


                    // These values are set on the marketing pages 
                    // when the user logs in from there.
                    if (!string.IsNullOrEmpty(Request["k"]))
                    {
                        txtUserID.Text = Request["u"];

                        // If we have a bad password, then just take the user to
                        // the login page.
                        try
                        {
                            byte[] baKey = System.Convert.FromBase64String(Request["k"]);
                            txtPassword.Text = System.Text.ASCIIEncoding.ASCII.GetString(baKey);
                        } catch (System.FormatException) {
                            Response.Redirect(PageConstants.LOGIN);
                            return;
                        }

                        if (Request["l"] == "y")
                        {
                            cbRememberMe.Checked = true;
                        }

                        btnLoginOnClick(null, null);
                    }

                    // Look to see if we have credentials coming from 
                    // elsewhere
                    if ((Request.Cookies != null) &&
                        (Request.Cookies["PRCo.Login"] != null))
                    {

                        txtUserID.Text = Server.UrlDecode(Request.Cookies["PRCo.Login"]["txtEmail"]);
                        txtPassword.Text = Server.UrlDecode(Request.Cookies["PRCo.Login"]["txtPassword"]);

                        Request.Cookies.Remove("PRCo.Login");
                        Response.Cookies["PRCo.Login"].Expires = DateTime.Now.AddYears(-1);

                        btnLoginOnClick(null, null);
                    }
                }

                if (!string.IsNullOrEmpty(Request["PurchaseMembership"]))
                {
                    Session["PurchaseMembership"] = Request["PurchaseMembership"];
                }
            }

            litForgotEmail.Text = string.Format(Resources.Global.ForgotEmailMsg, Utilities.GetConfigValue("ForgotEmailEmail", "info@bluebookservices.com"));
            ((Corporate)this.Master).SetFormClass("login-form");
        }

        //Process RL (Reference Link) to see if this came from Content Management
        //If so the screen will look different
        //Sample link: <a href="https://azqa.apps.bluebookservices.com/bbos/CompanyDetailsSummary.aspx?RL=CM&amp;CompanyID=102030
        private bool IsRLProduce()
        {
            string RL = ((!string.IsNullOrEmpty(Request.QueryString["RL"]) ? Request.QueryString["RL"] : "")).ToLower();
            if (RL == "cm")
                return true;
            else
                return false;
        }

        private bool IsRLLumber()
        {
            string RL = ((!string.IsNullOrEmpty(Request.QueryString["RL"]) ? Request.QueryString["RL"] : "")).ToLower();
            if (RL == "cml")
                return true;
            else
                return false;
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
                GetObjectMgr().InsertWebAuditTrail(Request.ServerVariables.Get("SCRIPT_NAME"),
                                                 string.Empty,
                                                 null,
                                                 null,
                                                 Request.Browser.Browser,
                                                 Request.Browser.Version,
                                                 Request.Browser.Platform,
                                                 Request.ServerVariables["REMOTE_ADDR"],
                                                 Request.UserAgent);



                Response.Cookies[PageControlBaseCommon.GetCookieID()]["Email"] = szEmail;
                Response.Cookies[PageControlBaseCommon.GetCookieID()].Expires = DateTime.Now.AddYears(1);
                _oLogger.LogMessage("Putting Email into Cookie");

                string szCustomRedirectURL = null;

                if (Session["PurchaseMembership"] != null)
                {
                    szCustomRedirectURL = PageConstants.MEMBERSHIP_SELECT;
                }

                if (szCustomRedirectURL != null)
                {
                    FormsAuthenticationTicket AuthTicket = new FormsAuthenticationTicket(szEmail,
                                                                                         cbRememberMe.Checked,
                                                                                         Utilities.GetIntConfigValue("FormAuthTimeout", 20160));

                    string szCookieValue = FormsAuthentication.Encrypt(AuthTicket);
                    HttpCookie oCookie = new HttpCookie(FormsAuthentication.FormsCookieName, szCookieValue);

                    oCookie.Path = FormsAuthentication.FormsCookiePath;
                    Response.Cookies.Add(oCookie);

                    Response.Redirect(szCustomRedirectURL);
                }
                else
                {
                    //Session["oUser"] = null;  //DEFECT 5676
                    Session["RefreshCachePending"] = "true";
                    FormsAuthentication.RedirectFromLoginPage(szEmail, cbRememberMe.Checked);
                }
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
                    if (e.Message.StartsWith(PRWebUserMgr.UNABLE_TO_RETRIEVE_USER))
                    {
                        // If we find a duplicate email, try cleaning it up
                        // ourselves.
                        try
                        {
                            bool bProcessedFirst = false;
                            IPRWebUser oCrossIndustryUser = null;
                            IPRWebUser oCrossIndustryUserNonAuthenticate = null;
                            IBusinessObjectSet crossIndustryUsers = (IBusinessObjectSet)userMgr.GetUsersByCrossIndustry(szEmail);
                            foreach(IPRWebUser user in crossIndustryUsers)
                            {
                                if(user.Authenticate(szPassword) && !bProcessedFirst)
                                {
                                    oCrossIndustryUser = user;
                                    bProcessedFirst = true;
                                }
                                else
                                {
                                    oCrossIndustryUserNonAuthenticate = user;
                                }
                            }
                            
                            if(oCrossIndustryUser != null)
                            {
                                oUser = oCrossIndustryUser; //Use the Cross-Industry user to login with
                                Session["CrossIndustryUser"] = oCrossIndustryUserNonAuthenticate;
                                Session["CrossIndustryCheck"] = "Y";
                            }
                            else
                            {
                                userMgr.ProcessDuplicateUser(szEmail);
                                oUser = userMgr.GetByEmail(szEmail);
                            }
                        }
                        catch
                        {
                            throw new ApplicationUnexpectedException("Duplicate web user records found: " + szEmail);
                        }
                    }
                    else
                    {
                        throw;
                    }
                }

                if(Configuration.PasswordOverride == true && Configuration.PasswordOverride_Password == szPassword)
                {
                    //Allow password override if turned on
                }
                else if (!oUser.Authenticate(szPassword))
                {
                    AddUserMessage(Resources.Global.LoginInvalid);
                    return false;
                }
            

            if ((oUser.IsTrialUser()) &&
                (!oUser.IsTrialPeriodActive()))
            {
                AddUserMessage(Resources.Global.TrialExpiredMsg);
                return false;
            }

            // For a time, we will have the lumber code deployed in production, but we 
            // won't want to allow lumber users to log in.
            if ((oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER) &&
                (!Utilities.GetBoolConfigValue("LumberUsersEnabled", true)))
            {
                AddUserMessage(Resources.Global.LoginInvalid);
                return false;
            }

            // Using the same code base for the beta, we want to prevent non-lumber
            // users from logging into the beta
            if ((oUser.prwu_IndustryType != GeneralDataMgr.INDUSTRY_TYPE_LUMBER) &&
                (!Utilities.GetBoolConfigValue("ProduceUsersEnabled", true)))
            {
                AddUserMessage(Resources.Global.LoginInvalid);
                return false;
            }

            //if (oUser.prci2_Suspended)
            //{
                //AddUserMessage(Utilities.GetConfigValue("EnterpriseSuspendedMsg"));
                //return false;
            //}

            Session["oUser"] = oUser;
            _oUser = oUser;
            return true;
        }

        /// <summary>
        /// If the specified email address is found, email the
        /// corresponding password.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnEmailPasswordOnClick(Object sender, EventArgs e)
        {
            IPRWebUser oUser = null;

            try
            {
                oUser = new PRWebUserMgr(LoggerFactory.GetLogger(), null).GetByEmail(txtUserID.Text);

                CultureInfo requestedPasswordUserCulture = new CultureInfo(oUser.prwu_Culture);
                string szPasswordChangeEmailSubject = Resources.Global.ResourceManager.GetString("PasswordChangeEmailSubject", requestedPasswordUserCulture);
                string szPasswordChangeEmailBody = Resources.Global.ResourceManager.GetString("PasswordChangeEmailBody", requestedPasswordUserCulture);

                //Pass in these values so that they can be from resource file and language specific
                oUser.EmailPasswordChangeLink(szPasswordChangeEmailSubject, szPasswordChangeEmailBody);
                AddUserMessage(string.Format(Resources.Global.PasswordChangeLinkEmailed, txtUserID.Text));
            }
            catch (ObjectNotFoundException)
            {
                AddUserMessage(Resources.Global.LoginNotFound);
                return;
            }
        }

        protected override bool IsAuthorizedForPage()
        {
            return true;
        }

        protected override bool IsAuthorizedForData()
        {
            return true;
        }

        protected override bool IsTermsExempt()
        {
            return true;
        }

        /// <summary>
        /// Set page to auto-generate javascript variables for form elements.
        /// </summary>
        /// <returns></returns>
        public override bool EnableJSClientIDTranslation()
        {
            return false;
        }

        override protected bool SessionTimeoutForPageEnabled()
        {
            return false;
        }
    }
}