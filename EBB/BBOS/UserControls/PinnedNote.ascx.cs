/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2007-2019

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com
     
 ClassName: PinnedNote.ascx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/

using PRCo.EBB.BusinessObjects;
using System;
using System.Web.UI.WebControls;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web.UserControls
{
    public partial class PinnedNote: UserControlBase
    {
        private int _oCompanyID;
        private bool _bCondensed = false;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
        }

        public int companyID
        {
            set
            {
                _oCompanyID = value;
                PopulateKeyNote(_oCompanyID, WebUser);
            }
            get { return _oCompanyID; }
        }

        public bool Condensed
        {
            set { _bCondensed = value; }
            get { return _bCondensed; }
        }

        protected void PopulateKeyNote(int companyID, IPRWebUser oWebUser)
        {
            if (!oWebUser.HasPrivilege(SecurityMgr.Privilege.Notes).HasPrivilege)
            {
                Visible = false; //tdKeyNote.Visible = false;
                return;
            }

            //Defect 6769 - Enforce 75 shared notes for L200 STANDARD
            //Madison changed to 500
            hidIsLumber_STANDARD.Value = WebUser.IsLumber_STANDARD().ToString();
            hidNotesShareCompanyMax.Value = Configuration.NotesShareCompanyMax_L200.ToString(); //500
            hidNotesShareCompanyCount.Value = WebUser.GetNotesShareCompanyCount().ToString();

            //Madison
            hidIsLumber_BASIC_PLUS.Value = WebUser.IsLumber_BASIC_PLUS().ToString();
            hidNotesShareCompanyMax_BASIC_PLUS.Value = Configuration.NotesShareCompanyMax_L150.ToString(); //250

            CompanyData ocd = GetCompanyData(companyID.ToString(), WebUser, GetDBAccess(), GetObjectMgr());
            if(ocd.bHasNote)
            {
                btnNotes.PostBackUrl = PageConstants.FormatFromRoot(PageConstants.COMPANY_DETAILS_CUSTOM, companyID);
                btnNotes.Visible = true;
                btnAddNote.Visible = false;
            }
            else
            {
                btnNotes.Visible = false;
                btnAddNote.Visible = true;
            }

            if (_bCondensed)
            {
                //Hide buttons
                Print.Visible = false;
                Close.Visible = false;
                btnNotes.Visible = false;
                btnAddNote.Visible = false;
                viewMore.Visible = false;
            }

            if (WebUser.prwu_HQID == 0)
                btnNotes.Enabled = false;

            IPRWebUserNote note = new PRWebUserNoteMgr(GetLogger(), oWebUser).GetKeyNote(oWebUser.prwu_HQID, companyID);
            if (note == null)
            {
                if (_bCondensed)
                { 
                    Visible = false;
                    return;
                }

                viewMore.Visible = false;
                trKeyNoteEmpty.Visible = true;
                trKeyNote.Visible = false;
                tdKeyNoteLastUpdated.Visible = false;

                return;
            }

            trKeyNoteEmpty.Visible = false;
            trKeyNote.Visible = true;
            tdKeyNoteLastUpdated.Visible = true;

            litKeyNoteLastUpdated.Text = UIUtils.GetStringFromDateTime(oWebUser.ConvertToLocalDateTime(note.prwun_NoteUpdatedDateTime));
            litKeyNoteLastUpdated2.Text = UIUtils.GetStringFromDateTime(oWebUser.ConvertToLocalDateTime(note.prwun_NoteUpdatedDateTime));

            if(_bCondensed)
                litKeyNote.Text = PageBase.FormatTextForHTML(note.prwun_Note);
            else
                litKeyNote.Text = PageBase.FormatTextForHTML(note.GetTruncatedText(Configuration.CompanyHeaderKeyNoteLength));
            litKeyNote2.Text = PageBase.FormatTextForHTML(note.prwun_Note);

            litKeyNoteLastUpdatedBy.Text = note.UpdatedBy;
            Print.CommandArgument = note.prwun_WebUserNoteID.ToString();
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
            Session["CompanyHeader_szCompanyID"] = _oCompanyID;
            ifrmNoteEdit.Attributes.Add("src", "../NoteEdit.aspx?Return=c" + parms);
            ModalPopupExtender3.Show();
        }
    }
}