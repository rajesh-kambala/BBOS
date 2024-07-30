using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using LumenWorks.Framework.IO.Csv;

namespace BBSI.CompanyImport
{
    public class Company : ImportBase
    {
        public string CompanyName;
        public string CompanyNameMatch;

        public int CompanyID;
        public int CityID;
        public int StateID;
        public List<Address> Addresses = new List<Address>();
        public List<Phone> Phones = new List<Phone>();
        public List<Commodity> Commodities = new List<Commodity>();
        public List<Classification> Classifications = new List<Classification>();
        public List<Email> EmailList = new List<Email>();


        public Company()
        {
        }


        public void Load(SqlConnection sqlConn, CsvReader csv)
        {
            CompanyName = prepareString(csv["Company Name"]);
            HandleCompanyName();

            AddAddress(sqlConn, csv);
            AddPhone(csv, "P");

            Email email = new Email(null, csv["WebSite"]);
            EmailList.Add(email);

            SetCommodities("Fruit, Vegetable");
            SetClassifications(csv["Classification"]);
        }

        #region Phone
        public void AddPhone(CsvReader csv, string type)
        {
            Phone phone = new Phone();
            phone.Load(csv, type);
            if ((!string.IsNullOrEmpty(phone.Number)) &&
                (phone.Number.Length == 10))
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

        }
        #endregion

        #region Address
        public void AddAddress(SqlConnection sqlConn, CsvReader csv)
        {
            Address address = new Address();
            address.Load(sqlConn, csv);
            address.CompanyID = CompanyID;
            address.Sequence = Addresses.Count + 1;
            AddAddress(address);
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

                if (cityCount.Count > 0)
                {
                    var sortedList = cityCount.OrderByDescending(key => key.Value);
                    string[] work = sortedList.First().Key.Split(',');
                    CityID = Convert.ToInt32(work[0]);
                    StateID = Convert.ToInt32(work[1]);
                }
            }
        }
        #endregion

        #region Commodity
        
        private void SetCommodities(string value)
        {
            string[] commods = value.Split(',');
            foreach (string commod in commods)
            {
                switch (commod.Trim().ToLower())
                {

                    case "Fruit":
                        AddCommodity(37, "F");
                        break;

                    case "Vegetable":
                        AddCommodity(291, "V");
                        break;
                }
            }
        }

        private void AddCommodity(int commodityID, string publishedDisplay) {
            Commodity commod = new Commodity(commodityID, publishedDisplay, Commodities.Count + 1);
            AddCommodity(commod);
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

            Commodities.Add(commod);
        }
        #endregion

        #region Classification
        private void SetClassifications(string value)
        {
            string[] classifications = value.Split(',');
            foreach (string classification in classifications)
            {
                switch (classification.Trim().ToLower())
                {
                    case "chipper":
                        AddClassification(150);
                        break;
                    case "distributor":
                        AddClassification(180);
                        break;
                    case "Importer":
                        AddClassification(220);
                        break;
                    case "jobber":
                        AddClassification(230);
                        break;
                    case "foodservice":
                        AddClassification(190);
                        break;
                    case "fresh cut processor":
                        AddClassification(210);
                        break;
                    case "juicer":
                        AddClassification(240);
                        break;
                    case "receiver":
                        AddClassification(300);
                        break;
                    case "retail":
                        AddClassification(330);
                        break;
                    case "restaurant":
                        AddClassification(320);
                        break;
                }
            }
        }

        private void AddClassification(int classifciationID)
        {
            Classification classification = new Classification(classifciationID);
            AddClassification(classification);
        }

        public void AddClassification(Classification classification)
        {

            // Look for duplicates and skip them
            foreach (Classification classification2 in Classifications)
            {
                if (classification2.ClassificationID == classification.ClassificationID)
                {
                    return;
                }
            }

            Classifications.Add(classification);
        }
        #endregion


        protected const string SQL_COMPANY_INSERT =
            "INSERT INTO Company (comp_CompanyID, comp_PRHQID,     comp_Name, comp_PRTradestyle1, comp_PRCorrTradestyle, comp_PRBookTradestyle, comp_PRType, comp_PRListingStatus, comp_PRListingCityID, comp_PRIndustryType, comp_Source, comp_CreatedBy, comp_CreatedDate, comp_UpdatedBy, comp_UpdatedDate, comp_Timestamp) " +
                         "VALUES (@comp_CompanyID,@comp_CompanyID,@comp_Name,@comp_Name,         @comp_Name,            @comp_Name,            @comp_PRType,@comp_PRListingStatus,@comp_PRListingCityID,@comp_PRIndustryType,@comp_Source, @CreatedBy, @CreatedDate, @UpdatedBy, @UpdatedDate, @Timestamp)";

        public void SaveCompany(SqlTransaction sqlTrans)
        {
            SetCityID();

            int transactionID = 0;

            SqlCommand cmdSave = sqlTrans.Connection.CreateCommand();
            cmdSave.Transaction = sqlTrans;

            CompanyID = GetPIKSID("Company", sqlTrans);
            cmdSave.CommandText = SQL_COMPANY_INSERT;


            cmdSave.CommandTimeout = 300;
            cmdSave.Parameters.AddWithValue("comp_CompanyID", CompanyID);
            cmdSave.Parameters.AddWithValue("comp_PRHQID", CompanyID);
            cmdSave.Parameters.AddWithValue("comp_Name", CompanyName);
            cmdSave.Parameters.AddWithValue("comp_PRType", "H");
            cmdSave.Parameters.AddWithValue("comp_PRListingStatus", "L");
            cmdSave.Parameters.AddWithValue("comp_PRListingCityID", CityID);
            cmdSave.Parameters.AddWithValue("comp_PRIndustryType", "P");
            cmdSave.Parameters.AddWithValue("comp_Source", "Import");
            cmdSave.Parameters.AddWithValue("CreatedBy", UPDATED_BY);
            cmdSave.Parameters.AddWithValue("CreatedDate", UPDATED_DATE);
            cmdSave.Parameters.AddWithValue("UpdatedBy", UPDATED_BY);
            cmdSave.Parameters.AddWithValue("UpdatedDate", UPDATED_DATE);
            cmdSave.Parameters.AddWithValue("Timestamp", UPDATED_DATE);
            cmdSave.ExecuteNonQuery();


            if (transactionID == 0)
            {
                StringBuilder sbExplanation = new StringBuilder("Company created from import." + Environment.NewLine);
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

            Email.DeleteAll(sqlTrans, CompanyID, 0);
            foreach (Email email in EmailList)
            {
                email.CompanyID = CompanyID;
                email.Save(sqlTrans);
            }

            Classification.DeleteAll(sqlTrans, CompanyID);
            foreach (Classification classification in Classifications)
            {
                classification.CompanyID = CompanyID;
                classification.Save(sqlTrans);
            }

            Commodity.DeleteAll(sqlTrans, CompanyID);
            foreach (Commodity mmwCommodity in Commodities)
            {
                mmwCommodity.CompanyID = CompanyID;
                mmwCommodity.Save(sqlTrans);
            }

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
        }

        public bool IsValid = true;
        public string InvalidReason;
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
