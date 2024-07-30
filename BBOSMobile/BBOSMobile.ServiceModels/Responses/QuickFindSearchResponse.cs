using BBOSMobile.ServiceModels.Common;
using System;
using System.Collections.Generic;


namespace BBOSMobile.ServiceModels.Responses
{
    public class QuickFindSearchResponse: ResponseBase
    {
        public IEnumerable<CompanyBase> Companies { get; set; }

        public int ResultCount { get; set; }
    }
}
