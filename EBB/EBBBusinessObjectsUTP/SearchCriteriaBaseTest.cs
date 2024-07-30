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

 Notes:	Created By Sharon Cole on 07/23/2007

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
    /// Provides the NUnit test functionality for the SearchCriteriaBaseTest classes.
    /// </summary>
    [TestFixture]
    public class SearchCriteriaBaseTest : TestBase
    {
        ///<summary>
        /// Get ready for some good ol'fashion testing...
        ///</summary>
        [TestFixtureSetUp]
        override public void Init()
        {
            base.Init();
        }

        ///<summary>
        /// Cleanup after ourselves...
        ///</summary>
        [TestFixtureTearDown]
        override public void Cleanup()
        {
            base.Cleanup();
        }

        /// <summary>
        /// Accesssor Test for SortAsc property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestSortAscAccessors()
        {
            SearchCriteriaBase oSearchCriteriaBase = new SearchCriteriaBase();
            oSearchCriteriaBase.SortAsc = true;
            Assert.AreEqual(true, oSearchCriteriaBase.SortAsc);
        }

        /// <summary>
        /// Accesssor Test for BBID property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestBBIDAccessors()
        {
            SearchCriteriaBase oSearchCriteriaBase = new SearchCriteriaBase();
            oSearchCriteriaBase.BBID = 5;
            Assert.AreEqual(5, oSearchCriteriaBase.BBID);
        }

        /// <summary>
        /// Accesssor Test for SearchWizardD property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestSearchWizardDAccessors()
        {
            SearchCriteriaBase oSearchCriteriaBase = new SearchCriteriaBase();
            oSearchCriteriaBase.SearchWizardID = 5;
            Assert.AreEqual(5, oSearchCriteriaBase.SearchWizardID);
        }

        /// <summary>
        /// Accesssor Test for CompanyName property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestCompanyNameAccessors()
        {
            SearchCriteriaBase oSearchCriteriaBase = new SearchCriteriaBase();
            oSearchCriteriaBase.CompanyName = "string";
            Assert.AreEqual("string", oSearchCriteriaBase.CompanyName);
        }

        /// <summary>
        /// Accesssor Test for SortField property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestSortFieldAccessors()
        {
            SearchCriteriaBase oSearchCriteriaBase = new SearchCriteriaBase();
            oSearchCriteriaBase.SortField = "string";
            Assert.AreEqual("string", oSearchCriteriaBase.SortField);
        }

        /// <summary>
        /// Accesssor Test for UserListIDs property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestUserListIDsAccessors()
        {
            SearchCriteriaBase oSearchCriteriaBase = new SearchCriteriaBase();
            oSearchCriteriaBase.UserListIDs = "string";
            Assert.AreEqual("string", oSearchCriteriaBase.UserListIDs);
        }

        /// <summary>
        /// Test for SQL returned by the GetSearchSQL function 
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        public void TestGetSearchSQL()
        {
            string szExpectedResults = "SELECT Comp_CompanyID FROM Company " +
                "WHERE Comp_CompanyID = @Param0 " +
                "AND Comp_CompanyID IN (SELECT DISTINCT prcse_CompanyId FROM PRCompanySearch WHERE prcse_NameAlphaOnly LIKE @Param1) " +
                "AND Comp_CompanyID IN (SELECT DISTINCT prwuld_AssociatedId FROM PRWebUserListDetail WHERE prwuld_WebUserListID IN (12,13,14) " +
                "AND prwuld_AssociatedType = @Param2)";

            SearchCriteriaBase oSearchCriteriaBase = new SearchCriteriaBase();

            oSearchCriteriaBase.BBID = 123456;
            oSearchCriteriaBase.CompanyName = "strube";
            oSearchCriteriaBase.UserListIDs = "12,13,14";
            
            ArrayList oParameters;

            string szSQL = oSearchCriteriaBase.GetSearchSQL(out oParameters);

            Assert.AreEqual(szExpectedResults.Trim(), szSQL.Trim());
            Assert.AreEqual(3, oParameters.Count);
        }
    }
}
