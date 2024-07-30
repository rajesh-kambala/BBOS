using System;
using System.Data.SqlClient;
using System.Text.RegularExpressions;
using LumenWorks.Framework.IO.Csv;

namespace IntlTradeAssociationImport
{
    public class Address : EntityBase
    {
        public string Street1;
        public string Street2;
        public string Street3;
        public string Street4;
        public string City;
        public string State;
        public string Postal;
        public string Country;

        public int CompanyID;
        public int CityID;
        public int StateID;
        public int Sequence;


        private const string SQL_FIND_CITY =
         @"SELECT prci_CityID, prst_StateID
             FROM vPRLocation
            WHERE dbo.ufn_GetLowerAlpha(prci_City) = dbo.ufn_GetLowerAlpha(@City)
              AND (prst_Abbreviation = @State OR prst_State = @State)";

        private SqlCommand cmdFindCity = null;
        public void SetCityID(SqlTransaction sqlTran)
        {

            if (string.IsNullOrEmpty(City))
            {
                WriteDebugMessage("Address.SetCityID() - Empty City.");
                return;
            }

            if (cmdFindCity == null)
            {
                cmdFindCity = new SqlCommand();
                cmdFindCity.Transaction = sqlTran;
                cmdFindCity.Connection = sqlTran.Connection;
                cmdFindCity.CommandText = SQL_FIND_CITY;
            }

            cmdFindCity.Parameters.Clear();
            cmdFindCity.Parameters.AddWithValue("City", City);
            cmdFindCity.Parameters.AddWithValue("State", State);

            using (SqlDataReader reader = cmdFindCity.ExecuteReader())
            {
                if (reader.Read())
                {
                    CityID = reader.GetInt32(0);
                    StateID = reader.GetInt32(1);
                }
            }
        }


        private const string SQL_ADDRESS_INSERT =
                @"INSERT INTO Address (Addr_AddressId, Addr_Address1, Addr_Address2, Addr_Address3, Addr_Address4, Addr_PostCode, addr_PRCityId, addr_PRPublish, Addr_CreatedBy, Addr_CreatedDate, Addr_UpdatedBy, Addr_UpdatedDate, Addr_TimeStamp) 
                               VALUES (@AddressId, @Address1, @Address2, @Address3, @Address4, @PostCode, @PRCityId, @PRPublish, @CreatedBy, @CreatedDate, @UpdatedBy, @UpdatedDate, @TimeStamp)";
        private const string SQL_ADDRESSLINK_INSERT =
                @"INSERT INTO Address_Link (AdLi_AddressLinkId, AdLi_AddressId, AdLi_CompanyID, AdLi_Type, adli_PRDefaultTax, adli_PRDefaultMailing, adLi_CreatedBy, AdLi_CreatedDate, AdLi_UpdatedBy, AdLi_UpdatedDate, AdLi_TimeStamp) 
                                    VALUES (@AddressLinkId, @AddressId, @CompanyID, @Type, @PRDefaultTax, @PRDefaultMailing, @CreatedBy, @CreatedDate, @UpdatedBy, @UpdatedDate, @TimeStamp)";

        private const string SQL_ADDRESS_UPDATE =
            @"UPDATE Address
                 SET Addr_Address1 = @Address1,
                     Addr_Address2 = @Address2,
                     Addr_Address3 = @Address3,
                     Addr_Address4 = @Address4,
                     Addr_PostCode = @PostCode,
                     addr_PRCityId = @PRCityId,
                     Addr_UpdatedBy = @UpdatedBy,
                     Addr_UpdatedDate = @UpdatedDate
                FROM Address_Link 
               WHERE addr_AddressID = adli_AddressID
                 AND adli_Type = @Type
                 AND adli_CompanyID = @CompanyID";

        public void Save(SqlTransaction sqlTrans, string szType)
        {
            if (CityID == 0)
            {
                WriteDebugMessage("Address.Save() - Not saving, CityID=0.");
                return;
            }

            if (Street1.Length > 40)
            {
                Street1 = Street1.Substring(0, 40);
            }

            SqlCommand cmdAddressSave = sqlTrans.Connection.CreateCommand();
            cmdAddressSave.Transaction = sqlTrans;

            int addressID = 0;
            addressID = GetPIKSID("Address", sqlTrans);
            cmdAddressSave.CommandText = SQL_ADDRESS_INSERT;

            cmdAddressSave.Parameters.AddWithValue("AddressID", addressID);
            AddParameter(cmdAddressSave, "Address1", Street1, 40);
            AddParameter(cmdAddressSave, "Address2", Street2, 40);
            AddParameter(cmdAddressSave, "Address3", Street3, 40);
            AddParameter(cmdAddressSave, "Address4", Street4, 40);
            cmdAddressSave.Parameters.AddWithValue("PRCityID", CityID);
            cmdAddressSave.Parameters.AddWithValue("PostCode", Postal);
            
            cmdAddressSave.Parameters.AddWithValue("PRPublish", "Y");
            cmdAddressSave.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
            cmdAddressSave.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
            cmdAddressSave.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdAddressSave.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdAddressSave.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
            cmdAddressSave.ExecuteNonQuery();

            int addressLinkID = GetPIKSID("Address_Link", sqlTrans);
            SqlCommand cmdAddressLinkSave = sqlTrans.Connection.CreateCommand();
            cmdAddressLinkSave.CommandText = SQL_ADDRESSLINK_INSERT;
            cmdAddressLinkSave.Transaction = sqlTrans;
            cmdAddressLinkSave.Parameters.AddWithValue("AddressLinkId", addressLinkID);
            cmdAddressLinkSave.Parameters.AddWithValue("AddressID", addressID);
            cmdAddressLinkSave.Parameters.AddWithValue("CompanyID", CompanyID);
            cmdAddressLinkSave.Parameters.AddWithValue("Type", szType);

            if (Sequence == 1)
            {
                cmdAddressLinkSave.Parameters.AddWithValue("PRDefaultTax", "Y");
                cmdAddressLinkSave.Parameters.AddWithValue("PRDefaultMailing", "Y");
            }
            else
            {
                cmdAddressLinkSave.Parameters.AddWithValue("PRDefaultTax", DBNull.Value);
                cmdAddressLinkSave.Parameters.AddWithValue("PRDefaultMailing", DBNull.Value);
            }

            cmdAddressLinkSave.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
            cmdAddressLinkSave.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
            cmdAddressLinkSave.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdAddressLinkSave.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdAddressLinkSave.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
            cmdAddressLinkSave.ExecuteNonQuery();

        }

        private const string SQL_ADDRESS_DELETE =
            @"DECLARE @Tmp table (ID int);
              INSERT INTO @Tmp SELECT adli_AddressID FROM Address_Link WHERE adli_CompanyID = @CompanyId;
              DELETE FROM Address_Link WHERE adli_CompanyID = @CompanyId;
              DELETE FROM Address WHERE addr_AddressId IN (SELECT ID FROM @Tmp);";

        public static void DeleteAll(SqlTransaction oTran, int companyID)
        {
            SqlCommand sqlCommand = oTran.Connection.CreateCommand();
            sqlCommand.CommandText = SQL_ADDRESS_DELETE;
            sqlCommand.Transaction = oTran;
            sqlCommand.Parameters.AddWithValue("CompanyId", companyID);
            sqlCommand.ExecuteNonQuery();
        }
        
    }
}

