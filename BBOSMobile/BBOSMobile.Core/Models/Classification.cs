using System;

using BBOSMobile.Core.Data;

namespace BBOSMobile.Core.Models
{
	public class Classification : BusinessEntityBase
	{
		public int ClassificationId { get; set; }

		public string Abbreviation { get; set; }

		public string Description { get; set; }

		public string Definition { get; set; }

		public string IndustryType { get; set; }
	}
}


