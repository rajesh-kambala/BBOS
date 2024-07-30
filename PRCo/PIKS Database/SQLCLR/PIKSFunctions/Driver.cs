using System;

/// <summary>
/// Used as a temporary driver for the NUnit tests when
/// debugging individual test cases.
/// </summary>
class Driver  
{  
	/// <summary>
	/// The main entry point for the application.
	/// </summary>
	[STAThread]
	static void Main(string[] args)
	{

        EquifaxUtils.PopulateEquifaxData(173909, 299582);
	}
}

