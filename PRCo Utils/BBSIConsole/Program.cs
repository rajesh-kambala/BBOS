using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Threading.Tasks;

using TSI.Arch;
using TSI.Utils;
using PRCo.BBS;

namespace BBSIConsole
{
    class Program
    {

        static ILogger _logger;

        static void Main(string[] args)
        {
            try
            {
                GenerateAndSaveInvoices();
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

        static void LogMessage(string msg)
        {
            Console.WriteLine(msg);
            _logger.LogMessage(msg);
        }

        static void GenerateAndSaveInvoices()
        {
            string path = "D:\\Temp\\BBSI\\Invoices\\";
            ReportInterface reportInterface = new ReportInterface();

            List<string> invoices = new List<string>();
            //invoices.Add("M124208");
            //invoices.Add("M124342");
            //invoices.Add("M126130");
            //invoices.Add("M126295");
            //invoices.Add("M124237");
            //invoices.Add("M126841");
            //invoices.Add("M124539");
            //invoices.Add("M126667");
            //invoices.Add("M126848");
            //invoices.Add("M126158");
            //invoices.Add("M123231");
            //invoices.Add("M126815");
            //invoices.Add("M126895");
            //invoices.Add("M125557");
            //invoices.Add("M126711");
            //invoices.Add("M126336");
            //invoices.Add("M126723");
            invoices.Add("M126178");
            invoices.Add("M126891");
            invoices.Add("M126606");
            invoices.Add("M126778");
            invoices.Add("M126943");
            invoices.Add("M126667");


            foreach (string invoiceNbr in invoices)
            {
                byte[] report = reportInterface.GenerateInvoiceStripe(invoiceNbr);
                File.WriteAllBytes($"{path}BBS Invoice {invoiceNbr}.pdf", report);
            }

        }
    }
}
