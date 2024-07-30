/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2014-2017

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: TESLongForm
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/

using System;
using System.Text;
using PRCo.EBB.BusinessObjects;

namespace PRCo.BBOS.UI.Web
{
    public partial class WebUserCustomField : UserControlBase
    {
        public string LabelWidth = string.Empty; // "50%";

        public enum Mode
        {
            View = 0,
            Edit = 1,
            BulkEdit = 2
        };

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
        }

        protected IPRWebUserCustomField _customField;
        protected Mode _mode;

        public void DisplayCustomField(IPRWebUserCustomField customField, Mode mode)
        {
            if (customField == null)
            {
                trRow.Visible = false;
                return;
            }

            if ((customField.prwucf_FieldTypeCode == "DDL") &&
                (customField.GetLookupValues().Count == 0))
            {
                trRow.Visible = false;
                return;
            }

            _customField = customField;
            _mode = mode;

            litCustomField.Text = BuildControls();
        }

        protected const string TEXT_BOX = "<input value='{0}' name='{1}' id='{1}' type='text' class='form-control tw-col-span-9' maxlength='100' {2} />";
        protected const string SELECT = "<select name='{0}' id='{0}' class='form-control tw-col-span-9' {1}>";
        protected const string OPTION = "<option value='{0}' class='form-control tw-col-span-9 ' {2}>{1}</option>";

        protected string BuildControls()
        {
            string sChecked = string.Empty;
            StringBuilder sbHTML = new StringBuilder();
            if (_mode == Mode.View)
            {
                sbHTML.Append(_customField.Value);
            }
            else
            {
                string controlID = null;
                string disabled = string.Empty;

                if (_mode == Mode.BulkEdit)
                {
                    disabled = " disabled=\"true\"";
                }

                if (_customField.prwucf_FieldTypeCode == "Text")
                {
                    controlID = string.Format("CustomFieldDataTxt_{0}", _customField.prwucf_WebUserCustomFieldID);
                    sbHTML.Append(string.Format(TEXT_BOX, _customField.Value, controlID, disabled));
                }
                else
                {
                    controlID = string.Format("CustomFieldDataDDL_{0}", _customField.prwucf_WebUserCustomFieldID);
                    sbHTML.Append(string.Format(SELECT, controlID, disabled));

                    if (string.IsNullOrEmpty(_customField.Value))
                    {
                        sChecked = " selected=\"true\"";
                    }
                    sbHTML.Append(string.Format(OPTION, string.Empty, "[None Selected]", sChecked));

                    foreach (IPRWebUserCustomFieldLookup lookup in _customField.GetLookupValues())
                    {
                        sChecked = string.Empty;
                        if (_customField.Value == lookup.prwucfl_LookupValue)
                        {
                            sChecked = " selected=\"true\"";
                        }
                        sbHTML.Append(string.Format(OPTION, lookup.prwucfl_WebUserCustomFieldLookupID, lookup.prwucfl_LookupValue, sChecked));
                    }

                    sbHTML.Append("</select>");
                }

                if (_mode == Mode.BulkEdit)
                {
                    tdSelect.Visible = true;
                    string checkboxID = string.Format("CustomFieldDataCB_{0}", _customField.prwucf_WebUserCustomFieldID);
                    litSelect.Text = string.Format("<input name=\"{1}\" type=\"checkbox\" onclick=\"document.getElementById('{0}').disabled = !this.checked;\" value=\"on\" />", controlID, checkboxID);
                }
            }

            if (!string.IsNullOrEmpty(LabelWidth))
            {
                tdLabel.Attributes.CssStyle.Add("width", LabelWidth);
            }
            return sbHTML.ToString();
        }
    }
}