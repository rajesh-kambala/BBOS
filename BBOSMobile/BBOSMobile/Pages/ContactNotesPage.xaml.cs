using System;
using System.Collections.Generic;
using System.Threading.Tasks;

using Xamarin.Forms;
using BBOSMobile.ServiceModels.Common;
using BBOSMobile.ServiceModels;
using BBOSMobile.Core.Interfaces;
using BBOSMobile.Core;
using BBOSMobile.ServiceModels.Requests;
using BBOSMobile.ServiceModels.Responses;
using BBOSMobile.Forms.ViewModels;
using BBOSMobile.Forms.Pages;

namespace BBOSMobile.Forms
{
	public partial class ContactNotesPage : BaseContentPage
	{
		private NoteViewModel viewModel { get; set; }
		private int _contactID;
		private int _bbid;
		private CompanyPage _parentPage;
		public ContactNotesPage (Contact contact, int BBID, CompanyPage parent)
		{
			//NavigationPage.SetHasNavigationBar (this, false);
			IsBusy = true;
			InitializeComponent ();
			_contactID = contact.ContactID;
			_bbid = BBID;
			_parentPage = parent;
			viewModel = new NoteViewModel ();

			viewModel.Note = contact.Notes == null ? new Note (){ NoteID = 0 } : contact.Notes;
			this.BindingContext = viewModel;

			//ITrackerService service = App.TrackerService;
			//service.TrackScreen ("Company Notes");

			IsBusy = false;
			Title = "Notes";

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
					//_parentPage.reloadClientContacts ();  /// samsung issue?
					await Navigation.PopModalAsync ();
				}
				IsBusy = false;
			}
		}
		private async void OnCancelButtonClicked(object sender, EventArgs args)
		{
			if (!IsBusy) {
				await Navigation.PopModalAsync ();
			}

		}

		private async Task<bool> SaveNote()
		{
			bool returnValue = false;

			try {
				var userCredentials = DependencyService.Get<IUserCredentialsService> ().GetUserCredentials ();
				var companyClient = new CompanyWebserviceClient ();
				var request = new SaveContactNoteRequest ();
				var note = viewModel.Note == null ? new Note() : viewModel.Note;
				//request.NoteText = viewModel.Note.NoteText;
				request.BBID = _bbid;
				request.ContactID = _contactID;
				request.Note = note;
				request.UserId = userCredentials.UserId;
	//			request.Note = note.NoteText;
				request.NoteID = note.NoteID;

				SaveContactNoteReponse response = await companyClient.SaveContactNote (request);
				var status = response.ResponseStatus;
				var message = response.ErrorMessage;
				if (status == Enumerations.ResponseStatus.Success) {
					returnValue = true;
				}
			}  catch(Exception ex) {
				DisplayErrorLoadingAlert ();
			}

			return returnValue;
		}
	}
}

