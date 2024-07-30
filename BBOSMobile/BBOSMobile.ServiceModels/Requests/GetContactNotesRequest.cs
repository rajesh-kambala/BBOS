using BBOSMobile.ServiceModels.Common;
using System;


namespace BBOSMobile.ServiceModels.Requests
{
    public class GetContactNotesRequest: RequestBase
    {
        public int ContactID { get; set; }
    }
}
