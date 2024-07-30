using System;

namespace QCSS_Call_Campaign
{
	class Program
	{
		static void Main(string[] args)
		{
			QCSSImporter qcssImporter = new QCSSImporter();
			qcssImporter.Import(args);

			Console.Write("Press any key to continue . . . ");
			Console.ReadKey(true);
		}
	}
}
