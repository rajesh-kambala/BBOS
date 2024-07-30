using System;

using BBOSMobile.Core.Data;

namespace BBOSMobile.Core.Models
{
	public class Terms : BusinessEntityBase
	{
		public string TermsText { get; set; }

		public DateTime TermDate { get; set; }

		public string TermsVersion { get; set; }
	}
}

