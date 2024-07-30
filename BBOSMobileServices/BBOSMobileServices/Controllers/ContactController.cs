/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2017-2019

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission ofBlue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: ContactController
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
    public class ContactController : ControllerBase
    {

        [Route("api/contact/getrecentlyviewed")]
        [HttpPost]
        [HttpGet]
        public GetRecentlyViewedContactsResponse GetRecentlyViewed(RequestBase request)
        {
            GetRecentlyViewedContactsResponse response = new GetRecentlyViewedContactsResponse();

            SetLoggerMethod("GetRecentlyViewed");
            try {
                IPRWebUser user = GetUserByGuid(request.UserId);
                if (user == null) {
                    return (GetRecentlyViewedContactsResponse)SetInvalidUserResponse(response);
                }

                SetLoggerUser(user);

                response.Contacts = GetRecentlyViewed(user);
                InsertAuditRecord(user, "api/contact/getrecentlyviewed", 0, 0);
                return (GetRecentlyViewedContactsResponse)SetSuccessResponse(response, user);
            }
            catch (Exception e) {
                return (GetRecentlyViewedContactsResponse)HandleException(response, e);
            }

        }

        [Route("api/contact/search")]
        [HttpPost]
        [HttpGet]
        public ContactSearchResponse Search(ContactSearchRequest request)
        {
            ContactSearchResponse response = new ContactSearchResponse();

            SetLoggerMethod("Search");
            try {
                IPRWebUser user = GetUserByGuid(request.UserId);
                if (user == null) {
                    return (ContactSearchResponse)SetInvalidUserResponse(response);
                }

                SetLoggerUser(user);

                response.ResultCount = SearchCount(user, request);
                if (response.ResultCount > 0) {
                    response.Contacts = Search(user, request);
                }
                InsertAuditRecord(user, "api/contact/search", 0, 0);
                return (ContactSearchResponse)SetSuccessResponse(response, user);
            }
            catch (Exception e) {
                return (ContactSearchResponse)HandleException(response, e);
            }
        }

        [Route("api/contact/getcontact")]
        [HttpPost]
        [HttpGet]
        public GetContactResponse GetContact(GetContactRequest request)
        {
            GetContactResponse response = new GetContactResponse();

            SetLoggerMethod("GetContact");
            try {
                IPRWebUser user = GetUserByGuid(request.UserId);
                if (user == null) {
                    return (GetContactResponse)SetInvalidUserResponse(response);
                }

                SetLoggerUser(user);

                response.Contact = GetContact(user, request.ContactID, request.BBID);
                InsertAuditRecord(user, "api/contact/getcontact", 0, request.ContactID);
                return (GetContactResponse)SetSuccessResponse(response, user);
            }
            catch (Exception e) {
                return (GetContactResponse)HandleException(response, e);
            }

        }

        [Route("api/contact/getcontactnotes")]
        [HttpPost]
        [HttpGet]
        public GetContactNotesResponse GetContactNotes(GetContactNotesRequest request)
        {
            GetContactNotesResponse response = new GetContactNotesResponse();

            SetLoggerMethod("GetContactNotes");
            try {
                IPRWebUser user = GetUserByGuid(request.UserId);
                if (user == null) {
                    return (GetContactNotesResponse)SetInvalidUserResponse(response);
                }

                SetLoggerUser(user);

                response.Notes = PopulateNotes(user, request.ContactID); ;
                InsertAuditRecord(user, "api/contact/getcontactnotes", 0, request.ContactID);
                return (GetContactNotesResponse)SetSuccessResponse(response, user);
            }
            catch (Exception e) {
                return (GetContactNotesResponse)HandleException(response, e);
            }

        }

        protected const string SQL_RECENT_PERSONS =
            @"SELECT pers_PersonID, RTRIM(pers_FirstName) As pers_FirstName, RTRIM(pers_LastName) as pers_LastName, 
                     dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, NULL, pers_Suffix) as PersonName, 
                     peli_PRTitle, comp_CompanyID, comp_PRCorrTradestyle,CityStateCountryShort,
                     ndx 
                FROM dbo.ufn_GetRecentPersons(@WebUserID, @ContactLimit) 
                     INNER JOIN Person WITH (NOLOCK) ON PersonID = pers_personID 
 	                 INNER JOIN Person_Link WITH (NOLOCK) on pers_PersonID = peli_PersonID 
                     INNER JOIN vPRBBOSCompanyList ON peli_CompanyID = comp_CompanyID
               WHERE peli_PRStatus='1' 
                 AND peli_PREBBPublish='Y' ";

        public List<ContactBase> GetRecentlyViewed(IPRWebUser user)
        {
            ArrayList parameters = new ArrayList();
            parameters.Add(new ObjectParameter("ContactLimit", Utilities.GetIntConfigValue("RecentViewsTopNContacts", 10)));
            parameters.Add(new ObjectParameter("WebUserID", user.prwu_WebUserID));

            string sql = SQL_RECENT_PERSONS + " ORDER BY ndx";
            return PopulateContacts(sql, parameters);
        }

        protected const string SQL_SEARCH =
            @"SELECT * FROM (
                     SELECT DISTINCT pers_PersonID, RTRIM(pers_FirstName) As pers_FirstName, RTRIM(pers_LastName) as pers_LastName, 
                         dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, pers_PRNickname1, pers_Suffix) as PersonName,
                         peli_PRTitle, 
	                     comp_CompanyID,
	                     comp_PRCorrTradestyle,
                         CityStateCountryShort,
	                     ROW_NUMBER() OVER(ORDER BY Pers_LastName, Pers_FirstName) AS NUMBER 
                    FROM Person WITH (NOLOCK) 
 	                     INNER JOIN Person_Link WITH (NOLOCK) on pers_PersonID = peli_PersonID 
	                     INNER JOIN Company WITH (NOLOCK) ON comp_CompanyID = peli_CompanyID
                         INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
                   WHERE peli_PREBBPublish = 'Y'
                     AND peli_PRStatus = '1'
                     AND comp_PRListingStatus IN ('L', 'H', 'N3', 'N5', 'N6', 'LUV')
                     AND pers_PersonID IN ({0})) as TblA
              WHERE NUMBER  BETWEEN ((@PageNumber - 1)  * @RowspPage + 1)  AND (@PageNumber * @RowspPage)
          ORDER BY Pers_LastName, Pers_FirstName";

        protected List<ContactBase> Search(IPRWebUser user, ContactSearchRequest request)
        {
            IPRWebUserSearchCriteria oWebUserSearchCriteria = GetSearchCriteria(user, request);
            PersonSearchCriteria criteria = (PersonSearchCriteria)oWebUserSearchCriteria.Criteria;
            criteria.WebUser = user;

            // Generate the sql required to retrieve the search results            
            ArrayList parameters;
            string sql = string.Format(SQL_SEARCH, criteria.GetPersonIDSubSQL(out parameters));

            parameters.Add(new ObjectParameter("PageNumber", request.PageIndex + 1));
            parameters.Add(new ObjectParameter("RowspPage", request.PageSize));
            parameters.Add(new ObjectParameter("WebUserID", user.prwu_WebUserID));
            parameters.Add(new ObjectParameter("HQID", user.prwu_HQID));

            List<ContactBase> results = PopulateContacts(sql, parameters);

            oWebUserSearchCriteria.prsc_ExecutionCount++;
            oWebUserSearchCriteria.prsc_LastExecutionDateTime = DateTime.Now;
            oWebUserSearchCriteria.prsc_LastExecutionResultCount = results.Count;

            InsertSearchAuditRecord(user, oWebUserSearchCriteria);

            return results;
        }


        protected const string SQL_SEARCH_COUNT =
           @"SELECT COUNT(DISTINCT pers_PersonID)
            FROM Person WITH (NOLOCK) 
 	                INNER JOIN Person_Link WITH (NOLOCK) on pers_PersonID = peli_PersonID 
	                INNER JOIN Company WITH (NOLOCK) ON comp_CompanyID = peli_CompanyID
                    INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
            WHERE peli_PREBBPublish = 'Y'
                AND peli_PRStatus = '1'
                AND comp_PRListingStatus IN ('L', 'H', 'N3', 'N5', 'N6', 'LUV')
                AND pers_PersonID IN ({0})";

        protected int SearchCount(IPRWebUser user, ContactSearchRequest request)
        {
            IPRWebUserSearchCriteria oWebUserSearchCriteria = GetSearchCriteria(user, request);
            PersonSearchCriteria criteria = (PersonSearchCriteria)oWebUserSearchCriteria.Criteria;
            criteria.WebUser = user;

            // Generate the sql required to retrieve the search results            
            ArrayList parameters;
            string sql = string.Format(SQL_SEARCH_COUNT, criteria.GetPersonIDSubSQL(out parameters));

            int searchCount = (int)GetDBAccess().ExecuteScalar(sql, parameters);
            return searchCount;
        }

        protected IPRWebUserSearchCriteria GetSearchCriteria(IPRWebUser user, ContactSearchRequest request)
        {
            IPRWebUserSearchCriteria oWebUserSearchCriteria = (IPRWebUserSearchCriteria)new PRWebUserSearchCriteriaMgr(GetLogger(), user).CreateObject();
            oWebUserSearchCriteria.prsc_SearchType = PRWebUserSearchCriteria.SEARCH_TYPE_PERSON;
            oWebUserSearchCriteria.prsc_HQID = user.prwu_HQID;
            oWebUserSearchCriteria.prsc_CompanyID = user.prwu_BBID;
            oWebUserSearchCriteria.prsc_WebUserID = user.prwu_WebUserID;

            PersonSearchCriteria criteria = (PersonSearchCriteria)oWebUserSearchCriteria.Criteria;
            criteria.WebUser = user;

            criteria.LastName = request.LastName;
            criteria.FirstName = request.FirstName;
            criteria.Title = request.Title;
            criteria.Email = request.Email;
            criteria.BBID = Convert.ToInt32(request.BBID);
            criteria.IndustryType = GetIndustryType(request);

            criteria.ListingCity = request.City;
            criteria.ListingStateIDs = request.State;
            criteria.ListingPostalCode = request.PostalCode;
            criteria.Radius = Convert.ToInt32(request.Radius);

            if (criteria.Radius > -1) {
                criteria.RadiusType = CompanySearchCriteria.CODE_RADIUSTYPE_LISTINGPOSTALCODE;
            }
            else {

                if (!string.IsNullOrEmpty(criteria.ListingPostalCode)) {
                    criteria.Radius = 0;
                    criteria.RadiusType = CompanySearchCriteria.CODE_RADIUSTYPE_LISTINGPOSTALCODE;
                }
            }

            return oWebUserSearchCriteria;
        }

        protected List<ContactBase> PopulateContacts(string sql, ArrayList parameters)
        {
            List<ContactBase> contacts = new List<ContactBase>();

            using (IDataReader reader = GetDBAccess().ExecuteReader(sql, parameters, CommandBehavior.CloseConnection, null)) {
                while (reader.Read()) {
                    ContactBase contact = new ContactBase();
                    contact.ContactID = GetDBAccess().GetInt32(reader, "pers_PersonID");
                    contact.Name = GetDBAccess().GetString(reader, "PersonName");
                    //contact.FirstName = GetDBAccess().GetString(reader, "pers_FirstName");
                    //contact.LastName = GetDBAccess().GetString(reader, "pers_LastName");
                    contact.Title = GetDBAccess().GetString(reader, "peli_PRTitle");
                    contact.BBID = GetDBAccess().GetInt32(reader, "comp_CompanyID");
                    contact.CompanyName = GetDBAccess().GetString(reader, "comp_PRCorrTradestyle");
                    contact.Location = GetDBAccess().GetString(reader, "CityStateCountryShort");
                    contacts.Add(contact);
                }
            }

            return contacts;
        }

        protected const string SQL_SELECT_PERSON =
                    @"SELECT comp_CompanyID,
                               comp_PRCorrTradestyle,
                               CityStateCountryShort,
                               pers_PersonID, peli_PersonLinkID, RTRIM(pers_FirstName) As pers_FirstName, RTRIM(pers_LastName) as pers_LastName, 
	                           dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, pers_PRNickname1, pers_Suffix) as PersonName, peli_PRTitle, 
	                           RTRIM(emai_EmailAddress) As Email, 
	                           dbo.ufn_FormatPhone(cphone.phon_CountryCode, cphone.phon_AreaCode, cphone.phon_Number, cphone.phon_PRExtension) As CompanyPhone,
	                           dbo.ufn_FormatPhone(dp.phon_CountryCode, dp.phon_AreaCode, dp.phon_Number, dp.phon_PRExtension) As DirectPhone, 
	                           dbo.ufn_FormatPhone(cp.phon_CountryCode, cp.phon_AreaCode, cp.phon_Number, cp.phon_PRExtension) As CellPhone
                          FROM Person WITH (NOLOCK) 
	                           INNER JOIN Person_Link WITH (NOLOCK) on pers_PersonID = peli_PersonID 
	                           INNER JOIN Company WITH (NOLOCK) ON comp_CompanyID = peli_CompanyID
                               INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
	                           LEFT OUTER JOIN vPRPersonEmail em WITH (NOLOCK) ON peli_PersonID = em.ELink_RecordID AND peli_CompanyID = emai_CompanyID AND em.ELink_Type='E' AND em.emai_PRPreferredPublished='Y' 
	                           LEFT OUTER JOIN vPRCompanyPhone cphone WITH (NOLOCK) ON peli_CompanyID = cphone.PLink_RecordID AND cphone.phon_PRIsPhone = 'Y' AND cphone.phon_PRPreferredPublished = 'Y'  
	                           LEFT OUTER JOIN vPRPersonPhone dp WITH (NOLOCK) ON  peli_PersonID = dp.PLink_RecordID AND peli_CompanyID = dp.phon_CompanyID AND dp.plink_Type = 'P' AND dp.phon_PRPublish = 'Y'  
	                           LEFT OUTER JOIN vPRPersonPhone cp WITH (NOLOCK) ON  peli_PersonID = cp.PLink_RecordID AND peli_CompanyID = cp.phon_CompanyID AND cp.plink_Type = 'C' AND cp.phon_PRPublish = 'Y'  
                         WHERE peli_PREBBPublish = 'Y'
                           AND peli_PersonID=@PersonID
                           AND peli_CompanyID=@CompanyID";

        protected Contact GetContact(IPRWebUser user, int contactID, int companyID)
        {
            Contact contact = new Contact();

            ArrayList parameters = new ArrayList();
            parameters.Add(new ObjectParameter("PersonID", contactID));
            parameters.Add(new ObjectParameter("CompanyID", companyID));

            using (IDataReader reader = GetDBAccess().ExecuteReader(SQL_SELECT_PERSON, parameters, CommandBehavior.CloseConnection, null)) {
                if (reader.Read()) {

                    contact.ContactID = GetDBAccess().GetInt32(reader, "pers_PersonID");
                    contact.Name = GetDBAccess().GetString(reader, "PersonName");
                    contact.FirstName = GetDBAccess().GetString(reader, "pers_FirstName");
                    contact.LastName = GetDBAccess().GetString(reader, "pers_LastName");
                    contact.Title = GetDBAccess().GetString(reader, "peli_PRTitle");
                    contact.BBID = GetDBAccess().GetInt32(reader, "comp_CompanyID");
                    contact.CompanyName = GetDBAccess().GetString(reader, "comp_PRCorrTradestyle");
                    contact.Location = GetDBAccess().GetString(reader, "CityStateCountryShort");

                    contact.Email = GetDBAccess().GetString(reader, "Email");
                    contact.CompanyPhone = GetDBAccess().GetString(reader, "CompanyPhone");
                    contact.CellPhone = GetDBAccess().GetString(reader, "CellPhone");
                    contact.DirectPhone = GetDBAccess().GetString(reader, "DirectPhone");
                }
            }


            contact.HasNotes = HasNotes(user, contactID);

            return contact;
        }

        protected bool HasNotes(IPRWebUser user, int contactID)
        {

            List<Note> notes = new List<Note>();

            if (!user.HasPrivilege(SecurityMgr.Privilege.Notes).HasPrivilege) {
                return false;
            }

            NoteSearchCriteria searchCriteria = new NoteSearchCriteria();
            searchCriteria.WebUser = user;
            searchCriteria.AssociatedID = contactID;
            searchCriteria.AssociatedType = "P";

            searchCriteria.SortField = "prwun_NoteUpdatedDateTime";
            searchCriteria.SortAsc = false;

            int noteCount = new PRWebUserNoteMgr(GetLogger(), user).SearchCount(searchCriteria);
            if (noteCount == 0) {
                return false;
            }

            return true;
        }

        protected List<Note> PopulateNotes(IPRWebUser user, int contactID)
        {
            if (!user.HasPrivilege(SecurityMgr.Privilege.Notes).HasPrivilege) {
                return new List<Note>();
            }

            return PopulateNotes(user, 0, contactID);
        }
    }
}