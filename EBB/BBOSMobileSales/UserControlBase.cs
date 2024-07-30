/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2022-2022

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: UserControlBase.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using PRCo.EBB.BusinessObjects;
using TSI.Utils;
using System.Web.UI;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Provides the common functionality needed by the user controls
    /// </summary>
    public class UserControlBase : UserControl
    {
        public IPRWebUser WebUser;
        public ILogger Logger;

        virtual protected void Page_Load(object sender, EventArgs e)
        {
            InitControl();
        }

        virtual protected void Page_Init(object sender, EventArgs e)
        {
            InitControl();
        }

        protected void InitControl()
        {
            WebUser = (IPRWebUser)Session["oUser"];
            Logger = (ILogger)Session["Logger"];
        }

        protected ILogger GetLogger()
        {
            if (Logger == null)
            {
                Logger = LoggerFactory.GetLogger();
                if (WebUser != null)
                {
                    Logger.UserID = WebUser.UserID;
                }
                Logger.RequestName = Request.ServerVariables.Get("SCRIPT_NAME");
            }

            return Logger;
        }
    }
}