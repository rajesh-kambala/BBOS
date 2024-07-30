/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2011-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
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
using System.Collections;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Text;
using System.Text.RegularExpressions;
using Newtonsoft.Json.Linq;
using System.Net;

using TSI.Utils;
using TSI.Arch;
using TSI.DataAccess;
using TSI.BusinessObjects;

using PRCo.EBB.BusinessObjects;
using PRCo.EBB.Util;
using System.IO;

namespace PRCo.BBOS.UI.Web.PublicProfiles
{
    /// <summary>
    /// Provides common functionality for all Code-Behind pages
    /// in the application.
    /// </summary>
    public class PageBase : System.Web.UI.Page
    {
    
        /// <summary>
        /// Prefix used to mark reference data in the cache
        /// </summary>
        protected const string REF_DATA_PREFIX = "RefData";
        protected const string REF_DATA_NAME = REF_DATA_PREFIX + "_{0}_{1}";

        /// <summary>
        /// The Logger this page should use.
        /// </summary>
        protected ILogger _oLogger = null;

        protected GeneralDataMgr _oObjectMgr;
        protected IDBAccess _oDBAccess;

        /// <summary>
        /// Data manager instance for our lookup codes.
        /// </summary>
        static protected Custom_CaptionMgr _oCustom_CaptionMgr = null;

        /// <summary>
        /// Generic counter used when building custom display constructs
        /// with a repeater.
        /// </summary>
        protected int _iRepeaterCount;
        protected int _iRepeaterRowCount = 1;

        /// <summary>
        /// Provides common functionality for all pages
        /// in the application.
        /// </summary>
        public PageBase() { }

        virtual protected void Page_PreInit(object sender, EventArgs e)
        {
            if (GetIndustryType() == "P")
            {
                this.MasterPageFile = "~/Produce.Master";
            }
        }

        /// <summary>
        /// Initialize the component
        /// </summary>
        /// <param name="e"></param>
        override protected void OnInit(EventArgs e)
        {
            base.OnInit(e);

            // Setup our Global Error Handler
            this.Error += new System.EventHandler(this.OnError);
        }

        /// <summary>
        /// Fires off when the page is about to render.
        /// </summary>
        /// <param name="e"></param>
        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);
            PreparePageFooter();
        }

        /// <summary>
        /// Writes a message to the application log.
        /// </summary>
        /// <param name="szMessage"></param>
        protected void LogMessage(string szMessage)
        {
            if (_oLogger != null)
            {
                _oLogger.LogMessage(szMessage);
            }
        }

        /// <summary>
        /// Writes the message to the application log
        /// with the specified trace level.
        /// </summary>
        /// <param name="szMessage"></param>
        /// <param name="iTraceLevel"></param>
        protected void LogMessage(string szMessage, int iTraceLevel)
        {
            if (_oLogger != null)
            {
                _oLogger.LogMessage(szMessage, iTraceLevel);
            }
        }

        /// <summary>
        /// Log an error to the application log
        /// </summary>
        /// <param name="e"></param>
        protected void LogError(Exception e)
        {
            if (_oLogger != null)
            {
                _oLogger.LogError(e);
            }
        }

        protected void LogError(Exception e, string szAdditionalInformation) {
            if (_oLogger != null) {
                _oLogger.LogError(null, e, szAdditionalInformation);
            }
        }

        /// <summary>
        /// Set the response.cache so that our 
        /// page is in no way cached.
        /// </summary>
        virtual protected void SetCacheOptions()
        {
            HttpCachePolicy oCachePolicy = Response.Cache;
            oCachePolicy.SetCacheability(HttpCacheability.NoCache);
            oCachePolicy.SetExpires(DateTime.Now.AddYears(-1));
            oCachePolicy.SetNoServerCaching();
            oCachePolicy.SetNoStore();
        }

        protected DateTime dtRequestStart;

        /// <summary>
        /// Provides base page_load functionality in populating various
        /// member variables including logging and the current user.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected virtual void Page_Load(object sender, System.EventArgs e)
        {
            dtRequestStart = DateTime.Now;
            SetCacheOptions();

            if (Session["Logger"] == null)
            {
                throw new ApplicationUnexpectedException("Logger Object Not Found in Session");
            }

            // Setup our Tracing Provider
            _oLogger = (ILogger)Session["Logger"];
            _oLogger.RequestName = Request.ServerVariables.Get("SCRIPT_NAME");

            LogMessage("Page_Load");
        }

        /// <summary>
        /// Determine if the current user is
        /// authorized to view this page.
        /// Should be overridden by all sub-classes
        /// </summary>
        /// <returns></returns>
        virtual protected bool IsAuthorizedForPage()
        {
            return false;
        }

        /// <summary>
        /// Ensures the Company/Person data being referenced is “listed”.
        /// Should be overridden by all sub-classes.
        /// </summary>
        /// <returns></returns>
        virtual protected bool IsAuthorizedForData()
        {
            return false;
        }

        /// <summary>
        /// The default error handler for the application.  Only
        /// unexpected errors should make it this far.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void OnError(object sender, System.EventArgs e)
        {
            // Transfer to Error.aspx to handle the appropriate display.
            Server.Transfer("Error.aspx");
        }

        /// <summary>
        /// Returns a formatted error table.
        /// </summary>
        /// <param name="szBoxTitle">Title of the error table</param>
        /// <param name="szMsg">Message to display</param>
        /// <param name="bDisplayButtons"></param>
        /// <returns>Formatted html table for display</returns>
        protected string GetFormattedErrorDisplay(string szBoxTitle,
                                                  string szMsg,
                                                  bool bDisplayButtons)
        {
            StringBuilder sbBuffer = new StringBuilder();

            sbBuffer.Append("<p>" + Environment.NewLine);
            sbBuffer.Append("<div>" + Environment.NewLine);

            sbBuffer.Append("<table width=\"500px\" style=\"border: 1px outset #C0C0C0;\" align=\"center\" cellspacing=\"0\" cellpadding=\"0\">" + Environment.NewLine);
            sbBuffer.Append("<tr><td class=\"errorHeader\">" + szBoxTitle + "</td></tr>" + Environment.NewLine);
            sbBuffer.Append("<tr><td class=\"errorMessage\">" + Environment.NewLine);

            sbBuffer.Append(szMsg + Environment.NewLine);

            if (bDisplayButtons)
            {
                sbBuffer.Append("<br/>&nbsp;<div align=\"right\">" + Environment.NewLine);
                sbBuffer.Append("<input type=\"button\" value=\"Previous Page\" onclick=\"history.go(-1);\" style=\"width:100px;\">" + Environment.NewLine);
                sbBuffer.Append("&nbsp;<input type=\"button\" value=\"Home\" onclick=\"location.href='default.aspx';\" style=\"width:100px;\">" + Environment.NewLine);
            }

            sbBuffer.Append("</div>" + Environment.NewLine);
            sbBuffer.Append("</td></tr>" + Environment.NewLine);
            sbBuffer.Append("</table>" + Environment.NewLine);
            sbBuffer.Append("</div>&nbsp;</p>" + Environment.NewLine);

            return sbBuffer.ToString();
        }

        /// <summary>
        /// Generates the default page footer displaying the
        /// specified message and specified user ID.
        /// </summary>
        /// <returns>HTML Code</returns>
        virtual public void PreparePageFooter()
        {
            if (Master != null)
            {

               Literal litFooterDuration = ((Literal)Master.FindControl("litFooterDuration"));
                if (litFooterDuration != null)
                {
                    DateTime dtRequestEnd = DateTime.Now;
                    TimeSpan oTS = dtRequestEnd.Subtract(dtRequestStart);
                    litFooterDuration.Text = oTS.TotalMilliseconds.ToString();
                }
            }
        }

 
        /// <summary>
        /// Retrieves the lookup value based on the specified
        /// lookup code.
        /// </summary>
        /// <param name="szRefDataType">Reference Data Type</param>
        /// <param name="iRefDataCode">Reference Data Code</param>
        /// <returns>Reference Data Value</returns>
        public string GetReferenceValue(object szRefDataType, object iRefDataCode)
        {
            return GetReferenceValue(Convert.ToString(szRefDataType), Convert.ToString(iRefDataCode));
        }

        /// <summary>
        /// Retrieves the lookup value based on the specified
        /// lookup code.
        /// </summary>
        /// <param name="szRefDataType">Reference Data Type</param>
        /// <param name="szRefDataCode">Reference Data Code</param>
        /// <returns>Reference Data Value</returns>
        public string GetReferenceValue(string szRefDataType, string szRefDataCode)
        {

            if (string.IsNullOrEmpty(szRefDataCode))
            {
                return "Unknown";
            }

            IBusinessObjectSet osRefData = GetReferenceData(szRefDataType);
            foreach (ICustom_Caption oLC in osRefData)
            {
                if (oLC.Code == szRefDataCode)
                {
                    return oLC.Meaning;
                }
            }

            throw new ApplicationUnexpectedException("Unable to find meaning for code - " + szRefDataType + ":" + szRefDataCode);
        }

        /// <summary>
        /// Formats a boolean for end-user
        /// display
        /// </summary>
        /// <param name="bValue"></param>
        /// <returns></returns>
        public static string BoolToString(bool bValue)
        {
            if (bValue)
            {
                return "Yes";
            }
            else
            {
                return "No";
            }
        }

        /// <summary>
        /// Returns the appropriate string value from the object
        /// </summary>
        /// <param name="oValue">The value to evaluate</param>
        /// <returns>String representation or emptystring if null</returns>
        static public string GetString(Object oValue)
        {
            if ((oValue == null) ||
                (oValue.ToString().Length == 0))
            {
                return string.Empty;
            }
            else
                return (string)oValue;
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
        /// Formats text for HTML by replacing CR (Char(10))
        ///  w/&gt;BR&lt; and spaces with nbsp;
        /// </summary>
        /// <param name="szText">Input Text</param>
        /// <returns>HTML Formatted Text</returns>
        static public string FormatTextForHTML(string szText)
        {
            if ((szText == null) ||
                (szText.Length == 0))
            {
                return "&nbsp;";
            }

            szText = HttpUtility.HtmlEncode(szText);
            szText = szText.Replace("\r\n", "<br/>");
            szText = szText.Replace("  ", " &nbsp;");

            return szText;
        }




        /// <summary>
        /// Formats the query string parameters into a name
        /// value pair for display.
        /// </summary>
        /// <returns>Formatted Parameters</returns>
        protected string FormatQueryStringParms(bool bAddLineBreak)
        {

            StringBuilder sbParms = new StringBuilder();
            foreach (string szKey in Request.QueryString.Keys)
            {
                if (sbParms.Length > 0)
                {
                    sbParms.Append("&");
                }
                sbParms.Append(szKey);
                sbParms.Append("=");

                if (szKey.ToLower().Contains("password"))
                    sbParms.Append("*****");
                else
                {
                    if(Request.Params[szKey] != null)
                        sbParms.Append(Request.Params[szKey].ToString());
                }

                if (bAddLineBreak)
                {
                    sbParms.Append(Environment.NewLine);
                }
            }

            return sbParms.ToString();
        }


        /// <summary>
        /// Bind the specified collection to the specified 
        /// list.
        /// </summary>
        /// <param name="oList">List Control</param>
        /// <param name="oCollection">Collection to Bind</param>
        static public void BindLookupValues(ListControl oList,
                                            ICollection oCollection)
        {
            BindLookupValues(oList, oCollection, null);
        }

        /// <summary>
        /// Bind the specified collection to the specified 
        /// list.
        /// </summary>
        /// <param name="oList">List Control</param>
        /// <param name="oCollection">Collection to Bind</param>
        /// <param name="bAddSelectOneItem">Indicator to add a "select one" option</param>
        static public void BindLookupValues(ListControl oList,
                                            ICollection oCollection,
                                            bool bAddSelectOneItem)
        {
            BindLookupValues(oList, oCollection, null, bAddSelectOneItem);
        }

        /// <summary>
        /// Bind the specified collection to the specified 
        /// list setting the specified values as the currently
        /// selected value.
        /// </summary>
        /// <param name="oList">List Control</param>
        /// <param name="oCollection">Collection to Bind</param>
        /// <param name="szSelectedValue">Current Value</param>
        static public void BindLookupValues(ListControl oList,
                                            ICollection oCollection,
                                            string szSelectedValue)
        {
            BindLookupValues(oList, oCollection, szSelectedValue, false);
        }

        /// <summary>
        /// Binds the specified collection to the specified list, setting
        /// the specified value as the default optionally adding a 
        /// "select one" item.
        /// </summary>
        /// <param name="oList">List Control</param>
        /// <param name="oCollection">Collection to Bind</param>
        /// <param name="szSelectedValue">Current Value</param>
        /// <param name="bAddSelectOneItem">Indicator to add a "select one" option</param>
        static public void BindLookupValues(ListControl oList,
                                            ICollection oCollection,
                                            string szSelectedValue,
                                            bool bAddSelectOneItem)
        {
            oList.DataSource = oCollection;
            oList.DataTextField = "Meaning";
            oList.DataValueField = "Code";
            oList.DataBind();

            if (bAddSelectOneItem)
            {
                oList.Items.Insert(0, new ListItem(string.Empty, string.Empty));
            }

            if ((szSelectedValue != null) &&
                (szSelectedValue.Length > 0))
            {
                SetListDefaultValue(oList, szSelectedValue);
            }
        }

        /// <summary>
        /// Set the SelectedIndex on the specified control to
        /// the index that corresponds to the specified selected
        /// value.
        /// </summary>
        /// <param name="oList">List Control</param>
        /// <param name="iSelectedValue">Current Value</param>
        static public void SetListDefaultValue(ListControl oList,
                                               int iSelectedValue)
        {
            SetListDefaultValue(oList, iSelectedValue.ToString());
        }

        /// <summary>
        /// Set the SelectedIndex on the specified control to
        /// the index that corresponds to the specified selected
        /// value.
        /// </summary>
        /// <param name="oList">List Control</param>
        /// <param name="bSelectedValue">Current Value</param>
        static public void SetListDefaultValue(ListControl oList,
                                               bool bSelectedValue)
        {
            SetListDefaultValue(oList, bSelectedValue.ToString());
        }

        /// <summary>
        /// Set the SelectedIndex on the specified control to
        /// the index that corresponds to the specified selected
        /// value.
        /// </summary>
        /// <param name="oList">List Control</param>
        /// <param name="szSelectedValue">Current Value</param>
        static public void SetListDefaultValue(ListControl oList,
                                               string szSelectedValue)
        {
            oList.SelectedIndex = oList.Items.IndexOf(oList.Items.FindByValue(szSelectedValue));
        }

        static public void SetListValue(ListControl oList, string szSelectedValue)
        {
            ListItem oItem = oList.Items.FindByValue(szSelectedValue);
            if (oItem != null)
            {
                oItem.Selected = true;
            }
        }

        protected void SetListValues(ListControl oList, string szIDValues)
        {
            if (string.IsNullOrEmpty(szIDValues))
            {
                return;
            }

            string[] aszValues = szIDValues.Split(new char[] { ',' });
            foreach (string szValue in aszValues)
            {
                if (!String.IsNullOrEmpty(szValue))
                {
                    SetListValue(oList, szValue);
                }
            }
        }


        /// <summary>
        /// Adds the specified value to the string build, delimiting it with a comma.
        /// </summary>
        /// <param name="sbList"></param>
        /// <param name="szValue"></param>
        static public void AddDelimitedValue(StringBuilder sbList, string szValue) {
            AddDelimitedValue(sbList, szValue, ",");
        }

        /// <summary>
        ///  Adds the specified value to the string build
        /// </summary>
        /// <param name="sbList"></param>
        /// <param name="szValue"></param>
        /// <param name="szDelimiter"></param>
        static public void AddDelimitedValue(StringBuilder sbList, string szValue, string szDelimiter)
        {
            if (sbList.Length > 0)
            {
                sbList.Append(szDelimiter);
            }
            sbList.Append(szValue);
        }

        /// <summary>
        /// Iterates the items in the specified control and returns a comma-delimited
        /// list of the selected item values.
        /// </summary>
        /// <param name="oListControl"></param>
        /// <returns></returns>
        static public string GetSelectedValues(ListControl oListControl)
        {
            StringBuilder sbSelectedValues = new StringBuilder();
            foreach (ListItem oListItem in oListControl.Items)
            {
                if (oListItem.Selected)
                {
                    if (sbSelectedValues.Length > 0)
                        sbSelectedValues.Append(",");
                    sbSelectedValues.Append(oListItem.Value);
                }
            }
            return sbSelectedValues.ToString();
        }

        /// <summary>
        /// Returns the virtual path to the current
        /// application
        /// </summary>
        /// <returns></returns>
        static public string GetVirtualPath()
        {
            return Utilities.GetConfigValue("VirtualPath");
        }

        /// <summary>
        /// Returns the set of LookupValue objects for the
        /// specified value name.
        /// </summary>
        /// <param name="szName">Value Name</param>
        /// <returns>LookupValue objects</returns>
        public IBusinessObjectSet GetReferenceData(string szName)
        {
            return GetReferenceData(szName, "en-us");
        }

        /// <summary>
        /// Returns the set of LookupValue objects for the
        /// specified value name.
        /// </summary>
        /// <param name="szName">Value Name</param>
        /// <param name="szCulture">The culture to use when retrieving the data</param>
        /// <returns>LookupValue objects</returns>
        static public IBusinessObjectSet GetReferenceData(string szName, string szCulture)
        {
            string szCacheName = string.Format(REF_DATA_NAME, szName, szCulture);

            IBusinessObjectSet oRefData = (BusinessObjectSet)HttpRuntime.Cache[szCacheName];
            if (oRefData == null)
            {

                switch (szName)
                {
                    case "IntegrityRating":
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT prin_IntegrityRatingID, prin_Name FROM PRIntegrityRating WITH (NOLOCK) WHERE prin_IsNumeral IS NULL ORDER BY prin_Order desc");
                        break;
                    case "IntegrityRating2":
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT prin_IntegrityRatingID As Code, prin_Name + ' - ' + dbo.ufn_GetCustomCaptionValue('prin_Name', prin_Name, '" + szCulture + "') As Meaning FROM PRIntegrityRating WITH (NOLOCK) ORDER BY prin_Order DESC");
                        break;
                    case "IntegrityRating3":
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT prin_IntegrityRatingID As Code, prin_Name + ' - ' + dbo.ufn_GetCustomCaptionValue('prin_Name', prin_Name, '" + szCulture + "') As Meaning FROM PRIntegrityRating WITH (NOLOCK) WHERE prin_IsNumeral IS NULL ORDER BY prin_Order DESC");
                        break;
                    case "TESPayRating":
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT prpy_PayRatingId, prpy_TradeReportDescription FROM PRPayRating WITH (NOLOCK) WHERE prpy_IsNumeral IS NULL AND prpy_Deleted IS NULL ORDER BY prpy_Order");
                        break;
                    case "CreditWorthRating": 
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT prcw_CreditWorthRatingID, prcw_Name FROM PRCreditWorthRating WITH (NOLOCK) WHERE prcw_IsNumeral IS NULL ORDER BY prcw_Order desc");
                        break;
                    case "CreditWorthRating2": // Non-Lumber Credit Worth Ratings
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT prcw_CreditWorthRatingId  As Code, prcw_Name As Meaning FROM PRCreditWorthRating WITH (NOLOCK) WHERE prcw_IndustryType LIKE '%,P,%' AND prcw_IsNumeral IS NULL ORDER BY prcw_Order DESC");
                        break;
                    case "CreditWorthRating2L": // Lumber Credit Worth Ratings
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT prcw_CreditWorthRatingId  As Code, prcw_Name As Meaning FROM PRCreditWorthRating WITH (NOLOCK) WHERE prcw_IndustryType LIKE '%,L,%' AND prcw_IsNumeral IS NULL ORDER BY prcw_Order DESC");
                        break;
                    case "PayRating2":
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT prpy_PayRatingId As Code, prpy_Name + ' - ' + dbo.ufn_GetCustomCaptionValue('prpy_Name', prpy_Name, '" + szCulture + "') As Meaning FROM PRPayRating WITH (NOLOCK) WHERE prpy_IsNumeral IS NULL AND prpy_Deleted IS NULL ORDER BY prpy_Order");
                        break;
                    case "DLPhrases":
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT prdlp_DLPhraseID, prdlp_Phrase FROM PRDLPhrase WITH (NOLOCK) ORDER BY prdlp_Order");
                        break;
                    case "StockExchanges":
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT prex_StockExchangeId, prex_Name FROM PRStockExchange WITH (NOLOCK) WHERE prex_Publish = 'Y' ORDER BY prex_Order");
                        break;
                    case "PayIndicator":
                        oRefData = GetNonCustomCaptionRefData(szName, "SELECT capt_code As Code, capt_code + ' - ' + cast(capt_us as varchar(max)) As Meaning FROM Custom_Captions WHERE capt_family = 'PayIndicatorDescription' ORDER BY capt_Order");
                        break;
                    //case "prcp_Volume":
                    //    oRefData = GetNonCustomCaptionRefData(szName, "SELECT RTRIM(Capt_Code), Capt_US  FROM Custom_Captions WITH (NOLOCK) WHERE Capt_Family='prcp_Volume' ORDER BY capt_order DESC");
                    //    break;
                        
                        
                    default:
                        if (_oCustom_CaptionMgr == null) {
                            _oCustom_CaptionMgr = new Custom_CaptionMgr();
                        }
                        oRefData = new Custom_CaptionMgr().GetByName(szName);
                        break;
                }



                if (oRefData.Count > 0)
                {
                    HttpRuntime.Cache.Insert(szCacheName, oRefData);
                }
            }

            if (oRefData.Count == 0)
            {
                throw new ApplicationUnexpectedException("No values found for reference data named '" + szName + "' and culture '" + szCulture + "'.");
            }

            // We want to make a copy of our lookup set because some of our
            // callers manipulate the set which we don't want affecting
            // others.
            IBusinessObjectSet oNewSet = new BusinessObjectSet(oRefData);

            return oNewSet;
        }

        /// <summary>
        /// Builds a set of Custom_Caption objects that is not queried from the 
        /// custom_caption table.  The specified SQL is expected to have the 
        /// code in position 0 and the meaning in position 1.
        /// </summary>
        /// <param name="szName">The name to give to the custom caption</param>
        /// <param name="szSQL"></param>
        /// <returns></returns>
        protected static IBusinessObjectSet GetNonCustomCaptionRefData(string szName, string szSQL)
        {
            IBusinessObjectSet oList = new BusinessObjectSet();

            IDataReader oReader = DBAccessFactory.getDBAccessProvider().ExecuteReader(szSQL, CommandBehavior.CloseConnection);
            try
            {
                while (oReader.Read())
                {
                    ICustom_Caption oCaption = new Custom_Caption();
                    oCaption.Name = szName;
                    oCaption.Code = oReader[0].ToString().Trim();
                    oCaption.Meaning = oReader[1].ToString().Trim();
                    oList.Add(oCaption);
                }
                return oList;
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }
        }



        /// <summary>
        /// Iterates through the items HtmlEncoding the displayed
        /// text.
        /// </summary>
        /// <param name="oListControl">List Control</param>
        virtual protected void PrepareForDisplay(ListControl oListControl)
        {
            foreach (ListItem item in oListControl.Items)
            {
                item.Text = Server.HtmlEncode(item.Text);
            }
        }


        /// <summary>
        /// Increments the internal counter for controlling the current column 
        /// index when processing a repeater control.
        /// </summary>
        /// <returns></returns>
        virtual protected string IncrementRepeaterCount()
        {
            _iRepeaterCount++;
            return string.Empty;
        }

        virtual protected string ResetRepeaterCount() {
            _iRepeaterCount = 0;
            return string.Empty;
        }

        virtual protected string ResetRepeaterRowCount() {
            _iRepeaterRowCount = 1;
            return string.Empty;
        }


        /// <summary>
        /// Return the element begin separator for a N column table
        /// row in a repeater based on the item count.
        /// </summary>
        /// <param name="iCount">Current Item Count</param>
        /// <param name="dNumCols">Number of Columns</param>
        /// <param name="szWidth">Width of Columns</param>
        /// <returns></returns>
        virtual protected string GetBeginSeparator(int iCount, decimal dNumCols, string szWidth) {
            return GetBeginSeparator(iCount, dNumCols, szWidth, false);
        }

        /// <summary>
        /// Return the element begin separator for a N column table
        /// row in a repeater based on the item count.
        /// </summary>
        /// <param name="iCount">Current Item Count</param>
        /// <param name="dNumCols">Number of Columns</param>
        /// <param name="szWidth">Width of Columns</param>
        /// <param name="bUseShadeRow"></param>
        /// <returns></returns>
        virtual protected string GetBeginSeparator(int iCount, decimal dNumCols, string szWidth, bool bUseShadeRow)
        {
            return GetBeginSeparator(iCount, dNumCols, szWidth, bUseShadeRow, null);
        }
            
        virtual protected string GetBeginSeparator(int iCount, decimal dNumCols, string szWidth, bool bUseShadeRow, string szClassName)
        {
            
            string szSeparator = string.Empty;

            if ((iCount == 1) ||
                ((iCount - 1) % dNumCols == 0))
            {
                if (bUseShadeRow) {
                    //szSeparator = "<tr " + UIUtils.GetShadeClass(_iRepeaterRowCount) + ">";
                } else {
                    szSeparator = "<tr>";
                }
                
                _iRepeaterRowCount++;
            }

            if (!string.IsNullOrEmpty(szClassName))
            {
                szClassName = "class=\"" + szClassName + "\"";
            }

            szSeparator = szSeparator + "<td style=\"width:" + szWidth + ";vertical-align:top;\" " + szClassName + ">";
            return szSeparator;
        }

        /// <summary>
        /// Returns the element end separator for a N column table
        /// row in a repeater based on the item count.
        /// </summary>
        /// <param name="iCount">Record Count</param>
        /// <param name="dNumCols">Number of Columns</param>
        /// <returns>Separator</returns>
        virtual protected string GetEndSeparator(int iCount, decimal dNumCols)
        {
            string szSeparator = "</td>";
            if ((iCount % dNumCols) == 0)
            {
                szSeparator = szSeparator + "</tr>";
            }
            return szSeparator;
        }

        /// <summary>
        /// Returns the element complete separator for a N column table
        /// row in a repeater based on the item count.
        /// </summary>
        /// <param name="iCount">Record Count</param>
        /// <param name="dNumCols">Column Count</param>
        /// <returns>Separator</returns>
        virtual protected string GetCompleteSeparator(int iCount, decimal dNumCols)
        {
            if ((iCount % dNumCols) != 0)
            {
                return "</tr>";
            }
            return string.Empty;
        }


        /// <summary>
        /// Optimizes the ViewState for the specified
        /// GridView by disabling the view state on
        /// each row.
        /// </summary>
        /// <param name="oGridView"></param>
        protected void OptimizeViewState(GridView oGridView)
        {

            foreach (GridViewRow oRow in oGridView.Rows)
            {
                oRow.EnableViewState = false;
            }
        }


        /// <summary>
        /// Returns the specified parameter.  If not found
        /// returns null.
        /// </summary>
        /// <param name="szName">Parameter Name</param>
        /// <returns></returns>
        protected string GetRequestParameter(string szName)
        {
            return GetRequestParameter(szName, true);
        }

        /// <summary>
        /// Returns the specified parameter.  If required and not found,
        /// an ApplicationUnexpectedException is thrown.  Otherwise
        /// returns null.
        /// </summary>
        /// <param name="szName">Parameter Name</param>
        /// <param name="bRequired">Required Indicator</param>
        /// <returns></returns>
        protected string GetRequestParameter(string szName, bool bRequired)
        {
            // Pass 1: Look in the request, i.e. querystring and form input
            if ((Request.QueryString[szName] != null) &&
                (Request.QueryString[szName].Length > 0))
            {
                return Request.QueryString[szName];
            }

            if ((Request.Form[szName] != null) &&
                (Request.Form[szName].Length > 0))
            {
                return Request.Form[szName];
            }

            // Pass 2: Look in the session
            if ((Session[szName] != null) &&
                (Session[szName].ToString().Length > 0)) {
                return Session[szName].ToString();
            } 
            
            // Pass 3: Look for a client cookie
            if (Request.Cookies != null) {
                if ((Request.Cookies[szName] != null) &&
                    (Request.Cookies[szName].Value.Length > 0)) {
                    return Request.Cookies[szName].Value;
                }


            }
            
            if (bRequired) {
                throw new ApplicationUnexpectedException(string.Format("Parameter value '{0}' not found in URL: {1}", szName, Request.RawUrl));
            }

            return null;
        }

        protected void SetRequestParameter(string szName, string szValue) {
            Session[szName] = szValue;
        }

        protected void RemoveRequestParameter(string szName) {
            Session.Remove(szName);
        }

        /// <summary>
        /// Helper method that removes the specified code
        /// from the Reference Set
        /// </summary>
        /// <param name="oLookupSet">Set of Lookup Values</param>
        /// <param name="szRemoveCode">Code to Remove</param>
        protected void RemoveReferenceCode(IBusinessObjectSet oLookupSet, string szRemoveCode)
        {
            ICustom_Caption oRemove = null;
            foreach (ICustom_Caption oCustom_Caption in oLookupSet)
            {
                if (oCustom_Caption.Code == szRemoveCode)
                {
                    oRemove = oCustom_Caption;
                    break;
                }
            }

            oLookupSet.Remove(oRemove);
        }

        /// <summary>
        /// Helper method that returns the value from the specified
        /// IDictionary that has the specified key.  If no value is
        /// found, and empty string is returned.
        /// </summary>
        /// <param name="szKey">Key</param>
        /// <param name="_htData">Data</param>
        /// <returns></returns>
        protected string GetValue(string szKey, IDictionary _htData)
        {
            if (_htData.Contains(szKey))
            {
                return Convert.ToString(_htData[szKey]);
            }

            return string.Empty;
        }

        /// <summary>
        /// Sets the page title
        /// </summary>
        /// <param name="szTitle"></param>
        /// <returns></returns>
        public void SetPageTitle(string szTitle)
        {
            SetPageTitle(szTitle, string.Empty);
        }

        /// <summary>
        ///  Sets the page title and sub-title
        /// </summary>
        /// <param name="szTitle"></param>
        /// <param name="szSubTitle"></param>
        public void SetPageTitle(string szTitle, string szSubTitle)
        {

            Label lblPageHeader = (Label)this.Master.FindControl("lblPageHeader");
            Label lblPageSubheader = (Label)this.Master.FindControl("lblPageSubheader");
            
            if ((lblPageHeader == null) &&
                (this.Master.Master != null))
            {
                lblPageHeader = (Label)this.Master.Master.FindControl("lblPageHeader");
                lblPageSubheader = (Label)this.Master.Master.FindControl("lblPageSubheader");
            }

            if (lblPageHeader == null)
            {
                return;
            }

            lblPageHeader.Text = szTitle;
            lblPageSubheader.Text = szSubTitle;

            SetHTMLTitle(szTitle);
        }

        public void SetHTMLTitle(string szTitle)
        {
            Literal litTitle = (Literal)this.Master.FindControl("litHeadTitle");
            if ((litTitle == null) &&
                (this.Master.Master != null))
            {
                litTitle = (Literal)this.Master.Master.FindControl("litHeadTitle");
            }

            if (litTitle != null)
            {
                litTitle.Text = szTitle;
            }
        }


        /// <summary>
        /// Returns the configured number of items per page.
        /// </summary>
        /// <returns>Items Per Page</returns>
        protected int GetItemsPerPage()
        {
            return Utilities.GetIntConfigValue("ItemsPerPageCount", 50);
        }

        /// <summary>
        /// Helper method to prefix the specified string with the specified
        /// characters.  If the string is empty, it will not be prefixed.
        /// </summary>
        /// <param name="szString">String to prefix</param>
        /// <param name="iLength">Desired length</param>
        /// <param name="szChar">Prefix character</param>
        /// <returns></returns>
        protected string PrefixString(string szString, int iLength, string szChar)
        {
            // If our string is empty, return it empty.
            if (szString.Length == 0)
            {
                return szString;
            }

            if (szString.Length < iLength)
            {
                int iDiff = iLength - szString.Length;
                for (int i = 0; i < iDiff; i++)
                {
                    szString = szString.Insert(0, szChar);
                }
            }

            return szString;
        }

        /// <summary>
        /// Helper method that returns the CSSClass
        /// for shading a row or not, depending on 
        /// the _iRepeaterCount.
        /// </summary>
        /// <returns></returns>
        protected string GetRowClass()
        {
            return GetRowClass(_iRepeaterCount);
        }

        /// <summary>
        /// Helper method that returns the CSSClass
        /// for shading a row or not, depending on 
        /// the specified count.
        /// </summary>
        /// <param name="iCount"></param>
        /// <returns></returns>
        protected string GetRowClass(int iCount)
        {
            if ((iCount % 2) == 0)
            {
                return "class=shaderow";
            }
            return string.Empty;
        }

        /// <summary>
        /// Adds client-side JS to prevent button double-clicks
        /// </summary>
        /// <param name="btnButton">Button to prevent double-clicking</param>
        protected void AddDoubleClickPreventionJS(WebControl btnButton)
        {
            //AddDoubleClickPreventionJS(btnButton, string.Empty);
            btnButton.Attributes.Add("tsiDisable", "true");
        }


        /// <summary>
        /// Helper method that returns a IDBAccess object.  This is
        /// cached in a member variable.
        /// </summary>
        /// <returns></returns>
        public IDBAccess GetDBAccess()
        {
            if (_oDBAccess == null)
            {
                _oDBAccess = DBAccessFactory.getDBAccessProvider();
                _oDBAccess.Logger = _oLogger;
            }
            return _oDBAccess;
        }

        /// <summary>
        /// Helper method that returns an EBBObjectMgr object.  This is
        /// cached in a member variable.
        /// </summary>
        /// <returns></returns>
        public GeneralDataMgr GetObjectMgr()
        {
            if (_oObjectMgr == null) {
                _oObjectMgr = new GeneralDataMgr(_oLogger, null);
            }

            return _oObjectMgr;
        }

        /// <summary>
        /// Does a cascading lookup for the ReturnURL parameter.  The
        /// order of resolution is Request object, Session, then the
        /// specified default value.
        /// </summary>
        /// <param name="szDefaultURL"></param>
        /// <returns></returns>
        protected string GetReturnURL(string szDefaultURL)
        {
            string szReturnURL = null;
            if (!string.IsNullOrEmpty(Request["ReturnURL"]))
            {
                szReturnURL = Request["ReturnURL"];
            }

            if (string.IsNullOrEmpty(szReturnURL))
            {
                if (!string.IsNullOrEmpty((string)Session["ReturnURL"]))
                {
                    szReturnURL = (string)Session["ReturnURL"];
                }
            }

            if (string.IsNullOrEmpty(szReturnURL))
            {
                szReturnURL = szDefaultURL;
            }

            return szReturnURL;
        }

        protected void SetReturnURL(string szURL) {
            Session["ReturnURL"] = szURL;
        }


        /// <summary>
        /// If true, JS is generated that translates the multipart ASP.NET
        /// client control names to the specified client name.
        /// </summary>
        /// <returns></returns>
        public virtual bool EnableJSClientIDTranslation()
        {
            return false;
        }

        /// <summary>
        /// If true, the GoogleAdServices JS code is available
        /// to be included with the page.
        /// </summary>
        /// <returns></returns>
        public virtual bool EnableGoogleAdServices()
        {
            return false;
        }


        /// <summary>
        /// Returns the Referrer page name without the host name or
        /// query string parameters.
        /// </summary>
        /// <returns></returns>
        protected string GetReferer()
        {
            if (string.IsNullOrEmpty(Request.ServerVariables.Get("HTTP_REFERER")))
            {
                return null;
            }

            string szPage = Request.ServerVariables.Get("HTTP_REFERER");
            string szHost = Request.ServerVariables.Get("HTTP_HOST");

            // If we don't find our host, then this came from an external
            // site.  Return the entire URL.
            if (szPage.IndexOf(szHost) == -1)
            {
                return szPage;
            }


            int iStart = szPage.IndexOf(szHost) + szHost.Length;

            int iLength = 0;
            int iEnd = szPage.IndexOf("?");
            if (iEnd < 0)
            {
                iLength = szPage.Length - iStart;
            }
            else
            {
                iLength = iEnd - iStart;
            }

            return szPage.Substring(iStart, iLength);
        }

        public void AddCacheValue(string szKey, object oData)
        {
            string szCacheName = string.Format(REF_DATA_NAME, szKey, "en-us");
            HttpContext.Current.Cache.Insert(szCacheName, oData, null, System.Web.Caching.Cache.NoAbsoluteExpiration, TimeSpan.FromHours(2));
        }

        public object GetCacheValue(string szKey)
        {
            string szCacheName = string.Format(REF_DATA_NAME, szKey, "en-us");
            return HttpContext.Current.Cache[szCacheName];
        }

        /// <summary>
        /// Generates the appropriate Meta tags for consumption
        /// by the search engines.
        /// </summary>
        protected void AddIndexPageRobotMetaTags()
        {
            HtmlMeta metaRobots = new HtmlMeta();
            metaRobots.Name = "robots";
            metaRobots.Content = Utilities.GetConfigValue("IndexPageRobotsMetaTag", "noindex,noarchive");
            Page.Header.Controls.AddAt(0, metaRobots);
        }

        /// <summary>
        /// Formats the decimal into a currency format for
        /// display.
        /// </summary>
        /// <param name="dValue">Value</param>
        /// <returns>Formatted for Currency</returns>
        static public string GetFormattedCurrency(decimal dValue)
        {
            if (dValue == 0)
            {
                return string.Empty;
            }
            return dValue.ToString("c0");
        }

        /// <summary>
        /// Formats the decimal into a currency format for
        /// display.
        /// </summary>
        /// <param name="dValue">Value</param>
        /// <param name="dDefault"></param>
        /// <returns>Formatted for Currency</returns>
        static public string GetFormattedCurrency(decimal dValue, decimal dDefault)
        {
            if (dValue == 0)
            {
                return dDefault.ToString("c");
            }
            return dValue.ToString("c");
        }

        static public string GetWebServiceURL()
        {
            return Utilities.GetConfigValue("BBOSWebServiceURL");
        }

        static public string GetMarketingSiteURL()
        {
            return Utilities.GetConfigValue("MarketingSiteURL");
        }


        protected void LogVisitor(int companyID)
        {
            if (Request.Cookies["Visitor"] == null)
                return;

            System.Collections.Specialized.NameValueCollection visitorCookie = Request.Cookies["Visitor"].Values;

            IPRWebSiteVisitor websiteVisitor = (IPRWebSiteVisitor)new PRWebSiteVisitorMgr(_oLogger, null).CreateObject();
            websiteVisitor.prwsv_SubmitterIPAddress = Request.ServerVariables["REMOTE_ADDR"];
            websiteVisitor.prwsv_SubmitterEmail = visitorCookie["Email"];
            websiteVisitor.prwsv_CompanyName = visitorCookie["CompanyName"];
            websiteVisitor.prwsv_PrimaryFunction = visitorCookie["PrimaryFunction"];
            websiteVisitor.prwsv_CompanyID = companyID;
            websiteVisitor.prwsv_IndustryType = GetIndustryType();
            websiteVisitor.prwsv_RequestsMembershipInfo = visitorCookie["RequestsMembershipInfo"];
            websiteVisitor.prwsv_SubmitterName = visitorCookie["SubmitterName"];
            websiteVisitor.prwsv_SubmitterPhone = visitorCookie["SubmitterPhone"];
            websiteVisitor.prwsv_State = visitorCookie["State"];
            websiteVisitor.prwsv_Country = visitorCookie["Country"];

            if (Request.UrlReferrer != null)
            {
                websiteVisitor.prwsv_Referrer = Request.UrlReferrer.ToString();
            }

            websiteVisitor.Save();
        }

        protected int GetVisitCount()
        {
            if ((Request.Cookies["VisitCount"] != null) &&
                (!string.IsNullOrEmpty(Request.Cookies["VisitCount"].Value)))
                return Convert.ToInt32(Request.Cookies["VisitCount"].Value);

            return 0;
        }

        protected int IncrementVisitCount()
        {
            int visitCount = GetVisitCount();

            visitCount++;
            HttpCookie aCookie = new HttpCookie("VisitCount");
            aCookie.Value = visitCount.ToString();
            aCookie.Expires = DateTime.Now.AddYears(5);
            Response.Cookies.Add(aCookie);

            return visitCount;
        }

        protected void DeleteVisitorCookies()
        {
            DeleteCookie("VisitCount");
            DeleteCookie("Visitor");
        }

        protected void DeleteCookie(string name)
        {
            HttpCookie aCookie = new HttpCookie(name);
            aCookie.Expires = DateTime.Now.AddDays(-1);
            Response.Cookies.Add(aCookie);
        }

        protected Regex regexEmail = null;
        protected bool isValidEmail(string email)
        {

            if (regexEmail == null)
            {
                // http://stackoverflow.com/questions/5342375/c-sharp-regex-email-validation
                regexEmail = new Regex(@"^[\w!#$%&'*+\-/=?\^_`{|}~]+(\.[\w!#$%&'*+\-/=?\^_`{|}~]+)*" + "@" + @"((([\-\w]+\.)+[a-zA-Z]{2,4})|(([0-9]{1,3}\.){3}[0-9]{1,3}))$");
            }

            Match match = regexEmail.Match(email);
            return match.Success;
           
        }

        protected string GetIndustryType()
        {
            return Utilities.GetConfigValue("IndustryType");
        }

        protected string ReCaptchaSiteKey()
        {
            return PRCo.EBB.UI.Web.Configuration.ReCaptchaSiteKey;
        }

        protected string ReCaptchaSecretKey()
        {
            return PRCo.EBB.UI.Web.Configuration.ReCaptchaSecretKey;
        }

        protected bool ValidateCaptcha()
        {
            if (!Utilities.GetBoolConfigValue("CaptchaEnabled", true))
                return true;

            ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;

            // https://www.c-sharpcorner.com/article/integration-of-google-recaptcha-in-websites/
            var result = false;
            var captchaResponse = Request.Form["g-recaptcha-response"];
            var apiUrl = "https://www.google.com/recaptcha/api/siteverify?secret={0}&response={1}";
            var requestUri = string.Format(apiUrl, ReCaptchaSecretKey(), captchaResponse);
            var request = (HttpWebRequest)WebRequest.Create(requestUri);
            using (WebResponse response = request.GetResponse())
            {
                using (StreamReader stream = new StreamReader(response.GetResponseStream()))
                {
                    JObject jResponse = JObject.Parse(stream.ReadToEnd());
                    var isSuccess = jResponse.Value<bool>("success");
                    result = (isSuccess) ? true : false;
                }
            }
            if (!result)
            {
                LogMessage("Captcha verification failed server-side.");
                return false;
            }

            return result;
        }

        /// <summary>
        /// Defect 7396 - send email to all Sales People
        /// PTS orders only, not Lumber
        /// </summary>
        /// <param name="subject"></param>
        /// <param name="content"></param>
        /// <param name="source"></param>
        /// <param name="oTran"></param>
        protected void SendEmailToSales(string subject, string content, string source, IDbTransaction oTran)
        {
            string szSalesEmailRecipientIDs = Utilities.GetConfigValue("SalesEmailRecipientIDs", "24,35,1012"); //(TJR,JBL,LEL) --Jeff Lair, Leticia Lima, Tim Reardon
            var salesPersonIDs = szSalesEmailRecipientIDs.Split(new[] { ',' }, System.StringSplitOptions.RemoveEmptyEntries);

            foreach (string salesPerson in salesPersonIDs)
            {
                GetObjectMgr().SendEmail_Text(GetObjectMgr().GetPRCoUserEmail(Convert.ToInt32(salesPerson), oTran),
                    subject,
                    content,
                    source,
                    oTran);
            }
        }
    }
}