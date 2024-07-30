using System;
using System.Collections.Generic;

using Xamarin.Forms;
using BBOSMobile.Core;
using BBOSMobile.Core.Data;
using System.Linq;
using BBOSMobile.Core.Models;
using BBOSMobile.Core.Interfaces;
using Xamarin.Essentials;

namespace BBOSMobile.Forms.Pages
{
	public partial class AboutUs : BaseContentPage
	{
		public static bool ShouldKeepContent;

		public AboutUs ()
		{
			IsBusy = true;
			InitializeComponent ();	
			SetupEventHandlers ();
			LoadAboutUsInfo ();
			Title = "About Us";
			//ITrackerService service = App.TrackerService;
			//service.TrackScreen ("Company Notes");
			IsBusy = false;
		}
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
			AboutUs.ShouldKeepContent = false;
			IsBusy = false;
		}

		protected override void OnDisappearing ()
		{
			if (ShouldClearContent(AboutUs.ShouldKeepContent)) 
			{
			} 
		}

		private void SetupEventHandlers(){
			lblTermsOfService.GestureRecognizers.Add (new TapGestureRecognizer {
				Command = new Command (()=> OnTermsOfServiceClicked()),
			});

			lblPrivacyStatement.GestureRecognizers.Add (new TapGestureRecognizer {
				Command = new Command (()=> OnPrivacyStatementClicked()),
			});
		}

		private void LoadAboutUsInfo(){
			
			IDeviceInfoService deviceInfo = DependencyService.Get<IDeviceInfoService>();
			deviceInfo.LoadInfo ();
			lblVersion.Text += " " + deviceInfo.AppVersion + " " + deviceInfo.PhonePlatform + " (" + deviceInfo.PhoneOS + ")";
//			lblVersion.Text += " " + deviceInfo.AppVersion + " " + deviceInfo.PhonePlatform + " (" + deviceInfo.PhoneOS + ")" + "\n" + "Package: " + AppInfo.PackageName;
		}

		public void OnTermsOfServiceClicked(){	
			AboutUs.ShouldKeepContent = true;
			Navigation.PushAsync (new TermsOfService ());
		}

		public void OnPrivacyStatementClicked(){
			AboutUs.ShouldKeepContent = true;
			Navigation.PushAsync (new PrivacyStatement ());
		}

	}
}

