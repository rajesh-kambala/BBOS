using System;
using System.Collections.Generic;
using System.Text;

namespace PRCo.BBOS.Communicator {
    class Program {
        static void Main(string[] args) {
            Communicator oCommunicator = new Communicator();
            oCommunicator.GenerateCommunications(args);
        
        }
    }
}
