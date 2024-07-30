using System;
using System.Collections.Generic;

namespace BBOSMobile.Core.WebServices
{
	public class SampleWebserviceClient : WebserviceClientBase
	{
		public SampleWebserviceClient ()
		{
		}

		private const string SampleApiBaseAddress = "http://api.tekconf.com/v1/";
		private const string ConferencesRequestURI = "conferences";

		public IEnumerable<ConferenceDto> GetConferencDtos ()
		{
			IEnumerable<ConferenceDto> conferenceDtos = GetServiceResponse<IEnumerable<ConferenceDto>> (SampleApiBaseAddress, ConferencesRequestURI).Result;
			return conferenceDtos;
		}
	}

	public class ConferenceDto
	{
		public string Slug { get; set; }

		public string Name { get; set; }

		public DateTime Start { get; set; }

		public double[] Position { get; set; }
	}
}

