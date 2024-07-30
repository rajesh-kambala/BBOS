// http://www.codeproject.com/Articles/9258/A-Fast-CSV-Reader

using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using CommandLine.Utility;

using LumenWorks.Framework.IO.Csv;
namespace CSGImport
{
    public class CSGImporter
    {
        private const string TYPE_STORE_NAME = "SN";
        private const string TYPE_TRADE_AREA = "TA";
        private const string TYPE_DISTRIBUTION_CENTER = "DC";

        public void Import(string[] args)
        {
            DateTime dtStart = DateTime.Now;

            Console.Clear();
            Console.Title = "CSG Import Utility";
            WriteLine("CSG Import Utility 2.1");
            WriteLine("Copyright (c) 2012-2019 Blue Book Services, Inc.");
            WriteLine("All Rights Reserved.");
            WriteLine("  OS Version: " + System.Environment.OSVersion.ToString());
            WriteLine(" CLR Version: " + System.Environment.Version.ToString());
            WriteLine(string.Empty);
            WriteLine(DateTime.Now.ToString("M/dd/yyyy hh:mm tt"));
            WriteLine(string.Empty);

            Arguments oCommandLine = new Arguments(args);
            if (oCommandLine["File"] == null)
            {
                WriteLine("/File= parameter missing.");
                return;
            }

            if (!File.Exists(oCommandLine["File"]))
            {
                WriteLine("The specified file is not found.");
                return;
            }

            Dictionary<string, CSGCompany> csgCompanies = new Dictionary<string, CSGCompany>();
            int recordCount = LoadFile(oCommandLine["File"], csgCompanies);
            WriteLine(string.Empty);

            using (SqlConnection sqlConn = new SqlConnection(ConfigurationManager.ConnectionStrings["SQLServer"].ConnectionString))
            {
                sqlConn.Open();

                DeleteCSGData(sqlConn);
                InsertCSGData(csgCompanies, sqlConn);
            }

            string crmMatchFile = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Substring(6);
            crmMatchFile = Path.Combine(crmMatchFile, "CSG New CRM Matches.csv");

            int totalCount = csgCompanies.Count;
            int newMatchCount = 0;
            int unmatachedCount = 0;
            int companyCount = 0;
            int personCount = 0;
            int storeNameCount = 0;
            int tradeAreaCount = 0;
            int distributionCenterCount = 0;
            CSGCompany csgCompany = null;

            using (StreamWriter sw = new StreamWriter(crmMatchFile))
            {
                sw.WriteLine("Company ID,BBID");
                foreach (string key in csgCompanies.Keys)
                {
                    csgCompany = csgCompanies[key];
                    if (csgCompany.Inserted)
                    {
                        companyCount++;
                        storeNameCount += csgCompany.StoreRecordCount;
                        tradeAreaCount += csgCompany.TradeAreaRecordCount;
                        distributionCenterCount += csgCompany.DistributionCenterRecordCount;
                        personCount += csgCompany.Persons.Count;
                    }
                    else
                        unmatachedCount++;

                    if (csgCompany.NewMatch)
                    {
                        newMatchCount++;
                        sw.WriteLine(csgCompany.CSGCompanyID + "," + csgCompany.CompanyID.ToString());
                    }
                }
            }

            WriteLine(string.Empty);
            WriteLine("  Total Record Count: " + csgCompanies.Count.ToString("###,##0"));
            WriteLine(string.Empty);
            WriteLine("       Company Count: " + companyCount.ToString("###,##0"));
            WriteLine("     Unmatched Count: " + unmatachedCount.ToString("###,##0"));
            WriteLine(string.Empty);
            WriteLine("     New Match Count: " + newMatchCount.ToString("###,##0"));
            WriteLine("        Person Count: " + personCount.ToString("###,##0"));
            WriteLine("    Store Name Count: " + storeNameCount.ToString("###,##0"));
            WriteLine("    Trade Area Count: " + tradeAreaCount.ToString("###,##0"));
            WriteLine("Distrib Center Count: " + distributionCenterCount.ToString("###,##0"));
            WriteLine(string.Empty);
            WriteLine("Execution Time: " + DateTime.Now.Subtract(dtStart).ToString());

            using (StreamWriter sw = new StreamWriter(_szOutputFile))
            {
                foreach (string line in _lszOutputBuffer)
                {
                    sw.WriteLine(line);
                }
            }
        }

        private void DeleteCSGData(SqlConnection sqlConn)
        {
            SqlCommand sqlDelete = new SqlCommand("DELETE FROM PRCSG", sqlConn);
            sqlDelete.ExecuteNonQuery();

            sqlDelete = new SqlCommand("DELETE FROM PRCSGData", sqlConn);
            sqlDelete.ExecuteNonQuery();

            sqlDelete = new SqlCommand("DELETE FROM PRCSGPerson", sqlConn);
            sqlDelete.ExecuteNonQuery();
        }

        private const string SQL_INSERT_CSG =
            @"INSERT INTO PRCSG (prcsg_CompanyID, prcsg_CSGCompanyID, prcsg_TotalUnits, prcsg_TotalSquareFootage, prcsg_CreatedBy, prcsg_UpdatedBy) 
              VALUES (@CompanyID, @CSGCompanyID, @TotalUnits, @TotalSquareFootage, @UserID, @UserID);";

        private void InsertCSGData(Dictionary<string, CSGCompany> csgCompanies, SqlConnection sqlConn)
        {
            CSGCompany csgCompany = null;
            Dictionary<int, CSGCompany> _uniqueByBBID = new Dictionary<int, CSGCompany>();
            int totalCount = csgCompanies.Count;
            int count = 0;


            foreach (string key in csgCompanies.Keys)
            {
                csgCompany = csgCompanies[key];
                count++;

                if (csgCompany.CompanyID == 0)
                {
                    WriteLine(string.Format("Matching record {0:###,##0} of {1:###,##0}: CSG ID {2}", count, totalCount, csgCompany.CSGCompanyID));
                    matchCSGCompany(csgCompany, sqlConn);
                }

                if (csgCompany.CompanyID > 0)
                {
                    if (_uniqueByBBID.ContainsKey(csgCompany.CompanyID))
                    {
                        CSGCompany rootCSGCompany = _uniqueByBBID[csgCompany.CompanyID];
                        rootCSGCompany.StoreNames.AddRange(csgCompany.StoreNames);
                        rootCSGCompany.TradeAreas.AddRange(csgCompany.TradeAreas);
                        rootCSGCompany.DistributionCenters.AddRange(csgCompany.DistributionCenters);
                        rootCSGCompany.Persons.AddRange(csgCompany.Persons);
                    } else
                    {
                        _uniqueByBBID.Add(csgCompany.CompanyID, csgCompany);
                    }
                }
            }

            WriteLine(string.Empty);

            totalCount = _uniqueByBBID.Count;
            count = 0;


            SqlCommand sqlCommand = new SqlCommand(SQL_INSERT_CSG + "SELECT SCOPE_IDENTITY();", sqlConn);
            foreach (int key in _uniqueByBBID.Keys)
            {
                csgCompany = _uniqueByBBID[key];

                count++;

                WriteLine(string.Format("Saving record {0:###,##0} of {1:###,##0}: CSG ID {2}", count, totalCount, csgCompany.CSGCompanyID));
                if (csgCompany.NewMatch)
                {
                    WriteLine(" - Newly Matched to CRM Company ID: " + csgCompany.CompanyID.ToString());
                }

                sqlCommand.Parameters.Clear();
                sqlCommand.Parameters.AddWithValue("CompanyID", csgCompany.CompanyID);
                sqlCommand.Parameters.AddWithValue("CSGCompanyID", csgCompany.CSGCompanyID);
                sqlCommand.Parameters.AddWithValue("UserID", -1);

                if (csgCompany.LocationCount == 0)
                {
                    sqlCommand.Parameters.AddWithValue("TotalUnits", DBNull.Value);
                }
                else
                {
                    sqlCommand.Parameters.AddWithValue("TotalUnits", csgCompany.LocationCount);
                }

                if (csgCompany.SellingSquareFt == 0)
                {
                    sqlCommand.Parameters.AddWithValue("TotalSquareFootage", DBNull.Value);
                }
                else
                {
                    sqlCommand.Parameters.AddWithValue("TotalSquareFootage", csgCompany.SellingSquareFt);
                }

                csgCompany.CSGID = Convert.ToInt32(sqlCommand.ExecuteScalar());
                csgCompany.Inserted = true;
                InsertCSGPerson(csgCompany, sqlConn);
                csgCompany.StoreRecordCount = InsertDataValue(csgCompany, csgCompany.StoreNames, TYPE_STORE_NAME, ',', sqlConn);
                csgCompany.TradeAreaRecordCount = InsertDataValue(csgCompany, csgCompany.TradeAreas, TYPE_TRADE_AREA, ',', sqlConn);
                csgCompany.DistributionCenterRecordCount = InsertDataValue(csgCompany, csgCompany.DistributionCenters, TYPE_DISTRIBUTION_CENTER, '|', sqlConn);

            }




        }

        private const string SQL_INSERT_CSGPerson =
            @"INSERT INTO PRCSGPerson (prcsgp_CSGID, prcsgp_CSGPersonID, prcsgp_FirstName, prcsgp_LastName, prcsgp_MiddleInitial, prcsgp_Suffix, prcsgp_Title, prcsgp_Email, prcsgp_CreatedBy, prcsgp_UpdatedBy) 
              VALUES (@CSGID, @CSGPersonID, @FirstName, @LastName, @MiddleInitial, @Suffix, @Title, @Email, @UserID, @UserID);";

        private SqlCommand commandCSGPerson = null;
        private void InsertCSGPerson(CSGCompany csgCompany, SqlConnection sqlConn)
        {
            if (csgCompany.Persons.Count == 0)
            {
                return;
            }

            if (commandCSGPerson == null)
            {
                commandCSGPerson = new SqlCommand(SQL_INSERT_CSGPerson, sqlConn);
            }


            foreach (CSGPerson csgPerson in csgCompany.Persons)
            {
                commandCSGPerson.Parameters.Clear();
                commandCSGPerson.Parameters.AddWithValue("CSGID", csgCompany.CSGID);
                AddValue(commandCSGPerson, "CSGPersonID", csgPerson.CSGPersonID);
                commandCSGPerson.Parameters.AddWithValue("FirstName", csgPerson.FirstName);
                commandCSGPerson.Parameters.AddWithValue("LastName", csgPerson.LastName);

                AddValue(commandCSGPerson, "MiddleInitial", csgPerson.MiddleInitial);
                AddValue(commandCSGPerson, "Suffix", csgPerson.Suffix);
                AddValue(commandCSGPerson, "Title", csgPerson.Title);
                AddValue(commandCSGPerson, "Email", csgPerson.Email);

                commandCSGPerson.Parameters.AddWithValue("UserID", -1);
                commandCSGPerson.ExecuteNonQuery();
            }
        }

        private void AddValue(SqlCommand sqlCommand, string parmName, string parmValue)
        {
            if (string.IsNullOrEmpty(parmValue))
                sqlCommand.Parameters.AddWithValue(parmName, DBNull.Value);
            else
                sqlCommand.Parameters.AddWithValue(parmName, parmValue);
        }

        private const string SQL_INSERT_CSGData =
            @"INSERT INTO PRCSGData (prcsgd_CSGID, prcsgd_Value, prcsgd_TypeCode, prcsgd_CreatedBy, prcsgd_UpdatedBy) 
              VALUES (@CSGID, @Value, @TypeCode,@UserID, @UserID);";

        private SqlCommand commandCSGData = null;
        private int InsertDataValue(CSGCompany csgCompany, List<string> values, string typeCode, char delimiter, SqlConnection sqlConn)
        {
            if (values.Count == 0)
                return 0;

            if (commandCSGData == null)
                commandCSGData = new SqlCommand(SQL_INSERT_CSGData, sqlConn);

            int recordCount = 0;
            values.Sort();
            HashSet<string> _processedValues = new HashSet<string>();

            foreach (string value in values)
            {
                if ((!string.IsNullOrEmpty(value)) &&
                    (!_processedValues.Contains(value)))
                {
                    recordCount++;
                    commandCSGData.Parameters.Clear();
                    commandCSGData.Parameters.AddWithValue("CSGID", csgCompany.CSGID);
                    commandCSGData.Parameters.AddWithValue("Value", value.Trim());
                    commandCSGData.Parameters.AddWithValue("TypeCode", typeCode);
                    commandCSGData.Parameters.AddWithValue("UserID", -1);
                    commandCSGData.ExecuteNonQuery();

                    _processedValues.Add(value);
                }
            }

            //WriteLine("   " + typeCode + " records: " + recordCount.ToString());
            return recordCount;
        }

        private int LoadFile(string fileName, Dictionary<string, CSGCompany> csgCompanies)
        {
            int recordCount = 0;

            CSGCompany csgCompany = null;
            using (CsvReader csv = new CsvReader(new StreamReader(fileName), true))
            {
                int fieldCount = csv.FieldCount;

                while (csv.ReadNextRecord())
                {
                    recordCount++;

                    if (string.IsNullOrEmpty(csv["Company ID"]))
                        continue;

                    if (csgCompanies.ContainsKey(csv["Company ID"]))
                        csgCompany = csgCompanies[csv["Company ID"]];
                    else
                    {
                        csgCompany = new CSGCompany();

                        if (!string.IsNullOrEmpty(csv["BBID"]))
                            csgCompany.CompanyID = Convert.ToInt32(csv["BBID"]);

                        csgCompany.CSGCompanyID = csv["Company ID"];
                        csgCompany.Phone = csv["Phone"];
                        csgCompany.Fax = csv["Fax"];
                        csgCompany.CompanyName = csv["Company Name"];
                        csgCompany.State = csv["State"];
                        csgCompany.MailState = csv["Mail State"];
                        csgCompanies.Add(csgCompany.CSGCompanyID, csgCompany);
                    }

                    csgCompany.SellingSquareFt += ConvertToInt(csv["Selling Sq Ft"]);
                    csgCompany.LocationCount += ConvertToInt(csv["Total Locations"]);
                    csgCompany.StoreNames.Add(csv["Store Name"]);
                    csgCompany.TradeAreas.AddRange(GetListValues(csv["Trade Areas"]));
                    if (!string.IsNullOrEmpty(csv["DC City"]))
                        csgCompany.DistributionCenters.Add(csv["DC City"] + ", " + csv["DC State"]);

                    if ((!string.IsNullOrEmpty(csv["First Name"])) && (!string.IsNullOrEmpty(csv["Last Name"])))
                    {
                        CSGPerson csgPerson = new CSGPerson();
                        csgPerson.FirstName = csv["First Name"];
                        csgPerson.LastName = csv["Last Name"];
                        csgPerson.MiddleInitial = csv["MI"];
                        csgPerson.Suffix = csv["SUFFIX"];
                        csgPerson.Title = csv["Contact Title"];
                        csgPerson.Email = csv["PERS_EMAIL"];

                        if (csv.HasHeader("Person ID"))
                            csgPerson.CSGPersonID = csv["Person ID"];

                        csgCompany.Persons.Add(csgPerson);
                    }

                    WriteLine(string.Format("Loading record {0:###,##0}: CSG ID {1}", recordCount, csgCompany.CSGCompanyID));
                } // End While
            }

            return recordCount;
        }

        private int ConvertToInt(string value)
        {
            if (string.IsNullOrEmpty(value))
                return 0;

            return Convert.ToInt32(value.Replace(",", string.Empty));
        }

        private const string SQL_SELECT_PHONE =
            @"SELECT phon_CompanyID 
                FROM vPRPhone WITH (NOLOCK)
               WHERE (phon_PhoneMatch = dbo.ufn_GetLowerAlpha(@Phone) {0})
                 AND phon_PhoneMatch IS NOT NULL
                 AND phon_CompanyID IS NOT NULL";

        private const string SQL_SELECT_PHONE_FAX_CLAUSE =
            " OR phon_PhoneMatch = dbo.ufn_GetLowerAlpha(@Fax)";

        private SqlCommand commandPhone = null;


        private const string SQL_SELECT_NAME =
            @"SELECT prcse_CompanyId 
                FROM PRCompanySearch WITH (NOLOCK)
                     INNER JOIN vPRAddress ON adli_CompanyID = prcse_CompanyId
               WHERE prcse_NameMatch = dbo.ufn_GetLowerAlpha(dbo.ufn_PrepareCompanyName(@Name))
                 AND (prst_Abbreviation = @State {0})";

        private const string SQL_SELECT_MAIL_STATE_CLAUSE = " OR prst_Abbreviation = @MailState";

        private SqlCommand commandName = null;

        private void matchCSGCompany(CSGCompany csgCompany, SqlConnection sqlConn)
        {
            csgCompany.NewMatch = false;
            if (commandPhone == null)
            {
                commandPhone = new SqlCommand();
                commandPhone.Connection = sqlConn;
            }

            commandPhone.CommandText = SQL_SELECT_PHONE;
            commandPhone.Parameters.Clear();
            commandPhone.Parameters.AddWithValue("Phone", csgCompany.Phone);

            string msg = string.Format(" - Matching on Phone", csgCompany.Phone);
            string sqlClause = string.Empty;

            if (!string.IsNullOrEmpty(csgCompany.Fax))
            {
                sqlClause = SQL_SELECT_PHONE_FAX_CLAUSE;
                commandPhone.Parameters.AddWithValue("Fax", csgCompany.Fax);
                msg += string.Format(" and on Fax", csgCompany.Fax);
            }

            commandPhone.CommandText = string.Format(commandPhone.CommandText, sqlClause);
            WriteLine(msg);

            object oCRMCompanyID = commandPhone.ExecuteScalar();
            if ((oCRMCompanyID != DBNull.Value) && (oCRMCompanyID != null))
            {
                csgCompany.CompanyID = Convert.ToInt32(oCRMCompanyID);
                csgCompany.NewMatch = true;
                WriteLine(string.Format(" - Matched to  {0}", csgCompany.CompanyID));
                return;
            }

            if (commandName == null)
            {
                commandName = new SqlCommand();
                commandName.Connection = sqlConn;
            }

            commandName.CommandText = SQL_SELECT_NAME;
            commandName.Parameters.Clear();
            commandName.Parameters.AddWithValue("Name", csgCompany.CompanyName);
            commandName.Parameters.AddWithValue("State", csgCompany.State);

            msg = string.Format(" - Matching on Name and State", csgCompany.CompanyName);
            sqlClause = string.Empty;

            if (!string.IsNullOrEmpty(csgCompany.MailState) && (csgCompany.State != csgCompany.MailState))
            {
                sqlClause = SQL_SELECT_MAIL_STATE_CLAUSE;
                commandName.Parameters.AddWithValue("MailState", csgCompany.MailState);
                msg += string.Format(" and on Mail State", csgCompany.MailState);
            }

            commandName.CommandText = string.Format(commandName.CommandText, sqlClause);
            WriteLine(msg);

            oCRMCompanyID = commandName.ExecuteScalar();
            if ((oCRMCompanyID != DBNull.Value) && (oCRMCompanyID != null))
            {
                csgCompany.CompanyID = Convert.ToInt32(oCRMCompanyID);
                csgCompany.NewMatch = true;
                WriteLine(string.Format(" - Matched to  {0}", csgCompany.CompanyID));
                return;
            }
        }


        private int getLocationCount(string storeName)
        {
            if (string.IsNullOrEmpty(storeName))
                return 0;

            int pos1 = storeName.IndexOf("(");
            int pos2 = storeName.IndexOf(")");

            if ((pos1 == -1) ||
                (pos2 == -1))
                return 0;

            return Convert.ToInt32(storeName.Substring(pos1 + 1, (pos2 - (pos1 + 1))));
        }

        protected string _szOutputFile;
        protected List<string> _lszOutputBuffer = new List<string>();

        private void WriteLine(string msg)
        {
            if (_szOutputFile == null)
            {
                _szOutputFile = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Substring(6);
                _szOutputFile = Path.Combine(_szOutputFile, "CSGImport.txt");
            }

            Console.WriteLine(msg);
            _lszOutputBuffer.Add(msg);
        }

        private List<string> GetListValues(string delimitedList)
        {
            return new List<string>(delimitedList.Split(','));
        }
    }


    class CSGCompany
    {
        public string CSGCompanyID;
        public int CompanyID;
        public int SellingSquareFt;
        public int LocationCount;
        public string CompanyName;
        public string State;
        public string MailState;

        public List<string> StoreNames = new List<string>();
        public List<string> TradeAreas = new List<string>();
        public List<string> DistributionCenters = new List<string>();

        public int TradeAreaRecordCount;
        public int StoreRecordCount;
        public int DistributionCenterRecordCount;
        public int CSGID;

        public string Phone;
        public string Fax;

        public bool NewMatch;
        public bool Inserted;

        public List<CSGPerson> Persons = new List<CSGPerson>();
    }

    class CSGPerson
    {
        public string CSGPersonID;
        public string FirstName;
        public string LastName;
        public string Title;
        public string MiddleInitial;
        public string Suffix;
        public string Email;
    }
}

