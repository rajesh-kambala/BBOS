/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: PageBase
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
using System.Threading;
using System.Globalization;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web.UserManagement {

    /// <summary>
    /// Helper class to generate HTML.  Localization is handled as well.
    /// </summary>
    public class UIUtils {

        /// <summary>
        /// Used to construct hyperlinks
        /// </summary>
        protected const string A_HREF = "<a href=\"{1}\" {2} {3}>{0}</a>";


        /// <summary>
        /// A formatted JavaScript link to ensure the proper syntax is used.
        /// </summary>
        protected const string JS_LINK = "<script type=\"text/javascript\" language=\"JavaScript\" src=\"{0}\"></script>";

        /// <summary>
        /// A formatted CSS link to ensure the proper syntax is used.
        /// </summary>
        protected const string CSS_LINK = "<LINK href=\"{0}\" type=\"text/css\" rel=\"stylesheet\">";

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
        protected static string CSS_DIR = @"css/";

        /// <summary>
        /// JavaScript file containing basic form methods.
        /// </summary>
        public static string JS_FORM_FUNCTIONS_FILE = "formFunctions.js";
        /// <summary>
        /// JavaScript file containing basic form methods.
        /// </summary>
        public static string JS_FORM_FUNCTIONS2_FILE = "formFunctions2.js";
        /// <summary>
        /// JavaScript file containing expand/collapse methods.
        /// </summary>
        public static string JS_TOGGLE_FUNCTIONS_FILE = "toggleFunctions.js";
        /// <summary>
        /// The main application JavaScript file. 
        /// </summary>
        public static string JS_EBB_FILE = "EBB.js";
        /// <summary>
        /// JavaScript file containing form validation methods.
        /// </summary>
        public static string JS_FORM_VALIDATION_FILE = "formValidationFunctions.js";


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
            return GetVirtualPath() + szPath;
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
            return string.Format(CSS_LINK, GetVirtualPath() + CSS_DIR + szFileName);
        }

        /// <summary>
        /// Create a Control object to programatically insert into 
        /// the master page's head section.
        /// </summary>
        /// <param name="szFileName"></param>
        /// <returns></returns>
        public static HtmlGenericControl GetCSSControl(string szFileName) {
            HtmlGenericControl JSLink = new HtmlGenericControl("link");
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
            JSLink.Attributes.Add("language", "javascript");
            JSLink.Attributes.Add("src", GetLocalizedURL(JS_DIR + szFileName));
            return JSLink;
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
                return "Yes";
            } else {
                return "No";
            }
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
        /// <param name="szValue">Value to Convert</param>
        /// <returns>DateTime</returns>
        static public DateTime GetDateTime(string szValue) {
            if ((szValue == null) ||
                (szValue.Trim().Length == 0)) {
                return DateTime.MinValue;
            }
            return DateTime.Parse(szValue);
        }

        static public DateTime GetDateTime(object oValue) {
            if ((oValue == null) ||
                (oValue == DBNull.Value)) {
                return DateTime.MinValue;
            }
            return Convert.ToDateTime(oValue);
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
                szCSSClass = string.Empty;
            }

            if (szTarget == null) {
                szTarget = string.Empty;
            }
            return string.Format(A_HREF, HttpUtility.HtmlEncode(szText), szURL, szCSSClass, szTarget);
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


        /// <summary>
        /// Returns the appropriate row class for
        /// shading.
        /// </summary>
        /// <param name="iCount"></param>
        /// <returns></returns>
        static public string GetRowClass(int iCount) {
            if ((iCount % 2) == 0) {
                return "class=shaderow";
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

            return ((decimal)lSize / (decimal)1024).ToString("###,##0.00") + " KB";
        
            //if (lSize < 1024) {
            //    return lSize.ToString("###,###") + " B";
            //} else if (lSize < 1048576) {
            //    return (lSize/1024).ToString("###,###") + " KB";
            //} else {
            //    return (lSize/1048576).ToString("###,###") + " MB";
            //}
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

    }
}
