using System;

namespace BBOSMobile.ServiceModels.Common
{
    /// <summary>
    /// Contains the common properties for all webservice requests.
    /// </summary>
    public class RequestBase
    {
        public Guid UserId { get; set; }
        public Enumerations.IndustryType IndustryType { get; set; }
        public int PageIndex { get; set; }

        public int PageSize { get; set; }
    }
}
