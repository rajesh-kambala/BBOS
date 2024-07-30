using System;
using System.Collections.Generic;
using System.Linq;

using Foundation;
using UIKit;
using BBOSMobile.Forms;
using BBOSMobile.iOS.Services;
using Google.Analytics;

namespace BBOSMobile.iOS
{
	[Register ("AppDelegate")]
	public partial class AppDelegate : global::Xamarin.Forms.Platform.iOS.FormsApplicationDelegate
	{
		public ITracker Tracker;
		public static readonly string TrackingId = "UA-65220518-1";

		public override bool FinishedLaunching (UIApplication app, NSDictionary options)
		{
			
			// grab your app token from https://app.testfairy.com/settings/ 
			// TestFairyLib.TestFairy.Begin ("664c3463361a3cdb49e095d6ecde27d3e64eabc0");

			global::Xamarin.Forms.Forms.Init ();
			InitializeDependencyServices ();

			// Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
			Gai.SharedInstance.DispatchInterval = 20;

			// Optional: automatically send uncaught exceptions to Google Analytics.
			Gai.SharedInstance.TrackUncaughtExceptions = true;

			// Initialize tracker.
			Tracker = Gai.SharedInstance.GetTracker (TrackingId);
			Tracker.Set (GaiConstants.ScreenName, "Start");
			Tracker.Send (DictionaryBuilder.CreateScreenView ().Build ());

			CheckSecKeychain ();
			LoadApplication (new App ());


			return base.FinishedLaunching (app, options);
		}

		/// <summary>
		/// Initializes the dependency services.
		/// </summary>
		private void InitializeDependencyServices ()
		{
			PhoneCallService.Init ();
			UserCredentialsService.Init ();
			EmailService.Init ();
			DeviceInfoService.Init ();
			TrackerService.Init ();
		}

		/// <summary>
		/// Checks the sec keychain and clears if when the app is first installed
		/// </summary>
		private void CheckSecKeychain()
		{
			string appInstalledKey = "AppInstalled";
			var appInstalled = NSUserDefaults.StandardUserDefaults.BoolForKey (appInstalledKey);

			if (!appInstalled) 
			{
				var userCredentialsService = new UserCredentialsService ();
				userCredentialsService.RemovePasswordSecRecord ();
				NSUserDefaults.StandardUserDefaults.SetBool (true, appInstalledKey); 
				NSUserDefaults.StandardUserDefaults.Synchronize ();
			}
		}
	}
}

