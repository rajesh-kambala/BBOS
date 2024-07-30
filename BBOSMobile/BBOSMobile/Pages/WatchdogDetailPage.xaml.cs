using System;
using System.Collections.Generic;

using Xamarin.Forms;
using BBOSMobile.Core;
using BBOSMobile.Forms.Custom;
using BBOSMobile.Forms.ViewModels;
using BBOSMobile.ServiceModels.Common;
using System.Collections.ObjectModel;
using BBOSMobile.Core.Interfaces;

namespace BBOSMobile.Forms.Pages
{
	public partial class WatchdogDetailPage : BaseContentPage
	{
		private WatchdogDetailViewModel viewModel;
		private WatchdogListItemViewModel listItemViewModel;
		private CompanyListContentView companyList;
		public static bool ShouldKeepContent;

		public WatchdogDetailPage (WatchdogListItemViewModel model)
		{
			InitializeComponent ();
			listItemViewModel = model;
			viewModel = new WatchdogDetailViewModel ();
			BindingContext = viewModel;
			Title = "Watchdog Group";

			ITrackerService service = App.TrackerService;
			//service.TrackScreen ("WatchDog Detail");
		}

		protected async override void OnAppearing ()
		{
			WatchdogDetailPage.ShouldKeepContent = false;
			base.OnAppearing ();
			Setup ();
		}

		protected override void OnDisappearing ()
		{
			if (ShouldClearContent(WatchdogDetailPage.ShouldKeepContent)) 
			{
//				viewModel = null;
//				listItemViewModel = null;
//				companyList = null;
			} 
		}

		private async void Setup()
		{
			try
			{
				var serviceClient = new WatchdogWebserviceClient ();
				var response = await serviceClient.GetWatchdogDetails (listItemViewModel.WatchdogGroupId);
				if (response.ResponseStatus == BBOSMobile.ServiceModels.Common.Enumerations.ResponseStatus.InvalidUserId) 
				{
					await Navigation.PushAsync(new LoginPage ());
					return;
				}

				if (response.ResponseStatus != Enumerations.ResponseStatus.Failure) 
				{
					var watchdogDetailViewModel = new WatchdogDetailViewModel ();
					watchdogDetailViewModel.WatchdogGroup = response.WatchdogGroup;
					watchdogDetailViewModel.WatchdogListItem = listItemViewModel;

					if (watchdogDetailViewModel != null) {
						if (watchdogDetailViewModel.WatchdogListItem != null) {
							viewModel.WatchdogListItem = watchdogDetailViewModel.WatchdogListItem;
							viewModel.WatchdogGroup = watchdogDetailViewModel.WatchdogGroup;
						}
					}

					CompanyListViewModel companyListViewModel = new CompanyListViewModel ();
					ObservableCollection<CompanyListItemViewModel> companyListItemList = new ObservableCollection<CompanyListItemViewModel> ();

					if (viewModel.WatchdogGroup.Companies != null) 
					{
						foreach(CompanyBase company in viewModel.WatchdogGroup.Companies)
						{			
							CompanyListItemViewModel companyListItemViewModel = new CompanyListItemViewModel ();
							companyListItemViewModel.BBID = company.BBID;
							companyListItemViewModel.HasNotes = company.HasNotes;
							companyListItemViewModel.IndustryAndType = string.Format ("{0} {1}", company.Industry, company.Type);
							companyListItemViewModel.Location = company.Location;
							companyListItemViewModel.Name = company.Name;
							companyListItemViewModel.Phone = company.Phone;
							companyListItemViewModel.Rating = company.Rating;
							companyListItemList.Add (companyListItemViewModel);
						}

						if (companyList != null) {
							mainLayout.Children.Remove (companyList);
						}

						companyListViewModel.Companies = companyListItemList;
						companyList = new CompanyListContentView (companyListViewModel,true);
						mainLayout.Children.Add (companyList);
					}
				}
			} catch(Exception ex) {
				//log
				DisplayErrorLoadingAlert ();
			}
			this.loadLayout.IsVisible = false;
			this.mainLayout.IsVisible = true;
			this.topLayout.IsVisible = true;
		}
	}
}

