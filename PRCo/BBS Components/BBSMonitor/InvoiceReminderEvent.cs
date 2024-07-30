/***********************************************************************
 Copyright Blue Book Services, Inc. 2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: InvoiceReminderEvent.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.IO;
using System.Timers;
using TSI.Utils;
using Stripe;
using PRCo.BBS.CRM;

namespace PRCo.BBS.BBSMonitor
{
    public class InvoiceReminderEvent : BBSMonitorEvent
    {
        /// <summary>
        /// Initializes the service setting up the logger, timer,
        /// etc.
        /// </summary>
        override public void Initialize(int iIndex)
        {
            _szName = "InvoiceReminderEvent";

            base.Initialize(iIndex);

            try
            {
                // Defaults to 24 hours.  Value is in minutes.
                _lEventInterval = Convert.ToInt64(Utilities.GetIntConfigValue("InvoiceReminderEventInterval", 1440)) * ONE_MINUTE_IN_MILLISECONDS;
                _oLogger.LogMessage("InvoiceReminderEvent Interval: " + _lEventInterval.ToString());

                _dtStartDateTime = Convert.ToDateTime(Utilities.GetConfigValue("InvoiceReminderEventStartDateTime"));
                _dtNextDateTime = _dtStartDateTime;

                _oEventTimer = new Timer();
                _oEventTimer.Elapsed += new ElapsedEventHandler(this.ProcessTick);
                ConfigureTimer(false);

                _oLogger.LogMessage("InvoiceReminderEvent Start: " + _dtNextDateTime.ToString());

            }
            catch (Exception e)
            {
                LogEventError("Error initializing InvoiceReminderEvent event.", e);
                throw;
            }
        }

        bool hasErrors = false;

        override public void ProcessEvent()
        {
            DateTime dtExecutionStartDate = DateTime.Now;

            try
            {
                hasErrors = false;
                StringBuilder output = new StringBuilder();
                ProcessReminders(2, output);
                ProcessReminders(1, output);

                if (Utilities.GetBoolConfigValue("InvoiceReminderEventWriteResultsToEventLog", true))
                    _oBBSMonitorService.LogEvent($"Invoice Reminder Event Executed Successfully.{Environment.NewLine}{Environment.NewLine}{output}");

                if (hasErrors || (Utilities.GetBoolConfigValue("InvoiceReminderEventSendResultsToSupport", false)))
                    SendMail("Invoice Reminder Event", $"Invoice Reminder Executed Successfully.{Environment.NewLine}{Environment.NewLine}" + output);


           } catch (Exception e) {
                // This logs the error in the Event Log, Trace File,
                // and sends the appropriate email.
                LogEventError("Error Procesing Invoice Reminder Event.", e);
            }
        }

        private const string SQL_INVOICE_REMINDERS =
            @"SELECT * FROM (
			SELECT DISTINCT prinv_CompanyID, prinv_InvoiceNbr, ihh.InvoiceDate, ihh.InvoiceDueDate, comp_PRCommunicationLanguage, comp_PRIndustryType, EmailAddress, FaxNo, SalesTaxAmt, Total, Balance,
                              HasAdvertisingItemCode, ContactName,
				              'AttnName' = CASE WHEN (prattn_PersonID IS NULL AND prattn_CustomLine IS NULL) THEN ContactName ELSE 'Attn: ' + ISNULL(prattn_CustomLine, dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, null, pers_Suffix)) END,
                              {1}, prci2_StripeCustomerId, prse_NextAnniversaryDate,
                              BillToName, BillToAddress1, BillToAddress2, BillToCity, BillToState, BillToZipCode, 
							  ROW_NUMBER() OVER (PARTITION BY prinv_InvoiceNbr ORDER BY prinv_InvoiceID DESC) RowNum
                FROM PRInvoice WITH (NOLOCK)
                     INNER JOIN MAS_PRC.dbo.vBBSiMasterInvoices ihh WITH (NOLOCK) ON prinv_InvoiceNbr = ihh.UDF_MASTER_INVOICE
	                 INNER JOIN Company WITH (NOLOCK) ON Comp_CompanyId = prinv_CompanyID
	                 LEFT OUTER JOIN PRAttentionLine WITH (NOLOCK) ON prattn_CompanyID = prinv_CompanyID AND prattn_ItemCode = 'ADVBILL' 
	                 LEFT OUTER JOIN vPerson pers WITH (NOLOCK) ON pers.Pers_PersonId = prattn_PersonID
                     LEFT OUTER JOIN PRService ON comp_CompanyID = prse_CompanyID AND prse_Primary='Y' 
               WHERE prinv_PaymentImportedIntoMAS IS NULL
                 AND {0} IS NULL
                 AND prinv_InvoiceNbr IN (
				                SELECT UDF_MASTER_INVOICE
				                  FROM MAS_PRC.dbo.AR_InvoiceHistoryHeader ihh WITH (NOLOCK) 
					                   INNER JOIN MAS_PRC.dbo.AR_OpenInvoice oi WITH (NOLOCK) ON ihh.InvoiceNo = oi.InvoiceNo
				                 GROUP BY UDF_MASTER_INVOICE
				                HAVING SUM(oi.Balance) > 0
				                   AND MAX(ihh.InvoiceDate) <= @ThresholdDate)
                 AND EmailAddress <> ''
            ) T1
			WHERE RowNum=1
			ORDER BY prinv_CompanyID";

        private void ProcessReminders(int reminderType, StringBuilder output)
        {
            string reminderField = "prinv_FirstReminderDate";
            string stripePaymentClause = "prinv_StripePaymentURL";
            DateTime thresholdDate = DateTime.Today.AddDays(0 - Utilities.GetIntConfigValue($"InvoiceReminder1DaysOld", 15));

            string subject = null;
            string subjectEnglish = Utilities.GetConfigValue($"InvoiceReminder1EmailSubject", "Friendly Reminder - Blue Book Services");
            string subjectSpanish = Utilities.GetConfigValue($"InvoiceReminder1EmailSubject_S", "Recordatorio Amistoso - Blue Book Services");


            if (reminderType == 2)
            {
                reminderField = "prinv_SecondReminderDate";
                stripePaymentClause = "'' AS prinv_StripePaymentURL";
                thresholdDate = DateTime.Today.AddDays(0 - Utilities.GetIntConfigValue("InvoiceReminder2DaysOld", 50));

                subjectEnglish = Utilities.GetConfigValue("InvoiceReminder2EmailSubject", "Final Reminder - Blue Book Services");
                subjectSpanish = Utilities.GetConfigValue("InvoiceReminder2EmailSubject_S", "Recordatorio Final - Blue Book Services");
            }

            // Setup our supporting files, etc.
            string invoiceBody = null;
            string invoiceTemplate = GetEmailTemplate($"InvoiceReminder_{reminderType}.html");
            string invoiceTemplateSpanish = GetEmailTemplate($"InvoiceReminder_{reminderType}_S.html");

            string emailBody = null;
            int invoiceCount = 0;

            string invoiceNbr = null;
            DateTime invoiceDate;
            DateTime dueDate;
            int customerNo = 0;
            string language = null;
            decimal salesTaxAmt = 0;
            decimal total = 0;
            decimal balance = 0;
            string stripeURL = null;
            string culture = null;
            string stripeCustomerID = null;

            // Used for debugging.
            int maxCount = Utilities.GetIntConfigValue("InvoiceReminderMaxCount", 99999);

            int maxErrorCount = Utilities.GetIntConfigValue("InvoiceReminderMaxErrorCount", 10);
            int errorCount = 0;
            List<string> errors = new List<string>();

            using (SqlConnection oConn = new SqlConnection(GetConnectionString())) {

                oConn.Open();

                using (SqlConnection oConn2 = new SqlConnection(GetConnectionString())) {
                    oConn2.Open();

                    string sql = string.Format(SQL_INVOICE_REMINDERS, reminderField, stripePaymentClause);
                    SqlCommand cmdInvoices = new SqlCommand(sql, oConn);
                    cmdInvoices.CommandTimeout = Utilities.GetIntConfigValue("ReaderTimeout", 600);
                    cmdInvoices.Parameters.AddWithValue("ThresholdDate", thresholdDate);

                    using (SqlDataReader drInvoices = cmdInvoices.ExecuteReader())
                    {
                        while (drInvoices.Read())
                        {
                            if (invoiceCount >= maxCount)
                                break;

                            try
                            {
                                invoiceCount++;
                                emailBody = null;

                                invoiceNbr = (string)drInvoices["prinv_InvoiceNbr"];
                                invoiceDate = (DateTime)drInvoices["InvoiceDate"];
                                dueDate = (DateTime)drInvoices["InvoiceDueDate"];
                                customerNo = (Int32)drInvoices["prinv_CompanyID"];
                                language = (string)drInvoices["comp_PRCommunicationLanguage"];
                                salesTaxAmt = (decimal)drInvoices["SalesTaxAmt"];
                                total = (decimal)drInvoices["Total"];
                                balance = (decimal)drInvoices["Balance"];

                                stripeCustomerID = null;
                                if (drInvoices["prci2_StripeCustomerId"] != DBNull.Value)
                                    stripeCustomerID = (string)drInvoices["prci2_StripeCustomerId"];

                                stripeURL = null;
                                if (drInvoices["prinv_StripePaymentURL"] != DBNull.Value)
                                    stripeURL = (string)drInvoices["prinv_StripePaymentURL"];

                                if ((reminderType == 2) ||
                                    (string.IsNullOrEmpty(stripeURL)))
                                    stripeURL = GetStripeHostedURL(oConn2, stripeCustomerID, Convert.ToString(customerNo), drInvoices);

                                SqlCommand cmdCreateEmail = new SqlCommand("usp_CreateEmail", oConn2);
                                cmdCreateEmail.CommandType = CommandType.StoredProcedure;
                                cmdCreateEmail.CommandTimeout = 90;
                                cmdCreateEmail.Parameters.AddWithValue("CreatorUserId", 1);
                                cmdCreateEmail.Parameters.AddWithValue("RelatedCompanyId", customerNo);
                                cmdCreateEmail.Parameters.AddWithValue("DoNotRecordCommunication", Utilities.GetConfigValue("InvoiceReminderDoNotRecordCommunication", "0"));
                                cmdCreateEmail.Parameters.AddWithValue("Source", "Invoice Reminder");
                                cmdCreateEmail.Parameters.AddWithValue("Content_Format", "HTML");
                                cmdCreateEmail.Parameters.AddWithValue("ProfileName", Utilities.GetConfigValue("InvoiceReminderEmailProfile", "BBS Billing"));

                                cmdCreateEmail.Parameters.AddWithValue("@To", (string)drInvoices["EmailAddress"]);
                                cmdCreateEmail.Parameters.AddWithValue("@Action", "EmailOut");

                                string paymentButton = GetPaymentButton(language, stripeURL);

                                string szOverrideAddressee;
                                if ((int)drInvoices["HasAdvertisingItemCode"] == 1 && !String.IsNullOrEmpty((string)drInvoices["AttnName"]))
                                    szOverrideAddressee = (string)drInvoices["AttnName"];
                                else
                                    szOverrideAddressee = (string)drInvoices["ContactName"];

                                string invoiceDetails = GetInvoiceForEmail(oConn2, invoiceNbr, invoiceDate, dueDate, salesTaxAmt, total, balance);
                                string downloadURL = GetInvoiceDownloadURL(oConn2, invoiceNbr);

                                switch (language)
                                {
                                    case "S":
                                        subject = subjectSpanish;
                                        invoiceBody = string.Format(invoiceTemplateSpanish, paymentButton, invoiceDetails, downloadURL);
                                        culture = "es-mx";
                                        break;

                                    default:
                                        subject = subjectEnglish;
                                        invoiceBody = string.Format(invoiceTemplate, paymentButton, invoiceDetails, downloadURL);
                                        culture = "en-us";
                                        break;

                                }

                                emailBody = GetFormattedEmail(oConn2,
                                                                customerNo,
                                                                subject,
                                                                invoiceBody,
                                                                szOverrideAddressee,
                                                                culture);

                                cmdCreateEmail.Parameters.AddWithValue("Content", emailBody);
                                cmdCreateEmail.Parameters.AddWithValue("Subject", subject);
                                cmdCreateEmail.ExecuteNonQuery();

                                UpdateInvoice(oConn2, invoiceNbr, reminderField);

                            }
                            catch (Exception eX)
                            {
                                hasErrors = true;
                                errors.Add($"BBID {customerNo} Invoice {invoiceNbr} - {eX.Message} {eX.StackTrace}");

                                LogEventError($"BBID {customerNo} Invoice {invoiceNbr}", eX);

                                errorCount++;
                                if (errorCount >= maxErrorCount)
                                    throw new ApplicationException($"Too many exceptions: {errorCount}");
                            }

                        }

                    }
                }
            }

            output.Append($"{invoiceCount} type {reminderType} reminders sent.{Environment.NewLine}");
            if (errorCount > 0)
            {
                output.Append($"{errorCount} companies had errors:{Environment.NewLine}");
                foreach(string error in errors) {
                    output.Append($" - {error}{Environment.NewLine}");
                }
            }

            output.Append(Environment.NewLine);
        }

        protected string GetPaymentButton(string language, string paymentURL)
        {
            string culture = "en-us";
            if (language == "S")
                culture = "es-mx";

            return $"<a href=\"{paymentURL}\"><img src=\"https://apps.bluebookservices.com/BBOS/{culture}/images/Pay-Now.png\" border=\"0\" align=\"center\" /></a>";
        }

        private string SQL_INVOICE_DETAILS =
           @"SELECT ihh.UDF_MASTER_INVOICE, ihh.CustomerNo, PRCompanySearch.prcse_FullName AS ServiceLocation, ihd.ItemCodeDesc, ExtensionAmt,
                    QuantityOrdered, ItemCodeDesc, ISNULL(prod_PRRecurring,'') IsRecognition,
                    PRCompanySearch.prcse_FullName AS ServiceLocation,
		            ISNULL(LAG(PRCompanySearch.prcse_FullName, 1) OVER(ORDER BY UDF_MASTER_INVOICE, ISNULL(T1.PrimarySort, 9999), ShipToState, ShipToCity, DetailSeqNo), '') ServiceLocation_Prev,
                    ISNULL(T1.PrimarySort, 9999) PrimarySort, ShipToState, ShipToCity, DetailSeqNo
               FROM MAS_PRC.dbo.AR_InvoiceHistoryHeader ihh WITH (NOLOCK) 
                    INNER JOIN MAS_PRC.dbo.AR_InvoiceHistoryDetail ihd WITH (NOLOCK) ON ihh.InvoiceNo = ihd.InvoiceNo AND ihh.HeaderSeqNo = ihd.HeaderSeqNo
 	                INNER JOIN PRCompanySearch WITH (NOLOCK) ON PRCompanySearch.prcse_CompanyId = CustomerNo
                    INNER JOIN CRM.dbo.Company WITH (NOLOCK) ON Comp_CompanyId = prcse_CompanyId
                    INNER JOIN CRM.dbo.vPRLocation ON comp_PRListingCityID = prci_CityID
                    LEFT OUTER JOIN NewProduct  WITH (NOLOCK) ON prod_code = ItemCode AND prod_PRRecurring='Y' AND Prod_ProductID <> 85 -- Exclude the old L100 code
                    LEFT OUTER JOIN (
			            SELECT DISTINCT CustomerNo As PrimaryCompanyID, 1 as PrimarySort
			              FROM MAS_PRC.dbo.AR_InvoiceHistoryHeader ihh WITH (NOLOCK)
				               INNER JOIN MAS_PRC.dbo.AR_InvoiceHistoryDetail ihd WITH (NOLOCK) ON ihh.InvoiceNo = ihd.InvoiceNo AND ihh.HeaderSeqNo = ihd.HeaderSeqNo 
				               INNER JOIN MAS_PRC.dbo.CI_Item ON ihd.ItemCode = CI_Item.ItemCode
			             WHERE Category2 = 'PRIMARY') T1 ON CustomerNo = PrimaryCompanyID
              WHERE UDF_MASTER_INVOICE = @InvoiceNbr 
                AND ExplodedKitItem <> 'C'
           ORDER BY ihh.UDF_MASTER_INVOICE, ISNULL(T1.PrimarySort, 9999), ShipToState, ShipToCity, DetailSeqNo";



        protected DataView _dvInvoiceDetails = null;
        protected string  _invoiceNbr = string.Empty;

        protected DataRowView[] GetInvoiceDetails(SqlConnection sqlConnection, string invoiceNumber)
        {
            if (invoiceNumber != _invoiceNbr)
            {
                SqlDataAdapter adapter = new SqlDataAdapter(SQL_INVOICE_DETAILS, sqlConnection);
                adapter.SelectCommand.CommandTimeout = 180;
                adapter.SelectCommand.Parameters.AddWithValue("InvoiceNbr", invoiceNumber);

                DataSet ds = new DataSet();
                adapter.Fill(ds);

                _dvInvoiceDetails = new DataView(ds.Tables[0]);
                _dvInvoiceDetails.Sort = "UDF_MASTER_INVOICE";
                _invoiceNbr = invoiceNumber;
            }

            DataRowView[] adrRows = _dvInvoiceDetails.FindRows(invoiceNumber);
            return adrRows;
        }

        protected string GetInvoiceForEmail(SqlConnection sqlConnection, string invoiceNumber, DateTime invoiceDate, DateTime dueDate, decimal salesTaxAmt, decimal total, decimal balance, string journalBatchNo = null)
        {
            StringBuilder emailDetails = new StringBuilder();

            string custommerNo = string.Empty;

            DataRowView[] adrRows = GetInvoiceDetails(sqlConnection, invoiceNumber);
            foreach (DataRowView drRow in adrRows)
            {
                if (custommerNo != drRow[1].ToString())
                {
                    emailDetails.Append($"<tr><td colspan=4 class=bbsBottomBorder><strong>{drRow[2]}</strong></td></tr>");
                    custommerNo = drRow[1].ToString();
                }

                emailDetails.Append($"<tr><td>{drRow[3].ToString()}</td><td align=right>{Convert.ToDecimal(drRow[4]):c}</td></tr>");
            }

            string emailBody = string.Empty;
            string emailTemplate = GetEmailTemplate("InvoiceInfoHeader.html");

            string[] args = { invoiceNumber,
                                invoiceDate.ToShortDateString(),
                                dueDate.ToShortDateString(),
                                total.ToString("c"),
                                emailDetails.ToString(),
                                balance.ToString("c"),
                                salesTaxAmt.ToString("c"),
                                balance.ToString("c") };

            emailBody = string.Format(emailTemplate, args);
            return emailBody;
        }

        private const string SQL_GET_INVOICE_DOWNLOAD_URL =
            @"SELECT TOP 1 prinv_PaymentURLKey
                FROM PRInvoice WITH (NOLOCK)
               WHERE prinv_InvoiceNbr = @InvoiceNbr
            ORDER BY prinv_CreatedDate DESC";

        private static string bbosURL = null;

        protected string GetInvoiceDownloadURL(SqlConnection sqlConnection, string invoiceNumber)
        {
            if (bbosURL == null)
            {
                string szSQL = "SELECT dbo.ufn_GetCustomCaptionValue('BBOS', 'URL', 'en-us')";
                SqlCommand cmdBBOSURL = new SqlCommand(szSQL, sqlConnection);
                bbosURL = (string)cmdBBOSURL.ExecuteScalar();
            }

            SqlCommand cmdMostRecentURL = new SqlCommand(SQL_GET_INVOICE_DOWNLOAD_URL, sqlConnection);
            cmdMostRecentURL.Parameters.AddWithValue("InvoiceNbr", invoiceNumber);

            using (IDataReader reader = cmdMostRecentURL.ExecuteReader(CommandBehavior.Default))
            {
                if (reader.Read())
                    return $"{bbosURL}/PI.aspx?k={reader.GetString(0)}&a=d";
            }

            return null;
        }

        protected void UpdateInvoice(SqlConnection sqlConnection, string invoiceNbr, string reminderField)
        {
            string sql = $"UPDATE PRInvoice SET {reminderField}=GETDATE(), prinv_UpdatedBy=1, prinv_UpdatedDate=GETDATE() WHERE prinv_InvoiceNbr='{invoiceNbr}'";
            SqlCommand cmdUpdateInvoice = new SqlCommand(sql, sqlConnection);
            cmdUpdateInvoice.ExecuteNonQuery();
        }

        public const string PRINV_SENT_METHOD_CODE_EMAIL = "E";
        public const string PRINV_SENT_METHOD_CODE_FAX = "F";
        public const string PRINV_SENT_METHOD_CODE_MAIL = "M";

        protected string GetStripeHostedURL(SqlConnection sqlConnection, string stripeCustomerId, string customerNo, IDataReader drInvoices)
        {
            int _iUserID = 0;

            if (stripeCustomerId == null)
            {
                //Create a stripe customer
                StripeError stripeCustomerError;
                Customer stripeCustomer = PRCo.BBS.CRM.Stripe.Customer_Create(customerNo,
                                                    (string)drInvoices["BillToName"],
                                                    (string)drInvoices["BillToAddress1"],
                                                    (string)drInvoices["BillToAddress2"],
                                                    (string)drInvoices["BillToCity"],
                                                    (string)drInvoices["BillToState"],
                                                    (string)drInvoices["BillToZipCode"],
                                                    "", //TODO:JMT phone from where??
                                                    (string)drInvoices["EmailAddress"],
                                                    out stripeCustomerError);

                if (stripeCustomerError != null)
                    throw new Exception(stripeCustomerError.Message);

                PRCo.BBS.CRM.Stripe.StripeCustomerId_Update(customerNo, stripeCustomer.Id, _iUserID, sqlConnection);
                stripeCustomerId = stripeCustomer.Id;
            }

            DateTime? nextAnniversaryDate = null;
            if (drInvoices["prse_NextAnniversaryDate"] != DBNull.Value)
                nextAnniversaryDate = Convert.ToDateTime(drInvoices["prse_NextAnniversaryDate"]);

            decimal salesTaxAmt = (decimal)drInvoices["SalesTaxAmt"];
            DataRowView[] drvDetails = GetInvoiceDetails(sqlConnection, (string)drInvoices["prinv_InvoiceNbr"]);

            //Create stripe invoice
            StripeError stripeInvoiceError;
            Invoice stripeInvoice = PRCo.BBS.CRM.Stripe.Invoice_Create(stripeCustomerId, customerNo, (string)drInvoices["prinv_InvoiceNbr"], nextAnniversaryDate, salesTaxAmt, drvDetails, out stripeInvoiceError);
            if (stripeInvoiceError != null)
                throw new Exception(stripeInvoiceError.Message);

            //Create PRInvoice record
            string szSentMethodCode = "";
            if (!string.IsNullOrEmpty((string)drInvoices["EmailAddress"]))
                szSentMethodCode = PRINV_SENT_METHOD_CODE_EMAIL;
            else if (!string.IsNullOrEmpty((string)drInvoices["FaxNo"]))
                szSentMethodCode = PRINV_SENT_METHOD_CODE_FAX;

            PRCo.BBS.CRM.Stripe.PRInvoice_Insert(customerNo,
                                                (string)drInvoices["prinv_InvoiceNbr"],
                                                szSentMethodCode,
                                                DateTime.Now,
                                                stripeInvoice.HostedInvoiceUrl,
                                                stripeInvoice.Id,
                                                _iUserID, 
                                                sqlConnection);

            return stripeInvoice.HostedInvoiceUrl;
        }

        private const string SQL_GET_FORMATTED_EMAIL = "SELECT dbo.ufn_GetFormattedEmail3(@CompanyID, @PersonID, 0, @Subject, @Text, @AddresseeOverride, @Culture, null, null, null)";
        protected string GetFormattedEmail(SqlConnection oConn, int companyID, string subject, string Text, string overrideAddressee, string culture)
        {
            SqlCommand oDBCommand = new SqlCommand(SQL_GET_FORMATTED_EMAIL, oConn);
            oDBCommand.Parameters.AddWithValue("CompanyID", companyID);
            oDBCommand.Parameters.AddWithValue("PersonID", 0);
            oDBCommand.Parameters.AddWithValue("Subject", subject);
            oDBCommand.Parameters.AddWithValue("Text", Text);
            oDBCommand.Parameters.AddWithValue("Culture", culture);
            oDBCommand.Parameters.AddWithValue("AddresseeOverride", overrideAddressee);

            object oValue = oDBCommand.ExecuteScalar();
            return ((string)oValue);
        }
    }
}
