/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2022-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: ExpressUpdatesPurchaseConfirm.aspx.cs
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
    public partial class ExpressUpdatesPurchaseConfirm : MembershipBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            SetPageTitle(Resources.Global.ConfirmExpressUpdatesPurchase);

            if (!IsPostBack)
            {
                hidTriggerPage.Text = Request.ServerVariables["SCRIPT_NAME"];
                PopulateForm();
            }
        }

        protected void PopulateForm()
        {
            decimal EXPRESS_UPDATES_COST = GetExpressUpdatePrice();
            
            string szHasExpressUpdates = "";
            if (HasExpressUpdates(_oUser.prwu_BBID))
                szHasExpressUpdates = "Y";

            decimal decFirstLicenseCost = 0;

            //Calculate and set Express Updates fee (either $215 or $0)
            if (szHasExpressUpdates == "Y")
            {
                decFirstLicenseCost = 0; //no additional cost because they already have it
            }
            else
            {
                decFirstLicenseCost = EXPRESS_UPDATES_COST; //charge base cost because no existing users have it
            }

            litCost_Existing.Text = UIUtils.GetFormattedCurrency(decFirstLicenseCost, 0);

            //Hide sections if counts are 0
            if (decFirstLicenseCost == 0)
                rowExpressUpdates.Visible = false;

            //Disable purchase button if not applicable
            if (decFirstLicenseCost == 0)
            {
                rowEmptyMsg.Visible = true;
                btnPurchase.Enabled = false;
            }
        }

        private decimal GetExpressUpdatePrice()
        {
            const int EXPRESSUPDATES_PRODUCTID = 21;

            string productCode = null;
            string productName = null;
            string taxClass = null;
            decimal price;

            GetProductPriceData(EXPRESSUPDATES_PRODUCTID, _oUser.prwu_Culture, out price, out taxClass, out productCode, out productName);
            return price;
        }

        protected const string EXPRESSUPDATES_PURCHASE_MSG = "EXPRESS UPDATES PURCHASE ORDER\n\nAn Express Updates Purchase order was placed by the following company.  Please add order to MAS and process online access settings in CRM.";

        protected void btnPurchaseOnClick(object sender, EventArgs e)
        {
            IDbTransaction oTran = GetObjectMgr().BeginTransaction();
            try
            {
                string szMsg = GetTaskMsg(EXPRESSUPDATES_PURCHASE_MSG);
                int specialistID = GetObjectMgr().GetPRCoSpecialistID(_oUser.prwu_BBID, GeneralDataMgr.PRCO_SPECIALIST_CSR, oTran);

                GetObjectMgr().CreateTask(specialistID,
                                          "Pending",
                                          szMsg,
                                          Utilities.GetConfigValue("ExpressUpdatesPurchaseCategory", string.Empty),
                                          Utilities.GetConfigValue("ExpressUpdatesPurchaseSubcategory", string.Empty),
                                          _oUser.prwu_BBID,
                                          _oUser.peli_PersonID,
                                          0,
                                          "OnlineIn",
                                          Utilities.GetConfigValue("ExpressUpdatesPurchaseEmailSubject", "Express Updates Purchase Request received from BBOS"),
                                          oTran);
                oTran.Commit();

                //GetObjectMgr().SendEmail_Text(GetObjectMgr().GetPRCoUserEmail(specialistID, oTran),
                //          Utilities.GetConfigValue("ExpressUpdatesPurchaseEmailSubject", "Express Updates Purchase Request received from BBOS"),
                //          szMsg,
                //          "ExpressUpdatesPurchaseConfirm.aspx",
                //          oTran);

                //Accounting -- default to eft@bluebookservices.com id 1029
                GetObjectMgr().SendEmail_Text(GetObjectMgr().GetPRCoUserEmail(Utilities.GetIntConfigValue("ExpressUpdatesPurchaseEmailAcctUserID", 1029), oTran),
                          Utilities.GetConfigValue("ExpressUpdatesPurchaseEmailSubject", "Express Updates Purchase Request received via BBOS"),
                          szMsg,
                          "ExpressUpdatesPurchaseConfirm.aspx",
                          oTran);

                //Defect 7396 - send email to all Sales People (default ('TJR', 'JBL', 'LEL') -- Jeff Lair, Leticia Lima, Tim Reardon
                SendEmailToSales(Utilities.GetConfigValue("ExpressUpdatesPurchaseEmailSubject", "Express Updates Purchase Request received via BBOS"),
                        szMsg,
                        "ExpressUpdatesPurchaseConfirm.aspx",
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
            sbMsg.Append("Express Updates License: " + litCost_Existing.Text + Environment.NewLine);

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
            Response.Redirect(PageConstants.EXPRESSUPDATES_PURCHASE);
        }
    }
}
