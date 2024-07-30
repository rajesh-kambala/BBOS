// http://www.codeproject.com/Articles/9258/A-Fast-CSV-Reader

using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using CommandLine.Utility;

using LumenWorks.Framework.IO.Csv;
namespace PostalDataImport
{
    public class PostalDataImporter
    {
        const string PR_POSTALCODE_TABLE = "PRPostalCode";
        const int BATCH_SIZE = 10000;

        const string COUNTRY_USA = "USA";
        const string COUNTRY_CANADA = "Canada";

        bool _blnCommit = false;
        string _szCountry;

        public void Import(string[] args)
        {
            DateTime dtStart = DateTime.Now;
            
            _szPath = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Substring(6);

            Console.Clear();
            Console.Title = "Postal Data Importer Utility";

            WriteLine("Postal Data Importer Utility 3.0");
            WriteLine("Copyright (c) 2023 Blue Book Services, Inc.");
            WriteLine("All Rights Reserved.");
            WriteLine("  OS Version: " + System.Environment.OSVersion.ToString());
            WriteLine(" CLR Version: " + System.Environment.Version.ToString());
            WriteLine(string.Empty);
            WriteLine("Started: " + DateTime.Now.ToString("M/dd/yyyy hh:mm tt"));
            WriteLine(string.Empty);

            Arguments oCommandLine = new Arguments(args);
            if (oCommandLine["File"] == null)
            {
                WriteLine("/File= parameter missing.");
                return;
            }
            else
                WriteLine("/File= " + oCommandLine["File"]);

            if (!File.Exists(oCommandLine["File"]))
            {
                WriteLine("The specified file is not found.");
                return;
            }

            if (oCommandLine["Country"] == null)
            {
                WriteLine("/Country= parameter missing (" + COUNTRY_USA + " or " + COUNTRY_CANADA + ")");
                return;
            }
            else if (oCommandLine["Country"].ToLower() != COUNTRY_USA.ToLower() && oCommandLine["Country"].ToLower() != COUNTRY_CANADA.ToLower())
            {
                WriteLine("/Country= parameter must be either " + COUNTRY_USA + " or " + COUNTRY_CANADA);
                return;
            }
            else
            {
                WriteLine("/Country= " + oCommandLine["Country"]);
                if (oCommandLine["Country"].ToLower() == COUNTRY_CANADA.ToLower())
                    _szCountry = COUNTRY_CANADA;
                else
                    _szCountry = COUNTRY_USA;
            }

            if (!string.IsNullOrEmpty(oCommandLine["Commit"]) && oCommandLine["Commit"].ToLower() == "true")
            {
                _blnCommit = true;
                WriteLine("/Commit = TRUE    <-- DATA WILL BE WRITTEN TO DATABASE -->");
                
                Console.Write("Press any key to continue . . . ");
                Console.ReadKey(true);
            }
            else
            {
                _blnCommit = false;
                WriteLine("/Commit = FALSE");
            }

            try
            {
                if (_szCountry == COUNTRY_USA)
                    ExecuteImportUSPostalCodes(oCommandLine["File"]);
                else
                    ExecuteImportCanadianPostalCodes(oCommandLine["File"]);
            }
            catch(Exception e)
            {
                WriteLine(DateTime.Now.ToString());
                WriteLine("An unexpected exception occurred: " + e.Message);

                Console.WriteLine();
                Console.WriteLine();
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine(DateTime.Now.ToString());
                Console.WriteLine("An unexpected exception occurred: " + e.Message);
                Console.WriteLine(e.StackTrace);
                Console.WriteLine("Terminating execution.");
                Console.ForegroundColor = ConsoleColor.Gray;

                WriteOuptutBuffer();

                using (StreamWriter sw = new StreamWriter(Path.Combine(_szPath, "PostalDataImporter_Exception.txt")))
                {
                    sw.WriteLine(e.Message + Environment.NewLine);
                    sw.WriteLine(e.StackTrace);
                }
            }
        }

        private void ExecuteImportUSPostalCodes(string szFile)
        {
            DateTime dtStart = DateTime.Now;

            List<USPostalRecord> usPostalRecords = new List<USPostalRecord>();
            int recordCount = LoadFileUSPostalCodes(szFile, usPostalRecords);

            WriteLine("");
            WriteLine("Records to Process: " + recordCount.ToString("###,##0"));

            using (SqlConnection sqlConn = new SqlConnection(ConfigurationManager.ConnectionStrings["SQLServer"].ConnectionString))
            {
                sqlConn.Open();

                InsertUSPostalCodes(usPostalRecords, sqlConn);
                RefreshPRCity(sqlConn);
            }

            WriteLine(string.Empty);
            WriteLine("            Record Count: " + recordCount.ToString("###,##0"));
            WriteLine("          Execution Time: " + DateTime.Now.Subtract(dtStart).ToString());

            WriteOuptutBuffer();
        }

        private void ExecuteImportCanadianPostalCodes(string szFile)
        {
            //Switched to this canadian data in July 2022 because PerfectAddress stopped providing Canadian data
            //https://www.zip-codes.com/canadian-postal-code-database.asp
            DateTime dtStart = DateTime.Now;

            List<CanadianPostalRecord> lstCanadianPostalRecorda = new List<CanadianPostalRecord>();
            int recordCount = LoadFileCanadianPostalCodes(szFile, lstCanadianPostalRecorda);

            WriteLine("");
            WriteLine("Records to Process: " + recordCount.ToString("###,##0"));

            using (SqlConnection sqlConn = new SqlConnection(ConfigurationManager.ConnectionStrings["SQLServer"].ConnectionString))
            {
                sqlConn.Open();
                ImportCanadianPostalCodes(lstCanadianPostalRecorda, sqlConn);
            }

            WriteLine(string.Empty);
            WriteLine("            Record Count: " + recordCount.ToString("###,##0"));
            WriteLine("          Execution Time: " + DateTime.Now.Subtract(dtStart).ToString());

            WriteOuptutBuffer();
        }

        private void InsertUSPostalCodes(List<USPostalRecord> usPostalRecords, SqlConnection sqlConn)
        {
            int count = 0;

            StringBuilder sb = new StringBuilder();
            foreach (USPostalRecord rec in usPostalRecords)
            {
                count++;
                WriteLine($" - Processing {count:###,##0} of {usPostalRecords.Count:###,##0}: {rec.Zip}");

                sb.Append($"IF NOT EXISTS(SELECT 'x' FROM {PR_POSTALCODE_TABLE} WHERE prpc_PostalCode='{rec.Zip}') BEGIN ");
                sb.Append($"INSERT INTO {PR_POSTALCODE_TABLE} (prpc_PostalCode, prpc_Latitude, prpc_Longitude, prpc_City, prpc_State, prpc_County, prpc_TimezoneOffset, prpc_DST, prpc_CreatedBy, prpc_UpdatedBy) VALUES (");
                sb.Append("'");
                sb.Append(rec.Zip);
                sb.Append("',");
                sb.Append(rec.Lat);
                sb.Append(",");
                sb.Append(rec.Long);
                sb.Append(",'");
                sb.Append(rec.City.Replace("'", "''"));
                sb.Append("','");
                sb.Append(rec.State);
                sb.Append("','");
                sb.Append(rec.County.Replace("'", "''"));
                sb.Append("',");
                sb.Append((0-Convert.ToDecimal(rec.Timezone)).ToString());
                sb.Append(",'");
                sb.Append(rec.DST);
                sb.Append("',-1,-1);");
                sb.Append($" END");
                sb.Append(Environment.NewLine);

                if (count % BATCH_SIZE == 0)
                {
                    //Commit batch or StringBuilder might get too large and cause memory error
                    if (_blnCommit)
                    {
                        SqlCommand sqlCommand = new SqlCommand(sb.ToString(), sqlConn);
                        sqlCommand.CommandTimeout = 180;
                        sqlCommand.ExecuteNonQuery();
                    }
                    sb = new StringBuilder();
                }
            }

            //Final batch
            if (sb.Length > 0)
            {
                if (_blnCommit)
                {
                    SqlCommand sqlCommand = new SqlCommand(sb.ToString(), sqlConn);
                    sqlCommand.ExecuteNonQuery();
                }
            }
        }

        private void ImportCanadianPostalCodes(List<CanadianPostalRecord> lstZipCodeRecords, SqlConnection sqlConn)
        {
            int count = 0;

            StringBuilder sb = new StringBuilder();
            foreach (CanadianPostalRecord rec in lstZipCodeRecords)
            {
                count++;
                WriteLine($" - Processing {count:###,##0} of {lstZipCodeRecords.Count:###,##0}: {rec.PostalCode}");

                sb.Append($"IF NOT EXISTS(SELECT 'x' FROM {PR_POSTALCODE_TABLE} WHERE prpc_PostalCode='{rec.PostalCode}') BEGIN ");
                sb.Append($"INSERT INTO {PR_POSTALCODE_TABLE} (prpc_PostalCode, prpc_Latitude, prpc_Longitude, prpc_City, prpc_State, prpc_CreatedBy, prpc_UpdatedBy) VALUES (");

                sb.Append("'");
                sb.Append(rec.PostalCode);
                sb.Append("',");
                sb.Append(rec.Latitude);
                sb.Append(",");
                sb.Append(rec.Longitude);
                sb.Append(",'");
                sb.Append(rec.CityMixedCase.Replace("'", "''"));
                sb.Append("','");
                sb.Append(rec.Province.Replace("'", "''"));
                sb.Append("', -1, -1);");
                sb.Append($" END");
                sb.Append(";\r\n");

                if (count % BATCH_SIZE == 0)
                {
                    //Commit batch or StringBuilder might get too large and cause memory error
                    if (_blnCommit)
                    {
                        SqlCommand sqlCommand = new SqlCommand(sb.ToString(), sqlConn);
                        sqlCommand.CommandTimeout = 180;
                        sqlCommand.ExecuteNonQuery();
                    }
                    sb = new StringBuilder();
                }
            }

            //Final batch
            if (sb.Length > 0)
            {
                if (_blnCommit)
                {
                    SqlCommand sqlCommand = new SqlCommand(sb.ToString(), sqlConn);
                    sqlCommand.ExecuteNonQuery();
                }
            }
        }

        const string SQL_REFRESH_PRCITY =
            @"UPDATE PRCity
                SET prci_Timezone = TimeZone,
                    prci_DST = prpc_DST,
                    prci_TimeZoneOffset = prpc_TimezoneOffset,
	                prci_UpdatedDate=GETDATE(),
	                prci_UpdatedBy=-1
               FROM (SELECT DISTINCT prci_CityID, prpc_State, prpc_City, prpc_TimezoneOffset, prpc_DST, 
                                   CASE prpc_TimezoneOffset
	                                    WHEN -3.5 THEN 'NST'
                                        WHEN -4 THEN 'EST+1'
                                        WHEN -5 THEN 'EST'
                                        WHEN -6 THEN 'CST'
                                        WHEN -7 THEN 'MST'
                                        WHEN -8 THEN 'PST'
                                        WHEN -9 THEN 'PST-1'
                                        WHEN -10 THEN 'PST-2'
                                        WHEN -11 THEN 'PST-3'
                                        WHEN -12 THEN 'PST-4'
                                        WHEN -13 THEN 'PST-5'
                                        WHEN -14 THEN 'PST-6'
                                    END as TimeZone
		              FROM PRPostalCode
			               INNER JOIN vPRLocation ON prst_Abbreviation=prpc_State AND prci_City= prpc_City
		             WHERE prcn_CountryId=1) T1
             WHERE PRCity.prci_CityId = T1.prci_CityID
               AND (prci_Timezone IS NULL
                    OR prci_DST IS NULL
		            OR prci_TimeZoneOffset IS NULL);";

        private void RefreshPRCity(SqlConnection sqlConn)
        {
            WriteLine("");
            WriteLine("RefreshPRCity() Begin");
            if (_blnCommit)
            {
                SqlCommand sqlCommand = new SqlCommand(SQL_REFRESH_PRCITY, sqlConn);
                sqlCommand.ExecuteNonQuery();
            }
            WriteLine("RefreshPRCity() End");
        }
        
        private Dictionary<char, char> spanishCharTranslation = null;

        protected string TranslateSpanishCharacters(string name)
        {
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
                spanishCharTranslation.Add('î', 'i');
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
            }

            StringBuilder newName = new StringBuilder();
            foreach (char c in name.ToCharArray())
            {
                if (spanishCharTranslation.ContainsKey(c))
                {
                    newName.Append(spanishCharTranslation[c]);
                }
                else
                {
                    if ((c != '¡') && (c != '¿'))
                    {
                        newName.Append(c);
                    }
                }
            }

            return newName.ToString();
        }

        private int LoadFileUSPostalCodes(string fileName, List<USPostalRecord> usPostalRecords)
        {
            int recordCount = 0;

            USPostalRecord usPostalRecord = null;
            using (CsvReader csv = new CsvReader(new StreamReader(fileName, Encoding.Default), true))
            {
                 int fieldCount = csv.FieldCount;

                while (csv.ReadNextRecord())
                {
                    if (csv["Latitude"] == "")
                        continue; //skip header row

                    recordCount++;

                    usPostalRecord = new USPostalRecord();
                    usPostalRecord.City = TranslateSpanishCharacters(csv["City"]);
                    usPostalRecord.State = csv["State"];
                    usPostalRecord.Zip = csv["ZipCode"];
                    usPostalRecord.AC = csv["AreaCode"];
                    usPostalRecord.County = csv["County"];
                    usPostalRecord.Timezone = csv["TimeZone"];
                    usPostalRecord.DST = csv["DayLightSaving"];
                    usPostalRecord.Lat = csv["Latitude"];
                    usPostalRecord.Long = csv["Longitude"];

                    usPostalRecords.Add(usPostalRecord);
                } // End While
            }

            return recordCount;
        }

        private int LoadFileCanadianPostalCodes(string fileName, List<CanadianPostalRecord> canadianPostalRecords)
        {
            int recordCount = 0;

            CanadianPostalRecord canadianPostalRecord = null;
            using (CsvReader csv = new CsvReader(new StreamReader(fileName, Encoding.Default), true))
            {
                int fieldCount = csv.FieldCount;

                while (csv.ReadNextRecord())
                {
                    if (csv["Latitude"] == "")
                        continue; //skip header row

                    recordCount++;

                    canadianPostalRecord = new CanadianPostalRecord();
                    canadianPostalRecord.PostalCode = csv["PostalCode"];
                    canadianPostalRecord.City = TranslateSpanishCharacters(csv["City"]);
                    canadianPostalRecord.Province = csv["Province"];
                    canadianPostalRecord.AreaCode = csv["AreaCode"];
                    canadianPostalRecord.Latitude = csv["Latitude"];
                    canadianPostalRecord.Longitude = csv["Longitude"];
                    canadianPostalRecord.CityMixedCase = csv["CityMixedCase"];
                    canadianPostalRecord.RecordType = csv["RecordType"];
                    canadianPostalRecords.Add(canadianPostalRecord);
                } 
            }

            return recordCount;
        }

        protected string _szOutputFile;
        protected string _szPath;
        protected List<string> _lszOutputBuffer = new List<string>();

        private void WriteLine(string msg)
        {
            Console.WriteLine(msg);
            _lszOutputBuffer.Add(msg);
        }

        private void WriteOuptutBuffer()
        {
            if (_szOutputFile == null)
                _szOutputFile = Path.Combine(_szPath, $"PostalDataImport_{_szCountry}_{DateTime.Now.ToString("yyyy-MM-dd_HH-mm")}.txt");

            using (StreamWriter sw = new StreamWriter(_szOutputFile))
            {
                foreach (string line in _lszOutputBuffer)
                {
                    sw.WriteLine(line);
                }
            }
        }
    }

    class USPostalRecord
    {
        public string City;
        public string State;
        public string Zip;
        public string AC;
        public string County;
        public string Timezone;
        public string DST;
        public string Lat;
        public string Long;
    }

    class CanadianPostalRecord
    {
        public string PostalCode;
        public string City;
        public string Province;
        public string AreaCode;
        public string Latitude;
        public string Longitude;
        public string CityMixedCase;
        public string RecordType;
    }
}