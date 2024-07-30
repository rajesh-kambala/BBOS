using System;

using BBOSMobile.Core.Models;

namespace BBOSMobile.Core.Interfaces
{
	public interface IUserCredentialsService
	{
		void SetUserCredentials(UserCredentials userCredentials);

		UserCredentials GetUserCredentials ();

		void ClearUserCredentials();
	}
}

