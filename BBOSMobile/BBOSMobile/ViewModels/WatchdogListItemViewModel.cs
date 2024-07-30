using System;
using System.Windows.Input;

namespace BBOSMobile.Forms
{
	public class WatchdogListItemViewModel
	{
		public int WatchdogGroupId {get;set;}
		public string Name {get;set;}
		public bool IsPrivate {get;set;}
		public string Private {
			get{
				if (IsPrivate) {
					return "(Yes)";
				}
				return "(No)";
			}
		}
		public bool InGroup { get; set;}
		//public bool AddToGroup { get; set;}
		public int Count {get;set;}

	}
}

