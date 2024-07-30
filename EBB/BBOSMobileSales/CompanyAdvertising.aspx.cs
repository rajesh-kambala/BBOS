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

 ClassName: CompanyAdvertising.aspx
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
    public partial class CompanyAdvertising : PageBase
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
            repAdRevenue.DataSource = MobileSales.AdRevenue(hidCompanyID.Text);
            repAdRevenue.DataBind();

            using (IDataReader drAdRevenue=MobileSales.AdRevenue(hidCompanyID.Text))
            {
                decimal decTotal = 0;

                while (drAdRevenue.Read())
                {
                    decTotal += drAdRevenue.GetDecimal(1);
                }

                litTotal.Text = String.Format("{0:C0}", decTotal);
            }

            if (repAdRevenue.Items.Count == 0)
                pnlAdRevenue.Visible = false;

            repImageAd.DataSource = MobileSales.ImageAd(hidCompanyID.Text);
            repImageAd.DataBind();

            using (IDataReader drImageAd = MobileSales.ImageAd(hidCompanyID.Text))
            {
                int ImpressionCount = 0;
                int ClickCount = 0;
                int Count = 0;

                while (drImageAd.Read())
                {
                    ImpressionCount += drImageAd.GetInt32(5);
                    ClickCount += drImageAd.GetInt32(6);
                    Count += 1;
                }

                litImpressionCount.Text = String.Format("{0:###,##0}", ImpressionCount);
                litClickCount.Text = String.Format("{0:###,##0}", ClickCount);
            }

            if (repImageAd.Items.Count == 0)
                pnlImageAd.Visible = false;

            repAdvertising.DataSource = MobileSales.Advertising(hidCompanyID.Text);
            repAdvertising.DataBind();
            if (repAdvertising.Items.Count == 0)
                pnlAdvertising.Visible = false;
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