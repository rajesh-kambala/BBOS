using System;
using BBOSMobile.ServiceModels.Common;

namespace BBOSMobile.ServiceModels.Requests
{
	public class WatchdogUpdateRequest: RequestBase
	{
		public int BBID { get; set; }
		public int WatchdogID { get; set; }

	}
}
