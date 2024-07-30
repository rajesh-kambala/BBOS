using System;

namespace BBOSMobile.ServiceModels.Common
{
	public class Contact: ContactBase
	{
		public string Email { get; set; }

        public int NoteID { get; set; }

		public Note Notes {get; set;}

		public string PrivateNotes { get; set; }

        public bool HasNotes { get; set; }

        // Used in contact screens
        public string CompanyPhone { get; set; }
        public string CellPhone { get; set; }
        public string DirectPhone { get; set; }

        // Used in company screens
        public string Fax { get; set; }
        public string Phone { get; set; }

        public string FirstName { get; set; }
        public string LastName { get; set; }
        


    }
}

