using BBOSMobile.ServiceModels.Common;
using System;
using System.Collections.Generic;

namespace BBOSMobile.ServiceModels.Requests
{
    public class CompanySearchRequest: RequestBase
    {
        public string CompanyName { get; set; }

        public string BBID { get; set; }

        public Enumerations.SearchType SearchType { get; set; }

        public string State { get; set; }

        public string City { get; set; }

        public string PostalCode { get; set; }

        public Enumerations.Radius Radius { get; set; }

        public string TerminalMarket { get; set; }

        public Enumerations.BBScore BBScore { get; set; }

        public Enumerations.IntegrityRating IntegrityRating { get; set; }

        public Enumerations.PayDescription PayDescription { get; set; }

		public Enumerations.PayIndicator PayIndicator { get; set; }

		public Enumerations.CurrentPayReport CurrentPayReport { get; set; }

        public Enumerations.CreditWorthRating CreditWorthRating { get; set; }

        public int CommodityId { get; set; }

        public int ClassificationId { get; set; }

		public int SpecieId { get; set; }

		public int ProductId { get; set; }

        public int ServiceId { get; set; }

		public DateTime CategoryListsLastUpdated { get; set; }
    }
}
