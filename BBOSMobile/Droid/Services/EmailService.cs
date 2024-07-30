
using Android.Content;
using Xamarin.Forms;
using BBOSMobile.Core.Interfaces;
using BBOSMobile.Core.Models;
using BBOSMobile.Droid.Services;


[assembly: Dependency(typeof(EmailService))]
namespace BBOSMobile.Droid.Services
{
    public class EmailService : IEmailService
	{
		/// <summary>
		/// Used for registration with dependency service
		/// </summary>
		public static void Init ()
		{
		}

		/// <summary>
		/// Opens up the Android Email Sender with pre-populated values
		/// </summary>
		/// <param name="email">Email.</param>
		public void CreateEmail (Email email)
		{
			var emailIntent = new Intent (Android.Content.Intent.ActionSendMultiple);
			emailIntent.SetType ("message/rfc822");
			emailIntent.PutExtra (Android.Content.Intent.ExtraEmail, email.ToAddresses.ToArray() );
			emailIntent.PutExtra (Android.Content.Intent.ExtraSubject, email.Subject);

			if (email.IsHtml)
			{
				emailIntent.SetType ("text/html");
				emailIntent.PutExtra (Intent.ExtraText, Android.Text.Html.FromHtml (email.Body));
			}
			else
			{
				emailIntent.SetType ("text/plain");
				emailIntent.PutExtra (Intent.ExtraText, email.Body);
			}

			//Needed to add the "New Task" flag here or it was crashing in the emulator
			var chooserIntent = Intent.CreateChooser (emailIntent, "Send mail...");
			chooserIntent.AddFlags (ActivityFlags.NewTask);

			Android.App.Application.Context.StartActivity (chooserIntent);
		}
		public bool CanSendEmail(){
//			var intent = new Intent (Android.Content.Intent.ActionSend);
//			intent.SetType("text/html");
//			PackageManager packageManager = new PackageManager ();
//			List<ResolveInfo> availableActivities = PackageManager.QueryIntentActivities(intent,0);
//
//
//			if(availableActivities.Count == 0)
//				return false;
//			else 
//				return true;
			return true;
		}
	}
}

