using System;

using Xamarin.Forms;
using BBOSMobile.Core.Interfaces;
using System.Diagnostics;

namespace BBOSMobile.Forms
{
	public class BaseContentPage : ContentPage
	{
		private bool ShouldKeepContent { get; set; }

		protected override void OnDisappearing ()
		{
            Debug.WriteLine("BaseContentPage is disappearing");

			base.OnDisappearing ();
			if (!ShouldKeepContent) 
			{
				this.Content = null;
				this.BindingContext = null;
			}
			var ignore = DelayedGCAsync();
		}

		/// <summary>
		/// Delayeds the GC async.
		/// </summary>
		/// <returns>The GC async.</returns>
		protected static async System.Threading.Tasks.Task DelayedGCAsync()
		{
			await System.Threading.Tasks.Task.Delay(2000);
			GC.Collect();
		}

		/// <summary>
		/// Determines whether to clear the content of the view.
		/// </summary>
		/// <returns><c>true</c>, if clear content was shoulded, <c>false</c> otherwise.</returns>
		/// <param name="viewModelShouldKeepContent">If set to <c>true</c> view model should keep content.</param>
		protected bool ShouldClearContent (bool viewModelShouldKeepContent)
		{
			var returnValue = false;

			if (viewModelShouldKeepContent && Device.OS == TargetPlatform.iOS) 
			{
				ShouldKeepContent = true;
				returnValue = false;
			}
            else if (viewModelShouldKeepContent && Device.OS == TargetPlatform.Android)
            {
                ShouldKeepContent = true;
                returnValue = false;
            }
            else 
			{
				ShouldKeepContent = false;
				returnValue = true;
			}

			return returnValue;
		}

		protected void DisplayErrorLoadingAlert()
		{
			DisplayAlert ("BBOS Mobile", "Error Loading Page - Please check your Internet Connection and try again.", "OK");
		}
	}
}





