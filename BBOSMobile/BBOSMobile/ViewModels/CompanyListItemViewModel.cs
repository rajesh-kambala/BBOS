using System;
using Xamarin.Forms;

namespace BBOSMobile
{
	public class CompanyListItemViewModel
	{
		public int BBID { get; set; }

		public string Name { get; set; }

		public string Location { get; set; }

		public string IndustryAndType { get; set; }

		public string Rating { get; set; }

		public string Phone { get; set; }

		public bool HasNotes { get; set; }

		public int Index { get; set; }

		public string ActionMenuDisplay {
			get {
				var retVal = "";
				if (Device.OS == TargetPlatform.Android) {
					
					if (Phone != "") {
						retVal = "Call " + Name;
					}
				} else {
					retVal = "Call";
				}

				return retVal;
			}
		}
	}
}

