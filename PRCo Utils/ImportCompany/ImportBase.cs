using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;
using LumenWorks.Framework.IO.Csv;


namespace BBSI.CompanyImport
{
    public class ImportBase
    {

        private TextInfo textInfo = new CultureInfo("en-US", false).TextInfo;
        protected string prepareString(string value)
        {
            if (string.IsNullOrEmpty(value))
            {
                return value;
            }

            if ((value.StartsWith("PO BOX ")) ||
                (value.StartsWith("RR ")))
            {
                return value;
            }

            value = value.Replace("&AMP;AMP;", "&");
            value = value.Replace("&AMP;", "&");
            value = value.Replace("&APOS;", "'");

            return textInfo.ToTitleCase(value.ToLower());
        }

        protected void AddParameter(SqlCommand sqlCommand, string szParmName, string szParmValue)
        {
            if (string.IsNullOrEmpty(szParmValue))
            {
                // Due to the reports and the multi-value paramters, we don't ever 
                // want this to be NULL
                if (szParmName == "Rating")
                {
                    sqlCommand.Parameters.AddWithValue(szParmName, string.Empty);
                }
                else
                {
                    sqlCommand.Parameters.AddWithValue(szParmName, DBNull.Value);
                }

            }
            else
            {
                sqlCommand.Parameters.AddWithValue(szParmName, szParmValue);
            }
        }

        protected void AddParameter(SqlCommand sqlCommand, string szParmName, int iParmValue)
        {
            if (iParmValue == 0)
            {
                sqlCommand.Parameters.AddWithValue(szParmName, DBNull.Value);
            }
            else
            {
                sqlCommand.Parameters.AddWithValue(szParmName, iParmValue);
            }
        }

        protected int GetPIKSID(string szTableName, SqlTransaction oTran)
        {
            SqlCommand sqlGetID = oTran.Connection.CreateCommand();
            sqlGetID.Transaction = oTran;
            sqlGetID.CommandText = "usp_getNextId";
            sqlGetID.CommandType = CommandType.StoredProcedure;
            sqlGetID.CommandTimeout = 300;
            sqlGetID.Parameters.Add(new SqlParameter("TableName", szTableName));

            SqlParameter oReturnParm = new SqlParameter();
            oReturnParm.ParameterName = "Return";
            oReturnParm.Value = 0;
            oReturnParm.Direction = ParameterDirection.Output;
            sqlGetID.Parameters.Add(oReturnParm);

            sqlGetID.ExecuteNonQuery();

            return Convert.ToInt32(oReturnParm.Value);
        }

        protected int OpenPIKSTransaction(SqlTransaction oTran, int companyID, int personID, string explanation)
        {
            SqlCommand sqlOpenPIKSTransaction = oTran.Connection.CreateCommand();
            sqlOpenPIKSTransaction.Transaction = oTran;
            sqlOpenPIKSTransaction.CommandText = "usp_CreateTransaction";
            sqlOpenPIKSTransaction.CommandType = CommandType.StoredProcedure;
            sqlOpenPIKSTransaction.CommandTimeout = 300;
            sqlOpenPIKSTransaction.Parameters.AddWithValue("UserId", UPDATED_BY);

            if (companyID > 0)
            {
                sqlOpenPIKSTransaction.Parameters.AddWithValue("prtx_CompanyId", companyID);
            }

            if (personID > 0)
            {
                sqlOpenPIKSTransaction.Parameters.AddWithValue("prtx_PersonId", personID);
            }

            sqlOpenPIKSTransaction.Parameters.AddWithValue("prtx_Explanation", explanation);
            sqlOpenPIKSTransaction.Parameters.AddWithValue("prtx_AuthorizedInfo ", "System");
            sqlOpenPIKSTransaction.Parameters.AddWithValue("prtx_EffectiveDate", DateTime.Now);

            SqlParameter oReturnParm = new SqlParameter();
            oReturnParm.ParameterName = "NextId";
            oReturnParm.Value = 0;
            oReturnParm.Direction = ParameterDirection.ReturnValue;
            sqlOpenPIKSTransaction.Parameters.Add(oReturnParm);

            sqlOpenPIKSTransaction.ExecuteNonQuery();
            return Convert.ToInt32(oReturnParm.Value);
        }

        protected const string SQL_PRTRANSACTION_CLOSE = "UPDATE PRTransaction SET prtx_Status='C', prtx_CloseDate=GETDATE(), prtx_UpdatedBy=1, prtx_UpdatedDate=GETDATE(), prtx_Timestamp=GETDATE() WHERE prtx_TransactionId=@TransactionID";

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

            SqlCommand sqlCloseTransaction = oTran.Connection.CreateCommand();
            sqlCloseTransaction.Transaction = oTran;
            sqlCloseTransaction.Parameters.Add(new SqlParameter("TransactionID", iTransactionID));
            sqlCloseTransaction.CommandText = SQL_PRTRANSACTION_CLOSE;
            sqlCloseTransaction.CommandTimeout = 300;

            if (sqlCloseTransaction.ExecuteNonQuery() == 0)
            {
                throw new ApplicationException("Unable to close transaction: " + iTransactionID.ToString());
            }
        }

        public void DeletePIKSTransaction(int iTransactionID, SqlTransaction oTran)
        {
            if (iTransactionID <= 0)
            {
                return;
            }

            SqlCommand sqlDelete = oTran.Connection.CreateCommand();
            sqlDelete.Transaction = oTran;
            sqlDelete.Parameters.Add(new SqlParameter("TransactionID", iTransactionID));
            sqlDelete.CommandText = "DELETE FROM PRTransactionDetail WHERE prtd_TransactionID = @TransactionID";
            sqlDelete.CommandTimeout = 300;

            sqlDelete.ExecuteNonQuery();


            sqlDelete.CommandText = "DELETE FROM PRTransaction WHERE prtx_TransactionID = @TransactionID";
            sqlDelete.ExecuteNonQuery();
        }

        protected const int UPDATED_BY = 1;
        protected DateTime UPDATED_DATE = DateTime.Now;





        protected static HashSet<string> _EmailSuppression = null;
        public static void LoadEmailSuppressionFile(string filename)
        {
            if (_EmailSuppression != null)
            {
                return;
            }

            _EmailSuppression = new HashSet<string>();

            if (string.IsNullOrEmpty(filename))
            {
                return;
            }

            using (CsvReader csv = new CsvReader(new StreamReader(filename), true))
            {
                csv.MissingFieldAction = MissingFieldAction.ReplaceByNull;

                while (csv.ReadNextRecord())
                {
                    _EmailSuppression.Add(csv["Email"].ToLower());
                }
            }
        }

        protected string GetEligibleEmail(string email)
        {
            if (string.IsNullOrEmpty(email))
            {
                return null;
            }

            if (_EmailSuppression.Contains(email.ToLower())) {
                return null;
            }

            return email;
        }


        protected static HashSet<string> _InternetDomain = null;
        public static void LoadInternetDomainFile(string filename)
        {

            if (_InternetDomain != null)
            {
                return;
            }

            _InternetDomain = new HashSet<string>();

            //string fileName = Path.Combine(_szPath, "InternetDomain.txt");
            using (CsvReader csv = new CsvReader(new StreamReader(filename), true))
            {
                csv.MissingFieldAction = MissingFieldAction.ReplaceByNull;

                while (csv.ReadNextRecord())
                {
                    _InternetDomain.Add(csv["Domain"].ToLower());
                }
            }
        }

        public bool IsDebug
        {
            get
            {
                if (!string.IsNullOrEmpty(ConfigurationManager.AppSettings["DebugMode"]))
                {
                   return Convert.ToBoolean(ConfigurationManager.AppSettings["DebugMode"]);
                }

                return false;
            }
        }

        public void WriteDebugMessage(string msg)
        {
            if (IsDebug)
            {
                Console.WriteLine(" - " + msg);
            }
        }

    }
}
