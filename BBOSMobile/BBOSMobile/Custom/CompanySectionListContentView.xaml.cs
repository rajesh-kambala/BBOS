using System;
using System.Collections.Generic;

using Xamarin.Forms;
using BBOSMobile.Forms.Pages;
using BBOSMobile.ServiceModels.Common;
using BBOSMobile.Core;
using BBOSMobile.Core.Interfaces;

namespace BBOSMobile.Forms.Custom
{
	public partial class CompanySectionListContentView : ContentView
	{
		public CompanySectionListContentView (CompanyViewModel viewModel)
		{
			InitializeComponent ();
			//ITrackerService service = App.TrackerService;
			//service.TrackScreen ("Company Section List");
//			foreach (var item in viewModel.SectionItems) 
//			{
//				var button = new Button (){ Text = item.DisplayName };
//				button.Clicked += ButtonClicked;
//				//button.BackgroundColor = Color.Gray;
//				button.TextColor = Color.White;
//				sectionLayout.Children.Add (button);
//			}
		}
			
//		private void ButtonClicked(object sender, EventArgs e)
//		{
//			Button button = (Button)sender;
//			App.RootPage.DisplayAlert ("Alert", button.Text , "OK");
//			// do stuff
//		}

//		async void OnListItemTapped(object sender, ItemTappedEventArgs e)
//		{
//			var model = e.Item as CompanyListItemViewModel;
//			var companyDetailPage = new CompanyPage(model.BBID);
//
//			// de-select the row
//			((ListView)sender).SelectedItem = null; 
//
//			await Navigation.PushAsync(companyDetailPage);
//		}
//
//		public void OnCall (object sender, EventArgs e) {
//
//			var mi = ((Xamarin.Forms.MenuItem)sender);
//			var phoneNumber = mi.CommandParameter.ToString();
//
//			if (!string.IsNullOrEmpty (phoneNumber)) 
//			{
//				var formattedNumber = phoneNumber.Replace ("-", string.Empty).Replace (" ", string.Empty).Trim ();
//
//				DependencyService.Get<IPhoneCallService>().MakeCall (formattedNumber);
//			}
//
//			//Device.OpenUri (new Uri ("tel://01234567890"));
//			//DisplayAlert("Call Company Context Action", mi.CommandParameter + " call company context action", "OK");
//
//		}
	}
}

