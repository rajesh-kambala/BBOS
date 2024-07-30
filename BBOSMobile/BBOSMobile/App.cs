using System;

using Xamarin.Forms;
using BBOSMobile.Core.Data;
using BBOSMobile.Core.Models;
using BBOSMobile.Core.Interfaces;
using BBOSMobile.Forms.Pages;
using BBOSMobile.Forms.Pages.Menu;

namespace BBOSMobile.Forms
{
	public class App : Application
	{
		

		public Appold ()
		{
			//read local device to 
			//determine if needs to go to login/dashboard/terms
			//var loginPage = new NavigationPage (new LoginPage ());
			//var rootPage = new NavigationPage (new RootPage ());
			//MainPage = rootPage;

			// Temporary Code to make sure we have a valid guid to test with
//			var userWebServiceClient = new BBOSMobile.Core.WebServices.UserWebserviceClient ();
//			var loginRequest = new BBOSMobile.ServiceModels.Requests.LoginRequest ();
//			loginRequest.Email = "mmamalis@travant.com";
//			loginRequest.Password = "Search41West";
//			var loginResponse = userWebServiceClient.Login (loginRequest);

//			var userId = new Guid("f1dd6e74-413c-4d3a-9345-3268ee6769a0");
//
//			var userCredentialsTemp = new UserCredentials {
//				Email = "mmamalis@travant.com",
//				Password = "Search41West",
//				UserId = userId
//			};
//			DependencyService.Get<IUserCredentialsService> ().SetUserCredentials (userCredentialsTemp);
//			// End Temporary Code


		}
	
		//protected override void OnStart ()
		//{
		//	// Handle when your app starts
		//}

		//protected override void OnSleep ()
		//{
		//	// Handle when your app sleeps
		//}

		//protected override void OnResume ()
		//{
		//	// Handle when your app resumes
		//}

		//public static BBOSDatabase Database {
		//	get 
		//	{ 
		//		if (database == null) 
		//		{
		//			database = new BBOSDatabase ();
		//		}
		//		return database; 
		//	}
		//}


	}
}

