/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Company 2010-2023

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: AdCampaignFileUpload
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI.WebControls;

namespace PRCo.BBS.CRM
{
    public partial class AdCampaignFileUpload : PageBase
    {
        //SubmitFlag
        //      P = submitParent()
        //      # = submitNextFileUpload(#) 
        //              ex:   _frame_uploadadimagefile2 if 2 is the value

        protected string _szSubmitFlag = "P";
        protected string _szFileTypeCode = "DI"; //DI or PI to determine how to save each of the 2 files in KYC
           
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            string szSubmitFlagQueryString = Request.QueryString["SubmitFlag"];
            if(!string.IsNullOrEmpty(szSubmitFlagQueryString))
            {
                _szSubmitFlag = szSubmitFlagQueryString.ToUpper();
                hidSubmitFlag.Value = szSubmitFlagQueryString.ToUpper();
            }

            string szFileTypeCode = Request.QueryString["FileTypeCode"];
            if (!string.IsNullOrEmpty(szFileTypeCode))
            {
                _szFileTypeCode = szFileTypeCode.ToUpper();
                hidFileTypeCode.Value = szFileTypeCode.ToUpper();
            }

            if (IsPostBack)
            {
                try
                {
                    SaveFiles();

                    // Once we're good to go, make sure we submit our
                    // parent form.
                    if(_szSubmitFlag == "P")
                        ClientScript.RegisterStartupScript(this.GetType(), "submitParent", "submitParent();", true);
                    else if(_szSubmitFlag.Length > 0)
                        ClientScript.RegisterStartupScript(this.GetType(), "submitNextFileUpload", string.Format("parent.submitNextFileUpload({0});", _szSubmitFlag), true);
                }
                catch (Exception eX)
                {
                    Response.Write("Error Page_Load: " + eX.Message + "<br>");
                    lblMsg.Text = eX.Message;
                    //lblOutput.Text = eX.StackTrace;
                }
            }
        }

        protected void SaveFiles()
        {
            try
            {
                SaveFile(upFile1, hidOldFile1.Value, hidUploadedFileName1);
            }
            catch (Exception e)
            {
                lblMsg.Text = e.Message;
            }
        }

        protected void SaveFile(FileUpload upFile,
                                string szOldFileName,
                                HiddenField hidNewFileName)
        {
            if (!upFile.HasFile)
            {
                return;
            }

            string szRootDir = GetRootDir();
            string szBaseDir = GetBaseDir();

            // Make sure that the directory exists.
            if (!Directory.Exists(Path.Combine(szRootDir, szBaseDir)))
            {
                Directory.CreateDirectory(Path.Combine(szRootDir, szBaseDir));
            }

            szBaseDir += upFile.FileName;

            // Now save our file.
            string szNewFile = Path.Combine(szRootDir, szBaseDir);
            upFile.SaveAs(szNewFile);

            hidNewFileName.Value = szBaseDir;

            // Defect 7005 - if print, then save in 2nd location
            if ((hidAdType.Value == "KYC" && _szFileTypeCode == "PI") || hidAdType.Value == "BP")
            {
                SaveFilePrintCopyInDigitalSubfolder(upFile, szOldFileName, hidNewFileName);
            }
        }

        // For defect 7005, save print images a 2nd time to digital subfolder so that BBOS ad campaign list screen can access them
        protected void SaveFilePrintCopyInDigitalSubfolder(FileUpload upFile,
                                 string szOldFileName,
                                 HiddenField hidNewFileName)
        {
            if (!upFile.HasFile)
            {
                return;
            }

            string szRootDir = GetDigitalRootDir();
            string szBaseDir = GetDigitalBaseDir() + "Print\\";

            // Make sure that the directory exists.
            if (!Directory.Exists(Path.Combine(szRootDir, szBaseDir)))
            {
                Directory.CreateDirectory(Path.Combine(szRootDir, szBaseDir));
            }

            // Check for the old file and delete it
            string szOldFile = szRootDir + szOldFileName;
            if (File.Exists(szOldFile))
            {
                File.Delete(szOldFile);
            }

            szBaseDir += upFile.FileName;

            // Now save our file.
            string szNewFile = Path.Combine(szRootDir, szBaseDir);
            upFile.SaveAs(szNewFile);
        }

        private string GetRootDir()
        {
            if ((hidAdType.Value == "BP") ||
                (hidAdType.Value == "PUB") ||
                (hidAdType.Value == "KYC" && _szFileTypeCode=="PI"))
            {
                return GetPrintRootDir();
            }
            else
            {
                return GetDigitalRootDir();
            }
        }

        private string GetPrintRootDir()
        {
            return GetLibraryRoot(); //docstore
        }
        private string GetPrintBaseDir()
        {
            SqlConnection sqlConn = null;
            try
            {
                sqlConn = OpenDBConnection();

                string szCmdText = string.Format(SQL_SELECT_COMPANY_NAME, hidBBID.Value);
                SqlCommand cmdCompanyName = new SqlCommand(szCmdText, sqlConn);
                string szCompanyName = (string)cmdCompanyName.ExecuteScalar();

                // If the company ends with a period, which they all should do, then we
                // need to strip it off, because that's what CRM does.
                if (szCompanyName.EndsWith("."))
                {
                    szCompanyName = szCompanyName.Substring(0, szCompanyName.Length - 1);
                }

                return szCompanyName.Substring(0, 1) + @"\" + szCompanyName + @"\";
            }
            finally
            {
                CloseDBConnection(sqlConn);
            }
        }

        private string GetDigitalRootDir()
        {
            return GetBBOSAdRootDir(); //PRCompanyAdUploadDirectory
        }
        private string GetDigitalBaseDir()
        {
            return hidBBID.Value + @"\"; ;
        }

        private string GetBaseDir()
        {
            if ((hidAdType.Value == "BP") ||
                (hidAdType.Value == "PUB") ||
                (hidAdType.Value == "KYC" && _szFileTypeCode == "PI"))
            {
                return GetPrintBaseDir();
            }
            else
            {
                return GetDigitalBaseDir();
            }
        }

        protected const string SQL_SELECT_CRM_LIBRARY_DIR = "SELECT parm_value FROM custom_sysparams WITH (NOLOCK) WHERE Parm_Name = 'DocStore'";
        protected const string SQL_SELECT_COMPANY_NAME = "SELECT comp_Name FROM Company WITH (NOLOCK) WHERE comp_CompanyID = {0}";

        private string GetLibraryRoot()
        {
            string szRootDir = null;

            SqlConnection sqlConn = null;
            try
            {
                sqlConn = OpenDBConnection();
                SqlCommand cmdRootDir = new SqlCommand(SQL_SELECT_CRM_LIBRARY_DIR, sqlConn);
                szRootDir = (string)cmdRootDir.ExecuteScalar();
                if ((!szRootDir.EndsWith(@"\")))
                {
                    szRootDir += @"\";
                }

                return szRootDir;
            }
            finally
            {
                CloseDBConnection(sqlConn);
            }
        }

        protected const string SQL_SELECT_BBOS_ADCAMPAIGN_DIR = "SELECT Capt_US FROM Custom_Captions WITH (NOLOCK) WHERE Capt_FamilyType = 'Choices' AND Capt_Family = 'PRCompanyAdUploadDirectory'";
        private string GetBBOSAdRootDir()
        {
            string szRootDir = null;

            SqlConnection sqlConn = null;
            try
            {
                sqlConn = OpenDBConnection();
                SqlCommand cmdRootDir = new SqlCommand(SQL_SELECT_BBOS_ADCAMPAIGN_DIR, sqlConn);

                szRootDir = (string)cmdRootDir.ExecuteScalar();
                if ((!szRootDir.EndsWith(@"\")))
                {
                    szRootDir += @"\";
                }

                return szRootDir;
            }
            finally
            {
                CloseDBConnection(sqlConn);
            }
        }
    }
}
