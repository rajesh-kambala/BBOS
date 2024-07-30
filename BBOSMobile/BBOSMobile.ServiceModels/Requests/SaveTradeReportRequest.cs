using System;
using BBOSMobile.ServiceModels.Common;

namespace BBOSMobile.ServiceModels.Requests
{
    public class SaveTradeReportRequest : RequestBase
    {
        public int TESReqeustID { get; set; }  // Leave empty for now

        public int ResponderCompanyID { get; set; }
        public int SubjectCompanyID { get; set; }

        public string TradePracticeRating { get; set; }
        public string PayPerformanceRating { get; set; }
        public string HighCreditRating { get; set; }
        public string CompanyLastDealt { get; set; }
        public bool OutOfBusiness { get; set; }
        public string Comments { get; set; }
    }
}
