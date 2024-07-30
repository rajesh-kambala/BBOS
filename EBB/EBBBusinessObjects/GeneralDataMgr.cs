/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: GeneralDataMgr
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Text;
using PRCo.EBB.Util;
using TSI.Arch;
using TSI.BusinessObjects;
using TSI.DataAccess;
using TSI.Security;
using TSI.Utils;

namespace PRCo.EBB.BusinessObjects
{

    /// <summary>
    /// Provides the common functionality for data access but isn't tied
    /// to any specific business object class.
    /// </summary>
    [Serializable]
    public class GeneralDataMgr : EBBObjectMgr
    {

        public const int UNKNOWN_CITY_ID = -1;

        public const string INDUSTRY_TYPE_PRODUCE = "P";
        public const string INDUSTRY_TYPE_LUMBER = "L";
        public const string INDUSTRY_TYPE_TRANSPORTATION = "T";
        public const string INDUSTRY_TYPE_SUPPLY = "S";

        public const string INDUSTRY_TYPE_WINEGRAPE = "W";

        protected const string SQL_WEBSERVICEAUDITTRAIL_INSERT = "INSERT INTO PRWebServiceAuditTrail (prwsat2_WebMethodName, prwsat2_WebServiceLicenseKeyID, prwsat2_WebUserID, prwsat2_BBIDRequestCount, prwsat2_CreatedBy, prwsat2_CreatedDate, prwsat2_UpdatedBy, prwsat2_UpdatedDate, prwsat2_TimeStamp) VALUES ({0},{1},{2},{3},{4},{5},{6},{7},{8})";
        protected const string SQL_WEBAUDITTRAIL_INSERT = "INSERT INTO PRWebAuditTrail (prwsat_CreatedBy,prwsat_CreatedDate,prwsat_UpdatedBy,prwsat_UpdatedDate,prwsat_TimeStamp,prwsat_WebUserID,prwsat_CompanyID,prwsat_PageName,prwsat_QueryString,prwsat_AssociatedID,prwsat_AssociatedType,prwsat_Browser,prwsat_BrowserVersion,prwsat_BrowserPlatform,prwsat_IPAddress,prwsat_BrowserUserAgent,prwsat_IsTrial) VALUES ({0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16})";
        protected const string SQL_PRREQUEST_INSERT = "INSERT INTO PRRequest (prreq_WebUserID,prreq_CompanyID,prreq_HQID,prreq_RequestTypeCode,prreq_Price,prreq_Name,prreq_ProductID,prreq_PriceListID,prreq_TriggerPage,prreq_SourceID,prreq_SourceEntity,prreq_CreatedBy,prreq_CreatedDate,prreq_UpdatedBy,prreq_UpdatedDate,prreq_TimeStamp) VALUES ({0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15})";
        protected const string SQL_PRBACKGROUNDCHECKREQUEST_INSERT = "INSERT INTO PRBackgroundCheckRequest (prbcr_RequestingCompanyID,prbcr_RequestingPersonD,prbcr_SubjectCompanyID,prbcr_RequestDateTime,prbcr_StatusCode,prbcr_CreatedBy,prbcr_CreatedDate,prbcr_UpdatedBy,prbcr_UpdatedDate,prbcr_TimeStamp) VALUES ({0},{1},{2},{3},{4},{5},{6},{7},{8},{9})";
        protected const string SQL_PRREQUESTDETAIL_INSERT = "INSERT INTO PRRequestDetail (prrc_RequestID,prrc_AssociatedID,prrc_AssociatedType,prrc_CreatedBy,prrc_CreatedDate,prrc_UpdatedBy,prrc_UpdatedDate,prrc_TimeStamp) " +
                                                            "SELECT  {0}, [value], {2},{3},{4},{5},{6},{7} " +
                                                            "  FROM dbo.Tokenize({1}, ',');";

        protected const string SQL_PRSHIPING_SELECT = "SELECT prship_ShippingRate FROM PRShipping WHERE prship_CountryID={0} AND prship_ProductID={1}";
        protected const string SQL_PRSELFSERVICEAUDITTRAIL_INSERT = "INSERT INTO PRSelfServiceAuditTrail (prssat_WebUserID,prssat_CompanyID,prssat_HQID,prssat_CreatedBy,prssat_CreatedDate,prssat_UpdatedBy,prssat_UpdatedDate,prssat_TimeStamp) VALUES ({0},{1},{2},{3},{4},{5},{6},{7})";
        protected const string SQL_PRSELFSERVICEAUDITTRAILDETAIL_INSERT = "INSERT INTO PRSelfServiceAuditTrailDetail (prssatd_SelfServiceAuditTrailID,prssatd_CategoryCode,prssatd_CreatedBy,prssatd_CreatedDate,prssatd_UpdatedBy,prssatd_UpdatedDate,prssatd_TimeStamp) VALUES ({0},{1},{2},{3},{4},{5},{6})";

        protected const string SQL_PRBUSINESSVALUATION_INSERT = "INSERT INTO PRBusinessValuation(prbv_CompanyId, prbv_PersonId, prbv_StatusCode, prbv_Guid, prbv_CreatedBy, prbv_CreatedDate, prbv_UpdatedBy, prbv_UpdatedDate, prbv_TimeStamp) VALUES ({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8})";
        protected const string SQL_BUSINESS_VALUATION_UPDATE_STATUS_CODE = @"UPDATE PRBusinessValuation SET prbv_StatusCode=@prbv_StatusCode WHERE prbv_BusinessValuationID=@prbv_BusinessValuationID";

        /// <summary>
        /// Constructor
        /// </summary>
        public GeneralDataMgr() { }

        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="oLogger">Logger</param>
        /// <param name="oUser">Current User</param>
        public GeneralDataMgr(ILogger oLogger,
            IUser oUser) : base(oLogger, oUser) { }

        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="oConn">DB Connection</param>
        /// <param name="oLogger">Logger</param>
        /// <param name="oUser">Current User</param>
        public GeneralDataMgr(IDbConnection oConn,
            ILogger oLogger,
            IUser oUser) : base(oConn, oLogger, oUser)
        {
            CurrentDBConnection = oConn;
        }

        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="oTran">Transaction</param>
        /// <param name="oLogger">Logger</param>
        /// <param name="oUser">Current User</param>
        public GeneralDataMgr(IDbTransaction oTran,
            ILogger oLogger,
            IUser oUser) : base(oTran, oLogger, oUser) { }

        /// <summary>
        /// Constructor using the Logger, User, and Transaction
        /// of the specified Manager to initialize this manager.
        /// </summary>
        /// <param name="oBizObjMgr">Business Object Manager</param>
        public GeneralDataMgr(BusinessObjectMgr oBizObjMgr) : base(oBizObjMgr) { }


        /// <summary>
        /// Creates the PRRequest and PRRequestDetail records for the specified
        /// type and IDs.
        /// </summary>
        /// <param name="szRequestType"></param>
        /// <param name="szIDList"></param>
        /// <param name="szTriggerPage"></param>
        /// <param name="oTran"></param>
        public int CreateRequest(string szRequestType,
                                  string szIDList,
                                  string szTriggerPage,
                                  IDbTransaction oTran)
        {
            return CreateRequest(szRequestType, 0M, null, szIDList, szTriggerPage, null, null, oTran);
        }

        /// <summary>
        /// Creates the PRRequest and PRRequestDetail records for the specified
        /// type and IDs.
        /// </summary>
        /// <param name="szRequestType"></param>
        /// <param name="dPrice"></param>
        /// <param name="szIDList"></param>
        /// <param name="iProductID"></param>
        /// <param name="iPriceListID"></param>
        /// <param name="szTriggerPage"></param>
        /// <param name="szSourceEntityType"></param>
        /// <param name="szSourceID"></param>
        /// <param name="oTran"></param>
        public int CreateRequest(string szRequestType,
                                  Decimal dPrice,
                                  string szIDList,
                                  int iProductID,
                                  int iPriceListID,
                                  string szTriggerPage,
                                  string szSourceID,
                                  string szSourceEntityType,
                                  IDbTransaction oTran)
        {

            return CreateRequest(szRequestType, dPrice, null, szIDList, iProductID, iPriceListID, szTriggerPage, szSourceID, szSourceEntityType, oTran);
        }

        /// <summary>
        /// Creates the PRRequest and PRRequestDetail records for the specified
        /// type and IDs.
        /// </summary>
        /// <param name="szRequestType"></param>
        /// <param name="dPrice"></param>
        /// <param name="szName"></param>
        /// <param name="szIDList"></param>
        /// <param name="szTriggerPage"></param>
        /// <param name="szSourceEntityType"></param>
        /// <param name="szSourceID"></param>
        /// <param name="oTran"></param>
        public int CreateRequest(string szRequestType,
                                  decimal dPrice,
                                  string szName,
                                  string szIDList,
                                  string szTriggerPage,
                                  string szSourceID,
                                  string szSourceEntityType,
                                  IDbTransaction oTran)
        {
            return CreateRequest(szRequestType, dPrice, szName, szIDList, 0, 0, szTriggerPage, szSourceID, szSourceEntityType, oTran);
        }

        /// <summary>
        /// Creates the PRRequest and PRRequestDetail records for the specified
        /// type and IDs.
        /// <remarks>
        /// If we ever switch this back to use the Sage ID mechanism, just loop
        /// through the szIDList and insert a record for each one.
        /// </remarks>
        /// </summary>
        /// <param name="szRequestType"></param>
        /// <param name="dPrice"></param>
        /// <param name="szName"></param>
        /// <param name="szIDList"></param>
        /// <param name="szTriggerPage"></param>
        /// <param name="iProductID"></param>
        /// <param name="iPriceListID"></param>
        /// <param name="szSourceEntityType"></param>
        /// <param name="szSourceID"></param>
        /// <param name="oTran"></param>
        public int CreateRequest(string szRequestType,
                                  decimal dPrice,
                                  string szName,
                                  string szIDList,
                                  int iProductID,
                                  int iPriceListID,
                                  string szTriggerPage,
                                  string szSourceID,
                                  string szSourceEntityType,
                                  IDbTransaction oTran)
        {

            //int iRequestID = GetRecordID("PRRequest", oTran);

            IPRWebUser oUser = (IPRWebUser)_oUser;


            ArrayList oParameters = new ArrayList();
            //oParameters.Add(new ObjectParameter("prreq_RequestID", iRequestID));
            oParameters.Add(new ObjectParameter("prreq_WebUserID", oUser.UserID));
            oParameters.Add(new ObjectParameter("prreq_CompanyID", oUser.prwu_BBID));
            oParameters.Add(new ObjectParameter("prreq_HQID", oUser.prwu_HQID));
            oParameters.Add(new ObjectParameter("prreq_RequestTypeCode", szRequestType));
            oParameters.Add(new ObjectParameter("prreq_Price", dPrice));
            oParameters.Add(new ObjectParameter("prreq_Name", szName));
            oParameters.Add(new ObjectParameter("prreq_ProductID", iProductID));
            oParameters.Add(new ObjectParameter("prreq_PriceListID", iPriceListID));
            oParameters.Add(new ObjectParameter("prreq_TriggerPage", szTriggerPage));
            oParameters.Add(new ObjectParameter("prreq_SourceID", szSourceID));
            oParameters.Add(new ObjectParameter("prreq_SourceEntity", szSourceEntityType));
            AddAuditTrailParametersForInsert(oParameters, "prreq");

            int iRequestID = ExecuteIdentityInsert("PRRequest", SQL_PRREQUEST_INSERT, oParameters, oTran);

            // Only two of our request types are not related to
            // companies.
            string szDetailType = "C";
            if ((szRequestType == "BP") || (szRequestType == "BPO"))
            {
                szDetailType = "PA";
            }

            if ((szRequestType == "PR") || (szRequestType == "PE"))
            {
                szDetailType = "P";
            }

            oParameters = new ArrayList();
            //oParameters.Add(new ObjectParameter("prrc_RequestDetailID", GetRecordID("PRRequestDetail", oTran)));
            oParameters.Add(new ObjectParameter("prrc_RequestID", iRequestID));
            oParameters.Add(new ObjectParameter("CompanyIDs", szIDList));
            oParameters.Add(new ObjectParameter("prrc_AssociatedType", szDetailType));
            AddAuditTrailParametersForInsert(oParameters, "prrc");
            ExecuteIdentityInsert("PRRequestDetail", SQL_PRREQUESTDETAIL_INSERT, oParameters, oTran);

            return iRequestID;
        }

        /// <summary>
        /// Creates the PRBackgroundCheckRequest record for the specified parameters
        /// <remarks>
        /// </remarks>
        /// </summary>
        public int CreateBackgroundCheckRequest(string szSubjectCompanyID, string szStatusCode, IDbTransaction oTran)
        {
            return CreateBackgroundCheckRequest(Convert.ToInt32(szSubjectCompanyID), szStatusCode, oTran);
        }
        public int CreateBackgroundCheckRequest(int iSubjectCompanyID,
                                                string szStatusCode,
                                                IDbTransaction oTran)
        {
            IPRWebUser oUser = (IPRWebUser)_oUser;

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prbcr_RequestingCompanyID", oUser.prwu_BBID));
            oParameters.Add(new ObjectParameter("prbcr_RequestingPersonD", oUser.peli_PersonID));
            oParameters.Add(new ObjectParameter("prbcr_SubjectCompanyID", iSubjectCompanyID));
            oParameters.Add(new ObjectParameter("prbcr_RequestDateTime", DateTime.Now));
            oParameters.Add(new ObjectParameter("prbcr_StatusCode", szStatusCode));

            AddAuditTrailParametersForInsert(oParameters, "prbcr");

            int iRequestID = ExecuteIdentityInsert("PRBackgroundCheckRequest", SQL_PRBACKGROUNDCHECKREQUEST_INSERT, oParameters, oTran);
            return iRequestID;
        }

        /// <summary>
        /// Creates the PRBusinessValuation record for the specified parameters
        /// <remarks>
        /// </remarks>
        /// </summary>
        public int CreateBusinessValuation(string szStatusCode, IDbTransaction oTran)
        {
            IPRWebUser oUser = (IPRWebUser)_oUser;

            // Create the PRBusinessValuation record
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prbv_CompanyID", oUser.prwu_BBID));
            oParameters.Add(new ObjectParameter("prbv_PersonID", oUser.peli_PersonID));
            oParameters.Add(new ObjectParameter("prbv_StatusCode", szStatusCode));
            oParameters.Add(new ObjectParameter("prbv_Guid", Guid.NewGuid().ToString()));

            AddAuditTrailParametersForInsert(oParameters, "prbv");

            int iRequestID = ExecuteIdentityInsert("PRBusinessValuation", SQL_PRBUSINESSVALUATION_INSERT, oParameters, oTran);
            return iRequestID;
        }

        public void UpdateBusinessValuationStatus(int prbv_BusinessValuationID, string prbv_StatusCode)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prbv_BusinessValuationID", prbv_BusinessValuationID));
            oParameters.Add(new ObjectParameter("prbv_StatusCode", prbv_StatusCode));

            GetDBAccess().ExecuteNonQuery(SQL_BUSINESS_VALUATION_UPDATE_STATUS_CODE, oParameters);
        }

        protected const string SQL_TAX_RATE_SELECT =
            @"SELECT TaxClass, TaxRate
				FROM MAS_SYSTEM.dbo.SY_SalesTaxCodeDetail
					 INNER JOIN CRM.dbo.PRTaxRate ON TaxCode = prtax_TaxCode ";

        /// <summary>
        /// Returns the tax rate for the specified geographic area. Implements a multi-
        /// pass algorithym.  If multiple rates are found on any given pass the highest
        /// rate is returned.  If no tax rate is found, zero is returned.
        /// </summary>
        /// <param name="szCity"></param>
        /// <param name="szCounty"></param>
        /// <param name="iStateID"></param>
        /// <param name="szPostalCode"></param>
        /// <returns></returns>
        public Dictionary<string, decimal> GetTaxRate(string szCity, string szCounty, int iStateID, string szPostalCode)
        {

            string szStateAbbr = GetStateAbbr(iStateID);
            string taxStates = Utilities.GetConfigValue("TaxRateStates", "'IL', 'CA', 'CT', 'NY', 'PA', 'FL', 'MA', 'MN', 'ND'");

            if ((string.IsNullOrEmpty(szStateAbbr)) ||
                (!taxStates.Contains(szStateAbbr)))
            {
                return null;
            }

            string szSQL = null;
            ArrayList oParameters = new ArrayList();


            Dictionary<string, decimal> taxRates = new Dictionary<string, decimal>();

            // If the user is in Illinios, then just query for that
            // tax record.
            if (iStateID == 14)
            {
                oParameters.Add(new ObjectParameter("prtax_PostalCode", Utilities.GetConfigValue("ILTaxPostalCode", "60188")));
                szSQL = SQL_TAX_RATE_SELECT + " WHERE prtax_PostalCode={0}";

                GetTaxRates(szSQL, oParameters, taxRates);
            }
            else
            {

                // PASS 1: City, County, & Postal Code
                oParameters.Add(new ObjectParameter("prtax_City", szCity));
                oParameters.Add(new ObjectParameter("prtax_County", szCounty));
                oParameters.Add(new ObjectParameter("prtax_PostalCode", szPostalCode));
                szSQL = SQL_TAX_RATE_SELECT + " WHERE prtax_City={0} AND prtax_County={1} AND prtax_PostalCode={2}";
                GetTaxRates(szSQL, oParameters, taxRates);

                if (taxRates.Count == 0)
                {
                    // PASS 2:  County, & Postal Code
                    oParameters.Clear();
                    oParameters.Add(new ObjectParameter("prtax_County", szCounty));
                    oParameters.Add(new ObjectParameter("prtax_PostalCode", szPostalCode));
                    szSQL = SQL_TAX_RATE_SELECT + " WHERE prtax_County={0} AND prtax_PostalCode={1}";
                    GetTaxRates(szSQL, oParameters, taxRates);

                    if (taxRates.Count == 0)
                    {

                        // PASS 3:  State, & Postal Code
                        oParameters.Clear();
                        oParameters.Add(new ObjectParameter("prtax_State", szStateAbbr));
                        oParameters.Add(new ObjectParameter("prtax_PostalCode", szPostalCode));
                        szSQL = SQL_TAX_RATE_SELECT + " WHERE prtax_State={0} AND prtax_PostalCode={1}";
                        GetTaxRates(szSQL, oParameters, taxRates);
                    }
                }
            }

            // If nothing was found,
            // return zero.
            if (taxRates.Count == 0)
            {
                return null;
            }

            return taxRates;
        }


        private void GetTaxRates(string sql, ArrayList parameters, Dictionary<string, decimal> taxRates)
        {
            using (IDataReader reader = GetDBAccess().ExecuteReader(FormatSQL(sql, parameters),
                                                                    parameters))
            {
                while (reader.Read())
                {
                    if (!taxRates.ContainsKey(reader.GetString(0)))
                    {
                        taxRates.Add(reader.GetString(0), reader.GetDecimal(1));
                    }
                }
            }
        }

        protected const string SQL_SELECT_COUNTY =
                  @"SELECT DISTINCT prtax_County
                      FROM PRTaxRate WITH (NOLOCK)
                     WHERE prtax_City = @City
                       AND prtax_State = @State
                       AND prtax_PostalCode = @PostalCode";

        public List<string> GetCounty(string szCity, int iStateID, string szPostalCode)
        {
            string szStateAbbr = GetStateAbbr(iStateID);
            string taxStates = Utilities.GetConfigValue("TaxRateStates", "'IL', 'CA', 'CT', 'NY', 'PA', 'FL', 'MA', 'MN', 'ND'");
            List<string> counties = new List<string>();

            if ((string.IsNullOrEmpty(szStateAbbr)) ||
                (!taxStates.Contains(szStateAbbr)))
            {
                return counties;
            }

            ArrayList parameters = new ArrayList();
            parameters.Add(new ObjectParameter("City", szCity));
            parameters.Add(new ObjectParameter("State", szStateAbbr));
            parameters.Add(new ObjectParameter("PostalCode", szPostalCode));


            using (IDataReader reader = GetDBAccess().ExecuteReader(SQL_SELECT_COUNTY,
                                                                    parameters))
            {
                while (reader.Read())
                {
                    counties.Add(reader.GetString(0));
                }
            }

            return counties;
        }



        /// <summary>
        /// Returns the shipping rate for the specified product to the
        /// specified country.
        /// </summary>
        /// <param name="iCountryID"></param>
        /// <param name="iProductID"></param>
        /// <returns></returns>
        public decimal GetShippingRate(int iCountryID, int iProductID)
        {

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prship_CountryID", iCountryID));
            oParameters.Add(new ObjectParameter("prship_ProductID", iProductID));

            string szSQL = FormatSQL(SQL_PRSHIPING_SELECT, oParameters);
            object oValue = GetDBAccess().ExecuteScalar(szSQL, oParameters);
            if (oValue == DBNull.Value)
            {
                return 0M;
            }
            else
            {
                return Convert.ToDecimal(oValue);
            }
        }


        /// <summary>
        /// Inserts the PRSelfServiceAuditTrail records for the specified
        /// category codes.
        /// </summary>
        /// <param name="alCategoryCodes"></param>
        /// <param name="oTran"></param>
        public void InsertSelfServiceAuditTrail(List<string> alCategoryCodes,
                                                IDbTransaction oTran)
        {

            if (!Utilities.GetBoolConfigValue("SelfServiceAuditTrailEnabled", true))
            {
                return;
            }

            IPRWebUser oUser = (IPRWebUser)_oUser;
            //int iSelfServiceATID = GetRecordID("PRSelfServiceAuditTrail", oTran);

            ArrayList oParameters = new ArrayList();
            //oParameters.Add(new ObjectParameter("prssat_SelfServiceAuditTrailID", iSelfServiceATID));
            oParameters.Add(new ObjectParameter("prssat_WebUserID", oUser.UserID));
            oParameters.Add(new ObjectParameter("prssat_CompanyID", oUser.prwu_BBID));
            oParameters.Add(new ObjectParameter("prssat_HQID", oUser.prwu_HQID));
            AddAuditTrailParametersForInsert(oParameters, "prssat");
            int iSelfServiceATID = ExecuteIdentityInsert("PRSelfServiceAuditTrail", SQL_PRSELFSERVICEAUDITTRAIL_INSERT, oParameters, oTran);


            foreach (string szCategoryCode in alCategoryCodes)
            {
                oParameters = new ArrayList();
                //oParameters.Add(new ObjectParameter("prssatd_SelfServiceAuditTrailDetailID", GetRecordID("PRSelfServiceAuditTrailDetail", oTran)));
                oParameters.Add(new ObjectParameter("prssatd_SelfServiceAuditTrailID", iSelfServiceATID));
                oParameters.Add(new ObjectParameter("prssatd_CategoryCode", szCategoryCode));
                AddAuditTrailParametersForInsert(oParameters, "prssatd");
                ExecuteIdentityInsert("PRSelfServiceAuditTrailDetail", SQL_PRSELFSERVICEAUDITTRAILDETAIL_INSERT, oParameters, oTran);
            }
        }



        /// <summary>
        /// Inserts the PRWebAuditTrail record for the 
        /// current page and user.
        /// </summary>
        public void InsertWebAuditTrail(string szPageName,
                                        string szQueryString,
                                        string szAssociatedID,
                                        string szAssociatedType,
                                        string szBrowser,
                                        string szBrowserVersion,
                                        string szBrowserPlatorm,
                                        string szIPAddress,
                                        string szUserAgent)
        {

            if (!Utilities.GetBoolConfigValue("WebAuditTrailEnabled", true))
            {
                return;
            }

            IPRWebUser oUser = (IPRWebUser)_oUser;

            ArrayList oParameters = new ArrayList();
            AddAuditTrailParametersForInsert(oParameters, "prwsat");
            oParameters.Add(new ObjectParameter("prwsat_WebUserID", oUser.UserID));
            oParameters.Add(new ObjectParameter("prwsat_CompanyID", oUser.prwu_BBID));
            oParameters.Add(new ObjectParameter("prwsat_PageName", szPageName));
            oParameters.Add(new ObjectParameter("prwsat_QueryString", szQueryString));
            oParameters.Add(new ObjectParameter("prwsat_AssociatedID", szAssociatedID));
            oParameters.Add(new ObjectParameter("prwsat_AssociatedType", szAssociatedType));
            oParameters.Add(new ObjectParameter("prwsat_Browser", szBrowser));
            oParameters.Add(new ObjectParameter("prwsat_BrowserVersion", szBrowserVersion));
            oParameters.Add(new ObjectParameter("prwsat_BrowserPlatform", szBrowserPlatorm));
            oParameters.Add(new ObjectParameter("prwsat_IPAddress", szIPAddress));
            oParameters.Add(new ObjectParameter("prwsat_BrowserUserAgent", szUserAgent));

            if (oUser.IsTrialPeriodActive())
            {
                oParameters.Add(new ObjectParameter("prwsat_IsTrial", GetPIKSCoreBool(true)));
            }
            else
            {
                oParameters.Add(new ObjectParameter("prwsat_IsTrial", DBNull.Value));
            }

            ExecuteIdentityInsert("PRWebAuditTrail", SQL_WEBAUDITTRAIL_INSERT, oParameters);
        }


        /// <summary>
        /// Inserts the PRWebServiceAuditTrail record for the 
        /// current web request and user.
        /// </summary>
        public void InsertWebServiceAuditTrail(string szRequestName,
                                               int iLicenseKeyID,
                                               int iBBIDRequestCount)
        {

            if (!Utilities.GetBoolConfigValue("WebServiceAuditTrailEnabled", true))
            {
                return;
            }

            IPRWebUser oUser = (IPRWebUser)_oUser;

            ArrayList oParameters = new ArrayList();
            //oParameters.Add(new ObjectParameter("prwsat2_WebServiceAuditTrailID", GetRecordID("PRWebAuditTrail")));
            oParameters.Add(new ObjectParameter("prwsat2_WebMethodName", szRequestName));
            oParameters.Add(new ObjectParameter("prwsat2_WebServiceLicenseKeyID", iLicenseKeyID));

            if (oUser == null)
            {
                oParameters.Add(new ObjectParameter("prwsat2_WebUserID", null));
            }
            else
            {
                oParameters.Add(new ObjectParameter("prwsat2_WebUserID", oUser.UserID));
            }


            oParameters.Add(new ObjectParameter("prwsat2_BBIDRequestCount", iBBIDRequestCount));
            AddAuditTrailParametersForInsert(oParameters, "prwsat2");
            ExecuteIdentityInsert("PRWebServiceAuditTrail", SQL_WEBSERVICEAUDITTRAIL_INSERT, oParameters);
        }


        protected const string SQL_CITYID_SELECT = "SELECT prci_CityID FROM PRCity (NOLOCK) WHERE prci_City={0} and prci_StateID={1}";
        public int GetCityID(Address oAddress)
        {
            return GetCityID(oAddress, null);
        }

        /// <summary>
        /// Returns the CityID for the specified address by lookup up the
        /// city name and state ID in the PRCity table.  Returns "Unknown"
        /// if not found.
        /// </summary>
        /// <param name="oAddress"></param>
        /// <param name="oTran"></param>
        /// <returns></returns>
        public int GetCityID(Address oAddress, IDbTransaction oTran)
        {
            return GetCityID(oAddress.City, oAddress.StateID, oTran);
        }


        /// <summary>
        /// Returns the CityID for the specified values by lookup up the
        /// city name and state ID in the PRCity table.  Returns "Unknown"
        /// if not found.
        /// </summary>
        /// <param name="szCity"></param>
        /// <param name="iStateID"></param>
        /// <param name="oTran"></param>
        /// <returns></returns>
        public int GetCityID(string szCity, int iStateID, IDbTransaction oTran)
        {

            if ((string.IsNullOrEmpty(szCity)) ||
                (iStateID == 0))
            {
                return UNKNOWN_CITY_ID;
            }

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prci_City", szCity));
            oParameters.Add(new ObjectParameter("prci_StateID", iStateID));

            string szSQL = FormatSQL(SQL_CITYID_SELECT, oParameters);
            object iCityID = GetDBAccess().ExecuteScalar(szSQL, oParameters, oTran);

            if (iCityID == null)
            {
                return UNKNOWN_CITY_ID;
            }

            return Convert.ToInt32(iCityID);
        }

        protected const string SQL_PERSONID_SELECT = "SELECT peli_PersonID FROM Person_Link (NOLOCK) WHERE peli_PersonLinkID={0}";
        /// <summary>
        /// Returns the Person ID for the WebUser
        /// object.
        /// </summary>
        /// <param name="oWebUser"></param>
        /// <returns></returns>
        public int GetPersonID(IPRWebUser oWebUser)
        {

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("peli_PersonLinkID", oWebUser.prwu_PersonLinkID));

            string szSQL = FormatSQL(SQL_PERSONID_SELECT, oParameters);
            return (int)GetDBAccess().ExecuteScalar(szSQL, oParameters);
        }



        protected const string SQL_STATE_ABBR_SELECT = "SELECT prst_Abbreviation FROM PRState (NOLOCK) WHERE prst_StateID={0}";

        public string GetStateAbbr(int iStateID)
        {
            return GetStateAbbr(iStateID, null);
        }

        /// <summary>
        /// Returns the State Abbreviation for the specified ID by looking
        /// in the PRState table.
        /// </summary>
        /// <param name="iStateID"></param>
        /// <param name="oTran"></param>
        /// <returns></returns>
        public string GetStateAbbr(int iStateID, IDbTransaction oTran)
        {

            if (iStateID == 0)
            {
                return null;
            }

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prst_StateID", iStateID));

            string szSQL = FormatSQL(SQL_STATE_ABBR_SELECT, oParameters);
            object szStateAbbr = GetDBAccess().ExecuteScalar(szSQL, oParameters, oTran);

            if (szStateAbbr == null)
            {
                return null;
            }

            return Convert.ToString(szStateAbbr);
        }


        protected const string SQL_COUNTRY_SELECT = "SELECT prcn_Country FROM PRCountry (NOLOCK) WHERE prcn_CountryID={0}";

        /// <summary>
        /// Returns the Country Name for the specified ID by looking
        /// in the PRCountry table.
        /// </summary>
        /// <param name="iCountryID"></param>
        /// <returns></returns>
        public string GetCountryName(int iCountryID)
        {
            return GetCountryName(iCountryID, null);
        }

        public string GetCountryName(int iCountryID, IDbTransaction oTran)
        {

            if (iCountryID == 0)
            {
                return null;
            }

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prcn_CountryID", iCountryID));

            string szSQL = FormatSQL(SQL_COUNTRY_SELECT, oParameters);
            object szCountry = GetDBAccess().ExecuteScalar(szSQL, oParameters, oTran);

            if (szCountry == null)
            {
                return null;
            }

            return Convert.ToString(szCountry);
        }

        public const int PRCO_SPECIALIST_RATINGS = 0;
        public const int PRCO_SPECIALIST_INSIDE_SALES = 1;
        public const int PRCO_SPECIALIST_FIELD_SALES = 2;
        public const int PRCO_SPECIALIST_LISTING_SPECIALIST = 3;
        public const int PRCO_SPECIALIST_CSR = 4;

        public int GetPRCoSpecialistID(string szCity, int iStateID, int iTypeID, IDbTransaction oTran)
        {
            return GetPRCoSpecialistID(szCity, iStateID, iTypeID, GeneralDataMgr.INDUSTRY_TYPE_PRODUCE, oTran);
        }

        /// <summary>
        /// Returns the appropriate specialistID for the 
        /// city and state.
        /// </summary>
        /// <param name="szCity"></param>
        /// <param name="iStateID"></param>
        /// <param name="iTypeID"></param>
        /// <param name="industryType"></param>
        /// <param name="oTran"></param>
        /// <returns></returns>
        public int GetPRCoSpecialistID(string szCity, int iStateID, int iTypeID, string industryType, IDbTransaction oTran)
        {
            int iCityID = GetCityID(szCity, iStateID, oTran);

            string szColName = null;

            if (industryType == INDUSTRY_TYPE_LUMBER)
            {
                switch (iTypeID)
                {
                    case PRCO_SPECIALIST_RATINGS:
                        szColName = "prci_LumberRatingUserId";
                        break;
                    case PRCO_SPECIALIST_INSIDE_SALES:
                        szColName = "prci_LumberInsideSalesRepId";
                        break;
                    case PRCO_SPECIALIST_FIELD_SALES:
                        szColName = "prci_LumberFieldSalesRepId";
                        break;
                    case PRCO_SPECIALIST_LISTING_SPECIALIST:
                        szColName = "prci_LumberListingSpecialistId";
                        break;
                    case PRCO_SPECIALIST_CSR:
                        szColName = "prci_LumberCustomerServiceId";
                        break;
                    default:
                        throw new ApplicationUnexpectedException("Invalid Type Specified");
                }
            }
            else
            {
                switch (iTypeID)
                {
                    case PRCO_SPECIALIST_RATINGS:
                        szColName = "prci_RatingUserId";
                        break;
                    case PRCO_SPECIALIST_INSIDE_SALES:
                        szColName = "prci_InsideSalesRepId";
                        break;
                    case PRCO_SPECIALIST_FIELD_SALES:
                        szColName = "prci_FieldSalesRepId";
                        break;
                    case PRCO_SPECIALIST_LISTING_SPECIALIST:
                        szColName = "prci_ListingSpecialistId";
                        break;
                    case PRCO_SPECIALIST_CSR:
                        szColName = "prci_CustomerServiceId";
                        break;
                    default:
                        throw new ApplicationUnexpectedException("Invalid Type Specified");
                }
            }
            string szSQL = null;
            ArrayList oParameters = new ArrayList();

            // If we don't know what city, then just use
            // any specialist ID for the state.  
            if (iCityID == UNKNOWN_CITY_ID)
            {
                oParameters.Add(new ObjectParameter("prci_StateID", iStateID));
                szSQL = FormatSQL("SELECT MAX(" + szColName + ") FROM PRCity (NOLOCK) WHERE prci_StateID={0}", oParameters);
            }
            else
            {
                oParameters.Add(new ObjectParameter("prci_CityID", iCityID));
                szSQL = FormatSQL("SELECT " + szColName + " FROM PRCity (NOLOCK) WHERE prci_CityID={0}", oParameters);
            }

            object oSpecialistID = GetDBAccess().ExecuteScalar(szSQL, oParameters, oTran);
            if ((oSpecialistID == DBNull.Value) ||
                (oSpecialistID == null))
            {
                return 0;
            }

            return (int)oSpecialistID;
        }

        /// <summary>
        /// Returns the appropriate specialist ID for the company
        /// </summary>
        /// <param name="iCompanyID"></param>
        /// <param name="iTypeID"></param>
        /// <param name="oTran"></param>
        /// <returns></returns>
        public int GetPRCoSpecialistID(int iCompanyID, int iTypeID, IDbTransaction oTran)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", iCompanyID));
            oParameters.Add(new ObjectParameter("TypeId", iTypeID));

            string szSQL = FormatSQL("SELECT dbo.ufn_GetPRCoSpecialistUserId({0}, {1})", oParameters);
            return (int)GetDBAccess().ExecuteScalar(szSQL, oParameters, oTran);
        }

        protected const string SQL_PRCO_USER_EMAIL = "SELECT RTRIM(user_EmailAddress) FROM users (NOLOCK) WHERE user_userid = @UserID";
        /// <summary>
        /// Returns the email address for the specified PRCo user ID.
        /// </summary>
        /// <param name="iUserID"></param>
        /// <param name="oTran"></param>
        /// <returns></returns>
        public string GetPRCoUserEmail(int iUserID, IDbTransaction oTran)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("UserID", iUserID));

            string szEmail = (string)GetDBAccess().ExecuteScalar(SQL_PRCO_USER_EMAIL, oParameters, oTran);
            return szEmail;
        }


        protected const string SQL_PRSEARCHAUDITTRAIL_INSERT =
            @"INSERT INTO PRSearchAuditTrail (prsat_WebUserID, prsat_CompanyID, prsat_SearchType, prsat_SearchWizardAuditTrailID,	prsat_WebUserSearchCritieraID, prsat_UserType, prsat_ResultCount, prsat_IsQuickFind, prsat_IsCompanyGeneral, prsat_IsCompanyLocation, prsat_IsClassification, prsat_IsCommodity, prsat_IsRating, prsat_IsProfile, prsat_IsCustom, prsat_IsHeader, prsat_IsLocalSource, prsat_CreatedBy, prsat_CreatedDate, prsat_UpdatedBy, prsat_UpdatedDate, prsat_TimeStamp)
                VALUES ({0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16},{17},{18},{19},{20},{21})";

        ///<summary>
        /// Creates the PRSearchAuditTrail and PRSearchAuditTrailDetail records
        /// for the specified search.
        /// </summary>
        /// <param name="oSearchCriteria"></param>
        /// <param name="oTran"></param>
        public void InsertSearchAuditTrail(IPRWebUserSearchCriteria oSearchCriteria,
                                           IDbTransaction oTran)
        {
            InsertSearchAuditTrail(oSearchCriteria, 0, oTran);
        }

        /// <summary>
        /// Creates the PRSearchAuditTrail and PRSearchAuditTrailDetail records
        /// for the specified search.
        /// </summary>
        /// <param name="oSearchCriteria"></param>
        /// <param name="iSearchWizardAuditTrailID"></param>
        /// <param name="oTran"></param>
        public int InsertSearchAuditTrail(IPRWebUserSearchCriteria oSearchCriteria,
                                           int iSearchWizardAuditTrailID,
                                           IDbTransaction oTran)
        {

            if (!Utilities.GetBoolConfigValue("SearchAuditTrailEnabled", true))
            {
                return 0;
            }

            IPRWebUser oUser = (IPRWebUser)_oUser;
            //int iSearchAuditTrailID = GetRecordID("PRSearchAuditTrail", oTran);

            ArrayList oParameters = new ArrayList();
            //oParameters.Add(new ObjectParameter("prsat_SearchAuditTrailID", iSearchAuditTrailID));
            oParameters.Add(new ObjectParameter("prsat_WebUserID", oUser.UserID));
            oParameters.Add(new ObjectParameter("prsat_CompanyID", oUser.prwu_BBID));
            oParameters.Add(new ObjectParameter("prsat_SearchType", oSearchCriteria.prsc_SearchType));

            if (iSearchWizardAuditTrailID == 0)
            {
                oParameters.Add(new ObjectParameter("prsat_SearchWizardAuditTrailID", null));
            }
            else
            {
                oParameters.Add(new ObjectParameter("prsat_SearchWizardAuditTrailID", iSearchWizardAuditTrailID));
            }

            oParameters.Add(new ObjectParameter("prsat_WebUserSearchCritieraID", oSearchCriteria.prsc_SearchCriteriaID));

            oParameters.Add(new ObjectParameter("prsat_UserType", "M"));

            oParameters.Add(new ObjectParameter("prsat_ResultCount", oSearchCriteria.prsc_LastExecutionResultCount));

            if (oSearchCriteria.prsc_SearchType == PRWebUserSearchCriteria.SEARCH_TYPE_COMPANY)
            {
                CompanySearchCriteria oCompanySearchCriteria = (CompanySearchCriteria)oSearchCriteria.Criteria;
                oParameters.Add(new ObjectParameter("prsat_IsQuickFind", GetPIKSCoreBool(oCompanySearchCriteria.IsQuickSearch)));
                oParameters.Add(new ObjectParameter("prsat_IsCompanyGeneral", GetPIKSCoreBool(IsCompanyGeneral(oCompanySearchCriteria))));
                oParameters.Add(new ObjectParameter("prsat_IsCompanyLocation", GetPIKSCoreBool(IsCompanyLocation(oCompanySearchCriteria))));
                oParameters.Add(new ObjectParameter("prsat_IsClassification", GetPIKSCoreBool(IsCompanyClassification(oCompanySearchCriteria))));
                oParameters.Add(new ObjectParameter("prsat_IsCommodity", GetPIKSCoreBool(IsCompanyCommodity(oCompanySearchCriteria))));
                oParameters.Add(new ObjectParameter("prsat_IsRating", GetPIKSCoreBool(IsCompanyRating(oCompanySearchCriteria))));
                oParameters.Add(new ObjectParameter("prsat_IsProfile", GetPIKSCoreBool(IsCompanyProfile(oCompanySearchCriteria))));
                oParameters.Add(new ObjectParameter("prsat_IsCustom", GetPIKSCoreBool(IsCompanyCustom(oCompanySearchCriteria))));
                oParameters.Add(new ObjectParameter("prsat_IsHeader", GetPIKSCoreBool(!string.IsNullOrEmpty(oCompanySearchCriteria.IndustryType))));
                oParameters.Add(new ObjectParameter("prsat_IsLocalSource", GetPIKSCoreBool(IsCompanyLocalSource(oCompanySearchCriteria))));

            }
            else
            {

                if (oSearchCriteria.prsc_SearchType == PRWebUserSearchCriteria.SEARCH_TYPE_CLAIM_ACTIVITY)
                {
                    oParameters.Add(new ObjectParameter("prsat_IsQuickFind", GetPIKSCoreBool(((ClaimActivitySearchCriteria)oSearchCriteria.Criteria).IsQuickSearch)));
                }
                else
                {
                    oParameters.Add(new ObjectParameter("prsat_IsQuickFind", null));
                }


                oParameters.Add(new ObjectParameter("prsat_IsCompanyGeneral", null));
                oParameters.Add(new ObjectParameter("prsat_IsCompanyLocation", null));
                oParameters.Add(new ObjectParameter("prsat_IsClassification", null));
                oParameters.Add(new ObjectParameter("prsat_IsCommodity", null));
                oParameters.Add(new ObjectParameter("prsat_IsRating", null));
                oParameters.Add(new ObjectParameter("prsat_IsProfile", null));
                oParameters.Add(new ObjectParameter("prsat_IsCustom", null));
                oParameters.Add(new ObjectParameter("prsat_IsHeader", null));
                oParameters.Add(new ObjectParameter("prsat_IsLocalSource", null));
            }
            AddAuditTrailParametersForInsert(oParameters, "prsat");
            int iSearchAuditTrailID = ExecuteIdentityInsert("PRSearchAuditTrail", SQL_PRSEARCHAUDITTRAIL_INSERT, oParameters, oTran);

            if (oSearchCriteria.prsc_SearchType == "Company")
            {
                CompanySearchCriteria oCompanySearchCriteria = (CompanySearchCriteria)oSearchCriteria.Criteria;
                ProcessSearchAuditTrailCriteria(iSearchAuditTrailID, oCompanySearchCriteria, oTran);
            }

            return iSearchAuditTrailID;
        }

        /// <summary>
        /// We are only auditing a limited number of fields.
        /// </summary>
        /// <param name="iSearchAuditTrailID"></param>
        /// <param name="oCompanySearchCriteria"></param>
        /// <param name="oTran"></param>
        private void ProcessSearchAuditTrailCriteria(int iSearchAuditTrailID,
                                                    CompanySearchCriteria oCompanySearchCriteria,
                                                    IDbTransaction oTran)
        {

            InsertSearchAuditTrailCriteria(iSearchAuditTrailID, "H", "IT", 0, oCompanySearchCriteria.IndustryType, oTran);

            InsertSearchAuditTrailCriteria(iSearchAuditTrailID, "L", "LCN", 0, oCompanySearchCriteria.ListingCountryIDs, oTran);
            InsertSearchAuditTrailCriteria(iSearchAuditTrailID, "L", "LS", 0, oCompanySearchCriteria.ListingStateIDs, oTran);
            InsertSearchAuditTrailCriteria(iSearchAuditTrailID, "L", "LCI", 0, oCompanySearchCriteria.ListingCity, oTran);
            InsertSearchAuditTrailCriteria(iSearchAuditTrailID, "L", "PC", 0, oCompanySearchCriteria.ListingPostalCode, oTran);
            InsertSearchAuditTrailCriteria(iSearchAuditTrailID, "L", "TM", 0, oCompanySearchCriteria.TerminalMarketIDs, oTran);

            // -1 means no radius.  A radius of 0 is valid and means searching only the specified zip code.
            if (oCompanySearchCriteria.Radius > -1)
            {
                InsertSearchAuditTrailCriteria(iSearchAuditTrailID, "L", "RS", oCompanySearchCriteria.Radius, null, oTran);
            }

            InsertSearchAuditTrailCriteria(iSearchAuditTrailID, "CM", "CM", 0, oCompanySearchCriteria.CommodityIDs, oTran);
            InsertSearchAuditTrailCriteria(iSearchAuditTrailID, "CM", "CMA", oCompanySearchCriteria.CommodityAttributeID, null, oTran);
            InsertSearchAuditTrailCriteria(iSearchAuditTrailID, "CM", "CMGM", oCompanySearchCriteria.CommodityGMAttributeID, null, oTran);

            InsertSearchAuditTrailCriteria(iSearchAuditTrailID, "CL", "CL", 0, oCompanySearchCriteria.ClassificationIDs, oTran);

            InsertSearchAuditTrailCriteria(iSearchAuditTrailID, "P", "VO", 0, oCompanySearchCriteria.Volume, oTran);
            InsertSearchAuditTrailCriteria(iSearchAuditTrailID, "P", "BR", 0, oCompanySearchCriteria.Brands, oTran);

            InsertSearchAuditTrailCriteria(iSearchAuditTrailID, "PP", "PP", 0, oCompanySearchCriteria.ProductProvidedIDs, oTran);
            InsertSearchAuditTrailCriteria(iSearchAuditTrailID, "SP", "SP", 0, oCompanySearchCriteria.ServiceProvidedIDs, oTran);
            InsertSearchAuditTrailCriteria(iSearchAuditTrailID, "S", "S", 0, oCompanySearchCriteria.SpecieIDs, oTran);

            // Only record this critiera if the user has access.
            if (((IPRWebUser)_oUser).HasPrivilege(SecurityMgr.Privilege.LocalSourceDataAccess).HasPrivilege)
            {
                InsertSearchAuditTrailCriteria(iSearchAuditTrailID, "LSS", "IEB", 0, oCompanySearchCriteria.IncludeLocalSource, oTran);
                InsertSearchAuditTrailCriteria(iSearchAuditTrailID, "LSS", "AO", 0, oCompanySearchCriteria.AlsoOperates, oTran);
                InsertSearchAuditTrailCriteria(iSearchAuditTrailID, "LSS", "TA", 0, oCompanySearchCriteria.TotalAcres, oTran);

                if (oCompanySearchCriteria.CertifiedOrganic)
                {
                    InsertSearchAuditTrailCriteria(iSearchAuditTrailID, "LSS", "CO", 0, "Yes", oTran);
                }
            }

        }

        protected const string SQL_PRSEARCHAUDITTRAILCRITERIA_INSERT =
            @"INSERT INTO PRSearchAuditTrailCriteria (prsatc_SearchAuditTrailID, prsatc_CriteriaTypeCode, prsatc_CriteriaSubtypeCode, prsatc_IntValue, prsatc_StringValue, prsatc_CreatedBy, prsatc_CreatedDate, prsatc_UpdatedBy, prsatc_UpdatedDate, prsatc_TimeStamp) 
                   VALUES ({0},{1},{2},{3},{4},{5},{6},{7},{8},{9})";

        private void InsertSearchAuditTrailCriteria(int iSearchAuditTrailID,
                                                  string szCriteriaTypeCode,
                                                  string szCriteriaSubtypeCode,
                                                  int iIntValue,
                                                  string szStringValue,
                                                  IDbTransaction oTran)
        {

            //A radius of 0 is valid and means searching only the specified zip code.
            if (szCriteriaSubtypeCode != "RS")
            {
                if ((string.IsNullOrEmpty(szStringValue)) &&
                    (iIntValue == 0))
                {
                    return;
                }
            }

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prsatc_SearchAuditTrailID", iSearchAuditTrailID));
            oParameters.Add(new ObjectParameter("prsatc_CriteriaTypeCode", szCriteriaTypeCode));
            oParameters.Add(new ObjectParameter("prsatc_CriteriaSubtypeCode", szCriteriaSubtypeCode));
            oParameters.Add(new ObjectParameter("prsatc_IntValue", iIntValue));
            oParameters.Add(new ObjectParameter("prsatc_StringValue", szStringValue));
            AddAuditTrailParametersForInsert(oParameters, "prsatc");
            ExecuteIdentityInsert("PRSearchAuditTrailDetail", SQL_PRSEARCHAUDITTRAILCRITERIA_INSERT, oParameters, oTran);
        }



        /// <summary>
        /// Creates the PRSearchAuditTrail and PRSearchAuditTrailDetail records
        /// for the specified search.
        /// </summary>
        /// <param name="szTypeCode"></param>
        /// <param name="szCriteriaTypeCode"></param>
        /// <param name="szKeywords"></param>
        /// <param name="iResultCount"></param>
        /// <param name="oTran"></param>
        public void InsertSearchAuditTrail(string szTypeCode,
                                           string szCriteriaTypeCode,
                                           string szKeywords,
                                           int iResultCount,
                                           IDbTransaction oTran)
        {

            if (!Utilities.GetBoolConfigValue("SearchAuditTrailEnabled", true))
            {
                return;
            }

            IPRWebUser oUser = (IPRWebUser)_oUser;


            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prsat_WebUserID", oUser.UserID));
            oParameters.Add(new ObjectParameter("prsat_CompanyID", oUser.prwu_BBID));
            oParameters.Add(new ObjectParameter("prsat_SearchType", szTypeCode));
            oParameters.Add(new ObjectParameter("prsat_SearchWizardAuditTrailID", null));
            oParameters.Add(new ObjectParameter("prsat_WebUserSearchCritieraID", null));

            oParameters.Add(new ObjectParameter("prsat_UserType", "M"));

            oParameters.Add(new ObjectParameter("prsat_ResultCount", iResultCount));

            oParameters.Add(new ObjectParameter("prsat_IsQuickFind", null));
            oParameters.Add(new ObjectParameter("prsat_IsCompanyGeneral", null));
            oParameters.Add(new ObjectParameter("prsat_IsCompanyLocation", null));
            oParameters.Add(new ObjectParameter("prsat_IsClassification", null));
            oParameters.Add(new ObjectParameter("prsat_IsCommodity", null));
            oParameters.Add(new ObjectParameter("prsat_IsRating", null));
            oParameters.Add(new ObjectParameter("prsat_IsProfile", null));
            oParameters.Add(new ObjectParameter("prsat_IsCustom", null));
            oParameters.Add(new ObjectParameter("prsat_IsHeader", null));
            oParameters.Add(new ObjectParameter("prsat_IsLocalSource", null));

            AddAuditTrailParametersForInsert(oParameters, "prsat");
            int iSearchAuditTrailID = ExecuteIdentityInsert("PRSearchAuditTrail", SQL_PRSEARCHAUDITTRAIL_INSERT, oParameters, oTran);

            InsertSearchAuditTrailCriteria(iSearchAuditTrailID, szCriteriaTypeCode, "KW", 0, szKeywords, oTran);
        }


        protected const string SQL_PRWEBUSERNOTE_INSERT =
            @"INSERT INTO PRWebUserNote (prwun_WebUserID, prwun_CompanyID, prwun_HQID, prwun_AssociatedID, prwun_AssociatedType, prwun_Note, prwun_IsPrivate, prwun_NoteUpdatedBy, prwun_NoteUpdatedDateTime, prwun_CreatedBy, prwun_CreatedDate, prwun_UpdatedBy, prwun_UpdatedDate, prwun_TimeStamp) 
                VALUES ({0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13})";
        /// <summary>
        /// Inserts a Note record
        /// </summary>
        /// <param name="iAssociatedID"></param>
        /// <param name="szAssociatedType"></param>
        /// <param name="szNote"></param>
        /// <param name="bIsPrivate"></param>
        /// <param name="oTran"></param>
        public int InsertNote(int iAssociatedID,
                                string szAssociatedType,
                                string szNote,
                                bool bIsPrivate,
                                IDbTransaction oTran)
        {

            //int iNoteID = GetRecordID("PRWebUserNote", oTran);
            IPRWebUser oWebuser = (IPRWebUser)_oUser;
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prwun_WebUserID", oWebuser.UserID));
            oParameters.Add(new ObjectParameter("prwun_CompanyID", oWebuser.prwu_BBID));
            oParameters.Add(new ObjectParameter("prwun_HQID", oWebuser.prwu_HQID));
            oParameters.Add(new ObjectParameter("prwun_AssociatedID", iAssociatedID));
            oParameters.Add(new ObjectParameter("prwun_AssociatedType", szAssociatedType));
            oParameters.Add(new ObjectParameter("prwun_Note", szNote));
            oParameters.Add(new ObjectParameter("prwun_IsPrivate", GetPIKSCoreBool(bIsPrivate)));
            oParameters.Add(new ObjectParameter("prwun_NoteUpdatedBy", oWebuser.UserID));
            oParameters.Add(new ObjectParameter("prwun_NoteUpdatedDateTime", DateTime.Now));

            AddAuditTrailParametersForInsert(oParameters, "prwun_");
            int iNoteID = ExecuteIdentityInsert("PRWebUserNote", SQL_PRWEBUSERNOTE_INSERT, oParameters, oTran);

            return iNoteID;
        }

        protected const string SQL_PRWEBUSERNOTE_UPDATE = "UPDATE PRWebUserNote SET prwun_Note={0}, prwun_WebUserID={1}, prwun_CompanyID={2}, prwun_UpdatedBy={3}, prwun_UpdatedDate={4}, prwun_TimeStamp={5} WHERE prwun_WebUserNoteID = {6}";
        /// <summary>
        /// Updates an existing note record
        /// </summary>
        /// <param name="iNoteID"></param>
        /// <param name="szNote"></param>
        /// <param name="oTran"></param>
        public void UpdateNote(int iNoteID,
                                string szNote,
                                IDbTransaction oTran)
        {
            IPRWebUser oWebuser = (IPRWebUser)_oUser;
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prwun_Note", szNote));
            oParameters.Add(new ObjectParameter("prwun_WebUserID", oWebuser.UserID));
            oParameters.Add(new ObjectParameter("prwun_CompanyID", oWebuser.prwu_BBID));
            AddAuditTrailParametersForUpdate(oParameters, "prwun_");
            oParameters.Add(new ObjectParameter("prwun_WebUserNoteID", iNoteID));

            string szSQL = FormatSQL(SQL_PRWEBUSERNOTE_UPDATE, oParameters);
            GetDBAccess().ExecuteNonQuery(szSQL, oParameters, oTran);
        }

        protected const string SQL_PRWEBUSERNOTE_DELETE = "DELETE FROM PRWebUserNote WHERE prwun_WebUserNoteID={0}";
        /// <summary>
        /// Deletes an existing note record.
        /// </summary>
        /// <param name="iNoteID"></param>
        /// <param name="oTran"></param>
        public void DeleteNote(int iNoteID,
                               IDbTransaction oTran)
        {

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prwun_WebUserNoteID", iNoteID));

            string szSQL = FormatSQL(SQL_PRWEBUSERNOTE_DELETE, oParameters);
            GetDBAccess().ExecuteNonQuery(szSQL, oParameters, oTran);
        }


        protected const string SQL_PRWEBUSERCUSTOMDATA_INSERT = "INSERT INTO PRWebUserCustomData (prwucd_WebUserID, prwucd_CompanyID, prwucd_HQID, prwucd_AssociatedID, prwucd_AssociatedType, prwucd_LabelCode, prwucd_Value, prwucd_CreatedBy, prwucd_CreatedDate, prwucd_UpdatedBy, prwucd_UpdatedDate, prwucd_TimeStamp) VALUES ({0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11})";
        /// <summary>
        /// Inserts a CustomData record
        /// </summary>
        /// <param name="iAssociatedID"></param>
        /// <param name="szAssociatedType"></param>
        /// <param name="szLabelCode"></param>
        /// <param name="szValue"></param>
        /// <param name="oTran"></param>
        public void InsertCustomData(int iAssociatedID,
                                     string szAssociatedType,
                                     string szLabelCode,
                                     string szValue,
                                     IDbTransaction oTran)
        {

            IPRWebUser oWebuser = (IPRWebUser)_oUser;
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prwucd_WebUserID", oWebuser.UserID));
            oParameters.Add(new ObjectParameter("prwucd_CompanyID", oWebuser.prwu_BBID));
            oParameters.Add(new ObjectParameter("prwucd_HQID", oWebuser.prwu_HQID));
            oParameters.Add(new ObjectParameter("prwucd_AssociatedID", iAssociatedID));
            oParameters.Add(new ObjectParameter("prwucd_AssociatedType", szAssociatedType));
            oParameters.Add(new ObjectParameter("prwucd_LabelCode", szLabelCode));
            oParameters.Add(new ObjectParameter("prwucd_Value", szValue));
            AddAuditTrailParametersForInsert(oParameters, "prwucd_");
            ExecuteIdentityInsert("PRWebUserCustomData", SQL_PRWEBUSERCUSTOMDATA_INSERT, oParameters, oTran);
        }


        protected const string SQL_PRPUBLICATIONARTICLEREAD_INSERT =
          "INSERT INTO PRPublicationArticleRead (prpar_PublicationArticleID, prpar_SourceID, prpar_SourceEntityType, prpar_TriggerPage, prpar_WebUserID, prpar_PublicationCode) " +
           "VALUES ({0},{1},{2},{3},{4},{5})";

        public void InsertPublicationArticleRead(int iArticleID,
                                                 int iSourceID,
                                                 string szSourceEntityType,
                                                 string szTriggerPage,
                                                 string szPublicationCode,
                                                 IDbTransaction oTran)
        {

            IPRWebUser oWebuser = (IPRWebUser)_oUser;
            ArrayList oParameters = new ArrayList();

            oParameters.Clear();
            oParameters.Add(new ObjectParameter("prpar_PublicationArticleID", iArticleID));
            oParameters.Add(new ObjectParameter("prpar_SourceID", iSourceID));
            oParameters.Add(new ObjectParameter("prpar_SourceEntityType", szSourceEntityType));
            oParameters.Add(new ObjectParameter("prpar_TriggerPage", szTriggerPage));
            oParameters.Add(new ObjectParameter("prpar_WebUserID", oWebuser.prwu_WebUserID));
            oParameters.Add(new ObjectParameter("prpar_PublicationCode", szPublicationCode));

            AddAuditTrailParametersForInsert(oParameters, "prpar");
            ExecuteIdentityInsert("PRPublicationArticleRead", SQL_PRPUBLICATIONARTICLEREAD_INSERT, oParameters, oTran);
        }

        protected const string SQL_PRPUBLICATIONARTICLEREAD_DELETE =
            "DELETE FROM PRPublicationArticleRead WHERE prpar_PublicationArticleID = {0} AND prpar_WebUserID = {1} AND prpar_PublicationCode = {2}";
        public void DeletePublicationArticleRead(int iArticleID,
                                                 string publicationCode,
                                                 IDbTransaction oTran)
        {
            IPRWebUser oWebuser = (IPRWebUser)_oUser;
            ArrayList oParameters = new ArrayList();

            oParameters.Clear();
            oParameters.Add(new ObjectParameter("prpar_PublicationArticleID", iArticleID));
            oParameters.Add(new ObjectParameter("prpar_WebUserID", oWebuser.prwu_WebUserID));
            oParameters.Add(new ObjectParameter("prpar_PublicationCode", publicationCode));
            GetDBAccessFullRights().ExecuteNonQuery(FormatSQL(SQL_PRPUBLICATIONARTICLEREAD_DELETE, oParameters), oParameters, oTran);
        }


        protected const string SQL_SELECT_BBOS_POPUP =
            @"SELECT DISTINCT prpbar_PublicationArticleID, prpbar_Name, prpbar_Body, prpbar_Size, prpar_PublicationArticleID
				FROM PRPublicationArticle WITH (NOLOCK)
					 LEFT OUTER JOIN PRPublicationArticleRead WITH (NOLOCK) ON prpbar_PublicationArticleID = prpar_PublicationArticleID 
                            AND prpar_PublicationCode = prpbar_PublicationCode 
                            AND prpar_WebUserID = @WebUserID 
			   WHERE prpbar_PublicationCode = 'BBOSPU'
				 AND GETDATE() BETWEEN prpbar_PublishDate AND ISNULL(prpbar_ExpirationDate, DATEADD(day, 1, GETDATE())) 
				 AND prpbar_IndustryTypeCode LIKE @IndustryTypeCode
				 AND CAST(prpbar_AccessLevel as Int) <= @AccessLevel";

        public IDataReader GetBBOSPopupDataReader()
        {
            IPRWebUser oWebuser = (IPRWebUser)_oUser;
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("IndustryTypeCode", "%," + oWebuser.prwu_IndustryType + ",%"));
            oParameters.Add(new ObjectParameter("AccessLevel", Convert.ToInt32(oWebuser.prwu_AccessLevel)));
            oParameters.Add(new ObjectParameter("WebUserID", Convert.ToInt32(oWebuser.prwu_WebUserID)));
            string szSQL = FormatSQL(SQL_SELECT_BBOS_POPUP, oParameters);

            return GetDBAccess().ExecuteReader(szSQL, oParameters);
        }

        protected const string SQL_PRWEBUSERCUSTOMDATA_UPDATE = "UPDATE PRWebUserCustomData SET prwucd_Value={0}, prwucd_WebUserID={1}, prwucd_CompanyID={2}, prwucd_UpdatedBy={3}, prwucd_UpdatedDate={4}, prwucd_TimeStamp={5} WHERE prwucd_CustomDataID = {6}";
        /// <summary>
        /// Updates an existing custom data record
        /// </summary>
        /// <param name="iCustomDataID"></param>
        /// <param name="szValue"></param>
        /// <param name="oTran"></param>
        public void UpdateCustomData(int iCustomDataID,
                                     string szValue,
                                     IDbTransaction oTran)
        {
            IPRWebUser oWebuser = (IPRWebUser)_oUser;
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prwucd_Value", szValue));
            oParameters.Add(new ObjectParameter("prwucd_WebUserID", oWebuser.UserID));
            oParameters.Add(new ObjectParameter("prwucd_CompanyID", oWebuser.prwu_BBID));
            AddAuditTrailParametersForUpdate(oParameters, "prwucd_");
            oParameters.Add(new ObjectParameter("prwucd_CustomDataID", iCustomDataID));

            string szSQL = FormatSQL(SQL_PRWEBUSERCUSTOMDATA_UPDATE, oParameters);
            GetDBAccess().ExecuteNonQuery(szSQL, oParameters, oTran);
        }

        protected const string SQL_PRWEBUSERCUSTOMDATA_DELETE = "DELETE FROM PRWebUserCustomData WHERE prwucd_CustomDataID={0}";
        /// <summary>
        /// Deletes an existing note record.
        /// </summary>
        /// <param name="iCustomDataID"></param>
        /// <param name="oTran"></param>
        public void DeleteCustomData(int iCustomDataID,
                                     IDbTransaction oTran)
        {

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prwucd_CustomDataID", iCustomDataID));

            string szSQL = FormatSQL(SQL_PRWEBUSERCUSTOMDATA_DELETE, oParameters);
            GetDBAccess().ExecuteNonQuery(szSQL, oParameters, oTran);
        }

        private bool IsCompanyGeneral(CompanySearchCriteria oCompanySearchCritiera)
        {
            if ((!string.IsNullOrEmpty(oCompanySearchCritiera.CompanyName)) ||
                (!string.IsNullOrEmpty(oCompanySearchCritiera.CompanyType)) ||
                (!string.IsNullOrEmpty(oCompanySearchCritiera.ListingStatus)) ||
                (!string.IsNullOrEmpty(oCompanySearchCritiera.PhoneAreaCode)) ||
                (!string.IsNullOrEmpty(oCompanySearchCritiera.PhoneNumber)) ||
                (!string.IsNullOrEmpty(oCompanySearchCritiera.FaxAreaCode)) ||
                (!string.IsNullOrEmpty(oCompanySearchCritiera.FaxNumber)) ||
                (!string.IsNullOrEmpty(oCompanySearchCritiera.Email)))
            {
                return true;
            }

            if (oCompanySearchCritiera.BBID > 0)
            {
                return true;
            };

            if ((oCompanySearchCritiera.FaxNotNull) ||
                (oCompanySearchCritiera.EmailNotNull) ||
                (oCompanySearchCritiera.NewListingOnly))
            {
                return true;
            }

            return false;
        }

        private bool IsCompanyLocation(CompanySearchCriteria oCompanySearchCritiera)
        {
            if ((!string.IsNullOrEmpty(oCompanySearchCritiera.ListingCountryIDs)) ||
                (!string.IsNullOrEmpty(oCompanySearchCritiera.ListingStateIDs)) ||
                (!string.IsNullOrEmpty(oCompanySearchCritiera.ListingCity)) ||
                (!string.IsNullOrEmpty(oCompanySearchCritiera.ListingPostalCode)) ||
                (!string.IsNullOrEmpty(oCompanySearchCritiera.TerminalMarketIDs)))
            {
                return true;
            }

            return false;
        }

        private bool IsCompanyClassification(CompanySearchCriteria oCompanySearchCritiera)
        {
            if ((!string.IsNullOrEmpty(oCompanySearchCritiera.ClassificationIDs)) ||
                (!string.IsNullOrEmpty(oCompanySearchCritiera.NumberOfRestaurantStores)) ||
                (!string.IsNullOrEmpty(oCompanySearchCritiera.NumberOfRetailStores)))
            {
                return true;
            }

            return false;
        }

        private bool IsCompanyCommodity(CompanySearchCriteria oCompanySearchCritiera)
        {
            if (!string.IsNullOrEmpty(oCompanySearchCritiera.CommodityIDs))
            {
                return true;
            }

            if ((oCompanySearchCritiera.CommodityAttributeID > 0) ||
                (oCompanySearchCritiera.CommodityGMAttributeID > 0))
            {
                return true;
            };

            return false;
        }

        private bool IsCompanyRating(CompanySearchCriteria oCompanySearchCritiera)
        {
            if ((!string.IsNullOrEmpty(oCompanySearchCritiera.RatingCreditWorthIDs)) ||
                (!string.IsNullOrEmpty(oCompanySearchCritiera.RatingIntegrityIDs)) ||
                (!string.IsNullOrEmpty(oCompanySearchCritiera.RatingNumeralIDs)) ||
                (!string.IsNullOrEmpty(oCompanySearchCritiera.RatingNumeralSearchType)) ||
                (!string.IsNullOrEmpty(oCompanySearchCritiera.RatingPayIDs)))
            {
                return true;
            }

            return false;
        }

        private bool IsCompanyProfile(CompanySearchCriteria oCompanySearchCritiera)
        {
            if ((!string.IsNullOrEmpty(oCompanySearchCritiera.LicenseTypes)) ||
                (!string.IsNullOrEmpty(oCompanySearchCritiera.LicenseNumber)) ||
                (!string.IsNullOrEmpty(oCompanySearchCritiera.Brands)) ||
                (!string.IsNullOrEmpty(oCompanySearchCritiera.CorporateStructure)) ||
                (!string.IsNullOrEmpty(oCompanySearchCritiera.DescriptiveLines)) ||
                (!string.IsNullOrEmpty(oCompanySearchCritiera.Volume)))
            {
                return true;
            }

            return false;
        }


        private bool IsCompanyCustom(CompanySearchCriteria oCompanySearchCritiera)
        {
            if ((!string.IsNullOrEmpty(oCompanySearchCritiera.CustomIdentifier)) ||
                (!string.IsNullOrEmpty(oCompanySearchCritiera.UserListIDs)))
            {
                return true;
            }

            if (oCompanySearchCritiera.CustomIdentifierNotNull)
            {
                return true;
            }

            return false;
        }

        private bool IsCompanyLocalSource(CompanySearchCriteria oCompanySearchCritiera)
        {
            if ((oCompanySearchCritiera.IncludeLocalSource == "ILS") ||
                (oCompanySearchCritiera.IncludeLocalSource == "LSO"))
            {
                return true;
            }


            return false;
        }


        protected const string SQL_HAS_NOTE = "SELECT dbo.ufn_HasNote({0}, {1}, {2}, 'C') As HasNote";
        /// <summary>
        /// Determines if the specified company has a note viewable by the current user.
        /// </summary>
        /// <param name="iCompanyID"></param>
        /// <returns></returns>
        public bool HasNote(int iCompanyID)
        {
            IPRWebUser oWebUser = (IPRWebUser)_oUser;

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("UserID", oWebUser.prwu_WebUserID));
            oParameters.Add(new ObjectParameter("HQID", oWebUser.prwu_HQID));
            oParameters.Add(new ObjectParameter("CompanyID", iCompanyID));

            // We want our own connection to avoid conflicts with
            // an open DataReader
            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            oDBAccess.Logger = _oLogger;

            string szSQL = FormatSQL(SQL_HAS_NOTE, oParameters);

            object oResult = oDBAccess.ExecuteScalar(szSQL, oParameters);

            if (oResult == DBNull.Value)
            {
                return false;
            }

            string szResult = (string)oResult;
            if ((!string.IsNullOrEmpty(szResult)) &&
                szResult == "Y")
            {
                return true;
            }

            return false;
        }


        protected const string SQL_SELECT_COMPANY_LISTING_STATUS = "SELECT comp_PRListingStatus FROM Company (NOLOCK) WHERE comp_CompanyID={0};";
        /// <summary>
        /// Determines if the specified company is listed.  Used most often to
        /// validate security.
        /// </summary>
        /// <param name="iCompanyID"></param>
        /// <returns></returns>
        public bool IsCompanyListed(int iCompanyID)
        {
            return IsCompanyListed(iCompanyID, null);
        }

        /// <summary>
        /// Determines if the specified company is listed.  Used most often to
        /// validate security.
        /// </summary>
        /// <param name="iCompanyID"></param>
        /// <param name="oTran"></param>
        /// <returns></returns>
        public bool IsCompanyListed(int iCompanyID, IDbTransaction oTran)
        {

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", iCompanyID));

            string szSQL = FormatSQL(SQL_SELECT_COMPANY_LISTING_STATUS, oParameters);
            string szListingStatus = (string)GetDBAccess().ExecuteScalar(szSQL, oParameters, oTran);

            if (string.IsNullOrEmpty(szListingStatus))
            {
                return false;
            }

            if ((szListingStatus == "L") ||
                (szListingStatus == "H") ||
                (szListingStatus == "N3") ||
                (szListingStatus == "N5") ||
                (szListingStatus == "N6") ||
                (szListingStatus == "LUV"))
            {
                return true;
            }

            return false;
        }

        public const string SQL_UPDATE_COMPANY_TERMS = "UPDATE Company SET comp_PREBBTermsAcceptedDate=GETDATE(), comp_PREBBTermsAcceptedBy={0} WHERE comp_CompanyID={1}";
        /// <summary>
        /// Sets the Accepted Terms fields on the current user's
        /// company record to today's date.
        /// </summary>
        public void SetAcceptedTerms()
        {
            IPRWebUser oUser = (IPRWebUser)_oUser;
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("comp_PREBBTermsAcceptedBy", oUser.prwu_WebUserID));
            oParameters.Add(new ObjectParameter("CompanyID", oUser.prwu_HQID));

            string szSQL = FormatSQL(SQL_UPDATE_COMPANY_TERMS, oParameters);
            GetDBAccessFullRights().ExecuteNonQuery(szSQL, oParameters);
        }

        const string SQL_UPDATE_ITA_FLAG_NULL = "UPDATE Company SET comp_PRHasITAAccess={0} WHERE comp_CompanyID={1}";
        /// <summary>
        /// Sets the comp_PRIsIntlTradeAssociation flag to NULL
        /// </summary>
        public void SetCompanyITAAccessFlag(bool bFlag)
        {
            IPRWebUser oUser = (IPRWebUser)_oUser;
            GeneralDataMgr _oObjectMgr = new GeneralDataMgr(_oLogger, oUser);
            _oObjectMgr.ConnectionName = "DBConnectionStringFullRights";

            int iTransactionID = _oObjectMgr.CreatePIKSTransaction(oUser.prwu_BBID, 0, _oUser.Name, Utilities.GetConfigValue("CompanyITAFlagCleared", "Company ITA flag cleared when user purchased a membership via web."), null);

            string szSQL = string.Format(SQL_UPDATE_ITA_FLAG_NULL, bFlag ? "'Y'" : "NULL", oUser.prwu_BBID);
            GetDBAccessFullRights().ExecuteNonQuery(szSQL);

            _oObjectMgr.ClosePIKSTransaction(iTransactionID, null);
        }


        public const string SQL_UPDATE_LINKED_IN_URL = "UPDATE Person SET pers_PRLinkedInProfile={0} WHERE pers_PersonID={1}";
        /// <summary>
        /// Sets the Accepted Terms fields on the current user's
        /// company record to today's date.
        /// </summary>
        public void UpdateLinkedInURL(string url)
        {
            IPRWebUser oUser = (IPRWebUser)_oUser;
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("pers_PRLinkedInProfile", url));
            oParameters.Add(new ObjectParameter("pers_PersonID", oUser.peli_PersonID));

            string szSQL = FormatSQL(SQL_UPDATE_LINKED_IN_URL, oParameters);
            GetDBAccessFullRights().ExecuteNonQuery(szSQL, oParameters);
        }


        protected const string SQL_PRWEBUSERLIST_INSERT =
                @"INSERT INTO PRWebUserList (prwucl_WebUserID, prwucl_CompanyID, prwucl_HQID, prwucl_TypeCode, prwucl_Name, prwucl_Description, prwucl_IsPrivate, prwucl_Pinned, prwucl_CategoryIcon, prwucl_CreatedBy, prwucl_CreatedDate, prwucl_UpdatedBy, prwucl_UpdatedDate, prwucl_TimeStamp) VALUES ({0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13})";
        /// <summary>
        /// Inserts a PRWebUserList record
        /// </summary>
        /// <param name="szTypeCode"></param>
        /// <param name="szName"></param>
        /// <param name="bIsPrivate"></param>
        /// <param name="bPinned"></param>
        /// <param name="icon"></param>
        /// <param name="oTran"></param>
        public int InsertWebUserList(string szTypeCode,
                                      string szName,
                                      string szDescription,
                                      bool bIsPrivate,
                                      bool bPinned,
                                      string icon,
                                      IDbTransaction oTran)
        {

            IPRWebUser oWebuser = (IPRWebUser)_oUser;
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prwucl_WebUserID", oWebuser.UserID));
            oParameters.Add(new ObjectParameter("prwucl_CompanyID", oWebuser.prwu_BBID));
            oParameters.Add(new ObjectParameter("prwucl_HQID", oWebuser.prwu_HQID));
            oParameters.Add(new ObjectParameter("prwucl_TypeCode", szTypeCode));
            oParameters.Add(new ObjectParameter("prwucl_Name", szName));
            oParameters.Add(new ObjectParameter("prwucl_Description", szDescription));
            oParameters.Add(new ObjectParameter("prwucl_IsPrivate", GetPIKSCoreBool(bIsPrivate)));
            oParameters.Add(new ObjectParameter("prwucl_Pinned", GetPIKSCoreBool(bPinned)));
            oParameters.Add(new ObjectParameter("prwucl_CategoryIcon", icon));
            AddAuditTrailParametersForInsert(oParameters, "prwucl");
            int iPRWebUserListID = ExecuteIdentityInsert("PRWebUserList", SQL_PRWEBUSERLIST_INSERT, oParameters, oTran);

            return iPRWebUserListID;
        }

        protected const string SQL_PRWEBUSERLISTDETAIL_INSERT = "INSERT INTO PRWebUserListDetail (prwuld_WebUserListID, prwuld_AssociatedID, prwuld_AssociatedType, prwuld_CreatedBy, prwuld_CreatedDate, prwuld_UpdatedBy, prwuld_UpdatedDate, prwuld_TimeStamp) VALUES ({0},{1},{2},{3},{4},{5},{6},{7})";

        /// <summary>
        /// Inserts a InsertWebUserListDetail record
        /// </summary>
        /// <param name="iWebUserListID"></param>
        /// <param name="iAssociatedID"></param>
        /// <param name="szAssociatedType"></param>
        /// <param name="oTran"></param>
        public void InsertWebUserListDetail(int iWebUserListID,
                                            int iAssociatedID,
                                            string szAssociatedType,
                                     IDbTransaction oTran)
        {


            IPRWebUser oWebuser = (IPRWebUser)_oUser;
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prwuld_WebUserListID", iWebUserListID));
            oParameters.Add(new ObjectParameter("prwuld_AssociatedID", iAssociatedID));
            oParameters.Add(new ObjectParameter("prwuld_AssociatedType", szAssociatedType));
            AddAuditTrailParametersForInsert(oParameters, "prwuld");
            ExecuteIdentityInsert("PRWebUserListDetail", SQL_PRWEBUSERLISTDETAIL_INSERT, oParameters, oTran);
        }

        protected const string SQL_PRPUBLICATIONARTICLE_UPDATE_COUNT = "UPDATE PRPublicationArticle SET prpbar_ViewCount = ISNULL(prpbar_ViewCount, 0) + 1 WHERE prpbar_PublicationArticleID = {0}";

        //protected const string SQL_PRPUBLICAIONARTICLE_HAS_READ =
            //"SELECT 'x' FROM PRPublicationArticleRead WITH (NOLOCK) WHERE prpar_PublicationArticleID={0} AND prpar_WebUserID={1}";

        //protected const string SQL_PRPUBLICAIONARTICLE_HAS_READ_INSERT =
            //"INSERT INTO PRPublicationArticleRead (prpar_PublicationArticleID, prpar_WebUserID, prpar_CreatedBy, prpar_CreatedDate, prpar_UpdatedBy, prpar_UpdatedDate, prpar_TimeStamp) " +
             //"VALUES ({0},{1},{2},{3},{4},{5},{6});";

        /// <summary>
        /// Updates the view count for the specified Article.
        /// </summary>
        /// <param name="iArticleID"></param>
        public void UpdateArticleViewCount(int iArticleID)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prpbar_PublicationArticleID", iArticleID));
            string szSQL = FormatSQL(SQL_PRPUBLICATIONARTICLE_UPDATE_COUNT, oParameters);
            GetDBAccess().ExecuteNonQuery(szSQL, oParameters);
        }

        protected const string SQL_SELECT_RECENT_BPEDITION =
                @"SELECT TOP 1 prpbed_PublicationEditionID 
					FROM PRPublicationEdition (NOLOCK) 
				   WHERE GETDATE() >= prpbed_PublishDate 
				ORDER BY prpbed_PublishDate DESC";

        /// <summary>
        /// Determines what the current BlueprintsEdition ID is.
        /// </summary>
        /// <returns></returns>
        public int GetCurrentBluePrintsEdition()
        {
            object oID = GetDBAccess().ExecuteScalar(SQL_SELECT_RECENT_BPEDITION);

            if (oID == null)
            {
                return 0;
            }

            return Convert.ToInt32(oID);
        }

        protected const string SQL_PRSEARCHWIZARDAUDITTRAIL_INSERT = "INSERT INTO PRSearchWizardAuditTrail (prswau_WebUserID, prswau_CompanyID, prswau_SearchWizardID, prswau_CreatedBy, prswau_CreatedDate, prswau_UpdatedBy, prswau_UpdatedDate, prswau_TimeStamp) VALUES ({0},{1},{2},{3},{4},{5},{6},{7})";
        /// <summary>
        /// Creates the Search Wizard Audit Trail records for the specified
        /// search wizard ID and answers.  The List is to be in order of the questions
        /// with the index being the question number. Index 0 is skipped so this should
        /// be a 1-based list.
        /// </summary>
        /// <param name="iSearchWizardID"></param>
        /// <param name="lSearchWizardAnswers"></param>
        /// <param name="oTran"></param>
        /// <returns></returns>
        public int InsertSearchWizardAuditTrail(int iSearchWizardID, List<string> lSearchWizardAnswers, IDbTransaction oTran)
        {

            IPRWebUser oUser = (IPRWebUser)_oUser;
            //int iSearchWizardAuditTrailID = GetRecordID("PRSearchWizardAuditTrail", oTran);

            ArrayList oParameters = new ArrayList();
            //oParameters.Add(new ObjectParameter("prswau_SearchWizardAuditTrailID", iSearchWizardAuditTrailID));
            oParameters.Add(new ObjectParameter("prswau_WebUserID", oUser.UserID));
            oParameters.Add(new ObjectParameter("prswau_CompanyID", oUser.prwu_BBID));
            oParameters.Add(new ObjectParameter("prswau_SearchWizardID", iSearchWizardID));
            AddAuditTrailParametersForInsert(oParameters, "prswau");
            int iSearchWizardAuditTrailID = ExecuteIdentityInsert("PRSearchWizardAuditTrail", SQL_PRSEARCHWIZARDAUDITTRAIL_INSERT, oParameters, oTran);

            for (int i = 1; i < lSearchWizardAnswers.Count; i++)
            {
                InsertSearchWizardAuditTrailDetail(iSearchWizardAuditTrailID, i, lSearchWizardAnswers[i], oTran);
            }

            return iSearchWizardAuditTrailID;
        }

        protected const string SQL_PRSEARCHWIZARDAUDITTRAILDETAIL_INSERT = "INSERT INTO PRSearchWizardAuditTrailDetail (prswaud_SearchWizardAuditTrailID, prswaud_Question, prswaud_Answer, prswaud_CreatedBy, prswaud_CreatedDate, prswaud_UpdatedBy, prswaud_UpdatedDate, prswaud_TimeStamp) VALUES ({0},{1},{2},{3},{4},{5},{6},{7})";

        /// <summary>
        /// Inserts the PRSearchWizardAuditTrailDetail records.
        /// </summary>
        /// <param name="iSearchWizardAuditTrailID"></param>
        /// <param name="iQuestion"></param>
        /// <param name="szAnswer"></param>
        /// <param name="oTran"></param>
        protected void InsertSearchWizardAuditTrailDetail(int iSearchWizardAuditTrailID, int iQuestion, string szAnswer, IDbTransaction oTran)
        {
            ArrayList oParameters = new ArrayList();
            //oParameters.Add(new ObjectParameter("prswaud_SearchWizardAuditTrailDetailID", GetRecordID("PRSearchWizardAuditTrailDetail", oTran)));
            oParameters.Add(new ObjectParameter("prswaud_SearchWizardAuditTrailID", iSearchWizardAuditTrailID));
            oParameters.Add(new ObjectParameter("prswaud_Question", iQuestion));
            oParameters.Add(new ObjectParameter("prswaud_Answer", szAnswer));
            AddAuditTrailParametersForInsert(oParameters, "prswaud");
            ExecuteIdentityInsert("PRSearchWizardAuditTrailDetail", SQL_PRSEARCHWIZARDAUDITTRAILDETAIL_INSERT, oParameters, oTran);
        }

        protected const string SQL_PRSOCIALMEDIA_INSERT = "INSERT INTO PRSocialMedia (prsm_CompanyID, prsm_SocialMediaTypeCode, prsm_URL, prsm_CreatedBy, prsm_CreatedDate, prsm_UpdatedBy, prsm_UpdatedDate, prsm_TimeStamp) VALUES ({0},{1},{2},{3},{4},{5},{6},{7})";
        public void InsertSocialMedia(int companyID, string typeCode, string url, IDbTransaction oTran)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prsm_CompanyID", companyID));
            oParameters.Add(new ObjectParameter("prsm_SocialMediaTypeCode", typeCode));
            oParameters.Add(new ObjectParameter("prsm_URL", url));
            AddAuditTrailParametersForInsert(oParameters, "prsm");
            ExecuteIdentityInsert("PRSocialMedia", SQL_PRSOCIALMEDIA_INSERT, oParameters, oTran);
        }

        protected const string SQL_PRSOCIALMEDIA_UPDATE = "UPDATE PRSocialMedia SET prsm_URL={1}, prsm_UpdatedBy={2}, prsm_UpdatedDate={3}, prsm_TimeStamp={4} WHERE prsm_SocialMediaID={0}";
        public void UpdateSocialMedia(int recordID, string url, IDbTransaction oTran)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prsm_SocialMediaID", recordID));
            oParameters.Add(new ObjectParameter("prsm_URL", url));
            AddAuditTrailParametersForUpdate(oParameters, "prsm");
            GetDBAccess().ExecuteNonQuery(FormatSQL(SQL_PRSOCIALMEDIA_UPDATE, oParameters), oParameters, oTran);
        }

        protected const string SQL_PRSOCIALMEDIA_DELETE = "DELETE FROM PRSocialMedia WHERE prsm_SocialMediaID={0}";
        public void DeleteSocialMedia(int recordID, IDbTransaction oTran)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prsm_SocialMediaID", recordID));
            GetDBAccess().ExecuteNonQuery(FormatSQL(SQL_PRSOCIALMEDIA_DELETE, oParameters), oParameters, oTran);
        }

        protected const string SQL_PRLINKEDINAUDITTRAIL_INSERT = "INSERT INTO PRLinkedInAuditTrail (prliat_WebUserID, prliat_SubjectCompanyID, prliat_APIMethod, prliat_SearchCount, prliat_TotalResultCount, prliat_UserResultCount, prliat_PrivateCount, prliat_ExceededThreshold,  prliat_CreatedBy, prliat_CreatedDate, prliat_UpdatedBy, prliat_UpdatedDate, prliat_TimeStamp) VALUES ({0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12})";
        public void InsertLinkedInAuditTrail(int subjectCompanyID, string apiMethod, int searchCount, int totalResultCount, int userResultCount, int privateCount, bool exceededThreshold, IDbTransaction oTran)
        {
            IPRWebUser oUser = (IPRWebUser)_oUser;

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prliat_WebUserID", oUser.prwu_WebUserID));
            oParameters.Add(new ObjectParameter("prliat_SubjectCompanyID", subjectCompanyID));
            oParameters.Add(new ObjectParameter("prliat_APIMethod", apiMethod));
            oParameters.Add(new ObjectParameter("prliat_SearchCount", searchCount));
            oParameters.Add(new ObjectParameter("prliat_TotalResultCount", totalResultCount));
            oParameters.Add(new ObjectParameter("prliat_UserResultCount", userResultCount));
            oParameters.Add(new ObjectParameter("prliat_PrivateCount", privateCount));
            oParameters.Add(new ObjectParameter("prliat_ExceededThreshold", GetPIKSCoreBool(exceededThreshold)));
            AddAuditTrailParametersForInsert(oParameters, "prliat");
            ExecuteIdentityInsert("PRLinkedInAuditTrail", SQL_PRLINKEDINAUDITTRAIL_INSERT, oParameters, oTran);
        }

        #region Base Class Required Methods


        /// <summary>
        /// Creates an instance of the PRWebUser business object
        /// </summary>
        /// <returns>IBusinessObject</returns>
        override protected IBusinessObject InstantiateBusinessObject(IDictionary oData)
        {
            return null;
        }

        /// <summary>
        /// The name of the table our business object
        /// is mapped to.
        /// </summary>
        /// <returns>Table Name</returns>
        override public string GetTableName()
        {
            return null;
        }

        /// <summary>
        /// The name of the business object class.
        /// </summary>
        /// <returns>Business Object Name</returns>
        override public string GetBusinessObjectName()
        {
            return null;
        }

        /// <summary>
        /// The fields that uniquly identify this object.
        /// </summary>
        /// <returns>IList</returns>
        override public IList GetKeyFields()
        {
            return null;
        }
        #endregion


        private const string SQL_RECORD_EXISTS_PRWEBUSERLISTDETAIL =
            @"SELECT 'x' 
			   FROM PRWebUserListDetail WITH (NOLOCK) 
			  WHERE prwuld_WebUserListID = {0} 
				AND prwuld_AssociatedID = {1} 
				AND prwuld_AssociatedType = 'C'";

        /// <summary>
        /// Helper method to determine if the a PRWebUserListDetail record currently exists
        /// for the given web user list id and company id.
        /// </summary>
        /// <param name="iListID"></param>
        /// <param name="iCompanyID"></param>
        /// <param name="oTran"></param>
        /// <returns></returns>
        public static bool PRWebUserListDetailRecordExists(int iListID, int iCompanyID, IDbTransaction oTran)
        {
            bool bRecordFound = false;
            ArrayList oParameters = new ArrayList();
            string szSQL = string.Format(SQL_RECORD_EXISTS_PRWEBUSERLISTDETAIL, iListID, iCompanyID);

            IDBAccess oDataAccess = DBAccessFactory.getDBAccessProvider();
            oDataAccess.Logger = LoggerFactory.GetLogger(); //_oLogger;

            object result = oDataAccess.ExecuteScalar(szSQL, oParameters, oTran);

            if ((result == DBNull.Value) ||
                (result == null))
                bRecordFound = false;
            else
                bRecordFound = true;

            return bRecordFound;
        }

        public void AddPRWebUserListDetail(int iListID, int iCompanyID, int iAUSListID, IDbTransaction oTran)
        {
            InsertWebUserListDetail(iListID, iCompanyID, "C", oTran);

            // If a company is being added to the AUS list, then also
            // make sure a relationship is created
            if (iListID == iAUSListID)
            {
                // Invoke stored procedure usp_UpdateCompanyRelationship to update/insert 
                // or remove company relationship records
                ArrayList oParameters = new ArrayList();

                oParameters.Add(new ObjectParameter("LeftCompanyId", ((IPRWebUser)_oUser).prwu_BBID));
                oParameters.Add(new ObjectParameter("RightCompanyId", iCompanyID));
                oParameters.Add(new ObjectParameter("RelationshipTypes", "23"));
                oParameters.Add(new ObjectParameter("Action", 0));
                oParameters.Add(new ObjectParameter("CRMUserID", ((IPRWebUser)_oUser).prwu_WebUserID));

                try
                {
                    GetDBAccess().ExecuteNonQuery("usp_UpdateCompanyRelationship", oParameters, oTran, CommandType.StoredProcedure);
                }
                catch (Exception eX)
                {
                    // There's nothing the end user can do about this so
                    // just log it and keep moving.
                    LogError(eX);

                    if (Utilities.GetBoolConfigValue("ThrowDevExceptions", false))
                    {
                        throw;
                    }
                }
            }
        }

        private const string SQL_DELETE_PRWEBUSERLISTDETAIL =
            @"DELETE FROM PRWebUserListDetail 
               WHERE prwuld_WebUserListID = {0}
                 AND prwuld_AssociatedID = {1}
                 AND prwuld_AssociatedType = 'C'";

        /// <summary>
        /// Deleted the corresponding PRWebUserListDetail Record.
        /// </summary>
        /// <param name="iListID"></param>
        /// <param name="iAssocCompanyID"></param>
        /// <param name="oTran"></param>
        public void DeletePRWebUserListDetail(int iListID, int iAssocCompanyID, IDbTransaction oTran)
        {
            ArrayList oParameters = new ArrayList();

            oParameters.Add(new ObjectParameter("prwuld_WebUserListID", iListID));
            oParameters.Add(new ObjectParameter("prwuld_AssociatedID", iAssocCompanyID));

            string szSQL = FormatSQL(SQL_DELETE_PRWEBUSERLISTDETAIL, oParameters);
            GetDBAccess().ExecuteNonQuery(szSQL, oParameters, oTran);
        }


        private const string SQL_UPDATE_PRWEBUSERLIST_UPDATEINFO =
            @"UPDATE PRWebUserList 
				 SET prwucl_UpdatedBy={0}, prwucl_UpdatedDate={1} 
			   WHERE prwucl_WebUserListID = {2}";

        /// <summary>
        /// Updates the lasted updated by and last updated date field on the existing PRWebUserList 
        /// record.
        /// </summary>
        /// <param name="iListID"></param>
        /// <param name="oTran"></param>
        public void UpdatePRWebUserList(int iListID, IDbTransaction oTran)
        {
            ArrayList oParameters = new ArrayList();

            oParameters.Add(new ObjectParameter("prwucl_UpdatedBy", ((IPRWebUser)_oUser).prwu_WebUserID));
            oParameters.Add(new ObjectParameter("prwucl_UpdatedDate", DateTime.Now));
            oParameters.Add(new ObjectParameter("prwucl_WebUserListID", iListID));

            string szSQL = FormatSQL(SQL_UPDATE_PRWEBUSERLIST_UPDATEINFO, oParameters);
            GetDBAccess().ExecuteNonQuery(szSQL, oParameters, oTran);
        }


        protected const string SQL_OPPORTUNITY_INSERT =
            @"INSERT INTO Opportunity (oppo_OpportunityID, oppo_PrimaryCompanyID, oppo_AssignedUserID, oppo_Type, oppo_Source, oppo_Note, oppo_Opened, oppo_Status, oppo_Stage, oppo_PRWebUserID, oppo_PRPipeline, oppo_PRTrigger, oppo_CreatedBy, oppo_CreatedDate, oppo_UpdatedBy, oppo_UpdatedDate, oppo_TimeStamp) 
			   VALUES ({0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16})";

        /// <summary>
        /// Creates an opporotunity record for those web users that have
        /// requested it.
        /// </summary>
        /// <param name="webUser"></param>
        /// <param name="oTran"></param>
        public void InsertMbrshipMoreInfoOppo(IPRWebUser webUser, IDbTransaction oTran)
        {

            int specialistID = GetPRCoSpecialistID(webUser.prwu_City, webUser.prwu_StateID, PRCO_SPECIALIST_INSIDE_SALES, webUser.prwu_IndustryType, oTran);
            if (specialistID == 0)
            {
                specialistID = Utilities.GetIntConfigValue("MbrshipMoreInfoSpecialistID", 43);
            }

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("oppo_OpportunityID", GetRecordID("Opportunity", oTran)));
            oParameters.Add(new ObjectParameter("oppo_PrimaryCompanyID", webUser.prwu_BBID));
            oParameters.Add(new ObjectParameter("oppo_AssignedUserID", specialistID));
            oParameters.Add(new ObjectParameter("oppo_Type", "NEWM"));
            oParameters.Add(new ObjectParameter("oppo_Source", "IB"));
            oParameters.Add(new ObjectParameter("oppo_Note", "Created via the BBOS."));
            oParameters.Add(new ObjectParameter("oppo_Opened", DateTime.Now));
            oParameters.Add(new ObjectParameter("oppo_Status", "Open"));
            oParameters.Add(new ObjectParameter("oppo_Stage", "Prospect"));
            oParameters.Add(new ObjectParameter("oppo_PRWebUserID", webUser.prwu_WebUserID));
            oParameters.Add(new ObjectParameter("oppo_PRPipeline", "M:BBOS"));
            oParameters.Add(new ObjectParameter("oppo_PRTrigger", "PIPE"));

            AddAuditTrailParametersForInsert(oParameters, "oppo");

            GetDBAccessFullRights().ExecuteNonQuery(FormatSQL(SQL_OPPORTUNITY_INSERT, oParameters), oParameters, null);
        }


        protected const string SQL_COMMUNICATION_LOG_INSERT =
            @"INSERT INTO PRCommunicationLog (prcoml_CompanyID, prcoml_PersonID, prcoml_AttachmentName, prcoml_Source, prcoml_Subject, prcoml_MethodCode, prcoml_CreatedBy, prcoml_CreatedDate, prcoml_UpdatedBy, prcoml_UpdatedDate, prcoml_Timestamp) 
			   VALUES ({0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10})";

        public void InsertCommunicationLog(string attachmentName, string source, string subject)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prcoml_CompanyID", ((IPRWebUser)User).prwu_BBID));
            oParameters.Add(new ObjectParameter("prcoml_PersonID", ((IPRWebUser)User).peli_PersonID));
            oParameters.Add(new ObjectParameter("prcoml_AttachmentName", attachmentName));
            oParameters.Add(new ObjectParameter("prcoml_Source", source));
            oParameters.Add(new ObjectParameter("prcoml_Subject", subject));
            oParameters.Add(new ObjectParameter("prcoml_MethodCode", "EmailOut"));
            AddAuditTrailParametersForInsert(oParameters, "prcoml");

            GetDBAccessFullRights().ExecuteNonQuery(FormatSQL(SQL_COMMUNICATION_LOG_INSERT, oParameters), oParameters, null);
        }


        protected const string SQL_HAS_ALL_NHA_VIDEOS_BEEN_RATED =
            @"SELECT COUNT(distinct prpbar_PublicationArticleID) As ArticleCount, COUNT(DISTINCT prsr_PublicationArticleID) As RatingCount
				FROM PRPublicationArticle WITH (NOLOCK)
					 LEFT OUTER JOIN PRSurveyResponse ON prpbar_PublicationArticleID = prsr_PublicationArticleID AND prsr_WebUserID={0}
			   WHERE prpbar_PublicationCode = 'NHA' 
				 AND prpbar_PublishDate < GETDATE()
				 AND prpbar_IndustryTypeCode LIKE {1}";


        /// <summary>
        /// Determines if the current user has rated all of the published NHA videos
        /// </summary>
        /// <returns></returns>
        public bool HasRatedAllNHAVideos()
        {
            bool hasRatedAll = false;

            ArrayList parameters = new ArrayList();
            parameters.Add(new ObjectParameter("prsr_WebUserID", ((IPRWebUser)User).prwu_WebUserID));
            parameters.Add(new ObjectParameter("prpbar_IndustryTypeCode", "%," + ((IPRWebUser)User).prwu_IndustryType + ",%"));

            using (IDataReader reader = GetDBAccess().ExecuteReader(FormatSQL(SQL_HAS_ALL_NHA_VIDEOS_BEEN_RATED, parameters),
                                                                    parameters))
            {
                while (reader.Read())
                {
                    if ((reader.GetInt32(0) - reader.GetInt32(1)) == 0)
                    {
                        hasRatedAll = true;
                    }
                }
            }

            return hasRatedAll;
        }


        /// <summary>
        /// Helper method that returns names/descriptions
        /// for the specified product IDs.
        /// </summary>
        /// <returns></returns>
        public string GetProductDescriptions(CreditCardPaymentInfo oCCPaymentInfo)
        {
            string szProductIDs = string.Empty;
            foreach (CreditCardProductInfo oProductInfo in oCCPaymentInfo.Products)
            {
                if (szProductIDs.Length > 0)
                {
                    szProductIDs += ",";
                }
                szProductIDs += oProductInfo.ProductID.ToString();
            }

            Hashtable htProductName = new Hashtable();

            string szSQL = "SELECT Prod_ProductID, RTRIM(ISNULL(" + GetLocalizedColName("prod_name") + ", prod_Name)) AS prod_name FROM NewProduct WHERE Prod_ProductID IN (" + szProductIDs + ")";


            using (IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection))
            {
                while (oReader.Read())
                {
                    htProductName.Add(oReader.GetInt32(0), (oReader.GetString(1)));
                }

            }

            StringBuilder sbProductDescription = new StringBuilder();
            foreach (CreditCardProductInfo oProductInfo in oCCPaymentInfo.Products)
            {
                if (sbProductDescription.Length > 0)
                {
                    sbProductDescription.Append("<br />");
                }

                sbProductDescription.Append(oProductInfo.Quantity.ToString());
                sbProductDescription.Append(" - ");
                sbProductDescription.Append((string)htProductName[oProductInfo.ProductID]);

                oProductInfo.Name = (string)htProductName[oProductInfo.ProductID];


                // Handle Company Updates
                if (oProductInfo.ProductID == Utilities.GetIntConfigValue("ExpressUpdateProductID", 21))
                {
                    sbProductDescription.Append(" (" + new Custom_CaptionMgr(this).GetMeaning("prmp_DeliveryCode", oProductInfo.DeliveryCode) + ": " + oProductInfo.DeliveryDestination + ")");
                    oProductInfo.Name += " (" + new Custom_CaptionMgr(this).GetMeaning("prmp_DeliveryCode", oProductInfo.DeliveryCode) + ": " + oProductInfo.DeliveryDestination + ")";
                }
            }

            return sbProductDescription.ToString();
        }

        protected const string SQL_PRMEMBERSHIPPURCHASE_INSERT =
            @"INSERT INTO PRMembershipPurchase 
                     (prmp_PaymentID, prmp_ProductID, prmp_Quantity, prmp_DeliveryCode, prmp_DeliveryDestination, prmp_IndustryType, prmp_HowLearned, prmp_HowLearnedOther, prmp_ReferralPerson, prmp_ReferralCompany, prmp_CreatedBy, prmp_CreatedDate, prmp_UpdatedBy, prmp_UpdatedDate, prmp_Timestamp) 
                VALUES ({0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14})";

        /// <summary>
        /// Creates the PRMembershipPurchase records.
        /// </summary>
        /// <param name="oCCPayment"></param>
        /// <param name="iPaymentID"></param>
        /// <param name="oTran"></param>
        public int ProcessMembership(CreditCardPaymentInfo oCCPayment, int iPaymentID, IDbTransaction oTran)
        {
            int membershipID = 0;
            ArrayList oParameters = new ArrayList();

            foreach (CreditCardProductInfo oProductInfo in oCCPayment.Products)
            {
                oParameters.Clear();
                oParameters.Add(new ObjectParameter("prmp_PaymentID", iPaymentID));
                oParameters.Add(new ObjectParameter("prmp_ProductID", oProductInfo.ProductID));
                oParameters.Add(new ObjectParameter("prmp_Quantity", oProductInfo.Quantity));
                oParameters.Add(new ObjectParameter("prmp_DeliveryCode", oProductInfo.DeliveryCode));
                oParameters.Add(new ObjectParameter("prmp_DeliveryDestination", oProductInfo.DeliveryDestination));
                oParameters.Add(new ObjectParameter("prmp_IndustryType", oCCPayment.IndustryType));

                // We want to return the ID of the primary membership
                // product purchase.
                if (oProductInfo.ProductFamilyID == Utilities.GetIntConfigValue("MembershipProductFamily", 5))
                {
                    oParameters.Add(new ObjectParameter("prmp_HowLearned", oCCPayment.HowLearned));
                    oParameters.Add(new ObjectParameter("prmp_HowLearnedOther", oCCPayment.HowLearnedOther));
                    oParameters.Add(new ObjectParameter("prmp_ReferralPerson", oCCPayment.ReferralPerson));
                    oParameters.Add(new ObjectParameter("prmp_ReferralCompany", oCCPayment.ReferralCompany));
                }
                else
                {
                    oParameters.Add(new ObjectParameter("prmp_HowLearned", DBNull.Value));
                    oParameters.Add(new ObjectParameter("prmp_HowLearnedOther", DBNull.Value));
                    oParameters.Add(new ObjectParameter("prmp_ReferralPerson", DBNull.Value));
                    oParameters.Add(new ObjectParameter("prmp_ReferralCompany", DBNull.Value));
                }


                AddAuditTrailParametersForInsert(oParameters, "prmp");

                string szSQL = FormatSQL(SQL_PRMEMBERSHIPPURCHASE_INSERT, oParameters);
                int iID = ExecuteIdentityInsert("PRMembershipPurchase", szSQL, oParameters, oTran);


                // We want to return the ID of the primary membership
                // product purchase.
                if (oProductInfo.ProductFamilyID == Utilities.GetIntConfigValue("MembershipProductFamily", 5))
                {
                    membershipID = iID;
                }
            }

            return membershipID;
        }

        private const string SQL_INTERACTION_EXISTS = "SELECT 'x' FROM vCommunication WHERE cmli_comm_CompanyID=@CompanyID AND comm_Subject = @Subject AND Comm_DateTime >= @SinceDate";

        public bool InteractionExists(int companyID, string subject)
        {
            return InteractionExists(companyID, subject, DateTime.Today);
        }
        public bool InteractionExists(int companyID, string subject, DateTime sinceDate)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", companyID));
            oParameters.Add(new ObjectParameter("Subject", subject));
            oParameters.Add(new ObjectParameter("SinceDate", sinceDate));

            string szSQL = FormatSQL(SQL_INTERACTION_EXISTS, oParameters);
            object value = GetDBAccess().ExecuteScalar(szSQL, oParameters);
            if ((value == DBNull.Value) || (value == null))
            {
                return false;
            }
            else
            {
                return true;
            }
        }

        /// <summary>
        /// If the business rules permit, this function generates an email to the user
        /// asking them to fill out a survey about the BR.
        /// </summary>
        public void SendBRSurvey(int iRequestID, int iPersonLinkID, string szCulture, IDbTransaction oTran)
        {
            ArrayList oParameters = new ArrayList();

            oParameters.Add(new ObjectParameter("PersonLinkID", iPersonLinkID));
            oParameters.Add(new ObjectParameter("RequestID", iRequestID));
            oParameters.Add(new ObjectParameter("Culture", szCulture));

            try
            { 
                GetDBAccess().ExecuteNonQuery("usp_SendBusinessReportSurvey", oParameters, oTran, CommandType.StoredProcedure);
            }
            catch (Exception eX)
            {
                // Eat the exception but log it.  There is nothing
                // the user can do, so don't burden them with it.
                _oLogger.LogError("Exception Sending BR Survey Email", eX);
            }
        }
    }
}
