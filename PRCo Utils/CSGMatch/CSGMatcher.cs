// http://www.codeproject.com/Articles/9258/A-Fast-CSV-Reader

using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Text;

using LumenWorks.Framework.IO.Csv;
namespace CSGMatch
{
    public class CSGMatcher
    {
        private int _matchedCount = 0;
        private int _unmatchedCount = 0;
        
        public void Match()
        {
            DateTime dtStart = DateTime.Now;

            Console.Clear();
            Console.Title = "CSG Matcher Utility";
            WriteLine("CSG Matcher Utility 1.1");
            WriteLine("Copyright (c) 2014-2018 Blue Book Services, Inc.");
            WriteLine("All Rights Reserved.");
            WriteLine("  OS Version: " + System.Environment.OSVersion.ToString());
            WriteLine(" CLR Version: " + System.Environment.Version.ToString());
            WriteLine(string.Empty);
            WriteLine(DateTime.Now.ToString("M/dd/yyyy hh:mm tt"));

            if (!File.Exists(ConfigurationManager.AppSettings["MatchFile"]))
            {
                throw new ApplicationException("The specified Match File is not found: " + ConfigurationManager.AppSettings["MatchFile"]);
            }


            List<CSGCompany> csgCompanies = new List<CSGCompany>();
            int recordCount = LoadFile(ConfigurationManager.AppSettings["MatchFile"], csgCompanies);

            
            using (SqlConnection sqlConn = new SqlConnection(ConfigurationManager.ConnectionStrings["SQLServer"].ConnectionString))
            {
                sqlConn.Open();

                int rowIndex = 0;

                foreach (CSGCompany csgCompany in csgCompanies)
                {
                    rowIndex++;

                    WriteLine(string.Format("Processing row {0}: {1} {2}", rowIndex.ToString(), csgCompany.CSGCompanyID, csgCompany.Name));

                    if (!string.IsNullOrEmpty(csgCompany.BBID))
                    {
                        WriteLine(" - Skipping because this record already has a BBID: " + csgCompany.BBID);
                    } else
                    {
                        matchCSGCompany(csgCompany, sqlConn);
                        matchPerson(csgCompany, sqlConn);
                    }

                }

                ListMatchedCompanies(csgCompanies, sqlConn);
            }

            


            WriteLine(string.Empty);
            WriteLine("     Total Record Count: " + recordCount.ToString("###,##0"));
            WriteLine("   Matched Company Count: " + _matchedCount.ToString("###,##0"));
            WriteLine(" Unmatched Company Count: " + _unmatchedCount.ToString("###,##0"));
            WriteLine("Execution Time: " + DateTime.Now.Subtract(dtStart).ToString());

            using (StreamWriter sw = new StreamWriter(_szOutputFile))
            {
                foreach (string line in _lszOutputBuffer)
                {
                    sw.WriteLine(line);
                }
            }
        }

        private const string SQL_SELECT_COMPANIES =
            @"SELECT comp_CompanyID,
                   comp_Name,
	               ls.capt_us as ListingStatus,
	               ISNULL(src.capt_us, '') as Source,
	               ISNULL(prse_ServiceCode, '') as ServiceCode,
	               ISNULL(prpa_LicenseNumber, '') as PACALicense
              FROM Company WITH (NOLOCK)
                   LEFT OUTER JOIN Custom_Captions ls ON ls.capt_code = comp_PRListingStatus AND ls.capt_family = 'comp_PRListingStatus'
	               LEFT OUTER JOIN Custom_Captions src ON src.capt_code = comp_Source AND src.capt_family = 'comp_Source'
                   LEFT OUTER JOIN PRService ON comp_CompanyID = prse_CompanyID AND prse_Primary = 'Y'
	               LEFT OUTER JOIN PRPACALicense ON comp_CompanyID = prpa_CompanyId AND prpa_Current = 'Y'
            WHERE comp_CompanyID IN ({0})";


        private const string SQL_METRICS =
            @"SELECT COUNT(1) as CompanyCount,
	               SUM(CASE WHEN prpa_LicenseNumber IS NOT NULL THEN CASE WHEN comp_PRListingStatus IN ('L', 'H') THEN 1 ELSE 0 END END) as [w/PACA License Listed],
	               SUM(CASE WHEN prpa_LicenseNumber IS NOT NULL THEN CASE WHEN comp_PRListingStatus IN ('L', 'H') THEN 0 ELSE 1 END END) as [w/PACA License Not Listed],
	               SUM(CASE WHEN prpa_LicenseNumber IS NULL THEN CASE WHEN comp_PRListingStatus IN ('L', 'H') THEN 1 ELSE 0 END END) as [w/o PACA License Listed],
	               SUM(CASE WHEN prpa_LicenseNumber IS NULL THEN CASE WHEN comp_PRListingStatus IN ('L', 'H') THEN 0 ELSE 1 END END) as [w/o PACA License Not Listed]
                FROM Company WITH (NOLOCK)
                    LEFT OUTER JOIN Custom_Captions ls ON ls.capt_code = comp_PRListingStatus AND ls.capt_family = 'comp_PRListingStatus'
	                LEFT OUTER JOIN Custom_Captions src ON src.capt_code = comp_Source AND src.capt_family = 'comp_Source'
                    LEFT OUTER JOIN PRService ON comp_CompanyID = prse_CompanyID AND prse_Primary = 'Y'
	                LEFT OUTER JOIN PRPACALicense ON comp_CompanyID = prpa_CompanyId AND prpa_Current = 'Y'
            WHERE comp_CompanyID IN ({0})";


        private const string outputLine = "\"{0}\",{1},\"{2}\",\"{3}\",\"{4}\",\"{5}\",\"{6}\",\"{7}\",{8},\"{9}\",\"{10}\",\"{11}\"";

        private void ListMatchedCompanies(List<CSGCompany> csgCompanies, SqlConnection sqlConn)
        {
            List<string> matchedCompanies = new List<string>();
            List<string> unmatchedCompanies = new List<string>();


            StringBuilder companyIDs = new StringBuilder();
            foreach (CSGCompany csgCompany in csgCompanies)
            {
                if (!string.IsNullOrEmpty(csgCompany.BBID))
                {
                    continue;
                }

                    if (csgCompany.Matched)
                {
                    if (!matchedCompanies.Contains(csgCompany.CSGCompanyID))
                    {
                        matchedCompanies.Add(csgCompany.CSGCompanyID);
                        if (companyIDs.Length > 0)
                        {
                            companyIDs.Append(", ");
                        }
                        companyIDs.Append(csgCompany.MatchedCompanyID.ToString());
                    }
                }
                else
                {
                    if (!unmatchedCompanies.Contains(csgCompany.CSGCompanyID))
                    {
                        unmatchedCompanies.Add(csgCompany.CSGCompanyID);
                    }
                }
            }

            _matchedCount = matchedCompanies.Count;
            _unmatchedCount = unmatchedCompanies.Count;

            SqlCommand commandCompanies = new SqlCommand();
            commandCompanies.Connection = sqlConn;
            commandCompanies.CommandText = string.Format(SQL_SELECT_COMPANIES, companyIDs.ToString());

            WriteLine(string.Format(SQL_METRICS, companyIDs.ToString()));


            string outputFile = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Substring(6);
            outputFile = Path.Combine(outputFile, "CSG Matched Companies.csv");
            using (StreamWriter sw = new StreamWriter(outputFile))
            {
                string[] headerArgs = { "CSG CompanyID", "\"BBID\"", "Company Name", "Listing Status", "Source", "Primary Membership", "PACA License #", "Match Type", "\"Person ID\"", "First Name", "Last Name", "Title" };
                sw.WriteLine(string.Format(outputLine, headerArgs));


                using (SqlDataReader reader = commandCompanies.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        List<CSGCompany> foundCSGCompanies = GetCSGCompanyID(csgCompanies, reader.GetInt32(0));
                        foreach (CSGCompany csgCompany in foundCSGCompanies)
                        {
                            string personID = string.Empty;
                            string firstName = string.Empty;
                            string lastName = string.Empty;
                            string title = string.Empty;

                            if (csgCompany.MatchedPersonID > 0)
                            {
                                personID = csgCompany.MatchedPersonID.ToString();
                                firstName = csgCompany.FirstName;
                                lastName = csgCompany.LastName;
                                title = csgCompany.CRMTitle;
                            }

                            string[] args = { csgCompany.CSGCompanyID, reader.GetInt32(0).ToString(), reader.GetString(1), reader.GetString(2), reader.GetString(3), reader.GetString(4), reader.GetString(5), csgCompany.MatchType, personID, firstName, lastName, title };
                            sw.WriteLine(string.Format(outputLine, args));
                        }   
                    }
                }
            }
        }

        private List<CSGCompany> GetCSGCompanyID(List<CSGCompany> csgCompanies, int BBID)
        {

            List<CSGCompany> foundCSGCompanies = new List<CSGCompany>();

            foreach (CSGCompany csgCompany in csgCompanies)
            {
                if (csgCompany.MatchedCompanyID == BBID)
                {
                    foundCSGCompanies.Add(csgCompany);
                    //return csgCompany.CSGCompanyID;
                }
            }

            return foundCSGCompanies;
        }


        private int LoadFile(string fileName, List<CSGCompany> csgCompanies)
        {
            int recordCount = 0;
            CSGCompany csgCompany = null;

            using (CsvReader csv = new CsvReader(new StreamReader(fileName), true))
            {
                int fieldCount = csv.FieldCount;

                while (csv.ReadNextRecord())
                {
                    recordCount++;

                    csgCompany = new CSGCompany();
                    csgCompany.CSGCompanyID = csv["Company ID"];
                    csgCompany.BBID = csv["BBID"];
                    csgCompany.Name = csv["Company Name"];
                    csgCompany.City = csv["City"];
                    csgCompany.State = csv["State"];
                    csgCompany.PostalCode = csv["Zip"];
                    csgCompany.MailCity = csv["Mail City"];
                    csgCompany.MailState = csv["Mail State"];
                    csgCompany.MailPostalCode = csv["Mail Zip"];
                    csgCompany.Phone = csv["Phone"];
                    csgCompany.FirstName = csv["First Name"];
                    csgCompany.LastName = csv["Last Name"];
                    csgCompany.Email = csv["PERS_EMAIL"];

                    csgCompanies.Add(csgCompany);
                } // End While
            }

            return recordCount;
        }

        private const string SQL_SELECT_PHONE =
            @"SELECT DISTINCT phon_CompanyID 
                FROM vPRPhone WITH (NOLOCK)
               WHERE phon_PhoneMatch = dbo.ufn_GetLowerAlpha(@Phone) 
                 AND phon_PhoneMatch IS NOT NULL
                 AND phon_CompanyID IS NOT NULL";

        private SqlCommand commandPhone = null;


        private const string SQL_SELECT_EMAIL =
            @"SELECT elink_RecordID 
                FROM vCompanyEmail WITH (NOLOCK)
               WHERE CASE elink_Type WHEN 'E' 
                        THEN RIGHT(RTRIM(Emai_EmailAddress), LEN(Emai_EmailAddress) - CHARINDEX('@', Emai_EmailAddress))
                        ELSE  REPLACE(emai_PRWebAddress, 'www.', '')
                     END = RIGHT(RTRIM(@Domain), LEN(@Domain) - CHARINDEX('@', @Domain))";

        private SqlCommand commandEmail = null;


        private const string SQL_SELECT_NAME =
            @"SELECT prcse_CompanyId 
                FROM PRCompanySearch WITH (NOLOCK)
                     INNER JOIN vPRAddress ON adli_ComapnyID = prcse_CompanyId
               WHERE prcse_NameMatch = dbo.ufn_GetLowerAlpha(dbo.ufn_PrepareCompanyName(@Name))
                 AND prst_Abbreviation = @State";

        private SqlCommand commandName = null;

        private void matchCSGCompany(CSGCompany csgCompany, SqlConnection sqlConn)
        {
            csgCompany.Matched = false;
            if (commandPhone == null)
            {
                commandPhone = new SqlCommand();
                commandPhone.Connection = sqlConn;
                commandPhone.CommandText = SQL_SELECT_PHONE;
            }

            
            commandPhone.Parameters.Clear();
            commandPhone.Parameters.AddWithValue("Phone", csgCompany.Phone);


            object oCRMCompanyID = commandPhone.ExecuteScalar();
            if ((oCRMCompanyID != null) &&
                (oCRMCompanyID != DBNull.Value))
            {
                csgCompany.MatchedCompanyID = Convert.ToInt32(oCRMCompanyID);
                csgCompany.Matched = true;
                csgCompany.MatchType = "Phone";
                //_matchedCount++;
                WriteLine(" - Matched by Phone");
                return;
            }

            if (!string.IsNullOrEmpty(csgCompany.Email)) {

                if (commandEmail == null)
                {
                    commandEmail = new SqlCommand();
                    commandEmail.Connection = sqlConn;
                    commandEmail.CommandText = SQL_SELECT_EMAIL;
                }

                commandEmail.Parameters.Clear();
                commandEmail.Parameters.AddWithValue("Domain", csgCompany.Email);

                oCRMCompanyID = commandEmail.ExecuteScalar();
                if ((oCRMCompanyID != null) &&
                    (oCRMCompanyID != DBNull.Value)) {
                    csgCompany.MatchedCompanyID = Convert.ToInt32(oCRMCompanyID);
                    csgCompany.Matched = true;
                    csgCompany.MatchType = "Domain";
                    //_matchedCount++;
                    WriteLine(" - Matched by Domain");
                    return;
                }
            }



            if (commandName == null)
            {
                commandName = new SqlCommand();
                commandName.Connection = sqlConn;
                commandName.CommandText = SQL_SELECT_NAME;
            }


            commandName.Parameters.Clear();
            commandName.Parameters.AddWithValue("Name", csgCompany.Name);
            commandName.Parameters.AddWithValue("State", csgCompany.State);


            oCRMCompanyID = commandPhone.ExecuteScalar();
            if ((oCRMCompanyID != null) &&
                (oCRMCompanyID != DBNull.Value))
            {
                csgCompany.MatchedCompanyID = Convert.ToInt32(oCRMCompanyID);
                csgCompany.Matched = true;
                csgCompany.MatchType = "Name";
                //_matchedCount++;
                WriteLine(" - Matched by Name");
                return;
            }

            WriteLine(" - Not matched.  Phone: " + csgCompany.Phone + ", Domain: " + csgCompany.Email + ", Name: " + csgCompany.Name + ", State: " + csgCompany.State);
        }

        private const string SQL_SELECT_PERSON =
            @"SELECT pers_PersonID, RTRIM(pers_FirstName) FirstName, RTRIM(pers_LastName) LastName, pt.capt_us [Title], ps.capt_us [Status]
                FROM Person
                     INNER JOIN Person_Link ON pers_PersonID = peli_PersonID
	                 INNER JOIN Custom_Captions ps ON ps.capt_code = peli_PRStatus AND ps.capt_family = 'peli_PRStatus'
				     INNER JOIN Custom_Captions pt ON pt.capt_code = peli_PRTitleCode AND pt.capt_family = 'pers_TitleCode'
                 WHERE peli_CompanyID = @CompanyID
                   AND pers_FirstName = @FirstName
                   AND pers_LastName = @LastName";
        private SqlCommand commandPerson = null;

        private void matchPerson(CSGCompany csgCompany, SqlConnection sqlConn)
        {
            if (!csgCompany.Matched)
            {
                return;
            }


            if (commandPerson == null)
            {
                commandPerson = new SqlCommand();
                commandPerson.Connection = sqlConn;
                commandPerson.CommandText = SQL_SELECT_PERSON;
            }


            WriteLine(" - Searching for associated Person: " + csgCompany.FirstName + " " + csgCompany.LastName);

            commandPerson.Parameters.Clear();
            commandPerson.Parameters.AddWithValue("CompanyID", csgCompany.MatchedCompanyID);
            commandPerson.Parameters.AddWithValue("FirstName", csgCompany.FirstName);
            commandPerson.Parameters.AddWithValue("LastName", csgCompany.LastName);

            using (SqlDataReader reader = commandPerson.ExecuteReader())
            {
                if (reader.Read())
                {
                    csgCompany.MatchedPersonID = reader.GetInt32(0);
                    csgCompany.CRMTitle = reader.GetString(3);
                    csgCompany.CRMStatus = reader.GetString(4);
                }
            }
        }


        protected string _szOutputFile;
        protected List<string> _lszOutputBuffer = new List<string>();

        private void WriteLine(string msg)
        {
            if (_szOutputFile == null)
            {
                _szOutputFile = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Substring(6);
                _szOutputFile = Path.Combine(_szOutputFile, "CSGMatch.txt");
            }

            Console.WriteLine(msg);
            _lszOutputBuffer.Add(msg);
        }

    }


    class CSGCompany
    {
        public string CSGCompanyID;
        public string BBID;
        public int CompanyID;
        public string Name;
        public string City;
        public string State;
        public string PostalCode;

        public string MailCity;
        public string MailState;
        public string MailPostalCode;
        
        public string Phone;
        
        public string FirstName;
        public string LastName;
        public string Email;

        public bool Matched;
        public int MatchedCompanyID;
        public string MatchType;

        public int MatchedPersonID;
        public string CRMTitle;
        public string CRMStatus;
        
    }
}

