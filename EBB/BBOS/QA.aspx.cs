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

 ClassName: QA.aspx  
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Web.UI.WebControls;

using PRCo.EBB.BusinessObjects;
using PRCo.EBB.Util;
using TSI.Arch;
using TSI.BusinessObjects;
using TSI.DataAccess;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web
{
    public partial class QA : PageBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            SetPageTitle("Quality Assurance");

            if (_oUser.HasPrivilege(SecurityMgr.Privilege.SystemAdmin).HasPrivilege)
            {
                pnlSysAdmin.Visible = true;
            }
            else
            {
                if (IsImpersonating() &&
                    ((IPRWebUser)Session["PRCOUser"]).HasPrivilege(SecurityMgr.Privilege.SystemAdmin).HasPrivilege)
                {
                    pnlSysAdmin.Visible = true;
                }
                else
                {
                    pnlSysAdmin.Visible = false;
                }
            }

            if (!IsPostBack)
            {
                BindLookupValues();
            }

            btnImpersonate.Visible = true;
            btnRevert.Visible = false;

            if (IsImpersonating())
            {
                btnImpersonate.Visible = false;
                btnRevert.Visible = true;
                litImpersonation.Text = "Impersonating BB# " + _oUser.prwu_HQID.ToString() + " " + _oUser.FirstName + " " + _oUser.LastName;
            }
        }

        protected void BindLookupValues()
        {
            ddlIndustryType.Items.Clear();
            ddlAccessLevel.Items.Clear();

            BindLookupValues(ddlIndustryType, GetReferenceData("comp_PRIndustryType"), _oUser.prwu_IndustryType);

            IBusinessObjectSet accessLevels = GetReferenceData("prwu_AccessLevel");
            foreach (ICustom_Caption accessLevel in accessLevels)
            {
                ddlAccessLevel.Items.Add(new ListItem(accessLevel.Meaning + " (" + accessLevel.Code + ")", accessLevel.Code));
            }

            SetListDefaultValue(ddlAccessLevel, _oUser.prwu_AccessLevel.ToString());
        }

        private const string SQL_GET_COMPANY = "SELECT comp_PRIndustryType FROM Company WITH (NOLOCK) where comp_CompanyID=@CompanyID";
        protected void btnImpersonateOnClick(object sender, EventArgs e)
        {
            IPRWebUser OriginalWebUser = _oUser;

            if (string.IsNullOrEmpty(txtHQID.Text) && string.IsNullOrEmpty(txtEmail.Text))
                return;

            Session["PRCOUser"] = _oUser;
            Session["PRCOUser.Impersonating"] = true;

            if (!string.IsNullOrEmpty(txtHQID.Text))
            {
                _oUser.prwu_HQID = Convert.ToInt32(txtHQID.Text);
                _oUser.prwu_BBID = Convert.ToInt32(txtHQID.Text);

                IList oParms = new ArrayList();
                oParms.Add(new DBParameter("CompanyID", Convert.ToInt32(txtHQID.Text)));
                string szIndustryType = (string)GetDBAccess().ExecuteScalar(SQL_GET_COMPANY, oParms);

                _oUser.prwu_IndustryType = szIndustryType;
            }
            else
            {
                PRWebUserMgr userMgr = new PRWebUserMgr(LoggerFactory.GetLogger(), null);

                try
                {
                    _oUser = GetUser(txtEmail.Text);
                }
                catch (ApplicationUnexpectedException e2)
                {
                    if (e2.Message.StartsWith(PRWebUserMgr.UNABLE_TO_RETRIEVE_USER))
                    {
                        // If we find a duplicate email, try cleaning it up
                        // ourselves.
                        try
                        {
                            bool bProcessedFirst = false;
                            IPRWebUser oCrossIndustryUser = null;
                            IPRWebUser oCrossIndustryUserNonAuthenticate = null;
                            IBusinessObjectSet crossIndustryUsers = (IBusinessObjectSet)userMgr.GetUsersByCrossIndustry(txtEmail.Text);
                            foreach (IPRWebUser user in crossIndustryUsers)
                            {
                                if (!bProcessedFirst)
                                {
                                    oCrossIndustryUser = user;
                                    bProcessedFirst = true;
                                }
                                else
                                {
                                    oCrossIndustryUserNonAuthenticate = user;
                                }
                            }

                            if (oCrossIndustryUser != null)
                            {
                                _oUser = oCrossIndustryUser; //Use the Cross-Industry user to login with
                                Session["CrossIndustryUser"] = oCrossIndustryUserNonAuthenticate;
                                Session["CrossIndustryCheck"] = "Y";
                            }
                            else
                            {
                                userMgr.ProcessDuplicateUser(txtEmail.Text);
                                _oUser = userMgr.GetByEmail(txtEmail.Text);
                            }
                        }
                        catch
                        {
                            throw new ApplicationUnexpectedException("Duplicate web user records found: " + txtEmail.Text);
                        }
                    }
                    else
                    {
                        throw;
                    }
                }

                Session["oUser"] = _oUser;
            }

            BindLookupValues();
            Session["szHelpURL"] = null;
            AddUserMessage("Impersonation Successful.", true);

            btnImpersonate.Visible = false;
            btnRevert.Visible = true;
            litImpersonation.Text = "Impersonating BB# " + _oUser.prwu_HQID.ToString() + " " + _oUser.FirstName + " " + _oUser.LastName;

            if (_oUser.prwu_AccessLevel == PRWebUser.SECURITY_LEVEL_TRADE_ASSOCIATION_ACCESS)
            {
                _oUser.prcta_IsIntlTradeAssociation = true;
                _oUser.prwu_ServiceCode = "ITALIC";
                _oUser.IsLimitado = true;
            }


            Session["mcCLCheck"] = null;
            Session["mcCLMsg"] = null;

            Session["mcJeopardyCheck"] = null;
            Session["mcJeopardyMsg"] = null;

            Response.Redirect(Request.RawUrl);
        }

        protected void btnRevertOnClick(object sender, EventArgs e)
        {
            _oUser = (IPRWebUser)Session["PRCOUser"];
            Session["oUser"] = _oUser;
            Session["PRCOUser.Impersonating"] = false;
            Session["PRCOUser"] = null;

            btnImpersonate.Visible = true;
            btnRevert.Visible = false;
            litImpersonation.Text = string.Empty;
            AddUserMessage("Reverted to User " + _oUser.Email, true);

            Session["mcCLCheck"] = null;
            Session["mcCLMsg"] = null;

            Session["mcJeopardyCheck"] = null;
            Session["mcJeopardyMsg"] = null;


            Response.Redirect(Request.RawUrl);
        }

        protected void btnCHWTest(object sender, EventArgs e)
        {
            _oUser.GetOpenInvoiceMessageCode();
        }

        /// <summary>
        /// All users can view this page.
        /// </summary>
        /// <returns></returns>
        override protected bool IsAuthorizedForPage()
        {
            if (IsImpersonating())
            {
                return true;
            }

            return IsPRCoUser();
        }

        /// <summary>
        /// All users can view this data.
        /// </summary>
        /// <returns></returns>
        protected override bool IsAuthorizedForData()
        {
            return true;
        }

        protected void btnSetAccessOnClick(object sender, EventArgs e)
        {
            SavePRCoUserValues();
            _oUser.prwu_AccessLevel = Convert.ToInt32(ddlAccessLevel.SelectedValue);
            _oUser.prwu_IndustryType = ddlIndustryType.SelectedValue;

            if(ddlAccessLevel.SelectedValue == PRWebUser.SECURITY_LEVEL_TRADE_ASSOCIATION_ACCESS.ToString()) 
            {
                _oUser.prcta_IsIntlTradeAssociation = true;
                _oUser.prwu_ServiceCode = "ITALIC";
                _oUser.IsLimitado = true;
            }
            else
            {
                _oUser.prcta_IsIntlTradeAssociation = false;
            }

            AddUserMessage("Access Information Set", true);
            Response.Redirect(Request.RawUrl);
        }

        protected void btnRestoreAccessOnClick(object sender, EventArgs e)
        {
            RestorePRCoUserValues();
            BindLookupValues();

            _oUser.prcta_IsIntlTradeAssociation = false;
            Response.Redirect(Request.RawUrl);
        }

        /// <summary>
        /// Restorses the current user's key values
        /// from the session.
        /// </summary>
        protected void RestorePRCoUserValues()
        {
            if (Session["IsPRCOUser"] != null)
            {
                _oUser.prwu_AccessLevel = Convert.ToInt32(Session["PRCOUser.prwu_AccessLevel"]);
                _oUser.prwu_IndustryType = (string)Session["PRCOUser.prwu_IndustryType"];
                _oUser.prwu_HQID = Convert.ToInt32(Session["PRCOUser.prwu_HQID"]);
                _oUser.prwu_BBID = Convert.ToInt32(Session["PRCOUser.prwu_BBID"]);
                _oUser.prwu_IndustryType = (string)Session["PRCOUser.prwu_IndustryType"];
                _oUser.Email = (string)Session["PRCOUser.Email"];
                _oUser.prwu_ServiceCode = (string)Session["PRCOUser.prwu_ServiceCode"];
                _oUser.Save();
            }

            SetListDefaultValue(ddlAccessLevel, _oUser.prwu_AccessLevel.ToString());
            SetListDefaultValue(ddlIndustryType, _oUser.prwu_IndustryType);

            _oUser.prcta_IsIntlTradeAssociation = false;
            _oUser.ClearLimitado();

            Session["PRCOUser.Impersonating"] = false;
        }

        /// <summary>
        /// Saves the current user's key values in the 
        /// session for future reference.
        /// </summary>
        protected void SavePRCoUserValues()
        {
            if (Session["IsPRCOUser"] == null)
            {
                Session["IsPRCOUser"] = true;
                Session["PRCOUser.prwu_AccessLevel"] = _oUser.prwu_AccessLevel.ToString();
                Session["PRCOUser.prwu_IndustryType"] = _oUser.prwu_IndustryType;
                Session["PRCOUser.prwu_HQID"] = _oUser.prwu_HQID.ToString();
                Session["PRCOUser.prwu_BBID"] = _oUser.prwu_BBID.ToString();
                Session["PRCOUser.Email"] = _oUser.Email;
                Session["PRCOUser.prwu_ServiceCode"] = _oUser.prwu_ServiceCode;
            }
        }
    }
}
