using System;
using BBOSMobile.ServiceModels.Common;
using System.Collections.Generic;

namespace BBOSMobile.Forms
{
	public class WatchdogAddViewModel
	{
		public int BBID { get; set;}
		public string BBIDDisplay{
			get{ 
				return "BB #" + Company.BBID.ToString ();
			}

		}
		public CompanyBase Company {get;set;}
		public List<WatchdogListItemViewModel> WatchdogListItems {get;set;}
	}
}

