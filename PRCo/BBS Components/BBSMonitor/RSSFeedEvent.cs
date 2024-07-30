/***********************************************************************
 Copyright Produce Reporter Company 2006-2022

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: RSSFeedEvent.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Timers;
using TSI.Utils;

namespace PRCo.BBS.BBSMonitor
{

    /// <summary>
    /// Event handler that generates the public RSS feed
    /// and the members only RSS feed.
    /// </summary>
    class RSSFeedEvent : BBSMonitorEvent {

        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex) {
            _szName = "RSSFeedEvent";

            base.Initialize(iIndex);

            try {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("RSSFeedInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("RSSFeed Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("RSSFeedStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("RSSFeed Start: " + _dtNextDateTime.ToString());

            } catch (Exception e) {
                LogEventError("Error initializing RSSFeed event.", e);
                throw;
            }
        }

        protected const string SQL_SELECT_ARTICLES_WP = 
                @"SELECT  
	                CAST(ID as int) AS ArticleID, 
	                post_title as prpbar_Name,
	                post_date AS PublishDate,
	                CASE WHEN post_content LIKE '<p>%' THEN SUBSTRING(post_content, 0, CHARINDEX('</p>', post_content)+4) ELSE SUBSTRING(post_content, 0, PATINDEX('%' + CHAR(13) + CHAR(10) + '%', post_content)) END AS prpbar_Abstract,
	                post_author,
	                Author,
	                Category
                FROM WordPressProduce.dbo.wp_posts WITH (NOLOCK)
		            LEFT OUTER JOIN WordPressProduce.dbo.wp_postmeta WITH (NOLOCK) ON wp_posts.ID = wp_postmeta.post_id AND meta_key = 'associated-companies'
		            CROSS APPLY CRM.dbo.ufn_GetWordPressPostDetails4(ID,'S') wpd 
                WHERE post_type = 'post'
		            AND post_status in('publish')
                    AND id NOT IN (SELECT post_ID FROM WordPressProduce.dbo.wp_postmeta WHERE meta_key = 'blueprintEdition' and meta_value <> 'a:1:{{i:0;a:1:{{s:4:""date"";s:0:"""";}}}}') --exclude blueprintEditions that are default empty value
		            AND post_Date BETWEEN DATEADD(month,{0}, GETDATE()) AND GETDATE()
                    AND post_content is not null
                ORDER BY post_date DESC";

        /// <summary>
        /// Go create the RSS XML files
        /// </summary>
        override public void ProcessEvent() {

            DateTime dtExecutionStartDate = DateTime.Now;

            // Create the public feed
            GenerateRSSFeed(true);
            
            // Create the members feed
            GenerateRSSFeed(false);

            if (Utilities.GetBoolConfigValue("RSSFeedWriteResultsToEventLog", true)) {
                _oBBSMonitorService.LogEvent("RSSFeed Executed Successfully.");
            }

            if (Utilities.GetBoolConfigValue("RSSFeedSendResultsToSupport", false)) {
                SendMail("RSSFeed Success", "RSSFeed Executed Successfully.");
            }
        }
        
        /// <summary>
        /// Generates the RSS XML files and write them
        /// to disk.
        /// </summary>
        /// <param name="bPublic"></param>
        protected void GenerateRSSFeed(bool bPublic)
        {

            int iExpirationMonths = 0 - Utilities.GetIntConfigValue("RSSFeedDefaultMonthsOld", 6);

            string szSQL = string.Format(SQL_SELECT_ARTICLES_WP, iExpirationMonths);

            // The file name and available articles depend
            // upon whether the file is for the public or is
            // for members only.
            string szFileName = "";
            if (bPublic)
            {
                szFileName = Utilities.GetConfigValue("RSSFeedPublicFileName", @"C:\Projects\EBB\EBB\RSS\BBOSRSS.xml");
            }
            else
            {
                szFileName = Utilities.GetConfigValue("RSSFeedMembersFileName", @"C:\Projects\EBB\EBB\RSS\BBOSMembersRSS.xml");
            }

            string szItemTemplate = GetEmailTemplate("RSSItemTemplate.xml");
            string szNewsArticleURL = Utilities.GetConfigValue("RSSFeedNewsArticleURL", "https://apps.bluebookservices.com/bbos/NewsArticleView.aspx?ArticleID={0}");
            string szBluePrintsEditionURL = Utilities.GetConfigValue("RSSFeedBluePrintsEditionURL", "https://apps.bluebookservices.com/bbos/BlueprintsView.aspx?ArticleID={0}");
            string szBBOSURL = Utilities.GetConfigValue("BBOSURL", "https://apps.bluebookservices.com/bbos");
            string szBBOSNewsURL = Utilities.GetConfigValue("RSSBBOSNews", Path.Combine(szBBOSURL, "News.aspx"));

            StringBuilder sbItems = new StringBuilder();
            SqlConnection oConn = new SqlConnection(GetConnectionString());
            try
            {
                oConn.Open();

                // Query for the articles and then build an RSSItem out
                // of each one.  Add the RSSItem to a stringbuilder.
                SqlCommand oSQLCommand = new SqlCommand(szSQL, oConn);
                IDataReader oReader = oSQLCommand.ExecuteReader();
                try
                {
                    while (oReader.Read())
                    {
                        string szGUID = null;
                        if (oReader.GetString(6) == "Produce Blueprints") //Category
                        {
                            szGUID = string.Format(szBluePrintsEditionURL, oReader.GetInt32(0));
                        }
                        else
                        {
                            szGUID = string.Format(szNewsArticleURL, oReader.GetInt32(0));
                        }
                            
                        string[] aArgs = {PrepareString(oReader[1]),
                                          PrepareString(oReader[3]),
                                          oReader.GetDateTime(2).ToString("dd MMM yyyy hh:mm:ss zz00"),
                                          string.Empty,
                                          szGUID};

                        string szItem = string.Format(szItemTemplate, aArgs);
                        sbItems.Append(szItem);
                        sbItems.Append(Environment.NewLine);
                    }
                }
                finally
                {
                    if (oReader != null)
                    {
                        oReader.Close();
                    }
                }

                // Now that we have our items, complete our Channel using the
                // specified template.
                string szChannelTemplate = GetEmailTemplate("RSSChannelTemplate.xml");
                string szRSSFeedImageURL = string.Format("{0}/en-us/images/{1}", szBBOSURL, Utilities.GetConfigValue("RSSFeedImage", "logo-BBS-narrow.png"));
                string szFeed = string.Format(szChannelTemplate, DateTime.Now.Year, szBBOSNewsURL, sbItems.ToString(), szBBOSURL, szRSSFeedImageURL);

                using (StreamWriter oSW = new StreamWriter(szFileName))
                {
                    oSW.Write(szFeed);
                }
            }
            catch (Exception e)
            {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error Procesing RSSFeed Event.", e);
            }
            finally
            {
                if (oConn != null)
                {
                    oConn.Close();
                }

                oConn = null;
            }
        }

        /// <summary>
        /// Helper method that encodes the HTML for inclusion in the XML
        /// feed and also makes sure any references to the ExternalLink
        /// component is fully qualified.
        /// </summary>
        /// <param name="oText"></param>
        /// <returns></returns>
        protected string PrepareString(object oText) {
            if (oText == DBNull.Value) {
                return string.Empty;
            }
            
            string szText = Convert.ToString(oText);
            szText = szText.Replace("href=&quot;ExternalLink.aspx", "href=&quot;" + Utilities.GetConfigValue("BBOSURL") + "ExternalLink.aspx");
            return System.Web.HttpUtility.HtmlEncode(szText);
        }
    }
}