using System;
using System.Collections.Generic;

namespace BBOSMobile.ServiceModels.Common
{
    public class UserAccess
    {
        public bool TermsRequired { get; set; }

        public Enumerations.UserLevel UserLevel { get; set; }

		public List<SecurityResult> SecurityPrivileges { get; set; }
    }
}
