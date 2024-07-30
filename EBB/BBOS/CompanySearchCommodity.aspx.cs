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

 ClassName: CompanySearchCommodity
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
using PRCo.EBB.Util;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This page contains the commodity search fields for searching companies
    /// including the commodity search type, attributes, and commodity id's.
    /// </summary>
    public partial class CompanySearchCommodity : CompanySearchBase
    {
        public const string REF_DATA_ATTRIBUTE_TYPE = "prat_Type";
        private const string PREFIX_COMMODITY = "COMM";

        private int MaxLevel = 3;

        private const string PAGE_VIEW_EXPANDED = "1";
        private const string PAGE_VIEW_BASIC = "0";
        private string _pageView = PAGE_VIEW_BASIC;

        private string PageView
        {
            get{
                return PAGE_VIEW_EXPANDED; //return _pageView;
                //Homework document says that we should just show all commodities, and remove the "Hide expanded" feature (Doesn't seem to work right anyway).
            }
            set { _pageView = (value == PAGE_VIEW_EXPANDED ? PAGE_VIEW_EXPANDED : PAGE_VIEW_BASIC); }
        }

        /// <summary>
        /// Calls page functions required to build and process this page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            // Set page title, sub-title
            SetPageTitle(Resources.Global.CompanySearch, Resources.Global.CommodityCriteria);

            // Add company submenu to this page
            SetSubmenu("btnCommodity");
            SetPopover();

            PopulateCheckboxValues();

            if (!IsPostBack)
            {
                //CheckForExpandedCriteria();
                LoadLookupValues();
                PopulateForm();
                //} else {
                //    Page.ClientScript.RegisterStartupScript(this.GetType(), "ctrl_ids", "initPageDisplay();", true);
            }

            // Hide/Show items based on current form values
            SetVisibility();

            // Make sure we have the latest search object updated before setting 
            // the search criteria control
            StoreCriteria();

            // Set Search Criteria User Control
            ucCompanySearchCriteriaControl.CompanySearchCriteria = _oCompanySearchCriteria;

            // Page & Layout view hyperlinks; Toggle captions and link according to current conditions.
            bool isViewExpanded = (PageView == PAGE_VIEW_EXPANDED);
            //hlPageViewTitle.Text = (isViewExpanded ? Resources.Global.HideExpandedCommodities : Resources.Global.ShowAllCommodities);
            //hlPageView.NavigateUrl = GetRedirectUrl((isViewExpanded ? PAGE_VIEW_BASIC : PAGE_VIEW_EXPANDED));

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

            if (!String.IsNullOrEmpty(Request["SearchID"]))
                Int32.TryParse(GetRequestParameter("SearchID"), out _iSearchID);
            else
                _iSearchID = 0;

            RetrieveObject();

            // Determine if user has selected expanded or basic view 
            // This is required here in order to correctly initialize the 
            // commodity listing table
            PageView = Request.QueryString["CommodityExpanded"];

            CheckForExpandedCriteria();
            MaxLevel = (PageView == PAGE_VIEW_EXPANDED ? 7 : 3);
            BuildCommoditiesTables();
        }

        protected void SetPopover()
        {
            popIndustryType.Attributes.Add("data-bs-title", string.Format("{0}<br/>{1}", Resources.Global.IndustryTypeText, Resources.Global.CommoditySearchHeaderText));
        }

        /// <summary>
        /// Check users page level authorization
        /// </summary>
        /// <returns></returns>
        override protected bool IsAuthorizedForPage()
        {
            return HasPrivilege_ITA_Always_True(SecurityMgr.Privilege.CompanySearchCommoditiesPage);
        }

        /// <summary>
        /// Check users control/data level authorization
        /// </summary>
        /// <returns></returns>
        protected override bool IsAuthorizedForData()
        {
            // Save Search Criteria requires Level 3 access
            List<Control> lSaveSearchControls = new List<Control>();
            lSaveSearchControls.Add(btnSaveSearch);
            lSaveSearchControls.Add(btnLoadSearch);
            ApplySecurity(lSaveSearchControls, SecurityMgr.Privilege.SaveSearches, _oUser.IsLimitado);
            ApplyReadOnlyCheck(btnSaveSearch);

            List<Control> lBaseLineSecurityControls = new List<Control>();
            lBaseLineSecurityControls.Add(rblGrowingMethod);
            lBaseLineSecurityControls.Add(rblCountryOfOrigin);
            lBaseLineSecurityControls.Add(rblSizeGroup);
            lBaseLineSecurityControls.Add(rblStyle);
            lBaseLineSecurityControls.Add(rblTreatment);
            ApplySecurity(lBaseLineSecurityControls, SecurityMgr.Privilege.CompanySearchByCommodityAttributes, _oUser.IsLimitado);

            lBaseLineSecurityControls.Clear();
            lBaseLineSecurityControls.Add(tblFruit);
            lBaseLineSecurityControls.Add(tblVegetable);
            lBaseLineSecurityControls.Add(tblHerb);
            lBaseLineSecurityControls.Add(tblFood);
            lBaseLineSecurityControls.Add(tblNut);
            lBaseLineSecurityControls.Add(tblFlower);
            lBaseLineSecurityControls.Add(tblSpice);

            lBaseLineSecurityControls.Add(cbFruit);
            lBaseLineSecurityControls.Add(cbVegetable);
            lBaseLineSecurityControls.Add(cbHerb);
            lBaseLineSecurityControls.Add(cbFood);
            lBaseLineSecurityControls.Add(cbNut);
            lBaseLineSecurityControls.Add(cbFlower);
            lBaseLineSecurityControls.Add(cbSpice);
            ApplySecurity(lBaseLineSecurityControls, SecurityMgr.Privilege.CompanySearchByCommodities, _oUser.IsLimitado);

            return true;
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

            List<ICustom_Caption> lSearchType = GetSearchTypeList(Resources.Global.CommoditySearchTypeAny, Resources.Global.CommoditySearchTypeAll);
            BindLookupValues(rblCommoditySearchType, lSearchType, CODE_SEARCH_TYPE_ANY);

            // NOTE: Investigate improvements here - currently implemented as radio button lists
            // allowing only 1 attribute out of the 4 to be selected for the search.
            #region Bind Attributes

            ICustom_Caption oAll = new Custom_Caption();
            oAll.Code = "0";
            oAll.Meaning = "All";

            // Bind Growing Method control
            DataTable dtAttributeList = GetAttributeList();

            List<ICustom_Caption> lGrowingMethodValues = new List<ICustom_Caption>();
            lGrowingMethodValues.Add(oAll);

            DataRow[] adrGrowingMethodList = dtAttributeList.Select("prat_Type = 'GM'");
            foreach (DataRow drRow in adrGrowingMethodList)
            {
                ICustom_Caption oCustom_Caption4 = new Custom_Caption();
                oCustom_Caption4.Code = drRow["prat_AttributeId"].ToString();
                oCustom_Caption4.Meaning = drRow["prat_Name"].ToString();
                lGrowingMethodValues.Add(oCustom_Caption4);
            }
            BindLookupValues(rblGrowingMethod, lGrowingMethodValues);

            // Bind Attribute - Country of Origin controls
            List<ICustom_Caption> lCountryOfOriginValues = new List<ICustom_Caption>();
            DataRow[] adrCountryOfOriginList = dtAttributeList.Select("prat_Type = 'CO'");
            lblCountryOfOrigin.Text = GetReferenceValue(REF_DATA_ATTRIBUTE_TYPE, "CO");

            foreach (DataRow drRow in adrCountryOfOriginList)
            {
                ICustom_Caption oCustom_Caption5 = new Custom_Caption();
                oCustom_Caption5.Code = drRow["prat_AttributeId"].ToString();
                oCustom_Caption5.Meaning = drRow["prat_Name"].ToString();
                lCountryOfOriginValues.Add(oCustom_Caption5);
            }
            BindLookupValues(rblCountryOfOrigin, lCountryOfOriginValues);

            // Bind Attribute - Size Group controls
            List<ICustom_Caption> lSizeGroupValues = new List<ICustom_Caption>();
            DataRow[] adrSizeGroupList = dtAttributeList.Select("prat_Type = 'SG'");
            lblSizeGroup.Text = GetReferenceValue(REF_DATA_ATTRIBUTE_TYPE, "SG");

            foreach (DataRow drRow in adrSizeGroupList)
            {
                ICustom_Caption oCustom_Caption6 = new Custom_Caption();
                oCustom_Caption6.Code = drRow["prat_AttributeId"].ToString();
                oCustom_Caption6.Meaning = drRow["prat_Name"].ToString();
                lSizeGroupValues.Add(oCustom_Caption6);
            }
            BindLookupValues(rblSizeGroup, lSizeGroupValues);

            // Bind Attribute - Style controls
            List<ICustom_Caption> lStyleValues = new List<ICustom_Caption>();
            DataRow[] adrStyleList = dtAttributeList.Select("prat_Type = 'ST'");
            lblStyle.Text = GetReferenceValue(REF_DATA_ATTRIBUTE_TYPE, "ST");

            foreach (DataRow drRow in adrStyleList)
            {
                ICustom_Caption oCustom_Caption7 = new Custom_Caption();
                oCustom_Caption7.Code = drRow["prat_AttributeId"].ToString();
                oCustom_Caption7.Meaning = drRow["prat_Name"].ToString();
                lStyleValues.Add(oCustom_Caption7);
            }
            BindLookupValues(rblStyle, lStyleValues);

            // Bind Attribute - Treatment controls
            List<ICustom_Caption> lTreatmentValues = new List<ICustom_Caption>();
            DataRow[] adrTreatmentList = dtAttributeList.Select("prat_Type = 'TR'");
            lblTreatment.Text = GetReferenceValue(REF_DATA_ATTRIBUTE_TYPE, "TR");

            foreach (DataRow drRow in adrTreatmentList)
            {
                ICustom_Caption oCustom_Caption8 = new Custom_Caption();
                oCustom_Caption8.Code = drRow["prat_AttributeId"].ToString();
                oCustom_Caption8.Meaning = drRow["prat_Name"].ToString();
                lTreatmentValues.Add(oCustom_Caption8);
            }
            BindLookupValues(rblTreatment, lTreatmentValues);
            #endregion

            // Bind Commodities checkbox list
            // NOTE: Done in page OnInit to correctly process viewstate
        }

        /// <summary>
        /// Populates the form controls based on the current 
        /// company search criteria object
        /// </summary>
        protected void PopulateForm()
        {
            // Set Commodity Criteria Information

            // Industry Type 
            SetListDefaultValue(rblIndustryType, _oCompanySearchCriteria.IndustryType);

            // Commodity Search Type
            if (!string.IsNullOrEmpty(_oCompanySearchCriteria.CommoditySearchType))
            {
                SetListDefaultValue(rblCommoditySearchType, _oCompanySearchCriteria.CommoditySearchType);
            }

            // Growing Method
            SetListDefaultValue(rblGrowingMethod, _oCompanySearchCriteria.CommodityGMAttributeID);

            if (_oCompanySearchCriteria.IncludeLocalSource == "LSO")
            {
                foreach (ListItem listItem in rblGrowingMethod.Items)
                {
                    if (listItem.Value == "24")
                    {
                        listItem.Enabled = false;
                        listItem.Selected = false;
                    }
                }

                rblCountryOfOrigin.Enabled = false;
                rblSizeGroup.Enabled = false;
                rblStyle.Enabled = false;
                rblTreatment.Enabled = false;
            }

            // Attributes
            if (_oCompanySearchCriteria.CommodityAttributeID == 0)
            {
                rbAttributeAll.Checked = true;
            }
            else
            {
                SetListDefaultValue(rblCountryOfOrigin, _oCompanySearchCriteria.CommodityAttributeID);
                SetListDefaultValue(rblSizeGroup, _oCompanySearchCriteria.CommodityAttributeID);
                SetListDefaultValue(rblStyle, _oCompanySearchCriteria.CommodityAttributeID);
                SetListDefaultValue(rblTreatment, _oCompanySearchCriteria.CommodityAttributeID);
            }

            // Commodities
            string[] aszCommodities = UIUtils.GetString(_oCompanySearchCriteria.CommodityIDs).Split(CompanySearchBase.achDelimiter);

            SetTableValues(cbFruit, "37", aszCommodities, tblFruit); 
            SetTableValues(cbVegetable, "291", aszCommodities, tblVegetable);
            SetTableValues(cbHerb, "248", aszCommodities, tblHerb);
            SetTableValues(cbFlower, "1", aszCommodities, tblFood);
            SetTableValues(cbFood, "16", aszCommodities, tblFlower);
            SetTableValues(cbNut, "271", aszCommodities, tblNut);
            SetTableValues(cbSpice, "287", aszCommodities, tblSpice);

            cbFruit.Attributes.Add("onclick", string.Format("toggleTable('{0}', '{1}');", cbFruit.ClientID, tblFruit.ClientID));
            cbVegetable.Attributes.Add("onclick", string.Format("toggleTable('{0}', '{1}');", cbVegetable.ClientID, tblVegetable.ClientID));
            cbHerb.Attributes.Add("onclick", string.Format("toggleTable('{0}', '{1}');", cbHerb.ClientID, tblHerb.ClientID));
            cbFlower.Attributes.Add("onclick", string.Format("toggleTable('{0}', '{1}');", cbFlower.ClientID, tblFood.ClientID));
            cbFood.Attributes.Add("onclick", string.Format("toggleTable('{0}', '{1}');", cbFood.ClientID, tblFlower.ClientID));
            cbNut.Attributes.Add("onclick", string.Format("toggleTable('{0}', '{1}');", cbNut.ClientID, tblNut.ClientID));
            cbSpice.Attributes.Add("onclick", string.Format("toggleTable('{0}', '{1}');", cbSpice.ClientID, tblSpice.ClientID));

            aceCommodity.ContextKey = MaxLevel.ToString();
        }

        protected void PopulateCheckboxValues()
        {
            cbFruit.InputAttributes.Add("value", "37");
            cbVegetable.InputAttributes.Add("value", "291");
            cbHerb.InputAttributes.Add("value", "248");
            cbFlower.InputAttributes.Add("value", "1");
            cbFood.InputAttributes.Add("value", "16");
            cbNut.InputAttributes.Add("value", "271");
            cbSpice.InputAttributes.Add("value", "287");
        }


        /// <summary>
        /// Used to show/hide form elements based on the current page
        /// settings
        /// </summary>
        protected void SetVisibility()
        {
            // If the Produce industry type is not selected, do not display the
            // commodities and discard any selected criteria.
            if (rblIndustryType.SelectedValue != GeneralDataMgr.INDUSTRY_TYPE_PRODUCE)
            {
                pnlExpandedContents.Visible = false;
                pnlCommodityList.Visible = false;
                _oCompanySearchCriteria.CommodityIDs = "";
                _oCompanySearchCriteria.CommodityGMAttributeID = 0;
                _oCompanySearchCriteria.CommodityAttributeID = 0;
                _oCompanySearchCriteria.ClassificationSearchType = "";
            }
            else
            {
                pnlExpandedContents.Visible = true;
                pnlCommodityList.Visible = true;
            }

            ApplySecurity(pnlIndustryType, SecurityMgr.Privilege.CompanySearchByIndustry);

            if (HasPrivilege_ITA_Always_True(SecurityMgr.Privilege.CompanySearchByCommodities))
                btnSearch.Enabled = true;
            else
                btnSearch.Enabled = false;
        }

        /// <summary>
        /// Collects and stores the search criteria on the users current company search
        /// criteria object 
        /// </summary>
        protected override void StoreCriteria()
        {
            // Save Company Commodity Search Criteria

            // Industry Type
            if (_oUser.prwu_IndustryType != GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                _oCompanySearchCriteria.IndustryType = rblIndustryType.SelectedValue;
            }

            // Commodity Search Type
            _oCompanySearchCriteria.CommoditySearchType = rblCommoditySearchType.SelectedValue;

            _oCompanySearchCriteria.CommodityGMAttributeID = 0;
            _oCompanySearchCriteria.CommodityAttributeID = 0;

            // Growing Method
            if (!(rblGrowingMethod.SelectedIndex < 0))
                _oCompanySearchCriteria.CommodityGMAttributeID = Convert.ToInt32(rblGrowingMethod.SelectedValue);

            // Attribute 
            if (!(rblCountryOfOrigin.SelectedIndex < 0))
                _oCompanySearchCriteria.CommodityAttributeID = Convert.ToInt32(rblCountryOfOrigin.SelectedValue);
            else
            {
                if (!(rblSizeGroup.SelectedIndex < 0))
                    _oCompanySearchCriteria.CommodityAttributeID = Convert.ToInt32(rblSizeGroup.SelectedValue);
                else
                {
                    if (!(rblStyle.SelectedIndex < 0))
                        _oCompanySearchCriteria.CommodityAttributeID = Convert.ToInt32(rblStyle.SelectedValue);
                    else
                    {
                        if (!(rblTreatment.SelectedIndex < 0))
                            _oCompanySearchCriteria.CommodityAttributeID = Convert.ToInt32(rblTreatment.SelectedValue);
                    }
                }
            }

            // Commodities
            StringBuilder selectedCommodities = new StringBuilder();
            AddCommodityValues(cbFruit, "37", selectedCommodities, tblFruit);
            AddCommodityValues(cbVegetable, "291", selectedCommodities, tblVegetable);
            AddCommodityValues(cbFlower, "1", selectedCommodities, tblFlower);
            AddCommodityValues(cbHerb, "248", selectedCommodities, tblHerb);
            AddCommodityValues(cbFood, "16", selectedCommodities, tblFood);
            AddCommodityValues(cbNut, "271", selectedCommodities, tblNut);
            AddCommodityValues(cbSpice, "287", selectedCommodities, tblSpice);

            _oCompanySearchCriteria.CommodityIDs = selectedCommodities.ToString();

            if (!Page.IsPostBack)
            {
                //SetToggle(tblFruit, hidFruit);  //Fruit always visible initially
                //SetToggle(tblVegetable, hidVegetable); //Vegetable always visible initially
                SetToggle(tblHerb, hidHerb); //SetToggle(tblHerb, "displayHerb");
                SetToggle(tblFlower, hidFlower); //SetToggle(tblFlower, "displayFlower");
                SetToggle(tblFood, hidFood); //SetToggle(tblFood, "displayFood");
                SetToggle(tblNut, hidNut); //SetToggle(tblNut, "displayNut");
                SetToggle(tblSpice, hidSpice); //SetToggle(tblSpice, "displaySpice");
            }
        }

        private void AddCommodityValues(CheckBox checkbox, string id, StringBuilder selectedCommodities, CheckBoxList controls)
        {
            if (checkbox.Checked)
            {
                AddDelimitedValue(selectedCommodities, id);
            }
            else
            {
                AddDelimitedValue(selectedCommodities, GetTableValues(controls));
            }
        }

        /// <summary>
        /// If Commodity table has values, set hidden value to true, else false
        /// For initial display on screen
        /// </summary>
        /// <param name="table"></param>
        /// <param name="oHid"></param>
        private void SetToggle(CheckBoxList table, HiddenField oHid)
        {
            if (!String.IsNullOrEmpty(GetTableValues(table)))
                oHid.Value = "true";
            else
                oHid.Value = "false";
        }

        /// <summary>
        /// Clears and stores the search criteria on the users current company search
        /// criteria object 
        /// </summary>
        protected override void ClearCriteria()
        {
            // Clear the corresponding Company Search Criteria object and 
            // reload the page

            // Commodity Search Type
            rblCommoditySearchType.SelectedIndex = -1;

            // Growing Method
            rblGrowingMethod.SelectedIndex = -1;

            // Attributes
            rblCountryOfOrigin.SelectedIndex = -1;
            rblSizeGroup.SelectedIndex = -1;
            rblStyle.SelectedIndex = -1;
            rblTreatment.SelectedIndex = -1;

            // Commodities
            ClearTableValues(tblFruit);
            ClearTableValues(tblVegetable);
            ClearTableValues(tblHerb);
            ClearTableValues(tblFood);
            ClearTableValues(tblFlower);
            ClearTableValues(tblNut);
            ClearTableValues(tblSpice);
            _szRedirectURL = PageConstants.COMPANY_SEARCH_COMMODITY;

            cbFruit.Checked = false;
            cbVegetable.Checked = false;
            cbFlower.Checked = false;
            cbHerb.Checked = false;
            cbFood.Checked = false;
            cbNut.Checked = false;
            cbSpice.Checked = false;
        }

        private void BuildCommoditiesTables()
        {
            // Retrieve Commodities
            DataTable dtCommodities = GetCommodityList();

            BuildCommodityTable(37, tblFruit, dtCommodities);
            BuildCommodityTable(291, tblVegetable, dtCommodities);
            BuildCommodityTable(248, tblHerb, dtCommodities);
            BuildCommodityTable(1, tblFlower, dtCommodities);
            BuildCommodityTable(16, tblFood, dtCommodities);
            BuildCommodityTable(271, tblNut, dtCommodities);
            BuildCommodityTable(287, tblSpice, dtCommodities);
        }

        private void BuildCommodityTable(int rootCommodityID, CheckBoxList commodityTable, DataTable dtCommodities)
        {
            DataView commodityData = new DataView(dtCommodities);
            commodityData.RowFilter = "prcm_RootParentID=" + rootCommodityID.ToString() + " AND prcm_Level <= " + MaxLevel.ToString();
            commodityData.Sort = "prcm_FullName";

            commodityTable.DataSource = commodityData;
            commodityTable.DataTextField = "prcm_FullName";
            commodityTable.DataValueField = "prcm_CommodityId";
            commodityTable.DataBind();
        }

        private bool SetTableValues(CheckBox control, string id, string[] values, ListControl oList)
        {
            bool hasSelection = false;
            foreach (string value in values)
            {
                if (id == value)
                {
                    control.Checked = true;
                    return true;
                }

                ListItem item = oList.Items.FindByValue(value);
                if (item != null)
                {
                    item.Selected = true;
                    hasSelection = true;
                }
            }

            return hasSelection;
        }

        protected string GetTableValues(CheckBoxList commodityTable)
        {
            StringBuilder sbValueList = new StringBuilder();
            foreach (ListItem item in commodityTable.Items)
            {
                if (item.Selected)
                {
                    AddDelimitedValue(sbValueList, item.Value);
                }
            }
            return sbValueList.ToString();
        }

        protected void ClearTableValues(CheckBoxList commodityTable)
        {
            foreach (ListItem item in commodityTable.Items)
            {
                item.Selected = false;
            }
        }

        private string GetRedirectUrl(string commodityExpanded)
        {
            return PageConstants.COMPANY_SEARCH_COMMODITY + "?CommodityExpanded=" + commodityExpanded + "&SearchID=" + _iSearchID.ToString();
        }

        /// <summary>
        /// Process the selection of the country of Origin attribute.  Deselect any other
        /// attribute values that may have been selected, store criteria and refresh page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void rblCountryOfOrigin_SelectedIndexChanged(object sender, EventArgs e)
        {
            // Country of Origin has been selected so delete any other attribute selections
            rblSizeGroup.SelectedIndex = -1;
            rblStyle.SelectedIndex = -1;
            rblTreatment.SelectedIndex = -1;

            // Store search criteria and refresh page
            StoreCriteria();
            Response.Redirect(GetRedirectUrl(PageView));
        }

        /// <summary>
        /// Process the selection of the Size Group attribute.  Deselect any other
        /// attribute values that may have been selected, store criteria and refresh page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void rblAttributeAll_OnChange(object sender, EventArgs e)
        {
            // Size Group has been selected.  Remove any other attribute selections
            rblCountryOfOrigin.SelectedIndex = -1;
            rblStyle.SelectedIndex = -1;
            rblTreatment.SelectedIndex = -1;
            rblSizeGroup.SelectedIndex = -1;

            // Store search criteria and refresh page
            StoreCriteria();
            Response.Redirect(GetRedirectUrl(PageView));
        }

        /// <summary>
        /// Process the selection of the Size Group attribute.  Deselect any other
        /// attribute values that may have been selected, store criteria and refresh page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void rblSizeGroup_SelectedIndexChanged(object sender, EventArgs e)
        {
            // Size Group has been selected.  Remove any other attribute selections
            rblCountryOfOrigin.SelectedIndex = -1;
            rblStyle.SelectedIndex = -1;
            rblTreatment.SelectedIndex = -1;

            // Store search criteria and refresh page
            StoreCriteria();
            Response.Redirect(GetRedirectUrl(PageView));
        }

        /// <summary>
        /// Process the selection of the Style attribute.  Deselect any other
        /// attribute values that may have been selected, store criteria and refresh page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void rblStyle_SelectedIndexChanged(object sender, EventArgs e)
        {
            // Style has been selected.  Remove any other attribute selections
            rblCountryOfOrigin.SelectedIndex = -1;
            rblSizeGroup.SelectedIndex = -1;
            rblTreatment.SelectedIndex = -1;

            // Store search criteria and refresh page
            StoreCriteria();
            Response.Redirect(GetRedirectUrl(PageView));
        }

        /// <summary>
        /// Process the selection of the Treatment attribute.  Deselect any other
        /// attribute values that may have been selected, store criteria and refresh page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void rblTreatment_SelectedIndexChanged(object sender, EventArgs e)
        {
            // Treatment has been selected.  Remove any other attribute selections
            rblCountryOfOrigin.SelectedIndex = -1;
            rblSizeGroup.SelectedIndex = -1;
            rblStyle.SelectedIndex = -1;

            // Store search criteria and refresh page
            StoreCriteria();
            Response.Redirect(GetRedirectUrl(PageView));
        }

        /// <summary>
        /// Process the selected index changed event for the industry type radio button list.
        /// If the produce industry is no longer selected, the previously selected commodity criteria should
        /// be discarded.  Store updated criteria and refresh page to update the search criteria
        /// user control.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void rblIndustryType_SelectedIndexChanged(object sender, EventArgs e)
        {
            // If the user selects a new industy type, discard the previously selected
            // classification criteria
            if (rblIndustryType.SelectedValue != GeneralDataMgr.INDUSTRY_TYPE_PRODUCE)
            {
                ClearTableValues(tblFruit);
                ClearTableValues(tblVegetable);
                ClearTableValues(tblHerb);
                ClearTableValues(tblFood);
                ClearTableValues(tblFlower);
                ClearTableValues(tblNut);
                ClearTableValues(tblSpice);
                _oCompanySearchCriteria.CommodityIDs = "";

                // Store search criteria and refresh page
                StoreCriteria();
                Response.Redirect(PageConstants.COMPANY_SEARCH_COMMODITY + "?CommodityExpanded=" + PageView);
            }
        }

        /// <summary>
        /// The method will scan through the selected search criteria to determine if the user
        /// has selected elements on the expanded criteria view.  This will be used to determine
        /// the toggle state for loaded searches.
        /// </summary>
        protected void CheckForExpandedCriteria()
        {
            // Check if the user has selected on of the other attributes
            if (_oCompanySearchCriteria.CommodityAttributeID > 0)
            {
                PageView = PAGE_VIEW_EXPANDED;
            }

            // Check if one of the selected commodities is above level 3
            if (!String.IsNullOrEmpty(_oCompanySearchCriteria.CommodityIDs))
            {
                string[] aszCommodities = _oCompanySearchCriteria.CommodityIDs.Split(CompanySearchBase.achDelimiter);
                DataTable dtCommodityList = GetCommodityList();

                // Retrieve commodity levels
                string szCommodityLevels;
                szCommodityLevels = TranslateListValues(aszCommodities, dtCommodityList, "prcm_CommodityId", "prcm_Level");

                string[] aszCommodityLevels = szCommodityLevels.Split(CompanySearchBase.achDelimiter);
                foreach (string szCommodityLevel in aszCommodityLevels)
                {
                    if (!String.IsNullOrEmpty(szCommodityLevel))
                    {
                        if (Convert.ToInt32(szCommodityLevel) > 3)
                        {
                            PageView = PAGE_VIEW_EXPANDED;
                            break;
                        }
                    }
                }
            }

            // Check if the search type is "All" or "Only"
            if (_oCompanySearchCriteria.CommoditySearchType == CODE_SEARCH_TYPE_ALL ||
                _oCompanySearchCriteria.CommoditySearchType == CODE_SEARCH_TYPE_ONLY)
            {
                PageView = PAGE_VIEW_EXPANDED;
            }
        }

    }
}
