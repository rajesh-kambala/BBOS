using System;
using System.Collections.Generic;
using Xamarin.Forms;
using BBOSMobile.Forms.Pages;
using BBOSMobile.Core.Interfaces;
using BBOSMobile.Core.Models;
using System.Diagnostics;

namespace BBOSMobile.Forms
{
	public partial class CompanySummaryListContentView : ContentView
	{
		private CompanyViewModel companyViewModel;
		public CompanySummaryListContentView (CompanyViewModel viewModel)
		{
			InitializeComponent ();
			companyViewModel = viewModel;
			BindingContext = viewModel;

			//ITrackerService service = App.TrackerService;
			//service.TrackScreen ("Company Summary List");
		}

		async void OnListItemTapped(object sender, ItemTappedEventArgs e)
		{
			((ListView)sender).SelectedItem = null; 
			var model = e.Item as CompanySummaryListItemViewModel;

			Debug.WriteLine("@@@@@@@socialImage:" + model.Image);
			Debug.WriteLine("@@@@@@@socialURL:" +  model.SocialURL);



			if (model.Action) {
				if (model.ActionURL == "RATING") {
					if (companyViewModel.ViewRating.Enabled) {
						var ratingPage = new RatingPage (companyViewModel);
						await Navigation.PushAsync(ratingPage);
					} else {
						await App.RootPage.DisplayAlert (Common.Constants.AlertTitle, Common.Constants.InvalidPermissionAlertMessage, Common.Constants.AlertOk);
					}


					// de-select the row


				}
				if (model.ActionURL == "PHONE") {
					MakePhoneCall (model.Value);
				}
				if (model.ActionURL == "EMAIL") {
					MakeEmailCall (model.Value);
				}
				if (model.ActionURL == "WEB") {
					MakeWebCall (model.Value);
				}
				if (model.ActionURL == "SOCIAL") {
					MakeWebCall (model.SocialURL);
				}
			}

		}

		void MakePhoneCall (string phoneNumber) {
			if (!string.IsNullOrEmpty (phoneNumber)) 
			{
				var formattedNumber = phoneNumber.Replace ("-", string.Empty).Replace (" ", string.Empty).Trim ();

				DependencyService.Get<IPhoneCallService>().MakeCall (formattedNumber);
			}
		}
		void MakeEmailCall(string emailAddress)
		{
			if (!string.IsNullOrEmpty (emailAddress)) {
				IEmailService service = DependencyService.Get<IEmailService> ();
				if (service.CanSendEmail()) {
					Email email = new Email ();
					email.ToAddresses = new List<string> (){ emailAddress };
					email.Subject = "";
					email.Body = "";
					service.CreateEmail (email);
				} else {
					App.RootPage.DisplayAlert (Common.Constants.AlertTitle, Common.Constants.InvalidEmailSetupAlertMessage, Common.Constants.AlertOk);
				}

			}

		}

		void MakeWebCall(string url)
		{
			if (!string.IsNullOrEmpty (url)) {
				if (!url.Contains("://"))
					url = "http://" + url;

//				//LinkedIn Check
//				if(url.Contains("www.linkedin.com"))
//					url = url.Replace("http://www.linkedin.com/Company", "https://touch.www.linkedin.com/?dl=no#company");
//				//https://touch.www.linkedin.com/?dl=no#company/864869
//				//http://www.linkedin.com/Company/86489
//
//				//Facebook Check
//				if(url.Contains("www.facebook.com"))
//					url = url.Replace("https://www.facebook.com/pages", "fb://page/");
//				//fb://page/7844589738 
//				//https://www.facebook.com/pages/Hudson-River-Fruit-Distributors/409825405724581"
				try{
					Device.OpenUri(new Uri(url));
				}
				catch{
				}

			}

		}
	}
}

