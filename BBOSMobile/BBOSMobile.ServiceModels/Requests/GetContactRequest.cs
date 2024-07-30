using BBOSMobile.ServiceModels.Common;
using System;


namespace BBOSMobile.ServiceModels.Requests
{
    public class GetContactRequest: RequestBase
    {
        public int ContactID { get; set; }
        public int BBID { get; set; }
    }
}
