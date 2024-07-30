/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2022-2022

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CompanySearch.aspx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/

using PRCo.BBOS.UI.Web;
using System;
using System.Data;
using System.Web.UI.WebControls;

namespace BBOSMobileSales
{
    public partial class CompanySearch : SearchBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if (!IsPostBack)
            {
                LoadLookupValues();
                PopulateForm();
            }
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
            BindLookupValues(ddlListingStatus, GetReferenceData("comp_PRListingStatus_MS"));
            ddlListingStatus.Items.Insert(0, new ListItem("Listing Status", ""));

            BindLookupValues(ddlIndustry, GetReferenceData("comp_PRIndustryTypeMS"));
            ddlIndustry.Items.Insert(0, new ListItem("Industry", ""));

            BindLookupValues(ddlSalesTerritory, GetReferenceData("prci_SalesTerritory"), false);
            ddlSalesTerritory.Items.Insert(0, new ListItem("Sales Territory", ""));

            DataTable dtStateList = GetStateList();
            DataView dvStateList = dtStateList.DefaultView;
            dvStateList.RowFilter = "prst_CountryId = 1";
            ddlState.DataSource = dvStateList;
            ddlState.DataTextField = "prst_State";
            ddlState.DataValueField = "prst_StateId";
            ddlState.DataBind();
            ddlState.Items.Insert(0, new ListItem("Listing State", ""));
        }

        /// <summary>
        /// Populates the form controls.
        /// </summary>
        protected void PopulateForm()
        {
            hidItemsPerPage.Value = Configuration.ItemsPerPage.ToString();
        }

              /// <summary>
        /// Clears and stores the search criteria on the users current company search
        /// criteria object 
        /// </summary>
        protected void ClearCriteria()
        {
            // Clear the corresponding Company Search Criteria object and reload the page
            txtBBNum.Text = "";
            txtCompanyName.Text = "";
            ddlListingStatus.SelectedIndex = -1;
            ddlIndustry.SelectedIndex = -1;
            ddlState.SelectedIndex = -1;
            ddlSalesTerritory.SelectedIndex = -1;

            _szRedirectURL = PageConstants.COMPANY_SEARCH;
        }
    }
}