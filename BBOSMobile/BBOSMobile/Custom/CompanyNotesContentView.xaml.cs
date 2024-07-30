using System;
using System.Collections.Generic;
using Xamarin.Forms;
using BBOSMobile.ServiceModels.Common;
using BBOSMobile.Forms.Common;

namespace BBOSMobile.Forms
{
	public partial class CompanyNotesContentView : ContentView
	{
		private int _bbid;
		private CompanyNotesPage _parent;

		public CompanyNotesContentView (IEnumerable<Note> Notes, int bbid, CompanyNotesPage parent)
		{
			InitializeComponent ();
			_bbid = bbid;
			_parent = parent;
			BindingContext = Notes;

		}
		async void OnListItemTapped(object sender, ItemTappedEventArgs e)
		{
			var model = e.Item as Note;
			var notesPage = new NotesPage(model, _bbid, _parent);

			// de-select the row
			((ListView)sender).SelectedItem = null; 

			//var notesPage = new NotesPage(note, _bbid, this);
			var page = Utils.GetNavigationPage (notesPage);
			await Navigation.PushModalAsync (page, true);

			//await Navigation.PushModalAsync (notesPage, true);

		

		}

//		var modalPage = new ContentPage ();
//		await Navigation.PushModalAsync (modalPage);
//		Debug.WriteLine ("The modal page is now on screen");
//		var poppedPage = await Navigation.PopModalAsync ();
//		Debug.WriteLine ("The modal page is dismissed");
//		Debug.WriteLine (Object.ReferenceEquals (modalPage, poppedPage)); //prints "true"


	}
}

