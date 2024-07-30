/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2017

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission ofBlue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: TestContactController
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Linq;
using BBOSMobile.ServiceModels.Common;
using BBOSMobile.ServiceModels.Requests;
using BBOSMobile.ServiceModels.Responses;
using BBSI.BBOSMobileServices.Controllers;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace BBSI.BBOSMobileServices.Tests
{
    [TestClass]
    public class TestContactController : TestBase
    {
        [TestMethod]
        public void TestGetRecentlyViewed()
        {
            LoginUser();

            RequestBase request = new RequestBase();
            request.UserId = _userLoginResponse.UserId;

            var controller = new ContactController();
            var response = controller.GetRecentlyViewed(request);

            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);
            Assert.AreEqual(Convert.ToInt32(2), response.Contacts.Count());
        }

        [TestMethod]
        public void TestSearchState()
        {
            LoginUser();

            ContactSearchRequest request = new ContactSearchRequest();
            request.UserId = _userLoginResponse.UserId;
            request.State = "14";
            request.Radius = Enumerations.Radius.TwentyFiveMiles;
            request.PageIndex = 0;
            request.PageSize = 25;

            var controller = new ContactController();
            ContactSearchResponse response = controller.Search(request);

            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);
            Assert.AreEqual(request.PageSize, response.Contacts.Count());
        }

        [TestMethod]
        public void TestSearchCount()
        {
            LoginUser();

            ContactSearchRequest request = new ContactSearchRequest();
            request.UserId = _userLoginResponse.UserId;
            request.State = "14";
            request.Radius = Enumerations.Radius.TwentyFiveMiles;
            request.PageIndex = 0;
            request.PageSize = 25;

            var controller = new ContactController();
            ContactSearchResponse response = controller.Search(request);

            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);
            Assert.AreEqual(request.PageSize, response.Contacts.Count());
            Assert.IsTrue(response.ResultCount > request.PageSize, "Result Count");
        }

        [TestMethod]
        public void TestGetContact()
        {
            LoginUser();

            GetContactRequest request = new GetContactRequest();
            request.UserId = _userLoginResponse.UserId;
            request.ContactID = 87044;
            request.BBID = 204482;
            request.PageIndex = 0;
            request.PageSize = 25;

            var controller = new ContactController();
            GetContactResponse response = controller.GetContact(request);

            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);
            Assert.AreEqual("Scott Sax", response.Contact.Name);
        }

        [TestMethod]
        public void TestSearchLastName()
        {
            LoginUser();

            ContactSearchRequest request = new ContactSearchRequest();
            request.UserId = _userLoginResponse.UserId;
            request.LastName = "smith";
            request.Radius = Enumerations.Radius.Any;
            request.PageIndex = 0;
            request.PageSize = 25;

            var controller = new ContactController();
            ContactSearchResponse response = controller.Search(request);

            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);
            Assert.AreEqual(request.PageSize, response.Contacts.Count());
        }
    }
}
