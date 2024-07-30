using System;
using System.Configuration;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Data;
using System.Data.SqlClient;

using CommandLine.Utility;

namespace InfoUSAResolveUnknownCity
{
    public class UnknownCityResolver
    {

        protected string _szOutputFile;
        protected string _szInputFile;
        protected SqlConnection _dbConn = null;
        protected int _iTransactionID = -1;

        protected int _iCompanyCount = 0;
        protected int _iNewCityCount = 0;
        protected int _iUpdatedCompanyCount = 0;
        protected int _iUpdatedAddressCount = 0;

        protected int _iListingCityID = 0;

        protected SqlTransaction _oTran;

        protected string szCurrentLine = null;
        protected List<string> _lszOutputBuffer = new List<string>();
        protected List<string> _lszNewCitiesBuffer = new List<string>();


        public void Resolve(string[] args)
        {
            Console.Clear();
            Console.Title = "InfoUSA Resolve Unknown City Utility";
            WriteLine("InfoUSA Resolve Unknown City Utility 1.0");
            WriteLine("Copyright (c) 2009 Produce Reporter Co.");
            WriteLine("All Rights Reserved.");
            WriteLine("  OS Version: " + System.Environment.OSVersion.ToString());
            WriteLine(" CLR Version: " + System.Environment.Version.ToString());
            WriteLine(string.Empty);
            WriteLine(string.Empty);

            _szInputFile = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Substring(6);
            _szInputFile = Path.Combine(_szInputFile, "InfoUSA_ImportedCompanies.txt");

            ResolveUnknownAddresses();
        }

        int _iCompanyID = 0;
        string _szName = null;
        string _szListingCity = null;
        string _szListingState = null;
        string _szPhysicalCity = null;
        string _szPhysicalState = null;

        protected void ResolveUnknownAddresses()
        {
            DateTime dtStart = DateTime.Now;
            string szInputLine = null;

            try
            {
                using (_dbConn = new SqlConnection(ConfigurationManager.ConnectionStrings["SQLServer"].ConnectionString))
                {
                    _dbConn.Open();

                    bool bSkip = true;
                    using (StreamReader srData = new StreamReader(_szInputFile))
                    {
                        while ((szInputLine = srData.ReadLine()) != null)
                        {
                            if (bSkip)
                            {
                                bSkip = false;
                            }
                            else
                            {

                                _iCompanyCount++;
                                string[] aszInputFields = szInputLine.Split('\t');

                                _iCompanyID = Convert.ToInt32(aszInputFields[51]);
                                _szName = aszInputFields[3];
                                _szListingCity = aszInputFields[5];
                                _szListingState = aszInputFields[6];
                                _szPhysicalCity = aszInputFields[11];
                                _szPhysicalState = aszInputFields[12];

                                _oTran = _dbConn.BeginTransaction();
                                try
                                {
                                    ProcessListingCity();
                                    ProcessAddresses();

                                    ClosePIKSTransaction();

                                    _oTran.Commit();
                                    //_oTran.Rollback();
                                }
                                catch
                                {
                                    _oTran.Rollback();
                                    throw;
                                }
                            }
                        }
                    }

                }
            }
            catch (Exception e)
            {
                WriteLine(string.Empty);
                WriteLine(string.Empty);
                Console.ForegroundColor = ConsoleColor.Red;
                WriteLine("An unexpected exception occurred: " + e.Message);
                WriteLine("Terminating execution.");
                Console.ForegroundColor = ConsoleColor.Gray;
                WriteLine(string.Empty);
                WriteLine("Stack Trace: ");
                WriteLine(e.StackTrace);
            }

            WriteLine(string.Empty);
            WriteLine("        Company Count: " + _iCompanyCount.ToString("###,##0"));
            WriteLine("       New City Count: " + _iNewCityCount.ToString("###,##0"));
            WriteLine("Updated Company Count: " + _iUpdatedCompanyCount.ToString("###,##0"));
            WriteLine("Updated Address Count: " + _iUpdatedAddressCount.ToString("###,##0"));
            WriteLine("Execution Time: " + DateTime.Now.Subtract(dtStart).ToString());

            string szOutputDirectory = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Substring(6);
            string szLogFile = Path.Combine(szOutputDirectory, "Log.txt");

            using (StreamWriter sw = new StreamWriter(szLogFile))
            {
                foreach (string szLine in _lszOutputBuffer)
                {
                    sw.WriteLine(szLine);
                }
            }

            string szNewCitiesFile = Path.Combine(szOutputDirectory, "NewCities.txt");

            using (StreamWriter sw = new StreamWriter(szNewCitiesFile))
            {
                foreach (string szLine in _lszNewCitiesBuffer)
                {
                    sw.WriteLine(szLine);
                }
            }
        }

        protected const string SQL_IS_UNKNOWN_LISTING_CITY =
            "SELECT 'x' FROM Company WITH(NOLOCK) WHERE comp_CompanyID=@CompanyID AND comp_PRListingCityID=-1";

        protected const string SQL_UPDATE_COMPANY =
            "UPDATE Company SET comp_PRListingCityID=@CityID, comp_UpdatedBy=-1, comp_UpdatedDate=GETDATE(), comp_TimeStamp=GETDATE() WHERE comp_CompanyID=@CompanyID";

        protected void ProcessListingCity()
        {
            _iListingCityID = 0;

            SqlCommand sqlListingCity = _dbConn.CreateCommand();
            sqlListingCity.Transaction = _oTran;
            sqlListingCity.Parameters.Add(new SqlParameter("CompanyID", _iCompanyID));
            sqlListingCity.CommandText = SQL_IS_UNKNOWN_LISTING_CITY;
            
            object oIsUnknown = sqlListingCity.ExecuteScalar();
            if (oIsUnknown != null)
            {
                //WriteLine(_iCompanyID.ToString() + " Unknown City Found.");
                szCurrentLine = _iCompanyID.ToString() + "||" + _szListingCity + "|" + _szListingState;

                _iListingCityID = ProcessCity(_szListingCity, _szListingState);

                // Update the Company table.
                _iTransactionID = OpenPIKSTransaction();

                SqlCommand sqlUpdateCompany = _dbConn.CreateCommand();
                sqlUpdateCompany.Transaction = _oTran;
                sqlUpdateCompany.Parameters.Add(new SqlParameter("CityID", _iListingCityID));
                sqlUpdateCompany.Parameters.Add(new SqlParameter("CompanyID", _iCompanyID));
                sqlUpdateCompany.CommandText = SQL_UPDATE_COMPANY;
                _iUpdatedCompanyCount++;

                if (sqlUpdateCompany.ExecuteNonQuery() == 0)
                {
                    throw new ApplicationException("Unable to update company: " + _iCompanyID.ToString());
                }

                WriteLine(szCurrentLine);

            }
        }

        protected const string SQL_SELECT_ADDRESSES =
            "SELECT addr_addressID, adli_type " +
              "FROM Address " +
                   "INNER JOIN Address_link ON addr_addressID = adli_addressID " +
             "WHERE addr_PRCityID=-1 " +
               "AND adli_companyID=@CompanyID";

        protected const string SQL_UPDATE_ADDRESS =
            "UPDATE Address SET addr_PRCityID=@CityID, addr_UpdatedBy=-1, addr_UpdatedDate=GETDATE(), addr_TimeStamp=GETDATE() WHERE addr_AddressID=@AddressID";

        public void ProcessAddresses()
        {
            SqlCommand sqlAddresses = _dbConn.CreateCommand();
            sqlAddresses.Transaction = _oTran;
            sqlAddresses.Parameters.Add(new SqlParameter("CompanyID", _iCompanyID));
            sqlAddresses.CommandText = SQL_SELECT_ADDRESSES;

            int iMailingAddressID = 0;
            int iPhysicalAddressID = 0;

            using (SqlDataReader oReader = sqlAddresses.ExecuteReader(CommandBehavior.Default))
            {
                while (oReader.Read())
                {
                    switch (oReader.GetString(1))
                    {
                        case "M":
                            iMailingAddressID = oReader.GetInt32(0);
                            break;

                        case "PH":
                            iPhysicalAddressID = oReader.GetInt32(0);
                            break;
                    }
                }
            }

            if (iMailingAddressID > 0)
            {
                ProcessAddress(iMailingAddressID, "M");
            }

            if (iPhysicalAddressID > 0)
            {
                ProcessAddress(iPhysicalAddressID, "PH");
            }
        }

        protected void ProcessAddress(int iAddressID, string szAddressType)
        {

            int iCityID = 0;



            switch (szAddressType)
            {
                case "PH":
                    szCurrentLine = _iCompanyID.ToString() + "|" + iAddressID.ToString() + "|" + _szPhysicalCity + "|" + _szPhysicalState;
                    if ((_iListingCityID > 0) &&
                        (_szListingCity == _szPhysicalCity) &&
                        (_szListingState == _szPhysicalState)) 
                    {
                        iCityID = _iListingCityID;
                        szCurrentLine += "|" + _iListingCityID.ToString() + "|Using Cached listing City ID|";
                    }
                    else
                    {
                        iCityID = ProcessCity(_szPhysicalCity, _szPhysicalState);
                    }
                    break;

                case "M":
                    szCurrentLine = _iCompanyID.ToString() + "|" + iAddressID.ToString() + "|" + _szListingCity + "|" + _szListingState;
                    if (_iListingCityID > 0)
                    {
                        iCityID = _iListingCityID;
                        szCurrentLine += "|" + _iListingCityID.ToString() + "|Using Cached listing City ID|";
                    }
                    else
                    {
                        iCityID = ProcessCity(_szListingCity, _szListingState);
                    }

                    break;
            }
        
            if (iCityID > 0)
            {
                // Update the Company table.
                _iTransactionID = OpenPIKSTransaction();

                SqlCommand sqlUpdateAddress = _dbConn.CreateCommand();
                sqlUpdateAddress.Transaction = _oTran;
                sqlUpdateAddress.Parameters.Add(new SqlParameter("CityID", iCityID));
                sqlUpdateAddress.Parameters.Add(new SqlParameter("AddressID", iAddressID));
                sqlUpdateAddress.CommandText = SQL_UPDATE_ADDRESS;
                _iUpdatedAddressCount++;

                if (sqlUpdateAddress.ExecuteNonQuery() == 0)
                {
                    throw new ApplicationException("Unable to update address: " + iAddressID.ToString());
                }

                WriteLine(szCurrentLine);
            }

        }


        private const string SQL_IS_CITY_EXIST = "SELECT prci_CityID FROM vPRLocation WHERE dbo.ufn_GetLowerAlpha(prci_City) = dbo.ufn_GetLowerAlpha(@City) AND prst_Abbreviation = @State;";

        private const string SQL_INSERT_CITY =
            "INSERT INTO PRCity (prci_CityID, prci_City, prci_StateID, prci_LumberRatingUserId, prci_LumberInsideSalesRepId, prci_LumberFieldSalesRepId, prci_LumberListingSpecialistId, prci_LumberCustomerServiceId, prci_CreatedBy, prci_CreatedDate, prci_UpdatedBy, prci_UpdatedDate, prci_TimeStamp) " +
            "SELECT @CityID, @City, prst_StateID, 32, 25, 126, 51, 9, -1, GETDATE(), -1, GETDATE(), GETDATE() " +
              "FROM PRState " +
             "WHERE prst_Abbreviation = @State " +
               "AND prst_CountryID = 1";

        protected int ProcessCity(string szCity, string szState)
        {
            int iCityID = 0;


            iCityID = SearchForCity(szCity, szState);

            // If we found an ID, then return it.
            if (iCityID > 0)
            {
                //WriteLine(" - City Found for " + szCity + ", " + szState + ": " + iCityID.ToString());
                szCurrentLine += "|" + iCityID.ToString() + "|Found 1st Pass|";
                return iCityID;
            }

            string szTranslatedCity = TranslateCityName(szCity);
            if (!string.IsNullOrEmpty(szTranslatedCity))
            {
                iCityID = SearchForCity(szTranslatedCity, szState);
                if (iCityID > 0)
                {
                    //WriteLine(" - Translated City Found for " + szTranslatedCity + " (" + szCity + "), " + szState + ": " + iCityID.ToString());
                    szCurrentLine += "|" + iCityID.ToString() + "|Found 2nd Pass|" + szTranslatedCity;
                    return iCityID;
                }
            }


            // Now add the city.
            iCityID = GetCityID();

            SqlCommand sqlInsertCity = _dbConn.CreateCommand();
            sqlInsertCity.Transaction = _oTran;
            sqlInsertCity.Parameters.Add(new SqlParameter("CityID", iCityID));
            sqlInsertCity.Parameters.Add(new SqlParameter("City", szCity));
            sqlInsertCity.Parameters.Add(new SqlParameter("State", szState));
            sqlInsertCity.CommandText = SQL_INSERT_CITY;

            if (sqlInsertCity.ExecuteNonQuery() == 0)
            {
                throw new ApplicationException("Unable to add city: " + iCityID.ToString() + ", " + szCity + ", " + szState);
            }

            _iNewCityCount++;
            //WriteLine(" - Added New City for " + szCity + ", " + szState + ": " + iCityID.ToString());
            szCurrentLine += "|" + iCityID.ToString() + "|Added New City|";
            _lszNewCitiesBuffer.Add(szCity + "|" + szState + "|" + iCityID.ToString());

            return iCityID;
        }

        protected int SearchForCity(string szCity, string szState)
        {
            // First we need to check to see if the city already exists.
            SqlCommand sqlCityExist = _dbConn.CreateCommand();
            sqlCityExist.Transaction = _oTran;
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
            if (szCity.StartsWith("Mt ")) {
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


        protected int GetCityID()
        {
            SqlCommand sqlGetID = _dbConn.CreateCommand();
            sqlGetID.Transaction = _oTran;
            sqlGetID.CommandText = "usp_getNextId";
            sqlGetID.CommandType = CommandType.StoredProcedure;

            sqlGetID.Parameters.Add(new SqlParameter("TableName", "PRCity"));

            SqlParameter oReturnParm = new SqlParameter();
            oReturnParm.ParameterName = "Return";
            oReturnParm.Value = 0;
            oReturnParm.Direction = ParameterDirection.Output;
            sqlGetID.Parameters.Add(oReturnParm);

            sqlGetID.ExecuteNonQuery();

            return Convert.ToInt32(oReturnParm.Value);
        }

        protected int OpenPIKSTransaction()
        {
            if (_iTransactionID > 0)
            {
                return _iTransactionID;                   
            }

            SqlCommand sqlOpenPIKSTransaction = _dbConn.CreateCommand();
            sqlOpenPIKSTransaction.Transaction = _oTran;
            sqlOpenPIKSTransaction.CommandText = "usp_CreateTransaction";
            sqlOpenPIKSTransaction.CommandType = CommandType.StoredProcedure;
            sqlOpenPIKSTransaction.Parameters.Add(new SqlParameter("UserId", -1));
            sqlOpenPIKSTransaction.Parameters.Add(new SqlParameter("prtx_CompanyId", _iCompanyID));
            sqlOpenPIKSTransaction.Parameters.Add(new SqlParameter("prtx_Explanation", "Auto-assigning City information based on InfoUSA data import."));

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
        public void ClosePIKSTransaction()
        {
            if (_iTransactionID <= 0)
            {
                return;
            }

            SqlCommand sqlCloseTransaction = _dbConn.CreateCommand();
            sqlCloseTransaction.Transaction = _oTran;
            sqlCloseTransaction.Parameters.Add(new SqlParameter("TransactionID", _iTransactionID));
            sqlCloseTransaction.CommandText = SQL_PRTRANSACTION_CLOSE;

            if (sqlCloseTransaction.ExecuteNonQuery() == 0)
            {
                throw new ApplicationException("Unable to close transaction: " + _iTransactionID.ToString());
            }

            _iTransactionID = -1;
        }

        protected void WriteLine(string szLine)
        {
            if (!string.IsNullOrEmpty(szLine))
            {
                Console.WriteLine(szLine);
                _lszOutputBuffer.Add(szLine);
            }
        }

    }
}
