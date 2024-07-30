using System;

using BBOSMobile.Core.Data;

namespace BBOSMobile.Core.Models
{
	public class TerminalMarket : BusinessEntityBase
	{
		public int TerminalMarketId { get; set; }

		public string Name { get; set; }

		public int StateId { get; set; } 

		//Bit of a hack, but everything else in the company search page has a definition field.  Makes the data binding easier
		public string Definition {
			get{ 
				return this.Name;
			}
		}
	}
}

