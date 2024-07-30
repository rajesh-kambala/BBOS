using System;
using System.Collections;
using PRCo.EBB.Util;

namespace PRCo.EBB.BusinessObjects
{
	/// <summary>
	/// Used as a temporary driver for the NUnit tests when
	/// debugging individual test cases.
	/// </summary>
	class Driver  
	{  
		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		[STAThread]
		static void Main(string[] args)
        {
            try
            {
                #region PRWebUserSearchCriteriaTest
                System.Console.WriteLine("BEGIN: PRWebUserSearchCriteriaTest");
                PRWebUserSearchCriteriaTest oWebUserSearchCriteriaTest = new PRWebUserSearchCriteriaTest();

                oWebUserSearchCriteriaTest.Init();
                oWebUserSearchCriteriaTest.TestAuditFields();
                oWebUserSearchCriteriaTest.TestDataPersistence();

                try
                {
                    oWebUserSearchCriteriaTest.TestDelete();
                }
                catch (Exception ex) { }
                oWebUserSearchCriteriaTest.TestObjectExists();
                oWebUserSearchCriteriaTest.TestSaveNew();
                oWebUserSearchCriteriaTest.TestSaveUpdate();
                oWebUserSearchCriteriaTest.TestFieldColMapping();
                oWebUserSearchCriteriaTest.Testprsc_SearchCriteriaIDAccessors();
                oWebUserSearchCriteriaTest.Cleanup();

                System.Console.WriteLine("Success - PRWebUserSearchCriteriaTest");
                #endregion

                #region PersonSearchCriteriaTest
                System.Console.WriteLine("BEGIN: PersonSearchCriteriaTest");
                PersonSearchCriteriaTest oPersonSearchCriteriaTest = new PersonSearchCriteriaTest();

                oPersonSearchCriteriaTest.TestGetSearchSQLFunction();
                oPersonSearchCriteriaTest.TestGetSearchSQLFunction_2();

                System.Console.WriteLine("Success - PersonSearchCriteriaTest");
                #endregion

                #region CreditSheetSearchCriteriaTest
                System.Console.WriteLine("BEGIN: CreditSheetSearchCriteriaTest");
                CreditSheetSearchCriteriaTest oCreditSheetSearchTest = new CreditSheetSearchCriteriaTest();

                oCreditSheetSearchTest.TestGetSearchSQLFunction();
                oCreditSheetSearchTest.TestGetSearchSQLFunction_2();

                System.Console.WriteLine("Success - CreditSheetSearchCriteriaTest");
                #endregion

                #region CompanySearchCriteriaTest
                System.Console.WriteLine("BEGIN: CompanySearchCriteriaTest");
                CompanySearchCriteriaTest oCompanyTest = new CompanySearchCriteriaTest();

                oCompanyTest.TestGetSearchSQLFunction_Company();
                oCompanyTest.TestGetSearchSQLFunction_Location();
                oCompanyTest.TestGetSearchSQLFunction_Classification();
                oCompanyTest.TestGetSearchSQLFunction_Commodity();
                oCompanyTest.TestGetSearchSQLFunction_Rating();
                oCompanyTest.TestGetSearchSQLFunction_Profile();
                oCompanyTest.TestGetSearchSQLFunction_Custom();
                oCompanyTest.TestGetSearchSQLFunction_QuickSearch();

                System.Console.WriteLine("Success - CompanySearchCriteriaTest");
                #endregion

                //PRWebUserTest oTest = new PRWebUserTest();
                //oTest.Init();
                //oTest.TestSetup();
                //oTest.TestFieldColMapping();
                //oTest.Cleanup();

                #region CompanySubmissionTest
                System.Console.WriteLine("BEGIN: CompanySubmissionTest");                
                CompanySubmissionUTP oTest = new CompanySubmissionUTP();

                oTest.TestSerialization01();

                System.Console.WriteLine("Success - CompanySubmissionTest");                
                #endregion

                #region PRWebUserTest
                System.Console.WriteLine("BEGIN: PRWebUserTest");
                PRWebUserTest oWebUserTest = new PRWebUserTest();

                oWebUserTest.Init();
                oWebUserTest.TestAuditFields();
                oWebUserTest.TestDataPersistence();

                try
                {
                    oWebUserTest.TestDelete();
                }
                catch (Exception ex) { }
                oWebUserTest.TestObjectExists();
                oWebUserTest.TestSaveNew();
                oWebUserTest.TestSaveUpdate();
                oWebUserTest.TestFieldColMapping();
                oWebUserTest.TestFirstNameAccessors();
                oWebUserTest.Cleanup();

                System.Console.WriteLine("Success - PRWebUserTest");
                #endregion
            }
            catch (Exception ex)
            {
                System.Console.WriteLine("Failure - " + ex.Message);
            }

            System.Console.ReadKey();
		}  
	}
}
