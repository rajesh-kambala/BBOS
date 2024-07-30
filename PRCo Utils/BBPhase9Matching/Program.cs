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


namespace BBPhase9Matching
{
    class Program
    {
        static void Main(string[] args)
        {

            Program oBBPhase9Matching = new Program();
            oBBPhase9Matching.Import();
        }

        protected const string DELIMITER = "\t";

        protected string _szFileID = null;
 
        protected List<string> _lszMatchedBuffer = new List<string>();
        protected List<string> _lszUnmatchedBuffer = new List<string>();
        protected List<string> _lszOutputBuffer = new List<string>();
        
        protected SqlConnection _dbConn = null;

        protected int _iLeadCount = 0;

        protected const string SQL_SELECT_SPREADSHEET =
            "SELECT * " +
             "FROM [Sheet1$]";

        public void Import()
        {
            Console.Clear();
            Console.Title = "BB Phase 9 Matching Utility";
            WriteLine("BB Phase 9 Matching Utility 1.0");
            WriteLine("Copyright (c) 2009-2010 Blue Book Services, Inc.");
            WriteLine("All Rights Reserved.");
            WriteLine("  OS Version: " + System.Environment.OSVersion.ToString());
            WriteLine(" CLR Version: " + System.Environment.Version.ToString());
            WriteLine(string.Empty);


            DateTime dtStart = DateTime.Now;

            _szFileID = "BBPhase9Matching_" + dtStart.ToString("yyyyMMdd_HHmmss") + "_";

            _dbConn = new SqlConnection(ConfigurationManager.ConnectionStrings["CRM"].ConnectionString);
            string szFileName = ConfigurationManager.AppSettings["InputFile"];

            OleDbConnection msExcelConn = new OleDbConnection("Provider=Microsoft.Jet.OLEDB.4.0;" +
                                                             "Data Source=" + szFileName + ";" +
                                                             "Extended Properties=\"Excel 8.0;HDR=Yes\"");

            try
            {
                _dbConn.Open();
                msExcelConn.Open();

                OleDbCommand cmdRedbook = msExcelConn.CreateCommand();
                cmdRedbook.CommandText = SQL_SELECT_SPREADSHEET;

                using (IDataReader drRedbook = cmdRedbook.ExecuteReader())
                {
                    while (drRedbook.Read())
                    {
                        Lead oLead = new Lead();

                        oLead.LeadID = Convert.ToInt32(GetValue(drRedbook, "RB_HQ_LEAD_ID"));
                        oLead.OKSID = Convert.ToInt32(GetValue(drRedbook, "OKS_ID"));
                        oLead.CompanyName = TranslateName(GetValue(drRedbook, "OKS_COMPNAME"));

                        oLead.PhoneNumber = GetValue(drRedbook, "OKS_PHONE");
                        oLead.FaxNumber      = GetValue(drRedbook, "OKS_FAX");

                        _iLeadCount++;
                        Write("Processing " + oLead.CompanyName);

                        if (FindCRMMatch(oLead))
                        {
                            WriteLine(" - Found");

                            _lszMatchedBuffer.Add(oLead.OKSID.ToString() + DELIMITER +
                                                  oLead.LeadID.ToString() + DELIMITER +
                                                  oLead.CompanyName + DELIMITER +
                                                  oLead.PhoneNumber + DELIMITER +
                                                  oLead.FaxNumber + DELIMITER +
                                                  oLead.MatchType + DELIMITER +
                                                  oLead.AssociatedCompanyID.ToString() + DELIMITER +
                                                  oLead.ListingStatus);
                        }
                        else
                        {
                            WriteLine(" - Not Found");

                            _lszUnmatchedBuffer.Add(oLead.OKSID.ToString() + DELIMITER +
                                                    oLead.LeadID.ToString() + DELIMITER +
                                                    oLead.CompanyName + DELIMITER +
                                                    oLead.PhoneNumber + DELIMITER +
                                                    oLead.FaxNumber);

                        }
                        
                    }
                }
            }
            catch (Exception e)
            {
                WriteLine(string.Empty);
                WriteLine(string.Empty);
                WriteLine(e.Message);
                WriteLine(e.StackTrace);

                throw;
            }

            finally
            {
                _dbConn.Close();
                msExcelConn.Close();

                WriteLine(string.Empty);
                WriteLine(string.Empty);
                WriteLine("     Lead Count: " + _iLeadCount.ToString("###,##0"));
                WriteLine("    Match Count: " + _lszMatchedBuffer.Count.ToString("###,##0"));
                WriteLine("Unmatched Count: " + _lszUnmatchedBuffer.Count.ToString("###,##0"));
                WriteLine(string.Empty);
                WriteLine("Execution Time: " + DateTime.Now.Subtract(dtStart).ToString());

                string szOutputDirectory = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Substring(6);
                string szOutputFile = Path.Combine(szOutputDirectory, _szFileID + "Log.txt");

                using (StreamWriter sw = new StreamWriter(szOutputFile))
                {
                    foreach (string szLine in _lszOutputBuffer)
                    {
                        sw.WriteLine(szLine);
                    }
                }

                szOutputFile = Path.Combine(szOutputDirectory, _szFileID + "Matched.txt");
                using (StreamWriter sw = new StreamWriter(szOutputFile))
                {
                    sw.WriteLine("OKS_ID" + DELIMITER + "RB_HQ_LEAD_ID" + DELIMITER + "OKS_COMPNAME" + DELIMITER + "OKS_PHONE" + DELIMITER + "OKS_FAX" + DELIMITER + "Match Type" + DELIMITER + "BB ID" + DELIMITER + "Listing Status");
                    foreach (string szLine in _lszMatchedBuffer)
                    {
                        sw.WriteLine(szLine);
                    }
                }


                szOutputFile = Path.Combine(szOutputDirectory, _szFileID + "Unmatched.txt");
                using (StreamWriter sw = new StreamWriter(szOutputFile))
                {
                    sw.WriteLine("OKS_ID" + DELIMITER + "RB_HQ_LEAD_ID" + DELIMITER + "OKS_COMPNAME" + DELIMITER + "OKS_PHONE" + DELIMITER + "OKS_FAX");
                    foreach (string szLine in _lszUnmatchedBuffer)
                    {
                        sw.WriteLine(szLine);
                    }
                }

            }
        }

        private const string SQL_MATCH_CRM_PHONE =
            "SELECT phon_CompanyID, comp_PRListingStatus FROM Phone WITH (NOLOCK) INNER JOIN Company WITH (NOLOCK) ON phon_CompanyID = comp_CompanyID WHERE comp_PRIndustryType = 'L' AND phon_PersonID IS NULL AND (phon_PhoneMatch = dbo.ufn_GetLowerAlpha(@Phone) OR phon_PhoneMatch = dbo.ufn_GetLowerAlpha(@Fax))";

        private const string SQL_MATCH_CRM_NAME =
            "SELECT comp_CompanyID, comp_PRListingStatus FROM Company WITH (NOLOCK) INNER JOIN PRCompanySearch WITH (NOLOCK) ON comp_CompanyID = prcse_CompanyId WHERE comp_PRIndustryType = 'L' AND (prcse_CorrTradestyleMatch = dbo.ufn_GetLowerAlpha(dbo.ufn_PrepareCompanyName(@Name)) OR prcse_LegalNameMatch = dbo.ufn_GetLowerAlpha(dbo.ufn_PrepareCompanyName(@Name)))";

        private SqlCommand cmdCRMPhoneMatch = null;
        private SqlCommand cmdCRMNameMatch = null;

        protected bool FindCRMMatch(Lead oLead)
        {
            if (cmdCRMPhoneMatch == null)
            {
                cmdCRMPhoneMatch = _dbConn.CreateCommand();
                cmdCRMPhoneMatch.CommandText = SQL_MATCH_CRM_PHONE;
            }
            
            cmdCRMPhoneMatch.Parameters.Clear();
            AddParameter(cmdCRMPhoneMatch, "Phone", oLead.PhoneNumber);
            AddParameter(cmdCRMPhoneMatch, "Fax", oLead.FaxNumber);

            using (IDataReader drCRMPhoneMatch = cmdCRMPhoneMatch.ExecuteReader())
            {
                if (drCRMPhoneMatch.Read())
                {
                    oLead.ExistsInCRM = true;
                    oLead.MatchType = "Phone";
                    oLead.AssociatedCompanyID = drCRMPhoneMatch.GetInt32(0);
                    oLead.ListingStatus = drCRMPhoneMatch.GetString(1);

                    return true;
                }
            }


            if (cmdCRMNameMatch == null)
            {
                cmdCRMNameMatch = _dbConn.CreateCommand();
                cmdCRMNameMatch.CommandText = SQL_MATCH_CRM_NAME;
            }
              
            cmdCRMNameMatch.Parameters.Clear();
            AddParameter(cmdCRMNameMatch, "Name", oLead.CompanyName);

            using (IDataReader drCRMNameMatch = cmdCRMNameMatch.ExecuteReader())
            {
                if (drCRMNameMatch.Read())
                {
                    oLead.ExistsInCRM = true;
                    oLead.MatchType = "Name";
                    oLead.AssociatedCompanyID = drCRMNameMatch.GetInt32(0);
                    oLead.ListingStatus = drCRMNameMatch.GetString(1);

                    return true;
                }
            }



            return false;
        }




        protected string TranslateName(string szName)
        {
            string szTemp = szName;

            szTemp = szTemp.Replace(" Agrl ", " Agricultural ");
            szTemp = szTemp.Replace(" Assn ", " Association ");
            szTemp = szTemp.Replace(" Bldg ", " Building ");
            szTemp = szTemp.Replace(" Br ", " Branch ");
            szTemp = szTemp.Replace(" Coll ", " Collector ");
            szTemp = szTemp.Replace(" Coml ", " Commercial ");
            szTemp = szTemp.Replace(" Contr ", " Contractor ");
            szTemp = szTemp.Replace(" Elev ", " Elevator ");
            szTemp = szTemp.Replace(" Est ", " Estate ");
            szTemp = szTemp.Replace(" Exch ", " Exchange ");
            szTemp = szTemp.Replace(" Furn ", " Furniture ");
            szTemp = szTemp.Replace(" Hdwe ", " Hardware ");
            szTemp = szTemp.Replace(" Invest ", " Investment ");
            szTemp = szTemp.Replace(" Lbr ", " Lumber ");
            szTemp = szTemp.Replace(" Machy ", " Machinery ");
            szTemp = szTemp.Replace(" Matl ", " Material ");
            szTemp = szTemp.Replace(" Matls ", " Materials ");
            szTemp = szTemp.Replace(" Merc ", " Mercantile ");
            szTemp = szTemp.Replace(" Mfrs ", " Manufacturers ");
            szTemp = szTemp.Replace(" Mfg ", " Manufacturing ");
            szTemp = szTemp.Replace(" Nat ", " National ");
            szTemp = szTemp.Replace(" Natl ", " National ");
            szTemp = szTemp.Replace(" Par ", " Parish ");
            szTemp = szTemp.Replace(" Pop ", " Population ");
            szTemp = szTemp.Replace(" Purch ", " Purchasing ");
            szTemp = szTemp.Replace(" R R ", " Railroad ");
            szTemp = szTemp.Replace(" Ry ", " Railway ");
            szTemp = szTemp.Replace(" Subsid ", " Subsidiary ");
            szTemp = szTemp.Replace(" Tr ", " Trust ");

            szTemp = szTemp.Replace(" (a Subchapter S Corp)", string.Empty);
            szTemp = szTemp.Replace(" (A Subchapter S Corp)", string.Empty);
            szTemp = szTemp.Replace(" (a Subchyapter S Corp)", string.Empty);

            szTemp = szTemp.Replace(" (not inc)", string.Empty);
            szTemp = szTemp.Replace(" (Not inc)", string.Empty);
            szTemp = szTemp.Replace(" (not Inc)", string.Empty);
            szTemp = szTemp.Replace(" (Not Inc)", string.Empty);

            szTemp = szTemp.Replace(" (no yd here)", string.Empty);
            szTemp = szTemp.Replace(" (Inc)", string.Empty);
            szTemp = szTemp.Replace(" (inc)", string.Empty);

            szTemp = szTemp.Replace(" (LP)", string.Empty);
            szTemp = szTemp.Replace(" (a limited partnership)", string.Empty);
            szTemp = szTemp.Replace(" (a limited  partnership)", string.Empty);
            szTemp = szTemp.Replace(" {a limited partnership)", string.Empty);
            

            if (szName != szTemp)
            {
                //_lszTranslateBuffer.Add(szName + DELIMITER + szTemp);
                //WriteLine("Translated " + szName + " to " + szTemp);
            }


            return szTemp;
        }


#region Helper Methods

        protected void AddParameter(SqlCommand sqlCommand, string szParmName, string szParmValue)
        {
            if (string.IsNullOrEmpty(szParmValue))
            {
                // Due to the reports and the multi-value paramters, we don't ever 
                // want this to be NULL
                if (szParmName == "Rating")
                {
                    sqlCommand.Parameters.AddWithValue(szParmName, string.Empty);
                }
                else
                {
                    sqlCommand.Parameters.AddWithValue(szParmName, DBNull.Value);
                }

            } else {
                sqlCommand.Parameters.AddWithValue(szParmName, szParmValue);
            }
        }

        protected void AddParameter(SqlCommand sqlCommand, string szParmName, int iParmValue)
        {
            if (iParmValue == 0)
            {
                sqlCommand.Parameters.AddWithValue(szParmName, DBNull.Value);
            }
            else
            {
                sqlCommand.Parameters.AddWithValue(szParmName, iParmValue);
            }
        }

        protected string GetValue(IDataReader drReader, string szColName)
        {
            if (drReader[szColName] == DBNull.Value)
            {
                return null;
            }

            return Convert.ToString(drReader[szColName]).Trim();
        }

        private string szTempWrite = string.Empty;
        protected void Write(string szLine)
        {
            Console.Write(szLine);
            szTempWrite += szLine;
        }

        protected void WriteLine(string szLine)
        {
            Console.WriteLine(szLine);
            _lszOutputBuffer.Add(szTempWrite + szLine);

            if (!string.IsNullOrEmpty(szTempWrite))
            {
                szTempWrite = string.Empty;
            }
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



        private void EnumerateWorksheets(string szFileName)
        {
            OleDbConnection msExcelConn = new OleDbConnection("Provider=Microsoft.Jet.OLEDB.4.0;" +
                                                             "Data Source=" + szFileName + ";" +
                                                             "Extended Properties=\"Excel 8.0;HDR=Yes\"");

            msExcelConn.Open();

            WriteLine("Worksheets found in " + szFileName);

            DataTable schemaTable = msExcelConn.GetOleDbSchemaTable(OleDbSchemaGuid.Tables, new object[] { null, null, null, "TABLE" });
            foreach (DataRow schemaRow in schemaTable.Rows)
            {
                string sheet = schemaRow["TABLE_NAME"].ToString();
                WriteLine(" - " + sheet);
            }
            
            msExcelConn.Close();

        }
#endregion

    
    }
}
