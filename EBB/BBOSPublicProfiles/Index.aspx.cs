/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2011-2012

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: Index.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using TSI.BusinessObjects;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web.PublicProfiles
{
    public partial class Index : PageBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            hlLogin.NavigateUrl = Utilities.GetConfigValue("BBOSRegisterLoginURL");

            SetPageTitle("Company Profile Index");
            

            PopulateForm();

            if (GetRequestParameter("OverrideRedirect", false) == "Y")
            {
                SetRequestParameter("OverrideRedirect", GetRequestParameter("OverrideRedirect"));
            }
        }

        protected const string SQL_SELECT_COMPANIES =
            @"SELECT comp_CompanyID, comp_PRCorrTradestyle
                FROM Company WITH (NOLOCK)
               WHERE {0}
                 AND comp_PRListingStatus IN ('L', 'H', 'LUV')
                 AND comp_PRIndustryType IN ({1})
                 AND comp_PRLocalSource IS NULL
            ORDER BY comp_PRCorrTradestyle";

        protected void PopulateForm()
        {
            if (string.IsNullOrEmpty(GetRequestParameter("ndx", false)))
            {
                Response.Redirect("Default.aspx");
                return;
            }

            int ndx = 0;
            if (!int.TryParse(GetRequestParameter("ndx"), out ndx))
            {
                Response.Redirect("Default.aspx");
                return;
            }

            string nameCondition = null;

            if (ndx == 27)
            {
                nameCondition = "SUBSTRING(comp_PRCorrTradestyle, 1, 1) LIKE '[^a-z]%' ";
            }
            else
            {
                string parm = ((char)(ndx + 64)).ToString();
                nameCondition = "comp_PRCorrTradestyle LIKE '" + parm + "%' ";
            }
            
            string szSQL = string.Format(SQL_SELECT_COMPANIES, 
                                         nameCondition,
                                         Utilities.GetConfigValue("IndustryTypes"));

            repCompanies.DataSource = GetDBAccess().ExecuteReader(szSQL, System.Data.CommandBehavior.CloseConnection);
            repCompanies.DataBind();
        }

    }
}
