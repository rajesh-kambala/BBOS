using System;
using System.Configuration;
using System.Collections.Generic;
using System.Collections;
using System.Linq;
using System.Text;
using System.IO;
using System.Data;
using System.Data.OleDb;
using System.Data.SqlClient;
//using CommandLine.Utility;
using System.Data.Common;
using System.Text.RegularExpressions;

namespace NHLAImport
{
    class Importer
    {
        int _companiesCounter, _companiesImportedCounter;
        int _sectionOneCompaniesInserted;
        int _sectionTwoCompaniesInserted;
        int _sectionThreeCompaniesInserted;
        List<DataIssue> _dataIssues = new List<DataIssue>();

        protected SqlConnection _dbConn = null;
        DateTime _startTime;

        private const string SQL_SCAN_EXCEL_SECTION_ONE =
            "SELECT NHLA_COMPANY, NHLA_ADDRESS_PRIMARY, NHLA_ADDRESS_SECONDARY, " +
            "NHLA_CITY, NHLA_STATE, NHLA_ZIPCODE, NHLA_COUNTRY, NHLA_PHONE, NHLA_FAX, " +
            "NHLA_WEB, NHLA_EMAIL, OKS_SEQUENCE_ID, OKS_BATCH_ID, " +
            "NHLA_IMPORTS_FROM_1, NHLA_IMPORTS_FROM_2, NHLA_IMPORTS_FROM_3, NHLA_IMPORTS_FROM_4, NHLA_IMPORTS_FROM_5, " +
            "NHLA_IMPORTS_FROM_6, NHLA_IMPORTS_FROM_7, NHLA_IMPORTS_FROM_8, NHLA_IMPORTS_FROM_9, NHLA_IMPORTS_FROM_10, " +
            "NHLA_EXPORTS_TO_1, NHLA_EXPORTS_TO_2, NHLA_EXPORTS_TO_3, NHLA_EXPORTS_TO_4, NHLA_EXPORTS_TO_5, " +
            "NHLA_EXPORTS_TO_6, NHLA_EXPORTS_TO_7, NHLA_EXPORTS_TO_8, NHLA_EXPORTS_TO_9, NHLA_EXPORTS_TO_10, NHLA_EXPORTS_TO_11, NHLA_EXPORTS_TO_12, " +
            "NHLA_BUS_TYPE_1, NHLA_BUS_TYPE_2, NHLA_BUS_TYPE_3, NHLA_BUS_TYPE_4, NHLA_BUS_TYPE_5, " +
            "NHLA_BUS_TYPE_6, NHLA_BUS_TYPE_7, NHLA_BUS_TYPE_8, NHLA_BUS_TYPE_9, NHLA_BUS_TYPE_10, " +
            "NHLA_IMPORTER, NHLA_EXPORTER, NHLA_SALES_CONTACT_1, NHLA_SALES_CONTACT_2, NHLA_SALES_CONTACT_3, NHLA_SALES_CONTACT_4, NHLA_SALES_CONTACT_5, " +
            "[NHLA_EXP_SALES_CONTACT 1], [NHLA_EXP_SALES_CONTACT 2], [NHLA_EXP_SALES_CONTACT 3], [NHLA_EXP_SALES_CONTACT 4], [NHLA_EXP_SALES_CONTACT 5], " +
            "[NHLA Lumber Type Green], [NHLA Lumber Type Air Dried], [NHLA Lumber Type Kiln Dried], [NHLA Lumber Type Rough], [NHLA Lumber Type Surfaced], " +
            "[NHLA Lumber Type Quarter Sewn], [NHLA Lumber Type Non-Specified], [NHLA Product Cabinets], [NHLA Product Crossties], [NHLA Product Dimension/Stock Comp], " +
            "[NHLA Product Doors], [NHLA Product Flooring Interior], [NHLA Product Flooring Truck], [NHLA Product Furniture], [NHLA Product Furniture Parts], " +
            "[NHLA Product Moulding/Millwork], [NHLA Product Pallet Cants/Lumber], [NHLA Product Pallet Cants/Lumber HT], [NHLA Product Pallets], [NHLA Product Pallets HT], " +
            "[NHLA Product Paneling], [NHLA Product Panels – Glued Up], [NHLA Product Plywood], [NHLA Product Timbers], [NHLA Product Turnings], " +
            "NHLA_HT_AUDITED, NHLA_GRADE_CERTIFIED, NHLA_SFI_CERTIFIED, NHLA_SFI_PART, NHLA_FSC_CERTIFIED, NHLA_OTHER_CERTIFICATION, NHLA_MEMBERSHIP_TYPE " +
            "FROM [Section 1$]";

        private const string SQL_SCAN_EXCEL_SECTION_TWO =
            "SELECT NHLA_COMPANY, NHLA_ADDRESS_PRIMARY, NHLA_ADDRESS_SECONDARY, " +
            "NHLA_CITY, NHLA_STATE, NHLA_ZIPCODE, NHLA_COUNTRY, NHLA_PHONE, NHLA_FAX, " +
            "NHLA_WEB, NHLA_EMAIL, OKS_SEQUENCE_ID, OKS_BATCH_ID, " +
            "NHLA_IMPORTS_FROM_1, NHLA_IMPORTS_FROM_2, NHLA_IMPORTS_FROM_3, NHLA_IMPORTS_FROM_4, NHLA_IMPORTS_FROM_5, " +
            "NHLA_IMPORTS_FROM_6, NHLA_IMPORTS_FROM_7, NHLA_IMPORTS_FROM_8, NHLA_IMPORTS_FROM_9, NHLA_IMPORTS_FROM_10, " +
            "NHLA_EXPORTS_TO_1, NHLA_EXPORTS_TO_2, NHLA_EXPORTS_TO_3, NHLA_EXPORTS_TO_4, NHLA_EXPORTS_TO_5, " +
            "NHLA_EXPORTS_TO_6, NHLA_EXPORTS_TO_7, NHLA_EXPORTS_TO_8, NHLA_EXPORTS_TO_9, NHLA_EXPORTS_TO_10, NHLA_EXPORTS_TO_11, " +
            "NHLA_BUS_TYPE_1, NHLA_BUS_TYPE_2, NHLA_BUS_TYPE_3, NHLA_BUS_TYPE_4, NHLA_BUS_TYPE_5, " +
            "NHLA_BUS_TYPE_6, NHLA_BUS_TYPE_7, NHLA_BUS_TYPE_8, NHLA_BUS_TYPE_9, NHLA_BUS_TYPE_10, " +
            "NHLA_IMPORTER, NHLA_EXPORTER, NHLA_SALES_CONTACT_1, NHLA_SALES_CONTACT_2, NHLA_SALES_CONTACT_3, NHLA_SALES_CONTACT_4, NHLA_SALES_CONTACT_5, " +
            "[NHLA_EXP_SALES_CONTACT 1], [NHLA_EXP_SALES_CONTACT 2], [NHLA_EXP_SALES_CONTACT 3], [NHLA_EXP_SALES_CONTACT 4], [NHLA_EXP_SALES_CONTACT 5], " +
            "NHLA_HT_AUDITED, NHLA_GRADE_CERTIFIED, NHLA_SFI_CERTIFIED, NHLA_SFI_PART, NHLA_FSC_CERTIFIED, NHLA_OTHER_CERTIFICATION, NHLA_MEMBERSHIP_TYPE " +
            "FROM [Section 2$]";

        private const string SQL_SCAN_EXCEL_SECTION_THREE =
            "SELECT NHLA_COMPANY, NHLA_ADDRESS_PRIMARY, NHLA_ADDRESS_SECONDARY, " +
            "NHLA_CITY, NHLA_STATE, NHLA_ZIPCODE, NHLA_COUNTRY, NHLA_PHONE, NHLA_FAX, " +
            "NHLA_WEB, NHLA_EMAIL, OKS_SEQUENCE_ID, OKS_BATCH_ID, " +
            "NHLA_IMPORTS_FROM_1, NHLA_IMPORTS_FROM_2, NHLA_IMPORTS_FROM_3, NHLA_IMPORTS_FROM_4, NHLA_IMPORTS_FROM_5, " +
            "NHLA_IMPORTS_FROM_6, NHLA_IMPORTS_FROM_7, NHLA_IMPORTS_FROM_8, NHLA_IMPORTS_FROM_9, NHLA_IMPORTS_FROM_10, " +
            "NHLA_EXPORTS_TO_1, NHLA_EXPORTS_TO_2, NHLA_EXPORTS_TO_3, NHLA_EXPORTS_TO_4, NHLA_EXPORTS_TO_5, " +
            "NHLA_EXPORTS_TO_6, NHLA_EXPORTS_TO_7, NHLA_EXPORTS_TO_8, NHLA_EXPORTS_TO_9, NHLA_EXPORTS_TO_10, NHLA_EXPORTS_TO_11, " +
            "NHLA_BUS_TYPE_1, NHLA_BUS_TYPE_2, NHLA_BUS_TYPE_3, NHLA_BUS_TYPE_4, NHLA_BUS_TYPE_5, " +
            "NHLA_BUS_TYPE_6, NHLA_BUS_TYPE_7, NHLA_BUS_TYPE_8, NHLA_BUS_TYPE_9, NHLA_BUS_TYPE_10, " +
            "NHLA_IMPORTER, NHLA_EXPORTER, NHLA_SALES_CONTACT_1, NHLA_SALES_CONTACT_2, NHLA_SALES_CONTACT_3, NHLA_SALES_CONTACT_4, NHLA_SALES_CONTACT_5, " +
            "[NHLA_EXP_SALES_CONTACT 1], [NHLA_EXP_SALES_CONTACT 2], [NHLA_EXP_SALES_CONTACT 3], [NHLA_EXP_SALES_CONTACT 4], [NHLA_EXP_SALES_CONTACT 5], " +
            "NHLA_HT_AUDITED, NHLA_GRADE_CERTIFIED, NHLA_SFI_CERTIFIED, NHLA_SFI_PART, NHLA_FSC_CERTIFIED, NHLA_OTHER_CERTIFICATION, NHLA_MEMBERSHIP_TYPE " +
            "FROM [Section 3$]";

        private const string SQL_IS_CITY_EXIST = "SELECT prci_CityID FROM vPRLocation WHERE dbo.ufn_GetLowerAlpha(prci_City) = dbo.ufn_GetLowerAlpha(@City) AND prst_Abbreviation = @State;";

        protected const string SQL_COMPANY_INSERT =
            "INSERT INTO Company (comp_CompanyID, comp_PRHQID, comp_Name, comp_PRTradestyle1, comp_PRCorrTradestyle, comp_PRBookTradestyle, comp_PRLegalName, comp_PRType, comp_PRListingStatus, comp_PRListingCityID, comp_PRIndustryType, comp_Source, comp_PRLastPublishedCSDate, comp_PRMethodSourceReceived, comp_CreatedBy, comp_CreatedDate, comp_UpdatedBy, comp_UpdatedDate, comp_Timestamp) " +
                         "VALUES (@comp_CompanyID, @comp_CompanyID, @comp_Name, @comp_Name, @comp_Name, @comp_Name, @comp_PRLegalName, @comp_PRType, @comp_PRListingStatus, @comp_PRListingCityID, @comp_PRIndustryType, @comp_Source, @comp_PRLastPublishedCSDate, @comp_PRMethodSourceReceived, @CreatedBy, @CreatedDate, @UpdatedBy, @UpdatedDate, @Timestamp)";


        private const string SQL_ADDRESS_INSERT = "INSERT INTO Address (Addr_AddressId, Addr_Address1, Addr_Address2, Addr_PostCode, addr_PRCityId, addr_PRPublish, Addr_CreatedBy, Addr_CreatedDate, Addr_UpdatedBy, Addr_UpdatedDate, Addr_TimeStamp) VALUES (@AddressId, @Address1, @Address2, @PostCode, @PRCityId, @PRPublish, @CreatedBy, @CreatedDate, @UpdatedBy, @UpdatedDate, @TimeStamp)";
        
        private const string SQL_ADDRESSLINK_INSERT = "INSERT INTO Address_Link (AdLi_AddressLinkId, AdLi_AddressId, AdLi_CompanyID, AdLi_Type, adli_PRDefaultTax, adli_PRDefaultMailing, adLi_CreatedBy, AdLi_CreatedDate, AdLi_UpdatedBy, AdLi_UpdatedDate, AdLi_TimeStamp) VALUES (@AddressLinkId, @AddressId, @CompanyID, @Type, @PRDefaultTax, @PRDefaultMailing, @CreatedBy, @CreatedDate, @UpdatedBy, @UpdatedDate, @TimeStamp)";

        private const string SQL_PHONE_INSERT = "INSERT INTO Phone (phon_PhoneID, phon_CompanyID, phon_Type, phon_PRDescription, Phon_AreaCode, Phon_Number, Phon_CountryCode, phon_PRPublish, phon_Default, Phon_CreatedBy, Phon_CreatedDate, Phon_UpdatedBy, Phon_UpdatedDate, Phon_Timestamp) " +
                                                           "VALUES (@PhoneID, @CompanyID, @Type, @Description, @AreaCode, @Number, @CountryCode, @PRPublish, @Default, @UpdatedBy, @UpdatedDate, @UpdatedBy, @UpdatedDate, @Timestamp)";

        private const string SQL_INTERNET_INSERT = "INSERT INTO Email (Emai_EmailId, Emai_CompanyID, Emai_Type, Emai_PRDescription, Emai_EmailAddress, emai_PRWebAddress, Emai_PRPublish, Emai_PRDefault, Emai_CreatedBy, Emai_CreatedDate, Emai_UpdatedBy, Emai_UpdatedDate, Emai_Timestamp) " +
                                                   "VALUES (@InternetID, @CompanyID, @Type, @Description, @Email, @WebAddress, @PRPublish, @Default, @UpdatedBy, @UpdatedDate, @UpdatedBy, @UpdatedDate, @Timestamp)";

        private const string SQL_PRCOMPANY_CLASSIFICATION_INSERT =
            "INSERT INTO PRCompanyClassification (prc2_CompanyClassificationId, prc2_CompanyId, prc2_ClassificationId, prc2_CreatedBy, prc2_CreatedDate, prc2_UpdatedBy, prc2_UpdatedDate, prc2_Timestamp) " +
            "VALUES (@CompanyClassificationId, @CompanyId, @ClassificationId, @UpdatedBy, @UpdatedDate, @UpdatedBy, @UpdatedDate, @Timestamp)";

        private const string SQL_PRCOMPANY_PRODUCT_PROVIDED_INSERT =
            "INSERT INTO PRCompanyProductProvided (prcprpr_CompanyProductProvidedID, prcprpr_CompanyId, prcprpr_ProductProvidedID, prcprpr_CreatedBy, prcprpr_CreatedDate, prcprpr_UpdatedBy, prcprpr_UpdatedDate, prcprpr_Timestamp) " +
            "VALUES (@CompanyProductProvidedID, @CompanyId, @ProductProvidedID, @UpdatedBy, @UpdatedDate, @UpdatedBy, @UpdatedDate, @Timestamp)";

        private const string SQL_PRCOMPANY_REGION_INSERT =
            "INSERT INTO PRCompanyRegion (prcd_CompanyRegionId, prcd_CompanyId, prcd_RegionID, prcd_Type, prcd_CreatedBy, prcd_CreatedDate, prcd_UpdatedBy, prcd_UpdatedDate, prcd_Timestamp) " +
            "VALUES (@CompanyRegionID, @CompanyId, @RegionID, @Type, @UpdatedBy, @UpdatedDate, @UpdatedBy, @UpdatedDate, @Timestamp)";

        private const string SQL_PRCOMPANYSPECIE_INSERT = "INSERT INTO PRCompanySpecie (prcspc_CompanySpecieID, prcspc_CompanyID, prcspc_SpecieID, prcspc_CreatedBy, prcspc_CreatedDate, prcspc_UpdatedBy, prcspc_UpdatedDate, prcspc_Timestamp) " +
           "VALUES (@CompanySpecieID, @CompanyID, @SpecieID, @UpdatedBy, @UpdatedDate, @UpdatedBy, @UpdatedDate, @Timestamp)";

        
        private SqlCommand cmdInsertCompany = null;

        protected const int UPDATED_BY = -55;
        protected DateTime UPDATED_DATE = DateTime.Now;

        public Importer()
        {
            _startTime = DateTime.Now;

            try
            {
                ConsoleWriter.InitializeConsole();
                TextLogWriter.InitializeGeneralLog(_startTime);
                TextLogWriter.InitializeCompaniesInsertedLog(_startTime);

                ImportData();

                DateTime endTime = DateTime.Now;

                //These are data issues that do not stop execution.
                if (_dataIssues.Count > 0)
                {
                    TextLogWriter.WriteDataIssues(_dataIssues);
                    ConsoleWriter.WriteDataIssues(_dataIssues);
                }

                TextLogWriter.FinalizeGeneralLog(_startTime, endTime);
                ConsoleWriter.FinalizeConsole(_startTime, endTime);
            }
            catch (Exception e)
            {
                TextLogWriter.WriteException(e);
                ConsoleWriter.WriteException(e);
                return;
            }
        }

        protected void ImportData()
        {
            string filePath = ConfigurationManager.AppSettings["InputDataFile"].ToString();
            string msExcelConn = String.Format(ConfigurationManager.AppSettings["msExcelConn"].ToString(), filePath);
            _dbConn = new SqlConnection(ConfigurationManager.ConnectionStrings["CRM"].ConnectionString);
            _dbConn.Open();

            try
            {

                DbProviderFactory factory = DbProviderFactories.GetFactory("System.Data.OleDb");

                using (DbConnection connection = factory.CreateConnection())
                {
                    connection.ConnectionString = msExcelConn;
                    connection.Open();

                    ConsoleWriter.WriteCompanyScannedText();

                    if(ScanSectionOne(connection))
                        if(ScanSectionTwo(connection))
                            ScanSectionThree(connection);

                    connection.Close(); 

                    ConsoleWriter.WriteTotalAnalysis(_companiesImportedCounter);
                    TextLogWriter.WriteSectionData("Total Analysis", _companiesCounter, _companiesImportedCounter);
                }
            }
            finally
            {
                _dbConn.Close();
            }
        }

        protected bool ScanSectionOne(DbConnection connection)
        {
            using (DbCommand command = connection.CreateCommand())
            {
                command.CommandText = String.Format(SQL_SCAN_EXCEL_SECTION_ONE, "[Section 1$]");

                using (DbDataReader dr = command.ExecuteReader())
                {
                    ConsoleWriter.WriteExecutionStatus("Scanning Section One...   ");

                    int i = 0;

                    while (dr.Read())
                    {
                        Company company = CreateCompany(dr, 1);

                        if (!string.IsNullOrEmpty(company.NHLACompany))
                        {
                            i++;
                            _companiesCounter++;

                            ConsoleWriter.WriteCurrentCompanyScanned(_companiesCounter);

                            if (InsertData(company))
                            {
                                _companiesImportedCounter++;
                                _sectionOneCompaniesInserted++;
                                TextLogWriter.WriteInsertedCompanyLog(_startTime, company.NHLACompany, company.CRMCompanyID, company.OksSequenceID, company.Section);
                            }
                            else
                            {
                                //Signal the caller to stop execution of the program.
                                return false;
                            }
                        }
                    }

                    ConsoleWriter.WriteSectionData("Section One Analysis", i, _sectionOneCompaniesInserted);
                    TextLogWriter.WriteSectionData("Section One Analysis", i, _sectionOneCompaniesInserted);
                    return true;
                }
            }
        }

        protected bool ScanSectionTwo(DbConnection connection)
        {
            using (DbCommand command = connection.CreateCommand())
            {
                command.CommandText = String.Format(SQL_SCAN_EXCEL_SECTION_TWO, "[Section 2$]");

                using (DbDataReader dr = command.ExecuteReader())
                {
                    ConsoleWriter.WriteExecutionStatus("Scanning Section Two...   ");

                    int i = 0;

                    while (dr.Read())
                    {
                        Company company = CreateCompany(dr, 2);                       

                        if (!string.IsNullOrEmpty(company.NHLACompany))
                        {
                            i++;
                            _companiesCounter++;

                            ConsoleWriter.WriteCurrentCompanyScanned(_companiesCounter);

                            if (InsertData(company))
                            {
                                _companiesImportedCounter++;
                                _sectionTwoCompaniesInserted++;
                                TextLogWriter.WriteInsertedCompanyLog(_startTime, company.NHLACompany, company.CRMCompanyID, company.OksSequenceID, company.Section);
                            }
                            else
                            {
                                //Signal the caller to stop execution of the program.
                                return false;
                            }

                        }
                    }

                    ConsoleWriter.WriteSectionData("Section Two Analysis", i, _sectionTwoCompaniesInserted);
                    TextLogWriter.WriteSectionData("Section Two Analysis", i, _sectionTwoCompaniesInserted);
                    return true;
                }
            }
        }

        protected bool ScanSectionThree(DbConnection connection)
        {
            using (DbCommand command = connection.CreateCommand())
            {
                command.CommandText = String.Format(SQL_SCAN_EXCEL_SECTION_THREE, "[Section 3$]");

                using (DbDataReader dr = command.ExecuteReader())
                {
                    ConsoleWriter.WriteExecutionStatus("Scanning Section Three...   ");

                    int i = 0;

                    while (dr.Read())
                    {
                        Company company = CreateCompany(dr, 3);

                        if (!string.IsNullOrEmpty(company.NHLACompany))
                        {
                            i++;
                            _companiesCounter++;

                            ConsoleWriter.WriteCurrentCompanyScanned(_companiesCounter);

                            if (InsertData(company))
                            {
                                _companiesImportedCounter++;
                                _sectionThreeCompaniesInserted++;
                                TextLogWriter.WriteInsertedCompanyLog(_startTime, company.NHLACompany, company.CRMCompanyID, company.OksSequenceID, company.Section);
                            }
                            else
                            {
                                //Signal the caller to stop execution of the program.
                                return false;
                            }

                        }
                    }

                    ConsoleWriter.WriteSectionData("Section Three Analysis", i, _sectionThreeCompaniesInserted);
                    TextLogWriter.WriteSectionData("Section Three Analysis", i, _sectionThreeCompaniesInserted);
                    return true;
                }
            }
        }


        protected Company CreateCompany(DbDataReader dr, int section)
        {
            Company company = new Company();

            company.NHLACompany = GetStringValue(dr, "NHLA_COMPANY");
            company.NHLAPhone = GetStringValue(dr, "NHLA_PHONE");
            company.NHLAFax = GetStringValue(dr, "NHLA_FAX");
            company.NHLAWeb = GetStringValue(dr, "NHLA_WEB");
            company.NHLAEmail = GetStringValue(dr, "NHLA_EMAIL");

            company.NHLAddressPrimary = GetStringValue(dr, "NHLA_ADDRESS_PRIMARY");
            company.NHLAddressSecondary = GetStringValue(dr, "NHLA_ADDRESS_SECONDARY");
            company.NHLACity = GetStringValue(dr, "NHLA_CITY");
            company.NHLAState = GetStringValue(dr, "NHLA_STATE");
            company.NHLAZipCode = GetStringValue(dr, "NHLA_ZIPCODE");
            company.NHLACountry = GetStringValue(dr, "NHLA_COUNTRY");
            company.Section = section;
            company.OksSequenceID = GetIntValue(dr, "OKS_SEQUENCE_ID");
            company.OkBatchID =  GetIntValue(dr, "OKS_BATCH_ID");
            //company.Branch_Of_Seq_ID = GetIntValue(dr, "Branch_Of_Seq_ID");

            company.NHLAHTAudited = GetStringValue(dr, "NHLA_HT_AUDITED") == "Y" ? "Y" : string.Empty;
            company.NHLAGradeCertified = GetStringValue(dr, "NHLA_GRADE_CERTIFIED") == "Y" ? "Y" : string.Empty;
            company.NHLASFICertified = GetStringValue(dr, "NHLA_SFI_CERTIFIED") == "Y" ? "Y" : string.Empty;
            company.NHLASFIPart = GetStringValue(dr, "NHLA_SFI_PART") == "Y" ? "SFI Part" : string.Empty;
            company.NHLAFSCCertified = GetStringValue(dr, "NHLA_FSC_CERTIFIED") == "Y" ? "Y" : string.Empty;
            company.NHLAOtherCertification = GetStringValue(dr, "NHLA_OTHER_CERTIFICATION") == "Y" ? "Y" : string.Empty;
            company.NHLAMembershipType = GetStringValue(dr, "NHLA_MEMBERSHIP_TYPE");

            company.NHLAImporter = GetStringValue(dr, "NHLA_IMPORTER") == "Y" ? "Y" : string.Empty;
            company.NHLAExporter = GetStringValue(dr, "NHLA_EXPORTER") == "Y" ? "Y" : string.Empty;

            company.Imports = GetImports(dr);
            company.Exports = GetExports(dr, section);
            company.BusinessTypes = GetBusinessTypes(dr);
            company.SalesContacts = GetSalesContacts(dr);
            company.ExpSalesContacts = GetExpSalesContacts(dr);

            if(section == 1)
                company.Products = GetProducts(dr);

            company.Inserted = false;

            return company;
        }

        protected List<ImportsFrom> GetImports(DbDataReader dr)
        {
            List<ImportsFrom> imports = new List<ImportsFrom>();

            string imports1 = GetStringValue(dr, "NHLA_IMPORTS_FROM_1");
            string imports2 = GetStringValue(dr, "NHLA_IMPORTS_FROM_2");
            string imports3 = GetStringValue(dr, "NHLA_IMPORTS_FROM_3");
            string imports4 = GetStringValue(dr, "NHLA_IMPORTS_FROM_4");
            string imports5 = GetStringValue(dr, "NHLA_IMPORTS_FROM_5");
            string imports6 = GetStringValue(dr, "NHLA_IMPORTS_FROM_6");
            string imports7 = GetStringValue(dr, "NHLA_IMPORTS_FROM_7");
            string imports8 = GetStringValue(dr, "NHLA_IMPORTS_FROM_8");
            string imports9 = GetStringValue(dr, "NHLA_IMPORTS_FROM_9");
            string imports10 = GetStringValue(dr, "NHLA_IMPORTS_FROM_10");

            if(!string.IsNullOrEmpty(imports1))
            {   
                ImportsFrom importsFrom = new ImportsFrom();
                importsFrom.NHLACode = imports1;
                imports.Add(importsFrom);
            }

            if(!string.IsNullOrEmpty(imports2))
            {   
                ImportsFrom importsFrom = new ImportsFrom();
                importsFrom.NHLACode = imports2;
                imports.Add(importsFrom);
            }

            if (!string.IsNullOrEmpty(imports3))
            {
                ImportsFrom importsFrom = new ImportsFrom();
                importsFrom.NHLACode = imports3;
                imports.Add(importsFrom);
            }

            if (!string.IsNullOrEmpty(imports4))
            {
                ImportsFrom importsFrom = new ImportsFrom();
                importsFrom.NHLACode = imports4;
                imports.Add(importsFrom);
            }

            if (!string.IsNullOrEmpty(imports5))
            {
                ImportsFrom importsFrom = new ImportsFrom();
                importsFrom.NHLACode = imports5;
                imports.Add(importsFrom);
            }

            if (!string.IsNullOrEmpty(imports6))
            {
                ImportsFrom importsFrom = new ImportsFrom();
                importsFrom.NHLACode = imports6;
                imports.Add(importsFrom);
            }

            if (!string.IsNullOrEmpty(imports7))
            {
                ImportsFrom importsFrom = new ImportsFrom();
                importsFrom.NHLACode = imports7;
                imports.Add(importsFrom);
            }

            if (!string.IsNullOrEmpty(imports8))
            {
                ImportsFrom importsFrom = new ImportsFrom();
                importsFrom.NHLACode = imports8;
                imports.Add(importsFrom);
            }

            if (!string.IsNullOrEmpty(imports9))
            {
                ImportsFrom importsFrom = new ImportsFrom();
                importsFrom.NHLACode = imports9;
                imports.Add(importsFrom);
            }

            if (!string.IsNullOrEmpty(imports10))
            {
                ImportsFrom importsFrom = new ImportsFrom();
                importsFrom.NHLACode = imports10;
                imports.Add(importsFrom);
            }

            return imports;
        }

        protected List<ExportsTo> GetExports(DbDataReader dr, int section)
        {
            List<ExportsTo> exports = new List<ExportsTo>();

            string exports1 = GetStringValue(dr, "NHLA_EXPORTS_TO_1");
            string exports2 = GetStringValue(dr, "NHLA_EXPORTS_TO_2");
            string exports3 = GetStringValue(dr, "NHLA_EXPORTS_TO_3");
            string exports4 = GetStringValue(dr, "NHLA_EXPORTS_TO_4");
            string exports5 = GetStringValue(dr, "NHLA_EXPORTS_TO_5");
            string exports6 = GetStringValue(dr, "NHLA_EXPORTS_TO_6");
            string exports7 = GetStringValue(dr, "NHLA_EXPORTS_TO_7");
            string exports8 = GetStringValue(dr, "NHLA_EXPORTS_TO_8");
            string exports9 = GetStringValue(dr, "NHLA_EXPORTS_TO_9");
            string exports10 = GetStringValue(dr, "NHLA_EXPORTS_TO_10");
            string exports11 = GetStringValue(dr, "NHLA_EXPORTS_TO_11");
            string exports12 = string.Empty;

            if(section == 1)
                exports12 = GetStringValue(dr, "NHLA_EXPORTS_TO_12");

            if (!string.IsNullOrEmpty(exports1))
            {
                ExportsTo exportsTo = new ExportsTo();
                exportsTo.NHLACode = exports1;
                exports.Add(exportsTo);
            }

            if (!string.IsNullOrEmpty(exports2))
            {
                ExportsTo exportsTo = new ExportsTo();
                exportsTo.NHLACode = exports2;
                exports.Add(exportsTo);
            }

            if (!string.IsNullOrEmpty(exports3))
            {
                ExportsTo exportsTo = new ExportsTo();
                exportsTo.NHLACode = exports3;
                exports.Add(exportsTo);
            }

            if (!string.IsNullOrEmpty(exports4))
            {
                ExportsTo exportsTo = new ExportsTo();
                exportsTo.NHLACode = exports4;
                exports.Add(exportsTo);
            }

            if (!string.IsNullOrEmpty(exports5))
            {
                ExportsTo exportsTo = new ExportsTo();
                exportsTo.NHLACode = exports5;
                exports.Add(exportsTo);
            }

            if (!string.IsNullOrEmpty(exports6))
            {
                ExportsTo exportsTo = new ExportsTo();
                exportsTo.NHLACode = exports6;
                exports.Add(exportsTo);
            }

            if (!string.IsNullOrEmpty(exports7))
            {
                ExportsTo exportsTo = new ExportsTo();
                exportsTo.NHLACode = exports7;
                exports.Add(exportsTo);
            }

            if (!string.IsNullOrEmpty(exports8))
            {
                ExportsTo exportsTo = new ExportsTo();
                exportsTo.NHLACode = exports8;
                exports.Add(exportsTo);
            }

            if (!string.IsNullOrEmpty(exports9))
            {
                ExportsTo exportsTo = new ExportsTo();
                exportsTo.NHLACode = exports9;
                exports.Add(exportsTo);
            }

            if (!string.IsNullOrEmpty(exports10))
            {
                ExportsTo exportsTo = new ExportsTo();
                exportsTo.NHLACode = exports10;
                exports.Add(exportsTo);
            }

            if (!string.IsNullOrEmpty(exports11))
            {
                ExportsTo exportsTo = new ExportsTo();
                exportsTo.NHLACode = exports11;
                exports.Add(exportsTo);
            }

            if (!string.IsNullOrEmpty(exports12))
            {
                ExportsTo exportsTo = new ExportsTo();
                exportsTo.NHLACode = exports12;
                exports.Add(exportsTo);
            }
            
            return exports;
        }


        protected List<BusinessType> GetBusinessTypes(DbDataReader dr)
        {
            List<BusinessType> businessTypes = new List<BusinessType>();

            string businessType1 = GetStringValue(dr, "NHLA_BUS_TYPE_1");
            string businessType2 = GetStringValue(dr, "NHLA_BUS_TYPE_2");
            string businessType3 = GetStringValue(dr, "NHLA_BUS_TYPE_3");
            string businessType4 = GetStringValue(dr, "NHLA_BUS_TYPE_4");
            string businessType5 = GetStringValue(dr, "NHLA_BUS_TYPE_5");
            string businessType6 = GetStringValue(dr, "NHLA_BUS_TYPE_6");
            string businessType7 = GetStringValue(dr, "NHLA_BUS_TYPE_7");
            string businessType8 = GetStringValue(dr, "NHLA_BUS_TYPE_8");
            string businessType9 = GetStringValue(dr, "NHLA_BUS_TYPE_9");
            string businessType10 = GetStringValue(dr, "NHLA_BUS_TYPE_10");

            if (!string.IsNullOrEmpty(businessType1))
            {
                BusinessType businessType = new BusinessType();
                businessType.NHLACode = businessType1;
                businessTypes.Add(businessType);
            }

            if (!string.IsNullOrEmpty(businessType2))
            {
                BusinessType businessType = new BusinessType();
                businessType.NHLACode = businessType2;
                businessTypes.Add(businessType);
            }

            if (!string.IsNullOrEmpty(businessType3))
            {
                BusinessType businessType = new BusinessType();
                businessType.NHLACode = businessType3;
                businessTypes.Add(businessType);
            }

            if (!string.IsNullOrEmpty(businessType4))
            {
                BusinessType businessType = new BusinessType();
                businessType.NHLACode = businessType4;
                businessTypes.Add(businessType);
            }

            if (!string.IsNullOrEmpty(businessType5))
            {
                BusinessType businessType = new BusinessType();
                businessType.NHLACode = businessType5;
                businessTypes.Add(businessType);
            }

            if (!string.IsNullOrEmpty(businessType6))
            {
                BusinessType businessType = new BusinessType();
                businessType.NHLACode = businessType6;
                businessTypes.Add(businessType);
            }

            if (!string.IsNullOrEmpty(businessType7))
            {
                BusinessType businessType = new BusinessType();
                businessType.NHLACode = businessType7;
                businessTypes.Add(businessType);
            }

            if (!string.IsNullOrEmpty(businessType8))
            {
                BusinessType businessType = new BusinessType();
                businessType.NHLACode = businessType8;
                businessTypes.Add(businessType);
            }

            if (!string.IsNullOrEmpty(businessType9))
            {
                BusinessType businessType = new BusinessType();
                businessType.NHLACode = businessType9;
                businessTypes.Add(businessType);
            }

            if (!string.IsNullOrEmpty(businessType10))
            {
                BusinessType businessType = new BusinessType();
                businessType.NHLACode = businessType10;
                businessTypes.Add(businessType);
            }

            return businessTypes;
        }

        protected List<SalesContact> GetSalesContacts(DbDataReader dr)
        {
            List<SalesContact> salesContacts = new List<SalesContact>();

            GetSalesContact(salesContacts, GetStringValue(dr, "NHLA_SALES_CONTACT_1"));
            GetSalesContact(salesContacts, GetStringValue(dr, "NHLA_SALES_CONTACT_2"));
            GetSalesContact(salesContacts, GetStringValue(dr, "NHLA_SALES_CONTACT_3"));
            GetSalesContact(salesContacts, GetStringValue(dr, "NHLA_SALES_CONTACT_4"));
            GetSalesContact(salesContacts, GetStringValue(dr, "NHLA_SALES_CONTACT_5"));

            return salesContacts;
        }

        /// <summary>
        /// Helper method parses the name string into the varios name tokens and
        /// adds a SalesContact instance to the list.
        /// </summary>
        /// <param name="salesContacts"></param>
        /// <param name="fullName"></param>
        private void GetSalesContact(List<SalesContact> salesContacts, string fullName)
        {
            if (string.IsNullOrEmpty(fullName))
            {
                return;
            }

            string[] name = fullName.Split(' ');

            if (name.Length > 0)
            {
                SalesContact salesContact = new SalesContact();
                salesContact.FullName = fullName;


                switch (name.Length)
                {
                    case 1:
                        salesContact.FirstName = name[0];
                        break;
                    case 2:
                        salesContact.FirstName = name[0];
                        salesContact.LastName = name[1];
                        break;
                    case 3:
                        salesContact.FirstName = name[0];
                        salesContact.MiddleName = name[1];
                        salesContact.LastName = name[2];
                        break;
                    case 4:
                        salesContact.FirstName = name[0];
                        salesContact.MiddleName = name[1];
                        salesContact.LastName = name[2];
                        salesContact.Suffix = name[3];
                        break;
                }
                salesContacts.Add(salesContact);
            }
        }

        protected List<SalesContact> GetExpSalesContacts(DbDataReader dr)
        {
            List<SalesContact> salesContacts = new List<SalesContact>();

            GetSalesContact(salesContacts, GetStringValue(dr, "NHLA_EXP_SALES_CONTACT 1"));
            GetSalesContact(salesContacts, GetStringValue(dr, "NHLA_EXP_SALES_CONTACT 2"));
            GetSalesContact(salesContacts, GetStringValue(dr, "NHLA_EXP_SALES_CONTACT 3"));
            GetSalesContact(salesContacts, GetStringValue(dr, "NHLA_EXP_SALES_CONTACT 4"));
            GetSalesContact(salesContacts, GetStringValue(dr, "NHLA_EXP_SALES_CONTACT 5"));

            return salesContacts;
        }

        protected List<Product> GetProducts(DbDataReader dr)
        {
            List<Product> products = new List<Product>();

            string lumTypeGreen = GetStringValue(dr, "NHLA Lumber Type Green");
            string lumTypeAirDried = GetStringValue(dr, "NHLA Lumber Type Air Dried");
            string lumTypeKilnDried = GetStringValue(dr, "NHLA Lumber Type Kiln Dried");
            string lumTypeRough = GetStringValue(dr, "NHLA Lumber Type Rough");
            string lumTypeSurfaced = GetStringValue(dr, "NHLA Lumber Type Surfaced");
            string lumTypeQuarterSewn = GetStringValue(dr, "NHLA Lumber Type Quarter Sewn");
            string lumTypeNonSpec = GetStringValue(dr, "NHLA Lumber Type Non-Specified");
            string cabinets = GetStringValue(dr, "NHLA Product Cabinets");
            string crossties = GetStringValue(dr, "NHLA Product Crossties");
            string stockComp = GetStringValue(dr, "NHLA Product Dimension/Stock Comp");
            string doors = GetStringValue(dr, "NHLA Product Doors");
            string flooringInterior = GetStringValue(dr, "NHLA Product Flooring Interior");
            string flooringTruck = GetStringValue(dr, "NHLA Product Flooring Truck");
            string furniture = GetStringValue(dr, "NHLA Product Furniture");
            string furnitureParts = GetStringValue(dr, "NHLA Product Furniture Parts");
            string moulding = GetStringValue(dr, "NHLA Product Moulding/Millwork");
            string cantsLumber = GetStringValue(dr, "NHLA Product Pallet Cants/Lumber");
            string cantsLumberHT = GetStringValue(dr, "NHLA Product Pallet Cants/Lumber HT");
            string pallets = GetStringValue(dr, "NHLA Product Pallets");
            string palletsHT = GetStringValue(dr, "NHLA Product Pallets HT");
            string panneling = GetStringValue(dr, "NHLA Product Paneling");
            string panelsGluedUp = GetStringValue(dr, "NHLA Product Panels – Glued Up");
            string plywood = GetStringValue(dr, "NHLA Product Plywood");
            string timbers = GetStringValue(dr, "NHLA Product Timbers");
            string turnings = GetStringValue(dr, "NHLA Product Turnings");

            if (lumTypeGreen == "Y" || lumTypeAirDried == "Y" || lumTypeKilnDried == "Y" || lumTypeRough == "Y" ||
                lumTypeSurfaced == "Y" || lumTypeQuarterSewn == "Y" || lumTypeNonSpec == "Y" || stockComp == "Y" )
            {
                Product product = new Product();
                product.Type = "Dimensional Lumber";
                products.Add(product);
            }

            if (cabinets == "Y")
            {
                Product product = new Product();
                product.Type = "Cabinets";
                products.Add(product);
            }

            if (crossties == "Y")
            {
                Product product = new Product();
                product.Type = "Beams";
                products.Add(product);
            }

            if (doors == "Y")
            {
                Product product = new Product();
                product.Type = "Doors";
                products.Add(product);
            }

            if (flooringInterior == "Y" || flooringTruck == "Y")
            {
                Product product = new Product();
                product.Type = "Flooring";
                products.Add(product);
            }

            if (flooringInterior == "Y" || flooringTruck == "Y")
            {
                Product product = new Product();
                product.Type = "Flooring";
                products.Add(product);
            }

            if (moulding == "Y")
            {
                Product product = new Product();
                product.Type = "Moulding & Trim";
                products.Add(product);

                Product product2 = new Product();
                product2.Type = "Millwork";
                products.Add(product2);
            }

            if (cantsLumber == "Y" || cantsLumberHT == "Y" || pallets == "Y" || palletsHT == "Y")
            {
                Product product = new Product();
                product.Type = "Pallet/Skid Stock";
                products.Add(product);
            }

            if (panneling == "Y" || panelsGluedUp == "Y")
            {
                Product product = new Product();
                product.Type = "Panel Products";
                products.Add(product);
            }

            if (plywood == "Y")
            {
                Product product = new Product();
                product.Type = "Plywood";
                products.Add(product);
            }

            if (timbers == "Y")
            {
                Product product = new Product();
                product.Type = "Timbers";
                products.Add(product);
            }

            if (turnings == "Y")
            {
                Product product = new Product();
                product.Type = "Stairs";
                products.Add(product);
            }

            if ((furniture == "Y") || (furnitureParts == "Y"))
            {
                Product product = new Product();
                product.Type = "Furniture";
                products.Add(product);
            }
            return products;
        }

        protected bool InsertData(Company company)
        {
            SqlTransaction oTran = _dbConn.BeginTransaction();

            try
            {
                //1. Determine Listing City ID.
                int listingCityID = ProcessCity(company, oTran);

                //2. Insert Company Record.
                int companyID = InsertCompany(company, listingCityID, oTran);

                //3. Open PIKS Transaction.
                int iPIKSCompanyTransID = OpenPIKSTransaction(companyID, 0, company, oTran);

                //4. Insert Address/Address_Link
                int addressID = InsertAddress(company, companyID, listingCityID, oTran);

                //5. Insert Phone
                InsertPhone(company, companyID, "P", oTran);

                //6. Insert Fax
                InsertPhone(company, companyID, "F", oTran);

                //7. Insert Email
                InsertInternet(companyID, "E", company.NHLAEmail, oTran);

                //8. Insert Web
                InsertInternet(companyID, "W", company.NHLAWeb, oTran);

                //9. Insert Importer Classification
                InsertImporterExporterClassification(company, "I", companyID, oTran);

                //10. Insert Exporter Classification
                InsertImporterExporterClassification(company, "E", companyID, oTran);

                //11. Insert Business Classifications
                InsertBusinessClassifications(company, companyID, oTran);

                //12. Insert Products
                InsertProducts(company, companyID, oTran);

                //13. Add Specie
                AddSpecie(companyID, oTran);

                //14. Insert Export Regions
                InsertExportRegions(company, companyID, oTran);

                //15. Insert Import Regions
                InsertImportRegions(company, companyID, oTran);

                //16. Close the company level transaction
                ClosePIKSTransaction(iPIKSCompanyTransID, oTran);

                //17. Create task
                CreateTask(company, companyID, oTran);

                //18. Insert Persons
                // Combine our list of contacts so that we don't add duplicate
                // persons to the database.  It appears the same names sometimes
                // appears in both lists.
                List<SalesContact> salesContacts = new List<SalesContact>();
                salesContacts.AddRange(company.SalesContacts);
                salesContacts.AddRange(company.ExpSalesContacts);
                InsertPersons(company, salesContacts, companyID, oTran);

                //oTran.Rollback();
                oTran.Commit();
                return true;
            }
            catch (Exception e)
            {
                oTran.Rollback();

                TextLogWriter.WriteException(e);
                ConsoleWriter.WriteException(e);
                return false;
            }
                
        }

        protected int InsertCompany(Company company,
                                   int iListingCityID,
                                   SqlTransaction oTran)
        {
            int iCompanyID = GetPIKSID("Company", oTran);

            if (cmdInsertCompany == null)
            {
                cmdInsertCompany = _dbConn.CreateCommand();
                cmdInsertCompany.CommandText = SQL_COMPANY_INSERT;
            }

            cmdInsertCompany.Parameters.Clear();
            cmdInsertCompany.Transaction = oTran;

            cmdInsertCompany.Parameters.AddWithValue("comp_CompanyID", iCompanyID);
            cmdInsertCompany.Parameters.AddWithValue("comp_PRHQID", iCompanyID);
            cmdInsertCompany.Parameters.AddWithValue("comp_Name", company.NHLACompany);
            cmdInsertCompany.Parameters.AddWithValue("comp_PRLegalName", DBNull.Value);
            cmdInsertCompany.Parameters.AddWithValue("comp_PRType", "H");
            cmdInsertCompany.Parameters.AddWithValue("comp_PRListingStatus", "LUV");
            cmdInsertCompany.Parameters.AddWithValue("comp_PRListingCityID", iListingCityID);
            cmdInsertCompany.Parameters.AddWithValue("comp_PRIndustryType", "L");
            cmdInsertCompany.Parameters.AddWithValue("comp_Source", "NHLA");
            cmdInsertCompany.Parameters.AddWithValue("comp_PRLastPublishedCSDate", DBNull.Value);
            cmdInsertCompany.Parameters.AddWithValue("comp_PRMethodSourceReceived", "NHLA");
            cmdInsertCompany.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
            cmdInsertCompany.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
            cmdInsertCompany.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdInsertCompany.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdInsertCompany.Parameters.AddWithValue("Timestamp", UPDATED_DATE);

            cmdInsertCompany.ExecuteNonQuery();

            company.CRMCompanyID = iCompanyID;
            return iCompanyID;
        }

        protected void InsertPhone(Company company, int iCompanyID, string szType, SqlTransaction oTran)
        {

            string szAreaCode = string.Empty;
            string szPhoneNumber = string.Empty;
            string workArea = null;


            if (szType == "P")
            {
                workArea = company.NHLAPhone;
            }

            if (szType == "F")
            {
                workArea = company.NHLAFax;
            }

            if (string.IsNullOrEmpty(workArea))
                return;


            workArea = workArea.Replace("-", "");

            if (workArea.Length != 10)
            {
                DataIssue dataIssue = new DataIssue();
                dataIssue.Type = Enum.GetName(typeof(DataIssue.IssueTypes), DataIssue.IssueTypes.Phone);

                if (szType == "P")
                {
                    dataIssue.Issue = "Invalid phone number of type " + szType + ": " + company.NHLAPhone + " for CompanyID: " + company.CRMCompanyID + " (" + company.OksSequenceID.ToString() + ")";
                }
                else
                {
                    dataIssue.Issue = "Invalid phone number of type " + szType + ": " + company.NHLAFax + " for CompanyID: " + company.CRMCompanyID + " (" + company.OksSequenceID.ToString() + ")";
                }

                _dataIssues.Add(dataIssue);

                return;
            }

            szAreaCode = workArea.Substring(0, 3);
            szPhoneNumber = workArea.Substring(3, 3) + "-" + workArea.Substring(6, 4);


            // First we need to see if we have an existing record.
            int iPhoneID = GetPIKSID("Phone", oTran);

            SqlCommand cmdPhoneInsert = _dbConn.CreateCommand();
            cmdPhoneInsert.CommandText = SQL_PHONE_INSERT;
            cmdPhoneInsert.Transaction = oTran;
            cmdPhoneInsert.Parameters.AddWithValue("PhoneID", iPhoneID);
            cmdPhoneInsert.Parameters.AddWithValue("CompanyID", iCompanyID);
            cmdPhoneInsert.Parameters.AddWithValue("Type", szType);

            if (szType == "P")
            {
                cmdPhoneInsert.Parameters.AddWithValue("Description", "Phone");
            }
            else
            {
                cmdPhoneInsert.Parameters.AddWithValue("Description", "FAX");
            }

            cmdPhoneInsert.Parameters.AddWithValue("AreaCode", szAreaCode);
            cmdPhoneInsert.Parameters.AddWithValue("Number", szPhoneNumber);
            cmdPhoneInsert.Parameters.AddWithValue("CountryCode", "1");
            cmdPhoneInsert.Parameters.AddWithValue("PRPublish", "Y");
            cmdPhoneInsert.Parameters.AddWithValue("Default", "Y");
            cmdPhoneInsert.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
            cmdPhoneInsert.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
            cmdPhoneInsert.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdPhoneInsert.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdPhoneInsert.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
            cmdPhoneInsert.ExecuteNonQuery();
        }

        protected void InsertInternet(int iCompanyID, string szType, string value, SqlTransaction oTran)
        {

            if (string.IsNullOrEmpty(value))
            {
                return;
            }

            object szEmail = DBNull.Value;
            object szWebAddress = DBNull.Value;

            if (szType == "E")
            {
                szEmail = value.ToLower();
            }
            else
            {
                szWebAddress = value.ToLower();
            }


            int iInternetID = GetPIKSID("Email", oTran);

            SqlCommand cmdInternetInsert = _dbConn.CreateCommand();
            cmdInternetInsert.CommandText = SQL_INTERNET_INSERT;
            cmdInternetInsert.Transaction = oTran;
            cmdInternetInsert.Parameters.AddWithValue("InternetID", iInternetID);
            cmdInternetInsert.Parameters.AddWithValue("CompanyID", iCompanyID);
            cmdInternetInsert.Parameters.AddWithValue("Type", szType);

            if (szType == "E")
            {
                cmdInternetInsert.Parameters.AddWithValue("Description", "E-Mail");
            }
            else
            {
                cmdInternetInsert.Parameters.AddWithValue("Description", "Web Site");
            }

            cmdInternetInsert.Parameters.AddWithValue("Email", szEmail);
            cmdInternetInsert.Parameters.AddWithValue("WebAddress", szWebAddress);
            cmdInternetInsert.Parameters.AddWithValue("PRPublish", "Y");
            cmdInternetInsert.Parameters.AddWithValue("Default", "Y");
            cmdInternetInsert.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
            cmdInternetInsert.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
            cmdInternetInsert.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdInternetInsert.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdInternetInsert.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
            cmdInternetInsert.ExecuteNonQuery();
        }

        protected void InsertImporterExporterClassification(Company company, string classification, int iCompanyID, SqlTransaction oTran)
        {
            int classificationID;
            if (company.NHLAImporter == "Y" && classification == "I")
                classificationID = 2187;
            else if (company.NHLAExporter == "Y" && classification == "E")
                classificationID = 2183;
            else
                return;

            int iCompanyClassificationID = GetPIKSID("PRCompanyClassification", oTran);

            SqlCommand cmdCompanyClassificationInsert = _dbConn.CreateCommand();
            cmdCompanyClassificationInsert.CommandText = SQL_PRCOMPANY_CLASSIFICATION_INSERT;
            cmdCompanyClassificationInsert.Transaction = oTran;
            cmdCompanyClassificationInsert.Parameters.AddWithValue("CompanyClassificationId", iCompanyClassificationID);
            cmdCompanyClassificationInsert.Parameters.AddWithValue("CompanyID", iCompanyID);
            cmdCompanyClassificationInsert.Parameters.AddWithValue("ClassificationId", classificationID);
            cmdCompanyClassificationInsert.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
            cmdCompanyClassificationInsert.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
            cmdCompanyClassificationInsert.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdCompanyClassificationInsert.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdCompanyClassificationInsert.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
            cmdCompanyClassificationInsert.ExecuteNonQuery();
        }

        protected void InsertBusinessClassifications(Company company, int companyID, SqlTransaction oTran)
        {

            if (company.BusinessTypes == null)
            {
                return;
            }

            Hashtable lookUpValues = new Hashtable();
            lookUpValues.Add("CON", 2195);
            lookUpValues.Add("CY", 2194);
            lookUpValues.Add("DP", 2186);
            lookUpValues.Add("DY", 2194);
            lookUpValues.Add("EMD", 2195);
            lookUpValues.Add("EX", 2183);
            lookUpValues.Add("IM", 2187);
            lookUpValues.Add("KD", 2186);
            lookUpValues.Add("MAN", 2186);
            lookUpValues.Add("SM", 2182);
            lookUpValues.Add("TRAN", 2196);

            List<Int32> insertedClassifications = new List<Int32>();

            // Add any classifications we may have already inserted
            if (company.NHLAImporter == "Y")
            {
                insertedClassifications.Add(2187);
            }

            if (company.NHLAExporter == "Y")
            {
                insertedClassifications.Add(2183);
            }

            foreach (BusinessType classification in company.BusinessTypes)
            {

                if (!lookUpValues.ContainsKey(classification.NHLACode.ToUpper()))
                {
                    // The users said to skip these types, so let's not
                    // log them as issues.
                    if ((classification.NHLACode.ToUpper() != "ED") &&
                        (classification.NHLACode.ToUpper() != "OTH") &&
                        (classification.NHLACode.ToUpper() != "SD") &&
                        (classification.NHLACode.ToUpper() != "WH") &&
                        (classification.NHLACode.ToUpper() != "TOWN"))
                    {
                        DataIssue dataIssue = new DataIssue();
                        dataIssue.Type = Enum.GetName(typeof(DataIssue.IssueTypes), DataIssue.IssueTypes.Classification);
                        dataIssue.Issue = "Unable to find classification: " + classification.NHLACode + " for CompanyID: " + company.CRMCompanyID + " (" + company.OksSequenceID.ToString() + ")";
                        _dataIssues.Add(dataIssue);
                    }
                }
                else
                {
                    int iClassificationID = (int)lookUpValues[classification.NHLACode.ToUpper()];

                    // Make sure we don't enter any duplicates
                    if (!insertedClassifications.Contains(iClassificationID))
                    {
                        // Only generate an ID if we need it
                        int iCompanyClassificationID = GetPIKSID("PRCompanyClassification", oTran);
                        
                        SqlCommand cmdCompanyClassificationInsert = _dbConn.CreateCommand();
                        cmdCompanyClassificationInsert.CommandText = SQL_PRCOMPANY_CLASSIFICATION_INSERT;
                        cmdCompanyClassificationInsert.Transaction = oTran;
                        cmdCompanyClassificationInsert.Parameters.AddWithValue("CompanyClassificationId", iCompanyClassificationID);
                        cmdCompanyClassificationInsert.Parameters.AddWithValue("CompanyID", companyID);
                        cmdCompanyClassificationInsert.Parameters.AddWithValue("ClassificationId", iClassificationID);
                        cmdCompanyClassificationInsert.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
                        cmdCompanyClassificationInsert.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
                        cmdCompanyClassificationInsert.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
                        cmdCompanyClassificationInsert.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
                        cmdCompanyClassificationInsert.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
                        cmdCompanyClassificationInsert.ExecuteNonQuery();

                        insertedClassifications.Add(iClassificationID);
                    }
                }
            }
        }


        protected void InsertProducts(Company company, int companyID, SqlTransaction oTran)
        {
            if (company.Products == null)
            {
                return;
            }

            Hashtable lookUpValues = new Hashtable();
            lookUpValues.Add("Dimensional Lumber", 7);
            lookUpValues.Add("Cabinets", 39);
            lookUpValues.Add("Beams", 1);
            lookUpValues.Add("Doors", 42);
            lookUpValues.Add("Flooring", 13);
            lookUpValues.Add("Moulding & Trim", 20);
            lookUpValues.Add("Millwork", 19);
            lookUpValues.Add("Pallet/Skid Stock", 22);
            lookUpValues.Add("Panel Products", 23);
            lookUpValues.Add("Plywood", 26);
            lookUpValues.Add("Timbers", 34);
            lookUpValues.Add("Stairs", 47);
            lookUpValues.Add("Furniture", 43);

            List<Int32> insertedProducts = new List<int>();

            foreach (Product product in company.Products)
            {

                if (!lookUpValues.ContainsKey(product.Type))
                {
                    DataIssue dataIssue = new DataIssue();
                    dataIssue.Type = Enum.GetName(typeof(DataIssue.IssueTypes), DataIssue.IssueTypes.Product);
                    dataIssue.Issue = "Unable to find product: " + product.Type + " for CompanyID: " + company.CRMCompanyID + " (" + company.OksSequenceID.ToString() + ")";
                    _dataIssues.Add(dataIssue);
                }
                else
                {
                    int iProductID = (int)lookUpValues[product.Type];

                    // Make sure we don't enter any duplicates
                    if (!insertedProducts.Contains(iProductID))
                    {
                        // Only generate an ID if we need it
                        int iID = GetPIKSID("PRCompanyProductProvided", oTran);

                        SqlCommand cmdInsert = _dbConn.CreateCommand();
                        cmdInsert.CommandText = SQL_PRCOMPANY_PRODUCT_PROVIDED_INSERT;
                        cmdInsert.Transaction = oTran;
                        cmdInsert.Parameters.AddWithValue("CompanyProductProvidedID", iID);
                        cmdInsert.Parameters.AddWithValue("CompanyID", companyID);
                        cmdInsert.Parameters.AddWithValue("ProductProvidedID", iProductID);
                        cmdInsert.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
                        cmdInsert.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
                        cmdInsert.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
                        cmdInsert.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
                        cmdInsert.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
                        cmdInsert.ExecuteNonQuery();

                        insertedProducts.Add(iProductID);
                    }
                }
            }
        }


        protected void InsertExportRegions(Company company, int companyID, SqlTransaction oTran)
        {
            if (company.Exports == null)
            {
                return;
            }

            Hashtable lookUpValues = new Hashtable();
            lookUpValues.Add("EU", 74);
            lookUpValues.Add("CL", 72);
            lookUpValues.Add("CE", 74);
            lookUpValues.Add("SA", 73);
            lookUpValues.Add("SEA", 79);
            lookUpValues.Add("AU", 78);
            lookUpValues.Add("CH", 79);
            lookUpValues.Add("AF", 77);
            lookUpValues.Add("MX", 71);

            List<Int32> insertedRegions = new List<int>();

            foreach (ExportsTo exportTo in company.Exports)
            {

                if (!lookUpValues.ContainsKey(exportTo.NHLACode))
                {
                    // The users said to skip these codes, so we shouldn't log
                    // them as a data issue.
                    if ((exportTo.NHLACode != "OC") &&
                        (exportTo.NHLACode != "NA"))
                    {

                        DataIssue dataIssue = new DataIssue();
                        dataIssue.Type = Enum.GetName(typeof(DataIssue.IssueTypes), DataIssue.IssueTypes.ExportRegion);
                        dataIssue.Issue = "Unable to find export region: " + exportTo.NHLACode + " for CompanyID: " + company.CRMCompanyID + " (" + company.OksSequenceID.ToString() + ")";
                        _dataIssues.Add(dataIssue);
                    }
                }
                else
                {
                    int iRegionID = (int)lookUpValues[exportTo.NHLACode];

                    // Make sure we don't enter any duplicates
                    if (!insertedRegions.Contains(iRegionID))
                    {
                        // Only generate an ID if we need it
                        int iID = GetPIKSID("PRCompanyRegion", oTran);

                        SqlCommand cmdInsert = _dbConn.CreateCommand();
                        cmdInsert.CommandText = SQL_PRCOMPANY_REGION_INSERT;
                        cmdInsert.Transaction = oTran;
                        cmdInsert.Parameters.AddWithValue("CompanyRegionID", iID);
                        cmdInsert.Parameters.AddWithValue("CompanyID", companyID);
                        cmdInsert.Parameters.AddWithValue("RegionID", iRegionID);
                        cmdInsert.Parameters.AddWithValue("Type", "SellI");
                        cmdInsert.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
                        cmdInsert.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
                        cmdInsert.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
                        cmdInsert.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
                        cmdInsert.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
                        cmdInsert.ExecuteNonQuery();

                        insertedRegions.Add(iRegionID);
                    }
                }
            }
        }


        protected void InsertImportRegions(Company company, int companyID, SqlTransaction oTran)
        {
            if (company.Imports == null)
            {
                return;
            }

            Hashtable lookUpValues = new Hashtable();
            lookUpValues.Add("EU", 74);
            lookUpValues.Add("CL", 72);
            lookUpValues.Add("CE", 74);
            lookUpValues.Add("SA", 73);
            lookUpValues.Add("SEA", 79);
            lookUpValues.Add("AU", 78);
            lookUpValues.Add("CH", 79);
            lookUpValues.Add("AF", 77);
            lookUpValues.Add("MX", 71);

            List<Int32> insertedRegions = new List<int>();

            foreach (ImportsFrom importFrom in company.Imports)
            {

                if (!lookUpValues.ContainsKey(importFrom.NHLACode))
                {
                    // The users said to skip these codes, so we shouldn't log
                    // them as a data issue.
                    if ((importFrom.NHLACode != "OC") &&
                        (importFrom.NHLACode != "NA"))
                    {
                        DataIssue dataIssue = new DataIssue();
                        dataIssue.Type = Enum.GetName(typeof(DataIssue.IssueTypes), DataIssue.IssueTypes.ImportRegion);
                        dataIssue.Issue = "Unable to find import region: " + importFrom.NHLACode + " for CompanyID: " + company.CRMCompanyID;
                        _dataIssues.Add(dataIssue);
                    }
                }
                else
                {
                    int iRegionID = (int)lookUpValues[importFrom.NHLACode];

                    // Make sure we don't enter any duplicates
                    if (!insertedRegions.Contains(iRegionID))
                    {
                        // Only generate an ID if we need it
                        int iID = GetPIKSID("PRCompanyRegion", oTran);

                        SqlCommand cmdInsert = _dbConn.CreateCommand();
                        cmdInsert.CommandText = SQL_PRCOMPANY_REGION_INSERT;
                        cmdInsert.Transaction = oTran;
                        cmdInsert.Parameters.AddWithValue("CompanyRegionID", iID);
                        cmdInsert.Parameters.AddWithValue("CompanyID", companyID);
                        cmdInsert.Parameters.AddWithValue("RegionID", iRegionID);
                        cmdInsert.Parameters.AddWithValue("Type", "SrcI");
                        cmdInsert.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
                        cmdInsert.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
                        cmdInsert.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
                        cmdInsert.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
                        cmdInsert.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
                        cmdInsert.ExecuteNonQuery();

                        insertedRegions.Add(iRegionID);
                    }
                }
            }
        }

        protected int GetPIKSID(string szTableName, SqlTransaction oTran)
        {
            SqlCommand sqlGetID = _dbConn.CreateCommand();
            sqlGetID.Transaction = oTran;
            sqlGetID.CommandText = "usp_getNextId";
            sqlGetID.CommandType = CommandType.StoredProcedure;

            sqlGetID.Parameters.Add(new SqlParameter("TableName", szTableName));

            SqlParameter oReturnParm = new SqlParameter();
            oReturnParm.ParameterName = "Return";
            oReturnParm.Value = 0;
            oReturnParm.Direction = ParameterDirection.Output;
            sqlGetID.Parameters.Add(oReturnParm);

            sqlGetID.ExecuteNonQuery();

            return Convert.ToInt32(oReturnParm.Value);
        }

        protected int OpenPIKSTransaction(int iCompanyID,
                                          int iPersonID,
                                          Company company,
                                          SqlTransaction oTran)
        {
            SqlCommand sqlOpenPIKSTransaction = _dbConn.CreateCommand();
            sqlOpenPIKSTransaction.Transaction = oTran;
            sqlOpenPIKSTransaction.CommandText = "usp_CreateTransaction";
            sqlOpenPIKSTransaction.CommandType = CommandType.StoredProcedure;
            sqlOpenPIKSTransaction.Parameters.AddWithValue("UserId", UPDATED_BY);

            StringBuilder sbExplanation = new StringBuilder("Created from the NHLA data import." + Environment.NewLine);
            sbExplanation.Append(Environment.NewLine + "NHLA OKS Batch ID: " + company.OkBatchID + Environment.NewLine);
            sbExplanation.Append(Environment.NewLine + "NHLA OKS Sequence ID: " + company.OksSequenceID + Environment.NewLine);
            sqlOpenPIKSTransaction.Parameters.AddWithValue("prtx_Explanation", sbExplanation.ToString());


            if (iCompanyID > 0)
            {
                sqlOpenPIKSTransaction.Parameters.AddWithValue("prtx_CompanyId", iCompanyID);
            }

            if (iPersonID > 0)
            {
                sqlOpenPIKSTransaction.Parameters.AddWithValue("prtx_PersonId", iPersonID);
            }


            SqlParameter oReturnParm = new SqlParameter();
            oReturnParm.ParameterName = "NextId";
            oReturnParm.Value = 0;
            oReturnParm.Direction = ParameterDirection.ReturnValue;
            sqlOpenPIKSTransaction.Parameters.Add(oReturnParm);

            sqlOpenPIKSTransaction.ExecuteNonQuery();
            return Convert.ToInt32(oReturnParm.Value);
        }

        protected const string SQL_PRTRANSACTION_CLOSE = "UPDATE PRTransaction SET prtx_Status='C', prtx_CloseDate=GETDATE(), prtx_UpdatedBy=-1, prtx_UpdatedDate=GETDATE(), prtx_Timestamp=GETDATE() WHERE prtx_TransactionId=@TransactionID";

        /// <summary>
        /// Updates the specified PRTransaction setting the appropriate
        /// values to close it.
        /// </summary>
        /// <param name="iTransactionID"></param>
        /// <param name="oTran"></param>
        public void ClosePIKSTransaction(int iTransactionID, SqlTransaction oTran)
        {
            if (iTransactionID <= 0)
            {
                return;
            }

            SqlCommand sqlCloseTransaction = _dbConn.CreateCommand();
            sqlCloseTransaction.Transaction = oTran;
            sqlCloseTransaction.Parameters.Add(new SqlParameter("TransactionID", iTransactionID));
            sqlCloseTransaction.CommandText = SQL_PRTRANSACTION_CLOSE;

            if (sqlCloseTransaction.ExecuteNonQuery() == 0)
            {
                throw new ApplicationException("Unable to close transaction: " + iTransactionID.ToString());
            }
        }

        protected int InsertAddress(Company company, int iCompanyID, int cityID, SqlTransaction oTran)
        {
            if ((string.IsNullOrEmpty(company.NHLAddressPrimary)) &&
                (string.IsNullOrEmpty(company.NHLAddressSecondary)) &&
                (string.IsNullOrEmpty(company.NHLACity)) &&
                (string.IsNullOrEmpty(company.NHLAState)) &&
                (string.IsNullOrEmpty(company.NHLAZipCode)) &&
                (string.IsNullOrEmpty(company.NHLACountry)))
            {
                return -1;
            }

            if (company.NHLAddressPrimary.Length > 40)
            {
                company.NHLAddressPrimary = company.NHLAddressPrimary.Substring(0, 40);

                DataIssue dataIssue = new DataIssue();
                dataIssue.Type = Enum.GetName(typeof(DataIssue.IssueTypes), DataIssue.IssueTypes.PrimaryAddress);
                dataIssue.Issue = "Primary Address too long for CompanyID: " + iCompanyID;
                _dataIssues.Add(dataIssue);
            }

            if (company.NHLAddressSecondary.Length > 40)
            {
                company.NHLAddressSecondary = company.NHLAddressSecondary.Substring(0, 40);

                DataIssue dataIssue = new DataIssue();
                dataIssue.Type = Enum.GetName(typeof(DataIssue.IssueTypes), DataIssue.IssueTypes.PrimaryAddress);
                dataIssue.Issue = "Secondary Address too long for CompanyID: " + iCompanyID;
                _dataIssues.Add(dataIssue);
            }

            int iAddressID = GetPIKSID("Address", oTran);

            SqlCommand cmdAddressInsert = _dbConn.CreateCommand();
            cmdAddressInsert.CommandText = SQL_ADDRESS_INSERT;
            cmdAddressInsert.Transaction = oTran;
            cmdAddressInsert.Parameters.AddWithValue("AddressID", iAddressID);
            cmdAddressInsert.Parameters.AddWithValue("Address1", company.NHLAddressPrimary);

            if (!string.IsNullOrEmpty(company.NHLAddressSecondary))
            {
                company.NHLAddressSecondary = company.NHLAddressSecondary.Trim();
            }

            if (string.IsNullOrEmpty(company.NHLAddressSecondary))
            {
                cmdAddressInsert.Parameters.AddWithValue("Address2", DBNull.Value);
            }
            else
            {
                cmdAddressInsert.Parameters.AddWithValue("Address2", company.NHLAddressSecondary);
            }

            cmdAddressInsert.Parameters.AddWithValue("PRCityID", cityID);
            cmdAddressInsert.Parameters.AddWithValue("PostCode", company.NHLAZipCode);
            cmdAddressInsert.Parameters.AddWithValue("PRPublish", "Y");
            cmdAddressInsert.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
            cmdAddressInsert.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
            cmdAddressInsert.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdAddressInsert.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdAddressInsert.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
            cmdAddressInsert.ExecuteNonQuery();

            int iAddressLinkID = GetPIKSID("Address_Link", oTran);
            SqlCommand cmdAddressLinkInsert = _dbConn.CreateCommand();
            cmdAddressLinkInsert.CommandText = SQL_ADDRESSLINK_INSERT;
            cmdAddressLinkInsert.Transaction = oTran;
            cmdAddressLinkInsert.Parameters.AddWithValue("AddressLinkId", iAddressLinkID);
            cmdAddressLinkInsert.Parameters.AddWithValue("AddressID", iAddressID);
            cmdAddressLinkInsert.Parameters.AddWithValue("CompanyID", iCompanyID);
            cmdAddressLinkInsert.Parameters.AddWithValue("Type", "PH");

            cmdAddressLinkInsert.Parameters.AddWithValue("PRDefaultTax", "Y");
            cmdAddressLinkInsert.Parameters.AddWithValue("PRDefaultMailing", "Y");
  

            cmdAddressLinkInsert.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
            cmdAddressLinkInsert.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
            cmdAddressLinkInsert.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdAddressLinkInsert.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdAddressLinkInsert.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
            cmdAddressLinkInsert.ExecuteNonQuery();

            return iAddressID;
        }

        protected void InsertPersons(Company company, List<SalesContact> contacts, int iCompanyID, SqlTransaction oTran)
        {
            if (contacts == null)
            {
                return;
            }

            List<string> insertedPersons = new List<string>();

            foreach (SalesContact salesContact in contacts)
            {
                // Make sure we don't add duplicate persons
                if (!insertedPersons.Contains(salesContact.FullName)) {

                    int iPersonID = GetPIKSID("Person", oTran);

                    int iPIKSPersonTransID = OpenPIKSTransaction(0,
                                                                iPersonID,
                                                                company,
                                                                oTran);

                    AddPerson(iPersonID, iCompanyID, iPIKSPersonTransID, salesContact, oTran);

                    ClosePIKSTransaction(iPIKSPersonTransID, oTran);

                    insertedPersons.Add(salesContact.FullName);
                }
            }
        }


        private const string SQL_PERSON_INSERT =
            "INSERT INTO Person (Pers_PersonId, Pers_FirstName, Pers_LastName, Pers_MiddleName, Pers_Suffix, Pers_CreatedBy, Pers_CreatedDate, Pers_UpdatedBy, Pers_UpdatedDate, Pers_Timestamp) " +
            "VALUES (@PersonId, @FirstName, @LastName, @MiddleName, @Suffix, @UpdatedBy, @UpdatedDate, @UpdatedBy, @UpdatedDate, @Timestamp)";

        private const string SQL_PERSON_LINK_INSERT =
            "INSERT INTO Person_Link (PeLi_PersonLinkId, PeLi_PersonId, PeLi_CompanyID, peli_PROwnershipRole, peli_PRTitleCode, peli_PRStatus, peli_PREBBPublish, peli_PRBRPublish, peli_PRSubmitTES, peli_PRUpdateCL, peli_PRUseServiceUnits, peli_PRUseSpecialServices, peli_PRReceivesTrainingEmail, peli_PRReceivesPromoEmail, peli_PRReceivesCreditSheetReport, peli_PREditListing, peli_CreatedBy, peli_CreatedDate, peli_UpdatedBy, peli_UpdatedDate, peli_Timestamp) " +
            "VALUES (@PersonLinkId, @PersonId, @CompanyID, 'RCR', 'OTHR', '1', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', @UpdatedBy, @UpdatedDate, @UpdatedBy, @UpdatedDate, @Timestamp)";

        protected void AddPerson(int iPersonId, int iCompanyID, int iPIKSTransactionID, SalesContact salesContact, SqlTransaction oTran)
        {

            if (string.IsNullOrEmpty(salesContact.FirstName))
            {
                DataIssue dataIssue = new DataIssue();
                dataIssue.Type = Enum.GetName(typeof(DataIssue.IssueTypes), DataIssue.IssueTypes.PersonName);
                dataIssue.Issue = "Found person without complete Name: " + salesContact.FullName + " for CompanyID: " + iCompanyID;
                _dataIssues.Add(dataIssue);
                
                // If we don't have a name, we cannot
                // insert the person record.
                return;
            }

            SqlCommand cmdPersonInsert = _dbConn.CreateCommand();
            cmdPersonInsert.CommandText = SQL_PERSON_INSERT;
            cmdPersonInsert.Transaction = oTran;
            cmdPersonInsert.Parameters.AddWithValue("PersonId", iPersonId);
            cmdPersonInsert.Parameters.AddWithValue("FirstName", salesContact.FirstName);
            cmdPersonInsert.Parameters.AddWithValue("LastName", salesContact.LastName);

            if (string.IsNullOrEmpty(salesContact.MiddleName))
            {
                cmdPersonInsert.Parameters.AddWithValue("MiddleName", DBNull.Value);
            } else {
                cmdPersonInsert.Parameters.AddWithValue("MiddleName", salesContact.MiddleName);
            }

            if (string.IsNullOrEmpty(salesContact.Suffix))
            {
                cmdPersonInsert.Parameters.AddWithValue("Suffix", DBNull.Value);
            }
            else
            {
                cmdPersonInsert.Parameters.AddWithValue("Suffix", salesContact.Suffix);
            }

            cmdPersonInsert.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
            cmdPersonInsert.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
            cmdPersonInsert.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdPersonInsert.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdPersonInsert.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
            cmdPersonInsert.ExecuteNonQuery();

            int iPersonLinkID = GetPIKSID("Person_Link", oTran);
            SqlCommand cmdPersonLinkInsert = _dbConn.CreateCommand();
            cmdPersonLinkInsert.CommandText = SQL_PERSON_LINK_INSERT;
            cmdPersonLinkInsert.Transaction = oTran;
            cmdPersonLinkInsert.Parameters.AddWithValue("PersonLinkId", iPersonLinkID);
            cmdPersonLinkInsert.Parameters.AddWithValue("PersonId", iPersonId);
            cmdPersonLinkInsert.Parameters.AddWithValue("CompanyID", iCompanyID);
            cmdPersonLinkInsert.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
            cmdPersonLinkInsert.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
            cmdPersonLinkInsert.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdPersonLinkInsert.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdPersonLinkInsert.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
            cmdPersonLinkInsert.ExecuteNonQuery();


            string szNewValue = salesContact.FirstName + " " + salesContact.LastName + " Created.";

            SqlCommand cmdTransDetail = _dbConn.CreateCommand();
            cmdTransDetail.CommandText = "usp_CreateTransactionDetail";
            cmdTransDetail.CommandType = CommandType.StoredProcedure;
            cmdTransDetail.Transaction = oTran;
            cmdTransDetail.Parameters.AddWithValue("prtx_TransactionId", iPIKSTransactionID);
            cmdTransDetail.Parameters.AddWithValue("Entity", "Person");
            cmdTransDetail.Parameters.AddWithValue("Action", "Insert");
            cmdTransDetail.Parameters.AddWithValue("NewValue", szNewValue);
            cmdTransDetail.Parameters.AddWithValue("UserId", UPDATED_BY);
            cmdTransDetail.ExecuteNonQuery();
        }

        protected int ProcessCity(Company company, SqlTransaction oTran)
        {
            int iCityID = 0;

 
            iCityID = SearchForCity(company.NHLACity, company.NHLAState, oTran);

            // If we found an ID, then return it.
            if (iCityID > 0)
            {
                return iCityID;
            }

            string szTranslatedCity = TranslateCityName(company.NHLACity, company.NHLAState);
            if (!string.IsNullOrEmpty(szTranslatedCity))
            {
                iCityID = SearchForCity(szTranslatedCity, company.NHLAState, oTran);
                if (iCityID > 0)
                {
                    return iCityID;
                }
            }

            DataIssue dataIssue = new DataIssue();
            dataIssue.Type = Enum.GetName(typeof(DataIssue.IssueTypes), DataIssue.IssueTypes.City);
            dataIssue.Issue = "Unable to Resolve City, State for Company " + company.NHLACompany + " (" + company.Section.ToString() + ":" + company.OksSequenceID.ToString() + "): " + company.NHLACity + ", " + company.NHLAState;
            _dataIssues.Add(dataIssue);

            TextLogWriter.WriteUnresolvedCity(_startTime, company);
            return -1;
        }

        protected int SearchForCity(string szCity, string szState, SqlTransaction oTran)
        {
            // First we need to check to see if the city already exists.
            SqlCommand sqlCityExist = _dbConn.CreateCommand();
            sqlCityExist.Transaction = oTran;
            sqlCityExist.Parameters.Add(new SqlParameter("City", szCity));
            sqlCityExist.Parameters.Add(new SqlParameter("State", szState));
            sqlCityExist.CommandText = SQL_IS_CITY_EXIST;
            object oCityID = sqlCityExist.ExecuteScalar();

            if (oCityID == null)
            {
                return -1;
            }

            return Convert.ToInt32(oCityID);
        }

        protected string TranslateCityName(string szCity, string szState)
        {

            if (szCity == "S Chicago Hts")
            {
                return "South Chicago Heights";
            }
            if (szCity.StartsWith("Mt "))
            {
                return szCity.Replace("Mt ", "Mount ");
            }
            if (szCity.StartsWith("N "))
            {
                return szCity.Replace("N ", "North ");
            }
            if (szCity.StartsWith("S "))
            {
                return szCity.Replace("S ", "South ");
            }
            if (szCity.StartsWith("Ste "))
            {
                return szCity.Replace("Ste ", "Saint ");
            }
            if (szCity.StartsWith("St "))
            {
                return szCity.Replace("St ", "Saint ");
            }
            if (szCity.StartsWith("Internatl "))
            {
                return szCity.Replace("Internatl ", "International ");
            }
            if (szCity.EndsWith(" Fls"))
            {
                return szCity.Replace(" Fls", " Falls");
            }
            if (szCity.EndsWith(" Spgs"))
            {
                return szCity.Replace(" Spgs", " Springs");
            }
            if (szCity.EndsWith(" Vlg"))
            {
                return szCity.Replace(" Vlg", " Village");
            }
            if (szCity.EndsWith(" Hls"))
            {
                return szCity.Replace(" Hls", " Hills");
            }
            if (szCity.EndsWith(" Hts"))
            {
                return szCity.Replace(" Hts", " Heights");
            }
            if (szCity.EndsWith(" Jeffrsn Sta"))
            {
                return szCity.Replace(" Jeffrsn Sta", " Jefferson Station");
            }
            if (szCity.EndsWith(" Sta"))
            {
                return szCity.Replace(" Sta", " Station");
            }

            if ((szState == "SOUTH CAROLINA") && (szCity == "NARTSVILLE"))
            {
                return "Hartsville";
            }

            if ((szState == "ONTARIO") && (szCity == "SCKOMBERG"))
            {
                return "Schomberg";
            }

            if ((szState == "FLORIDA") && (szCity == "SAINT PETERSBURG"))
            {
                return "St. Petersburg";
            }

            if ((szState == "MISSOURI") && (szCity == "Saint Louis"))
            {
                return "St. Louis";
            }

            if ((szState == "QUEBEC") && (szCity == "GRAND'MERE"))
            {
                return "Grand-Mere";
            }

            return null;
        }

        protected void CreateTask(Company company, int companyID, SqlTransaction oTran)
        {
            string szStatus = "Complete";

            StringBuilder sbTaskMsg = new StringBuilder();

            sbTaskMsg.Append("OKS Sequence ID: " + company.OksSequenceID.ToString() + Environment.NewLine);
            sbTaskMsg.Append("OKS Batch: " + company.OkBatchID.ToString() + Environment.NewLine);
            sbTaskMsg.Append("Membership Type: " + company.NHLAMembershipType + Environment.NewLine); 
   
            if(company.NHLAHTAudited == "Y")
                sbTaskMsg.Append("HT Audited: " + Environment.NewLine);

            if (company.NHLAGradeCertified == "Y")
                sbTaskMsg.Append("Grade Certified: " + Environment.NewLine);

            if (company.NHLASFICertified == "Y")
                sbTaskMsg.Append("SFI Certified: " + Environment.NewLine);

            if (company.NHLASFIPart == "Y")
                sbTaskMsg.Append("SFI Part: " + Environment.NewLine);

            if (company.NHLAFSCCertified == "Y")
                sbTaskMsg.Append("FSC Certified: " + Environment.NewLine);

            if (company.NHLAOtherCertification == "Y")
                sbTaskMsg.Append("Certified - Other: " + Environment.NewLine);


            SqlCommand cmdCreateTask = _dbConn.CreateCommand();
            cmdCreateTask.CommandText = "usp_CreateTask";
            cmdCreateTask.CommandType = CommandType.StoredProcedure;
            cmdCreateTask.Transaction = oTran;
            cmdCreateTask.Parameters.AddWithValue("StartDateTime", DateTime.Now);
            cmdCreateTask.Parameters.AddWithValue("DueDateTime", DateTime.Now);
            cmdCreateTask.Parameters.AddWithValue("CreatorUserId", UPDATED_BY);
            cmdCreateTask.Parameters.AddWithValue("AssignedToUserId", 51);
            cmdCreateTask.Parameters.AddWithValue("TaskNotes", sbTaskMsg.ToString());
            cmdCreateTask.Parameters.AddWithValue("Status", szStatus);
            cmdCreateTask.Parameters.AddWithValue("RelatedCompanyID", companyID);
            cmdCreateTask.ExecuteNonQuery();
        }

       
        protected void AddSpecie(int iCompanyID, SqlTransaction oTran)
        {
            int iCompanySpecieID = GetPIKSID("PRCompanySpecie", oTran);

            SqlCommand cmdCompanySpecieInsert = _dbConn.CreateCommand();
            cmdCompanySpecieInsert.CommandText = SQL_PRCOMPANYSPECIE_INSERT;
            cmdCompanySpecieInsert.Transaction = oTran;
            cmdCompanySpecieInsert.Parameters.AddWithValue("CompanySpecieID", iCompanySpecieID);
            cmdCompanySpecieInsert.Parameters.AddWithValue("CompanyID", iCompanyID);
            cmdCompanySpecieInsert.Parameters.AddWithValue("SpecieID", 75);
            cmdCompanySpecieInsert.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
            cmdCompanySpecieInsert.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
            cmdCompanySpecieInsert.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdCompanySpecieInsert.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdCompanySpecieInsert.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
            cmdCompanySpecieInsert.ExecuteNonQuery();
        }

        protected string GetStringValue(IDataReader drReader, string szColName)
        {
            if (drReader[szColName] == DBNull.Value)
            {
                return String.Empty;
            }
            return Convert.ToString(drReader[szColName]).Trim();
        }

        protected int GetIntValue(IDataReader drReader, string szColName)
        {
            if (drReader[szColName] == DBNull.Value)
            {
                return 0;
            }
            return Convert.ToInt32(drReader[szColName]);
        }

        protected void AddParameter(SqlCommand sqlCommand, string szParmName, string szParmValue)
        {
            if (string.IsNullOrEmpty(szParmValue))
            {
                sqlCommand.Parameters.AddWithValue(szParmName, DBNull.Value);
            }
            else
            {
                sqlCommand.Parameters.AddWithValue(szParmName, szParmValue);
            }
        }

        protected void AddParameter(SqlCommand sqlCommand, string szParmName, int iParmValue)
        {
            if (iParmValue == 0)
            {
                sqlCommand.Parameters.AddWithValue(szParmName, DBNull.Value);
            }
            else
            {
                sqlCommand.Parameters.AddWithValue(szParmName, iParmValue);
            }
        }
    }
}
