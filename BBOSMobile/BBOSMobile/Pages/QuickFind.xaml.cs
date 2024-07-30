using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Threading.Tasks;
using BBOSMobile.Core;
using BBOSMobile.Forms.Custom;
using Xamarin.Forms;
using BBOSMobile.ServiceModels.Common;
using BBOSMobile.Core.Interfaces;

namespace BBOSMobile.Forms.Pages
{
	public partial class QuickFind : BaseContentPage
	{
		CompanyListViewModel viewModel = new CompanyListViewModel() { PageIndex = 0, PageSize = 20 };
		CompanyListContentView companyListView;
		string previousSearchText = null;
		int latestCompanyListCount;
		public static bool ShouldKeepContent;

		public QuickFind ()
		{
			InitializeComponent ();
			BindingContext = viewModel;
			//NavigationPage.SetHasNavigationBar (this, false);
			Title = "Quick Find";

			if (!App.RecentViewsSecurity.HasPrivilege && !App.RecentViewsSecurity.Enabled) {
				RVSL.Opacity = .5;
			}
			if (!App.WatchdogListsPage.HasPrivilege && !App.WatchdogListsPage.Enabled) {
				WDSL.Opacity = .5;
			}
			var tapGestureRecognizerRV = new TapGestureRecognizer();
			tapGestureRecognizerRV.Tapped += (s, e) => {
				// handle the tap
				if ((App.RecentViewsSecurity.HasPrivilege) || (App.RecentViewsSecurity.Enabled)) {
					var page = new RecentViews ();
					App.RootPage.NavigateToPage (page);
				}
				else{
					DisplayAlert (Common.Constants.AlertTitle, Common.Constants.InvalidPermissionAlertMessage, Common.Constants.AlertOk);
				}

			};
			RVSL.GestureRecognizers.Add(tapGestureRecognizerRV);

			var tapGestureRecognizerWD = new TapGestureRecognizer();
			tapGestureRecognizerWD.Tapped += (s, e) => {
				// handle the tap
				if ((App.WatchdogListsPage.HasPrivilege) || (App.WatchdogListsPage.Enabled)) {
					var page = new WatchDogGroupsPage ();
					App.RootPage.NavigateToPage (page);
				}
				else{
					DisplayAlert (Common.Constants.AlertTitle, Common.Constants.InvalidPermissionAlertMessage, Common.Constants.AlertOk);
				}
			};
			WDSL.GestureRecognizers.Add(tapGestureRecognizerWD);

            var tapGestureRecognizerPS = new TapGestureRecognizer();
            tapGestureRecognizerPS.Tapped += (s, e) => {
                // handle the tap
                var page = new ContactSearch();
                App.RootPage.NavigateToPage(page);
            };
            PSSL.GestureRecognizers.Add(tapGestureRecognizerPS);

            var tapGestureRecognizerCS = new TapGestureRecognizer();
			tapGestureRecognizerCS.Tapped += (s, e) => {
				// handle the tap
				var page = new CompanySearch ();
				App.RootPage.NavigateToPage (page);
			};
			CSSL.GestureRecognizers.Add(tapGestureRecognizerCS);

			//ITrackerService service = App.TrackerService;
			//service.TrackScreen ("Quick Find");

		}

		protected override void OnAppearing ()
		{
			IsBusy = true;
			ShouldKeepContent = false;
			base.OnAppearing ();
			IsBusy = false;
            mainLayout.VerticalOptions = LayoutOptions.FillAndExpand;
            mainLayout.ForceLayout();
		}

		protected override void OnDisappearing ()
		{
			if (ShouldClearContent(QuickFind.ShouldKeepContent)) 
			{
				//viewModel = null;
			} 
		}
		protected override bool OnBackButtonPressed()
		{
			var page = new Dashboard ();
			App.RootPage.NavigateToPage (page);
			return true;
		}
		void OnSearchButtonPressed(object sender, EventArgs args)
		{
			return;
		}
		void OnCompanySearchButtonPressed(object sender, EventArgs args)
		{
			var page = new CompanySearch ();
			App.RootPage.NavigateToPage (page);
		}
		void OnRecentViewsButtonPressed(object sender, EventArgs args)
		{
			var page = new RecentViews ();
			App.RootPage.NavigateToPage (page);
		}
		void OnWatchDogGroupsButtonPressed(object sender, EventArgs args)
		{
			var page = new WatchDogGroupsPage ();
			App.RootPage.NavigateToPage (page);
		}

		void OnTextChanged(object sender, TextChangedEventArgs args)
		{
			ExecuteSearch(sender, args).ConfigureAwait(false); 
		}

		async Task ExecuteSearch(object sender, TextChangedEventArgs args)
		{
			
			await Task.Delay (700);

			SearchBar searchBar = (SearchBar)sender;

			string currentSearchText = searchBar.Text;
			string initialSearchText = args.NewTextValue;
			if (currentSearchText == initialSearchText) {
				if (!string.IsNullOrEmpty (currentSearchText)) {
					GetCompanies (currentSearchText);
				} else {
					viewModel.Companies = new ObservableCollection<CompanyListItemViewModel> ();
					ResetCompanyListView (false);
				}
			}
		}

		private async void GetCompanies(string searchText)
		{
			if (previousSearchText != searchText) {
				viewModel.PageIndex = 0;
				previousSearchText = searchText;
			} else {
				viewModel.PageIndex++;
			}

			try
			{
				var serviceClient = new CompanyWebserviceClient ();
				var response = await serviceClient.GetCompanies (searchText, viewModel.PageIndex, viewModel.PageSize);
				if (response.ResponseStatus == BBOSMobile.ServiceModels.Common.Enumerations.ResponseStatus.InvalidUserId) 
				{
					await Navigation.PushAsync(new LoginPage ());
					return;
				}

				if (response.ResponseStatus != Enumerations.ResponseStatus.Failure) 
				{
					if (response.Companies == null) 
					{
						return;
					}
					var companyList = new ObservableCollection<CompanyListItemViewModel> ();

					foreach (var company in response.Companies) {
						var companyListItem = new CompanyListItemViewModel ();
						companyListItem.BBID = company.BBID;
						companyListItem.Name = company.Name;
						companyListItem.Location = company.Location;
						companyListItem.Rating = company.Rating;
						companyListItem.IndustryAndType = string.Format ("{0} {1}", company.Industry, company.Type);
						companyListItem.HasNotes = company.HasNotes;
						companyListItem.Phone = company.Phone;
						companyListItem.Index = company.Index + (viewModel.PageSize * (viewModel.PageIndex));

						companyList.Add (companyListItem);
					}

					latestCompanyListCount = companyList.Count;

					if (viewModel.PageIndex == 0) {

						viewModel.Companies = new ObservableCollection<CompanyListItemViewModel> ();
						viewModel.Companies = companyList;

						ResetCompanyListView (true);
					} else {
						foreach (var company in companyList) {
							viewModel.Companies.Add (company);
						}
					}
				}
			} catch(Exception ex) {
				DisplayErrorLoadingAlert ();
			}	
		}

		private void OnItemAppearing(ListView listView, ItemVisibilityEventArgs e)
		{
			if (viewModel != null && viewModel.Companies != null && viewModel.Companies.Count == 0) {
				return;
			}
				
			if (latestCompanyListCount < viewModel.PageSize) 
			{
				return;
			}

			//hit bottom!
			if (viewModel.Companies.Count > 10) {
				if(((CompanyListItemViewModel)e.Item).Index == viewModel.Companies.Count - 1)
				{
					GetCompanies(searchEntry.Text);
				}
			}

		}

		private void ResetCompanyListView(bool ShowNoRecsFoundAlert)
		{
			if (companyListView != null) 
			{
				mainLayout.Children.Remove(companyListView);
			} 

			companyListView = new CompanyListContentView (viewModel, ShowNoRecsFoundAlert);

			mainLayout.Children.Add(companyListView);

			companyListView.ListViewCompany.ItemAppearing += (Object listView, ItemVisibilityEventArgs e) => {
				OnItemAppearing ((ListView)listView, e);
			};
		}
	}
}

