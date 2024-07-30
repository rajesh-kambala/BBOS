using System;
using System.Collections.Generic;

using Xamarin.Forms;
using BBOSMobile.Core;
using BBOSMobile.Forms.Custom;
using BBOSMobile.ServiceModels.Common;
using BBOSMobile.Core.Interfaces;

namespace BBOSMobile.Forms.Pages
{
	public partial class WatchDogGroupsPage : BaseContentPage
	{
		public static bool ShouldKeepContent;

		private bool isPageBusy;

		public WatchDogGroupsPage ()
		{
			InitializeComponent ();	
			Title = "Watchdog Groups";
			//TestRedirect ();
			var tapGestureRecognizerRV = new TapGestureRecognizer();
			tapGestureRecognizerRV.Tapped += (s, e) => {
				if (!isPageBusy){
					// handle the tap
					if ((App.RecentViewsSecurity.HasPrivilege) || (App.RecentViewsSecurity.Enabled)) {
						var page = new RecentViews ();
						App.RootPage.NavigateToPage (page);
					}
					else{
						DisplayAlert (Common.Constants.AlertTitle, Common.Constants.InvalidPermissionAlertMessage, Common.Constants.AlertOk);
					}
				}


			};
			RVSL.GestureRecognizers.Add(tapGestureRecognizerRV);
			if (!App.RecentViewsSecurity.HasPrivilege && !App.RecentViewsSecurity.Enabled) {
				RVSL.Opacity = .5;
			}
			if (!App.WatchdogListsPage.HasPrivilege && !App.WatchdogListsPage.Enabled) {
				WDSL.Opacity = .5;
			}

			var tapGestureRecognizerCS = new TapGestureRecognizer();
			tapGestureRecognizerCS.Tapped += (s, e) => {
				// handle the tap
				if(!isPageBusy){
					var page = new CompanySearch ();
					App.RootPage.NavigateToPage (page);
				}

			};
			CSSL.GestureRecognizers.Add(tapGestureRecognizerCS);

			var tapGestureRecognizerQF = new TapGestureRecognizer();
			tapGestureRecognizerQF.Tapped += (s, e) => {
				// handle the tap
				if(!isPageBusy){
					var page = new QuickFind ();
					App.RootPage.NavigateToPage (page);
				}

			};
			QFSL.GestureRecognizers.Add(tapGestureRecognizerQF);

            var tapGestureRecognizerPS = new TapGestureRecognizer();
            tapGestureRecognizerPS.Tapped += (s, e) => {
                // handle the tap
                var page = new ContactSearch();
                App.RootPage.NavigateToPage(page);
            };
            PSSL.GestureRecognizers.Add(tapGestureRecognizerPS);

            ITrackerService service = App.TrackerService;
			//service.TrackScreen ("WatchDog Groups");
		}

		protected async override void OnAppearing ()
		{
				WatchDogGroupsPage.ShouldKeepContent = false;
				base.OnAppearing ();
				Setup ();

		}
		protected override bool OnBackButtonPressed()
		{
			var page = new Dashboard ();
			App.RootPage.NavigateToPage (page);
			return true;
		}
		void OnCompanySearchButtonPressed(object sender, EventArgs args)
		{
			var page = new CompanySearch ();
			App.RootPage.NavigateToPage (page);
		}
		void OnRecentViewsButtonPressed(object sender, EventArgs args)
		{
			var page = new RecentViews ();
			App.RootPage.NavigateToPage (page);
		}
		void OnQuickFindButtonPressed(object sender, EventArgs args)
		{
			var page = new QuickFind ();
			App.RootPage.NavigateToPage (page);
		}
		protected override void OnDisappearing ()
		{
			if (ShouldClearContent(WatchDogGroupsPage.ShouldKeepContent)) 
			{
			} 
		}

		async void TestRedirect()
		{
			var watchdogAddPage = new WatchdogAddPage(281523);
			await Navigation.PushAsync(watchdogAddPage);
		}

		private async void Setup()
		{
			//IsBusy = true;
			isPageBusy = true;
			try
			{
				var serviceClient = new WatchdogWebserviceClient ();
				var response = await serviceClient.GetWatchdogs (0);
				if (response.ResponseStatus == BBOSMobile.ServiceModels.Common.Enumerations.ResponseStatus.InvalidUserId) 
				{
					await Navigation.PushAsync(new LoginPage ());
					return;
				}
				if (response.ResponseStatus != Enumerations.ResponseStatus.Failure) 
				{
					if (response.WatchdogGroups != null) {
						var watchdogList = new List<WatchdogListItemViewModel> ();

						if (response.WatchdogGroups != null) {
							foreach(var watchdog in response.WatchdogGroups)
							{
								var watchdogListItem = new WatchdogListItemViewModel ();
								watchdogListItem.Count = watchdog.Count;
								watchdogListItem.Name = watchdog.Name;
								watchdogListItem.IsPrivate = watchdog.IsPrivate;
								watchdogListItem.WatchdogGroupId = watchdog.WatchdogGroupId;

								watchdogList.Add (watchdogListItem);
							}

							WatchdogListViewModel viewModel = new WatchdogListViewModel ();
							viewModel.WatchdogListItems = watchdogList;

							var view = new WatchdogGroupListContentView (viewModel);
							listLayout.Children.Clear ();
							listLayout.Children.Add (view);
						}
					}

				}
			} catch(Exception ex) {
				//log
				DisplayErrorLoadingAlert ();
			}
			this.loadLayout.IsVisible = false;
			this.listLayout.IsVisible = true;

			isPageBusy = false;

		}
	}
}

