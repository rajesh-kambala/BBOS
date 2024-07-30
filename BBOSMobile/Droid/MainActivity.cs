
using Android.App;
using Android.Content.PM;
using Android.OS;
using BBOSMobile.Droid.Services;
using BBOSMobile.Forms;
using Xamarin.Forms.Platform.Android;
using static Android.Telephony.CarrierConfigManager;

namespace BBOSMobile.Droid
{
    //Theme="@android:style/Theme.Holo.Light"
    [Activity (Theme="@android:style/Theme.Holo.Light", Label = "BBOS Mobile", Icon = "@drawable/icon", MainLauncher = true, ConfigurationChanges = ConfigChanges.ScreenSize | ConfigChanges.Orientation)]
	public class MainActivity : global::Xamarin.Forms.Platform.Android.FormsApplicationActivity
    {
		protected override void OnCreate (Bundle bundle)
		{

            base.OnCreate (bundle);

			global::Xamarin.Forms.Forms.Init (this, bundle);
			InitializeDependencyServices ();

            LoadApplication(new App());
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
	}
}

