using System;

using Xamarin.Forms;

namespace BBOSMobile
{
	public class MasterPage : ContentPage
	{
		public MasterPage ()
		{
			Content = new StackLayout { 
				Children = {
					new Label { Text = "Hello ContentPage" }
				}
			};
		}
	}
}


