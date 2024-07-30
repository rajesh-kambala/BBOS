/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2010

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CompanySubmission
 Description:	

 Notes:	Created By Sharon Cole on 7/18/2007 3:07:32 PM

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Text;
using System.Xml;
using System.Xml.Serialization;

using TSI.Arch;
using TSI.DataAccess;
using TSI.BusinessObjects;
using TSI.Utils;

using PRCo.EBB.Util;

namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Provides the functionality for the CompanySubmission object
    /// </summary>
    [Serializable]
    public class CompanySubmission 
    {
        protected ILogger _oLogger;
        protected IPRWebUser _oWebUser;
        protected StringBuilder _sbTaskMsg;
        protected GeneralDataMgr _oObjectMgr;
        protected IDBAccess _oDBAccess;

        public int PRWebUserID;
        public int BBID;
        public int IncorporatedInStateID;
        public int IncorporatedInCountryID;

        public string CompanyName;
	    public string IndustryType;
        public string EntityType;
        public string ParentCompanyDetails;
        public string SubsidearyDetails;
        public string FullTimeEmployees;
        public string PartTimeEmployees;
        public string MCNumber;
        public string FFNumber;
        public string Volume;
        public string BranchLocations;
        public string DescriptiveLines;
        public string PACALicense;
        public string CFIALicense;
        public string DRCLicense;
        public string Commodities;
        public string OtherRequests;
        public string LoadUnloadHours;
        public string ShippingSeason;

        public CompanyProfile Profile;

        public List<Address> Addresses;
        public List<Bank> Banks;
        public List<Insurance> InsuranceCarriers;
        public List<InternetAddress> Emails;
        public List<InternetAddress> WebSites;
        public List<Phone> Phones;
	    public List<Classification> Classifications;
	    public List<Brand> Brands;
	    public List<Person> Principals;
	    public List<Person> Personnel;
        public List<Region> TruckingDomesticRegions;
        public List<Region> BuyDomesticRegions;
        public List<Region> SellDomesticRegions;
        public List<Region> BuyInternationalRegions;
        public List<Region> SellInternationalRegions;
        public List<ProductProvided> ProductsProvided;
        public List<ServiceProvided> ServicesProvided;
        public List<Specie> Species;
        
        public DateTime BusinessEstablishedDate;
	    public DateTime IncorporatedDate;

        public bool IsOwned;
        public bool HasSubsidiaries;
        public bool MembershipInterest;

        public bool IsPubliclyTraded;
        public int StockExchangeID;
        public string StockExchange;
        public string StockSymbol;

        public const int UNKNOWN_CITY_ID = -1;

        /// <summary>
        /// Constructor
        /// </summary>
        public CompanySubmission(ILogger oLogger, IPRWebUser oWebUser) {
            _oLogger = oLogger;
            _oWebUser = oWebUser;
        }

        public CompanySubmission() {}

        [XmlIgnore] 
        public ILogger Logger {
            get { return _oLogger; }
            set { _oLogger = value; }
        }

        [XmlIgnore]
        public IPRWebUser WebUser {
            get { return _oWebUser; }
            set { _oWebUser = value; }
        }

        public void AddAddress(Address oAddress) {
            if (Addresses == null) {
                Addresses = new List<Address>();
            }
            Addresses.Add(oAddress);
        }
        
        public Address GetAddress(string szType) {
            if (Addresses == null) {
                return null;
            }
        
            foreach(Address oAddress in Addresses) {
                if (oAddress.Type == szType) {
                    return oAddress;
                }
            }
            
            return null;
        }

        public void RemoveAddress(string szType) {
            Address oFound = null;
            foreach (Address oAddress in Addresses) {
                if (oAddress.Type == szType) {
                    oFound = oAddress;
                }
            }

            if (oFound != null) {
                Addresses.Remove(oFound);
            }
        }


        public void AddInsurance(Insurance oInsurance) {
            if (InsuranceCarriers == null) {
                InsuranceCarriers = new List<Insurance>();
            }
            InsuranceCarriers.Add(oInsurance);
        }

        public Insurance GetInsurance(string szType) {
            if (InsuranceCarriers == null) {
                return null;
            }
        
            foreach (Insurance oInsurance in InsuranceCarriers) {
                if (oInsurance.Type == szType) {
                    return oInsurance;
                }
            }

            return null;
        }

        public void RemoveInsurance(string szType) {
            Insurance oFound = null;
            foreach (Insurance oInsurance in InsuranceCarriers) {
                if (oInsurance.Type == szType) {
                    oFound = oInsurance;
                }
            }

            if (oFound != null) {
                InsuranceCarriers.Remove(oFound);
            }
        }




        public void AddBank(Bank oBank) {
            if (Banks == null) {
                Banks = new List<Bank>();
            }
            Banks.Add(oBank);
        }

        public void AddBrand(Brand oBrand) {
            if (Brands == null) {
                Brands = new List<Brand>();
            }
            Brands.Add(oBrand);
        }

        public void AddPhone(Phone oPhone) {
            if (Phones == null) {
                Phones = new List<Phone>();
            }
            Phones.Add(oPhone);
            oPhone.CountryCode = "1";
        }

        public void AddEmail(InternetAddress oEmail) {
            if (Emails == null) {
                Emails = new List<InternetAddress>();
            }
            oEmail.Type = "E";
            oEmail.Description = "E-Mail";
            Emails.Add(oEmail);
        }

        public void AddWebSite(InternetAddress oWebSite) {
            if (WebSites == null) {
                WebSites = new List<InternetAddress>();
            }
            oWebSite.Type = "W";
            oWebSite.Description = "Web Site";
            WebSites.Add(oWebSite);
        }

        public void AddClassification(Classification oClassification) {
            if (Classifications == null) {
                Classifications = new List<Classification>();
            }
            Classifications.Add(oClassification);
        }

        public void AddProductProvided(ProductProvided oProductProvided)
        {
            if (ProductsProvided == null) {
                ProductsProvided = new List<ProductProvided>();
            }
            ProductsProvided.Add(oProductProvided);
        }

        public void AddServiceProvided(ServiceProvided oServiceProvided)
        {
            if (ServicesProvided == null) {
                ServicesProvided = new List<ServiceProvided>();
            }
            ServicesProvided.Add(oServiceProvided);
        }

        public void AddSpecie(Specie oSpecie)
        {
            if (Species == null) {
                Species = new List<Specie>();
            }
            Species.Add(oSpecie);
        }

        public void AddPrincipal(Person oPerson)
        {
            if (Principals == null) {
                Principals = new List<Person>();
            }
            Principals.Add(oPerson);
            oPerson.OwnershipRole = "RCO";
        }

        public void AddPersonnel(Person oPerson) {
            if (Personnel == null) {
                Personnel = new List<Person>();
            }
            Personnel.Add(oPerson);
            oPerson.OwnershipRole = "RCR";
        }

        public void AddTruckingDomesticRegion(Region oRegion) {
            if (TruckingDomesticRegions == null) {
                TruckingDomesticRegions = new List<Region>();
            }
            oRegion.Type = "TrkD";
            TruckingDomesticRegions.Add(oRegion);
        }

        public void AddBuyDomesticRegion(Region oRegion) {
            if (BuyDomesticRegions == null) {
                BuyDomesticRegions = new List<Region>();
            }
            oRegion.Type = "SrcD";
            BuyDomesticRegions.Add(oRegion);
        }

        public void AddSellDomesticRegion(Region oRegion) {
            if (SellDomesticRegions == null) {
                SellDomesticRegions = new List<Region>();
            }
            oRegion.Type = "SellD";
            SellDomesticRegions.Add(oRegion);
        }

        public void AddBuyInternationalRegion(Region oRegion) {
            if (BuyInternationalRegions == null) {
                BuyInternationalRegions = new List<Region>();
            }
            oRegion.Type = "SrcI";
            BuyInternationalRegions.Add(oRegion);
        }

        public void AddSellInternationalRegion(Region oRegion) {
            if (SellInternationalRegions == null) {
                SellInternationalRegions = new List<Region>();
            }
            oRegion.Type = "SellI";
            SellInternationalRegions.Add(oRegion);
        }


        /// <summary>
        /// Serializes the data in the CompanySubmission object
        /// to XML.
        /// </summary>
        /// <param name="oCompanySubmission"></param>
        /// <returns></returns>
        public static string Serialize(CompanySubmission oCompanySubmission) {
            StringBuilder sbXML = new StringBuilder();

            XmlSerializer xs = new XmlSerializer(typeof(CompanySubmission));
            StringWriter xmlTextWriter = new StringWriter(sbXML);
            xs.Serialize(xmlTextWriter, oCompanySubmission);
            xmlTextWriter.Close();

            return sbXML.ToString();
        }

        /// <summary>
        /// Deserializes the specified XML data into a new
        /// CompanySubmission object.
        /// </summary>
        /// <param name="szXML"></param>
        /// <returns></returns>
        public static CompanySubmission Deserialize(string szXML) {

            XmlSerializer xs = new XmlSerializer(typeof(CompanySubmission));
            StringReader xmlStringReader = new StringReader(szXML);

            CompanySubmission oCompanySubmission = (CompanySubmission)xs.Deserialize(xmlStringReader);
            xmlStringReader.Close();

            return oCompanySubmission;
        }

        /// <summary>
        /// Saves the wizard data as an XML stream in
        /// the current user object.
        /// </summary>
        public void SaveWizard() {
            string szXML = CompanySubmission.Serialize(this);
            _oWebUser.prwu_CompanyData = szXML;
            _oWebUser.Save();
        }

        /// <summary>
        /// Refreshes the user object and then populates
        /// this object with the company submission data
        /// XML stream.
        /// </summary>
        public void LoadWizard() {
            _oWebUser.Refresh();
        }

        protected const string SQL_COMPANY_INSERT = "INSERT INTO Company (comp_CompanyID, comp_PRHQID, comp_PRUnconfirmed, comp_Name, comp_PRTradestyle1, comp_PRCorrTradestyle, comp_PRBookTradestyle, comp_PRType, comp_PRListingStatus, comp_PRListingCityID, comp_PRIndustryType, comp_PRUnloadHours, comp_PRMethodSourceReceived, comp_Source, comp_PREBBTermsAcceptedDate, comp_PREBBTermsAcceptedBy, comp_CreatedBy, comp_CreatedDate, comp_UpdatedBy, comp_UpdatedDate, comp_Timestamp) VALUES ({0},{1},{2},{3},{3},{3},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16},{17})";

        /// <summary>
        /// Processes the specified data saving it in the CRM BBS
        /// system.
        /// </summary>
        /// <returns></returns>
        public int ProcessSubmission() {

            _oLogger.RequestName = "SubmitCompanyData";

            // Any object manager will suffice
            _oObjectMgr = new GeneralDataMgr(_oLogger, _oWebUser);
            _oDBAccess = DBAccessFactory.getDBAccessProvider("DBConnectionStringFullRights");
            //_oDBAccess.ConnectionString = Utilities.GetConfigValue("DBConnectionStringFullRights");
            _oDBAccess.Logger = _oLogger;

            // Create the Company record
            int iCompanyID = _oObjectMgr.GetRecordID("Company");

            // Start creating the task message.
            _sbTaskMsg = new StringBuilder();
            _sbTaskMsg.Append("BB # " + iCompanyID.ToString() + " for " + CompanyName + " has been created from the web site." + Environment.NewLine + Environment.NewLine);

            if (BBID > 0) {
                _sbTaskMsg.Append("The user specified a BB # of " + BBID.ToString() + ".  This BB # has not been verified." + Environment.NewLine + Environment.NewLine);
            }

            
            //
            // Look for fuzzy matches of our company name.
            List<Int32> lMatchedCompanyIDs = _oObjectMgr.GetFuzzyMatchCompanyIDs(CompanyName);
            string szMatchedCompanyIDs = string.Empty;
            foreach(int iMatchedCompanyID in lMatchedCompanyIDs) {
                if (szMatchedCompanyIDs.Length > 0) {
                    szMatchedCompanyIDs += ", ";
                }
                szMatchedCompanyIDs += iMatchedCompanyID.ToString();
            }

            if (szMatchedCompanyIDs.Length > 0) {
                _sbTaskMsg.Append("The following BB #s are a fuzzy match for the specified company name: " + szMatchedCompanyIDs + Environment.NewLine);
            }



            // A list to hold the query parameters
            ArrayList oParameters = new ArrayList();

            // Our physical address is also our
            // listing city ID.
            int iListingCityID = UNKNOWN_CITY_ID;
            Address oPhysicalAddress = GetAddress(Address.TYPE_PHYSICAL);
			if (oPhysicalAddress != null)
			{
				iListingCityID = _oObjectMgr.GetCityID(oPhysicalAddress);
			}
			else
			{
				// Fall back to our mailing address
				Address oMailingAddress = GetAddress(Address.TYPE_MAIL);
				if (oMailingAddress != null)
				{
					iListingCityID = _oObjectMgr.GetCityID(oMailingAddress);
				}
			}
    
            if ((iListingCityID == UNKNOWN_CITY_ID) &&
                (oPhysicalAddress != null) &&
                (!string.IsNullOrEmpty(oPhysicalAddress.City))) {
                string szStateAbbr = _oObjectMgr.GetStateAbbr(oPhysicalAddress.StateID);
                _sbTaskMsg.Append("The listing city is 'Unknown'.  The specified physical city is '" + oPhysicalAddress.City + "' with a state of '" + szStateAbbr + "'." + Environment.NewLine);
            }

            if (!string.IsNullOrEmpty(ParentCompanyDetails)) {
                _sbTaskMsg.Append("Parent Company Details: " + ParentCompanyDetails + "." + Environment.NewLine);
            }
            if (!string.IsNullOrEmpty(SubsidearyDetails)) {
                _sbTaskMsg.Append("Subsideary Details: " + SubsidearyDetails + "." + Environment.NewLine);
            }
            if (!string.IsNullOrEmpty(BranchLocations)) {
                _sbTaskMsg.Append("Branch Locations: " + BranchLocations + "." + Environment.NewLine);
            }
            if (!string.IsNullOrEmpty(Commodities)) {
                _sbTaskMsg.Append("Commodities: " + Commodities + "." + Environment.NewLine);
            }

            if ((Profile != null) &&
                (!string.IsNullOrEmpty(Profile.OrganicCertifiedBy)))
            {
                _sbTaskMsg.Append("Organic Certified By: " + Profile.OrganicCertifiedBy + "." + Environment.NewLine);
            }

            if (!string.IsNullOrEmpty(ShippingSeason)) {
                _sbTaskMsg.Append("Shipping Season: " + ShippingSeason + "." + Environment.NewLine);
            }
            if (!string.IsNullOrEmpty(DRCLicense)) {
                _sbTaskMsg.Append("DRC License: " + DRCLicense + "." + Environment.NewLine);
            }
            if (!string.IsNullOrEmpty(PACALicense)) {
                _sbTaskMsg.Append("PACA License: " + PACALicense + "." + Environment.NewLine);
            }
            if (!string.IsNullOrEmpty(CFIALicense)) {
                _sbTaskMsg.Append("CFIA License: " + CFIALicense + "." + Environment.NewLine);
            }
            if (!string.IsNullOrEmpty(MCNumber)) {
                _sbTaskMsg.Append("MC Number: " + MCNumber + "." + Environment.NewLine);
            }

            if (!string.IsNullOrEmpty(StockExchange))
            {
                _sbTaskMsg.Append("Stock Exchange: " + StockExchange + "." + Environment.NewLine);
            }

            if (!string.IsNullOrEmpty(StockSymbol))
            {
                _sbTaskMsg.Append("Stock Symbol: " + StockSymbol + "." + Environment.NewLine);
            }

            if (!string.IsNullOrEmpty(DescriptiveLines)) {
                _sbTaskMsg.Append("\nDescriptive Lines:\n=================\n" + DescriptiveLines + "." + Environment.NewLine);
            }



            // TODO: CHW
            // A method above uses a data reader which closes the connection.
            // The call below to start a transaction fails due to the connection being
            // closed.  We should be getting a new one, but we are not.  Reset our
            // object manager to get a new connection for now.
            _oObjectMgr = new GeneralDataMgr(_oLogger, _oWebUser);
            _oObjectMgr.ConnectionName = "DBConnectionStringFullRights";
            
            IDbTransaction oTran = _oObjectMgr.BeginTransaction();
            try {
                oParameters.Add(new ObjectParameter("comp_CompanyID", iCompanyID));
                oParameters.Add(new ObjectParameter("comp_PRHQID", iCompanyID));
                oParameters.Add(new ObjectParameter("comp_PRUnconfirmed", "Y"));
                oParameters.Add(new ObjectParameter("comp_PRTradeStyle1", CompanyName));
                oParameters.Add(new ObjectParameter("comp_PRType", "H"));
                oParameters.Add(new ObjectParameter("comp_PRListingStatus", Utilities.GetConfigValue("DefaultCompanyPRListingStatus", "N2")));
                oParameters.Add(new ObjectParameter("comp_PRListingCityID", iListingCityID));
                oParameters.Add(new ObjectParameter("comp_PRIndustryType", IndustryType));
                oParameters.Add(new ObjectParameter("comp_PRUnloadHours", LoadUnloadHours));
                oParameters.Add(new ObjectParameter("comp_PRMethodSourceReceived", "W"));
                oParameters.Add(new ObjectParameter("comp_Source", "WEB"));
                oParameters.Add(new ObjectParameter("comp_PREBBTermsAcceptedDate", DateTime.Now));
                oParameters.Add(new ObjectParameter("comp_PREBBTermsAcceptedBy", WebUser.prwu_WebUserID));
                
                _oObjectMgr.AddAuditTrailParametersForInsert(oParameters, "comp");
                _oObjectMgr.ExecuteInsert("Company", SQL_COMPANY_INSERT, oParameters, oTran);

                int iTransactionID = _oObjectMgr.CreatePIKSTransaction(iCompanyID, 0, WebUser.Name, Utilities.GetConfigValue("CompanyDataSubmissionCompanyTransaction", "New unconfirmed company created via web."), oTran);
                _oObjectMgr.CreatePIKSTransactionDetail(iTransactionID, "Company", null, "Insert", null, null, iCompanyID.ToString() + " created.", oTran);

                SaveAddresses(iCompanyID, oTran);
                SaveBanks(iCompanyID, oTran);
                SaveBrands(iCompanyID, oTran);
                SaveBusinessEvents(iCompanyID, oTran);
                SaveClassifications(iCompanyID, oTran);
                SaveCompanyProfile(iCompanyID, oTran);
                SaveInternetAddresses(iCompanyID, 0, Emails, oTran);
                SaveInternetAddresses(iCompanyID, 0, WebSites, oTran);
                SaveRegion(iCompanyID, SellDomesticRegions, oTran);
                SaveRegion(iCompanyID, SellInternationalRegions, oTran);
                SaveRegion(iCompanyID, TruckingDomesticRegions, oTran);
                SaveRegion(iCompanyID, BuyDomesticRegions, oTran);
                SaveRegion(iCompanyID, BuyInternationalRegions, oTran);
                SavePersons(iCompanyID, Personnel, oTran);
                SavePersons(iCompanyID, Principals, oTran);
                SavePhone(iCompanyID, 0, Phones, oTran);
                SaveProductsProvided(iCompanyID, oTran);
                SaveServicesProvided(iCompanyID, oTran);
                SaveSpecies(iCompanyID, oTran);
                _oObjectMgr.ClosePIKSTransaction(iTransactionID, oTran);

                int iAssignedToID = Utilities.GetIntConfigValue("CompanyDataSubmissionUnknownCitySalesID", 24);
                if (iListingCityID != UNKNOWN_CITY_ID) {
                    iAssignedToID = _oObjectMgr.GetPRCoSpecialistID(iCompanyID, GeneralDataMgr.PRCO_SPECIALIST_INSIDE_SALES, oTran);
                }

                if (iAssignedToID == 0)
                {
                    iAssignedToID = Utilities.GetIntConfigValue("CompanyDataSubmissionUnknownCitySalesID", 24);
                    _sbTaskMsg.Append("\n\nNOTE: Unable to find Inside Sales Rep for this company's listing city." + Environment.NewLine);
                }

                _oObjectMgr.CreateTask(iAssignedToID,
                                        "Pending",
                                        _sbTaskMsg.ToString(),
                                        Utilities.GetConfigValue("CompanyDataSubmissionTaskCategory", string.Empty),
                                        Utilities.GetConfigValue("CompanyDataSubmissionTaskSubcategory", string.Empty),
                                        iCompanyID,
                                        0,
                                        oTran);

                _oObjectMgr.Commit();
                return iCompanyID;
            } catch {
                _oObjectMgr.Rollback();
                throw;
            }
        }

        
        protected const string SQL_ADDRESS_INSERT = "INSERT INTO Address (Addr_AddressId, Addr_Address1, Addr_Address2, Addr_Address3, Addr_Address4, Addr_PostCode, addr_PRCityId, Addr_CreatedBy, Addr_CreatedDate, Addr_UpdatedBy, Addr_UpdatedDate, Addr_TimeStamp) VALUES ({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11})";
        protected const string SQL_ADDRESSLINK_INSERT = "INSERT INTO Address_Link (AdLi_AddressLinkId, AdLi_AddressId, AdLi_CompanyID, AdLi_Type, adli_PRDefaultMailing, adli_PRDefaultTax, adLi_CreatedBy, AdLi_CreatedDate, AdLi_UpdatedBy, AdLi_UpdatedDate, AdLi_TimeStamp) VALUES ({0}, {1}, {2}, {3}, {4}, {4}, {5}, {6}, {7}, {8}, {9})";

        /// <summary>
        /// Iterates through the addresses saving them
        /// to BBS CRM.
        /// </summary>
        /// <param name="iCompanyID"></param>
        /// <param name="oTran"></param>
        protected void SaveAddresses(int iCompanyID, IDbTransaction oTran) {

            if (Addresses == null) {
                return;
            }


            ArrayList oParameters = new ArrayList();
            
            foreach (Address oAddress in Addresses) {
                int iAddressID = _oObjectMgr.GetRecordID("Address", oTran);

                oParameters.Clear();    
                oParameters.Add(new ObjectParameter("Addr_AddressId", iAddressID));
                oParameters.Add(new ObjectParameter("Addr_Address1", GetValue(oAddress.Address1)));
                oParameters.Add(new ObjectParameter("Addr_Address2", GetValue(oAddress.Address2)));
                oParameters.Add(new ObjectParameter("Addr_Address3", GetValue(oAddress.Address3)));
                oParameters.Add(new ObjectParameter("Addr_Address4", GetValue(oAddress.Address4)));
                oParameters.Add(new ObjectParameter("Addr_PostCode", GetValue(oAddress.PostalCode)));
                oParameters.Add(new ObjectParameter("addr_PRCityId", _oObjectMgr.GetCityID(oAddress, oTran)));
                _oObjectMgr.AddAuditTrailParametersForInsert(oParameters, "addr");
                _oObjectMgr.ExecuteInsert("Address", SQL_ADDRESS_INSERT, oParameters, oTran);

                oParameters.Clear();
                oParameters.Add(new ObjectParameter("AdLi_AddressLinkId", _oObjectMgr.GetRecordID("Address_Link", oTran)));
                oParameters.Add(new ObjectParameter("AdLi_AddressId", iAddressID));
                oParameters.Add(new ObjectParameter("AdLi_CompanyID", iCompanyID));
                oParameters.Add(new ObjectParameter("AdLi_Type", oAddress.Type));
                
                if (oAddress.Type == Address.TYPE_MAIL) {
                    oParameters.Add(new ObjectParameter("DefaultFlag", "Y"));
                } else {
                    oParameters.Add(new ObjectParameter("DefaultFlag", null));
                }
                
                _oObjectMgr.AddAuditTrailParametersForInsert(oParameters, "adli");
                _oObjectMgr.ExecuteInsert("Address", SQL_ADDRESSLINK_INSERT, oParameters, oTran);

            }
        }


        protected const string SQL_PRCOMPANYBANK_INSERT = "INSERT INTO PRCompanyBank (prcb_CompanyBankId, prcb_CompanyId, prcb_Name, prcb_Address1, prcb_Address2, prcb_City, prcb_State, prcb_PostalCode, prcb_CreatedBy, prcb_CreatedDate, prcb_UpdatedBy, prcb_UpdatedDate, prcb_TimeStamp) VALUES ({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12})";
        /// <summary>
        /// Iterates through the Banks saving them
        /// to BBS CRM.
        /// </summary>
        /// <param name="iCompanyID"></param>
        /// <param name="oTran"></param>
        protected void SaveBanks(int iCompanyID, IDbTransaction oTran) {

            if (Banks == null) {
                return;
            }

            ArrayList oParameters = new ArrayList();

            foreach (Bank oBank in Banks) {
                oParameters.Clear();
                oParameters.Add(new ObjectParameter("prcb_CompanyBankId", _oObjectMgr.GetRecordID("PRCompanyBank", oTran)));
                oParameters.Add(new ObjectParameter("prcb_CompanyId", iCompanyID));
                oParameters.Add(new ObjectParameter("prcb_Name", oBank.Name));
                oParameters.Add(new ObjectParameter("prcb_Address1", GetValue(oBank.Address1)));
                oParameters.Add(new ObjectParameter("prcb_Address2", GetValue(oBank.Address2)));
                oParameters.Add(new ObjectParameter("prcb_City", GetValue(oBank.City)));
                oParameters.Add(new ObjectParameter("prcb_State", _oObjectMgr.GetStateAbbr(oBank.StateID, oTran)));
                oParameters.Add(new ObjectParameter("prcb_PostalCode", GetValue(oBank.PostalCode)));
                _oObjectMgr.AddAuditTrailParametersForInsert(oParameters, "prcb");
                _oObjectMgr.ExecuteInsert("PRCompanyBank", SQL_PRCOMPANYBANK_INSERT, oParameters, oTran);
            }
        }


        protected const string SQL_PRCOMPANYBRAND_INSERT = "INSERT INTO PRCompanyBrand (prc3_CompanyBrandId, prc3_CompanyId, prc3_Brand, prc3_CreatedBy, prc3_CreatedDate, prc3_UpdatedBy, prc3_UpdatedDate, prc3_TimeStamp) VALUES ({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7})";
        /// <summary>
        /// Iterates through the Brands saving them
        /// to BBS CRM.
        /// </summary>
        /// <param name="iCompanyID"></param>
        /// <param name="oTran"></param>
        protected void SaveBrands(int iCompanyID, IDbTransaction oTran) {

            if (Brands == null) {
                return;
            }

            ArrayList oParameters = new ArrayList();

            foreach (Brand oBrand in Brands) {
                oParameters.Clear();

                oParameters.Add(new ObjectParameter("prc3_CompanyBrandId", _oObjectMgr.GetRecordID("PRCompanyBrand", oTran)));
                oParameters.Add(new ObjectParameter("prc3_CompanyId", iCompanyID));
                oParameters.Add(new ObjectParameter("prc3_Brand", oBrand.Name));
                _oObjectMgr.AddAuditTrailParametersForInsert(oParameters, "prc3");
                _oObjectMgr.ExecuteInsert("PRCompanyBrand", SQL_PRCOMPANYBRAND_INSERT, oParameters, oTran);
            }
        }

        protected const string CARRIER = "{0}\n{1}\n{2}\n{3} {4}, {5}";
        protected const string SQL_PRCOMPANYPROFILE_INSERT =
            @"INSERT INTO PRCompanyProfile 
                (prcp_CompanyProfileId, prcp_CompanyId, prcp_AtmosphereStorage, prcp_BkrCollectPct, prcp_BkrCollectRemitForShipper, prcp_BkrConfirmation, 
                 prcp_BkrGroundInspections, prcp_BkrReceive, prcp_BkrTakeFrieght, prcp_BkrTakePossessionPct, prcp_BkrTakeTitlePct, prcp_ColdStorage, 
                 prcp_ColdStorageLeased, prcp_HAACP, prcp_HAACPCertifiedBy, prcp_HumidityStorage, prcp_Organic, prcp_OrganicCertifiedBy, 
                 prcp_OtherCertification, prcp_QTV, prcp_QTVCertifiedBy, prcp_RipeningStorage, prcp_SellBrokersPct, prcp_SellBuyOthers, 
                 prcp_SellCoOpPct, prcp_SellDomesticAccountTypes, prcp_SellDomesticBuyersPct, prcp_SellExportersPct, prcp_SellHomeCenterPct, prcp_SellOfficeWholesalePct, 
                 prcp_SellProDealerPct, prcp_SellRetailYardPct, prcp_SellSecManPct, prcp_SellStockingWholesalePct, prcp_SellWholesalePct, prcp_SrcBuyBrokersPct, 
                 prcp_SrcBuyExportersPct, prcp_SrcBuyMillsPct, prcp_SrcBuyOfficeWholesalePct, prcp_SrcBuySecManPct, prcp_SrcBuyShippersPct, prcp_SrcBuyStockingWholesalePct, 
                 prcp_SrcBuyWholesalePct, prcp_SrcTakePhysicalPossessionPct, prcp_StorageBushel, prcp_StorageCarlots, prcp_StorageCF, prcp_StorageCoveredSF, 
                 prcp_StorageSF, prcp_StorageUncoveredSF, prcp_StorageWarehouses, prcp_TrkrCargoAmount, prcp_TrkrCargoCarrier, prcp_TrkrContainer, 
                 prcp_TrkrDirectHaulsPct, prcp_TrkrDryVan, prcp_TrkrFlatbed, prcp_TrkrLiabilityAmount, prcp_TrkrLiabilityCarrier, prcp_TrkrOther, 
                 prcp_TrkrOtherColdPct, prcp_TrkrOtherWarmPct, prcp_TrkrPiggyback, prcp_TrkrPowerUnits, prcp_TrkrProducePct, prcp_TrkrReefer, 
                 prcp_TrkrTanker, prcp_TrkrTeams, prcp_TrkrTPHaulsPct, prcp_TrkrTrailersLeased, prcp_TrkrTrailersOwned, prcp_TrkrTrucksLeased, 
                 prcp_TrkrTrucksOwned, prcp_Volume, prcp_FTEmployees, prcp_PTEmployees, prcp_RailServiceProvider1, prcp_RailServiceProvider2, 
                 prcp_CreatedBy, prcp_CreatedDate, prcp_UpdatedBy, prcp_UpdatedDate, prcp_TimeStamp) 
         VALUES ({0},{1},{2},{3},{4},{5},{6},
                 {7},{8},{9},{10},{11},{12},
                 {13},{14},{15},{16},{17},{18},
                 {19},{20},{21},{22},{23},{24},
                 {25},{26},{27},{28},{29},{30},
                 {31},{32},{33},{34},{35},{36},
                 {37},{38},{39},{40},{41},{42},
                 {43},{44},{45},{46},{47},{48},
                 {49},{50},{51},{52},{53},{54},
                 {55},{56},{57},{58},{59},{60},
                 {61},{62},{63},{64},{65},{66},
                 {67},{68},{69},{70},{71},{72},
                 {73},{74},{75},{76},{77},{78},
                 {79},{80},{81},{82})";
        /// <summary>
        /// Saves the PRCompanyProfile
        /// to BBS CRM.
        /// </summary>
        /// <param name="iCompanyID"></param>
        /// <param name="oTran"></param>
        protected void  SaveCompanyProfile(int iCompanyID, IDbTransaction oTran) {

            if (Profile == null) {
                return;
            }

            // Supply companies should not have PRCompanyProfile records.
            if (IndustryType == GeneralDataMgr.INDUSTRY_TYPE_SUPPLY)
            {
                return;
            }

            ArrayList oParameters = new ArrayList();

            oParameters.Add(new ObjectParameter("prcp_CompanyProfileId", _oObjectMgr.GetRecordID("PRCompanyProfile", oTran)));
            oParameters.Add(new ObjectParameter("prcp_CompanyId", iCompanyID));

            switch(IndustryType) {
                case GeneralDataMgr.INDUSTRY_TYPE_PRODUCE:
                    oParameters.Add(new ObjectParameter("prcp_AtmosphereStorage", _oObjectMgr.GetPIKSCoreBool(Profile.AtmosphereStorage)));
                    oParameters.Add(new ObjectParameter("prcp_BkrCollectPct", Profile.BkrCollectPct));
                    oParameters.Add(new ObjectParameter("prcp_BkrCollectRemitForShipper", _oObjectMgr.GetPIKSCoreBool(Profile.BkrCollectRemitForShipper)));
                    oParameters.Add(new ObjectParameter("prcp_BkrConfirmation", _oObjectMgr.GetPIKSCoreBool(Profile.BkrConfirmation)));
                    oParameters.Add(new ObjectParameter("prcp_BkrGroundInspections", _oObjectMgr.GetPIKSCoreBool(Profile.BkrGroundInspections)));
                    oParameters.Add(new ObjectParameter("prcp_BkrReceive", Profile.BkrReceive));
                    oParameters.Add(new ObjectParameter("prcp_BkrTakeFrieght", _oObjectMgr.GetPIKSCoreBool(Profile.BkrTakeFrieght)));
                    oParameters.Add(new ObjectParameter("prcp_BkrTakePossessionPct", Profile.BkrTakePossessionPct));
                    oParameters.Add(new ObjectParameter("prcp_BkrTakeTitlePct", Profile.BkrTakeTitlePct));
                    oParameters.Add(new ObjectParameter("prcp_ColdStorage", _oObjectMgr.GetPIKSCoreBool(Profile.ColdStorage)));
                    oParameters.Add(new ObjectParameter("prcp_ColdStorageLeased", _oObjectMgr.GetPIKSCoreBool(Profile.ColdStorageLeased)));
                    oParameters.Add(new ObjectParameter("prcp_HAACP", _oObjectMgr.GetPIKSCoreBool(Profile.HAACP)));
                    oParameters.Add(new ObjectParameter("prcp_HAACPCertifiedBy", Profile.HAACPCertifiedBy));
                    oParameters.Add(new ObjectParameter("prcp_HumidityStorage", _oObjectMgr.GetPIKSCoreBool(Profile.HumidityStorage)));
                    oParameters.Add(new ObjectParameter("prcp_Organic", _oObjectMgr.GetPIKSCoreBool(Profile.Organic)));
                    oParameters.Add(new ObjectParameter("prcp_OrganicCertifiedBy", GetValue(Profile.OrganicCertifiedBy)));
                    oParameters.Add(new ObjectParameter("prcp_OtherCertification", GetValue(Profile.OtherCertification)));
                    oParameters.Add(new ObjectParameter("prcp_QTV", _oObjectMgr.GetPIKSCoreBool(Profile.QTV)));
                    oParameters.Add(new ObjectParameter("prcp_QTVCertifiedBy", Profile.QTVCertifiedBy));
                    oParameters.Add(new ObjectParameter("prcp_RipeningStorage", _oObjectMgr.GetPIKSCoreBool(Profile.RipeningStorage)));
                    oParameters.Add(new ObjectParameter("prcp_SellBrokersPct", Profile.SellBrokersPct));
                    oParameters.Add(new ObjectParameter("prcp_SellBuyOthers", _oObjectMgr.GetPIKSCoreBool(Profile.SellBuyOthers)));
                    oParameters.Add(new ObjectParameter("prcp_SellCoOpPct", null));
                    oParameters.Add(new ObjectParameter("prcp_SellDomesticAccountTypes", GetValue(Profile.SellDomesticAccountTypes)));
                    oParameters.Add(new ObjectParameter("prcp_SellDomesticBuyersPct", Profile.SellDomesticBuyersPct));
                    oParameters.Add(new ObjectParameter("prcp_SellExportersPct", Profile.SellExportersPct));
                    oParameters.Add(new ObjectParameter("prcp_SellHomeCenterPct", null));
                    oParameters.Add(new ObjectParameter("prcp_SellOfficeWholesalePct", null));
                    oParameters.Add(new ObjectParameter("prcp_SellProDealerPct", null));
                    oParameters.Add(new ObjectParameter("prcp_SellRetailYardPct", null));
                    oParameters.Add(new ObjectParameter("prcp_SellSecManPct", null));
                    oParameters.Add(new ObjectParameter("prcp_SellStockingWholesalePct", null));
                    oParameters.Add(new ObjectParameter("prcp_SellWholesalePct", Profile.SellWholesalePct));
                    oParameters.Add(new ObjectParameter("prcp_SrcBuyBrokersPct", Profile.SrcBuyBrokersPct));
                    oParameters.Add(new ObjectParameter("prcp_SrcBuyExportersPct", Profile.SrcBuyExportersPct));
                    oParameters.Add(new ObjectParameter("prcp_SrcBuyMillsPct", null));
                    oParameters.Add(new ObjectParameter("prcp_SrcBuyOfficeWholesalePct", null));
                    oParameters.Add(new ObjectParameter("prcp_SrcBuySecManPct", null));
                    oParameters.Add(new ObjectParameter("prcp_SrcBuyShippersPct", Profile.SrcBuyShippersPct));
                    oParameters.Add(new ObjectParameter("prcp_SrcBuyStockingWholesalePct", null));
                    oParameters.Add(new ObjectParameter("prcp_SrcBuyWholesalePct", Profile.SrcBuyWholesalePct));
                    oParameters.Add(new ObjectParameter("prcp_SrcTakePhysicalPossessionPct", null));
                    oParameters.Add(new ObjectParameter("prcp_StorageBushel", GetValue(Profile.StorageBushel)));
                    oParameters.Add(new ObjectParameter("prcp_StorageCarlots", GetValue(Profile.StorageCarlots)));
                    oParameters.Add(new ObjectParameter("prcp_StorageCF", GetValue(Profile.StorageCF)));
                    oParameters.Add(new ObjectParameter("prcp_StorageCoveredSF", null));
                    oParameters.Add(new ObjectParameter("prcp_StorageSF", GetValue(Profile.StorageSF)));
                    oParameters.Add(new ObjectParameter("prcp_StorageUncoveredSF", null));
                    oParameters.Add(new ObjectParameter("prcp_StorageWarehouses", Profile.StorageWarehouses));
                    oParameters.Add(new ObjectParameter("prcp_TrkrCargoAmount", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrCargoCarrier", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrContainer", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrDirectHaulsPct", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrDryVan", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrFlatbed", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrLiabilityAmount", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrLiabilityCarrier", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrOther", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrOtherColdPct", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrOtherWarmPct", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrPiggyback", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrPowerUnits", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrProducePct", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrReefer", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrTanker", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrTeams", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrTPHaulsPct", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrTrailersLeased", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrTrailersOwned", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrTrucksLeased", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrTrucksOwned", null));
                    oParameters.Add(new ObjectParameter("prcp_Volume", GetValue(Volume)));
                    oParameters.Add(new ObjectParameter("prcp_FTEmployees", GetValue(FullTimeEmployees)));
                    oParameters.Add(new ObjectParameter("prcp_PTEmployees", GetValue(PartTimeEmployees)));
                    oParameters.Add(new ObjectParameter("prcp_RailServiceProvider1", null));
                    oParameters.Add(new ObjectParameter("prcp_RailServiceProvider2", null));
                    break;

                case GeneralDataMgr.INDUSTRY_TYPE_TRANSPORTATION:

                    decimal dCargoInsuranceAmount = 0;
                    string szCargoCarrier = null;
                    Insurance oInsurance = GetInsurance("C");
                    if (oInsurance != null)
                    {
                        dCargoInsuranceAmount = oInsurance.Amount;
                        object[] oArgs =  {oInsurance.Name,
                                    oInsurance.Address1,
                                    oInsurance.Address2,
                                    oInsurance.City,
                                    _oObjectMgr.GetStateAbbr(oInsurance.StateID, oTran),
                                    oInsurance.PostalCode};
                        szCargoCarrier = string.Format(CARRIER, oArgs);
                    }

                    decimal dLiablityInsuranceAmount = 0;
                    string szLiablityCarrier = null;
                    oInsurance = GetInsurance("L");
                    if (oInsurance != null)
                    {
                        dLiablityInsuranceAmount = oInsurance.Amount;
                        object[] oArgs = {oInsurance.Name,
                                    oInsurance.Address1,
                                    oInsurance.Address2,
                                    oInsurance.City,
                                    _oObjectMgr.GetStateAbbr(oInsurance.StateID, oTran),
                                    oInsurance.PostalCode};
                        szLiablityCarrier = string.Format(CARRIER, oArgs);
                    }

                    oParameters.Add(new ObjectParameter("prcp_AtmosphereStorage", null));
                    oParameters.Add(new ObjectParameter("prcp_BkrCollectPct", null));
                    oParameters.Add(new ObjectParameter("prcp_BkrCollectRemitForShipper", null));
                    oParameters.Add(new ObjectParameter("prcp_BkrConfirmation", null));
                    oParameters.Add(new ObjectParameter("prcp_BkrGroundInspections", null));
                    oParameters.Add(new ObjectParameter("prcp_BkrReceive", null));
                    oParameters.Add(new ObjectParameter("prcp_BkrTakeFrieght", null));
                    oParameters.Add(new ObjectParameter("prcp_BkrTakePossessionPct", null));
                    oParameters.Add(new ObjectParameter("prcp_BkrTakeTitlePct", null));
                    oParameters.Add(new ObjectParameter("prcp_ColdStorage", null));
                    oParameters.Add(new ObjectParameter("prcp_ColdStorageLeased", null));
                    oParameters.Add(new ObjectParameter("prcp_HAACP", null));
                    oParameters.Add(new ObjectParameter("prcp_HAACPCertifiedBy", null));
                    oParameters.Add(new ObjectParameter("prcp_HumidityStorage", null));
                    oParameters.Add(new ObjectParameter("prcp_Organic", null));
                    oParameters.Add(new ObjectParameter("prcp_OrganicCertifiedBy", null));
                    oParameters.Add(new ObjectParameter("prcp_OtherCertification", null));
                    oParameters.Add(new ObjectParameter("prcp_QTV", null));
                    oParameters.Add(new ObjectParameter("prcp_QTVCertifiedBy", null));
                    oParameters.Add(new ObjectParameter("prcp_RipeningStorage", null));
                    oParameters.Add(new ObjectParameter("prcp_SellBrokersPct", null));
                    oParameters.Add(new ObjectParameter("prcp_SellBuyOthers", null));
                    oParameters.Add(new ObjectParameter("prcp_SellCoOpPct", null));
                    oParameters.Add(new ObjectParameter("prcp_SellDomesticAccountTypes", null));
                    oParameters.Add(new ObjectParameter("prcp_SellDomesticBuyersPct", null));
                    oParameters.Add(new ObjectParameter("prcp_SellExportersPct", null));
                    oParameters.Add(new ObjectParameter("prcp_SellHomeCenterPct", null));
                    oParameters.Add(new ObjectParameter("prcp_SellOfficeWholesalePct", null));
                    oParameters.Add(new ObjectParameter("prcp_SellProDealerPct", null));
                    oParameters.Add(new ObjectParameter("prcp_SellRetailYardPct", null));
                    oParameters.Add(new ObjectParameter("prcp_SellSecManPct", null));
                    oParameters.Add(new ObjectParameter("prcp_SellStockingWholesalePct", null));
                    oParameters.Add(new ObjectParameter("prcp_SellWholesalePct", null));
                    oParameters.Add(new ObjectParameter("prcp_SrcBuyBrokersPct", null));
                    oParameters.Add(new ObjectParameter("prcp_SrcBuyExportersPct", null));
                    oParameters.Add(new ObjectParameter("prcp_SrcBuyMillsPct", null));
                    oParameters.Add(new ObjectParameter("prcp_SrcBuyOfficeWholesalePct", null));
                    oParameters.Add(new ObjectParameter("prcp_SrcBuySecManPct", null));
                    oParameters.Add(new ObjectParameter("prcp_SrcBuyShippersPct", null));
                    oParameters.Add(new ObjectParameter("prcp_SrcBuyStockingWholesalePct", null));
                    oParameters.Add(new ObjectParameter("prcp_SrcBuyWholesalePct", null));
                    oParameters.Add(new ObjectParameter("prcp_SrcTakePhysicalPossessionPct", null));
                    oParameters.Add(new ObjectParameter("prcp_StorageBushel", null));
                    oParameters.Add(new ObjectParameter("prcp_StorageCarlots", null));
                    oParameters.Add(new ObjectParameter("prcp_StorageCF", null));
                    oParameters.Add(new ObjectParameter("prcp_StorageCoveredSF", null));
                    oParameters.Add(new ObjectParameter("prcp_StorageSF", null));
                    oParameters.Add(new ObjectParameter("prcp_StorageUncoveredSF", null));
                    oParameters.Add(new ObjectParameter("prcp_StorageWarehouses", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrCargoAmount", dCargoInsuranceAmount));
                    oParameters.Add(new ObjectParameter("prcp_TrkrCargoCarrier", GetValue(szCargoCarrier)));
                    oParameters.Add(new ObjectParameter("prcp_TrkrContainer", GetValue(Profile.TrkrContainer)));
                    oParameters.Add(new ObjectParameter("prcp_TrkrDirectHaulsPct", Profile.TrkrDirectHaulsPct));
                    oParameters.Add(new ObjectParameter("prcp_TrkrDryVan", GetValue(Profile.TrkrDryVan)));
                    oParameters.Add(new ObjectParameter("prcp_TrkrFlatbed", GetValue(Profile.TrkrFlatbed)));
                    oParameters.Add(new ObjectParameter("prcp_TrkrLiabilityAmount", dLiablityInsuranceAmount));
                    oParameters.Add(new ObjectParameter("prcp_TrkrLiabilityCarrier", GetValue(szLiablityCarrier)));
                    oParameters.Add(new ObjectParameter("prcp_TrkrOther", GetValue(Profile.TrkrOther)));
                    oParameters.Add(new ObjectParameter("prcp_TrkrOtherColdPct", Profile.TrkrOtherColdPct));
                    oParameters.Add(new ObjectParameter("prcp_TrkrOtherWarmPct", Profile.TrkrOtherWarmPct));
                    oParameters.Add(new ObjectParameter("prcp_TrkrPiggyback", GetValue(Profile.TrkrPiggyback)));
                    oParameters.Add(new ObjectParameter("prcp_TrkrPowerUnits", GetValue(Profile.TrkrPowerUnits)));
                    oParameters.Add(new ObjectParameter("prcp_TrkrProducePct", Profile.TrkrProducePct));
                    oParameters.Add(new ObjectParameter("prcp_TrkrReefer", GetValue(Profile.TrkrReefer)));
                    oParameters.Add(new ObjectParameter("prcp_TrkrTanker", GetValue(Profile.TrkrTanker)));
                    oParameters.Add(new ObjectParameter("prcp_TrkrTeams", _oObjectMgr.GetPIKSCoreBool(Profile.TrkrTeams)));
                    oParameters.Add(new ObjectParameter("prcp_TrkrTPHaulsPct", Profile.TrkrTPHaulsPct));
                    oParameters.Add(new ObjectParameter("prcp_TrkrTrailersLeased", GetValue(Profile.TrkrTrailersLeased)));
                    oParameters.Add(new ObjectParameter("prcp_TrkrTrailersOwned", GetValue(Profile.TrkrTrailersOwned)));
                    oParameters.Add(new ObjectParameter("prcp_TrkrTrucksLeased", GetValue(Profile.TrkrTrucksLeased)));
                    oParameters.Add(new ObjectParameter("prcp_TrkrTrucksOwned", GetValue(Profile.TrkrTrucksOwned)));
                    oParameters.Add(new ObjectParameter("prcp_Volume", GetValue(Volume)));
                    oParameters.Add(new ObjectParameter("prcp_FTEmployees", GetValue(FullTimeEmployees)));
                    oParameters.Add(new ObjectParameter("prcp_PTEmployees", GetValue(PartTimeEmployees)));
                    oParameters.Add(new ObjectParameter("prcp_RailServiceProvider1", null));
                    oParameters.Add(new ObjectParameter("prcp_RailServiceProvider2", null));
                    break;

                case GeneralDataMgr.INDUSTRY_TYPE_LUMBER:

                    oParameters.Add(new ObjectParameter("prcp_AtmosphereStorage", null));
                    oParameters.Add(new ObjectParameter("prcp_BkrCollectPct", null));
                    oParameters.Add(new ObjectParameter("prcp_BkrCollectRemitForShipper", null));
                    oParameters.Add(new ObjectParameter("prcp_BkrConfirmation", null));
                    oParameters.Add(new ObjectParameter("prcp_BkrGroundInspections", null));
                    oParameters.Add(new ObjectParameter("prcp_BkrReceive", null));
                    oParameters.Add(new ObjectParameter("prcp_BkrTakeFrieght", null));
                    oParameters.Add(new ObjectParameter("prcp_BkrTakePossessionPct", null));
                    oParameters.Add(new ObjectParameter("prcp_BkrTakeTitlePct", null));
                    oParameters.Add(new ObjectParameter("prcp_ColdStorage", null));
                    oParameters.Add(new ObjectParameter("prcp_ColdStorageLeased", null));
                    oParameters.Add(new ObjectParameter("prcp_HAACP", null));
                    oParameters.Add(new ObjectParameter("prcp_HAACPCertifiedBy", null));
                    oParameters.Add(new ObjectParameter("prcp_HumidityStorage", null));
                    oParameters.Add(new ObjectParameter("prcp_Organic", null));
                    oParameters.Add(new ObjectParameter("prcp_OrganicCertifiedBy", null));
                    oParameters.Add(new ObjectParameter("prcp_OtherCertification", null));
                    oParameters.Add(new ObjectParameter("prcp_QTV", null));
                    oParameters.Add(new ObjectParameter("prcp_QTVCertifiedBy", null));
                    oParameters.Add(new ObjectParameter("prcp_RipeningStorage", null));
                    oParameters.Add(new ObjectParameter("prcp_SellBrokersPct", null));
                    oParameters.Add(new ObjectParameter("prcp_SellBuyOthers", null));
                    oParameters.Add(new ObjectParameter("prcp_SellCoOpPct", Profile.SellCoOpPct));
                    oParameters.Add(new ObjectParameter("prcp_SellDomesticAccountTypes", null));
                    oParameters.Add(new ObjectParameter("prcp_SellDomesticBuyersPct", null));
                    oParameters.Add(new ObjectParameter("prcp_SellExportersPct", Profile.SellExportersPct));
                    oParameters.Add(new ObjectParameter("prcp_SellHomeCenterPct", Profile.SellHomeCenterPct));
                    oParameters.Add(new ObjectParameter("prcp_SellOfficeWholesalePct", Profile.SellOfficeWholesalePct));
                    oParameters.Add(new ObjectParameter("prcp_SellProDealerPct", Profile.SellProDealerPct));
                    oParameters.Add(new ObjectParameter("prcp_SellRetailYardPct", Profile.SellRetailYardPct));
                    oParameters.Add(new ObjectParameter("prcp_SellSecManPct", Profile.SellSecManPct));
                    oParameters.Add(new ObjectParameter("prcp_SellStockingWholesalePct", Profile.SellStockingWholesalePct));
                    oParameters.Add(new ObjectParameter("prcp_SellWholesalePct", null));
                    oParameters.Add(new ObjectParameter("prcp_SrcBuyBrokersPct", null));
                    oParameters.Add(new ObjectParameter("prcp_SrcBuyExportersPct", Profile.SrcBuyExportersPct));
                    oParameters.Add(new ObjectParameter("prcp_SrcBuyMillsPct", Profile.SrcBuyMillsPct));
                    oParameters.Add(new ObjectParameter("prcp_SrcBuyOfficeWholesalePct", Profile.SrcBuyOfficeWholesalePct));
                    oParameters.Add(new ObjectParameter("prcp_SrcBuySecManPct", Profile.SrcBuySecManPct));
                    oParameters.Add(new ObjectParameter("prcp_SrcBuyShippersPct", null));
                    oParameters.Add(new ObjectParameter("prcp_SrcBuyStockingWholesalePct", Profile.SrcBuyStockingWholesalePct));
                    oParameters.Add(new ObjectParameter("prcp_SrcBuyWholesalePct", null));
                    oParameters.Add(new ObjectParameter("prcp_SrcTakePhysicalPossessionPct", Profile.SrcTakePhysicalPossessionPct));
                    oParameters.Add(new ObjectParameter("prcp_StorageBushel", null));
                    oParameters.Add(new ObjectParameter("prcp_StorageCarlots", null));
                    oParameters.Add(new ObjectParameter("prcp_StorageCF", null));
                    oParameters.Add(new ObjectParameter("prcp_StorageCoveredSF", GetValue(Profile.StorageCoveredSF)));
                    oParameters.Add(new ObjectParameter("prcp_StorageSF", null));
                    oParameters.Add(new ObjectParameter("prcp_StorageUncoveredSF", GetValue(Profile.StorageUncoveredSF)));
                    oParameters.Add(new ObjectParameter("prcp_StorageWarehouses", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrCargoAmount", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrCargoCarrier", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrContainer", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrDirectHaulsPct", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrDryVan", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrFlatbed", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrLiabilityAmount", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrLiabilityCarrier", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrOther", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrOtherColdPct", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrOtherWarmPct", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrPiggyback", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrPowerUnits", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrProducePct", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrReefer", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrTanker", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrTeams", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrTPHaulsPct", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrTrailersLeased", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrTrailersOwned", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrTrucksLeased", null));
                    oParameters.Add(new ObjectParameter("prcp_TrkrTrucksOwned", null));
                    oParameters.Add(new ObjectParameter("prcp_Volume", GetValue(Volume)));
                    oParameters.Add(new ObjectParameter("prcp_FTEmployees", GetValue(FullTimeEmployees)));
                    oParameters.Add(new ObjectParameter("prcp_PTEmployees", GetValue(PartTimeEmployees)));
                    //oParameters.Add(new ObjectParameter("prcp_VolumeBoardFeetPerYear", null));
                    //oParameters.Add(new ObjectParameter("prcp_VolumeCarLoadsPerYear", null));
                    //oParameters.Add(new ObjectParameter("prcp_VolumeTruckLoadsPerYear", null));
                    oParameters.Add(new ObjectParameter("prcp_RailServiceProvider1", GetValue(Profile.RailServiceProvider1)));
                    oParameters.Add(new ObjectParameter("prcp_RailServiceProvider2", GetValue(Profile.RailServiceProvider2)));
                    break;
            }            
            _oObjectMgr.AddAuditTrailParametersForInsert(oParameters, "prcp");
            _oObjectMgr.ExecuteInsert("PRCompanyProfile", SQL_PRCOMPANYPROFILE_INSERT, oParameters, oTran);

        }



        protected const string SQL_EMAIL_INSERT = "INSERT INTO Email (Emai_EmailId, Emai_CompanyID, Emai_PersonID, Emai_Type, Emai_EmailAddress, emai_PRWebAddress, emai_PRDescription, Emai_CreatedBy, Emai_CreatedDate, Emai_UpdatedBy, Emai_UpdatedDate, Emai_TimeStamp) VALUES ({0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11})";
        /// <summary>
        /// Iterates through the InternetAddresses saving them
        /// to BBS CRM.
        /// </summary>
        /// <param name="iCompanyID"></param>
        /// <param name="iPersonID"></param>
        /// <param name="lInternetAddresses"></param>
        /// <param name="oTran"></param>
        protected void SaveInternetAddresses(int iCompanyID, int iPersonID, List<InternetAddress> lInternetAddresses, IDbTransaction oTran) {

            if (lInternetAddresses == null) {
                return;
            }

            ArrayList oParameters = new ArrayList();
            foreach (InternetAddress oInternetAddress in lInternetAddresses) {
            
                if (!string.IsNullOrEmpty(oInternetAddress.Address)) {
                    oParameters.Clear();

                    oParameters.Add(new ObjectParameter("emai_EmailId", _oObjectMgr.GetRecordID("Email", oTran)));
                    oParameters.Add(new ObjectParameter("emai_CompanyID", iCompanyID));

                    if (iPersonID > 0) {
                        oParameters.Add(new ObjectParameter("emai_PersonID", iPersonID));
                    } else {
                        oParameters.Add(new ObjectParameter("emai_PersonID", null));
                    }
                    
                    oParameters.Add(new ObjectParameter("emai_Type", oInternetAddress.Type));

                    if (oInternetAddress.Type == "E") {
                        oParameters.Add(new ObjectParameter("emai_EmailAddress", oInternetAddress.Address));
                        oParameters.Add(new ObjectParameter("emai_PRWebAddress", null));
                    } else {
                        oParameters.Add(new ObjectParameter("emai_EmailAddress", null));
                        oParameters.Add(new ObjectParameter("emai_PRWebAddress", oInternetAddress.Address));
                    }

                    oParameters.Add(new ObjectParameter("Emai_PRDescription", oInternetAddress.Description));
                    _oObjectMgr.AddAuditTrailParametersForInsert(oParameters, "emai");
                    _oObjectMgr.ExecuteInsert("Email", SQL_EMAIL_INSERT, oParameters, oTran);
                }
            }
        }


        protected const string SQL_PHONE_INSERT = "INSERT INTO Phone (Phon_PhoneId, Phon_CompanyID, Phon_PersonID, Phon_Type, Phon_CountryCode, Phon_AreaCode, Phon_Number, phon_PRExtension, Phon_CreatedBy, Phon_CreatedDate, Phon_UpdatedBy, Phon_UpdatedDate, Phon_TimeStamp, phon_PRDescription) VALUES ({0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12}, dbo.ufn_GetCustomCaptionValue('Phon_TypeCompany', {3}, 'en-us'))";
        /// <summary>
        /// Iterates through the InternetAddresses saving them
        /// to BBS CRM.
        /// </summary>
        /// <param name="iCompanyID"></param>
        /// <param name="iPersonID"></param>
        /// <param name="lPhones"></param>
        /// <param name="oTran"></param>
        protected void SavePhone(int iCompanyID, int iPersonID, List<Phone> lPhones, IDbTransaction oTran) {

            if (lPhones == null) {
                return;
            }

            ArrayList oParameters = new ArrayList();
            foreach (Phone oPhone in lPhones) {
            
                if (!string.IsNullOrEmpty(oPhone.Number)) {
                
                    oParameters.Clear();

                    oParameters.Add(new ObjectParameter("phon_PhoneId", _oObjectMgr.GetRecordID("Phone", oTran)));
                    oParameters.Add(new ObjectParameter("phon_CompanyID", iCompanyID));

                    if (iPersonID > 0) {
                        oParameters.Add(new ObjectParameter("phon_PersonID", iPersonID));
                    } else {
                        oParameters.Add(new ObjectParameter("phon_PersonID", null));
                    }
                    oParameters.Add(new ObjectParameter("phon_Type", oPhone.Type));
                    oParameters.Add(new ObjectParameter("phon_CountryCode", oPhone.CountryCode));
                    oParameters.Add(new ObjectParameter("phon_AreaCode", oPhone.AreaCode));
                    oParameters.Add(new ObjectParameter("phon_Number", oPhone.Number));
                    oParameters.Add(new ObjectParameter("phon_PRExtension", GetValue(oPhone.Extension)));
                    _oObjectMgr.AddAuditTrailParametersForInsert(oParameters, "phon");
                    _oObjectMgr.ExecuteInsert("Phone", SQL_PHONE_INSERT, oParameters, oTran);
                }
            }
        }


        protected const string SQL_PRCOMPANYCLASSIFICATION_INSERT = "INSERT INTO PRCompanyClassification (prc2_CompanyClassificationId, prc2_CompanyId, prc2_ClassificationId, prc2_CreatedBy, prc2_CreatedDate, prc2_UpdatedBy, prc2_UpdatedDate, prc2_TimeStamp) VALUES ({0},{1},{2},{3},{4},{5},{6},{7})";
        /// <summary>
        /// Iterates through the InternetAddresses saving them
        /// to BBS CRM.
        /// </summary>
        /// <param name="iCompanyID"></param>
        /// <param name="oTran"></param>
        protected void SaveClassifications(int iCompanyID, IDbTransaction oTran) {

            if (Classifications == null) {
                return;
            }

            ArrayList oParameters = new ArrayList();
            foreach (Classification oClassification in Classifications) {
                oParameters.Clear();

                oParameters.Add(new ObjectParameter("prc2_CompanyClassificationId", _oObjectMgr.GetRecordID("PRCompanyClassification", oTran)));
                oParameters.Add(new ObjectParameter("prc2_CompanyId", iCompanyID));
                oParameters.Add(new ObjectParameter("prc2_ClassificationId", oClassification.ClassificationID));
                _oObjectMgr.AddAuditTrailParametersForInsert(oParameters, "prc2");
                _oObjectMgr.ExecuteInsert("PRCompanyClassification", SQL_PRCOMPANYCLASSIFICATION_INSERT, oParameters, oTran);
            }
        }


        protected const string SQL_COMPANYREGION_INSERT = "INSERT INTO PRCompanyRegion (prcd_CompanyRegionId, prcd_CompanyId, prcd_RegionId, prcd_Type, prcd_CreatedBy, prcd_CreatedDate, prcd_UpdatedBy, prcd_UpdatedDate, prcd_TimeStamp) VALUES ({0},{1},{2},{3},{4},{5},{6},{7},{8})";
        /// <summary>
        /// Iterates through the PRCompanyRegion saving them
        /// to BBS CRM.
        /// </summary>
        /// <param name="iCompanyID"></param>
        /// <param name="lRegions"></param>
        /// <param name="oTran"></param>
        protected void SaveRegion(int iCompanyID, List<Region> lRegions, IDbTransaction oTran) {

            if (lRegions == null) {
                return;
            }

            ArrayList oParameters = new ArrayList();
            foreach (Region oRegion in lRegions) {
                oParameters.Clear();

                oParameters.Add(new ObjectParameter("prcd_CompanyRegionId", _oObjectMgr.GetRecordID("PRCompanyRegion", oTran)));
                oParameters.Add(new ObjectParameter("prcd_CompanyId", iCompanyID));
                oParameters.Add(new ObjectParameter("prcd_RegionId", oRegion.RegionID));
                oParameters.Add(new ObjectParameter("prcd_Type", oRegion.Type));
                _oObjectMgr.AddAuditTrailParametersForInsert(oParameters, "prcd");
                _oObjectMgr.ExecuteInsert("PRCompanyRegion", SQL_COMPANYREGION_INSERT, oParameters, oTran);
            }
        }


        protected const string SQL_PERSON_INSERT = "INSERT INTO Person (Pers_PersonId, Pers_PRUnconfirmed, Pers_FirstName, Pers_LastName, Pers_MiddleName, Pers_Suffix, Pers_Source, pers_PRYearBorn, Pers_CreatedBy, Pers_CreatedDate, Pers_UpdatedBy, Pers_UpdatedDate, Pers_Timestamp) VALUES ({0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12})";
        protected const string SQL_PERSONLINK_INSERT = "INSERT INTO Person_Link (PeLi_PersonLinkId, PeLi_PersonId, PeLi_CompanyID, peli_PRTitleCode, peli_PRTitle, peli_PRStatus, peli_PROwnershipRole, peli_PRSubmitTES, peli_PRUpdateCL, peli_PRUseServiceUnits, peli_PRUseSpecialServices, PeLi_CreatedBy, PeLi_CreatedDate, PeLi_UpdatedBy, PeLi_UpdatedDate, PeLi_TimeStamp) VALUES ({0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15})";

        /// <summary>
        /// Iterates through the addresses saving them
        /// to BBS CRM.
        /// </summary>
        /// <param name="iCompanyID"></param>
        /// <param name="lPersons"></param>
        /// <param name="oTran"></param>
        protected void SavePersons(int iCompanyID, List<Person>lPersons, IDbTransaction oTran) {

            if (lPersons == null) {
                return;
            }


            ArrayList oParameters = new ArrayList();
            

            foreach (Person oPerson in lPersons) {
            
                if (!string.IsNullOrEmpty(oPerson.LastName)) {
            
                    int iPersonID = _oObjectMgr.GetRecordID("Person", oTran);
                    StringBuilder sbPersonMsg = new StringBuilder();    

                    oParameters.Clear();
                    oParameters.Add(new ObjectParameter("pers_PersonId", iPersonID));
                    oParameters.Add(new ObjectParameter("pers_PRUnconfirmed", "Y"));
                    oParameters.Add(new ObjectParameter("pers_FirstName", oPerson.FirstName));
                    oParameters.Add(new ObjectParameter("pers_LastName", GetValue(oPerson.LastName)));
                    oParameters.Add(new ObjectParameter("pers_MiddleName", oPerson.MiddleName));
                    oParameters.Add(new ObjectParameter("pers_Suffix", oPerson.Suffix));
                    oParameters.Add(new ObjectParameter("pers_Source", Utilities.GetConfigValue("DefaultPersonSource", "Web")));
                    if (oPerson.Birthdate == DateTime.MinValue) {
                        oParameters.Add(new ObjectParameter("pers_PRYearBorn", null));
                    } else {
                        oParameters.Add(new ObjectParameter("pers_PRYearBorn", oPerson.Birthdate.Year));
                    }
                    _oObjectMgr.AddAuditTrailParametersForInsert(oParameters, "pers");
                    _oObjectMgr.ExecuteInsert("Person", SQL_PERSON_INSERT, oParameters, oTran);

                    int iTransactionID = _oObjectMgr.CreatePIKSTransaction(0, iPersonID, _oWebUser.Name, Utilities.GetConfigValue("CompanyDataSubmissionPersonTransaction", "New person created via web."), oTran);
                    _oObjectMgr.CreatePIKSTransactionDetail(iTransactionID, "Person", null, "Insert", null, null, oPerson.FirstName + " " + oPerson.LastName + " created.", oTran);

                    oParameters.Clear();
                    oParameters.Add(new ObjectParameter("peLi_PersonLinkId", _oObjectMgr.GetRecordID("Person_Link", oTran)));
                    oParameters.Add(new ObjectParameter("peLi_PersonId", iPersonID));
                    oParameters.Add(new ObjectParameter("peLi_CompanyID", iCompanyID));
                    oParameters.Add(new ObjectParameter("peli_PRTitleCode", oPerson.TitleCode));
                    oParameters.Add(new ObjectParameter("peli_PRTitle", GetValue(oPerson.FullTitle)));
                    oParameters.Add(new ObjectParameter("peli_PRStatus", Utilities.GetConfigValue("DefaultPersonLinkPRStatus", "1")));
                    oParameters.Add(new ObjectParameter("peli_PROwnershipRole", oPerson.OwnershipRole));
                    oParameters.Add(new ObjectParameter("peli_PRSubmitTES", "Y"));
                    oParameters.Add(new ObjectParameter("peli_PRUpdateCL", "Y"));
                    oParameters.Add(new ObjectParameter("peli_PRUseServiceUnits", "Y"));
                    oParameters.Add(new ObjectParameter("peli_PRUseSpecialServices", "Y"));
                    _oObjectMgr.AddAuditTrailParametersForInsert(oParameters, "peli");
                    _oObjectMgr.ExecuteInsert("Person_Link", SQL_PERSONLINK_INSERT, oParameters, oTran);

                    SavePhone(iCompanyID, iPersonID, oPerson.Phones, oTran);
                    SaveInternetAddresses(iCompanyID, iPersonID, oPerson.Emails, oTran);

                    if (oPerson.DegreeEarnedDate != DateTime.MinValue) {
                        SavePersonEvent(iPersonID, 3, oPerson.DegreeEarnedDate, oPerson.EducationInstitution, oPerson.EducationDegree, oTran);
                    }

                    _oObjectMgr.ClosePIKSTransaction(iTransactionID, oTran);

                    if (oPerson.IsFormerBankruptcy) {
                        sbPersonMsg.Append("This person has had a former bankruptcy.\n");
                    }

                    //
                    // Look for fuzzy matches of our person's name.
                    List<Int32> lMatchedPersonIDs = GetMatchingPersonIDs(oPerson.FirstName, oPerson.LastName, oTran);
                    string szMatchedPersonIDs = string.Empty;
                    foreach (int iMatchedPersonID in lMatchedPersonIDs) {
                        if (szMatchedPersonIDs.Length > 0) {
                            szMatchedPersonIDs += ", ";
                        }
                        szMatchedPersonIDs += iMatchedPersonID.ToString();
                    }

                    if (szMatchedPersonIDs.Length > 0) {
                        sbPersonMsg.Append("The following Person IDs were found having the same name: " + szMatchedPersonIDs + "\n");
                    }

                    if (oPerson.PersonHistory != null) {
                        sbPersonMsg.Append("Person History:\n");
                        sbPersonMsg.Append("==============\n");
                        foreach (PersonHistory oPersonHistory in oPerson.PersonHistory) {
                        
                            if (!string.IsNullOrEmpty(oPersonHistory.CompanyName)) {
                        
                                sbPersonMsg.Append("\nBB #: " + oPersonHistory.BBID.ToString() + "\n");
                                sbPersonMsg.Append("Company Name: " + oPersonHistory.CompanyName + "\n");

                                if (!string.IsNullOrEmpty(oPersonHistory.City)) {
                                    sbPersonMsg.Append("City: " + oPersonHistory.City + "\n");
                                }

                                if (oPersonHistory.StateID > 0) {
                                    sbPersonMsg.Append("State: " + _oObjectMgr.GetStateAbbr(oPersonHistory.StateID, oTran) + "\n");
                                }

                                if (oPersonHistory.StartDate != DateTime.MinValue) {
                                    sbPersonMsg.Append("Start Date: " + oPersonHistory.StartDate.ToShortDateString() + "\n");
                                }

                                if (oPersonHistory.EndDate != DateTime.MinValue) {
                                    sbPersonMsg.Append("End Date: " + oPersonHistory.EndDate.ToShortDateString() + "\n");
                                }

                                sbPersonMsg.Append("Is Active: " + oPersonHistory.IsActive + "\n");
                                sbPersonMsg.Append("Ownership Percentage: " + oPersonHistory.OwnershipPercentage + "\n");

                                if (!string.IsNullOrEmpty(oPersonHistory.TitleCode)) {
                                    sbPersonMsg.Append("Title: " + oPersonHistory.TitleCode + "\n");
                                }
                            }
                        }
                    }


                    if (sbPersonMsg.Length > 0) {
                        _sbTaskMsg.Append("\n**** Person: " + oPerson.FirstName + " " + oPerson.LastName + "****\n");
                        _sbTaskMsg.Append(sbPersonMsg);

                    }
                }
            }
        }

        /// <summary>
        /// Saves the business events for this company.
        /// </summary>
        /// <param name="iCompanyID"></param>
        /// <param name="oTran"></param>
        protected void SaveBusinessEvents(int iCompanyID, IDbTransaction oTran) {
            if (BusinessEstablishedDate != DateTime.MinValue) {
                SaveBusinessEvent(iCompanyID, 9, BusinessEstablishedDate, null, 0, oTran);
            }

            if (IncorporatedDate != DateTime.MinValue) {
                SaveBusinessEvent(iCompanyID, 8, BusinessEstablishedDate, EntityType, IncorporatedInStateID, oTran);
            }
        }


        protected const string SQL_PRBUSINESSEVENT_INSERT = "INSERT INTO PRBusinessEvent (prbe_BusinessEventId, prbe_CompanyId, prbe_BusinessEventTypeId, prbe_EffectiveDate, prbe_DisplayedEffectiveDate, prbe_DisplayedEffectiveDateStyle, prbe_DetailedType, prbe_StateID, prbe_CreatedBy, prbe_CreatedDate, prbe_UpdatedBy, prbe_UpdatedDate, prbe_TimeStamp) VALUES ({0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12})";
        /// <summary>
        /// Saves the specfied business event.
        /// </summary>
        /// <param name="iCompanyID"></param>
        /// <param name="iEventType"></param>
        /// <param name="dtEventDate"></param>
        /// <param name="szDetailType"></param>
        /// <param name="iStateID"></param>
        /// <param name="oTran"></param>
        protected void SaveBusinessEvent(int iCompanyID, 
                                         int iEventType, 
                                         DateTime dtEventDate,
                                         string szDetailType,
                                         int iStateID,
                                         IDbTransaction oTran) {
            
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prbe_BusinessEventId", _oObjectMgr.GetRecordID("PRBusinessEvent", oTran)));
            oParameters.Add(new ObjectParameter("prbe_CompanyId", iCompanyID));
            oParameters.Add(new ObjectParameter("prbe_BusinessEventTypeId", iEventType));
            oParameters.Add(new ObjectParameter("prbe_EffectiveDate", dtEventDate));
            oParameters.Add(new ObjectParameter("prbe_DisplayedEffectiveDate", dtEventDate.ToString("MMMM dd, yyyy")));
            oParameters.Add(new ObjectParameter("prbe_DisplayedEffectiveDateStyle", "0"));
            oParameters.Add(new ObjectParameter("prbe_DetailedType", szDetailType));

            if (iStateID > 0) {
                oParameters.Add(new ObjectParameter("prbe_StateID", iStateID));
            } else {
                oParameters.Add(new ObjectParameter("prbe_StateID", null));
            }

            _oObjectMgr.AddAuditTrailParametersForInsert(oParameters, "prbe");
            _oObjectMgr.ExecuteInsert("PRBusinessEvent", SQL_PRBUSINESSEVENT_INSERT, oParameters, oTran);

        }



        protected const string SQL_PRPERSONEVENT_INSERT = "INSERT INTO PRPersonEvent (prpe_PersonEventId, prpe_PersonId, prpe_PersonEventTypeId, prpe_Date, prpe_EducationalInstitution, prpe_EducationalDegree, prpe_CreatedBy, prpe_CreatedDate, prpe_UpdatedBy, prpe_UpdatedDate, prpe_TimeStamp) VALUES ({0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10})";
        /// <summary>
        /// Saves the specified Person Event.
        /// </summary>
        /// <param name="iPersonID"></param>
        /// <param name="iEventType"></param>
        /// <param name="dtEventDate"></param>
        /// <param name="szEducationalInstitution"></param>
        /// <param name="szDegree"></param>
        /// <param name="oTran"></param>
        protected void SavePersonEvent(int iPersonID,
                                       int iEventType,
                                       DateTime dtEventDate,
                                       string szEducationalInstitution,
                                       string szDegree,
                                       IDbTransaction oTran) {

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prpe_PersonEventId", _oObjectMgr.GetRecordID("PRPersonEvent", oTran)));
            oParameters.Add(new ObjectParameter("prpe_PersonId", iPersonID));
            oParameters.Add(new ObjectParameter("prpe_PersonEventTypeId", iEventType));
            oParameters.Add(new ObjectParameter("prpe_Date", dtEventDate));
            oParameters.Add(new ObjectParameter("prpe_EducationalInstitution", szEducationalInstitution));
            oParameters.Add(new ObjectParameter("prpe_EducationalDegree", szDegree));
            _oObjectMgr.AddAuditTrailParametersForInsert(oParameters, "prpe");
            _oObjectMgr.ExecuteInsert("PRPersonEvent", SQL_PRPERSONEVENT_INSERT, oParameters, oTran);

        }

        protected const string SQL_PERSON_SELECT_MATCH = "SELECT pers_PersonID FROM Person WHERE pers_FirstName = {0} AND pers_LastName = {1}";
        /// <summary>
        /// Helper method that returns the PersonIDs that match
        /// both the first and last names.
        /// </summary>
        /// <param name="szFirstName"></param>
        /// <param name="szLastName"></param>
        /// <param name="oTran"></param>
        /// <returns></returns>
        protected List<Int32> GetMatchingPersonIDs(string szFirstName, string szLastName, IDbTransaction oTran) {

            List<Int32> lMatchedIDs = new List<Int32>();
            
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("pers_FirstName", szFirstName));
            oParameters.Add(new ObjectParameter("pers_LastName", szLastName));

            string szSQL = _oObjectMgr.FormatSQL(SQL_PERSON_SELECT_MATCH, oParameters);
            IDataReader oReader = null;
            try {
                oReader = _oDBAccess.ExecuteReader(szSQL, oParameters, CommandBehavior.Default, oTran);
                while (oReader.Read()) {
                    lMatchedIDs.Add(oReader.GetInt32(0));
                }
            } finally {
                if (oReader != null) {
                    oReader.Close();
                }
            }

            return lMatchedIDs;
        }

        protected const string SQL_PRCOMPANYPRODUCTPROVIDED_INSERT = "INSERT INTO PRCompanyProductProvided (prcprpr_CompanyProductProvidedID, prcprpr_CompanyID, prcprpr_ProductProvidedID, prcprpr_CreatedBy, prcprpr_CreatedDate, prcprpr_UpdatedBy, prcprpr_UpdatedDate, prcprpr_TimeStamp) VALUES ({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7})";
        /// <summary>
        /// Iterates through the Products Provided saving them
        /// to BBS CRM.
        /// </summary>
        /// <param name="iCompanyID"></param>
        /// <param name="oTran"></param>
        protected void SaveProductsProvided(int iCompanyID, IDbTransaction oTran)
        {

            if (ProductsProvided == null) {
                return;
            }

            ArrayList oParameters = new ArrayList();
            foreach (ProductProvided oProductProvided in ProductsProvided) {
                oParameters.Clear();

                oParameters.Add(new ObjectParameter("prcprpr_CompanyProductProvidedID", _oObjectMgr.GetRecordID("PRCompanyProductProvided", oTran)));
                oParameters.Add(new ObjectParameter("prcprpr_CompanyID", iCompanyID));
                oParameters.Add(new ObjectParameter("prcprpr_ProductProvidedID", oProductProvided.ProductProvidedID));
                _oObjectMgr.AddAuditTrailParametersForInsert(oParameters, "prcprpr");
                _oObjectMgr.ExecuteInsert("PRCompanyProductProvided", SQL_PRCOMPANYPRODUCTPROVIDED_INSERT, oParameters, oTran);
            }
        }

        protected const string SQL_PRCOMPANYSERVICEPROVIDED_INSERT = "INSERT INTO PRCompanyServiceProvided (prcserpr_CompanyServiceProvidedID, prcserpr_CompanyID, prcserpr_ServiceProvidedID, prcserpr_CreatedBy, prcserpr_CreatedDate, prcserpr_UpdatedBy, prcserpr_UpdatedDate, prcserpr_TimeStamp) VALUES ({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7})";
        /// <summary>
        /// Iterates through the ServiceProvided saving them
        /// to BBS CRM.
        /// </summary>
        /// <param name="iCompanyID"></param>
        /// <param name="oTran"></param>
        protected void SaveServicesProvided(int iCompanyID, IDbTransaction oTran)
        {

            if (ServicesProvided == null) {
                return;
            }

            ArrayList oParameters = new ArrayList();
            foreach (ServiceProvided oServiceProvided in ServicesProvided) {
                oParameters.Clear();

                oParameters.Add(new ObjectParameter("prcserpr_CompanyServiceProvidedID", _oObjectMgr.GetRecordID("PRCompanyServiceProvided", oTran)));
                oParameters.Add(new ObjectParameter("prcserpr_CompanyID", iCompanyID));
                oParameters.Add(new ObjectParameter("prcserpr_ServiceProvidedID", oServiceProvided.ServiceProvidedID));
                _oObjectMgr.AddAuditTrailParametersForInsert(oParameters, "prcserpr");
                _oObjectMgr.ExecuteInsert("PRCOMPANYSERVICEPROVIDED", SQL_PRCOMPANYSERVICEPROVIDED_INSERT, oParameters, oTran);
            }
        }

        protected const string SQL_PRCOMPANYSPECIES_INSERT = "Insert Into PRCompanySpecie (prcspc_CompanySpecieID,prcspc_CompanyID,prcspc_SpecieID,prcspc_CreatedBy,prcspc_CreatedDate,prcspc_UpdatedBy,prcspc_UpdatedDate,prcspc_TimeStamp) Values ({0},{1},{2},{3},{4},{5},{6},{7});";
        /// <summary>
        /// Iterates through the Species saving them
        /// to BBS CRM.
        /// </summary>
        /// <param name="iCompanyID"></param>
        /// <param name="oTran"></param>
        protected void SaveSpecies(int iCompanyID, IDbTransaction oTran)
        {

            if (Species == null) {
                return;
            }

            ArrayList oParameters = new ArrayList();
            foreach (Specie oSpecie in Species) {
                oParameters.Clear();

                oParameters.Add(new ObjectParameter("prspc_CompanySpecieID", _oObjectMgr.GetRecordID("PRCompanySpecie", oTran)));
                oParameters.Add(new ObjectParameter("prspc_CompanyID", iCompanyID));
                oParameters.Add(new ObjectParameter("prspc_SpecieID", oSpecie.SpecieID));
                _oObjectMgr.AddAuditTrailParametersForInsert(oParameters, "prspc");
                _oObjectMgr.ExecuteInsert("PRCompanySpecies", SQL_PRCOMPANYSPECIES_INSERT, oParameters, oTran);
            }
        }

        protected string GetValue(string szValue)
        {
            if (string.IsNullOrEmpty(szValue))
            {
                return null;
            }

            return szValue;

        }
    }
}


    