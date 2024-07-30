using System;
using System.Collections.Generic;
using System.Linq;

namespace BBOSMobile.Core.Data
{
	public class BBOSRepository : BBOSDatabase
	{
		#region Generic CRUD Methods

		public int DeleteAllItems<T>() where T: IBusinessEntity
		{
			lock (locker) {
				var table = typeof(T).Name;
				return (database.Execute("DELETE FROM " + table));
			}
		}

		public int DeleteItem<T> (int id) where T: IBusinessEntity
		{
			lock (locker) {
				return database.Delete<T>(id);
			}
		}

		public IEnumerable<T> GetAllItems<T> () where T: IBusinessEntity, new() 
		{
			lock (locker) {
				return (from i in database.Table<T>() select i).ToList();
			}
		}

		public T GetItem<T> (int id) where T: IBusinessEntity, new()
		{
			lock (locker) {
				var table = typeof(T).Name;
				var sql = String.Format ("SELECT * FROM {0} WHERE Id = {1}", table, id.ToString ());
				return database.Query<T> (sql).FirstOrDefault ();
			}
		}

		public int SaveItem (IBusinessEntity item) 
		{
			lock (locker) {
				if (item.ID != 0) {
					database.Update(item);
					return item.ID;
				} else {
					return database.Insert(item);
				}
			}
		}

		#endregion
	}
}

