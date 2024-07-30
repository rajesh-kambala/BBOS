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

 ClassName: SearchCompany.aspx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/

using System;
using System.Collections;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This page allows the user to select a company.  The user will be allowed to search for a company
    /// based on the following criteria: company name, city, country, and state/province.
    /// 
    /// Once the search has been executed, the user will be allowed to select a company, and is returned
    /// to the page specified by the ReturnURL.
    /// 
    /// The selected company ID will be stored in the Session["CompanyID"].
    /// </summary>
    public partial class SelectCompany : PageBase
    {
        protected const string SQL_SEARCH =
            @"SELECT TOP {0} *, 
                     dbo.ufn_GetCustomCaptionValue('comp_PRIndustryType', comp_PRIndustryType, '{1}') As IndustryType, 
                     dbo.ufn_GetCustomCaptionValue('comp_PRType_BBOS', comp_PRType, '{1}') As CompanyType, 
                     dbo.ufn_HasNote({2}, {3}, comp_CompanyID, 'C') As HasNote,
                     dbo.ufn_HasNewClaimActivity(comp_PRHQID, '{5}') as HasNewClaimActivity, 
                     dbo.ufn_HasMeritoriousClaim(comp_PRHQID, '{6}') as HasMeritoriousClaim,
                     dbo.ufn_HasCertification(comp_PRHQID) as HasCertification,
                     dbo.ufn_HasCertification_Organic(comp_PRHQID) as HasCertification_Organic,
                     dbo.ufn_HasCertification_FoodSafety(comp_PRHQID) as HasCertification_FoodSafety
                FROM vPRBBOSCompanyList
               WHERE comp_CompanyID IN ({4})
                 AND {7} AND {8} ";

        private CompanySearchCriteria oCompanySearch;

        /// <summary>
        /// Calls page functions required to build and process this page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            // Set page title
            SetPageTitle(Resources.Global.SelectCompany);

            // Setup javascript form validaton for the report manual connection section
            EnableFormValidation();

            // The search, select, and cancel buttons on the other sections should not 
            // cause this validation to occur.
            btnSearch.OnClientClick = "DisableValidation();";
            btnSelect.OnClientClick = "DisableValidation();";
            btnCancel.OnClientClick = "DisableValidation();";
            btnCancel2.OnClientClick = "DisableValidation();";
            btnCancel3.OnClientClick = "DisableValidation();";

            SetPopover();

            if (!IsPostBack)
            {
                // Stash our Return URL in a hidden form field
                ReturnURL.Value = GetReturnURL(PageConstants.BBOS_HOME);

                // Setup our "context", or default values, for our cascading
                // dropdown lists.
                if (_oUser.prwu_CountryID != 0)
                {
                    cddCountry.ContextKey = _oUser.prwu_CountryID.ToString();
                    cddMailCountry.ContextKey = _oUser.prwu_CountryID.ToString();
                }
                else
                {
                    // Default to USA
                    cddCountry.ContextKey = "1";
                    cddMailCountry.ContextKey = "1";
                }

                cddState.ContextKey = _oUser.prwu_StateID.ToString();
                cddMailState.ContextKey = _oUser.prwu_StateID.ToString();

                aceCompanyName.ContextKey = _oUser.prwu_IndustryType;

                SetSortField(gvSearchResults, "CompanyType");
                SetSortAsc(gvSearchResults, false);
            }

            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_FUNCTIONS2_FILE));
            //Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_VALIDATION_FILE));
            btnSelect.Attributes.Add("onclick", "return confirmSelect('" + Resources.Global.Company + "', 'rbCompanyID')");
        }

        protected void SetPopover()
        {
            popBBNumber.Attributes.Add("data-bs-title", Resources.Global.BBNumberDefinition);
        }


        /// <summary>
        /// Check users page level authorization        
        /// </summary>
        /// <returns></returns>
        override protected bool IsAuthorizedForPage()
        {
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

        /// <summary>
        /// Loads all of the databound controls setting 
        /// thier default values.
        /// </summary>
        protected void LoadLookupValues()
        {
            // NOTE: Country and State/Province controls are loaded through AJAX
        }

        /// <summary>
        /// Executes the company search given the criteria specified on the search form.
        /// </summary>
        private void ExecuteSearch()
        {
            oCompanySearch = new CompanySearchCriteria();
            oCompanySearch.WebUser = _oUser;

            RetrieveFormValues();

            ArrayList oParameters;
            object[] args = {Configuration.CompanySearchMaxResults,
                             _oUser.prwu_Culture,
                             _oUser.prwu_WebUserID,
                             _oUser.prwu_HQID,
                             oCompanySearch.GetSearchSQL(out oParameters),
                             DateTime.Today.AddDays(0 - Configuration.ClaimActivityNewThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss"),
                             DateTime.Today.AddDays(0 - Configuration.ClaimActivityMeritoriousThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss"),
                             GetObjectMgr().GetLocalSourceCondition(),
                             GetObjectMgr().GetIntlTradeAssociationCondition()};

            string szSQL = string.Format(SQL_SEARCH, args);
            szSQL += GetOrderByClause(gvSearchResults);

            //((EmptyGridView)gvSearchResults).EmptyTableRowText = GetNoResultsFoundMsg(Resources.Global.Companies);
            gvSearchResults.ShowHeaderWhenEmpty = true;
            gvSearchResults.EmptyDataText = GetNoResultsFoundMsg(Resources.Global.Companies);

            // Execute search and bind the results grid
            gvSearchResults.DataSource = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            gvSearchResults.DataBind();
            EnableBootstrapFormatting(gvSearchResults);

            OptimizeViewState(gvSearchResults);

            // Only query for the total number of rows if our
            // limit was reached on the main query.
            if (gvSearchResults.Rows.Count == Configuration.CompanySearchMaxResults)
            {
                ArrayList oCountParameters;
                oCompanySearch.ListingStatus = "L,H,LUV,N3,N5,N6";
                string szCountSQL = oCompanySearch.GetSearchCountSQL(out oCountParameters);

                int iCount = (int)GetDBAccess().ExecuteScalar(szCountSQL, oCountParameters);
                if (iCount > Configuration.CompanySearchMaxResults)
                {
                    AddUserMessage(string.Format(GetMaxResultsMsg(), iCount.ToString("###,##0"), Configuration.CompanySearchMaxResults.ToString("###,##0")));
                }
            }

            // Display the results count
            lblRecordCount.Text = string.Format(Resources.Global.RecordCountFoundMsg, gvSearchResults.Rows.Count, Resources.Global.Companies);

            // If no records could be found, disable the select and cancel buttons related to the
            // search results
            if (gvSearchResults.Rows.Count == 0)
            {
                btnSelect.Enabled = false;
                btnCancel2.Enabled = false;
            }
            else
            {
                btnSelect.Enabled = true;
                btnCancel2.Enabled = true;
            }
        }

        /// <summary>
        /// Helper method to retrieve the search criteria from the form.
        /// </summary>
        private void RetrieveFormValues()
        {
            if (!string.IsNullOrEmpty(txtBBNum.Text))
            {
                oCompanySearch.BBID = Convert.ToInt32(txtBBNum.Text);
            }

            // Company Name
            oCompanySearch.CompanyName = txtCompanyName.Text;
            // City
            oCompanySearch.ListingCity = txtCity.Text;
            // Country - only send if one is selected
            if (ddlCountry.SelectedValue != "0")
                oCompanySearch.ListingCountryIDs = ddlCountry.SelectedValue;
            // State - only send if one is selected
            if (ddlState.SelectedValue != "0")
                oCompanySearch.ListingStateIDs = ddlState.SelectedValue;
        }

        /// <summary>
        /// Handles the search on click event.  Displays the results grid and executes the search
        /// for companies based on the specified criteria.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            pnlSearchResults.Visible = true;

            // Execute Search
            ExecuteSearch();
        }

        /// <summary>
        /// Handles the cancel on click event.  Takes the user to the page specified by the ReturnURL
        /// parameter.  If none was found, the home page is used for a default.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Response.Redirect(ReturnURL.Value);
        }

        /// <summary>
        /// Handles the select on click event.  Stores the selected CompanyID in a session variable.
        /// Takes the user to the page specified by the ReturnURL parameter.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnSelect_Click(object sender, EventArgs e)
        {
            string szCompanyID = aceSelectedID.Value;
            if (string.IsNullOrEmpty(szCompanyID))
            {
                szCompanyID = GetRequestParameter("rbCompanyID", true);
            }
            ReturnToCaller(szCompanyID);
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            CompanySubmission oCompany = new CompanySubmission();
            oCompany.CompanyName = txtCompanyNameManual.Text;

            Address oAddress = new Address();
            oAddress.Address1 = txtMailStreet1.Text;
            oAddress.Address2 = txtMailStreet2.Text;
            oAddress.Address3 = txtMailStreet3.Text;
            oAddress.Address4 = txtMailStreet4.Text;
            oAddress.City = txtCityManual.Text;
            oAddress.CountryID = Convert.ToInt32(ddlMailCountry.SelectedValue);
            oAddress.StateID = Convert.ToInt32(ddlMailState.SelectedValue);
            oAddress.PostalCode = txtMailPostal.Text;
            oCompany.AddAddress(oAddress);

            Phone oPhone = new Phone();
            oPhone.AreaCode = txtPhoneAreaCode.Text;
            oPhone.Number = txtPhone.Text;
            oPhone.Type = "P";
            oCompany.AddPhone(oPhone);

            Phone oFax = new Phone();
            oFax.AreaCode = txtFaxAreaCode.Text;
            oFax.Number = txtFax.Text;
            oFax.Type = "F";
            oCompany.AddPhone(oFax);

            InternetAddress oEmail = new InternetAddress();
            oEmail.Address = txtEmailAddress.Text;
            oCompany.AddEmail(oEmail);

            Person oPerson = new Person();
            oPerson.LastName = txtContact.Text;
            oCompany.AddPersonnel(oPerson);

            Session["SelectCompanyManualCompany"] = oCompany;
            ReturnToCaller("-1");
        }

        protected void ReturnToCaller(string szCompanyID)
        {
            string szSessionValueName = (string)GetRequestParameter("CompanyIDSessionName", false);
            if (szSessionValueName == null)
                szSessionValueName = "CompanyID";

            Session[szSessionValueName] = szCompanyID;
            Response.Redirect(ReturnURL.Value);
        }

        /// <summary>
        /// Helper method that helps with bi-directional sorting
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void GridView_Sorting(Object sender, GridViewSortEventArgs e)
        {
            SetSortingAttributes((GridView)sender, e);
            ExecuteSearch();
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
        }
    }
}
