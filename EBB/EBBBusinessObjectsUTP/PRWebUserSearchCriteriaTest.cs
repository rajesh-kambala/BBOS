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

 Notes:	Created By TSI Class Generator on 7/17/2007 1:11:32 PM

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
    /// Provides the NUnit test functionality for the PRWebUserSearchCriteria classes.
    /// </summary>
    [TestFixture] 
    public class PRWebUserSearchCriteriaTest: TestBase
    {
        PRWebUserSearchCriteriaMgr _oMgr	= null;

        #region TSI Framework Generated Code
        ///<summary>
        /// Get ready for some good ol'fashion testing...
        ///</summary>
        [TestFixtureSetUp]
        override public void Init() {
            base.Init();
            IUser oUser = new User();
            oUser.UserID="9999";
            _oMgr = new PRWebUserSearchCriteriaMgr(LoggerFactory.GetLogger(), oUser);
        }

        ///<summary>
        /// Cleanup after ourselves...
        ///</summary>
        [TestFixtureTearDown]
        override public void Cleanup() {
        	base.Cleanup();
        }

        /// <summary>
        /// Accesssor Test for prsc_SearchCriteriaID property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprsc_SearchCriteriaIDAccessors()
        {
            IPRWebUserSearchCriteria oPRWebUserSearchCriteria = (IPRWebUserSearchCriteria)_oMgr.CreateObject();
            oPRWebUserSearchCriteria.prsc_SearchCriteriaID = 5;
            Assert.IsTrue(oPRWebUserSearchCriteria.IsDirty);
            Assert.AreEqual(5, oPRWebUserSearchCriteria.prsc_SearchCriteriaID);
        }

        /// <summary>
        /// Accesssor Test for prsc_LastExecutionDateTime property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprsc_LastExecutionDateTimeAccessors() {
            IPRWebUserSearchCriteria oPRWebUserSearchCriteria = (IPRWebUserSearchCriteria)_oMgr.CreateObject();
            oPRWebUserSearchCriteria.prsc_LastExecutionDateTime = DateTime.Now;
            Assert.IsTrue(oPRWebUserSearchCriteria.IsDirty);
            Assert.AreEqual(DateTime.Now, oPRWebUserSearchCriteria.prsc_LastExecutionDateTime);
        }


        /// <summary>
        /// Accesssor Test for prsc_CompanyID property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprsc_CompanyIDAccessors() {
            IPRWebUserSearchCriteria oPRWebUserSearchCriteria = (IPRWebUserSearchCriteria)_oMgr.CreateObject();
            oPRWebUserSearchCriteria.prsc_CompanyID = 5;
            Assert.IsTrue(oPRWebUserSearchCriteria.IsDirty);
            Assert.AreEqual(5, oPRWebUserSearchCriteria.prsc_CompanyID);
        }

        /// <summary>
        /// Accesssor Test for prsc_ExecutionCount property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprsc_ExecutionCountAccessors() {
            IPRWebUserSearchCriteria oPRWebUserSearchCriteria = (IPRWebUserSearchCriteria)_oMgr.CreateObject();
            oPRWebUserSearchCriteria.prsc_ExecutionCount = 5;
            Assert.IsTrue(oPRWebUserSearchCriteria.IsDirty);
            Assert.AreEqual(5, oPRWebUserSearchCriteria.prsc_ExecutionCount);
        }

        /// <summary>
        /// Accesssor Test for prsc_HQID property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprsc_HQIDAccessors() {
            IPRWebUserSearchCriteria oPRWebUserSearchCriteria = (IPRWebUserSearchCriteria)_oMgr.CreateObject();
            oPRWebUserSearchCriteria.prsc_HQID = 5;
            Assert.IsTrue(oPRWebUserSearchCriteria.IsDirty);
            Assert.AreEqual(5, oPRWebUserSearchCriteria.prsc_HQID);
        }

        /// <summary>
        /// Accesssor Test for prsc_LastExecutionResultCount property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprsc_LastExecutionResultCountAccessors() {
            IPRWebUserSearchCriteria oPRWebUserSearchCriteria = (IPRWebUserSearchCriteria)_oMgr.CreateObject();
            oPRWebUserSearchCriteria.prsc_LastExecutionResultCount = 5;
            Assert.IsTrue(oPRWebUserSearchCriteria.IsDirty);
            Assert.AreEqual(5, oPRWebUserSearchCriteria.prsc_LastExecutionResultCount);
        }


        /// <summary>
        /// Accesssor Test for prsc_WebUserID property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprsc_WebUserIDAccessors() {
            IPRWebUserSearchCriteria oPRWebUserSearchCriteria = (IPRWebUserSearchCriteria)_oMgr.CreateObject();
            oPRWebUserSearchCriteria.prsc_WebUserID = 5;
            Assert.IsTrue(oPRWebUserSearchCriteria.IsDirty);
            Assert.AreEqual(5, oPRWebUserSearchCriteria.prsc_WebUserID);
        }


        /// <summary>
        /// Accesssor Test for prsc_Criteria property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprsc_CriteriaAccessors() {
            IPRWebUserSearchCriteria oPRWebUserSearchCriteria = (IPRWebUserSearchCriteria)_oMgr.CreateObject();
            oPRWebUserSearchCriteria.prsc_Criteria = "string";
            Assert.IsTrue(oPRWebUserSearchCriteria.IsDirty);
            Assert.AreEqual("string", oPRWebUserSearchCriteria.prsc_Criteria);
        }

        /// <summary>
        /// Accesssor Test for prsc_IsLastUnsavedSearch property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprsc_IsLastUnsavedSearchAccessors() {
            IPRWebUserSearchCriteria oPRWebUserSearchCriteria = (IPRWebUserSearchCriteria)_oMgr.CreateObject();
            oPRWebUserSearchCriteria.prsc_IsLastUnsavedSearch = true;
            Assert.IsTrue(oPRWebUserSearchCriteria.IsDirty);
            Assert.AreEqual(true, oPRWebUserSearchCriteria.prsc_IsLastUnsavedSearch);
        }

        /// <summary>
        /// Accesssor Test for prsc_IsPrivate property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprsc_IsPrivateAccessors() {
            IPRWebUserSearchCriteria oPRWebUserSearchCriteria = (IPRWebUserSearchCriteria)_oMgr.CreateObject();
            oPRWebUserSearchCriteria.prsc_IsPrivate = true;
            Assert.IsTrue(oPRWebUserSearchCriteria.IsDirty);
            Assert.AreEqual(true, oPRWebUserSearchCriteria.prsc_IsPrivate);
        }

        /// <summary>
        /// Accesssor Test for prsc_Name property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprsc_NameAccessors() {
            IPRWebUserSearchCriteria oPRWebUserSearchCriteria = (IPRWebUserSearchCriteria)_oMgr.CreateObject();
            oPRWebUserSearchCriteria.prsc_Name = "string";
            Assert.IsTrue(oPRWebUserSearchCriteria.IsDirty);
            Assert.AreEqual("string", oPRWebUserSearchCriteria.prsc_Name);
        }

        /// <summary>
        /// Accesssor Test for prsc_SearchType property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprsc_SearchTypeAccessors() {
            IPRWebUserSearchCriteria oPRWebUserSearchCriteria = (IPRWebUserSearchCriteria)_oMgr.CreateObject();
            oPRWebUserSearchCriteria.prsc_SearchType = "string";
            Assert.IsTrue(oPRWebUserSearchCriteria.IsDirty);
            Assert.AreEqual("string", oPRWebUserSearchCriteria.prsc_SearchType);
        }

        /// <summary>
        /// Accesssor Test for prsc_SelectedIDs property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void Testprsc_SelectedIDsAccessors() {
            IPRWebUserSearchCriteria oPRWebUserSearchCriteria = (IPRWebUserSearchCriteria)_oMgr.CreateObject();
            oPRWebUserSearchCriteria.prsc_SelectedIDs = "string";
            Assert.IsTrue(oPRWebUserSearchCriteria.IsDirty);
            Assert.AreEqual("string", oPRWebUserSearchCriteria.prsc_SelectedIDs);
        }


        /// <summary>
        /// Saving a new Object 
        /// </summary>
        [Test]
        [Category("DatabaseAccess")]
        public void TestSaveNew() {
            IPRWebUserSearchCriteria oPRWebUserSearchCriteria = GetPopulatedObject();
            AddObjectToCleanup(oPRWebUserSearchCriteria);
            oPRWebUserSearchCriteria.Save();
            Assert.IsFalse(oPRWebUserSearchCriteria.IsDirty, "IsDirty");

            IPRWebUserSearchCriteria oPRWebUserSearchCriteria2 = (IPRWebUserSearchCriteria)_oMgr.GetObjectByKey(oPRWebUserSearchCriteria.GetKeyValues());
            Assert.IsNotNull(oPRWebUserSearchCriteria2);

        }

        /// <summary>
        /// Saving an existing Object 
        /// </summary>
        [Test]
        [Category("DatabaseAccess")]
        public void TestSaveUpdate() {
            IPRWebUserSearchCriteria oPRWebUserSearchCriteria = GetPopulatedObject();
            AddObjectToCleanup(oPRWebUserSearchCriteria);

            oPRWebUserSearchCriteria.Save();
            UpdateObject(oPRWebUserSearchCriteria);
            oPRWebUserSearchCriteria.Save();

            IPRWebUserSearchCriteria oPRWebUserSearchCriteria2 = (IPRWebUserSearchCriteria)_oMgr.GetObjectByKey(oPRWebUserSearchCriteria.GetKeyValues());
            Assert.IsNotNull(oPRWebUserSearchCriteria2);

        }

        /// <summary>
        /// Deleting an Object 
        /// </summary>
        [Test]
        [Category("DatabaseAccess")]
        [ExpectedException(typeof(ObjectNotFoundException))]
        public void TestDelete() {
            IPRWebUserSearchCriteria oPRWebUserSearchCriteria = GetPopulatedObject();

            oPRWebUserSearchCriteria.Save();
            oPRWebUserSearchCriteria.Delete();
            Assert.IsFalse(oPRWebUserSearchCriteria.IsInDB);

            IPRWebUserSearchCriteria oPRWebUserSearchCriteria2 = (IPRWebUserSearchCriteria)_oMgr.GetObjectByKey(oPRWebUserSearchCriteria.GetKeyValues());

        }

        /// <summary>
        /// Checking for existence 
        /// </summary>
        [Test]
        [Category("DatabaseAccess")]
        public void TestObjectExists() {
            IPRWebUserSearchCriteria oPRWebUserSearchCriteria = GetPopulatedObject();
            AddObjectToCleanup(oPRWebUserSearchCriteria);
            oPRWebUserSearchCriteria.Save();
            Assert.IsTrue(_oMgr.IsObjectExistByKey(oPRWebUserSearchCriteria.GetKeyValues()));

        }

        /// <summary>
        /// Testing FieldColMapping 
        /// </summary>
        [Test]
        [Category("DatabaseAccess")]
        public void TestFieldColMapping() {
            IPRWebUserSearchCriteria oPRWebUserSearchCriteria = GetPopulatedObject();
            Assert.AreEqual(18, oPRWebUserSearchCriteria.GetFieldColMapping().Count, "FieldColMapping.Count");

        }

        /// <summary>
        /// Validates audit fields 
        /// </summary>
        [Test]
        [Category("DatabaseAccess")]
        [Category("AuditField")]
        public void TestAuditFields() {
            DateTime dtSave = new DateTime(DateTime.Now.Year, DateTime.Now.Month, DateTime.Now.Day, DateTime.Now.Hour, DateTime.Now.Minute, DateTime.Now.Second);
            IPRWebUserSearchCriteria oPRWebUserSearchCriteria = GetPopulatedObject();
            AddObjectToCleanup(oPRWebUserSearchCriteria);
            oPRWebUserSearchCriteria.Save();
            Assert.AreEqual(_oMgr.User.UserID.ToString(), oPRWebUserSearchCriteria.CreatedUserID);
            TSIAssert.IsGreaterThan(oPRWebUserSearchCriteria.CreatedDateTime, dtSave);
            Assert.AreEqual(_oMgr.User.UserID.ToString(), oPRWebUserSearchCriteria.UpdatedUserID);
            TSIAssert.IsGreaterThan(oPRWebUserSearchCriteria.UpdatedDateTime, dtSave);

            DateTime dtCreated = oPRWebUserSearchCriteria.CreatedDateTime;
            dtSave = new DateTime(DateTime.Now.Year, DateTime.Now.Month, DateTime.Now.Day, DateTime.Now.Hour, DateTime.Now.Minute, DateTime.Now.Second);
            UpdateObject(oPRWebUserSearchCriteria);
            oPRWebUserSearchCriteria.Save();
            Assert.AreEqual(_oMgr.User.UserID.ToString(), oPRWebUserSearchCriteria.UpdatedUserID, "UpdatedUserID 02");
            TSIAssert.IsGreaterThan(oPRWebUserSearchCriteria.UpdatedDateTime, dtSave, "UpdatedDateTime 02");
            Assert.AreEqual(oPRWebUserSearchCriteria.CreatedDateTime, dtCreated, "CreatedDateTime");

        }

        /// <summary>
        /// DataPersistence 
        /// </summary>
        [Test]
        [Category("DatabaseAccess")]
        public void TestDataPersistence() {
            IPRWebUserSearchCriteria oPRWebUserSearchCriteria = GetPopulatedObject();
			  oPRWebUserSearchCriteria.Save();

            IPRWebUserSearchCriteria oPRWebUserSearchCriteria2 = (IPRWebUserSearchCriteria)_oMgr.GetObjectByKey(oPRWebUserSearchCriteria.GetKeyValues());
            AddObjectToCleanup(oPRWebUserSearchCriteria2);

            TSIAssert.AreEqual(oPRWebUserSearchCriteria.CreatedDateTime, oPRWebUserSearchCriteria2.CreatedDateTime, "prsc_CreatedDate");
            TSIAssert.AreEqual(oPRWebUserSearchCriteria.prsc_LastExecutionDateTime, oPRWebUserSearchCriteria2.prsc_LastExecutionDateTime, "prsc_LastExecutionDateTime");
            TSIAssert.AreEqual(oPRWebUserSearchCriteria.UpdatedDateTime, oPRWebUserSearchCriteria2.UpdatedDateTime, "prsc_UpdatedDate");
            Assert.AreEqual(oPRWebUserSearchCriteria.prsc_CompanyID, oPRWebUserSearchCriteria2.prsc_CompanyID, "prsc_CompanyID");
            Assert.AreEqual(oPRWebUserSearchCriteria.CreatedUserID, oPRWebUserSearchCriteria2.CreatedUserID, "prsc_CreatedBy");
            Assert.AreEqual(oPRWebUserSearchCriteria.prsc_ExecutionCount, oPRWebUserSearchCriteria2.prsc_ExecutionCount, "prsc_ExecutionCount");
            Assert.AreEqual(oPRWebUserSearchCriteria.prsc_HQID, oPRWebUserSearchCriteria2.prsc_HQID, "prsc_HQID");
            Assert.AreEqual(oPRWebUserSearchCriteria.prsc_LastExecutionResultCount, oPRWebUserSearchCriteria2.prsc_LastExecutionResultCount, "prsc_LastExecutionResultCount");
            Assert.AreEqual(oPRWebUserSearchCriteria.UpdatedUserID, oPRWebUserSearchCriteria2.UpdatedUserID, "prsc_UpdatedBy");
            Assert.AreEqual(oPRWebUserSearchCriteria.prsc_WebUserID, oPRWebUserSearchCriteria2.prsc_WebUserID, "prsc_WebUserID");
            Assert.AreEqual(oPRWebUserSearchCriteria.prsc_Criteria, oPRWebUserSearchCriteria2.prsc_Criteria, "prsc_Criteria");
            Assert.AreEqual(oPRWebUserSearchCriteria.prsc_IsLastUnsavedSearch, oPRWebUserSearchCriteria2.prsc_IsLastUnsavedSearch, "prsc_IsLastUnsavedSearch");
            Assert.AreEqual(oPRWebUserSearchCriteria.prsc_IsPrivate, oPRWebUserSearchCriteria2.prsc_IsPrivate, "prsc_IsPrivate");
            Assert.AreEqual(oPRWebUserSearchCriteria.prsc_Name, oPRWebUserSearchCriteria2.prsc_Name, "prsc_Name");
            Assert.AreEqual(oPRWebUserSearchCriteria.prsc_SearchType, oPRWebUserSearchCriteria2.prsc_SearchType, "prsc_SearchType");
            Assert.AreEqual(oPRWebUserSearchCriteria.prsc_SelectedIDs, oPRWebUserSearchCriteria2.prsc_SelectedIDs, "prsc_SelectedIDs");
        }

        /// <summary>
        /// Helper Method 
        /// Populates the object with dummy data 
        /// </summary>
        protected IPRWebUserSearchCriteria GetPopulatedObject() {
            IPRWebUserSearchCriteria oPRWebUserSearchCriteria = (IPRWebUserSearchCriteria)_oMgr.CreateObject();

            oPRWebUserSearchCriteria.prsc_LastExecutionDateTime = DateTime.Now;
            oPRWebUserSearchCriteria.prsc_CompanyID = 5;
            oPRWebUserSearchCriteria.prsc_ExecutionCount = 5;
            oPRWebUserSearchCriteria.prsc_HQID = 5;
            oPRWebUserSearchCriteria.prsc_LastExecutionResultCount = 5;
            oPRWebUserSearchCriteria.prsc_WebUserID = 5;
            oPRWebUserSearchCriteria.prsc_Name = "string";
            oPRWebUserSearchCriteria.prsc_SearchType = PRWebUserSearchCriteria.SEARCH_TYPE_COMPANY;
            oPRWebUserSearchCriteria.prsc_SelectedIDs = "string";
            oPRWebUserSearchCriteria.prsc_IsLastUnsavedSearch = true;
            oPRWebUserSearchCriteria.prsc_IsPrivate = true;

            oPRWebUserSearchCriteria.Criteria = new CompanySearchCriteria();

            return oPRWebUserSearchCriteria;
        }

        /// <summary>
        /// Helper Method 
        /// Populates the object with different dummy data 
        /// </summary>
        protected  void UpdateObject(IPRWebUserSearchCriteria oPRWebUserSearchCriteria) {
            oPRWebUserSearchCriteria.prsc_LastExecutionDateTime = DateTime.Now.AddDays(-1);
            oPRWebUserSearchCriteria.prsc_CompanyID = 10;
            oPRWebUserSearchCriteria.prsc_ExecutionCount = 10;
            oPRWebUserSearchCriteria.prsc_HQID = 10;
            oPRWebUserSearchCriteria.prsc_LastExecutionResultCount = 10;
            oPRWebUserSearchCriteria.prsc_WebUserID = 10;
            oPRWebUserSearchCriteria.prsc_Name = "stringXX";
            oPRWebUserSearchCriteria.prsc_SearchType = PRWebUserSearchCriteria.SEARCH_TYPE_COMPANY;
            oPRWebUserSearchCriteria.prsc_SelectedIDs = "stringXX";
            oPRWebUserSearchCriteria.prsc_IsLastUnsavedSearch = false;
            oPRWebUserSearchCriteria.prsc_IsPrivate = false;
        }
        #endregion
    }
}
