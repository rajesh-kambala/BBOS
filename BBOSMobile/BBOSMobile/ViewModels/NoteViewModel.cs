using System;
using System.Windows.Input;
using BBOSMobile.ServiceModels.Common;

namespace BBOSMobile.Forms.ViewModels
{
	public class NoteViewModel : BaseViewModel
	{
		public Note Note {get; set;}
		public bool CanChangePrivate { 
			get 
			{ 
				return (Note.IsCreator || Note.NoteID == 0);
			} 
		}
		public bool DisplayDateStamp { 
			get 
			{ 
				return (Note.NoteID != 0);
			} 
		}

	}
}

