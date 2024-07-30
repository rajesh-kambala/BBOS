using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PACAImporter
{
    class Program
    {
        static void Main(string[] args)
        {
            PACAImporter importer = new PACAImporter();
            importer.Import(args);

        }
    }
}
