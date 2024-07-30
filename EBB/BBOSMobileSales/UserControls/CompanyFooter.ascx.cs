/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2022-2022

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CompanyFooter.ascx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using PRCo.BBOS.UI.Web;
using System;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace BBOSMobileSales.UserControls
{
    public partial class CompanyFooter : System.Web.UI.UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                Label hidCompanyID = (Label)Parent.FindControl("hidCompanyID");
                hlOpenInBBOS.NavigateUrl = string.Format(Configuration.BBOSWebSiteHome + "/CompanyDetailsSummary.aspx?CompanyID={0}", hidCompanyID.Text);
            }
        }
    }
}
