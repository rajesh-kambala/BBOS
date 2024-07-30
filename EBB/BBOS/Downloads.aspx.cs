/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: Downloads
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.IO;
using System.Text;
using PRCo.EBB.BusinessObjects;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Allows the user access to various upload and download facilities.
    /// </summary>
    public partial class Downloads : PageBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            SetPageTitle(Resources.Global.AdditionalTools);

            litCompanyUpdates.Text = Resources.Global.CreditSheetDownloadsMsg;
            hlCompanyUpdates.PostBackUrl = PageConstants.COMPANY_UPDATE_DOWNLOAD;

            litDownloadshortcut.Text = string.Format(Resources.Global.ApplicationShortcut, GetApplicationNameAbbr());
            hlWebServices.NavigateUrl = Utilities.GetConfigValue("BBOSWebServicesURL", "https://apps.bluebookservices.com/bbwebservices");

            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                litBBOSMobile.Text = Resources.Global.BBOSMobileMsgL;
                pnlLumberAppLinks.Visible = true;

                tdWebServices.Visible = false;
                pnlPACADRCViolators.Visible = false; //Defect 6901 lumber can't see PACA DRC Violators report
            }
            else
            {
                litBBOSMobile.Text = Resources.Global.BBOSMobileMsgP;
                pnlProduceAppLinks.Visible = true;

                pnlPACADRCViolators.Visible = true;
            }

            //Defect 7050 - remove USDA for lumber
            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                tdUSDAMarket.Visible = false;
            }
        }

        /// <summary>
        /// Creates a .URL file for download onto Windows systems that is
        /// a shortcut to this instance of the application.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnDownloadShortcutOnClick(object sender, EventArgs e)
        {
            StringBuilder sbShortcut = new StringBuilder("[InternetShortcut]" + Environment.NewLine);
            sbShortcut.Append("URL=");
            sbShortcut.Append(GetURLProtocol());
            sbShortcut.Append(Request.ServerVariables["SERVER_NAME"]);
            sbShortcut.Append(GetVirtualPath());
            sbShortcut.Append(Environment.NewLine);

            sbShortcut.Append("IconFile=");
            sbShortcut.Append(GetURLProtocol());
            sbShortcut.Append(Request.ServerVariables["SERVER_NAME"]);
            sbShortcut.Append(GetVirtualPath());
            sbShortcut.Append("favicon.ico");
            sbShortcut.Append(Environment.NewLine);

            // Now deliver our report to the client
            Response.ClearContent();
            Response.ClearHeaders();

            Response.AddHeader("Content-Disposition", "attachment; filename=\"BBOS.url\"");
            Response.ContentType = "application/url";

            Response.Write(sbShortcut.ToString());
            Response.End();
            //Response.Flush();
            //Response.Close();
            //Response.End();
        }

        protected void btnDownloadHelpGuide(object sender, EventArgs e)
        {
            string szHelpGuide = Server.MapPath(UIUtils.GetLocalizedURL("/Help/" + GetIndustryPath(_oUser.prwu_IndustryType) + "/" + Utilities.GetConfigValue("HelpGuideDownloadFile")));

            // Now deliver our report to the client
            Response.ClearContent();
            Response.ClearHeaders();

            Response.AddHeader("Content-Disposition", "attachment; filename=\"" + Resources.Global.BBOSHelpGuideDownloadName + "\"");
            Response.ContentType = "application/pdf";

            Response.WriteFile(szHelpGuide);
            Response.End();
            //Response.Flush();
            //Response.Close();
            //Response.End();
        }

        protected void btnWidgetTermsOnClick(object sender, EventArgs e)
        {
            Session["IsWidget"] = "true";
            Response.Redirect(PageConstants.TERMS);
        }

        /// <summary>
        /// Only members level 4 or greater can access
        /// this page.
        /// </summary>
        /// <returns></returns>
        protected override bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.DownloadsPage).HasPrivilege;
        }

        protected override bool IsAuthorizedForData()
        {
            return true;
        }

        /// <summary>
        /// Reads the bankruptcy report from disk and steams it to the user.  This report
        /// is generated by the BBS Monitor.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnBankruptcyReportOnClick(object sender, EventArgs e)
        {
            FileInfo fi;
            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                fi = new FileInfo(Utilities.GetConfigValue("BankruptcyReportLumber"));
            else
                fi = new FileInfo(Utilities.GetConfigValue("BankruptcyReport"));

            // Now deliver our report to the client
            Response.ClearContent();
            Response.ClearHeaders();

            Response.AddHeader("Content-Disposition", "attachment; filename=\"" + Resources.Global.BankruptcyReportDownloadName + "\"");
            Response.AddHeader("Content-Length", fi.Length.ToString());
            Response.ContentType = "application/pdf";

            if(_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                Response.WriteFile(Utilities.GetConfigValue("BankruptcyReportLumber"));
            else
                Response.WriteFile(Utilities.GetConfigValue("BankruptcyReport"));
            
            //Response.Flush();
            //HttpContext.Current.ApplicationInstance.CompleteRequest();

            //Response.Close();
            //Response.End();

            // Removed - This report will be generated daily via the BBSMonitor 
            // Response.Redirect(PageConstants.Format(PageConstants.GET_REPORT, GetReport.BANKRUPCTY_REPORT));
        }

        protected void btnPACADRCViolatorsReport_Click(object sender, EventArgs e)
        {
            FileInfo fi;
            fi = new FileInfo(Utilities.GetConfigValue("PACADRCViolatorsReport"));

            // Now deliver our report to the client
            Response.ClearContent();
            Response.ClearHeaders();

            Response.AddHeader("Content-Disposition", "attachment; filename=\"" + Resources.Global.PACADRCViolatorsReportDownloadName + "\"");
            Response.AddHeader("Content-Length", fi.Length.ToString());
            Response.ContentType = "application/pdf";

            Response.WriteFile(Utilities.GetConfigValue("PACADRCViolatorsReport"));
        }
    }
}
