/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: PersonList.aspx.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.Threading;
using System.Text;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using TSI.Utils;
using TSI.BusinessObjects;
using TSI.DataAccess;
using PRCo.EBB.BusinessObjects;

namespace PRCo.BBOS.UI.Web.UserManagement {


    /// <summary>
    /// 
    /// </summary>
    public partial class PersonList : PageBase {


        override protected void Page_Load(object sender, EventArgs e) {
            base.Page_Load(sender, e);

            SetPageTitle("BBOS Access Management Tool", GetHQName());
            EnableFormValidation();
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_FUNCTIONS_FILE));
            btnCancel.OnClientClick="bDirty=false;DisableValidation();";
            btnSave.OnClientClick = "bDirty=false;";
            
            if (!IsPostBack) {
                PopulateForm();
                InsertBBOSUsersAudit("View", false, false, null);                
            }
        }

        protected const string SQL_GET_HQ_NAME = "SELECT comp_PRBookTradestyle FROM Company WHERE comp_CompanyID=@comp_CompanyID";
        protected string GetHQName() {
            
            if (Session["HQName"] == null) {
                ArrayList oParameters = new ArrayList();
                oParameters.Add(new ObjectParameter("comp_CompanyID", Session["HQID"]));
                
                Session["HQName"] = GetDBAccess().ExecuteScalar(SQL_GET_HQ_NAME, oParameters);
            }
            
            return (string)Session["HQName"];
        }

        protected const string SQL_SELECT_PERSON_ACCESS = "SELECT pers_PersonID, peli_PersonLinkID, dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, NULL, pers_Suffix) As PersonName, peli_PRTitle, ISNULL(prwu_AccessLevel, 0) prwu_AccessLevel, CityStateCountryShort, peli_PRConvertToBBOS, RTRIM(emai_EmailAddress) AS emai_EmailAddress, Emai_EmailId, comp_CompanyID " +
                   "FROM Person " +
                        "INNER JOIN Person_Link ON pers_PersonID = peli_PersonID " +
                        "INNER JOIN Company on peli_CompanyID = comp_CompanyID " +
                        "INNER JOIN vPRLocation on comp_PRListingCityID = prci_CityID " +
                        "LEFT OUTER JOIN PRWebUser ON peli_PersonLinkID = prwu_PersonLinkID " +
                        "LEFT OUTER JOIN Email ON peli_PersonID = emai_PersonID AND peli_CompanyID = emai_CompanyID " +                        
                "WHERE comp_PRHQID = @comp_HQID " +
                "  AND comp_PRListingStatus IN ('H', 'L', 'N1') " +
                "  AND peli_PRStatus IN (1,2,4) " + 
                "ORDER BY pers_LastName, pers_FirstName, pers_PersonID";
        protected void PopulateForm() {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("comp_HQID", Session["HQID"]));
            
            repPersonList.DataSource = GetDBAccess().ExecuteReader(SQL_SELECT_PERSON_ACCESS, oParameters, CommandBehavior.CloseConnection, null);
            repPersonList.DataBind();
            
            litMembershipMsg.Text = SetMembershipValues();
            hidMaxLicenses.Value = Session["MaxLicenses"].ToString();
            
            SetMultiplePersonText();
            SetLastAccessedDates();
        }            
        
        /// <summary>
        /// Helper method determines if the checkbox should be checked.
        /// </summary>
        /// <param name="oBBOSConvert"></param>
        /// <param name="oAccessLevel"></param>
        /// <returns></returns>
        protected string GetChecked(object oBBOSConvert, object oAccessLevel) {
            if (HasAccess(oBBOSConvert, oAccessLevel)) {
                return " checked ";
            }
            return string.Empty;
        }
        
        /// <summary>
        /// Helper method determines if the current person has access depending
        /// on the specified values and whether or not we're in production mode.
        /// </summary>
        /// <param name="oBBOSConvert"></param>
        /// <param name="oAccessLevel"></param>
        /// <returns></returns>
        protected bool HasAccess(object oBBOSConvert, object oAccessLevel) {

            if (IsBBOSProductionMode()) {
                if ((oAccessLevel != DBNull.Value) &&
                    (Convert.ToInt32(oAccessLevel) >= PRWebUser.SECURITY_LEVEL_1_TRIAL_USER)) {
                    return true;                       
                }
            } else {
                if ((oBBOSConvert != DBNull.Value) &&
                    (Convert.ToString(oBBOSConvert) == "Y")) {
                    return true;   
                }
            }
            
            return false;
        }    
        
        
        protected void btnSaveOnClick(object sender, EventArgs e) {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("comp_HQID", Session["HQID"]));

            // First build a list of the Persons we need to process.
            List<PersonAccess> lPersonAccess = new List<PersonAccess>();
            IDataReader oReader = GetDBAccess().ExecuteReader(SQL_SELECT_PERSON_ACCESS, oParameters, CommandBehavior.CloseConnection, null);
            try {
                while (oReader.Read()) {
                    lPersonAccess.Add(new PersonAccess(oReader.GetInt32(1), 
                                                       oReader.GetInt32(0),
                                                       HasAccess(oReader[6], oReader[4]),
                                                       GetDBAccess().GetString(oReader, 7, null),
                                                       GetDBAccess().GetInt32(oReader, "Emai_EmailId"),
                                                       oReader.GetInt32(9),
                                                       GetDBAccess().GetString(oReader, 2, null)));
                }
            } finally {
                oReader.Close();
            }

            int iLicenseCount = 0;
            int iMaxLicenses = (Int32)Session["MaxLicenses"];
            StringBuilder sbTasMsg = new StringBuilder();
            List<Int32> lAssignedPersonIDs = new List<Int32>();
            
            // Now iterate through our list getting the form values and seeing
            // if we have any work to do.
            GetObjectMgr().ConnectionString = Utilities.GetConfigValue("DBConnectionStringFullRights");
            IDbTransaction oTran = GetObjectMgr().BeginTransaction();
            try {
                bool bAccessChanged = false;
                bool bEmailChanged = false;

                foreach(PersonAccess oPersonAccess in lPersonAccess) {
                
                    //if (lAssignedPersonIDs.Contains(oPersonAccess.PersonID)) {
                    //    AddUserMessage(oPersonAccess.PersonName + " has been assigned access multiple times.  A person should o");
                    //    oTran.Rollback();
                    //    return;
                    //}
                    //lAssignedPersonIDs.Add(oPersonAccess.PersonID);
                
                    bool bGrantAccess = false;
                    if (GetRequestParameter("cb" + oPersonAccess.PersonLinkID.ToString(), false) != null) {
                        bGrantAccess = true;
                    }
                    
                    if (bGrantAccess) {
                        iLicenseCount++;
                        
                        if (iLicenseCount > iMaxLicenses) {
                            AddUserMessage("Only " + iMaxLicenses.ToString() + @" licenses are currently available.  Please deselect the appropriate\nnumber of users or contact Blue Book Services to purchase additional\nlicenses.");
                            oTran.Rollback();
                            return;
                        }
                    }
                    
                    if (bGrantAccess != oPersonAccess.HasAccess) {
                        bAccessChanged = true;
                        
                        // If we're in production mode, we don't actually change the conversion flag
                        // Instead we'll create a task for someone to take care of this.
                        if (IsBBOSProductionMode()) {
                            string szMsg = null;
                            if (bGrantAccess) {
                                szMsg = " Grant Access.";
                            } else {
                                szMsg = " Remove Access.";
                            }
                            
                            if (sbTasMsg.Length == 0) {
                                sbTasMsg.Append(Session["PersonName"].ToString() +  " has requested the following access changes: " + Environment.NewLine + Environment.NewLine);
                            } else {
                                sbTasMsg.Append(Environment.NewLine);
                            }
                            
                            sbTasMsg.Append(oPersonAccess.PersonName + " (" + oPersonAccess.PersonID.ToString() + "): " + szMsg);
                        } else {
                            SaveConvertFlag(oPersonAccess.PersonLinkID, bGrantAccess, oTran);
                        }
                    }

                    string szEmail = GetRequestParameter("txt" + oPersonAccess.PersonLinkID.ToString(), false);
                    if (szEmail != oPersonAccess.Email) {
                        bEmailChanged = true;
                        
                        if (string.IsNullOrEmpty(szEmail)) {
                            DeleteEmailAddress(oPersonAccess, oTran);
                        } else {
                            if ((bGrantAccess) &&
                                (IsDupEmail(oPersonAccess, szEmail, oTran))) {
                                AddUserMessage("The email address " + szEmail + " is already in use.  Default email addresses used by the new BBOS must be unique.  If you are unable to resolve this, please contact Blue Book Services at info@bluebookprco.com or 630-668-3500.");
                                oTran.Rollback();
                                return;
                            }
                            
                            SaveEmailAddress(oPersonAccess, szEmail, oTran);
                        }
                    }
                }
                
                // If we're in production mode, we no longer play with the converion
                // flag, but we also cannot just modify the PRWebUser records.  So just
                // create a task.
                if ((IsBBOSProductionMode() &&
                     sbTasMsg.Length > 0)) {
                     GetObjectMgr().CreateTask(Utilities.GetIntConfigValue("UserAccessChangeUserID", 1),
                                              "Pending",
                                              sbTasMsg.ToString(),
                                              Utilities.GetConfigValue("UserAccessChangeTaskCategory", string.Empty),
                                              Utilities.GetConfigValue("UserAccessChangeTaskSubcategory", string.Empty),
                                              oTran);
                }

                InsertBBOSUsersAudit("Save", bEmailChanged, bAccessChanged, oTran);
                oTran.Commit();
            } catch {
                oTran.Rollback();
                throw;
            } finally {
                if ((oTran != null) &&
                    (oTran.Connection != null)) {
                    oTran.Connection.Close();
                }
            }

            Response.Redirect("Complete.aspx");
        }
        
        protected const int UPDATED_BY = -135;
        protected const string SQL_UPDATE_CONVERT_FLAG = "UPDATE Person_Link SET peli_PRConvertToBBOS=@Convert, PeLi_UpdatedBy=@PeLi_UpdatedBy, PeLi_UpdatedDate=@PeLi_UpdatedDate, PeLi_TimeStamp=@PeLi_TimeStamp WHERE PeLi_PersonLinkId=@Person_LinkID";
        protected void SaveConvertFlag(int iPersonLink, bool bGrantAccess, IDbTransaction oTran) {
            ArrayList oParameters = new ArrayList();
            if (bGrantAccess) {
                oParameters.Add(new ObjectParameter("Convert", "Y"));
            } else {
                oParameters.Add(new ObjectParameter("Convert", null));
            }
            oParameters.Add(new ObjectParameter("PeLi_UpdatedBy", UPDATED_BY));
            oParameters.Add(new ObjectParameter("PeLi_UpdatedDate", DateTime.Now));
            oParameters.Add(new ObjectParameter("PeLi_TimeStamp", DateTime.Now));
            oParameters.Add(new ObjectParameter("Person_LinkID", iPersonLink));

            GetDBAccess().ExecuteNonQuery(SQL_UPDATE_CONVERT_FLAG, oParameters, oTran);
        }

        protected const string SQL_UPDATE_EMAIL = "UPDATE EMAIL SET Emai_EmailAddress=@Email, emai_UpdatedBy=@emai_UpdatedBy, emai_UpdatedDate=GETDATE(), emai_TimeStamp=GETDATE() WHERE Emai_EmailId=@Emai_EmailId";
        protected const string SQL_INSERT_EMAIL = "INSERT INTO Email (Emai_EmailId, Emai_CompanyID, Emai_PersonID, Emai_Type, Emai_EmailAddress, emai_PRDescription, Emai_CreatedBy, Emai_CreatedDate, Emai_UpdatedBy, Emai_UpdatedDate, Emai_TimeStamp) VALUES (@EmailID, @CompanyID, @PersonID, 'E', @Email, 'E-Mail', @CreatedByID, GETDATE(), @CreatedByID, GETDATE(), GETDATE());";
        protected const string SQL_DELETE_EMAIL = "DELETE FROM Email WHERE Emai_EmailId=@Emai_EmailId;";

        protected void SaveEmailAddress(PersonAccess oPersonAccess, string szEmail, IDbTransaction oTran) {
            ArrayList oParameters = new ArrayList();

            int iPIKSTransactionID = GetObjectMgr().CreatePIKSTransaction(0, oPersonAccess.PersonID, null, "Updated via the BBOS User Management application.", oTran);

            if (oPersonAccess.EmailID > 0) {
                oParameters.Add(new ObjectParameter("Email", szEmail));
                oParameters.Add(new ObjectParameter("emai_UpdatedBy", UPDATED_BY));
                oParameters.Add(new ObjectParameter("Emai_EmailId", oPersonAccess.EmailID));

                GetDBAccess().ExecuteNonQuery(SQL_UPDATE_EMAIL, oParameters, oTran);
            } else {

                oParameters.Add(new ObjectParameter("EmailID", GetObjectMgr().GetRecordID("Email", oTran)));
                oParameters.Add(new ObjectParameter("CompanyID", oPersonAccess.CompanyID));
                oParameters.Add(new ObjectParameter("PersonID", oPersonAccess.PersonID));
                oParameters.Add(new ObjectParameter("Email", szEmail));
                oParameters.Add(new ObjectParameter("CreatedByID", UPDATED_BY));

                GetDBAccess().ExecuteNonQuery(SQL_INSERT_EMAIL, oParameters, oTran);
            }                
            
            GetObjectMgr().ClosePIKSTransaction(iPIKSTransactionID, oTran);
        }


        protected void DeleteEmailAddress(PersonAccess oPersonAccess, IDbTransaction oTran) {
            if (oPersonAccess.EmailID > 0) {
                ArrayList oParameters = new ArrayList();
                int iPIKSTransactionID = GetObjectMgr().CreatePIKSTransaction(0, oPersonAccess.PersonID, null, "Deleted by the BBOS User Management application.", oTran);

                oParameters.Add(new ObjectParameter("Emai_EmailId", oPersonAccess.EmailID));
                GetDBAccess().ExecuteNonQuery(SQL_DELETE_EMAIL, oParameters, oTran);
                GetObjectMgr().ClosePIKSTransaction(iPIKSTransactionID, oTran);
            }
        }        
        

        protected class PersonAccess {
            public int EmailID;
            public int PersonLinkID;
            public int PersonID;
            public int CompanyID;
            public bool HasAccess;
            public string Email;
            public string PersonName;
            
            public PersonAccess(int iPersonLinkID, int iPersonID, bool bHasAccess, string szEmail, int iEmailID, int iCompanyID, string szPersonName) {
                PersonLinkID = iPersonLinkID;
                PersonID = iPersonID;
                HasAccess = bHasAccess;
                Email = szEmail;
                EmailID = iEmailID;
                CompanyID = iCompanyID;
                PersonName = szPersonName;
            }
        }

        protected const string SQL_EMAIL_DUP_CHECK = "SELECT 'x' FROM Email INNER JOIN Person_Link on emai_PersonID = peli_PersonID WHERE emai_Type='E' AND emai_EmailAddress=@Email AND emai_PersonID IS NOT NULL AND Emai_EmailId <> @EmailID AND peli_PRConvertToBBOS = 'Y'";
        //SELECT 'x' FROM PRWebUser INNER JOIN Person_Link ON peli_PersonLinkID = prwu_PersonLinkID WHERE prwu_Email='casandra@millsfamilyfarms.com' AND peli_PersonLinkID <> 
        protected bool IsDupEmail(PersonAccess oPersonAccess, string szEmail, IDbTransaction oTran) {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("Email", szEmail));
            oParameters.Add(new ObjectParameter("EmailID", oPersonAccess.EmailID));

            if (GetDBAccess().ExecuteScalar(SQL_EMAIL_DUP_CHECK, oParameters, oTran) == null) {
                return false;
            }
            
            return true;
        }



        protected const string SQL_MULTIPLE_PERSONS = "SELECT 'x' FROM Person_Link INNER JOIN Company on peli_CompanyID = comp_CompanyID  WHERE comp_PRHQID = @HQID GROUP BY peli_PersonID HAVING COUNT(1) > 1";
        protected void SetMultiplePersonText() {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("HQID", Session["HQID"]));
            
            if (GetDBAccess().ExecuteScalar(SQL_MULTIPLE_PERSONS, oParameters) == null) {
                pnlMultipePersons.Visible=false;
            }
        }

        protected const string SQL_SELECT_LAST_ACCESSED = "SELECT MAX(prbbosua_CreatedDate) FROM PRBBOSUserAudit WHERE prbbosua_HQID = @HQID AND prbbosua_PageName LIKE '%PersonList.aspx' AND prbbosua_Action = @Action;";
        protected void SetLastAccessedDates() {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("HQID", Session["HQID"]));
            oParameters.Add(new ObjectParameter("Action", "View"));

            object dtDate = GetDBAccess().ExecuteScalar(SQL_SELECT_LAST_ACCESSED, oParameters);
            if (dtDate != DBNull.Value) {
                litLastAccessed.Text = ((DateTime)dtDate).ToShortDateString();
            }

            oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("HQID", Session["HQID"]));
            oParameters.Add(new ObjectParameter("Action", "Save"));

            dtDate = GetDBAccess().ExecuteScalar(SQL_SELECT_LAST_ACCESSED, oParameters);
            if (dtDate != DBNull.Value) {
                litLastSaved.Text = ((DateTime)dtDate).ToShortDateString();
            }
        }
        
        protected const string ADDL_USERS_MSG = " and {0} additional {1} licenses";
        protected const string CURRENT_MEMBERSHIP_MSG = "Your organization currently has a {0} which provides {1}  BBOS user licenses{2}. This BBOS Access Management Tool allows you to confirm and adjust which individuals should receive a BBOS access license.  You can also submit email addresses for individuals at your organization (required for people who are flagged to receive a BBOS license).";
        //protected const string SQL_SELECT_MEMBERSHIP = "SELECT prod_Name, prod_PRWebUsers FROM PRService INNER JOIN NewProduct ON prse_ServiceCode = prod_code WHERE prod_ProductFamilyID=@ProductFamilyID AND prse_CancelCode IS NULL AND prse_HQID = @HQID";
        protected const string SQL_SELECT_MEMBERSHIP = "SELECT prod_Name, prod_PRWebUsers FROM PRService INNER JOIN NewProduct ON prse_ServiceCode = prod_code WHERE prod_ProductFamilyID=@ProductFamilyID AND prse_CancelCode IS NULL AND prse_CompanyID IN (SELECT comp_CompanyID FROM Company WHERE comp_PRHQID=dbo.ufn_BRGetHQID(@CompanyID)) order by prod_PRWebUsers desc";
        protected string SetMembershipValues() {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("ProductFamilyID", Utilities.GetIntConfigValue("MembershipProductFamily", 5)));
            oParameters.Add(new ObjectParameter("CompanyID", Session["BBID"]));

            int iUserCount = 0;
            int iAddlUserCount = 0;
            string szMembershipName = "Unknown membership";
            string szAddlLicenseName = null;

            IDataReader oReader = GetDBAccess().ExecuteReader(SQL_SELECT_MEMBERSHIP, oParameters, CommandBehavior.CloseConnection, null);
            try {
                if (oReader.Read()) {
                    iUserCount = oReader.GetInt32(1);
                    szMembershipName = oReader.GetString(0);
                } else {
                    AddUserMessage("No primary membership found.");
                }


            } finally {
                oReader.Close();
            }

            // The assumption here is that at this point, the company has the same type of additional
            // user licenses.
            oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("ProductFamilyID", Utilities.GetIntConfigValue("AdditionalUsersProductFamily", 6)));
            oParameters.Add(new ObjectParameter("CompanyID", Session["BBID"]));

            oReader = GetDBAccess().ExecuteReader(SQL_SELECT_MEMBERSHIP, oParameters, CommandBehavior.CloseConnection, null);
            try {
                while (oReader.Read()) {
                    iAddlUserCount++;
                    szAddlLicenseName = oReader.GetString(0);
                }

            } finally {
                oReader.Close();
            }

            string szMsg = string.Empty;
            if (iAddlUserCount > 0) {
                szMsg += string.Format(ADDL_USERS_MSG, iAddlUserCount, szAddlLicenseName);
            }
            Session["MaxLicenses"] = (iUserCount + iAddlUserCount);

            return string.Format(CURRENT_MEMBERSHIP_MSG, szMembershipName, iUserCount, szMsg);
        }

        protected string GetEmailTextboxID(int iPersonLinkID, object oID) {
            if (oID == DBNull.Value) {
                return iPersonLinkID.ToString() + "_0";
            }
            
            return iPersonLinkID.ToString() + "_" + oID.ToString();
        }
        
        

        protected void btnCancelOnClick(object sender, EventArgs e) {
            LogoffUser();
        }        
    }
}
