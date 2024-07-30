using System;
using BBOSMobile.ServiceModels.Common;

namespace BBOSMobile.ServiceModels.Requests
{
	public class SaveCompanyNoteRequest: RequestBase
	{
		public int BBID { get; set; }
		public int NoteID { get; set; }
		public string Note { get; set; }
		public bool Private {get; set;}


	}
}


