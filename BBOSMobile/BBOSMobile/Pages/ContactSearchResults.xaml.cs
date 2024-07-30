using System;
using System.Collections.Generic;

using Xamarin.Forms;
using BBOSMobile.Forms.ViewModels;
using BBOSMobile.Core;
using BBOSMobile.ServiceModels.Requests;
using System.Collections.ObjectModel;
using BBOSMobile.Forms.Custom;
using BBOSMobile.Forms.Pages;
using BBOSMobile.Core.Interfaces;
using System.Diagnostics;

namespace BBOSMobile.Forms
{
	public partial class ContactSearchResults : BaseContentPage
	{
		//ContactSearchViewModel contactSearchViewModel;
		ContactListViewModel contactListViewModel;
		ContactListContentView contactListContentView;
		ContactSearchRequest request;
		public static bool ShouldKeepContent;

		public ContactSearchResults ()
		{
			InitializeComponent();
			//contactSearchViewModel = vm;	
			Title = "Results";

			//ITrackerService service = App.TrackerService;
			//service.TrackScreen ("Contact Search Results");
		}

		protected async override void OnAppearing ()
		{
			ContactSearchResults.ShouldKeepContent = false;
			base.OnAppearing ();
			GetContacts ();
		}

		protected override void OnDisappearing ()
		{
			if (ShouldClearContent(ContactSearchResults.ShouldKeepContent)) 
			{
				//contactSearchViewModel = null;
				//contactListViewModel = null;
				//contactListContentView = null;
				//request = null;
			} 
		}

		private void PrepareRequest(){
			if (request == null) {
				request = new ContactSearchRequest ();
				request.PageIndex = 0;
				request.PageSize = 20;
			}

			var contactSearchViewModel = ContactSearch.ViewModel;

			//Add our string filters from the viewmodel
			if (!string.IsNullOrEmpty (contactSearchViewModel.FirstName)) {
				request.FirstName = contactSearchViewModel.FirstName;
			}
            //TODO:  Need to parse this string into city/state/zip for webservices
            if (!string.IsNullOrEmpty(contactSearchViewModel.LastName))
            {
                request.LastName = contactSearchViewModel.LastName;
            }
            if (!string.IsNullOrEmpty(contactSearchViewModel.Title))
            {
                request.Title = contactSearchViewModel.Title;
            }
            if (!string.IsNullOrEmpty(contactSearchViewModel.Email))
            {
                request.Email = contactSearchViewModel.Email;
            }

            if (!string.IsNullOrEmpty(contactSearchViewModel.City))
            {
                request.City = contactSearchViewModel.City;
            }
            if (!string.IsNullOrEmpty(contactSearchViewModel.Zip))
            {
                request.PostalCode = contactSearchViewModel.Zip;
            }

            if (contactSearchViewModel.SelectedState != null)
            {
                if (contactSearchViewModel.SelectedState.StateId != -1)
                {
                    request.State = contactSearchViewModel.SelectedState.StateId.ToString();
                }
            }

            if (contactSearchViewModel.SelectedRadius != null)
            {
                //if (companySearchViewModel.SelectedRadius.Id != -1) {
                request.Radius = (BBOSMobile.ServiceModels.Common.Enumerations.Radius)contactSearchViewModel.SelectedRadius.Id;
                //}
            }
            else
            {
                request.Radius = BBOSMobile.ServiceModels.Common.Enumerations.Radius.Any;
            }

            //And add all the dropdown/enum filters to the reuqest

			if (contactSearchViewModel.SelectedIndustry != null) {
				if (contactSearchViewModel.SelectedIndustry.Id != -1) {
					request.IndustryType = (BBOSMobile.ServiceModels.Common.Enumerations.IndustryType)contactSearchViewModel.SelectedIndustry.Id;
				}
			}

		}

		private async void GetContacts()
		{
			try {

               Debug.WriteLine("Try to get conntacts");

				activityLayout.IsVisible = true;
				activityIndicator.IsVisible = true;
				activityIndicator.IsRunning = true;

				var serviceClient = new ContactWebserviceClient ();

				PrepareRequest ();

				//Get our search response back
				var response = await serviceClient.GetContacts (request);
				if (response != null) {
                    Debug.WriteLine("response is not null");
                    if (response.ResponseStatus == BBOSMobile.ServiceModels.Common.Enumerations.ResponseStatus.InvalidUserId) 
					{
						Navigation.PushAsync(new LoginPage ());
					}
				}

                Debug.WriteLine("after the call to GetContacts");

                //Make sure we have results
                if (response == null) 
				{

                    Debug.WriteLine("response == null");

                    activityIndicator.IsVisible = false;
					activityIndicator.IsRunning = false;
					return;
				}
                
				if (response.Contacts == null || response.ResultCount == 0) 
				{
                    Debug.WriteLine("response.Contacts is null");

                    activityIndicator.IsVisible = false;
                    activityIndicator.IsRunning = false;
                    noRecordsFound.IsVisible = true;

                    return;
				}
                
				if (contactListViewModel == null) 
				{
                    Debug.WriteLine("contactListViewModel is null");
                    contactListViewModel = new ContactListViewModel ();
					contactListViewModel.Contacts= new ObservableCollection<ContactListItemViewModel> ();
				}
				if (request == null) {
					request = new ContactSearchRequest ();
					request.PageIndex = 0;
					request.PageSize = 20;
				}
				bool contactReturned = false;
                result_count_label.Text = response.ResultCount.ToString();
                foreach (var contact in response.Contacts) {
                    Debug.WriteLine("looping thru response.Contacts");

                    var contactListItem = new ContactListItemViewModel ();
                    contactListItem.ContactID = contact.ContactID;
					contactListItem.BBID = contact.BBID;
					contactListItem.Name = contact.Name;
					contactListItem.Location = contact.Location;
                    contactListItem.CompanyName = contact.CompanyName;

					contactListItem.Index = contact.Index + (request.PageSize * (request.PageIndex));

					contactListViewModel.Contacts.Add (contactListItem);
					contactReturned = true;
				}
				if (response.ResultCount > 0) {
                    Debug.WriteLine("ResultCount > 0");
                    noRecordsFound.IsVisible = false;
					request.PageIndex += 1;
					if (contactListContentView == null) {
						contactListContentView = new ContactListContentView (contactListViewModel);

						contactListContentView.ListViewContact.ItemAppearing += (Object listView, ItemVisibilityEventArgs e) => {
							OnItemAppearing ((ListView)listView, e);
						};

						//Add the companies to our layout
						mainLayout.Children.Clear();

                        if (Device.OS == TargetPlatform.Android) mainLayout.Children.Add(new Label { Text = "Results: " + response.ResultCount });
                       
                        mainLayout.Children.Add(contactListContentView);
					}
				}
				else{
					if (contactListContentView == null)
                        Debug.WriteLine("no results");

                        noRecordsFound.IsVisible = true;
				}
					
				activityLayout.IsVisible = false;
				activityIndicator.IsVisible = false;
				activityIndicator.IsRunning = false;

			}  catch(Exception ex) {
				DisplayErrorLoadingAlert ();
			}
		}

		private void OnItemAppearing(ListView listView, ItemVisibilityEventArgs e)
		{
			if (contactListViewModel.Contacts.Count == 0) {
				activityIndicator.IsVisible = false;
				activityIndicator.IsRunning = false;
				return;
			}	

			//hit bottom!
			if (contactListViewModel.Contacts.Count > 10) {
				if(((ContactListItemViewModel)e.Item).Index == contactListViewModel.Contacts.Count - 1)
				{
					GetContacts();
				}
			}
		}
	}
}

