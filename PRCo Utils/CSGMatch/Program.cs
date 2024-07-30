using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace CSGMatch
{
    class Program
    {
        static void Main(string[] args)
        {

            try
            {
                CSGMatcher csgMatcher = new CSGMatcher();
                csgMatcher.Match();
            }
            catch (Exception e)
            {
                Console.WriteLine();
                Console.WriteLine();
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine("An unexpected exception occurred: " + e.Message);
                Console.WriteLine(e.StackTrace);
                Console.WriteLine("Terminating execution.");
                Console.ForegroundColor = ConsoleColor.Gray;
            }

            Console.Write("Press any key to continue . . . ");
            Console.ReadKey(true);
        }
    }
}
