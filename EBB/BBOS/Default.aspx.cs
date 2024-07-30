/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2007-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: Default.aspx.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;

using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;
using System.Data;
using System.Web.UI.WebControls;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;
using System.Web;
using System.Web.Security;
using PRCo.EBB.Util;

namespace PRCo.BBOS.UI.Web
{
    public partial class Default : PageBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
            ((BBOS)Master).HideOldTopMenu();

            if (_oUser.IsLimitado)
            {
                Session["oWebUserSearchCriteria"] = null;
                Response.Redirect(PageConstants.LIMITADO_SEARCH);
            }
            else
            {
                //Not ITA user -- check cookie and possibly remove
                HttpCookie oLimitadoCookie = Request.Cookies[Limitado.LIMITADO_COOKIE_NAME];
                if (oLimitadoCookie != null && oLimitadoCookie.Value == "true")
                {
                    //Remove cookie since they don't have ITA aceess
                    Request.Cookies.Remove(Limitado.LIMITADO_COOKIE_NAME);
                    oLimitadoCookie.Expires = DateTime.Now.AddYears(-1);
                    oLimitadoCookie.Value = "false";
                    Response.Cookies.Set(oLimitadoCookie);
                }
            }

            if(Session["CrossIndustryCheck"] == null)
            {
                PRWebUserMgr userMgr = new PRWebUserMgr(LoggerFactory.GetLogger(), null);
                IBusinessObjectSet crossIndustryUsers = (IBusinessObjectSet)userMgr.GetUsersByCrossIndustry(_oUser.Email);
                if(crossIndustryUsers.Count == 0)
                {
                    Session["CrossIndustryCheck"] = "Y";
                }
                else
                {
                    foreach (IPRWebUser user in crossIndustryUsers)
                    {
                        if (_oUser.Email.ToLower() != user.Email.ToLower())
                        {
                            Session["CrossIndustryUser"] = user;
                            break;
                        }
                    }
                }
            }

            if(Session["CrossIndustryUser"] != null)
            {
                pnlCrossIndustryCheck.Visible = true;

                IPRWebUser oCrossIndustryUser = (IPRWebUser)Session["CrossIndustryUser"];
                if (oCrossIndustryUser.prwu_IndustryType == "L")
                    btnCrossIndustry.Text = "Switch to Lumber";
                else
                    btnCrossIndustry.Text = "Switch to Produce";
            }
            else
                pnlCrossIndustryCheck.Visible = false;

            ((BBOS)Master).HTMLTitle = Resources.Global.BlueBookService; //"Blue Book Service"
            ((BBOS)Master).SelectedMenu = "home-dropdown";

            EnableFormValidation();

            if (!IsPostBack)
            {
                PopulateMicroslider();
                ProcessRefreshCachePending();
            }

            PopulateWidgets();

            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_FUNCTIONS2_FILE));
            
            PopulateForm();

            DisplayBBOSPopup();

            hlSavedSearches.NavigateUrl = PageConstants.SAVED_SEARCHES;
            hlPersonSearch.NavigateUrl = PageConstants.PERSON_SEARCH;
            hlCompanyUpdateSearch.NavigateUrl = PageConstants.COMPANY_UPDATE_SEARCH;
            hlRecentViews.NavigateUrl = PageConstants.RECENT_VIEWS;
            hlLastCompanySearch.NavigateUrl = PageConstants.COMPANY_SEARCH_RESULTS_EXECUTE_LAST;

            if (_oUser.prwu_LastCompanySearchID == 0)
            {
                hlLastCompanySearch.Enabled = false;
            }

            hlClaimActivitySearch.NavigateUrl = PageConstants.CLAIMS_ACTIVITY_SEARCH;
            hlWatchdogLists.NavigateUrl = PageConstants.BROWSE_COMPANIES;
            hlNotes.NavigateUrl = PageConstants.BROWSE_NOTES;
            hlCustomFields.NavigateUrl = PageConstants.CUSTOM_FIELDS;
            hlPurchases.NavigateUrl = PageConstants.BROWSE_PURCHASES;
            hlAdditionalTools.NavigateUrl = PageConstants.DOWNLOADS;
            hlTES.NavigateUrl = PageConstants.TES;
            hlNewHireAcademy.NavigateUrl = PageConstants.NEW_HIRE_ACADEMY;

            hlLearningCenter.NavigateUrl = PageConstants.LEARNING_CENTER;
            hlBlueprints.NavigateUrl = PageConstants.BLUEPRINTS;
            hlBluebookServices.NavigateUrl = PageConstants.BLUEBOOK_SERVICES;
            hlBluebookReference.NavigateUrl = PageConstants.BLUEBOOK_REFERENCE;

            hlKnowYourCommodity.NavigateUrl = PageConstants.KNOW_YOUR_COMMODITY;

            hlSpecialServices.NavigateUrl = PageConstants.SPECIAL_SERVICES;
            hlQA.NavigateUrl = PageConstants.QA;
            hlSystemInfo.NavigateUrl = PageConstants.SYSTEM_INFO;

            ApplySecurity(_oUser);

            // If we're home, then let's clear out some of the
            // data from our session.
            RemoveRequestParameter("CompanyIDList");
            ClearSearchCritiera();

            Session.Remove(COMPANY_DATA_KEY);
            Session.Remove(COMPANY_DATA_KEY_HQ);
            Session.Remove(COMPANY_NEWS_DATA_KEY);

            Session.Remove("NotesSearchCriteria");
            Session.Remove("NotesSearchCriteria2");
            Session.Remove("ReturnURL");
            Session.Remove("CompanyID");
            DeleteCookie("CompanyID");

            if (!IsPostBack)
            {
                displayNoteReminder();
            }

            ApplyReadOnlyCheck(hlCustomFields);

            //Defect 7559
            if (!string.IsNullOrEmpty(_oUser.GetOpenInvoiceMessageCode()) && (Session["InvoiceMessage_SentDate"]==null || ((DateTime)Session["InvoiceMessage_SentDate"]).AddDays(1).CompareTo(DateTime.Now) < 0))
            {
                string sInvoiceCheckScript = "var bDisplayInvoiceMessage=true; ";
                if (_oUser.GetOpenInvoiceMessageCode() == PRWebUser.OPEN_INVOICE_MESSAGE_CODE_SUSPEND)
                    sInvoiceCheckScript += "var bSuspend=true;";
                else
                {
                    sInvoiceCheckScript += "var bSuspend=false;";
                    Session["InvoiceMessage_SentDate"] = DateTime.Now;
                }

                Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "invoiceCheck", sInvoiceCheckScript, true);
                PopulateOpenInvoiceMessageFields();
            }
            else
            {
                Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "invoiceCheck", "var bDisplayInvoiceMessage=false;", true);
            }
        }

        private void PopulateWidgets()
        {
            //Get all widgets configured for current user
            PRWebUserWidgetMgr oMgr = new PRWebUserWidgetMgr(_oLogger, _oUser);
            IBusinessObjectSet osWebUserWidgets = oMgr.GetObjects(string.Format("{0}={1} ORDER BY prwuw_Sequence", PRWebUserWidgetMgr.COL_PRWUW_WEB_USER_ID, _oUser.prwu_WebUserID));

            repWidgets.DataSource = osWebUserWidgets;
            repWidgets.DataBind();
        }

        private void PopulateOpenInvoiceMessageFields()
        {
            litInvoiceModalFooter.Text = string.Format(Resources.Global.OpenInvoice_Message_Footer, _oUser.OpenInvoiceNbr);

            switch (_oUser.GetOpenInvoiceMessageCode())
            {
                case PRWebUser.OPEN_INVOICE_MESSAGE_CODE_COMINGDUE:
                    litInvoiceModalTitle.Text = Resources.Global.OpenInvoice_Message_ComingDue_Title;
                    litInvoiceModalMessage.Text = string.Format(Resources.Global.OpenInvoice_Message_ComingDue_Message, _oUser.OpenInvoicePaymentURL);
                    break;
                case PRWebUser.OPEN_INVOICE_MESSAGE_CODE_PAYMENTDUE:
                    litInvoiceModalTitle.Text = Resources.Global.OpenInvoice_Message_PaymentDue_Title;
                    litInvoiceModalMessage.Text = string.Format(Resources.Global.OpenInvoice_Message_PaymentDue_Message, _oUser.OpenInvoicePaymentURL);
                    break;
                case PRWebUser.OPEN_INVOICE_MESSAGE_CODE_PASTDUE:
                    litInvoiceModalTitle.Text = Resources.Global.OpenInvoice_Message_PastDue_Title;
                    litInvoiceModalMessage.Text = string.Format(Resources.Global.OpenInvoice_Message_PastDue_Message, _oUser.OpenInvoicePaymentURL);
                    break;
                case PRWebUser.OPEN_INVOICE_MESSAGE_CODE_SUSPEND:
                    litInvoiceModalTitle.Text = Resources.Global.OpenInvoice_Message_Suspend_Title;
                    litInvoiceModalMessage.Text = string.Format(Resources.Global.OpenInvoice_Message_Suspend_Message, _oUser.OpenInvoicePaymentURL);
                    break;
                default:
                    break;
            }
        }

        private void ProcessRefreshCachePending()
        {
            if (Session["RefreshCachePending"] != null)
            {
                Session["RefreshCachePending"] = null;
                Response.Redirect(Request.RawUrl);
            }
        }

        private const string IMG_MICROSLIDER = "<img src=\"{3}\" data-href=\"{0}?AdCampaignID={1}&AdAuditTrailID={2}\" />";
        private const string SQL_MICROSLIDER_ADS =
             @"SELECT pradc_AdCampaignID, pracf_FileName_Disk
                    FROM PRAdCampaign WITH (NOLOCK)
	                INNER JOIN PRAdCampaignFile WITH (NOLOCK) ON pracf_AdCampaignID = pradc_AdCampaignID
                WHERE 
		            pradc_AdCampaignTypeDigital = @AdCampaignTypeDigital
		            AND GETDATE() BETWEEN pradc_StartDate AND pradc_EndDate
                AND pradc_IndustryType LIKE @IndustryType
                AND pradc_Language LIKE @Language
                AND pradc_CreativeStatus='A'
            ORDER BY pradc_Sequence, pradc_StartDate DESC";

        protected void PopulateMicroslider()
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("IndustryType", "%," + _oUser.prwu_IndustryType + ",%"));
            oParameters.Add(new ObjectParameter("Language", "%," + _oUser.prwu_Culture + ",%"));

            if(_oUser.prwu_AccessLevel == PRWebUser.SECURITY_LEVEL_TRADE_ASSOCIATION_ACCESS)
                oParameters.Add(new ObjectParameter("AdCampaignTypeDigital", "BBOSSliderITA"));
            else
                oParameters.Add(new ObjectParameter("AdCampaignTypeDigital", "BBOSSlider"));

            int adAuditTrailID = 0;
            int adCount = 0;

            List<Int32> campaignIDs = new List<int>();
            List<Int32> topSpotCampaignIDs = new List<int>();

            AdUtils _adUtils = new AdUtils(_oLogger, _oUser);

            using (IDbTransaction oTrans = GetObjectMgr().BeginTransaction())
            {
                try
                {
                    StringBuilder microSliderImages = new StringBuilder();
                    using (IDataReader reader = GetDBAccess().ExecuteReader(SQL_MICROSLIDER_ADS, oParameters, CommandBehavior.CloseConnection, null))
                    {
                        while (reader.Read())
                        {
                            campaignIDs.Add(reader.GetInt32(0));
                            if (topSpotCampaignIDs.Count == 0)
                            {
                                topSpotCampaignIDs.Add(reader.GetInt32(0));
                            }

                            adCount++;
                            if ((!IsPRCoUser()) ||
                                (Configuration.AdCampaignTesting))
                            {
                                adAuditTrailID = _adUtils.InsertAdAuditTrail(reader.GetInt32(0),
                                                                6046,
                                                                adCount,
                                                                null,
                                                                0,
                                                                oTrans);
                            }

                            string szAdImageHTML = Configuration.AdImageVirtualFolder + reader.GetString(1).Replace('\\', '/');
                            object[] oArgs = {Configuration.AdClickURL,
                                    reader.GetInt32(0),
                                    adAuditTrailID,
                                    szAdImageHTML,
                                    string.Empty};

                            microSliderImages.Append(string.Format(IMG_MICROSLIDER, oArgs));
                        }
                    }

                    // Make sure the impression counts are updated.
                    // Exclude the PRCo company from any auditing
                    if ((!IsPRCoUser()) ||
                        (Configuration.AdCampaignTesting))
                    {
                        _adUtils.UpdateImpressionCount(campaignIDs, oTrans);
                        _adUtils.UpdateTopSpotCount(topSpotCampaignIDs, oTrans);
                    }

                    microslider.Text = microSliderImages.ToString();

                    oTrans.Commit();
                }
                catch(Exception)
                {
                    if (oTrans != null)
                    {
                        oTrans.Rollback();
                    }
                    throw;
                }
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

        protected void PopulateForm()
        {
        }

        /// <summary>
        /// Disables menu options based on the specified user's
        /// security access and assigned roles.
        /// </summary>
        /// <param name="oUser"></param>
        public void ApplySecurity(IPRWebUser oUser)
        {
            ApplySecurity(liCompanySearch, hlCompanySearch, SecurityMgr.Privilege.CompanySearchPage);
            ApplySecurity(liPersonSearch, hlPersonSearch, SecurityMgr.Privilege.PersonSearchPage);
            ApplySecurity(liCompanyUpdateSearch, hlCompanyUpdateSearch, SecurityMgr.Privilege.CompanyUpdatesSearchPage);
            ApplySecurity(liSavedSearches, hlSavedSearches, SecurityMgr.Privilege.SaveSearches);
            ApplySecurity(liRecentViews, hlRecentViews, SecurityMgr.Privilege.RecentViewsPage);
            ApplySecurity(liLastCompanySearch, hlLastCompanySearch, SecurityMgr.Privilege.CompanySearchPage);

            ApplySecurity(liSpecialServices, hlSpecialServices, SecurityMgr.Privilege.TradingAssistancePage);
            ApplySecurity(liClaimActivitySearch, hlClaimActivitySearch, SecurityMgr.Privilege.ClaimActivitySearchPage);
            ApplySecurity(liWatchodgLists, hlWatchdogLists, SecurityMgr.Privilege.WatchdogListsPage);
            ApplySecurity(liNotes, hlNotes, SecurityMgr.Privilege.Notes);
            ApplySecurity(liCustomFields, hlCustomFields, SecurityMgr.Privilege.CustomFields);
            ApplySecurity(liPurchases, hlPurchases, SecurityMgr.Privilege.PurchasesPage);
            ApplySecurity(liAdditionalTools, hlAdditionalTools, SecurityMgr.Privilege.DownloadsPage);
            ApplySecurity(liTES, hlTES, SecurityMgr.Privilege.TradeExperienceSurveyPage);

            ApplySecurity(liLearningCenter, hlLearningCenter, SecurityMgr.Privilege.LearningCenterPage);
            ApplySecurity(liBlueprints, hlBlueprints, SecurityMgr.Privilege.BlueprintsPage);
            ApplySecurity(liKnowYourCommodity, hlKnowYourCommodity, SecurityMgr.Privilege.KnowYourCommodityPage);
            ApplySecurity(liBluebookReference, hlBluebookReference, SecurityMgr.Privilege.ReferenceGuidePage);
            ApplySecurity(liBluebookServices, hlBluebookServices, SecurityMgr.Privilege.MembershipGuidePage);
            ApplySecurity(liNewHireAcademy, hlNewHireAcademy, SecurityMgr.Privilege.NewHireAcademyPage);

            //ApplySecurity(liTES, hlTES, SecurityMgr.Privilege.TradeExperienceSurveyPage);
            //ApplySecurity(liEditCompany, hlEditCompany, SecurityMgr.Privilege.CompanyEditListingPage);
            //ApplySecurity(liManageMembership, hlManageMembership, SecurityMgr.Privilege.ManageMembershipPage);

            if (IsPRCoUser())
            {
                pnlQA.Visible = true;

                if (oUser.HasPrivilege(SecurityMgr.Privilege.SystemAdmin).HasPrivilege)
                {
                    hlSystemInfo.Visible = true;
                }
            }

            // This user may have just bought a membership, but it hasn't 
            // been linked to a CRM entity yet, so they cannot access
            // this functionality yet.
            if ((oUser.prwu_PersonLinkID == 0) ||
                (oUser.prwu_BBID == 0))
            {
                hlSpecialServices.Enabled = false;
                //hlEditCompany.Enabled = false;
                //hlRegisterUser.Enabled = false;
            }

            if(oUser.prwu_HQID ==0)
            {
                //Disable Notes
                hlNotes.Enabled = false;
            }
        }

        protected void btnLogoffOnClick(object sender, EventArgs e)
        {
            LogoffUser();
        }

        protected void btnCompanySearchOnClick(object sender, EventArgs e)
        {
            Session["oWebUserSearchCriteria"] = null;
            if (!string.IsNullOrEmpty(_oUser.prwu_DefaultCompanySearchPage))
            {
                Response.Redirect(_oUser.prwu_DefaultCompanySearchPage);
            }
            else
            {
                Response.Redirect(PageConstants.COMPANY_SEARCH);
            }
        }

        public override bool EnableGoogleAdServices()
        {
            if (Session["HomePageFirstTime"] == null)
            {
                Session["HomePageFirstTime"] = "N";
                return true;
            }

            return false;
        }

        protected void DisplayBBOSPopup()
        {
            int buttonHeightOffset = 50;
            using (IDataReader reader = GetObjectMgr().GetBBOSPopupDataReader())
            {
                if (reader.Read())
                {
                    hdnPublicationArticleID.Value = reader.GetInt32(0).ToString();

                    switch (reader.GetString(3))
                    {
                        case "T":
                            pnlBBOSPopup.Width = Unit.Pixel(Utilities.GetIntConfigValue("BBOSPopupSmallWidth", 175));
                            pnlBBOSPopup.Height = Unit.Pixel(Utilities.GetIntConfigValue("BBOSPopupSmallHeight", 100) + buttonHeightOffset);
                            break;
                        case "S":
                            pnlBBOSPopup.Width = Unit.Pixel(Utilities.GetIntConfigValue("BBOSPopupSmallWidth", 300));
                            pnlBBOSPopup.Height = Unit.Pixel(Utilities.GetIntConfigValue("BBOSPopupSmallHeight", 200) + buttonHeightOffset);
                            break;
                        case "M":
                            pnlBBOSPopup.Width = Unit.Pixel(Utilities.GetIntConfigValue("BBOSPopupLargeWidth", 630));
                            pnlBBOSPopup.Height = Unit.Pixel(Utilities.GetIntConfigValue("BBOSPopupLargeHeight", 400) + buttonHeightOffset);
                            break;
                        case "L":
                            pnlBBOSPopup.Width = Unit.Pixel(Utilities.GetIntConfigValue("BBOSPopupMediumWidth", 900));
                            pnlBBOSPopup.Height = Unit.Pixel(Utilities.GetIntConfigValue("BBOSPopupMediumHeight", 500) + buttonHeightOffset);
                            break;
                    }

                    litBBOSPopup.Text = reader.GetString(2);

                    if ((reader[4] == DBNull.Value) ||
                        (reader[4] == null))
                    {
                        // The user should only view the pop-up once per day.
                        if ((_oUser.prwu_LastBBOSPopupID != reader.GetInt32(0)) ||
                            (_oUser.prwu_LastBBOSPopupViewDate != DateTime.Today))
                        {
                            Page.ClientScript.RegisterStartupScript(this.GetType(), "key", "displayBBOSPopup();", true);

                            _oUser.prwu_LastBBOSPopupID = reader.GetInt32(0);
                            _oUser.prwu_LastBBOSPopupViewDate = DateTime.Today;
                            _oUser.Save();
                        }
                    }
                }
            }
        }

        public void btnDismissBBOSPopupClick(object sender, EventArgs e)
        {
            GetObjectMgr().InsertPublicationArticleRead(Convert.ToInt32(hdnPublicationArticleID.Value),
                                                        0,
                                                        null,
                                                        null,
                                                        "BBOSPU",
                                                        null);
            Response.Redirect(PageConstants.BBOS_HOME); //PopulateForm();
        }

        public void btnRemindBBOSPopupClick(object sender, EventArgs e)
        {
            _oUser.prwu_LastBBOSPopupViewDate = DateTime.Today;
            _oUser.Save();
            Response.Redirect(PageConstants.BBOS_HOME); //PopulateForm();
        }

        public void btnClose_Click(object sender, EventArgs e)
        {
            Session["NoteReminderSnooze"] = DateTime.Now;
            Response.Redirect(PageConstants.BBOS_HOME);
        }

        protected void displayNoteReminder()
        {
            if (Session["NoteReminderSnooze"] != null)
            {
                DateTime snooze = (DateTime)Session["NoteReminderSnooze"];
                if (DateTime.Now.Subtract(snooze).TotalMinutes < Utilities.GetIntConfigValue("NoteReminderSnooze", 15))
                {
                    return;
                }
                Session.Remove("NoteReminderSnooze");
            }

            int reminderCount = new PRWebUserNoteMgr(_oLogger, _oUser).GetPendingNotificationsCount(_oUser.prwu_WebUserID, "BBOS");

            if (reminderCount > 0)
            {
                pnlNoteReminder.Visible = true;

                gvNotes.DataSource = new PRWebUserNoteMgr(_oLogger, _oUser).GetPendingNotifications(_oUser.prwu_WebUserID, "BBOS");
                gvNotes.DataBind();
                EnableBootstrapFormatting(gvNotes);
                mpeNoteReminder.Show();
            }
        }

        protected void dismissAll(object sender, EventArgs e)
        {
            IBusinessObjectSet notes = new PRWebUserNoteMgr(_oLogger, _oUser).GetPendingNotifications(_oUser.prwu_WebUserID, "BBOS");
            foreach (IPRWebUserNote note in notes)
            {
                note.DismissReminder(_oUser, "BBOS");
            }

            Response.Redirect(PageConstants.BBOS_HOME);
        }

        protected void dismissSelected(object sender, EventArgs e)
        {
            string noteIDList = GetRequestParameter("cbNote");
            IBusinessObjectSet notes = new PRWebUserNoteMgr(_oLogger, _oUser).GetByNoteIDList(noteIDList);
            foreach (IPRWebUserNote note in notes)
            {
                note.DismissReminder(_oUser, "BBOS");
            }
            Response.Redirect(PageConstants.BBOS_HOME);
        }

        protected void repWidgets_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if(e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                PRWebUserWidget oWidget = (PRWebUserWidget)e.Item.DataItem;
                PlaceHolder phWidget = (PlaceHolder)e.Item.FindControl("phWidget");
                string szWidgetFileName = string.Format("~/Widgets/{0}.ascx", oWidget.prwuw_WidgetCode);
                UserControlBase wuwControl = (UserControlBase)Page.LoadControl(szWidgetFileName);

                //UserControlHolder is a place holder on the aspx page where I want to load the
                //user control to.
                phWidget.Controls.Add(wuwControl);
            }
        }

        protected void btnLogoff_Click(object sender, EventArgs e)
        {
            FormsAuthentication.SignOut();
            Session.Abandon();
            Response.Redirect("#");
        }

        protected void btnCrossIndustry_Click(object sender, EventArgs e)
        {
            IPRWebUser oUserTemp = _oUser;
            _oUser = (IPRWebUser)Session["CrossIndustryUser"];
            Session["oUser"] = (IPRWebUser)Session["CrossIndustryUser"];
            _oUser.UpdateLoginStats();

            Session["CrossIndustryUser"] = oUserTemp;
            Response.Redirect(Request.RawUrl);
        }
    }
}