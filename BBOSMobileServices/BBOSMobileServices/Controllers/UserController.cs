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

 ClassName: UserController
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Text;
using System.Web.Http;
using BBOSMobile.ServiceModels.Common;
using BBOSMobile.ServiceModels.Requests;
using BBOSMobile.ServiceModels.Responses;
using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;
using TSI.Utils;

namespace BBSI.BBOSMobileServices.Controllers
{

    public class UserController : ControllerBase
    {

        [Route("api/user/HelloWorld")]
        [HttpGet]
        public string HelloWorld()
        {
            return "Hello World";
        }

        [Route("api/user/Heartbeat")]
        [HttpPost]
        [HttpGet]
        public string Heartbeat()
        {
            return $"BBOSMobileServices: {DateTime.Now}";
        }

        [Route("api/user/login")]
        [HttpPost]
        [HttpGet]
        public LoginResponse Login(LoginRequest loginRequest) {

            LoginResponse response = new LoginResponse();
            try
            {
                DateTime dtStart = DateTime.Now;
                SetLoggerMethod("login");
                GetLogger().LogMessage($"Login attempt: {loginRequest.Email}");


                if (string.IsNullOrEmpty(loginRequest.Email)) 
                {
                    GetLogger().LogMessage($"- missing email");
                    return (LoginResponse)SetErrorResponse(response, "Email parameter missing.");
                }

                if  (string.IsNullOrEmpty(loginRequest.Password))
                {
                    GetLogger().LogMessage($"- missing password");
                    return (LoginResponse)SetErrorResponse(response, "Password parameter missing.");
                }

                IPRWebUser user = GetUser(loginRequest.Email);
                if (user == null)
                {
                    GetLogger().LogMessage($"- user not found");
                    return (LoginResponse)SetErrorResponse(response, Constants.ErrorMessages.INCORRECT_LOGIN_CREDENTIALS);
                }

                if (!user.Authenticate(loginRequest.Password))
                {
                    GetLogger().LogMessage($"- authentication failed");
                    return (LoginResponse)SetErrorResponse(response, Constants.ErrorMessages.INCORRECT_LOGIN_CREDENTIALS);
                }

                SetLoggerUser(user);
                SetMobileGUID(user);
                response.UserId = Guid.Parse(user.prwu_MobileGUID);
                response.BBID = user.prwu_BBID;
                response.RelatedBBIDs = GetRelatedBBIDs(user);

                //response.CategoryListsItems = GetCategoryList(user, GetLastAccessDate(user));
                response.CategoryListsItems = GetCategoryList(user, new DateTime(2000, 1, 1));

                if (user.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER) 
                    response.UserType = Enumerations.UserType.Lumber;
                else
                    response.UserType = Enumerations.UserType.Produce;

                InsertAuditRecord(user, "api/user/login");

                GetLogger().LogMessage("Method execution time: " + DateTime.Now.Subtract(dtStart).ToString());
                return (LoginResponse)SetSuccessResponse(response, user);
            }
            catch (ObjectNotFoundException)
            {
                GetLogger().LogMessage($"- ObjectNotFoundException: {loginRequest.Email}");
                return (LoginResponse)SetErrorResponse(response, Constants.ErrorMessages.INCORRECT_LOGIN_CREDENTIALS);
            }
            catch (Exception e)
            {
                GetLogger().LogMessage($"- EXCEPTION {e.Message} : {loginRequest.Email}");
                return (LoginResponse)HandleException(response, e);
            }
        }


        [Route("api/user/getpassword")]
        [HttpPost]
        [HttpGet]
        public SendPasswordResponse GetPassword(SendPasswordRequest request)
        {
            SetLoggerMethod("getpassword");

            SendPasswordResponse response = new SendPasswordResponse();
            if (string.IsNullOrEmpty(request.Email))
            {
                return (SendPasswordResponse)SetErrorResponse(response, "Email parameter missing.");
            }

            try
            {
                IPRWebUser user = GetUser(request.Email);
                if (user == null)
                {
                    return (SendPasswordResponse)SetErrorResponse(response, Constants.ErrorMessages.EMAIL_DOES_NOT_EXIST);    
                }

                user.EmailPassword();
                response.ResponseStatus = Enumerations.ResponseStatus.Success;
                InsertAuditRecord(user, "api/user/getpassword");
                return response;
            }
            catch (Exception e)
            {
                return (SendPasswordResponse)HandleException(response, e);
            }
        }


        [Route("api/user/getterms")]
        [HttpPost]
        [HttpGet]
        public GetTermsResponse GetTerms(RequestBase request)
        {
            SetLoggerMethod("GetTerms");

            GetTermsResponse response = new GetTermsResponse();
            try
            {
                IPRWebUser user = GetUserByGuid(request.UserId);
                if (user == null)
                {
                    return (GetTermsResponse)SetErrorResponse(response, Constants.ErrorMessages.USER_DOES_NOT_EXIST);
                }


                SetLoggerUser(user);

                response.TermsVersion = Utilities.GetConfigValue("TermsAndConditionsVersion");
                using (StreamReader srTerms = new StreamReader(Utilities.GetConfigValue("TermsAndConditionsFile")))
                {
                    response.TermsText = srTerms.ReadToEnd();
                }

                return (GetTermsResponse)SetSuccessResponse(response, user);

            }
            catch (Exception e)
            {
                return (GetTermsResponse)HandleException(response, e);
            }
        }

        [Route("api/user/saveterms")]
        [HttpPost]
        [HttpGet]
        public ResponseBase SaveTerms(RequestBase request)
        {
            SetLoggerMethod("SaveTerms");

            ResponseBase response = new ResponseBase();
            try
            {
                IPRWebUser user = GetUserByGuid(request.UserId);
                if (user == null)
                {
                    return SetErrorResponse(response, Constants.ErrorMessages.USER_DOES_NOT_EXIST);
                }

                SetLoggerUser(user);

                user.prwu_AcceptedTerms = true;
                user.prwu_AcceptedTermsDate = DateTime.Now;
                user.Save();

                return (ResponseBase)SetSuccessResponse(response, user);
            }
            catch (Exception e)
            {
                return (ResponseBase)HandleException(response, e);
            }
        }

        [Route("api/user/logexception")]
        [HttpPost]
        [HttpGet]
        public ResponseBase LogException(LogExceptionRequest request)
        {
            SetLoggerMethod("LogException");
            ResponseBase response = new ResponseBase();

            try
            {
                DateTime dtStart = DateTime.Now;

                AppendToLogFile(request.ExceptionDetails, "BBOSMobileErrorLog.txt");
                
                GetLogger().LogMessage("Method execution time: " + DateTime.Now.Subtract(dtStart).ToString());
                return (ResponseBase)SetSuccessResponse(response);
            }
            catch (Exception e)
            {
                HandleException(response, e);

                // We're going to eat the exception.  There is no need
                // to get the client in an exception loop.
                return (ResponseBase)SetSuccessResponse(response);
            }
        }

        [Route("api/user/logexceptiondetails")]
        [HttpPost]
        [HttpGet]
        public ResponseBase LogExceptionDetails(LogExceptionDetailsRequest request)
        {
            SetLoggerMethod("LogExceptionDetails");
            ResponseBase response = new ResponseBase();

            try
            {
                DateTime dtStart = DateTime.Now;

                StringBuilder error = new StringBuilder();
                error.AppendLine($"UserID: {request.UserID}");
                error.AppendLine($"OSVersion: {request.OSVersion}");
                error.AppendLine($"AppVersion: {request.AppVersion}");
                error.AppendLine($"AppIndustryType: {request.AppIndustryType}");
                error.AppendLine($"ScreenName: {request.ScreenName}");
                error.AppendLine($"WebMethod: {request.WebMethod}");
                error.AppendLine($"ExceptionMessage: {request.ExceptionMessage}");
                error.AppendLine($"AdditionalInfo: {request.AdditionalInfo}");
                error.AppendLine($"Stack Trace:");
                error.AppendLine($"{request.StackTrace}");

                string userID = string.Empty;
                if (!string.IsNullOrEmpty(request.UserID))
                    userID = "_" + request.UserID;

                string fileName = $"BBOSMobileErrorLog_{DateTime.Now:yyyy-MM-dd_HH-mm-ss-fff}{userID}.txt";
                AppendToLogFile(error.ToString(), fileName);

                GetLogger().LogMessage("Method execution time: " + DateTime.Now.Subtract(dtStart).ToString());
                return (ResponseBase)SetSuccessResponse(response);
            }
            catch (Exception e)
            {
                HandleException(response, e);

                // We're going to eat the exceptoin.  There is no need
                // to get the client in an exception loop.
                return (ResponseBase)SetSuccessResponse(response);
            }

        }

        private void AppendToLogFile(string message, string fileName)
        {
            string path = Utilities.GetConfigValue("BBOSMobileLogPath", @"C:\Temp\");
            string fullFileName = Path.Combine(path, fileName);

            using (StreamWriter sw = File.AppendText(fullFileName))
            {
                sw.WriteLine(message);
            }
        }

        private const string SQL_LAST_ACCESS_DATE =
            @"SELECT MAX(prwsat_CreatedDate) As LastAccessDate FROM PRWebAuditTrail WHERE prwsat_WebUserID=@UserID AND prwsat_pageName LIKE 'api/%'";
        private DateTime GetLastAccessDate(IPRWebUser user)
        {
            ArrayList parameters = new ArrayList();
            parameters.Add(new ObjectParameter("UserID", user.prwu_WebUserID));
            object result = GetDBAccess().ExecuteScalar(SQL_LAST_ACCESS_DATE, parameters);
            if ((result == DBNull.Value) ||
                (result == null))
            {
                return new DateTime(2000, 1, 1);
            }

            return Convert.ToDateTime(result);
        }


        private const string SQL_SELECT_RELATED_BBIDS =
            @"SELECT comp_CompanyID
                FROM (
	                SELECT comp_CompanyID FROM Company WITH (NOLOCK) WHERE comp_PRHQID=@CompanyID
	                UNION
	                SELECT prcr_LeftCompanyId
	                  FROM Company WITH (NOLOCK) 
	                       INNER JOIN PRCompanyRelationship WITH (NOLOCK) ON comp_CompanyID=prcr_RightCompanyID
	                 WHERE comp_PRHQID=@CompanyID
	                  AND prcr_Type IN ('27', '28', '29')
	                UNION
	                SELECT prcr_RightCompanyID
	                  FROM Company WITH (NOLOCK) 
	                       INNER JOIN PRCompanyRelationship WITH (NOLOCK) ON comp_CompanyID=prcr_LeftCompanyId
	                 WHERE comp_PRHQID=@CompanyID
	                  AND prcr_Type IN ('27', '28', '29')
                    ) T1
            ORDER BY comp_CompanyID";

        private List<int> GetRelatedBBIDs(IPRWebUser user)
        {
            List<int> relatedBBIDS = new List<int>();

            ArrayList parameters = new ArrayList();
            parameters.Add(new ObjectParameter("CompanyID", user.prwu_HQID));

            using (IDataReader reader = GetDBAccess().ExecuteReader(SQL_SELECT_RELATED_BBIDS, parameters, CommandBehavior.CloseConnection, null))
            {
                while (reader.Read())
                {
                    relatedBBIDS.Add(reader.GetInt32(0));
                }
            }

            return relatedBBIDS;
        }
    }
}
