/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CompanyDetailsBase
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Diagnostics;
using System.Threading;
using System.Web;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using TSI.Arch;
using TSI.BusinessObjects;
using TSI.DataAccess;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Provides the common functionality for the CompanyDetail
    /// screens.
    /// </summary>
    abstract public class CompanyDetailsBase : PageBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if (!IsPostBack)
            {
                GetCompanyDetailsHeader().LoadCompanyHeader(GetRequestParameter("CompanyID"), _oUser);

                //Call MasterPage.DisplayReturnToSearch()
                if(Master != null)
                    ((BBOS)Master).DisplayReturnToSearch();
            }

            //SetSubmenu();
        }

        abstract protected CompanyDetailsHeader GetCompanyDetailsHeader();
        abstract protected string GetCompanyID();

        /// <summary>
        /// Sets up the Company Details sub-menu
        /// </summary>
        protected void SetSubmenu(string strDefaultID)
        {
            //Get cached company data
            CompanyData ocd = GetCompanyDataFromSession();

            List<SubMenuItem> oMenuItems = new List<SubMenuItem>();

            AddSubmenuItemButton(oMenuItems, Resources.Global.ListingSummary, "btnCompanyDetailsListing", SecurityMgr.Privilege.CompanyDetailsListingPage);
            AddSubmenuItemButton(oMenuItems, Resources.Global.Contacts, "btnCompanyDetailsContacts", SecurityMgr.Privilege.CompanyDetailsContactsPage);
            AddSubmenuItemButton(oMenuItems, Resources.Global.CompanyUpdates, "btnCompanyDetailsUpdates", SecurityMgr.Privilege.CompanyDetailsUpdatesPage);
            AddSubmenuItemButton(oMenuItems, Resources.Global.CompanyNews, "btnCompanyDetailsNews", SecurityMgr.Privilege.CompanyDetailsNewsPage);
            AddSubmenuItemButton(oMenuItems, Resources.Global.ClassificationsProductsServicesSpecies, "btnCompanyDetailsClassifications", SecurityMgr.Privilege.CompanyDetailsClassificationsCommoditesProductSerivcesSpeciesPage);
            AddSubmenuItemButton(oMenuItems, Resources.Global.ClaimsActivityTable, "btnCompanyDetailsClaimActivity", SecurityMgr.Privilege.CompanyDetailsClaimActivityPage);
            AddSubmenuItemButton(oMenuItems, Resources.Global.ARReports, "btnCompanyDetailsARReports", SecurityMgr.Privilege.CompanyDetailsARReportsPage);
            AddSubmenuItemButton(oMenuItems, Resources.Global.ClassificationsAndCommodities, "btnCompanyDetailsClassifications", SecurityMgr.Privilege.CompanyDetailsClassificationsCommoditesPage);
            AddSubmenuItemButton(oMenuItems, Resources.Global.BranchesAndAffiliations, "btnCompanyDetailsBranches", SecurityMgr.Privilege.CompanyDetailsBranchesAffiliationsPage);

            if (ocd.bHasCSG)
            {
                AddSubmenuItemButton(oMenuItems, Resources.Global.ChainStoreGuide, "btnCompanyDetailsCSG", SecurityMgr.Privilege.CompanyDetailsChainStoreGuidePage);
            }

            AddSubmenuItemButton(oMenuItems, Resources.Global.CompanyCustom, "btnCompanyDetailsCustom", SecurityMgr.Privilege.CompanyDetailsCustomPage); //Notes label
            if(_oUser.prwu_HQID == 0)
            {
                //Disable notes
                foreach (SubMenuItem menuItem in oMenuItems)
                {
                    if (menuItem.Text == Resources.Global.CompanyCustom) //Notes
                    {
                        menuItem.Enabled = false;
                        //menuItem.Tooltip = Resources.Global.FeatureDisabledContactCustSvc; //"This feature is disabled.  Please contact customer service if you would like this feature.";
                    }
                }
            }

        #region "ClaimActivity Menu Item Disabling and Tooltip"
            SecurityMgr.SecurityResult resultClaimActivityAccess = _oUser.HasPrivilege(SecurityMgr.Privilege.CompanyDetailsClaimActivityPage);
            if(!resultClaimActivityAccess.Enabled)
            {
                foreach (SubMenuItem menuItem in oMenuItems)
                {
                    if (menuItem.Text == Resources.Global.ClaimsActivity)
                    {
                        menuItem.Enabled = false;
                        menuItem.Tooltip = Resources.Global.FeatureDisabledContactCustSvc; //"This feature is disabled.  Please contact customer service if you would like this feature.";
                    }
                }
            }
            else if (ocd.szCompanyType == "B")
            {
                foreach (SubMenuItem menuItem in oMenuItems)
                {
                    if (menuItem.Text == Resources.Global.ClaimsActivity)
                    {
                        menuItem.Enabled = false;
                        menuItem.Tooltip = Resources.Global.FeatureDisabledClaimsNotRecordedAtBranchLevel; // "This feature is disabled for this record since Claims are not recorded at the Branch-level.";
                    }
                }
            }

            #endregion

            SubMenuBar oSubMenuBar = (SubMenuBar)Master.FindControl("SubmenuBar");
            oSubMenuBar.MenuItemEvent += new EventHandler(oSubMenuBar_MenuItemEvent);
            oSubMenuBar.LoadMenuButtons(oMenuItems, strDefaultID);
        }

        /// <summary>
        /// Handles the on click event for each of the submenu items.  The
        /// current company search criteria object will be stored and the 
        /// user will be redirected accordingly.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void oSubMenuBar_MenuItemEvent(object sender, EventArgs e)
        {
            // If we are currently working with a specified search id, 
            // create a querystring to pass this along
            string szCompanyID = "";

            if (!String.IsNullOrEmpty(GetRequestParameter("CompanyID")))
                szCompanyID = GetRequestParameter("CompanyID");

            switch (((WebControl)sender).ID)
            {
                case "btnCompanyDetailsListing":
                    Response.Redirect(string.Format(PageConstants.COMPANY_DETAILS_SUMMARY, szCompanyID));
                    break;
                case "btnCompanyDetailsContacts":
                    Response.Redirect(string.Format(PageConstants.COMPANY_DETAILS_CONTACTS, szCompanyID));
                    break;
                case "btnCompanyDetailsUpdates":
                    Response.Redirect(string.Format(PageConstants.COMPANY_DETAILS_COMPANY_UPDATES, szCompanyID));
                    break;
                case "btnCompanyDetailsNews":
                    Response.Redirect(string.Format(PageConstants.COMPANY_NEWS, szCompanyID));
                    break;
                case "btnCompanyDetailsClaimActivity":
                    Response.Redirect(string.Format(PageConstants.COMPANY_CLAIMS_ACTIVITY_BBOS9, szCompanyID));
                    break;
                case "btnCompanyDetailsARReports":
                    Response.Redirect(string.Format(PageConstants.COMPANY_DETAILS_AR_REPORTS, szCompanyID));
                    break;
                case "btnCompanyDetailsClassifications":
                    Response.Redirect(string.Format(PageConstants.COMPANY_DETAILS_CLASSIFICATIONS, szCompanyID));
                    break;
                case "btnCompanyDetailsBranches":
                    Response.Redirect(string.Format(PageConstants.COMPANY_DETAILS_BRANCHES, szCompanyID));
                    break;
                case "btnCompanyDetailsCSG":
                    Response.Redirect(string.Format(PageConstants.COMPANY_DETAILS_CSG, szCompanyID));
                    break;
                case "btnCompanyDetailsCustom":
                    Response.Redirect(string.Format(PageConstants.COMPANY_DETAILS_CUSTOM, szCompanyID));
                    break;
            }
        }

        protected override bool IsAuthorizedForData()
        {
            if (GetRequestParameter("CompanyID", false) == null)
            {
                Response.Redirect(PageConstants.BBOS_HOME, true);
                return false;
            }

            int iCompanyID = 0;
            if (!int.TryParse(GetRequestParameter("CompanyID"), out iCompanyID))
            {
                throw new ApplicationExpectedException(Resources.Global.BookmarkError);
            }

            return GetObjectMgr().IsCompanyListed(iCompanyID);
        }

        protected void LogTimer(Stopwatch sw, string szMsg)
        {
            if (Utilities.GetBoolConfigValue("LogTimerEnabled", false))
            {
                LogMessage($"TIMER {szMsg}: {sw.ElapsedMilliseconds}ms");
            }
        }

        protected const string SQL_SELECT_PRIMARY_MEMBERSHIP =
                   @"SELECT ISNULL(prod_ProductID,0) prod_ProductID, ISNULL(prod_PRSequence, 0) prod_PRSequence, prod_Name, prod_Code
                FROM PRService WITH (NOLOCK) 
                     INNER JOIN NewProduct WITH (NOLOCK) ON prse_ServiceCode = prod_code 
               WHERE prse_HQID=@prse_HQID 
                 AND prse_Primary = 'Y'";
        /// <summary>
        /// Helper method that queries for the current user's
        /// primary membership.
        /// </summary>
        protected string GetPrimaryMembership()
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prse_HQID", _oUser.prwu_HQID));

            IDBAccess _oDBAccess = DBAccessFactory.getDBAccessProvider();
            _oDBAccess.Logger = _oLogger;

            using (IDataReader drPrimary = _oDBAccess.ExecuteReader(SQL_SELECT_PRIMARY_MEMBERSHIP, oParameters))
            {
                if (drPrimary.Read())
                {
                    return drPrimary.GetString(3);
                }
            }

            return "";
        }

        protected bool HandleLumberRedirect(string industryType, string companyID, string targetPage = PageConstants.COMPANY_DETAILS_SUMMARY)
        {
            if (!Utilities.GetBoolConfigValue("LumberRedirectEnabled", true))
                return false;

            if (industryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                Response.Redirect(PageConstants.Format(targetPage, companyID));
                return true;
            }

            return false;
        }
    }
}