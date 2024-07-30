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

 ClassName: CompanyAnalysis
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/

using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This page displays the financial ratios for selected companies for comparison purposes.  The company
    /// data included on this page will be BBID, Company, Statement Type, Statement Date, Current Ratio, Quick
    /// Ratio, Account Recievable Turnover, Days Payable Outstanding, Debt to Equity, Fixed Assets to Equity,
    /// Debt Service Ability, Operating Ratio, Rating, and BBScore.
    /// 
    /// The most recent financial statement record will be displayed regardless of age and the confidential
    /// flag.  
    /// 
    /// Ratios will be computed on each of the relevant fields for: Average, Median, 25 Percentile, 
    /// 75 Percentile, Highest Value, Lowest Value, and Standard Deviation.
    /// 
    /// Median: The middle values in a sample set.  For an even number of records the statistical median 
    /// value will be calculated - the lower of the two middle values will be used.  Null values will be 
    /// ignored.
    ///     
    /// Standard Deviation: A standard deviation will tell you how evenly the values in a sample are 
    /// distributed around the mean. The smaller the standard deviation, the more closely the values are 
    /// condensed around the mean. The greater the standard deviation, the more values you will find 
    /// at a distance from the mean.
    /// </summary>
    public partial class CompanyAnalysis : PageBase
    {
        private string szFinancialIDs = "";
        private string szCompanyIDs = "";

        // SQL used to retrieve the PRFinancial and Rating data for the selected companies. To retrieve the 
        // BB Score for a company, additional checks of the comp_PRInvestigationMethodGroup = "A" 
        // and prbs_ConfidencesScore > 5 (config value) are required.
        new protected const string SQL_GET_SELECTED_COMPANIES =
            @"SELECT prfs_FinancialID, comp_CompanyID, comp_PRBookTradestyle, ISNULL(comp_PRLegalName, '') comp_PRLegalName, comp_PRListingStatus, 
                     comp_PRLastPublishedCSDate, dbo.ufn_HasNote({0}, {1}, comp_CompanyID, 'C') As HasNote, 
                     compRating.prra_RatingLine, compRating.prra_RatingID, 
                     prfs_Type, prfs_StatementDate, prfs_CurrentRatio, prfs_QuickRatio, prfs_ARTurnover, 
                     prfs_DaysPayableOutstanding, prfs_DebtToEquity, prfs_FixedAssetsToNetWorth, prfs_DebtServiceAbility, 
                     prfs_OperatingRatio, prbs_BBScore, prbs_PRPublish, comp_PRPublishBBScore, comp_PRConfidentialFS,
                     dbo.ufn_HasNewClaimActivity(comp_PRHQID, '{3}') as HasNewClaimActivity, 
                     dbo.ufn_HasMeritoriousClaim(comp_PRHQID, '{4}') as HasMeritoriousClaim,
                     dbo.ufn_HasCertification(comp_PRHQID) as HasCertification,
                     dbo.ufn_HasCertification_Organic(comp_PRHQID) as HasCertification_Organic,
                     dbo.ufn_HasCertification_FoodSafety(comp_PRHQID) as HasCertification_FoodSafety,
                     CASE WHEN comp_PRType = 'B' THEN CASE WHEN compRating.prra_RatingID IS NOT NULL THEN 'N' ELSE 'Y' END ELSE 'N' END AS IsHQRating,
                     CASE WHEN comp_PRType = 'B' THEN CASE WHEN compRating.prra_RatingID IS NOT NULL THEN compRating.prra_RatingID ELSE hqRating.prra_RatingID END ELSE hqRating.prra_RatingID END AS prra_RatingID,
                     CASE WHEN comp_PRType = 'B' THEN CASE WHEN compRating.prra_RatingID IS NOT NULL THEN compRating.prra_RatingLine ELSE hqRating.prra_RatingLine END ELSE hqRating.prra_RatingLine END AS prra_RatingLine
                FROM Company WITH (NOLOCK) 
                     LEFT OUTER JOIN vPRCurrentRating compRating ON comp_CompanyID = compRating.prra_CompanyID 
                     LEFT OUTER JOIN vPRCurrentRating hqRating ON comp_PRHQID = hqRating.prra_CompanyID 
                     LEFT OUTER JOIN PRFinancial ON comp_CompanyID = prfs_CompanyID AND comp_PRFinancialStatementDate  = prfs_StatementDate 
                     LEFT OUTER JOIN PRBBScore ON comp_CompanyID = prbs_CompanyID AND prbs_Current='Y' and prbs_PRPublish = 'Y' and comp_PRPublishBBScore='Y'
               WHERE comp_CompanyID IN ({2}) ";

        // SQL used to calculate the ratio section Average for each of the relevant fields
        protected const string SQL_GET_AVERAGE = "SELECT AVG(prfs_CurrentRatio) AS CR_AVG, " +
            "AVG(prfs_QuickRatio) AS QR_AVG, AVG(prfs_ARTurnover) AS AR_AVG, " +
            "AVG(prfs_DaysPayableOutstanding) AS DPO_AVG, AVG(prfs_DebtToEquity) AS DTE_AVG, " +
            "AVG(prfs_FixedAssetsToNetWorth) AS FANW_AVG, AVG(prfs_DebtServiceAbility) AS DSA_AVG, " +
            "AVG(prfs_OperatingRatio) AS OR_AVG " +
            "FROM Company WITH (NOLOCK) " +
            "LEFT OUTER JOIN PRFinancial on comp_CompanyID = prfs_CompanyID AND comp_PRFinancialStatementDate = prfs_StatementDate " +
            "WHERE comp_CompanyID in ({0}) " +
            "AND ISNULL(comp_PRConfidentialFS, 0) != '2' ";

        protected const string SQL_GET_AVERAGE_BBS = "SELECT AVG(prbs_BBScore) AS BBS_AVG " +
            "FROM Company WITH (NOLOCK) " +
            "LEFT OUTER JOIN PRBBScore ON comp_CompanyID = prbs_CompanyID AND prbs_Current='Y' and prbs_PRPublish = 'Y' and comp_PRPublishBBScore='Y' " +
            "WHERE comp_CompanyID in ({0}) ";

        // SQL used to calculate the ratio section Minimum Value for each of the relevant fields
        protected const string SQL_GET_MIN_VALUE = "SELECT MIN(prfs_CurrentRatio) AS CR_MIN, " +
            "MIN(prfs_QuickRatio) AS QR_MIN, MIN(prfs_ARTurnover) AS AR_MIN, " +
            "MIN(prfs_DaysPayableOutstanding) AS DPO_MIN, MIN(prfs_DebtToEquity) AS DTE_MIN, " +
            "MIN(prfs_FixedAssetsToNetWorth) AS FANW_MIN, MIN(prfs_DebtServiceAbility) AS DSA_MIN, " +
            "MIN(prfs_OperatingRatio) AS OR_MIN " +
            "FROM Company WITH (NOLOCK) " +
            "LEFT OUTER JOIN PRFinancial on comp_CompanyID = prfs_CompanyID AND comp_PRFinancialStatementDate = prfs_StatementDate " +
            "WHERE comp_CompanyID in ({0}) " +
            "AND ISNULL(comp_PRConfidentialFS, 0) != '2' ";

        protected const string SQL_GET_MIN_VALUE_BBS = "SELECT MIN(prbs_BBScore) AS BBS_MIN " +
            "FROM Company WITH (NOLOCK) " +
            "LEFT OUTER JOIN PRBBScore ON comp_CompanyID = prbs_CompanyID AND prbs_Current='Y' and prbs_PRPublish = 'Y' and comp_PRPublishBBScore='Y' " +
            "WHERE comp_CompanyID in ({0}) ";

        // SQL used to calculate the ratio section Maximum Value for each of the relevant fields
        protected const string SQL_GET_MAX_VALUE = "SELECT MAX(prfs_CurrentRatio) AS CR_MAX, " +
            "MAX(prfs_QuickRatio) AS QR_MAX, MAX(prfs_ARTurnover) AS AR_MAX, " +
            "MAX(prfs_DaysPayableOutstanding) AS DPO_MAX, MAX(prfs_DebtToEquity) AS DTE_MAX, " +
            "MAX(prfs_FixedAssetsToNetWorth) AS FANW_MAX, MAX(prfs_DebtServiceAbility) AS DSA_MAX, " +
            "MAX(prfs_OperatingRatio) AS OR_MAX " +
            "FROM Company WITH (NOLOCK) " +
            "LEFT OUTER JOIN PRFinancial on comp_CompanyID = prfs_CompanyID AND comp_PRFinancialStatementDate = prfs_StatementDate " +
            "WHERE comp_CompanyID in ({0}) " +
            "AND ISNULL(comp_PRConfidentialFS, 0) != '2' ";

        protected const string SQL_GET_MAX_VALUE_BBS = "SELECT MAX(prbs_BBScore) AS BBS_MAX " +
            "FROM Company WITH (NOLOCK) " +
            "LEFT OUTER JOIN PRBBScore ON comp_CompanyID = prbs_CompanyID AND prbs_Current='Y' and prbs_PRPublish = 'Y' and comp_PRPublishBBScore='Y' " +
            "WHERE comp_CompanyID in ({0}) ";

        // SQL used to calculate the ratio section Standard Deviation for each of the relevant fields.
        // Rounding to the 2nd decimal place was added to elimate values being returned by sql in 
        // exponential notation format
        protected const string SQL_GET_STDEV_VALUE = "SELECT ROUND(STDEV(prfs_CurrentRatio), 2) AS CR_STDEV, " +
            "ROUND(STDEV(prfs_QuickRatio), 2) AS QR_STDEV, ROUND(STDEV(prfs_ARTurnover), 2) AS AR_STDEV, " +
            "ROUND(STDEV(prfs_DaysPayableOutstanding), 2) AS DPO_STDEV, ROUND(STDEV(prfs_DebtToEquity), 2) AS DTE_STDEV, " +
            "ROUND(STDEV(prfs_FixedAssetsToNetWorth), 2) AS FANW_STDEV, ROUND(STDEV(prfs_DebtServiceAbility), 2) AS DSA_STDEV, " +
            "ROUND(STDEV(prfs_OperatingRatio), 2) AS OR_STDEV " +
            "FROM Company WITH (NOLOCK) " +
            "LEFT OUTER JOIN PRFinancial on comp_CompanyID = prfs_CompanyID AND comp_PRFinancialStatementDate = prfs_StatementDate " +
            "WHERE comp_CompanyID in ({0}) " +
            "AND ISNULL(comp_PRConfidentialFS, 0) != '2' ";

        protected const string SQL_GET_STDEV_VALUE_BBS = "SELECT ROUND(STDEV(prbs_BBScore), 2) AS BBS_STDEV " +
            "FROM Company WITH (NOLOCK) " +
            "LEFT OUTER JOIN PRBBScore ON comp_CompanyID = prbs_CompanyID AND prbs_Current='Y' and prbs_PRPublish = 'Y' and comp_PRPublishBBScore='Y' " +
            "WHERE comp_CompanyID in ({0}) ";

        /// <summary>
        /// Calls page functions required to build and process this page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            // Set page title and add any additional javascript file required to process this 
            // page
            SetPageTitle(Resources.Global.AnalyzeCompanies);
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_FUNCTIONS2_FILE));
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_VALIDATION_FILE));

            // Setup formatted page text
            hlRatioDefinitions.NavigateUrl = Configuration.CorporateWebSite + GetReferenceValue("ReferenceURL", "RatioDefinitions");
            hlRatioDefinitions.Target = "website";

            if (!IsPostBack)
            {
                PopulateForm();

                // Store trigger page to be used for Create Requests
                hidTriggerPage.Value = GetReferer();

                // Create Request for Company Analysis
                CreateCompanyAnalysisRequest();
            }

            // Set security and validation on the pages process buttons
            ApplySecurity();
        }

        /// <summary>
        /// Check users page level authorization
        /// </summary>
        /// <returns></returns>
        override protected bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.CompanyAnalysisPage).HasPrivilege;
        }

        /// <summary>
        /// Check users control/data level authorization
        /// </summary>
        /// <returns></returns>
        protected override bool IsAuthorizedForData()
        {
            // NOTE: View Blue Book Score requires level 5 member access, which is the 
            // same as the page level access, so no additonal check is needed.

            // NOTE: The print report - company analysis report requires level 5 access,
            // which is the same as the page level access, so no additional check is needed.
            return true;
        }

        /// <summary>
        /// Populates the form controls.
        /// </summary>
        protected void PopulateForm()
        {
            // Restrieve the selected companies to use to populate the selected companies 
            // data grid 
            string szSelectedCompanyIDs = GetRequestParameter("CompanyIDList", true, false, true);

            object[] args = {_oUser.prwu_WebUserID,
                             _oUser.prwu_HQID,
                             szSelectedCompanyIDs,
                             DateTime.Today.AddDays(0 - Configuration.ClaimActivityNewThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss"),
                             DateTime.Today.AddDays(0 - Configuration.ClaimActivityMeritoriousThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss")};
            string szSQL = string.Format(SQL_GET_SELECTED_COMPANIES, args);
            szSQL += GetOrderByClause(gvSelectedCompanies);

            // Create empty grid view in case 0 results are found
            //((EmptyGridView)gvSelectedCompanies).EmptyTableRowText = GetNoResultsFoundMsg(Resources.Global.Companies);
            gvSelectedCompanies.ShowHeaderWhenEmpty = true;
            gvSelectedCompanies.EmptyDataText = GetNoResultsFoundMsg(Resources.Global.Companies);

            // Execute search and bind results to grid
            gvSelectedCompanies.DataSource = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection);
            gvSelectedCompanies.DataBind();
            EnableBootstrapFormatting(gvSelectedCompanies);

            OptimizeViewState(gvSelectedCompanies);

            // If no results are found, disable the buttons that require a company            
            if (gvSelectedCompanies.Rows.Count == 0)
            {
                btnReviseSelections.Enabled = false;
                //btnGenerateExport.Enabled = false;
                btnCompanyAnalysis.Enabled = false;
            }
        }

        /// <summary>
        /// Helper method applies security and hooks up the buttons
        /// to client-side validation.
        /// </summary>
        protected void ApplySecurity()
        {
            //PrepareButton(btnGenerateExport, false);
            PrepareButton(btnCompanyAnalysis, false);
        }

        /// <summary>
        /// Helper method used to create a request record the Company Analysis report when
        /// the company analysis page is loaded.
        /// </summary>
        protected void CreateCompanyAnalysisRequest()
        {
            // Insert CreateRequest record
            try
            {
                GetObjectMgr().CreateRequest("CA", GetRequestParameter("CompanyIDList"), hidTriggerPage.Value, null);
            }
            catch (Exception eX)
            {
                // There's nothing the end user can do about this so
                // just log it and keep moving.
                LogError(eX);

                if (Configuration.ThrowDevExceptions)
                {
                    throw;
                }
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

            // Store the CompanyID list and PRFinancialID list.  These will later
            // be used in our sql for the ratio computations on the page.
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                // Store company ID
                if (szCompanyIDs.Length > 0)
                    szCompanyIDs += ",";

                szCompanyIDs += ((GridView)sender).DataKeys[e.Row.DataItemIndex].Values[0].ToString();

                string szFinancialID = ((GridView)sender).DataKeys[e.Row.DataItemIndex].Values[1].ToString();
                if (!String.IsNullOrEmpty(szFinancialID))
                {
                    if (szFinancialIDs.Length > 0)
                        szFinancialIDs += ",";

                    szFinancialIDs += szFinancialID;
                }
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
        /// Handles the Get Business Report on click event.  Takes the user to the 
        /// BusinessReportConfirmSelectons page specifiying the selected company ids from this page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnBusinessReport_Click(object sender, EventArgs e)
        {
            // Set the CompanyIDList to the companies selected on this page
            SetRequestParameter("CompanyIDList", GetRequestParameter("cbCompAnalysisID"));
            Response.Redirect(string.Format(PageConstants.BUSINESS_REPORT_CONFIRM_SELECTIONS, string.Empty, string.Empty));
        }

        /// <summary>
        /// Handles the Generate Export File on click event.  Invokes the GetReport page 
        /// specifying the Company Analysis Export report type and including the appropriate parameters
        /// to generate the report.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnGenerateExport_Click(object sender, EventArgs e)
        {
            string szReportURL = "";
            string szRequestType = GetReport.COMPANY_ANALYSIS_EXPORT;

            // Create company analysis export url with appropriate parameters
            szReportURL = PageConstants.Format(PageConstants.GET_REPORT, szRequestType);

            // Store new CompanyIDList is stored in session 
            SetRequestParameter("CompanyIDList", GetRequestParameter("cbCompAnalysisID"));

            // Insert CreateRequest record
            try
            {
                GetObjectMgr().CreateRequest(szRequestType, GetRequestParameter("cbCompAnalysisID"), hidTriggerPage.Value, null);
            }
            catch (Exception eX)
            {
                // There's nothing the end user can do about this so
                // just log it and keep moving.
                LogError(eX);

                if (Configuration.ThrowDevExceptions)
                {
                    throw;
                }
            }

            Response.Redirect(szReportURL);
        }

        /// <summary>
        /// Handles the Get Company Analysis Report on click event handler.  Invokes the GetReport page
        /// specifying the Company Analysis Report report type and including the appropriate parameters
        /// to generate the report.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnCompanyAnalysis_Click(object sender, EventArgs e)
        {
            string szReportURL = "";
            string szRequestType = GetReport.COMPANY_ANALYSIS_REPORT;

            // Create company analysis export url with appropriate parameters
            szReportURL = PageConstants.Format(PageConstants.GET_REPORT, szRequestType);

            // Store new CompanyIDList is stored in session 
            Session["CompanyIDList"] = GetRequestParameter("cbCompAnalysisID");

            // Insert CreateRequest record
            try
            {
                GetObjectMgr().CreateRequest(szRequestType, GetRequestParameter("cbCompAnalysisID"), hidTriggerPage.Value, null);
            }
            catch (Exception eX)
            {
                // There's nothing the end user can do about this so
                // just log it and keep moving.
                LogError(eX);

                if (Configuration.ThrowDevExceptions)
                {
                    throw;
                }
            }

            Response.Redirect(szReportURL);
        }

        /// <summary>
        /// Helper method that prepares the button for use on the client page.
        /// </summary>
        /// <param name="oButton"></param>
        /// <param name="bOnlyOne">Indicates only one item can be selected by this button.</param>
        protected void PrepareButton(LinkButton oButton, bool bOnlyOne)
        {
            if (bOnlyOne)
            {
                oButton.Attributes.Add("onclick", "return confirmOneSelected('" + Resources.Global.Company + "', 'cbCompAnalysisID')");
            }
            else
            {
                oButton.Attributes.Add("onclick", "return confirmSelect('" + Resources.Global.Company + "', 'cbCompAnalysisID')");
            }
        }
        protected void PrepareButton(Image oButton, bool bOnlyOne)
        {
            if (bOnlyOne)
            {
                oButton.Attributes.Add("onclick", "return confirmOneSelected('" + Resources.Global.Company + "', 'cbCompAnalysisID')");
            }
            else
            {
                oButton.Attributes.Add("onclick", "return confirmSelect('" + Resources.Global.Company + "', 'cbCompAnalysisID')");
            }
        }

        List<string> _lSelectedIDs = null;

        /// <summary>
        /// Determines if the specified ID is part of the
        /// selected list.  If so, returns " checked ".
        /// </summary>
        /// <param name="iID"></param>
        /// <returns></returns>
        protected string GetChecked(int iID)
        {
            string szID = iID.ToString();

            // Only build our list of IDs once.
            _lSelectedIDs = new List<string>();

            string szSelectedIDs = GetRequestParameter("cbCompAnalysisID", false);
            if (!String.IsNullOrEmpty(szSelectedIDs))
            {
                string[] aszIDs = szSelectedIDs.Split(',');
                _lSelectedIDs.AddRange(aszIDs);
            }

            if (_lSelectedIDs.Contains(szID))
            {
                return " checked ";
            }
            else
            {
                return string.Empty;
            }
        }

        #region Build Computation Row Data
        /// <summary>
        /// Helper method used to build the Average ratio computation row data.
        /// </summary>
        /// <returns></returns>
        protected string GetAverageRowData()
        {
            StringBuilder sbRowData = new StringBuilder();

            // Handle the user selecting a group of companies that do not contain any 
            // financial statements
            if (String.IsNullOrEmpty(szFinancialIDs))
                szFinancialIDs = "0";

            // Format SQL to retrieve the average values 
            string szSQL = string.Format(SQL_GET_AVERAGE, szCompanyIDs);

            using (IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection))
            {
                oReader.Read();

                sbRowData.Append("<td style='width:60px' class='TopBorder text-center'>" + FormatDecimalDataForCell(oReader[0].ToString()) + "</td>");
                sbRowData.Append("<td style='width:60px' class='TopBorder text-center'>" + FormatDecimalDataForCell(oReader[1].ToString()) + "</td>");
                sbRowData.Append("<td style='width:80px' class='TopBorder text-center'>" + FormatDecimalDataForCell(oReader[2].ToString()) + "</td>");
                sbRowData.Append("<td style='width:95px' class='TopBorder text-center'>" + FormatDecimalDataForCell(oReader[3].ToString()) + "</td>");
                sbRowData.Append("<td style='width:60px' class='TopBorder text-center'>" + FormatDecimalDataForCell(oReader[4].ToString()) + "</td>");
                sbRowData.Append("<td style='width:60px' class='TopBorder text-center'>" + FormatDecimalDataForCell(oReader[5].ToString()) + "</td>");
                sbRowData.Append("<td style='width:60px' class='TopBorder text-center'>" + FormatDecimalDataForCell(oReader[6].ToString()) + "</td>");
                sbRowData.Append("<td style='width:70px' class='TopBorder text-center'>" + FormatDecimalDataForCell(oReader[7].ToString()) + "</td>");
                sbRowData.Append("<td style='width:90px;' class='TopBorder'>&nbsp;</td>");
            }

            szSQL = string.Format(SQL_GET_AVERAGE_BBS, szCompanyIDs);
            sbRowData.Append("<td width=\"60px\" align=\"center\" class=\"TopBorder\">" + FormatIntDataForCell(GetDBAccess().ExecuteScalar(szSQL)) + "</td>");

            return sbRowData.ToString();
        }

        /// <summary>
        /// Helper method used to build the Median ratio computation row data.
        /// </summary>
        /// <returns></returns>
        protected string GetMedianRowData()
        {
            StringBuilder sbRowData = new StringBuilder();

            sbRowData.Append("<td class='text-center noborder'>" + GetMedianValue("prfs_CurrentRatio") + "</td>");
            sbRowData.Append("<td class='text-center noborder'>" + GetMedianValue("prfs_QuickRatio") + "</td>");
            sbRowData.Append("<td class='text-center noborder'>" + GetMedianValue("prfs_ARTurnover") + "</td>");
            sbRowData.Append("<td class='text-center noborder'>" + GetMedianValue("prfs_DaysPayableOutstanding") + "</td>");
            sbRowData.Append("<td class='text-center noborder'>" + GetMedianValue("prfs_DebtToEquity") + "</td>");
            sbRowData.Append("<td class='text-center noborder'>" + GetMedianValue("prfs_FixedAssetsToNetWorth") + "</td>");
            sbRowData.Append("<td class='text-center noborder'>" + GetMedianValue("prfs_DebtServiceAbility") + "</td>");
            sbRowData.Append("<td class='text-center noborder'>" + GetMedianValue("prfs_OperatingRatio") + "</td>");
            sbRowData.Append("<td class='noborder'>&nbsp;</td>");
            sbRowData.Append("<td class='text-center noborder'>" + GetBBScoreMedianValue() + "</td>");

            return sbRowData.ToString();
        }

        /// <summary>
        /// Helper method used to build the 25 Percentile ratio computation row data
        /// </summary>
        /// <returns></returns>
        protected string Get25PercentileRowData()
        {
            StringBuilder sbRowData = new StringBuilder();

            sbRowData.Append("<td class='text-center noborder'>" + Get25PercentileValue("prfs_CurrentRatio") + "</td>");
            sbRowData.Append("<td class='text-center noborder'>" + Get25PercentileValue("prfs_QuickRatio") + "</td>");
            sbRowData.Append("<td class='text-center noborder'>" + Get25PercentileValue("prfs_ARTurnover") + "</td>");
            sbRowData.Append("<td class='text-center noborder'>" + Get25PercentileValue("prfs_DaysPayableOutstanding") + "</td>");
            sbRowData.Append("<td class='text-center noborder'>" + Get25PercentileValue("prfs_DebtToEquity") + "</td>");
            sbRowData.Append("<td class='text-center noborder'>" + Get25PercentileValue("prfs_FixedAssetsToNetWorth") + "</td>");
            sbRowData.Append("<td class='text-center noborder'>" + Get25PercentileValue("prfs_DebtServiceAbility") + "</td>");
            sbRowData.Append("<td class='text-center noborder'>" + Get25PercentileValue("prfs_OperatingRatio") + "</td>");
            sbRowData.Append("<td class='noborder'>&nbsp;</td>");
            sbRowData.Append("<td class='text-center noborder'>" + GetBBScore25PercentileValue() + "</td>");

            return sbRowData.ToString();
        }

        /// <summary>
        /// Helper method used to build the 75 Percentile ratio computation row data
        /// </summary>
        /// <returns></returns>
        protected string Get75PercentileRowData()
        {
            StringBuilder sbRowData = new StringBuilder();

            sbRowData.Append("<td class='text-center noborder'>" + Get75PercentileValue("prfs_CurrentRatio") + "</td>");
            sbRowData.Append("<td class='text-center noborder'>" + Get75PercentileValue("prfs_QuickRatio") + "</td>");
            sbRowData.Append("<td class='text-center noborder'>" + Get75PercentileValue("prfs_ARTurnover") + "</td>");
            sbRowData.Append("<td class='text-center noborder'>" + Get75PercentileValue("prfs_DaysPayableOutstanding") + "</td>");
            sbRowData.Append("<td class='text-center noborder'>" + Get75PercentileValue("prfs_DebtToEquity") + "</td>");
            sbRowData.Append("<td class='text-center noborder'>" + Get75PercentileValue("prfs_FixedAssetsToNetWorth") + "</td>");
            sbRowData.Append("<td class='text-center noborder'>" + Get75PercentileValue("prfs_DebtServiceAbility") + "</td>");
            sbRowData.Append("<td class='text-center noborder'>" + Get75PercentileValue("prfs_OperatingRatio") + "</td>");
            sbRowData.Append("<td class='noborder'>&nbsp;</td>");
            sbRowData.Append("<td class='text-center noborder'>" + GetBBScore75PercentileValue() + "</td>");

            return sbRowData.ToString();
        }

        /// <summary>
        /// Helper method used to build the Highest Value ratio computation row data
        /// </summary>
        /// <returns></returns>
        protected string GetHighestValueRowData()
        {
            StringBuilder sbRowData = new StringBuilder();

            string szSQL = string.Format(SQL_GET_MAX_VALUE, szCompanyIDs);

            using (IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection))
            {
                oReader.Read();

                for (int i = 0; i <= 7; i++)
                {
                    sbRowData.Append("<td class='text-center noborder'>" + FormatDecimalDataForCell(oReader[i].ToString()) + "</td>");
                }
                sbRowData.Append("<td class='noborder'>&nbsp;</td>");
            }

            szSQL = string.Format(SQL_GET_MAX_VALUE_BBS, szCompanyIDs);
            sbRowData.Append("<td width='50px' class='text-center noborder' >" + FormatIntDataForCell(GetDBAccess().ExecuteScalar(szSQL)) + "</td>");

            return sbRowData.ToString();
        }

        /// <summary>
        /// Helper method used to build the Lowest Value ratio computation row data
        /// </summary>
        /// <returns></returns>
        protected string GetLowestValueRowData()
        {
            StringBuilder sbRowData = new StringBuilder();

            string szSQL = string.Format(SQL_GET_MIN_VALUE, szCompanyIDs);

            using (IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection))
            {
                oReader.Read();

                for (int i = 0; i <= 7; i++)
                {
                    sbRowData.Append("<td class='text-center noborder'>" + FormatDecimalDataForCell(oReader[i].ToString()) + "</td>");
                }
                sbRowData.Append("<td class='noborder'>&nbsp;</td>");
            }

            szSQL = string.Format(SQL_GET_MIN_VALUE_BBS, szCompanyIDs);
            sbRowData.Append("<td width='50px' class='text-center noborder'>" + FormatIntDataForCell(GetDBAccess().ExecuteScalar(szSQL)) + "</td>");

            return sbRowData.ToString();
        }

        /// <summary>
        /// Helper method used to build the Standard Deviation ratio computation row data
        /// </summary>
        /// <returns></returns>        
        protected string GetStandardDeviationRowData()
        {
            StringBuilder sbRowData = new StringBuilder();

            string szSQL = string.Format(SQL_GET_STDEV_VALUE, szCompanyIDs);

            using (IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection))
            {
                oReader.Read();

                for (int i = 0; i <= 7; i++)
                {
                    sbRowData.Append("<td class='text-center noborder'>" + FormatDecimalDataForCell(oReader[i].ToString()) + "</td>");
                }

                sbRowData.Append("<td class='noborder'>&nbsp;</td>");
            }

            szSQL = string.Format(SQL_GET_STDEV_VALUE_BBS, szCompanyIDs);
            sbRowData.Append("<td class='text-center noborder'>" + FormatIntDataForCell(GetDBAccess().ExecuteScalar(szSQL)) + "</td>");

            return sbRowData.ToString();
        }
        #endregion

        #region Computation Row Data Helper Methods
        /// <summary>
        /// This will retrieve the 25 percentile value for the given field based on the companies selected
        /// financial ids.
        /// </summary>
        /// <param name="szFieldName"></param>
        /// <returns></returns>
        private string Get25PercentileValue(string szFieldName)
        {
            string szValue = "";

            // Create SQL to retrieve the 25 percentile value for this field based on the selected
            // companies financial ids.  The values will be separated into 4 groups in ascending order, and
            // the value will be calculated as the minimum value in group 2 of the 4.
            string szSQLGet25 = "SELECT MAX(" + szFieldName + ") AS " + szFieldName + "_25 " +
                "FROM ( " +
                "    SELECT " + szFieldName + ", " +
                "    NTILE(4) OVER(ORDER BY " + szFieldName + ") AS Percentile " +
                "    FROM PRFinancial " +
                "         INNER JOIN Company ON prfs_CompanyID = comp_CompanyID " +
                "    WHERE " + szFieldName + " IS NOT NULL " +
                "    AND prfs_FinancialID in ({0}) " +
                "    AND ISNULL(comp_PRConfidentialFS, 0) != '2' " +
                ") T1 " +
                "WHERE T1.Percentile = 1";

            string szSQL = string.Format(szSQLGet25, szFinancialIDs);

            IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection);
            try
            {
                oReader.Read();

                szValue = FormatDecimalDataForCell(oReader[0]);
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }

            return szValue;
        }

        /// <summary>
        /// This will retrieve the 75 percentile value for the given field based on the companies selected
        /// financial ids.
        /// </summary>
        /// <param name="szFieldName"></param>
        /// <returns></returns>
        private string Get75PercentileValue(string szFieldName)
        {
            string szValue = "";

            // Create SQL to retrieve the 75 percentile value for this field based on the selected
            // companies financial ids.  The values will be separated into 4 groups in ascending order, and
            // the value will be calculated as the maximum value in group 3 of the 4.
            string szSQLGet75 = "SELECT MAX(" + szFieldName + ") AS " + szFieldName + "_75 " +
                "FROM ( " +
                "    SELECT " + szFieldName + ", " +
                "    NTILE(4) OVER(ORDER BY " + szFieldName + ") AS Percentile " +
                "    FROM PRFinancial " +
                "         INNER JOIN Company ON prfs_CompanyID = comp_CompanyID " +
                "    WHERE " + szFieldName + " IS NOT NULL " +
                "    AND prfs_FinancialID in ({0}) " +
                "    AND ISNULL(comp_PRConfidentialFS, 0) != '2' " +
                ") T1 " +
                "WHERE T1.Percentile = 3";

            string szSQL = string.Format(szSQLGet75, szFinancialIDs);

            IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection);
            try
            {
                oReader.Read();

                szValue = FormatDecimalDataForCell(oReader[0]);
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }

            return szValue;
        }

        /// <summary>
        /// This will retrieve the median value for the given field based on the companies selected financial IDs.
        /// For an even number of records the statistical median value will be calculated - the lower 
        /// of the two middle values will be used.  Null values will be ignored.
        /// </summary>
        /// <param name="szFieldName"></param>
        /// <returns></returns>
        private string GetMedianValue(string szFieldName)
        {
            string szValue = "";

            // Create SQL to retrieve the Median value for this field based on the selected
            // companies financial ids.  The values will be separated into 2 groups in ascending order, and
            // the value will be calculated as the maximum value in group 1 of 2.
            string szSQLGetMedian = "SELECT MAX(" + szFieldName + ") AS " + szFieldName + "_MED " +
                "FROM ( " +
                "    SELECT " + szFieldName + ", " +
                "    NTILE(2) OVER(ORDER BY " + szFieldName + ") AS Percentile " +
                "    FROM PRFinancial " +
                "         INNER JOIN Company ON prfs_CompanyID = comp_CompanyID " +
                "    WHERE " + szFieldName + " IS NOT NULL " +
                "    AND prfs_FinancialID in ({0}) " +
                "    AND ISNULL(comp_PRConfidentialFS, 0) != '2' " +
                ") T1 " +
                "WHERE T1.Percentile = 1";

            string szSQL = string.Format(szSQLGetMedian, szFinancialIDs);

            IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection);
            try
            {
                oReader.Read();

                szValue = FormatDecimalDataForCell(oReader[0]);
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }

            return szValue;
        }
        #endregion

        #region BB Score Ratio Computation Helper Methods
        // NOTE: This done separately from the other PRFinancial fields to include the additional restrictions
        // on the BB Score data

        /// <summary>
        /// This will retrieve the 25 percentile value for the BB Score based on the companies selected
        /// ids.
        /// </summary>
        private string GetBBScore25PercentileValue()
        {
            string szValue = "";

            // Create SQL to retrieve the 25 percentile value for the BB Score based on the selected
            // companies ids.  The values will be separated into 4 groups in ascending order, and
            // the value will be calculated as the minimum value in group 2 of the 4.
            string szSQLGet25 = "SELECT MAX(prbs_BBScore) AS prbs_BBScore_25 " +
                "FROM ( " +
                "    SELECT prbs_BBScore, " +
                "    NTILE(4) OVER(ORDER BY prbs_BBScore) AS Percentile " +
                "    FROM COMPANY " +
                "    LEFT OUTER JOIN PRBBScore ON comp_CompanyID = prbs_CompanyID AND prbs_Current='Y' AND prbs_PRPublish = 'Y' and comp_PRPublishBBScore='Y' " +
                "    WHERE prbs_BBScore IS NOT NULL " +
                "    AND comp_CompanyID in ({0}) " +
                ") T1 " +
                "WHERE T1.Percentile = 1";

            string szSQL = string.Format(szSQLGet25, szCompanyIDs);

            IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection);
            try
            {
                oReader.Read();

                szValue = FormatIntDataForCell(oReader[0]);
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }

            return szValue;
        }

        /// <summary>
        /// This will retrieve the 75 percentile value for the given field based on the companies selected
        /// ids.
        /// </summary>
        private string GetBBScore75PercentileValue()
        {
            string szValue = "";

            // Create SQL to retrieve the 75 percentile value for the BB Score based on the selected
            // companies ids.  The values will be separated into 4 groups in ascending order, and
            // the value will be calculated as the maximum value in group 3 of the 4.
            string szSQLGet75 = "SELECT MAX(prbs_BBScore) AS prbs_BBScore_75 " +
                "FROM ( " +
                "    SELECT prbs_BBScore, " +
                "    NTILE(4) OVER(ORDER BY prbs_BBScore) AS Percentile " +
                "    FROM COMPANY WITH (NOLOCK) " +
                "    LEFT OUTER JOIN PRBBScore ON comp_CompanyID = prbs_CompanyID AND prbs_Current='Y' AND prbs_PRPublish = 'Y' and comp_PRPublishBBScore='Y'  " +
                "    WHERE prbs_BBScore IS NOT NULL " +
                "    AND comp_CompanyID in ({0}) " +
                ") T1 " +
                "WHERE T1.Percentile = 3";

            string szSQL = string.Format(szSQLGet75, szCompanyIDs);

            IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection);
            try
            {
                oReader.Read();

                szValue = FormatIntDataForCell(oReader[0]);
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }

            return szValue;
        }

        /// <summary>
        /// This will retrieve the median value for the BBScore field based on the companies selected IDs.
        /// For an even number of records the statistical median value will be calculated - the lower 
        /// of the two middle values will be used.  Null values will be ignored.
        /// </summary>
        private string GetBBScoreMedianValue()
        {
            string szValue = "";

            // Create SQL to retrieve the Median value for the BB Score based on the selected
            // companies ids.  The values will be separated into 2 groups in ascending order, and
            // the value will be calculated as the maximum value in group 1 of 2.
            string szSQLGetMedian = "SELECT MAX(prbs_BBScore) AS prbs_BBScore_MED " +
                "FROM ( " +
                "    SELECT prbs_BBScore, " +
                "    NTILE(2) OVER(ORDER BY prbs_BBScore) AS Percentile " +
                "    FROM COMPANY WITH (NOLOCK) " +
                "    LEFT OUTER JOIN PRBBScore ON comp_CompanyID = prbs_CompanyID AND prbs_Current='Y' AND prbs_PRPublish = 'Y' and comp_PRPublishBBScore='Y'  " +
                "    WHERE prbs_BBScore IS NOT NULL " +
                "    AND comp_CompanyID in ({0}) " +
                ") T1 " +
                "WHERE T1.Percentile = 1";

            string szSQL = string.Format(szSQLGetMedian, szCompanyIDs);

            IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection);
            try
            {
                oReader.Read();

                szValue = FormatIntDataForCell(oReader[0]);
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }

            return szValue;
        }
        #endregion

        #region Format Functions
        /// <summary>
        /// Helper method used to display decimal data on the page.  If the value is null or empty
        /// "n/a" will be displayed.
        /// </summary>
        /// <param name="oValue"></param>
        /// <returns></returns>
        protected string FormatDecimalDataForCell(object oValue)
        {
            return FormatDecimalDataForCell(oValue, DBNull.Value);
        }

        protected string FormatDecimalDataForCell(object oValue, object confidentialFlag)
        {
            if (confidentialFlag != System.DBNull.Value && Convert.ToString(confidentialFlag) == "2")
            {
                return "n/d";
            }

            if (oValue == System.DBNull.Value || String.IsNullOrEmpty(oValue.ToString()))
            {
                return "n/a";
            }

            decimal dValue = Convert.ToDecimal(oValue);
            return dValue.ToString("###,##0.00");
        }

        /// <summary>
        /// Helper method used to display integer data on the page.  If the value is null or empty
        /// "n/a" will be displayed.
        /// </summary>
        /// <param name="oValue"></param>
        /// <returns></returns>
        protected string FormatIntDataForCell(object oValue)
        {
            if (oValue == System.DBNull.Value || String.IsNullOrEmpty(oValue.ToString()))
                return "&nbsp;";
            else
            {
                decimal dValue = Convert.ToDecimal(oValue);
                return dValue.ToString("###,##0");
            }
        }

        /// <summary>
        /// Helper method used to translate a statement type of "Unknown" to "n/a" for this page.
        /// </summary>
        /// <param name="szStatementType"></param>
        /// <returns></returns>
        protected string GetStatementTypeDataForCell(string szStatementType)
        {
            string szStatementTypeValue = szStatementType;

            if (szStatementTypeValue == "Unknown")
                szStatementTypeValue = "n/a";

            return szStatementTypeValue;
        }
        #endregion
    }
}