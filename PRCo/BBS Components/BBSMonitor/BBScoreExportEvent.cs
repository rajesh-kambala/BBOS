/***********************************************************************
 Copyright Blue Book Services, Inc. 2017-2020

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: BBScoreExportEvent.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Data.SqlClient;
using System.IO;
using System.Timers;
using TSI.Utils;

namespace PRCo.BBS.BBSMonitor
{
  public class BBScoreExportEvent: BBSMonitorEvent
  {
    /// <summary>
    /// Initializes the service setting up the logger, timer,
    /// etc.
    /// </summary>
    override public void Initialize(int iIndex)
    {
      _szName = "BBScoreExport";

      base.Initialize(iIndex);

      try
      {
        // Defaults to 24 hours.  Value is in minutes.
        _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("BBScoreExportInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
        _oLogger.LogMessage("BBScoreExport Interval: " + _lEventInterval.ToString());

        _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("BBScoreExportStartDateTime"));
        _dtNextDateTime = _dtStartDateTime;

        _oEventTimer = new Timer();
        _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
        ConfigureTimer(false);

        _oLogger.LogMessage("BBScoreExport Start: " + _dtNextDateTime.ToString());

      }
      catch (Exception e)
      {
        LogEventError("Error initializing BBScoreExport event.", e);
        throw;
      }
    }

    /// <summary>
    /// Go generate our file and save it
    /// to disk.
    /// </summary>
    override public void ProcessEvent()
    {

      try
      {
        SqlConnection dbConn = new SqlConnection(GetConnectionString());
        dbConn.Open();

        DateTime dtLastBBScoreRunDate = GetDateTimeCustomCaption(dbConn, "LastBBScoreRunDate");
        DateTime dtLastBBScoreExportDate = GetDateTimeCustomCaption(dbConn, "LastBBScoreExportDate");

        if (dtLastBBScoreExportDate > dtLastBBScoreRunDate)
        {
            return;
        }

        string fileName = string.Format(Utilities.GetConfigValue("BBScoreExportFileName", "BBScore_{0}.csv"), DateTime.Today.ToString("yyyyMMdd"));
        string outputFile = Path.Combine(Utilities.GetConfigValue("BBScoreExportFolder"), fileName);

        CreateBBScoreFile(dbConn, outputFile);

        _oLogger.LogMessage(String.Format("File {0} created", outputFile));

        string ftpURL = Utilities.GetConfigValue("BBScoreExportFTPServer", "ftp://ftp.bluebookservices.com");

        UploadFile(ftpURL,
                    Utilities.GetConfigValue("BBScoreExportFTPUsername", "299330"),
                    Utilities.GetConfigValue("BBScoreExportFTPPassword", "Ppi*2011~"),
                    outputFile,
                    true,
                    false,
                    false);

        UpdateDateTimeCustomCaption(dbConn, "LastBBScoreExportDate", DateTime.Now);

        string msg = String.Format("A new BBSI BB Score file has been posted on {1}", outputFile, ftpURL);
        _oLogger.LogMessage(msg);

        if (!string.IsNullOrEmpty(Utilities.GetConfigValue("BBScoreExportNotification", string.Empty))) {
            SendMail(Utilities.GetConfigValue("BBScoreExportNotification"), "BBSI BB Score File", msg);
        }

        if (Utilities.GetBoolConfigValue("BBScoreExportWriteResultsToEventLog", true))
        {
          _oBBSMonitorService.LogEvent("BBScoreExport Executed Successfully.");
        }

        if (Utilities.GetBoolConfigValue("BBScoreExportSendResultsToSupport", false))
        {
          SendMail("BBScoreExport Success", "BBScoreExport Executed Successfully.");
        }

      }
      catch (Exception e)
      {
        // This logs the error in the Event Log, Trace File,
        // and sends the appropriate email.
        LogEventError("Error Procesing BBScoreExport Event.", e);
      }
    }

    private const string SQL_GET_BBSCORE =
      @"SELECT comp_CompanyID,
               comp_Name,
	           prbs_BBScore,
               prci_City,
               ISNULL(prst_State, '') as prst_State,
               prcn_Country,
               ISNULL(dbo.ufn_FormatPhone(phone.phon_CountryCode, phone.phon_AreaCode, phone.phon_Number, phone.phon_PRExtension), '') as Phone,
               ISNULL(RTRIM(WS.emai_PRWebAddress), '') as WebSite
          FROM Company WITH (NOLOCK)
               INNER JOIN PRBBScore WITH (NOLOCK) ON comp_CompanyID = prbs_CompanyID AND prbs_Current = 'Y' AND prbs_PRPublish = 'Y'
               INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
               LEFT OUTER JOIN vPRCompanyPhone phone WITH (NOLOCK) ON comp_CompanyID = phone.plink_RecordID AND  phone.phon_PRIsPhone = 'Y' AND phone.phon_PRPreferredPublished = 'Y'
               LEFT OUTER JOIN vCompanyEmail as WS WITH (NOLOCK) ON comp_CompanyID = WS.elink_RecordID AND WS.ELink_Type = 'W' AND WS.emai_PRPreferredPublished='Y' 
         WHERE comp_PRIndustryType IN ('P', 'T', 'S')
           AND comp_PRListingStatus IN ('L', 'H', 'LUV')
           AND comp_PRType = 'H'
         ORDER BY comp_Name";

        // 8-1-2018 Purposely didn't not include check comp_PRPublishBBScore='Y' after discussion between chw/jmt 

    private void CreateBBScoreFile(SqlConnection dbConn, string outputFile)
    {

      SqlCommand sqlCommand = new SqlCommand(SQL_GET_BBSCORE, dbConn);
      File.Delete(outputFile); //delete file if it already exists

      using (TextWriter csv = File.CreateText(outputFile))
      {
        using (SqlDataReader reader = sqlCommand.ExecuteReader())
        {
          csv.WriteLine("\"BBID\",\"Company Name\",\"BB Score\",\"Listing City\",\"Listing State\",\"Listing Country\",\"Phone\",\"Web Site\"");

          while (reader.Read())
          {
            string[] args = {reader.GetInt32(0).ToString(),
                             reader.GetString(1),
                             reader.GetDecimal(2).ToString("000"),
                             reader.GetString(3),
                             reader.GetString(4),
                             reader.GetString(5),
                             reader.GetString(6),
                             reader.GetString(7)};

            csv.WriteLine(string.Format("{0},\"{1}\",{2},\"{3}\",\"{4}\",\"{5}\",\"{6}\",\"{7}\"", args));
          }
        }
      }
    }


  }
}
