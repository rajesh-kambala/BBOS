/***********************************************************************
 Copyright Blue Book Services, Inc. 2015-2020

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: ThirdPartyNewsValidationEvent.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Net;
using System.Text;
using System.Timers;
using TSI.Utils;

namespace PRCo.BBS.BBSMonitor
{
    public class ExternalNewsValidationEvent: BBSMonitorEvent
    {
        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex) {
            _szName = "ExternalNewsValidationEvent";

            base.Initialize(iIndex);

            try {
                //
                // Configure our ExternalNewsValidation Event
                //
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("ExternalNewsValidationInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("ExternalNewsValidationEvent Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("ExternalNewsValidationStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("ExternalNewsValidation Start: " + _dtNextDateTime.ToString());

            } catch (Exception e) {
                LogEventError("Error initializing ExternalNewsValidation event.", e);
                throw;
            }
        }

        private const string INVALID_DETAIL = "\"{0}\",\"{1}\",\"{2}\",\"{3}\",\"{4}\"";
        private const string SQL_SELECT_EXTERNAL_NEWS =
            @"SELECT TOP({0}) pren_ExternalNewsID, pren_SubjectCompanyID, pren_Name, pren_URL, pren_PublishDateTime
                FROM PRExternalNews WITH (NOLOCK)
               WHERE pren_PublishDateTime < '{1}'
            ORDER BY pren_PublishDateTime";

        override public void ProcessEvent()
        {
            DateTime dtExecutionStartDate = DateTime.Now;

            Dictionary<string, bool> validatedURLs = new Dictionary<string, bool>();
            List<int> deleteNewsArticles = new List<int>();
            StringBuilder output = new StringBuilder();
            int urlCount = 0;

            SqlConnection oConn = new SqlConnection(GetConnectionString());
            oConn.Open();
            try
            {
                DateTime expirationDate = DateTime.Today.AddDays(0 - Utilities.GetIntConfigValue("ExternalNewsValidationArticleDaysThreshold", 90));

                string sql = string.Format(SQL_SELECT_EXTERNAL_NEWS,
                                           Utilities.GetIntConfigValue("ExternalNewsValidationArticleLimit", 500),
                                           expirationDate);

                SqlCommand sqlCommandCompanies = new SqlCommand(sql, oConn);
                sqlCommandCompanies.CommandTimeout = 240;

                using (SqlDataReader oReader = sqlCommandCompanies.ExecuteReader())
                {
                    while (oReader.Read())
                    {
                        urlCount++;

                        int externalNewsArticleID = oReader.GetInt32(0);
                        string url = oReader.GetString(3).Trim();

                        bool valid = false;

                        if (validatedURLs.ContainsKey(url))
                        {

                            valid = validatedURLs[url];


                        }
                        else
                        {
                            valid = ValidateURL(url);
                            validatedURLs.Add(url, valid);
                        }


                        if (!valid)
                        {
                            deleteNewsArticles.Add(externalNewsArticleID);

                            object[] args = {externalNewsArticleID,
                                             oReader.GetInt32(1),
                                             oReader.GetString(2),
                                             url,
                                             oReader.GetDateTime(4)};

                            output.Append(string.Format(INVALID_DETAIL, args) + Environment.NewLine);
                        }
                    }
                }


                if (deleteNewsArticles.Count > 0)
                {
                    string deleteIDs = string.Join(",", deleteNewsArticles);
                    string deleteSQL = "DELETE FROM PRExtneralNews WHERE pren_ExternalNewsID IN (" + deleteIDs + ")";

                    output.Append(Environment.NewLine + deleteSQL + Environment.NewLine);

                    if (Utilities.GetBoolConfigValue("ExternalNewsValidationDeleteArticles", false))
                    {

                        SqlCommand sqlDeleteArticles = new SqlCommand(deleteSQL, oConn);
                        sqlDeleteArticles.ExecuteNonQuery();
                    }
                }


                DateTime dtExecutionEndDateTime = DateTime.Now;

                StringBuilder sbMsg = new StringBuilder();
                sbMsg.Append("External News Articles Validated: " + urlCount.ToString("###,##0") + Environment.NewLine);
                sbMsg.Append("External News Articles Deleted: " + deleteNewsArticles.Count.ToString("###,##0") + Environment.NewLine);
                sbMsg.Append(Environment.NewLine);

                TimeSpan tsDiff = dtExecutionEndDateTime.Subtract(dtExecutionStartDate);
                sbMsg.Append("Execution time: " + tsDiff.ToString() + Environment.NewLine);

                if (Utilities.GetBoolConfigValue("ExternalNewsValidationWriteResultsToEventLog", true))
                {
                    _oBBSMonitorService.LogEvent(sbMsg.ToString());
                }


                if (Utilities.GetBoolConfigValue("ExternalNewsValidationSendResultsToSupport", false))
                {
                    if (output.Length > 0)
                    {
                        sbMsg.Append(Environment.NewLine);
                        sbMsg.Append("Non-OK URLs" + Environment.NewLine);
                        object[] headerArgs = {"External News ID",
                                       "Subject Company ID",
                                       "Article Name",
                                       "URL",
                                       "Publish Date/Time"};

                        sbMsg.Append(string.Format(INVALID_DETAIL, headerArgs) + Environment.NewLine);
                        sbMsg.Append(output);
                    }

                    SendMail("ExternalNewsValidation Event Success", sbMsg.ToString());
                }

                
            }
            catch (Exception e)
            {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error Procesing ExternalNewsValidation Event.", e);
            }
            finally
            {
                oConn.Close();
            }
        }

        /// <summary>
        /// Attempts to connect to the specified URL and sets attributes
        /// in the CompanyInternet class to indicate success or failure.
        /// </summary>
        private bool ValidateURL(string url)
        {
            if (url.StartsWith("http://"))
            {
                url = url.Replace("http://", string.Empty);
            }


            HttpWebRequest request = (HttpWebRequest)WebRequest.Create("http://" + url);
            request.CookieContainer = new CookieContainer();
            request.Accept = "*/*";
            request.UserAgent = Utilities.GetConfigValue("ExternalNewsValidationUserAgent", "Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; rv:11.0) like Gecko");
            request.Timeout = (Utilities.GetIntConfigValue("ExternalNewsValidationTimeout", 120) * 1000);


            try
            {
                using (HttpWebResponse response = (HttpWebResponse)request.GetResponse()) {
                    if (response.StatusCode == HttpStatusCode.OK)
                    {
                        var encoding = Encoding.GetEncoding(response.CharacterSet);

                        using (var responseStream = response.GetResponseStream())
                        using (var reader = new StreamReader(responseStream, encoding))
                        {
                            string content = reader.ReadToEnd();

                            if ((content.ToLower().Contains("<code>680004</code>")) ||
                                (content.ToLower().Contains("<message>no url has been found. </message>")))
                            {
                                return false;
                            }
                        }


                        return true;
                    }
                    else
                    {
                        return false;
                    }
                }
            }
            catch (System.Net.WebException)
            {
                return false;
            }

            catch (Exception Ex)
            {
                LogEventError("Error retrieving URL: " + url, Ex);
                return false;
            }

        }
    }
}
