/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2019-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: Notes
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Data;
using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// User control that displays the Performance Indicators for Series 250 upgrade
    /// </summary>
    public partial class PerformanceIndicators : UserControlBase
    {
        protected CompanyData _ocdCompany;
        protected CompanyData _ocdHQ;
        protected bool _bHidden = false;

        protected int _intTradeReportCount = 0;
        protected decimal _decAveIntegrity = 0;
        protected decimal _decIndustryAveIntegrity = 0;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if (!WebUser.HasPrivilege(SecurityMgr.Privilege.ViewPerformanceIndicators).HasPrivilege)
            {
                this.Visible = false;
                return;
            }

            if(!IsPostBack)
            {
                _ocdCompany = GetCompanyDataFromSession();
                _ocdHQ = GetCompanyData(HQID, WebUser, GetDBAccess(), GetObjectMgr(), bHQ: true);

                if (FinancialStatementDate == "Not Provided")
                    lblFinancialStmtLastSubmitted.Visible = false;
                else
                    lblFinancialStmtLastSubmitted.Text = FinancialStatementDate;

                if(!HasRatingHistory(HQID))
                {
                    lblRatingHistory_NoLink.Visible = true;
                    lblRatingHistory.Visible = false;
                }

                //If the company's current Credit Worth Rating = (150) (creditworthID=9), do not display row 
                if (_ocdHQ.szCreditWorthRating == "(150)")
                    rowFinancialStmtLastSubmitted.Visible = false;

                if (_ocdCompany.szCompanyType == "B" || _ocdCompany.szCompanyType == "BR")
                    litPanelTitle.Text = "HQ " + Resources.Global.PerformanceIndicators;
                else
                    litPanelTitle.Text = Resources.Global.PerformanceIndicators;

                LoadTradeActivity();
            }
        }

        /// <summary>
        /// Has Rating History PerformanceIndicators.ascx
        /// </summary>
        /// <returns></returns>
        public bool HasRatingHistory(string HQID)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", HQID));

            DataSet dsRatingHistory = GetDBAccess().ExecuteStoredProcedure("usp_BRRatings", oParameters);
            bool bHasRatingHistory = false;
            if (dsRatingHistory != null && dsRatingHistory.Tables.Count > 0 && dsRatingHistory.Tables[0].Rows.Count > 0)
                bHasRatingHistory = true;

            return bHasRatingHistory;
        }

        public string HQID
        {
            set { hidHQID.Value = value; }
            get { return hidHQID.Value; }
        }
        
        public int TradeReportCount
        {
            get { return _intTradeReportCount; }
        }
        public string AveIntegrity
        {
            get { return _decAveIntegrity.ToString("0.00");}
        }
        public string IndustryAveIntegrity
        {
            get { return _decIndustryAveIntegrity.ToString("0.00"); }
        }

        public bool Hidden
        {
            //Used to allow the control to exist on the page, but not be displayed -- for BBOS 9.0 where we want the popups but not the other visual elements
            set
            { 
                _bHidden = value;
                ToggleDisplay();
            }
            get { return _bHidden; }
        }

        private void ToggleDisplay()
        {
            pnlHidden.Visible = !Hidden;
        }

        public string FinancialStatementDate
        {
            get
            {
                return ((_ocdHQ.dtPRFinancialStatementDate == DateTime.MinValue) ? "Not Provided" : (_ocdHQ.dtPRFinancialStatementDate.ToString("MM/dd/yyyy")));
            }
        }

        const string SQL_TRADE_ACTIVITY_COUNT = @"SELECT prtr_SubjectID, AVG(CAST(prin_Weight as decimal(6,3))) as AveIntegrity,       
                                                        COUNT(prin_Weight) as TradeReportCount,
                                                        CASE WHEN capt_US IS NULL THEN '0' ELSE capt_US END AS IndustryAveIntegrity
                                                    FROM PRTradeReport WITH (NOLOCK)
                                                        INNER JOIN PRIntegrityRating WITH (NOLOCK) ON prtr_IntegrityId = prin_IntegrityRatingId
                                                        INNER JOIN Company C1 WITH (NOLOCK) ON Comp_CompanyId = prtr_SubjectId
														INNER JOIN Company C2 WITH (NOLOCK) ON C2.Comp_CompanyId = prtr_ResponderId AND C2.comp_PRIgnoreTES IS NULL
                                                        LEFT OUTER JOIN custom_captions WITH (NOLOCK) ON capt_family = 'IndustryAverageRatings_'  + C1.comp_PRIndustryType AND capt_code = 'IntegrityAverage_Current'
                                                    WHERE prtr_Date >= DATEADD(month, -6, GETDATE())
                                                        AND prtr_SubjectID = {0}
                                                        AND prtr_Duplicate IS NULL
                                                        AND prtr_ExcludeFromAnalysis IS NULL
                                                    GROUP BY prtr_SubjectID, capt_us";

        private void LoadTradeActivity()
        {
            int intTradeReportCount = 0; _intTradeReportCount = 0;
            decimal decAveIntegrity = 0; _decAveIntegrity = 0;
            decimal decIndustryAveIntegrity = 0; _decIndustryAveIntegrity = 0;

            string szSQL = string.Format(SQL_TRADE_ACTIVITY_COUNT, HQID);

            using (IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, null, CommandBehavior.CloseConnection, null)) { 
                while (oReader.Read())
                {
                    decAveIntegrity = oReader.GetDecimal(1); 
                    _decAveIntegrity = decAveIntegrity;

                    intTradeReportCount = oReader.GetInt32(2); 
                    _intTradeReportCount = intTradeReportCount;

                    decIndustryAveIntegrity = Convert.ToDecimal(oReader.GetString(3)); 
                    _decIndustryAveIntegrity = decIndustryAveIntegrity;
                }
            }

            if (intTradeReportCount == 0) //previous was <= 2, changed for defect 6794
            {
                pnlTradeActivitySummaryWrapper.Visible = false;
                return;
            }

            //Only process below if panel is being displayed
            lblTradeActivitySummary.Text = string.Format("{0} ({1}: {2})", decAveIntegrity.ToString("0.00"), Resources.Global.IndustryAvg, decIndustryAveIntegrity.ToString("0.00"));
            imgTradeActivitySummary.ImageUrl = UIUtils.GetImageURL(string.Format(Utilities.GetConfigValue("TradeActivityScoreImageFile", "TradeActivityGauge/TradeActivityGauge_{0}.jpg"), decAveIntegrity.ToString("0.00")));
            lblTradeRepotsIncluded.Text = string.Format("{0} {1}", intTradeReportCount.ToString(), Resources.Global.TradeReportsIncluded);

            //Hyperlink language-specific phrase in disclaimer
            string szDisclaimer = Resources.Global.TradeReportsDisclaimer;
            string szHyperlinkedPhrase = "";
            if(WebUser.prwu_Culture == PageBase.SPANISH_CULTURE)
                szHyperlinkedPhrase = "en la Guía de Membresía";
            else
                szHyperlinkedPhrase = "Membership Guide";

            szDisclaimer = szDisclaimer.Replace(szHyperlinkedPhrase, "<a href='" + PageConstants.BLUEBOOK_SERVICES + "' class='explicitlink'>" + szHyperlinkedPhrase + "</a>");
            litDisclaimer1.Text = szDisclaimer;
        }
    }
}