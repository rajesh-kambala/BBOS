using System;

using Xamarin.Forms;

namespace BBOSMobile.Forms.Common
{
	public static class Constants
	{
		// Alert Constants
		public static string AlertTitle { get { return "Blue Book Online Services"; } }
		public static string AlertOk { get { return "Ok"; } }

		public static string InvalidLoginAlertMessage { get { return "Invalid BBOS Login, please try again or contact Customer Service at 630.668.3500 for assistance."; } }
		public static string InvalidEmailAccountAlertMessage { get { return "Invalid BBOS Email Account, please try again or contact Customer Service at 630.668.3500 for assistance."; } }
		public static string InvalidPermissionAlertMessage { get { return "This feature is included with an upgraded Blue Book Service level. Please contact Customer Service at 630-668-3500 for assistance."; } }
		public static string InvalidEmailSetupAlertMessage { get { return "Device is unable to send email in its current state."; } }
	}
}


