/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2023

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: BusinessReportConfirmSelections
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using PRCo.EBB.Util;
using TSI.Arch;
using TSI.DataAccess;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;
using Stripe;
using System.Collections.Specialized;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This page allows members and non-members to confirm the companies selected and review pricing before
    /// purchasing the report.
    /// 
    /// The business report name, descriptions, and prices will be listed on the page based on the users 
    /// member or non-member status.  If the user is a non-member, only levels 1-3 are available.  If the user
    /// is a member, levels 3 and 4 are available.
    /// 
    /// Members users will see the price in units, while non-member users will see the price in currency.
    /// 
    /// Level 4 business reports are only available on companies that have a comp_PRInvestigationGroup = "A" and 
    /// a prbs_ConfidenceLevel > 5.  
    /// </summary>
    public partial class BusinessReportConfirmSelections : PageBase
    {
        // Maps to the prsuu_UsageTypeCode for Online Business Report
        private const string USAGE_TYPE = "OBR";

        protected decimal dTotal = 0M;

        //Credit card fields
        protected int _iPaymentID = 0;
        protected int _iAvailableUnits = 0;
        protected int _iRemainingUnits = 0;

        /// <summary>
        /// Calls page functions required to build and process this page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            // Set page title
            SetPageTitle(String.Format(Resources.Global.ConfirmSelections, Resources.Global.BusinessReport));

            // Setup formatted page text
            litHeaderText.Text = string.Format(Resources.Global.ConfirmSelectionsHeaderText, Resources.Global.BusinessReport);
            litSelectText.Text = string.Format(Resources.Global.SelectTheType, Resources.Global.BusinessReport) + ":";
            //litFooterText.Text = String.Format(Resources.Global.BusinessReportFooterText, PageConstants.MEMBERSHIP_SELECT);

            litLimitadoPurchaseInfo.Text = string.Format(Resources.Global.LimitadoPurchaseInfo, PageConstants.PURCHASE_MEMBERSHIP);

            // Generate Business Report Sample link
            hlBusinessReportSample.NavigateUrl = GetSamplesPath(Configuration.BusinessReportSampleFile);
            hlBusinessReportSample.Text = Resources.Global.ViewBusinessReportSample;

            EnableFormValidation();
            btnPurchase.OnClientClick = "bEnableValidation=false;";
            btnChargeCreditCard.OnClientClick = "bEnableValidation=true;";
            btnReviseSelections.OnClientClick = "bEnableValidation=false;";
            btnHome.OnClientClick = "bEnableValidation=false;";

            if (IsPostBack)
            {
                // Handle Stripe payments
                NameValueCollection nvc = Request.Form;
                string hfStripeToken = nvc["hfStripeToken"];
                if (!string.IsNullOrEmpty(hfStripeToken))
                {
                    btnChargeCreditCard_Click(hfStripeToken, sender, e);
                }
            }
            else //(!IsPostBack)
            {
                LoadLookupValues();

                PopulateForm();

                // Store trigger page to use in Create Request
                hidTriggerPage.Value = GetReferer();
            }

            SetVisibility();
        }

        /// <summary>
        /// Check users page level authorization
        /// </summary>
        /// <returns></returns>
        override protected bool IsAuthorizedForPage()
        {
            if (_oUser.IsLimitado)
                return true;
            else
                return _oUser.HasPrivilege(SecurityMgr.Privilege.BusinessReportPurchase).HasPrivilege;
        }

        /// <summary>
        /// Check users control/data level authorization
        /// </summary>
        /// <returns></returns>
        protected override bool IsAuthorizedForData()
        {
            return true;
        }

        protected const string PRODUCT_CONFIRMATION_DISPLAY = "<div class='row nomargin'><div class='col-md-12'>{0}</div></div>";
        /// <summary>
        /// Loads all of the databound controls setting 
        /// thier default values.
        /// </summary>
        protected void LoadLookupValues()
        {
            DataTable dtProductList = null;

            // Populate the member business report radio button list
            // with the available member business report products
            if(_oUser.IsLimitado)
                dtProductList = GetProductsByFamily(CODE_PRODUCTFAMILY_ITA_BR, GetCulture(_oUser));
            else
                dtProductList = GetProductsByFamily(CODE_PRODUCTFAMILY_MEM_BR, GetCulture(_oUser));

            // We're leaving this in for now, but the radio button list is
            // hidden later.

            foreach (DataRow drRow in dtProductList.Rows)
            {
                if (drRow["prod_IndustryTypeCode"].ToString().IndexOf("," + _oUser.prwu_IndustryType + ",") > -1)
                {
                    ListItem oItem = new ListItem();

                    string[] args = { drRow["prod_PRDescription"].ToString().Trim() };
                    oItem.Text = string.Format(PRODUCT_CONFIRMATION_DISPLAY, args);

                    oItem.Value = drRow["prod_code"].ToString().Trim();
                    rblMemReportType.Items.Add(oItem);

                    // At this point we should only have one record.  If we add more member BR
                    // products, this module will have to change anyway.

                    //Expecting args[0] to be in this general format
                    //<div style="font-weight:bold">Blue Book Business Report including Experian Credit Information</div><p style="margin-top:0em">Etc.......</p><p>popover portion</p>
                    //Split text apart into title and body so that we can put a blue info hover-over icon next to title (Defect 4553)
                    int iDivEndPos = args[0].IndexOf("</div") + 6;
                    string szDiv = args[0].Substring(0, iDivEndPos);
                    szDiv = szDiv.Replace("</div>", "");
                    szDiv = szDiv.Substring(szDiv.IndexOf(">") + 1);
                    litMemberReportTitle.Text = szDiv;
                    
                    string szP = args[0].Substring(iDivEndPos);
                    string szP1 = szP.Substring(0, szP.IndexOf("</p>") + 4);
                    string szP2 = szP.Substring(szP.IndexOf("</p>") + 4);

                    //SetPopover();
                    popMemberReportTitle.Attributes.Add("data-bs-title", string.Format("{0}", szP2));
                    litMemberReportType.Text = szP1;
                }
            }
        }

        /// <summary>
        /// Populates the form controls.
        /// </summary>
        protected void PopulateForm()
        {
            // Default Business Report Type control
            if (rblMemReportType.Items.Count > 0)
            {
                rblMemReportType.SelectedIndex = 0;
            }

            PopulateSelectedCompanies();

            // Work-Around for an issue with RBLs and update panels.  If the HTML is generated
            // with a list item selected, the "IndexChanged" event only fires once.  So make
            // sure it isn't set when rendered and then set it via client-side JS.
            rblMemReportType.SelectedIndex = 0;

            if (_oUser.IsLimitado)
            {
                pnlLimitadoPurchaseInfo.Visible = true;

                //Defect 4482 - purchase button should not be grayed out for Limitado users
                btnPurchase.Enabled = true;
                btnChargeCreditCard.Visible = false;

                //Defect 4482 - don't show calculation info for ITA users
                pnlMemFooter.Visible = false;
                pnlMemFooter2.Visible = false;
            }
            else
            {
                pnlMemFooter.Visible = true;
                pnlMemFooter2.Visible = true;

                _iAvailableUnits = _oUser.GetAvailableReports();
                _iRemainingUnits = _iAvailableUnits - (int)dTotal;
                hidRemainingUnits.Value = _iRemainingUnits.ToString();
                litAvailableUnits.Text = _iAvailableUnits.ToString("###,##0");
                litRemainingUnits.Text = (_iRemainingUnits).ToString("###,##0");

                if (dTotal > _iAvailableUnits)
                {
                    btnPurchase.Visible = false;
                    lblNotEnoughUnits.Text = string.Format(Resources.Global.NotEnoughReportsText, Configuration.NotEnoughUnitsCSREmail);

                    pnlCreditCardInput.Visible = true;
                    btnChargeCreditCard.Visible = true;

                    int iProductID;


                    if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                        iProductID = LUMBER_PRODUCTID_MEMBERS;
                    else
                        iProductID = PROD_PRODUCTID_MEMBERS;

                    CreditCardProductInfo ccProductInfo = ucCCI.AddCreditCardProductInfo(PRODUCTFAMILYID, iProductID,  Math.Abs(_iRemainingUnits));
                    lblProduct.Text = string.Format("{0} Additional Online Business Reports @ {1} Each", dTotal - _iAvailableUnits, UIUtils.GetFormattedCurrency(ccProductInfo.Price), 0M);
                    lblTotal.Text = UIUtils.GetFormattedCurrency(Math.Abs(_iRemainingUnits) * ccProductInfo.Price, 0M);
                }
                else
                {
                    btnPurchase.Visible = true;
                    btnChargeCreditCard.Visible = false;
                }
            }

            btnPurchase.Text = string.Format("{0}{1}", Resources.Global.GetReport, dTotal > 1 ? "s" : "");
            btnChargeCreditCard.Text = btnPurchase.Text;

            if (_oUser.IsLimitado)
                litMemDescription.Visible = false;
        }

        /// <summary>
        /// Used to show/hide form elements based on the current page
        /// settings
        /// </summary>
        protected void SetVisibility()
        {
            // We are hiding the member selection because at present we will
            // only have one BR to select.  However, since we need the selection
            // mechanism for non-members, and that that new member choices could
            // be introduced in the future, we will merely hide the panel for now
            // and leave the code as-is.  CHW 9/15/08
            litSelectText.Visible = false;
            rblMemReportType.Visible = false;

            if (Configuration.IsBeta)
            {
                btnPurchaseAdditionalUnits.Enabled = false;
            }
        }

        /// <summary>
        /// This method is used to populated the selected companies grid including the prices 
        /// and total cost 
        /// </summary>
        protected void PopulateSelectedCompanies()
        {
            if (string.IsNullOrEmpty(GetRequestParameter("CompanyIDList", false)))
            {
                throw new ApplicationExpectedException(Resources.Global.BookmarkError);
            }

            // Retrieve the selected companies to use to populate the selected companies 
            // data grid 
            string szSelectedCompanyIDs = GetRequestParameter("CompanyIDList", true);
            GetIneligibleCompanies(szSelectedCompanyIDs);

            // Generate the sql required to retrieve the selected companies            
            object[] args = {_oUser.prwu_Culture,
                             _oUser.prwu_WebUserID,
                             _oUser.prwu_HQID,
                             szSelectedCompanyIDs,
                             DateTime.Today.AddDays(0 - Configuration.ClaimActivityNewThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss"),
                             DateTime.Today.AddDays(0 - Configuration.ClaimActivityMeritoriousThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss"),
                            GetObjectMgr().GetLocalSourceCondition(),
                            GetObjectMgr().GetIntlTradeAssociationCondition()};

            string szSQL = string.Format(SQL_GET_SELECTED_COMPANIES, args);
            szSQL += GetOrderByClause(gvSelectedCompanies);

            // Create empty grid view in case 0 results are found
            //((EmptyGridView)gvSelectedCompanies).EmptyTableRowText = GetNoResultsFoundMsg(Resources.Global.Companies);
            gvSelectedCompanies.ShowHeaderWhenEmpty = true;
            gvSelectedCompanies.EmptyDataText = GetNoResultsFoundMsg(Resources.Global.Companies);

            // Clear price total counter
            dTotal = 0;

            // Execute search and bind results to grid
            gvSelectedCompanies.DataSource = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection);
            gvSelectedCompanies.DataBind();
            EnableBootstrapFormatting(gvSelectedCompanies);

            //If not ITA, hide the price column
            if (!_oUser.IsLimitado)
            {
                foreach (DataControlField dcfColumn in gvSelectedCompanies.Columns)
                {
                    if (dcfColumn.HeaderText == Resources.Global.Price)
                        dcfColumn.Visible = false;
                }
            }

            OptimizeViewState(gvSelectedCompanies);

            /*
            if(gvSelectedCompanies.Rows.Count == 1)
            {
                btnPurchase.Visible = true;
            }
            else if(gvSelectedCompanies.Rows.Count > 1)
            {
                btnChargeCreditCard.Visible = true;
            }
            */

            // Display the number of matching records found
            lblRecordCount.Text = string.Format(Resources.Global.RecordSelectedMsg, gvSelectedCompanies.Rows.Count, Resources.Global.Companies);

            // If no results are found, disable the buttons that require a company            
            btnPurchase.Enabled = true;
            if ((gvSelectedCompanies.Rows.Count == 0) ||
                ((iNoPurchaseCount == gvSelectedCompanies.Rows.Count)))
            {
                btnPurchase.Enabled = false;
            }
        }

        /// <summary>
        /// Helper method that helps with bi-directional sorting.  The default sort order
        /// for this grid should be by company name
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void GridView_Sorting(Object sender, GridViewSortEventArgs e)
        {
            SetSortingAttributes((GridView)sender, e);
            PopulateForm();
        }

        /// <summary>
        /// Adds the sort indicator to the appropriate column
        /// header.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void GridView_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            SetSortIndicator((GridView)sender, e);

            // Display Total in gridview footer            
            if (e.Row.RowType == DataControlRowType.Footer)
            {
                e.Row.Visible = false;
            }

            // Level 4 business reports are only available on companies that have 
            // have been verified to be within certain parameters (see function -
            // GetVerifiedCompanyList - disable any rows containing companies that do 
            // not meet these requirements.
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                int i = e.Row.RowIndex;
                string szCompanyID = ((GridView)sender).DataKeys[i].Value.ToString();

                if (lIneligibleCompanies.Contains(szCompanyID))
                {
                    e.Row.Enabled = false;
                }
            }

            DisplayLocalSource(e);
        }

        /// <summary>
        /// Handles the purchase on click event.  For members, this creates the session
        /// variables required to process the payment via service units and redirects the 
        /// user to the Service Unit Payment page.  For non-members, this creates the session
        /// variables required to process a cash payment and redirects the user to the 
        /// credit card payment page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnPurchase_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(GetRequestParameter("CompanyIDList", false)))
            {
                throw new ApplicationExpectedException(Resources.Global.BookmarkError);
            }

            string szSelectedCompanyIDs = GetRequestParameter("CompanyIDList", true);
            string[] aszCompanyIDList = szSelectedCompanyIDs.Split(new char[] { ',' });

            List<Report> reports = null;
            if (_oUser.prwu_EmailPurchases)
            {
                reports = new List<Report>();
            }

            if (_oUser.IsLimitado)
            {
                // Non-Member - setup variables for credit card processing
                CreditCardPaymentInfo oCCPaymentInfo = new CreditCardPaymentInfo();

                // Set the request type based on the report level requested
                oCCPaymentInfo.RequestType = rblMemReportType.SelectedValue; 

                // Do not charge for or include any of the recently purchased items
                string szCompanyIDsToChargeFor = "";
                foreach (string szCompanyID in aszCompanyIDList)
                {
                    if (!String.IsNullOrEmpty(szCompanyID))
                    {
                        // Build sub-list of company ids to charge for based on                                         
                        //   recently purchased reports
                        if (!_oUser.IsRecentPurchase(Convert.ToInt32(szCompanyID),
                                rblMemReportType.SelectedValue)) 
                        {
                            if (!String.IsNullOrEmpty(szCompanyIDsToChargeFor))
                                szCompanyIDsToChargeFor += ",";
                            szCompanyIDsToChargeFor += szCompanyID;
                        }

                        if (_oUser.prwu_EmailPurchases)
                        {
                            reports.Add(new Report(GetReport.BUSINESS_REPORT,
                                                   szCompanyID,
                                                   "0",
                                                   rblMemReportType.SelectedValue));
                        }
                    }
                }

                oCCPaymentInfo.SelectedIDs = szCompanyIDsToChargeFor;
                oCCPaymentInfo.TriggerPage = hidTriggerPage.Value;

                // Retrieve the report data based on the selected report type
                DataTable dtProductList = GetProductsByFamily(CODE_PRODUCTFAMILY_ITA_BR, GetCulture(_oUser));

                DataRow[] adrProduct = dtProductList.Select("prod_code = '" + rblMemReportType.SelectedValue + "'"); 
                DataRow drProduct = adrProduct[0];

                decimal dPerReportPrice = Convert.ToDecimal(drProduct["pric_price"]);
                int iProductID = Convert.ToInt32(drProduct["prod_ProductID"]);

                string[] aszCompanyIDsToChargeFor = szCompanyIDsToChargeFor.Split(new char[] { ',' });
                foreach (string szCompanyID in aszCompanyIDsToChargeFor)
                {
                    if (!String.IsNullOrEmpty(szCompanyID))
                    {
                        // Create a Product for each company selected
                        oCCPaymentInfo.Products.Add(new CreditCardProductInfo(iProductID, Convert.ToInt32(CODE_PRICINGLIST_ONLINE_DELIVERY), 1, dPerReportPrice));
                    }
                }

                if (_oUser.prwu_EmailPurchases)
                {
                    Session["EmailPurchases"] = reports;
                }

                Session["oCreditCardPayment"] = oCCPaymentInfo;
                Response.Redirect(GetFullSSLURL(PageConstants.CREDIT_CARD_PAYMENT));
            }
            else
            {
                // Retrieve the product data required for the payment info objects based on the 
                // report type selected (non-ITA users)
                DataTable dtProductList = GetProductsByFamily(CODE_PRODUCTFAMILY_MEM_BR, GetCulture(_oUser));
                DataRow[] adrProduct = dtProductList.Select("prod_code = '" + rblMemReportType.SelectedValue + "'");
                DataRow drProduct = adrProduct[0];

                int iPerReportPrice = Convert.ToInt32(drProduct["pric_price"]);
                int iProductID = Convert.ToInt32(drProduct["prod_ProductID"]);

                // Now drop any supply companies that are
                // in our list.
                GetIneligibleCompanies(szSelectedCompanyIDs);
                if (lIneligibleCompanies.Count > 0)
                {
                    List<string> lTempCompanyIDs = new List<string>();

                    foreach (string szCompanyID in aszCompanyIDList)
                    {
                        if (!lIneligibleCompanies.Contains(szCompanyID))
                        {
                            lTempCompanyIDs.Add(szCompanyID);
                        }
                    }

                    aszCompanyIDList = lTempCompanyIDs.ToArray();
                    lTempCompanyIDs = null;
                }

                // Make sure we have a "fresh" ServiceUnitPaymentInfo object
                Session["lServiceUnitPaymentInfo"] = null;

                // For each company in the request create a payment info object
                foreach (string szCompanyID in aszCompanyIDList)
                {
                    if (!String.IsNullOrEmpty(szCompanyID))
                    {
                        // Create payment info object
                        ServiceUnitPaymentInfo oPaymentInfo = new ServiceUnitPaymentInfo();
                        GetServiceUnitPaymentInfo().Add(oPaymentInfo);

                        oPaymentInfo.ObjectID = Convert.ToInt32(szCompanyID);
                        oPaymentInfo.ProductID = iProductID;

                        // Do not charge for or include in request any recent purchases                         
                        if (_oUser.IsRecentPurchase(Convert.ToInt32(szCompanyID), rblMemReportType.SelectedValue))
                        {
                            oPaymentInfo.Charge = false;
                            oPaymentInfo.IncludeInRequest = false;
                        }
                        else
                        {
                            oPaymentInfo.Charge = true;
                            oPaymentInfo.IncludeInRequest = true;
                        }

                        oPaymentInfo.Price = iPerReportPrice;

                        if (_oUser.prwu_EmailPurchases)
                        {
                            reports.Add(new Report(GetReport.BUSINESS_REPORT,
                                                    szCompanyID,
                                                    "0",
                                                    rblMemReportType.SelectedValue));
                        }
                    }
                }

                int iRequestID = ExecutePurchaseWithUnits(GetServiceUnitPaymentInfo(),
                                                            aszCompanyIDList.Length,
                                                            rblMemReportType.SelectedValue,
                                                            USAGE_TYPE,
                                                            hidTriggerPage.Value,
                                                            Request.QueryString["SourceID"],
                                                            Request.QueryString["SourceEntityType"]);

                if (_oUser.prwu_EmailPurchases)
                {
                    // We didn't have the RequestID when we first built our
                    // report list, so add it now.
                    foreach (Report report in reports)
                    {
                        report.RequestID = iRequestID.ToString();
                    }

                    Session["EmailPurchases"] = reports;
                }

                //SendBRSurvey()
                GeneralDataMgr oGeneralDataMgr = new GeneralDataMgr(_oLogger, _oUser);
                oGeneralDataMgr.User = _oUser;

                IDbTransaction oTran = oGeneralDataMgr.BeginTransaction();
                try
                {
                    oGeneralDataMgr.SendBRSurvey(iRequestID, _oUser.prwu_PersonLinkID, _oUser.prwu_Culture, oTran);
                    oTran.Commit();
                }
                catch
                {
                    oTran.Rollback();
                    throw;
                }

                Response.Redirect(PageConstants.BROWSE_PURCHASES);
            }
        }

        /// <summary>
        /// Handles the Revise Selections on click event.  This should take the user to 
        /// the CompanySearchResults page specifying the ExecuteLastSearch parameter
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnReviseSelections_Click(object sender, EventArgs e)
        {
            Response.Redirect(GetReturnURL(PageConstants.COMPANY_SEARCH_RESULTS_EXECUTE_LAST));
        }

        /// <summary>
        /// Handles the Cancel on click event.  This should take the user to the page 
        /// specified by the PRWebUser default company search page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnHome_Click(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.BBOS_HOME);
        }

        /// <summary>
        /// Handles the Member report type selected index changed.  The price of the report in 
        /// units is displayed within the table and must be recalculated if the user selects 
        /// a different report type.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void rblMemReportType_SelectedIndexChanged(object sender, EventArgs e)
        {
            PopulateSelectedCompanies();
        }

        /// <summary>
        /// Handles the Non-Member report type selected index changed.  The price of the report in 
        /// currency is displayed within the table and must be recalculated if the user selects 
        /// a different report type.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void rblNonMemReportType_SelectedIndexChanged(object sender, EventArgs e)
        {
            PopulateSelectedCompanies();
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

        protected int iNoPurchaseCount = 0;

        protected const string SQL_VERIFY_ELIGIBILITY =
            @"SELECT comp_CompanyID FROM Company WITH (NOLOCK) WHERE comp_CompanyID IN ({0}) AND (comp_PRIndustryType='S' OR comp_PRLocalSource='Y')";

        protected List<string> lIneligibleCompanies;

        protected void GetIneligibleCompanies(string szCompanyIDs)
        {
            if (lIneligibleCompanies == null)
            {
                lIneligibleCompanies = new List<string>();

                string szSQL = String.Format(SQL_VERIFY_ELIGIBILITY, szCompanyIDs);

                IDBAccess oDataAccess = DBAccessFactory.getDBAccessProvider();
                oDataAccess.Logger = _oLogger;
                using (IDataReader oReader = oDataAccess.ExecuteReader(szSQL, CommandBehavior.CloseConnection))
                {
                    while (oReader.Read())
                    {
                        lIneligibleCompanies.Add(oReader[0].ToString());
                    }
                }
            }
        }

        protected void btnPurchaseAdditionalOnClick(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.SERVICE_UNIT_PURCHASE);
        }

   

        /// <summary>
        /// This method is used to return the price for the report for the current company.  This 
        /// is based on the report type selected and whether or not this report has been recently 
        /// purchased for the given company.
        /// </summary>
        /// <param name="iCompanyID"></param>
        /// <returns></returns>
        protected string GetAvailability(int iCompanyID)
        {
            if (lIneligibleCompanies.Contains(iCompanyID.ToString()))
            {
                iNoPurchaseCount++;
                return Resources.Global.Ineligible;
            }

            // If this is a member, then determine the price in units based on
            // the selected business report level
            // Check if the selected report type has been recently purchased
            // for this company
            if (_oUser.IsRecentPurchase(iCompanyID, rblMemReportType.SelectedValue))
            {
                iNoPurchaseCount++;
                return Resources.Global.PreviouslyOrdered;
            }

            dTotal++;
            return string.Empty;
        }

        const int PRODUCTFAMILYID = 3;

        const int PROD_PRODUCTID_NONMEMBERS = 50;  // $115.00
        const int PROD_PRODUCTID_MEMBERS = 48;  // $30.00
        const int LUMBER_PRODUCTID_MEMBERS = 95;  // $10.00

        protected void btnChargeCreditCard_Click(object sender, EventArgs e)
        {
            NameValueCollection nvc = Request.Form;
            string hfStripeToken = nvc["hfStripeToken"];

            btnChargeCreditCard_Click(hfStripeToken, sender, e);
        }

        protected void btnChargeCreditCard_Click(string stripeToken, object sender, EventArgs e)
        {
            // Get our RequestID.  This will be our "OOTN" to include
            // in the Verisign transaction
            ucCCI.PaymentID = GetObjectMgr().GetRecordID("PRPayment");

            // Build our BR purchase objects
            ucCCI.CCPayment = new CreditCardPaymentInfo();
            ucCCI.CCPayment.RequestType = "AddUnits";
            int iRemainingUnits = Convert.ToInt32(hidRemainingUnits.Value);
            ucCCI.CCPayment.AdditionalUnits = Math.Abs(iRemainingUnits); 
            ucCCI.CCPayment.TriggerPage = hidTriggerPage.Value;

            //Set product info for emails and task creation
            ucCCI.CCPayment.ProductDescriptions = string.Format("Ad-Hoc Business Report Purchase - Qty {0}", Math.Abs(iRemainingUnits));
            ucCCI.ProductLabel = ucCCI.CCPayment.ProductDescriptions;

            int iProductID;

            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                iProductID = LUMBER_PRODUCTID_MEMBERS;
            else
                iProductID = PROD_PRODUCTID_MEMBERS;

            CreditCardProductInfo ccProductInfo = ucCCI.AddCreditCardProductInfo(PRODUCTFAMILYID, iProductID, Math.Abs(iRemainingUnits));
            ucCCI.CCPayment.Products.Add(ccProductInfo);
            ucCCI.CCPayment.TotalPrice = ccProductInfo.Quantity * ccProductInfo.Price;

            if (!ucCCI.ExecutePayment(stripeToken))
            {
                errMsg.Text = "The credit card transaction has been denied. Please review the information you provided for accuracy. If this error persists, please contact Blue Book Services at 630 668-3500.";
                return;
            }

            ucCCI.AuthCode = ucCCI.TrxnStripeCharge.Id;

            IDbTransaction oTran = GetObjectMgr().BeginTransaction();
            try
            {
                int Alloc_ID = ucCCI.ProcessAdditionalUnits(oTran);

                string szMsg = ucCCI.GetTaskMsg(ucCCI.ADD_UNITS_MSG);
                int related_company = 0;
                int related_person = 0;
                int sales_person = 0;

                if (_oUser != null)
                {
                    related_company = _oUser.prwu_BBID;
                    related_person = _oUser.peli_PersonID;
                }

                // Note: GetPRCoSpecialistID will crash if related_company is not in the DB.
                sales_person = related_company > 0 ?
                        GetObjectMgr().GetPRCoSpecialistID(related_company, GeneralDataMgr.PRCO_SPECIALIST_CSR, oTran)
                        : Utilities.GetIntConfigValue("AdditionalUnitsPurchaseUserID", 1);

                GetObjectMgr().CreateTask(sales_person,
                                          "Pending",
                                          szMsg,
                                          Utilities.GetConfigValue("AdditionalUnitsPurchaseCategory", string.Empty),
                                          Utilities.GetConfigValue("AdditionalUnitsPurchaseSubcategory", string.Empty),
                                          related_company,
                                          related_person,
                                          0,
                                          "OnlineIn",
                                          oTran);

                //Defect 6973 - emails via stored proc
                GetObjectMgr().SendEmail_Text(GetObjectMgr().GetPRCoUserEmail(sales_person, oTran),
                        Utilities.GetConfigValue("AdditionalUnitsPurchaseEmailSubject", "Additional Business Reports Purchased via BBOS"),
                        szMsg,
                        "BusinessReportConfirmSelections.aspx", 
                        oTran);

                GetObjectMgr().SendEmail_Text(GetObjectMgr().GetPRCoUserEmail(Utilities.GetIntConfigValue("AdditionalUnitsPurchaseEmailAcctUserID", 1029), oTran),
                    Utilities.GetConfigValue("AdditionalUnitsPurchaseEmailSubject", "Additional Business Reports Purchased via BBOS"),
                    szMsg,
                    "BusinessReportConfirmSelections.aspx",
                    oTran);

                ucCCI.CCUser.Save(oTran);
                Session["oUser"] = ucCCI.CCUser;

                ucCCI.CreatePayment(oTran);

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

            // Set these values so that our receipt screen 
            // can display them.
            ucCCI.CCPayment.Street1 = ucCCI.Street1;
            ucCCI.CCPayment.Street2 = ucCCI.Street2;
            ucCCI.CCPayment.City = ucCCI.City;
            ucCCI.CCPayment.StateID = Convert.ToInt32(ucCCI.State_Value);
            ucCCI.CCPayment.CountryID = Convert.ToInt32(ucCCI.Country_Value);
            ucCCI.CCPayment.PostalCode = ucCCI.PostalCode;
            ucCCI.CCPayment.AuthorizationCode = ucCCI.AuthCode; //_szAuthCode;
            ucCCI.CCPayment.PaymentID = ucCCI.PaymentID; //_iPaymentID;
            ucCCI.CCPayment.CreditCardNumber = ucCCI.TrxnStripeCharge.PaymentMethodDetails.Card.Last4;
            ucCCI.CCPayment.CreditCardType = EBB.BusinessObjects.Stripe.GetCreditCardType(ucCCI.TrxnStripeCharge.PaymentMethodDetails.Card.Brand);

            CreditCardPaymentReceipt.SendConfirmationEmail(ucCCI.CCPayment, _oUser, Server, GetObjectMgr());

            //now that the exact # of units have been added, invoke the Purchase button
            btnPurchase_Click(sender, e);
        }
    }
}