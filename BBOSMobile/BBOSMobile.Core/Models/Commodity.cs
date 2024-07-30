using System;

using BBOSMobile.Core.Data;

namespace BBOSMobile.Core.Models
{
	public class Commodity : BusinessEntityBase
	{
		public int CommodityID { get; set; }

		public string Abbreviation { get; set; }

		public string Definition { get; set; }
	}
}

