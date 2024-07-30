/***********************************************************************
 Copyright Produce Reporter Company 2006-2010

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: PRCreditSheetExport
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Collections;
using System.IO;
using System.Text;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

namespace PRCo.BBS.CRM {
    public partial class PRCreditSheetExport : PageBase {

        protected const string SQL_SELECT = "SELECT prcs_CompanyId,prcs_Tradestyle,prcs_Parenthetical,prcs_Change,prcs_RatingChangeVerbiage,prcs_RatingValue,prcs_PreviousRatingValue,prcs_Notes,prcs_Numeral,prcs_PublishableDate, prci_City, prst_State, prst_Abbreviation, prcn_Country,comp_PRIndustryType,prcs_KeyFlag, dbo.ufn_GetCreditSheetExportSection(comp_PRIndustryType, prcs_KeyFlag, @IsExpress) As Section FROM PRCreditSheet INNER JOIN Company ON prcs_CompanyID = comp_CompanyID INNER JOIN vPRLocation ON ISNULL(prcs_CityID, comp_PRListingCityID) = prci_CityID";
        protected const string SQL_WHERE = " WHERE (prcs_Status = 'P' AND comp_PRIndustryType <> 'L'";
        protected const string SQL_WHERE_EXPRESS = SQL_WHERE + " AND prcs_ExpressUpdatePubDate IS NULL)";
        protected const string SQL_WHERE_CREDIT_SHEET = SQL_WHERE + " AND prcs_WeeklyCSPubDate IS NULL)";
        protected const string SQL_FROM_CREDIT_SHEET = " FROM PRCreditSheet INNER JOIN Company On (Comp_CompanyId = prcs_CompanyId)";


        protected const string SQL_ORDER_BY_EXPRESS = " ORDER BY dbo.ufn_GetCreditSheetExportSection(comp_PRIndustryType, prcs_KeyFlag, @IsExpress), prcn_CountryId, prst_Abbreviation, prci_City, dbo.ufn_GetLowerAlpha(prcs_Tradestyle), prcs_PublishableDate";
        protected const string SQL_ORDER_BY_CREDIT_SHEET = " ORDER BY dbo.ufn_GetCreditSheetExportSection(comp_PRIndustryType, prcs_KeyFlag, @IsExpress), prcn_CountryId, prst_Abbreviation, prci_City, dbo.ufn_GetLowerAlpha(prcs_Tradestyle), prcs_PublishableDate";

        protected const string SQL_INCLUDE_DATE = " OR DATEADD(dd, DATEDIFF(dd,0, {0}), 0) = '{1}'";

        protected const string SQL_SELECT_EXPRESS = SQL_SELECT + SQL_WHERE_EXPRESS;
        protected const string SQL_SELECT_CREDIT_SHEET = SQL_SELECT + SQL_WHERE_CREDIT_SHEET;

        protected const string SQL_UPDATE = "UPDATE PRCreditSheet SET prcs_UpdatedBy=@UpdatedBy, prcs_UpdatedDate=GETDATE(), prcs_Timestamp=GETDATE()"; 
        protected const string SQL_UPDATE_EXPRESS = SQL_UPDATE + ", prcs_ExpressUpdatePubDate=GETDATE()" + SQL_FROM_CREDIT_SHEET + SQL_WHERE_EXPRESS;
        protected const string SQL_UPDATE_CREDIT_SHEET = SQL_UPDATE + ", prcs_WeeklyCSPubDate=GETDATE()" + SQL_FROM_CREDIT_SHEET + SQL_WHERE_CREDIT_SHEET;
        
        protected string sSID = "";
        protected int _iUserID;
        protected DateTime _dtIncludeDate;

        protected ArrayList _alMsgColumnsExceeded = new ArrayList();
        protected const char _cDelimiter = '\t';

        protected string sCreditSheetExpressWednesdayFilename;
        protected string sCreditSheetExpressFridayFilename;
        protected string sCreditSheetFileName;

        override protected void Page_Load(object sender, EventArgs e) {
            base.Page_Load(sender, e);

            lblError.Text = string.Empty;
            lblCreditSheetCount.Text = string.Empty;
            lblExpressCount.Text = string.Empty;

            sCreditSheetExpressFridayFilename = GetFileName(GetConfigValue("CreditSheetExpressFridayName", "FAXA.TXT"));
            sCreditSheetExpressWednesdayFilename = GetFileName(GetConfigValue("CreditSheetExpressWednesdayName", "FAXB.TXT"));
            sCreditSheetFileName = GetFileName(GetConfigValue("CreditSheetName", "CS.TXT"));

            if (!IsPostBack)
            {
                hidUserID.Text = Request["user_userid"];
                hidSID.Text = Request.Params.Get("SID");
                DisplayLastModifiedDate();
            }

            _iUserID = Int32.Parse(hidUserID.Text);
            sSID = hidSID.Text;

            DateTime.TryParse(txtIncludeDate.Text, out _dtIncludeDate);
        }

        /// <summary>
        /// Event handler for the Wednesday button
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnFridayOnClick(Object sender, EventArgs e) {
            try {
                CreateExpressExport(sCreditSheetExpressFridayFilename);
            } catch (Exception eX) {
                lblError.Text = "An Unexpected Error Has Occurred: " + eX.Message;
            }
            DisplayLastModifiedDate();
        }

        /// <summary>
        /// Event handler for the Wednesday button
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnWednesdayOnClick(Object sender, EventArgs e)
        {
            try {
                CreateExpressExport(sCreditSheetExpressWednesdayFilename);
                CreateCreditSheetExport(sCreditSheetFileName);
            } catch (Exception eX) {
                lblError.Text = "An Unexpected Error Has Occurred: " + eX.Message;
            }
            DisplayLastModifiedDate();
        }

        protected void DisplayLastModifiedDate()
        {
            // Show last update dates.
            litFridayExpressFileDate.Text = (File.Exists(sCreditSheetExpressFridayFilename) ? File.GetLastWriteTime(sCreditSheetExpressFridayFilename).ToString() : "N/A");

            litWednesdayExpressFileDate.Text = (File.Exists(sCreditSheetExpressWednesdayFilename) ? File.GetLastWriteTime(sCreditSheetExpressWednesdayFilename).ToString() : "N/A");
            litWednesdayCreditSheetFileDate.Text = (File.Exists(sCreditSheetFileName) ? File.GetLastWriteTime(sCreditSheetFileName).ToString() : "N/A");
        }

        /// <summary>
        /// Creates the Express Export File
        /// </summary>
        /// <param name="szFileName"></param>
        protected void CreateExpressExport(string szFileName) {
            pnlCreditsSheetStats.Visible = true;

            string szSQL = SQL_SELECT_EXPRESS + GetIncludeDateClause("prcs_ExpressUpdatePubDate") + SQL_ORDER_BY_EXPRESS;
            int iRecordCount = GenerateExtractFile(szFileName, szSQL, true);
            lblExpressCount.Text = iRecordCount.ToString("###,###,##0") + " Records written to " + szFileName;

            ExecutePRCreditSheetUpdate(SQL_UPDATE_EXPRESS);

            // Making a little assumption here.  At present, the express update is always
            // executed so we only have to put this check here:
            if (_alMsgColumnsExceeded.Count > 0) {
                lblExpressCount.Text += "<p>&nbsp;";

                foreach (string szMsg in _alMsgColumnsExceeded) {
                    lblExpressCount.Text += "<br>" + szMsg;
                }
            }
       }

        /// <summary>
        /// Creates the Credit Sheet Export file
        /// </summary>
        /// <param name="szFileName"></param>
        protected void CreateCreditSheetExport(string szFileName) {
            pnlCreditsSheetStats.Visible = true;

            string szSQL = SQL_SELECT_CREDIT_SHEET + GetIncludeDateClause("prcs_ExpressUpdatePubDate") + SQL_ORDER_BY_CREDIT_SHEET;
            int iRecordCount = GenerateExtractFile(szFileName, szSQL, false);
            lblCreditSheetCount.Text = iRecordCount.ToString("###,###,##0") + " Records written to " + szFileName;

            ExecutePRCreditSheetUpdate(SQL_UPDATE_CREDIT_SHEET);
        }

        /// <summary>
        /// Creates the extract file writing to the specified file name and query
        /// from the specified SQL.
        /// </summary>
        /// <param name="szFileName"></param>
        /// <param name="szSQL"></param>
        /// <param name="bIsExpress"></param>
        protected int GenerateExtractFile(string szFileName, string szSQL, bool bIsExpress) {
            int iRecordCount = 0;
            StringBuilder sbLine = null;
            SqlConnection dbConn = OpenDBConnection();
            SqlDataReader oReader = null;
            try {
                using (StreamWriter sw = new StreamWriter(szFileName)) {

                    SqlCommand oCommand = new SqlCommand(szSQL, dbConn);
                    oCommand.Parameters.AddWithValue("@IsExpress", bIsExpress);
                    oReader = oCommand.ExecuteReader(CommandBehavior.Default);
                    while (oReader.Read()) {

                        iRecordCount++;
                        sbLine = new StringBuilder();

                        string szCompanyID = Convert.ToString(oReader["prcs_CompanyId"]);

                        sbLine.Append(Convert.ToString(oReader["Section"]));
                        sbLine.Append(_cDelimiter);

                        // Country
                        string szValue = Convert.ToString(oReader["prcn_Country"]);
                        if (szValue == "USA") {
                            sbLine.Append("United States");
                        } else {
                            sbLine.Append(szValue);
                        }
                        sbLine.Append(_cDelimiter);


                        DateTime dtValue = Convert.ToDateTime(oReader["prcs_PublishableDate"]);
                        sbLine.Append(dtValue.ToString("MM/dd/yy"));
                        sbLine.Append(_cDelimiter);
                        
                        sbLine.Append(Convert.ToString(oReader["prst_State"]));
                        sbLine.Append(_cDelimiter);
                        
                        ArrayList alValue = LimitStringLength(Convert.ToString(oReader["prci_City"]), 34);
                        CheckArrayMaxItems(szCompanyID, "prci_City", alValue, 2);
                        AddArrayListToLine(sbLine, alValue, 2);

                        
                        sbLine.Append(szCompanyID);
                        sbLine.Append(_cDelimiter);

                        alValue = LimitStringLength(PrepareStringForExport(Convert.ToString(oReader["prcs_Tradestyle"])), 34);
                        CheckArrayMaxItems(szCompanyID, "prcs_Tradestyle", alValue, 4);
                        AddArrayListToLine(sbLine, alValue, 4);

                        alValue = LimitStringLength(PrepareStringForExport(Convert.ToString(oReader["prcs_Parenthetical"])), 34);
                        CheckArrayMaxItems(szCompanyID, "prcs_Parenthetical", alValue, 10);
                        AddArrayListToLine(sbLine, alValue, 10);

                        alValue = LimitStringLength(PrepareStringForExport(Convert.ToString(oReader["prcs_Change"])), 34);
                        CheckArrayMaxItems(szCompanyID, "prcs_Change", alValue, 61);
                        AddArrayListToLine(sbLine, alValue, 61);

                        // First line of prcs_RatingChangeVerbiage
                        alValue = LimitStringLength(PrepareStringForExport(Convert.ToString(oReader["prcs_RatingChangeVerbiage"])), 34);
                        CheckArrayMaxItems(szCompanyID, "prcs_RatingChangeVerbiage", alValue, 40);
                        string szFirstLine = (string)alValue[0];

                        sbLine.Append(szFirstLine);
                        sbLine.Append(_cDelimiter);
                        alValue.RemoveAt(0);

                        sbLine.Append(Convert.ToString(oReader["prcs_RatingValue"]));
                        sbLine.Append(_cDelimiter);

                        // Remainder of prcs_RatingChangeVerbiage
                        AddArrayListToLine(sbLine, alValue, 40);

                        sbLine.Append(Convert.ToString(oReader["prcs_PreviousRatingValue"]));
                        sbLine.Append(_cDelimiter);

                        alValue = LimitStringLength(PrepareStringForExport(Convert.ToString(oReader["prcs_Notes"])), 34);
                        CheckArrayMaxItems(szCompanyID, "prcs_Notes", alValue, 9);
                        AddArrayListToLine(sbLine, alValue, 9);

                        sbLine.Append(Convert.ToString(oReader["prcs_Numeral"]));
                        sw.WriteLine(sbLine.ToString());
                    }
                }

                return iRecordCount;
            } finally {
                if (oReader != null) {
                    oReader.Close();
                }

                CloseDBConnection(dbConn);
            }
        }


        /// <summary>
        /// Helper method that appends the contents of the array list to 
        /// the string builder.  If we have less strings then the max,
        /// then additional delimiters are appended.
        /// </summary>
        /// <param name="sbLine"></param>
        /// <param name="alValue"></param>
        /// <param name="iMaxColumns"></param>
        protected void AddArrayListToLine(StringBuilder sbLine, ArrayList alValue, int iMaxColumns) {
            for (int i = 0; i < iMaxColumns; i++) {
                if (i < alValue.Count) {
                    sbLine.Append(alValue[i]);
                }
                sbLine.Append(_cDelimiter);
            }
        }

        /// <summary>
        /// Helper method to check the the number of data elements to write out
        /// vs. how many slots are available. 
        /// </summary>
        /// <param name="szCompanyID"></param>
        /// <param name="szFieldName"></param>
        /// <param name="alValue"></param>
        /// <param name="iMaxColums"></param>
        protected void CheckArrayMaxItems(string szCompanyID, string szFieldName, ArrayList alValue, int iMaxColums) {
            if (alValue.Count > iMaxColums) {
                _alMsgColumnsExceeded.Add("BBID " + szCompanyID + " field " + szFieldName + " has " + alValue.Count.ToString() + " lines which exceeds the available columns of " + iMaxColums.ToString() + ".  The truncated record was written to the file.");
            }
        }

        /// <summary>
        /// Helper method to return a fully qualified file name.
        /// </summary>
        /// <param name="szFileName"></param>
        /// <returns></returns>
        protected string GetFileName(string szFileName) {
            string szRootFolder = GetConfigValue("CreditSheetExtractFolder", @"C:\Temp\");
            return string.Concat(szRootFolder, szFileName);
        }

        /// <summary>
        /// Helper method to update the PRCreditSheet records
        /// marking them as processed.
        /// </summary>
        /// <param name="szSQL"></param>
        protected void ExecutePRCreditSheetUpdate(string szSQL) {
            SqlConnection oConn = null;
            try {
                oConn = OpenDBConnection();

                SqlCommand oCommand = new SqlCommand(szSQL, oConn);
                oCommand.Parameters.AddWithValue("@UpdatedBy", _iUserID);
                oCommand.ExecuteNonQuery();

            } finally {
                if (oConn != null) {
                    oConn.Close();
                }
            }
        }

        /// <summary>
        /// Helper method used to specify what previously exported
        /// records to include in this export.
        /// </summary>
        /// <param name="szDateTimeColumn"></param>
        /// <returns></returns>
        protected string GetIncludeDateClause(string szDateTimeColumn) {
            if (_dtIncludeDate == DateTime.MinValue) {
                return string.Empty;
            }

            return string.Format(SQL_INCLUDE_DATE, szDateTimeColumn, _dtIncludeDate.ToString("yyyy-MM-dd"));
        }

        protected string PrepareStringForExport(string szLine) {
            return szLine.Replace("@", @"<\@>");
        }
    }
}
