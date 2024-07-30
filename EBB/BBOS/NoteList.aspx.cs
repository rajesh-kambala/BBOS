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

 ClassName: NoteList
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using System.Web.UI.HtmlControls;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Presents a list of notes to the user.  This includes global
    /// public notes and thier own private notes.  The user can also
    /// filter the list.
    /// </summary>
    public partial class NoteList : PageBase
    {
        /// <summary>
        /// This page allows the user to browse existing notes regardless
        /// of what object they are associated with.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if(_oUser.prwu_HQID == 0)
                Response.Redirect(PageConstants.BBOS_HOME, true);

            SetPageTitle(Resources.Global.Notes);

            if (!IsPostBack)
            {
                txtDateFrom.Attributes.Add("placeholder", GetCultureInfo_ShortDatePattern().ToUpper());
                txtDateTo.Attributes.Add("placeholder", GetCultureInfo_ShortDatePattern().ToUpper());

                LoadLookupValues();

                SetSortField(gvNotes, "prwun_NoteUpdatedDateTime");
                SetSortAsc(gvNotes, false);

                PopulateForm();
            }

            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_FUNCTIONS2_FILE));
            //Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_VALIDATION_FILE));
            EnableFormValidation();

            ApplySecurity(btnNoteReport, SecurityMgr.Privilege.ReportNotes);
            if (_oUser.HasPrivilege(SecurityMgr.Privilege.ReportNotes).Enabled)
                btnNoteReport.Attributes.Add("onclick", "return confirmSelect('" + Resources.Global.Note + "', 'cbNoteID')");
        }

        /// <summary>
        /// Loads all of the databound controls setting 
        /// thier default values.
        /// </summary>  
        protected void LoadLookupValues()
        {
        }

        protected void PopulateForm()
        {
            NoteSearchCriteria searchCriteria = null;
            if ((!String.IsNullOrEmpty(GetRequestParameter("ExecuteLastSearch", false))) &&
                (Session["NotesSearchCriteria2"] != null))
            {
                searchCriteria = (NoteSearchCriteria)Session["NotesSearchCriteria2"];
                Session.Remove("NotesSearchCriteria2");

                txtKeyWords.Text = searchCriteria.Keywords;
                txtDateFrom.Text = UIUtils.GetStringFromDate(searchCriteria.DateFrom);
                txtDateTo.Text = UIUtils.GetStringFromDate(searchCriteria.DateTo);
                txtName.Text = searchCriteria.Subject;
                cbPrivateOnly.Checked = searchCriteria.PrivateOnly;
            }
            else
            {
                searchCriteria = new NoteSearchCriteria();
                searchCriteria.WebUser = _oUser;
                searchCriteria.Keywords = txtKeyWords.Text;
                searchCriteria.DateFrom = UIUtils.GetDateTime(txtDateFrom.Text, GetCultureInfo(_oUser));
                searchCriteria.DateTo = UIUtils.GetDateTime(txtDateTo.Text, GetCultureInfo(_oUser));
                searchCriteria.AssociatedType = "C";
                searchCriteria.Subject = txtName.Text;
                searchCriteria.PrivateOnly = cbPrivateOnly.Checked;

                searchCriteria.SortField = GetSortField(gvNotes);
                searchCriteria.SortAsc = GetSortAsc(gvNotes);
            }

            //((EmptyGridView)gvNotes).EmptyTableRowText = GetNoResultsFoundMsg(Resources.Global.Notes);
            gvNotes.ShowHeaderWhenEmpty = true;
            gvNotes.EmptyDataText = GetNoResultsFoundMsg(Resources.Global.Notes);

            gvNotes.DataSource = new PRWebUserNoteMgr(_oLogger, _oUser).Search(searchCriteria);
            gvNotes.DataBind();
            EnableBootstrapFormatting(gvNotes);

            if(_oUser.prwu_Culture == "es-mx")
                lblRecordCount.Text = gvNotes.Rows.Count + " NOTAS ENCONTRADAS";
            else
                lblRecordCount.Text = string.Format(Resources.Global.RecordCountFoundMsg, gvNotes.Rows.Count, Resources.Global.Notes);

            Session["NotesSearchCriteria"] = searchCriteria;
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
                ApplyReadOnlyCheck((LinkButton)e.Row.Cells[10].Controls[1]);
            }
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
            txtName.Text = string.Empty;
            cbPrivateOnly.Checked = false;
            PopulateForm();
        }

        protected void btnEditNote_Click(object sender, EventArgs e)
        {
            string noteID = ((LinkButton)sender).CommandArgument;
            displayNoteIFrame("?Return=nl&NoteID=" + noteID);
        }

        protected void displayNoteIFrame(string parms)
        {
            ifrmNoteEdit.Attributes.Add("src", PageConstants.NOTE_EDIT + parms);
            ModalPopupExtender3.Show();
        }

        protected void btnNoteReport_Click(object sender, EventArgs e)
        {
            string noteIDList = GetRequestParameter("cbNoteID", true);
            GenerateNotesReport(noteIDList);
        }

        protected void btnDeleteAll_Click(object sender, EventArgs e)
        {
            string noteIDList = GetRequestParameter("cbNoteID", false);

            if (String.IsNullOrEmpty(noteIDList))
                return;

            foreach (string strNoteID in noteIDList.Split(','))
            {
                //Delete each individual note
                IPRWebUserNote _note = (IPRWebUserNote)new PRWebUserNoteMgr(_oLogger, _oUser).GetObjectByKey(Convert.ToInt32(strNoteID));
                _note.Delete();
                Response.Redirect(Page.Request.RawUrl, false);
            }
        }

        /// <summary>
        /// Only members level 3 or greater can access
        /// this page.
        /// </summary>
        /// <returns></returns>
        protected override bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.Notes).HasPrivilege;
        }

        protected override bool IsAuthorizedForData()
        {
            return true;
        }

        public override bool EnableJSClientIDTranslation()
        {
            return true;
        }
    }
}