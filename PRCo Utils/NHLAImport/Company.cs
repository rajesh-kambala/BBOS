using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace NHLAImport
{
    public class Company
    {
        public int CRMCompanyID { get; set; }
        public string NHLACompany { get; set; }
        public string NHLAddressPrimary { get; set; }
        public string NHLAddressSecondary { get; set; }
        public string NHLACity { get; set; }
        public string NHLAState { get; set; }
        public string NHLAZipCode { get; set; }
        public string NHLACountry { get; set; }
        public string NHLAPhone { get; set; }
        public string NHLAFax { get; set; }
        public string NHLAWeb { get; set; }
        public string NHLAEmail { get; set; }
        public int Section { get; set; }
        public int OksSequenceID { get; set; }
        public int OkBatchID { get; set; }
        public int Branch_Of_Seq_ID { get; set; }

        public List<ImportsFrom> Imports { get; set; }
        public List<ExportsTo> Exports { get; set; }
        public List<BusinessType> BusinessTypes { get; set; }
        public List<SalesContact> SalesContacts { get; set; }
        public List<SalesContact> ExpSalesContacts { get; set; }
        public List<Product> Products { get; set; }

        public string NHLAImporter { get; set; }
        public string NHLAExporter { get; set; }
        public string NHLAHTAudited { get; set; }
        public string NHLAGradeCertified { get; set; }
        public string NHLASFICertified { get; set; }
        public string NHLASFIPart { get; set; }
        public string NHLAFSCCertified { get; set; }
        public string NHLAOtherCertification { get; set; }
        public string NHLAMembershipType { get; set; }

        public bool Inserted { get; set; }
    }
}
