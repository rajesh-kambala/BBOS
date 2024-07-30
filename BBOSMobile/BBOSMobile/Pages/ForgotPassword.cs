using System;

using Xamarin.Forms;

namespace BBOSMobile
{
	public class ForgotPassword : ContentPage
	{
		public ForgotPassword ()
		{
			Content = new StackLayout { 
				Children = {
					new Label { Text = "Hello Forgot Password" }
				}
			};
		}
	}
}


