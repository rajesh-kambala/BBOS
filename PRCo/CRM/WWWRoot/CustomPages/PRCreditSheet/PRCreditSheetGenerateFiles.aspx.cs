/***********************************************************************
 Copyright Produce Reporter Company 2010-2015

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: PRCreditSheetGenerateFiles.aspx
 Description:	

 Notes:

***********************************************************************
***********************************************************************/
using System;
using System.Data.SqlClient;
using System.IO;
using System.Text;

namespace PRCo.BBS.CRM
{
    /// <summary>
    /// This page allows the user to manage the generation of the Weekly Credit Sheet
    /// and Express Update files.
    /// </summary>
    public partial class PRCreditSheetGenerateFiles : PageBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
            Server.ScriptTimeout = 300;

            lblMsg.Text = string.Empty;
            txtCSMessage.Attributes["maxlength"] = "500";

            if (!IsPostBack)
            {
                hidUserID.Text = Request["user_userid"];
                PopulateForm();

                imgbtnCreditSheetPublish.ImageUrl = "/" + _szAppName + "/img/Buttons/continue.gif";
                btnCreditSheetPublish.NavigateUrl = "PRCreditSheetPublish.asp?SID=" + Request.Params.Get("SID");
            
            }
        }

        protected const string SQL_LAST_REPORT_DATE =
                @"SELECT MAX(prcs_WeeklyCSPubDate) As LastCSReportDate, MAX(prcs_ExpressUpdatePubDate) As LastEXReportDate 
                    FROM PRCreditSheet WITH (NOLOCK) 
                         INNER JOIN Company WITH (NOLOCK) ON prcs_CompanyID = comp_CompanyID 
                   WHERE comp_PRIndustryType <> 'L' 
                     AND prcs_Status = 'P' ";

        protected const string SQL_REPORT_COUNT =
                @"SELECT COUNT(1) 
                   FROM PRCreditSheet WITH (NOLOCK) 
                        INNER JOIN Company WITH (NOLOCK) ON prcs_CompanyID = comp_CompanyID 
                  WHERE comp_PRIndustryType <> 'L' 
                    AND prcs_Status = 'P' ";

        protected const string SQL_MOST_RECENT_BATCH =
                @"SELECT * 
                  FROM (SELECT *,
                               RANK() OVER (ORDER BY prcsb_CreatedDate DESC) as Rank
                          FROM PRCreditSheetBatch
                         WHERE prcsb_TypeCode = @TypeCode) T1
                 WHERE Rank = 1";


        protected const string SQL_GET_SETTINGS =
                @"SELECT * 
                   FROM PRCreditSheetBatch
                  WHERE prcsb_TypeCode = @TypeCode
                    AND prcsb_StatusCode = 'S'";



        protected void PopulateForm()
        {
            DateTime dtLastCSPubDate = new DateTime();
            DateTime dtLastEXPubDate = new DateTime();

            int iLastCSCount = 0;
            int iLastEXCount = 0;

            int iNextCSCount = 0;
            int iNextEXCount = 0;

            using (SqlConnection dbConn = OpenDBConnection()) 
            {
                try {
                    SqlCommand cmdLastReportDate = new SqlCommand(SQL_LAST_REPORT_DATE, dbConn);
                    using (SqlDataReader drLastReportDate = cmdLastReportDate.ExecuteReader())
                    {
                        drLastReportDate.Read();
                        dtLastCSPubDate = drLastReportDate.GetDateTime(0);
                        dtLastEXPubDate = drLastReportDate.GetDateTime(1);
                    }

                    string szSQL = SQL_REPORT_COUNT + " AND prcs_WeeklyCSPubDate=@LastDate";
                    SqlCommand cmdCSLastReportCount = new SqlCommand(szSQL, dbConn);
                    cmdCSLastReportCount.Parameters.AddWithValue("LastDate", dtLastCSPubDate);
                    iLastCSCount = (int)cmdCSLastReportCount.ExecuteScalar();

                    szSQL = SQL_REPORT_COUNT + " AND prcs_ExpressUpdatePubDate=@LastDate";
                    SqlCommand cmdEXLastReportCount = new SqlCommand(szSQL, dbConn);
                    cmdEXLastReportCount.Parameters.AddWithValue("LastDate", dtLastEXPubDate);
                    iLastEXCount = (int)cmdEXLastReportCount.ExecuteScalar();

                    szSQL = SQL_REPORT_COUNT + " AND prcs_WeeklyCSPubDate IS NULL";
                    SqlCommand cmdCSNextReportCount = new SqlCommand(szSQL, dbConn);
                    iNextCSCount = (int)cmdCSNextReportCount.ExecuteScalar();

                    szSQL = SQL_REPORT_COUNT + " AND prcs_ExpressUpdatePubDate IS NULL";
                    SqlCommand cmdEXNextReportCount = new SqlCommand(szSQL, dbConn);
                    iNextEXCount = (int)cmdEXNextReportCount.ExecuteScalar();

                    szSQL = "SELECT dbo.ufn_GetCustomCaptionValue('SSRS', 'URL', 'en-us')";
                    SqlCommand cmdSSRSURL = new SqlCommand(szSQL, dbConn);
                    hidSSRSURL.Value = (string)cmdSSRSURL.ExecuteScalar();

                    szSQL = "SELECT dbo.ufn_GetCustomCaptionValue('prcsb_TestLogons', '1', 'en-us')";
                    SqlCommand cmdTestLogons = new SqlCommand(szSQL, dbConn);
                    txtCSTestUsers.Text = (string)cmdTestLogons.ExecuteScalar();



                    if (!IsUserInGroup(dbConn, hidUserID.Text, "4,5,10"))
                    {
                        btnCSGenerateFiles.Enabled = false;
                        btnCSResetLastReportDate.Enabled = false;
                        btnEXGenerateFiles.Enabled = false;
                        btnEXResetLastReportDate.Enabled = false;
                    }


                    lblnfoMsg.Text = string.Empty;
                    tblInfoMsg.Visible = false;
                    SqlCommand cmsLastCSBatch = new SqlCommand(SQL_MOST_RECENT_BATCH, dbConn);
                    cmsLastCSBatch.Parameters.AddWithValue("TypeCode", "CSUPD");
                    using (SqlDataReader reader = cmsLastCSBatch.ExecuteReader())
                    {
                        if (reader.Read()) {
                        
                            string statusCode = reader["prcsb_StatusCode"].ToString();
                            bool disableButtons = false;

                            switch (statusCode)
                            {
                                case "P":
                                    lblnfoMsg.Text = "A request to send the Credit Sheet Report is pending.  A new report cannot be sent until the current request has completed.";
                                    disableButtons = true;
                                    break;
                                case "IP":
                                    lblnfoMsg.Text = "A request to send the Credit Sheet Report is currently being processed.  A new report cannot be sent until the current request has completed.";
                                    disableButtons = true;
                                    break;
                                case "A":
                                    lblnfoMsg.Text = "The previous request to send the Credit Sheet Report aborted with an error.  Contact IT support for further information.";
                                    disableButtons = true;
                                    break;
                            }

                            if (disableButtons)
                            {
                                tblInfoMsg.Visible = true;
                                btnCSGenerateFiles.Enabled = false;
                                btnCSResetLastReportDate.Enabled = false;
                            }
                        }
                    }


                    cmsLastCSBatch = new SqlCommand(SQL_MOST_RECENT_BATCH, dbConn);
                    cmsLastCSBatch.Parameters.AddWithValue("TypeCode", "EXUPD");
                    using (SqlDataReader reader = cmsLastCSBatch.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            EXBatchID.Value = GetString(reader["prcsb_CreditSheetBatchID"]);
                        }
                    }


                    szSQL = "SELECT dbo.ufn_GetCustomCaptionValue('BBOS', 'URL', 'en-us')";
                    SqlCommand cmdBBOSURL = new SqlCommand(szSQL, dbConn);
                    string BBOSURL = (string)cmdBBOSURL.ExecuteScalar();

                    SqlCommand cmsLastExBatch = new SqlCommand(SQL_GET_SETTINGS, dbConn);
                    cmsLastExBatch.Parameters.AddWithValue("TypeCode", "CSUPD");
                    using (SqlDataReader reader = cmsLastExBatch.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            txtCSMessageHeader.Text = GetString(reader["prcsb_ReportHdr"]);
                            txtCSMessage.Text = GetString(reader["prcsb_ReportMsg"]);

                            cbHighlightMarketingMsg.Checked = (GetString(reader["prcsb_HighlightMsg"]) == "Y");

                            hlCSImg.Text = GetString(reader["prcsb_EmailImgURL"]);
                            txtCSImgLink.Text = GetString(reader["prcsb_EmailURL"]);
                            if (!string.IsNullOrEmpty(hlCSImg.Text))
                            {
                                hlCSImg.NavigateUrl = BBOSURL + hlCSImg.Text;
                                cbCSRemoveImage.Visible = true;
                            }
                            else
                            {
                                cbCSRemoveImage.Visible = false;
                            }
                        }
                    }

                    cmsLastExBatch = new SqlCommand(SQL_GET_SETTINGS, dbConn);
                    cmsLastExBatch.Parameters.AddWithValue("TypeCode", "EXUPD");
                    using (SqlDataReader reader = cmsLastExBatch.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            txtEXMessageHeader.Text = GetString(reader["prcsb_ReportHdr"]);
                            txtEXMessage.Text = GetString(reader["prcsb_ReportMsg"]);

                            hlExImg.Text = GetString(reader["prcsb_EmailImgURL"]);
                            txtEXImgLink.Text = GetString(reader["prcsb_EmailURL"]);
                            //hdnExImg.Value = 
                            if (!string.IsNullOrEmpty(hlExImg.Text))
                            {
                                hlExImg.NavigateUrl = BBOSURL + hlExImg.Text;
                                cbExRemoveImage.Visible = true;
                            }
                            else
                            {
                                cbExRemoveImage.Visible = false;
                            }
                        }
                    }

                }
                catch (Exception e)
                {
                    lblMsg.Text += e.Message;
                    return;
                }
            }

            litCSLastReportDate.Text = dtLastCSPubDate.ToString("f");
            litCSLastReportItemCount.Text = iLastCSCount.ToString("###,##0");
            litCSNextReportItemCount.Text = iNextCSCount.ToString("###,##0");

            litEXLastReportDate.Text = dtLastEXPubDate.ToString("f");
            litEXLastReportItemCount.Text = iLastEXCount.ToString("###,##0");
            litEXNextReportItemCount.Text = iNextEXCount.ToString("###,##0");

            hidLastCSDate.Value = dtLastCSPubDate.ToString("f");
            hidLastEXDate.Value = dtLastEXPubDate.ToString("f");

            Session["dtLastCSPubDate"] = dtLastCSPubDate;
            Session["dtLastEXPubDate"] = dtLastEXPubDate;
        }

        /// <summary>
        /// Updates the latest batch of Credit Sheet records setting the weekly publish
        /// date to NULL.  The corresponding BBOS file is also deleted.  Other existing
        /// files on disk are left alone.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnResetLastCSDate(object sender, EventArgs e)
        {
            if (Session["dtLastCSPubDate"] == null)
            {
                lblMsg.Text = "The page timeout expired. Please reload the page and then retry the operation.";
                return;
            }

            string szSQL = "UPDATE PRCreditSheet SET prcs_WeeklyCSPubDate = NULL FROM PRCreditSheet INNER JOIN Company WITH (NOLOCK) ON prcs_CompanyID = comp_CompanyID WHERE comp_PRIndustryType <> 'L' AND prcs_Status = 'P' AND prcs_WeeklyCSPubDate=@LastDate";
            DateTime dtLastCSPubDate = (DateTime)Session["dtLastCSPubDate"];

            int iAffectedRecords = 0;
            SqlConnection dbConn = OpenDBConnection();
            try
            {
                SqlCommand cmdRestLastReportDate = new SqlCommand(szSQL, dbConn);
                cmdRestLastReportDate.Parameters.AddWithValue("LastDate", dtLastCSPubDate);
                iAffectedRecords = cmdRestLastReportDate.ExecuteNonQuery();
            }
            catch (Exception eX)
            {
                lblMsg.Text = eX.Message;
            }
            finally
            {
                CloseDBConnection(dbConn);
            }

            // Now copy the file to the BBOS
            string szFileName = string.Format(GetConfigValue("CreditSheetCSUPDFileName", "Weekly Credit Sheet {0}{1}.pdf"), string.Empty, dtLastCSPubDate.ToString("yyyy-MM-dd"));
            string szTarget = GetConfigValue("BBOSCreditSheetFolder");
            File.Delete(Path.Combine(szTarget, szFileName));

            PopulateForm();

            DisplayUserMessage("Successfully reset Credit Sheet Update records.  The corresponding report in the BBOS has also been deleted.");
        }

        /// <summary>
        /// Updates the latest batch of Express Update records setting the weekly publish
        /// date to NULL. The existing files on disk are left alone.
        /// <param name="sender"></param>
        /// <param name="e"></param>
        /// </summary>
        protected void btnResetLastEXDate(object sender, EventArgs e)
        {
            if (Session["dtLastExPubDate"] == null)
            {
                lblMsg.Text = "The page timeout expired. Please refresh the page and then retry the operation.";
                return;
            }

            string szSQL = "UPDATE PRCreditSheet SET prcs_ExpressUpdatePubDate = NULL FROM PRCreditSheet INNER JOIN Company WITH (NOLOCK) ON prcs_CompanyID = comp_CompanyID WHERE comp_PRIndustryType <> 'L' AND prcs_Status = 'P' AND prcs_ExpressUpdatePubDate=@LastDate";
            DateTime dtLastEXPubDate = (DateTime)Session["dtLastEXPubDate"];

            int iAffectedRecords = 0;
            SqlConnection dbConn = OpenDBConnection();
            try
            {
                SqlCommand cmdRestLastReportDate = new SqlCommand(szSQL, dbConn);
                cmdRestLastReportDate.Parameters.AddWithValue("LastDate", dtLastEXPubDate);
                iAffectedRecords = cmdRestLastReportDate.ExecuteNonQuery();
            }
            catch (Exception eX)
            {
                lblMsg.Text = eX.Message;
            }
            finally
            {
                CloseDBConnection(dbConn);
            }

            PopulateForm();

            DisplayUserMessage("Successfully reset Express Update records.");
            //lblMsg.Text = "Successfully reset Express Update records.";
        }

        protected const string SQL_UDPATE_CS_PUDDATE =
                "UPDATE PRCreditSheet " +
                   "SET prcs_WeeklyCSPubDate = @ReportDate, " +
                       "prcs_UpdatedBy = @UserID, " +
                       "prcs_UpdatedDate = GETDATE(), " +
                       "prcs_Timestamp = GETDATE() " +
                  "FROM PRCreditSheet " +
                       "INNER JOIN Company ON prcs_CompanyID = comp_CompanyID " +
                 "WHERE comp_PRIndustryType <> 'L' " +
                   "AND prcs_Status = 'P' " +
                   "AND prcs_WeeklyCSPubDate IS NULL";

        protected void btnGenerateCSFiles(object sender, EventArgs e)
        {
            DateTime dtReportDate = DateTime.Now;

            SqlConnection dbConn = OpenDBConnection();
            try
            {
                SqlCommand cmdUpdateCSPubDate = new SqlCommand(SQL_UDPATE_CS_PUDDATE, dbConn);
                cmdUpdateCSPubDate.Parameters.AddWithValue("ReportDate", dtReportDate);
                cmdUpdateCSPubDate.Parameters.AddWithValue("UserID", Convert.ToInt32(hidUserID.Text));
                cmdUpdateCSPubDate.ExecuteNonQuery();
            }
            catch (Exception eX)
            {
                lblMsg.Text += eX.Message;
                return;
            }
            finally
            {
                CloseDBConnection(dbConn);
            }

            try
            {
                GenerateReportFile("Email", "CSUPD", dtReportDate);
                GenerateReportFile("Fax", "CSUPD", dtReportDate);
                GenerateEmailDistributionFile("CSUPD", dtReportDate);
                GenerateFaxDistributionFile("CSUPD", dtReportDate);

                // Now copy the file to the BBOS

                string szTargetFolder = GetConfigValue("BBOSCreditSheetFolder");
                string szTargetFileName =  string.Format(GetConfigValue("CreditSheetBBOSFileName", "Weekly Credit Sheet {0}.pdf"),  dtReportDate.ToString("yyyy-MM-dd"));
                
                string szSourceFolder = GetConfigValue("CreditSheetExportFolder");
                string szSourceFileName = string.Format(GetConfigValue("CreditSheetCSUPDFileName", "Weekly Credit Sheet {0}{1}.pdf"), string.Empty, dtReportDate.ToString("yyyy-MM-dd"));

                File.Copy(Path.Combine(szSourceFolder, szSourceFileName), Path.Combine(szTargetFolder, szTargetFileName));

                DisplayUserMessage("Successfully created the Credit Sheet Update files.  They can be found at " + szSourceFolder + ".  The report has also been published in the BBOS.");
                PopulateForm();
            }
            catch (Exception ex2)
            {
                lblMsg.Text = ex2.Message;
            }
        }

        protected void btnSendCreditSheet(object sender, EventArgs e)
        {
            if (SaveCreditSheeetSettings())
            {
                SendCreditSheet();
            }


        }

        protected void btnSaveCreditSheetSetting(object sender, EventArgs e)
        {
            if (SaveCreditSheeetSettings())
            {
                DisplayUserMessage("The Credit Sheet settings have been saved.");
                PopulateForm();
            }
        }

        protected void SendCreditSheet()
        {
            DateTime dtReportDate = DateTime.Now;

            SqlConnection dbConn = OpenDBConnection();
            try
            {
                if (!cbTest.Checked)
                {
                    SqlCommand cmdUpdateCSPubDate = new SqlCommand(SQL_UDPATE_CS_PUDDATE, dbConn);
                    cmdUpdateCSPubDate.Parameters.AddWithValue("ReportDate", dtReportDate);
                    cmdUpdateCSPubDate.Parameters.AddWithValue("UserID", Convert.ToInt32(hidUserID.Text));
                    cmdUpdateCSPubDate.ExecuteNonQuery();
                }

                // Generate the file for BBOS.
                if (!cbTest.Checked)
                {
                    GenerateReportFile("Email", "CSUPD", dtReportDate);
                    GenerateReportFile("Fax", "CSUPD", dtReportDate);

                    string szTargetFolder = GetConfigValue("BBOSCreditSheetFolder");
                    string szTargetFileName = string.Format(GetConfigValue("CreditSheetBBOSFileName", "Weekly Credit Sheet {0}.pdf"), dtReportDate.ToString("yyyy-MM-dd"));
                    if (File.Exists(Path.Combine(szTargetFolder, szTargetFileName)))
                    {
                        File.Delete(Path.Combine(szTargetFolder, szTargetFileName));
                    }

                    string szSourceFolder = GetConfigValue("CreditSheetExportFolder");
                    string szSourceFileName = string.Format(GetConfigValue("CreditSheetCSUPDFileName", "Weekly Credit Sheet {0}{1}.pdf"), string.Empty, dtReportDate.ToString("yyyy-MM-dd"));

                    File.Copy(Path.Combine(szSourceFolder, szSourceFileName), Path.Combine(szTargetFolder, szTargetFileName));
                }

                InsertBatch(dbConn, "CSUPD", dtReportDate, cbTest.Checked, txtCSTestUsers.Text, cbHighlightMarketingMsg.Checked);
            }
            catch (Exception eX)
            {
                lblMsg.Text += eX.Message;
                return;
            }
            finally
            {
                CloseDBConnection(dbConn);
            }

            try
            {
                DisplayUserMessage("The Credit Sheets batch has been created and will be processed shortly.");
                PopulateForm();
            }
            catch (Exception ex2)
            {
                lblMsg.Text = ex2.Message;
            }

        }

        protected bool SaveCreditSheeetSettings()
        {
            SqlConnection dbConn = OpenDBConnection();
            try
            {
                string emailImg = null;
                if (upCSImg.HasFile)
                {
                    GetCSImgDirs();

                    // Make sure that the directory exists.
                    if (!Directory.Exists(_szCSImagefolder))
                    {
                        Directory.CreateDirectory(_szCSImagefolder);
                    }

                    string fullFile = Path.Combine(_szCSImagefolder, upCSImg.FileName);
                    emailImg = _szCSImageVirtualDir + upCSImg.FileName;
                    upCSImg.SaveAs(fullFile);
                }
                else
                {
                    if (!cbCSRemoveImage.Checked)
                    {
                        emailImg = hlCSImg.Text;
                    }
                }

                UpdateSettings(dbConn, "CSUPD", txtCSMessageHeader.Text, txtCSMessage.Text, emailImg, txtCSImgLink.Text, cbHighlightMarketingMsg.Checked);
                return true;
            }
            catch (Exception eX)
            {
                lblMsg.Text += eX.Message;
                return false;
            }
            finally
            {
                CloseDBConnection(dbConn);
            }
        }

        protected void btnSaveExpressUpdate(object sender, EventArgs e)
        {
            SaveExpressUpdateSettings();
        }

        protected void SaveExpressUpdateSettings()
        {
            SqlConnection dbConn = OpenDBConnection();
            try
            {
                string emailImg = null;
                if (upEXImg.HasFile)
                {
                    GetCSImgDirs();

                    // Make sure that the directory exists.
                    if (!Directory.Exists(_szCSImagefolder))
                    {
                        Directory.CreateDirectory(_szCSImagefolder);
                    }

                    string fullFile = Path.Combine(_szCSImagefolder, upEXImg.FileName);
                    emailImg = _szCSImageVirtualDir + upEXImg.FileName;
                    upEXImg.SaveAs(fullFile);
                }
                else
                {
                    if (!cbExRemoveImage.Checked)
                    {
                        emailImg = hlExImg.Text;
                    }
                }

                UpdateSettings(dbConn, "EXUPD", txtEXMessageHeader.Text, txtEXMessage.Text, emailImg, txtEXImgLink.Text, false);
                InsertBatch(dbConn, "EXUPD", DateTime.Now, false, null, false);
            }
            catch (Exception eX)
            {
                lblMsg.Text += eX.Message;
                return;
            }
            finally
            {
                CloseDBConnection(dbConn);
            }

            try
            {

                DisplayUserMessage("The Express Update settings have been saved.");
                PopulateForm();
            }
            catch (Exception ex2)
            {
                lblMsg.Text = ex2.Message;
            }
        }

        protected const string SQL_UPDATE_SETTINGS =
            @"UPDATE PRCreditSheetBatch
                 SET prcsb_ReportHdr = @ReportHdr,
                     prcsb_ReportMsg = @ReportMsg,
                     prcsb_HighlightMsg = @HighlightMsg,
                     prcsb_EmailImgURL = @EmailImgURL,
                     prcsb_EmailURL = @EmailURL,
                     prcsb_UpdatedBy = @UserID,
                     prcsb_UpdatedDate = GETDATE(), 
                     prcsb_Timestamp = GETDATE()
               WHERE prcsb_StatusCode = 'S'
                 AND prcsb_TypeCode = @TypeCode";

        protected void UpdateSettings(SqlConnection dbConn, string typeCode, string reportHdr, string reportMsg, string emailImgURL, string emailURL, bool bHighlightMarketingMessage)
        {
            SqlCommand cmdUpateBatch = new SqlCommand(SQL_UPDATE_SETTINGS, dbConn);
            cmdUpateBatch.Parameters.AddWithValue("TypeCode", typeCode);
            cmdUpateBatch.Parameters.AddWithValue("ReportHdr", reportHdr);
            cmdUpateBatch.Parameters.AddWithValue("ReportMsg", reportMsg);
            if (bHighlightMarketingMessage)
                cmdUpateBatch.Parameters.AddWithValue("HighlightMsg", "Y");
            else
                cmdUpateBatch.Parameters.AddWithValue("HighlightMsg", DBNull.Value);

            if (!string.IsNullOrEmpty(emailImgURL))
            {
                cmdUpateBatch.Parameters.AddWithValue("EmailImgURL", emailImgURL);
            }
            else
            {
                cmdUpateBatch.Parameters.AddWithValue("EmailImgURL", DBNull.Value);
            }

            if (!string.IsNullOrEmpty(emailURL))
            {
                cmdUpateBatch.Parameters.AddWithValue("EmailURL", emailURL);
            }
            else
            {
                cmdUpateBatch.Parameters.AddWithValue("EmailURL", DBNull.Value);
            }

            cmdUpateBatch.Parameters.AddWithValue("UserID", Convert.ToInt32(hidUserID.Text));
            cmdUpateBatch.ExecuteNonQuery();
        }


        protected const string SQL_INSERT_BATCH =
            @"INSERT INTO PRCreditSheetBatch (prcsb_TypeCode, prcsb_StatusCode, prcsb_ReportDateTime, prcsb_ReportHdr, prcsb_ReportMsg, prcsb_HighlightMsg, prcsb_EmailImgURL, prcsb_EmailURL, prcsb_Test, prcsb_TestLogons, prcsb_CreatedBy, prcsb_CreatedDate, prcsb_UpdatedBy, prcsb_UpdatedDate, prcsb_Timestamp)
                SELECT prcsb_TypeCode, 'P', @ReportDateTime, prcsb_ReportHdr, prcsb_ReportMsg, prcsb_HighlightMsg, prcsb_EmailImgURL, prcsb_EmailURL, @Test, @TestLogons, @UserID, GETDATE(), @UserID, GETDATE(), GETDATE()
                 FROM PRCreditSheetBatch
                 WHERE prcsb_StatusCode = 'S'
                   AND prcsb_TypeCode = @TypeCode";

        protected void InsertBatch(SqlConnection dbConn, string typeCode, DateTime reportDateTime, bool isTest, string testLogons, bool bHighlightMarketingMessage)
        {
            SqlCommand cmdUpateBatch = new SqlCommand(SQL_INSERT_BATCH, dbConn);
            cmdUpateBatch.Parameters.AddWithValue("TypeCode", typeCode);
            cmdUpateBatch.Parameters.AddWithValue("UserID", Convert.ToInt32(hidUserID.Text));
            if (isTest)
            {
                cmdUpateBatch.Parameters.AddWithValue("ReportDateTime", DBNull.Value);
                cmdUpateBatch.Parameters.AddWithValue("Test", "Y");
                cmdUpateBatch.Parameters.AddWithValue("TestLogons", testLogons);
            }
            else
            {
                cmdUpateBatch.Parameters.AddWithValue("ReportDateTime", reportDateTime);
                cmdUpateBatch.Parameters.AddWithValue("Test", DBNull.Value);
                cmdUpateBatch.Parameters.AddWithValue("TestLogons", DBNull.Value);
            }

            cmdUpateBatch.ExecuteNonQuery();
        }

        protected const string SQL_UPDATE_BATCH_STATUS =
                   "UPDATE PRCreditSheetBatch SET prcsb_StatusCode = @StatusCode WHERE prcsb_CreditSheetBatchID = @CreditSheetBatchID;";

        private void UpdateBatchStatus(SqlConnection sqlConn, int batchID, string statusCode)
        {
            SqlCommand sqlCommand = new SqlCommand(SQL_UPDATE_BATCH_STATUS, sqlConn);
            sqlCommand.Parameters.AddWithValue("@CreditSheetBatchID", batchID);
            sqlCommand.Parameters.AddWithValue("@StatusCode", statusCode);
            sqlCommand.ExecuteNonQuery();
        }



        protected const string SQL_UDPATE_EX_PUBDATE =
                "UPDATE PRCreditSheet " +
                   "SET prcs_ExpressUpdatePubDate = @ReportDate, " +
                       "prcs_UpdatedBy = @UserID, " +
                       "prcs_UpdatedDate = GETDATE(), " +
                       "prcs_Timestamp = GETDATE() " +
                  "FROM PRCreditSheet " +
                       "INNER JOIN Company ON prcs_CompanyID = comp_CompanyID " +
                 "WHERE comp_PRIndustryType <> 'L' " +
                   "AND prcs_Status = 'P' " +
                   "AND prcs_ExpressUpdatePubDate IS NULL";

        protected void btnGenerateEXFiles(object sender, EventArgs e)
        {
            DateTime dtReportDate = DateTime.Now;

            SqlConnection dbConn = OpenDBConnection();
            try
            {
                SqlCommand cmdUpdateEXPubDate = new SqlCommand(SQL_UDPATE_EX_PUBDATE, dbConn);
                cmdUpdateEXPubDate.Parameters.AddWithValue("ReportDate", dtReportDate);
                cmdUpdateEXPubDate.Parameters.AddWithValue("UserID", Convert.ToInt32(hidUserID.Text));
                cmdUpdateEXPubDate.ExecuteNonQuery();
            }
            catch (Exception eX)
            {
                lblMsg.Text = eX.Message;
                return;
            }
            finally
            {
                CloseDBConnection(dbConn);
            }

            try
            {
                GenerateReportFile("Email", "EXUPD", dtReportDate);
                GenerateReportFile("Fax", "EXUPD", dtReportDate);
                GenerateEmailDistributionFile("EXUPD", dtReportDate);
                GenerateFaxDistributionFile("EXUPD", dtReportDate);

                DisplayUserMessage("Successfully created the Express Update files.  They can be found at " + GetConfigValue("CreditSheetExportFolder"));
                //lblMsg.Text = "Successfully created the Express Update files.  They can be found at " + GetConfigValue("CreditSheetExportFolder");
                PopulateForm();
            }
            catch (Exception ex2)
            {
                lblMsg.Text = ex2.Message;
            }
        }

        protected const string SQL_EMAIL_ATTENTION_LINES =
            @"SELECT comp_CompanyId, RTRIM(emai_EmailAddress) , comp_PRCorrTradestyle, dbo.ufn_GetRemainingBRCount(comp_CompanyID) as RemainingBRCount
                FROM PRAttentionLine WITH (NOLOCK) 
                     INNER JOIN Email WITH (NOLOCK) ON prattn_EmailID = emai_EmailID 
                     INNER JOIN Company WITH (NOLOCK) ON prattn_CompanyID = comp_CompanyID
               WHERE prattn_Disabled IS NULL 
                 AND prattn_ItemCode = @ItemCode
            ORDER BY comp_CompanyId";

        /// <summary>
        /// Helper method that generates the CSV file containing the email recipients of
        /// the specified report type.
        /// </summary>
        /// <param name="szReportType"></param>
        /// <param name="dtReportDate"></param>
        protected void GenerateEmailDistributionFile(string szReportType, DateTime dtReportDate)
        {
            SqlConnection dbConn = OpenDBConnection();
            try
            {
                SqlCommand cmdEmailFile = new SqlCommand(SQL_EMAIL_ATTENTION_LINES, dbConn);
                cmdEmailFile.Parameters.AddWithValue("ItemCode", szReportType);

                StringBuilder sbEmailFile = new StringBuilder("BBID,Email Address,Company Name,Business Reports");


                using (SqlDataReader drEmailFile = cmdEmailFile.ExecuteReader())
                {
                    while (drEmailFile.Read())
                    {
                        sbEmailFile.Append(Environment.NewLine);
                        sbEmailFile.Append(drEmailFile.GetInt32(0).ToString());
                        sbEmailFile.Append(",\"");
                        sbEmailFile.Append(drEmailFile.GetString(1));
                        sbEmailFile.Append("\",\"");
                        sbEmailFile.Append(drEmailFile.GetString(2));
                        sbEmailFile.Append("\",");
                        sbEmailFile.Append(drEmailFile.GetInt32(3).ToString());
                    }
                }

                string szFolder = GetConfigValue("CreditSheetExportFolder");
                string szName = null;
                if (szReportType == "CSUPD")
                {
                    szName = GetConfigValue("CreditSheetCSUPDDistributionListFileName", "Weekly Credit Sheet Distribution List {0} {1}.csv");
                }
                else
                {
                    szName = GetConfigValue("CreditSheetEXUPDDistributionListFileName", "Express Update Distribution List {0} {1}.csv");
                }
                string szFullName = Path.Combine(szFolder, string.Format(szName, "Email", dtReportDate.ToString("yyyy-MM-dd")));

                using (StreamWriter outfile = new StreamWriter(szFullName))
                {
                    outfile.Write(sbEmailFile.ToString());
                }
            }
            finally
            {
                CloseDBConnection(dbConn);
            }

        }

        protected const string SQL_FAX_ATTENTION_LINES =
          @"SELECT prattn_CompanyID, 
                   dbo.ufn_FormatPhone(phon_CountryCode, phon_AreaCode, phon_Number, phon_PRExtension), 
                   ISNULL(prattn_CustomLine, dbo.ufn_FormatPerson2(pers_FirstName, pers_LastName, pers_MiddleName, pers_PRNickName1, pers_Suffix, 0)) As Addressee, 
                   dbo.ufn_GetRemainingBRCount(prattn_CompanyID) as RemainingBRCount 
              FROM PRAttentionLine WITH (NOLOCK) 
                   INNER JOIN Phone WITH (NOLOCK) ON prattn_PhoneID = phon_PhoneID 
                   LEFT OUTER JOIN Person WITH (NOLOCK) ON prattn_PersonID = pers_PersonID 
             WHERE prattn_Disabled IS NULL 
               AND prattn_ItemCode = @ItemCode 
          ORDER BY prattn_CompanyID ";
         
        /// <summary>
        /// Helper method that generates the CSV file containing the fax recipients of
        /// the specified report type.
        /// </summary>
        /// <param name="szReportType"></param>
        /// <param name="dtReportDate"></param>
        protected void GenerateFaxDistributionFile(string szReportType, DateTime dtReportDate)
        {
            SqlConnection dbConn = OpenDBConnection();
            try
            {
                SqlCommand cmdFaxFile = new SqlCommand(SQL_FAX_ATTENTION_LINES, dbConn);
                cmdFaxFile.Parameters.AddWithValue("ItemCode", szReportType);

                StringBuilder sbFaxFile = new StringBuilder("TO1,ADDR,TO2,Business Reports");


                using (SqlDataReader drFaxFile = cmdFaxFile.ExecuteReader())
                {
                    while (drFaxFile.Read())
                    {
                        sbFaxFile.Append(Environment.NewLine);
                        sbFaxFile.Append(drFaxFile.GetInt32(0).ToString());
                        sbFaxFile.Append(",");
                        sbFaxFile.Append(drFaxFile.GetString(1));
                        sbFaxFile.Append(",\"");
                        if (drFaxFile[2] != DBNull.Value)
                        {
                            sbFaxFile.Append(drFaxFile.GetString(2));
                        }
                        sbFaxFile.Append("\",");
                        sbFaxFile.Append(drFaxFile.GetInt32(3).ToString());
                    }
                }

                string szFolder = GetConfigValue("CreditSheetExportFolder");
                string szName = null;
                if (szReportType == "CSUPD")
                {
                    szName = GetConfigValue("CreditSheetCSUPDDistributionListFileName", "Weekly Credit Sheet Distribution List {0} {1}.csv");
                }
                else
                {
                    szName = GetConfigValue("CreditSheetEXUPDDistributionListFileName", "Express Update Distribution List {0} {1}.csv");
                }   
                string szFullName = Path.Combine(szFolder, string.Format(szName, "Fax", dtReportDate.ToString("yyyy-MM-dd")));

                using (StreamWriter outfile = new StreamWriter(szFullName))
                {
                    outfile.Write(sbFaxFile.ToString());
                }
            }
            finally
            {
                CloseDBConnection(dbConn);
            }

        }


        ReportInterface _oReportInterface = null;
        /// <summary>
        /// Helper method generates the report from SSRS and saves it to disk
        /// </summary>
        /// <param name="szMethod"></param>
        /// <param name="szReportType"></param>
        /// <param name="dtReportDate"></param>
        protected void GenerateReportFile(string szMethod, string szReportType, DateTime dtReportDate)
        {
            string szFolder = GetConfigValue("CreditSheetExportFolder");
            string szSuffix = string.Empty;
            byte[] abReport = null;

            if (_oReportInterface == null)
            {
                _oReportInterface = new ReportInterface();
            }
            
            if (szMethod == "Email")
            {
                abReport = _oReportInterface.GenerateCreditSheetReportEmail(szReportType,
                                                                            "'P','T','S'",
                                                                             dtReportDate.ToString("yyyy-MM-dd HH:mm:ss.fff"),
                                                                             "I",
                                                                             txtCSMessageHeader.Text,
                                                                             txtCSMessage.Text,
                                                                             cbHighlightMarketingMsg.Checked
                                                                             );
            }
            else
            {
                abReport = _oReportInterface.GenerateCreditSheetReportFax(szReportType,
                                                                          "'P','T','S'",
                                                                          dtReportDate.ToString("yyyy-MM-dd HH:mm:ss.fff"),
                                                                             "I",
                                                                             txtCSMessageHeader.Text,
                                                                             txtCSMessage.Text);

                szSuffix = "Fax ";
            }

            string szName = null;
            if (szReportType == "CSUPD")
            {
                szName =GetConfigValue("CreditSheetCSUPDFileName", "Weekly Credit Sheet {0}{1}.pdf");
            }
            else
            {
                szName = GetConfigValue("CreditSheetEXUPDFileName", "Express Update {0}{1}.pdf");
            }            

            
            string szFullName = Path.Combine(szFolder, string.Format(szName, szSuffix, dtReportDate.ToString("yyyy-MM-dd")));

            if (File.Exists(szFolder))
            {
                File.Delete(szFullName);
            }

            using (FileStream oFStream = File.Create(szFullName, abReport.Length))
            {
                oFStream.Write(abReport, 0, abReport.Length);
            }
        }

        string _szCSImageVirtualDir;
        string _szCSImagefolder;

        protected const string SQL_SELECT_CS_IMG_DIR = "SELECT capt_code, capt_us FROM Custom_Captions WITH (NOLOCK) WHERE Capt_FamilyType = 'Choices' AND Capt_Family = 'PRCompanyCSImageDirectory'";
        private void GetCSImgDirs()
        {
            using (SqlConnection sqlConn =  OpenDBConnection()) {
                
                SqlCommand cmdRootDir = new SqlCommand(SQL_SELECT_CS_IMG_DIR, sqlConn);

                using (SqlDataReader reader = cmdRootDir.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        _szCSImageVirtualDir = reader.GetString(0).Trim();
                        if ((!_szCSImageVirtualDir.EndsWith(@"/")))
                        {
                            _szCSImageVirtualDir += @"/";
                        }

                        _szCSImagefolder = reader.GetString(1).Trim();
                        if ((!_szCSImagefolder.EndsWith(@"\")))
                        {
                            _szCSImagefolder += @"\";
                        }
                    }
                }

                if (string.IsNullOrEmpty(_szCSImagefolder))
                {
                    throw new ApplicationException("Unable to find 'PRCompanyCSImageDirectory' custom_caption value.");
                }

            }
        }

    }
}