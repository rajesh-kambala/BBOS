using System;
using System.Collections.Generic;
using System.Linq;
using SQLite;
using Xamarin.Forms;
using BBOSMobile.Core.Models;

namespace BBOSMobile.Core.Data
{
	public class BBOSDatabase 
	{
		protected static object locker = new object ();
		protected SQLiteConnection database;

		/// <summary>
		/// Initializes a new instance of the BBOSDatabase. 
		/// if the database doesn't exist, it will create the database and all the tables.
		/// </summary>
		/// <param name='path'>
		/// Path.
		/// </param>
		public BBOSDatabase()
		{
			database = DependencyService.Get<ISQLite> ().GetConnection ();
			// create the tables
			database.CreateTable<Terms> ();
			database.CreateTable<PrivacyStatement> ();
			database.CreateTable<Classification> ();
			database.CreateTable<Commodity> ();
			database.CreateTable<Product> ();
			database.CreateTable<Specie> ();
			database.CreateTable<Service> ();
			database.CreateTable<LookUpLastUpdated> ();
			database.CreateTable<State> ();
			database.CreateTable<TerminalMarket> ();
		}
	}
}


