using System;
using BBOSMobile.Core.Managers;
using BBOSMobile.Core.Models;
using System.Collections.Generic;
using System.Linq;
using System.Collections.ObjectModel;

namespace BBOSMobile.Forms.ViewModels
{
	public class ContactSearchViewModel : BaseViewModel
	{
		public ContactSearchViewModel ()
		{
			SelectedIndustry = new EnumPlaceholder () {Id = -1, Definition = "Industry"};
            SelectedState = new State() { StateId = -1, Name = "State" };
            SelectedRadius = new EnumPlaceholder() { Id = -1, Definition = "Radius" };
        }

		public enum Selection
		{
			None,
			Industry,
            Radius,
            State
            
		}

		//Which dropdown did they select on the search page
		public Selection SelectedDropdown {get;set;}

		//Standard text fields
		public string LastName {get;set;}
		public string FirstName {get;set;}
		public string Title {get;set;}
		public string Email {get;set;}

        public string City { get; set; }
        public string Zip { get; set; }



        //The dropdown item that was selected on the detail page
        public Classification SelectedClassification {get;set;}

        public List<State> States { get; set; }

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
        public const string SelectedIndustryPropertyName = "SelectedIndustry";
		private EnumPlaceholder selectedIndustry = new EnumPlaceholder () {Id = -1, Definition = "Industry"};
		public EnumPlaceholder SelectedIndustry
		{
			get { return selectedIndustry; }
			set { SetProperty(ref selectedIndustry, value, SelectedIndustryPropertyName); }
		}


        public const string SelectedStatePropertyName = "SelectedState";
        private State selectedState = new State() { StateId = -1, Name = "State" };
        public State SelectedState
        {
            get { return selectedState; }
            set { SetProperty(ref selectedState, value, SelectedStatePropertyName); }
        }

        public const string SelectedRadiusPropertyName = "SelectedRadius";
        private EnumPlaceholder selectedRadius = new EnumPlaceholder() { Id = -1, Definition = "Radius" };
        public EnumPlaceholder SelectedRadius
        {
            get { return selectedRadius; }
            set { SetProperty(ref selectedRadius, value, SelectedRadiusPropertyName); }
        }


        public List<EnumPlaceholder> Industry {get;set;}


		public int PageSize {get;set;}
		public int PageIndex {get;set;}
		public ObservableCollection<ContactListItemViewModel> Contacts { get; set; }

		public bool IsLumber {get;set;}

        public List<EnumPlaceholder> Radius { get; set; }



    }
    /*
	public class EnumPlaceholder{
		public int Id {get;set;}
		public string Definition {get;set;}
	}
    */
}

