using System;
using BBOSMobile.Core.Managers;
using BBOSMobile.Core.Models;
using System.Collections.Generic;
using System.Linq;
using System.Collections.ObjectModel;

namespace BBOSMobile.Forms.ViewModels
{
	public class CompanySearchViewModel : BaseViewModel
	{
		public CompanySearchViewModel ()
		{
			SelectedSearchType = new EnumPlaceholder () {Id = -1, Definition = "Type"};
			SelectedIndustry = new EnumPlaceholder () {Id = -1, Definition = "Industry"};
			SelectedState = new State () { StateId = -1, Name = "State" };
			SelectedRadius = new EnumPlaceholder () {Id = -1, Definition = "Radius"};
			SelectedTerminalMarket = new TerminalMarket () {TerminalMarketId = -1, Name = "Terminal Market"};
			SelectedBBScore = new EnumPlaceholder () {Id = -1, Definition = "BB Score Range"};
			SelectedIntegrity = new EnumPlaceholder () {Id = -1, Definition = "Trade Practices Rating"};
			SelectedPay = new EnumPlaceholder () {Id = -1, Definition = "Pay Description"};
			SelectedPayIndicator = new EnumPlaceholder(){Id = -1, Definition = "Pay Indicator"};
			SelectedCreditWorthyRating = new EnumPlaceholder () {Id = -1, Definition = "Credit Worth Rating"};
			SelectedSpecie = new Specie () {SpecieId = -1, Name = "Specie"};
			SelectedClassification = new Classification () {ClassificationId = -1, Definition = "Classification"};
			SelectedCommodity = new Commodity () {CommodityID = -1, Definition = "Commodity"};
			SelectedService = new Service () {ServiceId = -1, Name = "Services"};
			SelectedProduct = new Product () {ProductId = -1, Name = "Product"};
			SelectedSpecie = new Specie () {SpecieId = -1, Name = "Specie"};
			SelectedPayReport = new EnumPlaceholder () {Id = -1, Definition = "Current Pay Reports"};



        }

		public enum Selection
		{
			None,
			Classification,
			Industry,
			Commodity,
			SearchType,
			CreditWorthyRating,
			BBScore,
			Radius,
			Integrity,
			Pay,
			PayIndicator,
			CurrentPayReport,
			Specie,
			Product,
			Services,
			TerminalMarket,
			State
		}

		//Which dropdown did they select on the search page
		public Selection SelectedDropdown {get;set;}

		//Standard text fields
		public string CompanyName {get;set;}
		public string BBNumber {get;set;}
		public string City {get;set;}
		public string Zip {get;set;}

		//The dropdown item that was selected on the detail page
		//public Classification SelectedClassification {get;set;}
		//public Commodity SelectedCommodity { get; set; }
		//public State SelectedState {get;set;}
		//public Specie SelectedSpecie { get; set; }
		//public Product SelectedProduct { get; set; }
		//public Service SelectedService { get; set; }
		//public TerminalMarket SelectedTerminaMarket {get;set;}

		//public EnumPlaceholder SelectedCreditWorthyRating { get; set; }
		//public EnumPlaceholder SelectedBBScore { get; set; }
		//public EnumPlaceholder SelectedSearchType {get;set;}
		//public EnumPlaceholder SelectedIndustry {get;set;}
		//public EnumPlaceholder SelectedRadius {get;set;}
		//public EnumPlaceholder SelectedIntegrity {get;set;}
		//public EnumPlaceholder SelectedPay {get;set;}
		//public EnumPlaceholder SelectedPayReport {get;set;}

		//The dropdown item lists
		public List<Classification> Classifications { get; set; }
		public List<Commodity> Commodities { get; set; }
		public List<Specie> Species { get; set; }
		public List<Product> Products { get; set; }
		public List<Service> Services { get; set; }
		public List<State> States {get;set;}
		public List<TerminalMarket> TerminalMarkets { get; set; }
		public List<EnumPlaceholder> CreditWorthyRating {get;set;}
		public List<EnumPlaceholder> BBScore {get;set;}
		//public List<EnumPlaceholder> SearchType {get;set;}

		public const string SelectedStatePropertyName = "SelectedState";
		private State selectedState = new State () {StateId = -1, Name = "State"};
		public State SelectedState
		{
			get { return selectedState; }
			set { SetProperty(ref selectedState, value, SelectedStatePropertyName); }
		}

		public const string SelectedServicePropertyName = "SelectedService";
		private Service selectedService = new Service () {ServiceId = -1, Name = "Services"};
		public Service SelectedService
		{
			get { return selectedService; }
			set { SetProperty(ref selectedService, value, SelectedServicePropertyName); }
		}

		public const string SelectedProductPropertyName = "SelectedProduct";
		private Product selectedProduct = new Product () {ProductId = -1, Name = "Product"};
		public Product SelectedProduct
		{
			get { return selectedProduct; }
			set { SetProperty(ref selectedProduct, value, SelectedProductPropertyName); }
		}

		public const string SelectedSpeciePropertyName = "SelectedSpecie";
		private Specie selectedSpecie = new Specie () {SpecieId = -1, Name = "Specie"};
		public Specie SelectedSpecie
		{
			get { return selectedSpecie; }
			set { SetProperty(ref selectedSpecie, value, SelectedSpeciePropertyName); }
		}

		public const string SelectedClassificationPropertyName = "SelectedClassification";
		private Classification selectedClassification = new Classification () {ClassificationId = -1, Definition = "Classification"};
		public Classification SelectedClassification
		{
			get { return selectedClassification; }
			set { SetProperty(ref selectedClassification, value, SelectedClassificationPropertyName); }
		}

		public const string SelectedCommodityPropertyName = "SelectedCommodity";
		private Commodity selectedCommodity = new Commodity () {CommodityID = -1, Definition = "Commodity"};
		public Commodity SelectedCommodity
		{
			get { return selectedCommodity; }
			set { SetProperty(ref selectedCommodity, value, SelectedCommodityPropertyName); }
		}

		public const string SelectedPayReportPropertyName = "SelectedPayReport";
		private EnumPlaceholder selectedPayReport = new EnumPlaceholder () {Id = -1, Definition = "Current Pay Reports"};
		public EnumPlaceholder SelectedPayReport
		{
			get { return selectedPayReport; }
			set { SetProperty(ref selectedPayReport, value, SelectedPayReportPropertyName); }
		}

		public const string SelectedCreditWorthyRatingPropertyName = "SelectedCreditWorthyRating";
		private EnumPlaceholder selectedCreditWorthyRating = new EnumPlaceholder () {Id = -1, Definition = "Credit Worth Rating"};
		public EnumPlaceholder SelectedCreditWorthyRating
		{
			get { return selectedCreditWorthyRating; }
			set { SetProperty(ref selectedCreditWorthyRating, value, SelectedCreditWorthyRatingPropertyName); }
		}

		public const string SelectedSearchTypePropertyName = "SelectedSearchType";
		private EnumPlaceholder selectedSearchType = new EnumPlaceholder () {Id = -1, Definition = "Type"};
		public EnumPlaceholder SelectedSearchType
		{
			get { return selectedSearchType; }
			set { SetProperty(ref selectedSearchType, value, SelectedSearchTypePropertyName); }
		}

		public const string SelectedIndustryPropertyName = "SelectedIndustry";
		private EnumPlaceholder selectedIndustry = new EnumPlaceholder () {Id = -1, Definition = "Industry"};
		public EnumPlaceholder SelectedIndustry
		{
			get { return selectedIndustry; }
			set { SetProperty(ref selectedIndustry, value, SelectedIndustryPropertyName); }
		}

		public const string SelectedRadiusPropertyName = "SelectedRadius";
		private EnumPlaceholder selectedRadius = new EnumPlaceholder () {Id = -1, Definition = "Radius"};
		public EnumPlaceholder SelectedRadius
		{
			get { return selectedRadius; }
			set { SetProperty(ref selectedRadius, value, SelectedRadiusPropertyName); }
		}

		public const string SelectedTerminalMarketPropertyName = "SelectedTerminalMarket";
		private TerminalMarket selectedTerminalMarket = new TerminalMarket () {TerminalMarketId = -1, Name = "Terminal Market"};
		public TerminalMarket SelectedTerminalMarket
		{
			get { return selectedTerminalMarket; }
			set { SetProperty(ref selectedTerminalMarket, value, SelectedTerminalMarketPropertyName); }
		}

		public const string SelectedBBScorePropertyName = "SelectedBBScore";
		private EnumPlaceholder selectedBBScore = new EnumPlaceholder () {Id = -1, Definition = "BB Score Range"};
		public EnumPlaceholder SelectedBBScore
		{
			get { return selectedBBScore; }
			set { SetProperty(ref selectedBBScore, value, SelectedBBScorePropertyName); }
		}

		public const string SelectedIntegrityPropertyName = "SelectedIntegrity";
		private EnumPlaceholder selectedIntegrity = new EnumPlaceholder () {Id = -1, Definition = "Trade Practices Rating"};
		public EnumPlaceholder SelectedIntegrity
		{
			get { return selectedIntegrity; }
			set { SetProperty(ref selectedIntegrity, value, SelectedIntegrityPropertyName); }
		}

		public const string SelectedPayPropertyName = "SelectedPay";
		private EnumPlaceholder selectedPay = new EnumPlaceholder () {Id = -1, Definition = "Pay Description"};
		public EnumPlaceholder SelectedPay
		{
			get { return selectedPay; }
			set {	SetProperty(ref selectedPay, value, SelectedPayPropertyName); }
		}

		public const string SelectedPayIndicatorPropertyName = "SelectedPayIndicator";
		private EnumPlaceholder selectedPayIndicator = new EnumPlaceholder () {Id = -1, Definition = "Pay Indicator"};
		public EnumPlaceholder SelectedPayIndicator
		{
			get { return selectedPayIndicator; }
			set {	SetProperty(ref selectedPayIndicator, value, SelectedPayIndicatorPropertyName); }
		}
			

//		public const string SearchTypePropertyName = "SearchType";
//		private List<EnumPlaceholder> searchTypePropertyName = new List<EnumPlaceholder> ();
//		public List<EnumPlaceholder> SearchType
//		{
//			get { return searchTypePropertyName; }
//			set { SetProperty(ref searchTypePropertyName, value, SearchTypePropertyName); }
//		}

		public List<EnumPlaceholder> Industry {get;set;}
		public List<EnumPlaceholder> Radius {get;set;}
		public List<EnumPlaceholder> Integrity {get;set;}
		public List<EnumPlaceholder> Pay {get;set;}
		public List<EnumPlaceholder> PayIndicator {get;set;}
		public List<EnumPlaceholder> PayReport { get; set; }


		public int PageSize {get;set;}
		public int PageIndex {get;set;}
		public ObservableCollection<CompanyListItemViewModel> Companies { get; set; }

		public bool IsLumber {get;set;}
		public BBOSMobile.ServiceModels.Common.SecurityResult CompanySearchBBScore
		{
			get
			{
				var security = SecurityPrivileges.Find (m => m.PrivilegeName == BBOSMobile.ServiceModels.Common.Enumerations.Privilege.CompanySearchByBBScore); 
				if (security == null)
					return NoSecurity;
				else
					return security;
			} 
		}
		public BBOSMobile.ServiceModels.Common.SecurityResult CompanySearchClassifications
		{
			get
			{
				var security = SecurityPrivileges.Find (m => m.PrivilegeName == BBOSMobile.ServiceModels.Common.Enumerations.Privilege.CompanySearchByClassifications); 
				if (security == null)
					return NoSecurity;
				else
					return security;
			} 
		}
		public BBOSMobile.ServiceModels.Common.SecurityResult CompanySearchCommodities
		{
			get
			{
				var security = SecurityPrivileges.Find (m => m.PrivilegeName == BBOSMobile.ServiceModels.Common.Enumerations.Privilege.CompanySearchByCommodities); 
				if (security == null)
					return NoSecurity;
				else
					return security;
			} 
		}
		public BBOSMobile.ServiceModels.Common.SecurityResult CompanySearchCreditWorthRating
		{
			get
			{
				var security = SecurityPrivileges.Find (m => m.PrivilegeName == BBOSMobile.ServiceModels.Common.Enumerations.Privilege.CompanySearchByCreditWorthRating); 
				if (security == null)
					return NoSecurity;
				else
					return security;
			} 
		}
		public BBOSMobile.ServiceModels.Common.SecurityResult CompanySearchIntegrityRating
		{
			get
			{
				var security = SecurityPrivileges.Find (m => m.PrivilegeName == BBOSMobile.ServiceModels.Common.Enumerations.Privilege.CompanySearchByIntegrityRating); 
				if (security == null)
					return NoSecurity;
				else
					return security;
			} 
		}



		public BBOSMobile.ServiceModels.Common.SecurityResult CompanySearchByPayRating
		{
			get
			{
				var security = SecurityPrivileges.Find (m => m.PrivilegeName == BBOSMobile.ServiceModels.Common.Enumerations.Privilege.CompanySearchByPayRating); 
				if (security == null)
					return NoSecurity;
				else
					return security;
			} 
		}

		public BBOSMobile.ServiceModels.Common.SecurityResult CompanySearchPayIndicator
		{
			get
			{
				var security = SecurityPrivileges.Find (m => m.PrivilegeName == BBOSMobile.ServiceModels.Common.Enumerations.Privilege.CompanySearchByPayIndicator); 
				if (security == null)
					return NoSecurity;
				else
					return security;
			} 
		}
		public BBOSMobile.ServiceModels.Common.SecurityResult CompanySearchPayReportCount
		{
			get
			{
				var security = SecurityPrivileges.Find (m => m.PrivilegeName == BBOSMobile.ServiceModels.Common.Enumerations.Privilege.CompanySearchByPayReportCount); 
				if (security == null)
					return NoSecurity;
				else
					return security;
			} 
		}
		public BBOSMobile.ServiceModels.Common.SecurityResult CompanySearchProducts
		{
			get
			{
				var security = SecurityPrivileges.Find (m => m.PrivilegeName == BBOSMobile.ServiceModels.Common.Enumerations.Privilege.CompanySearchByProducts); 
				if (security == null)
					return NoSecurity;
				else
					return security;
			} 
		}
		public BBOSMobile.ServiceModels.Common.SecurityResult CompanySearchRadius
		{
			get
			{
				var security = SecurityPrivileges.Find (m => m.PrivilegeName == BBOSMobile.ServiceModels.Common.Enumerations.Privilege.CompanySearchByRadius); 
				if (security == null)
					return NoSecurity;
				else
					return security;
			} 
		}
		public BBOSMobile.ServiceModels.Common.SecurityResult CompanySearchServices
		{
			get
			{
				var security = SecurityPrivileges.Find (m => m.PrivilegeName == BBOSMobile.ServiceModels.Common.Enumerations.Privilege.CompanySearchByServices); 
				if (security == null)
					return NoSecurity;
				else
					return security;
			} 
		}
		public BBOSMobile.ServiceModels.Common.SecurityResult CompanySearchSpecie
		{
			get
			{
				var security = SecurityPrivileges.Find (m => m.PrivilegeName == BBOSMobile.ServiceModels.Common.Enumerations.Privilege.CompanySearchBySpecie); 
				if (security == null)
					return NoSecurity;
				else
					return security;
			} 
		}
		public BBOSMobile.ServiceModels.Common.SecurityResult CompanySearchTerminalMarket
		{
			get
			{
				var security = SecurityPrivileges.Find (m => m.PrivilegeName == BBOSMobile.ServiceModels.Common.Enumerations.Privilege.CompanySearchByTerminalMarket); 
				if (security == null)
					return NoSecurity;
				else
					return security;
			} 
		}



	}

	public class EnumPlaceholder{
		public int Id {get;set;}
		public string Definition {get;set;}
	}
}

