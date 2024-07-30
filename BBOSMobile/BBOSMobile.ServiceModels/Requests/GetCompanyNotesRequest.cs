using BBOSMobile.ServiceModels.Common;
using System;

namespace BBOSMobile.ServiceModels.Requests
{
	public class GetCompanyNotesRequest: RequestBase
	{
		public int BBID { get; set; }
	}
}


