using System;
using System.Collections;
using System.Data;
using System.Web.UI.WebControls;
using TSI.BusinessObjects;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web.Widgets
{
    public partial class AlertCompaniesRecentKeyChanges : WidgetControlBase
    {
        private const int DISPLAY_COUNT = 5;
        private const string SQL_AUS_COMPANIES_RECENT_KEY_CHANGES =
            @"SELECT TOP(@TopCount) comp_CompanyID, comp_PRBookTradestyle, CityStateCountryShort, prcs_PublishableDate 
              FROM PRWebUserList WITH (NOLOCK) 
                INNER JOIN PRWebUserListDetail WITH (NOLOCK) ON prwucl_WebUserListID = prwuld_WebUserListID 
                INNER JOIN vPRBBOSCompanyList ON prwuld_AssociatedID = comp_CompanyID 
                INNER JOIN PRCreditSheet WITH (NOLOCK) ON prwuld_AssociatedID = prcs_CompanyID 
              WHERE prwucl_WebUserID=@WebuserID 
                AND prwucl_TypeCode = 'AUS' 
                AND prcs_KeyFlag = 'Y'  
                AND prcs_Status = 'P' 
                ORDER BY prcs_PublishableDate DESC ";
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if (!Page.IsPostBack)
            {
                // Create empty grid view in case 0 results are found
                gvSearchResults.ShowHeaderWhenEmpty = true;
                gvSearchResults.EmptyDataText = Resources.Global.NoAlertCompaniesWithRecentKeyChangesFound;

                if (WebUser != null)
                {
                    // Execute search and bind results to grid
                    ArrayList oParameters = new ArrayList();
                    oParameters.Add(new ObjectParameter("WebUserID", WebUser.UserID));
                    oParameters.Add(new ObjectParameter("TopCount", DISPLAY_COUNT));

                    gvSearchResults.DataSource = GetDBAccess().ExecuteReader(SQL_AUS_COMPANIES_RECENT_KEY_CHANGES, oParameters, CommandBehavior.CloseConnection, null);
                }

                gvSearchResults.DataBind();
                
                EnableBootstrapFormatting(gvSearchResults);
            }
        }

        protected void btnAlerts_Click(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.ALERTS);
        }
    }
}