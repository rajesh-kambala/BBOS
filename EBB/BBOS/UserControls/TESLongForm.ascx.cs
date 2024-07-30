/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2011-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: TESLongForm
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using PRCo.EBB.Util;
using TSI.BusinessObjects;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    public partial class TESLongForm : UserControlBase
    {
        private string _szSubjectCompanyID;
        private string _szSubjectCompanyNameLocation;
        private string _szSubjectIndustryType;
        public string TESTriggerPage;

        public bool Enabled
        {
            get { return mdlExtTradeExperienceSurvey.Enabled; }
            set { mdlExtTradeExperienceSurvey.Enabled = value; }
        }

        public string SubjectCompanyID
        {
            set
            {
                _szSubjectCompanyID = value;
                hidTESSubjectCompanyID.Value = value;
                
                CompanyData ocd = GetCompanyData(value, WebUser, GetDBAccess(), GetObjectMgr());
                _szSubjectCompanyNameLocation = ocd.szCompanyName;
                if(!string.IsNullOrEmpty(ocd.szLocation))
                    _szSubjectCompanyNameLocation = _szSubjectCompanyNameLocation + ", " + ocd.szLocation;

                hidTESSubjectCompanyName.Value = _szSubjectCompanyNameLocation;
            }
            get { return _szSubjectCompanyID; }
        }

        public string SubjectIndustryType
        {
            set
            {
                _szSubjectIndustryType = value;
                BindIndustryLookupValues();
                ShowIndustryPanel();
            }
            get { return _szSubjectIndustryType; }
        }

        public string SubjectCompanyNameLocation
        {
            get { return _szSubjectCompanyNameLocation;  }
        }

        public void SetModalTargetControl(Control targetControl)
        {
            mdlExtTradeExperienceSurvey.TargetControlID = targetControl.ID;
        }

        public void SetModalTargetControl_Unique(Control targetControl)
        {
            mdlExtTradeExperienceSurvey.TargetControlID = targetControl.UniqueID;
        }

        public void ShowPopup()
        {
            mdlExtTradeExperienceSurvey.Show();
        }

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            string szSubmitSurvey = Page.ClientScript.GetPostBackEventReference(btnSubmitSurvey, "onclick");
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "btnSubmitSurveyOnClick", "function btnSubmitSurveyOnClick() {" + szSubmitSurvey + "}", true);

            if (!IsPostBack)
            {
                if (mdlExtTradeExperienceSurvey.Enabled)
                {
                    BindSurveyLookupValues();
                    PopulateForm();
                }
            }
        }

        /// <summary>
        /// Binds the lookup value to the appropriate controls.
        /// </summary>
        protected void BindSurveyLookupValues()
        {
            IList lYesNo = new ArrayList();

            ICustom_Caption oCustomCaption = new Custom_Caption();
            oCustomCaption.Code = "Y";
            oCustomCaption.Meaning = "Yes";
            lYesNo.Add(oCustomCaption);
            oCustomCaption = new Custom_Caption();
            oCustomCaption.Code = "N";
            oCustomCaption.Meaning = "No";
            lYesNo.Add(oCustomCaption);

            PageBase.BindLookupValues(rbDealtLength, GetReferenceData("prtr_RelationshipLength", WebUser.prwu_Culture));
            PageBase.BindLookupValues(rbDealtRecently, GetReferenceData("prtr_LastDealtDate", WebUser.prwu_Culture));
            PageBase.BindLookupValues(rbDealRegularly, lYesNo);
            PageBase.BindLookupValues(cbTerms, GetReferenceData("prtr_Terms", WebUser.prwu_Culture));
            PageBase.BindLookupValues(rbIntegrity, GetReferenceData("IntegrityRating3", WebUser.prwu_Culture));
            PageBase.BindLookupValues(rbPay, GetReferenceData("TESPayRating", WebUser.prwu_Culture));

            BindIndustryLookupValues();
            
            PageBase.BindLookupValues(rbCreditTerms, GetReferenceData("prtr_CreditTerms", WebUser.prwu_Culture));
            PageBase.BindLookupValues(rbPastDue, GetReferenceData("prtr_AmountPastDue", WebUser.prwu_Culture));
            PageBase.BindLookupValues(rbTrend, GetReferenceData("prtr_OverallTrend", WebUser.prwu_Culture));
            PageBase.BindLookupValues(rbInvoice, lYesNo);
            PageBase.BindLookupValues(rbDispute, lYesNo);
        }

        protected void BindIndustryLookupValues()
        {
            if (WebUser == null)
                InitControl();

            if (_szSubjectIndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                PageBase.BindLookupValues(rbHighCredit, GetReferenceData("prtr_HighCreditL", WebUser.prwu_Culture));
            else
                PageBase.BindLookupValues(rbHighCredit, GetReferenceData("prtr_HighCreditBBOS", WebUser.prwu_Culture));
        }

        protected void HideLumber()
        {
            pnlNonLumber1.Visible = true;
            pnlNonLumber2.Visible = true;
            pnlLumber.Visible = false;
        }

        protected void HideNonLumber()
        {
            pnlLumber.Visible = true;
            pnlNonLumber1.Visible = false;
            pnlNonLumber2.Visible = false;
        }

        protected void ShowIndustryPanel()
        {
            if (_szSubjectIndustryType != GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                HideLumber();
            }
            else
            {
                HideNonLumber();
            }
        }


        protected void PopulateForm()
        {
            ShowIndustryPanel();
        }

        protected const string SQL_INSERT_PRARAGING =
            "INSERT INTO PRARAging (praa_ARAgingId, praa_CompanyId, praa_PersonId, praa_Date, praa_RunDate, praa_DateSelectionCriteria, praa_ImportedDate, praa_ManualEntry, praa_Count, praa_Total, praa_TotalCurrent, praa_Total1to30, praa_Total31to60, praa_Total61to90, praa_Total91Plus, praa_CreatedBy, praa_CreatedDate, praa_UpdatedBy, praa_UpdatedDate, praa_TimeStamp) " +
                          " VALUES (@praa_ARAgingId,@praa_CompanyId,@praa_PersonId,@praa_Date,@praa_RunDate,@praa_DateSelectionCriteria,@praa_ImportedDate,@praa_ManualEntry,@praa_Count,@praa_Total,@praa_TotalCurrent,@praa_Total1to30,@praa_Total31to60,@praa_Total61to90,@praa_Total91Plus,@praa_CreatedBy,@praa_CreatedDate,@praa_UpdatedBy,@praa_UpdatedDate,@praa_TimeStamp)";

        protected const string SQL_INSERT_PRARAGING_DETAIL =
            "INSERT INTO PRARAgingDetail (praad_ARAgingDetailId, praad_ARAgingId, praad_ManualCompanyId, praad_CreditTermsText, praad_AmountCurrent, praad_Amount1to30, praad_Amount31to60, praad_Amount61to90, praad_Amount91Plus, praad_CreatedBy, praad_CreatedDate, praad_UpdatedBy, praad_UpdatedDate, praad_TimeStamp) " +
                                " VALUES (@praad_ARAgingDetailId,@praad_ARAgingId,@praad_ManualCompanyId,@praad_CreditTermsText,@praad_AmountCurrent,@praad_Amount1to30,@praad_Amount31to60,@praad_Amount61to90,@praad_Amount91Plus,@praad_CreatedBy,@praad_CreatedDate,@praad_UpdatedBy,@praad_UpdatedDate,@praad_TimeStamp)";

        /// <summary>
        /// Processes the suvery and creates the PRTradeReport record.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnSubmitSurveyOnClick(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(_szSubjectCompanyID))
            {
                _szSubjectCompanyID = hidTESSubjectCompanyID.Value;
            }

            if (_szSubjectCompanyID == WebUser.prwu_BBID.ToString() || _szSubjectCompanyID == WebUser.prwu_HQID.ToString())
            {
                AddUserMessage(Resources.Global.TESCannotSubmitOnSelf);
                return;
            }

            if (_szSubjectCompanyID == WebUser.prwu_BBID.ToString() || _szSubjectCompanyID == WebUser.prwu_HQID.ToString())
            {
                AddUserMessage(Resources.Global.TESCannotSubmitOnSelf);
                return;
            }

            string szTerms = string.Empty;
            foreach (ListItem oItem in cbTerms.Items)
            {
                if (oItem.Selected)
                {
                    if (szTerms.Length == 0)
                    {
                        szTerms = ",";
                    }
                    szTerms += oItem.Value + ",";
                }
            }
            if (szTerms.Length == 0)
            {
                szTerms = null;
            }

            if (WebUser == null)
            {
                WebUser = (IPRWebUser)Session["oUser"];
            }

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("Responder_BBID", WebUser.prwu_BBID));
            oParameters.Add(new ObjectParameter("Subject_BBID", SubjectCompanyID));
            oParameters.Add(new ObjectParameter("HowLong", rbDealtLength.SelectedValue));
            oParameters.Add(new ObjectParameter("HowRecently", rbDealtRecently.SelectedValue));
            oParameters.Add(new ObjectParameter("DealRegularly", rbDealRegularly.SelectedValue));
            oParameters.Add(new ObjectParameter("Integrity", rbIntegrity.SelectedValue));
            oParameters.Add(new ObjectParameter("Pay", rbPay.SelectedValue));
            oParameters.Add(new ObjectParameter("HighCredit", rbHighCredit.SelectedValue));
            oParameters.Add(new ObjectParameter("CreditTerms", rbCreditTerms.SelectedValue));
            oParameters.Add(new ObjectParameter("PastDue", rbPastDue.SelectedValue));
            oParameters.Add(new ObjectParameter("InvoiceOnSameDay", rbInvoice.SelectedValue));
            oParameters.Add(new ObjectParameter("BeyondTerms", rbDispute.SelectedValue));
            oParameters.Add(new ObjectParameter("OverallPay", rbTrend.SelectedValue));
            oParameters.Add(new ObjectParameter("Terms", szTerms));
            oParameters.Add(new ObjectParameter("ResponseSource", "W"));
            oParameters.Add(new ObjectParameter("PRWebUserID", WebUser.prwu_WebUserID));
            oParameters.Add(new ObjectParameter("OutOfBusiness", GetObjectMgr().GetPIKSCoreBool(cbOutOfBusiness.Checked)));
            oParameters.Add(new ObjectParameter("Summary", txtComments.Text));

            GetDBAccess().ExecuteNonQuery("usp_AddOnlineTradeReport", oParameters, null, CommandType.StoredProcedure);
            ((PageBase)Page).AddUserMessage(Resources.Global.TESThankYouMsg);

            if (WebUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                if ((!string.IsNullOrEmpty(txtAmountOwedCurrent.Text)) ||
                    (!string.IsNullOrEmpty(txtAmountOwed1_30.Text)) ||
                    (!string.IsNullOrEmpty(txtAmountOwed31_60.Text)) ||
                    (!string.IsNullOrEmpty(txtAmountOwed61_90.Text)) ||
                    (!string.IsNullOrEmpty(txtAmountOwed91.Text)))
                {
                    int iARAgingID = GetObjectMgr().GetRecordID("PRARAging");

                    oParameters.Clear();
                    oParameters.Add(new ObjectParameter("praa_ARAgingId", iARAgingID));
                    oParameters.Add(new ObjectParameter("praa_CompanyId", WebUser.prwu_BBID));
                    oParameters.Add(new ObjectParameter("praa_PersonId", WebUser.peli_PersonID));
                    oParameters.Add(new ObjectParameter("praa_Date", DateTime.Now));
                    oParameters.Add(new ObjectParameter("praa_RunDate", DateTime.Today));
                    oParameters.Add(new ObjectParameter("praa_DateSelectionCriteria", "INV"));
                    oParameters.Add(new ObjectParameter("praa_ImportedDate", DateTime.Today));
                    oParameters.Add(new ObjectParameter("praa_ManualEntry", "Y"));
                    oParameters.Add(new ObjectParameter("praa_Count", 1));
                    oParameters.Add(new ObjectParameter("praa_Total", GetValueForDBasDecmial(txtAmountOwedCurrent.Text) + GetValueForDBasDecmial(txtAmountOwed1_30.Text) + GetValueForDBasDecmial(txtAmountOwed31_60.Text) + GetValueForDBasDecmial(txtAmountOwed61_90.Text) + GetValueForDBasDecmial(txtAmountOwed91.Text)));
                    oParameters.Add(new ObjectParameter("praa_TotalCurrent", GetValueForDB(txtAmountOwedCurrent.Text)));
                    oParameters.Add(new ObjectParameter("praa_Total1to30", GetValueForDB(txtAmountOwed1_30.Text)));
                    oParameters.Add(new ObjectParameter("praa_Total31to60", GetValueForDB(txtAmountOwed31_60.Text)));
                    oParameters.Add(new ObjectParameter("praa_Total61to90", GetValueForDB(txtAmountOwed61_90.Text)));
                    oParameters.Add(new ObjectParameter("praa_Total91Plus", GetValueForDB(txtAmountOwed91.Text)));

                    GetObjectMgr().AddAuditTrailParametersForInsert(oParameters, "praa");
                    GetDBAccess().ExecuteNonQuery(SQL_INSERT_PRARAGING, oParameters, null);

                    oParameters.Clear();
                    oParameters.Add(new ObjectParameter("praad_ARAgingDetailId", GetObjectMgr().GetRecordID("PRARAgingDetail")));
                    oParameters.Add(new ObjectParameter("praad_ARAgingId", iARAgingID));
                    oParameters.Add(new ObjectParameter("praad_ManualCompanyId", SubjectCompanyID));
                    oParameters.Add(new ObjectParameter("praad_CreditTermsText", null));
                    oParameters.Add(new ObjectParameter("praad_AmountCurrent", GetValueForDB(txtAmountOwedCurrent.Text)));
                    oParameters.Add(new ObjectParameter("praad_Amount1to30", GetValueForDB(txtAmountOwed1_30.Text)));
                    oParameters.Add(new ObjectParameter("praad_Amount31to60", GetValueForDB(txtAmountOwed31_60.Text)));
                    oParameters.Add(new ObjectParameter("praad_Amount61to90", GetValueForDB(txtAmountOwed61_90.Text)));
                    oParameters.Add(new ObjectParameter("praad_Amount91Plus", GetValueForDB(txtAmountOwed91.Text)));

                    GetObjectMgr().AddAuditTrailParametersForInsert(oParameters, "praad");
                    GetDBAccess().ExecuteNonQuery(SQL_INSERT_PRARAGING_DETAIL, oParameters, null);
                }
            }

            try
            {
                GetObjectMgr().CreateRequest("TES", SubjectCompanyID, Page.Request.Path, null);

                //This ensures that the cache is cleared so that when and if the user goes to some other page
                //and then they click the Back browser button, the survey does not get resubmitted.
                //We are not adding any extra processing here because the postback resubmits the whole page
                //to begin with.
                //Response.Redirect("CompanyDetailsSummary.aspx?CompanyID=" + hidCompanyID.Text + "&thanks=true", false);
            }
            catch (Exception eX)
            {
                // There's nothing the end user can do about this so
                // just log it and keep moving.
                LogError(eX);

                if (Configuration.ThrowDevExceptions)
                {
                    throw;
                }
            }
            finally
            {
                //This resets the form in the modal.
                BindSurveyLookupValues();
                cbOutOfBusiness.Checked = false;
                txtComments.Text = string.Empty;
            }
        }

        protected string GetValueForDB(string szValue)
        {
            if (string.IsNullOrEmpty(szValue))
            {
                return null;
            }
            return szValue;
        }

        protected decimal GetValueForDBasDecmial(string szValue)
        {
            if (string.IsNullOrEmpty(szValue))
            {
                return 0M;
            }
            return Convert.ToDecimal(szValue);
        }
    }
}