/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Company 2010-2012

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: PRPublicationUpload
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PRCo.BBS.CRM
{
    public partial class PRPublicationUpload : PageBase
    {
        override protected  void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if (!IsPostBack)
            {
                hidIsPublicationEdition.Value = Request["IsPublicationEdition"];
                hidIsTraining.Value = Request["IsTraining"];
                hidIsNHA.Value = Request["IsNHA"];

                if (Request["IsPublicationEdition"] == "Y")
                {
                    litFile1.Text = "Cover Art Image File";
                    litFile2.Text = "Cover Art Thumb Image File";

                    litFile3.Visible = false;
                    upFile3.Visible = false;
                }
                else if (Request["IsTraining"] == "Y")
                {
                    litFile1.Text = "Document File";
                    litFile2.Text = "Icon Image File (If not specified, the default image will be displayed)";

                    litFile3.Visible = false;
                    upFile3.Visible = false;
                }
                else if (Request["IsNHA"] == "Y")
                {
                    litFile1.Text = "PDF Slides File";
                    litFile2.Text = "Icon Image File (If not specified, the default image will be displayed)";

                    litFile3.Visible = false;
                    upFile3.Visible = false;
                }
                else
                {
                    litFile1.Text = "Publication File";
                    litFile2.Text = "Cover Art Image File";
                    litFile3.Text = "Cover Art Thumb Image File";
                }
            }

            if (IsPostBack)
            {

                try
                {
                    SaveFiles();

                    // Once we're good to go, make sure we submit our
                    // parent form.
                    ClientScript.RegisterStartupScript(this.GetType(), "submitParent", "submitParent();", true);
                } catch (Exception eX) {

                    lblMsg.Text = eX.Message;
                    //lblOutput.Text = eX.StackTrace;
                }
            }
        }


        protected const string SQL_SELECT_ROOT_DIR = "SELECT Capt_US FROM Custom_Captions WITH (NOLOCK) WHERE Capt_FamilyType = 'Choices' AND Capt_Family = 'PRPublicationUploadDirectory'";
        protected void SaveFiles()
        {
            SqlConnection sqlConn = null;
            try
            {
                sqlConn = OpenDBConnection();
                SqlCommand cmdRootDir = new SqlCommand(SQL_SELECT_ROOT_DIR, sqlConn);

                string szRootDir = (string)cmdRootDir.ExecuteScalar();
                if ((!szRootDir.EndsWith(@"\")))
                {
                    szRootDir += @"\";
                }

                SaveFile(szRootDir, upFile1, hidOldFile1.Value, hidUploadedFileName1);
                SaveFile(szRootDir, upFile2, hidOldFile2.Value, hidUploadedFileName2);
                SaveFile(szRootDir, upFile3, hidOldFile3.Value, hidUploadedFileName3);
            }
            catch (Exception e)
            {
                lblMsg.Text = e.Message;
            } 
            finally
            {
                CloseDBConnection(sqlConn);
            }                
        }

        protected void SaveFile(string szRootDir, 
                                FileUpload upFile, 
                                string szOldFileName,
                                HiddenField hidNewFileName)
        {

            if (!upFile.HasFile)
            {
                return;
            }

            // Translate all Blueprint article types to
            // BP.
            string publicationCode = hidPublicationCode.Value;
            if ((publicationCode == "BPFB") ||
                (publicationCode == "BPS") ||
                (publicationCode == "BPFBS"))
            {
                publicationCode = "BP";
            }

            string szBaseDir = publicationCode + @"\";
            if (!string.IsNullOrEmpty(hidEditionName.Value)) {
                szBaseDir += hidEditionName.Value + @"\";
            }

            string szDebug = string.Empty;
            //lblMsg.Text += "Does it exist? " + Path.Combine(szRootDir, szBaseDir) + "<br/>";

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

            hidNewFileName.Value = szBaseDir;
        }
    }
}

