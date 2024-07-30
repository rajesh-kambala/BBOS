using System;
using System.Collections.Generic;

namespace BBOSMobile.ServiceModels.Common
{
	public class BBOSLists
	{
		public IEnumerable<Classification> ClassificationList { get; set; }

		public IEnumerable<Commodity> CommondityList { get; set; }

		public IEnumerable<Product> ProductList { get; set; }

		public IEnumerable<Service> ServiceList { get; set; }

		public IEnumerable<Specie> SpecieList { get; set; }
	}
}

