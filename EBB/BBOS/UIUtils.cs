/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2007-2020

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: UIUtils
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Globalization;
using System.Linq;
using System.Threading;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web {

    /// <summary>
    /// Helper class to generate HTML.  Localization is handled as well.
    /// </summary>
    public class UIUtils {

        /// <summary>
        /// Used to construct hyperlinks
        /// </summary>
        public const string A_HREF = "<a href=\"{1}\" {2} {3}>{0}</a>";


        /// <summary>
        /// A formatted JavaScript link to ensure the proper syntax is used.
        /// </summary>
        public const string JS_LINK = "<script type=\"text/javascript\" src=\"{0}\"></script>";

        /// <summary>
        /// A formatted CSS link to ensure the proper syntax is used.
        /// </summary>
        public const string CSS_LINK = "<link href=\"{0}\" type=\"text/css\" rel=\"stylesheet\" />";

        /// <summary>
        /// The relative directory for the image files.
        /// </summary>
        protected static string IMAGE_DIR = @"/images/";
        protected static string TEMPLATE_DIR = @"/Templates/";

        /// <summary>
        /// The relative directory for the JavaScript files.
        /// </summary>
        protected static string JS_DIR = @"/javascript/";

        /// <summary>
        /// The relative directory for the CSS files.
        /// </summary>
        protected static string CSS_DIR = @"Content/";

        /// <summary>
        /// JavaScript file containing basic form methods.
        /// </summary>
        public static string JS_FORM_FUNCTIONS_FILE = "formFunctions.min.js";
        /// <summary>
        /// JavaScript file containing basic form methods.
        /// </summary>
        public static string JS_FORM_FUNCTIONS2_FILE = "formFunctions2.min.js";
        /// <summary>
        /// JavaScript file containing expand/collapse methods.
        /// </summary>
        public static string JS_TOGGLE_FUNCTIONS_FILE = "toggleFunctions.min.js";
        /// <summary>
        /// The main application JavaScript file. 
        /// </summary>
        public static string JS_BBOS_FILE = "BBOS.min.js";
        /// <summary>
        /// JavaScript file containing form validation methods.
        /// </summary>
        public static string JS_FORM_VALIDATION_FILE = "formValidationFunctions.min.js";
        public static string JS_BOOTSTRAP_FUNCTIONS_FILE = "bootStrapFunctions.min.js";


        /// <summary>
        /// Returns the virtual path to the current
        /// application
        /// </summary>
        /// <returns></returns>
        public static string GetVirtualPath() {
            return Utilities.GetConfigValue("VirtualPath");
        }

        /// <summary>
        /// Returns the localized URL for the specified path.  Uses the
        /// current thread's CurrentUICulture to determine localization.
        /// </summary>
        /// <param name="szPath"></param>
        /// <returns></returns>
        public static string GetLocalizedURL(string szPath) {
            return GetVirtualPath() + Thread.CurrentThread.CurrentUICulture.Name.ToLower() + szPath;
        }


        public static string GetIndustryPath(string szIndustryCode)
        {
            if (szIndustryCode == "L")
            {
                return "Lumber";
            }
            else
            {
                return "Produce";
            }
        }

        /// <summary>
        /// Returns a formatted JS link with the appropriate
        /// virtual path.
        /// </summary>
        /// <param name="szFileName">JavaScript file</param>
        /// <returns>Formatted JS Link</returns>
        public static string GetJavaScriptTag(string szFileName) {
            return string.Format(JS_LINK, GetJavaScriptURL(szFileName));
        }

        /// <summary>
        /// Returns the localized Javascript URL 
        /// for the specified file.
        /// </summary>
        /// <param name="szFileName"></param>
        /// <returns></returns>
        public static string GetJavaScriptURL(string szFileName) {
            return GetLocalizedURL(JS_DIR + szFileName);
        }


        /// <summary>
        /// Returns a formatted CSS link with the appropriate
        /// virtual path.
        /// </summary>
        /// <param name="szFileName">CSS file</param>
        /// <returns>Formatted CSS Link</returns>
        public static string GetCSSTag(string szFileName) {
            string szCSSTag = string.Format(CSS_LINK, GetVirtualPath() + CSS_DIR + szFileName);
            return szCSSTag;
        }

        /// <summary>
        /// Create a Control object to programatically insert into 
        /// the master page's head section.
        /// </summary>
        /// <param name="szFileName"></param>
        /// <returns></returns>
        public static HtmlLink GetCSSControl(string szFileName) {
            //HtmlGenericControl JSLink = new HtmlGenericControl("link");
            HtmlLink JSLink = new HtmlLink();
            JSLink.Attributes.Add("rel", "stylesheet");
            JSLink.Attributes.Add("type", "text/css");
            JSLink.Attributes.Add("href", GetVirtualPath() + CSS_DIR + szFileName);
            return JSLink;
        }


        /// <summary>
        /// Returns a formatted img link with the appropriate
        /// virtual path.
        /// </summary>
        /// <param name="szFileName">image file</param>
        /// <returns>Formatted Image Link</returns>
        public static string GetImageTag(string szFileName) {
            return GetLocalizedURL(GetImageURL(szFileName));
        }

        /// <summary>
        /// Returns the localized URL for the specified image.
        /// </summary>
        /// <param name="szFileName"></param>
        /// <returns></returns>
        public static string GetImageURL(string szFileName) {
            return GetLocalizedURL(IMAGE_DIR + szFileName);
        }

        /// <summary>
        /// Returns the localized URL for the specified template.
        /// </summary>
        /// <param name="szFileName"></param>
        /// <returns></returns>
        public static string GetTemplateURL(string szFileName) {
            return GetLocalizedURL(TEMPLATE_DIR + szFileName);
        }

        /// <summary>
        /// Create a Control object to programatically insert into 
        /// the master page's head section.
        /// </summary>
        /// <param name="szFileName"></param>
        /// <returns></returns>
        public static HtmlGenericControl GetJavaScriptControl(string szFileName) {
            HtmlGenericControl JSLink = new HtmlGenericControl("script");
            JSLink.Attributes.Add("type", "text/javascript");
            JSLink.Attributes.Add("src", GetLocalizedURL(JS_DIR + szFileName));
            return JSLink;
        }


        static public string GetFormattedCurrency(object dValue)
        {
            if ((dValue == DBNull.Value) ||
                (dValue == null))
            {
                return string.Empty;
            }
            return GetFormattedCurrency((decimal)dValue, 0);
        }

        /// <summary>
        /// Formats the decimal into a currency format for
        /// display.
        /// </summary>
        /// <param name="dValue">Value</param>
        /// <returns>Formatted for Currency</returns>
        static public string GetFormattedCurrency(decimal dValue) {
            if (dValue == 0) {
                return string.Empty;
            }
            return dValue.ToString("c");
        }

        /// <summary>
        /// Formats the decimal into a currency format for
        /// display.
        /// </summary>
        /// <param name="dValue">Value</param>
        /// <param name="dDefault"></param>
        /// <returns>Formatted for Currency</returns>
        static public string GetFormattedCurrency(decimal dValue, decimal dDefault) {
            if (dValue == 0) {
                return dDefault.ToString("c");
            }
            return dValue.ToString("c");
        }

        /// <summary>
        /// Formats the int for display.
        /// </summary>
        /// <param name="iValue">Int value</param>
        /// <returns></returns>
        static public string GetFormattedInt(int iValue) {
            return GetFormattedInt(iValue, "0");
        }

        /// <summary>
        /// Formats the int for display with the specified default
        /// value if the specified value is zero (0).
        /// </summary>
        /// <param name="iValue">Int value</param>
        /// <param name="szDefaultValue">Default Value</param>
        /// <returns></returns>
        static public string GetFormattedInt(int iValue, string szDefaultValue) {
            if (iValue == 0) {
                return szDefaultValue;
            }

            return iValue.ToString("###,###,###,##0");
        }

        static public string GetFormattedDecimal(object dValue, int iDecimals)
        {
            if ((dValue == DBNull.Value) ||
                (dValue == null))
            {
                return string.Empty;
            }

            return GetFormattedDecimal((decimal)dValue, iDecimals);
        }

        /// <summary>
        /// Formats the Decimal for display with the default format.
        /// </summary>
        /// <param name="dValue">Decimal value</param>
        /// <returns></returns>
        static public string GetFormattedDecimal(decimal dValue) {
            return GetFormattedDecimal(dValue, 3);
        }

        /// <summary>
        /// Formats the Decimal for Decimal with the specified format.
        /// </summary>
        /// <param name="dValue">Decimal value</param>
        /// <param name="iDecimals">Number of decimals</param>
        /// <returns></returns>
        static public string GetFormattedDecimal(decimal dValue, int iDecimals) {
            return GetFormattedDecimal(dValue, iDecimals, "0");
        }

        /// <summary>
        /// Formats the Decimal for Decimal with the specified format.
        /// </summary>
        /// <param name="dValue">Decimal value</param>
        /// <param name="iDecimals">Number of decimals</param>
        /// <param name="szDefaultValue">Returns the default value if the value is zero</param>
        /// <returns></returns>
        static public string GetFormattedDecimal(decimal dValue, int iDecimals, string szDefaultValue) {
            if (dValue == 0) {
                return szDefaultValue;
            }

            return Math.Round(dValue, iDecimals).ToString();
        }

        /// <summary>
        /// Returns an int value formatted for
        /// display.
        /// </summary>
        /// <param name="iValue">Int Value</param>
        /// <returns>String</returns>
        static public string GetStringFromInt(int iValue) {
            return GetStringFromInt(iValue, true);
        }

        /// <summary>
        /// Returns an int value formatted for
        /// display.
        /// </summary>
        /// <param name="iValue">Int Value</param>
        /// <param name="bZeroIsBlank">Indicates zero should be returned as a blank</param>
        /// <returns>String</returns>
        static public string GetStringFromInt(int iValue, bool bZeroIsBlank) {
            if ((iValue == 0) &&
                (bZeroIsBlank)) {
                return string.Empty;
            }
            return iValue.ToString();
        }

        /// <summary>
        /// Returns an decimal value formatted for
        /// display.
        /// </summary>
        /// <param name="dValue">Decimal Value</param>
        /// <returns>String</returns>
        static public string GetStringFromDecimal(decimal dValue) {
            return GetStringFromDecimal(dValue, false);
        }

        /// <summary>
        /// Returns an decimal value formatted for
        /// display.
        /// </summary>
        /// <param name="dValue">Decimal Value</param>
        /// <param name="bZeroIsBlank">Indicates zero should be returned as a blank</param>
        /// <returns>String</returns>
        static public string GetStringFromDecimal(decimal dValue, bool bZeroIsBlank) {
            if ((dValue == 0) &&
                (bZeroIsBlank)) {
                return string.Empty;
            }
            return dValue.ToString();
        }

        /// <summary>
        /// If a value is found, attempts to create a bool.
        /// Otherwise returns false.
        /// </summary>
        /// <param name="bValue">Value to Convert</param>
        /// <returns>string</returns>
        static public string GetStringFromBool(bool bValue) {
            if (bValue) {
                return Resources.Global.Yes;
            } else {
                return string.Empty;
            }
        }

        /// <summary>
        /// If a value is found, attempts to create a bool.
        /// Otherwise returns false.
        /// </summary>
        /// <param name="szValue">Value to Convert</param>
        /// <returns>string</returns>
        static public string GetStringFromBool(string szValue) {
            if (szValue == "Y") {
                return Resources.Global.Yes;
            } else {
                return string.Empty;
            }
        }

        /// <summary>
        /// If a value is found, attempts to create a bool.
        /// Otherwise returns false.
        /// </summary>
        /// <param name="oValue">Value to Convert</param>
        /// <returns>string</returns>
        static public string GetStringFromBool(object oValue) {
            if (oValue == DBNull.Value) {
                return string.Empty;
            }
        
            return GetStringFromBool((string)oValue);
        }


        static public string GetStringFromBoolYN(object oValue)
        {
            if (oValue == DBNull.Value)
            {
                return Resources.Global.No;
            }

            return GetStringFromBoolYN((string)oValue);
        }

        static public string GetStringFromBoolYN(string szValue)
        {
            if (szValue == "Y")
            {
                return Resources.Global.Yes;
            }
            else
            {
                return Resources.Global.No;
            }
        }

        /// <summary>
        /// Returns the appropriate string value from the
        /// object in the mm/dd/yyyy format.
        /// </summary>
        /// <param name="oValue">The value to evaluate</param>
        /// <returns>String representation of DateTime</returns>
        static public string GetStringFromDate(Object oValue)
        {
            return GetStringFromDate(oValue, string.Empty);
        }


        static public string GetStringFromDate2DigitYear(Object oValue)
        {
            return GetStringFromDate(oValue, string.Empty, "MM/dd/yy");
        }

        /// <summary>
        /// Returns the appropriate string value from the
        /// object in the specified format.
        /// </summary>
        /// <param name="oValue">The value to evaluate</param>
        /// <param name="szDefault">The value to return if NULL</param>
        /// <returns>String representation of DateTime</returns>
        static public string GetStringFromDate(Object oValue, string szDefault)
        {
            return GetStringFromDateTime(oValue, szDefault, "d");
        }

        static public string GetStringFromDate(Object oValue, string szDefault, string format)
        {
            return GetStringFromDateTime(oValue, szDefault, format);
        }

        /// <summary>
        /// Formats the DateTime into a string.
        /// </summary>
        /// <param name="oValue">The value to evaluate</param>
        /// <returns>String representation of DateTime</returns>
        static public String GetStringFromDateTime(Object oValue)
        {
            return GetStringFromDateTime(oValue, string.Empty);
        }

        /// <summary>
        /// Formats the DateTime into a string.
        /// </summary>
        /// <param name="oValue">The value to evaluate</param>
        /// <param name="szDefault">Default value if null</param>
        /// <returns>String representation of DateTime</returns>
        static public String GetStringFromDateTime(Object oValue, string szDefault)
        {
            return GetStringFromDateTime(oValue, szDefault, "g");
        }


        /// <summary>
        /// Returns the appropriate string value from the
        /// object in the specified format.
        /// </summary>
        /// <param name="oValue">The value to evaluate</param>
        /// <param name="szFormat">The format to use</param>
        /// <param name="szDefault">The value to return if NULL</param>
        /// <returns>String representation of DateTime</returns>
        static public string GetStringFromDateTime(Object oValue, string szDefault, string szFormat)
        {
            if ((oValue == null) ||
                 (oValue.ToString().Length == 0))
            {
                return szDefault;
            }

            DateTime dtValue = (DateTime)oValue;

            // HACK: Using DateTime.MinValue instead of NULL.
            if (dtValue.Equals(DateTime.MinValue))
            {
                return szDefault;
            };

            return dtValue.ToString(szFormat);
        }

        /// <summary>
        /// If a value is found, return a string.  
        /// Otherwise return an empty string.
        /// </summary>
        /// <param name="oValue">Value</param>
        /// <returns>HTML Encoded Value</returns>
        static public string GetString(Object oValue) {
            if ((oValue == null) ||
                (oValue == DBNull.Value)) {
                return string.Empty;
            }

            return HttpUtility.HtmlEncode(oValue.ToString());
        }

        /// <summary>
        /// If a value is found, attempts to create a DateTime.
        /// Otherwise returns the DateTime.MinValue (hack).
        /// </summary>
        static public DateTime GetDateTime(string szValue, CultureInfo oCulture)
        {
            if ((szValue == null) ||
                (szValue.Trim().Length == 0))
            {
                return DateTime.MinValue;
            }
            return DateTime.Parse(szValue, oCulture);
        }

        static public DateTime GetDateTime(string szValue) {
            CultureInfo m_UsCulture = new CultureInfo(PageBase.ENGLISH_CULTURE);
            return GetDateTime(szValue, m_UsCulture);
        }

        static public DateTime GetDateTime(object oValue, CultureInfo oCulture) {
            if ((oValue == null) ||
                (oValue == DBNull.Value)) {
                return DateTime.MinValue;
            }
            return Convert.ToDateTime(oValue, oCulture);
        }

        static public DateTime GetDateTime(object oValue)
        {
            CultureInfo m_UsCulture = new CultureInfo(PageBase.ENGLISH_CULTURE);
            return GetDateTime(oValue, m_UsCulture);
        }

        /// <summary>
        /// If a value is found, attempts to create a bool.
        /// Otherwise returns false.
        /// </summary>
        /// <param name="szValue">Value to Convert</param>
        /// <returns>bool</returns>
        static public bool GetBool(string szValue) {
            if ((szValue == null) ||
                (szValue.Trim().Length == 0)) {
                return false;
            }

            if (szValue == "Y") {
                return true;
            }

            return false;

        }

        static public bool GetBool(object oValue) {
            if (oValue == DBNull.Value) {
                return false;
            }
            
            if (oValue == null) {
                return false;
            }
            
            return GetBool((string)oValue);
        }

        /// <summary>
        /// Converts the string value into an Int.
        /// </summary>
        /// <param name="szValue">Value</param>
        /// <returns>Int Value</returns>
        static public int GetInt(string szValue) {
            if ((szValue == null) ||
                (szValue.Trim().Length == 0)) {
                return 0;
            }

            return Convert.ToInt32(szValue.Replace(",", string.Empty));
        }

        /// <summary>
        /// Converts the string value into an Decimal.
        /// </summary>
        /// <param name="szValue">Value</param>
        /// <returns>decimal value</returns>
        static public decimal GetDecimal(string szValue) {
            if ((szValue == null) ||
                (szValue.Trim().Length == 0)) {
                return 0.0M;
            }
            return decimal.Parse(szValue);
        }

        /// <summary>
        /// Returns a formatted hyperlink.
        /// </summary>
        /// <param name="szURL">URL</param>
        /// <param name="szText">Text</param>
        /// <returns></returns>
        public static string GetHyperlink(string szURL, string szText) {
            return GetHyperlink(szURL, szText, null, null);
        }

        /// <summary>
        /// Returns a formatted hyperlink.
        /// </summary>
        /// <param name="szURL">URL</param>
        /// <param name="szText">Text</param>
        /// <param name="szCSSClass">Class</param>
        /// <returns></returns>
        public static string GetHyperlink(string szURL, string szText, string szCSSClass) {
            return GetHyperlink(szURL, szText, szCSSClass, null);
        }

        /// <summary>
        /// Returns a formatted hyperlink.
        /// </summary>
        /// <param name="szURL">URL</param>
        /// <param name="szText">Text</param>
        /// <param name="szCSSClass">Class</param>
        /// <param name="szTarget">Target Window for Hyperlink</param>
        /// <returns></returns>
        public static string GetHyperlink(string szURL, string szText, string szCSSClass, string szTarget) {
            if (szCSSClass == null) {
                szCSSClass = "explicitlink";
            }

            string css = "class=\"" + szCSSClass + "\"";

            if (szTarget == null) {
                szTarget = string.Empty;
            }
            return string.Format(A_HREF, HttpUtility.HtmlEncode(szText), szURL, css, szTarget);
        }


        /// <summary>
        /// Helper method that returns the class name
        /// to shade the row.  If no shade is needed,
        /// and empty string is returned.
        /// </summary>
        /// <param name="iIndex"></param>
        /// <returns></returns>
        public static string GetShadeClass(int iIndex) {
            if ((iIndex % 2) == 0) {
                return " class=shaderow ";
            } else {
                return string.Empty;
            }
        }


        protected const string ADOBE_IMAGE = "<div align=\"center\"><a href=\"{0}\" target=\"_blank\"><img src=\"{1}\" border=\"0\" alt=\"{2}\" /></a></div>";
        /// <summary>
        /// Helper method that returns an "Get Adobe Reader" image
        /// hyperlinked to the Adobe web site.
        /// </summary>
        /// <returns></returns>
        static public string GetAdobeReaderImage() {
            return string.Format(ADOBE_IMAGE, Utilities.GetConfigValue("AdobeReaderURL", "http://www.adobe.com/"), UIUtils.GetImageURL("get_adobe_reader.gif"), Resources.Global.GetAdobeReader);
        }

        /// <summary>
        /// Returns the appropriate row class for
        /// shading.
        /// </summary>
        /// <param name="iCount"></param>
        /// <returns></returns>
        static public string GetRowClass(int iCount) {
            if ((iCount % 2) == 0) {
                return "class=\"shaderow\"";
            }
            return string.Empty;
        }

        /// <summary>
        /// Returns the approprite image URL for the
        /// specified file's extenstion
        /// </summary>
        /// <param name="szFileName"></param>
        /// <returns></returns>
        public static string GetFileIcon(string szFileName) {

            string szIconName = string.Empty;
            if (szFileName.ToLower().EndsWith(".pdf")) {
                szIconName = "fileicon-pdf.gif";
            } else if (szFileName.ToLower().EndsWith(".txt")) {
                szIconName = "fileicon-text.gif";
            } else if (szFileName.ToLower().EndsWith(".zip")) {
                szIconName = "fileicon-compressed.gif";
            } else {
                szIconName = "fileicon-binary.gif";
            }

            return UIUtils.GetImageURL(szIconName);
        }
        
        /// <summary>
        /// Returns a formatted string for the file
        /// size.
        /// </summary>
        /// <param name="lSize"></param>
        /// <returns></returns>
        public static string GetFileSize(long lSize) {

            return ((decimal)lSize / (decimal)1024).ToString("###,##0") + " KB";
        }

        /// <summary>
        /// Truncates the specified string at the closest space between
        /// words up to the specified text limit.  Addes elipses (...) if
        /// the text was truncated.
        /// </summary>
        /// <param name="szText"></param>
        /// <param name="iTextLimit"></param>
        /// <returns></returns>
        static public string TruncateString(string szText, int iTextLimit) {

            if ((string.IsNullOrEmpty(szText)) ||
                (szText.Length <= iTextLimit)) {
                return szText;
            }

            int iSpaceIndex = szText.Substring(0, iTextLimit).LastIndexOf(' ');
            return szText.Substring(0, iSpaceIndex) + "...";
        }

        /// <summary>
        /// Returns an HTML link tag for the page header that describes the RSS
        /// feed.  This allows IE7's auto-discovery button to find the feed.
        /// </summary>
        /// <returns></returns>
        static public HtmlLink GetRSSAutoDiscoverLink() {
            //HtmlGenericControl oRSSLink = new HtmlGenericControl();
            HtmlLink oRSSLink = new HtmlLink();
            //oRSSLink.TagName = "link";
            oRSSLink.Attributes.Add("rel", "alternate");
            oRSSLink.Attributes.Add("type", "application/rss+xml");
            oRSSLink.Attributes.Add("title", Resources.Global.RSSFeedTitle);
            return oRSSLink;
        }        
        
        static public string GetWebsiteURL(string szPageName) {
            if (string.IsNullOrEmpty(szPageName)) {
                return "#";
            }
            return Configuration.WebSiteHome + szPageName;
        }

        static public int GetGridViewColumnIndex(string strColumnName, GridView oGrid)
        {
            for (int i = 0; i < oGrid.Columns.Count; i++)
            {
                if (oGrid.Columns[i].HeaderText == strColumnName)
                    return i;
            }

            return -1; //column wasn't found
        }

        /// <summary>
        /// Method to safely try to get a databound container item string
        /// and safely avoid runtime errors in case the requested item doesn't
        /// exist in the container
        /// </summary>
        /// <param name="container"></param>
        /// <param name="expression"></param>
        /// <returns></returns>
        public static string DataBinderEval_String(object container, string expression)
        {
            string x;

            try
            {
                x = (string)DataBinder.Eval(container, expression);
            }
            catch
            {
                x = "";
            }
            return x;
        }

        /// Method to safely try to get a databound container item int
        /// and safely avoid runtime errors in case the requested item doesn't
        /// exist in the container
        public static int DataBinderEval_Int(object container, string expression)
        {
            int x;

            try
            {
                x = Convert.ToInt32(DataBinder.Eval(container, expression));
            }
            catch
            {
                x = 0;
            }
            return x;
        }
    }
}
