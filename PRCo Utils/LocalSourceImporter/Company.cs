using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using LumenWorks.Framework.IO.Csv;

namespace LocalSourceImporter
{
    public class Company : MeisterMediaBase
    {
        public string MMWID;
        public string CompanyName;
        //public string AlsoOperates;
        public List<string> AlsoOperates = new List<string>();
        public string Crops;
        public string Business = null;
        public string FunctionJobTitle;
        public string Organic;
        public string TotalAcres;
        public string License;
        public string Email;


        public string CompanyNameMatch;
        public bool Matched;
        public bool UpdateCRM = true;
        public bool MultipleMatchInCRM;
        public string MultipleMatchCompanyIDs;
        public bool ExcludeFromMatch = false;
        public string MatchkedKey;

        public bool Duplicate;
        public string DuplicateMMWIDs = string.Empty;

        public bool IsValid = true;
        public string InvalidReason;

        public string MatchType;
        public bool NewRecord = false;
        public bool IsLocalSource;
        public bool NewForMMW = false;
        public int LocalSourceID;
        public bool HasRating;
        public int RatingID;

        bool hasBBIDColumn = false;
        public int CompanyID;
        public int CityID;
        public int StateID;
        public List<Person> Persons = new List<Person>();
        public List<Address> Addresses = new List<Address>();
        public List<Phone> Phones = new List<Phone>();
        public List<Phone> PhoneMatching = new List<Phone>();

        public bool Skip = false;
        public List<Company> DuplicateCompanies = new List<Company>();

        string organicLicense = null;
        string foodsafetyLicense = null;

        bool hasBrands = false;
        bool hasOwnership = false;
        public bool hasPACA = false;
        public bool hasDRC = false;

        private string AddressMatch;
        public Company()
        {
        }

        public Company(bool hasBBIDColumn)
        {
            this.hasBBIDColumn = hasBBIDColumn;
        }


        public string GetKey()
        {
            return CompanyNameMatch + ":" + Addresses[0].City + ":" + Addresses[0].State;
        }

        public string GetKey2()
        {
            if (Phones.Count > 0)
            {
                return Phones[0].Number;
            }

            return null;
        }


        public void Load(SqlConnection sqlConn, CsvReader csv)
        {
            MMWID = csv[Person.COL_MMWID];
            CompanyName = TranslateSpanishCharacters(prepareString(csv["Company"]));
            HandleCompanyName();

            GetAlsoOperates(csv["Own/Operate"]);
            SetCommodities(csv["Crops Grown"]); //was "CropsGrown"
            FunctionJobTitle = csv["Function"];
            Organic = GetOrganic(csv["Organic"]);
            HandleTotalAcres(csv["Production Area Total"]); //was "Total Acres"

            GetLicense(csv["Licenses/Certs Description"]); //was "Licesnse"

            if (csv.HasHeader("PRIMARY BUSINESS ACTIVITY"))
                GetBusiness(csv["PRIMARY BUSINESS ACTIVITY"]);

            // The email address at the company level is used
            // for domain matching and is not saved.  This is why
            // we don't reference the Email Suprresion function.
            //Email = csv[Person.COL_EMAIL].ToLower();

            ConvertName(sqlConn);

            AddPhone(csv, "P");
            AddPhone(csv, "F");
            AddAddress(sqlConn, csv);
            AddPerson(csv);

            if (hasBBIDColumn)
            {
                if (!string.IsNullOrEmpty(csv["BBID"]))
                {
                    int value;
                    if (int.TryParse(csv["BBID"], out value))
                    {
                        CompanyID = Convert.ToInt32(csv["BBID"]);
                        ValidateBBID(sqlConn);
                    }
                    else
                    {
                        Console.WriteLine(string.Format("Invalid BBID: {0}", csv["BBID"]));
                    }
                }
            }
        }



        private const string SQL_CONVERT_NAME =
             @"SELECT dbo.GetLowerAlpha(dbo.ufn_PrepareCompanyName(@CompanyName)) as NameMatch ";

        private SqlCommand cmdConvertName = null;
        private void ConvertName(SqlConnection sqlConn)
        {
            // If we don't have a company name
            // Make up a unique value so it doesn't match
            // to other records without a name but are in 
            // the same city/state.
            if (string.IsNullOrEmpty(CompanyName))
            {
                
                CompanyNameMatch = DateTime.Now.Ticks.ToString();
                return;
            }

            if (cmdConvertName == null)
            {
                cmdConvertName = new SqlCommand();
                cmdConvertName.Connection = sqlConn;
                cmdConvertName.CommandText = SQL_CONVERT_NAME;
            }

            cmdConvertName.Parameters.Clear();
            cmdConvertName.Parameters.AddWithValue("CompanyName", CompanyName);

            object result = cmdConvertName.ExecuteScalar();
            if ((result != null) && (result != DBNull.Value))
            {
                CompanyNameMatch = Convert.ToString(result);
            }

        }


        private int existingCityID = 0;
        private string existingCompanyName = string.Empty;
        private const string SQL_VALIDATE_BBID =
             @"SELECT comp_CompanyID, comp_PRListingStatus, comp_PRLocalSource, prls_LocalSourceID, prra_RatingId, comp_PRListingCItyID, comp_Name, comp_PRExcludeFromLocalSource
                 FROM Company WITH (NOLOCK)
                      LEFT OUTER JOIN PRLocalSource WITH (NOLOCK) ON comp_CompanyID = prls_CompanyID 
                      LEFT OUTER JOIN PRRating WITH (NOLOCK) ON comp_CompanyID = prra_CompanyID AND prra_Current = 'Y'
                WHERE comp_CompanyID = @CompanyID;";

        private SqlCommand cmdValidateBBID = null;
        private void ValidateBBID(SqlConnection sqlConn)
        {
            // This is our magic number to indicate "new company"
            if (CompanyID == 1)
            {
                return;
            }


            if (cmdValidateBBID == null)
            {
                cmdValidateBBID = new SqlCommand();
                cmdValidateBBID.Connection = sqlConn;
                cmdValidateBBID.CommandText = SQL_VALIDATE_BBID;
            }

            cmdValidateBBID.Parameters.Clear();
            cmdValidateBBID.Parameters.AddWithValue("CompanyID", CompanyID);

            using (SqlDataReader reader = cmdValidateBBID.ExecuteReader())
            {
                if (reader.Read())
                {
                    if (reader[3] != DBNull.Value)
                    {
                        LocalSourceID = reader.GetInt32(3);
                    }

                    // Is this flagged as local source?
                    if (reader[2] == DBNull.Value)
                    {
                        IsLocalSource = false;

                        // If not, then check the listing status
                        // to see if we should upate it
                        if ((reader.GetString(1) != "L") &&
                            (reader.GetString(1) != "H") &&
                            (reader.GetString(1) != "N1") &&
                            (reader.GetString(1) != "N5") &&
                            (reader.GetString(1) != "N6"))
                        {
                            UpdateCRM = true;
                        }
                        else
                        {
                            UpdateCRM = false;
                        }


                        if ((reader[7] != DBNull.Value) &&
                            (reader.GetString(7) == "Y"))  // The Do Not Match flag
                        {
                            UpdateCRM = false;
                            //WriteLine(" - Found unlisted company with the Do Not Match flag set.");
                        }

                    }
                    else
                    {
                        IsLocalSource = true;
                        UpdateCRM = true;

                        if ((reader[7] != DBNull.Value) &&
                            (reader.GetString(7) == "Y"))  // The Do Not Match flag
                        {
                            UpdateCRM = false;
                            //WriteLine(" - Found unlisted company with the Do Not Match flag set.");
                        }
                    }


                    if (reader[4] != DBNull.Value)
                    {
                        HasRating = true;
                        RatingID = reader.GetInt32(4);
                    }

                    existingCityID = reader.GetInt32(5);
                    existingCompanyName = reader.GetString(6);
                }
                else
                {
                    CompanyID = 0;
                }
            }

            // IF this is not a local soruce record but
            // we will be converting it to a local source
            // record, check for key existng data.
            if  (UpdateCRM)
            {
                CheckForExistingData(sqlConn, null);
            }

        }

        public void CheckForExistingData(SqlConnection sqlConn, SqlTransaction sqlTran)
        {
            hasBrands = HasBrands(sqlConn, sqlTran, CompanyID);
            hasOwnership = HasOnwershipRelations(sqlConn, sqlTran, CompanyID);
            hasPACA = HasPACA(sqlConn, sqlTran, CompanyID);
            hasDRC= HasDRC(sqlConn, sqlTran, CompanyID);
        }


        public string GetInternetDomain()
        {
            if ((!string.IsNullOrEmpty(Email)) &&
                (Email.IndexOf('@') > 0))
            {
                if (Email.ToLower().EndsWith(".net"))
                {
                    return string.Empty;
                }

                return Email.Substring(Email.IndexOf('@') + 1);
            }

            return string.Empty;
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

        public string ErrMsg;

        public void AddAddress(SqlConnection sqlConn, CsvReader csv)
        {
            Address address = new Address();
            address.Load(sqlConn, csv);
            address.CompanyID = CompanyID;
            address.Sequence = Addresses.Count + 1;
            AddAddress(address);

            ErrMsg = address.ErrMsg;
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

            if (string.IsNullOrEmpty(AddressMatch))
            {
                AddressMatch = newAddress.City.ToLower() + ":" + newAddress.State.ToLower();
            }

            if (CityID == 0)
            {
                CityID = newAddress.CityID;
                StateID = newAddress.StateID;
                AddressMatch = newAddress.CityID.ToString();
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

                if (cityCount.Count > 0)
                {
                    var sortedList = cityCount.OrderByDescending(key => key.Value);
                    string[] work = sortedList.First().Key.Split(',');
                    CityID = Convert.ToInt32(work[0]);
                    StateID = Convert.ToInt32(work[1]);
                }
            }
        }



        public void AddPerson(CsvReader csv)
        {
            if ((string.IsNullOrEmpty(csv[Person.COL_FIRSTNAME])) ||
                (string.IsNullOrEmpty(csv[Person.COL_LASTNAME])))
            {
                return;
            }

            if ((csv[Person.COL_FIRSTNAME].Trim() == ".") ||
                (csv[Person.COL_LASTNAME].Trim() == "."))
            {
              return;
            }

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

            foreach (Person person2 in Persons)
            {
                // Keyword: LSS2019
                // We no longer save email addresses
                if ((person.LastName == person2.LastName) &&
                    (person.FirstName == person2.FirstName) &&
                    (person.Title == person2.Title))
                {
                    return;
                }
            }

            person.Sequence = Persons.Count + 1;
            person.CompanyID = CompanyID;
            Persons.Add(person);

            if (person.CellPhone != null)
            {
                PhoneMatching.Add(person.CellPhone);
            }
        }


        public void AddDuplicateCompany(SqlConnection sqlConn, Company dupCompany, string key)
        {
            if (!string.IsNullOrEmpty(DuplicateMMWIDs))
            {
                DuplicateMMWIDs += ",";
            }
            DuplicateMMWIDs += dupCompany.MMWID;

            if (!string.IsNullOrEmpty(dupCompany.DuplicateMMWIDs))
            {
                DuplicateMMWIDs += "," + dupCompany.DuplicateMMWIDs;
            }


            Duplicate = true;
            MatchkedKey = key;
            AddDuplicateCompany(sqlConn, dupCompany);
        }


        public void AddDuplicateCompany(SqlConnection sqlConn, Company dupCompany)
        {
            if ((dupCompany.CompanyID == 0) &&
                (CompanyID > 0))
            {
                dupCompany.CompanyID = CompanyID;
                dupCompany.LocalSourceID = LocalSourceID;
            }

            if ((CompanyID == 0) &&
                (dupCompany.CompanyID > 0))
            { 
                CompanyID = dupCompany.CompanyID;
                LocalSourceID = dupCompany.LocalSourceID;

                ValidateBBID(sqlConn);
            }

            if (string.IsNullOrEmpty(CompanyName))
            {
                CompanyName = dupCompany.CompanyName;
                CompanyNameMatch = dupCompany.CompanyNameMatch;

                if ((!string.IsNullOrEmpty(CompanyName)) &&
                    (InvalidReason == "No company name found in input file."))
                {
                    IsValid = true;
                    InvalidReason = null;
                }
            }
            dupCompany.IsLocalSource = IsLocalSource;
            dupCompany.Skip = true;
            DuplicateCompanies.Add(dupCompany);
            AddPerson(dupCompany.Persons);
            AddCommodity(dupCompany.Commodities);
            AddClassification(dupCompany.Business);
            AddAddress(dupCompany.Addresses);
            AddPhone(dupCompany.Phones);
            AddAlsoOperates(dupCompany.AlsoOperates);
            AddBusiness(dupCompany.Business);
            AddOrganic(dupCompany.Organic);
            SetTotalAcres(dupCompany.TotalAcres);


            // Keyword: LSS2019
            // We no longer save email addresses
            //// If the current email is from a generic provider, i.e gmail
            //// and the dup has one from non-generic provider, then use
            //// the dup's email
            //if ((!string.IsNullOrEmpty(Email)) &&
            //    (_InternetDomain.Contains(GetInternetDomain())) &&
            //    (!string.IsNullOrEmpty(dupCompany.Email)) &&
            //    (!_InternetDomain.Contains(dupCompany.GetInternetDomain())))
            //{
            //    Email = dupCompany.Email;
            //}
        }

        public void SetCompanyID(int companyID)
        {
            CompanyID = companyID;

            foreach (Company company in DuplicateCompanies)
            {
                company.CompanyID = CompanyID;
                company.IsLocalSource = IsLocalSource;
            }

            foreach (Person person in Persons)
            {
                person.CompanyID = CompanyID;
            }

            foreach (Address address in Addresses)
            {
                address.CompanyID = CompanyID;
            }

        }




        private void GetAlsoOperates(string value)
        {
            string[] alsoOperates = value.Split('|'); //was previously comma
            string alsoOperatesResult = string.Empty;

            string tmp = null;
            foreach (string alsoOperate in alsoOperates)
            {
                tmp = GetAlsoOperatesInt(alsoOperate.Trim());
                AddAlsoOperates(tmp);
            }
        }

        private string GetAlsoOperatesInt(string value)
        {
            switch (value)
            {
                case "RM":
                case "M":
                    return "Roadside Market"; 

                case "P": return "Packing Facility";
                case "G": return "Greenhouse";
            }
            return null;
        }

        private void AddAlsoOperates(string value)
        {
            if (string.IsNullOrEmpty(value))
            {
                return;
            }

            // Don't add duplicates
            foreach (string alsoOperates in AlsoOperates)
            {
                if (alsoOperates == value)
                {
                    return;
                }
            }
            AlsoOperates.Add(value);
        }

        private void AddAlsoOperates(List<string> newValues)
        {
            foreach (string newValue in newValues)
            {
                AddAlsoOperates(newValue);
            }
            
        }

        private void GetBusiness(string value)
        {
            string[] businesses = value.Split('|'); //previously was comma
            foreach (string biz in businesses)
            {
                switch (biz.Trim())
                {
                    case "G":
                    case "GG":
                        AddBusiness("Grower");
                        break;
                    case "GP":
                        AddBusiness("Grower/Packer");
                        break;
                }
            }
        }

        
        private void AddBusiness(string value)
        {
            // Grower/Packer is all encompassing, so
            // if we're already set to that, we're done.
            if (Business == "Grower/Packer")
                return;

            // This works because of the previous conditional.
            Business = value;
        }


        private string GetFunctionJobTitle(string value)
        {
            switch (value)
            {
                case "A": return "Senior Mgmt";
                case "GM": return "General Mgmt";
                case "PM": return "Production Mgmt";
                case "SM": return "Sales and Marketing";
                case "OWN": return "Owner";
                case "SR": return "Sales";

                case "PA":
                case "P":
                    return "Buyer";

                case "214": return "Education";
                case "219": return "Other";
            }
            return value;
        }

        private string GetOrganic(string value)
        {
            switch (value.Trim())
            {
                case "610":
                case "Y":
                case "y":
                    return "Y";
                case "611": return null;
                case "": return null;
                default: return null;
            }
        }

        private void AddOrganic(string value)
        {
            // If we already have the flag set
            // leave it.
            if (Organic == "Y")
            {
                return;
            }

            Organic = value;
        }

        private void HandleTotalAcres(string value)
        {
            string[] totalAcres = value.Split('|'); //previously was comma
            foreach (string totalAcre in totalAcres)
            {
                SetTotalAcres(GetTotalAcres(totalAcre.Trim()));
            }
        }

        private string GetTotalAcres(string value)
        {
            switch (value)
            {
                case "L": return "<1 acre";
                case "1": return "1 - 24 acres";
                case "2": return "25 - 99 acres";
                case "3": return "100 - 499 acres";
                case "4": return "500 - 999 acres";
                case "5": return "1000 - 2499 acres";
                case "6": return "2500 + acres";
            }
            return null;
        }

        private void SetTotalAcres(string value)
        {
            if (string.IsNullOrEmpty(value))
            {
                return;
            }

            switch (value)
            {
                case "2500 + acres":
                    TotalAcres = value;
                    break;

                case "1000 - 2499 acres":
                    if (TotalAcres != "2500 + acres")
                    {
                        TotalAcres = value;
                    }
                    break;
                case "500 - 999 acres":
                    if ((TotalAcres != "2500 + acres") &&
                        (TotalAcres != "1000 - 2499 acres"))
                    {
                        TotalAcres = value;
                    }
                    break;
                case "100 - 499 acres":
                    if ((TotalAcres != "2500 + acres") &&
                        (TotalAcres != "1000 - 2499 acres") &&
                        (TotalAcres != "500 - 999 acres"))
                    {
                        TotalAcres = value;
                    }
                    break;
                case "25 - 99 acres":
                    if (string.IsNullOrEmpty(TotalAcres))
                    {
                        TotalAcres = value;
                    }
                    break;
                case "1 - 24 acres":
                    if (string.IsNullOrEmpty(TotalAcres))
                    {
                        TotalAcres = value;
                    }
                    break;
                case "L":
                    if (string.IsNullOrEmpty(TotalAcres))
                    {
                        TotalAcres = value;
                    }
                    break;
            }
        }

        private void GetLicense(string value)
        {
            if (string.IsNullOrEmpty(value))
            {
                return;
            }

            License = value;
            if (License.IndexOf("NOP") >= 0)
                organicLicense = "Y";

            if (License.IndexOf("GAP") >= 0)
                foodsafetyLicense = "Y";
        }

        public bool HasOrganicFoodSafetyLicense()
        {
            if ((!string.IsNullOrEmpty(organicLicense)) ||
                (!string.IsNullOrEmpty(foodsafetyLicense)))
            {
                return true;
            }

            return false;
        }

        public List<Commodity> Commodities = new List<Commodity>();
        private void SetCommodities(string value)
        {
            string[] crops = value.Split('|'); //Was previously a comma
            foreach (string crop in crops)
            {
                switch (crop.Trim())
                {
                    case "A":
                        AddCommodity(110, "A");
                        break;
                    case "PR":
                        AddCommodity(161, "Pr");
                        break;
                    case "CI":
                        AddCommodity(59, "Cit");
                        AddCommodity(62, "Gf");
                        AddCommodity(64, "L");
                        AddCommodity(65, "Ls");
                        AddCommodity(66, "Keyls");
                        AddCommodity(69, "Sweetls");
                        AddCommodity(70, "Mandarins");
                        AddCommodity(71, "Or");
                        AddCommodity(72, "Valenciaor");
                        AddCommodity(73, "Templeor");
                        AddCommodity(74, "Souror");
                        AddCommodity(75, "Navelor");
                        AddCommodity(76, "Bloodor");
                        AddCommodity(77, "Minneolaor");
                        AddCommodity(78, "Jor");
                        AddCommodity(80, "Pummelos");
                        AddCommodity(81, "Tangelos");
                        AddCommodity(82, "Tg");
                        break;
                    case "PN":
                        AddCommodity(102, "Pc");
                        AddCommodity(99, "Nec");
                        break;
                    case "PPA":
                        //AddCommodity(91, "Ap"); //removed
                        AddCommodity(104, "Pl");
                        AddCommodity(106, "Ps");
                        AddCommodity(91, "Ap");

                        break;
                    case "CH":
                        AddCommodity(94, "Ch");
                        break;
                    case "G":
                        AddCommodity(223, "Gs");
                        break;

                    case "BER":
                    case "BERX":
                        AddCommodity(47, "Bs");
                        AddCommodity(49, "Boysenberry");
                        AddCommodity(50, "Goosebs");
                        AddCommodity(51, "Bb");
                        AddCommodity(52, "Marionbb");
                        AddCommodity(54, "Cs");
                        AddCommodity(55, "Currants");
                        AddCommodity(56, "Redcurrants");
                        AddCommodity(57, "Rp");
                        AddCommodity(84, "St");
                        AddCommodity(53, "Bl");

                        break;

                    case "S": 
                        AddCommodity(84, "St");
                        break;

                    case "FRTX": 
                    case "FRT": 
                        AddCommodity(37, "F");
                        break;
                    case "AL":
                        AddCommodity(272, "Almonds");
                        break;
                    case "WN":
                        AddCommodity(285, "Walnuts");
                        break;
                    case "PI":
                        AddCommodity(284, "Pistachios");
                        break;
                    case "NUTX":
                    case "NUT":
                        AddCommodity(271, "N");
                        break;
                    case "T": 
                        AddCommodity(535, "Tom");
                        AddCommodity(1503, "Beefsteaktom");
                        AddCommodity(541, "Chtom");
                        AddCommodity(1504, "Clustertom");
                        AddCommodity(540, "Grapetom");
                        AddCommodity(1501, "Heirloomtom");
                        AddCommodity(539, "Plumtom");
                        AddCommodity(536, "Romatom");
                        AddCommodity(538, "Teardroptom");
                        AddCommodity(543, "Tomatillotom");
                        AddCommodity(537, "Yellowtom");

                        break;
                    case "PEP": 
                        AddCommodity(505, "Pp");
                        AddCommodity(506, "Fresnopp");
                        AddCommodity(507, "Redfresnopp");
                        AddCommodity(508, "Yellowpp");
                        AddCommodity(509, "Scotchbonnetpp");
                        AddCommodity(510, "Serranopp");
                        AddCommodity(511, "Redpp");
                        AddCommodity(512, "Poblanopp");
                        AddCommodity(513, "Pasillapp");
                        AddCommodity(514, "Jalapenopp");
                        AddCommodity(515, "Hotjalapenopp");
                        AddCommodity(516, "Habaneropp");
                        AddCommodity(517, "Chilipp");
                        AddCommodity(518, "Cayennepp");
                        AddCommodity(519, "Anaheimpp");
                        AddCommodity(520, "Ajicachuchapp");
                        AddCommodity(521, "Bellpp");
                        AddCommodity(523, "Yellowbellpp");
                        AddCommodity(524, "Whitebellpp");
                        AddCommodity(525, "Redbellpp");
                        AddCommodity(526, "Purplebellpp");
                        AddCommodity(527, "Orangebellpp");
                        AddCommodity(528, "Thaipp");
                        AddCommodity(529, "Cubanellepp");
                        AddCommodity(1502, "Waxbanpp");
                        AddCommodity(581, "Caribepp");
                        AddCommodity(570, "Manzanochilipp");

                        break;
                    case "SC": 
                        AddCommodity(487, "Sweetcorn");
                        AddCommodity(484, "Corn");
                        AddCommodity(489, "Husksweetcorn");
                        break;

                    case "CN":
                        AddCommodity(484, "Corn");
                        break;

                    case "M": 
                        AddCommodity(229, "Melon");
                        AddCommodity(230, "Persianmelon");
                        AddCommodity(231, "Bittermelon");
                        AddCommodity(232, "Wintermelon");
                        AddCommodity(233, "Hornedmelon");
                        AddCommodity(235, "Casmelon");
                        AddCommodity(236, "Crmelon");
                        AddCommodity(237, "Galiamelon");
                        AddCommodity(222, "Cants");
                        AddCommodity(243, "Wmel");
                        AddCommodity(244, "Seedlesswmel");
                        AddCommodity(226, "Hyd");
                        AddCommodity(569, "Bittergourdmelon");

                        break;
                    case "W": 
                        AddCommodity(243, "Wmel");
                        break;
                    case "SQS": 
                        AddCommodity(324, "Sq");
                        AddCommodity(326, "Zusq");
                        AddCommodity(327, "Mexsq");
                        AddCommodity(328, "Hssq");
                        AddCommodity(329, "Bananahssq");
                        AddCommodity(330, "Kabochahssq");
                        AddCommodity(331, "Acornhssq");
                        AddCommodity(332, "Spaghettihssq");
                        AddCommodity(333, "Italiansq");
                        AddCommodity(334, "Courgettesq");
                        AddCommodity(335, "Chinsq");
                        AddCommodity(336, "Yellowsq");
                        AddCommodity(561, "Moquasq");
                        AddCommodity(562, "Hairymoquasq");
                        AddCommodity(573, "Ornamentalsq");
                        AddCommodity(321, "Butternutsq");
                        AddCommodity(323, "Pum");
                        break;

                    case "ORN":
                        AddCommodity(486, "Ornamentalcorn");
                        AddCommodity(339, "Ornamentalgourds");
                        AddCommodity(573, "Ornamentalsq");
                        break;

                    case "SQW": 
                        AddCommodity(324, "Sq");
                        break;

                    case "ON": 
                        AddCommodity(309, "O");
                        AddCommodity(305, "Gno");
                        AddCommodity(306, "Scalliongno");
                        AddCommodity(310, "Yellowo");
                        AddCommodity(311, "Sweeto");
                        AddCommodity(312, "Whiteo");
                        AddCommodity(313, "Seedo");
                        AddCommodity(314, "Redo");
                        AddCommodity(315, "Cipollineo");
                        AddCommodity(316, "Pearlo");
                        AddCommodity(317, "Spanisho");
                        AddCommodity(574, "Seto");

                        break;
                    case "BC": 
                        AddCommodity(345, "Bc");
                        AddCommodity(348, "Cl");
                        AddCommodity(344, "Broccoflower");
                        AddCommodity(346, "Crownsbc");
                        AddCommodity(347, "Rabebc");


                        break;
                    case "P": 
                        AddCommodity(323, "Pum");
                        break;

                    case "CU": 
                        AddCommodity(491, "Ck");
                        AddCommodity(492, "Seedlessck");
                        AddCommodity(494, "Japaneseck");
                        AddCommodity(495, "Persianck");
                        AddCommodity(496, "Picklepersianck");
                        AddCommodity(497, "Europeanck");
                        AddCommodity(498, "Englishck");
                        AddCommodity(499, "Pickleck");

                        break;
                    case "LG": 
                        AddCommodity(370, "Gn");
                        AddCommodity(349, "Leafyvegetable");
                        AddCommodity(350, "Arugula");
                        AddCommodity(295, "Bk");
                        AddCommodity(352, "Cab");
                        AddCommodity(353, "Asiancab");
                        AddCommodity(354, "Chinasiancab");
                        AddCommodity(355, "Savoycab");
                        AddCommodity(356, "Greencab");
                        AddCommodity(357, "Redcab");
                        AddCommodity(358, "Calaloo");
                        AddCommodity(359, "Chard");
                        AddCommodity(360, "Cy");
                        AddCommodity(361, "Endigialet");
                        AddCommodity(362, "En");
                        AddCommodity(363, "Belgianen");
                        AddCommodity(365, "Es");
                        AddCommodity(366, "Fiddleheadf");
                        AddCommodity(368, "Frisee");
                        AddCommodity(297, "Gaichoy");
                        AddCommodity(371, "Hrgn");
                        AddCommodity(372, "Rapegn");
                        AddCommodity(373, "Kimcheegn");
                        AddCommodity(374, "Mesclungn");
                        AddCommodity(375, "Tsgn");
                        AddCommodity(376, "Hrrootgn");
                        AddCommodity(377, "Donquagn");
                        AddCommodity(378, "Dandeliongn");
                        AddCommodity(380, "Btgn");
                       // AddCommodity(382, "");
                        AddCommodity(383, "Microgn");
                        AddCommodity(385, "Let");
                        AddCommodity(386, "Bibblet");
                        AddCommodity(387, "Bostonlet");
                        AddCommodity(388, "Leaflet");
                        AddCommodity(389, "Machelet");
                        AddCommodity(390, "Redlet");
                        AddCommodity(391, "Romlet");
                        AddCommodity(392, "Butterlet");
                        AddCommodity(393, "Radicchio");
                        AddCommodity(394, "Rapini");
                        AddCommodity(298, "Rauday");
                        AddCommodity(396, "Salad");
                        AddCommodity(397, "Sorrel");
                        AddCommodity(398, "Spin");
                        AddCommodity(399, "Ongchoyspin");
                        AddCommodity(400, "Springmix");
                        AddCommodity(300, "Yuchoy");
                        AddCommodity(379, "Colgn");
                        AddCommodity(381, "Mustardgn");
                        AddCommodity(384, "Kl");
                        AddCommodity(401, "Watercress");
                        AddCommodity(577, "Sherlihongn");
                        AddCommodity(1500, "Gailankl");

                        break;

                    case "CB":
                        AddCommodity(352, "Cab");
                        break;

                    case "L": 
                        AddCommodity(361, "Endigialet");
                        AddCommodity(385, "Let");
                        AddCommodity(386, "Bibblet");
                        AddCommodity(387, "Bostonlet");
                        AddCommodity(388, "Leaflet");
                        AddCommodity(389, "Machelet");
                        AddCommodity(390, "Redlet");
                        AddCommodity(391, "Romlet");
                        AddCommodity(392, "Butterlet");
                        break;

                    case "CR":
                        AddCommodity(438, "Ct");
                        break;
                    case "PO":
                        AddCommodity(451, "P");
                        break;
                    case "SP":
                        AddCommodity(465, "Sp");
                        break;
                    case "GB":
                        AddCommodity(419, "Greenbn");
                        break;
                    case "AS":
                        AddCommodity(474, "Asp");
                        break;

                    case "HRB":
                        AddCommodity(249, "Basil");
                        AddCommodity(250, "Bayleaves");
                        AddCommodity(251, "Chervil");
                        AddCommodity(252, "Chives");
                        AddCommodity(253, "Cilantro");
                        AddCommodity(256, "Dill");
                        AddCommodity(258, "Fennel");
                        AddCommodity(1506, "Fenugreek");
                        AddCommodity(259, "Lgrass");
                        AddCommodity(260, "Marjoram");
                        AddCommodity(261, "Mint");
                        AddCommodity(263, "Oregano");
                        AddCommodity(264, "Parsley");
                        AddCommodity(262, "Peppermint");
                        AddCommodity(266, "Rosemary");
                        AddCommodity(267, "Sage");
                        AddCommodity(268, "Savory");
                        AddCommodity(554, "Spearmint");
                        AddCommodity(269, "Tarragon");
                        AddCommodity(270, "Thyme");
                        break;

                    case "COLX":
                    case "COL":
                        AddCommodity(475, "Br");
                        AddCommodity(379, "Colgn");
                        AddCommodity(384, "Kl");
                        AddCommodity(307, "Kohlrabi");
                        AddCommodity(381, "Mustardgn");
                        AddCommodity(467, "Ts");
                        AddCommodity(401, "Watercress");
                        AddCommodity(344, "Broccoflower");
                        AddCommodity(346, "Crownsbc");
                        AddCommodity(347, "Rabebc");
                        AddCommodity(455, "Rd"); 

                        break;
                    case "VEGX":
                    case "VEG":
                        AddCommodity(291, "V");
                        break;

                    case "AV":
                        AddCommodity(93, "Av");
                        break;
                    case "B":
                        AddCommodity(404, "Bn");
                        break;

                    case "DB":
                        AddCommodity(404, "Dbn");
                        break;

                    case "BP":
                        AddCommodity(5, "Beddingplants");
                        break;

                    case "BT":
                        AddCommodity(436, "Bt");
                        break;

                    case "CL":
                        AddCommodity(477, "Cel");
                        break;

                    case "EG":
                        AddCommodity(544, "Ep");
                        break;

                    case "FP":
                    case "PP":
                        AddCommodity(15, "Plants");
                        break;

                    case "CF":
                        AddCommodity(14, "Flowers");
                        break;

                    case "MA":
                        AddCommodity(98, "Man");
                        break;

                    case "OK":
                        AddCommodity(504, "Ok");
                        break;

                    case "PE":
                        AddCommodity(280, "Pn");
                        break;

                    case "PS":
                        AddCommodity(427, "Pe");
                        break;

                    case "TF":
                        AddCommodity(182, "Tropf");
                        break;
                }
            }
        }

        private void AddCommodity(int commodityID, string publishedDisplay) {
            Commodity commod = new Commodity(commodityID, publishedDisplay, Commodities.Count + 1);
            AddCommodity(commod);
        }


        public void AddCommodity(List<Commodity> commodities)
        {
            foreach (Commodity commodity in commodities)
            {
                AddCommodity(commodity);
            }
        }

        public void AddCommodity(Commodity commod)
        {
            // Look for duplicates and skip them
            foreach (Commodity commod2 in Commodities)
            {
                if (commod2.CommodityID == commod.CommodityID)
                {
                    return;
                }
            }

            switch(commod.PublishedDisplay)
            {
                case "F":
                    commod.Sequence = 5000;
                    break;
                case "V":
                    commod.Sequence = 5001;
                    break;
                default:
                    commod.Sequence = Commodities.Count + 1;
                    break;
            }
            Commodities.Add(commod);
        }



        protected const string SQL_COMPANY_INSERT =
            "INSERT INTO Company (comp_CompanyID, comp_PRHQID,     comp_Name, comp_PRTradestyle1, comp_PRCorrTradestyle, comp_PRBookTradestyle, comp_PRType, comp_PRListingStatus, comp_PRListingCityID, comp_PRIndustryType, comp_Source, comp_PROnlineOnly, comp_PRLocalSource, comp_PRCommunicationLanguage, comp_CreatedBy, comp_CreatedDate, comp_UpdatedBy, comp_UpdatedDate, comp_Timestamp) " +
                         "VALUES (@comp_CompanyID,@comp_CompanyID,@comp_Name,@comp_Name,         @comp_Name,            @comp_Name,            @comp_PRType,@comp_PRListingStatus,@comp_PRListingCityID,@comp_PRIndustryType,@comp_Source, @comp_PROnlineOnly, @comp_PRLocalSource, 'E', @CreatedBy, @CreatedDate, @UpdatedBy, @UpdatedDate, @Timestamp)";

        protected const string SQL_COMPANY_UPDATE =
            @"UPDATE Company
                 SET comp_Name=@comp_Name, 
                     comp_PRTradestyle1 = @comp_Name, 
                     comp_PRCorrTradestyle = @comp_Name, 
                     comp_PRBookTradestyle = @comp_Name, 
                     comp_PRListingStatus = @comp_PRListingStatus,
                     comp_PRListingCityID = @comp_PRListingCityID, 
                     comp_PROnlineOnly = @comp_PROnlineOnly, 
                     comp_PRLocalSource = @comp_PRLocalSource,
                     comp_PRPublishDL = NULL,
                     comp_PRPublishUnloadHours = NULL,
                     comp_PRTMFMAward = NULL,
                     comp_PRTMFMAwardDate = NULL,
                     comp_PRLegalName = NULL,
                     comp_UpdatedBy = @UpdatedBy, 
                     comp_UpdatedDate = @UpdatedDate, 
                     comp_Timestamp = @Timestamp  
               WHERE comp_CompanyID = @comp_CompanyID";

        public void SaveCompany(SqlTransaction sqlTrans)
        {
            if(CompanyName.Length > 104)
            {
                CompanyName = CompanyName.Substring(0, 104);
            }

            //
            // If we're not updating CRM, then we're only
            // updating the Local Source data.
            if (!UpdateCRM)
            {
                SaveLocalSource(sqlTrans);
                return;
            }

            SetCityID();

            int transactionID = 0;

            SqlCommand cmdSave = sqlTrans.Connection.CreateCommand();
            cmdSave.Transaction = sqlTrans;

            if (CompanyID < 100000)
            {
                NewRecord = true;
                NewForMMW = true;
                CompanyID = GetPIKSID("Company", sqlTrans);
                cmdSave.CommandText = SQL_COMPANY_INSERT;
            }
            else
            {
                StringBuilder sbExplanation = new StringBuilder("Company updated from Local Source import.");
                if (hasBrands) {
                    sbExplanation.Append("  Brands deleted from Brand table due to change in listing status.");
                }

                if (hasOwnership)
                {
                    sbExplanation.Append("  Ownership releationships deleted.");
                }

                cmdSave.CommandText = SQL_COMPANY_UPDATE;
                transactionID = OpenPIKSTransaction(sqlTrans, CompanyID, 0, sbExplanation.ToString());
            }

            // If we're updating an existing company, we found instances where the
            // company name on subsquent import files is empty, so in that case
            // use the name found in CRM.
            if ((string.IsNullOrEmpty(CompanyName)) &&
                (!string.IsNullOrEmpty(existingCompanyName)))
            {
                CompanyName = existingCompanyName;
            }

            if ((CityID == 0) &&
                (existingCityID > 0))
            {
                CityID = existingCityID;
            }

            cmdSave.CommandTimeout = 300;
            cmdSave.Parameters.AddWithValue("comp_CompanyID", CompanyID);
            cmdSave.Parameters.AddWithValue("comp_PRHQID", CompanyID);
            cmdSave.Parameters.AddWithValue("comp_Name", CompanyName);
            cmdSave.Parameters.AddWithValue("comp_PRType", "H");
            cmdSave.Parameters.AddWithValue("comp_PRListingStatus", "L");
            cmdSave.Parameters.AddWithValue("comp_PRListingCityID", CityID);
            cmdSave.Parameters.AddWithValue("comp_PRIndustryType", "P");
            cmdSave.Parameters.AddWithValue("comp_Source", "MMW");
            cmdSave.Parameters.AddWithValue("comp_PROnlineOnly", "Y");
            cmdSave.Parameters.AddWithValue("comp_PRLocalSource", "Y");
            cmdSave.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
            cmdSave.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
            cmdSave.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdSave.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdSave.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
            cmdSave.ExecuteNonQuery();

            IsLocalSource = true;

            if (transactionID == 0)
            {
                StringBuilder sbExplanation = new StringBuilder("Company created from Local Source import." + Environment.NewLine);
                sbExplanation.Append("MMW ID: " + MMWID);
                transactionID = OpenPIKSTransaction(sqlTrans, CompanyID, 0, sbExplanation.ToString());
            }

            Address.DeleteAll(sqlTrans, CompanyID);
            foreach (Address address in Addresses)
            {
                if (!string.IsNullOrEmpty(address.Street1Match))
                {
                    address.CompanyID = CompanyID;
                    address.Save(sqlTrans, "M");
                }
            }

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

            SaveLocalSource(sqlTrans);

            Commodity.DeleteAll(sqlTrans, CompanyID);
            foreach (Commodity mmwCommodity in Commodities)
            {
                mmwCommodity.CompanyID = CompanyID;
                mmwCommodity.Save(sqlTrans);
            }

            // In case this company was rated at one point
            UpdateRating(sqlTrans);
            SaveProfile(sqlTrans);

            if (hasBrands)
            {
                DeleteBrands(sqlTrans, CompanyID);
            }

            if (hasOwnership)
            {
                DeleteOnwershipRelations(sqlTrans, CompanyID);
            }


            if (hasPACA)
            {
                UpdatePACA(sqlTrans, CompanyID);
            }


            if (hasDRC)
            {
                UpdateDRC(sqlTrans, CompanyID);
            }

            ClosePIKSTransaction(transactionID, sqlTrans);

            if (!NewRecord)
            {
                DeletePIKSTransaction(transactionID, sqlTrans);
            }

            foreach (Person mmwPerson in Persons)
            {
                mmwPerson.CompanyID = CompanyID;
                mmwPerson.Save(sqlTrans, NewRecord);
            }

            UpdateTES(sqlTrans, CompanyID);


            //314894 
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

        protected const string SQL_LOCALSOURCE_INSERT =
             "INSERT INTO PRLocalSource (prls_CompanyID, prls_RegionStateID, prls_AlsoOperates, prls_Organic, prls_TotalAcres, prls_PRMMWID, prls_CreatedBy, prls_CreatedDate, prls_UpdatedBy, prls_UpdatedDate, prls_Timestamp) " +
                          "VALUES (@prls_CompanyID,@prls_RegionStateID,@prls_AlsoOperates,@prls_Organic,@prls_TotalAcres, @prls_PRMMWID, @CreatedBy, @CreatedDate, @UpdatedBy, @UpdatedDate, @Timestamp);SELECT SCOPE_IDENTITY();";

        protected const string SQL_LOCALSOURCE_UPDATE =
            @"UPDATE PRLocalSource 
                 SET prls_RegionStateID=@prls_RegionStateID, 
                     prls_AlsoOperates=@prls_AlsoOperates, 
                     prls_Organic=@prls_Organic, 
                     prls_TotalAcres=@prls_TotalAcres, 
                     prls_PRMMWID = @prls_PRMMWID,
                     prls_UpdatedBy=@UpdatedBy, 
                     prls_UpdatedDate=@UpdatedDate, 
                     prls_Timestamp=@Timestamp  
               WHERE prls_CompanyID = @prls_CompanyID";

        public void SaveLocalSource(SqlTransaction sqlTrans)
        {
            SqlCommand cmdSave = sqlTrans.Connection.CreateCommand();
            cmdSave.Transaction = sqlTrans;
            cmdSave.CommandTimeout = 120;

            // We are checking the local source ID in case this is a previously 
            // existing CRM record, i.e. source != MMW, that we are updating.
            if (LocalSourceID == 0)
            {
                cmdSave.CommandText = SQL_LOCALSOURCE_INSERT;
            }
            else
            {
                cmdSave.CommandText = SQL_LOCALSOURCE_UPDATE;
            }

            cmdSave.Parameters.AddWithValue("prls_CompanyID", CompanyID);
            cmdSave.Parameters.AddWithValue("prls_RegionStateID", StateID);
            cmdSave.Parameters.AddWithValue("prls_AlsoOperates", String.Join(", ", AlsoOperates));
            AddParameter(cmdSave, "prls_Organic", Organic);
            AddParameter(cmdSave, "prls_TotalAcres", TotalAcres);
            cmdSave.Parameters.AddWithValue("prls_PRMMWID", MMWID);
            cmdSave.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
            cmdSave.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
            cmdSave.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdSave.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdSave.Parameters.AddWithValue("Timestamp", UPDATED_DATE);

            object result = null;
            try
            {
                result = cmdSave.ExecuteScalar();
            }
            catch
            {
                Console.WriteLine("AlsoOperates: " + String.Join(",", AlsoOperates));
                Console.WriteLine("Organic: " + Organic);
                Console.WriteLine("TotalAcres: " + TotalAcres);
                throw;
            }

            if (LocalSourceID == 0)
            {
                LocalSourceID = Convert.ToInt32(result);
            }
        }


        private const string SQL_RATING_EXIST =
            @"SELECT 'x' FROM PRRating  WHERE prra_CompanyID = @CompanyID AND prra_Current = 'Y'";

        private const string SQL_UPDATE_RATING =
            @"UPDATE PRRating 
                 SET prra_Current = NULL, 
                     prra_UpdatedBy = @UpdatedBy, 
                     prra_UpdatedDate = @UpdatedDate, 
                     prra_Timestamp = @Timestamp 
               WHERE prra_CompanyID = @CompanyID 
                 AND prra_Current = 'Y'";

        protected void UpdateRating(SqlTransaction sqlTrans)
        {
            if (!HasRating)
            {
                return;
            }


            SqlCommand cmdSave = sqlTrans.Connection.CreateCommand();
            cmdSave.Transaction = sqlTrans;
            cmdSave.CommandTimeout = 120;
            cmdSave.CommandText = SQL_UPDATE_RATING;
            cmdSave.Parameters.AddWithValue("CompanyID", CompanyID);
            cmdSave.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdSave.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdSave.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
            cmdSave.ExecuteNonQuery();
        }


        protected void AddClassification(string value)
        {
            if (string.IsNullOrEmpty(value))
            {
                return;
            }

            if (Business == "Grower/Packer")
            {
                return;
            }

            Business = value;

        }

        protected void SaveClassifications(SqlTransaction sqlTrans)
        {
            // Keyword: LSS2019
            // If this is a new record, but does not
            // have a "Business" value, set it to "Grower"
            if ((LocalSourceID == 0) && (string.IsNullOrEmpty(Business))) {
                AddClassification(sqlTrans, 360); //Grower
                return;
            }


            switch (Business)
            {
                case "Grower":
                    AddClassification(sqlTrans, 360); //Grower
                    break;

                case "Grower/Packer":
                    AddClassification(sqlTrans, 360); //Grower
                    AddClassification(sqlTrans, 250); //Packer
                    break;
            }
        }

        private const string SQL_DELETE_CLASSIFICATIONS =
                    @"DELETE FROM  PRCompanyClassification WHERE prc2_CompanyId = @prc2_CompanyId;";

        public void DeleteAllClassifications(SqlTransaction sqlTrans)
        {
            // Keyword: LSS2019
            // If this is an existing record, but does not
            // have a "Business" value, leave the existing 
            // classifications.
            if ((LocalSourceID > 0) && (string.IsNullOrEmpty(Business)))
                return;

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


        // Exclude Non-Factor since the result
        // of this operation is to potentially mark
        // them non-factor
        private const string SQL_LOCAL_SOURCE =
        @"SELECT comp_CompanyID, prpa_LicenseNumber
                 FROM Company WITH (NOLOCK)
                      LEFT OUTER JOIN PRPACALicense WITH (NOLOCK) ON comp_CompanyID = prpa_CompanyID 
                                                                 AND prpa_Publish = 'Y'
                                                                 AND prpa_TerminateCode = '1'
                WHERE comp_PRLocalSource = 'Y'
                  AND comp_PRListingStatus NOT IN ('N3', 'N2')";

        private static SqlCommand cmdSelect = null;
        public static List<Company> GetLocalSource(SqlTransaction sqlTrans)
        {
            if (cmdSelect == null)
            {
                cmdSelect = new SqlCommand();
                cmdSelect.Connection = sqlTrans.Connection;
                cmdSelect.Transaction = sqlTrans;
            }

            cmdSelect.CommandText = SQL_LOCAL_SOURCE;

            List<Company> companies = new List<Company>();
            using (SqlDataReader reader = cmdSelect.ExecuteReader())
            {
                while (reader.Read())
                {
                    Company company = new Company();
                    company.CompanyID = reader.GetInt32(0);

                    if ((reader[1] != DBNull.Value) &&
                        (reader[1] != null)) {
                        company.hasPACA = true;
                    }

                    companies.Add(company);
                }
            }

            return companies;
        }


        private const string SQL_UPDATE_LISTINGSTATUS =
            @"UPDATE Company 
                 SET comp_PRListingStatus = @ListingStatus, 
                     comp_PRLocalSource = CASE @ListingStatus WHEN 'N3' THEN comp_PRLocalSource ELSE NULL END,
                     comp_UpdatedBy=@UpdatedBy, 
                     comp_UpdatedDate=@UpdatedDate, 
                     comp_Timestamp=@Timestamp    
               WHERE comp_CompanyID = @CompanyID";

        private SqlCommand cmdNonFactor = null;


        public void MarkNonFactor(SqlTransaction sqlTrans)
        {

            string listingStatus = "N3";
            string explanation = "Non-Factor";
            if (hasPACA)
            {
                listingStatus = "N2";
                explanation = "Listing Membership Prospect";
            }

            StringBuilder sbExplanation = new StringBuilder(string.Format("Company marked {0} because not found in Local Source import." + Environment.NewLine, explanation));
            int transactionID = OpenPIKSTransaction(sqlTrans, CompanyID, 0, sbExplanation.ToString());


            if (cmdNonFactor == null)
            {
                cmdNonFactor = new SqlCommand();
                cmdNonFactor.Connection = sqlTrans.Connection;
                cmdNonFactor.Transaction = sqlTrans;
            }



            cmdNonFactor.CommandText = SQL_UPDATE_LISTINGSTATUS;
            cmdNonFactor.Parameters.Clear();
            cmdNonFactor.Parameters.AddWithValue("CompanyID", CompanyID);
            cmdNonFactor.Parameters.AddWithValue("ListingStatus", listingStatus);
            cmdNonFactor.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdNonFactor.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdNonFactor.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
            cmdNonFactor.ExecuteNonQuery();

            ClosePIKSTransaction(transactionID, sqlTrans);
        }

        public string GetCityIDs() {

            StringBuilder cityIDs = new StringBuilder();

            foreach (Address address in Addresses)
            {
                if (address.CityID > 0)
                {
                    if (cityIDs.Length > 0)
                    {
                        cityIDs.Append(",");
                    }
                    cityIDs.Append(address.CityID.ToString());
                }
            }

            return cityIDs.ToString();
        }





        protected const string SQL_PROFILE_EXISTS = "SELECT 'x' FROM PRCompanyProfile WHERE prcp_CompanyId = @prcp_CompanyId";

        protected const string SQL_PROFILE_INSERT =
             "INSERT INTO PRCompanyProfile (prcp_CompanyProfileId, prcp_CompanyId, prcp_Organic, prcp_FoodSafetyCertified, prcp_CreatedBy, prcp_CreatedDate, prcp_UpdatedBy, prcp_UpdatedDate, prcp_Timestamp) " +
                          "VALUES (@prcp_CompanyProfileId,@prcp_CompanyId,@prcp_Organic,@prcp_FoodSafetyCertified, @CreatedBy, @CreatedDate, @UpdatedBy, @UpdatedDate, @Timestamp);";

        protected const string SQL_PROFILE_UPDATE =
            @"UPDATE PRCompanyProfile 
                 SET prcp_Organic=@prcp_Organic, 
                     prcp_FoodSafetyCertified=@prcp_FoodSafetyCertified, 
                     prcp_UpdatedBy=@UpdatedBy, 
                     prcp_UpdatedDate=@UpdatedDate, 
                     prcp_Timestamp=@Timestamp  
               WHERE prcp_CompanyId = @prcp_CompanyId";

        public void SaveProfile(SqlTransaction sqlTrans)
        {



            // If this is a new company and we don't have the licenses 
            // we're looking for, don't create a new PRCompanyProfile
            // record.
            if (NewRecord && string.IsNullOrEmpty(organicLicense) && string.IsNullOrEmpty(foodsafetyLicense))
            {
                return;
            }

            SqlCommand cmdRecordExists = sqlTrans.Connection.CreateCommand();
            cmdRecordExists.Transaction = sqlTrans;
            cmdRecordExists.CommandText = SQL_PROFILE_EXISTS;
            cmdRecordExists.Parameters.AddWithValue("prcp_CompanyId", CompanyID);
            object exists = cmdRecordExists.ExecuteScalar();

            SqlCommand cmdSave = sqlTrans.Connection.CreateCommand();
            cmdSave.Transaction = sqlTrans;
            cmdSave.CommandTimeout = 120;

            int recordID = 0;
            if (exists == null)
            {
                recordID = GetPIKSID("PRCompanyProfile", sqlTrans);
                cmdSave.CommandText = SQL_PROFILE_INSERT;
            }
            else
            {
                cmdSave.CommandText = SQL_PROFILE_UPDATE;
            }

            cmdSave.Parameters.AddWithValue("prcp_CompanyProfileId", recordID);
            cmdSave.Parameters.AddWithValue("prcp_CompanyId", CompanyID);
            AddParameter(cmdSave, "prcp_Organic", organicLicense);
            AddParameter(cmdSave, "prcp_FoodSafetyCertified", foodsafetyLicense);
            cmdSave.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
            cmdSave.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
            cmdSave.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdSave.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdSave.Parameters.AddWithValue("Timestamp", UPDATED_DATE);

            cmdSave.ExecuteScalar();
        }

        private void HandleCompanyName()
        {
            if ((CompanyName.ToLower() == "0") ||
                (CompanyName.ToLower() == "farm") ||
                (CompanyName.ToLower() == "farms") ||
                (CompanyName.ToLower() == "usda") ||
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

            if (CompanyName.ToLower().Contains("university"))
            {
                CompanyName = string.Empty;
                IsValid = false;
                Skip = true;
            }
        }

        private const string SQL_OWNERSHIP_RELATIONS_EXIST =
            @"SELECT 'x' FROM PRCompanyRelationship WITH (NOLOCK) 
               WHERE prcr_RightCompanyId=@CompanyID
                 AND prcr_Type IN ('27', '28') 
                 AND prcr_Active = 'Y'";
        private SqlCommand cmdSelectOwnership = null;



        private bool HasOnwershipRelations(SqlConnection sqlConn, SqlTransaction sqlTran, int companyID)
        {
            if (cmdSelectOwnership == null)
            {
                cmdSelectOwnership = new SqlCommand();
                cmdSelectOwnership.CommandText = SQL_OWNERSHIP_RELATIONS_EXIST;
            }
            cmdSelectOwnership.Connection = sqlConn;
            cmdSelectOwnership.Transaction = sqlTran;

            cmdSelectOwnership.Parameters.Clear();
            cmdSelectOwnership.Parameters.AddWithValue("CompanyID", companyID);

            object result = cmdSelectOwnership.ExecuteScalar();
            if ((result == null) ||
                (result == DBNull.Value))
            {
                return false;
            }

            return true;
        }

        private const string SQL_OWNERSHIP_RELATIONS_DELETE =
            @"ALTER TABLE PRCompanyRelationship DISABLE TRIGGER trg_PRCompanyRelationship_insdel;
             DELETE FROM PRCompanyRelationship 
               WHERE prcr_RightCompanyId=@CompanyID
                 AND prcr_Type IN ('27', '28');
              ALTER TABLE PRCompanyRelationship ENABLE TRIGGER trg_PRCompanyRelationship_insdel;";
        private SqlCommand cmdDeleteOwnership = null;

        private void DeleteOnwershipRelations(SqlTransaction sqlTrans, int companyID)
        {
            if (cmdDeleteOwnership == null)
            {
                cmdDeleteOwnership = new SqlCommand();
                cmdDeleteOwnership.Connection = sqlTrans.Connection;
                cmdDeleteOwnership.Transaction = sqlTrans;
                cmdDeleteOwnership.CommandText = SQL_OWNERSHIP_RELATIONS_DELETE;
            }

            cmdDeleteOwnership.Parameters.Clear();
            cmdDeleteOwnership.Parameters.AddWithValue("CompanyID", companyID);
            cmdDeleteOwnership.ExecuteNonQuery();
        }


        private const string SQL_BRANDS_EXIST = "SELECT 'x' FROM PRCompanyBrand WITH (NOLOCK) WHERE prc3_CompanyID=@CompanyID";
        private SqlCommand cmdSelectBrand = null;


        private const string SQL_BRANDS_DELETE = "DELETE FROM PRCompanyBrand WHERE prc3_CompanyID=@CompanyID";
        private SqlCommand cmdDeleteBrand = null;

        private bool HasBrands(SqlConnection sqlConn, SqlTransaction sqlTran, int companyID)
        {
            if (cmdSelectBrand == null)
            {
                cmdSelectBrand = new SqlCommand();
                cmdSelectBrand.CommandText = SQL_BRANDS_EXIST;
            }
            cmdSelectBrand.Connection = sqlConn;
            cmdSelectBrand.Transaction = sqlTran;

            cmdSelectBrand.Parameters.Clear();
            cmdSelectBrand.Parameters.AddWithValue("CompanyID", companyID);

            object result = cmdSelectBrand.ExecuteScalar();
            if ((result == null) ||
                (result == DBNull.Value))
            {
                return false;
            }

            return true;
        }

        private void DeleteBrands(SqlTransaction sqlTrans, int companyID)
        {
            if (cmdDeleteBrand == null)
            {
                cmdDeleteBrand = new SqlCommand();
                cmdDeleteBrand.Connection = sqlTrans.Connection;
                cmdDeleteBrand.Transaction = sqlTrans;
                cmdDeleteBrand.CommandText = SQL_BRANDS_DELETE;
            }

            cmdDeleteBrand.Parameters.Clear();
            cmdDeleteBrand.Parameters.AddWithValue("CompanyID", companyID);
            cmdDeleteBrand.ExecuteNonQuery();
        }



        private const string SQL_PACA_EXIST =
            @"SELECT 'x'
              FROM PRPACALicense
             WHERE prpa_CompanyID = @CompanyID
               AND prpa_Publish = 'Y';";

        private SqlCommand cmdSelectPACA = null;


        private const string SQL_PACA_UNPUBLISH=
            @"UPDATE PRPACALicense SET prpa_Publish = NULL, prpa_UpdatedBy=@UpdatedBy, prpa_UpdatedDate=@UpdatedDate WHERE prpa_CompanyID = @CompanyID AND prpa_Publish = 'Y';";
        private SqlCommand cmdUpdatePACA = null;

        private bool HasPACA(SqlConnection sqlConn, SqlTransaction sqlTran, int companyID)
        {
            if (cmdSelectPACA == null)
            {
                cmdSelectPACA = new SqlCommand();
                cmdSelectPACA.CommandText = SQL_PACA_EXIST;
            }
            cmdSelectPACA.Connection = sqlConn;
            cmdSelectPACA.Transaction = sqlTran;

            cmdSelectPACA.Parameters.Clear();
            cmdSelectPACA.Parameters.AddWithValue("CompanyID", companyID);

            object result = cmdSelectPACA.ExecuteScalar();
            if ((result == null) ||
                (result == DBNull.Value))
            {
                return false;
            }

            return true;
        }

        private void UpdatePACA(SqlTransaction sqlTrans, int companyID)
        {
            if (cmdUpdatePACA == null)
            {
                cmdUpdatePACA = new SqlCommand();
                cmdUpdatePACA.Connection = sqlTrans.Connection;
                cmdUpdatePACA.Transaction = sqlTrans;
                cmdUpdatePACA.CommandText = SQL_PACA_UNPUBLISH;
            }

            cmdUpdatePACA.Parameters.Clear();
            cmdUpdatePACA.Parameters.AddWithValue("CompanyID", companyID);
            cmdUpdatePACA.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdUpdatePACA.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdUpdatePACA.ExecuteNonQuery();
        }


        private const string SQL_DRC_EXIST =
            @"SELECT 'x'
              FROM PRDRCLicense
             WHERE prdr_CompanyID = @CompanyID
               AND prdr_Publish = 'Y'";
        private SqlCommand cmdSelectDRC= null;
        private bool HasDRC(SqlConnection sqlConn, SqlTransaction sqlTran, int companyID)
        {
            if (cmdSelectDRC == null)
            {
                cmdSelectDRC = new SqlCommand();
                cmdSelectDRC.CommandText = SQL_DRC_EXIST;
            }

            cmdSelectDRC.Connection = sqlConn;
            cmdSelectDRC.Transaction = sqlTran;

            cmdSelectDRC.Parameters.Clear();
            cmdSelectDRC.Parameters.AddWithValue("CompanyID", companyID);

            object result = cmdSelectDRC.ExecuteScalar();
            if ((result == null) ||
                (result == DBNull.Value))
            {
                return false;
            }

            return true;
        }


        private const string SQL_DRC_UNPUBLISH =
            @"UPDATE PRDRCLicense SET prdr_Publish = NULL, prdr_UpdatedBy=@UpdatedBy, prdr_UpdatedDate=@UpdatedDate WHERE prdr_CompanyID = @CompanyID AND prdr_Publish = 'Y';";
        private SqlCommand cmdUpdateDRC = null;
        private void UpdateDRC(SqlTransaction sqlTrans, int companyID)
        {
            if (cmdUpdateDRC == null)
            {
                cmdUpdateDRC = new SqlCommand();
                cmdUpdateDRC.Connection = sqlTrans.Connection;
                cmdUpdateDRC.Transaction = sqlTrans;
                cmdUpdateDRC.CommandText = SQL_DRC_UNPUBLISH;
            }

            cmdUpdateDRC.Parameters.Clear();
            cmdUpdateDRC.Parameters.AddWithValue("CompanyID", companyID);
            cmdUpdateDRC.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdUpdateDRC.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdUpdateDRC.ExecuteNonQuery();
        }


        private const string SQL_TES_UPDATE =
            @"UPDATE PRAttentionLine
		         SET prattn_PhoneID = @PhoneID,
                     prattn_EmailID = @EmailID, 
                     prattn_PersonID = @PersonID,
                     prattn_Disabled = @Disabled, 
                     prattn_UpdatedBy = @UpdatedBy, 
                     prattn_UpdatedDate = @UpdatedDate 
		       WHERE prattn_CompanyID = @CompanyId
                 AND prattn_ItemCode = 'TES-E';";

        private SqlCommand cmdUpdateTES = null;

        private void UpdateTES(SqlTransaction sqlTrans, int companyID)
        {
            if (cmdUpdateTES == null)
            {
                cmdUpdateTES = new SqlCommand();
                cmdUpdateTES.Connection = sqlTrans.Connection;
                cmdUpdateTES.Transaction = sqlTrans;
                cmdUpdateTES.CommandText = SQL_TES_UPDATE;
            }

            cmdUpdateTES.Parameters.Clear();
            cmdUpdateTES.Parameters.AddWithValue("CompanyID", companyID);

            int tesEmailID = 0;
            int tesPersonID = 0;
            foreach(Person person in Persons)
            {
                if (person.EmailID > 0)
                {
                    if (tesEmailID == 0)
                    {
                        tesEmailID = person.EmailID;
                        tesPersonID = person.PersonID;
                        break;
                    } 
                }
            }

            int tesFaxID = 0;
            if (tesEmailID == 0)
            {
                foreach(Phone phone in Phones)
                {
                    if ((phone.PhoneID > 0) &&
                        ((phone.Type == "F") ||
                         (phone.Type == "PF")))
                    {
                        tesFaxID = phone.PhoneID;
                        break;
                    }
                }
            }


            AddParameter(cmdUpdateTES, "EmailID", tesEmailID);
            AddParameter(cmdUpdateTES, "PhoneID", tesFaxID);
            AddParameter(cmdUpdateTES, "PersonID", tesPersonID);

            if (tesEmailID == 0 && tesFaxID == 0)
            {
                cmdUpdateTES.Parameters.AddWithValue("Disabled", "Y");
            } else
            {
                cmdUpdateTES.Parameters.AddWithValue("Disabled", DBNull.Value);
            }


            cmdUpdateTES.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdUpdateTES.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdUpdateTES.ExecuteNonQuery();
        }


        public void SetInvalid(string msg)
        {
            if (!IsValid)
            {
                InvalidReason += ", ";
            }
            IsValid = false;
            InvalidReason += msg;

        }
    }
}
