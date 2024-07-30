using System;

using BBOSMobile.Core.Data;

namespace BBOSMobile.Core.Models
{
	public class Specie : BusinessEntityBase
	{
		public int SpecieId { get; set; }

		public string Name { get; set; }

		//Bit of a hack, but everything else in the company search page has a definition field.  Makes the data binding easier
		public string Definition {
			get{ 
				return this.Name;
			}
		}
	}
}

