using BBOSMobile.ServiceModels.Common;
using System;
using System.Collections.Generic;

namespace BBOSMobile.ServiceModels.Responses
{
    public class GetWatchdogGroupResponse: ResponseBase
    {
        public IEnumerable<WatchdogGroup> WatchdogGroups { get; set; }

		public int ResultCount { get; set; }
    }
}
