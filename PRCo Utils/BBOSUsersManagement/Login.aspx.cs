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

 ClassName: Login
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Globalization;
using System.Threading;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using TSI.Utils;
using TSI.BusinessObjects;
using PRCo.EBB.BusinessObjects;

namespace PRCo.BBOS.UI.Web.UserManagement {
    public partial class Login : PageBase {
        override protected void Page_Load(object sender, EventArgs e) {
            base.Page_Load(sender, e);
            
            SetPageTitle("Login");
            EnableFormValidation();
            
            if (!IsPostBack) {
                lblLoginCount.Text = "0";

                if ((!string.IsNullOrEmpty(Request["BBID"])) &&
                    (!string.IsNullOrEmpty(Request["Password"]))) {
                    txtUserID.Text = Request["BBID"];
                    txtPassword.Text = Request["Password"];
                    btnLoginOnClick(null, null);
                }

                if ((!string.IsNullOrEmpty(Request["l"])) &&
                    (!string.IsNullOrEmpty(Request["p"]))) {
                    txtUserID.Text = Request["l"];
                    txtPassword.Text = Request["p"];
                    btnLoginOnClick(null, null);
                }
                
            }
        }


        /// <summary>
        /// Handles the OnLogin event.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnLoginOnClick(Object sender, EventArgs e) {
            int iLoginCount = Convert.ToInt32(lblLoginCount.Text);

            if (iLoginCount > Utilities.GetIntConfigValue("LoginAttemptThreshold", 5)) {
                AddUserMessage("Too many failed login attempts.  Please contact Blue Book Services Support.");
                btnLogin.Enabled = false;
                return;
            }

            iLoginCount++;
            lblLoginCount.Text = iLoginCount.ToString();

            if (!Authenticate(Convert.ToInt32(txtUserID.Text), txtPassword.Text)) {
                AddUserMessage("Invalid Login/Password Specified.");
            }
        }

        protected bool Authenticate(int iBBID, string szPassword) {
            if (CustomAuthenticate(iBBID, szPassword)) {

                FormsAuthentication.RedirectFromLoginPage(Session["PersonLinkID"].ToString(), false);
                return true;
            }

            return false;
        }

        protected const string SQL_AUTHENTICATE = "SELECT peli_PersonLinkID, peli_CompanyID, comp_PRHQID, peli_PersonID, dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_PRNickname1, NULL, pers_Suffix) As PersonName FROM Person_Link INNER JOIN PERSON on peli_PersonID = pers_PersonID INNER JOIN Company ON peli_CompanyID = comp_CompanyID WHERE peli_CompanyID=@peli_CompanyID AND peli_WebPassword=@peli_WebPassword AND peli_PRStatus IN (1,2,4)";
        protected const string SQL_AUTHENTICATE_PROD = "SELECT peli_PersonLinkID, peli_CompanyID, comp_PRHQID, peli_PersonID, dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_PRNickname1, NULL, pers_Suffix) As PersonName FROM Person_Link INNER JOIN PERSON on peli_PersonID = pers_PersonID INNER JOIN Company ON peli_CompanyID = comp_CompanyID INNER JOIN PRWebUser ON peli_PersonLinkID = prwu_PersonLinkID WHERE peli_CompanyID=@peli_CompanyID AND prwu_Password=dbo.ufnclr_EncryptText(@peli_WebPassword) AND peli_PRStatus IN (1,2,4)";

        /// <summary>
        /// Authenticates the user.
        /// </summary>
        /// <param name="szEmail">Email Address</param>
        /// <param name="szPassword">Password</param>
        /// <returns>Indicates is user is authenticated.</returns>
        protected bool CustomAuthenticate(int iBBID,
                                          string szPassword) {

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("peli_CompanyID", iBBID));
            oParameters.Add(new ObjectParameter("peli_WebPassword", szPassword));
            
            string szSQL = null;
            if (IsBBOSProductionMode()) {
                szSQL = SQL_AUTHENTICATE_PROD;
            } else {
                szSQL = SQL_AUTHENTICATE;
            }

            IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            try {
                if (!oReader.Read()) {
                    return false;
                }

                Session["PersonLinkID"] = oReader.GetInt32(0);
                Session["BBID"] = oReader.GetInt32(1);
                Session["HQID"] = oReader.GetInt32(2);
                Session["PersonID"] = oReader.GetInt32(3);
                Session["PersonName"] = oReader.GetString(4);

                return true;
            } finally {
                oReader.Close();
            }
            
        }        
    }
}
