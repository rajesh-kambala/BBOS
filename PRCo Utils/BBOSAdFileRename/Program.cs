using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using TSI.Utils;

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

            try {
                program.BBOSAdFileRename(commit);
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
            @"SELECT pradch_CompanyID,
                pradc_AdCampaignID,
                pracf_FileName,
                pracf_fileName_disk,
                pracf_filetypecode,
                pradc_AdCampaignType,
                pradc_AdCampaignTypeDigital,
                ISNULL(pradc_PeriodImpressionCount, 0) pradc_PeriodImpressionCount,
		            ISNULL(pradc_TopSpotCount,0) pradc_TopSpotCount,
                    pradc_TargetURL,
                    ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)) AS RandomNumber
                FROM PRAdCampaignHeader

                    INNER JOIN PRAdCampaign on pradc_AdCampaignHeaderID = pradch_AdCampaignHeaderID
                    INNER JOIN PRAdCampaignFile ON pracf_AdCampaignID = pradc_AdCampaignID
                WHERE
                    pracf_FileTypeCode<> 'PI'
	              ORDER BY pradch_CompanyID";

        private void BBOSAdFileRename(bool commit)
        {
            var CampaignRootPath = ConfigurationManager.AppSettings["CampaignRootPath"];
            SqlConnection dbConn = new SqlConnection(ConfigurationManager.ConnectionStrings["TSIUtils"].ConnectionString);
            try
            {
                dbConn.Open();
                string sql = SQL_BASE_SELECT;

                SqlCommand cmdAdCampaignFile = new SqlCommand(sql, dbConn);
                cmdAdCampaignFile.CommandTimeout = 600;

                using (IDataReader drAdCampaignFile = cmdAdCampaignFile.ExecuteReader(CommandBehavior.Default))
                {
                    while (drAdCampaignFile.Read())
                    {
                        int intCompanyID = drAdCampaignFile.GetInt32(0);
                        int intAdCampaignID = drAdCampaignFile.GetInt32(1);
                        string szFileName = drAdCampaignFile.GetString(2);
                        string szFileName_Disk = drAdCampaignFile.GetString(3);
                        string szFileTypeCode = drAdCampaignFile.GetString(4);

                        Console.WriteLine(string.Format("Processing Company #{0} AdCampaignID {1} FileName='{2}' FileName_Disk='{3}'", intCompanyID, intAdCampaignID, szFileName, szFileName_Disk));

                        if (File.Exists(Path.Combine(CampaignRootPath, szFileName)) && !File.Exists(Path.Combine(CampaignRootPath, szFileName_Disk)))
                        {
                            string szDirectory = Path.GetDirectoryName(Path.Combine(CampaignRootPath, szFileName_Disk));
                            Directory.CreateDirectory(szDirectory);

                            File.Copy(Path.Combine(CampaignRootPath, szFileName),
                                Path.Combine(CampaignRootPath, szFileName_Disk));
                        }
                    }
                }

                //Delete old files if commit=true
                if (commit)
                {
                    using (IDataReader drAdCampaignFile = cmdAdCampaignFile.ExecuteReader(CommandBehavior.Default))
                    {
                        while (drAdCampaignFile.Read())
                        {
                            int intCompanyID = drAdCampaignFile.GetInt32(0);
                            int intAdCampaignID = drAdCampaignFile.GetInt32(1);
                            string szFileName = drAdCampaignFile.GetString(2);
                            string szFileName_Disk = drAdCampaignFile.GetString(3);
                            string szFileTypeCode = drAdCampaignFile.GetString(4);

                            Console.WriteLine(string.Format("Deleting old file for Company #{0} AdCampaignID {1} FileName='{2}' FileName_Disk='{3}'", intCompanyID, intAdCampaignID, szFileName, szFileName_Disk));

                            if (File.Exists(Path.Combine(CampaignRootPath, szFileName)))
                                File.Delete(Path.Combine(CampaignRootPath, szFileName));
                            }
                        }
                }
            }
            finally
            {
                dbConn.Close();
            }
        }

        protected ILogger logger = null;
    
        protected void WriteLine(string msg)
        {
            Console.WriteLine(msg);
            logger.LogMessage(msg);
        }
    }
}