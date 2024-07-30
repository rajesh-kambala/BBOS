using LumenWorks.Framework.IO.Csv;
using PRCo.EBB.BusinessObjects;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Net;
using System.Text;
using TSI.Utils;

namespace MadisonLumberImporter
{
    public class Importer
    {
        public const string COL_BBID = "BBID";
        public const string COL_NAME = "Name of Mill";
        public const string COL_TYPEOFMILL = "Type of mill";
        public const string COL_REGION = "Region";
        public const string COL_CURTAILED = "Curtailed Y/N";
        public const string COL_EMPLOYEES = "Employees";
        public const string COL_MILLSTATUS = "Mill Status";

        protected bool _commit = false;
        protected string _szOutputPath;
        protected string _szFileError;
        protected string _szFileNewCompanies;
        protected string _szFileNewMatches;
        protected string _szFileUnmatched;
        protected string _szFileMultipleMatches;
        protected string _szFileUnlistedNewMatches;
        protected string _szFileOutput;
        protected string _szFileNameTimestamp;

        public bool Commit
        {
            get { return _commit; }
            set { _commit = value; }
        }

        public string OutputPath
        {
            get { return _szOutputPath; }
            set { _szOutputPath = value; }
        }

        public string FileError
        {
            get { return _szFileError; }
            set { _szFileError = value; }
        }

        public string FileNewCompanies
        {
            get { return _szFileNewCompanies; }
            set { _szFileNewCompanies = value; }
        }

        public string FileNewMatches
        {
            get { return _szFileNewMatches; }
            set { _szFileNewMatches = value; }
        }

        public string FileUnmatched
        {
            get { return _szFileUnmatched; }
            set { _szFileUnmatched = value; }
        }

        public string FileMultipleMatches
        {
            get { return _szFileMultipleMatches; }
            set { _szFileMultipleMatches = value; }
        }

        public string FileUnlistedNewMatches
        {
            get { return _szFileUnlistedNewMatches; }
            set { _szFileUnlistedNewMatches = value; }
        }

        public string FileOutput
        {
            get { return _szFileOutput; }
            set { _szFileOutput = value; }
        }
        
        public string FileNameTimestamp
        {
            get { return _szFileNameTimestamp; }
            set { _szFileNameTimestamp = value; }
        }

        List<string> lstFileNewCompanies = new List<string>();
        List<string> lstFileError = new List<string>();
        List<string> lstFileMultipleMatches = new List<string>();
        List<string> lstFileUnlistedNewMatches = new List<string>();

        List<string> lstFileNewMatches = new List<string>();
        List<string> lstFileUnmatched = new List<string>();

        public void ExecuteImport(string inputFile)
        {
            DateTime dtStart = DateTime.Now;

            SqlTransaction sqlTrans = null;
            using (SqlConnection sqlConn = new SqlConnection(ConfigurationManager.ConnectionStrings["TSIUtils"].ConnectionString))
            {
                sqlConn.Open();

                Dictionary<int, PRMadisonLumber> ImportDataByBBID = new Dictionary<int, PRMadisonLumber>();
                Dictionary<string, PRMadisonLumber> ImportDataByDataKey = new Dictionary<string, PRMadisonLumber>();

                LoadFile(sqlConn, inputFile, ImportDataByBBID, ImportDataByDataKey);

                WriteLine("");

                foreach (KeyValuePair<string, PRMadisonLumber> data in ImportDataByDataKey)
                {
                    if (data.Value.OriginalCompanyID == -1 && data.Value.IsValid)
                    {
                        try
                        {
                            data.Value.CreateCRMCompany(sqlConn, _commit);
                            
                            string szLogEntry = string.Format("BBID {0}: {1}", data.Value.prml_CompanyID, data.Key);
                            lstFileNewCompanies.Add(szLogEntry);
                            WriteLine(" - Company Created in CRM - " + szLogEntry);
                        }
                        catch (Exception e)
                        {
                            lstFileError.Add(e.Message);
                            WriteLine(e.Message);
                        }
                    }

                    sqlTrans = sqlConn.BeginTransaction();

                    try
                    {
                        if (!data.Value.IsValid)
                        {
                            foreach (string szMessage in data.Value.Messages)
                            {
                                lstFileError.Add(data.Key + ": " + szMessage);
                            }
                            WriteLine(" - Company was not Valid: " + data.Key);
                            continue;
                        }

                        if (data.Value.IsMultiMatch)
                        {
                            string szLogEntry = string.Format("{0} - Matches: {1}", data.Key, string.Join(", ", data.Value.MatchedCompanyIDs));
                            lstFileMultipleMatches.Add(szLogEntry);
                            WriteLine(" - Company Is Multi-Match - " + szLogEntry);
                            continue;
                        }

                        if (data.Value.prml_CompanyID > 0 && !data.Value.MergedElsewhere)
                        {
                            data.Value.Save(sqlTrans);
                        }

                        if (data.Value.OriginalCompanyID != 0)
                            continue;
                            
                        if (data.Value.IsNewMatch)
                        {
                            string szLogEntry = string.Format("{0}, {1}, {2}, {3}", data.Value.prml_CompanyID, data.Value.prml_Name.Replace("\"", "").Replace(",", ""), data.Value.prml_Region.Replace("\"", "").Replace(",", ""), data.Value.ListingStatus);

                            if (data.Value.ListingStatus != "L" && data.Value.ListingStatus != "H" && data.Value.ListingStatus != "LUV")
                            {
                                lstFileUnlistedNewMatches.Add(szLogEntry);
                                WriteLine(" - Company Is Unlisted New Match - ListingStatus=" + data.Value.ListingStatus + " - " + szLogEntry);
                            }
                            else
                            {
                                lstFileNewMatches.Add(szLogEntry);
                                WriteLine(" - Company Is Listed New Match - ListingStatus=" + data.Value.ListingStatus + " - " + szLogEntry);
                            }
                        }
                        else
                        {
                            //Unmatched
                            PRMadisonLumberAddress oContactAddress1 = null;
                            string szAddress1 = "";
                            string szAddress2 = "";
                            string szCity = "";
                            string szStateProvince = "";
                            string szPhoneType = "";
                            string szPhone = "";
                            foreach(PRMadisonLumberAddress oAddress in data.Value.GetPRMadisonLumberAddresses())
                            {
                                if(oAddress.prmla_AddressTypeCode == PRMadisonLumberAddress.ADDRESSTYPECODE_CONTACT)
                                {
                                    oContactAddress1 = oAddress;
                                    szAddress1 = oAddress.prmla_AddressLine1.Replace("\"", "").Replace(",", "");
                                    szAddress2 = oAddress.prmla_AddressLine2.Replace("\"", "").Replace(",", "");
                                    szCity = oAddress.prmla_City.Replace("\"", "").Replace(",", "");
                                    szStateProvince = oAddress.prmla_StateProvince.Replace("\"", "").Replace(",", "");
                                    break;
                                }
                            }

                            PRMadisonLumberPhone oPhone1 = null;
                            foreach (PRMadisonLumberPhone oPhone in data.Value.GetPRMadisonLumberPhones())
                            {
                                if (oPhone.prmlp_PhoneTypeCode == PRMadisonLumberPhone.PHONETYPECODE_PHONE)
                                {
                                    oPhone1 = oPhone;
                                    szPhoneType = oPhone.prmlp_PhoneType.Replace("\"", "").Replace(",", "");
                                    szPhone = oPhone.prmlp_Phone.Replace("\"", "").Replace(",", "");
                                    break;
                                }
                            }

                            string szLogEntry = string.Format("{0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}", 
                                data.Value.prml_Name.Replace("\"", "").Replace(",", ""), 
                                data.Value.prml_Region.Replace("\"", "").Replace(",", ""),
                                szAddress1,
                                szAddress2,
                                szCity,
                                szStateProvince,
                                szPhoneType,
                                szPhone
                            );

                            lstFileUnmatched.Add(szLogEntry);
                            WriteLine(" - Company Is Unmatched- " + szLogEntry);
                        }

                    }
                    catch (Exception e)
                    {
                        lstFileError.Add(e.StackTrace);
                        WriteLine(e.Message);
                        sqlTrans.Rollback();
                    }
                    finally
                    {
                        if (_commit)
                        {
                            sqlTrans.Commit();
                        }
                        else
                            sqlTrans.Rollback();
                    }
                }

                WriteOutputFiles();
                WriteLine("          Execution Time: " + DateTime.Now.Subtract(dtStart).ToString());
                WriteOuptutBuffer();
            }
        }

        private void LoadFile(SqlConnection sqlConn, string inputFile, Dictionary<int, PRMadisonLumber> ImportDataByBBID, Dictionary<string, PRMadisonLumber> ImportDataByDataKey)
        {
            int count = 0;
            int totalCount = 0;
            int skipCount = 0;
            int mergeCount = 0;

            WriteLine("Importing " + inputFile);

            using (CsvReader csvCount = new CsvReader(new StreamReader(inputFile), true)) //'\t'
            {
                while (csvCount.ReadNextRecord())
                {
                    totalCount++;
                }
            }

            WriteLine("");

            using (var reader = new StreamReader(inputFile, Encoding.GetEncoding("latin1")))
            {
                using (var csv = new CsvReader(reader, true)) //'\t'
                {
                    int fieldCount = csv.FieldCount;
                    csv.MissingFieldAction = MissingFieldAction.ReplaceByNull;
                    csv.UseColumnDefaults = true;

                    csv.DuplicateHeaderEncountered += (s, e) => e.HeaderName = $"{e.HeaderName}_{e.Index}";

                    PRMadisonLumberMgr oPRMadisonLumberMgr = new PRMadisonLumberMgr();
                    IDbTransaction oTrans = oPRMadisonLumberMgr.BeginTransaction();
                    while (csv.ReadNextRecord())
                    {
                        try
                        {
                            count++;

                            if (!string.IsNullOrEmpty(csv["Mill Status"]))
                            {
                                skipCount++;
                                WriteLine(string.Format("Skipping record {0:###,##0} of {1:###,##0} because it had a value in the Mill Status column.", count, totalCount));
                                continue;
                            }
                            else if (string.IsNullOrEmpty(csv["Name of Mill"]))
                            {
                                skipCount++;
                                WriteLine(string.Format("Skipping record {0:###,##0} of {1:###,##0} because it had a blank Name of Mill value.", count, totalCount));
                                continue;
                            }
                            else
                                WriteLine(string.Format("Loading record {0:###,##0} of {1:###,##0}: {2}-{3}", count, totalCount, string.IsNullOrEmpty(csv["Name of Mill"]) ?"": csv["Name of Mill"], csv["BBID"]));

                            // Load the data into something usable
                            string szBBID = csv["BBID"];
                            int BBID = 0;

                            PRMadisonLumber oPRMadisonLumber = (PRMadisonLumber)oPRMadisonLumberMgr.CreateObject();
                            string key1 = csv[COL_NAME] + ":" + csv[COL_REGION];
                            string key2 = csv[COL_NAME] + ":" + csv[COL_REGION] + ":" + csv["BBID"];

                            //If there is a BBID value in the import record, check to see if that value exists in ImportDataByBBID.
                            //If so, retrieve that PRMadisonLumber instance and invoke PRMadisonLumber.Merge().  Continue to the next record.  Note: Skip this if BBID=-1.
                            if (!string.IsNullOrEmpty(szBBID) && szBBID != "-1")
                            {
                                BBID = Convert.ToInt32(szBBID);
                                if (ImportDataByBBID.ContainsKey(BBID))
                                {
                                    mergeCount++;
                                    PRMadisonLumber oRecordToMerge = ImportDataByBBID[BBID];
                                    oRecordToMerge.Merge(csv);
                                    WriteLine(string.Format("   - Merging record {0:###,##0} of {1:###,##0} with BBID {2}", count, totalCount, oRecordToMerge.prml_CompanyID));
                                    continue;
                                }

                                oPRMadisonLumber.Load(csv);
                                ImportDataByDataKey.Add(key2, oPRMadisonLumber);
                                oPRMadisonLumber.prml_CompanyID = BBID;
                            }
                            else
                            {
                                if (ImportDataByDataKey.ContainsKey(key1) || ImportDataByDataKey.ContainsKey(key2))
                                {
                                    mergeCount++;

                                    PRMadisonLumber oRecordToMerge;
                                    if (ImportDataByDataKey.ContainsKey(key1))
                                    {
                                        oRecordToMerge = ImportDataByDataKey[key1];
                                    }
                                    else
                                    {
                                        oRecordToMerge = ImportDataByDataKey[key2];
                                    }

                                    oRecordToMerge.Merge(csv);
                                    if (oRecordToMerge.prml_CompanyID > 0)
                                        WriteLine(string.Format("   - Merging record {0:###,##0} of {1:###,##0} with BBID {2}: {3}", count, totalCount, oRecordToMerge.prml_CompanyID, key1));
                                    else
                                        WriteLine(string.Format("   - Merging record {0:###,##0} of {1:###,##0} with {2}", count, totalCount, key1));
                                    continue;
                                }

                                oPRMadisonLumber.Load(csv);
                                ImportDataByDataKey.Add(key1, oPRMadisonLumber);

                                if (oPRMadisonLumber.OriginalCompanyID != -1)
                                    oPRMadisonLumber.FindCompanyMatch();
                            }

                            //Validate data so that IsValid and Messages are created.
                            oPRMadisonLumber.Validate(sqlConn);

                            if (oPRMadisonLumber.prml_CompanyID > 0)
                            {
                                if (ImportDataByBBID.ContainsKey(oPRMadisonLumber.prml_CompanyID))
                                {
                                    mergeCount++;
                                    PRMadisonLumber oRecordToMerge = ImportDataByBBID[oPRMadisonLumber.prml_CompanyID];
                                    WriteLine(string.Format("   - Merging record {0:###,##0} of {1:###,##0} with BBID {2}: {3}", count, totalCount, oRecordToMerge.prml_CompanyID, key1));
                                    oRecordToMerge.Merge(csv);
                                    oPRMadisonLumber.MergedElsewhere = true; // flag this record as Merged so that it can be ignored on save
                                }
                                else
                                {
                                    ImportDataByBBID.Add(oPRMadisonLumber.prml_CompanyID, oPRMadisonLumber);
                                }
                            }
                        }
                        catch (Exception ex)
                        {
                            lstFileError.Add(ex.Message);
                        }
                    }

                    if (Commit)
                        oTrans.Commit();
                    else
                        oTrans.Rollback();

                    WriteLine("");
                    WriteLine(string.Format("Files Read: {0}", count));
                    WriteLine(string.Format("Files Skipped: {0}", skipCount));
                    WriteLine(string.Format("Files Merged: {0}", (mergeCount)));
                    WriteLine("");
                }
            }
        }

        public void DeleteData()
        {
            if (Commit)
            {
                PRMadisonLumberMgr oMgr = new PRMadisonLumberMgr();
                oMgr.DeleteData();
            }
        }

        protected List<string> _lszOutputBuffer = new List<string>();

        private void WriteLine(string msg)
        {
            Console.WriteLine(msg);
            _lszOutputBuffer.Add(msg);
        }

        private void WriteOuptutBuffer()
        {
            FileOutput = Path.Combine(_szOutputPath, string.Format("MadisonLumber_Data_{0}.txt", _szFileNameTimestamp));
            using (StreamWriter sw = new StreamWriter(FileOutput))
            {
                foreach (string line in _lszOutputBuffer)
                {
                    sw.WriteLine(line);
                }
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="MMWCompanies"></param>
        /// <returns>Returns the full path and filename of the LocalSource_NewCRMMatches csv file so that it can be uploaded to ftp</returns>
        private void WriteOutputFiles() //Dictionary<string, Company> MMWCompanies)
        {
            FileNewCompanies = Path.Combine(_szOutputPath, string.Format("MadisonLumber_NewCompany_{0}.txt", _szFileNameTimestamp));
            using (StreamWriter sw = new StreamWriter(FileNewCompanies))
            {
                foreach (string line in lstFileNewCompanies)
                {
                    sw.WriteLine(line);
                }
            }

            FileError = Path.Combine(_szOutputPath, string.Format("MadisonLumber_Invalid_{0}.txt", _szFileNameTimestamp));
            using (StreamWriter sw = new StreamWriter(FileError))
            {
                foreach (string line in lstFileError)
                {
                    sw.WriteLine(line);
                }
            }

            FileMultipleMatches = Path.Combine(_szOutputPath, string.Format("MadisonLumber_MultipleCRMMatch_{0}.txt", _szFileNameTimestamp));
            using (StreamWriter sw = new StreamWriter(FileMultipleMatches))
            {
                foreach (string line in lstFileMultipleMatches)
                {
                    sw.WriteLine(line);
                }
            }

            FileUnlistedNewMatches = Path.Combine(_szOutputPath, string.Format("MadisonLumber_NewCRMMatch_Unlisted_{0}.csv", _szFileNameTimestamp));
            using (StreamWriter sw = new StreamWriter(FileUnlistedNewMatches))
            {
                sw.WriteLine("BBID, Mill Name, Region, Listing Status");
                foreach (string line in lstFileUnlistedNewMatches)
                {
                    sw.WriteLine(line);
                }
            }

            FileNewMatches = Path.Combine(_szOutputPath, string.Format("MadisonLumber_NewCRMMatch_{0}.csv", _szFileNameTimestamp));
            using (StreamWriter sw = new StreamWriter(FileNewMatches))
            {
                sw.WriteLine("BBID, Mill Name, Region, Listing Status");
                foreach (string line in lstFileNewMatches)
                {
                    sw.WriteLine(line);
                }
            }

            //We need to create a new output file from the importer.  Kathi remined me they need an "unmatched" file so they can process those and either manual match them, create a company, or tell the importer to create a company.
            //Let's make this output file a CSV with columns for Mill Name and Region.  They will probably ask us to expand on that later.
            FileUnmatched = Path.Combine(_szOutputPath, string.Format("MadisonLumber_UnmatchedCRM_{0}.csv", _szFileNameTimestamp));
            using (StreamWriter sw = new StreamWriter(FileUnmatched))
            {
                sw.WriteLine("Mill Name, Region, Contact Address Line 1, Contact Address Line 2, Contact Address City, Contact Address State/Province, Phone Type, Phone Number");

                foreach (string line in lstFileUnmatched)
                {
                    sw.WriteLine(line);
                }
            }
        }


    }
}