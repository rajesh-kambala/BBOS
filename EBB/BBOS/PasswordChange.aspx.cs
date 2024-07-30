/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2018-2021

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: PasswordChange.aspx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using PRCo.EBB.BusinessObjects;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Handles the changing of a users password.
    /// 
    /// </summary>
    public partial class PasswordChange : PageBase
    {
        protected string _oQueryKey;
        protected IPRWebUser _oPasswordUser;

        /// <summary>
        /// Returns the specified key passed in -- the GUID param "qk" from the querystring
        /// http://localhost/bbos/PasswordChange.aspx?k=adsfdsafsa
        /// </summary>
        /// <returns></returns>
        /// 
        public string QueryKey
        {
            get
            {
                if (_oQueryKey == null)
                    _oQueryKey = Request.QueryString["qk"];

                return _oQueryKey;
            }
        }

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if (!ProcessKey())
                return; //key was invalid or missing so bail


            SetPageTitle(Resources.Global.PasswordChange, _oPasswordUser.Name);

            EnableFormValidation();
            btnCancel.OnClientClick = "DisableValidation();";
        }

        private bool ProcessKey()
        {
            //Handle whether valid key (non-expired) was passed-in
            if (QueryKey == null)
            {
                //No key passed in -- display error section of page
                DisplayErrorPanel(true, Resources.Global.PasswordChangeRequestKeyMissing);
                pnlPasswordInfo.Visible = false;
                return false;
            }
            else
            {
                //Key was passed in -- make sure it is valid and not expired
                PRWebUserMgr oMgr = new PRWebUserMgr(_oLogger, null);

                if (!oMgr.PasswordChangeGuidExists(QueryKey))
                {
                    //No key passed in -- display error section of page
                    DisplayErrorPanel(true, Resources.Global.PasswordChangeRequestKeyInvalid);
                    pnlPasswordInfo.Visible = false;
                    return false;
                }

                _oPasswordUser = oMgr.GetByPasswordChangeGuid(QueryKey);

                PageControlBaseCommon.SetCulture(_oPasswordUser);
                btnSave.Text = Resources.Global.btnSave;
                btnCancel.Text = Resources.Global.btnCancel;

                if (_oPasswordUser.prwu_PasswordChangeGuidExpirationDate != null)
                {
                    if (DateTime.Now > _oPasswordUser.prwu_PasswordChangeGuidExpirationDate)
                    {
                        DisplayErrorPanel(true, Resources.Global.PasswordChangeRequestKeyExpired);
                        return false;
                    }
                    else
                    {
                        //All is ok and key is valid, so display the main non-error panel
                        DisplayErrorPanel(false);
                        pnlPasswordInfo.Visible = true;
                        return true;
                    }
                }
                else
                {
                    DisplayErrorPanel(true, Resources.Global.PasswordChangeRequestKeyInvalid);
                    return false;
                }
            }
        }

        private void DisplayErrorPanel(bool blnShowErrorPanel, string strKeyError = null)
        {
            pnlKeyError.Visible = blnShowErrorPanel;

            if (strKeyError != null)
                lblKeyError.Text = strKeyError;
        }

       
        /// <summary>
        /// Populates the user object from the form controls.
        /// </summary>
        /// <returns></returns>
        protected bool PopulateObject()
        {
            if (_oPasswordUser == null)
                return false;


            int iMinPasswordLength = Utilities.GetIntConfigValue("MinPasswordLength", 6);

            if (txtPassword.Text != txtConfirmPassword.Text)
            {
                AddUserMessage(Resources.Global.PasswordsDoNotMatchMsg);
                return false;
            }

            if (txtPassword.Text.Length < iMinPasswordLength)
            {
                AddUserMessage(String.Format(Resources.Global.NewPasswordInvalidLengthMsg, iMinPasswordLength));
                return false;
            }

            _oPasswordUser.Password = txtPassword.Text;

            if (Session["IsBBIDLogin"] != null)
            {
                _oPasswordUser.prwu_BBIDLoginCount++;
            }

            //Invalidate the passwordchangeguid's before saving the record
            _oPasswordUser.prwu_PasswordChangeGuid = null;
            _oPasswordUser.prwu_PasswordChangeGuidExpirationDate = DateTime.MinValue;

            _oPasswordUser.Save();

            // If the user is logged in and editing themselves, refresh our application user.
            if (_oUser != null && _oPasswordUser.prwu_WebUserID == _oUser.prwu_WebUserID)
            {
                _oUser = new PRWebUserMgr(_oLogger, _oUser).GetByEmail(_oUser.Email);
                Session["oUser"] = _oUser;
            }

            return true;
        }

        /// <summary>
        /// All users can view this page.
        /// </summary>
        /// <returns></returns>
        override protected bool IsAuthorizedForPage()
        {
            return true;
        }

        /// <summary>
        /// All users can view this data.
        /// </summary>
        /// <returns></returns>
        protected override bool IsAuthorizedForData()
        {
            return true;
        }

        public override bool EnableJSClientIDTranslation()
        {
            return true;
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (PopulateObject())
                Response.Redirect(GetReturnURL(PageConstants.BBOS_HOME));
        }

        /// <summary>
        /// Returns the user to default.aspx.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnCancelOnClick(object sender, EventArgs e)
        {
            Response.Redirect(GetReturnURL(PageConstants.BBOS_HOME));
        }
    }
}