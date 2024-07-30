/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2021

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CompanyRelationshipMgr
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Text;
using TSI.BusinessObjects;
using TSI.DataAccess;
using TSI.Security;
using TSI.Utils;


namespace PRCo.EBB.BusinessObjects
{
	/// <summary>
	/// Data manager for the CompanyRelationship class
	/// </summary>
	[Serializable]
	public class CompanyRelationshipMgr : EBBObjectMgr
	{
		public List<CompanyRelationships> CompanyConnections;

		public const string COMP_REL_TYPES_PRODUCE = "'09','10','12','13','15'";
		public const string COMP_REL_TYPES_TRANSPORTATION = "'10','11','15'";
        public const string COMP_REL_TYPES_LUMBER = "'09','13','15'";

		protected const string CODE_AUDIT_CATEGORY_CONNECTIONLIST = "CN";

		protected const string SQL_GET_BY_TYPE_OLD =
			@"SELECT DISTINCT prcr_RightCompanyID, 
					 comp_PRBookTradestyle, CityStateCountryShort, 
					 dbo.ufn_HasNote({2}, {3}, comp_CompanyID, 'C') As HasNote, comp_PRLastPublishedCSDate, comp_PRListingStatus, 
					 dbo.ufn_GetRelationshipTypeList({0}, comp_CompanyID) As RelationshipTypeList,
					 dbo.ufn_GetRelationshipIDList({0}, comp_CompanyID) as RelationshipIDList
				FROM PRCompanyRelationship WITH (NOLOCK) 
					 INNER JOIN Company WITH (NOLOCK) ON prcr_RightCompanyID = comp_CompanyID 
					 INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID 
			   WHERE prcr_LeftCompanyID = {0} 
				 AND prcr_Active = 'Y' 
				 AND prcr_Deleted IS NULL
				 AND prcr_Type IN ({1}) ";
			//ORDER BY comp_PRBookTradestyle, CityStateCountryShort";


        protected const string SQL_GET_BY_TYPE =
			@"SELECT prcr_RightCompanyID, 
		             comp_PRBookTradestyle, 
                     CityStateCountryShort, 
		             dbo.ufn_HasNote({2}, {3}, comp_CompanyID, 'C') As HasNote, 
		             prcr_LastReportedDate, 
                     comp_PRListingStatus, 
		             dbo.ufn_GetRelationshipTypeList({0}, comp_CompanyID) As RelationshipTypeList,
                     dbo.ufn_GetRelationshipTypeCodeList({0}, comp_CompanyID) As RelationshipTypeCodeList,
		             dbo.ufn_GetRelationshipIDList({0}, comp_CompanyID) as RelationshipIDList,
                     dbo.ufn_HasNewClaimActivity(comp_PRHQID, '{4}') as HasNewClaimActivity, 
                     dbo.ufn_HasMeritoriousClaim(comp_PRHQID, '{5}') as HasMeritoriousClaim,
                     dbo.ufn_HasCertification(comp_PRHQID) as HasCertification,
                     dbo.ufn_HasCertification_Organic(comp_PRHQID) as HasCertification_Organic, 
                     dbo.ufn_HasCertification_FoodSafety(comp_PRHQID) as HasCertification_FoodSafety 
                FROM (SELECT DISTINCT prcr_RightCompanyID, prcr_LastReportedDate
	 	                FROM PRCompanyRelationship WITH (NOLOCK) 
		               WHERE prcr_LeftCompanyID = {0}
	 		             AND prcr_Active = 'Y' 
			             AND prcr_Deleted IS NULL
			             AND prcr_Type IN ({1})
                      ) T1
 		             INNER JOIN vPRBBOSCompanyList_ALL WITH (NOLOCK) ON prcr_RightCompanyID = comp_CompanyID 
               WHERE comp_PRListingStatus NOT IN ('N5', 'N6')
                 AND {6} AND {7}";
        //ORDER BY comp_PRBookTradestyle, CityStateCountryShort";


		public const string COL_PRCR_COMPANY_RELATIONSHIP_ID = "prcr_CompanyRelationshipID";

		#region TSI Framework Generated Code
		/// <summary>
		/// Constructor to initialize data manager
		/// </summary>
		/// <returns></returns>
		public CompanyRelationshipMgr() { }

		/// <summary>
		/// Constructor to initialize data manager
		/// </summary>
		/// <param name="oLogger">Logger</param>
		/// <param name="oUser">Current User</param>
		public CompanyRelationshipMgr(ILogger oLogger,
			IUser oUser)
			: base(oLogger, oUser) { }

		/// <summary>
		/// Constructor to initialize data manager
		/// </summary>
		/// <param name="oConn">DB Connection</param>
		/// <param name="oLogger">Logger</param>
		/// <param name="oUser">Current User</param>
		public CompanyRelationshipMgr(IDbConnection oConn,
			ILogger oLogger,
			IUser oUser)
			: base(oConn, oLogger, oUser) { }

		/// <summary>
		/// Constructor using the Logger, User, and Transaction
		/// of the specified Manager to initialize this manager.
		/// </summary>
		/// <param name="oBizObjMgr">Business Object Manager</param>
		public CompanyRelationshipMgr(BusinessObjectMgr oBizObjMgr) : base(oBizObjMgr) { }

		/// <summary>
		/// The name of the table our business object
		/// is mapped to.
		/// </summary>
		/// <returns>Table Name</returns>
		override public string GetTableName()
		{
			return "PRCompanyRelationship";
		}

		/// <summary>
		/// The name of the business object class.
		/// </summary>
		/// <returns>Business Object Name</returns>
		override public string GetBusinessObjectName()
		{
			return "PRCo.EBB.BusinessObjects.CompanyRelationships";
		}

		/// <summary>
		/// The fields that uniquely identify this object.
		/// </summary>
		/// <returns>IList</returns>
		override public IList GetKeyFields()
		{
			return new String[] { COL_PRCR_COMPANY_RELATIONSHIP_ID };
		}
		#endregion

		/// <summary>
		/// This method will load all relevant Produce company connection lists and store them 
		/// in the Produce Lists.
		/// </summary>
        public void LoadProduceCompany(string sortOrderBy)
		{
			CompanyConnections = GetCompanyRelationships(COMP_REL_TYPES_PRODUCE, sortOrderBy);
		}

		/// <summary>
		/// This method will load all relevant Transportation company connections lists and store
		/// them in the Transportation Lists.
		/// </summary>
        public void LoadTransCompany(string sortOrderBy)
		{
			CompanyConnections = GetCompanyRelationships(COMP_REL_TYPES_TRANSPORTATION, sortOrderBy);
		}

        public void LoadLumberCompany(string sortOrderBy)
		{
			CompanyConnections = GetCompanyRelationships(COMP_REL_TYPES_LUMBER, sortOrderBy);
		}


		/// <summary>
		/// Helper method to retrieve the corresponding connections lists from the database.
		/// </summary>
		/// <param name="szRelationshipTypes">Comma-delimited list of relationship types to retrieve</param>
        /// <param name="sortOrderBy"></param>
		/// <returns>List of matching CompanyRelationships objects</returns>
        public List<CompanyRelationships> GetCompanyRelationships(string szRelationshipTypes, string sortOrderBy)
		{
			// Retrieve the current users BBID
			int iCompanyID = ((IPRWebUser)_oUser).prwu_BBID;

			// Instantiate a new list object
			List<CompanyRelationships> oCompanyRelationships = new List<CompanyRelationships>();

            //Handle spanish globalization of date fields
            CultureInfo m_UsCulture = new CultureInfo("en-us");
            string szDate1 = DateTime.Today.AddDays(0 - Utilities.GetIntConfigValue("ClaimActivityNewThresholdIndicatorDays", 21)).ToString(m_UsCulture);
            string szDate2 = DateTime.Today.AddDays(0 - Utilities.GetIntConfigValue("ClaimActivityMeritoriousThresholdIndicatorDays", 60)).ToString(m_UsCulture);

            // Generate SQL to retrieve the list items for the types specified
            object[] args = {iCompanyID,
                             szRelationshipTypes, 
                             ((IPRWebUser)_oUser).prwu_WebUserID, 
                             ((IPRWebUser)_oUser).prwu_HQID, 
                             szDate1,
                             szDate2,
                             GetLocalSourceCondition(),
                             GetIntlTradeAssociationCondition()};
			string szSQL = string.Format(SQL_GET_BY_TYPE, args);

            if (!string.IsNullOrEmpty(sortOrderBy)) { 
                szSQL += sortOrderBy;
            }


			// Use our own DBAccess object to 
			// avoid conflicts with open readers.
			IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
			oDBAccess.Logger = _oLogger;

			// Retrieve the list data
			IDataReader oReader = oDBAccess.ExecuteReader(szSQL, CommandBehavior.CloseConnection);
			try
			{
				while (oReader.Read())
				{
					// For each record found, create a corresponding CompanyRelationships object
					CompanyRelationships oRelationship = new CompanyRelationships();

					oRelationship.RelatedCompanyID = GetDBAccess().GetInt32(oReader, "prcr_RightCompanyID");
					oRelationship.IsActive = true;
					oRelationship.RelatedCompanyName = GetDBAccess().GetString(oReader, "comp_PRBookTradestyle");
					oRelationship.Location = GetDBAccess().GetString(oReader, "CityStateCountryShort");
					oRelationship.HasNote = TranslateFromCRMBool(GetDBAccess().GetString(oReader, "HasNote"));
					oRelationship.LastPublishedCSDate = GetDBAccess().GetDateTime(oReader, "prcr_LastReportedDate");
					oRelationship.ListingStatus = GetDBAccess().GetString(oReader, "comp_PRListingStatus");
					oRelationship.RelationshipTypeList = GetDBAccess().GetString(oReader, "RelationshipTypeList");
                    oRelationship.RelationshipTypeCodeList = GetDBAccess().GetString(oReader, "RelationshipTypeCodeList");
                    oRelationship.RelationshipIDList = GetDBAccess().GetString(oReader, "RelationshipIDList");
                    oRelationship.ListingStatus = GetDBAccess().GetString(oReader, "comp_PRListingStatus");
                    oRelationship.HasCertification = TranslateFromCRMBool(GetDBAccess().GetString(oReader, "HasCertification"));
                    oRelationship.HasCertification_Organic = TranslateFromCRMBool(GetDBAccess().GetString(oReader, "HasCertification_Organic"));
                    oRelationship.HasCertification_FoodSafety = TranslateFromCRMBool(GetDBAccess().GetString(oReader, "HasCertification_FoodSafety"));

                    // Add it to this list
                    oCompanyRelationships.Add(oRelationship);
				}
			}
			finally
			{
				if (oReader != null)
				{
					oReader.Close();
				}
			}

			return oCompanyRelationships;
		}

		/// <summary>
		/// Helper method to retrieve the corresponding connections lists from the database.
		/// </summary>
		/// <param name="szRelationshipTypes">Comma-delimited list of relationship types to retrieve</param>
		/// <returns>List of matching CompanyRelationships objects</returns>
		public List<CompanyRelationships> GetCompanyRelationships2(string szRelationshipTypes)
		{
			// Retrieve the current users BBID
			int iCompanyID = ((IPRWebUser)_oUser).prwu_BBID;

			// Instantiate a new list object
			List<CompanyRelationships> oCompanyRelationships = new List<CompanyRelationships>();            

			// BBIDs should be unique, even if there are multiple relationship 
			// types reported within each category
			string szCompIDsAlreadyIncluded = "";

			string[] aszRelationshipsTypes = szRelationshipTypes.Split(new char[] { ',' });
			foreach (string szType in aszRelationshipsTypes)
			{
				// Generate SQL to retrieve the list items for the types specified
				object[] args = { iCompanyID, GetStringValueList(szType), ((IPRWebUser)_oUser).prwu_WebUserID, ((IPRWebUser)_oUser).prwu_HQID };
				string szSQL = string.Format(SQL_GET_BY_TYPE, args);

				// If a company has already been encluded in this relationship group
				// it should not be included again                
				if (szCompIDsAlreadyIncluded.Length > 0)
				{
					szSQL += " AND prcr_RightCompanyID NOT IN (" + szCompIDsAlreadyIncluded + ")";
				}

				szSQL += "ORDER BY comp_PRBookTradestyle, CityStateCountryShort";

				// Use our own DBAccess object to 
				// avoid conflicts with open readers.
				IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
				oDBAccess.Logger = _oLogger;

				// Retrieve the list data
				IDataReader oReader = oDBAccess.ExecuteReader(szSQL, CommandBehavior.CloseConnection);
				try
				{
					while (oReader.Read())
					{
						// For each record found, create a corresponding CompanyRelationships object
						CompanyRelationships oRelationship = new CompanyRelationships();

						oRelationship.RelatedCompanyID = GetDBAccess().GetInt32(oReader, "prcr_RightCompanyID");
						oRelationship.IsActive = true;
						oRelationship.Volume = GetDBAccess().GetString(oReader, "prcr_TransactionVolume", "");
						//oRelationship.FrequencyOfDealing = GetDBAccess().GetString(oReader, "prcr_TransactionFrequency", "");
						oRelationship.CompanyRelationshipID = GetDBAccess().GetInt32(oReader, "prcr_CompanyRelationshipID");
						oRelationship.Type = GetDBAccess().GetString(oReader, "prcr_Type", "");
						oRelationship.RelatedCompanyName = GetDBAccess().GetString(oReader, "comp_PRBookTradestyle");
						oRelationship.Location = GetDBAccess().GetString(oReader, "CityStateCountryShort");
						oRelationship.HasNote = TranslateFromCRMBool(GetDBAccess().GetString(oReader, "HasNote"));
						oRelationship.LastPublishedCSDate = GetDBAccess().GetDateTime(oReader, "comp_PRLastPublishedCSDate");
						oRelationship.ListingStatus = GetDBAccess().GetString(oReader, "comp_PRListingStatus");
						oRelationship.RelationshipTypeList = GetDBAccess().GetString(oReader, "RelationshipTypeList");

						// Add it to this list
						oCompanyRelationships.Add(oRelationship);

						// Add this company id to the list already included in this group
						if (szCompIDsAlreadyIncluded.Length > 0)
							szCompIDsAlreadyIncluded += ",";

						szCompIDsAlreadyIncluded += oRelationship.RelatedCompanyID;
					}
				}
				finally
				{
					if (oReader != null)
					{
						oReader.Close();
					}
				}
			}

			CompanyRelationshipComparer oComparer = new CompanyRelationshipComparer();
			oComparer.ComparisonMethod = "RelatedCompanyName:Location";
			oComparer.SortAsc = true;
			oCompanyRelationships.Sort(oComparer);

			return oCompanyRelationships;
		}

		protected const string SQL_UPDATE_CONNLISTDATE = "UPDATE Company SET comp_PRConnectionListDate=GETDATE() WHERE comp_CompanyID=@CompanyID";

		/// <summary>
		/// This method will save the specified Company Relationship object using the usp_AddOnlineTradeReport procedure.
		/// </summary>
		/// <param name="companyRelationship">CompanyRelationships object to save</param>
		public void SaveCompanyRelationships(CompanyRelationships companyRelationship)
		{
			PRWebUser oUser = (PRWebUser)_oUser;
			ArrayList oParameters = new ArrayList();

			oParameters.Add(new ObjectParameter("LeftCompanyId", oUser.prwu_BBID));
			oParameters.Add(new ObjectParameter("RightCompanyId", companyRelationship.RelatedCompanyID));
			oParameters.Add(new ObjectParameter("RelationshipTypes", companyRelationship.Type));

			if (companyRelationship.IsActive)
				oParameters.Add(new ObjectParameter("Action", 0));
			else
				oParameters.Add(new ObjectParameter("Action", 2));

			oParameters.Add(new ObjectParameter("CRMUserID", oUser.prwu_WebUserID));

			GetDBAccess().ExecuteNonQuery("usp_UpdateCompanyRelationship", oParameters, null, CommandType.StoredProcedure);

            UpdateConnectionList(companyRelationship);
		}

		/// <summary>
		/// This method will Save each of the Manual Company Relationships found in the list.  
		/// Manual connections will not be stored in the PRCompanyRelationship table, instead
		/// tasks will be created containing the data as reported by the user.
		/// </summary>
		/// <param name="lManualCompanyRelationships">List of manual CompanyRelationships objects to save</param>
		public void SaveManualCompanyRelationships(List<CompanyRelationships> lManualCompanyRelationships)
		{
			PRWebUser oUser = (PRWebUser)_oUser;

			//GeneralDataMgr _oObjectMgr = new GeneralDataMgr(_oLogger, oUser);

			IDbTransaction oTran = GetObjectDataMgr().BeginTransaction();
			try
			{
				foreach (CompanyRelationships oRelationship in lManualCompanyRelationships)
				{
					// If manual connections are specified, do not save them in the PRCompanyRelationship
					// table.  Instead create a task for the specified user id with a category of 
					// Miscellaneous
					StringBuilder sbMsg = new StringBuilder();

					sbMsg.Append("Customer submit manual connection:" + Environment.NewLine);

					sbMsg.Append("Company Name: " + oRelationship.RelatedCompanyName + Environment.NewLine);
                    sbMsg.Append("Contact Name: " + oRelationship.RelatedContactName + "  -  Please add this person as the TES Contact Name within ATTN lines once they have been added to CRM." + Environment.NewLine);
                    sbMsg.Append("Address 1: " + oRelationship.Addresses.Address1 + Environment.NewLine);
					sbMsg.Append("Address 2: " + oRelationship.Addresses.Address2 + Environment.NewLine);
					sbMsg.Append("Address 3: " + oRelationship.Addresses.Address3 + Environment.NewLine);
					sbMsg.Append("Address 4: " + oRelationship.Addresses.Address4 + Environment.NewLine);
					sbMsg.Append("City: " + oRelationship.Addresses.City + Environment.NewLine);
					sbMsg.Append("Country: " + new GeneralDataMgr().GetCountryName(oRelationship.Addresses.CountryID) + Environment.NewLine);
					sbMsg.Append("State ID: " + new GeneralDataMgr().GetStateAbbr(oRelationship.Addresses.StateID) + Environment.NewLine);
					sbMsg.Append("Postal Code: " + oRelationship.Addresses.PostalCode + Environment.NewLine);
					sbMsg.Append("Phone Area Code: " + oRelationship.Phone.AreaCode + Environment.NewLine);
					sbMsg.Append("Phone: " + oRelationship.Phone.Number + Environment.NewLine);
					sbMsg.Append("Fax Area Code: " + oRelationship.Fax.AreaCode + Environment.NewLine);
					sbMsg.Append("Fax: " + oRelationship.Fax.Number + Environment.NewLine);
					sbMsg.Append("Email: " + oRelationship.Email + Environment.NewLine);
					sbMsg.Append("Connection Type: " + oRelationship.Type + Environment.NewLine);
					sbMsg.Append("Trade Practice: " + oRelationship.TradePracticeName + Environment.NewLine);
					sbMsg.Append("Pay Performance: " + oRelationship.PayPerformanceName + Environment.NewLine);
					sbMsg.Append("High Credit: " + oRelationship.HighCreditName + Environment.NewLine);
					sbMsg.Append("Last Dealt: " + oRelationship.LastDealtName + Environment.NewLine);
					sbMsg.Append("Comments: " + oRelationship.Comments + Environment.NewLine);

					//GeneralDataMgr oObjectMgr = new GeneralDataMgr(_oLogger, _oUser);
					//Defect 6955 - default to JLM user 1051 for task assignment
					GetObjectDataMgr().CreateTask(Utilities.GetIntConfigValue("CompanySubmitManualConnectionTaskUserID", 1051),
											  "Pending",
											  sbMsg.ToString(),
											  Utilities.GetConfigValue("CompanySubmitManualConnectionCategory", ""),
											  Utilities.GetConfigValue("CompanySubmitManualConnectionSubcategory", ""),
                                              oTran);

					// Insert self service audit trail records
					List<string> lCategoryCodes = new List<string>();
					lCategoryCodes.Add(CODE_AUDIT_CATEGORY_CONNECTIONLIST);
                    GetObjectDataMgr().InsertSelfServiceAuditTrail(lCategoryCodes, oTran);
				}
				oTran.Commit();
			}
			catch
			{
				if (oTran != null)
				{
					oTran.Rollback();
				}
				throw;
			}
		}

		/// <summary>
		/// Helper method used to translate the comma-delimited list of relationship type values into
		/// the corresponding sql string list acceptable for the string comparison within an IN clause.
		/// </summary>
		/// <param name="szValueList"></param>
		/// <returns></returns>
		private string GetStringValueList(string szValueList)
		{
			// Add ' for strings used for IN clause
			string[] szValues = szValueList.Split(new char[] { ',' });
			string szStringValueList = "";
			foreach (string szValue in szValues)
			{
				if (szStringValueList.Length > 0)
					szStringValueList += ",";
				szStringValueList += "'" + szValue + "'";
			}

			return szStringValueList;
		}

        private const string SQL_UPDATE_RELATIONSHIPS =
            @"UPDATE PRCompanyRelationship
				SET prcr_TimesReported = ISNULL(prcr_TimesReported, 1) + 1,
					prcr_LastReportedDate = @UpdatedDate,
					prcr_UpdatedBy = @UserID,
					prcr_UpdatedDate = @UpdatedDate,
					prcr_TimeStamp = @UpdatedDate
			  WHERE prcr_CompanyRelationshipId IN ({0})";


        
		public void UpdateCompanyRelationships(string companyRelationshipIDList, bool confirmingList)
		{
            PRWebUser oUser = (PRWebUser)_oUser;
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("UpdatedDate", DateTime.Now));
            oParameters.Add(new ObjectParameter("UserID", oUser.prwu_WebUserID));

            GetDBAccessFullRights().ExecuteNonQuery(string.Format(SQL_UPDATE_RELATIONSHIPS, companyRelationshipIDList), oParameters);                

            oParameters.Clear();
            oParameters.Add(new ObjectParameter("CompanyID", oUser.prwu_BBID));

            UpdateConnectionList(companyRelationshipIDList, confirmingList);
            UpdateCompanyCLDate();
		}


        private const string SQL_UPDATE_RELATIONSHIPS_2 =
            @"UPDATE PRCompanyRelationship
				SET prcr_TimesReported = ISNULL(prcr_TimesReported, 1) + 1,
					prcr_LastReportedDate = @UpdatedDate,
					prcr_UpdatedBy = @UserID,
					prcr_UpdatedDate = @UpdatedDate,
					prcr_TimeStamp = @UpdatedDate
			  WHERE prcr_LeftCompanyID = @CompanyID
                AND prcr_Type IN ('09', '10', '11', '12', '13', '15')
                AND prcr_Active = 'Y' 
			    AND prcr_Deleted IS NULL";

        public void UpdateCompanyRelationships()
        {
            PRWebUser oUser = (PRWebUser)_oUser;
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("UpdatedDate", DateTime.Now));
            oParameters.Add(new ObjectParameter("UserID", oUser.prwu_WebUserID));
            oParameters.Add(new ObjectParameter("CompanyID", oUser.prwu_BBID));

            GetDBAccessFullRights().ExecuteNonQuery(SQL_UPDATE_RELATIONSHIPS_2, oParameters);

            oParameters.Clear();
            oParameters.Add(new ObjectParameter("CompanyID", oUser.prwu_BBID));
        }



        private const string SQL_REMOVE_RELATIONSHIPS =
            @"UPDATE PRCompanyRelationship
				SET prcr_Active = NULL,
					prcr_UpdatedBy = @UserID,
					prcr_UpdatedDate = @UpdatedDate,
					prcr_TimeStamp = @UpdatedDate
			  WHERE prcr_CompanyRelationshipId IN ({0})";



        public void RemoveCompanyRelationships(string companyRelationshipIDList)
        {
            PRWebUser oUser = (PRWebUser)_oUser;
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("UpdatedDate", DateTime.Now));
            oParameters.Add(new ObjectParameter("UserID", oUser.prwu_WebUserID));

            GetDBAccessFullRights().ExecuteNonQuery(string.Format(SQL_REMOVE_RELATIONSHIPS, companyRelationshipIDList), oParameters);

            oParameters.Clear();
            oParameters.Add(new ObjectParameter("CompanyID", oUser.prwu_BBID));

            RemoveConnectionListCompanies(companyRelationshipIDList);
            UpdateCompanyCLDate();
        }

        public void UpdateCompanyCLDate()
        {
            PRWebUser oUser = (PRWebUser)_oUser;
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", oUser.prwu_BBID));

            GetDBAccessFullRights().ExecuteNonQuery(SQL_UPDATE_CONNLISTDATE, oParameters);
        }


        private const string SQL_INSERT_CONNECTION_LIST_COMPANY =
            @"INSERT INTO PRConnectionListCompany (prclc_ConnectionListID, prclc_RelatedCompanyID, prclc_CreatedBy, prclc_CreatedDate, prclc_UpdatedBy, prclc_UpdatedDate, prclc_Timestamp)
                    SELECT DISTINCT @ConnectionListID, prcr_RightCompanyID, @prclc_CreatedBy, @prclc_CreatedDate, @prclc_UpdatedBy, @prclc_UpdatedDate, @prclc_Timestamp
                    FROM PRCompanyRelationship
                    WHERE prcr_CompanyRelationshipID IN ({0})
                    AND prcr_RightCompanyID NOT IN (SELECT prclc_RelatedCompanyID FROM PRConnectionListCompany WHERE prclc_ConnectionListID = @ConnectionListID)";


        public void UpdateConnectionList(string companyRelationshipIDList, bool confirmingList)
        {
            int connectionListID = GetConnectionListID(confirmingList);

            PRWebUser oUser = (PRWebUser)_oUser;
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("ConnectionListID", connectionListID));
            GetObjectDataMgr().AddAuditTrailParametersForInsert(oParameters, "prclc");

            GetDBAccessFullRights().ExecuteNonQuery(string.Format(SQL_INSERT_CONNECTION_LIST_COMPANY, companyRelationshipIDList), oParameters);  
        }


        private const string SQL_REMOVE_CONNECTION_LIST_COMPANY =
            @"DELETE PRConnectionListCompany
                FROM PRCompanyRelationship
               WHERE prclc_ConnectionListID = @ConnectionListID
                 AND prclc_RelatedCompanyID = prcr_RightCompanyID
                 AND prcr_CompanyRelationshipID IN ({0})";

        public void RemoveConnectionListCompanies(string companyRelationshipIDList)
        {
            int connectionListID = GetConnectionListID();

            PRWebUser oUser = (PRWebUser)_oUser;
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("ConnectionListID", connectionListID));
            GetObjectDataMgr().AddAuditTrailParametersForInsert(oParameters, "prclc");

            GetDBAccessFullRights().ExecuteNonQuery(string.Format(SQL_REMOVE_CONNECTION_LIST_COMPANY, companyRelationshipIDList), oParameters);
        }


        private const string SQL_INSERT_CONNECTION_LIST_COMPANY_2 =
                @"INSERT INTO PRConnectionListCompany (prclc_ConnectionListID, prclc_RelatedCompanyID, prclc_CreatedBy, prclc_CreatedDate, prclc_UpdatedBy, prclc_UpdatedDate, prclc_Timestamp)
                     SELECT DISTINCT @ConnectionListID, prcr_RightCompanyID, @prclc_CreatedBy, @prclc_CreatedDate, @prclc_UpdatedBy, @prclc_UpdatedDate, @prclc_Timestamp
                       FROM PRCompanyRelationship
                      WHERE prcr_RightCompanyID IN ({0})
                        AND prcr_RightCompanyID NOT IN (SELECT prclc_RelatedCompanyID FROM PRConnectionListCompany WHERE prclc_ConnectionListID = @ConnectionListID)";

        private const string SQL_DELETE_CONNECTION_LIST_COMPANY =
                @"DELETE FROM PRConnectionListCompany
                     WHERE prclc_ConnectionListID = @ConnectionListID
                       AND prclc_RelatedCompanyID = @RelatedCompanyID
                       AND prclc_RelatedCompanyID NOT IN (
                        SELECT DISTINCT prcr_RightCompanyID
                          FROM PRCompanyRelationship
                         WHERE prcr_LeftCompanyID = @CompanyID
                           AND prcr_Type IN ('09','10','11','12','13','14','15','16')
                           AND prcr_Active = 'Y')";


        public void UpdateConnectionList(CompanyRelationships companyRelationship)
        {
            int connectionListID = GetConnectionListID();

            PRWebUser oUser = (PRWebUser)_oUser;
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("ConnectionListID", connectionListID));

            if (companyRelationship.IsActive)
            {
                GetObjectDataMgr().AddAuditTrailParametersForInsert(oParameters, "prclc");
                GetDBAccessFullRights().ExecuteNonQuery(string.Format(SQL_INSERT_CONNECTION_LIST_COMPANY_2, companyRelationship.RelatedCompanyID.ToString()), oParameters);
            }
            else
            {
                oParameters.Add(new ObjectParameter("RelatedCompanyID", companyRelationship.RelatedCompanyID));
                oParameters.Add(new ObjectParameter("CompanyID", oUser.prwu_BBID));
                GetDBAccessFullRights().ExecuteNonQuery(string.Format(SQL_DELETE_CONNECTION_LIST_COMPANY, companyRelationship.RelatedCompanyID.ToString()), oParameters);
            }
        }


        private const string SQL_SELECT_CONNECTION_LIST =
            @"SELECT prcl2_ConnectionListID FROM PRConnectionList WITH (NOLOCK) WHERE prcl2_Source='BBOS' AND prcl2_ConnectionListDate=@Today AND prcl2_CompanyID=@CompanyID AND prcl2_PersonID=@PersonID";

        private const string SQL_INSERT_CONNECTION_LIST =
            @"INSERT INTO PRConnectionList (prcl2_ConnectionListID, prcl2_CompanyID, prcl2_ConnectionListDate, prcl2_Source, prcl2_PersonID, prcl2_CreatedBy, prcl2_CreatedDate, prcl2_UpdatedBy, prcl2_UpdatedDate, prcl2_Timestamp)
	                                VALUES (@RecordID, @CompanyID, @Today, 'BBOS', @PersonID, @prcl2_CreatedBy, @prcl2_CreatedDate, @prcl2_UpdatedBy, @prcl2_UpdatedDate, @prcl2_Timestamp);";


        private const string SQL_INSERT_CONNECTION_LIST_COMPANY_3 =
            @"INSERT INTO PRConnectionListCompany (prclc_ConnectionListID, prclc_RelatedCompanyID, prclc_CreatedBy, prclc_CreatedDate, prclc_UpdatedBy, prclc_UpdatedDate, prclc_Timestamp)
	          SELECT DISTINCT @RecordID, prcr_RightCompanyID, @prclc_CreatedBy, @prclc_CreatedDate, @prclc_UpdatedBy, @prclc_UpdatedDate, @prclc_Timestamp
	            FROM PRCompanyRelationship WITH (NOLOCK)
	           WHERE prcr_Type IN ('09','10','11','12','13','14','15','16')
	             AND prcr_LeftCompanyId = @CompanyID
	             AND prcr_Active = 'Y'";


        public int GetConnectionListID()
        {
            return GetConnectionListID(false);
        }
        public int GetConnectionListID(bool confirmingList)
        {
            PRWebUser oUser = (PRWebUser)_oUser;
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("Today", DateTime.Today));
            oParameters.Add(new ObjectParameter("CompanyID", oUser.prwu_BBID));
            oParameters.Add(new ObjectParameter("PersonID", oUser.peli_PersonID));

            object result = GetDBAccessFullRights().ExecuteScalar(SQL_SELECT_CONNECTION_LIST, oParameters);
            if ((result != DBNull.Value) &&
                (result != null))
            {
                return (int)result;
            }

            // If we didnt' find a record, then add one
            int recordID = GetObjectDataMgr().GetRecordID("PRConnectionList", null);

            oParameters.Clear();
            oParameters.Add(new ObjectParameter("RecordID", recordID));
            oParameters.Add(new ObjectParameter("CompanyID", oUser.prwu_BBID));
            oParameters.Add(new ObjectParameter("Today", DateTime.Today));
            oParameters.Add(new ObjectParameter("PersonID", oUser.peli_PersonID));
            GetObjectDataMgr().AddAuditTrailParametersForInsert(oParameters, "prcl2");
            GetDBAccessFullRights().ExecuteNonQuery(SQL_INSERT_CONNECTION_LIST, oParameters);

            // Don't default the new CL with the companies on the global list if
            // the user is confirming thier connections.
            if (!confirmingList) { 
                // Now copy the "Global" connection list to this new connection list
                oParameters.Clear();
                oParameters.Add(new ObjectParameter("RecordID", recordID));
                oParameters.Add(new ObjectParameter("CompanyID", oUser.prwu_BBID));
                GetObjectDataMgr().AddAuditTrailParametersForInsert(oParameters, "prclc");
                GetDBAccessFullRights().ExecuteNonQuery(SQL_INSERT_CONNECTION_LIST_COMPANY_3, oParameters);
            }

            return recordID;
        }
        
        private GeneralDataMgr _GeneralDataMgr;
        private GeneralDataMgr GetObjectDataMgr()
        {
            if (_GeneralDataMgr == null)
            {
                _GeneralDataMgr = new GeneralDataMgr(_oLogger, _oUser);

            }
            return _GeneralDataMgr;
        }

        private const string SQL_IS_AFFILIATE =
            @"SELECT 'x' 
               FROM PRCompanyRelationship WITH (NOLOCK) 
              WHERE prcr_Type in (N'27', N'28', N'29') 
                AND ((prcr_LeftCompanyId = @LeftCompanyId AND prcr_RightCompanyId = @RightCompanyId) 
                  OR (prcr_LeftCompanyId = @RightCompanyId AND prcr_RightCompanyId = @LeftCompanyId))";
        public bool IsAffiliated(int leftCompanyID, int rightCompanyID) {

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("LeftCompanyId", leftCompanyID));
            oParameters.Add(new ObjectParameter("RightCompanyId", rightCompanyID));

            object result = GetDBAccessFullRights().ExecuteScalar(SQL_IS_AFFILIATE, oParameters);
            if ((result != DBNull.Value) &&
                (result != null))
            {
                return true;
            }

            return false;
        }
	}
}
