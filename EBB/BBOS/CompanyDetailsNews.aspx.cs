/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2010-2023

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CompanyDetailsNews
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using PRCo.EBB.BusinessObjects;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    public partial class CompanyDetailsNews : CompanyDetailsBase
    {
        protected override string GetCompanyID()
        {
            if (IsPostBack)
                return hidCompanyID.Text;
            else
                return hidCompanyID.Text = GetRequestParameter("CompanyID", true, true);
        }

        protected override CompanyDetailsHeader GetCompanyDetailsHeader()
        {
            return ucCompanyDetailsHeader;
        }

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            // Set page title, sub-title
            SetPageTitle(Resources.Global.CompanyDetails, Resources.Global.News);

            // Add company submenu to this page
            SetSubmenu("btnCompanyDetailsNews");

            if (!IsPostBack)
            {
                hidCompanyID.Text = GetRequestParameter("CompanyID");
                Session["ReturnURL"] = PageConstants.Format(PageConstants.COMPANY_DETAILS_SUMMARY, hidCompanyID.Text);

                PopulateForm();
            }

            //Set user controls
            ucNewsArticles.WebUser = _oUser;
            ucNewsArticles.companyID = hidCompanyID.Text;
            ucNewsArticles.Title = Resources.Global.News; // "News/Articles";
            //ucNewsArticles.SummaryName = Resources.Global.BBOSNewsArticles; // "BBOS NEWS ARTICLES";
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

        /// <summary>
        /// Populates the page.
        /// </summary>
        protected void PopulateForm()
        {
        }

        override protected bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.CompanyDetailsNewsPage).Enabled;
        }
    }
}

