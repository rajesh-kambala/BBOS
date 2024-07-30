/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2024-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: BusinessValuation.aspx
 Description: 

 Notes:	

***********************************************************************
***********************************************************************/
using ICSharpCode.SharpZipLib.Zip;
using PayPal.Payments.DataObjects;
using PRCo.EBB.BusinessObjects;
using PRCo.EBB.Util;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.IO;
using System.Net.Mail;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using System.Web.Services.Description;
using System.Web.UI.WebControls;
using TSI.BusinessObjects;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    public partial class BusinessValuation : BusinessValuationBase
    {
        public const string BUSINESS_VALUATION_STATUS_CODE_IN_PROGRESS = "IP";
        public const string BUSINESS_VALUATION_STATUS_CODE_PENDING = "P";
        public const string BUSINESS_VALUATION_STATUS_CODE_SENT = "S";

        public class BusinessValuationData
        {
            public IPRWebUser oWebUser;
            public bool CanViewBusinessValuations;
            public int BusinessValuationID;
            public int CreatedBy;
            public DateTime CreatedDate;
            public int CompanyID;
            public int PersonID;
            public string Desciption;
            public string FileName;
            public string DiskFileName;
            public string StatusCode;
            public DateTime SentDateTime;
            public int ProcessedBy;
            public string Guid;
        }

        protected int _iAssignedToId = 0;
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            // get any class level values
            _iAssignedToId = Utilities.GetIntConfigValue("BusinessValuationAssignedToUserID", 1074); //Default to Dan W

            SetPageTitle(Resources.Global.BlueBookBusinessValuation);
            //EnableFormValidation();

            if (!IsPostBack)
            {
                SetReturnURL(PageConstants.BBOS_DEFAULT);
                PopulateForm();
            }
        }

        protected void PopulateForm()
        {
            string szFileName_Text = "BusinessValuationText_INCLUDED.html";
            string szFileName_Thanks = "BusinessValuationThanks.html";

            // Main panel
            string szText = "";
            using (StreamReader srTerms = new StreamReader(Server.MapPath(UIUtils.GetTemplateURL(szFileName_Text))))
            {
                szText = srTerms.ReadToEnd();
            }
            businessValuationText.Text = szText;
            BusinessValuationData oBVData = GetBusinessValuationData(_oUser);
            if(oBVData.BusinessValuationID > 0)
            {
                // If we got redirected here from payment page, process the payment and send the emails
                if (!string.IsNullOrEmpty(GetRequestParameter("BusinessValuationSetIP", false)))
                {
                    GeneralDataMgr oGeneralDataMgr = new GeneralDataMgr(LoggerFactory.GetLogger(), _oUser);
                    oGeneralDataMgr.User = _oUser;
                    oGeneralDataMgr.UpdateBusinessValuationStatus(oBVData.BusinessValuationID, BUSINESS_VALUATION_STATUS_CODE_IN_PROGRESS);
                    oBVData.StatusCode = BUSINESS_VALUATION_STATUS_CODE_IN_PROGRESS;

                    RemoveRequestParameter("BusinessValuationSetIP");
                    EmailBusinessValuationUsers(null);
                }

                // optional text for all users that already have a valuation in the current calendar year(Jan – Dec).
                // These companies cannot obtain a second valuation.This includes “pending” valuations.
                businessValuationText_CurrentYearReceived.Text = Resources.Global.BusinessValuationCurrentYearReceived;
                pnlUploads.Visible = false;
                pnlButtons.Visible = false;

                if (oBVData.StatusCode == "S")
                    pnlDownloadLink.Visible = true;

                //Display extra text if BASIC membership hasn't paid for their BusinessValuation yet
                if (GetPrimaryMembership() == PROD_CODE_BASIC)
                {
                    bool bPurchased = HasBusinessValuationPurchased_CurrentYear(_oUser);
                    if (!bPurchased)
                    { 
                        businessValuationText_CurrentYearReceived.Text = string.Format(Resources.Global.BusinessValuationSubmitPayment, PageConstants.BUSINESS_VALUATION_PURCHSE);
                        btnPay.Visible = true;
                    }
                }
            }

            //Thank you panel
            string szThankYouText = "";
            using (StreamReader srTerms = new StreamReader(Server.MapPath(UIUtils.GetTemplateURL(szFileName_Thanks))))
            {
                szThankYouText = srTerms.ReadToEnd();
            }
            businessValuationThankYou.Text = szThankYouText;

            if(!string.IsNullOrEmpty(GetRequestParameter("DisplayThanks", false)))
            {
                pnlThankYou.Visible = true;
                pnlSubmitBusinessValuation.Visible = false;
                RemoveRequestParameter("DisplayThanks");
            }
        }

        protected override bool IsAuthorizedForPage()
        {
            return true;
        }

        protected override bool IsAuthorizedForData()
        {
            return true;
        }

        protected void btnUpload_Click(object sender, EventArgs e)
        {
            string szPrimaryMembership = GetPrimaryMembership();
            bool bAllowBusinessValuation_CurrentYear;
            switch(szPrimaryMembership)
            {
                case PROD_CODE_STANDARD:
                case PROD_CODE_PREMIUM:
                case PROD_CODE_ENTERPRISE:
                    bAllowBusinessValuation_CurrentYear = true;
                    break;
                default:
                    // Make sure they've purchased a BV this year
                    bAllowBusinessValuation_CurrentYear = HasBusinessValuationPurchased_CurrentYear(_oUser);
                    break;
            }
            
            if (!fuIncomeStatement.HasFile || !fuBalanceSheet.HasFile)
            {
                AddUserMessage(Resources.Global.IncomeBalanceFilesRequired);
                return;
            }

            StringBuilder sbDescription = new StringBuilder();
            sbDescription.Append("Business Valuation Request");
            sbDescription.Append("Files Submitted: ");
            sbDescription.Append(Environment.NewLine);
            if(fuIncomeStatement.HasFile)
            {
                sbDescription.Append("- Income Statement");
                sbDescription.Append(Environment.NewLine);
            }
            if (fuBalanceSheet.HasFile)
            {
                sbDescription.Append("- Balance Sheet");
                sbDescription.Append(Environment.NewLine);
            }
            if (fuOtherDoc.HasFile)
            {
                sbDescription.Append("- Other Doc");
                sbDescription.Append(Environment.NewLine);
            }

            int iBusinessValuationId;
            IDbTransaction oTran = GetObjectMgr().BeginTransaction();
            try
            {
                // BASIC memberships start as Pending unless they've already purchased a Business Valuation package this year
                // Other memberships get it free to start as In Progress
                string szStatusCode;
                if(bAllowBusinessValuation_CurrentYear)
                    szStatusCode = BUSINESS_VALUATION_STATUS_CODE_IN_PROGRESS;
                else
                    szStatusCode = BUSINESS_VALUATION_STATUS_CODE_PENDING;

                
                GeneralDataMgr oGeneralDataMgr = new GeneralDataMgr(LoggerFactory.GetLogger(), _oUser);
                oGeneralDataMgr.User = _oUser;
                iBusinessValuationId = oGeneralDataMgr.CreateBusinessValuation(szStatusCode, oTran);

                // Upload files
                string szFile;
                
                szFile = UploadFile(fuIncomeStatement, iBusinessValuationId, "Income Statement", oTran);
                szFile = UploadFile(fuBalanceSheet, iBusinessValuationId, "Balance Sheet", oTran);
                szFile = UploadFile(fuOtherDoc, iBusinessValuationId, "Other Doc", oTran);

                //Interaction 1 : Ratings team to create Credit Worth Estimate
                AssignRatingAnalystTask(iBusinessValuationId, _iAssignedToId, oTran);

                // Only send email if non-BASIC or BASIC has already paid
                if (bAllowBusinessValuation_CurrentYear)
                {
                    //Interaction 2 : Automated Email to Seth / Dan
                    EmailBusinessValuationUsers(oTran);
                }

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

            createSSFileCommunicationRecord(iBusinessValuationId.ToString(), "BBOS - Business Valuation Request Received", "Business Valuation Request Received\r\n\r\n" + sbDescription.ToString(), _iAssignedToId, Utilities.GetIntConfigValue("BusinessValuationChannelIdOverride", 0), "BV", oTran);

            pnlSubmitBusinessValuation.Visible = false;
            pnlThankYou.Visible = true;

            if (szPrimaryMembership == PROD_CODE_BASIC && !bAllowBusinessValuation_CurrentYear)
            {
                SetReturnURL(PageConstants.BBOS_HOME);
                Response.Redirect(PageConstants.BUSINESS_VALUATION_PURCHSE);
            }
        }

        protected string UploadFile(FileUpload fu, int iBusinessValuationId, string szNotePrefix, IDbTransaction oTran)
        {
            if (!fu.HasFile)
                return null;

            string fileName = fu.FileName;
            string tmpName = Guid.NewGuid().ToString("N") + ".bin";
            string szFullFileName = Path.Combine(Utilities.GetConfigValue("FileUploadTempLocation", @"C:\Temp\FileUpload"), tmpName);
            fu.SaveAs(szFullFileName);
            return simulateSageFileUpload(iBusinessValuationId.ToString(), szFullFileName, fileName, _iAssignedToId, szNotePrefix, oTran);
        }

        protected void EmailBusinessValuationUsers(IDbTransaction oTran)
        {
            string szBusinessValuationUserEmailList = Utilities.GetConfigValue("BusinessValuationUserEmails", "sbarkett@ponderaholdings.com; dwywrot@bluebookservices.com");
            string szSubject = string.Format(Utilities.GetConfigValue("BusinessValuationEmailSubject", "Business Valuation for {0}"), _oUser.prwu_BBID);
            string szEmailBody = string.Format(Utilities.GetConfigValue("BusinessValuationEmailBody", "New Business Valuation request submitted by {0} from {1} (BBID {2})"), _oUser.Name, _oUser.prwu_CompanyName, _oUser.prwu_BBID);
            GeneralDataMgr oMgr = new GeneralDataMgr(LoggerFactory.GetLogger(), _oUser);
            oMgr.SendEmail(szBusinessValuationUserEmailList,
                EmailUtils.GetFromAddress(),
                szSubject,
                szEmailBody,
                true,
                null,
                "BusinessValuation.aspx.cs",
                oTran);
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Response.Redirect(GetReturnURL(PageConstants.BBOS_DEFAULT));
        }

        protected void btnPay_Click(object sender, EventArgs e)
        {
            SetReturnURL(PageConstants.BUSINESS_VALUATION);
            Response.Redirect(PageConstants.BUSINESS_VALUATION_PURCHSE);
        }
    }
}
