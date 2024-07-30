/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2018

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: WatchDogLists
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using PRCo.EBB.BusinessObjects;
using System;
using System.Collections;
using System.Data;
using TSI.BusinessObjects;
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
    public partial class WatchDogLists : UserControlBase
    {
        protected string _szCompanyID;
        protected int _categoryCount = 0;
        protected int _categoryIndex = 0;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
        }

        public string companyID
        {
            set
            {
                _szCompanyID = value;
                PopulateCategories(UIUtils.GetInt(_szCompanyID));
            }
            get { return _szCompanyID; }
        }

        protected const string SQL_CATEGORIES =
            @"SELECT prwucl_CategoryIcon, prwucl_Name, prwucl_Pinned
                 FROM PRWebUserList WITH (NOLOCK)
                      INNER JOIN PRWebUserListDetail WITH (NOLOCK) ON prwucl_WebUserListID = prwuld_WebUserListID
                WHERE ((prwucl_HQID = @HQID AND prwucl_IsPrivate IS NULL) OR (prwucl_WebUserID=@WebUserID AND prwucl_IsPrivate = 'Y')) 
                  AND prwuld_AssociatedID = @CompanyID
             ORDER BY prwucl_Name";

        protected void PopulateCategories(int companyID)
        {
            if (!WebUser.HasPrivilege(SecurityMgr.Privilege.WatchdogListsPage).HasPrivilege)
            {
                Categories.Visible = false;
                return;
            }

            IList parmList = new ArrayList();
            parmList.Add(new ObjectParameter("HQID", WebUser.prwu_HQID));
            parmList.Add(new ObjectParameter("WebUserID", WebUser.prwu_WebUserID));
            parmList.Add(new ObjectParameter("CompanyID", companyID));

            repCategories.DataSource = GetDBAccess().ExecuteReader(SQL_CATEGORIES, parmList, CommandBehavior.CloseConnection, null);
            repCategories.DataBind();

            _categoryCount = repCategories.Items.Count;
        }

        protected void btnRemoveCategory_Click(object sender, EventArgs e)
        {
            displayRemoveCategoryIFrame();
        }

        protected void displayRemoveCategoryIFrame()
        {
            ifrmCategoryRemove.Attributes.Add("src", "~/CompanyDetailsCategoryRemove.aspx?CompanyID=" + companyID);
            mdeCategoryRemove.Show();
        }

        protected void btnAddToWatchdogOnClick(object sender, EventArgs e)
        {
            SetRequestParameter("CompanyIDList", companyID);
            Response.Redirect(PageConstants.USER_LIST_ADD_TO);
        }
    }
}