/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CompanyNotes
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using PRCo.EBB.BusinessObjects;
using System;
using System.Collections;
using System.Data;
using System.Diagnostics;
using System.Security.Cryptography;
using System.Web;
using System.Web.UI.WebControls;
using TSI.BusinessObjects;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Displays company data and listing.
    /// </summary>
    public partial class CompanyNotes : CompanyDetailsBase
    {
        protected CompanyData _ocd;
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
            Page.Title = Resources.Global.BlueBookService;
            ((BBOS)Master).HideOldTopMenu();
            EnableFormValidation();

            GetOcd();

            if (!IsPostBack)
            {
                txtDateFrom.Attributes.Add("placeholder", GetCultureInfo_ShortDatePattern().ToUpper());
                txtDateTo.Attributes.Add("placeholder", GetCultureInfo_ShortDatePattern().ToUpper());

                SetSortField(gvNotes, "prwun_NoteUpdatedDateTime");
                SetSortAsc(gvNotes, false);

                hidCompanyID.Text = GetRequestParameter("CompanyID", true, true);

                if (HandleLumberRedirect(_ocd.szIndustryType, hidCompanyID.Text, PageConstants.COMPANY_DETAILS_CUSTOM))
                    return;

                PopulateForm();
            }

            RedirectToHomeIfCompanyMissing(hidCompanyID.Text);

            ApplySecurity(btnNoteReport, SecurityMgr.Privilege.ReportNotes);
            if (_oUser.HasPrivilege(SecurityMgr.Privilege.ReportNotes).Enabled)
                btnNoteReport.OnClientClick = "return confirmSelect('" + Resources.Global.Note + "', 'cbNoteID')";  //btnNoteReport.Attributes.Add("onclick", "return confirmSelect('" + Resources.Global.Note + "', 'cbNoteID')");

            ApplySecurity(btnAddNote, SecurityMgr.Privilege.Notes);

            //Set user controls
            ucSidebar.WebUser = _oUser;
            ucSidebar.CompanyID = UIUtils.GetString(hidCompanyID.Text);
            ucCompanyHero.WebUser = _oUser;
            ucCompanyHero.CompanyID = UIUtils.GetString(hidCompanyID.Text);
            ucCompanyBio.WebUser = _oUser;
            ucCompanyBio.CompanyID = UIUtils.GetString(hidCompanyID.Text);

            SetRequestParameter("CompanyIDList", hidCompanyID.Text);
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

        /// <summary>
        /// Populates the form controls for the specified
        /// company
        /// </summary>
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

            //LocalSource
            if (_ocd.bLocalSource)
            {
                ucCompanyDetailsHeaderMeister.MeisterVisible = true;
            }
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

        public CompanyData GetOcd()
        {
            if (_ocd == null)
                _ocd = PageControlBaseCommon.GetCompanyData(GetRequestParameter("CompanyID", true, true), _oUser, GetDBAccess(), GetObjectMgr());
            return _ocd;
        }
    }
}