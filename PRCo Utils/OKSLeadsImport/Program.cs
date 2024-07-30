using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace OKSLeadsImport
{
    class Program
    {
        static void Main(string[] args)
        {
            OKSImporter oOKSImporter = new OKSImporter();
            oOKSImporter.Import(args);
        }
    }
}
