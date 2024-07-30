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

 ClassName: CompanyServices.aspx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/

using PRCo.BBOS.UI.Web;
using System;
using PRCo.EBB.BusinessObjects;
using System.Data;

namespace BBOSMobileSales
{
    public partial class CompanyServices : PageBase
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
            repServices.DataSource = MobileSales.Services(hidCompanyID.Text);
            repServices.DataBind();

            repSalesInfo.DataSource = MobileSales.SalesInfo(hidCompanyID.Text);
            repSalesInfo.DataBind();

            using (IDataReader drServices = MobileSales.Services(hidCompanyID.Text))
            {
                while (drServices.Read())
                {
                    decimal OutstandingBalance = drServices.GetDecimal(6);
                    litOutstandingBalance.Text = String.Format("{0:C0}", OutstandingBalance);
                }
            }

            if (repServices.Items.Count == 0)
                pnlServices.Visible = false;
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