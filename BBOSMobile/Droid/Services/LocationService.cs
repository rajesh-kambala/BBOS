using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

using Android.Locations;
using Xamarin.Forms;
using BBOSMobile.Core.Interfaces;
using BBOSMobile.Droid.Services;

[assembly: Dependency(typeof(LocationService))]
namespace BBOSMobile.Droid.Services
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
				Geocoder geocoder = new Geocoder (Android.App.Application.Context);
				IList<Address> addressList = await geocoder.GetFromLocationAsync (postion.Latitude, postion.Longitude, 10);
				Address address = addressList.FirstOrDefault ();

				if (address != null) {
					returnPostalCode = address.PostalCode;
				}
			} else {
				return "LOCATIONDISABLED";
			}


			return returnPostalCode;
		}
	}
}

