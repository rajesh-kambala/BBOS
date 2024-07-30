using System;

namespace BBOSMobile.ServiceModels.Common
{
	public class SecurityResult
	{
		public Enumerations.Privilege PrivilegeName { get; set; }
		public bool HasPrivilege { get; set; } 
		public bool Visible { get; set; }
        public bool Enabled { get; set; }
    }
}
