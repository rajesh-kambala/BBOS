using System;
using System.Collections.Generic;
using Xamarin.Forms;
using BBOSMobile.Core.Interfaces;

namespace BBOSMobile.Forms
{
	public partial class CompanySpecieListContentView : ContentView
	{
		public CompanySpecieListContentView (CompanyViewModel viewModel)
		{
			InitializeComponent ();
			BindingContext = viewModel;
			//ITrackerService service = App.TrackerService;
			//service.TrackScreen ("Company Specie List");
		}
	}
}

