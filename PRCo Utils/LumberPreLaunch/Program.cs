using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace PRCo.BBOS.LumberPreLaunch
{
    class Program
    {
        static void Main(string[] args)
        {
            Communicator oComm = new Communicator();
            oComm.GenerateCommunications(args);
        }
    }
}
