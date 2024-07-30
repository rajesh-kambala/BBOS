/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2018

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: MembershipComplete.aspx.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using PRCo.EBB.BusinessObjects;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// The final step of the membership wizard.  Displays a "Thank you" message
    /// and cleans up all stray variables.
    /// </summary>
    public partial class MembershipComplete : MembershipBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            SetPageTitle(Resources.Global.MembershipComplete);

            // If this is a current member, then upgrade them to
            // thier current membership's access
            if (((string)Session["NewMembership"]) == "true")
            {
                litMembershipCompleteMsg.Text = Resources.Global.MembershipCompleteMsg1;

                if ((_oUser.prwu_PersonLinkID == 0) &&
                    (_oUser.prwu_CDSWBBID == 0))
                {
                    litMembershipCompleteMsg.Text += "<p></p>" + string.Format(Resources.Global.MyMessageCenterCDSWMsg, PageConstants.CDSW_INDUSTRY_SELECTION);
                }
            }
            else
            {
                litMembershipCompleteMsg.Text = Resources.Global.MembershipUgradeMsg3;
            }

            // Mom always said to clean up 
            // after ourselves.            
            RemoveMembershipParamaters();
        }

        protected void btnHomeOnClick(object sender, EventArgs e)
        {
            if (_oUser == null)
            {
                Response.Redirect(PageConstants.LOGIN);
            }

            Response.Redirect(PageConstants.BBOS_HOME);
        }
    }
}
