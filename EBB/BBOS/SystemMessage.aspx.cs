/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2018

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: SystemMessage.aspx.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Web.UI;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This page displays all system messages
    /// </summary>
    public partial class SystemMessage : PageBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            SetPageTitle(Resources.Global.MyMessageCenter);

            if (!IsPostBack)
            {
                PopulateForm();
            }
        }

        const string HR = "<hr style='height:4px;border:none;color:#333;background-color:#333; margin-right:-15px; margin-left:-15px;'>";

        /// <summary>
        /// Populates the outer repeater with those categories that have articles.
        /// </summary>
        protected void PopulateForm()
        {
            litWelcomeMsg.Text = string.Format(Resources.Global.MyMessageCenterWelcomeMsg2, _oUser.FirstName, DateTime.Today.ToString("MM/dd/yyyy"), "explicitlink");

            List<string> lstMsgs = GetSystemMessages();
            foreach(string szMsg in lstMsgs)
            {
                LiteralControl lit = new LiteralControl(string.Format("{1}<div class='row'><nobr>{0}</nobr></div>{1}", szMsg, HR));
                phMessageCener.Controls.Add(lit);
            }
        }

        /// <summary>
        /// Gets the system messages in a DataReader.
        /// </summary>
        /// <returns></returns>
        protected List<string> GetSystemMessages()
        {
            SystemMessages systemMsg = new SystemMessages(_oUser, _oLogger);
            return systemMsg.GetMessages("explicitlink");
        }

        protected override bool IsAuthorizedForPage()
        {
            return true;
        }

        protected override bool IsAuthorizedForData()
        {
            return true;
        }
    }
}
