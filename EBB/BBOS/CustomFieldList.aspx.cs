/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2014-2023

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CustomFieldList.aspx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Web.UI;
using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    public partial class CustomFieldList : PageBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            SetPageTitle(Resources.Global.btnManageCustomData); // "Manage Custom Data"

            if (!IsPostBack)
            {
                PopulateForm();
            }

            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_FUNCTIONS2_FILE));
            //Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_VALIDATION_FILE));
            EnableFormValidation();

            btnDelete.Attributes.Add("onclick", "return confirmDelete('Custom Data field', 'cbCustomField');");
            btnEdit.Attributes.Add("onclick", "return confirmOneSelected('Custom Data field', 'cbCustomField')");
        }

        /// <summary>
        /// Populates the form.
        /// </summary>
        protected void PopulateForm()
        {
            IBusinessObjectSet customFields = new PRWebUserCustomFieldMgr(_oLogger, _oUser).GetByHQ(_oUser.prwu_HQID);

            //((EmptyGridView)gvCustomFields).EmptyTableRowText = GetNoResultsFoundMsg(Resources.Global.CustomFields);
            gvCustomFields.ShowHeaderWhenEmpty = true;
            gvCustomFields.EmptyDataText = GetNoResultsFoundMsg(Resources.Global.CustomFields);

            gvCustomFields.DataSource = customFields;
            gvCustomFields.DataBind();
            EnableBootstrapFormatting(gvCustomFields);

            OptimizeViewState(gvCustomFields);

            lblRecordCount.Text = string.Format(Resources.Global.RecordCountFoundMsg, gvCustomFields.Rows.Count, "Custom Data Fields");

            if (gvCustomFields.Rows.Count == 0)
            {
                btnDelete.Enabled = false;
                btnEdit.Enabled = false;
            }
            else
            {
                btnDelete.Enabled = true;
                btnEdit.Enabled = true;
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            string szCheckedList = GetRequestParameter("cbCustomField");
            string[] customFieldIDs = szCheckedList.Split(',');

            IBusinessObjectSet customFields = new PRWebUserCustomFieldMgr(_oLogger, _oUser).GetByHQ(_oUser.prwu_HQID);

            foreach (string id in customFieldIDs)
            {
                foreach (IPRWebUserCustomField customField in customFields)
                {
                    if (customField.prwucf_WebUserCustomFieldID.ToString() == id)
                    {
                        customField.Delete();
                    }
                }
            }

            PopulateForm();
        }

        protected void btnEdit_Click(object sender, EventArgs e)
        {
            Response.Redirect(string.Format(PageConstants.CUSTOM_FIELD_EDIT, GetRequestParameter("cbCustomField")));
        }

        protected void btnNew_Click(object sender, EventArgs e)
        {
            Response.Redirect(string.Format(PageConstants.CUSTOM_FIELD_EDIT, -1));
        }

        /// <summary>
        /// Only members level 3 or greater can access
        /// this page.
        /// </summary>
        /// <returns></returns>
        protected override bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.CustomFields).HasPrivilege;
        }

        protected override bool IsAuthorizedForData()
        {
            return true;
        }
    }
}