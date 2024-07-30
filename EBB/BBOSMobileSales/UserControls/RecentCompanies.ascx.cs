/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2022

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: RecentCompanies.ascx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/

using PRCo.BBOS.UI.Web;
using PRCo.EBB.BusinessObjects;
using System;
using System.Web.UI;
using TSI.Utils;

namespace BBOSMobileSales.UserControls
{
    public partial class RecentCompanies : UserControlBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                if (WebUser != null)
                {
                    int iDisplayCount = Utilities.GetIntConfigValue("MobileSalesRecentDisplayCount", 5);

                    // Execute search and bind results to grid
                    repCompany.DataSource = MobileSales.RecentlyViewedCompanies(WebUser.UserID, iDisplayCount);
                }

                repCompany.DataBind();
            }
        }
    }
}