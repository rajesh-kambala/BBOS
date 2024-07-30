using LumenWorks.Framework.IO.Csv;
using System;
using System.Data.SqlClient;

namespace FoodHubImporter
{
	public class Phone : MeisterMediaBase
	{
		public const string COL_PHONE = "Phone";
		public const string COL_FAX = "Fax";
		public const string COL_MOBILE = "Mobile";

		public int Sequence;
		public int CompanyID;
		public int PersonID;

		public string Type;
		public string Number;

		public void Load(CsvReader csv, string type)
		{
			switch(type)
			{
				case "P":
					Number = csv["Market_Phone"];
					break;
			}

			Number = Number.Replace("-", string.Empty);
			Type = type;
		}

		private const string SQL_PHONE_DELETE =
				 @"DECLARE @Tmp table (ID int);
              INSERT INTO @Tmp SELECT plink_PhoneID FROM PhoneLink WHERE plink_RecordID = @RecordID AND pLink_EntityId = @EntityID;
              DELETE FROM PhoneLink WHERE plink_RecordID = @RecordID AND pLink_EntityId = @EntityID;
              DELETE FROM Phone WHERE phon_PhoneID IN (SELECT ID FROM @Tmp);";

		public static void DeleteAll(SqlTransaction oTran, int companyID, int personID)
		{
			SqlCommand cmdDelete = oTran.Connection.CreateCommand();
			cmdDelete.Transaction = oTran;
			cmdDelete.CommandText = SQL_PHONE_DELETE;
			cmdDelete.CommandTimeout = 300;

			if(personID > 0)
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

		private const string SQL_PHONE_INSERT = "INSERT INTO Phone (phon_PhoneID, phon_PRDescription, Phon_AreaCode, Phon_Number, Phon_CountryCode, phon_PRPublish, phon_PRPreferredPublished, phon_PRPreferredInternal, phon_CompanyID, Phon_CreatedBy, Phon_CreatedDate, Phon_UpdatedBy, Phon_UpdatedDate, Phon_Timestamp) " +
																												"VALUES (@PhoneID, @Description, @AreaCode, @Number, @CountryCode, @PRPublish, @PreferredPublished, @Default, @CompanyID, @UpdatedBy, @UpdatedDate, @UpdatedBy, @UpdatedDate, @Timestamp)";


		private const string SQL_PHONELINK_INSERT = "INSERT INTO PhoneLink (plink_LinkID, plink_EntityID, plink_RecordID, plink_Type, plink_PhoneID, plink_CreatedBy, plink_CreatedDate, plink_UpdatedBy, plink_UpdatedDate, plink_Timestamp) " +
																											 "VALUES (@PhoneLinkID, @EntityID, @RecordID, @Type, @PhoneID, @UpdatedBy, @UpdatedDate, @UpdatedBy, @UpdatedDate, @Timestamp)";


		public void Save(SqlTransaction oTran, bool isDefault)
		{

			if(string.IsNullOrEmpty(Number))
			{
				return;
			}

			if(Number.Length != 10)
			{
				return;
			}

			string areaCode = Number.Substring(0, 3);
			string phoneNumber = Number.Substring(3, 3) + "-" + Number.Substring(6, 4);

			int phoneID = GetPIKSID("Phone", oTran);

			SqlCommand cmdSave = oTran.Connection.CreateCommand();
			cmdSave.CommandText = SQL_PHONE_INSERT;
			cmdSave.Transaction = oTran;
			cmdSave.CommandTimeout = 300;
			cmdSave.Parameters.AddWithValue("PhoneID", phoneID);

			switch(Type)
			{
				case "P":
					cmdSave.Parameters.AddWithValue("Description", "Phone");
					break;
				case "F":
					cmdSave.Parameters.AddWithValue("Description", "FAX");
					break;
				case "PF":
					cmdSave.Parameters.AddWithValue("Description", "Phone or FAX");
					break;
				case "C":
					cmdSave.Parameters.AddWithValue("Description", "Cell");
					break;
			}

			cmdSave.Parameters.AddWithValue("AreaCode", areaCode);
			cmdSave.Parameters.AddWithValue("Number", phoneNumber);
			cmdSave.Parameters.AddWithValue("CountryCode", "1");
			cmdSave.Parameters.AddWithValue("PRPublish", "Y");

			if(isDefault)
			{
				cmdSave.Parameters.AddWithValue("Default", "Y");
				cmdSave.Parameters.AddWithValue("PreferredPublished", "Y");
			}
			else
			{
				cmdSave.Parameters.AddWithValue("Default", DBNull.Value);
				cmdSave.Parameters.AddWithValue("PreferredPublished", DBNull.Value);
			}

			// Only save this comnpany ID on person phone
			// records.
			if(PersonID > 0)
			{
				cmdSave.Parameters.AddWithValue("CompanyID", CompanyID);
			}
			else
			{
				cmdSave.Parameters.AddWithValue("CompanyID", DBNull.Value);
			}

			cmdSave.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
			cmdSave.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
			cmdSave.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
			cmdSave.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
			cmdSave.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
			cmdSave.ExecuteNonQuery();

			// First we need to see if we have an existing record.
			int phoneLinkID = GetPIKSID("PhoneLink", oTran);

			SqlCommand cmdSaveLink = oTran.Connection.CreateCommand();
			cmdSaveLink.CommandText = SQL_PHONELINK_INSERT;
			cmdSaveLink.Transaction = oTran;
			cmdSaveLink.CommandTimeout = 300;
			cmdSaveLink.Parameters.AddWithValue("PhoneLinkID", phoneLinkID);

			if(PersonID > 0)
			{
				cmdSaveLink.Parameters.AddWithValue("EntityID", 13);
				cmdSaveLink.Parameters.AddWithValue("RecordID", PersonID);
			}
			else
			{
				cmdSaveLink.Parameters.AddWithValue("EntityID", 5);
				cmdSaveLink.Parameters.AddWithValue("RecordID", CompanyID);

			}

			cmdSaveLink.Parameters.AddWithValue("Type", Type);
			cmdSaveLink.Parameters.AddWithValue("PhoneID", phoneID);
			cmdSaveLink.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
			cmdSaveLink.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
			cmdSaveLink.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
			cmdSaveLink.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
			cmdSaveLink.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
			cmdSaveLink.ExecuteNonQuery();
		}
	}
}
