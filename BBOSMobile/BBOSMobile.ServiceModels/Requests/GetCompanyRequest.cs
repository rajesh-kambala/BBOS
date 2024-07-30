using BBOSMobile.ServiceModels.Common;
using System;

namespace BBOSMobile.ServiceModels.Requests
{
    public class GetCompanyRequest: RequestBase
    {
        public int BBID { get; set; }
    }
}
