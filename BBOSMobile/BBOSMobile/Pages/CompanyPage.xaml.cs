using System;
using System.Collections.Generic;
using Xamarin.Forms;
using BBOSMobile.ServiceModels.Common;
using BBOSMobile.Core;
using BBOSMobile.Forms.Custom;
using BBOSMobile.Core.Interfaces;
using System.Linq;
using BBOSMobile.Core.Models;
using System.Diagnostics;
using BBOSMobile.ServiceModels.Requests;
using BBOSMobile.Core.WebServices;
using Xamarin.Forms.Internals;
using BBOSMobile.ServiceModels.Responses;
using Newtonsoft.Json;
using System.Threading;

namespace BBOSMobile.Forms.Pages
{
	public partial class CompanyPage : BaseContentPage
	{
		private CompanyViewModel viewModel = new CompanyViewModel();
		private CompanySummaryListContentView summaryView;
		private CompanyClassificationListContentView classificationView;
		private CompanyCommodityListContentView commodityView;
		private CompanyProductListContentView productView;
		private CompanySpecieListContentView specieView;
		private CompanyServiceListContentView serviceView;
		private CompanyContactListContentView contactsView;
		private ActivityIndicator activityView;



		private int _bbid;
		private bool _loaded = false;
		private bool _addGestures = true;
		private WebView webView = new WebView();
		private Label label = new Label();
		private string section = "";
		public static bool ShouldKeepContent;
		private static bool _contactsAreDisplayed = false;
		private string os_info = "not set";
		private string app_version = "not set";
		private string user_id = "not set";
		private string user_type = "not set";
		private string user_email = "not set";

		private List<string> log_array;

		private UserCredentials userCredentials;

		public CompanyPage (int BBID)
		{
			IsBusy = true;
			InitializeComponent ();
			_bbid = BBID;

			//ITrackerService service = App.TrackerService;
			//service.TrackScreen ("Company");

			IsBusy = false;
			if (activityView != null){
				mainLayout.Children.Remove(activityView);
			}

			IDeviceInfoService deviceInfo = DependencyService.Get<IDeviceInfoService>();
			deviceInfo.LoadInfo();
			os_info = " " + deviceInfo.PhonePlatform + " (" + deviceInfo.PhoneOS + ")";
			app_version = " " + deviceInfo.AppVersion;
			var userCredentials = DependencyService.Get<IUserCredentialsService>().GetUserCredentials();
			user_id = userCredentials.UserId.ToString();
			user_type = userCredentials.UserType.ToString();
			user_email = userCredentials.Email;
			log_array = new List<string>();


		}
		private async void Setup(bool ContactsAreDisplayed)
		{
			try {


				log_array.Add("Company Page start of Setup()");


				IsBusy = true;
				btnRateCompany.IsEnabled = false;
				IsBusy = true;

				activityView = new ActivityIndicator();
				activityView.IsRunning = true;
				activityView.IsVisible = true;
				mainLayout.Children.Add(activityView);
				sectionLayout.Children.Clear();


				////////////////////////
				///

				//var logserviceClient = new UserWebserviceClient();
				//var LogDetails = new LogExceptionDetailsRequest();
				//LogDetails.StackTrace = "testing logger";
				//LogDetails.OSVersion = "dummy os version";
				//LogDetails.ScreenName = "Company Page start of setup methodr";

				//var userCredentials = DependencyService.Get<IUserCredentialsService>().GetUserCredentials();
				//var userId = userCredentials.UserId;

				//LogDetails.UserId = userId;


				//var LogResponse = await logserviceClient.LogException(LogDetails);
				//Debug.WriteLine("@@@@logResponse error message:" + LogResponse.ErrorMessage);
				//Debug.WriteLine("@@@@logResponse response status string:" + LogResponse.ResponseStatus.ToString());


				/////////////////////





				var serviceClient = new CompanyWebserviceClient ();
				var response = await serviceClient.GetCompany(_bbid);


				log_array.Add("Company Page showing results of company service response");


				if (response != null) {
					if (response.ResponseStatus == BBOSMobile.ServiceModels.Common.Enumerations.ResponseStatus.InvalidUserId) 
					{
						CompanyPage.ShouldKeepContent = true;
						Navigation.PushAsync(new LoginPage ());
					}

				}





				if (response.Company == null) {
					activityIndicator.IsRunning = false;
					DisplayErrorLoadingAlert ();

					log_array.Add("not an exception but response.Company is null");


					try
					{
						var logserviceClient = new UserWebserviceClient();
						var LogDetails = new LogExceptionDetailsRequest();
						LogDetails.ScreenName = "Company Page response.Company is null";
						LogDetails.StackTrace = "not a true exception";
						LogDetails.ExceptionMessage = "not a true exception";
						LogDetails.OSVersion = os_info;
						LogDetails.AppVersion = app_version;
						LogDetails.UserID = user_id;
						LogDetails.AdditionalInfo = user_email + ":user is trying to retrieve bbid:" + _bbid;
						LogDetails.AppIndustryType = user_type;
						//var userCredentials = DependencyService.Get<IUserCredentialsService>().GetUserCredentials();
						//var userId = userCredentials.UserId;

						//LogDetails.UserId = userId;


						//var LogResponse = await logserviceClient.LogException(LogDetails);
						//Debug.WriteLine("@@@@logResponse error message:" + LogResponse.ErrorMessage);
						//Debug.WriteLine("@@@@logResponse response status string:" + LogResponse.ResponseStatus.ToString());
					}
					catch (Exception ex3)
					{
						//silent error
					}




					return;
				}


				if (response.ResponseStatus != Enumerations.ResponseStatus.Failure) {
					CreateCompanyViewModel(response.Company);
					BindingContext = viewModel;
					var x = 1;
					foreach (var item in viewModel.SectionItems) 
					{
						if (x > 1) {
							var label = new Label (){ Text = " | ", FontAttributes = FontAttributes.Bold};
							label.TextColor = Color.White;
							label.VerticalOptions = LayoutOptions.Center;
							label.FontSize = 15;
							sectionLayout.Children.Add (label);
						}
						var button = new Button (){ Text = item.DisplayName };
						button.Clicked += SectionButtonClicked;
						button.BackgroundColor = Color.FromHex("#1e90ff");
						button.TextColor = Color.White;
						sectionLayout.Children.Add (button);
						x++;
					}

					if (section != null && section == "Contacts")
					{

					}
					else
					{
						summaryView = new CompanySummaryListContentView(viewModel);
						mainLayout.Children.Add(summaryView);
						this.Title = "Summary";
					}

					if (ContactsAreDisplayed)
					{

						Debug.WriteLine("@@@@contacts are displayed in company page setup");


						log_array.Add("Company Page ContactsAreDisplayed --  not an error -- next step should be is GetCompanyContacts(bbid)");

						ClearSections();

						if (contactsView != null)
						{
							mainLayout.Children.Remove(contactsView);
						}

						var _serviceClient = new CompanyWebserviceClient();
						var _response = await serviceClient.GetCompanyContacts(_bbid);

						contactsView = new CompanyContactListContentView(_response.Contacts, _bbid, this);
						mainLayout.Children.Add(contactsView);



						log_array.Add("Company Page ContactsAreDisplayed --  debugging -- contacts returned");


					}


					//Button setup
					//NotesButton.IsVisible = viewModel.Company.HasNotes;
					activityIndicator.IsRunning = false;
					loadLayout.IsVisible = false;
					mainLayout.IsVisible = true;
					_loaded = true;



					//SecurityResult = new SecurityResult { Visible=true; IsEnabled = false;}
					//security
					//btnNotes.IsVisible = viewModel.NotesSecurity.Visible;
					//btnNotes.IsEnabled = viewModel.NotesSecurity.Enabled;

					if (viewModel.Company.HasNotes && viewModel.NotesSecurity.Visible) {
						notesCountLabel.IsVisible = true;
					} else {
						notesCountLabel.IsVisible = false;
					}

					//Adding isLocalSource check
					if (viewModel.Company.IsLocalSource) {
						MeisterLayout.IsVisible = viewModel.Company.IsLocalSource;
					}
					//End of isLocalSource






					//				if (App.RecentViewsSecurity.Enabled) {
					//					var page = new WatchDogGroupsPage ();
					//					App.RootPage.NavigateToPage (page);
					//				} else {
					//					DisplayAlert (Common.Constants.AlertTitle, Common.Constants.InvalidPermissionAlertMessage, Common.Constants.AlertOk);
					//				}

					//adding gestures

					if (viewModel.Company.IsWatchDog)

					{
						Debug.WriteLine("@@@setting image source for WD exists");
						//watchdog_indicator = new Image { Source = "company_btn_WD_exists.png" };
						watchdog_indicator.Source = ImageSource.FromFile("company_btn_WD_exists.png");
					}
					else
					{
						Debug.WriteLine("@@@setting image source for WD not exists");
						//watchdog_indicator = new Image { Source = "company_btn_WD_exists.png" };
						watchdog_indicator.Source = ImageSource.FromFile("company_btn_WD.png");
					}


					if (viewModel.NotesSecurity.HasPrivilege && viewModel.NotesSecurity.Visible)
					{
						NotesSL.IsVisible = true;
					}
					else
					{
						NotesSL.Opacity = .5;
					}

					if (viewModel.WatchdogListAdd.HasPrivilege && viewModel.WatchdogListAdd.Visible)
					{
						//always visible
					}
					else
					{
						AWSL.Opacity = .5;
					}


					Debug.WriteLine("in companypage --viewModel.Company.BBID:" + viewModel.Company.BBID);
					Debug.WriteLine("in companypage --App.UserRelatedBBIDsD:" + App.UserRelatedBBIDs.First().ToString());
					



					if (viewModel.Company.Industry.ToUpper() != "LUMBER" && viewModel.Company.Industry.ToUpper() != "SUPPLY AND SERVICE" 
						&& userCredentials.UserType != Enumerations.UserType.Lumber && !App.UserRelatedBBIDs.Contains(viewModel.Company.BBID))
					{
						btnRateCompany.IsEnabled = true;
						btnRateCompany.IsVisible = true;
					}
					IsBusy = false;
					if (activityView != null)
					{
						mainLayout.Children.Remove(activityView);
					}
				}
			}  catch(Exception ex) {

				Debug.WriteLine("@@@@exception in companypage:" + ex.ToString());


				DisplayErrorLoadingAlert ();



				log_array.Add("Exception in Company Page at end of setup of Contacts");

				try { 
				var logserviceClient = new UserWebserviceClient();
				var LogDetails = new LogExceptionDetailsRequest();
				LogDetails.ScreenName = "Exception at Company Page at end of setup for contacts";
				LogDetails.StackTrace = ex.StackTrace;
				LogDetails.ExceptionMessage = ex.Message;
					LogDetails.OSVersion = os_info;
					LogDetails.AppVersion = app_version;
					LogDetails.UserID = user_id;
					LogDetails.AdditionalInfo = user_email + ":" + JsonConvert.SerializeObject(log_array);
					LogDetails.AppIndustryType = user_type;


					//var userCredentials = DependencyService.Get<IUserCredentialsService>().GetUserCredentials();
					//var userId = userCredentials.UserId;

					//LogDetails.UserId = userId;


				//	var LogResponse = await logserviceClient.LogException(LogDetails);
				//Debug.WriteLine("@@@@logResponse error message:" + LogResponse.ErrorMessage);
				//Debug.WriteLine("@@@@logResponse response status string:" + LogResponse.ResponseStatus.ToString());
				}
				catch (Exception ex2)
				{
					//silent error
				}
			}
		}
		private void AddGestures()
		{
			var tapGestureRecognizerNote = new TapGestureRecognizer();
			tapGestureRecognizerNote.Tapped += (s, e) => {
				// handle the tap
				if (viewModel.NotesSecurity.Enabled)
				{
					CompanyPage.ShouldKeepContent = false; //forceing to false to refresh button-enable logic
					var page = new CompanyNotesPage(_bbid, viewModel);
					Navigation.PushAsync(page, true);
				}
				else
				{
					DisplayAlert(Common.Constants.AlertTitle, Common.Constants.InvalidPermissionAlertMessage, Common.Constants.AlertOk);
				}
			};


			NotesSL.GestureRecognizers.Add(tapGestureRecognizerNote);


			var tapGestureRecognizerAW = new TapGestureRecognizer();
			tapGestureRecognizerAW.Tapped += (s, e) => {
				// handle the tap
				if (!IsBusy)
				{
					IsBusy = true;
					if (viewModel.WatchdogListAdd.Enabled)
					{
						CompanyPage.ShouldKeepContent = false;
						Debug.WriteLine("@@@pushing async Watchdog Page");
						Navigation.PushAsync(new WatchdogAddPage(_bbid));
					}
					else
					{
						DisplayAlert(Common.Constants.AlertTitle, Common.Constants.InvalidPermissionAlertMessage, Common.Constants.AlertOk);
					}
					IsBusy = false;
				}
			};

			AWSL.GestureRecognizers.Add(tapGestureRecognizerAW);
		}
			

		
		protected override async void OnAppearing ()
		{
			Debug.WriteLine("@@@OnAppearing");


			base.OnAppearing();
			IsBusy = true;
			if (activityView != null){
				mainLayout.Children.Remove(activityView);
			}

			CompanyPage.ShouldKeepContent = false;
			/*
			if (section == "Contacts") {
				loadClientContacts ();
			}
			*/

			if (!_loaded) {  //coming back from a popasync/onDisappearing -- like Watchdog screen 
				Debug.WriteLine("@@@@@@!_loaded");
				Setup (section == "Contacts");//was contacts showing at the time of disappearing ?
			}

			else if(section == "Contacts") //only coming back from a notes edit --no onDisappearing
				{
					loadClientContacts();
				}
			
			else
			{

				Debug.WriteLine("@@@@already loaded");
/*
				IsBusy = false;

				if (activityView != null)
				{
					Debug.WriteLine("@@@@removing indicator");
					IsBusy = false;
					mainLayout.Children.Remove(activityView);

				}
				*/
			}
			if (_addGestures)
			{
				AddGestures();
				_addGestures = false;

			}
			if (viewModel.Company != null && viewModel.Company.HasNotes) {
				notesCountLabel.IsVisible = true;
			}
			
			
			//IsBusy = false;
			/*
			if (activityView != null)
			{
				mainLayout.Children.Remove(activityView);
			}
			*/
		}

		protected override void OnDisappearing ()
		{
			Debug.WriteLine("@@@OnDisappearing");
			Debug.WriteLine("@@@onDisappearing Section is : " + section);

			if (contactsView != null)
			{
				Debug.WriteLine("@@@onDisappearing --- trying to remove contacts view");
				mainLayout.Children.Remove(contactsView);
			}
			mainLayout.ForceLayout();


			if (ShouldClearContent(CompanyPage.ShouldKeepContent)) 
			{

				Debug.WriteLine("@@@onDisappearing - clearing sections");

				ClearSections();
				viewModel = new CompanyViewModel();
				_loaded = false;
				_addGestures = false;
				

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
				var phoneNumber = viewModel.Company.Phone;

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
				string address = System.Net.WebUtility.UrlEncode(viewModel.Company.MapAddress);
				if (Device.OS == TargetPlatform.iOS) {
					Device.OpenUri (new Uri ("http://maps.apple.com/?q=" + address));
				} else if (Device.OS == TargetPlatform.Android) {
					Device.OpenUri (new Uri ("geo:0,0?q=" + address));
				}
				IsBusy = false;
			}

		}
		async void NoteButtonClick (object sender, EventArgs e) 
		{
			if (!IsBusy) {
				IsBusy = true;
				CompanyPage.ShouldKeepContent = false;  //false to force a refresh so buttons work correctly again
				
				await Navigation.PushAsync(new CompanyNotesPage (_bbid, viewModel));
				IsBusy = false;
			}
		}

//		async void AddWatchDogButtonClick (object sender, EventArgs e) 
//		{
//			
//		}
			private void OnBtnRateCompanyClicked(object sender, EventArgs e)
		{

			if (!IsBusy)
			{

				Debug.WriteLine("@@@@ PRESSED ON RATE COMPANY BUTTON");

				IsBusy = true;
				//SaveViewModel();
				CompanySearch.ShouldKeepContent = false;
				Navigation.PushAsync(new CompanySurvey(viewModel.Company));
				IsBusy = false;
			}


		}
		private void SectionButtonClicked(object sender, EventArgs e)
		{
			if (!IsBusy) {
				IsBusy = true;
				ClearSections ();
				Button button = (Button)sender;

				section = button.Text;
				//App.RootPage.DisplayAlert ("Alert", button.Text , "OK");
				// do stuff
				this.Title = section;
				if (section == "Listing") {
					if (viewModel.CompanyDetailsListingPage.Enabled) {
						var html2 = viewModel.Company.Listing;
						var html = @"<html>
							<head>
							<meta name=""format-detection"" content=""telephone=no"">
							</head>
							<body>";
						html += viewModel.Company.Listing;
						html += "</body></html>";
						HtmlWebViewSource source = new HtmlWebViewSource()
						{
							Html = html
						};
						webView.InputTransparent = false;
						webView.VerticalOptions = LayoutOptions.FillAndExpand;
						webView.HorizontalOptions = LayoutOptions.FillAndExpand;
						webView.Source = source;

						mainLayout.Children.Add (webView);
					}
				}
				else if (section == "Summary") {

					summaryView = new CompanySummaryListContentView (viewModel);
					mainLayout.Children.Add (summaryView);
				} 
				else if (section == "Classifications") {
					classificationView = new CompanyClassificationListContentView (viewModel);
					mainLayout.Children.Add (classificationView);
				} 
				else if (section == "Commodities") {
					commodityView = new CompanyCommodityListContentView (viewModel);
					mainLayout.Children.Add (commodityView);
				}
				else if (section == "Products") {
					productView = new CompanyProductListContentView (viewModel);
					mainLayout.Children.Add (productView);
				}
				else if (section == "Species") {
					specieView = new CompanySpecieListContentView (viewModel);
					mainLayout.Children.Add (specieView);
				}
				else if (section == "Services") {
					serviceView = new CompanyServiceListContentView (viewModel);
					mainLayout.Children.Add (serviceView);
				}
				else if (section == "Contacts") {
					if (viewModel.CompanyDetailsContactsPage.Enabled) {
						loadClientContacts ();
					}
				}

				else {
					label.Text = section;
					mainLayout.Children.Add (label);
				}
				IsBusy = false;
			}
		}
		public void reloadClientContacts(){
			loadClientContacts ();
		}
		private async void loadClientContacts(){

			try {


				ClearSections();

				if (contactsView != null)
				{
					mainLayout.Children.Remove(contactsView);
				}
				

				mainLayout.IsEnabled = false; 
				IsBusy = true;
				activityView = new ActivityIndicator();
				activityView.IsRunning = true;
				activityView.IsVisible = true;
				mainLayout.Children.Add (activityView);
				//ClearSections ();
				var serviceClient = new CompanyWebserviceClient ();
				var response = await serviceClient.GetCompanyContacts(_bbid);

				contactsView = new CompanyContactListContentView(response.Contacts, _bbid, this);
				
				mainLayout.Children.Add (contactsView);
				IsBusy = false;
				mainLayout.IsEnabled = true; 
				if (activityView != null){
					mainLayout.Children.Remove(activityView);
				
				}
			}  catch(Exception ex) {
				DisplayErrorLoadingAlert ();

				try { 
				var logserviceClient = new UserWebserviceClient();
				var LogDetails = new LogExceptionDetailsRequest();
				LogDetails.ScreenName = "Company Page error in loadClientContacts()";
					LogDetails.StackTrace = ex.StackTrace;
					LogDetails.ExceptionMessage = ex.Message;
					LogDetails.OSVersion = os_info;
					LogDetails.AppVersion = app_version;
					LogDetails.UserID = user_id;
					LogDetails.AdditionalInfo = user_email;
					LogDetails.AppIndustryType = user_type;
					//var userCredentials = DependencyService.Get<IUserCredentialsService>().GetUserCredentials();
					//var userId = userCredentials.UserId;

					//LogDetails.UserId = userId;


				//	var LogResponse = await logserviceClient.LogException(LogDetails);
				//Debug.WriteLine("@@@@logResponse error message:" + LogResponse.ErrorMessage);
				//Debug.WriteLine("@@@@logResponse response status string:" + LogResponse.ResponseStatus.ToString());
				}
				catch (Exception ex3)
				{
					//silent error
				}


			}
		}

		private void ClearSections(){
			//Make Generic Call for this
			if (webView != null) {
				mainLayout.Children.Remove (webView);
			}
			if (label != null) {
				mainLayout.Children.Remove (label);
			}
			if(summaryView != null)
			{
				mainLayout.Children.Remove (summaryView);
			}
			if(classificationView != null)
			{
				mainLayout.Children.Remove (classificationView);
			}
			if(commodityView != null)
			{
				mainLayout.Children.Remove (commodityView);
			}
			if (productView != null) 
			{
				mainLayout.Children.Remove (productView);
			}
			if (specieView != null) 
			{
				mainLayout.Children.Remove (specieView);
			}
			if (serviceView != null) 
			{
				mainLayout.Children.Remove (serviceView);
			}
			if (contactsView != null) 
			{
				mainLayout.Children.Remove (contactsView);
			}
		}

		
		private void CreateCompanyViewModel(Company company){
			userCredentials = DependencyService.Get<IUserCredentialsService> ().GetUserCredentials();

				
			viewModel.Company = company;
			viewModel.SecurityPrivileges = userCredentials.SecurityPrivileges;
			//Need to build sectionListItems for user type
			viewModel.SectionItems = new List<CompanySectionListItemViewModel> ();
			AddSectionItem ("Summary");
			if (viewModel.CompanyDetailsListingPage.Visible) {
				AddSectionItem ("Listing");
			}

			if (userCredentials.UserLevel == Enumerations.UserLevel.Advanced || userCredentials.UserLevel == Enumerations.UserLevel.Premium) {
				//level 3 security
				if (viewModel.CompanyDetailsContactsPage.Visible) {
					AddSectionItem ("Contacts");
				}
			}
			AddSectionItem ("Classifications");
			if (userCredentials.UserType == BBOSMobile.ServiceModels.Common.Enumerations.UserType.Produce){
				//produce only
				if (company.Industry == "Produce") {
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

			//Need to build SummaryListItems for user type
			viewModel.SummaryItems = new List<CompanySummaryListItemViewModel> ();
			if (userCredentials.UserType == BBOSMobile.ServiceModels.Common.Enumerations.UserType.Produce) {
				if (viewModel.ViewRating.HasPrivilege && viewModel.ViewRating.Visible) {
					AddSummaryItem ("Rating:", company.Rating, true, "RATING");
				}
				if (viewModel.ViewBBScore.HasPrivilege && viewModel.ViewBBScore.Visible) {
					AddSummaryItem ("Blue Book Score:", company.BlueBookScore, false, "");
				}
				AddSummaryItem ("Industry:", company.Industry, false, "");
				AddSummaryItem ("Type:", company.Type, false, "");
				AddSummaryItem ("Status:", company.Status, false, "");
				AddSummaryItem ("Call:", company.Phone, true, "PHONE");
				AddSummaryItem ("Fax:", company.Fax, false, "");
				AddSummaryItem ("Toll-Free:", company.TollFree, true, "PHONE");
				AddSummaryItem ("Email:", company.Email, true, "EMAIL");
				AddSummaryItem ("Web:", company.Web, true, "WEB");
			}
			if (userCredentials.UserType == BBOSMobile.ServiceModels.Common.Enumerations.UserType.Lumber) {
				if (viewModel.ViewRating.HasPrivilege && viewModel.ViewRating.Visible) {
					AddSummaryItem ("Credit Worth Rating:", company.CreditWorthRating, true, "RATING");
					AddSummaryItem ("Rating Key Numerals:", company.RatingKeyNumbers, true, "RATING");
					AddSummaryItem ("Pay Indicator:", company.PayIndicator, true, "RATING");
				}
				AddSummaryItem ("Current Pay Reports:", company.CurrentPayReports.ToString(), false, "");
                //AddSummaryItem ("Blue Book Score:", company.BlueBookScore, false, "");
                if (viewModel.ViewBBScore.HasPrivilege && viewModel.ViewBBScore.Visible) // BB Score addeed 9/19/2017
                {
                    AddSummaryItem("Blue Book Score:", company.BlueBookScore, false, "");
                }
                AddSummaryItem ("Industry:", company.Industry, false, "");
				AddSummaryItem ("Type:", company.Type, false, "");
				AddSummaryItem ("Status:", company.Status, false, "");
				AddSummaryItem ("Call:", company.Phone, true, "PHONE");
				AddSummaryItem ("Fax:", company.Fax, false, "");
				AddSummaryItem ("Toll-Free:", company.TollFree, true, "PHONE");
				AddSummaryItem ("Email:", company.Email, true, "EMAIL");
				AddSummaryItem ("Web:", company.Web, true, "WEB");
			}

			//Need to check for social media
			foreach(var social in company.SocialMedia)
			{
				AddSummaryItem ("Social Media:", "", true, "SOCIAL", social.Media, social.Url);
			}

		}
		private void AddSummaryItem(string labelName, string value, bool action, string actionURL, string image = "",  string socialUrl = null){
			viewModel.SummaryItems.Add(new CompanySummaryListItemViewModel() {LabelName = labelName, Value = value, Action=action, ActionURL=actionURL, Image = image, SocialURL = socialUrl});
//			if (!string.IsNullOrEmpty (value)) {
//				viewModel.SummaryItems.Add(new CompanySummaryListItemViewModel() {LabelName = labelName, Value = value, Action=action, ActionURL=actionURL});
//			}
		}
		private void AddSectionItem(string displayName){
			if (!string.IsNullOrEmpty (displayName)) {
				viewModel.SectionItems.Add(new CompanySectionListItemViewModel() { Section = displayName, DisplayName = displayName});
			}
		}
	}
}

