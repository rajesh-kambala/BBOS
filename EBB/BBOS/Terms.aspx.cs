/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: Terms.aspx.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.IO;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Displays the BBOS usage terms.
    /// 
    /// <remarks>
    /// This page is accessible from the marketing page so we cannot assume
    /// we have a user object.
    /// </remarks>
    /// </summary>
    public partial class Terms : PageBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if (!IsPostBack)
            {
                lblReferrer.Text = Request.ServerVariables["HTTP_REFERER"];

                if (!string.IsNullOrEmpty((string)Session["IsMembership"]))
                    lblTermsType.Text = "Membership";
                else if (!string.IsNullOrEmpty((string)Session["LSSPurchase"]))
                    lblTermsType.Text = "LSSPurchase";
                else if (!string.IsNullOrEmpty((string)Session["ExpressUpdatesPurchase"]))
                    lblTermsType.Text = "ExpressUpdatesPurchase";
                else
                    lblTermsType.Text = "TermsAndConditions";

                PopulateForm();
            }

            switch (lblTermsType.Text)
            {
                case "Membership":
                    SetPageTitle(Resources.Global.MembershipAgreement);
                    btnDone.Visible = false;
                    break;
                case "TermsAndConditions":
                    SetPageTitle(Resources.Global.TermsAndConditions);
                    btnDone.Visible = false;
                    break;
                case "LSSPurchase":
                    SetPageTitle(Resources.Global.LSSPurchaseTitle);
                    btnDone.Visible = false;
                    break;
                case "ExpressUpdatesPurchase":
                    SetPageTitle(Resources.Global.ExpressUpdatesPurchaseTitle);
                    btnDone.Visible = false;
                    break;
            }

            if (!string.IsNullOrEmpty((string)Session["MembershipSummary"]))
            {
                btnAccept.Visible = false;
                btnDecline.Visible = false;
                btnDone.Visible = true;
            }

            if (_oUser == null)
            {
                btnAccept.Visible = false;
                btnDecline.Visible = false;
                btnDone.Visible = false;
            }
        }

        protected void PopulateForm()
        {
            string szFileName = null;

            switch (lblTermsType.Text)
            {
                case "Membership":
                    szFileName = "MembershipAgreement.html";
                    break;
                case "TermsAndConditions":
                case "LSSPurchase":
                case "ExpressUpdatesPurchase":
                    szFileName = "Terms.html";
                    break;
            }

            using (StreamReader srTerms = new StreamReader(Server.MapPath(UIUtils.GetTemplateURL(szFileName))))
            {
                litTerms.Text = srTerms.ReadToEnd(); 
            }
        }

        protected void btnAcceptOnClick(object sender, EventArgs e)
        {
            if (_oUser == null) 
            {
                Response.Redirect(PageConstants.BBOS_HOME);
                return;
            }

            switch (lblTermsType.Text)
            {
                case "Membership":
                    _oUser.prwu_AcceptedMemberAgreement = true;
                    _oUser.prwu_AcceptedMemberAgreementDate = DateTime.Now;
                    break;
                case "TermsAndConditions":
                case "LSSPurchase":
                case "ExpressUpdatesPurchase":
                    _oUser.prwu_AcceptedTerms = true;
                    _oUser.prwu_AcceptedTermsDate = DateTime.Now;

                    // Only set the accepted terms if this user is
                    // associated with a BBS CRM person link record.
                    if (_oUser.prwu_PersonLinkID > 0)
                    {
                        GetObjectMgr().SetAcceptedTerms();
                    }

                    break;
            }

            if (!IsImpersonating())
            {
                _oUser.Save();
            }

            // If this is for a new membership, then take the
            // user to the Credit Card Payment page.
            if (lblTermsType.Text == "Membership")
            {
                Response.Redirect(PageConstants.MEMBERSHIP_UPGRADE);
                return;
            }

            if (GetRequestParameter("PurchaseMembership", false) != null)
            {
                Response.Redirect(PageConstants.MEMBERSHIP_SELECT);
                return;
            }

            if(lblTermsType.Text == "LSSPurchase")
            {
                Session["LSSPurchase"] = null;
                Response.Redirect(PageConstants.LSS_PURCHASE_CONFIRM); //After clicking “Accept” the user should go to new confirmation page based on their selections.
                return;
            }
            else if (lblTermsType.Text == "ExpressUpdatesPurchase")
            {
                Session["ExpressUpdatesPurchase"] = null;
                Response.Redirect(PageConstants.EXPRESSUPDATES_PURCHASE_CONFIRM); //After clicking “Accept” the user should go to new confirmation page based on their selections.
                return;
            }

            // Otherwise, just go home.
            Response.Redirect(PageConstants.BBOS_HOME);
        }

        protected void btnDeclineOnClick(object sender, EventArgs e)
        {
            if (_oUser == null)
            {
                Response.Redirect(PageConstants.BBOS_HOME);
                return;
            }

            switch (lblTermsType.Text)
            {
                case "Membership":
                    _oUser.prwu_AcceptedMemberAgreement = false;
                    break;
                case "TermsAndConditions":
                    _oUser.prwu_AcceptedTerms = false;
                    break;
                case "LSSPurchase":
                case "ExpressUpdatesPurchase":
                    Response.Redirect(PageConstants.BBOS_HOME);
                    break; 
            }

            if (!IsImpersonating())
            {
                _oUser.Save();
            }

            LogoffUser();
        }

        protected void btnDoneOnClick(object sender, EventArgs e)
        {
            // If we have a NULL user, than we came from the marketing web
            // site.
            if (_oUser == null)
            {
                if (string.IsNullOrEmpty(lblReferrer.Text))
                    Response.Redirect(Configuration.WebSiteHome);
                else
                    Response.Redirect(lblReferrer.Text);
            }
            else
            {
                switch (lblTermsType.Text)
                {
                    case "Membership":
                        Session["MembershipSummary"] = null;
                        Session["IsMembership"] = null;
                        Response.Redirect(PageConstants.MEMBERSHIP_SUMMARY);
                        break;
                    case "TermsAndConditions":
                        Response.Redirect(lblReferrer.Text);
                        break;
                }
            }
        }

        protected override bool IsAuthorizedForPage()
        {
            return true;
        }

        protected override bool IsAuthorizedForData()
        {
            return true;
        }

        protected override bool IsTermsExempt()
        {
            return true;
        }
    }
}