using System;
using System.Collections.Generic;
using System.Threading.Tasks;

using Xamarin.Forms;
using BBOSMobile.Core;
using BBOSMobile.Core.WebServices;
using BBOSMobile.ServiceModels.Requests;
using BBOSMobile.ServiceModels.Responses;
using BBOSMobile.ServiceModels.Common;
using BBOSMobile.Core.Interfaces;
using System.Diagnostics;
using System.ComponentModel;

namespace BBOSMobile.Forms.Pages
{
	public partial class ForgotPassword : BaseContentPage
	{
		ForgotPasswordViewModel viewModel;
		public ForgotPassword ()
		{
            Debug.WriteLine("before initialize forgot password");

			InitializeComponent ();
			//ITrackerService service = App.TrackerService;
			//service.TrackScreen ("Company Search Results");

            Debug.WriteLine("before new ForgotPasswordViewModel");

            viewModel = new ForgotPasswordViewModel();
			this.BindingContext = viewModel; 
		}

		void OnForgetPasswordButtonClicked(object sender, EventArgs args)
		{

            Debug.WriteLine("OnForgetPasswordButtonClicked");

            ExecuteForgotPassword();
		}

		void EmailPropertyChanged(object sender, PropertyChangedEventArgs args)
		{

            try
            {


                Debug.WriteLine("EmailPropertyChanged event just started");

                Debug.WriteLine("txtEmail.Placeholder:" + txtEmail.Placeholder);

                Debug.WriteLine("lblEmailError text:" + lblEmailError.Text);


                Debug.WriteLine("lblEmailError.TextColor:" + lblEmailError.TextColor);

                lblEmailError.TextColor = Color.Transparent;

            }
            catch(Exception ex)
            {
                Debug.WriteLine("emailpropchanged exception:" + ex.Message);
            }
            Debug.WriteLine("EmailPropertyChanged event just ended");

        }

        async Task ExecuteForgotPassword(){

            Debug.WriteLine("ExecuteForgotPassword");

            bool validForm = true;
			if (string.IsNullOrEmpty (viewModel.Email)) 
			{
				lblEmailError.TextColor = Color.Red;
				validForm = false;
			}



			if (validForm) 
			{
                Debug.WriteLine("validForm");

                var forgotPasswordRequest = await ForgotPasswordRequest ();
                
                if (forgotPasswordRequest)
				{
                    Debug.WriteLine("forgotPasswordRequest");
                    await this.Navigation.PopModalAsync (false);
				} 
				else 
				{
					await DisplayAlert (Common.Constants.AlertTitle, Common.Constants.InvalidEmailAccountAlertMessage, Common.Constants.AlertOk);
				}
			}


		}
		void OnCancelButtonClicked(object sender, EventArgs args)
		{
			this.Navigation.PopModalAsync (true);
		}

		/// <summary>
		/// Forgots the password request.
		/// </summary>
		/// <returns><c>true</c>, if password request was forgoted, <c>false</c> otherwise.</returns>
		private async Task<bool> ForgotPasswordRequest()
		{
			bool returnValue = true;


			try
			{


				var userWebServiceClient = new UserWebserviceClient ();
				var sendPasswordRequest = new SendPasswordRequest ();
				sendPasswordRequest.Email = viewModel.Email;
				var sendPasswordResponse = await userWebServiceClient.SendPassword (sendPasswordRequest);

				if (sendPasswordResponse.ResponseStatus != Enumerations.ResponseStatus.Failure) 
				{
					var status = sendPasswordResponse.ResponseStatus;
					var message = sendPasswordResponse.ErrorMessage;
				}
				else{
					await DisplayAlert ("BBOS Mobile", "Email Address Not Found.", "OK");
					returnValue = false;
				}
			} catch(Exception ex) {
				returnValue = false;
				DisplayErrorLoadingAlert ();
			}
				
			return returnValue;
		}
	}
}

