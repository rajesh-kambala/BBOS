/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2022

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: QuickFind.ascx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/

using System;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This control allows the user to search for companies from any page.
    /// Only Company Name, BB # and Custom Identifiers are searched.
    /// 
    /// <remarks>
    /// I had to add a "dummy" textbox to the control to work around a form post
    /// issue when only one textbox appears on a page.  The default behavior of the
    /// web browsers is to submit the form when enter is pressed in this scenario.  By
    /// adding the dummy textbox, the browser allows the ASP.NET client-side code to
    /// fire instead.
    /// </remarks>
    /// </summary>
    public partial class QuickFind : UserControlBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
            btnQuickFind.ImageUrl = "~/images/search.png";
        }

        /// <summary>
        /// OnClick handler to execute the search.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnQuickFindOnClick(object sender, EventArgs e)
        {
            // There are circumstances where we don't have a user object due to
            // a timing issue where the user's session has expired.  In this case,
            // we'll just redirect to the login page.
            if (WebUser == null)
            {
                Response.Redirect(PageConstants.LOGIN);
                return;
            }

            if (string.IsNullOrEmpty(txtQuickFind.Text))
            {
                //Session["szUserMessage"] = Resources.Global.QuickFindEmptyMsg;
                return;
            }

            IPRWebUserSearchCriteria oWebUserSearchCriteria = (IPRWebUserSearchCriteria)new PRWebUserSearchCriteriaMgr(GetLogger(), WebUser).CreateObject();
            oWebUserSearchCriteria.prsc_SearchType = PRWebUserSearchCriteria.SEARCH_TYPE_COMPANY;
            oWebUserSearchCriteria.prsc_HQID = WebUser.prwu_HQID;
            oWebUserSearchCriteria.prsc_CompanyID = WebUser.prwu_BBID;
            oWebUserSearchCriteria.prsc_WebUserID = WebUser.prwu_WebUserID;

            CompanySearchCriteria oCompanySearchCritiera = (CompanySearchCriteria)oWebUserSearchCriteria.Criteria;
            oCompanySearchCritiera.IsQuickSearch = true;
            oCompanySearchCritiera.CompanyName = txtQuickFind.Text;
            oCompanySearchCritiera.ListingStatus = "L,H,LUV,N5";

            int iBBID = 0;
            if (Int32.TryParse(txtQuickFind.Text, out iBBID))
            {
                oCompanySearchCritiera.BBID = iBBID;
            }

            // Make sure these are excluded.
            oCompanySearchCritiera.PayReportCount = -1;

            oWebUserSearchCriteria.Criteria = oCompanySearchCritiera;
            Session["oWebUserSearchCriteria"] = oWebUserSearchCriteria;
            Response.Redirect(PageConstants.COMPANY_SEARCH_RESULTS_NEW);
        }

        public void SetWebUser(IPRWebUser oUser)
        {
            WebUser = oUser;
            AutoCompleteExtender1.ContextKey = "";
        }

        public ImageButton GetSearchButton()
        {
            return btnQuickFind;
        }
    }
}