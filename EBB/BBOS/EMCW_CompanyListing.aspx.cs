/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2023

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: EMCW_CompanyListing
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Text;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using PRCo.EBB.Util;
using TSI.Arch;
using TSI.BusinessObjects;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This page is part of the edit company wizard.  It allows users to not changes in the company
    /// listing.
    /// 
    /// No changes will be written directly to the PIKS tables.  Instead a task will be created for
    /// the company's listing specialist with the title "Customer submit listing changes".
    /// 
    /// If they user's company is not listed, display an error message.
    /// </summary>
    public partial class EMCW_CompanyListing : EMCWizardBase
    {
        protected const string SQL_GET_LISTING = "SELECT dbo.ufn_GetListingCache({0}, {1})";

        protected int _companyID = 0;
        protected string _companyName;

        /// <summary>
        /// Calls page functions required to build and process this page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            // Set page title, sub-title and add any additional javascript required for processing this page
            SetPageTitle(Resources.Global.EditCompany, Resources.Global.CompanyListing);

            // Add company submenu to this page
            SetSubmenu("btnCompanyListing" , blnDisableValidation: true);

            if (szCompanyType == CODE_COMPANY_TYPE_BRANCH)
                litBranchMsg.Text = Resources.Global.IncludeBranchMsgHQ;
            else
                litBranchMsg.Text = Resources.Global.IncludeBranchesMsg;

            // Display message to the user if their company is not listed
            if (!(GetObjectMgr().IsCompanyListed(_oUser.prwu_BBID)))
                pnlNotListed.Visible = true;

            SetPopover();

            if (!IsPostBack)
            {
                PopulateForm();
            }

            //Set user controls
            ucCompanyListing.WebUser = _oUser;
            ucCompanyListing.companyID = iCompanyID.ToString();// hidCompanyID.Text;

            EnableFormValidation();
        }

        protected void SetPopover()
        {
            //social media popover set in repSocialMedia_ItemDataBound
            //popWhatIsSM.Attributes.Add("data-bs-title", Resources.Global.SocialMediaHelp);
        }

        /// <summary>
        /// Set page to auto-generate javascript variables for form elements.
        /// This is required for the include branches popup on the form.
        /// </summary>
        /// <returns></returns>
        public override bool EnableJSClientIDTranslation()
        {
            return true;
        }

        /// <summary>
        /// Populates the form controls for the specified
        /// company
        /// </summary>
        protected void PopulateForm()
        {
            if (!_oUser.HasPrivilege(SecurityMgr.Privilege.CompanyEditListingPage).HasPrivilege)
            {
                pnlNoEdit.Visible = true;
                btnSubmit.Enabled = false;
            }

            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                btnDLIdeas.Visible = false;
                pnlProduce.Visible = false;
                BindLookupValues(ddlVolume, GetReferenceData("prcp_VolumeL"), true);
            }
            else
            {
                litDLIdeasHTML.Text = GetDLIdeas();
                pnlLumber.Visible = false;
                BindLookupValues(ddlVolume, GetReferenceData("prcp_Volume"), true);
            }
            litVolumeText.Text = Resources.Global.Volume + " - " + Resources.Global.VolumeText.Replace("<br/>", " ") + ":";

            PopulateSocialMedia(iCompanyID);
            SetEnterprise();
        }

        /// <summary>
        /// Helper method to return a handle to the Company Details Header used on the page to display 
        /// the company BB #, name, and location
        /// </summary>
        /// <returns></returns>
        protected override EMCW_CompanyHeader GetEditCompanyWizardHeader()
        {
            return (EMCW_CompanyHeader)ucCompanyDetailsHeader;
        }

        /// <summary>
        /// Handles the Listing Report button on click event.  Prompts if the branches should be included
        /// (ajax), and invokes the GetReport page specifying the appropriate parameters for the company
        /// listing report.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnListingReport_Click(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.Format(PageConstants.GET_REPORT, GetReport.LISTING_REPORT_LETTER));
        }

        /// <summary>
        /// Handles the Submit on click event.  Creates the task and displays a message informing the user 
        /// the data has been saved.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            // Determine what categories of data the user has submitted a change request for 
            List<string> lCategoryCodes = new List<string>();

            if (!String.IsNullOrEmpty(txtAddresses.Text))
                lCategoryCodes.Add(CODE_AUDIT_CATEGORY_ADDRESS);
            if (!String.IsNullOrEmpty(txtPhoneNumbers.Text))
                lCategoryCodes.Add(CODE_AUDIT_CATEGORY_PHONE);
            if (!String.IsNullOrEmpty(txtEmailWeb.Text))
                lCategoryCodes.Add(CODE_AUDIT_CATEGORY_EMAILWEB);
            if (!String.IsNullOrEmpty(txtCommodities.Text))
                lCategoryCodes.Add(CODE_AUDIT_CATEGORY_COMMODITY);
            if (!String.IsNullOrEmpty(txtClassifications.Text))
                lCategoryCodes.Add(CODE_AUDIT_CATEGORY_CLASSIFICATION);
            if(!String.IsNullOrEmpty(ddlVolume.SelectedValue))
                lCategoryCodes.Add(CODE_AUDIT_CATEGORY_VOLUME);
            if (!String.IsNullOrEmpty(txtBrands.Text))
                lCategoryCodes.Add(CODE_AUDIT_CATEGORY_BRAND);
            if (!String.IsNullOrEmpty(txtOther.Text))
                lCategoryCodes.Add(CODE_AUDIT_CATEGORY_OTHER);

            if (!String.IsNullOrEmpty(txtSpecie.Text))
                lCategoryCodes.Add(CODE_AUDIT_CATEGORY_SPECIE);
            if (!String.IsNullOrEmpty(txtServicesProvided.Text))
                lCategoryCodes.Add(CODE_AUDIT_CATEGORY_SERVICEPROVIDED);
            if (!String.IsNullOrEmpty(txtProductProvided.Text))
                lCategoryCodes.Add(CODE_AUDIT_CATEGORY_PRODUCTPROVIDED);

            string szFullCertFileName = null;
            string szRelativePath = null;
            string szFilePath = null;
            string szCompanyPath = null;

            if (fileCertFile.HasFile)
            {
                try
                {
                    // Retrieve full file upload path
                    szCompanyPath = GetCRMLibraryPath(Configuration.CRMLibraryRoot);
                    szFilePath = Path.Combine(Configuration.CRMLibraryRoot, szCompanyPath);

                    // Create the new file name
                    DateTime dtCertDate = DateTime.Now;
                    string szFileName = "Cert File_" + dtCertDate.ToString("yyyyMMdd") + "_" + dtCertDate.ToString("yyyyMMdd-hhmmss");
                    string szFileExtension = Path.GetExtension(fileCertFile.PostedFile.FileName);

                    // Create the full file name using the file path and name created
                    szRelativePath = szFileName + szFileExtension;
                    szFullCertFileName = Path.Combine(szFilePath, szRelativePath);

                    // Check if a file with this name already exists
                    int count = 1;
                    while (File.Exists(szFullCertFileName))
                    {
                        count++;
                        string suffix = " (" + count.ToString() + ")";
                        szFullCertFileName = Path.Combine(szFilePath, szFileName + suffix + szFileExtension);
                        szRelativePath = szFileName + suffix + szFileExtension;
                    }

                    // Save the uploaded file to disk
                    fileCertFile.SaveAs(szFullCertFileName);
                }
                catch (Exception ex)
                {
                    throw new ApplicationUnexpectedException(String.Format(Resources.Global.ErrorFileUpload, ex.Message));
                }
            }

            IDbTransaction oTran = GetObjectMgr().BeginTransaction();
            try
            {
                // If some of the data has changed
                if (lCategoryCodes.Count > 0 || !string.IsNullOrEmpty(szFullCertFileName))
                {
                    // Create user task noting changes
                    string szMsg = "Customer submit listing changes:" + Environment.NewLine;
                    szMsg += GetListingInfoForTask(szFullCertFileName);

                    int commID = 0;

                    //Defect 6828 - send task and email to HQ specialist instead of company specialist
                    if (!string.IsNullOrEmpty(szFullCertFileName))
                    {
                        //Defect 4640 attach cert file
                        string subject = "New Certification File received.";
                            
                        commID = GetObjectMgr().CreateTask(GetObjectMgr().GetPRCoSpecialistID(iHQCompanyID, GeneralDataMgr.PRCO_SPECIALIST_LISTING_SPECIALIST, oTran),
                          "Pending",
                          szMsg,
                          Utilities.GetConfigValue("CompanySubmitListingChangeCategory", "L"),
                          Utilities.GetConfigValue("CompanySubmitListingChangeSubcategory", "LI"),
                          _oUser.prwu_BBID,
                          _oUser.peli_PersonID,
                          0,
                          "OnlineIn",
                          subject,
                          "Y",
                          oTran);

                        InsertLibraryRecord(commID, szCompanyPath, szRelativePath, szFullCertFileName, Utilities.GetIntConfigValue("CompanyUploadCertFileAssignedToUserID", 1006), oTran); //default manager of listings = jmangini@bluebookservices.com
                    }
                    else
                    {
                        GetObjectMgr().CreateTask(GetObjectMgr().GetPRCoSpecialistID(iHQCompanyID, GeneralDataMgr.PRCO_SPECIALIST_LISTING_SPECIALIST, oTran),
                                                  "Pending",
                                                  szMsg,
                                                  Utilities.GetConfigValue("CompanySubmitListingChangeCategory", ""),
                                                  Utilities.GetConfigValue("CompanySubmitListingChangeSubcategory", ""),
                                                  _oUser.prwu_BBID,
                                                  _oUser.peli_PersonID,
                                                  0,
                                                  "OnlineIn",
                                                  oTran);
                    }

                    
                    //Defect 6973 - emails via stored proc
                    GetObjectMgr().SendEmail_Text(GetObjectMgr().GetPRCoUserEmail(GetObjectMgr().GetPRCoSpecialistID(iHQCompanyID, GeneralDataMgr.PRCO_SPECIALIST_LISTING_SPECIALIST, oTran), oTran),
                        Utilities.GetConfigValue("CompanySubmitListingChangeEmailSubject", "Member Listing Change via BBOS"),
                        szMsg,
                        "EMCW_CompanyListing.aspx",
                        oTran);

                    // Insert self service audit trail records
                    GetObjectMgr().InsertSelfServiceAuditTrail(lCategoryCodes, oTran);
                }

                SaveSocialMedia(iCompanyID, oTran);

                //Clear out commodity fields
                txtCommodity.Text = "";
                txtCommodities.Text = ""; 

                // Display message to user informing them that the data has been saved
                AddUserMessage(Resources.Global.SaveMsgCompanyListing);

                oTran.Commit();
            }
            catch
            {
                if (oTran != null)
                {
                    oTran.Rollback();
                }
                throw;
            }
            PopulateSocialMedia(iCompanyID);
        }

        private void ClearFields()
        {
            txtAddresses.Text = string.Empty;
            txtPhoneNumbers.Text = string.Empty;
            txtEmailWeb.Text = string.Empty;
            txtCommodities.Text = string.Empty;
            txtSpecie.Text = string.Empty;
            txtProductProvided.Text = string.Empty;
            txtServicesProvided.Text = string.Empty;
            txtClassifications.Text = string.Empty;
            ddlVolume.SelectedValue = string.Empty;
            txtBrands.Text = string.Empty;
            txtOther.Text = string.Empty;
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

        /// <summary>
        /// Helper method that formats the listing data change requests for including
        /// in a BBS CRM task.
        /// </summary>
        /// <returns></returns>
        protected string GetListingInfoForTask(string szFullCertFileName)
        {
            StringBuilder sbMsg = new StringBuilder();

            // Retrieve the data entered on the form.
            sbMsg.Append(_oUser.Name + Environment.NewLine);
            sbMsg.Append(szCompanyName + Environment.NewLine);

            if ((szCompanyType == CODE_COMPANY_TYPE_BRANCH))
            {
                sbMsg.Append("Branch ");
            }

            sbMsg.Append("BB #: " + iCompanyID.ToString() + Environment.NewLine);
            sbMsg.Append("HQ BB #: " + _oUser.prwu_HQID.ToString() + Environment.NewLine);
            sbMsg.Append(Environment.NewLine);

            if (!string.IsNullOrEmpty(txtAddresses.Text.Trim()))
            {
                sbMsg.Append("Company Addresses: " + Environment.NewLine + txtAddresses.Text.Trim() + Environment.NewLine + Environment.NewLine);
            }
            if (!string.IsNullOrEmpty(txtPhoneNumbers.Text.Trim()))
            {
                sbMsg.Append("Company Phone Numbers: " + Environment.NewLine + txtPhoneNumbers.Text.Trim() + Environment.NewLine + Environment.NewLine);
            }
            if (!string.IsNullOrEmpty(txtEmailWeb.Text.Trim()))
            {
                sbMsg.Append("Company Email/Web Site: " + Environment.NewLine + txtEmailWeb.Text.Trim() + Environment.NewLine + Environment.NewLine);
            }
            if (!string.IsNullOrEmpty(txtCommodities.Text.Trim()))
            {
                sbMsg.Append("Commodities: " + Environment.NewLine + txtCommodities.Text.Trim() + Environment.NewLine + Environment.NewLine);
            }

            if (!string.IsNullOrEmpty(txtSpecie.Text.Trim()))
            {
                sbMsg.Append("Species: " + Environment.NewLine + txtSpecie.Text.Trim() + Environment.NewLine + Environment.NewLine);
            }
            if (!string.IsNullOrEmpty(txtServicesProvided.Text.Trim()))
            {
                sbMsg.Append("Services Provided: " + Environment.NewLine + txtServicesProvided.Text.Trim() + Environment.NewLine + Environment.NewLine);
            }
            if (!string.IsNullOrEmpty(txtProductProvided.Text.Trim()))
            {
                sbMsg.Append("Products Provided: " + Environment.NewLine + txtProductProvided.Text.Trim() + Environment.NewLine + Environment.NewLine);
            }

            if (!string.IsNullOrEmpty(txtClassifications.Text.Trim()))
            {
                sbMsg.Append("Classifications: " + Environment.NewLine + txtClassifications.Text.Trim() + Environment.NewLine + Environment.NewLine);
            }
            if (!string.IsNullOrEmpty(ddlVolume.SelectedValue))
            {
                sbMsg.Append("Volume: " + Environment.NewLine + ddlVolume.SelectedItem.Text + Environment.NewLine + Environment.NewLine);
            }
            if (!string.IsNullOrEmpty(txtBrands.Text.Trim()))
            {
                sbMsg.Append("Brands: " + Environment.NewLine + txtBrands.Text.Trim() + Environment.NewLine + Environment.NewLine);
            }
            if (!string.IsNullOrEmpty(txtOther.Text.Trim()))
            {
                sbMsg.Append("Other Requests: " + Environment.NewLine + txtOther.Text.Trim() + Environment.NewLine + Environment.NewLine);
            }
            if (!string.IsNullOrEmpty(szFullCertFileName))
            {
                sbMsg.Append("Cert File: " + Environment.NewLine + Path.GetFileName(szFullCertFileName) + Environment.NewLine + Environment.NewLine);
            }

            return sbMsg.ToString();
        }

        protected string GetDLIdeas()
        {
            string szFileName = null;
            switch (szIndustryType)
            {
                case GeneralDataMgr.INDUSTRY_TYPE_PRODUCE:
                    szFileName = "DLIdeasProduce.htm";
                    break;
                case GeneralDataMgr.INDUSTRY_TYPE_TRANSPORTATION:
                    szFileName = "DLIdeasTransportation.htm";
                    break;
                case GeneralDataMgr.INDUSTRY_TYPE_SUPPLY:
                    szFileName = "DLIdeasSupply.htm";
                    break;
            }

            if (string.IsNullOrEmpty(szFileName))
            {
                return string.Empty;
            }

            using (StreamReader srDLIdeas = new StreamReader(Server.MapPath(UIUtils.GetTemplateURL(szFileName))))
            {
                return srDLIdeas.ReadToEnd();
            }
        }

        protected const string SQL_SOCIAL_MEDIA =
            @"SELECT RTRIM(capt_Code) AS capt_Code, 
	            dbo.ufn_GetCustomCaptionValue('prsm_SocialMediaTypeCode',RTRIM(capt_code),@Culture) capt_US,
	            prsm_SocialMediaID, 
	            prsm_SocialMediaTypeCode, 
	            prsm_URL 
            FROM custom_captions WITH(NOLOCK)
	            LEFT OUTER JOIN PRSocialMedia WITH(NOLOCK) ON capt_code = prsm_SocialMediaTypeCode AND prsm_CompanyID=@CompanyID AND prsm_Disabled IS NULL 
            WHERE capt_Family = 'prsm_SocialMediaTypeCode'
            ORDER BY Capt_Order ";
        protected void PopulateSocialMedia(int companyID)
        {
            if (!Utilities.GetBoolConfigValue("SocialMediaEnabled", true))
            {
                pnlSocialMedia.Visible = false;
                return;
            }

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", companyID));
            oParameters.Add(new ObjectParameter("Culture", _oUser.prwu_Culture ));

            repSocialMedia.DataSource = GetDBAccess().ExecuteReader(SQL_SOCIAL_MEDIA, oParameters, CommandBehavior.CloseConnection, null);
            repSocialMedia.DataBind();

            repSocialMediaDomains.DataSource = GetReferenceData("prsm_SocialMediaDomain");
            repSocialMediaDomains.DataBind();
        }

        protected void SaveSocialMedia(int companyID, IDbTransaction oTran)
        {
            if (!Utilities.GetBoolConfigValue("SocialMediaEnabled", true))
            {
                return;
            }

            GeneralDataMgr dataMgr = new GeneralDataMgr(_oLogger, _oUser);

            IBusinessObjectSet osSocialMedia = GetReferenceData("prsm_SocialMediaTypeCode");
            foreach (ICustom_Caption customCaption in osSocialMedia)
            {
                string id = GetRequestParameter("hdnSMID_" + customCaption.Code, false);
                string url = GetRequestParameter("txtSMURL_" + customCaption.Code, false);

                if (!string.IsNullOrEmpty(url))
                {
                    if (string.IsNullOrEmpty(id))
                    {
                        dataMgr.InsertSocialMedia(companyID, customCaption.Code, url, oTran);
                    }
                    else
                    {
                        dataMgr.UpdateSocialMedia(Convert.ToInt32(id), url, oTran);
                    }
                }
                else
                {
                    if (!string.IsNullOrEmpty(id))
                    {
                        dataMgr.DeleteSocialMedia(Convert.ToInt32(id), oTran);
                    }
                }
            }
        }

        private const string SQL_ENTERPRISE =
            @"SELECT comp_CompanyID, comp_Name, comp_PRType, CityStateCountryShort 
                FROM Company WITH (NOLOCK) 
                     INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
               WHERE comp_PRHQID = @HQID
                 AND comp_PRListingStatus IN ('L', 'H', 'LUV')
             ORDER BY comp_PRType DESC,
                      comp_Name,
                      prst_State";

        private const string COMPANY = "BB# {0} {1}, {2}";
        protected void SetEnterprise()
        {
            if (IsPostBack)
            {
                return;
            }

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("HQID", _oUser.prwu_HQID));

            using (IDataReader oReader = GetDBAccess().ExecuteReader(SQL_ENTERPRISE, oParameters, CommandBehavior.CloseConnection, null))
            {
                while (oReader.Read())
                {
                    ddlCompanies.Items.Add(new ListItem(string.Format(COMPANY, oReader.GetInt32(0), oReader.GetString(1), oReader.GetString(3)), oReader.GetInt32(0).ToString()));
                }
            }

            if (ddlCompanies.Items.Count > 1)
            {
                pnlEnterprise.Visible = true;
                SetListDefaultValue(ddlCompanies, _oUser.prwu_BBID);
            }
        }

        protected void btnSelectOnClick(object sender, EventArgs e)
        {
            PopulateForm();
            ClearFields();
        }

        override protected int GetCompanyID()
        {
            if (!IsPostBack)
            {
                return _oUser.prwu_BBID;
            }

            if (!pnlEnterprise.Visible)
            {
                return _oUser.prwu_BBID;
            }

            return Convert.ToInt32(ddlCompanies.SelectedValue);
        }

        protected override bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.CompanyEditListingPage).HasPrivilege;
        }

        protected void repSocialMedia_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            HtmlAnchor popWhatIsSM = (HtmlAnchor)e.Item.FindControl("popWhatIsSM");
            popWhatIsSM.Attributes.Add("data-bs-title", Resources.Global.SocialMediaHelp);
        }

        protected void btnEditPersonnelList_Click(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.EMCW_EDIT_PERSONNEL);
        }
    }
}