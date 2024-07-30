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

 ClassName: CompanyPersona.aspx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/

using PRCo.BBOS.UI.Web;
using System;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;

namespace BBOSMobileSales
{
    public partial class CompanyPerson : PageBase
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
            repPerson.DataSource = MobileSales.Person(hidCompanyID.Text);
            repPerson.DataBind();

            if (repPerson.Items.Count == 0)
                repPerson.Visible = false;
        }

        protected override bool IsAuthorizedForData()
        {
            return true;
        }

        protected override bool IsAuthorizedForPage()
        {
            return true;
        }

        protected void repPerson_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                dynamic person = e.Item.DataItem as dynamic;

                object licLevel = person[2];
                if (licLevel == DBNull.Value)
                {
                    PlaceHolder phLicLevel = (PlaceHolder)e.Item.FindControl("phLicLevel");
                    phLicLevel.Visible = false;
                }

                object email = person[5];
                if (email == DBNull.Value)
                {
                    PlaceHolder phEmail = (PlaceHolder)e.Item.FindControl("phEmail");
                    phEmail.Visible = false;
                }
            }
        }
    }
}