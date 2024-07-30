using System;
using System.Configuration;
using System.Collections.Generic;
using System.Collections;
using System.Linq;
using System.Text;
using System.IO;
using System.Data;
using System.Data.OleDb;
using System.Data.SqlClient;

namespace OKSAdditionalDataImport
{
    public class OKSImporter
    {

        public string Destination = null;
        public string InputFile = null;
        public string OutputFolder = null;
        public bool CommitChanges = false;


        protected List<string> _lszOutputBuffer = new List<string>();
        protected List<string> _lszExceptionBuffer = new List<string>();


        protected const int UPDATED_BY = -55;
        protected DateTime UPDATED_DATE = DateTime.Now;

        protected SqlConnection _dbConn = null;
        protected OleDbConnection driverConnection = null;

        public int CompanyCount = 0;
        public int SkippedCount = 0;

        public int SpecieInsertedCount = 0;
        public int ProductInsertedCount = 0;
        public int EmailInsertedCount = 0;

        public int VolumeAddedCount = 0;
        public int VolumeSkippedCount = 0;
        
        public int ErrorCount = 0;

        private const string MSEXCEL_CONN = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source={0};Extended Properties=Excel 8.0;Excel 12.0;HDR=YES;";


        public void ExecuteImport(object form)
        {
            DateTime dtStart = DateTime.Now;

            Form1 form1 = (Form1)form;

            try
            {
                // The Profile_Output table in the MS Access database
                // is our driver.
                string msExcelConn = String.Format(ConfigurationManager.ConnectionStrings["MSExcel"].ConnectionString, InputFile);


                driverConnection = new OleDbConnection(msExcelConn);
                _dbConn = new SqlConnection(ConfigurationManager.ConnectionStrings[Destination + "CRM"].ConnectionString);

                WriteLine("Processing OKS file: " + InputFile);
                if (CommitChanges)
                {
                    WriteLine("Commiting Changes.");
                }


                driverConnection.Open();
                _dbConn.Open();

                //if (Destination == "Test")
                //{
                //    KillCSItems();
                //}

                OleDbCommand cmdCompanyCount = driverConnection.CreateCommand();
                cmdCompanyCount.CommandText = "SELECT COUNT(1) FROM [Product Survey Companies$]";
                int count = (int)cmdCompanyCount.ExecuteScalar();


                form1.initProgressBar(count);

                OleDbCommand cmdProfileOutput = driverConnection.CreateCommand();
                cmdProfileOutput.CommandText = "SELECT * FROM [Product Survey Companies$] ORDER BY BBID";

                using (OleDbDataReader drProfileOuput = cmdProfileOutput.ExecuteReader())
                {
                    while (drProfileOuput.Read())
                    {
                        bool bUpdateCompany = false;
                        CompanyCount++;

                        string szBatchID = Convert.ToString(drProfileOuput["BATCH_ID"]);
                        int iCompanyID = Convert.ToInt32(drProfileOuput["BBID"]);
                        WriteLine("Processing Company ID: " + iCompanyID.ToString());

                        string szDisposition = (string)drProfileOuput["OKS_DISPOSITION"];
                        if (szDisposition.StartsWith("C2") ||
                            szDisposition.StartsWith("C3") ||
                            szDisposition.StartsWith("C6") ||
                            szDisposition.StartsWith("REFUSED"))
                        {
                            bUpdateCompany = true;
                        }

                        if (!bUpdateCompany)
                        {
                            object[] args = { iCompanyID, szBatchID, string.Empty, string.Empty, string.Empty, szDisposition };
                            SkippedCount++;
                        } else {

                            SqlTransaction oTran = _dbConn.BeginTransaction();
                            try
                            {

                                int iPIKSCompanyTransID = OpenPIKSTransaction(iCompanyID,
                                                                              drProfileOuput,
                                                                              oTran);


                                string profileMsg = UpdateProfile(iCompanyID, Convert.ToString(drProfileOuput["OKS_MMBF"]), oTran);
                                InsertEmail(iCompanyID, Convert.ToString(drProfileOuput["OKS_Email"]), oTran);
                                string productMsg = AddProducts(iCompanyID, iPIKSCompanyTransID, oTran);
                                string specieMsg = AddSpecie(iCompanyID, iPIKSCompanyTransID, oTran);

                                ClosePIKSTransaction(iPIKSCompanyTransID, oTran);

                                CreateTask(drProfileOuput, iCompanyID, specieMsg, productMsg, profileMsg, oTran);

                                if (CommitChanges)
                                {
                                    oTran.Commit();
                                }
                                else
                                {
                                    oTran.Rollback();
                                }
                            }
                            catch (Exception e)
                            {
                                oTran.Rollback();

                                WriteLine(string.Empty);
                                WriteLine(e.Message);
                                WriteLine(e.StackTrace);

                                ErrorCount++;
                            }

                            //break;
                        }

                        form1.incrementProgressBar();
                    } // End While
                } // End Using
            }
            catch (Exception e)
            {
                string szOutputFile = Path.Combine(OutputFolder, "Error.txt");
                using (StreamWriter sw = new StreamWriter(szOutputFile))
                {
                    sw.WriteLine(e.Message);
                    sw.WriteLine(e.StackTrace);
                }

                form1.handleException(e);
            }
            finally
            {
                driverConnection.Close();
                _dbConn.Close();

                WriteLine(string.Empty);
                WriteLine("        Company Count: " + CompanyCount.ToString("###,##0"));
                WriteLine("Skipped Company Count: " + SkippedCount.ToString("###,##0"));
                WriteLine("      Emails Inserted: " + EmailInsertedCount.ToString("###,##0"));
                WriteLine("     Species Inserted: " + SpecieInsertedCount.ToString("###,##0"));
                WriteLine("    Products Inserted: " + ProductInsertedCount.ToString("###,##0"));
                WriteLine("         Added Volume: " + VolumeAddedCount.ToString("###,##0"));
                WriteLine("       Skipped Volume: " + VolumeSkippedCount.ToString("###,##0"));

                if (ErrorCount > 0)
                {
                    WriteLine("          Error Count: " + ErrorCount.ToString("###,##0"));
                }

                WriteLine("Execution Time: " + DateTime.Now.Subtract(dtStart).ToString());


                string filePrefix = DateTime.Now.ToString("yyyy-MM-dd HH-mm");

                string szOutputFile = Path.Combine(OutputFolder, filePrefix + " Log.txt");

                using (StreamWriter sw = new StreamWriter(szOutputFile))
                {
                    foreach (string szLine in _lszOutputBuffer)
                    {
                        sw.WriteLine(szLine);
                    }
                }


                if (_lszExceptionBuffer.Count > 0)
                {
                    szOutputFile = Path.Combine(OutputFolder, filePrefix + " Exceptions.txt");
                    using (StreamWriter sw = new StreamWriter(szOutputFile))
                    {
                        foreach (string szLine in _lszExceptionBuffer)
                        {
                            sw.WriteLine(szLine);
                        }
                    }
                }

                form1.displaySuccess(this);
            }
        }



        protected int OpenPIKSTransaction(int iCompanyID,
                                          OleDbDataReader drProfileOuput,
                                          SqlTransaction oTran)
        {
            SqlCommand sqlOpenPIKSTransaction = _dbConn.CreateCommand();
            sqlOpenPIKSTransaction.Transaction = oTran;
            sqlOpenPIKSTransaction.CommandText = "usp_CreateTransaction";
            sqlOpenPIKSTransaction.CommandType = CommandType.StoredProcedure;
            sqlOpenPIKSTransaction.Parameters.AddWithValue("UserId", UPDATED_BY);

            sqlOpenPIKSTransaction.Parameters.AddWithValue("prtx_CompanyId", iCompanyID);
            sqlOpenPIKSTransaction.Parameters.AddWithValue("prtx_Explanation", "Data changes resulting from OKS call campaign.");
            sqlOpenPIKSTransaction.Parameters.AddWithValue("prtx_EffectiveDate", (DateTime)drProfileOuput["CALL_DATE"]);

            SqlParameter oReturnParm = new SqlParameter();
            oReturnParm.ParameterName = "NextId";
            oReturnParm.Value = 0;
            oReturnParm.Direction = ParameterDirection.ReturnValue;
            sqlOpenPIKSTransaction.Parameters.Add(oReturnParm);

            sqlOpenPIKSTransaction.ExecuteNonQuery();
            return Convert.ToInt32(oReturnParm.Value);
        }

        protected const string SQL_PRTRANSACTION_CLOSE = "UPDATE PRTransaction SET prtx_Status='C', prtx_CloseDate=GETDATE(), prtx_UpdatedBy=-1, prtx_UpdatedDate=GETDATE(), prtx_Timestamp=GETDATE() WHERE prtx_TransactionId=@TransactionID";

        /// <summary>
        /// Updates the specified PRTransaction setting the appropriate
        /// values to close it.
        /// </summary>
        /// <param name="iTransactionID"></param>
        /// <param name="oTran"></param>
        public void ClosePIKSTransaction(int iTransactionID, SqlTransaction oTran)
        {
            if (iTransactionID <= 0)
            {
                return;
            }

            SqlCommand sqlCloseTransaction = _dbConn.CreateCommand();
            sqlCloseTransaction.Transaction = oTran;
            sqlCloseTransaction.Parameters.Add(new SqlParameter("TransactionID", iTransactionID));
            sqlCloseTransaction.CommandText = SQL_PRTRANSACTION_CLOSE;

            if (sqlCloseTransaction.ExecuteNonQuery() == 0)
            {
                throw new ApplicationException("Unable to close transaction: " + iTransactionID.ToString());
            }
        }

        protected void CreateTask(OleDbDataReader drProfileOuput, int iBBID, string specieOther, string productOther, string profileMsg, SqlTransaction oTran)
        {
            string szStatus = "Closed";

            StringBuilder sbTaskMsg = new StringBuilder("Successful contact by OKS." + Environment.NewLine);
            sbTaskMsg.Append("Call Date: " + Convert.ToDateTime(drProfileOuput["CALL_DATE"]).ToString("MM/dd/yyyy h:mm tt") + Environment.NewLine);
            sbTaskMsg.Append("OKS Disposition: " + Convert.ToString(drProfileOuput["OKS_DISPOSITION"]) + Environment.NewLine);
            sbTaskMsg.Append("Batch ID: " + Convert.ToString(drProfileOuput["BATCH_ID"]) + Environment.NewLine);

            if (drProfileOuput["Remark"] != DBNull.Value)
            {
                sbTaskMsg.Append("Remark: " + Convert.ToString(drProfileOuput["Remark"]) + Environment.NewLine);
            }
            

            if (!string.IsNullOrEmpty(profileMsg))
            {
                sbTaskMsg.Append(profileMsg + Environment.NewLine);
            }

            if (!string.IsNullOrEmpty(productOther))
            {
                sbTaskMsg.Append("Found \"Other\" Products: " + Environment.NewLine);
                sbTaskMsg.Append(productOther + Environment.NewLine);
            }

            if (!string.IsNullOrEmpty(specieOther))
            {
                sbTaskMsg.Append("Found \"Other\" Specie: " + Environment.NewLine);
                sbTaskMsg.Append(specieOther + Environment.NewLine);
            }


            SqlCommand cmdCreateTask = _dbConn.CreateCommand();
            cmdCreateTask.CommandText = "usp_CreateTask";
            cmdCreateTask.CommandType = CommandType.StoredProcedure;
            cmdCreateTask.Transaction = oTran;
            cmdCreateTask.Parameters.AddWithValue("StartDateTime", DateTime.Now);
            cmdCreateTask.Parameters.AddWithValue("DueDateTime", DateTime.Now);
            cmdCreateTask.Parameters.AddWithValue("CreatorUserId", UPDATED_BY);
            cmdCreateTask.Parameters.AddWithValue("AssignedToUserId", Convert.ToInt32(ConfigurationManager.AppSettings["AssignedToUserId"]));

            cmdCreateTask.Parameters.AddWithValue("TaskNotes", sbTaskMsg.ToString());
            cmdCreateTask.Parameters.AddWithValue("Status", szStatus);
            cmdCreateTask.Parameters.AddWithValue("RelatedCompanyID", iBBID);
            cmdCreateTask.ExecuteNonQuery();
        }


        protected int GetPIKSID(string szTableName, SqlTransaction oTran)
        {
            SqlCommand sqlGetID = _dbConn.CreateCommand();
            sqlGetID.Transaction = oTran;
            sqlGetID.CommandText = "usp_getNextId";
            sqlGetID.CommandType = CommandType.StoredProcedure;

            sqlGetID.Parameters.Add(new SqlParameter("TableName", szTableName));

            SqlParameter oReturnParm = new SqlParameter();
            oReturnParm.ParameterName = "Return";
            oReturnParm.Value = 0;
            oReturnParm.Direction = ParameterDirection.Output;
            sqlGetID.Parameters.Add(oReturnParm);

            sqlGetID.ExecuteNonQuery();

            return Convert.ToInt32(oReturnParm.Value);
        }

        private const string SQL_UPDATE_CS_ITEMS =
            @"UPDATE PRCreditSheet 
               SET prcs_Status = 'K', 
                   prcs_UpdatedBy = -55, 
                   prcs_UpdatedDate = GETDATE() 
             FROM PRCreditSheet 
                  INNER JOIN Company ON prcs_CompanyID = comp_CompanyID 
            WHERE prcs_Status = 'P' 
              AND prcs_WeeklyCSPubDate IS NULL 
              AND comp_PRIndustryType = 'L'";

        protected void KillCSItems()
        {
            SqlCommand cmdUpdateCSItems = _dbConn.CreateCommand();
            cmdUpdateCSItems.CommandText = SQL_UPDATE_CS_ITEMS;
            cmdUpdateCSItems.ExecuteNonQuery();
        }

        protected void WriteLine(string szLine)
        {
            _lszOutputBuffer.Add(szLine);
        }


        private const string SQL_INTERNET_SELECT = "SELECT Emai_EmailId FROM Email WHERE Emai_CompanyID=@CompanyID AND Emai_PersonID IS NULL AND Emai_Type=@Type AND Emai_EmailAddress=@Email";
        private const string SQL_INTERNET_INSERT = "INSERT INTO Email (Emai_EmailId, Emai_CompanyID, Emai_Type, Emai_PRDescription, Emai_EmailAddress, Emai_PRPublish, emai_PRPreferredPublished, emai_PRPreferredInternal, Emai_CreatedBy, Emai_CreatedDate, Emai_UpdatedBy, Emai_UpdatedDate, Emai_Timestamp) " +
                                                   "VALUES (@InternetID, @CompanyID, @Type, @Description, @Email, @PRPublish, @PRPublish, @Default, @UpdatedBy, @UpdatedDate, @UpdatedBy, @UpdatedDate, @Timestamp)";

        protected void InsertEmail(int iCompanyID, string szOKSValue, SqlTransaction oTran)
        {

            if (string.IsNullOrEmpty(szOKSValue))
            {
                return;
            }

            string szEmail = szOKSValue.ToLower();

            // First we need to see if we have an existing record.
            SqlCommand cmdInternet = _dbConn.CreateCommand();
            cmdInternet.CommandText = SQL_INTERNET_SELECT;
            cmdInternet.Transaction = oTran;
            cmdInternet.Parameters.AddWithValue("CompanyID", iCompanyID);
            cmdInternet.Parameters.AddWithValue("Type", "E");
            cmdInternet.Parameters.AddWithValue("Email", szEmail);

            // If the email already exists for this company,
            // then don't add it.
            object oInternetID = cmdInternet.ExecuteScalar();
            if (oInternetID != null)
            {
                return;
            }

            int iInternetID = GetPIKSID("Email", oTran);

            SqlCommand cmdInternetInsert = _dbConn.CreateCommand();
            cmdInternetInsert.CommandText = SQL_INTERNET_INSERT;
            cmdInternetInsert.Transaction = oTran;
            cmdInternetInsert.Parameters.AddWithValue("InternetID", iInternetID);
            cmdInternetInsert.Parameters.AddWithValue("CompanyID", iCompanyID);
            cmdInternetInsert.Parameters.AddWithValue("Type", "E");
            cmdInternetInsert.Parameters.AddWithValue("Email", szEmail);
            cmdInternetInsert.Parameters.AddWithValue("Description", "E-Mail");
            cmdInternetInsert.Parameters.AddWithValue("PRPublish", "Y");
            cmdInternetInsert.Parameters.AddWithValue("Default", "Y");
            cmdInternetInsert.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
            cmdInternetInsert.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
            cmdInternetInsert.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdInternetInsert.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdInternetInsert.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
            cmdInternetInsert.ExecuteNonQuery();

            EmailInsertedCount++;
        }



        private const string SQL_COMPANYPROFILE_SELECT = "SELECT prcp_CompanyProfileID, prcp_Volume FROM PRCompanyProfile WHERE prcp_CompanyID=@CompanyID";
        private const string SQL_COMPANYPROFILE_UPDATE = "UPDATE PRCompanyProfile SET prcp_Volume=@Volume, prcp_CreatedBy=@UpdatedBy, prcp_CreatedDate=@UpdatedDate, prcp_UpdatedBy=@UpdatedBy, prcp_UpdatedDate=@UpdatedDate, prcp_Timestamp=@UpdatedDate WHERE prcp_CompanyProfileID = @CompanyProfileID";
        private const string SQL_COMPANYPROFILE_INSERT = "INSERT INTO PRCompanyProfile (prcp_CompanyProfileID, prcp_CompanyID, prcp_Volume, prcp_CreatedBy, prcp_CreatedDate, prcp_UpdatedBy, prcp_UpdatedDate, prcp_Timestamp) " +
                                                         "VALUES (@CompanyProfileID, @CompanyID, @Volume, @UpdatedBy, @UpdatedDate, @UpdatedBy, @UpdatedDate, @Timestamp)";

        protected string UpdateProfile(int iCompanyID, string szOKSValue, SqlTransaction oTran)
        {

            if (string.IsNullOrEmpty(szOKSValue))
            {
                return null;
            }

            string szVolume = null;

            switch (szOKSValue.Trim().ToLower()) {
                case "less than 1 mmbf": szVolume = "1"; break;
                case "1 - 10 mmbf":    szVolume = "2"; break;
                case "11 - 25 mmbf":   szVolume = "3"; break;
                case "26 - 50 mmbf":   szVolume = "4"; break;
                case "51 - 100 mmbf":  szVolume = "5"; break;
                case "101 - 200 mmbf": szVolume = "6"; break;
                case "201 - 300 mmbf": szVolume = "7"; break;
                case "301 - 400 mmbf": szVolume = "8"; break;
                case "401 - 500 mmbf": szVolume = "9"; break;
                case "501 - 600 mmbf": szVolume = "10"; break;
                case "601 - 700 mmbf": szVolume = "11"; break;
                case "701 - 800 mmbf": szVolume = "12"; break;
                case "801 - 900 mmbf": szVolume = "13"; break;
                case "901 - 999 mmbf": szVolume = "14"; break;
                case "1 billion bf +": szVolume = "15"; break;
            }

            // First we need to see if we have an existing record.
            SqlCommand cmdProfile = _dbConn.CreateCommand();
            cmdProfile.CommandText = SQL_COMPANYPROFILE_SELECT;
            cmdProfile.Transaction = oTran;
            cmdProfile.Parameters.AddWithValue("CompanyID", iCompanyID);

            bool bUpdate = false;
            int iCompanyProfileID = 0;
            
            using (SqlDataReader reader = cmdProfile.ExecuteReader())
            {
                if (reader.Read())
                {
                    // If we already have a volume value
                    // Then there is nothign to do
                    if (reader[1] != DBNull.Value)
                    {
                        if (reader.GetString(1).ToLower() != szVolume)
                        {
                            VolumeSkippedCount++;
                        }
                        return "OKS Volume value not added to database.";
                    }

                    iCompanyProfileID = reader.GetInt32(0);
                    bUpdate = true;
                }
            }

            if (bUpdate)
            {
                SqlCommand cmdProfileUpdate = _dbConn.CreateCommand();
                cmdProfileUpdate.CommandText = SQL_COMPANYPROFILE_UPDATE;
                cmdProfileUpdate.Transaction = oTran;
                cmdProfileUpdate.Parameters.AddWithValue("CompanyProfileID", iCompanyProfileID);
                cmdProfileUpdate.Parameters.AddWithValue("Volume", szVolume);
                cmdProfileUpdate.Parameters.AddWithValue("CompanyID", iCompanyID);
                cmdProfileUpdate.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
                cmdProfileUpdate.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
                cmdProfileUpdate.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
                cmdProfileUpdate.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
                cmdProfileUpdate.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
                cmdProfileUpdate.ExecuteNonQuery();

                VolumeAddedCount++;
            }
            else
            {

                iCompanyProfileID = GetPIKSID("PRCompanyProfile", oTran);

                SqlCommand cmdProfileInsert = _dbConn.CreateCommand();
                cmdProfileInsert.CommandText = SQL_COMPANYPROFILE_INSERT;
                cmdProfileInsert.Transaction = oTran;
                cmdProfileInsert.Parameters.AddWithValue("CompanyProfileID", iCompanyProfileID);
                cmdProfileInsert.Parameters.AddWithValue("CompanyID", iCompanyID);
                cmdProfileInsert.Parameters.AddWithValue("Volume", szVolume);
                cmdProfileInsert.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
                cmdProfileInsert.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
                cmdProfileInsert.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
                cmdProfileInsert.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
                cmdProfileInsert.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
                cmdProfileInsert.ExecuteNonQuery();

                VolumeAddedCount++;
            }

            return null;
        }

        protected string AddProducts(int iCompanyID, int iPIKSTransactionID, SqlTransaction oTran)
        {
            
            string szOtherProducts = string.Empty;

            bool bFoundProduct = false;
            string szNewProductList = null;
            string szOldProductList = GetValueList("SELECT dbo.ufn_GetProductsProvidedForList(" + iCompanyID + ")", oTran);


            OleDbCommand cmdProducts = driverConnection.CreateCommand();
            cmdProducts.CommandText = "SELECT * FROM [Product Survey Products$] WHERE BBID=" + iCompanyID.ToString();

            using (OleDbDataReader drProducts = cmdProducts.ExecuteReader())
            {
                while (drProducts.Read())
                {
                    bFoundProduct = true;
                    string product = drProducts.GetString(2);
                    if (product.StartsWith("OTHER -"))
                    {
                        if (!string.IsNullOrEmpty(szOtherProducts))
                        {
                            szOtherProducts += Environment.NewLine;
                        }
                        szOtherProducts += product;
                    }
                    else
                    {
                        AddProduct(iCompanyID, product, oTran);
                    }
                }
            }

            if (bFoundProduct)
            {
                szNewProductList = GetValueList("SELECT dbo.ufn_GetProductsProvidedForList(" + iCompanyID + ")", oTran);
                AddTransactionDetail(iPIKSTransactionID, "Product Provided", "prspc_Name", szNewProductList, szOldProductList, oTran);
            }

            return szOtherProducts;
        }


        private const string SQL_PRODUCT_SELECT = "SELECT 'x' FROM PRCompanyProductProvided WHERE prcprpr_CompanyID=@CompanyID AND prcprpr_ProductProvidedID = @ProductID";
        private const string SQL_PRODUCT_INSERT = "INSERT INTO PRCompanyProductProvided (prcprpr_CompanyProductProvidedID, prcprpr_CompanyID, prcprpr_ProductProvidedID, prcprpr_CreatedBy, prcprpr_CreatedDate, prcprpr_UpdatedBy, prcprpr_UpdatedDate, prcprpr_Timestamp) " +
                                                  "VALUES (@CompanyProductProvidedID, @CompanyID, @ProductID, @UpdatedBy, @UpdatedDate, @UpdatedBy, @UpdatedDate, @Timestamp)";
 
        protected void AddProduct(int iCompanyID, string szOKSValue, SqlTransaction oTran)
        {
            if (string.IsNullOrEmpty(szOKSValue))
            {
                return;
            }

            int iProductID = 0;

            switch (szOKSValue.Trim().ToLower())
            {
                case "beams": iProductID = 1; break;
                case "bevel siding": iProductID = 2; break;
                case "boards": iProductID = 3; break;
                case "cabinets": iProductID = 39; break;
                case "ceilings": iProductID = 50; break;
                case "composite products": iProductID = 4; break;
                case "counter tops": iProductID = 40; break;
                case "crates/boxes": iProductID = 41; break;
                case "cut stock": iProductID = 5; break;
                case "decking/deck components": iProductID = 6; break;
                case "dimensional lumber": iProductID = 7; break;
                case "doors/door components": iProductID = 42; break;
                case "edge-glued products": iProductID = 8; break;
                case "engineered wood products": iProductID = 9; break;
                case "fascia": iProductID = 10; break;
                case "fencing": iProductID = 11; break;
                case "fingerjoint material & products": iProductID = 12; break;
                case "flooring": iProductID = 13; break;
                case "furniture/furniture components": iProductID = 43; break;
                case "glulam beams": iProductID = 14; break;
                case "hardware": iProductID = 60; break;
                case "i-joists": iProductID = 15; break;
                case "industrial products": iProductID = 16; break;
                case "laminated veneer lumber (lvl)": iProductID = 17; break;
                case "lath": iProductID = 37; break;
                case "medium density fiberboard (mdf)": iProductID = 18; break;
                case "metric sized lumber": iProductID = 36; break;
                case "millwork": iProductID = 19; break;
                case "moulding & trim": iProductID = 20; break;
                case "osb": iProductID = 21; break;
                case "pallet/skid stock": iProductID = 22; break;
                case "panel products": iProductID = 23; break;
                case "particleboard": iProductID = 24; break;
                case "pattern stock": iProductID = 25; break;
                case "pellets": iProductID = 51; break;
                case "plywood": iProductID = 26; break;
                case "poles/pilings": iProductID = 52; break;
                case "posts": iProductID = 52; break;
                case "prefinished stock": iProductID = 28; break;
                case "pressure treated stock": iProductID = 35; break;
                case "railroad ties/cross ties": iProductID = 53; break;
                case "reclaimed wood": iProductID = 46; break;
                case "rough lumber": iProductID = 54; break;
                case "shingles & shakes": iProductID = 30; break;
                case "shutters": iProductID = 55; break;
                case "siding": iProductID = 31; break;
                case "specialty products": iProductID = 32; break;
                case "stakes": iProductID = 38; break;
                case "stairs/stair components": iProductID = 47; break;
                case "studs": iProductID = 33; break;
                case "timbers": iProductID = 34; break;
                case "treated lumber": iProductID = 35; break;
                case "trusses/truss components": iProductID = 48; break;
                case "walls": iProductID = 56; break;
                case "windows/window components": iProductID = 49; break;
            }

            // First we need to see if we have an existing record.
            SqlCommand cmdSelectProduct = _dbConn.CreateCommand();
            cmdSelectProduct.CommandText = SQL_PRODUCT_SELECT;
            cmdSelectProduct.Transaction = oTran;
            cmdSelectProduct.Parameters.AddWithValue("CompanyID", iCompanyID);
            cmdSelectProduct.Parameters.AddWithValue("ProductID", iProductID);

            // If the company already has this product assign, just
            // skip it.
            object retValue = cmdSelectProduct.ExecuteScalar();
            if (retValue != null)
            {
                return;
            }


            int iCompanyProductProvidedID = GetPIKSID("PRCompanyProductProvided", oTran);

            SqlCommand cmdProfileInsert = _dbConn.CreateCommand();
            cmdProfileInsert.CommandText = SQL_PRODUCT_INSERT;
            cmdProfileInsert.Transaction = oTran;
            cmdProfileInsert.Parameters.AddWithValue("CompanyProductProvidedID", iCompanyProductProvidedID);
            cmdProfileInsert.Parameters.AddWithValue("CompanyID", iCompanyID);
            cmdProfileInsert.Parameters.AddWithValue("ProductID", iProductID);
            cmdProfileInsert.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
            cmdProfileInsert.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
            cmdProfileInsert.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdProfileInsert.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdProfileInsert.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
            cmdProfileInsert.ExecuteNonQuery();

            ProductInsertedCount++;
        }


        protected string AddSpecie(int iCompanyID, int iPIKSTransactionID, SqlTransaction oTran)
        {
            string szOtherSpecie = string.Empty;

            bool bFoundSpecie = false;
            string szNewSpecieList = null;
            string szOldSpecieList = GetValueList("SELECT dbo.ufn_GetSpeciesForList(" + iCompanyID + ")", oTran);


            OleDbCommand cmdSpecies = driverConnection.CreateCommand();
            cmdSpecies.CommandText = "SELECT * FROM [Product Survey Species$] WHERE BBID=" + iCompanyID.ToString();

            using (OleDbDataReader drSpecie = cmdSpecies.ExecuteReader())
            {
                while (drSpecie.Read())
                {
                    bFoundSpecie = true;
                    string specie = null;
                    if (drSpecie[4] != DBNull.Value)
                    {
                        specie = drSpecie.GetString(4);
                    }
                    else if (drSpecie[3] != DBNull.Value)
                    {
                        specie = drSpecie.GetString(3);
                    }
                    else
                    {
                        specie = drSpecie.GetString(2);
                    }

                    string retVal = AddSpecie(iCompanyID, specie, oTran);
                    if (!string.IsNullOrEmpty(retVal))
                    {
                        if (!string.IsNullOrEmpty(szOtherSpecie))
                        {
                            szOtherSpecie += Environment.NewLine;
                        }
                        szOtherSpecie += retVal;
                    }
                }
            }

            if (bFoundSpecie)
            {
                szNewSpecieList = GetValueList("SELECT dbo.ufn_GetSpeciesForList(" + iCompanyID + ")", oTran);
                AddTransactionDetail(iPIKSTransactionID, "Specie", "prspc_Name", szNewSpecieList, szOldSpecieList, oTran);
            }

            return szOtherSpecie;
        }


        private const string SQL_PRCOMPANYSPECIE_SELECT = "SELECT 'x' FROM PRCompanySpecie WHERE prcspc_CompanyID=@CompanyID AND prcspc_SpecieID = @SpecieID";
        private const string SQL_PRCOMPANYSPECIE_INSERT = "INSERT INTO PRCompanySpecie (prcspc_CompanySpecieID, prcspc_CompanyID, prcspc_SpecieID, prcspc_CreatedBy, prcspc_CreatedDate, prcspc_UpdatedBy, prcspc_UpdatedDate, prcspc_Timestamp) " +
            "VALUES (@CompanySpecieID, @CompanyID, @SpecieID, @UpdatedBy, @UpdatedDate, @UpdatedBy, @UpdatedDate, @Timestamp)";
        protected string AddSpecie(int iCompanyID, string szOKSValue, SqlTransaction oTran)
        {

            if (string.IsNullOrEmpty(szOKSValue))
            {
                return null;
            }

            int iSpecieID = 0;
            switch (szOKSValue.Trim().ToLower())
            {
                case "softwood": iSpecieID = 1; break;
                case "agathis/kauri": iSpecieID = 2; break;
                case "cedar": iSpecieID = 3; break;
                case "alaskan yellow cedar": iSpecieID = 4; break;
                case "aromatic cedar": iSpecieID = 5; break;
                case "atlantic white cedar": iSpecieID = 6; break;
                case "chinese cedar": iSpecieID = 7; break;
                case "coastal western red cedar": iSpecieID = 8; break;
                case "eastern white cedar": iSpecieID = 9; break;
                case "incense cedar": iSpecieID = 10; break;
                case "inland red cedar": iSpecieID = 11; break;
                case "port orford cedar": iSpecieID = 12; break;
                case "red cedar": iSpecieID = 13; break;
                case "western red cedar": iSpecieID = 15; break;
                case "white cedar": iSpecieID = 16; break;
                case "yellow cedar": iSpecieID = 17; break;
                case "cypress": iSpecieID = 18; break;
                case "pacific coast cypress": iSpecieID = 19; break;
                case "fir": iSpecieID = 20; break;
                case "alpine fir/subalpine fir": iSpecieID = 195; break;
                case "balsam": iSpecieID = 21; break;
                case "california red fir": iSpecieID = 172; break;
                case "chinese fir": iSpecieID = 22; break;
                case "coast fir": iSpecieID = 23; break;
                case "douglas fir": iSpecieID = 24; break;
                case "grand fir": iSpecieID = 193; break;
                case "noble fir": iSpecieID = 171; break;
                case "pacific silver fir": iSpecieID = 194; break;
                case "white fir": iSpecieID = 26; break;
                case "hemlock": iSpecieID = 27; break;
                case "eastern hemlock": iSpecieID = 28; break;
                case "mountain hemlock": iSpecieID = 196; break;
                case "pacific hemlock": iSpecieID = 29; break;
                case "western hemlock": iSpecieID = 30; break;
                case "juniper": iSpecieID = 31; break;
                case "larch/tamarack": iSpecieID = 32; break;
                case "western larch": iSpecieID = 190; break;
                case "european larch": iSpecieID = 33; break;
                case "mixed species": iSpecieID = 170; break;
                case "alpine fir hem-fir (a-f hem fir)": iSpecieID = 183; break;
                case "douglas fir-larch (doug fir-l)": iSpecieID = 176; break;
                case "douglas fir-north (d fir(n))": iSpecieID = 178; break;
                case "douglas fir-south (dfs)": iSpecieID = 177; break;
                case "eastern spruce-pine-fir (e-spf)": iSpecieID = 174; break;
                case "engelmann spruce-alpine fir (es-af)": iSpecieID = 185; break;
                case "engelmann spruce-lodgepole pine (es-lp)": iSpecieID = 182; break;
                case "engelmann spruce-lodgepole pine-alpine f": iSpecieID = 186; break;
                case "hem-fir (h-f)": iSpecieID = 25; break;
                case "hem-fir north (hem-fir (n))": iSpecieID = 179; break;
                case "hemlock-tamarack (hem-tam)": iSpecieID = 189; break;
                case "mountain hemlock hem-fir (m-h hem fir)": iSpecieID = 188; break;
                case "ponderosa pine-lodgepole pine (pp-lp)": iSpecieID = 187; break;
                case "ponderosa pine-sugar pine (pp-sp)": iSpecieID = 184; break;
                case "spruce pine fir-south (spfs)": iSpecieID = 181; break;
                case "spruce-pine-fir (spf)": iSpecieID = 180; break;
                case "western spruce-pine-fir (w-spf)": iSpecieID = 175; break;
                case "pine": iSpecieID = 34; break;
                case "arkansas pine": iSpecieID = 35; break;
                case "brazilian pine": iSpecieID = 36; break;
                case "eastern red pine": iSpecieID = 37; break;
                case "eastern white pine": iSpecieID = 38; break;
                case "elliotis pine": iSpecieID = 39; break;
                case "european pine": iSpecieID = 40; break;
                case "heart pine": iSpecieID = 41; break;
                case "idaho white pine": iSpecieID = 42; break;
                case "jack pine": iSpecieID = 197; break;
                case "loblolly pine": iSpecieID = 43; break;
                case "lodgepole pine": iSpecieID = 44; break;
                case "longleaf pine": iSpecieID = 45; break;
                case "parana pine": iSpecieID = 46; break;
                case "patula pine": iSpecieID = 47; break;
                case "ponderosa pine": iSpecieID = 48; break;
                case "radiata pine": iSpecieID = 49; break;
                case "red pine": iSpecieID = 50; break;
                case "russian pine": iSpecieID = 51; break;
                case "scots pine": iSpecieID = 52; break;
                case "shortleaf pine": iSpecieID = 53; break;
                case "slash pine": iSpecieID = 54; break;
                case "southern pine": iSpecieID = 55; break;
                case "southern yellow pine": iSpecieID = 56; break;
                case "sugar pine": iSpecieID = 57; break;
                case "sylvestris pine": iSpecieID = 58; break;
                case "western pine": iSpecieID = 59; break;
                case "white pine": iSpecieID = 60; break;
                case "redwood": iSpecieID = 61; break;
                case "spanish cedar": iSpecieID = 14; break;
                case "spruce": iSpecieID = 62; break;
                case "black spruce": iSpecieID = 63; break;
                case "coastal sitka spruce": iSpecieID = 64; break;
                case "eastern spruce": iSpecieID = 65; break;
                case "engelmann spruce": iSpecieID = 66; break;
                case "euro spruce": iSpecieID = 67; break;
                case "european spruce": iSpecieID = 68; break;
                case "european white spruce": iSpecieID = 69; break;
                case "norway spruce": iSpecieID = 70; break;
                case "sitka spruce": iSpecieID = 71; break;
                case "white spruce": iSpecieID = 72; break;
                case "teak": iSpecieID = 73; break;
                case "plantation teak": iSpecieID = 224; break;
                case "burma teak": iSpecieID = 74; break;
                case "hardwood": iSpecieID = 75; break;
                case "afrormosia": iSpecieID = 203; break;
                case "alder": iSpecieID = 76; break;
                case "red alder": iSpecieID = 198; break;
                case "alowood": iSpecieID = 77; break;
                case "amapa": iSpecieID = 229; break;
                case "amendoim/ybyraro": iSpecieID = 225; break;
                case "andiroba": iSpecieID = 78; break;
                case "angelim pedra": iSpecieID = 79; break;
                case "angico": iSpecieID = 204; break;
                case "aniegre": iSpecieID = 205; break;
                case "appalachian hardwood": iSpecieID = 80; break;
                case "ash": iSpecieID = 81; break;
                case "brown ash": iSpecieID = 82; break;
                case "aspen": iSpecieID = 83; break;
                case "avodire": iSpecieID = 206; break;
                case "balau": iSpecieID = 84; break;
                case "red balau": iSpecieID = 85; break;
                case "bankarai": iSpecieID = 87; break;
                case "baromalli": iSpecieID = 88; break;
                case "basswood": iSpecieID = 89; break;
                case "beech": iSpecieID = 90; break;
                case "euro beech (steamed)": iSpecieID = 91; break;
                case "euro beech (white)": iSpecieID = 92; break;
                case "birch": iSpecieID = 93; break;
                case "baltic birch/russian birch": iSpecieID = 94; break;
                case "white birch": iSpecieID = 95; break;
                case "yellow birch": iSpecieID = 96; break;
                case "bloodwood": iSpecieID = 97; break;
                case "bocote": iSpecieID = 207; break;
                case "bubinga": iSpecieID = 208; break;
                case "butternut": iSpecieID = 99; break;
                case "cambara": iSpecieID = 100; break;
                case "canary wood": iSpecieID = 226; break;
                case "cherry": iSpecieID = 101; break;
                case "chestnut": iSpecieID = 230; break;
                case "cocobolo": iSpecieID = 209; break;
                case "cottonwood": iSpecieID = 102; break;
                case "cumaru": iSpecieID = 103; break;
                case "ebony": iSpecieID = 104; break;
                case "elm": iSpecieID = 105; break;
                case "red elm": iSpecieID = 106; break;
                case "eucalyptus": iSpecieID = 107; break;
                case "lyptus": iSpecieID = 108; break;
                case "garapa": iSpecieID = 109; break;
                case "greenheart": iSpecieID = 110; break;
                case "guajara/moabi": iSpecieID = 111; break;
                case "gum": iSpecieID = 112; break;
                case "sap gum": iSpecieID = 113; break;
                case "hackberry": iSpecieID = 114; break;
                case "hickory": iSpecieID = 115; break;
                case "holly": iSpecieID = 202; break;
                case "idigobo/emeri": iSpecieID = 210; break;
                case "ipe": iSpecieID = 116; break;
                case "iroko": iSpecieID = 228; break;
                case "jarrah": iSpecieID = 117; break;
                case "jatoba/brazilian cherry": iSpecieID = 98; break;
                case "kapur": iSpecieID = 118; break;
                case "keruing/apitong": iSpecieID = 119; break;
                case "kingwood": iSpecieID = 211; break;
                case "koa": iSpecieID = 212; break;
                case "kurupayra": iSpecieID = 120; break;
                case "lacewood": iSpecieID = 213; break;
                case "magnolia": iSpecieID = 199; break;
                case "makore": iSpecieID = 214; break;
                case "maple": iSpecieID = 126; break;
                case "hard maple": iSpecieID = 127; break;
                case "pacific coast maple": iSpecieID = 128; break;
                case "soft maple": iSpecieID = 129; break;
                case "marupa": iSpecieID = 130; break;
                case "massaranduba/brazilian redwood": iSpecieID = 131; break;
                case "meranti": iSpecieID = 132; break;
                case "merbau": iSpecieID = 133; break;
                case "morado": iSpecieID = 134; break;
                case "nogal/peruvian walnut": iSpecieID = 173; break;
                case "oak": iSpecieID = 135; break;
                case "red oak": iSpecieID = 136; break;
                case "white oak": iSpecieID = 137; break;
                case "obeche": iSpecieID = 138; break;
                case "okoume": iSpecieID = 139; break;
                case "osage orange": iSpecieID = 200; break;
                case "pau amarello/yellowheart": iSpecieID = 140; break;
                case "padauk": iSpecieID = 215; break;
                case "paulownia": iSpecieID = 141; break;
                case "pecan": iSpecieID = 142; break;
                case "persimmon": iSpecieID = 201; break;
                case "poplar": iSpecieID = 143; break;
                case "chinese poplar": iSpecieID = 144; break;
                case "western poplar": iSpecieID = 145; break;
                case "yellow poplar": iSpecieID = 146; break;
                case "purpleheart": iSpecieID = 147; break;
                case "ramin": iSpecieID = 148; break;
                case "redheart": iSpecieID = 216; break;
                case "rosewood": iSpecieID = 149; break;
                case "curupau/patagonian rosewood": iSpecieID = 150; break;
                case "para rosewood": iSpecieID = 151; break;
                case "sapele": iSpecieID = 152; break;
                case "sassafras": iSpecieID = 217; break;
                case "shedua": iSpecieID = 218; break;
                case "sucupira": iSpecieID = 153; break;
                case "sycamore": iSpecieID = 154; break;
                case "tanimbuca": iSpecieID = 155; break;
                case "tarara": iSpecieID = 156; break;
                case "tatajuba": iSpecieID = 157; break;
                case "tauari": iSpecieID = 158; break;
                case "taxi/brazilian olive": iSpecieID = 159; break;
                case "tiete rosewood/sirari": iSpecieID = 160; break;
                case "tigerwood": iSpecieID = 161; break;
                case "tornillo": iSpecieID = 162; break;
                case "true/american mahogany": iSpecieID = 121; break;
                case "african mahogany": iSpecieID = 122; break;
                case "philippine mahogany/lauan": iSpecieID = 124; break;
                case "santos mahogany": iSpecieID = 125; break;
                case "tulipwood": iSpecieID = 219; break;
                case "utile/sipo": iSpecieID = 163; break;
                case "virola": iSpecieID = 164; break;
                case "wallaba": iSpecieID = 227; break;
                case "walnut": iSpecieID = 165; break;
                case "wenge": iSpecieID = 220; break;
                case "willow": iSpecieID = 166; break;
                case "zebrawood": iSpecieID = 222; break;
                case "ziricote": iSpecieID = 223; break;
            }

            if (iSpecieID == 0)
            {
                return "Unknown specie specified: " + szOKSValue;
            }

            // First we need to see if we have an existing record.
            SqlCommand cmdSelectSpecie = _dbConn.CreateCommand();
            cmdSelectSpecie.CommandText = SQL_PRCOMPANYSPECIE_SELECT;
            cmdSelectSpecie.Transaction = oTran;
            cmdSelectSpecie.Parameters.AddWithValue("CompanyID", iCompanyID);
            cmdSelectSpecie.Parameters.AddWithValue("SpecieID", iSpecieID);

            // If the company already has this product assign, just
            // skip it.
            object retValue = cmdSelectSpecie.ExecuteScalar();
            if (retValue != null)
            {
                return null;
            }



            int iCompanySpecieID = GetPIKSID("PRCompanySpecie", oTran);

            SqlCommand cmdCompanySpecieInsert = _dbConn.CreateCommand();
            cmdCompanySpecieInsert.CommandText = SQL_PRCOMPANYSPECIE_INSERT;
            cmdCompanySpecieInsert.Transaction = oTran;
            cmdCompanySpecieInsert.Parameters.AddWithValue("CompanySpecieID", iCompanySpecieID);
            cmdCompanySpecieInsert.Parameters.AddWithValue("CompanyID", iCompanyID);
            cmdCompanySpecieInsert.Parameters.AddWithValue("SpecieID", iSpecieID);
            cmdCompanySpecieInsert.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
            cmdCompanySpecieInsert.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
            cmdCompanySpecieInsert.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdCompanySpecieInsert.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdCompanySpecieInsert.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
            cmdCompanySpecieInsert.ExecuteNonQuery();

            SpecieInsertedCount++;

            return null;
        }

        protected string GetValueList(string szSQL, SqlTransaction oTran)
        {
            SqlCommand cmdSelectList = _dbConn.CreateCommand();
            cmdSelectList.CommandText = szSQL;
            cmdSelectList.Transaction = oTran;

            object retVal = cmdSelectList.ExecuteScalar(); 
            if (retVal == DBNull.Value) {
                return string.Empty;
            }

            return (string)retVal;
        }

        protected void AddTransactionDetail(int iTransactionDetail, string szEntity, string szField, string szNewValue, string szOldValue, SqlTransaction oTran)
        {
            SqlCommand cmdInsertDetail = _dbConn.CreateCommand();
            cmdInsertDetail.CommandText = "usp_CreateTransactionDetail";
            cmdInsertDetail.CommandType = CommandType.StoredProcedure;
            cmdInsertDetail.Transaction = oTran;
            cmdInsertDetail.Parameters.AddWithValue("prtx_TransactionId", iTransactionDetail);
            cmdInsertDetail.Parameters.AddWithValue("Entity", szEntity);
            cmdInsertDetail.Parameters.AddWithValue("Field", szField);
            cmdInsertDetail.Parameters.AddWithValue("OldValue", szOldValue);
            cmdInsertDetail.Parameters.AddWithValue("NewValue", szNewValue);
            cmdInsertDetail.ExecuteNonQuery();
        }
    }
}
