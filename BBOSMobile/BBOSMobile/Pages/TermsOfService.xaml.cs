using System;
using System.Linq;

using Xamarin.Forms;
using BBOSMobile.Core.Managers;
using BBOSMobile.Core.Models;
using BBOSMobile.Core.WebServices;
using BBOSMobile.Core.Interfaces;
using BBOSMobile.ServiceModels.Common;

namespace BBOSMobile.Forms.Pages
{
	public partial class TermsOfService : BaseContentPage
	{
		private Terms terms;
		public TermsOfService ()
		{
			InitializeComponent ();

			var userCredentials = DependencyService.Get<IUserCredentialsService> ().GetUserCredentials ();
			if (userCredentials.UserId == Guid.Empty) {
				//MainPage = new LoginPage ();
			} else {
				LoadTermsOfService (userCredentials);
				this.Title = "Terms Of Use";
				//ITrackerService service = App.TrackerService;
				//service.TrackScreen ("Terms Of Use");
			}
		}

		protected async void LoadTermsOfService(UserCredentials userCredentials)
		{
			try
			{
				var userWebserviceClient = new UserWebserviceClient ();
				var termsResponse = await userWebserviceClient.GetTerms (userCredentials);

				if (termsResponse.ResponseStatus == BBOSMobile.ServiceModels.Common.Enumerations.ResponseStatus.InvalidUserId) 
				{
					await Navigation.PushAsync(new LoginPage ());
					return;
				}

				if (termsResponse.ResponseStatus != Enumerations.ResponseStatus.Failure) 
				{
					terms = new Terms ();
					terms.TermDate = DateTime.UtcNow;
					terms.TermsText = termsResponse.TermsText;
					terms.TermsVersion = terms.TermsVersion;

					var source = new HtmlWebViewSource();
					source.Html = termsResponse.TermsText;
					termsWebView.Source = source;
				}
			} catch(Exception ex) {
				//log
				DisplayErrorLoadingAlert ();
			}
			activityIndicator.IsEnabled = false;
			activityIndicator.IsRunning = false;
			activityIndicator.IsVisible = false;
		}
	}
}

