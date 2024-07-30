using System;
using System.Collections.Generic;

using Xamarin.Forms;
using BBOSMobile.Core;
using BBOSMobile.Forms.Custom;

namespace BBOSMobile.Forms.Pages
{
	public partial class WatchDogGroups : ContentPage
	{
		public WatchDogGroups ()
		{
			InitializeComponent();		
			Setup ();
			//TestRedirect ();
		}

		async void TestRedirect(){
			var watchdogAddPage = new WatchdogAddPage(281523);
			await Navigation.PushAsync(watchdogAddPage);
		}

		private void Setup(){
			var vm = GetViewModel ();
			var view = new WatchdogGroupListContentView (vm);
			mainLayout.Children.Add (view);
		}

		private WatchdogListViewModel GetViewModel()
		{
			var serviceClient = new WatchdogWebserviceClient ();

            var response = serviceClient.GetWatchdogs(0);
            //var response = serviceClient.GetWatchdogsMockData();

            var watchdogList = new List<WatchdogListItemViewModel> ();

			foreach(var watchdog in response.Result.WatchdogGroups)
			{
				var watchdogListItem = new WatchdogListItemViewModel ();
				watchdogListItem.Count = watchdog.Count;
				watchdogListItem.Name = watchdog.Name;
				watchdogListItem.IsPrivate = watchdog.IsPrivate;
				watchdogListItem.WatchdogGroupId = watchdog.WatchdogGroupId;

				watchdogList.Add (watchdogListItem);
			}

			WatchdogListViewModel vm = new WatchdogListViewModel ();
			vm.WatchdogListItems = watchdogList;

			return vm;
		}
	}
}

