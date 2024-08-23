/***********************************************************************
 Copyright Blue Book Services, Inc. 2021-2021

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: LogParser.cs
 Description:	https://documentation.help/Log-Parser/LPCOMAPI_CSExamples.htm
                https://www.microsoft.com/en-us/download/details.aspx?id=24659
 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Data.SqlClient;
using System.Timers;
using TSI.Utils;
//using MSUtil;
using System.Text;

namespace PRCo.BBS.BBSMonitor
{
    public class LogParser : BBSMonitorEvent
	{
		/// <summary>
		/// Generates the BB Score Lumber report
		/// </summary>
		override public void Initialize(int iIndex)
		{
			_szName = "LogParserEvent";

			base.Initialize(iIndex);

			try
			{
				_lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("LogParserInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
				_oLogger.LogMessage("LogParser Interval: " + _lEventInterval.ToString());

				_dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("LogParserStartDateTime"));
				_dtNextDateTime = _dtStartDateTime;

				_oEventTimer = new Timer();
				_oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
				ConfigureTimer(false);

				_oLogger.LogMessage("LogParser Start: " + _dtNextDateTime.ToString());

			}
			catch(Exception e)
			{
				LogEventError("Error initializing LogParser event.", e);
				throw;
			}
		}

		/// <summary>
		/// Process any BB Score Lumber reports.
		/// </summary>
		override public void ProcessEvent()
		{
			SqlConnection oConn = new SqlConnection(GetConnectionString());

			try
			{
				oConn.Open();

                //https://www.codeproject.com/Articles/13504/Simple-log-parsing-using-MS-Log-Parser-2-2-in-C-NE
                ParseW3CLog(oConn);

                if (Utilities.GetBoolConfigValue("LogParserWriteResultsToEventLog", true))
                    LogEvent("LogParser data successfully imported.");

                if (Utilities.GetBoolConfigValue("LogParserSendResultsToSupport", true))
                    SendMail("LogParser Success", "LogParser data successfully imported.");
			}
			catch(Exception e)
			{
				LogEventError("Error Procesing LogParser Event.", e);
			}
			finally
			{
				if(oConn != null)
					oConn.Close();

				oConn = null;
			}
		}

		const string INSERT_IIS = @"INSERT INTO PRIISLogData (priisld_IISLogDataId, priisld_IPAddress, priisld_LogDate, priisld_URI, priisld_LogType, priisld_Month, priisld_Year) 
						VALUES (@IISLogDataId, @IPAddress, @LogDate, @URI, @LogType, @Month, @Year)";

		public void ParseW3CLog(SqlConnection oConn)
		{
			// get max logdate currently in database so that we can only retrieve new records since then
			DateTime? dtMaxLogDate = null;
			SqlCommand cmdMaxLogDate = new SqlCommand("SELECT MAX(priisld_LogDate) FROM PRIISLogData WITH(NOLOCK)", oConn);
			using (SqlDataReader reader = cmdMaxLogDate.ExecuteReader())
			{
				if (reader.Read())
				{
					if(reader[0] != System.DBNull.Value)
						dtMaxLogDate = Convert.ToDateTime(reader[0]);
				}
			}

			// prepare LogParser Recordset & Record objects
			//ILogRecordset rsLP = null;
			//ILogRecord rowLP = null;

			//LogQueryClassClass LogParser = null;
			//COMW3CInputContextClassClass W3Clog = null;

			//StringBuilder sbSQL = new StringBuilder();

			//LogParser = new LogQueryClassClass();
			//W3Clog = new COMW3CInputContextClassClass();

			int iCount = 0;
			string URI = null;
			string LogType = null;
			DateTime LogDate = DateTime.MinValue;

			try
			{
				string szIISLogFilesPath = Utilities.GetConfigValue("LogParserIISLogFilesPath");

				//W3C Logparsing SQL. Replace this SQL query with whatever you want to retrieve. Download Log Parser 2.2 
				//from Microsoft and see sample queries.  https://www.codeproject.com/Articles/13504/Simple-log-parsing-using-MS-Log-Parser-2-2-in-C-NE
				//sbSQL.Append("SELECT c-ip, to_timestamp(date, time), cs-uri-stem, sc-status");
				//sbSQL.Append($" FROM {szIISLogFilesPath}\\u_*.log");
				//sbSQL.Append(" WHERE (cs-uri-stem like '%/eBook/index.html' OR cs-uri-stem like '%/kyc_ebook/%index.html%') ");
				//sbSQL.Append("   AND sc-status <> 404 ");

				//if (dtMaxLogDate.HasValue)
				//{
				//	sbSQL.Append($" AND to_timestamp(date,time) > TIMESTAMP('");
				//	sbSQL.Append(dtMaxLogDate.Value.ToString("yyyy-MM-dd HH:mm:ss"));
				//	sbSQL.Append("','yyyy-MM-dd HH:mm:ss') ");
				//}
				//sbSQL.Append("ORDER BY to_timestamp(date,time)");

				//_oLogger.LogMessage("LogParser SQL: " + sbSQL.ToString());

				// run the query against W3C log
				//rsLP = LogParser.Execute(sbSQL.ToString(), W3Clog);

				

				//iterate over all the returned records
				//while(!rsLP.atEnd())
    //            {
				//	iCount++;
				//	rowLP = rsLP.getRecord();
				//	//get values
				//	string IPAddress = (string)rowLP.getValue(0);
				//	LogDate = Convert.ToDateTime(rowLP.getValue(1));
				//	URI = (string)rowLP.getValue(2);
				//	LogType = "";

				//	int Month = 0;
				//	int Year = 0;

				//	if (URI.ToLower().Contains("/bp/"))
				//	{
				//		LogType = "BP";

				//		string bpUriPart1 = (URI.Split('+'))[0].ToLower();
				//		string bpUriPart2 = (URI.Split('+'))[1].ToLower();

				//		if (bpUriPart1.EndsWith("january")) { Month = 1; }
				//		else if (bpUriPart1.EndsWith("february")) { Month = 2; }
				//		else if (bpUriPart1.EndsWith("march")) { Month = 3; }
				//		else if (bpUriPart1.EndsWith("april")) { Month = 4; }
				//		else if (bpUriPart1.EndsWith("may")) { Month = 5; }
				//		else if (bpUriPart1.EndsWith("june")) { Month = 6; }
				//		else if (bpUriPart1.EndsWith("july")) { Month = 7; }
				//		else if (bpUriPart1.EndsWith("august")) { Month = 8; }
				//		else if (bpUriPart1.EndsWith("september")) { Month = 9; }
				//		else if (bpUriPart1.EndsWith("october")) { Month = 10; }
				//		else if (bpUriPart1.EndsWith("november")) { Month = 11; }
				//		else if (bpUriPart1.EndsWith("december")) { Month = 12; }

				//		// Some URLs only have two digit years.
				//		if (!Int32.TryParse(bpUriPart2.Substring(0, 4), out Year)) 
				//			Year = 2000 + Convert.ToInt32(bpUriPart2.Substring(0, 2));
				//	}
				//	else if (URI.ToLower().Contains("/kyc/"))
				//	{
				//		LogType = "KYC";
				//		int kycUriPart1Start = URI.ToLower().IndexOf("kyc_ebook/");

				//		// Some URLs only have two digit years.
				//		if (!Int32.TryParse(URI.ToLower().Substring(kycUriPart1Start + 10, 4), out Year))
				//			Year = 2000 + Convert.ToInt32(URI.ToLower().Substring(kycUriPart1Start + 10, 2));

				//	}
				//	else if (URI.ToLower().Contains("/kycguide/"))
				//	{
				//		LogType = "KYCGuide";

				//		int kycUriPart1Start = URI.ToLower().IndexOf("kycguide/");

				//		// Some URLs only have two digit years.
				//		if (!Int32.TryParse(URI.ToLower().Substring(kycUriPart1Start + 9, 4), out Year))
				//			Year = 2000 + Convert.ToInt32(URI.ToLower().Substring(kycUriPart1Start + 9, 2));

				//	}

				//	//insert record into table
				//	long iisLogDataID = GetRecordID(oConn, "PRIISLogData", null);

				//	SqlCommand cmdIISLog = new SqlCommand(INSERT_IIS, oConn, null);
				//	cmdIISLog.Parameters.AddWithValue("IISLogDataId", iisLogDataID);
				//	cmdIISLog.Parameters.AddWithValue("IPAddress", IPAddress);
				//	cmdIISLog.Parameters.AddWithValue("LogDate", LogDate);
				//	cmdIISLog.Parameters.AddWithValue("URI", URI);
				//	cmdIISLog.Parameters.AddWithValue("LogType", LogType);

				//	if(Month > 0)
				//		cmdIISLog.Parameters.AddWithValue("Month", Month);
				//	else
				//		cmdIISLog.Parameters.AddWithValue("Month", DBNull.Value);

				//	if (Year > 0)
				//		cmdIISLog.Parameters.AddWithValue("Year", Year);
				//	else
				//		cmdIISLog.Parameters.AddWithValue("Year", DBNull.Value);

				//	cmdIISLog.ExecuteNonQuery();

				//	// Next record
				//	rsLP.moveNext();
				//}

				if(iCount > 0)
					_oLogger.LogMessage($"LogParser Results: {iCount} new records added.");
			}
			catch (Exception eX)
			{
				string message = $"{eX.Message} parsing line #{iCount}. LogType: {LogType} LogDate:{LogDate} URI: {URI}";
				throw new ApplicationException(message, eX);
			}
		}
	}
}
