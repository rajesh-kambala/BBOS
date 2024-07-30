using System;
using System.Linq;
using BBOSMobile.ServiceModels.Common;
using System.Collections.ObjectModel;
using System.Collections.Generic;

namespace BBOSMobile
{
	public class ContactListViewModel : BaseViewModel
	{
		public ObservableCollection<ContactListItemViewModel> Contacts { get; set; }

		public int PageIndex { get; set; }

		public int PageSize { get; set; }
	}
}

