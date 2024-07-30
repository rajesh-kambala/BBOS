using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace PostalDataImport
{
    class Program
    {
        static void Main(string[] args)
        {
            try
            {
                PostalDataImporter postalDataImporter = new PostalDataImporter();
                postalDataImporter.Import(args);

                Console.WriteLine();
                Console.WriteLine("Completed: " + DateTime.Now.ToString("M/dd/yyyy hh:mm tt"));
                Console.WriteLine();
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
