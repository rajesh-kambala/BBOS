using BBOSMobile.ServiceModels.Common;
using System;
using System.Collections.Generic;

namespace BBOSMobile.ServiceModels.Responses
{
    public class GetRecentlyViewedResponse: ResponseBase
    {
        public IEnumerable<CompanyBase> Companies { get; set; }
        public IEnumerable<ContactBase> Contacts { get; set; }
    }
}
