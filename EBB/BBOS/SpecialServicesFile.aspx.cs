/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2018

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: SpecialServicesFile
 Description: This class provides the interface for the user to view 
              a Special Service File.	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Data;
using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    public partial class SpecialServicesFile : PageBase
    {
        // these should be loaded in Populate Form
        private int nClaimantCompanyId = 0;
        private int nRespondentCompanyId = 0;

        protected const string SQL_GET_SSFILE = "SELECT * FROM PRSSFile WITH (NOLOCK) WHERE prss_SSFileId = {0} ";
        protected const string SQL_SSFILE_IS_AUTH_DATA = "SELECT 'X' FROM PRSSFile WITH (NOLOCK) WHERE prss_SSFileId = {0} and (prss_ClaimantCompanyId = {1} OR prss_RespondentCompanyId = {1} OR prss_3rdPartyCompanyId = {1})";

        protected const string SQL_SELECT_SSFILE_ACCESS =
                @"SELECT prss_SSFileID, prss_UpdatedDate, prss_CreatedDate, prss_ClosedDate, prss_IssueDescription, prss_AssignedUserId, 
                         prss_OldestInvoiceDate, prss_IssueDescription, prss_InitialAmountOwed, prss_AmountPRCoCollected, prss_AmountStillOwing, prss_ClaimantCompanyId, 
                         prss_A1LetterSentDate, prss_WarningLetterSentDate, prss_ReportLetterSentDate, 
                         ISNULL(prss_RespondentCompanyId, '') as prss_RespondentCompanyId, ISNULL(prss_3rdPartyCompanyId, '') as prss_3rdPartyCompanyId, 
                         dbo.ufn_GetCustomCaptionValue('prss_Status', prss_Status, @Culture) As prss_Status, 
                         dbo.ufn_GetCustomCaptionValue('prss_Type', prss_Type, @Culture) As prss_Type, 
                         dbo.ufn_FormatUserName(prss_AssignedUserId) AS AssignedUser, claim.comp_PRLIstingStatus as ClaimantListingStatus, 
                         claim.comp_PRBookTradestyle AS ClaimantName, ISNULL(claim.comp_PRLegalName, '') AS ClaimantLegalName, claim.CityStateCountryShort AS ClaimantCityStateCountryShort, dbo.ufn_GetCustomCaptionValue('comp_PRIndustryType', claim.comp_PRIndustryType, @Culture) As ClaimantIndustryType, 
                         dbo.ufn_HasNote(@WebUserID, @WebUserHQID, prss_ClaimantCompanyId, 'C') As ClaimantHasNote, claim.comp_PRLastPublishedCSDate AS ClaimantLastPublishedCSDate, 
                         ISNULL(resp.comp_PRBookTradestyle, '') AS RespondentName, ISNULL(resp.comp_PRLegalName, '') AS RespondentLegalName, ISNULL(resp.CityStateCountryShort, '') AS RespondentCityStateCountryShort, 
                         ISNULL(dbo.ufn_GetCustomCaptionValue('comp_PRIndustryType', resp.comp_PRIndustryType, @Culture), '') As RespondentIndustryType, ISNULL(resp.comp_PRLIstingStatus, '') as RespondentListingStatus, 
                         dbo.ufn_HasNote(@WebUserID,  @WebUserHQID, prss_RespondentCompanyId, 'C') As RespondentHasNote, ISNULL(resp.comp_PRLastPublishedCSDate, '') AS RespondentLastPublishedCSDate,
                         
                         dbo.ufn_HasNewClaimActivity(claim.comp_PRHQID, @NewClaimThresholdDate) as ClaimantHasNewClaimActivity, 
                         dbo.ufn_HasMeritoriousClaim(claim.comp_PRHQID, @MeritoriousClaimThesholdDate) as ClaimantHasMeritoriousClaim,
                         dbo.ufn_HasNewClaimActivity(resp.comp_PRHQID, @NewClaimThresholdDate) as RespondentHasNewClaimActivity, 
                         dbo.ufn_HasMeritoriousClaim(resp.comp_PRHQID, @MeritoriousClaimThesholdDate) as RespondentHasMeritoriousClaim,

                         dbo.ufn_HasCertification(claim.comp_PRHQID) as ClaimantHasCertification,
                         dbo.ufn_HasCertification_Organic(claim.comp_PRHQID) as ClaimantHasCertification_Organic,
                         dbo.ufn_HasCertification_FoodSafety(claim.comp_PRHQID) as ClaimantHasCertification_FoodSafety,
                        
                         dbo.ufn_HasCertification(resp.comp_PRHQID) as RespondentHasCertification,
                         dbo.ufn_HasCertification_Organic(resp.comp_PRHQID) as RespondentHasCertification_Organic,
                         dbo.ufn_HasCertification_FoodSafety(resp.comp_PRHQID) as RespondentHasCertification_FoodSafety

                    FROM PRSSFile WITH (NOLOCK) 
                         INNER JOIN vPRBBOSCompanyList_ALL claim ON claim.comp_companyid = prss_ClaimantCompanyId 
                         LEFT OUTER JOIN vPRBBOSCompanyList_ALL resp ON resp.comp_companyid = prss_RespondentCompanyId ";

        protected const string SQL_SELECT_SSCONTACT_ACCESS = "" +
                ("SELECT prssc_ContactAttn " +
                 " FROM PRSSContact " +
                 " WHERE prssc_SSFileId = @SSFileID AND prssc_CompanyId = @ClaimantCompanyId AND prssc_IsPrimary = 'Y' ");

        protected const string SQL_WHERE_SSFILEID = " WHERE prss_SSFileId = @SSFileID ";

        override protected void Page_Load(object sender, EventArgs e)
        {
            // this value needs to be set priot to base.Page_load cal to assist in IsAuthorizedForData
            if (!IsPostBack)
            {
                hidSSFileID.Text = GetRequestParameter("SSFileID");
            }

            base.Page_Load(sender, e);

            SetPageTitle(Resources.Global.SpecialServicesFile);
            if (!IsPostBack)
            {
                PopulateForm();
            }
        }

        /// <summary>
        /// Populates the form.
        /// </summary>
        protected void PopulateForm()
        {
            string sClaimantCompanyId = null;
            string sRespondentCompanyId = null;

            if (!IsPostBack)
            {
                ArrayList oParameters = new ArrayList();
                oParameters.Add(new ObjectParameter("Culture", _oUser.prwu_Culture));
                oParameters.Add(new ObjectParameter("WebUserID", _oUser.prwu_WebUserID));
                oParameters.Add(new ObjectParameter("WebUserHQID", _oUser.prwu_HQID));
                oParameters.Add(new ObjectParameter("SSFileID", hidSSFileID.Text));
                oParameters.Add(new ObjectParameter("NewClaimThresholdDate", DateTime.Today.AddDays(0 - Configuration.ClaimActivityNewThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss")));
                oParameters.Add(new ObjectParameter("MeritoriousClaimThesholdDate", DateTime.Today.AddDays(0 - Configuration.ClaimActivityMeritoriousThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss")));

                DataSet dsSSFile = GetDBAccess().ExecuteSelect(SQL_SELECT_SSFILE_ACCESS + SQL_WHERE_SSFILEID, oParameters);

                gvClaimant.DataSource = dsSSFile;
                gvClaimant.DataBind();
                EnableBootstrapFormatting(gvClaimant);

                gvRespondent.DataSource = dsSSFile;
                gvRespondent.DataBind();
                EnableBootstrapFormatting(gvRespondent);

                IDataReader oReader = GetDBAccess().ExecuteReader(SQL_SELECT_SSFILE_ACCESS + SQL_WHERE_SSFILEID,
                                                                    oParameters, CommandBehavior.CloseConnection, null);
                try
                {
                    if (oReader.Read())
                    {
                        litFileID.Text = (GetDBAccess().GetInt32(oReader, "prss_SSFileID")).ToString();
                        // these integer values are defined in SpecialServicesBase
                        nClaimantCompanyId = GetDBAccess().GetInt32(oReader, "prss_ClaimantCompanyId");
                        sClaimantCompanyId = nClaimantCompanyId.ToString();
                        nRespondentCompanyId = GetDBAccess().GetInt32(oReader, "prss_RespondentCompanyId");
                        sRespondentCompanyId = nRespondentCompanyId.ToString();
                        if (nRespondentCompanyId == 0)
                            sRespondentCompanyId = "";

                        litCreatedDate.Text = GetStringFromDate(GetDBAccess().GetDateTime(oReader, "prss_CreatedDate"));
                        litClosedDate.Text = GetStringFromDate(GetDBAccess().GetDateTime(oReader, "prss_ClosedDate"));
                        litStatus.Text = GetDBAccess().GetString(oReader, "prss_Status");
                        litType.Text = GetDBAccess().GetString(oReader, "prss_Type");
                        litAssignedTo.Text = GetDBAccess().GetString(oReader, "AssignedUser");
                        litOldestInvoiceDate.Text = GetStringFromDate(GetDBAccess().GetDateTime(oReader, "prss_OldestInvoiceDate"));
                        litIssueDescription.Text = GetDBAccess().GetString(oReader, "prss_IssueDescription");

                        litTotalAmountOwing.Text = UIUtils.GetFormattedCurrency(GetDBAccess().GetDecimal(oReader, "prss_InitialAmountOwed"));
                        litAmountPRCoCollected.Text = UIUtils.GetFormattedCurrency(GetDBAccess().GetDecimal(oReader, "prss_AmountPRCoCollected"));
                        litAmountStillOwing.Text = UIUtils.GetFormattedCurrency(GetDBAccess().GetDecimal(oReader, "prss_AmountStillOwing"));

                        //litClaimantCompanyId.Text = sClaimantCompanyId + "<br />" +
                        //        GetCompanyDataForCellForUnlistedCompanies(nClaimantCompanyId,
                        //                        GetDBAccess().GetString(oReader, "ClaimantName"),
                        //                        GetDBAccess().GetString(oReader, "ClaimantLegalName"),
                        //                        GetObjectMgr().TranslateFromCRMBool(oReader["ClaimantHasNote"]),
                        //                        GetDBAccess().GetDateTime(oReader, "ClaimantLastPublishedCSDate"),
                        //                        GetDBAccess().GetString(oReader, "ClaimantListingStatus"),
                        //                        GetObjectMgr().TranslateFromCRMBool(oReader["ClaimantHasNewClaimActivity"]),
                        //                        GetObjectMgr().TranslateFromCRMBool(oReader["ClaimantHasMeritoriousClaim"]), true
                        //        ) + "<br />" + GetDBAccess().GetString(oReader, "ClaimantCityStateCountryShort");

                        if (nRespondentCompanyId == -1)
                        {
                            litRespondentCompanyId.Text = "Manually Entered Company";
                            litRespondentCompanyId.Visible = true;
                            gvRespondent.Visible = false;
                        }
                        else
                        {
                            litRespondentCompanyId.Visible = false;
                            gvRespondent.Visible = true;

                            //litRespondentCompanyId.Text = sRespondentCompanyId + "<br />" +
                            //        GetCompanyDataForCellForUnlistedCompanies(nRespondentCompanyId,
                            //                        GetDBAccess().GetString(oReader, "RespondentName"),
                            //                        GetDBAccess().GetString(oReader, "RespondentLegalName"),
                            //                        GetObjectMgr().TranslateFromCRMBool(oReader["RespondentHasNote"]),
                            //                        GetDBAccess().GetDateTime(oReader, "RespondentLastPublishedCSDate"),
                            //                        GetDBAccess().GetString(oReader, "RespondentListingStatus"),
                            //                        GetObjectMgr().TranslateFromCRMBool(oReader["RespondentHasNewClaimActivity"]),
                            //                        GetObjectMgr().TranslateFromCRMBool(oReader["RespondentHasMeritoriousClaim"]), true
                            //        ) + "<br />" + GetDBAccess().GetString(oReader, "RespondentCityStateCountryShort");

                            //litA1LetterSentDate.Text = GetStringFromDate(GetDBAccess().GetDateTime(oReader, "prss_A1LetterSentDate"));
                            //litWarningLetterSentDate.Text = GetStringFromDate(GetDBAccess().GetDateTime(oReader, "prss_WarningLetterSentDate"));
                            //litReportLetterSentDate.Text = GetStringFromDate(GetDBAccess().GetDateTime(oReader, "prss_ReportLetterSentDate"));
                            litLastActivityDate.Text = GetStringFromDate(GetDBAccess().GetDateTime(oReader, "prss_UpdatedDate")); //should be same date as Record of Activity text updates
                        }
                    }
                }
                finally
                {
                    if (oReader != null)
                    {
                        oReader.Close();
                    }
                }

                oParameters = new ArrayList();
                oParameters.Add(new ObjectParameter("SSFileID", hidSSFileID.Text));
                oParameters.Add(new ObjectParameter("ClaimantCompanyId", sClaimantCompanyId));
                oReader = GetDBAccess().ExecuteReader(SQL_SELECT_SSCONTACT_ACCESS,
                                                                    oParameters, CommandBehavior.CloseConnection, null);
                try
                {
                    if (oReader.Read())
                    {
                        litClaimantContact.Text = GetDBAccess().GetString(oReader, "prssc_ContactAttn");
                    }
                }
                finally
                {
                    if (oReader != null)
                    {
                        oReader.Close();
                    }
                }
            }
        }

        protected void btnBackOnClick(object sender, EventArgs e)
        {
            Response.Redirect(GetReturnURL(PageConstants.SPECIAL_SERVICES));
        }

        protected override bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.TradingAssistancePage).HasPrivilege;
        }

        protected override bool IsAuthorizedForData()
        {
            if (string.IsNullOrEmpty(hidSSFileID.Text))
                return false;

            string szSQL = string.Format(SQL_SSFILE_IS_AUTH_DATA, hidSSFileID.Text, _oUser.prwu_HQID);
            if (string.IsNullOrEmpty((string)GetDBAccess().ExecuteScalar(szSQL)))
                return false;
            else
                return true;
        }
    }
}
