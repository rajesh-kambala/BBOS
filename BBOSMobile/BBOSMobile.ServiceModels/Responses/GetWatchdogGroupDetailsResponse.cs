﻿using BBOSMobile.ServiceModels.Common;
using System;
using System.Collections.Generic;


namespace BBOSMobile.ServiceModels.Responses
{
	public class GetWatchdogGroupDetailsResponse: ResponseBase
	{
		public WatchdogGroup WatchdogGroup { get; set; }
	}
}
