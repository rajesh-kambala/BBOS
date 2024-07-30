using System;

using Xamarin.Forms;

namespace BBOSMobile.Forms.Common
{
	public static class Utils
	{
		/// <summary>
		/// Gets the navigation page.
		/// </summary>
		/// <returns>The navigation page.</returns>
		/// <param name="page">Page.</param>
		public static NavigationPage GetNavigationPage(Page page)
		{
			var navigationPage = new NavigationPage (page);

			navigationPage.BarBackgroundColor = Color.FromRgb (8,57,135);
			navigationPage.BarTextColor = Color.White;

			return navigationPage;
		}
	}
}

