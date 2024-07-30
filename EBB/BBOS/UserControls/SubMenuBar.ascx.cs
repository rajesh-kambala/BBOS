/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2007-2020

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: SubMenuBar
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;

using PRCo.EBB.BusinessObjects;
using PRCo.BBOS.UI.Web;
using AjaxControlToolkit;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// User control that renders the page sub-menu on the master page.
    /// The menu can be rendered either as Hyperlinks or as LinkButtons.
    /// </summary>
    public partial class SubMenuBar : UserControlBase
    {
        /// <summary>
        /// The event handler that will be called on all LinkButton
        /// click events.  The LinkButton instance will be passed
        /// in as the sender.
        /// </summary>
        public event EventHandler MenuItemEvent;

        override protected void Page_Load(object sender, EventArgs e)
        {

        }

        /// <summary>
        /// Renders the menu as Hyperlinks using the specified MenuItems.
        /// </summary>
        /// <param name="oMenuItems"></param>
        public void LoadMenu(List<SubMenuItem> oMenuItems)
        {
            foreach (SubMenuItem oMenuItem in oMenuItems)
            {
                HyperLink oLink = new HyperLink();
                oLink.ID = oMenuItem.ID;
                oLink.Text = Server.HtmlEncode(oMenuItem.Text);
                oLink.CssClass += " bbsButton bbsButton-secondary  ";
                oLink.ToolTip = oMenuItem.Tooltip;
                if (oMenuItem.Enabled)
                {
                    oLink.NavigateUrl = "~/" + oMenuItem.URL;
                    oLink.CssClass = "  bbsButton bbsButton-secondary selected ";
                }
                else
                {
                    oLink.CssClass += " disabled ";
                    //this feature is disabled. Please contact customer service if you would like this feature.
                    oLink.ToolTip = Resources.Global.FeatureDisabledContactCustSvc;
                }
                phSubMenu.Controls.Add(oLink);
            }

            Visible = true;
        }

        private string GetItemCount(int count, int decrement, int defCount)
        {
            if ((count - decrement) > 0)
                return (count - decrement).ToString();

            if (count < defCount)
                return count.ToString();

            return defCount.ToString();

        }

        /// <summary>
        /// Renders the menu as LinkButtons using the specified MenuItems.
        /// </summary>
        public void LoadMenuButtons(List<SubMenuItem> oMenuItems, string strDefaultID, bool blnDisableValidation = false)
        {
            foreach (SubMenuItem oMenuItem in oMenuItems)
            {
                LinkButton oLinkButton = new LinkButton();
                oLinkButton.Text = Server.HtmlEncode(oMenuItem.Text);
                oLinkButton.ID = oMenuItem.ID;
                oLinkButton.Enabled = oMenuItem.Enabled;
                oLinkButton.Click += new EventHandler(MenuItemOnClick);
                oLinkButton.CssClass += " bbsButton bbsButton-secondary  ";
                oLinkButton.ToolTip = oMenuItem.Tooltip;
                if (strDefaultID == oMenuItem.ID)
                {
                    oLinkButton.CssClass = " bbsButton bbsButton-secondary selected ";
                }

                if(!oMenuItem.Enabled)
                { 
                    oLinkButton.CssClass += " disabled ";
                    oLinkButton.ToolTip = Resources.Global.FeatureDisabledContactCustSvc;
                }

                if(blnDisableValidation)
                {
                    oLinkButton.OnClientClick = "DisableValidation();";
                }

                phSubMenu.Controls.Add(oLinkButton);
            }

            Visible = true;
        }

        private void MenuItemOnClick(object sender, EventArgs e)
        {
            MenuItemEvent?.Invoke(sender, e);
        }
    }

    /// <summary>
    /// Helper class that defines a menu item's text and
    /// URL.
    /// </summary>
    public class SubMenuItem
    {
        public string Text;
        public string URL;
        public string ID;
        public bool Enabled = true;
        public string Tooltip = "";

        public SubMenuItem(string szText, string szURL)
        {
            Text = szText;
            URL = szURL;
        }

        public SubMenuItem(string szText, string szURL, string szID)
        {
            Text = szText;
            URL = szURL;
            ID = szID;
        }

        public SubMenuItem(string szText, string szURL, bool bEnabled)
        {
            Text = szText;
            URL = szURL;
            Enabled = bEnabled;
        }

        public SubMenuItem(string szText, string szURL, string szID, bool bEnabled, string szTooltip)
        {
            Text = szText;
            URL = szURL;
            ID = szID;
            Enabled = bEnabled;
            Tooltip = szTooltip;
        }
    }
}