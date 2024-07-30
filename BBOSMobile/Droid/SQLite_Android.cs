using System;
using Xamarin.Forms;
using System.IO;
using BBOSMobile.Core.Data;
using BBOSMobile.Droid;
using SQLite;

[assembly: Dependency (typeof (SQLite_Android))]

namespace BBOSMobile.Droid
{
	public class SQLite_Android : ISQLite
	{
		public SQLite_Android ()
		{
		}

		#region ISQLite implementation
		public SQLite.SQLiteConnection GetConnection ()
		{
			var sqliteFilename = "BBOS_SQLite.db3";
			string documentsPath = System.Environment.GetFolderPath (System.Environment.SpecialFolder.Personal); // Documents folder
			var path = Path.Combine(documentsPath, sqliteFilename);

			// This is where we copy in the prepopulated database
			Console.WriteLine (path);
			if (!File.Exists(path))
			{
				var s = Android.App.Application.Context.Resources.OpenRawResource(Resource.Raw.BBOS_SQLite);  // RESOURCE NAME ###

				// create a write stream
				FileStream writeStream = new FileStream(path, FileMode.OpenOrCreate, FileAccess.Write);
				// write to the stream
				ReadWriteStream(s, writeStream);
			}
			
			//var plat = new SQLite.Platform.XamarinAndroid.SQLitePlatformAndroid();
			var conn = new SQLite.SQLiteConnection(path);

			// Return the database connection 
			return conn;
		}
		#endregion

		/// <summary>
		/// helper method to get the database out of /raw/ and into the user filesystem
		/// </summary>
		void ReadWriteStream(Stream readStream, Stream writeStream)
		{
			int Length = 256;
			Byte[] buffer = new Byte[Length];
			int bytesRead = readStream.Read(buffer, 0, Length);
			// write the required bytes
			while (bytesRead > 0)
			{
				writeStream.Write(buffer, 0, bytesRead);
				bytesRead = readStream.Read(buffer, 0, Length);
			}
			readStream.Close();
			writeStream.Close();
		}
	}
}