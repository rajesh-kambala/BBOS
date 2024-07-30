using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace CompanyMatching
{
    class NRLACompany
    {
        public string MatchType { get; set; }
        public int BBID { get; set; }
        public string IndustryType { get; set; }
        public string ListingStatus { get; set; }
        public string CRMCompanyName { get; set; }
        public string CRMMailingAddress { get; set; }
        public string CRMPhysicalAddress { get; set; }
        public string CRMDefaultPhone { get; set; }
        public string CRMDefaultFax { get; set; }
        public string CRMDefaultWeb { get; set; }
        public string CRMDefaultEmail { get; set; }
        public int CRMCompPRHQID { get; set; }
        public string NRLACompanyName { get; set; }
        public string NRLAddressPrimary { get; set; }
        public string NRLAddressSecondary { get; set; }
        public string NRLACity { get; set; }
        public string NRLAState { get; set; }
        public string NRLAZipCode { get; set; }
        public string NRLACountry { get; set; }
        public string NRLAPhone { get; set; }
        public string NRLAURL { get; set; }
        public string NRLAStatus {get; set;}
        public string HQCompany {get; set;}
        public string HQAddressPrimary {get; set;}
        public string HQAddressSecondary {get; set;}
        public string HQCity {get; set;}
        public string HQState {get; set;}
        public string HQZipCode {get; set;}
        public string HQCountry {get; set;}
        public string HQPhone {get; set;}
        public string HQTollFree {get; set;}
        public string HQFax {get; set;}
        public string HQURL {get; set;}
        public string HQEmail {get; set;}
        public int HQRecID { get; set; }
        public int OKsBatchID { get; set; }
        public string OKsComment { get; set; }
        public string CRMLegalName { get; set; }
        public string PhoneForMatch { get; set; }
        public enum MatchTypes { HQCompanyName, HQPhone, HQFax, HQURL, HQEmail, NRLACompanyName, NRLAPhone, NRLAURL };

    }
}
