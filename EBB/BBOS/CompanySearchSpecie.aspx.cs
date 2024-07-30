/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2009-2020

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CompanySearchSpecie
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using PRCo.EBB.Util;

using TSI.Utils;
namespace PRCo.BBOS.UI.Web
{
    public partial class CompanySearchSpecie : CompanySearchBase
    {
        //private int MaxLevel = 3;

        private const string PAGE_VIEW_EXPANDED = "1";
        private const string PAGE_VIEW_BASIC = "0";
        private string _pageView = PAGE_VIEW_BASIC;

        private string PageView
        {
            get
            {
                return PAGE_VIEW_EXPANDED;
            }
            set { _pageView = (value == PAGE_VIEW_EXPANDED ? PAGE_VIEW_EXPANDED : PAGE_VIEW_BASIC); }
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
            // species listing table
            PageView = Request.QueryString["CommodityExpanded"];

            CheckForExpandedCriteria();
            //MaxLevel = (PageView == PAGE_VIEW_EXPANDED ? 7 : 3);
            BuildSpeciesTables();

            //BuildTable(tblSpecie, GetSpecieList().Select("1=1", "prspc_DisplayOrder ASC"), "prspc_Level",
            //"prspc_SpecieID", "prspc_Name", "prspc_CompanyCount",
            //Utilities.GetBoolConfigValue("SpecieCountEnabled", false));
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
            SetPageTitle(Resources.Global.CompanySearch, Resources.Global.SpeciesCriteria);

            // Add company submenu to this page
            SetSubmenu("btnSpecie");

            if (!IsPostBack)
            {
                LoadLookupValues();
                PopulateForm();
            }
            else
            {
                StoreCriteria();
            }

            // Set Search Criteria User Control
            ucCompanySearchCriteriaControl.CompanySearchCriteria = _oCompanySearchCriteria;
        }

        /// <summary>
        /// Loads all of the databound controls setting 
        /// their default values.
        /// </summary>
        protected void LoadLookupValues()
        {
            List<ICustom_Caption> lSearchType = GetSearchTypeList(Resources.Global.SpecieSearchTypeAny, Resources.Global.SpecieSearchTypeAll);
            BindLookupValues(rblSearchType, lSearchType, CODE_SEARCH_TYPE_ANY);
        }

        protected void PopulateForm()
        {
            string[] aszIDs = UIUtils.GetString(_oCompanySearchCriteria.SpecieIDs).Split(CompanySearchBase.achDelimiter);

            if (Array.IndexOf(aszIDs, "1") >= 0) //Softwood
                CHK_CLASS1.Checked = true;
            if (Array.IndexOf(aszIDs, "75") >= 0) //Hardwood
                CHK_CLASS75.Checked = true;

            SetTableValues(aszIDs, tblSoftwood, PREFIX_CLASS, true, false, false);
            SetTableValues(aszIDs, tblHardwood1, PREFIX_CLASS, true, false, false);
            SetTableValues(aszIDs, tblHardwood2, PREFIX_CLASS, true, false, false);
            SetListValue(rblSearchType, _oCompanySearchCriteria.SpecieSearchType);

            ApplyReadOnlyCheck(btnSaveSearch);
        }

        /// <summary>
        /// Collects and stores the search criteria on the users current company search
        /// criteria object 
        /// </summary>
        protected override void StoreCriteria()
        {
            _oCompanySearchCriteria.SpecieSearchType = rblSearchType.SelectedValue;

            StringBuilder sbValueList = new StringBuilder();
            if(CHK_CLASS1.Checked)
                AddDelimitedValue(sbValueList, "1"); //Softwood
            if (CHK_CLASS75.Checked)
                AddDelimitedValue(sbValueList, "75"); //Hardwood

            AddDelimitedValue(sbValueList, GetTableValues(tblSoftwood, PREFIX_CLASS));
            AddDelimitedValue(sbValueList, GetTableValues(tblHardwood1, PREFIX_CLASS));
            AddDelimitedValue(sbValueList, GetTableValues(tblHardwood2, PREFIX_CLASS));
            _oCompanySearchCriteria.SpecieIDs = sbValueList.ToString();

            base.StoreCriteria();
        }

        /// <summary>
        /// Clears and stores the search criteria on the users current company search
        /// criteria object 
        /// </summary>
        protected override void ClearCriteria()
        {
            rblSearchType.SelectedIndex = -1;

            CHK_CLASS1.Checked = false; //Softwood
            CHK_CLASS75.Checked = false; //Hardwood

            ClearTableValues(tblSoftwood);
            ClearTableValues(tblHardwood1);
            ClearTableValues(tblHardwood2);

            _szRedirectURL = PageConstants.COMPANY_SEARCH_SPECIE;
        }

        /// <summary>
        /// Process on check changed events for checkboxes in the table.
        /// If the level 1 item is selected, all children should be disabled 
        /// and included in the search.  Reset the table values, store updated criteria, and 
        /// refresh page to update the search criteria user control.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override protected void oCheckbox_CheckChanged(object sender, EventArgs e)
        {
            LogMessage("oCheckbox_CheckChanged");
            string[] aszIDs = UIUtils.GetString(_oCompanySearchCriteria.SpecieIDs).Split(achDelimiter);

            if (Array.IndexOf(aszIDs, "1") >= 0) //Softwood
                CHK_CLASS1.Checked = true;
            if (Array.IndexOf(aszIDs, "75") >= 0) //Hardwood
                CHK_CLASS75.Checked = true;

            SetTableValues(aszIDs, tblSoftwood, PREFIX_CLASS, true, false, false);
            SetTableValues(aszIDs, tblHardwood1, PREFIX_CLASS, true, false, false);
            SetTableValues(aszIDs, tblHardwood2, PREFIX_CLASS, true, false, false);

            // Store search criteria and refresh page
            StoreCriteria();
        }

        /// <summary>
        /// Check users page level authorization
        /// </summary>
        /// <returns></returns>
        override protected bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchSpeciePage).HasPrivilege;
        }
        protected override bool IsAuthorizedForData()
        {
            return true;
        }

        /// <summary>
        /// The method will scan through the selected search criteria to determine if the user
        /// has selected elements on the expanded criteria view.  This will be used to determine
        /// the toggle state for loaded searches.
        /// </summary>
        protected void CheckForExpandedCriteria()
        {
            // Check if the search type is "All" or "Only"
            if (_oCompanySearchCriteria.CommoditySearchType == CODE_SEARCH_TYPE_ALL ||
                _oCompanySearchCriteria.CommoditySearchType == CODE_SEARCH_TYPE_ONLY)
            {
                PageView = PAGE_VIEW_EXPANDED;
            }
        }

        private void BuildSpeciesTables()
        {
            // Retrieve Species
            DataTable dtSpecies = GetSpecieList();

            BuildTable(tblSoftwood, GetSpecieList().Select("1=1", "prspc_DisplayOrder ASC"), "prspc_Level",
                        "prspc_SpecieID", "prspc_Name", "prspc_CompanyCount",
                        Utilities.GetBoolConfigValue("SpecieCountEnabled", false),
                        rootLevel1Restrictor: "1");

            BuildTable(tblHardwood1, GetSpecieList().Select("1=1", "prspc_DisplayOrder ASC"), "prspc_Level",
                        "prspc_SpecieID", "prspc_Name", "prspc_CompanyCount",
                        Utilities.GetBoolConfigValue("SpecieCountEnabled", false),
                        rootLevel1Restrictor: "75",
                        Level2End: "214"
                        );

            BuildTable(tblHardwood2, GetSpecieList().Select("1=1", "prspc_DisplayOrder ASC"), "prspc_Level",
                        "prspc_SpecieID", "prspc_Name", "prspc_CompanyCount",
                        Utilities.GetBoolConfigValue("SpecieCountEnabled", false),
                        rootLevel1Restrictor: "75",
                        Level2Start: "214");

            CHK_CLASS1.CheckedChanged += new EventHandler(oCheckbox_CheckChanged); //Softwood
            CHK_CLASS75.CheckedChanged += new EventHandler(oCheckbox_CheckChanged); //Hardwood
        }

        private void BuildSpecieTable(int rootSpecieID, CheckBoxList specieTable, DataTable dtSpecies)
        {
            DataView specieData = new DataView(dtSpecies);
            specieData.RowFilter = "prspc_ParentID=" + rootSpecieID.ToString();
            specieData.Sort = "prspc_Name";

            specieTable.DataSource = specieData;
            specieTable.DataTextField = "prspc_Name";
            specieTable.DataValueField = "prspc_SpecieID";
            specieTable.DataBind();
        }
    }
}