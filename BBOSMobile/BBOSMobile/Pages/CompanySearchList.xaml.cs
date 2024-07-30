using System;
using System.Collections.Generic;

using Xamarin.Forms;
using BBOSMobile.Forms.ViewModels;
using BBOSMobile.Forms.Pages;
using BBOSMobile.Core.Models;
using BBOSMobile.Core.Managers;
using System.Linq;
using System.Text.RegularExpressions;



namespace BBOSMobile.Forms
{
	public partial class CompanySearchList : BaseContentPage
	{
		CompanySearchViewModel viewModel;

		public CompanySearchList (CompanySearchViewModel vm)
		{
			InitializeComponent ();
			viewModel = vm;
			SetBindingSourceAndLists ();
			this.BindingContext = viewModel;

			listViewOptions.ItemSelected += listViewOptions_ItemSelected;
		}

	

		private void SetBindingSourceAndLists(){
			//Load up our lists from the database, and set the items source for the list the user
			//will select from

			var bbosDataManager = new BBOSDataManager ();

			if (viewModel.SelectedDropdown == CompanySearchViewModel.Selection.Classification) {
				//need to filter by industry type
				var list = viewModel.Classifications = bbosDataManager.GetAllItems<Classification> ().ToList ();
				if (CompanySearch.ViewModel.SelectedIndustry.Definition == "Transportation") {
					viewModel.Classifications = list.Where(m=>m.IndustryType=="T").ToList();
				} else if (CompanySearch.ViewModel.SelectedIndustry.Definition == "Supply") {
					viewModel.Classifications = list.Where(m=>m.IndustryType=="S").ToList();
				} else {
					if (!viewModel.IsLumber) {
						viewModel.Classifications = list.Where (m => m.IndustryType == "P").ToList ();
					}
				}

				listViewOptions.ItemsSource = viewModel.Classifications;
			} else if (viewModel.SelectedDropdown == CompanySearchViewModel.Selection.Commodity) {
				viewModel.Commodities = bbosDataManager.GetAllItems<Commodity> ().ToList ();
				listViewOptions.ItemsSource = viewModel.Commodities;
			} else if (viewModel.SelectedDropdown == CompanySearchViewModel.Selection.Specie) {
				viewModel.Species = bbosDataManager.GetAllItems<Specie> ().ToList ();
				listViewOptions.ItemsSource = viewModel.Species;
			} else if (viewModel.SelectedDropdown == CompanySearchViewModel.Selection.Product) {
				viewModel.Products = bbosDataManager.GetAllItems<Product> ().ToList ();
				listViewOptions.ItemsSource = viewModel.Products;
			} else if (viewModel.SelectedDropdown == CompanySearchViewModel.Selection.Services) {
				viewModel.Services = bbosDataManager.GetAllItems<Service> ().ToList ();
				listViewOptions.ItemsSource = viewModel.Services;
			}else if (viewModel.SelectedDropdown == CompanySearchViewModel.Selection.State) {
				viewModel.States = bbosDataManager.GetAllItems<State> ().ToList ();
				listViewOptions.ItemsSource = viewModel.States;
			}else if (viewModel.SelectedDropdown == CompanySearchViewModel.Selection.TerminalMarket) {
				var tmList = bbosDataManager.GetAllItems<TerminalMarket> ().ToList ();

				if (CompanySearch.ViewModel.SelectedState != null && CompanySearch.ViewModel.SelectedState.StateId > 0) {
					viewModel.TerminalMarkets = tmList.Where (m => m.StateId == CompanySearch.ViewModel.SelectedState.StateId).ToList ();
				}
				else{
					viewModel.TerminalMarkets = tmList;
				}
				listViewOptions.ItemsSource = viewModel.TerminalMarkets;


			} else if (viewModel.SelectedDropdown == CompanySearchViewModel.Selection.CreditWorthyRating) {
				var list = GetList<BBOSMobile.ServiceModels.Common.Enumerations.CreditWorthRating>();
				if (viewModel.IsLumber) {
					//replace MIL with K
					foreach (var rating in list) {
						rating.Definition = Regex.Replace (rating.Definition, "M ", "K ");
					}
				} 
				listViewOptions.ItemsSource = list;
					
			}
			else if (viewModel.SelectedDropdown == CompanySearchViewModel.Selection.BBScore) 
			{
				listViewOptions.ItemsSource = GetList<BBOSMobile.ServiceModels.Common.Enumerations.BBScore>();
			}else if (viewModel.SelectedDropdown == CompanySearchViewModel.Selection.SearchType) {
				listViewOptions.ItemsSource = GetList<BBOSMobile.ServiceModels.Common.Enumerations.SearchType>();
			}else if (viewModel.SelectedDropdown == CompanySearchViewModel.Selection.Industry) {
				var list = GetList<BBOSMobile.ServiceModels.Common.Enumerations.IndustryType>();
				//removing lumber because of produce user
				list.Remove(list[3]);
				listViewOptions.ItemsSource = list;
			}else if (viewModel.SelectedDropdown == CompanySearchViewModel.Selection.Radius) {
				listViewOptions.ItemsSource = GetList<BBOSMobile.ServiceModels.Common.Enumerations.Radius>();
			}else if (viewModel.SelectedDropdown == CompanySearchViewModel.Selection.Integrity) {
				listViewOptions.ItemsSource = GetList<BBOSMobile.ServiceModels.Common.Enumerations.IntegrityRating>();
			}else if (viewModel.SelectedDropdown == CompanySearchViewModel.Selection.Pay) {
				listViewOptions.ItemsSource = GetList<BBOSMobile.ServiceModels.Common.Enumerations.PayDescription>();
			}else if (viewModel.SelectedDropdown == CompanySearchViewModel.Selection.CurrentPayReport) {
				listViewOptions.ItemsSource = GetList<BBOSMobile.ServiceModels.Common.Enumerations.CurrentPayReport>();
			}else if (viewModel.SelectedDropdown == CompanySearchViewModel.Selection.PayIndicator) {
				listViewOptions.ItemsSource = GetList<BBOSMobile.ServiceModels.Common.Enumerations.PayIndicator>();
			}
		}

		void listViewOptions_ItemSelected (object sender, SelectedItemChangedEventArgs e)
		{
			//Based on the dropdown, choose the appropriate type to cast the item to
			if (viewModel.SelectedDropdown == CompanySearchViewModel.Selection.Commodity) 
			{
				CompanySearch.ViewModel.SelectedCommodity = e.SelectedItem as Commodity;
				//viewModel.SelectedCommodity = e.SelectedItem as Commodity;
			} 
			else if (viewModel.SelectedDropdown == CompanySearchViewModel.Selection.Classification) 
			{
				CompanySearch.ViewModel.SelectedClassification = e.SelectedItem as Classification;
				//viewModel.SelectedClassification = e.SelectedItem as Classification;
			} 
			else if (viewModel.SelectedDropdown == CompanySearchViewModel.Selection.CreditWorthyRating) 
			{
				CompanySearch.ViewModel.SelectedCreditWorthyRating = e.SelectedItem as EnumPlaceholder;
				//viewModel.SelectedCreditWorthyRating = e.SelectedItem as EnumPlaceholder;
			} 
			else if (viewModel.SelectedDropdown == CompanySearchViewModel.Selection.BBScore) 
			{
				CompanySearch.ViewModel.SelectedBBScore = e.SelectedItem as EnumPlaceholder;
				//viewModel.SelectedBBScore = e.SelectedItem as EnumPlaceholder;
			} 
			else if (viewModel.SelectedDropdown == CompanySearchViewModel.Selection.SearchType) 
			{
				CompanySearch.ViewModel.SelectedSearchType = e.SelectedItem as EnumPlaceholder;
				//viewModel.SelectedSearchType = e.SelectedItem as EnumPlaceholder;
			} 
			else if (viewModel.SelectedDropdown == CompanySearchViewModel.Selection.Industry) 
			{
				CompanySearch.ViewModel.SelectedIndustry = e.SelectedItem as EnumPlaceholder;
				//viewModel.SelectedIndustry = e.SelectedItem as EnumPlaceholder;

            if(CompanySearch.ViewModel.SelectedIndustry.Definition == "Supply")
                {

                    CompanySearch.ViewModel.SelectedBBScore = new EnumPlaceholder() { Id = -1, Definition = "BB Score Range" };
                    CompanySearch.ViewModel.SelectedIntegrity = new EnumPlaceholder() { Id = -1, Definition = "Trade Practices Rating" };
                    CompanySearch.ViewModel.SelectedPay = new EnumPlaceholder() { Id = -1, Definition = "Pay Description" };
                    CompanySearch.ViewModel.SelectedCreditWorthyRating = new EnumPlaceholder() { Id = -1, Definition = "Credit Worth Rating" };
                }


			} 
			else if (viewModel.SelectedDropdown == CompanySearchViewModel.Selection.Radius) 
			{
				CompanySearch.ViewModel.SelectedRadius = e.SelectedItem as EnumPlaceholder;
				//viewModel.SelectedRadius = e.SelectedItem as EnumPlaceholder;
			} 
			else if (viewModel.SelectedDropdown == CompanySearchViewModel.Selection.Integrity) 
			{
				CompanySearch.ViewModel.SelectedIntegrity = e.SelectedItem as EnumPlaceholder;
				//viewModel.SelectedIntegrity = e.SelectedItem as EnumPlaceholder;
			} 
			else if (viewModel.SelectedDropdown == CompanySearchViewModel.Selection.Pay) 
			{
				CompanySearch.ViewModel.SelectedPay = e.SelectedItem as EnumPlaceholder;
				//viewModel.SelectedPay = e.SelectedItem as EnumPlaceholder;
			} 
			else if (viewModel.SelectedDropdown == CompanySearchViewModel.Selection.PayIndicator) 
			{
				CompanySearch.ViewModel.SelectedPayIndicator = e.SelectedItem as EnumPlaceholder;
				//viewModel.SelectedPay = e.SelectedItem as EnumPlaceholder;
			} 
			else if (viewModel.SelectedDropdown == CompanySearchViewModel.Selection.Specie) 
			{
				CompanySearch.ViewModel.SelectedSpecie =  e.SelectedItem as Specie;
				//viewModel.SelectedSpecie = e.SelectedItem as Specie;
			} 
			else if (viewModel.SelectedDropdown == CompanySearchViewModel.Selection.Product) 
			{
				CompanySearch.ViewModel.SelectedProduct = e.SelectedItem as Product;
				//viewModel.SelectedProduct = e.SelectedItem as Product;
			} 
			else if (viewModel.SelectedDropdown == CompanySearchViewModel.Selection.Services) 
			{
				CompanySearch.ViewModel.SelectedService = e.SelectedItem as Service;
				//viewModel.SelectedService = e.SelectedItem as Service;
			} 
			else if (viewModel.SelectedDropdown == CompanySearchViewModel.Selection.State) 
			{
				CompanySearch.ViewModel.SelectedState = e.SelectedItem as State;
				//viewModel.SelectedState = e.SelectedItem as State;
			} 
			else if (viewModel.SelectedDropdown == CompanySearchViewModel.Selection.TerminalMarket) 
			{
				CompanySearch.ViewModel.SelectedTerminalMarket = e.SelectedItem as TerminalMarket;
				//viewModel.SelectedTerminaMarket = e.SelectedItem as TerminalMarket;
			} 
			else if (viewModel.SelectedDropdown == CompanySearchViewModel.Selection.CurrentPayReport) 
			{
				CompanySearch.ViewModel.SelectedPayReport = e.SelectedItem as EnumPlaceholder;
				//viewModel.SelectedPayReport = e.SelectedItem as EnumPlaceholder;
			}

			//Now go back to the previous page, with our new info
			Navigation.PopAsync ();
		}


		//Convert an enum list to a list of my enum placeholder class
		public static List<EnumPlaceholder> GetList<T>() where T : struct
		{
			List<EnumPlaceholder> epl = new List<EnumPlaceholder> ();
			foreach (int e in Enum.GetValues(typeof(T)))
			{
				EnumPlaceholder item = new EnumPlaceholder();
				item.Id = e;
				item.Definition = CamelCaseToSpaces(Enum.GetName(typeof(T), e));
				epl.Add (item);
			}
			return epl;

		}

		public static string ReplaceLeadingUnderScore(string value){
			return Regex.Replace (value, "_", "");
		}
		public static string ReplaceDoubleUnderScoreSpace(string value){
			return Regex.Replace (value, "__", " ");
		}
		public static string ReplacePlusWordWithSign(string value){
			return Regex.Replace (value, "plussign", "+");
		}
		public static string ReplaceMilWithM(string value){
			return Regex.Replace (value, "mil", "M ");
		}

		//Convert camel cased enum to strings with spaces
		public static string CamelCaseToSpaces(string value)
		{
			value = ReplaceDoubleUnderScoreSpace (value);
			value = ReplaceLeadingUnderScore (value);
			value = ReplacePlusWordWithSign (value);
			value = Regex.Replace(value, "(?!^)([A-Z])", " $1");
			value = ReplaceMilWithM (value);
			return value;
		}




	}




}

