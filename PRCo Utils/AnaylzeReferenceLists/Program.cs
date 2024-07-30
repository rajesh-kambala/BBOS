using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnaylzeReferenceLists
{
    class Program
    {
        static void Main(string[] args)
        {
            Analyzer analyzer = new Analyzer();
            analyzer.Analyze();

            Console.Write("Press any key to continue . . . ");
            Console.ReadKey(true);
        }
    }
}
