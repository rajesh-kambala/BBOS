using System;

using SQLite;

namespace BBOSMobile.Core.Data
{
	public class BusinessEntityBase : IBusinessEntity
	{
		[PrimaryKey, AutoIncrement]
		public int ID { get; set; }
	}
}

