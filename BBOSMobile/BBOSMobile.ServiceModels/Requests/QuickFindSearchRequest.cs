using BBOSMobile.ServiceModels.Common;
using System;


namespace BBOSMobile.ServiceModels.Requests
{
    public class QuickFindSearchRequest: RequestBase
    {
        public string SearchText { get; set; }

        public int PageIndex { get; set; }

        public int PageSize { get; set; }
    }
}
