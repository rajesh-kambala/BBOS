using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PACAComplaintDetailImporter
{
    class Program
    {
        static void Main(string[] args)
        {
            PACAComplaintDetailImporter importer = new PACAComplaintDetailImporter();
            importer.Import(args);

        }
    }
}
