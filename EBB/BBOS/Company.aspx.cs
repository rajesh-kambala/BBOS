/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: Company
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using PRCo.EBB.BusinessObjects;
using System;
using System.Collections;
using System.Data;
using System.Diagnostics;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.UI.WebControls;
using TSI.BusinessObjects;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Displays company data and listing.
    /// </summary>
    public partial class Company : CompanyDetailsBase
    {
        protected CompanyData _ocd;
        protected CompanyDataNews _ocdn;

        public static string RUN_ONCE_SCRIPT_IDENTIFIER = "abcdef";

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
            Page.Title = Resources.Global.BlueBookService;
            ((BBOS)Master).HideOldTopMenu();

            var sw = new Stopwatch();

            if (!IsPostBack)
            {
                sw.Restart();
                hidCompanyID.Text = GetRequestParameter("CompanyID", true, true);
                Session["ReturnURL"] = PageConstants.Format(PageConstants.COMPANY, hidCompanyID.Text);

                GetOcd();

                if (HandleLumberRedirect(_ocd.szIndustryType, hidCompanyID.Text))
                    return;

                PopulateForm();
                ApplySecurity();

                LogTimer(sw, "Company.aspx !PostBack");
                sw.Restart();
            }

            RedirectToHomeIfCompanyMissing(hidCompanyID.Text);

            //Set user controls
            ucSidebar.WebUser = _oUser;
            ucSidebar.CompanyID = UIUtils.GetString(hidCompanyID.Text);
            ucCompanyHero.WebUser = _oUser;
            ucCompanyHero.CompanyID = UIUtils.GetString(hidCompanyID.Text);
            ucCompanyBio.WebUser = _oUser;
            ucCompanyBio.CompanyID = UIUtils.GetString(hidCompanyID.Text);

            ucPinnedNote.WebUser = _oUser;
            ucPinnedNote.companyID = UIUtils.GetInt(hidCompanyID.Text);
            LogTimer(sw, "Company.aspx PinnedNote");
            sw.Restart();

            ucCompanyListing.WebUser = _oUser;
            ucCompanyListing.companyID = hidCompanyID.Text;
            LogTimer(sw, "Company.aspx Company Listing");
            sw.Restart();

            ucPerformanceIndicators.WebUser = _oUser;
            ucPerformanceIndicators.HQID = hidCompanyID.Text;
            LogTimer(sw, "Company.aspx PerformanceIndicators");
            sw.Restart();

            //ucNewsArticles lazy-loaded in PreRender

            //ucLocalSource lazy-loaded in PreRender
            //ucTradeAssociation lazy-loaded in PreRender
            //ucClassifications lazy-loaded in PreRender
            //ucCommoditiesList lazy-loaded in PreRender
            //ucCustomData lazy-loaded in PreRender
            
            sw.Stop();

            PopulateBBScoreChart();
        }

        private void PopulateBBScoreChart()
        {
            if (GetOcd().szBBScore != "" && GetOcd().bBBScorePublished && GetOcd().bCompBBScorePublished)
            {
                if (!Utilities.GetBoolConfigValue("BBScoreChartEnabled", false))
                {
                    litCreditScore.Visible = true;
                }
                else
                {
                    litCreditScore.Visible = false;
                    ucBBScoreChart.industry = _ocd.szIndustryType;
                    PageControlBaseCommon.PopulateBBScoreChart(UIUtils.GetInt(_ocd.szCompanyID), _ocd.szIndustryType, ucBBScoreChart.chart, ucBBScoreChart.bbScoreImage, ucBBScoreChart.bbScoreLiteral, _oUser.prwu_AccessLevel, Convert.ToDecimal(_ocd.szBBScore).ToString("###"), _oUser.prwu_Culture, _ocd.szBBScoreModel);
                }
            }
            else
            {
                PageControlBaseCommon.SetBBScoreChartSession(UIUtils.GetInt(_ocd.szCompanyID), _ocd.szIndustryType, _oUser.prwu_AccessLevel, _oUser.prwu_Culture);
            }
        }

        protected override string GetCompanyID()
        {
            if (IsPostBack)
            {
                return hidCompanyID.Text;
            }
            else
            {
                return GetRequestParameter("CompanyID");
            }
        }

        protected override CompanyDetailsHeader GetCompanyDetailsHeader()
        {
            return ucCompanyDetailsHeader;
        }

        /// <summary>
        /// Populates the form controls for the specified
        /// company
        /// </summary>
        protected void PopulateForm()
        {
            //Company Details
            LoadCompanyDetails();

            //Licenses
            repLicenses.DataSource = _ocd.dtLicenses;
            repLicenses.DataBind();
            //Volume
            repVolume.DataSource = _ocd.dtVolume;
            repVolume.DataBind();

            //Map
            string szEmbeddedMap = "";
            string szLocation = GetAddressForMap(GetCompanyID(), out szEmbeddedMap);
            ifMap.Attributes["src"] = szEmbeddedMap;
            divMap.Visible = true;

            //LocalSource
            if (_ocd.bLocalSource)
            {
                ucCompanyDetailsHeaderMeister.MeisterVisible = true;
            }

            if (_ocd.decAveIntegrity == 0)
                divTradeReportRiskInsight.Visible = false;

            PopulateKeyUpdates();

            if (litCreditScore.Text == "N/A")
            {
                divInsight.Visible = false;
            }
        }

        public void LoadCompanyDetails()
        {
            GetOcd(); //Get base _ocdn without news datatable since that needs to be background thread

            if (_ocd.szIndustryType != GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                if (_ocd.szIsHQRating == "Y")
                {
                    litRatingLabel.Text = "HQ Rating";
                }

                if (_oUser != null && _oUser.HasPrivilege(SecurityMgr.Privilege.ViewRating).HasPrivilege)
                {
                    lblRating.Text = _ocd.szRatingLine;
                    if (_ocd.dtPRRA_DateTime == DateTime.MinValue)
                    {
                        pnlRatingDate.Visible = false;
                        pnlRatingDate2.Visible = true;
                    }
                    else
                    {
                        pnlRatingDate.Visible = true;
                        pnlRatingDate2.Visible = false;

                        litRatingDate.Text = _ocd.dtPRRA_DateTime.ToString("M/d/yyyy"); //ex: as of 4/5/2018
                    }
                }
            }

            SecurityMgr.SecurityResult privBBScore = _oUser.HasPrivilege(SecurityMgr.Privilege.ViewBBScore);
            trCreditScore.Visible = privBBScore.Visible;

            if (privBBScore.HasPrivilege)
            {
                ApplySecurity(null, btnViewBBScoreHistory, SecurityMgr.Privilege.ViewBBScoreHistory);
                if (!_oUser.HasPrivilege(SecurityMgr.Privilege.ViewBBScoreHistory).HasPrivilege)
                {
                    btnViewBBScoreHistory.Visible = false;
                    btnBBScoreHistoryInsight.Visible = false;
                }

                //prbs_PRPublish
                if (_ocd.szBBScore != "" && _ocd.bBBScorePublished && _ocd.bCompBBScorePublished)
                {
                    litCreditScore.Text = Convert.ToDecimal(_ocd.szBBScore).ToString("###");
                    lblCreditScore.Text = Convert.ToDecimal(_ocd.szBBScore).ToString("###");
                    litCreditScore.Visible = false;
                }
                else
                {
                    litCreditScore.Text = Resources.Global.NotApplicableAbbr;
                    lblCreditScore.Visible = false;
                }
            }
            else
            {
                trCreditScore.Disabled = true;
            }

            if (!_oUser.HasPrivilege(SecurityMgr.Privilege.ViewRatingHistory).HasPrivilege)
            {
                btnRatingHistory.Visible = false;
                btnRatingHistory2.Visible = false;
            }

            //Get BBScore since: date from session variable
            litCreditScoreDate.Text = GetCreditScoreDate();

            //Other Information Section
            // Business Start
            litBusinessStartDateState.Text = string.Format("{0} {1}", _ocd.BusinessStartDate, _ocd.BusinessStartState);
            if (_ocd.szCompanyType == "B")
                litBusinessStartDateStateTitle.Text = "HQ " + Resources.Global.BusinessDateState;
            //Bank
            if (!string.IsNullOrEmpty(_ocd.szBank))
                litBank.Text = _ocd.szBank;
            else
                litBank.Text = "N/A";

            PopulateSocialMedia(UIUtils.GetInt(_ocd.szCompanyID), _ocd.szPreparedName, _ocd.bSuppressLinkedInWidget);
        }

        public CompanyData GetOcd()
        {
            if(_ocd == null)
                _ocd = PageControlBaseCommon.GetCompanyData(hidCompanyID.Text, _oUser, GetDBAccess(), GetObjectMgr());
            return _ocd;
        }
        
        public CompanyDataNews GetOcdNews()
        {
            if (_ocdn == null)
                _ocdn = PageControlBaseCommon.GetCompanyDataNews(hidCompanyID.Text, _oUser, GetDBAccess(), GetObjectMgr());
            return _ocdn;
        }


        public string GetCreditScoreDate()
        {
            if (HttpContext.Current.Session[SESSION_BBSCORE_HISTORY_DS] != null)
            {
                DataSet dsBBScoreHistory_Session = null;
                dsBBScoreHistory_Session = (DataSet)HttpContext.Current.Session[SESSION_BBSCORE_HISTORY_DS];

                foreach (DataRow dr in dsBBScoreHistory_Session.Tables[0].Rows)
                {
                    if (dr["RN"].ToString() == "1")
                    {
                        return ((DateTime)dr["RunDate"]).ToString("M/d/yyyy"); //ex: as of 4/5/2018
                    }
                }
            }

            return "";
        }

        protected const string SQL_CLASSIFICATIONS_LEVEL1_SELECT =
        @"SELECT DISTINCT b.{0} As Level1
                FROM PRCompanyClassification WITH (NOLOCK) 
                INNER JOIN PRClassification a WITH (NOLOCK) ON prc2_ClassificationID = prcl_ClassificationID 
                INNER JOIN PRClassification b WITH (NOLOCK) ON CASE WHEN CHARINDEX(',', a.prcl_Path) = 0 THEN a.prcl_Path ELSE LEFT(a.prcl_Path, CHARINDEX(',', a.prcl_Path)-1) END = b.prcl_ClassificationID";

        protected const string SQL_CLASSIFICATIONS_WHERE = " WHERE prc2_CompanyID = {0}";

        protected const string SQL_KEY_UPDATES =
            @" SELECT DISTINCT prrn_Name, CASE
								WHEN LOWER(@Culture) = 'es-mx' THEN CAST(Capt_ES AS VARCHAR(500))
								ELSE CAST(Capt_US AS VARCHAR(500))
							END AS prrn_Desc
                  FROM PRRatingNumeralAssigned WITH (NOLOCK)
                       INNER JOIN PRRatingNumeral WITH (NOLOCK) ON pran_RatingNumeralId = prrn_RatingNumeralId 
                       INNER JOIN PRRating WITH (NOLOCK) ON pran_RatingId = prra_RatingId 
                       INNER JOIN Custom_Captions cc WITH (NOLOCK) ON Capt_FamilyType = 'Choices' AND Capt_Family = 'prrn_Name' AND Capt_Code = prrn_Name
                 WHERE prra_CompanyId = @CompanyID
                   AND prra_Current = 'Y'
                   AND prra_Deleted IS NULL";
        
        protected const string SQL_KEY_UPDATES_INSIGHTS =
            @"  SELECT DISTINCT prrn_Name, CASE
								WHEN LOWER(@Culture) = 'es-mx' THEN CAST(Capt_ES AS VARCHAR(500))
								ELSE CAST(Capt_US AS VARCHAR(500))
							END AS prrn_Insight
                  FROM PRRatingNumeralAssigned WITH (NOLOCK)
                       INNER JOIN PRRatingNumeral WITH (NOLOCK) ON pran_RatingNumeralId = prrn_RatingNumeralId 
                       INNER JOIN PRRating WITH (NOLOCK) ON pran_RatingId = prra_RatingId 
                       INNER JOIN Custom_Captions cc WITH (NOLOCK) ON Capt_FamilyType = 'Choices' AND Capt_Family = 'prrn_Name_Insight' AND Capt_Code = prrn_Name
                 WHERE prra_CompanyId = @CompanyID
                   AND prra_Current = 'Y'
                   AND prra_Deleted IS NULL";

        protected void PopulateKeyUpdates()
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", _ocd.szCompanyID));
            oParameters.Add(new ObjectParameter("Culture", _oUser.prwu_Culture));

            repKeyUpdates.DataSource = GetDBAccess().ExecuteReader(SQL_KEY_UPDATES, oParameters, CommandBehavior.CloseConnection, null);
            repKeyUpdates.DataBind();
            
            repKeyUpdatesInsight.DataSource = GetDBAccess().ExecuteReader(SQL_KEY_UPDATES_INSIGHTS, oParameters, CommandBehavior.CloseConnection, null);
            repKeyUpdatesInsight.DataBind();
        }

        /// <summary>
        /// Apply security to the various screen components
        /// based on the current user's access level and role.
        /// </summary>
        protected void ApplySecurity()
        {
            ApplyReadOnlyCheck(btnSubmitTES);

            if (!_oUser.HasPrivilege(SecurityMgr.Privilege.ViewRatingHistory).HasPrivilege)
                btnSeeTradeActivityHistory.Visible = false;
        }

        override protected bool IsAuthorizedForPage()
        {
            return _oUser.IsLimitado || _oUser.HasPrivilege(SecurityMgr.Privilege.CompanyDetailsListingPage).Enabled;
        }

        public string GetCompanyTypeName(string szType)
        {
            switch (szType)
            {
                case "LS":
                    return Resources.Global.LocalSourceData;
                case "H":
                    return Resources.Global.Headquarter;
                case "B":
                    return Resources.Global.Branch;
            }
            return "";
        }

        public string GetAffiliationCount()
        {
            return GetOcd().dtAffiliation.Rows.Count.ToString();
        }
        public string GetBranchCount()
        {
            return GetOcd().dtBranch.Rows.Count.ToString();
        }

        //protected void btnUpdateCustomData_ServerClick(object sender, EventArgs e)
        //{
        //    if (ucCustomData != null)
        //        ucCustomData.btnEditCustomFields_Click(sender, e);
        //}

        protected void upnlBusinessDetails_PreRender(object sender, EventArgs e)
        {
            var sw = new Stopwatch();

            sw.Restart();
            ucLocalSource.WebUser = _oUser;
            ucLocalSource.companyID = UIUtils.GetInt(hidCompanyID.Text);
            LogTimer(sw, "LocalSource Lazy Load");

            sw.Restart();
            ucTradeAssociation.WebUser = _oUser;
            ucTradeAssociation.companyID = hidCompanyID.Text;
            LogTimer(sw, "TradeAssociation Lazy Load");

            sw.Restart();
            ucClassifications.WebUser = _oUser;
            ucClassifications.CompanyID = hidCompanyID.Text;
            LogTimer(sw, "Classifications Lazy Load");

            sw.Restart();
            if (_ocd.szIndustryType == GeneralDataMgr.INDUSTRY_TYPE_TRANSPORTATION ||
               _ocd.szIndustryType == GeneralDataMgr.INDUSTRY_TYPE_SUPPLY)
            {
                ucCommoditiesList.Visible = false;
            }
            else
            {
                ucCommoditiesList.Visible = false;
                ucCommoditiesList.WebUser = _oUser;
                ucCommoditiesList.IndustryType = GetOcd().szIndustryType;
                ucCommoditiesList.CompanyID = hidCompanyID.Text;
                LogTimer(sw, "Commodities Lazy Load");
                ucCommoditiesList.Visible = true;
            }

            sw.Restart();

            ucCustomData.WebUser = _oUser;
            ucCustomData.companyID = hidCompanyID.Text;

            LogTimer(sw, "CustomData Lazy Load");
            sw.Stop();
        }

        protected void upnlNews_PreRender(object sender, EventArgs e)
        {
            var sw = new Stopwatch();

            if (Request["__EVENTTARGET"] == upnlNews.ClientID &&
                Request.Form["__EVENTARGUMENT"] == RUN_ONCE_SCRIPT_IDENTIFIER)
            {
                GetOcdNews();

                sw.Restart();
                ucNewsArticles.Visible = false;
                ucNewsArticles.WebUser = _oUser;
                ucNewsArticles.companyID = hidCompanyID.Text;
                ucNewsArticles.Title = Resources.Global.NewsArticles; //"News/Articles";
                ucNewsArticles.Style = NewsArticles.NewsType.GENERAL_NEWS_SUMMARY;
                ucNewsArticles.PopulateNewsArticles(_ocdn);

                if (ucNewsArticles.NewsCount > 0)
                    ucNewsArticles.Visible = _oUser.HasPrivilege(SecurityMgr.Privilege.CompanyDetailsNewsPage).Enabled;
                else
                    ucNewsArticles.Visible = false;

                LogTimer(sw, "News Lazy Load");
            }
        }

        protected void repLicenses_ItemDataBound(object sender, System.Web.UI.WebControls.RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == System.Web.UI.WebControls.ListItemType.Item || e.Item.ItemType == System.Web.UI.WebControls.ListItemType.AlternatingItem)
            {
                Literal litName = (Literal)e.Item.FindControl("litName");
                Literal litLicense = (Literal)e.Item.FindControl("litLicense");
                DataRowView row = (DataRowView)e.Item.DataItem;

                string szName = row["Name"].ToString();
                string szLicense = row["License"].ToString();

                if (szName.ToLower() == "drc")
                {
                    litName.Text = $"DRC {Resources.Global.Member}";
                    litLicense.Text = $"{Resources.Global.Yes}";
                }
                else
                {
                    litName.Text = $"{Resources.Global.LicenciaDe}{szName} {Resources.Global.LicenseNumberShort}";
                    litLicense.Text = $"{szLicense}";
                }
            }
        }

        #region Social Media
        protected const string SOCIAL_MEDIA_CELL =
            "<td align=\"center\"><a href=\"{0}\" target=\"_blank\"><img src=\"{1}\" alt=\"{2}\" border=\"0\" /></a></td>";
        protected const string SQL_SOCIAL_MEDIA =
            "SELECT prsm_SocialMediaID, prsm_SocialMediaTypeCode, dbo.ufn_GetCustomCaptionValue('prsm_SocialMediaTypeCode', prsm_SocialMediaTypeCode, 'en-us') As SocialMediaType, prsm_URL FROM PRSocialMedia WITH (NOLOCK) WHERE prsm_CompanyID=@CompanyID AND prsm_Disabled IS NULL";
        protected void PopulateSocialMedia(int companyID,
                                           string companyName,
                                           bool suppresLinkedInWidget)
        {
            if (!Utilities.GetBoolConfigValue("SocialMediaEnabled", true))
            {
                //trSocialMedia.Visible = false;
                return;
            }

            StringBuilder sbSocialMedia = new StringBuilder();

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", companyID));

            int maxColumns = Utilities.GetIntConfigValue("SocialMediaColumnCount", 5);
            int colCount = 0;

            sbSocialMedia.Append("<table>");

            IDataReader oReader = GetDBAccess().ExecuteReader(SQL_SOCIAL_MEDIA, oParameters, CommandBehavior.CloseConnection, null);
            try
            {
                while (oReader.Read())
                {
                    if (colCount == 0)
                    {
                        sbSocialMedia.Append("<tr>");
                    }

                    string szURL = Utilities.GetConfigValue("VirtualPath") + PageConstants.Format(PageConstants.EXTERNAL_LINK_TRIGGER, Server.UrlEncode(oReader.GetString(3)), companyID, "C", Request.ServerVariables.Get("SCRIPT_NAME"));
                    sbSocialMedia.Append(string.Format(SOCIAL_MEDIA_CELL,
                                                       szURL,
                                                       UIUtils.GetImageURL(oReader.GetString(1) + ".png"),
                                                       oReader.GetString(2)));

                    colCount++;

                    if (colCount >= maxColumns)
                    {
                        colCount = 0;
                        sbSocialMedia.Append("</tr>");
                    }
                }
            }
            finally
            {
                oReader.Close();
            }

            if (colCount > 0)
            {
                sbSocialMedia.Append("</tr>");
            }
            sbSocialMedia.Append("</table>");

            litSocialMedia.Text = sbSocialMedia.ToString();
        }
        #endregion
    }
}