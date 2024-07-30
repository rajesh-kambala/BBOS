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

 ClassName: MembershipSummary.aspx.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Data;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;
using TSI.DataAccess;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    public partial class MembershipSummary : EMCWizardBase
    {
        DateTime _dtPurchasesThreshold;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            //ITA users have their own special membership upgrade path
            if (_oUser.IsLimitado)
            {
                Response.Redirect(PageConstants.PURCHASE_MEMBERSHIP);
            }

            SetPageTitle(Resources.Global.ManageMembership);
            
            // Add company submenu to this page
            SetSubmenu("btnManageMembership", blnDisableValidation: true);

            _dtPurchasesThreshold = DateTime.Now.AddHours(0 - Utilities.GetIntConfigValue("RecentPurchasesAvailabilityThreshold", 72));

            if (!IsPostBack)
            {
                SetSortField(gvServices, "Name");
                SetSortField(gvUsageHistory, "prsuu_CreatedDate");
                SetSortAsc(gvUsageHistory, false);
                PopulateForm();
            }
        }

        protected const string SQL_SELECT_SERVICES =
            @"SELECT {0} As Name, {1} As Description, prse_NextAnniversaryDate, CityStateCountryShort, CASE WHEN prod_code IN ('UNITS-PRODUCE', 'UNITS-LUMBER') THEN QuantityOrdered/dbo.ufn_GetProductPrice(47, 16010) ELSE QuantityOrdered END as   QuantityOrdered  
                FROM PRService 
                     INNER JOIN Company WITH (NOLOCK) ON prse_CompanyID = comp_CompanyID 
                     INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID 
	                 INNER JOIN NewProduct WITH (NOLOCK) ON prse_ServiceCode = prod_code AND prod_PRRecurring = 'Y' 
               WHERE prse_HQID = @prse_HQID
                 AND prod_Code <> 'CSUPD'";

        protected const string SQL_SELECT_USAGE_HISTORY =
           @"SELECT vPRServiceUnitUsageHistory.*, CityStateCountryShort 
               FROM vPRServiceUnitUsageHistory  
                    INNER JOIN Company WITH (NOLOCK) ON prsuu_CompanyID = comp_CompanyID 
                    INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID 
              WHERE prsuu_CreatedDate > DATEADD(MONTH, {0}, GETDATE())  
                AND prsuu_HQID = @prse_HQID ";

        protected const string SQL_SELECT_ALLOC_HISTORY =
            @"SELECT dbo.ufn_GetCustomCaptionValue('prun_AllocationTypeCode', prun_AllocationTypeCode, '{0}') As AllocationType, CityStateCountryShort, prun_ExpirationDate, prun_UnitsAllocated, UnitsUsed, prun_UnitsRemaining
                FROM vPRServiceUnitAllocHistory 
                     INNER JOIN Company WITH (NOLOCK) ON prun_CompanyID = comp_CompanyID 
                     INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID 
               WHERE prun_HQID=@prse_HQID  
            ORDER BY prun_ExpirationDate DESC";

        protected const string SQL_SELECT_EXPORT_USAGE =
            @"SELECT 
	            prwu_Firstname + ' ' + prwu_LastName [Person Name],
	            vprl.CityStateCountryShort [Location],
	            FORMAT(prrc_CreatedDate, 'yyyy-MM') [Month],
	            COUNT(DISTINCT prrc_AssociatedID) as [ExportCount]
            FROM PRRequest WITH (NOLOCK)
	            INNER JOIN PRRequestDetail WITH (NOLOCK) ON prreq_RequestID = prrc_RequestID
                INNER JOIN PRWebUser WITH (NOLOCK) ON prwu_WebUserID = prreq_WebUserID
	            INNER JOIN Company c ON c.Comp_CompanyId = prwu_BBID
	            INNER JOIN vPRLocation vprl ON c.comp_PRListingCityID=vprl.prci_CityID
            WHERE 
                prreq_CompanyID = @BBID
	            AND prrc_CreatedDate > DATEADD(MM, -5, DATEADD(DAY,1,EOMONTH(GETDATE(),-1)))
                AND prreq_RequestTypeCode IN ('CCE','CEL','CE','CDEL','CDE','BBSi_IE')
            GROUP BY prwu_Firstname + ' ' + prwu_LastName,FORMAT(prrc_CreatedDate, 'yyyy-MM'), vprl.CityStateCountryShort
            ORDER BY FORMAT(prrc_CreatedDate, 'yyyy-MM') DESC, prwu_Firstname + ' ' + prwu_LastName ASC";

        protected const string SQL_SELECT_BUSINESS_VALUATION =
            @"SELECT 
	            prbv_CreatedDate,
	            dbo.ufn_FormatPerson(Pers_FirstName, Pers_LastName, Pers_MiddleName, Pers_PRNickname1, Pers_Suffix) As [Created By],
                dbo.ufn_GetCustomCaptionValue('prbv_StatusCode', prbv_StatusCode, '{0}') As Status,
	            prbv_FileName,
                prbv_Guid,
                prbv_StatusCode
            FROM PRWebUser 
	            INNER JOIN PRBusinessValuation WITH(NOLOCK) ON prbv_CompanyID = prwu_BBID AND prbv_Deleted IS NULL 
	            INNER JOIN Person_Link ON PeLi_PersonLinkId = prwu_PersonLinkID
	            INNER JOIN Person ON pers_PersonID = PeLi_PersonId
            WHERE
	            prwu_WebUserID = @WebUserID";

        /// <summary>
        /// Populates the three grids.
        /// </summary>
        protected void PopulateForm()
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prse_HQID", _oUser.prwu_HQID));

            string szSQL = string.Format(SQL_SELECT_SERVICES,
                                         GetObjectMgr().GetLocalizedColName("prod_Name"),
                                         GetObjectMgr().GetLocalizedColName("prod_PRDescription"));
            szSQL += GetOrderByClause(gvServices);

            //((EmptyGridView)gvServices).EmptyTableRowText = GetNoResultsFoundMsg(Resources.Global.AnnualSubscriptionServices);
            gvServices.ShowHeaderWhenEmpty = true;
            gvServices.EmptyDataText = GetNoResultsFoundMsg(Resources.Global.AnnualSubscriptionServices);

            gvServices.DataSource = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            gvServices.DataBind();
            EnableBootstrapFormatting(gvServices);

            litUsageHistory.Text = string.Format(Resources.Global.ServiceUnitUsageforthePastNMonths, Utilities.GetIntConfigValue("ServiceUnitUsageHistoryThreshold", 12));
            szSQL = string.Format(SQL_SELECT_USAGE_HISTORY,
                                  0 - Utilities.GetIntConfigValue("UsageHistoryThreshold", 12));
            szSQL += GetOrderByClause(gvUsageHistory);

            //((EmptyGridView)gvUsageHistory).EmptyTableRowText = GetNoResultsFoundMsg(Resources.Global.ServiceUnitUsage);
            gvUsageHistory.ShowHeaderWhenEmpty = true;
            gvUsageHistory.EmptyDataText = GetNoResultsFoundMsg(Resources.Global.ServiceUnitUsage);

            gvUsageHistory.DataSource = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            gvUsageHistory.DataBind();
            EnableBootstrapFormatting(gvUsageHistory);

            szSQL = string.Format(SQL_SELECT_ALLOC_HISTORY, _oUser.prwu_Culture);
            gvAllocationHistory.DataSource = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            gvAllocationHistory.DataBind();
            EnableBootstrapFormatting(gvAllocationHistory);

            ArrayList oParametersUsage = new ArrayList();
            oParametersUsage.Add(new ObjectParameter("WebUserID", _oUser.prwu_WebUserID));
            oParametersUsage.Add(new ObjectParameter("BBID", _oUser.prwu_BBID));

            litRatingRep.Text = GetSpecalistInfo(0);
            litCSRep.Text = GetSpecalistInfo(4);
            litSaleRep.Text = GetSpecalistInfo(1);

            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                btnPurchaseExpressUpdates.Visible = false;
                btnAdCampaigns.Enabled = false;
                //btnUpgradeMembership.Visible = false;
                btnPurchaseLSSAccess.Visible = false;
                btnPurchaseExpressUpdates.Visible = false; //Defect 7172
            }


            if (Configuration.IsBeta)
            {
                btnUpgradeMembership.Enabled = false;
                btnPurchaseAdditionalUnits.Enabled = false;
            }

            ApplyReadOnlyCheck(btnUpgradeMembership);
            ApplyReadOnlyCheck(btnPurchaseAdditionalUnits);

            if(_oUser.IsLimitado)
            {
                btnUserAccessList.Visible = false;
                btnAdCampaigns.Visible = false;
                btnPurchaseAdditionalUnits.Visible = false;
                btnPurchaseLSSAccess.Visible = false;
                pnlUsageHistory.Visible = false;
                pnlAllocationHistory.Visible = false;
            }

            if(_oUser.IsLumber_STANDARD())
            {
                //Defect 6853 - show export usage for L200 members
                pnlExportUsage.Visible = true;

                gvExportUsage.ShowHeaderWhenEmpty = false;
                gvExportUsage.EmptyDataText = "No " + Resources.Global.ExportUsage + " data found.";

                szSQL = SQL_SELECT_EXPORT_USAGE;
                gvExportUsage.DataSource = GetDBAccess().ExecuteReader(szSQL, oParametersUsage, CommandBehavior.CloseConnection, null);
                gvExportUsage.DataBind();
                EnableBootstrapFormatting(gvExportUsage);
            }

            BusinessValuation.BusinessValuationData oBVData = PageControlBaseCommon.GetBusinessValuationData(_oUser);
            if(oBVData.CanViewBusinessValuations || oBVData.BusinessValuationID > 0)
            {
                pnlBusinessValuation.Visible = true;

                gvBusinessValuation.ShowHeaderWhenEmpty = false;
                gvBusinessValuation.EmptyDataText = "No " + Resources.Global.BusinessValuation + " data found.";

                szSQL = string.Format(SQL_SELECT_BUSINESS_VALUATION, _oUser.prwu_Culture);
                gvBusinessValuation.DataSource = GetDBAccess().ExecuteReader(szSQL, oParametersUsage, CommandBehavior.CloseConnection, null);
                gvBusinessValuation.DataBind();
                EnableBootstrapFormatting(gvBusinessValuation);
            }
        }



        /// <summary>
        /// Based on the purchase threshold, determines if the purchase is still available
        /// on the Purchases page and if so, hyperlinks the type.
        /// </summary>
        /// <param name="dtCreatedDateTime"></param>
        /// <param name="szUsageTypeCode"></param>
        /// <returns></returns>
        protected string GetType(DateTime dtCreatedDateTime, string szUsageTypeCode)
        {
            string szType = GetReferenceValue("prsuu_UsageTypeCode", szUsageTypeCode);

            if (dtCreatedDateTime < _dtPurchasesThreshold)
            {
                return szType;
            }

            return UIUtils.GetHyperlink(PageConstants.BROWSE_PURCHASES, szType);
        }

        protected const string SQL_SELECT_ARTICLE_NAME = "SELECT prpbar_Name FROM PRPublicationArticle WHERE prpbar_PublicationArticleID=@prpbar_PublicationArticleID";
        protected string GetAddtionalInfo(string szUsageTypeCode, object iRegardingObjectID, object oRequestedCompanyName)
        {
            switch (szUsageTypeCode)
            {
                case "OBR":
                case "VBR":
                case "FBR":
                case "EBR":
                case "MBR":
                    if (oRequestedCompanyName != DBNull.Value)
                    {
                        return Convert.ToString(oRequestedCompanyName);
                    }
                    break;
                case "BP":
                    ArrayList oParameters = new ArrayList();
                    oParameters.Add(new ObjectParameter("prpbar_PublicationArticleID", iRegardingObjectID));
                    IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
                    oDBAccess.Logger = _oLogger;
                    string szName = (string)oDBAccess.ExecuteScalar(SQL_SELECT_ARTICLE_NAME, oParameters);
                    return szName;
            }

            return string.Empty;
        }

        protected const string SQL_SELECT_SPECIALIST =
                @"SELECT RTRIM(user_FirstName) + ' ' + RTRIM(user_LastName), RTRIM(user_EmailAddress), user_Phone + ' x' + user_Extension As Phone 
                    FROM Users WITH (NOLOCK)
                   WHERE user_UserID = dbo.ufn_GetPRCoSpecialistUserId(@CompanyID, @TypeId)";
        protected string GetSpecalistInfo(int iType)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", _oUser.prwu_HQID));
            oParameters.Add(new ObjectParameter("TypeID", iType));

            StringBuilder sbSpecialist = new StringBuilder();
            IDataReader oReader = GetDBAccess().ExecuteReader(SQL_SELECT_SPECIALIST, oParameters, CommandBehavior.CloseConnection, null);
            try
            {
                if (oReader.Read())
                {
                    sbSpecialist.Append(oReader.GetString(0));
                    sbSpecialist.Append("<br/>");
                    if (oReader[2] != DBNull.Value)
                    {
                        sbSpecialist.Append(oReader.GetString(2));
                        sbSpecialist.Append("<br/>");
                    }
                    sbSpecialist.Append(UIUtils.GetHyperlink("mailto:" + oReader.GetString(1), oReader.GetString(1)));
                }
            }
            finally
            {
                oReader.Close();
            }

            return sbSpecialist.ToString();
        }

        /// <summary>
        /// Helper method that helps with bi-directional sorting
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void GridView_Sorting(Object sender, GridViewSortEventArgs e)
        {
            SetSortingAttributes((GridView)sender, e);
            PopulateForm();
        }

        protected const string SQL_SELECT_ALLOC_TOTALS =
            @"SELECT SUM(prun_UnitsAllocated), SUM(prun_UnitsRemaining), SUM(UnitsUsed) 
                FROM vPRServiceUnitAllocHistory 
               WHERE prun_HQID=@prun_HQID";

        /// <summary>
        /// Formats the footer by displaying the summary info.  Also sets the literal
        /// controls at the top of the page with much of the same info.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void GridView_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            SetSortIndicator((GridView)sender, e);

            if ((((GridView)sender).ID == gvAllocationHistory.ID) &&
                (e.Row.RowType == DataControlRowType.Footer))
            {
                e.Row.Cells[0].Visible = false;
                e.Row.Cells[1].Visible = false;
                e.Row.Cells[2].Text = Resources.Global.Totals + ":";
                e.Row.Cells[2].ColumnSpan = 3;

                ArrayList oParameters = new ArrayList();
                oParameters.Add(new ObjectParameter("prun_HQID", _oUser.prwu_HQID));
                IDataReader oReader = GetDBAccess().ExecuteReader(SQL_SELECT_ALLOC_TOTALS, oParameters, CommandBehavior.CloseConnection, null);
                try
                {
                    if (oReader.Read())
                    {
                        e.Row.Cells[3].Text = oReader.GetInt32(0).ToString("###,##0");
                        e.Row.Cells[4].Text = oReader.GetInt32(2).ToString("###,##0");
                        e.Row.Cells[5].Text = oReader.GetInt32(1).ToString("###,##0");
                    }
                }
                finally
                {
                    oReader.Close();
                }
            }
        }

        protected override bool IsAuthorizedForPage()
        {
            ApplySecurity(btnPurchaseAdditionalUnits, SecurityMgr.Privilege.BusinessReportPurchase);
            ApplySecurity(btnUserAccessList, SecurityMgr.Privilege.PersonAccessListPage);

            return _oUser.HasPrivilege(SecurityMgr.Privilege.ManageMembershipPage).HasPrivilege;
        }

        protected override bool IsAuthorizedForData()
        {
            return true;
        }

        protected void btnUpgradeMembershipOnClick(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.MEMBERSHIP_SELECT);
        }
        protected void btnUserAccessListOnClick(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.PERSON_ACCESS_LIST);
        }
        protected void btnAdCampaignOnClick(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.AD_CAMPAIGN_LIST);
        }
        protected void btnPurchaseAdditionalUnitsOnClick(object sender, EventArgs e)
        {
            Session["ReturnURL"] = PageConstants.MEMBERSHIP_SUMMARY;
            Response.Redirect(PageConstants.SERVICE_UNIT_PURCHASE);
        }
        protected void btnPurchaseExpressUpdatesOnClick(object sender, EventArgs e)
        {
            Session["ReturnURL"] = PageConstants.MEMBERSHIP_SUMMARY;
            Response.Redirect(PageConstants.EXPRESSUPDATES_PURCHASE);
        }
        protected void btnPurchaseLSSAccessOnClick(object sender, EventArgs e)
        {
            Session["ReturnURL"] = PageConstants.MEMBERSHIP_SUMMARY;
            Response.Redirect(PageConstants.LSS_PURCHASE);
        }

        /// <summary>
        /// Helper method to return a handle to the Company Details Header used on the page to display 
        /// the company BB #, name, and location
        /// </summary>
        /// <returns></returns>
        protected override EMCW_CompanyHeader GetEditCompanyWizardHeader()
        {
            return (EMCW_CompanyHeader)ucCompanyDetailsHeader;
        }

        protected void gvBusinessValuation_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                string prbv_FileName = DataBinder.Eval(e.Row.DataItem, "prbv_FileName") as String;
                string prbv_Guid = DataBinder.Eval(e.Row.DataItem, "prbv_Guid") as String;
                string prbv_StatusCode = DataBinder.Eval(e.Row.DataItem, "prbv_StatusCode") as String;

                Literal litDownloadLink = (Literal)e.Row.FindControl("litDownloadLink");

                if(!string.IsNullOrEmpty(prbv_FileName))
                    litDownloadLink.Text = BuildDownloadLink(prbv_FileName, prbv_Guid, prbv_StatusCode);
            }
        }

        public string BuildDownloadLink(string prbv_FileName, string prbv_Guid, string prbv_Status)
        {
            if (prbv_Status == "S")
                return $"<a href=\"{PageConstants.BUSINESS_VALUATION_DOWNLOAD}?g={prbv_Guid}\">{prbv_FileName}</a>";
            else
                return "";
        }
    }
}
