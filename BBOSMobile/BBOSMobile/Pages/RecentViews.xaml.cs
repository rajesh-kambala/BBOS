using System;
using System.Collections.Generic;

using Xamarin.Forms;
using BBOSMobile.Forms.Custom;
using BBOSMobile.Core;
using System.Collections.ObjectModel;
using BBOSMobile.ServiceModels.Common;
using BBOSMobile.Core.Interfaces;

namespace BBOSMobile.Forms.Pages
{
	public partial class RecentViews : BaseContentPage
	{
		CompanyListViewModel viewModel = new CompanyListViewModel();
        ContactListViewModel viewModelContact = new ContactListViewModel();

		CompanyListContentView companyList;
        ContactListContentView contactList;

        Label labelCompanySection  = new Label { Text = "Companies" };

        Label labelPersonSection = new Label { Text = "Persons" };



        public static bool ShouldKeepContent;
		private bool isPageBusy;
	
		public RecentViews ()
		{


            InitializeComponent();
			BindingContext = viewModel;
			Title = "Recent Views";
			isPageBusy = true;
			var tapGestureRecognizerWD = new TapGestureRecognizer();
			tapGestureRecognizerWD.Tapped += (s, e) => {
				// handle the tap
				if (!isPageBusy){
					if ((App.WatchdogListsPage.HasPrivilege) || (App.WatchdogListsPage.Enabled)) {
						var page = new WatchDogGroupsPage ();
						App.RootPage.NavigateToPage (page);
					}
					else{
						DisplayAlert (Common.Constants.AlertTitle, Common.Constants.InvalidPermissionAlertMessage, Common.Constants.AlertOk);
					}
				}

			};

			WDSL.GestureRecognizers.Add(tapGestureRecognizerWD);
			if (!App.RecentViewsSecurity.HasPrivilege && !App.RecentViewsSecurity.Enabled) {
				RVSL.Opacity = .5;
			}
			if (!App.WatchdogListsPage.HasPrivilege && !App.WatchdogListsPage.Enabled) {
				WDSL.Opacity = .5;
			}
			var tapGestureRecognizerCS = new TapGestureRecognizer();
			tapGestureRecognizerCS.Tapped += (s, e) => {
				// handle the tap
				if(!isPageBusy){
					var page = new CompanySearch ();
					App.RootPage.NavigateToPage (page);
				}
			};
			CSSL.GestureRecognizers.Add(tapGestureRecognizerCS);

			var tapGestureRecognizerQF = new TapGestureRecognizer();
			tapGestureRecognizerQF.Tapped += (s, e) => {
				// handle the tap
				if(!isPageBusy){
					var page = new QuickFind ();
					App.RootPage.NavigateToPage (page);
				}
			};
			QFSL.GestureRecognizers.Add(tapGestureRecognizerQF);

            var tapGestureRecognizerPS = new TapGestureRecognizer();
            tapGestureRecognizerPS.Tapped += (s, e) => {
                // handle the tap
                var page = new ContactSearch();
                App.RootPage.NavigateToPage(page);
            };
            PSSL.GestureRecognizers.Add(tapGestureRecognizerPS);

   //         ITrackerService service = App.TrackerService;
			//service.TrackScreen ("Ratings Page");
			isPageBusy = false;
		}

		protected override bool OnBackButtonPressed()
		{
			var page = new Dashboard ();
			App.RootPage.NavigateToPage (page);
			return true;
		}
		protected override void OnAppearing ()
		{
			
			RecentViews.ShouldKeepContent = false;
			base.OnAppearing ();
			//if (!_loaded) {
			Setup ();

		}
		protected override void OnDisappearing ()
		{
			if (ShouldClearContent(RecentViews.ShouldKeepContent)) 
			{
				//viewModel = null;
			} 
		}

		private async void Setup(){
			isPageBusy = true;
			if (viewModel == null)
				viewModel = new CompanyListViewModel ();

            if (viewModelContact == null)
                viewModelContact = new ContactListViewModel();


            var companies = new ObservableCollection<CompanyListItemViewModel> ();
            var contacts = new ObservableCollection<ContactListItemViewModel>();


            try
            {
				var serviceClient = new CompanyWebserviceClient ();

				var response = await serviceClient.GetRecentlyViewedCompanies();

				if (response.ResponseStatus == BBOSMobile.ServiceModels.Common.Enumerations.ResponseStatus.InvalidUserId) {
					await Navigation.PushAsync (new LoginPage ());
					return;

				} 

				if (response.ResponseStatus != Enumerations.ResponseStatus.Failure) 
				{
					foreach(var company in response.Companies)
					{
						var companyListItem = new CompanyListItemViewModel ();
						companyListItem.BBID = company.BBID;
						companyListItem.Name = company.Name;
						companyListItem.Location = company.Location;
						companyListItem.Rating = company.Rating;
						companyListItem.IndustryAndType = string.Format ("{0} {1}", company.Industry, company.Type);
						companyListItem.HasNotes = company.HasNotes;
						companyListItem.Phone = company.Phone;

						companies.Add (companyListItem);
					}

					if (viewModel == null)
						viewModel = new CompanyListViewModel ();

					viewModel.Companies = companies;

					if (companyList != null) {

                        mainLayout.Children.Remove(labelCompanySection);
                        mainLayout.Children.Remove (companyList);
					}


                    //FormattedString fsCompany = new FormattedString();
                    //fsCompany.Spans.Add(new Span { Text = "Companies", ForegroundColor = Color.White, BackgroundColor = Color.Blue });
                    //labelCompanySection.FormattedText = fsCompany;

                    mainLayout.Children.Add(labelCompanySection);
                    

                    companyList = new CompanyListContentView (viewModel,true);
					mainLayout.Children.Add (companyList);



                    //get the contacts from the companies controller response
                    foreach (var contact in response.Contacts)
                    {
                        var contactListItem = new ContactListItemViewModel();

                        contactListItem.BBID = contact.BBID;
                        contactListItem.CompanyName = contact.CompanyName;
                        contactListItem.Location = contact.Location;
                        contactListItem.ContactDisplay = contact.ContactDisplay;
                        contactListItem.Title = contact.Title;
                        contactListItem.Name = contact.Name;
                        contactListItem.ContactID = contact.ContactID;


                        contacts.Add(contactListItem);
                    }

                    if (viewModelContact == null)
                        viewModelContact = new ContactListViewModel();

                    viewModelContact.Contacts = contacts;

                    if (contactList != null)
                    {
                        mainLayout.Children.Remove(labelPersonSection);
                        mainLayout.Children.Remove(contactList);
                    }

                    mainLayout.Children.Add(labelPersonSection);
                    contactList = new ContactListContentView(viewModelContact);
                    mainLayout.Children.Add(contactList);




                }
			} catch(Exception ex) {
				DisplayErrorLoadingAlert ();
                
			}






			loadLayout.IsVisible = false;
			mainLayout.IsVisible = true;
			isPageBusy = false;
		}
	}
}

