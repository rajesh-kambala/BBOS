/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2007-2023

 The use, disclosure, reproduction, modification, transfer, or
 transmittal of  this work for any purpose in any form or by any
 means without the written  permission of Blue Book Services, Inc. is
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: AJAXHelper
 Description:

 Notes:

    This web service contains methods to help various AJAX enabled
    extenders and controls.  It is mostly a data provider.

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.ComponentModel;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading;
using System.Web;
using System.Web.Services;

using AjaxControlToolkit;
using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;
using TSI.DataAccess;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web
{

    [WebService(Namespace = "http://apps.bluebookservices.com/bbos")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [ToolboxItem(false)]
    [System.Web.Script.Services.ScriptService()]
    public class AJAXHelper : System.Web.Services.WebService {

        protected EBBObjectMgr _oObjectMgr;
        protected IDBAccess _oDBAccess;
        protected ILogger _oLogger;


        [WebMethod]
        public string IsCurrentBrowserLoggedIn()
        {
            if (HttpContext.Current.User.Identity.IsAuthenticated)
            {
                return HttpContext.Current.User.Identity.Name;
            }
            return string.Empty;
        }



        [WebMethod (EnableSession = true)]
        public bool HasRatedAllNHAVideos()
        {
            try {
                IPRWebUser webuser = (IPRWebUser)Session["oUser"];
                GeneralDataMgr objectMgr = new GeneralDataMgr(GetLogger(), webuser);
                return objectMgr.HasRatedAllNHAVideos();
            }
            catch (Exception e)
            {
                GetLogger().LogError(e);
                return false;
            }
        }

        /// <summary>
        /// Returns Country values from PRCountry.  Uses the contextKey
        /// as the default selected value.
        /// </summary>
        /// <param name="knownCategoryValues">private storage format string</param>
        /// <param name="category">category of DropDownList to populate</param>
        /// <param name="contextKey"></param>
        /// <returns>list of content items</returns>
        [WebMethod]
        public AjaxControlToolkit.CascadingDropDownNameValue[] GetCountries(string knownCategoryValues, string category, string contextKey) {
            try
            {
                GetLogger().LogMessage("GetCountries: " + knownCategoryValues + ", " + category + ", " + contextKey);

                bool bDefault = false;
                List<CascadingDropDownNameValue> values = new List<CascadingDropDownNameValue>();
                values.Add(new CascadingDropDownNameValue(string.Empty, "0"));

                string szSQL = "SELECT prcn_CountryID, prcn_Country FROM PRCountry WITH (NOLOCK) WHERE prcn_CountryID > 0 ORDER BY prcn_Country;";

                using (IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection))
                {
                    while (oReader.Read())
                    {

                        if (contextKey == Convert.ToString(oReader.GetInt32(0)))
                        {
                            bDefault = true;
                        }
                        else
                        {
                            bDefault = false;
                        }

                        values.Add(new CascadingDropDownNameValue(oReader.GetString(1), Convert.ToString(oReader.GetInt32(0)), bDefault));
                    }
                }

                GetLogger().LogMessage("GetCountries: Finished");

                return values.ToArray();
            }
            catch (Exception e)
            {
                GetLogger().LogError(e);
                throw;
            }
        }


        /// <summary>
        /// Returns PRState values.  Uses the contextKey as the defualt value.
        /// </summary>
        /// <param name="knownCategoryValues">private storage format string</param>
        /// <param name="category">category of DropDownList to populate</param>
        /// <param name="contextKey"></param>
        /// <returns>list of content items</returns>
        [WebMethod]
        public AjaxControlToolkit.CascadingDropDownNameValue[] GetStates(string knownCategoryValues, string category, string contextKey) {

            bool bDefault = false;
            List<CascadingDropDownNameValue> values = new List<CascadingDropDownNameValue>();
            values.Add(new CascadingDropDownNameValue(string.Empty, "0"));

            StringDictionary kv = CascadingDropDown.ParseKnownCategoryValuesString(knownCategoryValues);

            int iCountryID;
            if (!kv.ContainsKey("Country") ||
                !Int32.TryParse(kv["Country"], out iCountryID)) {
                return null;
            }

            ArrayList oParamters = new ArrayList();
            oParamters.Add(new ObjectParameter("prst_CountryID", iCountryID));
            string szSQL = GetObjectMgr().FormatSQL("SELECT prst_StateID, prst_State FROM PRState WITH (NOLOCK) WHERE prst_CountryID = {0} and prst_State IS NOT NULL ORDER BY prst_State;", oParamters);
            IDataReader oReader = null;

            try {
                oReader = GetDBAccess().ExecuteReader(szSQL, oParamters, CommandBehavior.CloseConnection, null);
                while (oReader.Read()) {

                    if (contextKey == Convert.ToString(oReader.GetInt32(0))) {
                        bDefault = true;
                    } else {
                        bDefault = false;
                    }

                    values.Add(new CascadingDropDownNameValue(oReader.GetString(1), Convert.ToString(oReader.GetInt32(0)), bDefault));
                }

                return values.ToArray();
            } catch (Exception e) {
                GetLogger().LogError(e);
                throw;
            } finally {
                if (oReader != null) {
                    oReader.Close();
                }
            }
        }


        /// <summary>
        /// Returns PRState values.  Uses the contextKey as the defualt value.
        /// </summary>
        /// <param name="knownCategoryValues">private storage format string</param>
        /// <param name="category">category of DropDownList to populate</param>
        /// <param name="contextKey"></param>
        /// <returns>list of content items</returns>
        [WebMethod]
        public AjaxControlToolkit.CascadingDropDownNameValue[] GetStateAbbreviations(string knownCategoryValues, string category, string contextKey) {

            bool bDefault = false;
            List<CascadingDropDownNameValue> values = new List<CascadingDropDownNameValue>();
            values.Add(new CascadingDropDownNameValue(string.Empty, "0"));

            StringDictionary kv = CascadingDropDown.ParseKnownCategoryValuesString(knownCategoryValues);

            int iCountryID;
            if (!kv.ContainsKey("Country") ||
                !Int32.TryParse(kv["Country"], out iCountryID)) {
                return null;
            }

            ArrayList oParamters = new ArrayList();
            oParamters.Add(new ObjectParameter("prst_CountryID", iCountryID));
            string szSQL = GetObjectMgr().FormatSQL("SELECT prst_StateID, ISNULL(prst_Abbreviation, prst_State) FROM PRState WITH (NOLOCK) WHERE prst_CountryID = {0} and prst_State IS NOT NULL ORDER BY prst_State;", oParamters);
            IDataReader oReader = null;

            try {
                oReader = GetDBAccess().ExecuteReader(szSQL, oParamters, CommandBehavior.CloseConnection, null);
                while (oReader.Read()) {

                    if (contextKey == Convert.ToString(oReader.GetInt32(0))) {
                        bDefault = true;
                    } else {
                        bDefault = false;
                    }

                    values.Add(new CascadingDropDownNameValue(oReader.GetString(1), Convert.ToString(oReader.GetInt32(0)), bDefault));
                }

                return values.ToArray();
            } catch (Exception e) {
                GetLogger().LogError(e);
                throw;
            } finally {
                if (oReader != null) {
                    oReader.Close();
                }
            }
        }



        protected const string RATING_DEF_ROW = "<tr {0}><td style=\"white-space:nowrap;\">{1}</td><td style=\"text-align:center;\">{2}</td><td>{3}</td></tr>";
        protected const string SQL_SELECT_RATING_DEFINTION = @"SELECT dbo.ufn_GetCustomCaptionValue('prcw_Name', prcw_Name, '{0}') As CreditWorth, prcw_Name,
                                                                      dbo.ufn_GetCustomCaptionValue('prin_Name', prin_Name, '{0}') As Integrity, prin_Name,
                                                                      dbo.ufn_GetCustomCaptionValue('prpy_Name', prpy_Name, '{0}') As Pay, prpy_Name
                                                               FROM vPRCurrentRating
                                                               WHERE prra_RatingID={1}";

        protected const string SQL_SELECT_RATING_NUMERAL_DEFINTION = "SELECT prrn_Name, dbo.ufn_GetCustomCaptionValue('prrn_Name', prrn_Name, '{0}') As NumeralName  " +
                                                                     "  FROM PRRating WITH (NOLOCK) " +
                                                                     "       INNER JOIN PRRatingNumeralAssigned WITH (NOLOCK) ON prra_RatingID = pran_RatingID " +
                                                                     "       INNER JOIN PRRatingNumeral WITH (NOLOCK) ON pran_RatingNumeralID = prrn_RatingNumeralID " +
                                                                     "WHERE prra_RatingID={1} ";

        protected const string SQL_SELECT_PAY_INDICATOR_DEFINITION =
            @"SELECT prcpi_PayIndicator, dbo.ufn_GetCustomCaptionValue('PayIndicatorDescription', prcpi_PayIndicator, '{0}') As IndicatorDescription
                FROM PRCompanyPayIndicator WITH (NOLOCK)
               WHERE prcpi_CompanyPayIndicatorID={1}";

        /// <summary>
        /// Returns a raw HTML table containing the part
        /// definitions of the rating ID specified in
        /// the contextKey.
        /// </summary>
        /// <param name="contextKey"></param>
        /// <returns></returns>
        [WebMethod]
        public string GetRatingDefinitionCompanyDetailsHeader(string contextKey)
        {
            return GetRatingDefinition(contextKey, "contentMain_ucCompanyDetailsHeader_pnlRatingDefinition");
        }

        [WebMethod]
        public string GetRatingDefinitionCompanyDetails(string contextKey) {
            return GetRatingDefinition(contextKey, "contentMain_ucCompanyDetails_pnlRatingDefinition");
        }

        [WebMethod]
        public string GetRatingDefinition_NoButton(string contextKey)
        {
            return GetRatingDefinition(contextKey, "");
        }

        private string GetRatingDefinition(string contextKey, string PanelToClose)
        {
            int iCount = 0;

            StringBuilder sbRatingDef = new StringBuilder();

            if (!string.IsNullOrEmpty(PanelToClose))
            {
                sbRatingDef.Append(string.Format("<div class='popup_header'><button type='button' class='close' data-bs-dismiss='modal' onclick='document.getElementById(\"{0}\").style.display=\"none\";'>&times;</button></div>", PanelToClose));
            }

            sbRatingDef.Append("<div class='popup_content'>");
            sbRatingDef.Append("<table class=\"table no_bot_marg table-hover table-striped\">");
            sbRatingDef.Append("<thead>");
                sbRatingDef.Append("<tr>");
                sbRatingDef.Append("<th>");
                    sbRatingDef.Append(Resources.Global.Type);
                sbRatingDef.Append("</th>");
                sbRatingDef.Append("<th>");
                    sbRatingDef.Append(Resources.Global.Rating);
                sbRatingDef.Append("</th>");
                sbRatingDef.Append("<th>");
                    sbRatingDef.Append("Definition");
                sbRatingDef.Append("</th>");
            sbRatingDef.Append("</thead>");
            sbRatingDef.Append("<tbody>");

            string szSQL = string.Format(SQL_SELECT_RATING_DEFINTION, Thread.CurrentThread.CurrentCulture.Name, contextKey);
            IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection);
            try {
                oReader.Read();

                if (!string.IsNullOrEmpty(GetDBAccess().GetString(oReader, 0))) {

                    string[] args = {UIUtils.GetRowClass(iCount),
                                    Resources.Global.CreditWorth,
                                    GetDBAccess().GetString(oReader, 1),
                                    GetDBAccess().GetString(oReader, 0)};

                    sbRatingDef.Append(string.Format(RATING_DEF_ROW, args));
                    iCount++;
                }

                if (!string.IsNullOrEmpty(GetDBAccess().GetString(oReader, 2))) {

                    string[] args = {UIUtils.GetRowClass(iCount),
                                     Resources.Global.Integrity,
                                    GetDBAccess().GetString(oReader, 3),
                                    GetDBAccess().GetString(oReader, 2)};

                    sbRatingDef.Append(string.Format(RATING_DEF_ROW, args));
                    iCount++;
                }

                if (!string.IsNullOrEmpty(GetDBAccess().GetString(oReader, 4))) {
                    string[] args = {UIUtils.GetRowClass(iCount),
                                    Resources.Global.Pay,
                                    GetDBAccess().GetString(oReader, 5),
                                    GetDBAccess().GetString(oReader, 4)};

                    sbRatingDef.Append(string.Format(RATING_DEF_ROW, args));
                    iCount++;
                }

            } finally {
                if (oReader != null) {
                    oReader.Close();
                }
            }


            szSQL = string.Format(SQL_SELECT_RATING_NUMERAL_DEFINTION, Thread.CurrentThread.CurrentCulture.Name, contextKey);
            oReader = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection);
            try {
                while (oReader.Read()) {

                    string[] args = {UIUtils.GetRowClass(iCount),
                                     Resources.Global.RatingNumeral,
                                     GetDBAccess().GetString(oReader, 0),
                                     GetDBAccess().GetString(oReader, 1)};

                    sbRatingDef.Append(string.Format(RATING_DEF_ROW, args));
                    iCount++;
                }

            } finally {
                if (oReader != null) {
                    oReader.Close();
                }
            }

            sbRatingDef.Append("</tbody>");
            sbRatingDef.Append("</table>");
            sbRatingDef.Append("</div>"); //<div class='popup_content'>");
            return sbRatingDef.ToString();
        }

        protected const string SQL_RECENT_COMPANIES = "SELECT comp_CompanyID, comp_PRCorrTradestyle as CompanyName " +
                                                        "FROM dbo.ufn_GetRecentCompanies(@WebUserID, @Top) " +
                                                             "INNER JOIN Company ON CompanyID = comp_CompanyID " +
                                                    "ORDER BY ndx;";

        /// <summary>
        /// Returns a raw HTML table containing the last # of
        /// companies viewed by the current user.
        /// </summary>
        /// <param name="contextKey"></param>
        /// <returns></returns>
        [WebMethod]
        public string GetQuickFindRecentCompanies(string contextKey) {
            int iCount = 0;

            StringBuilder sbRecentCompanies = new StringBuilder("<table width=95% id=tblQuickFindRecentViews>");
            sbRecentCompanies.Append("<tr><td class=colHeader>");
            sbRecentCompanies.Append(Resources.Global.RecentlyViewedCompanies);
            sbRecentCompanies.Append("</td></tr>");

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("WebUserID", contextKey));
            oParameters.Add(new ObjectParameter("Top", Utilities.GetIntConfigValue("QuickFindTopN", 10)));

            IDataReader oReader = GetDBAccess().ExecuteReader(SQL_RECENT_COMPANIES, oParameters, CommandBehavior.CloseConnection, null);
            try {
                while (oReader.Read()) {

                    sbRecentCompanies.Append("<tr " + UIUtils.GetRowClass(iCount) + ">");
                    sbRecentCompanies.Append("<td class=recentlist><a href=\"");
                    sbRecentCompanies.Append(PageConstants.Format(PageConstants.COMPANY_DETAILS_SUMMARY, oReader["comp_CompanyID"]));
                    sbRecentCompanies.Append("\">" + Resources.Global.BBNumber + " ");
                    sbRecentCompanies.Append(oReader["comp_CompanyID"]);
                    sbRecentCompanies.Append(" - ");
                    sbRecentCompanies.Append(oReader["CompanyName"]);
                    sbRecentCompanies.Append("</a></td></tr>");

                    iCount++;
                }
            } finally {
                if (oReader != null) {
                    oReader.Close();
                }
            }
            sbRecentCompanies.Append("</table>");
            return sbRecentCompanies.ToString();
        }

        protected const string DEFINITION_ROW = "<tr {0}><td class=\"text-center\">{1}</td><td>{2}</td></tr>";
        protected const string SQL_SELECT_ALL_RATING_NUMERAL_DEFINTION = "SELECT * FROM ufn_GetRatingNumerals('{0}', '{1}') ORDER BY Numeral";
        /// <summary>
        /// Returns an HTML table containing the definitions of all
        /// rating numerals
        /// </summary>
        /// <returns></returns>
        [WebMethod]
        public string GetRatingNumeralsDefinitions(string contextKey) {

            int iCount = 0;

            StringBuilder sbRatingDef = new StringBuilder("<div class='popup_header'><button type='button' class='close' data-bs-dismiss='modal' onclick='this.closest(\".Popup\").style.display=\"none\";'>&times;</button></div>");
            sbRatingDef.Append("<div class='popup_content'>");
            sbRatingDef.Append("  <table class=\"table table-striped table-hover\" id=\"tblAllRatingNumeralDefinitions\">");
            sbRatingDef.Append("  <tbody><tr><th scope=\"col\">");
            sbRatingDef.Append(Resources.Global.RatingNumeral);
            sbRatingDef.Append("</th><th scope=\"col\">");
            sbRatingDef.Append(Resources.Global.RatingNumeralDefinitions);
            sbRatingDef.Append("</th></tr>");
            sbRatingDef.Append("</div>");

            string szSQL = string.Format(SQL_SELECT_ALL_RATING_NUMERAL_DEFINTION,
                                         Thread.CurrentThread.CurrentCulture.Name,
                                         contextKey);

            IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection);
            try {
                while (oReader.Read()) {

                    string[] args = {UIUtils.GetRowClass(iCount),
                                    GetDBAccess().GetString(oReader, 0),
                                    GetDBAccess().GetString(oReader, 1)};

                    sbRatingDef.Append(string.Format(DEFINITION_ROW, args));
                    iCount++;
                }

                sbRatingDef.Append("</table>");
                return sbRatingDef.ToString();
            } finally {
                if (oReader != null) {
                    oReader.Close();
                }
            }

        }


        protected const string SQL_CLASSIFICATION_DEFINITION = "SELECT {0} As Name, {1} As Description FROM PRClassification WHERE prcl_BookSection={2} AND prcl_Level=2 ORDER BY Name;";
        /// <summary>
        /// Returns an HTML table containing the definitions of all
        /// classifications for the specified Book Section.
        /// </summary>
        /// <returns></returns>
        [WebMethod]
        public string GetClassificationDefinitions(string contextKey) {

            int iCount = 0;
            StringBuilder sbClassificationDef = new StringBuilder("<table width=95% id=tblClassificationDefinitions>");

            string szSQL = string.Format(SQL_CLASSIFICATION_DEFINITION,
                                         GetObjectMgr().GetLocalizedColName("prcl_Name"),
                                         GetObjectMgr().GetLocalizedColName("prcl_Description"),
                                         contextKey);

            IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection);
            try {
                while (oReader.Read()) {

                    string[] args = {UIUtils.GetRowClass(iCount),
                                    GetDBAccess().GetString(oReader, 0),
                                    GetDBAccess().GetString(oReader, 1)};

                    sbClassificationDef.Append(string.Format(DEFINITION_ROW, args));
                    iCount++;
                }

                sbClassificationDef.Append("</table>");
                return sbClassificationDef.ToString();
            } finally {
                if (oReader != null) {
                    oReader.Close();
                }
            }

        }

        protected const string SQL_SHIPPING_RATES = "SELECT prcn_Country, prship_ShippingRate " +
                                                        "FROM PRShipping " +
                                                             "INNER JOIN PRCountry on prship_CountryID = prcn_CountryID " +
                                                    " WHERE prship_ProductID=@prship_ProductID " +
                                                    "ORDER BY prcn_Country";

        /// <summary>
        /// Returns a raw HTML table containing the shipping
        /// rates from the PRShipping table.
        /// </summary>
        /// <returns></returns>
        [WebMethod]
        public string GetShippingRates() {

            int iCount = 0;
            StringBuilder sbShippingRates = new StringBuilder("<table width=94% id='tblQuickFindRecentViews' class='table-striped table-hover'>");
            sbShippingRates.Append("<tr><td class='bold'>");
            sbShippingRates.Append(Resources.Global.Country);
            sbShippingRates.Append("</td><td class='bold' width=80px>");
            sbShippingRates.Append(Resources.Global.ShippingRate);
            sbShippingRates.Append("</td></tr>");

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prship_ProductID", Utilities.GetIntConfigValue("ShippingRatesProductID", 3)));

            IDataReader oReader = GetDBAccess().ExecuteReader(SQL_SHIPPING_RATES, oParameters, CommandBehavior.CloseConnection, null);
            try {
                while (oReader.Read()) {

                    sbShippingRates.Append("<tr " + UIUtils.GetRowClass(iCount) + "><td>");
                    sbShippingRates.Append(oReader.GetString(0));
                    sbShippingRates.Append("</td><td align=right>");
                    sbShippingRates.Append(UIUtils.GetFormattedCurrency(oReader.GetDecimal(1)   , 0M));
                    sbShippingRates.Append("</td></tr>");

                    iCount++;
                }
            } finally {
                if (oReader != null) {
                    oReader.Close();
                }
            }
            sbShippingRates.Append("</table>");
            return sbShippingRates.ToString();
        }

        protected const string SQL_QUICKFIND_AUTOCOMPLETE =
            @"SELECT DISTINCT TOP {0} comp_CompanyID, comp_PRCorrTradestyle, ISNULL(comp_PRLegalName, '') comp_PRLegalName, CityStateCountryShort, comp_PRType, comp_PRLocalSource, 1 as Seq
                FROM vPRBBOSCompanyList
                     INNER JOIN PRCompanySearch WITH (NOLOCK) on comp_CompanyID = prcse_CompanyID
                     LEFT OUTER JOIN PRCompanyAlias WITH (NOLOCK) ON comp_CompanyID = pral_CompanyID
               WHERE ({1})
                 AND {2}
                 {3}
                 AND comp_PRListingStatus IN ('L','H','LUV', 'N5')
            ORDER BY comp_PRCorrTradestyle, comp_PRType DESC";

        /// <summary>
        /// Returns the auto-complete list for the QuickFind control.
        /// </summary>
        /// <param name="prefixText"></param>
        /// <param name="count"></param>
        /// <param name="contextKey">Industry Type</param>
        /// <returns></returns>
        [WebMethod(EnableSession = true)]
        public string[] GetQuickFindCompletionList(string prefixText, int count, string contextKey) {

            return BuildAutCompleteList(prefixText, count, contextKey, false);
        }

        [WebMethod(EnableSession = true)]
        public string[] GetQuickFindCompletionListHQ(string prefixText, int count, string contextKey)
        {

            return BuildAutCompleteList(prefixText, count, contextKey, true);
        }

        private string[] BuildAutCompleteList(string prefixText, int count, string indutryType, bool HQOnly) {

            char[] acDelimiter = { '|' };
            string[] aszTokens = prefixText.Split(acDelimiter);

            string szWhere = string.Empty;

            IList lParms = new ArrayList();
            foreach (string szToken in aszTokens)
            {
                if (szWhere.Length > 0)
                    szWhere += " OR ";

                // When the company name is "prepared" in the PRCompanySearch table, the token
                // " and " is removed.  We need to do the same here in order to match company
                // names.
                string szCleanToken = szToken.ToLower().Replace(" and ", string.Empty);
                szCleanToken = SearchCriteriaBase.CleanString(szCleanToken);

                string szStartsWith = "StartsWith" + lParms.Count.ToString();
                lParms.Add(new ObjectParameter(szStartsWith, szCleanToken + "%"));

                szWhere += "(prcse_NameMatch LIKE @" + szStartsWith + " OR ISNULL(prcse_LegalNameMatch, '') LIKE @" + szStartsWith + " OR prcse_CorrTradestyleMatch LIKE @" + szStartsWith + " OR pral_NameAlphaOnly LIKE @" + szStartsWith + ")";
            }

            string szIndustryClause = null;
            if (indutryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                szIndustryClause = "comp_PRIndustryType = 'L'";
            else
                szIndustryClause = "comp_PRIndustryType <> 'L'";

            IPRWebUser user = (IPRWebUser)HttpContext.Current.Session["oUser"];
            if (user == null)
                szIndustryClause += " AND comp_PRLocalSource IS NULL";
            else
            {
                GetObjectMgr().User = user;
                szIndustryClause += " AND " + GetObjectMgr().GetLocalSourceCondition() + " AND " + GetObjectMgr().GetIntlTradeAssociationCondition();
            }

            string hqOnlyClause = string.Empty;
            if (HQOnly)
                hqOnlyClause = " AND comp_PRType='H' ";

            object[] args = { count, szWhere, szIndustryClause, hqOnlyClause};
            using (IDataReader oReader = GetDBAccess().ExecuteReader(string.Format(SQL_QUICKFIND_AUTOCOMPLETE, args),
                                                                  lParms,
                                                                  CommandBehavior.CloseConnection,
                                                                  null))
            {
                List<String> lReturnList = new List<string>();
                while (oReader.Read())
                {
                    string type = oReader.GetString(4);
                    if (oReader[5] != DBNull.Value)
                        type = Resources.Global.LocalSource;

                    lReturnList.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(oReader.GetString(1) + "|" + oReader.GetString(2) + "|" + type + "|" + oReader.GetString(3), oReader.GetInt32(0).ToString()));
                }

                return lReturnList.ToArray();
            }
        }


        private const string SQL_CITY_AUTOCOMPLETE =
            "SELECT TOP 20 prci_City, prst_State As State, prcn_CountryId As CountryId " +
              "FROM vPRLocation WITH (NOLOCK) " +
             "WHERE prci_City LIKE @City ";

        /// <summary>
        /// Returns the auto-complete list for the QuickFind control.
        /// </summary>
        /// <param name="prefixText"></param>
        /// <param name="count"></param>
        /// <param name="contextKey">Industry Type</param>
        /// <returns></returns>
        [WebMethod]
        public string[] GetCityCompletionList(string prefixText, int count, string contextKey)
        {

            if (string.IsNullOrEmpty(prefixText))
            {
                return null;
            }

            string szSQL = SQL_CITY_AUTOCOMPLETE;
            ArrayList alParameters = new ArrayList();

            if (!string.IsNullOrEmpty(contextKey))
            {
                string[] aryContextKey = contextKey.Split('|');  //Format:  State|Country

                if (aryContextKey.Length >= 1 && !string.IsNullOrEmpty(aryContextKey[0]))
                {
                    szSQL += " AND prst_State=@State ";
                    alParameters.Add(new ObjectParameter("State", aryContextKey[0]));
                }
                if(aryContextKey.Length >= 2 && !string.IsNullOrEmpty(aryContextKey[1]))
                {
                    szSQL += " AND prcn_CountryId = @Country ";
                    alParameters.Add(new ObjectParameter("Country", aryContextKey[1]));
                }
            }

            IDataReader oReader = null;
            try
            {

                alParameters.Add(new ObjectParameter("City", prefixText + "%"));

                oReader = GetDBAccess().ExecuteReader(szSQL,
                                                      alParameters,
                                                      CommandBehavior.CloseConnection,
                                                      null);
                List<String> lReturnList = new List<string>();
                while (oReader.Read())
                {
                    string szName = oReader.GetString(0) + ", " + oReader.GetString(1);
                    lReturnList.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(szName, szName));
                }

                return lReturnList.ToArray();
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }
        }


        private const string SQL_CITY_AUTOCOMPLETE_2 =
       "SELECT TOP 20 prci_City, prst_State As State, prst_StateId, prcn_CountryId As CountryId " +
         "FROM vPRLocation WITH (NOLOCK) " +
        "WHERE prci_City LIKE @City ";
        /// <summary>
        /// Returns the auto-complete list for the QuickFind control.  This is v2 for the new 9.0 UI where ids are passed instead of country/state names.
        /// </summary>
        /// <param name="prefixText"></param>
        /// <param name="count"></param>
        /// <param name="contextKey">Industry Type</param>
        /// <returns></returns>
        [WebMethod]
        public string[] GetCityCompletionList2(string prefixText, int count, string contextKey)
        {
            if (string.IsNullOrEmpty(prefixText))
            {
                return null;
            }

            string szSQL = SQL_CITY_AUTOCOMPLETE_2;
            ArrayList alParameters = new ArrayList();

            if (!string.IsNullOrEmpty(contextKey))
            {
                string[] aryContextKey = contextKey.Split('|');  //Format:  State|Country

                if (aryContextKey.Length >= 1 && !string.IsNullOrEmpty(aryContextKey[0]))
                {
                    szSQL += " AND prst_StateId=@StateId ";
                    alParameters.Add(new ObjectParameter("StateId", aryContextKey[0]));
                }
                if (aryContextKey.Length >= 2 && !string.IsNullOrEmpty(aryContextKey[1]))
                {
                    szSQL += " AND prcn_CountryId = @Country ";
                    alParameters.Add(new ObjectParameter("Country", aryContextKey[1]));
                }
            }

            IDataReader oReader = null;
            try
            {

                alParameters.Add(new ObjectParameter("City", prefixText + "%"));

                oReader = GetDBAccess().ExecuteReader(szSQL,
                                                      alParameters,
                                                      CommandBehavior.CloseConnection,
                                                      null);
                List<String> lReturnList = new List<string>();
                while (oReader.Read())
                {
                    string szName = oReader.GetString(0) + ", " + oReader.GetString(1);
                    lReturnList.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(szName, szName));
                }

                return lReturnList.ToArray();
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }
        }


        private const string SQL_COMMODITY_AUTOCOMPLETE =
            @"SELECT prcm_CommodityId, {0}
               FROM PRCommodity WITH (NOLOCK)
              WHERE prcm_Level <= @Level
                AND {0} LIKE @Commodity
           ORDER BY {0}";

        /// <summary>
        /// Returns the auto-complete list for the Commodity Find control.
        /// </summary>
        /// <param name="prefixText"></param>
        /// <param name="count"></param>
        /// <param name="contextKey">Industry Type</param>
        /// <returns></returns>
        [WebMethod]
        public string[] GetCommodityCompletionList(string prefixText, int count, string contextKey)
        {
            if (string.IsNullOrEmpty(prefixText))
            {
                return null;
            }

            char[] acDelimiter = { '|' };
            string[] aszContextKey = contextKey.Split(acDelimiter);
            int level = Convert.ToInt32(aszContextKey[0]);
            //string displayType = aszContextKey[1];

            ArrayList alParameters = new ArrayList();
            alParameters.Add(new ObjectParameter("Level", level));
            alParameters.Add(new ObjectParameter("Commodity", "%" + prefixText + "%"));

            string nameField = GetObjectMgr().GetLocalizedColName("prcm_FullName");
            string szSQL = string.Format(SQL_COMMODITY_AUTOCOMPLETE, nameField);

            using (IDataReader oReader = GetDBAccess().ExecuteReader(szSQL,
                                                                     alParameters,
                                                                     CommandBehavior.CloseConnection,
                                                                     null)) {
                List<String> lReturnList = new List<string>();
                while (oReader.Read())
                {
                    lReturnList.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(oReader.GetString(1), oReader.GetInt32(0).ToString()));
                }

                return lReturnList.ToArray();
            }
        }

        /// <summary>
        /// Returns the auto-complete list for the Commodity Find control where context could be N|N.
        /// </summary>
        /// <param name="prefixText"></param>
        /// <param name="count"></param>
        /// <param name="contextKey">Industry Type</param>
        /// <returns></returns>
        [WebMethod]
        public string[] GetCommodityList(string prefixText, int count, string contextKey)
        {
            string exclusionClause = string.Empty;

            if (!string.IsNullOrEmpty(contextKey))
            {
                string[] args = contextKey.Split('|');
                if ((args.Length >= 1) &&
                    (args[0] != "Y"))
                    exclusionClause += " AND prcm_AttributeID IS NULL";

                if ((args.Length >= 2) &&
                    (args[1] != "Y"))
                    exclusionClause += " AND prcm_GrowingMethodID IS NULL";
            }

            string szSQL = $"SELECT TOP {count} prcm_CommodityID, prcm_Description, prcm_AttributeID, prcm_GrowingMethodID, prcm_Abbreviation FROM PRCommodity2 WHERE (prcm_DescriptionMatch LIKE '%{prefixText}%' OR prcm_AliasMatch LIKE '%{prefixText}%') {exclusionClause} ORDER BY prcm_Description";
            using (IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, null, CommandBehavior.CloseConnection, null))
            {
                List<String> lReturnList = new List<string>();
                while (oReader.Read())
                {
                    string key = oReader.GetInt32(0).ToString() + "|";
                    if (oReader[2] != DBNull.Value)
                        key += oReader.GetInt32(2).ToString();
                    else
                        key += "0";

                    key += "|";
                    if (oReader[3] != DBNull.Value)
                        key += oReader.GetInt32(3).ToString();
                    else
                        key += "0";

                    key += "|";
                    key += oReader.GetString(4);

                    lReturnList.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(oReader.GetString(1), key));
                }

                return lReturnList.ToArray();
            }
        }

        protected const string SQL_GET_LISTING =
            @"SELECT dbo.ufn_GetListingCache(comp_CompanyID, {1}), CityStateCountryShort
                FROM Company WITH (NOLOCK)
                     INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
               WHERE comp_CompanyID={0}";

        [WebMethod]
        public string GetListing(string contextKey)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", contextKey));
            oParameters.Add(new ObjectParameter("FormattingStyle", 0));
            string szSQL = GetObjectMgr().FormatSQL(SQL_GET_LISTING, oParameters);

            string szLocation = null;
            string szListing = null;

            IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            try
            {
                oReader.Read();
                szListing = GetDBAccess().GetString(oReader, 0);
                szLocation = GetDBAccess().GetString(oReader, 1);
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }

            return szLocation + "<br/>" + szListing;
        }

        protected const string SQL_COMPANY_LOGO_URL =
            @"SELECT dbo.ufn_GetCustomCaptionValue('PIKSUtils', 'LogoURL', 'en-us') + comp_PRLogo AS comp_PRLogo
                FROM Company WITH (NOLOCK)
               WHERE comp_CompanyID={0}
                 AND comp_PRPublishLogo='Y'";

        [WebMethod]
        public string GetCompanyLogoURL(string contextKey)
        {
            try
            {
                ArrayList oParameters = new ArrayList();
                oParameters.Add(new ObjectParameter("CompanyID", contextKey));
                string szSQL = GetObjectMgr().FormatSQL(SQL_COMPANY_LOGO_URL, oParameters);
                object logoURL = GetDBAccess().ExecuteScalar(szSQL, oParameters);

                if (logoURL == null)
                {
                    return string.Empty;
                }

                return (string)logoURL;
            }
            catch (Exception e)
            {
                GetLogger().LogError(e);
                throw;
            }
        }

        [WebMethod]
        public string GetRatingDefinitionCW(string contextKey)
        {

            int iCount = 0;

            StringBuilder sbRatingDef = new StringBuilder("<table class=\"formtable\" style=\"width:95%\">");
            sbRatingDef.Append("<tr><td class=\"colHeader\">");
            sbRatingDef.Append(Resources.Global.Type);
            sbRatingDef.Append("</td><td class=\"colHeader\" style=\"text-align:center\">");
            sbRatingDef.Append(Resources.Global.Rating);
            sbRatingDef.Append("</td><td class=\"colHeader\" width=\"100%\">");
            sbRatingDef.Append("Definition");
            sbRatingDef.Append("</td></tr>");

            string szSQL = string.Format(SQL_SELECT_RATING_DEFINTION, Thread.CurrentThread.CurrentCulture.Name, contextKey);
            IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection);
            try
            {
                oReader.Read();

                if (!string.IsNullOrEmpty(GetDBAccess().GetString(oReader, 0)))
                {

                    string[] args = {UIUtils.GetRowClass(iCount),
                                    Resources.Global.CreditWorth,
                                    GetDBAccess().GetString(oReader, 1),
                                    GetDBAccess().GetString(oReader, 0)};

                    sbRatingDef.Append(string.Format(RATING_DEF_ROW, args));
                    iCount++;
                }
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }

            return sbRatingDef.ToString();
        }


        [WebMethod]
        public string GetRatingDefinitionNumerals(string contextKey)
        {
            int iCount = 0;
            StringBuilder sbRatingDef = new StringBuilder("<table class=\"formtable\" style=\"width:100%\">");
            sbRatingDef.Append("<tr><td class=\"colHeader\">");
            sbRatingDef.Append(Resources.Global.Type);
            sbRatingDef.Append("</td><td class=\"colHeader\">");
            sbRatingDef.Append(Resources.Global.Rating);
            sbRatingDef.Append("</td><td class=\"colHeader\" width=\"100%\">");
            sbRatingDef.Append("Definition");
            sbRatingDef.Append("</td></tr>");

            string szSQL = string.Format(SQL_SELECT_RATING_NUMERAL_DEFINTION, Thread.CurrentThread.CurrentCulture.Name, contextKey);
            IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection);
            try
            {
                while (oReader.Read())
                {

                    string[] args = {UIUtils.GetRowClass(iCount),
                                     Resources.Global.RatingNumeral,
                                     GetDBAccess().GetString(oReader, 0),
                                     GetDBAccess().GetString(oReader, 1)};

                    sbRatingDef.Append(string.Format(RATING_DEF_ROW, args));
                    iCount++;
                }

            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }

            sbRatingDef.Append("</table>");
            return sbRatingDef.ToString();
        }

        [WebMethod]
        public string GetPayIndicatorDefinition(string contextKey)
        {
            int iCount = 0;
            StringBuilder sbRatingDef = new StringBuilder("<table class=\"formtable\" style=\"width:95%\">");
            sbRatingDef.Append("<tr><td class=\"colHeader\">");
            sbRatingDef.Append(Resources.Global.Type);
            sbRatingDef.Append("</td><td class=\"colHeader\">");
            sbRatingDef.Append(Resources.Global.Value);
            sbRatingDef.Append("</td><td class=\"colHeader\" style=\"width:100%\">");
            sbRatingDef.Append("Definition");
            sbRatingDef.Append("</td></tr>");

            string szSQL = string.Format(SQL_SELECT_PAY_INDICATOR_DEFINITION, Thread.CurrentThread.CurrentCulture.Name, contextKey);
            IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection);
            try
            {
                while (oReader.Read())
                {

                    string[] args = {UIUtils.GetRowClass(iCount),
                                     Resources.Global.PayIndicator,
                                     GetDBAccess().GetString(oReader, 0),
                                     GetDBAccess().GetString(oReader, 1)};

                    sbRatingDef.Append(string.Format(RATING_DEF_ROW, args));
                    iCount++;
                }

            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }

            sbRatingDef.Append("</table>");
            return sbRatingDef.ToString();
        }


        private const string SQL_UPDATE_ADDRESS_GEOCODE =
            @"UPDATE Address SET addr_PRLatitude=@Latitude, addr_PRLongitude=@Longitude WHERE addr_AddressID=@AddressID";

        [WebMethod]
        public void SetAddressGeoCode(string addressID, string latitude, string longitude)
        {
            try
            {
                ArrayList oParameters = new ArrayList();
                oParameters.Add(new ObjectParameter("AddressID", addressID));
                oParameters.Add(new ObjectParameter("Latitude", latitude));
                oParameters.Add(new ObjectParameter("Longitude", longitude));
                GetObjectMgr().GetDBAccessFullRights().ExecuteNonQuery(SQL_UPDATE_ADDRESS_GEOCODE, oParameters);
            }
            catch (Exception eX)
            {
                _oLogger.LogError(eX);
            }
        }



        private const string SQL_SPECIEY_AUTOCOMPLETE =
            @"SELECT prspc_SpecieID, prspc_Name
                FROM PRSpecie WITH (NOLOCK)
               WHERE prspc_Name LIKE @Specie
            ORDER BY prspc_Name";

        /// <summary>
        /// Returns the auto-complete list for the Specie Find control.
        /// </summary>
        /// <param name="prefixText"></param>
        /// <param name="count"></param>
        /// <param name="contextKey">Industry Type</param>
        /// <returns></returns>
        [WebMethod]
        public string[] GetSpecieCompletionList(string prefixText, int count, string contextKey)
        {

            if (string.IsNullOrEmpty(prefixText))
            {
                return null;
            }

            char[] acDelimiter = { '|' };
            string[] aszContextKey = contextKey.Split(acDelimiter);
            int level = Convert.ToInt32(aszContextKey[0]);

            ArrayList alParameters = new ArrayList();
            //alParameters.Add(new ObjectParameter("Level", level));
            alParameters.Add(new ObjectParameter("Specie", "%" + prefixText + "%"));

            using (IDataReader oReader = GetDBAccess().ExecuteReader(SQL_SPECIEY_AUTOCOMPLETE,
                                                                     alParameters,
                                                                     CommandBehavior.CloseConnection,
                                                                     null))
            {
                List<String> lReturnList = new List<string>();
                while (oReader.Read())
                {
                    lReturnList.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(oReader.GetString(1), oReader.GetInt32(0).ToString()));
                }

                return lReturnList.ToArray();
            }
        }

        /// <summary>
        /// Rating History HTML for PerformanceIndicators.ascx
        /// </summary>
        [WebMethod]
        public string GetRatingHistoryHTML(string HQID)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", HQID));

            DataSet dsRatingHistory = GetDBAccess().ExecuteStoredProcedure("usp_BRRatings", oParameters);

            StringBuilder sbRatingHistory = new StringBuilder("<div class='row'><div class='col-md-12 text-center mar_bot15'><h2>");
            sbRatingHistory.Append(Resources.Global.RatingHistory.ToUpper());
            sbRatingHistory.Append("</h2></div></div>");
            sbRatingHistory.Append("<div class='row'>");

            //Current HQ Rating Section
            StringBuilder sbCurrentRating = new StringBuilder("<div class='col-md-5 col-sm-12 col-xs-12 text-left'>");
            sbCurrentRating.Append("<div class='row'>");
            sbCurrentRating.Append("  <div class='col-md-12 text-left'>");
            sbCurrentRating.Append("    <b><u>");
            sbCurrentRating.Append(Resources.Global.CurrentHQRating);
            sbCurrentRating.Append(":</b></u>");
            sbCurrentRating.Append("  </div>");
            sbCurrentRating.Append("</div>");

            //HQ Rating Trend Section
            StringBuilder sbRatingTrend = new StringBuilder("<div class='col-md-7 col-sm-12 col-xs-12 text-left'>");
            sbRatingTrend.Append("<div class='row'>");
            sbRatingTrend.Append("  <div class='col-md-12 text-left'>");
            sbRatingTrend.Append("    <b><u>");
            sbRatingTrend.Append(Resources.Global.HQRatingTrend);
            sbRatingTrend.Append(":</b></u>");
            sbRatingTrend.Append("  </div>");
            sbRatingTrend.Append("</div>");

            sbRatingTrend.Append("<div class='row'>");
            sbRatingTrend.Append("<div class='col-md-5 col-sm-5 col-xs-5 text-left'><b>");
            sbRatingTrend.Append(Resources.Global.ReportedDate);
            sbRatingTrend.Append(":</b></div>");
            sbRatingTrend.Append("<div class='col-md-7 col-sm-7 col-xs-7 text-left'><b>");
            sbRatingTrend.Append(Resources.Global.NewRating);
            sbRatingTrend.Append(":</b></div>");
            sbRatingTrend.Append("</div>");

            foreach (DataRow dr in dsRatingHistory.Tables[0].Rows)
            {
                int RatingID;
                DateTime RatingDate;
                string Current = "";
                string RatingLine = "";
                string RatingAnalysis = "";
                string TMFMAward = "";

                RatingID = (int)dr["RatingID"];
                RatingDate = (DateTime)dr["RatingDate"];

                if (dr["Current"] != System.DBNull.Value)
                    Current = (string)dr["Current"];

                if (dr["RatingLine"] != System.DBNull.Value)
                    RatingLine = (string)dr["RatingLine"];

                if (dr["RatingAnalysis"] != System.DBNull.Value)
                    RatingAnalysis = (string)dr["RatingAnalysis"];

                if (dr["TMFMAward"] != System.DBNull.Value)
                    TMFMAward = "<b>" + (string)dr["TMFMAward"] + "</b>";

                if (Current == "Y")
                {
                    sbCurrentRating.Append("<div class='row'><div class='col-md-12 text-left'>");
                    sbCurrentRating.Append(RatingLine + "<br>");
                    sbCurrentRating.Append("(" + Resources.Global.UnchangedSince + " " + RatingDate.ToString("MM/dd/yyyy") + ")<br>");
                    sbCurrentRating.Append(TMFMAward);
                    sbCurrentRating.Append("</div></div></div>");
                }

                sbRatingTrend.Append("<div class='row'>");
                sbRatingTrend.Append("<div class='col-md-5 col-sm-5 col-xs-5 text-left'>" + RatingDate.ToString("MM/dd/yyyy") + "</div>");
                sbRatingTrend.Append("<div class='col-md-7 col-sm-7 col-xs-7 text-left'>" + RatingLine + (Current == "Y" ? " (" + Resources.Global.Current + ")" : "") + "</div>");
                sbRatingTrend.Append("</div>");
            }

            sbRatingHistory.Append(sbCurrentRating.ToString());
            sbRatingHistory.Append(sbRatingTrend.ToString());
            sbRatingHistory.Append("</div>");
            sbRatingHistory.Append("</div>");

            return sbRatingHistory.ToString();
        }



        /// <summary>
        /// Financials HTML for PerformanceIndicators.ascx
        /// </summary>
        [WebMethod]
        public string GetFinancialsHTML(string HQID)
        {
            StringBuilder sbFinancials = new StringBuilder("<div class='row'><div class='col-xs-12 text-center mar_bot15'><h2>");
            sbFinancials.Append(Resources.Global.FinancialInformation);
            sbFinancials.Append("</h2></div></div>");

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", HQID));
            oParameters.Add(new ObjectParameter("ThresholdMonthsOld", 24));
            oParameters.Add(new ObjectParameter("ExcludeMonthsOld", 48));
            oParameters.Add(new ObjectParameter("ReportLevel", 3));

            DataSet dsFinancial = GetDBAccess().ExecuteStoredProcedure("usp_BRFinancialInformation", oParameters);

            oParameters.Clear();
            oParameters.Add(new ObjectParameter("CompanyID", HQID));
            DataSet dsFinancialFlags = GetDBAccess().ExecuteStoredProcedure("usp_BRFinancialInformationFlags", oParameters);

            string szFinancialStatementType = "";
            if (dsFinancialFlags.Tables[0].Rows[0]["Type"] != DBNull.Value)
                szFinancialStatementType = (string)dsFinancialFlags.Tables[0].Rows[0]["Type"];

            bool bConfidential = ((string)dsFinancialFlags.Tables[0].Rows[0]["IsConfidential"]) == "2";

            DateTime dtMostRecent = new DateTime();;
            if (dsFinancialFlags.Tables[0].Rows[0]["MostRecentDate"] != DBNull.Value)
                dtMostRecent = Convert.ToDateTime(dsFinancialFlags.Tables[0].Rows[0]["MostRecentDate"]);

            var distinctDates = dsFinancial.Tables[0].AsEnumerable()
                    .Select(s => new {
                        StatementDate = s.Field<DateTime>("StatementDate"),
                    })
                    .Distinct().ToList();

            if (dsFinancialFlags.Tables.Count == 0 && dsFinancial.Tables[0].Rows.Count == 0)
            {
                AppendFinancialsFooterRow(sbFinancials, dtMostRecent, szFinancialStatementType, bConfidential);
                return sbFinancials.ToString();
            }

            // Build up to 3 financial data arrays to iterate through
            List<DataRow[]> lstYearFinancials = new List<DataRow[]>();
            for(int i=0; i< distinctDates.Count; i++)
            {
                if(lstYearFinancials.Count < 3)
                    lstYearFinancials.Add(dsFinancial.Tables[0].Select("StatementDate = '" + distinctDates[i].StatementDate.ToString() + "'"));
            }

            if (!bConfidential)
            {
                AppendFinancialsHeaderRow(sbFinancials, lstYearFinancials);

                //AppendFinancialRow(sbFinancials,"Current Assets", lstYearFinancials);
                //AppendFinancialRow(sbFinancials,"Net Fixed Assets", lstYearFinancials);
                //AppendFinancialRow(sbFinancials,"Other Assets", lstYearFinancials);
                //AppendFinancialRow(sbFinancials,"Total Assets", lstYearFinancials);
                //AppendBlankRow(sbFinancials);

                //AppendFinancialRow(sbFinancials,"Current Liabilities", lstYearFinancials);
                //AppendFinancialRow(sbFinancials,"Long-Term Liabilities", lstYearFinancials);
                //AppendFinancialRow(sbFinancials,"Other Liabilities", lstYearFinancials);
                //AppendFinancialRow(sbFinancials,"Equity", lstYearFinancials);
                //AppendBlankRow(sbFinancials);

                //AppendFinancialRow(sbFinancials,"Working Capital", lstYearFinancials);

                string szPropertyEnglish = "Current Ratio";
                string szPropertyTranslated = TranslateProperty(szPropertyEnglish);
                AppendFinancialRow(sbFinancials, szPropertyEnglish, szPropertyTranslated, lstYearFinancials);

                szPropertyEnglish = "Quick Ratio";
                szPropertyTranslated = TranslateProperty(szPropertyEnglish);
                AppendFinancialRow(sbFinancials, szPropertyEnglish, szPropertyTranslated, lstYearFinancials);

                //AppendFinancialRow(sbFinancials,"Account Receivable Turnover", lstYearFinancials);

                szPropertyEnglish = "Days Payable Outstanding";
                szPropertyTranslated = TranslateProperty(szPropertyEnglish);
                AppendFinancialRow(sbFinancials, szPropertyEnglish, szPropertyTranslated, lstYearFinancials);

                szPropertyEnglish = "Debt To Equity";
                szPropertyTranslated = TranslateProperty(szPropertyEnglish);
                AppendFinancialRow(sbFinancials, szPropertyEnglish, szPropertyTranslated, lstYearFinancials);

                //AppendFinancialRow(sbFinancials,"Fixed Assets to Equity", lstYearFinancials);
                //AppendFinancialRow(sbFinancials,"Debt Service Ability", lstYearFinancials);
                //AppendFinancialRow(sbFinancials,"Operating Ratio", lstYearFinancials);

                szPropertyEnglish = "Net Profit/Loss";
                szPropertyTranslated = TranslateProperty(szPropertyEnglish);
                AppendFinancialRow(sbFinancials, szPropertyEnglish, szPropertyTranslated, lstYearFinancials);
            }

            AppendFinancialsFooterRow(sbFinancials, dtMostRecent, szFinancialStatementType, bConfidential);

            return sbFinancials.ToString();
        }

        private string TranslateProperty(string szPropertyEnglish)
        {
            string szCulture = Thread.CurrentThread.CurrentCulture.Name.ToLower();
            if (szCulture == "es-mx")
            {
                switch(szPropertyEnglish)
                {
                    case "How Prepared":
                        return Resources.Global.HowPrepared;
                    case "Current Ratio":
                        return Resources.Global.CurrentRatio;
                    case "Quick Ratio":
                        return Resources.Global.QuickRatio;
                    case "Days Payable Outstanding":
                        return Resources.Global.DaysPayableOutstanding;
                    case "Debt To Equity":
                        return Resources.Global.DebtToEquity;
                    case "Net Profit/Loss":
                        return Resources.Global.NetProfitLoss;
                    case "Year-End":
                        return Resources.Global.YearEnd;
                    case "Interim":
                        return Resources.Global.Interim;
                }

                return szPropertyEnglish;
            }
            else
                return szPropertyEnglish;
        }

        private void AppendBlankRow(StringBuilder sbFinancials)
        {
            sbFinancials.Append("<div class='row'><div class='col-xs-12'>&nbsp;</div></div>");
        }

        private void AppendFinancialsHeaderRow(StringBuilder sbFinancials, List<DataRow[]> lstYearFinancials)
        {
            string szColSpacing = GetFinancialsColSpacing(lstYearFinancials);

            //Date row
            sbFinancials.Append("<div class='row bor_top'>");

            sbFinancials.Append(string.Format("<div class='{0}'>", szColSpacing));
            sbFinancials.Append("&nbsp;");
            sbFinancials.Append("</div>");

            foreach (DataRow[] drFinancial in lstYearFinancials)
            {
                string szColHeader = "<b>";

                string szType = (string)drFinancial[0][1]; //Type col
                if (szType == "Interim")
                {
                    string szInterimMonth = (string)drFinancial[0][2]; //InterimMonth col
                    szColHeader += szInterimMonth + " ";
                }

                DateTime dtStatementDate = (DateTime)drFinancial[0][0]; //StatementDate col
                szColHeader += TranslateProperty(szType) + " " + dtStatementDate.ToString("MM/dd/yyyy");
                szColHeader += "</b>";

                sbFinancials.Append(string.Format("<div class='{0}'>", szColSpacing));
                sbFinancials.Append(szColHeader);
                sbFinancials.Append("</div>");
            }
            sbFinancials.Append("</div>"); //row

            //How Prepared row
            sbFinancials.Append("<div class='row bor_top bor_bot'>");
            sbFinancials.Append(string.Format("<div class='{0}'>", szColSpacing));
            sbFinancials.Append("<b>");
            sbFinancials.Append(TranslateProperty("How Prepared"));
            sbFinancials.Append("</b>");
            sbFinancials.Append("</div>");

            foreach (DataRow[] drFinancial in lstYearFinancials)
            {
                string szColHeader = "";

                string szPreparationMethod = (string)drFinancial[0][3]; //PreparationMethod col
                szColHeader += szPreparationMethod;

                sbFinancials.Append(string.Format("<div class='{0}'>", szColSpacing));
                sbFinancials.Append(szColHeader);
                sbFinancials.Append("</div>");
            }

            sbFinancials.Append("</div>"); //row
        }

        private void AppendFinancialsFooterRow(StringBuilder sbFinancials, DateTime dtMostRecent, string szFinancialStatementType, bool bConfidential)
        {
            sbFinancials.Append("<div class='row mar_top'>");
            sbFinancials.Append("<div class='col-xs-12'>");

            if (bConfidential)
            {
                sbFinancials.Append(Resources.Global.FinancialStatementsSubmittedInConfidence); //Financial statements are submitted in confidence to be used for rating purposes only. Specific figures are not quoted.
                sbFinancials.Append("&nbsp;&nbsp;");
            }

            string szConnector = "a";
            if (szFinancialStatementType.Length > 0 && szFinancialStatementType.Substring(0, 1) == "I")
                szConnector = "an"; //an Interim or a Year-End

            sbFinancials.Append(string.Format(Resources.Global.MostRecentFinancialStatementProvided, szConnector, szFinancialStatementType, dtMostRecent.ToString("MM/dd/yyyy")));  //The most recent financial statement provided by the company is {0} {1} statement dated {2}.", szConnector, szFinancialStatementType, dtMostRecent.ToString("MM/dd/yyyy")));
            sbFinancials.Append("</div>");

            sbFinancials.Append("<div class='col-xs-12 text-center' style=\"margin-top:10px;\">");
            sbFinancials.Append($"<a data-bs-toggle=\"modal\" data-bs-target=\"#pnlPurchConf\" href=\"javascript:__doPostBack('ctl00$contentMain$btnBusinessReport','')\">{Resources.Global.DownloadBRDetailMsg}</a>");
            sbFinancials.Append("</div>");

            sbFinancials.Append("</div>");
        }

        private static string GetFinancialsColSpacing(List<DataRow[]> lstYearFinancials)
        {
            string szColSpacing;
            switch (lstYearFinancials.Count)
            {
                case 1:
                    szColSpacing = "col-xs-6";
                    break;
                case 2:
                    szColSpacing = "col-xs-4";
                    break;
                default:
                    szColSpacing = "col-xs-3";
                    break;
            }

            return szColSpacing;
        }

        private void AppendFinancialRow(StringBuilder sbFinancials, string szPropertyEnglish, string szPropertyTranslated, List<DataRow[]> lstYearFinancials)
        {
            string szColSpacing = GetFinancialsColSpacing(lstYearFinancials);
            sbFinancials.Append("<div class='row bor_bot'>");

            sbFinancials.Append(string.Format("<div class='{0}'>", szColSpacing));
            sbFinancials.Append("<b>" + szPropertyTranslated + "</b>");
            sbFinancials.Append("</div>");

            foreach (DataRow[] drFinancial in lstYearFinancials)
            {
                string szValue = GetValue(drFinancial, szPropertyEnglish);
                sbFinancials.Append(string.Format("<div class='{0}'>", szColSpacing));
                sbFinancials.Append(szValue);
                sbFinancials.Append("</div>");
            }

            sbFinancials.Append("</div>");
        }

        private string GetValue(DataRow[] drFinancial, string szPropertyToFind)
        {
            foreach(DataRow dr in drFinancial)
            {
                string szDataType = ((string)dr[4]).ToUpper(); //DataType
                string szProperty = (string)dr[5]; //Property

                if (szProperty == szPropertyToFind)
                {
                    switch(szDataType)
                    {
                        case "C":
                            if (dr[6] == DBNull.Value)
                                return "";
                            else
                                return string.Format("{0:n0}", Convert.ToDecimal(dr[6]));
                        case "R":
                            if (dr[6] == DBNull.Value)
                                return "";
                            else
                                return string.Format("{0:n2}", Convert.ToDecimal(dr[6]));
                        case "S":
                            if (dr[6] == DBNull.Value)
                                return "";
                            else
                                return Convert.ToString(dr[6]); //ex: Profitable
                    }
                }
            }

            return ""; //not found
        }

        private void FinancialsHeaderRow(StringBuilder sbFinancials, DateTime dtStatementDate)
        {
            sbFinancials.Append("<div class='row'>");
            sbFinancials.Append("<div class='col-md-3'></div>");
            //sbFinancials.Append("<div class='col-md-3'>" + XPath + "</div>"); //Year-End 1
            sbFinancials.Append("<div class='col-md-3'></div>"); //Year-End 2
            sbFinancials.Append("<div class='col-md-3'></div>"); //Year-End 3
            sbFinancials.Append("</div>"); //col-md-3
            sbFinancials.Append("</div>"); //row
        }

        /// <summary>
        /// Trade Activity Summary HTML for PerformanceIndicators.ascx
        /// </summary>
        /// <param name="HQID"></param>
        /// <returns></returns>
        [WebMethod]
        public string GetTradeActivitySummaryHTML(string HQID)
        {
            StringBuilder sbTradeActivitySummary = new StringBuilder("<div class='row'><div class='col-xs-12 text-center mar_bot15'><h2>");
            sbTradeActivitySummary.Append(Resources.Global.TradeReportDetails.ToUpper());
            sbTradeActivitySummary.Append("</h2></div></div>");

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", HQID));
            oParameters.Add(new ObjectParameter("MonthsOld", 6));

            DataSet dsTradeReportDetails = GetDBAccess().ExecuteStoredProcedure("usp_BRTradeReportDetails", oParameters);

            if (dsTradeReportDetails.Tables[0].Rows.Count == 0)
            {
                sbTradeActivitySummary.Append("<div class='row'><div class='col-xs-12'>No trade report details available.</div></div>");
                return sbTradeActivitySummary.ToString();
            }

            string szColSpacing = "col-xs-5ths";

            //Header row
            sbTradeActivitySummary.Append("<div class='row bor_bot'>");
            sbTradeActivitySummary.Append(string.Format("<div class='{0}'><b>{1}</b></div>", szColSpacing, Resources.Global.ReportDate));
            sbTradeActivitySummary.Append(string.Format("<div class='{0}'><b>{1}</b></div>", szColSpacing, Resources.Global.Industry));
            sbTradeActivitySummary.Append(string.Format("<div class='{0}'><b>{1}</b></div>", szColSpacing, Resources.Global.TradePractices));
            sbTradeActivitySummary.Append(string.Format("<div class='{0}'><b>{1}</b></div>", szColSpacing, Resources.Global.AveragePayInDays));
            sbTradeActivitySummary.Append(string.Format("<div class='{0}'><b>{1}</b></div>", szColSpacing, Resources.Global.HighCreditInDollars));
            sbTradeActivitySummary.Append("</div>");

            foreach (DataRow dr in dsTradeReportDetails.Tables[0].Rows)
            {
                string szReportDate;
                if (dr["ReportDate"] == DBNull.Value)
                    szReportDate = "";
                else
                    szReportDate = ((DateTime)dr["ReportDate"]).ToString("MM/dd/yyyy");

                string szIndustry;
                if (dr["ResponderIndustryType"] == DBNull.Value)
                    szIndustry = "";
                else
                {
                    szIndustry = (string)dr["ResponderIndustryType"];
                    switch(szIndustry)
                    {
                        case "P":
                            szIndustry = Resources.Global.Produce;
                            break;
                        case "T":
                            szIndustry = Resources.Global.Transportation;
                            break;
                        case "S":
                            szIndustry = Resources.Global.Supply;
                            break;
                    }
                }

                string szTradePractices;
                if (dr["IntegrityRating"] == DBNull.Value)
                    szTradePractices = "";
                else
                    szTradePractices = (string)dr["IntegrityRating"];

                string szAveragePay;
                if (dr["PayRating"] == DBNull.Value)
                    szAveragePay = "";
                else
                    szAveragePay = (string)dr["PayRating"];

                string szHighCredit;
                if (dr["HighCredit"] == DBNull.Value)
                    szHighCredit = "";
                else
                    szHighCredit = (string)dr["HighCredit"];

                sbTradeActivitySummary.Append("<div class='row bor_bot'>");

                sbTradeActivitySummary.Append(string.Format("<div class='{0}'>", szColSpacing));
                sbTradeActivitySummary.Append(szReportDate);
                sbTradeActivitySummary.Append("</div>");

                sbTradeActivitySummary.Append(string.Format("<div class='{0}'>", szColSpacing));
                sbTradeActivitySummary.Append(szIndustry);
                sbTradeActivitySummary.Append("</div>");

                sbTradeActivitySummary.Append(string.Format("<div class='{0}'>", szColSpacing));
                sbTradeActivitySummary.Append(szTradePractices);
                sbTradeActivitySummary.Append("</div>");

                sbTradeActivitySummary.Append(string.Format("<div class='{0}'>", szColSpacing));
                sbTradeActivitySummary.Append(szAveragePay);
                sbTradeActivitySummary.Append("</div>");

                sbTradeActivitySummary.Append(string.Format("<div class='{0}'>", szColSpacing));
                sbTradeActivitySummary.Append(szHighCredit);
                sbTradeActivitySummary.Append("</div>");

                sbTradeActivitySummary.Append("</div>");
            }

            return sbTradeActivitySummary.ToString();
        }

        #region Helper Methods

        /// <summary>
        /// Returns an instance of an ObjectMgr
        /// </summary>
        /// <returns></returns>
        protected EBBObjectMgr GetObjectMgr() {
            if (_oObjectMgr == null) {
                _oObjectMgr = new PRWebUserMgr(GetLogger(), null);
            }
            return _oObjectMgr;
        }

        /// <summary>
        /// Returns an isntance of a DBAccess
        /// </summary>
        /// <returns></returns>
        protected IDBAccess GetDBAccess() {
            if (_oDBAccess == null) {
                _oDBAccess = DBAccessFactory.getDBAccessProvider();
                _oDBAccess.Logger = GetLogger();
            }
            return _oDBAccess;
        }

        /// <summary>
        /// Returns an instance of a Logger
        /// </summary>
        /// <returns></returns>
        protected ILogger GetLogger() {
            if (_oLogger == null) {
                _oLogger = LoggerFactory.GetLogger();
                _oLogger.RequestName = this.GetType().Name;
            }

            return _oLogger;
        }
        #endregion Helper Methods
    }
}
