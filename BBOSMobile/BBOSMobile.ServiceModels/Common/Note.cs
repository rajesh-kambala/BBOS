using System;

namespace BBOSMobile.ServiceModels.Common
{
	public class Note
	{
		public int NoteID { get; set; }

		public DateTime LastUpdated { get; set; }

		public bool IsPrivate { get; set; }

		public string NoteText { get; set; }

		public string LastUpdatedBy {get; set;}

		public bool IsCreator { get; set; }


	}
}

