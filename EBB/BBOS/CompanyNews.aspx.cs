/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CompanyNews
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using PRCo.EBB.BusinessObjects;
using System;
using System.Collections;
using System.Data;
using System.Diagnostics;
using System.Security.Cryptography;
using System.Web;
using TSI.BusinessObjects;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Displays company data and listing.
    /// </summary>
    public partial class CompanyNews : CompanyDetailsBase
    {
        protected CompanyData _ocd;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
            Page.Title = Resources.Global.BlueBookService;
            ((BBOS)Master).HideOldTopMenu();

            if (!IsPostBack)
            {
                hidCompanyID.Text = GetRequestParameter("CompanyID", true, true);
                GetOcd();
                PopulateForm();
            }

            RedirectToHomeIfCompanyMissing(hidCompanyID.Text);

            //Set user controls
            ucSidebar.WebUser = _oUser;
            ucSidebar.CompanyID = UIUtils.GetString(hidCompanyID.Text);
            ucCompanyHero.WebUser = _oUser;
            ucCompanyHero.CompanyID = UIUtils.GetString(hidCompanyID.Text);
            ucCompanyBio.WebUser = _oUser;
            ucCompanyBio.CompanyID = UIUtils.GetString(hidCompanyID.Text);

            ucNewsArticles.WebUser = _oUser;
            ucNewsArticles.companyID = hidCompanyID.Text;
            ucNewsArticles.Title = Resources.Global.News; // "News/Articles";
            ucNewsArticles.PublishDateTimeColName = "prpbar_PublishDate";
            ucNewsArticles.NewsArticlesDisplayed = NewsArticles.MAX_ARTICLES; //put before Style is called
            ucNewsArticles.MaxMonthsOld = Configuration.NewsMaxMonthsOld;
            ucNewsArticles.Style = NewsArticles.NewsType.GENERAL_NEWS_COMPANY_DETAILS_NEWS;
            ucNewsArticles.IsAbstract = false; //display full length articles
            ucNewsArticles.DisplayStatusColumn = true;
            ucNewsArticles.DisplaySourceColumn = false;
            ucNewsArticles.DisplayCategoryColumn = true;
            ucNewsArticles.DisplayViewAllButton = false;
            ucNewsArticles.DisplayFeedColumn = false;
            ucNewsArticles.AllowSorting = true;
            ucNewsArticles.DisplayRecordCounts = true;
            ucNewsArticles.PopulateNewsArticles();
        }

        protected override string GetCompanyID()
        {
            if (IsPostBack)
            {
                return hidCompanyID.Text;
            }
            else
            {
                return GetRequestParameter("CompanyID");
            }
        }

        protected override CompanyDetailsHeader GetCompanyDetailsHeader()
        {
            return ucCompanyDetailsHeader;
        }

        /// <summary>
        /// Populates the form controls for the specified
        /// company
        /// </summary>
        protected void PopulateForm()
        {

            //LocalSource
            if (_ocd.bLocalSource)
            {
                ucCompanyDetailsHeaderMeister.MeisterVisible = true;
            }
        }
        public CompanyData GetOcd()
        {
            if (_ocd == null)
                _ocd = PageControlBaseCommon.GetCompanyData(hidCompanyID.Text, _oUser, GetDBAccess(), GetObjectMgr());
            return _ocd;
        }

        override protected bool IsAuthorizedForPage()
        {
            return _oUser.IsLimitado || _oUser.HasPrivilege(SecurityMgr.Privilege.CompanyDetailsListingPage).Enabled;
        }
    }
}