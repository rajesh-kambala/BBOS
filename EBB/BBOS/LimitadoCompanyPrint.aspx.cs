using PRCo.EBB.BusinessObjects;
using System;
using System.Web.UI.WebControls;
using TSI.Arch;

namespace PRCo.BBOS.UI.Web
{
    public partial class LimitadoCompanyPrint : System.Web.UI.Page
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
            ImageButton btnPrint = ((ImageButton)FindControl("btnPrint"));

            if (!IsPostBack)
            {
                const string COMPANY_ID = "CompanyID";
                const string INDUSTRY_TYPE = "IndustryType";

                if (Request[COMPANY_ID] == null || Request[COMPANY_ID].Length == 0)
                    throw new ApplicationUnexpectedException(string.Format(Resources.Global.ErrorParameterMissing, COMPANY_ID, Request.RawUrl));
                if (Request[INDUSTRY_TYPE] == null || Request[INDUSTRY_TYPE].Length == 0)
                    throw new ApplicationUnexpectedException(string.Format(Resources.Global.ErrorParameterMissing, INDUSTRY_TYPE, Request.RawUrl));

                hidCompanyID.Text = Request[COMPANY_ID];
                hidIndustryType.Text = Request[INDUSTRY_TYPE];

                _oUser = (IPRWebUser)Session["oUser"];
            }

            //Set user controls
            ucCompanyDetails.WebUser = _oUser;
            ucCompanyDetails.companyID = hidCompanyID.Text;

            ucCompanyListing.WebUser = _oUser;
            ucCompanyListing.companyID = hidCompanyID.Text;

            ucCompanyDetailsHeader.LoadCompanyHeader(hidCompanyID.Text, _oUser);
            ucPrintHeader.SubTitle = ucCompanyDetailsHeader.CompanyName;

            ucClassifications.WebUser = _oUser;
            ucClassifications.CompanyID = hidCompanyID.Text;

            ucCommodities.WebUser = _oUser;
            ucCommodities.IndustryType = hidIndustryType.Text;
            ucCommodities.CompanyID = hidCompanyID.Text;
        }
    }
}