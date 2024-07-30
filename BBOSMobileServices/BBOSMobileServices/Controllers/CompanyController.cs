/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2015-2020

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission ofBlue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CompanyController
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Data;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Web.Http;
using BBOSMobile.ServiceModels.Common;
using BBOSMobile.ServiceModels.Requests;
using BBOSMobile.ServiceModels.Responses;
using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;
using TSI.Utils;

namespace BBSI.BBOSMobileServices.Controllers
{
    public class CompanyController : ControllerBase
    {

        [Route("api/company/getrecentlyviewed")]
        [HttpPost]
        [HttpGet]
        public GetRecentlyViewedResponse GetRecentlyViewed(RequestBase request)
        {
            GetRecentlyViewedResponse response = new GetRecentlyViewedResponse();

            SetLoggerMethod("GetRecentlyViewed");
            try
            {
                DateTime dtStart = DateTime.Now;
                IPRWebUser user = GetUserByGuid(request.UserId);
                if (user == null)
                    return (GetRecentlyViewedResponse)SetInvalidUserResponse(response);

                SetLoggerUser(user);

                response.Companies = GetRecentlyViewed(user);
                response.Contacts = new ContactController().GetRecentlyViewed(user);

                InsertAuditRecord(user, "api/company/getrecentlyviewed", 0, 0);

                GetLogger().LogMessage("Method execution time: " + DateTime.Now.Subtract(dtStart).ToString());
                return (GetRecentlyViewedResponse)SetSuccessResponse(response, user);
            }
            catch (Exception e)
            {
                return (GetRecentlyViewedResponse)HandleException(response, e);
            }

        }

        [Route("api/company/quickfind")]
        [HttpPost]
        [HttpGet]
        public QuickFindSearchResponse QuickFind(QuickFindSearchRequest request)
        {
            QuickFindSearchResponse response = new QuickFindSearchResponse();
            SetLoggerMethod("QuickFind");

            try
            {
                DateTime dtStart = DateTime.Now;

                IPRWebUser user = GetUserByGuid(request.UserId);
                if (user == null)
                    return (QuickFindSearchResponse)SetInvalidUserResponse(response);

                SetLoggerUser(user);

                GetLogger().LogMessage($"Search text: {request.SearchText}");
                response.Companies = QuickFind(user, request);
                response.ResultCount = response.Companies.Count();
                GetLogger().LogMessage($"ResultCount: {response.ResultCount}");
                InsertAuditRecord(user, "api/company/quickfind", 0, 0);

                GetLogger().LogMessage("Method execution time: " + DateTime.Now.Subtract(dtStart).ToString());
                return (QuickFindSearchResponse)SetSuccessResponse(response, user);
            }
            catch (Exception e)
            {
                return (QuickFindSearchResponse)HandleException(response, e);
            }

        }

        [Route("api/company/search")]
        [HttpPost]
        [HttpGet]
        public CompanySearchResponse Search(CompanySearchRequest request)
        {
            CompanySearchResponse response = new CompanySearchResponse();

            SetLoggerMethod("Search");
            try
            {
                DateTime dtStart = DateTime.Now;

                IPRWebUser user = GetUserByGuid(request.UserId);
                if (user == null)
                    return (CompanySearchResponse)SetInvalidUserResponse(response);    

                SetLoggerUser(user);

                response.ResultCount = SearchCount(user, request);
                if (response.ResultCount > 0) {
                    response.Companies = Search(user, request);
                }
                response.CategoryListsItems = GetCategoryList(user, request.CategoryListsLastUpdated);
                InsertAuditRecord(user, "api/company/search", 0, 0);

                GetLogger().LogMessage("Method execution time: " + DateTime.Now.Subtract(dtStart).ToString());
                return (CompanySearchResponse)SetSuccessResponse(response, user);
            }
            catch (Exception e)
            {
                return (CompanySearchResponse)HandleException(response, e);
            }

        }

        [Route("api/company/getcompany")]
        [HttpPost]
        [HttpGet]
        public GetCompanyResponse GetCompany(GetCompanyRequest request)
        {
            GetCompanyResponse response = new GetCompanyResponse();

            SetLoggerMethod("GetCompany");
            try
            {
                DateTime dtStart = DateTime.Now;

                IPRWebUser user = GetUserByGuid(request.UserId);
                if (user == null)
                    return (GetCompanyResponse)SetInvalidUserResponse(response);

                SetLoggerUser(user);

                response.Company = GetCompany(user, request.BBID);
                InsertAuditRecord(user, "api/company/getcompany", request.BBID, 0);

                GetLogger().LogMessage("Method execution time: " + DateTime.Now.Subtract(dtStart).ToString());
                return (GetCompanyResponse)SetSuccessResponse(response, user);
            }
            catch (Exception e)
            {
                return (GetCompanyResponse)HandleException(response, e);
            }

        }

        [Route("api/company/getcompanynotes")]
        [HttpPost]
        [HttpGet]
        public GetCompanyNotesResponseModel GetCompanyNotes(GetCompanyNotesRequest request)
        {
            GetCompanyNotesResponseModel response = new GetCompanyNotesResponseModel();

            SetLoggerMethod("GetCompanyNotes");
            try
            {
                IPRWebUser user = GetUserByGuid(request.UserId);
                if (user == null)
                {
                    return (GetCompanyNotesResponseModel)SetInvalidUserResponse(response);
                }

                SetLoggerUser(user);

                response.Notes = PopulateNotes(user, request.BBID); ;
                InsertAuditRecord(user, "api/company/getcompanynotes", request.BBID, 0);
                return (GetCompanyNotesResponseModel)SetSuccessResponse(response, user);
            }
            catch (Exception e)
            {
                return (GetCompanyNotesResponseModel)HandleException(response, e);
            }

        }


        [Route("api/company/getcompanycontacts")]
        [HttpPost]
        [HttpGet]
        public GetCompanyContactsResponseModel GetCompanyContacts(GetCompanyContactsRequest request)
        {
            GetCompanyContactsResponseModel response = new GetCompanyContactsResponseModel();

            SetLoggerMethod("GetCompanyContacts");
            try
            {
                DateTime dtStart = DateTime.Now;

                IPRWebUser user = GetUserByGuid(request.UserId);
                if (user == null)
                    return (GetCompanyContactsResponseModel)SetInvalidUserResponse(response);

                SetLoggerUser(user);

                response.Contacts = GetContacts(user, request.BBID);
                InsertAuditRecord(user, "api/company/getcompanycontacts", request.BBID, 0);

                GetLogger().LogMessage("Method execution time: " + DateTime.Now.Subtract(dtStart).ToString());
                return (GetCompanyContactsResponseModel)SetSuccessResponse(response, user);
            }
            catch (Exception e)
            {
                return (GetCompanyContactsResponseModel)HandleException(response, e);
            }

        }

        [Route("api/company/savecompanynote")]
        [HttpPost]
        [HttpGet]
        public ResponseBase SaveCompanyNote(SaveCompanyNoteRequest request)
        {
            ResponseBase response = new ResponseBase();

            SetLoggerMethod("SaveCompanyNote");
            try
            {
                DateTime dtStart = DateTime.Now;

                IPRWebUser user = GetUserByGuid(request.UserId);
                if (user == null)
                    return SetInvalidUserResponse(response);

                SetLoggerUser(user);
                SaveNote(user, request.NoteID, Convert.ToInt32(request.BBID), "C", request.Note, request.Private);
                InsertAuditRecord(user, "api/company/savecompanynote", request.BBID, 0);

                GetLogger().LogMessage("Method execution time: " + DateTime.Now.Subtract(dtStart).ToString());
                return SetSuccessResponse(response, user);
            }
            catch (Exception e)
            {
                return HandleException(response, e);
            }

        }

        [Route("api/company/savecontactnote")]
        [HttpPost]
        [HttpGet]
        public ResponseBase SaveContactNote(SaveContactNoteRequest request)
        {
            ResponseBase response = new ResponseBase();

            SetLoggerMethod("SaveContactNote");
            try
            {
                DateTime dtStart = DateTime.Now;

                IPRWebUser user = GetUserByGuid(request.UserId);
                if (user == null)
                    return SetInvalidUserResponse(response);

                SetLoggerUser(user);

                string note = null;
                if (request.Note != null)
                    note = request.Note.NoteText;

                SaveNote(user, request.NoteID, request.ContactID, "P", note, true);
                InsertAuditRecord(user, "api/company/savecontactnote", request.BBID, request.ContactID);

                GetLogger().LogMessage("Method execution time: " + DateTime.Now.Subtract(dtStart).ToString());
                return SetSuccessResponse(response, user);
            }
            catch (Exception e)
            {
                return HandleException(response, e);
            }

        }

        [Route("api/company/savetradereport")]
        [HttpPost]
        [HttpGet]
        public SaveTradeReportResponse SaveTradeReport(SaveTradeReportRequest request)
        {
            ResponseBase response = new SaveTradeReportResponse();

            SetLoggerMethod("SaveTradeReport");
            try
            {
                DateTime dtStart = DateTime.Now;

                IPRWebUser user = GetUserByGuid(request.UserId);
                if (user == null)
                    return (SaveTradeReportResponse)SetInvalidUserResponse(response);

                SetLoggerUser(user);
                AddOnlineTradeReport(user, request);

                InsertAuditRecord(user, "api/company/savetradereport");

                GetLogger().LogMessage("Method execution time: " + DateTime.Now.Subtract(dtStart).ToString());
                return (SaveTradeReportResponse)SetSuccessResponse(response, user);
            }
            catch (Exception e)
            {
                return (SaveTradeReportResponse)HandleException(response, e);
            }

        }

        #region DataAccess
        protected const string SQL_RECENT_COMPANIES =
            @"FROM dbo.ufn_GetRecentCompanies(@WebUserID, @CompanyLimit)  
                   INNER JOIN vPRBBOSCompanyList ON CompanyID = comp_CompanyID 
                   LEFT OUTER JOIN vPRCurrentRating compRating ON comp_CompanyID = compRating.prra_CompanyID 
                   LEFT OUTER JOIN vPRCurrentRating hqRating ON comp_PRHQID = hqRating.prra_CompanyID ";

        protected List<CompanyBase> GetRecentlyViewed(IPRWebUser user)
        {
            ArrayList parameters = new ArrayList();
            parameters.Add(new ObjectParameter("CompanyLimit", Utilities.GetIntConfigValue("RecentViewsTopNCompanies", 10)));
            parameters.Add(new ObjectParameter("WebUserID", user.prwu_WebUserID));
            parameters.Add(new ObjectParameter("HQID", user.prwu_HQID));

            string sql = SQL_COMPANY_BASE_SELECT + SQL_RECENT_COMPANIES + " WHERE " + GetObjectMgr(user).GetLocalSourceCondition() + " ORDER BY ndx";
            return PopulateCompanyBase(sql, parameters);
        }



        protected const string SQL_QUICKFIND_AUTOCOMPLETE =
            @"SELECT * FROM (
                SELECT vPRBBOSCompanyList.*, 
                        dbo.ufn_GetCustomCaptionValue('comp_PRIndustryTypeBBOS', comp_PRIndustryType, 'en-us') As IndustryType,
                        dbo.ufn_GetCustomCaptionValue('comp_PRType_BBOS', comp_PRType, 'en-us') As CompanyType,
                        dbo.ufn_HasNote(@WebUserID, @HQID, comp_CompanyID, 'C') As HasNote,
                        CASE WHEN comp_PRType = 'B' THEN CASE WHEN compRating.prra_RatingID IS NOT NULL THEN 'N' ELSE 'Y' END ELSE 'N' END AS IsHQRating,
                        CASE WHEN comp_PRType = 'B' THEN CASE WHEN compRating.prra_RatingID IS NOT NULL THEN compRating.prra_RatingLine ELSE hqRating.prra_RatingLine END ELSE hqRating.prra_RatingLine END AS prra_RatingLine, 
                        ROW_NUMBER() OVER(ORDER BY comp_PRBookTradestyle) AS NUMBER
                   FROM vPRBBOSCompanyList  
                        INNER JOIN PRCompanySearch WITH (NOLOCK) on comp_CompanyID = prcse_CompanyID 
                        LEFT OUTER JOIN vPRCurrentRating compRating ON comp_CompanyID = compRating.prra_CompanyID 
                        LEFT OUTER JOIN vPRCurrentRating hqRating ON comp_PRHQID = hqRating.prra_CompanyID 
                   WHERE ({0})
                     AND {1} 
                     AND {2}
                     AND comp_PRListingStatus IN ('L','H','LUV', 'N5') ) as TblA
                WHERE NUMBER  BETWEEN ((@PageNumber - 1)  * @RowspPage + 1)  AND (@PageNumber * @RowspPage)
                ORDER BY comp_PRBookTradestyle, comp_PRType DESC";

        protected List<CompanyBase> QuickFind(IPRWebUser user, QuickFindSearchRequest request)
        {

            ArrayList parameters = new ArrayList();
            string szWhere = string.Empty;

            char[] acDelimiter = { '|' };
            string[] aszTokens = request.SearchText.Split(acDelimiter);

            foreach (string szToken in aszTokens) {
                if (szWhere.Length > 0) {
                    szWhere += " OR ";
                }

                string szCleanToken = SearchCriteriaBase.CleanString(szToken);
                string szStartsWith = "StartsWith" + parameters.Count.ToString();
                parameters.Add(new ObjectParameter(szStartsWith, szCleanToken + "%"));

                szWhere += "(prcse_NameMatch LIKE @" + szStartsWith + " OR ISNULL(prcse_LegalNameMatch, '') LIKE @" + szStartsWith + " OR prcse_CorrTradestyleMatch LIKE @" + szStartsWith + ")";
            }

            int iBBID = 0;
            if (Int32.TryParse(request.SearchText, out iBBID)) {

                if (iBBID > 99999) {

                    parameters.Add(new ObjectParameter("BBID", iBBID));
                    szWhere += " OR comp_CompanyID=@BBID";
                }
                    

            }


            string szIndustryClause = null;
            if (user.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                szIndustryClause = "comp_PRIndustryType = 'L'";
            } else if (user.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_WINEGRAPE)
            {
                szIndustryClause = "comp_PRIndustryType = 'W'";
            } else {
                szIndustryClause = "comp_PRIndustryType <> 'L'";
            }


            object[] args = { szWhere, szIndustryClause, GetObjectMgr(user).GetLocalSourceCondition()};
            string sql = string.Format(SQL_QUICKFIND_AUTOCOMPLETE, args);

            
            parameters.Add(new ObjectParameter("PageNumber", request.PageIndex + 1));
            parameters.Add(new ObjectParameter("RowspPage", request.PageSize));
            parameters.Add(new ObjectParameter("WebUserID", user.prwu_WebUserID));
            parameters.Add(new ObjectParameter("HQID", user.prwu_HQID));

            return PopulateCompanyBase(sql, parameters);
            
        }



        protected const string SQL_SEARCH =
            @"SELECT * FROM (
	                SELECT vPRBBOSCompanyList.*, 
			                dbo.ufn_GetCustomCaptionValue('comp_PRIndustryTypeBBOS', comp_PRIndustryType, 'en-us') As IndustryType,
			                dbo.ufn_GetCustomCaptionValue('comp_PRType_BBOS', comp_PRType, 'en-us') As CompanyType,
                            dbo.ufn_HasNote(@WebUserID, @HQID, comp_CompanyID, 'C') As HasNote,
                            CASE WHEN comp_PRType = 'B' THEN CASE WHEN compRating.prra_RatingID IS NOT NULL THEN 'N' ELSE 'Y' END ELSE 'N' END AS IsHQRating,
                            CASE WHEN comp_PRType = 'B' THEN CASE WHEN compRating.prra_RatingID IS NOT NULL THEN compRating.prra_RatingLine ELSE hqRating.prra_RatingLine END ELSE hqRating.prra_RatingLine END AS prra_RatingLine, 
			                ROW_NUMBER() OVER(ORDER BY comp_PRBookTradestyle) AS NUMBER
	                FROM vPRBBOSCompanyList
			                LEFT OUTER JOIN vPRCurrentRating compRating ON comp_CompanyID = compRating.prra_CompanyID 
			                LEFT OUTER JOIN vPRCurrentRating hqRating ON comp_PRHQID = hqRating.prra_CompanyID 
	                WHERE comp_CompanyID IN ({0})) as TblA
                WHERE NUMBER  BETWEEN ((@PageNumber - 1)  * @RowspPage + 1)  AND (@PageNumber * @RowspPage)
                ORDER BY comp_PRBookTradestyle, comp_PRType DESC";

        protected List<CompanyBase> Search(IPRWebUser user, CompanySearchRequest request)
        {

            IPRWebUserSearchCriteria oWebUserSearchCriteria = GetSearchCriteria(user, request);
            CompanySearchCriteria criteria = (CompanySearchCriteria)oWebUserSearchCriteria.Criteria;
            criteria.WebUser = user;


            // Generate the sql required to retrieve the search results            
            ArrayList parameters;
            string sql = string.Format(SQL_SEARCH, criteria.GetSearchSQL(out parameters));

            parameters.Add(new ObjectParameter("PageNumber", request.PageIndex + 1));
            parameters.Add(new ObjectParameter("RowspPage", request.PageSize));
            parameters.Add(new ObjectParameter("WebUserID", user.prwu_WebUserID));
            parameters.Add(new ObjectParameter("HQID", user.prwu_HQID));

            List<CompanyBase> results = PopulateCompanyBase(sql, parameters);

            oWebUserSearchCriteria.prsc_ExecutionCount++;
            oWebUserSearchCriteria.prsc_LastExecutionDateTime = DateTime.Now;
            oWebUserSearchCriteria.prsc_LastExecutionResultCount = results.Count;

            InsertSearchAuditRecord(user, oWebUserSearchCriteria);

            return results;
        }

        protected const string SQL_SEARCH_COUNT =
                @"SELECT COUNT(1)
	                FROM vPRBBOSCompanyList
	               WHERE comp_CompanyID IN ({0})";


        protected int SearchCount(IPRWebUser user, CompanySearchRequest request)
        {
            IPRWebUserSearchCriteria oWebUserSearchCriteria = GetSearchCriteria(user, request);
            CompanySearchCriteria criteria = (CompanySearchCriteria)oWebUserSearchCriteria.Criteria;
            criteria.WebUser = user;

            // Generate the sql required to retrieve the search results            
            ArrayList parameters;
            string sql = string.Format(SQL_SEARCH_COUNT, criteria.GetSearchSQL(out parameters));

            int searchCount = (int)GetDBAccess().ExecuteScalar(sql, parameters);
            return searchCount;
        }


        protected IPRWebUserSearchCriteria GetSearchCriteria(IPRWebUser user, CompanySearchRequest request)
        {
            IPRWebUserSearchCriteria oWebUserSearchCriteria = (IPRWebUserSearchCriteria)new PRWebUserSearchCriteriaMgr(GetLogger(), user).CreateObject();
            oWebUserSearchCriteria.prsc_SearchType = PRWebUserSearchCriteria.SEARCH_TYPE_COMPANY;
            oWebUserSearchCriteria.prsc_HQID = user.prwu_HQID;
            oWebUserSearchCriteria.prsc_CompanyID = user.prwu_BBID;
            oWebUserSearchCriteria.prsc_WebUserID = user.prwu_WebUserID;

            CompanySearchCriteria criteria = (CompanySearchCriteria)oWebUserSearchCriteria.Criteria;
            criteria.WebUser = user;
            criteria.PayReportCount = -1;
            criteria.ListingStatus = "L,H,LUV";

            criteria.CompanyName = request.CompanyName;
            if (!string.IsNullOrEmpty(request.BBID)) {
                criteria.BBID = Convert.ToInt32(request.BBID);
            }

            criteria.IndustryType = GetIndustryType(request);
            criteria.CompanyType = GetCompanyType(request);
            criteria.ListingCity = request.City;
            criteria.ListingStateIDs = request.State;
            criteria.ListingPostalCode = request.PostalCode;
            criteria.Radius = Convert.ToInt32(request.Radius);
            criteria.TerminalMarketIDs = request.TerminalMarket;

            if (criteria.Radius > -1) {
                if (!string.IsNullOrEmpty(criteria.TerminalMarketIDs)) {
                    criteria.RadiusType = CompanySearchCriteria.CODE_RADIUSTYPE_TERMINALMARKET;
                }
                else {
                    criteria.RadiusType = CompanySearchCriteria.CODE_RADIUSTYPE_LISTINGPOSTALCODE;
                }
            }
            else {

                if (!string.IsNullOrEmpty(criteria.ListingPostalCode)) {
                    criteria.Radius = 0;
                    criteria.RadiusType = CompanySearchCriteria.CODE_RADIUSTYPE_LISTINGPOSTALCODE;
                }
            }


            criteria.BBScore = Convert.ToInt32(request.BBScore);
            criteria.BBScoreSearchType = ">";

            criteria.RatingIntegrityIDs = GetIntegrityRating(request);
            criteria.RatingPayIDs = GetPayRating(request);
            criteria.RatingCreditWorthIDs = GetCreditWorthRating(user, request);

            if (criteria.IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER) {
                if (request.SpecieId > 0) {
                    criteria.SpecieIDs = request.SpecieId.ToString();
                    criteria.SpecieSearchType = "Any";
                }

                if (request.ProductId > 0) {
                    criteria.ProductProvidedIDs = request.ProductId.ToString();
                    criteria.ProductProvidedSearchType = "Any";
                }

                if (request.ServiceId > 0) {
                    criteria.ServiceProvidedIDs = request.ServiceId.ToString();
                    criteria.ServiceProvidedSearchType = "Any";
                }

                criteria.PayIndicator = GetPayIndicator(request);
                criteria.PayReportCount = GetPayReportCount(request);
                criteria.PayReportCountSearchType = ">";
            }
            else {
                if (request.CommodityId > 0) {
                    criteria.CommodityIDs = request.CommodityId.ToString();
                    criteria.CommoditySearchType = "Any";
                }
            }


            if (request.ClassificationId > 0) {
                string childIDs = GetChildClassifications(request.ClassificationId);
                if (!string.IsNullOrEmpty(childIDs)) {
                    criteria.ClassificationIDs = childIDs;
                }
                else {
                    criteria.ClassificationIDs = request.ClassificationId.ToString();
                }

                criteria.ClassificationSearchType = "Any";
            }

            return oWebUserSearchCriteria;
        }

        protected const string SQL_CLASSIFICATIONS_LEVEL_2 =
            @"SELECT prcl_ClassificationId
                FROM PRClassification WITH (NOLOCK)
               WHERE prcl_ParentId = @ClassificationID
                 AND prcl_Level IN (2)
            ORDER BY prcl_DisplayOrder;";

        protected string GetChildClassifications(int ClassificationId)
        {
            ArrayList parameters = new ArrayList();
            parameters.Add(new ObjectParameter("ClassificationID", ClassificationId));

            StringBuilder idList = new StringBuilder();

            using (IDataReader reader = GetDBAccess().ExecuteReader(SQL_CLASSIFICATIONS_LEVEL_2, parameters, CommandBehavior.CloseConnection, null))
            {
                while (reader.Read())
                {
                    if (idList.Length > 0)
                    {
                        idList.Append(",");
                    }

                    idList.Append(reader.GetInt32(0).ToString());
                }
            }

            return idList.ToString();
        }


        protected const string SQL_SELECT_STATES =
            @"SELECT prst_StateID
                FROM PRState WITH (NOLOCK)
               WHERE prst_CountryId IN (1, 2)
                 AND prst_Abbreviation IN (SELECT value FROM dbo.Tokenize(@StateList, ','))
            ORDER BY prst_StateId;";

        protected string GetStateIDList(string stateAbbreviations)
        {
            if (string.IsNullOrEmpty(stateAbbreviations))
            {
                return null;
            }

            ArrayList parameters = new ArrayList();
            parameters.Add(new ObjectParameter("StateList", stateAbbreviations));

            StringBuilder idList = new StringBuilder();

            using (IDataReader reader = GetDBAccess().ExecuteReader(SQL_SELECT_STATES, parameters, CommandBehavior.CloseConnection, null))
            {
                while (reader.Read())
                {
                    if (idList.Length > 0)
                    {
                        idList.Append(",");
                    }

                    idList.Append(reader.GetInt32(0).ToString());
                }
            }

            return idList.ToString();
        }


        protected string GetCompanyType(CompanySearchRequest request)
        {

            switch (request.SearchType)
            {
                case Enumerations.SearchType.Headquarters:
                    return "H";
                case Enumerations.SearchType.Branch:
                    return "B";
            }

            return null;
        }


        protected string GetIntegrityRating(CompanySearchRequest request)
        {

            switch (request.IntegrityRating)
            {
                case Enumerations.IntegrityRating.XXX:
                    return "5";
                case Enumerations.IntegrityRating.XXXOrHigher:
                    return "5,6";
                case Enumerations.IntegrityRating.XXXX:
                    return "6";
            }

            return null;
        }

        protected string GetPayRating(CompanySearchRequest request)
        {

            switch (request.PayDescription)
            {
                case Enumerations.PayDescription.AOrHigher:
                    return "8,9";
                case Enumerations.PayDescription.BOrHigher:
                    return "6,8,9";
                case Enumerations.PayDescription.COrHigher:
                    return "5,6,8,9";
            }

            return null;
        }

        protected string GetCreditWorthRating(IPRWebUser user, CompanySearchRequest request)
        {
            if (user.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                switch (request.CreditWorthRating)
                {
                    case Enumerations.CreditWorthRating._500mil_orHigher:
                        return "60,61,62,63,65,65,66,67,68,69,70,71,72,73,74,75,76,77,78";
                    case Enumerations.CreditWorthRating._100mil_orHigher:
                        return "54,55,56,57,58,59,60,61,62,63,65,65,66,67,68,69,70,71,72,73,74,75,76,77,78";
                    case Enumerations.CreditWorthRating._5mil_orHigher:
                        return "46,47,48,49,50,51,52,52,54,55,56,57,58,59,60,61,62,63,65,65,66,67,68,69,70,71,72,73,74,75,76,77,78";
                }
            }
            else
            {
                switch (request.CreditWorthRating)
                {
                    case Enumerations.CreditWorthRating._500mil_orHigher:
                        return "26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44";
                    case Enumerations.CreditWorthRating._100mil_orHigher:
                        return "20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44";
                    case Enumerations.CreditWorthRating._5mil_orHigher:
                        return "12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44";
                }
            }


            return null;
        }

        protected string GetPayIndicator(CompanySearchRequest request)
        {

            switch (request.PayIndicator)
            {
                case Enumerations.PayIndicator.A:
                    return "A";
                case Enumerations.PayIndicator.BOrHigher:
                    return "A,B";
                case Enumerations.PayIndicator.COrHigher:
                    return "A,B,C";
            }

            return null;
        }


        protected int GetPayReportCount(CompanySearchRequest request)
        {

            switch (request.CurrentPayReport)
            {
                case Enumerations.CurrentPayReport.GreaterThan__1:
                    return 1;
                case Enumerations.CurrentPayReport.GreaterThan__2:
                    return 2;
                case Enumerations.CurrentPayReport.GreaterThan__3:
                    return 3;
                case Enumerations.CurrentPayReport.GreaterThan__4:
                    return 4;
            }

            return -1;
        }


        protected const string SQL_SELECT_COMPANY =
            @"SELECT TOP 1 *
                FROM vPRBBOSCompany
               WHERE comp_CompanyID=@CompanyID";

        protected Company GetCompany(IPRWebUser user, int companyID)
        {
            Company company = new Company();

            string industryType = null;
            int ratingID = 0;
            int companyPayIndicatorID = 0;

            ArrayList parameters = new ArrayList();
            parameters.Add(new ObjectParameter("CompanyID", companyID));

            using (IDataReader reader = GetDBAccess().ExecuteReader(SQL_SELECT_COMPANY, parameters, CommandBehavior.CloseConnection, null))
            {
                if (reader.Read())
                {
                    industryType = GetDBAccess().GetString(reader, "comp_PRIndustryType");
                    ratingID = GetDBAccess().GetInt32(reader, "prra_RatingID");

                    company.BBID = GetDBAccess().GetInt32(reader, "comp_CompanyID");
                    company.Name = GetDBAccess().GetString(reader, "comp_PRCorrTradestyle");
                    company.Location = GetDBAccess().GetString(reader, "CityStateCountryShort");
                    company.Rating = GetRatingLine(reader);

                    if (GetBool(GetDBAccess().GetString(reader, "prbs_PRPublish")) &&
                        GetBool(GetDBAccess().GetString(reader, "comp_PRPublishBBScore")))
                    {
                        company.BlueBookScore = GetDBAccess().GetDecimal(reader, "prbs_BBScore").ToString("000");
                    }

                    company.Industry = GetDBAccess().GetString(reader, "IndustryType");
                    company.Type = GetDBAccess().GetString(reader, "PRType");
                    company.Status = GetDBAccess().GetString(reader, "ListingStatus");
                    company.Phone = GetDBAccess().GetString(reader, "Phone");
                    company.TollFree = GetDBAccess().GetString(reader, "TollFree");
                    company.Fax = GetDBAccess().GetString(reader, "Fax");
                    company.Web = GetDBAccess().GetString(reader, "emai_PRWebAddress");
                    company.Email = GetDBAccess().GetString(reader, "Email");
                    company.IsLocalSource = GetBool(GetDBAccess().GetString(reader, "comp_PRLocalSource"));

                    if (industryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                    {
                        company.CreditWorthRating = GetDBAccess().GetString(reader, "prcw_Name");
                        company.RatingKeyNumbers = GetDBAccess().GetString(reader, "prra_AssignedRatingNumerals");

                        if (GetBool(GetDBAccess().GetString(reader, "comp_PRPublishPayIndicator")))
                        {
                            company.PayIndicator = GetDBAccess().GetString(reader, "prcpi_PayIndicator");
                            companyPayIndicatorID = GetDBAccess().GetInt32(reader, "prcpi_CompanyPayIndicatorID");
                        }

                        company.CurrentPayReports = GetDBAccess().GetInt32(reader, "PayReportCount");
                        
                    }
                }
            }

            company.MapAddress = GetMapAddress(companyID);

            ObservableCollection<Rating> ratings = GetRatingDefinition(ratingID);
            if (industryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                ratings.Add(GetPayIndicatorDefinition(companyPayIndicatorID));
            }
            company.Ratings = ratings;

            company.SocialMedia = GetSocialMedia(companyID);
            company.Listing = GetListing(companyID);
            company.Classifications = GetClassifications(companyID);
            //company.Contacts = GetContacts(user, companyID);

            if (industryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                company.Products = GetProducts(companyID);
                company.Services = GetServices(companyID);
                company.Species = GetSpecie(companyID);
            }
            else
            {
                company.Commodities = GetCommodities(companyID);
            }

            company.HasNotes = HasNotes(user, companyID);
            company.IsWatchDog = IsOnWatchdogList(user, companyID);

            return company;
        }


        protected const string SQL_SOCIAL_MEDIA =
            @"SELECT prsm_SocialMediaTypeCode, prsm_URL
                FROM PRSocialMedia WITH (NOLOCK) 
               WHERE prsm_CompanyID=@CompanyID AND prsm_Disabled IS NULL";

        protected List<SocialMedia> GetSocialMedia(int companyID)
        {

            List<SocialMedia> list = new List<SocialMedia>();

            ArrayList parameters = new ArrayList();
            parameters.Add(new ObjectParameter("CompanyID", companyID));

            using (IDataReader oReader = GetDBAccess().ExecuteReader(SQL_SOCIAL_MEDIA, parameters, CommandBehavior.CloseConnection, null))
            {
                while (oReader.Read())
                {
                    SocialMedia socialMedia = new SocialMedia();
                    socialMedia.Media = oReader.GetString(0) + ".png";
                    socialMedia.Url = oReader.GetString(1);

                    list.Add(socialMedia);
                }
            }

            return list;
        }

        protected const string SQL_GET_LISTING = "SELECT dbo.ufn_GetListingCache(@CompanyID, @FormattingStyle)";

        protected string GetListing(int companyID)
        {
            ArrayList parameters = new ArrayList();
            parameters.Add(new ObjectParameter("CompanyID", companyID));
            parameters.Add(new ObjectParameter("FormattingStyle", 0));

            object oListing = GetDBAccess().ExecuteScalar(SQL_GET_LISTING, parameters);
            if (oListing != DBNull.Value)
            {
                return Convert.ToString(oListing);
            }

            return null;
        }



        protected const string SQL_SELECT_PERSONS2 =
            @"SELECT vPRBBOSPersonList.*,
                     prwun_WebUserNoteID
	            FROM vPRBBOSPersonList
	                 LEFT OUTER JOIN PRWebUserNote WITH (NOLOCK) ON prwun_AssociatedID = pers_PersonID AND prwun_AssociatedType='P' AND prwun_WebUserID=9999
            WHERE peli_CompanyID=@CompanyID 
            ORDER BY TitleCodeOrder";

        protected const string SQL_SELECT_PERSONS =
            @"SELECT peli_CompanyID, pers_PersonID, peli_PersonLinkID, RTRIM(pers_FirstName) As pers_FirstName, RTRIM(pers_LastName) as pers_LastName, dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, pers_PRNickname1, pers_Suffix) as PersonName, peli_PRTitle, RTRIM(emai_EmailAddress) As Email, 
    peli_PRTitleCode, tcc.capt_order as TitleCodeOrder,
	tcc.capt_us as GenericTitle,
	peli_PRSequence,
	ISNULL(ISNULL(pphone.phon_PRDescription, pcc.capt_us) + ': ' + dbo.ufn_FormatPhone(pphone.phon_CountryCode, pphone.phon_AreaCode, pphone.phon_Number, pphone.phon_PRExtension), 'Company: ' + dbo.ufn_FormatPhone(cphone.phon_CountryCode, cphone.phon_AreaCode, cphone.phon_Number, cphone.phon_PRExtension)) As Phone, 
	ISNULL(ISNULL(pfax.phon_PRDescription, fcc.capt_us) + ': ' + dbo.ufn_FormatPhone(pfax.phon_CountryCode, pfax.phon_AreaCode, pfax.phon_Number, pfax.phon_PRExtension), dbo.ufn_FormatPhone(cfax.phon_CountryCode, cfax.phon_AreaCode, cfax.phon_Number, cfax.phon_PRExtension)) As Fax,
	ROW_NUMBER() OVER (PARTITION BY peli_CompanyID ORDER BY peli_PRSequence) as DefaultSequence,
    prwun_WebUserNoteID
FROM Person WITH (NOLOCK) 
	INNER JOIN Person_Link WITH (NOLOCK) on pers_PersonID = peli_PersonID 
	INNER JOIN custom_captions tcc WITH (NOLOCK) ON tcc.capt_family = 'pers_TitleCode' and tcc.capt_code = peli_PRTitleCode 
	LEFT OUTER JOIN vPRPersonEmail em WITH (NOLOCK) ON peli_PersonID = em.ELink_RecordID AND peli_CompanyID = emai_CompanyID AND em.ELink_Type='E' AND em.emai_PRPreferredPublished='Y' 
	LEFT OUTER JOIN vPRCompanyPhone cfax WITH (NOLOCK) ON peli_CompanyID = cfax.PLink_RecordID AND cfax.phon_PRIsFax = 'Y' AND cfax.phon_PRPreferredPublished = 'Y'  
	LEFT OUTER JOIN vPRCompanyPhone cphone WITH (NOLOCK) ON peli_CompanyID = cphone.PLink_RecordID AND cphone.phon_PRIsPhone = 'Y' AND cphone.phon_PRPreferredPublished = 'Y'  
	LEFT OUTER JOIN vPRPersonPhone pfax WITH (NOLOCK) ON peli_PersonID = pfax.PLink_RecordID AND peli_CompanyID = pfax.phon_CompanyID AND pfax.phon_PRIsFax = 'Y' AND pfax.phon_PRPreferredPublished = 'Y'  
	LEFT OUTER JOIN Custom_Captions fcc WITH (NOLOCK) ON fcc.capt_family = 'Phon_TypePerson' and fcc.capt_code = pfax.PLink_Type 
	LEFT OUTER JOIN vPRPersonPhone pphone WITH (NOLOCK) ON  peli_PersonID = pphone.PLink_RecordID AND peli_CompanyID = pphone.phon_CompanyID AND pphone.phon_PRIsPhone = 'Y' AND pphone.phon_PRPreferredPublished = 'Y'  
	LEFT OUTER JOIN Custom_Captions pcc WITH (NOLOCK)  ON pcc.capt_family = 'Phon_TypePerson' and pcc.capt_code = pphone.PLink_Type 
    LEFT OUTER JOIN PRWebUserNote WITH (NOLOCK) ON prwun_AssociatedID = pers_PersonID AND prwun_AssociatedType='P' AND prwun_WebUserID=@WebUserID
WHERE peli_PRStatus = '1' 
AND peli_PREBBPublish = 'Y'
AND peli_CompanyID=@CompanyID 
            ORDER BY TitleCodeOrder";

        protected List<Contact> GetContacts(IPRWebUser webuser, int companyID)
        {

            List<Contact> list = new List<Contact>();

            ArrayList parameters = new ArrayList();
            parameters.Add(new ObjectParameter("CompanyID", companyID));
            parameters.Add(new ObjectParameter("WebUserID", webuser.prwu_WebUserID));

            using (IDataReader reader = GetDBAccess().ExecuteReader(SQL_SELECT_PERSONS, parameters, CommandBehavior.CloseConnection, null))
            {
                while (reader.Read())
                {
                    Contact contact = new Contact();
                    contact.ContactID = GetDBAccess().GetInt32(reader, "pers_PersonID");
                    contact.Name = GetDBAccess().GetString(reader, "PersonName");
                    contact.FirstName = GetDBAccess().GetString(reader, "pers_FirstName");
                    contact.LastName = GetDBAccess().GetString(reader, "pers_LastName");
                    contact.Title = GetDBAccess().GetString(reader, "peli_PRTitle");
                    contact.Email = GetDBAccess().GetString(reader, "Email");
                    contact.Phone = GetDBAccess().GetString(reader, "Phone");
                    contact.Fax = GetDBAccess().GetString(reader, "Fax");

                    if (GetDBAccess().GetInt32(reader, "prwun_WebUserNoteID") > 0)
                    {
                        contact.HasNotes = true;
                        contact.NoteID = GetDBAccess().GetInt32(reader, "prwun_WebUserNoteID");
                    }

                    list.Add(contact);
                }
            }

            foreach(Contact contact in list) {
                if (contact.HasNotes)
                {
                    SetNote(webuser, contact);
                }
            }
           

            return list;
        }



        protected const string SQL_CLASSIFICATIONS_SELECT =
            @"SELECT a.prcl_ClassificationID, a.prcl_Name as Name, a.prcl_Abbreviation, a.prcl_Description As Description, a.prcl_BookSection
                FROM PRCompanyClassification WITH (NOLOCK) 
                     INNER JOIN PRClassification a WITH (NOLOCK) ON prc2_ClassificationID = prcl_ClassificationID 
                     INNER JOIN PRClassification b WITH (NOLOCK) ON CASE WHEN CHARINDEX(',', a.prcl_Path)  = 0 THEN a.prcl_Path ELSE LEFT(a.prcl_Path, CHARINDEX(',', a.prcl_Path)-1) END = b.prcl_ClassificationID 
               WHERE prc2_CompanyID = @CompanyID 
            ORDER BY b.prcl_Name, a.prcl_Abbreviation, a.prcl_Description";

        protected List<BBOSMobile.ServiceModels.Common.Classification> GetClassifications(int companyID)
        {
            ArrayList parameters = new ArrayList();
            parameters.Add(new ObjectParameter("CompanyID", companyID));

            return GetClassifications(SQL_CLASSIFICATIONS_SELECT, parameters);
        }


        protected const string SQL_COMMODITY_SELECT =
            @"SELECT * 
              FROM (
            SELECT prcca_CommodityId, prcx_Description, prcca_PublishedDisplay,
                        CASE WHEN prcx_Description IS NULL 
                            THEN ISNULL(GrowingMethod + ' ', '') +
                                ISNULL(AttributeName + ' ', '') +
   					            CASE WHEN prcca_ListingCol2 <> '' THEN prcca_ListingCol2  + ' ' ELSE '' END +
		                        prcca_ListingCol1 
                            ELSE prcx_Description END as TmpDescription 
                FROM vListingPRCompanyCommodity 
                WHERE prcca_CompanyID=@CompanyID 
	            ) T1
            ORDER BY ISNULL(prcx_Description, TmpDescription), prcca_PublishedDisplay";

        /// <summary>
        /// Populates the commodities portion of the page.
        /// </summary>
        protected List<BBOSMobile.ServiceModels.Common.Commodity> GetCommodities(int companyID)
        {
            ArrayList parameters = new ArrayList();
            parameters.Add(new ObjectParameter("CompanyID", companyID));
            return GetCommodities(SQL_COMMODITY_SELECT, parameters);;
        }


        protected const string SQL_PRODUCT_SELECT =
            @"SELECT prprpr_ProductProvidedID, prprpr_Name 
                FROM vPRCompanyProductProvided 
               WHERE prcprpr_CompanyID=@CompanyID
            ORDER BY prprpr_Name";

        protected List<BBOSMobile.ServiceModels.Common.Product> GetProducts(int companyID)
        {
            ArrayList parameters = new ArrayList();
            parameters.Add(new ObjectParameter("CompanyID", companyID));
            return GetProducts(SQL_PRODUCT_SELECT, parameters);
        }


        protected const string SQL_SERVICE_SELECT =
            @"SELECT prserpr_ServiceProvidedID, prserpr_Name 
                FROM vPRCompanyServiceProvided 
               WHERE prcserpr_CompanyID=@CompanyID
            ORDER BY prserpr_Name";

        protected List<BBOSMobile.ServiceModels.Common.Service> GetServices(int companyID)
        {
            ArrayList parameters = new ArrayList();
            parameters.Add(new ObjectParameter("CompanyID", companyID));
            return GetServices(SQL_SERVICE_SELECT, parameters);
        }


        protected const string SQL_SPECIE_SELECT =
            @"SELECT prspc_SpecieID, prspc_Name 
                FROM vPRCompanySpecie 
               WHERE prcspc_CompanyID=@CompanyID
            ORDER BY prspc_Name";

        protected List<BBOSMobile.ServiceModels.Common.Specie> GetSpecie(int companyID)
        {
            ArrayList parameters = new ArrayList();
            parameters.Add(new ObjectParameter("CompanyID", companyID));
            return GetSpecie(SQL_SPECIE_SELECT, parameters);;
        }


        protected const string SQL_SELECT_RATING_DEFINTION =
            @"SELECT dbo.ufn_GetCustomCaptionValue('prcw_Name', prcw_Name, '{0}') As CreditWorth, prcw_Name, 
                     dbo.ufn_GetCustomCaptionValue('prin_Name', prin_Name, '{0}') As Integrity, prin_Name, 
                     dbo.ufn_GetCustomCaptionValue('prpy_Name', prpy_Name, '{0}') As Pay, prpy_Name 
                FROM vPRCurrentRating 
                WHERE prra_RatingID={1}";

        protected const string SQL_SELECT_RATING_NUMERAL_DEFINTION =
            @"SELECT prrn_Name, dbo.ufn_GetCustomCaptionValue('prrn_Name', prrn_Name, '{0}') As NumeralName  
                FROM PRRating WITH (NOLOCK) 
                     INNER JOIN PRRatingNumeralAssigned WITH (NOLOCK) ON prra_RatingID = pran_RatingID 
                     INNER JOIN PRRatingNumeral WITH (NOLOCK) ON pran_RatingNumeralID = prrn_RatingNumeralID 
               WHERE prra_RatingID={1}";

        protected const string SQL_SELECT_PAY_INDICATOR_DEFINITION =
            @"SELECT prcpi_PayIndicator, dbo.ufn_GetCustomCaptionValue('PayIndicatorDescription', prcpi_PayIndicator, '{0}') As IndicatorDescription 
                FROM PRCompanyPayIndicator WITH (NOLOCK) 
               WHERE prcpi_CompanyPayIndicatorID={1}";

        public ObservableCollection<Rating> GetRatingDefinition(int ratingID)
        {

            ObservableCollection<Rating> ratingDefs = new ObservableCollection<Rating>();


            string sql = string.Format(SQL_SELECT_RATING_DEFINTION, "en-us", ratingID);
            using (IDataReader reader = GetDBAccess().ExecuteReader(sql, CommandBehavior.CloseConnection))
            {
                if (reader.Read())
                {

                    if (!string.IsNullOrEmpty(GetDBAccess().GetString(reader, 0)))
                    {
                        Rating rating = new Rating();
                        rating.Type = "Credit Worth";
                        rating.Score = GetDBAccess().GetString(reader, 1);
                        rating.Definition = GetDBAccess().GetString(reader, 0);
                        ratingDefs.Add(rating);
                    }

                    if (!string.IsNullOrEmpty(GetDBAccess().GetString(reader, 2)))
                    {
                        Rating rating = new Rating();
                        rating.Type = "Trade Practices";
                        rating.Score = GetDBAccess().GetString(reader, 3);
                        rating.Definition = GetDBAccess().GetString(reader, 2);
                        ratingDefs.Add(rating);
                    }

                    if (!string.IsNullOrEmpty(GetDBAccess().GetString(reader, 4)))
                    {
                        Rating rating = new Rating();
                        rating.Type = "Pay Rating";
                        rating.Score = GetDBAccess().GetString(reader, 5);
                        rating.Definition = GetDBAccess().GetString(reader, 4);
                        ratingDefs.Add(rating);
                    }
                }
            }


            sql = string.Format(SQL_SELECT_RATING_NUMERAL_DEFINTION, "en-us", ratingID);
            using (IDataReader reader = GetDBAccess().ExecuteReader(sql, CommandBehavior.CloseConnection))
            {
                while (reader.Read())
                {
                    Rating rating = new Rating();
                    rating.Type = "Rating Numeral";
                    rating.Score = GetDBAccess().GetString(reader, 0);
                    rating.Definition = GetDBAccess().GetString(reader, 1);
                    ratingDefs.Add(rating);
                }

            }

            return ratingDefs;
        }


        public Rating GetPayIndicatorDefinition(int companyPayIndicatorID)
        {
            Rating rating = null;
            string szSQL = string.Format(SQL_SELECT_PAY_INDICATOR_DEFINITION, "en-us", companyPayIndicatorID);
            using (IDataReader reader = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection))
            {
                while (reader.Read())
                {

                    rating = new Rating();
                    rating.Type = "Pay Indicator";
                    rating.Score = GetDBAccess().GetString(reader, 0);
                    rating.Definition = GetDBAccess().GetString(reader, 1);
                }

            }
            return rating;
        }



        protected List<Note> PopulateNotes(IPRWebUser user, int companyID)
        {
            if (!user.HasPrivilege(SecurityMgr.Privilege.Notes).HasPrivilege)
            {
                return new List<Note>();
            }

            return PopulateNotes(user, companyID, 0);
        }


        protected Note GetPersonNote(IPRWebUser user, int personID)
        {

            Note note = null;

            if (!user.HasPrivilege(SecurityMgr.Privilege.Notes).HasPrivilege)
            {
                return note;
            }

            NoteSearchCriteria searchCriteria = new NoteSearchCriteria();
            searchCriteria.WebUser = user;
            searchCriteria.AssociatedID = personID;
            searchCriteria.AssociatedType = "P";

            searchCriteria.SortField = "prwun_NoteUpdatedDateTime";
            searchCriteria.SortAsc = false;

            IBusinessObjectSet results = new PRWebUserNoteMgr(GetLogger(), user).Search(searchCriteria);

            foreach (IPRWebUserNote webuserNote in results)
            {
                note = new Note();
                note.NoteID = webuserNote.prwun_WebUserNoteID;
                note.LastUpdated = user.ConvertToLocalDateTime(webuserNote.prwun_NoteUpdatedDateTime);
                note.LastUpdatedBy = webuserNote.UpdatedBy + " " + webuserNote.UpdatedByLocation;
                note.NoteText = webuserNote.prwun_Note;
                note.IsPrivate = webuserNote.prwun_IsPrivate;

                if (webuserNote.CreatedUserID == user.prwu_WebUserID.ToString())
                {
                    note.IsCreator = true;
                }

            }

            return note;
        }

        protected void SetNote(IPRWebUser user, Contact contact)
        {
            if (!contact.HasNotes)
            {
                return;
            }
            
            if (!user.HasPrivilege(SecurityMgr.Privilege.Notes).HasPrivilege)
            {
                contact.HasNotes = false;
                return;
            }

            IPRWebUserNote webuserNote = (IPRWebUserNote)new PRWebUserNoteMgr(GetLogger(), user).GetObjectByKey(contact.NoteID);

            Note note = new Note();
            note.NoteID = webuserNote.prwun_WebUserNoteID;
            note.LastUpdated = user.ConvertToLocalDateTime(webuserNote.prwun_NoteUpdatedDateTime);
            note.LastUpdatedBy = webuserNote.UpdatedBy + " " + webuserNote.UpdatedByLocation;
            note.NoteText = webuserNote.prwun_Note;
            note.IsPrivate = webuserNote.prwun_IsPrivate;

            if (webuserNote.CreatedUserID == user.prwu_WebUserID.ToString())
            {
                note.IsCreator = true;
            }

            contact.Notes = note;
        }


        protected bool HasNotes(IPRWebUser user, int companyID)
        {

            List<Note> notes = new List<Note>();

            if (!user.HasPrivilege(SecurityMgr.Privilege.Notes).HasPrivilege)
            {
                return false;
            }

            NoteSearchCriteria searchCriteria = new NoteSearchCriteria();
            searchCriteria.WebUser = user;
            searchCriteria.AssociatedID = companyID;
            searchCriteria.AssociatedType = "C";

            searchCriteria.SortField = "prwun_NoteUpdatedDateTime";
            searchCriteria.SortAsc = false;

            int noteCount = new PRWebUserNoteMgr(GetLogger(), user).SearchCount(searchCriteria);
            if (noteCount == 0)
            {
                return false;
            }

            return true;
        }

        private const string SQL_IS_ON_WATCHDOG_LIST =
            @"SELECT 'x'
                FROM PRWebUserList WITH (NOLOCK) 
                        LEFT OUTER JOIN PRWebUserListDetail WITH (NOLOCK) ON prwucl_WebUserListID = prwuld_WebUserListID AND prwuld_Deleted IS NULL 
                WHERE ((prwucl_HQID = @HQID AND prwucl_IsPrivate IS NULL) 
                        OR (prwucl_WebUserID=@WebUserID AND prwucl_IsPrivate = 'Y'))
	            AND prwuld_AssociatedID = @CompanyID";

        protected bool IsOnWatchdogList(IPRWebUser user, int companyID)
        {
            ArrayList parameters = new ArrayList();
            parameters.Add(new ObjectParameter("HQID", user.prwu_HQID));
            parameters.Add(new ObjectParameter("WebUserID", user.prwu_WebUserID));
            parameters.Add(new ObjectParameter("CompanyID", companyID));

            object result = GetDBAccess().ExecuteScalar(SQL_IS_ON_WATCHDOG_LIST, parameters);
            if ((result == null) ||
                (result == DBNull.Value))
                return false;

            return true;
        }

        protected string GetMapAddress(int companyID)
        {

            string sql = string.Format("SELECT Address FROM vPRMapAddresses WHERE comp_CompanyID = {0}", companyID);

            using (IDataReader reader = GetDBAccess().ExecuteReader(sql))
            {
                while (reader.Read())
                {
                    return reader.GetString(0);
                }
            }

            return null;
        }

        protected void InsertAuditRecord(IPRWebUser user, int companyID)
        {


            GetObjectMgr(user).InsertWebAuditTrail("/api/company/getcompany",
                                                    null,
                                                    companyID.ToString(),
                                                    "C",
                                                    null,
                                                    null,
                                                    null,
                                                    null,
                                                    null);
        }

        /// <summary>
        /// Helper method that removes any whitespace or punctuation from the 
        /// given string.
        /// </summary>
        /// <param name="szInput"></param>
        /// <returns></returns>
        public static string CleanString(string szInput)
        {

            // Remove all white space
            Regex rexWhiteSpace = new Regex(@"\s");
            // Remove all punctuation
            Regex rexPunctuation = new Regex(@"[^a-zA-Z0-9*]");

            szInput = rexWhiteSpace.Replace(szInput, "");
            szInput = rexPunctuation.Replace(szInput, "");

            return szInput;
        }


        private IPRWebUserNote SaveNote(IPRWebUser user, int noteID, int associatedID, string associatedType, string note, bool isPrivate)
        {
            IPRWebUserNote webUserNote = null;
            if (noteID == 0)
            {
                webUserNote = (IPRWebUserNote)new PRWebUserNoteMgr(GetLogger(), user).CreateObject();
                webUserNote.prwun_HQID = user.prwu_HQID;
                webUserNote.prwun_CompanyID = user.prwu_BBID;
                webUserNote.prwun_WebUserID = user.prwu_WebUserID;
                webUserNote.prwun_AssociatedID = associatedID;
                webUserNote.prwun_AssociatedType = associatedType;

                webUserNote.prwun_NoteUpdatedDateTime = new DateTime(DateTime.Now.Ticks, DateTimeKind.Unspecified);
                webUserNote.prwun_NoteUpdatedBy = user.prwu_WebUserID;
                webUserNote.prwun_CreatedBy = user.prwu_WebUserID;
            }
            else
            {
                webUserNote = (IPRWebUserNote)new PRWebUserNoteMgr(GetLogger(), user).GetObjectByKey(noteID);
            }

            webUserNote.prwun_IsPrivate = isPrivate;
            webUserNote.prwun_Note = note;
            webUserNote.Save();

            return webUserNote;
        }

        private void AddOnlineTradeReport(IPRWebUser user, SaveTradeReportRequest request)
        {
            bool responded = true;

            //If the request was not filled out do not supply these parameters so that the PRTradeReport is not created.
            if (string.IsNullOrEmpty(request.CompanyLastDealt) &&
                string.IsNullOrEmpty(request.TradePracticeRating) &&
                string.IsNullOrEmpty(request.PayPerformanceRating) &&
                string.IsNullOrEmpty(request.HighCreditRating) &&
                request.OutOfBusiness == false &&
                string.IsNullOrEmpty(request.Comments))
            {

                responded = false;
            }

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("Responder_BBID", user.prwu_BBID));
            oParameters.Add(new ObjectParameter("Subject_BBID", request.SubjectCompanyID));
            oParameters.Add(new ObjectParameter("PRWebUserID", user.prwu_WebUserID));
            oParameters.Add(new ObjectParameter("ResponseSource", Utilities.GetConfigValue("TradeReportSourceCode","MA")));
            

            //If the request was not filled out do not supply these parameters so that the PRTradeReport is not created.
            if (responded)
            {
                oParameters.Add(new ObjectParameter("HowRecently", request.CompanyLastDealt));
                oParameters.Add(new ObjectParameter("Integrity", request.TradePracticeRating));
                oParameters.Add(new ObjectParameter("Pay", request.PayPerformanceRating));
                oParameters.Add(new ObjectParameter("HighCredit", request.HighCreditRating));
                oParameters.Add(new ObjectParameter("OutOfBusiness", GetObjectMgr(user).GetPIKSCoreBool(request.OutOfBusiness)));
                oParameters.Add(new ObjectParameter("Summary", request.Comments));
            }


            if (request.TESReqeustID != 0) { 
                oParameters.Add(new ObjectParameter("PRTESRequestID", request.TESReqeustID));
            }

            GetDBAccess().ExecuteNonQuery("usp_AddOnlineTradeReport", oParameters, null, CommandType.StoredProcedure);
        }
        #endregion
    }
}
