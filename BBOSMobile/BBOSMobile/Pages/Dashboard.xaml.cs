using System;
using System.Collections.Generic;

using Xamarin.Forms;
using BBOSMobile.Core.Interfaces;
using BBOSMobile.Core.Models;
using BBOSMobile.Core.WebServices;
using BBOSMobile.ServiceModels.Requests;
using BBOSMobile.ServiceModels.Responses;

namespace BBOSMobile.Forms.Pages
{
	public partial class Dashboard : BaseContentPage
	{
		

		public Dashboard ()
		{
			InitializeComponent ();
			Title = "Blue Book Services";
			if (!App.RecentViewsSecurity.Enabled) {
				imageRV.Opacity = .5;
			}
			if (!App.WatchdogListsPage.Enabled) {
				imageWD.Opacity = .5;
			}
			//ITrackerService service = App.TrackerService;
			//service.TrackScreen ("Dashboard");
		}
		public void NavigateToPage(int tabNumber)
		{
			var page = new InternalRootPage ();
			page.SelectedItem = page.Children [tabNumber];
			page.Title = page.Children [tabNumber].Title;
			App.RootPage.NavigateToPage (page);
		}

		void OnQuickFindButtonClicked(object sender, EventArgs args)
		{
			if (!IsBusy) {
				IsBusy = true;
				var page = new QuickFind ();
				App.RootPage.NavigateToPage (page);
				//NavigateToPage (0);
				IsBusy = false;
			}

		}

		void OnCompanySearchButtonClicked(object sender, EventArgs args)
		{
			if (!IsBusy) {
				IsBusy = true;
				//NavigateToPage (1);
				var page = new CompanySearch ();
				App.RootPage.NavigateToPage (page);
				IsBusy = false;
			}
		}

        void OnPersonSearchButtonClicked(object sender, EventArgs args)
        {
            if (!IsBusy)
            {
                IsBusy = true;
                //NavigateToPage (1);
                var page = new ContactSearch();
                App.RootPage.NavigateToPage(page);
                IsBusy = false;
            }
        }
        void OnRecentViewsButtonClicked(object sender, EventArgs args)
		{
			//NavigateToPage (2);
			if (!IsBusy) {
				IsBusy = true;
				if (App.RecentViewsSecurity.Enabled) {
					var page = new RecentViews ();
					App.RootPage.NavigateToPage (page);
				} else {
					DisplayAlert (Common.Constants.AlertTitle, Common.Constants.InvalidPermissionAlertMessage, Common.Constants.AlertOk);
				}
				IsBusy = false;
			}
		}

		void OnWatchDogButtonClicked(object sender, EventArgs args)
		{
			if (!IsBusy) {
				IsBusy = true;
				if (App.WatchdogListsPage.Enabled) {
					var page = new WatchDogGroupsPage ();
					App.RootPage.NavigateToPage (page);
				} else {
					DisplayAlert (Common.Constants.AlertTitle, Common.Constants.InvalidPermissionAlertMessage, Common.Constants.AlertOk);
				}
				IsBusy = false;
			}
		}
	}
}

