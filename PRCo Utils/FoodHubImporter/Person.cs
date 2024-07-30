using LumenWorks.Framework.IO.Csv;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Text;

namespace FoodHubImporter
{
	public class Person : MeisterMediaBase
	{
		public const string COL_MMWID = "IGRP_NO";
		public const string COL_EMAIL = "Email";
		public const string COL_FIRSTNAME = "FirstName";
		public const string COL_LASTNAME = "LastName";
		public const string COL_TITLE = "Title";
		public const string COL_FUNCTION_TITLE = "Function or Job Title";

		public string MMWID;
		//public string Email;
		public string FirstName;
		public string LastName;
		public string Title = "Other";

		public Phone oPhone;
		public int Sequence;
		public int CompanyID;
		public int PersonID;

		private string GenericTitle;
		private string Role = ",E,";

		public void Load(CsvReader csv)
		{
			//Email = GetEligibleEmail(csv["Market_Email"]);

			//Market_ManagerName	Map first word into First name, then rest into Last name field.
			string[] ManagerName = prepareString(csv["Market_ManagerName"]).Split(' ');
			for(int i=0; i<ManagerName.Length; i++)
			{
				if(i == 0)
					FirstName = ManagerName[i];
				else
					LastName += ManagerName[i] + " ";
			}

			LastName = LastName.Trim();

			AddPhone(csv, "P"); 

			Title = prepareString(csv["FH_ContactTitle"]);
			ProcessTitle();

			GenericTitle = Person.GetGenericTitle(Title);
			//ProcessJobFunction(csv[COL_FUNCTION_TITLE]);

			if(string.IsNullOrEmpty(Title))
			{
				Title = "Other";
			}
		}

		protected const string SQL_PERSON_INSERT =
				 "INSERT INTO Person (Pers_PersonId, Pers_FirstName, Pers_LastName, pers_PRLocalSource, Pers_CreatedBy, Pers_CreatedDate, Pers_UpdatedBy, Pers_UpdatedDate, Pers_Timestamp) VALUES (@Pers_PersonId, @Pers_FirstName,@Pers_LastName, @pers_PRLocalSource, @CreatedBy, @CreatedDate, @UpdatedBy, @UpdatedDate, @Timestamp)";

		protected const string SQL_PERSON_UPDATE =
				@"UPDATE Person
                 SET Pers_FirstName=@Pers_FirstName, 
                     Pers_LastName=@Pers_LastName, 
                     Pers_UpdatedBy=@UpdatedBy, 
                     Pers_UpdatedDate=@UpdatedDate, 
                     Pers_Timestamp=@Timestamp  
               WHERE Pers_PersonId = @Pers_PersonId";

		protected const string SQL_PERSON_LINK_INSERT =
				 @"INSERT INTO Person_Link (PeLi_PersonLinkId, PeLi_PersonId, PeLi_CompanyID, peli_PRRole, peli_PROwnershipRole, peli_PRTitleCode, peli_PRTitle, peli_PREBBPublish, peli_PRBRPublish, peli_PRStatus,
                                   peli_PRSubmitTES, peli_PRSequence, peli_CreatedBy, peli_CreatedDate, peli_UpdatedBy, peli_UpdatedDate, peli_Timestamp) 
                          VALUES (@PeLi_PersonLinkId,@PeLi_PersonId,@PeLi_CompanyID, @peli_PRRole, @peli_PROwnershipRole, @peli_PRTitleCode, @peli_PRTitle, @peli_PREBBPublish, @peli_PRBRPublish, @peli_PRStatus,
                                  @peli_PRSubmitTES, @peli_PRSequence, @CreatedBy, @CreatedDate, @UpdatedBy, @UpdatedDate, @Timestamp)";

		protected const string SQL_PERSON_LINK_UPDATE =
				@"UPDATE Person_Link
                 SET peli_PRRole = @peli_PRRole, 
                     peli_PROwnershipRole = @peli_PROwnershipRole, 
                     peli_PRTitleCode = @peli_PRTitleCode, 
                     peli_PRTitle = @peli_PRTitle, 
                     peli_PREBBPublish = @peli_PREBBPublish, 
                     peli_PRBRPublish = @peli_PRBRPublish, 
                     peli_PRStatus = @peli_PRStatus,
                     peli_PRSequence = @peli_PRSequence, 
                     peli_UpdatedBy=@UpdatedBy, 
                     peli_UpdatedDate=@UpdatedDate, 
                     peli_Timestamp=@Timestamp  
               WHERE peli_CompanyID = @peli_CompanyID
                 AND peli_PersonID = @peli_PersonID";

		public void Save(SqlTransaction sqlTrans, bool newCompany)
		{
			bool newRecord = false;

			if((!newCompany) &&
					(PersonID == 0))
			{
				//PersonID = matchOnName(sqlTrans);
				PersonID = matchOnMMWID(sqlTrans);
			}

			int transactionID = 0;
			SqlCommand cmdSave = sqlTrans.Connection.CreateCommand();
			cmdSave.Transaction = sqlTrans;

			if(PersonID == 0)
			{
				newRecord = true;
				PersonID = GetPIKSID("Person", sqlTrans);
				cmdSave.CommandText = SQL_PERSON_INSERT;
			}
			else
			{
				cmdSave.CommandText = SQL_PERSON_UPDATE;

				StringBuilder sbExplanation = new StringBuilder("Person updated from Local Source import." + Environment.NewLine);
				transactionID = OpenPIKSTransaction(sqlTrans, 0, PersonID, sbExplanation.ToString());
			}

			cmdSave.Parameters.AddWithValue("Pers_PersonId", PersonID);
			//cmdSave.Parameters.AddWithValue("pers_PRMMWID", MMWID);
			cmdSave.Parameters.AddWithValue("Pers_FirstName", FirstName);
			cmdSave.Parameters.AddWithValue("Pers_LastName", LastName);
			cmdSave.Parameters.AddWithValue("pers_PRLocalSource", "Y");
			cmdSave.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
			cmdSave.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
			cmdSave.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
			cmdSave.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
			cmdSave.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
			cmdSave.ExecuteNonQuery();


			if(transactionID == 0)
			{
				StringBuilder sbExplanation = new StringBuilder("Person created from Food Hub import." + Environment.NewLine);
				sbExplanation.Append(String.Format("Person ID: {0}, {1} {2}{3} ", PersonID, FirstName, LastName, Environment.NewLine));
				transactionID = OpenPIKSTransaction(sqlTrans, 0, PersonID, sbExplanation.ToString());
			}

			SqlCommand cmdSaveLink = sqlTrans.Connection.CreateCommand();
			cmdSaveLink.Transaction = sqlTrans;
			int PersonLinkID = 0;
			if(newRecord)
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
			cmdSaveLink.Parameters.AddWithValue("peli_PRRole", Role);
			cmdSaveLink.Parameters.AddWithValue("peli_PROwnershipRole", "RCR");
			cmdSaveLink.Parameters.AddWithValue("peli_PRTitleCode", GenericTitle);
			cmdSaveLink.Parameters.AddWithValue("peli_PRTitle", Title);
			cmdSaveLink.Parameters.AddWithValue("peli_PREBBPublish", "Y");
			cmdSaveLink.Parameters.AddWithValue("peli_PRBRPublish", "Y");
			cmdSaveLink.Parameters.AddWithValue("peli_PRStatus", "1");
			cmdSaveLink.Parameters.AddWithValue("peli_PRSubmitTES", "Y");
			cmdSaveLink.Parameters.AddWithValue("peli_PRUpdateCL", "Y");
			cmdSaveLink.Parameters.AddWithValue("peli_PRSequence", Sequence);
			cmdSaveLink.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
			cmdSaveLink.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
			cmdSaveLink.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
			cmdSaveLink.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
			cmdSaveLink.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
			cmdSaveLink.ExecuteNonQuery();

			Phone.DeleteAll(sqlTrans, 0, PersonID);
			if(oPhone != null)
			{
				oPhone.PersonID = PersonID;
				oPhone.CompanyID = CompanyID;
				oPhone.Save(sqlTrans, true);
			}

			//DeleteEmail(sqlTrans, 0, PersonID);
			//SaveEmail(sqlTrans, CompanyID, PersonID, Email);

			ClosePIKSTransaction(transactionID, sqlTrans);

			if(!newRecord)
			{
				DeletePIKSTransaction(transactionID, sqlTrans);
			}
		}


		public void AddPhone(CsvReader csv, string type)
		{
			if((string.IsNullOrEmpty(csv["Market_Phone"])) ||
					(csv["Market_Phone"].Length < 10))
			{
				return;
			}
			
			oPhone = new Phone();
			oPhone.Load(csv, type);
			oPhone.CompanyID = CompanyID;
			oPhone.PersonID = PersonID;
			oPhone.Sequence = 1;
		}

		private const string SQL_MATCH_MMWID =
					 @"SELECT DISTINCT pers_PersonID
                 FROM Person WITH (NOLOCK)
                      INNER JOIN Person_Link WITH (NOLOCK) ON pers_PersonID = peli_PersonID
                WHERE peli_CompanyID = @CompanyID
                  AND pers_PRMMWID = @MMWID
                  AND pers_PRLocalSource = 'Y'";

		private SqlCommand cmdMatchMMWID = null;
		protected int matchOnMMWID(SqlTransaction sqlTrans)
		{

			if(cmdMatchMMWID == null)
			{
				cmdMatchMMWID = new SqlCommand();
				cmdMatchMMWID.Connection = sqlTrans.Connection;
			}

			cmdMatchMMWID.Transaction = sqlTrans;
			cmdMatchMMWID.CommandText = SQL_MATCH_MMWID;
			cmdMatchMMWID.Parameters.Clear();
			cmdMatchMMWID.Parameters.AddWithValue("CompanyID", CompanyID);
			cmdMatchMMWID.Parameters.AddWithValue("MMWID", MMWID);

			using(SqlDataReader reader = cmdMatchMMWID.ExecuteReader())
			{
				while(reader.Read())
				{
					return reader.GetInt32(0);
				}
			}

			return 0;
		}


		private const string SQL_MATCH_NAME =
	 @"SELECT DISTINCT pers_PersonID
                 FROM Person WITH (NOLOCK)
                      INNER JOIN Person_Link WITH (NOLOCK) ON pers_PersonID = peli_PersonID
                WHERE peli_CompanyID = @CompanyID
                  AND pers_FirstName = @FirstName
                  AND pers_LastName = @LastName
                  AND pers_PRLocalSource = 'Y'";

		private SqlCommand cmdMatchName = null;
		protected int matchOnName(SqlTransaction sqlTrans)
		{

			if(cmdMatchName == null)
			{
				cmdMatchName = new SqlCommand();
				cmdMatchName.Connection = sqlTrans.Connection;
			}

			cmdMatchName.Transaction = sqlTrans;
			cmdMatchName.CommandText = SQL_MATCH_NAME;
			cmdMatchName.Parameters.Clear();
			cmdMatchName.Parameters.AddWithValue("CompanyID", CompanyID);
			cmdMatchName.Parameters.AddWithValue("FirstName", FirstName);
			cmdMatchName.Parameters.AddWithValue("LastName", LastName);

			using(SqlDataReader reader = cmdMatchName.ExecuteReader())
			{
				while(reader.Read())
				{
					return reader.GetInt32(0);
				}
			}

			return 0;
		}

		private const string SQL_GET_BY_COMPANY =
				 @"SELECT peli_PersonID
                 FROM Person_Link WITH (NOLOCK)
                WHERE peli_CompanyID = @CompanyID;";

		private static SqlCommand cmdSelect = null;
		public static List<Person> GetByCompany(SqlTransaction sqlTrans, int companyID)
		{
			if(cmdSelect == null)
			{
				cmdSelect = new SqlCommand();
				cmdSelect.Connection = sqlTrans.Connection;

			}

			cmdSelect.Transaction = sqlTrans;
			cmdSelect.CommandText = SQL_GET_BY_COMPANY;
			cmdSelect.Parameters.Clear();
			cmdSelect.Parameters.AddWithValue("CompanyID", companyID);

			List<Person> persons = new List<Person>();
			using(SqlDataReader reader = cmdSelect.ExecuteReader())
			{
				while(reader.Read())
				{
					Person person = new Person();
					person.PersonID = reader.GetInt32(0);
					person.CompanyID = companyID;
					persons.Add(person);
				}
			}

			return persons;
		}


		private const string SQL_NLC =
				@"UPDATE Person_Link 
                 SET peli_PRStatus = '3', 
                     peli_UpdatedBy=@UpdatedBy, 
                     peli_UpdatedDate=@UpdatedDate, 
                     peli_Timestamp=@Timestamp   
               WHERE peli_PersonID = @PersonID AND peli_CompanyID = @CompanyID";

		private SqlCommand cmdNLC = null;
		public void MarkNLC(SqlTransaction sqlTrans)
		{

			StringBuilder sbExplanation = new StringBuilder("Person marked NLC because not found in Local Source import." + Environment.NewLine);
			int transactionID = OpenPIKSTransaction(sqlTrans, 0, PersonID, sbExplanation.ToString());


			if(cmdNLC == null)
			{
				cmdNLC = new SqlCommand();
				cmdNLC.Connection = sqlTrans.Connection;
			}

			cmdNLC.Transaction = sqlTrans;
			cmdNLC.CommandText = SQL_NLC;
			cmdNLC.Parameters.Clear();
			cmdNLC.Parameters.AddWithValue("CompanyID", CompanyID);
			cmdNLC.Parameters.AddWithValue("PersonID", PersonID);
			cmdNLC.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
			cmdNLC.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
			cmdNLC.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
			cmdNLC.ExecuteNonQuery();

			ClosePIKSTransaction(transactionID, sqlTrans);
		}

		private void ProcessTitle()
		{
			if(string.IsNullOrEmpty(Title))
			{
				return;
			}

			// Some rows have numeric values for the
			// title.
			int dummy = 0;
			if(Int32.TryParse(Title, out dummy))
			{
				Title = "Other";
				return;
			}

			if(Title.ToUpper() == "GM")
			{
				Title = "General Manager";
				return;
			}

			if(Title.ToUpper() == "VP")
			{
				Title = "Vice President";
				return;
			}

			if(Title.ToUpper() == "MGR")
			{
				Title = "Manager";
				return;
			}

			if(Title.ToUpper() == "WIFE")
			{
				Title = null;
				return;
			}


			if((Title.ToUpper() == "PRES") ||
					(Title.ToUpper() == "PRES.") ||
					(Title.ToUpper() == "PRESD.") ||
					(Title.ToUpper() == "PREDISENT") ||
					(Title.ToUpper() == "PRERSIDENT"))
			{
				Title = "President";
				return;
			}


			if((Title.ToUpper() == "OENER") ||
					(Title.ToUpper() == "ONWER") ||
					(Title.ToUpper() == "OWENER") ||
					(Title.ToUpper() == "OWER") ||
					(Title.ToUpper() == "OWMER") ||
					(Title.ToUpper() == "OWMNER") ||
					(Title.ToUpper() == "OWN") ||
					(Title.ToUpper() == "OWNE") ||
					(Title.ToUpper() == "OW"))
			{
				Title = "Owner";
				return;
			}

			if(Title.Length == 1)
			{
				Title = null;
				return;
			}

			if((Title.ToLower() == "dr") ||
					(Title.ToLower() == "dr.") ||
					(Title.ToLower() == "mr") ||
					(Title.ToLower() == "mr.") ||
					(Title.ToLower() == "mrs") ||
					(Title.ToLower() == "mrs.") ||
					(Title.ToLower() == "ms") ||
					(Title.ToLower() == "ms.") ||
					(Title.ToLower() == "n/a") ||
					(Title.ToLower() == "na") ||
					(Title.ToLower() == "no title") ||
					(Title.ToLower() == "none") ||
					(Title.ToLower() == "null"))
			{

				Title = null;
			}

		}

		private static Dictionary<string, string> _GenericTitles = null;
		private static string GetGenericTitle(string title)
		{

			if(string.IsNullOrEmpty(title))
			{
				return "OTHR";
			}

			if(_GenericTitles == null)
			{
				using(SqlConnection sqlConn = new SqlConnection(ConfigurationManager.ConnectionStrings["SQLServer"].ConnectionString))
				{
					_GenericTitles = new Dictionary<string, string>();

					sqlConn.Open();
					SqlCommand command = sqlConn.CreateCommand();
					command.CommandText = "SELECT capt_us, capt_code FROM Custom_Captions WHERE capt_family = 'pers_TitleCode' AND capt_code <> 'Manager'";

					using(SqlDataReader reader = command.ExecuteReader())
					{
						while(reader.Read())
						{
							_GenericTitles.Add(reader.GetString(0).ToUpper().Trim(), reader.GetString(1).Trim());
						}
					}
				}
			}


			if(_GenericTitles.ContainsKey(title.ToUpper()))
			{
				return _GenericTitles[title.ToUpper()];
			}

			return "OTHR";
		}

		//private void ProcessJobFunction(string values)
		//{
		//	if(string.IsNullOrEmpty(values))
		//	{
		//		return;
		//	}

		//	List<string> jobFunctions = values.Split(',').Select(p => p.Trim()).ToList();
		//	jobFunctions = jobFunctions.OrderBy(q => q).ToList();


		//	string value = jobFunctions[0].Trim();


		//	switch(value)
		//	{
		//		case "200":
		//			if(string.IsNullOrEmpty(Title)) Title = "Senior Manager";
		//			if(string.IsNullOrEmpty(GenericTitle)) GenericTitle = "MGR";
		//			Role = ",E,";
		//			return;
		//		case "201":
		//			if(string.IsNullOrEmpty(Title)) Title = "Manager";
		//			if(string.IsNullOrEmpty(GenericTitle)) GenericTitle = "MGR";
		//			Role = ",M,";
		//			return;
		//		case "202":
		//			if(string.IsNullOrEmpty(Title)) Title = "Production Manager";
		//			if(string.IsNullOrEmpty(GenericTitle)) GenericTitle = "OPER";
		//			Role = ",HO,O,";
		//			break;
		//		case "213":
		//			if(string.IsNullOrEmpty(Title)) Title = "Sales & Marketing";
		//			if(string.IsNullOrEmpty(GenericTitle)) GenericTitle = "SALE";
		//			Role = ",S,M,";
		//			return;
		//	}


		//}
	}
}
