/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: EBBObjectMgr
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq.Expressions;
using System.Text;
using System.Threading;
using TSI.Arch;
using TSI.BusinessObjects;
using TSI.DataAccess;
using TSI.Security;
using TSI.Utils;

namespace PRCo.EBB.BusinessObjects
{
	/// <summary>
	/// Provides common data access functionality for the 
	/// EBB business objects.
	/// </summary>
    [Serializable]
	abstract public class EBBObjectMgr : BusinessObjectMgr {

		/// <summary>
		/// Constructor
		/// </summary>
		public EBBObjectMgr(){}

		/// <summary>
		/// Constructor
		/// </summary>
		/// <param name="oLogger">Logger</param>
		/// <param name="oUser">Current User</param>
		public EBBObjectMgr(ILogger oLogger, 
			IUser oUser): base(oLogger, oUser){}

		/// <summary>
		/// Constructor
		/// </summary>
		/// <param name="oConn">DB Connection</param>
		/// <param name="oLogger">Logger</param>
		/// <param name="oUser">Current User</param>
		public EBBObjectMgr(IDbConnection oConn,
			ILogger oLogger,
			IUser oUser): base(oConn, oLogger, oUser){
			CurrentDBConnection = oConn;
		}

		/// <summary>
		/// Constructor
		/// </summary>
		/// <param name="oTran">Transaction</param>
		/// <param name="oLogger">Logger</param>
		/// <param name="oUser">Current User</param>
		public EBBObjectMgr(IDbTransaction oTran,
			ILogger oLogger,
			IUser oUser): base(oTran, oLogger, oUser) {}

		/// <summary>
		/// Constructor using the Logger, User, and Transaction
		/// of the specified Manager to initialize this manager.
		/// </summary>
		/// <param name="oBizObjMgr">Business Object Manager</param>
        public EBBObjectMgr(BusinessObjectMgr oBizObjMgr) : base(oBizObjMgr) { }

		override protected void InitSettings() {
			base.InitSettings();
            UsesAuditFields = false;
		}

        public override bool  UsesIdentity {
	        get { 
		            return base.UsesIdentity;
	            }
	        set { 
		            base.UsesIdentity = value;
	        }
        }

		/// <summary>
		/// For efficiency, we sometimes issue update SQL statements to update
		/// large number of records instead of retrieving them as objects and 
		/// then updating them individually.  In this scenario, we want to ensure
		/// the audit fields are updated appropriately.
		/// </summary>
		/// <returns></returns>
		protected string GetAuditFieldUpdateClause() {
			return COL_UPDATED_USER_ID + "=" + _oUser.UserID + ", " + COL_UPDATED_DATETIME + "=" + GetDBAccess().PrepareValueForSQL(DateTime.Now);
		}

		/// <summary>
		/// For efficiency, we sometimes issue update SQL statements to update
		/// large number of records instead of retrieving them as objects and 
		/// then updating them individually.  In this scenario, we want to ensure
		/// the optlock field is updated appropriately.
		/// </summary>
		protected string GetOptLockUpdateClause() {
			return COL_OPT_LOCK + "='" + CreateOptLockValue() + "'";
		}


		/// <summary>
		/// Returns the current user cast
		/// to IPRWebUser
		/// </summary>
        /// <returns>IPRWebUser</returns>
		virtual public IPRWebUser GetPRWebUser() {
            return (IPRWebUser)_oUser;
		}

		/// <summary>
		/// Executes a stored procedure that does not
		/// have any output.
		/// </summary>
		/// <param name="szName">Stored Procedure Name</param>
		/// <param name="oParameters">Parameters</param>
		/// <param name="oTran">Transaction</param>
		virtual protected void ExecuteStoredProcedure(string szName,
			IList oParameters,
			IDbTransaction oTran) {
			if ((szName == null) ||
				(szName.Length == 0)) {
				throw new ArgumentNullException("szName");
			}

			GetDBAccess().ExecuteNonQuery(szName, oParameters, oTran, CommandType.StoredProcedure);
		}


		/// <summary>
		/// Takes the list of values and builds a comma-delimited
		/// string of values for use in an 'IN' clause.
		/// </summary>
		/// <param name="oValueList">List of Values</param>
		/// <returns>String of Values</returns>
		virtual public string BuildInList(IList oValueList) {
			StringBuilder sbInClause = new StringBuilder("(");

			foreach (object oValue in oValueList) {
				if (sbInClause.Length > 1) {
					sbInClause.Append(",");
				}
				sbInClause.Append(PrepareValueForSQL(oValue));
			}
			sbInClause.Append(")");

			return sbInClause.ToString();
		}

		/// <summary>
		/// Returns / Sets the current DB connection.  Does
		/// not open a connection if one does not exist.
		/// </summary>
		public IDbConnection CurrentDBConnection {
			get {return _oDBConnection;}
			set {_oDBConnection = value;
				if (value != null) {
					GetDBAccess().SetDbConnection(value);
				}
			}
		}

		/// <summary>
		/// Appends an "And" condition to the specified Where SQL string.
		/// Translates the wildcard characters.  If the specified string
		/// has a length > 0, and "AND" clause is added.
		/// </summary>
		/// <param name="sbSQL">SQL String</param>
		/// <param name="oParameters">Parameters</param>
		/// <param name="szColumn">Column Name</param>
		/// <param name="szValue">Value</param>
		virtual public void AddStringCondition(StringBuilder sbSQL,
			IList oParameters,
			string szColumn,
			string szValue) {
			if (!String.IsNullOrEmpty(szValue)) {
				AddCondition(sbSQL, oParameters, szColumn, "Like", TranslateWildCards(szValue));
			}
		}

		/// <summary>
		/// Adds a condition to the current SQL string.
		/// Helper method for building the search SQL.
		/// </summary>
		/// <param name="sbSQL">Search SQL</param>
		/// <param name="oParameters">Parameter List</param>
		/// <param name="szColumn">Column Name To Add</param>
		/// <param name="szCondition">Condition To Add</param>
		/// <param name="oValue">Value to Add</param>
        virtual public void AddCondition(StringBuilder sbSQL,
									IList oParameters,
									string szColumn,
									string szCondition,
									object oValue) {

			if (sbSQL.Length > 0) {
				sbSQL.Append(" AND ");
			}

			sbSQL.Append(szColumn);
			sbSQL.Append(" ");
			sbSQL.Append(szCondition);
			sbSQL.Append(" {");
			sbSQL.Append(oParameters.Count.ToString());
			sbSQL.Append("}");


			oParameters.Add(new ObjectParameter("Parm" + oParameters.Count.ToString(), oValue));
		}


        /// <summary>
        /// Adds a condition to the current SQL string.
        /// Helper method for building the search SQL.
        /// </summary>
        /// <param name="sbSQL">Search SQL</param>
        /// <param name="oParameters">Parameter List</param>
        /// <param name="szColumn">Column Name To Add</param>
        /// <param name="szCondition">Condition To Add</param>
        /// <param name="oValue">Value to Add</param>
        virtual public void AddORCondition(StringBuilder sbSQL,
                                    IList oParameters,
                                    string szColumn,
                                    string szCondition,
                                    object oValue) {

            if (sbSQL.Length > 0) {
                sbSQL.Append(" OR ");
            }

            sbSQL.Append(szColumn);
            sbSQL.Append(" ");
            sbSQL.Append(szCondition);
            sbSQL.Append(" {");
            sbSQL.Append(oParameters.Count.ToString());
            sbSQL.Append("}");


            oParameters.Add(new ObjectParameter("Parm" + oParameters.Count.ToString(), oValue));
        }

		/// <summary>
		/// Adds an IN condition to the current SQL string.
		/// Helper method for building the search SQL.
		/// </summary>
		/// <param name="sbSQL">Search SQL</param>
		/// <param name="szColumn">Column Name To Add</param>
		/// <param name="szCondition">Condition To Add</param>
		/// <param name="oValueList">ValueList to Generate an IN clause for</param>
        virtual public void AddInCondition(StringBuilder sbSQL,
			string szColumn,
			string szCondition,
			IList  oValueList) {

			if (oValueList.Count > 0) {
				if (sbSQL.Length > 0) {
					sbSQL.Append(" AND ");
				}

				sbSQL.Append(szColumn);
				sbSQL.Append(szCondition);
				sbSQL.Append(BuildInList(oValueList));
			}
		}

		/// <summary>
		/// EBB persisted objects have a single key field.  This
		/// method will retrieve IEBB Derived objects by a list of
		/// key values.
		/// </summary>
		/// <param name="oKeyValueList">List of Key Values</param>
		/// <param name="oSortList">List of SortCriterion objects</param>
		/// <returns></returns>
		public IBusinessObjectSet GetObjectByKeys(IList oKeyValueList, IList oSortList) {
			StringBuilder sbSQL = new StringBuilder(GetKeyFields()[0].ToString());
			sbSQL.Append(" in ");
			sbSQL.Append(BuildInList(oKeyValueList));
			return GetObjects(sbSQL.ToString(), oSortList);
		}

		/// <summary>
		/// Returns the object for the specified WHERE clause.
		/// Throws an ObjectNotFound exception if nothing is
		/// found.
		/// </summary>
		/// <param name="szWhereClause">Where clause</param>
		/// <returns></returns>
		public IBusinessObject GetObject(string szWhereClause) {
			return GetObject(szWhereClause, null);
		}

		/// <summary>
		/// Returns the object for the specified WHERE clause.
		/// Throws an ObjectNotFound exception if nothing is 
		/// found.
		/// </summary>
		/// <param name="szWhereClause">Where clause</param>
		/// <param name="oParmList">Parameter List</param>
		/// <returns></returns>
		public IBusinessObject GetObject(string szWhereClause, IList oParmList) {
			StringBuilder sbSQL = new StringBuilder(GetSelectFromClause());
			
			if (!szWhereClause.ToLower().Trim().StartsWith("where")) {
				sbSQL.Append(" where ");
			}
			sbSQL.Append(szWhereClause);

			return GetObjectByCustomSQL(sbSQL.ToString(), oParmList);
		}

		/// <summary>
		/// Creates a new set of BusinessObjects from the specified SourceSet
		/// for the specifed PageNumber.
		/// </summary>
		/// <param name="oSourceSet">Source Set</param>
		/// <param name="iPageSize">Page Size</param>
		/// <param name="iPageNumber">Page Number</param>
		/// <returns></returns>
		protected IBusinessObjectSet ApplyPaging(IBusinessObjectSet oSourceSet,
			                                     int iPageSize,
			                                     int iPageNumber) {

			IBusinessObjectSet oResults = new BusinessObjectSet();


			// We are only implementing paging if our page
			// size is > 0.
			if (iPageSize > 0) {
				int iRecordCountStart = 1;
				int iRecordCountEnd   = 0;

				// Determine where we should start and end when iterating
				// through our set.
				if (iPageNumber > 1) {
					iRecordCountStart = ((iPageNumber-1) * iPageSize) + 1;
				}
				iRecordCountEnd = iRecordCountStart + iPageSize;

				for (int i=iRecordCountStart; i< iRecordCountEnd; i++) {
					if (i > oSourceSet.Count) {
						break;
					}
					oResults.Add(oSourceSet[i-1]);
				}
			} else {
				oResults = oSourceSet;
			}

			oResults.PageNum    = iPageNumber;
			oResults.PageSize   = iPageSize;
			oResults.TotalCount = oSourceSet.Count;

			return oResults;
		}


        /// <summary>
        /// Helper method that localizes a column name by looking
        /// at the current culture and, if not US English, appends
        /// the language portion of the name to the column name.
        /// </summary>
        /// <param name="szColumnName"></param>
        /// <returns></returns>
        public string GetLocalizedColName(string szColumnName) {
            return GetLocalizedColName(szColumnName, true);
        }


        /// <summary>
        /// Helper method that localizes a column name by looking
        /// at the current culture and, if not US English, appends
        /// the language portion of the name to the column name.
        /// </summary>
        /// <param name="szColumnName"></param>
        /// <param name="bIgnoreUS">Indicates the column doesn't have a suffix for US English</param>
        /// <returns></returns>
        public string GetLocalizedColName(string szColumnName, bool bIgnoreUS) {
            if  ((bIgnoreUS) &&
                (Thread.CurrentThread.CurrentCulture.Name == "en-US")) {
                return szColumnName;
            }

            // CRM names the US English colums with "US" insted of "EN"
            if (Thread.CurrentThread.CurrentCulture.Name == "en-US") {
                return szColumnName +"_US";
            } else {
                return szColumnName + "_" + Thread.CurrentThread.CurrentCulture.Name.Substring(0, 2).ToUpper();
            }
        }

        /// <summary>
        /// Returns an ID from the CRM usp_getNextId stored procedure
        /// for the table managed by this object manager.
        /// </summary>
        /// <returns></returns>
        public int GetRecordID() {
            return GetRecordID(GetTableName(), null);
        }

        /// <summary>
        /// Returns an ID from the CRM usp_getNextId stored procedure
        /// for the specified table.
        /// </summary>
        /// <param name="szTableName"></param>
        /// <returns></returns>
        public int GetRecordID(string szTableName) {
            return GetRecordID(szTableName, null);
        }

        /// <summary>
        /// Returns an ID from the CRM usp_getNextId stored procedure
        /// for the specified table.
        /// </summary>
        /// <param name="szTableName"></param>
        /// <param name="oTran"></param>
        /// <returns></returns>
        public int GetRecordID(string szTableName, IDbTransaction oTran) {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("TableName", szTableName));

            ObjectParameter oReturnParameter = new ObjectParameter("Return", 0, ParameterDirection.Output);
            oParameters.Add(oReturnParameter);
    
            GetDBAccess().ExecuteNonQuery("usp_getNextId", oParameters, oTran, CommandType.StoredProcedure);
            
            return Convert.ToInt32(oReturnParameter.Value);            
        }

        /// <summary>
        /// Helper method that adds the parameters for the audit trail columns
        /// to the specifed arraylist.
        /// </summary>
        /// <param name="oParameters"></param>
        /// <param name="szColumPrefix"></param>
        public void AddAuditTrailParametersForInsert(ArrayList oParameters, string szColumPrefix) {
            if (_oUser == null) {
                oParameters.Add(new ObjectParameter(szColumPrefix + "_CreatedBy", null));
            } else {
                oParameters.Add(new ObjectParameter(szColumPrefix + "_CreatedBy", _oUser.UserID));
            }
            oParameters.Add(new ObjectParameter(szColumPrefix + "_CreatedDate", DateTime.Now));
            AddAuditTrailParametersForUpdate(oParameters, szColumPrefix);
            
        }

        /// <summary>
        /// Helper method that adds the parameters for the audit trail columns
        /// to the specifed arraylist.
        /// </summary>
        /// <param name="oParameters"></param>
        /// <param name="szColumPrefix"></param>
        public void AddAuditTrailParametersForUpdate(ArrayList oParameters, string szColumPrefix) {
            if (_oUser == null) {
                oParameters.Add(new ObjectParameter(szColumPrefix + "_UpdatedBy", null));
            } else {
                oParameters.Add(new ObjectParameter(szColumPrefix + "_UpdatedBy", _oUser.UserID));

            }
            oParameters.Add(new ObjectParameter(szColumPrefix + "_UpdatedDate", DateTime.Now));
            oParameters.Add(new ObjectParameter(szColumPrefix + "_TimeStamp", DateTime.Now));
        }

        /// <summary>
        /// Helper method to format the SQL and then execute the Insert statement.
        /// </summary>
        /// <param name="szTableName"></param>
        /// <param name="szSQL"></param>
        /// <param name="oParameters"></param>
        public void ExecuteInsert(string szTableName, string szSQL, ArrayList oParameters) {
            ExecuteInsert(szTableName, szSQL, oParameters, null);
        }

        /// <summary>
        /// Helper method to format the SQL and then execute the Insert statement.
        /// </summary>
        /// <param name="szTableName"></param>
        /// <param name="szSQL"></param>
        /// <param name="oParameters"></param>
        /// <param name="oTran"></param>
        public void ExecuteInsert(string szTableName, string szSQL, ArrayList oParameters, IDbTransaction oTran) {
            string szFormattedSQL = FormatSQL(szSQL, oParameters);
            if (GetDBAccess().ExecuteNonQuery(szFormattedSQL, oParameters, oTran) == 0) {
                throw new ApplicationUnexpectedException("No " + szTableName + " Records Inserted.");
            }
        }

        /// <summary>
        /// Helper method to format the SQL and then execute the Insert statement.
        /// </summary>
        /// <param name="szTableName"></param>
        /// <param name="szSQL"></param>
        /// <param name="oParameters"></param>
        public int ExecuteIdentityInsert(string szTableName, string szSQL, ArrayList oParameters) {
            return ExecuteIdentityInsert(szTableName, szSQL, oParameters, null);
        }

        /// <summary>
        /// Helper method to format the SQL and then execute the Insert statement.
        /// </summary>
        /// <param name="szTableName"></param>
        /// <param name="szSQL"></param>
        /// <param name="oParameters"></param>
        /// <param name="oTran"></param>
        public int ExecuteIdentityInsert(string szTableName, string szSQL, ArrayList oParameters, IDbTransaction oTran) {
            string szFormattedSQL = FormatSQL(szSQL, oParameters) + ";SELECT SCOPE_IDENTITY();";
            object oID = GetDBAccess().ExecuteScalar(szFormattedSQL, oParameters, oTran);
            return Convert.ToInt32(oID);
        }


        protected const string SQL_PRTTRANSACTION_INSERT = "INSERT INTO PRTransaction (prtx_TransactionId, prtx_CompanyId, prtx_PersonId, prtx_EffectiveDate, prtx_AuthorizedInfo, prtx_Explanation, prtx_Status, prtx_CreatedBy, prtx_CreatedDate, prtx_UpdatedBy, prtx_UpdatedDate, prtx_TimeStamp) VALUES ({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11})";

        /// <summary>
        /// Creates a new open PRTransaction
        /// </summary>
        /// <param name="iCompanyID"></param>
        /// <param name="iPersonID"></param>
        /// <param name="szAuthorizationInfo"></param>
        /// <param name="szExplanation"></param>
        /// <param name="oTran"></param>
        /// <returns></returns>
        public int CreatePIKSTransaction(int iCompanyID,
                                         int iPersonID,
                                         string szAuthorizationInfo,
                                         string szExplanation,
                                         IDbTransaction oTran) {


            ArrayList oParameters = new ArrayList();
            int iTransactionID = GetRecordID("PRTransaction", oTran);
            oParameters.Add(new ObjectParameter("prtx_TransactionId", iTransactionID));
            
            if (iCompanyID == 0) {
                oParameters.Add(new ObjectParameter("prtx_CompanyId", null));
            } else {
                oParameters.Add(new ObjectParameter("prtx_CompanyId", iCompanyID));
            }

            if (iPersonID == 0) {
                oParameters.Add(new ObjectParameter("prtx_PersonId", null));
            } else {
                oParameters.Add(new ObjectParameter("prtx_PersonId", iPersonID));
            }
            
            oParameters.Add(new ObjectParameter("prtx_EffectiveDate", DateTime.Now));
            oParameters.Add(new ObjectParameter("prtx_AuthorizedInfo", szAuthorizationInfo));
            oParameters.Add(new ObjectParameter("prtx_Explanation", szExplanation));
            oParameters.Add(new ObjectParameter("prtx_Status", "O"));
            AddAuditTrailParametersForInsert(oParameters, "prtx");
            ExecuteInsert("PRTransaction", SQL_PRTTRANSACTION_INSERT, oParameters, oTran);

            return iTransactionID;
        }



        protected const string SQL_PRTTRANSACTIONDETAIL_INSERT = "INSERT INTO PRTransactionDetail (prtd_TransactionId, prtd_EntityName, prtd_ColumnName, prtd_Action, prtd_ColumnType, prtd_OldValue, prtd_NewValue, prtd_CreatedBy, prtd_CreatedDate, prtd_UpdatedBy, prtd_UpdatedDate, prtd_TimeStamp) VALUES ({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11})";

        /// <summary>
        /// Creates a PRTransactionDetail record for the specified
        /// PRTransaction.
        /// </summary>
        /// <param name="iTransactionID"></param>
        /// <param name="szEntityName"></param>
        /// <param name="szColumnName"></param>
        /// <param name="szAction"></param>
        /// <param name="szColumnType"></param>
        /// <param name="szOldValue"></param>
        /// <param name="szNewValue"></param>
        /// <param name="oTran"></param>
        /// <returns></returns>
        public int CreatePIKSTransactionDetail(int iTransactionID,
                                             string szEntityName,
                                             string szColumnName,
                                             string szAction,
                                             string szColumnType,
                                             string szOldValue,
                                             string szNewValue,
                                             IDbTransaction oTran) {


            ArrayList oParameters = new ArrayList();
            //oParameters.Add(new ObjectParameter("prtd_TransactionDetailId", GetRecordID("PRTransactionDetail", oTran)));
            oParameters.Add(new ObjectParameter("prtd_TransactionId", iTransactionID));
            oParameters.Add(new ObjectParameter("prtd_EntityName", szEntityName));
            oParameters.Add(new ObjectParameter("prtd_ColumnName", szColumnName));
            oParameters.Add(new ObjectParameter("prtd_Action", szAction));
            oParameters.Add(new ObjectParameter("prtd_ColumnType", szColumnType));
            oParameters.Add(new ObjectParameter("prtd_OldValue", szOldValue));
            oParameters.Add(new ObjectParameter("prtd_NewValue", szNewValue));
            AddAuditTrailParametersForInsert(oParameters, "prtd");
            int iTransactionDetailID = ExecuteIdentityInsert("PRTransactionDetail", SQL_PRTTRANSACTIONDETAIL_INSERT, oParameters, oTran);

            return iTransactionDetailID;
        }


        protected const string SQL_PRTRANSACTION_CLOSE = "UPDATE PRTransaction SET prtx_Status={1}, prtx_CloseDate={2}, prtx_UpdatedBy={3}, prtx_UpdatedDate={4}, prtx_Timestamp={5} WHERE prtx_TransactionId={0}";

        /// <summary>
        /// Updates the specified PRTransaction setting the appropriate
        /// values to close it.
        /// </summary>
        /// <param name="iTransactionID"></param>
        /// <param name="oTran"></param>
        public void ClosePIKSTransaction(int iTransactionID, IDbTransaction oTran) {

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prtx_TransactionId", iTransactionID));
            oParameters.Add(new ObjectParameter("prtx_Status", "C"));
            oParameters.Add(new ObjectParameter("prtx_CloseDate", DateTime.Now));
            AddAuditTrailParametersForUpdate(oParameters, "prtx");

            string szSQL = FormatSQL(SQL_PRTRANSACTION_CLOSE, oParameters);
            _oDBAccess.ExecuteNonQuery(szSQL, oParameters, oTran);
        }

        public int CreateTask(int iAssignedToUserID,
                                  string szStatus,
                                  string szNotes,
                                  string szCategory,
                                  string szSubcategory,
                                  IDbTransaction oTran)
        {
            return CreateTask(iAssignedToUserID,
                        szStatus,
                        szNotes,
                        szCategory,
                        szSubcategory,
                        0,
                        oTran);
        }



        /// <summary>
        /// Creates a task in BBS CRM.
        /// </summary>
        /// <param name="iAssignedToUserID"></param>
        /// <param name="szStatus"></param>
        /// <param name="szNotes"></param>
        /// <param name="szCategory"></param>
        /// <param name="szSubcategory"></param>
        /// <param name="iFileID"></param>
        /// <param name="oTran">Optional</param>
        public int CreateTask(int iAssignedToUserID,
                                  string szStatus,
                                  string szNotes,
                                  string szCategory,
                                  string szSubcategory,
                                  int iFileID,
                                  IDbTransaction oTran) {

            int iRelatedCompany = 0;
            int iRelatedPerson = 0;
            
            if (_oUser != null) {
                iRelatedCompany = ((IPRWebUser)_oUser).prwu_BBID;
                iRelatedPerson = ((IPRWebUser)_oUser).peli_PersonID;
            }
           
            return CreateTask(iAssignedToUserID, 
                        szStatus, 
                        szNotes, 
                        szCategory, 
                        szSubcategory,
                        iRelatedCompany,
                        iRelatedPerson,
                        iFileID,
                        null,
                        oTran);
        }


        public int CreateTask(int iAssignedToUserID,
                                  string szStatus,
                                  string szNotes,
                                  string szCategory,
                                  string szSubcategory,
                                  int iRelatedCompanyID,
                                  int iRelatedPersonID,
                                  IDbTransaction oTran)
        {

            return CreateTask(iAssignedToUserID,
                        szStatus,
                        szNotes,
                        szCategory,
                        szSubcategory,
                        iRelatedCompanyID,
                        iRelatedPersonID,
                        0,
                        null,
                        oTran);
        }

        public int CreateTask(int iAssignedToUserID,
                                  string szStatus,
                                  string szNotes,
                                  string szCategory,
                                  string szSubcategory,
                                  int iRelatedCompanyID,
                                  int iRelatedPersonID,
                                  int iFileID,
                                  string szAction,
                                  IDbTransaction oTran)
        {
            return CreateTask(iAssignedToUserID,
                        szStatus,
                        szNotes,
                        szCategory,
                        szSubcategory,
                        iRelatedCompanyID,
                        iRelatedPersonID,
                        iFileID,
                        szAction,
                        null,
                        null,
                        oTran);
        }


        public int CreateTask(int iAssignedToUserID,
                          string szStatus,
                          string szNotes,
                          string szCategory,
                          string szSubcategory,
                          int iRelatedCompanyID,
                          int iRelatedPersonID,
                          int iFileID,
                          string szAction,
                          string szSubject,
                          IDbTransaction oTran)
        {
            return CreateTask(iAssignedToUserID,
                        szStatus,
                        szNotes,
                        szCategory,
                        szSubcategory,
                        iRelatedCompanyID,
                        iRelatedPersonID,
                        iFileID,
                        szAction,
                        szSubject,
                        null,
                        oTran);
        }

        public int CreateTask(int iAssignedToUserID,
                          string szStatus,
                          string szNotes,
                          string szCategory,
                          string szSubcategory,
                          int iRelatedCompanyID,
                          int iRelatedPersonID,
                          int iFileID,
                          string szAction,
                          string szSubject,
                          string szHasAttachments,
                          IDbTransaction oTran)
        {
            return CreateTask(iAssignedToUserID,
                        szStatus,
                        szNotes,
                        szCategory,
                        szSubcategory,
                        iRelatedCompanyID,
                        iRelatedPersonID,
                        iFileID,
                        szAction,
                        szSubject,
                        szHasAttachments,
                        0,
                        oTran);
        }

        /// <summary>
        /// Creates a task in BBS CRM.
        /// </summary>
        /// <param name="iAssignedToUserID"></param>
        /// <param name="szStatus"></param>
        /// <param name="szNotes"></param>
        /// <param name="szCategory"></param>
        /// <param name="szSubcategory"></param>
        /// <param name="iRelatedCompanyID"></param>
        /// <param name="iRelatedPersonID"></param>
        /// <param name="iFileID"></param>
        /// <param name="szAction"></param>
        /// <param name="szSubject"></param>
        /// <param name="szHasAttachments"></param>
        /// <param name="iChannelIdOverride"></param>
        /// <param name="oTran">Optional</param>
        public int CreateTask(int iAssignedToUserID,
                                  string szStatus,
                                  string szNotes,
                                  string szCategory,
                                  string szSubcategory,
                                  int iRelatedCompanyID,
                                  int iRelatedPersonID,
                                  int iFileID,
                                  string szAction,
                                  string szSubject,
                                  string szHasAttachments,
                                  int iChannelIdOverride,
                                  IDbTransaction oTran) {

            SqlCommand cmdCreate = null;
            SqlParameter parm = null;

            // Create the command
            cmdCreate = new SqlCommand("usp_CreateTask", (SqlConnection)DBConnection, (SqlTransaction)oTran);
            cmdCreate.CommandType = CommandType.StoredProcedure;

            // clear all stored procedure parameters
            cmdCreate.Parameters.Clear();

            // create the return parameter
            parm = cmdCreate.Parameters.Add("ReturnValue", SqlDbType.Int);
            parm.Direction = ParameterDirection.ReturnValue;

            // load the parameters for the stored procedure
            cmdCreate.Parameters.AddWithValue("@StartDateTime", DateTime.Now);
            cmdCreate.Parameters.AddWithValue("@DueDateTime", DateTime.Now);
            cmdCreate.Parameters.AddWithValue("@CreatorUserId", Utilities.GetIntConfigValue("DefaultEBBSystemUserID", -1000));
            cmdCreate.Parameters.AddWithValue("@AssignedToUserId", iAssignedToUserID);
            cmdCreate.Parameters.AddWithValue("@TaskNotes", szNotes);
            cmdCreate.Parameters.AddWithValue("@Action", szAction);
            cmdCreate.Parameters.AddWithValue("@Status", szStatus);
            cmdCreate.Parameters.AddWithValue("@PRCategory", szCategory);
            cmdCreate.Parameters.AddWithValue("@PRSubcategory", szSubcategory);
            cmdCreate.Parameters.AddWithValue("@HasAttachments", szHasAttachments);
            cmdCreate.Parameters.AddWithValue("@Subject", szSubject);

            if (iRelatedCompanyID > 0)
            {
                cmdCreate.Parameters.AddWithValue("@RelatedCompanyId", iRelatedCompanyID);
            }

            if (iRelatedPersonID > 0)
            {
                cmdCreate.Parameters.AddWithValue("@RelatedPersonId", iRelatedPersonID);
            }

            if (iFileID > 0)
            {
                cmdCreate.Parameters.AddWithValue("@PRFileId", iFileID);
            }

            if (iChannelIdOverride > 0)
            {
                cmdCreate.Parameters.AddWithValue("@ChannelIdOverride", iChannelIdOverride);
            }

            cmdCreate.ExecuteNonQuery();

            return Convert.ToInt32(cmdCreate.Parameters["ReturnValue"].Value);
        }

        /// <summary>
        /// Helper method that returns bool values how the PIKS Core
        /// database expect bools to be stored.  Either 'Y' or NULL.
        /// </summary>
        /// <param name="bValue"></param>
        /// <returns></returns>
        public string GetPIKSCoreBool(bool bValue) {
            if (bValue) {
                return "Y";
            }
            return null;
        }

        /// <summary>
        /// Helper method that prepares the company name for a fuzzy match 
        /// by removing variations of the specifed suffix from the name.
        /// </summary>
        /// <param name="szValue"></param>
        /// <param name="szRemove"></param>
        /// <returns></returns>
        public string RemoveCompanySuffixVariations(string szValue, string szRemove) {
            string szFuzzyName = szValue;
            szFuzzyName = RemoveEnding(szFuzzyName, ", " + szRemove);
            szFuzzyName = RemoveEnding(szFuzzyName, ", " + szRemove + ".");
            szFuzzyName = RemoveEnding(szFuzzyName, "," + szRemove);
            szFuzzyName = RemoveEnding(szFuzzyName, "," + szRemove + ".");
            szFuzzyName = RemoveEnding(szFuzzyName, " " + szRemove);
            szFuzzyName = RemoveEnding(szFuzzyName, " " + szRemove + ".");

            return szFuzzyName;
        }

        /// <summary>
        /// Helper method that removes the specified text from the value
        /// if it exists at the end of the string.
        /// </summary>
        /// <param name="szValue"></param>
        /// <param name="szRemove"></param>
        /// <returns></returns>
        public string RemoveEnding(string szValue, string szRemove) {
            if (szValue.EndsWith(szRemove)) {
                return szValue.Substring(0, szValue.Length - szRemove.Length);
            }

            return szValue;
        }

        /// <summary>
        /// Returns a list of BB # who's name's have a fuzzy match
        /// to the specified name.  Common compay suffixes are
        /// ignored.
        /// </summary>
        /// <param name="szCompanyName"></param>
        /// <returns></returns>
        public List<Int32> GetFuzzyMatchCompanyIDs(string szCompanyName) {

            List<Int32> lMatchedIDs = new List<Int32>();

            // If we made it here, we didn't find an exact match.  Now look
            // using some fuzzy logic.
            string szFuzzyName = szCompanyName;
            szFuzzyName = RemoveCompanySuffixVariations(szFuzzyName, "llc");
            szFuzzyName = RemoveCompanySuffixVariations(szFuzzyName, "inc");
            szFuzzyName = RemoveCompanySuffixVariations(szFuzzyName, "co");
            szFuzzyName = RemoveCompanySuffixVariations(szFuzzyName, "ltd");
            szFuzzyName = RemoveCompanySuffixVariations(szFuzzyName, "llp");

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prcse_NameAlphaOnly", szFuzzyName));

            string szSQL = FormatSQL("SELECT prcse_CompanyId FROM PRCompanySearch WHERE prcse_NameAlphaOnly = dbo.ufn_GetLowerAlpha({0})", oParameters);
            IDataReader oReader = null;
            try {
                oReader = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
                while (oReader.Read()) {
                    lMatchedIDs.Add(oReader.GetInt32(0));
                }
            } finally {
                if (oReader != null) {
                    oReader.Close();
                }
            }

            return lMatchedIDs;
        }


        public List<string> GetFuzzyMatchCompanies(string szCompanyName)
        {

            List<string> lMatchedIDs = new List<string>();

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prcse_NameAlphaOnly", szCompanyName));

            string szSQL = FormatSQL("SELECT prcse_FullName FROM PRCompanySearch WITH (NOLOCK) WHERE prcse_NameMatch = dbo.ufn_GetLowerAlpha(dbo.ufn_PrepareCompanyName({0}))", oParameters);
            
            using (IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null)) {
                while (oReader.Read())
                {
                    lMatchedIDs.Add(oReader.GetString(0));
                }
            }

            return lMatchedIDs;
        }

      
        public bool TranslateFromCRMBool(object oValue) {
            if (oValue == DBNull.Value) {
                return false;
            }
            
            if (oValue == null) {
                return false;
            }
            
            if (Convert.ToString(oValue) == "Y") {
                return true;
            }
        
            return false;
        }
        
        protected IDBAccess _oDBAccessFullRights = null;
        
        /// <summary>
        /// Returns a DBAccess object that has full rights to the
        /// database.  Should only be used when an operation needs 
        /// to update a core BBS CRM table.
        /// </summary>
        /// <returns></returns>
        public IDBAccess GetDBAccessFullRights() {
            if (_oDBAccessFullRights == null) {
                _oDBAccessFullRights = DBAccessFactory.getDBAccessProvider("DBConnectionStringFullRights");
                _oDBAccessFullRights.Logger = _oLogger;
            }
            
            return _oDBAccessFullRights;
        }

        protected string _szNoLock = null;
        /// <summary>
        /// Helper method that returns the SQL NOLOCK table hint
        /// if it is enabled.
        /// </summary>
        /// <returns></returns>
        virtual public string GetNoLock() {
            if (_szNoLock == null) {
                if (Utilities.GetBoolConfigValue("SQLNoLockEnabled", true)) {
                    _szNoLock = " WITH (NOLOCK) ";
                } else {
                    _szNoLock = string.Empty;
                }
            }

            return _szNoLock;
        }

        public object GetStringForParamter(string value)
        {
            if (string.IsNullOrEmpty(value))
            {
                return DBNull.Value;
            }

            return value;
        }


        public override string GetUserID()
        {
            if (_oUser == null)
            {
                return "0";
            }

            return ((IPRWebUser)_oUser).prwu_WebUserID.ToString();
        }

        public string GetFormattedEmail(int companyID, int personID, int webUserID, string subject, string message, string culture, string industryType)
        {
            ArrayList parmList = new ArrayList();
            parmList.Add(new ObjectParameter("CompanyID", companyID));
            parmList.Add(new ObjectParameter("PersonID", personID));
            parmList.Add(new ObjectParameter("WebUserID", webUserID));
            parmList.Add(new ObjectParameter("Title", subject));
            parmList.Add(new ObjectParameter("Body", message));
            parmList.Add(new ObjectParameter("AddresseeOverride", null));
            parmList.Add(new ObjectParameter("Culture", culture));
            parmList.Add(new ObjectParameter("IndustryType", industryType));

            object[] args = { companyID, personID, webUserID, subject, message, culture, industryType };
            return (string)GetDBAccess().ExecuteScalar("SELECT dbo.ufn_GetFormattedEmail3(@CompanyID, @PersonID, @WebUserID, @Title, @Body, @AddresseeOverride, @Culture, @IndustryType, null, null)", parmList);
        }

        public void SendEmail(string to, string subject, string content, string source)
        {
            string from = GetFromAddress();

            SendEmail(to, from, subject, content, true, null, source, null);
        }

        public void SendEmail_Text(string to, string subject, string content, string source, IDbTransaction oTran)
        {
            SendEmail(to, subject, content, source, oTran, "TEXT");
        }
        public void SendEmail(string to, string subject, string content, string source, IDbTransaction oTran, string contentFormat="HTML")
        {
            string from = GetFromAddress();

            bool blnIsHTML = false;
            if (contentFormat == "HTML")
                blnIsHTML = true;

            SendEmail(to, from, subject, content, blnIsHTML, null, source, oTran);
        }

        /// <summary>
		/// Sends email via usp_CreateEmail with possible attachments
		/// </summary>
		/// <param name="szToAddress">To Address</param>
		/// <param name="szFromAddress">From Address</param>
		/// <param name="szSubject">Subject</param>
		/// <param name="szMessage">Message</param>
        /// <param name="bIsBodyHTML">Mail Format</param>
        /// <param name="lstAttachments">List of Attachment objects</param>
		public void SendEmail(string szToAddress,
                                    string szFromAddress,
                                    string szSubject,
                                    string szMessage,
                                    bool bIsBodyHTML,
                                    List<string> lstAttachments,
                                    string source,
                                    IDbTransaction oTran)
        {
            string szAttachments = string.Empty;

            // Override email address is handled inside usp_CreateEmail
            // It looks for Custom_Caption EmailOverride|Email to exist
            // Very important than QA server have this override defined

            ArrayList parmList = new ArrayList();
            parmList.Add(new ObjectParameter("To", szToAddress));
            parmList.Add(new ObjectParameter("From", szFromAddress));
            parmList.Add(new ObjectParameter("Subject", szSubject));
            parmList.Add(new ObjectParameter("Content", szMessage));
            parmList.Add(new ObjectParameter("Action", "EmailOut"));

            string sSQL = "EXEC usp_CreateEmail " +
                       "@To=@To, " +
                       "@From=@From, " +
                       "@Subject=@Subject, " +
                       "@Content=@Content, " +
                       "@Action=@Action, " +
                       "@DoNotRecordCommunication=1, ";

            if (Utilities.GetBoolConfigValue("EnabledBCCToFromAddress", false))
            {
                sSQL += "@BCC=@BCC, ";
                parmList.Add(new ObjectParameter("BCC", GetFromAddress()));
            }

            if (!string.IsNullOrEmpty(source))
            {
                sSQL += "@Source=@Source, ";
                parmList.Add(new ObjectParameter("Source", source));
            }

            if (lstAttachments != null && lstAttachments.Count > 0)
            {
                foreach (string oAttachment in lstAttachments)
                    szAttachments += oAttachment.Trim() + ";";
                
                szAttachments = szAttachments.TrimEnd(';');

                sSQL += "@AttachmentFileName=@AttachmentFileName, ";
                parmList.Add(new ObjectParameter("AttachmentFileName", szAttachments));
            }

            if (bIsBodyHTML)
                sSQL += "@Content_Format='HTML';";
            else
                sSQL += "@Content_Format='TEXT';";

            // If mail is disabled, then exit.
            if (!Utilities.GetBoolConfigValue("EmailEnabled"))
                return;

            if(oTran == null)
                GetDBAccess().ExecuteScalar(sSQL, parmList);
            else
                GetDBAccess().ExecuteScalar(sSQL, parmList, oTran);
        }

        public string GetFromAddress()
        {
            return Utilities.GetConfigValue("EMailFromAddress");
        }

        public string GetCompanyName(int companyID)
        {
            string sql = string.Format("SELECT comp_PRBookTradestyle FROM Company WITH (NOLOCK) WHERE comp_CompanyID={0}", companyID);
            return (string)GetDBAccess().ExecuteScalar(sql);
        }

        public string GetLocalSourceCondition()
        {
            if (((IPRWebUser)_oUser).HasLocalSourceDataAccess())
            {
                return string.Format("(LocalSourceStateID IS NULL OR LocalSourceStateID IN (SELECT DISTINCT prlsr_StateID FROM PRLocalSourceRegion WITH (NOLOCK) WHERE prlsr_ServiceCode IN ({0})))", ((IPRWebUser)_oUser).GetLocalSourceDataAccessServiceCodes());
            }
            else
            {
                return "comp_PRLocalSource IS NULL";
            }
        }

        public string GetIntlTradeAssociationCondition()
        {
            //3.1.2.1	Add GetIntlTradeAssociationCondition(): Model on GetLocalSourceCondition().  If the User.IsIntrlTradeAssocationUser, then return “comp_PRImporter = ‘Y’”.  Else return null.
            if (((IPRWebUser)_oUser).prcta_IsIntlTradeAssociation)
            {
                return "comp_PRImporter = 'Y'";
            }
            else
            {
                return "1=1";
            }
        }
    }
}
