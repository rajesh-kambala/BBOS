using System;
using BBOSMobile.ServiceModels.Common;

namespace BBOSMobile.ServiceModels.Requests

{
    public class LogExceptionRequest: RequestBase
    {
        public string ExceptionDetails { get; set; }
    }
}
