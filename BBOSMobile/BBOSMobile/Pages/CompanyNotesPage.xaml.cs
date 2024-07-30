using System;
using System.Collections.Generic;

using Xamarin.Forms;
using BBOSMobile.Core;
using BBOSMobile.ServiceModels.Common;
using BBOSMobile.ServiceModels;
using BBOSMobile.Forms.Pages;
using BBOSMobile.Forms.Common;
using BBOSMobile.Core.Interfaces;

namespace BBOSMobile.Forms
{
	public partial class CompanyNotesPage : BaseContentPage
	{
		private int _bbid;
//		private bool hasNotes;
		//private bool _loaded = false;
		private CompanyNotesContentView listview;
		private CompanyViewModel _companyViewModel;
		public static bool ShouldKeepContent;

		public CompanyNotesPage (Int32 BBID, CompanyViewModel vm)
		{
			IsBusy = true;
			InitializeComponent ();
			_companyViewModel = vm;
			_bbid = BBID;
			ToolbarItems.Add(new ToolbarItem("", "AddNote.png", async () =>
				{
					var date = DateTime.Now;
					CompanyNotesPage.ShouldKeepContent = true;
					Note note = new Note(){NoteID = 0, NoteText = "", LastUpdatedBy = "", LastUpdated = date};

					var notesPage = new NotesPage(note, _bbid, this);
					var page = Utils.GetNavigationPage (notesPage);
					await Navigation.PushModalAsync (page, true);
				}));

			IsBusy = false;
			//ITrackerService service = App.TrackerService;
			//service.TrackScreen ("Company Notes");

		}
			
		public void Reload(){
			Setup ();
		}
		protected override void OnAppearing ()
		{
			IsBusy = true;
			CompanyNotesPage.ShouldKeepContent = false;
			base.OnAppearing ();
//			if (!_loaded) {
//				Setup ();
//			}
			Setup();
			IsBusy = false;
		}

		protected override void OnDisappearing ()
		{
			if (ShouldClearContent(CompanyPage.ShouldKeepContent)) 
			{
				listview = null;
			}
			try
			{
				mainLayout.Children.RemoveAt(0);
			}
			catch(Exception ex)
            {
				//silent error
            }
		}


		private async void Setup()
		{
			this.Title = "Notes";
			try
			{
				var serviceClient = new CompanyWebserviceClient ();
				var response = await serviceClient.GetCompanyNotes (_bbid);
				if (response.Notes.Count > 0){
					_companyViewModel.Company.HasNotes = true;
				}

				if (response.ResponseStatus == BBOSMobile.ServiceModels.Common.Enumerations.ResponseStatus.InvalidUserId) 
				{
					Navigation.PushAsync(new LoginPage ());
				}

				if (listview != null) {
					mainLayout.Children.Remove (listview);
				}

				if (response.ResponseStatus != Enumerations.ResponseStatus.Failure) {
					listview = new CompanyNotesContentView (response.Notes, _bbid, this);
					mainLayout.VerticalOptions = LayoutOptions.FillAndExpand;
					mainLayout.Children.Add (listview);


                    listview.VerticalOptions = LayoutOptions.FillAndExpand;
                    listview.ForceLayout();
                    mainLayout.ForceLayout();
                    listview.ForceLayout();

                }
				//_loaded = true;
			} catch(Exception ex) {
				DisplayErrorLoadingAlert ();
			}

		}

	}
}

