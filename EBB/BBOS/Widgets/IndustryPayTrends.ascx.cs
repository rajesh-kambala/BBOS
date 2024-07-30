using PRCo.EBB.BusinessObjects;
using System;
using System.Collections;
using System.Data;
using System.Web.UI.DataVisualization.Charting;
using TSI.BusinessObjects;
using TSI.DataAccess;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web.Widgets
{
    public partial class IndustryPayTrends : WidgetControlBase
    {
        private const string SQL_INDUSTRY_PAY_TRENDS_TES =
            @"SELECT PayRating, 
			       REPLACE(REPLACE(SUBSTRING(PayRating, 0, LEN(PayRating)-10),' -','-'),'- ','-') AS PayRatingShort,
                   PayRatingCount, 
                   TotalCount, 
                   CAST(PayRatingCount as Decimal(10,3)) / CAST(TotalCount as Decimal(10,3)) as Pct 
                  FROM (SELECT prtr_PayRatingId,  
                   CAST(capt_us as varchar(100)) PayRating, 
                   prpy_Order, 
                   COUNT(1) PayRatingCount 
                  FROM PRTradeReport WITH (NOLOCK) 
                   INNER JOIN Company C1 WITH (NOLOCK) ON prtr_SubjectID = C1.comp_CompanyID 
                   INNER JOIN Company C2 WITH (NOLOCK) ON C2.Comp_CompanyId = prtr_ResponderId AND C2.comp_PRIgnoreTES IS NULL
                   INNER JOIN PRPayRating ON prtr_PayRatingID = prpy_PayRatingID 
                   INNER JOIN Custom_Captions ON prpy_Name = capt_code AND capt_family = 'prpy_Name' 
                 WHERE C1.comp_PRIndustryType <> 'L' 
                   AND C1.comp_PRListingStatus = 'L'  
                   AND prtr_PayRatingId IS NOT NULL 
                   AND prtr_PayRatingId <> '' 
                   AND prtr_Date >= CAST(DATEADD(month, -12, GETDATE()) as Date) 
                GROUP BY prtr_PayRatingId, CAST(capt_us as varchar(100)), prpy_Order) T1 
                CROSS JOIN (SELECT COUNT(1) as TotalCount 
                  FROM PRTradeReport WITH (NOLOCK) 
                    INNER JOIN Company C1 WITH (NOLOCK) ON prtr_SubjectID = C1.comp_CompanyID 
                    INNER JOIN Company C2 WITH (NOLOCK) ON C2.Comp_CompanyId = prtr_ResponderId AND C2.comp_PRIgnoreTES IS NULL
                 WHERE C1.comp_PRIndustryType <> 'L' 
                   AND C1.comp_PRListingStatus = 'L' -- Listed only? 
                   AND prtr_PayRatingId IS NOT NULL 
                   AND prtr_PayRatingId <> '' 
                   AND prtr_Date >= CAST(DATEADD(month, -12, GETDATE()) as Date)) T2 
                ORDER BY prpy_Order ";

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if (!Page.IsPostBack)
            {
                if (WebUser != null)
                {
                    // Execute search and bind results to grid
                    PopulateChart();
                }
            }
        }

        public bool ChangeWidgetsLinkVisible
        {
            set { hlChangeWidgets.Visible = value; }
        }

        private void PopulateChart()
        {
            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            chartPayTrends_TES.DataSource = oDBAccess.ExecuteReader(SQL_INDUSTRY_PAY_TRENDS_TES, null, CommandBehavior.CloseConnection, null);
            chartPayTrends_TES.DataBind();

            foreach (Series s in chartPayTrends_TES.Series)
            {
                foreach(DataPoint dp in s.Points)
                {
                    dp.Label = "#PERCENT{P1}";
                    dp.LegendText = "#VALX";

                    if (dp.AxisLabel == "1-14 days")
                        dp.Color = System.Drawing.ColorTranslator.FromHtml("#43A047"); //dark green
                    else if (dp.AxisLabel == "15-21 days")
                        dp.Color = System.Drawing.ColorTranslator.FromHtml("#C5E1A5"); //light green
                    else if (dp.AxisLabel == "22-28 days")
                        dp.Color = System.Drawing.ColorTranslator.FromHtml("#84FFFF"); //aqua blue
                    else if (dp.AxisLabel == "29-35 days")
                        dp.Color = System.Drawing.ColorTranslator.FromHtml("#CFD8DC"); //gray
                    else if (dp.AxisLabel == "36-45 days")
                        dp.Color = System.Drawing.ColorTranslator.FromHtml("#FFEE58"); //yellow
                    else if (dp.AxisLabel == "46-60 days")
                        dp.Color = System.Drawing.ColorTranslator.FromHtml("#FFA726"); //orange
                    else
                        dp.Color = System.Drawing.ColorTranslator.FromHtml("#D32F2F"); //red

                    if (WebUser.prwu_Culture == PageBase.SPANISH_CULTURE)
                    {
                        dp.AxisLabel = dp.AxisLabel.Replace("days", Resources.Global.Days);
                    }
                }
            }

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("NumMonths", Utilities.GetIntConfigValue("IndustryPayTrendsARCount", 12)));

            if (WebUser.prwu_IndustryType != GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                //NOT LUMBER
                DataSet dsPayTrends_AR = oDBAccess.ExecuteStoredProcedure("usp_IndustryPayTrendAR", oParameters);

                chartPayTrends_AR.DataSource = dsPayTrends_AR;
                chartPayTrends_AR.DataBind();

                foreach (Series s in chartPayTrends_AR.Series)
                {
                    foreach (DataPoint dp in s.Points)
                    {
                        dp.Label = "";
                        dp.LegendText = "#VALX";
                    }

                    if (WebUser.prwu_Culture == PageBase.SPANISH_CULTURE)
                    {
                        s.Name = s.Name.Replace("Days", Resources.Global.Days);
                        s.Name = s.Name.Replace("Current", Resources.Global.Current);
                    }
                }

                chartPayTrends_AR.ChartAreas["ChartArea1"].AxisX.LabelStyle.Angle = -90;

                chartPayTrends_AR.Visible = true;
            }
            else
            {
                //LUMBER
                DataSet dsPayTrends_AR_Lumber = oDBAccess.ExecuteStoredProcedure("usp_IndustryPayTrendAR_Lumber", oParameters);

                chartPayTrends_AR_Lumber.DataSource = dsPayTrends_AR_Lumber;
                chartPayTrends_AR_Lumber.DataBind();

                foreach (Series s in chartPayTrends_AR_Lumber.Series)
                {
                    foreach (DataPoint dp in s.Points)
                    {
                        dp.Label = "";
                        dp.LegendText = "#VALX";
                    }

                    if (WebUser.prwu_Culture == PageBase.SPANISH_CULTURE)
                    {
                        s.Name = s.Name.Replace("Days", Resources.Global.Days);
                        s.Name = s.Name.Replace("Current", Resources.Global.Current);
                    }
                }

                chartPayTrends_AR_Lumber.ChartAreas["ChartArea1"].AxisX.LabelStyle.Angle = -90;

                chartPayTrends_AR_Lumber.Visible = true;

                //Hide TES button for lumber
                btnTES.Visible = false;
                btnAR.Visible = false; //or to simply dim it  btnAR.Attributes["class"] = "btn gray_btn"; //remove dim

                Page.ClientScript.RegisterStartupScript(this.GetType(), "AR", "AR();", true);
            }
        }
    }
}