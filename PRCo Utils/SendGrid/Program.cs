using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SendGrid
{
    class Program
    {
        static void Main(string[] args)
        {

            try
            {
                SendGridPOC sendGridPOC = new SendGridPOC();
                sendGridPOC.ScoreEmailAddresses().Wait();
            }
            catch (Exception e)
            {
                if (e.InnerException != null)
                    e = e.InnerException;

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
