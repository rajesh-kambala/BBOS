using System;

using BBOSMobile.ServiceModels.Common;

namespace BBOSMobile.Forms.ViewModels
{
	public class WatchdogDetailViewModel : BaseViewModel
	{
		//public WatchdogGroup WatchdogGroup {get;set;}

		//public WatchdogListItemViewModel WatchdogListItem {get;set;}

		public const string WatchdogGroupPropertyName = "WatchdogGroup";
		private WatchdogGroup watchdogGroup = new WatchdogGroup ();
		public WatchdogGroup WatchdogGroup
		{
			get { return watchdogGroup; }
			set { SetProperty(ref watchdogGroup, value, WatchdogGroupPropertyName); }
		}

		public const string WatchdogListItemPropertyName = "WatchdogListItem";
		private WatchdogListItemViewModel watchdogListItem = new WatchdogListItemViewModel ();
		public WatchdogListItemViewModel WatchdogListItem
		{
			get { return watchdogListItem; }
			set { SetProperty(ref watchdogListItem, value, WatchdogListItemPropertyName); }
		}
	}
}

