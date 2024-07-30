using System;
using System.Collections.Generic;
using System.Linq;
using System.Collections.ObjectModel;

using Xamarin.Forms;
using BBOSMobile.Core.Interfaces;
using BBOSMobile.ServiceModels.Common;
using BBOSMobile.ServiceModels.Requests;
using BBOSMobile.ServiceModels.Responses;
using BBOSMobile.Core.WebServices;
using BBOSMobile.ServiceModels;
using System.Threading.Tasks;


namespace BBOSMobile.Core
{
	public class ContactWebserviceClient : WebserviceClientBase
	{
		//private const string ApiBaseAddress = "http://api.tekconf.com/v1/";
		//private const string RequestURI = "conferences";

		private const string userApiBaseAddress = apiBaseAddress + "contact/";
		private const string getContactRequestURI = "getContact";
		private const string getContactQuickFindRequestURI = "quickfind";
		private const string getContactRecentlyViewedRequestURI = "getrecentlyviewed";
		private const string getContactSearchURI = "search";
		private const string getContactNotesURI = "getcontactnotes";
		private const string getContactContactsURI = "getcontactcontacts";
		private const string saveContactNoteURI = "savecontactnote";
		//private const string saveContactNoteURI = "savecontactnote";

		//GetContact
		public async Task<GetContactResponse> GetContact(int ContactID, int BBID) 
		{
			var userCredentials = DependencyService.Get<IUserCredentialsService> ().GetUserCredentials ();
			var userId = userCredentials.UserId;

			var request = new GetContactRequest ();
			request.UserId = userId;
			request.ContactID = ContactID;
            request.BBID = BBID;
			var response = await GetServiceResponse<GetContactRequest, GetContactResponse> (userApiBaseAddress, getContactRequestURI, request);
			return response;
		}

		public async Task<GetRecentlyViewedResponse> GetRecentlyViewedContacts()
		{
			//return GetCompaniesMockData(searchText);
			var userCredentials = DependencyService.Get<IUserCredentialsService> ().GetUserCredentials ();
			var userId = userCredentials.UserId;

			var request = new GetRecentlyViewedRequest ();
			request.UserId = userId;


			var response = await GetServiceResponse<GetRecentlyViewedRequest, GetRecentlyViewedResponse> (userApiBaseAddress, getContactRecentlyViewedRequestURI, request);
			return response;
		}

		public async Task<ContactSearchResponse> GetContacts(ContactSearchRequest request){
			var userCredentials = DependencyService.Get<IUserCredentialsService> ().GetUserCredentials ();
			if (userCredentials.UserType == BBOSMobile.ServiceModels.Common.Enumerations.UserType.Lumber) {
				request.IndustryType = Enumerations.IndustryType.Lumber;
			}
			var userId = userCredentials.UserId;

			request.UserId = userId;
			var response = await GetServiceResponse<ContactSearchRequest, ContactSearchResponse> (userApiBaseAddress, getContactSearchURI, request);

			if (response != null) 
			{
				if (response.Contacts != null) 
				{
					for (var i = 0; i < response.Contacts.Count (); i++) 
					{
						response.Contacts.ElementAt (i).Index = i;
					}
				}
			}

			return response;


		}

		public async Task<QuickFindSearchResponse> GetCompanies(string searchText, int pageIndex, int pageSize)
		{
			var userCredentials = DependencyService.Get<IUserCredentialsService> ().GetUserCredentials ();
			var userId = userCredentials.UserId;

			var request = new QuickFindSearchRequest ();
			request.SearchText = searchText;
			request.UserId = userId;
			request.PageIndex = pageIndex;
			request.PageSize = pageSize;

			var response = await GetServiceResponse<QuickFindSearchRequest, QuickFindSearchResponse> (userApiBaseAddress, getContactQuickFindRequestURI, request);

			if (response != null) 
			{
				if (response.Companies != null) 
				{
					for (var i = 0; i < response.Companies.Count (); i++) 
					{
						response.Companies.ElementAt (i).Index = i;
					}
				}
			}

			return response;
		}
/*
		public async Task<GetContactNotesResponseModel> GetContactNotes(int BBID)
		{
			var userCredentials = DependencyService.Get<IUserCredentialsService> ().GetUserCredentials ();
			var userId = userCredentials.UserId;

			var request = new GetContactNotesRequest ();
			request.UserId = userId;
			request.BBID = BBID;


			var response = await GetServiceResponse<GetContactNotesRequest, GetContactNotesResponseModel> (userApiBaseAddress, getContactNotesURI, request);
			return response;
		}

		public async Task<GetContactContactsResponseModel> GetContactContacts(int BBID)
		{
			var userCredentials = DependencyService.Get<IUserCredentialsService> ().GetUserCredentials ();
			var userId = userCredentials.UserId;

			var request = new GetContactContactsRequest ();
			request.UserId = userId;
			request.BBID = BBID;


			var response = await GetServiceResponse<GetContactContactsRequest, GetContactContactsResponseModel> (userApiBaseAddress, getContactContactsURI, request);
			return response;
		}
*/
		public async Task<SaveContactNoteReponse>  SaveContactNote (SaveContactNoteRequest request) 
		{
			var response = await GetServiceResponse<SaveContactNoteRequest, SaveContactNoteReponse> (userApiBaseAddress, saveContactNoteURI, request);
			return response;
		}
        /*
                public async Task<SaveContactNoteReponse>  SaveContactNote (SaveContactNoteRequest request) 
                {
                    var response = await GetServiceResponse<SaveContactNoteRequest, SaveContactNoteReponse> (userApiBaseAddress, saveContactNoteURI, request);
                    return response;
                }
                */
    }

}

