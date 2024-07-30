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

 ClassName: Purchases
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/

using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Threading;
using System.Web.UI;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using TSI.DataAccess;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This page lists the purchases made by the current user's company in the past 24 
    /// hours.  This value will be configurable
    /// 
    /// The user will be allowed to click on the icon in the download column to retrieve the
    /// report.
    /// 
    /// For members this page is at the enterprise level.  Users can see reports purchased by
    /// other users at the same enterprise (HB and branches).
    /// </summary>
    public partial class Purchases : PageBase
    {
        // SQL to retrieve the recent business reports purchased for this user's company
        public const string SQL_GET_BR_REQUESTS =
            @"SELECT prrc_AssociatedID, prreq_CreatedDate, 
                     dbo.ufn_GetCustomCaptionValue('comp_PRIndustryType', comp_PRIndustryType, '{0}') As IndustryType, 
                     dbo.ufn_GetCustomCaptionValue('comp_PRType_BBOS', comp_PRType, '{0}') As CompanyType, 
                     dbo.ufn_HasNote({1}, {2}, comp_CompanyID, 'C') As HasNote, 
                     CityStateCountryShort, comp_PRBookTradestyle, comp_PRLegalName, comp_PRLastPublishedCSDate, comp_PRListingStatus, 
                     dbo.ufn_FormatPerson(Pers_FirstName, Pers_LastName, Pers_MiddleName, pers_PRNickname1, Pers_Suffix) AS OrderedBy, 
                     dbo.ufn_GetWebUserLocation(prreq_CreatedBy) AS OrderedByLocation, prreq_RequestTypeCode, prreq_RequestID,
                     dbo.ufn_HasNewClaimActivity(comp_PRHQID, '{4}') as HasNewClaimActivity, 
                     dbo.ufn_HasMeritoriousClaim(comp_PRHQID, '{5}') as HasMeritoriousClaim,
                     dbo.ufn_HasCertification(comp_PRHQID) as HasCertification,
                     dbo.ufn_HasCertification_Organic(comp_PRHQID) as HasCertification_Organic,
                     dbo.ufn_HasCertification_FoodSafety(comp_PRHQID) as HasCertification_FoodSafety,
                     comp_PRLocalSource
                FROM PRRequest WITH (NOLOCK) 
                     INNER JOIN PRRequestDetail WITH (NOLOCK) on prreq_RequestID = prrc_RequestID 
                     INNER JOIN PRWebUser WITH (NOLOCK) ON prreq_CreatedBy = prwu_WebUserID 
                     INNER JOIN vPRBBOSCompanyList ON prrc_AssociatedID = comp_CompanyID 
                     INNER JOIN Person_Link WITH (NOLOCK) ON prwu_PersonLinkID = PeLi_PersonLinkId 
                     INNER JOIN Person WITH (NOLOCK) ON dbo.Person_Link.PeLi_PersonId = Pers_PersonId 
               WHERE prreq_HQID = {1} AND prreq_RequestTypeCode LIKE 'BR%' 
                 AND prreq_CreatedDate >= '{3}' AND prreq_Deleted IS NULL 
                 AND prrc_AssociatedType = 'C'";

        // SQL to retrieve the company count for the marketing lists displayed
        protected const string SQL_GET_NUM_OF_COMPANIES =
            @"SELECT COUNT (*) AS NumOfCompanies 
                FROM PRRequestDetail 
               WHERE prrc_RequestID = {0}";

        // SQL to retrieve the company id list for the related marketing list.  This is used to 
        // handle the download onclick events for the marketing lists
        protected const string SQL_GET_COMPANY_ID_LIST =
            @"SELECT prrc_AssociatedID 
                FROM PRRequestDetail WITH (NOLOCK) 
               WHERE prrc_RequestID = {0} 
                 AND prrc_AssociatedType = 'C' 
                 AND prrc_Deleted IS NULL ";

        /// <summary>
        /// Calls page functions required to build and process this page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            // Set page title
            SetPageTitle(Resources.Global.Purchases); //SetPageTitle(Resources.Global.BusinessReportRequestsLast72Hours);

            // Setup formatted page text
            litHeaderText.Text = String.Format(Resources.Global.PurchasesHeaderText, Utilities.GetIntConfigValue("RecentPurchasesAvailabilityThreshold", 72).ToString());
            litInstructionsText.Text = Resources.Global.PurchaseInstructionsText;
            litFooterText.Text = String.Format(Resources.Global.PurchasesFooterText, PageConstants.TERMS);

            if (!IsPostBack)
            {
                PopulateForm();
            }

            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_FUNCTIONS2_FILE));
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_VALIDATION_FILE));
        }

        /// <summary>
        /// Check users page level authorization
        /// </summary>
        /// <returns></returns>
        override protected bool IsAuthorizedForPage()
        {
            return _oUser.IsLimitado || _oUser.HasPrivilege(SecurityMgr.Privilege.PurchasesPage).HasPrivilege;
        }

        /// <summary>
        /// Check users control/data level authorization
        /// </summary>
        /// <returns></returns>
        protected override bool IsAuthorizedForData()
        {
            return true;
        }

        /// <summary>
        /// Populates the form controls.
        /// </summary>
        private void PopulateForm()
        {
            // Display Business Report List
            // Generate the sql required to retrieve the purchased business reports            
            CultureInfo m_UsCulture = new CultureInfo(ENGLISH_CULTURE);
            string szThreshold_BR = DateTime.Now.AddHours(0 - Utilities.GetIntConfigValue("RecentPurchasesAvailabilityThreshold", 72)).ToString(m_UsCulture);
            //DateTime dtThreshold_BR = DateTime.Now.AddHours(0 - Utilities.GetIntConfigValue("RecentPurchasesAvailabilityThreshold", 72));

            string szSQL_BR = null;
            object[] args_BR = { _oUser.prwu_Culture,
                                _oUser.prwu_HQID,
                                _oUser.prwu_WebUserID,
                                szThreshold_BR,
                                DateTime.Today.AddDays(0 - Configuration.ClaimActivityNewThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss"),
                                DateTime.Today.AddDays(0 - Configuration.ClaimActivityMeritoriousThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss") };

            szSQL_BR = string.Format(SQL_GET_BR_REQUESTS, args_BR);
            szSQL_BR += GetOrderByClause(gvBusinessReports);

            // Create empty grid view in case 0 results are found
            //((EmptyGridView)gvBusinessReports).EmptyTableRowText = GetNoResultsFoundMsg(Resources.Global.Companies);
            gvBusinessReports.ShowHeaderWhenEmpty = true;
            gvBusinessReports.EmptyDataText = GetNoResultsFoundMsg(Resources.Global.Companies);

            // Execute search and bind results to grid
            gvBusinessReports.DataSource = GetDBAccess().ExecuteReader(szSQL_BR, CommandBehavior.CloseConnection);
            gvBusinessReports.DataBind();
            EnableBootstrapFormatting(gvBusinessReports);
            gvBusinessReports.Columns[2].Visible = false;

            OptimizeViewState(gvBusinessReports);

            // Display the number of matching records found
            lblBRRecordCount.Text = string.Format(Resources.Global.RecordCountFoundMsg, gvBusinessReports.Rows.Count, Resources.Global.BusinessReports);

            if (gvBusinessReports.Rows.Count == 0)
            {
                btnEmailPurchases.Enabled = false;
            }
            else
            {
                txtAttachmentEmail.Text = _oUser.Email;
                btnSendEmailAttachments.Attributes.Add("onclick", "return emailPurchases();");
            }

            if (Session["EmailPurchases"] != null)
            {
                List<Report> reports = (List<Report>)Session["EmailPurchases"];
                SendEmailAttchments(reports);
                Session.Remove("EmailPurchases");
            }
        }

        /// <summary>
        /// Helper method that helps with bi-directional sorting.  The default sort order
        /// for this grid should be by company name
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void GridView_Sorting(Object sender, GridViewSortEventArgs e)
        {
            SetSortingAttributes((GridView)sender, e);
            PopulateForm();
        }

        /// <summary>
        /// Adds the sort indicator to the appropriate column
        /// header.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void GridView_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            SetSortIndicator((GridView)sender, e);
        }

        #region Helper methods for GridViews
        /// <summary>
        /// Helper method to generate the business report download link.
        /// </summary>
        /// <param name="iCompanyID">Company ID</param>
        /// <param name="szRequestTypeCode">Request Type Code</param>
        /// <param name="iRequestID"></param>
        /// <returns></returns>
        protected string GetBusinessReportDownloadLink(int iCompanyID, string szRequestTypeCode, int iRequestID)
        {
            string szDownloadLink = "";
            string szReportURL = "";

            string szRequestType = "";
            string szLevel = "";
            if (szRequestTypeCode == "BRF")
            {
                szRequestType = GetReport.BUSINESS_REPORT_FREE;
                szLevel = "4"; //the free report is really a sub-type of BR4
            }
            else
            {
                szRequestType = GetReport.BUSINESS_REPORT;
                szLevel = szRequestTypeCode.Replace("BR", "");
            }

            // Create company analysis export url with appropriate parameters
            szReportURL = PageConstants.Format(PageConstants.GET_REPORT + "&CompanyID={1}&Level={2}&RequestID={3}", szRequestType, iCompanyID, szLevel, iRequestID);

            // Create PDF icon link to this report
            szDownloadLink += "<a href=\"" + szReportURL + "\">";
            szDownloadLink += "<img src=\"" + UIUtils.GetImageURL("icon-download.png") + "\" alt=\"" + Resources.Global.DownloadPDFDocument + "\" border=\"0\">";
            szDownloadLink += "<br/><span class=\"annotation\">" + Resources.Global.Download + "</span></a>";

            return szDownloadLink;
        }

        /// <summary>
        /// Helper method to retrieve the number of companies included in a marketing list.
        /// </summary>
        /// <param name="iRequestID">Request ID</param>
        /// <returns></returns>
        protected string GetCompanyCount(int iRequestID)
        {
            string szSQL = "";
            int iCount = 0;

            // Generate SQL to retrieve company count
            szSQL = string.Format(SQL_GET_NUM_OF_COMPANIES, iRequestID);

            IDBAccess oDataAccess = DBAccessFactory.getDBAccessProvider();
            oDataAccess.Logger = _oLogger;
            IDataReader oReader = oDataAccess.ExecuteReader(szSQL, CommandBehavior.CloseConnection);
            try
            {
                while (oReader.Read())
                {
                    iCount = oDataAccess.GetInt32(oReader, "NumOfCompanies");
                }
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }

            return iCount.ToString();
        }

        /// <summary>
        /// Helper method to retrieve the Level from on the Request Type Code
        /// </summary>
        /// <param name="iRequestID">Request ID</param>
        /// <param name="szRequestTypeCode">Request Type Code</param>
        /// <returns></returns>
        protected string GetRequestLevel(int iRequestID, string szRequestTypeCode)
        {
            string szLevel = "";

            if (szRequestTypeCode.Contains("BR"))
                szLevel = szRequestTypeCode.Replace("BR", "");

            if (szRequestTypeCode.Contains("ML"))
                szLevel = szRequestTypeCode.Replace("ML", "");

            return szLevel;
        }


        #endregion

        protected void btnSendEmailAttachmentsOnClick(object sender, EventArgs e)
        {
            string selectedIndexes = Request.Form["cbBusinessReport"];

            if (string.IsNullOrEmpty(selectedIndexes))
            {
                AddUserMessage("Please select a purchase.");
                return;
            }

            string[] indexes = selectedIndexes.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);

            List<Report> reports = new List<Report>();
            foreach (string index in indexes)
            {
                reports.Add(new Report(GetReport.BUSINESS_REPORT,
                                       Request.Form["hidBRAssociatedID" + index],
                                       Request.Form["hidBRRequestID" + index],
                                       Request.Form["hidBRRequestTypeCode" + index]));
            }

            SendEmailAttchments(reports);
            PopulateForm();
        }

        protected void SendEmailAttchments(List<Report> reports)
        {
            ReportEmailer reportEmailer = new ReportEmailer();
            reportEmailer.WebUser = _oUser;
            reportEmailer.Logger = _oLogger;
            reportEmailer.IsEligibleForEquifaxData = IsEligibleForEquifaxData();
            reportEmailer.Email = txtAttachmentEmail.Text;
            reportEmailer.Reports = reports;
            reportEmailer.TemplateFile = Server.MapPath(UIUtils.GetTemplateURL("ReportEmailerBody.htm"));
            reportEmailer.ZipFiles = cbAttachmentZipFiles.Checked;

            Thread newThread = new Thread(reportEmailer.SendEmailAttachments);
            newThread.Start();

            AddUserMessage("The selected purchases have been emailed to " + txtAttachmentEmail.Text);
        }
    }
}
