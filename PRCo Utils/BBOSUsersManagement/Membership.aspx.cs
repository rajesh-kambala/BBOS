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

 ClassName: Membership.aspx.cs
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
    public partial class Membership : PageBase {
        override protected void Page_Load(object sender, EventArgs e) {
            base.Page_Load(sender, e);

            SetPageTitle("Membership Options");
            
            if (!IsPostBack) {
                PopulateForm();            
            }
        }

        public const string SQL_SELECT_MEMBERSHIP_PRODUCTS = "SELECT prod_ProductID, RTRIM(prod_Code) AS prod_Code, prod_Name, prod_PRDescription, dbo.ufn_GetProductPrice(prod_ProductID, @PricingListID) as pric_Price FROM NewProduct WHERE prod_ProductFamilyID=@prod_ProductFamilyID ORDER BY prod_PRSequence";
        protected void PopulateForm() {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("PricingListID", 16010));
            oParameters.Add(new ObjectParameter("prod_ProductFamilyID", Utilities.GetIntConfigValue("MembershipProductFamily", 5)));

            repMemberships.DataSource = GetDBAccess().ExecuteReader(SQL_SELECT_MEMBERSHIP_PRODUCTS, oParameters, CommandBehavior.CloseConnection, null);
            repMemberships.DataBind();

            
            oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("PricingListID", 16010));
            oParameters.Add(new ObjectParameter("prod_ProductFamilyID", Utilities.GetIntConfigValue("AdditionalUsersProductFamily", 6)));

            ResetRepeaterCount();
            repAdditionalLicenses.DataSource = GetDBAccess().ExecuteReader(SQL_SELECT_MEMBERSHIP_PRODUCTS, oParameters, CommandBehavior.CloseConnection, null);
            repAdditionalLicenses.DataBind();

            litMembershipMsg.Text = SetMembershipValues();
        }

        protected const string ADDL_USERS_MSG = " and {0} additional {1} licenses";
        protected const string CURRENT_MEMBERSHIP_MSG = "Your organization currently has a {0} which provides {1}  BBOS user licenses{2}. To purchase additional BBOS licenses, please contact Blue Book Services at <a href=\"mailto:customerservice@bluebookprco.com\">customerservice@bluebookprco.com</a> or 630-668-3500. ";
        //protected const string SQL_SELECT_MEMBERSHIP = "SELECT prod_Name, prod_PRWebUsers FROM PRService INNER JOIN NewProduct ON prse_ServiceCode = prod_code WHERE prod_ProductFamilyID=@ProductFamilyID AND prse_CancelCode IS NULL AND prse_HQID = @HQID";
        protected const string SQL_SELECT_MEMBERSHIP = "SELECT prod_Name, prod_PRWebUsers FROM PRService INNER JOIN NewProduct ON prse_ServiceCode = prod_code WHERE prod_ProductFamilyID=@ProductFamilyID AND prse_CancelCode IS NULL AND prse_CompanyID IN (SELECT comp_CompanyID FROM Company WHERE comp_PRHQID=dbo.ufn_BRGetHQID(@CompanyID)) ORDER BY prod_PRWebUsers DESC";
        protected string SetMembershipValues() {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("ProductFamilyID", Utilities.GetIntConfigValue("MembershipProductFamily", 5)));
            oParameters.Add(new ObjectParameter("CompanyID", Session["BBID"]));

            int iUserCount = 0;
            string szMembershipName = "Unknown membership";

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

            int iAddlUserCount = 0;
            string szAddlLicenseName = string.Empty;
            
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

            return string.Format(CURRENT_MEMBERSHIP_MSG, szMembershipName, iUserCount, szMsg);
        }
    }
}
