using PRCo.EBB.BusinessObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web.UserControls
{
    public partial class MenuSearch : UserControl
    {
        public IPRWebUser WebUser;
        public ILogger Logger;

        protected void Page_Load(object sender, EventArgs e)
        {
            hlSavedSearches.PostBackUrl = "~/" + PageConstants.SAVED_SEARCHES;
            hlRecentViews.PostBackUrl = "~/" + PageConstants.RECENT_VIEWS;
            hlLastCompanySearch.PostBackUrl = "~/" + PageConstants.COMPANY_SEARCH_RESULTS_EXECUTE_LAST;
            hlPersonSearch.PostBackUrl = "~/" + PageConstants.PERSON_SEARCH;
            hlCompanyUpdateSearch.PostBackUrl = "~/" + PageConstants.COMPANY_UPDATE_SEARCH;
            hlClaimActivitySearch.PostBackUrl = "~/" + PageConstants.CLAIMS_ACTIVITY_SEARCH;

            if (WebUser != null && WebUser.IsLimitado)
            {
                hlSavedSearches.Visible = false;
                hlCompanyUpdateSearch.Visible = false;
                hlClaimActivitySearch.Visible = false;
            }

            if (WebUser.prwu_LastCompanySearchID == 0)
            {
                hlLastCompanySearch.Enabled = false;
            }
        }
    }
}