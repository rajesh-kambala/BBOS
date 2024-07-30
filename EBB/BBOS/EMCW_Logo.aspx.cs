/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2016-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: EMCW_Logo
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Text;
using PRCo.EBB.BusinessObjects;
using TSI.Arch;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web
{
    public partial class EMCW_Logo : EMCWizardBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            // Set page title, sub-title
            SetPageTitle(Resources.Global.EditCompany, Resources.Global.ManageLogo);

            // Add company submenu to this page
            SetSubmenu("btnManageLogo", blnDisableValidation:true);

            // Setup page for file upload
            AddDoubleClickPreventionJS(btnSave);
            EnableFormValidation();
            Form.Attributes.Add("enctype", "multipart/form-data");

            btnCancel.OnClientClick = "bEnableValidation=false;";

            QuickFind oQuickFind = (QuickFind)this.Master.FindControl("QuickFind");
            oQuickFind.GetSearchButton().OnClientClick = "DisableValidation();";

            cbIAgree.Attributes.Add("onclick", "cbIAgree_Click();");
            Page.ClientScript.RegisterStartupScript(this.GetType(), "cbIAgree", "var cbIAgree=document.getElementById('" + cbIAgree.ClientID + "');", true);

            // disable the Submit button until the I Agree checkbox is clicked
            PostBackURL.Value = ClientScript.GetPostBackEventReference(btnSave, "OnClick");
            btnSave.Enabled = false;

            if (!IsPostBack)
            {
                PopulateForm();
            }
        }

        /// <summary>
        /// Populates the form controls for the specified
        /// company
        /// </summary>
        protected void PopulateForm()
        {
            if (string.IsNullOrEmpty(szLogo))
            {
                litLogo.Visible = true;
                litLogo.Text = Resources.Global.NoCurrentlyPublishedLogoFileFound; // "No currently published logo file found."
            }
            else
            {
                imgLogo.Visible = true;
                imgLogo.ImageUrl = string.Format(Configuration.CompanyLogoURL, szLogo);
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            // Check to see if a file was uploaded
            if (!fileLogo.HasFile)
            {
                AddUserMessage(string.Format(Resources.Global.UploadFileMissingMsg, "").Replace("  ", " "));
                return;
            }

            string szFullFileName = null;
            string szRelativePath = null;
            string szFilePath = null;
            string szCompanyPath = null;
            try
            {
                // Retrieve full file upload path
                szCompanyPath = GetCRMLibraryPath(Configuration.CRMLibraryRoot);
                szFilePath = Path.Combine(Configuration.CRMLibraryRoot, szCompanyPath);

                // Create the new file name
                string szFileName = _oUser.prwu_HQID.ToString() + "_CompanyLogoUploadedFile";
                string szFileExtension = Path.GetExtension(fileLogo.PostedFile.FileName);

                //strFileName += strFileExtension;

                // Create the full file name using the file path and name created
                szRelativePath = szFileName + szFileExtension;
                szFullFileName = Path.Combine(szFilePath, szRelativePath);

                // Check if a file with this name already exists
                int count = 1;
                while (File.Exists(szFullFileName))
                {
                    count++;
                    string suffix = "_(" + count.ToString() + ")";
                    szFullFileName = Path.Combine(szFilePath, szFileName + suffix + szFileExtension);
                    szRelativePath = szFileName + suffix + szFileExtension;
                }

                // Save the uploaded file to disk
                fileLogo.SaveAs(szFullFileName);
            }
            catch (Exception ex)
            {
                throw new ApplicationUnexpectedException(String.Format(Resources.Global.ErrorFileUpload, ex.Message));
            }

            IDbTransaction oTran = GetObjectMgr().BeginTransaction();
            try
            {
                int assignedToUserID = GetObjectMgr().GetPRCoSpecialistID(_oUser.prwu_HQID, 4, oTran);

                // Generate a task for the appropriate user that contains the BBID, Hyperlink to the
                // uploaded file, and the name of the file .
                string subject = "New Company Logo File";
                StringBuilder sbMsg = new StringBuilder();

                sbMsg.Append(subject);
                sbMsg.Append(Environment.NewLine + Environment.NewLine);
                sbMsg.Append("The Logo Agreement was accepted electronically within BBOS by the user.");
                int commID = 0;

                commID = GetObjectMgr().CreateTask(assignedToUserID,
                                                  "Pending",
                                                  sbMsg.ToString(),
                                                  Utilities.GetConfigValue("CompanyUploadLogoCategory", "CS"),
                                                  Utilities.GetConfigValue("CompanyUploadLogoSubcategory", "LG"),
                                                  _oUser.prwu_BBID,
                                                  _oUser.peli_PersonID,
                                                  0,
                                                  "OnlineIn",
                                                  subject,
                                                  "Y",
                                                  oTran);

                InsertLibraryRecord(commID, szCompanyPath, szRelativePath, szFullFileName, assignedToUserID, oTran);

                // Insert a self service audit trail record
                List<string> lCategoryCodes = new List<string>();
                lCategoryCodes.Add("LOGO");
                GetObjectMgr().InsertSelfServiceAuditTrail(lCategoryCodes, oTran);
                oTran.Commit();

                //object[] args = {_oUser.prwu_BBID, _oUser.prwu_CompanyName, szCompanyLocation };
                //string body = string.Format("New company logo file received from BB# {0}, {1}, {2}", args);

                //int userID1 = Utilities.GetIntConfigValue("CompanyUploadLogoEmailUserID1", 12);
                //string email = GetObjectMgr().GetPRCoUserEmail(userID1, oTran);
                //GetObjectMgr().SendEmail(email, subject, body, "BBOS AR Report Submission");

                //int userID2 = Utilities.GetIntConfigValue("CompanyUploadLogoEmailUserID1", 27);
                //email = GetObjectMgr().GetPRCoUserEmail(userID2, oTran);
                //GetObjectMgr().SendEmail(email, subject, body, "BBOS AR Report Submission");
            }
            catch
            {
                if (oTran != null)
                {
                    oTran.Rollback();
                }
                throw;
            }

            // Display message to user informing them that the data has been saved
            AddUserMessage(Resources.Global.LogoSaveMsg, true);

            // Refresh page
            Response.Redirect(PageConstants.EMCW_LOGO);
        }

        /// <summary>
        /// Helper method to return a handle to the Company Details Header used on the page to display 
        /// the company BB #, name, and location
        /// </summary>
        /// <returns></returns>
        protected override EMCW_CompanyHeader GetEditCompanyWizardHeader()
        {
            return ucCompanyDetailsHeader;
        }

        /// <summary>
        /// Handles the cancel on click event.  Takes the user to the member home page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnCancel_Click(object sender, EventArgs e)
        {
            // Takes the user to the member home page
            Response.Redirect(PageConstants.BBOS_HOME);
        }

        protected override bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.CompanyEditListingPage).HasPrivilege;
        }

        public override bool EnableJSClientIDTranslation()
        {
            return true;
        }
    }
}