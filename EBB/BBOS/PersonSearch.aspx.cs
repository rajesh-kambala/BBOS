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

 ClassName: PersonSearch.aspx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/

using System;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;


namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This page allows the user to specify criteria and view search results for Person records.  
    /// The search criteria will include Last Name, First Name, Title, Phone, Email, Company Name,
    /// and BB #.
    /// 
    /// If a saved search is loaded, it must either be private and owned by the current user or public 
    /// and owned by the user's enterprise.
    /// </summary>
    public partial class PersonSearch : PersonSearchBase
    {
        /// <summary>
        /// Calls page functions required to build and process this page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            SetPageTitle(Resources.Global.PeopleSearch, "Person Criteria");

            SetSubmenu("btnPerson");
            SetPopover();

            if (!IsPostBack)
            {
                LoadLookupValues();
                PopulateForm();
            }

            // Make sure we have the latest search object updated before setting 
            // the search criteria control
            StoreCriteria();

            // Set Search Criteria User Control
            ucPersonSearchCriteriaControl.PersonSearchCriteria = _oPersonSearchCriteria;
        }

        protected void SetPopover()
        {
            popIndustryType.Attributes.Add("data-bs-title", Resources.Global.IndustryTypeText);
            popBBNumber.Attributes.Add("data-bs-title", Resources.Global.BBNumberDefinition);
        }

        /// <summary>
        /// Populates the criteria page with the contents of the
        /// current search.
        /// </summary>
        protected void PopulateForm()
        {
            txtLastName.Text = _oPersonSearchCriteria.LastName;
            txtFirstName.Text = _oPersonSearchCriteria.FirstName;
            txtTitle.Text = _oPersonSearchCriteria.Title;
            txtPhoneAreaCode.Text = _oPersonSearchCriteria.PhoneAreaCode;
            txtPhoneNumber.Text = _oPersonSearchCriteria.PhoneNumber;
            txtEmail.Text = _oPersonSearchCriteria.Email;
            txtCompanyName.Text = _oPersonSearchCriteria.CompanyName;
            txtBBNum.Text = UIUtils.GetStringFromInt(_oPersonSearchCriteria.BBID, true);
            SetListValues(cblRole, _oPersonSearchCriteria.Role);

            List<Control> lRoleControls = new List<Control>();
            lRoleControls.Add(lblRole);
            lRoleControls.Add(cblRole);
            ApplySecurity(lRoleControls, SecurityMgr.Privilege.PersonSearchByRole);

            BindLookupValues(ddlIndustryType, GetReferenceData(REF_DATA_INDUSTRY_TYPE), _oPersonSearchCriteria.IndustryType, true);
            //rblIndustryType.Items.Insert(0, new ListItem("<All>", string.Empty));

            ApplySecurity(trIndustry, ddlIndustryType, SecurityMgr.Privilege.PersonSearchByIndustry);
        }

        protected void LoadLookupValues()
        {
            BindLookupValues(cblRole, GetReferenceData("peli_PRRole"));
        }

        /// <summary>
        /// Collects and stores the search criteria on the users current person search
        /// criteria object and stores the current person search criteria object as part of 
        /// the current users web user search criteria object        
        /// </summary>
        override protected void StoreCriteria()
        {
            _oPersonSearchCriteria.LastName = txtLastName.Text;
            _oPersonSearchCriteria.FirstName = txtFirstName.Text;
            _oPersonSearchCriteria.Title = txtTitle.Text;
            _oPersonSearchCriteria.PhoneAreaCode = txtPhoneAreaCode.Text;
            _oPersonSearchCriteria.PhoneNumber = txtPhoneNumber.Text;
            _oPersonSearchCriteria.Email = txtEmail.Text;
            _oPersonSearchCriteria.CompanyName = txtCompanyName.Text;
            _oPersonSearchCriteria.Role = GetSelectedValues(cblRole);
            _oPersonSearchCriteria.IndustryType = ddlIndustryType.SelectedValue;

            if (txtBBNum.Text.Length > 0)
                _oPersonSearchCriteria.BBID = Convert.ToInt32(txtBBNum.Text);
            else
                _oPersonSearchCriteria.BBID = 0;

            base.StoreCriteria();
        }

        /// <summary>
        /// Clears the form values and update the person search criteria object.  
        /// Restores the updated person search criteria object with
        /// the corresponding values cleared.  
        /// </summary>
        override protected void ClearCriteria()
        {
            txtLastName.Text = "";
            txtFirstName.Text = "";
            txtTitle.Text = "";
            txtPhoneAreaCode.Text = "";
            txtPhoneNumber.Text = "";
            txtEmail.Text = "";
            txtCompanyName.Text = "";
            txtBBNum.Text = "";
            ddlIndustryType.SelectedIndex = 0;

            //Uncheck all roles
            foreach (ListItem item in cblRole.Items)
                item.Selected = false;

            _szRedirectURL = PageConstants.PERSON_SEARCH;
        }
    }
}
