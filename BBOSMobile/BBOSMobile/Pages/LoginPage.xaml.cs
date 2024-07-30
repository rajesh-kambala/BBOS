using System;

using System.Threading.Tasks;

using Xamarin.Forms;
using BBOSMobile.Core.Interfaces;
using BBOSMobile.Core.Managers;
using BBOSMobile.Core.Models;
using BBOSMobile.Core.WebServices;
using BBOSMobile.Forms.Pages.Menu;
using BBOSMobile.Forms.ViewModels;
using BBOSMobile.ServiceModels.Common;
using BBOSMobile.ServiceModels.Requests;

using System.Diagnostics;
using Xamarin.Essentials;

namespace BBOSMobile.Forms.Pages
{
	public partial class LoginPage : BaseContentPage
	{
		LoginViewModel viewModel;
		UserCredentials userCredentials;
		bool _termsRequired = true;
        string _version = string.Empty;
        public LoginPage ()
		{

            Debug.WriteLine("showing login page -- start");

			viewModel = new LoginViewModel ();
			this.BindingContext = viewModel;



			NavigationPage.SetHasNavigationBar (this, false);
			//ITrackerService service = App.TrackerService;
			ITrackerService service = DependencyService.Get<ITrackerService>();
            //service.TrackScreen ("Company Search Results");

			DependencyService.Get<IUserCredentialsService> ().ClearUserCredentials ();
			InitializeComponent ();

            VersionTracking.Track();
            if (Device.RuntimePlatform == Device.iOS)
            {
                _version = "Version: " + VersionTracking.CurrentVersion;
            }
            if (Device.RuntimePlatform == Device.Android)
            {
                _version = "Version: " + VersionTracking.CurrentVersion;
                _version = _version + " Build: " + VersionTracking.CurrentBuild;
            }
			lblVersion.Text = _version;
            Debug.WriteLine("showing login page -- end");

        }

		//		void EmailPropertyChanged(object sender, EventArgs args)
		//		{
		//			lblEmailError.TextColor = Color.Transparent;
		//		}
		//
		//		void PasswordPropertyChanged(object sender, EventArgs args)
		//		{
		//			lblPassError.TextColor = Color.Transparent;
		//		}

		void OnTapGestureRecognizerTapped(object sender, EventArgs args)
		{
            if (txtPassword.IsPassword)
            {

				txtPassword.IsPassword = false;
				lblShowHide.Text = "Hide";
				
            }
            else
			{
				txtPassword.IsPassword = true;
				lblShowHide.Text = "Show";
			}
		}

		private async void OnLoginButtonClicked(object sender, EventArgs args)
		{

            Debug.WriteLine("login button clicked -- start");

            viewModel.IsBusy = true;
			bool validForm = true;

			if (string.IsNullOrEmpty (viewModel.Email)) 
			{
				lblEmailError.TextColor = Color.Red;
				validForm = false;
			}

			if (string.IsNullOrEmpty (viewModel.Password)) 
			{
				lblPassError.TextColor = Color.Red;
				validForm = false;
			}

            Debug.WriteLine("form validated");

            if (validForm) 
			{
				bool login = await Login ();
				viewModel.IsBusy = false;
				if (login) 
				{
					//check for terms and redirect there if needed
					if (_termsRequired) {
						await this.Navigation.PushModalAsync (new TermsOfUse (this.userCredentials));
					} else {
						DependencyService.Get<IUserCredentialsService> ().SetUserCredentials (this.userCredentials);
						App.RootPage = new RootPage ();
						await this.Navigation.PushModalAsync (App.RootPage);
					}

				} 
				else 
				{
					await DisplayAlert (Common.Constants.AlertTitle, Common.Constants.InvalidLoginAlertMessage, Common.Constants.AlertOk);
				}
			}
			viewModel.IsBusy = false;

            Debug.WriteLine("login button clicked -- end");
        }

		void OnForgetPasswordButtonClicked(object sender, EventArgs args)
		{
			ShouldClearContent (true);
			this.Navigation.PushModalAsync(new ForgotPassword ());
		}
		void OnLearnMoreButtonClicked(object sender, EventArgs args)
		{
			ShouldClearContent (true);
			Device.OpenUri(new Uri("http://www.bluebookservices.com"));
		}


		/// <summary>
		/// Login with email / password
		/// </summary>
		private async Task<bool> Login()
		{

            
			bool returnValue = false;

			var request = new LoginRequest () { 

                Email = viewModel.Email,
                Password = viewModel.Password


            };

			try
			{
				var loginClient = new UserWebserviceClient ();
                Debug.WriteLine("start login check");
                var response = await loginClient.Login(request);
                Debug.WriteLine("finished login check");

                if (response.ResponseStatus != Enumerations.ResponseStatus.Failure) 
				{
					// Code to Store Local Credentials
					returnValue = true;
					_termsRequired = response.TermsRequired == null ? true : response.TermsRequired;
					this.userCredentials = new UserCredentials {
						Email = viewModel.Email,
						Password = viewModel.Password,
						UserId = response.UserId,
						UserType = response.UserType,
						UserLevel = response.UserAccessInfo.UserLevel,
						SecurityPrivileges = response.UserAccessInfo.SecurityPrivileges,
						UserBBID = response.BBID,
						UserRelatedBBIDs = response.RelatedBBIDs

					};
					DependencyService.Get<IUserCredentialsService> ().SetUserCredentials (this.userCredentials);
					App.RecentViewsSecurity = userCredentials.SecurityPrivileges.Find (m => m.PrivilegeName == BBOSMobile.ServiceModels.Common.Enumerations.Privilege.RecentViewsPage); 
					App.WatchdogListsPage = userCredentials.SecurityPrivileges.Find (m => m.PrivilegeName == BBOSMobile.ServiceModels.Common.Enumerations.Privilege.WatchdogListsPage);

					App.UserBBID = userCredentials.UserBBID;
					App.UserRelatedBBIDs = userCredentials.UserRelatedBBIDs;

					Debug.WriteLine("App.UserBBID: "+ App.UserBBID);
					//Debug.WriteLine("App.UserRelatedBBIDs: "+ App.UserRelatedBBIDs);


					var lookUpListManager = new LookUpListManager ();
					lookUpListManager.UpdateLookUpLists (response.CategoryListsItems);
				}
			} catch(Exception ex) {
				//DisplayErrorLoadingAlert ();
			}

			return returnValue;
		}
	}
}

