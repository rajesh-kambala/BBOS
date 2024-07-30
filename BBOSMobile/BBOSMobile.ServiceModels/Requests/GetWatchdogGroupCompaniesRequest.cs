using BBOSMobile.ServiceModels.Common;
using System;
using System.Collections.Generic;

namespace BBOSMobile.ServiceModels.Requests
{
    public class GetWatchdogGroupCompaniesRequest: RequestBase
    {
        public int WatchdogGroupId { get; set; }
    }
}
