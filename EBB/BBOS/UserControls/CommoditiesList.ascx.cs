/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2020-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: Commodities.ascx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using PRCo.EBB.BusinessObjects;
using System;
using System.Collections;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using TSI.BusinessObjects;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// User control that displays the Commodities information
    /// on each of the company detail pages.
    /// </summary>
    public partial class CommoditiesList : UserControlBase
    {
        public enum CommoditiesListFormatType
        {
            FORMAT_ORIG = 1,
            FORMAT_BBOS9 = 2
        }

        protected CommoditiesListFormatType _eFormat = CommoditiesListFormatType.FORMAT_ORIG; //default to original style

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if (!Page.IsPostBack)
            {
                Session["CommoditiesListSortBy"] = "Description";
            }
        }

        public string CompanyID
        {
            set
            {
                hidCompanyID.Text = value;
                PopulateCommodities();
            }
            get { return hidCompanyID.Text; }
        }

        public string IndustryType
        {
            set
            {
                hidIndustryType.Text = value;
            }
            get { return hidIndustryType.Text; }
        }

        protected const string SQL_COMMODITY_SELECT_KYCC =
        @"  SELECT {0} As Description, prcca_PublishedDisplay, prcca_ListingCol1, prcca_ListingCol2, AttributeName, GrowingMethod, prcca_Sequence, 
                    prcca_CommodityId, prkycc_Commodityid, prkycc_ArticleID, prkycc_PostName
                FROM vListingPRCompanyCommodity WITH (NOLOCK)
	            LEFT JOIN PRKYCCommodity WITH(NOLOCK) ON prcca_CommodityId = prkycc_CommodityID 
		            AND ISNULL(prcca_AttributeID,0) = ISNULL(prkycc_AttributeID,0)
		            AND ISNULL(prcca_GrowingMethodID,0) = ISNULL(prkycc_GrowingMethodID,0)
                LEFT JOIN {1} wpp WITH(NOLOCK) ON 
                    wpp.ID = prkycc_ArticleID
                    AND post_type = 'KYC' 
                    AND post_status='publish' 
                    AND post_date<GETDATE()";

        protected const string SQL_COMMODITY_WHERE = "WHERE prcca_CompanyID={0}";

        /// <summary>
        /// Populates the commodities portion of the page.
        /// </summary>
        protected void PopulateCommodities()
        {
            if (hidIndustryType.Text != GeneralDataMgr.INDUSTRY_TYPE_PRODUCE)
            {
                this.Visible = false;
            }

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prcca_CompanyID", hidCompanyID.Text));

            string szSQL = string.Format(SQL_COMMODITY_SELECT_KYCC,
                                GetObjectMgr().GetLocalizedColName("prcx_Description"),
                                Configuration.WordPressProduce_posts);

            szSQL = GetObjectMgr().FormatSQL(szSQL + " " + SQL_COMMODITY_WHERE, oParameters);

            string szSort = null;
            if (Session["CommoditiesListSortBy"] != null)
                szSort = (string)Session["CommoditiesListSortBy"];
            else if (!string.IsNullOrEmpty(hidSortBy.Text))
                szSort = hidSortBy.Text;

            if (!string.IsNullOrEmpty(szSort))
                szSQL += $" ORDER BY {szSort} ASC";

            switch(Format)
            {
                case CommoditiesListFormatType.FORMAT_ORIG:
                    repCommodities1.DataSource = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
                    repCommodities1.DataBind();
                    break;
                case CommoditiesListFormatType.FORMAT_BBOS9:
                    repCommodities2.DataSource = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
                    repCommodities2.DataBind();
                    break;
            }
        }

        protected void repCommodities_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                HyperLink aDescription = (HyperLink)e.Item.FindControl("aDescription");
                Literal litDescription = (Literal)e.Item.FindControl("litDescription");

                var intArticleID = DataBinder.Eval(e.Item.DataItem, "prkycc_ArticleID");

                if (intArticleID == System.DBNull.Value || (int)intArticleID == 0)
                {
                    aDescription.Visible = false;
                }
                else
                {
                    litDescription.Visible = false;
                    aDescription.NavigateUrl = string.Format("~/" + PageConstants.KNOW_YOUR_COMMODITY_VIEW, intArticleID);
                }
            }
        }

        protected void btnPrint_Click(object sender, ImageClickEventArgs e)
        {
            Response.Redirect(PageConstants.Format(PageConstants.GET_REPORT, GetReport.COMPANY_COMMODITY_REPORT) + "&CompanyID=" + CompanyID + "&Culture=" + WebUser.prwu_Culture);
        }
        protected void btnPrint2_ServerClick(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.Format(PageConstants.GET_REPORT, GetReport.COMPANY_COMMODITY_REPORT) + "&CompanyID=" + CompanyID + "&Culture=" + WebUser.prwu_Culture);
        }

        public CommoditiesListFormatType Format
        {
            set
            {
                _eFormat = value;
                SetVisibility();
            }
            get { return _eFormat; }
        }

        private void SetVisibility()
        {
            switch (Format)
            {
                case CommoditiesListFormatType.FORMAT_BBOS9:
                    pnlCommodities1.Visible = false;
                    pnlCommodities2.Visible = true;
                    break;

                default:
                    pnlCommodities1.Visible = true;
                    pnlCommodities2.Visible = false;
                    break;
            }
        }
    }
}