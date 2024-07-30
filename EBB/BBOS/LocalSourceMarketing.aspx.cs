/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2018-2018

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: LocalSourceMarketing.aspx.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.IO;
using System.Web.UI;
using PRCo.EBB.BusinessObjects;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This page allows the user to either select a new membership (if not
    /// a member user) or upgrade their current membership.
    /// </summary>
    public partial class LocalSourceMarketing : PageBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            //SetPageTitle(Resources.Global.SelectMembershipPackage);
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_FUNCTIONS2_FILE));
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_VALIDATION_FILE));

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
            string szTemplateFile = "LocalSourceMarketing.htm";

            using (StreamReader srTemplate = new StreamReader(Server.MapPath(UIUtils.GetTemplateURL(szTemplateFile))))
            {
                litLocalSourceMarketing.Text = srTemplate.ReadToEnd();
            }
        }

        override protected bool IsAuthorizedForPage()
        {
            return true;
        }

        protected override bool IsAuthorizedForData()
        {
            return true;
        }
    }
}
