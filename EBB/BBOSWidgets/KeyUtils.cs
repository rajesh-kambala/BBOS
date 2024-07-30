/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2012

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: KeyUtils.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;

using TSI.BusinessObjects;
using TSI.DataAccess;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web.Widgets
{
    public class KeyUtils
    {
        protected IDBAccess _oDBAccess;
        protected ILogger _oLogger;

        protected const string SQL_VALIDATE_KEY =
            @"SELECT prwk_WidgetKeyID, prwk_CompanyID, prwk_HostName
                FROM PRWidgetKey WITH (NOLOCK) 
               WHERE prwk_LicenseKey = @Key
                 AND prwk_WidgetTypeCode = @WidgetTypeCode
                 AND prwk_Disabled IS NULL";

        protected const string SQL_UPDATE_KEY =
            @"UPDATE PRWidgetKey 
                 SET prwk_AccessCount = ISNULL(prwk_AccessCount, 0) + 1,
                     prwk_LastAccessDateTime = GETDATE()
               WHERE prwk_WidgetKeyID = @WidgetKeyID";

        private string _szRequestName;

        public bool ValidateKey(string szWidgetTypeCode, string szKey, out int iCompanyID)
        {
            int iWidgetKeyID = 0;
            return ValidateKey(szWidgetTypeCode, szKey, szWidgetTypeCode, out iCompanyID, out iWidgetKeyID);
        }

        public bool ValidateKey(string szWidgetTypeCode, string szKey, string szRequestName, out int iCompanyID, out int iWidgetKeyID)
        {
            _szRequestName = szRequestName;
            GetLogger();

            _oLogger.LogMessage("WidgetTypeCode=" + szWidgetTypeCode);
            _oLogger.LogMessage("Key=" + szKey);

            iCompanyID = 0;
            iWidgetKeyID = 0;
            string cleanedReferrerName = GetRefererHostName();

            // If coming from our own domains, return true.
            if ((cleanedReferrerName.ToLower() == "myserver.local") ||
                (cleanedReferrerName.ToLower() == "localhost") ||
                (cleanedReferrerName.ToLower() == "bluebookservices.com") ||
                (cleanedReferrerName.ToLower() == "producebluebook.com") ||
                (cleanedReferrerName.ToLower() == "lumberbluebook.com") ||
                (cleanedReferrerName.ToLower().EndsWith(".bluebookservices.com"))) {

                iWidgetKeyID = 5000;
                iCompanyID = 100002;

                return true;
            }

            if (string.IsNullOrEmpty(szKey)) {
                LogKeyValidationError("No WidgetKey Specified.");
                return false;
            }

            string szHostName = null;

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("Key", szKey));
            oParameters.Add(new ObjectParameter("WidgetTypeCode", szWidgetTypeCode));

            IDataReader oReader = null;
            try
            {
                oReader = GetDBAccess().ExecuteReader(SQL_VALIDATE_KEY, oParameters, CommandBehavior.CloseConnection, null);
                while (oReader.Read())
                {
                    iWidgetKeyID = oReader.GetInt32(0);
                    iCompanyID = oReader.GetInt32(1);
                    szHostName = oReader.GetString(2);
                }
            }
            catch (Exception e)
            {
                GetLogger().LogError(e);
                return false;
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }

            _oLogger.LogMessage("WidgetKeyID=" + iWidgetKeyID.ToString());

            // Did we find a record for the 
            // key/widget combination?
            if (iWidgetKeyID == 0)
            {
                LogKeyValidationError("Widget Key record not found for WidgetKey '" + szKey + "' and WidgetTypeCode '" + szWidgetTypeCode + "'");
                return false;
            }


            // Temporary work around.  A legitmate site has the Quickfind widget on the home page.
            // sometimes the host name is coming in as empty.  So in that case, just don't valiate
            // the host name.  This is a short-term work-around.
            if (!string.IsNullOrEmpty(cleanedReferrerName))
            {
                string tmpHostName = RemoveHostnamePrefix(szHostName);
                _oLogger.LogMessage("PRWidgetKey.prwk_Hostname=" + szHostName);
                _oLogger.LogMessage("tmpHostName=" + tmpHostName);

                if (cleanedReferrerName != tmpHostName)
                {
                    LogKeyValidationError("Invalid host name found.  Licensed host name: '" + tmpHostName + "', found host name: '" + cleanedReferrerName + "'.");
                    return false;
                }
            }

            try
            {
                oParameters.Clear();
                oParameters.Add(new ObjectParameter("WidgetKeyID", iWidgetKeyID));
                GetDBAccess().ExecuteNonQuery(SQL_UPDATE_KEY, oParameters);
            }
            catch (Exception e)
            {
                GetLogger().LogError(e);
                return false;
            }

            return true;
        }

        protected string GetRefererHostName()
        {
            

            string szReferer = HttpContext.Current.Request.ServerVariables.Get("HTTP_REFERER");

            _oLogger.LogMessage("GetRefererHostName() szReferer=" + szReferer);

            if (string.IsNullOrEmpty(szReferer))
            {
                return string.Empty;
            }

            int iStart = szReferer.IndexOf("://") + 3;
            int iEnd = szReferer.IndexOf("/", iStart);
            if (iEnd == -1)
            {
                iEnd = szReferer.Length;
            }

            string szHostname = szReferer.Substring(iStart, iEnd - iStart);

            return RemoveHostnamePrefix(szHostname);
        }

        protected string RemoveHostnamePrefix(string szHostname)
        {
            if (szHostname.IndexOf(".") != szHostname.LastIndexOf("."))
            {
                szHostname = szHostname.Substring(szHostname.IndexOf(".") + 1);
            }

            _oLogger.LogMessage("RemoveHostnamePrefix() szHostname=" + szHostname);

            return szHostname.ToLower();
        }


        protected void LogKeyValidationError(string szReason)
        {
            if (Utilities.GetBoolConfigValue("WidgetLogKeyValidationErrors", true))
            {
                Exception eX = new ApplicationException(szReason);
                GetLogger().LogError("Widget Key Validation Error", eX);
            }
        }


        /// <summary>
        /// Returns an isntance of a DBAccess
        /// </summary>
        /// <returns></returns>
        protected IDBAccess GetDBAccess()
        {
            if (_oDBAccess == null)
            {
                _oDBAccess = DBAccessFactory.getDBAccessProvider();
                _oDBAccess.Logger = GetLogger();
            }
            return _oDBAccess;
        }

        /// <summary>
        /// Returns an instance of a Logger
        /// </summary>
        /// <returns></returns>
        protected ILogger GetLogger()
        {
            if (_oLogger == null)
            {
                _oLogger = LoggerFactory.GetLogger();
                _oLogger.RequestName = _szRequestName;
            }

            return _oLogger;
        }

    }
}