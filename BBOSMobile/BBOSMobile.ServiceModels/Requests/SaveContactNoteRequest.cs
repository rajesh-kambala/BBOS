using System;
using BBOSMobile.ServiceModels.Common;

namespace BBOSMobile.ServiceModels.Requests
{
	public class SaveContactNoteRequest: RequestBase
	{
		public int BBID { get; set; }
		public int ContactID { get; set; }
		public int NoteID { get; set; }
		public Note Note { get; set; }

	}
}


