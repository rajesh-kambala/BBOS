/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2019

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: BORComplete.aspx.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using PRCo.EBB.Util;
using TSI.BusinessObjects;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web.PublicProfiles
{
    public partial class BORComplete : MembershipBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
        }

        static public string URL()
        {
            string _url = HttpContext.Current.Request.QueryString["url"];
            if (_url == null)
                _url = "";
            
            return _url;
        }
    }
}