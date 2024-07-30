/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2023

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: SpecialServicesCourtesyContact
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
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Collections.Generic;

namespace PRCo.BBOS.UI.Web
{
    public partial class SpecialServicesCourtesyContact : SpecialServicesBase
    {
        private int _iAssignedToId = 0;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            // get any class level values
            _iAssignedToId = Utilities.GetIntConfigValue("SpecialServicesAssignedToUserID", 1003);

            // Set page title, sub-title
            SetPageTitle(Resources.Global.TradingAssistance, Resources.Global.CourtesyContact);

            // Setup page for file upload
            AddDoubleClickPreventionJS(btnSubmit);
            EnableFormValidation();
            btnCancel.OnClientClick = "bEnableValidation=false;";
            btnAddRespondent.OnClientClick = "bEnableValidation=false;";
            Form.Attributes.Add("enctype", "multipart/form-data");

            // using the above statement causes the href prop to never be rendered to the screen;  therefore we'll use the syntax below
            //Page.ClientScript.RegisterStartupScript(this.GetType(), "btnSubmit", btnSubmit.ClientID + ".disabled=true;", true);

            litCourtestyContactForm.Text = Resources.Global.CourtesyContactFormHeader;

            if (!IsPostBack)
            {
                txtInvoiceDate.Attributes.Add("placeholder", PageControlBaseCommon.GetCultureInfo_ShortDatePattern().ToUpper());
                PopulateForm();
            }
            else
            {
                if(FileUpload1.PostedFile != null)
                {
                    //Automatically invoke the btnAttachFile button
                    btnAttach_Click(sender, e);
                }
            }
        }

        protected string InvoicesJSON
        {
            get 
            {
                if (string.IsNullOrEmpty(hidInvoices.Value))
                    hidInvoices.Value = "[]";
                return hidInvoices.Value; 
            }
            set { hidInvoices.Value = value; }
        }
        protected List<CourtesyContactInvoice> Invoices
        {
            get
            {
                return JsonConvert.DeserializeObject<List<CourtesyContactInvoice>>(InvoicesJSON);
            }
        }

        /// <summary>
        /// Populates the form.
        /// </summary>
        protected void PopulateForm()
        {
            hidClaimantCompanyName.Value = getCompanyNameShort(_oUser.prwu_HQID.ToString());
            hidCulture.Value = Thread.CurrentThread.CurrentCulture.Name.ToLower();

            // Populate form values from session if session variables exist
            if (Session["RespondentCompanyID"] != null)
            {
                hdnRespondentCompanyID.Value = (string)Session["RespondentCompanyID"];

                if (hdnRespondentCompanyID.Value == "-1")
                {
                    lblRespondentCompanyName.Text = ((CompanySubmission)Session["SelectCompanyManualCompany"]).CompanyName;
                    hidShortCompanyName.Value = lblRespondentCompanyName.Text;
                }
                else
                {
                    lblRespondentCompanyName.Text = getCompanyName((string)Session["RespondentCompanyID"]);
                    hidShortCompanyName.Value = getCompanyNameShort((string)Session["RespondentCompanyID"]);
                }
            }

            using (StreamReader srEmail = new StreamReader(Server.MapPath(UIUtils.GetTemplateURL("SpecialServicesCourtesyContactNotification_Top.htm"))))
            {
                hidPreviewTemplate.Value = srEmail.ReadToEnd();
            }

            using (StreamReader srEmail = new StreamReader(Server.MapPath(UIUtils.GetTemplateURL("SpecialServicesCourtesyContactNotification_Bottom.htm"))))
            {
                divBottom.InnerHtml = srEmail.ReadToEnd();
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

        protected const string SQL_INSERT_PRSSFILE_COURTESY_CONTACT =
        @"INSERT INTO PRSSFile 
	        (prss_CreatedBy, prss_CreatedDate, prss_UpdatedBy, prss_UpdatedDate, prss_TimeStamp, prss_IssueDescription, prss_ClaimantCompanyId, prss_RespondentCompanyId, 
            prss_AssignedUserId, prss_NumberOfInvoices, prss_Type, prss_Status, prss_SSFileId, 
            prss_ChannelId, prss_Publish) 
            VALUES ({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, 'Y' )";

        protected void btnSubmitOnClick(object sender, EventArgs e)
        {
            if(Invoices.Count == 0)
            {
                AddUserMessage("You must add at least one invoice.");
                return;
            }

            StringBuilder sbDescription = new StringBuilder();
            if (!string.IsNullOrEmpty(txtContactName.Text))
            {
                sbDescription.Append("Contact Name: ");
                sbDescription.Append(txtContactName.Text);
                sbDescription.Append(Environment.NewLine);
            }

            if (!string.IsNullOrEmpty(txtContactEmail.Text))
            {
                sbDescription.Append("Contact Email: ");
                sbDescription.Append(txtContactEmail.Text);
                sbDescription.Append(Environment.NewLine);
            }

            foreach(CourtesyContactInvoice invoice in Invoices)
            {
                if (invoice == null)
                    continue;
                sbDescription.Append("Invoice: ");
                sbDescription.Append($"{invoice.invoicenum}; {invoice.invoicedate.ToShortDateString()}; ${invoice.amount}");
                sbDescription.Append(Environment.NewLine);
            }

            int iSSFileId;
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

                oParameters.Add(new ObjectParameter("prss_NumberOfInvoices", Invoices.Count));

                oParameters.Add(new ObjectParameter("prss_Type", "CC"));
                oParameters.Add(new ObjectParameter("prss_Status", "P"));

                iSSFileId = GetObjectMgr().GetRecordID("PRSSFile", oTran);
                oParameters.Add(new ObjectParameter("prss_SSFileId", iSSFileId));

                oParameters.Add(new ObjectParameter("prss_ChannelId", Utilities.GetIntConfigValue("SpecialServicesChannelID", 8)));

                string szSQL = GetObjectMgr().FormatSQL(SQL_INSERT_PRSSFILE_COURTESY_CONTACT, oParameters);
                GetObjectMgr().ExecuteInsert("PRSSFile", szSQL, oParameters, oTran);

                // Add the PRSSContact record
                insertSSContact(iSSFileId,
                                "",
                                "",
                                "",
                                "",
                                "",
                                "",
                                "",
                                "",
                                txtContactEmail.Text,
                                oTran);

                foreach (ListItem listItem in lbAttachedFiles.Items)
                {
                    string fileName = listItem.Value;

                    string tmpName = (string)Session["specialServiceAddlFile_" + fileName];
                    string szSourceFileName = Path.Combine(Utilities.GetConfigValue("FileUploadTempLocation", @"C:\Temp\FileUpload"), tmpName);

                    simulateSageFileUpload(iSSFileId.ToString(), szSourceFileName, fileName, _iAssignedToId, oTran);
                }

                string emailTo = Utilities.GetConfigValue("SpecialServicesTradingAssistEmail", "tradingassist@bluebookservices.com");
                NotifyUser(iSSFileId, _iAssignedToId, emailTo, "BBOS - Courtesy Contact", oTran);

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

            //Send email and create comm records             
            NotifyCourtesyContactAllParties(hidClaimantCompanyName.Value, txtContactName.Text, txtContactEmail.Text, Invoices, Thread.CurrentThread.CurrentUICulture.Name.ToLower());
            createEmailCommunicationRecord(iSSFileId.ToString(), "BBOS - Courtesy Contact Emails Sent (All)", "Courtesy Contact on Past Due Invoice(s) Email sent to all parties regarding Courtesy Contact below.\r\n\r\n" + sbDescription.ToString(), _iAssignedToId, oTran);

            NotifyCourtesyContactPreClaimant(hidShortCompanyName.Value, Thread.CurrentThread.CurrentUICulture.Name.ToLower());
            createEmailCommunicationRecord(iSSFileId.ToString(), "BBOS - Courtesy Contact Email Sent (Pre-Claimant)",  $"Courtesy Contact confirmation email sent to pre-claimant {_oUser.Email} regarding Courtesy Contact below.\r\n\r\n" + sbDescription.ToString(), _iAssignedToId, oTran);

            pnlCourtesyContact.Visible = false;
            pnlThankYou.Visible = true;
            litThankYouMsg.Text = string.Format(Resources.Global.SpecialServicesCourtesyContactSubmitted, hidShortCompanyName.Value);

            // remove any session variables this form created
            removeFormValuesOnSession();
        }

        protected void btnAddRespondentClick(object sender, EventArgs e)
        {
            // Store the form values on the session and go to the company select page
            storeFormValuesOnSession();
            Response.Redirect(PageConstants.SELECT_COMPANY + "?ReturnURL=" + PageConstants.SPECIAL_SERVICES_COURTESY_CONTACT + "&CompanyIDSessionName=RespondentCompanyID");
        }

        private void storeFormValuesOnSession()
        {
            // store all values from the form on the session
            //Session["prss_IssueDescription"] = txtIssueQuestion.Text;
            //Session["prss_InitialAmountOwed"] = txtInitialAmountOwed.Text;
            //Session["prss_OldestInvoiceDate"] = txtOldestInvoiceDate.Text;
        }

        private void removeFormValuesOnSession()
        {
            // remove all values from the form on the session
            //Session.Remove("prss_OldestInvoiceDate");
            Session.Remove("RespondentCompanyID");
        }

        public override bool EnableJSClientIDTranslation()
        {
            return true;
        }

        protected void btnAttach_Click(object sender, System.EventArgs e)
        {
            ClientScript.RegisterStartupScript(this.GetType(), "refresh", "refresh();", true);

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

        protected void btnRemoveFile_Click(object sender, System.EventArgs e)
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

        protected void btnAddInvoice_Click(object sender, EventArgs e)
        {
            // Check if an invoice
            if (string.IsNullOrEmpty(txtInvoiceNumber.Text)
                || string.IsNullOrEmpty(txtInvoiceDate.Text)
                || string.IsNullOrEmpty(txtInvoiceAmount.Text))
            {
                return;
            }

            DateTime dtInvoiceDate = DateTime.Parse(txtInvoiceDate.Text);
            if ((DateTime.Now - dtInvoiceDate).TotalDays < 30)
            {
                string szMessageDefault = @"<p>Please note, Courtesy Contacts are only available for invoices that are 30 days (or more) past-due.</p><br/><p>Please contact our Trading Assistance team with any questions at <a href=""mailto:tradingassist@bluebookservices.com"" style=""color:blue"">tradingassist@bluebookservices.com</a> or call 630.668.3500.</p>";
                string szMessage = Utilities.GetConfigValue("CourtesyContactsPastDueMsg", szMessageDefault);
                string f = "displayErrorMessage('" + szMessage + "');";
                ClientScript.RegisterStartupScript(this.GetType(), "notavail", "$(document).ready(function() { " + f + "});", true);
                return;
            }
             
            // Add it to the collection
            CourtesyContactInvoice invoice = new CourtesyContactInvoice();
            invoice.amount = Convert.ToDecimal(txtInvoiceAmount.Text);
            invoice.invoicedate = Convert.ToDateTime(txtInvoiceDate.Text);
            invoice.invoicenum = txtInvoiceNumber.Text;

            var list = JsonConvert.DeserializeObject<List<CourtesyContactInvoice>>(InvoicesJSON);
            list.Add(invoice);
            InvoicesJSON = JsonConvert.SerializeObject(list, Formatting.Indented);
            hidInvoices.Value = InvoicesJSON;

            txtInvoiceNumber.Text = "";
            txtInvoiceDate.Text = "";
            txtInvoiceAmount.Text = "";

            ClientScript.RegisterStartupScript(this.GetType(), "refresh", "refresh();", true);
        }

        protected void btnDone_Click(object sender, System.EventArgs e)
        {
            Response.Redirect(PageConstants.SPECIAL_SERVICES);
        }
    }
}