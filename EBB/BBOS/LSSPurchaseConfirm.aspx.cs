/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2018-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: LSSPurchaseConfirm.aspx.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using PRCo.EBB.BusinessObjects;
using PRCo.EBB.Util;
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web
{
    public partial class LSSPurchaseConfirm : MembershipBase
    {
        protected Dictionary<string,string> _lstUserID_New = new Dictionary<string,string>();
        protected Dictionary<string,string> _lstUserID_Existing = new Dictionary<string,string>();

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            _lstUserID_New = (Dictionary<string,string>)Session["LSSPurchaseUserIDList_New"];
            _lstUserID_Existing = (Dictionary<string,string>)Session["LSSPurchaseUserIDList_Existing"];

            SetPageTitle(Resources.Global.ConfirmLocalSourceLicensePurchase);

            if (!IsPostBack)
            {
                hidTriggerPage.Text = Request.ServerVariables["SCRIPT_NAME"];
                PopulateForm();
            }
        }

        protected void PopulateForm()
        {
            const int LOCAL_SOURCE_ACCESS_FEE_COST = 375;
            const int ADDITIONAL_LICENSE_FEE = 110;

            int intFirstLicenseCost = 0;
            int intNewLicenseQty = 0;

            //Calculate and set Local Source Access fee (either $350 or $0)
            //Calculate and set Additional License Fees ($100 per additional new license above and beyond first Local Source Access license)
            if (_lstUserID_Existing.Count > 0)
            {
                intFirstLicenseCost = 0; //no additional cost because they already have it
                intNewLicenseQty = _lstUserID_New.Count;
            }
            else if (_lstUserID_New.Count > 0)
            {
                //Existing.Count == 0
                intFirstLicenseCost = LOCAL_SOURCE_ACCESS_FEE_COST; //chage base cost because no existing users have it
                intNewLicenseQty = _lstUserID_New.Count - 1;
            }

            litCost_Existing.Text = UIUtils.GetFormattedCurrency(intFirstLicenseCost, 0);

            litQuantity_New.Text = intNewLicenseQty.ToString();
            litCost_New.Text = UIUtils.GetFormattedCurrency(intNewLicenseQty * ADDITIONAL_LICENSE_FEE, 0);  // $100 per additional license

            //Hide sections if counts are 0
            if (intFirstLicenseCost == 0)
                rowLocalSourceAccess.Visible = false;
            if (intNewLicenseQty == 0)
                rowAdditionalLicenses.Visible = false;

            //Disable purchase button if not applicable
            if (intFirstLicenseCost == 0 && intNewLicenseQty == 0)
            {
                rowEmptyMsg.Visible = true;
                btnPurchase.Enabled = false;
            }
        }

        protected const string LSS_PURCHASE_MSG = "LSS PURCHASE ORDER\n\nAn LSS Purchase order was placed by the following company.  Please add order to MAS and process online access settings in CRM.";

        protected void btnPurchaseOnClick(object sender, EventArgs e)
        {
            IDbTransaction oTran = GetObjectMgr().BeginTransaction();
            try
            {
                string szMsg = GetTaskMsg(LSS_PURCHASE_MSG);
                int specialistID = GetObjectMgr().GetPRCoSpecialistID(_oUser.prwu_BBID, GeneralDataMgr.PRCO_SPECIALIST_CSR, oTran);

                GetObjectMgr().CreateTask(specialistID,
                                          "Pending",
                                          szMsg,
                                          Utilities.GetConfigValue("LSSPurchaseCategory", string.Empty),
                                          Utilities.GetConfigValue("LSSPurchaseSubcategory", string.Empty),
                                          _oUser.prwu_BBID,
                                          _oUser.peli_PersonID,
                                          0,
                                          "OnlineIn",
                                          Utilities.GetConfigValue("LSSPurchaseEmailSubject", "LSS Purchase Request received from BBOS"),
                                          oTran);
                oTran.Commit();

                //Defect 6973 - emails via stored proc
                //GetObjectMgr().SendEmail_Text(GetObjectMgr().GetPRCoUserEmail(specialistID, oTran),
                //          Utilities.GetConfigValue("LSSPurchaseEmailSubject", "LSS Purchase Request received from BBOS"),
                //          szMsg,
                //          "LSSPurchaseConfirm.aspx",
                //          oTran);
                
                //Accounting -- default to eft@bluebookservices.com id 1029
                GetObjectMgr().SendEmail_Text(GetObjectMgr().GetPRCoUserEmail(Utilities.GetIntConfigValue("LSSPurchaseEmailAcctUserID", 1029), oTran),
                        Utilities.GetConfigValue("LSSPurchaseEmailSubject", "LSS Purchase Request received via BBOS"),
                        szMsg,
                        "LSSPurchaseConfirm.aspx",
                        oTran);

                //Defect 7396 - send email to all Sales People (default ('TJR', 'JBL', 'LEL') -- Jeff Lair, Leticia Lima, Tim Reardon
                SendEmailToSales(Utilities.GetConfigValue("LSSPurchaseEmailSubject", "LSS Purchase Request received via BBOS"),
                        szMsg,
                        "LSSPurchaseConfirm.aspx",
                        _oUser,
                        oTran);
            }
            catch
            {
                if (oTran != null)
                {
                    oTran.Rollback();
                }
                throw;
            }

            Response.Redirect(PageConstants.MEMBERSHIP_COMPLETE);
        }

        /// <summary>
        /// Helper method that formats the transaction details for a BBS CRM user task.
        /// </summary>
        /// <param name="szOrderMsg"></param>
        /// <returns></returns>
        protected string GetTaskMsg(string szOrderMsg)
        {
            StringBuilder sbMsg = new StringBuilder();

            sbMsg.Append(szOrderMsg + Environment.NewLine);
            sbMsg.Append(GetUserInfoForTask() + Environment.NewLine);
            sbMsg.Append("Product Information" + Environment.NewLine);
            sbMsg.Append("Local Source Access: " + litCost_Existing.Text + Environment.NewLine);
            sbMsg.Append("Additional Local Source License Quantity: " + litQuantity_New.Text + Environment.NewLine);
            sbMsg.Append("Additional Local Source License Cost: " + litCost_New.Text + Environment.NewLine);

            sbMsg.Append(GetAdditionalUsersList());

            return sbMsg.ToString();
        }

        /// <summary>
        /// Helper method that formats the user data for inclusion
        /// in a BBS CRM task.
        /// </summary>
        /// <returns></returns>
        protected string GetUserInfoForTask()
        {
            StringBuilder sbMsg = new StringBuilder();

            sbMsg.Append(_oUser.Name + Environment.NewLine);
            sbMsg.Append(_oUser.prwu_CompanyName + Environment.NewLine);
            sbMsg.Append("BB #: " + _oUser.prwu_BBID.ToString() + Environment.NewLine);
            sbMsg.Append("HQ BB #: " + _oUser.prwu_HQID.ToString() + Environment.NewLine);
            sbMsg.Append(_oUser.prwu_PhoneAreaCode + "-" + _oUser.prwu_PhoneNumber + Environment.NewLine);
            sbMsg.Append(_oUser.Email + Environment.NewLine);

            return sbMsg.ToString();
        }

        /// <summary>
        /// Returns a formated string of any additional membership users
        /// specified by the user in the membership wizard.
        /// </summary>
        /// <returns></returns>
        protected string GetAdditionalUsersList()
        {
            if (_lstUserID_New.Count == 0 && _lstUserID_Existing.Count == 0)
            {
                return string.Empty;
            }

            StringBuilder sbAddUsers = new StringBuilder(Environment.NewLine + "Specified Additional Users" + Environment.NewLine);
            foreach (string strAdditionalUser in _lstUserID_New.Values)
            {
                sbAddUsers.Append(strAdditionalUser);
                sbAddUsers.Append(Environment.NewLine);
            }

            return sbAddUsers.ToString();
        }

        protected override bool IsAuthorizedForPage()
        {
            return true;
        }

        protected override bool IsAuthorizedForData()
        {
            return true;
        }

        protected void btnReviseSection_Click(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.LSS_PURCHASE);
        }
    }
}
