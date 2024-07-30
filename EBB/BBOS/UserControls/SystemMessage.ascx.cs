/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2007-2023

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com
     
 ClassName: SystemMessage.ascx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/

using System;
using System.Collections.Generic;

namespace PRCo.BBOS.UI.Web.UserControls
{
    public partial class SystemMessage : UserControlBase
    {
        private string _strMessage;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
            if (!IsPostBack)
            {
                PopulateForm();

                if (WebUser.IsLimitado)
                    pnlPrimary.Style.Add("width", "49%");
            }
        }

        protected void PopulateForm()
        {
            String msg = GetMessage();

            if (!string.IsNullOrEmpty(msg))
            {
                msg += " " + UIUtils.GetHyperlink(PageConstants.SYSTEM_MESSAGE, Resources.Global.ViewAllMessages, "messages", string.Empty);
            }
            else
            {
                msg = string.Format(Resources.Global.MyMessageCenterWelcomeMsg, WebUser.FirstName + " " + WebUser.LastName, DateTime.Today.ToString("dddd, MMMM d, yyyy"));
            }

            litMessage.Text = msg;

            bool blnHasTESMessage = HasTESMessage();
            if (blnHasTESMessage)
            {
                iconTES.InnerText = "feedback";
            }
        }

        protected string GetMessage()
        {
            SystemMessages systemMsg = new SystemMessages(WebUser, Logger);
            string msg;
            List<string> lstMsgs = new List<string>();

            //International Trade custom message or member message, depending on user type
            if (WebUser.IsLimitado)
            {
                msg = systemMsg.GetCustomMessage("ITA");
                if (!string.IsNullOrEmpty(msg))
                {
                    lstMsgs.Add(msg);
                }
            }

            msg = systemMsg.GetSuspensionPendingMessage();
            if (!string.IsNullOrEmpty(msg))
            {
                lstMsgs.Add(msg);
            }

            msg = systemMsg.GetTESMessage();
            if (!string.IsNullOrEmpty(msg))
            {
                lstMsgs.Add(msg);
            }

            msg = systemMsg.GetJeopardyMessage();
            if (!string.IsNullOrEmpty(msg))
            {
                lstMsgs.Add(msg);
            }

            msg = systemMsg.GetReferenceListMessage();
            if (!string.IsNullOrEmpty(msg))
            {
                lstMsgs.Add(msg);
            }

            msg = systemMsg.GetServiceUnitMessage();
            if (!string.IsNullOrEmpty(msg))
            {
                msg = msg.Replace("explicitlink2", "messages");
                msg = msg.Replace("explicitlink", "messages");
                if (!string.IsNullOrEmpty(msg))
                {
                    lstMsgs.Add(msg);
                }
            }

            msg = systemMsg.GetCompanyUpdatesMessage();
            if (!string.IsNullOrEmpty(msg))
            {
                lstMsgs.Add(msg);
            }

            //Since it's not international trade, check Member here
            msg = systemMsg.GetCustomMessage("Member");
            if (!string.IsNullOrEmpty(msg))
            {
                lstMsgs.Add(msg);
            }

            switch(lstMsgs.Count)
            {
                case 0:
                    return null;
                case 1:
                    return lstMsgs[0];
                default:
                    return lstMsgs[0] + "  " + lstMsgs[1]; //return 2 messages
            }
        }

        protected bool HasTESMessage()
        {
            SystemMessages systemMsg = new SystemMessages(WebUser, Logger);

            string msg = systemMsg.GetTESMessage();
            if (!string.IsNullOrEmpty(msg))
            {
                return true;
            }

            return false;
        }

        public string Message
        {
            set
            {
                litMessage.Text = value;
                _strMessage = value;
            }
            get { return _strMessage; }
        }
    }
}