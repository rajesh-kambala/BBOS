/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2019

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: MembershipUsers.aspx.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Text;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

using PRCo.EBB.BusinessObjects;
namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Allows the user to specify which persons should be granted access after the
    /// membership has been processed.  
    /// </summary>
    public partial class MembershipUsers : MembershipBase
    {
        protected bool _ITAMode = false;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if (_oUser.IsLimitado)
                _ITAMode = true;

            EnableFormValidation();

            if (!IsPostBack)
            {
                PopulateForm();
            }
        }

        /// <summary>
        /// Populates the grid listing the different additional unit
        /// packages available.
        /// </summary>
        protected void PopulateForm()
        {
            if (_ITAMode)
            {
                SetPageTitle(Resources.Global.OnlineUsers);
            }
            else
                SetPageTitle(Resources.Global.SelectMembershipOptions, Resources.Global.UserSetup);

            ucMembershipSelected.WebUser = _oUser;
            ucMembershipSelected.LoadMembership();

            List<Person> lPersons = GetCombinedPersonList();

            if (lPersons.Count > 50)
                lPersons.RemoveRange(50, (lPersons.Count - 50));

            repMembershipUsers.DataSource = lPersons;
            repMembershipUsers.DataBind();
        }

        /// <summary>
        /// Stores the user selections for use by the CreditCardPayment
        /// page.
        /// </summary>
        protected bool StoreSelections()
        {
            List<Person> lPersons = GetCombinedPersonList();
            StringBuilder missingData = new StringBuilder();

            for (int i = 1; i <= lPersons.Count; i++)
            {
                string title = GetRequestParameter("txtTitle" + i.ToString(), false);
                string firstName = GetRequestParameter("txtFirstName" + i.ToString(), false);
                string lastName = GetRequestParameter("txtLastName" + i.ToString(), false);
                string email = GetRequestParameter("txtEmail" + i.ToString(), false);

                if (!string.IsNullOrEmpty(title) || !string.IsNullOrEmpty(firstName) || !string.IsNullOrEmpty(lastName) || !string.IsNullOrEmpty(email))
                {
                    if (string.IsNullOrEmpty(title) || string.IsNullOrEmpty(firstName) || string.IsNullOrEmpty(lastName) || string.IsNullOrEmpty(email))
                    {
                        if (missingData.Length == 0)
                            missingData.Append("\\n");

                        missingData.Append("Line " + i + ": ");

                        if (string.IsNullOrEmpty(title))
                            missingData.Append("Title, ");

                        if (string.IsNullOrEmpty(firstName))
                            missingData.Append("First Name, ");

                        if (string.IsNullOrEmpty(lastName))
                            missingData.Append("Last Name, ");

                        if (string.IsNullOrEmpty(email))
                            missingData.Append("Email Address");

                        missingData.Replace(",", "", missingData.Length - 1, 1);
                        missingData.Append("\\n");
                    }
                }

                lPersons[i - 1].Title = GetRequestParameter("txtTitle" + i.ToString(), false);
                lPersons[i - 1].FirstName = GetRequestParameter("txtFirstName" + i.ToString(), false);
                lPersons[i - 1].LastName = GetRequestParameter("txtLastName" + i.ToString(), false);
                lPersons[i - 1].Email = GetRequestParameter("txtEmail" + i.ToString(), false);
            }

            if (missingData.Length > 0)
            {
                PopulateForm();
                AddUserMessage(String.Format(Resources.Global.MembershipUsersMissingData, missingData.ToString()));

                return false;
            }

            return true;
        }

        protected void btnNext_Click(object sender, EventArgs e)
        {
            if (StoreSelections())
            {
                if (_oUser == null)
                {
                    Response.Redirect(PageConstants.USER_PROFILE);
                }
                else
                {
                    if(_ITAMode)
                        Response.Redirect(PageConstants.CREDIT_CARD_PAYMENT);
                    else
                        Response.Redirect(PageConstants.TERMS);
                }
            }
        }

        protected void btnPrevious_Click(object sender, EventArgs e)
        {
            StoreSelections();

            if (_ITAMode)
                Response.Redirect(PageConstants.PURCHASE_MEMBERSHIP);
            else
                Response.Redirect(PageConstants.MEMBERSHIP_ADDTIONAL_LICENSES);
        }
    }
}
