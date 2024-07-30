using System;
using System.Collections.Generic;
using Xamarin.Forms;

namespace BBOSMobile.Forms.Custom
{
	public partial class WatchdogAddListContentView : ContentView
	{
		public WatchdogAddListContentView (WatchdogAddViewModel viewModel)
		{
			InitializeComponent ();
			BindingContext = viewModel;
		}

	
		async void OnListItemTapped(object sender, ItemTappedEventArgs e)
		{
			//TODO:  Switch over to watchdog group view models 

//			var model = e.Item as WatchdogListItemViewModel;
//			var watchdogDetailPage = new WatchdogDetailPage(model);
//
//			// de-select the row
//			((ListView)sender).SelectedItem = null; 
//
//			await Navigation.PushAsync(watchdogDetailPage);
		}
	}
}

