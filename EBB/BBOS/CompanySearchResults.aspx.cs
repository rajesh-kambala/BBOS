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

 ClassName: CompanySearchResults
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/

using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Executes the specified search and populates the page.
    /// 
    /// NOTE: A lot remains to be done.  The bare minimum was implemented
    /// in order to test other portions of the system.
    /// </summary>
    public partial class CompanySearchResults : CompanySearchBase
    {
        protected const string SQL_SEARCH =
            @"SELECT {0} {5}.*, 
                     dbo.ufn_GetCustomCaptionValue('comp_PRIndustryTypeBBOS', comp_PRIndustryType, '{1}') As IndustryType,
                     dbo.ufn_GetCustomCaptionValue('comp_PRType_BBOS', comp_PRType, '{1}') As CompanyType, 
                     dbo.ufn_HasNote({2}, {3}, comp_CompanyID, 'C') As HasNote,
                     dbo.ufn_HasNewClaimActivity(comp_PRHQID, '{6}') as HasNewClaimActivity, 
                     dbo.ufn_HasMeritoriousClaim(comp_PRHQID, '{7}') as HasMeritoriousClaim,
                     dbo.ufn_HasCertification(comp_PRHQID) as HasCertification,
                     dbo.ufn_HasCertification_Organic(comp_PRHQID) as HasCertification_Organic,
                     dbo.ufn_HasCertification_FoodSafety(comp_PRHQID) as HasCertification_FoodSafety,
                     CASE WHEN comp_PRType = 'B' THEN CASE WHEN compRating.prra_RatingID IS NOT NULL THEN 'N' ELSE 'Y' END ELSE 'N' END AS IsHQRating,
                     CASE WHEN comp_PRType = 'B' THEN CASE WHEN compRating.prra_RatingID IS NOT NULL THEN compRating.prra_RatingID ELSE hqRating.prra_RatingID END ELSE hqRating.prra_RatingID END AS prra_RatingID,
                     CASE WHEN comp_PRType = 'B' THEN CASE WHEN compRating.prra_RatingID IS NOT NULL THEN compRating.prra_RatingLine ELSE hqRating.prra_RatingLine END ELSE hqRating.prra_RatingLine END AS prra_RatingLine,
                     compProfile.prcp_SalvageDistressedProduce,
	                 OnWatchdogList,
                     dbo.ufn_GetWatchdogGroupsForList({2}, comp_CompanyID) WatchdogList
                FROM {5} 
                     LEFT OUTER JOIN vPRCurrentRating compRating ON comp_CompanyID = compRating.prra_CompanyID 
                     LEFT OUTER JOIN vPRCurrentRating hqRating ON comp_PRHQID = hqRating.prra_CompanyID 
                     LEFT OUTER JOIN PRCompanyProfile compProfile WITH (NOLOCK) ON comp_CompanyID = compProfile.prcp_CompanyID 
	                 LEFT OUTER JOIN (SELECT DISTINCT prwuld_AssociatedID, 'Y' As OnWatchdogList
                                        FROM PRWebUserList WITH (NOLOCK) 
                                             INNER JOIN PRWebUserListDetail WITH (NOLOCK) ON prwucl_WebUserListID = prwuld_WebUserListID AND prwuld_Deleted IS NULL 
                                       WHERE ((prwucl_HQID = {3} AND prwucl_IsPrivate IS NULL) 
                                          OR (prwucl_WebUserID={2} AND prwucl_IsPrivate = 'Y'))) tblWD ON prwuld_AssociatedID = comp_CompanyID
               WHERE comp_CompanyID IN ({4})";

        private string szSelectedIDs = "";

        /// <summary>
        /// Calls page functions required to build and process this page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override protected void Page_Load(object sender, EventArgs e)
        {
            _bReturnNullIfNoCriteriaFound = true;
            base.Page_Load(sender, e);

            // Set page title, sub-title
            SetPageTitle(Resources.Global.CompanySearch, Resources.Global.SearchResults);

            Session["ReturnURL"] = PageConstants.COMPANY_SEARCH_RESULTS_EXECUTE_LAST;

            if (!IsPostBack)
            {
                // Populate form -> execute search
                LoadLookupValues();
                PopulateForm();
            }

            ApplySecurity();
            SetVisiblity();

            // See issue #54.  Hiding it from the user for now.
            // We should probably remove the code at some point but
            // restoring it would be a pain so let's make sure this
            // is want we want to do first.
            // btnNewSearch.Visible = false;
        }

        protected void LoadLookupValues()
        {
        }

        /// <summary>
        /// Check users page level authorization
        /// </summary>
        /// <returns></returns>
        override protected bool IsAuthorizedForPage()
        {
            // All users can view company search results
            return true;
        }

        /// <summary>
        /// Check users control/data level authorization
        /// </summary>
        /// <returns></returns>
        protected override bool IsAuthorizedForData()
        {
            return true;
        }

        protected string HTML_NOTHING_FOUND =
            @"<div class=NoticeBox style=width:600px;margin-left:auto;margin-right:auto;margin-top:10px;margin-bottom:25px>" + Resources.Global.NoCompaniesFoundMatchingCriteria + "</div>";

        /*
        No Companies were found that match the specified criteria.If you can not locate a specific company in BBOS, Blue Book
        Services will attempt to gather and validate the information required to be listed.Simply use the<a href={0}>Feedback
        Form</a> to provide information about the unlisted company of interest.
        */
        /// <summary>
        /// Executes the specified search and populates the form.
        /// </summary>
        protected void PopulateForm()
        {
            // Retrieve the web user search criteria object
            IPRWebUserSearchCriteria oWebUserSearchCriteria;

            // If requested, retrieve the last executed search
            if (!String.IsNullOrEmpty(GetRequestParameter("ExecuteLastSearch", false)))
                oWebUserSearchCriteria = GetLastExecuted();
            else
                oWebUserSearchCriteria = GetSearchCritieria(_iSearchID, PRWebUserSearchCriteria.SEARCH_TYPE_COMPANY, true);

            // If we get this far and still don't have criteria, go get 
            // the last search executed.
            if (oWebUserSearchCriteria == null)
                oWebUserSearchCriteria = GetLastExecuted();

            // Finnally just throw an exception.
            if (oWebUserSearchCriteria == null)
            {
                if ((_oUser == null) ||
                    (string.IsNullOrEmpty(_oUser.prwu_DefaultCompanySearchPage)))
                {
                    Response.Redirect(PageConstants.COMPANY_SEARCH);
                    return;
                }

                Response.Redirect(_oUser.prwu_DefaultCompanySearchPage);
                return;
            }

            PopulateMicroslider((CompanySearchCriteria)oWebUserSearchCriteria.Criteria);

            // Set Search Criteria User Control
            ucAdvancedCompanySearchCriteriaControl.CompanySearchCriteria = (CompanySearchCriteria)oWebUserSearchCriteria.Criteria;
            ucAdvancedCompanySearchCriteriaControl._bHorizontalDisplay = true;
            if (ucAdvancedCompanySearchCriteriaControl.CompanySearchCriteria.IsQuickSearch)
                ucAdvancedCompanySearchCriteriaControl.Visible = false;

            // Retrieve previously selected ids so we can recheck selections on grid
            szSelectedIDs = oWebUserSearchCriteria.prsc_SelectedIDs;

            string searchView = null;
            string searchLimit = null;
            if (IsPRCoUser())
            {
                searchView = "vPRBBOSCompanyList_ALL";
                searchLimit = string.Empty;
            }
            else
            {
                searchView = "vPRBBOSCompanyList";
                searchLimit = "TOP " + Configuration.CompanySearchMaxResults.ToString();
            }

            // Generate the sql required to retrieve the search results            
            ArrayList oParameters;
            object[] args = {searchLimit,
                             _oUser.prwu_Culture,
                             _oUser.prwu_WebUserID,
                             _oUser.prwu_HQID,
                             oWebUserSearchCriteria.Criteria.GetSearchSQL(out oParameters),
                             searchView,
                             DateTime.Today.AddDays(0 - Configuration.ClaimActivityNewThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss"),
                             DateTime.Today.AddDays(0 - Configuration.ClaimActivityMeritoriousThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss")};
            string szSQL = string.Format(SQL_SEARCH, args);

            szSQL += GetOrderByClause(gvSearchResults);

            // Optionally display debugging information on this page
            DisplayDebuggingData(szSQL, oParameters);

            // Create empty grid view in case 0 results are found
            //((EmptyGridView)gvSearchResults).EmptyTableRowText = string.Format(HTML_NOTHING_FOUND, PageConstants.FEEDBACK + "?FeedbackType=RULC");
            gvSearchResults.ShowHeaderWhenEmpty = true;
            gvSearchResults.EmptyDataText = string.Format(HTML_NOTHING_FOUND, PageConstants.FEEDBACK + "?FeedbackType=RULC");

            // Execute search and bind results to grid
            gvSearchResults.DataSource = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            gvSearchResults.DataBind();

            if (gvSearchResults.Rows.Count > 0)
            {
                LinkButton lbTypeIndustryColHeader = (LinkButton)gvSearchResults.HeaderRow.FindControl("lbTypeIndustryColHeader");
                lbTypeIndustryColHeader.Text = PageControlBaseCommon.GetIndustryTypeHeader(_oUser);
            }

            EnableBootstrapFormatting(gvSearchResults);

            OptimizeViewState(gvSearchResults);

            // Only query for the total number of rows if our
            // limit was reached on the main query.
            if (gvSearchResults.Rows.Count == Configuration.CompanySearchMaxResults)
            {
                ArrayList oCountParameters;
                string szCountSQL = oWebUserSearchCriteria.Criteria.GetSearchCountSQL(out oCountParameters);

                int iCount = (int)GetDBAccess().ExecuteScalar(szCountSQL, oCountParameters);
                if (iCount > Configuration.CompanySearchMaxResults)
                {
                    AddUserMessage(string.Format(GetMaxResultsMsg(), iCount.ToString("###,##0"), Configuration.CompanySearchMaxResults.ToString("###,##0")));
                }
            }

            // Display the number of matching records found
            lblRecordCount.Text = string.Format(Resources.Global.CompaniesCountFoundMsg, gvSearchResults.Rows.Count);

            // Update the statics for the current search
            oWebUserSearchCriteria.prsc_ExecutionCount++;
            oWebUserSearchCriteria.prsc_LastExecutionDateTime = DateTime.Now;
            oWebUserSearchCriteria.prsc_LastExecutionResultCount = gvSearchResults.Rows.Count;

            // Save the updated search data
            PRWebUserSearchCriteriaMgr oWebUserSearchCriteriaMgr = new PRWebUserSearchCriteriaMgr(_oLogger, _oUser);

            if (!IsImpersonating())
            {
                // Save this search as the last unsaved search in the system.
                oWebUserSearchCriteriaMgr.SaveLastSearch((PRWebUserSearchCriteria)oWebUserSearchCriteria, null);
                int iSearchAuditTrailID = 0;
                try
                {
                    // Create a search audit record
                    IDbTransaction oTran = GetObjectMgr().BeginTransaction();

                    int iSearchWizardAuditTrailID = 0;
                    if (GetRequestParameter("IsSearchWizard", false) != null)
                    {
                        iSearchWizardAuditTrailID = GetObjectMgr().InsertSearchWizardAuditTrail(Convert.ToInt32(GetRequestParameter("SearchWizardID")),
                                                                                                (List<string>)Session["SearchWizardAnswers"],
                                                                                                oTran);
                    }

                    iSearchAuditTrailID = GetObjectMgr().InsertSearchAuditTrail(oWebUserSearchCriteria, iSearchWizardAuditTrailID, oTran);
                    GetObjectMgr().Commit();
                }
                catch (Exception eX)
                {
                    GetObjectMgr().Rollback();

                    // There's nothing the end user can do about this so
                    // just log it and keep moving.
                    LogError(eX);

                    if (Configuration.ThrowDevExceptions)
                    {
                        throw;
                    }
                }
            }

            if (GetRequestParameter("IsSearchWizard", false) != null)
            {
                RemoveRequestParameter("IsSearchWizard");
            }

            // If no results are found, disable the buttons that require a company            
            if (gvSearchResults.Rows.Count == 0)
            {
                DisableButtons();
                DisplayZeroResultsFeedback();
            }

            // Determine if we should redirect to the company details if only one company was found
            // The user must have the appropriate security access for this.
            else if (gvSearchResults.Rows.Count == 1)
            {
                if ((_oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchResultsAutoRedirect1Result).HasPrivilege) &&
                    (Configuration.DisplayDetailsForOneResult))
                {
                    int iCompanyID = Convert.ToInt32(gvSearchResults.DataKeys[0].Value.ToString());
                    if (((CompanySearchCriteria)oWebUserSearchCriteria.Criteria).IndustryType != GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                        if (_oUser.IsLimitado)
                            Response.Redirect(string.Format("~/LimitadoCompany.aspx?CompanyID={0}", iCompanyID));
                        else
                            Response.Redirect(PageConstants.Format(PageConstants.COMPANY, iCompanyID));
                    else
                        Response.Redirect(PageConstants.Format(PageConstants.COMPANY_DETAILS_SUMMARY, iCompanyID));

                    return;
                }
            }

            int adCount = 0;

            adCount = gvSearchResults.Rows.Count / Configuration.CompanySearchResultsOneAdPerCompanyCount;

            if (gvSearchResults.PageCount % Configuration.CompanySearchResultsOneAdPerCompanyCount != 0)
            {
                adCount++;
            }

            if (adCount < Configuration.CompanySearchResultsMinAdCount)
            {
                adCount = Configuration.CompanySearchResultsMinAdCount;
            }

            if (adCount > Configuration.CompanySearchResultsMaxAdCount)
            {
                adCount = Configuration.CompanySearchResultsMaxAdCount;
            }

            Advertisement.Logger = _oLogger;
            Advertisement.WebUser = _oUser;
            Advertisement.MaxAdCount = adCount;
            Advertisement.LoadAds();

            DisplayKYC((CompanySearchCriteria)oWebUserSearchCriteria.Criteria);

            if (Configuration.CompanySearchLocalSourceCountMsgEnabled &&
                (((CompanySearchCriteria)oWebUserSearchCriteria.Criteria).IndustryType == GeneralDataMgr.INDUSTRY_TYPE_PRODUCE) &&
                (!_oUser.HasLocalSourceDataAccess()))
            {
                IPRWebUserSearchCriteria localSourceCriteria = (IPRWebUserSearchCriteria)oWebUserSearchCriteria.Copy();
                localSourceCriteria.Criteria.IsLocalSourceCountOverride = true;
                localSourceCriteria.Criteria.IncludeLocalSource = "LSO";
                localSourceCriteria.WebUser = _oUser;

                ArrayList oCountParameters;
                string szCountSQL = localSourceCriteria.Criteria.GetSearchCountSQL(out oCountParameters);

                int iCount = (int)GetDBAccess().ExecuteScalar(szCountSQL, oCountParameters);
                if (iCount > 1)
                {
                    pnlLocalSourceMsg.Visible = true;
                    litLocalSourceCount.Text = iCount.ToString("###,###");
                }
            }

            //Exports management
            ExportsManagement(hidExportsPeriod, hidExportsMax, hidExportsUsed);
        }

        /// <summary>
        /// Helper method that helps with bi-directional sorting
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
            DisplayLocalSource(e);

            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                HyperLink hlCompanyDetails = (HyperLink)e.Row.FindControl("hlCompanyDetails");
                int iCompanyID = Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "comp_CompanyID"));

                if (_oUser.prwu_CompanyLinksNewTab)
                    hlCompanyDetails.Target = "_blank";

                if (_oUser.IsLimitado)
                    hlCompanyDetails.NavigateUrl = string.Format("~/LimitadoCompany.aspx?CompanyID={0}", iCompanyID);
                else
                    hlCompanyDetails.NavigateUrl = string.Format("~/Company.aspx?CompanyID={0}", iCompanyID);
            }
        }

        /// <summary>
        /// Helper method applies security and hooks up the buttons
        /// to client-side validation.
        /// </summary>
        protected void ApplySecurity()
        {
            PrepareButton(btnReports, false);

            PrepareButton(btnAddToWatchdog, false);
            PrepareButton(btnSubmitTES, false);
            PrepareButton(btnCustomFieldEdit, false);

            btnAnalyzeCompanies.Attributes.Add("onclick", "if(!LimitCheckCount('" + Resources.Global.Companies + "', 'cbCompanyID', '" + Resources.Global.AnalyzeCompanies + "', " + Utilities.GetConfigValue("CompanyAnalysisMaximumCompanies", "50") + ")) return false; ");

            ApplySecurity(btnAddToWatchdog, SecurityMgr.Privilege.WatchdogListAdd);
            ApplySecurity(btnExportData, SecurityMgr.Privilege.DataExportPage);
            ApplySecurity(btnSaveSearch, SecurityMgr.Privilege.SaveSearches);
            ApplySecurity(btnCustomFieldEdit, SecurityMgr.Privilege.CustomFields);
            ApplySecurity(btnAnalyzeCompanies, SecurityMgr.Privilege.CompanyAnalysisPage);
            ApplySecurity(btnSubmitTES, SecurityMgr.Privilege.TradeExperienceSurveyPage);
            ApplySecurity(btnMap, SecurityMgr.Privilege.ViewMap);

            if (_oUser.IsTrialPeriodActive())
            {
                btnExportData.Disabled = true;
            }

            ApplyReadOnlyCheck(btnSaveSearch);
            ApplyReadOnlyCheck(btnSubmitTES);
            ApplyReadOnlyCheck(btnAddToWatchdog);
            ApplyReadOnlyCheck(btnCustomFieldEdit);

            if (!_oUser.HasPrivilege(SecurityMgr.Privilege.ViewRating).HasPrivilege)
            {
                gvSearchResults.Columns[7].Visible = false;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="szSQL"></param>
        /// <param name="oParameters"></param>
        protected void DisplayDebuggingData(string szSQL, IList oParameters)
        {
            if (!Utilities.GetBoolConfigValue("DisplayCompanySearchDebugging", false))
            {
                return;
            }

            pnlDebug.Visible = true;

            lblSQL.Text = szSQL;

            // Spin through our SQL parms adding 
            // them to our format array 
            StringBuilder szParameters = new StringBuilder();
            foreach (ObjectParameter oParameter in oParameters)
            {
                string szName = oParameter.Name.ToString();
                string szValue = oParameter.Value.ToString();

                szParameters.Append("DECLARE @" + szName);

                if (oParameter.Value is string)
                {
                    szParameters.Append(" varchar(100) = ");
                }

                if (oParameter.Value is DateTime)
                {
                    szParameters.Append(" datetime = ");
                }

                if (oParameter.Value is Int32)
                {
                    szParameters.Append(" int = ");
                }

                if ((oParameter.Value is string) ||
                    (oParameter.Value is DateTime))
                {
                    szParameters.Append("'");
                }

                szParameters.Append(szValue);
                if ((oParameter.Value is string) ||
                    (oParameter.Value is DateTime))
                {
                    szParameters.Append("'");
                }

                szParameters.Append("<br/>");
            }

            lblParameters.Text = szParameters.ToString();
        }

        /// <summary>
        /// 
        /// </summary>
        protected void DisableButtons()
        {
            btnExportData.Disabled = true;
            btnReports.Disabled = true;
            btnPrintList.Disabled = true;
            btnAddToWatchdog.Disabled = true;
            btnSubmitTES.Disabled = true;
            btnAnalyzeCompanies.Disabled = true;
        }

        #region Button OnClick event handlers
        /// <summary>
        /// Handles the Submit Trade Survey on click event.  Invokes the Save Selected function to save
        /// the selected company's on the form, and takes the user to the TradeExperienceSurvey.aspx page 
        /// for the selected company.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnSubmitTESOnClick(object sender, EventArgs e)
        {
            SaveSelected();

            SetRequestParameter("CompanyIDList", GetRequestParameter("cbCompanyID"));
            Response.Redirect(PageConstants.TES);
        }

        /// <summary>
        /// Takes the user to the page specified by the PRWebUser.DefaultCompanySearchPage.  
        /// If none is found, redirects the user the CompanySearch.aspx page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnEditSearchCriteria_Click(object sender, EventArgs e)
        {
            IPRWebUserSearchCriteria oWebUserSearchCriteria = GetSearchCritieria(_iSearchID, PRWebUserSearchCriteria.SEARCH_TYPE_COMPANY, true);

            if (oWebUserSearchCriteria == null)
            {
                if(_oUser.IsLimitado)
                    Response.Redirect(PageConstants.LIMITADO_SEARCH + "?SearchID=" + _iSearchID.ToString());
                else
                    Response.Redirect(PageConstants.COMPANY_SEARCH + "?SearchID=" + _iSearchID.ToString());
            }
            else
            {
                Response.Redirect(GetEditCriteriaURL((CompanySearchCriteria)oWebUserSearchCriteria.Criteria));
            }
        }

        /// <summary>
        /// Handles the Reports on click event.  Invokes the Save Selected function to save
        /// the selected company's on the form, and takes the user to the ReportsConfirmSelections.aspx page 
        /// for the selected companies.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnReports_Click(object sender, EventArgs e)
        {
            SaveSelected();
            SetRequestParameter("CompanyIDList", GetRequestParameter("cbCompanyID"));
            Response.Redirect(PageConstants.REPORTS_CONFIRM_SELECTION);
        }

        /// <summary>
        /// Handles the Maps on click event.  Invokes the Save Selected function to save
        /// the selected company's on the form.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnMap_Click(object sender, EventArgs e)
        {
            SaveSelected();
            SetRequestParameter("CompanyIDList", GetRequestParameter("cbCompanyID"));
            ClientScript.RegisterStartupScript(this.GetType(), "map", "displayMap();", true);
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
            SaveSelected();
            SetRequestParameter("CompanyIDList", GetRequestParameter("cbCompanyID"));
            Response.Redirect(PageConstants.USER_LIST_ADD_TO);
        }

        /// <summary>
        /// Handles the Get Marketing List on click event.  Invokes the Save Selected function to save
        /// the selected company's on the form, and takes the user to the DataExportConfirmSelections.aspx 
        /// page specifying the selected companies.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnExportData_Click(object sender, EventArgs e)
        {
            SaveSelected();
            SetRequestParameter("CompanyIDList", GetRequestParameter("cbCompanyID"));
            Response.Redirect(PageConstants.DATA_EXPORT_CONFIRM_SELECTIONS);
        }


        protected void btnCustomFieldEdit_Click(object sender, EventArgs e)
        {
            SaveSelected();
            SetRequestParameter("CompanyIDList", GetRequestParameter("cbCompanyID"));
            Response.Redirect("CustomFieldCompanyBulkEdit.aspx");
        }


        /// <summary>
        /// Handles the Analyze Companies on click event.  Invokes the Save Selected function to save
        /// the selected company's on the form, and takes the user to the CompanyAnalysis.aspx 
        /// page specifying the selected companies.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnAnalyzeCompanies_Click(object sender, EventArgs e)
        {
            SaveSelected();
            SetRequestParameter("CompanyIDList", GetRequestParameter("cbCompanyID"));
            Response.Redirect(PageConstants.COMPANY_ANALYSIS);
        }
        #endregion

        /// <summary>
        /// Saves the selected company IDs
        /// </summary>
        private void SaveSelected()
        {
            string[] aCompanyIDs = GetRequestParameter("cbCompanyID").Split(',');
            if (aCompanyIDs.Length <= Utilities.GetIntConfigValue("CompanySearchResultsSelectedThreshold", 1100))
            {
                IPRWebUserSearchCriteria oWebUserSearchCriteria = GetSearchCritieria(_iSearchID, PRWebUserSearchCriteria.SEARCH_TYPE_COMPANY);
                oWebUserSearchCriteria.prsc_SelectedIDs = GetRequestParameter("cbCompanyID");

                PRWebUserSearchCriteriaMgr oWebUserSearchCriteriaMgr = new PRWebUserSearchCriteriaMgr(_oLogger, _oUser);
                oWebUserSearchCriteriaMgr.SaveLastSearch((PRWebUserSearchCriteria)oWebUserSearchCriteria, null); //fix bug where 1st search wasn't saved to database - Defect 3847 (jeff and chris debugged this together)
                oWebUserSearchCriteriaMgr.SaveSelected(oWebUserSearchCriteria, null);
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
            if (_lSelectedIDs == null)
            {
                _lSelectedIDs = new List<string>();

                // Check SelectedIDs on web user search criteria object
                if (!String.IsNullOrEmpty(szSelectedIDs))
                {
                    string[] aszIDs = szSelectedIDs.Split(',');
                    _lSelectedIDs.AddRange(aszIDs);
                }
                else
                {
                    // Commented out by CHW.  Not entirely certain if
                    // we want to remove this just yet.
                    // TODO: Determine if this code is needed.
                    //// If these can't be found, lets check the session
                    //szSelectedIDs = GetRequestParameter("CompanyIDList", false);
                    //if (!String.IsNullOrEmpty(szSelectedIDs))
                    //{
                    //    string[] aszIDs = szSelectedIDs.Split(',');
                    //    _lSelectedIDs.AddRange(aszIDs);
                    //}
                }
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

        /// <summary>
        /// Helper method that prepares the button for use on the client page.
        /// </summary>
        /// <param name="oButton"></param>
        /// <param name="bOnlyOne">Indicates only one item can be selected by this button.</param>
        protected void PrepareButton(LinkButton oButton, bool bOnlyOne)
        {
            if (bOnlyOne)
            {
                oButton.Attributes.Add("onclick", "return confirmOneSelected('" + Resources.Global.Company + "', 'cbCompanyID');");
            }
            else
            {
                oButton.Attributes.Add("onclick", "return confirmSelect('" + Resources.Global.Company + "', 'cbCompanyID');");
            }
        }
        protected void PrepareButton(HtmlButton oButton, bool bOnlyOne)
        {
            if (bOnlyOne)
            {
                oButton.Attributes.Add("onclick", "if (!confirmOneSelected('" + Resources.Global.Company + "', 'cbCompanyID')) return false;");
            }
            else
            {
                oButton.Attributes.Add("onclick", "if (!confirmSelect('" + Resources.Global.Company + "', 'cbCompanyID')) return false;");
            }
        }

        protected IPRWebUserSearchCriteria GetLastExecuted()
        {
            if (_oUser.prwu_LastCompanySearchID == 0)
            {
                return null;
            }

            IPRWebUserSearchCriteria oLastSearch = new PRWebUserSearchCriteriaMgr(_oLogger, _oUser).GetLastExecuted(PRWebUserSearchCriteria.SEARCH_TYPE_COMPANY);
            oLastSearch.WebUser = _oUser;
            Session["oWebUserSearchCriteria"] = oLastSearch;
            return oLastSearch;
        }

        protected void SetVisiblity()
        {
            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                btnAnalyzeCompanies.Visible = false;
                //gvSearchResults.Columns[4].Visible = false;
            }

            if (_oUser.IsLimitado)
            {
                btnReports.Visible = false;
                btnPrintList.Visible = true;
            }
        }

        protected const string SQL_SELECT_DISPLAY_ZERO_RESULTS =
            "SELECT COUNT(1) % @PerCount As ModResult " +
              "FROM PRSearchAuditTrail WITH (NOLOCK) " +
             "WHERE prsat_WebUserID=@WebUserID " +
               "AND prsat_ResultCount = 0";

        protected void DisplayZeroResultsFeedback()
        {
            if (!Utilities.GetBoolConfigValue("ZeroResultsFeedbackEnabled", true))
            {
                return;
            }

            if (_oUser.prwu_IndustryType != GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                return;
            }

            if (_oUser.prwu_DontDisplayZeroResultsFeedback)
            {
                return;
            }

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("PerCount", Utilities.GetIntConfigValue("ZeroResultsFeedbackPerCount", 3)));
            oParameters.Add(new ObjectParameter("WebUserID", _oUser.prwu_WebUserID));

            int iModResult = (int)GetDBAccess().ExecuteScalar(SQL_SELECT_DISPLAY_ZERO_RESULTS, oParameters);
            if (iModResult == 0)
            {
                HtmlGenericControl oBody = (HtmlGenericControl)Master.FindControl("Body");
                oBody.Attributes.Add("onload", "processResults();");
            }
        }

        protected string GetEditCriteriaURL(CompanySearchCriteria oCriteria)
        {
            if (_oUser.IsLimitado)
                return PageConstants.LIMITADO_SEARCH + "?SearchID=" + _iSearchID.ToString();

            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                return PageConstants.COMPANY_SEARCH + "?SearchID=" + _iSearchID.ToString();
            else
                return PageConstants.ADVANCED_COMPANY_SEARCH + "?SearchID=" + _iSearchID.ToString();
        }

        protected const string SQL_SELECT_KYC =
               @"SELECT prpbar_PublicationArticleID, 
                        prpbar_FileName, 
                        {1} AS prcm_FullName, 
                        prpbar_CoverArtThumbFileName, 
                        prpbar_PublicationCode
                   FROM PRPublicationArticle WITH (NOLOCK)
                        INNER JOIN PRCommodity WITH (NOLOCK) ON prpbar_PublicationArticleID = prcm_PublicationArticleID
                  WHERE prcm_CommodityId IN ({0})  
               ORDER BY prpbar_Sequence";

        protected void DisplayKYC(CompanySearchCriteria oCompanySearchCriteria)
        {
            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                pnlKYC.Visible = false;
                return;
            }

            int iCount = 0;
            string szCommodityIDs = oCompanySearchCriteria.CommodityIDs;

            litKYCHeader.Text = Resources.Global.KnowYourCommodity; //"KNOW YOUR COMMODITY";

            if (!string.IsNullOrEmpty(szCommodityIDs))
            {
                string szSQL = string.Format(SQL_SELECT_KYC,
                    szCommodityIDs,
                    GetObjectMgr().GetLocalizedColName("prcm_FullName")
                    );
                using (IDataReader reader = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection))
                {
                    while (reader.Read())
                    {
                        iCount++;
                        if (iCount > 1)
                        {
                            break;
                        }


                        hlKYC3.NavigateUrl = PageConstants.KNOW_YOUR_COMMODITY;
                        hlKYC2.Text = Resources.Global.ReviewInfoOnAvailGradesCompat1 ; // "Review information on availability, grades, compatibility and more.";
                    }
                }
            }

            if (iCount != 1)
            {
                hlKYC3.NavigateUrl = PageConstants.KNOW_YOUR_COMMODITY;
                hlKYC2.Text = Resources.Global.ReviewInfoOnAvailGradesCompat2 ; //"Review information on availability, grades, compatibility, and more for various products.";
            }
        }

        //DECLARE @IndustryType varchar(50) = 'P'
        //DECLARE @CommodityIDs varchar(50) = ',110,'
        private const string SQL_COMPANY_SEARCH_AD =
            @"SELECT pradc_AdCampaignID,
                    pradc_TargetURL,
	                pracf_FileName_Disk,
                    pradc_IndustryType,
					pradc_CommodityId,
                    pradc_Language
                FROM vPRAdCampaignImage
                WHERE pradc_AdCampaignTypeDigital = 'SRLA'
                    AND pracf_FileTypeCode = 'DI'
                    AND pradc_CreativeStatus='A'
                    AND GETDATE() BETWEEN pradc_StartDate AND pradc_EndDate
                    AND pradc_Language LIKE @Language
					AND
					(
		                (@IndustryType IS NULL AND @CommodityIDs IS NOT NULL AND pradc_IndustryType IS NULL AND @CommodityIDs LIKE ('%,'+CAST(pradc_CommodityID AS varchar(50))+',%'))
		                OR
		                (@IndustryType IS NOT NULL AND @CommodityIDs IS NULL AND pradc_IndustryType LIKE '%,' + @IndustryType + ',%' AND pradc_CommodityId IS NULL)
		                OR
		                (@IndustryType IS NOT NULL AND @CommodityIDs IS NOT NULL AND pradc_IndustryType LIKE '%,' + @IndustryType + ',%' AND @CommodityIDs LIKE ('%,'+CAST(pradc_CommodityID AS varchar(50))+',%'))
					)";

        private const string IMG_MICROSLIDER = "<img src=\"{3}\" data-href=\"{0}?AdCampaignID={1}&AdAuditTrailID={2}\" />";


        protected void PopulateMicroslider(CompanySearchCriteria oWebUserSearchCriteria)
        {
            int adAuditTrailID = 0;
            int adCampaignID = 0;
            string imageURL = null;
            List<Int32> campaignIDs = new List<int>();

            if (oWebUserSearchCriteria == null)
                return;

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("IndustryType", oWebUserSearchCriteria.IndustryType));
            oParameters.Add(new ObjectParameter("Language", "%," + _oUser.prwu_Culture + ",%"));

            string szCommodityIDs = oWebUserSearchCriteria.CommodityIDs;
            if (string.IsNullOrEmpty(szCommodityIDs))
            {
                szCommodityIDs = null;
            }
            else
            {
                // Format so commodity ids can go into like clause
                if (!szCommodityIDs.StartsWith(","))
                    szCommodityIDs = "," + szCommodityIDs;
                if (!szCommodityIDs.EndsWith(","))
                    szCommodityIDs = szCommodityIDs + ",";
            }

            oParameters.Add(new ObjectParameter("CommodityIDs", szCommodityIDs));

            AdUtils _adUtils = new AdUtils(LoggerFactory.GetLogger(), _oUser);
            using (IDbTransaction oTrans = GetObjectMgr().BeginTransaction())
            {
                try
                {
                    StringBuilder microSliderImages = new StringBuilder();

                    using (IDataReader reader = GetDBAccess().ExecuteReader(SQL_COMPANY_SEARCH_AD, oParameters, CommandBehavior.CloseConnection, null))
                    {
                        while (reader.Read())
                        {
                            adAuditTrailID = 0;
                            int adCount = 0;
                            imageURL = null;

                            adCampaignID = reader.GetInt32(0);
                            imageURL = reader.GetString(2);

                            campaignIDs.Add(adCampaignID);
                            adCount++;

                            if ((!IsPRCoUser()) ||
                                (Configuration.AdCampaignTesting))
                            {
                                // Exclude the PRCo company from any auditing
                                // Add the audit trail first beacause we need it to 
                                // build any hyperlinks.
                                adAuditTrailID = _adUtils.InsertAdAuditTrail(adCampaignID, 0, adCount, null, 0, oTrans);

                            }

                            string szAdImageHTML = Configuration.AdImageVirtualFolder + imageURL.Replace('\\', '/');
                            object[] oArgs = {Configuration.AdClickURL,
                                    reader.GetInt32(0),
                                    adAuditTrailID,
                                    szAdImageHTML,
                                    string.Empty};

                            microSliderImages.Append(string.Format(IMG_MICROSLIDER, oArgs));
                        }
                    }


                    // Make sure the impression counts are updated.
                    // Exclude the PRCo company from any auditing
                    if ((!IsPRCoUser()) ||
                        (Configuration.AdCampaignTesting))
                    {
                        _adUtils.UpdateImpressionCount(campaignIDs, oTrans);
                    }

                    microslider.Text = microSliderImages.ToString();

                    oTrans.Commit();
                }
                catch (Exception)
                {
                    if (oTrans != null)
                    {
                        oTrans.Rollback();
                    }
                    throw;
                }
            }
        }
    }
}