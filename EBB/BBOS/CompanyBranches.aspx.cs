/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CompanyBranches
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using PRCo.EBB.BusinessObjects;
using System;
using System.Collections;
using System.Data;
using System.Diagnostics;
using System.Security.Cryptography;
using System.Web;
using System.Web.UI.WebControls;
using System.Web.UI;
using TSI.BusinessObjects;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Displays company data and listing.
    /// </summary>
    public partial class CompanyBranches : CompanyDetailsBase
    {
        CompanyData _ocd;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
            Page.Title = Resources.Global.BlueBookService;
            ((BBOS)Master).HideOldTopMenu();

            if (!IsPostBack)
            {
                hidCompanyID.Text = GetRequestParameter("CompanyID", true, true);

                PopulateForm();
            }

            RedirectToHomeIfCompanyMissing(hidCompanyID.Text);

            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_FUNCTIONS2_FILE));
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_VALIDATION_FILE));

            //Set user controls
            ucSidebar.WebUser = _oUser;
            ucSidebar.CompanyID = UIUtils.GetString(hidCompanyID.Text);
            ucCompanyHero.WebUser = _oUser;
            ucCompanyHero.CompanyID = UIUtils.GetString(hidCompanyID.Text);
            ucCompanyBio.WebUser = _oUser;
            ucCompanyBio.CompanyID = UIUtils.GetString(hidCompanyID.Text);
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

        protected void btnPrint_Click(object sender, ImageClickEventArgs e)
        {
            string szScript = "setTimeout(function() { printdiv(); }, 1000);"; //without delay the print window can be a garbled mess
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "printx", string.Format("<script>{0}</script>", szScript), false);
        }

        protected void PopulateForm()
        {
            PopulateBranches();
            PopulateAffiliations();

            ApplySecurity(btnReports, SecurityMgr.Privilege.CompanyReportsPage);
            ApplySecurity(btnReportsBranches, SecurityMgr.Privilege.CompanyReportsPage);

            ApplySecurity(btnAddToWatchdog, SecurityMgr.Privilege.WatchdogListAdd);
            ApplySecurity(btnAddToWatchdogBranches, SecurityMgr.Privilege.WatchdogListAdd);

            ApplySecurity(btnExportData, SecurityMgr.Privilege.DataExportPage);
            ApplySecurity(btnExportDataBranches, SecurityMgr.Privilege.DataExportPage);

            if (gvBranches.Rows.Count == 0)
            {
                btnReportsBranches.Enabled = false;
                btnExportDataBranches.Enabled = false;
                btnAddToWatchdogBranches.Enabled = false;
            }
            else
            {
                string szExportClick = $"if(!confirmSelect('Branch', 'cbBranchID') || !ValidateExportsCount2('{hidExportsMax_Branches.ClientID}', '{hidExportsUsed_Branches.ClientID}', '{hidSelectedCount_Branches.ClientID}', '{hidExportsPeriod_Branches.ClientID}')) return false;";
                btnReportsBranches.Attributes.Add("onclick", szExportClick);
                btnExportDataBranches.Attributes.Add("onclick", szExportClick) ;
                btnAddToWatchdogBranches.Attributes.Add("onclick", "return confirmSelect('Branch', 'cbBranchID')");
            }

            if (gvAffiliations.Rows.Count == 0)
            {
                btnReports.Enabled = false;
                btnExportData.Enabled = false;
                btnAddToWatchdog.Enabled = false;
            }
            else
            {
                string szExportClick = $"if(!confirmSelect('Affiliate', 'cbAffiliateID') || !ValidateExportsCount2('{hidExportsMax_Affiliates.ClientID}', '{hidExportsUsed_Affiliates.ClientID}', '{hidSelectedCount_Affiliates.ClientID}', '{hidExportsPeriod_Affiliates.ClientID}')) return false;";
                btnReports.Attributes.Add("onclick", szExportClick);
                btnExportData.Attributes.Add("onclick", szExportClick);
                btnAddToWatchdog.Attributes.Add("onclick", "return confirmSelect('Affiliate', 'cbAffiliateID')");
            }

            //Get cached company data
            _ocd = GetCompanyDataFromSession();

            if (_ocd.bLocalSource)
            {
                ucCompanyDetailsHeaderMeister.MeisterVisible = true;
            }

            //Exports management
            ExportsManagement(hidExportsPeriod_Branches, hidExportsMax_Branches, hidExportsUsed_Branches);
            ExportsManagement(hidExportsPeriod_Affiliates, hidExportsMax_Affiliates, hidExportsUsed_Affiliates);
        }

        protected const string SQL_COMPANY_HQ_SELECT = "SELECT comp_CompanyID, comp_PRBookTradestyle, CityStateCountryShort, comp_PRListingStatus FROM Company WITH (NOLOCK) INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID WHERE comp_CompanyID = dbo.ufn_BRGetHQID({0})";
        protected const string SQL_BRANCHES_1 =
                    @"SELECT *, 
                             dbo.ufn_GetCustomCaptionValue('comp_PRIndustryType', comp_PRIndustryType, '{0}') As IndustryType, 
                             dbo.ufn_HasNote({1}, {2}, comp_CompanyID, 'C') As HasNote, 
                             dbo.ufn_FormatPhone(phone.phon_CountryCode, phone.phon_AreaCode, phone.phon_Number, phone.phon_PRExtension) as Phone,
                             dbo.ufn_HasNewClaimActivity(comp_PRHQID, '{4}') as HasNewClaimActivity, 
                             dbo.ufn_HasMeritoriousClaim(comp_PRHQID, '{5}') as HasMeritoriousClaim,
                             dbo.ufn_HasCertification(comp_PRHQID) as HasCertification,
                             dbo.ufn_HasCertification_Organic(comp_PRHQID) as HasCertification_Organic,
                             dbo.ufn_HasCertification_FoodSafety(comp_PRHQID) as HasCertification_FoodSafety
                        FROM vPRBBOSCompanyList
                             LEFT OUTER JOIN vPRCompanyPhone phone WITH (NOLOCK) ON comp_CompanyID = phone.PLink_RecordID AND phone.phon_PRIsPhone='Y' AND phone.phon_PRPreferredPublished='Y' 
                       WHERE comp_CompanyID IN ({3}) ";

        protected const string SQL_BRANCHES_2 = "SELECT comp_CompanyID FROM Company WITH (NOLOCK) WHERE comp_PRHQID ={0} AND comp_PRType = 'B' AND comp_PRListingStatus IN ({1})";

        /// <summary>
        /// Populates the Branches portion of the page.
        /// </summary>
        protected void PopulateBranches()
        {
            int iHQID = 0;
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", hidCompanyID.Text));

            string qhListingStatus = null;

            string szSQL = GetObjectMgr().FormatSQL(SQL_COMPANY_HQ_SELECT, oParameters);
            using (IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null))
            {
                oReader.Read();
                iHQID = GetDBAccess().GetInt32(oReader, "comp_CompanyID");

                litBBID.Text = iHQID.ToString();
                hlHQName.Text = GetDBAccess().GetString(oReader, 1);
                hlHQName.NavigateUrl = PageConstants.Format(PageConstants.COMPANY_DETAILS_SUMMARY, iHQID);
                litLocation.Text = GetDBAccess().GetString(oReader, 2);

                qhListingStatus = GetDBAccess().GetString(oReader, "comp_PRListingStatus");
            }

            string listingStatus = "'L', 'H', 'LUV'";
            if ((qhListingStatus == "N3") ||
                (qhListingStatus == "N5") ||
                (qhListingStatus == "N6"))
            {
                listingStatus += ",'N3','N5','N6'";
            }

            oParameters.Clear();
            //oParameters.Add(new ObjectParameter("comp_CompanyID", iHQID));

            szSQL = string.Format(SQL_BRANCHES_2, iHQID, listingStatus);

            object[] args =  {_oUser.prwu_Culture,
                              _oUser.prwu_WebUserID,
                              _oUser.prwu_HQID,
                              szSQL,
                              DateTime.Today.AddDays(0 - Configuration.ClaimActivityNewThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss"),
                              DateTime.Today.AddDays(0 - Configuration.ClaimActivityMeritoriousThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss")};

            szSQL = string.Format(SQL_BRANCHES_1,
                                  args);

            szSQL += " AND " + GetObjectMgr().GetLocalSourceCondition();
            szSQL += " AND " + GetObjectMgr().GetIntlTradeAssociationCondition();
            szSQL += GetOrderByClause(gvBranches);

            string[] aKeys = { "comp_CompanyID" };
            gvBranches.DataKeyNames = aKeys;

            //((EmptyGridView)gvBranches).EmptyTableRowText = GetNoResultsFoundMsg(Resources.Global.Branches);
            gvBranches.ShowHeaderWhenEmpty = true;
            gvBranches.EmptyDataText = GetNoResultsFoundMsg(Resources.Global.Branches);

            gvBranches.DataSource = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            gvBranches.DataBind();

            EnableBootstrapFormatting(gvBranches);

            //OptimizeViewState(gvBranches);
        }

        protected const string SQL_AFFILIATES_1 =
            @"SELECT *, 
                    dbo.ufn_GetCustomCaptionValue('comp_PRIndustryType', comp_PRIndustryType, '{0}') As IndustryType, 
                    dbo.ufn_GetCustomCaptionValue('comp_PRType_BBOS', comp_PRType, '{0}') As CompanyType, 
                    dbo.ufn_HasNote({1}, {2}, comp_CompanyID, 'C') As HasNote, 
                    compRating.prra_RatingLine,
                    dbo.ufn_FormatPhone(phone.phon_CountryCode, phone.phon_AreaCode, phone.phon_Number, phone.phon_PRExtension) as Phone, 
                    emai_PRWebAddress,
                    dbo.ufn_HasNewClaimActivity(comp_PRHQID, '{4}') as HasNewClaimActivity, 
                    dbo.ufn_HasMeritoriousClaim(comp_PRHQID, '{5}') as HasMeritoriousClaim,
                    dbo.ufn_HasCertification(comp_PRHQID) as HasCertification,
                    dbo.ufn_HasCertification_Organic(comp_PRHQID) as HasCertification_Organic,
                    dbo.ufn_HasCertification_FoodSafety(comp_PRHQID) as HasCertification_FoodSafety,
                    CASE WHEN comp_PRType = 'B' THEN CASE WHEN compRating.prra_RatingID IS NOT NULL THEN 'N' ELSE 'Y' END ELSE 'N' END AS IsHQRating,
                    CASE WHEN comp_PRType = 'B' THEN CASE WHEN compRating.prra_RatingID IS NOT NULL THEN compRating.prra_RatingID ELSE hqRating.prra_RatingID END ELSE hqRating.prra_RatingID END AS prra_RatingID,
                    CASE WHEN comp_PRType = 'B' THEN CASE WHEN compRating.prra_RatingID IS NOT NULL THEN compRating.prra_RatingLine ELSE hqRating.prra_RatingLine END ELSE hqRating.prra_RatingLine END AS prra_RatingLine
                FROM vPRBBOSCompanyList
                    LEFT OUTER JOIN vPRCurrentRating compRating ON comp_CompanyID = compRating.prra_CompanyID 
                    LEFT OUTER JOIN vPRCurrentRating hqRating ON comp_PRHQID = hqRating.prra_CompanyID 
                    LEFT OUTER JOIN vCompanyEmail WITH (NOLOCK) ON comp_CompanyID = elink_RecordID AND elink_Type = 'W' AND emai_PRPreferredPublished = 'Y' 
                    LEFT OUTER JOIN vPRCompanyPhone phone WITH (NOLOCK) ON comp_CompanyID = phone.PLink_RecordID AND phone.phon_PRIsPhone='Y' AND phone.phon_PRPreferredPublished='Y' 
                WHERE comp_CompanyID IN ({3}) AND comp_PRListingStatus IN ('L', 'H', 'LUV')";

        protected const string SQL_AFFILIATES_2 = "SELECT CASE WHEN prcr_LeftCompanyID={0} THEN prcr_RightCompanyID ELSE prcr_LeftCompanyID END As CompanyID" +
                                            "  FROM PRCompanyRelationship WITH (NOLOCK) " +
                                            " WHERE (prcr_LeftCompanyID = {0} OR prcr_RightCompanyID={0})" +
                                            "   AND prcr_Type IN (27, 28, 29)" +
                                            "   AND prcr_Active = 'Y'" +
                                            "   AND prcr_Deleted IS NULL";
        /// <summary>
        /// Populates the Affliations portion of the page
        /// </summary>
        protected void PopulateAffiliations()
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("comp_CompanyID", hidCompanyID.Text));

            string szSQL = GetObjectMgr().FormatSQL(SQL_AFFILIATES_2, oParameters);

            object[] args =  {_oUser.prwu_Culture,
                              _oUser.prwu_WebUserID,
                              _oUser.prwu_HQID,
                              szSQL,
                              DateTime.Today.AddDays(0 - Configuration.ClaimActivityNewThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss"),
                              DateTime.Today.AddDays(0 - Configuration.ClaimActivityMeritoriousThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss")};

            szSQL = string.Format(SQL_AFFILIATES_1,
                                  args);
            szSQL += " AND " + GetObjectMgr().GetLocalSourceCondition();
            szSQL += " AND " + GetObjectMgr().GetIntlTradeAssociationCondition();
            szSQL += GetOrderByClause(gvAffiliations);

            //((EmptyGridView)gvAffiliations).EmptyTableRowText = GetNoResultsFoundMsg(Resources.Global.Affiliations);
            gvAffiliations.ShowHeaderWhenEmpty = true;
            gvAffiliations.EmptyDataText = GetNoResultsFoundMsg(Resources.Global.Affiliations);

            gvAffiliations.DataSource = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            gvAffiliations.DataBind();
            EnableBootstrapFormatting(gvAffiliations);

            //OptimizeViewState(gvAffiliations);
        }

        /// <summary>
        /// Helper method that helps with bi-directional sorting
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void AffiliationsGridView_Sorting(Object sender, GridViewSortEventArgs e)
        {
            SetSortingAttributes((GridView)sender, e);
            PopulateAffiliations();
        }

        /// <summary>
        /// Helper method that helps with bi-directional sorting
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void BranchesGridView_Sorting(Object sender, GridViewSortEventArgs e)
        {
            SetSortingAttributes((GridView)sender, e);
            PopulateBranches();
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

            GridView oGridView = (GridView)sender;

            if ((oGridView.ID == "gvBranches") &&
               (e.Row.RowType == DataControlRowType.DataRow))
            {

                if ((int)oGridView.DataKeys[e.Row.RowIndex].Value == Convert.ToInt32(hidCompanyID.Text))
                {
                    e.Row.CssClass = "highlightrow";
                }
            }

            if ((oGridView.ID == "gvAffiliations") &&
               (e.Row.RowType == DataControlRowType.DataRow))
            {
                Literal litRatingLine = (Literal)e.Row.FindControl("litRatingLine");

                if (_oUser.HasPrivilege(SecurityMgr.Privilege.ViewRating).HasPrivilege)
                {
                    object ratingID = DataBinder.Eval(e.Row.DataItem, "prra_RatingID");
                    object ratingLine = DataBinder.Eval(e.Row.DataItem, "prra_RatingLine");
                    object isHQRating = DataBinder.Eval(e.Row.DataItem, "IsHQRating");

                    litRatingLine.Text = GetRatingCell(ratingID, ratingLine, isHQRating);
                }
                else if (_oUser.IsLumber_BASIC() || _oUser.IsLumber_BASIC_PLUS())
                {
                    //Defect 6818 alternate "Upgrade to view" link for Basic Lumber users
                    litRatingLine.Text = string.Format("<a href='MembershipSelect.aspx'>{0}</a>", Resources.Global.UpgradeToView);
                }
            }
        }

        /// <summary>
        /// Handles the Reports on click event.  Takes the user to the ReportsConfirmSelections.aspx page 
        /// for the selected companies.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnReports_Click(object sender, EventArgs e)
        {
            RedirectToReports("cbAffiliateID");
        }

        protected void btnReportsBranches_Click(object sender, EventArgs e)
        {
            RedirectToReports("cbBranchID");
        }

        protected void RedirectToReports(string checkboxID)
        {
            Session["ReturnURL"] = PageConstants.Format(PageConstants.COMPANY_BRANCHES_BBOS9, hidCompanyID.Text);
            SetRequestParameter("CompanyIDList", GetRequestParameter(checkboxID));
            Response.Redirect(PageConstants.REPORTS_CONFIRM_SELECTION);
        }

        /// <summary>
        /// Handles the Get Marketing List on click event.  Takes the user to the DataExportConfirmSelections.aspx 
        /// page specifying the selected companies.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnExportData_Click(object sender, EventArgs e)
        {
            Session["ReturnURL"] = PageConstants.Format(PageConstants.COMPANY_BRANCHES_BBOS9, hidCompanyID.Text);
            RedirectToExportData("cbAffiliateID");
        }

        protected void btnExportDataBranches_Click(object sender, EventArgs e)
        {
            RedirectToExportData("cbBranchID");
        }

        protected void RedirectToExportData(string checkboxID)
        {
            Session["ReturnURL"] = PageConstants.Format(PageConstants.COMPANY_BRANCHES_BBOS9, hidCompanyID.Text);
            SetRequestParameter("CompanyIDList", GetRequestParameter(checkboxID));
            Response.Redirect(PageConstants.DATA_EXPORT_CONFIRM_SELECTIONS);
        }

        /// <summary>
        /// Handles the Add To Watchdog List on click event.  Invokes the Save Selected function to save
        /// the selected company's on the form, and takes the user to the UserListAddTo.aspx page specifying
        /// the selected companies.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnAddToWatchdog_Click(object sender, EventArgs e)
        {
            RedirectToWatchdogList("cbAffiliateID");
        }

        protected void btnAddToWatchdogBranches_Click(object sender, EventArgs e)
        {
            RedirectToWatchdogList("cbBranchID");
        }

        protected void RedirectToWatchdogList(string checkboxID)
        {
            Session["ReturnURL"] = PageConstants.Format(PageConstants.COMPANY_BRANCHES_BBOS9, hidCompanyID.Text);
            SetRequestParameter("CompanyIDList", GetRequestParameter(checkboxID));
            Response.Redirect(PageConstants.USER_LIST_ADD_TO);
        }

        protected string GetCompanyURL(object oWebSite)
        {
            if (oWebSite == DBNull.Value)
            {
                return string.Empty;
            }

            string szWebSite = oWebSite.ToString();
            if (!string.IsNullOrEmpty(szWebSite))
            {
                string szURL = PageConstants.Format(PageConstants.EXTERNAL_LINK_TRIGGER, szWebSite, hidCompanyID.Text, "C", Request.ServerVariables.Get("SCRIPT_NAME"));
                return UIUtils.GetHyperlink(szURL, szWebSite, null, "Target=_blank");
            }

            return string.Empty;
        }

        override protected bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.CompanyDetailsBranchesAffiliationsPage).Enabled;
        }


    }
}