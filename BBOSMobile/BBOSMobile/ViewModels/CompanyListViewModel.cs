using System;
using System.Linq;
using BBOSMobile.ServiceModels.Common;
using System.Collections.ObjectModel;
using System.Collections.Generic;

namespace BBOSMobile
{
	public class CompanyListViewModel : BaseViewModel
	{
		public ObservableCollection<CompanyListItemViewModel> Companies { get; set; }

		public int PageIndex { get; set; }

		public int PageSize { get; set; }
	}
}

