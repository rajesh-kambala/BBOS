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


namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Provides the NUnit test functionality for the PRWebUser classes.
    /// </summary>
    [TestFixture] 
    public class PRWebUserTest: TestBase
    {
        PRWebUserMgr _oMgr	= null;

        #region TSI Framework Generated Code
        ///<summary>
        /// Get ready for some good ol'fashion testing...
        ///</summary>
        [TestFixtureSetUp]
        override public void Init() {
            base.Init();
            IUser oUser = new User();
            oUser.UserID="9999";
            _oMgr = new PRWebUserMgr(LoggerFactory.GetLogger(), oUser);
        }

        ///<summary>
        /// Cleanup after ourselves...
        ///</summary>
        [TestFixtureTearDown]
        override public void Cleanup() {
        	base.Cleanup();
        }

        /// <summary>
        /// Accesssor Test for prwu_AcceptedTerms property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprwu_AcceptedTermsAccessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.prwu_AcceptedTerms = true;
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual(true, oPRWebUser.prwu_AcceptedTerms);
        }

        /// <summary>
        /// Accesssor Test for prwu_IsNewUser property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprwu_IsNewUserAccessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.prwu_IsNewUser = true;
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual(true, oPRWebUser.prwu_IsNewUser);
        }

        /// <summary>
        /// Accesssor Test for prwu_MailListOptIn property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprwu_MailListOptInAccessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.prwu_MailListOptIn = true;
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual(true, oPRWebUser.prwu_MailListOptIn);
        }

        /// <summary>
        /// Accesssor Test for prwu_MembershipInterest property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprwu_MembershipInterestAccessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.prwu_MembershipInterest = true;
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual(true, oPRWebUser.prwu_MembershipInterest);
        }

        /// <summary>
        /// Accesssor Test for LastLoginDate property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestLastLoginDateAccessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.LastLoginDate = DateTime.Now;
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual(DateTime.Now, oPRWebUser.LastLoginDate);
        }

        /// <summary>
        /// Accesssor Test for prwu_LastPasswordChange property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprwu_LastPasswordChangeAccessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.prwu_LastPasswordChange = DateTime.Now;
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual(DateTime.Now, oPRWebUser.prwu_LastPasswordChange);
        }

        /// <summary>
        /// Accesssor Test for prwu_TrialExpirationDate property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprwu_TrialExpirationDateAccessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.prwu_TrialExpirationDate = DateTime.Now;
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual(DateTime.Now, oPRWebUser.prwu_TrialExpirationDate);
        }

        /// <summary>
        /// Accesssor Test for prwu_BBID property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprwu_BBIDAccessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.prwu_BBID = 5;
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual(5, oPRWebUser.prwu_BBID);
        }

        /// <summary>
        /// Accesssor Test for prwu_CountryID property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprwu_CountryIDAccessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.prwu_CountryID = 5;
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual(5, oPRWebUser.prwu_CountryID);
        }

        /// <summary>
        /// Accesssor Test for prwu_FailedAttemptCount property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprwu_FailedAttemptCountAccessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.prwu_FailedAttemptCount = 5;
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual(5, oPRWebUser.prwu_FailedAttemptCount);
        }

        /// <summary>
        /// Accesssor Test for prwu_LastCompanySearchID property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprwu_LastCompanySearchIDAccessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.prwu_LastCompanySearchID = 5;
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual(5, oPRWebUser.prwu_LastCompanySearchID);
        }

        /// <summary>
        /// Accesssor Test for prwu_LastCreditSheetSearchID property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprwu_LastCreditSheetSearchIDAccessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.prwu_LastCreditSheetSearchID = 5;
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual(5, oPRWebUser.prwu_LastCreditSheetSearchID);
        }

        /// <summary>
        /// Accesssor Test for prwu_LastPersonSearchID property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprwu_LastPersonSearchIDAccessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.prwu_LastPersonSearchID = 5;
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual(5, oPRWebUser.prwu_LastPersonSearchID);
        }

        /// <summary>
        /// Accesssor Test for LoginCount property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestLoginCountAccessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.LoginCount = 5;
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual(5, oPRWebUser.LoginCount);
        }

        /// <summary>
        /// Accesssor Test for prwu_PersonLinkID property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprwu_PersonLinkIDAccessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.prwu_PersonLinkID = 5;
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual(5, oPRWebUser.prwu_PersonLinkID);
        }

        /// <summary>
        /// Accesssor Test for prwu_PRServiceID property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprwu_PRServiceIDAccessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.prwu_PRServiceID = 5;
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual(5, oPRWebUser.prwu_PRServiceID);
        }

        /// <summary>
        /// Accesssor Test for prwu_StateID property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprwu_StateIDAccessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.prwu_StateID = 5;
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual(5, oPRWebUser.prwu_StateID);
        }

        /// <summary>
        /// Accesssor Test for prwu_WebUserID property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprwu_WebUserIDAccessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.prwu_WebUserID = 5;
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual(5, oPRWebUser.prwu_WebUserID);
        }

        /// <summary>
        /// Accesssor Test for prwu_AccessLevel property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprwu_AccessLevelAccessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.prwu_AccessLevel = 5;
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual(5, oPRWebUser.prwu_AccessLevel);
        }

        /// <summary>
        /// Accesssor Test for prwu_Address1 property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprwu_Address1Accessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.prwu_Address1 = "string";
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual("string", oPRWebUser.prwu_Address1);
        }

        /// <summary>
        /// Accesssor Test for prwu_Address2 property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprwu_Address2Accessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.prwu_Address2 = "string";
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual("string", oPRWebUser.prwu_Address2);
        }

        /// <summary>
        /// Accesssor Test for prwu_City property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprwu_CityAccessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.prwu_City = "string";
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual("string", oPRWebUser.prwu_City);
        }

        /// <summary>
        /// Accesssor Test for prwu_CompanyData property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprwu_CompanyDataAccessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.prwu_CompanyData = "string";
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual("string", oPRWebUser.prwu_CompanyData);
        }

        /// <summary>
        /// Accesssor Test for prwu_CompanyName property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprwu_CompanyNameAccessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.prwu_CompanyName = "string";
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual("string", oPRWebUser.prwu_CompanyName);
        }

        /// <summary>
        /// Accesssor Test for prwu_CompanySize property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprwu_CompanySizeAccessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.prwu_CompanySize = "string";
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual("string", oPRWebUser.prwu_CompanySize);
        }

        /// <summary>
        /// Accesssor Test for prwu_Culture property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprwu_CultureAccessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.prwu_Culture = "x";
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual("x", oPRWebUser.prwu_Culture);
        }

        /// <summary>
        /// Accesssor Test for prwu_DefaultCompanySearchPage property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprwu_DefaultCompanySearchPageAccessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.prwu_DefaultCompanySearchPage = "string";
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual("string", oPRWebUser.prwu_DefaultCompanySearchPage);
        }

        /// <summary>
        /// Accesssor Test for Email property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestEmailAccessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.Email = "string";
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual("string", oPRWebUser.Email);
        }

        /// <summary>
        /// Accesssor Test for prwu_FaxAreaCode property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprwu_FaxAreaCodeAccessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.prwu_FaxAreaCode = "string";
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual("string", oPRWebUser.prwu_FaxAreaCode);
        }

        /// <summary>
        /// Accesssor Test for prwu_FaxNumber property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprwu_FaxNumberAccessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.prwu_FaxNumber = "string";
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual("string", oPRWebUser.prwu_FaxNumber);
        }

        /// <summary>
        /// Accesssor Test for FirstName property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestFirstNameAccessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.FirstName = "string";
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual("string", oPRWebUser.FirstName);
        }

        /// <summary>
        /// Accesssor Test for prwu_Gender property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprwu_GenderAccessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.prwu_Gender = "string";
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual("string", oPRWebUser.prwu_Gender);
        }

        /// <summary>
        /// Accesssor Test for prwu_HowLearned property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprwu_HowLearnedAccessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.prwu_HowLearned = "string";
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual("string", oPRWebUser.prwu_HowLearned);
        }

        /// <summary>
        /// Accesssor Test for prwu_IndustryClassification property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprwu_IndustryClassificationAccessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.prwu_IndustryClassification = "string";
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual("string", oPRWebUser.prwu_IndustryClassification);
        }

        /// <summary>
        /// Accesssor Test for LastName property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestLastNameAccessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.LastName = "string";
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual("string", oPRWebUser.LastName);
        }

        /// <summary>
        /// Accesssor Test for Password property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestPasswordAccessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.Password = "string";
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual("string", oPRWebUser.Password);
        }

        /// <summary>
        /// Accesssor Test for prwu_PhoneAreaCode property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprwu_PhoneAreaCodeAccessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.prwu_PhoneAreaCode = "string";
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual("string", oPRWebUser.prwu_PhoneAreaCode);
        }

        /// <summary>
        /// Accesssor Test for prwu_PhoneNumber property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprwu_PhoneNumberAccessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.prwu_PhoneNumber = "string";
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual("string", oPRWebUser.prwu_PhoneNumber);
        }

        /// <summary>
        /// Accesssor Test for prwu_PostalCode property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprwu_PostalCodeAccessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.prwu_PostalCode = "string";
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual("string", oPRWebUser.prwu_PostalCode);
        }

        /// <summary>
        /// Accesssor Test for prwu_TitleCode property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprwu_TitleCodeAccessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.prwu_TitleCode = "string";
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual("string", oPRWebUser.prwu_TitleCode);
        }

        /// <summary>
        /// Accesssor Test for prwu_UICulture property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprwu_UICultureAccessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.prwu_UICulture = "x";
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual("x", oPRWebUser.prwu_UICulture);
        }

        /// <summary>
        /// Accesssor Test for prwu_WebSite property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprwu_WebSiteAccessors() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();
            oPRWebUser.prwu_WebSite = "string";
            Assert.IsTrue(oPRWebUser.IsDirty);
            Assert.AreEqual("string", oPRWebUser.prwu_WebSite);
        }


        /// <summary>
        /// Saving a new Object 
        /// </summary>
        [Test]
        [Category("DatabaseAccess")]
        public void TestSaveNew() {
            IPRWebUser oPRWebUser = GetPopulatedObject();
            AddObjectToCleanup(oPRWebUser);

            try {
                oPRWebUser.Save();
            } catch (Exception e) {
                _oLogger.LogError(e);
                throw;
            }
            Assert.IsFalse(oPRWebUser.IsDirty, "IsDirty");

            IPRWebUser oPRWebUser2 = (IPRWebUser)_oMgr.GetObjectByKey(oPRWebUser.prwu_WebUserID);
            Assert.IsNotNull(oPRWebUser2);

        }

        /// <summary>
        /// Saving an existing Object 
        /// </summary>
        [Test]
        [Category("DatabaseAccess")]
        public void TestSaveUpdate() {
            IPRWebUser oPRWebUser = GetPopulatedObject();
            AddObjectToCleanup(oPRWebUser);

            oPRWebUser.Save();
            UpdateObject(oPRWebUser);
            oPRWebUser.Save();

            IPRWebUser oPRWebUser2 = (IPRWebUser)_oMgr.GetObjectByKey(oPRWebUser.GetKeyValues());
            Assert.IsNotNull(oPRWebUser2);

        }

        /// <summary>
        /// Deleting an Object 
        /// </summary>
        [Test]
        [Category("DatabaseAccess")]
        [ExpectedException(typeof(ObjectNotFoundException))]
        public void TestDelete() {
            IPRWebUser oPRWebUser = GetPopulatedObject();

            oPRWebUser.Save();
            oPRWebUser.Delete();
            Assert.IsFalse(oPRWebUser.IsInDB);

            IPRWebUser oPRWebUser2 = (IPRWebUser)_oMgr.GetObjectByKey(oPRWebUser.GetKeyValues());

        }

        /// <summary>
        /// Checking for existence 
        /// </summary>
        [Test]
        [Category("DatabaseAccess")]
        public void TestObjectExists() {
            IPRWebUser oPRWebUser = GetPopulatedObject();
            AddObjectToCleanup(oPRWebUser);
            oPRWebUser.Save();
            Assert.IsTrue(_oMgr.IsObjectExistByKey(oPRWebUser.GetKeyValues()));

        }

        /// <summary>
        /// Testing FieldColMapping 
        /// </summary>
        [Test]
        [Category("DatabaseAccess")]
        public void TestFieldColMapping() {
            IPRWebUser oPRWebUser = GetPopulatedObject();
            Assert.AreEqual(46, oPRWebUser.GetFieldColMapping().Count, "FieldColMapping.Count");

        }

        /// <summary>
        /// Validates audit fields 
        /// </summary>
        [Test]
        [Category("DatabaseAccess")]
        [Category("AuditField")]
        public void TestAuditFields() {
            DateTime dtSave = new DateTime(DateTime.Now.Year, DateTime.Now.Month, DateTime.Now.Day, DateTime.Now.Hour, DateTime.Now.Minute, DateTime.Now.Second);
            IPRWebUser oPRWebUser = GetPopulatedObject();
            AddObjectToCleanup(oPRWebUser);
            oPRWebUser.Save();
            Assert.AreEqual(_oMgr.User.UserID.ToString(), oPRWebUser.CreatedUserID);
            TSIAssert.IsGreaterThan(oPRWebUser.CreatedDateTime, dtSave);

            DateTime dtCreated = oPRWebUser.CreatedDateTime;
            dtSave = new DateTime(DateTime.Now.Year, DateTime.Now.Month, DateTime.Now.Day, DateTime.Now.Hour, DateTime.Now.Minute, DateTime.Now.Second);
            UpdateObject(oPRWebUser);
            oPRWebUser.Save();
            Assert.AreEqual(_oMgr.User.UserID.ToString(), oPRWebUser.UpdatedUserID, "UpdatedUserID 02");
            TSIAssert.IsGreaterThan(oPRWebUser.UpdatedDateTime, dtSave, "UpdatedDateTime 02");
            Assert.AreEqual(oPRWebUser.CreatedDateTime, dtCreated, "CreatedDateTime");

        }

        /// <summary>
        /// DataPersistence 
        /// </summary>
        [Test]
        [Category("DatabaseAccess")]
        public void TestDataPersistence() {
            IPRWebUser oPRWebUser = GetPopulatedObject();
			  oPRWebUser.Save();

            IPRWebUser oPRWebUser2 = (IPRWebUser)_oMgr.GetObjectByKey(oPRWebUser.GetKeyValues());
            AddObjectToCleanup(oPRWebUser2);

            Assert.AreEqual(oPRWebUser.prwu_AcceptedTerms, oPRWebUser2.prwu_AcceptedTerms, "prwu_AcceptedTerms");
            Assert.AreEqual(oPRWebUser.prwu_IsNewUser, oPRWebUser2.prwu_IsNewUser, "prwu_IsNewUser");
            Assert.AreEqual(oPRWebUser.prwu_MailListOptIn, oPRWebUser2.prwu_MailListOptIn, "prwu_MailListOptIn");
            Assert.AreEqual(oPRWebUser.prwu_MembershipInterest, oPRWebUser2.prwu_MembershipInterest, "prwu_MembershipInterest");
            TSIAssert.AreEqual(oPRWebUser.LastLoginDate, oPRWebUser2.LastLoginDate, "LastLoginDate");
            TSIAssert.AreEqual(oPRWebUser.prwu_LastPasswordChange, oPRWebUser2.prwu_LastPasswordChange, "prwu_LastPasswordChange");
            TSIAssert.AreEqual(oPRWebUser.prwu_TrialExpirationDate, oPRWebUser2.prwu_TrialExpirationDate, "prwu_TrialExpirationDate");
            Assert.AreEqual(oPRWebUser.prwu_BBID, oPRWebUser2.prwu_BBID, "prwu_BBID");
            Assert.AreEqual(oPRWebUser.prwu_CountryID, oPRWebUser2.prwu_CountryID, "prwu_CountryID");
            Assert.AreEqual(oPRWebUser.prwu_FailedAttemptCount, oPRWebUser2.prwu_FailedAttemptCount, "prwu_FailedAttemptCount");
            Assert.AreEqual(oPRWebUser.prwu_LastCompanySearchID, oPRWebUser2.prwu_LastCompanySearchID, "prwu_LastCompanySearchID");
            Assert.AreEqual(oPRWebUser.prwu_LastCreditSheetSearchID, oPRWebUser2.prwu_LastCreditSheetSearchID, "prwu_LastCreditSheetSearchID");
            Assert.AreEqual(oPRWebUser.prwu_LastPersonSearchID, oPRWebUser2.prwu_LastPersonSearchID, "prwu_LastPersonSearchID");
            Assert.AreEqual(oPRWebUser.LoginCount, oPRWebUser2.LoginCount, "LoginCount");
            Assert.AreEqual(oPRWebUser.prwu_PersonLinkID, oPRWebUser2.prwu_PersonLinkID, "prwu_PersonLinkID");
            Assert.AreEqual(oPRWebUser.prwu_PRServiceID, oPRWebUser2.prwu_PRServiceID, "prwu_PRServiceID");
            Assert.AreEqual(oPRWebUser.prwu_StateID, oPRWebUser2.prwu_StateID, "prwu_StateID");
            Assert.AreEqual(oPRWebUser.prwu_WebUserID, oPRWebUser2.prwu_WebUserID, "prwu_WebUserID");
            Assert.AreEqual(oPRWebUser.prwu_AccessLevel, oPRWebUser2.prwu_AccessLevel, "prwu_AccessLevel");
            Assert.AreEqual(oPRWebUser.prwu_Address1, oPRWebUser2.prwu_Address1, "prwu_Address1");
            Assert.AreEqual(oPRWebUser.prwu_Address2, oPRWebUser2.prwu_Address2, "prwu_Address2");
            Assert.AreEqual(oPRWebUser.prwu_City, oPRWebUser2.prwu_City, "prwu_City");
            Assert.AreEqual(oPRWebUser.prwu_CompanyData, oPRWebUser2.prwu_CompanyData, "prwu_CompanyData");
            Assert.AreEqual(oPRWebUser.prwu_CompanyName, oPRWebUser2.prwu_CompanyName, "prwu_CompanyName");
            Assert.AreEqual(oPRWebUser.prwu_CompanySize, oPRWebUser2.prwu_CompanySize, "prwu_CompanySize");
            Assert.AreEqual(oPRWebUser.prwu_Culture, oPRWebUser2.prwu_Culture, "prwu_Culture");
            Assert.AreEqual(oPRWebUser.prwu_DefaultCompanySearchPage, oPRWebUser2.prwu_DefaultCompanySearchPage, "prwu_DefaultCompanySearchPage");
            Assert.AreEqual(oPRWebUser.Email, oPRWebUser2.Email, "Email");
            Assert.AreEqual(oPRWebUser.prwu_FaxAreaCode, oPRWebUser2.prwu_FaxAreaCode, "prwu_FaxAreaCode");
            Assert.AreEqual(oPRWebUser.prwu_FaxNumber, oPRWebUser2.prwu_FaxNumber, "prwu_FaxNumber");
            Assert.AreEqual(oPRWebUser.FirstName, oPRWebUser2.FirstName, "FirstName");
            Assert.AreEqual(oPRWebUser.prwu_Gender, oPRWebUser2.prwu_Gender, "prwu_Gender");
            Assert.AreEqual(oPRWebUser.prwu_HowLearned, oPRWebUser2.prwu_HowLearned, "prwu_HowLearned");
            Assert.AreEqual(oPRWebUser.prwu_IndustryClassification, oPRWebUser2.prwu_IndustryClassification, "prwu_IndustryClassification");
            Assert.AreEqual(oPRWebUser.LastName, oPRWebUser2.LastName, "LastName");
            Assert.AreEqual(oPRWebUser.Password, oPRWebUser2.Password, "Password");
            Assert.AreEqual(oPRWebUser.prwu_PhoneAreaCode, oPRWebUser2.prwu_PhoneAreaCode, "prwu_PhoneAreaCode");
            Assert.AreEqual(oPRWebUser.prwu_PhoneNumber, oPRWebUser2.prwu_PhoneNumber, "prwu_PhoneNumber");
            Assert.AreEqual(oPRWebUser.prwu_PostalCode, oPRWebUser2.prwu_PostalCode, "prwu_PostalCode");
            Assert.AreEqual(oPRWebUser.prwu_TitleCode, oPRWebUser2.prwu_TitleCode, "prwu_TitleCode");
            Assert.AreEqual(oPRWebUser.prwu_UICulture, oPRWebUser2.prwu_UICulture, "prwu_UICulture");
            Assert.AreEqual(oPRWebUser.prwu_WebSite, oPRWebUser2.prwu_WebSite, "prwu_WebSite");
        }

        /// <summary>
        /// Helper Method 
        /// Populates the object with dummy data 
        /// </summary>
        protected IPRWebUser GetPopulatedObject() {
            IPRWebUser oPRWebUser = (IPRWebUser)_oMgr.CreateObject();

            oPRWebUser.prwu_AcceptedTerms = true;
            oPRWebUser.prwu_IsNewUser = true;
            oPRWebUser.prwu_MailListOptIn = true;
            oPRWebUser.prwu_MembershipInterest = true;
            oPRWebUser.LastLoginDate = DateTime.Now;
            oPRWebUser.prwu_LastPasswordChange = DateTime.Now;
            oPRWebUser.prwu_TrialExpirationDate = DateTime.Now;
            oPRWebUser.prwu_BBID = 5;
            oPRWebUser.prwu_CountryID = 5;
            oPRWebUser.prwu_FailedAttemptCount = 5;
            oPRWebUser.prwu_LastCompanySearchID = 5;
            oPRWebUser.prwu_LastCreditSheetSearchID = 5;
            oPRWebUser.prwu_LastPersonSearchID = 5;
            oPRWebUser.LoginCount = 5;
            oPRWebUser.prwu_PersonLinkID = 5;
            oPRWebUser.prwu_PRServiceID = 5;
            oPRWebUser.prwu_StateID = 5;
            //oPRWebUser.prwu_WebUserID = 5;
            oPRWebUser.prwu_AccessLevel = 5;
            oPRWebUser.prwu_Address1 = "string";
            oPRWebUser.prwu_Address2 = "string";
            oPRWebUser.prwu_City = "string";
            oPRWebUser.prwu_CompanyData = "string";
            oPRWebUser.prwu_CompanyName = "string";
            oPRWebUser.prwu_CompanySize = "string";
            oPRWebUser.prwu_Culture = "x";
            oPRWebUser.prwu_DefaultCompanySearchPage = "string";
            oPRWebUser.Email = "string";
            oPRWebUser.prwu_FaxAreaCode = "string";
            oPRWebUser.prwu_FaxNumber = "string";
            oPRWebUser.FirstName = "string";
            oPRWebUser.prwu_Gender = "string";
            oPRWebUser.prwu_HowLearned = "string";
            oPRWebUser.prwu_IndustryClassification = "string";
            oPRWebUser.LastName = "string";
            //oPRWebUser.Password = "string";
            oPRWebUser.prwu_PhoneAreaCode = "string";
            oPRWebUser.prwu_PhoneNumber = "string";
            oPRWebUser.prwu_PostalCode = "string";
            oPRWebUser.prwu_TitleCode = "string";
            oPRWebUser.prwu_UICulture = "x";
            oPRWebUser.prwu_WebSite = "string";
            return oPRWebUser;
        }

        /// <summary>
        /// Helper Method 
        /// Populates the object with different dummy data 
        /// </summary>
        protected  void UpdateObject(IPRWebUser oPRWebUser) {
            oPRWebUser.prwu_AcceptedTerms = false;
            oPRWebUser.prwu_IsNewUser = false;
            oPRWebUser.prwu_MailListOptIn = false;
            oPRWebUser.prwu_MembershipInterest = false;
            oPRWebUser.LastLoginDate = DateTime.Now.AddDays(-1);
            oPRWebUser.prwu_LastPasswordChange = DateTime.Now.AddDays(-1);
            oPRWebUser.prwu_TrialExpirationDate = DateTime.Now.AddDays(-1);
            oPRWebUser.prwu_BBID = 10;
            oPRWebUser.prwu_CountryID = 10;
            oPRWebUser.prwu_FailedAttemptCount = 10;
            oPRWebUser.prwu_LastCompanySearchID = 10;
            oPRWebUser.prwu_LastCreditSheetSearchID = 10;
            oPRWebUser.prwu_LastPersonSearchID = 10;
            oPRWebUser.LoginCount = 10;
            oPRWebUser.prwu_PersonLinkID = 10;
            oPRWebUser.prwu_PRServiceID = 10;
            oPRWebUser.prwu_StateID = 10;
            //oPRWebUser.prwu_WebUserID = 10;
            oPRWebUser.prwu_AccessLevel = 10;
            oPRWebUser.prwu_Address1 = "stringXX";
            oPRWebUser.prwu_Address2 = "stringXX";
            oPRWebUser.prwu_City = "stringXX";
            oPRWebUser.prwu_CompanyData = "stringXX";
            oPRWebUser.prwu_CompanyName = "stringXX";
            oPRWebUser.prwu_CompanySize = "stringXX";
            oPRWebUser.prwu_Culture = "y";
            oPRWebUser.prwu_DefaultCompanySearchPage = "stringXX";
            oPRWebUser.Email = "stringXX";
            oPRWebUser.prwu_FaxAreaCode = "stringXX";
            oPRWebUser.prwu_FaxNumber = "stringXX";
            oPRWebUser.FirstName = "stringXX";
            oPRWebUser.prwu_Gender = "strgXX";
            oPRWebUser.prwu_HowLearned = "stringXX";
            oPRWebUser.prwu_IndustryClassification = "stringXX";
            oPRWebUser.LastName = "stringXX";
            //oPRWebUser.Password = "stringXX";
            oPRWebUser.prwu_PhoneAreaCode = "stringXX";
            oPRWebUser.prwu_PhoneNumber = "stringXX";
            oPRWebUser.prwu_PostalCode = "stringXX";
            oPRWebUser.prwu_TitleCode = "stringXX";
            oPRWebUser.prwu_UICulture = "y";
            oPRWebUser.prwu_WebSite = "stringXX";
        }
        #endregion
    }
}
