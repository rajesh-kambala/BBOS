using System;
using System.Collections;
using System.Data;
using System.Web.UI.WebControls;
using TSI.BusinessObjects;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web.Widgets
{
    public partial class CompaniesRecentlyViewed : WidgetControlBase
    {
        private const int DISPLAY_COUNT = 5;
        private const string SQL_RECENTLY_VIEWED_COMPANIES =
            @"SELECT comp_CompanyID, comp_PRBookTradestyle, CityStateCountryShort
                FROM dbo.ufn_GetRecentCompanies(@WebUserID, @TopCount)
                INNER JOIN vPRBBOSCompanyList ON CompanyID = comp_CompanyID";
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if (!Page.IsPostBack)
            {
                // Create empty grid view in case 0 results are found
                gvSearchResults.ShowHeaderWhenEmpty = true;
                gvSearchResults.EmptyDataText = Resources.Global.NoRecentlyViewedCompaniesFound;

                if (WebUser != null)
                {
                    // Execute search and bind results to grid
                    ArrayList oParameters = new ArrayList();
                    oParameters.Add(new ObjectParameter("WebUserID", WebUser.UserID));
                    oParameters.Add(new ObjectParameter("TopCount", DISPLAY_COUNT));

                    gvSearchResults.DataSource = GetDBAccess().ExecuteReader(SQL_RECENTLY_VIEWED_COMPANIES, oParameters, CommandBehavior.CloseConnection, null);
                }

                gvSearchResults.DataBind();
                
                EnableBootstrapFormatting(gvSearchResults);
            }
        }

        /// <summary>
        /// Adds the sort indicator to the appropriate column
        /// header.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void GridView_RowDataBound(object sender, GridViewRowEventArgs e)
        {
        }
    }
}