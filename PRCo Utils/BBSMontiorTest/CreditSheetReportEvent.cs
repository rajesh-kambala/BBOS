using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Data.Sql;
using System.IO;
using System.Data;
using System.Linq;
using System.Text;

using PRCO.BBS;

namespace BBSMontiorTest
{
    public class CreditSheetReportEvent
    {

        public void ProcessEvent()
        {
            SqlConnection oConn = new SqlConnection(ConfigurationManager.ConnectionStrings["SQLServer"].ConnectionString);
            SqlDataReader oReader = null;

            int iCSItemCount = 0;

            try
            {
                oConn.Open();

                DateTime dtReportDate = DateTime.Now;

                SqlCommand cmdGetLastReportDate = new SqlCommand(
                        "SELECT MAX(prcs_WeeklyCSPubDate) " +
			             "FROM PRCreditSheet WITH (NOLOCK) " +
                              "INNER JOIN Company ON prcs_CompanyID = comp_CompanyID " +
			            "WHERE prcs_WeeklyCSPubDate IS NOT NULL " +
                          "AND comp_PRIndustryType = 'L'", oConn);

                dtReportDate = (DateTime)cmdGetLastReportDate.ExecuteScalar();

                string szReportDate = dtReportDate.ToString("yyyy-MM-dd hh:mm:ss:fff tt");

                Console.WriteLine("Found Report Date of " + szReportDate);

                // Determine if any CS items have been published
                // since we last exectued.
                SqlCommand oSQLCommand = new SqlCommand("usp_GetCreditSheetCount", oConn);
                oSQLCommand.CommandType = CommandType.StoredProcedure;
                oSQLCommand.Parameters.AddWithValue("@ReportDate", dtReportDate);
                oSQLCommand.Parameters.AddWithValue("@IndustryTypeList", "L");


                using (oReader = oSQLCommand.ExecuteReader())
                {
                    if (oReader.Read())
                    {
                        iCSItemCount = oReader.GetInt32(0);
                    }
                }


                Console.WriteLine("Found " + iCSItemCount.ToString() + " items.");

                if (iCSItemCount > 0)
                {
                    // First get our report

                    ReportInterface oReportInterface = new ReportInterface();
                    byte[] abCSReport = oReportInterface.GenerateCreditSheetByPeriodReport(dtReportDate);

                    string szReportFile = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Substring(6);
                    szReportFile = Path.Combine(szReportFile, "LumberCreditSheetReport.pdf");

                    Console.WriteLine("Found Report Date of " + dtReportDate.ToString());

                    using (FileStream oFStream = File.Create(szReportFile, abCSReport.Length))
                    {
                        oFStream.Write(abCSReport, 0, abCSReport.Length);
                    }
                }


            }
            catch (Exception e)
            {
                Console.WriteLine();
                Console.WriteLine();
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine("An unexpected exception occurred: " + e.Message);
                Console.WriteLine(e.StackTrace);
                Console.WriteLine("Terminating execution.");
                Console.ForegroundColor = ConsoleColor.Gray;

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
