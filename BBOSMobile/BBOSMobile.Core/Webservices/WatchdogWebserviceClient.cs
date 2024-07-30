using System;
using System.Collections.Generic;
using System.Threading.Tasks;

using Xamarin.Forms;
using BBOSMobile.Core.Interfaces;
using BBOSMobile.Core.WebServices;
using BBOSMobile.ServiceModels;
using BBOSMobile.ServiceModels.Common;
using BBOSMobile.ServiceModels.Requests;
using BBOSMobile.ServiceModels.Responses;

namespace BBOSMobile.Core
{
	public class WatchdogWebserviceClient : WebserviceClientBase
	{
		private const string userApiBaseAddress = apiBaseAddress + "watchdog/";
		private const string getWatchdogGroupRequestURI = "getgroups";
		private const string getWatchdogDetailsURI = "getgroup";
		private const string saveCompanyToWatchDogGroupURI = "savecompany";
		private const string addCompanyToWatchDogGroupURI = "addcompany";
		private const string removeCompanyToWatchDogGroupURI = "removecompany";


		public async Task<GetWatchdogGroupDetailsResponse> GetWatchdogDetails (int watchdogGroupId)
		{
			var userCredentials = DependencyService.Get<IUserCredentialsService> ().GetUserCredentials ();
			var userId = userCredentials.UserId;
			var request = new GetWatchdogGroupCompaniesRequest ();
			request.UserId = userId;
			request.WatchdogGroupId = watchdogGroupId;

			var response = await GetServiceResponse<GetWatchdogGroupCompaniesRequest, GetWatchdogGroupDetailsResponse> (userApiBaseAddress, getWatchdogDetailsURI, request);
			return response;
		}
		public async Task<SaveCompanyToWatchdogGroupResponse>  SaveCompanyToWatchDogGroups (SaveCompanyToWatchdogGroupRequest request) 
		{
			var response = await GetServiceResponse<SaveCompanyToWatchdogGroupRequest, SaveCompanyToWatchdogGroupResponse> (userApiBaseAddress, saveCompanyToWatchDogGroupURI, request);
			return response;
		}
		public async Task<WatchdogUpdateResponse>  AddCompanyToWatchDogGroup (WatchdogUpdateRequest request) 
		{
			var response = await GetServiceResponse<WatchdogUpdateRequest, WatchdogUpdateResponse> (userApiBaseAddress, addCompanyToWatchDogGroupURI, request);
			return response;
		}
		public async Task<WatchdogUpdateResponse>  RemoveCompanyFromWatchDogGroup (WatchdogUpdateRequest request) 
		{
			var response = await GetServiceResponse<WatchdogUpdateRequest, WatchdogUpdateResponse> (userApiBaseAddress, removeCompanyToWatchDogGroupURI, request);
			return response;
		}
		public async Task<GetWatchdogGroupResponse> GetWatchdogs (int BBID)
		{
			var userCredentials = DependencyService.Get<IUserCredentialsService> ().GetUserCredentials ();
			var userId = userCredentials.UserId;
			var request = new GetWatchdogGroupRequest ();
			request.UserId = userId;
			if (BBID > 0) {
				request.BBID = BBID;
			}

			var response = await GetServiceResponse<GetWatchdogGroupRequest, GetWatchdogGroupResponse> (userApiBaseAddress, getWatchdogGroupRequestURI, request);
			return response;
		}
			
	}
}

