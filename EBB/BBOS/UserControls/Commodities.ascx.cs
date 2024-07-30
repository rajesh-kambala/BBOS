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
    public partial class Commodities : UserControlBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if (!Page.IsPostBack)
            {
                SetSortField(gvCommodities, "prcca_Sequence");
                SetSortAsc(gvCommodities, true);
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
                updpnlCommodities.Visible = false;
            }

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prcca_CompanyID", hidCompanyID.Text));

            string szSQL = string.Format(SQL_COMMODITY_SELECT_KYCC,
                                GetObjectMgr().GetLocalizedColName("prcx_Description"),
                                Configuration.WordPressProduce_posts);

            szSQL = GetObjectMgr().FormatSQL(szSQL + SQL_COMMODITY_WHERE, oParameters);
            szSQL += GetOrderByClause(gvCommodities);

            //((EmptyGridView)gvCommodities).EmptyTableRowText = GetNoResultsFoundMsg(Resources.Global.Commodities);
            gvCommodities.ShowHeaderWhenEmpty = true;
            gvCommodities.EmptyDataText = GetNoResultsFoundMsg(Resources.Global.Commodities);

            gvCommodities.DataSource = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            gvCommodities.DataBind();
            EnableBootstrapFormatting(gvCommodities);

            Visible = true;
        }

        /// <summary>
        /// Helper method that helps with bi-directional sorting
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void GridView_Sorting(Object sender, GridViewSortEventArgs e)
        {
            GridView gvGrid = (GridView)sender;

            SetSortingAttributes(gvGrid, e);
            PopulateCommodities();
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
        }

        /// <summary>
        /// Adds the sort indicator to the appropriate column
        /// header.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void gvCommodities_GridView_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            SetSortIndicator((GridView)sender, e);

            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                HyperLink aDescription = (HyperLink)e.Row.FindControl("aDescription");
                Literal litDescription = (Literal)e.Row.FindControl("litDescription");

                var intArticleID = DataBinder.Eval(e.Row.DataItem, "prkycc_ArticleID");

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
    }
}