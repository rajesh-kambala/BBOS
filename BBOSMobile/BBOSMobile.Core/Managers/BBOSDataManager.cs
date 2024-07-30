using System;
using System.Collections.Generic;

using BBOSMobile.Core.Data;

namespace BBOSMobile.Core.Managers
{
	/// <summary>
	/// BBOS base manager class with generic db methods.
	/// </summary>
	public class BBOSDataManager
	{
		/// <summary>
		/// Generic method to delete all of a business entity
		/// </summary>
		/// <returns>The all items.</returns>
		/// <typeparam name="T">The 1st type parameter.</typeparam>
		public int DeleteAllItems<T> () where T: IBusinessEntity
		{
			var bbosRepository = new BBOSRepository (); 
			return bbosRepository.DeleteAllItems<T> ();
		}

		/// <summary>
		/// Generic method to delete an item
		/// </summary>
		/// <returns>The item.</returns>
		/// <param name="id">Identifier.</param>
		/// <typeparam name="T">The 1st type parameter.</typeparam>
		public int DeleteItem<T> (int id) where T: IBusinessEntity
		{
			var bbosRepository = new BBOSRepository (); 
			return bbosRepository.DeleteItem<T> (id);
		}

		/// <summary>
		/// Generic method to get all business entity items
		/// </summary>
		/// <returns>The all items.</returns>
		/// <typeparam name="T">The 1st type parameter.</typeparam>
		public IEnumerable<T> GetAllItems<T> () where T: IBusinessEntity, new()
		{
			var bbosRepository = new BBOSRepository (); 
			return bbosRepository.GetAllItems<T> ();
		}

		/// <summary>
		/// Generic method to get a business entity by id
		/// </summary>
		/// <returns>The item.</returns>
		/// <param name="id">Identifier.</param>
		/// <typeparam name="T">The 1st type parameter.</typeparam>
		public T GetItem<T> (int id) where T: IBusinessEntity, new()
		{
			var bbosRepository = new BBOSRepository (); 
			return bbosRepository.GetItem<T> (id);
		}

		/// <summary>
		/// Generic Method to save a business entity
		/// </summary>
		/// <returns>The item.</returns>
		/// <param name="item">Item.</param>
		public int SaveItem (IBusinessEntity item)
		{
			var bbosRepository = new BBOSRepository (); 
			return bbosRepository.SaveItem (item);
		}
	}
}

