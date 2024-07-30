/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2020

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: UserList
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Data;
using System.Text;
using System.Web.UI;
using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This page displays past alerts on the user's current Alert watchdog list.
    /// </summary>
    public partial class Alerts : PageBase
    {
        protected DateTime _dtFromDate;
        protected DateTime _dtToDate;
        private int _iYear;
        private int _iMonth;

        const string BR = "<br>";

        /// <summary>
        /// Calls page functions required to build and process this page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            SetPageTitle(Resources.Global.Alerts);
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_TOGGLE_FUNCTIONS_FILE));
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_FUNCTIONS2_FILE));
            EnableFormValidation();

            //SetSortField(gvUserList, "prwucl_Name");

            if (!IsPostBack)
            {
                txtDateFrom.Attributes.Add("placeholder", GetCultureInfo_ShortDatePattern().ToUpper());
                txtDateTo.Attributes.Add("placeholder", GetCultureInfo_ShortDatePattern().ToUpper());

                BindLookupValues();
                PopulateForm();

                Search();
            }
        }

        private void AppendRow(StringBuilder sb, string szText, bool bIndent = false)
        {
            string szStyle = "";
            if (bIndent)
                szStyle = "style='margin-left:15px;' ";

            sb.Append(string.Format("<div {1}>{0}</div>", szText, szStyle));
        }

        const string BLANK_ROW = "<div>&nbsp;</div>";

        private void AppendBlankRow(StringBuilder sb)
        {
            sb.Append(BLANK_ROW);
        }

        private void RemoveBlankRow(StringBuilder sb)
        {
            if(sb.ToString().EndsWith(BLANK_ROW))
            {
                sb.Remove(sb.ToString().LastIndexOf(BLANK_ROW), BLANK_ROW.Length);
            }
        }

        private void AppendHRRow(StringBuilder sb)
        {
            sb.Append("<hr style='height:4px;border:none;color:#333;background-color:#333;'>");
        }

        const string STYLED_BUTTON = @"<table align='right'>
                                            <tr>
                                                <td style='background-color: #68AE00; border: none; color: white; padding: 5px 14px; text-align: center; font-size: 12px; border-radius: 4px; min-width:60px;'>
                                                    <a href='{0}' target='_blank' style = 'color:white;text-decoration: none;font-weight:bold; vertical-align:central;'>{1}</a>
                                                </td>
                                            </tr>
                                       </table><br>";

        /// <summary>
        /// Executes the search populating the results grid.
        /// </summary>
        protected void Search()
        {
            PopulateDateRange(ddlDateRange.SelectedValue);

            IList parms = new ArrayList();
            parms.Add(new ObjectParameter("PersonID", _oUser.peli_PersonID));
            parms.Add(new ObjectParameter("CompanyID", _oUser.prwu_BBID));
            parms.Add(new ObjectParameter("StartDate", _dtFromDate));
            parms.Add(new ObjectParameter("EndDate", _dtToDate));

            DataSet dsMonitoredCompanies = GetDBAccess().ExecuteStoredProcedure("usp_Alerts_GetMonitoredCompanies", parms);

            DataView dvMonitoredCompanies_Sorted = dsMonitoredCompanies.Tables[0].DefaultView;
            dvMonitoredCompanies_Sorted.Sort = "comp_PRCorrTradestyle asc";

            StringBuilder sb = new StringBuilder();

            if(dvMonitoredCompanies_Sorted.Count > 0)
                AppendHRRow(sb);

            foreach (DataRowView row in dvMonitoredCompanies_Sorted)
            {
                int MonitoredCompanyID = (int)row["MonitoredCompanyID"];
                string comp_PRCorrTradestyle = (string)row["comp_PRCorrTradestyle"];
                string CityStateCountryShort = (string)row["CityStateCountryShort"];

                string szLinkURL = string.Format(PageConstants.BUSINESS_REPORT_CONFIRM_SELECTIONS_COMPANYIDLIST, MonitoredCompanyID);
                string szLinkTag = string.Format(STYLED_BUTTON, szLinkURL, Resources.Global.btnGetBusinessReport);

                AppendRow(sb, CityStateCountryShort + szLinkTag); //Add a button for Get Business Report.Hyperlink this to the BusinessReportConfirmation.aspx specifying the subject company ID (put in upper right)
                AppendRow(sb, string.Format("BB #{0}", MonitoredCompanyID), bIndent: true);

                string szCompanyDetailsLink = string.Format("<a href='{0}' class='explicitlink2'>{1}</a>", PageConstants.Format(PageConstants.COMPANY_DETAILS_SUMMARY, MonitoredCompanyID), comp_PRCorrTradestyle);
                AppendRow(sb, szCompanyDetailsLink);
                AppendBlankRow(sb);

                sb.Append(GetCreditSheetHTML(MonitoredCompanyID));
                sb.Append(GetNewsHTML(MonitoredCompanyID));
                sb.Append(GetClaimHTML(MonitoredCompanyID));
                sb.Append(GetCourtCaseHTML(MonitoredCompanyID));
                sb.Append(GetBBScoreChangeHTML(MonitoredCompanyID));
                sb.Append(GetBBScoreNewPublishableHTML(MonitoredCompanyID));

                AppendHRRow(sb);
            }

            if (dvMonitoredCompanies_Sorted.Count > 0)
                sb.Append(GetRatingDefinitions());

            lblResults.Text = sb.ToString();
        }

        private string GetRatingDefinitions()
        {
            StringBuilder sb = new StringBuilder();

            IList parms = new ArrayList();
            parms.Add(new ObjectParameter("PersonID", _oUser.peli_PersonID));
            parms.Add(new ObjectParameter("CompanyID", _oUser.prwu_BBID));
            parms.Add(new ObjectParameter("StartDate", _dtFromDate));
            parms.Add(new ObjectParameter("EndDate", _dtToDate));

            AppendRow(sb, "<b><u>Current Rating Definitions:</u></b>");
            AppendBlankRow(sb);

            string szRatingKeyURL;
            if (_oUser.prwu_IndustryType == "L")
                szRatingKeyURL = PageConstants.GET_PUBLICATION_FILE + "?PublicationArticleID=7732";
            else
                szRatingKeyURL = PageConstants.GET_PUBLICATION_FILE + "?PublicationArticleID=6214";

            using (IDataReader reader = GetDBAccess().ExecuteReader("usp_Alerts_GetRatingNumerals", parms, CommandBehavior.CloseConnection, null, CommandType.StoredProcedure))
            {
                while (reader.Read())
                {
                    string Numeral = (string)reader["Numeral"];
                    string Description = (string)reader["Description"];
                    
                    AppendRow(sb, string.Format("{0}&nbsp;&nbsp;&nbsp;&nbsp;{1}", Numeral, Description), bIndent: true);
                }
            }

            AppendBlankRow(sb);
            AppendRow(sb, string.Format("For a list of all Rating Key Numerals, go to the <a href='{0}' class='explicitlink2'>Rating Key</a> in BBOS.", szRatingKeyURL));

            return sb.ToString();
        }

        private string GetCreditSheetHTML(int MonitoredCompanyID)
        {
            StringBuilder sb = new StringBuilder();

            IList parms = new ArrayList();
            parms.Add(new ObjectParameter("CompanyID", MonitoredCompanyID));
            parms.Add(new ObjectParameter("StartDate", _dtFromDate));
            parms.Add(new ObjectParameter("EndDate", _dtToDate));

            using (IDataReader reader = GetDBAccess().ExecuteReader("usp_Alerts_GetCreditItems", parms, CommandBehavior.CloseConnection, null, CommandType.StoredProcedure))
            {
                while (reader.Read())
                {
                    string ItemText = (string)reader["ItemText"];
                    ItemText = ItemText.Replace("\r\n", BR);
                    AppendRow(sb, ItemText, bIndent:true);
                    AppendBlankRow(sb);
                }

                RemoveBlankRow(sb);

                return sb.ToString();
            }
        }

        private string GetNewsHTML(int MonitoredCompanyID)
        {
            StringBuilder sb = new StringBuilder();

            IList parms = new ArrayList();
            parms.Add(new ObjectParameter("CompanyID", MonitoredCompanyID));
            parms.Add(new ObjectParameter("StartDate", _dtFromDate));
            parms.Add(new ObjectParameter("EndDate", _dtToDate));

            using (IDataReader reader = GetDBAccess().ExecuteReader("usp_Alerts_GetNews", parms, CommandBehavior.CloseConnection, null, CommandType.StoredProcedure))
            {
                while (reader.Read())
                {
                    string prbar_Name = (string)reader["prpbar_Name"];
                    string URL = (string)reader["URL"];
                    int prpbar_PublicationArticleID = (int)reader["prpbar_PublicationArticleID"];

                    string szText = "A BBOS News article has been reported on this firm.  This news article can be read online via BBOS at <a href='apps.bluebookservices.com' class='explicitlink2'>apps.bluebookservices.com</a>." + BR + BR;
                    string szLink = URL + prpbar_PublicationArticleID.ToString();
                    szText += string.Format("<a href='{0}' class='explicitlink2'>{1}</a>", szLink, prbar_Name);

                    AppendRow(sb, szText, bIndent:true);
                }

                return sb.ToString();
            }
        }

        private string GetClaimHTML(int MonitoredCompanyID)
        {
            StringBuilder sb = new StringBuilder();

            IList parms = new ArrayList();
            parms.Add(new ObjectParameter("CompanyID", MonitoredCompanyID));
            parms.Add(new ObjectParameter("StartDate", _dtFromDate));
            parms.Add(new ObjectParameter("EndDate", _dtToDate));

            using (IDataReader reader = GetDBAccess().ExecuteReader("usp_Alerts_GetClaims", parms, CommandBehavior.CloseConnection, null, CommandType.StoredProcedure))
            {
                while (reader.Read())
                {
                    DateTime prss_OpenedDate = (DateTime)reader["prss_OpenedDate"];
                    int prss_SSFileID = (int)reader["prss_SSFileID"];
                    string URL = (string)reader["URL"];
                    int prss_RespondentCompanyId = (int)reader["prss_RespondentCompanyId"];

                    string szText = "Blue Book Services has received a new claim filed against this company.  Additional details can be read online via BBOS at <a href='apps.bluebookservices.com' class='explicitlink2'>apps.bluebookservices.com</a>." + BR + BR;
                    string szLink = URL + prss_RespondentCompanyId.ToString();
                    szText += string.Format("<a href='{0}' class='explicitlink2'>{1} - {2}</a>", szLink, prss_OpenedDate.ToString("MM/dd/yyyy"), prss_SSFileID);
                    
                    AppendRow(sb, szText, bIndent: true);
                }

                return sb.ToString();
            }
        }

        private string GetCourtCaseHTML(int MonitoredCompanyID)
        {
            StringBuilder sb = new StringBuilder();

            IList parms = new ArrayList();
            parms.Add(new ObjectParameter("CompanyID", MonitoredCompanyID));
            parms.Add(new ObjectParameter("StartDate", _dtFromDate));
            parms.Add(new ObjectParameter("EndDate", _dtToDate));

            using (IDataReader reader = GetDBAccess().ExecuteReader("usp_Alerts_GetCourtCases", parms, CommandBehavior.CloseConnection, null, CommandType.StoredProcedure))
            {
                while (reader.Read())
                {
                    int prss_RespondentCompanyId = (int)reader["prss_RespondentCompanyId"];
                    DateTime prss_OpenedDate = (DateTime)reader["prss_OpenedDate"];
                    int prss_SSFileID = (int)reader["prss_SSFileID"];
                    string URL = (string)reader["URL"];

                    string szText = "A civil case has been filed in Federal court identifying this company as a defendant. Additional details can be read online via BBOS at <a href='apps.bluebookservices.com' class='explicitlink2'>apps.bluebookservices.com</a>." + BR + BR;
                    string szLink = URL + prss_RespondentCompanyId.ToString();
                    szText += string.Format("<a href='{0}' class='explicitlink2'>{1} - {2}</a>", szLink, prss_OpenedDate.ToString("MM/dd/yyyy"), prss_SSFileID);

                    AppendRow(sb, szText, bIndent: true);
                }

                return sb.ToString();
            }
        }

        private string GetBBScoreChangeHTML(int MonitoredCompanyID)
        {
            StringBuilder sb = new StringBuilder();

            IList parms = new ArrayList();
            parms.Add(new ObjectParameter("CompanyID", MonitoredCompanyID));
            parms.Add(new ObjectParameter("StartDate", _dtFromDate));
            parms.Add(new ObjectParameter("EndDate", _dtToDate));

            using (IDataReader reader = GetDBAccess().ExecuteReader("usp_Alerts_GetScoreChange", parms, CommandBehavior.CloseConnection, null, CommandType.StoredProcedure))
            {
                while (reader.Read())
                {
                    decimal prbs_BBScore = (decimal)reader["prbs_BBScore"];
                    decimal PreviousScore = (decimal)reader["PreviousScore"];
                    
                    string szLine = "Blue Book Score has {0} by {1}.  Current Blue Book Score is {2}.  The previous Blue Book Score was {3}.  Consult the online Business Report for further details and trends.";
                    decimal ScoreChange = prbs_BBScore - PreviousScore;
                    string szScoreChangeText;
                    if (ScoreChange > 0)
                        szScoreChangeText = "increased";
                    else
                        szScoreChangeText = "decreased";

                    AppendRow(sb, string.Format(szLine, szScoreChangeText, (int)(Math.Abs(ScoreChange)), (int)prbs_BBScore, (int)PreviousScore), bIndent: true);
                }

                return sb.ToString();
            }
        }

        private string GetBBScoreNewPublishableHTML(int MonitoredCompanyID)
        {
            StringBuilder sb = new StringBuilder();

            IList parms = new ArrayList();
            parms.Add(new ObjectParameter("CompanyID", MonitoredCompanyID));
            parms.Add(new ObjectParameter("StartDate", _dtFromDate));
            parms.Add(new ObjectParameter("EndDate", _dtToDate));

            using (IDataReader reader = GetDBAccess().ExecuteReader("usp_Alerts_GetNewPublishableScore", parms, CommandBehavior.CloseConnection, null, CommandType.StoredProcedure))
            {
                while (reader.Read())
                {
                    decimal prbs_BBScore = (decimal)reader["prbs_BBScore"];
                    string szLine = "Blue Book Score of {0} assigned.";

                    AppendRow(sb, string.Format(szLine, (int)prbs_BBScore), bIndent: true);
                }

                return sb.ToString();
            }
        }

        private void PopulateDateRange(string szDateRangeType)
        {
            // Date Range Type Criteria
            if (string.IsNullOrEmpty(szDateRangeType))
            {
                if (!string.IsNullOrEmpty(txtDateFrom.Text) && !string.IsNullOrEmpty(txtDateTo.Text))
                {
                    _dtFromDate = Convert.ToDateTime(txtDateFrom.Text);
                    _dtToDate = Convert.ToDateTime(txtDateTo.Text);
                }

                return;
            }

            _iMonth = DateTime.Now.Month;
            _iYear = DateTime.Now.Year;
            DateTime dtTemp = new DateTime();

            switch (szDateRangeType)
            {
                case CreditSheetSearchCriteria.CODE_DATERANGE_TODAY:
                    _dtFromDate = Convert.ToDateTime(DateTime.Today.ToShortDateString());
                    _dtToDate = Convert.ToDateTime(DateTime.Today.ToShortDateString());
                    break;
                case CreditSheetSearchCriteria.CODE_DATERANGE_YESTERDAY:
                    _dtFromDate = Convert.ToDateTime(DateTime.Today.AddDays(-1).ToShortDateString());
                    _dtToDate = Convert.ToDateTime(DateTime.Today.AddDays(-1).ToShortDateString());
                    break;
                case CreditSheetSearchCriteria.CODE_DATERANGE_THISWEEK:
                    // Let's find the most recent Sunday first.
                    dtTemp = DateTime.Today.AddDays(-1 * Convert.ToInt16(DateTime.Today.DayOfWeek));
                    _dtFromDate = Convert.ToDateTime(dtTemp.ToShortDateString());
                    _dtToDate = Convert.ToDateTime(DateTime.Today.ToShortDateString());
                    break;
                case CreditSheetSearchCriteria.CODE_DATERANGE_LASTWEEK:
                    dtTemp = DateTime.Today.AddDays(-1 * Convert.ToInt16(DateTime.Today.DayOfWeek));
                    _dtFromDate = Convert.ToDateTime(dtTemp.AddDays(-7).ToShortDateString());
                    _dtToDate = Convert.ToDateTime(dtTemp.AddDays(-1).ToShortDateString());
                    break;
                case CreditSheetSearchCriteria.CODE_DATERANGE_THISMONTH:
                    dtTemp = new DateTime(_iYear, _iMonth, 1);
                    _dtFromDate = dtTemp;
                    _dtToDate = Convert.ToDateTime(DateTime.Today.ToShortDateString());
                    break;
                case CreditSheetSearchCriteria.CODE_DATERANGE_LASTMONTH:
                    dtTemp = DateTime.Now.AddMonths(-1);
                    _dtFromDate = new DateTime(dtTemp.Year, dtTemp.Month, 1);
                    _dtToDate = _dtFromDate.AddMonths(1).AddDays(-1);
                    break;
                case CreditSheetSearchCriteria.CODE_DATERANGE_THISQUARTER:
                    SetDatesByQuarter(_iMonth);
                    break;
                case CreditSheetSearchCriteria.CODE_DATERANGE_LASTQUARTER:
                    SetDatesByQuarter(_iMonth);
                    _dtFromDate = _dtFromDate.AddMonths(-3);
                    _dtToDate = _dtToDate.AddMonths(-3);
                    break;
            }
        }

        /// <summary>
        /// Determines the dates to be used for by quarter searches
        /// based on the month supplied
        /// </summary>
        /// <param name="iMonth">Month used to determine quarter</param>
        private void SetDatesByQuarter(int iMonth)
        {
            DateTime dtFromTemp;
            DateTime dtToTemp;

            if (iMonth == 1 || iMonth == 2 || iMonth == 3)
            {
                dtFromTemp = new DateTime(_iYear, 1, 1);
                _dtFromDate = dtFromTemp;
                dtToTemp = new DateTime(_iYear, 3, 31);
                _dtToDate = dtToTemp;
            }
            else if (iMonth == 4 || iMonth == 5 || iMonth == 6)
            {
                dtFromTemp = new DateTime(_iYear, 4, 1);
                _dtFromDate = dtFromTemp;
                dtToTemp = new DateTime(_iYear, 6, 30);
                _dtToDate = dtToTemp;
            }
            else if (iMonth == 7 || iMonth == 8 || iMonth == 9)
            {
                dtFromTemp = new DateTime(_iYear, 7, 1);
                _dtFromDate = dtFromTemp;
                dtToTemp = new DateTime(_iYear, 9, 30);
                _dtToDate = dtToTemp;
            }
            else if (iMonth == 10 || iMonth == 11 || iMonth == 12)
            {
                dtFromTemp = new DateTime(_iYear, 10, 1);
                _dtFromDate = dtFromTemp;
                dtToTemp = new DateTime(_iYear, 12, 31);
                _dtToDate = dtToTemp;
            }
        }

        protected void BindLookupValues()
        {
            BindLookupValues(ddlDateRange, GetReferenceData("RelativeDateRange"), "Yesterday");
            ddlDateRange.Attributes.Add("onchange", "ToggleCalendar();");

            //ddlSortOption.Items.Add(new System.Web.UI.WebControls.ListItem("Alert Date", "1", true));
            //ddlSortOption.Items.Add(new System.Web.UI.WebControls.ListItem("Company Name", "2"));
        }

        /// <summary>
        /// Check users page level authorization
        /// </summary>
        /// <returns></returns>
        override protected bool IsAuthorizedForPage()
        {
            return true;
        }

        /// <summary>        
        /// Check users control/data level authorization
        /// </summary>
        /// <returns></returns>
        override protected bool IsAuthorizedForData()
        {
            return true;
        }

        /// <summary>
        /// Populates the form controls.
        /// </summary>
        protected void PopulateForm()
        {
        }

        /// <summary>
        /// Prepares the criteria object by populating it from the
        /// form and then executes the search.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnSearchOnClick(object sender, EventArgs e)
        {
            PopulateSearchCriteria();
            Search();
        }

        protected void PopulateSearchCriteria()
        {
            if ((string.IsNullOrEmpty(ddlDateRange.SelectedValue)) &&
                ((string.IsNullOrEmpty(txtDateFrom.Text)) ||
                    (string.IsNullOrEmpty(txtDateTo.Text))))
            {
                AddUserMessage(Resources.Global.PleaseSpecifyDateRange);
                return;
            }
        }

        protected void btnClearCriteria_Click(object sender, EventArgs e)
        {
            //Session["oWebUserSearchCriteria"] = null;
            ddlDateRange.SelectedValue = "Yesterday";
            txtDateFrom.Text = "";
            txtDateTo.Text = "";
            lblResults.Text = "";
            PopulateForm();

            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "DisableValidation", "DisableValidation();", true);
        }
    }
}
