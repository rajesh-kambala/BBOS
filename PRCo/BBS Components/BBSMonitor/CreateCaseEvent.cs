/***********************************************************************
 Copyright Blue Book Services, Inc. 2011-2015

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CreateCaseEvent.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Timers;
using TSI.Utils;

namespace PRCo.BBS.BBSMonitor
{
    public class CreateCaseEvent : BBSMonitorEvent
    {

        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex)
        {
            _szName = "CreateCaseEvent";

            base.Initialize(iIndex);

            try
            {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("CreateCaseInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("CreateCaseNumeral Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("CreateCaseStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("CreateCase Start: " + _dtNextDateTime.ToString());

            }
            catch (Exception e)
            {
                LogEventError("Error initializing CreateCase event.", e);
                throw;
            }
        }

        protected const string SQL_SELECT_INVOICES =
          @"SELECT DISTINCT
                   CAST(CASE WHEN ihh.BillToCustomerNo = '' THEN ihh.CustomerNo ELSE ihh.BillToCustomerNo END As INT) As CompanyID,
                   UDF_MASTER_INVOICE,
                   ihh.InvoiceDate,
                   prattn_PersonID,
                   prattn_CustomLine
              FROM MAS_PRC.dbo.AR_OpenInvoice oi
                   INNER JOIN MAS_PRC.dbo.AR_InvoiceHistoryHeader ihh ON oi.InvoiceNo = ihh.InvoiceNo
                   LEFT OUTER JOIN CRM.dbo.PRAttentionLine WITH (NOLOCK) ON CAST(CASE WHEN ihh.BillToCustomerNo = '' THEN ihh.CustomerNo ELSE ihh.BillToCustomerNo END As INT) = prattn_CompanyID AND prattn_ItemCode = 'BILL'
             WHERE Balance > 0
               AND ihh.InvoiceDate < DATEADD(DAY, {0}, GETDATE())	
               AND UDF_MASTER_INVOICE NOT IN (SELECT case_PRMasterInvoiceNumber FROM CRM.dbo.Cases WITH (NOLOCK) WHERE case_PRMasterInvoiceNumber IS NOT NULL)";

        /// <summary>
        /// 
        /// </summary>
        override public void ProcessEvent()
        {
            DateTime dtExecutionStartDate = DateTime.Now;
            int caseCount = 0;
            int closeCount = 0;

            StringBuilder sbMsg = new StringBuilder();
            SqlConnection oConn = new SqlConnection(GetConnectionString());

            string invoiceNumber = string.Empty;
            object personID = null;
            object customLine = null;

            try
            {
                oConn.Open();

                // First close any cases that now have a zero balance.
                SqlCommand closeCommand = new SqlCommand("usp_ClosePendingCases", oConn);
                closeCommand.CommandType = CommandType.StoredProcedure;
                closeCount = closeCommand.ExecuteNonQuery();


                string sql = string.Format(SQL_SELECT_INVOICES, 0 - Utilities.GetIntConfigValue("CreateCaseInvoiceThrehsold", 45));
                _oLogger.LogMessage(sql);
                SqlCommand oSQLCommand = new SqlCommand(sql, oConn);
                using (IDataReader reader = oSQLCommand.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        // We may get multiple records per master invoice.
                        // In that case, processing the first one found is
                        // sufficient.  
                        if (invoiceNumber != reader.GetString(1)) {
                            caseCount++;

                            int companyID = reader.GetInt32(0);
                           
                            invoiceNumber = reader.GetString(1);
                            personID = reader[3];
                            customLine = reader[4];

                            InsertCase(companyID, personID, customLine, invoiceNumber);

                            sbMsg.Append(companyID.ToString() + Environment.NewLine);
                        }
                    }
                }

                if (caseCount > 0)
                {
                    sbMsg.Insert(0, string.Format("Created {0} new cases for the following company IDs:" + Environment.NewLine + Environment.NewLine, caseCount));
                }

                if (closeCount > 0)
                {
                    sbMsg.Insert(0, string.Format("Closed {0} cases that now have a zero balance." + Environment.NewLine + Environment.NewLine, closeCount));
                }


                if (Utilities.GetBoolConfigValue("CreateCaseWriteResultsToEventLog", true))
                {
                    _oBBSMonitorService.LogEvent("CreateCase Executed Successfully.");
                }

                if (Utilities.GetBoolConfigValue("CreateCaseSendResultsToSupport", false))
                {
                    if (sbMsg.Length > 0)
                    {
                        SendMail("Create Case Success", sbMsg.ToString());
                    }
                }

            }
            catch (Exception e)
            {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error Procesing CreateCase Event.", e);
            }
            finally
            {
                if (oConn != null)
                {
                    oConn.Close();
                }

                oConn = null;
            }
        }

        private const string SQL_INSERT_CASE =
            @"INSERT INTO CASES (case_CaseId, case_AssignedUserId, case_ChannelId, case_PrimaryCompanyID, case_PrimaryPersonID, case_PRAltContactName, case_PRMasterInvoiceNumber, case_Opened, case_Status, case_CreatedBy, case_CreatedDate, case_UpdatedBy, case_UpdatedDate, case_Timestamp) 
                        VALUES (@CaseID, @AssignedUserID, @ChannelID, @CompanyID, @PersonID, @AltContactName, @InvoiceNumber, GETDATE(), @Status, -1, GETDATE(), -1, GETDATE(), GETDATE());";
        protected void InsertCase(int companyID,
                                  object personID,
                                  object altContact,
                                  string invoiceNumber)
        {

            SqlConnection oConn = new SqlConnection(GetConnectionString());
            oConn.Open();

            try
            {
                int recordID = GetRecordID(oConn, "Cases", null);

                SqlCommand commandInsertCase = new SqlCommand(SQL_INSERT_CASE, oConn);
                commandInsertCase.Parameters.AddWithValue("CaseID", recordID);
                commandInsertCase.Parameters.AddWithValue("CompanyID", companyID);
                commandInsertCase.Parameters.AddWithValue("InvoiceNumber", invoiceNumber);
                commandInsertCase.Parameters.AddWithValue("AssignedUserID", Utilities.GetIntConfigValue("CreateCaseDefaultUserID", 1027));
                commandInsertCase.Parameters.AddWithValue("ChannelID", Utilities.GetIntConfigValue("CreateCaseChannelID", 14));
                commandInsertCase.Parameters.AddWithValue("Status", Utilities.GetConfigValue("CreateCaseStatus", "Open"));

                if ((personID == null) ||
                    (personID == DBNull.Value))
                {
                    commandInsertCase.Parameters.AddWithValue("PersonID", DBNull.Value);
                }
                else
                {
                    commandInsertCase.Parameters.AddWithValue("PersonID", personID);
                }


                if ((altContact == null) ||
                    (altContact == DBNull.Value))
                {
                    commandInsertCase.Parameters.AddWithValue("AltContactName", DBNull.Value);
                }
                else
                {
                    commandInsertCase.Parameters.AddWithValue("AltContactName", altContact);
                }

                commandInsertCase.ExecuteNonQuery();
            }
            finally
            {
                if (oConn != null)
                {
                    oConn.Close();
                }

                oConn = null;
            }
        }
    }
}
