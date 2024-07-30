using System;
using System.Collections.Generic;

namespace BBOSMobile.ServiceModels.Common
{
	public class Classification : LookUpListBase
	{
		public string Abbreviation { get; set; }

		public string Description { get; set; }

		public string Definition { get; set; }

		public string IndustryType { get; set; }
	}
}
