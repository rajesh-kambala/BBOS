/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2017

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com
     
 ClassName: PinnedCustomData.ascx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/

using PRCo.EBB.BusinessObjects;
using System;
using System.Web.UI.WebControls;
using TSI.BusinessObjects;

namespace PRCo.BBOS.UI.Web.UserControls
{
    public partial class PinnedCustomData : UserControlBase
    {
        protected int _customFieldCount = 0;

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
                PopulateCustomFields(_oCompanyID, WebUser);
            }
            get { return _oCompanyID; }
        }

        protected void PopulateCustomFields(int companyID, IPRWebUser oWebUser)
        {

            if (!oWebUser.HasPrivilege(SecurityMgr.Privilege.CustomFields).HasPrivilege)
            {
                Visible = false;
                return;
            }

            IBusinessObjectSet customFields = new PRWebUserCustomFieldMgr(GetLogger(), oWebUser).GetByAssociatedCompany(oWebUser.prwu_HQID, companyID, true);
            repCustomFields.DataSource = customFields;
            repCustomFields.DataBind();

            _customFieldCount = customFields.Count;
            if (customFields.Count == 0)
            {
                trCustomFieldEmpty.Visible = true;
            }
        }

        protected void RepCustomFields_ItemCreated(Object Sender, RepeaterItemEventArgs e)
        {
            // Execute the following logic for Items and Alternating Items.
            if (e.Item.ItemType == ListItemType.Item ||
                e.Item.ItemType == ListItemType.AlternatingItem)
            {
                IPRWebUserCustomField customField = (IPRWebUserCustomField)e.Item.DataItem;

                if ((customField != null) &&
                    (customField.prwucf_Pinned))
                {
                    PlaceHolder ph = (PlaceHolder)e.Item.FindControl("phCustomField");
                    WebUserCustomField webUserCustomField = (WebUserCustomField)LoadControl("WebUserCustomField.ascx");
                    //webUserCustomField.LabelWidth = "150px;";
                    webUserCustomField.DisplayCustomField(customField, WebUserCustomField.Mode.View);
                    ph.Controls.Add(webUserCustomField);
                }
            }
        }
    }
}