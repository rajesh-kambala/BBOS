using System;

using Android.Content;
using Xamarin.Forms;
using BBOSMobile.Core.Interfaces;
using BBOSMobile.Droid.Services;

[assembly: Dependency(typeof(PhoneCallService))]
namespace BBOSMobile.Droid.Services
{
    public class PhoneCallService : IPhoneCallService
	{
		/// <summary>
		/// Used for registration with dependency service
		/// </summary>
		public static void Init ()
		{
		}

		/// <summary>
		/// Makes the call.
		/// </summary>
		/// <param name="phoneNumber">Phone number.</param>
		public void MakeCall (string phoneNumber)
		{
			var uri = Android.Net.Uri.Parse(String.Format("tel:{0}", phoneNumber));
			var intent = new Intent(Intent.ActionView, uri);
			intent.AddFlags (ActivityFlags.NewTask);
			Android.App.Application.Context.StartActivity (intent);
		}
	}
}

