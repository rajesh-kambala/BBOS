/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2017-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CustomData
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using PRCo.EBB.BusinessObjects;
using System;
using System.Web.UI.WebControls;
using TSI.BusinessObjects;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// User control that displays the company header, or "banner" information
    /// on each of the company detail pages.
    /// 
    /// NOTE: This user control is also being used to display the company header information
    /// on each of the edit my company wizard pages.
    /// </summary>
    public partial class CustomData : UserControlBase
    {
        protected string _szCompanyID;
        protected int _customFieldCount = 0;
        private bool _bCondensed = false;

        public event EventHandler EditCustomDataButtonClicked;

        public enum CustomDataFormatType
        {
            FORMAT_ORIG = 1,
            FORMAT_BBOS9 = 2
        }

        protected CustomDataFormatType _eFormat = CustomDataFormatType.FORMAT_ORIG; //default to original style

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if(!IsPostBack)
            {
                ApplySecurity();
                SetVisibility();
            }
        }

        /// <summary>
        /// Apply security to the various screen components
        /// based on the current user's access level and role.
        /// </summary>
        protected void ApplySecurity()
        {
            PageBase.ApplyReadOnlyCheck(btnCustomFieldEdit1);
        }

        public string companyID
        {
            set
            {
                _szCompanyID = value;
                PopulateCustomFields(UIUtils.GetInt(_szCompanyID));
            }
            get { return _szCompanyID; }
        }

        public bool Condensed
        {
            set { _bCondensed = value; }
            get { return _bCondensed; }
        }

        public bool HideEditCustomDataButton
        {
            set; get;
        }

        protected void PopulateCustomFields(int companyID)
        {
            if (!WebUser.HasPrivilege(SecurityMgr.Privilege.CustomFields).HasPrivilege)
            {
                pnlCustomFields1.Visible = false;
                pnlCustomFields2.Visible = false;
                return;
            }

            IBusinessObjectSet customFields = new PRWebUserCustomFieldMgr(GetLogger(), WebUser).GetByAssociatedCompany(WebUser.prwu_HQID, companyID);

            switch(Format)
            {
                case CustomDataFormatType.FORMAT_ORIG:
                    repCustomFields1.DataSource = customFields;
                    repCustomFields1.DataBind();

                    _customFieldCount = customFields.Count;
                    if (customFields.Count == 0)
                    {
                        btnCustomFieldEdit1.Enabled = false;
                    }

                    if (_bCondensed)
                    {
                        btnCustomFieldEdit1.Visible = false;
                        btnCustomFieldManage1.Visible = false;
                    }
                    break;
                case CustomDataFormatType.FORMAT_BBOS9:
                    repCustomFields2.DataSource = customFields;
                    repCustomFields2.DataBind();

                    _customFieldCount = customFields.Count;
                    if (customFields.Count == 0)
                    {
                        btnCustomFieldEdit2.Disabled = true;
                    }

                    if (_bCondensed)
                    {
                        btnCustomFieldEdit2.Visible = false;
                        btnCustomFieldManage2.Visible = false;
                    }
                    break;
                default:
                    Visible = false;
                    return;
            }

            Visible = true;
        }

        protected void RepCustomFields_ItemCreated(Object Sender, RepeaterItemEventArgs e)
        {
            // Execute the following logic for Items and Alternating Items.
            if (e.Item.ItemType == ListItemType.Item ||
                e.Item.ItemType == ListItemType.AlternatingItem)
            {
                //Get the MyClass instance for this repeater item
                IPRWebUserCustomField customField = (IPRWebUserCustomField)e.Item.DataItem;

                if (customField != null)
                {
                    switch (Format)
                    {
                        case CustomDataFormatType.FORMAT_ORIG:
                            PlaceHolder ph = (PlaceHolder)e.Item.FindControl("phCustomField");

                            WebUserCustomField webUserCustomField = (WebUserCustomField)LoadControl("WebUserCustomField.ascx");
                            webUserCustomField.DisplayCustomField(customField, WebUserCustomField.Mode.View);

                            ph.Controls.Add(webUserCustomField);
                            break;
                        case CustomDataFormatType.FORMAT_BBOS9:
                            Literal litCustomFieldLabel = (Literal)e.Item.FindControl("litCustomFieldLabel");
                            Literal litCustomFieldValue = (Literal)e.Item.FindControl("litCustomFieldValue");
                            litCustomFieldLabel.Text = customField.prwucf_Label;
                            litCustomFieldValue.Text = customField.Value;
                            break;
                    }
                }
            }
        }

        public void btnEditCustomFields_Click(object sender, EventArgs e)
        {
            EditCustomDataButtonClicked?.Invoke(this, e);
        }

        public bool EditButtonDisabled
        {
            get { return btnCustomFieldEdit2.Disabled;  }
        }

        public bool EditButtonVisible
        {
            get { return btnCustomFieldEdit2.Visible; }
        }

        protected void btnCustomFieldEdit2_ServerClick(object sender, EventArgs e)
        {
            EditCustomDataButtonClicked?.Invoke(this, e);
        }

        public CustomDataFormatType Format
        {
            set
            {
                _eFormat = value;
                SetVisibility();
            }
            get { return _eFormat; }
        }

        private void SetVisibility()
        {
            switch (Format)
            {
                case CustomDataFormatType.FORMAT_BBOS9:
                    pnlCustomFields1.Visible = false;
                    pnlCustomFields2.Visible = true;
                    if (HideEditCustomDataButton)
                        btnCustomFieldEdit2.Visible = false;
                    break;

                default:
                    pnlCustomFields1.Visible = true;
                    pnlCustomFields2.Visible = false;
                    break;
            }
        }

        protected void btnCustomFieldManage2_ServerClick(object sender, EventArgs e)
        {
            Response.Redirect("~/CustomFieldList.aspx");
        }


    }
}