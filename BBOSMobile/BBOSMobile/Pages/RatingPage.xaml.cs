using System;
using System.Collections.Generic;

using Xamarin.Forms;
using System.Linq;
using System.Collections.ObjectModel;
using BBOSMobile.ServiceModels.Common;
using BBOSMobile.Core.Interfaces;

namespace BBOSMobile.Forms
{
	public partial class RatingPage : BaseContentPage
	{
		public RatingPage  (CompanyViewModel viewModel)
		{
			InitializeComponent ();
			var ratings = viewModel.Company.Ratings.Where (m => m != null).ToList ();
			viewModel.Company.Ratings = new ObservableCollection<Rating>(ratings);

			BindingContext = viewModel;

			this.Title = "Rating";
			if (viewModel.Company.Ratings.Count == 0) 
			{
				noRecordsFound.IsVisible = true;
				listViewCompany.IsVisible = false;
			} 
			else 
			{
				noRecordsFound.IsVisible = false;
				listViewCompany.IsVisible = true;
			}

			//ITrackerService service = App.TrackerService;
			//service.TrackScreen ("Company Search Results");
		}
	}
}

