using System;
using System.Collections.Generic;

using Xamarin.Forms;
using BBOSMobile.Forms.Pages;
using BBOSMobile.ServiceModels.Common;
using BBOSMobile.Core;
using BBOSMobile.Core.Interfaces;

namespace BBOSMobile.Forms.Custom
{
	public partial class CompanyListContentView : ContentView
	{
		public ListView ListViewCompany 
		{
			
			get
			{  
				return listViewCompany;
			}

			set 
			{
				listViewCompany = value;
			}

		}

		public CompanyListContentView (CompanyListViewModel viewModel, bool ShowNoRecsFoundAlert)
		{
			
				InitializeComponent ();
				BindingContext = viewModel;

				if (viewModel.Companies.Count == 0 && ShowNoRecsFoundAlert) 
				{
					noRecordsFound.IsVisible = true;
					listViewCompany.IsVisible = false;
				} 
				else if (viewModel.Companies.Count == 0 && !ShowNoRecsFoundAlert) { 
					noRecordsFound.IsVisible = false;
					listViewCompany.IsVisible = false;
			}	
			else
			{ 
					noRecordsFound.IsVisible = false;
					listViewCompany.IsVisible = true;
				}
            //listViewCompany.Header = "Companies";

        }

		async void OnListItemTapped(object sender, ItemTappedEventArgs e)
		{
			var model = e.Item as CompanyListItemViewModel;
			var companyDetailPage = new CompanyPage(model.BBID);

			// de-select the row
			((ListView)sender).SelectedItem = null; 

			WatchdogDetailPage.ShouldKeepContent = true;
			CompanySearchResults.ShouldKeepContent = true;
			CompanySearch.ShouldKeepContent = true;
			RecentViews.ShouldKeepContent = true;
			await Navigation.PushAsync(companyDetailPage);
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

