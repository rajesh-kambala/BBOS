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

 ClassName: CompanySearchBase
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
using TSI.BusinessObjects;
using TSI.Utils;
using TSI.Arch;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Base class for the company search pages.  This class provides
    /// the common functionality for the company search pages.
    /// 
    /// This class will be used to create the search submenu to be displayed 
    /// on several of the search pages, as well as process the onclick events for the menu 
    /// buttons, storing the criteria before redirecting the user to the requested page.
    /// 
    /// Each of the search button click events will be handled within this class including: Search,
    /// Clear This Criteria, Clear All Criteria, Save Seaarch Criteria, Load Search Criteria, and
    /// New Search.
    /// 
    /// Functions are provided to retrieve and store data lists used to create 
    /// several of the search page items including: Countries, States, Terminal Markets,
    /// Classifications, Commodities, and Rating data.
    /// 
    /// Helper functions are also available to get/set, clear, and disable checkbox controls 
    /// within tables. 
    /// </summary>
    public class CompanySearchBase : SearchBase
    {
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

        protected CompanySearchCriteria _oCompanySearchCriteria;

        protected bool _bReturnNullIfNoCriteriaFound = false;

        // Classification table contains localized column names
        private const string SQL_GET_CLASSIFICATIONS = "SELECT prcl_ClassificationID, CASE WHEN {0} IS NULL THEN prcl_Name ELSE {0} END AS prcl_Name, prcl_Level, " +
            "prcl_BookSection, prcl_ParentID, prcl_CompanyCount, prcl_CompanyCountIncludeLocalSource, prcl_DisplayOrder, " +
            "CASE WHEN {1} IS NULL THEN prcl_Description ELSE {1} END AS prcl_Description " +
            "FROM PRClassification WITH (NOLOCK) ";

        private const string SQL_GET_ATTRIBUTES = "SELECT prat_AttributeId, {0} AS prat_Name, prat_Type " +
            "FROM PRAttribute WITH (NOLOCK) ORDER BY prat_Name ";

        // PRSpecie table contains localized column names
        private const string SQL_GET_SPECIES = "SELECT prspc_SpecieID, prspc_Name, prspc_Level, " +
            "prspc_ParentID, prspc_CompanyCount, prspc_DisplayOrder " +
            "FROM PRSpecie WITH (NOLOCK) " +
            "ORDER BY prspc_DisplayOrder ";

        // PRServiceProvided table contains localized column names
        private const string SQL_GET_SERVICE_PROVIDED = "SELECT prserpr_ServiceProvidedID, prserpr_Name, prserpr_Level, prserpr_ParentID, prserpr_CompanyCount, prserpr_DisplayOrder " +
            "FROM PRServiceProvided WITH (NOLOCK) " +
            "ORDER BY prserpr_DisplayOrder ";

        // PRProductProvided table contains localized column names
        private const string SQL_GET_PRODUCT_PROVIDED = "SELECT prprpr_ProductProvidedID, prprpr_Name, prprpr_Level, " +
            "prprpr_ParentID, prprpr_CompanyCount " +
            "FROM PRProductProvided WITH (NOLOCK) " +
            "ORDER BY prprpr_DisplayOrder";

        public static string CODE_SEARCH_TYPE_ANY = "Any";
        public static string CODE_SEARCH_TYPE_ALL = "All";
        public static string CODE_SEARCH_TYPE_ONLY = "Only";

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

            // Determine if are you sure confirmation messages should be displayed
            if (_bIsDirty)
            {
                ClientScript.RegisterClientScriptBlock(Page.GetType(), "script1", "var bDisplayConfirmations = true;", true);
            }
            else
            {
                ClientScript.RegisterClientScriptBlock(Page.GetType(), "script1", "var bDisplayConfirmations = false;", true);
            }

            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_FUNCTIONS2_FILE));
        }

        /// <summary>
        /// Stores the current company search criteria object as part of 
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
        /// Sets the submenu items for the company search pages
        /// </summary>
        protected void SetSubmenu(string strDefaultID)
        {
            List<SubMenuItem> oMenuItems = new List<SubMenuItem>();

            AddSubmenuItemButton(oMenuItems, Resources.Global.Company, "btnCompany", SecurityMgr.Privilege.CompanySearchPage);
            AddSubmenuItemButton(oMenuItems, Resources.Global.Rating, "btnRating", SecurityMgr.Privilege.CompanySearchRatingPage);
            AddSubmenuItemButton(oMenuItems, Resources.Global.Location, "btnLocation", SecurityMgr.Privilege.CompanySearchLocationPage);

            if(HasPrivilege_ITA_Always_True(SecurityMgr.Privilege.CompanySearchCommoditiesPage))
                AddSubmenuItemButton(oMenuItems, Resources.Global.Commodity, "btnCommodity", SecurityMgr.Privilege.CompanySearchCommoditiesPage, "", true);
            else
                AddSubmenuItemButton(oMenuItems, Resources.Global.Commodity, "btnCommodity", SecurityMgr.Privilege.CompanySearchCommoditiesPage);

            AddSubmenuItemButton(oMenuItems, Resources.Global.Species, "btnSpecie", SecurityMgr.Privilege.CompanySearchServicesPage);
            AddSubmenuItemButton(oMenuItems, Resources.Global.Product, "btnProduct", SecurityMgr.Privilege.CompanySearchProductsPage);
            AddSubmenuItemButton(oMenuItems, Resources.Global.Service, "btnService", SecurityMgr.Privilege.CompanySearchServicesPage);
            AddSubmenuItemButton(oMenuItems, Resources.Global.Classification, "btnClassification", SecurityMgr.Privilege.CompanySearchClassificationsPage);
            AddSubmenuItemButton(oMenuItems, Resources.Global.Profile, "btnProfile", SecurityMgr.Privilege.CompanySearchProfilePage);
            AddSubmenuItemButton(oMenuItems, Resources.Global.LocalSourceData, "btnLocalSourceData", SecurityMgr.Privilege.LocalSourceDataAccess);
            AddSubmenuItemButton(oMenuItems, Resources.Global.CustomFilters, "btnCustom", SecurityMgr.Privilege.CompanySearchCustomPage);

            SubMenuBar oSubMenuBar = (SubMenuBar)Master.FindControl("SubmenuBar");
            oSubMenuBar.MenuItemEvent += new EventHandler(oSubMenuBar_MenuItemEvent);
            oSubMenuBar.LoadMenuButtons(oMenuItems, strDefaultID);
        }

        /// <summary>
        /// Handles the on click event for each of the submenu items.  The
        /// current company search criteria object will be stored and the 
        /// user will be redirected accordingly.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void oSubMenuBar_MenuItemEvent(object sender, EventArgs e)
        {
            // If we are currently working with a specified search id, 
            // create a querystring to pass this along
            string szQueryString = "";

            if (!String.IsNullOrEmpty(Request.QueryString.ToString()))
                szQueryString = "?" + Request.QueryString.ToString();

            // Store search criteria
            StoreCriteria();

            switch (((WebControl)sender).ID)
            {
                case "btnCompany":
                    Response.Redirect(PageConstants.COMPANY_SEARCH + szQueryString);
                    break;
                case "btnLocation":
                    Response.Redirect(PageConstants.COMPANY_SEARCH_LOCATION + szQueryString);
                    break;
                case "btnClassification":
                    Response.Redirect(PageConstants.COMPANY_SEARCH_CLASSIFICATION + szQueryString);
                    break;
                case "btnCommodity":
                    Response.Redirect(PageConstants.COMPANY_SEARCH_COMMODITY + szQueryString);
                    break;
                case "btnRating":
                    Response.Redirect(PageConstants.COMPANY_SEARCH_RATING + szQueryString);
                    break;
                case "btnProfile":
                    Response.Redirect(PageConstants.COMPANY_SEARCH_PROFILE + szQueryString);
                    break;
                case "btnCustom":
                    Response.Redirect(PageConstants.COMPANY_SEARCH_CUSTOM + szQueryString);
                    break;
                case "btnSpecie":
                    Response.Redirect(PageConstants.COMPANY_SEARCH_SPECIE + szQueryString);
                    break;
                case "btnProduct":
                    Response.Redirect(PageConstants.COMPANY_SEARCH_PRODUCT + szQueryString);
                    break;
                case "btnService":
                    Response.Redirect(PageConstants.COMPANY_SEARCH_SERVICE + szQueryString);
                    break;
                case "btnLocalSourceData":
                    Response.Redirect(PageConstants.COMPANY_SEARCH_LOCAL_SOURCE + szQueryString);
                    break;
            }
        }

        /// <summary>
        /// Handles the Search on click event for each of the company search pages
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            StoreCriteria();

            Response.Redirect(PageConstants.Format(PageConstants.COMPANY_SEARCH_RESULTS, _iSearchID));
        }

        /// <summary>
        /// Handles the Clear This Criteria on click event for each of the company 
        /// search pages
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnClearCriteria_Click(object sender, EventArgs e)
        {
            // Reset current form only 
            ClearCriteria();

            // Store reset values on search criteria object
            StoreCriteria();

            // Reload Current page 
            // NOTE: This is required to correctly refresh search criteria panel.
            Response.Redirect(_szRedirectURL + "?SearchID=" + _iSearchID.ToString());
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

            if(Request.Url.ToString().ToLower().Contains(PageConstants.LIMITADO_SEARCH.ToLower()))
                Response.Redirect(PageConstants.LIMITADO_SEARCH);
            else
                Response.Redirect(PageConstants.COMPANY_SEARCH);
        }

        /// <summary>
        /// Handles the Save Search Criteria on click event for each of the company
        /// search pages
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

        /// <summary>
        /// Handles the Load Search Criteria on click event for each of the company 
        /// search pages
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnLoadSearch_Click(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.SAVED_SEARCHES);
        }

        /// <summary>
        /// Handles the New Search on click event for each of the company search
        /// pages.  Takes the user to the SearchList.aspx page.  If the user has 
        /// modified the pages, ask "Are you sure you want to overrwrite and begin 
        /// a new search"?
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnNewSearch_Click(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.SAVED_SEARCHES);
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
        /// Retrieves and stores the current classification list from the database
        /// </summary>
        /// <returns>DataTable of current PRClassification values</returns>
        public DataTable GetClassificationList()
        {
            string szCacheName = string.Format("dtClassificationList_{0}", PageControlBaseCommon.GetCulture(_oUser));
            if (GetCacheValue(szCacheName) == null)
            {
                // Retrieve Classification List from Database
                string szSQL = string.Format(SQL_GET_CLASSIFICATIONS,
                    GetObjectMgr().GetLocalizedColName("prcl_Name"),
                    GetObjectMgr().GetLocalizedColName("prcl_Description"));

                DataSet dsClassificationList;
                DataTable dtClassificationList;

                dsClassificationList = GetDBAccess().ExecuteSelect(szSQL);
                dtClassificationList = dsClassificationList.Tables[0];

                // Store in Session
                AddCacheValue(szCacheName, dtClassificationList);
                return dtClassificationList;
            }
            else
            {
                return (DataTable)GetCacheValue(szCacheName);
            }
        }

        /// <summary>
        /// Retrieves and stores the current Specie list from the database
        /// </summary>
        /// <returns>DataTable of current PRSpecie values</returns>
        public DataTable GetSpecieList()
        {
            string szCacheName = "dtSpecieList";
            if (GetCacheValue(szCacheName) == null)
            {
                // Retrieve Specie List from Database
                string szSQL = string.Format(SQL_GET_SPECIES,
                                             GetObjectMgr().GetLocalizedColName("prspc_Name"));

                DataTable dtSpecieList = GetDBAccess().ExecuteSelect(szSQL).Tables[0];

                // Store in Session
                AddCacheValue(szCacheName, dtSpecieList);
            }
            return (DataTable)GetCacheValue(szCacheName);
        }

        /// <summary>
        /// Retrieves and stores the current PRProductProvided list from the database
        /// </summary>
        /// <returns>DataTable of current PRProductProvided values</returns>
        public DataTable GetProductProvidedList()
        {
            string szCacheName = "dtProductProvidedList";
            if (GetCacheValue(szCacheName) == null)
            {
                // Retrieve ProductProvided List from Database
                string szSQL = string.Format(SQL_GET_PRODUCT_PROVIDED,
                                             GetObjectMgr().GetLocalizedColName("prprpr_Name"));

                DataTable dtProductProvidedList = GetDBAccess().ExecuteSelect(szSQL).Tables[0];

                // Store in Session
                AddCacheValue(szCacheName, dtProductProvidedList);
            }
            return (DataTable)GetCacheValue(szCacheName);
        }

        /// <summary>
        /// Retrieves and stores the current PRServiceProvided list from the database
        /// </summary>
        /// <returns>DataTable of current PRServiceProvided values</returns>
        public DataTable GetServiceProvidedList()
        {
            string szCacheName = "dtServiceProvidedList";
            if (GetCacheValue(szCacheName) == null)
            {
                // Retrieve ServiceProvided List from Database
                string szSQL = string.Format(SQL_GET_SERVICE_PROVIDED,
                                             GetObjectMgr().GetLocalizedColName("prserpr_Name"));

                DataTable dtServiceProvidedList = GetDBAccess().ExecuteSelect(szSQL).Tables[0];

                // Store in Session
                AddCacheValue(szCacheName, dtServiceProvidedList);
            }
            return (DataTable)GetCacheValue(szCacheName);
        }

        /// <summary>
        /// Retrieves and stores the current attribute list from the database
        /// </summary>
        /// <returns>DataTable of current PRAttribute values</returns>
        public DataTable GetAttributeList()
        {
            string szCacheName = string.Format("dtAttributeList_{0}", PageControlBaseCommon.GetCulture(_oUser));

            if (GetCacheValue(szCacheName) == null)
            {
                // Retrieve Attribute List from Database
                DataSet dsAttributeList = GetDBAccess().ExecuteSelect(string.Format(SQL_GET_ATTRIBUTES, GetObjectMgr().GetLocalizedColName("prat_Name")));
                DataTable dtAttributeList;
                dtAttributeList = dsAttributeList.Tables[0];

                // Store in Session
                AddCacheValue(szCacheName, dtAttributeList);
                return dtAttributeList;
            }
            else
            {
                return (DataTable)GetCacheValue(szCacheName);
            }
        }

        /// <summary>
        /// Helper method used to determine if we should display
        /// the company count value.
        /// </summary>
        /// <param name="iCount"></param>
        /// <param name="bIncludeCount"></param>
        /// <returns></returns>
        protected string GetCompanyCount(int iCount, bool bIncludeCount)
        {
            if (bIncludeCount)
            {
                return " (" + iCount.ToString() + ")";
            }
            else
            {
                return string.Empty;
            }
        }

        /// <summary>
        /// Helper method that creates a pad string used
        /// to ident items in our criteria table.
        /// </summary>
        /// <param name="iCount"></param>
        /// <returns></returns>
        protected string GetPadding(int iCount)
        {
            StringBuilder sbPadding = new StringBuilder();
            for (int i = 0; i < iCount; i++)
            {
                sbPadding.Append("&nbsp;");
            }
            return sbPadding.ToString();
        }

        /// <summary>
        /// This method builds nested tables to present a list of search criteria.  The outer table
        /// contains a single row for each level 1 item.  Each level 1 item then has an inner table for
        /// all of its children.
        /// </summary>
        protected void BuildTable(Table tblCriteria, DataRow[] dtSourceRows,
            string szLevelColumn, string szIDColumn, string szNameColumn, string szCompanyCountColumn,
            bool bDisplayCompanyCount, bool blnStriped = false,
            string rootLevel1Restrictor = null,
            string Level2Start = null, 
            string Level2End = null)
        {
            DataRow[] adrRows = dtSourceRows;

            Table tblTable = tblCriteria;
            TableRow oMainRow = new TableRow();
            tblTable.Rows.Add(oMainRow);

            Table tblChild = null;
            TableCell oLevel1Cell = null;
            string szRowClass = string.Empty;
            string szParentID = string.Empty;

            int iPreviousLevel = 1;
            CheckBox chkPreviousCheckbox = null;
            Stack<string> stkParentIDs = new Stack<string>();

            bool bLevel1FilterStarted = false;
            bool bLevel1FilterEnded = false;
            
            bool bLevel2FilterStarted = false;
            bool bLevel2FilterEnded = false;

            foreach (DataRow drRow in adrRows)
            {
                int iLevel = Convert.ToInt32(drRow[szLevelColumn]);
                string szID = Convert.ToString(drRow[szIDColumn]);
                string szName = Convert.ToString(drRow[szNameColumn]);

                if (iLevel == 1)
                {
                    if (string.IsNullOrEmpty(rootLevel1Restrictor))
                        bLevel1FilterStarted = true;
                    else if (!bLevel1FilterStarted && szID == rootLevel1Restrictor)
                        bLevel1FilterStarted = true; //this is the one to start with
                    else if (bLevel1FilterStarted)
                        bLevel1FilterEnded = true; //we hit another level1 so time to stop processing others
                }
                else
                {
                    if (string.IsNullOrEmpty(Level2Start) || Level2Start == szID)
                        bLevel2FilterStarted = true;
                    if (Level2End == szID)
                        bLevel2FilterEnded = true;

                    if (!bLevel2FilterStarted || bLevel2FilterEnded)
                        continue;
                }

                if (!bLevel1FilterStarted || bLevel1FilterEnded)
                    continue; //only process this record if Filter range has started but not ended

                int iCompanyCount = 0;
                if (drRow[szCompanyCountColumn] != DBNull.Value)
                {
                    iCompanyCount = Convert.ToInt32(drRow[szCompanyCountColumn].ToString());
                }

                // If this is a level 1 item, start a new cell in the 
                // outer table.
                if (iLevel == 1)
                {
                    oLevel1Cell = new TableCell();
                    oLevel1Cell.CssClass = "vertical-align-top";
                    //oLevel1Cell.VerticalAlign = VerticalAlign.Top;
                    oLevel1Cell.Width = new Unit("100px");
                    oMainRow.Cells.Add(oLevel1Cell);

                    tblChild = new Table();
                    tblChild.ID = "TBL_" + tblCriteria.ID + "_INNER";

                    //if (blnStriped)
                    //    tblChild.CssClass = "table table_bbos norm_lbl";
                    //else
                    //    tblChild.CssClass = "table gray_bg";
                    tblChild.CssClass = "table table_bbos norm_lbl";

                    oLevel1Cell.Controls.Add(tblChild);
                    szRowClass = string.Empty;
                }

                TableRow oRow = new TableRow();
                tblChild.Rows.Add(oRow);

                TableCell oCell = new TableCell();
                oCell.CssClass = "nowraptd_wraplabel";
                
                oRow.Cells.Add(oCell);

                // Handle the indentation
                if (iLevel > 2)
                {
                    Literal litPadding = new Literal();
                    litPadding.Text = GetPadding(iLevel * 3);
                    oCell.Controls.Add(litPadding);
                }

                CheckBox oCheckbox = new CheckBox();
                oCheckbox.ID = "CHK_" + PREFIX_CLASS + szID;

                oCheckbox.CssClass = "smallcheck";
                if (iLevel == 1)
                    oCheckbox.CssClass = "smallcheck level1";

                oCheckbox.Attributes.Add("Value", szID);
                oCheckbox.CheckedChanged += new EventHandler(oCheckbox_CheckChanged);
                oCheckbox.AutoPostBack = true;
                oCheckbox.Text = szName + GetCompanyCount(iCompanyCount, bDisplayCompanyCount);

                // If our level has changed, push or pop the stack.  
                // If our level has increased, put our parent on the
                // stack.  If our level has decreased, pop that last
                // parent so that our actually parent is now on top.
                if (iLevel > iPreviousLevel)
                {
                    stkParentIDs.Push(chkPreviousCheckbox.ID);
                }
                else if (iLevel < iPreviousLevel)
                {
                    stkParentIDs.Pop();
                }

                // It is the parent ID attribute that allows us to
                // iterate through the controls to select/deselect
                // the appropriate children controls. 
                if (iLevel == 1)
                {
                    szParentID = oCheckbox.ID;
                }
                else
                {
                    oCheckbox.InputAttributes["ParentID"] = stkParentIDs.Peek(); //Attributes.Add("ParentID", stkParentIDs.Peek());
                }

                if (iLevel > 1)
                    oCell.Controls.Add(oCheckbox);

                iPreviousLevel = iLevel;
                chkPreviousCheckbox = oCheckbox;
            }
        }

        protected List<CheckBoxGroup> BuildTable_Bootstrap(PlaceHolder phCriteria, 
                    DataRow[] dtSourceRows,
                    string szLevelColumn, 
                    string szIDColumn, 
                    string szNameColumn, 
                    string szCountColumn,
                    bool bDisplayCompanyCount)
        {
            //Create in-memory checkboxgroup that can be passed into usercontrol for display
            List<CheckBoxGroup> lstCBG = new List<CheckBoxGroup>();
            CheckBoxGroup cbgWorking = new CheckBoxGroup();

            foreach(DataRow drRow in dtSourceRows)
            {
                int iLevel = Convert.ToInt32(drRow[szLevelColumn]);
                string szID = Convert.ToString(drRow[szIDColumn]);
                string szName = Convert.ToString(drRow[szNameColumn]);
                int iCount = 0;

                if (drRow[szCountColumn] != DBNull.Value)
                    iCount = Convert.ToInt32(drRow[szCountColumn].ToString());

                if(iLevel == 1)
                {
                    if (!string.IsNullOrEmpty(cbgWorking.root.id))
                    {
                        //Store a complete group and start a new one
                        lstCBG.Add(cbgWorking);
                        cbgWorking = new CheckBoxGroup();
                    }

                    //We have a new root level to work on
                    cbgWorking.root.id = szID;
                    cbgWorking.root.name = szName;
                    cbgWorking.root.level = iLevel;
                    cbgWorking.root.count = iCount;

                    cbgWorking.root.checkboxId = "CHK_" + PREFIX_CLASS + cbgWorking.root.id;
                }
                else
                {
                    //Level 2 item -- add to root of current working root ID
                    CheckBoxItem cbi = new CheckBoxItem();
                    cbi.id = szID;
                    cbi.name = szName;
                    cbi.level = 2;
                    cbi.parentId = cbgWorking.root.id;
                    cbi.count = iCount;

                    cbgWorking.lstItems.Add(cbi);
                }
            }

            if (cbgWorking.lstItems.Count > 0)
            {
                // Store final cbg
                lstCBG.Add(cbgWorking);
            }

            return lstCBG;
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

        /// <summary>
        /// Helper method that builds the "Any", "All", "Only" search type custom captions
        /// list.
        /// </summary>
        /// <param name="szAnyCaption"></param>
        /// <param name="szAllCaption"></param>
        /// <returns></returns>
        public static List<ICustom_Caption> GetSearchTypeList(string szAnyCaption, string szAllCaption)
        {
            // Bind Search Type control
            List<ICustom_Caption> lSearchType = new List<ICustom_Caption>();

            ICustom_Caption oCustom_Caption = new Custom_Caption();
            oCustom_Caption.Code = CODE_SEARCH_TYPE_ANY;
            oCustom_Caption.Meaning = szAnyCaption;
            lSearchType.Add(oCustom_Caption);

            ICustom_Caption oCustom_Caption2 = new Custom_Caption();
            oCustom_Caption2.Code = CODE_SEARCH_TYPE_ALL;
            oCustom_Caption2.Meaning = szAllCaption;
            lSearchType.Add(oCustom_Caption2);

            return lSearchType;
        }

        /// <summary>
        /// Builds a control table containing the button, checkbox control, and button controls
        /// </summary>
        /// <param name="tblTable">Form Table to place controls in</param>
        /// <param name="iNumOfColumns">Number of Columns to include in table</param>
        /// <param name="szControlGroupPrefix">Unique prefix to use for control group</param>
        /// <param name="pnlSelectLinks"></param>
        /// <param name="updPanel"></param>
        protected void BuildControlTable(Table tblTable, int iNumOfColumns, string szControlGroupPrefix,
            Panel pnlSelectLinks, UpdatePanel updPanel)
        {
            BuildControlTable(tblTable, iNumOfColumns, szControlGroupPrefix, pnlSelectLinks, updPanel, bReverseSelectGreaterThanLessThan:false);
        }

        protected void BuildControlTable(Table tblTable, int iNumOfColumns, string szControlGroupPrefix,
            Panel pnlSelectLinks, UpdatePanel updPanel, bool bReverseSelectGreaterThanLessThan)
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

            TableRow oRow;
            TableCell oCell;
            CheckBox oCheckbox;
            LinkButton oButtonLessThan, oButtonGreaterThan;

            int iMaxIndex = osRefData.Count - 1;
            int iItemsAddedCount = 0;

            #region Create Select All / Deselect All links
            Literal oLiteral2 = new Literal();
            oLiteral2.Text = ""; //oLiteral2.Text = "[&nbsp;";
            pnlSelectLinks.Controls.Add(oLiteral2);

            // The greater than / less than depends upon the direction of the
            // data (lower to higher or higher to lower).
            string szLessThanFlag = "true";
            string szGreaterThanFlag = "false";
            if (bReverseSelectGreaterThanLessThan)
            {
                szLessThanFlag = "false";
                szGreaterThanFlag = "true";
            }

            // Add <= link to select all checkboxes less than or equal
            // to the selected value
            oButtonLessThan = new LinkButton();
            oButtonLessThan.ID = "LT_" + szControlGroupPrefix;
            oButtonLessThan.OnClientClick = "javascript:SelectPartialList2('" + CONTAINER_NAME + "_CHK_" + szControlGroupPrefix + "_', " + szLessThanFlag + ", " + iMaxIndex.ToString() + ");";

            // Nest image in linkbutton
            Literal oLiteral = new Literal();
            oLiteral.Text = Resources.Global.SelectAllLess;
            oButtonLessThan.Controls.Add(oLiteral);

            pnlSelectLinks.Controls.Add(oButtonLessThan);

            Literal oSALLiteral = new Literal();
            oSALLiteral.Text = "&nbsp;|&nbsp;";
            pnlSelectLinks.Controls.Add(oSALLiteral);

            AsyncPostBackTrigger oTrigger = new AsyncPostBackTrigger();
            oTrigger.ControlID = oButtonLessThan.ID;
            oTrigger.EventName = "Click";
            updPanel.Triggers.Add(oTrigger);

            // Add <= link to select all checkboxes less than or equal
            // to the selected value
            oButtonGreaterThan = new LinkButton();
            oButtonGreaterThan.ID = "GT_" + szControlGroupPrefix;
            oButtonGreaterThan.OnClientClick = "javascript:SelectPartialList2('" + CONTAINER_NAME + "_CHK_" + szControlGroupPrefix + "_', " + szGreaterThanFlag + ", " + iMaxIndex.ToString() + ");";

            // Nest image in linkbutton
            oLiteral = new Literal();
            oLiteral.Text = Resources.Global.SelectAllGreater;
            oButtonGreaterThan.Controls.Add(oLiteral);

            pnlSelectLinks.Controls.Add(oButtonGreaterThan);

            oTrigger = new AsyncPostBackTrigger();
            oTrigger.ControlID = oButtonGreaterThan.ID;
            oTrigger.EventName = "Click";
            updPanel.Triggers.Add(oTrigger);

            Literal oSAGLiteral = new Literal();
            oSAGLiteral.Text = "&nbsp;|&nbsp;";
            pnlSelectLinks.Controls.Add(oSAGLiteral);


            // Set Select All / Deselect All Links for Volume checkbox list
            LinkButton oSelectAll = new LinkButton();
            oSelectAll.ID = "SA_" + szControlGroupPrefix + "_" + iItemsAddedCount.ToString();
            oSelectAll.OnClientClick = "javascript:CheckAllInList('" + CONTAINER_NAME + "_CHK_" + szControlGroupPrefix + "_', true, " + iMaxIndex.ToString() + ");";
            oSelectAll.Text = Resources.Global.SelectAll;
            pnlSelectLinks.Controls.Add(oSelectAll);

            AsyncPostBackTrigger oTrigger4 = new AsyncPostBackTrigger();
            oTrigger4.ControlID = oSelectAll.ID;
            oTrigger4.EventName = "Click";
            updPanel.Triggers.Add(oTrigger4);

            Literal oLiteral3 = new Literal();
            oLiteral3.Text = "&nbsp;|&nbsp;";
            pnlSelectLinks.Controls.Add(oLiteral3);

            LinkButton oDeselectAll = new LinkButton();
            oDeselectAll.ID = "DA_" + szControlGroupPrefix + "_" + iItemsAddedCount.ToString();
            oDeselectAll.OnClientClick = "javascript:CheckAllInList('" + CONTAINER_NAME + "_CHK_" + szControlGroupPrefix + "_', false, " + iMaxIndex.ToString() + ");";
            oDeselectAll.Text = Resources.Global.DeselectAll;

            pnlSelectLinks.Controls.Add(oDeselectAll);

            AsyncPostBackTrigger oTrigger5 = new AsyncPostBackTrigger();
            oTrigger5.ControlID = oDeselectAll.ID;
            oTrigger5.EventName = "Click";
            updPanel.Triggers.Add(oTrigger5);

            Literal oLiteral4 = new Literal();
            oLiteral4.Text = ""; //oLiteral4.Text = "&nbsp;]";
            pnlSelectLinks.Controls.Add(oLiteral4);

            #endregion

            oRow = new TableRow();

            Table tblChildren = null;
            TableCell oChildCell = null;
            TableRow oChildRow = null;

            // calculate the number of rows / column
            int iRowCount = (osRefData.Count / iNumOfColumns) + ((osRefData.Count % iNumOfColumns) > 0 ? 1 : 0);

            // Iterate through the columns
            for (int i = 0; i < iNumOfColumns; i++)
            {
                tblChildren = new Table();
                tblChildren.ID = "TBL_" + szControlGroupPrefix + "_" + i.ToString();
                tblChildren.Width = Unit.Percentage(100);

                tblChildren.CssClass = "table-bbos norm_lbl";

                // Iterate through the rows in each column.  Each column will contain it's own
                // table.
                for (int j = 0; ((j < iRowCount) && (iItemsAddedCount < osRefData.Count)); j++)
                {
                    ICustom_Caption oCustomCaption = (ICustom_Caption)osRefData[iItemsAddedCount];

                    oCheckbox = new CheckBox();
                    oCheckbox.ID = "CHK_" + szControlGroupPrefix + "_" + iItemsAddedCount.ToString();
                    oCheckbox.Attributes.Add("Value", oCustomCaption.Code);
                    oCheckbox.Text = oCustomCaption.Meaning;
                    oCheckbox.AutoPostBack = true;

                    AsyncPostBackTrigger oTrigger2 = new AsyncPostBackTrigger();
                    oTrigger2.ControlID = oCheckbox.ID;
                    oTrigger2.EventName = "CheckedChanged";
                    updPanel.Triggers.Add(oTrigger2);

                    oChildCell = new TableCell();
                    oChildCell.CssClass = "nowraptd_wraplabel";
                    oChildCell.Controls.Add(oCheckbox);

                    oChildRow = new TableRow();
                    oChildRow.Cells.Add(oChildCell);
                    tblChildren.Rows.Add(oChildRow);

                    iItemsAddedCount++;
                }

                oCell = new TableCell();
                oCell.CssClass = "vertical-align-top";
                oCell.Controls.Add(tblChildren);
                oRow.Controls.Add(oCell);
            }
            tblTable.Rows.Add(oRow);
        }

        protected List<ICustom_Caption> GetSearchTypeValues()
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

        protected void ModifyIndustryType(RadioButtonList rblIndustryType)
        {
            foreach (ListItem item in rblIndustryType.Items)
            {
                item.Text = item.Text + "&nbsp;&nbsp;&nbsp;&nbsp;";
            }
        }

        protected string GetSearchButtonMsg()
        {
            if (DateTime.Today > Utilities.GetDateTimeConfigValue("SearchButtonMsgEndDate", new DateTime(2015, 2, 1)))
            {
                return string.Empty;
            }

            int displayCount = 0;
            if (Request.Cookies["BBOSSearchButtonMsgCount"] != null)
            {
                if (!Int32.TryParse(Convert.ToString(Request.Cookies["BBOSSearchButtonMsgCount"].Value), out displayCount))
                {
                    displayCount = 1;
                }
            }

            if (displayCount > Utilities.GetIntConfigValue("SearchButtonMsgMaxCount", 20))
            {
                return string.Empty;
            }

            displayCount++;
            Response.Cookies["BBOSSearchButtonMsgCount"].Value = displayCount.ToString();
            Response.Cookies["BBOSSearchButtonMsgCount"].Expires = DateTime.Now.AddYears(1);

            return "<p><em>Note: The Search Button has moved to the left hand side of this page.</em></p>";
        }
    }
}
