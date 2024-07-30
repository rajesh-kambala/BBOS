using System;
using System.Collections.Generic;
using System.Linq;

using BBOSMobile.Core.Data;
using BBOSMobile.ServiceModels.Common;
using DataModels = BBOSMobile.Core.Models;

namespace BBOSMobile.Core.Managers
{
	public class LookUpListManager : BBOSDataManager
	{
		/// <summary>
		/// Saves the look up lists to the local db.
		/// </summary>
		/// <param name="categoryLists">Category lists.</param>
		public void UpdateLookUpLists(CategoryLists categoryLists)
		{
			var bbosRepository = new BBOSRepository ();
			bool needToUpdateLastUpdated = false;

			if (categoryLists.ClassificationList != null) 
			{
				bbosRepository.DeleteAllItems<DataModels.Classification> ();
				foreach (var wsClassification in categoryLists.ClassificationList) 
				{
					var classification = new DataModels.Classification () {
						ClassificationId = wsClassification.Id,
						Abbreviation = wsClassification.Abbreviation,
						Definition = wsClassification.Definition,
						Description = wsClassification.Description,
						IndustryType = wsClassification.IndustryType
					};
					bbosRepository.SaveItem (classification);
				} 

				needToUpdateLastUpdated = true;
			}

			if (categoryLists.CommondityList != null) 
			{
				bbosRepository.DeleteAllItems<DataModels.Commodity> ();
				foreach (var wsCommodity in categoryLists.CommondityList) 
				{
					var commodity = new DataModels.Commodity () {
						CommodityID = wsCommodity.Id,
						Abbreviation = wsCommodity.Abbreviation,
						Definition = wsCommodity.Definition
					};
					bbosRepository.SaveItem (commodity);
				} 

				needToUpdateLastUpdated = true;
			}

			if (categoryLists.ProductList != null) 
			{
				bbosRepository.DeleteAllItems<DataModels.Product> ();
				foreach (var wsProduct in categoryLists.ProductList) 
				{
					var product = new DataModels.Product () {
						ProductId = wsProduct.Id,
						Name = wsProduct.Name
					};
					bbosRepository.SaveItem (product);
				} 

				needToUpdateLastUpdated = true;
			}

			if (categoryLists.SpecieList != null) 
			{
				bbosRepository.DeleteAllItems<DataModels.Specie> ();
				foreach (var wsSpecie in categoryLists.SpecieList) 
				{
					var specie = new DataModels.Specie () {
						SpecieId = wsSpecie.Id,
						Name = wsSpecie.Name
					};
					bbosRepository.SaveItem (specie);
				} 

				needToUpdateLastUpdated = true;
			}

			if (categoryLists.ServiceList != null) 
			{
				bbosRepository.DeleteAllItems<DataModels.Service> ();
				foreach (var wsService in categoryLists.ServiceList) 
				{
					var service = new DataModels.Service () {
						ServiceId = wsService.Id,
						Name = wsService.Name
					};
					bbosRepository.SaveItem (service);
				} 

				needToUpdateLastUpdated = true;
			}

			if (needToUpdateLastUpdated) 
			{
				UpdateLookUpListLastUpdated ();
			}

			if (categoryLists.StateList != null) 
			{
				bbosRepository.DeleteAllItems<DataModels.State> ();
				foreach (var wsService in categoryLists.StateList) 
				{
					var service = new DataModels.State () {
						StateId = wsService.Id,
						Name = wsService.Name
					};
					bbosRepository.SaveItem (service);
				} 

				needToUpdateLastUpdated = true;
			}

			if (categoryLists.TerminalMarketList != null) 
			{
				bbosRepository.DeleteAllItems<DataModels.TerminalMarket> ();
				foreach (var wsService in categoryLists.TerminalMarketList) 
				{
					var service = new DataModels.TerminalMarket () {
						TerminalMarketId = wsService.Id,
						Name = wsService.Name,
						StateId = wsService.StateId
					};
					bbosRepository.SaveItem (service);
				} 

				needToUpdateLastUpdated = true;
			}

			if (needToUpdateLastUpdated) 
			{
				UpdateLookUpListLastUpdated ();
			}
		}

		/// <summary>
		/// Gets the look up list last updated.
		/// </summary>
		/// <returns>The look up list last updated.</returns>
		public DateTime GetLookUpListLastUpdated ()
		{
			var returnValue = DateTime.MinValue;

			var bbosRepository = new BBOSRepository ();
			var lookUpLastUpdated = bbosRepository.GetAllItems<DataModels.LookUpLastUpdated> ().FirstOrDefault ();

			if (lookUpLastUpdated != null) 
			{
				returnValue = lookUpLastUpdated.LastUpdatedDateTime;
			}

			return returnValue;
		}

		/// <summary>
		/// Updates the LookUpLastUpdated, used so we can tell the services when an update is needed
		/// </summary>
		public void UpdateLookUpListLastUpdated ()
		{
			var bbosRepository = new BBOSRepository ();

			var lookUpLastUpdated = bbosRepository.GetAllItems<DataModels.LookUpLastUpdated> ().FirstOrDefault ();
			if (lookUpLastUpdated == null) 
			{
				lookUpLastUpdated = new DataModels.LookUpLastUpdated ();
			}
			lookUpLastUpdated.LastUpdatedDateTime = DateTime.Now;

			bbosRepository.SaveItem (lookUpLastUpdated);
		}
	}
}

