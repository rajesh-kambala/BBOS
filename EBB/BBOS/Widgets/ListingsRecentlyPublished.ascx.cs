using PRCo.EBB.BusinessObjects;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Web.UI.WebControls;
using TSI.BusinessObjects;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web.Widgets
{
    public partial class ListingsRecentlyPublished : WidgetControlBase
    {
        private const int DISPLAY_COUNT = 5;

        // The {1} param needs to be either comp_PRIndustryType <> 'L' or comp_PRIndustryType = 'L'
        private const string SQL_RECENTLY_PUBLISHED_LISTINGS = 
            @"SELECT TOP({0}) comp_CompanyID, comp_PRBookTradestyle, CityStateCountryShort, comp_PRListedDate
                FROM vPRBBOSCompanyList
                WHERE 
                    {1}
	                AND comp_PRType = 'H'
                    AND comp_PRLocalSource IS NULL
                    AND comp_PRListingStatus = 'L'
                ORDER BY comp_PRListedDate DESC";

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if (!Page.IsPostBack)
            {
                // Create empty grid view in case 0 results are found
                gvSearchResults.ShowHeaderWhenEmpty = true;
                gvSearchResults.EmptyDataText = Resources.Global.NoRecentlyPublishedListingsFound;

                if (WebUser != null)
                {
                    // Execute search and bind results to grid
                    List<string> oParams = new List<string>();
                    oParams.Add(DISPLAY_COUNT.ToString());

                    if (WebUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                        oParams.Add(" comp_PRIndustryType = 'L' ");
                    else
                        oParams.Add(" comp_PRIndustryType <> 'L' ");

                    string szSQL = string.Format(SQL_RECENTLY_PUBLISHED_LISTINGS, oParams[0], oParams[1]);

                    gvSearchResults.DataSource = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection);
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