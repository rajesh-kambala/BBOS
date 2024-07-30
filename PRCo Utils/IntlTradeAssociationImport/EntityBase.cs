using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.IO;
using LumenWorks.Framework.IO.Csv;


namespace IntlTradeAssociationImport
{
    public class EntityBase
    {
        public Importer ParentImporter;
        public Company ParentCompany;

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

        protected void AddParameter(SqlCommand sqlCommand, string szParmName, string szParmValue, int maxLength)
        {

            if ((!string.IsNullOrEmpty(szParmValue)) &&
                (szParmValue.Length > maxLength))
                szParmValue = szParmValue.Substring(0, maxLength);

            AddParameter(sqlCommand, szParmName, szParmValue);
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

        protected void AddParameter(SqlCommand sqlCommand, string szParmName, bool bParmValue)
        {
            if (bParmValue)
            {
                sqlCommand.Parameters.AddWithValue(szParmName, "Y");
            }
            else
            {
                sqlCommand.Parameters.AddWithValue(szParmName, DBNull.Value);
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





        private const string SQL_EMAIL_DELETE =
            @"DECLARE @Tmp table (ID int);
              INSERT INTO @Tmp SELECT elink_EmailID FROM EmailLink WHERE elink_RecordID = @RecordID AND eLink_EntityId = @EntityID;
              DELETE FROM EmailLink WHERE elink_RecordID = @RecordID AND eLink_EntityId = @EntityID;
              DELETE FROM Email WHERE emai_EmailID IN (SELECT ID FROM @Tmp);";


        protected void DeleteEmail(SqlTransaction oTran, int companyID, int personID)
        {
            SqlCommand cmdDelete = oTran.Connection.CreateCommand();
            cmdDelete.Transaction = oTran;
            cmdDelete.CommandText = SQL_EMAIL_DELETE;
            cmdDelete.CommandTimeout = 300;

            if (personID > 0)
            {
                AddParameter(cmdDelete, "RecordID", personID);
                AddParameter(cmdDelete, "EntityID", 13);
            }
            else
            {
                AddParameter(cmdDelete, "RecordID", companyID);
                AddParameter(cmdDelete, "EntityID", 5);

            }
            cmdDelete.ExecuteNonQuery();
        }

        protected int SaveEmail(SqlTransaction oTran, int companyID, int personID, string email)
        {
            return SaveInternetAddress(oTran, companyID, personID, "E", email);
        }

        protected int SaveWebsite(SqlTransaction oTran, int companyID, int personID, string url)
        {
            return SaveInternetAddress(oTran, companyID, personID, "W", url);
        }


        protected int SaveInternetAddress(SqlTransaction oTran, int companyID, int personID, string type, string address)
        {

            if (string.IsNullOrEmpty(address))
            {
                return 0; 
            }

            //int emailID = GetEmailID(oTran, companyID, personID, address, type);
            //if (emailID > 0)
            //{
            //    return emailID;
            //}

            DeleteEmail(oTran, companyID, personID);


            // First we need to see if we have an existing record.
            //int emailID = GetPIKSID("Email", oTran);

            SqlCommand cmdSave = oTran.Connection.CreateCommand();
            cmdSave.Transaction = oTran;
            cmdSave.CommandText = "usp_InsertEmail";
            cmdSave.CommandType = CommandType.StoredProcedure;
            cmdSave.CommandTimeout = 300;

            if (personID > 0)
            {
                cmdSave.Parameters.AddWithValue("EntityID", 13);
                cmdSave.Parameters.AddWithValue("RecordID", personID);
                cmdSave.Parameters.AddWithValue("CompanyID", companyID);
            }
            else
            {
                cmdSave.Parameters.AddWithValue("EntityID", 5);
                cmdSave.Parameters.AddWithValue("RecordID", companyID);
            }

            cmdSave.Parameters.AddWithValue("Type", type);

            if (type == "E")
            {
                cmdSave.Parameters.AddWithValue("Description", "E-Mail");
                cmdSave.Parameters.AddWithValue("EmailAddress", address);
                cmdSave.Parameters.AddWithValue("WebAddress", DBNull.Value);
            } else
            {
                cmdSave.Parameters.AddWithValue("Description", "Web Site");
                cmdSave.Parameters.AddWithValue("EmailAddress", DBNull.Value);
                cmdSave.Parameters.AddWithValue("WebAddress", address);
            }

            cmdSave.Parameters.AddWithValue("Publish", "Y");
            cmdSave.Parameters.AddWithValue("PreferredPublish", "Y");
            cmdSave.Parameters.AddWithValue("PreferredInternal", "Y");
            cmdSave.Parameters.AddWithValue("UserID", UPDATED_BY);
            cmdSave.ExecuteNonQuery();

            int emailID = GetEmailID(oTran, companyID, personID, address, type);
            return emailID;
        }


        private const string SQL_SELECT_EMAIL =
                   "SELECT emai_EmailID FROM vPREmail WITH (NOLOCK) WHERE elink_RecordID=@RecordID AND elink_EntityID=@EntityID AND elink_Type='E' AND emai_EmailAddress=@Value";
        private const string SQL_SELECT_WEBSITE =
                   "SELECT emai_EmailID FROM vPREmail WITH (NOLOCK) WHERE elink_RecordID=@RecordID AND elink_EntityID=@EntityID AND elink_Type='W' AND emai_PRWebAddress=@Value";


        protected int GetEmailID(SqlTransaction sqlTrans, int companyID, int personID, string value, string type)
        {
            SqlCommand cmdEmail = new SqlCommand();
            cmdEmail.Connection = sqlTrans.Connection;
            cmdEmail.Transaction = sqlTrans;

            if (type == "E")
            {
                cmdEmail.CommandText = SQL_SELECT_EMAIL;
            } else
            {
                cmdEmail.CommandText = SQL_SELECT_WEBSITE;
            }

            if (personID > 0)
            {
                cmdEmail.Parameters.AddWithValue("EntityID", 13);
                cmdEmail.Parameters.AddWithValue("RecordID", personID);
            }
            else
            {
                cmdEmail.Parameters.AddWithValue("EntityID", 5);
                cmdEmail.Parameters.AddWithValue("RecordID", companyID);
            }

            cmdEmail.Parameters.AddWithValue("Value", value);

            object result = cmdEmail.ExecuteScalar();
            if ((result == null) ||
                (result == DBNull.Value))
            {
                return 0;
            }

            return Convert.ToInt32(result);
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

        protected bool GetBoolValue(IDataReader reader, int index)
        {
            if (reader[index] != DBNull.Value)
            {
                return true;
            }

            return false;
        }

        protected int GetIntValue(IDataReader reader, int index)
        {
            if (reader[index] != DBNull.Value)
            {
                return Convert.ToInt32(reader[index]);
            }

            return 0;
        }

        protected string GetStringValue(IDataReader reader, int index)
        {
            if (reader[index] != DBNull.Value)
            {
                return Convert.ToString(reader[index]);
            }

            return null;
        }
    }
}
