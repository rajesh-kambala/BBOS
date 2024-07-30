using System;
using System.Collections.Generic;
using BBOSMobile.Core.Data;

namespace BBOSMobile.Core.Models
{
	public class PayPerformance : BusinessEntityBase
	{
		public int PayPerformanceID { get; set; }

		public string Code { get; set; }

		public string Definition { get; set; }

		public static List<PayPerformance> getList()
		{

			var list = new List<PayPerformance>();


			list.Add(new PayPerformance() { PayPerformanceID = 9, Code = "9", Definition = "1-14 (AA)" });
			list.Add(new PayPerformance() { PayPerformanceID = 8, Code = "8", Definition = "15-21 (A)" });
			list.Add(new PayPerformance() { PayPerformanceID = 6, Code = "6", Definition = "22-28 (B)" });
			list.Add(new PayPerformance() { PayPerformanceID = 5, Code = "5", Definition = "29-35 (C)" });
			list.Add(new PayPerformance() { PayPerformanceID = 4, Code = "4", Definition = "36-45 (D)" });
			list.Add(new PayPerformance() { PayPerformanceID = 3, Code = "3", Definition = "46-60 (E)" });
			list.Add(new PayPerformance() { PayPerformanceID = 2, Code = "2", Definition = "60+ (F)" });

			return list;
		}

	}
}

