using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace CompanyMatching
{
    class Company
    {
        public string MatchType {get; set;}
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
        public string NHLACompany { get; set; }
        public string NHLAddressPrimary { get; set; }
        public string NHLAddressSecondary { get; set; }
        public string NHLCity { get; set; }
        public string NHLAState { get; set; }
        public string NHLZipCode { get; set; }
        public string NHLACountry { get; set; }
        public string NHLAPhone { get; set; }
        public string NHLAFax { get; set; }
        public string NHLAWeb { get; set; }
        public string NHLAEmail { get; set; }
        public int Section { get; set; }
        public int OksSequenceID { get; set; }
        public string CRMLegalName { get; set; }
        public string PhoneForMatch { get; set; }
        public enum MatchTypes { Phone, Fax, Web, Email, CompanyName };
    }
}
