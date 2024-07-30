using System;
using System.Data.SqlClient;
using System.Text.RegularExpressions;
using LumenWorks.Framework.IO.Csv;
using PerfectAddressDLLWrapper;

namespace LocalSourceImporter
{
    public class Address : MeisterMediaBase
    {
        public const string COL_ADDRESS = "Address 1";
        public const string COL_CITY = "City";
        public const string COL_STATE = "State";
        public const string COL_ZIP = "Zip";
        public const string COL_COUNTRY = "Country";

        public int Sequence;
        public int CompanyID;
        public int CityID;
        public int StateID;

        public string Street1;
        public string City;
        public string State;
        public string Zip;
        public string Country;
        public string County;

        public string Street1Match;

        public void Load(SqlConnection sqlConn, CsvReader csv)
        {
            Street1 = prepareString(csv[COL_ADDRESS]);
            City = prepareString(csv[COL_CITY]);
            State = csv[COL_STATE];
            Zip = csv[COL_ZIP];
            Country = prepareString(csv[COL_COUNTRY]);

            if (Zip.Length == 4)
            {
                Zip = "0" + Zip;
            }


            ValidateAddress();


            SetCityID(sqlConn);


            Street1Match = Regex.Replace(Street1, @"[^\w]", string.Empty).ToLower();
        }

        private const string SQL_FIND_CITY =
             @"SELECT prci_CityID, prst_StateID
                        FROM vPRLocation
                       WHERE dbo.ufn_GetLowerAlpha(prci_City) = dbo.ufn_GetLowerAlpha(@City )
                         AND prst_Abbreviation = @State";

        private SqlCommand cmdFindCity = null;
        private void SetCityID(SqlConnection sqlConn)
        {
            if (string.IsNullOrEmpty(City))
            {
                WriteDebugMessage("Address.SetCityID() - Empty City.");
                return;
            }

            if (cmdFindCity == null)
            {
                cmdFindCity = new SqlCommand();
                cmdFindCity.Connection = sqlConn;
                cmdFindCity.CommandText = SQL_FIND_CITY;
            }

            string temp = City;
            if ((State == "QC") &&
                (City.ToLower().StartsWith("st-")))
            {
                temp = City.ToLower().Replace("st-", "Saint-");
            }

            cmdFindCity.Parameters.Clear();
            cmdFindCity.Parameters.AddWithValue("City", temp);
            cmdFindCity.Parameters.AddWithValue("State", State);

            bool found = false;
            using (SqlDataReader reader = cmdFindCity.ExecuteReader())
            {
                if (reader.Read())
                {
                    CityID = reader.GetInt32(0);
                    StateID = reader.GetInt32(1);
                    found = true;
                }
            }

            if (!found)
            {
                // This mechanism only has US data so use
                // it as a second pass.
                SetCityIDFromPostal(sqlConn);
            }
        }

        private const string SQL_FIND_CITY_FROM_POSTAL =
             @"SELECT prci_CityID, prst_StateID, prpc_City, prpc_State
                 FROM PRPostalCode
                      INNER JOIN vPRLocation ON dbo.ufn_GetLowerAlpha(prpc_City) = dbo.ufn_GetLowerAlpha(prci_City) AND prpc_State = prst_Abbreviation
                WHERE prpc_PostalCode = @Postal";

        private SqlCommand cmdFindCityFromPostal = null;
        private void SetCityIDFromPostal(SqlConnection sqlConn)
        {

            if (string.IsNullOrEmpty(Zip))
            {
                WriteDebugMessage("Address.SetCityIDFromPostal() - Empty Zip.");
                return;
            }

            if (cmdFindCityFromPostal == null)
            {
                cmdFindCityFromPostal = new SqlCommand();
                cmdFindCityFromPostal.Connection = sqlConn;
                cmdFindCityFromPostal.CommandText = SQL_FIND_CITY_FROM_POSTAL;
            }

            cmdFindCityFromPostal.Parameters.Clear();

            if ((Zip.Length > 5) &&
                (Country.ToUpper() == "UNITED STATES"))
            {
                cmdFindCityFromPostal.Parameters.AddWithValue("Postal", Zip.Substring(0, 5));
            }
            else
            {
                cmdFindCityFromPostal.Parameters.AddWithValue("Postal", Zip);
            }

            using (SqlDataReader reader = cmdFindCityFromPostal.ExecuteReader())
            {
                if (reader.Read())
                {
                    CityID = reader.GetInt32(0);
                    StateID = reader.GetInt32(1);
                }
            }
        }

        private const string SQL_ADDRESS_INSERT =
                @"INSERT INTO Address (Addr_AddressId, Addr_Address1, Addr_PostCode, addr_PRCityId, addr_PRCounty, addr_PRPublish, Addr_CreatedBy, Addr_CreatedDate, Addr_UpdatedBy, Addr_UpdatedDate, Addr_TimeStamp) 
                               VALUES (@AddressId, @Address1, @PostCode, @PRCityId, @County, @PRPublish, @CreatedBy, @CreatedDate, @UpdatedBy, @UpdatedDate, @TimeStamp)";
        private const string SQL_ADDRESSLINK_INSERT =
                @"INSERT INTO Address_Link (AdLi_AddressLinkId, AdLi_AddressId, AdLi_CompanyID, AdLi_Type, adli_PRDefaultTax, adli_PRDefaultMailing, adLi_CreatedBy, AdLi_CreatedDate, AdLi_UpdatedBy, AdLi_UpdatedDate, AdLi_TimeStamp) 
                                    VALUES (@AddressLinkId, @AddressId, @CompanyID, @Type, @PRDefaultTax, @PRDefaultMailing, @CreatedBy, @CreatedDate, @UpdatedBy, @UpdatedDate, @TimeStamp)";

        private const string SQL_ADDRESS_UPDATE =
            @"UPDATE Address
                 SET Addr_Address1 = @Address1,
                     Addr_PostCode = @PostCode,
                     addr_PRCounty = @County,
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
            bool newCompany = true; // Hold over from previous update logic. 
            if (newCompany)
            {
                addressID = GetPIKSID("Address", sqlTrans);
                cmdAddressSave.CommandText = SQL_ADDRESS_INSERT;
            }
            else
            {
                cmdAddressSave.CommandText = SQL_ADDRESS_UPDATE;
                cmdAddressSave.Parameters.AddWithValue("Type", szType);
                cmdAddressSave.Parameters.AddWithValue("CompanyID", CompanyID);
            }

            cmdAddressSave.Parameters.AddWithValue("AddressID", addressID);
            cmdAddressSave.Parameters.AddWithValue("Address1", Street1);
            cmdAddressSave.Parameters.AddWithValue("PRCityID", CityID);
            cmdAddressSave.Parameters.AddWithValue("PostCode", Zip);
            AddParameter(cmdAddressSave, "County", County);
            cmdAddressSave.Parameters.AddWithValue("PRPublish", "Y");
            cmdAddressSave.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
            cmdAddressSave.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
            cmdAddressSave.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdAddressSave.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdAddressSave.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
            cmdAddressSave.ExecuteNonQuery();


            if (newCompany)
            {
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
        }

        private const string SQL_DELETE_ALL =
                    @"DELETE FROM Address WHERE addr_AddressId IN (SELECT adli_AddressID FROM Address_Link WHERE adli_CompanyID=@CompanyId);";

        private const string SQL_DELETE_ALL_LINK =
                    @"DELETE FROM Address_Link WHERE adli_CompanyID=@CompanyId;";


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

            //sqlCommand.CommandText = SQL_DELETE_ALL_LINK;
            //sqlCommand.ExecuteNonQuery();
        }

        public string ErrMsg = null;

        private void ValidateAddress()
        {
            // try to do some address verification
            PerfectAddressDLL PA = new PerfectAddressDLL();
            try
            {
                // manually initialize this object
                PA.Initialize();

                int nRetCode = PA.CheckAddress("", "", Street1, City + " " + State + ", " + Zip);

                int nCount = PA.GetMatchCount();
                string szStreet = string.Empty;
                string szCity = string.Empty;
                string szState = string.Empty;
                string szZip = string.Empty;
                string szCounty = string.Empty;

                string szFirmHigh = string.Empty;
                string szPRUrb = string.Empty;
                string szDelLine = string.Empty;
                string szLastLine = string.Empty;

                if (nRetCode == PerfectAddressDLL.ErrorCodes.XC_MULT)
                {
                    // Can't handle multiple responses for now
                    return;
                }
                else if (nRetCode >= 0 && nRetCode < PerfectAddressDLL.ErrorCodes.XC_BADADDR && nRetCode != PerfectAddressDLL.ErrorCodes.XC_NONDEL)
                {
                    PA.GetStdAddress(ref szFirmHigh, ref szPRUrb, ref szDelLine, ref szLastLine);
                    Street1 = szDelLine.Trim();
                    PA.GetCity(ref szCity);
                    City = szCity.Trim();
                    PA.GetState(ref szState);
                    State = szState.Trim();
                    PA.GetZip(ref szZip);
                    Zip = szZip.Trim();
                    PA.GetCounty(ref szCounty);
                    County = szCounty.Trim();
                }
                else
                {
                    WriteDebugMessage("Address.ValidateAddress() - No Match.  Return Code = " + nRetCode.ToString());
                }
            }
            catch (Exception pae)
            {
                ErrMsg = pae.Message;
            }
            finally
            {
                // make sure we close this object
                if (PA != null)
                    PA.Terminate();
            }

        }
    }
}
