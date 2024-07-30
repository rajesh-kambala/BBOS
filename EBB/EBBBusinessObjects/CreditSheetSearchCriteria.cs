/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2017

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CreditSheetSearchCriteria
 Description:	

 Notes:	Created By Sharon Cole on 7/17/2007 3:07:32 PM

***********************************************************************
***********************************************************************/

using System;
using System.Collections;
using System.Globalization;
using System.Text;

using TSI.Arch;
using TSI.Utils;

namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Provides the functionality for the CreditSheetSearchCriteria
    /// </summary>
    [Serializable]
    public class CreditSheetSearchCriteria : SearchCriteriaBase
    {
        protected string _szDateRangeType;

        protected DateTime _dtFromDate;
        protected DateTime _dtToDate;

        protected bool _bKeyOnly;
        protected bool _bIncludeNewListing;
        protected bool _bOnlyNewListings;

        private int _iYear;
        private int _iMonth;

        // CRM PRCreditSheets Table Constants
        public const string COL_PRCREDITSHEETS_CREDITSHEETID = "prcs_CreditSheetId";
        public const string COL_PRCREDITSHEETS_COMPANYID = "prcs_CompanyId";
        public const string COL_PRCREDITSHEETS_DATE = "prcs_PublishableDate";
        public const string COL_PRCREDITSHEETS_KEYONLY = "prcs_KeyFlag";
        public const string COL_PRCREDITSHEETS_STATUS = "prcs_Status ";
 
        // Other search constants
        public const string CODE_DATERANGE_TODAY = "Today";
        public const string CODE_DATERANGE_YESTERDAY = "Yesterday";
        public const string CODE_DATERANGE_THISWEEK = "This Week";
        public const string CODE_DATERANGE_LASTWEEK = "Last Week";
        public const string CODE_DATERANGE_THISMONTH = "This Month";
        public const string CODE_DATERANGE_LASTMONTH = "Last Month";
        public const string CODE_DATERANGE_THISQUARTER = "This Quarter";
        public const string CODE_DATERANGE_LASTQUARTER = "Last Quarter";

        // SQL constants
        protected const string SQL_CREDITSHEET_SEARCH =
            @"SELECT vPRBBOSCompanyList.*, 
                     prcs_CreditSheetID, 
                     prcs_PublishableDate, 
                     prcs_KeyFlag, 
                     dbo.ufn_GetCSItemCache(prcs_CreditSheetID, 0) As ItemText, 
                     dbo.ufn_HasNote({0}, {1}, comp_CompanyID, 'C') As HasNote,
                     dbo.ufn_HasNewClaimActivity(comp_PRHQID, '{2}') as HasNewClaimActivity, 
                     dbo.ufn_HasMeritoriousClaim(comp_PRHQID, '{3}') as HasMeritoriousClaim,
                     dbo.ufn_HasCertification(comp_PRHQID) as HasCertification,
                     dbo.ufn_HasCertification_Organic(comp_PRHQID) as HasCertification_Organic, 
                     dbo.ufn_HasCertification_FoodSafety(comp_PRHQID) as HasCertification_FoodSafety";

        protected const string SQL_CREDITSHEET_SEARCH_FROM = " FROM PRCreditSheet WITH (NOLOCK) INNER JOIN vPRBBOSCompanyList ON prcs_CompanyId = comp_CompanyID WHERE ";

        /// <summary>
        /// Constructor
        /// </summary>
        public CreditSheetSearchCriteria() { }

        #region Property Accessors
        /// <summary>
        /// Accessor for the DateRangeType property.
        /// </summary>
        public string DateRangeType
        {
            get { return _szDateRangeType; }
            set {
                SetDirty(value, _szDateRangeType);
                _szDateRangeType = value;
            }
        }

        /// <summary>
        /// Accessor for the FromDate property.
        /// </summary>
        public DateTime FromDate
        {
            get { return _dtFromDate; }
            set {
                SetDirty(value, _dtFromDate);
                _dtFromDate = value;
            }
        }

        /// <summary>
        /// Accessor for the ToDate property.
        /// </summary>
        public DateTime ToDate
        {
            get { return _dtToDate; }
            set {
                SetDirty(value, _dtToDate);
                _dtToDate = value;
            }
        }
        
        /// <summary>
        /// Accessor for the KeyOnly property.
        /// </summary>
        public bool KeyOnly
        {
            get { return _bKeyOnly; }
            set {
                SetDirty(value, _bKeyOnly);
                _bKeyOnly = value;
            }
        }


        /// <summary>
        /// Accessor for the IncludeNewListings property.
        /// </summary>
        public bool IncludeNewListings
        {
            get { return _bIncludeNewListing; }
            set
            {
                SetDirty(value, _bIncludeNewListing);
                _bIncludeNewListing = value;
            }
        }

        /// <summary>
        /// Accessor for the OnlyNewListings property.
        /// </summary>
        public bool OnlyNewListings
        {
            get { return _bOnlyNewListings; }
            set
            {
                SetDirty(value, _bOnlyNewListings);
                _bOnlyNewListings = value;
            }
        }
        #endregion

        /// <summary>
        /// Generates the Search SQL based on the Search
        /// Criteria.
        /// </summary>
        /// <param name="oParams">Parameter List</param>
        /// <returns>Search SQL String</returns>
        override public string GetSearchSQL(out ArrayList oParams)
        {
            if (_oUser == null) {
                throw new ApplicationUnexpectedException("The WebUser attribute is null.");
            }
        
            oParams = new ArrayList();
           
            string szWhere = BuildWhereClause(oParams);
            string szOrderBy = BuildOrderByClause();

            //Handle spanish globalization of date fields
            CultureInfo m_UsCulture = new CultureInfo("en-us");
            string szDate1 = DateTime.Today.AddDays(0 - Utilities.GetIntConfigValue("ClaimActivityNewThresholdIndicatorDays", 21)).ToString(m_UsCulture);
            string szDate2 = DateTime.Today.AddDays(0 - Utilities.GetIntConfigValue("ClaimActivityMeritoriousThresholdIndicatorDays", 60)).ToString(m_UsCulture);

            object[] args = {_oUser.prwu_WebUserID, 
                             _oUser.prwu_HQID, 
                             szDate1,
                             szDate2 };

            return string.Format(SQL_SELECT_TOP,
                                 Utilities.GetConfigValue("CompanyUpdateSearchMaxResults", "2000"),
                                 string.Format(SQL_CREDITSHEET_SEARCH + SQL_CREDITSHEET_SEARCH_FROM, args) + " " + szWhere,
                                 szOrderBy);
            
        }

        /// <summary>
        /// Returns the SQL to count the number of rows that would be 
        /// returned by the specified criteria.
        /// </summary>
        /// <param name="oParams"></param>
        /// <returns></returns>
        override public string GetSearchCountSQL(out ArrayList oParams) {
            if (_oUser == null) {
                throw new ApplicationUnexpectedException("The WebUser attribute is null.");
            }

            oParams = new ArrayList();

            string szWhere = BuildWhereClause(oParams);
            return string.Format("SELECT COUNT(1) As CNT " + SQL_CREDITSHEET_SEARCH_FROM, _oUser.prwu_WebUserID, _oUser.prwu_HQID) + " " + szWhere;
        }

        /// <summary>
        /// Builds the appropriate WHERE clause based on the criteria
        /// specified.
        /// </summary>
        /// <param name="oParameters">Parameter List</param>
        /// <returns>WHERE Clause</returns>
        override protected string BuildWhereClause(IList oParameters)
        {
            StringBuilder sbWhereClause = new StringBuilder();
            StringBuilder sbSubSelectWhere = new StringBuilder();

            sbWhereClause.Append(base.BuildWhereClause(oParameters));
            sbWhereClause.Replace(COL_COMPANY_COMPANYID, COL_PRCREDITSHEETS_COMPANYID);

            // Date Range Type Criteria
            if (!String.IsNullOrEmpty(_szDateRangeType))
            {
                _iMonth = DateTime.Now.Month;
                _iYear = DateTime.Now.Year;
                DateTime dtTemp = new DateTime();
                
                switch (_szDateRangeType)
                {
                    case CODE_DATERANGE_TODAY:
                        _dtFromDate = Convert.ToDateTime(DateTime.Today.ToShortDateString());
                        _dtToDate = Convert.ToDateTime(DateTime.Today.ToShortDateString());
                        break;
                    case CODE_DATERANGE_YESTERDAY:
                        _dtFromDate = Convert.ToDateTime(DateTime.Today.AddDays(-1).ToShortDateString());
                        _dtToDate = Convert.ToDateTime(DateTime.Today.AddDays(-1).ToShortDateString());
                        break;
                    case CODE_DATERANGE_THISWEEK:
                        // Let's find the most recent Sunday first.
                        dtTemp = DateTime.Today.AddDays(-1 * Convert.ToInt16(DateTime.Today.DayOfWeek));
                        _dtFromDate = Convert.ToDateTime(dtTemp.ToShortDateString());
                        _dtToDate = Convert.ToDateTime(DateTime.Today.ToShortDateString());
                        break;
                    case CODE_DATERANGE_LASTWEEK:
                        dtTemp = DateTime.Today.AddDays(-1 * Convert.ToInt16(DateTime.Today.DayOfWeek));
                        _dtFromDate = Convert.ToDateTime(dtTemp.AddDays(-7).ToShortDateString());
                        _dtToDate = Convert.ToDateTime(dtTemp.AddDays(-1).ToShortDateString());
                        break;
                    case CODE_DATERANGE_THISMONTH:
                        dtTemp = new DateTime(_iYear, _iMonth, 1);
                        _dtFromDate = dtTemp;
                        _dtToDate = Convert.ToDateTime(DateTime.Today.ToShortDateString());
                        break;
                    case CODE_DATERANGE_LASTMONTH:
                        dtTemp = DateTime.Now.AddMonths(-1);
                        _dtFromDate = new DateTime(dtTemp.Year, dtTemp.Month, 1);
                        _dtToDate = _dtFromDate.AddMonths(1).AddDays(-1);
                        break;
                    case CODE_DATERANGE_THISQUARTER:
                        SetDatesByQuarter(_iMonth);
                        break;
                    case CODE_DATERANGE_LASTQUARTER:
                        SetDatesByQuarter(_iMonth);
                        _dtFromDate = _dtFromDate.AddMonths(-3);
                        _dtToDate = _dtToDate.AddMonths(-3);
                        break;
                }
            }

            // From Date Criteria
            if (_dtFromDate != DateTime.MinValue)
            {
                AddCondition(sbWhereClause, oParameters, COL_PRCREDITSHEETS_DATE, ">=", _dtFromDate);
            }

            // To Date Criteria
            if (_dtToDate != DateTime.MinValue)
            {
                // Add 1 to date to be inclusive of to date
                _dtToDate = _dtToDate.AddDays(1);
                AddCondition(sbWhereClause, oParameters, COL_PRCREDITSHEETS_DATE, "<", _dtToDate);
            }

            // Key Only Criteria
            if (_bKeyOnly)
            {
                AddCondition(sbWhereClause, oParameters, COL_PRCREDITSHEETS_KEYONLY, "=", "Y");
            }

            //OnlyNewListings takes prescedent over IncludeNew
            if (_bOnlyNewListings)
            {
                if (sbWhereClause.Length > 0)
                {
                    sbWhereClause.Append(" AND");
                }

                sbWhereClause.Append(" prcs_NewListing ='Y'");
            }
            else if (!_bIncludeNewListing)
            {
                if (sbWhereClause.Length > 0) {
                    sbWhereClause.Append(" AND");
                }

                sbWhereClause.Append(" prcs_NewListing IS NULL");
            }

            AddCondition(sbWhereClause, oParameters, COL_PRCREDITSHEETS_STATUS, "=", "P");

            AddConnector(sbWhereClause);
            sbWhereClause.Append(GetObjectMgr().GetLocalSourceCondition());
            AddConnector(sbWhereClause);
            sbWhereClause.Append(GetObjectMgr().GetIntlTradeAssociationCondition());

            return sbWhereClause.ToString();
        }

        /// <summary>
        /// Determines the dates to be used for by quarter searches
        /// based on the month supplied
        /// </summary>
        /// <param name="iMonth">Month used to determine quarter</param>
        private void SetDatesByQuarter(int iMonth)
        {
            DateTime dtFromTemp;
            DateTime dtToTemp;

            if (iMonth == 1 || iMonth == 2 || iMonth == 3)
            {
                dtFromTemp = new DateTime(_iYear, 1, 1);
                _dtFromDate = dtFromTemp;
                dtToTemp = new DateTime(_iYear, 3, 31);
                _dtToDate = dtToTemp;
            }
            else if (iMonth == 4 || iMonth == 5 || iMonth == 6)
            {
                dtFromTemp = new DateTime(_iYear, 4, 1);
                _dtFromDate = dtFromTemp;
                dtToTemp = new DateTime(_iYear, 6, 30);
                _dtToDate = dtToTemp;
            }
            else if (iMonth == 7 || iMonth == 8 || iMonth == 9)
            {
                dtFromTemp = new DateTime(_iYear, 7, 1);
                _dtFromDate = dtFromTemp;
                dtToTemp = new DateTime(_iYear, 9, 30);
                _dtToDate = dtToTemp;
            }
            else if (iMonth == 10 || iMonth == 11 || iMonth == 12)
            {
                dtFromTemp = new DateTime(_iYear, 10, 1);
                _dtFromDate = dtFromTemp;
                dtToTemp = new DateTime(_iYear, 12, 31);
                _dtToDate = dtToTemp;
            }
        }
    }
}
