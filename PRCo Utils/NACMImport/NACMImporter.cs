using System;
using System.Configuration;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.IO;

using CommandLine.Utility;


namespace NACMImport
{
    class NACMImporter
    {
        protected string _szOutputFile;
        protected string _szInputDirectory;
        protected List<string> _lszOutputBuffer = new List<string>();

        public void Import(string[] args)
        {
            Console.Clear();
            Console.Title = "NACM Import Utility";
            WriteLine("NACM Import Utility 1.0");
            WriteLine("Copyright (c) 2009 Produce Reporter Co.");
            WriteLine("All Rights Reserved.");
            WriteLine("  OS Version: " + System.Environment.OSVersion.ToString());
            WriteLine(" CLR Version: " + System.Environment.Version.ToString());
            WriteLine(string.Empty);

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
                //DisplayHelp();
                return;
            }

            if (oCommandLine["O"] != null)
            {
                _szOutputFile = oCommandLine["O"];
            }
            else
            {
                _szOutputFile = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Substring(6);
                _szOutputFile = Path.Combine(_szOutputFile, "NACMImporter.txt");
            }

            if (oCommandLine["D"] != null)
            {
                _szInputDirectory = oCommandLine["D"];
            }
            else
            {
                _szInputDirectory = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Substring(6);
                _szInputDirectory = Path.Combine(_szInputDirectory, "Data");
            }

            try
            {
                ExecuteConversion();
            }
            catch (Exception e)
            {
                Console.WriteLine();
                Console.WriteLine();
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine("An unexpected exception occurred: " + e.Message);
                Console.WriteLine("Terminating execution.");
                Console.ForegroundColor = ConsoleColor.Gray;
            }
        }

        protected SqlConnection _dbConn = null;
        protected Hashtable _htDupAccounts = null;
        protected int _iDebtorCount = 0;
        protected int _iARCount = 0;
        protected int _iSkippedLines = 0;

        protected int _iTotalCreditorCount = 0;
        protected int _iTotalDebtorCount = 0;
        protected int _iTotalARCount = 0;
        protected int _iTotalSkippedLines = 0;

        void ExecuteConversion()
        {
            DateTime dtStart = DateTime.Now;
            string szInputLine = null;

            try
            {
                using (_dbConn = new SqlConnection(ConfigurationManager.ConnectionStrings["SQLServer"].ConnectionString))
                {
                    _dbConn.Open();

                    WriteLine("Reading files from " + _szInputDirectory);

                    DirectoryInfo di = new DirectoryInfo(_szInputDirectory);
                    FileInfo[] rgFiles = di.GetFiles("*.txt");
                    foreach (FileInfo fi in rgFiles)
                    {
                        WriteLine("Processing file " + fi.Name);

                        _iTotalCreditorCount++;

                        int iCreditorID = 0;

                        _htDupAccounts = new Hashtable();
                        _iDebtorCount = 0;
                        _iARCount = 0;
                        _iSkippedLines = 0;

                        DateTime dtFileStart = DateTime.Now;

                        using (StreamReader srData = new StreamReader(Path.Combine(_szInputDirectory, fi.Name)))
                        {
                            while ((szInputLine = srData.ReadLine()) != null)
                            {
                                string[] aszInputFields = szInputLine.Split('\t');

                                switch (aszInputFields[0])
                                {
                                    case "A":
                                        iCreditorID = ProcessHeader(aszInputFields);
                                        break;

                                    case "C":
                                        ProcessDebtor(iCreditorID, aszInputFields);
                                        break;
                                }
                            }

                            WriteLine(" - File Processing Time: " + DateTime.Now.Subtract(dtFileStart).ToString());
                            WriteLine(" - Debtor Count: " + _iDebtorCount.ToString("###,##0"));
                            WriteLine(" - AR Count: " + _iARCount.ToString("###,##0"));
                            WriteLine(" - Skpped Line Count: " + _iSkippedLines.ToString("###,##0"));

                            _iTotalDebtorCount += _iDebtorCount;
                            _iTotalARCount += _iARCount;
                            _iTotalSkippedLines += _iSkippedLines;
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
                WriteLine("AR Line Count: " + _iARCount.ToString("###,##0"));
                WriteLine("Stack Trace: ");
                WriteLine(e.StackTrace);
            }

            WriteLine(string.Empty);
            WriteLine("   Creditor Count: " + _iTotalCreditorCount.ToString("###,##0"));
            WriteLine("     Debtor Count: " + _iTotalDebtorCount.ToString("###,##0"));
            WriteLine("         AR Count: " + _iTotalARCount.ToString("###,##0"));
            WriteLine("Skpped Line Count: " + _iTotalSkippedLines.ToString("###,##0"));
            WriteLine("Execution Time: " + DateTime.Now.Subtract(dtStart).ToString());

            string szOutputDirectory = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Substring(6);
            szOutputDirectory = Path.Combine(szOutputDirectory, "Log.txt");

            using (StreamWriter sw = new StreamWriter(szOutputDirectory))
            {
                foreach (string szLine in _lszOutputBuffer)
                {
                    sw.WriteLine(szLine);
                }
            }
        }

        protected const string SQL_INSERT_CREDITOR =
            "INSERT INTO Creditor (CreditorName, ExtractDate) VALUES (@CreditorName, @ExtractDate);SELECT SCOPE_IDENTITY();";
        protected int ProcessHeader(string[] aszInputFields)
        {
            SqlCommand sqlInsertCreditor = _dbConn.CreateCommand();
            sqlInsertCreditor.Parameters.Add(new SqlParameter("CreditorName", aszInputFields[1]));
            sqlInsertCreditor.Parameters.Add(new SqlParameter("ExtractDate", GetDateValue(aszInputFields[3])));
            sqlInsertCreditor.CommandText = SQL_INSERT_CREDITOR;
            return Convert.ToInt32(sqlInsertCreditor.ExecuteScalar());
        }


        protected string SQL_DUP_PASS_1 = 
            "SELECT DebtorID FROM Debtor WHERE DupNameValue = dbo.ufn_ProcessName(@AccountName) AND City = @City AND stateProvince = @State";

        protected string SQL_DUP_PASS_2 =
            "SELECT DebtorID FROM Debtor WHERE AccountPhone = dbo.ufn_GetLowerAlpha(@AccountPhone)";

        protected string SQL_INSERT_DEBTOR =
            "INSERT INTO Debtor (DupNameValue,AccountName,AdditionalName,street,street2,city,stateProvince,postalcode,AccountID,SIC,AccountPhone,IsEstimatedYearsOpen,YearsOpen) VALUES (dbo.ufn_ProcessName(@AccountName),@AccountName,@AdditionalName,@street,@street2,@city,@stateProvince,@postalcode,@AccountID,@SIC,@AccountPhone,@IsEstimatedYearsOpen,@YearsOpen);SELECT SCOPE_IDENTITY();";

        protected string SQL_INSERT_ARAGING =
            "INSERT INTO ARAging (DebtorID,CreditorID,ExtractDate,AccountID,AmtTotal,AmtCurrent,AmtPD30,AmtPD60,AmtPD90,AmtPD90over,DateOfLastActivity,TermsIDExperian,HighCredit) VALUES (@DebtorID,@CreditorID,@ExtractDate,@AccountID,@AmtTotal,@AmtCurrent,@AmtPD30,@AmtPD60,@AmtPD90,@AmtPD90over,@DateOfLastActivity,@TermsIDExperian,@HighCredit);";
        
        
        protected void ProcessDebtor(int iCreditorID, string[] aszInputFields)
        {

            if (aszInputFields.Length < 32)
            {
                _iSkippedLines++;
                return;
            }

            if (string.IsNullOrEmpty(aszInputFields[4]))
            {
                _iSkippedLines++;
                return;
            }

            int iDebtorID = 0;

            if (_htDupAccounts.ContainsKey(aszInputFields[4]))
            {
                iDebtorID = (int)_htDupAccounts[aszInputFields[4]];
                //Console.WriteLine("...found in cache...");
            }
            else
            {
                // Pass 1
                SqlCommand sqlDupCheck = _dbConn.CreateCommand();
                sqlDupCheck.Parameters.Add(new SqlParameter("AccountName", aszInputFields[4]));
                sqlDupCheck.Parameters.Add(new SqlParameter("City", aszInputFields[8]));
                sqlDupCheck.Parameters.Add(new SqlParameter("State", aszInputFields[9]));
                sqlDupCheck.CommandText = SQL_DUP_PASS_1;
                iDebtorID = Convert.ToInt32(sqlDupCheck.ExecuteScalar());

                // Pass 2
                if ((iDebtorID == 0) && IsValidPhone(aszInputFields[14]))
                {
                    sqlDupCheck.Parameters.Clear();
                    sqlDupCheck.Parameters.Add(new SqlParameter("AccountPhone", aszInputFields[14]));
                    sqlDupCheck.CommandText = SQL_DUP_PASS_2;
                    iDebtorID = Convert.ToInt32(sqlDupCheck.ExecuteScalar());
                }

                // Not found, add it
                if (iDebtorID == 0)
                {
                    sqlDupCheck.Parameters.Clear();
                    sqlDupCheck.Parameters.Add(new SqlParameter("AccountName", aszInputFields[4]));
                    sqlDupCheck.Parameters.Add(new SqlParameter("AdditionalName", aszInputFields[5]));
                    sqlDupCheck.Parameters.Add(new SqlParameter("street", aszInputFields[6]));
                    sqlDupCheck.Parameters.Add(new SqlParameter("street2", aszInputFields[7]));
                    sqlDupCheck.Parameters.Add(new SqlParameter("city", aszInputFields[8]));
                    sqlDupCheck.Parameters.Add(new SqlParameter("stateProvince", aszInputFields[9]));
                    sqlDupCheck.Parameters.Add(new SqlParameter("postalcode", aszInputFields[10]));
                    sqlDupCheck.Parameters.Add(new SqlParameter("AccountID", aszInputFields[12]));
                    sqlDupCheck.Parameters.Add(new SqlParameter("SIC", aszInputFields[13]));

                    if (!IsValidPhone(aszInputFields[14]))
                    {
                        sqlDupCheck.Parameters.Add(new SqlParameter("AccountPhone", DBNull.Value));
                    }
                    else
                    {
                        sqlDupCheck.Parameters.Add(new SqlParameter("AccountPhone", aszInputFields[14]));
                    }


                    sqlDupCheck.Parameters.Add(new SqlParameter("IsEstimatedYearsOpen", aszInputFields[15]));

                    if (string.IsNullOrEmpty(aszInputFields[16]))
                    {
                        sqlDupCheck.Parameters.Add(new SqlParameter("YearsOpen", DBNull.Value));
                    }
                    else
                    {
                        sqlDupCheck.Parameters.Add(new SqlParameter("YearsOpen", aszInputFields[16]));
                    }

                    sqlDupCheck.CommandText = SQL_INSERT_DEBTOR;
                    iDebtorID = Convert.ToInt32(sqlDupCheck.ExecuteScalar());

                    _iDebtorCount++;
                }

                _htDupAccounts.Add(aszInputFields[4], iDebtorID);
            }

            SqlCommand sqlARAging = _dbConn.CreateCommand();
            sqlARAging.Parameters.Add(new SqlParameter("DebtorID", iDebtorID));
            sqlARAging.Parameters.Add(new SqlParameter("CreditorID", iCreditorID));
            sqlARAging.Parameters.Add(new SqlParameter("ExtractDate", GetDateValue(aszInputFields[11])));
            sqlARAging.Parameters.Add(new SqlParameter("AccountID", aszInputFields[12]));
            sqlARAging.Parameters.Add(new SqlParameter("AmtTotal", aszInputFields[22]));
            sqlARAging.Parameters.Add(new SqlParameter("AmtCurrent", aszInputFields[23]));
            sqlARAging.Parameters.Add(new SqlParameter("AmtPD30", aszInputFields[24]));
            sqlARAging.Parameters.Add(new SqlParameter("AmtPD60", aszInputFields[25]));
            sqlARAging.Parameters.Add(new SqlParameter("AmtPD90", aszInputFields[26]));
            sqlARAging.Parameters.Add(new SqlParameter("AmtPD90over", aszInputFields[27]));
            sqlARAging.Parameters.Add(new SqlParameter("DateOfLastActivity", GetDateValue(aszInputFields[17])));
            sqlARAging.Parameters.Add(new SqlParameter("TermsIDExperian", aszInputFields[18]));
            sqlARAging.Parameters.Add(new SqlParameter("HighCredit", aszInputFields[20]));

            sqlARAging.CommandText = SQL_INSERT_ARAGING;
            sqlARAging.ExecuteNonQuery();

            _iARCount++;

            switch (_iARCount % 7)
            {
                case 0: Console.Write("|"); break;
                case 1: Console.Write("/"); break;
                case 2: Console.Write("-"); break;
                case 3: Console.Write(@"\"); break;
                case 4: Console.Write("|"); break;
                case 5: Console.Write(@"/"); break;
                case 6: Console.Write("-"); break;
                case 7: Console.Write(@"\"); break;
            }
            Console.SetCursorPosition(Console.CursorLeft - 1, Console.CursorTop);

        }

        protected object GetDateValue(string szValue)
        {
            if (string.IsNullOrEmpty(szValue.Trim()))
            {
                return DBNull.Value;
            }

            if (szValue.Length < 8)
            {
                return DBNull.Value;
            }

            return new DateTime(Convert.ToInt32(szValue.Substring(4, 4)), Convert.ToInt32(szValue.Substring(0, 2)), Convert.ToInt32(szValue.Substring(2, 2)));
        }

        protected bool IsValidPhone(string szValue)
        {
            if (string.IsNullOrEmpty(szValue.Trim()))
            {
                return false;
            }

            if (szValue.Length < 10) {
                return false;
            }

            if ((szValue == "1111111111") ||
                (szValue == "0000000000")) {
                return false;
            }

            return true;
        }

        protected void WriteLine(string szLine)
        {
            Console.WriteLine(szLine);
            _lszOutputBuffer.Add(szLine);
        }
    }
}
