using System;
using System.Collections.Generic;
using BBOSMobile.Core.Data;

namespace BBOSMobile.Core.Models
{
	public class HighCredit : BusinessEntityBase
	{
		public int HighCreditID { get; set; }

		public string Code { get; set; }

		public string Definition { get; set; }

		public static List<HighCredit> getList()
		{

			var list = new List<HighCredit>();


			list.Add(new HighCredit() { HighCreditID = 6, Code = "A", Definition = "5-10M" });
			list.Add(new HighCredit() { HighCreditID = 5, Code = "B", Definition = "10-50M" });
			list.Add(new HighCredit() { HighCreditID = 4, Code = "C", Definition = "50-75M" });
			list.Add(new HighCredit() { HighCreditID = 3, Code = "D", Definition = "75-100M" });
			list.Add(new HighCredit() { HighCreditID = 2, Code = "E", Definition = "100-250M" });
			list.Add(new HighCredit() { HighCreditID = 1, Code = "F", Definition = "Over 250M" });

			return list;
		}
	}
}

