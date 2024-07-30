using System;
using System.Collections.Generic;

using Xamarin.Forms;
using BBOSMobile.Forms.Pages;
using BBOSMobile.ServiceModels.Common;
using BBOSMobile.Core;
using BBOSMobile.Core.Interfaces;

namespace BBOSMobile.Forms.Custom
{
	public partial class WatchdogGroupListContentView : ContentView
	{
		public WatchdogGroupListContentView (WatchdogListViewModel viewModel)
		{
			InitializeComponent ();
			BindingContext = viewModel;

		}

		async void OnListItemTapped(object sender, ItemTappedEventArgs e)
		{
			//TODO:  Switch over to watchdog group view models 

			var model = e.Item as WatchdogListItemViewModel;
			var watchdogDetailPage = new WatchdogDetailPage(model);

			// de-select the row
			((ListView)sender).SelectedItem = null; 

			WatchDogGroupsPage.ShouldKeepContent = true;
			await Navigation.PushAsync(watchdogDetailPage);
		}
	}
}

