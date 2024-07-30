/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2019-2023

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: LimitadoSearch.aspx.cs
 Description: Limitado home page for searching companies - no sub-menu is needed	

 Notes:	

***********************************************************************
***********************************************************************/

using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This page contains the general search fields for searching companies
    /// including the company name, bb #, type, listing status, company phone, company fax, 
    /// company email, and new listings.
    /// </summary>
    public partial class LimitadoSearch : CompanySearchBase
    {
        /// <summary>
        /// Calls page functions required to build and process this page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            // Set page title, sub-title
            SetPageTitle(Resources.Global.CompanySearch, Resources.Global.CompanyCriteria);

            // Add company submenu to this page
            SetPopover();

            if (!IsPostBack)
            {
                PopulateMicroslider();
                LoadLookupValues();
                PopulateForm();

                if (string.IsNullOrEmpty(_oCompanySearchCriteria.ListingCountryIDs))
                {
                    ddlCountry.SelectedValue = "1"; //USA
                    _oCompanySearchCriteria.ListingCountryIDs = "1";
                }
                else
                {
                    ddlCountry.SelectedValue = _oCompanySearchCriteria.ListingCountryIDs;
                }

                if (string.IsNullOrEmpty(_oCompanySearchCriteria.ListingStateIDs))
                {
                    ddlState.SelectedValue = "";
                    _oCompanySearchCriteria.ListingStateIDs = "";
                }
                else
                {
                    ddlState.SelectedValue = _oCompanySearchCriteria.ListingStateIDs;
                }
                
                _oCompanySearchCriteria.CommoditySearchType = CODE_SEARCH_TYPE_ANY;
                _oCompanySearchCriteria.ClassificationSearchType = CODE_SEARCH_TYPE_ANY;
                _oCompanySearchCriteria.ClassificationIDs = "220, 350"; //importer/exporter
            }

            // Make sure we have the latest search object updated before setting 
            // the search criteria control
            StoreCriteria();

            // Set Search Criteria User Control
            ucCompanySearchCriteriaControl.CompanySearchCriteria = _oCompanySearchCriteria;
        }

        protected void SetPopover()
        {
            popCompanyName.Attributes.Add("data-bs-title", Resources.Global.WhatIsThisCompanyName);
        }

        private const string IMG_MICROSLIDER = "<img src=\"{3}\" data-href=\"{0}?AdCampaignID={1}&AdAuditTrailID={2}\" />";
        private const string SQL_MICROSLIDER_ADS =
             @"SELECT pradc_AdCampaignID, pracf_FileName
                    FROM PRAdCampaign WITH (NOLOCK)
	                INNER JOIN PRAdCampaignFile WITH (NOLOCK) ON pracf_AdCampaignID = pradc_AdCampaignID
                WHERE 
		            pradc_AdCampaignTypeDigital = @AdCampaignTypeDigital
		            AND GETDATE() BETWEEN pradc_StartDate AND pradc_EndDate
                AND pradc_IndustryType LIKE @IndustryType
                AND pradc_Language LIKE @Language
                AND pradc_CreativeStatus='A'
            ORDER BY pradc_Sequence, pradc_StartDate DESC";

        protected void PopulateMicroslider()
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("IndustryType", "%," + _oUser.prwu_IndustryType + ",%"));
            oParameters.Add(new ObjectParameter("Language", "%," + _oUser.prwu_Culture + ",%"));

            if (_oUser.prwu_AccessLevel == PRWebUser.SECURITY_LEVEL_TRADE_ASSOCIATION_ACCESS)
            {
                oParameters.Add(new ObjectParameter("AdCampaignTypeDigital", "BBOSSliderITA"));
            }
            else
                oParameters.Add(new ObjectParameter("AdCampaignTypeDigital", "BBOSSlider"));

            int adAuditTrailID = 0;
            int adCount = 0;

            List<Int32> campaignIDs = new List<int>();
            List<Int32> topSpotCampaignIDs = new List<int>();

            AdUtils _adUtils = new AdUtils(_oLogger, _oUser);

            using (IDbTransaction oTrans = GetObjectMgr().BeginTransaction())
            {
                try
                {
                    StringBuilder microSliderImages = new StringBuilder();
                    using (IDataReader reader = GetDBAccess().ExecuteReader(SQL_MICROSLIDER_ADS, oParameters, CommandBehavior.CloseConnection, null))
                    {
                        while (reader.Read())
                        {
                            campaignIDs.Add(reader.GetInt32(0));
                            if (topSpotCampaignIDs.Count == 0)
                            {
                                topSpotCampaignIDs.Add(reader.GetInt32(0));
                            }

                            adCount++;
                            if ((!IsPRCoUser()) ||
                                (Configuration.AdCampaignTesting))
                            {
                                adAuditTrailID = _adUtils.InsertAdAuditTrail(reader.GetInt32(0),
                                                                6046,
                                                                adCount,
                                                                null,
                                                                0,
                                                                oTrans);
                            }

                            string szAdImageHTML = Configuration.AdImageVirtualFolder + reader.GetString(1).Replace('\\', '/');
                            object[] oArgs = {Configuration.AdClickURL,
                                    reader.GetInt32(0),
                                    adAuditTrailID,
                                    szAdImageHTML,
                                    string.Empty};

                            microSliderImages.Append(string.Format(IMG_MICROSLIDER, oArgs));
                        }
                    }

                    // Make sure the impression counts are updated.
                    // Exclude the PRCo company from any auditing
                    if ((!IsPRCoUser()) ||
                        (Configuration.AdCampaignTesting))
                    {
                        _adUtils.UpdateImpressionCount(campaignIDs, oTrans);
                        _adUtils.UpdateTopSpotCount(topSpotCampaignIDs, oTrans);
                    }

                    microslider.Text = microSliderImages.ToString();

                    oTrans.Commit();
                }
                catch(Exception)
                {
                    if (oTrans != null)
                    {
                        oTrans.Rollback();
                    }
                    throw;
                }
            }
        }

        /// <summary>
        /// Check users page level authorization
        /// </summary>
        /// <returns></returns>
        override protected bool IsAuthorizedForPage()
        {
            return _oUser.IsLimitado || _oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchPage).HasPrivilege;
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
        /// Loads all of the databound controls setting 
        /// thier default values.
        /// </summary>
        protected void LoadLookupValues()
        {
            string szSQLBindCommodity;
            ArrayList oParameters = new ArrayList();

            if (_oUser.prwu_Culture == SPANISH_CULTURE)
                szSQLBindCommodity = string.Format(SQL_BIND_COMMODITY, "prcm_Name_ES");
            else
                szSQLBindCommodity = string.Format(SQL_BIND_COMMODITY, "prcm_Name");

            //Fruit dropdown
            oParameters.Add(new ObjectParameter("RootParentID", 37)); //fruit
            ddlFruit.DataSource = GetDBAccess().ExecuteReader(szSQLBindCommodity, oParameters, CommandBehavior.CloseConnection, null);
            ddlFruit.DataValueField = "prcm_CommodityId";
            ddlFruit.DataTextField = "prcm_Name";
            ddlFruit.DataBind();
            ListItem oItemAny = new ListItem(Resources.Global.SelectAny, "");
            ddlFruit.Items.Insert(0, oItemAny);

            //Vegetable dropdown
            oParameters.Clear();
            oParameters.Add(new ObjectParameter("RootParentID", 291)); //vegetable
            ddlVegetable.DataSource = GetDBAccess().ExecuteReader(szSQLBindCommodity, oParameters, CommandBehavior.CloseConnection, null);
            ddlVegetable.DataValueField = "prcm_CommodityId";
            ddlVegetable.DataTextField = "prcm_Name";
            ddlVegetable.DataBind();
            oItemAny = new ListItem(Resources.Global.SelectAny, "");
            ddlVegetable.Items.Insert(0, oItemAny);

            //Herb dropdown
            oParameters.Clear();
            oParameters.Add(new ObjectParameter("RootParentID", 248)); //herb
            ddlHerb.DataSource = GetDBAccess().ExecuteReader(szSQLBindCommodity, oParameters, CommandBehavior.CloseConnection, null);
            ddlHerb.DataValueField = "prcm_CommodityId";
            ddlHerb.DataTextField = "prcm_Name";
            ddlHerb.DataBind();
            oItemAny = new ListItem(Resources.Global.SelectAny, "");
            ddlHerb.Items.Insert(0, oItemAny);

            //Country Dropdown
            oParameters.Clear();
            ddlCountry.DataSource = GetDBAccess().ExecuteReader(SQL_GET_COUNTRIES, oParameters, CommandBehavior.CloseConnection, null);
            ddlCountry.DataValueField = "prcn_CountryID";
            ddlCountry.DataTextField = "prcn_Country";
            ddlCountry.DataBind();
            ddlCountry.SelectedValue = _oCompanySearchCriteria.ListingCountryIDs;
            ddlCountry.Items.Insert(0, new ListItem("", ""));

            //State Dropdown
            oParameters.Clear();
            string szCountryID;
            if (string.IsNullOrEmpty(_oCompanySearchCriteria.ListingCountryIDs) || _oCompanySearchCriteria.ListingCountryIDs == "0")
                szCountryID = "1"; //USA
            else
                szCountryID = _oCompanySearchCriteria.ListingCountryIDs;

            BindState(szCountryID);
        }

        private void BindState(string szCountryID)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prst_CountryID", szCountryID));
            ddlState.DataSource = GetDBAccess().ExecuteReader(SQL_GET_STATES, oParameters, CommandBehavior.CloseConnection, null);
            ddlState.DataValueField = "prst_StateID";
            ddlState.DataTextField = "prst_State";
            ddlState.DataBind();

            ddlState.Items.Insert(0, new ListItem("", ""));

            ddlState.SelectedValue = _oCompanySearchCriteria.ListingStateIDs;
        }

        const string SQL_BIND_COMMODITY =
            @"SELECT prcm_CommodityId, {0} [prcm_Name]
              FROM PRCommodity WITH (NOLOCK) 
              WHERE prcm_RootParentID=@RootParentID 
                AND prcm_Level <=3 ORDER BY {0}";

        const string SQL_GET_COUNTRIES =
            @"SELECT prcn_CountryID, prcn_Country FROM PRCountry WITH(NOLOCK) WHERE prcn_CountryID > 0 ORDER BY prcn_Country";

        const string SQL_GET_STATES =
            @"SELECT prst_StateID, prst_State FROM PRState WITH(NOLOCK) WHERE prst_CountryID = @prst_CountryID and prst_State IS NOT NULL ORDER BY prst_State";

        /// <summary>
        /// Populates the form controls.
        /// </summary>
        protected void PopulateForm()
        {
            // Company Name
            txtCompanyName.Text = _oCompanySearchCriteria.CompanyName;

            //Commodities
            if (_oCompanySearchCriteria.CommodityIDs != null)
            {
                string[] aszCommodities = _oCompanySearchCriteria.CommodityIDs.Split(CompanySearchBase.achDelimiter);
                foreach (string szCommodityID in aszCommodities)
                {
                    ddlFruit.SelectedValue = szCommodityID;
                    ddlVegetable.SelectedValue = szCommodityID;
                    ddlHerb.SelectedValue = szCommodityID;
                }
            }
        }

        /// <summary>
        /// Collects and stores the search criteria on the users current company search
        /// criteria object 
        /// </summary>
        protected override void StoreCriteria()
        {
            // Save Company Search Criteria

            // Company Name 
            _oCompanySearchCriteria.CompanyName = txtCompanyName.Text.Trim();

            _oCompanySearchCriteria.ListingCountryIDs = ddlCountry.SelectedValue;
            _oCompanySearchCriteria.ListingStateIDs = ddlState.SelectedValue;

            _oCompanySearchCriteria.CommodityIDs = CommodityIDList();

            base.StoreCriteria();
        }

        private string CommodityIDList()
        {
            string szCommodityIDList = "";
            if (!string.IsNullOrEmpty(ddlFruit.SelectedValue))
                szCommodityIDList += ddlFruit.SelectedValue + ",";
            if (!string.IsNullOrEmpty(ddlVegetable.SelectedValue))
                szCommodityIDList += ddlVegetable.SelectedValue + ",";
            if (!string.IsNullOrEmpty(ddlHerb.SelectedValue))
                szCommodityIDList += ddlHerb.SelectedValue + ",";

            if (szCommodityIDList.EndsWith(","))
                szCommodityIDList = szCommodityIDList.Substring(0, szCommodityIDList.Length - 1);

            return szCommodityIDList;
        }

        /// <summary>
        /// Make sure our ToggleInitialState JS function gets
        /// called to set come control states appropriately.
        /// </summary>
        public override void PreparePageFooter()
        {
            base.PreparePageFooter();
            Page.ClientScript.RegisterStartupScript(this.GetType(), "OnPageLoadJS", "ToggleInitialState();", true);
        }

        protected void ddlCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            _oCompanySearchCriteria.ListingCountryIDs = ddlCountry.SelectedValue;
            Response.Redirect(Request.RawUrl);
        }

        /// <summary>
        /// Clears and stores the search criteria on the users current company search
        /// criteria object 
        /// </summary>
        protected override void ClearCriteria()
        {
            // Clear the corresponding Company Search Criteria object and reload the page

            txtCompanyName.Text = "";

            ddlFruit.SelectedIndex = 0;
            ddlVegetable.SelectedIndex = 0;
            ddlHerb.SelectedIndex = 0;

            ddlCountry.SelectedIndex = -1;
            ddlState.SelectedIndex = -1;

            _szRedirectURL = PageConstants.LIMITADO_SEARCH;
        }

        protected void btnLogoff_Click(object sender, EventArgs e)
        {
            FormsAuthentication.SignOut();
            Session.Abandon();
            Response.Redirect("#");
        }
    }
}