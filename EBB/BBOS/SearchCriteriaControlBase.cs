using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using PRCo.EBB.BusinessObjects;
using TSI.DataAccess;

namespace PRCo.BBOS.UI.Web
{
    public class SearchCriteriaControlBase : System.Web.UI.UserControl
    {
        public bool _bHorizontalDisplay = false;
        protected PageBase oPageBase;
        protected SearchBase searchBase;

        virtual protected void Page_Load(object sender, EventArgs e)
        {
            oPageBase = new PageBase();
            searchBase = new SearchBase();
        }

        protected string GetLocationCriteria(SearchCriteriaBase searchCriteria)
        {
            StringBuilder sbLocationSearchCriteria = new StringBuilder();

            // Listing Country
            if (!String.IsNullOrEmpty(searchCriteria.ListingCountryIDs))
            {
                string[] aszCountries = searchCriteria.ListingCountryIDs.Split(new char[] { ',' });
                DataTable dtCountryList = searchBase.GetCountryList();

                sbLocationSearchCriteria.Append(GetCriteriaHTML(Resources.Global.ListingCountry,
                    searchBase.TranslateListValues(aszCountries, dtCountryList, "prcn_CountryId", "prcn_Country"),
                    true));
            }

            // Listing State/Province
            if (!String.IsNullOrEmpty(searchCriteria.ListingStateIDs))
            {
                string[] aszStates = searchCriteria.ListingStateIDs.Split(new char[] { ',' });
                DataTable dtStateList = searchBase.GetStateList();

                sbLocationSearchCriteria.Append(GetCriteriaHTML(Resources.Global.ListingStateProvince,
                    searchBase.TranslateListValues(aszStates, dtStateList, "prst_StateId", "prst_State"),
                    true));
            }

            // Listing City
            if (!String.IsNullOrEmpty(searchCriteria.ListingCity))
            {
                sbLocationSearchCriteria.Append(GetCriteriaHTML(Resources.Global.ListingCity,
                    searchCriteria.ListingCity,
                    true));
            }

            // Listing County
            if (!String.IsNullOrEmpty(searchCriteria.ListingCounty))
            {
                sbLocationSearchCriteria.Append(GetCriteriaHTML(Resources.Global.ListingCounty, searchCriteria.ListingCounty, true));
            }

            // Terminal Market
            if (!String.IsNullOrEmpty(searchCriteria.TerminalMarketIDs))
            {
                string[] aszTerminalMarkets = searchCriteria.TerminalMarketIDs.Split(new char[] { ',' });
                DataTable dtTerminalMarketList = searchBase.GetTerminalMarketList();

                sbLocationSearchCriteria.Append(GetCriteriaHTML(Resources.Global.TerminalMarket,
                    searchBase.TranslateListValues(aszTerminalMarkets, dtTerminalMarketList, "prtm_TerminalMarketId", "prtm_FullMarketName"),
                    true));
            }

            // Listing Postal Code
            if (!String.IsNullOrEmpty(searchCriteria.ListingPostalCode))
            {
                sbLocationSearchCriteria.Append(GetCriteriaHTML(Resources.Global.ListingPostalCode,
                    searchCriteria.ListingPostalCode,
                    true));
            }

            // Within Radius
            if (searchCriteria.Radius >= 0 &&
                !String.IsNullOrEmpty(searchCriteria.RadiusType))
            {
                sbLocationSearchCriteria.Append(GetCriteriaHTML(Resources.Global.WithinRadius,
                    searchCriteria.Radius.ToString() + " " + Resources.Global.MilesOf + " " + searchCriteria.RadiusType,
                    true));
            }

            return sbLocationSearchCriteria.ToString();
        }

        protected string GetCustomCriteria(SearchCriteriaBase searchCriteria, bool bBBOS9 = false, List<Tuple<string, string, bool>> lstData = null)
        {
            StringBuilder sbCustomSearchCriteria = new StringBuilder();

            // Has Notes
            if (searchCriteria.HasNotes)
            {
                if (bBBOS9)
                {
                    if (searchCriteria is CompanySearchCriteria)
                        lstData.Add(NewRow(Resources.Global.CompanyHasNotes,"", false));
                    else
                        lstData.Add(NewRow("Person Has Notes", "", false));
                }
                else
                {
                    if (searchCriteria is CompanySearchCriteria)
                        sbCustomSearchCriteria.Append(GetCriteriaHTML(Resources.Global.CompanyHasNotes, Resources.Global.CompanyHasNotes, true));
                    else
                        sbCustomSearchCriteria.Append(GetCriteriaHTML("Person Has Notes", "Person Has Notes", true));
                }
            }

            if ((searchCriteria is CompanySearchCriteria) &&
                (((CompanySearchCriteria)searchCriteria).CustomFieldSearchCriteria != null) &&
                (((CompanySearchCriteria)searchCriteria).CustomFieldSearchCriteria.Count > 0))
            {
                PRWebUserCustomFieldMgr customFieldMgr = new PRWebUserCustomFieldMgr();
                foreach (PRWebUserCustomFieldSearchCriteria customFieldSC in ((CompanySearchCriteria)searchCriteria).CustomFieldSearchCriteria)
                {
                    IPRWebUserCustomField customField = (IPRWebUserCustomField)customFieldMgr.GetObjectByKey(customFieldSC.CustomFieldID);

                    if (bBBOS9)
                    {
                        if (customFieldSC.MustHaveValue)
                        {
                            lstData.Add(NewRow(customField.prwucf_Label, "Must have a value", true));
                        }
                        else
                        {
                            if (customField.prwucf_FieldTypeCode == "DDL")
                            {
                                lstData.Add(NewRow(customField.prwucf_Label, customField.GetLookupValue(customFieldSC.CustomFieldLookupID).prwucfl_LookupValue, true));
                            }
                            else
                            {
                                if (!string.IsNullOrEmpty(customFieldSC.SearchValue))
                                {
                                    lstData.Add(NewRow(customField.prwucf_Label, customFieldSC.SearchValue, true));
                                }
                            }
                        }
                    }
                    else
                    {
                        if (customFieldSC.MustHaveValue)
                        {
                            sbCustomSearchCriteria.Append(GetCriteriaHTML(customField.prwucf_Label, "Must have a value", true));
                        }
                        else
                        {
                            if (customField.prwucf_FieldTypeCode == "DDL")
                            {
                                sbCustomSearchCriteria.Append(GetCriteriaHTML(customField.prwucf_Label, customField.GetLookupValue(customFieldSC.CustomFieldLookupID).prwucfl_LookupValue, true));
                            }
                            else
                            {
                                if (!string.IsNullOrEmpty(customFieldSC.SearchValue))
                                {
                                    sbCustomSearchCriteria.Append(GetCriteriaHTML(customField.prwucf_Label, customFieldSC.SearchValue, true));
                                }
                            }
                        }
                    }
                }
            }

            // Watchdog Lists
            if (!string.IsNullOrEmpty(searchCriteria.UserListIDs))
            {
                if (bBBOS9)
                {
                    lstData.Add(NewRow(Resources.Global.WatchdogLists, GetWatchdogListNames(searchCriteria.UserListIDs), true));
                }
                else
                {
                    sbCustomSearchCriteria.Append(GetCriteriaHTML(Resources.Global.WatchdogLists, GetWatchdogListNames(searchCriteria.UserListIDs), true));
                }
            }

            return sbCustomSearchCriteria.ToString();
        }

        protected Tuple<string, string, bool> NewRow(string name, string value, bool showValue = true)
        {
            return new Tuple<string, string, bool>(name, value, showValue);
        }

        /// <summary>
        /// Helper method to build the HTML for each search criteria item.
        /// </summary>
        /// <param name="szCriteriaName">Search criteria name</param>
        /// <param name="szCriteriaValue">Search criteria value</param>
        /// <param name="bIncludeSubHeader">Include section header</param>
        /// <returns>HTML string for search criteria section</returns>
        protected string GetCriteriaHTML(string szCriteriaName, string szCriteriaValue, bool bIncludeSubHeader)
        {
            string szHTML = "";

            szCriteriaName = szCriteriaName.Replace("<br/>", " ");

            szHTML += "<p class='search-criteria-group'>";
            szHTML += string.Format("<div class=''><span class='clr_blu'>{0}:</span><br/>{1}</div>", szCriteriaName, szCriteriaValue);
            szHTML += "</p>";

            return szHTML;
        }

        /// <summary>
        /// Helper method to build the HTML for each criteria section header.
        /// </summary>
        /// <param name="szSectionHeader">Section Header Name</param>
        /// <returns>HTML string for section header</returns>
        protected string GetSectionHeaderHTML(string szSectionHeader)
        {
            return ""; //per new requirements, criteria will no longer be grouped so don't display headers

            //string szHTML = "";
            //szHTML += string.Format("<div class='row'><div class='col-md-12'><h5 class='blu_tab'>{0}</h5></div></div>", szSectionHeader);
            //return szHTML;
        }

        protected string GetReferenceDisplayValues(string szIDs, string szRefDataName)
        {
            string[] aszIds = szIDs.Split(',');
            StringBuilder sbDisplay = new StringBuilder();
            foreach (string szID in aszIds)
            {
                if (sbDisplay.Length > 0)
                {
                    sbDisplay.Append(", ");
                }
                sbDisplay.Append(oPageBase.GetReferenceValue(szRefDataName, szID.Trim()));
            }
            return sbDisplay.ToString();
        }

        protected const string SQL_SELECT_WATCHDOG_LIST_NAMES =
            @"SELECT prwucl_Name
                FROM PRWebUserList WITH (NOLOCK) 
               WHERE prwucl_WebUserListID IN ({0});";

        protected string GetWatchdogListNames(string szIDs)
        {
            StringBuilder names = new StringBuilder();
            IDBAccess oDataAccess = DBAccessFactory.getDBAccessProvider();
            //oDataAccess.Logger = _oLogger;
            using (IDataReader reader = oDataAccess.ExecuteReader(string.Format(SQL_SELECT_WATCHDOG_LIST_NAMES, szIDs), null, CommandBehavior.CloseConnection, null))
            {
                while (reader.Read())
                {
                    if (names.Length > 0)
                    {
                        names.Append(",");
                    }
                    names.Append(reader[0]);
                }
            }

            return names.ToString();
        }
    }
}