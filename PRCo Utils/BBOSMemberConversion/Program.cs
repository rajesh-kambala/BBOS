using System;
using System.Collections.Generic;
using System.Text;

namespace PRCo.BBOS.MemberConversion {
    class Program {
        static void Main(string[] args) {
            EnterpriseConverter oConverter = new EnterpriseConverter();
            oConverter.ConvertEnterprises(args);        
        }
    }
}
