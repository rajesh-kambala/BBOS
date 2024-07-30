using System;
using System.Collections.Generic;

using Xamarin.Forms;
using BBOSMobile.Core;
using BBOSMobile.Forms.ViewModels;
using System.Linq;
using BBOSMobile.ServiceModels.Requests;
using BBOSMobile.Core.Interfaces;
using BBOSMobile.Core.Models;
using System.Diagnostics;

namespace BBOSMobile.Forms.Pages
{
	public partial class CompanySearch : BaseContentPage
	{
		public static CompanySearchViewModel ViewModel;
		public static bool ShouldKeepContent;
		public UserCredentials userCredentials = DependencyService.Get<IUserCredentialsService> ().GetUserCredentials();
		public CompanySearch()
		{
			IsBusy = true;
			InitializeComponent ();
			CompanySearch.ViewModel = new CompanySearchViewModel ();
			CompanySearch.ViewModel.SecurityPrivileges = userCredentials.SecurityPrivileges;

			if (userCredentials.UserType == BBOSMobile.ServiceModels.Common.Enumerations.UserType.Lumber)
				ViewModel.IsLumber = true;
			else
				ViewModel.IsLumber = false;
			BindingContext = CompanySearch.ViewModel;
			SetPageView ();

			Title = "Company Search";
			if (!App.RecentViewsSecurity.HasPrivilege && !App.RecentViewsSecurity.Enabled) {
				RVSL.Opacity = .5;
			}
			if (!App.WatchdogListsPage.HasPrivilege && !App.WatchdogListsPage.Enabled) {
				WDSL.Opacity = .5;
			}
			var tapGestureRecognizerRV = new TapGestureRecognizer();
			tapGestureRecognizerRV.Tapped += (s, e) => {
				// handle the tap
				if ((App.RecentViewsSecurity.HasPrivilege) || (App.RecentViewsSecurity.Enabled)) {
					var page = new RecentViews ();
					App.RootPage.NavigateToPage (page);
				}
				else{
					DisplayAlert (Common.Constants.AlertTitle, Common.Constants.InvalidPermissionAlertMessage, Common.Constants.AlertOk);
				}

			};
			RVSL.GestureRecognizers.Add(tapGestureRecognizerRV);

			var tapGestureRecognizerWD = new TapGestureRecognizer();
			tapGestureRecognizerWD.Tapped += (s, e) => {
				// handle the tap
				if ((App.WatchdogListsPage.HasPrivilege) || (App.WatchdogListsPage.Enabled)) {
					var page = new WatchDogGroupsPage ();
					App.RootPage.NavigateToPage (page);
				}
				else{
					DisplayAlert (Common.Constants.AlertTitle, Common.Constants.InvalidPermissionAlertMessage, Common.Constants.AlertOk);
				}
			};
			WDSL.GestureRecognizers.Add(tapGestureRecognizerWD);


            var tapGestureRecognizerQF = new TapGestureRecognizer();
            tapGestureRecognizerQF.Tapped += (s, e) => {
                // handle the tap
                var page = new QuickFind();
                App.RootPage.NavigateToPage(page);
            };
            QFSL.GestureRecognizers.Add(tapGestureRecognizerQF);

            var tapGestureRecognizerPS = new TapGestureRecognizer();
            tapGestureRecognizerPS.Tapped += (s, e) => {
                // handle the tap
                var page = new ContactSearch();
                App.RootPage.NavigateToPage(page);
            };
            PSSL.GestureRecognizers.Add(tapGestureRecognizerPS);



			//Make the current location stack layout clickable
			var tgr = new TapGestureRecognizer ();
			tgr.Tapped +=(s,e)=>OnBtnCurrentLocationClicked(s,e);
			slCurrentLocation.GestureRecognizers.Add(tgr);

			//ITrackerService service = App.TrackerService;
			//service.TrackScreen ("Company Search");
			IsBusy = false;
		}



        public void SetPageView(){
			//Check to see if this is a lumber user.  Otherwise, assume produce

			btnCurrentPayReport.IsVisible = true;
			btnIntegrity.IsVisible = true;
			btnBBScore.IsVisible = true;
			btnIndustry.IsVisible = true;
			slCommodity.IsVisible = true;
			btnPay.IsVisible = true;
			btnPayIndicator.IsVisible = true;
			slSpecie.IsVisible = true;
			slProduct.IsVisible = true;
			slService.IsVisible = true;
			if (userCredentials.UserType == BBOSMobile.ServiceModels.Common.Enumerations.UserType.Lumber) {
				slCommodity.IsVisible = false;

                //btnBBScore.IsVisible = false;  //they want this allowed for Lumber now // 9/19/2016
                
                btnBBScore.IsVisible = CompanySearch.ViewModel.CompanySearchBBScore.Visible;
                btnBBScore.IsEnabled = true; // CompanySearch.ViewModel.CompanySearchBBScore.Enabled;
                if (!CompanySearch.ViewModel.CompanySearchBBScore.Enabled)
                {
                    btnBBScore.Opacity = .5;
                }
                
                btnIntegrity.IsVisible = false;
				btnIndustry.IsVisible = false;
				btnTerminalMarket.IsVisible = false;
				btnCreditWorthy.IsVisible = false;
				btnPay.IsVisible = false;

				//lumber security
				btnPayIndicator.IsVisible = CompanySearch.ViewModel.CompanySearchPayIndicator.Visible;
				btnPayIndicator.IsEnabled = true; //CompanySearch.ViewModel.CompanySearchPayIndicator.Enabled;
				if (!CompanySearch.ViewModel.CompanySearchPayIndicator.Enabled) {
					btnPayIndicator.Opacity = .5;
				}

				btnProduct.IsVisible = CompanySearch.ViewModel.CompanySearchProducts.Visible;
				btnProduct.IsEnabled = true; // CompanySearch.ViewModel.CompanySearchProducts.Enabled;
				if (!CompanySearch.ViewModel.CompanySearchProducts.Enabled) {
					btnProduct.Opacity = .5;
				}
				lblProduct.IsVisible = CompanySearch.ViewModel.CompanySearchProducts.Visible;

				btnService.IsVisible = CompanySearch.ViewModel.CompanySearchServices.Visible;
				btnService.IsEnabled = true;  //CompanySearch.ViewModel.CompanySearchServices.Enabled;
				if (!CompanySearch.ViewModel.CompanySearchServices.Enabled) {
					btnService.Opacity = .5;
				}

				btnSpecie.IsVisible = CompanySearch.ViewModel.CompanySearchSpecie.Visible;
				btnSpecie.IsEnabled = true; //CompanySearch.ViewModel.CompanySearchSpecie.Enabled;
				if (!CompanySearch.ViewModel.CompanySearchSpecie.Enabled) {
					btnSpecie.Opacity = .5;
				}
				lblSpecie.IsVisible = CompanySearch.ViewModel.CompanySearchSpecie.Visible;



			} 
			else {
				slSpecie.IsVisible = false;
				slProduct.IsVisible = false;
				slService.IsVisible = false;
				btnCurrentPayReport.IsVisible = false;
				btnCreditWorthyLumber.IsVisible = false;
				btnPayIndicator.IsVisible = false;

				//produce security
				btnBBScore.IsVisible = CompanySearch.ViewModel.CompanySearchBBScore.Visible;
				btnBBScore.IsEnabled = true; // CompanySearch.ViewModel.CompanySearchBBScore.Enabled;
				if (!CompanySearch.ViewModel.CompanySearchBBScore.Enabled) {
					btnBBScore.Opacity = .5;
				}

				btnCommodity.IsVisible = CompanySearch.ViewModel.CompanySearchCommodities.Visible;
				//btnCommodity.IsEnabled = true; // CompanySearch.ViewModel.CompanySearchCommodities.Enabled;
				if (!CompanySearch.ViewModel.CompanySearchCommodities.Enabled) {
					btnCommodity.Opacity = .5;
				}
				lblCommodity.IsVisible = CompanySearch.ViewModel.CompanySearchCommodities.Visible;

				btnCreditWorthy.IsVisible = CompanySearch.ViewModel.CompanySearchCreditWorthRating.Visible;
				btnCreditWorthy.IsEnabled = true; // CompanySearch.ViewModel.CompanySearchCreditWorthRating.Enabled;
				if (!CompanySearch.ViewModel.CompanySearchCreditWorthRating.Enabled){
					btnCreditWorthy.Opacity = .5;
				}

				btnIntegrity.IsVisible = CompanySearch.ViewModel.CompanySearchIntegrityRating.Visible;
				btnIntegrity.IsEnabled = true; //CompanySearch.ViewModel.CompanySearchIntegrityRating.Enabled;
				if (!CompanySearch.ViewModel.CompanySearchIntegrityRating.Enabled) {
					btnIntegrity.Opacity = .5;
				}

				btnPay.IsVisible = CompanySearch.ViewModel.CompanySearchByPayRating.Visible;
				btnPay.IsEnabled = true; //CompanySearch.ViewModel.CompanySearchByPayRating.Enabled;
				if (!CompanySearch.ViewModel.CompanySearchByPayRating.Enabled) {
					btnPay.Opacity = .5;
				}

				btnTerminalMarket.IsVisible = CompanySearch.ViewModel.CompanySearchTerminalMarket.Visible;
				btnTerminalMarket.IsEnabled = true; //CompanySearch.ViewModel.CompanySearchTerminalMarket.Enabled;
				if (!CompanySearch.ViewModel.CompanySearchTerminalMarket.Enabled) {
					btnTerminalMarket.Opacity = .5;
				}

			}

			//general security
			btnClassification.IsVisible = CompanySearch.ViewModel.CompanySearchClassifications.Visible;
			btnClassification.IsEnabled = true; //CompanySearch.ViewModel.CompanySearchClassifications.Enabled;
			if (!CompanySearch.ViewModel.CompanySearchClassifications.Enabled) {
				btnClassification.Opacity = .5;
			}
			lblClassification.IsVisible = CompanySearch.ViewModel.CompanySearchClassifications.Visible;

			btnRadius.IsVisible = CompanySearch.ViewModel.CompanySearchRadius.Visible;
			btnRadius.IsEnabled = true; //CompanySearch.ViewModel.CompanySearchRadius.Enabled;
			if (!CompanySearch.ViewModel.CompanySearchRadius.Enabled) {
				btnRadius.Opacity = .5;
			}

		
		}

//		public CompanySearch (CompanySearchViewModel vm)
//		{
//			InitializeComponent ();
//			if (vm == null) {
//				viewModel = new CompanySearchViewModel ();
//			} else {
//				//If we came back to this page from the detail page, populate it with those selections
//				viewModel = vm;
//				LoadViewModel ();
//			}
//
//			//Produce or lumber
//			SetPageView ();
//
//			//Hide this since I can't figure out how to clear the navigation back stack
//			NavigationPage.SetHasBackButton (this, false);
//
//		}
		protected override bool OnBackButtonPressed()
		{
			if (!IsBusy) {
				var page = new Dashboard ();
				App.RootPage.NavigateToPage (page);
				return true;
			}
			return false;

		}
		protected override void OnAppearing ()
		{
			IsBusy = true;
			if (ViewModel != null && !ViewModel.IsLumber) {
				if (btnIndustry.Text != "Produce" && btnIndustry.Text != "Industry") {
					btnCommodity.IsEnabled = false;
					//CompanySearch.ViewModel.Commodities 
				} else {
					if (CompanySearch.ViewModel.CompanySearchCommodities.Enabled) {
						btnCommodity.IsEnabled = true;
					}

				}
			}
            if (ViewModel != null)
            {
                if (ViewModel.SelectedIndustry.Definition == "Supply")
                {

                    btnBBScore.IsEnabled = false;
                    btnIntegrity.IsEnabled = false;
                    btnPay.IsEnabled = false;
                    btnCreditWorthy.IsEnabled = false;


                }
                else
                {
                    btnBBScore.IsEnabled = true;
                    btnIntegrity.IsEnabled = true;
                    btnPay.IsEnabled = true;
                    btnCreditWorthy.IsEnabled = true;
                }
            }

            CompanySearch.ShouldKeepContent = false;
			base.OnAppearing ();


			IsBusy = false;
		}

		protected override void OnDisappearing ()
		{
			if (ShouldClearContent(CompanySearch.ShouldKeepContent)) 
			{
				//CompanySearch.ViewModel = null;
			} 
		}

		private async void OnBtnCurrentLocationClicked(object sender, EventArgs args){
			if (!IsBusy) {
				IsBusy = true;
				var postalCode = await DependencyService.Get<ILocationService> ().GetCurrentPostalCode ();
				if (postalCode == "LOCATIONDISABLED") {
					await DisplayAlert ("Location services disabled", "Please turn on location services.", "Cancel");
				} else {
					this.zip.Text = postalCode;
				}
				IsBusy = false;
			}
		}

		private void OnBtnClassificationClicked(object sender, EventArgs args) {
			if (CompanySearch.ViewModel.CompanySearchClassifications.Enabled) {
				if (!IsBusy) {
					IsBusy = true;
					SaveViewModel ();
					CompanySearch.ViewModel.SelectedDropdown = CompanySearchViewModel.Selection.Classification;
					CompanySearch.ShouldKeepContent = true;
					Navigation.PushAsync (new CompanySearchList(ViewModel));
					IsBusy = false;
				} 
			} else {
				DisplayAlert (Common.Constants.AlertTitle, Common.Constants.InvalidPermissionAlertMessage, Common.Constants.AlertOk);
			}
		}

		private void OnBtnCommodityClicked(object sender, EventArgs args){
			if (CompanySearch.ViewModel.CompanySearchCommodities.Enabled) {
				if (!IsBusy) {
					IsBusy = true;
					SaveViewModel ();
					CompanySearch.ViewModel.SelectedDropdown = CompanySearchViewModel.Selection.Commodity;
					CompanySearch.ShouldKeepContent = true;
					Navigation.PushAsync (new CompanySearchList (ViewModel));
					IsBusy = false;
				}
			}	else {
					DisplayAlert (Common.Constants.AlertTitle, Common.Constants.InvalidPermissionAlertMessage, Common.Constants.AlertOk);
			}
		}

		private void OnBtnCreditWorthyClicked(object sender, EventArgs args) {
			if (CompanySearch.ViewModel.CompanySearchCreditWorthRating.Enabled) {
				if (!IsBusy) {
					IsBusy = true;
					SaveViewModel ();
					CompanySearch.ViewModel.SelectedDropdown = CompanySearchViewModel.Selection.CreditWorthyRating;
					CompanySearch.ShouldKeepContent = true;
					Navigation.PushAsync (new CompanySearchList(ViewModel));
					IsBusy = false;
				} 
			} else {
				DisplayAlert (Common.Constants.AlertTitle, Common.Constants.InvalidPermissionAlertMessage, Common.Constants.AlertOk);
			} 
		}

		private void OnBtnBBScoreClicked(object sender, EventArgs args){
			if (CompanySearch.ViewModel.CompanySearchBBScore.Enabled) {
				if (!IsBusy) {
					IsBusy = true;
					SaveViewModel ();
					CompanySearch.ViewModel.SelectedDropdown = CompanySearchViewModel.Selection.BBScore;
					CompanySearch.ShouldKeepContent = true;
					Navigation.PushAsync (new CompanySearchList(ViewModel));
					IsBusy = false;
				} 
			} else {
				DisplayAlert (Common.Constants.AlertTitle, Common.Constants.InvalidPermissionAlertMessage, Common.Constants.AlertOk);
			}
		}

		private void OnBtnSearchTypeClicked(object sender, EventArgs args){
			if (!IsBusy) {
				IsBusy = true;
				SaveViewModel ();
				CompanySearch.ViewModel.SelectedDropdown = CompanySearchViewModel.Selection.SearchType;
				CompanySearch.ShouldKeepContent = true;
				Navigation.PushAsync (new CompanySearchList(ViewModel));
				IsBusy = false;
			}

		}

		private void OnBtnIndustryClicked(object sender, EventArgs args){
			if (!IsBusy) {
				IsBusy = true;
				SaveViewModel ();
				CompanySearch.ViewModel.SelectedDropdown = CompanySearchViewModel.Selection.Industry;
				CompanySearch.ShouldKeepContent = true;
				Navigation.PushAsync(new CompanySearchList(ViewModel));

                //Debug.WriteLine("CompanySearch.ViewModel.SelectedIndustry.Definition:" + CompanySearch.ViewModel.SelectedIndustry.Definition);

                IsBusy = false;
			}

		}

		private void OnBtnRadiusClicked(object sender, EventArgs args) {
			if (CompanySearch.ViewModel.CompanySearchRadius.Enabled) {
				if (!IsBusy) {
					IsBusy = true;
					SaveViewModel ();
					CompanySearch.ViewModel.SelectedDropdown = CompanySearchViewModel.Selection.Radius;
					CompanySearch.ShouldKeepContent = true;
					Navigation.PushAsync (new CompanySearchList(ViewModel));
					IsBusy = false;
				} 
			} else {
				DisplayAlert (Common.Constants.AlertTitle, Common.Constants.InvalidPermissionAlertMessage, Common.Constants.AlertOk);
			}
		}

		private void OnBtnIntegrityClicked(object sender, EventArgs args){
			if (CompanySearch.ViewModel.CompanySearchIntegrityRating.Enabled) {
				if (!IsBusy) {
					IsBusy = true;
					SaveViewModel ();
					CompanySearch.ViewModel.SelectedDropdown = CompanySearchViewModel.Selection.Integrity;
					CompanySearch.ShouldKeepContent = true;
					Navigation.PushAsync (new CompanySearchList(ViewModel));
					IsBusy = false;
				}
			}  else {
				DisplayAlert (Common.Constants.AlertTitle, Common.Constants.InvalidPermissionAlertMessage, Common.Constants.AlertOk);
			} 
		}

		private void OnBtnPayClicked(object sender, EventArgs args){
			if (CompanySearch.ViewModel.CompanySearchByPayRating.Enabled) {
				if (!IsBusy) {
					IsBusy = true;
					SaveViewModel ();
					CompanySearch.ViewModel.SelectedDropdown = CompanySearchViewModel.Selection.Pay;
					CompanySearch.ShouldKeepContent = true;
					Navigation.PushAsync (new CompanySearchList(ViewModel));
					IsBusy = false;
				} 
			}  else {
				DisplayAlert (Common.Constants.AlertTitle, Common.Constants.InvalidPermissionAlertMessage, Common.Constants.AlertOk);
			} 
		}

		private void OnBtnPayIndicatorClicked(object sender, EventArgs args){
			if (CompanySearch.ViewModel.CompanySearchPayIndicator.Enabled) {
				if (!IsBusy) {
					IsBusy = true;
					SaveViewModel ();
					CompanySearch.ViewModel.SelectedDropdown = CompanySearchViewModel.Selection.PayIndicator;
					CompanySearch.ShouldKeepContent = true;
					Navigation.PushAsync (new CompanySearchList (ViewModel));
					IsBusy = false;
				} 
			} else {
				DisplayAlert (Common.Constants.AlertTitle, Common.Constants.InvalidPermissionAlertMessage, Common.Constants.AlertOk);
			}
		}

		private void OnBtnCurrentPayReportClicked(object sender, EventArgs args){
			if (!IsBusy) {
				IsBusy = true;
				SaveViewModel ();
				CompanySearch.ViewModel.SelectedDropdown = CompanySearchViewModel.Selection.CurrentPayReport;
				CompanySearch.ShouldKeepContent = true;
				Navigation.PushAsync (new CompanySearchList(ViewModel));
				IsBusy = false;
			}
		}

		private void OnBtnSpecieClicked(object sender, EventArgs args) {
			if (CompanySearch.ViewModel.CompanySearchSpecie.Enabled) {
				if (!IsBusy) {
					IsBusy = true;
					SaveViewModel ();
					CompanySearch.ViewModel.SelectedDropdown = CompanySearchViewModel.Selection.Specie;
					CompanySearch.ShouldKeepContent = true;
					Navigation.PushAsync (new CompanySearchList (ViewModel));
					IsBusy = false;
				} 
			} else {
				DisplayAlert (Common.Constants.AlertTitle, Common.Constants.InvalidPermissionAlertMessage, Common.Constants.AlertOk);
			}
		}

		private void OnBtnProductClicked(object sender, EventArgs args) {
			if (CompanySearch.ViewModel.CompanySearchProducts.Enabled) {
				if (!IsBusy) {
					IsBusy = true;
					SaveViewModel ();
					CompanySearch.ViewModel.SelectedDropdown = CompanySearchViewModel.Selection.Product;
					CompanySearch.ShouldKeepContent = true;
					Navigation.PushAsync (new CompanySearchList (ViewModel));
					IsBusy = false;
				}
			} else {
				DisplayAlert (Common.Constants.AlertTitle, Common.Constants.InvalidPermissionAlertMessage, Common.Constants.AlertOk);
			}
		}

		private void OnBtnServiceClicked(object sender, EventArgs args) {
			if (CompanySearch.ViewModel.CompanySearchServices.Enabled) {
				if (!IsBusy) {
					IsBusy = true;
					SaveViewModel ();
					CompanySearch.ViewModel.SelectedDropdown = CompanySearchViewModel.Selection.Services;
					CompanySearch.ShouldKeepContent = true;
					Navigation.PushAsync (new CompanySearchList (ViewModel));
					IsBusy = false;
				} 
			} else {
				DisplayAlert (Common.Constants.AlertTitle, Common.Constants.InvalidPermissionAlertMessage, Common.Constants.AlertOk);
			}
		}

		private void OnBtnSearchClicked(object sender, EventArgs args){
			if (!IsBusy) {
				IsBusy = true;
				SaveViewModel ();		
				CompanySearch.ShouldKeepContent = true;
				Navigation.PushAsync (new CompanySearchResults());
				IsBusy = false;
			}

		}

		private void OnBtnResetClicked(object sender, EventArgs args){
			if (!IsBusy) {
				IsBusy = true;
				var model = CompanySearch.ViewModel;
				CompanySearch.ViewModel = new CompanySearchViewModel ();
				CompanySearch.ViewModel.SecurityPrivileges = model.SecurityPrivileges;
				if (userCredentials.UserType == BBOSMobile.ServiceModels.Common.Enumerations.UserType.Lumber)
					ViewModel.IsLumber = true;
				else
					ViewModel.IsLumber = false;
				BindingContext = CompanySearch.ViewModel;
				LoadViewModel ();
				btnCommodity.IsEnabled = true;
				IsBusy = false;
			}
		}

		private void OnBtnTerminalMarketClicked(object sender, EventArgs args) {
			if (CompanySearch.ViewModel.CompanySearchTerminalMarket.Enabled) {
				if (!IsBusy) {
					IsBusy = true;
					SaveViewModel ();
					CompanySearch.ViewModel.SelectedDropdown = CompanySearchViewModel.Selection.TerminalMarket;
					CompanySearch.ShouldKeepContent = true;
					Navigation.PushAsync (new CompanySearchList(ViewModel));
					IsBusy = false;
				}
			}  else {
				DisplayAlert (Common.Constants.AlertTitle, Common.Constants.InvalidPermissionAlertMessage, Common.Constants.AlertOk);
			} 
		}

		private void OnBtnStateClicked(object sender, EventArgs args){
			if (!IsBusy) {
				IsBusy = true;
				SaveViewModel ();
				CompanySearch.ViewModel.SelectedDropdown = CompanySearchViewModel.Selection.State;
				CompanySearch.ShouldKeepContent = true;
				Navigation.PushAsync (new CompanySearchList(ViewModel));
				IsBusy = false;
			}

		}

		private void SaveViewModel(){
			if (CompanySearch.ViewModel == null)
				CompanySearch.ViewModel = new CompanySearchViewModel ();
			CompanySearch.ViewModel.CompanyName = "";//companyName.Text;
			CompanySearch.ViewModel.BBNumber = "";//bbNumber.Text;
			CompanySearch.ViewModel.City = city.Text;
			CompanySearch.ViewModel.Zip = zip.Text;

		}

		void OnQuickFindButtonPressed(object sender, EventArgs args)
		{
			if (!IsBusy) {
				var page = new QuickFind ();
				App.RootPage.NavigateToPage (page);
			}

		}
		void OnRecentViewsButtonPressed(object sender, EventArgs args)
		{
			if (!IsBusy) {
				var page = new RecentViews ();
				App.RootPage.NavigateToPage (page);
			}

		}
		void OnWatchDogGroupsButtonPressed(object sender, EventArgs args)
		{
			if (!IsBusy) {
				var page = new WatchDogGroupsPage ();
				App.RootPage.NavigateToPage (page);
			}

		}

		private void LoadViewModel(){
			//companyName.Text = ViewModel.CompanyName;
			//bbNumber.Text = ViewModel.BBNumber;
			city.Text = ViewModel.City;
			zip.Text = ViewModel.Zip;



		}





	}
}

