using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Net;
using System.Net.Mail;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;

using TSI.Arch;
using TSI.Utils;
using System.Data.Odbc;
using LumenWorks.Framework.IO.Csv;

namespace BBOSEmailer
{
    public class Emailer
    {
        public void SendEmail(string emailTemplate, string subject, string fromName, string emailListFile)
        {
            DateTime dtExecutionStartDate = DateTime.Now;
            WriteLine(string.Empty);
            WriteLine($"Starting {dtExecutionStartDate}");
            WriteLine($"Template={emailTemplate}");
            WriteLine($"Subject={subject}");
            WriteLine($"FomName={fromName}");
            WriteLine($"EmailListFile={emailListFile}");

            WriteLine(string.Empty);

            string emailBody = null;
            using (StreamReader sr = new StreamReader(Path.Combine(ConfigurationManager.AppSettings["TemplateFolder"], emailTemplate)))
            {
                emailBody = sr.ReadToEnd();
            }

            int totalCount = 0;
            int count = 0;
            int exceptionCount = 0;
            int sentCount = 0;
            int unsentCount = 0;

            List<string> emailAddresses = new List<string>();

            using (CsvReader csvCount = new CsvReader(new StreamReader(emailListFile), true))
            {
                while (csvCount.ReadNextRecord())
                {
                    emailAddresses.Add(csvCount[0]);
                    totalCount++;
                }
            }

            foreach(string email in emailAddresses )
            {
                count++;

                WriteLine($" - Sending {count:###,##0} of {totalCount:###,##0} to {email}");

                try
                {
                    SendMail(email, fromName, subject, emailBody);
                    sentCount++;
                }
                catch (Exception eX)
                {
                    exceptionCount++;
                    WriteLine($" - EXCEPTION: {eX.Message}");

                    if (exceptionCount > 25)
                    {
                        WriteLine(string.Empty);
                        WriteLine($"EXITING - TOO MANY EXCEPTIONS");
                        break;
                    }
                }
            }
            WriteLine(string.Empty);
            WriteLine("  Emails Sent: " + sentCount.ToString("###,##0"));
            WriteLine("Emails Unsent: " + unsentCount.ToString("###,##0"));
            WriteLine("Execution Time: " + DateTime.Now.Subtract(dtExecutionStartDate).ToString());

            using (StreamWriter sw = new StreamWriter(_szOutputFile))
            {
                foreach (string line in _lszOutputBuffer)
                {
                    sw.WriteLine(line);
                }
            }
        }



        private const string SQL_SELECT_BBOS_USERS =
            @"SELECT TOP({0}) pers_PersonID, comp_CompanyID, 
                       dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, pers_PRNickName1, pers_Suffix) As FullName, 
 	                   comp_PRCorrTradestyle, RTRIM(prwu_Email) As Email 
                  FROM Person_Link WITH (NOLOCK)
                       INNER JOIN Person WITH (NOLOCK) ON peli_PersonID = pers_PersonID 
                       INNER JOIN Company WITH (NOLOCK) ON peli_CompanyID = comp_CompanyID 
                       INNER JOIN PRWebUser WITH (NOLOCK) ON peli_PersonLinkID = prwu_PersonLinkID 
                       INNER JOIN PRCompanyIndicators WITH (NOLOCK) ON peli_CompanyID = prci2_CompanyID
                 WHERE peli_PRStatus In ('1') 
                   AND CAST(prwu_AccessLevel as INT) > 100
                   AND prci2_Suspended IS NULL
                   {1}
              ORDER BY comp_PRCorrTradestyle, pers_LastName, pers_FirstName";



        public void SendEmail(string emailTemplate, string subject, string fromName, string industry, int emailLimit)
        {
            DateTime dtExecutionStartDate = DateTime.Now;
            WriteLine(string.Empty);
            WriteLine($"Starting {dtExecutionStartDate}");
            WriteLine($"Template={emailTemplate}");
            WriteLine($"Subject={subject}");
            WriteLine($"FomName={fromName}");
            WriteLine($"Industry={industry}");

            WriteLine(string.Empty);

            string emailBody = null;
            using (StreamReader sr = new StreamReader(Path.Combine(ConfigurationManager.AppSettings["TemplateFolder"], emailTemplate)))
            {
                emailBody = sr.ReadToEnd();
            }

            string industryClause = string.Empty;
            if (industry == "L")
                industryClause = "AND comp_PRIndustryType ='L'";
            else
                industryClause = "AND comp_PRIndustryType <> 'L'";

            string sql = string.Format(SQL_SELECT_BBOS_USERS, emailLimit, industryClause);

            int exceptionCount = 0;
            int sentCount = 0;
            int unsentCount = 0;

            using (SqlConnection oConn = new SqlConnection(ConfigurationManager.AppSettings["DBConnectionString"])) {
                oConn.Open();

                SqlCommand oSelectCommand = oConn.CreateCommand();
                oSelectCommand.CommandText = sql;
                oSelectCommand.CommandTimeout = 300;
                oSelectCommand.CommandType = CommandType.Text;

                using (SqlDataReader oReader = oSelectCommand.ExecuteReader())
                {
                    while (oReader.Read())
                    {
                        if (oReader[4] == DBNull.Value)
                        {
                            WriteLine($"{oReader.GetString(3)} BB# {oReader.GetInt32(1)} - {oReader.GetString(2)}");
                            WriteLine($" - No email address found.");
                            unsentCount++;
                            continue;
                        }

                        WriteLine($"{oReader.GetString(3)} BB# {oReader.GetInt32(1)} - {oReader.GetString(2)} at {oReader.GetString(4)}");

                        try
                        {
                            string email = oReader.GetString(4);
                            SendMail(email, fromName, subject, emailBody);
                            sentCount++;
                        } catch (Exception eX)
                        {
                            exceptionCount++;
                            WriteLine($" - EXCEPTION: {eX.Message}");

                            if (exceptionCount > 25)
                            {
                                WriteLine(string.Empty);
                                WriteLine($"EXITING - TOO MANY EXCEPTIONS");
                                break;
                            }
                        }
                    }
                }
            }
            WriteLine(string.Empty);
            WriteLine("  Emails Sent: " + sentCount.ToString("###,##0"));
            WriteLine("Emails Unsent: " + unsentCount.ToString("###,##0"));
            WriteLine("Execution Time: " + DateTime.Now.Subtract(dtExecutionStartDate).ToString());

            using (StreamWriter sw = new StreamWriter(_szOutputFile))
            {
                foreach (string line in _lszOutputBuffer)
                {
                    sw.WriteLine(line);
                }
            }
        }

        protected string _szOutputFile;
        protected List<string> _lszOutputBuffer = new List<string>();

        private void WriteLine(string msg)
        {
            if (_szOutputFile == null)
            {
                _szOutputFile = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Substring(6);
                _szOutputFile = Path.Combine(_szOutputFile, "Emailer.txt");
            }

            Console.WriteLine(msg);
            _lszOutputBuffer.Add(msg);
        }

        private void SendMail(string szToAddress,
                              string szFromName,
                              string szSubject,
                              string szMessage)
        {
            SendMail(szToAddress,
                      "newsletter@bluebookservices.com",
                      szFromName,
                      szSubject,
                      szMessage,
                      true,
                      null,
                      null);
        }

        /// <summary>
        /// Sends email.
        /// </summary>
        private void SendMail(string szToAddress,
                                        string szFromAddress,
                                        string szFromName,
                                        string szSubject,
                                        string szMessage,
                                        bool bIsBodyHTML,
                                        Attachment attachment,
                                        string szCCAddress)
        {
            if (!string.IsNullOrEmpty(Utilities.GetConfigValue("EmailSMTPToOverride", string.Empty)))
                szToAddress = Utilities.GetConfigValue("EmailSMTPToOverride", string.Empty);

            MailMessage oMessage = new MailMessage();
            oMessage.From = new MailAddress(szFromAddress, szFromName);

            string[] aszToAddresses = szToAddress.Split(',');
            foreach (string szAddress in aszToAddresses)
            {
                try
                {
                    oMessage.To.Add(new MailAddress(szAddress));
                }
                catch (FormatException)
                {
                    throw new ApplicationExpectedException("An invalid email address has been specified: " + szAddress);
                }
            }

            if (!string.IsNullOrEmpty(szCCAddress))
            {
                string[] aszCCAddresses = szCCAddress.Split(',');
                foreach (string szAddress in aszCCAddresses)
                {
                    oMessage.CC.Add(new MailAddress(szAddress));
                }
            }

            oMessage.Subject = szSubject;
            oMessage.Body = szMessage;
            oMessage.IsBodyHtml = bIsBodyHTML;

            if (attachment != null)
                oMessage.Attachments.Add(attachment);


            WriteMailToFile(oMessage);

            // If mail is disabled, then
            // exit.
            if (!Utilities.GetBoolConfigValue("EmailEnabled"))
                return;

            SmtpClient oClient = new SmtpClient(Utilities.GetConfigValue("EMailSMTPServer"));
            oClient.Port = Utilities.GetIntConfigValue("EmailSMTPPort", 25);
            oClient.EnableSsl = Utilities.GetBoolConfigValue("EmailSMTPEnableSSL", false);

            if (Utilities.GetBoolConfigValue("EMailSMTPServerAuthenticate", false))
            {
                oClient.Credentials = new NetworkCredential(Utilities.GetConfigValue("EMailSMTPUserName"),
                                                            Utilities.GetConfigValue("EMailSMTPPassword"),
                                                            Utilities.GetConfigValue("EMailSMTPDomain"));
            }

            oClient.Send(oMessage);
        }

        /// <summary>
        /// Writes the contents of the email message
        /// to disk.
        /// </summary>
        /// <param name="oMessage">Message</param>
        private void WriteMailToFile(MailMessage oMessage)
        {
            if (!Utilities.GetBoolConfigValue("EmailWriteToFileEnabled", false))
                return;

            if (Utilities.GetBoolConfigValue("EmailWriteToFileEML", true))
            {
                SmtpClient client = new SmtpClient();
                client.DeliveryMethod = SmtpDeliveryMethod.SpecifiedPickupDirectory;
                client.PickupDirectoryLocation = Utilities.GetConfigValue("EmailFilePath");
                client.Send(oMessage);
                return;
            }

            string szFileName = Path.Combine(Utilities.GetConfigValue("EmailFilePath"), DateTime.Now.ToString("yyyyMMdd_HHmmssff") + "_" + oMessage.To + "_" + oMessage.Subject);
            if (oMessage.IsBodyHtml)
                szFileName += ".html";
            else
                szFileName += ".txt";

            using (StreamWriter oEmailFile = new StreamWriter(szFileName))
            {
                oEmailFile.Write(oMessage.Body);
            }
        }
    }
}
