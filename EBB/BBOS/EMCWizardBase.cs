/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2020

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: EMCWizardBase
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;
using TSI.DataAccess;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Base class for the edit company wizard pages.  This class provides
    /// the common functionality for the edit company wizard pages.
    /// 
    /// This class will be used to create the edit company wizard submenu to be displayed 
    /// on each of the wizard pages, as well as load the edit company wizard page header.
    /// 
    /// If the company's industry type is supply and service or the company type is a branch
    /// the menu will not be displayed.  These types of companies do not have a connection list 
    /// nor is a financial statement tracked.
    /// </summary>
    abstract public class EMCWizardBase : PageBase
    {
        protected int iCompanyID = 0;
        protected int iHQCompanyID = 0;

        protected string szCompanyName = "";
        protected string szIndustryType = "";
        protected string szCompanyType = "";
        protected string szCompanyLocation = "";
        protected string szLogo = "";

        protected DateTime dtJeopardyDate;

        protected const string CODE_COMPANY_TYPE_HEADQUARTERS = "H";
        protected const string CODE_COMPANY_TYPE_BRANCH = "B";

        protected const string CODE_AUDIT_CATEGORY_ADDRESS = "A";
        protected const string CODE_AUDIT_CATEGORY_BRAND = "BR";
        protected const string CODE_AUDIT_CATEGORY_CLASSIFICATION = "CL";
        protected const string CODE_AUDIT_CATEGORY_CONNECTIONLIST = "CN";
        protected const string CODE_AUDIT_CATEGORY_COMMODITY = "CO";
        protected const string CODE_AUDIT_CATEGORY_FINANCIALSTMT = "FS";
        protected const string CODE_AUDIT_CATEGORY_OTHER = "OT";
        protected const string CODE_AUDIT_CATEGORY_PERSONNEL = "PE";
        protected const string CODE_AUDIT_CATEGORY_PHONE = "PH";
        protected const string CODE_AUDIT_CATEGORY_EMAILWEB = "WE";
        protected const string CODE_AUDIT_CATEGORY_SPECIE = "S";
        protected const string CODE_AUDIT_CATEGORY_SERVICEPROVIDED = "SP";
        protected const string CODE_AUDIT_CATEGORY_PRODUCTPROVIDED = "PP";
        protected const string CODE_AUDIT_CATEGORY_VOLUME = "V";

        private const string SQL_GET_COMPANY_DATA =
            @"SELECT comp_Name, comp_PRIndustryType, comp_PRType, comp_PRJeopardyDate, CityStateCountryShort, comp_PRLogo, comp_PRHQId 
                FROM Company WITH (NOLOCK) 
                     INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
               WHERE comp_CompanyID = {0}";

        protected CompanyRelationshipMgr oMgr;

        public List<CompanyRelationships> lCompanyConnections;

        /// <summary>
        /// Calls page functions required to build and process this page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            // Retrieve the additional company data required for processing these pages.
            GetCompanyData(GetCompanyID());

            // If the industry type is supply and service do not display the menu
            // If the company type is branch do not display the menu
            if ((szCompanyType != CODE_COMPANY_TYPE_BRANCH))
            {
                //SetSubmenu();
            }

            // Load the Company Header data to be displayed on each page
            GetEditCompanyWizardHeader().LoadCompanyHeader(iCompanyID.ToString());
        }

        virtual protected int GetCompanyID()
        {
            return _oUser.prwu_BBID;
        }

        abstract protected EMCW_CompanyHeader GetEditCompanyWizardHeader();

        /// <summary>
        /// Sets up the Edit Company Wizard sub-menu
        /// </summary>
        protected void SetSubmenu(string strDefaultID, bool blnDisableValidation = false)
        {
            List<SubMenuItem> oMenuItems = new List<SubMenuItem>();

            //Don't display Edit Listing, Manage Logo, Connection List, Financial Statemnet, and Upload AR for ITA users
            if (!_oUser.IsLimitado)
            {
                AddSubmenuItemButton(oMenuItems, Resources.Global.CompanyListing, "btnCompanyListing", SecurityMgr.Privilege.CompanyEditListingPage);
            }

            AddSubmenuItemButton(oMenuItems, Resources.Global.ManageMembership, "btnManageMembership", SecurityMgr.Privilege.ManageMembershipPage);

            if (!_oUser.IsLimitado)
            {
                AddSubmenuItemButton(oMenuItems, Resources.Global.ManageLogo, "btnManageLogo", SecurityMgr.Privilege.CompanyEditListingPage);
                AddSubmenuItemButton(oMenuItems, Resources.Global.ConnectionList, "btnConnectionList", SecurityMgr.Privilege.CompanyEditReferenceListPage);
            }

            if (szIndustryType != GeneralDataMgr.INDUSTRY_TYPE_SUPPLY && !_oUser.IsLimitado)
                AddSubmenuItemButton(oMenuItems, Resources.Global.FinancialStatement, "btnFinancialStatement", SecurityMgr.Privilege.CompanyEditFinancialStatementPage);

            if (!_oUser.IsLimitado)
            {
                AddSubmenuItemButton(oMenuItems, Resources.Global.UploadAccountsReceivable, "btnUploadAccountsReceivable", SecurityMgr.Privilege.CompanyEditListingPage);
            }

            AddSubmenuItemButton(oMenuItems, Resources.Global.UserProfile, "btnUserProfile", null);

            SubMenuBar oSubMenuBar = (SubMenuBar)Master.FindControl("SubmenuBar");
            oSubMenuBar.MenuItemEvent += new EventHandler(oSubMenuBar_MenuItemEvent);
            oSubMenuBar.LoadMenuButtons(oMenuItems, strDefaultID, blnDisableValidation);
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
            switch (((WebControl)sender).ID)
            {
                case "btnCompanyListing":
                    Response.Redirect(PageConstants.EMCW_COMPANY_LISTING);
                    break;
                case "btnManageMembership":
                    Response.Redirect(PageConstants.MEMBERSHIP_SUMMARY);
                    break;
                case "btnManageLogo":
                    Response.Redirect(PageConstants.EMCW_LOGO);
                    break;
                case "btnConnectionList":
                    Response.Redirect(PageConstants.EMCW_REFERENCELIST);
                    break;
                case "btnFinancialStatement":
                    Response.Redirect(PageConstants.EMCW_FINANCIAL_STATEMENT);
                    break;
                case "btnUploadAccountsReceivable":
                    Response.Redirect(PageConstants.EMCW_AR_REPORTS);
                    break;
                case "btnUserProfile":
                    Response.Redirect(PageConstants.USER_PROFILE);
                    break;
            }
        }

        override protected bool IsAuthorizedForData()
        {
            return true;
        }

        protected void GetCompanyData()
        {
            GetCompanyData(_oUser.prwu_BBID);
        }

        /// <summary>
        /// Helper method used to retrieve the additional company data required for processing
        /// the edit my company wizard pages.  This includes the Industry Type, Company Type, and 
        /// Jeopardy date for the current users company.
        /// </summary>
        protected void GetCompanyData(int companyID)
        {
            iCompanyID = companyID;
            iHQCompanyID = companyID; //override below as long as it's found

            ArrayList oParameters = new ArrayList();

            oParameters.Add(new ObjectParameter("comp_CompanyID", iCompanyID));
            string szSQL = GetObjectMgr().FormatSQL(SQL_GET_COMPANY_DATA, oParameters);

            // Use our own DBAccess object to 
            // avoid conflicts with open readers.
            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            oDBAccess.Logger = _oLogger;

            using (IDataReader oReader = oDBAccess.ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null))
            {
                if (oReader.Read())
                {
                    szCompanyName = GetDBAccess().GetString(oReader, "comp_Name");
                    szIndustryType = GetDBAccess().GetString(oReader, "comp_PRIndustryType");
                    szCompanyType = GetDBAccess().GetString(oReader, "comp_PRType");
                    dtJeopardyDate = GetDBAccess().GetDateTime(oReader, "comp_PRJeopardyDate");
                    szCompanyLocation = GetDBAccess().GetString(oReader, "CityStateCountryShort");
                    szLogo = GetDBAccess().GetString(oReader, "comp_PRLogo");
                    iHQCompanyID = GetDBAccess().GetInt32(oReader, "comp_PRHQId");
                }
            }
        }

        /// <summary>
        /// Helper method used to get the corresponding connection lists based on the 
        /// companies industry type.
        /// </summary>
        /// <param name="szIndustryType">Company's Industry Type</param>
        /// <param name="sortOrderBy"></param>
        protected void GetCompanyRelationshipData(string szIndustryType, string sortOrderBy)
        {
            // If produce, check and set Produce connection list data
            if (szIndustryType == GeneralDataMgr.INDUSTRY_TYPE_PRODUCE)
            {
                oMgr = new CompanyRelationshipMgr(_oLogger, _oUser);
                oMgr.LoadProduceCompany(sortOrderBy);
                lCompanyConnections = oMgr.CompanyConnections;
            }

            // If transportation, get and set the transportation connection list data
            if (szIndustryType == GeneralDataMgr.INDUSTRY_TYPE_TRANSPORTATION)
            {
                oMgr = new CompanyRelationshipMgr(_oLogger, _oUser);
                oMgr.LoadTransCompany(sortOrderBy);
                lCompanyConnections = oMgr.CompanyConnections;
            }

            // If Lumber, get and set the lumber connection list data
            if (szIndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                oMgr = new CompanyRelationshipMgr(_oLogger, _oUser);
                oMgr.LoadLumberCompany(sortOrderBy);
                lCompanyConnections = oMgr.CompanyConnections;
            }
        }

        protected string GetCRMLibraryPath(string szRoot)
        {
            // store the file in the company's Library folder
            // path is Custom_SysParams.DocStore \ first char of company name \ company name \ document
            string sCompanyName = _oUser.prwu_CompanyName;
            string sChar1 = sCompanyName[0].ToString();

            // ensure the full file upload path exists
            string szCompanyPath = sChar1 + "\\" + sCompanyName;
            string szFilePath = szRoot + "\\" + szCompanyPath;

            // If this directory does not already exist, create it
            if (!System.IO.Directory.Exists(szFilePath))
                System.IO.Directory.CreateDirectory(szFilePath);

            return szCompanyPath;
        }

        protected const string SQL_INSERT_LIBRARY = "INSERT INTO Library " +
            "(libr_CreatedBy, libr_CreatedDate, libr_UpdatedBy, libr_UpdatedDate, libr_TimeStamp, " +
            "libr_CompanyId, libr_PersonId, libr_UserId, libr_FilePath, libr_FileName, " +
            "libr_CommunicationId, libr_FileSize, libr_PRFileId, libr_LibraryId) " +
            "VALUES " +
            "({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13})";

        protected void InsertLibraryRecord(int communicationID, string companyPath, string relativePath, string fullPath, int assignedToUserID, IDbTransaction oTran)
        {
            ArrayList oParameters = new ArrayList();

            oParameters.Add(new ObjectParameter("libr_CreatedBy", _oUser.prwu_WebUserID));
            oParameters.Add(new ObjectParameter("libr_CreatedDate", DateTime.Now));
            oParameters.Add(new ObjectParameter("libr_UpdatedBy", _oUser.prwu_WebUserID));
            oParameters.Add(new ObjectParameter("libr_UpdatedDate", DateTime.Now));
            oParameters.Add(new ObjectParameter("libr_TimeStamp", DateTime.Now));

            oParameters.Add(new ObjectParameter("libr_CompanyId", _oUser.prwu_BBID));
            oParameters.Add(new ObjectParameter("libr_PersonId", _oUser.peli_PersonID));
            oParameters.Add(new ObjectParameter("libr_UserId", assignedToUserID));
            oParameters.Add(new ObjectParameter("libr_FilePath", companyPath.Replace('\\', '/') + '/'));
            oParameters.Add(new ObjectParameter("libr_FileName", relativePath));

            oParameters.Add(new ObjectParameter("libr_CommunicationId", communicationID));
            oParameters.Add(new ObjectParameter("libr_FileSize", new FileInfo(fullPath).Length));
            oParameters.Add(new ObjectParameter("libr_PRFileId", DBNull.Value));
            oParameters.Add(new ObjectParameter("libr_LibraryId", GetObjectMgr().GetRecordID("Library", oTran)));

            string szSQL = GetObjectMgr().FormatSQL(SQL_INSERT_LIBRARY, oParameters);
            GetObjectMgr().ExecuteInsert("Library", szSQL, oParameters, oTran);
        }
    }
}
