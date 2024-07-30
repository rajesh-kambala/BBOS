using System;
using System.Collections.Generic;

using Xamarin.Forms;
using BBOSMobile.Forms.ViewModels;
using BBOSMobile.Core;
using BBOSMobile.ServiceModels.Requests;
using System.Collections.ObjectModel;
using BBOSMobile.Forms.Custom;
using BBOSMobile.Forms.Pages;
using BBOSMobile.Core.Interfaces;
using System.Diagnostics;

namespace BBOSMobile.Forms
{
	public partial class CompanySearchResults : BaseContentPage
	{
		//CompanySearchViewModel companySearchViewModel;
		CompanyListViewModel companyListViewModel;
		CompanyListContentView companyListContentView;
		CompanySearchRequest request;
		public static bool ShouldKeepContent;


        

        public CompanySearchResults ()
		{
			InitializeComponent ();
			//companySearchViewModel = vm;	
			Title = "Results";
            //NavigationPage.SetBackButtonTitle(this, "Comp Search");

			//ITrackerService service = App.TrackerService;
			//service.TrackScreen ("Company Search Results");
		}

		protected async override void OnAppearing ()
		{
			CompanySearchResults.ShouldKeepContent = false;
			base.OnAppearing ();
			GetCompanies ();
            //mainLayout.ForceLayout();
            
		}

		protected override void OnDisappearing ()
		{
			if (ShouldClearContent(CompanySearchResults.ShouldKeepContent)) 
			{
				//companySearchViewModel = null;
				//companyListViewModel = null;
				//companyListContentView = null;
				//request = null;
			} 
		}

		private void PrepareRequest(){
			if (request == null) {
				request = new CompanySearchRequest ();
				request.PageIndex = 0;
				request.PageSize = 20;
			}

			var companySearchViewModel = CompanySearch.ViewModel;

			//Add our string filters from the viewmodel
			if (!string.IsNullOrEmpty (companySearchViewModel.BBNumber)) {
				request.BBID = companySearchViewModel.BBNumber;
			}
			//TODO:  Need to parse this string into city/state/zip for webservices
			if (!string.IsNullOrEmpty (companySearchViewModel.City)) {
				request.City = companySearchViewModel.City;
			}
			if (!string.IsNullOrEmpty (companySearchViewModel.Zip)) {
				request.PostalCode = companySearchViewModel.Zip;
			}

			if (!string.IsNullOrEmpty (companySearchViewModel.CompanyName)) {
				request.CompanyName = companySearchViewModel.CompanyName;
			}

			//And add all the dropdown/enum filters to the reuqest

			if (companySearchViewModel.SelectedState != null) {
				if (companySearchViewModel.SelectedState.StateId != -1) {
					request.State = companySearchViewModel.SelectedState.StateId.ToString ();
				}
			}

			if (companySearchViewModel.SelectedTerminalMarket != null) {
				if (companySearchViewModel.SelectedTerminalMarket.TerminalMarketId != -1) {
					request.TerminalMarket = companySearchViewModel.SelectedTerminalMarket.TerminalMarketId.ToString ();
				}
			}

			if (companySearchViewModel.SelectedBBScore != null) {
				if (companySearchViewModel.SelectedBBScore.Id != -1) {
					request.BBScore = (BBOSMobile.ServiceModels.Common.Enumerations.BBScore)companySearchViewModel.SelectedBBScore.Id;
				}
			}
			if (companySearchViewModel.SelectedClassification != null) {
				if (companySearchViewModel.SelectedClassification.ClassificationId != -1) {
					request.ClassificationId = companySearchViewModel.SelectedClassification.ClassificationId;
				}
			}

			if (companySearchViewModel.SelectedCommodity != null) {
				if (companySearchViewModel.SelectedCommodity.CommodityID != -1) {
					request.CommodityId = companySearchViewModel.SelectedCommodity.CommodityID;
				}
			}

			if (companySearchViewModel.SelectedCreditWorthyRating != null) {
				if (companySearchViewModel.SelectedCreditWorthyRating.Id != -1) {
					request.CreditWorthRating = (BBOSMobile.ServiceModels.Common.Enumerations.CreditWorthRating)companySearchViewModel.SelectedCreditWorthyRating.Id;
				}
			}

			if (companySearchViewModel.SelectedIndustry != null) {
				if (companySearchViewModel.SelectedIndustry.Id != -1) {
					request.IndustryType = (BBOSMobile.ServiceModels.Common.Enumerations.IndustryType)companySearchViewModel.SelectedIndustry.Id;
				}
			}

			if (companySearchViewModel.SelectedIntegrity != null) {
				if (companySearchViewModel.SelectedIntegrity.Id != -1) {
					request.IntegrityRating = (BBOSMobile.ServiceModels.Common.Enumerations.IntegrityRating)companySearchViewModel.SelectedIntegrity.Id;
				}
			}

			if (companySearchViewModel.SelectedPay != null) {
				if (companySearchViewModel.SelectedPay.Id != -1) {
						request.PayDescription = (BBOSMobile.ServiceModels.Common.Enumerations.PayDescription)companySearchViewModel.SelectedPay.Id;
				}
			}
			if (companySearchViewModel.SelectedPayIndicator != null) {
				if (companySearchViewModel.SelectedPayIndicator.Id != -1) {
					request.PayIndicator = (BBOSMobile.ServiceModels.Common.Enumerations.PayIndicator)companySearchViewModel.SelectedPayIndicator.Id;
				}
			}

			if (companySearchViewModel.SelectedRadius != null) {
				//if (companySearchViewModel.SelectedRadius.Id != -1) {
					request.Radius = (BBOSMobile.ServiceModels.Common.Enumerations.Radius)companySearchViewModel.SelectedRadius.Id;
				//}
			}

			if (companySearchViewModel.SelectedSearchType != null) {
				if (companySearchViewModel.SelectedSearchType.Id != -1) {
					request.SearchType = (BBOSMobile.ServiceModels.Common.Enumerations.SearchType)companySearchViewModel.SelectedSearchType.Id;
				}
			}

			if (companySearchViewModel.SelectedSpecie != null) {
				if (companySearchViewModel.SelectedSpecie.SpecieId != -1) {
					request.SpecieId = companySearchViewModel.SelectedSpecie.SpecieId;
				}
			}

			if (companySearchViewModel.SelectedPayReport != null) {
				if (companySearchViewModel.SelectedPayReport.Id != -1) {
					request.CurrentPayReport = (BBOSMobile.ServiceModels.Common.Enumerations.CurrentPayReport)companySearchViewModel.SelectedPayReport.Id;
				}
			}

			if (companySearchViewModel.SelectedService != null) {
				if (companySearchViewModel.SelectedService.ServiceId != -1) {
					request.ServiceId = companySearchViewModel.SelectedService.ServiceId;
				}
			}

			if (companySearchViewModel.SelectedProduct != null) {
				if (companySearchViewModel.SelectedProduct.ProductId != -1) {
					request.ProductId = companySearchViewModel.SelectedProduct.ProductId;
				}
			}
		}

		private async void GetCompanies()
		{
			try {
				activityLayout.IsVisible = true;
				activityIndicator.IsVisible = true;
				activityIndicator.IsRunning = true;

				var serviceClient = new CompanyWebserviceClient ();

				PrepareRequest ();

				//Get our search response back
				var response = await serviceClient.GetCompanies (request);
				if (response != null) {
					if (response.ResponseStatus == BBOSMobile.ServiceModels.Common.Enumerations.ResponseStatus.InvalidUserId) 
					{
						Navigation.PushAsync(new LoginPage ());
					}
				}


				//Make sure we have results
				if (response == null) 
				{
					activityIndicator.IsVisible = false;
					activityIndicator.IsRunning = false;
					return;
				}
                
				if (response.Companies == null || response.ResultCount == 0)  
				{

                    activityIndicator.IsVisible = false;
                    activityIndicator.IsRunning = false;
                    noRecordsFound.IsVisible = true;


                    return;
				}
                
                if (companyListViewModel == null) 
				{
					companyListViewModel = new CompanyListViewModel ();
					companyListViewModel.Companies= new ObservableCollection<CompanyListItemViewModel> ();
				}
				if (request == null) {
					request = new CompanySearchRequest ();
					request.PageIndex = 0;
					request.PageSize = 20;
				}
				bool companyReturned = false;
                result_count_label.Text = response.ResultCount.ToString();
				foreach (var company in response.Companies) {
					var companyListItem = new CompanyListItemViewModel ();
					companyListItem.BBID = company.BBID;
					companyListItem.Name = company.Name;
					companyListItem.Location = company.Location;
					companyListItem.Rating = company.Rating;
					companyListItem.IndustryAndType = string.Format ("{0} {1}", company.Industry, company.Type);
					companyListItem.HasNotes = company.HasNotes;
					companyListItem.Phone = company.Phone;
					companyListItem.Index = company.Index + (request.PageSize * (request.PageIndex));

					companyListViewModel.Companies.Add (companyListItem);
					companyReturned = true;
				}
				if (response.ResultCount > 0) {

                    Debug.WriteLine("ResultCount > 0");

                    noRecordsFound.IsVisible = false;
					request.PageIndex += 1;
					if (companyListContentView == null) {
						companyListContentView = new CompanyListContentView (companyListViewModel,true);

						companyListContentView.ListViewCompany.ItemAppearing += (Object listView, ItemVisibilityEventArgs e) => {
							OnItemAppearing ((ListView)listView, e);
						};

						//Add the companies to our layout
						mainLayout.Children.Clear();

                        if(Device.OS == TargetPlatform.Android) mainLayout.Children.Add(new Label { Text = "Results: " + response.ResultCount });
                        
						mainLayout.Children.Add(companyListContentView);
					}
				}
				else{
					if (companyListContentView == null )
                        Debug.WriteLine("no results");
                    noRecordsFound.IsVisible = true;
				}
					
				activityLayout.IsVisible = false;
				activityIndicator.IsVisible = false;
				activityIndicator.IsRunning = false;

			}  catch(Exception ex) {
				DisplayErrorLoadingAlert ();
			}
		}

		private void OnItemAppearing(ListView listView, ItemVisibilityEventArgs e)
		{
			if (companyListViewModel.Companies.Count == 0) {
				activityIndicator.IsVisible = false;
				activityIndicator.IsRunning = false;
				return;
			}	

			//hit bottom!
			if (companyListViewModel.Companies.Count > 10) {
				if(((CompanyListItemViewModel)e.Item).Index == companyListViewModel.Companies.Count - 1)
				{
					GetCompanies();
				}
			}
		}
	}
}

