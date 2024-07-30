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

 ClassName: EMCW_ReferenceList
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;
using TSI.DataAccess;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;
using System.Web.UI.HtmlControls;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This page is part of the edit company wizard.  It allows users to save changes to their company
    /// connection lists.
    /// </summary>
    public partial class EMCW_ReferenceList : EMCWizardBase
    {
        private const string SQL_GET_CONNECTION_LIST_DATE =
            @"SELECT comp_PRConnectionListDate 
                FROM Company WITH (NOLOCK) 
               WHERE comp_CompanyID = {0}";

        /// <summary>
        /// Calls page functions required to build and process this page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            // Set page title, sub-title and add any additional javascript files required for 
            // processing this page
            SetPageTitle(Resources.Global.EditCompany, Resources.Global.ConnectionList);
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_FUNCTIONS2_FILE));
            //Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_VALIDATION_FILE));

            // Add company submenu to this page
            SetSubmenu("btnConnectionList", blnDisableValidation: true);

            // Setup javascript form validaton for the report manual connection section
            EnableFormValidation();

            // Set the connection list date
            lblConnListDate.Text = GetConnectionListDate();

            SetPopover();

            if (!IsPostBack)
            {
                SetSortField(gvConnections, "comp_PRBookTradestyle");
                SetSortAsc(gvConnections, true);
                PopulateForm();

                LoadLookupValues();

                AddConnection();
            }
        }

        protected void SetPopover()
        {
            popWhatIsConfirmConnections.Attributes.Add("data-bs-title", Resources.Global.ConfirmReferencesHelp);
            popWhatIsConfirmConnections2.Attributes.Add("data-bs-title", Resources.Global.ConfirmReferencesHelp);

            //More popover set in GridView_RowDataBound
        }

        /// <summary>
        /// Helper method to return a handle to the Company Details Header used on the page to display 
        /// the company BB #, name, and location
        /// </summary>
        /// <returns></returns>
        protected override EMCW_CompanyHeader GetEditCompanyWizardHeader()
        {
            return ucCompanyDetailsHeader;
        }

        /// <summary>
        /// Populates the form controls.
        /// </summary>
        protected void PopulateForm()
        {
            string sortOrderBy = GetOrderByClause(gvConnections);

            // Retrieve the company connection list data based on the industry type
            GetCompanyRelationshipData(szIndustryType, sortOrderBy);
            PopulateGridView(gvConnections, lCompanyConnections);

            btnSubmitSurvey.OnClientClick = "return confirmSelect('Company', 'chkSelect');";
            btnConfirmConnections.OnClientClick = "return confirmSelect('Company', 'chkSelect');";
            btnConfirmAllConnections.OnClientClick = "CheckAll('chkSelect', true);";
            btnRemoveConnections.OnClientClick = "return confirmSelect('Company', 'chkSelect');";

            ucCompanyDetailsHeader.Visible = false;
            lblCompanyInfo.Text = Resources.Global.BBNumber + ucCompanyDetailsHeader.BBID + " " + ucCompanyDetailsHeader.CompanyName + ", " + ucCompanyDetailsHeader.CompanyLocation;
        }

        protected void PopulateGridView(GridView gvGridView, List<CompanyRelationships> lRelatedCompanies)
        {
            // Create empty grid view in case 0 results are found
            //((EmptyGridView)gvGridView).EmptyTableRowText = GetNoResultsFoundMsg(Resources.Global.Companies);
            gvGridView.ShowHeaderWhenEmpty = true;
            gvGridView.EmptyDataText = GetNoResultsFoundMsg(Resources.Global.Companies);

            // Execute search and bind results to grid
            gvGridView.DataSource = lRelatedCompanies;
            gvGridView.DataBind();
            EnableBootstrapFormatting(gvGridView);

            //Check security for BBScore column and popup
            SecurityMgr.SecurityResult privBBScore = _oUser.HasPrivilege(SecurityMgr.Privilege.ViewBBScore);
            if (!privBBScore.Visible)
            {
                //Hide Blue Book Score column entirely -- user doesn't have view privilege
                gvGridView.Columns[6].Visible = false;
            }

            // Display the number of matching records found
            //lblHeader.Text = szHeaderTitle + " (" + gvGridView.Rows.Count + ")";

            if (gvGridView.Rows.Count == 0)
            {
                btnSubmitSurvey.Enabled = false;
                btnConfirmAllConnections.Enabled = false;
                btnConfirmConnections.Enabled = false;
                btnRemoveConnections.Enabled = false;
            }
        }

        protected string GetCheckbox(string listingStatus, int companyID)
        {
            return "<input type=\"checkbox\" name=\"chkSelect\" value=\"" + companyID.ToString() + "\" />";
        }

        /// <summary>
        /// Handles the Save on click event.  Creates the task and displays a message informing the user 
        /// the data has been saved.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnSubmitSurvey_Click(object sender, EventArgs e)
        {
            SubmitTradeExperienceSurvey(lCompanyConnections, gvConnections);
        }

        private void SubmitTradeExperienceSurvey(List<CompanyRelationships> lCompanyRelationships, GridView gvConnListData)
        {
            string selectedCompanyIDs = Request["chkSelect"];

            if (string.IsNullOrEmpty(selectedCompanyIDs) ||
                (selectedCompanyIDs.Length == 0))
            {
                PopulateForm();
                AddUserMessage(Resources.Global.SelectAtLeastOneCompany);
                return;
            }
            else
            {
                Response.Redirect("TradeExperienceSurvey.aspx?CompanyIDList=" + selectedCompanyIDs.ToString());
            }
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

            if (e.Row.RowType == DataControlRowType.Header)
            {
                HtmlAnchor popWhatIsRelationship = (HtmlAnchor)e.Row.FindControl("popWhatIsRelationship");
                popWhatIsRelationship.Attributes.Add("data-bs-title", Resources.Global.RelationshipHelp);
            }

            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                // if the company is not listed, display label not link for company name
                string szListingStatus = (string)DataBinder.Eval(e.Row.DataItem, "ListingStatus");
                if (string.IsNullOrEmpty(szListingStatus) || "L,H,N3,N5,N6".IndexOf(szListingStatus) == -1)
                {
                    HyperLink hlRelatedCompanyDetails = (HyperLink)e.Row.FindControl("hlRelatedCompanyDetails");
                    Label lblRelatedCompanyDetails = (Label)e.Row.FindControl("lblRelatedCompanyDetails");

                    hlRelatedCompanyDetails.Visible = false;
                    lblRelatedCompanyDetails.Visible = true;
                }

                string szRelatedCompanyId = Convert.ToString(DataBinder.Eval(e.Row.DataItem, "RelatedCompanyID"));
                int RatingId;
                string RatingLine;
                string IsHQRating;
                decimal BBScore;
                string prbs_Model;
                string IndustryType;
                string prbs_PRPublish;
                string comp_PRPublishBBScore;

                GetCompanyInfo(szRelatedCompanyId, out RatingId, out RatingLine, out IsHQRating, out BBScore, out IndustryType, out prbs_PRPublish, out comp_PRPublishBBScore, out prbs_Model);

                //Rating column
                Label lblRating = (Label)e.Row.FindControl("lblRating");
                lblRating.Text = GetRatingCell(RatingId, RatingLine, IsHQRating);

                //BB Score column
                Literal litBBScore = (Literal)e.Row.FindControl("litBBScore");
                LinkButton lbBBScore = (LinkButton)e.Row.FindControl("lbBBScore");

                //Enforce security on BBScore results
                if (BBScore > 0 && prbs_PRPublish=="Y" && comp_PRPublishBBScore=="Y")
                {
                    lbBBScore.Text = BBScore.ToString("###");
                    lbBBScore.CommandArgument = string.Format("{0}|{1}|{2}", szRelatedCompanyId, IndustryType, prbs_Model);

                    litBBScore.Text = BBScore.ToString("###");
                    litBBScore.Visible = false;
                }
                else
                {
                    litBBScore.Text = Resources.Global.NotApplicableAbbr;
                    lbBBScore.Visible = false;
                }

                if (!Utilities.GetBoolConfigValue("BBScoreChartEnabled", false))
                {
                    lbBBScore.Visible = false;
                    litBBScore.Visible = true;
                }

                //Rate button
                LinkButton lbRateCompany = (LinkButton)e.Row.FindControl("lbRateCompany");
                lbRateCompany.Text = Resources.Global.RateCompany;
                lbRateCompany.CommandArgument = string.Format("{0}|{1}", szRelatedCompanyId, IndustryType); 

                if (!_oUser.HasPrivilege(SecurityMgr.Privilege.TradeExperienceSurveyPage).HasPrivilege || Configuration.ReadOnlyEnabled)
                {
                    lbRateCompany.Enabled = false;
                }
            }
        }

        /// <summary>
        /// Load the BB Score image and force the BBScoreChart popup to open
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void lbBBScore_Click(object sender, EventArgs e)
        {
            LinkButton btn = sender as LinkButton;
            string szBBScore = btn.Text;

            string[] szCommandArg = btn.CommandArgument.Split('|');
            string szRelatedCompanyId = szCommandArg[0];
            string szIndustryType = szCommandArg[1];
            string szModel = szCommandArg[2];

            ucBBScoreChart.industry = szIndustryType;
            PageControlBaseCommon.PopulateBBScoreChart(Convert.ToInt32(szRelatedCompanyId), szIndustryType, ucBBScoreChart.chart, ucBBScoreChart.bbScoreImage, ucBBScoreChart.bbScoreLiteral, _oUser.prwu_AccessLevel, szBBScore, _oUser.prwu_Culture, szModel, false);
            PageControlBaseCommon.RegisterPopupJS(ucBBScoreChart.updatePanel);
        }

        #region Get Company Data
        protected string GetConnectionListDate()
        {
            string szConnListDate = "";

            // Retrieve the current users company id for the edit my company wizard pages
            iCompanyID = _oUser.prwu_BBID;

            ArrayList oParameters = new ArrayList();

            oParameters.Add(new ObjectParameter("comp_CompanyID", iCompanyID));
            string szSQL = GetObjectMgr().FormatSQL(SQL_GET_CONNECTION_LIST_DATE, oParameters);

            // Use our own DBAccess object to 
            // avoid conflicts with open readers.
            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            oDBAccess.Logger = _oLogger;

            using (IDataReader oReader = oDBAccess.ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null))
            {
                if (oReader.Read())
                    szConnListDate = GetStringFromDate(GetDBAccess().GetDateTime(oReader, "comp_PRConnectionListDate"));
            }

            return szConnListDate;
        }

        //const string SQL_GET_COMPANY_RATING = "SELECT prcra_RatingId, prcra_RatingLine, prcra_IsHQRating FROM PRCompanyRating WHERE prcra_companyid=@CompanyId";
        const string SQL_GET_COMPANY_INFO = @"SELECT 
	                                            CASE WHEN comp_PRType = 'B' THEN CASE WHEN compRating.prra_RatingID IS NOT NULL THEN compRating.prra_RatingID ELSE hqRating.prra_RatingID END ELSE hqRating.prra_RatingID END AS prra_RatingID,
	                                            CASE WHEN comp_PRType = 'B' THEN CASE WHEN compRating.prra_RatingID IS NOT NULL THEN compRating.prra_RatingLine ELSE hqRating.prra_RatingLine END ELSE hqRating.prra_RatingLine END AS prra_RatingLine,
	                                            CASE WHEN comp_PRType = 'B' THEN CASE WHEN compRating.prra_RatingID IS NOT NULL THEN 'N' ELSE 'Y' END ELSE 'N' END AS IsHQRating,
                                                prbs_BBScore,
                                                prbs_Model,
                                                comp_PRIndustryType,
                                                prbs_PRPublish,
                                                comp_PRPublishBBScore
                                            FROM Company WITH (NOLOCK) 
	                                            LEFT OUTER JOIN vPRCurrentRating compRating WITH (NOLOCK) ON comp_CompanyID = compRating.prra_CompanyID 
	                                            LEFT OUTER JOIN vPRCurrentRating hqRating WITH (NOLOCK) ON comp_PRHQID = hqRating.prra_CompanyID 
	                                            LEFT OUTER JOIN PRBBScore WITH (NOLOCK) ON comp_CompanyID = prbs_CompanyID AND prbs_Current='Y' 
                                            WHERE comp_CompanyID=@CompanyId
";

        protected void GetCompanyInfo(string szRelatedCompanyId, out int RatingId, out string RatingLine, out string IsHQRating, out decimal prbs_BBScore, out string comp_PRIndustryType, out string prbs_PRPublish, out string comp_PRPublishBBScore, out string prbs_Model)
        {
            // Retrieve the company rating for the current row being displayed
            ArrayList oParameters = new ArrayList();

            oParameters.Add(new ObjectParameter("CompanyId", szRelatedCompanyId));
            string szSQL = GetObjectMgr().FormatSQL(SQL_GET_COMPANY_INFO, oParameters);

            // Use our own DBAccess object to avoid conflicts with open readers.
            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            oDBAccess.Logger = _oLogger;

            RatingId = 0;
            RatingLine = "";
            IsHQRating = "";
            prbs_BBScore = 0;
            prbs_Model = "";
            comp_PRIndustryType = "";
            prbs_PRPublish = "";
            comp_PRPublishBBScore = "";

            using (IDataReader oReader = oDBAccess.ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null))
            {
                if (oReader.Read())
                {
                    RatingId = GetDBAccess().GetInt32(oReader, "prra_RatingId");
                    RatingLine = GetDBAccess().GetString(oReader, "prra_RatingLine");
                    IsHQRating = GetDBAccess().GetString(oReader, "IsHQRating");
                    prbs_BBScore = GetDBAccess().GetDecimal(oReader, "prbs_BBScore");
                    prbs_Model = GetDBAccess().GetString(oReader, "prbs_Model");
                    comp_PRIndustryType = GetDBAccess().GetString(oReader, "comp_PRIndustryType");
                    prbs_PRPublish = GetDBAccess().GetString(oReader, "prbs_PRPublish"); ;
                    comp_PRPublishBBScore = GetDBAccess().GetString(oReader, "comp_PRPublishBBScore"); ;
                }
            }
        }

        #endregion

        /// <summary>
        /// This is currently unused.  To sort the grids we must then save/restore the
        /// form input values without saving them to the database.  It has been deemed 
        /// not worth the effort.  This code will remain for future reference.
        /// 
        /// To use, add a call to this method on the OnSort handler.
        /// </summary>
        /// <param name="oGridView"></param>
        protected void SortRelationshipList(GridView oGridView)
        {

            List<CompanyRelationships> lSortList = null;
            lSortList = lCompanyConnections;

            // Create Person Comparer Class
            CompanyRelationshipComparer oCRComparer = new CompanyRelationshipComparer();

            // Sort By Lastname
            oCRComparer.ComparisonMethod = GetSortField(oGridView);
            oCRComparer.SortAsc = GetSortAsc(oGridView);
            lSortList.Sort(oCRComparer);
        }

        protected void btnAddConnection_Click(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.Format(PageConstants.EMCW_REFERENCELIST_ADD + "&Type={0}", szIndustryType));
        }

        protected void btnConfirmRelationships_Click(object sender, EventArgs e)
        {
            string selectedCompanyIDs = Request["chkSelect"];

            if (string.IsNullOrEmpty(selectedCompanyIDs) ||
                (selectedCompanyIDs.Length == 0))
            {
                PopulateForm();
                AddUserMessage(Resources.Global.SelectAtLeastOneCompany);
                return;
            }

            string[] aszCompanyIDs = selectedCompanyIDs.Split(',');
            StringBuilder masterIDList = new StringBuilder();

            foreach (string companyID in aszCompanyIDs)
            {
                if (masterIDList.Length > 0)
                {
                    masterIDList.Append(", ");
                }

                masterIDList.Append(GetRequestParameter("hdnRelationshipIDList_" + companyID.Trim()));
            }

            CompanyRelationshipMgr manager = new CompanyRelationshipMgr(_oLogger, _oUser);
            manager.UpdateCompanyRelationships(masterIDList.ToString(), true);
            Session["mcCLCheck"] = null;

            // Display message to user informing them that the data has been saved
            AddUserMessage(Resources.Global.SaveMsgConnectionList, true);
            btnConfirmConnections.Enabled = false;
            Response.Redirect(PageConstants.EMCW_REFERENCELIST);
        }

        protected void btnRemoveRelationships_Click(object sender, EventArgs e)
        {
            string selectedCompanyIDs = Request["chkSelect"];

            if (string.IsNullOrEmpty(selectedCompanyIDs) ||
                (selectedCompanyIDs.Length == 0))
            {
                PopulateForm();
                AddUserMessage(Resources.Global.SelectAtLeastOneCompany);
                return;
            }

            string[] aszCompanyIDs = selectedCompanyIDs.Split(',');
            StringBuilder masterIDList = new StringBuilder();

            foreach (string companyID in aszCompanyIDs)
            {
                if (masterIDList.Length > 0)
                {
                    masterIDList.Append(", ");
                }

                masterIDList.Append(GetRequestParameter("hdnRelationshipIDList_" + companyID.Trim()));
            }

            CompanyRelationshipMgr manager = new CompanyRelationshipMgr(_oLogger, _oUser);

            manager.RemoveCompanyRelationships(masterIDList.ToString());

            // Now mark the remaining relationship as confirmed.
            manager.UpdateCompanyRelationships();

            // Display message to user informing them that the data has been saved
            AddUserMessage(Resources.Global.SaveMsgConnectionList, true);
            btnConfirmConnections.Enabled = false;
            Session["mcCLCheck"] = null;
            Response.Redirect(PageConstants.EMCW_REFERENCELIST);
        }

        protected override bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.CompanyEditReferenceListPage).HasPrivilege;
        }

        protected void LoadLookupValues()
        {
            // Retrieve Connection Types from the database 
            IBusinessObjectSet osRefData = GetReferenceData("BBOSLeftRelType" + szIndustryType);

            // Bind the filtered connection type list to both the search connection types and
            // manual connection types on the page
            BindLookupValues(ddlConnTypeSearch, osRefData);
            BindLookupValues(ddlConnTypeManual, osRefData);
            BindLookupValues(chkListRelationshipTypes, osRefData);
            BindLookupValues(rdLstIntegrity, GetReferenceData("IntegrityRating3"));
            BindLookupValues(rdLstPayPerformance, GetReferenceData("TESPayRating"));
            BindLookupValues(rdLstLastDealt, GetReferenceData("prtr_LastDealtDate"));

            if (IsLumber())
            {
                BindLookupValues(rdLstHighCredit, GetReferenceData("prtr_HighCreditL"));
            }
            else
            {
                BindLookupValues(rdLstHighCredit, GetReferenceData("prtr_HighCreditBBOS"));
            }

            if (_oUser.prwu_CountryID != 0)
            {
                cddMailCountry.ContextKey = _oUser.prwu_CountryID.ToString();
                cddMailState.ContextKey = _oUser.prwu_StateID.ToString();
            }
            else
            {
                // Default to USA
                cddMailCountry.ContextKey = "1";
                cddMailState.ContextKey = String.Empty;
            }

            aceCompanyName.ContextKey = _oUser.prwu_IndustryType;
        }

        /// <summary>
        /// Checks is the user works in a lumber type industry.
        /// </summary>
        /// <returns></returns>
        private bool IsLumber()
        {
            bool isLumber = false;

            if (_oUser != null)
            {
                if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                    isLumber = true;
            }

            return isLumber;
        }

        protected void btnSaveReference_Click(object sender, EventArgs e)
        {
            CompanyRelationshipMgr manager = new CompanyRelationshipMgr(_oLogger, _oUser);

            if (manager.IsAffiliated(_oUser.prwu_BBID, Convert.ToInt32(hSelectedCompanyID.Value)))
            {
                AddUserMessage("The addition of an affiliate as a reference is not allowed.");
                return;
            }

            CompanyRelationships companyRelationship = new CompanyRelationships();
            companyRelationship.RelatedCompanyID = Convert.ToInt32(hSelectedCompanyID.Value);
            companyRelationship.Type = ddlConnTypeSearch.SelectedValue;
            companyRelationship.IsActive = true;

            if (string.IsNullOrEmpty(GetConnectionListDate()))
            {
                string szNotes = Utilities.GetConfigValue("ConnectionListSaveMsg", "One or more companies have been added to a New Reference List Online.");

                GetObjectMgr().CreateTask(GetObjectMgr().GetPRCoSpecialistID(iCompanyID, GeneralDataMgr.PRCO_SPECIALIST_RATINGS, null),
                                        "Pending",
                                        szNotes,
                                        Utilities.GetConfigValue("ConnectionListSaveCategory", "R"),
                                        Utilities.GetConfigValue("ConnectionListSaveSubcategory", ""),
                                        _oUser.prwu_BBID,
                                        _oUser.peli_PersonID,
                                        0,
                                        "OnlineIn",
                                        Utilities.GetConfigValue("ConnectionListSaveSubject", "Reference List Saved"),
                                        "Y",
                                        null);
            }

            manager.SaveCompanyRelationships(companyRelationship);
            manager.UpdateCompanyRelationships();
            manager.UpdateCompanyCLDate();
            Session["mcCLCheck"] = null;

            // Refresh our page
            AddUserMessage(Resources.Global.SaveMsgConnectionList, true);
            Response.Redirect(PageConstants.EMCW_REFERENCELIST);
        }

        protected void btnReport_Click(object sender, EventArgs e)
        {
            // Create a list to be used to report the manual company relationship 
            // details entered.
            List<CompanyRelationships> oManualConnections = new List<CompanyRelationships>();

            // Create a new company relationship object and set the values based on the
            // data entered on the form
            CompanyRelationships oRelationship = new CompanyRelationships();

            oRelationship.RelatedCompanyName = txtCompanyNameManual.Text;
            oRelationship.RelatedContactName = txtContactNameManual.Text;

            Address oAddress = new Address();

            oAddress.Address1 = txtMailStreet1.Text;
            oAddress.City = txtCityManual.Text;
            oAddress.CountryID = Convert.ToInt32(ddlMailCountry.SelectedValue);
            oAddress.StateID = Convert.ToInt32(ddlMailState.SelectedValue);
            oAddress.PostalCode = txtMailPostal.Text;
            
            oRelationship.Addresses = oAddress;

            Phone oPhone = new Phone();
            Phone oFax = new Phone();

            oPhone.AreaCode = txtPhoneAreaCode.Text;
            oPhone.Number = txtPhone.Text;

            oRelationship.Phone = oPhone;

            oFax.AreaCode = txtFaxAreaCode.Text;
            oFax.Number = txtFax.Text;

            oRelationship.Fax = oFax;
            oRelationship.Email = txtEmail.Text;
            oRelationship.Type = ddlConnTypeManual.SelectedValue;
            if (rdLstIntegrity.SelectedIndex != -1)
            {
                oRelationship.TradePracticeName = rdLstIntegrity.SelectedItem.Text;
            }
            if (rdLstPayPerformance.SelectedIndex != -1)
            {
                oRelationship.PayPerformanceName = rdLstPayPerformance.SelectedItem.Text;
            }
            if (rdLstHighCredit.SelectedIndex != -1)
            {
                oRelationship.HighCreditName = rdLstHighCredit.SelectedItem.Text;
            }
            if (rdLstLastDealt.SelectedIndex != -1)
            {
                oRelationship.LastDealtName = rdLstLastDealt.SelectedItem.Text;
            }
            oRelationship.Comments = txtAreaComments.Value;

            // Add the manual relationship to the list
            oManualConnections.Add(oRelationship);

            // Save the manual relationship data reported by the user
            CompanyRelationshipMgr oMgr = new CompanyRelationshipMgr(_oLogger, _oUser);
            oMgr.SaveManualCompanyRelationships(oManualConnections);

            // Display message to user informing them that the data has been saved
            AddUserMessage(Resources.Global.SaveMsgConnectionListManual, true);

            Response.Redirect(PageConstants.EMCW_REFERENCELIST);
        }

        private const string SQL_GET_EXISTING_RELATIONSHIP_CODES =
            @"SELECT prcr_Type 
                FROM PRCompanyRelationship WITH (NOLOCK) 
                     INNER JOIN custom_captions ON prcr_Type = capt_code AND capt_family = {0} 
               WHERE prcr_LeftCompanyID = {1} 
                 AND prcr_RightCompanyID = {2} 
                 AND prcr_Active='Y'";

        private List<string> GetExistingRelationshipCodes()
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("capt_family", "BBOSLeftRelType" + szIndustryType));
            oParameters.Add(new ObjectParameter("prcr_LeftCompanyID", iCompanyID));
            oParameters.Add(new ObjectParameter("prcr_RightCompanyID", Convert.ToInt32(hRelatedCompanyID.Value)));
            string szSQL = GetObjectMgr().FormatSQL(SQL_GET_EXISTING_RELATIONSHIP_CODES, oParameters);

            // Use our own DBAccess object to 
            // avoid conflicts with open readers.
            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            oDBAccess.Logger = _oLogger;

            List<string> existingRelCodes = new List<string>();

            using (IDataReader oReader = oDBAccess.ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null))
            {
                while (oReader.Read())
                    existingRelCodes.Add(oDBAccess.GetString(oReader, "prcr_Type"));
            }

            return existingRelCodes;
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            CompanyRelationshipMgr manager = new CompanyRelationshipMgr(_oLogger, _oUser);
            List<string> existingRelCodes = GetExistingRelationshipCodes();

            foreach (ListItem relationshipType in chkListRelationshipTypes.Items)
            {
                if (relationshipType.Selected)
                {
                    // Create a new companyRelationships object
                    CompanyRelationships relationship = new CompanyRelationships();
                    relationship.RelatedCompanyID = Convert.ToInt32(hRelatedCompanyID.Value);
                    relationship.Type = relationshipType.Value;
                    relationship.IsActive = true;
                    manager.SaveCompanyRelationships(relationship);
                }
                else
                {
                    // The type is not selected, so check to see if it's in out list
                    // of existing codes.  If so, then we need to mark the relationship
                    // inactive.
                    if (existingRelCodes.Any(code => code.Equals(relationshipType.Value)))
                    {
                        CompanyRelationships relationship = new CompanyRelationships();
                        relationship.RelatedCompanyID = Convert.ToInt32(hRelatedCompanyID.Value);
                        relationship.Type = relationshipType.Value;
                        relationship.IsActive = false;
                        manager.SaveCompanyRelationships(relationship);
                    }
                }
            }

            // Display message to user informing them that the data has been saved
            //AddUserMessage(Resources.Global.SaveMsgConnectionList, true);
            Response.Redirect(PageConstants.EMCW_REFERENCELIST);
        }

        protected void AddConnection()
        {
            if (string.IsNullOrEmpty(GetRequestParameter("Add", false)))
            {
                return;
            }

            if(Configuration.RedirectHomeOnException && GetRequestParameter("CompanyIDList", false) == null)
            {
                Response.Redirect(PageConstants.BBOS_HOME);
            }

            hSelectedCompanyID.Value = GetRequestParameter("CompanyIDList");
            txtCompany.Text = (string)Session["CompanyHeader_szCompanyName"];
            mdlExtAddConnection.Show();
        }

        protected string escapeJSString(string value)
        {
            return value.Replace("'", "\\'");
        }

        protected void lbRateCompany_Click(object sender, EventArgs e)
        {
            //Popup the long form TES control for the selected company row
            LinkButton lbRateCompany = (LinkButton)sender;

            string[] szCommandArg = lbRateCompany.CommandArgument.Split('|');
            string szClickedCompanyId = szCommandArg[0];
            string szClickedIndustryType = szCommandArg[1];

            TESLongForm.WebUser = _oUser;
            TESLongForm.SubjectCompanyID = szClickedCompanyId;
            TESLongForm.SubjectIndustryType = szClickedIndustryType;

            TESLongForm.SetModalTargetControl_Unique(lbRateCompany);
            System.Web.UI.ScriptManager.RegisterStartupScript(this, this.GetType(), "RateCompany", "ShowTESPopup();", true); 
        }
    }
}
