using System;

namespace BBOSMobile.ServiceModels.Common
{
    /// <summary>
    /// Used as the base Company class. All lists containg company data will be of this type in order to improve performance.
    /// </summary>
    public class CompanyBase
    {
        public int BBID { get; set; }

        public string Name { get; set; }

        public string Location { get; set; }

		public string MapAddress { get; set; }

		public string Industry { get; set; }

		public string Type { get; set; }

		public string Rating { get; set; }

        public string Phone { get; set; }

		public bool HasNotes { get; set; }

		public int Index { get; set; }
    }
}
