using System;
using System.Collections.Generic;

using Xamarin.Forms;
using BBOSMobile.Core;
using BBOSMobile.ServiceModels.Common;
using BBOSMobile.ServiceModels;
using BBOSMobile.ServiceModels.Requests;
using BBOSMobile.Core.Interfaces;
using BBOSMobile.ServiceModels.Responses;
using System.Threading.Tasks;
using BBOSMobile.Forms.ViewModels;
using BBOSMobile.Forms.Pages;

namespace BBOSMobile.Forms
{
	public partial class NotesPage : BaseContentPage
	{
		private int _bbid;
		private NoteViewModel viewModel { get; set; }
		private static CompanyNotesPage _parentPage { get; set; }

		protected override void OnAppearing ()
		{
			//NavigationPage.SetHasNavigationBar (this, false);
		}
		public NotesPage (Note note, int bbid, CompanyNotesPage parent)
		{
			//NavigationPage.SetHasNavigationBar (this, false);
			Title = "Notes";
			IsBusy = true;
			InitializeComponent ();
			_bbid = bbid;
			_parentPage = parent;

		
			viewModel = new NoteViewModel ();
			viewModel.Note = note;

			this.BindingContext = viewModel;

			//ITrackerService service = App.TrackerService;
			//service.TrackScreen ("Company Note");

			IsBusy = false;

		}
		private async void OnSaveButtonClicked(object sender, EventArgs args)
		{
			
			if (!IsBusy) {
				IsBusy = true;
				bool saveNote = await SaveNote ();
				if (saveNote) 
				{
					if (Device.OS == TargetPlatform.Android) {

					}
					_parentPage.Reload();
					await Navigation.PopModalAsync ();
					IsBusy = false;
				}
			}

			//viewModel.IsBusy = false;
		}
		private async void OnCancelButtonClicked(object sender, EventArgs args)
		{
			if (!IsBusy) {
				IsBusy = true;
				await Navigation.PopModalAsync ();
				IsBusy = false;
			}

		}

		private async Task<bool> SaveNote()
		{
			bool returnValue = false;
			try
			{
				var userCredentials = DependencyService.Get<IUserCredentialsService> ().GetUserCredentials ();
				var companyClient = new CompanyWebserviceClient ();
				var request = new SaveCompanyNoteRequest ();
				request.BBID = _bbid;
				request.Note = viewModel.Note.NoteText;
				request.NoteID = viewModel.Note.NoteID;
				request.UserId = userCredentials.UserId;
				request.Private = viewModel.Note.IsPrivate;
				SaveCompanyNoteReponse response = await companyClient.SaveCompanyNote (request);

				if (response.ResponseStatus != Enumerations.ResponseStatus.Failure) 
				{
					var status = response.ResponseStatus;
					var message = response.ErrorMessage;
					if (status == Enumerations.ResponseStatus.Success) {
						returnValue = true;
					}
				}

			} catch(Exception ex) {
				DisplayErrorLoadingAlert ();
			}
			return returnValue;
		}



//		
	}
}

