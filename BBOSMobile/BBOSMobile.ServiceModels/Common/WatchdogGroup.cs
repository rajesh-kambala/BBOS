using System;
using System.Collections.Generic;

namespace BBOSMobile.ServiceModels.Common
{
	public class WatchdogGroup: WatchdogGroupBase
	{
		public IEnumerable<CompanyBase> Companies { get; set; }

		public string Description { get; set; }

		public string CreatedBy { get; set; }

		public string TypeCode {get; set;}
	}
}
