using BBOSMobile.ServiceModels.Common;
using System;
using System.Collections.Generic;


namespace BBOSMobile.ServiceModels.Responses
{
    public class GetRecentlyViewedContactsResponse : ResponseBase
    {
        public IEnumerable<ContactBase> Contacts { get; set; }
    }
}
