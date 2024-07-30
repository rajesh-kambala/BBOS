/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2014-2024

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
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web
{
    public partial class CustomFieldEdit : PageBase
    {
        IPRWebUserCustomField _customField = null;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
            SetPageTitle("Edit Custom Data");

            EnableFormValidation();

            // This is a hidden button that mirrors
            // the save LinkButton.  Had trouble getting 
            // this to 
            Form.DefaultButton = btnSave.UniqueID;
            SetPopover();

            if (!IsPostBack)
            {
                PopulateForm();
            }
        }

        protected void SetPopover()
        {
            //lbWhatIsPinned.Attributes.Add("data-bs-title", string.Format(Resources.Global.CustomFieldPinnedMsg, Configuration.CustomFieldPinThreshold));
        }

        protected IPRWebUserCustomField GetObject()
        {
            if (_customField == null)
            {
                if (IsPostBack)
                {
                    _customField = (IPRWebUserCustomField)Session["EditCustomField"];
                }

                if (_customField == null)
                {
                    string id = GetRequestParameter("ID");
                    int customFieldID = 0;
                    if (!Int32.TryParse(id, out customFieldID))
                    {
                        Response.Redirect(PageConstants.BBOS_HOME, true);
                        return null;
                    }

                    if (GetRequestParameter("ID") == "-1")
                    {
                        _customField = (IPRWebUserCustomField)new PRWebUserCustomFieldMgr(_oLogger, _oUser).CreateObject();
                        _customField.prwucf_HQID = _oUser.prwu_HQID;
                        _customField.prwucf_CompanyID = _oUser.prwu_BBID;
                        _customField.prwucf_FieldTypeCode = "DDL";
                    }
                    else
                    {
                        _customField = (IPRWebUserCustomField)new PRWebUserCustomFieldMgr(_oLogger, _oUser).GetObjectByKey(customFieldID);
                    }

                    Session["EditCustomField"] = _customField;
                }
            }

            return _customField;
        }

        protected void PopulateForm()
        {
            GetObject();

            //cbPinned.Checked = _customField.prwucf_Pinned;
            txtFieldLabel.Text = _customField.prwucf_Label;
            BindLookupValues(ddlFieldType, GetReferenceData("prwucf_FieldTypeCode"), _customField.prwucf_FieldTypeCode, false);

            if (_customField.IsInDB)
            {
                ddlFieldType.Enabled = false;
            }

            if (_customField.prwucf_FieldTypeCode == "DDL")
            {
                if (_customField.IsInDB)
                {
                    BindLookupValues();
                }
                else
                {
                    btnNewRow_Click(null, null);
                }
            }
            else
            {
                trFieldValues.Visible = false;
            }

            //int pinnedCount = new PRWebUserCustomFieldMgr(_oLogger, _oUser).GetPinnedFieldCount(_oUser.prwu_HQID);
            //if ((pinnedCount >= Configuration.CustomFieldPinThreshold) &&
            //    (!_customField.prwucf_Pinned))
            //{
            //    cbPinned.Enabled = false;
            //}
        }

        protected void BindLookupValues()
        {
            int i = 0;
            foreach (IPRWebUserCustomFieldLookup lookup in _customField.GetLookupValues())
            {
                TableRow row = new TableRow();
                TableCell cell = new TableCell();

                TextBox textBox = new TextBox();
                textBox.Columns = 35;
                textBox.MaxLength = 50;
                textBox.ID = "txtFieldValue" + i.ToString();
                textBox.Text = lookup.prwucfl_LookupValue;
                textBox.CssClass = "form-control";

                string lookupValue = GetRequestParameter("ctl00$contentMain$txtFieldValue" + i.ToString(), false);
                if (lookupValue != null)
                {
                    textBox.Text = lookupValue;
                }

                HiddenField hiddenField = new HiddenField();
                hiddenField.Value = lookup.prwucfl_WebUserCustomFieldLookupID.ToString();
                hiddenField.ID = "hidID" + i.ToString();

                cell.Controls.Add(textBox);
                cell.Controls.Add(hiddenField);
                row.Cells.Add(cell);

                TableCell removeCell = new TableCell();
                removeCell.Style.Add("text-align", "center");
                CheckBox cbRemove = new CheckBox();
                cbRemove.ID = "cbDelete" + i.ToString();

                string removeValue = GetRequestParameter("ctl00$mainContent$cbDelete" + i.ToString(), false);
                if (removeValue != null)
                {
                    cbRemove.Checked = true;
                }

                removeCell.Controls.Add(cbRemove);
                row.Cells.Add(removeCell);

                tblFieldValues.Rows.Add(row);

                i++;
            }

            hdnValueCount.Value = i.ToString();
        }

        protected void btnNewRow_Click(object sender, EventArgs e)
        {
            GetObject();
            _customField.AddLookupValue(string.Empty, _customField.GetLookupValues().Count + 1);
            BindLookupValues();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            GetObject();

            //_customField.prwucf_Pinned = cbPinned.Checked;
            _customField.prwucf_Label = txtFieldLabel.Text;
            _customField.prwucf_FieldTypeCode = ddlFieldType.SelectedValue;

            if (_customField.prwucf_FieldTypeCode == "DDL")
            {
                int valueCount = 0;
                int i = 0;
                foreach (IPRWebUserCustomFieldLookup lookup in _customField.GetLookupValues())
                {
                    string removeValue = GetRequestParameter("ctl00$contentMain$cbDelete" + i.ToString(), false);
                    if (removeValue != null)
                    {
                        string lookupID = GetRequestParameter("ctl00$contentMain$hidID" + i.ToString(), false);
                        if (!string.IsNullOrEmpty(lookupID))
                        {
                            _customField.RemoveLookupValue(Convert.ToInt32(lookupID));
                        }
                    }
                    else
                    {
                        string lookupValue = GetRequestParameter("ctl00$contentMain$txtFieldValue" + i.ToString(), false);
                        lookup.prwucfl_LookupValue = lookupValue;
                        lookup.prwucfl_Sequence = i;

                        if (lookupValue != null)
                        {
                            valueCount++;
                        }
                    }
                    i++;
                }

                if (valueCount == 0)
                {
                    AddUserMessage(Resources.Global.ToSaveCustomDataAsDropDownFieldMustBeSpecified);
                    return;
                }

            }

            _customField.Save();

            Response.Redirect(PageConstants.CUSTOM_FIELD_LIST); 
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.CUSTOM_FIELD_LIST);
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
            GetObject();

            if (_customField.prwucf_HQID != _oUser.prwu_HQID)
            {
                return false;
            }

            return true;
        }
    }
}
