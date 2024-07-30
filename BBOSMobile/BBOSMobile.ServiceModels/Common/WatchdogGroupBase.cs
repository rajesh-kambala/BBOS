using System;

namespace BBOSMobile.ServiceModels.Common
{
	public class WatchdogGroupBase
	{
		public int WatchdogGroupId { get; set; }

		public string Name { get; set; }

		public bool IsPrivate { get; set; }

		public int Count { get; set; }

		public bool InGroup { get; set; }

	}
}

