using System;
using BBOSMobile.ServiceModels.Common;
using System.Collections.Generic;

namespace BBOSMobile.Forms
{
	public class CompanyViewModel : BaseViewModel
	{
		public Company Company { get; set; }
		public string PhoneDisplay {
			get {
				string ret = "";
				if (Company.Phone != "") {
					ret += " | " + Company.Phone;
				}
				return ret;
			}
		}
		public string BBIDDisplay{
			get{ 
				return "BB #" + Company.BBID.ToString ();
			}

		}

        public string WDIndicator
        {
            get
            {
                if (Company.IsWatchDog) { return "  WD"; } else { return ""; }
                //if (1==1) { return "  (WD)"; } else { return ""; }
            }
        }

		public List<CompanySummaryListItemViewModel> SummaryItems { get; set; }
		public List<CompanySectionListItemViewModel> SectionItems { get; set; }
		public BBOSMobile.ServiceModels.Common.SecurityResult NotesSecurity
		{
			get
			{
				if (SecurityPrivileges == null) {
					return NoSecurity;
				} else {
					var security = SecurityPrivileges.Find (m => m.PrivilegeName == BBOSMobile.ServiceModels.Common.Enumerations.Privilege.Notes); 
					if (security == null)
						return NoSecurity;
					else
						return security;
				}

			} 
		}
		public BBOSMobile.ServiceModels.Common.SecurityResult WatchdogListAdd
		{
			get
			{
				if (SecurityPrivileges == null) {
					return NoSecurity;
				} else {
					var security = SecurityPrivileges.Find (m => m.PrivilegeName == BBOSMobile.ServiceModels.Common.Enumerations.Privilege.WatchdogListAdd); 
					if (security == null)
						return NoSecurity;
					else
						return security;
				}

			} 
		}
		public BBOSMobile.ServiceModels.Common.SecurityResult CompanyDetailsListingPage
		{
			get
			{
				if (SecurityPrivileges == null) {
					return NoSecurity;
				} else {
					var security = SecurityPrivileges.Find (m => m.PrivilegeName == BBOSMobile.ServiceModels.Common.Enumerations.Privilege.CompanyDetailsListingPage); 
					if (security == null)
						return NoSecurity;
					else
						return security;
				}

			} 
		}
		public BBOSMobile.ServiceModels.Common.SecurityResult CompanyDetailsContactsPage
		{
			get
			{
				if (SecurityPrivileges == null) {
					return NoSecurity;
				} else {
					var security = SecurityPrivileges.Find (m => m.PrivilegeName == BBOSMobile.ServiceModels.Common.Enumerations.Privilege.CompanyDetailsContactsPage); 
					if (security == null)
						return NoSecurity;
					else
						return security;
				}

			} 
		}
		public BBOSMobile.ServiceModels.Common.SecurityResult ViewRating
		{
			get
			{
				if (SecurityPrivileges == null) {
					return NoSecurity;
				} else {
					var security = SecurityPrivileges.Find (m => m.PrivilegeName == BBOSMobile.ServiceModels.Common.Enumerations.Privilege.ViewRating); 
					if (security == null)
						return NoSecurity;
					else
						return security;
				}

			} 
		}
		public BBOSMobile.ServiceModels.Common.SecurityResult ViewBBScore
		{
			get
			{
				if (SecurityPrivileges == null) {
					return NoSecurity;
				} else {
					var security = SecurityPrivileges.Find (m => m.PrivilegeName == BBOSMobile.ServiceModels.Common.Enumerations.Privilege.ViewBBScore); 
					if (security == null)
						return NoSecurity;
					else
						return security;
				}

			} 
		}
	}
}

