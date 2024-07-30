using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IntlTradeAssociationImport
{
    public class Company : EntityBase
    {
        public int CompanyID;
        public string MemberID;
        public string CompanyName;
        public string City;
        public string State;
        public string Website;
        public string Email;
        public string AssociationCode;
        public string AssociationMemberID;
        public string DefaultTimeZone;

        public string Rating;
        public string ServiceCode;

        public bool Matched;
        public bool MultipleMatchInCRM;
        public string MultipleMatchCompanyIDs;
        public bool DoNotMatch;
        public bool Duplicate;

        public bool Inserted;
        public bool Deleted;

        public int ListingCityID;
        public string ListingStatus;
        public int CompanyTradeAssociationID;

        public bool IsMember;
        public bool HasRating;
        public bool HasBBScore;
        public bool HasAffiliations;
        public bool HasDL;
        public bool HasOtherIntlTradeAssocations;
        public bool IsIntlTradeAssociation;

        public List<Phone> Phones = new List<Phone>();
        public List<Person> Persons = new List<Person>();
        public List<Address> Addresses = new List<Address>();
        public List<Commodity> Commodities = new List<Commodity>();

        public bool HasPhonePreferredInternal = false;
        public bool HasPhonePreferrePublished = false;

        public string actionCode = "NEW";
        public bool IsValid = true;
        public string ValidationMsg;


        private int existingCityID = 0;
        private string existingCompanyName = string.Empty;
        private const string SQL_VALIDATE_BBID =
             @"SELECT comp_CompanyID, Company.comp_Name, comp_PRListingStatus, comp_PRListingCItyID, prse_ServiceCode,
                      prcta_CompanyTradeAssociationID, prcta_IsIntlTradeAssociation,
                      prra_RatingID, prbs_BBScoreID, HasAffiliations, HasDL,
					  OtherIntlTACount, comp_PRIsIntlTradeAssociation, comp_PRExcludeFromIntlTA,
                      prra_RatingLine, prse_ServiceCode
                 FROM Company WITH (NOLOCK)
                      LEFT OUTER JOIN (SELECT DISTINCT @CompanyID as CompanyID, 'Y' as HasAffiliations FROM dbo.ufn_GetCompanyAffiliations(@CompanyID)) T1 ON comp_CompanyID = CompanyID
                      LEFT OUTER JOIN PRCompanyTradeAssociation WITH (NOLOCK) ON comp_CompanyID = prcta_CompanyID AND prcta_TradeAssociationCode = @TradeAssociationCode
                      LEFT OUTER JOIN PRService ON comp_PRHQID = prse_HQID AND prse_Primary = 'Y'
                      LEFT OUTER JOIN vPRCompanyRating WITH (NOLOCK) ON comp_CompanyID = prra_CompanyID AND prra_Current = 'Y'
                      LEFT OUTER JOIN PRBBScore WITH (NOLOCK) ON comp_CompanyID = prbs_CompanyID AND prbs_Current = 'Y' AND prbs_BBScore > 0
					  LEFT OUTER JOIN (SELECT prcta_CompanyID OtherIntlTACompanyID, COUNT(1) OtherIntlTACount FROM PRCompanyTradeAssociation WITH (NOLOCK) WHERE prcta_IsIntlTradeAssociation = 'Y' AND prcta_TradeAssociationCode <> @TradeAssociationCode GROUP BY prcta_CompanyID) T2 ON comp_CompanyID = OtherIntlTACompanyID
					  LEFT OUTER JOIN (SELECT DISTINCT comp_PRHQID as DLHQID , 'Y' HasDL FROM Company WITH (NOLOCK) INNER JOIN PRDescriptiveLine WITH (NOLOCK) ON comp_CompanyID = prdl_CompanyID AND comp_PRPublishDL='Y') T3 ON comp_PRHQID = DLHQID
                WHERE comp_CompanyID = @CompanyID;";

        private SqlCommand cmdValidateBBID = null;
        private void ValidateBBID(SqlTransaction sqlTrans)
        {
            if (cmdValidateBBID == null)
            {
                cmdValidateBBID = new SqlCommand();
                cmdValidateBBID.Connection = sqlTrans.Connection;
                cmdValidateBBID.Transaction = sqlTrans;
                cmdValidateBBID.CommandText = SQL_VALIDATE_BBID;
            }

            cmdValidateBBID.Parameters.Clear();
            cmdValidateBBID.Parameters.AddWithValue("CompanyID", CompanyID);
            cmdValidateBBID.Parameters.AddWithValue("TradeAssociationCode", AssociationCode);

            using (SqlDataReader reader = cmdValidateBBID.ExecuteReader())
            {
                if (reader.Read())
                {
                    existingCompanyName = reader.GetString(1);
                    ListingStatus = reader.GetString(2);
                    existingCityID = reader.GetInt32(3);
                    IsMember = GetBoolValue(reader, 4);
                    CompanyTradeAssociationID = GetIntValue(reader, 5);
                    HasRating = GetBoolValue(reader, 7);
                    HasBBScore = GetBoolValue(reader, 8);
                    HasAffiliations = GetBoolValue(reader, 9);
                    HasDL = GetBoolValue(reader, 10);
                    HasOtherIntlTradeAssocations = GetBoolValue(reader, 11);
                    IsIntlTradeAssociation = GetBoolValue(reader, 12);
                    DoNotMatch = GetBoolValue(reader, 13);
                    Rating = GetStringValue(reader, 14);
                    ServiceCode = GetStringValue(reader, 15);
                }
                else
                {
                    CompanyID = 0;
                }
            }
        }

        public void Validate()
        {
            if (HasRating || HasBBScore || HasAffiliations)
            {
                IsValid = false;
                ValidationMsg = "Company has rating, BB Score, and/or affiliations.";
                return;
            }
        }


        public void AddPhone(Phone newPhone)
        {
            // Don't add duplicates
            foreach (Phone phone in Phones)
            {
                if (phone.Number == newPhone.Number)
                {
                    return;
                }
            }

            newPhone.CompanyID = CompanyID;
            newPhone.SetTypeCode();
            newPhone.ParentImporter = this.ParentImporter;
            newPhone.ParentCompany = this;
            Phones.Add(newPhone);
        }

        public void AddAddress(Address newAddress)
        {
            newAddress.CompanyID = CompanyID;
            newAddress.Sequence = Addresses.Count + 1;
            newAddress.ParentImporter = this.ParentImporter;
            Addresses.Add(newAddress);
        }

        public void AddPerson(Person newPerson)
        {
            newPerson.CompanyID = CompanyID;
            newPerson.ParentImporter = this.ParentImporter;
            newPerson.ParentCompany = this;
            Persons.Add(newPerson);
        }

        public void AddCommodity(Commodity newCommodity)
        {
            newCommodity.CompanyID = CompanyID;
            newCommodity.ParentImporter = this.ParentImporter;
            newCommodity.ParentCompany = this;
            newCommodity.Sequence = Commodities.Count + 1;
            Commodities.Add(newCommodity);
        }


        protected const string SQL_COMPANY_INSERT =
            "INSERT INTO Company (comp_CompanyID, comp_PRHQID, comp_PRIsIntlTradeAssociation, comp_PRHasITAAccess, comp_Name, comp_PRTradestyle1, comp_PRCorrTradestyle, comp_PRBookTradestyle, comp_PRType, comp_PRListingStatus, comp_PRListingCityID, comp_PRIndustryType, comp_Source, comp_PROnlineOnly,  comp_PRCommunicationLanguage, comp_CreatedBy, comp_CreatedDate, comp_UpdatedBy, comp_UpdatedDate, comp_Timestamp) " +
                         "VALUES (@comp_CompanyID,@comp_CompanyID,@comp_IsIntlTradeAssociation,@comp_IsIntlTradeAssociation,@comp_Name,@comp_Name,         @comp_Name,            @comp_Name,            @comp_PRType,@comp_PRListingStatus,@comp_PRListingCityID,@comp_PRIndustryType,@comp_Source, @comp_PROnlineOnly, @Language, @CreatedBy, @CreatedDate, @UpdatedBy, @UpdatedDate, @Timestamp)";

        protected const string SQL_COMPANY_UPDATE =
            @"UPDATE Company
                 SET comp_Name=@comp_Name, 
                     comp_PRTradestyle1 = @comp_Name, 
                     comp_PRCorrTradestyle = @comp_Name, 
                     comp_PRBookTradestyle = @comp_Name, 
                     comp_PRListingStatus = @comp_PRListingStatus,
                     comp_PRListingCityID = @comp_PRListingCityID, 
                     comp_PROnlineOnly = @comp_PROnlineOnly, 
                     comp_PRPublishDL = NULL,
                     comp_PRPublishUnloadHours = NULL,
                     comp_PRTMFMAward = NULL,
                     comp_PRTMFMAwardDate = NULL,
                     comp_PRLegalName = NULL,
                     comp_PRCommunicationLanguage = @Language,
                     comp_PRIsIntlTradeAssociation = @comp_IsIntlTradeAssociation,
                     comp_PRHasITAAccess = @comp_IsIntlTradeAssociation,
                     comp_UpdatedBy = @UpdatedBy, 
                     comp_UpdatedDate = @UpdatedDate, 
                     comp_Timestamp = @Timestamp  
               WHERE comp_CompanyID = @comp_CompanyID";

        private bool IsNewRecord = false;
        public void Save(SqlTransaction sqlTrans)
        {
            ValidateBBID(sqlTrans);

            if (DoNotMatch)
            {
                ParentImporter.WriteLine(" - Skipping Company ID " + CompanyID.ToString());
                ParentImporter.AddException(this, "Company flagged as 'Do Not Match' - Skipping." );
                return;
            }

            if ((HasRating) || (HasBBScore) || (HasAffiliations))
            {
                ParentImporter.WriteLine(" - Skipping Company ID " + CompanyID.ToString());
                ParentImporter.AddException(this, "Matched to a company that has a rating, BB Score, or affiliations.  No action taken.");
                if (Duplicate)
                    ParentImporter.AddException(this, "Multiple import record matched to same BBID.  No action taken. Company ID: " + CompanyID.ToString());

                // Even though we're skipping this user, save them.
                SavePersons(sqlTrans);
                return;
            }

            if ((!IsIntlTradeAssociation) &&
                (ListingStatus == "L"))
            {
                if (IsMember)
                {
                    //ParentImporter.AddException(this, "Matched to a listed member company.  Only created the trade association record.");
                    ParentImporter.WriteLine(" - Matched to a listed member company ID: " + CompanyID.ToString());
                    ParentImporter.WriteLine(" - Creating the trade association record and adding persons.");
                    SaveTradeAssociation(sqlTrans, false);
                    SavePersons(sqlTrans);
                }
                else
                {
                    //ParentImporter.AddException(this, "Matched to a listed non-member company.  Created the trade association record and associated persons.");
                    //SaveCompanyIntlTA(sqlTrans);
                    ParentImporter.WriteLine(" - Matched to an listed non-member company ID: " + CompanyID.ToString());
                    ParentImporter.WriteLine(" - Creating the trade association record and adding persons.");
                    SaveTradeAssociation(sqlTrans, true);
                    SavePersons(sqlTrans);
                }

                return;
            }

            if (Duplicate)
            {
                ParentImporter.AddException(this, "Multiple import record matched to same BBID.  No action taken. Company ID: " + CompanyID.ToString());
                RefreshPersons(sqlTrans);
                return;
            }

            Addresses[0].SetCityID(sqlTrans);
            ListingCityID = Addresses[0].CityID;

            if ((ListingCityID == 0) &&
                (existingCityID > 0))
            {
                ListingCityID = existingCityID;
            }

            if (ListingCityID == 0)
            {
                ParentImporter.AddInvalidCity(City + ", " + State);
                ParentImporter.WriteLine(" - Unable to save company, invalid City found: " + City + ", " + State);
                return;
            }


            int transactionID = 0;

            SqlCommand cmdSave = sqlTrans.Connection.CreateCommand();
            cmdSave.Transaction = sqlTrans;

            if (CompanyID == 0)
            {
                IsNewRecord = true;
                CompanyID = GetPIKSID("Company", sqlTrans);
                cmdSave.CommandText = SQL_COMPANY_INSERT;

                ParentImporter.WriteLine(" - Creating new company: " + CompanyID.ToString());
            }
            else
            {
                StringBuilder sbExplanation = new StringBuilder("Company updated from Intl Trade Association import.");
                cmdSave.CommandText = SQL_COMPANY_UPDATE;
                transactionID = OpenPIKSTransaction(sqlTrans, CompanyID, 0, sbExplanation.ToString());

                if (Matched)
                {
                    ParentImporter.WriteLine(" - Updating matched company: " + CompanyID.ToString());
                }
                else
                {
                    ParentImporter.WriteLine(" - Updating specified company: " + CompanyID.ToString());
                }

            }

            cmdSave.CommandTimeout = 300;
            cmdSave.Parameters.AddWithValue("comp_CompanyID", CompanyID);
            cmdSave.Parameters.AddWithValue("comp_PRHQID", CompanyID);
            cmdSave.Parameters.AddWithValue("comp_Name", CompanyName);
            cmdSave.Parameters.AddWithValue("comp_PRType", "H");
            cmdSave.Parameters.AddWithValue("comp_PRListingStatus", "L");
            cmdSave.Parameters.AddWithValue("comp_PRListingCityID", ListingCityID);
            cmdSave.Parameters.AddWithValue("comp_PRIndustryType", "P");
            cmdSave.Parameters.AddWithValue("comp_Source", "ITA");
            cmdSave.Parameters.AddWithValue("Language", "S");
            cmdSave.Parameters.AddWithValue("comp_IsIntlTradeAssociation", "Y");


            if ((IsMember) || (HasRating) || (HasBBScore))
            {
                cmdSave.Parameters.AddWithValue("comp_PROnlineOnly", DBNull.Value);
            }
            else
            {
                cmdSave.Parameters.AddWithValue("comp_PROnlineOnly", "Y");
            }

            cmdSave.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
            cmdSave.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
            cmdSave.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdSave.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdSave.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
            cmdSave.ExecuteNonQuery();

            if (transactionID == 0)
            {
                StringBuilder sbExplanation = new StringBuilder("Company created from Intl Trade Association import.");
                transactionID = OpenPIKSTransaction(sqlTrans, CompanyID, 0, sbExplanation.ToString());
            }


            SaveTradeAssociation(sqlTrans, true);


            Address.DeleteAll(sqlTrans, CompanyID);
            foreach (Address address in Addresses)
            {
                if (!string.IsNullOrEmpty(address.Street1))
                {
                    address.CompanyID = CompanyID;
                    address.Save(sqlTrans, "M");
                }
            }


            HasPhonePreferredInternal = Phone.HasPhoneFlag(sqlTrans, CompanyID, "phon_PRIsPhone", "phon_PRPreferredInternal");
            HasPhonePreferrePublished = Phone.HasPhoneFlag(sqlTrans, CompanyID, "phon_PRIsPhone", "phon_PRPreferredPublished");
            foreach (Phone phone in Phones)
            {
                phone.CompanyID = CompanyID;
                phone.Save(sqlTrans);
            }

            SaveEmail(sqlTrans, CompanyID, 0, Email);
            SaveWebsite(sqlTrans, CompanyID, 0, Website);
            SaveClassification(sqlTrans, 360);  // Grower

            Commodity.DeleteAll(sqlTrans, CompanyID);
            foreach (Commodity commodity in Commodities)
            {
                commodity.CompanyID = CompanyID;
                commodity.Save(sqlTrans);
            }

            ClosePIKSTransaction(transactionID, sqlTrans);

            if (!IsNewRecord)
            {
                DeletePIKSTransaction(transactionID, sqlTrans);
            }

            SavePersons(sqlTrans);
            UpdateTES(sqlTrans, CompanyID);
        }

        protected void SavePersons(SqlTransaction sqlTrans)
        {
            foreach (Person person in Persons)
            {
                person.CompanyID = CompanyID;
                person.Save(sqlTrans, IsNewRecord);
            }

            //// Now go find any 
            //bool found = false;
            //List<Person> existingPersons = new Person().GetIntlTAPersons(sqlTrans, CompanyID);
            //foreach (Person existingPerson in existingPersons)
            //{
            //    found = false;
            //    foreach (Person person in Persons)
            //    {
            //        if (existingPerson.PersonLinkID == person.PersonLinkID)
            //        {
            //            found = true;
            //            break;
            //        }
            //    }

            //    if (!found)
            //    {
            //        existingPerson.RemoveIntlPerson(sqlTrans);
            //    }
            //}
        }

        protected void RefreshPersons(SqlTransaction sqlTrans)
        {
            foreach (Person person in Persons) {
                person.CompanyID = CompanyID;
                person.RefreshFromCRM(sqlTrans, IsNewRecord);
            }
        }

        protected const string SQL_COMPANY_INTL_UPDATE =
            @"UPDATE Company
                 SET comp_PRIsIntlTradeAssociation = @comp_IsIntlTradeAssociation,
                     comp_PRHasITAAccess = @comp_IsIntlTradeAssociation,
                     comp_PROnlineOnly = @comp_PROnlineOnly, 
                     comp_UpdatedBy = @UpdatedBy, 
                     comp_UpdatedDate = @UpdatedDate, 
                     comp_Timestamp = @Timestamp  
               WHERE comp_CompanyID = @comp_CompanyID";

        private void SaveCompanyIntlTA(SqlTransaction sqlTrans, bool IsIntlTradeAssociation, bool OnlineOnly)
        {
            StringBuilder sbExplanation = new StringBuilder("Company updated from Intl Trade Association import.");
            int transactionID = OpenPIKSTransaction(sqlTrans, CompanyID, 0, sbExplanation.ToString());


            SqlCommand cmdSave = sqlTrans.Connection.CreateCommand();
            cmdSave.Transaction = sqlTrans;
            cmdSave.CommandText = SQL_COMPANY_INTL_UPDATE;
            cmdSave.Parameters.AddWithValue("comp_CompanyID", CompanyID);
            AddParameter(cmdSave, "comp_IsIntlTradeAssociation", IsIntlTradeAssociation);
            AddParameter(cmdSave, "comp_PROnlineOnly", OnlineOnly);
            cmdSave.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdSave.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdSave.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
            cmdSave.ExecuteNonQuery();

            ClosePIKSTransaction(transactionID, sqlTrans);
        }


        protected const string INSERT_TA =
                @"INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_MemberID, prcta_TradeAssociationCode, prcta_IsIntlTradeAssociation, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp)
                VALUES (@CompanyID, @MemberID, @Type, @IsIntlTradeAssociation, @UpdatedBy, @UpdatedDate, @UpdatedBy, @UpdatedDate, @UpdatedDate)";
        private SqlCommand cmdInsertTA = null;
        protected void SaveTradeAssociation(SqlTransaction sqlTrans, bool isIntlTradeAssociation)
        {
            if (CompanyTradeAssociationID > 0)
            {
                return;
            }

            if (cmdInsertTA == null)
            {
                cmdInsertTA = new SqlCommand();
                cmdInsertTA.Connection = sqlTrans.Connection;
                cmdInsertTA.Transaction = sqlTrans;
                cmdInsertTA.CommandText = INSERT_TA;
            }

            cmdInsertTA.Parameters.Clear();
            cmdInsertTA.Parameters.AddWithValue("CompanyID", CompanyID);
            AddParameter(cmdInsertTA, "IsIntlTradeAssociation", isIntlTradeAssociation);
            AddParameter(cmdInsertTA, "MemberID", AssociationMemberID);
            cmdInsertTA.Parameters.AddWithValue("Type", AssociationCode);
            cmdInsertTA.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdInsertTA.Parameters.AddWithValue("UpdatedDate", UPDATED_BY);
            cmdInsertTA.ExecuteNonQuery();
        }

        private const string SQL_SELECT_CLASSIFICATIONS =
            "SELECT prc2_ClassificationID FROM PRCompanyClassification WITH (NOLOCK) WHERE prc2_CompanyID=@CompanyID";

        private HashSet<Int32> _classifications;

        protected bool HasClassification(SqlTransaction sqlTrans, int classificationID)
        {
            if (_classifications == null)
            {
                SqlCommand cmdClassifications = new SqlCommand();
                cmdClassifications.Connection = sqlTrans.Connection;
                cmdClassifications.Transaction = sqlTrans;
                cmdClassifications.CommandText = SQL_SELECT_CLASSIFICATIONS;
                cmdClassifications.Parameters.AddWithValue("CompanyID", CompanyID);

                _classifications = new HashSet<int>();
                using (SqlDataReader reader = cmdClassifications.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        _classifications.Add(reader.GetInt32(0));
                    }
                }
            }

            if (_classifications.Contains(classificationID))
            {
                return true;
            }

            return false;
        }



        private const string SQL_PRCOMPANY_CLASSIFICATION_INSERT =
            "INSERT INTO PRCompanyClassification (prc2_CompanyClassificationId, prc2_CompanyId, prc2_ClassificationId, prc2_CreatedBy, prc2_CreatedDate, prc2_UpdatedBy, prc2_UpdatedDate, prc2_Timestamp) " +
            "VALUES (@CompanyClassificationId, @CompanyId, @ClassificationId, @UpdatedBy, @UpdatedDate, @UpdatedBy, @UpdatedDate, @Timestamp)";

        protected void SaveClassification(SqlTransaction sqlTrans, int classificationID)
        {
            if (HasClassification(sqlTrans, classificationID))
            {
                return;
            }

            int iCompanyClassificationID = GetPIKSID("PRCompanyClassification", sqlTrans);

            SqlCommand cmdCompanyClassificationInsert = sqlTrans.Connection.CreateCommand();
            cmdCompanyClassificationInsert.CommandText = SQL_PRCOMPANY_CLASSIFICATION_INSERT;
            cmdCompanyClassificationInsert.Transaction = sqlTrans;
            cmdCompanyClassificationInsert.Parameters.AddWithValue("CompanyClassificationId", iCompanyClassificationID);
            cmdCompanyClassificationInsert.Parameters.AddWithValue("CompanyID", CompanyID);
            cmdCompanyClassificationInsert.Parameters.AddWithValue("ClassificationId", classificationID);
            cmdCompanyClassificationInsert.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
            cmdCompanyClassificationInsert.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
            cmdCompanyClassificationInsert.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdCompanyClassificationInsert.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdCompanyClassificationInsert.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
            cmdCompanyClassificationInsert.ExecuteNonQuery();
        }

        private const string SQL_TES_UPDATE =
            @"UPDATE PRAttentionLine
		         SET prattn_PhoneID = @PhoneID,
                     prattn_EmailID = @EmailID, 
                     prattn_PersonID = @PersonID,
                     prattn_Disabled = @Disabled, 
                     prattn_UpdatedBy = @UpdatedBy, 
                     prattn_UpdatedDate = @UpdatedDate 
		       WHERE prattn_CompanyID = @CompanyId
                 AND prattn_ItemCode IN ('TES-E', 'LRL', 'JEP-E');";

        private SqlCommand cmdUpdateTES = null;

        private void UpdateTES(SqlTransaction sqlTrans, int companyID)
        {
            if (cmdUpdateTES == null)
            {
                cmdUpdateTES = new SqlCommand();
                cmdUpdateTES.Connection = sqlTrans.Connection;
                cmdUpdateTES.Transaction = sqlTrans;
                cmdUpdateTES.CommandText = SQL_TES_UPDATE;
            }

            cmdUpdateTES.Parameters.Clear();
            cmdUpdateTES.Parameters.AddWithValue("CompanyID", companyID);

            int tesEmailID = 0;
            int tesPersonID = 0;
            foreach (Person person in Persons)
            {
                if (person.EmailID > 0)
                {
                    if (tesEmailID == 0)
                    {
                        tesEmailID = person.EmailID;
                        tesPersonID = person.PersonID;
                        break;
                    }
                }
            }

            int tesFaxID = 0;
            if (tesEmailID == 0)
            {
                foreach (Phone phone in Phones)
                {
                    if ((phone.PhoneID > 0) &&
                        ((phone.Type == "F") ||
                         (phone.Type == "PF")))
                    {
                        tesFaxID = phone.PhoneID;
                        break;
                    }
                }
            }


            AddParameter(cmdUpdateTES, "EmailID", tesEmailID);
            AddParameter(cmdUpdateTES, "PhoneID", tesFaxID);
            AddParameter(cmdUpdateTES, "PersonID", tesPersonID);

            if (tesEmailID == 0 && tesFaxID == 0)
            {
                cmdUpdateTES.Parameters.AddWithValue("Disabled", "Y");
            }
            else
            {
                cmdUpdateTES.Parameters.AddWithValue("Disabled", DBNull.Value);
            }


            cmdUpdateTES.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdUpdateTES.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdUpdateTES.ExecuteNonQuery();
        }

        public List<Company> GetIntlTACompanies(SqlTransaction sqlTrans)
        {
            List<Company> results = new List<Company>();

            SqlCommand sqlCommand = new SqlCommand();
            sqlCommand.Connection = sqlTrans.Connection;
            sqlCommand.Transaction = sqlTrans;
            sqlCommand.CommandText = "SELECT comp_CompanyID FROM Company WITH (NOLOCK) WHERE comp_PRIsIntlTradeAssociation = 'Y'";

            using (SqlDataReader reader = sqlCommand.ExecuteReader())
            {
                while (reader.Read())
                {
                    Company company = new Company();

                    company.CompanyID = reader.GetInt32(0);
                    results.Add(company);
                }
            }

            return results;
        }

        public void RemoveIntlCompany(SqlTransaction sqlTrans)
        {
            ValidateBBID(sqlTrans);

            if (!IsIntlTradeAssociation)
            {
                return;
            }

            // If this company is associated with other
            // Intl Trade Associations, keep it as is.
            if (!HasOtherIntlTradeAssocations)
            {

                // Keep the persons, but remove thier licenses
                List<Person> existingPersons = new Person().GetIntlTAPersons(sqlTrans, CompanyID, AssociationCode);
                foreach (Person existingPerson in existingPersons)
                {
                    existingPerson.ParentImporter = this.ParentImporter;
                    existingPerson.RemoveBBOSLicense(sqlTrans);
                }

                ParentImporter.WriteLine("Removing company from Intl Trade Association: " + CompanyID.ToString());
                SaveCompanyIntlTA(sqlTrans, false, true);
            }

            SqlCommand cmdSave = sqlTrans.Connection.CreateCommand();
            cmdSave.Transaction = sqlTrans;
            cmdSave.CommandText = "DELETE FROM PRCompanyTradeAssociation WHERE prcta_CompanyID=@CompanyID AND prcta_TradeAssociationCode=@TradeAssociationCode";
            cmdSave.Parameters.AddWithValue("CompanyID", CompanyID);
            cmdSave.Parameters.AddWithValue("TradeAssociationCode", AssociationCode);
            cmdSave.ExecuteNonQuery();
        }
    }
}
