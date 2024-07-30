/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: Sidebar.ascx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/

using PRCo.EBB.BusinessObjects;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Runtime.Remoting.Messaging;
using System.Threading;
using System.Web.UI;
using TSI.BusinessObjects;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web.UserControls
{
    public partial class Sidebar : UserControlBase
    {
        protected string _szCompanyID;
        protected CompanyData _ocd;
        protected int _prwucl_WebUserListID;

        protected int _iMenuExpand = 1;
        public const int MENU_EXPAND_COMPANY = 1;
        public const int MENU_EXPAND_SERVICES = 2;
        public const int MENU_EXPAND_DOWNLOADS = 3;
        public const int MENU_EXPAND_ACTIONS = 4;

        protected int _iMenuPage = 1;
        public const int MENU_PAGE_COMPANY_PROFILE = 1;
        public const int MENU_PAGE_COMPANY_CONTACTS = 2;
        public const int MENU_PAGE_COMPANY_AR_REPORTS = 3;
        public const int MENU_PAGE_COMPANY_CLAIMS_ACTIVITY = 4;
        public const int MENU_PAGE_COMPANY_BRANCHES = 5;
        public const int MENU_PAGE_COMPANY_NEWS = 6;
        public const int MENU_PAGE_COMPANY_UPDATES = 7;
        public const int MENU_PAGE_COMPANY_NOTES = 8;
        public const int MENU_PAGE_COMPANY_CSG = 9;

        PageBase oPage;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
            oPage = (PageBase)this.Parent.Page;

            _prwucl_WebUserListID = GetAUSList().WebUserListID;
            ucCustomData.EditCustomDataButtonClicked += new EventHandler(EditCustomDataButton_Clicked);

            if (!IsPostBack)
            {
                GetOcd();
                PopulateForm();
                PopulateSideBar();
                ApplySecurity();

                if (_ocd.szCompanyType == "B")
                {
                    btnAddToConnectionList.Visible = false;
                }
            }

            PopulateButtons();
        }

        public string CompanyID
        {
            get { return _szCompanyID; }
            set { _szCompanyID = value; }
        }

        public int MenuExpand
        {
            get { return _iMenuExpand; }
            set { _iMenuExpand = value; }
        }

        public int MenuPage
        {
            get { return _iMenuPage; }
            set { _iMenuPage = value; }
        }

        public CompanyData GetOcd()
        {
            if (_ocd == null)
                _ocd = PageControlBaseCommon.GetCompanyData(CompanyID, WebUser, GetDBAccess(), GetObjectMgr());
            return _ocd;
        }

        protected void PopulateForm()
        {
            // Select correct menu item
            if (MenuPage == MENU_PAGE_COMPANY_PROFILE)
                SelectMenu(btnCompanyProfile);
            else if (MenuPage == MENU_PAGE_COMPANY_CONTACTS)
                SelectMenu(btnContacts);
            else if (MenuPage == MENU_PAGE_COMPANY_AR_REPORTS)
                SelectMenu(btnARReports);
            else if (MenuPage == MENU_PAGE_COMPANY_CLAIMS_ACTIVITY)
                SelectMenu(btnClaimsActivity);
            else if (MenuPage == MENU_PAGE_COMPANY_BRANCHES)
                SelectMenu(btnBranches);
            else if (MenuPage == MENU_PAGE_COMPANY_NEWS)
                SelectMenu(btnNews);
            else if (MenuPage == MENU_PAGE_COMPANY_UPDATES)
                SelectMenu(btnUpdates);
            else if (MenuPage == MENU_PAGE_COMPANY_NOTES)
                SelectMenu(btnNotes);
            else if (MenuPage == MENU_PAGE_COMPANY_CSG)
                SelectMenu(btnCSG);

            // Expand correct menus
            switch (MenuExpand)
            {
                case MENU_EXPAND_COMPANY:
                    ShowMenu(menu_Company);
                    ShowMenu(menu_Actions);
                    break;
            }

            //Rate
            ucTESLongForm.SubjectIndustryType = _ocd.szIndustryType;

            //Business Report
            if (_ocd.szIndustryType == GeneralDataMgr.INDUSTRY_TYPE_SUPPLY)
            {
                btnBusinessReportFree.Disabled = true;
                btnBusinessReportExperian.Disabled = true;
                btnBusinessReportPR.Disabled = true;
            }

            if(_ocd.iCountryID != 1)
            {
                btnBusinessReportExperian.Visible = false;
            }

            if(_ocd.bLocalSource)
            {
                //throw new AuthorizationException(GetUnauthorizedForPageMsg());
                if (!SecurityMgr.HasLocalSourceDataAccess(WebUser, _ocd.iRegionID).HasPrivilege)
                {
                    //throw new AuthorizationException(GetUnauthorizedForPageMsg());
                    //Defect 4595 - don't show Access Denied msg but instead informational page that doesn't require login
                    Response.Redirect(PageConstants.LOCAL_SOURCE_MARKETING);
                }

                btnBusinessReportFree.Disabled = true;
                btnBusinessReportFree.Attributes.Add("onClick", "return false;");

                btnBusinessReportExperian.Disabled = true;
                btnBusinessReportExperian.Attributes.Add("onClick", "return false;");

                btnBusinessReportPR.Disabled = true;
                btnBusinessReportPR.Attributes.Add("onClick", "return false;");
            }

            if (WebUser.GetAvailableReports() == 0)
            {
                string szAlertMsg = string.Format(Resources.Global.NotEnoughReportsText2, Configuration.NotEnoughUnitsCSREmail, PageConstants.SERVICE_UNIT_PURCHASE, Resources.Global.PurchaseAdditionalReports);
                btnBusinessReportExperian.Attributes.Add("onClick", "bbAlert(\"" + szAlertMsg + "\"); return false;"); //Defect 4579 show popup msg and link
            }
            else
            {
                if (!WebUser.IsRecentPurchase(Convert.ToInt32(CompanyID), PROD_CODE))
                {
                    // defect 4579 - if _oUser.HideBRPurchaseConfirmationMsg = false, display a pop-up message to the user similar to “After purchasing this report, you will have X remaining.”  
                    // For X, use _oUser.GetAvailableReports() – 1.  Also have a checkbox for “Don’t show this message again”.  If checked, set _oUser.HideBRPurchaseConfirmationMsg = true.  
                    // Display two buttons “Download” and “Cancel”.
                    btnBusinessReportExperian.Attributes.Add("onClick", "return false;");
                    btnBusinessReportExperian.Attributes.Add("data-bs-toggle", "modal");
                    btnBusinessReportExperian.Attributes.Add("data-bs-target", "#pnlPurchBR");
                }

                if (!WebUser.IsRecentPurchase(Convert.ToInt32(CompanyID), PROD_CODE_FREE))
                {
                    btnBusinessReportFree.Attributes.Add("onClick", "return false;");
                    btnBusinessReportFree.Attributes.Add("data-bs-toggle", "modal");
                    btnBusinessReportFree.Attributes.Add("data-bs-target", "#pnlFreeBR");
                }

                litPurchConfMsg.Text = string.Format(Resources.Global.PurchConfMsg2, WebUser.GetAllocatedUnits(), (WebUser.GetAvailableReports() - 1));
                litFreeMsg.Text = Resources.Global.FreeConfMsg;

                ArrayList oParameters = new ArrayList();
                oParameters.Add(new ObjectParameter("prbca_HQID", WebUser.prwu_HQID));
                IDataReader oReader = GetDBAccess().ExecuteReader(SQL_SELECT_BACKGROUND_CHECK_ALLOC_TOTALS, oParameters, CommandBehavior.CloseConnection, null);

                int iAllocation = 0;
                int iRemaining = 0;
                try
                {
                    if (oReader.Read())
                    {
                        iAllocation = oReader.GetInt32(0);
                        iRemaining = oReader.GetInt32(1) - 1;
                    }
                }
                finally
                {
                    oReader.Close();
                }

                if (iRemaining < 0)
                {
                    litPRConfMsg.Text = string.Format(Resources.Global.PublicRecordsConfMsgZeroRemain, iAllocation);
                    btnPRConfEmail.Visible = false;
                }
                else
                {
                    litPRConfMsg.Text = string.Format(Resources.Global.PublicRecordsConfMsg, iAllocation, iRemaining);
                }
            }

            //Public Records - always show popup
            btnBusinessReportPR.Attributes.Add("onClick", "return false;");
            btnBusinessReportPR.Attributes.Add("data-bs-toggle", "modal");
            btnBusinessReportPR.Attributes.Add("data-bs-target", "#pnlPRBR");
        }

        //Show aria menu
        private void ShowMenu(System.Web.UI.HtmlControls.HtmlGenericControl control)
        {
            control.Attributes["class"] = control.Attributes["class"] + " show";
        }

        private void SelectMenu(System.Web.UI.HtmlControls.HtmlButton btn)
        {
            btn.Attributes["class"] = btn.Attributes["class"] + " selected";
        }

        protected void PopulateSideBar()
        {
            //Links
            hlCompanyProfile.NavigateUrl = "~/" + string.Format(PageConstants.COMPANY, CompanyID);
            hlContacts.NavigateUrl = "~/" + string.Format(PageConstants.COMPANY_CONTACTS_BBOS9, CompanyID);
            hlARReports.NavigateUrl = "~/" + string.Format(PageConstants.COMPANY_AR_REPORTS_BBOS9, CompanyID);
            hlClaimsActivityReport.NavigateUrl = "~/" + string.Format(PageConstants.COMPANY_CLAIMS_ACTIVITY_BBOS9, CompanyID);
            hlBranchesAffiliations.NavigateUrl = "~/" + string.Format(PageConstants.COMPANY_BRANCHES_BBOS9, CompanyID);
            hlNewsArticles.NavigateUrl = "~/" + string.Format(PageConstants.COMPANY_NEWS_BBOS9, CompanyID);
            hlCompanyUpdates.NavigateUrl = "~/" + string.Format(PageConstants.COMPANY_UPDATES_BBOS9, CompanyID);
            hlNotes.NavigateUrl = "~/" + string.Format(PageConstants.COMPANY_NOTES_BBOS9, CompanyID);
            hlChainStoreGuide.NavigateUrl = "~/" + string.Format(PageConstants.COMPANY_CSG_BBOS9, CompanyID);

            // Only display the "Newly Listed" icon if the
            // listed date is within the configured threshold.
            //Check delisted first
            if (_ocd.dtDelistedDate != DateTime.MinValue
                && (_ocd.szListingStatus == "N3" ||
                    _ocd.szListingStatus == "N4" ||
                    _ocd.szListingStatus == "N5" ||
                    _ocd.szListingStatus == "N6"))
            {
                TimeSpan oTS = DateTime.Now.Subtract(_ocd.dtDelistedDate);
                int iDays = oTS.Days + 1;
                if (iDays < Configuration.CompanyLastChangeThreshold)
                {
                    litListedDate.Text = string.Format(Resources.Global.DeListedInLastMsg, iDays);
                    spnListedDate.Visible = true;
                }
            }
            else if (_ocd.dtListedDate != DateTime.MinValue)
            {
                TimeSpan oDiff = DateTime.Today - _ocd.dtListedDate;
                if (oDiff.Days <= Configuration.NewListingDaysThreshold)
                {
                    spnListedDate.Visible = true;

                    if (_ocd.szListingStatus == "N3" ||
                        _ocd.szListingStatus == "N4" ||
                        _ocd.szListingStatus == "N5" ||
                        _ocd.szListingStatus == "N6")
                    {
                        litListedDate.Text = string.Format(Resources.Global.DeListedInLastMsg, oDiff.Days + 1);
                    }
                    else if(_ocd.szListingStatus == "LUV")
                    {
                        litListedDate.Text = string.Format(Resources.Global.PendingListingMsg, oDiff.Days + 1);

                    }
                    else
                    {
                        litListedDate.Text = string.Format(Resources.Global.ListedInLastMsg, oDiff.Days + 1);
                    }
                }
            }

            if (_ocd.bHasNewClaimActivity)
            {
                spnNewClaim.Visible = true;
                litNewClaim.Text = Resources.Global.NewClaimReported;
            }

            if (_ocd.dtLastChanged > DateTime.MinValue)
            {
                TimeSpan oTS = DateTime.Now.Subtract(_ocd.dtLastChanged);
                int iDays = oTS.Days + 1;
                if (iDays < Configuration.CompanyLastChangeThreshold)
                {
                    spnLastUpdated.Visible = true;
                    litLastUpdated.Text = string.Format(Resources.Global.CompanyChangedMsg, iDays);
                }
            }

            //UserNote Count for Badge
            NoteSearchCriteria searchCriteria = new NoteSearchCriteria();
            searchCriteria.WebUser = WebUser;
            searchCriteria.AssociatedID = Convert.ToInt32(CompanyID);
            searchCriteria.AssociatedType = "C";
            IBusinessObjectSet os = (IBusinessObjectSet)new PRWebUserNoteMgr(GetLogger(), WebUser).Search(searchCriteria);
            if (os.Count > 0)
            {
                spnNotesBadge.Visible = true;
                litNotesBadge.Text = os.Count.ToString();
            }

            //Visibility
            if (_ocd.bHasCSG)
            {
                if (WebUser.HasPrivilege(SecurityMgr.Privilege.CompanyDetailsChainStoreGuidePage).HasPrivilege)
                    hlChainStoreGuide.Visible = true;
            }

            ucCustomData.WebUser = WebUser;
            ucCustomData.companyID = CompanyID;

            btnUpdateCustomData.Disabled = ucCustomData.EditButtonDisabled;
            btnUpdateCustomData.Visible = ucCustomData.EditButtonVisible;

            ucCustomData.Visible = false;
        }

        protected void btnRequestTradingAssistance_ServerClick(object sender, EventArgs e)
        {
            Session["RespondentCompanyID"] = CompanyID;
            Response.Redirect(PageConstants.SPECIAL_SERVICES);
        }

        /// <summary>
        /// Apply security to the various screen components
        /// based on the current user's access level and role.
        /// </summary>
        protected void ApplySecurity()
        {
            ucTESLongForm.WebUser = WebUser;
            ucTESLongForm.SubjectCompanyID = CompanyID;

            if (Configuration.ReadOnlyEnabled)
            {
                ucTESLongForm.Enabled = false;
            }
            else
            {
                ucTESLongForm.SetModalTargetControl_Unique(btnRateCompany);

                //Rate Company button on left toolbar
                oPage.ApplySecurity(btnRateCompany, btnRateCompany, SecurityMgr.Privilege.TradeExperienceSurveyPage);
                if ((btnRateCompany.Visible) &&
                    (!btnRateCompany.Disabled))
                {
                    if (!oPage.IsValidTESSubject(WebUser, Convert.ToInt32(CompanyID)))
                    {
                        btnRateCompany.Disabled = true;
                    }
                }
                else
                {
                    btnRateCompany.Disabled = true;
                }
            }

            oPage.ApplySecurity(btnAddToConnectionList, SecurityMgr.Privilege.CompanyEditReferenceListPage);
            PageBase.ApplyReadOnlyCheck(btnRateCompany);
            PageBase.ApplyReadOnlyCheck(btnAddToConnectionList);

            oPage.ApplySecurity(btnAlertAdd, SecurityMgr.Privilege.WatchdogListsPage);
            oPage.ApplySecurity(btnAlertRemove, SecurityMgr.Privilege.WatchdogListsPage);
            oPage.ApplySecurity(hlCompanyUpdates, SecurityMgr.Privilege.CompanyDetailsUpdatesPage);
            oPage.ApplySecurity(hlContacts, SecurityMgr.Privilege.CompanyDetailsContactsPage);
            oPage.ApplySecurity(hlARReports, SecurityMgr.Privilege.CompanyDetailsARReportsPage);
            oPage.ApplySecurity(btnARReports, SecurityMgr.Privilege.CompanyDetailsARReportsPage);
            
        }

        public void RateCompanyButtonClick()
        {
            var f = $"$('{btnRateCompany.ClientID}').click(); alert('hi');";
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "scriptRateCompany", f, true);
        }

        protected void btnAddToConnectionList_ServerClick(object sender, EventArgs e)
        {
            SetRequestParameter("CompanyIDList", CompanyID);
            Response.Redirect(PageConstants.Format(PageConstants.EMCW_REFERENCELIST_ADD + "&Type={0}", "Other"));
        }

        protected void btnAlertAdd_ServerClick(object sender, EventArgs e)
        {
            int iCompanyID = Convert.ToInt32(CompanyID);

            IDbTransaction oTran = GetObjectMgr().BeginTransaction();
            try
            {
                if (!GeneralDataMgr.PRWebUserListDetailRecordExists(_prwucl_WebUserListID, iCompanyID, oTran))
                {
                    // Insert new PRWebUserListDetail record for this company and list
                    GetObjectMgr().AddPRWebUserListDetail(_prwucl_WebUserListID, iCompanyID, _prwucl_WebUserListID, oTran);
                    GetObjectMgr().UpdatePRWebUserList(_prwucl_WebUserListID, oTran);
                }

                oTran.Commit();
            }
            catch
            {
                if (oTran != null)
                {
                    oTran.Rollback();
                }
                throw;
            }

            btnAlertAdd.Visible = false;
            btnAlertRemove.Visible = true;

            Response.Redirect(Request.RawUrl);
        }

        protected void btnAlertRemove_ServerClick(object sender, EventArgs e)
        {
            int iCompanyID = Convert.ToInt32(CompanyID);

            IDbTransaction oTran = GetObjectMgr().BeginTransaction();
            try
            {
                if (GeneralDataMgr.PRWebUserListDetailRecordExists(_prwucl_WebUserListID, iCompanyID, oTran))
                {
                    // Remove PRWebUserDetail Record
                    GetObjectMgr().DeletePRWebUserListDetail(_prwucl_WebUserListID, iCompanyID, oTran);
                    GetObjectMgr().UpdatePRWebUserList(_prwucl_WebUserListID, oTran);
                }

                oTran.Commit();
            }
            catch
            {
                if (oTran != null)
                {
                    oTran.Rollback();
                }
                throw;
            }

            btnAlertAdd.Visible = true;
            btnAlertRemove.Visible = false;

            Response.Redirect(Request.RawUrl);
        }

        private void PopulateButtons()
        {
            if (!GeneralDataMgr.PRWebUserListDetailRecordExists(_prwucl_WebUserListID, Convert.ToInt32(CompanyID), null))
                btnAlertRemove.Visible = false;
            else
                btnAlertAdd.Visible = false;
        }

        private class AUSList
        {
            public int WebUserListID;
            public string Name;
            public int CompanyCount;
        }

        public const string SQL_SELECT_AUS_LIST_BY_WEBUSERID =
           @"SELECT prwucl_WebUserListID, prwucl_Name, COUNT(prwuld_WebUserListDetailID) AS CompanyCount 
                FROM PRWebUserList WITH(NOLOCK)
	            LEFT OUTER JOIN PRWebUserListDetail WITH (NOLOCK) ON prwucl_WebUserListID = prwuld_WebUserListID 
                WHERE prwucl_TypeCode='AUS'
	            AND prwucl_WebUserID={0}
                GROUP BY prwucl_WebUserListID, prwucl_Name";

        private AUSList GetAUSList()
        {
            AUSList oAUSList = new AUSList();
            string szSQL = string.Format(SQL_SELECT_AUS_LIST_BY_WEBUSERID, WebUser.prwu_WebUserID);
            using (IDataReader dr = GetDBAccess().ExecuteReader(szSQL))
            {
                if (dr.Read())
                {
                    oAUSList.WebUserListID = (int)dr["prwucl_WebUserListID"];
                    oAUSList.Name = (string)dr["prwucl_Name"];
                    oAUSList.CompanyCount = (int)dr["CompanyCount"];
                }
            }

            return oAUSList;
        }

        protected void btnAddToWatchdog_ServerClick(object sender, EventArgs e)
        {
            SetRequestParameter("CompanyIDList", CompanyID);
            Response.Redirect(PageConstants.USER_LIST_ADD_TO);
        }

        protected void btnRemoveFromWatchdog2_ServerClick(object sender, EventArgs e)
        {
            displayRemoveFromWatchdogIFrame();
        }

        protected void displayRemoveFromWatchdogIFrame()
        {
            ifrmRemoveFromWatchdog.Attributes.Add("src", "~/CompanyDetailsCategoryRemove.aspx?CompanyID=" + CompanyID);
            mdeRemoveFromWatchdog.Show();
        }

        protected void btnUpdateCustomData_ServerClick(object sender, EventArgs e)
        {
            if (ucCustomData != null)
                ucCustomData.btnEditCustomFields_Click(sender, e);
        }

        /// <summary>
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void EditCustomDataButton_Clicked(object sender, EventArgs e)
        {
            displayIFrame();
        }
        protected void displayIFrame()
        {
            ifrmCustomFieldEdit.Attributes.Add("src", "~/CompanyDetailsCustomFieldEdit.aspx?CompanyID=" + CompanyID);
            ModalPopupExtender2.Show();
        }

        protected void btnPurchConfDownload_Click(object sender, EventArgs e)
        {
            int iRequestID = PurchaseReport(blnFree:false); 

            if (chkDontShowAgain.Checked)
            {
                WebUser.HideBRPurchaseConfirmationMsg = true;
                WebUser.Save();
            }

            DownloadReport(iRequestID, PROD_CODE);
            Session.Remove("EmailPurchases");
        }

        protected void btnPurchConfEmail_Click(object sender, EventArgs e)
        {
            int iRequestID = PurchaseReport(blnFree:false);

            if (chkDontShowAgain.Checked)
            {
                WebUser.HideBRPurchaseConfirmationMsg = true;
                WebUser.Save();
            }

            if (Session["EmailPurchases"] != null)
            {
                List<Report> reports = (List<Report>)Session["EmailPurchases"];
                SendEmailAttachments(reports);
                Session.Remove("EmailPurchases");
            }
        }

        private int PurchaseReport(bool blnFree = true)
        {
            string szProdCode = "";
            List<Report> reports = null;
            reports = new List<Report>();

            // Retrieve the product data required for the payment info objects based on the 
            // report type selected (non-ITA users)
            DataTable dtProductList = oPage.GetProductsByFamily(CODE_PRODUCTFAMILY_MEM_BR, GetCulture(WebUser));
            DataRow[] adrProduct;
            if (blnFree)
                szProdCode = PROD_CODE_FREE;
            else
                szProdCode = PROD_CODE;

            adrProduct = dtProductList.Select("prod_code = '" + szProdCode + "'");

            DataRow drProduct = adrProduct[0];

            int iPerReportPrice = Convert.ToInt32(drProduct["pric_price"]);
            int iProductID = Convert.ToInt32(drProduct["prod_ProductID"]);

            // Make sure we have a "fresh" ServiceUnitPaymentInfo object
            Session["lServiceUnitPaymentInfo"] = null;

            // Create payment info object
            ServiceUnitPaymentInfo oPaymentInfo = new ServiceUnitPaymentInfo();
            oPage.GetServiceUnitPaymentInfo().Add(oPaymentInfo);

            oPaymentInfo.ObjectID = Convert.ToInt32(CompanyID);
            oPaymentInfo.ProductID = iProductID;

            // Do not charge for or include in request any recent purchases                         
            oPaymentInfo.Charge = true;
            oPaymentInfo.IncludeInRequest = true;

            oPaymentInfo.Price = iPerReportPrice;

            reports.Add(new Report(GetReport.BUSINESS_REPORT,
                                    CompanyID,
                                    "0",
                                    szProdCode));

            int iRequestID = oPage.ExecutePurchaseWithUnits(oPage.GetServiceUnitPaymentInfo(),
                1,
                szProdCode, //BR4 or BRF
                "OBR",
                oPage.GetReferer(),
                CompanyID,
                "Company");

            // We didn't have the RequestID when we first built our
            // report list, so add it now.
            foreach (Report report in reports)
            {
                report.RequestID = iRequestID.ToString();
            }

            Session["EmailPurchases"] = reports;

            if (blnFree)
            {
                btnBusinessReportFree.Attributes.Remove("onClick");
                btnBusinessReportFree.Attributes.Remove("data-bs-toggle");
                btnBusinessReportFree.Attributes.Remove("data-bs-target");
            }
            else
            {
                btnBusinessReportExperian.Attributes.Remove("onClick");
                btnBusinessReportExperian.Attributes.Remove("data-bs-toggle");
                btnBusinessReportExperian.Attributes.Remove("data-bs-target");
            }

            WebUser.RefreshRecentPurchases();
            return iRequestID;
        }

        protected void SendEmailAttachments(List<Report> reports)
        {
            ReportEmailer reportEmailer = new ReportEmailer();
            reportEmailer.WebUser = WebUser;
            reportEmailer.Logger = LoggerFactory.GetLogger();
            reportEmailer.IsEligibleForEquifaxData = oPage.IsEligibleForEquifaxData();
            reportEmailer.Email = WebUser.Email;
            reportEmailer.Reports = reports;
            reportEmailer.TemplateFile = Server.MapPath(UIUtils.GetTemplateURL("ReportEmailerBody.htm"));

            Thread newThread = new Thread(reportEmailer.SendEmailAttachments);
            newThread.Start();

            AddUserMessage(string.Format(Resources.Global.BusinessReportEmailedTo, WebUser.Email));
        }

        private void DownloadReport(string szProdCode)
        {
            // Generate the sql required to retrieve the purchased business reports            
            CultureInfo m_UsCulture = new CultureInfo(PageControlBaseCommon.ENGLISH_CULTURE);
            string szThreshold_BR = DateTime.Now.AddHours(0 - Utilities.GetIntConfigValue("RecentPurchasesAvailabilityThreshold", 72)).ToString(m_UsCulture);

            string szSQL_BR = null;
            object[] args_BR = { WebUser.prwu_Culture,
                                WebUser.prwu_HQID,
                                WebUser.prwu_WebUserID,
                                szThreshold_BR,
                                DateTime.Today.AddDays(0 - Configuration.ClaimActivityNewThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss"),
                                DateTime.Today.AddDays(0 - Configuration.ClaimActivityMeritoriousThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss") };

            szSQL_BR = string.Format(Purchases.SQL_GET_BR_REQUESTS, args_BR);
            szSQL_BR += " AND prrc_AssociatedID = " + CompanyID;

            if(szProdCode == PROD_CODE_FREE)
            {
                szSQL_BR.Replace("LIKE 'BR%'", "LIKE 'BRF%'");
            }

            // Execute search so we can get RequestID with which to generate report
            using (IDataReader drReport = GetDBAccess().ExecuteReader(szSQL_BR, CommandBehavior.CloseConnection))
            {
                if (drReport.Read())
                {
                    int iRequestID = Convert.ToInt32(drReport["prreq_RequestID"]);
                    DownloadReport(iRequestID, szProdCode);
                }
            }
        }

        private void DownloadReport(int iRequestID, string szProdCode)
        {
            //ex: https://azqa.apps.bluebookservices.com/bbos/GetReport.aspx?ReportType=BR&CompanyID=102030&Level=4&RequestID=295733
            string szReportUrl = string.Format("GetReport.aspx?ReportType={0}&CompanyID={1}&Level=4&RequestID={2}", szProdCode, CompanyID, iRequestID);

            //Download the previously-purchased report to the browser
            Response.Redirect(szReportUrl);
        }

        protected void btnBusinessReportFree_ServerClick(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(CompanyID))
            {
                if (WebUser.IsRecentPurchase(Convert.ToInt32(CompanyID), PROD_CODE_FREE))
                    DownloadReport(PROD_CODE_FREE);
                else
                {
                    PurchaseReport(blnFree:true);
                    DownloadReport(PROD_CODE_FREE);
                }
            }
        }

        protected void btnBusinessReportExperian_ServerClick(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(CompanyID))
            {
                if (WebUser.IsRecentPurchase(Convert.ToInt32(CompanyID), PROD_CODE))
                    DownloadReport(PROD_CODE);
                else
                {
                    PurchaseReport(blnFree:false);
                    DownloadReport(PROD_CODE);
                }
            }
        }

        protected void btnFreeBRDownload_Click(object sender, EventArgs e)
        {
            int iRequestID = PurchaseReport(blnFree: true);

            if (chkDontShowAgain.Checked)
            {
                WebUser.HideBRPurchaseConfirmationMsg = true;
                WebUser.Save();
            }

            DownloadReport(iRequestID, PROD_CODE_FREE);
            Session.Remove("EmailPurchases");
        }

        protected void btnFreeBREmail_Click(object sender, EventArgs e)
        {
            int iRequestID = PurchaseReport(blnFree: true);

            if (chkDontShowAgain.Checked)
            {
                WebUser.HideBRPurchaseConfirmationMsg = true;
                WebUser.Save();
            }

            if (Session["EmailPurchases"] != null)
            {
                List<Report> reports = (List<Report>)Session["EmailPurchases"];
                SendEmailAttachments(reports);
                Session.Remove("EmailPurchases");
            }
        }

        protected void btnPRConfEmail_Click(object sender, EventArgs e)
        {
            int iRequestID = PurchaseReportPlusPublicRecordsSupplement();
        }
        private int PurchaseReportPlusPublicRecordsSupplement()
        {
            GeneralDataMgr oGeneralDataMgr = new GeneralDataMgr(GetLogger(), WebUser);
            oGeneralDataMgr.User = WebUser;

            int iRequestID;
            IDbTransaction oTran = oGeneralDataMgr.BeginTransaction();
            try
            {
                iRequestID = oGeneralDataMgr.CreateBackgroundCheckRequest(CompanyID, "P", oTran);

                //Task
                int iAssignedToUserID = Utilities.GetIntConfigValue("ReportPublicRecordSupplementUserID", 12); //default to Bill Z
                string szNote = Utilities.GetConfigValue("ReportPublicRecordSupplementTaskNote", "Background check was requested by {0} on {1}.");
                szNote = string.Format(szNote, WebUser.prwu_CompanyName, GetOcd().szCompanyName);

                oGeneralDataMgr.CreateTask(iAssignedToUserID, "Pending", szNote, "R", "BGC", oTran); //Rating / Background Check task

                oGeneralDataMgr.SendEmail_Text(GetObjectMgr().GetPRCoUserEmail(iAssignedToUserID, oTran),
                        Utilities.GetConfigValue("PublicRecordsRequestEmailSubject", "Public Records Request"),
                        szNote,
                        "Company.aspx",
                        oTran);

                //Consume one background check allocation unit
                ArrayList oParameters = new ArrayList();
                oParameters.Add(new ObjectParameter("CompanyID", WebUser.prwu_BBID));
                oParameters.Add(new ObjectParameter("CRMUserID", null));
                GetDBAccess().ExecuteNonQuery("usp_ConsumeBackgroundCheckUnits", oParameters, oTran, CommandType.StoredProcedure);

                oTran.Commit();
            }
            catch
            {
                if(oTran != null)
                {
                    oTran.Rollback();
                }
                throw;
            }

            btnBusinessReportPR.Attributes.Remove("onClick");
            btnBusinessReportPR.Attributes.Remove("data-bs-toggle");
            btnBusinessReportPR.Attributes.Remove("data-bs-target");

            AddUserMessage(Resources.Global.BusinessReportPlusPublicRecordsSupplementRequestSent);

            //WebUser.RefreshRecentPurchases();
            return iRequestID;
        }

        protected const string SQL_SELECT_BACKGROUND_CHECK_ALLOC_TOTALS =
            @"SELECT ISNULL(SUM(prbca_Allocation),0), ISNULL(SUM(prbca_Remaining), 0)
                FROM PRBackgroundCheckAllocation
               WHERE prbca_HQID=@prbca_HQID";
    }
}