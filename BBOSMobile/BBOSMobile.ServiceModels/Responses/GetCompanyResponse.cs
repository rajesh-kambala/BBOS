using BBOSMobile.ServiceModels.Common;
using System;

namespace BBOSMobile.ServiceModels.Responses
{
    public class GetCompanyResponse: ResponseBase
    {
        public Company Company { get; set; }
    }
}
