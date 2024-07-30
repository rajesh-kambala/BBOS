/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2015=2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission ofBlue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: ControllerBase
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
//using System.Web.Http;
using BBOSMobile.ServiceModels.Common;
using PRCo.EBB.BusinessObjects;

using TSI.BusinessObjects;
using TSI.DataAccess;
using TSI.Utils;
using ILogger = TSI.Utils.ILogger;
using LoggerFactory = TSI.Utils.LoggerFactory;

namespace BBSI.BBOSMobileServices.Controllers
{
    public class BBSControllerBase : ControllerBase
    {

        protected const string SQL_COMPANY_BASE_SELECT =
            @"SELECT vPRBBOSCompanyList.*,
                     dbo.ufn_GetCustomCaptionValue('comp_PRIndustryTypeBBOS', comp_PRIndustryType, 'en-us') As IndustryType,
                     dbo.ufn_GetCustomCaptionValue('comp_PRType_BBOS', comp_PRType, 'en-us') As CompanyType,
                     dbo.ufn_HasNote(@WebUserID, @HQID, comp_CompanyID, 'C') As HasNote,
                     CASE WHEN comp_PRType = 'B' THEN CASE WHEN compRating.prra_RatingID IS NOT NULL THEN 'N' ELSE 'Y' END ELSE 'N' END AS IsHQRating,
                     CASE WHEN comp_PRType = 'B' THEN CASE WHEN compRating.prra_RatingID IS NOT NULL THEN compRating.prra_RatingLine ELSE hqRating.prra_RatingLine END ELSE hqRating.prra_RatingLine END AS prra_RatingLine ";


        protected ResponseBase SetErrorResponse(ResponseBase response, string errorMsg)
        {
            response.ResponseStatus = Enumerations.ResponseStatus.Failure;
            response.ErrorMessage = errorMsg;
            return response;
        }

        protected ResponseBase SetInvalidUserResponse(ResponseBase response)
        {
            response.ResponseStatus = Enumerations.ResponseStatus.InvalidUserId;
            return response;
        }

        protected ResponseBase HandleException(ResponseBase response, Exception e)
        {
            GetLogger().LogError(e);
            return SetErrorResponse(response, Constants.ErrorMessages.GENERIC_FAILURE);
        }

        protected ResponseBase SetSuccessResponse(ResponseBase response)
        {
            return SetSuccessResponse(response, null);
        }

        protected ResponseBase SetSuccessResponse(ResponseBase response, IPRWebUser user)
        {
            if (user != null)
                SetUserAccessInfo(response, user);
            response.ResponseStatus = Enumerations.ResponseStatus.Success;
            return response;
        }


        private ILogger _logger = null;
        protected ILogger GetLogger()
        {
            return GetLogger(string.Empty);
        }

        protected ILogger GetLogger(string method)
        {
            if (_logger == null)
            {
                _logger = LoggerFactory.GetLogger();
            }

            if (!string.IsNullOrEmpty(method))
            {
                _logger.RequestName = method;
            }
            
            return _logger;
        }

        protected void SetLoggerMethod(string method)
        {
            GetLogger(method);
        }

        protected void SetLoggerUser(IPRWebUser user)
        {
            if (_logger != null)
            {
                _logger.UserID = user.Email.Trim();
            }
        }

        protected IDBAccess _oDBAccess;
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
                _oDBAccess.Logger = GetLogger();
            }
            return _oDBAccess;
        }

        
        protected GeneralDataMgr _oObjectMgr;
        /// <summary>
        /// Helper method that returns an EBBObjectMgr object.  This is
        /// cached in a member variable.
        /// </summary>
        /// <returns></returns>
        public GeneralDataMgr GetObjectMgr(IPRWebUser user)
        {
            if (_oObjectMgr == null)
            {
                _oObjectMgr = new GeneralDataMgr(GetLogger(), null);
            }


            if (user != null)
            {
                _oObjectMgr.User = user;
            }
            
            return _oObjectMgr;
        }

        protected IPRWebUser GetUser(string email) {
            try
            {
                return (IPRWebUser)new PRWebUserMgr(GetLogger(), null).GetByEmail(email);
            }
            catch (ObjectNotFoundException)
            {
                return null;
            }
            
            
        }

        protected IPRWebUser GetUserByGuid(Guid guid)
        {
            try { 
                return (IPRWebUser)new PRWebUserMgr(GetLogger(), null).GetByMobileGuid(guid.ToString());
            }
            catch (ObjectNotFoundException)
            {
                return null;
            }

        }


        protected void SetUserAccessInfo(ResponseBase response, IPRWebUser user)
        {
            UserAccess userAccess = new UserAccess();

            switch(user.prwu_AccessLevel) {
                case PRWebUser.SECURITY_LEVEL_LIMITED_ACCESS:
                    userAccess.UserLevel = Enumerations.UserLevel.Limited;
                    break;
                case PRWebUser.SECURITY_LEVEL_BASIC_ACCESS:
                    userAccess.UserLevel = Enumerations.UserLevel.Basic;
                    break;
                case PRWebUser.SECURITY_LEVEL_STANDARD:
                    userAccess.UserLevel = Enumerations.UserLevel.Intermediate;
                    break;
                case PRWebUser.SECURITY_LEVEL_ADVANCED:
                    userAccess.UserLevel = Enumerations.UserLevel.Advanced;
                    break;
                case PRWebUser.SECURITY_LEVEL_PREMIUM:
                case PRWebUser.SECURITY_LEVEL_ADMIN:
                    userAccess.UserLevel = Enumerations.UserLevel.Premium;
                    break;
            }

            userAccess.TermsRequired = !user.prwu_AcceptedTerms;
            userAccess.SecurityPrivileges = GetUserSecurity(user);

            response.UserAccessInfo = userAccess;
        }


        protected List<SecurityResult> GetUserSecurity(IPRWebUser user)
        {
            List<SecurityResult> securityResults = new List<SecurityResult>();

            List<PRCo.EBB.BusinessObjects.SecurityMgr.SecurityResult> results = SecurityMgr.GetPrivileges(user);

            foreach (Enumerations.Privilege privilege in Enum.GetValues(typeof(Enumerations.Privilege)))
            {
                foreach (PRCo.EBB.BusinessObjects.SecurityMgr.SecurityResult result in results)
                {
                    if (privilege.ToString() == result.Privilege.ToString())
                    {
                        SecurityResult securityResult = new SecurityResult();
                        securityResult.PrivilegeName = privilege;
                        securityResult.HasPrivilege = result.HasPrivilege;
                        securityResult.Visible = result.Visible;
                        securityResult.Enabled = result.Enabled;
                        securityResults.Add(securityResult);
                    }
                }
            }

            return securityResults;
        }


        protected void SetMobileGUID(IPRWebUser user)
        {
            user.prwu_MobileGUID = Guid.NewGuid().ToString();
            user.prwu_MobileGUIDExpiration = DateTime.Now.AddHours(Utilities.GetIntConfigValue("MobileGuidExpirationHours", 24));
            user.Save();
        }



        protected List<CompanyBase> PopulateCompanyBase(string sql, ArrayList parameters)
        {
            List<CompanyBase> companies = new List<CompanyBase>();

            using (IDataReader reader = GetDBAccess().ExecuteReader(sql, parameters, CommandBehavior.CloseConnection, null))
            {
                while (reader.Read())
                {
                    CompanyBase company = new CompanyBase();
                    company.BBID = GetDBAccess().GetInt32(reader, "comp_CompanyID");
                    company.Name = GetDBAccess().GetString(reader, "comp_PRBookTradestyle");
                    company.Location = GetDBAccess().GetString(reader, "CityStateCountryShort");
                    company.Industry = GetDBAccess().GetString(reader, "IndustryType");

                    if (GetDBAccess().GetString(reader, "comp_PRLocalSource") == "Y")
                    {
                        company.Type = "LS";
                    } else
                    {
                        company.Type = GetDBAccess().GetString(reader, "CompanyType");
                    }
                    


                    company.Rating = GetRatingLine(reader);

                    company.Phone = GetDBAccess().GetString(reader, "Phone");
                    if (GetDBAccess().GetString(reader, "HasNote") == "Y")
                    {
                        company.HasNotes = true;
                    }

                    companies.Add(company);
                }
            }

            return companies;
        }

        protected string GetRatingLine(IDataReader reader)
        {
            if (!string.IsNullOrEmpty(GetDBAccess().GetString(reader, "prra_RatingLine")))
            {
                string prefix = string.Empty;
                if (GetDBAccess().GetString(reader, "IsHQRating") == "Y")
                {
                    prefix = "HQ: ";
                }
                return prefix + GetDBAccess().GetString(reader, "prra_RatingLine");
            }

            return null;
        }


        protected CategoryLists GetCategoryList(IPRWebUser user, DateTime lastUpdated)
        {
            CategoryLists categoryList = new CategoryLists();
            categoryList.ClassificationList = GetClassifications(user, lastUpdated);
            categoryList.StateList = GetStates(user, lastUpdated);

            if (user.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                categoryList.ProductList = GetProducts(user, lastUpdated);
                categoryList.ServiceList = GetServices(user, lastUpdated);
                categoryList.SpecieList = GetSpecie(user, lastUpdated);
            }
            else
            {
                categoryList.CommondityList = GetCommodities(user, lastUpdated);
                categoryList.TerminalMarketList = GetTerminalMarkets(user, lastUpdated);
            }
            
            return categoryList;
        }

        protected const string SQL_CLASSIFICATIONS_CHANGED_SELECT =
            @"SELECT prcl_ClassificationID, '', '', prcl_ShortDescription, prcl_BookSection
                FROM PRClassification WITH (NOLOCK) 
               WHERE prcl_BookSection IN ({0})
                 AND (prcl_Level = '1' AND prcl_BookSection IN (0, 3)
                     OR prcl_Level = '2')
                 AND prcl_UpdatedDate >=@LastUpdated
            ORDER BY prcl_BookSection, prcl_Level, prcl_ShortDescription";

        protected List<BBOSMobile.ServiceModels.Common.Classification> GetClassifications(IPRWebUser user, DateTime lastUpdated)
        {
            string bookSectionSQL = null;
            if (user.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                bookSectionSQL = "3";
            }
            else
            {
                bookSectionSQL = "0,1,2";
            }

            ArrayList parameters = new ArrayList();
            parameters.Add(new ObjectParameter("LastUpdated", lastUpdated));

            return GetClassifications(string.Format(SQL_CLASSIFICATIONS_CHANGED_SELECT, bookSectionSQL), parameters);
        }


        protected List<BBOSMobile.ServiceModels.Common.Classification> GetClassifications(string sql, IList parameters)
        {
            List<BBOSMobile.ServiceModels.Common.Classification> list = new List<BBOSMobile.ServiceModels.Common.Classification>();

            using (IDataReader reader = GetDBAccess().ExecuteReader(sql, parameters, CommandBehavior.CloseConnection, null))
            {
                while (reader.Read())
                {
                    BBOSMobile.ServiceModels.Common.Classification classification = new BBOSMobile.ServiceModels.Common.Classification();
                    classification.Id = reader.GetInt32(0);
                    classification.Description = GetDBAccess().GetString(reader, 1);
                    classification.Abbreviation = GetDBAccess().GetString(reader, 2);
                    classification.Definition = GetDBAccess().GetString(reader, 3);

                    switch (reader.GetString(4))
                    {
                        case "0":
                            classification.IndustryType = GeneralDataMgr.INDUSTRY_TYPE_PRODUCE;
                            break;
                        case "1":
                            classification.IndustryType = GeneralDataMgr.INDUSTRY_TYPE_TRANSPORTATION;
                            break;
                        case "2":
                            classification.IndustryType = GeneralDataMgr.INDUSTRY_TYPE_SUPPLY;
                            break;
                        case "3":
                            classification.IndustryType = GeneralDataMgr.INDUSTRY_TYPE_LUMBER;
                            break;

                    }

                    list.Add(classification);
                }
            }

            return list;
        }



        protected const string SQL_COMMODITY_CHANGED_SELECT =
            @"SELECT prcm_CommodityId, prcm_ShortDescription, '', ''
                FROM PRCommodity 
               WHERE prcm_Level <=3 
                 AND prcm_UpdatedDate >=@LastUpdated
            ORDER BY prcm_ShortDescription";

        protected List<BBOSMobile.ServiceModels.Common.Commodity> GetCommodities(IPRWebUser user, DateTime lastUpdated)
        {
            ArrayList parameters = new ArrayList();
            parameters.Add(new ObjectParameter("LastUpdated", lastUpdated));
            return GetCommodities(SQL_COMMODITY_CHANGED_SELECT, parameters);
        }


        protected List<BBOSMobile.ServiceModels.Common.Commodity> GetCommodities(string sql, IList parameters)
        {
            List<BBOSMobile.ServiceModels.Common.Commodity> list = new List<BBOSMobile.ServiceModels.Common.Commodity>();

            using (IDataReader reader = GetDBAccess().ExecuteReader(sql, parameters, CommandBehavior.CloseConnection, null))
            {
                while (reader.Read())
                {
                    BBOSMobile.ServiceModels.Common.Commodity commodity = new BBOSMobile.ServiceModels.Common.Commodity();
                    commodity.Id =  reader.GetInt32(0);
                    if (reader[1] == DBNull.Value)
                    {
                        commodity.Definition = reader.GetString(3);
                    }
                    else
                    {
                        commodity.Definition = reader.GetString(1);
                    }

                    
                    commodity.Abbreviation = string.Empty;
                    list.Add(commodity);
                }
            }

            return list;
        }


        protected const string SQL_PRODUCT_CHANGED_SELECT =
            @"SELECT prprpr_ProductProvidedID, prprpr_Name 
                FROM PRProductProvided 
               WHERE prprpr_UpdatedDate >=@LastUpdated
            ORDER BY prprpr_Name";

        protected List<BBOSMobile.ServiceModels.Common.Product> GetProducts(IPRWebUser user, DateTime lastUpdated)
        {
            ArrayList parameters = new ArrayList();
            parameters.Add(new ObjectParameter("LastUpdated", lastUpdated));
            return GetProducts(SQL_PRODUCT_CHANGED_SELECT, parameters);
        }



        protected List<BBOSMobile.ServiceModels.Common.Product> GetProducts(string sql, IList parameters)
        {
            List<BBOSMobile.ServiceModels.Common.Product> list = new List<BBOSMobile.ServiceModels.Common.Product>();

            using (IDataReader reader = GetDBAccess().ExecuteReader(sql, parameters, CommandBehavior.CloseConnection, null))
            {
                while (reader.Read())
                {
                    BBOSMobile.ServiceModels.Common.Product product = new BBOSMobile.ServiceModels.Common.Product();
                    product.Id = reader.GetInt32(0);
                    product.Name = reader.GetString(1);
                    list.Add(product);
                }
            }

            return list;
        }



        protected const string SQL_SERVICE_CHANGED_SELECT =
            @"SELECT prserpr_ServiceProvidedID, prserpr_Name 
                FROM PRServiceProvided 
               WHERE prserpr_UpdatedDate >=@LastUpdated
            ORDER BY prserpr_Name";

        protected List<BBOSMobile.ServiceModels.Common.Service> GetServices(IPRWebUser user, DateTime lastUpdated)
        {
            ArrayList parameters = new ArrayList();
            parameters.Add(new ObjectParameter("LastUpdated", lastUpdated));
            return GetServices(SQL_SERVICE_CHANGED_SELECT, parameters);
        }


        protected List<BBOSMobile.ServiceModels.Common.Service> GetServices(string sql, IList parameters)
        {
            List<BBOSMobile.ServiceModels.Common.Service> list = new List<BBOSMobile.ServiceModels.Common.Service>();

            using (IDataReader reader = GetDBAccess().ExecuteReader(sql, parameters, CommandBehavior.CloseConnection, null))
            {
                while (reader.Read())
                {
                    BBOSMobile.ServiceModels.Common.Service service = new BBOSMobile.ServiceModels.Common.Service();
                    service.Id = reader.GetInt32(0);
                    service.Name = reader.GetString(1);
                    list.Add(service);
                }
            }

            return list;
        }


        protected const string SQL_SPECIE_CHANGED_SELECT =
            @"SELECT prspc_SpecieID, prspc_Name 
                FROM PRSpecie 
               WHERE prspc_UpdatedDate >=@LastUpdated
            ORDER BY prspc_Name";

        protected List<BBOSMobile.ServiceModels.Common.Specie> GetSpecie(IPRWebUser user, DateTime lastUpdated)
        {
            ArrayList parameters = new ArrayList();
            parameters.Add(new ObjectParameter("LastUpdated", lastUpdated));
            return GetSpecie(SQL_SPECIE_CHANGED_SELECT, parameters);
        }

        protected List<BBOSMobile.ServiceModels.Common.Specie> GetSpecie(string sql, IList parameters)
        {
            List<BBOSMobile.ServiceModels.Common.Specie> list = new List<BBOSMobile.ServiceModels.Common.Specie>();

            using (IDataReader oReader = GetDBAccess().ExecuteReader(sql, parameters, CommandBehavior.CloseConnection, null))
            {
                while (oReader.Read())
                {
                    BBOSMobile.ServiceModels.Common.Specie specie = new BBOSMobile.ServiceModels.Common.Specie();
                    specie.Id = oReader.GetInt32(0);
                    specie.Name = oReader.GetString(1);
                    list.Add(specie);
                }
            }

            return list;
        }



        protected const string SQL_TERMINAL_MARKET_CHANGED_SELECT =
            @"SELECT prtm_TerminalMarketId, prtm_ShortMarketName, ISNULL(prst_StateID, 0) 
                FROM PRTerminalMarket WITH (NOLOCK) 
                     LEFT OUTER JOIN PRState ON prtm_State = prst_Abbreviation
               WHERE prtm_ShortMarketName IS NOT NULL 
                 AND prtm_UpdatedDate >=@LastUpdated
            ORDER BY prtm_ShortMarketName";

        protected List<BBOSMobile.ServiceModels.Common.TerminalMarket> GetTerminalMarkets(IPRWebUser user, DateTime lastUpdated)
        {
            ArrayList parameters = new ArrayList();
            parameters.Add(new ObjectParameter("LastUpdated", lastUpdated));
            List<BBOSMobile.ServiceModels.Common.TerminalMarket> list = new List<BBOSMobile.ServiceModels.Common.TerminalMarket>();

            using (IDataReader reader = GetDBAccess().ExecuteReader(SQL_TERMINAL_MARKET_CHANGED_SELECT, parameters, CommandBehavior.CloseConnection, null))
            {
                while (reader.Read())
                {
                    BBOSMobile.ServiceModels.Common.TerminalMarket terminalMarket = new BBOSMobile.ServiceModels.Common.TerminalMarket();
                    terminalMarket.Id = reader.GetInt32(0);
                    terminalMarket.Name = reader.GetString(1);
                    terminalMarket.StateId = reader.GetInt32(2);
                    list.Add(terminalMarket);
                }
            }

            return list;
        }



        protected const string SQL_STATE_CHANGED_SELECT =
            @"SELECT prst_StateID, prst_State 
                FROM PRState WITH (NOLOCK) 
               WHERE prst_CountryID IN (1,2) 
                 AND prst_UpdatedDate >=@LastUpdated 
            ORDER BY prst_CountryID, prst_State";

        protected List<BBOSMobile.ServiceModels.Common.State> GetStates(IPRWebUser user, DateTime lastUpdated)
        {
            ArrayList parameters = new ArrayList();
            parameters.Add(new ObjectParameter("LastUpdated", lastUpdated));
            List<BBOSMobile.ServiceModels.Common.State> list = new List<BBOSMobile.ServiceModels.Common.State>();

            using (IDataReader reader = GetDBAccess().ExecuteReader(SQL_STATE_CHANGED_SELECT, parameters, CommandBehavior.CloseConnection, null))
            {
                while (reader.Read())
                {
                    BBOSMobile.ServiceModels.Common.State state = new BBOSMobile.ServiceModels.Common.State();
                    state.Id = reader.GetInt32(0);
                    state.Name = reader.GetString(1);
                    list.Add(state);
                }
            }

            return list;
        }

        protected bool GetBool(string value)
        {
            if (string.IsNullOrEmpty(value))
            {
                return false;
            }

            if (value == "Y")
            {
                return true;
            }

            return false;

        }

        protected void InsertAuditRecord(IPRWebUser user, string action)
        {
            InsertAuditRecord(user, action, 0, 0);
        }

        protected void InsertAuditRecord(IPRWebUser user, string action, int companyID, int personID)
        {
            try
            {
                string associatedID = null;
                string associatedType = null;

                if (companyID > 0)
                {
                    associatedID = companyID.ToString();
                    associatedType = "C";
                }
                if (personID > 0)
                {
                    associatedID = personID.ToString();
                    associatedType = "P";
                }

                GetObjectMgr(user).InsertWebAuditTrail(action,
                                                        null,
                                                        associatedID,
                                                        associatedType,
                                                        null,
                                                        null,
                                                        null,
                                                        null,
                                                        null);
            }
            catch (Exception eX)
            {
                // Eat this
                GetLogger().LogError("Error in InsertAuditRecord", eX);
            }
        }

        protected void InsertSearchAuditRecord(IPRWebUser user, IPRWebUserSearchCriteria oWebUserSearchCriteria)
        {
            try
            {
                GetObjectMgr(user).InsertSearchAuditTrail(oWebUserSearchCriteria, 0, null);
            }
            catch (Exception eX)
            {
                // Eat this
                GetLogger().LogError("Error in InsertSearchAuditRecord", eX);
            }
        }

        protected string GetIndustryType(RequestBase request)
        {

            switch (request.IndustryType)
            {
                case Enumerations.IndustryType.Produce:
                    return GeneralDataMgr.INDUSTRY_TYPE_PRODUCE;
                case Enumerations.IndustryType.Transportation:
                    return GeneralDataMgr.INDUSTRY_TYPE_TRANSPORTATION;
                case Enumerations.IndustryType.Supply:
                    return GeneralDataMgr.INDUSTRY_TYPE_SUPPLY;
                case Enumerations.IndustryType.Lumber:
                    return GeneralDataMgr.INDUSTRY_TYPE_LUMBER;
            }

            return null;
        }

        protected List<Note> PopulateNotes(IPRWebUser user, int companyID, int contactID)
        {

            List<Note> notes = new List<Note>();

            if (!user.HasPrivilege(SecurityMgr.Privilege.Notes).HasPrivilege)
            {
                return notes;
            }


            NoteSearchCriteria searchCriteria = new NoteSearchCriteria();
            searchCriteria.WebUser = user;

            if (companyID > 0)
            {
                searchCriteria.AssociatedID = companyID;
                searchCriteria.AssociatedType = "C";
            }

            if (contactID > 0)
            {
                searchCriteria.AssociatedID = contactID;
                searchCriteria.AssociatedType = "P";
            }
            searchCriteria.SortField = "prwun_NoteUpdatedDateTime";
            searchCriteria.SortAsc = false;

            IBusinessObjectSet results = new PRWebUserNoteMgr(GetLogger(), user).Search(searchCriteria);

            foreach (IPRWebUserNote webuserNote in results)
            {
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


                notes.Add(note);

            }



            return notes;
        }
    }
}