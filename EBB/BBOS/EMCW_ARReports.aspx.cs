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

 ClassName: EMCW_ARReports
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using PRCo.EBB.BusinessObjects;
using TSI.Arch;
using TSI.BusinessObjects;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web
{
    public partial class EMCW_ARReports : EMCWizardBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            // Set page title, sub-title
            SetPageTitle(Resources.Global.EditCompany, Resources.Global.UploadAccountsReceivable);

            // Add company submenu to this page
            SetSubmenu("btnUploadAccountsReceivable", blnDisableValidation:true);

            // Setup page for file upload
            AddDoubleClickPreventionJS(btnSave);
            EnableFormValidation();
            Form.Attributes.Add("enctype", "multipart/form-data");

            btnCancel.OnClientClick = "bEnableValidation=false;";

            QuickFind oQuickFind = (QuickFind)this.Master.FindControl("QuickFind");
            oQuickFind.GetSearchButton().OnClientClick = "DisableValidation();";

            if (!IsPostBack)
            {
                PopulateForm();
            }
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
        /// Populates the form controls for the specified
        /// company
        /// </summary>
        protected void PopulateForm()
        {
            litHeaderText.Visible = false;
        }

        protected const string SQL_UPDATE_AR_LAST_SUBMITTED_DATE =
            @"UPDATE PRCompanyInfoProfile 
                 SET prc5_ARLastSubmittedDate=GETDATE() 
               WHERE prc5_CompanyId = @CompanyId";

        /// <summary>
        /// Handles the Save on click event.  Creates the task and displays a message informing the user 
        /// the data has been saved.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnSave_Click(object sender, EventArgs e)
        {
            // Check to see if a file was uploaded
            if (!fileARReport.HasFile)
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
                DateTime dtARDate = Convert.ToDateTime(txtARDate.Text);
                string szFileName = "AR Submission File_" + dtARDate.ToString("yyyyMMdd") + "_" + DateTime.Now.ToString("yyyyMMdd-hhmmss");
                string szFileExtension = Path.GetExtension(fileARReport.PostedFile.FileName);

                //strFileName += strFileExtension;

                // Create the full file name using the file path and name created
                szRelativePath = szFileName + szFileExtension;
                szFullFileName = Path.Combine(szFilePath, szRelativePath);
                
                // Check if a file with this name already exists
                int count = 1;
                while (File.Exists(szFullFileName))
                {
                    count++;
                    string suffix = " (" + count.ToString() + ")";
                    szFullFileName = Path.Combine(szFilePath, szFileName + suffix + szFileExtension);
                    szRelativePath = szFileName + suffix + szFileExtension;
                }

                // Save the uploaded file to disk
                fileARReport.SaveAs(szFullFileName);
            }
            catch (Exception ex)
            {
                throw new ApplicationUnexpectedException(String.Format(Resources.Global.ErrorFileUpload, ex.Message));
            }

            IDbTransaction oTran = GetObjectMgr().BeginTransaction();
            try
            {

                // Generate a task for the appropriate user that contains the BBID, Hyperlink to the
                // uploaded file, and the name of the file .
                string subject = "New AR File dated " + txtARDate.Text + " received.";
                StringBuilder sbMsg = new StringBuilder();

                sbMsg.Append(subject);
                int commID = 0;
                int assignedToUserID = 0;

                // Lumber wants the interaction to be assigned to the rating analyst
                // Produce wants them to go to a single user.
                if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                {
                    assignedToUserID = GetObjectMgr().GetPRCoSpecialistID(_oUser.prwu_BBID, GeneralDataMgr.PRCO_SPECIALIST_RATINGS, oTran);
                } else
                {
                    assignedToUserID = Utilities.GetIntConfigValue("CompanyUploadARReportAssignedToUserID", 51);
                }

                commID = GetObjectMgr().CreateTask(assignedToUserID,
                                    "Pending",
                                    sbMsg.ToString(),
                                    Utilities.GetConfigValue("CompanyUploadARReportCategory", "ARSub"),
                                    Utilities.GetConfigValue("CompanyUploadARReportSubcategory", "ARF"),
                                    _oUser.prwu_BBID,
                                    _oUser.peli_PersonID,
                                    0,
                                    "OnlineIn",
                                    subject,
                                    "Y",
                                    oTran);

                InsertLibraryRecord(commID, szCompanyPath, szRelativePath, szFullFileName, Utilities.GetIntConfigValue("CompanyUploadARReportAssignedToUserID", 27), oTran);

                // Insert a self service audit trail record
                List<string> lCategoryCodes = new List<string>();
                lCategoryCodes.Add("AR");
                GetObjectMgr().InsertSelfServiceAuditTrail(lCategoryCodes, oTran);
                oTran.Commit();

                object[] args = { txtARDate.Text, _oUser.prwu_BBID, _oUser.prwu_CompanyName, szCompanyLocation };
                string body = string.Format("New AR File dated {0} received from BB# {1}, {2}, {3}", args);

                int userID1 = 0;
                int userID2 = 0;
                if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                {
                    userID1 = Utilities.GetIntConfigValue("CompanyUploadARReportLumberEmailoUserID1", 1045);
                    userID2 = Utilities.GetIntConfigValue("CompanyUploadARReportLumberEmailoUserID2", 1022);
                }
                else
                {
                    userID1 = Utilities.GetIntConfigValue("CompanyUploadARReportEmailoUserID1", 12);
                    userID2 = Utilities.GetIntConfigValue("CompanyUploadARReportEmailoUserID2", 51);
                }

                SendEmail(oTran, userID1, subject, body, "BBOS AR Report Submission");
                SendEmail(oTran, userID2, subject, body, "BBOS AR Report Submission");
            }
            catch
            {
                if (oTran != null)
                {
                    oTran.Rollback();
                }
                throw;
            }

            //Defect 7034 - update PRCompanyInfoProfile.prc5_ARLastSubmittedDate for this company
            //Needed full database rights to update that table, else a permission denied error is thrown
            _oObjectMgr = new GeneralDataMgr(_oLogger, _oUser);
            _oObjectMgr.ConnectionName = "DBConnectionStringFullRights";
            oTran = _oObjectMgr.BeginTransaction();
            try
            {
                ArrayList oParameters = new ArrayList();
                oParameters.Add(new ObjectParameter("CompanyId", _oUser.prwu_BBID));
                GetDBAccess().ExecuteNonQuery(SQL_UPDATE_AR_LAST_SUBMITTED_DATE, oParameters, oTran);
                _oObjectMgr.Commit();
            }
            catch
            {
                _oObjectMgr.Rollback();
                throw;
            }

            // Display message to user informing them that the data has been saved
            AddUserMessage(Resources.Global.ARReportsSaveMsg, true);

            //Defect 7034 - send email confirming receipt of file
            string szSubject = "AR Report Submitted";
            string szContent = string.Format("Thank you for submitting your AR report through Blue Book Online Services (BBOS) on {0:MM/dd/yyyy}.  ", DateTime.Now) 
                + Resources.Global.ARReportsSaveMsg.Replace("\\r\\n", "  ");
            string szDeliveryAddress = GetDeliveryAddress(_oUser.prwu_BBID);
            //Send email to current BBOS user
            GetObjectMgr().SendEmail_Text(_oUser.Email, szSubject, szContent, "BBOS AR Report Submission", null);

            //Also send to deliveryaddress receipient if it's different than BBOS user
            if(!string.IsNullOrEmpty(szDeliveryAddress) && _oUser.Email.Trim().ToLower() != szDeliveryAddress.Trim().ToLower())
                GetObjectMgr().SendEmail_Text(szDeliveryAddress, szSubject, szContent, "BBOS AR Report Submission", null);

            // Refresh page
            Response.Redirect(PageConstants.EMCW_AR_REPORTS);
        }

        string SQL_GET_DELIVERY_ADDRESS = @"SELECT DeliveryAddress FROM vPRCompanyAttentionLine where prattn_CompanyID=@CompanyID AND prattn_ItemCode = 'ARD'";

        private string GetDeliveryAddress(int iCompanyID)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", iCompanyID));
            using (IDataReader oReader = GetDBAccess().ExecuteReader(SQL_GET_DELIVERY_ADDRESS, oParameters, CommandBehavior.CloseConnection, null))
            {
                if(oReader.Read())
                {
                    return oReader.GetString(0);
                }
            }

            return "";
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

        protected void SendEmail(IDbTransaction oTran, int userID, string subject, string body, string source)
        {
            if (userID == 0)
            {
                return;
            }

            string emailAddress = GetObjectMgr().GetPRCoUserEmail(userID, oTran);
            GetObjectMgr().SendEmail(emailAddress, subject, body, source);
        }

        protected override bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.CompanyEditListingPage).HasPrivilege;
        }
    }
}