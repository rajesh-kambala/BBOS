using System;

using Foundation;
using UIKit;
using Xamarin.Forms;
using BBOSMobile.Core;
using BBOSMobile.Core.Interfaces;
using BBOSMobile.iOS;
using BBOSMobile.iOS.Services;

[assembly: Dependency(typeof(PhoneCallService))]
namespace BBOSMobile.iOS.Services
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
			NSUrl url = new NSUrl (string.Format (@"telprompt://{0}", phoneNumber));
			UIApplication.SharedApplication.OpenUrl (url);
		}
	}
}

