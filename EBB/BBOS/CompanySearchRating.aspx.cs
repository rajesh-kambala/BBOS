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

 ClassName: CompanySearchRating
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/

using System;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;

using PRCo.EBB.BusinessObjects;
using PRCo.EBB.Util;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This page contains the rating search fields for searching companies
    /// including the trading/transportation membership year, BB score, integrity/ability rating
    /// pay description, and credit worth rating.
    /// 
    /// If Supply and Service is selected as the Industry Type the rating search form should 
    /// not be displayed.
    ///
    /// <remarks>
    /// The CompanySearchRating.aspx page uses a different approach to generate the commodity listing than what the
    /// SearchWizard1_5.aspx page users.  The SearchWizard1_4.aspx is a bit simplier because we don't
    /// have to interact with AJAX and populate a criteria control.
    /// </remarks>
    /// </summary>
    public partial class CompanySearchRating : CompanySearchBase
    {
        private const string REF_DATA_INTEGRITYRATING = "prin_Name";
        private const string REF_DATA_PAYDESCRIPTION = "prpy_Name";

        /// <summary>
        /// Calls page functions required to build and process this page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            // Set page title, sub-title and add any additional javascript functions
            // required for processing this page
            SetPageTitle(Resources.Global.CompanySearch, Resources.Global.RatingCriteria);
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_FUNCTIONS2_FILE));

            // Add company submenu to this page
            SetSubmenu("btnRating");
            SetPopover();

            if (!IsPostBack)
            {
                LoadLookupValues();
                PopulateForm();
                chkTMFMNotNull.Attributes.Add("onclick", "ToggleMustHave(this, 'TMFM');");

                // Hide/Show items based on current form values
                SetVisibility();
            }

            // Make sure we have the latest search object updated before setting 
            // the search criteria control
            StoreCriteria();

            // Set Search Criteria User Control
            ucCompanySearchCriteriaControl.CompanySearchCriteria = _oCompanySearchCriteria;

            // See issue #54.  Hiding it from the user for now.
            // We should probably remove the code at some point but
            // restoring it would be a pain so let's make sure this
            // is want we want to do first.
            btnNewSearch.Visible = false;
        }

        /// <summary>
        /// Initialize the page controls.  All dynamic page controls
        /// must be pre-built in order for viewstate to be set correctly on 
        /// page load
        /// </summary>
        /// <param name="e"></param>
        override protected void OnInit(EventArgs e)
        {
            base.OnInit(e);

            // Build Integrity/Ability Rating controls
            BuildControlTable(tblIntegrityRating, 2, PREFIX_INTEGRITYRATING, pnlIntegrityLinks, UpdatePanel1);
            // Build Pay Description controls
            BuildControlTable(tblPayRating, 2, PREFIX_PAYDESCRIPTION, pnlPayRatingLinks, UpdatePanel1);

            // Build Pay Indiocator controls
            BuildControlTable(tblPayIndicator, 1, PREFIX_PAYINDICATOR, pnlPayIndicatorLinks, UpdatePanel1);

            // Build Credit Worth Rating controls 
            BuildControlTable(tblCreditWorthRating, 4, PREFIX_CREDITWORTHRATING, pnlCreditLinks, UpdatePanel1);
            // Build Credit Worth Rating controls 
            BuildControlTable(tblCreditWorthRatingL, 4, PREFIX_CREDITWORTHRATING_LUMBER, pnlCreditLinksL, UpdatePanel1);
        }

        protected void SetPopover()
        {
            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                popIndustryType.Attributes.Add("data-bs-title", Resources.Global.IndustryTypeText);
                popCreditWorth.Attributes.Add("data-bs-title", Resources.Global.CreditWorthKDescription); //K=thousand
            }
            else
            {
                popIndustryType.Attributes.Add("data-bs-title", string.Format("{0}<br/>{1}", Resources.Global.IndustryTypeText, Resources.Global.SearchByRatingText));
                popCreditWorth.Attributes.Add("data-bs-title", Resources.Global.CreditWorthMDescription); //M=thousand
            }

            popWhatIsBBScore.Attributes.Add("data-bs-title", Resources.Global.BBScoreDefinition);
        }

        /// <summary>
        /// Check users page level authorization
        /// </summary>
        /// <returns></returns>
        override protected bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchRatingPage).HasPrivilege;
        }

        /// <summary>
        /// Check users control/data level authorization
        /// </summary>
        /// <returns></returns>
        protected override bool IsAuthorizedForData()
        {
            // Trading Membership Year
            List<Control> lMembershipYearControls = new List<Control>();
            lMembershipYearControls.Add(chkTMFMNotNull);
            ApplySecurity(lMembershipYearControls, SecurityMgr.Privilege.CompanySearchByTMFMMembershipYear);

            // BB Score
            List<Control> lBBScoreControls = new List<Control>();
            //lBBScoreControls.Add(lblBBScore);
            lBBScoreControls.Add(ddlBBScoreSearchType);
            lBBScoreControls.Add(txtBBScore);
            ApplySecurity(lBBScoreControls, SecurityMgr.Privilege.CompanySearchByBBScore);

            // Credit Worth
            List<Control> lCreditWorthControls = new List<Control>();
            //lCreditWorthControls.Add(lblCreditWorth);
            lCreditWorthControls.Add(pnlCreditLinks);
            lCreditWorthControls.Add(tblCreditWorthRating);
            lCreditWorthControls.Add(pnlCreditLinksL);
            lCreditWorthControls.Add(tblCreditWorthRatingL);
            ApplySecurity(lCreditWorthControls, SecurityMgr.Privilege.CompanySearchByCreditWorthRating);

            // Integrity / Ability
            List<Control> lIntegrityRatingControls = new List<Control>();
            //lIntegrityRatingControls.Add(lblIntegrityRating);
            lIntegrityRatingControls.Add(pnlIntegrityLinks);
            lIntegrityRatingControls.Add(tblIntegrityRating);
            ApplySecurity(lIntegrityRatingControls, SecurityMgr.Privilege.CompanySearchByIntegrityRating);

            // Pay Description
            List<Control> lPayDescriptionControls = new List<Control>();
            //lPayDescriptionControls.Add(lblPayRating);
            lPayDescriptionControls.Add(pnlPayRatingLinks);
            lPayDescriptionControls.Add(tblPayRating);
            ApplySecurity(lPayDescriptionControls, SecurityMgr.Privilege.CompanySearchByPayRating);

            // Pay Indicator
            List<Control> lPayIndicatorControls = new List<Control>();
            //lPayIndicatorControls.Add(lblPayIndicator);
            lPayIndicatorControls.Add(pnlPayIndicatorLinks);
            lPayIndicatorControls.Add(tblPayIndicator);
            ApplySecurity(lPayIndicatorControls, SecurityMgr.Privilege.CompanySearchByPayIndicator);

            // Save Search Criteria requires Level 3 access
            List<Control> lSaveSearchControls = new List<Control>();
            lSaveSearchControls.Add(btnSaveSearch);
            lSaveSearchControls.Add(btnLoadSearch);
            ApplySecurity(lSaveSearchControls, SecurityMgr.Privilege.SaveSearches);
            ApplyReadOnlyCheck(btnSaveSearch);

            // Pay Report Count
            List<Control> lPayReportCountControls = new List<Control>();
            //lPayReportCountControls.Add(lblPayReportCount);
            lPayReportCountControls.Add(ddlPayReportCountSearchType);
            lPayReportCountControls.Add(txtPayReportCount);
            ApplySecurity(lPayReportCountControls, SecurityMgr.Privilege.CompanySearchByPayReportCount);

            return true;
        }

        /// <summary>
        /// Loads all of the databound controls setting 
        /// thier default values.
        /// </summary>
        protected void LoadLookupValues()
        {
            // Bind Industry Type control
            BindLookupValues(rblIndustryType, GetReferenceData(REF_DATA_INDUSTRY_TYPE));
            ModifyIndustryType(rblIndustryType);

            // Create Search Type list
            List<ICustom_Caption> lSearchTypeValues = GetSearchTypeValues();

            // Bind Membership Year Search Type drop-down
            //BindLookupValues(ddlMembershipYearSearchType, lSearchTypeValues);

            // Bind BB Score search type drop-down
            BindLookupValues(ddlBBScoreSearchType, lSearchTypeValues);

            // Bind Pay Report Count search type drop-down
            BindLookupValues(ddlPayReportCountSearchType, lSearchTypeValues);

            // Create Membership Year List
            List<ICustom_Caption> lMembershipYearValues = new List<ICustom_Caption>();
            for (int i = 1901; i <= DateTime.Now.Year; i++)
            {
                ICustom_Caption oCustom_Caption4 = new Custom_Caption();
                oCustom_Caption4.Code = i.ToString();
                oCustom_Caption4.Meaning = i.ToString();
                lMembershipYearValues.Add(oCustom_Caption4);
            }

            // Bind Integrity/Ability Rating controls
            // NOTE: Dynamic control - done in page OnInit to correctly process viewstate

            // Bind Pay Description Controls
            // NOTE: Dynamic control - done in page OnInit to correctly process viewstate

            // Bind Credit Worth Rating Controls
            // NOTE: Dynamic control - done in page OnInit to correctly process viewstate
        }

        /// <summary>
        /// Populates the form controls based on the current 
        /// company search criteria object
        /// </summary>
        protected void PopulateForm()
        {
            // Set Rating Criteria Information
            SetListDefaultValue(rblIndustryType, _oCompanySearchCriteria.IndustryType);

            // Set Profile Criteria Information
            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                // Pay Report Count
                SetListDefaultValue(ddlPayReportCountSearchType, _oCompanySearchCriteria.PayReportCountSearchType);
                if (_oCompanySearchCriteria.PayReportCount > -1)
                {
                    txtPayReportCount.Text = _oCompanySearchCriteria.PayReportCount.ToString();
                }

                // Pay Indicator
                string[] aszPayIndicator = UIUtils.GetString(_oCompanySearchCriteria.PayIndicator).Split(new char[] { ',' });
                SetTableValues(aszPayIndicator, tblPayIndicator, PREFIX_PAYINDICATOR);
            }
            else
            {
                chkTMFMNotNull.Checked = _oCompanySearchCriteria.IsTMFM;

                // Integrity / Ability Rating
                string[] aszIntegrityRating = UIUtils.GetString(_oCompanySearchCriteria.RatingIntegrityIDs).Split(new char[] { ',' });
                SetTableValues(aszIntegrityRating, tblIntegrityRating, PREFIX_INTEGRITYRATING);

                // Pay Description
                string[] aszPayDescriptions = UIUtils.GetString(_oCompanySearchCriteria.RatingPayIDs).Split(new char[] { ',' });
                SetTableValues(aszPayDescriptions, tblPayRating, PREFIX_PAYDESCRIPTION);
            }

            // BB Score
            SetListDefaultValue(ddlBBScoreSearchType, _oCompanySearchCriteria.BBScoreSearchType);
            txtBBScore.Text = UIUtils.GetStringFromInt(_oCompanySearchCriteria.BBScore, true);


            // Credit Worth Rating
            string[] aszCreditRatings = UIUtils.GetString(_oCompanySearchCriteria.RatingCreditWorthIDs).Split(new char[] { ',' });
            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                SetTableValues(aszCreditRatings, tblCreditWorthRatingL, PREFIX_CREDITWORTHRATING);
            else
                SetTableValues(aszCreditRatings, tblCreditWorthRating, PREFIX_CREDITWORTHRATING);
        }

        /// <summary>
        /// Used to show/hide form elements based on the current page
        /// settings
        /// </summary>
        protected void SetVisibility()
        {
            // If the Produce or Transportation industry type is not selected, 
            // do not display the ratings search form and discard any selected criteria.
            if (rblIndustryType.SelectedValue == GeneralDataMgr.INDUSTRY_TYPE_SUPPLY)
            {
                pnlRatingForm.Visible = false;
                _oCompanySearchCriteria.MemberYear = 0;
                _oCompanySearchCriteria.MemberYearSearchType = "";
                _oCompanySearchCriteria.BBScoreSearchType = "";
                _oCompanySearchCriteria.BBScore = 0;
                _oCompanySearchCriteria.RatingIntegrityIDs = "";
                _oCompanySearchCriteria.RatingPayIDs = "";
                _oCompanySearchCriteria.RatingCreditWorthIDs = "";
                _oCompanySearchCriteria.PayIndicator = "";
            }
            else
                pnlRatingForm.Visible = true;

            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                //pnlIndustryType.Visible = false;

                tblCreditWorthRating.Visible = false;
                pnlCreditLinks.Visible = false;

                trPayRating.Visible = false;
                trMembershipYear.Visible = false;
                trIntegrityRating.Visible = false;
            }
            else
            {
                trPayReportCount.Visible = false;
                tblCreditWorthRatingL.Visible = false;
                pnlCreditLinksL.Visible = false;

                trPayIndicator.Visible = false;
            }

            ApplySecurity(pnlIndustryType, SecurityMgr.Privilege.CompanySearchByIndustry);

#if LOCALGROWERSEBETA
            litSearchByRatingText.Visible = false;
#endif
        }

        /// <summary>
        /// Collects and stores the search criteria on the users current company search
        /// criteria object 
        /// </summary>
        protected override void StoreCriteria()
        {
            // Save Company Rating Search Criteria
            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                _oCompanySearchCriteria.PayReportCountSearchType = ddlPayReportCountSearchType.SelectedValue;
                if (txtPayReportCount.Text.Length > 0)
                    _oCompanySearchCriteria.PayReportCount = Convert.ToInt32(txtPayReportCount.Text);
                else
                    _oCompanySearchCriteria.PayReportCount = -1; // Magic Number

                _oCompanySearchCriteria.RatingCreditWorthIDs = GetTableValues(tblCreditWorthRatingL, PREFIX_CREDITWORTHRATING_LUMBER);

                _oCompanySearchCriteria.PayIndicator = GetTableValues(tblPayIndicator, PREFIX_PAYINDICATOR);

            }
            else
            {
                // Industry Type
                _oCompanySearchCriteria.IndustryType = rblIndustryType.SelectedValue;

                _oCompanySearchCriteria.IsTMFM = chkTMFMNotNull.Checked;

                //Trade practices rating: change to only four options.  If XXX selected include XXX148 and if XX selected include XX147. Per homework doc.
                //string strRatingIntegrityIDs = GetTableValues(tblIntegrityRating, PREFIX_INTEGRITYRATING);
                //if(strRatingIntegrityIDs.Contains("5") && !strRatingIntegrityIDs.Contains("4"))
                //  strRatingIntegrityIDs += ",4";
                //if (strRatingIntegrityIDs.Contains("2") && !strRatingIntegrityIDs.Contains("3"))
                //  strRatingIntegrityIDs += ",3";

                _oCompanySearchCriteria.RatingIntegrityIDs = GetTableValues(tblIntegrityRating, PREFIX_INTEGRITYRATING);

                _oCompanySearchCriteria.RatingPayIDs = GetTableValues(tblPayRating, PREFIX_PAYDESCRIPTION);
                _oCompanySearchCriteria.RatingCreditWorthIDs = GetTableValues(tblCreditWorthRating, PREFIX_CREDITWORTHRATING);
            }

            // BBScore
            if (txtBBScore.Text.Length > 0)
                _oCompanySearchCriteria.BBScore = Convert.ToInt32(txtBBScore.Text);
            else
                _oCompanySearchCriteria.BBScore = 0;
            _oCompanySearchCriteria.BBScoreSearchType = ddlBBScoreSearchType.SelectedValue;

            base.StoreCriteria();
        }

        /// <summary>
        /// Clears and restores the search criteria on the users current company search
        /// criteria object.
        /// </summary>
        protected override void ClearCriteria()
        {
            // Clear the corresponding Company Search Criteria object and 
            // reload the page
            chkTMFMNotNull.Checked = false;

            // BB Score
            ddlBBScoreSearchType.SelectedIndex = -1;
            txtBBScore.Text = "";

            // Integrity/Ability Rating
            ClearTableValues(tblIntegrityRating);

            // Pay Description
            ClearTableValues(tblPayRating);

            // Pay Indicator
            ClearTableValues(tblPayIndicator);

            // Credit Worth Rating
            ClearTableValues(tblCreditWorthRating);
            ClearTableValues(tblCreditWorthRatingL);

            ddlPayReportCountSearchType.SelectedIndex = -1;
            txtPayReportCount.Text = "";

            _szRedirectURL = PageConstants.COMPANY_SEARCH_RATING;
        }

        /// <summary>
        /// Set page to auto-generate javascript variables for form elements.
        /// This is required for the [must have] checkboxes on the fax and email
        /// form items.
        /// </summary>
        /// <returns></returns>
        public override bool EnableJSClientIDTranslation()
        {
            return true;
        }

        /// <summary>
        /// Make sure our ToggleInitialState JS function gets
        /// called to set come control states appropriately.
        /// </summary>
        public override void PreparePageFooter()
        {
            base.PreparePageFooter();

            if (_oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchByTMFMMembershipYear).HasPrivilege)
            {
                Page.ClientScript.RegisterStartupScript(this.GetType(), "OnPageLoadJS", "ToggleInitialStateRating();", true);
            }
        }

        protected void rblIndustryType_SelectedIndexChanged(object sender, EventArgs e)
        {
            PopulateForm();
            // Hide/Show items based on current form values
            SetVisibility();
        }
    }
}
