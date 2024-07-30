/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: MembershipUpgrade.aspx.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using PRCo.EBB.BusinessObjects;
using PRCo.EBB.Util;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This page allows the user to confirm the selected membership
    /// upgrade products.
    /// </summary>
    public partial class MembershipUpgrade : MembershipBase
    {
        protected const string MEMBERSHIP_UPGRADE_MSG = "MEMBERSHIP UPGRADE ORDER\n\nA membership upgrade order was placed by the following company.  Please add order to MAS and process online access settings in CRM.";

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            SetPageTitle(Resources.Global.MembershipConfirmUpgrade);

            if (!IsPostBack)
            {
                PopulateForm();
            }
        }

        /// <summary>
        /// Populates the form with the selected products
        /// and costs.
        /// </summary>
        protected void PopulateForm()
        {
            CreditCardPaymentInfo oCCPayment = GetCreditCardPaymentInfo();

            if ((oCCPayment.Products == null) ||
                (oCCPayment.Products.Count == 0))
            {
                lblProduct.Text = Resources.Global.NoProductsSelected;
                btnPurchase.Enabled = false;
                return;
            }

            lblProduct.Text = GetProductDescriptions(oCCPayment);

            // Compute shipping for each product
            foreach (CreditCardProductInfo oProductInfo in oCCPayment.Products)
            {
                oCCPayment.Shipping += (GetObjectMgr().GetShippingRate(_oUser.prwu_CountryID, oProductInfo.ProductID) * oProductInfo.Quantity);
            }

            // Compute out our tax using the User values
            oCCPayment.GetTaxedCost();
            oCCPayment.TotalPrice = oCCPayment.GetCost() + oCCPayment.Shipping + oCCPayment.TaxAmount;

            lblSubTotal.Text = UIUtils.GetFormattedCurrency(oCCPayment.GetCost(), 0M);
            lblShipping.Text = UIUtils.GetFormattedCurrency(oCCPayment.GetShippingRate(), 0M);
            lblSalesTax.Text = UIUtils.GetFormattedCurrency(oCCPayment.TaxAmount, 0M);
            lblTotal.Text = UIUtils.GetFormattedCurrency(oCCPayment.TotalPrice, 0M);

            lblTaxMsg.Text = Resources.Global.CreditCardTaxMsg;
        }

        /// <summary>
        /// Helper method that formats the transaction details
        /// for a BBS CRM user task.
        /// </summary>
        /// <param name="szOrderMsg"></param>
        /// <returns></returns>
        protected string GetTaskMsg(string szOrderMsg)
        {
            StringBuilder sbMsg = new StringBuilder();

            sbMsg.Append(szOrderMsg + Environment.NewLine);
            sbMsg.Append(GetUserInfoForTask() + Environment.NewLine);
            sbMsg.Append("Product Information" + Environment.NewLine);
            sbMsg.Append(lblProduct.Text.Replace("<br />", Environment.NewLine) + Environment.NewLine);
            sbMsg.Append(GetAdditionalUsersList());

            return sbMsg.ToString();
        }

        /// <summary>
        /// Returns a formated string of any additional membership users
        /// specified by the user in the membership wizard.
        /// </summary>
        /// <returns></returns>
        protected string GetAdditionalUsersList()
        {
            List<Person> lMembershipUsers = (List<Person>)Session["lMembershipUsers"];
            if (lMembershipUsers == null)
            {
                return string.Empty;
            }

            StringBuilder sbAddUsers = new StringBuilder(Environment.NewLine + "Specified Additional Users" + Environment.NewLine);
            foreach (Person oPerson in lMembershipUsers)
            {
                sbAddUsers.Append(GetReferenceValue("prwu_AccessLevel", oPerson.AccessLevel.ToString()));
                sbAddUsers.Append(" - ");
                sbAddUsers.Append(oPerson.FirstName);
                sbAddUsers.Append(" ");
                sbAddUsers.Append(oPerson.LastName);
                sbAddUsers.Append(" - ");
                sbAddUsers.Append(oPerson.Email);
                sbAddUsers.Append(Environment.NewLine);
            }

            return sbAddUsers.ToString();
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
        protected void btnPurchaseOnClick(object sender, EventArgs e)
        {
            IDbTransaction oTran = GetObjectMgr().BeginTransaction();
            try
            {
                _oUser.prwu_AccessLevel = Convert.ToInt32(GetRequestParameter("MembershipAccessLevel"));
                _oUser.Save(oTran);

                string szMsg = GetTaskMsg(MEMBERSHIP_UPGRADE_MSG);
                int specialistID;
                if (_oUser.IsLimitado)
                {
                    //For ITA, use Inside Sales rep
                    specialistID = GetObjectMgr().GetPRCoSpecialistID(_oUser.prwu_BBID, GeneralDataMgr.PRCO_SPECIALIST_INSIDE_SALES, oTran);
                }
                else
                {
                    //For all others use CSR
                    specialistID = GetObjectMgr().GetPRCoSpecialistID(_oUser.prwu_BBID, GeneralDataMgr.PRCO_SPECIALIST_CSR, oTran);
                }

                GetObjectMgr().CreateTask(specialistID,
                                          "Pending",
                                          szMsg,
                                          Utilities.GetConfigValue("MembershipUpgradeCategory", string.Empty),
                                          Utilities.GetConfigValue("MembershipUpgradeSubcategory", string.Empty),
                                          _oUser.prwu_BBID,
                                          _oUser.peli_PersonID,
                                          0,
                                          "OnlineIn",
                                          Utilities.GetConfigValue("MembershipUpgradeEmailSubject", "Membership Upgrade Request received from BBOS"),
                                          oTran);
                oTran.Commit();

                //Defect 6973 - emails via stored proc
                //Inside sales rep (for ITA) or QA specialist
                //GetObjectMgr().SendEmail_Text(GetObjectMgr().GetPRCoUserEmail(specialistID, oTran),
                //        Utilities.GetConfigValue("MembershipUpgradeEmailSubject", "Membership Upgrade Request received from BBOS"),
                //        szMsg,
                //        "MembershipUpgrade.aspx",
                //        oTran);

                //Accounting -- default to eft@bluebookservices.com id 1029 per defect 4508
                GetObjectMgr().SendEmail_Text(GetObjectMgr().GetPRCoUserEmail(Utilities.GetIntConfigValue("MembershipUpgradeEmailAcctUserID", 1029), oTran),
                        Utilities.GetConfigValue("MembershipUpgradeEmailSubject", "Membership Upgrade via BBOS"),
                        szMsg,
                        "MembershipUpgrade.aspx",
                        oTran);

                //Defect 7396 - send email to all Sales People (default ('TJR', 'JBL', 'LEL') -- Jeff Lair, Leticia Lima, Tim Reardon
                SendEmailToSales(Utilities.GetConfigValue("MembershipUpgradeEmailSubject", "Membership Upgrade via BBOS"),
                        szMsg,
                        "MembershipUpgrade.aspx",
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

        protected void btnReviseOnClick(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.MEMBERSHIP_SELECT);
        }
    }
}
