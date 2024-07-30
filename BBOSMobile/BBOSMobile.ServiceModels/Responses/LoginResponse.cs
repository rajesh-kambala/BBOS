using System;
using System.Collections.Generic;
using BBOSMobile.ServiceModels.Common;

namespace BBOSMobile.ServiceModels.Responses
{
	public class LoginResponse : ResponseBase
	{
		public Guid UserId { get; set; }

		public CategoryLists CategoryListsItems { get; set; }

		public Enumerations.UserType UserType { get; set; }

		public int BBID;

		public IEnumerable<int> RelatedBBIDs { get; set; }
	}
}

