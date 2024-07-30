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

 ClassName: SpecialServicesList.aspx
 Description: This class provides the listing of all Special Service
              records for the current company.

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Data;
using System.Globalization;
using System.Text;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    public partial class SpecialServicesList : PageBase
    {
        protected const string SQL_SELECT_SSFILE_ACCESS = "" +
                @"SELECT prss_SSFileID, prss_CreatedDate, prss_ClosedDate, prss_AssignedUserId, prss_ClaimantCompanyId, ISNULL(prss_RespondentCompanyId, '') as prss_RespondentCompanyId, 
                        dbo.ufn_GetCustomCaptionValue('prss_Status', prss_Status, @Culture) As prss_Status, 
                        dbo.ufn_GetCustomCaptionValue('prss_Type', prss_Type, @Culture) As prss_Type, 
                        dbo.ufn_FormatUserName(prss_AssignedUserId) AS AssignedUser, rtrim(user_EmailAddress) as user_EmailAddress, (user_Phone + ' x' + user_Extension) As user_Phone, claim.comp_PRLIstingStatus as ClaimantListingStatus, 
                        claim.comp_PRBookTradestyle AS ClaimantName, ISNULL(claim.comp_PRLegalName, '') AS ClaimantLegalName, claim.CityStateCountryShort AS ClaimantCityStateCountryShort, dbo.ufn_GetCustomCaptionValue('comp_PRIndustryType', claim.comp_PRIndustryType, @Culture) As ClaimantIndustryType, 
                        dbo.ufn_HasNote(@WebUserID, @WebUserHQID, prss_ClaimantCompanyId, 'C') As ClaimantHasNote, claim.comp_PRLastPublishedCSDate AS ClaimantLastPublishedCSDate, 
                        ISNULL(resp.comp_PRBookTradestyle, '') AS RespondentName, ISNULL(resp.comp_PRLegalName, '') AS RespondentLegalName, ISNULL(resp.CityStateCountryShort, '') AS RespondentCityStateCountryShort, ISNULL(resp.comp_PRLIstingStatus, '') as RespondentListingStatus, 
                        ISNULL(dbo.ufn_GetCustomCaptionValue('comp_PRIndustryType', resp.comp_PRIndustryType, @Culture), '') As RespondentIndustryType, 
                        ISNULL(dbo.ufn_HasNote(@WebUserID,  @WebUserHQID, prss_RespondentCompanyId, 'C'), '') As RespondentHasNote, ISNULL(resp.comp_PRLastPublishedCSDate, '') AS RespondentLastPublishedCSDate,
                        dbo.ufn_HasNewClaimActivity(claim.comp_PRHQID, @NewClaimThresholdDate) as ClaimantHasNewClaimActivity, 
                        dbo.ufn_HasMeritoriousClaim(claim.comp_PRHQID, @MeritoriousClaimThesholdDate) as ClaimantHasMeritoriousClaim,
                        dbo.ufn_HasNewClaimActivity(resp.comp_PRHQID, @NewClaimThresholdDate) as RespondentHasNewClaimActivity, 
                        dbo.ufn_HasMeritoriousClaim(resp.comp_PRHQID, @MeritoriousClaimThesholdDate) as RespondentHasMeritoriousClaim,

                        dbo.ufn_HasCertification(claim.comp_PRHQID) as ClaimantHasCertification,
                        dbo.ufn_HasCertification_Organic(claim.comp_PRHQID) as ClaimantHasCertification_Organic,
                        dbo.ufn_HasCertification_FoodSafety(claim.comp_PRHQID) as ClaimantHasCertification_FoodSafety,
                        
                        dbo.ufn_HasCertification(resp.comp_PRHQID) as RespondentHasCertification,
                        dbo.ufn_HasCertification_Organic(resp.comp_PRHQID) as RespondentHasCertification_Organic,
                        dbo.ufn_HasCertification_FoodSafety(resp.comp_PRHQID) as RespondentHasCertification_FoodSafety,

                        prss_PublishedNotes
                   FROM PRSSFile WITH (NOLOCK)
                        INNER JOIN vPRBBOSCompanyList_ALL claim ON claim.comp_companyid = prss_ClaimantCompanyId
                        LEFT OUTER JOIN vPRBBOSCompanyList_ALL resp ON resp.comp_companyid = prss_RespondentCompanyId 
                        LEFT OUTER JOIN Users WITH (NOLOCK) on user_UserId = prss_AssignedUserId 
                 WHERE (prss_ClaimantCompanyId = @WebUserHQID OR prss_RespondentCompanyId = @WebUserHQID OR prss_3rdPartyCompanyId = @WebUserHQID) 
                   AND (prss_Status='O' or (prss_Status='C' and prss_ClosedDate >= DateAdd(day, -(@ClosedDaysThreshold), GETDATE())))";

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            SetPageTitle(Resources.Global.SpecialServicesFiles2);

            if (!IsPostBack)
            {
                SetReturnURL(PageConstants.SPECIAL_SERVICES);
                SetSortField(gvSSFileAccess, "prss_SSFileID");
                gvSSFileAccess.Attributes["SortAsc"] = "false";
                PopulateForm();
            }
        }

        protected void PopulateForm()
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("Culture", _oUser.prwu_Culture));
            oParameters.Add(new ObjectParameter("WebUserID", _oUser.prwu_WebUserID));
            oParameters.Add(new ObjectParameter("WebUserHQID", _oUser.prwu_HQID));
            oParameters.Add(new ObjectParameter("ClosedDaysThreshold", Utilities.GetIntConfigValue("SSFileListClosedDaysThreshold", 730)));

            //Handle spanish globalization of date fields
            CultureInfo m_UsCulture = new CultureInfo("en-us");
            string szDate1 = DateTime.Today.AddDays(0 - Configuration.ClaimActivityNewThresholdIndicatorDays).ToString(m_UsCulture);
            string szDate2 = DateTime.Today.AddDays(0 - Utilities.GetIntConfigValue("ClaimActivityMeritoriousThresholdIndicatorDays", 60)).ToString(m_UsCulture);

            oParameters.Add(new ObjectParameter("NewClaimThresholdDate", szDate1));
            oParameters.Add(new ObjectParameter("MeritoriousClaimThesholdDate", szDate2));

            string szSQL = SQL_SELECT_SSFILE_ACCESS + GetOrderByClause(gvSSFileAccess);

            // Create empty grid view in case 0 results are found
            //((EmptyGridView)gvSSFileAccess).EmptyTableRowText = GetNoResultsFoundMsg(Resources.Global.SpecialServicesFiles);
            gvSSFileAccess.ShowHeaderWhenEmpty = true;
            gvSSFileAccess.EmptyDataText = GetNoResultsFoundMsg(Resources.Global.SpecialServicesFiles);

            gvSSFileAccess.DataSource = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            gvSSFileAccess.DataBind();
            EnableBootstrapFormatting(gvSSFileAccess);

            // Display the number of matching records found
            lblRecordCount.Text = string.Format(Resources.Global.RecordCountFoundMsg, gvSSFileAccess.Rows.Count, Resources.Global.SpecialServicesFiles);

            ApplyReadOnlyCheck(btnFileClaim);
            ApplyReadOnlyCheck(btnContactTradingAssistance);
        }

        protected void GridView_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            SetSortIndicator((GridView)sender, e);

            if(e.Row.RowType == DataControlRowType.DataRow)
            {
                Panel note = (Panel)e.Row.FindControl("note");
                HtmlButton btnClose = (HtmlButton)e.Row.FindControl("btnClose");
                if (note != null && btnClose != null)
                    btnClose.Attributes.Add("onclick", string.Format("document.getElementById('{0}').style.display='none';", note.ClientID));
            }
        }

        protected void GridView_Sorting(object sender, GridViewSortEventArgs e)
        {
            SetSortingAttributes((GridView)sender, e);
            PopulateForm();
        }

        protected string GetFormattedAssignedToEmail(string szAssignedTo, string szAssignedToEmail, string szPhone)
        {
            StringBuilder sbUserEmail = new StringBuilder();
            sbUserEmail.Append(szAssignedTo);
            sbUserEmail.Append("<br>");
            if (!string.IsNullOrEmpty(szPhone))
            {
                sbUserEmail.Append(szPhone);
                sbUserEmail.Append("<br>");
            }
            sbUserEmail.Append(UIUtils.GetHyperlink("mailto:" + szAssignedToEmail, szAssignedToEmail, "tw-text-xs tw-text-brand"));
            
            return sbUserEmail.ToString();
        }

        protected void btnContactTradingAssistanceOnClick(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.CONTACT_TRADING_ASSISTANCE);
        }

        protected void btnFileClaimOnClick(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.SPECIAL_SERVICES_FILE_CLAIM);
        }

        protected override bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.TradingAssistancePage).HasPrivilege;
        }

        protected override bool IsAuthorizedForData()
        {
            return true;
        }

        protected bool DisplayNotes(object notes)
        {
            if (notes == DBNull.Value)
            {
                return false;
            }

            if (string.IsNullOrEmpty((string)notes))
            {
                return false;
            }

            return true;
        }

        protected const string SQL_SELECT_BBSi_CLAIMS =
        @"SELECT *
               FROM vPRBBSiClaims 
              WHERE prss_RespondentCompanyId = @CompanyID
                AND ISNULL(prss_ClosedDate, GETDATE()) >= @ThresholdDate
                AND prss_Status IN ('O', 'C')
                AND prss_Publish = 'Y'";

        protected void btnSendCourtesyContactOnClick(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.SPECIAL_SERVICES_COURTESY_CONTACT);
        }
    }
}
