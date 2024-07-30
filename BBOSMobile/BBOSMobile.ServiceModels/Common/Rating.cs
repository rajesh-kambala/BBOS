using System;

namespace BBOSMobile.ServiceModels.Common
{
    public class Rating
    {
        public string Type { get; set; }

        public string Score { get; set; }

        public string Definition { get; set; }

		public string DisplayType { get {return string.IsNullOrEmpty (Type) ? "None" : Type; } }

		public string DisplayScore { get {return string.IsNullOrEmpty (Score) ? "None" : Score; } }

		public string DisplayDefinition { get {return string.IsNullOrEmpty (Definition) ? "None" : Definition; } }
    }
}
