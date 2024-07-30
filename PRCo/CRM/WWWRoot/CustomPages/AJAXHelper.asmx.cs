/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2009-2021

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: AJAXHelper
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Configuration;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Web.Services;
using AjaxControlToolkit;
using Microsoft.Win32;
using Newtonsoft.Json;

namespace PRCo.BBS.CRM
{
    /// <summary>
    /// Summary description for AJAXHelper
    /// </summary>
    [System.Web.Script.Services.ScriptService()]
    [WebService(Namespace = "http://www.bluebookservices/CRM")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    // To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
    // [System.Web.Script.Services.ScriptService]
    public class AJAXHelper : System.Web.Services.WebService
    {

        protected const string CONN_STRING = "server={0};User ID={1};Password={2};Initial Catalog={3};Application Name={4}";
        protected string _szDBConnection;


        [WebMethod]
        public string HelloWorld()
        {
            return "Hello World";
        }


        [WebMethod]
        public bool DoesCompanyExist(string companyName)
        {
            using (SqlConnection oConn = OpenDBConnection()) 
            {
                SqlCommand sqlCommand = oConn.CreateCommand();
                sqlCommand.CommandText = "SELECT 'x' FROM PRCompanySearch WITH (NOLOCK) WHERE prcse_NameAlphaOnly=dbo.ufn_GetLowerAlpha(@CompanyName)";
                sqlCommand.Parameters.AddWithValue("CompanyName", companyName);
                object oValue = sqlCommand.ExecuteScalar();

                if (oValue == null)
                {
                    return false;
                }

                return true;
            }
        }

        [WebMethod]
        public string GetCountryID(string cityID) {
            using (SqlConnection oConn = OpenDBConnection())
            {
                SqlCommand sqlCommand = oConn.CreateCommand();
                sqlCommand.CommandText = "SELECT prcn_CountryID FROM vPRLocation WHERE prci_CityID=@CityID";
                sqlCommand.Parameters.AddWithValue("CityID", cityID);
                object oValue = sqlCommand.ExecuteScalar();

                if (oValue == null)
                {
                    return "0";
                }

                return Convert.ToString(oValue);
            }
        }

    [WebMethod]
    public string GetPersonEmail(int companyID, int personID)
    {
      using (SqlConnection oConn = OpenDBConnection())
      {

        SqlCommand sqlCommand = oConn.CreateCommand();
        object value = null;
        if (personID > 0)
        {
          sqlCommand.CommandText = string.Format("SELECT emai_EmailAddress FROM vPRPersonEmail WITH (NOLOCK) WHERE elink_RecordID={0} AND emai_CompanyID = {1} AND ELink_Type = 'E' AND emai_PRPreferredInternal='Y'", personID, companyID);
          value = sqlCommand.ExecuteScalar();
          if (value != null)
          {
            return Convert.ToString(value);
          }
        }

        //sqlCommand.CommandText = string.Format("SELECT emai_EmailAddress FROM vCompanyEmail WITH (NOLOCK) WHERE elink_RecordID={0} AND ELink_Type = 'E' AND emai_PRPreferredInternal='Y'", companyID);
        //value = sqlCommand.ExecuteScalar();
        //if (value != null)
        //{
        //  return Convert.ToString(value);
        //}

        return string.Empty;
      }
    }

    [WebMethod]
    public string GetCurrentListing(int companyID)
    {
        using (SqlConnection oConn = OpenDBConnection())
        {
            SqlCommand sqlCommand = oConn.CreateCommand();
            object value = null;
            sqlCommand.CommandText = string.Format("SELECT dbo.ufn_GetListingClassVolCommBlock({0},0)", companyID);

            value = sqlCommand.ExecuteScalar();
            if (value != null)
            {
                return Convert.ToString(value);
            }

            return string.Empty;
        }
    }

        private static readonly Object objGetNewListingLock = new Object();

        /// <summary>
        /// Special code here per discussion between CHW and JMT on 9/28/2020
        /// Take in proposed new commodities, add them to the db as the negative of the companyid,
        /// call the UFN to calculate the ListingClassVolCommBlock, then remove the temporarily added commodities.
        /// This let's use re-use the UFN which has alot of common logic.
        /// </summary>
        /// <returns></returns>
        [WebMethod]
        public string GetNewListing(int companyID, string ccArray)
        {
            if (ccArray == "")
                return string.Empty;

            string[] cc = ccArray.Split(',');
            DateTime dtNow = DateTime.Now;
            int intSequence = 0;

            //Defect 6784 - need locks to prevent incorrect counts if commodity checkboxes clicked in rapid succession
            lock (objGetNewListingLock)
            {
                try
                {
                    using (SqlConnection dbConn = OpenDBConnection())
                    {
                        SqlTransaction dbTran = dbConn.BeginTransaction();
                        try
                        {
                            foreach (string c in cc)
                            {
                                string[] v = c.Split('|');
                                string szCommodityId = v[0];
                                string szAttributeId = v[1];
                                string szGrowingMethodId = v[2];

                                CCAInsert(dbConn, dbTran, -1 * companyID, szCommodityId, szAttributeId, szGrowingMethodId, dtNow, ++intSequence);
                            }

                            dbTran.Commit();
                        }
                        catch
                        {
                            dbTran.Rollback();
                            throw;
                        }

                        SqlCommand sqlCommand = dbConn.CreateCommand();
                        object value = null;
                        sqlCommand.CommandText = string.Format("SELECT dbo.ufn_GetListingClassVolCommBlock({0},0)", -1 * companyID);

                        value = sqlCommand.ExecuteScalar();

                        if (value != null)
                        {
                            return Convert.ToString(value);
                        }

                        return string.Empty;
                    }
                }
                finally
                {
                    using (SqlConnection dbConnCleanup = OpenDBConnection())
                    {
                        SqlCommand sqlCleanup = dbConnCleanup.CreateCommand();
                        sqlCleanup.CommandText = string.Format("DISABLE TRIGGER ALL ON PRCompanyCommodityAttribute; DELETE FROM PRCompanyCommodityAttribute WHERE prcca_CompanyId={0}; ENABLE TRIGGER ALL ON PRCompanyCommodityAttribute;",
                            -1*companyID);
                        object value = sqlCleanup.ExecuteScalar();
                    }
                }
            }
        }

        const string SQL_INSERT_COMPANYCOMMODITYATTRIBUTE = @"DECLARE @NextPRCCAId int
                EXEC usp_GetNextId 'PRCompanyCommodityAttribute', @NextPRCCAId output;
                DISABLE TRIGGER ALL ON PRCompanyCommodityAttribute;

                DECLARE @PublishedDisplayName varchar(5000)
                
                SELECT @PublishedDisplayName = prcm_Abbreviation FROM PRCommodity2 WITH(NOLOCK)
                    WHERE ((@CommodityId='0' AND prcm_CommodityID IS NULL) OR (prcm_CommodityId=@CommodityId)) 
	                AND ((@AttributeId='0' AND prcm_AttributeId IS NULL) OR (prcm_AttributeId = @AttributeId))
	                AND ((@GrowingMethodId='0' AND prcm_GrowingMethodID IS NULL) OR (prcm_GrowingMethodId = @GrowingMethodId))

                INSERT INTO PRCompanyCommodityAttribute
                (prcca_CompanyCommodityAttributeId,
                    prcca_CreatedBy, prcca_createdDate, prcca_UpdatedBy, prcca_UpdatedDate, prcca_TimeStamp,
                    prcca_CompanyId, prcca_CommodityId, prcca_GrowingMethodId, prcca_AttributeId,
                    prcca_Publish, prcca_PublishWithGM, prcca_PublishedDisplay, prcca_Sequence
                )
                VALUES(
                    @NextPRCCAId,
                    @UserId, @UpdatedDate, @UserId, @UpdatedDate, @UpdatedDate,
                    @CompanyID, @CommodityId, @GrowingMethodId, @AttributeId,
                    @Publish, NULL, @PublishedDisplayName, @Sequence
                );

                ENABLE TRIGGER ALL ON PRCompanyCommodityAttribute;";

        private void CCAInsert(SqlConnection dbConn, SqlTransaction dbTran, int companyID, string szCommodityID, string szAttributeID, string szGrowingMethodID, DateTime dtDate, int Sequence)
        {
            SqlCommand sqlCommand = dbConn.CreateCommand();
            sqlCommand.Transaction = dbTran;

            sqlCommand.CommandText = SQL_INSERT_COMPANYCOMMODITYATTRIBUTE;
            sqlCommand.Parameters.AddWithValue("UserId", -1);
            sqlCommand.Parameters.AddWithValue("CompanyID", companyID);
            sqlCommand.Parameters.AddWithValue("CommodityId", szCommodityID);
            sqlCommand.Parameters.AddWithValue("AttributeId", szAttributeID);
            sqlCommand.Parameters.AddWithValue("GrowingMethodId", szGrowingMethodID);
            sqlCommand.Parameters.AddWithValue("UpdatedDate", dtDate);
            sqlCommand.Parameters.AddWithValue("Sequence", Sequence);
            sqlCommand.Parameters.AddWithValue("Publish", "Y");
            object iRows = sqlCommand.ExecuteNonQuery();
        }

        private const string SQL_GET_LAST_REL_TYPE =
    @"SELECT TOP 1 prcr_Type
        FROM PRCompanyRelationship
       WHERE prcr_RightCompanyID=@CompanyID
         AND prcr_Type IN ('09', '10', '12', '13', '15')
      ORDER BY prcr_LastReportedDate DESC";

    [WebMethod]
    public string GetLastRelationshipType(int companyID)
    {
      using (SqlConnection oConn = OpenDBConnection())
      {

        SqlCommand sqlCommand = oConn.CreateCommand();
        object value = null;


        sqlCommand.CommandText = SQL_GET_LAST_REL_TYPE;
        sqlCommand.Parameters.AddWithValue("CompanyID", companyID);
        value = sqlCommand.ExecuteScalar();
        if (value != null)
        {
          return Convert.ToString(value);
        }

        return string.Empty;
      }
    }

    [WebMethod]
        public string GetCustomCaptionValue(string szFamily, string szCode)
        {
            SqlConnection oConn = OpenDBConnection();
            try
            {
                SqlCommand cmdGetCustomCaptionValue = oConn.CreateCommand();
                cmdGetCustomCaptionValue.CommandText = "SELECT dbo.ufn_GetCustomCaptionValue('" + szFamily + "', '" + szCode + "', 'en-us')";
                object oValue = cmdGetCustomCaptionValue.ExecuteScalar();

                if (oValue == null)
                {
                    return szCode;
                }

                return oValue.ToString();
            }
            catch (Exception e)
            {
                return e.Message;
            }
            finally
            {
                CloseDBConnection(oConn);
            }
        }

        protected const string SQL_GET_ATTN_FAX =
            @"SELECT phon_PhoneID As ID, dbo.ufn_FormatPhone(phon_CountryCode, phon_AreaCode, phon_Number, phon_PRExtension) As Value, plink_EntityID  
                FROM vPRPhone WITH (NOLOCK) 
               WHERE plink_Type {1} 
                 AND ((plink_RecordID = @CompanyID AND plink_EntityID = 5)
                     {0})";


        /// <summary>
        /// Returns the fax numbers eligible for the attenion line based on
        /// the knowncategory and context value.
        /// </summary>
        /// <param name="knownCategoryValues"></param>
        /// <param name="category"></param>
        /// <param name="contextKey"></param>
        /// <returns></returns>
        [System.Web.Services.WebMethod]
        [System.Web.Script.Services.ScriptMethod]
        public CascadingDropDownNameValue[] GetAttentionLinePhone(string knownCategoryValues, 
                                                                string category, 
                                                                string contextKey)
        {

            List<CascadingDropDownNameValue> values = new List<CascadingDropDownNameValue>();
            values.Add(new CascadingDropDownNameValue("-- None --", "0"));


            StringDictionary sdKnownValues = CascadingDropDown.ParseKnownCategoryValuesString(knownCategoryValues);
            WriteToLog("knownCategoryValues:" + knownCategoryValues);

            DictionaryEntry[] deKnownValue = new DictionaryEntry[sdKnownValues.Count];
            sdKnownValues.CopyTo(deKnownValue, 0);


            bool personSearch = false;
            string whereClause = string.Empty;
            int companyID = Convert.ToInt32(contextKey);
            int personID = 0;
            if (Int32.TryParse((string)deKnownValue[0].Value, out personID))
            {
                personSearch = true;
                 whereClause = " OR (plink_RecordID = @PersonID AND plink_EntityID = 13 AND  ISNULL(phon_CompanyID, 0) = @CompanyID)";
            }


            SqlConnection oConn = OpenDBConnection();

            try
            {
                string szPhoneTypeClause = null;
                if (category == "Fax")
                {
                    szPhoneTypeClause = " IN ('F', 'PF', 'SF') ";
                }
                else
                {
                    szPhoneTypeClause = " NOT IN ('F', 'SF') ";
                }


                string szSQL = string.Format(SQL_GET_ATTN_FAX, whereClause, szPhoneTypeClause);
                SqlCommand cmdAttnLineFax = oConn.CreateCommand();
                cmdAttnLineFax.Parameters.AddWithValue("CompanyID", companyID);
                if (personSearch)
                {
                    cmdAttnLineFax.Parameters.AddWithValue("PersonID", personID);
                }
               
                cmdAttnLineFax.CommandText = szSQL;
                WriteToLog(szSQL);
                WriteToLog("companyID:" + companyID.ToString());
                WriteToLog("category:" + category);
                WriteToLog("contextKey:" + contextKey);

                string szName = null;
                using (SqlDataReader oReader = cmdAttnLineFax.ExecuteReader())
                {
                    while (oReader.Read())
                    {
                        szName = oReader.GetString(1);
                        if (oReader.GetInt32(2) == 13)
                        {
                            szName += " (p)";
                        }

                        values.Add(new CascadingDropDownNameValue(szName, Convert.ToString(oReader.GetInt32(0))));
                    }
                }
                return values.ToArray();
            }
            catch (Exception e)
            {
                WriteToLog(e.Message);
                throw;
            } 
            finally
            {
                CloseDBConnection(oConn);
            }
        }

        protected const string SQL_GET_ATTN_EMAIL =
            @"SELECT emai_EmailID As ID, RTRIM(emai_EmailAddress) As Value, elink_EntityID 
                FROM vPREmail WITH (NOLOCK) 
               WHERE elink_Type = 'E' 
                 AND ((elink_RecordID = @CompanyID AND elink_EntityID = 5)
                     {0})";

        /// <summary>
        /// Returns the email addresses eligible for the attenion line based on
        /// the knowncategory and context value.
        /// </summary>
        /// <param name="knownCategoryValues"></param>
        /// <param name="category"></param>
        /// <param name="contextKey"></param>
        /// <returns></returns>
        [System.Web.Services.WebMethod]
        [System.Web.Script.Services.ScriptMethod]
        public CascadingDropDownNameValue[] GetAttentionLineEmail(string knownCategoryValues,
                                                                string category,
                                                                string contextKey)
        {

            List<CascadingDropDownNameValue> values = new List<CascadingDropDownNameValue>();
            values.Add(new CascadingDropDownNameValue("-- None --", "0"));

            StringDictionary sdKnownValues = CascadingDropDown.ParseKnownCategoryValuesString(knownCategoryValues);
            WriteToLog("knownCategoryValues:" + knownCategoryValues);

            DictionaryEntry[] deKnownValue = new DictionaryEntry[sdKnownValues.Count];
            sdKnownValues.CopyTo(deKnownValue, 0);

            bool personSearch = false;
            string whereClause = string.Empty;
            int companyID = Convert.ToInt32(contextKey);
            int personID = 0;
            if (Int32.TryParse((string)deKnownValue[0].Value, out personID))
            {
                personSearch = true;
                whereClause = " OR (elink_RecordID = @PersonID AND elink_EntityID = 13 AND  ISNULL(emai_CompanyID, 0) = @CompanyID)";
            }



            SqlConnection oConn = OpenDBConnection();

            try
            {
                string szSQL = string.Format(SQL_GET_ATTN_EMAIL, whereClause);
                SqlCommand cmdAttnLineFax = oConn.CreateCommand();
                cmdAttnLineFax.Parameters.AddWithValue("CompanyID", companyID);
                if (personSearch)
                {
                    cmdAttnLineFax.Parameters.AddWithValue("PersonID", personID);
                }

                cmdAttnLineFax.CommandText = szSQL;
                WriteToLog(szSQL);
                WriteToLog("companyID:" + companyID.ToString());
                WriteToLog("contextKey:" + contextKey);

                string szName = null;
                using (SqlDataReader oReader = cmdAttnLineFax.ExecuteReader())
                {
                    while (oReader.Read())
                    {
                        szName = oReader.GetString(1);
                        if (oReader.GetInt32(2) == 13)
                        {
                            szName += " (p)";
                        }

                        values.Add(new CascadingDropDownNameValue(szName, Convert.ToString(oReader.GetInt32(0))));
                    }
                }
                return values.ToArray();
            }
            catch (Exception e)
            {
                WriteToLog(e.Message);
                throw;
            }
            finally
            {
                CloseDBConnection(oConn);
            }
        }

        private const string SQL_SELECT_ROLES =
          @"SELECT DISTINCT peli_PRRole 
              FROM Person_link WITH (NOLOCK)
             WHERE peli_PRRole is not null and peli_deleted is null and peli_PRStatus != '3' 
               AND peli_CompanyId = @CompanyID";

        [WebMethod]
        public string GetPersonRoles(int companyId, int excludePersonLinkID)
        {
            using (SqlConnection oConn = OpenDBConnection())
            {
                SqlCommand sqlCommand = oConn.CreateCommand();
                sqlCommand.Parameters.AddWithValue("CompanyID", companyId);

                string sql = SQL_SELECT_ROLES;
                if (excludePersonLinkID != 0)
                {
                    sql += " AND peli_PersonLinkId != @PersonLinkID";
                    sqlCommand.Parameters.AddWithValue("PersonLinkID", excludePersonLinkID);
                }

                sqlCommand.CommandText = sql;

                string role = string.Empty; 
                using (SqlDataReader reader = sqlCommand.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        role += reader.GetString(0);
                    }
                }

                return role;
            }
        }

        [WebMethod]
        public string GetOwnershipPct(int companyId)
        {
            using (SqlConnection oConn = OpenDBConnection())
            {
                SqlCommand sqlCommand = oConn.CreateCommand();
                sqlCommand.Parameters.AddWithValue("CompanyID", companyId);
                sqlCommand.CommandText = "SELECT dbo.ufn_GetOwnershipPercentage(" + companyId.ToString() + ") As CurrentPercentag";

                object returnVal = sqlCommand.ExecuteScalar();
                return Convert.ToString(returnVal);
            }
        }

        public class companyownership
        {
            public  float CurrentPercentage { get; set; }
            public string CompanyName { get; set; }
        }

        [WebMethod]
        public string GetCompanyOwnership(int companyId)
        {
            using (SqlConnection oConn = OpenDBConnection())
            {
                SqlCommand sqlCommand = oConn.CreateCommand();
                sqlCommand.Parameters.AddWithValue("CompanyID", companyId);
                sqlCommand.CommandText = "SELECT comp_Name, dbo.ufn_GetOwnershipPercentage(Comp_CompanyId) As CurrentPercentage FROM Company WHERE Comp_CompanyId = @CompanyID";

                var co = new companyownership();

                using (SqlDataReader sdr = sqlCommand.ExecuteReader())
                {
                    if(sdr.Read())
                    {
                        co.CurrentPercentage = (float)Convert.ToDouble(sdr["CurrentPercentage"]);
                        co.CompanyName = sdr["comp_name"].ToString();
                    }
                }
                                
                return JsonConvert.SerializeObject(co);
            }
        }

        public class branchownership
        {
            public int comp_CompanyId_l { get; set; }
            public int comp_PRHQId_l { get; set; }
            public string CompanyName_l { get; set; }
            public int comp_CompanyId_r { get; set; }
            public int comp_PRHQId_r { get; set; }
            public string CompanyName_r { get; set; }
        }

        [WebMethod]
        public string GetBranchOwnership(int leftCompanyId, int rightCompanyId)
        {
            using (SqlConnection oConn = OpenDBConnection())
            {
                var bo = new branchownership();
                SqlCommand sqlCommandLeft = oConn.CreateCommand();
                sqlCommandLeft.Parameters.AddWithValue("CompanyId", leftCompanyId);
                sqlCommandLeft.CommandText = "SELECT comp_CompanyId, comp_PRHQId, comp_Name FROM Company WHERE comp_CompanyId = @CompanyId";

                using (SqlDataReader sdr = sqlCommandLeft.ExecuteReader())
                {
                    if (sdr.Read())
                    {
                        bo.comp_CompanyId_l = (int)sdr["comp_CompanyId"];
                        bo.comp_PRHQId_l = (int)sdr["comp_PRHQId"];
                        bo.CompanyName_l = sdr["comp_Name"].ToString();
                    }
                }

                SqlCommand sqlCommandRight = oConn.CreateCommand();
                sqlCommandRight.Parameters.AddWithValue("CompanyId", rightCompanyId);
                sqlCommandRight.CommandText = "SELECT comp_CompanyId, comp_PRHQId, comp_Name FROM Company WHERE comp_CompanyId = @CompanyId";

                using (SqlDataReader sdr = sqlCommandRight.ExecuteReader())
                {
                    if (sdr.Read())
                    {
                        bo.comp_CompanyId_r = (int)sdr["comp_CompanyId"];
                        bo.comp_PRHQId_r = (int)sdr["comp_PRHQId"];
                        bo.CompanyName_r = sdr["comp_Name"].ToString();
                    }
                }

                return JsonConvert.SerializeObject(bo);
            }
        }

        [WebMethod]
        public bool CheckForDupPersonLink(int companyId, int personID, int personLinkID)
        {
            using (SqlConnection oConn = OpenDBConnection())
            {
                SqlCommand sqlCommand = oConn.CreateCommand();
                sqlCommand.Parameters.AddWithValue("CompanyID", companyId);
                sqlCommand.Parameters.AddWithValue("PersonID", personID);
                sqlCommand.Parameters.AddWithValue("PersonLinkID", personLinkID);
                sqlCommand.CommandText = "SELECT 'x' FROM Person_Link WITH (NOLOCK) WHERE peli_PersonID=@PersonID AND peli_CompanyID=@CompanyID AND peli_PersonLinkID <> @PersonLinkID AND peli_PRStatus='1'";

                object returnVal = sqlCommand.ExecuteScalar();
                if ((returnVal != null) &&
                    (returnVal != DBNull.Value))
                    return true;

                return false;
            }
        }

        /// <summary>
        /// Helper method that returns a new database connection. 
        /// </summary>
        /// <returns></returns>
        virtual protected SqlConnection OpenDBConnection()
        {
            return OpenDBConnection("CRM AJAX Helper");
        }

        /// <summary>
        /// Helper method that returns a new database connection. 
        /// </summary>
        /// <returns></returns>
        virtual protected SqlConnection OpenDBConnection(string szActionName)
        {

            if (_szDBConnection == null)
            {
                string szUserID = null;
                string szPassword = null;
                string szServer = null;
                string szDatabase = null;

                RegistryKey regCRM = Registry.LocalMachine;
                regCRM = regCRM.OpenSubKey(@"SOFTWARE\eware\Config");

                szUserID = (string)regCRM.GetValue("BBSDatabaseUserID");
                szPassword = (string)regCRM.GetValue("BBSDatabasePassword");
                regCRM.Close();

                RegistryKey regCRM2 = Registry.LocalMachine;
                regCRM2 = regCRM2.OpenSubKey(@"SOFTWARE\eware\Config\/CRM");

                szDatabase = (string)regCRM2.GetValue("DefaultDatabase");
                szServer = (string)regCRM2.GetValue("DefaultDatabaseServer");
                regCRM2.Close();

                string[] aArgs = { szServer, szUserID, szPassword, szDatabase, szActionName };
                _szDBConnection = string.Format(CONN_STRING, aArgs);
            }

            SqlConnection dbConn = new SqlConnection(_szDBConnection);
            dbConn.Open();
            return dbConn;
        }

        /// <summary>
        /// Helper method that closes the specified connection.
        /// </summary>
        /// <param name="dbConn"></param>
        virtual protected void CloseDBConnection(SqlConnection dbConn)
        {
            if (dbConn != null)
            {
                dbConn.Close();
            }
        }


        private string _szLogFile = null;
        private void WriteToLog(string szText)
        {
            if (_szLogFile == null)
            {
                _szLogFile = GetConfigValue("LogFile", @"D:\Temp\WWWRoot.txt");
            }
            //File.AppendAllText(_szLogFile, DateTime.Now.ToString("yyyyMMdd_HHmmss") + "|" + szText + Environment.NewLine);
        }

        /// <summary>
        /// Helper method that returns the value for the specified
        /// configuration value name.  If no value is found, then
        /// the specified default is returned.
        /// </summary>
        /// <param name="szValueName"></param>
        /// <param name="szDefault"></param>
        /// <returns></returns>
        protected string GetConfigValue(string szValueName, string szDefault)
        {
            if (string.IsNullOrEmpty(ConfigurationManager.AppSettings[szValueName]))
            {
                return szDefault;
            }

            return ConfigurationManager.AppSettings[szValueName];
        }


        public class pacaInfo
        {
            public string CompanyName { get; set; }
            public int CompanyId { get; set; }
            public string LicenseNumber { get; set; }
            public bool DuplicateExists { get; set; }
            public string RedirectUrl { get; set; }
            public bool IsCurrent { get; set; }
            public string SaveLink { get; set; }
        }

        [WebMethod]
        public string PRImportPACADupCheck(string LicenseNumber, string redirectUrl)
        {
            using (SqlConnection oConn = OpenDBConnection())
            {
                SqlCommand sqlCommand = oConn.CreateCommand();
                sqlCommand.Parameters.AddWithValue("prpa_LicenseNumber", LicenseNumber);
                sqlCommand.CommandText = "SELECT DISTINCT comp_Name, Comp_CompanyId, prpa_LicenseNumber FROM PRPACALicense WITH(NOLOCK) INNER JOIN Company WITH(NOLOCK) ON Comp_CompanyId = prpa_CompanyId WHERE prpa_LicenseNumber = @prpa_LicenseNumber";

                var oPacaDupCheck = new pacaInfo();
                oPacaDupCheck.LicenseNumber = LicenseNumber;
                oPacaDupCheck.DuplicateExists = false;
                oPacaDupCheck.RedirectUrl = redirectUrl;

                using (SqlDataReader sdr = sqlCommand.ExecuteReader())
                {
                    if (sdr.Read())
                    {
                        oPacaDupCheck.CompanyName = sdr["comp_Name"].ToString();
                        oPacaDupCheck.CompanyId = (int)sdr["comp_companyid"];
                        oPacaDupCheck.LicenseNumber = sdr["prpa_LicenseNumber"].ToString();
                        oPacaDupCheck.DuplicateExists = true;
                    }
                }

                return JsonConvert.SerializeObject(oPacaDupCheck);
            }
        }

        [WebMethod]
        public string PRImportPACAActiveCheck(int CompanyID, string redirectUrl, string saveLink)
        {
            using (SqlConnection oConn = OpenDBConnection())
            {
                SqlCommand sqlCommand = oConn.CreateCommand();
                sqlCommand.Parameters.AddWithValue("prpa_CompanyId", CompanyID);
                sqlCommand.CommandText = "SELECT prpa_PACALicenseId, prpa_LicenseNumber FROM PRPacaLicense WITH(NOLOCK) WHERE prpa_CompanyId = @prpa_CompanyId AND prpa_Current='Y'";

                var oPacaActiveCheck = new pacaInfo();
                oPacaActiveCheck.IsCurrent = false;
                oPacaActiveCheck.RedirectUrl = redirectUrl;
                oPacaActiveCheck.SaveLink = saveLink;

                using (SqlDataReader sdr = sqlCommand.ExecuteReader())
                {
                    if (sdr.Read())
                    {
                        oPacaActiveCheck.IsCurrent = true;
                    }
                }

                return JsonConvert.SerializeObject(oPacaActiveCheck);
            }
        }
        
    }
}
