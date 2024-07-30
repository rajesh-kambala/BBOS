/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: PRWebUser
 Description:	

 Notes:	Created By TSI Class Generator on 6/26/2007 9:40:32 AM

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Threading;
using NUnit.Framework;
using TSI.Arch;
using TSI.BusinessObjects;
using TSI.Security;
using TSI.Utils;
using TSI.QA;


namespace PRCo.EBB.BusinessObjects {

    [TestFixture] 
    public class CompanySubmissionUTP:TestBase {

        [Test]
        public void TestSerialization01() {

            CompanySubmission oCompanySubmission = GetPopulatedObject();
            string szXML = null;
            try {
                szXML = CompanySubmission.Serialize(oCompanySubmission);
            } catch (Exception e) {
                _oLogger.LogError(e);
            }

            Assert.IsNotNull(szXML);

            CompanySubmission oCompanySubmission2 = CompanySubmission.Deserialize(szXML);

            CompareObjects(oCompanySubmission, oCompanySubmission2);
        }


        protected void CompareObjects(CompanySubmission o1, CompanySubmission o2) {

            Assert.AreEqual(o1.CompanyName, o2.CompanyName, "CompanyName");
            Assert.AreEqual(o1.BBID, o2.BBID, "BBID");
            Assert.AreEqual(o1.CFIALicense, o2.CFIALicense, "CFIALicense");
            Assert.AreEqual(o1.DescriptiveLines, o2.DescriptiveLines, "DescriptiveLines");
            Assert.AreEqual(o1.DRCLicense, o2.DRCLicense, "DRCLicense");
            Assert.AreEqual(o1.EntityType, o2.EntityType, "EntityType");
            Assert.AreEqual(o1.IncorporatedDate, o2.IncorporatedDate, "IncorporatedDate");
            Assert.AreEqual(o1.IncorporatedInStateID, o2.IncorporatedInStateID, "IncorporatedInStateID");
            Assert.AreEqual(o1.BusinessEstablishedDate, o2.BusinessEstablishedDate, "BusinessEstablishedDate");
            Assert.AreEqual(o1.FullTimeEmployees, o2.FullTimeEmployees, "FullTimeEmployees");
            Assert.AreEqual(o1.PartTimeEmployees, o2.PartTimeEmployees, "PartTimeEmployees");
            Assert.AreEqual(o1.ShippingSeason, o2.ShippingSeason, "ShippingSeason");
            Assert.AreEqual(o1.SubsidearyDetails, o2.SubsidearyDetails, "SubsidearyDetails");

            Assert.AreEqual(o1.Addresses.Count, o2.Addresses.Count, "Addresses.Count");
            Assert.AreEqual(o1.Addresses[0].Address1, o2.Addresses[0].Address1, "Addresses[0].Address1");
            Assert.AreEqual(o1.Addresses[0].Address2, o2.Addresses[0].Address2, "Addresses[0].Address2");
            Assert.AreEqual(o1.Addresses[0].Address3, o2.Addresses[0].Address3, "Addresses[0].Address3");

            Assert.AreEqual(o1.Banks.Count, o2.Banks.Count, "Banks.Count");
            Assert.AreEqual(o1.Banks[0].Address1, o2.Banks[0].Address1, "Banks[0].Address1");
            Assert.AreEqual(o1.Banks[0].Name, o2.Banks[0].Name, "Banks[0].Name");

            Assert.AreEqual(o1.Phones.Count, o2.Phones.Count, "Phones.Count");
            Assert.AreEqual(o1.Phones[0].AreaCode, o2.Phones[0].AreaCode, "Phones[0].AreaCode");
            Assert.AreEqual(o1.Phones[0].Number, o2.Phones[0].Number, "Phones[0].Number");

            Assert.AreEqual(o1.Profile.AtmosphereStorage, o2.Profile.AtmosphereStorage, "Profile.AtmosphereStorage");

            Assert.AreEqual(o1.WebSites.Count, o2.WebSites.Count, "WebSites.Count");
            Assert.AreEqual(o1.WebSites[0].Address, o2.WebSites[0].Address, "WebSites[0].Address");
            Assert.AreEqual(o1.WebSites[0].Description, o2.WebSites[0].Description, "WebSites[0].Description");
            Assert.AreEqual(o1.WebSites[0].Type, o2.WebSites[0].Type, "WebSites[0].Type");

            Assert.AreEqual(o1.Emails.Count, o2.Emails.Count, "Emails.Count");
            Assert.AreEqual(o1.Emails[0].Address, o2.Emails[0].Address, "Emails[0].Address");
            Assert.AreEqual(o1.Emails[0].Description, o2.Emails[0].Description, "Emails[0].Description");
            Assert.AreEqual(o1.Emails[0].Type, o2.Emails[0].Type, "Emails[0].Type");

            Assert.AreEqual(o1.SellDomesticRegions.Count, o2.SellDomesticRegions.Count, "SellDomesticRegions.Count");
            Assert.AreEqual(o1.SellDomesticRegions[0].RegionID, o2.SellDomesticRegions[0].RegionID, "SellDomesticRegions[0].RegionID");
            Assert.AreEqual(o1.SellDomesticRegions[0].Type, o2.SellDomesticRegions[0].Type, "SellDomesticRegions[0].Type");

            Assert.AreEqual(o1.SellInternationalRegions.Count, o2.SellInternationalRegions.Count, "SellInternationalRegions.Count");
            Assert.AreEqual(o1.SellInternationalRegions[0].RegionID, o2.SellInternationalRegions[0].RegionID, "SellInternationalRegions[0].RegionID");
            Assert.AreEqual(o1.SellInternationalRegions[0].Type, o2.SellInternationalRegions[0].Type, "SellInternationalRegions[0].Type");

            Assert.AreEqual(o1.TruckingDomesticRegions.Count, o2.TruckingDomesticRegions.Count, "TruckingDomesticRegions.Count");
            Assert.AreEqual(o1.TruckingDomesticRegions[0].RegionID, o2.TruckingDomesticRegions[0].RegionID, "TruckingDomesticRegions[0].RegionID");
            Assert.AreEqual(o1.TruckingDomesticRegions[0].Type, o2.TruckingDomesticRegions[0].Type, "TruckingDomesticRegions[0].Type");

            //Assert.AreEqual(o1.BuyDomesticRegions.Count, o2.BuyDomesticRegions.Count, "BuyDomesticRegions.Count");
            //Assert.AreEqual(o1.BuyDomesticRegions[0].RegionID, o2.BuyDomesticRegions[0].RegionID, "BuyDomesticRegions[0].RegionID");
            //Assert.AreEqual(o1.BuyDomesticRegions[0].Type, o2.BuyDomesticRegions[0].Type, "BuyDomesticRegions[0].Type");

            //Assert.AreEqual(o1.BuyInternationalRegions.Count, o2.BuyInternationalRegions.Count, "BuyInternationalRegions.Count");
            //Assert.AreEqual(o1.BuyInternationalRegions[0].RegionID, o2.BuyInternationalRegions[0].RegionID, "BuyInternationalRegions[0].RegionID");
            //Assert.AreEqual(o1.BuyInternationalRegions[0].Type, o2.BuyInternationalRegions[0].Type, "BuyInternationalRegions[0].Type");



            Assert.AreEqual(o1.Personnel.Count, o2.Personnel.Count, "Personnel.Count");
            Assert.AreEqual(o1.Personnel[0].FirstName, o2.Personnel[0].FirstName, "Personnel[0].FirstName");
            Assert.AreEqual(o1.Personnel[0].LastName, o2.Personnel[0].LastName, "Personnel[0].LastName");
            Assert.AreEqual(o1.Personnel[0].MiddleName, o2.Personnel[0].MiddleName, "Personnel[0].MiddleName");
            Assert.AreEqual(o1.Personnel[0].Suffix, o2.Personnel[0].Suffix, "Personnel[0].Suffix");
            Assert.AreEqual(o1.Personnel[0].IsActive, o2.Personnel[0].IsActive, "Personnel[0].IsActive");
            Assert.AreEqual(o1.Personnel[0].IsFormerBankruptcy, o2.Personnel[0].IsFormerBankruptcy, "Personnel[0].IsFormerBankruptcy");

            Assert.AreEqual(o1.Personnel[0].Phones.Count, o2.Personnel[0].Phones.Count, "Personnel[0].Phones.Count");
            Assert.AreEqual(o1.Personnel[0].Phones[0].AreaCode, o2.Personnel[0].Phones[0].AreaCode, "Personnel[0].Phones[0].AreaCode");
            Assert.AreEqual(o1.Personnel[0].Phones[0].Number, o2.Personnel[0].Phones[0].Number, "Personnel[0].Phones[0].Number");

            Assert.AreEqual(o1.Personnel[0].Emails.Count, o2.Personnel[0].Emails.Count, "Personnel[0].Emails.Count");
            Assert.AreEqual(o1.Personnel[0].Emails[0].Address, o2.Personnel[0].Emails[0].Address, "Personnel[0].Emails[0].Address");
            Assert.AreEqual(o1.Personnel[0].Emails[0].Description, o2.Personnel[0].Emails[0].Description, "Personnel[0].Emails[0].Description");
            Assert.AreEqual(o1.Personnel[0].Emails[0].Type, o2.Personnel[0].Emails[0].Type, "Personnel[0].Emails[0].Type");



        }

        [Test]
        public void TestSave01() {
            CompanySubmission oCompanySubmission = GetPopulatedObject();
            oCompanySubmission.ProcessSubmission();
        }

        protected CompanySubmission GetPopulatedObject() {
            IPRWebUser oWebUser = new PRWebUser();
            oWebUser.UserID = "9999";
            oWebUser.prwu_WebUserID = 9999;

            ILogger oLogger = LoggerFactory.GetLogger();

            CompanySubmission oCompanySubmission = new CompanySubmission(oLogger, oWebUser);
            oCompanySubmission.CompanyName = "Travant Solutions";
            oCompanySubmission.CFIALicense = "CFIALicense";
            oCompanySubmission.DescriptiveLines = "Descriptive Lines";
            oCompanySubmission.DRCLicense = "DRCLicense";
            oCompanySubmission.EntityType = "1";
            oCompanySubmission.IncorporatedDate = new DateTime(2000, 10, 16);
            oCompanySubmission.IncorporatedInStateID = 14;
            oCompanySubmission.BusinessEstablishedDate = new DateTime(2000, 10, 16);
            oCompanySubmission.FullTimeEmployees = "5";
            oCompanySubmission.PartTimeEmployees = "6";
            oCompanySubmission.ShippingSeason = "June 1st to June 2nd";
            oCompanySubmission.SubsidearyDetails = "We own Wisconson.";
            oCompanySubmission.ParentCompanyDetails = "He grew up near the coal mines in West Virginia...";
            oCompanySubmission.PACALicense = "111111";
            oCompanySubmission.DRCLicense = "222222";
            oCompanySubmission.MCNumber = "333333";
            oCompanySubmission.CFIALicense = "444444";


            Address oAddress = new Address();
            oAddress.Address1 = "Address1";
            oAddress.Address2 = "Address2";
            oAddress.Address3 = "Address3";
            oAddress.Type = "PH";
            oAddress.City = "VernonX Hills";
            oAddress.StateID = 14;
            oCompanySubmission.AddAddress(oAddress);

            Bank oBank = new Bank();
            oBank.Name = "My Cool Bank";
            oBank.Address1 = "Address 1";
            oBank.City = "Vernon Hills";
            oBank.StateID = 14;
            oCompanySubmission.AddBank(oBank);

            Brand oBrand = new Brand();
            oBrand.Name = "TSI Apples";
            oCompanySubmission.AddBrand(oBrand);
            oBrand = new Brand();
            oBrand.Name = "TSI Oranges";
            oCompanySubmission.AddBrand(oBrand);

            CompanyProfile oProfile = new CompanyProfile();
            oProfile.AtmosphereStorage = true;
            oCompanySubmission.Profile = oProfile;

            InternetAddress oWebSite = new InternetAddress();
            oWebSite.Address = "www.travant.com";
            oWebSite.Description = "Travant Web Site";
            oCompanySubmission.AddWebSite(oWebSite);

            InternetAddress oEmail = new InternetAddress();
            oEmail.Address = "user@travant.com";
            oCompanySubmission.AddEmail(oEmail);

            Phone oPhone = new Phone();
            oPhone.AreaCode = "555";
            oPhone.Number = "555-5555";
            oPhone.Extension = "x123";
            oPhone.Type = "P";
            oCompanySubmission.AddPhone(oPhone);

            oPhone = new Phone();
            oPhone.AreaCode = "111";
            oPhone.Number = "111-5555";
            oPhone.Type = "F";
            oCompanySubmission.AddPhone(oPhone);


            Region oRegion = new Region();
            oRegion.RegionID = 5;
            oCompanySubmission.AddSellDomesticRegion(oRegion);

            oRegion = new Region();
            oRegion.RegionID = 20;
            oCompanySubmission.AddSellInternationalRegion(oRegion);


            oRegion = new Region();
            oRegion.RegionID = 10;
            oCompanySubmission.AddSellInternationalRegion(oRegion);

            oRegion = new Region();
            oRegion.RegionID = 15;
            oCompanySubmission.AddTruckingDomesticRegion(oRegion);

            Person oPerson = new Person();
            oPerson.FirstName = "Mickey";
            oPerson.LastName = "Mouse";
            oPerson.TitleCode = "RCO";
            oPerson.DegreeEarnedDate = new DateTime(1990, 5, 15);
            oPerson.EducationInstitution = "University of PRCo";
            oPerson.EducationDegree = "Masters of Produce";
            oCompanySubmission.AddPersonnel(oPerson);

            oPhone = new Phone();
            oPhone.AreaCode = "111";
            oPhone.Number = "111-1111";
            oPerson.AddPhone(oPhone);

            oEmail = new InternetAddress();
            oEmail.Address = "person@travant.com";
            oPerson.AddEmail(oEmail);

            PersonHistory oPersonHistory = new PersonHistory();
            oPersonHistory.BBID = 102030;
            oPersonHistory.CompanyName = "Cool Company";
            oPersonHistory.City = "Vernon Hills";
            oPersonHistory.StateID = 14;
            oPersonHistory.StartDate = new DateTime(2001, 6, 1);
            oPersonHistory.OwnershipPercentage = 40M;

            oPerson.AddPersonHistory(oPersonHistory);

            Classification oClassification = new Classification();
            oClassification.ClassificationID = 5;
            oCompanySubmission.AddClassification(oClassification);
            oClassification = new Classification();
            oClassification.ClassificationID = 15;
            oCompanySubmission.AddClassification(oClassification);

            return oCompanySubmission;
        }
    }
}
