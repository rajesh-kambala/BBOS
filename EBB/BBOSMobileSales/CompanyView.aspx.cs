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

 ClassName: CompanyView.aspx
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
    public partial class CompanyView : PageBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if (!IsPostBack)
            {
                //// Only create the web audit trail upon first load, not everytime
                //// the page is posted back.
                InsertWebAudit();

                hidCompanyID.Text = GetRequestParameter("CompanyID", true, true);
                PopulateForm();
            }
        }

        protected void PopulateForm()
        {
            using (IDataReader oReader = MobileSales.HeaderContent(hidCompanyID.Text))
            {
                while (oReader.Read())
                {
                    if(oReader[5] != DBNull.Value)
                        CurrentMLevel.Text = oReader.GetString(5);

                    if (oReader[6] != DBNull.Value)
                        MemberSince.Text = oReader.GetString(6);

                    if (oReader[4] != DBNull.Value)
                        CurrentRating.Text = oReader.GetString(4);

                    if (oReader[7] != DBNull.Value)
                        TripCode.Text = oReader.GetString(7);
                }
            }

            repPreferredPhones.DataSource = MobileSales.Phones(hidCompanyID.Text);
            repPreferredPhones.DataBind();
            repAddresses.DataSource = MobileSales.Addresses(hidCompanyID.Text);
            repAddresses.DataBind();
            repRatingFacts.DataSource = MobileSales.RatingFacts(hidCompanyID.Text);
            repRatingFacts.DataBind();
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