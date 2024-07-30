using LumenWorks.Framework.IO.Csv;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;

namespace FoodHubImporter
{
    public class Company : MeisterMediaBase
    {
        // BEGIN NEW
        public string FMID; //MemberID is same as FMID
        public string CompanyName;
        public string Business = null;
        public string MailingAddress1;      //MAILING_ST
        public string MailingCity;              //MAILING_CITY
        public string MailingState;             //MAILING_STATE_FIPS
        public string MailingZip;                   //not MAILING_ZIP -- refresh to map and get this -- use perfect address
        public string MailingCounty;            //refresh to map and get this -- use perfect address

        public string PhysicalAddress1;     //LOCATION_ST
        public string PhysicalCity;             //LOCATION_CITY
        public string PhysicalState;            //LOCATION_STATE_FIPS
        public string PhysicalZip;              //not LOCATION_ZIP -- refresh to map and get this -- use perfect address
        public string PhysicalCounty;           //refresh to map and get this -- use perfect address

        public string MarketPhone;
        public string MarketEmail;
        public string MarketWebsite;
        public string MarketFacebook;
        public string MarketTwitter;
        public string MarketManagerName;
        public string ProductList;

        public string Location_Desc;
        public string EstablishYear;
        public string Legal_Status;
        public string Legal_StatusDesc;
        public string OperationMonthList;
        public string PracticeList;
        public string F2BList;
        public string ProcurementList;
        public string OpserviceList;
        public string PSServiceList;
        // END NEW

        //public bool IsValid = true;
        //public string InvalidReason;
        bool newRecord = false;

        public int CompanyID;
        public int CityID;
        public int StateID;
        public List<Person> Persons = new List<Person>();
        public List<Address> Addresses = new List<Address>();
        public List<Phone> Phones = new List<Phone>();
        public List<Phone> PhoneMatching = new List<Phone>();

        public Company()
        {
        }

        public string GetKey()
        {
            return CompanyName + ":" + MailingCity + ":" + MailingState;
        }

        public bool Load(SqlConnection sqlConn, CsvReader csv, List<string> lstErrors)
        {
            List<string> lstLocalErrors = new List<string>();

            FMID = csv["FMID"]; //MemberID
            CompanyName = csv["MarketName"];
            MailingAddress1 = csv["Mailing_ST"];
            MailingCity = csv["Mailing_City"];
            MailingState = csv["Mailing_StateFIPS"];
            PhysicalAddress1 = csv["Location_ST"];
            PhysicalCity = csv["Location_City"];
            PhysicalState = csv["Location_StateFIPS"];

            MarketPhone = csv["Market_Phone"];
            MarketEmail = csv["Market_Email"];
            MarketWebsite = StripHttpPrefix(csv["Market_Website"]);

            MarketFacebook = csv["Market_Facebook"];
            MarketTwitter = csv["Market_Twitter"];
            MarketManagerName = csv["Market_ManagerName"];
            ProductList = csv["ProductList"];

            AddPhone(csv, "P");
            AddAddress(sqlConn, csv, lstLocalErrors);
            AddPerson(csv);
            AddClassification("Food Hub");
            
            SetCommodities(sqlConn, csv, lstLocalErrors);

            Location_Desc = csv["Location_Desc"];
            EstablishYear = csv["EstablishYear"];
            Legal_Status = csv["Legal_Status"];
            Legal_StatusDesc = csv["Legal_StatusDesc"];
            OperationMonthList = csv["OperationMonthList"];
            PracticeList = csv["PracticeList"];
            F2BList = csv["F2BList"];
            ProcurementList = csv["ProcurementList"];
            OpserviceList = csv["OpserviceList"];
            PSServiceList = csv["PSServiceList"];

            if (lstLocalErrors.Count > 0)
            {
                foreach (string strError in lstLocalErrors)
                    lstErrors.Add(strError);
                return false;
            }

            return true;
        }

        private string StripHttpPrefix(string strUrl)
        {
            string strNewUrl = strUrl;

            string strPrefix = "http://";
            if (strNewUrl.StartsWith(strPrefix))
                strNewUrl = strNewUrl.Substring(strPrefix.Length);

            strPrefix = "https://";
            if (strNewUrl.StartsWith(strPrefix))
                strNewUrl = strNewUrl.Substring(strPrefix.Length);

            if (strNewUrl.EndsWith("/"))
                strNewUrl = strNewUrl.Substring(0, strNewUrl.Length - 1);

            return strNewUrl;
        }

        public void AddPhone(CsvReader csv, string type)
        {
            Phone phone = new Phone();
            phone.Load(csv, type);
            if ((!string.IsNullOrEmpty(phone.Number)) &&
                    (phone.Number.Length >= 10))
            {
                AddPhone(phone);
            }
        }

        public void AddPhone(List<Phone> Phones)
        {
            foreach (Phone phone in Phones)
            {
                AddPhone(phone);
            }
        }

        public void AddPhone(Phone newPhone)
        {
            // Don't add duplicates
            foreach (Phone phone in Phones)
            {
                if (phone.Number == newPhone.Number)
                {

                    if ((phone.Type == "P" && newPhone.Type == "F") ||
                            (phone.Type == "F" && newPhone.Type == "P"))
                    {
                        phone.Type = "PF";
                    }

                    return;
                }
            }

            newPhone.Sequence = Phones.Count + 1;
            newPhone.CompanyID = CompanyID;
            Phones.Add(newPhone);

            PhoneMatching.Add(newPhone);
        }

        public void AddAddress(SqlConnection sqlConn, CsvReader csv, List<string> lstErrors)
        {
            //Mailing address
            Address mailingAddress = new Address();
            mailingAddress.LoadMailing(sqlConn, csv, lstErrors);
            mailingAddress.CompanyID = CompanyID;
            mailingAddress.Sequence = Addresses.Count + 1;
            AddAddress(mailingAddress);

            //Physical address
            Address physicalAddress = new Address();
            physicalAddress.LoadPhysical(sqlConn, csv, lstErrors);
            physicalAddress.CompanyID = CompanyID;
            physicalAddress.Sequence = Addresses.Count + 1;
            AddAddress(physicalAddress);
        }

        public void AddAddress(List<Address> addresses)
        {
            foreach (Address address in addresses)
            {
                AddAddress(address);
            }
        }

        public void AddAddress(Address newAddress)
        {
            // Don't add duplicates
            foreach (Address address in Addresses)
            {


                if ((address.Street1Match == newAddress.Street1Match) &&
                        (address.City.ToLower() == newAddress.City.ToLower()) &&
                        (address.State.ToLower() == newAddress.State.ToLower()))
                {
                    return;
                }
            }

            newAddress.Sequence = Addresses.Count + 1;
            newAddress.CompanyID = CompanyID;
            Addresses.Add(newAddress);

            if (CityID == 0)
            {
                CityID = newAddress.CityID;
                StateID = newAddress.StateID;
            }
        }

        private void SetCityID()
        {
            Dictionary<string, int> cityCount = new Dictionary<string, int>();

            if (Addresses.Count > 1)
            {

                foreach (Address address in Addresses)
                {
                    if (address.CityID > 0)
                    {
                        int cnt;

                        string key = address.CityID.ToString() + "," + address.StateID.ToString();

                        cityCount.TryGetValue(key, out cnt);
                        cityCount[key] = cnt + 1;
                    }
                }

                var sortedList = cityCount.OrderByDescending(key => key.Value);
                string[] work = sortedList.First().Key.Split(',');
                CityID = Convert.ToInt32(work[0]);
                StateID = Convert.ToInt32(work[1]);
            }
        }

        public void AddPerson(CsvReader csv)
        {
            if (string.IsNullOrEmpty(csv["Market_ManagerName"]))
                return;

            Person person = new Person();
            person.Load(csv);
            person.CompanyID = CompanyID;
            person.Sequence = Persons.Count + 1;
            AddPerson(person);
        }

        public void AddPerson(List<Person> persons)
        {
            foreach (Person person in persons)
            {
                AddPerson(person);
            }
        }

        public void AddPerson(Person person)
        {
            person.Sequence = Persons.Count + 1;
            person.CompanyID = CompanyID;
            Persons.Add(person);

            if (person.oPhone != null)
            {
                PhoneMatching.Add(person.oPhone);
            }
        }

        //public void AddDuplicateCompany(Company dupCompany, string key)
        //{
        //	if(!string.IsNullOrEmpty(DuplicateMMWIDs))
        //	{
        //		DuplicateMMWIDs += ", ";
        //	}
        //	DuplicateMMWIDs += dupCompany.MMWID;
        //	Duplicate = true;
        //	MatchkedKey = key;
        //	AddDuplicateCompany(dupCompany);
        //}

        //public void AddDuplicateCompany(Company dupCompany)
        //{
        //	if(dupCompany.CompanyID == 0)
        //	{
        //		dupCompany.CompanyID = CompanyID;
        //	}

        //	dupCompany.IsLocalSource = IsLocalSource;
        //	dupCompany.Skip = true;
        //	DuplicateCompanies.Add(dupCompany);
        //	AddPerson(dupCompany.Persons);
        //	AddCommodity(dupCompany.Commodities);
        //	AddClassification(dupCompany.Business);
        //	AddAddress(dupCompany.Addresses);
        //	AddPhone(dupCompany.Phones);
        //	AddAlsoOperates(dupCompany.AlsoOperates);
        //	AddBusiness(dupCompany.Business);
        //	AddOrganic(dupCompany.Organic);
        //	SetTotalAcres(dupCompany.TotalAcres);

        //	// If the current email is from a generic provider, i.e gmail
        //	// and the dup has one from non-generic provider, then use
        //	// the dup's email
        //	if((!string.IsNullOrEmpty(Email)) &&
        //			(_InternetDomain.Contains(GetInternetDomain())) &&
        //			(!string.IsNullOrEmpty(dupCompany.Email)) &&
        //			(!_InternetDomain.Contains(dupCompany.GetInternetDomain())))
        //	{
        //		Email = dupCompany.Email;
        //	}
        //}

        //public void SetCompanyID(int companyID)
        //{
        //	CompanyID = companyID;

        //	foreach(Company company in DuplicateCompanies)
        //	{
        //		company.CompanyID = CompanyID;
        //		company.IsLocalSource = IsLocalSource;
        //	}

        //	foreach(Person person in Persons)
        //	{
        //		person.CompanyID = CompanyID;
        //	}

        //	foreach(Address address in Addresses)
        //	{
        //		address.CompanyID = CompanyID;
        //	}

        //}

        //private void GetAlsoOperates(string value)
        //{
        //	string[] alsoOperates = value.Split(',');
        //	string alsoOperatesResult = string.Empty;

        //	string tmp = null;
        //	foreach(string alsoOperate in alsoOperates)
        //	{
        //		tmp = GetAlsoOperatesInt(alsoOperate.Trim());
        //		AddAlsoOperates(tmp);
        //	}
        //}

        //private string GetAlsoOperatesInt(string value)
        //{
        //	switch(value)
        //	{
        //		case "600": return "Roadside Market";
        //		case "601": return "Packing Facility";
        //		case "602": return "Greenhouse";
        //	}
        //	return null;
        //}

        //private void AddAlsoOperates(string value)
        //{
        //	if(string.IsNullOrEmpty(value))
        //	{
        //		return;
        //	}

        //	// Don't add duplicates
        //	foreach(string alsoOperates in AlsoOperates)
        //	{
        //		if(alsoOperates == value)
        //		{
        //			return;
        //		}
        //	}
        //	AlsoOperates.Add(value);
        //}

        //private void AddAlsoOperates(List<string> newValues)
        //{
        //	foreach(string newValue in newValues)
        //	{
        //		AddAlsoOperates(newValue);
        //	}
        //}

        //private void GetBusiness(string value)
        //{
        //	string[] businesses = value.Split(',');
        //	foreach(string biz in businesses)
        //	{
        //		switch(biz.Trim())
        //		{
        //			case "100":
        //				AddBusiness("Grower");
        //				break;
        //			case "101":
        //				AddBusiness("Grower/Packer");
        //				break;
        //		}

        //	}
        //}

        //private void AddBusiness(string value)
        //{
        //	// Grower/Packer is all encompassing, so
        //	// if we're already set to that, we're done.
        //	if(Business == "Grower/Packer")
        //		return;

        //	// This works because of the previous conditional.
        //	Business = value;
        //}

        //private string GetFunctionJobTitle(string value)
        //{
        //	switch(value)
        //	{
        //		case "200": return "Senior Mgmt";
        //		case "201": return "General Mgmt";
        //		case "202": return "Production Mgmt";
        //		case "213": return "Sales and Marketing";
        //		case "214": return "Education";
        //		case "219": return "Other";
        //	}
        //	return value;
        //}

        public List<Commodity> Commodities = new List<Commodity>();

        private void SetCommodities(SqlConnection sqlConn, CsvReader csv, List<string> lstErrors)
        {
            if (csv["Jams"] != "0")
            {
                AddCommodity(28, "Jellies");
                AddCommodity(31, "Preserves");
            }

            if (csv["Local_Coffee"] != "0")
                AddCommodity(21, "Coffee");

            if (csv["Local_Flowers"] != "0")
                AddCommodity(14, "Flowers");

            if (csv["Local_Dairy"] != "0")
                AddCommodity(18, "Cheese");

            if (csv["Local_DryBeans"] != "0")
            {
                AddCommodity(424, "Chilibe");
                AddCommodity(425, "Chinbe");
            }

            if (csv["Local_Eggs"] != "0")
                AddCommodity(25, "Eggs");

            if (csv["Local_Herbs"] != "0")
            {
                AddCommodity(248, "Herbs");
                AddCommodity(249, "Basil");
                AddCommodity(250, "Bayleaves");
                AddCommodity(251, "Chervil");
                AddCommodity(252, "Chives");
                AddCommodity(253, "Cilantro");
                AddCommodity(254, "Culantro");
                AddCommodity(255, "Diepca");
                AddCommodity(256, "Dill");
                AddCommodity(257, "Epazote");
                AddCommodity(258, "Fennel");
                AddCommodity(259, "Lgrass");
                AddCommodity(260, "Marjoram");
                AddCommodity(261, "Mint");
                AddCommodity(262, "Pepper");
                AddCommodity(263, "Oregano");
                AddCommodity(264, "Parsley");
                AddCommodity(266, "Rosemary");
                AddCommodity(267, "Sage");
                AddCommodity(268, "Savory");
                AddCommodity(269, "Tarragon");
                AddCommodity(270, "Thyme");
            }

            if (csv["Local_Fruits"] != "0")
                AddCommodity(37, "F");

            if (csv["Local_Vegetables"] != "0")
                AddCommodity(291, "V");

            if (csv["Local_Honey"] != "0")
                AddCommodity(27, "Honey");

            if (csv["Local_Mushrooms"] != "0")
            {
                AddCommodity(501, "M");
                AddCommodity(502, "Shiitake");
                AddCommodity(503, "Morel");
            }

            if (csv["Local_Nuts"] != "0")
            {
                AddCommodity(271, "N");
                AddCommodity(272, "Almonds");
                AddCommodity(273, "Brazilnuts");
                AddCommodity(274, "Cashews");
                AddCommodity(275, "Chestnuts");
                AddCommodity(276, "Italian");
                AddCommodity(277, "Filberts");
                AddCommodity(278, "Hazelnuts");
                AddCommodity(279, "Macadamias");
                AddCommodity(280, "Pn");
                AddCommodity(281, "Green");
                AddCommodity(282, "Pec");
                AddCommodity(283, "Pinen");
                AddCommodity(284, "Pistachios");
                AddCommodity(285, "Walnuts");
                AddCommodity(286, "Regular");
            }

            if (csv["Local_Protein_NonAnim"] != "0")
                AddCommodity(36, "Tofu");

            if (csv["Local_Wine"] != "0")
                AddCommodity(224, "Wine");
        }

        private void AddCommodity(int commodityID, string publishedDisplay)
        {
            Commodity commod = new Commodity(commodityID, publishedDisplay, Commodities.Count + 1);
            Commodities.Add(commod);
        }

        protected const string SQL_COMPANY_INSERT =
                    "INSERT INTO Company (comp_CompanyID, comp_PRHQID, comp_Name, comp_PRTradestyle1, comp_PRCorrTradestyle, comp_PRBookTradestyle, comp_PRType, comp_PRListingStatus, comp_PRListingCityID, comp_PRIndustryType, comp_Source, comp_CreatedBy, comp_CreatedDate, comp_UpdatedBy, comp_UpdatedDate, comp_Timestamp) " +
                        "VALUES (@comp_CompanyID,@comp_CompanyID,@comp_Name,@comp_Name,@comp_Name,@comp_Name,@comp_PRType,@comp_PRListingStatus,@comp_PRListingCityID,@comp_PRIndustryType,@comp_Source, @CreatedBy, @CreatedDate, @UpdatedBy, @UpdatedDate, @Timestamp)";

        protected const string SQL_COMPANY_UPDATE =
                @"UPDATE Company
                 SET comp_Name=@comp_Name, 
                     comp_PRTradestyle1=@comp_Name, 
                     comp_PRCorrTradestyle=@comp_Name, 
                     comp_PRBookTradestyle=@comp_Name, 
                     comp_PRListingStatus=@comp_PRListingStatus,
                     comp_PRListingCityID=@comp_PRListingCityID, 
                     comp_PROnlineOnly = @comp_PROnlineOnly, 
                     comp_PRLocalSource = @comp_PRLocalSource,
                     comp_PRPublishDL = NULL,
                     comp_UpdatedBy=@UpdatedBy, 
                     comp_UpdatedDate=@UpdatedDate, 
                     comp_Timestamp=@Timestamp  
               WHERE comp_CompanyID = @comp_CompanyID";

        public void SaveCompany(SqlTransaction sqlTrans)
        {
            SetCityID();

            int transactionID = 0;

            SqlCommand cmdSave = sqlTrans.Connection.CreateCommand();
            cmdSave.Transaction = sqlTrans;

            if (CompanyID < 100000)
            {
                newRecord = true;
                CompanyID = GetPIKSID("Company", sqlTrans);
                cmdSave.CommandText = SQL_COMPANY_INSERT;
            }
            else
            {
                cmdSave.CommandText = SQL_COMPANY_UPDATE;

                StringBuilder sbExplanation = new StringBuilder("Company updated from Local Source import.");
                transactionID = OpenPIKSTransaction(sqlTrans, CompanyID, 0, sbExplanation.ToString());
            }

            cmdSave.CommandTimeout = 300;
            cmdSave.Parameters.AddWithValue("comp_CompanyID", CompanyID);
            cmdSave.Parameters.AddWithValue("comp_PRHQID", CompanyID);
            cmdSave.Parameters.AddWithValue("comp_Name", CompanyName);
            cmdSave.Parameters.AddWithValue("comp_PRType", "H");
            cmdSave.Parameters.AddWithValue("comp_PRListingStatus", "N2");              //always not listed-listing membership prospect

            //always Mailing City unless there is a physical address, then physical city
            int? intListingCityPhysical = null;
            int? intListingCityMailing = null;

            foreach (Address oAddress in Addresses)
            {
                if (oAddress.Type == "P")
                    intListingCityPhysical = oAddress.CityID;
                else if (oAddress.Type == "M")
                    intListingCityMailing = oAddress.CityID;
            }

            if (intListingCityPhysical.HasValue)
                cmdSave.Parameters.AddWithValue("comp_PRListingCityID", intListingCityPhysical);
            else
                cmdSave.Parameters.AddWithValue("comp_PRListingCityID", intListingCityMailing);

            cmdSave.Parameters.AddWithValue("comp_PRIndustryType", "P");                //always produce
            cmdSave.Parameters.AddWithValue("comp_Source", "P");                       // P=Third Party 
            //cmdSave.Parameters.AddWithValue("comp_PROnlineOnly", null);				//Do not set
            //cmdSave.Parameters.AddWithValue("comp_PRLocalSource", null);				//Do not set
            cmdSave.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
            cmdSave.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
            cmdSave.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdSave.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdSave.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
            cmdSave.ExecuteNonQuery();

            //IsLocalSource = true;

            if (transactionID == 0)
            {
                StringBuilder sbExplanation = new StringBuilder("New company added per USDA Food Hub List." + Environment.NewLine);
                sbExplanation.Append("FMID: " + FMID);
                transactionID = OpenPIKSTransaction(sqlTrans, CompanyID, 0, sbExplanation.ToString());
            }

            Address.DeleteAll(sqlTrans, CompanyID);
            foreach (Address address in Addresses)
            {
                address.CompanyID = CompanyID;
                address.Save(sqlTrans, address.Type);
            }

            //Save email at company-level (Entityid=5)
            SaveEmail(sqlTrans, CompanyID, MarketEmail, "E-Mail");
            SaveWebsite(sqlTrans, CompanyID, MarketWebsite, "Web Site");

            if (MarketFacebook.Trim().Length > 0)
                SaveSocialMedia(sqlTrans, CompanyID, "facebook", MarketFacebook);

            if (MarketTwitter.Trim().Length > 0)
                SaveSocialMedia(sqlTrans, CompanyID, "twitter", MarketTwitter);

            bool isDefault = false;
            bool foundPhone = false;
            bool foundFax = false;

            Phone.DeleteAll(sqlTrans, CompanyID, 0);
            foreach (Phone phone in Phones)
            {
                isDefault = false;
                if (!foundPhone && (phone.Type == "P" || phone.Type == "PF"))
                {
                    isDefault = true;
                    foundPhone = true;
                }

                if (!foundFax && (phone.Type == "F" || phone.Type == "PF"))
                {
                    isDefault = true;
                    foundFax = true;
                }
                phone.CompanyID = CompanyID;
                phone.Save(sqlTrans, isDefault);
            }

            DeleteAllClassifications(sqlTrans);
            SaveClassifications(sqlTrans);

            Commodity.DeleteAll(sqlTrans, CompanyID);
            foreach (Commodity oCommodity in Commodities)
            {
                oCommodity.CompanyID = CompanyID;
                oCommodity.Save(sqlTrans);
            }

            // In case this company was rated at one point
            //UpdateRating(sqlTrans); 
            //SaveProfile(sqlTrans);

            ClosePIKSTransaction(transactionID, sqlTrans);

            if (!newRecord)
            {
                DeletePIKSTransaction(transactionID, sqlTrans);
            }

            foreach (Person oPerson in Persons)
            {
                oPerson.CompanyID = CompanyID;
                oPerson.Save(sqlTrans, newRecord);
            }

            //Crate interaction note
            AddInteraction(sqlTrans);

            //
            //  Now look to see who we should mark NLC
            //
            bool foundPerson = false;
            List<Person> crmPersons = Person.GetByCompany(sqlTrans, CompanyID);
            foreach (Person crmPerson in crmPersons)
            {
                foundPerson = false;
                foreach (Person mmwPerson in Persons)
                {
                    if (crmPerson.PersonID == mmwPerson.PersonID)
                    {
                        foundPerson = true;
                        break;
                    }
                }

                if (!foundPerson)
                {
                    crmPerson.MarkNLC(sqlTrans);
                }
            }
        }

        //protected void UpdateRating(SqlTransaction sqlTrans)
        //{
        //	if(!HasRating)
        //	{
        //		return;
        //	}

        //	SqlCommand cmdSave = sqlTrans.Connection.CreateCommand();
        //	cmdSave.Transaction = sqlTrans;
        //	cmdSave.CommandTimeout = 120;
        //	cmdSave.CommandText = SQL_UPDATE_RATING;
        //	cmdSave.Parameters.AddWithValue("CompanyID", CompanyID);
        //	cmdSave.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
        //	cmdSave.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
        //	cmdSave.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
        //	cmdSave.ExecuteNonQuery();
        //}

        protected void AddClassification(string value)
        {
            if (string.IsNullOrEmpty(value))
            {
                return;
            }

            Business = value;
        }

        protected void SaveClassifications(SqlTransaction sqlTrans)
        {
            switch (Business)
            {
                case "Food Hub":
                    AddClassification(sqlTrans, 355); //Food Hub
                    break;
            }
        }

        private const string SQL_DELETE_CLASSIFICATIONS =
                                @"DELETE FROM  PRCompanyClassification WHERE prc2_CompanyId = @prc2_CompanyId;";

        public void DeleteAllClassifications(SqlTransaction sqlTrans)
        {
            SqlCommand sqlCommand = sqlTrans.Connection.CreateCommand();
            sqlCommand.CommandText = SQL_DELETE_CLASSIFICATIONS;
            sqlCommand.CommandTimeout = 120;
            sqlCommand.Transaction = sqlTrans;

            sqlCommand.Parameters.AddWithValue("prc2_CompanyId", CompanyID);
            sqlCommand.ExecuteNonQuery();
        }

        private const string SQL_PRCOMPANY_CLASSIFICATION_INSERT =
                "INSERT INTO PRCompanyClassification (prc2_CompanyClassificationId, prc2_CompanyId, prc2_ClassificationId, prc2_CreatedBy, prc2_CreatedDate, prc2_UpdatedBy, prc2_UpdatedDate, prc2_Timestamp) " +
                "VALUES (@CompanyClassificationId, @CompanyId, @ClassificationId, @UpdatedBy, @UpdatedDate, @UpdatedBy, @UpdatedDate, @Timestamp)";

        protected void AddClassification(SqlTransaction sqlTrans, int classificationID)
        {
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

        protected const string INSERT_Interaction = @"EXEC dbo.usp_CreateInteractions @CompanyID, @Note, @Date, @Action, @Category, null, @Status, @Priority, @Type, @Subject, 1, 1";

        /// <summary>
        /// Returns true if record was inserted into database, or false if ignored due to CallResultCode
        /// </summary>
        /// <param name="sqlTrans"></param>
        /// <param name="oCallRecord"></param>
        /// <returns></returns>
        private void AddInteraction(SqlTransaction sqlTrans)
        {
            SqlCommand cmdInsertInteraction = new SqlCommand();
            cmdInsertInteraction.Connection = sqlTrans.Connection;
            cmdInsertInteraction.Transaction = sqlTrans;
            cmdInsertInteraction.CommandText = INSERT_Interaction;

            cmdInsertInteraction.Parameters.Clear();

            cmdInsertInteraction.Parameters.AddWithValue("CompanyID", CompanyID);
            cmdInsertInteraction.Parameters.AddWithValue("Date", DateTime.Now);
            cmdInsertInteraction.Parameters.AddWithValue("Action", "Note");
            cmdInsertInteraction.Parameters.AddWithValue("Status", "Complete");
            cmdInsertInteraction.Parameters.AddWithValue("Priority", "Normal");
            cmdInsertInteraction.Parameters.AddWithValue("Type", "Note");
            cmdInsertInteraction.Parameters.AddWithValue("Category", "C");
            cmdInsertInteraction.Parameters.AddWithValue("Subject", "New company added per USDA Food Hub List");

            cmdInsertInteraction.Parameters.AddWithValue("Note", GenerateNote());
            cmdInsertInteraction.ExecuteNonQuery();
        }

        private string GenerateNote()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("New company added per USDA Food Hub List. Additional information includes:\n");
            sb.Append(String.Format("{0}: {1}\n", "FMID", FMID));
            sb.Append(String.Format("{0}: {1}\n", "Location_Desc", Location_Desc));
            sb.Append(String.Format("{0}: {1}\n", "EstablishYear", EstablishYear));
            sb.Append(String.Format("{0}: {1}\n", "Legal_Status", Legal_Status));
            sb.Append(String.Format("{0}: {1}\n", "Legal_StatusDesc", Legal_StatusDesc));
            sb.Append(String.Format("{0}: {1}\n", "OperationMonthList", OperationMonthList));
            sb.Append(String.Format("{0}: {1}\n", "PracticeList", PracticeList));
            sb.Append(String.Format("{0}: {1}\n", "F2BList", F2BList));
            sb.Append(String.Format("{0}: {1}\n", "ProcurementList", ProcurementList));
            sb.Append(String.Format("{0}: {1}\n", "OpserviceList", OpserviceList));
            sb.Append(String.Format("{0}: {1}\n", "PSServiceList", PSServiceList));

            return sb.ToString();
        }

        //private const string SQL_LOCAL_SOURCE =
        //@"SELECT comp_CompanyID 
        //               FROM Company WITH (NOLOCK)
        //              WHERE comp_PRLocalSource = 'Y'";

        //private static SqlCommand cmdSelect = null;
        //public static List<Company> GetLocalSource(SqlTransaction sqlTrans)
        //{
        //    if (cmdSelect == null)
        //    {
        //        cmdSelect = new SqlCommand();
        //        cmdSelect.Connection = sqlTrans.Connection;
        //        cmdSelect.Transaction = sqlTrans;
        //    }

        //    cmdSelect.CommandText = SQL_LOCAL_SOURCE;

        //    List<Company> companies = new List<Company>();
        //    using (SqlDataReader reader = cmdSelect.ExecuteReader())
        //    {
        //        while (reader.Read())
        //        {
        //            Company company = new Company();
        //            company.CompanyID = reader.GetInt32(0);
        //            companies.Add(company);
        //        }
        //    }

        //    return companies;
        //}

        //private const string SQL_NLC =
        //        @"UPDATE Company 
        //         SET comp_PRListingStatus = 'N3', 
        //             comp_UpdatedBy=@UpdatedBy, 
        //             comp_UpdatedDate=@UpdatedDate, 
        //             comp_Timestamp=@Timestamp    
        //       WHERE comp_CompanyID = @CompanyID";

        //private SqlCommand cmdNonFactor = null;
        //public void MarkNonFactor(SqlTransaction sqlTrans)
        //{

        //	StringBuilder sbExplanation = new StringBuilder("Company marked Non-Factor because not found in Local Source import." + Environment.NewLine);
        //	int transactionID = OpenPIKSTransaction(sqlTrans, CompanyID, 0, sbExplanation.ToString());


        //	if(cmdNonFactor == null)
        //	{
        //		cmdNonFactor = new SqlCommand();
        //		cmdNonFactor.Connection = sqlTrans.Connection;
        //		cmdNonFactor.Transaction = sqlTrans;
        //	}

        //	cmdNonFactor.CommandText = SQL_NLC;
        //	cmdNonFactor.Parameters.Clear();
        //	cmdNonFactor.Parameters.AddWithValue("CompanyID", CompanyID);
        //	cmdNonFactor.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
        //	cmdNonFactor.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
        //	cmdNonFactor.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
        //	cmdNonFactor.ExecuteNonQuery();

        //	ClosePIKSTransaction(transactionID, sqlTrans);
        //}

        //public string GetCityIDs()
        //{

        //	StringBuilder cityIDs = new StringBuilder();

        //	foreach(Address address in Addresses)
        //	{
        //		if(address.CityID > 0)
        //		{
        //			if(cityIDs.Length > 0)
        //			{
        //				cityIDs.Append(",");
        //			}
        //			cityIDs.Append(address.CityID.ToString());
        //		}
        //	}

        //	return cityIDs.ToString();
        //}

        //protected const string SQL_PROFILE_EXISTS = "SELECT 'x' FROM PRCompanyProfile WHERE prcp_CompanyId = @prcp_CompanyId";

        //protected const string SQL_PROFILE_INSERT =
        //		 "INSERT INTO PRCompanyProfile (prcp_CompanyProfileId, prcp_CompanyId, prcp_Organic, prcp_FoodSafetyCertified, prcp_CreatedBy, prcp_CreatedDate, prcp_UpdatedBy, prcp_UpdatedDate, prcp_Timestamp) " +
        //									"VALUES (@prcp_CompanyProfileId,@prcp_CompanyId,@prcp_Organic,@prcp_FoodSafetyCertified, @CreatedBy, @CreatedDate, @UpdatedBy, @UpdatedDate, @Timestamp);";

        //protected const string SQL_PROFILE_UPDATE =
        //		@"UPDATE PRCompanyProfile 
        //               SET prcp_Organic=@prcp_Organic, 
        //                   prcp_FoodSafetyCertified=@prcp_FoodSafetyCertified, 
        //                   prcp_UpdatedBy=@UpdatedBy, 
        //                   prcp_UpdatedDate=@UpdatedDate, 
        //                   prcp_Timestamp=@Timestamp  
        //             WHERE prcp_CompanyId = @prcp_CompanyId";

        //public void SaveProfile(SqlTransaction sqlTrans)
        //{

        //	// If this is a new company and we don't have the licenses 
        //	// we're looking for, don't create a new PRCompanyProfile
        //	// record.
        //	if(newRecord && string.IsNullOrEmpty(organicLicense) && string.IsNullOrEmpty(foodsafetyLicense))
        //	{
        //		return;
        //	}

        //	object exists = null;

        //	if(!newRecord)
        //	{
        //		SqlCommand cmdRecordExists = sqlTrans.Connection.CreateCommand();
        //		cmdRecordExists.Transaction = sqlTrans;
        //		cmdRecordExists.CommandText = SQL_PROFILE_EXISTS;
        //		cmdRecordExists.Parameters.AddWithValue("prcp_CompanyId", CompanyID);
        //		exists = cmdRecordExists.ExecuteScalar();
        //	}

        //	SqlCommand cmdSave = sqlTrans.Connection.CreateCommand();
        //	cmdSave.Transaction = sqlTrans;
        //	cmdSave.CommandTimeout = 120;
        //	int recordID = 0;

        //	if(exists == null)
        //	{
        //		recordID = GetPIKSID("PRCompanyProfile", sqlTrans);
        //		cmdSave.CommandText = SQL_PROFILE_INSERT;
        //	}
        //	else
        //	{
        //		cmdSave.CommandText = SQL_PROFILE_UPDATE;
        //	}

        //	cmdSave.Parameters.AddWithValue("prcp_CompanyProfileId", recordID);
        //	cmdSave.Parameters.AddWithValue("prcp_CompanyId", CompanyID);
        //	AddParameter(cmdSave, "prcp_Organic", organicLicense);
        //	AddParameter(cmdSave, "prcp_FoodSafetyCertified", foodsafetyLicense);
        //	cmdSave.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
        //	cmdSave.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
        //	cmdSave.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
        //	cmdSave.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
        //	cmdSave.Parameters.AddWithValue("Timestamp", UPDATED_DATE);

        //	cmdSave.ExecuteScalar();
        //}

        private void HandleCompanyName()
        {
            if ((CompanyName.ToLower() == "0") ||
                    (CompanyName.ToLower() == "farm") ||
                    (CompanyName.ToLower() == "farms") ||
                    (CompanyName.ToLower() == "n/a") ||
                    (CompanyName.ToLower() == "na") ||
                    (CompanyName.ToLower() == "no") ||
                    (CompanyName.ToLower() == "none") ||
                    (CompanyName.ToLower() == "null") ||
                    (CompanyName.ToLower() == "owner") ||
                    (CompanyName.ToLower() == "self") ||
                    (CompanyName.ToLower() == "xxx") ||
                    (CompanyName.ToLower() == "# of employees"))
            {
                CompanyName = string.Empty;
                return;
            }

            if (CompanyName.EndsWith(" Llc"))
            {
                CompanyName = CompanyName.Replace(" Llc", " LLC");
                return;
            }

            if (CompanyName.EndsWith(" Llc."))
            {
                CompanyName = CompanyName.Replace(" Llc", " LLC");
                return;
            }
        }
    }
}