using System;
using System.Collections.Generic;

using Android.Content;
using Xamarin.Forms;
using BBOSMobile.Core;
using BBOSMobile.Core.Interfaces;
using BBOSMobile.Core.Models;
using BBOSMobile.Droid;
using BBOSMobile.Droid.Services;
using Android.Content.PM;
//ddd - using Android.Gms.Analytics;
using BBOSMobile.Forms;


[assembly: Dependency(typeof(TrackerService))]
namespace BBOSMobile.Droid.Services
{
	public class TrackerService //: ITrackerService
	{
		const string PROPERTY_ID = "UA-65220518-1";
		public const int GENERAL_TRACKER = 0;

		public enum TrackerName {
			AppTracker,
			GlobalTracker,
			EcommerceTracker
		}
        //ddd - static Dictionary<TrackerName, Tracker> trackers = new Dictionary<TrackerName, Tracker> ();

        public static void Init ()
		{
		}
        //ddd - 
//        public static Tracker GetTracker (TrackerName trackerId) 
//		{
//			if (!trackers.ContainsKey (trackerId)) {
//				//var analytics = GoogleAnalytics.GetInstance (Context);
//				GoogleAnalytics analytics = GoogleAnalytics.GetInstance(Android.App.Application.Context);

			
//				analytics.Logger.LogLevel = LoggerLogLevel.Verbose;

//				Tracker t;
//				t = analytics.NewTracker (PROPERTY_ID);
////				if (trackerId == TrackerName.AppTracker)
////					t = analytics.NewTracker (PROPERTY_ID);
////				else if (trackerId == TrackerName.GlobalTracker)
////					t = analytics.NewTracker (Resource.Xml.global_tracker);
////				else
////					t = analytics.NewTracker (Resource.Xml.ecommerce_tracker);

//				t.EnableAdvertisingIdCollection (true);

//				trackers.Add (trackerId, t);
//			}

//			return trackers [trackerId];
//		}

		//public void TrackScreen (string screen) {
		//	try{
		//		Tracker t = TrackerService.GetTracker (TrackerService.TrackerName.AppTracker);
		//		t.SetScreenName (screen);
		//		t.Send (new HitBuilders.AppViewBuilder ().Build ());
		//	}
		//	catch{

		//	}
		//}

		public void TrackScreen(string screen, Dictionary<string, string> args)
		{
			return;
		}

	}
}

