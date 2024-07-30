using System;
using BBOSMobile.ServiceModels.Common;

namespace BBOSMobile.ServiceModels.Requests

{
    public class LogExceptionDetailsRequest : RequestBase
    {
        public string UserID { get; set; }
        public string OSVersion { get; set; }
        public string AppVersion { get; set; }
        public string AppIndustryType { get; set; }
        public string ScreenName { get; set; }
        public string WebMethod { get; set; }
        public string ExceptionMessage { get; set; }
        public string StackTrace { get; set; }
        public string AdditionalInfo { get; set; }
    }
}
