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

 ClassName: Classifications.ascx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Data;
using System.Web.UI.WebControls;
using TSI.BusinessObjects;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// User control that displays the Classification information
    /// on each of the company detail pages.
    /// </summary>
    public partial class Classifications : UserControlBase
    {
        public enum ClassificationsFormatType
        {
            FORMAT_ORIG = 1,
            FORMAT_BBOS9 = 2
        }

        protected ClassificationsFormatType _eFormat = ClassificationsFormatType.FORMAT_ORIG; //default to original style

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if (!Page.IsPostBack)
            {
                SetVisibility();
            }
        }

        public string CompanyID
        {
            set
            {
                hidCompanyID.Text = value;
                PopulateClassifications();
            }
            get { return hidCompanyID.Text; }
        }

        protected const string SQL_CLASSIFICATIONS_SELECT =
                @"SELECT b.{0} As Level1, a.prcl_Abbreviation, a.{0} As Name, a.{1} As Description, prc2_Sequence
                    FROM PRCompanyClassification WITH (NOLOCK) 
                    INNER JOIN PRClassification a WITH (NOLOCK) ON prc2_ClassificationID = prcl_ClassificationID 
                    INNER JOIN PRClassification b WITH (NOLOCK) ON CASE WHEN CHARINDEX(',', a.prcl_Path) = 0 THEN a.prcl_Path ELSE LEFT(a.prcl_Path, CHARINDEX(',', a.prcl_Path)-1) END = b.prcl_ClassificationID";
        
        protected const string SQL_CLASSIFICATIONS_WHERE = " WHERE prc2_CompanyID = {0}";

        protected void PopulateClassifications()
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prc2_CompanyID", CompanyID));

            string szSQL = string.Format(SQL_CLASSIFICATIONS_SELECT,
                GetObjectMgr().GetLocalizedColName("prcl_Name"),
                GetObjectMgr().GetLocalizedColName("prcl_Description"));

            szSQL = GetObjectMgr().FormatSQL(szSQL + SQL_CLASSIFICATIONS_WHERE, oParameters);

            switch(Format)
            {
                case ClassificationsFormatType.FORMAT_ORIG:
                    if (string.IsNullOrEmpty(GetOrderByClause(gvClassifications1)))
                        szSQL += " ORDER BY prc2_Sequence ASC";
                    else
                        szSQL += GetOrderByClause(gvClassifications1);

                    gvClassifications1.ShowHeaderWhenEmpty = true;
                    gvClassifications1.EmptyDataText = GetNoResultsFoundMsg(Resources.Global.Classifications);
                    gvClassifications1.DataSource = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
                    gvClassifications1.DataBind();
                    EnableBootstrapFormatting(gvClassifications1);
                    break;
                case ClassificationsFormatType.FORMAT_BBOS9:
                    if (string.IsNullOrEmpty(GetOrderByClause(gvClassifications2)))
                        szSQL += " ORDER BY prc2_Sequence ASC";
                    else
                        szSQL += GetOrderByClause(gvClassifications2);
                    gvClassifications2.ShowHeaderWhenEmpty = true;
                    gvClassifications2.EmptyDataText = GetNoResultsFoundMsg(Resources.Global.Classifications);
                    gvClassifications2.DataSource = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
                    gvClassifications2.DataBind();
                    EnableBootstrapFormatting(gvClassifications2);
                    break;
                default:
                    Visible = false;
                    return;
            }

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
            PopulateClassifications();
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

        public ClassificationsFormatType Format
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
                case ClassificationsFormatType.FORMAT_BBOS9:
                    pnlClassifications1.Visible = false;
                    pnlClassifications2.Visible = true;
                    break;

                default:
                    pnlClassifications1.Visible = true;
                    pnlClassifications2.Visible = false;
                    break;
            }
        }
    }
}