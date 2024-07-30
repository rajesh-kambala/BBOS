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

 ClassName: CompanyDetailsCustomFieldEdit
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    public partial class CompanyDetailsCustomFieldEdit : PageBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            SetPageTitle(Resources.Global.EditCustomData);
            

            if (!IsPostBack)
            {
                hidCompanyID.Value = GetRequestParameter("CompanyID");
                IBusinessObjectSet customFields = new PRWebUserCustomFieldMgr(_oLogger, _oUser).GetByAssociatedCompany(_oUser.prwu_HQID, Convert.ToInt32(hidCompanyID.Value));
                repCustomFields.DataSource = customFields;
                repCustomFields.DataBind();
            }
        }

        protected void RepCustomFields_ItemCreated(object Sender, RepeaterItemEventArgs e)
        {
            // Execute the following logic for Items and Alternating Items.
            if (e.Item.ItemType == ListItemType.Item ||
                e.Item.ItemType == ListItemType.AlternatingItem)
            {

                //Get the MyClass instance for this repeater item
                IPRWebUserCustomField customField = (IPRWebUserCustomField)e.Item.DataItem;
                PlaceHolder ph = (PlaceHolder)e.Item.FindControl("phCustomField");

                WebUserCustomField webUserCustomField = (WebUserCustomField)LoadControl("UserControls/WebUserCustomField.ascx");
                webUserCustomField.DisplayCustomField(customField, WebUserCustomField.Mode.Edit);

                ph.Controls.Add(webUserCustomField);
            }
        }

        protected void Save_Click(object sender, EventArgs e)
        {
            IBusinessObjectSet customFields = new PRWebUserCustomFieldMgr(_oLogger, _oUser).GetByHQ(_oUser.prwu_HQID);

            foreach (IPRWebUserCustomField customField in customFields)
            {
                if (customField.prwucf_FieldTypeCode == "DDL")
                {
                    int lookupID = 0;
                    string name = "CustomFieldDataDDL_" + customField.prwucf_WebUserCustomFieldID.ToString();
                    string work = Request.Form[name];
                    if (!string.IsNullOrEmpty(work))
                    {
                        lookupID = Convert.ToInt32(work);
                    }

                    customField.SetValue(Convert.ToInt32(hidCompanyID.Value), lookupID);
                }
                else
                {
                    string name = "CustomFieldDataTxt_" + customField.prwucf_WebUserCustomFieldID.ToString();
                    string work = Request.Form[name];
                    customField.SetValue(Convert.ToInt32(hidCompanyID.Value), work);
                }
            }

            customFields.Save();
            ClientScript.RegisterStartupScript(this.GetType(), "close", string.Format("closeReload({0});", hidCompanyID.Value), true);
        }

        protected void Cancel_Click(object sender, EventArgs e)
        {
            ClientScript.RegisterStartupScript(this.GetType(), "close", string.Format("closeReload({0});", hidCompanyID.Value), true);
        }

        protected override bool IsAuthorizedForData()
        {
            return true;
        }

        override protected bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.CustomFields).Enabled;
        }
    }
}