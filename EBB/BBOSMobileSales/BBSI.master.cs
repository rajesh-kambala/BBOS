/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2022-2023

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: BBSI.master
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using PRCo.BBOS.UI.Web;
using PRCo.EBB.BusinessObjects;
using System;

namespace Sales
{
    public partial class BBSI : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            hlOpenBBOS.NavigateUrl = Configuration.BBOSWebSiteHome;
            hlOpenBBOS.Target = "bbos";
            litYear.Text = DateTime.Now.Year.ToString();
        }

        public void HideMenu()
        {
            appMenu.Visible = false;
            phToggler.Visible = false;
        }

        public void SetUserName(IPRWebUser oUser)
        {
            if (oUser != null)
                litUserName.Text = oUser.FirstName + " " + oUser.LastName;
            else
                litUserName.Text = "";
        }
    }
}