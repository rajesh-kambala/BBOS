using System;
using System.Collections.Generic;

namespace BBOSMobile.Core.Models
{
	public class Email
	{
		public List<string> ToAddresses {get;set;}
		public string Subject {get;set;}
		public string Body {get;set;}
		public bool IsHtml {get;set;}
	}
}

