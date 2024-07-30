using System;
using BBOSMobile.ServiceModels.Common;

namespace BBOSMobile
{
	public class ContactSummaryListItemViewModel
	{
		public bool Action {get; set;}

		public int OrderPosition { get; set;}

		public string LabelName { get; set; }

		public string Value { get; set;}

		public string ActionURL {get; set;}

		public string Image {get; set;}

		public string SocialURL {get; set;}

		public bool HasImage { get{return !string.IsNullOrEmpty(Image); }}

	}
}

