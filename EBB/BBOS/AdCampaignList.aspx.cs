/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2022

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: AdCampaignList.aspx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using TSI.BusinessObjects;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    public partial class AdCampaignList : PageBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            SetPageTitle(Resources.Global.AdvertisingCampaigns);

            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_FUNCTIONS2_FILE));
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_VALIDATION_FILE));
            btnAdCampaignReport.Attributes.Add("onclick", "return confirmSelect('" + Resources.Global.AdCampaign + "', 'rbAdCampaignID')");

            if (!IsPostBack)
            {
                SetSortField(gvAdCampaigns, "pradc_StartDate");
                SetSortAsc(gvAdCampaigns, false);

                PopulateForm();
            }
        }

        protected const string SQL_SELECT_CAMPAIGNS =
            @"SELECT
                pradc_AdCampaignID, 
				pradch_Name, 
				CASE 
						 WHEN pradch_TypeCode='D' THEN dbo.ufn_GetCustomCaptionValue('pradc_AdCampaignTypeDigital', pradc_AdCampaignTypeDigital, 'en-us')
						 WHEN pradch_TypeCode='KYC' AND pradc_StartDate IS NOT NULL AND pradc_EndDate IS NOT NULL AND pracf_FileTypeCode='DI'  THEN 'KYC Digital ' + pradc_KYCEdition
						 WHEN pradch_TypeCode='KYC' AND pradc_StartDate IS NOT NULL AND pradc_EndDate IS NOT NULL AND pracf_FileTypeCode='PI'  THEN 'KYC Print ' + pradc_KYCEdition
						 WHEN pradch_TypeCode='KYC' AND pradc_StartDate IS NULL AND pradc_EndDate IS NULL THEN 'KYC Publication Advertisement ' + pradc_KYcEdition
						 WHEN pradch_TypeCode='TT' THEN 'T&T ' + pradc_TTEdition
						 WHEN pradch_TypeCode='BP' THEN 'Blueprints ' + LEFT(pradc_BluePrintsEdition,4) + '-' + RIGHT(pradc_BluePrintsEdition,2)
				END AS AdCampaignType,
				CityStateCountryShort, 
                CASE WHEN pradch_TypeCode='BP' THEN LEFT(pradc_BluePrintsEdition,4) + '-' + RIGHT(pradc_BluePrintsEdition,2) + '-01' ELSE pradc_StartDate END pradc_StartDate, 
                pradc_EndDate, 
                CASE WHEN pradch_TypeCode='KYC' AND pradc_StartDate IS NULL AND pradc_EndDate IS NULL THEN dbo.ufn_GetAdPublicationViewCount(pradc_AdCampaignID) ELSE pradc_ImpressionCount END As pradc_ImpressionCount, 
                pradc_ClickCount,
				pracf_FileTypeCode,
				ISNULL(pracf_FileName,'') pracf_FileName
            FROM PRAdCampaignHeader WITH (NOLOCK)
				INNER JOIN PRAdCampaign WITH (NOLOCK) ON pradc_AdCampaignHeaderID = pradch_AdCampaignHeaderID 
				INNER JOIN Company WITH (NOLOCK) ON pradch_CompanyID = comp_CompanyID 
				INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID 
                LEFT OUTER JOIN PRAdCampaignFile ON pracf_AdCampaignID = pradc_AdCampaignID
            WHERE pradch_HQID=@HQID"; 
				//AND pradch_TypeCode NOT IN ('BP')";

        protected void PopulateForm()
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("HQID", _oUser.prwu_HQID));

            string szSQL = string.Format(SQL_SELECT_CAMPAIGNS, _oUser.prwu_Culture);
            szSQL += GetOrderByClause(gvAdCampaigns);

            //((EmptyGridView)gvAdCampaigns).EmptyTableRowText = GetNoResultsFoundMsg(Resources.Global.AdvertisingCampaigns2);
            gvAdCampaigns.ShowHeaderWhenEmpty = true;
            gvAdCampaigns.EmptyDataText = GetNoResultsFoundMsg(Resources.Global.AdvertisingCampaigns2);

            gvAdCampaigns.DataSource = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            gvAdCampaigns.DataBind();
            EnableBootstrapFormatting(gvAdCampaigns);

            OptimizeViewState(gvAdCampaigns);
            lblRecordCount.Text = string.Format(Resources.Global.RecordCountFoundMsg, gvAdCampaigns.Rows.Count, Resources.Global.AdvertisingCampaigns2);
        }

        protected void btnDoneOnClick(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.MEMBERSHIP_SUMMARY);
        }

        protected void btnAdCampaignReportOnClick(object sender, EventArgs e)
        {
            string szID = GetRequestParameter("rbAdCampaignID");
            Response.Redirect(PageConstants.Format(PageConstants.GET_REPORT, GetReport.AD_CAMPAING_SUMMARY_REPORT) + "&AdCampaignID=" + szID);
        }

        /// <summary>
        /// Helper method that helps with bi-directional sorting
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void GridView_Sorting(Object sender, GridViewSortEventArgs e)
        {
            SetSortingAttributes((GridView)sender, e);
            PopulateForm();
        }

        /// <summary>
        /// Adds the sort indicator to the appropriate column
        /// header.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void GridView_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            SetSortIndicator((GridView)sender, e);

            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                string szFileNameAndPath = DataBinder.Eval(e.Row.DataItem, "pracf_FileName") as String;
                string szFileTypeCode = DataBinder.Eval(e.Row.DataItem, "pracf_FileTypeCode") as String;
                if (!string.IsNullOrEmpty(szFileNameAndPath))
                {
                    string szFileNameDisplay = "";
                    int pos = szFileNameAndPath.IndexOf("\\");
                    if (pos >= 0)
                    {
                        szFileNameDisplay = szFileNameAndPath.Substring(pos + 1);
                    }

                    HyperLink hlAdImage = (HyperLink)e.Row.FindControl("hlAdImage");
                    hlAdImage.Text = szFileNameDisplay;
                    if(szFileTypeCode == "PI")
                    {
                        //Copy of print image should have also been saved to a Print folder by CRM
                        int x = szFileNameAndPath.LastIndexOf("\\") + 1;
                        string szFileNameOnly = szFileNameAndPath.Substring(x, szFileNameAndPath.Length - x);
                        szFileNameOnly = Server.UrlEncode(szFileNameOnly).Replace("+", "%20");

                        DateTime PRINT_IMAGE_FILE_COPY_START_DATE = Utilities.GetDateTimeConfigValue("PrintImageFileCopyStartDate", new DateTime(2022, 2, 10));
                        if(DateTime.Now >= PRINT_IMAGE_FILE_COPY_START_DATE)
                        {
                            hlAdImage.NavigateUrl = Configuration.AdImageVirtualFolder + _oUser.prwu_HQID + "/Print/" + szFileNameOnly;
                            hlAdImage.Visible = true;
                        }
                    }
                    else
                    {
                        //Digital
                        string szEncodedFileName = Server.UrlEncode(szFileNameAndPath).Replace("+", "%20");
                        hlAdImage.NavigateUrl = Configuration.AdImageVirtualFolder + szEncodedFileName;
                        hlAdImage.Visible = true;
                    }
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
    }
}
