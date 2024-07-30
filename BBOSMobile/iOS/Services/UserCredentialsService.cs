using System;
using Security;
using Foundation;

using Newtonsoft.Json;
using Xamarin.Forms;
using BBOSMobile.Core.Common;
using BBOSMobile.Core.Interfaces;
using BBOSMobile.Core.Models;
using BBOSMobile.iOS.Services;
using System.Diagnostics;

[assembly: Dependency(typeof(UserCredentialsService))]
namespace BBOSMobile.iOS.Services
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
			SetUserCredentials(userCredentials); 
		}

		/// <summary>
		/// Gets the password sec record.
		/// </summary>
		/// <returns>The password sec record.</returns>
		private SecRecord GetPasswordSecRecord()
		{
			var passwordSecRecord = new SecRecord (SecKind.GenericPassword) {
				Generic = NSData.FromString (Constants.UserCredentialsAccount)
			};

			return passwordSecRecord;
		}

		/// <summary>
		/// Gets the user credentials.
		/// </summary>
		/// <returns>The user credentials.</returns>
		public UserCredentials GetUserCredentials()
		{
			UserCredentials userCredentials = new UserCredentials ();

			SecStatusCode resultCode;
			var userCredentialSecRecord = SecKeyChain.QueryAsRecord (GetPasswordSecRecord(), out resultCode);
			if (resultCode == SecStatusCode.Success) 
			{
				userCredentials =  JsonConvert.DeserializeObject<UserCredentials> (userCredentialSecRecord.ValueData.ToString ());
				userCredentials.UserId = new Guid (userCredentialSecRecord.Comment);
			}
			//Debug.WriteLine("@@@ getting user_credentials NSDATA valuedata:" + userCredentialSecRecord.ValueData.ToString());

			return userCredentials;
		}

		/// <summary>
		/// Removes the password sec record.
		/// </summary>
		public void RemovePasswordSecRecord()
		{
			var existingPasswordSecRecord = GetPasswordSecRecord ();

			SecStatusCode resultCode;
			var userCredentialSecRecord = SecKeyChain.QueryAsRecord (existingPasswordSecRecord, out resultCode);

			if (resultCode == SecStatusCode.Success) 
			{
				resultCode = SecKeyChain.Remove(existingPasswordSecRecord);
			} 
		}

		/// <summary>
		/// Sets the user credentials.
		/// </summary>
		/// <param name="userCredentials">User credentials.</param>
		public void SetUserCredentials(UserCredentials userCredentials)
		{
			RemovePasswordSecRecord ();

			var newUserCredentialSecRecord = new SecRecord(SecKind.GenericPassword) {
				Label = userCredentials.Email,
				Description = Constants.UserCredentialsDescription,
				Account = userCredentials.Email,
				Service = Constants.UserCredentialsAccount,
				Comment = userCredentials.UserId.ToString(),
				ValueData = NSData.FromString(JsonConvert.SerializeObject(userCredentials)),

				Generic = NSData.FromString (Constants.UserCredentialsAccount)
			};

			Debug.WriteLine("@@@ setting user_credentials NSDATA valuedata:" + NSData.FromString(JsonConvert.SerializeObject(userCredentials)));

			SecKeyChain.Add (newUserCredentialSecRecord);
		}
	}
}

