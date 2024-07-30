using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;


namespace PRCo.BBS.CRM.CustomPages.PRGeneral
{
    public partial class BusinessReportPurchaseSend : PageBase
    {
        protected string UserID;
        protected string SID;
        protected string prbrp_BusinessReportPurchaseID;

        override protected void Page_Load(object sender, EventArgs e)
        {
            Server.ScriptTimeout = 60 * 180;
            base.Page_Load(sender, e);

            prbrp_BusinessReportPurchaseID = Request["prbrp_BusinessReportPurchaseID"];
            UserID = Request["user_userid"];
            SID = Request["SID"];

            if (!IsPostBack)
            {
                SqlCommand cmdSelectBRPurchase = new SqlCommand(SQL_SELECT_BR_PURCHASE, GetDBConnnection());
                cmdSelectBRPurchase.Parameters.AddWithValue("ID", prbrp_BusinessReportPurchaseID);

                using (IDataReader reader = cmdSelectBRPurchase.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        EmailAddress.Text = GetString(reader["prbrp_SubmitterEmail"]);
                    }
                }
            }
        }


        protected void btnSendClick(object sender, EventArgs e)
        {
            
            SendBREmail(prbrp_BusinessReportPurchaseID);
            Response.Redirect("BusinessReportPurchase.asp?SID=" + SID + "&BRSent=Y&prbrp_BusinessReportPurchaseID=" + prbrp_BusinessReportPurchaseID);
        }

        protected void btnCancelClick(object sender, EventArgs e)
        {
            Response.Redirect("BusinessReportPurchase.asp?SID=" + SID + "&prbrp_BusinessReportPurchaseID=" + prbrp_BusinessReportPurchaseID);
        }

        private const string SQL_SELECT_BR_PURCHASE =
             "SELECT * FROM vPRBusinessReportPurchase WITH(NOLOCK) WHERE prbrp_BusinessReportPurchaseID = @ID";


        public void SendBREmail(string prbrp_BusinessReportPurchaseID)
        {
            string productCode = null;
            string industryType = null;
            int companyID = 0;

            SqlCommand cmdSelectBRPurchase = new SqlCommand(SQL_SELECT_BR_PURCHASE, GetDBConnnection());
            cmdSelectBRPurchase.Parameters.AddWithValue("ID", prbrp_BusinessReportPurchaseID);

            using (IDataReader reader = cmdSelectBRPurchase.ExecuteReader())
            {
                if (reader.Read())
                {
                    productCode = GetString(reader["prod_Code"]);
                    industryType = GetString(reader["prbrp_IndustryType"]);
                    companyID = GetInt(reader["prbrp_CompanyID"]);
                }
            }

            string subject = GetLookupCodeMeaning("PurchaseBR", "Subject");
            string body = GetLookupCodeMeaning("PurchaseBR", "Body2");
            string email = GetFormattedEmail(GetDBConnnection(), null, 0, 0, subject, body, EmailAddress.Text, "en-us", industryType);

            byte[] abReport = GetBusinessReport(companyID, productCode);
            string reportName = string.Format("Blue Book ID {0} Business Report.pdf", companyID);

            SqlCommand cmdCreateEmail = new SqlCommand("usp_CreateEmail", GetDBConnnection());
            cmdCreateEmail.CommandType = CommandType.StoredProcedure;
            cmdCreateEmail.Parameters.AddWithValue("Subject", subject);
            cmdCreateEmail.Parameters.AddWithValue("Content", email);
            cmdCreateEmail.Parameters.AddWithValue("DoNotRecordCommunication", "1");
            cmdCreateEmail.Parameters.AddWithValue("Source", "Send Business Report Purchase");
            cmdCreateEmail.Parameters.AddWithValue("Content_Format", "HTML");
            cmdCreateEmail.Parameters.AddWithValue("To", EmailAddress.Text);
            cmdCreateEmail.Parameters.AddWithValue("Action", "EmailOut");

            string tempReportsFolder = GetConfigValue("TempReports");
            string sqlReportsFolder = GetConfigValue("SQLReportPath");

            WriteFileToDisk(Path.Combine(tempReportsFolder, reportName), abReport);
            cmdCreateEmail.Parameters.AddWithValue("@AttachmentFileName", Path.Combine(sqlReportsFolder, reportName));

            cmdCreateEmail.ExecuteNonQuery();
        }

        protected ReportInterface _oRI;
        /// <summary>
        /// Interfaces with SSRS to generate the business report.
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="requestTypeCode"></param>
        /// <returns></returns>
        protected byte[] GetBusinessReport(int companyID, string requestTypeCode)
        {

            if (_oRI == null)
            {
                _oRI = new ReportInterface();
            }

            int iReportLevel = Convert.ToInt32(requestTypeCode.Replace("BR", ""));

            bool bIncludeBalanceSheet = false;
            bool IsEligibleForEquifaxData = false;


            return _oRI.GenerateBusinessReport(companyID.ToString(), iReportLevel, bIncludeBalanceSheet, false, 0, IsEligibleForEquifaxData, 0);
        }


        private const string SQL_SELECT_CUSTOM_CAPTION_VALUE =
             "SELECT capt_us FROM Custom_Captions WITH(NOLOCK) WHERE capt_Family = @capt_Family AND capt_Code = @capt_Code";

        private string GetLookupCodeMeaning(string captFamily, string captCode)
        {
            SqlCommand cmdCustomCaption = new SqlCommand(SQL_SELECT_CUSTOM_CAPTION_VALUE, GetDBConnnection());
            cmdCustomCaption.Parameters.AddWithValue("capt_Family", captFamily);
            cmdCustomCaption.Parameters.AddWithValue("capt_Code", captCode);

            return (string)cmdCustomCaption.ExecuteScalar();
        }

        private SqlConnection _dbConn = null;
        private SqlConnection GetDBConnnection()
        {
            if (_dbConn == null)
            {
                _dbConn = OpenDBConnection("BusinessReportSend");
            }

            return _dbConn;
        }
    }
}