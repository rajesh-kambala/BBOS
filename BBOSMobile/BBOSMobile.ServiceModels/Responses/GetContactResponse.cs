using BBOSMobile.ServiceModels.Common;
using System;

namespace BBOSMobile.ServiceModels.Responses
{
    public class GetContactResponse: ResponseBase
    {
        public Contact Contact { get; set; }
    }
}
