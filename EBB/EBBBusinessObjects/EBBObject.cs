/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co. 2007-2014

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co. is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: EBBObject
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Configuration;
using System.Data;
using System.IO;
using System.Net;
using System.Text;
using System.Web;

using TSI.Arch;
using TSI.BusinessObjects;
using TSI.Utils;
using PRCo.EBB.Util;

namespace PRCo.EBB.BusinessObjects
{
	/// <summary>
	/// Provides the common functionality for the EBB business objects
	/// </summary>
    [Serializable]
	abstract public class EBBObject : BusinessObject, IEBBObject
	{
		/// <summary>
		/// Indicates this object has started its own local
		/// transaction.
		/// </summary>
		protected bool		_bLocalTransaction;

		/// <summary>
		/// Indicates that when data operations have completed,
		/// if the current transaction should be reset.
		/// </summary>
		protected bool		_bResetTransaction;

		/// <summary>
		/// List of objects to save when this object
		/// is saved.
		/// </summary>
		protected IBusinessObjectSet _oObjectsToSaveOnSave;

		/// <summary>
		/// List of objects to delete when this object
		/// is saved.
		/// </summary>
		protected IBusinessObjectSet _oObjectsToDeleteOnSave;

		/// <summary>
		/// List of objects to save when this object
		/// is deleted.
		/// </summary>
		protected IBusinessObjectSet _oObjectsToSaveOnDelete;

		/// <summary>
		/// List of objects to delete when this object
		/// is deleted.
		/// </summary>
		protected IBusinessObjectSet _oObjectsToDeleteOnDelete;

		/// <summary>
		/// The date/time value to represent NULL since
		/// structures cannot be null.
		/// </summary>
		public static DateTime DATETIME_NULL = DateTime.MinValue;

		protected DateTime			_dtTestToday;

		/// <summary>
		/// Constructor
		/// </summary>
		public EBBObject() {
			_szOptLock = "0";
		}

		/// <summary>
		/// Most objects use an integer ID,
		/// so zero (0) it out.
		/// </summary>
		public override void ClearKeyValues() {
			IList oKeys = new ArrayList();
			oKeys.Add(0);
			SetKeyValues(oKeys);
		}

		/// <summary>
        ///
        /// </summary>
		/// <param name="oTran"></param>
		public override void Delete(IDbTransaction oTran) {
			
			// This will be reset by
			// the deletion.
			bool bIsInDB = IsInDB;
			
			// Our transaction handling methods are instance specific which could
			// cause us a problem since most often the code in the sub-class controls
			// the transactions...  So, just use a little local check here instead of
			// using the helper methods.
			bool bLocalTran = false;
			if (oTran == null) {
				oTran = GetTransaction(oTran);
				bLocalTran = true;
			}

			try {
				base.Delete(oTran);

				if (_oObjectsToDeleteOnDelete != null) {
					_oObjectsToDeleteOnDelete.Delete(oTran);
					_oObjectsToDeleteOnDelete = null;
				}

				if (_oObjectsToSaveOnDelete != null) {
					_oObjectsToSaveOnDelete.Save(oTran);
					_oObjectsToSaveOnDelete = null;
				}

				if (bLocalTran) {
					CommitTransaction();
				}
			} catch {
				if (bLocalTran) {
					RollbackTransaction();
				}
				throw;
			}
		}


		/// <summary>
		/// Saves this object and any associated objects.
		/// </summary>
		/// <param name="oTran"></param>
		public override void Save(IDbTransaction oTran) {

            if ((!IsInDB) &&
                (((int)GetKeyValues()[0]) == 0)) {

    
                if (!_oMgr.UsesIdentity) {
                    IList oKeyValues = new ArrayList();
                    oKeyValues.Add(((EBBObjectMgr)_oMgr).GetRecordID());

                    SetKeyValues(oKeyValues);
                }                    
            }
			
			// Our transaction handling methods are instance specific which could
			// cause us a problem since most often the code in the sub-class controls
			// the transactions...  So, just use a little local check here instead of
			// using the helper methods.
			bool bLocalTran = false;
			if (oTran == null) {
				oTran = GetTransaction(oTran);
				bLocalTran = true;
			}

			try {

				base.Save(oTran);

				if (_oObjectsToSaveOnSave != null) {
					_oObjectsToSaveOnSave.Save(oTran);
					_oObjectsToSaveOnSave = null;
				}

				if (_oObjectsToDeleteOnSave != null) {
					_oObjectsToDeleteOnSave.Delete(oTran);
					_oObjectsToDeleteOnSave = null;
				}

				if (bLocalTran) {
					CommitTransaction();
				}
			} catch {
				if (bLocalTran) {
					RollbackTransaction();
				}
				throw;
			}
		}

		/// <summary>
		/// Returns a valid transaction to use after checking the
		/// specified transaction.  If one is started here, a flag
		/// is set for the other helper methods to process it.
		/// </summary>
		/// <param name="oTran">Transaction</param>
		/// <returns>Transaction</returns>
		virtual protected IDbTransaction GetTransaction(IDbTransaction oTran) {
			_bResetTransaction = true;
			
			// If we're not in a
			// Transaction, then start one.
			if (oTran == null) {
				_bLocalTransaction = true;
				oTran = _oMgr.BeginTransaction();
			} else {
				if (oTran == _oMgr.Transaction) {
					_bResetTransaction = false;
				} else {
					_oMgr.Transaction = oTran;
				}
			}
			return oTran;
		}

		/// <summary>
		/// If this class started the transaction,
		/// it commits it, otherwise nulls out
		/// our reference.
		/// </summary>
		virtual protected void CommitTransaction() {
			if (_bLocalTransaction) {
				_oMgr.Commit();
				_bLocalTransaction =false;
			} else if (_bResetTransaction) {
				_oMgr.Transaction = null;	
			}
		}

		/// <summary>
		/// If this class started the transaction,
		/// it rolls it back, otherwise nulls out
		/// our reference.
		/// </summary>
		virtual protected void RollbackTransaction() {
			if (_bLocalTransaction) {
				_oMgr.Rollback();
				_bLocalTransaction = false;
			} else if (_bResetTransaction) {
				_oMgr.Transaction = null;
			}
		}

		/// <summary>
		/// Adds the specified object to the list of objects that must
		/// be saved when this object is saved.  Typically used to save
		/// objects that do not have a direct association with this objects
		/// such as audit objects.
		/// </summary>
		/// <param name="oObject"></param>
		virtual protected void AddObjectToSaveOnSave(IEBBObject oObject) {
			if (_oObjectsToSaveOnSave == null) {
				_oObjectsToSaveOnSave = _oMgr.CreateBusinessObjectSetType();
			}
			_oObjectsToSaveOnSave.Add(oObject);
		}

		/// <summary>
		/// Adds the specified objects to the list of objects that must
		/// be saved when this object is saved.  Typically used to save
		/// objects that do not have a direct association with this objects
		/// such as audit objects.
		/// </summary>
		/// <param name="oObjectList"></param>
		virtual protected void AddObjectsToSaveOnSave(IBusinessObjectSet oObjectList) {
			if (_oObjectsToSaveOnSave == null) {
				_oObjectsToSaveOnSave = _oMgr.CreateBusinessObjectSetType();
			}
			_oObjectsToSaveOnSave.AddRange(oObjectList);
		}

		/// <summary>
		/// Adds the specified object to the list of objects that must
		/// be deleted when this object is saved.  Typically used to delete
		/// objects that do not have a direct association with this objects
		/// such as audit objects.
		/// </summary>
		/// <param name="oObject"></param>
        virtual protected void AddObjectToDeleteOnSave(IEBBObject oObject) {
			if (_oObjectsToDeleteOnSave == null) {
				_oObjectsToDeleteOnSave = _oMgr.CreateBusinessObjectSetType();
			}
			_oObjectsToDeleteOnSave.Add(oObject);
		}

		/// <summary>
		/// Adds the specified object list to the list of objects that must
		/// be deleted when this object is saved.  Typically used to delete
		/// objects that do not have a direct association with this objects
		/// such as audit objects.
		/// </summary>
		/// <param name="oObjectList"></param>
		virtual protected void AddObjectsToDeleteOnSave(IBusinessObjectSet oObjectList) {
			if (_oObjectsToDeleteOnSave == null) {
				_oObjectsToDeleteOnSave = _oMgr.CreateBusinessObjectSetType();
			}
			_oObjectsToDeleteOnSave.AddRange(oObjectList);
		}

		/// <summary>
		/// Adds the specified object to the list of objects that must
		/// be saved when this object is deleted.  Typically used to save
		/// objects that do not have a direct association with this objects
		/// such as audit objects.
		/// </summary>
		/// <param name="oObject"></param>
        virtual protected void AddObjectToSaveOnDelete(IEBBObject oObject) {
			if (_oObjectsToSaveOnDelete == null) {
				_oObjectsToSaveOnDelete = _oMgr.CreateBusinessObjectSetType();
			}
			_oObjectsToSaveOnDelete.Add(oObject);
		}

		/// <summary>
		/// Adds the specified object list to the list of objects that must
		/// be saved when this object is deleted.  Typically used to save
		/// objects that do not have a direct association with this objects
		/// such as audit objects.
		/// </summary>
		/// <param name="oObjectList"></param>
		virtual protected void AddObjectsToSaveOnDelete(IBusinessObjectSet oObjectList) {
			if (_oObjectsToSaveOnDelete == null) {
				_oObjectsToSaveOnDelete = _oMgr.CreateBusinessObjectSetType();
			}
			_oObjectsToSaveOnDelete.AddRange(oObjectList);
		}

		/// <summary>
		/// Adds the specified object to the list of objects that must
		/// be deleted when this object is deleted.  Typically used to delete
		/// objects that do not have a direct association with this objects
		/// such as audit objects.
		/// </summary>
		/// <param name="oObject"></param>
		virtual protected void AddObjectToDeleteOnDelete(IEBBObject oObject) {
			if (_oObjectsToDeleteOnDelete == null) {
				_oObjectsToDeleteOnDelete = _oMgr.CreateBusinessObjectSetType();
			}
			_oObjectsToDeleteOnDelete.Add(oObject);
		}

		/// <summary>
		/// Adds the specified object list to the list of objects that must
		/// be deleted when this object is deleted.  Typically used to delete
		/// objects that do not have a direct association with this objects
		/// such as audit objects.
		/// </summary>
		/// <param name="oObjectList"></param>
		virtual protected void AddObjectsToDeleteOnDelete(IBusinessObjectSet oObjectList) {
			if (_oObjectsToDeleteOnDelete == null) {
				_oObjectsToDeleteOnDelete = _oMgr.CreateBusinessObjectSetType();
			}
			_oObjectsToDeleteOnDelete.AddRange(oObjectList);
			
		}


		/// <summary>
		/// Method used to simulate the current
		/// date for testing.
		/// </summary>
		/// <param name="dtVal"></param>
		public void SetToday(DateTime dtVal) {
			_dtTestToday = dtVal;
		}

		/// <summary>
		/// Method used to simulate the current
		/// date for testing.
		/// </summary>
		public DateTime GetToday() {
			if (_dtTestToday != EBBObject.DATETIME_NULL) {
				return _dtTestToday;
			}
			return DateTime.Today;
		}

		/// <summary>
		/// Returns the contents of the specified file.
		/// </summary>
		/// <param name="szFileName">File to read</param>
		/// <returns></returns>
		public static string ReadTemplateFile(string szFileName) {
			StringBuilder sbText = new StringBuilder();

			string szTemplate = Path.Combine(Utilities.GetConfigValue("TemplateFolder"), szFileName);

			// Create an instance of StreamReader to read from a file.
			// The using statement also closes the StreamReader.
			using (StreamReader srReader = new StreamReader(szTemplate)) {
				string szLine;
				while ((szLine = srReader.ReadLine()) != null) {
					sbText.Append(szLine);
				}
			}
			
			return sbText.ToString();
		}

        /// <summary>
        /// In order to avoid constant column naming conflicts, we configured the business
        /// objects to not use audit fields when they actually do.  This method ensures
        /// they get set appropriately.
        /// </summary>
        /// <param name="iOptions"></param>
        protected override void PrepareForUnload(int iOptions) {
            base.PrepareForUnload(iOptions);

            if (_bIsInDB) {
                _dtUpdatedDateTime = DateTime.Now;
                _szUpdatedUserID = _oMgr.GetUserID();
            } else {
                // Only set these if they are not
                // already set.
                if (_dtCreatedDateTime == DateTime.MinValue) {
                    _dtCreatedDateTime = DateTime.Now;
                    _dtUpdatedDateTime = DateTime.Now;
                }

                if (string.IsNullOrEmpty(_szCreatedUserID)) {
                    _szCreatedUserID = _oMgr.GetUserID();
                    _szUpdatedUserID = _oMgr.GetUserID();
                }
            }

        }


        //public override void OnBeforeSave() {
        //    base.OnBeforeSave();

        //    if ((!IsInDB) &&
        //        (((int)GetKeyValues()[0]) == 0)) {

        //        IList oKeyValues = new ArrayList();
        //        oKeyValues.Add(((EBBObjectMgr)_oMgr).GetRecordID());

        //        SetKeyValues(oKeyValues);
        //    }

        //}


        protected Custom_CaptionMgr _customCaptionMgr;
        protected Custom_CaptionMgr GetCustomCaptionMgr()
        {
            if (_customCaptionMgr == null)
            {
                _customCaptionMgr = new Custom_CaptionMgr(_oMgr);
            }
            return _customCaptionMgr;
        }

        protected GeneralDataMgr _objectMgr;
        protected GeneralDataMgr GetObjectMgr()
        {
            if (_objectMgr == null)
            {
                _objectMgr = new GeneralDataMgr(_oMgr);
            }
            return _objectMgr;
        }


        protected void AddField(StringBuilder taskMsg, string label, string value)
        {
            taskMsg.Append(label + ": " + value + Environment.NewLine);
        }

        protected IPRWebUser GetWebUser()
        {
            return (IPRWebUser)_oMgr.User;
        }

        public DateTime ConvertToUTC(DateTime dtDateTime, string timeZone) {
            TimeZoneInfo tszLocalTimeZone = TimeZoneInfo.FindSystemTimeZoneById(timeZone);
            return TimeZoneInfo.ConvertTimeToUtc(dtDateTime, tszLocalTimeZone);
        }

	}
}
