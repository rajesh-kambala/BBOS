using System;
using System.Collections.Generic;

namespace BBOSMobile.ServiceModels.Common
{
	public class CategoryLists
	{
		public IEnumerable<Classification> ClassificationList { get; set; }

		public IEnumerable<Commodity> CommondityList { get; set; }

		public IEnumerable<Product> ProductList { get; set; }

		public IEnumerable<Service> ServiceList { get; set; }

		public IEnumerable<Specie> SpecieList { get; set; }

		public IEnumerable<State> StateList { get; set; }

		public IEnumerable<TerminalMarket> TerminalMarketList { get; set; }
	}
}

