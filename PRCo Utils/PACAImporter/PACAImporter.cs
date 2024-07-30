using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Net;
using System.Text;
using System.Text.RegularExpressions;

using CommandLine.Utility;
using LumenWorks.Framework.IO.Csv;
using ICSharpCode.SharpZipLib.Zip;
using TSI.Utils;

namespace PACAImporter
{
    public class PACAImporter
    {
        protected bool _commit = false;
        protected bool _batchMode = false;

        public void Import(string[] args)
        {
            Console.Clear();
            Console.Title = "PACA Importer Utility";
            WriteLine("PACA Importer Utility 1.5");
            WriteLine("Copyright (c) 2018-2022 Blue Book Services, Inc.");
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

            DateTime fileDate = new DateTime(2024, 6, 1);
            
            //DateTime fileDate = DateTime.MinValue;

            //if (oCommandLine["FileDate"] != null) {

            //    if (!DateTime.TryParse(oCommandLine["FileDate"], out fileDate)) {
            //        WriteLine("/FileDate= parameter invalid.");
            //        return;
            //    }

            //}
            //else {
            //    WriteLine("/FileDate= parameter missing.");
            //    return;
            //}

            if (oCommandLine["Commit"] == "Y") {
                _commit = true;
            }

            if (oCommandLine["BatchMode"] == "Y") {
                _batchMode = true;
            }

            //timestamp = fileDate.ToString("yyyyMMdd");
            //_szOutputFile = Path.Combine(_szPath, string.Format("PACAImport_{0}.txt", timestamp));
            _szOutputFile = Path.Combine(_szPath, string.Format("PACA Full Refresh.txt", timestamp));

            try {
                ImportPACAData(fileDate);
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

                using (StreamWriter sw = new StreamWriter(Path.Combine(_szPath, string.Format("PACAImport_{0}_Exception.txt", timestamp)))) {
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
        public void ImportPACAData(DateTime fileDate)
        {
            DateTime dtExecutionStartDate = DateTime.Now;

            int intPACACommandTimeout = Utilities.GetIntConfigValue("PACACommandTimeout", 3600);
            StringBuilder sbMsg = new StringBuilder();

            string importDir = Utilities.GetConfigValue("PACAImportFolder");
            outputDir = Path.Combine(importDir, "Temp");
            if (!Directory.Exists(outputDir))
                Directory.CreateDirectory(outputDir);

            //string zipFileName = Path.Combine(importDir, string.Format("PACAImport_{0}.zip", timestamp)); 
            //ExtractFiles(zipFileName, outputDir);

            //license = new PACAFile(timestamp + "license.csv", PACAFile.FileType.License, this);
            //trade = new PACAFile(timestamp + "trade.csv", PACAFile.FileType.Trade, this);
            //principal = new PACAFile(timestamp + "principal.csv", PACAFile.FileType.Principal, this);
            //complaints = new PACAFile(timestamp + "complaint.csv", PACAFile.FileType.Complaints, this);

            license = new PACAFile("Active Entity as of 05-29-2024.csv", PACAFile.FileType.License, this);
            principal = new PACAFile("Active Principals as of 05-29-2024.csv", PACAFile.FileType.Principal, this);


            //int fileCount = ValidateFiles();
            //if (fileCount == 0) {
            //    WriteLine("No files found");
            //    return;
            //}

            int iMatchedLicenses = 0;
            SqlConnection oConn = new SqlConnection(ConfigurationManager.ConnectionStrings["SQLServer"].ConnectionString);
            oConn.Open();

            SqlTransaction oTran = null;

            try
            {
                try
                {
                    oTran = oConn.BeginTransaction();

                    DateTime metricStart = DateTime.Now;
                    WriteLine("Load License File");
                    LoadFile(oConn, oTran, license);
                    WriteLine($" - {DateTime.Now.Subtract(metricStart)}");

                    //metricStart = DateTime.Now;
                    //WriteLine("Load Trade File");
                    //LoadFile(oConn, oTran, trade);
                    //WriteLine($" - {DateTime.Now.Subtract(metricStart)}");

                    metricStart = DateTime.Now;
                    WriteLine("Load Principal File");
                    LoadFile(oConn, oTran, principal);
                    WriteLine($" - {DateTime.Now.Subtract(metricStart)}");

                    //if (File.Exists(Path.Combine(outputDir, complaints.FileName)))
                    //{
                    //    metricStart = DateTime.Now;
                    //    WriteLine("Load Complaints File");
                    //    LoadFile(oConn, oTran, complaints);
                    //    WriteLine($" - {DateTime.Now.Subtract(metricStart)}");
                    //}

                    if (_commit)
                        oTran.Commit();
                    else
                    {
                        oTran.Rollback();
                    }
                }
                catch
                {
                    if (oTran != null)
                        oTran.Rollback();

                    throw;
                }

                try
                {
                    //oTran = oConn.BeginTransaction();

                    // Now we execute the stored procedure that processes
                    // the newly imported records.
                    SqlCommand cmdCreate = null;
                    SqlParameter parm = null;

                    cmdCreate = new SqlCommand("usp_PACAProcessImports", oConn);
                    cmdCreate.CommandType = CommandType.StoredProcedure;
                    cmdCreate.Transaction = oTran;
                    cmdCreate.CommandTimeout = intPACACommandTimeout;

                    parm = cmdCreate.Parameters.Add("ReturnValue", SqlDbType.Int);
                    parm.Direction = ParameterDirection.ReturnValue;

                    DateTime metricStart = DateTime.Now;
                    WriteLine("Execute usp_PACAProcessImports");
                    cmdCreate.ExecuteNonQuery();
                    WriteLine($" - {DateTime.Now.Subtract(metricStart)}");

                    iMatchedLicenses = Convert.ToInt32(cmdCreate.Parameters["ReturnValue"].Value);

                    //if (File.Exists(Path.Combine(outputDir, complaints.FileName)))
                    //{
                    //    //Process Complaints (3.1.2.5)
                    //    SqlCommand cmdProcessComplaints = new SqlCommand("usp_PACAProcessComplaints", oConn);
                    //    cmdProcessComplaints.CommandType = CommandType.StoredProcedure;
                    //    cmdProcessComplaints.Transaction = oTran;
                    //    cmdProcessComplaints.CommandTimeout = intPACACommandTimeout;
                    //    cmdProcessComplaints.ExecuteNonQuery();
                    //}

                    //if (_commit)
                    //    oTran.Commit();
                    //else
                    //    oTran.Rollback();
                }
                catch
                {
                    //if (oTran != null)
                    //    oTran.Rollback();

                    throw;
                }
            }
            finally
            {
                if (oConn != null)
                {
                    oConn.Close();
                }

                oConn = null;

                //DeleteFile(license);
                //DeleteFile(trade);
                //DeleteFile(principal);
                //DeleteFile(complaints);
            }

            WriteLine("PACA import results for date " + fileDate.ToString("MM-dd-yyyy") + "." + Environment.NewLine);

            if (!string.IsNullOrEmpty(complaintsMsg))
            {
                sbMsg.Append(complaintsMsg);
                sbMsg.Append(Environment.NewLine);
                sbMsg.Append(Environment.NewLine);
            }

            WriteFileDetails(sbMsg, license, iMatchedLicenses);
            sbMsg.Append(Environment.NewLine);
            //WriteFileDetails(sbMsg, trade, 0);
            //sbMsg.Append(Environment.NewLine);
            WriteFileDetails(sbMsg, principal, 0);
            sbMsg.Append(Environment.NewLine);
            //WriteFileDetails(sbMsg, complaints, 0);

            DateTime dtExecutionEndDateTime = DateTime.Now;
            WriteLine(string.Empty);
            //WriteLine("Start Date/Time:" + dtExecutionStartDate.ToString());
            //WriteLine("End Date/Time:" + dtExecutionEndDateTime.ToString());

            TimeSpan tsDiff = dtExecutionEndDateTime.Subtract(dtExecutionStartDate);
            WriteLine("\n\nExecution time: " + tsDiff.ToString());
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
            WriteLine(" - Success Count: " + pacaFile.SuccessCount.ToString("###,##0"));
            WriteLine(" - Failed Count: " + pacaFile.FailedCount.ToString("###,##0"));
            WriteLine(" - Wrong Format Count: " + pacaFile.WrongFormatCount.ToString("###,##0"));
            if (iMatchedLicenses > 0)
                WriteLine(" - Match Count: " + iMatchedLicenses.ToString("###,##0"));

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
            int iFailedLoad = 0;
            int iSuccessLoad = 0;

            try {
                cmdCreate = new SqlCommand(pacaFile.StoredProc, dbConn);
                cmdCreate.CommandType = CommandType.StoredProcedure;
                cmdCreate.Transaction = oTran;

                // Process each line of input
                int iSequence = 0; //used by Principal
                string licenseNumber = string.Empty;

                using (CsvReader csv = new CsvReader(new StreamReader(Path.Combine(outputDir, pacaFile.FileName)), true)) {
                    while (csv.ReadNextRecord()) {
                        // Cursory validation of this line says that it 
                        // should have <iExpectedCount> fields
                        // If it doesn't we cannot process it.
                        if (csv.FieldCount != pacaFile.ColumnCount) {
                            iWrongCount++;
                            continue;
                        }

                        // this record may have a fighting chance at being processed
                        for (int i = 0; i < csv.FieldCount; i++) {

                            if ((Utilities.GetBoolConfigValue("PACALicenseDeletedFieldEnabled", true)) &&
                                (pacaFile.Type == PACAFile.FileType.License) &&
                                (i == 27))
                                continue;

                            // if the value is empty, set our string value property to null
                            if (csv[i].Length == 0)
                                pacaFile.Parameters[i].ParamValue = null;
                            else
                                pacaFile.Parameters[i].ParamValue = csv[i];
                        }

                        try {
                            // clear all stored procedure parameters
                            cmdCreate.Parameters.Clear();

                            // create the return parameter
                            parm = cmdCreate.Parameters.Add("ReturnValue", SqlDbType.Int);
                            parm.Direction = ParameterDirection.ReturnValue;

                            // Load the stored procedure based upon file type
                            switch (pacaFile.Type) {
                                case PACAFile.FileType.License:
                                    // load sp parameters common for each call
                                    parm = cmdCreate.Parameters.AddWithValue("@pril_FileName", sFilename);
                                    parm = cmdCreate.Parameters.AddWithValue("@pril_ImportDate", dtNow);
                                    break;

                                case PACAFile.FileType.Principal:

                                    // load sp parameters common for each call
                                    parm = cmdCreate.Parameters.AddWithValue("@prip_FileName", sFilename);
                                    parm = cmdCreate.Parameters.AddWithValue("@prip_ImportDate", dtNow);

                                    // load the sequence
                                    parm = cmdCreate.Parameters.AddWithValue("@prip_Sequence", iSequence);
                                    iSequence++;
                                    break;

                                case PACAFile.FileType.Trade:
                                    // load sp parameters common for each call
                                    parm = cmdCreate.Parameters.AddWithValue("@prit_FileName", sFilename);
                                    parm = cmdCreate.Parameters.AddWithValue("@prit_ImportDate", dtNow);
                                    break;
                                case PACAFile.FileType.Complaints:
                                    // load sp parameters common for each call
                                    parm = cmdCreate.Parameters.AddWithValue("@pripc_FileName", sFilename);
                                    parm = cmdCreate.Parameters.AddWithValue("@pripc_ImportDate", dtNow);
                                    break;
                            }

                            pacaFile.LoadParameters(cmdCreate);

                            bool saveRecord = true;
                            StringBuilder sbSQL = new StringBuilder("EXEC " + cmdCreate.CommandText + " ");
                            foreach (SqlParameter parm2 in cmdCreate.Parameters) {

                                if ((parm2.ParameterName == "@pril_LicenseNumber") ||
                                    (parm2.ParameterName == "@prip_LicenseNumber") ||
                                    (parm2.ParameterName == "@prit_LicenseNumber") ||
                                    (parm2.ParameterName == "@pripc_LicenseNumber"))
                                {
                                    licenseNumber = Convert.ToString(parm2.Value);

                                    if (string.IsNullOrEmpty(licenseNumber)) {
                                        saveRecord = false;
                                        iFailedLoad++;
                                        pacaFile.Errors.Add(pacaFile.FileName + ": No License # specified");

                                    }

                                    if (licenseNumber.StartsWith("Z")) {
                                        saveRecord = false;
                                        iFailedLoad++;
                                        pacaFile.Errors.Add(pacaFile.FileName + ": License # begins with 'Z' - " + licenseNumber);
                                    }

                                    if (licenseNumber.Length > 8)
                                    {
                                        saveRecord = false;
                                        iFailedLoad++;
                                        pacaFile.Errors.Add(pacaFile.FileName + ": License # is greater than 8 characters - " + licenseNumber);
                                    }
                                }

                                if (skipLicenses.Contains(licenseNumber)) { 
                                    saveRecord = false;
                                    iFailedLoad++;
                                    pacaFile.Errors.Add(pacaFile.FileName + ": This license # was previously skipped - " + licenseNumber);
                                }                       

                                if (parm2.ParameterName == "@pril_TerminateCode") {
                                    if (Convert.ToString(parm2.Value) == "0") {
                                        saveRecord = false;
                                        skipLicenses.Add(licenseNumber);

                                        iFailedLoad++;
                                        pacaFile.Errors.Add(pacaFile.FileName + ": Status Code = No License (0) - " + licenseNumber);
                                    }
                                }

                                sbSQL.Append(Environment.NewLine);
                                sbSQL.Append(parm2.ParameterName);
                                sbSQL.Append("=");
                                if (parm2.Value == null)
                                    sbSQL.Append("null");
                                else {
                                    sbSQL.Append("'");
                                    sbSQL.Append(parm2.Value.ToString());
                                    sbSQL.Append("'");
                                }
                                sbSQL.Append(", ");
                            }

                            //WriteLine(sbSQL.ToString());

                            if (saveRecord) {
                                cmdCreate.ExecuteNonQuery();

                                // This return value is the ID of the record inserted
                                // We don't use it here.
                                iReturn = Convert.ToInt32(cmdCreate.Parameters["ReturnValue"].Value);
                                iSuccessLoad++;
                            }
                        }
                        catch (Exception e) {
                            if (csv != null && csv.FieldCount > 1) {
                                pacaFile.Errors.Add(pacaFile.FileName + ": " + e.Message + " License #: [" + csv[0] + "]");

                                // If this is for a license record, add it to the skip list
                                // so we don't bother with any associated trade or principal
                                // records.
                                if (pacaFile.Type == PACAFile.FileType.License)
                                    skipLicenses.Add(csv[0]);

                            }
                            else {
                                pacaFile.Errors.Add(pacaFile.FileName + ": " + e.Message);
                            }

                            iFailedLoad++;

                            //if (csv != null && csv.FieldCount > 1) {
                            //    throw new ApplicationException(pacaFile.FileName + ": " + e.Message + " License #: [" + csv[0] + "]", e);
                            //}
                            //else {
                            //    throw new ApplicationException(pacaFile.FileName + ": " + e.Message, e);
                            //}
                        }
                    }
                }
            }
            finally {

                pacaFile.SuccessCount = iSuccessLoad;
                pacaFile.FailedCount = iFailedLoad;
                pacaFile.WrongFormatCount = iWrongCount;
            }
        }

        private string timestamp = null;
        private string outputDir = null;
        private PACAFile license = null;
        private PACAFile trade = null;
        private PACAFile principal = null;
        private PACAFile complaints = null;
        private List<string> skipLicenses = new List<string>();
        private string complaintsMsg = string.Empty;

        private int ValidateFiles()
        {
            int fileCount = 0;

            if (ValidateFile(license))
                fileCount++;
            if (ValidateFile(trade))
                fileCount++;
            if (ValidateFile(principal))
                fileCount++;
            if (ValidateFile(complaints))
                fileCount++;

            return fileCount;
        }

        private bool ValidateFile(PACAFile pacaFile)
        {
            string fullPath = Path.Combine(outputDir, pacaFile.FileName);
            return File.Exists(fullPath);
        }

        private void DeleteFile(PACAFile pacaFile)
        {
            string fullPath = Path.Combine(outputDir, pacaFile.FileName);
            if (File.Exists(fullPath))
                File.Delete(fullPath);
        }


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
        PACAImporter Importer;

        public enum FileType { License, Principal, Trade, Complaints }

        public string FileName;
        public FileType Type;
        public int FailedCount;
        public int SuccessCount;
        public int WrongFormatCount;

        public List<String> Errors = new List<string>();
        public List<DBParam> Parameters = new List<DBParam>();

        public string StoredProc;
        public int ColumnCount;

        public PACAFile(string fileName, FileType type, PACAImporter importer)
        {
            FileName = fileName;
            Type = type;
            Importer = importer;
            Initialize();
        }

        private void Initialize()
        {
            switch (Type) {
                case FileType.License:
                    StoredProc = "usp_CreateImportPACALicense";
                    if (Utilities.GetBoolConfigValue("PACALicenseDeletedFieldEnabled", true))
                        ColumnCount = 28;  // There is an extra "Deleted" field that we are ignoring for now.
                    else
                        ColumnCount = 27;

                    Parameters.Add(new DBParam("@pril_LicenseNumber", SqlDbType.NVarChar));//license number
                    Parameters.Add(new DBParam("@pril_ExpirationDate", SqlDbType.DateTime));//Expiration date
                    Parameters.Add(new DBParam("@pril_CompanyName", SqlDbType.NVarChar));//customer name
                    Parameters.Add(new DBParam("@pril_CustomerFirstName", SqlDbType.NVarChar));//customer first name
                    Parameters.Add(new DBParam("@pril_CustomerMiddleInitial", SqlDbType.NVarChar));//customer middle initial
                    Parameters.Add(new DBParam("@pril_City", SqlDbType.NVarChar));//city
                    Parameters.Add(new DBParam("@pril_State", SqlDbType.NVarChar));//state
                    Parameters.Add(new DBParam("@pril_Address1", SqlDbType.NVarChar));//address line 1
                    Parameters.Add(new DBParam("PostCode", SqlDbType.NVarChar));//zip 
                    Parameters.Add(new DBParam("@pril_PostCode", SqlDbType.NVarChar));// zip plu
                    Parameters.Add(new DBParam("@pril_TypeFruitVeg", SqlDbType.NVarChar));//type fruit / veg
                    Parameters.Add(new DBParam("@pril_ProfCode", SqlDbType.NVarChar));//type business code
                    Parameters.Add(new DBParam("@pril_OwnCode", SqlDbType.NVarChar));//ownership
                    Parameters.Add(new DBParam("@pril_IncState", SqlDbType.NVarChar));//state incorporated
                    Parameters.Add(new DBParam("@pril_IncDate", SqlDbType.DateTime));//date incorporated
                    Parameters.Add(new DBParam("@pril_MailAddress1", SqlDbType.NVarChar));//mailing address line 1
                    Parameters.Add(new DBParam("@pril_MailCity", SqlDbType.NVarChar));//mailing city
                    Parameters.Add(new DBParam("@pril_MailState", SqlDbType.NVarChar));//mailing state
                    Parameters.Add(new DBParam("MailPostCode", SqlDbType.NVarChar));//mailing zip
                    Parameters.Add(new DBParam("@pril_MailPostCode", SqlDbType.NVarChar));//mailing zip+4
                    Parameters.Add(new DBParam("@pril_Telephone", SqlDbType.NVarChar));//number
                    Parameters.Add(new DBParam("@pril_Email", SqlDbType.NVarChar));
                    Parameters.Add(new DBParam("@pril_WebAddress", SqlDbType.NVarChar));
                    Parameters.Add(new DBParam("@pril_Fax", SqlDbType.NVarChar));//number
                    Parameters.Add(new DBParam("@pril_TerminateDate", SqlDbType.DateTime));//termination date
                    Parameters.Add(new DBParam("@pril_TerminateCode", SqlDbType.NVarChar));//termination code
                    Parameters.Add(new DBParam("@pril_PACARunDate", SqlDbType.DateTime));//run date
                    break;

                case FileType.Principal:
                    StoredProc = "usp_CreateImportPACAPrincipal";
                    ColumnCount = 6;

                    Parameters.Add(new DBParam("@prip_LicenseNumber", SqlDbType.NVarChar));
                    Parameters.Add(new DBParam("@prip_LastName", SqlDbType.NVarChar));
                    Parameters.Add(new DBParam("@prip_Title", SqlDbType.NVarChar));
                    Parameters.Add(new DBParam("@prip_City", SqlDbType.NVarChar));
                    Parameters.Add(new DBParam("@prip_State", SqlDbType.NVarChar));
                    Parameters.Add(new DBParam("@prip_PACARunDate", SqlDbType.DateTime));
                    break;

                case FileType.Trade:
                    StoredProc = "usp_CreateImportPACATrade";
                    ColumnCount = 5;

                    Parameters.Add(new DBParam("@prit_LicenseNumber", SqlDbType.NVarChar));
                    Parameters.Add(new DBParam("@prit_AdditionalTradeName", SqlDbType.NVarChar));
                    Parameters.Add(new DBParam("@prit_City", SqlDbType.NVarChar));
                    Parameters.Add(new DBParam("@prit_State", SqlDbType.NVarChar));
                    Parameters.Add(new DBParam("@prit_PACARunDate", SqlDbType.DateTime));
                    break;

                case FileType.Complaints:
                    StoredProc = "usp_CreateImportPACAComplaint";
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

        /// <summary>
        /// Create the stored procedure parameters for the loading of a
        /// PACA License Record
        /// </summary>
        /// <param name="cmdCreate"></param>
        public void LoadParameters(SqlCommand cmdCreate)
        {
            string sParamName = null;
            string sParamValue = null;
            string sTempPhone = string.Empty;
            string sTempZip = string.Empty;
            string sAbbreviation = string.Empty;

            Regex digitsOnly = new Regex(@"[^\d]");

            SqlDbType iType = SqlDbType.NVarChar;

            for (int i = 0; i < Parameters.Count; i++) {

                SqlParameter parm = null;
                sParamName = Parameters[i].SPParamName;
                sParamValue = Parameters[i].ParamValue;
                iType = Parameters[i].Type;

                try {

                    // Determine what to do with the input value
                    if (sParamName == null) {
                        // shouldn't ever be
                        continue;
                    }
                    else if (sParamName.Equals("unused")) {
                        // we don't use this field from the input table
                        continue;
                    }

                    // Part 1 of our Zip Code
                    else if (sParamName.Equals("PostCode")) {
                        sTempZip = sParamValue;
                    }

                    // Part 2 of our Zip Code
                    else if (sParamName.Equals("@pril_PostCode")) {
                        if ((!string.IsNullOrEmpty(sParamValue)) &&
                            (sParamValue != "0"))
                            sTempZip += sParamValue;

                        parm = cmdCreate.Parameters.AddWithValue(sParamName, sTempZip);
                        sTempZip = string.Empty;
                    }

                    // Part 1 of our Zip Code
                    else if (sParamName.Equals("MailPostCode")) {
                        sTempZip = sParamValue;
                    }

                    // Part 2 of our Zip Code
                    else if (sParamName.Equals("@pril_MailPostCode")) {
                        if ((!string.IsNullOrEmpty(sParamValue)) &&
                            (sParamValue != "0"))
                            sTempZip += sParamValue;

                        parm = cmdCreate.Parameters.AddWithValue(sParamName, sTempZip);
                        sTempZip = string.Empty;
                    }

                    else if (sParamName.Equals("@pril_Telephone") ||
                             sParamName.Equals("@pril_Fax")) {
                        // Remove all non-numeric characters
                        sTempPhone = string.Empty;
                        if (sParamValue != null)
                            sTempPhone = digitsOnly.Replace(sParamValue, string.Empty);

                        parm = cmdCreate.Parameters.AddWithValue(sParamName, sTempPhone);
                    }

                    else if (sParamName.Equals("@pril_TypeFruitVeg") ||
                             sParamName.Equals("@pril_ProfCode") ||
                             sParamName.Equals("@pril_OwnCode") ||
                             sParamName.Equals("@pril_TerminateCode")) {

                        string family = null;
                        switch (sParamName) {
                            case "@pril_TypeFruitVeg":
                                family = "TypeFruitVegRL";
                                break;
                            case "@pril_ProfCode":
                                family = "ProfCodeRL";
                                break;
                            case "@pril_OwnCode":
                                family = "OwnershipTypeCodeRL";
                                break;
                            case "@pril_TerminateCode":
                                family = "prpa_TerminateCodeRL";
                                break;
                        }

                        sAbbreviation = translateCustomCaption(cmdCreate, family, sParamValue);
                        parm = cmdCreate.Parameters.AddWithValue(sParamName, sAbbreviation);
                        sAbbreviation = string.Empty;
                    }

                    // Translate the state name into an abbreviation.  This is what the 
                    // import logic further downstream expects.
                    else if (sParamName.Equals("@pril_State") ||
                             sParamName.Equals("@pril_MailState") ||
                             sParamName.Equals("@prip_State") ||
                             sParamName.Equals("@prit_State") ||
                             sParamName.Equals("@pril_IncState")) {

                        sAbbreviation = translateState(cmdCreate, sParamValue);
                        parm = cmdCreate.Parameters.AddWithValue(sParamName, sAbbreviation);
                        sAbbreviation = string.Empty;
                    }

                    else if (sParamName.Equals("@prip_LastName")) {

                        string[] tokens = sParamValue.Split(' ');
                        if (tokens.Length == 1) {
                            cmdCreate.Parameters.AddWithValue(sParamName, tokens[0].Trim());
                        }

                        if (tokens.Length == 2) {
                            cmdCreate.Parameters.AddWithValue("@prip_FirstName", tokens[0].Trim());
                            cmdCreate.Parameters.AddWithValue(sParamName, tokens[1].Trim());
                        }

                        if (tokens.Length >= 3) {
                            cmdCreate.Parameters.AddWithValue("@prip_FirstName", tokens[0].Trim());

                            int tokenIndex = 1;
                            if (tokens[1].Trim().Length == 1) {
                                cmdCreate.Parameters.AddWithValue("@prip_MiddleInitial", tokens[1].Trim());
                                tokenIndex = 2;
                            }

                            string tempName = string.Empty;
                            while (tokenIndex < tokens.Length) {
                                if (tempName.Length > 0)
                                    tempName += " ";

                                tempName += tokens[tokenIndex];
                                tokenIndex++;
                            }

                            cmdCreate.Parameters.AddWithValue(sParamName, tempName);
                        }
                    }
                    else {
                        // determine the type and store the sp parameter 
                        if (iType == SqlDbType.NVarChar) //string
                            parm = cmdCreate.Parameters.AddWithValue(sParamName, sParamValue);
                        else if (iType == SqlDbType.Int) //int
                            parm = cmdCreate.Parameters.AddWithValue(sParamName, int.Parse(sParamValue));
                        else if (iType == SqlDbType.DateTime) //date
                        {
                            DateTime dtReturn = InputToDate(sParamValue);
                            // if the date is null, don't add the param; the sp
                            // will set the value to null
                            if (dtReturn != DateTime.MinValue)
                                parm = cmdCreate.Parameters.AddWithValue(sParamName, dtReturn);
                        }
                    }

                    if ((sParamName == "@pril_LicenseNumber") ||
                        (sParamName == "@prip_LicenseNumber") ||
                        (sParamName == "@prit_LicenseNumber") ||
                        (sParamName == "@pripc_LicenseNumber"))
                    {

                        if (string.IsNullOrEmpty(sParamValue))
                            return;
                        
                        if (sParamValue.StartsWith("Z"))
                            return;
                    }

                }
                catch (Exception eX) {
                    string exMsg = sParamName + "=" + sParamValue + ": " + eX.Message;
                    throw new ApplicationException(exMsg);
                }
            }
        }

        /// <summary>
        /// Helper method that converts the PACA data format
        /// into a Date/Time structure.
        /// </summary>
        /// <param name="sDate"></param>
        /// <returns></returns>
        private DateTime InputToDate(string sDate)
        {
            DateTime dtReturn = DateTime.MinValue;
            if (sDate == null || sDate.Trim().Length == 0) {
                return dtReturn;
            }

            try {
                //// these values come in the format YYYY-MM-DD
                int iYear = int.Parse(sDate.Substring(0, 4));
                int iMonth = int.Parse(sDate.Substring(5, 2));
                int iDay = int.Parse(sDate.Substring(8, 2));

                // Sanity check
                if (iYear < 1900)
                    throw new Exception("Invalid date specified: " + sDate);

                dtReturn = new DateTime(iYear, iMonth, iDay);
                return dtReturn;
            }
            catch {
                throw new Exception("Invalid date specified: " + sDate);
            }
        }

        private Dictionary<string, string> _stateCache = new Dictionary<string, string>();

        private string translateState(SqlCommand cmdCreate, string stateName)
        {
            if (string.IsNullOrEmpty(stateName))
                return null;

            // If the state is only two characters, assume
            // it is an abbreviation.
            if (stateName.Length == 2)
                return stateName;

            if (!_stateCache.ContainsKey(stateName)) {

                SqlCommand sqlCommand = new SqlCommand("SELECT prst_Abbreviation FROM PRState WHERE prst_State=@State");
                sqlCommand.Connection = cmdCreate.Connection;
                sqlCommand.Transaction = cmdCreate.Transaction;
                sqlCommand.Parameters.AddWithValue("State", stateName);

                object result = sqlCommand.ExecuteScalar();
                if ((result != DBNull.Value) && (result != null))
                    _stateCache.Add(stateName, Convert.ToString(result));
                else {

                    // See if this is a country.
                    string countryAbbr = translateCountry(cmdCreate, stateName);
                    if (countryAbbr == null)
                        throw new Exception("Unknown State/Country specified: " + stateName);
                    else
                        return countryAbbr;
                }
            }

            return _stateCache[stateName];
        }

        private Dictionary<string, string> _countryCache = new Dictionary<string, string>();
        private string translateCountry(SqlCommand cmdCreate, string countryName)
        {
            if (string.IsNullOrEmpty(countryName))
                return null;


            if (!_countryCache.ContainsKey(countryName)) {

                SqlCommand sqlCommand = new SqlCommand("SELECT prcn_IATACode FROM PRCountry WHERE prcn_Country=@Country");
                sqlCommand.Connection = cmdCreate.Connection;
                sqlCommand.Transaction = cmdCreate.Transaction;
                sqlCommand.Parameters.AddWithValue("Country", countryName);

                object result = sqlCommand.ExecuteScalar();
                if ((result != DBNull.Value) && (result != null))
                    _countryCache.Add(countryName, Convert.ToString(result));
                else
                    return null;
            }

            return _countryCache[countryName];
        }

        private Dictionary<string, string> _customCaptionCache = new Dictionary<string, string>();

        private string translateCustomCaption(SqlCommand cmdCreate, string family, string meaning)
        {
            if (string.IsNullOrEmpty(meaning))
                return null;

            string key = family + ":" + meaning;

            if (!_customCaptionCache.ContainsKey(key)) {

                SqlCommand sqlCommand = new SqlCommand("SELECT capt_code FROM Custom_Captions WHERE capt_Family=@Family AND capt_US = @Meaning");
                sqlCommand.Connection = cmdCreate.Connection;
                sqlCommand.Transaction = cmdCreate.Transaction;
                sqlCommand.Parameters.AddWithValue("Family", family);
                sqlCommand.Parameters.AddWithValue("Meaning", meaning);

                object result = sqlCommand.ExecuteScalar();
                if ((result != DBNull.Value) && (result != null))
                    _customCaptionCache.Add(key, Convert.ToString(result));
                else
                    throw new Exception("Unknown field value specified: " + family + "-" + meaning);
                
            }

            return _customCaptionCache[key];
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