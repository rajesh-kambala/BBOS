/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2018-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: EMCW_EditPersonnel
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using PRCo.EBB.Util;
using TSI.BusinessObjects;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

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
    public partial class EMCW_EditPersonnel : EMCWizardBase
    {
        private const string REF_DATA_EXIT_REASON = "peli_PRExitReason";
        private const string REF_DATA_TYPE_PERSON = "phon_TypePerson";

        protected const string SQL_GET_LISTING = "SELECT dbo.ufn_GetListingCache({0}, {1})";

        protected const string SQL_GET_LICENSE_INFO_2 = @"SELECT prod_code, prod_PRWebAccessLevel, cast(capt_US AS varchar(100)) AS WebAccessDescription, CAST(ISNULL(SUM(QuantityOrdered), 0) as int) As OrderedCount, ISNULL(AssignedCount, 0) As AssignedCount, prod_productfamilyid 
                                                         FROM NewProduct WITH (NOLOCK) 
                                                              INNER JOIN custom_captions WITH (NOLOCK) ON capt_family = 'prwu_AccessLevel' and capt_Code = prod_PRWebAccessLevel  
                                                              LEFT OUTER JOIN PRService ON prod_code = prse_ServiceCode AND prse_HQID = @CompanyID
                                                              LEFT OUTER JOIN (SELECT prwu_HQID, prwu_ServiceCode, COUNT(1) As AssignedCount 
						                                                         FROM PRWebUser WITH (NOLOCK) 
						                                                        WHERE prwu_ServiceCode IS NOT NULL
						                                                       GROUP BY prwu_HQID, prwu_ServiceCode) T1 ON prod_code = prwu_ServiceCode and prwu_HQID = @CompanyID
                                                        WHERE prod_productfamilyid IN (6,14) 
                                                          AND prod_IndustryTypeCode LIKE '%' + @IndustryType + '%'
                                                     GROUP BY prod_code, prod_PRWebAccessLevel, cast(capt_US AS varchar(100)), AssignedCount, prod_PRSequence, prod_productfamilyid 
                                                       ORDER BY prod_PRSequence";

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

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", _oUser.prwu_BBID));
            oParameters.Add(new ObjectParameter("IndustryType", _oUser.prwu_IndustryType));

            using (IDataReader oReader = GetDBAccess().ExecuteReader(SQL_GET_LICENSE_INFO_2, oParameters, CommandBehavior.CloseConnection, null))
            {
                int iLicensesUsed = 0;
                int iLicensesAvailable = 0;
                
                while (oReader.Read())
                {
                    iLicensesUsed += oReader.GetInt32(4);
                    iLicensesAvailable += oReader.GetInt32(3);
                }

                int iLicensesLeftToAssign = iLicensesAvailable - iLicensesUsed;
                litLicenseInfo.Text = string.Format(Resources.Global.PersonnelLicenseMessage, iLicensesAvailable);
            }

            SetPopover();

            EnableFormValidation();

            if (!IsPostBack)
            {
                LoadLookupValues();
                PopulateForm();
            }

            //Set user controls
            ucCompanyListing.WebUser = _oUser;
            ucCompanyListing.companyID = iCompanyID.ToString();
        }

        protected void LoadLookupValues()
        {
        }

        protected void SetPopover()
        {
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

            PopulatePersonnel(iCompanyID);

            BindLookupValues(ddlPhoneType1, GetReferenceData(REF_DATA_TYPE_PERSON));
            ddlPhoneType1.Items.Insert(0, new ListItem(string.Empty, string.Empty));
            BindLookupValues(ddlPhoneType2, GetReferenceData(REF_DATA_TYPE_PERSON));
            ddlPhoneType2.Items.Insert(0, new ListItem(string.Empty, string.Empty));
            BindLookupValues(ddlPhoneType3, GetReferenceData(REF_DATA_TYPE_PERSON));
            ddlPhoneType3.Items.Insert(0, new ListItem(string.Empty, string.Empty));

            SetEnterprise();
        }

        private void ClearFields()
        {
            txtFormattedName1.Text = "";
            txtTitle1.Text = "";
            txtEmail1.Text = "";
            txtDateStarted1.Text = "";
            txtPrevEmployer1.Text = "";
            txtPhone1.Text = "";
            ddlPhoneType1.SelectedValue = "";
            rblAddToListing1.ClearSelection();
            txtAdditionalChangeInstructions1.Text = "";
            cbAssignBBOSLicense1.Checked = false;

            txtFormattedName2.Text = "";
            txtTitle2.Text = "";
            txtEmail2.Text = "";
            txtDateStarted2.Text = "";
            txtPrevEmployer2.Text = "";
            txtPhone2.Text = "";
            ddlPhoneType2.SelectedValue = "";
            rblAddToListing2.ClearSelection();
            txtAdditionalChangeInstructions2.Text = "";
            cbAssignBBOSLicense2.Checked = false;

            txtFormattedName3.Text = "";
            txtTitle3.Text = "";
            txtEmail3.Text = "";
            txtDateStarted3.Text = "";
            txtPrevEmployer3.Text = "";
            txtPhone3.Text = "";
            ddlPhoneType3.SelectedValue = "";
            rblAddToListing3.ClearSelection();
            txtAdditionalChangeInstructions3.Text = "";
            cbAssignBBOSLicense3.Checked = false;
        }

        //Pulled from ListingReportLetterSub.rdl query
        protected const string SQL_PERSONNEL =
            @"SELECT DISTINCT v.*, phon_FullNumber[PhoneNumber], plink_Type[PhoneType]
               FROM vLRLPerson v
                LEFT OUTER JOIN(SELECT* FROM (
                                    SELECT PLink_RecordID, phon_FullNumber, plink_Type, ROW_NUMBER() OVER (PARTITION BY PLink_RecordID ORDER BY CASE plink_Type WHEN 'P' THEN 1 WHEN 'C' THEN 2 ELSE 99 END) RowNum
                                     FROM vPRPersonPhone
                                    WHERE phon_CompanyID=@CompanyID
                                      AND phon_PRPreferredPublished='Y') T1
                               WHERE T1.RowNum=1) pp ON v.PersonID = pp.PLink_RecordID
           WHERE[BBID] = @CompanyID
            ORDER BY[Order]";

        protected void PopulatePersonnel(int companyID)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", companyID));

            repPersonnel.DataSource = GetDBAccess().ExecuteReader(SQL_PERSONNEL, oParameters, CommandBehavior.CloseConnection, null);
            repPersonnel.DataBind();
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
            // Determine what personnel the user has submitted a change request for 
            List<RepeaterItem> lstChangedPersonnel = new List<RepeaterItem>();

            foreach (RepeaterItem p in repPersonnel.Items)
            {
                bool blnChanged = false;

                TextBox txtFormattedName = (TextBox)p.FindControl("txtFormattedName");
                HiddenField hidFormattedName = (HiddenField)p.FindControl("hidFormattedName");
                if (txtFormattedName.Text != hidFormattedName.Value) blnChanged = true;

                TextBox txtTitle = (TextBox)p.FindControl("txtTitle");
                HiddenField hidTitle = (HiddenField)p.FindControl("hidTitle");
                if (txtTitle.Text != hidTitle.Value) blnChanged = true;

                TextBox txtEmail = (TextBox)p.FindControl("txtEmail");
                HiddenField hidEmail = (HiddenField)p.FindControl("hidEmail");
                if (txtEmail.Text != hidEmail.Value) blnChanged = true;

                TextBox txtOwnershipPct = (TextBox)p.FindControl("txtOwnershipPct");
                HiddenField hidOwnershipPct = (HiddenField)p.FindControl("hidOwnershipPct");
                if (txtOwnershipPct.Text != hidOwnershipPct.Value) blnChanged = true;

                CheckBox cbHasBBOSLicense = (CheckBox)p.FindControl("cbHasBBOSLicense");
                HiddenField hidHasBBOSLicense = (HiddenField)p.FindControl("hidHasBBOSLicense");
                if (cbHasBBOSLicense.Checked.ToString() != hidHasBBOSLicense.Value) blnChanged = true;

                TextBox txtDateLeft = (TextBox)p.FindControl("txtDateLeft");
                HiddenField hidDateLeft = (HiddenField)p.FindControl("hidDateLeft");
                if (txtDateLeft.Text != hidDateLeft.Value) blnChanged = true;

                TextBox txtCurrentlyEmployedAt = (TextBox)p.FindControl("txtCurrentlyEmployedAt");
                HiddenField hidCurrentlyEmployedAt = (HiddenField)p.FindControl("hidCurrentlyEmployedAt");
                if (txtCurrentlyEmployedAt.Text != hidCurrentlyEmployedAt.Value) blnChanged = true;

                DropDownList ddlReasonLeft = (DropDownList)p.FindControl("ddlReasonLeft");
                HiddenField hidReasonLeft = (HiddenField)p.FindControl("hidReasonLeft");
                if (ddlReasonLeft.SelectedValue != hidReasonLeft.Value) blnChanged = true;

                CheckBox cbNoLongerAtCompany = (CheckBox)p.FindControl("cbNoLongerAtCompany");
                HiddenField hidNoLongerAtCompany = (HiddenField)p.FindControl("hidNoLongerAtCompany");
                if (cbNoLongerAtCompany.Checked.ToString().ToLower() != hidNoLongerAtCompany.Value.ToLower()) blnChanged = true;

                TextBox txtPhone  = (TextBox)p.FindControl("txtPhone");
                HiddenField hidPhone = (HiddenField)p.FindControl("hidPhone");
                if (txtPhone.Text != hidPhone.Value) blnChanged = true;

                DropDownList ddlPhoneType = (DropDownList)p.FindControl("ddlPhoneType");
                HiddenField hidPhoneType = (HiddenField)p.FindControl("hidPhoneType");
                if (ddlPhoneType.SelectedValue != hidPhoneType.Value) blnChanged = true;

                TextBox txtAdditionalChangeInstructions = (TextBox)p.FindControl("txtAdditionalChangeInstructions");
                HiddenField hidAdditionalChangeInstructions = (HiddenField)p.FindControl("hidAdditionalChangeInstructions");
                if (txtAdditionalChangeInstructions.Text != hidAdditionalChangeInstructions.Value) blnChanged = true;

                if (blnChanged)
                    lstChangedPersonnel.Add(p);
            }

            List<string> lCategoryCodes = new List<string>();
            lCategoryCodes.Add(CODE_AUDIT_CATEGORY_PERSONNEL);

            int iAddedPersonCount = 0;
            string szMsg = "Customer submitting personnel changes:" + Environment.NewLine;
            szMsg += GetListingInfoForTask(lstChangedPersonnel, out iAddedPersonCount);

            if (lstChangedPersonnel.Count > 0 | iAddedPersonCount > 0)
            {
                IDbTransaction oTran = GetObjectMgr().BeginTransaction();
                try
                {
                    // If some of the data has changed, or personnel have been added
                    // Create user task noting changes
                    // Defect 6828 - send task and email to HQ specialist instead of company specialist
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

                    //Defect 6973 - emails via stored proc
                    GetObjectMgr().SendEmail_Text(GetObjectMgr().GetPRCoUserEmail(GetObjectMgr().GetPRCoSpecialistID(iHQCompanyID, GeneralDataMgr.PRCO_SPECIALIST_LISTING_SPECIALIST, oTran), oTran),
                            Utilities.GetConfigValue("MemberPersonnelChangeEmailSubject", "Customer submitted personnel changes"),
                            szMsg,
                            "EMCW_EditPersonnel.aspx",
                            oTran);

                    // Insert self service audit trail records
                    GetObjectMgr().InsertSelfServiceAuditTrail(lCategoryCodes, oTran);

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

                ClearFields();
            }
        }

        private bool HasInput(TextBox txtFormattedName, TextBox txtTitle, TextBox txtEmail, TextBox txtDateStarted, TextBox txtPrevEmployer, RadioButtonList rblAddToListing, CheckBox cbAssignBBOSLicense, TextBox txtPhone, DropDownList ddlPhoneType, TextBox txtAdditionalChangeInstructions)
        {
            bool blnChanged = false;

            if (txtFormattedName.Text.Length > 0) blnChanged = true;
            else if(txtTitle.Text.Length > 0) blnChanged = true;
            else if (txtEmail.Text.Length > 0) blnChanged = true;
            else if (txtDateStarted.Text.Length > 0) blnChanged = true;
            else if (txtPrevEmployer.Text.Length > 0) blnChanged = true;
            else if (rblAddToListing.SelectedValue != "No") blnChanged = true;
            else if (cbAssignBBOSLicense.Checked) blnChanged = true;
            else if (txtPhone.Text.Length > 0) blnChanged = true;
            else if (ddlPhoneType.SelectedValue != "") blnChanged = true;
            else if (txtAdditionalChangeInstructions.Text.Length > 0) blnChanged = true;

            return blnChanged;
        }

        /// <summary>
        /// Handles the cancel on click event.  Takes the user to the EMCW company listing page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnCancel_Click(object sender, EventArgs e)
        {
            // Takes the user to the EMCW Company Listing page
            Response.Redirect(PageConstants.EMCW_COMPANY_LISTING);
        }

        /// <summary>
        /// Helper method that formats the personnel data change requests for including
        /// in a BBS CRM task.
        /// </summary>
        /// <returns></returns>
        protected string GetListingInfoForTask(List<RepeaterItem> lstChangedPersonnel, out int iAddedPersonCount)
        {
            StringBuilder sbMsg = new StringBuilder();
            iAddedPersonCount = 0;

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

            //Changed personnel
            if (lstChangedPersonnel.Count > 0)
            {
                sbMsg.Append("CHANGED PERSONNEL" + Environment.NewLine);
                sbMsg.Append("-----------------" + Environment.NewLine);

                foreach (RepeaterItem p in lstChangedPersonnel)
                {
                    HiddenField hidFormattedName = (HiddenField)p.FindControl("hidFormattedName");
                    TextBox txtFormattedName = (TextBox)p.FindControl("txtFormattedName");

                    if(hidFormattedName.Value == txtFormattedName.Text)
                        sbMsg.Append("Name: " + txtFormattedName.Text + Environment.NewLine);
                    else
                        sbMsg.Append("Before Name: " + hidFormattedName.Value + "   After Name: " + txtFormattedName.Text + Environment.NewLine);

                    HiddenField hidTitle = (HiddenField)p.FindControl("hidTitle");
                    TextBox txtTitle = (TextBox)p.FindControl("txtTitle");
                    if (hidTitle.Value != txtTitle.Text)
                    {
                        sbMsg.Append("Before Title: " + hidTitle.Value + "   After Title: " + txtTitle.Text + Environment.NewLine);
                    }

                    HiddenField hidEmail = (HiddenField)p.FindControl("hidEmail");
                    TextBox txtEmail = (TextBox)p.FindControl("txtEmail");
                    if (hidEmail.Value != txtEmail.Text)
                    {
                        sbMsg.Append("Before Email: " + hidEmail.Value + "   After Email: " + txtEmail.Text + Environment.NewLine);
                    }

                    HiddenField hidOwnershipPct  = (HiddenField)p.FindControl("hidOwnershipPct");
                    TextBox txtOwnershipPct = (TextBox)p.FindControl("txtOwnershipPct");
                    if (hidOwnershipPct.Value != txtOwnershipPct.Text)
                    {
                        sbMsg.Append("Before Ownership Pct: " + hidOwnershipPct.Value + "   After Ownership Pct: " + txtOwnershipPct.Text + Environment.NewLine);
                    }

                    HiddenField hidHasBBOSLicense = (HiddenField)p.FindControl("hidHasBBOSLicense");
                    CheckBox cbHasBBOSLicense = (CheckBox)p.FindControl("cbHasBBOSLicense");
                    if (hidHasBBOSLicense.Value.ToLower() != cbHasBBOSLicense.Checked.ToString().ToLower())
                    {
                        sbMsg.Append("Before Online Access License: " + hidHasBBOSLicense.Value.ToLower() + "   After Online Access License: " + cbHasBBOSLicense.Checked.ToString().ToLower() + Environment.NewLine);
                    }

                    HiddenField hidNoLongerAtCompany = (HiddenField)p.FindControl("hidNoLongerAtCompany");
                    CheckBox cbNoLongerAtCompany = (CheckBox)p.FindControl("cbNoLongerAtCompany");
                    if (hidNoLongerAtCompany.Value.ToLower() != cbNoLongerAtCompany.Checked.ToString().ToLower())
                    {
                        sbMsg.Append("Before No Longer at Company: " + hidNoLongerAtCompany.Value.ToLower() + "   After No Longer at Company: " + cbNoLongerAtCompany.Checked.ToString().ToLower() + Environment.NewLine);
                    }

                    HiddenField hidDateLeft = (HiddenField)p.FindControl("hidDateLeft");
                    TextBox txtDateLeft = (TextBox)p.FindControl("txtDateLeft");
                    if (hidDateLeft.Value != txtDateLeft.Text)
                    {
                        sbMsg.Append("Before Date Left: " + hidDateLeft.Value + "   After Date Left: " + txtDateLeft.Text + Environment.NewLine);
                    }

                    HiddenField hidReasonLeft= (HiddenField)p.FindControl("hidReasonLeft");
                    DropDownList ddlReasonLeft = (DropDownList)p.FindControl("ddlReasonLeft");
                    if (hidReasonLeft.Value != ddlReasonLeft.SelectedValue)
                    {
                        sbMsg.Append("Before Reason Left: " + hidReasonLeft.Value + "   After Reason Left: " + ddlReasonLeft.SelectedItem.Text + Environment.NewLine);
                    }

                    HiddenField hidCurrentlyEmployedAt = (HiddenField)p.FindControl("hidCurrentlyEmployedAt");
                    TextBox txtCurrentlyEmployedAt = (TextBox)p.FindControl("txtCurrentlyEmployedAt");
                    if (hidCurrentlyEmployedAt.Value != txtCurrentlyEmployedAt.Text)
                    {
                        sbMsg.Append("Before Currently Employed At: " + hidCurrentlyEmployedAt.Value + "   After Currently Employed At: " + txtCurrentlyEmployedAt.Text + Environment.NewLine);
                    }

                    HiddenField hidPhone = (HiddenField)p.FindControl("hidPhone");
                    TextBox txtPhone = (TextBox)p.FindControl("txtPhone");
                    if (hidPhone.Value != txtPhone.Text)
                    {
                        sbMsg.Append("Before Phone Number: " + hidPhone.Value + "   After Phone Number: " + txtPhone.Text + Environment.NewLine);
                    }

                    HiddenField hidPhoneType = (HiddenField)p.FindControl("hidPhoneType");
                    DropDownList ddlPhoneType = (DropDownList)p.FindControl("ddlPhoneType");
                    if (hidPhoneType.Value != ddlPhoneType.SelectedValue)
                    {
                        sbMsg.Append("Before Phone Type: " + hidPhoneType.Value + "   After Phone Type: " + ddlPhoneType.SelectedItem.Text + Environment.NewLine);
                    }

                    HiddenField hidAdditionalChangeInstructions  = (HiddenField)p.FindControl("hidAdditionalChangeInstructions");
                    TextBox txtAdditionalChangeInstructions = (TextBox)p.FindControl("txtAdditionalChangeInstructions");
                    if (hidAdditionalChangeInstructions.Value != txtAdditionalChangeInstructions.Text)
                    {
                        sbMsg.Append("Before Additional Change Instructions: " + hidAdditionalChangeInstructions.Value + "   After Additional Change Instructions: " + txtAdditionalChangeInstructions.Text + Environment.NewLine);
                    }

                    sbMsg.Append(Environment.NewLine);
                }
            }

            sbMsg.Append("ADDED PERSONNEL" + Environment.NewLine);
            sbMsg.Append("---------------" + Environment.NewLine);

            //New personnel
            bool blnNewPersonnel = false;
            if (HasInput(txtFormattedName1, txtTitle1, txtEmail1, txtDateStarted1, txtPrevEmployer1, rblAddToListing1, cbAssignBBOSLicense1, txtPhone1, ddlPhoneType1, txtAdditionalChangeInstructions1))
            {
                sbMsg = AppendNewPerson(sbMsg, txtFormattedName1, txtTitle1, txtEmail1, txtDateStarted1, txtPrevEmployer1, rblAddToListing1, cbAssignBBOSLicense1, txtPhone1, ddlPhoneType1, txtAdditionalChangeInstructions1);
                blnNewPersonnel = true;
                iAddedPersonCount++;
            }
            if (HasInput(txtFormattedName2, txtTitle2, txtEmail2, txtDateStarted2, txtPrevEmployer2, rblAddToListing2, cbAssignBBOSLicense2, txtPhone2, ddlPhoneType2, txtAdditionalChangeInstructions2))
            {
                sbMsg = AppendNewPerson(sbMsg, txtFormattedName2, txtTitle2, txtEmail2, txtDateStarted2, txtPrevEmployer2, rblAddToListing2, cbAssignBBOSLicense2, txtPhone2, ddlPhoneType2, txtAdditionalChangeInstructions2);
                blnNewPersonnel = true;
                iAddedPersonCount++;
            }
            if (HasInput(txtFormattedName3, txtTitle3, txtEmail3, txtDateStarted3, txtPrevEmployer3, rblAddToListing3, cbAssignBBOSLicense3, txtPhone3, ddlPhoneType3, txtAdditionalChangeInstructions3))
            {
                sbMsg = AppendNewPerson(sbMsg, txtFormattedName3, txtTitle3, txtEmail3, txtDateStarted3, txtPrevEmployer3, rblAddToListing3, cbAssignBBOSLicense3, txtPhone3, ddlPhoneType3, txtAdditionalChangeInstructions3);
                blnNewPersonnel = true;
                iAddedPersonCount++;
            }

            if (!blnNewPersonnel)
                sbMsg.Append("NONE" + Environment.NewLine);

            return sbMsg.ToString();
        }

        private StringBuilder AppendNewPerson(StringBuilder sbMsg, TextBox txtFormattedName, TextBox txtTitle, TextBox txtEmail, TextBox txtDateStarted, TextBox txtPrevEmployer, RadioButtonList rblAddToListing, CheckBox cbAssignBBOSLicense, TextBox txtPhone, DropDownList ddlPhoneType, TextBox txtAdditionalChangeInstructions)
        {
            sbMsg.Append("Name: " + txtFormattedName.Text + Environment.NewLine);
            sbMsg.Append("Title: " + txtTitle.Text + Environment.NewLine);
            sbMsg.Append("Email: " + txtEmail.Text + Environment.NewLine);
            sbMsg.Append("Date Started: " + txtDateStarted.Text + Environment.NewLine);
            sbMsg.Append("Phone: " + txtPhone.Text + Environment.NewLine);
            sbMsg.Append("Phone Type: " + ddlPhoneType.SelectedItem.Text + Environment.NewLine);
            sbMsg.Append("Previous Employer: " + txtPrevEmployer.Text + Environment.NewLine);
            sbMsg.Append("Add To Listing: " + rblAddToListing.SelectedValue + Environment.NewLine);
            sbMsg.Append("Assign Online Access License: " + cbAssignBBOSLicense.Checked.ToString() + Environment.NewLine);
            sbMsg.Append("Additional Instructions: " + txtAdditionalChangeInstructions.Text + Environment.NewLine);
            sbMsg.Append(Environment.NewLine);

            return sbMsg;
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

        protected void btnManageCompanyListing_Click(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.EMCW_COMPANY_LISTING);
        }

        protected void repPersonnel_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item ||
                e.Item.ItemType == ListItemType.AlternatingItem)
            {
                int PersonID = (int)(DataBinder.Eval(e.Item.DataItem, "PersonID"));
                int BBID = (int)(DataBinder.Eval(e.Item.DataItem, "BBID"));
                string FormattedName = (DataBinder.Eval(e.Item.DataItem, "Formatted Name")).ToString();
                string FirstName = (DataBinder.Eval(e.Item.DataItem, "First Name")).ToString();
                string LastName = (DataBinder.Eval(e.Item.DataItem, "Last Name")).ToString();
                string Title = (DataBinder.Eval(e.Item.DataItem, "Title")).ToString();
                string StartDate = (DataBinder.Eval(e.Item.DataItem, "Start Date")).ToString();
                string EmailAddress = (DataBinder.Eval(e.Item.DataItem, "E-Mail Address")).ToString();
                string PubInBBOS = (DataBinder.Eval(e.Item.DataItem, "Pub in BBOS")).ToString();
                decimal peli_PRPctOwned = UIUtils.GetDecimal(DataBinder.Eval(e.Item.DataItem, "peli_PRPctOwned").ToString());
                int Order = UIUtils.GetInt(DataBinder.Eval(e.Item.DataItem, "Order").ToString());
                string HasLicense = (DataBinder.Eval(e.Item.DataItem, "HasLicense")).ToString();
                string PhoneNumber = (DataBinder.Eval(e.Item.DataItem, "PhoneNumber")).ToString();
                string PhoneType = (DataBinder.Eval(e.Item.DataItem, "PhoneType")).ToString();

                TextBox txtFormattedName = (TextBox)e.Item.FindControl("txtFormattedName");
                HiddenField hidFormattedName = (HiddenField)e.Item.FindControl("hidFormattedName");
                txtFormattedName.Text = FormattedName;
                hidFormattedName.Value = FormattedName;

                TextBox txtTitle = (TextBox)e.Item.FindControl("txtTitle");
                HiddenField hidTitle = (HiddenField)e.Item.FindControl("hidTitle");
                txtTitle.Text = Title;
                hidTitle.Value = Title;

                TextBox txtEmail = (TextBox)e.Item.FindControl("txtEmail");
                HiddenField hidEmail = (HiddenField)e.Item.FindControl("hidEmail");
                txtEmail.Text = EmailAddress;
                hidEmail.Value = EmailAddress;

                if (DataBinder.Eval(e.Item.DataItem, "peli_PRPctOwned") != DBNull.Value)
                {
                    TextBox txtOwnershipPct = (TextBox)e.Item.FindControl("txtOwnershipPct");
                    HiddenField hidOwnershipPct = (HiddenField)e.Item.FindControl("hidOwnershipPct");
                    txtOwnershipPct.Text = string.Format("{0:0.00}", peli_PRPctOwned);
                    hidOwnershipPct.Value = string.Format("{0:0.00}", peli_PRPctOwned);
                }

                CheckBox cbHasBBOSLicense = (CheckBox)e.Item.FindControl("cbHasBBOSLicense");
                HiddenField hidHasBBOSLicense = (HiddenField)e.Item.FindControl("hidHasBBOSLicense");
                cbHasBBOSLicense.Checked = (HasLicense == "Y") ? true : false;
                hidHasBBOSLicense.Value = cbHasBBOSLicense.Checked.ToString();

                DropDownList ddlReasonLeft = (DropDownList)e.Item.FindControl("ddlReasonLeft");
                HiddenField hidReasonLeft = (HiddenField)e.Item.FindControl("hidReasonLeft");
                BindLookupValues(ddlReasonLeft, GetReferenceData(REF_DATA_EXIT_REASON));
                ddlReasonLeft.Items.Insert(0, new ListItem(string.Empty, string.Empty));
                ddlReasonLeft.Text = "";
                hidReasonLeft.Value = "";

                TextBox txtPhone = (TextBox)e.Item.FindControl("txtPhone");
                HiddenField hidPhone = (HiddenField)e.Item.FindControl("hidPhone");
                txtPhone.Text = PhoneNumber;
                hidPhone.Value = PhoneNumber;

                DropDownList ddlPhoneType = (DropDownList)e.Item.FindControl("ddlPhoneType");
                BindLookupValues(ddlPhoneType, GetReferenceData(REF_DATA_TYPE_PERSON));
                ddlPhoneType.Items.Insert(0, new ListItem(string.Empty, string.Empty));

                HiddenField hidPhoneType = (HiddenField)e.Item.FindControl("hidPhoneType");
                ddlPhoneType.SelectedValue = PhoneType;
                hidPhoneType.Value = PhoneType;

                HiddenField hidNoLongerAtCompany = (HiddenField)e.Item.FindControl("hidNoLongerAtCompany");
                hidNoLongerAtCompany.Value = "false";
            }
        }
    }
}
