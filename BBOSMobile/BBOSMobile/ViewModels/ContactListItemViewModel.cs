using System;
using Xamarin.Forms;

namespace BBOSMobile
{
	public class ContactListItemViewModel
	{
        public int BBID { get; set; }

        public int ContactID { get; set; }

        public string Name { get; set; }

		public string Title { get; set; }

		public string ContactDisplay { get; set; }

		public string CompanyName { get; set; }

		public string Location { get; set; }
		public int Index { get; set; }


	}
}

