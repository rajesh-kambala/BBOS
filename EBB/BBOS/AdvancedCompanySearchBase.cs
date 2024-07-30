/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2023-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: AdvancedCompanySearchBase
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/

using PRCo.EBB.BusinessObjects;
using PRCo.EBB.Util;
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using TSI.Arch;
using TSI.BusinessObjects;

namespace PRCo.BBOS.UI.Web
{
    public class AdvancedCompanySearchBase : SearchBase
    {
        public const string SELECTED_MENU_CLASS_HOME = "home-dropdown";
        public const string SELECTED_MENU_CLASS_ADVANCED_SEARCH = "advanced-search-dropdown";
        public const string SELECTED_MENU_CLASS_TOOLS = "tools-dropdown";
        public const string SELECTED_MENU_CLASS_LEARNING = "learning-dropdown";

        protected const string CONTAINER_NAME = "contentMain";
        protected const string PREFIX_INTEGRITYRATING = "IR";
        protected const string PREFIX_PAYDESCRIPTION = "PD";
        protected const string PREFIX_CREDITWORTHRATING = "CWR";
        protected const string PREFIX_CREDITWORTHRATING_LUMBER = "CWRL";
        protected const string PREFIX_VOLUME = "VOL";
        protected const string PREFIX_LUMBER_VOLUME = "LMBR_VOL";
        protected const string PREFIX_LUMBER_FT_EMPLOYEE = "LMBR_FTE";
        protected const string PREFIX_PAYINDICATOR = "PI";
        protected const string PREFIX_CLASS = "CLASS";
        protected const string PREFIX_TOTAL_ACRES = "TOTAL_ACRES";
        protected const string PREFIX_NUM_RETAIL = "NUM_RETAIL";
        protected const string PREFIX_NUM_REST = "NUM_REST";

        public const int SEARCH_PANEL_INDUSTRY = 0;
        public const int SEARCH_PANEL_COMPANY_DETAILS = 1;
        public const int SEARCH_PANEL_RATINGS = 2;
        public const int SEARCH_PANEL_LOCATION = 3;
        public const int SEARCH_PANEL_COMMODITIES = 4;
        public const int SEARCH_PANEL_CLASSIFICATIONS = 5;
        public const int SEARCH_PANEL_LICENSES_CERTS = 6;
        public const int SEARCH_PANEL_LOCAL_SOURCE = 7;
        public const int SEARCH_PANEL_CUSTOM = 8;
        public const int SEARCH_PANEL_INTERNAL = 9;

        protected const string REF_DATA_NUMBER_OF_STORES = "prc2_StoreCount";
        protected const string CLASSIFICATION_ID_RESTAURANT = "320";
        protected const string CLASSIFICATION_ID_RETAIL = "330";
        protected const string CLASSIFICATION_ID_RETAIL_YARD_DEALER = "2190";

        protected CompanySearchCriteria _oCompanySearchCriteria;
        protected CompanySearchBase _oCompanySearchBase;

        List<string> _lSelectedIDs = null;

        protected CompanySearchBase oCompanySearchBase
        {
            get {
                if (_oCompanySearchBase == null)
                    _oCompanySearchBase = new CompanySearchBase();

                return _oCompanySearchBase; 
            }
        }

        protected bool _bReturnNullIfNoCriteriaFound = false;

        const string CACHE_COUNTRIES = "AdvCompanySearch_Country";
        const string CACHE_STATES = "AdvCompanySearch_States";

        const string SQL_GET_COUNTRIES = "SELECT prcn_CountryID, prcn_Country FROM PRCountry WITH (NOLOCK) WHERE prcn_CountryID > 0 ORDER BY prcn_Country";
        public string getCountries()
        {
            string szCountries = (string)HttpRuntime.Cache[CACHE_COUNTRIES];
            if (string.IsNullOrEmpty(szCountries))
            {

                StringBuilder c = new StringBuilder();
                using (IDataReader oReader = PageControlBaseCommon.GetDBAccess().ExecuteReader(SQL_GET_COUNTRIES, CommandBehavior.CloseConnection))
                {
                    while (oReader.Read())
                    {
                        c.Append("{\"prcn_CountryId\": \"" + oReader[0] + "\", \"prcn_Country\": \"" + oReader[1] + "\" },");
                    }
                }

                szCountries = c.ToString();
                HttpRuntime.Cache.Insert(CACHE_COUNTRIES, szCountries);
            }

            return szCountries;
        }

        const string SQL_GET_STATES = "SELECT prst_StateId, prst_CountryId, prst_State, prst_Abbreviation FROM PRState ORDER BY prst_CountryId, prst_State";
        public string getStates()
        {
            string szStates = (string)HttpRuntime.Cache[CACHE_STATES];
            if (string.IsNullOrEmpty(szStates))
            {

                StringBuilder c = new StringBuilder();
                using (IDataReader oReader = PageControlBaseCommon.GetDBAccess().ExecuteReader(SQL_GET_STATES, CommandBehavior.CloseConnection))
                {
                    while (oReader.Read())
                    {
                        c.Append("{\"prst_StateId\": \"" + oReader[0] + "\", \"prst_CountryId\": \"" + oReader[1] + "\", \"prst_State\": \"" + oReader[2] + "\", \"prst_Abbreviation\": \"" + oReader[3] + "\" },");
                    }
                }

                szStates = c.ToString();
                HttpRuntime.Cache.Insert(CACHE_STATES, szStates);
            }

            return szStates;
        }

        const string SQL_GET_TERMINAL_MARKETS = "SELECT prst_StateId, prst_CountryId, prst_State, prst_Abbreviation FROM PRState ORDER BY prst_CountryId, prst_State";
        public string getTerminalMarkets()
        {
            // Bind Terminal Market control
            DataTable dtTerminalMarketList = GetTerminalMarketList();

            DataRow[] drTerminalMarkets = null;
            drTerminalMarkets = dtTerminalMarketList.Select();

            StringBuilder c = new StringBuilder();
            foreach (DataRow drRow in drTerminalMarkets)
            {
                c.Append("{\"prtm_TerminalMarketId\": \"" + drRow["prtm_TerminalMarketId"].ToString() + "\", \"prtm_FullMarketName\": \"" + drRow["prtm_FullMarketName"].ToString() + "\", \"prtm_City\": \"" + drRow["prtm_City"].ToString() + "\", \"prtm_State\": \"" + drRow["prtm_State"].ToString() + "\" },");
            }

            return c.ToString();
        }
        
        public string getCommodities()
        {
            // Bind Commodities control
            DataTable dtCommodities = GetCommodityList();
            DataRow[] drCommodities = null;
            drCommodities = dtCommodities.Select();

            StringBuilder c = new StringBuilder();
            foreach (DataRow drRow in drCommodities)
            {
                c.Append("{\"prcm_CommodityId\": \"" + drRow["prcm_CommodityId"].ToString() + "\", \"prcm_ParentId\": \"" + drRow["prcm_ParentId"].ToString() + "\", \"prcm_Level\": \"" + drRow["prcm_Level"].ToString() + "\", \"prcm_FullName\": \"" + drRow["prcm_FullName"].ToString() + "\" },");
            }

            return c.ToString();
        }

        public string getAttributesControl()
        {
            DataTable dtAttributeList = oCompanySearchBase.GetAttributeList();
            StringBuilder c = new StringBuilder();

            c.Append($"<select id='attributes' aria-label='attributes' class='postback'>");
            c.Append($"<option selected='' value=''>{Resources.Global.All}</option>");
            
            var szOptGroup = GetReferenceValue(CompanySearchCommodity.REF_DATA_ATTRIBUTE_TYPE, "CO");
            c.Append($"<optgroup label='{szOptGroup}'>");
            DataRow[] adrCountryOfOriginList = dtAttributeList.Select("prat_Type = 'CO'");
            foreach (DataRow drRow in adrCountryOfOriginList)
            {
                c.Append($"<option value='{drRow["prat_AttributeId"].ToString()}'>{drRow["prat_Name"].ToString()}</option>");
            }
            c.Append("</optgroup>");

            szOptGroup = GetReferenceValue(CompanySearchCommodity.REF_DATA_ATTRIBUTE_TYPE, "SG");
            c.Append($"<optgroup label='{szOptGroup}'>");
            DataRow[] adrSizeGroupList = dtAttributeList.Select("prat_Type = 'SG'");
            foreach (DataRow drRow in adrSizeGroupList)
            {
                c.Append($"<option value='{drRow["prat_AttributeId"].ToString()}'>{drRow["prat_Name"].ToString()}</option>");
            }
            c.Append("</optgroup>");

            szOptGroup = GetReferenceValue(CompanySearchCommodity.REF_DATA_ATTRIBUTE_TYPE, "ST");
            c.Append($"<optgroup label='{szOptGroup}'>");
            DataRow[] adrStyleList = dtAttributeList.Select("prat_Type = 'ST'");
            foreach (DataRow drRow in adrStyleList)
            {
                c.Append($"<option value='{drRow["prat_AttributeId"].ToString()}'>{drRow["prat_Name"].ToString()}</option>");
            }
            c.Append("</optgroup>");

            szOptGroup = GetReferenceValue(CompanySearchCommodity.REF_DATA_ATTRIBUTE_TYPE, "TR");
            c.Append($"<optgroup label='{szOptGroup}'>");
            DataRow[] adrTreatmentList = dtAttributeList.Select("prat_Type = 'TR'");
            foreach (DataRow drRow in adrTreatmentList)
            {
                c.Append($"<option value='{drRow["prat_AttributeId"].ToString()}'>{drRow["prat_Name"].ToString()}</option>");
            }
            c.Append("</optgroup>");
            
            c.Append($"</select>");
            return c.ToString();
        }

        /// <summary>
        /// Provides company search base page_load functionality to retrieve 
        /// or create the company search criteria object required on each of
        /// the company search pages.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            EnableFormValidation();

            if (!string.IsNullOrEmpty(Request["SearchID"]))
                Int32.TryParse(GetRequestParameter("SearchID"), out _iSearchID);
            else
                _iSearchID = 0;

            if (!string.IsNullOrEmpty(Request["ns"]))
            {
                Session["oWebUserSearchCriteria"] = null;
            }

            RetrieveObject();

            if (!IsPostBack)
            {
                // Defect 7372 - USA default on initial page_load
                if(string.IsNullOrEmpty(_oCompanySearchCriteria.ListingCountryIDs))
                    _oCompanySearchCriteria.ListingCountryIDs = "1";
            }

            // Determine if are you sure confirmation messages should be displayed
            if (_bIsDirty)
                ClientScript.RegisterClientScriptBlock(Page.GetType(), "script1", "var bDisplayConfirmations = true;", true);
            else
                ClientScript.RegisterClientScriptBlock(Page.GetType(), "script1", "var bDisplayConfirmations = false;", true);

            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_FUNCTIONS2_FILE));

            //Add the various script calls for the new UI
            Page.ClientScript.RegisterStartupScript(this.GetType(), "addCountries", $"var countries = [ {getCountries()} ];\r\n\r\n ", true); //bottom of page
            Page.ClientScript.RegisterStartupScript(this.GetType(), "addStates", $"var states = [ {getStates()} ]; \r\n\r\n ", true); //bottom of page

            Page.ClientScript.RegisterStartupScript(this.GetType(), "addTerminalMarkets", $"var terminalMarkets = [ {getTerminalMarkets()} ]; \r\n\r\n ", true);  //bottom of page
            Page.ClientScript.RegisterStartupScript(this.GetType(), "addCommodities", $"var commodities = [ {getCommodities()} ]; \r\n\r\n", true);  //bottom of page
        }

        /// <summary>
        /// Handles the Search on click event for the Advanced Company Search page
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            StoreCriteria();
            Response.Redirect(PageConstants.Format(PageConstants.COMPANY_SEARCH_RESULTS, _iSearchID));
        }

        /// <summary>
        /// Restores the updated company search criteria object with
        /// the corresponding values cleared.  Subpages should handle clearing 
        /// corresponding form values and updating company search criteria 
        /// object accordingly
        /// </summary>
        protected virtual void ClearCriteria()
        {
            // Store updated company search criteria object
            StoreCriteria();
        }

        /// <summary>
        /// Handles the Clear All Criteria on click event for each of the company
        /// search pages
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnClearAllCriteria_Click(object sender, EventArgs e)
        {
            // Clear this search criteria object
            Session["oWebUserSearchCriteria"] = null;

            if (Request.Url.ToString().ToLower().Contains(PageConstants.LIMITADO_SEARCH.ToLower()))
                Response.Redirect(PageConstants.LIMITADO_SEARCH);
            else
                Response.Redirect(PageConstants.ADVANCED_COMPANY_SEARCH);
        }

        /// <summary>
        /// Stores the current advanced company search criteria object as part of 
        /// the current users web user search criteria object
        /// </summary>
        protected virtual void StoreCriteria()
        {
            IPRWebUserSearchCriteria oWebUserSearchCriteria = GetSearchCritieria(_iSearchID, PRWebUserSearchCriteria.SEARCH_TYPE_COMPANY);
            oWebUserSearchCriteria.Criteria = _oCompanySearchCriteria;
        }

        /// <summary>
        /// Retrieves the current company search criteria object from
        /// the current users web user search criteria object
        /// </summary>
        protected void RetrieveObject()
        {
            if (_oCompanySearchCriteria == null)
            {
                IPRWebUserSearchCriteria oWebUserSearchCriteria = null;

                // Check for an existing Company Search Criteria Object
                try
                {
                    oWebUserSearchCriteria = GetSearchCritieria(_iSearchID, PRWebUserSearchCriteria.SEARCH_TYPE_COMPANY, _bReturnNullIfNoCriteriaFound);
                }
                catch (ObjectNotFoundException)
                {
                    // If we cannot find a search object, just take the 
                    // user to the home page.
                    Response.Redirect(PageConstants.BBOS_HOME, true);
                    return;
                }

                if (oWebUserSearchCriteria == null)
                {
                    return;
                }

                _oCompanySearchCriteria = (CompanySearchCriteria)oWebUserSearchCriteria.Criteria;

                // We're going to handle the data conversion of this criterion
                // one search at a time.
                if (_oCompanySearchCriteria.ListingStatus == "L,H")
                {
                    _oCompanySearchCriteria.ListingStatus = "L,H,LUV";
                }

                // If this is not the company search results page,
                // then be sure to reset the IsQuickSearch flag.
                if (this is CompanySearchResults)
                {
                    // Nothing to do here
                }
                else
                {
                    _oCompanySearchCriteria.IsQuickSearch = false;
                }

                if (string.IsNullOrEmpty(_oCompanySearchCriteria.IndustryType))
                {
                    if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                    {
                        _oCompanySearchCriteria.IndustryType = GeneralDataMgr.INDUSTRY_TYPE_LUMBER;
                    }
                    else
                    {
                        _oCompanySearchCriteria.IndustryType = GeneralDataMgr.INDUSTRY_TYPE_PRODUCE;
                    }
                }

                if (string.IsNullOrEmpty(_oCompanySearchCriteria.ListingStatus))
                {
                    _oCompanySearchCriteria.ListingStatus = "L,H,LUV";
                }

                _bIsDirty = _oCompanySearchCriteria.IsDirty;

                bool bAuthorizedToView = true;

                // Verify user is authorized to view this search
                if (oWebUserSearchCriteria.prsc_IsPrivate)
                {
                    // Private Search, user must be the search owner to view
                    if (oWebUserSearchCriteria.prsc_WebUserID == _oUser.prwu_WebUserID)
                    {
                        bAuthorizedToView = true;
                    }
                }
                else
                {
                    // Public search, search must belong to the current user's enterprise                
                    if (oWebUserSearchCriteria.prsc_HQID == _oUser.prwu_HQID)
                    {
                        bAuthorizedToView = true;
                    }
                }

                if (!bAuthorizedToView)
                {
                    throw new AuthorizationException(Resources.Global.UnauthorizedForSearchMsg);
                }
            }
        }

        /// <summary>
        /// Builds a control div containing the button, checkbox control, and button controls, output something like:
        /// <span class="bbs-checkbox-input">
		///      <input id = "contentMain_CHK_IR_0" type="checkbox" name="ctl00$contentMain$CHK_IR_0" class="postback" data-gtm-form-interact-field-id="0">
		///      <label for="contentMain_CHK_IR_0">XXXX - Excellent</label>
	    /// </span>
        /// </summary>
        /// <param name="phRegion">Form Placeholder to place controls in</param>
        /// <param name="szControlGroupPrefix">Unique prefix to use for control group</param>
        /// <param name="updPanel"></param>
        protected void BuildControlTable(PlaceHolder phRegion, string szControlGroupPrefix, UpdatePanel updPanel)
        {
            IBusinessObjectSet osRefData = null;

            // Retrieve Reference Data
            switch (szControlGroupPrefix)
            {
                case PREFIX_INTEGRITYRATING:
                    osRefData = GetReferenceData("IntegrityRating2_Display");
                    break;
                case PREFIX_PAYDESCRIPTION:
                    osRefData = GetReferenceData("PayRating2");
                    break;
                case PREFIX_PAYINDICATOR:
                    osRefData = GetReferenceData("PayIndicator");
                    break;
                case PREFIX_CREDITWORTHRATING:
                    osRefData = GetReferenceData("CreditWorthRating2");
                    break;
                case PREFIX_CREDITWORTHRATING_LUMBER:
                    osRefData = GetReferenceData("CreditWorthRating2L");
                    break;
                case PREFIX_VOLUME:
                    osRefData = GetReferenceData("prcp_Volume");
                    break;
                case PREFIX_LUMBER_VOLUME:
                    osRefData = GetReferenceData("prcp_VolumeL");
                    break;
                case PREFIX_TOTAL_ACRES:
                    osRefData = GetReferenceData("prls_TotalAcres");
                    break;
                case PREFIX_LUMBER_FT_EMPLOYEE:
                    osRefData = GetReferenceData("NumEmployees");
                    break;
            }

            CheckBox oCheckbox;

            int iItemsAddedCount = 0;

            for (int i = 0; i < osRefData.Count; i++)
            {
                ICustom_Caption oCustomCaption = (ICustom_Caption)osRefData[i];

                HtmlGenericControl oDiv = new HtmlGenericControl();
                oDiv.Attributes["class"] = "bbs-checkbox-input";

                oCheckbox = new CheckBox();
                oCheckbox.ID = "CHK_" + szControlGroupPrefix + "_" + iItemsAddedCount.ToString();
                oCheckbox.Attributes.Add("Value", oCustomCaption.Code);
                oCheckbox.Text = oCustomCaption.Meaning;
                oCheckbox.InputAttributes.Add("class", "postback"); //this avoids outer <span> if we used CssClass https://stackoverflow.com/questions/997342/why-does-asp-net-radiobutton-and-checkbox-render-inside-a-span

                oDiv.Controls.Add(oCheckbox);

                iItemsAddedCount++;
                phRegion.Controls.Add(oDiv);
            }
        }

        public static List<ICustom_Caption> GetSearchTypeValues()
        {
            List<ICustom_Caption> lSearchTypeValues = new List<ICustom_Caption>();

            ICustom_Caption oCustom_Caption = new Custom_Caption();
            oCustom_Caption.Code = "=";
            oCustom_Caption.Meaning = Resources.Global.EqualTo;
            lSearchTypeValues.Add(oCustom_Caption);

            ICustom_Caption oCustom_Caption2 = new Custom_Caption();
            oCustom_Caption2.Code = ">";
            oCustom_Caption2.Meaning = Resources.Global.GreaterThan;
            lSearchTypeValues.Add(oCustom_Caption2);

            ICustom_Caption oCustom_Caption3 = new Custom_Caption();
            oCustom_Caption3.Code = "<";
            oCustom_Caption3.Meaning = Resources.Global.LessThan;
            lSearchTypeValues.Add(oCustom_Caption3);

            return lSearchTypeValues;
        }

        /// <summary>
        /// Handles the Save Search Criteria on click event for the advanced company search page
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnSaveSearch_Click(object sender, EventArgs e)
        {
            // Save the search criteria object 
            StoreCriteria();

            // Redirect the user to the Search Edit page
            Response.Redirect(PageConstants.Format(PageConstants.SEARCH_EDIT, _iSearchID, PRWebUserSearchCriteria.SEARCH_TYPE_COMPANY));
        }

        protected void BuildClassificationsTable(Panel oParentPanel, string szBookSection, int iChildColumns, bool bIncludeLevel1Check, bool bIncludeClassificationCount, UpdatePanel updPanel)
        {
            // Defect 4519  - show classification counts for ONLY BBSI logins
            if (!IsPRCoUser())
                bIncludeClassificationCount = false;

            // Retrieve Level 1 Classifications
            DataTable dtClassifications = oCompanySearchBase.GetClassificationList();
            DataRow[] adrLevel1ClassList = dtClassifications.Select("prcl_BookSection = " + szBookSection + " AND prcl_Level = 1", "prcl_DisplayOrder");

            HtmlInputCheckBox oCheckbox = new HtmlInputCheckBox(); 
            HtmlGenericControl oLabel;

            int iLevel1ColumnCount = 1;

            // Process each level 1 classification
            foreach (DataRow drRow in adrLevel1ClassList)
            {
                #region Create Level 1 Classification controls
                //HtmlGenericControl oDivPanelHeading = new HtmlGenericControl("div");
                //oDivPanelHeading.Attributes.Add("class", "panel-heading");
                //oDivPanelHeading.Attributes.Add("role", "tab");
                //oDivPanelHeading.Attributes.Add("id", "heading" + drRow["prcl_ClassificationID"].ToString());

                HtmlGenericControl oOuterDiv = new HtmlGenericControl("div");

                Panel oDivFlex = new Panel();
                oDivFlex.CssClass = "tw-flex tw-justify-between";
                Panel oDivCheckboxInput = new Panel();
                oDivCheckboxInput.CssClass = "bbs-checkbox-input";
                Panel oDivExpandCollapse = new Panel();
                oDivExpandCollapse.CssClass = "input-wrapper";

                string szPrclName = drRow["prcl_Name"].ToString().Replace(" ", "");  //strip spaces in case there are any (ex: Fruit)
                string szCheckBoxListName = "cboxes_" + szPrclName;

                // Create a checkbox control if requested, otherwise just create a label control for this level
                if (bIncludeLevel1Check)
                {
                    // Create a checkbox control for the level 1 classification
                    oCheckbox = new HtmlInputCheckBox();
                    oCheckbox.ID = "CHK_" + PREFIX_CLASS + drRow["prcl_ClassificationID"].ToString();

                    oCheckbox.Attributes.Add("class", "postback classification");
                    oCheckbox.Attributes.Add("Value", drRow["prcl_ClassificationID"].ToString());

                    string szOnChange = $"toggleAllCheckboxes(this.checked, '{szCheckBoxListName}');";
                    if (szCheckBoxListName.ToLower() == ("cboxes_producebuyer"))
                        szOnChange += "displayNumofRetail();";

                    oCheckbox.Attributes.Add("onchange", szOnChange);

                    oDivCheckboxInput.Controls.Add(oCheckbox);
                }

                // Create a label control to display the level 1 classification
                oLabel = new HtmlGenericControl();
                oLabel.TagName = "label";
                oLabel.ID = "LBL_" + PREFIX_CLASS + drRow["prcl_ClassificationID"].ToString();
                oLabel.Attributes["for"] = $"{CONTAINER_NAME}_{oCheckbox.ClientID}";
                oLabel.InnerText = drRow["prcl_Name"].ToString();
                oLabel.Attributes.Add("class", "strong");
                
                if (drRow["prcl_CompanyCount"].ToString().Length > 0)
                    oLabel.InnerText += GetClassificationCount((int)drRow["prcl_CompanyCount"], (int)drRow["prcl_CompanyCountIncludeLocalSource"], false);

                oDivCheckboxInput.Controls.Add(oLabel);

                //Input wrapper / Collapse / Expand
                oDivExpandCollapse.Attributes.Add("id", szPrclName);

                HiddenField oHidden = new HiddenField();
                oHidden.Value = "true";
                oHidden.ID = "hid" + szPrclName;
                oDivExpandCollapse.Controls.Add(oHidden);

                HtmlGenericControl oCheckboxesUL = new HtmlGenericControl("ul");
                oCheckboxesUL.Attributes.Add("class", "input-wrapper bbs-checkbox-input-group-col-2-small tw-hidden");
                oCheckboxesUL.ID = szCheckBoxListName;
                oCheckboxesUL.ClientIDMode = ClientIDMode.Static;

                string szHtml = $"<button type='button' class='bbsButton bbsButton-secondary small' onclick=\"toggleExpandCollapse(this, '{oCheckboxesUL.ClientID}')\"><span class='text-label'>Expand</span><span class='msicon notranslate'>expand_more</span></button>";
                LiteralControl litExpandCollapse = new LiteralControl(szHtml);
                oDivExpandCollapse.Controls.Add(litExpandCollapse);

                oDivFlex.Controls.Add(oDivCheckboxInput);
                oDivFlex.Controls.Add(oDivExpandCollapse);

                #endregion

                // Build Child Classifications on panel
                DataRow[] adrLevel2ClassList = dtClassifications.Select("prcl_ParentID = " + drRow["prcl_ClassificationID"].ToString(), "prcl_DisplayOrder");
                HtmlInputCheckBox oCheckbox2;

                // Process each child classification
                foreach (DataRow drRow2 in adrLevel2ClassList)
                {
                    // Create a LI tag for this classification
                    HtmlGenericControl oLI = new HtmlGenericControl("li");

                    oCheckbox2 = new HtmlInputCheckBox();
                    oCheckbox2.ID = "CHK_" + PREFIX_CLASS + drRow2["prcl_ClassificationID"].ToString();
                    oCheckbox2.Attributes.Add("class", "postback classification");
                    oCheckbox2.Attributes.Add("Value", drRow2["prcl_ClassificationID"].ToString());
                    oCheckbox2.ClientIDMode = ClientIDMode.Static;

                    if (bIncludeLevel1Check)
                    {
                        oCheckbox2.Attributes.Add("ParentID", oCheckbox.ID);
                    }

                    Label oCheckbox2_Label = new Label();
                    oCheckbox2_Label.AssociatedControlID = oCheckbox2.ClientID;
                    oCheckbox2_Label.ID = "lbl" + PREFIX_CLASS + drRow2["prcl_ClassificationID"].ToString();
                    oCheckbox2_Label.Text = drRow2["prcl_Name"].ToString();

                    if (drRow2["prcl_CompanyCount"].ToString().Length > 0)
                    {
                        oCheckbox2_Label.Text += GetClassificationCount((int)drRow2["prcl_CompanyCount"], (int)drRow2["prcl_CompanyCountIncludeLocalSource"], bIncludeClassificationCount);
                    }

                    oCheckbox2_Label.Text += "&nbsp;";
                    oCheckbox2_Label.CssClass = "smaller";

                    oCheckbox2.Attributes.Add("onchange", "processCheck(this);");

                    oLI.Controls.Add(oCheckbox2);
                    oLI.Controls.Add(oCheckbox2_Label);

                    if (oParentPanel.ID != "pnlSupplyClass")
                    {
                        HtmlGenericControl oInfoSpan = GetInfoSpan(drRow2); //Add info icon with prcl_Description next to checkbox text
                        oLI.Controls.Add(oInfoSpan);
                    }

                    oCheckboxesUL.Controls.Add(oLI);
                }

                // Add child classification table to page

                oOuterDiv.Controls.Add(oDivFlex);
                oOuterDiv.Controls.Add(oCheckboxesUL);

                iLevel1ColumnCount++;

                oParentPanel.Controls.Add(oOuterDiv);

                AddHR(oParentPanel);
            }
        }

        protected void BuildCheckboxTable(Panel oParentPanel, IBusinessObjectSet osData, UpdatePanel updPanel)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("<ul class='bbs-checkbox-input-group tw-grid tw-grid-cols-2 tw-gap-x-4'>");
            foreach(var x in osData)
            {
                sb.Append("li");

            }

                
        }

        private void AddHR(Panel oParentPanel)
        {
            HtmlGenericControl oDivSpacer = new HtmlGenericControl("hr");
            oParentPanel.Controls.Add(oDivSpacer);
        }

        /// <summary>
        /// Call back for when our checkbox is checked.  The sub-class should
        /// override this and handle.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        virtual protected void oCheckbox_CheckChanged(object sender, EventArgs e)
        {
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

        private static HtmlGenericControl GetInfoSpan(DataRow drRow)
        {
            HtmlGenericControl span = new HtmlGenericControl("button");
            span.Attributes["type"] = "button";
            span.InnerHtml = "help";
            span.Attributes["class"] = "msicon notranslate help";
            span.Attributes["data-bs-toggle"] = "tooltip";
            span.Attributes["data-bs-placement"] = "right";
            span.Attributes["data-bs-html"] = "true";
            span.Attributes["data-bs-title"] = drRow["prcl_Description"].ToString();

            return span;
        }

        public void setPanelVisibility_TW(Panel pnl, bool visible)
        {
            string szClass = pnl.CssClass;
            if (visible)
                szClass = szClass.Replace("tw-hidden", "");
            else
            {
                if (!szClass.Contains("tw-hidden"))
                    szClass += " tw-hidden";
            }

            pnl.CssClass = szClass;

        }

        public void setEnabled_TW(HtmlGenericControl ctl, bool enabled)
        {
            string szClass = ctl.Attributes["class"].ToString();
            if (enabled)
            {
                ctl.Attributes.Remove("disabled");
            }
            else
                ctl.Attributes["disabled"] = "disabled";
        }

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

                if (_oCompanySearchCriteria != null)
                {
                    if (!string.IsNullOrEmpty(_oCompanySearchCriteria.UserListIDs))
                    {
                        string[] aszIDs = _oCompanySearchCriteria.UserListIDs.Split(',');
                        _lSelectedIDs.AddRange(aszIDs);
                    }
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
    }
}