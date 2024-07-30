using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace LumberLeadsImport
{
    class Program
    {
        static void Main(string[] args)
        {
            LumberLeadsImporter oLumberLeadsImporter = new LumberLeadsImporter();
            oLumberLeadsImporter.Import(args);
        }
    }
}
