using LumenWorks.Framework.IO.Csv;
using PerfectAddressDLLWrapper;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;

namespace FoodHubImporter
{
	public class Address : MeisterMediaBase
	{
        //public const string COL_ADDRESS = "Address";
        //public const string COL_CITY = "City";
        //public const string COL_STATE = "State";
        //public const string COL_ZIP = "Zip";
        //public const string COL_COUNTRY = "Country";

        public string FMID;

		public int Sequence;
		public int CompanyID;
		public int CityID;
		public int StateID;
		public string Type;

		public string Street1;
		public string City;
		public string State;
		public string Zip = String.Empty; //set it so that PerfectAddress can try to fill it
		public string Country;
		public string County;

		public string Street1Match;

		public void LoadMailing(SqlConnection sqlConn, CsvReader csv, List<string> lstErrors)
		{
			//Create Mailing address records.  Publishable, Type=Mailing
			Type = "M"; //Mailing
            FMID = csv["FMID"];

			Street1 = prepareString(csv["Mailing_ST"]);
			City = prepareString(csv["Mailing_City"]);
            Zip = prepareString(csv["Mailing_Zip"]);

			//STATE
			string strFIPS = csv["Mailing_StateFIPS"];
			State = GetStateFromFIPS(strFIPS);

			Country = "UNITED STATES";

			if(Zip.Length == 4)
			{
				Zip = "0" + Zip;
			}

			SetPerfectAddress();
            SetCityID(sqlConn, lstErrors);
		}

		public void LoadPhysical(SqlConnection sqlConn, CsvReader csv, List<string> lstErrors)
		{
			//Create Physical address records.  Publishable, Type=Physical
			Type = "PH"; //Physical
            FMID = csv["FMID"];

            Street1 = prepareString(csv["Location_ST"]);
			City = prepareString(csv["Location_City"]);
            Zip = prepareString(csv["Location_Zip"]);

            //STATE
            string strFIPS = csv["Location_StateFIPS"];
			State = GetStateFromFIPS(strFIPS);

			Country = "UNITED STATES";

			if(Zip.Length == 4)
			{
				Zip = "0" + Zip;
			}

			SetPerfectAddress();
			SetCityID(sqlConn, lstErrors);
		}

		private string GetStateFromFIPS(string strFIPS)
		{
            int intFIPS = Convert.ToInt32(strFIPS);
			switch(intFIPS)
			{
				case  1: return "AL";
				case  2: return "AK";
				case  4: return "AZ";
				case  5: return "AR";
				case  6: return "CA";
				case  8: return "CO";
				case  9: return "CT";
				case 10: return "DE";
				case 11: return "DC";
				case 12: return "FL";
				case 13: return "GA";
				case 15: return "HI";
				case 16: return "ID";
				case 17: return "IL";
				case 18: return "IN";
				case 19: return "IA";
				case 20: return "KS";
				case 21: return "KY";
				case 22: return "LA";
				case 23: return "ME";
				case 24: return "MD";
				case 25: return "MA";
				case 26: return "MI";
				case 27: return "MN";
				case 28: return "MS";
				case 29: return "MO";
				case 30: return "MT";
				case 31: return "NE";
				case 32: return "NV";
				case 33: return "NH";
				case 34: return "NJ";
				case 35: return "NM";
				case 36: return "NY";
				case 37: return "NC";
				case 38: return "ND";
				case 39: return "OH";
				case 40: return "OK";
				case 41: return "OR";
				case 42: return "PA";
				case 44: return "RI";
				case 45: return "SC";
				case 46: return "SD";
				case 47: return "TN";
				case 48: return "TX";
				case 49: return "UT";
				case 50: return "VT";
				case 51: return "VA";
				case 53: return "WA";
				case 54: return "WV";
				case 55: return "WI";
				case 56: return "WY";
				case 60: return "AS";
				case 66: return "GU";
				case 69: return "MP";
				case 72: return "PR";
				case 74: return "UM";
				case 78: return "VI";
			}

			return "";
		}

		private const string SQL_FIND_CITY =
				 @"SELECT prci_CityID, prst_StateID
                        FROM vPRLocation
                       WHERE prci_City = @City 
                         AND prst_Abbreviation = @State";

		private SqlCommand cmdFindCity = null;
		private void SetCityID(SqlConnection sqlConn, List<string> lstErrors)
		{
			if(cmdFindCity == null)
			{
				cmdFindCity = new SqlCommand();
				cmdFindCity.Connection = sqlConn;
				cmdFindCity.CommandText = SQL_FIND_CITY;
			}

			cmdFindCity.Parameters.Clear();
			cmdFindCity.Parameters.AddWithValue("City", City);
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

			if(!found && Zip != "")
			{
				// This mechanism only has US data so use
				// it as a second pass.
				SetCityIDFromPostal(sqlConn, lstErrors);
			}
		}

		/// <summary>
		/// Write error to either console or disk (depending on how it is configured here internally)
		/// </summary>
		/// <param name="strError"></param>
		private static void WriteDataError(string strError, List<string> lstErrors)
		{
			Console.ForegroundColor = ConsoleColor.Red;
			Console.WriteLine(strError);
			lstErrors.Add(strError);
			Console.ForegroundColor = ConsoleColor.Gray;
		}


		private const string SQL_FIND_CITY_FROM_POSTAL =
				 @"SELECT prci_CityID, prst_StateID, prpc_City, prpc_State
                 FROM PRPostalCode
                      INNER JOIN vPRLocation ON prpc_City = prci_City AND prpc_State = prst_Abbreviation
                WHERE prpc_PostalCode = @Postal";

		private SqlCommand cmdFindCityFromPostal = null;
		
		private void SetCityIDFromPostal(SqlConnection sqlConn, List<string> lstErrors)
		{
			if(Zip.Length == 0)
			{
                throw new Exception("Zip cannot be empty");
			}

			if(cmdFindCityFromPostal == null)
			{
				cmdFindCityFromPostal = new SqlCommand();
				cmdFindCityFromPostal.Connection = sqlConn;
				cmdFindCityFromPostal.CommandText = SQL_FIND_CITY_FROM_POSTAL;
			}

			cmdFindCityFromPostal.Parameters.Clear();

			string strZipToSearch = "";

			if((Zip.Length > 5) &&
					(Country == "UNITED STATES"))
				strZipToSearch = Zip.Substring(0, 5);
			else
				strZipToSearch = Zip;

			cmdFindCityFromPostal.Parameters.AddWithValue("Postal", strZipToSearch);

			using(SqlDataReader reader = cmdFindCityFromPostal.ExecuteReader())
			{
				if(reader.Read())
				{
					CityID = reader.GetInt32(0);
					StateID = reader.GetInt32(1);
				}
				else
				{
                    WriteDataError(string.Format("Missing Data: {0}, {1}, Zip {2} for FMID {3}", City, State, Zip, FMID), lstErrors);
				}
			}
		}

		private const string SQL_ADDRESS_INSERT =
						@"INSERT INTO Address (Addr_AddressId, Addr_Address1, Addr_PostCode, addr_PRCityId, addr_PRPublish, Addr_CreatedBy, Addr_CreatedDate, Addr_UpdatedBy, Addr_UpdatedDate, Addr_TimeStamp) 
                               VALUES (@AddressId, @Address1, @PostCode, @PRCityId, @PRPublish, @CreatedBy, @CreatedDate, @UpdatedBy, @UpdatedDate, @TimeStamp)";
		private const string SQL_ADDRESSLINK_INSERT =
						@"INSERT INTO Address_Link (AdLi_AddressLinkId, AdLi_AddressId, AdLi_CompanyID, AdLi_Type, adli_PRDefaultTax, adli_PRDefaultMailing, adLi_CreatedBy, AdLi_CreatedDate, AdLi_UpdatedBy, AdLi_UpdatedDate, AdLi_TimeStamp) 
                                    VALUES (@AddressLinkId, @AddressId, @CompanyID, @Type, @PRDefaultTax, @PRDefaultMailing, @CreatedBy, @CreatedDate, @UpdatedBy, @UpdatedDate, @TimeStamp)";

		private const string SQL_ADDRESS_UPDATE =
				@"UPDATE Address
                 SET Addr_Address1 = @Address1,
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
			if(CityID == 0)
			{
				return;
			}

			if(Street1.Length > 40)
			{
				Street1 = Street1.Substring(0, 40);
			}

			SqlCommand cmdAddressSave = sqlTrans.Connection.CreateCommand();
			cmdAddressSave.Transaction = sqlTrans;

			int addressID = 0;
			bool newCompany = true; // Hold over from previous update logic. 
			if(newCompany)
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
			cmdAddressSave.Parameters.AddWithValue("PRPublish", "Y");		//set as publishable
			cmdAddressSave.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
			cmdAddressSave.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
			cmdAddressSave.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
			cmdAddressSave.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
			cmdAddressSave.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
			cmdAddressSave.ExecuteNonQuery();


			if(newCompany)
			{
				int addressLinkID = GetPIKSID("Address_Link", sqlTrans);
				SqlCommand cmdAddressLinkSave = sqlTrans.Connection.CreateCommand();
				cmdAddressLinkSave.CommandText = SQL_ADDRESSLINK_INSERT;
				cmdAddressLinkSave.Transaction = sqlTrans;
				cmdAddressLinkSave.Parameters.AddWithValue("AddressLinkId", addressLinkID);
				cmdAddressLinkSave.Parameters.AddWithValue("AddressID", addressID);
				cmdAddressLinkSave.Parameters.AddWithValue("CompanyID", CompanyID);
				cmdAddressLinkSave.Parameters.AddWithValue("Type", szType);

				if(Sequence == 1)
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

		private void SetPerfectAddress()
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

				if(nRetCode == PerfectAddressDLL.ErrorCodes.XC_MULT)
				{
					// Can't handle multiple responses for now
					return;
				}
				else if(nRetCode >= 0 && nRetCode < PerfectAddressDLL.ErrorCodes.XC_BADADDR && nRetCode != PerfectAddressDLL.ErrorCodes.XC_NONDEL)
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
			}
			finally
			{
				// make sure we close this object
				if(PA != null)
					PA.Terminate();

                if (City == "McCune")
                    City = "Mc Cune";  //TODO:JMT temp fix as discussed between Jeff and Chris on 4/13/2016
			}
		}
	}
}
