using System;
using System.Collections.Generic;

namespace BBOSMobile.Core.Interfaces
{
	public interface ITrackerService
	{
		void TrackScreen (string screen);
		void TrackScreen (string screen, Dictionary<string, string> args);
	}
}

