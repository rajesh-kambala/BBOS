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

 ClassName: CompanyDetailsHeader
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Data;
using PRCo.EBB.BusinessObjects;
using TSI.Utils;
using System.Collections;
using TSI.BusinessObjects;
using System.Text;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// User control that displays the company header, or "banner" information
    /// on each of the company detail pages.
    /// 
    /// NOTE: This user control is also being used to display the company header information
    /// on each of the edit my company wizard pages.
    /// </summary>
    public partial class CompanyDetails : UserControlBase
    {
        //protected string _szLocation = null;
        protected string _szCompanyID;
        protected bool _bPadding = false;
        protected bool _bLimitadoSimplified = false;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if (!Page.IsPostBack)
            {
                if (Padding)
                {
                    pCompanyDetails.Attributes.Add("class", pCompanyDetails.Attributes["class"] + " padding_lr_15");
                }

                //Put off-screen to fix flicker issue in defect 6777
                pnlPayIndicator.Style["left"] = "-500px";
                pnlPayIndicator.Style["top"] = "-500px";
            }
        }

        /// <summary>
        /// Populates the header.
        /// </summary>
        /// <param name="szCompanyID"></param>
        /// <param name="oWebUser"></param>
        public void LoadCompanyHeader(string szCompanyID, IPRWebUser oWebUser)
        {
            _szCompanyID = szCompanyID;
            CompanyData ocd = GetCompanyData(szCompanyID, oWebUser, GetDBAccess(), GetObjectMgr());
        }

        /// <summary>
        /// Make this string publically available for 
        /// use on the parent pages.
        /// </summary>
        public string Location
        {
            get
            {
                CompanyData ocd = GetCompanyData(_szCompanyID, WebUser, GetDBAccess(), GetObjectMgr());
                return ocd.szLocation;
            }
        }

        public string companyID
        {
            set
            {
                _szCompanyID = value;
                LoadCompanyDetails(WebUser);
            }
            get { return _szCompanyID; }
        }

        public bool Padding
        {
            set { _bPadding = value; }
            get { return _bPadding; }
        }

        public bool LimitadoSimplified
        {
            set { _bLimitadoSimplified = value; }
            get { return _bLimitadoSimplified; }
        }


        /// <summary>
        /// Populates the header.
        /// </summary>
        public void LoadCompanyDetails(IPRWebUser oWebUser)
        {
            CompanyData ocd = GetCompanyData(companyID, oWebUser, GetDBAccess(), GetObjectMgr());

            litTitle.Text = Resources.Global.Details;

            if (ocd.szIndustryType != GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                if (ocd.szIsHQRating == "Y")
                {
                    litRatingLabel.Text = "HQ Rating";
                }

                if (WebUser != null && WebUser.HasPrivilege(SecurityMgr.Privilege.ViewRating).HasPrivilege)
                {
                    lblRating.Text = ocd.szRatingLine;
                    if (ocd.dtPRRA_DateTime == DateTime.MinValue)
                    {
                        pnlRatingDate.Visible = false;
                        pnlRatingDate2.Visible = true;
                    }
                    else
                    {
                        pnlRatingDate.Visible = true;
                        pnlRatingDate2.Visible = false;

                        lblRatingDate.Text = string.Format("{0} {1}", Resources.Global.Since, ocd.dtPRRA_DateTime.ToString("M/d/yyyy")); //ex: as of 4/5/2018
                    }
                }

                hidRatingID.Text = ocd.iRatingID.ToString();
                pdeRating.ContextKey = ocd.iRatingID.ToString();

                trCreditWorthRating.Visible = false;
                trRatingNumeral.Visible = false;
                trPayReportCount.Visible = false;
                trPayIndicator.Visible = false;
                trIndustry.Visible = true;
            }
            else
            {
                trRating.Visible = false;

                if (WebUser.HasPrivilege(SecurityMgr.Privilege.ViewRating).HasPrivilege)
                {
                    lblCreditWorthRating.Text = ocd.szCreditWorthRating; 
                    lblRatingNumeral.Text = ocd.szAssignedRatingNumerals; 
                }
                else if (WebUser.IsLumber_BASIC() || WebUser.IsLumber_BASIC_PLUS())
                {
                    //Defect 6818 alternate "Upgrade to view" link for Basic Lumber users
                    lblCreditWorthRating2.Text = string.Format("<a href='MembershipSelect.aspx'>{0}</a>", Resources.Global.UpgradeToView);
                    lblRatingNumeral2.Text = string.Format("<a href='MembershipSelect.aspx'>{0}</a>", Resources.Global.UpgradeToView);

                    lblCreditWorthRating2.Visible = true;
                    lblRatingNumeral2.Visible = true;
                    lblCreditWorthRating.Visible = false;
                    lblRatingNumeral.Visible = false;
                }


                if ((WebUser.HasPrivilege(SecurityMgr.Privilege.CompanyDetailsARReportsPage).HasPrivilege) &&
                    ocd.iPayReportCount > 0) 
                {
                    hlPayReportCount.Text = ocd.iPayReportCount.ToString(); 
                    hlPayReportCount.NavigateUrl = PageConstants.FormatFromRoot(PageConstants.COMPANY_DETAILS_AR_REPORTS, companyID);
                }
                else
                {
                    if (WebUser.HasPrivilege(SecurityMgr.Privilege.CompanyDetailsARReportsPage).HasPrivilege)
                    {
                        litPayReportCount.Text = ocd.iPayReportCount.ToString(); 
                    }
                    else
                    {
                        hlPayReportCount.Text = ocd.iPayReportCount.ToString();
                        hlPayReportCount.NavigateUrl = PageConstants.FormatFromRoot(PageConstants.EXTERNAL_LINK_TRIGGER, Configuration.ARReportsMarketingPageLumber, companyID, "C", Request.ServerVariables.Get("SCRIPT_NAME"));
                        hlPayReportCount.Target = "_blank";
                    }
                }

                if (WebUser.HasPrivilege(SecurityMgr.Privilege.ViewPayIndicator).HasPrivilege)
                {
                    if (ocd.bPublishPayIndicator)
                    {
                        lblPayIndicator.Text = ocd.szPayIndicator; 
                        dpePayIndicator.ContextKey = ocd.iCompanyPayIndicatorID.ToString();
                    }
                }
                else if (WebUser.IsLumber_BASIC() || WebUser.IsLumber_BASIC_PLUS())
                {
                    //Defect 6818 alternate "Upgrade to view" link for Basic Lumber users
                    lblPayIndicator2.Text = string.Format("<a href='MembershipSelect.aspx'>{0}</a>", Resources.Global.UpgradeToView);
                    lblPayIndicator2.Visible = true;
                    lblPayIndicator.Visible = false;
                }

                dpeCreditWorthRating.ContextKey = ocd.iRatingID.ToString();
                dpeRatingNumeral.ContextKey = ocd.iRatingID.ToString();
                trIndustry.Visible = false;
            }

            litIndustry.Text = ocd.szIndustryTypeName;
            litType.Text = GetCompanyType(ocd.szCompanyType, ocd.bLocalSource);
            switch(litType.Text)
            {
                case "LS":
                    litType.Text = Resources.Global.LocalSourceData; // "Local Source"
                    break;
                case "H":
                    litType.Text = Resources.Global.Headquarter; 
                    break;
                case "B":
                    litType.Text = Resources.Global.Branch; 
                    break;
            }
                

            if (ocd.szListingStatus == "N3" ||
                ocd.szListingStatus == "N5" ||
                ocd.szListingStatus == "N6")
            {
                litStatus.Text = Resources.Global.PreviouslyListed;
            }
            else
            {
                litStatus.Text = ocd.szListingStatusName;
            }

            litPhone.Text = ocd.szPhone;
            litFax.Text = ocd.szFax;

            // Business Start
            litBusinessStartDateState.Text = string.Format("{0} {1}", ocd.BusinessStartDate, ocd.BusinessStartState);
            if (ocd.szCompanyType == "B")
                litBusinessStartDateStateTitle.Text = "HQ " + Resources.Global.BusinessDateState;
            

            hlEmail.Text = ocd.szEmailAddress;
            if (!string.IsNullOrEmpty(hlEmail.Text))
            {
                hlEmail.NavigateUrl = "mailto:" + hlEmail.Text;
            }

            hlWebsite.Text = ocd.szWebAddress; 
            if (!string.IsNullOrEmpty(hlWebsite.Text))
            {
                string szURL = PageConstants.FormatFromRoot(PageConstants.EXTERNAL_LINK_TRIGGER, hlWebsite.Text, companyID, "C", Request.ServerVariables.Get("SCRIPT_NAME"));
                hlWebsite.NavigateUrl = szURL;
            }

            SecurityMgr.SecurityResult privBBScore = WebUser.HasPrivilege(SecurityMgr.Privilege.ViewBBScore);
            WhatIsBBScore.Visible = privBBScore.Visible;
            trBBScore2.Visible = privBBScore.Visible;
            trBBScore.Visible = privBBScore.Visible;

            bool hasBBScore = false;

            if (privBBScore.HasPrivilege)
            {
                WhatIsBBScore.Visible = false;
                pnlWhatIsBBScore.Visible = false;
                pceWhatIsBBScore.Enabled = false;

                //prbs_PRPublish
                if (ocd.szBBScore != "" && ocd.bBBScorePublished && ocd.bCompBBScorePublished)
                {
                    hasBBScore = true;

                    lblBBScore.Text = Convert.ToDecimal(ocd.szBBScore).ToString("###");
                    litBBScore.Text = Convert.ToDecimal(ocd.szBBScore).ToString("###");
                    litBBScore.Visible = false;

                    //Calculate which BBScore jpg file to display
                    string szFileExtras = ""; //the param portion of "BBScore_NoText_{0}.jpg"
                    if(ocd.szIndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                        szFileExtras = string.Format("{0}_Lumber", Convert.ToDecimal(ocd.szBBScore).ToString("###"));
                    else
                        szFileExtras = string.Format("{0}", Convert.ToDecimal(ocd.szBBScore).ToString("###"));

                    //New ranges and images implemented Dec 2021 - use BBScoreGauge3 folder
                    if (ocd.szBBScoreModel.ToLower() == Configuration.CurrentBBScoreModelName)
                        imgBBScore.ImageUrl = UIUtils.GetImageURL(string.Format(Utilities.GetConfigValue("BBScoreImageFile").Replace("BBScoreGauge/", "BBScoreGauge3/"), szFileExtras));
                    else
                        imgBBScore.ImageUrl = UIUtils.GetImageURL(string.Format(Utilities.GetConfigValue("BBScoreImageFile"), szFileExtras));
                }
                else
                {
                    litBBScore.Text = Resources.Global.NotApplicableAbbr;
                    lblBBScore.Visible = false;
                    trBBScore2.Visible = false;
                }
            }
            else
            {
                trBBScore.Disabled = true;
                trBBScore2.Visible = false;
            }

            PopulateSocialMedia(UIUtils.GetInt(ocd.szCompanyID), ocd.szPreparedName, ocd.bSuppressLinkedInWidget);
            PopulateClaimsActivity(UIUtils.GetInt(ocd.szCompanyID), ocd.iHQID, ocd.szCompanyType, ocd.szIndustryType);
            PopulateARReports(UIUtils.GetInt(ocd.szCompanyID), ocd.szIndustryType);

            if (hasBBScore)
            {
                if (!Utilities.GetBoolConfigValue("BBScoreChartEnabled", false))
                {
                    lblBBScore.Visible = false;
                    litBBScore.Visible = true;
                    return;
                }

                ucBBScoreChart.industry = ocd.szIndustryType;
                PageControlBaseCommon.PopulateBBScoreChart(UIUtils.GetInt(ocd.szCompanyID), ocd.szIndustryType, ucBBScoreChart.chart, ucBBScoreChart.bbScoreImage, ucBBScoreChart.bbScoreLiteral, oWebUser.prwu_AccessLevel, Convert.ToDecimal(ocd.szBBScore).ToString("###"), oWebUser.prwu_Culture, ocd.szBBScoreModel);
            }

            if(LimitadoSimplified)
            {
                //Hide rows that don't apply for Limitado users per the design doc
                trCreditWorthRating.Visible = false;
                trPayIndicator.Visible = false;
                trPayReportCount.Visible = false;
                trRating.Visible = false;
                trClaimTable.Visible = false;
                trARReports.Visible = false;
                trIndustry.Visible = false;
                trStatus.Visible = false;
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

        #region "ClaimActivity"
        protected const string SQL_BBSI_CLAIM_ACTIVITY_COUNT =
                 @"SELECT (COUNT(prss_SSFileID) + COUNT(prcc_CourtCaseID)) as ClaimActivityCount
                  FROM Company WITH (NOLOCK) 
                       LEFT OUTER JOIN PRSSFile WITH (NOLOCK) ON comp_CompanyID = prss_RespondentCompanyId
                                                                AND prss_Status IN ('O', 'C')
                                                                AND prss_Publish = 'Y'
                                                                AND prss_Type = 'C'
                                                                AND ISNULL(prss_ClosedDate, GETDATE()) >= @ThresholdDate1
                       LEFT OUTER JOIN PRCourtCases WITH (NOLOCK) ON comp_CompanyID = prcc_CompanyID
                                                                AND ISNULL(prcc_ClosedDate, GETDATE()) >= @ThresholdDate2
                WHERE comp_CompanyID = @CompanyID";

        protected const string SQL_BBSI_CLAIMS_MERITORIOUS =
            @"SELECT 'x'
              FROM PRSSFile WITH (NOLOCK)
             WHERE prss_RespondentCompanyId = @CompanyID
               AND prss_Status IN ('O', 'C')
               AND prss_Publish = 'Y'
               AND prss_Meritorious = 'Y'
               AND prss_MeritoriousDate >= @ThresholdDate";

        protected const string SQL_BBSI_CLAIMS_NEW =
            @"SELECT 'x'
              FROM PRSSFile WITH (NOLOCK)
             WHERE prss_RespondentCompanyId = @CompanyID
               AND prss_Status IN ('O', 'C')
               AND prss_Publish = 'Y'
               AND prss_OpenedDate >= @ThresholdDate
             UNION
            SELECT 'X'
              FROM PRCourtCases WITH (NOLOCK)
             WHERE prcc_CreatedDate >= @ThresholdDate
               AND prcc_CompanyID = @CompanyID";

        public const string SQL_SELECT_PACA_COMPLAINTS =
            @"SELECT PRPacaComplaint.* FROM PRPACAComplaint
	            INNER JOIN PRPACALicense ON prpa_PACALicenseId =  prpac_PACALicenseID AND prpa_Current='Y' AND prpa_CompanyId = @CompanyID";

        protected void PopulateClaimsActivity(int companyID,
                                              int hqID,
                                              string companyType,
                                              string industryType)
        {
            if (industryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                trClaimTable.Visible = false;
                return;
            }

            // If this is for a branch,
            // then base the queries on the HQ.
            if (companyType == "B")
            {
                litClaimActivityHQ.Text = "HQ";
            }

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", hqID));

            int months;
            int monthsFederalCivilCases;

            if (WebUser.prwu_AccessLevel >= PRWebUser.SECURITY_LEVEL_ADVANCED_PLUS)
            {
                months = Configuration.ClaimActivityBBSiClaimsThresholdMonthsPlus_Meritorious; //60 default
                monthsFederalCivilCases = Configuration.ClaimActivityFederalCivilCasesThresholdMonthsPlus; //60 default
            }
            else
            {
                months = Configuration.ClaimActivityBBSiClaimsThresholdMonths; //24 default
                monthsFederalCivilCases = Configuration.ClaimActivityFederalCivilCasesThresholdMonths; //24 default
            }

            oParameters.Add(new ObjectParameter("ThresholdDate1", DateTime.Today.AddMonths(0 - months)));
            oParameters.Add(new ObjectParameter("ThresholdDate2", DateTime.Today.AddMonths(0 - monthsFederalCivilCases)));

            int count = (int)GetDBAccess().ExecuteScalar(SQL_BBSI_CLAIM_ACTIVITY_COUNT, oParameters);
            
            bool bHasPACAComplaints = false;
            oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", companyID));

            using (IDataReader oReader = GetDBAccess().ExecuteReader(SQL_SELECT_PACA_COMPLAINTS, oParameters, CommandBehavior.CloseConnection, null))
            {
                if (oReader.Read())
                {
                    bHasPACAComplaints = true;
                }
            }

            if (count == 0 && !bHasPACAComplaints)
            {
                hlClaimActivity.Enabled = false;
                return;
            }

            hlClaimActivity.NavigateUrl = PageConstants.FormatFromRoot(PageConstants.COMPANY_CLAIMS_ACTIVITY_BBOS9, companyID);

            oParameters.Clear();
            oParameters.Add(new ObjectParameter("CompanyID", hqID));
            int days = Configuration.ClaimActivityMeritoriousThresholdIndicatorDays;
            DateTime threshold = DateTime.Today.AddDays(0 - days);
            oParameters.Add(new ObjectParameter("ThresholdDate", threshold));

            if (GetDBAccess().ExecuteScalar(SQL_BBSI_CLAIMS_MERITORIOUS, oParameters) != null)
            {
                hlClaimActivityMeritorious.ImageUrl = UIUtils.GetImageURL("ClaimActivity-Meritorious.png");
                hlClaimActivityMeritorious.NavigateUrl = PageConstants.FormatFromRoot(PageConstants.COMPANY_CLAIMS_ACTIVITY_BBOS9, companyID);
            }

            oParameters.Clear();
            oParameters.Add(new ObjectParameter("CompanyID", hqID));

            days = Configuration.ClaimActivityNewThresholdIndicatorDays;
            threshold = DateTime.Today.AddDays(0 - days);
            oParameters.Add(new ObjectParameter("ThresholdDate", threshold));

            if (GetDBAccess().ExecuteScalar(SQL_BBSI_CLAIMS_NEW, oParameters) != null)
            {
                hlClaimActivityNew.ImageUrl = UIUtils.GetImageURL("ClaimActivity-New.png");
                hlClaimActivityNew.NavigateUrl = PageConstants.FormatFromRoot(PageConstants.COMPANY_CLAIMS_ACTIVITY_BBOS9, companyID);
            }
        }
        #endregion

        #region ARReports
        private const string SQL_AR_REPORT_COUNT =
                 @"SELECT COUNT(*) FROM (SELECT DISTINCT praad_ReportingCompanyName, CAST(praa_Date as Date) praa_Date
	                FROM vPRARAgingDetailOnProduce
	                WHERE praad_SubjectCompanyID = @CompanyID
		                AND praa_Date >= DATEADD(m, -@Threshold, GETDATE())) T1";

        protected void PopulateARReports(int companyID,
                                         string industryType)
        {
            if (industryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                trARReports.Visible = false;
                return;
            }

            IList oParameters = new ArrayList();

            const int THRESHOLD_MONTHS = 6;
            oParameters.Add(new ObjectParameter("CompanyID", companyID));
            oParameters.Add(new ObjectParameter("Threshold", THRESHOLD_MONTHS)); //Defect 6825 force to 6 months instead of WebUser.prwu_ARReportsThrehold
            int count = (int)GetDBAccess().ExecuteScalar(SQL_AR_REPORT_COUNT, oParameters);

            hlARReports.Text = string.Format("{0}", count);
            hlARReports.ToolTip = string.Format(Resources.Global.LastxMonths, THRESHOLD_MONTHS);

            if (WebUser.HasPrivilege(SecurityMgr.Privilege.CompanyDetailsARReportsPage).HasPrivilege)
            {
                hlARReports.NavigateUrl = PageConstants.FormatFromRoot(PageConstants.COMPANY_DETAILS_AR_REPORTS, companyID);
            }
            else
            {
                hlARReports.NavigateUrl = PageConstants.FormatFromRoot(PageConstants.EXTERNAL_LINK_TRIGGER, Configuration.ARReportsMarketingPage, companyID, "C", Request.ServerVariables.Get("SCRIPT_NAME"));
                hlARReports.Target = "_blank";
            }
        }
        #endregion
 
    }
}