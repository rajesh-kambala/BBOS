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

 ClassName: CompanySearchCustom
 Description:

 Notes:

***********************************************************************
***********************************************************************/

using System;
using System.Collections;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;
using System.Web.UI.HtmlControls;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This page contains the custom search fields for searching companies
    /// including the custom identifier, company has notes, and search by watchdog
    /// lists.
    /// </summary>
    public partial class CompanySearchCustom : CompanySearchBase
    {
        private bool bResetUserList = false;
        private bool bResetCustomFields = false;

        /// <summary>
        /// Calls page functions required to build and process this page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            // Set page title, sub-title, and include any additonal javascript
            // files required for this page.
            SetPageTitle(Resources.Global.CompanySearch, Resources.Global.CustomFilters);
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_TOGGLE_FUNCTIONS_FILE));
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_FUNCTIONS2_FILE));

            // Add company submenu to this page
            SetSubmenu("btnCustom");
            SetPopover();

            if (!IsPostBack)
            {
                LoadLookupValues();

                PopulateForm();
                SetVisibility();

                bResetUserList = true;
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

            _oUser = (IPRWebUser)Session["oUser"];
            if (_oUser == null)
                Response.Redirect("Default.aspx");

            if (!String.IsNullOrEmpty(Request["SearchID"]))
                Int32.TryParse(GetRequestParameter("SearchID"), out _iSearchID);
            else
                _iSearchID = 0;

            RetrieveObject();


            PopulateCustomFields();
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
            return _oUser.HasPrivilege(SecurityMgr.Privilege.CompanySearchCustomPage).HasPrivilege;
        }

        /// <summary>
        /// Check users control/data level authorization
        /// </summary>
        /// <returns></returns>
        protected override bool IsAuthorizedForData()
        {

            // Notes
            List<Control> lHasNotesControls = new List<Control>();
            //lHasNotesControls.Add(lblHasNotes);
            lHasNotesControls.Add(chkCompanyHasNotes);
            ApplySecurity(lHasNotesControls, SecurityMgr.Privilege.CompanySearchByHasNotes);


            // Watchdog list
            List<Control> lWatchdogControls = new List<Control>();
            lWatchdogControls.Add(pnlWatchdogList);
            ApplySecurity(lWatchdogControls, SecurityMgr.Privilege.CompanySearchByWatchdogList);

            // Save Search Criteria requires Level 3 access
            List<Control> lSaveSearchControls = new List<Control>();
            lSaveSearchControls.Add(btnSaveSearch);
            lSaveSearchControls.Add(btnLoadSearch);
            ApplySecurity(lSaveSearchControls, SecurityMgr.Privilege.SaveSearches);
            ApplyReadOnlyCheck(btnSaveSearch);
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
            // Bind Industry Type control
            BindLookupValues(rblIndustryType, GetReferenceData(REF_DATA_INDUSTRY_TYPE));
            ModifyIndustryType(rblIndustryType);
        }

        /// <summary>
        /// Populates the form controls.
        /// </summary>
        protected void PopulateForm()
        {
            // Set Company Custom Search Information

            // Industry Type
            SetListDefaultValue(rblIndustryType, _oCompanySearchCriteria.IndustryType);

            // Company Has Notes
            chkCompanyHasNotes.Checked = _oCompanySearchCriteria.HasNotes;

            // Watchdog Lists
            PopulateUserLists(gvUserList);
            //EnableRowHighlight(gvUserList);
        }

        /// <summary>
        /// Collects and stores the search criteria on the users current company search
        /// criteria object
        /// </summary>
        protected override void StoreCriteria()
        {
            // Save Company Search Criteria
            // Industry Type
            if (_oUser.prwu_IndustryType != GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                _oCompanySearchCriteria.IndustryType = rblIndustryType.SelectedValue;
            }
            // Company Has Notes
            _oCompanySearchCriteria.HasNotes = chkCompanyHasNotes.Checked;

            // Store User List selections
            if (!bResetUserList)
            {
                _oCompanySearchCriteria.UserListIDs = GetRequestParameter("cbUserListID", false);
            }


            if (_oCompanySearchCriteria.CustomFieldSearchCriteria != null)
            {
                _oCompanySearchCriteria.CustomFieldSearchCriteria.Clear();
            }

            if (!bResetCustomFields)
            {
                IBusinessObjectSet customFields = new PRWebUserCustomFieldMgr(_oLogger, _oUser).GetByHQ(_oUser.prwu_HQID);
                foreach (IPRWebUserCustomField customField in customFields)
                {
                    CheckBox cbControl = (CheckBox)FindControlRecursive(this, "cbCustomDataField_" + customField.prwucf_WebUserCustomFieldID.ToString());
                    if ((cbControl != null) &&
                        (cbControl.Checked))
                    {
                        _oCompanySearchCriteria.AddCustomFieldSearchCriteria(customField.prwucf_WebUserCustomFieldID, true);
                    }

                    if (customField.prwucf_FieldTypeCode == "Text")
                    {
                        TextBox textControl = (TextBox)FindControlRecursive(this, "CustomDataField_" + customField.prwucf_WebUserCustomFieldID.ToString());

                        if ((cbControl != null) &&
                            (cbControl.Checked))
                        {
                            textControl.Enabled = false;
                        }
                        else
                        {
                            if (textControl != null && !string.IsNullOrEmpty(textControl.Text))
                            {
                                _oCompanySearchCriteria.AddCustomFieldSearchCriteria(customField.prwucf_WebUserCustomFieldID, textControl.Text);
                            }
                        }
                    }

                    if ((customField.prwucf_FieldTypeCode == "DDL") &&
                        (customField.GetLookupValues().Count > 0))
                    {
                        DropDownList ddlControl = (DropDownList)FindControlRecursive(this, "CustomDataField_" + customField.prwucf_WebUserCustomFieldID.ToString());

                        if (ddlControl != null)
                        {
                            if ((cbControl != null) &&
                                (cbControl.Checked))
                            {
                                ddlControl.Enabled = false;
                            }
                            else
                            {
                                if ((!string.IsNullOrEmpty(ddlControl.SelectedValue)) &&
                                    (ddlControl.SelectedValue != "0"))
                                {
                                    _oCompanySearchCriteria.AddCustomFieldSearchCriteria(customField.prwucf_WebUserCustomFieldID, Convert.ToInt32(ddlControl.SelectedValue));
                                }
                            }
                        }
                    }
                }
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

            // Has Notes
            chkCompanyHasNotes.Checked = false;

            // Clear User List selections
            bResetUserList = true;
            _oCompanySearchCriteria.UserListIDs = "";

            bResetCustomFields = true;
            if (_oCompanySearchCriteria.CustomFieldSearchCriteria != null)
            {
                _oCompanySearchCriteria.CustomFieldSearchCriteria.Clear();
            }

            _szRedirectURL = PageConstants.COMPANY_SEARCH_CUSTOM;
        }

        List<string> _lSelectedIDs = null;

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

        /// <summary>
        /// Helper method that helps with bi-directional sorting
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void UserListGridView_Sorting(Object sender, GridViewSortEventArgs e)
        {
            SetSortingAttributes((GridView)sender, e);

            _oCompanySearchCriteria.UserListIDs = GetRequestParameter("cbUserListID", false);
            PopulateUserLists(gvUserList);
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

        protected void SetVisibility()
        {
            ApplySecurity(pnlIndustryType, SecurityMgr.Privilege.CompanySearchByIndustry);
            //if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            //{
            //    pnlIndustryType.Visible = false;
            //}

        }

        protected void PopulateCustomFields()
        {
            if (!_oUser.HasPrivilege(SecurityMgr.Privilege.CustomFields).HasPrivilege)
            {
                return;
            }

            IBusinessObjectSet customFields = new PRWebUserCustomFieldMgr(_oLogger, _oUser).GetByHQ(_oUser.prwu_HQID);
            repCustomFields.DataSource = customFields;
            repCustomFields.DataBind();
        }

        protected void RepCustomFields_ItemCreated(Object Sender, RepeaterItemEventArgs e)
        {
            Label space = new Label();
            space.Text = "&nbsp;";

            // Execute the following logic for Items and Alternating Items.
            if (e.Item.ItemType == ListItemType.Item ||
                e.Item.ItemType == ListItemType.AlternatingItem)
            {
                //Get the MyClass instance for this repeater item
                IPRWebUserCustomField customField = (IPRWebUserCustomField)e.Item.DataItem;

                if ((customField.prwucf_FieldTypeCode == "DDL") &&
                    (customField.GetLookupValues().Count == 0))
                {
                    return;
                }

                PRWebUserCustomFieldSearchCriteria customFieldCriteria = null;
                if (_oCompanySearchCriteria.CustomFieldSearchCriteria != null)
                {
                    foreach (PRWebUserCustomFieldSearchCriteria customFieldCriteria2 in _oCompanySearchCriteria.CustomFieldSearchCriteria)
                    {
                        if (customField.prwucf_WebUserCustomFieldID == customFieldCriteria2.CustomFieldID)
                        {
                            customFieldCriteria = customFieldCriteria2;
                            break;
                        }
                    }
                }

                PlaceHolder ph = (PlaceHolder)e.Item.FindControl("phCustomField");

                HtmlGenericControl divRow = new HtmlGenericControl();
                divRow.Attributes["class"] = "row nomargin";
                divRow.TagName = "div";

                HtmlGenericControl divLabel = new HtmlGenericControl();
                divLabel.Attributes["class"] = "col-md-2 clr_blu";
                divLabel.TagName = "label";
                divLabel.InnerText = customField.prwucf_Label + ":";

                divRow.Controls.Add(divLabel);

                HtmlGenericControl divControl = new HtmlGenericControl();
                divControl.Attributes["class"] = "col-md-4 clr_blu";
                divControl.TagName = "div";
                if (customField.prwucf_FieldTypeCode == "DDL")
                {
                    IList lookupValues = customField.GetLookupValues();
                    lookupValues.Insert(0, new PRWebUserCustomFieldLookup());
                    ((PRWebUserCustomFieldLookup)lookupValues[0]).prwucfl_LookupValue = Resources.Global.SelectAny; //"[Any]"

                    DropDownList dropDownList = new DropDownList();
                    dropDownList.ID = "CustomDataField_" + customField.prwucf_WebUserCustomFieldID.ToString();
                    dropDownList.AutoPostBack = true;
                    dropDownList.DataSource = customField.GetLookupValues();
                    dropDownList.DataTextField = "prwucfl_LookupValue";
                    dropDownList.DataValueField = "prwucfl_WebUserCustomFieldLookupID";
                    dropDownList.CssClass = "form-control";
                    dropDownList.DataBind();

                    if (customFieldCriteria != null)
                    {
                        dropDownList.SelectedIndex = dropDownList.Items.IndexOf(dropDownList.Items.FindByValue(customFieldCriteria.CustomFieldLookupID.ToString()));
                    }

                    divControl.Controls.Add(dropDownList);
                    divRow.Controls.Add(divControl);
                    divLabel.Attributes["for"] = dropDownList.ID;
                }
                else
                {
                    TextBox textBox = new TextBox();
                    textBox.ID = "CustomDataField_" + customField.prwucf_WebUserCustomFieldID.ToString();
                    textBox.MaxLength = 100;
                    textBox.AutoPostBack = true;
                    textBox.CssClass = "form-control";

                    if (customFieldCriteria != null)
                    {
                        textBox.Text = customFieldCriteria.SearchValue;
                    }

                    divControl.Controls.Add(textBox);
                    divRow.Controls.Add(divControl);
                    divLabel.Attributes["for"] = textBox.ID;
                }


                HtmlGenericControl divMustHaveValue = new HtmlGenericControl();
                divMustHaveValue.Attributes["class"] = "panel-body pad10 noborder col-md-4 clr_blu label_top_5";
                divMustHaveValue.TagName = "div";

                CheckBox checkBox = new CheckBox();
                checkBox.ID = "cbCustomDataField_" + customField.prwucf_WebUserCustomFieldID.ToString();
                checkBox.AutoPostBack = true;

                if (customFieldCriteria != null)
                {
                    checkBox.Checked = customFieldCriteria.MustHaveValue;
                }

                HtmlGenericControl spanMustHaveValueText = new HtmlGenericControl();
                spanMustHaveValueText.TagName = "span";
                spanMustHaveValueText.InnerText = Resources.Global.MustHaveValue; // "Must have a value";

                divMustHaveValue.Controls.Add(checkBox);
                divMustHaveValue.Controls.Add(spanMustHaveValueText);
                divRow.Controls.Add(divMustHaveValue);

                ph.Controls.Add(divRow);
            }
        }
    }
}
