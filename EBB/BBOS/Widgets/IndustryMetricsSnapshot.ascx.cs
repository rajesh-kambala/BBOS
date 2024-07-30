using PRCo.EBB.BusinessObjects;
using System;
using System.Collections;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using TSI.BusinessObjects;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web.Widgets
{
    public partial class IndustryMetricsSnapshot : WidgetControlBase
    {
        private const string SQL_INDUSTRY_METRICS =
                  @"SELECT prim_Metric [Metric], prim_Count [Count] FROM PRIndustryMetrics WHERE prim_IndustryType = @IndustryType ";

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if (!Page.IsPostBack)
            {
                // Create empty grid view in case 0 results are found
                gvSearchResults.ShowHeaderWhenEmpty = true;

                string IndustryType;
                if (WebUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                    IndustryType = "Lumber";
                else
                    IndustryType = "Produce";

                DataTable dtData = new DataTable();

                if (WebUser != null)
                {
                    // Execute search and bind results to grid
                    ArrayList oParameters = new ArrayList();
                    oParameters.Add(new ObjectParameter("IndustryType", IndustryType));

                    IDataReader dr = GetDBAccess().ExecuteReader(SQL_INDUSTRY_METRICS, oParameters, CommandBehavior.CloseConnection, null);
                    dtData.Load(dr);
                }

                gvSearchResults.DataSource = dtData;
                gvSearchResults.DataBind();

                EnableBootstrapFormatting(gvSearchResults);
            }
        }

        public bool ChangeWidgetsLinkVisible
        {
            set { hlChangeWidgets.Visible = value; }
        }

        /// <summary>
        /// Adds the sort indicator to the appropriate column
        /// header.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void GridView_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                string szMetric = (DataBinder.Eval(e.Row.DataItem, "Metric")).ToString();
                int intCount = Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "Count"));
                Literal litMetric = (Literal)e.Row.FindControl("litMetric");

                HyperLink hlCount = (HyperLink)e.Row.FindControl("hlCount");

                /*  Number of “meritorious” claims(Blue Book claims) filed in past 12 months(and link to Search Claims screen)
                    Number of bankruptcies filed in past 12 months(and link to Bankruptcy Report)
                    Number of Rating Upgrades in past 12 months(and link to Search Company Updates)
                    Number of Rating Downgrades in past 12 months(and link to Search Company Updates)
                    Number of New Listings Reported in past 12 months(and link to Search Company Updates)
                */

                switch (szMetric.ToLower())
                {
                    case "meritoriousclaims":
                        hlCount.NavigateUrl = string.Format("~/{0}", PageConstants.CLAIMS_ACTIVITY_SEARCH);
                        break;
                    case "bankruptcy":
                        hlCount.NavigateUrl = string.Format("~/{0}", string.Format(PageConstants.GET_REPORT, GetReport.BANKRUPCTY_REPORT_NR));
                        break;
                    default:
                        hlCount.NavigateUrl = string.Format("~/{0}", PageConstants.COMPANY_UPDATE_SEARCH);
                        break;
                }

                switch(szMetric.ToLower())
                {
                    case "meritoriousclaims":
                        litMetric.Text = Resources.Global.MeritoriousClaims;
                        break;
                    case "bankruptcy":
                        litMetric.Text = Resources.Global.Bankruptcy;
                        break;
                    case "downgrade":
                        litMetric.Text = Resources.Global.Downgrade;
                        break;
                    case "upgrade":
                        litMetric.Text = Resources.Global.Upgrade;
                        break;
                    case "newlylisted":
                        litMetric.Text = Resources.Global.NewlyListed;
                        break;
                    default:
                        litMetric.Text = szMetric;
                        break;
                }
            }
        }
    }
}
