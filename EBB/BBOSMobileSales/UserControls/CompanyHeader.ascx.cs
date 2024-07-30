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

 ClassName: CompanyHeader.ascx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/

using PRCo.EBB.BusinessObjects;
using System;
using System.Data;
using System.Web.UI.WebControls;

namespace BBOSMobileSales.UserControls
{
    public partial class CompanyHeader : System.Web.UI.UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Label ParentCompanyID = (Label)Parent.FindControl("hidCompanyID");
                hidCompanyID.Value = ParentCompanyID.Text;
                PopulateForm();
            }
        }

        protected void PopulateForm()
        {
            using (IDataReader dr = MobileSales.HeaderContentBasic(hidCompanyID.Value))
            {
                while (dr.Read())
                {
                    litCompanyName.Text = dr.GetString(1);
                    litCityState.Text = dr.GetString(2);
                    litBBID.Text = dr.GetInt32(0).ToString();
                    litListingStatus.Text = dr.GetString(4);
                }
            }

            hlSummary.NavigateUrl = "~/CompanyView.aspx?CompanyID=" + hidCompanyID.Value + "#sum";
            hlServices.NavigateUrl = "~/CompanyServices.aspx?CompanyID=" + hidCompanyID.Value + "#svs";
            hlPersonnel.NavigateUrl = "~/CompanyPerson.aspx?CompanyID=" + hidCompanyID.Value + "#per";
            hlDeliveryInfo.NavigateUrl = "~/CompanyDelivery.aspx?CompanyID=" + hidCompanyID.Value + "#di";
            hlAdvertising.NavigateUrl = "~/CompanyAdvertising.aspx?CompanyID=" + hidCompanyID.Value + "#ads";
            hlInteractions.NavigateUrl = "~/CompanyInteractions.aspx?CompanyID=" + hidCompanyID.Value + "#intr";
            hlClaims.NavigateUrl = "~/CompanyClaims.aspx?CompanyID=" + hidCompanyID.Value + "#clm";
            hlOpportunities.NavigateUrl = "~/CompanyOpportunity.aspx?CompanyID=" + hidCompanyID.Value + "#oppo";
            hlListing.NavigateUrl = "~/CompanyListing.aspx?CompanyID=" + hidCompanyID.Value + "#lst";
        }
    }
}