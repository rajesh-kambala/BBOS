using System;
using System.Collections.Generic;

using Xamarin.Forms;
using BBOSMobile.Forms.Pages;
using BBOSMobile.ServiceModels.Common;
using BBOSMobile.Core;
using BBOSMobile.Core.Interfaces;

namespace BBOSMobile.Forms.Custom
{
	public partial class ContactListContentView : ContentView
	{
		public ListView ListViewContact 
		{
			
			get
			{  
				return listViewContact;
			}

			set 
			{
				listViewContact = value;
			}

		}

		public ContactListContentView (ContactListViewModel viewModel)
		{
			
				InitializeComponent ();
				BindingContext = viewModel;

				if (viewModel.Contacts.Count == 0) 
				{
					noRecordsFound.IsVisible = true;
					listViewContact.IsVisible = false;
				} 
				else 
				{
					noRecordsFound.IsVisible = false;
					listViewContact.IsVisible = true;
				}

            //ListViewContact.Header = "Persons";
		}

		async void OnListItemTapped(object sender, ItemTappedEventArgs e)
		{
			var model = e.Item as ContactListItemViewModel;
			var contactDetailPage = new ContactPage(model.ContactID, model.BBID);

			// de-select the row
			((ListView)sender).SelectedItem = null; 

			WatchdogDetailPage.ShouldKeepContent = true;
			ContactSearchResults.ShouldKeepContent = true;
			ContactSearch.ShouldKeepContent = true;
			RecentViews.ShouldKeepContent = true;
			await Navigation.PushAsync(contactDetailPage);
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
			//DisplayAlert("Call Contact Context Action", mi.CommandParameter + " call contact context action", "OK");

		}
	}
}

