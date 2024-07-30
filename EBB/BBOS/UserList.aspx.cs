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

 ClassName: UserList
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;
using TSI.DataAccess;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;
using TSI.Arch;
using System.Text;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This page displays the details for the user list.  The list name, description, and other list details 
    /// will be displayed as well as the current companies contained in the list.
    /// 
    /// From this page, the user will be allowed to Edit this list if they are the list owner.  They can also
    /// select companies from this list to get business reports, submit trade surveys, reports, extract data, and
    /// analyze the companies.
    /// 
    /// If the company displayed in the list has a comp_PRLastPublishedCSDate within the past 90 days (config
    /// value) the row will be highlighted (config value).
    /// 
    /// The list must either be private and "owned" by the current user or public and "owned" by the current
    /// user's enterprise.
    /// </summary>
    public partial class UserList : UserListBase
    {
        /// <summary>
        /// Calls page functions required to build and process this page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            // Retrieve the user list id (required for processing this page)
            hidUserListID.Value = GetRequestParameter("UserListID");
            if(hidUserListID.Value == "AUS")
            {
                //Special processing to lookup AUS list ID as a default
                Response.Redirect(string.Format(PageConstants.USER_LIST, GetAUSListID()));
            }

            // Set page title and add any additional javascript files required for processing
            // this page
            if (_oUser.IsLimitado)
            {
                SetPageTitle(Resources.Global.Alerts);
            }
            else
                SetPageTitle(Resources.Global.WatchdogList);

            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_FUNCTIONS2_FILE));
            EnableFormValidation();

            if (!IsPostBack)
            {
                PopulateForm();
            }

            SetVisibility();

            ApplyButtonSecurity();

            ApplyReadOnlyCheck(btnEdit);
            ApplyReadOnlyCheck(btnSubmitTES);

            //Limitado button hides
            if (_oUser.IsLimitado)
            {
                btnEdit.Visible = false;
                btnReports.Visible = false;
                btnExportData.Visible = false;
                btnAnalyzeCompanies.Visible = false;
                btnSubmitTES.Visible = false;
                btnMap.Visible = false;
            }
        }

        /// <summary>
        /// Check users page level authorization
        /// </summary>
        /// <returns></returns>
        override protected bool IsAuthorizedForPage()
        {
            return _oUser.IsLimitado || _oUser.HasPrivilege(SecurityMgr.Privilege.WatchdogListsPage).HasPrivilege;
        }

        /// <summary>        
        /// Check users control/data level authorization
        /// </summary>
        /// <returns></returns>
        override protected bool IsAuthorizedForData()
        {
            return true;
        }

        /// <summary>
        /// Populates the form controls.
        /// </summary>
        protected void PopulateForm()
        {
            // Retrieve the user list details
            GetUserListDetails();

            // Populate the selected companies for this list
            PopulateCompanyList();
        }

        /// <summary>
        /// Populates the Company list grid view control on the form
        /// </summary>
        protected void PopulateCompanyList()
        {
            // Create empty grid view in case 0 results are found
            //((EmptyGridView)gvCompanyList).EmptyTableRowText = GetNoResultsFoundMsg(Resources.Global.Companies);
            gvCompanyList.ShowHeaderWhenEmpty = true;
            gvCompanyList.EmptyDataText = GetNoResultsFoundMsg(Resources.Global.Companies);

            string szSQL;

            if (hidListType.Value == "CL")
            {
                //Retrieve list same as on Manage Reference List (Defect 4647)
                string sortOrderBy = GetOrderByClause(gvCompanyList);

                // Retrieve the company connection list data based on the industry type
                List<CompanyRelationships> lRelatedCompanies = GetCompanyRelationshipData(_oUser.prwu_IndustryType, sortOrderBy);

                StringBuilder sbList = new StringBuilder();
                foreach (CompanyRelationships cr in lRelatedCompanies)
                {
                    if (sbList.Length > 0)
                        sbList.Append(",");
                    sbList.Append(cr.RelatedCompanyID);
                }

                // Generate the sql required to retrieve the selected companies   
                object[] args = {_oUser.prwu_Culture,
                             _oUser.prwu_WebUserID,
                             _oUser.prwu_HQID,
                             sbList.Length==0?"0":sbList.ToString(),
                             DateTime.Today.AddDays(0 - Configuration.ClaimActivityNewThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss"),
                             DateTime.Today.AddDays(0 - Configuration.ClaimActivityMeritoriousThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss"),
                             GetObjectMgr().GetLocalSourceCondition(),
                             GetObjectMgr().GetIntlTradeAssociationCondition()};

                szSQL = string.Format(SQL_GET_SELECTED_COMPANIES_WITH_RATINGS, args);
            }
            else
            {
                // Retrieve the companies to use to populate the selected companies data grid 
                string szListCompanyIDs = GetUserListCompanyIDs(Convert.ToInt32(hidUserListID.Value));

                // Generate the sql required to retrieve the selected companies   
                object[] args = {_oUser.prwu_Culture,
                             _oUser.prwu_WebUserID,
                             _oUser.prwu_HQID,
                             szListCompanyIDs,
                             DateTime.Today.AddDays(0 - Configuration.ClaimActivityNewThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss"),
                             DateTime.Today.AddDays(0 - Configuration.ClaimActivityMeritoriousThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss"),
                             GetObjectMgr().GetLocalSourceCondition(),
                             GetObjectMgr().GetIntlTradeAssociationCondition()};

                szSQL = string.Format(SQL_GET_SELECTED_COMPANIES_WITH_RATINGS, args);
            }

            szSQL += GetOrderByClause(gvCompanyList);
            // Execute search and bind results to grid
            gvCompanyList.DataSource = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection);
            gvCompanyList.DataBind();
            EnableBootstrapFormatting(gvCompanyList);

            OptimizeViewState(gvCompanyList);

            // Display the number of matching records found
            lblRecordCount.Text = string.Format(Resources.Global.RecordCountFoundMsg, gvCompanyList.Rows.Count, Resources.Global.Companies);

            // If no results are found, disable the buttons that require a company            
            if (gvCompanyList.Rows.Count == 0)
            {
                btnSubmitTES.Enabled = false;
                btnReports.Enabled = false;
                btnExportData.Enabled = false;
                btnAnalyzeCompanies.Enabled = false;
            }
        }

        /// <summary>
        /// Helper method used to get the corresponding connection lists based on the 
        /// companies industry type.
        /// </summary>
        /// <param name="szIndustryType">Company's Industry Type</param>
        /// <param name="sortOrderBy"></param>
        protected List<CompanyRelationships> GetCompanyRelationshipData(string szIndustryType, string sortOrderBy)
        {
            CompanyRelationshipMgr oMgr = new CompanyRelationshipMgr(_oLogger, _oUser);
            List<CompanyRelationships> lCompanyConnections = new List<CompanyRelationships>();

            // If produce, check and set Produce connection list data
            if (szIndustryType == GeneralDataMgr.INDUSTRY_TYPE_PRODUCE)
            {
                oMgr.LoadProduceCompany(sortOrderBy);
                lCompanyConnections = oMgr.CompanyConnections;
            }

            // If transportation, get and set the transportation connection list data
            if (szIndustryType == GeneralDataMgr.INDUSTRY_TYPE_TRANSPORTATION)
            {
                oMgr.LoadTransCompany(sortOrderBy);
                lCompanyConnections = oMgr.CompanyConnections;
            }

            // If Lumber, get and set the lumber connection list data
            if (szIndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                oMgr.LoadLumberCompany(sortOrderBy);
                lCompanyConnections = oMgr.CompanyConnections;
            }

            return lCompanyConnections;
        }

        /// <summary>
        /// Used to show/hide form elements based on the current page
        /// settings
        /// </summary>
        protected void SetVisibility()
        {
            // Only display the Manage AUS Settings button if the list type = AUS
            if (hidListType.Value == CODE_LIST_TYPE_AUS)
                btnManageAlertsSettings.Visible = true;

            // Disable the Edit button if the current user is not the authorized to edit this list
            btnEdit.Enabled = IsAuthorizedForEdit(Convert.ToInt32(hidUserListID.Value));

            // Only display the Manage Connection List button if the list type = Connection List
            if (hidListType.Value == CODE_LIST_TYPE_CONNECTIONLIST)
            {
                if (_oUser.prwu_IndustryType != GeneralDataMgr.INDUSTRY_TYPE_SUPPLY)
                {
                    btnManageConnList.Visible = true;
                }

                //Defect 4440 - hide the Edit and Remove buttons for CL lists
                btnEdit.Visible= false;
                btnRemove.Visible = false;
            }
        }

        /// <summary>
        /// Helper method that applies security and hooks up the buttons
        /// to client-side validation.
        /// </summary>
        protected void ApplyButtonSecurity()
        {
            PrepareButton(btnSubmitTES, false);
            PrepareButton(btnReports, false);
            PrepareButton(btnExportData, false);
            PrepareButton(btnRemove, false);

            btnAnalyzeCompanies.Attributes.Add("onclick", "return LimitCheckCount('" + Resources.Global.Company + "', 'cbCompanyID', '" + Resources.Global.AnalyzeCompanies + "', " + Utilities.GetConfigValue("CompanyAnalysisMaximumCompanies", "50") + ")");

            ApplySecurity(btnAnalyzeCompanies, SecurityMgr.Privilege.CompanyAnalysisPage);
            ApplySecurity(btnSubmitTES, SecurityMgr.Privilege.TradeExperienceSurveyPage);
            ApplySecurity(btnExportData, SecurityMgr.Privilege.DataExportPage);

            // Defect 7052 - L150 have button disabled
            if (_oUser.prwu_AccessLevel == PRWebUser.SECURITY_LEVEL_BASIC_PLUS)
            {
                btnAddToWatchdog.Enabled = false;
            }
        }

        /// <summary>
        /// This function is used to retrieve the user list data for the specified user list including 
        /// the list name, description, is private, created by, location, list owner.  The list must
        /// either be private and "owned" by the current user or public and "owned" by the current user's 
        /// enterprise.  If not record is found that matches this criteria, an authorization exception
        /// will be thrown.
        /// </summary>
        private void GetUserListDetails()
        {
            bool bRecordFound = false;

            ArrayList oParameters = new ArrayList();

            oParameters.Add(new ObjectParameter("prwucl_WebUserListID", hidUserListID.Value));
            oParameters.Add(new ObjectParameter("prwucl_WebUserID", _oUser.prwu_WebUserID));
            oParameters.Add(new ObjectParameter("prwucl_HQID", _oUser.prwu_HQID));

            string szSQL;

            // Level 3 access is required to view custom lists
            if (_oUser.HasPrivilege(SecurityMgr.Privilege.WatchdogListAdd).HasPrivilege)
                szSQL = GetObjectMgr().FormatSQL(SQL_GET_WEB_USER_LIST_DATA, oParameters);
            else
                szSQL = GetObjectMgr().FormatSQL(SQL_GET_WEB_USER_LIST_DATA + SQL_EXCLUDE_CUSTOM_LISTS, oParameters);

            // Use our own DBAccess object to 
            // avoid conflicts with open readers.
            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            oDBAccess.Logger = _oLogger;

            using (IDataReader oReader = oDBAccess.ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null))
            {
                while (oReader.Read())
                {
                    bRecordFound = true;
                    lblListName.Text = TranslateList(GetDBAccess().GetString(oReader, "prwucl_Name"));
                    lblListDescription.Text = TranslateList(GetDBAccess().GetString(oReader, "prwucl_Description"));
                    lblPrivate.Text = UIUtils.GetStringFromBool(GetDBAccess().GetString(oReader, "prwucl_IsPrivate"));

                    //lblCreatedBy.Text = GetDBAccess().GetString(oReader, "CreatedBy");
                    //lblCreatedByLocation.Text = GetDBAccess().GetString(oReader, "CreatedByLocation");

                    lblLastUpdatedBy.Text = GetDBAccess().GetString(oReader, "UpdatedBy");
                    lblLastUpdatedByLocation.Text = GetDBAccess().GetString(oReader, "UpdatedByLocation");

                    hidListType.Value = GetDBAccess().GetString(oReader, "prwucl_TypeCode");
                    hidWebUserID.Value = GetDBAccess().GetInt32(oReader, "prwucl_WebUserID").ToString();

                    //lblPinned.Text = UIUtils.GetStringFromBool(GetDBAccess().GetString(oReader, "prwucl_Pinned"));

                    if (string.IsNullOrEmpty(GetDBAccess().GetString(oReader, "prwucl_CategoryIcon")))
                    {
                        Icon.Visible = false;
                    }
                    else
                    {
                        Icon.ImageUrl = UIUtils.GetImageURL(GetDBAccess().GetString(oReader, "prwucl_CategoryIcon"));
                    }

                    if (GetDBAccess().GetString(oReader, "prwucl_TypeCode") == CODE_LIST_TYPE_CONNECTIONLIST)
                    {
                        //trCreatedBy.Visible = false;
                        trLastUpdatedBy.Visible = false;
                    }
                }
            }

            // If no record was found, then the user does not have authorized access to this record.
            // Throw authorization exception
            if (!bRecordFound)
                throw new AuthorizationException(Resources.Global.UnauthorizedForPageMsg);
        }

        private string TranslateList(string szPhrase)
        {
            const string AUSL_EN_NEW = "Alerts List"; //previously was Automatic Update Service List
            const string AUSL_MX_NEW = "Lista De Alertas";

            const string LISTNAME_EN = "Companies that are automatically monitored.";
            const string LISTNAME_MX = "Empresas automaticamente monitoreadas";

            switch (_oUser.prwu_Culture)
            {
                case "es-mx":
                    switch (szPhrase)
                    {
                        case AUSL_EN_NEW:
                            return AUSL_MX_NEW;
                        case LISTNAME_EN:
                            return LISTNAME_MX;
                        default:
                            return szPhrase;
                    };
                case "en-us":
                    switch (szPhrase)
                    {
                        case AUSL_MX_NEW:
                            return AUSL_EN_NEW;
                        case LISTNAME_MX:
                            return LISTNAME_EN;
                        default:
                            return szPhrase;
                    };
                default:
                    return szPhrase;
            }
        }

        /// <summary>
        /// Handles the Back button on click event.  Takes the user to the UserListList.aspx page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnBack_Click(object sender, EventArgs e)
        {
            if(_oUser.IsLimitado)
                Response.Redirect(GetReturnURL(PageConstants.LIMITADO_SEARCH));
            else
                Response.Redirect(PageConstants.BROWSE_COMPANIES);
        }

        /// <summary>
        /// Handles the Edit button on click event.  Takes the user to the UserListEdit.aspx page
        /// for this user list.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnEdit_Click(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.Format(PageConstants.USER_LIST_EDIT, hidUserListID.Value));
        }

        /// <summary>
        /// Handles the Get Business Report on click event.  Takes the user to the BusinessReportConfirmSelections.aspx
        /// page for the selected companies.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnBusinessReport_Click(object sender, EventArgs e)
        {
            Session["ReturnURL"] = (PageConstants.Format(PageConstants.USER_LIST, hidUserListID.Value));
            SetRequestParameter("CompanyIDList", GetRequestParameter("cbCompanyID"));
            Response.Redirect(string.Format(PageConstants.BUSINESS_REPORT_CONFIRM_SELECTIONS, hidUserListID.Value, "PRWebUserList"));
        }

        /// <summary>
        /// Handles the Submit Trade Survey on click event.  Takes the user to the TradeExperienceSurvey.aspx
        /// page for the selected company.  
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnSubmitTESOnClick(object sender, EventArgs e)
        {
            Session["ReturnURL"] = (PageConstants.Format(PageConstants.USER_LIST, hidUserListID.Value));
            SetRequestParameter("CompanyIDList", GetRequestParameter("cbCompanyID"));
            Response.Redirect(PageConstants.TES);
        }

        /// <summary>
        /// Handles the Report button on click event.  Takes the user to the ReportsConfirmSelections.aspx
        /// page for the selected companies.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnReports_Click(object sender, EventArgs e)
        {
            Session["ReturnURL"] = (PageConstants.Format(PageConstants.USER_LIST, hidUserListID.Value));
            SetRequestParameter("CompanyIDList", GetRequestParameter("cbCompanyID"));
            Response.Redirect(PageConstants.REPORTS_CONFIRM_SELECTION);
        }

        /// <summary>
        /// Handles the Export Data button on click event.  Takes the user to the DataExportConfirmSelections.aspx
        /// page for the selected companies.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnExportData_Click(object sender, EventArgs e)
        {
            Session["ReturnURL"] = (PageConstants.Format(PageConstants.USER_LIST, hidUserListID.Value));
            SetRequestParameter("CompanyIDList", GetRequestParameter("cbCompanyID"));
            Response.Redirect(PageConstants.DATA_EXPORT_CONFIRM_SELECTIONS);
        }

        /// <summary>
        /// Handles the Analyze Companies button on click event.  Takes the user to the CompanyAnalysis.aspx
        /// page for the selected companies.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnAnalyzeCompanies_Click(object sender, EventArgs e)
        {
            Session["ReturnURL"] = (PageConstants.Format(PageConstants.USER_LIST, hidUserListID.Value));
            SetRequestParameter("CompanyIDList", GetRequestParameter("cbCompanyID"));
            Response.Redirect(PageConstants.COMPANY_ANALYSIS);
        }

        /// <summary>
        /// Handles the Manage Alerts Settings button OnClick event.  Takes the user to the
        /// UserProfile.aspx page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnManageAlertsSettings_Click(object sender, EventArgs e)
        {
            SetReturnURL(PageConstants.Format(PageConstants.USER_LIST, hidUserListID.Value));
            Response.Redirect(PageConstants.USER_PROFILE);
        }

        /// <summary>
        /// Handles the Manage Connection List button OnClick event.  Takes the user to the
        /// EMCW_ReferenceList.aspx page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnManageConnList_Click(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.EMCW_REFERENCELIST);
        }

        /// <summary>
        /// Helper method that helps with bi-directional sorting
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void GridView_Sorting(Object sender, GridViewSortEventArgs e)
        {
            SetSortingAttributes((GridView)sender, e);
            PopulateCompanyList();
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

            // If the company displayed in the list has a comp_PRLastPublishedCSDate within the past
            // 90 days (config value), highlight the row with the appropriate color (config value)
            // NOTE: Removed 11/06/07 - GetCompanyDataForCell places "recently changed" icon next to company
            // name - highlight is no longer required.

            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                // if the company is not listed, display label not link for company name
                string szListingStatus = (string)DataBinder.Eval(e.Row.DataItem, "comp_PRListingStatus");
                
                if (string.IsNullOrEmpty(szListingStatus) || "L,H,N3,N5,N6".IndexOf(szListingStatus) == -1)
                {
                    HyperLink hlCompanyDetails = (HyperLink)e.Row.FindControl("hlCompanyDetails");
                    Label lblCompanyDetails = (Label)e.Row.FindControl("lblCompanyDetails");

                    hlCompanyDetails.Visible = false;
                    lblCompanyDetails.Visible = true;
                }
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
                string szSelectedIDs = GetRequestParameter("cbCompanyID", false);
                if (!String.IsNullOrEmpty(szSelectedIDs))
                {
                    string[] aszIDs = szSelectedIDs.Split(',');
                    _lSelectedIDs.AddRange(aszIDs);
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
                oButton.Attributes.Add("onclick", "return confirmOneSelected('" + Resources.Global.Company + "', 'cbCompanyID')");
            }
            else
            {
                oButton.Attributes.Add("onclick", "return confirmSelect('" + Resources.Global.Company + "', 'cbCompanyID')");
            }
        }

        protected void btnRemove_Click(object sender, EventArgs e)
        {
            oTran = GetObjectMgr().BeginTransaction();
            try
            {
                // Delete any PRWebUserDetail records for those companies checked "Remove"
                string szCompaniesToRemove = GetRequestParameter("cbCompanyID", false);
                if (!String.IsNullOrEmpty(szCompaniesToRemove))
                {
                    string[] aszCompaniesToRemove = szCompaniesToRemove.Split(new char[] { ',' });

                    foreach (string szCompanyID in aszCompaniesToRemove)
                    {
                        if (!String.IsNullOrEmpty(szCompanyID))
                        {
                            // Remove PRWebUserDetail Record
                            DeletePRWebUserListDetail(Convert.ToInt32(hidUserListID.Value), Convert.ToInt32(szCompanyID));
                        }
                    }

                    GeneralDataMgr oMgr = new GeneralDataMgr(_oLogger, _oUser);
                    oMgr.UpdatePRWebUserList(Convert.ToInt32(hidUserListID.Value), oTran);
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

            Response.Redirect(PageConstants.Format(PageConstants.USER_LIST, hidUserListID.Value));
        }

        /// <summary>
        /// Handles the Add To Another Watchdog List on click event.  Invokes the Save Selected function to save
        /// the selected company's on the form, and takes the user to the UserListAddTo.aspx page specifying
        /// the selected companies.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnAddToWatchdog_Click(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(hidSelectedCompanyIDs.Value))
            {
                SetRequestParameter("CompanyIDList", hidSelectedCompanyIDs.Value);
                Response.Redirect(PageConstants.USER_LIST_ADD_TO);
            }
        }
    }
}
