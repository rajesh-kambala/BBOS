using System.Collections.Generic;
using BBOSMobile.ServiceModels.Common;


namespace BBOSMobile.ServiceModels.Requests
{
    public class SaveCompanyToWatchdogGroupRequest: RequestBase
    {
        public IEnumerable<int> WatchdogGroupIds { get; set; }

        public string BBID { get; set; }
    }
}
