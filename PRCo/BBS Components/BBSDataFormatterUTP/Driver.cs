using System;
using System.Data;
using System.Data.SqlClient;

namespace PRCO.BBS
{
	/// <summary>
	/// Summary description for Class1.
	/// </summary>
	class Driver
	{
		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		[STAThread]
		static void Main(string[] args)
		{

            FaxTest2();
            //BBSDataFormatterTest oTest = new BBSDataFormatterTest();
            //oTest.Init();
            //oTest.TestBusinessEventAgreementInPrinciple();

            //long lInterval = 525600L * 6000L;
            //DateTime dtNextExecution = new DateTime(2006, 1, 1, 18, 0, 0);

            //while (dtNextExecution < DateTime.Now) {
            //    dtNextExecution = dtNextExecution.AddMilliseconds(lInterval);
            //}

            //System.Console.Write(dtNextExecution.ToString());

		}

        static void FaxTest() {
            SqlConnection oConn = new SqlConnection(@"Data Source=sql01;Integrated Security=SSPI;Initial Catalog=CRM;Application Name=FaxTest");

            try {
                string szRecipient = "/fax=847 680-4777/ <fax@rfgateway.bluebookprco.local>";
                //string szRecipient = "fax@rfgateway.bluebookprco.local";
                string szContent = "<TOFAXNUM:847 680-4777><NOCOVER>\nTest " + DateTime.Now.ToString() + " Fax from DBMail and PRCo";
                
                oConn.Open();

                SqlCommand oSQLCommand = new SqlCommand("msdb.dbo.sp_send_dbmail", oConn);
                oSQLCommand.CommandType = CommandType.StoredProcedure;
                oSQLCommand.Parameters.AddWithValue("@profile_name", "RightFax");
                oSQLCommand.Parameters.AddWithValue("@recipients", szRecipient);
                //oSQLCommand.Parameters.AddWithValue("@body", szContent);
                oSQLCommand.Parameters.AddWithValue("@file_attachments", @"D:\SageCRM5.8\CRM\WWWRoot\TempReports\AUSSettingsReport_083408_144716.pdf");

                int iReturn = Convert.ToInt32(oSQLCommand.ExecuteScalar());

                if (iReturn != 0) {
                    throw new ApplicationException("Non-zero return code sending: " + iReturn.ToString());
                }

            } finally {
                oConn.Close();
            }
        }

        static void FaxTest2() {

            SqlConnection oConn = new SqlConnection(@"Data Source=sql01;Integrated Security=SSPI;Initial Catalog=CRM;Application Name=FaxTest");

            try {
                oConn.Open();
                SqlCommand oSQLCommand = new SqlCommand("usp_CreateEmail", oConn);
                oSQLCommand.CommandType = CommandType.StoredProcedure;
                oSQLCommand.Parameters.AddWithValue("@CreatorUserId", -1);
                oSQLCommand.Parameters.AddWithValue("@From", "Fax Test");
                oSQLCommand.Parameters.AddWithValue("@Subject", "Fax Test Subject");
                //oSQLCommand.Parameters.AddWithValue("@Content", szContent);
                //oSQLCommand.Parameters.AddWithValue("@RelatedPersonId", oReportUser.PersonID);
                oSQLCommand.Parameters.AddWithValue("@RelatedCompanyId", 102030);
                oSQLCommand.Parameters.AddWithValue("@To", "847 680-4777");
                oSQLCommand.Parameters.AddWithValue("@Action", "FaxOut");

                oSQLCommand.Parameters.AddWithValue("@AttachmentDir", @"D:\SageCRM5.8\CRM\WWWRoot\TempReports\");
                oSQLCommand.Parameters.AddWithValue("@AttachmentFileName", @"D:\SageCRM5.8\CRM\WWWRoot\TempReports\AUSSettingsReport_083408_144716.pdf");

                int iReturn = Convert.ToInt32(oSQLCommand.ExecuteScalar());
                if (iReturn != 0) {
                    throw new ApplicationException("Non-zero return code sending: " + iReturn.ToString());
                }
            } finally {
                oConn.Close();
            }


        }
	}
}
