using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace GenerateSalesOrders
{
    class Program
    {
        static void Main(string[] args)
        {

            try
            {
                SOGenerator soGenerate = new SOGenerator();
                soGenerate.Generate();
            }
            catch (Exception e)
            {
                Console.WriteLine();
                Console.WriteLine();
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine("An unexpected exception occurred: " + e.Message);
                Console.WriteLine("Terminating execution.");

                Console.WriteLine(e.StackTrace);

                Console.ForegroundColor = ConsoleColor.Gray;
            }

            Console.WriteLine("Press any key to continue...");
            Console.ReadKey(true);
        }
    }
}
