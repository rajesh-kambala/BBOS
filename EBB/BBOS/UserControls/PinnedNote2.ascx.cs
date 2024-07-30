/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com
     
 ClassName: PinnedNote2.ascx
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
    public partial class PinnedNote2: UserControlBase
    {
        private int _oCompanyID;

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

        protected void PopulateKeyNote(int companyID, IPRWebUser oWebUser)
        {
            if (!oWebUser.HasPrivilege(SecurityMgr.Privilege.Notes).HasPrivilege)
            {
                Visible = false;
                return;
            }

            IPRWebUserNote note = new PRWebUserNoteMgr(GetLogger(), oWebUser).GetKeyNote(oWebUser.prwu_HQID, companyID);
            if (note == null)
            {
                Visible = false;
                return;
            }
            litKeyNoteLastUpdated.Text = UIUtils.GetStringFromDateTime(oWebUser.ConvertToLocalDateTime(note.prwun_NoteUpdatedDateTime));
            litKeyNoteLastUpdated2.Text = UIUtils.GetStringFromDateTime(oWebUser.ConvertToLocalDateTime(note.prwun_NoteUpdatedDateTime));
            
            litKeyNote.Text = PageBase.FormatTextForHTML(note.GetTruncatedText(Configuration.CompanyHeaderKeyNoteLength));
            litKeyNote2.Text = PageBase.FormatTextForHTML(note.prwun_Note);

            litKeyNoteLastUpdatedBy.Text = note.UpdatedBy;
        }
    }
}