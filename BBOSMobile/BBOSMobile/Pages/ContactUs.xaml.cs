using System;
using System.Collections.Generic;

using Xamarin.Forms;
using BBOSMobile.Core;
using BBOSMobile.Core.Interfaces;
using BBOSMobile.Core.Models;

namespace BBOSMobile.Forms.Pages
{
	public partial class ContactUs : BaseContentPage
	{
		protected override void OnAppearing ()
		{
			InitializeComponent ();
			Title = "Contact Us";
			//Make phone label clickable
//			lblPhone.GestureRecognizers.Add (new TapGestureRecognizer {
//				Command = new Command (()=> OnPhoneClicked()),
//			});

			//			lblEmail.GestureRecognizers.Add (new TapGestureRecognizer {
			//				Command = new Command (()=> OnEmailClicked()),
			//			});

//			lblWebsite.GestureRecognizers.Add (new TapGestureRecognizer {
//				Command = new Command (()=> OnWebsiteClicked()),
//			});

			//			lblAddress.GestureRecognizers.Add (new TapGestureRecognizer {
			//				Command = new Command (()=> OnAddressClicked()),
			//			});

		}
		public ContactUs ()
		{
			//InitializeComponent ();
		
			//ITrackerService service = App.TrackerService;
			//service.TrackScreen ("Contact Us");


		}
		protected override bool OnBackButtonPressed()
		{
			if (!IsBusy) {
				IsBusy = true;
				var page = new Dashboard ();
				App.RootPage.NavigateToPage (page);
				IsBusy = false;
				return true;
			}
			return false;
		}
		void OnPhoneClicked(object sender, EventArgs e) 
		{
			//Launch dialer here...doesn't seem to be showing anything in the simulator though.
			//Not sure if it is a simulator issue or I'm doing something wrong here.
			if (!IsBusy) {
				IPhoneCallService phone = DependencyService.Get<IPhoneCallService> ();
				phone.MakeCall ("6306683500");
				IsBusy = false;
			}
		}

		public void OnEmailClicked (object sender, EventArgs e) 
		{
			if (!IsBusy){
				IsBusy = true;
				IEmailService service = DependencyService.Get<IEmailService> ();
				if (service.CanSendEmail()) {
					Email email = new Email ();
					email.ToAddresses = new List<string> (){ "info@bluebookservices.com" };
					email.Subject = "";
					email.Body = "";
					service.CreateEmail (email);
				} else {
					DisplayAlert (Common.Constants.AlertTitle, Common.Constants.InvalidEmailSetupAlertMessage, Common.Constants.AlertOk);
				}

				IsBusy = false;
			}
		}

		void OnWebsiteClicked(object sender, EventArgs e) 
		{
			if (!IsBusy) {
				IsBusy = true;
				Device.OpenUri (new Uri ("http://www.bluebookservices.com"));
				IsBusy = false;
			}
		}

		void OnAddressClicked()
		{
			if (!IsBusy) {
				IsBusy = true;
				string address = System.Net.WebUtility.UrlEncode ("Carol Stream, IL USA 60188-3520");
				if (Device.OS == TargetPlatform.iOS) {
					Device.OpenUri (new Uri ("http://maps.apple.com/?q=" + address));
				} else if (Device.OS == TargetPlatform.Android) {
					Device.OpenUri (new Uri ("geo:0,0?q=" + address));
				}
				IsBusy = false;
			}
		}
	}
}

