/***********************************************************************
 Copyright Blue Book Services, Inc. 2018-2023

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: BBScoreExportCombinedEvent.cs
 Description:	

 Notes:	Based on BBScoreLumberEvent.cs.  Combined lumber (4 files)
 with Produce (5 files).

***********************************************************************
***********************************************************************/
using ICSharpCode.SharpZipLib.Zip;
using System;
using System.Data.SqlClient;
using System.IO;
using System.Timers;
using TSI.Utils;

namespace PRCo.BBS.BBSMonitor
{
    public class BBScoreExportCombinedEvent : BBSMonitorEvent
    {
        private int _DayOfMonthProduce = 0;
        private int _DayOfMonthLumber = 0;
        private const string DELIMITER = "\t";

        /// <summary>
        /// Generates the BB Score Export combined files
        /// </summary>
        override public void Initialize(int iIndex)
        {
            _szName = "BBScoreExportCombinedEvent";

            base.Initialize(iIndex);

            try
            {
                _DayOfMonthProduce = Utilities.GetIntConfigValue("BBScoreExportCombinedDayOfMonthProduce", 1);
                _DayOfMonthLumber = Utilities.GetIntConfigValue("BBScoreExportCombinedDayOfMonthLumber", 5);
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("BBScoreExportCombinedInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("BBScoreExportCombined Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("BBScoreExportCombinedStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("BBScoreExportCombined Start: " + _dtNextDateTime.ToString());

            }
            catch (Exception e)
            {
                LogEventError("Error initializing BBScoreExportCombined event.", e);
                throw;
            }
        }

        /// <summary>
        /// Process any BB Score Lumber reports.
        /// </summary>
        override public void ProcessEvent()
        {
            // We actually only run once a month, on the day
            // of the month specified.
            if (DateTime.Today.Day != _DayOfMonthProduce && DateTime.Today.Day != _DayOfMonthLumber)
            {
                _oLogger.LogMessage($"DayOfMonth to run (from config file) = {_DayOfMonthProduce} (Produce) and {_DayOfMonthLumber} (Lumber) - SKIPPING");
                return;
            }

            if(DateTime.Today.Day == _DayOfMonthLumber)
                ProcessLumberEvent();
            
            if (DateTime.Today.Day == _DayOfMonthProduce)
                ProcessProduceEvent();
        }

        #region Lumber
        private void ProcessLumberEvent()
        {
            SqlConnection oConn = new SqlConnection(GetConnectionString());
            const string CUSTOM_CAPTION = "prlumber_LastRunDate";
            const string FILE_NAME_LUMBER_AR_AGING = "Lumber AR Aging.csv";
            const string FILE_NAME_RATINGS = "Ratings.csv";
            const string FILE_PAY_INDICATOR = "PayIndicator.csv";
            const string FILE_RATING_NUMERAL_CHANGES = "RatingNumeralChanges.csv";
            string FILE_NAME_ZIP = Utilities.GetConfigValue("BBScoreExportCombinedLumberFTPFileName", "LumberBB.zip");

            try
            {
                string targetFolder = Utilities.GetConfigValue("BBScoreExportCombinedFolder");

                oConn.Open();

                DateTime dtLastRunDate = GetDateTimeCustomCaption(oConn, CUSTOM_CAPTION); //to create stub NULL prlumber_LastRunDate, run this script: 	INSERT INTO Custom_Captions (Capt_CaptionId, Capt_FamilyType, Capt_Family, Capt_Code, Capt_US, Capt_UK, Capt_FR, Capt_DE, Capt_ES, Capt_Order, Capt_System, Capt_CreatedBy, Capt_CreatedDate, Capt_UpdatedBy, Capt_UpdatedDate, Capt_TimeStamp, Capt_Deleted, Capt_Context, Capt_DU, Capt_JP, Capt_Component, capt_deviceid, capt_integrationid, capt_CS) values (((select max(capt_captionid) from Custom_Captions) + 1),'Choices', 'prlumber_LastRunDate', NULL, 'Lumber BB Last Run Date/Time', 'Lumber BB Last Run Date/Time', 'Lumber BB Last Run Date/Time', 'Lumber BB Last Run Date/Time', 'Lumber BB Last Run Date/Time', 0, NULL, -1, GETDATE(), -1000, GETDATE(), GETDATE(), NULL, NULL, NULL, NULL, 'PRDropdownValues', NULL, NULL, NULL)

                _oLogger.LogMessage("ProcessLumberEvent() started");
                _oLogger.LogMessage("Lumber dtLastRunDate=" + dtLastRunDate.ToString());

                //Create CSV files
                CreateLumberARFile(oConn, targetFolder, FILE_NAME_LUMBER_AR_AGING, dtLastRunDate);
                CreateLumberRatingFile(oConn, targetFolder, FILE_NAME_RATINGS, dtLastRunDate);
                CreateLumberPayIndicatorFile(oConn, targetFolder, FILE_PAY_INDICATOR, dtLastRunDate);
                CreateLumberRatingNumeralChangedFile(oConn, targetFolder, FILE_RATING_NUMERAL_CHANGES, dtLastRunDate);

                string ftpFileName = CompressFiles(targetFolder, FILE_NAME_ZIP, FILE_NAME_LUMBER_AR_AGING, FILE_NAME_RATINGS, FILE_PAY_INDICATOR, FILE_RATING_NUMERAL_CHANGES);

                _oLogger.LogMessage(String.Format("zip file {0} created", ftpFileName));
                string msg = string.Empty;

                if (Utilities.GetBoolConfigValue("BBScoreExportCombinedProcessFTP", true))
                {
                    //FTP zip file
                    string ftpURL = Utilities.GetConfigValue("BBScoreExportCombinedFTPServer", "ftp://ftp.bluebookservices.com");

                    UploadFileSFTP(ftpURL,
                                   Utilities.GetIntConfigValue("BBScoreExportCombinedFTPPort", 9210),
                                   Utilities.GetConfigValue("BBScoreExportCombinedFTPUsername", "qa"),
                                   Utilities.GetConfigValue("BBScoreExportCombinedFTPPassword", "fTp~1901"),
                                   ftpFileName,
                                   Utilities.GetConfigValue("BBScoreExportCombinedFTPFolder", "data") + "/" + Path.GetFileName(ftpFileName));

                    msg = String.Format("Zip file {0} sent via FTP to {1}", ftpFileName, ftpURL);
                    _oLogger.LogMessage(msg);
                }

                //FINALIZE
                UpdateDateTimeCustomCaption(oConn, CUSTOM_CAPTION, DateTime.Now);

                if (Utilities.GetBoolConfigValue("BBScoreExportCombinedWriteResultsToEventLog", true))
                {
                    LogEvent("Lumber BBScore AR data successfully generated. " + msg);
                }

                if (Utilities.GetBoolConfigValue("BBScoreExportCombinedSendResultsToSupport", true))
                {
                    SendMail("Lumber BBScore AR Success", "Lumber BBScore AR data successfully generated. " + msg);
                }
            }
            catch (Exception e)
            {
                LogEventError("Error Procesing BBScoreExportCombined.ProcessLumberEvent.", e);
            }
            finally
            {
                if (oConn != null)
                    oConn.Close();

                oConn = null;
            }
        }

        protected const string LumberAgingDataSQL =
                @"SELECT praa_CompanyID as SubmitterID,
						 praad_SubjectCompanyID as SubjectID,
						 CAST(praa_Date as Date) as [ARDate],
						 ISNULL(praad_AmountCurrent, 0) [AmountCurrent], 
						 ISNULL(praad_Amount1to30, 0) [Amount1to30], 
						 ISNULL(praad_Amount31to60, 0) [Amount31to60], 
						 ISNULL(praad_Amount61to90, 0) [Amount61to90], 
						 ISNULL(praad_Amount91Plus, 0) [Amount91Plus]
			        FROM Company WITH (NOLOCK)
					 	 INNER JOIN PRARAging WITH (NOLOCK) ON comp_CompanyID = praa_CompanyID
						 INNER JOIN PRARAgingDetail WITH (NOLOCK) ON praa_ARAgingID = praad_ARAgingID
			       WHERE comp_PRIndustryType = 'L'
					 AND praa_CreatedDate > @LastRunDate
					 AND praad_SubjectCompanyID IS NOT NULL
			    ORDER BY praa_CompanyID, praad_SubjectCompanyID";

        private void CreateLumberARFile(SqlConnection oConn, string targetFolder, string strFileName, DateTime dtLastRunDate)
        {
            //GET DATA
            SqlCommand oSQLCommand = new SqlCommand(LumberAgingDataSQL, oConn);

            oSQLCommand.Parameters.AddWithValue("@LastRunDate", dtLastRunDate);

            //CREATE REPORT / WRITE FILE
            string strFullFileAndPath = Path.Combine(targetFolder, strFileName);
            File.Delete(strFullFileAndPath); //delete file if it already exists

            using (TextWriter csv = File.CreateText(strFullFileAndPath))
            {
                using (SqlDataReader reader = oSQLCommand.ExecuteReader())
                {
                    csv.WriteLine("SubmitterID, SubjectID, ARDate, AmountCurrent, Amount1to30, Amount31to60, Amount61to90, Amount91Plus");

                    while (reader.Read())
                    {
                        csv.Write(reader["SubmitterID"] + ",");
                        csv.Write(reader["SubjectID"] + ",");
                        csv.Write(FormatDate(reader.GetDateTime(2)) + ",");
                        csv.Write(reader["AmountCurrent"] + ",");
                        csv.Write(reader["Amount1to30"] + ",");
                        csv.Write(reader["Amount31to60"] + ",");
                        csv.Write(reader["Amount61to90"] + ",");
                        csv.WriteLine(reader["Amount91Plus"]);
                    }
                }
            }
        }

        protected const string LUMBER_RATING_SQL =
                    @"SELECT comp_CompanyID as BBID,
						Company.comp_Name as [Company Name],
						CityStateCountryShort as [Listing Location],
						prra_RatingLine as [Rating Line],
						ISNULL(prcpi_PayIndicator, '') as [Pay Indicator],
						FirstAssignedDate as [First Assigned Date]
					FROM Company WITH (NOLOCK)
						INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
						INNER JOIN (SELECT prra_CompanyID, MIN(prra_Date) as FirstAssignedDate --, prra_RatingID, prra_CreatedDate, prra_AssignedRatingNumerals
									FROM vPRCompanyRating
									WHERE prra_Date >= @LastRunDate
										AND (prra_AssignedRatingNumerals LIKE '%(18)%'
										OR prra_AssignedRatingNumerals LIKE '%(113)%'
										OR prra_AssignedRatingNumerals LIKE '%(114)%')
									GROUP BY prra_CompanyID) T1 ON comp_CompanyID = T1.prra_CompanyID
						LEFT OUTER JOIN vPRCompanyRating ON Comp_CompanyID = vPRCompanyRating.prra_CompanyId AND prra_Current = 'Y'
						LEFT OUTER JOIN PRCompanyPayIndicator WITH (NOLOCK) ON Comp_CompanyID = prcpi_CompanyID AND prcpi_Current = 'Y'
					WHERE comp_PRIndustryType = 'L'
						AND comp_CompanyID NOT IN (
							SELECT prra_CompanyID FROM (
									SELECT prra_CompanyID, prra_RatingID, prra_CreatedDate, prra_AssignedRatingNumerals, ROW_NUMBER() OVER (PARTITION BY prra_CompanyID ORDER BY prra_CreatedDate DESC) as RowNum
									FROM vPRCompanyRating
									WHERE prra_Date < @LastRunDate) T1
							WHERE RowNum = 1
									AND (prra_AssignedRatingNumerals LIKE '%(18)%'
									OR prra_AssignedRatingNumerals LIKE '%(113)%'
									OR prra_AssignedRatingNumerals LIKE '%(114)%'))
					ORDER BY Company.comp_Name";

        private void CreateLumberRatingFile(SqlConnection oConn, string targetFolder, string strFileName, DateTime dtLastRunDate)
        {
            //GET DATA
            SqlCommand oSQLCommand = new SqlCommand(LUMBER_RATING_SQL, oConn);
            oSQLCommand.Parameters.AddWithValue("@LastRunDate", dtLastRunDate);
            oSQLCommand.CommandTimeout = Utilities.GetIntConfigValue("BBScoreExportCombinedCommandTimeout", 120);

            //CREATE REPORT / WRITE FILE
            string strFullFileAndPath = Path.Combine(targetFolder, strFileName);
            File.Delete(strFullFileAndPath); //delete file if it already exists

            using (TextWriter csv = File.CreateText(strFullFileAndPath))
            {
                using (SqlDataReader reader = oSQLCommand.ExecuteReader())
                {
                    csv.WriteLine("BBID" + DELIMITER + "Company Name" + DELIMITER + "Listing Location" + DELIMITER + "Rating Line" + DELIMITER + "Pay Indicator" + DELIMITER + "First Assigned Date");

                    while (reader.Read())
                    {
                        csv.Write(reader["BBID"] + DELIMITER);
                        csv.Write(reader["Company Name"] + DELIMITER);
                        csv.Write(reader["Listing Location"] + DELIMITER);
                        csv.Write(reader["Rating Line"] + DELIMITER);
                        csv.Write(reader["Pay Indicator"] + DELIMITER);
                        csv.WriteLine(FormatDate(reader.GetDateTime(5)) + DELIMITER);
                    }
                }
            }
        }

        protected const string LUMBER_PAY_INDICATOR_SQL =
            @"SELECT prcpi_CompanyID,
                       prcpi_CreatedDate,
	                   prcpi_PayIndicatorScore, 
	                   prcpi_PayIndicator
                  FROM PRCompanyPayIndicator WITH (NOLOCK)
                 WHERE prcpi_CreatedDate > @LastRunDate
                ORDER BY prcpi_CompanyID, prcpi_CreatedDate";


        private void CreateLumberPayIndicatorFile(SqlConnection oConn, string targetFolder, string strFileName, DateTime dtLastRunDate)
        {
            //GET DATA
            SqlCommand oSQLCommand = new SqlCommand(LUMBER_PAY_INDICATOR_SQL, oConn);
            oSQLCommand.Parameters.AddWithValue("@LastRunDate", dtLastRunDate);
            oSQLCommand.CommandTimeout = Utilities.GetIntConfigValue("BBScoreExportCombinedCommandTimeout", 120);

            //CREATE REPORT / WRITE FILE
            string strFullFileAndPath = Path.Combine(targetFolder, strFileName);
            File.Delete(strFullFileAndPath); //delete file if it already exists

            using (TextWriter csv = File.CreateText(strFullFileAndPath))
            {
                using (SqlDataReader reader = oSQLCommand.ExecuteReader())
                {
                    csv.WriteLine("CompanyID,Date,PayIndicatorScorez,PayIndicator");

                    while (reader.Read())
                    {
                        csv.Write(reader["prcpi_CompanyID"] + ",");
                        csv.Write(FormatDate(reader.GetDateTime(1)) + ",");
                        csv.Write(reader["prcpi_PayIndicatorScore"] + ",");
                        csv.WriteLine(reader["prcpi_PayIndicator"]);
                    }
                }
            }
        }


        protected const string LUMBER_RATING_NUMERAL_CHANGED_SQL =
            @"SELECT a.prra_CompanyID, prra_RatingLine, prra_CreatedDate 
               FROM vPRCompanyRating a
                    INNER JOIN Company WITH (NOLOCK) ON a.prra_CompanyID = comp_CompanyID
                    LEFT OUTER JOIN (SELECT * FROM (
	                                     SELECT prra_CompanyID, prra_AssignedRatingNumerals, ROW_NUMBER() OVER (PARTITION By prra_CompanyID ORDER BY prra_CreatedDate DESC) as RowNum
	                                       FROM vPRCompanyRating
	                                      WHERE prra_CreatedDate < @LastRunDate) T1
			                          WHERE RowNum = 1) T2 ON a.prra_CompanyId = T2.prra_CompanyId
              WHERE a.prra_CreatedDate > @LastRunDate
                AND a.prra_Current = 'Y'
                AND comp_PRIndustryType = 'L'
	            AND ISNULL(a.prra_AssignedRatingNumerals, '') <> ISNULL(T2.prra_AssignedRatingNumerals, '')";

        private void CreateLumberRatingNumeralChangedFile(SqlConnection oConn, string targetFolder, string strFileName, DateTime dtLastRunDate)
        {
            //GET DATA
            SqlCommand oSQLCommand = new SqlCommand(LUMBER_RATING_NUMERAL_CHANGED_SQL, oConn);
            oSQLCommand.Parameters.AddWithValue("@LastRunDate", dtLastRunDate);
            oSQLCommand.CommandTimeout = Utilities.GetIntConfigValue("BBScoreExportCombinedCommandTimeout", 120);

            //CREATE REPORT / WRITE FILE
            string strFullFileAndPath = Path.Combine(targetFolder, strFileName);
            File.Delete(strFullFileAndPath); //delete file if it already exists

            using (TextWriter csv = File.CreateText(strFullFileAndPath))
            {
                using (SqlDataReader reader = oSQLCommand.ExecuteReader())
                {
                    csv.WriteLine("BBID,RatingLine,FirstAssignedDate");

                    while (reader.Read())
                    {
                        csv.Write(reader["prra_CompanyID"] + ",");
                        csv.Write(reader["prra_RatingLine"] + ",");
                        csv.WriteLine(FormatDate(reader.GetDateTime(2)));
                    }
                }
            }
        }


        private string FormatDate(DateTime dateValue)
        {
            return dateValue.ToString("yyyy-MM-dd");
        }

        #endregion  

        #region Produce
        private void ProcessProduceEvent()
        {
            SqlConnection oConn = new SqlConnection(GetConnectionString());
            const string CUSTOM_CAPTION = "prproduce_LastRunDate";

            //Files from ODG_Export.dtsx file
            const string FILE_NAME_PRODUCE_ODG_AGING = "ODGAging.csv"; 
            const string FILE_NAME_PRODUCE_ODG_COMPANY = "ODGCompany.csv"; 
            const string FILE_NAME_PRODUCE_ODG_FINANCE = "ODGFinance.csv"; 
            const string FILE_NAME_PRODUCE_ODG_NUMERALS = "ODGNumerals.csv"; 
            const string FILE_NAME_PRODUCE_ODG_TRADE = "ODGTrade.csv"; 

            string FILE_NAME_ZIP = Utilities.GetConfigValue("BBScoreExportCombinedProduceFTPFileName", "ProduceBB.zip");

            try
            {
                string targetFolder = Utilities.GetConfigValue("BBScoreExportCombinedFolder");
                
                oConn.Open();

                DateTime dtLastRunDate = GetDateTimeCustomCaption(oConn, CUSTOM_CAPTION); //to create stub NULL prproduce_LastRunDate, run this script: 	INSERT INTO Custom_Captions (Capt_CaptionId, Capt_FamilyType, Capt_Family, Capt_Code, Capt_US, Capt_UK, Capt_FR, Capt_DE, Capt_ES, Capt_Order, Capt_System, Capt_CreatedBy, Capt_CreatedDate, Capt_UpdatedBy, Capt_UpdatedDate, Capt_TimeStamp, Capt_Deleted, Capt_Context, Capt_DU, Capt_JP, Capt_Component, capt_deviceid, capt_integrationid, capt_CS) values (((select max(capt_captionid) from Custom_Captions) + 1),'Choices', 'prproduce_LastRunDate', NULL, 'Produce BB Last Run Date/Time', 'Produce BB Last Run Date/Time', 'Produce BB Last Run Date/Time', 'Produce BB Last Run Date/Time', 'Produce BB Last Run Date/Time', 0, NULL, -1, GETDATE(), -1000, GETDATE(), GETDATE(), NULL, NULL, NULL, NULL, 'PRDropdownValues', NULL, NULL, NULL)

                _oLogger.LogMessage("ProcessProduceEvent() started");
                _oLogger.LogMessage("Produce dtLastRunDate=" + dtLastRunDate.ToString());

                //Create CSV files
                CreateProduceODGAgingFile(oConn, targetFolder, FILE_NAME_PRODUCE_ODG_AGING);
                CreateProduceODGCompanyFile(oConn, targetFolder, FILE_NAME_PRODUCE_ODG_COMPANY);
                CreateProduceODGFinanceFile(oConn, targetFolder, FILE_NAME_PRODUCE_ODG_FINANCE);
                CreateProduceODGNumeralsFile(oConn, targetFolder, FILE_NAME_PRODUCE_ODG_NUMERALS);
                CreateProduceODGTradeFile(oConn, targetFolder, FILE_NAME_PRODUCE_ODG_TRADE);
                //CreateProduceODGCompanyDetailViewsFile(oConn, targetFolder, FILE_NAME_PRODUCE_ODG_COMPANY_DETAIL_VIEWS);
                //CreateProduceODGBusinessReportViewsFile(oConn, targetFolder, FILE_NAME_PRODUCE_ODG_BUSINESS_REPORT_VIEWS);
                //CreateProduceODGClaimActivityFile(oConn, targetFolder, FILE_NAME_PRODUCE_ODG_CLAIM_ACTIVITY);


                string ftpFileName = CompressFiles(targetFolder, FILE_NAME_ZIP, 
                                                    FILE_NAME_PRODUCE_ODG_AGING, 
                                                    FILE_NAME_PRODUCE_ODG_COMPANY, 
                                                    FILE_NAME_PRODUCE_ODG_FINANCE,
                                                    FILE_NAME_PRODUCE_ODG_NUMERALS,
                                                    FILE_NAME_PRODUCE_ODG_TRADE);

                _oLogger.LogMessage(String.Format("zip file {0} created", ftpFileName));
                string msg = string.Empty;

                if (Utilities.GetBoolConfigValue("BBScoreExportCombinedProcessFTP", true))
                {
                    //FTP zip file
                    string ftpURL = Utilities.GetConfigValue("BBScoreExportCombinedFTPServer", "ftp://ftp.bluebookservices.com");

                    UploadFileSFTP(ftpURL,
                                   Utilities.GetIntConfigValue("BBScoreExportCombinedFTPPort", 9210),
                                   Utilities.GetConfigValue("BBScoreExportCombinedFTPUsername", "qa"),
                                   Utilities.GetConfigValue("BBScoreExportCombinedFTPPassword", "fTp~1901"),
                                   ftpFileName,
                                   Utilities.GetConfigValue("BBScoreExportCombinedFTPFolder", "data") + "/" + Path.GetFileName(ftpFileName));

                    msg = String.Format("Zip file {0} sent via FTP to {1}", ftpFileName, ftpURL);
                    _oLogger.LogMessage(msg);
                }

                //FINALIZE
                UpdateDateTimeCustomCaption(oConn, CUSTOM_CAPTION, DateTime.Now);

                if (Utilities.GetBoolConfigValue("BBScoreExportCombinedWriteResultsToEventLog", true))
                {
                    _oBBSMonitorService.LogEvent("Produce BBScore ODG data successfully generated. " + msg);
                }

                if (Utilities.GetBoolConfigValue("BBScoreExportCombinedSendResultsToSupport", true))
                {
                    SendMail("Produce BBScore ODG Success", "Produce BBScore ODG data successfully generated. " + msg);
                }
            }
            catch (Exception e)
            {
                LogEventError("Error Procesing BBScoreExportCombined.ProcessProduceEvent.", e);
            }
            finally
            {
                if (oConn != null)
                    oConn.Close();

                oConn = null;
            }
        }

        //AR Aging Source
        protected const string ODGSQL_AGING =
            @"SELECT *
                FROM vPRModelOpARAging
               WHERE praa_CreatedDate BETWEEN @TargetStartDate AND @TargetEndDate"; 

        private static void CreateProduceODGAgingFile(SqlConnection oConn, string targetFolder, string strFileName)
        {
            //GET DATA
            SqlCommand oSQLCommand = new SqlCommand(ODGSQL_AGING, oConn);
            oSQLCommand.CommandTimeout = Utilities.GetIntConfigValue("BBScoreExportCombinedCommandTimeout", 240);

            DateTime dtTargetEndDate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
            DateTime dtTargetStartDate = dtTargetEndDate.AddMonths(-Utilities.GetIntConfigValue("BBScoreExportCombined_ODGAging_MonthsOld", 36));

            oSQLCommand.Parameters.AddWithValue("@TargetEndDate", dtTargetEndDate);
            oSQLCommand.Parameters.AddWithValue("@TargetStartDate", dtTargetStartDate);

            //CREATE REPORT / WRITE FILE
            string strFullFileAndPath = Path.Combine(targetFolder, strFileName);
            File.Delete(strFullFileAndPath); //delete file if it already exists

            using (TextWriter csv = File.CreateText(strFullFileAndPath))
            {
                using (SqlDataReader reader = oSQLCommand.ExecuteReader())
                {
                    csv.WriteLine("KeyField, ProvBBID, AgingDate, AMT_0_29, AMT_30_44, AMT_45_60, AMT_61_PLUS, CUSTBBID, Credit_Terms, AVG_DAYS_OUTSTANDING");

                    while (reader.Read())
                    {
                        csv.Write(reader["KeyField"] + ",");
                        csv.Write(reader["ProvBBID"] + ",");
                        csv.Write(CustomDate3(reader["AgingDate"]) + ","); // Ex: 05/03/2016
                        csv.Write(reader["AMT_0_29"] + ",");
                        csv.Write(reader["AMT_30_44"] + ",");
                        csv.Write(reader["AMT_45_60"] + ",");
                        csv.Write(reader["AMT_61_PLUS"] + ",");
                        csv.Write(reader["CUSTBBID"] + ",");
                        csv.Write(reader["Credit_Terms"] + ",");
                        csv.WriteLine(reader["AVG_DAYS_OUTSTANDING"]);
                    }
                }
            }
        }

        //Company Source
        protected const string ODGSQL_COMPANY =
            @"With Results (SubjectId, ResponderId, Tier) As
            (
	            Select Distinct prcr_RightCompanyID, prcr_LeftCompanyId, 1  
	              From PRCompanyRelationship
	             Where prcr_LastReportedDate > DateAdd(Month, -24, getDate()) 
	               And prcr_Type IN ('01', '02', '04', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22')
	            Union All
	            Select Distinct prcr_LeftCompanyID, prcr_RightCompanyId, 1  
	              From PRCompanyRelationship
	             Where prcr_LastReportedDate > DateAdd(Month, -24, getDate()) 
	               And prcr_Type IN ('01', '02', '04', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22') 
	            Union All
	            Select Distinct prcr_RightCompanyID, prcr_LeftCompanyId, 2  
	             From  PRCompanyRelationship
	             Where 
		            prcr_LastReportedDate > DateAdd(Month, -60, getDate()) 
	               And prcr_Type IN ('01', '02', '04', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22') 
	            Union All
	            Select Distinct prcr_LeftCompanyID, prcr_RightCompanyId, 2  
	             From  PRCompanyRelationship
	             Where
	               prcr_LastReportedDate > DateAdd(Month, -60, getDate()) 
	               And prcr_Type IN ('01', '02', '04', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22') 
	            Union All
	            Select Distinct prcr_RightCompanyId, prcr_LeftCompanyId, 3  
	              From PRCompanyRelationship
	             Where
		            prcr_LastReportedDate < DateAdd(Month, -60, getDate()) 
	               And prcr_Type IN ('01', '02', '04', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22')
	            Union All
	            Select Distinct prcr_RightCompanyID, prcr_LeftCompanyId, 3  
	              From PRCompanyRelationship
	             Where 
	            prcr_LastReportedDate > DateAdd(Month, -36, getDate())
	               And prcr_Type IN ('23', '24', '25', '26')
	            Union All
	            Select Distinct prcr_LeftCompanyID,prcr_RightCompanyId, 3  
	              From PRCompanyRelationship
	             Where prcr_LastReportedDate < DateAdd(Month, -60, getDate()) 
	               And prcr_Type IN ('1', '2', '4', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22')
	            Union All
	            Select Distinct prcr_LeftCompanyID, prcr_RightCompanyId, 3  
	              From PRCompanyRelationship
	             Where prcr_LastReportedDate > DateAdd(Month, -36, getDate())
	               And prcr_Type IN ('23', '24', '25', '26')
            ),
            RelCount(SubjectID, Tier, TotalCnt) As
            (
                Select SubjectID, Tier, Count(ResponderID) As TotalCnt
                From (
	                    (Select SubjectID, ResponderID, Min(Tier) As Tier
	                       From Results
	                   Group By SubjectID, ResponderID)
                     )TableA
                Group by SubjectID, Tier
            ),
            OwnerShipByCompany (prcr_CompanyRelationshipId, prcr_LeftCompanyId, prcr_RightCompanyId) As
            (
                Select
                    prcr_CompanyRelationshipId
                    , prcr_LeftCompanyId
                    , prcr_RightCompanyId
                From
                    PRCompanyRelationship
                    INNER JOIN company on comp_companyid = prcr_leftcompanyid
                    INNER JOIN vPRLocation on comp_prlistingcityid = prci_cityid
                Where
                    prcr_Deleted is null
                    And (prcr_Type = '27' or prcr_Type = '28')
            )
            Select Distinct
	            c.comp_CompanyId As BBID,
	            c.comp_PRBookTradestyle As TRADESTYLE,
	            l.prci_City As CITY, 
	            l.prst_State As [STATE], 
	            l.prcn_Country As COUNTRY, 
	            c.comp_PRType As HQBR, 
	            Coalesce(c.comp_PRHQId,'') As HQBBID,
	            Coalesce(cr.prcw_Name,'') As WORTH_RATING, 
	            Coalesce(cr.prin_Name,'') As IA_RATING, 
	            Coalesce(cr.prpy_Name,'') As PAY_RATING,
	            Coalesce(cr.prra_AssignedRatingNumerals,'') As RATING_NUMERALS, 
	            c.comp_PRListingStatus As [STATUS], 
	            Coalesce(Convert(nvarchar(30), dbo.ufn_GetBusinessEventDate(c.comp_CompanyID, 9, 0, 0, NULL),101),'') As DATE_BUSINESS_STARTED,
	            Coalesce(Convert(nvarchar(30), dbo.ufn_GetDateOfCurrentOwnership(c.comp_CompanyID), 101),'') As DATE_OF_CURRENT_OWNERSHIP,
	            Convert(nvarchar(30), GETDATE(), 101) As ExportDate,
	            Coalesce(c.comp_PRAdministrativeUsage,'') As  ADMIN_USAGE,
	            Coalesce(c.comp_PRInvestigationMethodGroup,'') As INV_GROUP,
	            Tier1Cnt = Coalesce(Tier1.TotalCnt,''),
	            Tier2Cnt = Coalesce(Tier2.TotalCnt,''),
	            Tier3Cnt = Coalesce(Tier3.TotalCnt,''),
	            Case 
		            When p.peli_PersonID is not null And oc.prcr_LeftCompanyID is not null Then 'M'
		            When oc.prcr_LeftCompanyID is not null Then 'C'
		            When p.peli_PersonID is not null Then 'I'
		            Else 'U'
                End As OWN_TYPE,
	            c.comp_PRIndustryType As IND_TYPE
            From
                Company c
                INNER JOIN vPRLocation l ON prci_CityId = c.comp_PRListingCityId
                LEFT OUTER JOIN vPRCompanyRating cr ON cr.prra_CompanyId = c.comp_CompanyId And cr.prra_Current = 'Y'
	            LEFT OUTER JOIN OwnershipByCompany oc on oc.prcr_RightCompanyID = c.Comp_CompanyID
	            LEFT OUTER JOIN Person_Link p on p.peli_CompanyID = c.comp_CompanyID
		            And p.peli_PRStatus != 3
		            And p.peli_PROwnershipRole Not In ('RCR','RCN','RCU')
	            Left Outer JOin RelCount Tier1 on Tier1.SubjectID = c.Comp_CompanyID And Tier1.tier = 1
	            Left Outer JOin RelCount Tier2 on Tier2.SubjectID = c.Comp_CompanyID And Tier2.tier = 2
	            Left Outer JOin RelCount Tier3 on Tier3.SubjectID = c.Comp_CompanyID And Tier3.tier = 3
            WHERE comp_PRLocalSource IS NULL
              AND comp_PRIndustryType IN ('P', 'T')	
            Order By
                c.comp_CompanyId";
        private static void CreateProduceODGCompanyFile(SqlConnection oConn, string targetFolder, string strFileName)
        {
            //GET DATA
            SqlCommand oSQLCommand = new SqlCommand(ODGSQL_COMPANY, oConn);
            oSQLCommand.CommandTimeout = Utilities.GetIntConfigValue("BBScoreExportCombinedCommandTimeout", 360); //allow more than the default 30 seconds since this SQL can take a bit to run

            //CREATE REPORT / WRITE FILE
            string strFullFileAndPath = Path.Combine(targetFolder, strFileName);
            File.Delete(strFullFileAndPath); //delete file if it already exists

            using (TextWriter csv = File.CreateText(strFullFileAndPath))
            {
                using (SqlDataReader reader = oSQLCommand.ExecuteReader())
                {
                    csv.WriteLine("\"BBID\", \"TRADESTYLE\", \"CITY\", \"STATE\", \"COUNTRY\", \"HQBR\", \"HQBBID\", \"WORTH_RATING\", \"IA_RATING\", \"PAY_RATING\", \"RATING_NUMERALS\", \"STATUS\", \"DATE_BUSINESS_STARTED\", \"DATE_OF_CURRENT_OWNERSHIP\", \"ExportDate\", \"ADMIN_USAGE\", \"INV_GROUP\", \"Tier1Cnt\", \"Tier2Cnt\", \"Tier3Cnt\", \"OWN_TYPE\", \"IND_TYPE\"");

                    while (reader.Read())
                    {
                        csv.Write(Quotes(reader["BBID"]) + ",");
                        csv.Write(Quotes(reader["TRADESTYLE"].ToString().Replace("\"", "\"\"")) + ","); //fix issue when both " and , in company name - ex: BBID 394689 has a name of Dub-L “S” Transfer, Inc.
                        csv.Write(Quotes(reader["CITY"]) + ",");
                        csv.Write(Quotes(reader["STATE"]) + ",");
                        csv.Write(Quotes(reader["COUNTRY"]) + ",");
                        csv.Write(Quotes(reader["HQBR"]) + ",");
                        csv.Write(Quotes(reader["HQBBID"]) + ",");
                        csv.Write(Quotes(reader["WORTH_RATING"]) + ",");
                        csv.Write(Quotes(reader["IA_RATING"]) + ",");
                        csv.Write(Quotes(reader["PAY_RATING"]) + ",");
                        csv.Write(Quotes(reader["RATING_NUMERALS"]) + ",");
                        csv.Write(Quotes(reader["STATUS"]) + ",");
                        csv.Write(Quotes(CustomDate3(reader["DATE_BUSINESS_STARTED"])) + ","); // Ex: 04/01/1971
                        csv.Write(Quotes(CustomDate3(reader["DATE_OF_CURRENT_OWNERSHIP"])) + ","); // Ex: 04/01/1971
                        csv.Write(Quotes(CustomDate3(reader["ExportDate"])) + ","); // Ex: 06/01/2018
                        csv.Write(Quotes(reader["ADMIN_USAGE"]) + ",");
                        csv.Write(Quotes(reader["INV_GROUP"]) + ",");
                        csv.Write(Quotes(reader["Tier1Cnt"]) + ",");
                        csv.Write(Quotes(reader["Tier2Cnt"]) + ",");
                        csv.Write(Quotes(reader["Tier3Cnt"]) + ",");
                        csv.Write(Quotes(reader["OWN_TYPE"]) + ",");
                        csv.WriteLine(Quotes(reader["IND_TYPE"]));
                    }
                }
            }
        }

        //Finance Source
        protected const string ODGSQL_FINANCE =
            @"SELECT	prfs_CompanyId AS BBID,
	                Cast(Convert(nvarchar(30),prfs_StatementDate, 101) As DateTime) AS STATEMENTDATE,
	                prfs_Currency AS CURRENCY, 
	                prfs_Type AS TYPE, 
	                prfs_InterimMonth AS INTERIMMONTH, 
	                prfs_PreparationMethod AS PREPARATIONMETHOD,
	                prfs_CashEquivalents AS CASHEQUIVALENTS, 
	                prfs_ARTrade AS ARTRADE, 
	                prfs_GrowerAdvances AS GROWERADVANCES,
	                prfs_DueFromRelatedParties AS DUEFROMRELATEDPARTIES,
	                prfs_LoansNotesReceivable AS LOANSNOTESRECEIVABLE,
	                prfs_MarketableSecurities AS MARKETABLESECURITIES,
	                prfs_Inventory AS INVENTORY,
	                prfs_OtherCurrentAssets AS OTHERCURRENTASSETS,
	                prfs_TotalCurrentAssets AS TOTALCURRENTASSETS,
	                prfs_AccountsPayable AS ACCOUNTSPAYABLE,
	                prfs_CurrentMaturity AS CURRENTMATURITY,
 	                prfs_CreditLine AS CREDITLINE,
 	                prfs_CurrentLoanPayableShldr AS CURRENTLOANPAYABLESHLDR,
 	                prfs_OtherCurrentLiabilities AS OTHERCURRENTLIABILITIES,
 	                prfs_TotalCurrentLiabilities AS TOTALCURRENTLIABILITIES,
	                prfs_Property AS PROPERTY, 
	                prfs_LeaseholdImprovements AS LEASEHOLDIMPROVEMENTS, 
	                prfs_OtherFixedAssets AS OTHERFIXEDASSETS, 
	                prfs_AccumulatedDepreciation AS ACCUMULATEDDEPRECIATION, 
	                prfs_NetFixedAssets AS NETFIXEDASSETS,
	                prfs_LongTermDebt AS LONGTERMDEBT, 
	                prfs_LoansNotesPayableShldr AS LOANSNOTESPAYABLESHLDR, 
	                prfs_OtherLongLiabilities AS OTHERLONGLIABILITIES, 
	                prfs_TotalLongLiabilities AS TOTALLONGLIABILITIES, 
	                prfs_OtherLoansNotesReceivable AS OTHERLOANSNOTESRECEIVABLE,
	                prfs_Goodwill AS GOODWILL, 
	                prfs_OtherMiscAssets AS OTHERMISCASSETS, 
	                prfs_TotalOtherAssets AS TOTALOTHERASSETS, 
	                prfs_OtherEquity AS OTHEREQUITY, 
	                prfs_OtherMiscLiabilities AS OTHERMISCLIABILITIES, 
	                prfs_RetainedEarnings AS RETAINEDEARNINGS,
	                prfs_TotalEquity AS TOTALEQUITY, 
	                prfs_TotalAssets AS TOTALASSETS, 
	                prfs_TotalLiabilities AS TOTALLIABILITIES, 
	                prfs_TotalLiabilityAndEquity AS TOTALLIABILITYANDEQUITY, 
	                prfs_WorkingCapital AS WORKINGCAPITAL,
	                prfs_Sales AS SALES, 
	                prfs_CostGoodsSold AS COSTGOODSSOLD, 
	                prfs_GrossProfitMargin AS GROSSPROFITMARGIN, 
	                prfs_OperatingExpenses AS OPERATINGEXPENSES, 
	                prfs_OperatingIncome AS OPERATINGINCOME, 
	                prfs_InterestIncome AS INTERESTINCOME,
	                prfs_OtherIncome AS OTHERINCOME, 
	                prfs_ExtraordinaryGainLoss AS EXTRAORDINARYGAINLOSS, 
	                prfs_InterestExpense AS INTERESTEXPENSE, 
	                prfs_OtherExpenses AS OTHEREXPENSES, 
	                prfs_TaxProvision AS TAXPROVISION,
	                prfs_NetIncome AS NETINCOME, 
	                prfs_Depreciation AS DEPRECIATION, 
	                prfs_Amortization AS AMORTIZATION, 
	                prfs_NetProfitLoss AS NETPROFITLOSS, 
	                prfs_CurrentRatio AS CURRENTRATIO, 
	                prfs_QuickRatio AS QUICKRATIO, 
	                prfs_ARTurnover AS ARTURNOVER,
	                prfs_DaysPayableOutstanding AS DAYSPAYABLEOUTSTANDING, 
	                prfs_DebtToEquity AS DEBTTOEQUITY, 
	                prfs_FixedAssetsToNetWorth AS FIXEDASSETSTONETWORTH, 
	                prfs_DebtServiceAbility AS DEBTSERVICEABILITY, 
	                prfs_OperatingRatio AS OPERATINGRATIO, 
	                prfs_ZScore AS ZSCORE
                FROM PRFinancial 
                INNER JOIN Company s with (nolock) ON prfs_CompanyID = s.comp_CompanyID
                WHERE prfs_CreatedDate BETWEEN @TargetStartDate AND @TargetEndDate
                    AND s.comp_PRLocalSource IS NULL
                    AND s.comp_PRIndustryType IN ('P', 'T');";

        private static void CreateProduceODGFinanceFile(SqlConnection oConn, string targetFolder, string strFileName)
        {
            //GET DATA
            SqlCommand oSQLCommand = new SqlCommand(ODGSQL_FINANCE, oConn);
            oSQLCommand.CommandTimeout = Utilities.GetIntConfigValue("BBScoreExportCombinedCommandTimeout", 240);

            //Replace ? that were in origianl ODG_Export.dtsx
            DateTime dtTargetEndDate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
            DateTime dtTargetStartDate = dtTargetEndDate.AddMonths(-Utilities.GetIntConfigValue("BBScoreExportCombined_ODGFinance_MonthsOld", 360));

            oSQLCommand.Parameters.AddWithValue("@TargetEndDate", dtTargetEndDate);
            oSQLCommand.Parameters.AddWithValue("@TargetStartDate", dtTargetStartDate);

            //CREATE REPORT / WRITE FILE
            string strFullFileAndPath = Path.Combine(targetFolder, strFileName);
            File.Delete(strFullFileAndPath); //delete file if it already exists

            using (TextWriter csv = File.CreateText(strFullFileAndPath))
            {
                using (SqlDataReader reader = oSQLCommand.ExecuteReader())
                {
                    csv.WriteLine("BBID, STATEMENTDATE, CURRENCY, TYPE, INTERIMMONTH, PREPARATIONMETHOD, CASHEQUIVALENTS, ARTRADE, GROWERADVANCES, DUEFROMRELATEDPARTIES, LOANSNOTESRECEIVABLE, MARKETABLESECURITIES, INVENTORY, OTHERCURRENTASSETS, TOTALCURRENTASSETS, ACCOUNTSPAYABLE, CURRENTMATURITY, CREDITLINE, CURRENTLOANPAYABLESHLDR, OTHERCURRENTLIABILITIES, TOTALCURRENTLIABILITIES, PROPERTY, LEASEHOLDIMPROVEMENTS, OTHERFIXEDASSETS, ACCUMULATEDDEPRECIATION, NETFIXEDASSETS, LONGTERMDEBT, LOANSNOTESPAYABLESHLDR, OTHERLONGLIABILITIES, TOTALLONGLIABILITIES, OTHERLOANSNOTESRECEIVABLE, GOODWILL, OTHERMISCASSETS, TOTALOTHERASSETS, OTHEREQUITY, OTHERMISCLIABILITIES, RETAINEDEARNINGS, TOTALEQUITY, TOTALASSETS, TOTALLIABILITIES, TOTALLIABILITYANDEQUITY, WORKINGCAPITAL, SALES, COSTGOODSSOLD, GROSSPROFITMARGIN, OPERATINGEXPENSES, OPERATINGINCOME, INTERESTINCOME, OTHERINCOME, EXTRAORDINARYGAINLOSS, INTERESTEXPENSE, OTHEREXPENSES, TAXPROVISION, NETINCOME, DEPRECIATION, AMORTIZATION, NETPROFITLOSS, CURRENTRATIO, QUICKRATIO, ARTURNOVER, DAYSPAYABLEOUTSTANDING, DEBTTOEQUITY, FIXEDASSETSTONETWORTH, DEBTSERVICEABILITY, OPERATINGRATIO, ZSCORE");

                    while (reader.Read())
                    {
                        csv.Write(reader["BBID"] + ",");
                        csv.Write(CustomDate1(reader["STATEMENTDATE"])+ ","); // Ex: 1995-12-31 00:00:00.000
                        csv.Write(reader["CURRENCY"] + ",");
                        csv.Write(reader["TYPE"] + ",");
                        csv.Write(reader["INTERIMMONTH"] + ",");
                        csv.Write(reader["PREPARATIONMETHOD"] + ",");
                        csv.Write(reader["CASHEQUIVALENTS"] + ",");
                        csv.Write(reader["ARTRADE"] + ",");
                        csv.Write(reader["GROWERADVANCES"] + ",");
                        csv.Write(reader["DUEFROMRELATEDPARTIES"] + ",");
                        csv.Write(reader["LOANSNOTESRECEIVABLE"] + ",");
                        csv.Write(reader["MARKETABLESECURITIES"] + ",");
                        csv.Write(reader["INVENTORY"] + ",");
                        csv.Write(reader["OTHERCURRENTASSETS"] + ",");
                        csv.Write(reader["TOTALCURRENTASSETS"] + ",");
                        csv.Write(reader["ACCOUNTSPAYABLE"] + ",");
                        csv.Write(reader["CURRENTMATURITY"] + ",");
                        csv.Write(reader["CREDITLINE"] + ",");
                        csv.Write(reader["CURRENTLOANPAYABLESHLDR"] + ",");
                        csv.Write(reader["OTHERCURRENTLIABILITIES"] + ",");
                        csv.Write(reader["TOTALCURRENTLIABILITIES"] + ",");
                        csv.Write(reader["PROPERTY"] + ",");
                        csv.Write(reader["LEASEHOLDIMPROVEMENTS"] + ",");
                        csv.Write(reader["OTHERFIXEDASSETS"] + ",");
                        csv.Write(reader["ACCUMULATEDDEPRECIATION"] + ",");
                        csv.Write(reader["NETFIXEDASSETS"] + ",");
                        csv.Write(reader["LONGTERMDEBT"] + ",");
                        csv.Write(reader["LOANSNOTESPAYABLESHLDR"] + ",");
                        csv.Write(reader["OTHERLONGLIABILITIES"] + ",");
                        csv.Write(reader["TOTALLONGLIABILITIES"] + ",");
                        csv.Write(reader["OTHERLOANSNOTESRECEIVABLE"] + ",");
                        csv.Write(reader["GOODWILL"] + ",");
                        csv.Write(reader["OTHERMISCASSETS"] + ",");
                        csv.Write(reader["TOTALOTHERASSETS"] + ",");
                        csv.Write(reader["OTHEREQUITY"] + ",");
                        csv.Write(reader["OTHERMISCLIABILITIES"] + ",");
                        csv.Write(reader["RETAINEDEARNINGS"] + ",");
                        csv.Write(reader["TOTALEQUITY"] + ",");
                        csv.Write(reader["TOTALASSETS"] + ",");
                        csv.Write(reader["TOTALLIABILITIES"] + ",");
                        csv.Write(reader["TOTALLIABILITYANDEQUITY"] + ",");
                        csv.Write(reader["WORKINGCAPITAL"] + ",");
                        csv.Write(reader["SALES"] + ",");
                        csv.Write(reader["COSTGOODSSOLD"] + ",");
                        csv.Write(reader["GROSSPROFITMARGIN"] + ",");
                        csv.Write(reader["OPERATINGEXPENSES"] + ",");
                        csv.Write(reader["OPERATINGINCOME"] + ",");
                        csv.Write(reader["INTERESTINCOME"] + ",");
                        csv.Write(reader["OTHERINCOME"] + ",");
                        csv.Write(reader["EXTRAORDINARYGAINLOSS"] + ",");
                        csv.Write(reader["INTERESTEXPENSE"] + ",");
                        csv.Write(reader["OTHEREXPENSES"] + ",");
                        csv.Write(reader["TAXPROVISION"] + ",");
                        csv.Write(reader["NETINCOME"] + ",");
                        csv.Write(reader["DEPRECIATION"] + ",");
                        csv.Write(reader["AMORTIZATION"] + ",");
                        csv.Write(reader["NETPROFITLOSS"] + ",");
                        csv.Write(reader["CURRENTRATIO"] + ",");
                        csv.Write(reader["QUICKRATIO"] + ",");
                        csv.Write(reader["ARTURNOVER"] + ",");
                        csv.Write(reader["DAYSPAYABLEOUTSTANDING"] + ",");
                        csv.Write(reader["DEBTTOEQUITY"] + ",");
                        csv.Write(reader["FIXEDASSETSTONETWORTH"] + ",");
                        csv.Write(reader["DEBTSERVICEABILITY"] + ",");
                        csv.Write(reader["OPERATINGRATIO"] + ",");
                        csv.WriteLine(reader["ZSCORE"]);
                    }
                }
            }
        }

        //Numerals Source
        protected const string ODGSQL_NUMERALS =
            @"SELECT prra_CompanyId AS BBID, 
	            convert(nvarchar(30),prra_Date,101) AS EFFECTIVEDATE, 
	            prrn_Name AS NUMERAL
                FROM    PRRatingNumeralAssigned
	            INNER JOIN PRRating ON pran_RatingId = prra_RatingId
	            INNER JOIN PRRatingNumeral ON prrn_RatingNumeralId = pran_RatingNumeralId
                WHERE prrn_Name IN ('(1)','(2)','(3)','(4)','(5)','(6)','(7)','(8)','(9)','(10)','(13)', '(14)','(15)','(16)','(17)','(18)','(19)','(26)','(49)','(52)','(84)','(108)','(113)','(152)','(153)','(156)','(157)')
                    AND prra_CreatedDate BETWEEN @TargetStartDate AND @TargetEndDate
                ORDER BY prra_Date;";

        private static void CreateProduceODGNumeralsFile(SqlConnection oConn, string targetFolder, string strFileName)
        {
            //GET DATA
            SqlCommand oSQLCommand = new SqlCommand(ODGSQL_NUMERALS, oConn);
            oSQLCommand.CommandTimeout = Utilities.GetIntConfigValue("BBScoreExportCombinedCommandTimeout", 240);

            //Replace ? that were in origianl ODG_Export.dtsx
            DateTime dtTargetEndDate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
            DateTime dtTargetStartDate = dtTargetEndDate.AddMonths(-Utilities.GetIntConfigValue("BBScoreExportCombined_ODGNumerals_MonthsOld", 258));

            oSQLCommand.Parameters.AddWithValue("@TargetStartDate", dtTargetStartDate);
            oSQLCommand.Parameters.AddWithValue("@TargetEndDate", dtTargetEndDate);

            //CREATE REPORT / WRITE FILE
            string strFullFileAndPath = Path.Combine(targetFolder, strFileName);
            File.Delete(strFullFileAndPath); //delete file if it already exists

            using (TextWriter csv = File.CreateText(strFullFileAndPath))
            {
                using (SqlDataReader reader = oSQLCommand.ExecuteReader())
                {
                    csv.WriteLine("BBID, EFFECTIVEDATE, NUMERAL");

                    while (reader.Read())
                    {
                        csv.Write(reader["BBID"] + ",");
                        csv.Write(CustomDate3(reader["EFFECTIVEDATE"]) + ","); // 01/02/1997
                        csv.WriteLine(reader["NUMERAL"]);
                    }
                }
            }
        }

        //Trade Source
        protected const string ODGSQL_TRADE =
            @"SELECT prtr_SubjectId AS SUBJECTBBID,
 	                 prtr_ResponderId AS RESPONDERBBID,
 	                 prtr_Date AS REPORTDATE,
	                 prin_Name AS IA, 
	                 prpy_Name AS PAY, 
	                 prtr_LastDealtDate AS DEALT, 
	                 prtr_CreditTerms AS TERMS, 
	                 prtr_HighCredit AS HIGH, 
	                 prtr_Duplicate AS DUPLICATE
                FROM PRTradeReport with (nolock)
                     INNER JOIN Company s with (nolock) ON prtr_SubjectID = s.comp_CompanyID
                     INNER JOIN Company r with (nolock) ON prtr_ResponderId = r.comp_CompanyID
	                 LEFT OUTER JOIN PRIntegrityRating with (nolock) on prin_IntegrityRatingId = prtr_IntegrityId
	                 LEFT OUTER JOIN PRPayRating with (nolock) on prpy_PayRatingId = prtr_PayRatingId
               WHERE prtr_CreatedDate BETWEEN @TargetStartDate AND @TargetEndDate
                 AND s.comp_PRLocalSource IS NULL
                 AND s.comp_PRIndustryType IN ('P', 'T')
                 AND r.comp_PRIgnoreTES IS NULL
                 AND prtr_ExcludeFromAnalysis IS NULL
            ORDER BY prtr_Date;";

        //                 AND ISNULL(prtr_LastDealtDate, 'x') NOT IN ('C', 'D')

        private static void CreateProduceODGTradeFile(SqlConnection oConn, string targetFolder, string strFileName)
        {
            //GET DATA
            SqlCommand oSQLCommand = new SqlCommand(ODGSQL_TRADE, oConn);
            oSQLCommand.CommandTimeout = Utilities.GetIntConfigValue("BBScoreExportCombinedCommandTimeout", 240);

            //Replace ? that were in origianl ODG_Export.dtsx
            DateTime dtTargetEndDate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
            DateTime dtTargetStartDate = dtTargetEndDate.AddMonths(-Utilities.GetIntConfigValue("BBScoreExportCombined_ODGTrade_MonthsOld", 360));

            oSQLCommand.Parameters.AddWithValue("@TargetEndDate", dtTargetEndDate);
            oSQLCommand.Parameters.AddWithValue("@TargetStartDate", dtTargetStartDate);

            //CREATE REPORT / WRITE FILE
            string strFullFileAndPath = Path.Combine(targetFolder, strFileName);
            File.Delete(strFullFileAndPath); //delete file if it already exists

            using (TextWriter csv = File.CreateText(strFullFileAndPath))
            {
                using (SqlDataReader reader = oSQLCommand.ExecuteReader())
                {
                    csv.WriteLine("SUBJECTBBID, RESPONDERBBID, REPORTDATE, IA, PAY, DEALT, TERMS, HIGH, DUPLICATE");

                    while (reader.Read())
                    {
                        csv.Write(reader["SUBJECTBBID"] + ",");
                        csv.Write(reader["RESPONDERBBID"] + ",");
                        csv.Write(CustomDate2(reader["REPORTDATE"])+ ","); //1997-02-10 00:00:00
                        csv.Write(reader["IA"] + ",");
                        csv.Write(reader["PAY"] + ",");
                        csv.Write(reader["DEALT"] + ",");
                        csv.Write(reader["TERMS"] + ",");
                        csv.Write(reader["HIGH"] + ",");
                        csv.WriteLine(reader["DUPLICATE"]);
                    }
                }
            }
        }

        //BBOS Company Detail Views.sql
        protected const string ODGSQL_COMPANY_DETAIL_VIEWS =
              @"SELECT comp_CompanyID [BBID],
		            Company.comp_Name [Company Name],
		            prst_State [Listing State],
		            prcn_Country [Listing Country],
		            CAST(ls.capt_us as varchar(100)) [Listing Status],
		            prwsat_CreatedDate [Date Viewed],
		            prwsat_CompanyID [Viewer BBID],
		            CASE WHEN prwsat_AssociatedID = prwsat_CompanyID THEN 'Y' ELSE 'N' END as [Subject Viewed]
                FROM CRM.dbo.PRWebAuditTrail WITH (NOLOCK)
                    INNER JOIN CRM.dbo.Company WITH (NOLOCK) ON prwsat_AssociatedID = comp_CompanyID
	                INNER JOIN CRM.dbo.vPRLocation ON comp_PRListingCityID = prci_CityID
	                INNER JOIN CRM.dbo.Custom_Captions ls WITH (NOLOCK) ON comp_PRListingStatus = ls.capt_code AND ls.capt_family = 'comp_PRListingStatus'
                WHERE prwsat_PageName LIKE '%CompanyDetailsSummary.aspx'
                    AND prwsat_CreatedDate BETWEEN @TargetStartDate AND @TargetEndDate
                ORDER BY [BBID], [Date Viewed], [Viewer BBID];";
        private static void CreateProduceODGCompanyDetailViewsFile(SqlConnection oConn, string targetFolder, string strFileName)
        {
            //GET DATA
            SqlCommand oSQLCommand = new SqlCommand(ODGSQL_COMPANY_DETAIL_VIEWS, oConn);
            oSQLCommand.CommandTimeout = Utilities.GetIntConfigValue("BBScoreExportCombinedCommandTimeout", 240);

            //Replace ? that were in original SQL provided
            DateTime dtTargetEndDate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
            DateTime dtTargetStartDate = dtTargetEndDate.AddMonths(-Utilities.GetIntConfigValue("BBScoreExportCombined_ODGCompanyDetailViews_MonthsOld", 1));

            oSQLCommand.Parameters.AddWithValue("@TargetStartDate", dtTargetStartDate);
            oSQLCommand.Parameters.AddWithValue("@TargetEndDate", dtTargetEndDate);

            //CREATE REPORT / WRITE FILE
            string strFullFileAndPath = Path.Combine(targetFolder, strFileName);
            File.Delete(strFullFileAndPath); //delete file if it already exists

            using (TextWriter csv = File.CreateText(strFullFileAndPath))
            {
                using (SqlDataReader reader = oSQLCommand.ExecuteReader())
                {
                    csv.WriteLine("BBID, Company Name, Listing State, Listing Country, Listing Status, Date Viewed, Viewer BBID, Subject Viewed");

                    while (reader.Read())
                    {
                        csv.Write(reader["BBID"] + ",");
                        csv.Write(Quotes(reader["Company Name"]) + ",");
                        csv.Write(reader["Listing State"] + ",");
                        csv.Write(reader["Listing Country"] + ",");
                        csv.Write(reader["Listing Status"] + ",");
                        csv.Write(CustomDate4(reader["Date Viewed"]) + ","); // Ex: 3/6/18
                        csv.Write(reader["Viewer BBID"] + ",");
                        csv.WriteLine(reader["Subject Viewed"]);
                    }
                }
            }
        }

        //Business Report Views.sql
        protected const string ODGSQL_BUSINESS_REPORT_VIEWS =
            @"SELECT comp_CompanyID [BBID],
		            Company.comp_Name [Company Name],
		            prst_State [Listing State],
		            prcn_Country [Listing Country],
		            CAST(ls.capt_us as varchar(100)) [Listing Status],
		            prbr_CreatedDate [Date Viewed],
		            prbr_RequestingCompanyId [Viewer BBID],
		            CAST(ms.capt_us as varchar(100)) [Method Sent],
		            CASE WHEN prbr_RequestedCompanyId = prbr_RequestingCompanyId THEN 'Y' ELSE 'N' END as [Subject Viewed]
                FROM CRM.dbo.PRBusinessReportRequest WITH (NOLOCK)
                    INNER JOIN CRM.dbo.Company WITH (NOLOCK) ON prbr_RequestedCompanyId = comp_CompanyID
	                INNER JOIN CRM.dbo.vPRLocation ON comp_PRListingCityID = prci_CityID
	                INNER JOIN CRM.dbo.Custom_Captions ls ON comp_PRListingStatus = ls.capt_code AND ls.capt_family = 'comp_PRListingStatus'
	                INNER JOIN CRM.dbo.Custom_Captions ms ON prbr_MethodSent = ms.capt_code AND ms.capt_family = 'prbr_MethodSent'
                WHERE prbr_CreatedDate BETWEEN @TargetStartDate AND @TargetEndDate
                ORDER BY comp_CompanyID, prbr_CreatedDate, prbr_RequestingCompanyId";
        private static void CreateProduceODGBusinessReportViewsFile(SqlConnection oConn, string targetFolder, string strFileName)
        {
            //GET DATA
            SqlCommand oSQLCommand = new SqlCommand(ODGSQL_BUSINESS_REPORT_VIEWS, oConn);
            oSQLCommand.CommandTimeout = Utilities.GetIntConfigValue("BBScoreExportCombinedCommandTimeout", 240);

            //Replace ? that were in original SQL provided
            DateTime dtTargetEndDate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
            DateTime dtTargetStartDate = dtTargetEndDate.AddMonths(-Utilities.GetIntConfigValue("BBScoreExportCombined_ODGBusinessReportViews_MonthsOld", 1));

            oSQLCommand.Parameters.AddWithValue("@TargetStartDate", dtTargetStartDate);
            oSQLCommand.Parameters.AddWithValue("@TargetEndDate", dtTargetEndDate);

            //CREATE REPORT / WRITE FILE
            string strFullFileAndPath = Path.Combine(targetFolder, strFileName);
            File.Delete(strFullFileAndPath); //delete file if it already exists

            using (TextWriter csv = File.CreateText(strFullFileAndPath))
            {
                using (SqlDataReader reader = oSQLCommand.ExecuteReader())
                {
                    csv.WriteLine("BBID, Company Name, Listing State, Listing Country, Listing Status, Date Viewed, Viewer BBID, Method Sent, Subject Viewed"); 

                    while (reader.Read())
                    {
                        csv.Write(reader["BBID"] + ",");
                        csv.Write(Quotes(reader["Company Name"]) + ","); //Company Name quoted all the time
                        csv.Write(reader["Listing State"] + ",");
                        csv.Write(reader["Listing Country"] + ",");
                        csv.Write(reader["Listing Status"] + ",");
                        csv.Write(CustomDate4(reader["Date Viewed"]) + ",");
                        csv.Write(reader["Viewer BBID"] + ",");
                        csv.Write(reader["Method Sent"] + ","); 
                        csv.WriteLine(reader["Subject Viewed"]);
                    }
                }
            }
        }

        //Claim Activity Query.sql
        protected const string ODGSQL_CLAIM_ACTIVITY =
            @"SELECT * 
                FROM (
	            SELECT comp_CompanyID [BBID],
		                comp_Name [Company Name],
		                prci_City [Listing City],
		                prst_State [Listing State],
		                prcn_Country [Listing Country],
		                CAST(capt_us as varchar(100)) [Listing Status],
		                prss_OpenedDate [Open Date],
		                'BBSI' [Claim Type],
		                prss_Status [Status],
		                prss_ClosedDate [Date Closed],
		                prss_InitialAmountOwed [Amount],
		                ISNULL(prss_Meritorious, 'N') Meritorious
	                FROM PRSSFile
		                INNER JOIN Company ON prss_RespondentCompanyID = comp_CompanyID
		                INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
		                INNER JOIN Custom_Captions ON comp_PRListingStatus = capt_code AND capt_family = 'comp_PRListingStatus'
	                WHERE prss_Type = 'C'
	                AND prss_OpenedDate BETWEEN @TargetStartDate AND @TargetEndDate
	                UNION
	            SELECT comp_CompanyID [BBID],
		                comp_Name [Company Name],
		                prci_City [Listing City],
		                prst_State [Listing State],
		                prcn_Country [Listing Country],
		                CAST(capt_us as varchar(100)) [Listing Status],
		                prcc_CreatedDate [Open Date],
		                'Lawsuit' [Claim Type],
		                '' [Status],
		                prcc_ClosedDate [Date Closed],
		                prcc_ClaimAmt [Amount],
		                '' Meritorious 
	                FROM PRCourtCases
		                INNER JOIN Company ON prcc_CompanyID = comp_CompanyID
		                INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
		                INNER JOIN Custom_Captions ON comp_PRListingStatus = capt_code AND capt_family = 'comp_PRListingStatus'
	                WHERE prcc_CreatedDate BETWEEN @TargetStartDate AND @TargetEndDate) T1
            ORDER BY BBID, [Open Date]";

        private static void CreateProduceODGClaimActivityFile(SqlConnection oConn, string targetFolder, string strFileName)
        {
            //GET DATA
            SqlCommand oSQLCommand = new SqlCommand(ODGSQL_CLAIM_ACTIVITY, oConn);
            oSQLCommand.CommandTimeout = Utilities.GetIntConfigValue("BBScoreExportCombinedCommandTimeout", 240);

            //Replace ? that were in original SQL provided
            DateTime dtTargetEndDate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
            DateTime dtTargetStartDate = dtTargetEndDate.AddMonths(-Utilities.GetIntConfigValue("BBScoreExportCombined_ODGClaimActivityFile_MonthsOld", 24));

            oSQLCommand.Parameters.AddWithValue("@TargetStartDate", dtTargetStartDate);
            oSQLCommand.Parameters.AddWithValue("@TargetEndDate", dtTargetEndDate);

            //CREATE REPORT / WRITE FILE
            string strFullFileAndPath = Path.Combine(targetFolder, strFileName);
            File.Delete(strFullFileAndPath); //delete file if it already exists

            using (TextWriter csv = File.CreateText(strFullFileAndPath))
            {
                using (SqlDataReader reader = oSQLCommand.ExecuteReader())
                {
                    csv.WriteLine("BBID, Company Name, Listing City, Listing State, Listing Country, Listing Status, Open Date, Claim Type, Status, Date Closed, Amount, Meritorious");

                    while (reader.Read())
                    {
                        csv.Write(reader["BBID"] + ",");
                        csv.Write(Quotes(reader["Company Name"]) + ","); //Company name always has quotes
                        csv.Write(reader["Listing City"] + ",");
                        csv.Write(reader["Listing State"] + ",");
                        csv.Write(reader["Listing Country"] + ",");
                        csv.Write(reader["Listing Status"] + ",");
                        csv.Write(CustomDate4(reader["Open Date"]) + ","); // Ex: 5/2/18
                        csv.Write(reader["Claim Type"] + ",");
                        csv.Write(reader["Status"] + ",");
                        csv.Write(CustomDate4(reader["Date Closed"]) + ","); // Ex: 5/2/18

                        object amt = reader["Amount"];

                        if (amt == null || amt == DBNull.Value)
                            csv.Write(",");
                        else
                        {
                            decimal value;
                            string szAmt;

                            if (Decimal.TryParse(amt.ToString(), out value))
                            {
                                szAmt = value.ToString("0.00");
                            }
                            else
                            {
                                szAmt = amt.ToString();
                            }

                            szAmt = szAmt.Replace("$", ""); //make sure no $
                            csv.Write(szAmt + ","); 
                        }

                        csv.WriteLine(reader["Meritorious"]);
                    }
                }
            }
        }
        #endregion

        protected string CompressFiles(string strFolder, string strZipFileName, params string[] lstSourceFileNames)
        {
            string zipName = Path.Combine(strFolder, strZipFileName);
            File.Delete(zipName); //delete zip file it it already exists

            using (ZipOutputStream zipOutputStream = new ZipOutputStream(File.Create(zipName)))
            {
                zipOutputStream.SetLevel(9); // 0-9, 9 being the highest compression
                //zipOutputStream.Password = Utilities.GetConfigValue("BBScoreExportCombinedZipPassword", "P@ssword1"); //must provide password if AESKeySize is set

                foreach (string strSourceFile in lstSourceFileNames)
                    addZipEntry(zipOutputStream, strFolder, strSourceFile);

                zipOutputStream.Finish();
                zipOutputStream.IsStreamOwner = true;
                zipOutputStream.Close();
            }

            return zipName;
        }

        #region Utility Functions

        protected void addZipEntry(ZipOutputStream zipOutputStream,
                                    string folder,
                                    string fileName)
        {
            addZipEntry(zipOutputStream, folder, fileName, fileName);
        }

        protected void addZipEntry(ZipOutputStream zipOutputStream,
                                    string folder,
                                    string fileName,
                                    string zipEntryName)
        {
            ZipEntry zipEntry = new ZipEntry(ZipEntry.CleanName(zipEntryName));
            zipEntry.DateTime = DateTime.Now;
            //zipEntry.AESKeySize = 256; //if this is turned on, must provide password or it will error out
            zipOutputStream.PutNextEntry(zipEntry);

            byte[] buffer = new byte[4096];
            using (FileStream fs = File.OpenRead(Path.Combine(folder, fileName)))
            {
                int sourceBytes;
                do
                {
                    sourceBytes = fs.Read(buffer, 0, buffer.Length);
                    zipOutputStream.Write(buffer, 0, sourceBytes);

                } while (sourceBytes > 0);
            }
            zipOutputStream.CloseEntry();
        }

        private static string Quotes(object obj)
        {
            if (obj == null || obj == DBNull.Value)
                return string.Format("\"\"");
            else
                return string.Format("\"{0}\"", obj.ToString());
        }

        private static string CustomDate1(object obj)
        {
            return CustomDate(obj, "yyyy-MM-dd HH:mm:ss.fff"); // Ex: 1997-02-10 00:00:00.000
        }

        private static string CustomDate2(object obj)
        {
            return CustomDate(obj, "yyyy-MM-dd HH:mm:ss"); // Ex: 1997-02-10 00:00:00
        }

        private static string CustomDate3(object obj)
        {
            return CustomDate(obj, "MM/dd/yyyy"); // Ex: 01/02/1997
        }

        private static string CustomDate4(object obj)
        {
            return CustomDate(obj, "M/d/yy"); // Ex: 5/16/97 
        }

        private static string CustomDate(object obj)
        {
            return CustomDate(obj, "yyyy-MM-dd"); // Ex: 1997-05-25
        }

        private static string CustomDate(object obj, string szFormat)
        {
            if (obj == null || obj == DBNull.Value || obj.ToString() == "")
                return string.Format("");
            else
                return Convert.ToDateTime(obj).ToString(szFormat);
        }
        #endregion  
    }
}
