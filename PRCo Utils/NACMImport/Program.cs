using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace NACMImport
{
    class Program
    {
        static void Main(string[] args)
        {
            NACMImporter oNACMImporter = new NACMImporter();
            oNACMImporter.Import(args);
        }
    }
}
