/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2014-2019

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: Visitor.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using PRCo.EBB.BusinessObjects;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web.PublicProfiles
{
    public partial class Visitor :PageBase
    {
        private int companyID = 0;
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if (string.IsNullOrEmpty(GetRequestParameter("CompanyID", false)))
            {
                Response.Redirect("Default.aspx");
                return;
            }

            companyID = 0;
            if (!int.TryParse(GetRequestParameter("CompanyID"), out companyID))
            {
                Response.Redirect("Default.aspx");
                return;
            }

            if (!IsPostBack)
            {

                cddCountry.ServicePath = GetWebServiceURL();
                cddState.ServicePath = GetWebServiceURL();

                cddCountry.ContextKey = "1";  //USA
                cddState.ContextKey = string.Empty;

                SetListDefaultValue(ddlCountry, "1");
                SetListDefaultValue(ddlState, "14");


                if (GetIndustryType() == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                {
                    BindLookupValues(ddlPrimaryFunction, GetReferenceData("prglr_PrimaryFunctionL"), true);
                }
                else
                {
                    BindLookupValues(ddlPrimaryFunction, GetReferenceData("prglr_PrimaryFunction"), true);
                }
                


            }
        }


        protected void btnSubmitOnClick(object sender, EventArgs e)
        {
            tmpValidationMsg.Visible = false;

            Page.Validate("Required");

            if (cbMoreInfo.Checked)
            {
                if (Page.IsValid)
                {
                    if (string.IsNullOrEmpty(txtSubmitterName.Text))
                    {
                        tmpValidationMsg.Visible = true;
                        return;
                    }

                    if (string.IsNullOrEmpty(txtSubmitterPhone.Text))
                    {
                        tmpValidationMsg.Visible = true;
                        return;
                    }

                    int countryID = Convert.ToInt32(ddlCountry.SelectedValue);

                    if ((countryID == 1) ||
                        (countryID == 2)) {
                    
                        if (ddlState.SelectedValue == "0") {
                            tmpValidationMsg.Visible = true;
                            return;
                        }
                    }
                }
            }
            
            if (!Page.IsValid)
            {
                return;
            }

            SetCompanyProfileCookie();
            //IncrementVisitCount();
            //LogVisitor(companyID);

            CreateCRMTask();
            string wpParm = string.Empty;
            if (GetRequestParameter("p", false) != null)
                wpParm = "&p=1";

            Response.Redirect($"CompanyProfile.aspx?CompanyID={companyID}{wpParm}");
        }

        protected void SetCompanyProfileCookie()
        {
            HttpCookie aCookie = new HttpCookie("Visitor");
            aCookie.Values["Email"] = txtSubmitterEmail.Text;
            aCookie.Values["CompanyName"] = txtCompanyName.Text;
            aCookie.Values["PrimaryFunction"] = ddlPrimaryFunction.SelectedValue;
            aCookie.Values["RequestsMembershipInfo"] = cbMoreInfo.Checked ? "Y" : string.Empty;

            aCookie.Values["SubmitterName"] = txtSubmitterName.Text;
            aCookie.Values["SubmitterPhone"] = txtSubmitterPhone.Text;
            aCookie.Values["State"] = ddlState.SelectedItem.Text;
            aCookie.Values["Country"] = ddlCountry.SelectedItem.Text;

            aCookie.Expires = DateTime.Now.AddYears(5);
            Response.Cookies.Add(aCookie);
        }

        public void CreateCRMTask()
        {
            if (!cbMoreInfo.Checked)
            {
                return;
            }

            int salesUserID = GetObjectMgr().GetPRCoSpecialistID(string.Empty,
                                                                 Convert.ToInt32(ddlState.SelectedValue),
                                                                 GeneralDataMgr.PRCO_SPECIALIST_INSIDE_SALES,
                                                                 GetIndustryType(),
                                                                 null);

            if (salesUserID == 0)
            {
                salesUserID = Utilities.GetIntConfigValue("WebsiteVisitorPRCoUserID", 24);
            }

            StringBuilder taskMsg = new StringBuilder();
            taskMsg.Append("VISITOR INFO / MEMBERSHIP INTEREST" + Environment.NewLine + Environment.NewLine);
            taskMsg.Append("Submitter Email: " + txtSubmitterEmail.Text + Environment.NewLine);
            taskMsg.Append("Submitter Name: " + txtSubmitterName.Text + Environment.NewLine);
            taskMsg.Append("Submitter Phone: " + txtSubmitterPhone.Text + Environment.NewLine);
            taskMsg.Append("Company Name: " + txtCompanyName.Text + Environment.NewLine);
            taskMsg.Append("State: " + ddlState.SelectedItem.Text + Environment.NewLine);
            taskMsg.Append("Country: " + ddlCountry.SelectedItem.Text + Environment.NewLine);
            taskMsg.Append("Primary Function: " + GetReferenceValue("prglr_PrimaryFunction", ddlPrimaryFunction.SelectedValue) + Environment.NewLine);
            taskMsg.Append("Requested Membership Info: Y" + Environment.NewLine);
            taskMsg.Append(Environment.NewLine);

            GetObjectMgr().CreateTask(salesUserID,
                                    "Pending",
                                    taskMsg.ToString(),
                                    Utilities.GetConfigValue("WebsiteVisitorTaskCategory", "SM"),
                                    Utilities.GetConfigValue("WebsiteVisitorTaskSubcategory", "MEM"),
                                    0,
                                    0,
                                    0,
                                    "OnlineIn",
                                    null);
        }
    }
}