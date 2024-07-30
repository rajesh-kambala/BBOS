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

 ClassName: CompanyUpdateDownload
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.IO;
using System.Web.UI;

using PRCo.EBB.BusinessObjects;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This page presents the most recent Company Update PDF files for 
    /// download.  They are presented from a directory on disk and sorted
    /// by most recent first.
    /// </summary>
    public partial class CompanyUpdateDownload : PageBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            SetPageTitle(Resources.Global.CreditSheetDownloads);

            Page.ClientScript.RegisterStartupScript(this.GetType(),
                                                    "EnableRowHighlight",
                                                    "EnableRowHighlight(document.getElementById('tblDownloads'));",
                                                    true);

            PopulateForm();
        }

        /// <summary>
        /// Populates the list of Company Update files available 
        /// for download.
        /// </summary>
        protected void PopulateForm()
        {
            string szRootFolder = null;

            litMsg1.Text = string.Format(Resources.Global.CompanyUpdateMsg1, PageConstants.COMPANY_UPDATE_SEARCH);

            int publicationArticleID;
            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                publicationArticleID = Convert.ToInt32(Utilities.GetConfigValue("LumberRatingArticle", "7732"));
            else
                publicationArticleID = Convert.ToInt32(Utilities.GetConfigValue("NonLumberRatingArticle", "6214"));

            litMsg2.Text = string.Format(Resources.Global.CompanyUpdateMsg2, String.Format("GetPublicationFile.aspx?PublicationArticleID={0}", publicationArticleID));

            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                szRootFolder = Utilities.GetConfigValue("CompanyUpdatesLumberFolder");
            }
            else
            {
                szRootFolder = Utilities.GetConfigValue("CompanyUpdatesFolder");
            }

            int iMaxFiles = Utilities.GetIntConfigValue("CompanyUpdatesMax", 10);

            List<DownloadFile> lDownloadFiles = new List<DownloadFile>();
            DirectoryInfo oDirInfo = new DirectoryInfo(szRootFolder);

            FileInfo[] aFileInfo = oDirInfo.GetFiles("*.pdf");
            Array.Sort(aFileInfo, new CompareFileInfoEntries());

            if (iMaxFiles > aFileInfo.Length)
            {
                iMaxFiles = aFileInfo.Length;
            }

            for (int iIndex = 0; iIndex < iMaxFiles; iIndex++)
            {
                FileInfo oFileInfo = aFileInfo[iIndex];

                DownloadFile oDownloadFile = new DownloadFile();
                oDownloadFile.FileDate = oFileInfo.LastWriteTime;
                oDownloadFile.FileName = oFileInfo.Name;
                oDownloadFile.FileSize = UIUtils.GetFileSize(oFileInfo.Length);
                oDownloadFile.Index = iIndex + 1;

                lDownloadFiles.Add(oDownloadFile);
            }

            gvDownloadFiles.DataSource = lDownloadFiles;
            gvDownloadFiles.DataBind();
            EnableBootstrapFormatting(gvDownloadFiles);
        }

        /// <summary>
        /// Returns the URL to use for the Company Update file
        /// </summary>
        /// <param name="szFileName"></param>
        /// <returns></returns>
        protected string GetURL(object szFileName)
        {
            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                return Utilities.GetConfigValue("CompanyUpdatesLumberVirtualFolder") + (string)szFileName;
            }
            else
            {
                return Utilities.GetConfigValue("CompanyUpdatesVirtualFolder") + (string)szFileName;
            }
        }

        /// <summary>
        /// Only members level 1 or greater can access
        /// this page.
        /// </summary>
        /// <returns></returns>
        protected override bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.CompanyUpdatesDownloadPage).HasPrivilege;
        }

        protected override bool IsAuthorizedForData()
        {
            return true;
        }
    }
}
