/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2011-2014

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: Default.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web.PublicProfiles
{
    public partial class Default : PageBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            string marketingWebsite = Utilities.GetConfigValue("MarketingSiteURL");
            hlPrivacyPolicy.NavigateUrl = marketingWebsite + hlPrivacyPolicy.NavigateUrl;
            hlLogin.NavigateUrl = Utilities.GetConfigValue("BBOSRegisterLoginURL");

            SetPageTitle("Company Profile Index");

            industrytype.Text = GetReferenceValue("comp_PRIndustryType", GetIndustryType()).ToLower();

            //AddIndexPageRobotMetaTags();

            if (GetRequestParameter("OverrideRedirect", false) == "Y")
            {
                SetRequestParameter("OverrideRedirect", GetRequestParameter("OverrideRedirect"));
            }
        }
    }
}
