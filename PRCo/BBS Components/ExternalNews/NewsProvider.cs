/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc 2010-2011

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: NewsProvider
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using Microsoft.Win32;
using TSI.Utils;

namespace PRCo.BBOS.ExternalNews
{

    abstract public class NewsProvider : INewsProvider
    {

        protected const string CONN_STRING = "server={0};User ID={1};Password={2};Initial Catalog={3};Application Name=ExternalNews";
        protected string action = string.Empty;

        /// <summary>
        /// Helper method that goes through the various locations where we might find
        /// a connection string and returns the first one found.
        /// </summary>
        /// <returns></returns>
        virtual protected string GetConnectionString()
        {
            string szConnection = null;
            if (ConfigurationManager.ConnectionStrings["DBConnectionStringFullRights"] != null)
            {
                szConnection = ConfigurationManager.ConnectionStrings["DBConnectionStringFullRights"].ConnectionString;
                if (!string.IsNullOrEmpty(szConnection))
                {
                    return szConnection;
                }
            }

            szConnection = Utilities.GetConfigValue("DBConnectionString", string.Empty);
            if (!string.IsNullOrEmpty(szConnection))
            {
                return szConnection;
            }


            string szUserID = null;
            string szPassword = null;
            string szServer = null;
            string szDatabase = null;

            RegistryKey regCRM = Registry.LocalMachine;
            regCRM = regCRM.OpenSubKey(@"SOFTWARE\eware\Config");

            szUserID = (string)regCRM.GetValue("BBSDatabaseUserID");
            szPassword = (string)regCRM.GetValue("BBSDatabasePassword");
            regCRM.Close();

            RegistryKey regCRM2 = Registry.LocalMachine;
            regCRM2 = regCRM2.OpenSubKey(@"SOFTWARE\eware\Config\/CRM");

            szDatabase = (string)regCRM2.GetValue("DefaultDatabase");
            szServer = (string)regCRM2.GetValue("DefaultDatabaseServer");
            regCRM2.Close();

            string[] aArgs = { szServer, szUserID, szPassword, szDatabase };

            return string.Format(CONN_STRING, aArgs);
        }


        public virtual string NewsProviderName
        {
            get { throw new ApplicationException("Not Implemented"); }
        }

        /// <summary>
        /// This method is for those news sources that maintain their own list of unique IDs for companies.  
        /// Using the appropriate mechanism, this method should query the news source for the unique ID for 
        /// every Company record that does not already have a record in PRCompanyExternalNews.  For each 
        /// new unique ID found, insert a new record into the PRCompanyExternalNews table.
        /// </summary>
        public virtual void RefreshCodes()
        {
        }

        /// <summary>
        /// Refreshes the news articles for the specified company, honoring the cache
        /// settings, meaning that we only query the external source if the cache time
        /// limit has expired.
        /// </summary>
        /// <param name="companyID"></param>
        public virtual void RefreshCompany(int companyID)
        {

        }

        /// <summary>
        /// Refreshes the news articles for the specified company.
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="overrideCache">If true, then we query the external news source
        /// regardless if the cache time limit has expired. </param>
        public virtual void RefreshCompany(int companyID, bool overrideCache)
        {

        }

        /// <summary>
        /// Refreshes the news articles for the all companies, honoring the cache
        /// settings, meaning that we only query the external source if the cache time
        /// limit has expired.
        /// </summary>        
        public virtual void RefreshAllCompanies()
        {

        }

        /// <summary>
        /// Refreshes the news articles for all companies.
        /// </summary>
        /// <param name="overrideCache">If true, then we query the external news source
        /// regardless if the cache time limit has expired. </param>
        public virtual void RefreshAllCompanies(bool overrideCache)
        {
        }

        /// <summary>
        /// Helper method that writes a formatted message to the log 
        /// buffer.
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="message"></param>
        virtual protected void WriteToLog(int companyID, string message)
        {
            WriteToLog(companyID.ToString() + " " + message);
        }

        protected StringBuilder _sbLog = null;

        /// <summary>
        /// Helper method that writes a message to the log buffer.
        /// </summary>
        /// <param name="message"></param>
        virtual protected void WriteToLog(string message) {

            if (_sbLog == null)
            {
                _sbLog = new StringBuilder();
            }

            _sbLog.Append(message);
            _sbLog.Append(Environment.NewLine);
        }

        private string _szLogPath = null;

        /// <summary>
        /// Helper method that writes the log buffer
        /// to a file on disk.
        /// </summary>
        /// <param name="filename"></param>
        virtual public void WriteLogToFile(string filename)
        {
            if (_szLogPath == null)
            {
                _szLogPath = Utilities.GetConfigValue("NewsProviderLogPath",
                                                      Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location));
            }
            WriteLogToFile(_szLogPath, filename);

        }

        virtual public void WriteLogToFile(string path, string filename)
        {
            if (_sbLog == null)
            {
                return;
            }
            string szOutputFile = Path.Combine(path, DateTime.Now.ToString("yyyyMMdd_HHmmss") + "_" + action + "_" + filename);
            using (StreamWriter sw = new StreamWriter(szOutputFile))
            {
                sw.Write(_sbLog.ToString());
            }
        }

        virtual public StringBuilder GetLog()
        {
            return _sbLog;
        }

        virtual protected object GetStringForDB(string value)
        {
            if (string.IsNullOrEmpty(value))
            {
                return DBNull.Value;
            }

            return value;
        }
    }
}
