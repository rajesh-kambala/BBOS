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

 ClassName: UIUtils.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Globalization;
using System.Threading;
using System.Web;
using System.Web.UI.HtmlControls;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Helper class to generate HTML.  Localization is handled as well.
    /// </summary>
    public class UIUtils
    {
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
        /// JavaScript file containing form validation methods.
        /// </summary>
        public static string JS_FORM_VALIDATION_FILE = "formValidationFunctions.min.js";

        /// <summary>
        /// Returns the virtual path to the current
        /// application
        /// </summary>
        /// <returns></returns>
        public static string GetVirtualPath()
        {
            return Utilities.GetConfigValue("VirtualPath");
        }

        /// <summary>
        /// Returns the virtual path to the current
        /// application
        /// </summary>
        /// <returns></returns>
        public static string GetVirtualPathLocal()
        {
            return Utilities.GetConfigValue("VirtualPathLocal");
        }

        /// <summary>
        /// Returns the localized URL for the specified path.  Uses the
        /// current thread's CurrentUICulture to determine localization.
        /// </summary>
        /// <param name="szPath"></param>
        /// <returns></returns>
        public static string GetLocalizedURL(string szPath)
        {
            return GetVirtualPath() + Thread.CurrentThread.CurrentUICulture.Name.ToLower() + szPath;
        }

        /// <summary>
        /// Returns the localized URL for the specified path.  Uses the
        /// current thread's CurrentUICulture to determine localization.
        /// </summary>
        /// <param name="szPath"></param>
        /// <returns></returns>
        public static string GetLocalizedURLLocal(string szPath)
        {
            return GetVirtualPathLocal() + Thread.CurrentThread.CurrentUICulture.Name.ToLower() + szPath;
        }

        /// <summary>
        /// Returns the localized URL for the specified image.
        /// </summary>
        /// <param name="szFileName"></param>
        /// <returns></returns>
        public static string GetImageURL(string szFileName)
        {
            return GetLocalizedURLLocal(IMAGE_DIR + szFileName);
        }

        /// <summary>
        /// Create a Control object to programatically insert into 
        /// the master page's head section.
        /// </summary>
        /// <param name="szFileName"></param>
        /// <returns></returns>
        public static HtmlGenericControl GetJavaScriptControl(string szFileName)
        {
            HtmlGenericControl JSLink = new HtmlGenericControl("script");
            JSLink.Attributes.Add("type", "text/javascript");
            JSLink.Attributes.Add("src", GetLocalizedURLLocal(JS_DIR + szFileName));
            return JSLink;
        }

        /// <summary>
        /// Returns an int value formatted for
        /// display.
        /// </summary>
        /// <param name="iValue">Int Value</param>
        /// <returns>String</returns>
        static public string GetStringFromInt(int iValue)
        {
            return GetStringFromInt(iValue, true);
        }

        /// <summary>
        /// Returns an int value formatted for
        /// display.
        /// </summary>
        /// <param name="iValue">Int Value</param>
        /// <param name="bZeroIsBlank">Indicates zero should be returned as a blank</param>
        /// <returns>String</returns>
        static public string GetStringFromInt(int iValue, bool bZeroIsBlank)
        {
            if ((iValue == 0) &&
                (bZeroIsBlank))
            {
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
        static public string GetStringFromDecimal(decimal dValue)
        {
            return GetStringFromDecimal(dValue, false);
        }

        /// <summary>
        /// Returns an decimal value formatted for
        /// display.
        /// </summary>
        /// <param name="dValue">Decimal Value</param>
        /// <param name="bZeroIsBlank">Indicates zero should be returned as a blank</param>
        /// <returns>String</returns>
        static public string GetStringFromDecimal(decimal dValue, bool bZeroIsBlank)
        {
            if ((dValue == 0) &&
                (bZeroIsBlank))
            {
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
        static public string GetStringFromBool(bool bValue)
        {
            if (bValue)
            {
                return Resources.Global.Yes;
            }
            else
            {
                return string.Empty;
            }
        }

        /// <summary>
        /// If a value is found, attempts to create a bool.
        /// Otherwise returns false.
        /// </summary>
        /// <param name="szValue">Value to Convert</param>
        /// <returns>string</returns>
        static public string GetStringFromBool(string szValue)
        {
            if (szValue == "Y")
            {
                return Resources.Global.Yes;
            }
            else
            {
                return string.Empty;
            }
        }

        /// <summary>
        /// If a value is found, attempts to create a bool.
        /// Otherwise returns false.
        /// </summary>
        /// <param name="oValue">Value to Convert</param>
        /// <returns>string</returns>
        static public string GetStringFromBool(object oValue)
        {
            if (oValue == DBNull.Value)
            {
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
        static public string GetString(Object oValue)
        {
            if ((oValue == null) ||
                (oValue == DBNull.Value))
            {
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

        static public DateTime GetDateTime(string szValue)
        {
            CultureInfo m_UsCulture = new CultureInfo(PageBase.ENGLISH_CULTURE);
            return GetDateTime(szValue, m_UsCulture);
        }

        static public DateTime GetDateTime(object oValue, CultureInfo oCulture)
        {
            if ((oValue == null) ||
                (oValue == DBNull.Value))
            {
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
        static public bool GetBool(string szValue)
        {
            if ((szValue == null) ||
                (szValue.Trim().Length == 0))
            {
                return false;
            }

            if (szValue == "Y")
            {
                return true;
            }

            return false;

        }

        static public bool GetBool(object oValue)
        {
            if (oValue == DBNull.Value)
            {
                return false;
            }

            if (oValue == null)
            {
                return false;
            }

            return GetBool((string)oValue);
        }

        /// <summary>
        /// Converts the string value into an Int.
        /// </summary>
        /// <param name="szValue">Value</param>
        /// <returns>Int Value</returns>
        static public int GetInt(string szValue)
        {
            if ((szValue == null) ||
                (szValue.Trim().Length == 0))
            {
                return 0;
            }

            return Convert.ToInt32(szValue.Replace(",", string.Empty));
        }

        /// <summary>
        /// Converts the string value into an Decimal.
        /// </summary>
        /// <param name="szValue">Value</param>
        /// <returns>decimal value</returns>
        static public decimal GetDecimal(string szValue)
        {
            if ((szValue == null) ||
                (szValue.Trim().Length == 0))
            {
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
        public static string GetHyperlink(string szURL, string szText)
        {
            return GetHyperlink(szURL, szText, null, null);
        }

        /// <summary>
        /// Returns a formatted hyperlink.
        /// </summary>
        /// <param name="szURL">URL</param>
        /// <param name="szText">Text</param>
        /// <param name="szCSSClass">Class</param>
        /// <returns></returns>
        public static string GetHyperlink(string szURL, string szText, string szCSSClass)
        {
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
        public static string GetHyperlink(string szURL, string szText, string szCSSClass, string szTarget)
        {
            if (szCSSClass == null)
            {
                szCSSClass = "explicitlink";
            }

            string css = "class=\"" + szCSSClass + "\"";

            if (szTarget == null)
            {
                szTarget = string.Empty;
            }
            return string.Format(A_HREF, HttpUtility.HtmlEncode(szText), szURL, css, szTarget);
        }
    }
}
