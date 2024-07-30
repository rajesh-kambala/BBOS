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
     
 ClassName: PinnedWatchdogGroups.ascx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/

using PRCo.EBB.BusinessObjects;
using System;
using System.Collections;
using System.Data;
using TSI.BusinessObjects;

namespace PRCo.BBOS.UI.Web.UserControls
{
    public partial class PinnedWatchdogGroups : UserControlBase
    {
        protected int _categoryCount = 0;
        private int _oCompanyID;

        protected const string SQL_CATEGORIES =
             @"SELECT prwucl_CategoryIcon, prwucl_Name
                 FROM PRWebUserList WITH (NOLOCK)
                      INNER JOIN PRWebUserListDetail WITH (NOLOCK) ON prwucl_WebUserListID = prwuld_WebUserListID
                WHERE prwucl_HQID = @HQID
                  AND prwucl_Pinned = 'Y'
                  AND prwuld_AssociatedID = @CompanyID
             ORDER BY prwucl_Name";

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
        }

        public int companyID
        {
            set
            {
                _oCompanyID = value;
                PopulateCategories(_oCompanyID, WebUser);
            }
            get { return _oCompanyID; }
        }

        protected void PopulateCategories(int companyID, IPRWebUser oWebUser)
        {

            if (!oWebUser.HasPrivilege(SecurityMgr.Privilege.WatchdogListsPage).HasPrivilege)
            {
                Visible = false;
                return;
            }

            IList parmList = new ArrayList();
            parmList.Add(new ObjectParameter("HQID", oWebUser.prwu_HQID));
            parmList.Add(new ObjectParameter("CompanyID", companyID));

            repCategories.DataSource = GetDBAccess().ExecuteReader(SQL_CATEGORIES, parmList, CommandBehavior.CloseConnection, null);
            repCategories.DataBind();

            _categoryCount = repCategories.Items.Count;

            trCategory.Visible = (_categoryCount != 0);
            trCategoryEmpty.Visible = (_categoryCount == 0);
        }
    }
}