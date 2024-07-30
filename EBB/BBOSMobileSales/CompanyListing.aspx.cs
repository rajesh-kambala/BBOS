/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2022-2022

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CompanyListing.aspx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/

using PRCo.BBOS.UI.Web;
using System;
using PRCo.EBB.BusinessObjects;

namespace BBOSMobileSales
{
    public partial class CompanyListing : PageBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if (!IsPostBack)
            {
                hidCompanyID.Text = GetRequestParameter("CompanyID", true, true);
                PopulateForm();
            }
        }

        protected void PopulateForm()
        {
            repListing.DataSource = MobileSales.Listing(hidCompanyID.Text);
            repListing.DataBind();

            if (repListing.Items.Count == 0)
                repListing.Visible = false;
        }

        protected override bool IsAuthorizedForData()
        {
            return true;
        }

        protected override bool IsAuthorizedForPage()
        {
            return true;
        }
    }
}