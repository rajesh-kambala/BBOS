using System;

namespace BBOSMobile.ServiceModels.Common
{
    /// <summary>
    /// Contain the common properties for all webservice responses.
    /// </summary>
    public class ResponseBase
    {
        public Enumerations.ResponseStatus ResponseStatus { get; set; }

        public string ErrorMessage { get; set; }

		public bool TermsRequired { get; set; }

        public UserAccess UserAccessInfo { get; set; }
    }
}
