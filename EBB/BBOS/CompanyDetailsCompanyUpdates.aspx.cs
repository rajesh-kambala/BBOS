/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2017

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CompanyDetailsCompanyUpdates.aspx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Data;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web {

    /// <summary>
    /// Displays the company updates for the current company. Allows the user
    /// to filter the list, view the Company Listing, and generate reports.
    /// </summary>
    public partial class CompanyDetailsCompanyUpdates : CompanyDetailsBase
    {
        override protected void Page_Load(object sender, EventArgs e) {
            base.Page_Load(sender, e);

            // Set page title, sub-title
            SetPageTitle(Resources.Global.CompanyDetails, Resources.Global.CompanyUpdates);

            // Add company submenu to this page
            SetSubmenu("btnCompanyDetailsUpdates");

            EnableFormValidation();

            SetPopover();

            if (!IsPostBack) {
                txtDateFrom.Attributes.Add("placeholder", GetCultureInfo_ShortDatePattern().ToUpper());
                txtDateTo.Attributes.Add("placeholder", GetCultureInfo_ShortDatePattern().ToUpper());

                if (GetRequestParameter("do", false) != null)
                {
                    txtDateFrom.Text = DateTime.Now.AddDays(0 - Convert.ToInt32(GetRequestParameter("do"))).ToShortDateString();
                }
                else
                {
                    txtDateFrom.Text = DateTime.Now.AddDays(0 - Configuration.CompanyDetailsUpdateDaysOld).ToShortDateString();
                }

                txtDateTo.Text = DateTime.Now.ToShortDateString();

                hidCompanyID.Text = hidCompanyID.Text = GetRequestParameter("CompanyID", true, true);
                
                SetSortField(gvCompanyUpdates, "prcs_PublishableDate");
                SetSortAsc(gvCompanyUpdates, false);

                dpeRatingNumeralDefinition.ContextKey = _oUser.prwu_IndustryType;

                PopulateForm();
            }

            //Set user controls
            ucCompanyListing.WebUser = _oUser;
            ucCompanyListing.companyID = hidCompanyID.Text;
        }

        protected void SetPopover()
        {
            if ((string)Session["CompanyHeader_szIndustryType"] == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                WhatIsKeyChanges.Attributes.Add("data-bs-title", Resources.Global.KeyChangeDefinitionL);
            else
                WhatIsKeyChanges.Attributes.Add("data-bs-title", Resources.Global.KeyChangeDefinition);
        }

        /// <summary>
        /// Populates the page.
        /// </summary>
        protected void PopulateForm()
        {
            PopulateCompanyUpdates();
            PopulateListing();
        }
          
        /// <summary>
        /// Populates the Company Updates portion of the page.
        /// </summary>
        protected void PopulateCompanyUpdates() {

            ApplySecurity(btnBusinessReport, SecurityMgr.Privilege.BusinessReportPurchase);
            ApplySecurity(btnCompanyUpdateReport, SecurityMgr.Privilege.ReportCompanyUpdateList);
            ApplyReadOnlyCheck(btnBusinessReport);

            IPRWebUserSearchCriteria oWebUserSearchCritiera = new PRWebUserSearchCriteria();
            oWebUserSearchCritiera.prsc_SearchType = PRWebUserSearchCriteria.SEARCH_TYPE_COMPANY_UPDATE;
            CreditSheetSearchCriteria oCriteria = (CreditSheetSearchCriteria)oWebUserSearchCritiera.Criteria;
            oCriteria.WebUser = _oUser;
            
            oCriteria.BBID = Convert.ToInt32(hidCompanyID.Text);
            oCriteria.FromDate = UIUtils.GetDateTime(txtDateFrom.Text, GetCultureInfo(_oUser));
            oCriteria.ToDate = UIUtils.GetDateTime(txtDateTo.Text, GetCultureInfo(_oUser));
            oCriteria.KeyOnly = cbKeyChangesOnly.Checked;
            oCriteria.IncludeNewListings = true;
            
            ArrayList oParameters = new ArrayList();
            string szSQL = oCriteria.GetSearchSQL(out oParameters);
            szSQL += GetOrderByClause(gvCompanyUpdates);

            //((EmptyGridView)gvCompanyUpdates).EmptyTableRowText = GetNoResultsFoundMsg(Resources.Global.CompanyUpdates);
            gvCompanyUpdates.ShowHeaderWhenEmpty = true;
            gvCompanyUpdates.EmptyDataText = GetNoResultsFoundMsg(Resources.Global.CompanyUpdates);

            gvCompanyUpdates.DataSource = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            gvCompanyUpdates.DataBind();
            EnableBootstrapFormatting(gvCompanyUpdates);
        }

        protected const string SQL_SELECT_RATING_NUMERAL_DEFINTION = "SELECT * FROM ufn_GetRatingNumerals('{0}', '{2}')   " +
                                                                     "WHERE Numeral IN ({1}) " +
                                                                     "ORDER BY Numeral;";


        protected const string SQL_GET_LISTING = "SELECT dbo.ufn_GetListingCache({0}, {1})";
        /// <summary>
        /// Populates the Listing portion of the page.
        /// </summary>
        protected void PopulateListing() {
            //pnlListingDetails.Visible = true;
            //lblListing.Visible = true;
            //litListing.Visible = true;

            SecurityMgr.SecurityResult privViewListing = _oUser.HasPrivilege(SecurityMgr.Privilege.ViewCompanyListing);
            if (privViewListing.HasPrivilege)
            {

              ArrayList oParameters = new ArrayList();
              oParameters.Add(new ObjectParameter("CompanyID", hidCompanyID.Text));
              oParameters.Add(new ObjectParameter("FormattingStyle", 0));
              string szSQL = GetObjectMgr().FormatSQL(SQL_GET_LISTING, oParameters);
              //litListing.Text = (string)Session["CompanyHeader_szLocation"] + "<br/>" + (string)GetDBAccess().ExecuteScalar(szSQL, oParameters);
            }
            else
            {
              //litListing.Text = GetBasicListing(hidCompanyID.Text);
            }
        }
        
        protected void btnFilterOnClick(object sender, EventArgs e) {
            PopulateForm();
        }

        protected void btnBusinessReportOnClick(object sender, EventArgs e) {
            Session["CompanyIDList"] = hidCompanyID.Text;
            Response.Redirect(string.Format(PageConstants.BUSINESS_REPORT_CONFIRM_SELECTIONS, hidCompanyID.Text, "Company"));
        }

        protected void btnCompanyUpdateReportOnClick(object sender, EventArgs e) {
            Response.Redirect(PageConstants.Format(PageConstants.GET_REPORT, GetReport.COMPANY_UPDATE_LIST_REPORT) + "&CompanyID=" + hidCompanyID.Text + "&FromDate=" + txtDateFrom.Text + "&ToDate=" + txtDateTo.Text + "&KeyChangesOnly=" + cbKeyChangesOnly.Checked.ToString() + "&IncludeListing=true");  
        }


        /// <summary>
        /// Helper method that helps with bi-directional sorting
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void GridView_Sorting(Object sender, GridViewSortEventArgs e) {
            SetSortingAttributes((GridView)sender, e);
            PopulateForm();
        }

        /// <summary>
        /// Adds the sort indicator to the appropriate column
        /// header.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void GridView_RowDataBound(object sender, GridViewRowEventArgs e) {
            SetSortIndicator((GridView)sender, e);
        }       
        
        protected override string GetCompanyID() {
            if (IsPostBack) {
                return hidCompanyID.Text;
            } else {
                return GetRequestParameter("CompanyID");
            }
        }

        protected override CompanyDetailsHeader GetCompanyDetailsHeader() {
            return ucCompanyDetailsHeader;
        }


        protected override bool IsAuthorizedForPage() {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.CompanyDetailsUpdatesPage).HasPrivilege;
        }
    }
}
