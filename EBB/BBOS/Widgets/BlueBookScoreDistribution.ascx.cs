using System;
using System.Data;
using System.Web.UI.DataVisualization.Charting;
using TSI.DataAccess;

namespace PRCo.BBOS.UI.Web.Widgets
{
    public partial class BlueBookScoreDistribution : WidgetControlBase
    {
        private const string SQL_BLUE_BOOK_SCORE_DISTRIBUTION =
            @"SELECT Bracket,  
                COUNT(1) as BracketCount, 
                TotalCount, 
                CAST(COUNT(1) as Decimal(10,3)) / CAST(TotalCount as Decimal(10,3)) as Pct
                  FROM (SELECT CASE WHEN prbs_BBScore >= 900 THEN '900-999' 
			                WHEN prbs_BBScore >= 800 THEN '800-899' 
			                WHEN prbs_BBScore >= 700 THEN '700-799' 
			                WHEN prbs_BBScore >= 600 THEN '600-699' 
			                WHEN prbs_BBScore >= 500 THEN '500-599' 
		                END as Bracket 
                 FROM PRBBScore WITH (NOLOCK) 
                  INNER JOIN Company ON prbs_CompanyID = comp_CompanyID 
                WHERE comp_PRIndustryType {0}
                  AND comp_PRListingStatus = 'L'  
                  AND prbs_Current = 'Y' 
                  AND prbs_PRPublish = 'Y') T1 
                  CROSS JOIN (SELECT COUNT(1) as TotalCount  
                   FROM PRBBScore WITH (NOLOCK) 
                  INNER JOIN Company ON prbs_CompanyID = comp_CompanyID 
	                WHERE comp_PRIndustryType {0}
                    AND comp_PRListingStatus = 'L'  
                  AND prbs_Current = 'Y' 
                  AND prbs_PRPublish = 'Y') T2 
                GROUP BY Bracket, TotalCount 
                ORDER BY Bracket ";
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

            string szSQL;
            if(WebUser.prwu_IndustryType == "L")
                szSQL = string.Format(SQL_BLUE_BOOK_SCORE_DISTRIBUTION, " = 'L'");
            else
                szSQL = string.Format(SQL_BLUE_BOOK_SCORE_DISTRIBUTION, " <> 'L'");


            chartBBScoreDistribution.DataSource = oDBAccess.ExecuteReader(szSQL, null, CommandBehavior.CloseConnection, null);
            chartBBScoreDistribution.DataBind();

            foreach(Series s in chartBBScoreDistribution.Series)
            {
                foreach(DataPoint dp in s.Points)
                {
                    dp.Label = "#PERCENT{P1}";
                    dp.LegendText = "#VALX";

                    if (dp.AxisLabel == "500-599")
                        dp.Color = System.Drawing.ColorTranslator.FromHtml("#D32F2F"); //red
                    else if (dp.AxisLabel == "600-699")
                        dp.Color = System.Drawing.ColorTranslator.FromHtml("#FFEE58"); //yellow
                    else if (dp.AxisLabel == "700-799")
                        dp.Color = System.Drawing.ColorTranslator.FromHtml("#84FFFF"); //uqua blue
                    else if (dp.AxisLabel == "800-899")
                        dp.Color = System.Drawing.ColorTranslator.FromHtml("#C5E1A5"); //light green
                    else if (dp.AxisLabel == "900-999")
                        dp.Color = System.Drawing.ColorTranslator.FromHtml("#43A047"); //dark green
                }
            }
        }
    }
}