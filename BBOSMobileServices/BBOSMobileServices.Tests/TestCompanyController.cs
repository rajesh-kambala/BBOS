/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2015-2019

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission ofBlue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: TestCompanyController
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
    public class TestCompanyController: TestBase
    {

        [TestMethod]
        public void TestGetRecentlyViewed()
        {
            LoginUser();

            RequestBase request = new RequestBase();
            request.UserId = _userLoginResponse.UserId;

            var controller = new CompanyController();
            var response = controller.GetRecentlyViewed(request);

            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);
            Assert.AreEqual(2, response.Companies.Count());
            Assert.AreEqual(2, response.Contacts.Count());
        }

        [TestMethod]
        public void TestQuickFindTest()
        {
            LoginUser();

            QuickFindSearchRequest request = new QuickFindSearchRequest();
            request.UserId = _userLoginResponse.UserId;
            request.SearchText = "Apple";
            request.PageIndex = 0;
            request.PageSize = 25;

            var controller = new CompanyController();
            QuickFindSearchResponse response = controller.QuickFind(request);

            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);
            Assert.AreEqual(request.PageSize, response.Companies.Count());

            int foundBBID = response.Companies.First<CompanyBase>().BBID;

            request.PageIndex = 1;
            request.PageSize = 25;

            response = controller.QuickFind(request);

            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);
            Assert.AreEqual(request.PageSize, response.Companies.Count());

            foreach (CompanyBase company in response.Companies)
            {
                Assert.AreNotEqual(foundBBID, company.BBID);
            }
        }

        [TestMethod]
        public void TestQuickFindBBIDTest()
        {
            LoginUser();

            QuickFindSearchRequest request = new QuickFindSearchRequest();
            request.UserId = _userLoginResponse.UserId;
            request.SearchText = "103513";
            request.PageIndex = 0;
            request.PageSize = 25;

            var controller = new CompanyController();
            QuickFindSearchResponse response = controller.QuickFind(request);

            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);
            Assert.AreEqual(1, response.Companies.Count());

            foreach (CompanyBase company in response.Companies)
            {
                Assert.AreEqual(103513, company.BBID);
            }
        }
        

        [TestMethod]
        public void TestSearchRadius()
        {
            LoginUser();

            CompanySearchRequest request = new CompanySearchRequest();
            request.UserId = _userLoginResponse.UserId;
            request.PostalCode = "60061";
            request.Radius = Enumerations.Radius.TwentyFiveMiles;
            request.PageIndex = 0;
            request.PageSize = 25;

            var controller = new CompanyController();
            CompanySearchResponse response = controller.Search(request);

            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);
            Assert.AreEqual(request.PageSize, response.Companies.Count());
        }



        [TestMethod]
        public void TestSearchState()
        {
            LoginUser();

            CompanySearchRequest request = new CompanySearchRequest();
            request.UserId = _userLoginResponse.UserId;
            request.State = "14";
            request.Radius = Enumerations.Radius.TwentyFiveMiles;
            request.PageIndex = 0;
            request.PageSize = 25;

            var controller = new CompanyController();
            CompanySearchResponse response = controller.Search(request);

            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);
            Assert.AreEqual(request.PageSize, response.Companies.Count());
        }

        [TestMethod]
        public void TestSearchCount()
        {
            LoginUser();

            CompanySearchRequest request = new CompanySearchRequest();
            request.UserId = _userLoginResponse.UserId;
            request.State = "14";
            request.Radius = Enumerations.Radius.TwentyFiveMiles;
            request.PageIndex = 0;
            request.PageSize = 25;

            var controller = new CompanyController();
            CompanySearchResponse response = controller.Search(request);

            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);
            Assert.IsTrue(response.ResultCount > request.PageSize, "Result Count");
        }


        [TestMethod]
        public void TestSearchCommodity()
        {
            LoginUser();

            CompanySearchRequest request = new CompanySearchRequest();
            request.UserId = _userLoginResponse.UserId;
            request.CommodityId = 71;  // Orange
            request.Radius = Enumerations.Radius.TwentyFiveMiles;
            request.PageIndex = 0;
            request.PageSize = 25;

            var controller = new CompanyController();
            CompanySearchResponse response = controller.Search(request);

            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);
            Assert.AreEqual(request.PageSize, response.Companies.Count());
        }


        [TestMethod]
        public void TestSearchClassification()
        {
            LoginUser();

            CompanySearchRequest request = new CompanySearchRequest();
            request.UserId = _userLoginResponse.UserId;
            request.ClassificationId = 360;  // Growers
            request.Radius = Enumerations.Radius.TwentyFiveMiles;
            request.PageIndex = 0;
            request.PageSize = 25;

            var controller = new CompanyController();
            CompanySearchResponse response = controller.Search(request);

            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);
            Assert.AreEqual(request.PageSize, response.Companies.Count());
        }



        [TestMethod]
        public void TestSearchCity()
        {
            LoginUser();

            CompanySearchRequest request = new CompanySearchRequest();
            request.UserId = _userLoginResponse.UserId;
            request.City = "Chicago";
            request.Radius = Enumerations.Radius.TwentyFiveMiles;
            request.PageIndex = 0;
            request.PageSize = 25;

            var controller = new CompanyController();
            CompanySearchResponse response = controller.Search(request);

            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);
            Assert.AreEqual(request.PageSize, response.Companies.Count());
        }



        [TestMethod]
        public void TestGetCompany()
        {
            LoginUser();

            GetCompanyRequest request = new GetCompanyRequest();
            request.UserId = _userLoginResponse.UserId;
            request.BBID = 102030;
            
            var controller = new CompanyController();
            GetCompanyResponse response = controller.GetCompany(request);

            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);

            Company company = response.Company;
            
            Assert.AreEqual("Strube Celery & Vegetable Co.", company.Name);
            Assert.AreEqual("927", company.BlueBookScore);
            Assert.AreEqual(1, company.SocialMedia.Count());
            Assert.AreEqual(6, company.Classifications.Count());
            Assert.AreEqual(43, company.Commodities.Count());
            Assert.AreEqual(26, company.Contacts.Count());
            Assert.AreNotEqual(0, company.Listing.Length);

        }

        [TestMethod]
        public void TestAddNote()
        {
            LoginUser();

            SaveCompanyNoteRequest request = new SaveCompanyNoteRequest();
            request.UserId = _userLoginResponse.UserId;
            request.BBID = 102030;
            request.Note = "New note created by BBOSMobileServices at " + DateTime.Now.ToString();

            var controller = new CompanyController();
            ResponseBase response = controller.SaveCompanyNote(request);

            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);
        }

        [TestMethod]
        public void TestAddPrivateNote()
        {
            LoginUser();

            SaveCompanyNoteRequest request = new SaveCompanyNoteRequest();
            request.UserId = _userLoginResponse.UserId;
            request.BBID = 102030;
            request.Note = "New note created by BBOSMobileServices at " + DateTime.Now.ToString();
            request.Private = true;

            var controller = new CompanyController();
            ResponseBase response = controller.SaveCompanyNote(request);

            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);
        }

        [TestMethod]
        public void TestEditNote()
        {
            LoginUser();

            SaveCompanyNoteRequest request = new SaveCompanyNoteRequest();
            request.UserId = _userLoginResponse.UserId;
            request.BBID = 102030;
            request.Note = "Note updated by BBOSMobileServices at " + DateTime.Now.ToString();
            request.NoteID = 46375;

            var controller = new CompanyController();
            ResponseBase response = controller.SaveCompanyNote(request);

            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);

        }


        [TestMethod]
        public void TestAddPersonNote()
        {
            LoginUser();

            SaveContactNoteRequest request = new SaveContactNoteRequest();
            request.UserId = _userLoginResponse.UserId;
            request.ContactID = 37353;

            Note note = new Note();
            note.NoteText = "New note created by BBOSMobileServices at " + DateTime.Now.ToString();

            request.Note = note;

            var controller = new CompanyController();
            ResponseBase response = controller.SaveContactNote(request);

            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);

        }


        [TestMethod]
        public void TestGetCompanyNotes()
        {
            LoginUser();

            GetCompanyNotesRequest request = new GetCompanyNotesRequest();
            request.UserId = _userLoginResponse.UserId;
            request.BBID = 164849;

            var controller = new CompanyController();
            GetCompanyNotesResponseModel response = controller.GetCompanyNotes(request);

            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);

        }

        [TestMethod]
        public void TestGetContacts()
        {
            LoginUser();

            GetCompanyContactsRequest request = new GetCompanyContactsRequest();
            request.UserId = _userLoginResponse.UserId;
            request.BBID = 102030;

            var controller = new CompanyController();
            GetCompanyContactsResponseModel response = controller.GetCompanyContacts(request);
            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);

            Assert.IsTrue(response.Contacts.Count() > 1, "Contacts were not returned.");
        }

        [TestMethod]
        public void TestContactNotes()
        {
            LoginUser();

            GetCompanyContactsRequest request = new GetCompanyContactsRequest();
            request.UserId = _userLoginResponse.UserId;
            request.BBID = 102030;

            var controller = new CompanyController();
            GetCompanyContactsResponseModel response = controller.GetCompanyContacts(request);
            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);

            foreach (Contact contact in response.Contacts)
            {
                if (contact.ContactID == 37353)
                {
                    Assert.AreNotEqual(0, contact.Notes.NoteID);
                }
            }
        }

        [TestMethod]
        public void TestContactNotes2()
        {
            LoginUser();

            GetCompanyContactsRequest request = new GetCompanyContactsRequest();
            request.UserId = _userLoginResponse.UserId;
            request.BBID = 194657;

            var controller = new CompanyController();
            GetCompanyContactsResponseModel response = controller.GetCompanyContacts(request);
            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);

            foreach (Contact contact in response.Contacts)
            {
                if (contact.ContactID == 8355)
                {
                    Assert.AreNotEqual(0, contact.Notes.NoteID);
                }
            }
        }


        [TestMethod]
        public void TestSearchCurrentPayReport()
        {
            LoginUser();

            CompanySearchRequest request = new CompanySearchRequest();
            request.UserId = _userLoginResponse.UserId;
            request.PageSize = 100;
            request.PageIndex = 0;

            request.IndustryType = Enumerations.IndustryType.Lumber;
            request.CurrentPayReport = Enumerations.CurrentPayReport.GreaterThan__4;

            var controller = new CompanyController();
            CompanySearchResponse response = controller.Search(request);

            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);
            Assert.AreEqual(request.PageSize, response.Companies.Count());
        }


        [TestMethod]
        public void TestSearchPayIndicator()
        {
            LoginUser();

            CompanySearchRequest request = new CompanySearchRequest();
            request.UserId = _userLoginResponse.UserId;
            request.PageSize = 100;
            request.PageIndex = 0;

            request.IndustryType = Enumerations.IndustryType.Lumber;
            request.PayIndicator = Enumerations.PayIndicator.A;

            var controller = new CompanyController();
            CompanySearchResponse response = controller.Search(request);

            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);
            Assert.AreEqual(request.PageSize, response.Companies.Count());
        }

        [TestMethod]
        public void TestGetLumberCompany()
        {
            LoginUser();

            GetCompanyRequest request = new GetCompanyRequest();
            request.UserId = _userLoginResponse.UserId;
            request.BBID = 271219;

            var controller = new CompanyController();
            GetCompanyResponse response = controller.GetCompany(request);

            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);

            Company company = response.Company;
            Assert.AreNotEqual(0, company.Listing.Length);

        }


        [TestMethod]
        public void TestSearchLumberServices()
        {
            LoginUser();

            CompanySearchRequest request = new CompanySearchRequest();
            request.UserId = _userLoginResponse.UserId;
            request.PageSize = 100;
            request.PageIndex = 0;

            request.IndustryType = Enumerations.IndustryType.Lumber;
            request.ServiceId = 88;

            var controller = new CompanyController();
            CompanySearchResponse response = controller.Search(request);

            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);
            Assert.AreEqual(3, response.Companies.Count());
        }



        [TestMethod]
        public void TestSearchPostalCode()
        {
            LoginUser();

            CompanySearchRequest request = new CompanySearchRequest();
            request.UserId = _userLoginResponse.UserId;
            request.PageSize = 100;
            request.PageIndex = 0;

            request.PostalCode = "60188";

            var controller = new CompanyController();
            CompanySearchResponse response = controller.Search(request);

            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);
            Assert.AreEqual(1, response.Companies.Count());
        }



        [TestMethod]
        public void TestSearchDefect4081()
        {
            LoginUser();

            CompanySearchRequest request = new CompanySearchRequest();
            request.UserId = _userLoginResponse.UserId;
            request.PageIndex = 0;
            request.PageSize = 500;
            request.ClassificationId = 220;  // Importer
            request.CommodityId = 474;  // Asparagus
            request.State = "10"; // Florida

            var controller = new CompanyController();
            CompanySearchResponse response = controller.Search(request);

            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);
            foreach (CompanyBase company in response.Companies)
            {
                Console.WriteLine(company.Name);
            }
        }

        [TestMethod]
        public void TestGetContactsDefect4082()
        {
            LoginUser();

            GetCompanyContactsRequest request = new GetCompanyContactsRequest();
            request.UserId = _userLoginResponse.UserId;
            request.BBID = 162984;

            var controller = new CompanyController();
            GetCompanyContactsResponseModel response = controller.GetCompanyContacts(request);
            Assert.AreEqual(Enumerations.ResponseStatus.Success, response.ResponseStatus);

            Assert.IsTrue(response.Contacts.Count() > 1, "Contacts were not returned.");
        }

    }
}
