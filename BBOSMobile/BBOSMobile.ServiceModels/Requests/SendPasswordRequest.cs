using System;
using BBOSMobile.ServiceModels.Common;

namespace BBOSMobile.ServiceModels.Requests
{
    public class SendPasswordRequest: RequestBase
    {
        public string Email { get; set; }
    }
}
