/***********************************************************************
 Copyright Blue Book Services, Inc. 2016-2019

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: BBScoreLumberEvent.cs
 Description:	

 Notes:	

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
	public class BBScoreLumberEvent : BBSMonitorEvent
	{
        private int _DayOfMonth = 0;
        private const string DELIMIETER = "\t";

		/// <summary>
		/// Generates the BB Score Lumber report
		/// </summary>
		override public void Initialize(int iIndex)
		{
			_szName = "BBScoreLumberEvent";

			base.Initialize(iIndex);

			try
			{
                _DayOfMonth = Utilities.GetIntConfigValue("BBScoreLumberDayOfMonth", 1);
				_lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("BBScoreLumberInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
				_oLogger.LogMessage("BBScoreLumber Interval: " + _lEventInterval.ToString());

				_dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("BBScoreLumberStartDateTime"));
				_dtNextDateTime = _dtStartDateTime;

				_oEventTimer = new Timer();
				_oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
				ConfigureTimer(false);

				_oLogger.LogMessage("BBScoreLumber Start: " + _dtNextDateTime.ToString());

			}
			catch(Exception e)
			{
				LogEventError("Error initializing BBScoreLumber event.", e);
				throw;
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

		protected const string RatingNumeralSQL =
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

		/// <summary>
		/// Process any BB Score Lumber reports.
		/// </summary>
		override public void ProcessEvent()
		{

            // We actually only run once a month, on the day
            // of the month specified.
            if (DateTime.Today.Day != _DayOfMonth)
            {
                return;
            }

			SqlConnection oConn = new SqlConnection(GetConnectionString());
			const string CUSTOM_CAPTION = "prlumber_LastRunDate_old";
			const string FILE_NAME_LUMBER_AR_AGING = "Lumber AR Aging.csv"; 
			const string FILE_NAME_RATINGS = "Ratings.csv";
            string FILE_NAME_ZIP = Utilities.GetConfigValue("BBScoreLumberFTPFileName", "LumberBB.zip");

			try
			{
				string targetFolder = Utilities.GetConfigValue("BBScoreLumberFolder");

				oConn.Open();

				DateTime dtLastRunDate = GetDateTimeCustomCaption(oConn, CUSTOM_CAPTION); //to create stub NULL prlumber_LastRunDate_old, run this script: 	INSERT INTO Custom_Captions (Capt_CaptionId, Capt_FamilyType, Capt_Family, Capt_Code, Capt_US, Capt_UK, Capt_FR, Capt_DE, Capt_ES, Capt_Order, Capt_System, Capt_CreatedBy, Capt_CreatedDate, Capt_UpdatedBy, Capt_UpdatedDate, Capt_TimeStamp, Capt_Deleted, Capt_Context, Capt_DU, Capt_JP, Capt_Component, capt_deviceid, capt_integrationid, capt_CS) values (((select max(capt_captionid) from Custom_Captions) + 1),'Choices', 'prlumber_LastRunDate_old', NULL, 'Lumber BB Last Run Date/Time', 'Lumber BB Last Run Date/Time', 'Lumber BB Last Run Date/Time', 'Lumber BB Last Run Date/Time', 'Lumber BB Last Run Date/Time', 0, NULL, -1, GETDATE(), -1000, GETDATE(), GETDATE(), NULL, NULL, NULL, NULL, 'PRDropdownValues', NULL, NULL, NULL)

				_oLogger.LogMessage("dtLastRunDate=" + dtLastRunDate.ToString());

				//Create CSV files
				CreateLumberARFile(oConn, targetFolder, FILE_NAME_LUMBER_AR_AGING, dtLastRunDate);
				CreateRatingNumeralFile(oConn, targetFolder, FILE_NAME_RATINGS, dtLastRunDate);

				string ftpFileName = CompressFiles(targetFolder, FILE_NAME_ZIP, FILE_NAME_LUMBER_AR_AGING, FILE_NAME_RATINGS);

				_oLogger.LogMessage(String.Format("zip file {0} created", ftpFileName));

				//FTP zip file
				string ftpURL = Utilities.GetConfigValue("BBScoreLumberFTPServer", "ftp://ftp.bluebookservices.com");

                UploadFileSFTP(ftpURL,
                               Utilities.GetIntConfigValue("BBScoreLumberFTPPort", 9210),
				               Utilities.GetConfigValue("BBScoreLumberFTPUsername", "qa"),
				               Utilities.GetConfigValue("BBScoreLumberFTPPassword", "fTp~1901"),
				               ftpFileName,
                               Utilities.GetConfigValue("BBScoreLumberFTPFolder", "data") + "/" + Path.GetFileName(ftpFileName));

                string msg = String.Format("Zip file {0} sent via FTP to {1}", ftpFileName, ftpURL);
				_oLogger.LogMessage(msg);

				//FINALIZE
				UpdateDateTimeCustomCaption(oConn, CUSTOM_CAPTION, DateTime.Now);

                if (Utilities.GetBoolConfigValue("BBScoreLumberWriteResultsToEventLog", true))
                {
                    LogEvent("Lumber BBScore AR data successfully generated. " + msg);
                }

                if (Utilities.GetBoolConfigValue("BBScoreLumberSendResultsToSupport", true))
                {
                    SendMail("Lumber BBScore AR Success", "Lumber BBScore AR data successfully generated. " + msg);
                }
			}
			catch(Exception e)
			{
				LogEventError("Error Procesing BBScoreLumber Event.", e);
			}
			finally
			{
				if(oConn != null)
					oConn.Close();

				oConn = null;
			}
		}

		private static void CreateLumberARFile(SqlConnection oConn, string targetFolder, string strFileName, DateTime dtLastRunDate)
		{
			//GET DATA
			SqlCommand oSQLCommand = new SqlCommand(LumberAgingDataSQL, oConn);
			oSQLCommand.Parameters.AddWithValue("@LastRunDate", dtLastRunDate);

			//CREATE REPORT / WRITE FILE
      string strFullFileAndPath = Path.Combine(targetFolder, strFileName);
			File.Delete(strFullFileAndPath); //delete file if it already exists

			using(TextWriter csv = File.CreateText(strFullFileAndPath))
			{
				using(SqlDataReader reader = oSQLCommand.ExecuteReader())
				{
                    csv.WriteLine("SubmitterID, SubjectID, ARDate, AmountCurrent, Amount1to30, Amount31to60, Amount61to90, Amount91Plus");

					while(reader.Read())
					{
						csv.Write(reader["SubmitterID"] + ",");
						csv.Write(reader["SubjectID"] + ",");
						csv.Write(reader["ARDate"] + ",");
						csv.Write(reader["AmountCurrent"] + ",");
						csv.Write(reader["Amount1to30"] + ",");
						csv.Write(reader["Amount31to60"] + ",");
						csv.Write(reader["Amount61to90"] + ",");
						csv.WriteLine(reader["Amount91Plus"]);
					}
				}
			}
		}

		private static void CreateRatingNumeralFile(SqlConnection oConn, string targetFolder, string strFileName, DateTime dtLastRunDate)
		{
			//GET DATA
			SqlCommand oSQLCommand = new SqlCommand(RatingNumeralSQL, oConn);
			oSQLCommand.Parameters.AddWithValue("@LastRunDate", dtLastRunDate);
            oSQLCommand.CommandTimeout = Utilities.GetIntConfigValue("BBScoreLumberCommandTimeout", 120);

			//CREATE REPORT / WRITE FILE
            string strFullFileAndPath = Path.Combine(targetFolder, strFileName);
			File.Delete(strFullFileAndPath); //delete file if it already exists

			using(TextWriter csv = File.CreateText(strFullFileAndPath))
			{
				using(SqlDataReader reader = oSQLCommand.ExecuteReader())
				{
                    csv.WriteLine("BBID" + DELIMIETER + "Company Name" + DELIMIETER + "Listing Location" + DELIMIETER + "Rating Line" + DELIMIETER + "Pay Indicator" + DELIMIETER + "First Assigned Date");

					while(reader.Read())
					{
						csv.Write(reader["BBID"] + DELIMIETER);
						csv.Write(reader["Company Name"] + DELIMIETER);
						csv.Write(reader["Listing Location"] + DELIMIETER);
						csv.Write(reader["Rating Line"] + DELIMIETER);
						csv.Write(reader["Pay Indicator"] + DELIMIETER);
						csv.WriteLine(reader["First Assigned Date"]);
					}
				}
			}
		}

		protected string CompressFiles(string strFolder, string strZipFileName, params string[] lstSourceFileNames)
		{
			string zipName = Path.Combine(strFolder, strZipFileName);
			File.Delete(zipName); //delete zip file it it already exists

			using(ZipOutputStream zipOutputStream = new ZipOutputStream(File.Create(zipName)))
			{
				zipOutputStream.SetLevel(9); // 0-9, 9 being the highest compression
				//zipOutputStream.Password = Utilities.GetConfigValue("BBScoreLumberZipPassword", "P@ssword1"); //must provide password if AESKeySize is set

				foreach(string strSourceFile in lstSourceFileNames)
					addZipEntry(zipOutputStream, strFolder, strSourceFile);

				zipOutputStream.Finish();
				zipOutputStream.IsStreamOwner = true;
				zipOutputStream.Close();
			}

			return zipName;
		}

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
			using(FileStream fs = File.OpenRead(Path.Combine(folder, fileName)))
			{
				int sourceBytes;
				do
				{
					sourceBytes = fs.Read(buffer, 0, buffer.Length);
					zipOutputStream.Write(buffer, 0, sourceBytes);

				} while(sourceBytes > 0);
			}
			zipOutputStream.CloseEntry();
		}
	}
}
