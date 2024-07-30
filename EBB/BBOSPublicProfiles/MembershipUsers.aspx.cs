/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2014-2023

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: MembershipUsers.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;

using PRCo.EBB.BusinessObjects;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web.PublicProfiles
{
    public partial class MembershipUsers : MembershipBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            Master.SetFormClass("member step-3 user-setup");

            if (Session["oCreditCardPayment"] == null)
            {
                Response.Redirect("MembershipSelect.aspx" + LangQueryString());
            }

            if (!IsPostBack)
            {
                PopulateForm();
            }

            btnCancel.NavigateUrl = GetMarketingSiteURL() + "/join-today/";
        }

        protected void PopulateForm()
        {
            List<Person> lPersons = GetCombinedPersonList();

            repMembershipUsers.DataSource = lPersons;
            repMembershipUsers.DataBind();

            CreditCardPaymentInfo oCCPaymentInfo = GetCreditCardPaymentInfo();
            txtSpecialInstructions.Text = oCCPaymentInfo.SpecialInstructions;
        }

        protected bool SaveUsers()
        {
            List<Person> lPersons = GetCombinedPersonList();
            StringBuilder missingData = new StringBuilder();

            PRWebUserMgr webUserMgr = new PRWebUserMgr(_oLogger, null);
            StringBuilder existingEmails = new StringBuilder();
            StringBuilder invalidEmails = new StringBuilder();
            bool success = true;

            for (int i = 1; i <= lPersons.Count; i++)
            {
                lPersons[i - 1].Title = GetRequestParameter("txtTitle" + i.ToString(), false);
                lPersons[i - 1].FirstName = GetRequestParameter("txtFirstName" + i.ToString(), false);
                lPersons[i - 1].LastName = GetRequestParameter("txtLastName" + i.ToString(), false);
                lPersons[i - 1].Email = GetRequestParameter("txtEmail" + i.ToString(), false);

                string email = lPersons[i - 1].Email;

                if (!string.IsNullOrEmpty(email))
                {
                    if (!isValidEmail(email))
                    {
                        success = false;
                        if (invalidEmails.Length > 0)
                        {
                            invalidEmails.Append(", ");
                        }
                        invalidEmails.Append(email);
                    }
                    else
                    {
                        if (webUserMgr.UserExists(email, 0, false))
                        {
                            success = false;
                            if (existingEmails.Length > 0)
                            {
                                existingEmails.Append(", ");
                            }
                            existingEmails.Append(email);
                        }
                    }
                }
            }

            if (!success)
            {
                validationError.Style.Add("display", string.Empty);

                if (invalidEmails.Length > 0)
                {
                    validEmails.Visible = true;
                    invalidList.Text = invalidEmails.ToString();
                }

                if (existingEmails.Length > 0)
                {
                    exisitngEmails.Visible = true;
                    existingList.Text = existingEmails.ToString();
                }


                PopulateForm();
            }

            CreditCardPaymentInfo oCCPaymentInfo = GetCreditCardPaymentInfo();
            oCCPaymentInfo.SpecialInstructions = txtSpecialInstructions.Text;

            return success;
        }


        protected List<Person> GetCombinedPersonList()
        {
            List<Person> lPersons = new List<Person>();
            lPersons.AddRange((List<Person>)Session["lMembershipUsers"]);

            SortedList slAdditionalLicenses = (SortedList)Session["slAdditionalLicenses"];
            if (slAdditionalLicenses != null)
            {
                foreach (int iKey in slAdditionalLicenses.Keys)
                {
                    lPersons.AddRange((List<Person>)Session["lAdditionalUsers_" + iKey.ToString()]);
                }
            }

            return lPersons;
        }

        private string GetQueryString()
        {
            string szQry = LangQueryString();
            return szQry;
        }


        protected void btnNextOnClick(object sender, EventArgs e)
        {
            if (SaveUsers())
            {
                Response.Redirect("Payment.aspx" + GetQueryString());
            }
        }

        protected void btnPreviousOnClick(object sender, EventArgs e)
        {
            SaveUsers();
            if (SaveUsers())
            {
                if (Utilities.GetConfigValue("IndustryType") == "P")
                    Response.Redirect("MembershipOptions.aspx" + LangQueryString());
                else
                    Response.Redirect("MembershipSelect.aspx" + GetQueryString());
            }
        }

        //protected void btnCancelOnClick(object sender, EventArgs e)
        //{
        //    Session.Remove("oCreditCardPayment");
        //    Response.Redirect(GetMarketingSiteURL() + "/join-today/");
        //}
    }
}