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

 ClassName: CompanySearchClassification
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
using PRCo.EBB.Util;
using TSI.Utils;
using PRCo.EBB.BusinessObjects;
using System.Web.UI.HtmlControls;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This page contains the classification search fields for searching companies
    /// including the classification search type, classification id's, number of retail stores,
    /// and the number of restaurant stores.
    /// 
    /// The classifications displayed will be those corresponding to the selected industry types
    /// prcl_BookType value.
    /// 
    /// If available, the count of how many companies have that classification will be listed in
    /// parenthessis after the classification name.
    /// 
    /// The Number of Retail and Restaurant stores will only be enabled if the produce - restaurant 
    /// and/or product - retail classification is selected. 
    /// 
    /// If a new industry type is selected, the previously selected classification criteria will be
    /// discarded.
    /// </summary>
    public partial class CompanySearchClassification : CompanySearchBase
    {
        private const string REF_DATA_NUMBER_OF_STORES = "prc2_StoreCount";

        private const string CLASSIFICATION_ID_RESTAURANT = "320";
        private const string CLASSIFICATION_ID_RETAIL = "330";
        private const string CLASSIFICATION_ID_RETAIL_YARD_DEALER = "2190";

        /// <summary>
        /// Calls page functions required to build and process this page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            // Set page title, sub-title
            SetPageTitle(Resources.Global.CompanySearch, Resources.Global.ClassificationCriteria);

            // Add company submenu to this page
            SetSubmenu("btnClassification");
            SetPopover();

            if (!IsPostBack)
            {
                LoadLookupValues();

                PopulateForm();
            }

            // Make sure we have the latest search object updated before setting 
            // the search criteria control
            StoreCriteria();

            // Hide/Show items based on current form values
            SetVisibility();

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

            _oUser = (IPRWebUser)Session["oUser"];

            // If we don't have a user, take them to the login
            // page.  Sometimes we end up here after the user's auth
            // ticket times out, but for some reason ASP.NET does not
            // take the user to the login page.
            if (_oUser == null)
            {
                Response.Redirect(PageConstants.LOGIN);
                return;
            }

            // Build Produce Classification Table
            BuildClassificationsTable_BootStrap(pnlProduceClass, "0", 1, true, true);

            // Build Transportation Classification Table
            BuildClassificationsTable_BootStrap(pnlTransportationClass, "1", 4, false, true);

            // Build Supply and Service Classification Table
            BuildClassificationsTable_BootStrap(pnlSupplyClass, "2", Utilities.GetIntConfigValue("CompanySearchClassificaitonSupplyColumns", 3), false, true);

            // Build Lumber Classification Table
            BuildClassificationsTable_BootStrap(pnlLumberClass, "3", 1, false, Utilities.GetBoolConfigValue("LumberClassificationCountEnabled", false));

            //Defect 7045 - Limited Access can't click Level 1 checkboxes
            if (_oUser.prwu_AccessLevel == PRWebUser.SECURITY_LEVEL_LIMITED_ACCESS)
            {
                pnlProduceClass.Enabled = false;
                pnlTransportationClass.Enabled = false;
                pnlSupplyClass.Enabled = false;
            }
        }

        protected void SetPopover()
        {
            popIndustryType.Attributes.Add("data-bs-title", Resources.Global.IndustryTypeText);
        }

        /// <summary>
        /// Check users page level authorization
        /// </summary>
        /// <returns></returns>
        override protected bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchClassificationsPage).HasPrivilege;
        }

        /// <summary>
        /// Check users control/data level authorization
        /// </summary>
        /// <returns></returns>
        protected override bool IsAuthorizedForData()
        {
            // Number of Stores
            List<Control> lNumberOfRestaurantControls = new List<Control>();
            lNumberOfRestaurantControls.Add(lblRestaurantStores);
            lNumberOfRestaurantControls.Add(cblNumOfRestaurants);
            ApplySecurity(lNumberOfRestaurantControls, SecurityMgr.Privilege.CompanySearchByNumberofRestaraunts);

            // Retail
            List<Control> lNumberOfRetailControls = new List<Control>();
            lNumberOfRetailControls.Add(lblRetailStores);
            lNumberOfRetailControls.Add(cblNumOfRetail);
            ApplySecurity(lNumberOfRetailControls, SecurityMgr.Privilege.CompanySearchByNumberofRetailStores);

            // Save Search Criteria requires Level 3 access
            List<Control> lSaveSearchControls = new List<Control>();
            lSaveSearchControls.Add(btnSaveSearch);
            lSaveSearchControls.Add(btnLoadSearch);
            ApplySecurity(lSaveSearchControls, SecurityMgr.Privilege.SaveSearches);
            ApplyReadOnlyCheck(btnSaveSearch);

            if (_oUser.prwu_IndustryType != GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                // Classification Search Type
                List<Control> lClassificationSearchType = new List<Control>();
                lClassificationSearchType.Add(lblClassSearchType);
                lClassificationSearchType.Add(rblClassSearchType);
                ApplySecurity(lSaveSearchControls, SecurityMgr.Privilege.CompanySearchByClassifications);

                // Produce Class
                List<Control> lProduceClass = new List<Control>();
                lProduceClass.Add(pnlProduceClass);
                ApplySecurity(lProduceClass, SecurityMgr.Privilege.CompanySearchByClassifications);

                // Transportation
                List<Control> lTransporationClass = new List<Control>();
                lTransporationClass.Add(pnlTransportationClass);
                ApplySecurity(lTransporationClass, SecurityMgr.Privilege.CompanySearchByClassifications);

                // Supply
                List<Control> lSupplyClass = new List<Control>();
                lSupplyClass.Add(pnlSupplyClass);
                ApplySecurity(lSupplyClass, SecurityMgr.Privilege.CompanySearchByClassifications);
            }
            else
            {
                // Lumber
                List<Control> lLumberClass = new List<Control>();
                lLumberClass.Add(pnlLumberClass);
                ApplySecurity(lLumberClass, SecurityMgr.Privilege.CompanySearchByClassifications);
            }

            return true;
        }

        private List<Control> GetSubTables(Table ClassificationTable)
        {
            // Special case of the tables on this page, First row is the header.
            // Return all subtables contained in rows 2 .. n
            List<Control> lTableControls = new List<Control>();
            for (int i = 1; i < ClassificationTable.Rows.Count; i++)
            {
                foreach (TableCell cl in ClassificationTable.Rows[i].Cells)
                {
                    foreach (Control ct in cl.Controls)
                    {
                        if (ct is Table)
                        {
                            lTableControls.Add(ct);
                        }
                    }
                }
            }
            return lTableControls;
        }

        /// <summary>
        /// Loads all of the databound controls setting 
        /// their default values.
        /// </summary>
        protected void LoadLookupValues()
        {
            // Bind Industry Type control
            BindLookupValues(rblIndustryType, GetReferenceData(REF_DATA_INDUSTRY_TYPE));
            ModifyIndustryType(rblIndustryType);

            List<ICustom_Caption> lSearchType = GetSearchTypeList(Resources.Global.ClassificationSearchTypeAny, Resources.Global.ClassificationSearchTypeAll);
            BindLookupValues(rblClassSearchType, lSearchType, CODE_SEARCH_TYPE_ANY);

            // Bind Classifications checkbox list
            // NOTE: Done in page OnInit to correctly process viewstate

            // Bind Number of Retail Stores control
            BindLookupValues(cblNumOfRetail, GetReferenceData(REF_DATA_NUMBER_OF_STORES));

            // Bind Number of Restaurant Stores control
            BindLookupValues(cblNumOfRestaurants, GetReferenceData(REF_DATA_NUMBER_OF_STORES));
        }

        /// <summary>
        /// Populates the form controls based on the current 
        /// company search criteria object
        /// </summary>
        protected void PopulateForm()
        {
            // Set Classification Criteria Information

            // Industry Type 
            SetListDefaultValue(rblIndustryType, _oCompanySearchCriteria.IndustryType);

            // Classification Search Type
            if (!string.IsNullOrEmpty(_oCompanySearchCriteria.ClassificationSearchType))
            {
                SetListDefaultValue(rblClassSearchType, _oCompanySearchCriteria.ClassificationSearchType);
            }

            // Classifications
            string[] aszClassifications = UIUtils.GetString(_oCompanySearchCriteria.ClassificationIDs).Split(CompanySearchBase.achDelimiter);
            SetTableValues_Bootstrap(aszClassifications, pnlProduceClass, PREFIX_CLASS, _oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchByClassifications).HasPrivilege, false, false);
            SetTableValues_Bootstrap(aszClassifications, pnlTransportationClass, PREFIX_CLASS, _oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchByClassifications).HasPrivilege, false, false);
            SetTableValues_Bootstrap(aszClassifications, pnlSupplyClass, PREFIX_CLASS, _oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchByClassifications).HasPrivilege, false, false);
            SetTableValues_Bootstrap(aszClassifications, pnlLumberClass, PREFIX_CLASS, _oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchByClassifications).HasPrivilege, false, false);

            // Number of Retail Stores
            string[] aszNumOfRetailStores = UIUtils.GetString(_oCompanySearchCriteria.NumberOfRetailStores).Split(CompanySearchBase.achDelimiter);
            foreach (string szNumOfRetailStores in aszNumOfRetailStores)
            {
                if (!String.IsNullOrEmpty(szNumOfRetailStores))
                {
                    foreach (ListItem oItem in cblNumOfRetail.Items)
                    {
                        if (szNumOfRetailStores == oItem.Value)
                            oItem.Selected = true;
                    }
                }
            }

            // Number of Restaurant Stores
            string[] aszNumOfRestaurantStores = UIUtils.GetString(_oCompanySearchCriteria.NumberOfRestaurantStores).Split(CompanySearchBase.achDelimiter);
            foreach (string szNumOfRestaurantStores in aszNumOfRestaurantStores)
            {
                if (!String.IsNullOrEmpty(szNumOfRestaurantStores))
                {
                    foreach (ListItem oItem in cblNumOfRestaurants.Items)
                    {
                        if (szNumOfRestaurantStores == oItem.Value)
                            oItem.Selected = true;
                    }
                }
            }

            if (_oCompanySearchCriteria.IncludeLocalSource == "ELS")
            {
                CheckGrowerIncludeLSS.Value = "Y";
            }
        }


        /// <summary>
        /// Used to show/hide form elements based on the current page
        /// settings
        /// </summary>
        protected void SetVisibility()
        {
            // Determine what classification tables to show based on the 
            // Industry type selected
            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                //pnlIndustryType.Visible = false;
                pnlProduceClass.Visible = false;
                pnlTransportationClass.Visible = false;
                pnlSupplyClass.Visible = false;
                pnlLumberClass.Visible = true;
                pnlNumberOfStores.Visible = true;
            }
            else
            {
                switch (rblIndustryType.SelectedValue)
                {
                    case GeneralDataMgr.INDUSTRY_TYPE_PRODUCE:
                        pnlProduceClass.Visible = true;
                        pnlTransportationClass.Visible = false;
                        pnlSupplyClass.Visible = false;
                        pnlNumberOfStores.Visible = true;
                        pnlLumberClass.Visible = false;
                        break;
                    case GeneralDataMgr.INDUSTRY_TYPE_TRANSPORTATION:
                        pnlProduceClass.Visible = false;
                        pnlTransportationClass.Visible = true;
                        pnlSupplyClass.Visible = false;
                        pnlNumberOfStores.Visible = false;
                        pnlLumberClass.Visible = false;
                        break;
                    case GeneralDataMgr.INDUSTRY_TYPE_SUPPLY:
                        pnlProduceClass.Visible = false;
                        pnlTransportationClass.Visible = false;
                        pnlSupplyClass.Visible = true;
                        pnlNumberOfStores.Visible = false;
                        pnlLumberClass.Visible = false;
                        break;
                }
            }

            ApplySecurity(pnlIndustryType, SecurityMgr.Privilege.CompanySearchByIndustry);

            // Enable Number of Retail Stores if retail classification is selected
            pnlNumberOfStores.Visible = false; //only make visible later if Retail or Restaurant is chosen

            if (!String.IsNullOrEmpty(_oCompanySearchCriteria.ClassificationIDs))
            {
                if ((_oCompanySearchCriteria.ClassificationIDs.Contains(CLASSIFICATION_ID_RETAIL)) ||
                    (_oCompanySearchCriteria.ClassificationIDs.Contains(CLASSIFICATION_ID_RETAIL_YARD_DEALER)))
                {
                    pnlNumberOfStores.Visible = true;
                    lblRetailStores.Enabled = true;
                    cblNumOfRetail.Enabled = true;
                }
                else
                {
                    lblRetailStores.Enabled = false;
                    cblNumOfRetail.SelectedIndex = -1;
                    cblNumOfRetail.Enabled = false;
                    _oCompanySearchCriteria.NumberOfRetailStores = "";
                }
            }
            else
            {
                lblRetailStores.Enabled = false;
                cblNumOfRetail.SelectedIndex = -1;
                cblNumOfRetail.Enabled = false;
                _oCompanySearchCriteria.NumberOfRetailStores = "";
            }

            // Enable Number of Restaurant Stores if restaurant classification is selected
            if (!String.IsNullOrEmpty(_oCompanySearchCriteria.ClassificationIDs))
            {
                if (_oCompanySearchCriteria.ClassificationIDs.Contains(CLASSIFICATION_ID_RESTAURANT))
                {
                    pnlNumberOfStores.Visible = true;
                    lblRestaurantStores.Enabled = true;
                    cblNumOfRestaurants.Enabled = true;
                }
                else
                {
                    lblRestaurantStores.Enabled = false;
                    cblNumOfRestaurants.SelectedIndex = -1;
                    cblNumOfRestaurants.Enabled = false;
                    _oCompanySearchCriteria.NumberOfRestaurantStores = "";
                }
            }
            else
            {
                lblRestaurantStores.Enabled = false;
                cblNumOfRestaurants.SelectedIndex = -1;
                cblNumOfRestaurants.Enabled = false;
                _oCompanySearchCriteria.NumberOfRestaurantStores = "";
            }


            // If a Level 1 classification has been selected, disable only and all search types and 
            // default the search type to any.  This applies only to Produce classifications.  Trans and 
            // Supply industry types do not have selectable top level items.
            bool blnAnyLevel1Checked = false;

            foreach (CheckBox oCheckBox in pnlProduceClass.FindDescendants<CheckBox>())
            {
                if (oCheckBox.Checked && oCheckBox.InputAttributes["ParentID"] == null)
                {
                    blnAnyLevel1Checked = true;
                }
            }

            if(blnAnyLevel1Checked)
            {
                _oCompanySearchCriteria.ClassificationSearchType = CODE_SEARCH_TYPE_ANY;
                rblClassSearchType.SelectedIndex = 0;

                rblClassSearchType.Items[1].Enabled = false;
            }
            else
            {
                rblClassSearchType.Items[1].Enabled = true;
            }
        }

        /// <summary>
        /// Collects and stores the search criteria on the users current company search
        /// criteria object 
        /// </summary>
        protected override void StoreCriteria()
        {
            // Save Company Classification Search Criteria
            // Industry Type
            if (_oUser.prwu_IndustryType != GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                _oCompanySearchCriteria.IndustryType = rblIndustryType.SelectedValue;
            }

            // Classification Search Type
            _oCompanySearchCriteria.ClassificationSearchType = rblClassSearchType.SelectedValue;

            // Classifications
            if (_oUser.prwu_IndustryType != GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                switch (rblIndustryType.SelectedValue)
                {
                    case GeneralDataMgr.INDUSTRY_TYPE_PRODUCE:
                        _oCompanySearchCriteria.ClassificationIDs = GetCheckboxValues_Bootstrap(pnlProduceClass, PREFIX_CLASS);  
                        break;
                    case GeneralDataMgr.INDUSTRY_TYPE_TRANSPORTATION:
                        _oCompanySearchCriteria.ClassificationIDs = GetCheckboxValues_Bootstrap(pnlTransportationClass, PREFIX_CLASS);
                        break;
                    case GeneralDataMgr.INDUSTRY_TYPE_SUPPLY:
                        _oCompanySearchCriteria.ClassificationIDs = GetCheckboxValues_Bootstrap(pnlSupplyClass, PREFIX_CLASS);
                        break;
                }
            }
            else
            {
                _oCompanySearchCriteria.ClassificationIDs = GetCheckboxValues_Bootstrap(pnlLumberClass, PREFIX_CLASS);
            }

            // Number of Retail Stores
            StringBuilder sbNumOfRetailStores = new StringBuilder();

            foreach (ListItem oListItem in cblNumOfRetail.Items)
            {
                if (oListItem.Selected)
                {
                    AddDelimitedValue(sbNumOfRetailStores, oListItem.Value);
                }
            }

            _oCompanySearchCriteria.NumberOfRetailStores = sbNumOfRetailStores.ToString();

            // Number of Restaurant Stores
            StringBuilder sbNumOfRestaurantStores = new StringBuilder();

            foreach (ListItem oListItem in cblNumOfRestaurants.Items)
            {
                if (oListItem.Selected)
                {
                    AddDelimitedValue(sbNumOfRestaurantStores, oListItem.Value);
                }
            }

            _oCompanySearchCriteria.NumberOfRestaurantStores = sbNumOfRestaurantStores.ToString();

            if (GrowerIncludeLSS.Value == "Y")
            {
                _oCompanySearchCriteria.IncludeLocalSource = "ILS";
            }

            base.StoreCriteria();
        }

        /// <summary>
        /// Clears and stores the search criteria on the users current company search
        /// criteria object 
        /// </summary>
        protected override void ClearCriteria()
        {
            // Clear the corresponding Company Search Criteria object and 
            // reload the page

            // Classification Search Type
            rblClassSearchType.SelectedIndex = -1;

            // Classifications
            ClearTableValues_AllCheckboxes(pnlProduceClass);
            ClearTableValues_AllCheckboxes(pnlTransportationClass);
            ClearTableValues_AllCheckboxes(pnlSupplyClass);
            ClearTableValues_AllCheckboxes(pnlLumberClass);

            // Number of Retail Stores
            cblNumOfRetail.SelectedIndex = -1;

            // Number of Restaurant Stores
            cblNumOfRestaurants.SelectedIndex = -1;

            _szRedirectURL = PageConstants.COMPANY_SEARCH_CLASSIFICATION;
        }

        private HtmlGenericControl CreateDiv(string Class = null, string Id = null, string Role = null)
        {
            return CreateControl("div", Class: Class, Id: Id, Role: Role);
        }

        private HtmlGenericControl CreateControl(string Tag = "div", string Class = null, string Id = null, string Role = null, string Type = null)
        {
            HtmlGenericControl oControl = new HtmlGenericControl(Tag);
            if (Class != null)
                oControl.Attributes.Add("class", Class);
            if (Id != null)
                oControl.Attributes.Add("ID", Id);
            if (Role != null)
                oControl.Attributes.Add("role", Role);
            if (Type != null)
                oControl.Attributes.Add("type", Type);

            return oControl;
        }

        /// <summary>
        /// Builds the Classification checkbox table for the specified book section (bootstrap panel style)
        /// </summary>      
        private void BuildClassificationsTable_BootStrap(Panel oParentPanel, string szBookSection, int iChildColumns,
                bool bIncludeLevel1Check, bool bIncludeClassificationCount)
        {
            // Defect 4519  - show classification counts for ONLY BBSI logins
            if(!IsPRCoUser())
                bIncludeClassificationCount = false;

            // Retrieve Level 1 Classifications
            DataTable dtClassifications = GetClassificationList();
            DataRow[] adrLevel1ClassList = dtClassifications.Select("prcl_BookSection = " + szBookSection + " AND prcl_Level = 1", "prcl_DisplayOrder");

            CheckBox oCheckbox = new CheckBox();
            Label oLabel;

            int iLevel1ColumnCount = 1;

            //Create header divs
            Panel oDivHeading1 = new Panel();
            oDivHeading1.Attributes.Add("class", "row nomargin");

            Panel oDivHeading2 = new Panel();
            oDivHeading2.Attributes.Add("class", "mar_top noborder");

            // Process each level 1 classification
            foreach (DataRow drRow in adrLevel1ClassList)
            {
                #region Create Level 1 Classification controls
                HtmlGenericControl oDivPanelHeading = new HtmlGenericControl("div");
                oDivPanelHeading.Attributes.Add("class", "panel-heading");
                oDivPanelHeading.Attributes.Add("role", "tab");
                oDivPanelHeading.Attributes.Add("id", "heading" + drRow["prcl_ClassificationID"].ToString());

                //HtmlGenericControl oDivH4 = new HtmlGenericControl("h4");
                Panel oDivH4 = new Panel();
                oDivH4.Attributes.Add("class", "panel-title bbos_bg commodityPanelTitle");

                // Create a checkbox control is requested, otherwise just create
                // a label control for this level
                if (bIncludeLevel1Check)
                {
                    // Create a checkbox control for the level 1 classification
                    oCheckbox = new CheckBox();
                    oCheckbox.ID = "CHK_" + PREFIX_CLASS + drRow["prcl_ClassificationID"].ToString();

                    oCheckbox.CssClass = "commodityAllCheckbox";
                    oCheckbox.Attributes.Add("Value", drRow["prcl_ClassificationID"].ToString());
                    oCheckbox.CheckedChanged += new EventHandler(oCheckbox_CheckChanged);
                    oCheckbox.AutoPostBack = true;

                    // If a checkbox is being created, also create a post back trigger
                    // to update the ajax search criteria control
                    AsyncPostBackTrigger oTrigger = new AsyncPostBackTrigger();
                    oTrigger.ControlID = oCheckbox.ID;
                    oTrigger.EventName = "CheckedChanged";
                    UpdatePanel1.Triggers.Add(oTrigger);

                    oDivH4.Controls.Add(oCheckbox);
                }

                // Create a label control to display the level 1 classification
                oLabel = new Label();
                oLabel.ID = "LBL_" + PREFIX_CLASS + drRow["prcl_ClassificationID"].ToString();
                oLabel.Text = drRow["prcl_Name"].ToString();
                if (drRow["prcl_CompanyCount"].ToString().Length > 0)
                    oLabel.Text += GetClassificationCount((int)drRow["prcl_CompanyCount"], (int)drRow["prcl_CompanyCountIncludeLocalSource"], false);

                oDivH4.Controls.Add(oLabel);

                string szPrclName = drRow["prcl_Name"].ToString().Replace(" ", "");  //strip spaces in case there are any (ex: Fruit)

                HtmlGenericControl oI = new HtmlGenericControl("i");
                oI.Attributes.Add("id", "img" + drRow["prcl_Name"].ToString().Replace(" ","")); //strip spaces in case there are any
                oI.Attributes.Add("class", "more-less glyphicon glyphicon-minus");
                oI.Attributes.Add("onclick", string.Format("Toggle_Hid('{0}', document.getElementById('contentMain_hid{0}'));", szPrclName)); 
                oDivH4.Controls.Add(oI);

                oDivHeading2.Controls.Add(oDivH4);
                oDivHeading1.Controls.Add(oDivHeading2);

                iLevel1ColumnCount++;

                oParentPanel.Controls.Add(oDivHeading1);
                #endregion

                // Build Child Classifications on panel
                DataRow[] adrLevel2ClassList = dtClassifications.Select("prcl_ParentID = " + drRow["prcl_ClassificationID"].ToString(), "prcl_DisplayOrder");

                CheckBox oCheckbox2;

                Panel oDivPanelBody = new Panel();
                oDivPanelBody.Attributes.Add("class", "panel-body norm_lbl gray_bg tw-grid tw-grid-cols-1 md:tw-grid-cols-2 lg:tw-grid-cols-3");
                oDivPanelBody.Attributes.Add("style", "padding: 8px;");
                oDivPanelBody.Attributes.Add("id", szPrclName);

                HiddenField oHidden = new HiddenField();
                oHidden.Value = "true";
                oHidden.ID = "hid" + szPrclName;

                oDivPanelBody.Controls.Add(oHidden);

                // Process each child classification
                foreach (DataRow drRow2 in adrLevel2ClassList)
                {
                    // Create table cell for child classification

                    Panel oDivOuter = new Panel();

                    // Create a checkbox control for this classification
                    oCheckbox2 = new CheckBox();
                    oCheckbox2.ID = "CHK_" + PREFIX_CLASS + drRow2["prcl_ClassificationID"].ToString();

                    oCheckbox2.InputAttributes["class"] = "norm_lbl";

                    oCheckbox2.Attributes.Add("Value", drRow2["prcl_ClassificationID"].ToString());

                    if (bIncludeLevel1Check)
                    {
                        oCheckbox2.InputAttributes["ParentID"] = oCheckbox.ID; 
                    }

                    Label oCheckbox2_Label = new Label();
                    oCheckbox2_Label.ID = "lbl" + PREFIX_CLASS + drRow2["prcl_ClassificationID"].ToString();
                    oCheckbox2_Label.Text = drRow2["prcl_Name"].ToString();

                    if (drRow2["prcl_CompanyCount"].ToString().Length > 0)
                    {
                        oCheckbox2_Label.Text += GetClassificationCount((int)drRow2["prcl_CompanyCount"], (int)drRow2["prcl_CompanyCountIncludeLocalSource"], bIncludeClassificationCount);
                    }

                    oCheckbox2_Label.Text += "&nbsp;";
                    oCheckbox2_Label.CssClass = "smaller";

                    oCheckbox2.AutoPostBack = true;
                    oCheckbox2.Attributes.Add("onclick", "disableParent(this);");

                    if (drRow2["prcl_ClassificationID"].ToString() == "360")
                    {  // Grower
                        if (_oUser.HasLocalSourceDataAccess())
                        {
                            oCheckbox2.Attributes.Add("onchange", "checkForLSS();");
                            oCheckbox2.Attributes.Add("class", "nopadding_lr");
                        }
                    }

                    oDivOuter.Controls.Add(oCheckbox2);
                    oDivOuter.Controls.Add(oCheckbox2_Label);

                    if (!drRow2["prcl_ClassificationID"].ToString().Equals("2195") && !drRow2["prcl_ClassificationID"].ToString().Equals("2196"))
                    {
                        HtmlGenericControl oInfoSpan = GetInfoSpan(drRow2); //Add info icon with prcl_Description next to checkbox text

                        //oDivOuter.Controls.Add(oInfoLink2);
                        oDivOuter.Controls.Add(oInfoSpan);
                    }

                    oDivPanelBody.Controls.Add(oDivOuter);
                }

                // Add child classification table to page
                oDivHeading2.Controls.Add(oDivPanelBody);

                HtmlGenericControl oDivSpacer = new HtmlGenericControl("div");
                oDivSpacer.Attributes.Add("class", "row noborder mar_top");
                oDivHeading2.Controls.Add(oDivSpacer);
            }
        }

        private static HyperLink GetInfoHyperlink(DataRow drRow)
        {
            Image oInfoImage = new Image();
            oInfoImage.ImageUrl = "~/images/info_sm.png";
            oInfoImage.ID = "IMG_" + PREFIX_CLASS + drRow["prcl_ClassificationID"].ToString();

            HyperLink oInfoLink = new HyperLink();
            oInfoLink.ID = "A_" + PREFIX_CLASS + drRow["prcl_ClassificationID"].ToString();
            oInfoLink.CssClass = "clr_blc";
            oInfoLink.Attributes.Add("href", "#");
            oInfoLink.Attributes.Add("data-bs-trigger", "hover");
            oInfoLink.Attributes.Add("data-bs-html", "true");
            oInfoLink.Attributes.Add("style", "color: #000;");
            oInfoLink.Attributes.Add("data-bs-toggle", "popover");
            oInfoLink.Attributes.Add("data-bs-placement", "bottom");
            oInfoLink.Attributes.Add("data-bs-title", drRow["prcl_Description"].ToString());

            //oInfoLink.ToolTip = drRow["prcl_Description"].ToString();
            if (drRow["prcl_Description"].ToString().Length > 0)
                oInfoLink.Controls.Add(oInfoImage);

            return oInfoLink;
        }
        private static HtmlGenericControl GetInfoSpan(DataRow drRow)
        {
            HtmlGenericControl span = new HtmlGenericControl("span");
            span.InnerHtml = "help";
            span.Attributes["class"] = "msicon notranslate help";
            span.Attributes["data-bs-toggle"] = "tooltip";
            span.Attributes["data-bs-placement"] = "right";
            span.Attributes["data-bs-html"] = "true";
            span.Attributes["data-bs-title"] = drRow["prcl_Description"].ToString();

            return span;
        }

        private string GetClassificationCount(int iCount, int iCountIncludeLocalSource, bool bIncludeClassificationCount)
        {
            //if _oUser.HasLocalSourceDataAccess() use new count field, not old - defect 4104
            if (bIncludeClassificationCount)
            {
                if (_oUser.HasLocalSourceDataAccess())
                    return " (" + iCountIncludeLocalSource.ToString("###,##0") + ")";
                else
                    return " (" + iCount.ToString("###,##0") + ")";
            }
            else
            {
                return string.Empty;
            }
        }

        /// <summary>
        /// Process on check changed events for checkboxes in the classification table.
        /// If the level 1 classification is selected, all child classification should be disabled 
        /// and included in the search.  Reset the table values, store updated criteria, and 
        /// refresh page to update the search criteria user control.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override protected void oCheckbox_CheckChanged(object sender, EventArgs e)
        {
            // Always deselect the children.  This 
            CheckBox checkbox = (CheckBox)sender;
            string checkboxVal = checkbox.Attributes["Value"].ToString();
            string parentTblID = "CHK_CLASS" + checkboxVal;
            if(checkbox.Checked)
                SelectChildren_BootStrap(parentTblID, pnlProduceClass, PREFIX_CLASS, true);
            else if(AllChildrenChecked(parentTblID, pnlProduceClass, PREFIX_CLASS))
                SelectChildren_BootStrap(parentTblID, pnlProduceClass, PREFIX_CLASS, false);

            StoreCriteria();

            string[] aszClassifications = UIUtils.GetString(_oCompanySearchCriteria.ClassificationIDs).Split(new char[] { ',' });
            SetTableValues_Bootstrap(aszClassifications, pnlProduceClass, PREFIX_CLASS, _oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchByClassifications).HasPrivilege, false, true);

            ucCompanySearchCriteriaControl.BuildSearchCriteria();
        }

        protected void SelectChildren_BootStrap(string parentID, Panel pnlPanel, string szControlGroupPrefix, bool blnChecked)
        {
            foreach (CheckBox oCheckBox in pnlPanel.FindDescendants<CheckBox>())
            {
                if (oCheckBox.InputAttributes["ParentID"] == parentID)
                {
                    oCheckBox.Checked = blnChecked;
                }
            }
        }

        protected bool AllChildrenChecked(string parentID, Panel pnlPanel, string szControlGroupPrefix)
        {
            foreach (CheckBox oCheckBox in pnlPanel.FindDescendants<CheckBox>())
            {
                if (oCheckBox.InputAttributes["ParentID"] == parentID)
                {
                    if (!oCheckBox.Checked)
                        return false;
                }
            }

            return true;
        }

        protected void DeselectChildren(string parentID, Table tblTable, string szControlGroupPrefix)
        {
            foreach (TableRow oRow in tblTable.Rows)
            {
                foreach (TableCell oCell in oRow.Cells)
                {
                    foreach (Control oControl in oCell.Controls)
                    {
                        if ((!string.IsNullOrEmpty(oControl.ID)) &&
                            (oControl.ID.Contains("CHK_" + szControlGroupPrefix)))
                        {
                            CheckBox oCheckbox = (CheckBox)oControl;
                            if (oCheckbox.InputAttributes["ParentID"] == parentID)
                            {
                                oCheckbox.Checked = false;
                            }
                        }
                        else
                        {
                            // Process Child tables
                            if ((!string.IsNullOrEmpty(oControl.ID)) &&
                                (oControl.ID.Contains("TBL_")))
                            {
                                DeselectChildren(parentID, (Table)oControl, szControlGroupPrefix);
                            }
                        }
                    }
                }
            }
        }

        /// <summary>
        /// Process the selected index changed event for the industry type radio button list.
        /// If a new industry type is selected, the previously selected classification criteria should
        /// be discarded.  Store updated criteria and refresh page to update the search criteria
        /// user control.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void rblIndustryType_SelectedIndexChanged(object sender, EventArgs e)
        {
            // If the user selects a new industy type, discard the previously selected
            // classification criteria
            ClearTableValues_AllCheckboxes(pnlProduceClass);
            ClearTableValues_AllCheckboxes(pnlTransportationClass);
            ClearTableValues_AllCheckboxes(pnlSupplyClass);

            _oCompanySearchCriteria.ClassificationIDs = "";

            // Store search criteria and refresh page
            StoreCriteria();
        }
    }
}