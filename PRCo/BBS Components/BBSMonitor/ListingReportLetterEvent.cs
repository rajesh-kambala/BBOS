/***********************************************************************
 Copyright Blue Book Services, Inc. 2014-2023

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: ListingReportLetterEvent.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using ICSharpCode.SharpZipLib.Zip;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Threading;
using System.Timers;
using TSI.Utils;

namespace PRCo.BBS.BBSMonitor
{
    public class ListingReportLetterEvent : BBSMonitorEvent
    {
        private const string STANDARD_INDENT = "     ";
        private const string BRANCH_INDENT = "     ";
        private const string NEWLINE = "\r\n";

        private const string LISTING_REPORT_LETTER_FOLDER = "ListingReportLetterFolder";
        private const string LISTING_REPORT_LETTER_FOLDER_LOCAL = "ListingReportLetterFolderLocal";

        private string _fileDate = null;

        private string _LRLBaseCompanyDataFile, _LRLListingDataFile, _LRLPersonDataFile, _LRLControlFile;
        private string _LRLCompanyProductFile, _LRLProductMasterFile;
        private string _companyIDList = null;
        private string _fullCompanyIDList = null;
        private string _PDFFolder;
        private string _PDFFolderLocal;

        private List<Company> _invalidCompanies = new List<Company>();
        private DateTime _dtNow;

        private int _MailingPieceCount = 0;
        private int _LocationCount = 0;
        private int _PeopleCount = 0;
        private int _CompanyProductCount = 0;
        private int _ProductMasterCount = 0;
        private int _USACount = 0;
        private int _INTCount = 0;

        string _szUSAPath;
        string _szINTPath;

        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex)
        {
            _szName = "ListingReportLetterEvent";

            base.Initialize(iIndex);

            try
            {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("ListingReportLetterInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("ListingReportLetter Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("ListingReportLetterStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new System.Timers.Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("ListingReportLetter Start: " + _dtNextDateTime.ToString());

            }
            catch (Exception e)
            {
                LogEventError("Error initializing ListingReportLetter event.", e);
                throw;
            }
        }

        protected const string SQL_SELECT_LRL_CYCLE =
            @"SELECT prlrlc_LRLCycleID, prlrlc_IndustryTypeCode, prlrlc_ServiceTypeCode, prlrlc_CycleStartDate, prlrlc_CycleEndDate, prlrlc_CycleCount, prlrlc_GapStartDate, prlrlc_GapEndDate
                FROM PRLRLCycle
               WHERE GETDATE() BETWEEN prlrlc_CycleStartDate AND prlrlc_CycleEndDate
                 AND (prlrlc_GapStartDate IS NULL  
                      OR (GETDATE() NOT BETWEEN prlrlc_GapStartDate AND prlrlc_GapEndDate))";

        private bool ListingReportLetterRunOldZipStyle()
        {
            return Utilities.GetBoolConfigValue("ListingReportLetterRunOldZipStyle", true);
        }

        private bool ListingReportLetterOneLargeZipFile()
        {
            return Utilities.GetBoolConfigValue("ListingReportLetterOneLargeZipFile", true);
        }
        /// <summary>
        /// Go update the classification company counts.
        /// </summary>
        override public void ProcessEvent()
        {
            DateTime dtExecutionStartDate = DateTime.Now;
            _dtNow = DateTime.Now;

            _MailingPieceCount = 0;
            _LocationCount = 0;
            _PeopleCount = 0;
            _CompanyProductCount = 0;
            _ProductMasterCount = 0;

            _USACount = 0;
            _INTCount = 0;

            _cmdBranches = null;
            _dvCompanyProducts = null;
            _dvListingData = null;
            _dvPerson = null;
            StringBuilder sbCounts = new StringBuilder();

            try
            {
                List<LRLCycle> lrlCycles = null;

                using (SqlConnection oConn = new SqlConnection(GetConnectionString()))
                {
                    oConn.Open();

                    lrlCycles = GetLRLCycles(oConn);

                    if (lrlCycles.Count > 0)
                    {
                        InitializeFiles();

                        List<Int32> lrlCompanies = new List<Int32>();
                        List<Company> lCompanies = new List<Company>();

                        foreach (LRLCycle lrlCycle in lrlCycles)
                        {
                            lrlCompanies.AddRange(GetLRLCompanyIDs(oConn, lrlCycle));

                            // Used to regenerate data from previously crashed cycles.
                            //if (lrlCycle.LRLCycleID == 44)
                            //    lrlCompanies.AddRange(GetLRLCompaniesFromBatch(oConn, lrlCycle, 966));

                            //if (lrlCycle.LRLCycleID == 42)
                            //    lrlCompanies.AddRange(GetLRLCompaniesFromBatch(oConn, lrlCycle, 965));

                            lCompanies.AddRange(GetLRLCompanies(oConn, lrlCycle));
                        }


                        _companyIDList = string.Join(",", lrlCompanies);
                        _fullCompanyIDList = GetFullCompanyIDList(oConn, _companyIDList);


                        List<Company> lMailedCompanies = new List<Company>();
                        string _mailedCompanyIDList = "";

                        bool bMailFilesCreated = false;
                        int mailCount = 0;
                        int emailCount = 0;
                        int errorCount = 0;
                        int maxErrorCount = Utilities.GetIntConfigValue("ListingReportLetterMaxErrorCount", 10);
                        _fileDate = DateTime.Today.ToString("MM/dd/yyyy");

                        bool bBRE = Utilities.GetBoolConfigValue("ListReportLetterBRE", false);
                        bool bInsert1 = Utilities.GetBoolConfigValue("ListReportLetterInsert1", false);
                        bool bInsert2 = Utilities.GetBoolConfigValue("ListReportLetterInsert2", false);

                        SqlTransaction sqlTran = null;
                        try
                        {
                            // For each company, generate a letter and add it to
                            // the output file.
                            foreach (Company oCompany in lCompanies)
                            {
                                // This can cause deadlock issues, so we're going 
                                // skip this for now to see what happens.
                                //sqlTran = oConn.BeginTransaction();

                                if (oCompany.DeliveryType == "E")
                                {
                                    if (string.IsNullOrEmpty(oCompany.DeliveryAddress))
                                        _invalidCompanies.Add(oCompany);
                                    else
                                    {
                                        _oLogger.LogMessage($"Sending to BB# {oCompany.CompanyID} {oCompany.Name} to {oCompany.DeliveryAddress}");

                                        // Get the report outside of the database transaction because it
                                        // can take some time to generate.
                                        byte[] lrlReport = GetLRLReport(oCompany, bBRE, bInsert1, bInsert2);

                                        try
                                        {
                                            sqlTran = oConn.BeginTransaction();
                                            if (Utilities.GetBoolConfigValue("ListingReportLetterSendEmail", true))
                                                EmailLRL(oConn, sqlTran, oCompany, lrlReport);

                                            CreateInteraction(oConn, sqlTran, oCompany);
                                            UpdateCompanies(oConn, sqlTran, oCompany.CompanyID.ToString());
                                            sqlTran.Commit();
                                            emailCount++;
                                        } catch (Exception innerEx) {
                                            if (sqlTran != null)
                                                sqlTran.Rollback();

                                            errorCount++;
                                            _oLogger.LogError($"Exception emailing LRL to {oCompany.CompanyID}.  This record is skipped.", innerEx);
                                            
                                            if (errorCount >= maxErrorCount)
                                                throw new ApplicationException($"Too many exceptions sending the LRL: {errorCount}");
                                        }
                                        
                                    }
                                }
                                else
                                {
                                    bMailFilesCreated = true;
                                    ProcessCompany(oConn, sqlTran, oCompany, bBRE, bInsert1, bInsert2);
                                    lMailedCompanies.Add(oCompany);

                                    if (mailCount > 0)
                                        _mailedCompanyIDList += ",";
                                    
                                    _mailedCompanyIDList += oCompany.CompanyID.ToString();

                                    mailCount++;
                                }

                                //sqlTran.Commit();
                                sqlTran = null;
                            }

                            if (ListingReportLetterRunOldZipStyle())
                                ProcessProductMasterFile(oConn, sqlTran);

                            CreateInteractions(oConn, sqlTran, lMailedCompanies);
                            UpdateCompanies(oConn, sqlTran, _mailedCompanyIDList);

                            foreach (LRLCycle lrlCycle in lrlCycles)
                            {
                                InsertLRLBatch(oConn, sqlTran, lrlCycle);
                            }
                        }
                        catch
                        {
                            if (sqlTran != null)
                                sqlTran.Rollback();
                            throw;
                        }

                        foreach (LRLCycle lrlCycle in lrlCycles)
                        {
                            sbCounts.Append(lrlCycle.GetBatchName() + Environment.NewLine);
                            sbCounts.Append("   Company Count: " + lrlCycle.CompanyCount.ToString("###,##0") + Environment.NewLine);
                            sbCounts.Append("    Member Count: " + lrlCycle.MemberCount.ToString("###,##0") + Environment.NewLine);
                            sbCounts.Append(" NonMember Count: " + lrlCycle.NonMemberCount.ToString("###,##0") + Environment.NewLine);
                            sbCounts.Append("Total Sent Count: " + lrlCycle.TotalSentCount.ToString("###,##0") + Environment.NewLine);
                            sbCounts.Append(" Remaining Count: " + lrlCycle.RemainingCount.ToString("###,##0") + Environment.NewLine);
                            sbCounts.Append(" Exception Count: " + _invalidCompanies.Count.ToString("###,##0") + Environment.NewLine);
                            sbCounts.Append("     Error Count: " + errorCount.ToString("###,##0") + Environment.NewLine);
                            sbCounts.Append(Environment.NewLine);
                        }

                        if (_invalidCompanies.Count > 0)
                        {
                            sbCounts.Append(Environment.NewLine);
                            sbCounts.Append("Invalid Companies Found" + Environment.NewLine);
                            sbCounts.Append("=======================" + Environment.NewLine);
                            foreach (Company company in _invalidCompanies)
                            {
                                sbCounts.Append("BB #" + company.CompanyID.ToString() + " " + company.Name + Environment.NewLine);
                            }
                        }

                        // Only package up the output mail house files
                        // if we actually process companies for LRL mailings.
                        if (bMailFilesCreated)
                        {
                            GenerateControlCountFile();

                            if (ListingReportLetterRunOldZipStyle())
                            {
                                string ftpFileName = CompressFiles(lCompanies);
                                UploadFile(ftpFileName);
                                GenerateEmail(oConn, Path.GetFileName(ftpFileName), sbCounts.ToString());
                            }
                            else
                            {
                                if (ListingReportLetterOneLargeZipFile())
                                {
                                    string szOneLargeZipFile = CompressOneLargeZipFile(_LRLControlFile, _szUSAPath, _szINTPath);
                                    UploadFile(szOneLargeZipFile);
                                    GenerateEmail(oConn, Path.GetFileName(szOneLargeZipFile), sbCounts.ToString());
                                }
                                else
                                {
                                    UploadFile(_LRLControlFile);
                                    UploadFolder(_szUSAPath);
                                    UploadFolder(_szINTPath);
                                    GenerateEmail(oConn, Path.GetFileName(_LRLControlFile), sbCounts.ToString());
                                }
                            }

                            CleanupFiles();
                        }
                    }


                    if (!string.IsNullOrEmpty(Utilities.GetConfigValue("ListingReportLetterBBSIEmailAddress", string.Empty)))
                    {
                        StringBuilder sbEmail = new StringBuilder(string.Format("Found {0} LRL Cycles.", lrlCycles.Count) + Environment.NewLine);
                        sbEmail.Append(sbCounts.ToString());

                        SqlCommand cmdCreateEmail = new SqlCommand("usp_CreateEmail", oConn);
                        cmdCreateEmail = new SqlCommand("usp_CreateEmail", oConn);
                        cmdCreateEmail.CommandType = CommandType.StoredProcedure;
                        cmdCreateEmail.Parameters.AddWithValue("To", Utilities.GetConfigValue("ListingReportLetterBBSIEmailAddress"));
                        cmdCreateEmail.Parameters.AddWithValue("Subject", Utilities.GetConfigValue("ListingReportLetterBBSIEmailSubject", "BBS LRL Files"));
                        cmdCreateEmail.Parameters.AddWithValue("Content", sbEmail.ToString());
                        cmdCreateEmail.Parameters.AddWithValue("DoNotRecordCommunication", 1);
                        cmdCreateEmail.Parameters.AddWithValue("Action", "EmailOut");
                        cmdCreateEmail.ExecuteNonQuery();
                    }
                }

                TimeSpan tsDiff = DateTime.Now.Subtract(dtExecutionStartDate);
                StringBuilder sbMsg = new StringBuilder(string.Format("Found {0} LRL Cycles.", lrlCycles.Count) + Environment.NewLine);
                sbMsg.Append("Execution time: " + tsDiff.ToString() + Environment.NewLine + Environment.NewLine);
                sbMsg.Append(sbCounts.ToString());



                if (Utilities.GetBoolConfigValue("ListingReportLetterWriteResultsToEventLog", true))
                    _oBBSMonitorService.LogEvent(sbMsg.ToString());

                if (Utilities.GetBoolConfigValue("ListingReportLetterSendResultsToSupport", false))
                    SendMail("LRL Reports Success", sbMsg.ToString());
            }
            catch (Exception e)
            {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error Procesing ListingReportLetter Event.", e);
            }
        }

        private string CompressOneLargeZipFile(string lrlControlFile, string pathUSA, string pathInt)
        {
            string zipName = Path.Combine(Utilities.GetConfigValue(LISTING_REPORT_LETTER_FOLDER),
                                                     Utilities.GetConfigValue("ListingReportLetterFolderCompressFile", string.Format("BBSI LRL Data {0}.zip", DateTime.Now.ToString("yyyyMMdd_HHmm"))));

            using (ZipOutputStream zipOutputStream = new ZipOutputStream(File.Create(zipName)))
            {
                zipOutputStream.SetLevel(9); // 0-9, 9 being the highest compression
                zipOutputStream.Password = Utilities.GetConfigValue("ListingReportLetterZipPassword", "P@ssword1");

                addZipEntry(zipOutputStream, Utilities.GetConfigValue(LISTING_REPORT_LETTER_FOLDER), lrlControlFile, "Control.txt");

                DirectoryInfo di = new DirectoryInfo(pathUSA);
                foreach (FileInfo file in di.EnumerateFiles())
                {
                    addZipEntry(zipOutputStream, pathUSA, file.FullName, $"{file.Name}");
                }

                di = new DirectoryInfo(pathInt);
                foreach (FileInfo file in di.EnumerateFiles())
                {
                    addZipEntry(zipOutputStream, pathInt, file.FullName, $"{file.Name}");
                }

                zipOutputStream.Finish();
                zipOutputStream.IsStreamOwner = true;
                zipOutputStream.Close();
            }

            return zipName;
        }

        private void UploadFile(string ftpFileName)
        {
            // Check to see if FTP is enabled.  It may be disabled 
            // for testing, etc.
            if (!Utilities.GetBoolConfigValue("ListingReportLetterProcessFTP", true))
                return;


            // FTP vs. SFTP
            if (Utilities.GetBoolConfigValue("ListingReportLetterUseFTP", true))
            {
                UploadFile(Utilities.GetConfigValue("ListingReportLetterFTPServer", "ftp://ftp.bluebookservices.com"),
                           Utilities.GetConfigValue("ListingReportLetterFTPUsername", "qa"),
                           Utilities.GetConfigValue("ListingReportLetterFTPPassword", "qA$1901"),
                           ftpFileName);
            }
            else
            {
                UploadFileSFTP(Utilities.GetConfigValue("ListingReportLetterFTPServer", "ftp://ftp.bluebookservices.com"),
                               Utilities.GetIntConfigValue("ListingReportLetterFTPPort", 22),
                               Utilities.GetConfigValue("ListingReportLetterFTPUsername", "qa"),
                               Utilities.GetConfigValue("ListingReportLetterFTPPassword", "qA$1901"),
                               ftpFileName,
                               Path.GetFileName(ftpFileName));
            }
        }

        private void UploadFolder(string path)
        {
            DirectoryInfo di = new DirectoryInfo(path);
            foreach (FileInfo file in di.EnumerateFiles())
            {
                UploadFile(file.FullName);
                Thread.Sleep(Utilities.GetIntConfigValue("ListReportLetterFTPSleep", 250));
            }
        }


        protected List<Int32> GetLRLCompanyIDs(SqlConnection sqlConn, LRLCycle lrlCycle)
        {
            List<Int32> lrlCompanies = new List<Int32>();

            SqlCommand sqlLRLCycle = new SqlCommand();
            sqlLRLCycle.Connection = sqlConn;
            sqlLRLCycle.CommandText = "usp_GetLRLCompanies";
            sqlLRLCycle.CommandType = CommandType.StoredProcedure;
            sqlLRLCycle.CommandTimeout = Utilities.GetIntConfigValue("ListingReportLetterCommandTimeout", 150);
            sqlLRLCycle.Parameters.AddWithValue("CycleStartDate", lrlCycle.StartDate);
            sqlLRLCycle.Parameters.AddWithValue("TotalCycles", lrlCycle.CycleCount);
            sqlLRLCycle.Parameters.AddWithValue("IndustryType", lrlCycle.IndustryTypeCode);
            sqlLRLCycle.Parameters.AddWithValue("ServiceType", lrlCycle.ServiceTypeCode);

            int iMaxCompanyCount = Utilities.GetIntConfigValue("ListingReportLetterMaxCompanyCount", 999999999);

            using (IDataReader dataReader = sqlLRLCycle.ExecuteReader())
            {
                while (dataReader.Read())
                {
                    if (lrlCompanies.Count <= iMaxCompanyCount)
                        lrlCompanies.Add(dataReader.GetInt32(0));
                }
            }

            lrlCycle.CompanyCount = lrlCompanies.Count;
            lrlCycle.CompanyIDs = string.Join(",", lrlCompanies);

            return lrlCompanies;
        }

        private const string SQL_GET_COMPANIES_FROM_BATCH =
            @"SELECT value
                  FROM PRLRLBatch
                       CROSS APPLY dbo.Tokenize(prlrlb_Criteria, ',')
                WHERE prlrlb_LRLBatchID = @BatchID";
        protected List<Int32> GetLRLCompaniesFromBatch(SqlConnection sqlConn, LRLCycle lrlCycle, int batchID)
        {
            List<Int32> lrlCompanies = new List<Int32>();

            SqlCommand sqlLRLCycle = new SqlCommand();
            sqlLRLCycle.Connection = sqlConn;
            sqlLRLCycle.CommandText = SQL_GET_COMPANIES_FROM_BATCH;
            sqlLRLCycle.CommandTimeout = Utilities.GetIntConfigValue("ListingReportLetterCommandTimeout", 150);
            sqlLRLCycle.Parameters.AddWithValue("BatchID", batchID);

            using (IDataReader dataReader = sqlLRLCycle.ExecuteReader())
            {
                while (dataReader.Read())
                {
                    lrlCompanies.Add(Convert.ToInt32(dataReader[0]));
                }
            }

            lrlCycle.CompanyCount = lrlCompanies.Count;
            lrlCycle.CompanyIDs = string.Join(",", lrlCompanies);

            return lrlCompanies;
        }

        private const string SQL_SELECT_COMPANIES =
              @"SELECT DISTINCT comp_CompanyID, comp_PRType, CASE WHEN prattn_EmailID IS NULL THEN 'M' ELSE 'E' END As DeliveryType, Addressee, DeliveryAddress, comp_Name, ServiceType,
                       [Order] = RANK() OVER (PARTITION BY comp_PRHQID ORDER BY comp_PRType Desc, comp_PRIndustryType asc, prcn_Country asc , prst_State asc, prci_City asc, comp_Name asc, comp_CompanyId asc),
                        prst_CountryId
                  FROM Company WITH (NOLOCK) 
                       INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID 
                       LEFT OUTER JOIN vPRCompanyAttentionLine WITH (NOLOCK) ON comp_CompanyID = prattn_CompanyID AND prattn_ItemCode = 'LRL'
                       LEFT OUTER JOIN vPRPrimaryMembers WITH (NOLOCK) ON comp_CompanyID = CompanyID
                 WHERE comp_PRType = 'H' 
                   AND comp_CompanyID IN ({0})
              ORDER BY comp_CompanyID, [Order]";

        protected List<Company> GetLRLCompanies(SqlConnection sqlConn, LRLCycle lrlCycle)
        {
            List<Company> lCompanies = new List<Company>();
            int iMaxCompanyCount = Utilities.GetIntConfigValue("ListingReportLetterMaxCompanyCount", 999999999);

            if (string.IsNullOrEmpty(lrlCycle.CompanyIDs))
                return lCompanies;

            string szSQL = string.Format(SQL_SELECT_COMPANIES, lrlCycle.CompanyIDs);
            SqlCommand sqlCompanies = new SqlCommand(szSQL, sqlConn);
            sqlCompanies.CommandTimeout = Utilities.GetIntConfigValue("ListingReportLetterCommandTimeout", 150); 
            using (IDataReader drCompanies = sqlCompanies.ExecuteReader(CommandBehavior.Default))
            {
                while (drCompanies.Read())
                {
                    Company oCompany = new Company();
                    oCompany.CompanyID = drCompanies.GetInt32(0);
                    oCompany.Type = drCompanies.GetString(1);
                    oCompany.DeliveryType = drCompanies.GetString(2);
                    if (oCompany.DeliveryType == "E")
                    {
                        if (drCompanies[3] != DBNull.Value)
                            oCompany.Addressee = drCompanies.GetString(3);

                        oCompany.DeliveryAddress = drCompanies.GetString(4);
                    }

                    oCompany.Name = drCompanies.GetString(5);

                    if (drCompanies[6] != DBNull.Value)
                    {
                        oCompany.IsMember = true;
                        lrlCycle.MemberCount++;
                    }
                    else
                    {
                        lrlCycle.NonMemberCount++;
                    }

                    oCompany.Order = drCompanies.GetInt64(7);
                    oCompany.Country = drCompanies.GetInt32(8); //CountryId

                    lCompanies.Add(oCompany);

                    if (lCompanies.Count >= iMaxCompanyCount)
                        break;
                }
            }

            return lCompanies;
        }

        protected List<LRLCycle> GetLRLCycles(SqlConnection sqlConn)
        {
            List<LRLCycle> lrlCycles = new List<LRLCycle>();

            SqlCommand sqlLRLCycle = new SqlCommand(SQL_SELECT_LRL_CYCLE, sqlConn);
            using (IDataReader dataReader = sqlLRLCycle.ExecuteReader())
            {
                while (dataReader.Read())
                {
                    LRLCycle lrlCycle = new LRLCycle();
                    lrlCycle.LRLCycleID = dataReader.GetInt32(0);
                    lrlCycle.IndustryTypeCode = dataReader.GetString(1);
                    lrlCycle.ServiceTypeCode = dataReader.GetString(2);
                    lrlCycle.StartDate = dataReader.GetDateTime(3);
                    lrlCycle.EndDate = dataReader.GetDateTime(4);
                    lrlCycle.CycleCount = dataReader.GetInt32(5);

                    if (dataReader[6] != DBNull.Value)
                    {
                        lrlCycle.GapStartDate = dataReader.GetDateTime(6);
                        lrlCycle.GapEndDate = dataReader.GetDateTime(7);
                    }

                    lrlCycles.Add(lrlCycle);
                }
            }

            return lrlCycles;
        }

        private const string SQL_SELECT_BRANCHES =
               @"SELECT comp_CompanyID, comp_PRType
                   FROM Company WITH (NOLOCK) 
                        INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
                  WHERE comp_PRType = 'B' 
                    AND comp_PRListingStatus IN ('L', 'H', 'LUV') 
                    AND comp_PRHQID = @HQID 
               ORDER BY prcn_Country, prst_State, prci_City, comp_PRBookTradeStyle";

        private SqlCommand _cmdBranches = null;
        /// <summary>
        /// Helper method that retrieves the branches for the specified
        /// company.
        /// </summary>
        /// <param name="sqlConn"></param>
        /// <param name="sqlTran"></param>
        /// <param name="oCompany"></param>
        /// <returns></returns>
        private List<Company> GetBranches(SqlConnection sqlConn, SqlTransaction sqlTran, Company oCompany)
        {
            List<Company> lBranches = new List<Company>();

            //if (_cmdBranches == null)
            //{
            _cmdBranches = new SqlCommand(SQL_SELECT_BRANCHES, sqlConn, sqlTran);
            //}
            _cmdBranches.Parameters.Clear();
            _cmdBranches.Parameters.AddWithValue("HQID", oCompany.CompanyID);

            using (IDataReader drBranches = _cmdBranches.ExecuteReader(CommandBehavior.Default))
            {
                while (drBranches.Read())
                {
                    Company oBranch = new Company();
                    oBranch.CompanyID = drBranches.GetInt32(0);
                    oBranch.Type = drBranches.GetString(1);
                    lBranches.Add(oBranch);
                }
            }

            return lBranches;
        }

        private void ProcessCompany(SqlConnection sqlConn, SqlTransaction sqlTran, Company company, bool bBRE, bool bInsert1, bool bInsert2)
        {
            if (ListingReportLetterRunOldZipStyle())
            {
                ProcessBaseCompanyData(sqlConn, sqlTran, company);
                ProcessListingData(sqlConn, sqlTran, company);
                ProcessPersonsData(sqlConn, sqlTran, company);
                ProcessCompanyProduct(sqlConn, sqlTran, company);

                if (company.Type == "H")
                {
                    _MailingPieceCount++;

                    List<Company> branches = GetBranches(sqlConn, sqlTran, company);
                    int i = 1;

                    foreach (Company branch in branches)
                    {
                        i++;
                        branch.Order = i;
                        ProcessCompany(sqlConn, sqlTran, branch, bBRE, bInsert1, bInsert2);
                    }
                }
            }
            else
            {
                CreateLRLFile(sqlConn, sqlTran, company, bBRE, bInsert1, bInsert2);
            }
        }

        protected void CreateLRLFile(SqlConnection sqlConn, SqlTransaction sqlTran, Company company, bool bBRE, bool bInsert1, bool bInsert2)
        {
            if (oRI == null)
                oRI = new ReportInterface();

            byte[] abReport = oRI.GenerateListingReportLetter(company.CompanyID, bBRE, bInsert1, bInsert2);

            const string LISTING_REPORT_LETTER_MAIL_FILENAME = "LRL_{0}_{1}.pdf";

            string lrlFileName;
            string szFullName;

            if (company.Country == 1)
            {
                lrlFileName = string.Format(LISTING_REPORT_LETTER_MAIL_FILENAME, "USA", company.CompanyID);
                szFullName = Path.Combine(_szUSAPath, lrlFileName);
                _USACount++;
            }
            else if (company.Country > 1)
            {
                lrlFileName = string.Format(LISTING_REPORT_LETTER_MAIL_FILENAME, "INT", company.CompanyID);
                szFullName = Path.Combine(_szINTPath, lrlFileName);
                _INTCount++;
            } else {
                _oLogger.LogMessage($"Invalid record found: BB# {company.CompanyID} {company.Name}.");
                _oLogger.LogError(new ApplicationException($"Invalid record found: BB# {company.CompanyID} {company.Name}."));
                return;
            }

            _oLogger.LogMessage($"Saving to BB# {company.CompanyID} {company.Name} to {lrlFileName}");
            using (FileStream oFStream = File.Create(szFullName, abReport.Length))
            {
                oFStream.Write(abReport, 0, abReport.Length);
            }
        }

        private void ProcessBaseCompanyData(SqlConnection sqlConn, SqlTransaction sqlTran, Company company)
        {
            //Get base company data.
            string szSQL = string.Format("SELECT * FROM vLRLCompany WHERE BBID={0}", company.CompanyID);
            //WriteToLog(company.CompanyID, szSQL);

            SqlCommand sqlBaseData = new SqlCommand(szSQL, sqlConn, sqlTran);
            sqlBaseData.CommandTimeout = 60 * 60;

            //Insert a line in the base company data file.
            using (IDataReader drBaseData = sqlBaseData.ExecuteReader(CommandBehavior.Default))
            {
                while (drBaseData.Read())
                {

                    string logo = string.Empty;
                    if (!string.IsNullOrEmpty(GetString(drBaseData["PublishLogo"])))
                    {
                        company.Logo = GetString(drBaseData["Logo"]);
                        logo = GetLogoPathForExport(GetString(drBaseData["Logo"]));
                    }

                    StringBuilder text = new StringBuilder();
                    AddValueToBuffer(text, GetInt(drBaseData["BBID"]));
                    AddValueToBuffer(text, GetInt(drBaseData["HQID"]));
                    AddValueToBuffer(text, GetString(drBaseData["Company Name"]));
                    AddValueToBuffer(text, GetString(drBaseData["Type"]));
                    AddValueToBuffer(text, GetString(drBaseData["Listing City"]));
                    AddValueToBuffer(text, GetString(drBaseData["Listing State"]));
                    AddValueToBuffer(text, GetString(drBaseData["Listing Country"]));
                    AddValueToBuffer(text, company.Order);
                    AddValueToBuffer(text, GetString(drBaseData["Industry"]));
                    AddValueToBuffer(text, GetString(drBaseData["CL Message"]));
                    AddValueToBuffer(text, GetString(drBaseData["Last CL Date"]));
                    AddValueToBuffer(text, GetString(drBaseData["Volume Message"]));
                    AddValueToBuffer(text, logo);
                    AddValueToBuffer(text, GetString(drBaseData["Has DL"]));
                    AddValueToBuffer(text, GetString(drBaseData["Attention Line"]));
                    AddValueToBuffer(text, GetString(drBaseData["Address 1"]));
                    AddValueToBuffer(text, GetString(drBaseData["Address 2"]));
                    AddValueToBuffer(text, GetString(drBaseData["Address 3"]));
                    AddValueToBuffer(text, GetString(drBaseData["Address 4"]));
                    AddValueToBuffer(text, GetString(drBaseData["Mailing City"]));
                    AddValueToBuffer(text, GetString(drBaseData["Mailing State"]));
                    AddValueToBuffer(text, GetString(drBaseData["Mailing Country"]));
                    AddValueToBuffer(text, GetString(drBaseData["Mailing Zip"]));
                    AddValueToBuffer(text, _fileDate);
                    AddValueToBuffer(text, GetString(drBaseData["Member"]));
                    AddValueToBuffer(text, GetString(drBaseData["Marketing Message"]));

                    string email = string.Empty;
                    string title = null;
                    string addressee = null;

                    //  1. If TES-M enabled and TES-E disabled, then: list TES-M attn line on LRL and leave Email field blank. 
                    // [Goal: have them add an email on LRL, which we would then add to TES-E and disable TES-M]
                    if ((drBaseData["TESM_Disabled"] == DBNull.Value) &&
                        (drBaseData["TESE_Disabled"] != DBNull.Value))
                    {
                        title = GetString(drBaseData["TESM_Title"]);
                        addressee = GetString(drBaseData["TESM_Addressee"]);
                    }

                    // 2. If TES-M disabled and TES-E enabled with email, then: list TES-E attn line on LRL and pull in email from 
                    // TES-E attn line. [Goal: Validate that TES-E attn line remains correct]
                    // 3. If TES-M disabled and TES-E enabled with Fax, then: list TES-E attn line on LRL and and leave Email field blank. 
                    // [Goal: have them add an email on LRL, which we would then update TES-E so TES is delivered by Email, not Fax]
                    if ((drBaseData["TESM_Disabled"] != DBNull.Value) &&
                        (drBaseData["TESE_Disabled"] == DBNull.Value))
                    {
                        email = GetString(drBaseData["TESE_Email"]);
                        title = GetString(drBaseData["TESE_Title"]);
                        addressee = GetString(drBaseData["TESE_Addressee"]);
                    }

                    // 4. If TES-M enabled and TES-E enabled, then: list TES-M attn line on LRL and leave Email field blank. 
                    //[Goal: have them add an email on LRL, which we would then add to TES-E and disable TES-M]
                    if ((drBaseData["TESM_Disabled"] == DBNull.Value) &&
                        (drBaseData["TESE_Disabled"] == DBNull.Value))
                    {
                        title = GetString(drBaseData["TESM_Title"]);
                        addressee = GetString(drBaseData["TESM_Addressee"]);
                    }

                    AddValueToBuffer(text, email);
                    AddValueToBuffer(text, title);
                    AddValueToBuffer(text, addressee);

                    text.Append(NEWLINE);

                    WriteToFile(_LRLBaseCompanyDataFile, text.ToString());
                    _LocationCount++;
                }
            }
        }

        private const string SQL_SELECT_LISTING_DATA =
               @"SELECT comp_CompanyID as BBID, 
                        dbo.ufn_GetListingFromCompany2(comp_CompanyID, 4, 1, 1) as Listing 
                   FROM Company WITH (NOLOCK)
                  WHERE comp_CompanyID IN ({0})
               ORDER BY comp_CompanyID";

        private DataView _dvListingData = null;
        private void ProcessListingData(SqlConnection sqlConn, SqlTransaction sqlTran, Company company)
        {
            if (_dvListingData == null)
            {
                string sql = string.Format(SQL_SELECT_LISTING_DATA, _fullCompanyIDList);
                _dvListingData = GetDataView(sqlConn, sqlTran, sql);
                _dvListingData.Sort = "BBID";
            }

            _dvListingData.RowFilter = "BBID =" + company.CompanyID.ToString();
            foreach (DataRow drListingData in _dvListingData.ToTable().Rows)
            {
                StringBuilder text = new StringBuilder();
                AddValueToBuffer(text, _fileDate);
                AddValueToBuffer(text, GetInt(drListingData["BBID"]));
                AddValueToBuffer(text, GetString(drListingData["Listing"]));
                text.Append(NEWLINE);
                WriteToFile(_LRLListingDataFile, text.ToString());
            }
        }
        private const string SQL_SELECT_PERSONS =
           @"SELECT [PersonID] = peli_PersonID, 
                   [BBID] = peli_CompanyID,  
                   [Formatted Name] = dbo.ufn_FormatPersonByID (peli_PersonID),  
                   [First Name] = rtrim(pers_FirstName),  
                   [Last Name] = rtrim(pers_LastName),  
                   [Title] = peli_PRTitle,  
                   [Start Date] = peli_PRStartDate,  
                   [E-Mail Address] = rtrim(emai_EmailAddress),  
                   [Pub in BBOS] = peli_PREBBPublish,  
                   peli_PRPctOwned,  
                   HasLicense,
                   [Order] = RANK() OVER (PARTITION BY peli_CompanyID ORDER BY capt_Order, pers_FullName asc)  
              FROM vPRPersonnelListing  
                   LEFT OUTER JOIN Custom_Captions on capt_Code = peli_PRTitleCode  
                                                AND capt_Family = 'pers_TitleCode' 
                                                AND capt_FamilyType = 'Choices'  
             WHERE peli_PRStatus in (1,2) 
               AND peli_CompanyID IN ({0})
          ORDER BY peli_CompanyID, [Order]";

        private DataView _dvPerson = null;
        private void ProcessPersonsData(SqlConnection sqlConn, SqlTransaction sqlTran, Company company)
        {
            if (_dvPerson == null)
            {
                string sql = string.Format(SQL_SELECT_PERSONS, _fullCompanyIDList);
                _dvPerson = GetDataView(sqlConn, sqlTran, sql);
                _dvPerson.Sort = "BBID, [Order]";
            }

            _dvPerson.RowFilter = "BBID =" + company.CompanyID.ToString();
            foreach (DataRow drPersonData in _dvPerson.ToTable().Rows)
            {
                StringBuilder text = new StringBuilder();

                AddValueToBuffer(text, GetInt(drPersonData["PersonID"]));
                AddValueToBuffer(text, GetInt(drPersonData["BBID"]));
                AddValueToBuffer(text, GetString(drPersonData["Formatted Name"]));
                AddValueToBuffer(text, GetString(drPersonData["First Name"]));
                AddValueToBuffer(text, GetString(drPersonData["Last Name"]));
                AddValueToBuffer(text, GetString(drPersonData["Title"]));
                AddValueToBuffer(text, GetString(drPersonData["Start Date"]));
                AddValueToBuffer(text, GetString(drPersonData["E-Mail Address"]));
                AddValueToBuffer(text, GetString(drPersonData["Pub in BBOS"]));
                AddValueToBuffer(text, GetInt(drPersonData["Order"]));
                AddValueToBuffer(text, _fileDate);
                AddValueToBuffer(text, GetPercentValue(drPersonData["peli_PRPctOwned"]));

                if (Utilities.GetBoolConfigValue("ListingReportLetterHasLicenseEnabled", true))
                {
                    text.Append("\t");
                    // We want to send a blank instead of "N"
                    if (GetString(drPersonData["HasLicense"]) == "Y")
                        text.Append("Y");
                }

                text.Append(NEWLINE);

                WriteToFile(_LRLPersonDataFile, text.ToString());

                _PeopleCount++;
            }
        }

        private const string SQL_SELECT_COMPANY_PRODUCTS =
                   @"SELECT prcprpr_CompanyID [BBID], 
                            prcprpr_ProductProvidedID [ProductID]
                       FROM PRCompanyProductProvided WITH (NOLOCK)
                      WHERE prcprpr_CompanyID IN ({0})
                        AND prcprpr_ProductProvidedID > 0
                   ORDER BY prcprpr_CompanyID, prcprpr_ProductProvidedID";
        private DataView _dvCompanyProducts = null;

        private void ProcessCompanyProduct(SqlConnection sqlConn, SqlTransaction sqlTran, Company company)
        {
            if (_dvCompanyProducts == null)
            {
                string sql = string.Format(SQL_SELECT_COMPANY_PRODUCTS, _fullCompanyIDList);
                _dvCompanyProducts = GetDataView(sqlConn, sqlTran, sql);
                _dvCompanyProducts.Sort = "BBID, ProductID";
            }

            _dvCompanyProducts.RowFilter = "BBID =" + company.CompanyID.ToString();
            foreach (DataRow drRow in _dvCompanyProducts.ToTable().Rows)
            {
                StringBuilder text = new StringBuilder();

                AddValueToBuffer(text, GetInt(drRow["BBID"]));
                AddValueToBuffer(text, GetInt(drRow["ProductID"]));
                text.Append(NEWLINE);

                WriteToFile(_LRLCompanyProductFile, text.ToString());
                _CompanyProductCount++;

            }
        }

        private const string SQL_SELECT_PRODUCTS =
                   @"SELECT prprpr_ProductProvidedID [ProductID], 
                            prprpr_Name  [Product Name], 
                         prprpr_DisplayOrder [Display Order]
                       FROM PRProductProvided WITH (NOLOCK)
                   ORDER BY prprpr_DisplayOrder";

        private void ProcessProductMasterFile(SqlConnection sqlConn, SqlTransaction sqlTran)
        {
            SqlCommand sqlProduct = new SqlCommand(SQL_SELECT_PRODUCTS, sqlConn, sqlTran);
            sqlProduct.CommandTimeout = 60 * 60;

            //Insert a line in the persons data file.
            using (IDataReader drProductData = sqlProduct.ExecuteReader(CommandBehavior.Default))
            {
                while (drProductData.Read())
                {
                    StringBuilder text = new StringBuilder();

                    AddValueToBuffer(text, GetInt(drProductData["ProductID"]));
                    AddValueToBuffer(text, GetString(drProductData["Product Name"]));
                    AddValueToBuffer(text, GetInt(drProductData["Display Order"]));
                    text.Append(NEWLINE);

                    WriteToFile(_LRLProductMasterFile, text.ToString());
                    _ProductMasterCount++;
                }
            }
        }

        private DataView GetDataView(SqlConnection sqlConn, SqlTransaction sqlTran, string sql)
        {
            SqlCommand sqlCommand = new SqlCommand(sql, sqlConn, sqlTran);
            SqlDataAdapter sqlAdapter = new SqlDataAdapter(sqlCommand);
            DataSet ds = new DataSet();
            sqlAdapter.Fill(ds);

            return new DataView(ds.Tables[0]);
        }

        protected void WriteBaseCompanyDataHeader()
        {
            StringBuilder text = new StringBuilder();

            AddValueToBuffer(text, "BBID");
            AddValueToBuffer(text, "HQID");
            AddValueToBuffer(text, "Company Name");
            AddValueToBuffer(text, "Type");
            AddValueToBuffer(text, "Listing City");
            AddValueToBuffer(text, "Listing State");
            AddValueToBuffer(text, "Listing Country");
            AddValueToBuffer(text, "Order");
            AddValueToBuffer(text, "Industry");
            AddValueToBuffer(text, "CL Message");
            AddValueToBuffer(text, "Last CL Date");
            AddValueToBuffer(text, "Volume Message");
            AddValueToBuffer(text, "Logo");
            AddValueToBuffer(text, "Has DL");
            AddValueToBuffer(text, "Attention Line");
            AddValueToBuffer(text, "Address 1");
            AddValueToBuffer(text, "Address 2");
            AddValueToBuffer(text, "Address 3");
            AddValueToBuffer(text, "Address 4");
            AddValueToBuffer(text, "Mailing City");
            AddValueToBuffer(text, "Mailing State");
            AddValueToBuffer(text, "Mailing Country");
            AddValueToBuffer(text, "Mailing Zip");
            AddValueToBuffer(text, "File Date");
            AddValueToBuffer(text, "Member");
            AddValueToBuffer(text, "Marketing Message");
            AddValueToBuffer(text, "Email");
            AddValueToBuffer(text, "Title");
            AddValueToBuffer(text, "Attention");
            text.Append(NEWLINE);

            WriteToFile(_LRLBaseCompanyDataFile, text.ToString());
        }

        protected void WritePersonDataFileHeader()
        {
            StringBuilder text = new StringBuilder();
            AddValueToBuffer(text, "PersonID");
            AddValueToBuffer(text, "BBID");
            AddValueToBuffer(text, "Formatted Name");
            AddValueToBuffer(text, "First Name");
            AddValueToBuffer(text, "Last Name");
            AddValueToBuffer(text, "Title");
            AddValueToBuffer(text, "Start Date");
            AddValueToBuffer(text, "E-Mail Address");
            AddValueToBuffer(text, "Pub in BBOS");
            AddValueToBuffer(text, "Order");
            AddValueToBuffer(text, "File Date");
            AddValueToBuffer(text, "Ownership Percent");
            if (Utilities.GetBoolConfigValue("ListingReportLettertHasLicenseEnabled", true))
                AddValueToBuffer(text, "Has License");
            text.Append(NEWLINE);

            WriteToFile(_LRLPersonDataFile, text.ToString());
        }

        protected void WriteCompanyProductDataFileHeader()
        {
            StringBuilder text = new StringBuilder();

            AddValueToBuffer(text, "BBID");
            AddValueToBuffer(text, "ProductID");
            text.Append(NEWLINE);

            WriteToFile(_LRLCompanyProductFile, text.ToString());
        }

        protected void WriteProductMasterDataFileHeader()
        {
            StringBuilder text = new StringBuilder();

            AddValueToBuffer(text, "ProductID");
            AddValueToBuffer(text, "Product Name");
            AddValueToBuffer(text, "Display Order");
            text.Append(NEWLINE);

            WriteToFile(_LRLProductMasterFile, text.ToString());
        }

        protected void WriteListingDataFileHeader()
        {
            StringBuilder text = new StringBuilder();

            AddValueToBuffer(text, "File Date");
            AddValueToBuffer(text, "BBID");
            AddValueToBuffer(text, "Listing");
            text.Append(NEWLINE);

            WriteToFile(_LRLListingDataFile, text.ToString());
        }

        protected string GetLogoPathForExport(string logo)
        {
            if (!string.IsNullOrEmpty(logo))
                return @"logos\" + logo.Substring(logo.IndexOf(@"\") + 1);

            return logo;
        }

        /// <summary>
        /// Helper function that writes the specified text to the
        /// specified file
        /// </summary>
        /// <param name="szFileName"></param>
        /// <param name="szContent"></param>
        private void WriteToFile(string szFileName, string szContent)
        {
            File.AppendAllText(szFileName, szContent);
        }

        private void AddValueToBuffer(StringBuilder buffer, object value)
        {
            if (buffer.Length > 0)
                buffer.Append("\t");
            buffer.Append(value);
        }

        private void InitializeFiles()
        {
            if (ListingReportLetterRunOldZipStyle())
            {
                _LRLBaseCompanyDataFile = ResetFile(Utilities.GetConfigValue("ListingReportLetterCompanyFile", "Base_Company_Data.txt"));
                WriteBaseCompanyDataHeader();

                _LRLListingDataFile = ResetFile(Utilities.GetConfigValue("ListingReportLetterListingFile", "LRL_Listing_Data.txt"));
                WriteListingDataFileHeader();

                _LRLPersonDataFile = ResetFile(Utilities.GetConfigValue("ListingReportLetterPersonFile", "LRL_Person_Data.txt"));
                WritePersonDataFileHeader();

                _LRLCompanyProductFile = ResetFile(Utilities.GetConfigValue("ListingReportLetterCompanyProductFile", "LRL_Company_Product_Data.txt"));
                WriteCompanyProductDataFileHeader();

                _LRLProductMasterFile = ResetFile(Utilities.GetConfigValue("ListingReportLetterProductMasterFile", "LRL_Product_Master_Data.txt"));
                WriteProductMasterDataFileHeader();
            }
            else
            {
                //Defect 4419 - PDF batch instead of data files -- store PDF files locally instead of on network drive
                DateTime dtFolderDate = DateTime.Now;
                _PDFFolder = Path.Combine(Utilities.GetConfigValue(LISTING_REPORT_LETTER_FOLDER), string.Format("BBSI LRL PDF {0}", dtFolderDate.ToString("yyyyMMdd_HHmm")));
                _PDFFolderLocal = Path.Combine(Utilities.GetConfigValue(LISTING_REPORT_LETTER_FOLDER_LOCAL), string.Format("BBSI LRL PDF {0}", dtFolderDate.ToString("yyyyMMdd_HHmm")));
                _szUSAPath = Path.Combine(_PDFFolderLocal, "USA");
                _szINTPath = Path.Combine(_PDFFolderLocal, "INT");

                Directory.CreateDirectory(_szUSAPath);
                Directory.CreateDirectory(_szINTPath);
                Directory.CreateDirectory(_PDFFolder);
            }
        }

        private string ResetFile(string fileName)
        {
            string fullFile = Path.Combine(Utilities.GetConfigValue(LISTING_REPORT_LETTER_FOLDER), fileName);
            if (File.Exists(fullFile))
                File.Delete(fullFile);

            return fullFile;
        }

        protected void CreateInteractions(SqlConnection sqlConn, SqlTransaction sqlTran, List<Company> lCompanies)
        {
            SqlCommand cmdCreateTask = new SqlCommand("usp_CreateTask", sqlConn, sqlTran);
            cmdCreateTask.CommandType = CommandType.StoredProcedure;

            int iAssignedToUserID = Utilities.GetIntConfigValue("ListingReportLetterTaskUserID", 1);
            string szNotes = Utilities.GetConfigValue("ListingReportLetterTaskNotes", "Listing Report Letter Sent.");
            foreach (Company company in lCompanies)
            {
                CreateInteraction(sqlConn, sqlTran, company);
            }
        }

        protected void CreateInteraction(SqlConnection sqlConn, SqlTransaction sqlTran, Company company)
        {
            SqlCommand cmdCreateTask = new SqlCommand("usp_CreateTask", sqlConn, sqlTran);
            cmdCreateTask.CommandType = CommandType.StoredProcedure;

            int iAssignedToUserID = Utilities.GetIntConfigValue("ListingReportLetterTaskUserID", 1);
            string szNotes = Utilities.GetConfigValue("ListingReportLetterTaskNotes", "Listing Report Letter Sent.");

            cmdCreateTask.Parameters.Clear();
            cmdCreateTask.Parameters.AddWithValue("AssignedToUserId", iAssignedToUserID);
            cmdCreateTask.Parameters.AddWithValue("TaskNotes", szNotes);
            cmdCreateTask.Parameters.AddWithValue("RelatedCompanyID", company.CompanyID);
            cmdCreateTask.Parameters.AddWithValue("StartDateTime", _dtNow);
            cmdCreateTask.Parameters.AddWithValue("DueDateTime", _dtNow);

            if (company.DeliveryType == "E")
                cmdCreateTask.Parameters.AddWithValue("Action", "EmailOut");
            else
                cmdCreateTask.Parameters.AddWithValue("Action", "LetterOut");

            cmdCreateTask.Parameters.AddWithValue("Status", "Complete");
            cmdCreateTask.Parameters.AddWithValue("PRCategory", "L");
            cmdCreateTask.Parameters.AddWithValue("PRSubcategory", "LRL");
            //cmdCreateTask.Parameters.AddWithValue("Subject", "Listing Report Letter");
            cmdCreateTask.ExecuteNonQuery();
        }

        private const string UPDATE_COMPANY_LRL_DATE =
            @"UPDATE Company 
                 SET comp_PRLastLRLLetterDate=@Now, 
                     comp_UpdatedBy=@UserID, 
                     comp_UpdatedDate=@Now, 
                     comp_Timestamp=@Now 
               WHERE comp_CompanyID IN ({0});";

        protected void UpdateCompanies(SqlConnection sqlConn, SqlTransaction sqlTran, string companyIDList)
        {
            if (string.IsNullOrEmpty(companyIDList))
                return;

            SqlCommand cmdUpdateCompany = new SqlCommand(string.Format(UPDATE_COMPANY_LRL_DATE, companyIDList),
                                                         sqlConn,
                                                         sqlTran);

            cmdUpdateCompany.Parameters.AddWithValue("Now", _dtNow);
            cmdUpdateCompany.Parameters.AddWithValue("UserID", -1);
            cmdUpdateCompany.CommandTimeout = Utilities.GetIntConfigValue("ListingReportLetterCommandTimeout", 150);
            cmdUpdateCompany.ExecuteNonQuery();
        }

        private const string SQL_INSERT_BATCH =
            @"INSERT INTO PRLRLBatch (prlrlb_BatchName, prlrlb_LRLCycleID, prlrlb_BatchType, prlrlb_Count, prlrlb_MemberCount, prlrlb_NonMemebrCount, prlrlb_TotalSentCount, prlrlb_RemainingCount, prlrlb_Criteria, prlrlb_CreatedBy, prlrlb_CreatedDate, prlrlb_UpdatedBy, prlrlb_UpdatedDate, prlrlb_Timestamp) 
                              VALUES (@prlrlb_BatchName, @prlrlb_LRLCycleID,  @prlrlb_BatchType, @prlrlb_Count, @prlrlb_MemberCount, @prlrlb_NonMemebrCount, @prlrlb_TotalSentCount, @prlrlb_RemainingCount, @prlrlb_Criteria, @prlrlb_CreatedBy, @prlrlb_CreatedDate, @prlrlb_UpdatedBy, @prlrlb_UpdatedDate, @prlrlb_Timestamp)";

        protected void InsertLRLBatch(SqlConnection sqlConn, SqlTransaction sqlTran, LRLCycle lrlCycle)
        {
            if (lrlCycle.CompanyCount == 0)
                return;

            SqlCommand cmdCounts = new SqlCommand();
            cmdCounts.Connection = sqlConn;
            cmdCounts.Transaction = sqlTran;
            cmdCounts.CommandText = "usp_GetLRLCounts";
            cmdCounts.CommandType = CommandType.StoredProcedure;
            cmdCounts.CommandTimeout = Utilities.GetIntConfigValue("ListingReportLetterCommandTimeout", 150);
            cmdCounts.Parameters.AddWithValue("CycleStartDate", lrlCycle.StartDate);
            cmdCounts.Parameters.AddWithValue("IndustryType", lrlCycle.IndustryTypeCode);
            cmdCounts.Parameters.AddWithValue("ServiceType", lrlCycle.ServiceTypeCode);

            using (IDataReader dataReader = cmdCounts.ExecuteReader())
            {
                while (dataReader.Read())
                {
                    lrlCycle.TotalSentCount = dataReader.GetInt32(0);
                    lrlCycle.RemainingCount = dataReader.GetInt32(1);
                }
            }

            // If this isn't a test run, create a batch record for this execution.
            SqlCommand cmdInsertBatch = new SqlCommand(SQL_INSERT_BATCH, sqlConn, sqlTran);
            cmdInsertBatch.Parameters.AddWithValue("prlrlb_BatchName", lrlCycle.GetBatchName());
            cmdInsertBatch.Parameters.AddWithValue("prlrlb_LRLCycleID", lrlCycle.LRLCycleID);
            cmdInsertBatch.Parameters.AddWithValue("prlrlb_BatchType", "L");
            cmdInsertBatch.Parameters.AddWithValue("prlrlb_Count", lrlCycle.CompanyCount);
            cmdInsertBatch.Parameters.AddWithValue("prlrlb_MemberCount", lrlCycle.MemberCount);
            cmdInsertBatch.Parameters.AddWithValue("prlrlb_NonMemebrCount", lrlCycle.NonMemberCount);
            cmdInsertBatch.Parameters.AddWithValue("prlrlb_TotalSentCount", lrlCycle.TotalSentCount);
            cmdInsertBatch.Parameters.AddWithValue("prlrlb_RemainingCount", lrlCycle.RemainingCount);
            cmdInsertBatch.Parameters.AddWithValue("prlrlb_Criteria", lrlCycle.CompanyIDs);
            cmdInsertBatch.Parameters.AddWithValue("prlrlb_CreatedBy", -1);
            cmdInsertBatch.Parameters.AddWithValue("prlrlb_CreatedDate", _dtNow);
            cmdInsertBatch.Parameters.AddWithValue("prlrlb_UpdatedBy", -1);
            cmdInsertBatch.Parameters.AddWithValue("prlrlb_UpdatedDate", _dtNow);
            cmdInsertBatch.Parameters.AddWithValue("prlrlb_Timestamp", _dtNow);

            cmdInsertBatch.ExecuteNonQuery();
        }

        protected void GenerateControlCountFile()
        {
            if (ListingReportLetterRunOldZipStyle())
            {
                _LRLControlFile = Path.Combine(Utilities.GetConfigValue(LISTING_REPORT_LETTER_FOLDER),
                                               Utilities.GetConfigValue("ListingReportLetterControlFile", "Control.txt"));
            }
            else
            {
                _LRLControlFile = Path.Combine(_PDFFolder,
                    Utilities.GetConfigValue("ListingReportLetterControlFile", "Control.txt")); //continue to store control file on network folder
            }

            if (File.Exists(_LRLControlFile))
                File.Delete(_LRLControlFile);

            string text = GetFormattedControlTotals();
            WriteToFile(_LRLControlFile, text.ToString());
        }

        protected string GetFormattedControlTotals()
        {
            StringBuilder text = new StringBuilder();

            if (ListingReportLetterRunOldZipStyle())
            {
                AddValueToBuffer(text, "Mailing Piece Count");
                AddValueToBuffer(text, "Location Count");
                AddValueToBuffer(text, "People Count");
                AddValueToBuffer(text, "Company Product Count");
                AddValueToBuffer(text, "Product Count");

                text.Append(Environment.NewLine);
                AddValueToBuffer(text, _MailingPieceCount.ToString());
                AddValueToBuffer(text, _LocationCount.ToString());
                AddValueToBuffer(text, _PeopleCount.ToString());
                AddValueToBuffer(text, _CompanyProductCount.ToString());
                AddValueToBuffer(text, _ProductMasterCount.ToString());
            }
            else
            {
                AddValueToBuffer(text, string.Format("Mailing Piece Count: {0}", _MailingPieceCount.ToString()));
                text.Append(Environment.NewLine);
                AddValueToBuffer(text, string.Format("USA Count: {0}", _USACount.ToString()));
                text.Append(Environment.NewLine);
                AddValueToBuffer(text, string.Format("INT Count: {0}", _INTCount.ToString()));
                text.Append(Environment.NewLine);
            }

            return text.ToString();
        }

        protected string CompressFiles(List<Company> lCompanies)
        {
            string zipName = Path.Combine(Utilities.GetConfigValue(LISTING_REPORT_LETTER_FOLDER),
                                          Utilities.GetConfigValue("ListingReportLetterFolderCompressFile", string.Format("BBSI LRL Data {0}.zip", DateTime.Now.ToString("yyyyMMdd_HHmm"))));

            using (ZipOutputStream zipOutputStream = new ZipOutputStream(File.Create(zipName)))
            {
                zipOutputStream.SetLevel(9); // 0-9, 9 being the highest compression
                zipOutputStream.Password = Utilities.GetConfigValue("ListingReportLetterZipPassword", "P@ssword1");

                addZipEntry(zipOutputStream, Utilities.GetConfigValue(LISTING_REPORT_LETTER_FOLDER), Utilities.GetConfigValue("ListingReportLetterCompanyFile", "Base_Company_Data.txt"));
                addZipEntry(zipOutputStream, Utilities.GetConfigValue(LISTING_REPORT_LETTER_FOLDER), Utilities.GetConfigValue("ListingReportLetterListingFile", "LRL_Listing_Data.txt"));
                addZipEntry(zipOutputStream, Utilities.GetConfigValue(LISTING_REPORT_LETTER_FOLDER), Utilities.GetConfigValue("ListingReportLetterPersonFile", "LRL_Person_Data.txt"));
                addZipEntry(zipOutputStream, Utilities.GetConfigValue(LISTING_REPORT_LETTER_FOLDER), Utilities.GetConfigValue("ListingReportLetterCompanyProductFile", "LRL_Company_Product_Data.txt"));
                addZipEntry(zipOutputStream, Utilities.GetConfigValue(LISTING_REPORT_LETTER_FOLDER), Utilities.GetConfigValue("ListingReportLetterProductMasterFile", "LRL_Product_Master_Data.txt"));

                addZipEntry(zipOutputStream, Utilities.GetConfigValue(LISTING_REPORT_LETTER_FOLDER), Utilities.GetConfigValue("ListingReportLetterControlFile", "Control.txt"));

                if (Utilities.GetBoolConfigValue("ListingReportLetterIncludeLogos", true))
                {
                    string logoFolder = Utilities.GetConfigValue("LogosFolder");
                    foreach (Company company in lCompanies)
                    {
                        if (!string.IsNullOrEmpty(company.Logo))
                        {
                            addZipEntry(zipOutputStream, logoFolder, company.Logo, GetLogoPathForExport(company.Logo));
                        }
                    }
                }

                zipOutputStream.Finish();
                zipOutputStream.IsStreamOwner = true;
                zipOutputStream.Close();
            }

            return zipName;
        }

        protected void GenerateEmail(SqlConnection sqlConn, string fileName, string countMsg)
        {
            string body = string.Format(Utilities.GetConfigValue("ListingReportLetterMailHouseEmailBody",
                                                                 "A new BBSI LRL file, {0}, has been uploaded to {1} and is available for processing."),
                                        fileName,
                                        Utilities.GetConfigValue("ListingReportLetterFTPServer", "ftp://ftp.bluebookprco.com"));

            SqlCommand cmdCreateEmail = new SqlCommand("usp_CreateEmail", sqlConn);
            cmdCreateEmail.CommandType = CommandType.StoredProcedure;
            cmdCreateEmail.Parameters.AddWithValue("To", Utilities.GetConfigValue("ListingReportLetterMailHouseEmailAddress", "cwalls@travant.com"));
            cmdCreateEmail.Parameters.AddWithValue("Subject", Utilities.GetConfigValue("ListingReportLetterMailHouseEmailSubject", "BBSI LRL Files"));
            cmdCreateEmail.Parameters.AddWithValue("Content", body);
            cmdCreateEmail.Parameters.AddWithValue("DoNotRecordCommunication", 1);
            cmdCreateEmail.Parameters.AddWithValue("Action", "EmailOut");
            cmdCreateEmail.ExecuteNonQuery();

            if (!string.IsNullOrEmpty(Utilities.GetConfigValue("ListingReportLetterBBSIEmailAddress", string.Empty)))
            {
                body += Environment.NewLine + Environment.NewLine;
                body += GetFormattedControlTotals();
                body += Environment.NewLine + Environment.NewLine;
                body += countMsg;

                cmdCreateEmail = new SqlCommand("usp_CreateEmail", sqlConn);
                cmdCreateEmail.CommandType = CommandType.StoredProcedure;
                cmdCreateEmail.Parameters.AddWithValue("To", Utilities.GetConfigValue("ListingReportLetterBBSIEmailAddress"));
                cmdCreateEmail.Parameters.AddWithValue("Subject", Utilities.GetConfigValue("ListingReportLetterBBSIEmailSubject", "BBSI LRL Files"));
                cmdCreateEmail.Parameters.AddWithValue("Content", body);
                cmdCreateEmail.Parameters.AddWithValue("DoNotRecordCommunication", 1);
                cmdCreateEmail.Parameters.AddWithValue("Action", "EmailOut");
                cmdCreateEmail.ExecuteNonQuery();
            }
        }

        protected void addZipEntry(ZipOutputStream zipOutputStream,
                                   string folder,
                                   string fileName)
        {
            addZipEntry(zipOutputStream, folder, fileName, fileName);
        }

        protected void addZipEntry(ZipOutputStream zipOutputStream,
                                   string folder,
                                   string fileName,
                                   string zipEntryName)
        {
            ZipEntry zipEntry = new ZipEntry(ZipEntry.CleanName(zipEntryName));
            zipEntry.DateTime = DateTime.Now;
            zipEntry.AESKeySize = 256;
            zipOutputStream.PutNextEntry(zipEntry);

            byte[] buffer = new byte[4096];
            using (FileStream fs = File.OpenRead(Path.Combine(folder, fileName)))
            {
                int sourceBytes;
                do
                {
                    sourceBytes = fs.Read(buffer, 0, buffer.Length);
                    zipOutputStream.Write(buffer, 0, sourceBytes);

                } while (sourceBytes > 0);
            }
            zipOutputStream.CloseEntry();
        }

        private void CleanupFiles()
        {
            if (ListingReportLetterRunOldZipStyle())
            {
                File.Delete(_LRLBaseCompanyDataFile);
                File.Delete(_LRLPersonDataFile);
                File.Delete(_LRLListingDataFile);
                File.Delete(_LRLCompanyProductFile);
                File.Delete(_LRLProductMasterFile);
                File.Delete(_LRLControlFile);
            }
            else
            {
                if (Utilities.GetBoolConfigValue("ListingReportLetterDeletePDF", true))
                    Directory.Delete(_PDFFolderLocal, true);
            }
        }

        ReportInterface oRI = null;
        protected void EmailLRL(SqlConnection sqlConn, SqlTransaction sqlTran, Company company, byte[] abReport)
        {
            ReportUser reportUser = new ReportUser();
            reportUser.CompanyID = company.CompanyID;
            reportUser.Destination = company.DeliveryAddress;
            reportUser.MethodID = DELIVERY_METHOD_EMAIL;

            string lrlFileName = string.Format(Utilities.GetConfigValue("ListingReportLetterEmailFileName", "BBSI Listing Report Letter {0}.pdf"), company.CompanyID);

            string lrlEmailBody = GetEmailTemplate("ListingReportLetterContent.html");
            string subject = Utilities.GetConfigValue("ListingReportLetterEmailSubject", "Your Listing Report for " + company.Name);
            string content = GetFormattedEmail(sqlConn, sqlTran, reportUser.CompanyID, reportUser.PersonID, subject, lrlEmailBody);
            string category = Utilities.GetConfigValue("ListingReportLetterCategory", string.Empty);
            string subcategory = Utilities.GetConfigValue("ListingReportLetterSubcategory", string.Empty);

            SendReport(sqlConn,
                       sqlTran,
                       reportUser,
                       subject,
                       content,
                       abReport,
                       lrlFileName,
                       category,
                       subcategory,
                       true,
                       "Generate LRL",
                       "HTML",
                       Utilities.GetConfigValue("ListingReportLetterEmailProfile", "BBS Listings"));
        }

        protected byte[] GetLRLReport(Company company, bool bBRE, bool bInsert1, bool bInsert2)
        {
            if (oRI == null)
                oRI = new ReportInterface();

            return oRI.GenerateListingReportLetter(company.CompanyID, bBRE, bInsert1, bInsert2);
        }

        private const string SQL_SELECT_ALL =
            @"SELECT comp_CompanyID 
                FROM Company WITH (NOLOCK)
               WHERE comp_PRListingStatus IN ('L', 'H', 'LUV') 
                 AND comp_PRHQID IN ({0}) 
            ORDER BY comp_CompanyID";

        protected string GetFullCompanyIDList(SqlConnection sqlConn, string companyIDList)
        {
            List<Int32> fullCompanyList = new List<Int32>();

            SqlCommand sqlFullCompanyList = new SqlCommand();
            sqlFullCompanyList.Connection = sqlConn;
            sqlFullCompanyList.CommandText = string.Format(SQL_SELECT_ALL, companyIDList);

            using (IDataReader dataReader = sqlFullCompanyList.ExecuteReader())
            {
                while (dataReader.Read())
                {
                    fullCompanyList.Add(dataReader.GetInt32(0));
                }
            }

            return string.Join(",", fullCompanyList);
        }

        protected class LRLCycle
        {
            public int LRLCycleID;
            public string IndustryTypeCode;
            public string ServiceTypeCode;
            public DateTime StartDate;
            public DateTime EndDate;
            public DateTime GapStartDate;
            public DateTime GapEndDate;
            public int CycleCount;
            public int CompanyCount;
            public int MemberCount;
            public int NonMemberCount;
            public int TotalSentCount;
            public int RemainingCount;
            public string CompanyIDs;

            public string GetBatchName()
            {
                string work = null;

                if (IndustryTypeCode == "L")
                {
                    work = "Lumber ";
                }
                else
                {
                    work = "Produce ";
                }

                switch (ServiceTypeCode)
                {
                    case "M":
                        work += " Members";
                        break;
                    case "N":
                        work += " Non-members";
                        break;
                    case "B":
                        work += " All";
                        break;
                }

                return work;
            }
        }

        protected class Company
        {
            public int CompanyID;
            public string Type;
            public long Order;
            public string Logo;
            public string DeliveryType;
            public string Addressee;
            public string DeliveryAddress;
            public string Name;
            public bool IsMember;
            public int Country;
        }
    }
}