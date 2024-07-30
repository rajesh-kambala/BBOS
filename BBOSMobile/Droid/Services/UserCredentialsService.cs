using System;

using Android.Content;
using Android.Preferences;
using Newtonsoft.Json;
using Xamarin.Forms;
using BBOSMobile.Core.Common;
using BBOSMobile.Core.Interfaces;
using BBOSMobile.Core.Models;
using BBOSMobile.Droid.Services;

[assembly: Dependency(typeof(UserCredentialsService))]
namespace BBOSMobile.Droid.Services
{
	public class UserCredentialsService : IUserCredentialsService
	{
		/// <summary>
		/// Used for registration with dependency service
		/// </summary>
		public static void Init ()
		{
		}

		/// <summary>
		/// Clears the user credentials.
		/// </summary>
		public void ClearUserCredentials()
		{
			var userCredentials = new UserCredentials ();
			userCredentials.Email = String.Empty;
			userCredentials.Password = String.Empty;
			//userCredentials.SecurityPrivileges = null;
			//userCredentials
			SetUserCredentials(userCredentials);
		}

		/// <summary>
		/// Sets the user credentials.
		/// </summary>
		/// <param name="userCredentials">User credentials.</param>
		public void SetUserCredentials(UserCredentials userCredentials)
		{
			ISharedPreferences preferenceManager = PreferenceManager.GetDefaultSharedPreferences (Android.App.Application.Context); 
			ISharedPreferencesEditor editor = preferenceManager.Edit ();
			editor.PutString (Constants.UserCredentialsAccount, userCredentials.Email);
			editor.PutString (Constants.UserCredentialsInfo, JsonConvert.SerializeObject(userCredentials));
			editor.Apply ();
		}

		/// <summary>
		/// Gets the user credentials.
		/// </summary>
		/// <returns>The user credentials.</returns>
		public UserCredentials GetUserCredentials()
		{
			UserCredentials userCredentials = new UserCredentials ();

			ISharedPreferences preferenceManager = PreferenceManager.GetDefaultSharedPreferences (Android.App.Application.Context); 
			var userCredentialsValue = preferenceManager.GetString (Constants.UserCredentialsInfo, String.Empty);
			if (!String.IsNullOrEmpty (userCredentialsValue)) 
			{
				userCredentials = JsonConvert.DeserializeObject<UserCredentials> (userCredentialsValue);
			}
			userCredentials.Email = preferenceManager.GetString (Constants.UserCredentialsAccount, String.Empty);

			return userCredentials;
		}
	}
}

