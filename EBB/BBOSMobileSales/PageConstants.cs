/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2007-2022

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: PageConstants.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Contains constants for the EBB page
    /// URLS with paramters.
    /// </summary>
    public class PageConstants
    {
        public const string AUTO_LOGOFF = "Login.aspx?AutoLogoff=true";
        public const string LOGIN = "Login.aspx";
        public const string BBOS_MOBILE_SALES_HOME = "default.aspx";
        public const string COMPANY_SEARCH = "CompanySearch.aspx";
        public const string ERROR = "Error.aspx";
        public const string COMPANY_SEARCH_RESULTS_NEW = "CompanySearchResults.aspx";
        public const string GET_PUBLICATION_FILE = "GetPublicationFile.aspx";
        public const string BBOS_MOBILE_SALES_SESSIONID = "BBOSMobileSales_SessionID";
        public const string SESSION_TRACKER = "SessionTracker";

        /// <summary>
        /// Helper method to format URLs.  The string.Format allows up to three (3) object
        /// parameters before requiring them to be in an array.  This makes for a little
        /// cleaner code.
        /// </summary>
        /// <param name="szURL">URL to format</param>
        /// <param name="oParm1">Parameter 1</param>
        /// <returns></returns>
        public static string Format(string szURL, object oParm1)
        {
            return string.Format(szURL, oParm1);
        }
        public static string FormatFromRoot(string szURL, object oParm1)
        {
            return "~/" + string.Format(szURL, oParm1);
        }
    }
}