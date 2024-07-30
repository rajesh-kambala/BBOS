using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlClient;

namespace BBSI.CompanyImport
{
    public class Email: ImportBase
    {
        public string EmailAddress;
        public string WebSite;
        public int CompanyID;
        public int PersonID;
        public string TypeCode;

        public Email(string emailAddress, string website)
        {
            if (!string.IsNullOrEmpty(emailAddress))
            {
                EmailAddress = emailAddress;
                TypeCode = "E";
            } else
            {
                WebSite = website;
                TypeCode = "W";
            }
        }

        private const string SQL_EMAIL_DELETE =
            @"DECLARE @Tmp table (ID int);
              INSERT INTO @Tmp SELECT elink_EmailID FROM EmailLink WHERE elink_RecordID = @RecordID AND eLink_EntityId = @EntityID;
              DELETE FROM EmailLink WHERE elink_RecordID = @RecordID AND eLink_EntityId = @EntityID;
              DELETE FROM Email WHERE emai_EmailID IN (SELECT ID FROM @Tmp);";


        public static void DeleteAll(SqlTransaction oTran, int companyID, int personID)
        {
            SqlCommand cmdDelete = oTran.Connection.CreateCommand();
            cmdDelete.Transaction = oTran;
            cmdDelete.CommandText = SQL_EMAIL_DELETE;
            cmdDelete.CommandTimeout = 300;

            if (personID > 0)
            {
                cmdDelete.Parameters.AddWithValue("RecordID", personID);
                cmdDelete.Parameters.AddWithValue("EntityID", 13);
            }
            else
            {
                cmdDelete.Parameters.AddWithValue("RecordID", companyID);
                cmdDelete.Parameters.AddWithValue("EntityID", 5);
            }
            cmdDelete.ExecuteNonQuery();
        }


        private const string SQL_EMAIL_INSERT = "INSERT INTO Email (Emai_EmailId, Emai_EmailAddress, emai_PRWebAddress, emai_PRDescription, emai_PRPublish, emai_PRPreferredPublished, emai_PRPreferredInternal, emai_CompanyID, emai_CreatedBy, emai_CreatedDate, emai_UpdatedBy, emai_UpdatedDate, emai_Timestamp) " +
                                                            "VALUES (@EmailId, @EmailAddress, @WebSite, @Description, @PRPublish, @PRPublish, @Default, @CompanyID, @UpdatedBy, @UpdatedDate, @UpdatedBy, @UpdatedDate, @Timestamp)";


        private const string SQL_EMAILLINK_INSERT = "INSERT INTO EmailLink (elink_LinkID, elink_EntityID, elink_RecordID, elink_Type, ELink_EmailId, elink_CreatedBy, elink_CreatedDate, elink_UpdatedBy, elink_UpdatedDate, elink_Timestamp) " +
                                                           "VALUES (@EmailLinkID, @EntityID, @RecordID, @Type, @EmailId, @UpdatedBy, @UpdatedDate, @UpdatedBy, @UpdatedDate, @Timestamp)";

        public void Save(SqlTransaction oTran)
        {
            // First we need to see if we have an existing record.
            int emailID = GetPIKSID("Email", oTran);

            SqlCommand cmdSave = oTran.Connection.CreateCommand();
            cmdSave.CommandText = SQL_EMAIL_INSERT;
            cmdSave.Transaction = oTran;
            cmdSave.CommandTimeout = 300;

            cmdSave.Parameters.AddWithValue("EmailID", emailID);

            AddParameter(cmdSave, "EmailAddress", EmailAddress);
            AddParameter(cmdSave, "WebSite", WebSite);
            if (TypeCode == "E")
            {
                cmdSave.Parameters.AddWithValue("Description", "E-Mail");
            }
            else
            {
                cmdSave.Parameters.AddWithValue("Description", "Web Site");
            }
            cmdSave.Parameters.AddWithValue("PRPublish", "Y");
            cmdSave.Parameters.AddWithValue("Default", "Y");
            AddParameter(cmdSave, "CompanyID", CompanyID);
            cmdSave.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
            cmdSave.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
            cmdSave.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdSave.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdSave.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
            cmdSave.ExecuteNonQuery();


            int emailLinkID = GetPIKSID("EmailLink", oTran);
            SqlCommand cmdSaveLink = oTran.Connection.CreateCommand();
            cmdSaveLink.CommandText = SQL_EMAILLINK_INSERT;
            cmdSaveLink.Transaction = oTran;
            cmdSaveLink.CommandTimeout = 300;
            cmdSaveLink.Parameters.AddWithValue("EmailLinkID", emailLinkID);

            if (PersonID > 0)
            {
                cmdSaveLink.Parameters.AddWithValue("EntityID", 13);
                cmdSaveLink.Parameters.AddWithValue("RecordID", PersonID);
            }
            else
            {
                cmdSaveLink.Parameters.AddWithValue("EntityID", 5);
                cmdSaveLink.Parameters.AddWithValue("RecordID", CompanyID);
            }

            cmdSaveLink.Parameters.AddWithValue("Type", TypeCode);
            cmdSaveLink.Parameters.AddWithValue("EmailId", emailID);
            cmdSaveLink.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
            cmdSaveLink.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
            cmdSaveLink.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdSaveLink.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdSaveLink.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
            cmdSaveLink.ExecuteNonQuery();
        }
    }
}
