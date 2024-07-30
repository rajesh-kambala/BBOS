using System;
using System.Collections.Generic;
using Xamarin.Forms;
using BBOSMobile.ServiceModels.Common;
using BBOSMobile.Core.Interfaces;

namespace BBOSMobile.Forms
{
	public partial class CompanyClassificationListContentView : ContentView
	{
		public CompanyClassificationListContentView (CompanyViewModel viewModel)
		{
			InitializeComponent ();
			BindingContext = viewModel;
			//ITrackerService service = App.TrackerService;
			//service.TrackScreen ("Company Classification List");
		}
	}
}



