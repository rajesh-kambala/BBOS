using System;
using System.Collections.Generic;

using Xamarin.Forms;
using BBOSMobile.Core;
using BBOSMobile.Forms.ViewModels;
using System.Linq;
using BBOSMobile.ServiceModels.Requests;
using BBOSMobile.Core.Interfaces;
using BBOSMobile.Core.Models;

namespace BBOSMobile.Forms.Pages
{
	public partial class ContactSearch : BaseContentPage
	{
		public static ContactSearchViewModel ViewModel;
		public static bool ShouldKeepContent;
		public UserCredentials userCredentials = DependencyService.Get<IUserCredentialsService> ().GetUserCredentials();
		public ContactSearch()
		{
			IsBusy = true;
			InitializeComponent ();
			ContactSearch.ViewModel = new ContactSearchViewModel ();
			ContactSearch.ViewModel.SecurityPrivileges = userCredentials.SecurityPrivileges;

			if (userCredentials.UserType == BBOSMobile.ServiceModels.Common.Enumerations.UserType.Lumber)
				ViewModel.IsLumber = true;
			else
				ViewModel.IsLumber = false;
			BindingContext = ContactSearch.ViewModel;
			SetPageView ();

			Title = "Person Search";
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

            //Make the current location stack layout clickable
            var tgr = new TapGestureRecognizer();
            tgr.Tapped += (s, e) => OnBtnCurrentLocationClicked(s, e);
            slCurrentLocation.GestureRecognizers.Add(tgr);



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


            var tapGestureRecognizerCS = new TapGestureRecognizer();
            tapGestureRecognizerCS.Tapped += (s, e) => {
                // handle the tap
                if (1==1)
                {
                    var page = new CompanySearch();
                    App.RootPage.NavigateToPage(page);
                }
            };
            CSSL.GestureRecognizers.Add(tapGestureRecognizerCS);

            var tapGestureRecognizerQF = new TapGestureRecognizer();
			tapGestureRecognizerQF.Tapped += (s, e) => {
				// handle the tap
				var page = new QuickFind ();
				App.RootPage.NavigateToPage (page);
			};
			QFSL.GestureRecognizers.Add(tapGestureRecognizerQF);



			//ITrackerService service = App.TrackerService;
			//service.TrackScreen ("Contact Search");
			IsBusy = false;
		}

		public void SetPageView(){
			//Check to see if this is a lumber user.  Otherwise, assume produce
			btnIndustry.IsVisible = true;
			if (userCredentials.UserType == BBOSMobile.ServiceModels.Common.Enumerations.UserType.Lumber) {

                /*
				slCommodity.IsVisible = false;
				btnBBScore.IsVisible = false;
				btnIntegrity.IsVisible = false;
                */
				btnIndustry.IsVisible = false;
                /*
				btnTerminalMarket.IsVisible = false;
				btnCreditWorthy.IsVisible = false;
				btnPay.IsVisible = false;
                */



			} 
			

		
		}

//		public ContactSearch (ContactSearchViewModel vm)
//		{
//			InitializeComponent ();
//			if (vm == null) {
//				viewModel = new ContactSearchViewModel ();
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
					//btnCommodity.IsEnabled = false;
					//ContactSearch.ViewModel.Commodities 
				} else {

				}
			}
			ContactSearch.ShouldKeepContent = false;
			base.OnAppearing ();


			IsBusy = false;
		}

		protected override void OnDisappearing ()
		{
			if (ShouldClearContent(ContactSearch.ShouldKeepContent)) 
			{
				//ContactSearch.ViewModel = null;
			} 
		}


		private void OnBtnIndustryClicked(object sender, EventArgs args){
			if (!IsBusy) {
				IsBusy = true;
				SaveViewModel ();
				ContactSearch.ViewModel.SelectedDropdown = ContactSearchViewModel.Selection.Industry;
				ContactSearch.ShouldKeepContent = true;
				Navigation.PushAsync (new ContactSearchList(ViewModel));
				IsBusy = false;
			}

		}

        private async void OnBtnCurrentLocationClicked(object sender, EventArgs args)
        {
            if (!IsBusy)
            {
                IsBusy = true;
                var postalCode = await DependencyService.Get<ILocationService>().GetCurrentPostalCode();
                if (postalCode == "LOCATIONDISABLED")
                {
                    await DisplayAlert("Location services disabled", "Please turn on location services.", "Cancel");
                }
                else
                {
                    this.zip.Text = postalCode;
                }
                IsBusy = false;
            }
        }


        private void OnBtnRadiusClicked(object sender, EventArgs args)
        {
            //if (CompanySearch.ViewModel.CompanySearchRadius.Enabled)
            //{
                if (!IsBusy)
                {
                    IsBusy = true;
                    SaveViewModel();
                    ContactSearch.ViewModel.SelectedDropdown = ContactSearchViewModel.Selection.Radius;
                    ContactSearch.ShouldKeepContent = true;
                    Navigation.PushAsync(new ContactSearchList(ViewModel));
                    IsBusy = false;
                }
/*
            }
            else
            {
                DisplayAlert(Common.Constants.AlertTitle, Common.Constants.InvalidPermissionAlertMessage, Common.Constants.AlertOk);
            } */

        }


        private void OnBtnStateClicked(object sender, EventArgs args)
        {
            if (!IsBusy)
            {
                IsBusy = true;
                SaveViewModel();
                ContactSearch.ViewModel.SelectedDropdown = ContactSearchViewModel.Selection.State;
                ContactSearch.ShouldKeepContent = true;
                Navigation.PushAsync(new ContactSearchList(ViewModel));
                IsBusy = false;
            }

        }


        private void OnBtnSearchClicked(object sender, EventArgs args){
			if (!IsBusy) {

                //DependencyService.Get<IContactsService>().CreateContact("junk");

                
				IsBusy = true;
				SaveViewModel ();		
				ContactSearch.ShouldKeepContent = true;
				Navigation.PushAsync (new ContactSearchResults());
				IsBusy = false;
                
                
			}

		}

		private void OnBtnResetClicked(object sender, EventArgs args){
			if (!IsBusy) {
				IsBusy = true;
				var model = ContactSearch.ViewModel;
				ContactSearch.ViewModel = new ContactSearchViewModel ();
				ContactSearch.ViewModel.SecurityPrivileges = model.SecurityPrivileges;
				if (userCredentials.UserType == BBOSMobile.ServiceModels.Common.Enumerations.UserType.Lumber)
					ViewModel.IsLumber = true;
				else
					ViewModel.IsLumber = false;
				BindingContext = ContactSearch.ViewModel;
				LoadViewModel ();
				IsBusy = false;
			}
		}

		private void SaveViewModel(){
			if (ContactSearch.ViewModel == null)
				ContactSearch.ViewModel = new ContactSearchViewModel ();
            ContactSearch.ViewModel.FirstName = firstname.Text;
			ContactSearch.ViewModel.LastName = lastname.Text;
            ContactSearch.ViewModel.Title = title.Text;
            ContactSearch.ViewModel.Email = email.Text;
            ContactSearch.ViewModel.City = city.Text;
            ContactSearch.ViewModel.Zip = zip.Text;



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
			//contactName.Text = ViewModel.ContactName;
			//bbNumber.Text = ViewModel.BBNumber;


			firstname.Text = "";
            lastname.Text = "";
            title.Text = "";
            email.Text = "";
            city.Text = "";
            zip.Text = "";




		}





	}
}

