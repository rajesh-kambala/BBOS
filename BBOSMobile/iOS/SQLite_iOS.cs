using System;
using System.IO;

using Xamarin.Forms;
using BBOSMobile.Core.Data;
using BBOSMobile.iOS;

[assembly: Dependency (typeof (SQLite_iOS))]

namespace BBOSMobile.iOS
{
	public class SQLite_iOS : ISQLite
	{
		public SQLite_iOS ()
		{
		}

		#region ISQLite implementation
		public SQLite.SQLiteConnection GetConnection ()
		{
			var sqliteFilename = "BBOS_SQLite.db3";
			string documentsPath = Environment.GetFolderPath (Environment.SpecialFolder.Personal); // Documents folder
			string libraryPath = Path.Combine (documentsPath, "..", "Library"); // Library folder
			var path = Path.Combine(libraryPath, sqliteFilename);

			// This is where we copy in the prepopulated database
			Console.WriteLine (path);
			if (!File.Exists (path)) {
				File.Copy (sqliteFilename, path);
			}
				
			//var plat = new SQLite.Net.Platform.XamarinIOS.SQLitePlatformIOS();
			var conn = new SQLite.SQLiteConnection(path);

			// Return the database connection 
			return conn;
		}
		#endregion
	}
}
