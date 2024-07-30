using System;

using BBOSMobile.Core.Data;

namespace BBOSMobile.Core.Models
{
	public class PrivacyStatement : BusinessEntityBase
	{
		public string PrivacyStatementText { get; set; }

		public DateTime PrivacyStatementDate { get; set; }
	}
}

