using System;

namespace BBOSMobile.Core.Interfaces
{
	public interface IDeviceInfoService
	{
		string CarrierName { get; set; }
		string PhoneModel { get; set; }
		string PhonePlatform { get; set; }
		string PhoneOS { get; set; }
		string AppVersion { get; set; }
		bool HasSDCard { get; set; }
		bool HasCarrierDataNetwork { get; set; }

		void LoadInfo();
	}
}

