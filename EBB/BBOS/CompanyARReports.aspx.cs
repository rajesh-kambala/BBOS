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

 ClassName: CompanyARReports
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
using System.Web.UI.WebControls;
using System.Web.UI;
using TSI.BusinessObjects;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Displays company data and listing.
    /// </summary>
    public partial class CompanyARReports : CompanyDetailsBase
    {
        CompanyData _ocd;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
            Page.Title = Resources.Global.BlueBookService;
            ((BBOS)Master).HideOldTopMenu();

            if (!IsPostBack)
            {
                hidCompanyID.Text = GetRequestParameter("CompanyID", true, true);

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

        protected void btnPrint_Click(object sender, ImageClickEventArgs e)
        {
            string szScript = "setTimeout(function() { printdiv(); }, 1000);"; //without delay the print window can be a garbled mess
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "printx", string.Format("<script>{0}</script>", szScript), false);
        }

        /// <summary>
        /// Populates the page.
        /// </summary>
        protected void PopulateForm()
        {
            string threshold = GetARThreshold();

            //Get cached company data
            _ocd = GetCompanyDataFromSession();

            IList parms = new ArrayList();
            parms.Add(new ObjectParameter("SubjectCompanyID", hidCompanyID.Text));
            parms.Add(new ObjectParameter("Threshold", threshold));
            parms.Add(new ObjectParameter("IndustryType", _ocd.szIndustryType));

            if (_ocd.szIndustryType != GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                //((EmptyGridView)gvARReports).EmptyTableRowText = "No AR Reports available for this company.";
                gvARReports.ShowHeaderWhenEmpty = true;
                gvARReports.EmptyDataText = GetNoResultsFoundMsg(Resources.Global.NoARReportsAvail); //"No AR Reports available for this company.";

                gvARReports.DataSource = GetDBAccess().ExecuteReader("usp_GetBBOSARDetails", parms, CommandBehavior.CloseConnection, null, CommandType.StoredProcedure);
                gvARReports.DataBind();
                EnableBootstrapFormatting(gvARReports);
            }
            else
            {
                pnlARReports.Visible = false;
            }

            litSummaryMonths.Text = threshold;
            using (IDataReader reader = GetDBAccess().ExecuteReader("usp_GetBBOSARSummary", parms, CommandBehavior.CloseConnection, null, CommandType.StoredProcedure))
            {
                if (reader.Read())
                {
                    litAvgMonthlyBalance.Text = UIUtils.GetFormattedCurrency(reader["AvgMonthlyBalance"]);
                    litHighBalance.Text = UIUtils.GetFormattedCurrency(reader["MaxMonthlyBalance"]);
                    litTotalNumCompanies.Text = UIUtils.GetFormattedInt((int)reader["ReportingCompanies"]);
                }
            }

            if ((_ocd.szIndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER) &&
                (litTotalNumCompanies.Text == "0"))
            {
                pnlNoData.Visible = true;
            }

            PopulateARReportsChart(Convert.ToInt32(hidCompanyID.Text));

            //LocalSource
            if (_ocd.bLocalSource)
            {
                ucCompanyDetailsHeaderMeister.MeisterVisible = true;
            }
        }

        private string GetARThreshold()
        {
            //Get cached company data
            CompanyData ocd = GetCompanyDataFromSession();

            string threshold = _oUser.prwu_ARReportsThrehold;
            if ((ocd.szIndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER))
            {
                threshold = Utilities.GetConfigValue("CompanyDetailsARAgingThresholdLumber", "3");
            }

            return threshold;
        }

        private const string INNRER_CELL = "{0}<br/>{1}%";
        protected string GetARAmount(object dollarVal, object percVal)
        {
            if (dollarVal == DBNull.Value)
            {
                return string.Empty;
            }

            return string.Format(INNRER_CELL, UIUtils.GetFormattedCurrency(dollarVal), UIUtils.GetFormattedDecimal(percVal, 2));
        }

        protected override bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.CompanyDetailsARReportsPage).HasPrivilege;
        }

        private const string SQL_AR_CHART =
           @" SELECT *
                 FROM (

               SELECT TOP(@Top)
	                   Year(praa_Date) [Year], 
	                   Month(praa_Date) [Month],
		               LEFT(DATENAME(MONTH,praa_Date),3) + ' ' + CAST(YEAR(praa_Date) as varchar(4)) as [DateDisplay],
			            praad_Amount0to29Percent = 100 * dbo.ufn_Divide(SUM(CASE WHEN praad_Amount0to29 < 0 THEN 0 ELSE praad_Amount0to29 END ), SUM(CASE WHEN praad_Amount0to29 < 0 THEN 0 ELSE praad_Amount0to29 END + CASE WHEN praad_Amount30to44 < 0 THEN 0 ELSE praad_Amount30to44 END + CASE WHEN praad_Amount45to60 < 0 THEN 0 ELSE praad_Amount45to60 END + CASE WHEN praad_Amount61Plus < 0 THEN 0 ELSE praad_Amount61Plus END)),
					    praad_Amount30to44Percent = 100 * dbo.ufn_Divide(SUM(CASE WHEN praad_Amount30to44 < 0 THEN 0 ELSE praad_Amount30to44 END ), SUM(CASE WHEN praad_Amount0to29 < 0 THEN 0 ELSE praad_Amount0to29 END + CASE WHEN praad_Amount30to44 < 0 THEN 0 ELSE praad_Amount30to44 END + CASE WHEN praad_Amount45to60 < 0 THEN 0 ELSE praad_Amount45to60 END + CASE WHEN praad_Amount61Plus < 0 THEN 0 ELSE praad_Amount61Plus END)),
						praad_Amount45to60Percent = 100 * dbo.ufn_Divide(SUM(CASE WHEN praad_Amount45to60 < 0 THEN 0 ELSE praad_Amount45to60 END ), SUM(CASE WHEN praad_Amount0to29 < 0 THEN 0 ELSE praad_Amount0to29 END + CASE WHEN praad_Amount30to44 < 0 THEN 0 ELSE praad_Amount30to44 END + CASE WHEN praad_Amount45to60 < 0 THEN 0 ELSE praad_Amount45to60 END + CASE WHEN praad_Amount61Plus < 0 THEN 0 ELSE praad_Amount61Plus END)),
						praad_Amount61PlusPercent = 100 * dbo.ufn_Divide(SUM(CASE WHEN praad_Amount61Plus < 0 THEN 0 ELSE praad_Amount61Plus END), SUM(CASE WHEN praad_Amount0to29 < 0 THEN 0 ELSE praad_Amount0to29 END + CASE WHEN praad_Amount30to44 < 0 THEN 0 ELSE praad_Amount30to44 END + CASE WHEN praad_Amount45to60 < 0 THEN 0 ELSE praad_Amount45to60 END + CASE WHEN praad_Amount61Plus < 0 THEN 0 ELSE praad_Amount61Plus END))
                 FROM vPRARAgingDetailOnProduce 
	            WHERE praad_SubjectCompanyID=@CompanyID
                  AND praad_TotalAmount > 0
	            GROUP BY Year(praa_Date), Month(praa_Date), LEFT(DATENAME(MONTH,praa_Date),3) + ' ' + CAST(YEAR(praa_Date) as varchar(4))
	            ORDER BY Year(praa_Date) DESC, Month(praa_Date) DESC
                     ) T1 ORDER BY [Year], [Month]";

        protected void PopulateARReportsChart(int companyID)
        {
            //Get cached company data
            CompanyData ocd = GetCompanyDataFromSession();

            pnlARChart.Visible = true;

            chartARChartLumber.Width = new Unit(775, UnitType.Pixel);
            chartARChartProduce.Width = new Unit(775, UnitType.Pixel);

            System.Web.UI.DataVisualization.Charting.Chart chart = chartARChartProduce;
            int threshold = Utilities.GetIntConfigValue("ARReportsBarChartThresholdProduce", 6);

            if ((ocd.szIndustryType) == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                chart = chartARChartLumber;
                threshold = Utilities.GetIntConfigValue("ARReportsBarChartThresholdLumber", 3);
                pnlChartProduce.Visible = false;
            }
            else
            {
                pnlChartLumber.Visible = false;
            }

            ArrayList parms = new ArrayList();
            parms.Add(new ObjectParameter("SubjectCompanyID", companyID));
            parms.Add(new ObjectParameter("Threshold", Utilities.GetIntConfigValue("ARReportsBarChartThreshold", threshold)));
            parms.Add(new ObjectParameter("IndustryType", ocd.szIndustryType));

            chart.DataSource = GetDBAccess().ExecuteReader("usp_GetBBOSARCharts", parms, CommandBehavior.CloseConnection, null, CommandType.StoredProcedure);
            chart.DataBind();
        }

        protected void SupressDataLabels(System.Web.UI.DataVisualization.Charting.Chart chart)
        {
            foreach (System.Web.UI.DataVisualization.Charting.Series series in chart.Series)
            {
                foreach (System.Web.UI.DataVisualization.Charting.DataPoint point in series.Points)
                {
                    if (point.YValues.Length > 0 && (double)point.YValues.GetValue(0) == 0)
                    {
                        point.LegendText = point.AxisLabel; //In case you have legend
                        point.AxisLabel = string.Empty;
                        point.Label = string.Empty;
                    }
                }
            }
        }

        protected void btARReportOnClick(object sender, EventArgs e)
        {
            //Get cached company data
            CompanyData ocd = GetCompanyDataFromSession();

            Response.Redirect(PageConstants.Format(PageConstants.GET_REPORT, GetReport.AR_REPORTS) + "&CompanyID=" + hidCompanyID.Text + "&Threshold=" + GetARThreshold() + "&IndustryType=" + ocd.szIndustryType);
        }

    }
}