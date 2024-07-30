using System;
using System.Collections.Generic;
using BBOSMobile.Core.Data;

namespace BBOSMobile.Core.Models
{
	public class TradePractice : BusinessEntityBase
	{
		public int TradePracticeID { get; set; }

		public string Code { get; set; }

		public string Definition { get; set; }

		public static List<TradePractice> getList()
		{


			var list = new List<TradePractice>();

			list.Add(new TradePractice() { TradePracticeID = 6, Code = "6", Definition = "XXXX - Excellent" });
			list.Add(new TradePractice() { TradePracticeID = 5, Code = "5", Definition = "XXX - Good" });
			list.Add(new TradePractice() { TradePracticeID = 2, Code = "2", Definition = "XX - Unsatisfactory" });
			list.Add(new TradePractice() { TradePracticeID = 1, Code = "1", Definition = "X - Poor" });

			return list;
		}
	}
}

