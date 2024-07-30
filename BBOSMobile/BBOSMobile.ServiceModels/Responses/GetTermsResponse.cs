using BBOSMobile.ServiceModels.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BBOSMobile.ServiceModels.Responses
{
    public class GetTermsResponse: ResponseBase
    {
        public string TermsVersion { get; set; }

        public string TermsText { get; set; }
    }
}
