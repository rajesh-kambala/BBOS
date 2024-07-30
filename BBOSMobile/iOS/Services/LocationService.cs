using System;
using System.Threading;
using System.Threading.Tasks;

using CoreLocation;
using Foundation;
using UIKit;
using Xamarin.Forms;
using BBOSMobile.Core.Interfaces;
using BBOSMobile.iOS.Services;

[assembly: Dependency(typeof(LocationService))]
namespace BBOSMobile.iOS.Services
{
	public class LocationService : ILocationService
	{
		public async Task<string> GetCurrentPostalCode ()
		{
			string returnPostalCode = String.Empty;

			var cancelSource = new CancellationTokenSource();
			var geolocator = new Geolocator ();
			if (geolocator.IsGeolocationEnabled) {
				geolocator.DesiredAccuracy = 100;

				var postion = await geolocator.GetPositionAsync (10000, cancelSource.Token, true);
				CLGeocoder geocoder = new CLGeocoder ();
				var placeMarks = await geocoder.ReverseGeocodeLocationAsync (new CLLocation (postion.Latitude, postion.Longitude));
				if (placeMarks != null) {
					if (placeMarks.Length > 0) {
						returnPostalCode = placeMarks [0].PostalCode;
					}
				}

				return returnPostalCode;
			} else {
				return "LOCATIONDISABLED";
			}

		}
	}
}

