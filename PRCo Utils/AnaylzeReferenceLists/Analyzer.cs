using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;

namespace AnaylzeReferenceLists
{
    public class Analyzer
    {

        protected string _szOutputFile;
        protected string _szOutputDataFile;
        protected string _szPath;
        protected List<string> _lszOutputBuffer = new List<string>();
        protected List<string> _lszDataBuffer = new List<string>();

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

            using (StreamWriter sw = new StreamWriter(_szOutputDataFile))
            {
                foreach (string line in _lszDataBuffer)
                {
                    sw.WriteLine(line);
                }
            }

        }

        public void Analyze()
        {
            Console.Clear();
            Console.Title = "Company Relationship Analyzer Utility";
            WriteLine("Company Relationship Analyzer Utility 1.0");
            WriteLine("Copyright (c) 2017 Blue Book Services, Inc.");
            WriteLine("All Rights Reserved.");
            WriteLine("  OS Version: " + System.Environment.OSVersion.ToString());
            WriteLine(" CLR Version: " + System.Environment.Version.ToString());
            WriteLine(string.Empty);
            WriteLine(DateTime.Now.ToString("M/dd/yyyy hh:mm tt"));


            _szPath = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Substring(6);

            _szOutputFile = Path.Combine(_szPath, "Analyzer.txt");
            _szOutputDataFile = Path.Combine(_szPath, "AnalyzerData.csv");

            try
            {
                ExecuteAnalyzer();
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

                WriteOuptutBuffer();

                using (StreamWriter sw = new StreamWriter(Path.Combine(_szPath, "Exception.txt")))
                {
                    sw.WriteLine(e.Message + Environment.NewLine);
                    sw.WriteLine(e.StackTrace);
                }
            }
        }

        private void ExecuteAnalyzer()
        {
            DateTime dtStart = DateTime.Now;

            using (SqlConnection sqlConn = new SqlConnection(ConfigurationManager.ConnectionStrings["SQLServer"].ConnectionString))
            {
                sqlConn.Open();
                List<Int32> companies = LoadEligibleCompanies(sqlConn);
                HashSet<Int32> processedCompanies = new HashSet<int>();

                _lszDataBuffer.Add("BBID,Company Name,City,State,Country,Listing Status,Classification,Rating Line,Listed Date,Ref List Count,Trade Report Count,BBID,Company Name,City,State,Country,Listing Status,Classification,Rating Line,Listed Date,Ref List Count,Trade Report Count,Ref List Share %");

                List<Int32> leftReferenceList = null;
                List<Int32> rightReferenceList = null;
                List<Int32> commonReferences = null;

                WriteLine(string.Format("Found {0} eligible companies.", companies.Count));
                WriteLine(string.Empty);

                foreach (int leftCompanyID in companies)
                {
                    WriteLine(string.Format("Analyzing {0}", leftCompanyID));
                    processedCompanies.Add(leftCompanyID);


                    leftReferenceList = GetReferenceList(sqlConn, leftCompanyID);

                    foreach (int rightCompanyID in companies)
                    {
                        if (processedCompanies.Contains(rightCompanyID))
                        {
                            continue;
                        }

                        rightReferenceList = GetReferenceList(sqlConn, rightCompanyID);
                        commonReferences = leftReferenceList.Intersect(rightReferenceList).ToList();

                        double pctSame = Convert.ToDouble(commonReferences.Count) / Convert.ToDouble(leftReferenceList.Count);

                        if (pctSame >= .6) {
                            WriteLine(string.Format(" - Found {0} with {1}% overlap.", rightCompanyID, pctSame));

                            string output = GetCompanyInfo(sqlConn, leftCompanyID);
                            output += ",";
                            output += GetCompanyInfo(sqlConn, rightCompanyID);
                            output += ",";
                            output += pctSame.ToString("0.00");
                            _lszDataBuffer.Add(output);
                        }
                    }
                }
            }


            WriteLine(string.Empty);
            WriteLine("Execution Time: " + DateTime.Now.Subtract(dtStart).ToString());

            WriteOuptutBuffer();
        }

        private void AnalyzeReferenceList(SqlConnection sqlConn, int leftCompanyID, int rightCompanyID)
        {
            List<Int32> leftReferences = new List<Int32>();
            List<Int32> rightReferences = new List<Int32>();

            List<Int32> commonReferences = leftReferences.Intersect(rightReferences).ToList();
        }

        Dictionary<Int32, List<Int32>> referenceLists = new Dictionary<Int32, List<Int32>>();
        SqlCommand cmdReferenceList = null;

        private const string SQL_GET_REFERENCE_LIST =
            @"SELECT DISTINCT prcr_RightCompanyID
                  FROM PRCompanyRelationship
                 WHERE prcr_Active = 'Y'
                   AND prcr_Type IN ('09', '10', '11', '12', '13', '14', '15', '16')
                   AND prcr_LeftCompanyId = @CompanyID
                ORDER BY prcr_RightCompanyID";
        private List<Int32> GetReferenceList(SqlConnection sqlConn, int companyID)
        {
            if (referenceLists.ContainsKey(companyID))
            {
                return referenceLists[companyID];
            }


            if (cmdReferenceList == null)
            {
                cmdReferenceList = new SqlCommand();
                cmdReferenceList.Connection = sqlConn;
                cmdReferenceList.CommandText = SQL_GET_REFERENCE_LIST;
            }

            cmdReferenceList.Parameters.Clear();
            cmdReferenceList.Parameters.AddWithValue("CompanyID", companyID);

            List<Int32> referenceList = new List<Int32>();
            using (SqlDataReader reader = cmdReferenceList.ExecuteReader())
            {
                while (reader.Read())
                {
                    referenceList.Add(reader.GetInt32(0));
                }
            }

            referenceLists.Add(companyID, referenceList);
            return referenceList;
        }



        private const string SQL_LOAD_COMPANIES =
            @"SELECT prcr_LeftCompanyID
                  FROM PRCompanyRelationship WITH (NOLOCK)
                       INNER JOIN Company WITH (NOLOCK) ON prcr_LeftCompanyID = comp_CompanyID
                 WHERE prcr_Active = 'Y'
                   AND prcr_Type IN ('09', '10', '11', '12', '13', '14', '15', '16')
                   AND prcr_LeftCompanyId NOT IN (-1, 100002)
                GROUP BY prcr_LeftCompanyID
                HAVING COUNT(DISTINCT prcr_RightCompanyID) >= 2
                ORDER BY prcr_LeftCompanyID";

        private List<Int32> LoadEligibleCompanies(SqlConnection sqlConn)
        {
            List<Int32> companies = new List<Int32>();

            SqlCommand cmdLoad = new SqlCommand();
            cmdLoad.Connection = sqlConn;
            cmdLoad.CommandText = SQL_LOAD_COMPANIES;

            using (SqlDataReader reader = cmdLoad.ExecuteReader())
            {
                while (reader.Read())
                {
                    companies.Add(reader.GetInt32(0));
                }
            }

            return companies;
        }


        Dictionary<Int32, string> companyInfoList = new Dictionary<Int32, string>();
        SqlCommand cmdCompanyInfo = null;


        private const string SQL_GET_COMPANY_INFO =
                @"SELECT comp_CompanyID [BBID],
	                   Company.comp_Name [Company Name],
	                   prci_City [City],
	                   prst_State [State],
	                   prcn_Country [Country],
	                   capt_US [Listing Status],
	                   dbo.ufn_GetLevel1Classifications(comp_CompanyID, 2) [ Classification],
	                   prra_RatingLine [ Rating Line],
	                   comp_PRListedDate [Subject Listed Date],
                       RelCount as [Reference List Count],
	                   TradeReportCount [Trade Report Count]
                  FROM Company WITH (NOLOCK) 
	                   INNER JOIN vPRLocation  ON comp_PRListingCityID = prci_CityID
	                   INNER JOIN Custom_Captions WITH (NOLOCK) ON comp_PRListingStatus = capt_code AND capt_Family = 'comp_PRListingStatus'
	                   LEFT OUTER JOIN vPRCompanyRating ON comp_CompanyID = prra_CompanyID AND prra_Current = 'Y'
	                   LEFT OUTER JOIN (SELECT prcr_LeftCompanyID, COUNT(1) as RelCount
	                                      FROM PRCompanyRelationship WITH (NOLOCK)
						                 WHERE prcr_Active = 'Y'
						                   AND prcr_Type IN ('09', '10', '11', '12', '13', '14', '15', '16')
						                GROUP BY prcr_LeftCompanyID) T1 ON prcr_LeftCompanyID = comp_CompanyID
	                   LEFT OUTER JOIN (SELECT prtr_SubjectId, COUNT(1) as TradeReportCount
	                                      FROM PRTradeReport WITH (NOLOCK)
						                 WHERE prtr_CreatedDate >= DATEADD(month, -12, GETDATE())
						                GROUP BY prtr_SubjectId) T2 ON prtr_SubjectId = comp_CompanyID
                 WHERE comp_CompanyID = @CompanyID";
        private string GetCompanyInfo(SqlConnection sqlConn, int companyID)
        {
            if (companyInfoList.ContainsKey(companyID))
            {
                return companyInfoList[companyID];
            }


            if (cmdCompanyInfo == null)
            {
                cmdCompanyInfo = new SqlCommand();
                cmdCompanyInfo.Connection = sqlConn;
                cmdCompanyInfo.CommandText = SQL_GET_COMPANY_INFO;
            }

            cmdCompanyInfo.Parameters.Clear();
            cmdCompanyInfo.Parameters.AddWithValue("CompanyID", companyID);

            StringBuilder companyInfo = new StringBuilder();
            using (SqlDataReader reader = cmdCompanyInfo.ExecuteReader())
            {
                if (reader.Read())
                {
                    AddIntValue(companyInfo, reader[0]);
                    AddStringValue(companyInfo, reader[1]);
                    AddStringValue(companyInfo, reader[2]);
                    AddStringValue(companyInfo, reader[3]);
                    AddStringValue(companyInfo, reader[4]);
                    AddStringValue(companyInfo, reader[5]);
                    AddStringValue(companyInfo, reader[6]);
                    AddStringValue(companyInfo, reader[7]);
                    AddDateValue(companyInfo, reader[8]);
                    AddIntValue(companyInfo, reader[9]);
                    AddIntValue(companyInfo, reader[10]);
                } else
                {
                    throw new Exception(string.Format("Unable to find company data on {0}", companyID));
                }
            }

            companyInfoList.Add(companyID, companyInfo.ToString());
            return companyInfo.ToString();
        }

        private void AddStringValue(StringBuilder buffer, object value)
        {
            if (buffer.Length > 0)
            {
                buffer.Append(",");
            }

            if (value == null || value == DBNull.Value)
            {
                return;
            }

            buffer.Append("\"");
            buffer.Append(Convert.ToString(value));
            buffer.Append("\"");
        }

        private void AddIntValue(StringBuilder buffer, object value)
        {
            if (buffer.Length > 0)
            {
                buffer.Append(",");
            }

            if (value == null || value == DBNull.Value)
            {
                return;
            }

            buffer.Append(Convert.ToInt32(value));
        }

        private void AddDateValue(StringBuilder buffer, object value)
        {
            if (buffer.Length > 0)
            {
                buffer.Append(",");
            }

            if (value == null || value == DBNull.Value)
            {
                return;
            }

            buffer.Append(Convert.ToDateTime(value));
        }
    }
}
