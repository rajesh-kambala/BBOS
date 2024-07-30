using System;

namespace BBOSMobile.ServiceModels.Requests
{
	public class GetWatchdogGroupRequest
	{
		public Guid UserId { get; set; }

		public int BBID { get; set; }
	}
}

