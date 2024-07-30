using System;
using System.Collections.Generic;

using Xamarin.Forms;
using BBOSMobile.Core;
using BBOSMobile.Forms.Custom;
using BBOSMobile.ServiceModels.Common;
using System.Threading.Tasks;
using BBOSMobile.ServiceModels.Requests;
using BBOSMobile.Core.Interfaces;


namespace BBOSMobile.Forms.Pages
{
	public partial class WatchdogAddPage : BaseContentPage
	{
		private int BBID {get;set;}
		private List<int> WatchDogGroups { get; set; }
		private WatchdogAddViewModel vm { get; set; }

		public WatchdogAddPage (int BBID)
		{
			IsBusy = true;
			InitializeComponent ();
			this.BBID = BBID;
			this.Title = "Watchdog Add";

			ITrackerService service = App.TrackerService;
			//service.TrackScreen ("WatchDog Add");
			IsBusy = false;
		}

		protected async override void OnAppearing ()
		{
			IsBusy = true;
			base.OnAppearing ();
			Setup ();
			IsBusy = false;
		}

		protected override bool OnBackButtonPressed()
		{
			if (!IsBusy) {
				Navigation.PopAsync();
				return true;
			}
			return false;

		}
		private async void OnCancelButtonClicked(object sender, EventArgs args)
		{
			if (!IsBusy) {
				await Navigation.PopAsync ();
			}

		}
		private async void OnSaveButtonClicked(object sender, EventArgs args)
		{
			if (!IsBusy) 
			{
				IsBusy = true;
				//save to watchdog groups
				loadLayout.IsVisible = true;
				bool retVal = true;
				var userCredentials = DependencyService.Get<IUserCredentialsService> ().GetUserCredentials ();

				foreach(var item in vm.WatchdogListItems)
				{
					var request = new WatchdogUpdateRequest ();
					request.UserId = userCredentials.UserId;
					if (item.InGroup) {
						//save to group
						request.BBID = this.BBID;
						request.WatchdogID = item.WatchdogGroupId;
						bool savedToGroup = await SaveToWatchDogGroup (request);
						if (savedToGroup == false) {
							retVal = false;
						}

					} else {
						//remove from group
						request.BBID = this.BBID;
						request.WatchdogID = item.WatchdogGroupId;
						bool removedFromGroups = await RemoveWatchDogFromGroup (request);
						if (removedFromGroups == false) {
							retVal = false;
						}
					}
				}
				loadLayout.IsVisible = false;

				if (retVal) 
				{
					await Navigation.PopAsync ();
				} 
				else 
				{
					await DisplayAlert (Common.Constants.AlertTitle, "Error Saving to Watchdog Groups", Common.Constants.AlertOk);
				}
				IsBusy = false;
			}


		}

		private async Task<bool> SaveToWatchDogGroup(WatchdogUpdateRequest request)
		{
			bool returnValue = false;

			var client = new WatchdogWebserviceClient ();
			var response = await client.AddCompanyToWatchDogGroup (request);

			if (response.ResponseStatus != Enumerations.ResponseStatus.Failure) 
			{
				returnValue = true;
			}

			return returnValue;
		}
		private async Task<bool> RemoveWatchDogFromGroup(WatchdogUpdateRequest request)
		{
			bool returnValue = false;

			var client = new WatchdogWebserviceClient ();
			var response = await client.RemoveCompanyFromWatchDogGroup (request);

			if (response.ResponseStatus != Enumerations.ResponseStatus.Failure) 
			{
				returnValue = true;
			}

			return returnValue;
		}

		private async void Setup()
		{

			try
			{
				//only show CU and AUS type code (third list is CL - can not add to or remove from)
				var watchdogServiceClient = new WatchdogWebserviceClient ();
				var companyServiceClient = new CompanyWebserviceClient ();

				var watchdogResponse = await watchdogServiceClient.GetWatchdogs (BBID);
				if (watchdogResponse.ResponseStatus == BBOSMobile.ServiceModels.Common.Enumerations.ResponseStatus.InvalidUserId) 
				{
					await Navigation.PushAsync(new LoginPage ());
					return;
				}

				var companyResponse = await companyServiceClient.GetCompany(BBID);
				if (companyResponse.ResponseStatus == BBOSMobile.ServiceModels.Common.Enumerations.ResponseStatus.InvalidUserId) 
				{
					await Navigation.PushAsync(new LoginPage ());
					return;
				}

				if (watchdogResponse.ResponseStatus != Enumerations.ResponseStatus.Failure) 
				{
					var watchdogList = new List<WatchdogListItemViewModel> ();

					foreach(var watchdog in watchdogResponse.WatchdogGroups)
					{
						var watchdogListItem = new WatchdogListItemViewModel ();
						watchdogListItem.Count = watchdog.Count;
						watchdogListItem.Name = watchdog.Name;
						watchdogListItem.IsPrivate = watchdog.IsPrivate;
						watchdogListItem.WatchdogGroupId = watchdog.WatchdogGroupId;
						watchdogListItem.InGroup = watchdog.InGroup;
						watchdogList.Add (watchdogListItem);
					}

					vm = new WatchdogAddViewModel ();
					vm.WatchdogListItems = watchdogList;
					vm.Company = companyResponse.Company;

					var view = new WatchdogAddListContentView (vm);
					mainLayout.Children.Add (view);
					loadLayout.IsVisible = false;
					mainLayout.IsVisible = true;
					listLayout.IsVisible = true;
					sectionLayout.IsVisible = true;
					buttonLayout.IsVisible = true;
					this.BindingContext = vm;

				}
			} catch(Exception ex) {
				DisplayErrorLoadingAlert ();
			}


			//var watchdogResponse = await watchdogServiceClient.GetWatchdogsMockData();

		}
	}
}

