using System;
using System.Collections.Generic;
using BBOSMobile.Core.Data;

namespace BBOSMobile.Core.Models
{
	public class OutOfBusiness : BusinessEntityBase
	{
		public int OutOfBusinessID { get; set; }

		public string Code { get; set; }

		public bool Value { get; set; }

		public string Definition { get; set; }

		public static List<OutOfBusiness> getList()
		{

			var list = new List<OutOfBusiness>();

			list.Add(new OutOfBusiness() { OutOfBusinessID = 2, Code = "T", Value = true, Definition = "Company Is Out Of Business" });
			list.Add(new OutOfBusiness() { OutOfBusinessID = 1, Code = "F", Value = false, Definition = "Company Is Still In Business" });

			return list;
		}

	}
}

