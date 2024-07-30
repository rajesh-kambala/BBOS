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

 ClassName: SpecialServicesFileClaim
 Description: This class provides the interface for the user to enter 
              a Special Service Claim File.	This form stores information
              on the session during Company lookup and removes the 
              session variables during Cancel/Submit.

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Data;
using System.IO;
using System.Text;
using System.Threading;
using System.Web.UI;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    public partial class SpecialServicesFileClaim : SpecialServicesBase
    {
        private int _iAssignedToId = 0;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            // get any class level values
            _iAssignedToId = Utilities.GetIntConfigValue("SpecialServicesAssignedToUserID", 1003);

            // Set page title, sub-title
            SetPageTitle(Resources.Global.TradingAssistance, Resources.Global.FileClaim);

            // Setup page for file upload
            //AddDoubleClickPreventionJS(btnSubmit);
            EnableFormValidation();
            btnCancel.OnClientClick = "bEnableValidation=false;";
            btnAddRespondent.OnClientClick = "bEnableValidation=false;";
            Form.Attributes.Add("enctype", "multipart/form-data");

            cbIAgree2.Attributes.Add("onclick", "cbIAgree_Click();");
            Page.ClientScript.RegisterStartupScript(this.GetType(), "cbIAgree2", "var cbIAgree2=document.getElementById('" + cbIAgree2.ClientID + "');", true);

            cbIAgree3.Attributes.Add("onclick", "cbIAgree_Click();");
            Page.ClientScript.RegisterStartupScript(this.GetType(), "cbIAgree3", "var cbIAgree3=document.getElementById('" + cbIAgree3.ClientID + "');", true);

            cbIAgree4.Attributes.Add("onclick", "cbIAgree_Click();");
            Page.ClientScript.RegisterStartupScript(this.GetType(), "cbIAgree4", "var cbIAgree4=document.getElementById('" + cbIAgree4.ClientID + "');", true);

            // disable the Submit button until the I Agree checkbox is clicked
            PostBackURL.Value = ClientScript.GetPostBackEventReference(btnSubmit, "OnClick");
            btnSubmit.Enabled = false;

            // using the above statement causes the href prop to never be rendered to the screen;  therefore we'll use the syntax below
            //Page.ClientScript.RegisterStartupScript(this.GetType(), "btnSubmit", btnSubmit.ClientID + ".disabled=true;", true);

            litClaimAuthForm.Text = string.Format(Resources.Global.DownloadClaimAuthForm, Utilities.GetConfigValue("SpecialServicesClaimAuthorizationForm"));

            lblThankYouMsg.Text = Resources.Global.SaveMsgSpecialServicesClaim;
            TESLongForm.WebUser = _oUser;
            TESLongForm.SubjectIndustryType = _oUser.prwu_IndustryType;
            TESLongForm.SetModalTargetControl(btnSubmitTES);

            if (!IsPostBack)
            {
                PopulateForm();
            }
            else
            {
                if (FileUpload1.PostedFile != null)
                {
                    //Automatically invoke the btnAttachFile button
                    btnAttach_Click(sender, e);
                }
            }
        }

        /// <summary>
        /// Populates the form.
        /// </summary>
        protected void PopulateForm()
        {
            lblClaimantCompanyName.Text = getCompanyName(_oUser.prwu_HQID.ToString());
            // Populate form values from session if session variables exist
            if (Session["prss_IssueDescription"] != null)
                txtIssueQuestion.Text = (string)Session["prss_IssueDescription"];
            if (Session["prss_InitialAmountOwed"] != null)
                txtInitialAmountOwed.Text = (string)Session["prss_InitialAmountOwed"];

            if (Session["RespondentCompanyID"] != null)
            {
                hdnRespondentCompanyID.Value = (string)Session["RespondentCompanyID"];

                if (hdnRespondentCompanyID.Value == "-1")
                {
                    lblRespondentCompanyName.Text = ((CompanySubmission)Session["SelectCompanyManualCompany"]).CompanyName;
                    btnSubmitTES.Enabled = false;
                }
                else
                {
                    lblRespondentCompanyName.Text = getCompanyName((string)Session["RespondentCompanyID"]);
                }
            }

            using (IDataReader oReader = GetDBAccess().ExecuteReader(String.Format(SQL_GET_COMPANY_CONTACTINFO2, _oUser.prwu_BBID, _oUser.peli_PersonID), CommandBehavior.CloseConnection))
            {
                if (oReader.Read())
                {
                    if (oReader[0] != null)
                        txtStreet1.Text = oReader[0].ToString();
                    if (oReader[1] != null)
                        txtStreet2.Text = oReader[1].ToString();
                    if (oReader[2] != null)
                        txtStreet3.Text = oReader[2].ToString();
                    if (oReader[3] != null)
                        txtCity.Text = oReader[3].ToString();
                    if (oReader[4] != null)
                        cddState.ContextKey = oReader[4].ToString();
                    if (oReader[5] != null)
                        cddCountry.ContextKey = oReader[5].ToString();
                    if (oReader[6] != null)
                        txtPostalCode.Text = oReader[6].ToString();
                    if (oReader[7] != null)
                        txtPhoneNumber.Text = oReader[7].ToString();
                    if (oReader[8] != null)
                        txtFaxNumber.Text = oReader[8].ToString();
                }
                else
                {
                    cddCountry.ContextKey = _oUser.prwu_CountryID.ToString();
                    cddState.ContextKey = _oUser.prwu_StateID.ToString();
                }
            }

            txtEmail.Text = _oUser.Email;

            if (_oUser.prwu_Culture == SPANISH_CULTURE)
            {
                btnAuthParagraphToggle.Text = Resources.Global.btnAuthParagraph_InEnglish; // "En Inglés";
                hidAuthParagraphLanguage.Value = SPANISH_CULTURE;
            }
            else
            {
                btnAuthParagraphToggle.Text = Resources.Global.btnAuthParagraph_InSpanish; // "En Español";
                hidAuthParagraphLanguage.Value = ENGLISH_CULTURE;
            }
        }

        /// <summary>
        /// All users can view this data.
        /// </summary>
        /// <returns></returns>
        protected override bool IsAuthorizedForData()
        {
            return true;
        }

        /// <summary>
        /// Returns the user to the specified ReturnURL
        /// parameter.  If not specified, then the user is returned
        /// to the special services listing.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnCancelOnClick(object sender, EventArgs e)
        {
            // remove any session variables this form created
            removeFormValuesOnSession();

            foreach (ListItem listItem in lbAttachedFiles.Items)
            {
                string fileName = listItem.Value;
                deleteAttachedFile(fileName);
                Session.Remove("specialServiceAddlFile_" + fileName);
            }

            Response.Redirect(GetReturnURL(PageConstants.SPECIAL_SERVICES));
        }

        protected const string SQL_INSERT_PRSSFILE_CLAIM =
            @"INSERT INTO PRSSFile 
            (prss_CreatedBy, prss_CreatedDate, prss_UpdatedBy, prss_UpdatedDate, prss_TimeStamp, prss_IssueDescription, prss_ClaimantCompanyId, prss_RespondentCompanyId, 
             prss_AssignedUserId, prss_InitialAmountOwed, prss_NumberOfInvoices, prss_Type, prss_Status, prss_SSFileId, 
             prss_ChannelId, prss_InitialAmountOwed_CID, prss_AmountStillOwing_CID, prss_AmountPRCoCollected_CID, prss_AmountPRCoInvoiced_CID, prss_PRCoAssistanceFeePct, 
             prss_ClaimAuthRcvdDate, prss_Publish) 
            VALUES ({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}, {15}, {15}, {15}, {15}, {16}, {17}, 'Y' )";

        // prss_AssignedUserId, prss_InitialAmountOwed, prss_NumberOfInvoices, prss_OldestInvoiceDate, prss_PACADeadlineDate, prss_Type, prss_Status, prss_SSFileId, 
        //"({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}, {15}, {16}, {17}, {17}, {17}, {17}, {18}, {19}, 'Y' )";

        protected void btnSubmitOnClick(object sender, EventArgs e)
        {
            if (!TotalAmountOwingCheck())
                return;

            StringBuilder sbDescription = new StringBuilder();
            sbDescription.Append(txtIssueQuestion.Text);

            if (sbDescription.Length > 0)
            {
                sbDescription.Append(Environment.NewLine);
                sbDescription.Append(Environment.NewLine);
            }

            if (!string.IsNullOrEmpty(txtRespondentContactName.Text))
            {
                sbDescription.Append("Respondent Contact Name: ");
                sbDescription.Append(txtRespondentContactName.Text);
                sbDescription.Append(Environment.NewLine);
            }

            if (cbSpanish.Checked)
            {
                sbDescription.Append("Prefer a Spanish speaking representative.");
                sbDescription.Append(Environment.NewLine);
            }

            //if (!string.IsNullOrEmpty(txtTradeShowCode.Text))
            //{
            //    sbDescription.Append("Trade Show Code: ");
            //    sbDescription.Append(txtTradeShowCode.Text);
            //    sbDescription.Append(Environment.NewLine);
            //}

            IDbTransaction oTran = GetObjectMgr().BeginTransaction();
            try
            {
                // Create the PRSSFile record
                ArrayList oParameters = new ArrayList();

                oParameters.Add(new ObjectParameter("prss_CreatedBy", _oUser.prwu_WebUserID));
                oParameters.Add(new ObjectParameter("prss_CreatedDate", DateTime.Now));
                oParameters.Add(new ObjectParameter("prss_UpdatedBy", _oUser.prwu_WebUserID));
                oParameters.Add(new ObjectParameter("prss_UpdatedDate", DateTime.Now));
                oParameters.Add(new ObjectParameter("prss_TimeStamp", DateTime.Now));

                oParameters.Add(new ObjectParameter("prss_IssueDescription", sbDescription.ToString()));
                oParameters.Add(new ObjectParameter("prss_ClaimantCompanyId", _oUser.prwu_BBID));
                oParameters.Add(new ObjectParameter("prss_RespondentCompanyId", hdnRespondentCompanyID.Value));
                oParameters.Add(new ObjectParameter("prss_AssignedUserId", _iAssignedToId));

                if (string.IsNullOrEmpty(txtInitialAmountOwed.Text))
                {
                    oParameters.Add(new ObjectParameter("prss_InitialAmountOwed", null));
                }
                else
                {
                    oParameters.Add(new ObjectParameter("prss_InitialAmountOwed", Convert.ToDecimal(txtInitialAmountOwed.Text)));
                }

                oParameters.Add(new ObjectParameter("prss_NumberOfInvoices", null));

                oParameters.Add(new ObjectParameter("prss_Type", "C"));
                oParameters.Add(new ObjectParameter("prss_Status", "P"));

                int iSSFileId = GetObjectMgr().GetRecordID("PRSSFile", oTran);
                oParameters.Add(new ObjectParameter("prss_SSFileId", iSSFileId));

                oParameters.Add(new ObjectParameter("prss_ChannelId", Utilities.GetIntConfigValue("SpecialServicesChannelID", 8)));

                oParameters.Add(new ObjectParameter("CID", 1));
                oParameters.Add(new ObjectParameter("prss_PRCoAssistanceFeePct ", Utilities.GetIntConfigValue("SpecialServicesAssistanceFeePct", 12)));
                oParameters.Add(new ObjectParameter("prss_ClaimAuthRcvdDate", DateTime.Now));

                string szSQL = GetObjectMgr().FormatSQL(SQL_INSERT_PRSSFILE_CLAIM, oParameters);
                GetObjectMgr().ExecuteInsert("PRSSFile", szSQL, oParameters, oTran);

                // Add the PRSSContact record
                insertSSContact(iSSFileId,
                                txtStreet1.Text,
                                txtStreet2.Text,
                                txtStreet3.Text,
                                txtCity.Text,
                                ddlState.Items[ddlState.SelectedIndex].Text,
                                txtPostalCode.Text,
                                txtPhoneNumber.Text,
                                txtFaxNumber.Text,
                                txtEmail.Text,
                                oTran);

                foreach (ListItem listItem in lbAttachedFiles.Items)
                {
                    string fileName = listItem.Value;

                    string tmpName = (string)Session["specialServiceAddlFile_" + fileName];
                    string szSourceFileName = Path.Combine(Utilities.GetConfigValue("FileUploadTempLocation", @"C:\Temp\FileUpload"), tmpName);

                    simulateSageFileUpload(iSSFileId.ToString(), szSourceFileName, fileName, _iAssignedToId, oTran);
                }

                string emailTo = Utilities.GetConfigValue("SpecialServicesClaimsEmail", "claims@bluebookservices.com");
                NotifyUser(iSSFileId, _iAssignedToId, emailTo, "BBOS - File Claim", oTran);
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

            NotifyContact(txtEmail.Text, Thread.CurrentThread.CurrentUICulture.Name.ToLower());

            pnlFileClaim.Visible = false;
            pnlThankYou.Visible = true;

            TESLongForm.SubjectCompanyID = hdnRespondentCompanyID.Value;

            // remove any session variables this form created
            removeFormValuesOnSession();
        }

        protected bool TotalAmountOwingCheck()
        {
            double dblInitialAmountOwed = 0.0;
            double.TryParse(txtInitialAmountOwed.Text, out dblInitialAmountOwed);

            int intThreshold = Utilities.GetIntConfigValue("TotalAmountOwingThreshold", 300);

            if (dblInitialAmountOwed < intThreshold)
            {
                AddUserMessage(string.Format(Resources.Global.TotalAmountOwingThresholdTooLow, intThreshold));
                return false;
            }

            return true;
        }

        protected void btnAddRespondentClick(object sender, EventArgs e)
        {
            // Store the form values on the session and go to the company select page
            storeFormValuesOnSession();
            Response.Redirect(PageConstants.SELECT_COMPANY + "?ReturnURL=" + PageConstants.SPECIAL_SERVICES_FILE_CLAIM + "&CompanyIDSessionName=RespondentCompanyID");
        }

        private void storeFormValuesOnSession()
        {
            // store all values from the form on the session
            Session["prss_IssueDescription"] = txtIssueQuestion.Text;
            Session["prss_InitialAmountOwed"] = txtInitialAmountOwed.Text;
            //Session["prss_OldestInvoiceDate"] = txtOldestInvoiceDate.Text;
        }

        private void removeFormValuesOnSession()
        {
            // remove all values from the form on the session
            Session.Remove("prss_IssueDescription");
            Session.Remove("prss_InitialAmountOwed");
            //Session.Remove("prss_OldestInvoiceDate");
            Session.Remove("SelectCompanyManualCompany");
            Session.Remove("RespondentCompanyID");
        }

        public override bool EnableJSClientIDTranslation()
        {
            return true;
        }

        protected void btnAttach_Click(object sender, System.EventArgs e)
        {
            // Some exceptions have been lodgged with this being NULL.
            // I'm not sure why, but let's add a check for now.
            if (FileUpload1 == null)
                return;

            if (FileUpload1.PostedFile == null)
                return;

            // Save the attached file to fileName variable
            string fileName = FileUpload1.PostedFile.FileName;

            // Check if a file is selected
            if (string.IsNullOrEmpty(fileName))
                return;

           
            int iNameIndex = fileName.LastIndexOf("\\");
            if (iNameIndex > -1)
                fileName = fileName.Substring(iNameIndex + 1);

            // Add it to the collection
            lbAttachedFiles.Items.Add(fileName);
            lbAttachedFiles.Rows = lbAttachedFiles.Items.Count + 1;

            string tmpName = Guid.NewGuid().ToString("N") + ".bin";
            Session["specialServiceAddlFile_" + fileName] = tmpName;

            string szFullFileName = Path.Combine(Utilities.GetConfigValue("FileUploadTempLocation", @"C:\Temp\FileUpload"), tmpName);
            FileUpload1.SaveAs(szFullFileName);
        }

        protected void btnRemove_Click(object sender, System.EventArgs e)
        {
            if (lbAttachedFiles.SelectedIndex > -1)
            {
                string fileName = lbAttachedFiles.SelectedValue;
                deleteAttachedFile(fileName);
                lbAttachedFiles.Items.Remove(lbAttachedFiles.SelectedValue);
                lbAttachedFiles.Rows = lbAttachedFiles.Items.Count + 1;
            }
        }

        protected void deleteAttachedFile(string fileName)
        {
            string tmpName = (string)Session["specialServiceAddlFile_" + fileName];
            string szFullFileName = Path.Combine(Utilities.GetConfigValue("FileUploadTempLocation", @"C:\Temp\FileUpload"), tmpName);
            File.Delete(szFullFileName);
        }

        protected void AppendDescription(StringBuilder sbDescription, bool bAppend, string szText)
        {
            if (bAppend)
            {
                if (sbDescription.Length > 0)
                {
                    sbDescription.Append(", ");
                }

                sbDescription.Append(szText);
            }
        }

        protected void btnFileClaimClick(object sender, System.EventArgs e)
        {
            Response.Redirect(PageConstants.SPECIAL_SERVICES_FILE_CLAIM);
        }

        protected void btnDoneClick(object sender, System.EventArgs e)
        {
            Response.Redirect(PageConstants.SPECIAL_SERVICES);
        }

        protected void btnAuthParagraphToggle_Click(object sender, EventArgs e)
        {
            //Switch paragraph between English and Spanish
            if (hidAuthParagraphLanguage.Value == SPANISH_CULTURE)
            {
                hidAuthParagraphLanguage.Value = ENGLISH_CULTURE;
                lblSSFileAuthorizationAgreementMsg.Text = Resources.Global.SSFileAuthorizationAgreementMsg_English;
                btnAuthParagraphToggle.Text = Resources.Global.btnAuthParagraph_InSpanish;
            }
            else
            {
                hidAuthParagraphLanguage.Value = SPANISH_CULTURE;
                lblSSFileAuthorizationAgreementMsg.Text = Resources.Global.SSFileAuthorizationAgreementMsg_Spanish;
                btnAuthParagraphToggle.Text = Resources.Global.btnAuthParagraph_InEnglish;
            }
        }
    }
}
