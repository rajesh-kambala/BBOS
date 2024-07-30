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

 ClassName: TestWatchdogController
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Linq;
using BBOSMobile.ServiceModels.Common;
using BBOSMobile.ServiceModels.Requests;
using BBOSMobile.ServiceModels.Responses;
using BBSI.BBOSMobileServices.Controllers;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Newtonsoft.Json;


namespace BBSI.BBOSMobileServices.Tests
{
    [TestClass]
    public class TestWatchdogController : TestBase
    {
        [TestMethod]
        public void TestGetWatchdogGroups()
        {
            LoginUser();

            GetWatchdogGroupRequest request = new GetWatchdogGroupRequest();
            request.UserId = _userLoginResponse.UserId;

            var controller = new WatchdogController();
            GetWatchdogGroupResponse response = controller.GetWatchdogGroups(request);

            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);
            Assert.AreEqual(Convert.ToInt32(1), response.WatchdogGroups.Count());
        }

        [TestMethod]
        public void TestGetWatchdogGroup()
        {
            LoginUser();

            GetWatchdogGroupCompaniesRequest request = new GetWatchdogGroupCompaniesRequest();
            request.UserId = _userLoginResponse.UserId;
            request.WatchdogGroupId = 29208;

            var controller = new WatchdogController();
            GetWatchdogGroupDetailsResponse response = controller.GetWatchdogGroup(request);

            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);
            Assert.AreEqual("Automatic Update Service List", response.WatchdogGroup.Name);
            Assert.AreEqual(Convert.ToInt32(178), response.WatchdogGroup.Companies.Count());
        }

        [TestMethod]
        public void TestGetWatchdogGroupsForCompany()
        {
            LoginUser();

            GetWatchdogGroupRequest request = new GetWatchdogGroupRequest();
            request.UserId = _userLoginResponse.UserId;
            request.BBID = 102030;

            var controller = new WatchdogController();
            GetWatchdogGroupResponse response = controller.GetWatchdogGroups(request);

            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);
            Assert.AreEqual(Convert.ToInt32(3), response.WatchdogGroups.Count());

            foreach (WatchdogGroup watchdog in response.WatchdogGroups)
            {
                if (watchdog.Name == "Automatic Update Service List")
                {
                    Assert.IsTrue(watchdog.InGroup);
                }
                else
                {
                    Assert.IsFalse(watchdog.InGroup);
                }
            }

        }



        [TestMethod]
        public void TestSaveCompany()
        {
            LoginUser();

            SaveCompanyToWatchdogGroupRequest request = new SaveCompanyToWatchdogGroupRequest();
            request.UserId = _userLoginResponse.UserId;
            request.BBID = "102030";
            List<Int32> watchdogIDs = new List<Int32>();
            watchdogIDs.Add(29208);
            watchdogIDs.Add(48412);
            request.WatchdogGroupIds = watchdogIDs;

            var controller = new WatchdogController();
            ResponseBase response = controller.SaveCompany(request);

            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);
        }


        [TestMethod]
        public void TestSaveCompanyDerek()
        {
            LoginUser();

            SaveCompanyToWatchdogGroupRequest request = new SaveCompanyToWatchdogGroupRequest();
            request.UserId = _userLoginResponse.UserId;
            request.BBID = "102030";
            List<Int32> watchdogIDs = new List<Int32>();
            watchdogIDs.Add(48412);
            watchdogIDs.Add(48413);
            request.WatchdogGroupIds = watchdogIDs;

            string json = JsonConvert.SerializeObject(request);


            var controller = new WatchdogController();
            ResponseBase response = controller.SaveCompany(request);

            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);
        }

        [TestMethod]
        public void TestWatchdogAddCompany()
        {
            LoginUser();

            WatchdogUpdateRequest request = new WatchdogUpdateRequest();
            request.UserId = _userLoginResponse.UserId;
            request.BBID = 102030;
            request.WatchdogID = 48412;
            

            var controller = new WatchdogController();
            ResponseBase response = controller.AddCompany(request);

            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);
        }

        [TestMethod]
        public void TestWatchdogRemoveCompany()
        {
            LoginUser();

            WatchdogUpdateRequest request = new WatchdogUpdateRequest();
            request.UserId = _userLoginResponse.UserId;
            request.BBID = 102030;
            request.WatchdogID = 48412;


            var controller = new WatchdogController();
            ResponseBase response = controller.RemoveCompany(request);

            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);
        }
    }
}
