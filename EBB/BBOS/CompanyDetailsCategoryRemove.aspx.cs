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

 ClassName: CompanyDetailsCategoryRemove
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Data;
using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    public partial class CompanyDetailsCategoryRemove : PageBase
    {
        protected const string SQL_CATEGORIES =
            @"SELECT prwuld_WebUserListDetailID, prwucl_CategoryIcon, prwucl_Name, prwucl_Pinned, prwucl_TypeCode
                 FROM PRWebUserList WITH (NOLOCK)
                      INNER JOIN PRWebUserListDetail WITH (NOLOCK) ON prwucl_WebUserListID = prwuld_WebUserListID
                WHERE ((prwucl_HQID = @HQID AND prwucl_IsPrivate IS NULL) OR (prwucl_WebUserID=@WebUserID AND prwucl_IsPrivate = 'Y')) 
                  AND prwuld_AssociatedID = @CompanyID
             ORDER BY prwucl_Name";

        protected int _categoryCount = 0;
        protected int _categoryIndex = 0;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            EnableFormValidation();

            SetPageTitle(Resources.Global.RemoveFromWatchdogCategory);

            if (!IsPostBack)
            {
                hdnCompanyID.Value = GetRequestParameter("CompanyID");

                IList parmList = new ArrayList();
                parmList.Add(new ObjectParameter("HQID", _oUser.prwu_HQID));
                parmList.Add(new ObjectParameter("WebUserID", _oUser.prwu_WebUserID));
                parmList.Add(new ObjectParameter("CompanyID", hdnCompanyID.Value));

                repCategories.DataSource = GetDBAccess().ExecuteReader(SQL_CATEGORIES, parmList, CommandBehavior.CloseConnection, null);
                repCategories.DataBind();

                _categoryCount = repCategories.Items.Count;
            }

            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_FUNCTIONS2_FILE));
            //Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_VALIDATION_FILE));

            btnCancel.PostBackUrl = string.Format("CompanyDetailsSummary.aspx?CompanyID={0}", hdnCompanyID.Value);

            if (_categoryCount == 0)
            {
                btnSave.Enabled = false;
                btnSave.CssClass += " disabled ";
                repCategories.Visible = false;
                divNoWatchdogGroupsFound.Visible = true;
            }
        }

        protected void Save_Click(object sender, EventArgs e)
        {
            string szIDList = GetRequestParameter("cbWebUserListDetailID");
            GetDBAccess().ExecuteNonQuery(string.Format("DELETE FROM PRWebUserListDetail WHERE prwuld_WebUserListDetailID IN ({0})", szIDList));

            ResetCompanyDataSession();
            _categoryIndex = 0;
            ClientScript.RegisterStartupScript(this.GetType(), "close", "closeReload();", true);
        }

        protected string GetDisabled(string typeCode)
        {
            if (typeCode == "CL")
            {
                return "disabled=true";
            }

            return string.Empty;
        }

        protected override bool IsAuthorizedForData()
        {
            return true;
        }

        protected override bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.WatchdogListsPage).HasPrivilege;
        }
    }
}