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

 ClassName: CompanyClaimsActivity
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using PRCo.EBB.BusinessObjects;
using System;
using System.Collections;
using System.Data;
using System.Web.UI.WebControls;
using System.Web.UI;
using TSI.BusinessObjects;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;
using System.Web.UI.HtmlControls;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Displays company data and listing.
    /// </summary>
    public partial class CompanyClaimsActivity : CompanyDetailsBase
    {
        CompanyData _ocd;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
            Page.Title = Resources.Global.BlueBookService;
            ((BBOS)Master).HideOldTopMenu();

            // Set page title, sub-title
            ImageButton btnPrint = ((ImageButton)Master.FindControl("btnPrint"));
            btnPrint.Click += new ImageClickEventHandler(btnPrint_Click);

            if (!IsPostBack)
            {
                //Get cached company data
                _ocd = GetCompanyDataFromSession();

                if (_ocd.szCompanyType == "B")
                {
                    Response.Redirect(string.Format(PageConstants.COMPANY_CLAIMS_ACTIVITY_BBOS9, _ocd.iHQID));
                    return;
                }

                hidCompanyID.Text = GetRequestParameter("CompanyID");

                SetSortField(gvFederalCivilCases, "prcc_FiledDate");
                SetSortAsc(gvFederalCivilCases, false);

                SetSortField(gvBBSClaims, "prss_CreatedDate");
                SetSortAsc(gvBBSClaims, false);

                PopulateForm();
            }

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
            PopulateCourtCases();
            DisplayButtons();
            PopulateBBSiClaims();
            PopulatePACAComplaints();

            //LocalSource
            if (_ocd.bLocalSource)
            {
                ucCompanyDetailsHeaderMeister.MeisterVisible = true;
            }
        }

        protected const string SQL_SELECT_COURT_CASES =
            @"SELECT *
               FROM vPRCourtCases 
              WHERE prcc_CompanyID = @CompanyID
                AND ISNULL(prcc_ClosedDate, GETDATE()) >= @ThresholdDate";

        protected void PopulateCourtCases()
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", hidCompanyID.Text));

            int months;

            if (_oUser.prwu_AccessLevel >= PRWebUser.SECURITY_LEVEL_ADVANCED_PLUS)
                months = Configuration.ClaimActivityFederalCivilCasesThresholdMonthsPlus;
            else
                months = Configuration.ClaimActivityFederalCivilCasesThresholdMonths;

            DateTime threshold = DateTime.Today.AddMonths(0 - months);
            oParameters.Add(new ObjectParameter("ThresholdDate", threshold));

            string szSQL = SQL_SELECT_COURT_CASES;
            szSQL += GetOrderByClause(gvFederalCivilCases);

            gvFederalCivilCases.ShowHeaderWhenEmpty = true;
            gvFederalCivilCases.EmptyDataText = GetNoResultsFoundMsg(Resources.Global.Lawsuits);

            gvFederalCivilCases.DataSource = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            gvFederalCivilCases.DataBind();
            EnableBootstrapFormatting(gvFederalCivilCases);

            FederalCivilCasesThreshold.Text = months.ToString();
        }

        protected const string SQL_SELECT_BBSi_CLAIMS =
             @"SELECT *
               FROM vPRBBSiClaims 
              WHERE prss_RespondentCompanyId = @CompanyID
                AND
			    (
				    (ISNULL(Meritorious,'') = 'Yes' AND ISNULL(prss_ClosedDate, GETDATE()) >= @ThresholdDateMeritorious)
				    OR
				    (ISNULL(Meritorious,'') <> 'Yes' AND ISNULL(prss_ClosedDate, GETDATE()) >= @ThresholdDate)
			    )
                AND prss_Status IN ('O', 'C')
                AND prss_Publish = 'Y'";

        protected void PopulateBBSiClaims()
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", hidCompanyID.Text));

            int months;
            int monthsMeritorious;

            if (_oUser.prwu_AccessLevel >= PRWebUser.SECURITY_LEVEL_ADVANCED_PLUS)
            {
                months = Configuration.ClaimActivityBBSiClaimsThresholdMonthsPlus; //24 default
                monthsMeritorious = Configuration.ClaimActivityBBSiClaimsThresholdMonthsPlus_Meritorious; //60 default
                ClaimsFiledHeader.Text = string.Format("{0} {1} {2}",
                                            Resources.Global.BBSICase1_ADVPLUS,
                                            months,
                                            string.Format(Resources.Global.BBSICase2_ADVPLUS, monthsMeritorious));
            }
            else
            {
                months = Configuration.ClaimActivityBBSiClaimsThresholdMonths; //24 default
                monthsMeritorious = Configuration.ClaimActivityBBSiClaimsThresholdMonths; //24 default
                ClaimsFiledHeader.Text = string.Format("{0} {1} {2}",
                                            Resources.Global.BBSICase1,
                                            months,
                                            Resources.Global.BBSICase2);
            }

            DateTime threshold = DateTime.Today.AddMonths(0 - months);
            oParameters.Add(new ObjectParameter("ThresholdDate", threshold));

            DateTime thresholdMeritorious = DateTime.Today.AddMonths(0 - monthsMeritorious);
            oParameters.Add(new ObjectParameter("ThresholdDateMeritorious", thresholdMeritorious));

            string szSQL = SQL_SELECT_BBSi_CLAIMS;
            szSQL += GetOrderByClause(gvBBSClaims);

            gvBBSClaims.ShowHeaderWhenEmpty = true;
            gvBBSClaims.EmptyDataText = GetNoResultsFoundMsg(Resources.Global.BBSClaims);

            gvBBSClaims.DataSource = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            gvBBSClaims.DataBind();
            EnableBootstrapFormatting(gvBBSClaims);
        }

        public const string SQL_SELECT_PACA_COMPLAINTS =
            @"SELECT PRPacaComplaint.* FROM PRPACAComplaint
	            INNER JOIN PRPACALicense ON prpa_PACALicenseId =  prpac_PACALicenseID AND prpa_Current='Y' AND prpa_CompanyId = @CompanyID";

        protected void PopulatePACAComplaints()
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", hidCompanyID.Text));

            string szSQL = SQL_SELECT_PACA_COMPLAINTS;

            IDataReader oReader = null;

            //Default to no complaints state
            divComplaints.Visible = false;
            divPACAReparationCaseHeaderMsg.Visible = false;
            divNoComplaints.Visible = true;

            try
            {
                oReader = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
                if (oReader.Read())
                {
                    divComplaints.Visible = true;
                    divPACAReparationCaseHeaderMsg.Visible = true;
                    divNoComplaints.Visible = false;

                    litInformal.Text = UIUtils.GetString(oReader["prpac_InfRepComplaintCount"]);
                    litDisputedInformal.Text = UIUtils.GetString(oReader["prpac_DisInfRepComplaintCount"]);
                    litFormal.Text = UIUtils.GetString(oReader["prpac_ForRepComplaintCount"]);
                    litDisputedFormal.Text = UIUtils.GetString(oReader["prpac_DisForRepCompaintCount"]);

                    if (oReader["prpac_TotalFormalClaimAmt"] != DBNull.Value)
                        litTotalClaimAmount.Text = string.Format("{0:C}", oReader["prpac_TotalFormalClaimAmt"]);
                    else
                        litTotalClaimAmount.Text = "0";
                }
            }
            catch (Exception e)
            {
                LoggerFactory.GetLogger().LogError(e);
                throw;
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }
        }

        protected const string SQL_SELECT_HAS_BUSINESS_EVENT =
            @"SELECT 'x'
              FROM PRBusinessEvent
                   INNER JOIN PRCourtCases ON prbe_CompanyId = prcc_CompanyID
	                                      AND prbe_CaseNumber = prcc_CaseNumber
            WHERE prcc_CompanyID = @CompanyID";

        protected void DisplayButtons()
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", hidCompanyID.Text));

            if (GetDBAccess().ExecuteScalar(SQL_SELECT_HAS_BUSINESS_EVENT, oParameters) == null)
                pnlButtons.Visible = false;

            if (!_oUser.IsInRole(PRWebUser.ROLE_USE_SERVICE_UNITS))
                btnBusinessReport.Enabled = false;
        }

        protected void btnBusinessReportOnClick(object sender, EventArgs e)
        {
            SetRequestParameter("CompanyIDList", hidCompanyID.Text);
            Response.Redirect(string.Format(PageConstants.BUSINESS_REPORT_CONFIRM_SELECTIONS, hidCompanyID.Text, "Company"));
        }

        /// <summary>
        /// Helper method that helps with bi-directional sorting
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void GridView_Sorting(Object sender, GridViewSortEventArgs e)
        {
            SetSortingAttributes((GridView)sender, e);

            if (((GridView)sender).ID == "gvFederalCivilCases")
                PopulateCourtCases();

            if (((GridView)sender).ID == "gvBBSiClaims")
                PopulateBBSiClaims();
        }

        /// <summary>
        /// Adds the sort indicator to the appropriate column
        /// header.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void GridView_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            SetSortIndicator((GridView)sender, e);

            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                Panel note = (Panel)e.Row.FindControl("note");
                HtmlButton btnClose = (HtmlButton)e.Row.FindControl("btnClose");
                if (note != null && btnClose != null)
                    btnClose.Attributes.Add("onclick", string.Format("document.getElementById('{0}').style.display='none';", note.ClientID));
            }
        }

        protected bool DisplayNotes(object notes)
        {
            if (notes == DBNull.Value)
            {
                return false;
            }

            if (string.IsNullOrEmpty((string)notes))
            {
                return false;
            }

            return true;
        }

        protected string GetStatus(object status, object closedDate)
        {
            string szStatus = Convert.ToString(status);
            if (szStatus == "Closed")
            {
                return szStatus + " - " + GetStringFromDate(closedDate);
            }

            return szStatus;
        }

        override protected bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.CompanyDetailsClaimActivityPage).Enabled;
        }
    }
}