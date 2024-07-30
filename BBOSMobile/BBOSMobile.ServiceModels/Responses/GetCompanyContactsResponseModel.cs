using BBOSMobile.ServiceModels.Common;
using System;
using System.Collections.Generic;

namespace BBOSMobile.ServiceModels.Responses
{
	public class GetCompanyContactsResponseModel: ResponseBase
	{
		public IEnumerable<Contact> Contacts { get; set; }
	}
}




