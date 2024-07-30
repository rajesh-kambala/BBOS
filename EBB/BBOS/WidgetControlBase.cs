/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2018-2018

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: WidgetControlBase
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Provides the common functionality needed by the user controls
    /// </summary>
    public class WidgetControlBase : UserControlBase
    {
        protected override void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
        }
    }
}
