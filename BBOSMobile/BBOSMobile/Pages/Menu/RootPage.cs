using System;
using System.Linq;

using Xamarin.Forms;

using Custom = BBOSMobile.Forms.Custom;
using BBOSMobile.Forms.Common;

namespace BBOSMobile.Forms.Pages.Menu
{
	public class RootPage : MasterDetailPage
	{
		Custom.MenuItem previousItem;

		public static MenuPage OptionsPage;

		public RootPage ()
		{
			Title = "Blue Book Services";
			OptionsPage = new MenuPage(){Title = "menu", Icon="settings"};
//			System.Windows.Input.ICommand ViewFilterCommand = new Command((sender) =>
//			{
//				DisplayActionSheet("test", "cance", "d", new string[]{"En suspend", "En traitement", "Refusée", "Acceptée"});
//			});
//			this.ToolbarItems.Add (new ToolbarItem (){ Icon = "settings", Command = ViewFilterCommand });
			OptionsPage.Menu.ItemSelected += (sender, e) => NavigateTo(e.SelectedItem as Custom.MenuItem);


			Master = OptionsPage;

			Detail = Utils.GetNavigationPage (new Dashboard ());

			//NavigateTo(optionsPage.Menu.ItemsSource.Cast<Custom.MenuItem>().First());

			//NavigationPage.SetHasNavigationBar (this, false);  
		}

		public void NavigateToPage(Page page)
		{
			if (previousItem != null) 
			{
				previousItem.Selected = false;
			}

			Detail = Utils.GetNavigationPage (page);

			IsPresented = false;
		}

		void NavigateTo(Custom.MenuItem option)
		{
			if (previousItem != null)
				previousItem.Selected = false;

			if (option != null) 
			{
				option.Selected = true;
				previousItem = option;

				var displayPage = PageForOption (option);
				if (option.Title == "View Full Site") {
					Device.OpenUri(new Uri("https://apps.bluebookservices.com/BBOS/Login.aspx"));
				}
				if (option.Title == "Watchdog Groups") {
					if ((App.WatchdogListsPage.HasPrivilege) || (App.WatchdogListsPage.Enabled)) {
						
					}
					else{
						DisplayAlert (Common.Constants.AlertTitle, Common.Constants.InvalidPermissionAlertMessage, Common.Constants.AlertOk);
						return;
					}
				}
				if (option.Title == "Recent Views") {
					if ((App.RecentViewsSecurity.HasPrivilege) || (App.RecentViewsSecurity.Enabled)) {

					}
					else{
						DisplayAlert (Common.Constants.AlertTitle, Common.Constants.InvalidPermissionAlertMessage, Common.Constants.AlertOk);
						return;
					}
				}

				Detail = Utils.GetNavigationPage (displayPage);

				OptionsPage.Menu.SelectedItem = null;
			}

			IsPresented = false;
		}

		Page PageForOption (Custom.MenuItem option)
		{
			// TODO: Refactor this to the Builder pattern (see ICellFactory).
			if (option.Title == "Dashboard")
				return new Dashboard();
			if (option.Title == "Quick Find")
				return new QuickFind();
			if (option.Title == "Company Search")
				return new CompanySearch();
            if (option.Title == "Person Search")
                return new ContactSearch();
            if (option.Title == "Recent Views")
				return new RecentViews();
			if (option.Title == "Watchdog Groups")
				return new WatchDogGroupsPage();
			if (option.Title == "Contact Us")
				return new ContactUs();
			if (option.Title == "User Account")
				return new UserAccount();
			if (option.Title == "About Us")
				return new AboutUs();
			if (option.Title == "View Full Site")
				return new Dashboard();
			if (option.Title == "Log Out")
				//delete out user
				return new LoginPage();
		
			return new Dashboard();
			//throw new NotImplementedException("Unknown menu option: " + option.Title);
		}
	}
}


