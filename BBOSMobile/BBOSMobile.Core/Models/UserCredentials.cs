using System;
using BBOSMobile.ServiceModels.Common;
using System.Collections.Generic;

namespace BBOSMobile.Core.Models
{
	public class UserCredentials
	{
		public string Email { get; set; }
		public string Password { get; set; }
		public Guid UserId { get; set; }
		public bool TermsRequired { get; set; }
		public Enumerations.UserType UserType { get; set; }
		public Enumerations.UserLevel UserLevel { get; set; }
		public List<SecurityResult> SecurityPrivileges { get; set; }

		public IEnumerable<int> UserRelatedBBIDs { get; set; }
		public int UserBBID { get; set; }


	}
}

