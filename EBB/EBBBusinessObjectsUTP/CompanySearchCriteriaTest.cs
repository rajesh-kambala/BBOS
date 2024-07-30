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
    /// Provides the NUnit test functionality for the CompanySearchCriteria classes.
    /// </summary>
    [TestFixture]
    public class CompanySearchCriteriaTest : TestBase
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
        /// Accesssor Test for CompanyType property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestCompanyTypeAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.CompanyType = "string";
            Assert.AreEqual("string", oCompanySearchCriteria.CompanyType);
        }

        /// <summary>
        /// Accesssor Test for ListingStatus property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestListingStatusAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.ListingStatus = "string";
            Assert.AreEqual("string", oCompanySearchCriteria.ListingStatus);
        }

        /// <summary>
        /// Accesssor Test for PhoneAreaCode property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestPhoneAreaCodeAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.PhoneAreaCode = "string";
            Assert.AreEqual("string", oCompanySearchCriteria.PhoneAreaCode);
        }

        /// <summary>
        /// Accesssor Test for PhoneNumber property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestPhoneNumberAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.PhoneNumber = "string";
            Assert.AreEqual("string", oCompanySearchCriteria.PhoneNumber);
        }

        /// <summary>
        /// Accesssor Test for FaxAreaCode property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestFaxAreaCodeAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.FaxAreaCode = "string";
            Assert.AreEqual("string", oCompanySearchCriteria.FaxAreaCode);
        }

        /// <summary>
        /// Accesssor Test for FaxNumber property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestFaxNumberAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.FaxNumber = "string";
            Assert.AreEqual("string", oCompanySearchCriteria.FaxNumber);
        }

        /// <summary>
        /// Accesssor Test for FaxNotNull property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestFaxNotNullAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.FaxNotNull = true;
            Assert.AreEqual(true, oCompanySearchCriteria.FaxNotNull);
        }

        /// <summary>
        /// Accesssor Test for Email property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestEmailAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.Email = "string";
            Assert.AreEqual("string", oCompanySearchCriteria.Email);
        }

        /// <summary>
        /// Accesssor Test for EmailNotNull property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestEmailNotNullAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.EmailNotNull = true;
            Assert.AreEqual(true, oCompanySearchCriteria.EmailNotNull);
        }

        /// <summary>
        /// Accesssor Test for NewListingOnly property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestNewListingOnlyAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.NewListingOnly = true;
            Assert.AreEqual(true, oCompanySearchCriteria.NewListingOnly);
        }

        /// <summary>
        /// Accesssor Test for NewListingDaysOld property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestNewListingDaysOldAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.NewListingDaysOld = 5;
            Assert.AreEqual(5, oCompanySearchCriteria.NewListingDaysOld);
        }

        /// <summary>
        /// Accesssor Test for IndustryType property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestIndustryTypeAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.IndustryType = "string";
            Assert.AreEqual("string", oCompanySearchCriteria.IndustryType);
        }

        /// <summary>
        /// Accesssor Test for ListingCountryIDs property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestListingCountryIDsAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.ListingCountryIDs = "string";
            Assert.AreEqual("string", oCompanySearchCriteria.ListingCountryIDs);
        }

        /// <summary>
        /// Accesssor Test for ListingStateIDs property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestListingStateIDsAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.ListingStateIDs = "string";
            Assert.AreEqual("string", oCompanySearchCriteria.ListingStateIDs);
        }

        /// <summary>
        /// Accesssor Test for ListingCity property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestListingCityAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.ListingCity = "string";
            Assert.AreEqual("string", oCompanySearchCriteria.ListingCity);
        }

        /// <summary>
        /// Accesssor Test for ListingPostalCode property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestListingPostalCodeAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.ListingPostalCode = "string";
            Assert.AreEqual("string", oCompanySearchCriteria.ListingPostalCode);
        }

        /// <summary>
        /// Accesssor Test for TerminalMarketIDs property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestTerminalMarketIDsAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.TerminalMarketIDs = "string";
            Assert.AreEqual("string", oCompanySearchCriteria.TerminalMarketIDs);
        }

        /// <summary>
        /// Accesssor Test for Radius property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestRadiusAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.Radius = 5;
            Assert.AreEqual(5, oCompanySearchCriteria.Radius);
        }

        /// <summary>
        /// Accesssor Test for RadiusType property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestRadiusTypeAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.RadiusType = "string";
            Assert.AreEqual("string", oCompanySearchCriteria.RadiusType);
        }

        /// <summary>
        /// Accesssor Test for ClassificationIDs property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestClassificationIDsAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.ClassificationIDs = "string";
            Assert.AreEqual("string", oCompanySearchCriteria.ClassificationIDs);
        }

        /// <summary>
        /// Accesssor Test for ClassificationSearchType property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestClassificationSearchTypeAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.ClassificationSearchType = "string";
            Assert.AreEqual("string", oCompanySearchCriteria.ClassificationSearchType);
        }

        /// <summary>
        /// Accesssor Test for CommodityIDs property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestCommodityIDsAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.CommodityIDs = "string";
            Assert.AreEqual("string", oCompanySearchCriteria.CommodityIDs);
        }

        /// <summary>
        /// Accesssor Test for NumberOfRetailStores property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestNumberOfRetailStoresAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.NumberOfRetailStores = "string";
            Assert.AreEqual("string", oCompanySearchCriteria.NumberOfRetailStores);
        }

        /// <summary>
        /// Accesssor Test for NumberOfRestaurantStores property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestNumberOfRestaurantStoresAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.NumberOfRestaurantStores = "string";
            Assert.AreEqual("string", oCompanySearchCriteria.NumberOfRestaurantStores);
        }

        /// <summary>
        /// Accesssor Test for CommodityGMAttributeID property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestCommodityGMAttributeIDAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.CommodityGMAttributeID = 5;
            Assert.AreEqual(5, oCompanySearchCriteria.CommodityGMAttributeID);
        }

        /// <summary>
        /// Accesssor Test for CommodityAttributeID property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestCommodityAttributeIDAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.CommodityAttributeID = 5;
            Assert.AreEqual(5, oCompanySearchCriteria.CommodityAttributeID);
        }

        /// <summary>
        /// Accesssor Test for CommoditySearchType property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestCommoditySearchTypeAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.CommoditySearchType = "string";
            Assert.AreEqual("string", oCompanySearchCriteria.CommoditySearchType);
        }

        /// <summary>
        /// Accesssor Test for MemberYear property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestMemberYearAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.MemberYear = 5;
            Assert.AreEqual(5, oCompanySearchCriteria.MemberYear);
        }

        /// <summary>
        /// Accesssor Test for MemberYearSearchType property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestMemberYearSearchTypeAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.MemberYearSearchType = "string";
            Assert.AreEqual("string", oCompanySearchCriteria.MemberYearSearchType);
        }

        /// <summary>
        /// Accesssor Test for BBScore property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestBBScoreAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.BBScore = 5;
            Assert.AreEqual(5, oCompanySearchCriteria.BBScore);
        }

        /// <summary>
        /// Accesssor Test for BBScoreSearchType property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestBBScoreSearchTypeAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.BBScoreSearchType = "string";
            Assert.AreEqual("string", oCompanySearchCriteria.BBScoreSearchType);
        }

        /// <summary>
        /// Accesssor Test for RatingCreditWorthIDs property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestRatingCreditWorthIDsAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.RatingCreditWorthIDs = "string";
            Assert.AreEqual("string", oCompanySearchCriteria.RatingCreditWorthIDs);
        }

        /// <summary>
        /// Accesssor Test for RatingIntegrityIDs property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestRatingIntegrityIDsAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.RatingIntegrityIDs = "string";
            Assert.AreEqual("string", oCompanySearchCriteria.RatingIntegrityIDs);
        }

        /// <summary>
        /// Accesssor Test for RatingPayIDs property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestRatingPayIDsAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.RatingPayIDs = "string";
            Assert.AreEqual("string", oCompanySearchCriteria.RatingPayIDs);
        }

        /// <summary>
        /// Accesssor Test for RatingNumeralIDs property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestRatingNumeralIDsAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.RatingNumeralIDs = "string";
            Assert.AreEqual("string", oCompanySearchCriteria.RatingNumeralIDs);
        }

        /// <summary>
        /// Accesssor Test for RatingNumeralSearchType property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestRatingNumeralSearchTypeAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.RatingNumeralSearchType = "string";
            Assert.AreEqual("string", oCompanySearchCriteria.RatingNumeralSearchType);
        }

        /// <summary>
        /// Accesssor Test for LicenseTypes property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestLicenseTypesAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.LicenseTypes = "string";
            Assert.AreEqual("string", oCompanySearchCriteria.LicenseTypes);
        }

        /// <summary>
        /// Accesssor Test for LicenseNumber property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestLicenseNumberAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.LicenseNumber = "string";
            Assert.AreEqual("string", oCompanySearchCriteria.LicenseNumber);
        }

        /// <summary>
        /// Accesssor Test for Brands property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestBrandsAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.Brands = "string";
            Assert.AreEqual("string", oCompanySearchCriteria.Brands);
        }

        /// <summary>
        /// Accesssor Test for CorporateStructure property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestCorporateStructureAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.CorporateStructure = "string";
            Assert.AreEqual("string", oCompanySearchCriteria.CorporateStructure);
        }

        /// <summary>
        /// Accesssor Test for DescriptiveLines property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestDescriptiveLinesAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.DescriptiveLines = "string";
            Assert.AreEqual("string", oCompanySearchCriteria.DescriptiveLines);
        }

        /// <summary>
        /// Accesssor Test for Volume property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestVolumeAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.Volume = "string";
            Assert.AreEqual("string", oCompanySearchCriteria.Volume);
        }

        /// <summary>
        /// Accesssor Test for HasNotes property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestHasNotesAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.HasNotes = true;
            Assert.AreEqual(true, oCompanySearchCriteria.HasNotes);
        }

        /// <summary>
        /// Accesssor Test for IsQuickSearch property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestIsQuickSearchAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.IsQuickSearch = true;
            Assert.AreEqual(true, oCompanySearchCriteria.IsQuickSearch);
        }

        /// <summary>
        /// Accesssor Test for CustomIdentifier property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestCustomIdentifierAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.CustomIdentifier = "string";
            Assert.AreEqual("string", oCompanySearchCriteria.CustomIdentifier);
        }

        /// <summary>
        /// Accesssor Test for CustomIdentifierNotNull property.
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        [Category("Accessor")]
        public void TestCustomIdentifierNotNullAccessors()
        {
            CompanySearchCriteria oCompanySearchCriteria = new CompanySearchCriteria();
            oCompanySearchCriteria.CustomIdentifierNotNull = true;
            Assert.AreEqual(true, oCompanySearchCriteria.CustomIdentifierNotNull);
        }

        /// <summary>
        /// Test for SQL returned by the GetSearchSQL function 
        /// Company Criteria
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        public void TestGetSearchSQLFunction_Company()
        {
            string szExpectedResults = "SELECT Comp_CompanyID FROM Company " +
                "WHERE Comp_CompanyID = @Param0 " +
                "AND Comp_CompanyID IN (SELECT DISTINCT prcse_CompanyId FROM PRCompanySearch WHERE prcse_NameAlphaOnly LIKE @Param1) " +
                "AND comp_PRIndustryType = @Param2 " +
                "AND Comp_PRType = @Param3 " +
                "AND comp_PRListingStatus IN ('L','H') " +
                "AND Comp_CompanyID IN (SELECT DISTINCT Phon_CompanyID FROM Phone WHERE Phon_AreaCode = @Param4 AND Phon_Type = @Param5 AND Phon_PRPublish = @Param6) " +
                "AND Comp_CompanyID IN (SELECT DISTINCT Phon_CompanyID FROM Phone WHERE Phon_Number = @Param7 AND Phon_Type = @Param8 AND Phon_PRPublish = @Param9) " +
                "AND Comp_CompanyID IN (SELECT DISTINCT Phon_CompanyID FROM Phone WHERE Phon_Number IS NOT NULL AND Phon_Type = @Param10 AND Phon_PersonID IS NULL AND Phon_PRPublish = @Param11) " +
                "AND Comp_CompanyID IN (SELECT DISTINCT Emai_CompanyID FROM Email WHERE Emai_EmailAddress LIKE @Param12 AND Emai_Type = @Param13 AND Emai_PRPublish = @Param14) " +
                "AND comp_PRListedDate >= @Param15";

            CompanySearchCriteria oCriteria = new CompanySearchCriteria();

            oCriteria.BBID = 123456;
            oCriteria.CompanyName = "Strube";
            oCriteria.IndustryType = "P";
            oCriteria.CompanyType = "H";
            oCriteria.ListingStatus = "L,H";
            oCriteria.PhoneAreaCode = "708";
            oCriteria.PhoneNumber = "555-6677";
            oCriteria.FaxNotNull = true;
            oCriteria.Email = "test@test.com";
            oCriteria.NewListingOnly = true;
            oCriteria.NewListingDaysOld = 7;
            
            ArrayList oParameters;

            string szSQL = oCriteria.GetSearchSQL(out oParameters);

            Assert.AreEqual(szExpectedResults.Trim(), szSQL.Trim());
            Assert.AreEqual(16, oParameters.Count);
        }

        /// <summary>
        /// Test for SQL returned by the GetSearchSQL function 
        /// Location Criteria
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        public void TestGetSearchSQLFunction_Location()
        {
            string szExpectedResults = "SELECT Comp_CompanyID FROM Company " +
                "WHERE comp_PRIndustryType = @Param0 " +
                "AND comp_PRListingStatus IN ('L','H') " +
                "AND comp_PRListingCityId IN (SELECT DISTINCT prci_CityId FROM vPRLocation WHERE prst_CountryId IN (1) " +
                "AND prst_StateId IN (14,15) AND prci_City LIKE @Param1) " +
                "AND Comp_CompanyID IN (SELECT CompanyID FROM dbo.ufn_GetCompaniesWithinRadius(@ListingPostalCode2, @Radius2))";            

            CompanySearchCriteria oCriteria = new CompanySearchCriteria();

            oCriteria.IndustryType = "P";
            oCriteria.ListingStatus = "L,H";
            oCriteria.ListingCountryIDs = "1";
            oCriteria.ListingStateIDs = "14,15";
            oCriteria.ListingCity = "New Lenox";
            oCriteria.ListingPostalCode = "60451";
            oCriteria.Radius = 10;
            oCriteria.RadiusType = "Listing Postal Code";

            ArrayList oParameters;

            string szSQL = oCriteria.GetSearchSQL(out oParameters);

            Assert.AreEqual(szExpectedResults.Trim(), szSQL.Trim());
            Assert.AreEqual(4, oParameters.Count);
        }

        /// <summary>
        /// Test for SQL returned by the GetSearchSQL function 
        /// Classification Criteria
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        public void TestGetSearchSQLFunction_Classification()
        {
            string szExpectedResults = "SELECT Comp_CompanyID FROM Company WHERE " +
                "Comp_CompanyID IN (SELECT DISTINCT prc2_CompanyId FROM PRCompanyClassification WHERE prc2_ClassificationId IN (300)) " +
                "AND Comp_CompanyID IN (SELECT DISTINCT prc2_CompanyId FROM PRCompanyClassification WHERE prc2_ClassificationId IN (230)) " +
                "AND Comp_CompanyID IN (SELECT prc2_CompanyId FROM PRCompanyClassification GROUP BY prc2_CompanyId HAVING COUNT(*) = 2)";

            CompanySearchCriteria oCriteria = new CompanySearchCriteria();

            oCriteria.ClassificationIDs = "300,230";
            oCriteria.ClassificationSearchType = "Only";

            ArrayList oParameters;

            string szSQL = oCriteria.GetSearchSQL(out oParameters);

            Assert.AreEqual(szExpectedResults.Trim(), szSQL.Trim());
            Assert.AreEqual(0, oParameters.Count);
        }

        /// <summary>
        /// Test for SQL returned by the GetSearchSQL function 
        /// Commodity Criteria
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        public void TestGetSearchSQLFunction_Commodity()
        {
            string szExpectedResults = "SELECT Comp_CompanyID FROM Company " +
                "WHERE Comp_CompanyID IN (SELECT DISTINCT prcca_CompanyId FROM PRCompanyCommodityAttribute " +
                "WHERE prcca_CommodityId IN (245,345,346,347) AND prcca_Publish = @Param0) " +
                "OR Comp_CompanyID IN (SELECT DISTINCT prcca_CompanyId FROM PRCompanyCommodityAttribute WHERE prcca_GrowingMethodId = @Param1) " +
                "OR Comp_CompanyID IN (SELECT DISTINCT prcca_CompanyId FROM PRCompanyCommodityAttribute WHERE prcca_AttributeId = @Param2)";        

            CompanySearchCriteria oCriteria = new CompanySearchCriteria();

            oCriteria.CommodityIDs = "245,345";
            oCriteria.CommoditySearchType = "Any";
            oCriteria.CommodityGMAttributeID = 1;
            oCriteria.CommodityAttributeID = 12;

            ArrayList oParameters;

            string szSQL = oCriteria.GetSearchSQL(out oParameters);

            Assert.AreEqual(szExpectedResults.Trim(), szSQL.Trim());
            Assert.AreEqual(3, oParameters.Count);
        }

        /// <summary>
        /// Test for SQL returned by the GetSearchSQL function 
        /// Rating Criteria
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        public void TestGetSearchSQLFunction_Rating()
        {
            string szExpectedResults = "SELECT Comp_CompanyID " +
                "FROM Company " +
                "WHERE comp_PRTMFMAwardDate > @Param0 " +
                "AND Comp_CompanyID IN (SELECT DISTINCT prbs_CompanyID FROM PRBBScore WHERE prbs_Current = @Param1 AND comp_PRInvestigationMethodGroup = @Param2 AND prbs_BBScore > @Param3) " +
                "AND Comp_CompanyID IN (SELECT DISTINCT prra_CompanyId FROM PRRating WHERE prra_CreditWorthId IN (8,9) AND prra_Current = @Param4) " +
                "AND Comp_CompanyID IN (SELECT DISTINCT prra_CompanyId FROM PRRating WHERE prra_IntegrityId IN (12,13,14) AND prra_Current = @Param5) " +
                "AND Comp_CompanyID IN (SELECT DISTINCT prra_CompanyId FROM PRRating WHERE prra_PayRatingId IN (5,6) AND prra_Current = @Param6)";

            CompanySearchCriteria oCriteria = new CompanySearchCriteria();

            oCriteria.MemberYear = 2000;
            oCriteria.MemberYearSearchType = ">";
            oCriteria.BBScore = 99;
            oCriteria.BBScoreSearchType = ">";
            oCriteria.RatingIntegrityIDs = "12,13,14";
            oCriteria.RatingPayIDs = "5,6";
            oCriteria.RatingCreditWorthIDs = "8,9";
            
            ArrayList oParameters;

            string szSQL = oCriteria.GetSearchSQL(out oParameters);

            Assert.AreEqual(szExpectedResults.Trim(), szSQL.Trim());
            Assert.AreEqual(7, oParameters.Count);
        }

        /// <summary>
        /// Test for SQL returned by the GetSearchSQL function 
        /// Profile Criteria
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        public void TestGetSearchSQLFunction_Profile()
        {
            string szExpectedResults = "SELECT Comp_CompanyID FROM Company " +
                "WHERE  (Comp_CompanyID IN (SELECT DISTINCT prdr_CompanyId FROM PRDRCLicense WHERE prdr_Publish = @Param0) " +
                "OR Comp_CompanyID IN (SELECT DISTINCT prli_CompanyId FROM PRCompanyLicense WHERE prli_Type IN ('CFIA','DOT','DRC') AND prli_Publish = @Param1)) " +
                "AND Comp_CompanyID IN (SELECT DISTINCT prli_CompanyId FROM PRCompanyLicense WHERE prli_Number = @Param2 AND prli_Publish = @Param3) " +
                "AND Comp_CompanyID IN (SELECT DISTINCT prc3_CompanyId FROM PRCompanyBrand WHERE prc3_Brand = @Param4 AND prc3_Publish = @Param5) " +
                "AND Comp_CompanyID IN (SELECT DISTINCT prcp_CompanyId FROM PRCompanyProfile WHERE prcp_CorporateStructure IN ('Coop')) " +
                "AND Comp_CompanyID IN (SELECT DISTINCT prdl_CompanyId FROM PRDescriptiveLine WHERE prdl_LineContent LIKE @Param6) " +
                "AND Comp_CompanyID IN (SELECT DISTINCT prcp_CompanyId FROM PRCompanyProfile WHERE prcp_Volume IN (12,13,14))"; 

            CompanySearchCriteria oCriteria = new CompanySearchCriteria();

            oCriteria.LicenseTypes = "CFIA,DOT,DRC";
            oCriteria.LicenseNumber = "12-34-56";
            oCriteria.Brands = "Gerber";
            oCriteria.CorporateStructure = "Coop";
            oCriteria.DescriptiveLines = "Misc";
            oCriteria.Volume = "12,13,14";

            ArrayList oParameters;

            string szSQL = oCriteria.GetSearchSQL(out oParameters);

            Assert.AreEqual(szExpectedResults.Trim(), szSQL.Trim());
            Assert.AreEqual(7, oParameters.Count);
        }

        /// <summary>
        /// Test for SQL returned by the GetSearchSQL function 
        /// Custom Criteria
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        public void TestGetSearchSQLFunction_Custom()
        {
            string szExpectedResults = "SELECT Comp_CompanyID FROM Company WHERE " +
                "Comp_CompanyID IN (SELECT DISTINCT prwucd_AssociatedID FROM PRWebUserCustomData WHERE prwucd_Value LIKE @Param0 AND " +
                "prwucd_LabelCode = @Param1)";

            CompanySearchCriteria oCriteria = new CompanySearchCriteria();

            IPRWebUser oWebUser = new PRWebUser();
            oWebUser.UserID = "9999";
            oWebUser.prwu_WebUserID = 9999;

            oCriteria.WebUser = oWebUser;
            oCriteria.CustomIdentifier = "BandB";

            ArrayList oParameters;

            string szSQL = oCriteria.GetSearchSQL(out oParameters);

            Assert.AreEqual(szExpectedResults.Trim(), szSQL.Trim());
            Assert.AreEqual(3, oParameters.Count);
        }

        /// <summary>
        /// Test for SQL returned by the GetSearchSQL function 
        /// Quick Search Criteria
        /// </summary>
        [Test]
        [Category("NoDatabaseAccess")]
        public void TestGetSearchSQLFunction_QuickSearch()
        {
            string szExpectedResults = "SELECT Comp_CompanyID FROM Company " +
                "WHERE Comp_CompanyID IN (SELECT DISTINCT prcse_CompanyId FROM PRCompanySearch WHERE prcse_NameAlphaOnly LIKE @Param0)";
  
            CompanySearchCriteria oCriteria = new CompanySearchCriteria();

            oCriteria.IsQuickSearch = true;
            oCriteria.CompanyName = "Strube";

            ArrayList oParameters;

            string szSQL = oCriteria.GetSearchSQL(out oParameters);

            Assert.AreEqual(szExpectedResults.Trim(), szSQL.Trim());
            Assert.AreEqual(1, oParameters.Count);
        }
    }
}
