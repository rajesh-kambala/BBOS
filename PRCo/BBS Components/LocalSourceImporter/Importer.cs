using LumenWorks.Framework.IO.Csv;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Text;

using TSI.Utils;

namespace LocalSourceImporter
{
    public class Importer
    {
        protected bool _commit = false;
        protected bool _processNonFactorCompanies = false;
        protected List<Int32> _nonFactorCompanies = new List<int>();
        protected string _szOutputFile;
        protected string _szPath;
        protected string _szFileNameTimestamp;
        protected List<KeyValuePair<string, int>> _lstMatchExclusions = new List<KeyValuePair<string, int>>();

        public bool Commit
        {
            get { return _commit; }
            set { _commit = value; }
        }

        public bool ProcessNonFactorCompanies
        {
            get { return _processNonFactorCompanies; }
            set { _processNonFactorCompanies = value; }
        }

        public List<Int32> NonFactoryCompanies
        {
            get { return _nonFactorCompanies; }
            set { _nonFactorCompanies = value; }
        }

        private const string SQL_MATCH_EXCLUSIONS =
            @"SELECT DISTINCT prlse_Key, prlse_CompanyID FROM PRLocalSourceMatchExclusion";

        public List<KeyValuePair<string, int>> MatchExclusions
        {
            get
            {
                if (_lstMatchExclusions == null || _lstMatchExclusions.Count == 0)
                {
                    _lstMatchExclusions = new List<KeyValuePair<string, int>>();

                    using (SqlConnection sqlConn = new SqlConnection(ConfigurationManager.ConnectionStrings["TSIUtils"].ConnectionString))
                    {
                        sqlConn.Open();

                        SqlCommand cmdMatchExclusions = new SqlCommand();
                        cmdMatchExclusions.Connection = sqlConn;
                        cmdMatchExclusions.CommandTimeout = 300;
                        cmdMatchExclusions.CommandText = SQL_MATCH_EXCLUSIONS;

                        using (SqlDataReader reader = cmdMatchExclusions.ExecuteReader())
                        {
                            while (reader.Read())
                                _lstMatchExclusions.Add(new KeyValuePair<string, int>(reader.GetString(0), reader.GetInt32(1)));
                        }
                    }
                }

                return _lstMatchExclusions;
            }
        }

        public string OutputPath
        {
            get { return _szPath; }
            set { _szPath = value; }
        }

        public string OutputFile
        {
            get { return _szOutputFile; }
            set { _szOutputFile = value; }
        }

        public string FileNameTimestamp
        {
            get { return _szFileNameTimestamp; }
            set { _szFileNameTimestamp = value; }
        }

        public string FileInvalid
        {
            get;
            set;
        }

        public string FileDuplicates
        {
            get;
            set;
        }

        public string FileMulitpleMatches
        {
            get;
            set;
        }

        public string FileData
        {
            get;
            set;
        }

        public string FileNewMatches
        {
            get;
            set;
        }

        public string FileOrganicFoodSafetyLicense
        {
            get;
            set;
        }

        public string FileNonFactor
        {
            get;
            set;
        }

        public string FilePACADRCLicense
        {
            get;
            set;
        }

        public void ExecuteImport(string inputFile)
        {
            DateTime dtStart = DateTime.Now;

            int matchCount = 0;
            int multipleMatchCount = 0;
            int notFoundCount = 0;

            SqlTransaction sqlTrans = null;
            using (SqlConnection sqlConn = new SqlConnection(ConfigurationManager.ConnectionStrings["TSIUtils"].ConnectionString))
            {
                sqlConn.Open();

                Dictionary<string, Company> MMWCompanies = new Dictionary<string, Company>();
                Dictionary<int, Company> MMWCompaniesByBBID = new Dictionary<int, Company>();

                LoadFile(sqlConn, inputFile, MMWCompanies, MMWCompaniesByBBID);
                MatchWithinFile(sqlConn, MMWCompanies);

                _invalidCount = 0;
                foreach (string key in MMWCompanies.Keys)
                {
                    Company mmwCompany = MMWCompanies[key];
                    if (string.IsNullOrEmpty(mmwCompany.CompanyName))
                        mmwCompany.SetInvalid("No company name found in input file.");

                    if (mmwCompany.CityID == 0)
                        mmwCompany.SetInvalid("Unable to find city in CRM: " + mmwCompany.Addresses[0].City + ", " + mmwCompany.Addresses[0].State + " " + mmwCompany.Addresses[0].Zip);

                    if (mmwCompany.CompanyName.Contains("&AMP;"))
                        mmwCompany.SetInvalid("Invalid characters in company name.");

                    if (!mmwCompany.IsValid)
                        _invalidCount++;
                }

                int maxLoadCompanies = Utilities.GetIntConfigValue("LocalSourceDataImportMaxLoadCompanies", Int32.MaxValue);
                int count = 0;
                WriteLine("");

                foreach (string key in MMWCompanies.Keys)
                {
                    count++;

                    if (count > maxLoadCompanies)
                        break;

                    Company mmwCompany = MMWCompanies[key];
                    WriteLine(string.Format("Processing Company {0:###,##0} of {1:###,##0}: MMW ID {2}", count, MMWCompanies.Keys.Count, mmwCompany.MMWID));

                    if (mmwCompany.Skip)
                        continue;

                    sqlTrans = sqlConn.BeginTransaction();

                    try
                    {
                        if (mmwCompany.CompanyID == 0)
                        {
                            matchOnPhone(sqlTrans, mmwCompany);

                            if (mmwCompany.Matched)
                            {
                                if(MatchExclusions.Contains(new KeyValuePair<string, int>(mmwCompany.MMWID, mmwCompany.CompanyID)))
                                {
                                    //Defect 7077
                                    mmwCompany.Matched = false; 
                                    mmwCompany.MultipleMatchInCRM = false;
                                    WriteLine(" - Ignored Match from Exclusion List");
                                }
                                else
                                    matchCount++;
                            }
                            else
                            {
                                matchOnName(sqlTrans, mmwCompany);
                                if (mmwCompany.Matched)
                                {
                                    if (MatchExclusions.Contains(new KeyValuePair<string, int>(mmwCompany.MMWID, mmwCompany.CompanyID)))
                                    {
                                        //Defect 7077
                                        mmwCompany.Matched = false; 
                                        mmwCompany.MultipleMatchInCRM = false;
                                        notFoundCount++;
                                        WriteLine(" - Ignored Match from Exclusion List");
                                    }
                                    else
                                        matchCount++;
                                }
                                else
                                    notFoundCount++;
                            }

                            if (mmwCompany.MultipleMatchInCRM)
                                multipleMatchCount++;

                            if ((mmwCompany.IsValid) &&
                                (!mmwCompany.MultipleMatchInCRM))
                            {
                                mmwCompany.NewForMMW = true;
                                mmwCompany.SaveCompany(sqlTrans);
                                if (mmwCompany.Matched)
                                    WriteLine(" - Saved matched Company - BBID: " + mmwCompany.CompanyID.ToString());
                                else
                                    WriteLine(" - Saved Unmatched Company - New BBID: " + mmwCompany.CompanyID.ToString());
                            }
                        }
                        else if (mmwCompany.CompanyID == 1)
                        {
                            mmwCompany.SaveCompany(sqlTrans);
                            WriteLine(" - Saved Company - Forced New BBID: " + mmwCompany.CompanyID.ToString());
                        }
                        else
                        {
                            // This record has been previously matched.  Now
                            // See if we should update it.
                            if (mmwCompany.UpdateCRM)
                            {
                                mmwCompany.SaveCompany(sqlTrans);
                                WriteLine(" - Updated Previously Matched Company - BBID: " + mmwCompany.CompanyID.ToString());
                            }
                            else
                            {
                                // IT looks strange saving the company even though we say we're skipping it.  In this context
                                // The CRM company data is left alone, but the Local Source fields are updated.  We do it this
                                // way for bettering tracing. 
                                mmwCompany.SaveCompany(sqlTrans);
                                WriteLine(" - Skipping Previously Matched Company - BBID: " + mmwCompany.CompanyID.ToString());
                            }
                        }

                        if (_commit)
                            sqlTrans.Commit();
                        else
                            sqlTrans.Rollback();
                    }
                    catch
                    {
                        sqlTrans.Rollback();
                        WriteOutputFiles(MMWCompanies);
                        throw;
                    }
                }

                if (_processNonFactorCompanies)
                {
                    sqlTrans = sqlConn.BeginTransaction();
                    try
                    {
                        //
                        //  Now look to see who we should mark Non-Factor
                        //
                        WriteLine(string.Empty);
                        bool foundCompany = false;
                        List<Company> crmCompanies = Company.GetLocalSource(sqlTrans);
                        foreach (Company crmCompany in crmCompanies)
                        {
                            foundCompany = false;
                            foreach (string key in MMWCompanies.Keys)
                            {
                                Company mmwCompany = MMWCompanies[key];

                                if (crmCompany.CompanyID == mmwCompany.CompanyID)
                                {
                                    foundCompany = true;
                                    break;
                                }
                            }

                            if (!foundCompany)
                            {
                                WriteLine(string.Format("Marking Company {0} Non-Factor.", crmCompany.CompanyID));
                                crmCompany.MarkNonFactor(sqlTrans);
                                _nonFactorCompanies.Add(crmCompany.CompanyID);
                            }
                        }

                        if (_commit)
                        {
                            sqlTrans.Commit();
                        }
                        else
                        {
                            sqlTrans.Rollback();
                        }

                    }
                    catch
                    {
                        sqlTrans.Rollback();
                        throw;
                    }
                }

                WriteOutputFiles(MMWCompanies);

                WriteLine(string.Empty);
                WriteLine("            Record Count: " + (MMWCompanies.Count + _dupCount).ToString("###,##0"));
                WriteLine("  Distinct Company Count: " + MMWCompanies.Count.ToString("###,##0"));
                WriteLine("         Duplicate Count: " + _dupCount.ToString("###,##0"));
                WriteLine("           Invalid Count: " + _invalidCount.ToString("###,##0"));
                WriteLine("         CRM Match Count: " + matchCount.ToString("###,##0"));
                WriteLine("Multiple CRM Match Count: " + multipleMatchCount.ToString("###,##0"));
                WriteLine("         Unmatched Count: " + notFoundCount.ToString("###,##0"));
                WriteLine("          Execution Time: " + DateTime.Now.Subtract(dtStart).ToString());

                WriteLine(string.Empty);
                WriteLine("Deleting duplicate LSS persons - " + DateTime.Now.ToString());

                SqlCommand cmdDupPersons = new SqlCommand();
                cmdDupPersons.Connection = sqlConn;
                cmdDupPersons.CommandText = "usp_DeleteDuplicateLSSPersons";
                cmdDupPersons.CommandType = System.Data.CommandType.StoredProcedure;
                cmdDupPersons.CommandTimeout = 1800;
                cmdDupPersons.ExecuteNonQuery();

                WriteLine("          Execution Time: " + DateTime.Now.Subtract(dtStart).ToString());

                WriteOuptutBuffer();
            }
        }


        private const string SQL_MATCH_PHONE =
            @"SELECT DISTINCT comp_PRHQID, comp_PRLocalSource, comp_PRListingStatus, prls_LocalSourceID, prra_RatingId, comp_Name, HasService, comp_PRExcludeFromLocalSource
                FROM Company WITH (NOLOCK) 
                     LEFT OUTER JOIN PRLocalSource WITH (NOLOCK) ON comp_CompanyID = prls_CompanyID 
                     LEFT OUTER JOIN PRRating WITH (NOLOCK) ON comp_CompanyID = prra_CompanyID AND prra_Current = 'Y'
                     LEFT OUTER JOIN (SELECT DISTINCT prse_CompanyID, 'Y' as HasService FROM PRService) T1 ON comp_CompanyID = prse_CompanyID
               WHERE comp_PRListingStatus NOT IN ('D')
			     AND comp_PRType = 'H'
                 AND comp_PRIndustryType = 'P'
			     AND comp_PRHQID IN (
						   SELECT DISTINCT comp_PRHQID
							 FROM Company WIT (NOLOCK)
								  INNER JOIN vPRPhone WITH (NOLOCK) ON comp_CompanyID = phon_CompanyID
							WHERE phon_CompanyID IS NOT NULL 
                              AND comp_PRIndustryType = 'P'
							  AND ({0}))
            ORDER BY comp_PRHQID";


        private SqlCommand cmdMatchPhone = null;
        protected void matchOnPhone(SqlTransaction sqlTrans, Company mmwCompany)
        {
            if (mmwCompany.Phones.Count == 0)
            {
                return;
            }

            WriteLine(" - Matching in CRM on Phone");

            if (cmdMatchPhone == null)
            {
                cmdMatchPhone = new SqlCommand();
                cmdMatchPhone.Connection = sqlTrans.Connection;
                cmdMatchPhone.CommandTimeout = 300;
            }

            cmdMatchPhone.Transaction = sqlTrans;
            cmdMatchPhone.Parameters.Clear();

            int phoneCount = 0;
            string parmName = null;
            StringBuilder sbClause = new StringBuilder();
            foreach (Phone phone in mmwCompany.Phones)
            {
                if (sbClause.Length > 0)
                {
                    sbClause.Append(" OR ");
                }

                parmName = "Phone" + phoneCount.ToString();
                phoneCount++;
                sbClause.Append("phon_PhoneMatch=dbo.GetLowerAlpha(@" + parmName + ")");
                cmdMatchPhone.Parameters.AddWithValue(parmName, phone.Number);
            }

            cmdMatchPhone.CommandText = string.Format(SQL_MATCH_PHONE, sbClause.ToString());

            //foreach (SqlParameter parm in cmdMatchPhone.Parameters)
            //{
            //    Console.WriteLine("DECLARE @" + parm.ParameterName + " varchar(25) ='" + parm.Value.ToString() + "'");
            //}
            //Console.WriteLine(cmdMatchPhone.CommandText);

            int count = 0;
            using (SqlDataReader reader = cmdMatchPhone.ExecuteReader())
            {
                while (reader.Read())
                {
                    count++;
                    mmwCompany.MatchType = "Phone";

                    if (reader[1] != DBNull.Value)
                    {
                        mmwCompany.IsLocalSource = true;
                    }

                    if (count == 1)
                    {
                        mmwCompany.IsValid = true;
                        mmwCompany.Matched = true;
                        mmwCompany.NewRecord = false;
                        mmwCompany.UpdateCRM = false;
                        mmwCompany.SetCompanyID(reader.GetInt32(0));
                        mmwCompany.MultipleMatchCompanyIDs = reader.GetInt32(0).ToString();

                        if (reader[3] != DBNull.Value)
                        {
                            mmwCompany.LocalSourceID = reader.GetInt32(3);
                        }

                        if (mmwCompany.IsLocalSource)
                        {
                            mmwCompany.UpdateCRM = true;
                        }
                        else
                        {
                            if ((reader.GetString(2) != "L") &&
                                (reader.GetString(2) != "H") &&
                                (reader.GetString(2) != "N1") &&
                                (reader.GetString(2) != "N5") &&
                                (reader.GetString(2) != "N6"))
                            {
                                // Doesn't have a service
                                if (reader[6] == DBNull.Value)
                                {
                                    mmwCompany.UpdateCRM = true;
                                }
                                else
                                {
                                    WriteLine(" - Found unlisted with a service.");
                                }
                            }
                        }

                        if ((reader[7] != DBNull.Value) &&
                            (reader.GetString(7) == "Y"))  // The Do Not Match flag
                        {
                            mmwCompany.UpdateCRM = false;
                            WriteLine(" - Found unlisted company with the Do Not Match flag set.");
                        }

                        if (reader[4] != DBNull.Value)
                        {
                            mmwCompany.HasRating = true;
                            mmwCompany.RatingID = reader.GetInt32(4);
                        }

                        if (string.IsNullOrEmpty(mmwCompany.CompanyName))
                        {
                            mmwCompany.CompanyName = reader.GetString(5);
                        }
                    }
                    else
                    {
                        if (reader[0] != DBNull.Value)
                        {
                            mmwCompany.MultipleMatchInCRM = true;
                            mmwCompany.MultipleMatchCompanyIDs += ", " + reader.GetInt32(0).ToString();
                            mmwCompany.UpdateCRM = false;
                            mmwCompany.NewRecord = false;
                        }
                    }

                    WriteLine(" - Found BBID: " + mmwCompany.MultipleMatchCompanyIDs + "(by phone " + cmdMatchPhone.Parameters[0].Value + "; MMWID=" + mmwCompany.MMWID + ")");
                }
            }

            // IF this is not a local soruce record but
            // we will be converting it to a local source
            // record, check for key existng data.
            if ((mmwCompany.CompanyID > 0) &&
                (mmwCompany.UpdateCRM))
            {
                mmwCompany.CheckForExistingData(sqlTrans.Connection, sqlTrans);
            }
        }

        private const string SQL_MATCH_NAME =
              @"SELECT DISTINCT comp_PRHQID, comp_PRLocalSource, comp_PRListingStatus, prls_LocalSourceID, prra_RatingId, comp_Name, HasService, comp_PRExcludeFromLocalSource
                        FROM Company WITH (NOLOCK) 
                             LEFT OUTER JOIN PRLocalSource WITH (NOLOCK) ON comp_CompanyID = prls_CompanyID 
                             LEFT OUTER JOIN PRRating WITH (NOLOCK) ON comp_CompanyID = prra_CompanyID AND prra_Current = 'Y'
                             LEFT OUTER JOIN (SELECT DISTINCT prse_CompanyID, 'Y' as HasService FROM PRService) T1 ON comp_CompanyID = prse_CompanyID
                       WHERE comp_PRListingStatus NOT IN ('D')
			             AND comp_PRType = 'H'
                         AND comp_PRIndustryType = 'P'
			             AND comp_PRHQID IN (
						           SELECT DISTINCT comp_PRHQID
							         FROM Company WIT (NOLOCK)
								          INNER JOIN dbo.ufn_SearchByCompanyName(@CompanyName) ON comp_CompanyID = CompanyID
								          LEFT OUTER JOIN vPRAddress ON comp_CompanyID = adli_CompanyID
			                        WHERE comp_PRListingStatus NOT IN ('D')
                                      AND comp_PRIndustryType = 'P'
                                      AND (comp_PRListingCityID IN ({0})
                                           OR addr_PRCityID IN ({0})))
                    ORDER BY comp_PRHQID";

        private SqlCommand cmdMatchName = null;
        protected void matchOnName(SqlTransaction sqlTrans, Company mmwCompany)
        {
            if (string.IsNullOrEmpty(mmwCompany.CompanyName))
            {
                mmwCompany.IsValid = false;
                return;
            }

            if (mmwCompany.CityID == 0)
            {
                return;
            }

            WriteLine(" - Matching in CRM on Company Name and City/State");

            if (cmdMatchName == null)
            {
                cmdMatchName = new SqlCommand();
                cmdMatchName.Connection = sqlTrans.Connection;
                cmdMatchName.CommandTimeout = 300;
            }

            cmdMatchName.Transaction = sqlTrans;
            cmdMatchName.CommandText = string.Format(SQL_MATCH_NAME, mmwCompany.GetCityIDs());
            cmdMatchName.Parameters.Clear();
            cmdMatchName.Parameters.AddWithValue("CompanyName", mmwCompany.CompanyName);
            //cmdMatchName.Parameters.AddWithValue("CityID", mmwCompany.CityID);

            int count = 0;
            using (SqlDataReader reader = cmdMatchName.ExecuteReader())
            {
                while (reader.Read())
                {
                    count++;
                    mmwCompany.MatchType = "Company Name and City/State";

                    if (reader[1] != DBNull.Value)
                    {
                        mmwCompany.IsLocalSource = true;
                    }


                    if (count == 1)
                    {
                        mmwCompany.UpdateCRM = false;
                        mmwCompany.Matched = true;
                        mmwCompany.NewRecord = true;
                        mmwCompany.SetCompanyID(reader.GetInt32(0));
                        mmwCompany.MultipleMatchCompanyIDs = reader.GetInt32(0).ToString();

                        if (reader[3] != DBNull.Value)
                        {
                            mmwCompany.LocalSourceID = reader.GetInt32(3);
                        }


                        if (mmwCompany.IsLocalSource)
                        {
                            mmwCompany.UpdateCRM = true;
                        }
                        else
                        {
                            if ((reader.GetString(2) != "L") &&
                                (reader.GetString(2) != "H") &&
                                (reader.GetString(2) != "N1") &&
                                (reader.GetString(2) != "N5") &&
                                (reader.GetString(2) != "N6"))
                            {
                                // Doesn't have a service
                                if (reader[6] == DBNull.Value)
                                {
                                    mmwCompany.UpdateCRM = true;
                                }
                                else
                                {
                                    WriteLine(" - Found unlisted with a service.");
                                }
                            }

                            if ((reader[7] != DBNull.Value) &&
                                (reader.GetString(7) == "Y"))  // The Do Not Match flag
                            {
                                mmwCompany.UpdateCRM = false;
                                WriteLine(" - Found unlisted company with the Do Not Match flag set.");
                            }
                        }

                        if (reader[4] != DBNull.Value)
                        {
                            mmwCompany.HasRating = true;
                            mmwCompany.RatingID = reader.GetInt32(4);
                        }
                    }
                    else
                    {
                        if (reader[0] != DBNull.Value)
                        {
                            mmwCompany.MultipleMatchInCRM = true;
                            mmwCompany.MultipleMatchCompanyIDs += ", " + reader.GetInt32(0).ToString();
                            mmwCompany.UpdateCRM = false;
                            mmwCompany.NewRecord = false;
                        }
                    }

                    WriteLine(" - Found BBID: " + mmwCompany.MultipleMatchCompanyIDs + "(by name " + mmwCompany.CompanyName + "; MMWID=" + mmwCompany.MMWID + ")");
                }
            }

            // IF this is not a local soruce record but
            // we will be converting it to a local source
            // record, check for key existng data.
            if ((mmwCompany.CompanyID > 0) &&
                (mmwCompany.UpdateCRM))
            {
                mmwCompany.CheckForExistingData(sqlTrans.Connection, sqlTrans);
            }
        }



        int _invalidCount = 0;
        int _dupCount = 0;

        private void LoadFile(SqlConnection sqlConn, string fileName, Dictionary<string, Company> mmwCompanies, Dictionary<int, Company> MMWCompaniesByBBID)
        {
            int count = 0;
            int totalCount = 0;

            WriteLine("Importing " + fileName);

            using (CsvReader csvCount = new CsvReader(new StreamReader(fileName), true, '\t'))
            {
                while (csvCount.ReadNextRecord())
                {
                    totalCount++;
                }
            }


            using (CsvReader csv = new CsvReader(new StreamReader(fileName), true, '\t'))
            {
                int fieldCount = csv.FieldCount;
                csv.MissingFieldAction = MissingFieldAction.ReplaceByNull;
                csv.UseColumnDefaults = true;

                csv.DuplicateHeaderEncountered += (s, e) => e.HeaderName = $"{e.HeaderName}_{e.Index}";
                csv.MissingFieldAction = MissingFieldAction.ReplaceByNull;

                bool hasBBIDColumn = false;
                foreach (LumenWorks.Framework.IO.Csv.Column col in csv.Columns)
                {
                    if (col.Name == "BBID")
                    {
                        hasBBIDColumn = true;
                        break;
                    }
                }

                DateTime tempStart = new DateTime();

                bool bFoundExisting = false;
                while (csv.ReadNextRecord())
                {
                    tempStart = DateTime.Now;
                    count++;

                    // Skip empty lines
                    if (string.IsNullOrEmpty(csv[Person.COL_MMWID]))
                    {
                        WriteLine(string.Format("Skipping record {0:###,##0} of {1:###,##0}: No MMW ID found.", count, totalCount));
                        continue;
                    }

                    WriteLine(string.Format("Loading record {0:###,##0} of {1:###,##0}: MMW ID {2}", count, totalCount, csv[Person.COL_MMWID]));

                    // Load the data into something usable
                    Company mmwCompany = new Company(hasBBIDColumn);

                    mmwCompany.Load(sqlConn, csv);

                    if (!string.IsNullOrEmpty(mmwCompany.ErrMsg))
                    {
                        WriteLine(" - ERROR: " + mmwCompany.ErrMsg);
                    }

                    Company mmwExistingCompany = null;
                    bFoundExisting = false;
                    if (MMWCompaniesByBBID.ContainsKey(mmwCompany.CompanyID))
                    {
                        bFoundExisting = true;
                        mmwExistingCompany = MMWCompaniesByBBID[mmwCompany.CompanyID];
                        WriteLine(string.Format(" - Found by BBID {0}: MMW ID {1}", mmwCompany.CompanyID, mmwExistingCompany.MMWID));
                    }
                    else if (mmwCompanies.ContainsKey(mmwCompany.GetKey()))
                    {
                        mmwExistingCompany = mmwCompanies[mmwCompany.GetKey()];

                        // If both companies have a BBID, do not dedup them even
                        // if they match by key
                        if ((mmwExistingCompany.CompanyID > 100000) &&
                            (mmwCompany.CompanyID > 100000))
                        {
                            bFoundExisting = false;
                        }
                        else
                        {
                            bFoundExisting = true;
                            WriteLine(string.Format(" - Found by Key {0}: MMW ID {1}", mmwCompany.GetKey(), mmwExistingCompany.MMWID));
                        }
                    }

                    // If we already have this company, use the one found 
                    // earlier.
                    if (bFoundExisting)
                    {
                        _dupCount++;
                        mmwExistingCompany.AddDuplicateCompany(sqlConn, mmwCompany, mmwCompany.GetKey());

                        // It's possible that the existing company did not have a BBID, but now
                        // due to the just added duplicate, does.  In this case we need to update
                        // our BBID index.
                        if ((!MMWCompaniesByBBID.ContainsKey(mmwExistingCompany.CompanyID)) &&
                            (mmwExistingCompany.CompanyID >= 100000))
                        {
                            MMWCompaniesByBBID.Add(mmwExistingCompany.CompanyID, mmwExistingCompany);
                        }
                    }
                    else
                    {
                        int keyCount = 0;
                        string tmpKey = mmwCompany.GetKey();
                        while (mmwCompanies.ContainsKey(tmpKey))
                        {
                            keyCount++;
                            tmpKey = mmwCompany.GetKey() + "_" + keyCount.ToString("00");
                        }

                        mmwCompanies.Add(tmpKey, mmwCompany);

                        // A CompanyID of 1 is our magic number that means "New Company"
                        // so make sure it's not part of our matching list
                        if (mmwCompany.CompanyID >= 100000)
                        {
                            MMWCompaniesByBBID.Add(mmwCompany.CompanyID, mmwCompany);
                        }
                    }
                }
            }
        }

        protected void MatchWithinFile(SqlConnection sqlConn, Dictionary<string, Company> mmwCompanies)
        {
            WriteLine(string.Empty);

            List<string> removeKeys = new List<string>();

            DateTime tempStart = new DateTime();

            bool matched = false;
            int count = 0;
            foreach (string key in mmwCompanies.Keys)
            {
                count++;

                Company mmwCompany = mmwCompanies[key];
                if ((mmwCompany.CompanyID < 100000) &&   // If we have a company ID, no need to go through this process
                    (!mmwCompany.ExcludeFromMatch) &&
                    (!mmwCompany.Matched))
                {

                    tempStart = DateTime.Now;

                    matched = false;
                    WriteLine(string.Format("Matching Company {0:###,##0} of {1:###,##0} within input file: Subscription ID {2}", count, mmwCompanies.Keys.Count, mmwCompany.MMWID));


                    foreach (string key2 in mmwCompanies.Keys)
                    {
                        Company mmwCompany2 = mmwCompanies[key2];
                        if ((!string.IsNullOrEmpty(mmwCompany2.CompanyName)) &&
                            (mmwCompany.MMWID != mmwCompany2.MMWID))
                        {

                            // If our current company is "Force New", skip all
                            // other companies that arleady have a BBID.
                            if ((mmwCompany2.CompanyID > 100000) &&
                                (mmwCompany.CompanyID == 1))
                            {
                                continue;
                            }

                            // If these companies have different company IDs
                            // then we cannot dedup them.
                            if ((mmwCompany2.CompanyID > 100000) &&
                                (mmwCompany.CompanyID > 100000) &&
                                (mmwCompany.CompanyID != mmwCompany2.CompanyID))
                            {
                                continue;
                            }


                            foreach (Phone phone in mmwCompany.PhoneMatching)
                            {
                                foreach (Phone phone2 in mmwCompany2.PhoneMatching)
                                {

                                    if (phone.Number == phone2.Number)
                                    {
                                        matched = true;
                                        WriteLine(string.Format(" - Found by Phone {0}: MMW ID {1}", phone.Number, mmwCompany2.MMWID));

                                        // If the found record has a company ID and the
                                        // current does not, use the found company.
                                        if ((mmwCompany2.CompanyID > 10000) &&
                                            (mmwCompany.CompanyID == 0))
                                        {

                                            mmwCompany2.AddDuplicateCompany(sqlConn, mmwCompany, phone.Number);
                                            removeKeys.Add(mmwCompany.GetKey());
                                            break;
                                        }

                                        // If the found record has a company ID and the
                                        // current does not, use the found company.
                                        if ((mmwCompany.CompanyID > 10000) &&
                                            (mmwCompany2.CompanyID == 0))
                                        {

                                            mmwCompany.AddDuplicateCompany(sqlConn, mmwCompany2, phone.Number);
                                            removeKeys.Add(mmwCompany2.GetKey());
                                            break;
                                        }

                                        // Only keep the second company if the current company
                                        // does not have a name.
                                        if (!string.IsNullOrEmpty(mmwCompany.CompanyName))
                                        {
                                            mmwCompany.AddDuplicateCompany(sqlConn, mmwCompany2, phone.Number);

                                            // Remove the other company from our list.
                                            removeKeys.Add(mmwCompany2.GetKey());
                                            mmwCompany2.ExcludeFromMatch = true;
                                            break;
                                        }
                                        else
                                        {
                                            mmwCompany2.AddDuplicateCompany(sqlConn, mmwCompany, phone.Number);

                                            // Remove the other company from our list.
                                            removeKeys.Add(mmwCompany.GetKey());
                                        }

                                        // Stop iterating through the
                                        // matched company phones.
                                        break;
                                    }
                                }

                                // Stop iterating through the current
                                // company phones.
                                if (matched)
                                    break;
                            }
                        }
                    }
                }
            }

            foreach (string key in removeKeys)
            {
                if (mmwCompanies.ContainsKey(key))
                {
                    if (!((Company)mmwCompanies[key]).IsValid)
                    {
                        _invalidCount--;
                    }

                    mmwCompanies.Remove(key);
                    _dupCount++;
                }
                else
                {
                    WriteLine(string.Format(" - Unable to remove key {0}: Not Found.", key));
                }
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
            using (StreamWriter sw = new StreamWriter(_szOutputFile))
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
        private void WriteOutputFiles(Dictionary<string, Company> MMWCompanies)
        {
            FileInvalid = Path.Combine(_szPath, string.Format("LocalSource_Invalid_{0}.csv", _szFileNameTimestamp));
            using (StreamWriter sw = new StreamWriter(FileInvalid))
            {
                sw.WriteLine("Subscription ID,Invalid Reason");
                foreach (string key in MMWCompanies.Keys)
                {
                    Company mmwCompany = MMWCompanies[key];
                    if (!mmwCompany.IsValid)
                    {
                        sw.WriteLine(string.Format("{0},{1}", mmwCompany.MMWID, mmwCompany.InvalidReason));
                    }
                }
            }

            FileDuplicates = Path.Combine(_szPath, string.Format("LocalSource_Duplicates_{0}.csv", _szFileNameTimestamp));
            using (StreamWriter sw = new StreamWriter(FileDuplicates))
            {
                sw.WriteLine("IGRP_NO,Duplicate IGRP_NOs");

                foreach (string key in MMWCompanies.Keys)
                {
                    Company mmwCompany = MMWCompanies[key];
                    if (mmwCompany.Duplicate)
                    {
                        sw.WriteLine(string.Format("{0},\"{1}\"", mmwCompany.MMWID, mmwCompany.DuplicateMMWIDs));
                    }
                }
            }

            FileMulitpleMatches = Path.Combine(_szPath, string.Format("LocalSource_MultipleCRMMatch_{0}.csv", _szFileNameTimestamp));
            using (StreamWriter sw = new StreamWriter(FileMulitpleMatches))
            {
                sw.WriteLine("IGRP_NO,Matched Subscription ID,Company Name,Phone");
                foreach (string key in MMWCompanies.Keys)
                {
                    Company mmwCompany = MMWCompanies[key];
                    if (mmwCompany.MultipleMatchInCRM)
                    {
                        sw.WriteLine(string.Format("{0},\"{1}\"", mmwCompany.MMWID, mmwCompany.MultipleMatchCompanyIDs));
                    }
                }
            }

            FileData = Path.Combine(_szPath, string.Format("LocalSource_Data_{0}.csv", _szFileNameTimestamp));
            using (StreamWriter sw = new StreamWriter(FileData))
            {
                sw.WriteLine("IGRP_NO,BBID,Is Local Source");
                foreach (string key in MMWCompanies.Keys)
                {
                    Company mmwCompany = MMWCompanies[key];
                    if (mmwCompany.CompanyID > 0)
                    {
                        string tmpID = string.Empty;
                        if (!mmwCompany.MultipleMatchInCRM)
                        {
                            tmpID = mmwCompany.CompanyID.ToString();
                        }

                        sw.WriteLine(string.Format("{0},{1},{2}", mmwCompany.MMWID, tmpID, mmwCompany.IsLocalSource));
                        if (!string.IsNullOrEmpty(mmwCompany.DuplicateMMWIDs))
                        {
                            string[] ids = mmwCompany.DuplicateMMWIDs.Split(',');
                            foreach (string id in ids)
                            {
                                sw.WriteLine(string.Format("{0},{1},{2}", id, tmpID, mmwCompany.IsLocalSource));
                            }
                        }
                    }
                }
            }

            FileNewMatches = Path.Combine(_szPath, string.Format("LocalSource_NewCRMMatches_{0}.csv", _szFileNameTimestamp));
            using (StreamWriter sw = new StreamWriter(FileNewMatches))
            {
                sw.WriteLine("IGRP_NO,BBID");
                foreach (string key in MMWCompanies.Keys)
                {
                    Company mmwCompany = MMWCompanies[key];
                    if ((mmwCompany.CompanyID > 0) &&
                        (mmwCompany.NewRecord))
                    {
                        sw.WriteLine(string.Format("{0},{1}", mmwCompany.MMWID, mmwCompany.CompanyID));
                        if (!string.IsNullOrEmpty(mmwCompany.DuplicateMMWIDs))
                        {
                            string[] ids = mmwCompany.DuplicateMMWIDs.Split(',');
                            foreach (string id in ids)
                            {
                                sw.WriteLine(string.Format("{0},{1}", id, mmwCompany.CompanyID));
                            }
                        }
                    }
                }
            }

            FileOrganicFoodSafetyLicense = Path.Combine(_szPath, string.Format("LocalSource_ExistingCRM_HasOrganicFoodSafetyLicense_{0}.csv", _szFileNameTimestamp));
            using (StreamWriter sw = new StreamWriter(FileOrganicFoodSafetyLicense))
            {
                sw.WriteLine("IGRP_NO,BBID");
                foreach (string key in MMWCompanies.Keys)
                {
                    Company mmwCompany = MMWCompanies[key];
                    if ((mmwCompany.HasOrganicFoodSafetyLicense()) &&
                        (!mmwCompany.UpdateCRM))
                    {
                        sw.WriteLine(string.Format("{0},{1}", mmwCompany.MMWID, mmwCompany.CompanyID));
                    }
                }
            }

            FileNonFactor = Path.Combine(_szPath, string.Format("LocalSource_MarkedNonFactor_{0}.csv", _szFileNameTimestamp));
            using (StreamWriter sw = new StreamWriter(FileNonFactor))
            {
                sw.WriteLine("BBID");
                foreach (int CompanyID in _nonFactorCompanies)
                {
                    sw.WriteLine(string.Format("{0}", CompanyID));
                }
            }

            FilePACADRCLicense = Path.Combine(_szPath, string.Format("LocalSource_ExistingCRM_Has_PACA_DRCLicense_{0}.csv", _szFileNameTimestamp));
            using (StreamWriter sw = new StreamWriter(FilePACADRCLicense))
            {
                sw.WriteLine("BBID");
                foreach (string key in MMWCompanies.Keys)
                {
                    Company mmwCompany = MMWCompanies[key];
                    if (mmwCompany.hasPACA)
                    {
                        sw.WriteLine(string.Format("{0}", mmwCompany.CompanyID));
                    }
                }
            }
        }
    }
}