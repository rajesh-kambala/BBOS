/***********************************************************************
 Copyright Blue Book Services, Inc. 2012-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact 
 by e-mail at info@travant.com

 ClassName: AccountingExportEvent.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Net.Mail;
using System.Text;
using System.Timers;

using TSI.Utils;

namespace PRCo.BBS.BBSMonitor
{
    class AccountingExportEvent : BBSMonitorEvent
    {

        protected const string DELIMITER = "|";
        protected const string COMPANY_ID_MASK = "0000000";

        protected string _OutputFolder = null;

        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex)
        {
            _szName = "AccountingExportEvent";

            base.Initialize(iIndex);
            _oLogger.RequestName = _szName;
            try
            {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("AccountingExportInterval", 15)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("AccountingExport Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("AccountingExportStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("AccountingExport Start: " + _dtNextDateTime.ToString());

            }
            catch (Exception e)
            {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error initializing AccountingExport event.", e);
                throw;
            }
        }

        override public void ProcessEvent()
        {
            DateTime dtExecutionStartDate = DateTime.Now;
            DateTime dtStartDate = new DateTime();
            DateTime dtEndDate = DateTime.Now;

            StringBuilder sbResults = new StringBuilder();
            bool bIssuesFound = false;

            _OutputFolder = Utilities.GetConfigValue("AccountingExportFolder", @"C:\Temp");
            SqlConnection oConn = new SqlConnection(GetConnectionString());

            try
            {
                oConn.Open();

                // CHW: Something is causing our last run date to be out of sync with the change queue.
                // As long as we have a good end date so we don't skip records added to the queue after
                // we started, this temp-fix should be okay.
                //dtStartDate = GetDateTimeCustomCaption(oConn, "AccountingExportLastRunDate");
                dtStartDate = DateTime.Now.AddHours(-36);

                if (Utilities.GetBoolConfigValue("AEGenerateFiles", true))
                {
                    CreateZipCodeFile(oConn, dtStartDate, dtEndDate);
                    CreateCRMCompaniesFile(oConn, dtStartDate, dtEndDate);
                    CreateCRMCompanyBillToFile(oConn, dtStartDate, dtEndDate);
                    CreateSalesOrderFile(oConn, dtStartDate, dtEndDate, "BT");
                    CreateSalesOrderFile(oConn, dtStartDate, dtEndDate, "ST");
                    CreateDLLineItemsFile(oConn, dtStartDate, dtEndDate);
                    CreateDLQuantityFile(oConn, dtStartDate, dtEndDate);
                    CreateSalesOrderTaxFile(oConn);
                    CreateAdvertisingSalesOrder(oConn);
                    CreateStripePaymentFile(oConn);
                }

                if (Utilities.GetBoolConfigValue("AEImportIntoMAS", true))
                {
                    // The sales order jobs take the longest, so execute them first.
                    ExecuteMASImport(oConn, _OutputFolder, Utilities.GetConfigValue("AESOShipToFileName"), Utilities.GetConfigValue("AESOShipToVIJob"), Utilities.GetConfigValue("AESOShipToMASJob"));
                    ExecuteMASImport(oConn, _OutputFolder, Utilities.GetConfigValue("AESOBillToFileName"), Utilities.GetConfigValue("AESOBillToVIJob"), Utilities.GetConfigValue("AESOBillToMASJob"));
                    ExecuteMASImport(oConn, _OutputFolder, Utilities.GetConfigValue("AEZipCodesFileName"), Utilities.GetConfigValue("AEZipCodesVIJob"), Utilities.GetConfigValue("AEZipCodesMASJob"));
                    ExecuteMASImport(oConn, _OutputFolder, Utilities.GetConfigValue("AECompanyFileName"), Utilities.GetConfigValue("AECompanyVIJob"), Utilities.GetConfigValue("AECompanyMASJob"));

                    // Let's give the company import a head start before
                    // we kick off the other jobs
                    //System.Threading.Thread.Sleep(1000 * Utilities.GetIntConfigValue("AECompanyImportHeadStart", 10));

                    ExecuteMASImport(oConn, _OutputFolder, Utilities.GetConfigValue("AEContactsFileName"), Utilities.GetConfigValue("AEContactsVIJob"), Utilities.GetConfigValue("AEContactsMASJob"));

                    // Now let the contacts load before 
                    // the company/contact job starts
                    //System.Threading.Thread.Sleep(1000 * Utilities.GetIntConfigValue("AEContactsImportHeadStart", 10));

                    ExecuteMASImport(oConn, _OutputFolder, Utilities.GetConfigValue("AECompanyContactsFileName"), Utilities.GetConfigValue("AECompanyContactsVIJob"), Utilities.GetConfigValue("AECompanyContactsMASJob"));
                    ExecuteMASImport(oConn, _OutputFolder, Utilities.GetConfigValue("AECompanyBillToFileName"), Utilities.GetConfigValue("AECompanyBillToVIJob"), Utilities.GetConfigValue("AECompanyBillToMASJob"));
                    ExecuteMASImport(oConn, _OutputFolder, Utilities.GetConfigValue("AEDLOrdersFileName"), Utilities.GetConfigValue("AEDLOrdersVIJob"), Utilities.GetConfigValue("AEDLOrdersMASJob"));
                    ExecuteMASImport(oConn, _OutputFolder, Utilities.GetConfigValue("AEDLLineItemsFileName"), Utilities.GetConfigValue("AEDLLineItemsVIJob"), Utilities.GetConfigValue("AEDLLineItemsMASJob"));
                    ExecuteMASImport(oConn, _OutputFolder, Utilities.GetConfigValue("AEDLQuantityFileName"), Utilities.GetConfigValue("AEDLQuantityVIJob"), Utilities.GetConfigValue("AEDLQuantityMASJob"));
                    ExecuteMASImport(oConn, _OutputFolder, Utilities.GetConfigValue("SalesOrderTaxFileName"), Utilities.GetConfigValue("SalesOrderTaxVIJob"), Utilities.GetConfigValue("SalesOrderTaxMASJob"));
                    ExecuteMASImport(oConn, _OutputFolder, Utilities.GetConfigValue("AdSalesOrderFileName"), Utilities.GetConfigValue("AdSalesOrderVIJob"), Utilities.GetConfigValue("AdSalesOrderMASJob"));
                    ExecuteMASImport(oConn, _OutputFolder, Utilities.GetConfigValue("StripePaymentFileName"), Utilities.GetConfigValue("StripePaymentVIJob"), Utilities.GetConfigValue("StripePaymentMASJob"));
                }

                // We need to give time for MAS to start up and process the file
                // It's possible we got here to fast and we'll move the file before
                // MAS has a chance to process it.
                System.Threading.Thread.Sleep(1000 * Utilities.GetIntConfigValue("ArchiveFilesDelay", 10));

                if (Utilities.GetBoolConfigValue("AEArchiveFiles", true))
                {
                    ArchiveFile(_OutputFolder, Utilities.GetConfigValue("AEZipCodesFileName"), Utilities.GetConfigValue("AccountingExportArchiveFolder"), dtExecutionStartDate);
                    ArchiveFile(_OutputFolder, Utilities.GetConfigValue("AECompanyFileName"), Utilities.GetConfigValue("AccountingExportArchiveFolder"), dtExecutionStartDate);
                    ArchiveFile(_OutputFolder, Utilities.GetConfigValue("AEContactsFileName"), Utilities.GetConfigValue("AccountingExportArchiveFolder"), dtExecutionStartDate);
                    ArchiveFile(_OutputFolder, Utilities.GetConfigValue("AECompanyContactsFileName"), Utilities.GetConfigValue("AccountingExportArchiveFolder"), dtExecutionStartDate);
                    ArchiveFile(_OutputFolder, Utilities.GetConfigValue("AECompanyBillToFileName"), Utilities.GetConfigValue("AccountingExportArchiveFolder"), dtExecutionStartDate);
                    ArchiveFile(_OutputFolder, Utilities.GetConfigValue("AESOBillToFileName"), Utilities.GetConfigValue("AccountingExportArchiveFolder"), dtExecutionStartDate);
                    ArchiveFile(_OutputFolder, Utilities.GetConfigValue("AESOShipToFileName"), Utilities.GetConfigValue("AccountingExportArchiveFolder"), dtExecutionStartDate);
                    ArchiveFile(_OutputFolder, Utilities.GetConfigValue("AEDLOrdersFileName"), Utilities.GetConfigValue("AccountingExportArchiveFolder"), dtExecutionStartDate);
                    ArchiveFile(_OutputFolder, Utilities.GetConfigValue("AEDLLineItemsFileName"), Utilities.GetConfigValue("AccountingExportArchiveFolder"), dtExecutionStartDate);
                    ArchiveFile(_OutputFolder, Utilities.GetConfigValue("AEDLQuantityFileName"), Utilities.GetConfigValue("AccountingExportArchiveFolder"), dtExecutionStartDate);
                    ArchiveFile(_OutputFolder, Utilities.GetConfigValue("SalesOrderTaxFileName"), Utilities.GetConfigValue("AccountingExportArchiveFolder"), dtExecutionStartDate);
                    ArchiveFile(_OutputFolder, Utilities.GetConfigValue("AdSalesOrderFileName"), Utilities.GetConfigValue("AccountingExportArchiveFolder"), dtExecutionStartDate);
                    ArchiveFile(_OutputFolder, Utilities.GetConfigValue("StripePaymentFileName"), Utilities.GetConfigValue("AccountingExportArchiveFolder"), dtExecutionStartDate);
                }


                if (Utilities.GetBoolConfigValue("AEImportIntoMAS", true))
                {
                    // I believe the bat file we're executing actually finishes before the VI job that it invoked
                    // finishes.  We may want to refactor this at some point to execute the VI job directly instead
                    // of going through a bat file, but the bat file is a handy troubleshooting tool.  For now
                    // we'll just pause a little bit to allow VI to catch up.
                    System.Threading.Thread.Sleep(Utilities.GetIntConfigValue("AccountingExportArchivePause", 20) * 1000);

                    if (!GetMASImportResults(oConn, dtExecutionStartDate, Utilities.GetConfigValue("AEZipCodesMASJob"), sbResults))
                        bIssuesFound = true;
                    
                    if (!GetMASImportResults(oConn, dtExecutionStartDate, Utilities.GetConfigValue("AECompanyMASJob"), sbResults))
                        bIssuesFound = true;

                    if (!GetMASImportResults(oConn, dtExecutionStartDate, Utilities.GetConfigValue("AEContactsMASJob"), sbResults))
                        bIssuesFound = true;

                    if (!GetMASImportResults(oConn, dtExecutionStartDate, Utilities.GetConfigValue("AECompanyContactsMASJob"), sbResults))
                        bIssuesFound = true;

                    if (!GetMASImportResults(oConn, dtExecutionStartDate, Utilities.GetConfigValue("AECompanyBillToMASJob"), sbResults))
                        bIssuesFound = true;

                    if (!GetMASImportResults(oConn, dtExecutionStartDate, Utilities.GetConfigValue("AESOBillToMASJob"), sbResults))
                        bIssuesFound = true;

                    if (!GetMASImportResults(oConn, dtExecutionStartDate, Utilities.GetConfigValue("AESOShipToMASJob"), sbResults))
                        bIssuesFound = true;

                    if (!GetMASImportResults(oConn, dtExecutionStartDate, Utilities.GetConfigValue("AEDLOrdersMASJob"), sbResults))
                        bIssuesFound = true;

                    if (!GetMASImportResults(oConn, dtExecutionStartDate, Utilities.GetConfigValue("AEDLLineItemsMASJob"), sbResults))
                        bIssuesFound = true;

                    if (!GetMASImportResults(oConn, dtExecutionStartDate, Utilities.GetConfigValue("AEDLQuantityMASJob"), sbResults))
                        bIssuesFound = true;

                    if (!GetMASImportResults(oConn, dtExecutionStartDate, Utilities.GetConfigValue("SalesOrderTaxMASJob"), sbResults))
                        bIssuesFound = true;

                    if (!GetMASImportResults(oConn, dtExecutionStartDate, Utilities.GetConfigValue("AdSalesOrderMASJob"), sbResults))
                        bIssuesFound = true;

                    if (!GetMASImportResults(oConn, dtExecutionStartDate, Utilities.GetConfigValue("StripePaymentMASJob"), sbResults))
                        bIssuesFound = true;
                }

                DeleteChangeRequestRecords(oConn, dtStartDate, dtEndDate);

                // If we didn't generate files, then we shouldn't udpate the last 
                // run value.
                if (Utilities.GetBoolConfigValue("AEGenerateFiles", true))
                    UpdateDateTimeCustomCaption(oConn, "AccountingExportLastRunDate", dtEndDate);

                if (Utilities.GetBoolConfigValue("AccountingExportWriteResultsToEventLog", true))
                {
                    string subject = "successfully.";
                    if (bIssuesFound)
                        subject = " with issues.";
                    
                    _oBBSMonitorService.LogEvent("The Accounting Export Event completed " + subject + Environment.NewLine + Environment.NewLine + sbResults.ToString());
                }

                if ((Utilities.GetBoolConfigValue("AccountingExportSendResultsToSupport", false)) ||
                    (bIssuesFound))
                {
                    string subject = "Accounting Export Success";
                    if (bIssuesFound)
                        subject = "Accounting Completed with Issues";

                    SendMail(subject,
                             sbResults.ToString());
                }
            }
            catch (Exception e)
            {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error Procesing AccountingExport Event.", e);
            }
            finally
            {
                if (oConn != null)
                    oConn.Close();

                oConn = null;
            }
        }

        protected const string SQL_CRM_COMPANIES =
            @"SELECT DISTINCT 
                   comp_PRHQID, Comp_CompanyId, comp_PRCorrTradestyle, Addr_Address1, Addr_Address2, Addr_Address3, PostCode, prci_City, State, prcn_CountryId, EmailAddress,
                   Fax, prci2_TaxCode, prci2_TaxExempt, prci2_CustomerCategory,
                   Addressee
              FROM PRChangeDetection WITH (NOLOCK)
                   INNER JOIN vPRCompanyAccounting WITH (NOLOCK) ON prchngd_CompanyID = comp_CompanyID
             WHERE prchngd_ChangeType IN ('New', 'UPDATE', 'User Triggered')
               AND prchngd_CreatedDate BETWEEN @Start AND @End";

        protected void CreateCRMCompaniesFile(SqlConnection oConn,
                                              DateTime fromDate,
                                              DateTime toDate)
        {

            StringBuilder sbCRMCompanies = new StringBuilder();
            StringBuilder sbCRMContacts = new StringBuilder();
            StringBuilder sbCRMCompanyContacts = new StringBuilder();


            SqlCommand cmdCRMCompanies = new SqlCommand(SQL_CRM_COMPANIES, oConn);
            cmdCRMCompanies.CommandTimeout = 240;
            cmdCRMCompanies.Parameters.AddWithValue("Start", fromDate);
            cmdCRMCompanies.Parameters.AddWithValue("End", toDate);
            
            using (SqlDataReader reader = cmdCRMCompanies.ExecuteReader())
            {
                while (reader.Read())
                {
                    if (reader[2] == DBNull.Value)
                        continue;

                    sbCRMCompanies.Append("00");
                    sbCRMCompanies.Append(DELIMITER);
                    sbCRMCompanies.Append(reader.GetInt32(1).ToString(COMPANY_ID_MASK));
                    sbCRMCompanies.Append(DELIMITER);

                    string work = GetString(reader[2]);
                    if (work.Length > 30)
                        work = work.Substring(0, 30);

                    sbCRMCompanies.Append(work);
                    sbCRMCompanies.Append(DELIMITER);

                    // Add the rest of our row
                    AddRow(reader, sbCRMCompanies, 2, 15);

                    if (!string.IsNullOrEmpty(GetString(reader[15])))
                    {
                        sbCRMContacts.Append("00");
                        sbCRMContacts.Append(DELIMITER);
                        sbCRMContacts.Append(reader.GetInt32(1).ToString(COMPANY_ID_MASK));
                        sbCRMContacts.Append(DELIMITER);
                        sbCRMContacts.Append(Utilities.GetConfigValue("AccountingContactCode", "BILL"));
                        sbCRMContacts.Append(DELIMITER);
                        sbCRMContacts.Append(GetString(reader[15]));
                        sbCRMContacts.Append(Environment.NewLine);

                        sbCRMCompanyContacts.Append("00");
                        sbCRMCompanyContacts.Append(DELIMITER);
                        sbCRMCompanyContacts.Append(reader.GetInt32(1).ToString(COMPANY_ID_MASK));
                        sbCRMCompanyContacts.Append(DELIMITER);
                        sbCRMCompanyContacts.Append(Utilities.GetConfigValue("AccountingContactCode", "BILL"));
                        sbCRMCompanyContacts.Append(Environment.NewLine);
                    }
                }
            }

            WriteFile(sbCRMCompanies, _OutputFolder, Utilities.GetConfigValue("AECompanyFileName"));
            WriteFile(sbCRMContacts, _OutputFolder, Utilities.GetConfigValue("AEContactsFileName"));
            WriteFile(sbCRMCompanyContacts, _OutputFolder, Utilities.GetConfigValue("AECompanyContactsFileName"));
        }

        protected const string SQL_CRM_BILL_TO =
            @"SELECT DISTINCT 
                   Comp_CompanyId, comp_PRHQID
              FROM PRChangeDetection WITH (NOLOCK)
                   INNER JOIN vPRCompanyAccounting WITH (NOLOCK) ON prchngd_CompanyID = comp_CompanyID
             WHERE prchngd_ChangeType IN ('New', 'UPDATE', 'User Triggered')
               AND prchngd_CreatedDate BETWEEN @Start AND @End
               AND comp_PRHQID <> comp_CompanyID
               AND comp_PRType = 'B'";

        protected void CreateCRMCompanyBillToFile(SqlConnection oConn,
                                                  DateTime fromDate,
                                                  DateTime toDate)
        {
            StringBuilder sbCRMBillTo = new StringBuilder();


            SqlCommand cmdCRMBillTo = new SqlCommand(SQL_CRM_BILL_TO, oConn);
            cmdCRMBillTo.CommandTimeout = 240;
            cmdCRMBillTo.Parameters.AddWithValue("Start", fromDate);
            cmdCRMBillTo.Parameters.AddWithValue("End", toDate);
            
            using (SqlDataReader reader = cmdCRMBillTo.ExecuteReader())
            {
                while (reader.Read())
                {
                    sbCRMBillTo.Append("00");
                    sbCRMBillTo.Append(DELIMITER);
                    sbCRMBillTo.Append(reader.GetInt32(0).ToString(COMPANY_ID_MASK));
                    sbCRMBillTo.Append(DELIMITER);
                    sbCRMBillTo.Append("00");
                    sbCRMBillTo.Append(DELIMITER);
                    sbCRMBillTo.Append(reader.GetInt32(1).ToString(COMPANY_ID_MASK));
                    sbCRMBillTo.Append(Environment.NewLine);
                }
            }

            WriteFile(sbCRMBillTo, _OutputFolder, Utilities.GetConfigValue("AECompanyBillToFileName"));
        }

        protected const string SQL_SALES_ORDERS =
            @"SELECT DISTINCT 
                   SalesOrderNo, '00', '0' + CAST(comp_CompanyID as varchar(10)), Addr_Address1, Addr_Address2, Addr_Address3, PostCode, prci_City, State, prcn_CountryId, vPRCompanyAccounting.EmailAddress, Fax
              FROM PRChangeDetection WITH (NOLOCK)
                   INNER JOIN vPRCompanyAccounting WITH (NOLOCK) ON prchngd_CompanyID = comp_CompanyID
                   {0}
             WHERE prchngd_ChangeType IN ('New', 'UPDATE', 'User Triggered')
               AND prchngd_CreatedDate BETWEEN @Start AND @End";

        protected const string SQL_BILL_TO_CLAUSE =
            "INNER JOIN MAS_PRC.dbo.SO_SalesOrderHeader ON CAST(BillToCustomerNo as INT) = comp_CompanyID AND OrderType = 'R' AND CycleCode <> '99'";

        protected const string SQL_SHIP_TO_CLAUSE =
            "INNER JOIN MAS_PRC.dbo.SO_SalesOrderHeader ON CAST(CustomerNo as INT) = comp_CompanyID AND OrderType = 'R' AND CycleCode <> '99'";

        protected void CreateSalesOrderFile(SqlConnection oConn,
                                            DateTime fromDate,
                                            DateTime toDate,
                                            string fileType)
        {
            StringBuilder sbSalesOrders = new StringBuilder();

            string sql = null;
            string fileName = null;
            switch (fileType)
            {
                case "BT":
                    sql = string.Format(SQL_SALES_ORDERS, SQL_BILL_TO_CLAUSE);
                    fileName = Utilities.GetConfigValue("AESOBillToFileName");
                    break;
                case "ST":
                    sql = string.Format(SQL_SALES_ORDERS, SQL_SHIP_TO_CLAUSE);
                    fileName = Utilities.GetConfigValue("AESOShipToFileName");
                    break;
            }

            SqlCommand cmdSalesOrders = new SqlCommand(sql, oConn);
            cmdSalesOrders.CommandTimeout = 240;
            cmdSalesOrders.Parameters.AddWithValue("Start", fromDate);
            cmdSalesOrders.Parameters.AddWithValue("End", toDate);

            using (SqlDataReader reader = cmdSalesOrders.ExecuteReader())
            {
                while (reader.Read())
                {
                    AddRow(reader, sbSalesOrders, 12);
                }
            }

            WriteFile(sbSalesOrders, _OutputFolder, fileName);
        }



        protected void CreateDLLineItemsFile(SqlConnection oConn,
                                             DateTime fromDate,
                                             DateTime toDate)
        {

            StringBuilder sbDLOrders = new StringBuilder();
            StringBuilder sbDLLineItems = new StringBuilder();

            SqlCommand cmdDLLineItems = new SqlCommand("usp_GetDLOrders", oConn);
            cmdDLLineItems.CommandType = System.Data.CommandType.StoredProcedure;
            cmdDLLineItems.CommandTimeout = 240;
            cmdDLLineItems.Parameters.AddWithValue("Start", fromDate);
            cmdDLLineItems.Parameters.AddWithValue("End", toDate);

            using (SqlDataReader reader = cmdDLLineItems.ExecuteReader())
            {
                while (reader.Read())
                {
                    AddRow(reader, sbDLOrders, 44);
                }

                reader.NextResult();

                while (reader.Read())
                {
                    AddRow(reader, sbDLLineItems, 16);
                }
            }

            WriteFile(sbDLOrders, _OutputFolder, Utilities.GetConfigValue("AEDLOrdersFileName"));
            WriteFile(sbDLLineItems, _OutputFolder, Utilities.GetConfigValue("AEDLLineItemsFileName"));
        }

        protected const string SQL_DL_QUANTITY =
            @"SELECT SO_SalesOrderHeader.SalesOrderNo, ARDivisionNo, CustomerNo, LineKey, CRM.dbo.ufn_GetListingDLLineCount(prchngd_CompanyID) As Quantity
                FROM CRM.dbo.PRChangeDetection WITH (NOLOCK)
	                 INNER JOIN MAS_PRC.dbo.SO_SalesOrderHeader ON CAST(CustomerNo as INT) =prchngd_CompanyID AND OrderType = 'R' AND CycleCode <> '99'       
	                 INNER JOIN MAS_PRC.dbo.SO_SalesOrderDetail ON SO_SalesOrderHeader.SalesOrderNo = SO_SalesOrderDetail.SalesOrderNo
               WHERE prchngd_ChangeType IN ('DL Quantity')  
                 AND prchngd_CreatedDate BETWEEN @Start AND @End
                 AND ItemCode = 'DL'
                 AND prchngd_CompanyID NOT IN (SELECT prse_CompanyID FROM PRService WHERE prse_Primary='Y')";

        protected void CreateDLQuantityFile(SqlConnection oConn,
                                            DateTime fromDate,
                                            DateTime toDate)
        {

            StringBuilder sbDLQuantity = new StringBuilder();

            SqlCommand cmdDLQuantity = new SqlCommand(SQL_DL_QUANTITY, oConn);
            cmdDLQuantity.CommandTimeout = 240;
            cmdDLQuantity.Parameters.AddWithValue("Start", fromDate);
            cmdDLQuantity.Parameters.AddWithValue("End", toDate);
            

            using (SqlDataReader reader = cmdDLQuantity.ExecuteReader())
            {
                while (reader.Read())
                {
                    AddRow(reader, sbDLQuantity, 5);
                }
            }

            WriteFile(sbDLQuantity, _OutputFolder, Utilities.GetConfigValue("AEDLQuantityFileName"));
        }

        protected const string SQL_ZIP_CODES =
            @"SELECT DISTINCT 
                   PostCode, MAX(prci_City) As City, State, prcn_CountryId
              FROM PRChangeDetection WITH (NOLOCK)
                   INNER JOIN vPRCompanyAccounting WITH (NOLOCK) ON prchngd_CompanyID = comp_CompanyID
                   LEFT OUTER JOIN MAS_SYSTEM.dbo.SY_ZipCode ON PostCode = ZipCode
             WHERE prchngd_ChangeType IN ('New', 'UPDATE', 'User Triggered')
               AND prchngd_CreatedDate BETWEEN @Start AND @End
               AND prcn_CountryID IN ('001', '002', '003')
               AND ZipCode IS NULL
               AND PostCode IS NOT NULL
          GROUP BY PostCode, State, prcn_CountryID
          ORDER BY prcn_CountryID, State, PostCode";

        protected void CreateZipCodeFile(SqlConnection oConn,
                                         DateTime fromDate,
                                         DateTime toDate)
        {

            StringBuilder sbZipCodes = new StringBuilder();

            SqlCommand cmdZipCodes = new SqlCommand(SQL_ZIP_CODES, oConn);
            cmdZipCodes.CommandTimeout = Utilities.GetIntConfigValue("ReaderTimeout", 600);
            cmdZipCodes.Parameters.AddWithValue("Start", fromDate);
            cmdZipCodes.Parameters.AddWithValue("End", toDate);

            using (SqlDataReader reader = cmdZipCodes.ExecuteReader())
            {
                while (reader.Read())
                {
                    AddRow(reader, sbZipCodes, 4);
                }
            }

            WriteFile(sbZipCodes, _OutputFolder, Utilities.GetConfigValue("AEZipCodesFileName"));
        }


        protected const string SQL_DELETE_CHANGE_REQUEST =
            @"DELETE FROM PRChangeDetection WHERE prchngd_CreatedDate BETWEEN @Start AND @End";

        protected int DeleteChangeRequestRecords(SqlConnection oConn,
                                                   DateTime fromDate,
                                                   DateTime toDate)
        {
            if (!Utilities.GetBoolConfigValue("AEDeleteChangeRequestRecords", false))
                return 0;

            SqlCommand cmdDelete = new SqlCommand(SQL_DELETE_CHANGE_REQUEST, oConn);
            cmdDelete.CommandTimeout = 240;
            cmdDelete.Parameters.AddWithValue("Start", fromDate);
            cmdDelete.Parameters.AddWithValue("End", toDate);
            return cmdDelete.ExecuteNonQuery();
        }

        protected void AddRow(SqlDataReader reader, StringBuilder buffer, int columns)
        {
            AddRow(reader, buffer, 0, columns);
        }

        protected void AddRow(SqlDataReader reader, StringBuilder buffer, int startIndex, int columns)
        {
            for (int i = startIndex; i < columns; i++)
            {
                buffer.Append(GetString(reader[i]));

                if (i != (columns - 1))
                    buffer.Append(DELIMITER);
            }
            buffer.Append(Environment.NewLine);
        }

        private const string SQL_SALES_ORDER_TAX =
            @"SELECT hdr.SalesOrderNo,
                       c.TaxSchedule
                  FROM MAS_PRC.dbo.AR_Customer c WITH (NOLOCK)
                       INNER JOIN MAS_PRC.dbo.SO_SalesOrderHeader hdr WITH (NOLOCK) ON c.CustomerNo = hdr.CustomerNo
                 WHERE c.TaxSchedule != hdr.TaxSchedule
                   AND OrderType = 'R'
                   AND CycleCode <> '99'
                   AND c.ARDivisionNo = '00'
                   AND c.TaxSchedule <> ''";

        protected void CreateSalesOrderTaxFile(SqlConnection oConn)
        {
            StringBuilder sbSalesOrderTax = new StringBuilder();
            SqlCommand cmdSalesOrderTax = new SqlCommand(SQL_SALES_ORDER_TAX, oConn);
            cmdSalesOrderTax.CommandTimeout = 240;
            using (SqlDataReader reader = cmdSalesOrderTax.ExecuteReader())
            {
                while (reader.Read())
                {
                    AddRow(reader, sbSalesOrderTax, 2);
                }
            }

            WriteFile(sbSalesOrderTax, _OutputFolder, Utilities.GetConfigValue("SalesOrderTaxFileName"));
        }

        private const string SQL_STRIPE_PAYMENT_BATCH_TOTAL =
            @"SELECT SUM(TE.ExtensionAmt+ihh.SalesTaxAmt) as BatchTotal
               FROM PRInvoice inv WITH(NOLOCK) 
		            INNER JOIN MAS_PRC.dbo.AR_InvoiceHistoryHeader ihh WITH(NOLOCK) ON ihh.UDF_MASTER_INVOICE = inv.prinv_InvoiceNbr
		            LEFT OUTER JOIN (SELECT ihd.InvoiceNo InvoiceNo, SUM(ihd.ExtensionAmt) ExtensionAmt FROM MAS_PRC.dbo.AR_InvoiceHistoryDetail ihd WITH(NOLOCK) GROUP BY ihd.InvoiceNo) TE ON TE.InvoiceNo = ihh.InvoiceNo
	          WHERE prinv_UpdatedBy = -1
                AND prinv_PaymentImportedIntoMAS = 'Y'
                AND prinv_UpdatedDate = @TransactionDateTime";

        private const string SQL_STRIPE_PAYMENT_FILE =
             @"SELECT ARDivisionNo 
	                ,MAS_PRC.dbo.ufn_GetBillTo(BillToCustomerNo, CustomerNo) CustomerNo
	                ,ihh.InvoiceNo
	                ,InvoiceType='IN'
                    ,[TransactionDate]=FORMAT(prinv_PaymentDateTime, 'M/d/yyyy')
	                ,[SequenceNo]='000000'
	                ,[CheckNo]='STR' + FORMAT(prinv_InvoiceID,'0000000')
	                ,[TransactionType]='P'
	                ,[PaymentDate]= FORMAT(prinv_PaymentDateTime, 'M/d/yyyy')
	                ,[TransactionAmt]=TE.ExtensionAmt+ihh.SalesTaxAmt
                    ,BatchTotal = @BatchTotal 
                    ,DepositBatchNum = @DepositBatchNum 
               FROM PRInvoice inv WITH(NOLOCK) 
		            INNER JOIN MAS_PRC.dbo.AR_InvoiceHistoryHeader ihh WITH(NOLOCK) ON ihh.UDF_MASTER_INVOICE = inv.prinv_InvoiceNbr
		            LEFT OUTER JOIN (SELECT ihd.InvoiceNo InvoiceNo, SUM(ihd.ExtensionAmt) ExtensionAmt FROM MAS_PRC.dbo.AR_InvoiceHistoryDetail ihd WITH(NOLOCK) GROUP BY ihd.InvoiceNo) TE ON TE.InvoiceNo = ihh.InvoiceNo
	          WHERE prinv_UpdatedBy = -1
                AND prinv_PaymentImportedIntoMAS = 'Y'
                AND prinv_UpdatedDate = @TransactionDateTime
            ORDER BY CustomerNo, ihh.InvoiceNo  ";

        private const string SQL_STRIPE_UPDATE_PRINVOICE =
            @"UPDATE PRInvoice 
                 SET prinv_PaymentImportedIntoMAS = 'Y', 
                     prinv_UpdatedBy = -1, 
                     prinv_UpdatedDate = @TransactionDateTime
                FROM MAS_PRC.dbo.AR_InvoiceHistoryHeader WITH(NOLOCK) 
               WHERE UDF_MASTER_INVOICE = prinv_InvoiceNbr
                 AND prinv_PaymentDateTime IS NOT NULL 
                 AND prinv_PaymentImportedIntoMAS IS NULL";

        private const string SQL_STRIPE_DEPOIST_BATCH_NUM =
            @"DECLARE @DepositBatchNum int = 0;
SELECT @DepositBatchNum = CAST(capt_code as Int) FROM CRM.dbo.Custom_Captions WHERE capt_family = 'DepositBatchNum';
SET @DepositBatchNum = @DepositBatchNum + 1;
IF (@DepositBatchNum > 9999) SET @DepositBatchNum = 1;
UPDATE CRM.dbo.Custom_Captions SET capt_code = @DepositBatchNum, Capt_UpdatedDate=GETDATE(), Capt_UpdatedBy=1 WHERE capt_family = 'DepositBatchNum';
SELECT @DepositBatchNum as DepositBatchNum;";

        protected void CreateStripePaymentFile(SqlConnection oConn)
        {
            SuspendCompanies(oConn);

            int startHour = Utilities.GetIntConfigValue("StripeProcessingStartHour", 21);
            if (DateTime.Now.Hour < startHour)
                return;

            DateTime transactionDate = DateTime.Now;

            try
            {
                _oLogger.LogMessage("CreateStripePaymentFile - Begin");
                _oLogger.LogMessage($" - Transaction Date: {transactionDate:yyyy-MM-dd HH:mm:ss.fff}");


                //Update the PRInvoice record setting the PaymentImpotedIntoMAS Flag = 'Y'.
                SqlCommand cmdSetImported = new SqlCommand(SQL_STRIPE_UPDATE_PRINVOICE, oConn);
                cmdSetImported.Parameters.AddWithValue("TransactionDateTime", transactionDate);
                cmdSetImported.ExecuteNonQuery();

                SqlCommand cmdBatchTotal = new SqlCommand(SQL_STRIPE_PAYMENT_BATCH_TOTAL, oConn);
                cmdBatchTotal.Parameters.AddWithValue("TransactionDateTime", transactionDate);
                object value = cmdBatchTotal.ExecuteScalar();
                if ((value == null) ||
                    (value == DBNull.Value) ||
                    (Convert.ToDecimal(value) == 0))
                {
                    _oLogger.LogMessage(" - Batch Total = 0 - Existing");
                    return;
                }

                string batchTotal = Convert.ToDecimal(value).ToString("0.00");

                SqlCommand cmdDepositBatchNum = new SqlCommand(SQL_STRIPE_DEPOIST_BATCH_NUM, oConn);
                int depositBatchNumber = Convert.ToInt32(cmdDepositBatchNum.ExecuteScalar());
                string depostBatch = $"S{depositBatchNumber:0000}";

                StringBuilder sbStripePayment = new StringBuilder();

                SqlCommand cmdStripePayment = new SqlCommand(SQL_STRIPE_PAYMENT_FILE, oConn);
                cmdStripePayment.Parameters.AddWithValue("TransactionDateTime", transactionDate);
                cmdStripePayment.Parameters.AddWithValue("BatchTotal", batchTotal);
                cmdStripePayment.Parameters.AddWithValue("DepositBatchNum", depostBatch);
                cmdStripePayment.CommandTimeout = 240;
                using (SqlDataReader reader = cmdStripePayment.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        AddRow(reader, sbStripePayment, 12);
                    }
                }

                WriteFile(sbStripePayment, _OutputFolder, Utilities.GetConfigValue("StripePaymentFileName"));
                
                UnsuspendCompanies(oConn);
            } finally {
                _oLogger.LogMessage("CreateStripePaymentFile - End");
            }
        }
        

        protected class AdSalesOrder
        {
            public decimal pract_TermsAmount;
            public DateTime pract_BillingDate;
            public int pract_AdCampaignTermsID;
            public string pract_InvoiceDescription;

            public int pradc_AdCampaignID;
            public int pradch_CompanyID;
            public int pradch_HQID;
            public string pradc_AdCampaignType;
            public string pradch_Name;
            public string pradc_BluePrintsEdition;
            public string pradc_BluePrintsEdition_Capt;
            public string pradc_PlannedSection;
            public string pradc_PlannedSection_Capt;
            public decimal pradc_Cost;
            public decimal pradc_Discount;
            public string pradc_CreativeStatus;
            public string pradc_CreativeStatusPrint;
            public string pradc_Premium;
            public int pradc_AdCampaignHeaderID;
            public string pradc_AdCampaignTypeDigital;
            public string pradc_AdCampaignTypeDigital_Capt;
            public string pradc_TTEdition;
            public string pradc_TTEdition_Capt;
            public string pradc_KYCEdition;
            public string pradc_KYCEdition_Capt;
            public int pradc_KYCCommodityID;
            public string pradc_KYCCommodityID_Capt;

            public string pradch_TypeCode;
            public decimal pradch_Cost;
            public decimal pradch_Discount;

            // constructor
            public AdSalesOrder(SqlDataReader reader)
            {
                pract_TermsAmount = reader["pract_TermsAmount"] == DBNull.Value ? 0.0m : Convert.ToDecimal(reader["pract_TermsAmount"]);
                pract_BillingDate = Convert.ToDateTime(reader["pract_BillingDate"]);
                pract_AdCampaignTermsID = reader["pract_AdCampaignTermsID"] == DBNull.Value ? 0 : Convert.ToInt32(reader["pract_AdCampaignTermsID"]);

                pract_InvoiceDescription = Convert.ToString(reader["pract_InvoiceDescription"]);

                pradc_AdCampaignID = reader["pradc_AdCampaignID"] == DBNull.Value ? 0 : Convert.ToInt32(reader["pradc_AdCampaignID"]);
                pradch_CompanyID = reader["pradch_CompanyID"] == DBNull.Value ? 0 : Convert.ToInt32(reader["pradch_CompanyID"]);
                pradch_HQID = reader["pradch_HQID"] == DBNull.Value ? 0 : Convert.ToInt32(reader["pradch_HQID"]);
                pradc_AdCampaignType = Convert.ToString(reader["pradc_AdCampaignType"]);
                pradch_Name = Convert.ToString(reader["pradch_Name"]);
                pradc_BluePrintsEdition = Convert.ToString(reader["pradc_BluePrintsEdition"]);
                pradc_BluePrintsEdition_Capt = Convert.ToString(reader["pradc_BluePrintsEdition_Capt"]);
                pradc_PlannedSection = Convert.ToString(reader["pradc_PlannedSection"]);
                pradc_PlannedSection_Capt = Convert.ToString(reader["pradc_PlannedSection_Capt"]);
                pradc_Cost = reader["pradc_Cost"] == DBNull.Value ? 0.0m : Convert.ToDecimal(reader["pradc_Cost"]);
                pradc_Discount = reader["pradc_Discount"] == DBNull.Value ? 0.0m : Convert.ToDecimal(reader["pradc_Discount"]);
                pradc_CreativeStatus = Convert.ToString(reader["pradc_CreativeStatus"]);
                pradc_CreativeStatusPrint = Convert.ToString(reader["pradc_CreativeStatusPrint"]);
                pradc_Premium = Convert.ToString(reader["pradc_Premium"]);
                pradc_AdCampaignHeaderID = reader["pradc_AdCampaignHeaderID"] == DBNull.Value ? 0 : Convert.ToInt32(reader["pradc_AdCampaignHeaderID"]);
                pradc_AdCampaignTypeDigital = Convert.ToString(reader["pradc_AdCampaignTypeDigital"]);
                pradc_AdCampaignTypeDigital_Capt = Convert.ToString(reader["pradc_AdCampaignTypeDigital_Capt"]);
                pradc_TTEdition = Convert.ToString(reader["pradc_TTEdition"]);
                pradc_TTEdition_Capt = Convert.ToString(reader["pradc_TTEdition_Capt"]);
                pradc_KYCEdition = Convert.ToString(reader["pradc_KYCEdition"]);
                pradc_KYCEdition_Capt = Convert.ToString(reader["pradc_KYCEdition_Capt"]);
                pradc_KYCCommodityID = reader["pradc_KYCCommodityID"] == DBNull.Value ? 0 : Convert.ToInt32(reader["pradc_KYCCommodityID"]);
                pradc_KYCCommodityID_Capt = Convert.ToString(reader["pradc_KYCCommodityID_Capt"]);

                pradch_CompanyID = reader["pradch_CompanyID"] == DBNull.Value ? 0 : Convert.ToInt32(reader["pradch_CompanyID"]);
                pradch_TypeCode = Convert.ToString(reader["pradch_TypeCode"]);
                pradch_Cost = reader["pradch_Cost"] == DBNull.Value ? 0.0m : Convert.ToDecimal(reader["pradch_Cost"]);
                pradch_Discount = reader["pradch_Discount"] == DBNull.Value ? 0.0m : Convert.ToDecimal(reader["pradch_Discount"]);
            }
        }

        protected class AdARData
        {
            public string CompanyID;

            public string BillToName;
            public string BillToAddress1;
            public string BillToAddress2;
            public string BillToAddress3;
            public string BillToZipCode;
            public string BillToCity;
            public string BillToState;
            public string BillToCountryCode;

            public string ShipToName;
            public string ShipToAddress1;
            public string ShipToAddress2;
            public string ShipToAddress3;
            public string ShipToZipCode;
            public string ShipToCity;
            public string ShipToState;
            public string ShipToCountryCode;

            public string TaxSchedule;
            public string BilltoDivisionNo;
            public string BillToCustomerNo;

            public string ItemCode;
            public string ItemType;
            public string ItemCodeDesc;
            public string StandardUnitOfMeasure;
            public string CostOfGoodsSoldAcctKey;
            public string SalesIncomeAcctKey;
            public string TaxClass;

            public int QuantityOrdered;

            // constructor
            public AdARData(SqlDataReader reader)
            {
                CompanyID = Convert.ToString(reader["CompanyID"]);

                BillToName = Convert.ToString(reader["BillToName"]);
                BillToAddress1 = Convert.ToString(reader["BillToAddress1"]);
                BillToAddress2 = Convert.ToString(reader["BillToAddress2"]);
                BillToAddress3 = Convert.ToString(reader["BillToAddress3"]);
                BillToZipCode = Convert.ToString(reader["BillToZipCode"]);
                BillToCity = Convert.ToString(reader["BillToCity"]);
                BillToState = Convert.ToString(reader["BillToState"]);
                BillToCountryCode = Convert.ToString(reader["BillToCountryCode"]);

                ShipToName = Convert.ToString(reader["ShipToName"]);
                ShipToAddress1 = Convert.ToString(reader["ShipToAddress1"]);
                ShipToAddress2 = Convert.ToString(reader["ShipToAddress2"]);
                ShipToAddress3 = Convert.ToString(reader["ShipToAddress3"]);
                ShipToZipCode = Convert.ToString(reader["ShipToZipCode"]);
                ShipToCity = Convert.ToString(reader["ShipToCity"]);
                ShipToState = Convert.ToString(reader["ShipToState"]);
                ShipToCountryCode = Convert.ToString(reader["ShipToCountryCode"]);

                TaxSchedule = Convert.ToString(reader["TaxSchedule"]);
                BilltoDivisionNo = Convert.ToString(reader["BilltoDivisionNo"]);
                BillToCustomerNo = Convert.ToString(reader["BillToCustomerNo"]);

                ItemCode = Convert.ToString(reader["ItemCode"]);
                ItemType = Convert.ToString(reader["ItemType"]);
                
                StandardUnitOfMeasure = Convert.ToString(reader["StandardUnitOfMeasure"]);
                CostOfGoodsSoldAcctKey = Convert.ToString(reader["CostOfGoodsSoldAcctKey"]);
                SalesIncomeAcctKey = Convert.ToString(reader["SalesIncomeAcctKey"]);
                TaxClass = Convert.ToString(reader["TaxClass"]);

                QuantityOrdered = reader["QuantityOrdered"] == DBNull.Value ? 0 : Convert.ToInt32(reader["QuantityOrdered"]);

                //Fields that need to be overridden
                ItemCodeDesc = Convert.ToString(reader["ItemCodeDesc"]);
                //StandardUnitPrice = reader["StandardUnitPrice"] == DBNull.Value ? 0.0m : Convert.ToDecimal(reader["StandardUnitPrice"]);
                //ExtensionAmt = reader["ExtensionAmt"] == DBNull.Value ? 0.0m : Convert.ToDecimal(reader["ExtensionAmt"]);
            }
        }

        protected const string SQL_AD_SALES_ORDERS_PENDING = "SELECT DISTINCT * FROM vPRAdSalesOrdersPending";
        protected const string SQL_AD_AR_DATA = "usp_PRAd_AR_Data";

        protected void CreateAdvertisingSalesOrder(SqlConnection oConn)
        {
            StringBuilder sbAdSalesOrders = new StringBuilder();

            SqlCommand cmdAdSalesOrders = new SqlCommand(SQL_AD_SALES_ORDERS_PENDING, oConn);
            cmdAdSalesOrders.CommandTimeout = 240;

            List<AdSalesOrder> lstAdSalesOrders = new List<AdSalesOrder>();

            using (SqlDataReader reader = cmdAdSalesOrders.ExecuteReader())
            {
                while (reader.Read())
                {
                    AdSalesOrder oAdSalesOrder = new AdSalesOrder(reader);
                    if (oAdSalesOrder.pract_TermsAmount == 0.0m)
                    {
                        continue;
                    }

                    lstAdSalesOrders.Add(oAdSalesOrder);
                }
            }

            foreach (AdSalesOrder oAdSalesOrder in lstAdSalesOrders)
            {
                //ex: EXEC dbo.usp_PRAd_AR_Data 16828,'D','BBILA'
                SqlCommand cmdARData = new SqlCommand(SQL_AD_AR_DATA, oConn);
                cmdARData.CommandType = CommandType.StoredProcedure;
                cmdARData.CommandTimeout = 240;
                cmdARData.Parameters.AddWithValue("AdCampaignID", oAdSalesOrder.pradc_AdCampaignID);
                cmdARData.Parameters.AddWithValue("AdCampaignType", oAdSalesOrder.pradch_TypeCode);
                cmdARData.Parameters.AddWithValue("AdCampaignPremium", oAdSalesOrder.pradc_Premium);

                string szDescription = oAdSalesOrder.pradch_Name; //default to be overridden

                switch (oAdSalesOrder.pradch_TypeCode)
                {
                    case "BP":
                        //send if approved
                        if (oAdSalesOrder.pradc_CreativeStatus == "A")
                        {
                            szDescription = oAdSalesOrder.pract_InvoiceDescription; //string.Format("{0}", string.Format("{0} Blueprints Ad", oAdSalesOrder.pradc_BluePrintsEdition_Capt));
                        }
                        else
                            continue;

                        break;
                    case "KYC":
                        // Send invoice two days after the digital ad start date and both the print and digital ads are approved by customer.
                        // Invoice Premium ads on the 10th of November after the print KYC Guide is mailed.
                        // RGAD and RGADPREM codes
                        if (oAdSalesOrder.pradc_CreativeStatus == "A" && oAdSalesOrder.pradc_CreativeStatusPrint == "A")
                            if (oAdSalesOrder.pradc_Premium == "Y")
                            {
                                if(string.IsNullOrEmpty(oAdSalesOrder.pradc_KYCCommodityID_Capt))
                                    szDescription = oAdSalesOrder.pract_InvoiceDescription; //string.Format("{0} Prem. Ad", oAdSalesOrder.pradc_KYCEdition_Capt);
                                else
                                    szDescription = oAdSalesOrder.pract_InvoiceDescription;  //string.Format("{0} Prem. Ad:{1}", oAdSalesOrder.pradc_KYCEdition_Capt, oAdSalesOrder.pradc_KYCCommodityID_Capt);
                            }
                            else
                                szDescription = oAdSalesOrder.pract_InvoiceDescription;  //string.Format("{0} Ad:{1}", oAdSalesOrder.pradc_KYCEdition_Capt, oAdSalesOrder.pradc_KYCCommodityID_Capt);
                        else
                            continue;

                        break;
                    case "D":
                        //send 2 days after digital ad start date and digital ad is approved by customer
                        if (oAdSalesOrder.pradc_CreativeStatus == "A")
                        { 
                            cmdARData.Parameters.AddWithValue("AdCampaignSubType", oAdSalesOrder.pradc_AdCampaignTypeDigital);

                            switch(oAdSalesOrder.pradc_AdCampaignTypeDigital)
                            {
                                case "BBILA":
                                    szDescription = oAdSalesOrder.pract_InvoiceDescription; //"BB Insider Leaderboard Ad";
                                    break;
                                default:
                                    szDescription = oAdSalesOrder.pract_InvoiceDescription; //string.Format("{0}", oAdSalesOrder.pradc_AdCampaignTypeDigital_Capt);
                                    break;
                            }
                        }
                        else
                            continue;

                        break;
                    case "TT":
                        // Invoice Premium ads invoice 10th of November after the print KYC Guide is mailed if approved
                        if (oAdSalesOrder.pradc_CreativeStatus == "A")
                        {
                            oAdSalesOrder.pradc_TTEdition_Capt = string.Format("{0} Trading/Transp. Guide Ad", oAdSalesOrder.pradc_TTEdition);
                            szDescription = oAdSalesOrder.pract_InvoiceDescription;  //string.Format("{0}", oAdSalesOrder.pradc_TTEdition_Capt);
                        }
                        else
                            continue;

                        break;
                    default:
                        continue;
                }

                List<AdARData> lstAdARData = new List<AdARData>();
                using (SqlDataReader readerAR = cmdARData.ExecuteReader())
                {
                    while (readerAR.Read())
                    {
                        lstAdARData.Add(new AdARData(readerAR));
                    }
                }

                if (lstAdARData.Count == 0)
                {
                    /* Defect 5703
                        1. Determine if no ad data is returned to include in the file.  In this case, we need to notify the users via email.  
                           Have a separate email address to send the email.The email should include the Company ID.
                        2. In this scenario, do not update the Processed flag on the terms record. 
                    */

                    string szEmail = Utilities.GetConfigValue("AccountingExportBillingTermsErrorEmail", "supportbbos@bluebookservices.com");
                    string szSubject = Utilities.GetConfigValue("AccountingExportBillingTermsErrorSubject", "Billing Terms Processing Error");
                    string szMessageTemplate = Utilities.GetConfigValue("AccountingExportBillingTermsErrorMessage", "Error processing billing terms for ad campaign {0} [{1}], for company ID {2}.  No data returned to create sales order.");
                    string szMessage = string.Format(szMessageTemplate, oAdSalesOrder.pradc_AdCampaignID, oAdSalesOrder.pradch_Name, oAdSalesOrder.pradch_CompanyID);

                    MailAddress oFrom = new MailAddress(Utilities.GetConfigValue("EmailSupportFrom", "bluebookservices@bluebookservices.com"));
                    MailAddress oTo = new MailAddress(szEmail);

                    string szBody = string.Format("From: {0}\nTo: {1}\nSubject: {2}\n\n{3}", oFrom.Address, szEmail, szSubject, szMessage);
                    SendMail(oTo.Address, szSubject, szBody);
                }
                else
                {

                    foreach (AdARData oAdARData in lstAdARData)
                    {
                        sbAdSalesOrders.Append(DELIMITER); //SalesOrder No null
                        sbAdSalesOrders.Append(oAdSalesOrder.pract_BillingDate.ToString("M/d/yyyy")); //m/d/yyyy format
                        sbAdSalesOrders.Append(DELIMITER);
                        sbAdSalesOrders.Append("00");
                        sbAdSalesOrders.Append(DELIMITER);
                        sbAdSalesOrders.Append(oAdARData.CompanyID);
                        //sbAdSalesOrders.Append(DELIMITER);
                        //sbAdSalesOrders.Append("N");
                        //sbAdSalesOrders.Append(DELIMITER);
                        //sbAdSalesOrders.Append("N");
                        sbAdSalesOrders.Append(DELIMITER);
                        sbAdSalesOrders.Append("S");  // Standard Order
                        sbAdSalesOrders.Append(DELIMITER);
                        sbAdSalesOrders.Append("12/31/5999"); //ShipExpireDate
                        sbAdSalesOrders.Append(DELIMITER);
                        sbAdSalesOrders.Append(oAdARData.CompanyID);
                        sbAdSalesOrders.Append(DELIMITER);
                        sbAdSalesOrders.Append("N"); //OrderStatus
                        sbAdSalesOrders.Append(DELIMITER);
                        sbAdSalesOrders.Append(oAdARData.BillToName);
                        sbAdSalesOrders.Append(DELIMITER);
                        sbAdSalesOrders.Append(oAdARData.BillToAddress1);
                        sbAdSalesOrders.Append(DELIMITER);
                        sbAdSalesOrders.Append(oAdARData.BillToAddress2);
                        sbAdSalesOrders.Append(DELIMITER);
                        sbAdSalesOrders.Append(oAdARData.BillToAddress3);
                        sbAdSalesOrders.Append(DELIMITER);
                        sbAdSalesOrders.Append(oAdARData.BillToZipCode);
                        sbAdSalesOrders.Append(DELIMITER);
                        sbAdSalesOrders.Append(oAdARData.BillToCity);
                        sbAdSalesOrders.Append(DELIMITER);
                        sbAdSalesOrders.Append(oAdARData.BillToState);
                        sbAdSalesOrders.Append(DELIMITER);
                        sbAdSalesOrders.Append(oAdARData.BillToCountryCode);
                        sbAdSalesOrders.Append(DELIMITER);
                        sbAdSalesOrders.Append(oAdARData.ShipToName);
                        sbAdSalesOrders.Append(DELIMITER);
                        sbAdSalesOrders.Append(oAdARData.ShipToAddress1);
                        sbAdSalesOrders.Append(DELIMITER);
                        sbAdSalesOrders.Append(oAdARData.ShipToAddress2);
                        sbAdSalesOrders.Append(DELIMITER);
                        sbAdSalesOrders.Append(oAdARData.ShipToAddress3);
                        sbAdSalesOrders.Append(DELIMITER);
                        sbAdSalesOrders.Append(oAdARData.ShipToZipCode);
                        sbAdSalesOrders.Append(DELIMITER);
                        sbAdSalesOrders.Append(oAdARData.ShipToCity);
                        sbAdSalesOrders.Append(DELIMITER);
                        sbAdSalesOrders.Append(oAdARData.ShipToState);
                        sbAdSalesOrders.Append(DELIMITER);
                        sbAdSalesOrders.Append(oAdARData.ShipToCountryCode);
                        sbAdSalesOrders.Append(DELIMITER);
                        sbAdSalesOrders.Append(oAdARData.TaxSchedule);
                        sbAdSalesOrders.Append(DELIMITER);
                        sbAdSalesOrders.Append(oAdARData.BilltoDivisionNo);
                        sbAdSalesOrders.Append(DELIMITER);
                        sbAdSalesOrders.Append(oAdARData.BillToCustomerNo);
                        sbAdSalesOrders.Append(DELIMITER);

                        sbAdSalesOrders.Append(oAdARData.ItemCode);
                        sbAdSalesOrders.Append(DELIMITER);
                        sbAdSalesOrders.Append(oAdARData.ItemType);
                        sbAdSalesOrders.Append(DELIMITER);

                        if (szDescription.Length > 30)
                            szDescription = szDescription.Substring(0, 30); //overridden description 30 chars max
                        sbAdSalesOrders.Append(szDescription);
                        sbAdSalesOrders.Append(DELIMITER);

                        sbAdSalesOrders.Append(oAdARData.StandardUnitOfMeasure);
                        sbAdSalesOrders.Append(DELIMITER);
                        sbAdSalesOrders.Append(oAdARData.CostOfGoodsSoldAcctKey);
                        sbAdSalesOrders.Append(DELIMITER);
                        sbAdSalesOrders.Append(oAdARData.SalesIncomeAcctKey);
                        sbAdSalesOrders.Append(DELIMITER);
                        sbAdSalesOrders.Append(oAdARData.TaxClass);
                        sbAdSalesOrders.Append(DELIMITER);
                        sbAdSalesOrders.Append(oAdARData.QuantityOrdered); //fixed qty 1
                        sbAdSalesOrders.Append(DELIMITER);
                        sbAdSalesOrders.Append(oAdSalesOrder.pract_TermsAmount); //overridden price from terms record
                        sbAdSalesOrders.Append(DELIMITER);
                        sbAdSalesOrders.Append(oAdSalesOrder.pract_TermsAmount); //overridden price from terms record
                        sbAdSalesOrders.Append(DELIMITER);

                        sbAdSalesOrders.Append(Environment.NewLine);
                    }

                    //3.1.1.2.4 Update the PRAdvertisingTerm record setting the Processed Flag = 'Y'.
                    SqlCommand cmdSetProcessed = new SqlCommand("UPDATE PRAdCampaignTerms SET pract_Processed='Y', pract_UpdatedDate=GETDATE(), pract_UpdatedBy=-1  WHERE pract_AdCampaignTermsID = @AdCampaignTermsID", oConn);
                    cmdSetProcessed.CommandType = CommandType.Text;
                    cmdSetProcessed.CommandTimeout = 240;
                    cmdSetProcessed.Parameters.AddWithValue("AdCampaignTermsID", oAdSalesOrder.pract_AdCampaignTermsID);

                    cmdSetProcessed.ExecuteNonQuery();
                }
            }

            WriteFile(sbAdSalesOrders, _OutputFolder, Utilities.GetConfigValue("AdSalesOrderFileName"));
        }

        private const string SQL_UNSUSPEND_COMPANIES =
            @"UPDATE PRCompanyIndicators
               SET prci2_Suspended = NULL,
                   prci2_UpdatedBy = 1,
	               prci2_UpdatedDate = GETDATE()
              FROM PRInvoice
             WHERE prci2_CompanyID = prinv_CompanyID
               AND prci2_Suspended = 'Y'
               AND prinv_PaymentImportedIntoMAS = 'Y'
               AND prinv_PaymentDateTime <= @DateThreshold";
        protected void UnsuspendCompanies(SqlConnection oConn)
        {
            // ACH payments may come in with a payment date of over a week ago.
            DateTime dateThreshold = DateTime.Now.AddHours(0 - Utilities.GetIntConfigValue("StripePaymentUnsuspendThresholdHours", 300));

            SqlCommand sqlCommand = new SqlCommand(SQL_UNSUSPEND_COMPANIES, oConn);
            sqlCommand.Parameters.AddWithValue("DateThreshold", dateThreshold);
            sqlCommand.ExecuteNonQuery();
        }

        private const string SQL_SUSPEND_COMPANIES =
            @"UPDATE PRCompanyIndicators
                   SET prci2_Suspended = 'Y',
                       prci2_UpdatedBy = 1,
	                   prci2_UpdatedDate = GETDATE()
                 WHERE prci2_DoNotSuspend IS NULL
                   AND prci2_Suspended IS NULL
                   AND prci2_CompanyID IN (SELECT ihh.CustomerNo
							                FROM MAS_PRC.dbo.AR_InvoiceHistoryHeader ihh WITH (NOLOCK) 
								                INNER JOIN MAS_PRC.dbo.AR_OpenInvoice oi WITH (NOLOCK) ON ihh.InvoiceNo = oi.InvoiceNo
								                INNER JOIN MAS_PRC.dbo.SO_SalesOrderHistoryHeader sohh WITH (NOLOCK) ON ihh.SalesOrderNo = sohh.SalesOrderNo
								                INNER JOIN CRM.dbo.PRCompanyIndicators WITH (NOLOCK) ON ihh.CustomerNo = prci2_CompanyID
							                WHERE oi.Balance > 0
								                AND sohh.MasterRepeatingOrderNo <> ''
								                AND prci2_DoNotSuspend IS NULL
								                AND ihh.InvoiceDueDate <= @DateThreshold
						                GROUP BY ihh.CustomerNo
						                HAVING SUM(oi.Balance) > 0)";

        protected void SuspendCompanies(SqlConnection oConn)
        {
            DateTime dateThreshold = DateTime.Today.AddDays(0 - Utilities.GetIntConfigValue("StripePaymentSuspendThresholdDays", 35));

            SqlCommand sqlCommand = new SqlCommand(SQL_SUSPEND_COMPANIES, oConn);
            sqlCommand.Parameters.AddWithValue("DateThreshold", dateThreshold);
            sqlCommand.ExecuteNonQuery();
        }
    }
}
