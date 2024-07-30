using System;
using System.ComponentModel;

namespace BBOSMobile.ServiceModels.Common
{
    public static class Enumerations
    {
        public enum ResponseStatus
        {
            Failure,
            Success,
			InvalidUserId,
			Unauthorized
        }

		public enum UserType
		{
			Produce,
			Lumber
		}

        public enum UserLevel
        {
            Limited,
            Basic,
            Intermediate,
            Advanced,
            Premium
        }

        public enum SearchType
        {
            Any,
            Headquarters,
            Branch
        }

        public enum IndustryType
        {
            Produce,
            Transportation,
            Supply,
			Lumber
        }

        public enum Radius
        {
            Any = -1,
            TenMiles = 10,
            TwentyFiveMiles = 25,
            FiftyMiles = 50,
            HundredMiles = 100,
        }

        public enum BBScore
        {
           _850plussign = 850,
           _900plussign = 900,
           _950plussign = 950,
           _975plussign = 975
        }

        public enum IntegrityRating
        {
			Any,
            XXX,
            XXXOrHigher,
            XXXX
        }

        public enum PayDescription
        {
			Any,
            AOrHigher,
            BOrHigher,
            COrHigher
        }

        public enum CreditWorthRating       
        { 
            _5mil_orHigher = 5,
            _100mil_orHigher = 100,
            _500mil_orHigher = 500
        }

		public enum CurrentPayReport
		{
			Any,
			GreaterThan__1,
			GreaterThan__2,
			GreaterThan__3,
			GreaterThan__4
		}

		public enum PayIndicator
		{
			Any,
			A,
			BOrHigher,
			COrHigher
		}

		public enum Privilege
		{
			CompanyDetailsClassificationsCommoditesPage,
			CompanyDetailsClassificationsCommoditesProductSerivcesSpeciesPage,
			CompanyDetailsContactsPage,
			CompanyDetailsListingPage,
			CompanySearchByBBScore,
			CompanySearchByClassifications,
			CompanySearchByCommodities,
			CompanySearchByCreditWorthRating,
			CompanySearchByIntegrityRating,
			CompanySearchByPayIndicator,
			CompanySearchByPayRating,
			CompanySearchByPayReportCount,
			CompanySearchByProducts,
			CompanySearchByRadius,
			CompanySearchByServices,
			CompanySearchBySpecie,
			CompanySearchByTerminalMarket,
			Notes,
			PersonDetailsPage,
			RecentViewsPage,
			ViewBBScore,
			ViewRating,
			WatchdogListAdd,
			WatchdogListsPage,
            ContactDetailsListingPage,
            ContactDetailsContactsPage
        }




    }
}
