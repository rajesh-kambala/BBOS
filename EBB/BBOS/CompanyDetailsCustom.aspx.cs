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

 ClassName: CompanyDetailsCustom.aspx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Displays the company updates for the current company. Allows the user
    /// to filter the list, view the Company Listing, and generate reports.
    /// </summary>
    public partial class CompanyDetailsCustom : CompanyDetailsBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            // Set page title, sub-title
            SetPageTitle(Resources.Global.CompanyDetails, Resources.Global.Notes);

            // Add company submenu to this page
            SetSubmenu("btnCompanyDetailsCustom");

            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_TOGGLE_FUNCTIONS_FILE));
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_FUNCTIONS2_FILE));
            //Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_VALIDATION_FILE));
            EnableFormValidation();

            if (!IsPostBack)
            {
                txtDateFrom.Attributes.Add("placeholder", GetCultureInfo_ShortDatePattern().ToUpper());
                txtDateTo.Attributes.Add("placeholder", GetCultureInfo_ShortDatePattern().ToUpper());

                SetSortField(gvNotes, "prwun_NoteUpdatedDateTime");
                SetSortAsc(gvNotes, false);

                hidCompanyID.Text = hidCompanyID.Text = GetRequestParameter("CompanyID", true, true);
                PopulateForm();

                ApplySecurity(btnNoteReport, SecurityMgr.Privilege.ReportNotes);
                if(_oUser.HasPrivilege(SecurityMgr.Privilege.ReportNotes).Enabled)
                    btnNoteReport.OnClientClick = "return confirmSelect('" + Resources.Global.Note + "', 'cbNoteID')";  //btnNoteReport.Attributes.Add("onclick", "return confirmSelect('" + Resources.Global.Note + "', 'cbNoteID')");

                ApplySecurity(btnAddNote, SecurityMgr.Privilege.Notes);
            }

            SetRequestParameter("CompanyIDList", hidCompanyID.Text);
        }

        protected void PopulateForm()
        {
            PopulateNotes();
            ApplyReadOnlyCheck(btnAddNote);

            //Defect 6769 - Enforce 75 shared notes for L200
            //Madison changed to 500
            hidIsLumber_STANDARD.Value = _oUser.IsLumber_STANDARD().ToString();
            hidNotesShareCompanyMax.Value = Configuration.NotesShareCompanyMax_L200.ToString(); //500
            hidNotesShareCompanyCount.Value = _oUser.GetNotesShareCompanyCount().ToString();

            //Madison
            hidIsLumber_BASIC_PLUS.Value = _oUser.IsLumber_BASIC_PLUS().ToString();
            hidNotesShareCompanyMax_BASIC_PLUS.Value = Configuration.NotesShareCompanyMax_L150.ToString(); //250
        }

        /// <summary>
        /// Populates the Notes section of the page
        /// </summary>
        protected void PopulateNotes()
        {
            NoteSearchCriteria searchCriteria = new NoteSearchCriteria();
            searchCriteria.WebUser = _oUser;
            searchCriteria.AssociatedID = Convert.ToInt32(hidCompanyID.Text);
            searchCriteria.AssociatedType = "C";

            searchCriteria.Keywords = txtKeyWords.Text;
            searchCriteria.DateFrom = UIUtils.GetDateTime(txtDateFrom.Text, GetCultureInfo(_oUser));
            searchCriteria.DateTo = UIUtils.GetDateTime(txtDateTo.Text, GetCultureInfo(_oUser));
            searchCriteria.PrivateOnly = cbPrivateOnly.Checked;

            searchCriteria.SortField = GetSortField(gvNotes);
            searchCriteria.SortAsc = GetSortAsc(gvNotes);

            gvNotes.DataSource = new PRWebUserNoteMgr(_oLogger, _oUser).Search(searchCriteria);
            gvNotes.DataBind();
            EnableBootstrapFormatting(gvNotes);
        }

        protected void btnFilterOnClick(object sender, EventArgs e)
        {
            PopulateForm();
        }

        protected void btnClearOnClick(object sender, EventArgs e)
        {
            Session.Remove("NotesSearchCriteria");

            txtKeyWords.Text = string.Empty;
            txtDateFrom.Text = string.Empty;
            txtDateTo.Text = string.Empty;
            cbPrivateOnly.Checked = false;

            PopulateNotes();
        }

        /// <summary>
        /// Helper method that helps with bi-directional sorting
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void GridView_Sorting(Object sender, GridViewSortEventArgs e)
        {
            SetSortingAttributes((GridView)sender, e);
            PopulateForm();
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

            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                ApplyReadOnlyCheck((LinkButton)e.Row.Cells[7].Controls[1]);

                LinkButton EditNote = (LinkButton)e.Row.FindControl("EditNote");
                if (!_oUser.HasPrivilege(SecurityMgr.Privilege.Notes).HasPrivilege)
                    EditNote.Enabled = false;
            }
        }

        protected override string GetCompanyID()
        {
            if (IsPostBack)
            {
                return hidCompanyID.Text;
            }
            else
            {
                return GetRequestParameter("CompanyID");
            }
        }

        protected override CompanyDetailsHeader GetCompanyDetailsHeader()
        {
            return ucCompanyDetailsHeader;
        }

        protected void btnAddNote_Click(object sender, EventArgs e)
        {
            displayNoteIFrame(string.Empty);
        }

        protected void btnEditNote_Click(object sender, EventArgs e)
        {
            string noteID = ((LinkButton)sender).CommandArgument;
            displayNoteIFrame("?NoteID=" + noteID);
        }

        protected void displayNoteIFrame(string parms)
        {
            Session["CompanyHeader_szCompanyID"] = hidCompanyID.Text;
            ifrmNoteEdit.Attributes.Add("src", PageConstants.NOTE_EDIT + parms);
            ModalPopupExtender3.Show();
        }

        protected void btnNoteReport_Click(object sender, EventArgs e)
        {
            string noteIDList = GetRequestParameter("cbNoteID", true);
            GenerateNotesReport(noteIDList);
        }

        override protected bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.CompanyDetailsCustomPage).Enabled;
        }
    }
}