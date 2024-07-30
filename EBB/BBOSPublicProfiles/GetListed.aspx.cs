/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2022-2023

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: GetListed.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Web;
using System.Web.UI;

using PRCo.EBB.BusinessObjects;

namespace PRCo.BBOS.UI.Web.PublicProfiles
{
    public partial class GetListed :PageBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
            Master.SetFormClass("get-listed");

            if (!IsPostBack)
            {
                cddCountry.ServicePath = GetWebServiceURL();
                cddState.ServicePath = GetWebServiceURL();

                cddCountry.ContextKey = "1";  //USA
                cddState.ContextKey = string.Empty;

                if (GetIndustryType() == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                {
                    BindLookupValues(ddlPrimaryFunction, GetReferenceData("prglr_PrimaryFunctionL"), true);
                    BindLookupValues(ddlHowLearned, GetReferenceData("prwu_HowLearnedL_Curr"), true);
                }
                else
                {
                    BindLookupValues(ddlPrimaryFunction, GetReferenceData("prglr_PrimaryFunction"), true);
                    BindLookupValues(ddlHowLearned, GetReferenceData("prwu_HowLearned_Curr"), true);
                }
                

            }
        }

        protected void btnCancelOnClick(object sender, EventArgs e)
        {

        }

        protected void btnSubmitOnClick(object sender, EventArgs e)
        {
            Page.Validate();

            if (!ValidateCaptcha())
            {
                throw new HttpRequestValidationException("Captcha verification failed.");
            }

            if (!Page.IsValid)
            {
                return;
            }

            IPRGetListedRequest getListedRequest = (IPRGetListedRequest)new PRGetListedRequestMgr(_oLogger, null).CreateObject();
            getListedRequest.prglr_SubmitterName = txtSubmitterName.Text;
            getListedRequest.prglr_SubmitterPhone = txtSubmitterPhone.Text;
            getListedRequest.prglr_SubmitterEmail = txtSubmitterEmail.Text;
            getListedRequest.prglr_SubmitterIPAddress = Request.ServerVariables["REMOTE_ADDR"];
            getListedRequest.prglr_CompanyName = txtCompanyName.Text;
            getListedRequest.prglr_Street1 = txtStreet1.Text;
            getListedRequest.prglr_Street2 = txtStreet2.Text;
            getListedRequest.prglr_City = txtCity.Text;
            getListedRequest.prglr_State = ddlState.SelectedValue;
            getListedRequest.prglr_PostalCode = txtPostalCode.Text;
            getListedRequest.prglr_Country = ddlCountry.SelectedValue;
            getListedRequest.prglr_CompanyPhone = txtCompanyPhone.Text;
            getListedRequest.prglr_CompanyEmail = txtCompanyEmail.Text;
            getListedRequest.prglr_CompanyWebsite = txtCompanyWeb.Text;
            getListedRequest.prglr_PrimaryFunction = ddlPrimaryFunction.SelectedValue;
            getListedRequest.prglr_HowLearned = ddlHowLearned.SelectedValue;
            getListedRequest.prglr_IndustryType = GetIndustryType();

            if (Request.Form["owner"] == "on")
                getListedRequest.prglr_SubmitterIsOwner = "Y";

            getListedRequest.prglr_Principals = txtPrincipals.Text;

            if (cbMoreInfo.Checked)
                getListedRequest.prglr_RequestsMembershipInfo = "Y";

            
            getListedRequest.Save();
            getListedRequest.CreateCRMTask();
            getListedRequest.SendThankYouEmail();

            industrytype.Text = GetReferenceValue("comp_PRIndustryType", GetIndustryType()).ToLower();
            pnlForm.Visible = false;
            pnlThankYou.Visible = true;

                ClientScript.RegisterStartupScript(this.GetType(), "Scroll", "scrollToTop();", true);
            Page.MaintainScrollPositionOnPostBack = false;
        }
    }
}