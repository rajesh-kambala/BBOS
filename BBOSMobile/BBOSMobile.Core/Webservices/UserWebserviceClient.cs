using System;
using System.Threading.Tasks;

using Xamarin.Forms;
using BBOSMobile.Core.Interfaces;
using BBOSMobile.Core.Models;
using BBOSMobile.ServiceModels.Common;
using BBOSMobile.ServiceModels.Requests;
using BBOSMobile.ServiceModels.Responses;

namespace BBOSMobile.Core.WebServices
{
	public class UserWebserviceClient : WebserviceClientBase
	{
		private const string userApiBaseAddress = apiBaseAddress + "user/";
		private const string loginRequestURI = "login";
		private const string sendPasswordRequestURI = "getpassword";
		private const string getTermsRequestURI = "getterms";
		private const string saveTermsRequestURI = "saveterms";

		/// <summary>
		/// Gets the terms.
		/// </summary>
		/// <returns>The terms.</returns>
		public async Task<GetTermsResponse> GetTerms(UserCredentials userCredentials) 
		{
			var requestBase = new RequestBase ();
			requestBase.UserId = userCredentials.UserId;

			return  await GetServiceResponse<RequestBase, GetTermsResponse> (userApiBaseAddress, getTermsRequestURI, requestBase);
		}

		/// <summary>
		/// Login the specified loginRequest.
		/// </summary>
		/// <param name="loginRequest">Login request.</param>
		public async Task<LoginResponse> Login (LoginRequest loginRequest) 
		{
			var response = await GetServiceResponse<LoginRequest, LoginResponse> (userApiBaseAddress, loginRequestURI, loginRequest);
			return response; 
		}

		/// <summary>
		/// Save Terms.
		/// </summary>
		/// <returns></returns>
		/// <param name="saveTerms">.</param>
		public async Task<SendPasswordResponse> SendPassword (SendPasswordRequest sendPasswordRequest) 
		{
			return  await GetServiceResponse<SendPasswordRequest, SendPasswordResponse> (userApiBaseAddress, sendPasswordRequestURI, sendPasswordRequest);
		}

		/// <summary>
		/// Sends the password.
		/// </summary>
		/// <returns>The password.</returns>
		/// <param name="sendPasswordRequest">Send password request.</param>
		public async Task<SaveTermsResponse> SaveTerms () 
		{
			var userCredentials = DependencyService.Get<IUserCredentialsService> ().GetUserCredentials ();
			var userId = userCredentials.UserId;
			var request = new SaveTermsRequest ();
			request.UserId = userId;
			return  await GetServiceResponse<SaveTermsRequest, SaveTermsResponse> (userApiBaseAddress, saveTermsRequestURI, request);
		}
	}
}

