using System;
using System.Collections.Generic;
using Xamarin.Forms;
using BBOSMobile.ServiceModels.Common;
using BBOSMobile.Core;
using BBOSMobile.Forms.Custom;
using BBOSMobile.Core.Interfaces;
using System.Linq;

namespace BBOSMobile.Forms.Pages
{
	public partial class ContactPage : BaseContentPage
	{
		private ContactViewModel viewModel = new ContactViewModel();
		private ContactSummaryListContentView summaryView;
/*
		private ContactClassificationListContentView classificationView;
		private ContactCommodityListContentView commodityView;
		private ContactProductListContentView productView;
		private ContactSpecieListContentView specieView;
		private ContactServiceListContentView serviceView;
		private ContactContactListContentView contactsView;
        */
		private ActivityIndicator activityView;



		private int _contactID;
        private int _BBID;

		private bool _loaded = false;
		private WebView webView = new WebView();
		private Label label = new Label();
		private string section = "";
		public static bool ShouldKeepContent;

		public ContactPage (int contactID, int BBID)
		{
			IsBusy = true;
			InitializeComponent ();
            _contactID = contactID;
            _BBID = BBID;

            


			//ITrackerService service = App.TrackerService;
			//service.TrackScreen ("Contact");

			IsBusy = false;
			if (activityView != null){
				mainLayout.Children.Remove(activityView);
			}

		}
		private async void Setup()
		{
			try {
				IsBusy = true;


				var serviceClient = new ContactWebserviceClient ();
				var response = await serviceClient.GetContact(_contactID, _BBID);
				if (response != null) {
					if (response.ResponseStatus == BBOSMobile.ServiceModels.Common.Enumerations.ResponseStatus.InvalidUserId) 
					{
						ContactPage.ShouldKeepContent = true;
						Navigation.PushAsync(new LoginPage());
					}

				}

				if (response.Contact == null) {
					activityIndicator.IsRunning = false;
					DisplayErrorLoadingAlert ();
					return;
				}
				if (response.ResponseStatus != Enumerations.ResponseStatus.Failure) {
					CreateContactViewModel(response.Contact);
					BindingContext = viewModel;
					var x = 1;
					summaryView = new ContactSummaryListContentView(viewModel);
					mainLayout.Children.Add(summaryView);
					this.Title = "Summary";

					//Button setup
					//NotesButton.IsVisible = viewModel.Contact.HasNotes;
					activityIndicator.IsRunning = false;
					loadLayout.IsVisible = false;
					mainLayout.IsVisible = true;
					_loaded = true;

                    //SecurityResult = new SecurityResult { Visible=true; IsEnabled = false;}
                    //security
                    //btnNotes.IsVisible = viewModel.NotesSecurity.Visible;
                    //btnNotes.IsEnabled = viewModel.NotesSecurity.Enabled;



                    //				if (App.RecentViewsSecurity.Enabled) {
                    //					var page = new WatchDogGroupsPage ();
                    //					App.RootPage.NavigateToPage (page);
                    //				} else {
                    //					DisplayAlert (Common.Constants.AlertTitle, Common.Constants.InvalidPermissionAlertMessage, Common.Constants.AlertOk);
                    //				}


                    var BBID_tap = new TapGestureRecognizer();
                    BBID_tap.Tapped += async (s, e) =>
                    {
                        //IsBusy = true;
                        var companyDetailPage = new CompanyPage(viewModel.Contact.BBID);


                        WatchdogDetailPage.ShouldKeepContent = true;
                        CompanySearchResults.ShouldKeepContent = true;
                        CompanySearch.ShouldKeepContent = true;
                        RecentViews.ShouldKeepContent = true;
                        await Navigation.PushAsync(companyDetailPage);
                        //IsBusy = false;
                    };
                    this.FindByName<Label>("clickable_BBID").GestureRecognizers.Add(BBID_tap);



                    IsBusy = false;
				}
			}  catch(Exception ex) {
				DisplayErrorLoadingAlert ();
			}
		}
			
		protected override void OnAppearing ()
		{
			IsBusy = true;
			if (activityView != null){
				mainLayout.Children.Remove(activityView);
			}
			ContactPage.ShouldKeepContent = false;

			base.OnAppearing ();
			if (!_loaded) {
				Setup ();
			}
			if (viewModel.Contact != null && viewModel.Contact.HasNotes) {
				//notesCountLabel.IsVisible = true;
			}
			IsBusy = false;

		}

		protected override void OnDisappearing ()
		{
			if (ShouldClearContent(ContactPage.ShouldKeepContent)) 
			{
				//viewModel = null;
			} 
		}
		protected override bool OnBackButtonPressed()
		{
			if (!IsBusy) {
				Navigation.PopAsync();
				return true;
			}
			return false;

		}




		public void PhoneButtonClick (object sender, EventArgs e) {
			if (!IsBusy) {
				var phoneNumber = viewModel.Contact.CompanyPhone;

				if (!string.IsNullOrEmpty (phoneNumber)) 
				{
					var formattedNumber = phoneNumber.Replace ("-", string.Empty).Replace (" ", string.Empty).Trim ();

					DependencyService.Get<IPhoneCallService>().MakeCall (formattedNumber);
				}
			}

		}

		public void MeisterMediaButtonClick (object sender, EventArgs e) {
			if (!IsBusy) {
				Device.OpenUri(new Uri("https://www.meistermedia.com"));
			}

		}
			
		public void MapButtonClick (object sender, EventArgs e) 
		{
			//TODO: Need Address 1 and Address 2
			if (!IsBusy) {
				IsBusy = true;
				string address = System.Net.WebUtility.UrlEncode(viewModel.Contact.Location);
				if (Device.OS == TargetPlatform.iOS) {
					Device.OpenUri (new Uri ("http://maps.apple.com/?q=" + address));
				} else if (Device.OS == TargetPlatform.Android) {
					Device.OpenUri (new Uri ("geo:0,0?q=" + address));
				}
				IsBusy = false;
			}

		}


//		async void AddWatchDogButtonClick (object sender, EventArgs e) 
//		{
//			
//		}
			



		private void CreateContactViewModel(Contact contact){
			var userCredentials = DependencyService.Get<IUserCredentialsService> ().GetUserCredentials();

				
			viewModel.Contact = contact;
			viewModel.SecurityPrivileges = userCredentials.SecurityPrivileges;
			//Need to build sectionListItems for user type
/*
			viewModel.SectionItems = new List<ContactSectionListItemViewModel> ();
			AddSectionItem ("Summary");
			if (viewModel.ContactDetailsListingPage.Visible) {
				AddSectionItem ("Listing");
			}

			if (userCredentials.UserLevel == Enumerations.UserLevel.Advanced || userCredentials.UserLevel == Enumerations.UserLevel.Premium) {
				//level 3 security
				if (viewModel.ContactDetailsContactsPage.Visible) {
					AddSectionItem ("Contacts");
				}
			}
			AddSectionItem ("Classifications");
			if (userCredentials.UserType == BBOSMobile.ServiceModels.Common.Enumerations.UserType.Produce){
				//produce only
				if (contact.Industry == "Produce") {
					AddSectionItem ("Commodities");
				}
			}
			if (userCredentials.UserType == BBOSMobile.ServiceModels.Common.Enumerations.UserType.Lumber)
			{
				//lumber only
				AddSectionItem ("Species");
				AddSectionItem ("Products");
				AddSectionItem ("Services");
			}
*/
			//Need to build SummaryListItems for user type
			viewModel.SummaryItems = new List<ContactSummaryListItemViewModel> ();

                AddSummaryItem("Title:", contact.Title, false, "");
                AddSummaryItem("Email:", contact.Email, true, "EMAIL");

                AddSummaryItem("Cell:", contact.CellPhone, true, "PHONE");
                AddSummaryItem("Direct:", contact.DirectPhone, true, "PHONE");

			


		}
		private void AddSummaryItem(string labelName, string value, bool action, string actionURL, string image = "",  string socialUrl = null){
			viewModel.SummaryItems.Add(new ContactSummaryListItemViewModel() {LabelName = labelName, Value = value, Action=action, ActionURL=actionURL, Image = image, SocialURL = socialUrl});
//			if (!string.IsNullOrEmpty (value)) {
//				viewModel.SummaryItems.Add(new ContactSummaryListItemViewModel() {LabelName = labelName, Value = value, Action=action, ActionURL=actionURL});
//			}
		}
	}
}

