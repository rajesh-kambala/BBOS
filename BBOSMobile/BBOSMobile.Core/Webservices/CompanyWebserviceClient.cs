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
	public class CompanyWebserviceClient : WebserviceClientBase
	{
		//private const string ApiBaseAddress = "http://api.tekconf.com/v1/";
		//private const string RequestURI = "conferences";

		private const string userApiBaseAddress = apiBaseAddress + "company/";
		private const string getCompanyRequestURI = "getCompany";
		private const string getCompanyQuickFindRequestURI = "quickfind";
		private const string getCompanyRecentlyViewedRequestURI = "getrecentlyviewed";
		private const string getCompanySearchURI = "search";
		private const string getCompanyNotesURI = "getcompanynotes";
		private const string getCompanyContactsURI = "getcompanycontacts";
		private const string saveCompanyNoteURI = "savecompanynote";
		private const string saveContactNoteURI = "savecontactnote";
		private const string saveTradeReportURI = "savetradereport";

		//GetCompany
		public async Task<GetCompanyResponse> GetCompany(int BBID ) 
		{
			var userCredentials = DependencyService.Get<IUserCredentialsService> ().GetUserCredentials ();
			var userId = userCredentials.UserId;

			var request = new GetCompanyRequest ();
			request.UserId = userId;
			request.BBID = BBID;
			var response = await GetServiceResponse<GetCompanyRequest, GetCompanyResponse> (userApiBaseAddress, getCompanyRequestURI, request);
			return response;
		}

		public async Task<GetRecentlyViewedResponse> GetRecentlyViewedCompanies()
		{
			//return GetCompaniesMockData(searchText);
			var userCredentials = DependencyService.Get<IUserCredentialsService> ().GetUserCredentials ();
			var userId = userCredentials.UserId;

			var request = new GetRecentlyViewedRequest ();
			request.UserId = userId;


			var response = await GetServiceResponse<GetRecentlyViewedRequest, GetRecentlyViewedResponse> (userApiBaseAddress, getCompanyRecentlyViewedRequestURI, request);
			return response;
		}

		public async Task<CompanySearchResponse> GetCompanies(CompanySearchRequest request){
			var userCredentials = DependencyService.Get<IUserCredentialsService> ().GetUserCredentials ();
			if (userCredentials.UserType == BBOSMobile.ServiceModels.Common.Enumerations.UserType.Lumber) {
				request.IndustryType = Enumerations.IndustryType.Lumber;
			}
			var userId = userCredentials.UserId;

			request.UserId = userId;
			var response = await GetServiceResponse<CompanySearchRequest, CompanySearchResponse> (userApiBaseAddress, getCompanySearchURI, request);

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

		public async Task<QuickFindSearchResponse> GetCompanies(string searchText, int pageIndex, int pageSize)
		{
			var userCredentials = DependencyService.Get<IUserCredentialsService> ().GetUserCredentials ();
			var userId = userCredentials.UserId;

			var request = new QuickFindSearchRequest ();
			request.SearchText = searchText;
			request.UserId = userId;
			request.PageIndex = pageIndex;
			request.PageSize = pageSize;

			var response = await GetServiceResponse<QuickFindSearchRequest, QuickFindSearchResponse> (userApiBaseAddress, getCompanyQuickFindRequestURI, request);

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

		public async Task<GetCompanyNotesResponseModel> GetCompanyNotes(int BBID)
		{
			var userCredentials = DependencyService.Get<IUserCredentialsService> ().GetUserCredentials ();
			var userId = userCredentials.UserId;

			var request = new GetCompanyNotesRequest ();
			request.UserId = userId;
			request.BBID = BBID;


			var response = await GetServiceResponse<GetCompanyNotesRequest, GetCompanyNotesResponseModel> (userApiBaseAddress, getCompanyNotesURI, request);
			return response;
		}

		public async Task<GetCompanyContactsResponseModel> GetCompanyContacts(int BBID)
		{
			var userCredentials = DependencyService.Get<IUserCredentialsService> ().GetUserCredentials ();
			var userId = userCredentials.UserId;

			var request = new GetCompanyContactsRequest ();
			request.UserId = userId;
			request.BBID = BBID;


			var response = await GetServiceResponse<GetCompanyContactsRequest, GetCompanyContactsResponseModel> (userApiBaseAddress, getCompanyContactsURI, request);
			return response;
		}

		public async Task<SaveCompanyNoteReponse>  SaveCompanyNote (SaveCompanyNoteRequest request) 
		{
			var response = await GetServiceResponse<SaveCompanyNoteRequest, SaveCompanyNoteReponse> (userApiBaseAddress, saveCompanyNoteURI, request);
			return response;
		}

		public async Task<SaveContactNoteReponse>  SaveContactNote (SaveContactNoteRequest request) 
		{
			var response = await GetServiceResponse<SaveContactNoteRequest, SaveContactNoteReponse> (userApiBaseAddress, saveContactNoteURI, request);
			return response;
		}

		public async Task<SaveTradeReportResponse> SaveTradeReport(SaveTradeReportRequest request)
		{
			var response = await GetServiceResponse<SaveTradeReportRequest, SaveTradeReportResponse>(userApiBaseAddress, saveTradeReportURI, request);
			return response;
		}

	}
		
}

