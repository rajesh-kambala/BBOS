using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace TradeAssociationImport
{
    class Program
    {
        static void Main(string[] args)
        {
            TAImporter taImporter = new TAImporter();
            taImporter.Import(args);

            Console.Write("Press any key to continue . . . ");
            Console.ReadKey(true);
        }
    }
}
