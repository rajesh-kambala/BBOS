using System;
using System.Collections.Generic;
using Xamarin.Forms;
using BBOSMobile.Core.Interfaces;

namespace BBOSMobile.Forms
{
	public partial class CompanyServiceListContentView : ContentView
	{
		public CompanyServiceListContentView (CompanyViewModel viewModel)
		{
			InitializeComponent ();
			BindingContext = viewModel;
			//ITrackerService service = App.TrackerService;
			//service.TrackScreen ("Company Service List");
		}
	}
}

