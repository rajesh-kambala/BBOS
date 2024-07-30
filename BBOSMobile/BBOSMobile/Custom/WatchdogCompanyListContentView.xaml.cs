using System;
using System.Collections.Generic;

using Xamarin.Forms;
using BBOSMobile.Forms.Pages;
using BBOSMobile.Core.Interfaces;

namespace BBOSMobile.Forms.Custom
{
	public partial class WatchdogCompanyListContentView : ContentView
	{
		public WatchdogCompanyListContentView (CompanyListViewModel viewModel)
		{
			InitializeComponent ();
			BindingContext = viewModel;
		}

	

		public void OnCall (object sender, EventArgs e) {

			var mi = ((Xamarin.Forms.MenuItem)sender);
			var phoneNumber = mi.CommandParameter.ToString();

			if (!string.IsNullOrEmpty (phoneNumber)) 
			{
				var formattedNumber = phoneNumber.Replace ("-", string.Empty).Replace (" ", string.Empty).Trim ();

				DependencyService.Get<IPhoneCallService>().MakeCall (formattedNumber);
			}

			//Device.OpenUri (new Uri ("tel://01234567890"));
			//DisplayAlert("Call Company Context Action", mi.CommandParameter + " call company context action", "OK");

		}
	}
}

