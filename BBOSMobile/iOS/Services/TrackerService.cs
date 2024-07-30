using System.Collections.Generic;

using MessageUI;
using UIKit;
using Xamarin.Forms;
using BBOSMobile.Core;
using BBOSMobile.Core.Interfaces;
using BBOSMobile.Core.Models;
using BBOSMobile.iOS;
using BBOSMobile.iOS.Services;
using Google.Analytics;

[assembly: Dependency(typeof(TrackerService))]
namespace BBOSMobile.iOS.Services
{
	public class TrackerService : ITrackerService
	{
		

		/// <summary>
		/// Used for registration with dependency service
		/// </summary>
		public static void Init ()
		{
			
		}
			
		public void TrackScreen (string screen) {
			try{
				// Google track screen
				var tracker = Gai.SharedInstance.DefaultTracker;
				tracker.Set (GaiConstants.ScreenName, screen);
				tracker.Send (DictionaryBuilder.CreateScreenView ().Build ());

			}
			catch
			{
				
			}

		}

		public void TrackScreen(string screen, Dictionary<string, string> args) {
			//Debug.WriteLine ("TrackScreen Dict iOS: " + screen);
			var tracker = Gai.SharedInstance.DefaultTracker;
			tracker.Set (GaiConstants.ScreenName, screen);

			tracker.Set (GaiConstants.EventCategory, screen);
			foreach (var a in args) {
				// tracker.Set (a.Key, a.Value);
				tracker.Set (GaiConstants.EventAction, a.Key);
				tracker.Set (GaiConstants.EventLabel, a.Value);
			}
			tracker.Send (DictionaryBuilder.CreateScreenView ().Build ());

			//Insights.Track(screen, args);
		}

	}
}

