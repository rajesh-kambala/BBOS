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

using CommandLine.Utility;
namespace OKSImport
{
    class OKSImporter
    {

        protected string _szOutputFile;
        protected string _szInputDirectory;
        protected List<string> _lszOutputBuffer = new List<string>();
        protected List<string> _lszSkippedBuffer = new List<string>();

        protected const int UPDATED_BY = -55;
        protected DateTime UPDATED_DATE = DateTime.Now;

        protected SqlConnection _dbConn = null;
        protected OleDbConnection _classifConnection = null;

        protected int _iCompanyUpdatedCount = 0;
        protected int _iAddresUpdatedCount = 0;
        protected int _iAddresInsertedCount = 0;
        protected int _iEmailUpdatedCount = 0;
        protected int _iEmailInsertedCount = 0;
        protected int _iWebUpdatedCount = 0;
        protected int _iWebInsertedCount = 0;
        protected int _iPhoneUpdatedCount = 0;
        protected int _iPhoneInsertedCount = 0;
        protected int _iFaxUpdatedCount = 0;
        protected int _iFaxInsertedCount = 0;
        protected int _iClassificationInsertedCount = 0;
        protected int _iSpecieInsertedCount = 0;
        protected int _iPersonInsertedCount = 0;

        protected int _iMCityID = 0;
        protected int _iPHCityID = 0;
        protected int _iListingCityID = 0;

        public void Import(string[] args)
        {
            Console.Clear();
            Console.Title = "OKS Import Utility";
            WriteLine("OKS Import Utility 1.0");
            WriteLine("Copyright (c) 2009 Produce Reporter Co.");
            WriteLine("All Rights Reserved.");
            WriteLine("  OS Version: " + System.Environment.OSVersion.ToString());
            WriteLine(" CLR Version: " + System.Environment.Version.ToString());
            WriteLine(string.Empty);

            if (args.Length == 0)
            {
                //DisplayHelp();
                //return;
            }

            // Command line parsing
            Arguments oCommandLine = new Arguments(args);


            if ((oCommandLine["help"] != null) ||
                (oCommandLine["?"] != null))
            {
                //DisplayHelp();
                return;
            }

            if (oCommandLine["O"] != null)
            {
                _szOutputFile = oCommandLine["O"];
            }
            else
            {
                _szOutputFile = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Substring(6);
                _szOutputFile = Path.Combine(_szOutputFile, "OKSImporter.txt");
            }

            if (oCommandLine["D"] != null)
            {
                _szInputDirectory = oCommandLine["D"];
            }
            else
            {
                _szInputDirectory = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Substring(6);
            }

            try
            {
                ExecuteImport();
            }
            catch (Exception e)
            {
                Console.WriteLine();
                Console.WriteLine();
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine("An unexpected exception occurred: " + e.Message);
                Console.WriteLine(e.StackTrace);
                Console.WriteLine("Terminating execution.");
                Console.ForegroundColor = ConsoleColor.Gray;
            }
        }

        private const string MSACCESS_CONN = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source={0}";
        protected void ExecuteImport()
        {
            DateTime dtStart = DateTime.Now;
            int iCompanyCount = 0;
            int iHasChangedCount = 0;


            bool bCommit = Convert.ToBoolean(ConfigurationManager.AppSettings["CommitChanges"]);

            // The Profile_Output table in the MS Access database
            // is our driver.
            OleDbConnection driverConnection = new OleDbConnection(ConfigurationManager.ConnectionStrings["MSAccess"].ConnectionString);
            _classifConnection = new OleDbConnection(ConfigurationManager.ConnectionStrings["MSAccess"].ConnectionString);
            _dbConn = new SqlConnection(ConfigurationManager.ConnectionStrings["SQLServer"].ConnectionString);

            Console.WriteLine("Processing OKS database: " + (ConfigurationManager.ConnectionStrings["MSAccess"].ConnectionString));
            if (bCommit)
            {
                Console.WriteLine("Commiting Changes.");
            }
            Console.WriteLine();

            try
            {
                driverConnection.Open();
                _classifConnection.Open();
                _dbConn.Open();

                OleDbCommand cmdProfileOutput = driverConnection.CreateCommand();
                cmdProfileOutput.CommandText = "SELECT * FROM PROFILE_OUTPUT ORDER BY BB_BBID";

                using (OleDbDataReader drProfileOuput = cmdProfileOutput.ExecuteReader())
                {
                    while (drProfileOuput.Read())
                    {
                        bool bUpdateCompany = false;
                        iCompanyCount++;
                        int iBBID = Convert.ToInt32(drProfileOuput["BB_BBID"]);
                        WriteLine("Processing BB ID: " + iBBID.ToString());

                        string szDisposition = (string)drProfileOuput["OKS_DISPOSITION"];
                        if (szDisposition.StartsWith("C2") ||
                            szDisposition.StartsWith("C3"))
                        {
                            bUpdateCompany = true;
                        }

                        if (IsCompanyValid(iBBID, null))
                        {

                            if (HasCompanyChanged(iBBID, null))
                            {
                                iHasChangedCount++;
                                WriteLine(" - Previously Changed, Not Updating.");
                            }
                            else
                            {

                                SqlTransaction oTran = _dbConn.BeginTransaction();
                                try
                                {

                                    if (bUpdateCompany)
                                    {
                                        int iPIKSCompanyTransID = OpenPIKSTransaction(iBBID,
                                                                               0,
                                                                              Convert.ToString(drProfileOuput["OKS_RESPONDENT"]),
                                                                              (DateTime)drProfileOuput["OKS_CALL_DATE"],
                                                                               oTran);

                                        DeleteAddresses(drProfileOuput, iBBID, oTran);

                                        // Make sure we process the mailing address first so that
                                        // the default flags are processed correctly.
                                        _iMCityID = UpdateAddress(drProfileOuput, iBBID, "M", oTran);
                                        _iPHCityID = UpdateAddress(drProfileOuput, iBBID, "PH", oTran);

                                        UpdatePhone(iBBID, "P", Convert.ToString(drProfileOuput["OKS_PHONE"]), oTran);
                                        UpdatePhone(iBBID, "F", Convert.ToString(drProfileOuput["OKS_FAX"]), oTran);

                                        UpdateInternet(iBBID, "E", Convert.ToString(drProfileOuput["OKS_Email"]), oTran);
                                        UpdateInternet(iBBID, "W", Convert.ToString(drProfileOuput["OKS_WebSite"]), oTran);

                                        AddSpecie(iBBID, Convert.ToString(drProfileOuput["OKS_Products"]), oTran);

                                        AddClassifications(iBBID, oTran);

                                        if (_iPHCityID > 0)
                                        {
                                            _iListingCityID = _iPHCityID;
                                        }
                                        else if (_iMCityID > 0)
                                        {
                                            _iListingCityID = _iMCityID;
                                        }
                                        else
                                        {
                                            _iListingCityID = -1;
                                        }

                                        UpdateCompany(drProfileOuput, iBBID, _iListingCityID, oTran);

                                        ClosePIKSTransaction(iPIKSCompanyTransID, oTran);


                                        OleDbCommand cmdProfilePersonnel = _classifConnection.CreateCommand();
                                        cmdProfilePersonnel.CommandText = "SELECT * FROM PROFILE_PERSONNEL WHERE BB_BBID=\"" + iBBID.ToString() + "\"";

                                        using (OleDbDataReader drProfilePersonnel = cmdProfilePersonnel.ExecuteReader())
                                        {
                                            while (drProfilePersonnel.Read())
                                            {
                                                int iPersonID = GetPIKSID("Person", oTran);

                                                int iPIKSPersonTransID = OpenPIKSTransaction(0,
                                                                                            iPersonID,
                                                                                            Convert.ToString(drProfileOuput["OKS_RESPONDENT"]),
                                                                                            (DateTime)drProfileOuput["OKS_CALL_DATE"],
                                                                                            oTran);

                                                AddPerson(iPersonID, iPIKSPersonTransID, drProfilePersonnel, oTran);

                                                ClosePIKSTransaction(iPIKSPersonTransID, oTran);
                                            }
                                        }
                                    }


                                    CreateTask(drProfileOuput, iBBID, oTran);

                                    if (bCommit)
                                    {
                                        oTran.Commit();
                                    }
                                    else
                                    {
                                        oTran.Rollback();
                                    }
                                }
                                catch (Exception e)
                                {
                                    oTran.Rollback();

                                    WriteLine(string.Empty);
                                    WriteLine(e.Message);
                                    WriteLine(e.StackTrace);

                                    throw;
                                }
                            }
                        }
                    }
                }
            }
            finally
            {
                driverConnection.Close();
                _classifConnection.Close();
                _dbConn.Close();

                WriteLine(string.Empty);
                WriteLine("            Company Count: " + iCompanyCount.ToString("###,##0"));
                WriteLine(" Previously Changed Count: " + iHasChangedCount.ToString("###,##0"));
                WriteLine("        Companies Updated: " + _iCompanyUpdatedCount.ToString("###,##0"));
                WriteLine("        Addresses Updated: " + _iAddresUpdatedCount.ToString("###,##0"));
                WriteLine("       Addresses Inserted: " + _iAddresInsertedCount.ToString("###,##0"));
                WriteLine("           Emails Updated: " + _iEmailUpdatedCount.ToString("###,##0"));
                WriteLine("          Emails Inserted: " + _iEmailInsertedCount.ToString("###,##0"));
                WriteLine("         Websites Updated: " + _iWebUpdatedCount.ToString("###,##0"));
                WriteLine("        Websites Inserted: " + _iWebInsertedCount.ToString("###,##0"));
                WriteLine("           Phones Updated: " + _iPhoneUpdatedCount.ToString("###,##0"));
                WriteLine("          Phones Inserted: " + _iPhoneInsertedCount.ToString("###,##0"));
                WriteLine("            Faxes Updated: " + _iFaxUpdatedCount.ToString("###,##0"));
                WriteLine("           Faxes Inserted: " + _iFaxInsertedCount.ToString("###,##0"));
                WriteLine(" Classifications Inserted: " + _iClassificationInsertedCount.ToString("###,##0"));
                WriteLine("         Species Inserted: " + _iSpecieInsertedCount.ToString("###,##0"));
                WriteLine("         Persons Inserted: " + _iPersonInsertedCount.ToString("###,##0"));



                WriteLine("Execution Time: " + DateTime.Now.Subtract(dtStart).ToString());

                string szOutputDirectory = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Substring(6);
                string szOutputFile = Path.Combine(szOutputDirectory, "Log.txt");

                using (StreamWriter sw = new StreamWriter(szOutputFile))
                {
                    foreach (string szLine in _lszOutputBuffer)
                    {
                        sw.WriteLine(szLine);
                    }
                }

                szOutputFile = Path.Combine(szOutputDirectory, "Skipped.txt");
                using (StreamWriter sw = new StreamWriter(szOutputFile))
                {
                    foreach (string szLine in _lszSkippedBuffer)
                    {
                        sw.WriteLine(szLine);
                    }
                }

                
            }
            

        }

        private const string SQL_COMPANY_UPDATE = "UPDATE Company SET comp_Name=@Name, comp_PRCorrTradestyle=@Name, comp_PRBookTradestyle=@Name, comp_PRTradestyle1=@Name, comp_PRLegalName=@LegalName, comp_PRListingCityID=ISNULL(@ListingCityID, comp_PRListingCityID), comp_PRListingStatus='L', comp_UpdatedBy=@UpdatedBy, comp_UpdatedDate=@UpdatedDate WHERE comp_CompanyID=@CompanyID";
        protected void UpdateCompany(OleDbDataReader drProfileOuput, int iCompanyID, int iListingCityID, SqlTransaction oTran)
        {
            SqlCommand cmdCompanyUpdate = _dbConn.CreateCommand();
            cmdCompanyUpdate.CommandText = SQL_COMPANY_UPDATE;
            cmdCompanyUpdate.Transaction = oTran;
            cmdCompanyUpdate.Parameters.AddWithValue("Name", drProfileOuput["OKS_CompName"]);

            if ((drProfileOuput["OKS_CompName_Legal"] != DBNull.Value) &&
                (Convert.ToString(drProfileOuput["OKS_CompName"]) != Convert.ToString(drProfileOuput["OKS_CompName_Legal"])))
            {
                //WriteLine(" - Updating Legal Name");
                cmdCompanyUpdate.Parameters.AddWithValue("LegalName", drProfileOuput["OKS_CompName_Legal"]);
            }
            else
            {
                cmdCompanyUpdate.Parameters.AddWithValue("LegalName", DBNull.Value);
            }

            if (iListingCityID > 0)
            {
                cmdCompanyUpdate.Parameters.AddWithValue("ListingCityID", iListingCityID);
            }
            else
            {
                cmdCompanyUpdate.Parameters.AddWithValue("ListingCityID", DBNull.Value);
            }


            cmdCompanyUpdate.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdCompanyUpdate.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdCompanyUpdate.Parameters.AddWithValue("CompanyID", iCompanyID);
            cmdCompanyUpdate.ExecuteNonQuery();

            _iCompanyUpdatedCount++;
        }

        private const string SQL_PHONE_SELECT = "SELECT phon_PhoneID FROM Phone WHERE phon_CompanyID=@CompanyID AND phon_PersonID IS NULL AND phon_Type=@Type";
        private const string SQL_PHONE_UPDATE = "UPDATE Phone SET Phon_AreaCode=@AreaCode, Phon_Number=@Number, phon_PRPublish=@PRPublish, phon_Default=@Default, Phon_UpdatedBy=@UpdatedBy, Phon_UpdatedDate=@UpdatedDate WHERE Phon_PhoneId = @PhoneID";
        private const string SQL_PHONE_INSERT = "INSERT INTO Phone (phon_PhoneID, phon_CompanyID, phon_Type, phon_PRDescription, Phon_AreaCode, Phon_Number, Phon_CountryCode, phon_PRPublish, phon_Default, Phon_CreatedBy, Phon_CreatedDate, Phon_UpdatedBy, Phon_UpdatedDate, Phon_Timestamp) " +
                                                           "VALUES (@PhoneID, @CompanyID, @Type, @Description, @AreaCode, @Number, @CountryCode, @PRPublish, @Default, @UpdatedBy, @UpdatedDate, @UpdatedBy, @UpdatedDate, @Timestamp)";

        protected void UpdatePhone(int iCompanyID, string szType, string szOKSValue, SqlTransaction oTran)
        {

            if (string.IsNullOrEmpty(szOKSValue)) 
            {
                return;
            }

            if (szOKSValue.Length != 10)
            {
                WriteLine(" - Invalid Phone Number: " + szType + " " + szOKSValue);
                return;
            }

            string szAreaCode = szOKSValue.Substring(0, 3);
            string szPhoneNumber = szOKSValue.Substring(3, 3) + "-" + szOKSValue.Substring(6, 4);

            // First we need to see if we have an existing record.
            SqlCommand cmdPhone = _dbConn.CreateCommand();
            cmdPhone.CommandText = SQL_PHONE_SELECT;
            cmdPhone.Transaction = oTran;
            cmdPhone.Parameters.AddWithValue("CompanyID", iCompanyID);
            cmdPhone.Parameters.AddWithValue("Type", szType);

            int iPhoneID = 0;
            object oPhoneID = cmdPhone.ExecuteScalar();
            if (oPhoneID != null) {
                iPhoneID = (int)oPhoneID;
            }

            if (iPhoneID > 0)
            {
                SqlCommand cmdPhoneUpdate = _dbConn.CreateCommand();
                cmdPhoneUpdate.CommandText = SQL_PHONE_UPDATE;
                cmdPhoneUpdate.Transaction = oTran;
                cmdPhoneUpdate.Parameters.AddWithValue("AreaCode", szAreaCode);
                cmdPhoneUpdate.Parameters.AddWithValue("Number", szPhoneNumber);
                cmdPhoneUpdate.Parameters.AddWithValue("PRPublish", "Y");
                cmdPhoneUpdate.Parameters.AddWithValue("Default", "Y");
                cmdPhoneUpdate.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
                cmdPhoneUpdate.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
                cmdPhoneUpdate.Parameters.AddWithValue("PhoneID", iPhoneID);
                cmdPhoneUpdate.ExecuteNonQuery();

                if (szType == "P")
                {
                    _iPhoneUpdatedCount++;
                }
                else
                {
                    _iFaxUpdatedCount++;
                }
            }
            else
            {
                iPhoneID = GetPIKSID("Phone", oTran);

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
                    cmdPhoneInsert.Parameters.AddWithValue("Description", "Fax");
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

                if (szType == "P")
                {
                    _iPhoneInsertedCount++;
                }
                else
                {
                    _iFaxInsertedCount++;
                }

            }
        }

        private const string SQL_ADDRESS_DELETE = "DELETE FROM Address WHERE addr_AddressID IN (SELECT adli_AddressID FROM Address_Link WHERE adli_CompanyID=@CompanyID)";
        private const string SQL_ADDRESSLINK_DELETE = "DELETE FROM Address_Link WHERE adli_CompanyID=@CompanyID";

        protected void DeleteAddresses(OleDbDataReader drProfileOuput, int iCompanyID, SqlTransaction oTran)
        {
            string szPhysicalCity = Convert.ToString(drProfileOuput["OKS_Physical_City"]);
            string szMailingCity = Convert.ToString(drProfileOuput["OKS_Mailing_City"]);
            
            // If we have either address, delete them both.
            if ((!string.IsNullOrEmpty(szPhysicalCity)) ||
                (!string.IsNullOrEmpty(szMailingCity)))
            {
                //WriteLine(" - Deleting Addresses");

                SqlCommand cmdDeleteAddress = _dbConn.CreateCommand();
                cmdDeleteAddress.CommandText = SQL_ADDRESS_DELETE;
                cmdDeleteAddress.Transaction = oTran;
                cmdDeleteAddress.Parameters.AddWithValue("CompanyID", iCompanyID);
                cmdDeleteAddress.ExecuteNonQuery();

                SqlCommand cmdDeleteAddressLink = _dbConn.CreateCommand();
                cmdDeleteAddressLink.CommandText = SQL_ADDRESSLINK_DELETE;
                cmdDeleteAddressLink.Transaction = oTran;
                cmdDeleteAddressLink.Parameters.AddWithValue("CompanyID", iCompanyID);
                cmdDeleteAddressLink.ExecuteNonQuery();
            
            }
        }

        protected const string SQL_ADDRESS_SELECT =
            "SELECT addr_addressID " +
              "FROM Address " +
                   "INNER JOIN Address_link ON addr_addressID = adli_addressID " +
             "WHERE adli_type=@Type AND adli_companyID=@CompanyID";

        private const string SQL_ADDRESS_UPDATE = "UPDATE Address SET Addr_Address1=@Address1, Addr_Address2=@Address2, addr_PRCityId=@PRCityID, Addr_PostCode=@PostCode, addr_PRPublish=@PRPublish, addr_UpdatedBy=@UpdatedBy, addr_UpdatedDate=@UpdatedDate WHERE addr_AddressId = @AddressID";
        private const string SQL_ADDRESS_INSERT = "INSERT INTO Address (Addr_AddressId, Addr_Address1, Addr_Address2, Addr_PostCode, addr_PRCityId, addr_PRPublish, Addr_CreatedBy, Addr_CreatedDate, Addr_UpdatedBy, Addr_UpdatedDate, Addr_TimeStamp) VALUES (@AddressId, @Address1, @Address2, @PostCode, @PRCityId, @PRPublish, @CreatedBy, @CreatedDate, @UpdatedBy, @UpdatedDate, @TimeStamp)";
        private const string SQL_ADDRESSLINK_INSERT = "INSERT INTO Address_Link (AdLi_AddressLinkId, AdLi_AddressId, AdLi_CompanyID, AdLi_Type, adli_PRDefaultMailing, adli_PRDefaultShipping, adli_PRDefaultTax, adli_PRDefaultTES, adli_PRDefaultJeopardy, adli_PRDefaultListing, adli_PRDefaultBilling, adLi_CreatedBy, AdLi_CreatedDate, AdLi_UpdatedBy, AdLi_UpdatedDate, AdLi_TimeStamp) VALUES (@AddressLinkId, @AddressId, @CompanyID, @Type, @PRDefaultMailing, @PRDefaultShipping, @PRDefaultTax, @PRDefaultTES, @PRDefaultJeopardy, @PRDefaultListing, @PRDefaultBilling, @CreatedBy, @CreatedDate, @UpdatedBy, @UpdatedDate, @TimeStamp)";
        private const string SQL_ADDRESSLINK_UPDATE = "UPDATE Address_Link SET adli_PRDefaultMailing = @PRDefaultMailing, adli_PRDefaultShipping = @PRDefaultShipping, adli_PRDefaultTax = @PRDefaultTax, adli_PRDefaultTES = @PRDefaultTES, adli_PRDefaultJeopardy = @PRDefaultJeopardy, adli_PRDefaultListing = @PRDefaultListing, adli_PRDefaultBilling = @PRDefaultBilling, adli_UpdatedBy=@UpdatedBy, adli_UpdatedDate=@UpdatedDate WHERE adli_AddressID=@AddressID";

        protected int UpdateAddress(OleDbDataReader drProfileOuput, int iCompanyID, string szType, SqlTransaction oTran)
        {
            string szStreet1 = null;
            string szStreet2 = null;
            string szCity = null;
            string szState = null;
            string szPostal = null;

            if (szType == "PH")
            {
                szStreet1 = Convert.ToString(drProfileOuput["OKS_Physical_Address_Primary"]);
                szStreet2 = Convert.ToString(drProfileOuput["OKS_Physical_Address_Secondary"]);
                szCity = Convert.ToString(drProfileOuput["OKS_Physical_City"]);
                szState = Convert.ToString(drProfileOuput["OKS_Physical_State_Full"]);
                szPostal = Convert.ToString(drProfileOuput["OKS_Physical_Zipcode"]);
            }
            else
            {
                szStreet1 = Convert.ToString(drProfileOuput["OKS_Mailing_Address_Primary"]);
                szStreet2 = Convert.ToString(drProfileOuput["OKS_Mailing_Address_Secondary"]);
                szCity = Convert.ToString(drProfileOuput["OKS_Mailing_City"]);
                szState = Convert.ToString(drProfileOuput["OKS_Mailing_State_Full"]);
                szPostal = Convert.ToString(drProfileOuput["OKS_Mailing_Zipcode"]);
            }

            if ((string.IsNullOrEmpty(szStreet1)) &&
                (string.IsNullOrEmpty(szStreet2)) &&
                (string.IsNullOrEmpty(szCity)) &&
                (string.IsNullOrEmpty(szState)) &&
                (string.IsNullOrEmpty(szPostal))) {
                return -1;
            }


            // We need to translate our City/State/Country into
            // a CityID
            int iCityID = ProcessCity(szCity, szState, oTran);


            // Determine if this company already has an address
            // with the default flags set.
            int iDefaultAddressID = GetAddressIDForDefault(iCompanyID, oTran);


            // We need to see if we have an existing record.
            SqlCommand cmdAddress = _dbConn.CreateCommand();
            cmdAddress.CommandText = SQL_ADDRESS_SELECT;
            cmdAddress.Transaction = oTran;
            cmdAddress.Parameters.AddWithValue("CompanyID", iCompanyID);
            cmdAddress.Parameters.AddWithValue("Type", szType);

            int iAddressID = 0;
            object oAddressID = cmdAddress.ExecuteScalar();
            if (oAddressID != null)
            {
                iAddressID = (int)oAddressID;
            }

            if (iAddressID > 0)
            {
                SqlCommand cmdAddressUpdate = _dbConn.CreateCommand();
                cmdAddressUpdate.CommandText = SQL_ADDRESS_UPDATE;
                cmdAddressUpdate.Transaction = oTran;
                cmdAddressUpdate.Parameters.AddWithValue("Address1", szStreet1);

                if (string.IsNullOrEmpty(szStreet2))
                {
                    cmdAddressUpdate.Parameters.AddWithValue("Address2", DBNull.Value);
                }
                else
                {
                    cmdAddressUpdate.Parameters.AddWithValue("Address2", szStreet2);
                }
                cmdAddressUpdate.Parameters.AddWithValue("PRCityID", iCityID);
                cmdAddressUpdate.Parameters.AddWithValue("PostCode", szPostal);
                cmdAddressUpdate.Parameters.AddWithValue("PRPublish", "Y");
                cmdAddressUpdate.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
                cmdAddressUpdate.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
                cmdAddressUpdate.Parameters.AddWithValue("AddressID", iAddressID);
                cmdAddressUpdate.ExecuteNonQuery();

                // If this address already has the default billing flag set,
                // then set all of the defaults.  A previous import routine did 
                // not set these correctly.  
                if (iAddressID == iDefaultAddressID) {
 
                    SqlCommand cmdAddressLinkUpdate = _dbConn.CreateCommand();
                    cmdAddressLinkUpdate.CommandText = SQL_ADDRESSLINK_UPDATE;
                    cmdAddressLinkUpdate.Transaction = oTran;
                    cmdAddressLinkUpdate.Parameters.AddWithValue("PRDefaultMailing", "Y");
                    cmdAddressLinkUpdate.Parameters.AddWithValue("PRDefaultShipping", "Y");
                    cmdAddressLinkUpdate.Parameters.AddWithValue("PRDefaultTax", "Y");
                    cmdAddressLinkUpdate.Parameters.AddWithValue("PRDefaultTES", "Y");
                    cmdAddressLinkUpdate.Parameters.AddWithValue("PRDefaultJeopardy", "Y");
                    cmdAddressLinkUpdate.Parameters.AddWithValue("PRDefaultListing", "Y");
                    cmdAddressLinkUpdate.Parameters.AddWithValue("PRDefaultBilling", "Y");
                    cmdAddressLinkUpdate.Parameters.AddWithValue("AddressID", iAddressID);
                    cmdAddressLinkUpdate.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
                    cmdAddressLinkUpdate.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
                    cmdAddressLinkUpdate.ExecuteNonQuery();
                }

                _iAddresUpdatedCount++;
            } else {
                iAddressID = GetPIKSID("Address", oTran);

                SqlCommand cmdAddressInsert = _dbConn.CreateCommand();
                cmdAddressInsert.CommandText = SQL_ADDRESS_INSERT;
                cmdAddressInsert.Transaction = oTran;
                cmdAddressInsert.Parameters.AddWithValue("AddressID", iAddressID);
                cmdAddressInsert.Parameters.AddWithValue("Address1", szStreet1);
                if (string.IsNullOrEmpty(szStreet2))
                {
                    cmdAddressInsert.Parameters.AddWithValue("Address2", DBNull.Value);
                }
                else
                {
                    cmdAddressInsert.Parameters.AddWithValue("Address2", szStreet2);
                }
                cmdAddressInsert.Parameters.AddWithValue("PRCityID", iCityID);
                cmdAddressInsert.Parameters.AddWithValue("PostCode", szPostal);
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
                cmdAddressLinkInsert.Parameters.AddWithValue("Type", szType);

                // If the company doesn't have an address with the default flags
                // set, then set them on this one.
                if (iDefaultAddressID == -1) {
                    cmdAddressLinkInsert.Parameters.AddWithValue("PRDefaultMailing", "Y");
                    cmdAddressLinkInsert.Parameters.AddWithValue("PRDefaultShipping", "Y");
                    cmdAddressLinkInsert.Parameters.AddWithValue("PRDefaultTax", "Y");
                    cmdAddressLinkInsert.Parameters.AddWithValue("PRDefaultTES", "Y");
                    cmdAddressLinkInsert.Parameters.AddWithValue("PRDefaultJeopardy", "Y");
                    cmdAddressLinkInsert.Parameters.AddWithValue("PRDefaultListing", "Y");
                    cmdAddressLinkInsert.Parameters.AddWithValue("PRDefaultBilling", "Y");
                } else {
                    cmdAddressLinkInsert.Parameters.AddWithValue("PRDefaultMailing", DBNull.Value);
                    cmdAddressLinkInsert.Parameters.AddWithValue("PRDefaultShipping", DBNull.Value);
                    cmdAddressLinkInsert.Parameters.AddWithValue("PRDefaultTax", DBNull.Value);
                    cmdAddressLinkInsert.Parameters.AddWithValue("PRDefaultTES", DBNull.Value);
                    cmdAddressLinkInsert.Parameters.AddWithValue("PRDefaultJeopardy", DBNull.Value);
                    cmdAddressLinkInsert.Parameters.AddWithValue("PRDefaultListing", DBNull.Value);
                    cmdAddressLinkInsert.Parameters.AddWithValue("PRDefaultBilling", DBNull.Value);
                }
                
                cmdAddressLinkInsert.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
                cmdAddressLinkInsert.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
                cmdAddressLinkInsert.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
                cmdAddressLinkInsert.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
                cmdAddressLinkInsert.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
                cmdAddressLinkInsert.ExecuteNonQuery();

                _iAddresInsertedCount++;
            }

            return iCityID;
        }

        private const string SQL_INTERNET_SELECT = "SELECT Emai_EmailId FROM Email WHERE Emai_CompanyID=@CompanyID AND Emai_PersonID IS NULL AND Emai_Type=@Type";
        private const string SQL_INTERNET_UPDATE = "UPDATE Email SET Emai_EmailAddress=@Email, emai_PRWebAddress=@WebAddress, emai_PRPublish=@PRPublish, emai_PRDefault=@Default, emai_UpdatedBy=@UpdatedBy, emai_UpdatedDate=@UpdatedDate WHERE Emai_EmailId = @InternetID";
        private const string SQL_INTERNET_INSERT = "INSERT INTO Email (Emai_EmailId, Emai_CompanyID, Emai_Type, Emai_PRDescription, Emai_EmailAddress, emai_PRWebAddress, Emai_PRPublish, Emai_PRDefault, Emai_CreatedBy, Emai_CreatedDate, Emai_UpdatedBy, Emai_UpdatedDate, Emai_Timestamp) " +
                                                   "VALUES (@InternetID, @CompanyID, @Type, @Description, @Email, @WebAddress, @PRPublish, @Default, @UpdatedBy, @UpdatedDate, @UpdatedBy, @UpdatedDate, @Timestamp)";

        protected void UpdateInternet(int iCompanyID, string szType, string szOKSValue, SqlTransaction oTran)
        {

            if (string.IsNullOrEmpty(szOKSValue))
            {
                return;
            }

            object szEmail = DBNull.Value;
            object szWebAddress = DBNull.Value;

            if (szType == "E")
            {
                szEmail = szOKSValue;
            }
            else
            {
                szWebAddress = szOKSValue;
            }


            // First we need to see if we have an existing record.
            SqlCommand cmdInternet = _dbConn.CreateCommand();
            cmdInternet.CommandText = SQL_INTERNET_SELECT;
            cmdInternet.Transaction = oTran;
            cmdInternet.Parameters.AddWithValue("CompanyID", iCompanyID);
            cmdInternet.Parameters.AddWithValue("Type", szType);

            int iInternetID = 0;
            object oInternetID = cmdInternet.ExecuteScalar();
            if (oInternetID != null)
            {
                iInternetID = (int)oInternetID;
            }

            if (iInternetID > 0)
            {
                SqlCommand cmdInternetUpdate = _dbConn.CreateCommand();
                cmdInternetUpdate.CommandText = SQL_INTERNET_UPDATE;
                cmdInternetUpdate.Transaction = oTran;
                cmdInternetUpdate.Parameters.AddWithValue("Email", szEmail);
                cmdInternetUpdate.Parameters.AddWithValue("WebAddress", szWebAddress);
                cmdInternetUpdate.Parameters.AddWithValue("PRPublish", "Y");
                cmdInternetUpdate.Parameters.AddWithValue("Default", "Y");
                cmdInternetUpdate.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
                cmdInternetUpdate.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
                cmdInternetUpdate.Parameters.AddWithValue("InternetID", iInternetID);
                cmdInternetUpdate.ExecuteNonQuery();

                if (szType == "E")
                {
                    _iEmailUpdatedCount++;
                }
                else
                {
                    _iWebUpdatedCount++;
                }
            }
            else
            {
                iInternetID = GetPIKSID("Email", oTran);

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

                if (szType == "E")
                {
                    _iEmailInsertedCount++;
                }
                else
                {
                    _iWebInsertedCount++;
                }

            }
        }

        protected void AddSpecie(int iCompanyID, string szOKSValue, SqlTransaction oTran)
        {
            if (string.IsNullOrEmpty(szOKSValue))
            {
                return;
            }

            if ((szOKSValue == "S") || (szOKSValue == "B"))
            {
                AddSpecie(iCompanyID, 1, oTran);
            }

            if ((szOKSValue == "H") || (szOKSValue == "B"))
            {
                AddSpecie(iCompanyID, 75, oTran);
            }
        }

        private const string SQL_PRCOMPANYSPECIE_INSERT = "INSERT INTO PRCompanySpecie (prcspc_CompanySpecieID, prcspc_CompanyID, prcspc_SpecieID, prcspc_CreatedBy, prcspc_CreatedDate, prcspc_UpdatedBy, prcspc_UpdatedDate, prcspc_Timestamp) " +
            "VALUES (@CompanySpecieID, @CompanyID, @SpecieID, @UpdatedBy, @UpdatedDate, @UpdatedBy, @UpdatedDate, @Timestamp)";
        protected void AddSpecie(int iCompanyID, int iSpecieID, SqlTransaction oTran)
        {
            int iCompanySpecieID = GetPIKSID("PRCompanySpecie", oTran);

            SqlCommand cmdCompanySpecieInsert = _dbConn.CreateCommand();
            cmdCompanySpecieInsert.CommandText = SQL_PRCOMPANYSPECIE_INSERT;
            cmdCompanySpecieInsert.Transaction = oTran;
            cmdCompanySpecieInsert.Parameters.AddWithValue("CompanySpecieID", iCompanySpecieID);
            cmdCompanySpecieInsert.Parameters.AddWithValue("CompanyID", iCompanyID);
            cmdCompanySpecieInsert.Parameters.AddWithValue("SpecieID", iSpecieID);
            cmdCompanySpecieInsert.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
            cmdCompanySpecieInsert.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
            cmdCompanySpecieInsert.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdCompanySpecieInsert.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdCompanySpecieInsert.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
            cmdCompanySpecieInsert.ExecuteNonQuery();

            _iSpecieInsertedCount++;
        }


        protected void AddClassifications(int iCompanyID, SqlTransaction oTran)
        {
            OleDbCommand cmdClassification = _classifConnection.CreateCommand();
            cmdClassification.CommandText = "SELECT OKS_CATEGORY FROM PROFILE_CLASSIFICATION WHERE BB_BBID = \"" + iCompanyID.ToString() + "\"";

            using (OleDbDataReader drClassification = cmdClassification.ExecuteReader())
            {
                while (drClassification.Read())
                {
                    if (Convert.ToString(drClassification[0]) != null)
                    {
                        AddClassification(iCompanyID, Convert.ToString(drClassification[0]), oTran);
                    }
                }
            }
        }

        private const string SQL_PRCOMPANY_CLASSIFICATION_INSERT =
            "INSERT INTO PRCompanyClassification (prc2_CompanyClassificationId, prc2_CompanyId, prc2_ClassificationId, prc2_CreatedBy, prc2_CreatedDate, prc2_UpdatedBy, prc2_UpdatedDate, prc2_Timestamp) " +
            "VALUES (@CompanyClassificationId, @CompanyId, @ClassificationId, @UpdatedBy, @UpdatedDate, @UpdatedBy, @UpdatedDate, @Timestamp)";

        Hashtable _htClassification = null;
        protected void AddClassification(int iCompanyID, string szClassification, SqlTransaction oTran)
        {
            if (_htClassification == null)
            {
                _htClassification = new Hashtable();
                _htClassification.Add("seller", 2181);
                _htClassification.Add("mill (seller)", 2182);
                _htClassification.Add("exporter (seller)", 2183);
                _htClassification.Add("buyer", 2184);
                _htClassification.Add("office wholesaler (buyer)", 2185);
                _htClassification.Add("secondary manufacturer (buyer)", 2186);
                _htClassification.Add("importer (buyer)", 2187);
                _htClassification.Add("co-op (buyer)", 2188);
                _htClassification.Add("co-op  (buyer)", 2188);
                _htClassification.Add("stocking wholesaler/distributor (buyer)", 2189);
                _htClassification.Add("retail lumber yard (buyer)", 2190);
                _htClassification.Add("home center (buyer)", 2191);
                _htClassification.Add("pro dealer (buyer)", 2192);
                _htClassification.Add("supply chain services", 2193);
                _htClassification.Add("reload center (supply chain service)", 2194);
                _htClassification.Add("other supply/service (supply chain service)", 2195);
                _htClassification.Add("transportation (supply chain service)", 2196);
            }

            int iCompanyClassificationID = GetPIKSID("PRCompanyClassification", oTran);

            if (!_htClassification.ContainsKey(szClassification.ToLower()))
            {
                WriteLine(" - Unable to find classifiation:" + szClassification.ToLower());
                return;
            }

            int iClassificationID = (int)_htClassification[szClassification.ToLower()];

            SqlCommand cmdCompanyClassificationInsert = _dbConn.CreateCommand();
            cmdCompanyClassificationInsert.CommandText = SQL_PRCOMPANY_CLASSIFICATION_INSERT;
            cmdCompanyClassificationInsert.Transaction = oTran;
            cmdCompanyClassificationInsert.Parameters.AddWithValue("CompanyClassificationId", iCompanyClassificationID);
            cmdCompanyClassificationInsert.Parameters.AddWithValue("CompanyID", iCompanyID);
            cmdCompanyClassificationInsert.Parameters.AddWithValue("ClassificationId", iClassificationID);
            cmdCompanyClassificationInsert.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
            cmdCompanyClassificationInsert.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
            cmdCompanyClassificationInsert.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdCompanyClassificationInsert.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdCompanyClassificationInsert.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
            cmdCompanyClassificationInsert.ExecuteNonQuery();

            _iClassificationInsertedCount++;

        }

        private const string SQL_PERSON_INSERT =
            "INSERT INTO Person (Pers_PersonId, Pers_FirstName, Pers_LastName, Pers_CreatedBy, Pers_CreatedDate, Pers_UpdatedBy, Pers_UpdatedDate, Pers_Timestamp) " +
            "VALUES (@PersonId, @FirstName, @LastName, @UpdatedBy, @UpdatedDate, @UpdatedBy, @UpdatedDate, @Timestamp)";

        private const string SQL_PERSON_LINK_INSERT =
            "INSERT INTO Person_Link (PeLi_PersonLinkId, PeLi_PersonId, PeLi_CompanyID, peli_PROwnershipRole, peli_PRTitle, peli_PRTitleCode, peli_PRStatus, peli_PREBBPublish, peli_PRBRPublish, peli_PRSubmitTES, peli_PRUpdateCL, peli_PRUseServiceUnits, peli_PRUseSpecialServices, peli_PRReceivesTrainingEmail, peli_PRReceivesPromoEmail, peli_PRReceivesCreditSheetReport, peli_PREditListing, peli_CreatedBy, peli_CreatedDate, peli_UpdatedBy, peli_UpdatedDate, peli_Timestamp) " +
            "VALUES (@PersonLinkId, @PersonId, @CompanyID, 'RCR', @PRTitle, 'OTHR', '1', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', @UpdatedBy, @UpdatedDate, @UpdatedBy, @UpdatedDate, @Timestamp)"; 

        protected void AddPerson(int iPersonId, int iPIKSTransactionID, OleDbDataReader drProfilePersonnel, SqlTransaction oTran) {

            string szFirstName = GetCamelCase(Convert.ToString(drProfilePersonnel["OKS_CONTACT_FIRST"]));
            string szLastName = GetCamelCase(Convert.ToString(drProfilePersonnel["OKS_CONTACT_LAST"]));
            string szTitle = GetCamelCase(Convert.ToString(drProfilePersonnel["OKS_CONTACT_TITLE"]));

            if (string.IsNullOrEmpty(szFirstName))
            {
                WriteLine(" - Found person without first name.");
            }

            if (string.IsNullOrEmpty(szLastName))
            {
                WriteLine(" - Found person without last name.");
            }
            
            SqlCommand cmdPersonInsert = _dbConn.CreateCommand();
            cmdPersonInsert.CommandText = SQL_PERSON_INSERT;
            cmdPersonInsert.Transaction = oTran;
            cmdPersonInsert.Parameters.AddWithValue("PersonId", iPersonId);
            cmdPersonInsert.Parameters.AddWithValue("FirstName", szFirstName);
            cmdPersonInsert.Parameters.AddWithValue("LastName", szLastName);
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
            cmdPersonLinkInsert.Parameters.AddWithValue("CompanyID", Convert.ToInt32(drProfilePersonnel["BB_BBID"]));
            cmdPersonLinkInsert.Parameters.AddWithValue("PRTitle", szTitle);
            cmdPersonLinkInsert.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
            cmdPersonLinkInsert.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
            cmdPersonLinkInsert.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdPersonLinkInsert.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdPersonLinkInsert.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
            cmdPersonLinkInsert.ExecuteNonQuery();


            string szNewValue = szFirstName + " " + szLastName + " Created.";

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

            _iPersonInsertedCount++;
        }


        protected void CreateTask(OleDbDataReader drProfileOuput, int iBBID, SqlTransaction oTran)
        {
            string szStatus = "Closed";
            
            StringBuilder sbTaskMsg = new StringBuilder();

            string szDisposition = (string)drProfileOuput["OKS_DISPOSITION"];
            if (szDisposition.StartsWith("C2") ||
                szDisposition.StartsWith("C3"))
            {
                sbTaskMsg.Append("Successful contact by OKS." + Environment.NewLine);
            }
            else
            {
                sbTaskMsg.Append("Contact attempted and unsuccessful by OKS.  Call outcome: " + szDisposition + Environment.NewLine);
            }


            if (!String.IsNullOrEmpty(Convert.ToString(drProfileOuput["OKS_RED_BOOK_USAGE"]))) {
                sbTaskMsg.Append("Redbook Usage: " + Convert.ToString(drProfileOuput["OKS_RED_BOOK_USAGE"]) + Environment.NewLine);
            }

            if (!String.IsNullOrEmpty(Convert.ToString(drProfileOuput["OKS_CREDIT_DECISIONS_COMPANY"])))
            {
                sbTaskMsg.Append("Credit Decisions Company: " + Convert.ToString(drProfileOuput["OKS_CREDIT_DECISIONS_COMPANY"]) + Environment.NewLine);
            }

            if (Convert.ToString(drProfileOuput["OKS_Respondent_Contact_Request"]) == "Y") {
                sbTaskMsg.Append("Company would like a followup call." + Environment.NewLine);
                szStatus = "Pending";
            }

            if (sbTaskMsg.Length == 0) {
                return;
            }

            sbTaskMsg.Append(Environment.NewLine);
            sbTaskMsg.Append("Contact Name: " + Convert.ToString(drProfileOuput["OKS_RESPONDENT"]) + Environment.NewLine);
            sbTaskMsg.Append("Title: " + Convert.ToString(drProfileOuput["OKS_RESPONDENT_TITLE"]) + Environment.NewLine);


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
            cmdCreateTask.Parameters.AddWithValue("RelatedCompanyID", iBBID);
            cmdCreateTask.ExecuteNonQuery();
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

        protected int OpenPIKSTransaction(int iCompanyID, int iPersonID, string szRespondentName, DateTime dtCallDate, SqlTransaction oTran)
        {
            SqlCommand sqlOpenPIKSTransaction = _dbConn.CreateCommand();
            sqlOpenPIKSTransaction.Transaction = oTran;
            sqlOpenPIKSTransaction.CommandText = "usp_CreateTransaction";
            sqlOpenPIKSTransaction.CommandType = CommandType.StoredProcedure;
            sqlOpenPIKSTransaction.Parameters.AddWithValue("UserId", UPDATED_BY);

            if (iCompanyID > 0)
            {
                sqlOpenPIKSTransaction.Parameters.AddWithValue("prtx_CompanyId", iCompanyID);
            }

            if (iPersonID > 0)
            {
                sqlOpenPIKSTransaction.Parameters.AddWithValue("prtx_PersonId", iPersonID);
            }

            sqlOpenPIKSTransaction.Parameters.AddWithValue("prtx_Explanation", "Data changes resulting from OKS call campaign.");
            sqlOpenPIKSTransaction.Parameters.AddWithValue("prtx_AuthorizedInfo ", szRespondentName);
            sqlOpenPIKSTransaction.Parameters.AddWithValue("prtx_EffectiveDate", dtCallDate);

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


        private const string SQL_IS_CITY_EXIST = "SELECT prci_CityID FROM vPRLocation WHERE dbo.ufn_GetLowerAlpha(prci_City) = dbo.ufn_GetLowerAlpha(@City) AND prst_State = @State;";
        protected int ProcessCity(string szCity, string szState, SqlTransaction oTran)
        {
            int iCityID = 0;


            iCityID = SearchForCity(szCity, szState, oTran);

            // If we found an ID, then return it.
            if (iCityID > 0)
            {
                return iCityID;
            }

            string szTranslatedCity = TranslateCityName(szCity);
            if (!string.IsNullOrEmpty(szTranslatedCity))
            {
                iCityID = SearchForCity(szTranslatedCity, szState, oTran);
                if (iCityID > 0)
                {
                    return iCityID;
                }
            }


            WriteLine(" - Unable to Resolve City, State: " + szCity + ", " + szState);

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


        protected string TranslateCityName(string szCity)
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


            return null;
        }

        private const string SQL_ADDRESS_SELECT_DEFAULT = "SELECT adli_AddressID FROM Address_Link WHERE adli_CompanyID=@CompanyID AND adli_PRDefaultBilling = 'Y'";
        protected int GetAddressIDForDefault(int iCompanyID, SqlTransaction oTran) {

            // First we need to check to see if the city already exists.
            SqlCommand sqlDefaultAddress = _dbConn.CreateCommand();
            sqlDefaultAddress.Transaction = oTran;
            sqlDefaultAddress.Parameters.Add(new SqlParameter("CompanyID", iCompanyID));
            sqlDefaultAddress.CommandText = SQL_ADDRESS_SELECT_DEFAULT;
            object oAddressID = sqlDefaultAddress.ExecuteScalar();

            if (oAddressID == null)
            {
                return -1;
            }

            return Convert.ToInt32(oAddressID);
        }
        
        protected void WriteLine(string szLine)
        {
            Console.WriteLine(szLine);
            _lszOutputBuffer.Add(szLine);
        }

        protected string GetCamelCase(string szText)
        {
            if (string.IsNullOrEmpty(szText))
            {
                return string.Empty;
            }

            string szTemp = szText.Trim();

            return szTemp.Substring(0, 1) + szTemp.Substring(1, szTemp.Length - 1).ToLower();
        }

        private const string SQL_IS_COMPANY_VALID = "SELECT comp_PRIndustryType, comp_PRListingStatus FROM Company WITH (NOLOCK) WHERE comp_CompanyID=@CompanyID";
        protected bool IsCompanyValid(int iCompanyID, SqlTransaction oTran)
        {
            SqlCommand sqlIsCompanyValid = _dbConn.CreateCommand();
            sqlIsCompanyValid.Transaction = oTran;
            sqlIsCompanyValid.Parameters.Add(new SqlParameter("CompanyID", iCompanyID));
            sqlIsCompanyValid.CommandText = SQL_IS_COMPANY_VALID;

            object oIndustryType;
            object oListingStatus;
            using (SqlDataReader oReader = sqlIsCompanyValid.ExecuteReader(CommandBehavior.Default))
            {
                if (!oReader.Read())
                {
                    WriteLine(" - Unable to find Company in CRM.");
                    _lszSkippedBuffer.Add(iCompanyID.ToString() + "\tNot Found in CRM");
                    return false;
                }

                oIndustryType = oReader[0];
                oListingStatus = oReader[1];
            }

            if (Convert.ToString(oIndustryType) != "L")
            {
                WriteLine(" - Company found, but comp_PRIndustryType != 'L'.  Not updating.");
                _lszSkippedBuffer.Add(iCompanyID.ToString() + "\tNot a Lumber Company");
                return false;
            }

            if (Convert.ToString(oListingStatus) == "L")
            {
                WriteLine(" - Company found, but comp_PRListingStatus == 'L'.  Not updating.");
                _lszSkippedBuffer.Add(iCompanyID.ToString() + "\tAlready Listed");
                return false;
            }


            return true;
        }

        private const string SQL_COMPANY_TRANS_DATE = "SELECT 'x' FROM PRTransaction WITH (NOLOCK) WHERE prtx_CompanyID=@CompanyID AND prtx_CreatedDate > '2009-10-05'";
        protected bool HasCompanyChanged(int iCompanyID, SqlTransaction oTran)
        {
            SqlCommand sqlHasCompanyChanged = _dbConn.CreateCommand();
            sqlHasCompanyChanged.Transaction = oTran;
            sqlHasCompanyChanged.Parameters.Add(new SqlParameter("CompanyID", iCompanyID));
            sqlHasCompanyChanged.CommandText = SQL_COMPANY_TRANS_DATE;

            object oResult = sqlHasCompanyChanged.ExecuteScalar();
            if (oResult == null)
            {
                return false;
            }

            _lszSkippedBuffer.Add(iCompanyID.ToString() + "\tUpdated Since 10/5/2009");
            return true;
        }
    }
}
