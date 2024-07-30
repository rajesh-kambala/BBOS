using System;
using System.Collections.Generic;
using BBOSMobile.Core.Data;

namespace BBOSMobile.Core.Models
{
	public class LastDealt : BusinessEntityBase
	{
		public int LastDealtID { get; set; }

		public string Code { get; set; }

		public string Definition { get; set; }


		public static List<LastDealt> getList()
		{

			var list = new List<LastDealt>();


			list.Add(new LastDealt() { LastDealtID = 4, Code = "A", Definition = "1-6 Months" });
			list.Add(new LastDealt() { LastDealtID = 3, Code = "B", Definition = "7-12 Months" });
			list.Add(new LastDealt() { LastDealtID = 2, Code = "C", Definition = "Over 1 Year" });
			list.Add(new LastDealt() { LastDealtID = 1, Code = "D", Definition = "Never" });

			return list;
		}
	}
}

