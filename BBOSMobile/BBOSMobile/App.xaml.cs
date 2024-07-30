using System;
using System.Linq;

using Xamarin.Forms.Xaml;
using Xamarin.Forms;
using BBOSMobile.Core.Models;
using BBOSMobile.Core.Interfaces;
using BBOSMobile.Forms.Pages;
using BBOSMobile.Forms.Pages.Menu;
using System.Collections.Generic;
using System.Diagnostics;
using BBOSMobile.Core.Data;

[assembly: XamlCompilation(XamlCompilationOptions.Compile)]

namespace BBOSMobile.Forms
{

    public partial class App : Application
    {
        static BBOSDatabase database;
        public static RootPage RootPage { get; set; }
        public static BBOSMobile.ServiceModels.Common.SecurityResult RecentViewsSecurity { get; set; } 
		public static BBOSMobile.ServiceModels.Common.SecurityResult WatchdogListsPage { get; set; }
		public static ITrackerService TrackerService { get; set; }

		public static IEnumerable<int> UserRelatedBBIDs { get; set; }
		public static int UserBBID { get; set; }

        protected override void OnStart()
        {
            // Handle when your app starts
        }

        protected override void OnSleep()
        {
            // Handle when your app sleeps
        }

        protected override void OnResume()
        {
            // Handle when your app resumes
        }

        public static BBOSDatabase Database
        {
            get
            {
                if (database == null)
                {
                    database = new BBOSDatabase();
                }
                return database;
            }
        }
        public App()
        {
			InitializeComponent ();
			if (TrackerService == null) {
				TrackerService = DependencyService.Get<ITrackerService> ();
			}
			SetMainPage ();
		
		}

		/// <summary>
		/// Sets the main page.
		/// </summary>
		private void SetMainPage ()
		{
			
			var userCredentials = DependencyService.Get<IUserCredentialsService> ().GetUserCredentials ();
			if (userCredentials.UserId == Guid.Empty || userCredentials.SecurityPrivileges == null) 
			{
				MainPage = new LoginPage ();
			}  
			else 
			{
				RecentViewsSecurity = userCredentials.SecurityPrivileges.Find (m => m.PrivilegeName == BBOSMobile.ServiceModels.Common.Enumerations.Privilege.RecentViewsPage); 
				WatchdogListsPage = userCredentials.SecurityPrivileges.Find (m => m.PrivilegeName == BBOSMobile.ServiceModels.Common.Enumerations.Privilege.WatchdogListsPage);

				Debug.WriteLine("@@@@ in APP class -- setting App.UserBBID with : " + userCredentials.UserBBID);

				UserRelatedBBIDs = userCredentials.UserRelatedBBIDs;
				UserBBID = userCredentials.UserBBID;


				App.RootPage = new RootPage ();
				MainPage = App.RootPage;
			}




		}

        
    }
}