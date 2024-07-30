using System;
using System.Threading.Tasks;

namespace BBOSMobile.Core.Interfaces
{
	public interface ILocationService
	{
		Task<string> GetCurrentPostalCode ();
	}
}

