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
using TSI.Utils;

namespace IntlTradeAssociationImport
{
    public class Importer
    {
        protected bool _commit = false;
        protected List<Int32> _matchedBBIDs = new List<int>();
        protected List<Int32> _dupBBIDs = new List<int>();

        public void Import(string[] args)
        {
            Console.Clear();
            Console.Title = "Intl Trade Association Import Utility";
            WriteLine("International Trade Association Import Utility 1.1");
            WriteLine("Copyright (c) 2018-2021 Blue Book Services, Inc.");
            WriteLine("All Rights Reserved.");
            WriteLine("  OS Version: " + System.Environment.OSVersion.ToString());
            WriteLine(" CLR Version: " + System.Environment.Version.ToString());
            WriteLine(string.Empty);
            WriteLine(DateTime.Now.ToString("M/dd/yyyy hh:mm tt"));


            _szPath = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Substring(6);


            if (args.Length == 0)
            {
                DisplayHelp();
                return;
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
            string columnMappingFile = null;

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

            if (oCommandLine["ColumnMappingFile"] != null)
            {
                columnMappingFile = Path.Combine(_szPath, oCommandLine["ColumnMappingFile"]);
            }
            else
            {
                WriteLine("/ColumnMappingFile= parameter missing.");
                DisplayHelp();
                return;
            }

            if (oCommandLine["Commit"] == "Y")
            {
                _commit = true;
            }


            _szOutputDataFile = Path.Combine(_szPath, "TA_" + typeCode + "_Results.csv");
            _szMatchedDataFile = Path.Combine(_szPath, "TA_" + typeCode + "_NewMatches.csv");

            try
            {
                ExecuteImport(typeCode, columnMappingFile, inputFile);
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

                using (StreamWriter sw = new StreamWriter(Path.Combine(_szPath, "ITAImport_Exception.txt")))
                {
                    sw.WriteLine(e.Message + Environment.NewLine);
                    sw.WriteLine(e.StackTrace);
                }

            }
        }

        protected void ExecuteImport(string typeCode, string columnMappingFile, string inputFile)
        {
            DateTime dtStart = DateTime.Now;

            LoadColumnMapping(columnMappingFile);

            StringBuilder multipleMatchList = new StringBuilder("MemberID,Company IDs" + Environment.NewLine);
            StringBuilder noMatchList = new StringBuilder("Member ID,Phone,Fax" + Environment.NewLine);

            int count = 0;
            int matchedCount = 0;

            List<Company> taCompanies = LoadFile(inputFile, typeCode);
            taCompanies = taCompanies.OrderBy(c => c.CompanyName).ToList();

            SqlTransaction sqlTrans = null;
            using (SqlConnection sqlConn = new SqlConnection(ConfigurationManager.ConnectionStrings["SQLServer"].ConnectionString))
            {
                sqlConn.Open();

                try
                {

                    sqlTrans = sqlConn.BeginTransaction();

                    WriteLine(string.Empty);
                    WriteLine("Matching to CRM");
                    foreach (Company company in taCompanies)
                    {
                        count++;
                        WriteLine(string.Format("Processing record {0:###,##0} of {1:###,##0}: {2}", count, taCompanies.Count, company.CompanyName));
                        matchCRMCompany(company, sqlTrans);

                        if (company.Matched)
                            matchedCount++;
                    }

                    count=0;
                    WriteLine(string.Empty);
                    WriteLine("Looking for Duplicate BBIDs");
                    foreach (Company company in taCompanies) {
                        count++;
                        WriteLine(string.Format("Processing record {0:###,##0} of {1:###,##0}: {2}", count, taCompanies.Count, company.CompanyName));
                        if ((!company.Duplicate) &&
                            (_dupBBIDs.Contains(company.CompanyID)))
                        {
                            company.Duplicate = true;
                        }
                    }

                    count = 0;
                    WriteLine(string.Empty);
                    WriteLine("Saving companies");
                    foreach (Company company in taCompanies)
                    {
                        count++;
                        WriteLine(string.Format("Processing record {0:###,##0} of {1:###,##0}: {2}", count, taCompanies.Count, company.CompanyName));
                        company.Save(sqlTrans);
                    }

                    // Now go find any 
                    bool found = false;
                    List<Company> existingCompanies = new Company().GetIntlTACompanies(sqlTrans);
                    foreach (Company existingCompany in existingCompanies)
                    {
                        
                        found = false;
                        foreach (Company company in taCompanies)
                        {
                            if (existingCompany.CompanyID == company.CompanyID)
                            {
                                found = true;
                                break;
                            }
                        }

                        if (!found)
                        {
                            existingCompany.ParentImporter = this;
                            existingCompany.AssociationCode = typeCode;
                            existingCompany.RemoveIntlCompany(sqlTrans);
                        }
                    }


                    // Now go find any persons flagged as ITA but 
                    // not in our file.
                    WriteLine(string.Empty);
                    WriteLine("Looking for ITA persons to remove");
                    found = false;
                    List<Person> removePersons = new List<Person>();
                    List<Person> existingPersons = new Person().GetIntlTAPersons(sqlTrans, typeCode);
                    foreach (Person existingPerson in existingPersons)
                    {
                        found = false;
                        foreach (Company company in taCompanies)
                        {
                            foreach (Person person in company.Persons)
                            {
                                if (existingPerson.PersonLinkID == person.PersonLinkID)
                                {
                                    found = true;
                                    break;
                                }
                            }

                            if (found)
                                break;
                        }

                        if (!found)
                        {
                            removePersons.Add(existingPerson);
                        }
                    }

                    foreach (Person removePerson in removePersons)
                    {
                        //WriteLine(string.Format("Marking Person {0} {1}: {2} NLC.", removePerson.FirstName, removePerson.LastName, removePerson.PersonID));
                        removePerson.ParentImporter = this;
                        removePerson.RemoveIntlPerson(sqlTrans);
                    }

                    if (_commit)
                    {
                        WriteLine(string.Empty);
                        WriteLine("Committing Changes.");
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
                }
                catch
                {
                    WriteFile(_lszOutputBuffer, "TA_" + typeCode + "_Import.txt");
                    sqlTrans.Rollback();
                    throw;
                }

                WriteResultsFile(taCompanies);
                WriteMatchedFile(taCompanies);

                WriteLine(string.Empty);
                WriteLine("  Record Count: " + taCompanies.Count.ToString("###,##0"));
                WriteLine(" Matched Count: " + matchedCount.ToString("###,##0"));
                WriteLine(string.Empty);
                WriteLine("Execution Time: " + DateTime.Now.Subtract(dtStart).ToString());

                WriteFile(_lszOutputBuffer, "TA_" + typeCode + "_Import.txt");
                WriteFile(_lstInvalidCity, "TA_" + typeCode + "_InvalidCities.csv");
                WriteFile(_lstExceptions, "TA_" + typeCode + "_Exceptions.csv");

            }
        }

        private void WriteFile(List<string> content, string fileName)
        {
            string _fullFileName = Path.Combine(_szPath, fileName);
            using (StreamWriter sw = new StreamWriter(_fullFileName))
            {
                foreach (string line in content)
                {
                    sw.WriteLine(line);
                }
            }
        }


        private const string SQL_SELECT_PHONE =
            @"SELECT phon_CompanyID 
                FROM vPRPhone WITH (NOLOCK)
               WHERE ({0})
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
                 AND (prst_State = @State {0})";

        private SqlCommand commandName = null;

        private void matchCRMCompany(Company company, SqlTransaction sqlTrans)
        {
            if (company.CompanyID > 0)
            {
                WriteLine(string.Format(" - Previously matched to {0}.", company.CompanyID));
                return;
            }

            company.Matched = false;
            if (commandPhone == null)
                commandPhone = new SqlCommand();

            commandPhone.Connection = sqlTrans.Connection;
            commandPhone.Transaction = sqlTrans;
            commandPhone.CommandText = SQL_SELECT_PHONE;
            commandPhone.Parameters.Clear();

            string sqlClause = string.Empty;
            string parmName = string.Empty;
            string parmValue = string.Empty;

            int phoneCount = 0;
            foreach (Phone phone in company.Phones)
            {
                phoneCount++;
                parmName = "Phone" + phoneCount.ToString();
                parmValue = phone.Number;

                commandPhone.Parameters.AddWithValue(parmName, parmValue);
                if (sqlClause.Length > 0)
                    sqlClause += " OR ";

                sqlClause += string.Format("(phon_PhoneMatch = dbo.ufn_GetLowerAlpha(@{0}) AND phon_CountryCode='{1}')", parmName, phone.CountryCode);
                WriteLine(string.Format(" - Matching on Phone {0}.", parmValue));
            }

            if (string.IsNullOrEmpty(sqlClause))
                return;

            commandPhone.CommandText = string.Format(commandPhone.CommandText, sqlClause);

            object oCRMCompanyID = commandPhone.ExecuteScalar();
            if ((oCRMCompanyID != DBNull.Value) && (oCRMCompanyID != null))
            {
                company.CompanyID = Convert.ToInt32(oCRMCompanyID);
                company.Matched = true;
                WriteLine(string.Format(" - Matched to {0}", company.CompanyID));
                CheckForDuplicate(company);
                return;
            }


            if (commandName == null)
                commandName = new SqlCommand();

            commandName.Connection = sqlTrans.Connection;
            commandName.Transaction = sqlTrans;


            commandName.CommandText = SQL_SELECT_NAME;
            commandName.Parameters.Clear();
            commandName.Parameters.AddWithValue("Name", company.CompanyName);
            commandName.Parameters.AddWithValue("State", company.State);

            sqlClause = string.Empty;
            commandName.CommandText = string.Format(commandName.CommandText, sqlClause);
            WriteLine(string.Format(" - Matching on Name and State {0}, {1}", company.CompanyName, company.State));

            oCRMCompanyID = commandName.ExecuteScalar();
            if ((oCRMCompanyID != DBNull.Value) && (oCRMCompanyID != null))
            {

                company.CompanyID = Convert.ToInt32(oCRMCompanyID);
                company.Matched = true;
                WriteLine(string.Format(" - Matched to  {0}", company.CompanyID));
                CheckForDuplicate(company);
                return;
            }
        }


        private char[] delimiters = { ',', '.' };
        private List<Company> LoadFile(string fileName, string taType)
        {
            List<Company> taCompanies = new List<Company>();

            using (CsvReader csv = new CsvReader(new StreamReader(fileName, Encoding.Default), true))
            {

                int fieldCount = csv.FieldCount;
                int rowIndex = 1;
                int index = 1;
                csv.MissingFieldAction = MissingFieldAction.ReplaceByNull;

                while (csv.ReadNextRecord())
                {
                    rowIndex++;
                    Company company = new Company();

                    company.ParentImporter = this;
                    company.CompanyName = TranslateSpanishCharacters(getCSVValue(csv, "CompanyName"));

                    if (!string.IsNullOrEmpty(getCSVValue(csv, "CompanyID")))
                    {
                        company.CompanyID = Convert.ToInt32(getCSVValue(csv, "CompanyID"));
                        CheckForDuplicate(company);
                    }

                    company.City = TranslateSpanishCharacters(getCSVValue(csv, "City"));
                    company.State = TranslateMexicanState(TranslateSpanishCharacters(getCSVValue(csv, "State")));
                    company.Email = getCSVValue(csv, "Email");
                    company.Website = getCSVValue(csv, "Website");
                    company.AssociationCode = taType;
                    company.DefaultTimeZone = GetTranslatedColName("DefaultTimeZone");

                    Address address = new Address();
                    address.Street1 = TranslateSpanishCharacters(getCSVValue(csv, "Street1"));
                    address.Street2 = TranslateSpanishCharacters(getCSVValue(csv, "Street2"));
                    address.Street3 = TranslateSpanishCharacters(getCSVValue(csv, "Street3"));
                    //address.Street4 = TranslateSpanishCharacters(getCSVValue(csv, "Street4"));
                    address.City = TranslateSpanishCharacters(getCSVValue(csv, "City"));
                    address.State = TranslateMexicanState(TranslateSpanishCharacters(getCSVValue(csv, "State")));
                    address.Postal = getCSVValue(csv, "Postal");
                    address.Country = getCSVValue(csv, "Country");
                    if (string.IsNullOrEmpty(address.Country))
                    {
                        address.Country = GetTranslatedColName("DefaultCountry");
                    }
                    company.AddAddress(address);

                    index = 1;
                    while (!string.IsNullOrEmpty(getCSVValue(csv, "Phone" + index.ToString())))
                    {
                        Phone phone = new Phone();
                        phone.Type = getCSVValue(csv, "PhoneType" + index.ToString());


                        phone.Number = getCSVValue(csv, "Phone" + index.ToString()).Replace("(", string.Empty).Replace(")", string.Empty).Replace(" ", string.Empty);

                        if (phone.Number.StartsWith("1 "))
                        {
                            phone.Number = phone.Number.Substring(2);
                        }

                        if ((phone.Number.Length == 11) && (phone.Number.StartsWith("1"))) {
                            phone.Number = phone.Number.Substring(1);
                        }

                        phone.CountryCode = getCSVValue(csv, "PhoneCountryCode" + index.ToString());

                        if (string.IsNullOrEmpty(phone.CountryCode))
                        {
                            phone.CountryCode = GetTranslatedColName("DefaultPhoneCountryCode");
                        }

                        company.AddPhone(phone);
                        index++;
                    }

                    index = 1;
                    while (!string.IsNullOrEmpty(getCSVValue(csv, "PersonLastName" + index.ToString())))
                    {
                        Person person = new Person();
                        person.FirstName = TranslateSpanishCharacters(getCSVValue(csv, "PersonFirstName" + index.ToString()));
                        person.LastName = TranslateSpanishCharacters(getCSVValue(csv, "PersonLastName" + index.ToString()));
                        person.Email = getCSVValue(csv, "PersonEmail" + index.ToString());
                        company.AddPerson(person);
                        person.FormatName();
                        index++;
                    }

                    if (!string.IsNullOrEmpty(getCSVValue(csv, "Commodities")))
                    {
                        string commodities = getCSVValue(csv, "Commodities");
                        string[] aszCommodities = commodities.Split(delimiters, StringSplitOptions.RemoveEmptyEntries);
                        foreach (string szCommodity in aszCommodities)
                        {
                            Commodity commodity = new Commodity();
                            commodity.Name = szCommodity;
                            company.AddCommodity(commodity);
                        }
                    }

                    taCompanies.Add(company);
                }
            }

            return taCompanies;
        }

        private void CheckForDuplicate(Company company)
        {
            if (_matchedBBIDs.Contains(company.CompanyID))
            {
                company.Duplicate = true;
                _dupBBIDs.Add(company.CompanyID);
            }
            else
            {
                _matchedBBIDs.Add(company.CompanyID);
            }
        }

        private string getCSVValue(CsvReader csv, string colName)
        {
            string translatedColName = GetTranslatedColName(colName);
            if (string.IsNullOrEmpty(translatedColName))
            {
                return null;
            }

            return csv[translatedColName];
        }

        protected string GetTranslatedColName(string colNameMaster)
        {

            if (_colMapping.ContainsKey(colNameMaster.ToLower()))
            {
                return _colMapping[colNameMaster.ToLower()].Trim();
            }

            return null;
        }

        private string getPhoneValue(string phone)
        {
            if (string.IsNullOrEmpty(phone))
            {
                return phone;
            }

            string work = cleanString(phone.Trim().ToLower());
            if (work.StartsWith("+1"))
                work = work.Substring(2);

            if (work.IndexOf("ext") > -1)
                work = work.Substring(0, work.IndexOf("ext"));

            if (work.IndexOf('x') > 0)
                work = work.Substring(0, work.IndexOf('x'));

            return work;
        }

        private string cleanString(string input)
        {
            return new string(input.Where(b => b <= 127).Select(b => (char)b).ToArray());
        }

        private string _szOutputDataFile;
        private void WriteResultsFile(List<Company> taCompanies)
        {

            StringBuilder line = new StringBuilder();

            using (StreamWriter sw = new StreamWriter(_szOutputDataFile))
            {
                string header = string.Empty;
                //if (_hasMemberID)
                //{
                //    header = "MemberID,";
                //}
                header += "Company Name,CompanyID";

                sw.WriteLine(header);
                foreach (Company Company in taCompanies)
                {
                    line.Clear();

                    //if (_hasMemberID)
                    //{
                    //    line.Append(Company.MemberID);
                    //    line.Append(",");
                    //}
                    line.Append(Company.CompanyName);
                    line.Append(",");
                    line.Append(Company.CompanyID);

                    sw.WriteLine(line);
                }
            }
        }

        private string _szMatchedDataFile;
        private void WriteMatchedFile(List<Company> taCompanies)
        {

            StringBuilder line = new StringBuilder();

            using (StreamWriter sw = new StreamWriter(_szMatchedDataFile))
            {
                string header = string.Empty;
                //if (_hasMemberID)
                //{
                //    header = "MemberID,";
                //}
                header += "Company Name,CompanyID";

                sw.WriteLine(header);
                foreach (Company company in taCompanies)
                {
                    if (!company.Matched) continue;

                    line.Clear();

                    //if (_hasMemberID)
                    //{
                    //    line.Append(company.MemberID);
                    //    line.Append(",");
                    //}
                    line.Append(company.CompanyName);
                    line.Append(",");
                    line.Append(company.CompanyID);

                    sw.WriteLine(line);
                }
            }
        }


        protected string _szPath;
        protected List<string> _lszOutputBuffer = new List<string>();

        public void WriteLine(string msg)
        {
            Console.WriteLine(msg);
            _lszOutputBuffer.Add(msg);
        }

        protected List<string> _lstInvalidCity = new List<string>();
        public void AddInvalidCity(string msg)
        {
            _lstInvalidCity.Add(msg);
        }

        private const string EXCEPTION_DETAIL = "\"{0}\",\"{1}\",\"{2}\",\"{3}\",\"{4}\",\"{5}\"";
        protected List<string> _lstExceptions = new List<string>();
        public void AddException(Company company, string msg)
        {
            WriteLine(" - " + msg);

            object[] args = { company.CompanyName, company.CompanyID, company.Rating, company.ListingStatus, company.ServiceCode, msg };

            string tmpMsg = string.Format(EXCEPTION_DETAIL, args);
            _lstExceptions.Add(tmpMsg);
        }


        /// <summary>
        /// Displays the application help message
        /// </summary>
        protected void DisplayHelp()
        {
            Console.WriteLine(string.Empty);
            Console.WriteLine("International Trade Association Import Utility");
            Console.WriteLine("/Type= - The type of Trade Association records to be imported.  Should be one" + Environment.NewLine + "         of the prcta_TradeAssociationCode custom_caption values.");
            Console.WriteLine("/File= - The CSV import file.");
            Console.WriteLine("/ColumnMappingFile= - The CSV column mapping file.");
            Console.WriteLine("/Commit= - [Y/N] Determines if the database changes should be committed." + Environment.NewLine + "           Defaults to N.");
            Console.WriteLine("/Help - This help message");
        }

        private string GetImportColName(string colNameValue, string parmValue)
        {
            if (parmValue != null)
            {
                return parmValue;
            }

            return colNameValue;
        }

        private Dictionary<string, string> _colMapping = new Dictionary<string, string>();

        protected void LoadColumnMapping(string columnMappingFile)
        {
            if (_colMapping.Count > 0)
            {
                return;
            }


            using (StreamReader srReader = new StreamReader(columnMappingFile))
            {
                string szLine = null;
                while ((szLine = srReader.ReadLine()) != null)
                {
                    string[] colFields = szLine.Split(',');
                    _colMapping.Add(colFields[0].ToLower().Trim(), colFields[1].ToLower().Trim());
                }
            }
        }

        private Dictionary<char, char> spanishCharTranslation = null;

        protected string TranslateSpanishCharacters(string name)
        {
            if (string.IsNullOrEmpty(name))
                return name;

            if (spanishCharTranslation == null)
            {
                spanishCharTranslation = new Dictionary<char, char>();
                spanishCharTranslation.Add('Á', 'A');
                spanishCharTranslation.Add('á', 'a');
                spanishCharTranslation.Add('à', 'a');
                spanishCharTranslation.Add('â', 'a');
                spanishCharTranslation.Add('ã', 'a');
                spanishCharTranslation.Add('ä', 'a');
                spanishCharTranslation.Add('å', 'a');
                spanishCharTranslation.Add('è', 'e');
                spanishCharTranslation.Add('é', 'e');
                spanishCharTranslation.Add('ê', 'e');
                spanishCharTranslation.Add('ë', 'e');
                spanishCharTranslation.Add('ì', 'i');
                spanishCharTranslation.Add('í', 'i');
                spanishCharTranslation.Add('ï', 'i');
                spanishCharTranslation.Add('ó', 'o');
                spanishCharTranslation.Add('ô', 'o');
                spanishCharTranslation.Add('õ', 'o');
                spanishCharTranslation.Add('ö', 'o');
                spanishCharTranslation.Add('ú', 'u');
                spanishCharTranslation.Add('ù', 'u');
                spanishCharTranslation.Add('û', 'u');
                spanishCharTranslation.Add('ü', 'u');
                spanishCharTranslation.Add('ý', 'y');
                spanishCharTranslation.Add('ÿ', 'y');
                spanishCharTranslation.Add('ñ', 'n');
                spanishCharTranslation.Add('ç', 'c');
                spanishCharTranslation.Add('Í', 'I');

                // Not Spanish, but this is a good place
                // to include this.
                spanishCharTranslation.Add(Convert.ToChar(8211), '-');  // en dash
                spanishCharTranslation.Add(Convert.ToChar(8212), '-');  // em dash
            }

            StringBuilder newName = new StringBuilder();
            foreach (char c in name.ToCharArray())
            {
                if (spanishCharTranslation.ContainsKey(c))
                    newName.Append(spanishCharTranslation[c]);
                else
                {
                    if ((c != '¡') && (c != '¿'))
                        newName.Append(c);
                }
            }

            return newName.ToString();
        }

        protected string TranslateMexicanState(string state)
        {
            if (string.IsNullOrEmpty(state))
                return state;

            if (state.ToLower() == "mexico estado")
                return "Estado de Mexico";

            return state;

        }
    }
}
