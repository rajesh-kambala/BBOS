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

 ClassName: CompanyDetailsSummary
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Threading;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Displays the basic company data and listing.
    /// </summary>
    public partial class CompanyDetailsSummary : CompanyDetailsBase
    {
        protected const string SQL_SELECT_COMPANY =
            @"SELECT TOP 1 *
                FROM vPRBBOSCompanyLocalized
               WHERE comp_CompanyID=@comp_CompanyID
               AND prwu_WebUserID = @prwu_WebUserID ";

        public const string SQL_SELECT_AUS_LIST_BY_WEBUSERID =
            @"SELECT prwucl_WebUserListID, prwucl_Name, COUNT(prwuld_WebUserListDetailID) AS CompanyCount 
                FROM PRWebUserList WITH(NOLOCK)
	            LEFT OUTER JOIN PRWebUserListDetail WITH (NOLOCK) ON prwucl_WebUserListID = prwuld_WebUserListID 
                WHERE prwucl_TypeCode='AUS'
	            AND prwucl_WebUserID={0}
                GROUP BY prwucl_WebUserListID, prwucl_Name";

        protected int _prwucl_WebUserListID;

        

        string companyType = null;
        protected int _categoryCount = 0;
        protected int _categoryIndex = 0;
        protected CompanyData _ocd;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            // Set page title, sub-title
            SetPageTitle(Resources.Global.CompanyDetails, Resources.Global.ListingSummary, true);
            
            _prwucl_WebUserListID = GetAUSList().WebUserListID;

            // Add company submenu to this page
            SetSubmenu("btnCompanyDetailsListing");

            ucCustomData.EditCustomDataButtonClicked += new EventHandler(EditCustomDataButton_Clicked);

            //Get cached company data
            _ocd = GetCompanyDataFromSession();

            if (!IsPostBack)
            {
                ReDirectToCompanyASPX();

                hidCompanyID.Text = GetRequestParameter("CompanyID", true, true);
                Session["ReturnURL"] = PageConstants.Format(PageConstants.COMPANY_DETAILS_SUMMARY, hidCompanyID.Text);
                
                PopulateForm();

                ApplySecurity();
                if (companyType == "B")
                {
                    btnAddToConnectionList.Visible = false;
                }
            }

            PopulateButtons();

            if (_oUser.IsLimitado)
                Response.Redirect(string.Format(PageConstants.LIMITADO_COMPANY, hidCompanyID.Text));

            //Set user controls
            ucPinnedNote.WebUser = _oUser;
            ucPinnedNote.companyID = UIUtils.GetInt(hidCompanyID.Text);

            ucLocalSource.WebUser = _oUser;
            ucLocalSource.companyID = UIUtils.GetInt(hidCompanyID.Text);

            ucCompanyDetails.WebUser = _oUser;
            ucCompanyDetails.companyID = hidCompanyID.Text;

            ucCompanyListing.WebUser = _oUser;
            ucCompanyListing.companyID = hidCompanyID.Text;

            ucPerformanceIndicators.WebUser = _oUser;
            ucPerformanceIndicators.HQID = hidCompanyID.Text;

            ucTradeAssociation.WebUser = _oUser;
            ucTradeAssociation.companyID = hidCompanyID.Text;

            ucNewsArticles.WebUser = _oUser;
            ucNewsArticles.companyID = hidCompanyID.Text;
            ucNewsArticles.Title = Resources.Global.NewsArticles; //"News/Articles";
            ucNewsArticles.Style = NewsArticles.NewsType.GENERAL_NEWS_SUMMARY;
            ucNewsArticles.PopulateNewsArticles();

            if (ucNewsArticles.NewsCount > 0)
                ucNewsArticles.Visible = _oUser.HasPrivilege(SecurityMgr.Privilege.CompanyDetailsNewsPage).Enabled;
            else
                ucNewsArticles.Visible = false;

            PopulateCategories();

            ucCustomData.WebUser = _oUser;
            ucCustomData.companyID = hidCompanyID.Text;

            ucNotes.WebUser = _oUser;
            ucNotes.companyID = hidCompanyID.Text;

            ucCompanyDetailsHeader.WebUser = _oUser;

            if (_oUser.prwu_Culture == PageBase.SPANISH_CULTURE)
                btnPurchConfEmail.Width = new Unit("250px");
        }

        protected void ReDirectToCompanyASPX()
        {
            //Redirect CompanyDetailsSummary.aspx to Company.aspx if not lumber
            if(_ocd.szIndustryType != GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                Response.Redirect(Request.Url.AbsoluteUri.ToLower().Replace("companydetailssummary.aspx", "Company.aspx"));
            }
        }

        protected const string SQL_CATEGORIES =
            @"SELECT prwucl_CategoryIcon, prwucl_Name, prwucl_Pinned
                 FROM PRWebUserList WITH (NOLOCK)
                      INNER JOIN PRWebUserListDetail WITH (NOLOCK) ON prwucl_WebUserListID = prwuld_WebUserListID
                WHERE ((prwucl_HQID = @HQID AND prwucl_IsPrivate IS NULL) OR (prwucl_WebUserID=@WebUserID AND prwucl_IsPrivate = 'Y')) 
                  AND prwuld_AssociatedID = @CompanyID
             ORDER BY prwucl_Name";

        protected void PopulateCategories()
        {
            if (!_oUser.HasPrivilege(SecurityMgr.Privilege.WatchdogListsPage).HasPrivilege)
            {
                Categories.Visible = false;
                return;
            }

            IList parmList = new ArrayList();
            parmList.Add(new ObjectParameter("HQID", _oUser.prwu_HQID));
            parmList.Add(new ObjectParameter("WebUserID", _oUser.prwu_WebUserID));
            parmList.Add(new ObjectParameter("CompanyID", Convert.ToInt32(hidCompanyID.Text)));

            repCategories.DataSource = GetDBAccess().ExecuteReader(SQL_CATEGORIES, parmList, CommandBehavior.CloseConnection, null);
            repCategories.DataBind();

            _categoryCount = repCategories.Items.Count;
        }

        protected void btnAddToWatchdogOnClick(object sender, EventArgs e)
        {
            SetRequestParameter("CompanyIDList", hidCompanyID.Text);
            Response.Redirect(PageConstants.USER_LIST_ADD_TO);
        }

        protected void btnRemoveCategory_Click(object sender, EventArgs e)
        {
            displayRemoveCategoryIFrame();
        }

        protected void displayRemoveCategoryIFrame()
        {
            ifrmCategoryRemove.Attributes.Add("src", "~/CompanyDetailsCategoryRemove.aspx?CompanyID=" + hidCompanyID.Text);
            mdeCategoryRemove.Show();
        }

        /// <summary>
        /// Populates the form controls for the specified
        /// company
        /// </summary>
        protected void PopulateForm()
        {
            int iRatingID = 0;
            int iCompanyPayIndicatorID = 0;
            int hqID = 0;
            int regionID = 0;
            bool suppressLinkedInWidget = false;
            bool isLocalSource = false;

            string industryType = null;

            int companyID = Convert.ToInt32(hidCompanyID.Text);
            string preparedName = null;



            ArrayList oParameters = new ArrayList();

            oParameters.Add(new ObjectParameter("comp_CompanyID", hidCompanyID.Text));
            oParameters.Add(new ObjectParameter("prwu_WebUserID", _oUser.prwu_WebUserID));

            using (IDataReader oReader = GetDBAccess().ExecuteReader(SQL_SELECT_COMPANY, oParameters, CommandBehavior.CloseConnection, null))
            {
                oReader.Read();

                isLocalSource = UIUtils.GetBool(GetDBAccess().GetString(oReader, "comp_PRLocalSource"));
                regionID = GetDBAccess().GetInt32(oReader, "prst_StateID");

                industryType = GetDBAccess().GetString(oReader, "comp_PRIndustryType");
                preparedName = GetDBAccess().GetString(oReader, "PreparedName");
                companyType = GetDBAccess().GetString(oReader, "comp_PRType");

                hqID = GetDBAccess().GetInt32(oReader, "comp_PRHQID");

                TESLongForm.SubjectIndustryType = industryType;

                iRatingID = GetDBAccess().GetInt32(oReader, "prra_RatingID");
                iCompanyPayIndicatorID = GetDBAccess().GetInt32(oReader, "prcpi_CompanyPayIndicatorID");
                suppressLinkedInWidget = GetObjectMgr().TranslateFromCRMBool(oReader["comp_PRHideLinkedInWidget"]);


                if (industryType != GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                {
                    hidRatingID.Text = iRatingID.ToString();
                }
                else
                {
                }

                if (industryType == GeneralDataMgr.INDUSTRY_TYPE_SUPPLY)
                {
                    btnBusinessReport.Enabled = false;
                }
            }

            if (isLocalSource)
            {
                //throw new AuthorizationException(GetUnauthorizedForPageMsg());
                if (!SecurityMgr.HasLocalSourceDataAccess(_oUser, regionID).HasPrivilege)
                {
                    //throw new AuthorizationException(GetUnauthorizedForPageMsg());
                    //Defect 4595 - don't show Access Denied msg but instead informational page that doesn't require login
                    Response.Redirect(PageConstants.LOCAL_SOURCE_MARKETING);
                }
                
                btnBusinessReport.Enabled = false;
                btnBusinessReport.Attributes.Add("onClick", "return false;");
                ucCompanyDetailsHeaderMeister.MeisterVisible = true;
            }

            GetAddressForMap();

            if (_oUser.GetAvailableReports() == 0)
            {
                string szAlertMsg = string.Format(Resources.Global.NotEnoughReportsText2, Configuration.NotEnoughUnitsCSREmail, PageConstants.SERVICE_UNIT_PURCHASE, Resources.Global.PurchaseAdditionalReports);
                btnBusinessReport.Attributes.Add("onClick", "bbAlert(\"" + szAlertMsg + "\"); return false;"); //Defect 4579 show popup msg and link
            }
            else
            {
                if (!_oUser.IsRecentPurchase(Convert.ToInt32(hidCompanyID.Text), PROD_CODE) && !_oUser.HideBRPurchaseConfirmationMsg)
                {
                    // defect 4579 - if _oUser.HideBRPurchaseConfirmationMsg = false, display a pop-up message to the user similar to “After purchasing this report, you will have X remaining.”  
                    // For X, use _oUser.GetAvailableReports() – 1.  Also have a checkbox for “Don’t show this message again”.  If checked, set _oUser.HideBRPurchaseConfirmationMsg = true.  
                    // Display two buttons “Download” and “Cancel”.
                    btnBusinessReport.Attributes.Add("onClick", "return false;");
                    btnBusinessReport.Attributes.Add("data-bs-toggle", "modal");
                    btnBusinessReport.Attributes.Add("data-bs-target", "#pnlPurchConf");
                }

                litPurchConfMsg.Text = string.Format(Resources.Global.PurchConfMsg, (_oUser.GetAvailableReports()-1));
            }
        }

        private void PopulateButtons()
        {
            if (!GeneralDataMgr.PRWebUserListDetailRecordExists(_prwucl_WebUserListID, Convert.ToInt32(hidCompanyID.Text), null))
                btnAlertRemove.Visible = false;
            else
                btnAlertAdd.Visible = false;
        }

        /// <summary>
        /// Handles the on click event for each of the submenu items.  The
        /// current company search criteria object will be stored and the 
        /// user will be redirected accordingly.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void EditCustomDataButton_Clicked(object sender, EventArgs e)
        {
            displayIFrame();
        }
        protected void displayIFrame()
        {
            ifrmCustomFieldEdit.Attributes.Add("src", "~/CompanyDetailsCustomFieldEdit.aspx?CompanyID=" + hidCompanyID.Text);
            ModalPopupExtender2.Show();
        }

        /// <summary>
        /// We are re-using the "ufn_IsAddressValidForRadius" function
        /// </summary>
        protected const string SQL_SELECT_ADDRESS_FOR_MAP =
            @"SELECT RTRIM(addr_Address1), RTRIM(addr_Address2), prci_City, ISNULL(prst_Abbreviation, prst_State) As State, addr_PostCode, prcn_Country 
                FROM Address WITH (NOLOCK) 
                     INNER JOIN Address_Link WITH (NOLOCK) on addr_AddressID = adli_AddressID 
                     INNER JOIN vPRLocation ON addr_PRCityID = prci_CityID 
               WHERE adli_Type IN ('PH', 'S', 'M', 'W', 'I', 'O') 
                 AND adli_CompanyID={0} 
                 AND dbo.ufn_IsAddressValidForRadius(adli_CompanyID, addr_AddressID) = 'Y';";
        protected void GetAddressForMap()
        {
            string szSQL = string.Format(SQL_SELECT_ADDRESS_FOR_MAP, hidCompanyID.Text);
            IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection);
            try
            {
                if (oReader.Read())
                {
                    string[] args = {GetDBAccess().GetString(oReader, 0),
                                     GetDBAccess().GetString(oReader, 1),
                                     GetDBAccess().GetString(oReader, 2),
                                     GetDBAccess().GetString(oReader, 3),
                                     GetDBAccess().GetString(oReader, 4),
                                     GetDBAccess().GetString(oReader, 5)};

                    string szMapURL = string.Format(Utilities.GetConfigValue("MapURL"), args);

                    hlViewMap.OnClientClick = "javascript:openBBOSWindow('" + szMapURL + "', width=600,height=600);";
                }
                else
                {
                    hlViewMap.Enabled = false;
                }
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }
        }

        /// <summary>
        /// Apply security to the various screen components
        /// based on the current user's access level and role.
        /// </summary>
        protected void ApplySecurity()
        {
            TESLongForm.WebUser = _oUser;
            TESLongForm.SubjectCompanyID = hidCompanyID.Text;

            if (Configuration.ReadOnlyEnabled)
            {
                TESLongForm.Enabled = false;
            }
            else
            {
                TESLongForm.SetModalTargetControl(btnRateCompany);

                ApplySecurity(btnRateCompany, btnRateCompany, SecurityMgr.Privilege.TradeExperienceSurveyPage);
                if ((btnRateCompany.Visible) &&
                    (btnRateCompany.Enabled))
                {

                    if (!IsValidTESSubject(_oUser, Convert.ToInt32(hidCompanyID.Text)))
                    {
                        btnRateCompany.Enabled = false;
                        TESLongForm.Enabled = false;
                    }
                }
                else
                {
                    TESLongForm.Enabled = false;
                }
            }

            ApplySecurity(btnAddToConnectionList, SecurityMgr.Privilege.CompanyEditReferenceListPage);
            
            ApplySecurity(btnAlertAdd, SecurityMgr.Privilege.WatchdogListsPage);
            ApplySecurity(btnAlertRemove, SecurityMgr.Privilege.WatchdogListsPage);
            ApplySecurity(btnManageAlerts, SecurityMgr.Privilege.WatchdogListsPage);

            ApplySecurity(btnGetTradingAssistance, SecurityMgr.Privilege.TradingAssistancePage);

            btnEditCompany.Visible = false;
            if (_oUser.prwu_BBID == Convert.ToInt32(hidCompanyID.Text))
            {
                ApplySecurity(btnEditCompany, SecurityMgr.Privilege.CompanyEditListingPage);
            }

            ApplySecurity(btnBusinessReport, SecurityMgr.Privilege.BusinessReportPurchase, _oUser.IsLimitado);

            ApplySecurity(hlViewMap, SecurityMgr.Privilege.ViewMap);

            ApplyReadOnlyCheck(btnRateCompany);
            ApplyReadOnlyCheck(btnBusinessReport);
            ApplyReadOnlyCheck(btnGetTradingAssistance);
            ApplyReadOnlyCheck(btnEditCompany);
            ApplyReadOnlyCheck(btnAddToConnectionList);
        }

        protected void btnDownloadListingOnClick(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.Format(PageConstants.GET_REPORT, GetReport.COMPANY_LISTING_REPORT) + "&CompanyID=" + hidCompanyID.Text + "&IncludeBranches=" + ucCompanyListing.IncludeBranches);
        }

        protected void btnBusinessReportOnClick(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(hidCompanyID.Text))
            {
                if (_oUser.IsRecentPurchase(Convert.ToInt32(hidCompanyID.Text), PROD_CODE))
                    DownloadReport();
                else
                {
                    PurchaseReport();
                    DownloadReport();
                }
            }
        }

        private void DownloadReport()
        {
            // Generate the sql required to retrieve the purchased business reports            
            CultureInfo m_UsCulture = new CultureInfo(ENGLISH_CULTURE);
            string szThreshold_BR = DateTime.Now.AddHours(0 - Utilities.GetIntConfigValue("RecentPurchasesAvailabilityThreshold", 72)).ToString(m_UsCulture);

            string szSQL_BR = null;
            object[] args_BR = { _oUser.prwu_Culture,
                                _oUser.prwu_HQID,
                                _oUser.prwu_WebUserID,
                                szThreshold_BR,
                                DateTime.Today.AddDays(0 - Configuration.ClaimActivityNewThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss"),
                                DateTime.Today.AddDays(0 - Configuration.ClaimActivityMeritoriousThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss") };

            szSQL_BR = string.Format(Purchases.SQL_GET_BR_REQUESTS, args_BR);
            szSQL_BR += " AND prrc_AssociatedID = " + hidCompanyID.Text;

            // Execute search so we can get RequestID with which to generate report
            using (IDataReader drReport = GetDBAccess().ExecuteReader(szSQL_BR, CommandBehavior.CloseConnection))
            {
                if (drReport.Read())
                {
                    int iRequestID = Convert.ToInt32(drReport["prreq_RequestID"]);
                    DownloadReport(iRequestID);
                }
            }
        }

        private void DownloadReport(int iRequestID)
        {
            //ex: https://azqa.apps.bluebookservices.com/bbos/GetReport.aspx?ReportType=BR&CompanyID=102030&Level=4&RequestID=295733
            string szReportUrl = string.Format("GetReport.aspx?ReportType=BR&CompanyID={0}&Level=4&RequestID={1}", hidCompanyID.Text, iRequestID);

            //Download the previously-purchased report to the browser
            Response.Redirect(szReportUrl);
        }

        protected void btnGetTradingAssistanceOnClick(object sender, EventArgs e)
        {
            Session["RespondentCompanyID"] = hidCompanyID.Text;
            Response.Redirect(PageConstants.SPECIAL_SERVICES);
        }

        protected void btnAnalyzeCompanies_Click(object sender, EventArgs e)
        {
            SetRequestParameter("CompanyIDList", hidCompanyID.Text);
            Response.Redirect(PageConstants.COMPANY_ANALYSIS);
        }

        protected void btnEditCompany_Click(object sender, EventArgs eX)
        {
            Response.Redirect(PageConstants.EMCW_COMPANY_LISTING);
        }

        /// <summary>
        /// Handles the Add To Connection List on click event.  Takes the user to the EMCW_ConnectionListAdd.aspx page 
        /// specifying this company.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnAddToConnectionListOnClick(object sender, EventArgs e)
        {
            SetRequestParameter("CompanyIDList", hidCompanyID.Text);
            Response.Redirect(PageConstants.Format(PageConstants.EMCW_REFERENCELIST_ADD + "&Type={0}", "Other"));
        }

        protected override string GetCompanyID()
        {
            if (IsPostBack)
            {
                return hidCompanyID.Text;
            }
            else
            {
                return GetRequestParameter("CompanyID");
            }
        }

        protected override CompanyDetailsHeader GetCompanyDetailsHeader()
        {
            return ucCompanyDetailsHeader;
        }

        public override bool EnableJSClientIDTranslation()
        {
            return true;
        }

        override protected bool IsAuthorizedForPage()
        {
            return _oUser.IsLimitado || _oUser.HasPrivilege(SecurityMgr.Privilege.CompanyDetailsListingPage).Enabled;
        }

        protected void hlViewMap_Click(object sender, EventArgs e)
        {
            Response.Redirect(Request.RawUrl);
        }

        protected void btnPurchConfDownload_Click(object sender, EventArgs e)
        {
            int iRequestID = PurchaseReport();

            if (chkDontShowAgain.Checked)
            {
                _oUser.HideBRPurchaseConfirmationMsg = true;
                _oUser.Save();
            }

            DownloadReport(iRequestID);
            Session.Remove("EmailPurchases");
        }

        protected void btnPurchConfEmail_Click(object sender, EventArgs e)
        {
            int iRequestID = PurchaseReport();

            if (chkDontShowAgain.Checked)
            {
                _oUser.HideBRPurchaseConfirmationMsg = true;
                _oUser.Save();
            }

            if (Session["EmailPurchases"] != null)
            {
                List<Report> reports = (List<Report>)Session["EmailPurchases"];
                SendEmailAttchments(reports);
                Session.Remove("EmailPurchases");
            }
        }

        private int PurchaseReport()
        {
            List<Report> reports = null;
            reports = new List<Report>();

            // Retrieve the product data required for the payment info objects based on the 
            // report type selected (non-ITA users)
            DataTable dtProductList = GetProductsByFamily(CODE_PRODUCTFAMILY_MEM_BR, GetCulture(_oUser));
            DataRow[] adrProduct = dtProductList.Select("prod_code = '" + PROD_CODE + "'");
            DataRow drProduct = adrProduct[0];

            int iPerReportPrice = Convert.ToInt32(drProduct["pric_price"]);
            int iProductID = Convert.ToInt32(drProduct["prod_ProductID"]);

            // Make sure we have a "fresh" ServiceUnitPaymentInfo object
            Session["lServiceUnitPaymentInfo"] = null;

            // Create payment info object
            ServiceUnitPaymentInfo oPaymentInfo = new ServiceUnitPaymentInfo();
            GetServiceUnitPaymentInfo().Add(oPaymentInfo);

            oPaymentInfo.ObjectID = Convert.ToInt32(hidCompanyID.Text);
            oPaymentInfo.ProductID = iProductID;

            // Do not charge for or include in request any recent purchases                         
            oPaymentInfo.Charge = true;
            oPaymentInfo.IncludeInRequest = true;

            oPaymentInfo.Price = iPerReportPrice;

            reports.Add(new Report(GetReport.BUSINESS_REPORT,
                                    hidCompanyID.Text,
                                    "0",
                                    PROD_CODE));

            int iRequestID = ExecutePurchaseWithUnits(GetServiceUnitPaymentInfo(),
                1,
                PROD_CODE, //BR4
                "OBR",
                GetReferer(),
                hidCompanyID.Text,
                "Company"); //Request.QueryString["SourceEntityType"]);


            // We didn't have the RequestID when we first built our
            // report list, so add it now.
            foreach (Report report in reports)
            {
                report.RequestID = iRequestID.ToString();
            }

            Session["EmailPurchases"] = reports;

            btnBusinessReport.Attributes.Remove("onClick");
            btnBusinessReport.Attributes.Remove("data-bs-toggle");
            btnBusinessReport.Attributes.Remove("data-bs-target");

            _oUser.RefreshRecentPurchases();
            return iRequestID;
        }

        protected void SendEmailAttchments(List<Report> reports)
        {
            ReportEmailer reportEmailer = new ReportEmailer();
            reportEmailer.WebUser = _oUser;
            reportEmailer.Logger = _oLogger;
            reportEmailer.IsEligibleForEquifaxData = IsEligibleForEquifaxData();
            reportEmailer.Email = _oUser.Email;
            reportEmailer.Reports = reports;
            reportEmailer.TemplateFile = Server.MapPath(UIUtils.GetTemplateURL("ReportEmailerBody.htm"));
            //reportEmailer.ZipFiles = cbAttachmentZipFiles.Checked;

            Thread newThread = new Thread(reportEmailer.SendEmailAttachments);
            newThread.Start();

            AddUserMessage(string.Format(Resources.Global.BusinessReportEmailedTo, _oUser.Email));
        }

        /// <summary>
        /// Ensures the list of ServiceUnitPaymentInfo objects are stored
        /// in the session.
        /// </summary>
        /// <returns></returns>
        override protected bool PersistPaymentInfo()
        {
            return true;
        }

        private class AUSList
        {
            public int WebUserListID;
            public string Name;
            public int CompanyCount;
        }

        private AUSList GetAUSList()
        {
            AUSList oAUSList = new AUSList();
            string szSQL = string.Format(SQL_SELECT_AUS_LIST_BY_WEBUSERID, _oUser.prwu_WebUserID);
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

        protected void btnAlertAdd_Click(object sender, EventArgs e)
        {
            int iCompanyID = Convert.ToInt32(hidCompanyID.Text);

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

        protected void btnAlertRemove_Click(object sender, EventArgs e)
        {
            int iCompanyID = Convert.ToInt32(hidCompanyID.Text);

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

        protected void btnManageAlerts_Click(object sender, EventArgs e)
        {
            SetReturnURL(Request.RawUrl);
            Response.Redirect(PageConstants.Format(PageConstants.USER_LIST, _prwucl_WebUserListID));
        }
    }
}