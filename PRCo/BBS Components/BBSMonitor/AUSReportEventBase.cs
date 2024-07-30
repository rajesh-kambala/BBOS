/***********************************************************************
 Copyright Produce Reporter Company 2006-2021

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: BBSMonitor.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;

namespace PRCo.BBS.BBSMonitor
{

    /// <summary>
    /// Provides the common functionality for the AUS and
    /// AUS Settings reports.
    /// </summary>
    public abstract class AUSReportEventBase : BBSMonitorEvent
    {

        protected const string SQL_SELECT_AUS_SETTINGS = "SELECT peli_PersonID, peli_CompanyID, COUNT(1) As AUSCount " +
                  "  FROM Person_Link " +
                  "INNER JOIN PRWebUser on peli_PersonLinkID = prwu_PersonLinkID " +
                  "INNER JOIN PRWebUserList ON prwu_WebUserID = prwucl_WebUserID " +
                  "INNER JOIN PRWebUserListDetail ON prwucl_WebUserListID = prwuld_WebUserListID " +
                  "WHERE prwucl_TypeCode = 'AUS' " +
                  "AND prwu_AccessLevel in ('200', '300', '400', '500', '999999') " +
                  "GROUP BY peli_PersonID, peli_CompanyID " +
                  "HAVING COUNT(1) > 0";

        protected const string MSG_AUS_DETAIL = " - {0} to {1} at {2} with {3} BBID {4} with {5} changes.\n";
        protected const string MSG_AUS_SUMMARY = "A total of {0:###,###,##0} changes were detected for the time period of {1:g} through {2:g}.  {3:###,##0} AUS reports delievered.\n - {4:###,##0} were emailed\n - {5:###,##0} were faxed";
        protected const string MSG_AUS_LIMITED = "Special execution limited to montiored BBID {0}.  ";
        protected const string MSG_AUS_SETTINGS_SUMMARY = "{0:###,##0} AUS Alert Event reports delievered.\n - {1:###,##0} were emailed\n - {2:###,##0} were faxed";

        protected string _BBOSURL;

        /// <summary>
        /// Populates the ReportUser object with the report header
        /// information.
        /// </summary>
        /// <param name="oConn"></param>
        /// <param name="oReportUser"></param>
        protected void GetAlertsReportHeader(SqlConnection oConn, ReportUser oReportUser)
        {
            SqlCommand oSQLCommand = new SqlCommand("usp_GetAUSReportHeader", oConn);
            oSQLCommand.CommandType = CommandType.StoredProcedure;
            oSQLCommand.Parameters.AddWithValue("@PersonID", oReportUser.PersonID);
            oSQLCommand.Parameters.AddWithValue("@CompanyID", oReportUser.CompanyID);

            SqlDataReader oReader = null;
            try
            {
                oReader = oSQLCommand.ExecuteReader();
                if (oReader.Read())
                {
                    oReportUser.PersonName = oReader.GetString(0);

                    if (IsNullOrEmpty(oReader[1]))
                    {
                        oReportUser.Invalid = true;
                        oReportUser.CompanyName = "[NULL]";
                    }
                    else
                    {
                        oReportUser.CompanyName = oReader.GetString(1);
                    }

                    if (IsNullOrEmpty(oReader[3]))
                    {
                        oReportUser.Invalid = true;
                        oReportUser.Method = "[NULL]";
                    }
                    else
                    {
                        oReportUser.Method = oReader.GetString(3);
                    }


                    if (IsNullOrEmpty(oReader[5]))
                    {
                        oReportUser.Invalid = true;
                        oReportUser.MethodID = -1;
                    }
                    else
                    {
                        oReportUser.MethodID = Convert.ToInt32(oReader.GetString(5));
                    }

                    if (IsNullOrEmpty(oReader[6]))
                    {
                        oReportUser.Invalid = true;
                        oReportUser.Destination = "[NULL]";
                    }
                    else
                    {
                        oReportUser.Destination = oReader.GetString(6).Trim();
                    }

                }
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }
        }

        const string STYLED_BUTTON = @"<table align='right'>
                                            <tr>
                                                <td style='background-color: #68AE00; border: none; color: white; padding: 5px 14px; text-align: center; font-size: 12px; border-radius: 4px; min-width:60px;'>
                                                    <a href='{0}' target='_blank' style = 'color:white;text-decoration: none;font-weight:bold; vertical-align:central;'>{1}</a>
                                                </td>
                                            </tr>
                                       </table><br>";

        const string GET_BR_ENGLISH = "Get Business Report";
        const string GET_BR_SPANISH = "Obtener Informe Comercial";

        /// <summary>
        /// Build HTML email in similar format to current AUS report
        /// </summary>
        /// <param name="recipientPersonId"></param>
        /// <param name="companyId"></param>
        /// <param name="dtStart"></param>
        /// <param name="dtEnd"></param>
        /// <returns></returns>
        protected string GenerateAlertEmail(SqlConnection oConn, int recipientPersonId, int companyId, string industryType, string culture, DateTime dtStart, DateTime dtEnd)
        {
            StringBuilder sb = new StringBuilder();
            DataTable dtMonitoredCompanies = new DataTable();

            using (SqlCommand cmd = new SqlCommand("usp_Alerts_GetMonitoredCompanies"))
            {
                cmd.Parameters.AddWithValue("@PersonID", recipientPersonId);
                cmd.Parameters.AddWithValue("@CompanyID", companyId);
                cmd.Parameters.AddWithValue("@StartDate", dtStart);
                cmd.Parameters.AddWithValue("@EndDate", dtEnd);

                cmd.Connection = oConn;
                cmd.CommandType = CommandType.StoredProcedure;
                using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                {
                    sda.Fill(dtMonitoredCompanies);
                }
            }

            if (dtMonitoredCompanies.Rows.Count > 0)
                AppendHRRow(sb);

            foreach (DataRow row in dtMonitoredCompanies.Rows)
            {
                int MonitoredCompanyID = (int)row["MonitoredCompanyID"];
                string comp_PRCorrTradestyle = (string)row["comp_PRCorrTradestyle"];
                string CityStateCountryShort = (string)row["CityStateCountryShort"];

                string szLinkURL = string.Format(BBOSURL(oConn) + BUSINESS_REPORT_CONFIRM_SELECTIONS, MonitoredCompanyID);
                string szLinkTag = string.Format(STYLED_BUTTON, szLinkURL, culture == "es-mx" ? GET_BR_SPANISH : GET_BR_ENGLISH);

                AppendRow(sb, CityStateCountryShort + szLinkTag); //Add a button for Get Business Report.Hyperlink this to the BusinessReportConfirmation.aspx specifying the subject company ID (put in upper right)
                AppendRow(sb, string.Format("BB #{0}", MonitoredCompanyID), bIndent: true);

                string szCompanyDetailsLink = string.Format("<a href='{0}' class='explicitlink2'>{1}</a>", string.Format(BBOSURL(oConn) + COMPANY_DETAILS_SUMMARY, MonitoredCompanyID), comp_PRCorrTradestyle);
                AppendRow(sb, szCompanyDetailsLink);

                AppendBlankRow(sb);

                sb.Append(GetCreditSheetHTML(oConn, MonitoredCompanyID, dtStart, dtEnd));
                sb.Append(GetNewsHTML(oConn, MonitoredCompanyID, dtStart, dtEnd));
                sb.Append(GetClaimHTML(oConn, MonitoredCompanyID, dtStart, dtEnd));
                sb.Append(GetCourtCaseHTML(oConn, MonitoredCompanyID, dtStart, dtEnd));
                sb.Append(GetBBScoreChangeHTML(oConn, MonitoredCompanyID, dtStart, dtEnd));
                sb.Append(GetBBScoreNewPublishableHTML(oConn, MonitoredCompanyID, dtStart, dtEnd));

                AppendHRRow(sb);
            }

            //Include verbiage from the six (6) textboxes at the end of the current report in this email.
            sb.Append(GetFooterText(oConn, recipientPersonId, companyId, industryType, dtStart, dtEnd));

            return sb.ToString();
        }

        const string COMPANY_DETAILS_SUMMARY = "CompanyDetailsSummary.aspx?CompanyID={0}";
        const string BUSINESS_REPORT_CONFIRM_SELECTIONS = "BusinessReportConfirmSelections.aspx?CompanyIDList={0}";
        const string GET_PUBLICATION_FILE = "GetPublicationFile.aspx";

        const string BR = "<br>";
        const string BLANK_ROW = "<div>&nbsp;</div>";

        private void AppendRow(StringBuilder sb, string szText, bool bIndent = false)
        {
            string szStyle = "";
            if (bIndent)
                szStyle = "style='margin-left:15px;' ";

            sb.Append(string.Format("<div {1}>{0}</div>", szText, szStyle));
        }

        private void AppendBlankRow(StringBuilder sb)
        {
            sb.Append(BLANK_ROW);
        }

        private void RemoveBlankRow(StringBuilder sb)
        {
            if (sb.ToString().EndsWith(BLANK_ROW))
            {
                sb.Remove(sb.ToString().LastIndexOf(BLANK_ROW), BLANK_ROW.Length);
            }
        }

        private void AppendHRRow(StringBuilder sb)
        {
            sb.Append("<hr style='height:4px;border:none;color:#333;background-color:#333;'>");
        }

        private string GetCreditSheetHTML(SqlConnection oConn, int MonitoredCompanyID, DateTime dtStart, DateTime dtEnd)
        {
            StringBuilder sb = new StringBuilder();
            SqlCommand oSQLCommand = new SqlCommand("usp_Alerts_GetCreditItems", oConn);
            oSQLCommand.CommandType = CommandType.StoredProcedure;

            oSQLCommand.Parameters.AddWithValue("@CompanyID", MonitoredCompanyID);
            oSQLCommand.Parameters.AddWithValue("@StartDate", dtStart);
            oSQLCommand.Parameters.AddWithValue("@EndDate", dtEnd);

            SqlDataReader oReader = null;

            try
            {
                oReader = oSQLCommand.ExecuteReader();
                while (oReader.Read())
                {
                    string ItemText = (string)oReader["ItemText"];
                    ItemText = ItemText.Replace("\r\n", BR);
                    AppendRow(sb, ItemText, bIndent: true);
                    AppendBlankRow(sb);
                }

                RemoveBlankRow(sb);

                return sb.ToString();
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }
        }

        private string GetNewsHTML(SqlConnection oConn, int MonitoredCompanyID, DateTime dtStart, DateTime dtEnd)
        {
            StringBuilder sb = new StringBuilder();
            SqlCommand oSQLCommand = new SqlCommand("usp_Alerts_GetNews", oConn);
            oSQLCommand.CommandType = CommandType.StoredProcedure;

            oSQLCommand.Parameters.AddWithValue("@CompanyID", MonitoredCompanyID);
            oSQLCommand.Parameters.AddWithValue("@StartDate", dtStart);
            oSQLCommand.Parameters.AddWithValue("@EndDate", dtEnd);

            SqlDataReader oReader = null;

            try
            {
                oReader = oSQLCommand.ExecuteReader();
                while (oReader.Read())
                {
                    string prpbar_Name = (string)oReader["prpbar_Name"];
                    string URL = (string)oReader["URL"];
                    int prpbar_PublicationArticleID = (int)oReader["prpbar_PublicationArticleID"];

                    string szText = "A BBOS News article has been reported on this firm.  This news article can be read online via BBOS at apps.bluebookservices.com." + BR + BR;
                    string szLink = URL + prpbar_PublicationArticleID.ToString();
                    szText += string.Format("<a href='{0}' class='explicitlink2'>{1}</a>", szLink, prpbar_Name);

                    AppendRow(sb, szText, bIndent: true);
                }

                return sb.ToString();
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }
        }

        private string GetClaimHTML(SqlConnection oConn, int MonitoredCompanyID, DateTime dtStart, DateTime dtEnd)
        {
            StringBuilder sb = new StringBuilder();
            SqlCommand oSQLCommand = new SqlCommand("usp_Alerts_GetClaims", oConn);
            oSQLCommand.CommandType = CommandType.StoredProcedure;

            oSQLCommand.Parameters.AddWithValue("@CompanyID", MonitoredCompanyID);
            oSQLCommand.Parameters.AddWithValue("@StartDate", dtStart);
            oSQLCommand.Parameters.AddWithValue("@EndDate", dtEnd);

            SqlDataReader oReader = null;

            try
            {
                oReader = oSQLCommand.ExecuteReader();
                while (oReader.Read())
                {
                    DateTime prss_OpenedDate = (DateTime)oReader["prss_OpenedDate"];
                    int prss_SSFileID = (int)oReader["prss_SSFileID"];
                    string URL = (string)oReader["URL"];
                    int prss_RespondentCompanyId = (int)oReader["prss_RespondentCompanyId"];

                    string szText = BR + "Blue Book Services has received a new claim filed against this company.  Additional details can be read online via BBOS at apps.bluebookservices.com." + BR + BR;
                    string szLink = URL + prss_RespondentCompanyId.ToString();
                    szText += string.Format("<a href='{0}' class='explicitlink2'>{1} - {2}</a>", szLink, prss_OpenedDate.ToString("MM/dd/yyyy"), prss_SSFileID);

                    AppendRow(sb, szText, bIndent: true);
                }

                return sb.ToString();
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }
        }

        private string GetCourtCaseHTML(SqlConnection oConn, int MonitoredCompanyID, DateTime dtStart, DateTime dtEnd)
        {
            StringBuilder sb = new StringBuilder();
            SqlCommand oSQLCommand = new SqlCommand("usp_Alerts_GetCourtCases", oConn);
            oSQLCommand.CommandType = CommandType.StoredProcedure;

            oSQLCommand.Parameters.AddWithValue("@CompanyID", MonitoredCompanyID);
            oSQLCommand.Parameters.AddWithValue("@StartDate", dtStart);
            oSQLCommand.Parameters.AddWithValue("@EndDate", dtEnd);

            SqlDataReader oReader = null;

            try
            {
                oReader = oSQLCommand.ExecuteReader();
                while (oReader.Read())
                {
                    int prcc_CompanyID = (int)oReader["prcc_CompanyID"];
                    DateTime prcc_FiledDate = (DateTime)oReader["prcc_FiledDate"];
                    string prcc_CaseNumber = (string)oReader["prcc_CaseNumber"];
                    string URL = (string)oReader["URL"];

                    string szText = BR + "A civil case has been filed in Federal court identifying this company as a defendant. Additional details can be read online via BBOS at apps.bluebookservices.com." + BR + BR;
                    string szLink = URL + prcc_CompanyID.ToString();
                    szText += string.Format("<a href='{0}' class='explicitlink2'>{1} - {2}</a>", szLink, prcc_FiledDate.ToString("MM/dd/yyyy"), prcc_CaseNumber);

                    AppendRow(sb, szText, bIndent: true);
                }

                return sb.ToString();
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }
        }

        private string GetBBScoreChangeHTML(SqlConnection oConn, int MonitoredCompanyID, DateTime dtStart, DateTime dtEnd)
        {
            StringBuilder sb = new StringBuilder();
            SqlCommand oSQLCommand = new SqlCommand("usp_Alerts_GetScoreChange", oConn);
            oSQLCommand.CommandType = CommandType.StoredProcedure;

            oSQLCommand.Parameters.AddWithValue("@CompanyID", MonitoredCompanyID);
            oSQLCommand.Parameters.AddWithValue("@StartDate", dtStart);
            oSQLCommand.Parameters.AddWithValue("@EndDate", dtEnd);

            SqlDataReader oReader = null;

            try
            {
                oReader = oSQLCommand.ExecuteReader();
                while (oReader.Read())
                {
                    decimal prbs_BBScore = (decimal)oReader["prbs_BBScore"];
                    decimal PreviousScore = (decimal)oReader["PreviousScore"];

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
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }
        }

        private string GetBBScoreNewPublishableHTML(SqlConnection oConn, int MonitoredCompanyID, DateTime dtStart, DateTime dtEnd)
        {
            StringBuilder sb = new StringBuilder();
            SqlCommand oSQLCommand = new SqlCommand("usp_Alerts_GetNewPublishableScore", oConn);
            oSQLCommand.CommandType = CommandType.StoredProcedure;

            oSQLCommand.Parameters.AddWithValue("@CompanyID", MonitoredCompanyID);
            oSQLCommand.Parameters.AddWithValue("@StartDate", dtStart);
            oSQLCommand.Parameters.AddWithValue("@EndDate", dtEnd);

            SqlDataReader oReader = null;

            try
            {
                oReader = oSQLCommand.ExecuteReader();
                while (oReader.Read())
                {
                    decimal prbs_BBScore = (decimal)oReader["prbs_BBScore"];
                    string szLine = "Blue Book Score of {0} assigned.";

                    AppendRow(sb, string.Format(szLine, (int)prbs_BBScore), bIndent: true);
                }

                return sb.ToString();
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }
        }

        private string GetFooterText(SqlConnection oConn, int recipientPersonId, int MonitoredCompanyID, string industryType, DateTime dtStart, DateTime dtEnd)
        {
            StringBuilder sb = new StringBuilder();
            SqlCommand oSQLCommand = new SqlCommand("usp_Alerts_GetRatingNumerals", oConn);
            oSQLCommand.CommandType = CommandType.StoredProcedure;

            oSQLCommand.Parameters.AddWithValue("@PersonID", recipientPersonId);
            oSQLCommand.Parameters.AddWithValue("@CompanyID", MonitoredCompanyID);
            oSQLCommand.Parameters.AddWithValue("@StartDate", dtStart);
            oSQLCommand.Parameters.AddWithValue("@EndDate", dtEnd);

            SqlDataReader oReader = null;

            try
            {
                AppendRow(sb, "<b><u>Current Rating Definitions:</u></b>");
                AppendBlankRow(sb);

                string szRatingKeyURL;
                if (industryType == "L")
                    szRatingKeyURL = BBOSURL(oConn) + GET_PUBLICATION_FILE + "?PublicationArticleID=7732";
                else
                    szRatingKeyURL = BBOSURL(oConn) + GET_PUBLICATION_FILE + "?PublicationArticleID=6214";

                oReader = oSQLCommand.ExecuteReader();
                while (oReader.Read())
                {
                    string Numeral = (string)oReader["Numeral"];
                    string Description = (string)oReader["Description"];

                    AppendRow(sb, string.Format("{0}&nbsp;&nbsp;&nbsp;&nbsp;{1}", Numeral, Description), bIndent: true);
                }

                AppendBlankRow(sb);
                AppendRow(sb, string.Format("For a list of all Rating Key Numerals, go to the <a href='{0}' class='explicitlink2'>Rating Key</a> in BBOS.", szRatingKeyURL));
                AppendBlankRow(sb);

                AppendRow(sb, "If you have any questions regarding these updates, contact us at <a href='mailto:info@bluebookservices.com' class='explicitlink2'>info@bluebookservices.com</a> or 630 668-3500.");
                AppendBlankRow(sb);

                AppendRow(sb, "The information contained herein is submitted in good faith as reported to us without prejudice, with no guarantee of its correctness in strict confidence to members for their exclusive use and benefit and is subject to the provisions if the membership agreement. It is not to be disclosed and members will be held strictly liable for the expenses, loss or damage to this Company from any such disclosure.Interested members should ask for details before arriving at final conclusions.");
                AppendBlankRow(sb);

                return sb.ToString();
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }
        }



        const string SQL_GET_BBOS_URL = @"SELECT dbo.ufn_GetCustomCaptionValue('BBOS', 'URL', 'en-us') as BBOSURL";

        protected string BBOSURL(SqlConnection oConn)
        {
            if (!string.IsNullOrEmpty(_BBOSURL))
                return _BBOSURL;

            SqlCommand oSQLCommand = new SqlCommand(SQL_GET_BBOS_URL, oConn);
            oSQLCommand.CommandType = CommandType.Text;
            string BBOSURL;

            using (SqlDataReader oReader = oSQLCommand.ExecuteReader(CommandBehavior.Default))
            {
                if (oReader.Read())
                    BBOSURL = (string)oReader["BBOSURL"];
                else
                    BBOSURL = "https://azqa.apps.bluebookservices.com/bbos/";
            }

            _BBOSURL = BBOSURL;
            return _BBOSURL;
        }
    }
}
