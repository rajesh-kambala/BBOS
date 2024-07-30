using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace LumberLeadsImport
{
    public class Lead
    {
        public int BatchID;
        public int MatchedLeadID;
        public string MatchType;
        public bool Exists;
        public bool ExistsInCRM;
        public bool ExportedForValidation;
        public string ListingStatus;

        public int LeadID;
        public string Source;
        public int AssociatedCompanyID;
        public string CompanyName;
        public string AlternateName;
        public string Rating;
        public string MiscInfo;
        public string FirstAddress1;
        public string FirstAddress2;
        public string FirstCity;
        public string FirstState;
        public string FirstCountry;
        public string FirstPostCode;
        public string SecondAddress1;
        public string SecondAddress2;
        public string SecondCity;
        public string SecondState;
        public string SecondCountry;
        public string SecondPostCode;
        public string PhoneNumber;
        public string FaxNumber;
        public string Email;
        public string WebSite;

        public string Description;
        public string ListingCity;
        public string ListingState;
        public string OriginalRedBookName;
        public string CustomerNumber;

        public string Status;
        public string StatusChangedBy;
        public string StatusChangedDate;

        public int ARDetailCount;
        public DateTime LastARDate;


        public void ValidatePhone()
        {
            if (!string.IsNullOrEmpty(PhoneNumber))
            {
                if ((PhoneNumber.Length < 7) ||
                    (PhoneNumber.IndexOf("E+") >= 0) ||
                    (PhoneNumber.StartsWith("/")))
                {
                    PhoneNumber = null;
                }
            }

            if (!string.IsNullOrEmpty(FaxNumber))
            {
                if ((FaxNumber.Length < 7) ||
                    (FaxNumber.IndexOf("E+") >= 0) ||
                    (FaxNumber.StartsWith("/")))
                {
                    FaxNumber = null;
                }
            }

        }
    }
}
