using System;
using SQLite;



namespace BBOSMobile.Core.Data
{
	public interface ISQLite
	{
		SQLiteConnection GetConnection();
	}
}
