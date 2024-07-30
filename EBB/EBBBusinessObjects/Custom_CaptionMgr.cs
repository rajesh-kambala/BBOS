/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2020

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: Custom_Caption
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Data;
using System.Threading;
using System.Globalization;

using TSI.Arch;
using TSI.BusinessObjects;
using TSI.Utils;
using TSI.Security;
using TSI.DataAccess;
using PRCo.EBB.BusinessObjects;

namespace PRCo.EBB.Util
{
    /// <summary>
    /// Data Manager for the Custom_Caption class.
    /// </summary>
    [Serializable]
	public class Custom_CaptionMgr : EBBObjectMgr {
		public const string COL_CODE	= "Capt_Code";
		public const string COL_MEANING	= "Meaning";
        public const string COL_NAME    = "Capt_Family";
        public const string COL_ORDER   = "Capt_Order";

        public const string COL_CAPT = "Capt";

        protected const string SQL_GET_BY_NAME_SELECT = "SELECT RTRIM(Capt_Family) AS Capt_Family, RTRIM(Capt_Code) AS Capt_Code, ISNULL({0}, Capt_US) AS " + COL_MEANING + " FROM Custom_Captions WITH (NOLOCK) ";
        protected const string SQL_GET_BY_NAME_WHERE = " WHERE " + COL_NAME + "={0} AND Capt_Deleted IS NULL";
        protected const string SQL_GET_VALUE = "from Custom_Captions Where " + COL_NAME + "={0} AND " + COL_CODE + "={1} AND Capt_Deleted IS NULL";

		#region TSI Framework Generated Code
		/// <summary>
		/// Constructor to initialize data manager
		/// </summary>
		/// <returns></returns>
		public Custom_CaptionMgr(){}

		/// <summary>
		/// Constructor to initialize data manager
		/// </summary>
		/// <param name="oLogger">Logger</param>
		/// <param name="oUser">Current User</param>
		public Custom_CaptionMgr(ILogger oLogger,
			IUser oUser): base(oLogger, oUser){}

		/// <summary>
		/// Constructor to initialize data manager
		/// </summary>
		/// <param name="oConn">DB Connection</param>
		/// <param name="oLogger">Logger</param>
		/// <param name="oUser">Current User</param>
		public Custom_CaptionMgr(IDbConnection oConn,
			ILogger oLogger,
			IUser oUser): base(oConn, oLogger, oUser){}

		/// <summary>
		/// Constructor using the Logger, User, and Transaction
		/// of the specified Manager to initialize this manager.
		/// </summary>
		/// <param name="oBizObjMgr">Business Object Manager</param>
		public Custom_CaptionMgr(BusinessObjectMgr oBizObjMgr): base(oBizObjMgr){}

		/// <summary>
		/// Creates an instance of the Custom_Caption business object
		/// </summary>
		/// <returns>IBusinessObject</returns>
		override protected IBusinessObject InstantiateBusinessObject(IDictionary oData) {
			return new Custom_Caption();
		}

		/// <summary>
		/// The name of the table our business object
		/// is mapped to.
		/// </summary>
		/// <returns>Table Name</returns>
		override public string GetTableName() {
			return "Custom_Caption";
		}

		/// <summary>
		/// The name of the business object class.
		/// </summary>
		/// <returns>Business Object Name</returns>
		override public string GetBusinessObjectName() {
			return "PRCo.EBB.BusinessObjects.Custom_Caption";
		}

		/// <summary>
		/// The fields that uniquely identify this object.
		/// </summary>
		/// <returns>IList</returns>
		override public IList GetKeyFields() {
			return null;
		}
		#endregion

		
		/// <summary>
		/// Retrieves the Lookup Codes with the specified
		/// name sorted by meaning.
		/// </summary>
		/// <param name="szName">Lookup Code Name</param>
		/// <returns>LookupValue objects</returns>
		public IBusinessObjectSet GetByName(string szName) {
			IList oParameters = GetParmList(COL_NAME, szName);

            string szSQL = string.Format(SQL_GET_BY_NAME_SELECT, GetLocalizedColName(COL_CAPT, false));
            szSQL += FormatSQL(SQL_GET_BY_NAME_WHERE, oParameters);
            szSQL += GetSortClause(GetSortList(COL_ORDER, true), false);
			return GetObjectsByCustomSQL(szSQL, oParameters);
		}

		/// <summary>
		/// Returns the value for the specified name and code
		/// </summary>
		/// <param name="szName">Lookup Value Name</param>
		/// <param name="szCode">Lookup Value Code</param>
		/// <returns></returns>
		public string GetMeaning(string szName, string szCode) {
			IList oParameters = new ArrayList();
			oParameters.Add(new ObjectParameter(COL_NAME, szName));
			oParameters.Add(new ObjectParameter(COL_CODE, szCode));

            string szSQL = string.Format("SELECT {0} AS " + COL_MEANING + " ", GetLocalizedColName("Capt", false), true);
            return (string)GetDBAccess().ExecuteScalar(FormatSQL(szSQL + SQL_GET_VALUE, oParameters), oParameters);
		}
    }
}
