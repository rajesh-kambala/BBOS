using BBOSMobile.Forms.ViewModels;
using System;

using Xamarin.Forms;


namespace BBOSMobile
{
	public class LoginPage : ContentPage
	{
		public LoginPage()
		{
			BindingContext = new LoginViewModel();

			this.SetBinding (ContentPage.TitleProperty, "Login");

			NavigationPage.SetHasNavigationBar (this, true);
			var label = new Label { Text = "Image Here" };
			var loginErrorLabel = new Label { Text = "Invalid Login, please try again or contact Customer Service at 630.668.3500 for assistance.", TextColor = Color.Red, IsVisible = false };
			var emailErrorLabel = new Label { Text = "Valid email address is required", TextColor = Color.Transparent };
			var passErrorLabel = new Label { Text = "Password is required", TextColor = Color.Transparent };


			var emailEntry = new Entry {Text = "Email",};
			emailEntry.SetBinding (Entry.TextProperty, "Email");
		
			var passEntry = new Entry ();
			passEntry.SetBinding (Entry.TextProperty, "Password");
			passEntry.IsPassword = true;


			var loginButton = new Button { Text = "Login" };
			loginButton.Clicked += (sender, e) => {
				var vm = (LoginViewModel)BindingContext;
				var validForm = true;
				if(string.IsNullOrEmpty(vm.Email)){
					emailErrorLabel.TextColor = Color.Red;
					validForm = false;
				}
				if(string.IsNullOrEmpty(vm.Password)){
					passErrorLabel.TextColor = Color.Red;
					validForm = false;
				}
				if (validForm){
					//attempt login service
					if (1==2){
						//store User Object encrypted on device

						//redirect to dashboard
						var page = new ForgotPassword();
						this.Navigation.PushModalAsync(page);

					}
					else{
						loginErrorLabel.IsVisible = true;
					}

				}
			};



			var forgotButton = new Button { Text = "Forgot Password" };
			forgotButton.Clicked += (sender, e) => {
				var page = new ForgotPassword();
				this.Navigation.PushModalAsync(page);
			};
				

			Content = new StackLayout {
				VerticalOptions = LayoutOptions.StartAndExpand,
				Padding = new Thickness(20),
				Children = {
					label, emailEntry, emailErrorLabel, passEntry, passErrorLabel, loginButton, loginErrorLabel, forgotButton
				}
			};
		}
	}
}


