/***********************************************************************
 Copyright Produce Reporter Company 2013-2018

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: InternetValidationEvent.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Net;
using System.Text;
using System.Timers;
using TSI.Utils;
namespace PRCo.BBS.BBSMonitor
{
    public class InternetValidationEvent : BBSMonitorEvent
    {
        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex) {
            _szName = "InternetValidationEvent";

            base.Initialize(iIndex);

            try {
                //
                // Configure our InternetValidationEvent Event
                //
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("InternetValidationInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("InternetValidation Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("InternetValidationStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("InternetValidation Start: " + _dtNextDateTime.ToString());

            } catch (Exception e) {
                LogEventError("Error initializing InternetValidation event.", e);
                throw;
            }
        }

        private const string INVALID_DETAIL = "\"{0}\",\"{1}\",\"{2}\",\"{3}\",\"{4}\",\"{5}\",\"{6}\"";
        private const string SQL_SELECT_WEB_SITES =
            @"SELECT ISNULL(CASE elink_EntityID WHEN 5 THEN elink_RecordID ELSE NULL END, 0) As emai_CompanyID, 
                     ISNULL(CASE elink_EntityID WHEN 13 THEN elink_RecordID ELSE NULL END, 0) As emai_PersonID, 
                     RTRIM(emai_PRWebAddress), 
                     comp_PRListingStatus,  
                     comp_PRIndustryType, 
                     ISNULL(emai_PRPublish, 'N') 
                FROM Email WITH (NOLOCK)
                     INNER JOIN EmailLink WITH (NOLOCK) ON emai_EmailID = elink_EmailID
                     INNER JOIN Company WITH (NOLOCK) ON elink_RecordID = comp_CompanyID 
               WHERE elink_Type='W' 
                 AND comp_PRListingStatus IN ({0}) 
                 AND comp_PRLocalSource IS NULL
                 AND comp_PRIndustryType IN ({1})
                 AND emai_PRPublish = 'Y'
            ORDER BY RTRIM(emai_PRWebAddress), comp_CompanyID";

        override public void ProcessEvent() 
        {
            DateTime dtExecutionStartDate = DateTime.Now;

            // We can only execute on certain days
            // of the month
            if (!CanExecute(dtExecutionStartDate))
            {
                return;
            }

            List<CompanyInternet> lcompanyInternet = new List<CompanyInternet>();
            List<CompanyInternet> lvalidatedCompanyInternet = new List<CompanyInternet>();
            StringBuilder output = new StringBuilder();
            StringBuilder outputEmail = new StringBuilder();
            StringBuilder outputHTTP = new StringBuilder();
            StringBuilder outputLumber = new StringBuilder();
            StringBuilder unableToConnect = new StringBuilder();

            int uniqueInvalidURLCount = 0;
            int invalidCompanyCount = 0;
            int NonBBSiStandardFormattedCount = 0;

            int count = 0;
            int maxCount = Utilities.GetIntConfigValue("InternetValidationMaxCount", 999999);

            SqlConnection oConn = new SqlConnection(GetConnectionString());
            oConn.Open();
            try
            {
                string sql = string.Format(SQL_SELECT_WEB_SITES,
                                           Utilities.GetConfigValue("InternetValidationListingStatus", "'L', 'LUV', 'H'"),
                                           Utilities.GetConfigValue("InternetValidationIndustryType", "'P', 'T', 'S', 'L'"));

                SqlCommand sqlCommandCompanies = new SqlCommand(sql,
                                                                oConn);
                sqlCommandCompanies.CommandTimeout = 240;

                using (SqlDataReader oReader = sqlCommandCompanies.ExecuteReader())
                {
                    while (oReader.Read())
                    {
                        lcompanyInternet.Add(new CompanyInternet(oReader.GetInt32(0), 
                                                                 oReader.GetInt32(1),
                                                                 oReader.GetString(2), 
                                                                 "W",
                                                                 oReader.GetString(3),
                                                                 oReader.GetString(4),
                                                                 oReader.GetString(5)));

                        count++;
                        if (count >= maxCount)
                        {
                            break;
                        }
                    
                    }
                }




                foreach(CompanyInternet companyInternet in lcompanyInternet) {

                    bool validated = false;
                    foreach(CompanyInternet validatedCompanyInternet in lvalidatedCompanyInternet) {
                        if (companyInternet.URL == validatedCompanyInternet.URL)
                        {
                            validated = true;

                            companyInternet.Valid = validatedCompanyInternet.Valid;
                            companyInternet.StatusDescription = validatedCompanyInternet.StatusDescription;
                            companyInternet.Duplicate = true;

                            //validatedCompanyInternet.Duplicate = true;
                            if (!string.IsNullOrEmpty(validatedCompanyInternet.OtherBBIDs))
                            {
                                validatedCompanyInternet.OtherBBIDs += ",";
                            }
                            validatedCompanyInternet.OtherBBIDs += companyInternet.BBID.ToString();


                            if (!companyInternet.Valid)
                            {
                                invalidCompanyCount++;
                            }

                            break;
                        }
                    }

                    if (!validated)
                    {
                        ValidateURL(companyInternet);
                        lvalidatedCompanyInternet.Add(companyInternet);

                        if (!companyInternet.Valid)
                        {
                            invalidCompanyCount++;
                        }
                    }

                }

                foreach (CompanyInternet companyInternet in lcompanyInternet)
                {

                    object[] args = {companyInternet.BBID.ToString(),
                                             companyInternet.URL,
                                             companyInternet.StatusDescription,
                                             companyInternet.ListingStatus,
                                             companyInternet.IndustryType,
                                             companyInternet.Published,
                                             companyInternet.OtherBBIDs};

                    if (((!companyInternet.Valid) ||
                        (companyInternet.URL.StartsWith("http://"))) &&
                        (!companyInternet.Duplicate))
                    {

                        if (Utilities.GetBoolConfigValue("InternetValidationDoubleValidationEnabled", false))
                        {
                            // Double check the state of the web site.
                            // Sometimes we get false negatives.
                            companyInternet.Valid = true;
                            ValidateURL(companyInternet);
                        }


                        if (!companyInternet.Valid)
                        {
                            uniqueInvalidURLCount++;

                            if (companyInternet.IndustryType == "L")
                                outputLumber.Append(string.Format(INVALID_DETAIL, args) + Environment.NewLine);
                            else
                                output.Append(string.Format(INVALID_DETAIL, args) + Environment.NewLine);
                        }



                        if (companyInternet.URL.StartsWith("http://"))
                        {
                            NonBBSiStandardFormattedCount++;
                            args[2] = string.Empty;
                            outputHTTP.Append(string.Format(INVALID_DETAIL, args) + Environment.NewLine);
                        }
                    }


                    if (companyInternet.UnableToConnect)
                    {
                        unableToConnect.Append(string.Format(INVALID_DETAIL, args) + Environment.NewLine);
                    }
                }

                DateTime dtExecutionEndDateTime = DateTime.Now;

                StringBuilder sbMsg = new StringBuilder();
                sbMsg.Append("URLS Validated: " + lcompanyInternet.Count.ToString("###,##0") + Environment.NewLine);
                sbMsg.Append("Non-OK Unique URLs Found: " + uniqueInvalidURLCount.ToString("###,##0") + Environment.NewLine);
                sbMsg.Append("Non-OK Companies Found: " + invalidCompanyCount.ToString("###,##0") + Environment.NewLine);
                sbMsg.Append("Non-BBSi Standard Formatted URL Count: " + NonBBSiStandardFormattedCount.ToString("###,##0") + Environment.NewLine);
                sbMsg.Append(Environment.NewLine);

                TimeSpan tsDiff = dtExecutionEndDateTime.Subtract(dtExecutionStartDate);
                sbMsg.Append("Execution time: " + tsDiff.ToString() + Environment.NewLine);

                if (Utilities.GetBoolConfigValue("InternetValidationWriteResultsToEventLog", true))
                {
                    _oBBSMonitorService.LogEvent(sbMsg.ToString());
                }

                if (output.Length > 0)
                {
                    sbMsg.Append(Environment.NewLine);
                    sbMsg.Append("Produce Non-OK URLs" + Environment.NewLine);
                    object[] headerArgs = {"Company ID",
                                       "URL",
                                       "Status Description",
                                       "Listing Status",
                                       "Industry Type",
                                       "Web Site Published",
                                       "Other BBIDs"};

                    sbMsg.Append(string.Format(INVALID_DETAIL, headerArgs) + Environment.NewLine);
                    sbMsg.Append(output);
                }


                if (outputLumber.Length > 0)
                {
                    sbMsg.Append(Environment.NewLine + Environment.NewLine);
                    sbMsg.Append("Lumber Non-OK URLs" + Environment.NewLine);
                    object[] headerArgs = {"Company ID",
                                       "URL",
                                       "Status Description",
                                       "Listing Status",
                                       "Industry Type",
                                       "Web Site Published",
                                       "Other BBIDs"};

                    sbMsg.Append(string.Format(INVALID_DETAIL, headerArgs) + Environment.NewLine);
                    sbMsg.Append(outputLumber);
                }

                if (unableToConnect.Length > 0)
                {
                    sbMsg.Append(Environment.NewLine + Environment.NewLine);
                    sbMsg.Append("Unable To Connect" + Environment.NewLine);
                    object[] headerArgs = {"Company ID",
                                       "URL",
                                       "Status Description",
                                       "Listing Status",
                                       "Industry Type",
                                       "Web Site Published",
                                       "Other BBIDs"};

                    sbMsg.Append(string.Format(INVALID_DETAIL, headerArgs) + Environment.NewLine);
                    sbMsg.Append(unableToConnect);
                }

                //sbMsg.Append(Environment.NewLine + Environment.NewLine);
                //sbMsg.Append(GetPlatformInfo());
 
                //if (outputHTTP.Length > 0)
                //{
                //    sbMsg.Append(Environment.NewLine);
                //    sbMsg.Append("Non-BBSi Standard Formatted URLs" + Environment.NewLine);
                //    object[] headerArgs = {"Company ID",
                //                           "URL",
                //                           string.Empty,
                //                           "Listing Status",
                //                           "Industry Type",
                //                           "Web Site Published",
                //                           "Other BBIDs"};

                //    sbMsg.Append(string.Format(INVALID_DETAIL, headerArgs) + Environment.NewLine);
                //    sbMsg.Append(outputHTTP);
                //}


                SendMail("InternetValidation Event Success", sbMsg.ToString());
            }
            catch (Exception e)
            {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error Procesing InternetValidation Event.", e);
            }
            finally
            {
                oConn.Close();
            }
        }

        private bool CanExecute(DateTime dtDate)
        {
            int iOccurence = Utilities.GetIntConfigValue("InternetValidationOccurenceInMonth", 2);
            DayOfWeek targetDayOfWeek = (DayOfWeek)Enum.ToObject(typeof(DayOfWeek), 
                                                                 Utilities.GetIntConfigValue("InternetValidationDayOfWeek", 0));

            if (dtDate.DayOfWeek == targetDayOfWeek)
            {
                int iStart = 1 + ((iOccurence - 1) * 7);
                int iEnd = iStart + 6;

                if ((dtDate.Day >= iStart) &&
                    (dtDate.Day <= iEnd))
                {
                    return true;
                }


            }

            return false;
        }

        /// <summary>
        /// Attempts to connect to the specified URL and sets attributes
        /// in the CompanyInternet class to indicate success or failure.
        /// </summary>
        /// <param name="companyInternet"></param>
        private void ValidateURL(CompanyInternet companyInternet)
        {
            ValidateURL(companyInternet, "http://");
        }


        private void ValidateURL(CompanyInternet companyInternet, string protocol)
        {

            string url = null;
            if (companyInternet.URL.StartsWith(protocol))
                url = companyInternet.URL.Replace(protocol, string.Empty);
            else
                url = companyInternet.URL;

            try
            {

                //Create a request for the URL. 
                HttpWebRequest request = (HttpWebRequest)WebRequest.Create(protocol + url);
                request.CookieContainer = new CookieContainer();
                request.Accept = "*/*";
                request.UserAgent = Utilities.GetConfigValue("InternetValidationUserAgent", "Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; rv:11.0) like Gecko");
                request.Timeout = (Utilities.GetIntConfigValue("InternetValidationRequestTimeout", 120) * 1000);
                ServicePointManager.SecurityProtocol |= SecurityProtocolType.Tls | SecurityProtocolType.Tls11 | 
                                                        SecurityProtocolType.Tls12 | SecurityProtocolType.Ssl3;

                //Get the response.
                using (HttpWebResponse response = (HttpWebResponse)request.GetResponse())
                {
                    companyInternet.StatusDescription = response.StatusDescription;
                    if ((response.StatusCode == HttpStatusCode.OK) ||
                        (response.StatusCode == HttpStatusCode.Created) ||
                        (response.StatusCode == HttpStatusCode.NonAuthoritativeInformation) ||
                        (response.StatusCode == HttpStatusCode.Accepted))
                    {
                        companyInternet.Valid = true;
                    }
                    else
                    {
                        companyInternet.Valid = false;
                    }
                }
            }
            catch (Exception e)
            {
                string exceptionMsg = string.Empty;
                Exception eX = e;
                while (eX != null)
                {
                    if (!string.IsNullOrEmpty(exceptionMsg))
                        exceptionMsg += " --> ";

                    exceptionMsg += eX.Message;
                    eX = eX.InnerException;
                }

                if (e.Message == "Unable to connect to the remote server")
                {
                    companyInternet.Valid = true;
                    companyInternet.UnableToConnect = true;
                } else
                {
                    companyInternet.Valid = false;
                }
              
                companyInternet.StatusDescription = "Exception: " + exceptionMsg;

                //// Only try again if we are using a non-secure protocol
                //if ((e.Message == "Unable to connect to the remote server") &&
                //    (protocol == "http://"))
                //{
                //    // Try again using a secure protocol
                //    //ValidateURL(companyInternet, "https://");
                //} else
                //{
                //    companyInternet.Valid = false;
                //    companyInternet.StatusDescription = "Exception: " + e.Message;
                //}
            } finally
            {
                if (protocol == "https://")
                {
                    companyInternet.StatusDescription += " (2nd Attempt)";
                }
            }
        }

        private string GetPlatformInfo()
        {
            StringBuilder platformInfo = new StringBuilder();

            platformInfo.Append("Runtime: " + System.Diagnostics.FileVersionInfo.GetVersionInfo(typeof(int).Assembly.Location).ProductVersion + Environment.NewLine);
            platformInfo.Append("Enabled protocols:   " + ServicePointManager.SecurityProtocol.ToString() + Environment.NewLine);

            platformInfo.Append("Available protocols: " + Environment.NewLine);
            Boolean platformSupportsTls12 = false;
            foreach (SecurityProtocolType protocol in Enum.GetValues(typeof(SecurityProtocolType)))
            {
                platformInfo.Append(protocol.GetHashCode().ToString() + Environment.NewLine);
                if (protocol.GetHashCode() == 3072)
                {
                    platformSupportsTls12 = true;
                }
            }

            platformInfo.Append("Is Tls12 enabled: " + ServicePointManager.SecurityProtocol.HasFlag((SecurityProtocolType)3072).ToString() + Environment.NewLine);

            // enable Tls12, if possible
            if (!ServicePointManager.SecurityProtocol.HasFlag((SecurityProtocolType)3072)){
                if (platformSupportsTls12)
                {
                    platformInfo.Append("Platform supports Tls12, but it is not enabled. Enabling it now." + Environment.NewLine);
                    ServicePointManager.SecurityProtocol |= (SecurityProtocolType)3072;
                }
                else
                {
                    platformInfo.Append("Platform does not supports Tls12." + Environment.NewLine);
                }
            }

            // disable SSL3. Has no negative impact if SSL3 is already disabled
            System.Net.ServicePointManager.SecurityProtocol &= ~SecurityProtocolType.Ssl3;

            platformInfo.Append("Enabled protocols:   " + ServicePointManager.SecurityProtocol.ToString());
            return platformInfo.ToString();
        }
    }

    class CompanyInternet {
        public int BBID;
        public int PersonID;
        public string URL;
        public string URLType;
        public bool Valid = true;
        public string StatusDescription;
        public string ListingStatus;
        public string IndustryType;
        public string Published;
        public string OtherBBIDs = string.Empty;
        public bool Duplicate = false;
        public bool UnableToConnect = false;

        public CompanyInternet(int bbid, int personID, string url, string urlType) {
            BBID = bbid;
            PersonID = personID;
            URL = url;
            URLType = urlType;
        }

        public CompanyInternet(int bbid, int personID, string url, string urlType, string listingStatus, string industryType, string published)
        {
            BBID = bbid;
            PersonID = personID;
            URL = url;
            URLType = urlType;
            ListingStatus = listingStatus;
            IndustryType = industryType;
            Published = published;
        }
    }
}

