using System;
using BBOSMobile.ServiceModels.Common;
using System.Collections.Generic;

namespace BBOSMobile.Forms
{
	public class ContactViewModel : BaseViewModel
	{
		public Contact Contact { get; set; }
		public string PhoneDisplay {
			get {
				string ret = "";
				if (Contact.CompanyPhone != "") {
					ret += " | " + Contact.CompanyPhone;
				}
				return ret;
			}
		}
		public string BBIDDisplay{
			get{ 
				return "BB #" + Contact.BBID.ToString ();
			}

		}
		public List<ContactSummaryListItemViewModel> SummaryItems { get; set; }
		//public List<ContactSectionListItemViewModel> SectionItems { get; set; }
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
		public BBOSMobile.ServiceModels.Common.SecurityResult ContactDetailsListingPage
		{
			get
			{
				if (SecurityPrivileges == null) {
					return NoSecurity;
				} else {
					var security = SecurityPrivileges.Find (m => m.PrivilegeName == BBOSMobile.ServiceModels.Common.Enumerations.Privilege.ContactDetailsListingPage); 
					if (security == null)
						return NoSecurity;
					else
						return security;
				}

			} 
		}
		public BBOSMobile.ServiceModels.Common.SecurityResult ContactDetailsContactsPage
		{
			get
			{
				if (SecurityPrivileges == null) {
					return NoSecurity;
				} else {
					var security = SecurityPrivileges.Find (m => m.PrivilegeName == BBOSMobile.ServiceModels.Common.Enumerations.Privilege.ContactDetailsContactsPage); 
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

