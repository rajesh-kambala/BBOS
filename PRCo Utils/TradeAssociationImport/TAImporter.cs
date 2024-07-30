// http://www.codeproject.com/Articles/9258/A-Fast-CSV-Reader

using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;
using CommandLine.Utility;
using LumenWorks.Framework.IO.Csv;

namespace TradeAssociationImport
{
    public class TAImporter
    {
        protected string _phoneColName = "Phone";
        protected string _faxColName = "Fax";
        protected string _memberIDColName = "MemberID";
        protected string _companyIDColName = "CompanyID";
        protected string _cityColName = "null";
        protected string _stateColName = "null";

        protected bool _allowMultipleMatches = false;
        protected bool _addToBranches = false;
        protected bool _commit = false;
        protected bool _hasMemberID = true;

        public void Import(string[] args)
        {
            Console.Clear();
            Console.Title = "Trade Association Import Utility";
            WriteLine("Trade Association Import Utility 1.3");
            WriteLine("Copyright (c) 2012-2017 Blue Book Services, Inc.");
            WriteLine("All Rights Reserved.");
            WriteLine("  OS Version: " + System.Environment.OSVersion.ToString());
            WriteLine(" CLR Version: " + System.Environment.Version.ToString());
            WriteLine(string.Empty);
            WriteLine(DateTime.Now.ToString("M/dd/yyyy hh:mm tt"));


            _szPath = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Substring(6);


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
                DisplayHelp();
                return;
            }

            string typeCode = null;
            string inputFile = null;

            if (oCommandLine["Type"] != null)
            {
                typeCode = oCommandLine["Type"];
            }
            else
            {
                WriteLine("/Type= parameter missing.");
                DisplayHelp();
                return;
            }

            if (oCommandLine["File"] != null)
            {
                inputFile = Path.Combine(_szPath, oCommandLine["File"]);
            }
            else
            {
                WriteLine("/File= parameter missing.");
                DisplayHelp();
                return;
            }


            if (oCommandLine["PhoneColName"] != null)
            {
                _phoneColName = oCommandLine["PhoneColName"];
            }
            if (oCommandLine["FaxColName"] != null)
            {
                _faxColName = oCommandLine["FaxColName"];
            }
            if (oCommandLine["MemberIDColName"] != null)
            {
                _memberIDColName = oCommandLine["MemberIDColName"];
            }
            if (oCommandLine["CompanyIDColName"] != null)
            {
                _companyIDColName = oCommandLine["CompanyIDColName"];
            }
            if (oCommandLine["CityColName"] != null)
            {
                _cityColName = oCommandLine["CityColName"];
            }
            if (oCommandLine["StateColName"] != null)
            {
                _stateColName = oCommandLine["StateColName"];
            }

            if (oCommandLine["AllowMultipleMatches"] == "Y")
            {
                _allowMultipleMatches = true;
            }

            if (oCommandLine["AddToBranches"] == "Y")
            {
                _addToBranches = true;
            }


            if (oCommandLine["Commit"] == "Y")
            {
                _commit = true;
            }

            if (_memberIDColName.ToLower() == "null")
            {
                _hasMemberID = false;
            }

            _szOutputFile = Path.Combine(_szPath, "TA_" + typeCode + "_Import.txt");
            _szOutputDataFile = Path.Combine(_szPath, "TA_" + typeCode + "_Results.csv");

            try
            {
                ExecuteImport(typeCode, inputFile);
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



        protected void ExecuteImport(string typeCode, string inputFile)
        {
            DateTime dtStart = DateTime.Now;

            StringBuilder multipleMatchList = new StringBuilder("MemberID, Company IDs" + Environment.NewLine);
            StringBuilder noMatchList = new StringBuilder("Member ID,Phone,Fax" + Environment.NewLine);
            StringBuilder deleteIDList = new StringBuilder();
            StringBuilder deleteList = new StringBuilder("Company ID,Member ID" + Environment.NewLine);



            int recordCount = 0;
            int notFoundCount = 0;
            int multipleMatchCount = 0;
            int deleteCount = 0;
            int skipCount = 0;
            int existsCount = 0;

            List<TACompany> taCompanies = new List<TACompany>();
            skipCount = LoadFile(inputFile, typeCode, taCompanies);
            if (_hasMemberID)
            {
                taCompanies = taCompanies.OrderBy(c => c.MemberID).ToList();
            }
            else
            {
                taCompanies = taCompanies.OrderBy(c => c.CompanyID).ToList();
            }


            SqlTransaction sqlTrans = null;
            using (SqlConnection sqlConn = new SqlConnection(ConfigurationManager.ConnectionStrings["SQLServer"].ConnectionString))
            {
                bool insertMember = true;
                sqlConn.Open();

                try {

                    sqlTrans = sqlConn.BeginTransaction();

                    foreach (TACompany taCompany in taCompanies)
                    {

                        if (_hasMemberID)
                        {
                            WriteLine(" - Processing " + typeCode + " Member ID: " + taCompany.MemberID);
                        }
                        else
                        {
                            WriteLine(" - Processing " + typeCode + " Company ID: " + taCompany.CompanyID);
                        }


                        insertMember = true;

                        if (existsInCRM(sqlTrans, taCompany, typeCode))
                        {
                            WriteLine("   Found in CRM: " + taCompany.CompanyID);
                            existsCount++;
                        }
                        else
                        {

                            // If the record is not in CRM and we don't have a
                            // company ID, then try to match it.
                            if (string.IsNullOrEmpty(taCompany.CompanyID))
                            {
                                matchOnPhone(sqlTrans, taCompany);
                            }


                            if (existsInCRM(sqlTrans, taCompany, typeCode))
                            {
                                WriteLine("   Found in CRM: " + taCompany.CompanyID);
                                existsCount++;
                            }
                            else
                            {

                                if (taCompany.MultipleMatchInCRM)
                                {

                                    if (!_allowMultipleMatches)
                                    {
                                        if (!findByLocation(sqlTrans, taCompany))
                                        {
                                            WriteLine("   Found multiple matches: Not Adding.");
                                            insertMember = false;
                                            multipleMatchCount++;
                                            multipleMatchList.Append(taCompany.MemberID + ", \"" + taCompany.MultipleMatchCompanyIDs + "\"" + Environment.NewLine);
                                        }
                                    }
                                }

                                if (string.IsNullOrEmpty(taCompany.CompanyID))
                                {
                                    WriteLine("   No match found: Not Adding.");
                                    insertMember = false;
                                    notFoundCount++;
                                    noMatchList.Append(taCompany.MemberID + "," + taCompany.Phone + "," + taCompany.Fax + Environment.NewLine);
                                }


                                if (insertMember)
                                {
                                    recordCount += addMember(sqlTrans, taCompany, typeCode);
                                }
                            }
                        }

                        if (deleteIDList.Length > 0)
                        {
                            deleteIDList.Append(", ");
                        }

                        if (_hasMemberID)
                        {
                            deleteIDList.Append("'" + taCompany.MemberID + "'");
                        }
                        else
                        {
                            deleteIDList.Append(taCompany.CompanyID);
                        }
                    }

                    deleteCount = deleteMembers(sqlTrans, deleteIDList.ToString(), typeCode, deleteList);


                    AddMembershipsToBranches(sqlTrans, typeCode);

                    if (_commit)
                    {
                        WriteLine(string.Empty);
                        WriteLine("Commiting Changes.");
                        WriteLine(string.Empty);

                        sqlTrans.Commit();
                    }
                    else
                    {
                        WriteLine(string.Empty);
                        WriteLine("Rolling Back Changes.");
                        WriteLine(string.Empty);
                        sqlTrans.Rollback();
                    }
                } catch {

                    sqlTrans.Rollback();
                    throw;
                }

                if (!_allowMultipleMatches)
                {
                    using (StreamWriter sw = new StreamWriter(Path.Combine(_szPath, "TA_" + typeCode + "_Multiple_Matches.txt")))
                    {
                        sw.Write(multipleMatchList.ToString());
                    }
                }

                using (StreamWriter sw = new StreamWriter(Path.Combine(_szPath, "TA_" + typeCode + "_No_Matches.csv")))
                {
                    sw.Write(noMatchList.ToString());
                }
                using (StreamWriter sw = new StreamWriter(Path.Combine(_szPath, "TA_" + typeCode + "_Deleted.csv")))
                {
                    sw.Write(deleteList.ToString());
                }

                WriteResultsFile(taCompanies);

                WriteLine(string.Empty);
                WriteLine("              Record Count: " + (skipCount + taCompanies.Count).ToString("###,##0"));
                WriteLine("           Processed Count: " + taCompanies.Count.ToString("###,##0"));
                WriteLine("             Skipped Count: " + skipCount.ToString("###,##0"));
                WriteLine("       Exists in CRM Count: " + existsCount.ToString("###,##0"));
                WriteLine("          Records Inserted: " + recordCount.ToString("###,##0"));
                WriteLine("           Records Deleted: " + deleteCount.ToString("###,##0"));
                WriteLine("         Members Not Found: " + notFoundCount.ToString("###,##0"));
                WriteLine("Members w-Multiple Matches: " + multipleMatchCount.ToString("###,##0"));
                WriteLine("Execution Time: " + DateTime.Now.Subtract(dtStart).ToString());

                using (StreamWriter sw = new StreamWriter(_szOutputFile))
                {
                    foreach (string line in _lszOutputBuffer)
                    {
                        sw.WriteLine(line);
                    }
                }
            }
        }

        protected const string SQL_DELETE_MEMBERS =
            "DELETE PRCompanyTradeAssociation OUTPUT Deleted.prcta_CompanyID, Deleted.prcta_MemberID  WHERE prcta_TradeAssociationCode=@Type AND {0} NOT IN ({1})";
        protected int deleteMembers(SqlTransaction sqlTrans, string deleteIDs, string typeCode, StringBuilder deleteList)
        {
            WriteLine(string.Empty);
            WriteLine("Deleting member IDs not found in the input file.");
            WriteLine(string.Empty);

            SqlCommand cmdDeleteTA = new SqlCommand();
            cmdDeleteTA.Connection = sqlTrans.Connection;
            cmdDeleteTA.Transaction = sqlTrans;

            string keyField = null;
            if (_hasMemberID)
            {
                keyField = "prcta_MemberID";
            }
            else
            {
                keyField = "prcta_CompanyID";
            }

            cmdDeleteTA.CommandText = string.Format(SQL_DELETE_MEMBERS, keyField, deleteIDs);

            
            cmdDeleteTA.Parameters.AddWithValue("Type", typeCode);

            int recordCount = 0;
            using (SqlDataReader reader = cmdDeleteTA.ExecuteReader())
            {
                while (reader.Read())
                {
                    recordCount++;
                    deleteList.Append(reader.GetInt32(0).ToString() + ",");

                    if (_hasMemberID)
                    {
                        deleteList.Append(reader.GetString(1));
                    }

                    deleteList.Append(Environment.NewLine);
                }
            }

            return recordCount;
            //return cmdDeleteTA.ExecuteNonQuery();
        }


        protected int addMember(SqlTransaction sqlTrans, TACompany taCompany, string typeCode)
        {
            int recordCount = 0;
            if (!taCompany.Matched)
            {
                recordCount++;
                addMember(sqlTrans, taCompany.CompanyID, taCompany.MemberID, typeCode);
            }
            else
            {
                foreach (string companyID in taCompany.MultipleMatchCompanyIDs.Split(','))
                {
                    recordCount++;
                    addMember(sqlTrans, companyID, taCompany.MemberID, typeCode);
                }
            }

            return recordCount;
        }

        protected const string INSERT_TA =
            @"INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_MemberID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp)
                VALUES (@CompanyID, @MemberID, @Type, @User, GETDATE(), @User, GETDATE(), GETDATE())";
        private SqlCommand cmdInsertTA = null;
        protected void addMember(SqlTransaction sqlTrans, string companyID, string memberID, string typeCode)
        {
            WriteLine("   Adding for company: " + companyID.Trim());

            if (cmdInsertTA == null)
            {
                cmdInsertTA = new SqlCommand();
                cmdInsertTA.Connection = sqlTrans.Connection;
                cmdInsertTA.Transaction = sqlTrans;
                cmdInsertTA.CommandText = INSERT_TA;
            }

            cmdInsertTA.Parameters.Clear();
            cmdInsertTA.Parameters.AddWithValue("CompanyID", companyID);

            if (_hasMemberID)
            {
                cmdInsertTA.Parameters.AddWithValue("MemberID", memberID); 
            }
            else
            {
                cmdInsertTA.Parameters.AddWithValue("MemberID", DBNull.Value);
            }

            cmdInsertTA.Parameters.AddWithValue("Type", typeCode);
            cmdInsertTA.Parameters.AddWithValue("User", -1);

            cmdInsertTA.ExecuteNonQuery();
        }


        private const string SQL_MATCH_PHONE =
            @"SELECT DISTINCT phon_CompanyID 
                FROM vPRPhone WITH (NOLOCK) 
                     INNER JOIN Company ON phon_CompanyID = comp_CompanyID
               WHERE phon_CompanyID IS NOT NULL 
                 AND comp_PRListingStatus NOT IN ('D', 'N3')
                 AND (phon_PhoneMatch=dbo.GetLowerAlpha(@Phone)";

        private SqlCommand cmdMatchPhone= null;
        protected void matchOnPhone(SqlTransaction sqlTrans, TACompany taCompany)
        {
            WriteLine("   Matching on Phone");

            if (string.IsNullOrEmpty(taCompany.Phone) &&
                string.IsNullOrEmpty(taCompany.Fax))
            {
                return;
            }


            if (cmdMatchPhone == null)
            {
                cmdMatchPhone = new SqlCommand();
                cmdMatchPhone.Connection = sqlTrans.Connection;
                cmdMatchPhone.Transaction = sqlTrans;
            }

            cmdMatchPhone.CommandText = SQL_MATCH_PHONE;
            cmdMatchPhone.Parameters.Clear();

            // If we made it here but don't have a phone value,
            // instead use the fax value.
            if (string.IsNullOrEmpty(taCompany.Phone))
            {
                cmdMatchPhone.Parameters.AddWithValue("Phone", taCompany.Fax);
            }
            else
            {

                cmdMatchPhone.Parameters.AddWithValue("Phone", taCompany.Phone);
                if (!string.IsNullOrEmpty(taCompany.Fax))
                {
                    cmdMatchPhone.CommandText += " OR phon_PhoneMatch=dbo.GetLowerAlpha(@Fax)";
                    cmdMatchPhone.Parameters.AddWithValue("Fax", taCompany.Fax);
                }
            }

            cmdMatchPhone.CommandText += ")";

            int count = 0;
            using (SqlDataReader reader = cmdMatchPhone.ExecuteReader())
            {
                while (reader.Read())
                {
                    count++;

                    if (count == 1)
                    {
                        taCompany.Matched = true;
                        taCompany.CompanyID = reader.GetInt32(0).ToString();
                        taCompany.MultipleMatchCompanyIDs = reader.GetInt32(0).ToString();
                    }
                    else
                    {
                        if (reader[0] != DBNull.Value)
                        {
                            taCompany.MultipleMatchInCRM = true;
                            taCompany.MultipleMatchCompanyIDs += ", " + reader.GetInt32(0).ToString();
                        }
                    }
                }
            }

        }




        private const string SQL_EXISTS_IN_CRM =
            "SELECT prcta_CompanyID FROM PRCompanyTradeAssociation WITH (NOLOCK) WHERE prcta_TradeAssociationCode= @Type AND ";
        private SqlCommand cmdExistsInCRM = null;

        protected bool existsInCRM(SqlTransaction sqlTrans, TACompany taCompany, string typeCode)
        {
            if (cmdExistsInCRM == null)
            {
                cmdExistsInCRM = new SqlCommand();
                cmdExistsInCRM.Connection = sqlTrans.Connection;
                cmdExistsInCRM.Transaction = sqlTrans;
            }

            cmdExistsInCRM.CommandText = SQL_EXISTS_IN_CRM;
            cmdExistsInCRM.Parameters.Clear();
            cmdExistsInCRM.Parameters.AddWithValue("Type", typeCode);

            // If we have a company ID, then look for the existing TA record
            // with it. Otherwise use the Member ID
            if (!string.IsNullOrEmpty(taCompany.CompanyID))
            {
                cmdExistsInCRM.CommandText += "prcta_CompanyID=@CompanyID";
                cmdExistsInCRM.Parameters.AddWithValue("CompanyID", Convert.ToInt32(taCompany.CompanyID));
            }
            else
            {
                cmdExistsInCRM.CommandText += "prcta_MemberID=@MemberID";
                cmdExistsInCRM.Parameters.AddWithValue("MemberID", taCompany.MemberID);
            }

            object result = cmdExistsInCRM.ExecuteScalar();
            if ((result == DBNull.Value) ||
                (result == null))
            {
                return false;
            }

            taCompany.CompanyID = Convert.ToString(result);

            return true;
        }



        private const string SQL_FIND_BY_LOCATION =
            "SELECT adli_CompanyID FROM vPRAddress WHERE prci_City= @City AND prst_Abbreviation=@State AND adli_CompanyID IN (SELECT value FROM Tokenize(@CompanyIDs, ','))";
        private SqlCommand cmdFindByLocation = null;

        protected bool findByLocation(SqlTransaction sqlTrans, TACompany taCompany)
        {
            if (string.IsNullOrEmpty(taCompany.City))
            {
                return false;
            }

            if (cmdFindByLocation == null)
            {
                cmdFindByLocation = new SqlCommand();
                cmdFindByLocation.Connection = sqlTrans.Connection;
                cmdFindByLocation.Transaction = sqlTrans;
            }

            cmdFindByLocation.CommandText = SQL_FIND_BY_LOCATION;
            cmdFindByLocation.Parameters.Clear();
            cmdFindByLocation.Parameters.AddWithValue("City", taCompany.City);
            cmdFindByLocation.Parameters.AddWithValue("State", taCompany.State);
            cmdFindByLocation.Parameters.AddWithValue("CompanyIDs", taCompany.MultipleMatchCompanyIDs);

            string companyID = null;
            int count = 0;
            using (SqlDataReader reader = cmdFindByLocation.ExecuteReader())
            {
                while (reader.Read())
                {
                    count++;
                    if (count > 1)
                    {
                        break;
                    }

                    companyID = reader.GetInt32(0).ToString();
                }
            }

            // If we only found 1 result, use that.
            if (count == 1)
            {
                taCompany.CompanyID = companyID;
                taCompany.MultipleMatchCompanyIDs = companyID;
                return true;
            }

            return false;
        }



        private int LoadFile(string fileName, string typeCode, List<TACompany> taCompanies)
        {
            StringBuilder sbSkipped = new StringBuilder();
            int skipCount = 0;

            using (CsvReader csv = new CsvReader(new StreamReader(fileName), true))
            {
                bool skip = false;
                
                int fieldCount = csv.FieldCount;
                int rowIndex = 1;
                csv.MissingFieldAction = MissingFieldAction.ReplaceByNull;

                while (csv.ReadNextRecord())
                {
                    rowIndex++;
                    skip = false;
                    TACompany taCompany = new TACompany();

                    if (_memberIDColName.ToLower() != "null")
                    {
                        taCompany.MemberID = csv[_memberIDColName];
                    }

                    if (_companyIDColName.ToLower() != "null")
                    {
                        taCompany.CompanyID = csv[_companyIDColName];
                    }
                    if (_phoneColName.ToLower() != "null")
                    {
                        taCompany.Phone = getPhoneValue(csv[_phoneColName]);
                    }
                    if (_faxColName.ToLower() != "null")
                    {
                        taCompany.Fax = getPhoneValue(csv[_faxColName]);
                    }

                    if (_cityColName.ToLower() != "null")
                    {
                        taCompany.City = csv[_cityColName];
                    }

                    if (_stateColName.ToLower() != "null")
                    {
                        taCompany.State = csv[_stateColName];
                    }


                    if ((!_hasMemberID) &&
                        ((taCompany.CompanyID.ToLower() == "none") ||
                         (string.IsNullOrEmpty(taCompany.CompanyID))))
                    {
                        skip = true;
                        skipCount++;
                        sbSkipped.Append(rowIndex.ToString() + Environment.NewLine);
                    }

                    if (!skip)
                    {
                        taCompanies.Add(taCompany);
                    }
                }
            }

            if (sbSkipped.Length > 0)
            {
                sbSkipped.Insert(0, "Row Number" + Environment.NewLine);
                using (StreamWriter sw = new StreamWriter(Path.Combine(_szPath, "TA_" + typeCode + "_Skipped.txt")))
                {
                    sw.Write(sbSkipped.ToString());
                }
            }

            return skipCount;
        }

        private const string SQL_ADD_TO_BRANCHES =
            @"INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_MemberID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp)
                SELECT comp_CompanyID, prcta_MemberID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp
                 FROM PRCompanyTradeAssociation
                      INNER JOIN Company ON prcta_CompanyID = comp_PRHQID
                WHERE prcta_TradeAssociationCode = @TypeCode
                  AND comp_PRType = 'B'
                  AND comp_CompanyID NOT IN (SELECT prcta_CompanyID FROM PRCompanyTradeAssociation WHERE prcta_TradeAssociationCode = @TypeCode)";

        private SqlCommand cmdAddToBranches = null;
        private void AddMembershipsToBranches(SqlTransaction sqlTrans, string typeCode)
        {
            if (!_addToBranches)
            {
                return;
            }

            WriteLine("Adding Membership to Branches");

            cmdAddToBranches = new SqlCommand();
            cmdAddToBranches.Connection = sqlTrans.Connection;
            cmdAddToBranches.Transaction = sqlTrans;
            cmdAddToBranches.CommandText = SQL_ADD_TO_BRANCHES;
            cmdAddToBranches.Parameters.AddWithValue("TypeCode", typeCode);
            cmdAddToBranches.ExecuteNonQuery();
        }

        private string getPhoneValue(string phone)
        {
            if (string.IsNullOrEmpty(phone))
            {
                return phone;
            }

            string work = cleanString(phone.Trim().ToLower());
            if (work.StartsWith("+1"))
            {
                work = work.Substring(2);
            }

            if (work.IndexOf("ext") > -1)
            {
                work = work.Substring(0, work.IndexOf("ext"));
            }

            if (work.IndexOf('x') > 0)
            {
                work = work.Substring(0, work.IndexOf('x'));
            }

            return work;
        }

        private string cleanString(string input)
        {
            return new string(input.Where(b => b <= 127).Select(b => (char)b).ToArray());
        }

        private string _szOutputDataFile;
        private void WriteResultsFile(List<TACompany> taCompanies)
        {

            StringBuilder line = new StringBuilder();

            using (StreamWriter sw = new StreamWriter(_szOutputDataFile))
            {
                sw.WriteLine("MemberID,CompanyID,Phone");
                foreach (TACompany taCompany in taCompanies)
                {
                    line.Clear();

                    line.Append(taCompany.MemberID);
                    line.Append(",");
                    line.Append(taCompany.CompanyID);
                    line.Append(",");
                    line.Append(taCompany.Phone);
                    
                    sw.WriteLine(line);
                }
            }
        }


        protected string _szOutputFile;
        protected string _szPath;
        protected List<string> _lszOutputBuffer = new List<string>();

        private void WriteLine(string msg)
        {
            Console.WriteLine(msg);
            _lszOutputBuffer.Add(msg);
        }

        /// <summary>
        /// Displays the application help message
        /// </summary>
        protected void DisplayHelp()
        {
            Console.WriteLine(string.Empty);
            Console.WriteLine("Trade Association Import Utility");
            Console.WriteLine("/Type= - The type of Trade Association records to be imported.  Should be one" + Environment.NewLine + "         of the prcta_TradeAssociationCode custom_caption values.");
            Console.WriteLine("/File= - The CSV import file.");
            Console.WriteLine("/CompanyIDColName= - The name of the column containing the BBSi Company ID." + Environment.NewLine + "                     Specify NULL if not present.  Defaults to CompanyID.");
            Console.WriteLine("/MemberIDColName= - The name of the column containing the Trade Association" + Environment.NewLine + "                    Member ID.  Specify NULL if not present.  Defaults to" + Environment.NewLine + "                    MemberID.");
            Console.WriteLine("/PhoneColName= - The name of the column containing the Phone Number.  Specify" + Environment.NewLine + "                 NULL if not present.  Defaults to Phone.");
            Console.WriteLine("/FaxColName= - The name of the column containing the Fax Number.  Specify" + Environment.NewLine + "               NULL if not present.  Defaults to Fax.");
            Console.WriteLine("/CityColName= - The name of the column containing the City.  Specify" + Environment.NewLine + "               NULL if not present.  Defaults to NULL.");
            Console.WriteLine("/StateColName= - The name of the column containing the State.  Specify" + Environment.NewLine + "               NULL if not present.  Defaults to NULL.");
            Console.WriteLine("/AllowMultipleMatches= - [Y/N] If Y, will allow a single member ID to be" + Environment.NewLine + "                         associated with multiple companies.  Defaults to N.");
            Console.WriteLine("/Commit= - [Y/N] Determines if the database changes should be committed." + Environment.NewLine + "           Defaults to N.");
            Console.WriteLine(string.Empty);
            Console.WriteLine("/Help - This help message");
        }
    }

    public class TACompany
    {
        public string CompanyID;
        public string MemberID;
        public string Phone;
        public string Fax;
        public string City;
        public string State;

        public bool Matched;
        public bool MultipleMatchInCRM;
        public string MultipleMatchCompanyIDs;

        public bool Inserted;
        public bool Deleted;

    }
}
