using System;
using System.Collections.Generic;
using Xamarin.Forms;
using BBOSMobile.Core.Interfaces;
using BBOSMobile.Core.Models;
using BBOSMobile.ServiceModels.Common;
using BBOSMobile.Forms.Pages;
using BBOSMobile.Forms.Common;
using System.Text.RegularExpressions;
using System.Diagnostics;

namespace BBOSMobile.Forms
{
	public partial class CompanyContactListContentView : ContentView
	{
		private int _bbid;
		private CompanyPage _parent;

		//public CompanyContactListContentView (CompanyViewModel viewModel)
		public CompanyContactListContentView (IEnumerable<Contact> Contacts, int bbid, CompanyPage parent)
		{
			_bbid = bbid;
			_parent = parent;
			InitializeComponent ();
			BindingContext = Contacts;
			//ITrackerService service = App.TrackerService;
			//service.TrackScreen ("Company Contact List");
		}
		public void PhoneButtonClick (object sender, EventArgs e) {

			var sl = (StackLayout)(sender);
			var t = (Contact)(sl.BindingContext);


			var phoneNumber = t.Phone;
//			if (phoneNumber.Contains("Company:")){
//				phoneNumber = phoneNumber.Replace ("Company:", "").Trim();
//			}
//			if (phoneNumber.Contains("Cell:")){
//				phoneNumber = phoneNumber.Replace ("Cell:", "").Trim();
//			}
			phoneNumber = Regex.Replace(phoneNumber, "[^0-9]", "");

			if (!string.IsNullOrEmpty (phoneNumber)) 
			{
				var formattedNumber = phoneNumber.Replace ("-", string.Empty).Replace (" ", string.Empty).Trim ();

				DependencyService.Get<IPhoneCallService>().MakeCall (formattedNumber);
			}
		}
		void EmailButtonClick(object sender, EventArgs e)
		{
			var sl = (StackLayout)(sender);
			var t = (Contact)(sl.BindingContext);
			var emailAddress = t.Email;
			if (!string.IsNullOrEmpty (emailAddress)) {
				IEmailService service = DependencyService.Get<IEmailService> ();
				if (service.CanSendEmail ()) {
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
		public void OnListItemTapped(object sender, ItemTappedEventArgs e)
		{

			// de-select the row
			((ListView)sender).SelectedItem = null; 

		}
		public void NotesButtonClick(object sender, EventArgs e)
		{
			var sl = (StackLayout)(sender);
			var t = (Contact)(sl.BindingContext);
			//Navigation.PushAsync(new ContactNotesPage (t));
			CompanyPage.ShouldKeepContent = true;
		
			var notesPage = new ContactNotesPage (t, _bbid, _parent );
			var page = Utils.GetNavigationPage (notesPage);
			Navigation.PushModalAsync (page, true);


			//Navigation.PushModalAsync (new ContactNotesPage (t, _bbid, _parent ));
		}

        public void OnAddToContactsMenuClick(object sender, EventArgs e)
        {

            var mi = ((Xamarin.Forms.MenuItem)sender);
            var t = (Contact)(mi.BindingContext);

            var company_name = ((CompanyViewModel)_parent.BindingContext).Company.Name;

            var title = t.Title;
            if (string.IsNullOrEmpty(title))
            {
                title = "";
            }


            Debug.WriteLine("*****company_name" + company_name);

            if (string.IsNullOrEmpty(company_name))
            {
                company_name = "";
            }


            var email = t.Email;
            if (string.IsNullOrEmpty(email))
            {
                email = "";
            }


            var first_name = t.FirstName;
            if (string.IsNullOrEmpty(first_name))
            {
                first_name = "";
            }

            var last_name = t.LastName;
            if (string.IsNullOrEmpty(last_name))
            {
                last_name = "";
            }

            var company_phone_number = t.CompanyPhone;
            var phoneNumber = t.Phone;

            if (!string.IsNullOrEmpty(company_phone_number))
            {
                    //do nothing
            }

            else if (string.IsNullOrEmpty(company_phone_number) && (!string.IsNullOrEmpty(phoneNumber)))
            {
                if (phoneNumber.Contains("Company:"))
                {
                    phoneNumber = phoneNumber.Replace("Company:", "").Trim();
                }
                else if (phoneNumber.Contains("Cell:"))
                {
                    phoneNumber = phoneNumber.Replace("Cell:", "").Trim();
                }
                if (!string.IsNullOrEmpty(phoneNumber))
                {
                    phoneNumber = phoneNumber.Replace("-", string.Empty).Replace(" ", string.Empty).Trim();
                }

                company_phone_number = phoneNumber;

            }


            var contact_info_set = new String[] { first_name, last_name, email, company_phone_number, company_name,title };


            Debug.WriteLine("*****before calling the IOS service" + company_name);

            DependencyService.Get<IContactsService>().CreateContact(contact_info_set);





        }

        public void OnPhoneMenuClick (object sender, EventArgs e) {

			var mi = ((Xamarin.Forms.MenuItem)sender);
			var t = (Contact)(mi.BindingContext);
			var phoneNumber = t.Phone;
			if (phoneNumber.Contains("Company:")){
				phoneNumber = phoneNumber.Replace ("Company:", "").Trim();
			}
			if (!string.IsNullOrEmpty (phoneNumber)) 
			{
				var formattedNumber = phoneNumber.Replace ("-", string.Empty).Replace (" ", string.Empty).Trim ();

				DependencyService.Get<IPhoneCallService>().MakeCall (formattedNumber);
			}

		}
		public void OnEmailMenuClick (object sender, EventArgs e) {
			var mi = ((Xamarin.Forms.MenuItem)sender);
			var t = (Contact)(mi.BindingContext);
			var emailAddress = t.Email;
			if (!string.IsNullOrEmpty (emailAddress)) {
				IEmailService service = DependencyService.Get<IEmailService> ();
				Email email = new Email ();
				email.ToAddresses = new List<string> (){ emailAddress };
				email.Subject = "";
				email.Body = "";
				service.CreateEmail (email);
			}

		}


	}
}

