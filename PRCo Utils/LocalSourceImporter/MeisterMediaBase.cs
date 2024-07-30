using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;
using System.Text;
using LumenWorks.Framework.IO.Csv;


namespace LocalSourceImporter
{
    public class MeisterMediaBase
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


        private const string SQL_EMAIL_INSERT = "INSERT INTO Email (Emai_EmailId, Emai_EmailAddress, emai_PRDescription, emai_PRPublish, emai_PRPreferredPublished, emai_PRPreferredInternal, emai_CompanyID, emai_CreatedBy, emai_CreatedDate, emai_UpdatedBy, emai_UpdatedDate, emai_Timestamp) " +
                                                            "VALUES (@EmailId, @EmailAddress, @Description, @PRPublish, @PRPublish, @Default, @CompanyID, @UpdatedBy, @UpdatedDate, @UpdatedBy, @UpdatedDate, @Timestamp)";


        private const string SQL_EMAILLINK_INSERT = "INSERT INTO EmailLink (elink_LinkID, elink_EntityID, elink_RecordID, elink_Type, ELink_EmailId, elink_CreatedBy, elink_CreatedDate, elink_UpdatedBy, elink_UpdatedDate, elink_Timestamp) " +
                                                           "VALUES (@EmailLinkID, @EntityID, @RecordID, @Type, @EmailId, @UpdatedBy, @UpdatedDate, @UpdatedBy, @UpdatedDate, @Timestamp)";

        protected int SaveEmail(SqlTransaction oTran, int companyID, int personID, string email)
        {

            if (string.IsNullOrEmpty(email))
            {
                return 0;
            }

            // First we need to see if we have an existing record.
            int emailID = GetPIKSID("Email", oTran);

            SqlCommand cmdSave = oTran.Connection.CreateCommand();
            cmdSave.CommandText = SQL_EMAIL_INSERT;
            cmdSave.Transaction = oTran;
            cmdSave.CommandTimeout = 300;

            cmdSave.Parameters.AddWithValue("EmailID", emailID);
            cmdSave.Parameters.AddWithValue("Description", "E-Mail");

            cmdSave.Parameters.AddWithValue("EmailAddress", email);
            cmdSave.Parameters.AddWithValue("PRPublish", "Y");
            cmdSave.Parameters.AddWithValue("Default", "Y");
            AddParameter(cmdSave, "CompanyID", companyID);
            cmdSave.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
            cmdSave.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
            cmdSave.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdSave.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdSave.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
            cmdSave.ExecuteNonQuery();


            // First we need to see if we have an existing record.
            int emailLinkID = GetPIKSID("EmailLink", oTran);

            SqlCommand cmdSaveLink = oTran.Connection.CreateCommand();
            cmdSaveLink.CommandText = SQL_EMAILLINK_INSERT;
            cmdSaveLink.Transaction = oTran;
            cmdSaveLink.CommandTimeout = 300;
            cmdSaveLink.Parameters.AddWithValue("EmailLinkID", emailLinkID);

            if (personID > 0)
            {
                cmdSaveLink.Parameters.AddWithValue("EntityID", 13);
                cmdSaveLink.Parameters.AddWithValue("RecordID", personID);
            }
            else
            {
                cmdSaveLink.Parameters.AddWithValue("EntityID", 5);
                cmdSaveLink.Parameters.AddWithValue("RecordID", companyID);

            }

            cmdSaveLink.Parameters.AddWithValue("Type", "E");
            cmdSaveLink.Parameters.AddWithValue("EmailId", emailID);
            cmdSaveLink.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
            cmdSaveLink.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
            cmdSaveLink.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdSaveLink.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdSaveLink.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
            cmdSaveLink.ExecuteNonQuery();

            return emailID;
        }

        private const string SQL_UNPUBLISH_EMAIL =
            @"UPDATE Email
                 SET emai_PRPublish=NULL, emai_PRPreferredPublished=NULL, Emai_UpdatedBy=@UpdatedBy, Emai_UpdatedDate=@UpdatedDate
                FROM EmailLink
               WHERE Emai_EmailId = ELink_EmailId AND ELink_RecordID=@RecordID AND elink_EntityID=@EntityID AND ELink_Type=@Type AND emai_PRPublish='Y'";

        protected void UnpublishEmail(SqlTransaction oTran, int companyID, int personID)
        {
            SqlCommand cmdUpdate = oTran.Connection.CreateCommand();
            cmdUpdate.CommandText = SQL_UNPUBLISH_EMAIL;
            cmdUpdate.Transaction = oTran;
            cmdUpdate.CommandTimeout = 300;
            cmdUpdate.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdUpdate.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdUpdate.Parameters.AddWithValue("Type", "E");

            if (personID > 0) {
                cmdUpdate.Parameters.AddWithValue("EntityID", 13);
                cmdUpdate.Parameters.AddWithValue("RecordID", personID);
            }
            else {
                cmdUpdate.Parameters.AddWithValue("EntityID", 5);
                cmdUpdate.Parameters.AddWithValue("RecordID", companyID);
            }

            cmdUpdate.ExecuteNonQuery();
        }

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

        private Dictionary<char, char> spanishCharTranslation = null;

        protected string TranslateSpanishCharacters(string name)
        {
            if (spanishCharTranslation == null)
            {
                spanishCharTranslation = new Dictionary<char, char>();
                spanishCharTranslation.Add('Á', 'A');
                spanishCharTranslation.Add('á', 'a');
                spanishCharTranslation.Add('à', 'a');
                spanishCharTranslation.Add('â', 'a');
                spanishCharTranslation.Add('ã', 'a');
                spanishCharTranslation.Add('ä', 'a');
                spanishCharTranslation.Add('å', 'a');
                spanishCharTranslation.Add('è', 'e');
                spanishCharTranslation.Add('é', 'e');
                spanishCharTranslation.Add('ê', 'e');
                spanishCharTranslation.Add('ë', 'e');
                spanishCharTranslation.Add('ì', 'i');
                spanishCharTranslation.Add('í', 'i');
                spanishCharTranslation.Add('ï', 'i');
                spanishCharTranslation.Add('ó', 'o');
                spanishCharTranslation.Add('ô', 'o');
                spanishCharTranslation.Add('õ', 'o');
                spanishCharTranslation.Add('ö', 'o');
                spanishCharTranslation.Add('ú', 'u');
                spanishCharTranslation.Add('ù', 'u');
                spanishCharTranslation.Add('û', 'u');
                spanishCharTranslation.Add('ü', 'u');
                spanishCharTranslation.Add('ý', 'y');
                spanishCharTranslation.Add('ÿ', 'y');
                spanishCharTranslation.Add('ñ', 'n');
                spanishCharTranslation.Add('ç', 'c');
            }

            StringBuilder newName = new StringBuilder();
            foreach (char c in name.ToCharArray())
            {
                if (spanishCharTranslation.ContainsKey(c))
                {
                    newName.Append(spanishCharTranslation[c]);
                }
                else
                {
                    if ((c != '¡') && (c != '¿'))
                    {
                        newName.Append(c);
                    }
                }
            }

            return newName.ToString();
        }
    }
}
