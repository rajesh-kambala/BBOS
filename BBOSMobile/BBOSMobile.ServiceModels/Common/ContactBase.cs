    using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BBOSMobile.ServiceModels.Common
{
    public class ContactBase
    {
        public int ContactID { get; set; }

        public string Name { get; set; }

        public string Title { get; set; }

        public string ContactDisplay
        {
            get
            {
                return Name + " - " + Title;
            }
        }

        public int BBID { get; set; }

        public string CompanyName { get; set; }
        public string Location { get; set; }

        public int Index { get; set; }

    }
}
