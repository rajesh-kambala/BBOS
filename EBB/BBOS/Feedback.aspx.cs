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

 ClassName: Feedback.aspx.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Text;

using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;
using PRCo.EBB.Util;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web
{
    public partial class Feedback : PageBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            SetPageTitle(Resources.Global.Feedback);
            SetPopover();

            if (!IsPostBack)
            {
                BindLookupValues();

                if (_oUser != null)
                {
                    pnlUserInfo.Visible = false;
                }

                if (GetRequestParameter("FeedbackType", false) == "RULC")
                {
                    int iSearchID;
                    if (!String.IsNullOrEmpty(Request["SearchID"]))
                        Int32.TryParse(GetRequestParameter("SearchID"), out iSearchID);
                    else
                        iSearchID = 0;

                    // Check for an existing Company Search Criteria Object
                    IPRWebUserSearchCriteria oWebUserSearchCriteria = GetSearchCritieria(iSearchID, PRWebUserSearchCriteria.SEARCH_TYPE_COMPANY, true);
                    if (oWebUserSearchCriteria != null)
                    {
                        CompanySearchCriteria oCriteria = (CompanySearchCriteria)oWebUserSearchCriteria.Criteria;
                        txtCompanyName.Text = oCriteria.CompanyName;
                    }
                }
            }
        }

        protected void SetPopover()
        {
            popWhatIsPageName.Attributes.Add("data-bs-title", Resources.Global.WhatIsPageName);
            popWhatIsObjectClicked.Attributes.Add("data-bs-title", Resources.Global.WhatIsObjectClicked);
            popDataBeingViewed.Attributes.Add("data-bs-title", Resources.Global.DataBeingViewedMsg);
        }

        /// <summary>
        /// Loads all of the databound controls setting 
        /// thier default values.
        /// </summary>  
        protected void BindLookupValues()
        {
            BindLookupValues(ddlFeedbackType, GetReferenceData("prfdbk_FeedbackTypeCode"), GetCurrentCulture(_oUser));

            if (GetRequestParameter("FeedbackType", false) != null)
            {
                SetListDefaultValue(ddlFeedbackType, GetRequestParameter("FeedbackType", false));
            }
        }

        protected const string SQL_INSERT_FEEDBACK = "INSERT INTO PRFeedBack (prfdbk_WebUserID, prfdbk_Browser, prfdbk_BrowserVersion, prfdbk_BrowserPlatform, prfdbk_UserAgent, prfdbk_FeedbackTypeCode, prfdbk_PageName, prfdbk_ActionTaken, prfdbk_Data, prfdbk_Expectations, prfdbk_ActualBehavior, prfdbk_HowIsBeneficial, prfdbk_HowOftenUsed, prfdbk_CurrentFunctionality, prfdbk_ProposedFunctionality, prfdbk_General, prfdbk_IPAddress, prfdbk_Name, prfdbk_Email, prfdbk_CreatedBy, prfdbk_CreatedDate, prfdbk_UpdatedBy, prfdbk_UpdatedDate, prfdbk_TimeStamp) VALUES ({0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16},{17},{18},{19},{20},{21},{22},{23})";
        protected void btnSubmitOnClick(object sender, EventArgs e)
        {
            ArrayList oParameters = new ArrayList();

            if (_oUser != null)
            {
                oParameters.Add(new ObjectParameter("prfdbk_WebUserID", _oUser.prwu_WebUserID));
            }
            else
            {
                oParameters.Add(new ObjectParameter("prfdbk_WebUserID", null));
            }

            oParameters.Add(new ObjectParameter("prfdbk_Browser", Request.Browser.Browser));
            oParameters.Add(new ObjectParameter("prfdbk_BrowserVersion", Request.Browser.Version));
            oParameters.Add(new ObjectParameter("prfdbk_BrowserPlatform", Request.Browser.Platform));
            oParameters.Add(new ObjectParameter("prfdbk_UserAgent", Request.ServerVariables["HTTP_USER_AGENT"]));
            oParameters.Add(new ObjectParameter("prfdbk_FeedbackTypeCode", ddlFeedbackType.SelectedValue));
            oParameters.Add(new ObjectParameter("prfdbk_PageName", txtPageName.Text));
            oParameters.Add(new ObjectParameter("prfdbk_ActionTaken", txtClicked.Text));
            oParameters.Add(new ObjectParameter("prfdbk_Data", txtData.Text));
            oParameters.Add(new ObjectParameter("prfdbk_Expectations", txtExpectations.Text));

            if (ddlFeedbackType.SelectedValue == "RF")
            {
                oParameters.Add(new ObjectParameter("prfdbk_ActualBehavior", txtDescription.Text));
                oParameters.Add(new ObjectParameter("prfdbk_HowIsBeneficial", txtChangeBenefits.Text));
            }
            else
            {
                oParameters.Add(new ObjectParameter("prfdbk_ActualBehavior", txtActualBehavior.Text));
                oParameters.Add(new ObjectParameter("prfdbk_HowIsBeneficial", txtBenefits.Text));
            }

            oParameters.Add(new ObjectParameter("prfdbk_HowOftenUsed", txtHowOften.Text));
            oParameters.Add(new ObjectParameter("prfdbk_CurrentFunctionality", txtCurrentFunctionality.Text));
            oParameters.Add(new ObjectParameter("prfdbk_ProposedFunctionality", txtProposedFunctionality.Text));

            switch (ddlFeedbackType.SelectedValue)
            {
                case "GC":
                    oParameters.Add(new ObjectParameter("prfdbk_General", txtComment.Text));
                    break;
                case "RULC":
                    StringBuilder sbSuggestCompany = new StringBuilder();
                    sbSuggestCompany.Append("Company Name: " + txtCompanyName.Text + Environment.NewLine);
                    sbSuggestCompany.Append("Company Address: " + txtCompanyAddress.Text + Environment.NewLine);
                    sbSuggestCompany.Append("Company Phone: " + txtCompanyPhone.Text + Environment.NewLine);
                    sbSuggestCompany.Append("Company Website: " + txtCompanyWeb.Text + Environment.NewLine);
                    sbSuggestCompany.Append("Additional Info: " + txtCompanyAddlInfo.Text + Environment.NewLine);
                    oParameters.Add(new ObjectParameter("prfdbk_General", sbSuggestCompany.ToString()));
                    break;
                case "SM":
                    StringBuilder sbSealMisuse = new StringBuilder();
                    sbSealMisuse.Append("Company Name: " + txtCompanyName.Text + Environment.NewLine);
                    sbSealMisuse.Append("Company Website: " + txtCompanyWeb.Text + Environment.NewLine);
                    sbSealMisuse.Append("Additional Info: " + txtCompanyAddlInfo.Text + Environment.NewLine);
                    oParameters.Add(new ObjectParameter("prfdbk_General", sbSealMisuse.ToString()));
                    break;
                default:
                    oParameters.Add(new ObjectParameter("prfdbk_General", txtQuestion.Text));
                    break;
            }

            oParameters.Add(new ObjectParameter("prfdbk_IPAddress", Request.ServerVariables["REMOTE_ADDR"]));
            oParameters.Add(new ObjectParameter("prfdbk_Name", txtUserName.Text));
            oParameters.Add(new ObjectParameter("prfdbk_Email", txtUserEmail.Text));

            GetObjectMgr().AddAuditTrailParametersForInsert(oParameters, "prfdbk");
            GetObjectMgr().ExecuteIdentityInsert("PRFeedBack", SQL_INSERT_FEEDBACK, oParameters);

            SendFeedbackEmail();

            if (_oUser == null)
            {
                Response.Redirect(Configuration.WebSiteHome);
            }
            else
            {
                AddUserMessage(Resources.Global.FeedbackThankyouMsg, true);
                Response.Redirect(PageConstants.BBOS_HOME);
            }
        }

        protected void SendFeedbackEmail()
        {
            if (_oUser == null)
            {
                return;
            }

            if (_oUser.prwu_IndustryType != GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                return;
            }

            string szSubmittedText = "";
            const string NewLine = "<BR>";

            StringBuilder msg = new StringBuilder();
            msg.Append("A lumber user has {0}." + NewLine + NewLine);
            msg.Append("Submitted By:" + NewLine);
            msg.Append(_oUser.Name + NewLine);
            msg.Append("BBID #: " + _oUser.prwu_BBID.ToString() + " " + _oUser.prwu_CompanyName + NewLine);
            msg.Append(_oUser.Email + NewLine + NewLine);

            switch (ddlFeedbackType.SelectedValue)
            {
                case "PR":
                    szSubmittedText = "submitted a Problem Report";
                    msg.Append("Problem Info Submitted:" + NewLine);
                    msg.Append("Page Name: " + txtPageName.Text + NewLine);
                    msg.Append("Object Clicked / Action Taken: " + txtClicked.Text + NewLine);
                    msg.Append("Date Being Viewed: " + txtData.Text + NewLine);
                    msg.Append("Describe Expected Result: " + txtExpectations.Text + NewLine);
                    msg.Append("Describe Actual Behavior: " + txtActualBehavior.Text + NewLine);
                    break;
                case "RF":
                    szSubmittedText = "requested a New Feature";
                    msg.Append("Feature Info Submitted:" + NewLine);
                    msg.Append("Idea Description: " + txtDescription.Text + NewLine);
                    msg.Append("How Benefits: " + txtChangeBenefits.Text + NewLine);
                    msg.Append("How Often Use: " + txtHowOften.Text + NewLine);
                    break;
                case "CR":
                    szSubmittedText = "requested a Change Request";
                    msg.Append("Change Request Info Submitted:" + NewLine);
                    msg.Append("Current Functionality: " + txtCurrentFunctionality.Text + NewLine);
                    msg.Append("Proposed New Functionality: " + txtProposedFunctionality.Text + NewLine);
                    msg.Append("How Benefits: " + txtBenefits.Text + NewLine);
                    break;
                case "Q":
                    szSubmittedText = "submitted a Question";
                    msg.Append("Question Submitted:" + NewLine);
                    msg.Append(txtQuestion.Text + NewLine);
                    break;
                case "RULC":
                    szSubmittedText = "suggested a Company to Research";
                    msg.Append("Company Info Submitted:" + NewLine);
                    msg.Append("Company Name: " + txtCompanyName.Text + NewLine);
                    msg.Append("Company Address: " + txtCompanyAddress.Text + NewLine);
                    msg.Append("Company Phone: " + txtCompanyPhone.Text + NewLine);
                    msg.Append("Company Website: " + txtCompanyWeb.Text + NewLine);
                    msg.Append("Additional Info: " + txtCompanyAddlInfo.Text + NewLine);
                    break;
                case "SM":
                    szSubmittedText = "submitted Seal Misuse";
                    msg.Append("Seal Misuse Info Submitted:" + NewLine);
                    msg.Append("Company Name: " + txtCompanyName.Text + NewLine);
                    msg.Append("Company Web Sites: " + txtCompanyWeb.Text + NewLine);
                    msg.Append("Additional Information: " + txtCompanyAddlInfo.Text + NewLine);
                    break;
                case "GC":
                    szSubmittedText = "submitted a General Comment";
                    msg.Append(txtComment.Text + NewLine);
                    break;

                default:
                    break;
            }

            string szMsg = string.Format(msg.ToString(), szSubmittedText); //replace {0}

            //Send email via SQL server method
            GeneralDataMgr oMgr = new GeneralDataMgr(LoggerFactory.GetLogger(), null);
            oMgr.SendEmail(Configuration.FeedbackCompanySubmissionEmail,
                            EmailUtils.GetFromAddress(),
                            Configuration.FeedbackCompanySubmissionSubject,
                            szMsg,
                            true,
                            null,
                            "Feedback.aspx",
                            null);
        }

        protected void btnCancelOnClick(object sender, EventArgs e)
        {
            if (_oUser == null)
            {
                Response.Redirect(Configuration.WebSiteHome);
            }
            else
            {
                Response.Redirect(PageConstants.BBOS_HOME);
            }
        }

        protected override bool IsAuthorizedForData()
        {
            return true;
        }

        protected override bool IsAuthorizedForPage()
        {
            return true;
        }

        public override bool EnableJSClientIDTranslation()
        {
            return true;
        }
    }
}
