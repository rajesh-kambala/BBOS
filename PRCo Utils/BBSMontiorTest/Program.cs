using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace BBSMontiorTest
{
    class Program
    {
        static void Main(string[] args)
        {

            CreditSheetReportEvent oCSRE = new CreditSheetReportEvent();
            oCSRE.ProcessEvent();
        }
    }
}
