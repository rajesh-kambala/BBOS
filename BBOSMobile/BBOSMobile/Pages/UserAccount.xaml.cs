using System;
using System.Collections.Generic;

using Xamarin.Forms;
using BBOSMobile.Core.Interfaces;

namespace BBOSMobile.Forms.Pages
{
	public partial class UserAccount : BaseContentPage
	{

		public UserAccount ()
		{
			InitializeComponent ();
			var userCredentials = DependencyService.Get<IUserCredentialsService> ().GetUserCredentials ();
			if (userCredentials.UserId == Guid.Empty) 
			{
				//MainPage = new LoginPage ();
			} 
			else 
			{
				lblEmail.Text = userCredentials.Email;
				lblUserType.Text += userCredentials.UserType;
			}
			this.Title = "User Account";

//			lblWebsite.GestureRecognizers.Add (new TapGestureRecognizer {
//				Command = new Command (()=> OnWebsiteClicked()),
//			});

			ITrackerService service = App.TrackerService;
			//service.TrackScreen ("User Account");

		
		}
		protected override bool OnBackButtonPressed()
		{
			var page = new Dashboard ();
			App.RootPage.NavigateToPage (page);
			return true;
		}
		void OnWebsiteClicked()
		{
			Device.OpenUri(new Uri("http://www.bluebookservices.com"));
		}

		void onLogOutButtonClicked(object sender, EventArgs args){
			var page = new LoginPage ();
			this.Navigation.PushAsync(page);
		}
	}
}

