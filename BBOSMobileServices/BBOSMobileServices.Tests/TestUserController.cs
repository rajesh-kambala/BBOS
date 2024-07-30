/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2015

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission ofBlue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: TestUserController
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Net.Http.Headers;
using BBOSMobile.ServiceModels.Common;
using BBOSMobile.ServiceModels.Requests;
using BBOSMobile.ServiceModels.Responses;
using BBSI.BBOSMobileServices.Controllers;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Newtonsoft.Json;


namespace BBSI.BBOSMobileServices.Tests
{
    [TestClass]
    public class TestUserController : TestBase
    {

        [TestMethod]
        public void TestLoginSuccess()
        {
            LoginRequest loginRequest = new LoginRequest();
            loginRequest.Email = "mmamalis@travant.com";
            loginRequest.Password = "Search41West";

            var controller = new UserController();
            var response = controller.Login(loginRequest);

            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);
        }


        [TestMethod]
        public void TestLoginFailure()
        {
            LoginRequest loginRequest = new LoginRequest();
            loginRequest.Email = "mmamalis@travant.com";
            loginRequest.Password = "WRONG";

            var controller = new UserController();
            var response = controller.Login(loginRequest);

            Assert.AreEqual(Enumerations.ResponseStatus.Failure, response.ResponseStatus);
        }



        [TestMethod]
        public void TestLoginSuccessJSON()
        {
            HttpClient client = new HttpClient();
            client.BaseAddress = new Uri("http://localhost/BBOSMobileServices/");
            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

            JsonMediaTypeFormatter jsonFormatter = new JsonMediaTypeFormatter();

            LoginRequest loginRequest = new LoginRequest();
            loginRequest.Email = "mmamalis@travant.com";
            loginRequest.Password = "Search41West";         
            HttpContent content = new ObjectContent<LoginRequest>(loginRequest, jsonFormatter);

            LoginResponse response = null;
            var httpResponse = client.PostAsync("api/user/login", content).Result;

            if (httpResponse.IsSuccessStatusCode)
            {
                response = JsonConvert.DeserializeObject<LoginResponse>(httpResponse.Content.ReadAsStringAsync().Result);
            }

            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);
        }

        [TestMethod]
        public void TestHelloWordJSON()
        {
            HttpClient client = new HttpClient();
            client.BaseAddress = new Uri("http://localhost/BBOSMobileServices/");
            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json")); 
            
            MediaTypeFormatter jsonFormatter = new JsonMediaTypeFormatter();

            var response = client.GetAsync("api/user/HelloWorld").Result;
        }


        [TestMethod]
        public void TestGetPasswordSuccess()
        {
            SendPasswordRequest request = new SendPasswordRequest();
            request.Email = "mmamalis@travant.com";

            var controller = new UserController();
            var response = controller.GetPassword(request);

            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);
        }


        [TestMethod]
        public void TestGetPasswordFailure()
        {
            SendPasswordRequest request = new SendPasswordRequest();
            request.Email = "mmamalis@travantWRONG.com";

            var controller = new UserController();
            var response = controller.GetPassword(request);

            Assert.AreEqual(Enumerations.ResponseStatus.Failure, response.ResponseStatus);
        }


        [TestMethod]
        public void TestGetPasswordSuccessJSON()
        {
            HttpClient client = new HttpClient();
            client.BaseAddress = new Uri("http://localhost/BBOSMobileServices/");
            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

            JsonMediaTypeFormatter jsonFormatter = new JsonMediaTypeFormatter();

            HttpContent content = new StringContent("mmamalis@travant.com");

            LoginResponse response = null;
            var httpResponse = client.PostAsync("api/user/getpassword", content).Result;

            if (httpResponse.IsSuccessStatusCode)
            {
                response = JsonConvert.DeserializeObject<LoginResponse>(httpResponse.Content.ReadAsStringAsync().Result);
            }

            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);
        }



        [TestMethod]
        public void TestGetTerms()
        {
            LoginUser();

            RequestBase request = new RequestBase();
            request.UserId = _userLoginResponse.UserId;

            var controller = new UserController();
            var response = controller.GetTerms(request);

            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);

            Assert.AreNotEqual(0, response.TermsText.Length);
        }



        [TestMethod]
        public void TestSaveTerms()
        {
            LoginUser();

            RequestBase request = new RequestBase();
            request.UserId = _userLoginResponse.UserId;

            var controller = new UserController();
            var response = controller.SaveTerms(request);

            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);
        }
    }
}
