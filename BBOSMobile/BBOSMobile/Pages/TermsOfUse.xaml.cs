using System;

using Xamarin.Forms;
using BBOSMobile.Core.Managers;
using BBOSMobile.Core.Models;
using BBOSMobile.Core.WebServices;
using BBOSMobile.Forms.Pages.Menu;
using BBOSMobile.Core.Interfaces;
using BBOSMobile.ServiceModels.Common;

namespace BBOSMobile.Forms.Pages
{
	public partial class TermsOfUse : BaseContentPage
	{
		private Terms terms;
		UserCredentials userCredentials;
		public TermsOfUse (UserCredentials userCredentials)
		{
			InitializeComponent ();
			NavigationPage.SetHasNavigationBar (this, false);
			this.userCredentials = userCredentials;

			ITrackerService service = App.TrackerService;
			//service.TrackScreen ("Terms of Use (Prompted)");
		}

		protected async void OnIAcceptOnClick (object sender, EventArgs args)
		{
			if (terms != null) 
			{
				try
				{
					var bbosDataManager = new BBOSDataManager ();
					bbosDataManager.SaveItem (terms);
					var userWebserviceClient = new UserWebserviceClient ();

					DependencyService.Get<IUserCredentialsService> ().SetUserCredentials (this.userCredentials);
					var response = await userWebserviceClient.SaveTerms ();

					if (response.ResponseStatus != Enumerations.ResponseStatus.Failure) 
					{

					}
				} catch(Exception ex) {
					DisplayErrorLoadingAlert ();
				}
					
			}

			App.RootPage = new RootPage ();
			await this.Navigation.PushModalAsync (App.RootPage);
		}

		protected async override void OnAppearing ()
		{
			base.OnAppearing ();

			try
			{
				var userWebserviceClient = new UserWebserviceClient ();
				var termsResponse = await userWebserviceClient.GetTerms (userCredentials);

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
				DisplayErrorLoadingAlert ();
			}

			activityIndicator.IsEnabled = false;
			activityIndicator.IsRunning = false;
			activityIndicator.IsVisible = false;
		}
	}
}

