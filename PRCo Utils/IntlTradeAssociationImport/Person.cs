using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlClient;

namespace IntlTradeAssociationImport
{
    public class Person : EntityBase
    {
        public string FirstName;
        public string MiddleName;
        public string LastName;
        public string Title;
        public string PhoneType;
        public string Phone;
        public string Email;
        public int Sequence;

        public int PersonID;
        public int PersonLinkID;
        public int CompanyID;
        public int WebUserID;
        public int EmailID;
        public bool IsIntlTradeAssociation;
        public string ServiceCode;
        public string Status;

        private char[] nameDelimiter = { ' ' };
        public void FormatName()
        {
            FirstName = CleanName(FirstName);
            LastName = CleanName(LastName);

            if (FirstName == LastName)
            {
                string[] tokens = LastName.Split(nameDelimiter, StringSplitOptions.RemoveEmptyEntries);
                FirstName = tokens[0].Trim();

                if (tokens.Length == 2)
                    LastName = tokens[1].Trim();
                else if (tokens.Length == 3)
                    LastName = tokens[1].Trim() + " " + tokens[2].Trim();
                else if (tokens.Length >= 4) {
                    MiddleName = tokens[1].Trim();

                    LastName = tokens[2].Trim(); ;
                    for (int i = 3; i < tokens.Length; i++) {
                        LastName += " " + tokens[i].Trim();
                    }

                }
            }
        }

        private string CleanName(string name)
        {
            return name;

            //string work = name;
            //work = removeToken("Lic");
            //work = removeToken("Ing");
            //work = removeToken("Dra");
            //work = removeToken("Dr");
            //work = removeToken("Arq");
            //work = removeToken("Prof");
            //work = removeToken("Mtro");
            //work = removeToken("Enfra");
            //work = removeToken("C.P");
            //work = removeToken("CP");
            //work = removeToken("Q.F.B");
            //work = removeToken("QFB");
            //work = removeToken("Pte");
            //work = removeToken("Stario");
            //work = removeToken("Voc");
            //work = removeToken("Tes");
            //work = removeToken("Dir");
            //work = removeToken("Ec");
            //work = removeToken("C");

            //return work;
        }

        private string removeToken(string token)
        {
            string work = token;
            if (work.StartsWith(token + ". "))
            {
                work = work.Substring(0, token.Length + 2);
            }
            if (work.StartsWith(token + " "))
            {
                work = work.Substring(0, token.Length + 1);
            }
            return work;
        }

        protected const string SQL_PERSON_INSERT =
             "INSERT INTO Person (Pers_PersonId, Pers_FirstName, pers_MiddleName, Pers_LastName, pers_PRIsIntlTradeAssociation, Pers_CreatedBy, Pers_CreatedDate, Pers_UpdatedBy, Pers_UpdatedDate, Pers_Timestamp) " +
                          "VALUES (@Pers_PersonId, @Pers_FirstName,@pers_MiddleName,@Pers_LastName, @pers_PRIsIntlTradeAssociation, @CreatedBy, @CreatedDate, @UpdatedBy, @UpdatedDate, @Timestamp)";

        protected const string SQL_PERSON_UPDATE =
            @"UPDATE Person
                 SET Pers_FirstName=@Pers_FirstName, 
                     pers_MiddleName=@pers_MiddleName,
                     Pers_LastName=@Pers_LastName, 
                     pers_PRIsIntlTradeAssociation=@pers_PRIsIntlTradeAssociation, 
                     Pers_UpdatedBy=@UpdatedBy, 
                     Pers_UpdatedDate=@UpdatedDate, 
                     Pers_Timestamp=@Timestamp  
               WHERE Pers_PersonId = @Pers_PersonId";


        protected const string SQL_PERSON_LINK_INSERT =
             @"INSERT INTO Person_Link (PeLi_PersonLinkId, PeLi_PersonId, PeLi_CompanyID, peli_PRRole, peli_PROwnershipRole, peli_PRTitleCode, peli_PRTitle, peli_PREBBPublish, peli_PRBRPublish, peli_PRStatus,
                                   peli_PRSubmitTES, peli_PRSequence, peli_PRCSReceiveMethod, peli_CreatedBy, peli_CreatedDate, peli_UpdatedBy, peli_UpdatedDate, peli_Timestamp) 
                          VALUES (@PeLi_PersonLinkId,@PeLi_PersonId,@PeLi_CompanyID, @peli_PRRole, @peli_PROwnershipRole, @peli_PRTitleCode, @peli_PRTitle, @peli_PREBBPublish, @peli_PRBRPublish, @peli_PRStatus,
                                  @peli_PRSubmitTES, @peli_PRSequence, @peli_PRCSReceiveMethod, @CreatedBy, @CreatedDate, @UpdatedBy, @UpdatedDate, @Timestamp)";


        protected const string SQL_PERSON_LINK_UPDATE =
            @"UPDATE Person_Link
                 SET peli_PRRole = @peli_PRRole, 
                     peli_PROwnershipRole = @peli_PROwnershipRole, 
                     peli_PRTitleCode = @peli_PRTitleCode, 
                     peli_PRTitle = @peli_PRTitle, 
                     peli_PREBBPublish = @peli_PREBBPublish, 
                     peli_PRBRPublish = @peli_PRBRPublish, 
                     peli_PRStatus = @peli_PRStatus,
                     peli_PRCSReceiveMethod = @peli_PRCSReceiveMethod,
                     peli_PRSequence = @peli_PRSequence, 
                     peli_UpdatedBy=@UpdatedBy, 
                     peli_UpdatedDate=@UpdatedDate, 
                     peli_Timestamp=@Timestamp  
               WHERE peli_CompanyID = @peli_CompanyID
                 AND peli_PersonID = @peli_PersonID";

        public void Save(SqlTransaction sqlTrans, bool newCompany)
        {
            bool newRecord = false;

            if ((!newCompany) &&
                (PersonID == 0))
            {
                matchOnName(sqlTrans);
            }


            if (Status == "3") {
                ParentImporter.WriteLine(" - Skipping existing person because they are marked NLC: " + FirstName + " " + LastName + ": " + PersonID.ToString());
                return;
            }

            int transactionID = 0;
            SqlCommand cmdSave = sqlTrans.Connection.CreateCommand();
            cmdSave.Transaction = sqlTrans;

            if (PersonID == 0)
            {
                newRecord = true;
                PersonID = GetPIKSID("Person", sqlTrans);
                cmdSave.CommandText = SQL_PERSON_INSERT;
                ParentImporter.WriteLine(" - Saving new person: " + FirstName + " " + LastName + " - " + PersonID.ToString());
            }
            else
            {
                cmdSave.CommandText = SQL_PERSON_UPDATE;
                StringBuilder sbExplanation = new StringBuilder("Person updated from Intl Trade Association import." + Environment.NewLine);
                transactionID = OpenPIKSTransaction(sqlTrans, 0, PersonID, sbExplanation.ToString());
                ParentImporter.WriteLine(" - Updating existing person: " + FirstName + " " + LastName + ": " + PersonID.ToString());
            }

            cmdSave.Parameters.AddWithValue("Pers_PersonId", PersonID);
            cmdSave.Parameters.AddWithValue("Pers_FirstName", FirstName);
            AddParameter(cmdSave, "pers_MiddleName", MiddleName);
            cmdSave.Parameters.AddWithValue("Pers_LastName", LastName);
            cmdSave.Parameters.AddWithValue("pers_PRIsIntlTradeAssociation", 'Y');
            cmdSave.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
            cmdSave.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
            cmdSave.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdSave.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdSave.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
            cmdSave.ExecuteNonQuery();

            if (transactionID == 0)
            {
                StringBuilder sbExplanation = new StringBuilder("Person created from Intl Trade Association import." + Environment.NewLine);
                transactionID = OpenPIKSTransaction(sqlTrans, 0, PersonID, sbExplanation.ToString());
            }


            SqlCommand cmdSaveLink = sqlTrans.Connection.CreateCommand();
            cmdSaveLink.Transaction = sqlTrans;
            if (newRecord)
            {
                cmdSave.CommandText = SQL_PERSON_INSERT;
                PersonLinkID = GetPIKSID("Person_Link", sqlTrans);
                cmdSaveLink.CommandText = SQL_PERSON_LINK_INSERT;
            }
            else
            {
                cmdSaveLink.CommandText = SQL_PERSON_LINK_UPDATE;
            }

            cmdSaveLink.Parameters.AddWithValue("PeLi_PersonLinkId", PersonLinkID);
            cmdSaveLink.Parameters.AddWithValue("PeLi_PersonId", PersonID);
            cmdSaveLink.Parameters.AddWithValue("PeLi_CompanyID", CompanyID);
            cmdSaveLink.Parameters.AddWithValue("peli_PRRole", DBNull.Value);
            cmdSaveLink.Parameters.AddWithValue("peli_PROwnershipRole", "RCR");
            cmdSaveLink.Parameters.AddWithValue("peli_PRTitleCode", "OTHR");
            cmdSaveLink.Parameters.AddWithValue("peli_PRTitle", DBNull.Value);
            cmdSaveLink.Parameters.AddWithValue("peli_PREBBPublish", "Y");
            cmdSaveLink.Parameters.AddWithValue("peli_PRBRPublish", "Y");
            cmdSaveLink.Parameters.AddWithValue("peli_PRStatus", "1");
            cmdSaveLink.Parameters.AddWithValue("peli_PRSubmitTES", "Y");
            cmdSaveLink.Parameters.AddWithValue("peli_PRUpdateCL", "Y");
            cmdSaveLink.Parameters.AddWithValue("peli_PRCSReceiveMethod", "3");
            cmdSaveLink.Parameters.AddWithValue("peli_PRSequence", 0);
            cmdSaveLink.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
            cmdSaveLink.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
            cmdSaveLink.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdSaveLink.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdSaveLink.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
            cmdSaveLink.ExecuteNonQuery();

            EmailID = SaveEmail(sqlTrans, CompanyID, PersonID, Email);

            if (WebUserID == 0)
            {
                CreateWebUser(sqlTrans);
            }
            else
            {
                UpdateWebuser(sqlTrans);
            }

            ClosePIKSTransaction(transactionID, sqlTrans);

            if (!newRecord)
            {
                DeletePIKSTransaction(transactionID, sqlTrans);
            }
        }

        private void CreateWebUser(SqlTransaction sqlTrans)
        {
            if (string.IsNullOrEmpty(Email))
            {
                return;
            }

            if (IsEmailInUse(sqlTrans))
            {
                ParentImporter.AddException(ParentCompany, "Email address already exists in CRM: " + Email);
                return;
            }

            ParentImporter.WriteLine(" - Creating web user record");

            SqlCommand cmdWebUser = new SqlCommand();
            cmdWebUser.Connection = sqlTrans.Connection;
            cmdWebUser.Transaction = sqlTrans;
            cmdWebUser.CommandText = "usp_CreateWebUserFromPersonLink";
            cmdWebUser.CommandType = System.Data.CommandType.StoredProcedure;
            cmdWebUser.Parameters.AddWithValue("PersonLinkID", PersonLinkID);
            cmdWebUser.Parameters.AddWithValue("ServiceCode", "ITALIC");
            cmdWebUser.Parameters.AddWithValue("MaxAccesslevel", "100");
            cmdWebUser.ExecuteNonQuery();
        }

        private const string SQL_UPDATE_WEBUSER =
            "UPDATE PRWebUser SET prwu_ServiceCode=@ServiceCode, prwu_AccessLevel=@AccessLevel, prwu_Disabled=NULL, prwu_Email=@Email, prwu_Timezone=@TimeZone, prwu_UpdatedBy=@UserID, prwu_UpdatedDate=@UpdatedDate, prwu_Timestamp=@UpdatedDate WHERE prwu_WebUserID=@WebUserID";
        private void UpdateWebuser(SqlTransaction sqlTrans)
        {
            if (string.IsNullOrEmpty(Email))
            {
                return;
            }

            ParentImporter.WriteLine(" - Updating web user record");

            SqlCommand cmdWebUser = new SqlCommand();
            cmdWebUser.Connection = sqlTrans.Connection;
            cmdWebUser.Transaction = sqlTrans;
            cmdWebUser.CommandText = SQL_UPDATE_WEBUSER;
            cmdWebUser.Parameters.AddWithValue("ServiceCode", "ITALIC");
            cmdWebUser.Parameters.AddWithValue("AccessLevel", "100");
            cmdWebUser.Parameters.AddWithValue("Email", Email);
            cmdWebUser.Parameters.AddWithValue("WebUserID", WebUserID);
            cmdWebUser.Parameters.AddWithValue("TimeZone", ParentCompany.DefaultTimeZone);
            cmdWebUser.Parameters.AddWithValue("UserID", UPDATED_BY);
            cmdWebUser.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);

            cmdWebUser.ExecuteNonQuery();
        }

        private const string SQL_MATCH_NAME =
       @"SELECT DISTINCT pers_PersonID, peli_PersonLinkID, prwu_WebUserID, prwu_ServiceCode, pers_PRIsIntlTradeAssociation, peli_PRStatus
                 FROM Person WITH (NOLOCK)
                      INNER JOIN Person_Link WITH (NOLOCK) ON pers_PersonID = peli_PersonID
                      LEFT OUTER JOIN PRWebUser WITH (NOLOCK) ON peli_PersonLinkID = prwu_PersonLinkID
                WHERE peli_CompanyID = @CompanyID
                  AND pers_FirstName = @FirstName
                  AND pers_LastName = @LastName";

        private SqlCommand cmdMatchName = null;
        protected void matchOnName(SqlTransaction sqlTrans)
        {

            cmdMatchName = new SqlCommand();
            cmdMatchName.Connection = sqlTrans.Connection;
            cmdMatchName.Transaction = sqlTrans;
            cmdMatchName.CommandText = SQL_MATCH_NAME;
            cmdMatchName.Parameters.AddWithValue("CompanyID", CompanyID);
            cmdMatchName.Parameters.AddWithValue("FirstName", FirstName);
            cmdMatchName.Parameters.AddWithValue("LastName", LastName);

            using (SqlDataReader reader = cmdMatchName.ExecuteReader())
            {
                if (reader.Read())
                {
                    PersonID = reader.GetInt32(0);
                    PersonLinkID = GetIntValue(reader, 1);
                    WebUserID = GetIntValue(reader, 2);
                    ServiceCode = GetStringValue(reader, 3);
                    IsIntlTradeAssociation = GetBoolValue(reader, 4);
                    Status = GetStringValue(reader, 5);
                }
            }

            return;
        }

        public void RefreshFromCRM(SqlTransaction sqlTrans, bool newCompany)
        {
            if ((!newCompany) &&
                (PersonID == 0)) {
                matchOnName(sqlTrans);
            }

        }


        private const string SQL_EXISTING_PERSONS =
       @"SELECT DISTINCT pers_PersonID, peli_PersonLinkID, prwu_WebUserID, prwu_ServiceCode, pers_PRIsIntlTradeAssociation, RTRIM(pers_FirstName) pers_FirstName, RTRIM(pers_LastName) pers_LastName, peli_CompanyID
                 FROM Person WITH (NOLOCK)
                      INNER JOIN Person_Link WITH (NOLOCK) ON pers_PersonID = peli_PersonID
                      INNER JOIN PRCompanyTradeAssociation WITH (NOLOCK) ON peli_CompanyId = prcta_CompanyID
                      LEFT OUTER JOIN PRWebUser WITH (NOLOCK) ON peli_PersonLinkID = prwu_PersonLinkID
                WHERE pers_PRIsIntlTradeAssociation = @pers_PRIsIntlTradeAssociation
                  AND prcta_TradeAssociationCode = @TradeAssociationCode
                  {0}
                  AND peli_PRStatus = '1'";

        public List<Person> GetIntlTAPersons(SqlTransaction sqlTrans, string typeCode)
        {
            return GetIntlTAPersons(sqlTrans, 0, typeCode);
        }

        public List<Person> GetIntlTAPersons(SqlTransaction sqlTrans, int companyID, string typeCode)
        {
            List<Person> results = new List<Person>();

            SqlCommand sqlCommand = new SqlCommand();
            sqlCommand.Connection = sqlTrans.Connection;
            sqlCommand.Transaction = sqlTrans;
            sqlCommand.CommandText = SQL_EXISTING_PERSONS;
            sqlCommand.Parameters.AddWithValue("pers_PRIsIntlTradeAssociation", "Y");
            sqlCommand.Parameters.AddWithValue("TradeAssociationCode", typeCode);

            string companyClause = string.Empty;
            if (companyID > 0)
            {
                sqlCommand.Parameters.AddWithValue("CompanyID", companyID);
                companyClause = "AND peli_CompanyID = @CompanyID";
            }

            sqlCommand.CommandText = string.Format(SQL_EXISTING_PERSONS, companyClause);

            using (SqlDataReader reader = sqlCommand.ExecuteReader())
            {
                while (reader.Read())
                {
                    Person person = new Person();

                    person.PersonID = reader.GetInt32(0);
                    person.PersonLinkID = GetIntValue(reader, 1);
                    person.WebUserID = GetIntValue(reader, 2);
                    person.ServiceCode = GetStringValue(reader, 3);
                    person.IsIntlTradeAssociation = GetBoolValue(reader, 4);
                    person.FirstName = GetStringValue(reader, 5);
                    person.LastName = GetStringValue(reader, 6);
                    person.CompanyID = reader.GetInt32(7);
                    results.Add(person);
                }
            }

            return results;
        }

        private const string SQL_REMOVE_PERSON =
             @"UPDATE Person_Link
                 SET peli_PRStatus = @peli_PRStatus,
                     peli_UpdatedBy=@UpdatedBy, 
                     peli_UpdatedDate=@UpdatedDate, 
                     peli_Timestamp=@Timestamp  
               WHERE peli_PersonLinkID=@PersonLinkID
                 AND peli_PRStatus = '1'";

        public void RemoveIntlPerson(SqlTransaction sqlTrans)
        {
            StringBuilder sbExplanation = new StringBuilder("Person updated from Intl Trade Association import." + Environment.NewLine);
            int transactionID = OpenPIKSTransaction(sqlTrans, 0, PersonID, sbExplanation.ToString());
            ParentImporter.WriteLine(" - Marking existing person NLC: " + FirstName + " " + LastName + ": " + PersonID.ToString());

            SqlCommand sqlCommand = new SqlCommand();
            sqlCommand.Connection = sqlTrans.Connection;
            sqlCommand.Transaction = sqlTrans;
            sqlCommand.CommandText = SQL_REMOVE_PERSON;
            sqlCommand.Parameters.AddWithValue("PersonLinkID", PersonLinkID);
            sqlCommand.Parameters.AddWithValue("peli_PRStatus", "3");
            sqlCommand.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            sqlCommand.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            sqlCommand.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
            sqlCommand.ExecuteNonQuery();

            ClosePIKSTransaction(transactionID, sqlTrans);

            RemoveBBOSLicense(sqlTrans);
        }

        private const string SQL_REMOVE_BBOS_LICENSE =
             @"UPDATE PRWebUser
                 SET prwu_ServiceCode = NULL,
                     prwu_AccessLevel = NULL,
                     prwu_Disabled = 'Y',
                     prwu_UpdatedBy=@UpdatedBy, 
                     prwu_UpdatedDate=@UpdatedDate, 
                     prwu_Timestamp=@Timestamp  
               WHERE prwu_WebUserID = @WebUserID";

        public void RemoveBBOSLicense(SqlTransaction sqlTrans)
        {
            if (WebUserID == 0)
            {
                return;
            }

            ParentImporter.WriteLine(" - Removing BBOS License: " + FirstName + " " + LastName + ": " + PersonID.ToString());
            SqlCommand sqlCommand = new SqlCommand();
            sqlCommand.Connection = sqlTrans.Connection;
            sqlCommand.Transaction = sqlTrans;
            sqlCommand.CommandText = SQL_REMOVE_BBOS_LICENSE;
            sqlCommand.Parameters.AddWithValue("WebUserID", WebUserID);
            sqlCommand.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            sqlCommand.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            sqlCommand.Parameters.AddWithValue("Timestamp", UPDATED_DATE);

            sqlCommand.ExecuteNonQuery();
        }

        private const string SQL_IS_EMAIL_IN_USE =
            @"SELECT prwu_Email FROM PRWebUser WITH (NOLOCK) WHERE prwu_Email=@Email";
        public bool IsEmailInUse(SqlTransaction sqlTrans)
        {
            SqlCommand sqlCommand = new SqlCommand();
            sqlCommand.Connection = sqlTrans.Connection;
            sqlCommand.Transaction = sqlTrans;
            sqlCommand.CommandText = SQL_IS_EMAIL_IN_USE;
            sqlCommand.Parameters.AddWithValue("Email", Email);
            object result = sqlCommand.ExecuteScalar();

            if ((result == null) ||
                (result == DBNull.Value))
            {
                return false;
            }

            return true;
        }
    }
}
