using CommandLine.Utility;
using ICSharpCode.SharpZipLib.Zip;
using LumenWorks.Framework.IO.Csv;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using TSI.Utils;

namespace PACAComplaintDetailImporter
{
    public class PACAComplaintDetailImporter
    {
        protected bool _commit = false;
        protected bool _batchMode = false;
        protected string _sourceFolder = String.Empty;
        protected int _numFilesToRead = 0;

        protected int _zipFilesRead = 0;
        protected int _complaintFilesRead = 0;
        protected int _complaintsRead = 0;
        protected int _complaintDetailRecordsCreated;


        public void Import(string[] args)
        {
            Console.Clear();
            Console.Title = "PACA Complaint Detail Importer Utility";
            WriteLine("PACA Complaint Detail Importer Utility 1.0");
            WriteLine("Copyright (c) 2022-2023 Blue Book Services, Inc.");
            WriteLine("All Rights Reserved.");
            WriteLine("  OS Version: " + System.Environment.OSVersion.ToString());
            WriteLine(" CLR Version: " + System.Environment.Version.ToString());
            WriteLine(string.Empty);
            WriteLine(DateTime.Now.ToString("M/dd/yyyy hh:mm tt"));

            _szPath = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Substring(6);

            if (args.Length == 0) {
                //DisplayHelp();
                return;
            }

            // Command line parsing
            Arguments oCommandLine = new Arguments(args);
            DateTime fileDate = DateTime.Now;

            if (oCommandLine["SourceFolder"] != null) {
                _sourceFolder = oCommandLine["SourceFolder"];

                if (!Directory.Exists(_sourceFolder))
                    WriteLine($"/SourceFolder={_sourceFolder} - folder does not exist!");
            }
            else {
                WriteLine("/SourceFolder= parameter missing.");
                return;
            }

            if (oCommandLine["NumFilesToRead"] != null)
            {
                if (!Int32.TryParse(oCommandLine["NumFilesToRead"], out _numFilesToRead))
                {
                    WriteLine("/NumFilesToRead= parameter invalid.");
                    return;
                }
            }
            else
            {
                WriteLine("/NumFilesToRead= parameter missing.");
                return;
            }

            if (oCommandLine["Commit"].ToLower() == "y") {
                _commit = true;
            }

            if (oCommandLine["BatchMode"].ToLower() == "y")
            {
                _batchMode = true;
            }

            timestamp = fileDate.ToString("yyyyMMddHHmm");
            _szOutputFile = Path.Combine(_szPath, string.Format("PACAComplaintDetailImport_{0}.txt", timestamp));

            try {
                ImportPACAComplaintDetailData(fileDate);
                WriteOuptutBuffer();
            }
            catch (Exception e) {
                Console.WriteLine();
                Console.WriteLine();
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine("An unexpected exception occurred: " + e.Message);
                Console.WriteLine(e.StackTrace);
                Console.WriteLine("Terminating execution.");
                Console.ForegroundColor = ConsoleColor.Gray;

                WriteOuptutBuffer();

                using (StreamWriter sw = new StreamWriter(Path.Combine(_szPath, string.Format("PACAComplaintDetailImport_{0}_Exception.txt", timestamp)))) {
                    sw.WriteLine(e.Message + Environment.NewLine);
                    sw.WriteLine(e.StackTrace);
                }
            }

            if (!_batchMode) {
                Console.Write("Press any key to continue . . . ");
                Console.ReadKey(true);
            }
        }

        /// <summary>
        /// Import the PACA Files
        /// </summary>
        public void ImportPACAComplaintDetailData(DateTime fileDate)
        {
            DateTime dtExecutionStartDate = fileDate;
            int iProcessedCount = 0;
            
            outputDir = Path.Combine(_sourceFolder, "Temp");
            if (!Directory.Exists(outputDir))
                Directory.CreateDirectory(outputDir);

            int intPACACommandTimeout = Utilities.GetIntConfigValue("PACACommandTimeout", 3600);
            StringBuilder sbMsg = new StringBuilder();

            SqlConnection oConn = new SqlConnection(ConfigurationManager.ConnectionStrings["SQLServer"].ConnectionString);
            oConn.Open();

            SqlTransaction oTran = null;

            try
            {
                oTran = oConn.BeginTransaction();

                string[] files = Directory.GetFiles(_sourceFolder, "*.zip");
                foreach (string zipFileName in files)
                {
                    _zipFilesRead++;
                    WriteLine($"Processing file {zipFileName}");
                    ExtractFiles(zipFileName, outputDir);

                    string szComplaintsFileName = GetComplaintsFileName(outputDir);
                    if (szComplaintsFileName.Length > 0)
                    {
                        _complaintFilesRead++;
                        complaints = new PACAFile(szComplaintsFileName, PACAFile.FileType.Complaints, this);
                        LoadFile(oConn, oTran, complaints);
                        
                        WriteLine($"  - {complaints.RowCount} complaints found.");
                    }
                    else
                        WriteLine($"  - No complaint file found.");

                    DeleteFiles(outputDir); //Delete temp files

                    iProcessedCount++;
                    if (iProcessedCount >= _numFilesToRead)
                        break;
                }

                if (_commit)
                {
                    oTran.Commit();
                    WriteLine("Committing changes to database because /commit was Y");
                }
                else
                {
                    oTran.Rollback();
                    WriteLine("Rolling back changes to database because /commit was not Y");
                }
            }
            catch
            {
                if (oTran != null)
                    oTran.Rollback();

                throw;
            }

            WriteLine("PACA Complaint Detail import results for date " + fileDate.ToString("MM-dd-yyyy") + "." + Environment.NewLine);
            WriteFileDetails(sbMsg, complaints, 0);

            DateTime dtExecutionEndDateTime = DateTime.Now;
            WriteLine(string.Empty);

            TimeSpan tsDiff = dtExecutionEndDateTime.Subtract(dtExecutionStartDate);
            WriteLine("\n\nExecution time: " + tsDiff.ToString());
        }

        private void DeleteFiles(string path)
        {
            System.IO.DirectoryInfo di = new DirectoryInfo(path);
            foreach (FileInfo file in di.GetFiles())
            {
                file.Delete();
            }
        }

        private string GetComplaintsFileName(string outputDir)
        {
            string[] files = Directory.GetFiles(outputDir, "*complaint.csv");
            if (files.Length == 1)
                return files[0];
            else
                return "";
        }

        protected string _szOutputFile;
        protected string _szPath;
        protected List<string> _lszOutputBuffer = new List<string>();

        private void WriteLine(string msg)
        {
            Console.WriteLine(msg);
            _lszOutputBuffer.Add(msg);
        }

        public void WriteErrorLine(string msg)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine("ERROR: " + msg);
            Console.ForegroundColor = ConsoleColor.Gray;
            _lszOutputBuffer.Add(msg);
        }

        private void WriteFileDetails(StringBuilder sbMsg, PACAFile pacaFile, int iMatchedLicenses)
        {
            WriteLine("File: " + pacaFile.FileName);
            WriteLine(" - # of Zip Files Read: " + _zipFilesRead.ToString("###,##0"));
            WriteLine(" - # of Complaint Files Read: " + _complaintFilesRead.ToString("###,##0"));
            WriteLine(" - # of Complaints Read: " + _complaintsRead.ToString("###,##0"));
            WriteLine(" - # of Complaint Detail records created: " + _complaintDetailRecordsCreated.ToString("###,##0"));

            if (pacaFile.Errors.Count > 0) {
                WriteLine(" - Failed Record Details: ");
                foreach (string error in pacaFile.Errors) {
                    WriteLine("   * " + error);
                }
            }
        }

        private void WriteOuptutBuffer()
        {
            using (StreamWriter sw = new StreamWriter(_szOutputFile)) {
                foreach (string line in _lszOutputBuffer) {
                    sw.WriteLine(line);
                }
            }
        }

        private const string SQL_RETRIEVE_PRPACACOMPLAINTDETAIL = 
                        @"SELECT TOP 1 * FROM PRPACAComplaintDetail 
                            WHERE prpacd_LicenseNumber=@LicenseNumber ORDER BY prpacd_PRPACAComplaintDetailID DESC";

        /// <summary>
        /// This method loads the specified file into the CRM database.
        /// </summary>
        /// <param name="dbConn"></param>
        /// <param name="oTran"></param>
        /// <param name="pacaFile"></param>
		private void LoadFile(SqlConnection dbConn,
                              SqlTransaction oTran,
                              PACAFile pacaFile)
        {
            // Create a name for the file to store
            string sFilename = Path.GetFileName(pacaFile.FileName);

            // Make all date references one consistent time
            DateTime dtNow = DateTime.Now;

            SqlCommand cmdCreate = null;
            SqlParameter parm = null;
            int iReturn;

            //create some variables for statistics
            int iWrongCount = 0;
            int iRecordsCreated = 0;
            int iRowCount = 0;
            int iFailedLoad = 0;

            try {
                cmdCreate = new SqlCommand(pacaFile.StoredProc, dbConn);
                cmdCreate.CommandType = CommandType.StoredProcedure;
                cmdCreate.Transaction = oTran;

                // Process each line of input
                string licenseNumber = string.Empty;
                DateTime fileDate;

                using (CsvReader csv = new CsvReader(new StreamReader(Path.Combine(outputDir, pacaFile.FileName)), true)) {
                    fileDate = new DateTime(Convert.ToInt32(sFilename.Substring(0, 4)),
                                            Convert.ToInt32(sFilename.Substring(4, 2)),
                                            Convert.ToInt32(sFilename.Substring(6, 2)));
                    while (csv.ReadNextRecord()) {
                        iRowCount++;
                        _complaintsRead++;

                        // Cursory validation of this line says that it 
                        // should have <iExpectedCount> fields
                        // If it doesn't we cannot process it.
                        if (csv.FieldCount != pacaFile.ColumnCount) {
                            iWrongCount++;
                            continue;
                        }

                        // this record may have a fighting chance at being processed
                        for (int i = 0; i < csv.FieldCount; i++) {

                            // if the value is empty, set our string value property to null
                            if (csv[i].Length == 0)
                                pacaFile.Parameters[i].ParamValue = null;
                            else
                                pacaFile.Parameters[i].ParamValue = csv[i];
                        }

                        //If num_informal_reparation_complaints and num_formal_reparation_complaints are both 0, skip.
                        if(pacaFile.Parameters[3].ParamValue=="0" && pacaFile.Parameters[5].ParamValue == "0")
                            continue;

                        string szLicenseNumber = pacaFile.Parameters[1].ParamValue;

                        if(szLicenseNumber == null)
                        {
                            iWrongCount++;
                            continue;
                        }
                        SqlCommand cmdPACAComplaintDetail = new SqlCommand(SQL_RETRIEVE_PRPACACOMPLAINTDETAIL, dbConn);
                        cmdPACAComplaintDetail.CommandType = CommandType.Text;
                        cmdPACAComplaintDetail.Transaction = oTran;
                        cmdPACAComplaintDetail.Parameters.AddWithValue("LicenseNumber", szLicenseNumber);

                        int prevInfRepComplaintCount = 0;
                        int prevForRepComplaintCount = 0;
                        bool blnPrevExists = false;

                        using (IDataReader oReader = cmdPACAComplaintDetail.ExecuteReader())
                        {
                            while (oReader.Read())
                            {
                                if(oReader["prpacd_InfRepComplaintCount"] != DBNull.Value)
                                    prevInfRepComplaintCount = (int)oReader["prpacd_InfRepComplaintCount"];

                                if (oReader["prpacd_ForRepComplaintCount"] != DBNull.Value)
                                    prevForRepComplaintCount = (int)oReader["prpacd_ForRepComplaintCount"];
                                blnPrevExists = true;
                            }
                        }

                        int changedInfRepComplaints = prevInfRepComplaintCount - Convert.ToInt32(pacaFile.Parameters[3].ParamValue);
                        int changedForRepComplaints = prevForRepComplaintCount - Convert.ToInt32(pacaFile.Parameters[5].ParamValue);

                        if(!blnPrevExists)
                        {
                            // Handle situation where no record exists in DB
                            changedInfRepComplaints = Math.Abs(changedInfRepComplaints);
                            changedForRepComplaints = Math.Abs(changedForRepComplaints);
                        }

                        if (changedInfRepComplaints > 0 || changedForRepComplaints > 0)
                        {
                            try
                            {
                                //insert new PRPACAComplaintDetail record for the file date, license number, and positive change values.
                                //If only one is positive, then ignore the other.

                                // clear all stored procedure parameters
                                cmdCreate.Parameters.Clear();

                                // create the return parameter
                                parm = cmdCreate.Parameters.Add("ReturnValue", SqlDbType.Int);
                                parm.Direction = ParameterDirection.ReturnValue;

                                parm = cmdCreate.Parameters.AddWithValue("@prpacd_LicenseNumber", szLicenseNumber);
                                parm = cmdCreate.Parameters.AddWithValue("@prpacd_ChangeDate", fileDate);

                                if (changedInfRepComplaints > 0)
                                    parm = cmdCreate.Parameters.AddWithValue("@prpacd_InfRepComplaintCount", changedInfRepComplaints);
                                else
                                    parm = cmdCreate.Parameters.AddWithValue("@prpacd_InfRepComplaintCount", null);

                                if (changedForRepComplaints > 0)
                                    parm = cmdCreate.Parameters.AddWithValue("@prpacd_ForRepComplaintCount", changedForRepComplaints);
                                else
                                    parm = cmdCreate.Parameters.AddWithValue("@prpacd_ForRepComplaintCount", null);

                                //StringBuilder sbSQL = new StringBuilder("EXEC " + cmdCreate.CommandText + " ");
                                cmdCreate.ExecuteNonQuery();
                                _complaintDetailRecordsCreated++;

                                // This return value is the ID of the record inserted
                                // We don't use it here.
                                iReturn = Convert.ToInt32(cmdCreate.Parameters["ReturnValue"].Value);
                                iRecordsCreated++;
                            }
                            catch (Exception e)
                            {
                                if (csv != null && csv.FieldCount > 2)
                                {
                                    pacaFile.Errors.Add(pacaFile.FileName + ": " + e.Message + " License #: [" + csv[1] + "]");
                                }
                                else
                                {
                                    pacaFile.Errors.Add(pacaFile.FileName + ": " + e.Message);
                                }

                                iFailedLoad++;
                            }
                        }
                    }
                }
            }
            finally {
                pacaFile.SuccessCount = iRecordsCreated;
                pacaFile.FailedCount = iFailedLoad;
                pacaFile.WrongFormatCount = iWrongCount;
                pacaFile.RowCount = iRowCount;
            }
        }

        private string timestamp = null;
        private string outputDir = null;
        private PACAFile complaints = null;

        private void ExtractFiles(string zipFileName, string targetFolder)
        {
            FastZip fastZip = new FastZip();
            string fileFilter = null;

            // Will always overwrite if target filenames already exist
            fastZip.ExtractZip(zipFileName, targetFolder, fileFilter);
        }
    }

    public class PACAFile
    {
        PACAComplaintDetailImporter Importer;

        public enum FileType { Complaints }

        public string FileName;
        public FileType Type;
        public int FailedCount;
        public int SuccessCount;
        public int WrongFormatCount;
        public int RowCount;

        public List<String> Errors = new List<string>();
        public List<DBParam> Parameters = new List<DBParam>();

        public string StoredProc;
        public int ColumnCount;

        public PACAFile(string fileName, FileType type, PACAComplaintDetailImporter importer)
        {
            FileName = fileName;
            Type = type;
            Importer = importer;
            Initialize();
        }

        private void Initialize()
        {
            switch (Type) {
                case FileType.Complaints:
                    StoredProc = "usp_CreatePACAComplaintDetail";
                    ColumnCount = 7;

                    Parameters.Add(new DBParam("@pripc_BusinessName", SqlDbType.NVarChar));
                    Parameters.Add(new DBParam("@pripc_LicenseNumber", SqlDbType.NVarChar));
                    Parameters.Add(new DBParam("@pripc_DisInfRepComplaintCount", SqlDbType.Int));
                    Parameters.Add(new DBParam("@pripc_InfRepComplaintCount", SqlDbType.Int));
                    Parameters.Add(new DBParam("@pripc_DisForRepCompaintCount", SqlDbType.Int));
                    Parameters.Add(new DBParam("@pripc_ForRepComplaintCount", SqlDbType.Int));
                    Parameters.Add(new DBParam("@pripc_TotalFormalClaimAmt", SqlDbType.Decimal));

                    break;
            }
        }
    }

    public class DBParam
    {
        public string SPParamName;
        public SqlDbType Type;
        public string ParamValue;

        public DBParam(string SPParamName, SqlDbType Type)
        {
            this.SPParamName = SPParamName;
            this.Type = Type;
        }

        public DBParam(string SPParamName, SqlDbType Type, string ParamValue)
        {
            this.SPParamName = SPParamName;
            this.Type = Type;
            this.ParamValue = ParamValue;
        }
    }
}