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

 ClassName: GenerateInvoices.aspx
 Description:	

 Notes:

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;

using ICSharpCode.SharpZipLib.Zip;
using Stripe;

namespace PRCo.BBS.CRM
{
    public partial class GenerateInvoices : PageBase
    {
        protected string sSID = string.Empty;
        protected int _iUserID;

        protected int _usaCount = 0;
        protected int _canadaCount = 0;
        protected int _mexicoCount = 0;
        protected int _otherCount = 0;

        protected decimal _usaTotal = 0;
        protected decimal _canadaTotal = 0;
        protected decimal _mexicoTotal = 0;
        protected decimal _otherTotal = 0;

        override protected void Page_Load(object sender, EventArgs e)
        {
            //Server.ScriptTimeout = 60 * (60 * 8);
            Server.ScriptTimeout = 60 * GetConfigValue("GenerateInvoicesScriptTimeoutMinutes", 360);
            base.Page_Load(sender, e);

            lblMsg.Text = string.Empty;

            if (!IsPostBack)
            {
                hidUserID.Text = Request["user_userid"];
                hidSID.Text = Request["SID"];

                PopulateForm();
            }
        }

        protected const string SQL_SELECT_INVOICE_BATCHES =
            @"SELECT DISTINCT TOP({0}) JournalNoGLBatchNo, InvoiceDate, MAX(TimeCreated) TimeCreated, JournalNoGLBatchNo + ' - '  + FORMAT(InvoiceDate, 'MM/dd/yyyy') + ' ' + MAX(TimeCreated) + ' - ' + CAST(COUNT(DISTINCT UDF_MASTER_INVOICE) As Varchar) + ' Invoices' As Label 
               FROM MAS_PRC.dbo.AR_InvoiceHistoryHeader
              WHERE InvoiceType = 'IN'
           GROUP BY JournalNoGLBatchNo, InvoiceDate
           ORDER BY InvoiceDate DESC, JournalNoGLBatchNo DESC";

        protected void PopulateForm()
        {
            string sql = string.Format(SQL_SELECT_INVOICE_BATCHES, GetConfigValue("GenerateInvoicesBatchCount", 10));
            SqlCommand cmdInvoiceBatches = new SqlCommand(sql, GetDBConnnection());

            ddlMailBatchList.DataTextField = "Label";
            ddlMailBatchList.DataValueField = "JournalNoGLBatchNo";
            using (IDataReader drCustomCaption = cmdInvoiceBatches.ExecuteReader(CommandBehavior.Default))
            {
                ddlMailBatchList.DataSource = drCustomCaption;
                ddlMailBatchList.DataBind();
            }

            ddlElectronicBatchList.DataTextField = "Label";
            ddlElectronicBatchList.DataValueField = "JournalNoGLBatchNo";
            using (IDataReader drCustomCaption = cmdInvoiceBatches.ExecuteReader(CommandBehavior.Default))
            {
                ddlElectronicBatchList.DataSource = drCustomCaption;
                ddlElectronicBatchList.DataBind();
            }
        }

        protected void btnGenerateExportFilesClick(object sender, EventArgs e)
        {
            GenerateExportFile(false);
        }

        protected void btnGenerateSendExportFilesClick(object sender, EventArgs e)
        {
            GenerateExportFile(true);
        }

        protected void btnGenerateEmailFaxInvoicesClick(object sender, EventArgs e)
        {
            GenerateElectronicInvoices(false);
        }

        protected void btnGenerateSendEmailFaxInvoicesClick(object sender, EventArgs e)
        {
            GenerateElectronicInvoices(true);
        }

        protected void GenerateElectronicInvoices(bool send) {
            string inclusionType = Request["ddlInclusionType"];

            int maxInvoices = 99999;
            Int32.TryParse(Request["txtMaxInvoices"], out maxInvoices);

            GenerateElectronicInvoices(send, maxInvoices, inclusionType);
        }

        protected const string SQL_BASE_SELECT =
            @"SELECT TOP({3}) vBBSiMasterInvoices.*, HasLineItemDiscounts, comp_PRCommunicationLanguage,
                    prfs_StatementDate, prfs_sales,
				    PrimaryServiceDiscount,
				    comp_PRIndustryType,
                    vprl.prcn_CountryId,
					'AttnName' = CASE WHEN (prattn_PersonID IS NULL AND prattn_CustomLine IS NULL) THEN ContactName ELSE 'Attn: ' + ISNULL(prattn_CustomLine, dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, null, pers_Suffix)) END,
                    Balance, SalesTaxAmt, Total,
                    prse_NextAnniversaryDate,
                    prci2_StripeCustomerId
                FROM MAS_PRC.dbo.vBBSiMasterInvoices 
                     INNER JOIN Company WITH (NOLOCK) ON CAST(BillToCustomerNo As Int) = comp_CompanyID
                     LEFT OUTER JOIN (
		 	            SELECT UDF_MASTER_INVOICE, CASE WHEN SUM(LineDiscountPercent) > 0 THEN 'Y' ELSE 'N' END As HasLineItemDiscounts
			              FROM MAS_PRC.dbo.AR_InvoiceHistoryHeader ihh
				               INNER JOIN MAS_PRC.dbo.AR_InvoiceHistoryDetail ihd ON ihh.InvoiceNo = ihd.InvoiceNo AND ihh.HeaderSeqNo = ihd.HeaderSeqNo
			            GROUP BY UDF_MASTER_INVOICE         
                     ) T1 ON MAS_PRC.dbo.vBBSiMasterInvoices.UDF_MASTER_INVOICE = T1.UDF_MASTER_INVOICE
                     
                     INNER JOIN vPRLocation vprl ON vprl.prci_CityID = Company.comp_PRListingCityId 

                     LEFT OUTER JOIN PRFinancial ON comp_CompanyID = prfs_CompanyID
	                      AND comp_PRFinancialStatementDate = prfs_StatementDate

                     LEFT OUTER JOIN (
                        SELECT UDF_MASTER_INVOICE, MAX(LineDiscountPercent) as PrimaryServiceDiscount
                        FROM MAS_PRC.dbo.AR_InvoiceHistoryHeader ihh
                        INNER JOIN MAS_PRC.dbo.AR_InvoiceHistoryDetail ihd ON ihh.InvoiceNo = ihd.InvoiceNo AND ihh.HeaderSeqNo = ihd.HeaderSeqNo
                        INNER JOIN MAS_PRC.dbo.CI_ITEM i ON ihd.ItemCode = i.ItemCode AND Category2 = 'Primary'
                        GROUP BY UDF_MASTER_INVOICE
		              ) T2 ON MAS_PRC.dbo.vBBSiMasterInvoices.UDF_MASTER_INVOICE = T2.UDF_MASTER_INVOICE

					 LEFT OUTER JOIN PRAttentionLine WITH (NOLOCK) ON prattn_CompanyID = BillToCustomerNo AND prattn_ItemCode = 'ADVBILL' 
					 LEFT OUTER JOIN vPRAddress bl WITH (NOLOCK) ON prattn_AddressID = bl.Addr_AddressId
					 LEFT OUTER JOIN vPerson pers WITH (NOLOCK) ON pers.Pers_PersonId = prattn_PersonID
                     LEFT OUTER JOIN PRService ON comp_CompanyID = prse_CompanyID AND prse_Primary='Y' 
               WHERE {2}
                 AND prci2_BillingException IS NULL
                 AND BillToCustomerNo NOT IN (SELECT prcoml_CompanyID FROM PRCommunicationLog WHERE prcoml_CreatedDate > '{1}' AND prcoml_Source = 'Generate Invoices')";

        protected const string SQL_ELECTRONIC_CLAUSE =
           @" AND (FaxNo <> '' OR EmailAddress <> '') ORDER BY BillToCustomerNo";

        protected const string SQL_MAIL_CLAUSE =
           @" AND FaxNo = '' AND EmailAddress = '' AND Balance > 0 ORDER BY BillToCustomerNo";


        protected void GenerateElectronicInvoices(bool send, int maxInvoices, string inclusionType)
        {
            // CHW DEBUG
            //maxInvoices = 1;
            //inclusionType = "I";


            string invoiceNbr = null;
            DateTime invoiceDate;
            DateTime dueDate;
            string customerNo = null;
            string language = null;
            decimal balance = 0;
            decimal salesTaxAmt = 0;
            decimal total = 0;
            string stripeCustomerID;
            StringBuilder attachmentList = new StringBuilder();


            int maxErrorCount = GetConfigValue("GenerateInvoicesMaxErrorCount", 10);
            int errorCount = 0;
            List<string> errors = new List<string>();

            string exclusionDate = DateTime.Now.AddHours(0 - GetConfigValue("GenerateInvoicesExcludeHours", 60)).ToString("yyyy-MM-dd hh:mm:ss tt");
            string journalBatchNo = null;

            lblMsg.Text += $"Started: {DateTime.Now.ToString()}";

            int pastDueDaysOld = 5;
            DateTime pastDueThreshold = DateTime.Today.AddDays(0 - pastDueDaysOld);

            try
            {
                string inclusionClause = string.Empty;
                if (string.IsNullOrEmpty(inclusionType))
                    inclusionClause = $"(JournalNoGLBatchNo = '{ddlElectronicBatchList.SelectedValue}' OR (Balance > 0 AND InvoiceDueDate < {pastDueThreshold:yyyy-MM-dd})";
                else if (inclusionType == "I")
                {
                    inclusionClause = $"JournalNoGLBatchNo = '{ddlElectronicBatchList.SelectedValue}'";
                    journalBatchNo = ddlElectronicBatchList.SelectedValue;
                }
                else if (inclusionType == "P")
                    inclusionClause = "(Balance > 0 AND InvoiceDueDate < GETDATE())";


                string sql = string.Format(SQL_BASE_SELECT + SQL_ELECTRONIC_CLAUSE, ddlElectronicBatchList.SelectedValue, exclusionDate, inclusionClause, maxInvoices);
                //lblMsg.Text += $"<p>{sql}</p>";

                SqlCommand cmdInvoices = new SqlCommand(sql, GetDBConnnection());
                cmdInvoices.CommandTimeout = 600;

                string tempReportsFolder = GetConfigValue("TempReports");
                string templatesFolder = GetConfigValue("TemplatesPath");
                string sqlReportsFolder = GetConfigValue("SQLReportPath");
                string userReportsFolder = GetConfigValue("GenerateInvoicesUserReviewFolder");
                ReportInterface oRI = new ReportInterface();

                // Setup our supporting files, etc.
                string invoiceBody = null;

                string invoiceTemplate = ReadTemplate("Invoice Email.html");
                string invoiceTemplateSpanish = ReadTemplate("Invoice Email - Spanish.html");
                
                string subject = null;
                string subjectEnglish = GetConfigValue("GenerateInvoicesEmailSubject", "Blue Book Services: Your Invoice is Attached");
                string subjectSpanish = GetConfigValue("GenerateInvoicesEmailSubject_S", "Servicios de Libro Azul: Su factura está adjunta");

                System.IO.File.Copy(Path.Combine(templatesFolder, "Wire Bank Transfer.pdf"), Path.Combine(tempReportsFolder, "Wire Bank Transfer.pdf"), true);

                string emailBody = null;
                int invoiceCount = 0;

                string szEmailImageHTML_TOP = "";
                string szEmailImageHTML_BOTTOM = "";
                string szInvoiceBodyWithEmailImages;
                string comp_PRIndustryType;
                string culture = "";

                using (IDataReader drInvoices = cmdInvoices.ExecuteReader(CommandBehavior.Default))
                {
                    while (drInvoices.Read()) {

                        try
                        {
                            emailBody = null;
                            attachmentList.Clear();

                            invoiceNbr = (string)drInvoices["UDF_MASTER_INVOICE"];
                            invoiceDate = (DateTime)drInvoices["InvoiceDate"];
                            dueDate = (DateTime)drInvoices["InvoiceDueDate"];
                            customerNo = ((string)drInvoices["BillToCustomerNo"]).Substring(1); //strip off leading 0
                            language = (string)drInvoices["comp_PRCommunicationLanguage"];
                            comp_PRIndustryType = (string)drInvoices["comp_PRIndustryType"];

                            stripeCustomerID = null;
                            if (drInvoices["prci2_StripeCustomerId"] != DBNull.Value)
                                stripeCustomerID = (string)drInvoices["prci2_StripeCustomerId"];

                            balance = 0;
                            if (drInvoices["Balance"] != DBNull.Value)
                                balance = (decimal)drInvoices["Balance"];

                            salesTaxAmt = (decimal)drInvoices["SalesTaxAmt"];
                            total = (decimal)drInvoices["Total"];

                            // Get the Paid URL fist (if there is one), because it may not be 
                            // the most recent URL.
                            string stripeURL = GetPaidStripePaymentURL(GetDBEmailConnnection(), invoiceNbr);

                            if (string.IsNullOrEmpty(stripeURL))
                                stripeURL = GetMostRecentStripePaymentURL(GetDBEmailConnnection(), invoiceNbr);

                            if (string.IsNullOrEmpty(stripeURL))
                                stripeURL = GetStripeHostedURL(customerNo, stripeCustomerID, drInvoices, inclusionType);

                            // Bottom Message
                            string msgBottom = GetBottomMessageTemplate(comp_PRIndustryType, language);

                            bool sendEmail = true;
                            bool sendFax = false;
                            if ((string.IsNullOrEmpty((string)drInvoices["EmailAddress"])) &&
                                (!string.IsNullOrEmpty((string)drInvoices["FaxNo"])))
                            {
                                sendEmail = false;
                                sendFax = true;
                            }

                            // Only generate the PDF if we have to.
                            string invoiceFileName = null;
                            byte[] abReport = null;
                            if ((sendFax) || !send)
                            {
                                invoiceFileName = string.Format(GetConfigValue("GenerateInvoicesFileName", "BBS Invoice {0}.pdf"), invoiceNbr);
                                abReport = oRI.GenerateInvoiceStripe(invoiceNbr);
                            }

                            if (!send)
                            {
                                string fullName = Path.Combine(userReportsFolder, invoiceFileName);
                                WriteFileToDisk(fullName, abReport);
                            }
                            else
                            {
                                SqlCommand cmdCreateEmail = new SqlCommand("usp_CreateEmail", GetDBEmailConnnection());
                                cmdCreateEmail.CommandType = CommandType.StoredProcedure;
                                cmdCreateEmail.CommandTimeout = 90;
                                cmdCreateEmail.Parameters.AddWithValue("CreatorUserId", hidUserID.Text);
                                cmdCreateEmail.Parameters.AddWithValue("RelatedCompanyId", (string)drInvoices["BillToCustomerNo"]);
                                cmdCreateEmail.Parameters.AddWithValue("DoNotRecordCommunication", GetConfigValue("GenerateInvoicesDoNotRecordCommunication", "0"));
                                cmdCreateEmail.Parameters.AddWithValue("Source", "Generate Invoices");
                                cmdCreateEmail.Parameters.AddWithValue("Content_Format", "HTML");
                                cmdCreateEmail.Parameters.AddWithValue("ProfileName", GetConfigValue("GenerateInvoicesEmailProfile", "BBS Billing"));

                                if (sendEmail)
                                {
                                    cmdCreateEmail.Parameters.AddWithValue("@To", (string)drInvoices["EmailAddress"]);
                                    cmdCreateEmail.Parameters.AddWithValue("@Action", "EmailOut");

                                    if (((string)drInvoices["prattn_IncludeWireTransferInstructions"]) == "Y")
                                    {
                                        attachmentList.Append(Path.Combine(sqlReportsFolder, "Wire Bank Transfer.pdf"));
                                        attachmentList.Append(";");
                                    }

                                    szEmailImageHTML_TOP = GetEmailImage(GetDBConnnection2(), "2", "T", comp_PRIndustryType);
                                    szEmailImageHTML_BOTTOM = GetEmailImage(GetDBConnnection2(), "2", "B", comp_PRIndustryType);

                                    string paymentButton = GetPaymentButton(language, balance, stripeURL);

                                    string szOverrideAddressee;
                                    if ((int)drInvoices["HasAdvertisingItemCode"] == 1 && !String.IsNullOrEmpty((string)drInvoices["AttnName"]))
                                        szOverrideAddressee = (string)drInvoices["AttnName"];
                                    else
                                        szOverrideAddressee = (string)drInvoices["ContactName"];


                                    string invoiceDetails = GetInvoiceForEmail(GetDBEmailConnnection(), invoiceNbr, invoiceDate, dueDate, salesTaxAmt, total, balance, journalBatchNo);
                                    string downloadURL = GetInvoiceDownloadURL(GetDBEmailConnnection(), invoiceNbr);

                                    switch (language)
                                    {
                                        case "S":
                                            subject = subjectSpanish;
                                            invoiceBody = string.Format(invoiceTemplateSpanish, paymentButton, msgBottom, invoiceDetails, downloadURL, invoiceNbr);
                                            szInvoiceBodyWithEmailImages = szEmailImageHTML_TOP + invoiceBody + szEmailImageHTML_BOTTOM;
                                            culture = "es-mx";
                                            break;

                                        default:
                                            subject = subjectEnglish;
                                            invoiceBody = string.Format(invoiceTemplate, paymentButton, msgBottom, invoiceDetails, downloadURL, invoiceNbr);
                                            szInvoiceBodyWithEmailImages = szEmailImageHTML_TOP + invoiceBody + szEmailImageHTML_BOTTOM;
                                            culture = "en-us";
                                            break;

                                    }

                                    emailBody = GetFormattedEmail(GetDBEmailConnnection(),
                                                                  null,
                                                                  Convert.ToInt32(drInvoices["BillToCustomerNo"]),
                                                                  0,
                                                                  subject,
                                                                  szInvoiceBodyWithEmailImages,
                                                                  szOverrideAddressee,
                                                                  culture);

                                    cmdCreateEmail.Parameters.AddWithValue("Content", emailBody);
                                    cmdCreateEmail.Parameters.AddWithValue("Subject", subject);

                                    if (GetConfigValue("InvoiceInsertEnabled", false) == true)
                                    {
                                        //Defect 4456 - per Larry, exclude inserts from past due invoices
                                        if (Convert.ToDateTime(drInvoices["InvoiceDueDate"]) > DateTime.Now)
                                        {
                                            int iCountry = Convert.ToInt32(drInvoices["prcn_CountryId"]);
                                            string szInsertAttachment = "";

                                            if (comp_PRIndustryType != "L"
                                                && (iCountry == 1 || iCountry == 2))
                                            {  
                                                // DEFECT #7437
                                                // Leaving this here for now in case other inserts
                                                // are desired in the future.
                                                //if (drInvoices["prfs_sales"] == DBNull.Value
                                                //    || Convert.ToDateTime(drInvoices["prfs_StatementDate"]) < DateTime.Now.AddMonths(-1 * Convert.ToInt32(GetConfigValue("FinancialStatementOlderThan_Months", "18"))))
                                                //{
                                                //    szInsertAttachment = "May be Eligible for SB Discount.pdf";
                                                //}
                                                //else if (Convert.ToDouble(drInvoices["prfs_sales"]) < Convert.ToDouble(GetConfigValue("SalesThreshhold", "10000000")) &&
                                                //    drInvoices["PrimaryServiceDiscount"] != DBNull.Value && Convert.ToDouble(drInvoices["PrimaryServiceDiscount"]) == Convert.ToDouble(GetConfigValue("InvoiceInsertPercent", "5")))
                                                //{
                                                //    szInsertAttachment = "Has SB Discount.pdf";
                                                //}

                                                if (!string.IsNullOrEmpty(szInsertAttachment))
                                                {
                                                    attachmentList.Append(Path.Combine(sqlReportsFolder, szInsertAttachment));
                                                    attachmentList.Append(";");
                                                }
                                            }
                                        }
                                    }

                                }
                                else if (!string.IsNullOrEmpty((string)drInvoices["FaxNo"]))
                                {
                                    WriteFileToDisk(Path.Combine(tempReportsFolder, invoiceFileName), abReport);
                                    attachmentList.Append(Path.Combine(sqlReportsFolder, invoiceFileName));
                                    cmdCreateEmail.Parameters.AddWithValue("@AttachmentFileName", attachmentList.ToString());

                                    cmdCreateEmail.Parameters.AddWithValue("@To", (string)drInvoices["FaxNo"]);
                                    cmdCreateEmail.Parameters.AddWithValue("@Action", "FaxOut");
                                }

                                cmdCreateEmail.ExecuteNonQuery();
                                invoiceCount++;

                            }

                        } catch (Exception eX) {
                            errors.Add($"BBID {customerNo} Invoice {invoiceNbr} - {eX.Message} {eX.StackTrace}");

                            errorCount++;
                            if (errorCount >= maxErrorCount)
                                throw new ApplicationException($"Too many exceptions: {errorCount}");
                        }
                    }
                }

                if (send)
                    lblMsg.Text += string.Format("<br/>Successfully sent {0} invoices.", invoiceCount);
                else
                    lblMsg.Text += string.Format("<br/>Successfully generated {0} invoices.  They are available for review at <a href=\"{1}\" target=_blank>{1}</a>.", invoiceCount, GetVirtualPath(GetConfigValue("GenerateInvoicesUserReviewVirtualFolder")));

                if (errorCount > 0)
                {
                    lblMsg.Text += $"<br/>{ errorCount} invoices had errors:";
                    lblMsg.Text += "<ul>";
                    foreach (string error in errors)
                    {
                        lblMsg.Text += $"<li>{error}</li>";
                    }
                    lblMsg.Text += "</ul>";
                }

                lblMsg.Text += $"<br/>Ended: {DateTime.Now.ToString()}";
            }
            catch (Exception eX)
            {
                lblMsg.Text += eX.Message + "<br/>";

                lblMsg.Text += "<ul>";
                foreach (string error in errors)
                {
                    lblMsg.Text += $"<li>{error}</li>";
                }
                lblMsg.Text += "</ul>";

                /*
                if (!string.IsNullOrEmpty(invoiceNbr)) 
                    lblMsg.Text += "<br/>InvoiceNbr: " + invoiceNbr;
                
                if (!string.IsNullOrEmpty(invoiceFileName)) 
                    lblMsg.Text += "<br/>Invoice FileName: " + invoiceFileName;
              
                if (attachmentList.Length > 0) 
                    lblMsg.Text += "<br/>Attachments: " + attachmentList.ToString();

                lblMsg.Text += "<br/><pre>" + eX.StackTrace + "</pre>";
                */
            } 
            finally
            {
                CloseDBConnection(_dbConn);
                CloseDBConnection(_dbConn2);
                CloseDBConnection(_dbEmailConn);
            }
        }

        protected const string SQL_INVOICE_DETAILS =
            @"SELECT ihh.JournalNoGLBatchNo, 
                   ihh.UDF_MASTER_INVOICE, 
	               ihh.InvoiceDate,
	               ihh.InvoiceDueDate,
	               ISNULL(Balance, 0),
	               prcse_FullName,
	               SubTotal,
	               Itemcode,
	               ItemCodeDesc,
	               QuantityOrdered,
	               LineDiscountPercent,
	               ExtensionAmt,
	               UnitPrice,
                  ISNULL(ca.Fax, '') as FaxNo,
                  ISNULL(RTRIM(ca.EmailAddress), '') as EmailAddress
             FROM MAS_PRC.dbo.AR_InvoiceHistoryHeader ihh WITH (NOLOCK)
                  INNER JOIN MAS_PRC.dbo.AR_InvoiceHistoryDetail ihd WITH (NOLOCK) ON ihh.InvoiceNo = ihd.InvoiceNo AND ihh.HeaderSeqNo = ihd.HeaderSeqNo
	              INNER JOIN MAS_PRC.dbo.AR_Customer c WITH (NOLOCK) ON MAS_PRC.dbo.ufn_GetBillTo(BillToCustomerNo, ihh.CustomerNo) = c.CustomerNo AND ISNUMERIC(c.CustomerNo) = 1 AND c.ARDivisionNo <> '01'
	              INNER JOIN CRM.dbo.PRCompanySearch WITH (NOLOCK) ON c.CustomerNo = prcse_CompanyId
	              INNER JOIN CRM.dbo.vPRCompanyAccounting ca WITH (NOLOCK) ON c.CustomerNo = comp_CompanyID
	              LEFT OUTER JOIN CRM.dbo.PRCompanyIndicators WITH (NOLOCK) ON c.CustomerNo = prci2_CompanyID
	              LEFT OUTER JOIN (SELECT UDF_MASTER_INVOICE, SUM(Balance) Balance
	                                 FROM MAS_PRC.dbo.AR_OpenInvoice 
									      INNER JOIN MAS_PRC.dbo.AR_InvoiceHistoryHeader ON AR_OpenInvoice.InvoiceNo = AR_InvoiceHistoryHeader.InvoiceNo
										                                                AND AR_OpenInvoice.InvoiceHistoryHeaderSeqNo = AR_InvoiceHistoryHeader.HeaderSeqNo
					             GROUP BY UDF_MASTER_INVOICE) T1 ON ihh.UDF_MASTER_INVOICE = T1.UDF_MASTER_INVOICE	              LEFT OUTER JOIN (
		            SELECT ihh.JournalNoGLBatchNo,
			               ihh.UDF_MASTER_INVOICE,
			               ihh.CustomerNo,
			               Sum(ExtensionAmt) As SubTotal
		              FROM MAS_PRC.dbo.AR_InvoiceHistoryHeader ihh WITH (NOLOCK) 
			               INNER JOIN MAS_PRC.dbo.AR_InvoiceHistoryDetail ihd WITH (NOLOCK) ON ihh.InvoiceNo = ihd.InvoiceNo AND ihh.HeaderSeqNo = ihd.HeaderSeqNo
	                WHERE ihh.JournalNoGLBatchNo = '{0}'
	             GROUP BY ihh.JournalNoGLBatchNo,
			              ihh.UDF_MASTER_INVOICE,
			              ihh.CustomerNo
 	                           ) T2 ON ihh.UDF_MASTER_INVOICE = T2.UDF_MASTER_INVOICE 
		                          AND  MAS_PRC.dbo.ufn_GetBillTo(BillToCustomerNo, ihh.CustomerNo) = T2.CustomerNo 
            WHERE ihh.UDF_MASTER_INVOICE IS NOT NULL      
              AND ihh.UDF_MASTER_INVOICE <> ''
              AND SourceJournal = 'SO'
              AND ISNULL(ca.Fax, '') = '' AND ISNULL(ca.EmailAddress, '') = ''
              AND (ihh.JournalNoGLBatchNo = '{0}'
                   OR (Balance >0 AND InvoiceDueDate < GETDATE()))
              AND ExplodedKitItem <> 'C'";

        protected void GenerateExportFile(bool send)
        {
            int maxInvoices = 99999;
            string inclusionClause = $"(JournalNoGLBatchNo = '{ddlMailBatchList.SelectedValue}' OR (Balance > 0 AND InvoiceDueDate < GETDATE())) ";

            try
            {
                string userReportsFolder = GetConfigValue("GenerateInvoicesUserReviewFolder");
                string headerFileName = string.Format(GetConfigValue("GenerateInvoiceHeaderFileName", "InvoiceHeader_{0}.txt"), ddlMailBatchList.SelectedValue);
                string detailFileName = string.Format(GetConfigValue("GenerateInvoiceDetailFileName", "InvoiceDetail_{0}.txt"), ddlMailBatchList.SelectedValue);

                int invoiceCount = 0;
                StringBuilder buffer = new StringBuilder();

                using (TextWriter headerfile = new StreamWriter(Path.Combine(userReportsFolder, headerFileName)))
                {
                    string strHeader = "Invoice Number\tCompany ID\tInvoice Date\tTerms\tContact Name\tBill To Name\tAddress1\tAddress2\tAddress3\tCity\tState\tPostal Code\tCountry\tDiscount Amt\tSubtotal Amt\tSales Tax Amt\tAmt Paid\tTotal Due\tPast Due\tInclude Wire Transfer\tHas Line Item Discounts";
                    if (GetConfigValue("InvoiceInsertEnabled", false) == true)
                        strHeader += "\tInsert1\tInsert2\tInsert3\tInsert4\tInsert5\tInsert6";

                    headerfile.WriteLine(strHeader);

                    string exclusionDate = DateTime.Now.ToString("yyyy-MM-dd hh:mm:ss tt");
                    string sql = string.Format(SQL_BASE_SELECT + SQL_MAIL_CLAUSE, ddlMailBatchList.SelectedValue, exclusionDate, inclusionClause, maxInvoices);
                    SqlCommand cmdInvoices = new SqlCommand(sql, GetDBConnnection());
                    cmdInvoices.CommandTimeout = 1800;

                    //lblMsg.Text += $"<p>{sql}</p>";

                    using (IDataReader drInvoices = cmdInvoices.ExecuteReader(CommandBehavior.Default))
                    {
                        while (drInvoices.Read())
                        {
                            invoiceCount++;

                            AddField(buffer, drInvoices["UDF_MASTER_INVOICE"]);
                            AddField(buffer, drInvoices["BillToCustomerNo"]);
                            AddField(buffer, Convert.ToDateTime(drInvoices["InvoiceDate"]).ToShortDateString());
                            AddField(buffer, drInvoices["TermsCodeDesc"]);
                            AddField(buffer, drInvoices["ContactName"]);
                            AddField(buffer, drInvoices["BillToName"]);
                            AddField(buffer, drInvoices["BillToAddress1"]);
                            AddField(buffer, drInvoices["BillToAddress2"]);
                            AddField(buffer, drInvoices["BillToAddress3"]);
                            AddField(buffer, drInvoices["BillToCity"]);
                            AddField(buffer, drInvoices["BillToState"]);
                            AddField(buffer, drInvoices["BillToZipCode"]);
                            AddField(buffer, drInvoices["CountryName"]);
                            AddField(buffer, drInvoices["DiscountAmt"]);
                            AddField(buffer, Convert.ToDecimal(drInvoices["TaxableSalesAmt"]) + Convert.ToDecimal(drInvoices["NonTaxableSalesAmt"]));
                            AddField(buffer, drInvoices["SalesTaxAmt"]);
                            AddField(buffer, Convert.ToDecimal(drInvoices["Total"]) - Convert.ToDecimal(drInvoices["Balance"]));
                            AddField(buffer, drInvoices["Balance"]);

                            if (Convert.ToDateTime(drInvoices["InvoiceDueDate"]) < DateTime.Now)
                            {
                                AddField(buffer, "Y");
                            }
                            else
                            {
                                AddField(buffer, "N");
                            }

                            AddField(buffer, drInvoices["prattn_IncludeWireTransferInstructions"]);
                            AddField(buffer, drInvoices["HasLineItemDiscounts"]);

                            if (GetConfigValue("InvoiceInsertEnabled", false) == true)
                            {
                                string szInsert1 = "";
                                string szInsert2 = "";
                                string szInsert3 = "";
                                string szInsert4 = "";
                                string szInsert5 = "";
                                string szInsert6 = "";

                                //Defect 4456 - per Larry, exclude inserts from past due invoices
                                if (Convert.ToDateTime(drInvoices["InvoiceDueDate"]) > DateTime.Now)
                                {
                                    int iCountry = Convert.ToInt32(drInvoices["prcn_CountryId"]);
                                    if (Convert.ToString(drInvoices["comp_PRIndustryType"]) != "L"
                                        && (iCountry == 1 || iCountry == 2))
                                    {
                                        if (drInvoices["prfs_sales"] == DBNull.Value
                                            || Convert.ToDateTime(drInvoices["prfs_StatementDate"]) < DateTime.Now.AddMonths(-1 * Convert.ToInt32(GetConfigValue("FinancialStatementOlderThan_Months", "18"))))
                                        {
                                            szInsert1 = "SBD-U";
                                        }
                                        else if (Convert.ToDouble(drInvoices["prfs_sales"]) < Convert.ToDouble(GetConfigValue("SalesThreshhold", "10000000")) &&
                                            drInvoices["PrimaryServiceDiscount"] != DBNull.Value && Convert.ToDouble(drInvoices["PrimaryServiceDiscount"]) == Convert.ToDouble(GetConfigValue("InvoiceInsertPercent", "5")))
                                        {
                                            szInsert1 = "SBD-Y";
                                        }
                                    }
                                }

                                AddField(buffer, szInsert1);
                                AddField(buffer, szInsert2);
                                AddField(buffer, szInsert3);
                                AddField(buffer, szInsert4);
                                AddField(buffer, szInsert5);
                                AddField(buffer, szInsert6);
                            }
                            
                            headerfile.WriteLine(buffer.ToString());
                            buffer.Length = 0;

                            switch (Convert.ToString(drInvoices["BillToCountryCode"]))
                            {
                                case "001":
                                    _usaCount++;
                                    _usaTotal += Convert.ToDecimal(drInvoices["Balance"]);
                                    break;
                                case "002":
                                    _canadaCount++;
                                    _canadaTotal += Convert.ToDecimal(drInvoices["Balance"]);
                                    break;
                                case "003":
                                    _mexicoCount++;
                                    _mexicoTotal += Convert.ToDecimal(drInvoices["Balance"]);
                                    break;
                                default:
                                    _otherCount++;
                                    _otherTotal += Convert.ToDecimal(drInvoices["Balance"]);
                                    break;
                            }
                        }
                    }
                }

                using (TextWriter detailfile = new StreamWriter(Path.Combine(userReportsFolder, detailFileName)))
                {
                    if (GetConfigValue("GenerateInvoicesLegacyFormatEnabled", true))
                    {
                        detailfile.WriteLine("Invoice Number\tShipTo City\tShipTo State\tItem\tQuantity\tDiscount\tAmount\tUnitPrice");
                    }
                    else
                    {
                        detailfile.WriteLine("Invoice Number\tShipTo Location\tShipTo Subtotal\tItem\tQuantity\tDiscount\tAmount\tUnitPrice");
                    }

                    string sql = string.Format(SQL_INVOICE_DETAILS, ddlMailBatchList.SelectedValue);
                    SqlCommand cmdInvoices = new SqlCommand(sql, GetDBConnnection());
                    cmdInvoices.CommandTimeout = 1800;

                    using (IDataReader drInvoices = cmdInvoices.ExecuteReader(CommandBehavior.Default))
                    {
                        while (drInvoices.Read())
                        {
                            if (GetConfigValue("GenerateInvoicesLegacyFormatEnabled", true))
                            {
                                AddField(buffer, drInvoices["UDF_MASTER_INVOICE"]);
                                AddField(buffer, drInvoices["ListingCity"]);

                                if (string.IsNullOrEmpty(Convert.ToString(drInvoices["ListingState"])))
                                {
                                    AddField(buffer, drInvoices["prcn_Country"]);
                                }
                                else
                                {
                                    AddField(buffer, drInvoices["ListingState"]);
                                }

                                AddField(buffer, drInvoices["ItemCodeDesc"]);
                                AddField(buffer, drInvoices["QuantityOrdered"]);
                                AddField(buffer, drInvoices["LineDiscountPercent"]);
                                AddField(buffer, drInvoices["ExtensionAmt"]);
                                AddField(buffer, drInvoices["UnitPrice"]);
                            }
                            else
                            {
                                AddField(buffer, drInvoices["UDF_MASTER_INVOICE"]);
                                AddField(buffer, drInvoices["prcse_FullName"]);
                                AddField(buffer, drInvoices["SubTotal"]);
                                AddField(buffer, drInvoices["ItemCodeDesc"]);
                                AddField(buffer, drInvoices["QuantityOrdered"]);
                                AddField(buffer, drInvoices["LineDiscountPercent"]);
                                AddField(buffer, drInvoices["ExtensionAmt"]);
                                AddField(buffer, drInvoices["UnitPrice"]);
                            }

                            detailfile.WriteLine(buffer.ToString());
                            buffer.Length = 0;
                        }
                    }
                }

                if (send)
                {
                    string controlFileName = GenerateControlCountFile();

                    string ftpFileName = CompressFiles(headerFileName, detailFileName, controlFileName, ddlMailBatchList.SelectedValue);

                    UploadFileSFTP(GetConfigValue("GenerateInvoicesFTPServer", "ftp://ftp.bluebookservices.com"),
                                   22,
                                   GetConfigValue("GenerateInvoicesFTPUsername", "qa"),
                                   GetConfigValue("GenerateInvoicesFTPPassword", "qA$1901"),
                                   ftpFileName,
                                   Path.GetFileName(ftpFileName));

                    System.IO.File.Delete(Path.Combine(userReportsFolder, headerFileName));
                    System.IO.File.Delete(Path.Combine(userReportsFolder, detailFileName));
                    System.IO.File.Delete(Path.Combine(userReportsFolder, controlFileName));

                    lblMsg.Text += string.Format("Successfully generated and sent {0} invoices.", invoiceCount);
                }
                else
                {
                    lblMsg.Text += string.Format("Successfully generated {0} invoices.  The files are available for review at {1}.", invoiceCount, userReportsFolder);
                }
            }
            catch (Exception eX)
            {
                lblMsg.Text += eX.Message;
                lblMsg.Text += "<br/><pre>" + eX.StackTrace + "</pre>";
            }
            finally
            {
                CloseDBConnection(_dbConn);
                CloseDBConnection(_dbConn2);
            }
        }

        //private  _InvoiceControlFile = null;
        protected string GenerateControlCountFile()
        {
            string userReportsFolder = GetConfigValue("GenerateInvoicesUserReviewFolder");
            string controlFileName = string.Format(GetConfigValue("GenerateInvoicesControlFile", "Control_{0}.txt"), ddlMailBatchList.SelectedValue);

            string controlFile = Path.Combine(userReportsFolder,
                                           controlFileName);

            if (System.IO.File.Exists(controlFile))
                System.IO.File.Delete(controlFile);

            string text = GetFormattedControlTotals();
            using (TextWriter controlfile = new StreamWriter(controlFile))
            {
                controlfile.Write(text);
            }

            return controlFileName;
        }


        protected string GetFormattedControlTotals()
        {
            StringBuilder text = new StringBuilder();

            text.Append("Description");
            text.Append("\t");
            text.Append("Count");
            text.Append("\t");
            text.Append("Total");
            text.Append(Environment.NewLine);
            text.Append("USA");
            text.Append("\t");
            text.Append(_usaCount.ToString("###,##0"));
            text.Append("\t");
            text.Append(_usaTotal.ToString("###,###,##0.00"));
            text.Append(Environment.NewLine);
            text.Append("Canada");
            text.Append("\t");
            text.Append(_canadaCount.ToString("###,##0"));
            text.Append("\t");
            text.Append(_canadaTotal.ToString("###,###,##0.00"));
            text.Append(Environment.NewLine);
            text.Append("Mexico");
            text.Append("\t");
            text.Append(_mexicoCount.ToString("###,##0"));
            text.Append("\t");
            text.Append(_mexicoTotal.ToString("###,###,##0.00"));
            text.Append(Environment.NewLine);
            text.Append("Other");
            text.Append("\t");
            text.Append(_otherCount.ToString("###,##0"));
            text.Append("\t");
            text.Append(_otherTotal.ToString("###,###,##0.00"));
            text.Append(Environment.NewLine);
            text.Append("TOTALS");
            text.Append("\t");
            text.Append((_usaCount + _canadaCount + _mexicoCount + _otherCount).ToString("###,##0"));
            text.Append("\t");
            text.Append((_usaTotal + _canadaTotal + _mexicoTotal + _otherTotal).ToString("###,###,##0.00"));

            return text.ToString();
        }

        protected void GenerateEmail(string fileName)
        {
            string body = string.Format(GetConfigValue("GenerateInvoicesFTPEmailBody",
                                                       "A new BBSi invoice file, {0}, has been uploaded to {1} and is available for processing."),
                                        fileName,
                                        GetConfigValue("GenerateInvoicesFTPServer", "ftp://ftp.bluebookprco.com"));

            SqlCommand cmdCreateEmail = new SqlCommand("usp_CreateEmail", GetDBConnnection());
            cmdCreateEmail.CommandType = CommandType.StoredProcedure;
            cmdCreateEmail.Parameters.AddWithValue("To", GetConfigValue("GenerateInvoiceFTPEmailAddress", "cwalls@travant.com"));
            cmdCreateEmail.Parameters.AddWithValue("Subject", GetConfigValue("GenerateInvoicesFTPEmailSubject", "New BBSi Invoice Files"));
            cmdCreateEmail.Parameters.AddWithValue("Content", body);
            cmdCreateEmail.Parameters.AddWithValue("DoNotRecordCommunication", 1);
            cmdCreateEmail.Parameters.AddWithValue("Action", "EmailOut");
            cmdCreateEmail.ExecuteNonQuery();

            if (!string.IsNullOrEmpty(GetConfigValue("GenerateInvoicesBBSiEmailAddress", string.Empty)))
            {
                body += Environment.NewLine + Environment.NewLine;
                body += GetFormattedControlTotals();

                cmdCreateEmail = new SqlCommand("usp_CreateEmail", GetDBConnnection());
                cmdCreateEmail.CommandType = CommandType.StoredProcedure;
                cmdCreateEmail.Parameters.AddWithValue("To", GetConfigValue("GenerateInvoicesBBSiEmailAddress"));
                cmdCreateEmail.Parameters.AddWithValue("Subject", GetConfigValue("GenerateInvoicesFTPEmailSubject", "New BBSi Invoice Files"));
                cmdCreateEmail.Parameters.AddWithValue("Content", body);
                cmdCreateEmail.Parameters.AddWithValue("DoNotRecordCommunication", 1);
                cmdCreateEmail.Parameters.AddWithValue("Action", "EmailOut");
                cmdCreateEmail.ExecuteNonQuery();
            }
        }

        protected string CompressFiles(string headerFileName, string detailFileName, string controlFileName, string GLBatchNo)
        {
            string zipName = Path.Combine(GetConfigValue("GenerateInvoicesUserReviewFolder"),
                                          GetConfigValue("GenerateInvoicesCompressFile", string.Format("BBSi Invoices {0}.zip", GLBatchNo)));

            using (ZipOutputStream zipOutputStream = new ZipOutputStream(System.IO.File.Create(zipName)))
            {
                zipOutputStream.SetLevel(9); // 0-9, 9 being the highest compression
                zipOutputStream.Password = GetConfigValue("GenerateInvoicesZipPassword", "P@ssword1");

                addZipEntry(zipOutputStream, GetConfigValue("GenerateInvoicesUserReviewFolder"), headerFileName);
                addZipEntry(zipOutputStream, GetConfigValue("GenerateInvoicesUserReviewFolder"), detailFileName);
                addZipEntry(zipOutputStream, GetConfigValue("GenerateInvoicesUserReviewFolder"), controlFileName);
 
                zipOutputStream.Finish();
                zipOutputStream.IsStreamOwner = true;
                zipOutputStream.Close();
            }

            return zipName;
        }

        private void AddField(StringBuilder buffer, object value)
        {
            if (buffer.Length > 0)
            {
                buffer.Append("\t");
            }
            buffer.Append(Convert.ToString(value));
        }

        //private void WriteFileToDisk(string fullName, byte[] abReport)
        //{
        //    using (FileStream oFStream = File.Create(fullName, abReport.Length))
        //    {
        //        oFStream.Write(abReport, 0, abReport.Length);
        //    }
        //}
        
        private SqlConnection _dbConn = null;
        private SqlConnection _dbConn2 = null;
        private SqlConnection _dbEmailConn = null;

        /// <summary>
        /// Returns an open DB Connection
        /// </summary>
        /// <returns></returns>
        private SqlConnection GetDBConnnection()
        {
            if (_dbConn == null)
            {
                _dbConn = OpenDBConnection("GenerateInvoices");
            }

            return _dbConn;
        }

        /// <summary>
        /// Returns a second open DB Connection so they can be nested
        /// </summary>
        /// <returns></returns>
        private SqlConnection GetDBConnnection2()
        {
            if (_dbConn2 == null)
            {
                _dbConn2 = OpenDBConnection("GenerateInvoices");
            }

            return _dbConn2;
        }

        private SqlConnection GetDBEmailConnnection()
        {
            if (_dbEmailConn == null)
            {
                _dbEmailConn = OpenDBConnection("GenerateInvoices");
            }

            return _dbEmailConn;
        }
    }
}