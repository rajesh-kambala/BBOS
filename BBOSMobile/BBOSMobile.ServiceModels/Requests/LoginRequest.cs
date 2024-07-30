using System;
using BBOSMobile.ServiceModels.Common;

namespace BBOSMobile.ServiceModels.Requests
{
    public class LoginRequest: RequestBase
    {
        public string Email { get; set; }

        public string Password { get; set; }
    }
}
