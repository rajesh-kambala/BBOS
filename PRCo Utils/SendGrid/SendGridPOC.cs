using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Data.SqlClient;
using System.Threading.Tasks;
using System.Threading;
using Newtonsoft.Json;
using SendGrid;
using SendGrid.Helpers.Mail;
using TSI.Utils;

namespace SendGrid
{
    public class SendGridPOC
    {
        public async Task ScoreEmailAddresses()
        {
            DateTime dtStart = DateTime.Now;

            Console.Clear();
            Console.Title = "SendGrid POC Utility";
            WriteLine("SendGrid POC Utility 1.0");
            WriteLine("Copyright (c) 2023 Blue Book Services");
            WriteLine("All Rights Reserved.");
            WriteLine("  OS Version: " + System.Environment.OSVersion.ToString());
            WriteLine(" CLR Version: " + System.Environment.Version.ToString());
            WriteLine(string.Empty);
            WriteLine(DateTime.Now.ToString("M/dd/yyyy hh:mm tt"));
            WriteLine(string.Empty);

            List<BBEmailAddress> bbEmails = GetMembershipBillingEmails("01");
            List<EmailValidationResult> results = await ScoreEmailAddresses(bbEmails);

            string dataFile = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Substring(6);
            dataFile = Path.Combine(dataFile, "MembershipBillngEmailValidation.csv");
            WriteDataFile(results, dataFile);

            bbEmails = GetDLBillingEmails();
            results = await ScoreEmailAddresses(bbEmails);

            dataFile = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Substring(6);
            dataFile = Path.Combine(dataFile, "DLBillingEmailValidation.csv");
            WriteDataFile(results, dataFile);

        }

        public async Task<List<EmailValidationResult>> ScoreEmailAddresses(List<BBEmailAddress> bbEmails)
        {
            List<EmailValidationResult> results = new List<EmailValidationResult>();
            try
            {
                foreach (BBEmailAddress bbEmail in bbEmails)
                {
                    WriteLine($"Validating {bbEmail.CompanyID} - {bbEmail.Email}");
                    EmailValidationResult validationResult = await ScoreEmailAddress(bbEmail.Email);
                    validationResult.BBID = bbEmail.CompanyID;
                    validationResult.PersonID = bbEmail.PersonID;

                    if (validationResult.verdict.ToLower() != "valid")
                        results.Add(validationResult);

                    Thread.Sleep(200);
                }

                return results;
            }
            catch (Exception eX)
            {
                WriteLine(eX.Message);
                WriteLine(eX.StackTrace);
                throw;
            }
        }

        public async Task<EmailValidationResult> ScoreEmailAddress(string emailAddress)
        {
            try
            {
                var apiKey = Utilities.GetConfigValue("SENDGRID_VALIDATION_API_KEY");
                var client = new SendGridClient(apiKey: apiKey);

                string data = $"{{\"email\":\"{emailAddress}\",\"source\": \"crmpoc\"}}";

                var response = await client.RequestAsync(method: SendGridClient.Method.POST, urlPath: "validations/email", requestBody: data);
                string jsonPayload = response.Body.ReadAsStringAsync().Result;

                //WriteLine(response.StatusCode.ToString());
                //WriteLine(jsonPayload);
                //WriteLine(response.Headers.ToString());

                jsonPayload = jsonPayload.Substring(10);
                jsonPayload = jsonPayload.Substring(0, jsonPayload.Length - 1);
                jsonPayload = jsonPayload.Trim();

                EmailValidationResult emailResult = JsonConvert.DeserializeObject<EmailValidationResult>(jsonPayload);
                return emailResult;
            } catch (Exception eX) {
                WriteLine(eX.Message);
                WriteLine(eX.StackTrace);

                //throw;
            }

            return null;
        }

        protected string _szOutputFile;
        protected List<string> _lszOutputBuffer = new List<string>();

        private void WriteLine(string msg)
        {
            if (_szOutputFile == null)
            {
                _szOutputFile = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Substring(6);
                _szOutputFile = Path.Combine(_szOutputFile, "SendGrid.txt");
            }

            Console.WriteLine(msg);
            _lszOutputBuffer.Add(msg);
        }

        private void WriteDataFile(List<EmailValidationResult> emailResults, string fileName)
        {
            using (StreamWriter sw = new StreamWriter(fileName))
            {
                sw.WriteLine("CompanyID,PersonID,Email,Verdict,Score,Has Valid Address Syntax,Has MX or A Record,Is Suspected Disposable Address,Is Suspected Role Address,Has Known Bounces,Has Suspected Bounces");

                foreach (EmailValidationResult emailResult in emailResults)
                {
                    sw.WriteLine($"{emailResult.BBID},{emailResult.PersonID},{emailResult.email},{emailResult.verdict},{emailResult.score},{emailResult.checks.domain.has_valid_address_syntax},{emailResult.checks.domain.has_mx_or_a_record},{emailResult.checks.domain.is_suspected_disposable_address},{emailResult.checks.local_part.is_suspected_role_address},{emailResult.checks.additional.has_known_bounces},{emailResult.checks.additional.has_suspected_bounces}");
                }
            }
        }

        private const string SQL_SELECT_MEMBERSHIP_BILLING_EMAIL =
            @"SELECT prattn_CompanyID, prattn_PersonID, prattn_EmailID, RTRIM(emai_EmailAddress) emai_EmailAddress
                FROM PRAttentionLine WITH (NOLOCK)
                     INNER JOIN Company WITH (NOLOCK) ON prattn_CompanyID= comp_CompanyID
	                 INNER JOIN Email WITH (NOLOCK) ON Emai_EmailId = prattn_EmailID
		             INNER JOIN PRService WITH (NOLOCK) ON prattn_CompanyID = prse_CompanyID AND prse_Primary='Y'
               WHERE BillingMonth = '{0}'
                 AND prattn_Disabled IS NULL
                 AND prattn_ItemCode IN ('BILL')
                 AND prattn_EmailID IS NOT NULL
            ORDER BY prattn_CompanyID";

        private List<BBEmailAddress> GetMembershipBillingEmails(string billingMonth)
        {
            return GetEmailAddresses(string.Format(SQL_SELECT_MEMBERSHIP_BILLING_EMAIL, billingMonth));
        }

        private const string SQL_SELECT_DL_BILLING_EMAIL =
            @"SELECT prattn_CompanyID, prattn_PersonID, prattn_EmailID, RTRIM(emai_EmailAddress) emai_EmailAddress
                FROM PRAttentionLine WITH (NOLOCK)
                    INNER JOIN Company WITH (NOLOCK) ON prattn_CompanyID= comp_CompanyID
	                INNER JOIN Email WITH (NOLOCK) ON Emai_EmailId = prattn_EmailID
		            LEFT OUTER JOIN PRService ON prattn_CompanyID = prse_CompanyID AND prse_Primary='Y'
		            LEFT OUTER JOIN (SELECT DISTINCT prdl_CompanyId FROM PRDescriptiveLine WITH (NOLOCK)) T1 ON prattn_CompanyID = prdl_CompanyId
              WHERE prse_ServiceCode IS NULL
                AND comp_PRPublishDL='Y'
	            AND prdl_CompanyId IS NOT NULL
                AND prattn_Disabled IS NULL
                AND prattn_ItemCode IN ('BILL')
            ORDER BY prattn_CompanyID";


        private List<BBEmailAddress> GetDLBillingEmails()
        {
            return GetEmailAddresses(SQL_SELECT_DL_BILLING_EMAIL);
        }

        private List<BBEmailAddress> GetEmailAddresses(string sql)
        {
            List<BBEmailAddress> bbEmails = new List<BBEmailAddress>();

            using (SqlConnection sqlConn = new SqlConnection(ConfigurationManager.ConnectionStrings["SQLServer"].ConnectionString))
            {
                sqlConn.Open();
                SqlCommand commandCompanies = new SqlCommand();
                commandCompanies.Connection = sqlConn;
                commandCompanies.CommandText = sql;

                using (SqlDataReader reader = commandCompanies.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        BBEmailAddress bbEmail = new BBEmailAddress();
                        bbEmail.CompanyID = reader.GetInt32(0);

                        if (reader[1] != DBNull.Value)
                            bbEmail.PersonID = reader.GetInt32(1);

                        bbEmail.EmailID = reader.GetInt32(2);
                        bbEmail.Email = reader.GetString(3);
                        bbEmails.Add(bbEmail);
                    }
                }
            }

            return bbEmails;
        }
    }

    public class BBEmailAddress
    {
        public int CompanyID;
        public int PersonID;
        public int EmailID;
        public string Email;
    }
}
