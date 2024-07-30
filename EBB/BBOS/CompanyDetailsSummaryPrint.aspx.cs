using PRCo.EBB.BusinessObjects;
using System;
using System.Collections;
using System.Data;
using System.Web.UI.WebControls;
using TSI.Arch;
using TSI.BusinessObjects;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    public partial class CompanyDetailsSummaryPrint : System.Web.UI.Page
    {
        protected const string SQL_SELECT_COMPANY =
           @"SELECT TOP 1 *
                FROM vPRBBOSCompanyLocalized
               WHERE comp_CompanyID=@comp_CompanyID
               AND prwu_WebUserID = @prwu_WebUserID ";

        public IPRWebUser _oUser = null;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Set page title, sub-title
            //SetPageTitle(Resources.Global.CompanyDetails, Resources.Global.ListingSummary, true);
            ImageButton btnPrint = ((ImageButton)FindControl("btnPrint"));
            //btnPrint.Click += new ImageClickEventHandler(btnPrint_Click);

            if (!IsPostBack)
            {
                const string COMPANY_ID = "CompanyID";
                if (Request[COMPANY_ID] == null || Request[COMPANY_ID].Length == 0)
                    throw new ApplicationUnexpectedException(string.Format(Resources.Global.ErrorParameterMissing, COMPANY_ID, Request.RawUrl));

                hidCompanyID.Text = Request[COMPANY_ID];

                _oUser = (IPRWebUser)Session["oUser"];
            }

            //Set user controls
            ucPinnedNote.WebUser = _oUser;
            ucPinnedNote.Condensed = true;
            ucPinnedNote.companyID = UIUtils.GetInt(hidCompanyID.Text);

            ucLocalSource.WebUser = _oUser;
            ucLocalSource.companyID = UIUtils.GetInt(hidCompanyID.Text);

            ucCompanyDetails.WebUser = _oUser;
            ucCompanyDetails.companyID = hidCompanyID.Text;

            ucPerformanceIndicators.WebUser = _oUser;
            ucPerformanceIndicators.HQID = hidCompanyID.Text;

            ucTradeAssociation.WebUser = _oUser;
            ucTradeAssociation.companyID = hidCompanyID.Text;

            ucNewsArticles.WebUser = _oUser;
            ucNewsArticles.companyID = hidCompanyID.Text;
            ucNewsArticles.Title = Resources.Global.NewsArticles; //"News/Articles";
            ucNewsArticles.Style = NewsArticles.NewsType.GENERAL_NEWS_SUMMARY;
            ucNewsArticles.Condensed = true;
            ucNewsArticles.PopulateNewsArticles();
            if (ucNewsArticles.NewsCount > 0)
                ucNewsArticles.Visible = _oUser.HasPrivilege(SecurityMgr.Privilege.CompanyDetailsNewsPage).Enabled;

            PopulateCategories();

            ucCustomData.WebUser = _oUser;
            ucCustomData.Condensed = true;
            ucCustomData.companyID = hidCompanyID.Text;

            ucNotes.WebUser = _oUser;
            ucNotes.Condensed = true;
            ucNotes.companyID = hidCompanyID.Text;

            ucCompanyListing.WebUser = _oUser;
            ucCompanyListing.companyID = hidCompanyID.Text;

            ucCompanyDetailsHeader.LoadCompanyHeader(hidCompanyID.Text, _oUser);
            ucPrintHeader.SubTitle = ucCompanyDetailsHeader.CompanyName;
        }

        protected const string SQL_CATEGORIES =
            @"SELECT prwucl_CategoryIcon, prwucl_Name, prwucl_Pinned
                 FROM PRWebUserList WITH (NOLOCK)
                      INNER JOIN PRWebUserListDetail WITH (NOLOCK) ON prwucl_WebUserListID = prwuld_WebUserListID
                WHERE ((prwucl_HQID = @HQID AND prwucl_IsPrivate IS NULL) OR (prwucl_WebUserID=@WebUserID AND prwucl_IsPrivate = 'Y')) 
                  AND prwuld_AssociatedID = @CompanyID
             ORDER BY prwucl_Name";

        protected void PopulateCategories()
        {
            if (!_oUser.HasPrivilege(SecurityMgr.Privilege.WatchdogListsPage).HasPrivilege)
            {
                pnlWatchdogLists.Visible = false;
                return;
            }

            IList parmList = new ArrayList();
            parmList.Add(new ObjectParameter("HQID", _oUser.prwu_HQID));
            parmList.Add(new ObjectParameter("WebUserID", _oUser.prwu_WebUserID));
            parmList.Add(new ObjectParameter("CompanyID", Convert.ToInt32(hidCompanyID.Text)));

            repCategories.DataSource = GetDBAccess().ExecuteReader(SQL_CATEGORIES, parmList, CommandBehavior.CloseConnection, null);
            repCategories.DataBind();
        }
    }
}