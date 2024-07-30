using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Xamarin.Forms;
using BBOSMobile.Core.Interfaces;
using BBOSMobile.Core.Models;
using System.Diagnostics;
using BBOSMobile.ServiceModels.Common;
using System.Text;
using System.Threading;
using BBOSMobile.ServiceModels.Requests;
//using Xamarin.Android.Net;
using System.Net;

namespace BBOSMobile.Core.WebServices
{
	public class WebserviceClientBase
	{
        //protected const string apiBaseAddress = "https://qa.mobileservicesbluebook.com/v1/api/"; //new azure site for DEV
        protected const string apiBaseAddress = "https://mobileservicesbluebook.com/v1/api/";  //new azure site for PRODUCTION

        //protected const string apiBaseAddress = "https://qa.mobileservicesbluebook.com/V1/api/";

        //protected const string apiBaseAddress = "https://qa.apps.bluebookservices.com/BBOSMobileServices/api/";//good working qa env in 2016
        //protected const string apiBaseAddress = "https://apps.bluebookservices.com/BBOSMobileServices/api/";

        


        /// <summary>
        /// Creates the client.
        /// </summary>
        /// <returns>The client.</returns>
        /// <param name="serviceURl">Service U rl.</param>
        private HttpClient CreateClient (string serviceURl)
		{
            
            
            var httpClient = new HttpClient();
            httpClient.BaseAddress = new Uri(serviceURl);

            // JsonHttpClient will always Accept JSON
            httpClient.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));


            //var httpClient = new HttpClient();
            //httpClient.BaseAddress = new Uri(serviceURl);

          

   //         _httpClient.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue(MEDIA_TYPE));
   //         httpClient.DefaultRequestHeaders.Accept.Clear ();
			//httpClient.DefaultRequestHeaders.Accept.Add (new MediaTypeWithQualityHeaderValue("application/json"));

			return httpClient;
		}

		/// <summary>
		/// Gets the service response.
		/// </summary>
		/// <returns>The service response.</returns>
		/// <param name="baseURI">Base UR.</param>
		/// <param name="requestURI">Request UR.</param>
		/// <typeparam name="T">The 1st type parameter.</typeparam>
		public async Task<T> GetServiceResponse<T> (string baseURI, string requestURI)
		{
			using (var httpClient = CreateClient (baseURI)) 
			{
				var response = await httpClient.GetAsync (requestURI).ConfigureAwait(false);
				if (response.IsSuccessStatusCode) 
				{
					var json = await response.Content.ReadAsStringAsync ().ConfigureAwait(false);
					if (!string.IsNullOrWhiteSpace (json)) 
					{
						return await Task.Run (() => 
							JsonConvert.DeserializeObject<T>(json)
						).ConfigureAwait(false);
					}
				}
			}

			return default(T);
		}

		/// <summary>
		/// Posts the service response.
		/// </summary>
		/// <returns>The service response.</returns>
		/// <param name="baseURI">Base UR.</param>
		/// <param name="requestURI">Request UR.</param>
		/// <param name="requestModel">Request model.</param>
		/// <typeparam name="T">The 1st type parameter.</typeparam>
		/// <typeparam name="V">The 2nd type parameter.</typeparam>
		public async Task<T> GetServiceResponse<V, T> (string baseURI, string requestURI, V requestModel) where T: BBOSMobile.ServiceModels.Common.ResponseBase
		{
            //TestCall();
            HttpClient client = new HttpClient();
            client.BaseAddress = new Uri(baseURI);

            Debug.WriteLine("baseURI:" + baseURI);
            Debug.WriteLine("requestURI:" + requestURI);
            
         


            string serialized = JsonConvert.SerializeObject(requestModel);


            var inputMessage = new HttpRequestMessage
            {
                Content = new StringContent(serialized, Encoding.UTF8, "application/json")
            };

            inputMessage.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));


            try
            {
                Debug.WriteLine("before postasync");

                var response = client.PostAsync(requestURI, inputMessage.Content).Result;

                if (response.IsSuccessStatusCode)
                {
                    var json = await response.Content.ReadAsStringAsync();
                    Debug.WriteLine("json coming back:" + json);
                    if (!string.IsNullOrWhiteSpace(json))
                    {
                        Debug.WriteLine("start json deserial");
                        var returnT = JsonConvert.DeserializeObject<T>(json);
                        Debug.WriteLine("finished json deserial");
                        Debug.WriteLine("starting CheckUserLevel");
                        CheckUserLevel(returnT.UserAccessInfo); // Update UserLevel if it changed
                        Debug.WriteLine("finished CheckUserLevel");
                        //updating terms
                        if (returnT.UserAccessInfo != null)
                        {
                            returnT.TermsRequired = returnT.UserAccessInfo.TermsRequired;
                        }
                        return returnT;
                    }
                }
            }
            catch (Exception e)
            {
                Debug.WriteLine("caught postasync error" + e.Message);
                Debug.WriteLine("caught postasync error" + e.StackTrace);
            }



            //         using (var httpClient = CreateClient (baseURI)) 
            //{
            //	try{
            //		StringContent requestContent = new StringContent(JsonConvert.SerializeObject(requestModel), System.Text.Encoding.UTF8, "application/json");

            //                 Debug.WriteLine("baseURI:" + baseURI);
            //                 Debug.WriteLine("requestURI:" + requestURI);
            //                 Debug.WriteLine("requestContent:" + requestContent.ReadAsStringAsync().Result);

            //                 Debug.WriteLine("before postasync");
            //                 //var response2 = await httpClient.PostAsync(baseURI + requestURI, new StringContent(JsonConvert.SerializeObject(requestModel), Encoding.UTF8, "application/json"));

            //                 var response = await httpClient.PostAsync (requestURI, requestContent);
            //                 Debug.WriteLine("after postasync");
            //                 if (response.IsSuccessStatusCode) 
            //		{
            //                     var json = await response.Content.ReadAsStringAsync().ConfigureAwait(false);
            //                     //var json = await response.Content.ReadAsStringAsync ().ConfigureAwait(false);
            //			Debug.WriteLine ("json coming back:" + json);
            //			if (!string.IsNullOrWhiteSpace (json)) 
            //			{
            //                         Debug.WriteLine("start json deserial");
            //                         var returnT = JsonConvert.DeserializeObject<T> (json);
            //                         Debug.WriteLine("finished json deserial");
            //                         Debug.WriteLine("starting CheckUserLevel");
            //                         CheckUserLevel(returnT.UserAccessInfo); // Update UserLevel if it changed
            //                         Debug.WriteLine("finished CheckUserLevel");
            //                         //updating terms
            //                         if (returnT.UserAccessInfo != null) {
            //					returnT.TermsRequired = returnT.UserAccessInfo.TermsRequired;
            //				}
            //				return returnT;
            //			}
            //		}
            //	}
            //	catch(Exception e){

            //                 Debug.WriteLine("caught postasync error" + e.Message);
            //                 Debug.WriteLine("caught postasync error" + e.StackTrace);

            //                 return default(T);
            //	}

            //}
            return default(T);
		}



		/// <summary>
		/// Checks the user level.
		/// </summary>
		/// <param name="userAccessInfo">User access info.</param>
		private void CheckUserLevel(UserAccess userAccessInfo)
		{
			if (userAccessInfo != null) 
			{
				var userCredentials = DependencyService.Get<IUserCredentialsService> ().GetUserCredentials ();
				if (!String.IsNullOrEmpty(userCredentials.Email)) //first time in.
				{
					var newUserCredentials = new UserCredentials {
						Email = userCredentials.Email,
						Password = userCredentials.Password,
						UserId = userCredentials.UserId,
						UserType = userCredentials.UserType,
						UserLevel = userAccessInfo.UserLevel,
						SecurityPrivileges = userAccessInfo.SecurityPrivileges,
						UserBBID = userCredentials.UserBBID,
						UserRelatedBBIDs=userCredentials.UserRelatedBBIDs



					};	
					DependencyService.Get<IUserCredentialsService> ().SetUserCredentials (newUserCredentials);
				}
			}
		}

        public void TestCall()
        {
            
            HttpClient client = new HttpClient();
            

            client.DefaultRequestHeaders.Add("Accept", "application/json");
            client.DefaultRequestHeaders.Add("User-Agent", "BBOS");
            string apiUrl = @"https://mobileservicesbluebook.com/v1/api/user/login";
            LoginRequest request = new LoginRequest();
            request.Email = "cwalls@travant.com";
            request.Password = "Blu3B0ok";

            string serialized = JsonConvert.SerializeObject(request);
                
            var inputMessage = new HttpRequestMessage
            {
                Content = new StringContent(serialized, Encoding.UTF8, "application/json")
            };

            inputMessage.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            
            
            try
            {
                var message = client.PostAsync(apiUrl, inputMessage.Content).Result;

                if (message.IsSuccessStatusCode)
                {
                    var apiResponse = message.Content.ReadAsStringAsync();

                    var test = JsonConvert.DeserializeObject<UserCredentials>(apiResponse.Result);

                   
                }
            }
            catch (Exception e)
            {
                Debug.WriteLine("caught postasync error" + e.Message);
                Debug.WriteLine("caught postasync error" + e.StackTrace);
            }
        }
    }
}

