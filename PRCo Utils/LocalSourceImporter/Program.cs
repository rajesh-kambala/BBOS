using System;

namespace LocalSourceImporter
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
