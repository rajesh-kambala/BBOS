using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IntlTradeAssociationImport
{
    class Program
    {
        static void Main(string[] args)
        {
            Importer importer = new Importer();
            importer.Import(args);

            Console.Write("Press any key to continue . . . ");
            Console.ReadKey(true);
        }
    }
}
