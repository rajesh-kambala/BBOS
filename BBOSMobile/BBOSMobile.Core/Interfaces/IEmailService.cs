using System;
using System.Collections.Generic;
using BBOSMobile.Core.Models;

namespace BBOSMobile.Core.Interfaces
{
	public interface IEmailService
	{
		void CreateEmail (Email email);
		bool CanSendEmail();
	}
}

