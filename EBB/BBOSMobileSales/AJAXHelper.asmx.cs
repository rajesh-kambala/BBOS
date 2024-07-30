/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2022-2022

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: AJAXHelper.asmx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using PRCo.EBB.BusinessObjects;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Web;
using System.Web.Services;
using TSI.BusinessObjects;
using TSI.DataAccess;
using TSI.Utils;
using Newtonsoft.Json;

namespace Sales
{
    /// <summary>
    /// Summary description for AJAXHelper
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    [System.Web.Script.Services.ScriptService()]
    // To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
    // [System.Web.Script.Services.ScriptService]
    public class AJAXHelper : System.Web.Services.WebService
    {
        protected EBBObjectMgr _oObjectMgr;
        protected IDBAccess _oDBAccess;
        protected ILogger _oLogger;

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
        [System.Web.Script.Services.ScriptMethod]
        public string[] GetQuickFindCompletionList(string prefixText, int count, string contextKey)
        {
            return BuildAutoCompleteList(prefixText, count, false);
        }

        private string[] BuildAutoCompleteList(string prefixText, int count, bool HQOnly)
        {
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

            string szIndustryClause = "comp_PRLocalSource IS NULL AND comp_PRIsIntlTradeAssociation IS NULL";

            string hqOnlyClause = string.Empty;
            if (HQOnly)
                hqOnlyClause = " AND comp_PRType='H' ";

            object[] args = { count, szWhere, szIndustryClause, hqOnlyClause };
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

        [WebMethod(EnableSession = true)]
        public string CompanySearch(string BBNum, string CompanyName, string ListingStatus, string Industry, string State, string SalesTerritory, int Page, int ItemsPerPage)
        {
            CompanySearchCriteria criteria = new CompanySearchCriteria();

            criteria.WebUser = (IPRWebUser)HttpContext.Current.Session["oUser"];

            if(!string.IsNullOrEmpty(BBNum))
                criteria.BBID = Convert.ToInt32(BBNum);
            if (!string.IsNullOrEmpty(CompanyName))
                criteria.CompanyName = CompanyName;
            if (!string.IsNullOrEmpty(ListingStatus))
                criteria.ListingStatus = ListingStatus;

            if (!string.IsNullOrEmpty(Industry))
            {
                criteria.IndustryType = "L";
                if (Industry != "L")
                    criteria.IndustryTypeNotEqual = true;
            }
            else
                criteria.IndustryTypeSkip = true;

            if (!string.IsNullOrEmpty(State))
                criteria.ListingStateIDs = State;
            if (!string.IsNullOrEmpty(SalesTerritory))
                criteria.TerritoryCode = SalesTerritory;

            DataSet ds = MobileSales.CompanySearch(BBNum, CompanyName, ListingStatus, Industry, State, SalesTerritory, Page, ItemsPerPage);
            string jsonString = string.Empty;
            jsonString = JsonConvert.SerializeObject(ds.Tables[0], Formatting.Indented );

            return jsonString;
        }

        #region Helper Methods
        /// <summary>
        /// Returns an instance of an ObjectMgr
        /// </summary>
        /// <returns></returns>
        protected EBBObjectMgr GetObjectMgr()
        {
            if (_oObjectMgr == null)
            {
                _oObjectMgr = new PRWebUserMgr(GetLogger(), null);
            }
            return _oObjectMgr;
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
                _oLogger.RequestName = this.GetType().Name;
            }

            return _oLogger;
        }
        #endregion Helper Methods
    }
}
