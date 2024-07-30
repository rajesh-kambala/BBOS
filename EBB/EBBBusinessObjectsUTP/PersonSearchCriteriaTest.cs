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

 ClassName: PersonSearchCriteriaTest
 Description:	

 Notes:	Created By Sharon Cole on 07/24/2007

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
    /// Provides the NUnit test functionality for the PersonSearchCriteria classes.
    /// </summary>
    [TestFixture]
    public class PersonSearchCriteriaTest : TestBase
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
        /// Accesssor Test for FirstName property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestFirstNameAccessors()
        {
            PersonSearchCriteria oPersonSearchCriteria = new PersonSearchCriteria();            
            oPersonSearchCriteria.FirstName = "string";
            Assert.AreEqual("string", oPersonSearchCriteria.FirstName);
        }

        /// <summary>
        /// Accesssor Test for LastName property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestLastNameAccessors()
        {
            PersonSearchCriteria oPersonSearchCriteria = new PersonSearchCriteria();
            oPersonSearchCriteria.LastName = "string";
            Assert.AreEqual("string", oPersonSearchCriteria.LastName);
        }

        /// <summary>
        /// Accesssor Test for Title property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestTitleAccessors()
        {
            PersonSearchCriteria oPersonSearchCriteria = new PersonSearchCriteria();
            oPersonSearchCriteria.Title = "string";
            Assert.AreEqual("string", oPersonSearchCriteria.Title);
        }

        /// <summary>
        /// Accesssor Test for PhoneAreaCode property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestPhoneAreaCodeAccessors()
        {
            PersonSearchCriteria oPersonSearchCriteria = new PersonSearchCriteria();
            oPersonSearchCriteria.PhoneAreaCode = "string";
            Assert.AreEqual("string", oPersonSearchCriteria.PhoneAreaCode);
        }

        /// <summary>
        /// Accesssor Test for PhoneNumber property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestPhoneNumberAccessors()
        {
            PersonSearchCriteria oPersonSearchCriteria = new PersonSearchCriteria();
            oPersonSearchCriteria.PhoneNumber = "string";
            Assert.AreEqual("string", oPersonSearchCriteria.PhoneNumber);
        }

        /// <summary>
        /// Accesssor Test for Email property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestEmailAccessors()
        {
            PersonSearchCriteria oPersonSearchCriteria = new PersonSearchCriteria();
            oPersonSearchCriteria.Email = "string";
            Assert.AreEqual("string", oPersonSearchCriteria.Email);
        }

        /// <summary>
        /// Test for SQL returned by the GetSearchSQL function 
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        public void TestGetSearchSQLFunction()
        {
            string szExpectedResults = "SELECT TOP " + Utilities.GetConfigValue("PersonSearchMaxResults", "2000") + 
                " * FROM (SELECT DISTINCT Pers_FirstName AS FirstName, Pers_LastName AS LastName, " +
                "'Person' AS SourceTable, Pers_PersonId AS PersonId, " +
                "dbo.ufn_FormatPerson(Pers_FirstName, Pers_LastName, Pers_MiddleName, Pers_PRNickname1, Pers_Suffix) As PersonName " +
                "FROM Person INNER JOIN Person_Link ON Pers_PersonId = PeLi_PersonId " +
                "INNER JOIN vPRBBOSCompanyList ON PeLi_CompanyId = Comp_CompanyID " +
                "WHERE PeLi_CompanyId = @Param0 AND Pers_FirstName LIKE @Param1 AND Pers_LastName LIKE @Param3 " +
                "AND peli_PRTitle LIKE @Param5 AND Pers_PersonId IN (SELECT DISTINCT Emai_PersonID FROM Email " +
                "WHERE Emai_EmailAddress LIKE @Param7 AND Emai_Type = @Param8 AND Emai_PersonID IS NOT NULL) " +
                "AND peli_PRStatus = @Param10 AND peli_PREBBPublish = @Param11 " +
                "UNION ALL SELECT prwuc_FirstName AS FirstName, prwuc_LastName AS LastName, " +
                "'PRWebUserContact' AS SourceTable, prwuc_WebUserID AS PersonId, " +
                "dbo.ufn_FormatPerson(prwuc_FirstName, prwuc_LastName, prwuc_MiddleName, null, prwuc_Suffix) As PersonName " +
                "FROM PRWebUserContact INNER JOIN vPRBBOSCompanyList ON prwuc_CompanyId = Comp_CompanyID " +
                "WHERE prwuc_CompanyId = @Param0 AND prwuc_FirstName LIKE @Param2 AND prwuc_LastName LIKE @Param4 " +
                "AND prwuc_Title LIKE @Param6 AND prwuc_Email LIKE @Param9 " +
                "AND  ((prwuc_WebUserID = @Param12) OR (prwuc_HQID = @Param13 AND prwuc_IsPrivate IS NULL))) T1";

            PersonSearchCriteria oCriteria = new PersonSearchCriteria();

            IPRWebUser oWebUser = new PRWebUser();
            oWebUser.UserID = "9999";
            oWebUser.prwu_WebUserID = 9999;

            oCriteria.WebUser = oWebUser;
            
            oCriteria.BBID = 123456;
            oCriteria.LastName = "Doe";
            oCriteria.FirstName = "Jane";
            oCriteria.Title = "President";
            oCriteria.Email = "test@test.com";

            ArrayList oParameters;

            string szSQL = oCriteria.GetSearchSQL(out oParameters);

            Assert.AreEqual(szExpectedResults.Trim(), szSQL.Trim());
            Assert.AreEqual(14, oParameters.Count);
        }

        /// <summary>
        /// Test for SQL returned by the GetSearchSQL function 
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        public void TestGetSearchSQLFunction_2()
        {
            string szExpectedResults = "SELECT TOP " + Utilities.GetConfigValue("PersonSearchMaxResults", "2000") + 
                " * FROM (SELECT DISTINCT Pers_FirstName AS FirstName, Pers_LastName AS LastName, " +
                "'Person' AS SourceTable, Pers_PersonId AS PersonId, " +
                "dbo.ufn_FormatPerson(Pers_FirstName, Pers_LastName, Pers_MiddleName, Pers_PRNickname1, Pers_Suffix) As PersonName " +
                "FROM Person INNER JOIN Person_Link ON Pers_PersonId = PeLi_PersonId " +
                "INNER JOIN vPRBBOSCompanyList ON PeLi_CompanyId = Comp_CompanyID " +
                "WHERE PeLi_CompanyId IN (SELECT DISTINCT prcse_CompanyId FROM PRCompanySearch " +
                "WHERE prcse_NameAlphaOnly LIKE @Param0) AND Pers_PhoneAreaCode = @Param1 " +
                "AND Pers_PhoneNumber = @Param3 AND peli_PRStatus = @Param5 AND peli_PREBBPublish = @Param6 " +
                "UNION ALL SELECT prwuc_FirstName AS FirstName, prwuc_LastName AS LastName, " +
                "'PRWebUserContact' AS SourceTable, prwuc_WebUserID AS PersonId, " +
                "dbo.ufn_FormatPerson(prwuc_FirstName, prwuc_LastName, prwuc_MiddleName, null, prwuc_Suffix) As PersonName " +
                "FROM PRWebUserContact INNER JOIN vPRBBOSCompanyList ON prwuc_CompanyId = Comp_CompanyID " +
                "WHERE prwuc_CompanyId IN (SELECT DISTINCT prcse_CompanyId FROM PRCompanySearch " +
                "WHERE prcse_NameAlphaOnly LIKE @Param0) AND prwuc_PhoneAreaCode = @Param2 " +
                "AND prwuc_PhoneNumber = @Param4 " +
                "AND  ((prwuc_WebUserID = @Param7) OR (prwuc_HQID = @Param8 AND prwuc_IsPrivate IS NULL))) T1";

            PersonSearchCriteria oCriteria = new PersonSearchCriteria();

            IPRWebUser oWebUser = new PRWebUser();
            oWebUser.UserID = "9999";
            oWebUser.prwu_WebUserID = 9999;

            oCriteria.WebUser = oWebUser;
            
            oCriteria.CompanyName = "Strube";
            oCriteria.PhoneAreaCode = "708";
            oCriteria.PhoneNumber = "444-5555";

            ArrayList oParameters;

            string szSQL = oCriteria.GetSearchSQL(out oParameters);

            Assert.AreEqual(szExpectedResults.Trim(), szSQL.Trim());
            Assert.AreEqual(9, oParameters.Count);
        }
    }
}
