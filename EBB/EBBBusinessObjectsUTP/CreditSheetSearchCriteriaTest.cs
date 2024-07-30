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

 ClassName: CreditSheetSearchCriteriaTest
 Description:	

 Notes:	Created By Sharon Cole on 07/20/2007

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
    /// Provides the NUnit test functionality for the CreditSheetSearchCriteria classes.
    /// </summary>
    [TestFixture] 
    public class CreditSheetSearchCriteriaTest : TestBase
    {
        ///<summary>
        /// Get ready for some good ol'fashion testing...
        ///</summary>
        [TestFixtureSetUp]
        override public void Init() {
            base.Init();
        }

        ///<summary>
        /// Cleanup after ourselves...
        ///</summary>
        [TestFixtureTearDown]
        override public void Cleanup() {
        	base.Cleanup();
        }

        /// <summary>
        /// Accesssor Test for KeyOnly property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestKeyOnlyAccessors()
        {
            CreditSheetSearchCriteria oCreditSheetSearchCriteria = new CreditSheetSearchCriteria();
            oCreditSheetSearchCriteria.KeyOnly = true;
            Assert.AreEqual(true, oCreditSheetSearchCriteria.KeyOnly);
        }

        /// <summary>
        /// Accesssor Test for FromDate property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestFromDateAccessors()
        {
            CreditSheetSearchCriteria oCreditSheetSearchCriteria = new CreditSheetSearchCriteria();
            oCreditSheetSearchCriteria.FromDate = DateTime.Now;
            Assert.AreEqual(DateTime.Now, oCreditSheetSearchCriteria.FromDate);
        }

        /// <summary>
        /// Accesssor Test for ToDate property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestToDateAccessors()
        {
            CreditSheetSearchCriteria oCreditSheetSearchCriteria = new CreditSheetSearchCriteria();
            oCreditSheetSearchCriteria.ToDate = DateTime.Now;
            Assert.AreEqual(DateTime.Now, oCreditSheetSearchCriteria.ToDate);
        }

        /// <summary>
        /// Accesssor Test for DateRangeType property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestDateRangeTypeAccessors()
        {
            CreditSheetSearchCriteria oCreditSheetSearchCriteria = new CreditSheetSearchCriteria();
            oCreditSheetSearchCriteria.DateRangeType = "string";
            Assert.AreEqual("string", oCreditSheetSearchCriteria.DateRangeType);
        }

        /// <summary>
        /// Test for SQL returned by the GetSearchSQL function 
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        public void TestGetSearchSQLFunction()
        {
            string szExpectedResults = "SELECT TOP " + Utilities.GetConfigValue("CompanyUpdateSearchMaxResults", "2000") + 
                " * FROM (SELECT *, dbo.ufn_GetItem(prcs_CreditSheetID, 2, 1, 34) AS ItemText, " +
                "dbo.ufn_HasNote(9999, 0, comp_CompanyID, 'C') As HasNote FROM PRCreditSheet " +
                "INNER JOIN vPRBBOSCompanyList ON prcs_CompanyId = comp_CompanyID " +
                "WHERE  prcs_CompanyId IN (SELECT DISTINCT prcse_CompanyId FROM PRCompanySearch " +
                "WHERE prcse_NameAlphaOnly LIKE @Param0) AND prcs_PublishableDate >= @Param1 " +
                "AND prcs_PublishableDate < @Param2 AND prcs_KeyFlag = @Param3) T1";

            CreditSheetSearchCriteria oCriteria = new CreditSheetSearchCriteria();

            IPRWebUser oWebUser = new PRWebUser();
            oWebUser.UserID = "9999";
            oWebUser.prwu_WebUserID = 9999;

            oCriteria.WebUser = oWebUser;
            oCriteria.CompanyName = "Strube";
            oCriteria.DateRangeType = "This Quarter";
            oCriteria.KeyOnly = true;            

            ArrayList oParameters;

            string szSQL = oCriteria.GetSearchSQL(out oParameters);

            Assert.AreEqual(szExpectedResults.Trim(), szSQL.Trim());
            Assert.AreEqual(4, oParameters.Count);
        }

        /// <summary>
        /// Test for SQL returned by the GetSearchSQL function 
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        public void TestGetSearchSQLFunction_2()
        {
            string szExpectedResults = "SELECT TOP " + Utilities.GetConfigValue("CompanyUpdateSearchMaxResults", "2000") + 
                " * FROM (SELECT *, dbo.ufn_GetItem(prcs_CreditSheetID, 2, 1, 34) AS ItemText, " +
                "dbo.ufn_HasNote(9999, 0, comp_CompanyID, 'C') As HasNote FROM PRCreditSheet " +
                "INNER JOIN vPRBBOSCompanyList ON prcs_CompanyId = comp_CompanyID " +
                "WHERE  prcs_CompanyId = @Param0 " +
                "AND prcs_PublishableDate >= @Param1 " +
                "AND prcs_PublishableDate < @Param2) T1";

            CreditSheetSearchCriteria oCriteria = new CreditSheetSearchCriteria();

            IPRWebUser oWebUser = new PRWebUser();
            oWebUser.UserID = "9999";
            oWebUser.prwu_WebUserID = 9999;

            oCriteria.WebUser = oWebUser;
            oCriteria.BBID = 123456;
            oCriteria.FromDate = Convert.ToDateTime("6/15/2007");
            oCriteria.ToDate = Convert.ToDateTime("7/15/2007");

            ArrayList oParameters;

            string szSQL = oCriteria.GetSearchSQL(out oParameters);

            Assert.AreEqual(szExpectedResults.Trim(), szSQL.Trim());
            Assert.AreEqual(3, oParameters.Count);
        }
    }
}
