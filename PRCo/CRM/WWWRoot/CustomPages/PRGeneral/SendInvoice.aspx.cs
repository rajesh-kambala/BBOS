/***********************************************************************
 Copyright Blue Book Services, Inc. 2014-2024

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
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Web.UI;

namespace PRCo.BBS.CRM
{
    public partial class SendInvoice : PageBase
    {
        string _UserID;

        override protected void Page_Load(object sender, EventArgs e)
        {
            Server.ScriptTimeout = 60 * 180;
            base.Page_Load(sender, e);

            _UserID = Request["user_userid"];
            Send((string)Request["InvoiceNo"]);
        }


        protected const string SQL_SELECT_INVOICE =
            @"SELECT vBBSiMasterInvoices.*, comp_PRCommunicationLanguage, comp_PRIndustryType,
					'AttnName' = CASE WHEN (prattn_PersonID IS NULL AND prattn_CustomLine IS NULL) THEN ContactName ELSE 'Attn: ' + ISNULL(prattn_CustomLine, dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, null, pers_Suffix)) END,
                     Balance, SalesTaxAmt, Total,
                     prse_NextAnniversaryDate,
                     prci2_StripeCustomerId
                FROM MAS_PRC.dbo.vBBSiMasterInvoices 
                     INNER JOIN Company WITH (NOLOCK) ON CAST(BillToCustomerNo As Int) = comp_CompanyID
					 LEFT OUTER JOIN PRAttentionLine WITH (NOLOCK) ON prattn_CompanyID = SUBSTRING(BillToCustomerNo,2,6) AND prattn_ItemCode = 'ADVBILL' 
					 LEFT OUTER JOIN vPRAddress bl WITH (NOLOCK) ON prattn_AddressID = bl.Addr_AddressId
					 LEFT OUTER JOIN vPerson pers WITH (NOLOCK) ON pers.Pers_PersonId = prattn_PersonID
                     LEFT OUTER JOIN PRService ON comp_CompanyID = prse_CompanyID AND prse_Primary='Y' 
               WHERE UDF_MASTER_INVOICE = '{0}'
                AND (FaxNo <> '' OR EmailAddress <> '')";


        protected void Send(string invoiceNbr)
        {
            try
            {
                string companyID;
                string comp_PRIndustryType;
                DateTime invoiceDate;
                DateTime dueDate;
                decimal balance;
                decimal salesTaxAmt;
                decimal total;
                string stripeCustomerID;

                string sql = string.Format(SQL_SELECT_INVOICE, invoiceNbr);
                SqlCommand cmdInvoices = new SqlCommand(sql, GetDBConnnection());
                cmdInvoices.CommandTimeout = 600;

                string invoiceFileName = null;
                string tempReportsFolder = GetConfigValue("TempReports");
                string sqlReportsFolder = GetConfigValue("SQLReportPath");
                string templatesFolder = GetConfigValue("TemplatesPath");

                ReportInterface oRI = new ReportInterface();

                string invoiceBody = null;
                string emailBody = null;

                using (IDataReader drInvoices = cmdInvoices.ExecuteReader(CommandBehavior.Default))
                {
                    while (drInvoices.Read())
                    {
                        companyID = (string)drInvoices["BillToCustomerNo"];
                        comp_PRIndustryType = (string)drInvoices["comp_PRIndustryType"];
                        balance = (decimal)drInvoices["Balance"];
                        invoiceDate = (DateTime)drInvoices["InvoiceDate"];
                        dueDate = (DateTime)drInvoices["InvoiceDueDate"];
                        salesTaxAmt = (decimal)drInvoices["SalesTaxAmt"];
                        total = (decimal)drInvoices["Total"];

                        stripeCustomerID = null;
                        if (drInvoices["prci2_StripeCustomerId"] != DBNull.Value)
                            stripeCustomerID = (string)drInvoices["prci2_StripeCustomerId"];

                        emailBody = null;

                        invoiceFileName = string.Format(GetConfigValue("GenerateInvoicesFileName", "BBS Invoice {0}.pdf"), (string)drInvoices["UDF_MASTER_INVOICE"]);

                        SqlCommand cmdCreateEmail = new SqlCommand("usp_CreateEmail", GetDBEmailConnnection());
                        cmdCreateEmail.CommandType = CommandType.StoredProcedure;
                        cmdCreateEmail.Parameters.AddWithValue("CreatorUserId", _UserID);
                        cmdCreateEmail.Parameters.AddWithValue("Subject", GetConfigValue("GenerateInvoicesEmailSubject", "Blue Book Services: Your Invoice is Attached"));
                        cmdCreateEmail.Parameters.AddWithValue("RelatedCompanyId", companyID);
                        cmdCreateEmail.Parameters.AddWithValue("DoNotRecordCommunication", GetConfigValue("GenerateInvoicesDoNotRecordCommunication", "0"));
                        cmdCreateEmail.Parameters.AddWithValue("Source", "Generate Invoices");
                        cmdCreateEmail.Parameters.AddWithValue("Content_Format", "HTML");
                        cmdCreateEmail.Parameters.AddWithValue("ProfileName", GetConfigValue("GenerateInvoicesEmailProfile", "BBS Billing"));

                        bool sendEmail = true;
                        bool sendFax = false;
                        if ((string.IsNullOrEmpty((string)drInvoices["EmailAddress"])) &&
                            (!string.IsNullOrEmpty((string)drInvoices["FaxNo"])))
                        {
                            sendEmail = false;
                            sendFax = true;
                        }

                        StringBuilder attachmentList = new StringBuilder();

                        if (sendEmail)
                        {
                            cmdCreateEmail.Parameters.AddWithValue("@To", (string)drInvoices["EmailAddress"]);
                            cmdCreateEmail.Parameters.AddWithValue("@Action", "EmailOut");

                            if (((string)drInvoices["prattn_IncludeWireTransferInstructions"]) == "Y")
                            {
                                File.Copy(Path.Combine(templatesFolder, "Wire Bank Transfer.pdf"), Path.Combine(tempReportsFolder, "Wire Bank Transfer.pdf"), true);
                                attachmentList.Append(Path.Combine(sqlReportsFolder, "Wire Bank Transfer.pdf"));
                                attachmentList.Append(";");
                            }

                            string szOverrideAddressee;
                            if ((int)drInvoices["HasAdvertisingItemCode"] == 1 && !String.IsNullOrEmpty((string)drInvoices["AttnName"]))
                                szOverrideAddressee = (string)drInvoices["AttnName"];
                            else
                                szOverrideAddressee = (string)drInvoices["ContactName"];

                            string language = (string)drInvoices["comp_PRCommunicationLanguage"];
                            string templateFile = null;
                            if (language == "S")
                                templateFile = "Invoice Email - Spanish.html";
                            else
                                templateFile = "Invoice Email.html";

                            string subject = null;
                            if (language == "S")
                                subject = GetConfigValue("GenerateInvoicesEmailSubject_S", "Servicios de Libro Azul: Su factura está adjunta");
                            else
                                subject = GetConfigValue("GenerateInvoicesEmailSubject", "Blue Book Services: Your Invoice is Attached");


                            using (StreamReader srTemplate = new StreamReader(Path.Combine(templatesFolder, templateFile)))
                            {
                                invoiceBody = srTemplate.ReadToEnd();
                            }

                            // Get the Paid URL fist (if there is one), because it may not be 
                            // the most recent URL.
                            string stripeURL = GetPaidStripePaymentURL(GetDBEmailConnnection(), (string)drInvoices["UDF_MASTER_INVOICE"]);

                            if (string.IsNullOrEmpty(stripeURL))
                                stripeURL = GetMostRecentStripePaymentURL(GetDBEmailConnnection(), (string)drInvoices["UDF_MASTER_INVOICE"]);

                            if (string.IsNullOrEmpty(stripeURL))
                                stripeURL = GetStripeHostedURL(companyID, stripeCustomerID, drInvoices, "B");

                            // Bottom Message
                            string msgBottom = GetBottomMessageTemplate(comp_PRIndustryType, language);
                            string paymentButton = GetPaymentButton(language, balance, stripeURL);

                            string invoiceDetails = GetInvoiceForEmail(GetDBEmailConnnection(), invoiceNbr, invoiceDate, dueDate, salesTaxAmt, total, balance);
                            string downloadURL = GetInvoiceDownloadURL(GetDBEmailConnnection(), invoiceNbr);

                            invoiceBody = string.Format(invoiceBody, paymentButton, msgBottom, invoiceDetails, downloadURL, invoiceNbr);

                            emailBody = GetFormattedEmail(GetDBEmailConnnection(),
                                                            null,
                                                            Convert.ToInt32(companyID),
                                                            0,
                                                            subject,
                                                            invoiceBody,
                                                            szOverrideAddressee);

                            cmdCreateEmail.Parameters.AddWithValue("Content", emailBody);
                        }
                        else if (sendFax)
                        {
                            cmdCreateEmail.Parameters.AddWithValue("@To", (string)drInvoices["FaxNo"]);
                            cmdCreateEmail.Parameters.AddWithValue("@Action", "FaxOut");
                        }

                        if (sendFax)
                        {
                            // This has to be done after the Stripe URL
                            // has been generated.
                            byte[] abReport = oRI.GenerateInvoiceStripe((string)drInvoices["UDF_MASTER_INVOICE"]);
                            WriteFileToDisk(Path.Combine(tempReportsFolder, invoiceFileName), abReport);
                            attachmentList.Append(Path.Combine(sqlReportsFolder, invoiceFileName));
                            cmdCreateEmail.Parameters.AddWithValue("@AttachmentFileName", attachmentList.ToString());
                        }

                        cmdCreateEmail.ExecuteNonQuery();
                    }
                }

                //Response.Redirect(string.Format("../PRCompany/PRCompanyPaymentHistory.asp?SID={0}&Key0=1&Key1={1}", _SID, companyID);
                Page.ClientScript.RegisterStartupScript(this.GetType(), "close", "closeSuccess();", true);
            }
            catch (Exception eX)
            {
                lblMsg.Text += eX.Message;
                lblMsg.Text += "<br/><pre>" + eX.StackTrace + "</pre>";
            }
            finally
            {
                CloseDBConnection(_dbConn);
                CloseDBConnection(_dbEmailConn);
            }
        }
  
        private SqlConnection _dbConn = null;
        private SqlConnection _dbEmailConn = null;

        /// <summary>
        /// Returns an open DB Connection
        /// </summary>
        /// <returns></returns>
        private SqlConnection GetDBConnnection()
        {
            if (_dbConn == null)
                _dbConn = OpenDBConnection("SendInvoice");

            return _dbConn;
        }

        private SqlConnection GetDBEmailConnnection()
        {
            if (_dbEmailConn == null)
                _dbEmailConn = OpenDBConnection("SendInvoice");

            return _dbEmailConn;
        }
    }
}