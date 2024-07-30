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

 ClassName: BBOS.Master (new version updated in 2023 BBOS9 upgrade)
 Description:

 Notes:

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;

using TSI.Arch;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    public partial class BBOS : MasterPage
    {
        protected StringBuilder _sbClientIDTranslation = null;
        protected const string CONTROL_ID_TRANSLATION = "var {0}=document.getElementById('{1}');\n";

        private IPRWebUser _webUser;
        private string _htmlTitle = string.Empty;
        private string _selectedMenu = string.Empty;

        protected string _googleTagProduce = string.Empty;
        protected string _googleTagLumber = string.Empty;

        protected void Page_Load(object sender, EventArgs e)
        {
            Page.Header.DataBind();

            PageBase oPage = (PageBase)contentMain.Page;

            if (oPage.EnableJSClientIDTranslation())
            {
                _sbClientIDTranslation = new StringBuilder();
                TranslateControls(Page.Master.FindControl("contentMain"));
                Page.ClientScript.RegisterStartupScript(this.GetType(), "ctrl_ids", _sbClientIDTranslation.ToString(), true);
            }

            // Footer Links
            hlPrivacy.NavigateUrl = oPage.GetMarketingSiteURL(Utilities.GetConfigValue("WebSitePrivacy"));

            if (string.IsNullOrEmpty(hlContactUs.NavigateUrl))
            {
                hlContactUs.NavigateUrl = Utilities.GetConfigValue("CorporateWebSite") + "/contact-us/";
            }

            _webUser = (IPRWebUser)Session["oUser"];
            if (_webUser != null)
            {
                memberName.Text = _webUser.FirstName;
                memberName2.Text = _webUser.Name;
                try
                {
                    accessLevel.Text = oPage.GetReferenceValue("prwu_AccessLevel", _webUser.prwu_AccessLevel);
                    accessLevel2.Text = oPage.GetReferenceValue("prwu_AccessLevel", _webUser.prwu_AccessLevel);
                } catch (ApplicationUnexpectedException) {
                    // We're going to eat this exception becuase it's on the master page which is also
                    // used by the Error page.  An exception here causes an exception loop due to the
                    // error page.
                    accessLevel.Text = string.Empty;
                }

                SystemMessages systemMsg = new SystemMessages(_webUser, LoggerFactory.GetLogger());
                List<string> systemMsgs = systemMsg.GetMessages();
                if (systemMsgs.Count > 0)
                {
                    bbsBadge.Visible = true;
                    litMessageCount.Text = systemMsgs.Count.ToString();
                }
                else
                    bbsBadge.Visible = false;
            }

            SetGoogleTags();

            SetApplicationMenu();

            if (!IsPostBack)
            {
                // show the top nav sidebar button only on these pages
                if (oPage is AdvancedCompanySearch ||
                    oPage is Company ||
                    oPage is CompanyARReports ||
                    oPage is CompanyBranches ||
                    oPage is CompanyClaimsActivity ||
                    oPage is CompanyContacts ||
                    oPage is CompanyCSG ||
                    oPage is CompanyNews ||
                    oPage is CompanyNotes ||
                    oPage is CompanyUpdates
                    )
                {
                    sidebar_offcanvas_toggle_button.Visible = true;
                }

                if (oPage.EnableGoogleAdServices())
                {
                    if (Utilities.GetBoolConfigValue("GoogleAdServicesEnabled", true))
                    {
                        string szGoogleAdServices = (string)HttpRuntime.Cache["GoogleAdServices"];
                        if (string.IsNullOrEmpty(szGoogleAdServices))
                        {
                            using (StreamReader srTemplate = new StreamReader(Server.MapPath(UIUtils.GetTemplateURL("GoogleAdServices.txt"))))
                            {
                                szGoogleAdServices = srTemplate.ReadToEnd();
                            }
                            HttpRuntime.Cache["GoogleAdServices"] = szGoogleAdServices;
                        }

                        litGoogleAdWords.Text = szGoogleAdServices;
                    }
                }

                string bodyStyle = Utilities.GetConfigValue("BodyStyle", string.Empty);
                if (!string.IsNullOrEmpty(bodyStyle))
                {
                    Body.Attributes.Add("class", bodyStyle);
                }

                if (_webUser != null)
                {
                    if (_webUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                    {
                        tdAdvertise.Visible = false;
                        SocialMedia.Visible = false;
                        hlSpecialServices.Visible = false;
                        hlLearningCenter.Visible = false;
                        hlBlueprints.Visible = false;
                        hlKnowYourCommodity.Visible = false;
                        hlBluebookReference.Visible = false;
                        hlNewHireAcademy.Visible    = false;
                        hlBlueprintFlipbook.Visible = false;
                        SocialMediaLumber.Visible = true;
                        hlAdvancedCompanySearch.Visible = false; //TODO:remove this once lumber has been fully implemented -- PT is deferring those screens until later
                        hlCompanyProfileViewsMenuItem.Visible = false; 
                    }

                    if (_webUser.prwu_Culture == PageBase.ENGLISH_CULTURE)
                    {
                        //Per Kathi, lumber users should not see Switch To Spanish option (#314)
                        if (_webUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                            divSwitchToSpanish.Visible = false;
                        else
                            divSwitchToSpanish.Visible = true;
                    }
                    else
                        divSwitchToEnglish.Visible = true;
                }
            }
        }

        /// <summary>
        /// Property to control the HTML title on the browser tab
        /// </summary>
        public string HTMLTitle
        {
            get { return _htmlTitle; }
            set
            {
                _htmlTitle = value;
                litHTMLTitle.Text = value;
            }
        }

        private void TranslateControls(Control oControl)
        {
            if (oControl.HasControls())
            {
                foreach (Control ctrl2 in oControl.Controls)
                {
                    TranslateControls(ctrl2);
                }
            }
            else
            {
                if (!string.IsNullOrEmpty(oControl.ID))
                {
                    if (oControl is CheckBox)
                    {
                        if (!string.IsNullOrEmpty(((CheckBox)oControl).Text))
                        {
                            _sbClientIDTranslation.Append(string.Format(CONTROL_ID_TRANSLATION, oControl.ID, oControl.ClientID));
                        }
                    }
                    else
                    {
                        _sbClientIDTranslation.Append(string.Format(CONTROL_ID_TRANSLATION, oControl.ID, oControl.ClientID));
                    }
                }
            }
        }

        protected void btnLogoffOnClick(object sender, EventArgs e)
        {
            Hashtable htSessionTracker = (Hashtable)Application[PageConstants.SESSION_TRACKER];
            if (htSessionTracker != null)
            {

                IPRWebUser oUser = (IPRWebUser)Session["oUser"];
                if (oUser != null)
                {
                    if (htSessionTracker.ContainsKey(oUser.prwu_WebUserID))
                    {
                        Application.Lock();
                        htSessionTracker.Remove(oUser.prwu_WebUserID);
                        Application.UnLock();

                        Response.Cookies[PageConstants.BBOS_SESSIONID].Expires = DateTime.Now.AddHours(-1);
                    }
                }
            }

            FormsAuthentication.SignOut();
            Session.Abandon();

            PageBase oPage = (PageBase)this.contentMain.Page;
            Response.Redirect(oPage.GetMarketingSiteURL(string.Empty));
        }


        /// <summary>
        /// If it's enabled, return the link to the public profile JS code that
        /// sets a cookie indicating this user has logged in to the BBOS.
        /// </summary>
        /// <returns></returns>
        protected string GetPublicProfileJS()
        {
            if (Utilities.GetBoolConfigValue("BBOSLoginRedirectEnabled", true))
            {
                return string.Format(UIUtils.JS_LINK, Utilities.GetConfigValue("BBOSPublicProfilesLoginJS"));
            }
            return string.Empty;
        }

        public void SetFooterContactUsURL(string url)
        {
            hlContactUs.NavigateUrl = url;
        }

        private const string GOOGLE_TAG_HEAD = @"<!-- Google Tag Manager -->
            <script>
                (function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src='https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);})(window,document,'script','dataLayer','INDUSTRY_CODE');
            </script>
            <!-- End Google Tag Manager -->";
        private const string GOOGLE_TAG_BODY = @"<!-- Google Tag Manager (noscript) -->
            <noscript><iframe src=https://www.googletagmanager.com/ns.html?id=INDUSTRY_CODE height='0' width='0' style='display:none;visibility:hidden'></iframe></noscript>
            <!-- End Google Tag Manager(noscript) -->";

        private void SetGoogleTags()
        {
            if (contentMain.Page is Login)
                return;
            if (_webUser == null)
                return;

            if (_googleTagProduce == string.Empty)
                _googleTagProduce = Utilities.GetConfigValue("GoogleTagProduce", "GTM-W5PZ7DX");
            if (_googleTagLumber == string.Empty)
                _googleTagLumber = Utilities.GetConfigValue("GoogleTagLumber", "GTM-PK37TQK");

            string szHead = GOOGLE_TAG_HEAD.Replace("INDUSTRY_CODE", _webUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER ? _googleTagLumber : _googleTagProduce);
            string szBody = GOOGLE_TAG_BODY.Replace("INDUSTRY_CODE", _webUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER ? _googleTagLumber : _googleTagProduce);

            contentGoogleTagHead.Visible = true;
            contentGoogleTagHead.Controls.Add(new LiteralControl(szHead));

            pnlGoogleTagBody.Visible = true;
            pnlGoogleTagBody.Controls.Add(new LiteralControl(szBody));
        }

        private void SetApplicationMenu()
        {
            hlSavedSearches.NavigateUrl = PageConstants.SAVED_SEARCHES;

            hlCompanyUpdateSearch.NavigateUrl = PageConstants.COMPANY_UPDATE_SEARCH;
            hlRecentViews.NavigateUrl = PageConstants.RECENT_VIEWS;
            hlLastCompanySearch.NavigateUrl = PageConstants.COMPANY_SEARCH_RESULTS_EXECUTE_LAST;

            hlClaimActivitySearch.NavigateUrl = PageConstants.CLAIMS_ACTIVITY_SEARCH;
            hlWatchdogLists.NavigateUrl = PageConstants.BROWSE_COMPANIES;
            hlNotes.NavigateUrl = PageConstants.BROWSE_NOTES;
            hlRequestBusinessValuation.NavigateUrl = PageConstants.BUSINESS_VALUATION;
            hlCustomFields.NavigateUrl = PageConstants.CUSTOM_FIELDS;
            hlPurchases.NavigateUrl = PageConstants.BROWSE_PURCHASES;
            hlAdditionalTools.NavigateUrl = PageConstants.DOWNLOADS;
            hlNewHireAcademy.NavigateUrl = PageConstants.NEW_HIRE_ACADEMY;

            hlMyMessageCenter.NavigateUrl = PageConstants.SYSTEM_MESSAGE;

            string szNewsUrl = Utilities.GetConfigValue("ProduceWebSite");
            if (_webUser?.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                szNewsUrl = Utilities.GetConfigValue("LumberWebSite");
                hlClaimActivitySearch.Visible = false;
            }

            hlNews.NavigateUrl = szNewsUrl;
            hlLearningCenter.NavigateUrl = PageConstants.LEARNING_CENTER;
            hlBlueprints.NavigateUrl = PageConstants.BLUEPRINTS;
            hlBluebookServices.NavigateUrl = PageConstants.BLUEBOOK_SERVICES;
            hlKnowYourCommodity.NavigateUrl = PageConstants.KNOW_YOUR_COMMODITY;
            hlBluebookReference.NavigateUrl = PageConstants.BLUEBOOK_REFERENCE;

            if (_webUser != null)
            {
                PRWebUserMgr oMgr = new PRWebUserMgr(LoggerFactory.GetLogger(), _webUser);
                hlRatingKeyNumerals.NavigateUrl = PageConstants.GET_PUBLICATION_FILE + "?PublicationArticleID=" + oMgr.GetRatingKeyNumeralsPublicationArticleID(_webUser.prwu_IndustryType, _webUser.prwu_Culture);
                hlRatingKeyNumerals.Target = "_blank";
            }

            hlSpecialServices.NavigateUrl = PageConstants.SPECIAL_SERVICES;
            hlTES.NavigateUrl = PageConstants.TES;

            //Store this link in session because it takes 2 database hits to retrieve, and this is on BBOS.Master so need to be efficient
            if (Session["CurrentBPEditionLink"] == null)
            {
                int iCurrentBPEditionID = PageControlBaseCommon.GetCurrentBluePrintsEdition();
                string strCurrentBPEditionLink = hlBlueprintFlipbook.NavigateUrl = PageControlBaseCommon.GetCurrentBluePrintsEditionLink(iCurrentBPEditionID);
                Session["CurrentBPEditionLink"] = strCurrentBPEditionLink;
                string strCurrentBPEditionCover = PageControlBaseCommon.GetCurrentBluePrintsEditionCover(iCurrentBPEditionID);
                Session["CurrentBPEditionCover"] = strCurrentBPEditionCover;
            }
            hlBlueprintFlipbook.NavigateUrl = (string)Session["CurrentBPEditionLink"];

            hlAccountSettings.NavigateUrl = PageConstants.USER_PROFILE;

            if (_webUser != null)
            {
                PageBase oPage = (PageBase)this.contentMain.Page;
                if (!oPage.GetObjectMgr().IsCompanyListed(_webUser.prwu_BBID))
                    hlMyCompanyProfile.NavigateUrl = string.Format(PageConstants.EMCW_COMPANY_LISTING, _webUser.prwu_BBID);
                else
                    hlMyCompanyProfile.NavigateUrl = string.Format(PageConstants.COMPANY, _webUser.prwu_BBID);

                hlCompanyProfileViews.NavigateUrl = PageConstants.COMANY_PROFILE_VIEWS;
            }

            hlManageAlerts.NavigateUrl = string.Format(PageConstants.USER_LIST, "AUS"); // tells that page to lookup the AUS list by default since a real listid isn't avail yet
            aBBOSHOME.HRef = PageConstants.BBOS_HOME;

            ApplySecurity(_webUser);
        }

        /// <summary>
        /// Disables menu options based on the specified user's
        /// security access and assigned roles.
        /// </summary>
        public void ApplySecurity(IPRWebUser webUser)
        {
            if (webUser == null)
            {
                return;
            }

            ApplySecurity(null, hlCompanySearch, SecurityMgr.Privilege.CompanySearchPage);
            
            ApplySecurity(null, hlPersonSearch, SecurityMgr.Privilege.PersonSearchPage);
            ApplySecurity(null, hlCompanyUpdateSearch, SecurityMgr.Privilege.CompanyUpdatesSearchPage);
            ApplySecurity(null, hlSavedSearches, SecurityMgr.Privilege.SaveSearches);
            ApplySecurity(null, hlRecentViews, SecurityMgr.Privilege.RecentViewsPage);
            ApplySecurity(null, hlLastCompanySearch, SecurityMgr.Privilege.CompanySearchPage);

            ApplySecurity(null, hlSpecialServices, SecurityMgr.Privilege.TradingAssistancePage);
            ApplySecurity(null, hlClaimActivitySearch, SecurityMgr.Privilege.ClaimActivitySearchPage);
            ApplySecurity(null, hlWatchdogLists, SecurityMgr.Privilege.WatchdogListsPage);
            ApplySecurity(null, hlNotes, SecurityMgr.Privilege.Notes);
            ApplySecurity(null, hlCustomFields, SecurityMgr.Privilege.CustomFields);
            ApplySecurity(null, hlPurchases, SecurityMgr.Privilege.PurchasesPage);
            ApplySecurity(null, hlAdditionalTools, SecurityMgr.Privilege.DownloadsPage);
            ApplySecurity(null, hlNews, SecurityMgr.Privilege.NewsPage);
            ApplySecurity(null, hlTES, SecurityMgr.Privilege.TradeExperienceSurveyPage);

            ApplySecurity(null, hlLearningCenter, SecurityMgr.Privilege.LearningCenterPage);
            ApplySecurity(null, hlBlueprints, SecurityMgr.Privilege.BlueprintsPage);
            ApplySecurity(null, hlBlueprintFlipbook, SecurityMgr.Privilege.BlueprintsPage);
            ApplySecurity(null, hlKnowYourCommodity, SecurityMgr.Privilege.KnowYourCommodityPage);
            ApplySecurity(null, hlBluebookReference, SecurityMgr.Privilege.ReferenceGuidePage);
            ApplySecurity(null, hlBluebookServices, SecurityMgr.Privilege.MembershipGuidePage);
            ApplySecurity(null, hlNewHireAcademy, SecurityMgr.Privilege.NewHireAcademyPage);

            if (webUser.IsLimitado)
            {
                //Override security application above and force Limitado into correct button enabling despite security privileges
                //so that applying 100 security / Limitado = true works properly
                hlClaimActivitySearch.Visible = false;
                hlPersonSearch.Visible = false;
                hlCompanyUpdateSearch.Visible = false;
                hlSavedSearches.Visible = false;
                hlSpecialServices.Visible = false;
                hlWatchdogLists.Visible = false;
                hlNotes.Visible = false;
                hlCustomFields.Visible = false;
                hlAdditionalTools.Visible = false;
                hlTES.Visible = false;
                hlLearningCenter.Visible = false;
                hlBluebookReference.Visible = false;
                hlBluebookServices.Visible = false;
                hlNewHireAcademy.Visible = false;
                hlMyMessageCenter.Visible = false;
                hlNews.Visible = false;

                hlManageAlerts.Visible = true;

                hlCompanySearch.Enabled = true;
                hlRecentViews.Enabled = true;
                hlLastCompanySearch.Enabled = true;
                hlPurchases.Enabled = true;
                hlBlueprints.Enabled = true;
                hlKnowYourCommodity.Enabled = true;
                hlBlueprintFlipbook.Enabled = true;
                hlAccountSettings.Enabled = true;
                hlMyCompanyProfile.Enabled = true;
                hlRatingKeyNumerals.Enabled = true;
            }

            if (webUser.prwu_LastCompanySearchID == 0)
            {
                hlLastCompanySearch.Enabled = false;
            }

            if ((webUser.prwu_PersonLinkID == 0) ||
                (webUser.prwu_BBID == 0))
            {
                DisableMenuItem(hlSpecialServices);
            }

            //Hide Company Search except for Lumber
            if (_webUser.prwu_IndustryType != GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                liCompanySearch.Visible = false;
            }

            PageBase.ApplyReadOnlyCheck(hlCustomFields);
        }

        protected void btnCompanySearchOnClick(object sender, EventArgs e)
        {
            if (_webUser == null)
            {
                if (Session["oUser"] == null)
                {
                    Response.Redirect(PageConstants.BBOS_HOME);
                    return;
                }

                _webUser = (IPRWebUser)Session["oUser"];
            }


            Session["oWebUserSearchCriteria"] = null;
            if (!string.IsNullOrEmpty(_webUser.prwu_DefaultCompanySearchPage))
            {
                Response.Redirect(_webUser.prwu_DefaultCompanySearchPage);
            }
            else
            {
                if(_webUser.IsLimitado)
                    Response.Redirect(PageConstants.LIMITADO_SEARCH);
                else
                    Response.Redirect(PageConstants.COMPANY_SEARCH);
            }
        }

        protected void btnPersonSearchOnClick(object sender, EventArgs e)
        {
            Session["oWebUserSearchCriteria"] = null;
            Response.Redirect(PageConstants.PERSON_SEARCH);
        }

        protected void ApplySecurity(Control containerControl, Control actionControl, SecurityMgr.Privilege privilege)
        {
            SecurityMgr.SecurityResult result = _webUser.HasPrivilege(privilege);
            if (containerControl != null)
                containerControl.Visible = result.Visible;

            if (actionControl != null)
            {
                if (actionControl is WebControl)
                {
                    ((WebControl)actionControl).Enabled = result.Enabled;
                    if (actionControl is HyperLink)
                    {
                        if (!((HyperLink)actionControl).Enabled)
                        {
                            ((HyperLink)actionControl).NavigateUrl = "";
                            ((HyperLink)actionControl).CssClass += " disabled";
                        }
                    }
                    else if (actionControl is LinkButton)
                    {
                        if (!((LinkButton)actionControl).Enabled)
                        {
                            ((LinkButton)actionControl).PostBackUrl = "";
                            ((LinkButton)actionControl).CssClass += " disabled";
                        }
                    }
                }
                else
                {
                    ((HtmlControl)actionControl).Disabled = result.Enabled;
                }
            }
        }

        protected void DisableMenuItem(HyperLink hlMenuItem)
        {
            hlMenuItem.Enabled = false;
            hlMenuItem.CssClass = "disabled";
        }

        protected void DisableMenuItem(LinkButton hlMenuItem)
        {
            hlMenuItem.Enabled = false;
            hlMenuItem.CssClass = "disabled";
        }

        protected void btnSwitchToEnglish_Click(object sender, EventArgs e)
        {
            _webUser.prwu_Culture = PageBase.ENGLISH_CULTURE;
            _webUser.prwu_UICulture = PageBase.ENGLISH_CULTURE;

            _webUser.Save();
            SetCulture(_webUser);

            ResetCompanyDataSession();
            ResetCompanyDataNewsSession();

            HttpContext.Current.Session[SESSION_BBSCORE_HISTORY_BBID] = null;

            Response.Redirect(Request.RawUrl);
        }

        protected void btnSwitchToSpanish_Click(object sender, EventArgs e)
        {
            _webUser.prwu_Culture = PageBase.SPANISH_CULTURE;
            _webUser.prwu_UICulture = PageBase.SPANISH_CULTURE;

            _webUser.Save();
            SetCulture(_webUser);
            ResetCompanyDataSession();
            ResetCompanyDataNewsSession();

            HttpContext.Current.Session[SESSION_BBSCORE_HISTORY_BBID] = null;
            Response.Redirect(Request.RawUrl);
        }

        protected void btnTermsAndConditionsOnClick(object sender, EventArgs e)
        {
            Session["MembershipSummary"] = "Y";
            Session["IsMembership"] = null;
            Response.Redirect(PageConstants.TERMS);
        }

        protected void btnMembershipAgreementOnClick(object sender, EventArgs e)
        {
            Session["MembershipSummary"] = "Y";
            Session["IsMembership"] = "Y";
            Response.Redirect(PageConstants.TERMS);
        }

        public void DisplayReturnToSearch()
        {
            string szReturnURL = (string)Session["ReturnURL"] ?? String.Empty;
            if (!string.IsNullOrEmpty(szReturnURL) && szReturnURL == PageConstants.COMPANY_SEARCH_RESULTS_EXECUTE_LAST)
            {
                hlReturntoSearch.Visible = true;
                hlReturntoSearch.HRef = szReturnURL;
            }
        }

        public string SelectedMenu
        {
            set
            {
                _selectedMenu = value;
            }
            get
            {
                return _selectedMenu.ToLower();
            }
        }

        public string SelectedMenuClass(string szButtonID)
        {
            if (szButtonID.ToLower() == SelectedMenu)
                return "selected";
            else
                return "";
        }

        protected void hlAdvancedCompanySearch_Click(object sender, EventArgs e)
        {
            if (_webUser == null)
            {
                if (Session["oUser"] == null)
                {
                    Response.Redirect(PageConstants.BBOS_HOME);
                    return;
                }

                _webUser = (IPRWebUser)Session["oUser"];
            }


            Session["oWebUserSearchCriteria"] = null;
            if (_webUser.IsLimitado)
                Response.Redirect(PageConstants.LIMITADO_SEARCH);
            else
                Response.Redirect(PageConstants.ADVANCED_COMPANY_SEARCH);
        }

        public void HideOldTopMenu()
        {
            divOldTopMenu.Attributes.CssStyle.Add("display", "none");
        }

        protected void btnHelp_ServerClick(object sender, EventArgs e)
        {
            Response.Redirect(Utilities.GetConfigValue("CorporateWebSite") + "/contact-us/");
        }
    }
}

namespace System.Runtime.CompilerServices
{
    //https://stackoverflow.com/questions/64749385/predefined-type-system-runtime-compilerservices-isexternalinit-is-not-defined
    internal static class IsExternalInit { }
}
