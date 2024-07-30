/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2012-2023

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: QuickFind.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using TSI.Utils;
namespace PRCo.BBOS.UI.Web.Widgets
{
    public partial class QuickFind : PageBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            int iCompanyID = 0;
            int iWidgetID = 0;
            if (!new KeyUtils().ValidateKey("QuickFind", 
                                            GetRequestParameter("key",false), 
                                            Request.ServerVariables.Get("SCRIPT_NAME"), 
                                            out iCompanyID,
                                            out iWidgetID))
            {
                pnlQuickFind.Visible = false;
                return;
            }

            string industryType = "P";
            if (GetRequestParameter("Industry", false) != null)
                industryType = GetRequestParameter("Industry", false);

            aceQuickFind.ContextKey = industryType;
            aceQuickFind.ServicePath = Utilities.GetConfigValue("QuickFindServicePath", "http://apps.bluebookservices.com/bbos/AJAXHelper.asmx");

            imgQuickFindHdr.ImageUrl = Utilities.GetConfigValue("ImagesURL") + "Widget_banner.jpg";

            if (GetRequestParameter("HideHeader", false) == "Y")
                trQuickFindHdr.Visible = false;

            int panelWidth = 200;
            if (GetRequestParameter("Width", false) != null)
                panelWidth = Convert.ToInt32(GetRequestParameter("Width", false));

            if (GetRequestParameter("HideBody", false) == "Y")
                pnlBottom.Visible = false;
            else
            {
                if (Utilities.GetBoolConfigValue("QuickFindScaleText", false))
                {
                    if (panelWidth <= 200)
                        pnlBottom.Style.Add("font-size", "12px;");
                    else if (panelWidth <= 300)
                        pnlBottom.Style.Add("font-size", "14px;");
                    else if (panelWidth <= 400)
                        pnlBottom.Style.Add("font-size", "15px;");
                    else if (panelWidth <= 500)
                        pnlBottom.Style.Add("font-size", "16px;");
                }
                else
                {
                    pnlBottom.Style.Add("font-size", "10px;");
                    pnlBottom.Style.Add("width", "165px;");
                }
            }

            if (GetRequestParameter("Border", false) == "Y")
            {
                pnlQuickFind.Style.Add("border", "1px solid gray");
                panelWidth = panelWidth - 5;
            }

            if (GetRequestParameter("HideSearchIcon", false) == "Y")
                txtQuickFind.CssClass = txtQuickFind.CssClass.Replace("searchIcon", string.Empty);

            if (GetRequestParameter("TextBoxHeight", false) != null)
                txtQuickFind.Style.Add("height", GetRequestParameter("TextBoxHeight", false) + "px");

            pnlQuickFind.Style.Add("width", panelWidth.ToString() + "px");
            txtQuickFind.Style.Add("width", (panelWidth-5).ToString() + "px");

            string szTargetURL = null;
            string szMarketingWebsiteURL = null;
            if (industryType == "P")
            {
                szTargetURL = string.Format(Utilities.GetConfigValue("QuickFindProducePublicProfileURL", "http://www.producebluebook.com/PublicProfile/CompanyProfile.aspx?WK={0}&CompanyID="), iWidgetID);
                szMarketingWebsiteURL = Utilities.GetConfigValue("ProduceMarketingSiteURL", "http://www.producebluebook.com");
            }
            else
            {
                szTargetURL = string.Format(Utilities.GetConfigValue("QuickFindLumberPublicProfileURL", "http://www.lumberbluebook.com/PublicProfile/CompanyProfile.aspx?WK={0}&CompanyID="), iWidgetID);
                szMarketingWebsiteURL = Utilities.GetConfigValue("LumberMarketingSiteURL", "http://www.lumberbluebook.com");
            }

            if (GetRequestParameter("BBISCSS", false) != null)
            {
                AddCSS(szMarketingWebsiteURL + Utilities.GetConfigValue("BBSICSS", "/wp-content/themes/blue-book/style.css"));
                AddCSS("~/css/QuickFindBBSI.min.css");
                aceQuickFind.OnClientItemSelected = "AutoCompleteSelectedBBSI";
            }
            else
            {
                AddCSS("~/css/QuickFind.min.css");
            }

            ClientScript.RegisterStartupScript(this.GetType(), "targetURL", "var targetURL='" + szTargetURL + "';" + Environment.NewLine, true);
        }

        protected void AddCSS(string path)
        {
            Literal cssFile = new Literal() { Text = @"<link href=""" + Page.ResolveUrl(path) + @""" type=""text/css"" rel=""stylesheet"" />" };
            Page.Header.Controls.Add(cssFile);
        }
    }
}