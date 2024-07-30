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

 ClassName: CompanyDetailsHeader
 Description:

 Notes:

***********************************************************************
***********************************************************************/
using System;
using PRCo.EBB.BusinessObjects;
using TSI.Utils;
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
    public partial class CompanyDetailsHeader : UserControlBase
    {
        protected string _szCompanyID = null;
        protected string _szCompanyName = "";
        protected bool _bLimitadoMode = false;
        public bool hideLocation { get; set; }

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
            if(hideLocation)
            {
                litLocation.Visible = false;
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

            CompanyData ocd = PageControlBaseCommon.GetCompanyData(szCompanyID, oWebUser, GetDBAccess(), GetObjectMgr());
            PopulateForm(ocd);

            _szCompanyName = ocd.szCompanyName;

            if (ocd.szIndustryType != GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                pdeRating.ContextKey = ocd.iRatingID.ToString();
            }

            SecurityMgr.SecurityResult privBBScore = oWebUser.HasPrivilege(SecurityMgr.Privilege.ViewBBScore);
            WhatIsBBScore.Visible = privBBScore.Visible;
            //trBBScore2.Visible = privBBScore.Visible;
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
                }
                else
                {
                    litBBScore.Text = Resources.Global.NotApplicableAbbr;
                    lblBBScore.Visible = false;
                }
            }
            else
            {
                trBBScore.Disabled = true;
            }

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
                WebUser = oWebUser;
            }
        }

        protected void PopulateForm(PageControlBaseCommon.CompanyData ocd)
        {
            // Stash these in the cache.  Most likely the user will be
            // clicking through the company pages so let's not query
            // for these if we don't have too.
            Session["CompanyHeader_szCompanyName"] = ocd.szCompanyName;
            Session["CompanyHeader_szLocation"] = ocd.szLocation;
            Session["CompanyHeader_dtListedDate"] = ocd.dtListedDate;
            Session["CompanyHeader_szListingStatus"] = ocd.szListingStatus;
            Session["CompanyHeader_szIndustryType"] = ocd.szIndustryType;
            Session["CompanyHeader_bHasNote"] = ocd.bHasNote;
            Session["CompanyHeader_bHasCSG"] = ocd.bHasCSG;
            Session["CompanyHeader_dtLastChanged"] = ocd.dtLastChanged;
            Session["CompanyHeader_szCompanyID"] = ocd.szCompanyID;

            litBBID.Text = ocd.szCompanyID;

            if (LimitadoMode)
            {
                //Don't link Company Name for Limitado -- show literal instead
                litCompanyName.Visible = true;
                hlCompanyName.Visible = false;
                litCompanyName.Text = ocd.szCompanyName;
            }
            else
            {
                litCompanyName.Visible = false;
                hlCompanyName.Visible = true;
                hlCompanyName.Text = ocd.szCompanyName;
                hlCompanyName.NavigateUrl = PageConstants.FormatFromRoot(PageConstants.COMPANY_DETAILS_SUMMARY, ocd.szCompanyID);
            }

            litLocation.Text = ocd.szLocation;

            litTitle.Text = string.Format("{0}, {1}", ocd.szCompanyName, ocd.szLocation);

            bool unlistedCompany = false;

            // If not listed, then display an icon with text.
            if ((ocd.szListingStatus == "N3") ||
                (ocd.szListingStatus == "N4") ||
                (ocd.szListingStatus == "N5") ||
                (ocd.szListingStatus == "N6"))
            {
                trMessage.Visible = true;
                if(ocd.szCompanyType.StartsWith("B"))
                    litMessage.Text = Resources.Global.BranchNoLongerListedMsg; //branch
                else
                    litMessage.Text = Resources.Global.CompanyNoLongerListedMsg; //hq

                if (ocd.dtDelistedDate != DateTime.MinValue)
                    litMessage.Text += string.Format(" {0} {1}.", Resources.Global.AsOf, ocd.dtDelistedDate.ToShortDateString());

                unlistedCompany = true;
                btnCompanyUpdates.Visible = true;
                btnCompanyUpdates.PostBackUrl = PageConstants.FormatFromRoot(PageConstants.COMPANY_DETAILS_COMPANY_UPDATES, ocd.szCompanyID);

                trRating.Visible = false;
                trBBScore.Visible = false;
            }
            else
            {
                // Only display the "Newly Listed" icon if the
                // listed date is within the configured threshold.
                if (ocd.dtListedDate != DateTime.MinValue)
                {
                    TimeSpan oDiff = DateTime.Today - ocd.dtListedDate;
                    if (oDiff.Days <= Configuration.NewListingDaysThreshold)
                    {
                        trMessage.Visible = true;
                        imgIcon.Visible = true;
                        imgIcon.ImageUrl = UIUtils.GetImageURL("icon-new-listing.gif");
                        imgIcon.ToolTip = string.Format(Resources.Global.NewListingMsg, oDiff.Days + 1);
                        litMessage.Text = string.Format(Resources.Global.NewListingMsg, oDiff.Days + 1);
                    }
                }
            }

            if (ocd.szListingStatus == "LUV")
                trUnverified.Visible = true;
            else
                ltUnverified.Text = string.Empty;

            if (ocd.szIndustryType != GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                litRatingLabel.Text = ocd.szRatingLineLabel;

                if (WebUser != null && WebUser.HasPrivilege(SecurityMgr.Privilege.ViewRating).HasPrivilege)
                    lblRating.Text = ocd.szRatingLine;

                trRatingNumeral.Visible = false;
                trPayIndicator.Visible = false;
            }
            else
            {
                trRating.Visible = false;
                if (WebUser != null)
                {
                    if (WebUser.HasPrivilege(SecurityMgr.Privilege.ViewRating).HasPrivilege)
                    {
                        lblRatingNumeral.Text = ocd.szRatingNumerals;
                    }
                    else if (WebUser.IsLumber_BASIC() || WebUser.IsLumber_BASIC_PLUS())
                    {
                        //Defect 6818 alternate "Upgrade to view" link for Basic Lumber users
                        lblRatingNumeral.Text = string.Format("<a href='MembershipSelect.aspx'>{0}</a>", Resources.Global.UpgradeToView);
                    }

                    if (WebUser.HasPrivilege(SecurityMgr.Privilege.ViewPayIndicator).HasPrivilege)
                    {
                        lblPayIndicator.Text = ocd.szPayIndicator;
                    }
                    else if (WebUser.IsLumber_BASIC() || WebUser.IsLumber_BASIC_PLUS())
                    {
                        //Defect 6818 alternate "Upgrade to view" link for Basic Lumber users
                        lblPayIndicator.Text = string.Format("<a href='MembershipSelect.aspx'>{0}</a>", Resources.Global.UpgradeToView);
                    }
                }
            }

            if (!unlistedCompany)
            {
                bool blnHasPrivilege;
                if (WebUser == null)
                {
                    blnHasPrivilege = false;
                    trBBScore.Visible = false;
                }
                else
                {
                    SecurityMgr.SecurityResult result = WebUser.HasPrivilege(SecurityMgr.Privilege.ViewBBScore);
                    trBBScore.Visible = result.Visible;
                    blnHasPrivilege = result.HasPrivilege;
                }

                if (blnHasPrivilege)
                {
                    //prbs_PRPublish
                    if ((ocd.szBBScore != null) &&
                        ocd.bBBScorePublished && ocd.bCompBBScorePublished)
                    {
                        litBBScore.Text = ocd.szBBScore;
                        lblBBScore.Text = ocd.szBBScore;
                        litBBScore.Visible = false;
                    }
                    else
                    {
                        litBBScore.Text = Resources.Global.NotApplicableAbbr;
                        lblBBScore.Visible = false;
                    }
                }
                else
                {
                    trBBScore.Disabled = true;
                }
            }

            if (ocd.bHasNote)
            {
                hlNote.Visible = true;
                hlNote.ImageUrl = UIUtils.GetImageURL("icon-note.gif");
                hlNote.ToolTip = Resources.Global.ViewNote;
                hlNote.NavigateUrl = PageConstants.FormatFromRoot(PageConstants.COMPANY_DETAILS_CUSTOM, ocd.szCompanyID);
            }

            if (ocd.bIsCertifiedOrganic || ocd.bIsFoodSafetyCertified)
            {
                hlCertified.Visible = true;
                hlCertified.ImageUrl = UIUtils.GetImageURL("icon-certified16.png");
                hlCertified.NavigateUrl = PageConstants.FormatFromRoot(PageConstants.COMPANY_DETAILS_CLASSIFICATIONS, ocd.szCompanyID);

                if (ocd.bIsCertifiedOrganic && ocd.bIsFoodSafetyCertified)
                    hlCertified.ToolTip = Resources.Global.CertifiedOrganicAndFoodSafety;
                else if (ocd.bIsCertifiedOrganic)
                    hlCertified.ToolTip = Resources.Global.CertifiedOrganic;
                else if (ocd.bIsFoodSafetyCertified)
                    hlCertified.ToolTip = Resources.Global.CertifiedFoodSafety;
            }

            if (ocd.dtLastChanged > DateTime.MinValue)
            {
                TimeSpan oTS = DateTime.Now.Subtract(ocd.dtLastChanged);
                int iDays = oTS.Days + 1;
                if (iDays < Configuration.CompanyLastChangeThreshold)
                {
                    hlChanged.Visible = true;
                    hlChanged.ImageUrl = UIUtils.GetImageURL("icon-changed.gif");
                    hlChanged.ToolTip = string.Format(Resources.Global.CompanyChangedMsg, iDays);
                    hlChanged.Attributes.Add("alt", hlChanged.ToolTip);
                    hlChanged.NavigateUrl = PageConstants.FormatFromRoot(PageConstants.COMPANY_DETAILS_COMPANY_UPDATES, ocd.szCompanyID);
                }
            }

            if (ocd.bOnWatchdogList)
            {
                imgOnWatchdogList.Visible = true;
                imgOnWatchdogList.ImageUrl = UIUtils.GetImageURL("icon_on_watchdog.png");
            }

            // Hide small left col if there is nothing to display (removed a col-md-1 so that when company doesn't have logo, there
            // isn't unnecessary whitespace.
            if (!imgIcon.Visible && !hlNote.Visible && !hlCertified.Visible && !hlChanged.Visible && !imgOnWatchdogList.Visible)
            {
                divLeftCol.Visible = false;
            }

            if (ocd.bPRTMFMAward)
            {
                imgTMFM.Visible = true;

                switch (ocd.szIndustryType)
                {
                    case GeneralDataMgr.INDUSTRY_TYPE_PRODUCE:
                        imgTMFM.ImageUrl = UIUtils.GetImageURL("seal_trade.svg");
                        lblTMFMMsg.Text = string.Format(Resources.Global.TradingMemberMsg, ocd.dtPRTMFMAwardDate.Year);
                        break;
                    case GeneralDataMgr.INDUSTRY_TYPE_TRANSPORTATION:
                        imgTMFM.ImageUrl = UIUtils.GetImageURL("seal_transport.svg");
                        lblTMFMMsg.Text = string.Format(Resources.Global.TransportationMemberMsg, ocd.dtPRTMFMAwardDate.Year);
                        break;
                }
            }
            else
            {
                trTMFM.Visible = false;
                DynCol1.Attributes["class"] = "col-md-9 col-xs-8";
                DynCol2.Visible = false;
            }

            if(LimitadoMode)
            {
                trRating.Visible = false;
            }

            //Adjust bootstrap colspans depending on left col visible and badge visible
            if (!divLeftCol.Visible && !DynCol2.Visible)
                DynCol1.Attributes["class"] = "col-xs-12";
            else if(divLeftCol.Visible && !DynCol2.Visible)
                DynCol1.Attributes["class"] = "col-xs-11";
            else if(!divLeftCol.Visible && DynCol2.Visible)
                DynCol1.Attributes["class"] = "col-xs-7";
        }

        /// <summary>
        /// Make this string publically available for
        /// use on the parent pages.
        /// </summary>
        public string Location
        {
            get
            {
                PageControlBaseCommon.CompanyData ocd = PageControlBaseCommon.GetCompanyData(_szCompanyID, WebUser, GetDBAccess(), GetObjectMgr());
                return ocd.szLocation;
            }
        }

        public string CompanyName
        {
            get { return _szCompanyName; }
        }

        public bool LimitadoMode
        {
            get { return _bLimitadoMode; }
            set { _bLimitadoMode = value; }
        }
    }
}
