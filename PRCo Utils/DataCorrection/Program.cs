using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.IO;

using PRCo.EBB.BusinessObjects;
using TSI.Utils;
using PRCo.BBS;

namespace DataCorrection
{
    class Program
    {
        static void Main(string[] args)
        {
            bool commit = false;

            if ((args.Length > 0) &&
                (args[0].ToLower() == "/commit"))
            {
                commit = true;
            }


            Program program = new Program();
            //program.RemoveABRatingFromSavedSearches(commit);

            try {
                program.GenerateInvoices();
            }
            catch (Exception e) {
                Console.WriteLine();
                Console.WriteLine();
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine("An unexpected exception occurred: " + e.Message);
                Console.WriteLine(e.StackTrace);
                Console.WriteLine("Terminating execution.");
                Console.ForegroundColor = ConsoleColor.Gray;
            }

            Console.Write("Press any key to continue . . . ");
            Console.ReadKey(true);

        }




        protected const string SQL_BASE_SELECT =
            @"SELECT vBBSiMasterInvoices.*, HasLineItemDiscounts, comp_PRCommunicationLanguage,
                    prfs_StatementDate, prfs_sales,
				    PrimaryServiceDiscount,
				    comp_PRIndustryType,
                    vprl.prcn_CountryId
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

               WHERE (JournalNoGLBatchNo = '003493'
                      OR (Balance >0 AND InvoiceDueDate < GETDATE()))
                 AND prci2_BillingException IS NULL
                 AND (FaxNo <> '' OR EmailAddress <> '')";


        public void GenerateInvoices()
        {
            SqlConnection dbConn = new SqlConnection(ConfigurationManager.ConnectionStrings["SQLServer"].ConnectionString);
            try {
                dbConn.Open();
                string sql = SQL_BASE_SELECT;
                
                SqlCommand cmdInvoices = new SqlCommand(sql, dbConn);
                cmdInvoices.CommandTimeout = 600;

                ReportInterface oRI = new ReportInterface();

                // Setup our supporting files, etc.
                int invoiceCount = 0;

                using (IDataReader drInvoices = cmdInvoices.ExecuteReader(CommandBehavior.Default)) {
                    while (drInvoices.Read()) {
                        invoiceCount++;

                        Console.WriteLine(string.Format("Processing Invoice # {0}", (string)drInvoices["UDF_MASTER_INVOICE"]));

                        byte[] abReport = oRI.GenerateInvoice((string)drInvoices["UDF_MASTER_INVOICE"]);
                        string invoiceFileName = string.Format("BBSi Invoice {0}.pdf", (string)drInvoices["UDF_MASTER_INVOICE"]);

                         WriteFileToDisk(Path.Combine(@"D:\Temp\BBSI Invoices", invoiceFileName), abReport);
                    }
                }

            }
            finally {
                dbConn.Close();
            }

        }

        protected void WriteFileToDisk(string fullName, byte[] abReport)
        {
            using (FileStream oFStream = File.Create(fullName, abReport.Length)) {
                oFStream.Write(abReport, 0, abReport.Length);
            }
        }










        protected ILogger logger = null;

        protected const string SQL_GET_SAVED_SEARCHES =
            @"SELECT prsc_SearchCriteriaID, prwu_WebUserID, prwu_BBID, prwu_Email, prsc_Name
                FROM PRWebUserSearchCriteria WITH (NOLOCK)
                     INNER JOIN PRWebUser WITH (NOLOCK) ON prsc_WebUserID = prwu_WebUserID
               WHERE prsc_Criteria LIKE '%<RatingPayIDs>%7%</RatingPayIDs>%'
            ORDER BY prwu_BBID, prwu_WebUserID";

        protected void RemoveABRatingFromSavedSearches(bool commit)
        {
            logger = LoggerFactory.GetLogger();
            logger.FileName = Path.Combine(Directory.GetCurrentDirectory(), "trace_" + DateTime.Now.ToString("yyyy-MM-dd HH-mm") + ".txt");

            Console.Clear();
            Console.Title = "Data Correction Utility";
            WriteLine("Data Correction Utility");
            WriteLine("  OS Version: " + System.Environment.OSVersion.ToString());
            WriteLine(" CLR Version: " + System.Environment.Version.ToString());
            WriteLine(string.Empty);
            WriteLine(DateTime.Now.ToString());
            WriteLine(string.Empty);
            if (commit)
            {
                WriteLine("Committing Changes");
            }
            else
            {
                WriteLine("Rolling Back Changes");
            }
            WriteLine(string.Empty);


            SqlConnection dbConn = new SqlConnection(ConfigurationManager.ConnectionStrings["TSIUtils"].ConnectionString);
            SqlCommand cmd = dbConn.CreateCommand();
            cmd.CommandText = SQL_GET_SAVED_SEARCHES;
            cmd.CommandTimeout = 120;

            dbConn.Open();

            PRWebUserSearchCriteriaMgr oWebUserSearchCriteriaMgr = new PRWebUserSearchCriteriaMgr(logger, null);
            IDbTransaction dbTran = oWebUserSearchCriteriaMgr.BeginTransaction();

            int count = 0;
            try
            {
                using (SqlDataReader dr = cmd.ExecuteReader(CommandBehavior.CloseConnection))
                {

                    WriteLine("BBID, WebUserID, Email, SearchID, Search Name, Before Pay Rating, After Pay Rating");
                    
                    while (dr.Read())
                    {
                        count++;


                        int searchID = dr.GetInt32(0);
                        int webUserID = dr.GetInt32(1);
                        int bbID = dr.GetInt32(2);
                        string email = dr.GetString(3).Trim();
                        string searchName = dr.GetString(4).Trim();

                        IPRWebUserSearchCriteria oWebUserSearchCriteria = (IPRWebUserSearchCriteria)oWebUserSearchCriteriaMgr.GetObjectByKey(searchID);
                        CompanySearchCriteria criteria = (CompanySearchCriteria)oWebUserSearchCriteria.Criteria;

                        string before = criteria.RatingPayIDs;

                        if (criteria.RatingPayIDs == "7")
                        {
                            criteria.RatingPayIDs = "8";
                        }

                        if (criteria.RatingPayIDs.StartsWith("7,"))
                        {
                            criteria.RatingPayIDs = criteria.RatingPayIDs.Substring(2, (criteria.RatingPayIDs.Length - 2));
                        }

                        if (criteria.RatingPayIDs.IndexOf(",7") > -1)
                        {
                            criteria.RatingPayIDs = criteria.RatingPayIDs.Replace(",7", string.Empty);
                        }

                        WriteLine(bbID.ToString() + ", " + webUserID.ToString() + ", " + email + ", " + searchID.ToString() + ", " + searchName + ", '" + before + "', '" + criteria.RatingPayIDs + "'");

                        oWebUserSearchCriteria.Save(dbTran);
                    }
                }

                WriteLine(string.Empty);
                WriteLine("Processed " + count.ToString("###,##0") + " Saved Searches");

                if (commit)
                {
                    WriteLine("Committing Changes");
                    oWebUserSearchCriteriaMgr.Commit();
                }
                else
                {
                    WriteLine("Rolling Back Changes");
                    oWebUserSearchCriteriaMgr.Rollback();
                }

            }
            catch(Exception e)
            {
                oWebUserSearchCriteriaMgr.Rollback();
                logger.LogError(e);
            }
        }

        protected void WriteLine(string msg)
        {
            Console.WriteLine(msg);
            logger.LogMessage(msg);
        }
    }
}
