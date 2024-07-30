using System;
using System.Collections.Generic;
using System.Text;

namespace PRCo.BBOS.BBOSConversion {
    class Program {
        static void Main(string[] args) {
            BBOSConverter oBBOSConverter = new BBOSConverter();
            oBBOSConverter.ConvertMembers(args);              
        }
    }
}
