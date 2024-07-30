/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2018

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: UserControlBase
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;
using TSI.DataAccess;
using TSI.Utils;

namespace PRCo.EBB.UI.Web {

    /// <summary>
    /// Provides the common functionality needed by the user controls
    /// </summary>
    public class UserControlBase : System.Web.UI.UserControl {

        public IPRWebUser WebUser;
        public ILogger Logger;

        protected const string REF_AD_CAMPAIGN = "AdCampaign {0}";

        protected IDBAccess _oDBAccess;
        protected GeneralDataMgr _oObjectMgr;

        virtual protected void Page_Load(object sender, EventArgs e) {
        }

        /// <summary>
        /// Helper method that returns an EBBObjectMgr object.  This is
        /// cached in a member variable.
        /// </summary>
        /// <returns></returns>
        public GeneralDataMgr GetObjectMgr() {
            if (_oObjectMgr == null) {
                _oObjectMgr = new GeneralDataMgr(GetLogger(), WebUser);
            }
            return _oObjectMgr;
        }

        protected IDBAccess GetDBAccess() {
            if (_oDBAccess == null) {
                _oDBAccess = DBAccessFactory.getDBAccessProvider();
                _oDBAccess.Logger = GetLogger();
            }

            return _oDBAccess;
        }
        
        protected ILogger GetLogger() {
            if (Logger == null) {
                Logger = LoggerFactory.GetLogger();
                if (WebUser != null) {
                    Logger.UserID = WebUser.UserID;
                }
                Logger.RequestName = Request.ServerVariables.Get("SCRIPT_NAME");
            }
            
            return Logger;
        }

        /// <summary>
        /// Log an error to the application log
        /// </summary>
        /// <param name="e"></param>
        protected void LogError(Exception e)
        {
            if (Logger != null)
            {
                Logger.LogError(e);
            }
        }

        static public int IncrementCacheCount(string szCacheName)
        {
            int intCacheCount = 0;

            if (HttpRuntime.Cache[szCacheName] == null)
                intCacheCount = 1;
            else
                intCacheCount = Convert.ToInt32(HttpRuntime.Cache[szCacheName]) + 1;

            HttpRuntime.Cache[szCacheName] = intCacheCount;
            return intCacheCount;
        }

    }
}
