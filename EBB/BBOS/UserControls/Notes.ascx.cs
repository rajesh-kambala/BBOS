/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2019

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: Notes
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// User control that displays the company header, or "banner" information
    /// on each of the company detail pages.
    /// 
    /// NOTE: This user control is also being used to display the company header information
    /// on each of the edit my company wizard pages.
    /// </summary>
    public partial class Notes : UserControlBase
    {
        protected string _szCompanyID;
        private bool _bCondensed = false;
        
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
        }

        public string companyID
        {
            set
            {
                _szCompanyID = value;
                PopulateNotes(UIUtils.GetInt(_szCompanyID));
            }
            get { return _szCompanyID; }
        }

        public bool Condensed
        {
            set { _bCondensed = value; }
            get { return _bCondensed; }
        }

        #region "SQL Statements"
        #endregion

        protected void PopulateNotes(int companyID)
        {
            if (!WebUser.HasPrivilege(SecurityMgr.Privilege.Notes).HasPrivilege)
            {
                Visible = false;
                return;
            }

            NoteSearchCriteria searchCriteria = new NoteSearchCriteria();
            searchCriteria.WebUser = WebUser;
            searchCriteria.AssociatedID = companyID;
            searchCriteria.AssociatedType = "C";

            searchCriteria.SortField = "prwun_NoteUpdatedDateTime";
            searchCriteria.SortAsc = false;

            IBusinessObjectSet results = new PRWebUserNoteMgr(GetLogger(), WebUser).Search(searchCriteria);

            IBusinessObjectSet displaySet = new BusinessObjectSet();
            int max = Utilities.GetIntConfigValue("SummaryNewsArticlesDisplayed", 3);
            if (results.Count < max)
            {
                max = results.Count;
            }

            for (int i = 0; i < max; i++)
            {
                displaySet.Add(results[i]);
            }

            litViewAllNews.Text = Resources.Global.ViewAll + " " + results.Count.ToString();
            lnkViewAllNews.PostBackUrl = "~/" + string.Format(PageConstants.COMPANY_DETAILS_CUSTOM, companyID);

            gvNotes.DataSource = displaySet;
            gvNotes.DataBind();
            EnableBootstrapFormatting(gvNotes);

            if(_bCondensed)
            {
                btnAddNote.Visible = false;
                lnkViewAllNews.Visible = false;
            }

            //Defect 6769 - Enforce 75 shared notes for L200 STANDARD
            //Madison changed to 500
            hidIsLumber_STANDARD.Value = WebUser.IsLumber_STANDARD().ToString();
            hidNotesShareCompanyMax.Value = Configuration.NotesShareCompanyMax_L200.ToString(); //500
            hidNotesShareCompanyCount.Value = WebUser.GetNotesShareCompanyCount().ToString();

            //Madison
            hidIsLumber_BASIC_PLUS.Value = WebUser.IsLumber_BASIC_PLUS().ToString();
            hidNotesShareCompanyMax_BASIC_PLUS.Value = Configuration.NotesShareCompanyMax_L150.ToString(); //250
            if(WebUser.prwu_HQID == 0)
            {
                btnAddNote.Enabled = false;
                lnkViewAllNews.Enabled = false;
            }
        }

        protected void gvNotes_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                if(_bCondensed)
                {
                    LinkButton x = (LinkButton)e.Row.FindControl("viewMore");
                    x.Visible = false;
                }

                LinkButton Print = (LinkButton)e.Row.FindControl("Print");
                if (!WebUser.HasPrivilege(SecurityMgr.Privilege.ReportNotes).HasPrivilege)
                {
                    Print.Enabled = false;
                }
            }
        }

        protected void btnPrintNote_Click(object sender, EventArgs e)
        {
            string reportID = ((LinkButton)sender).CommandArgument.ToString();
            Session["NoteIDList"] = reportID;
            Response.Redirect(PageConstants.FormatFromRoot(PageConstants.GET_REPORT, GetReport.NOTES_REPORT));
        }

        protected void btnAddNote_Click(object sender, EventArgs e)
        {
            displayNoteIFrame(string.Empty);
        }

        protected void displayNoteIFrame(string parms)
        {
            Session["CompanyHeader_szCompanyID"] = companyID;
            ifrmNoteEdit.Attributes.Add("src", "~/NoteEdit.aspx?Return=c" + parms);
            ModalPopupExtender3.Show();
        }
    }
}