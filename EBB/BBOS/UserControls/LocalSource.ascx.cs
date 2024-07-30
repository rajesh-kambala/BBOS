/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2017-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: LocalSource.ascx
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
using TSI.Arch;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// User control that displays the local source data, and meister text when it providesthe local source data
    /// </summary>
    public partial class LocalSource : UserControlBase
    {
        protected const string SQL_LOCAL_SOURCE =
                @"SELECT prls_AlsoOperates, prls_Organic, prls_TotalAcres, prls_EnhancedListing
                 FROM PRLocalSource WITH (NOLOCK)
                WHERE prls_CompanyID = @CompanyID";

        protected int _szCompanyID;

        public enum LocalSourceFormatType
        {
            FORMAT_ORIG = 1,
            FORMAT_BBOS9 = 2
        }

        protected LocalSourceFormatType _eFormat = LocalSourceFormatType.FORMAT_ORIG; //default to original style

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if (!Page.IsPostBack)
            {
                SetVisibility();
            }
        }

        public int companyID
        {
            set
            {
                _szCompanyID = value;
                PopulateLocalSourceData();
            }
            get { return _szCompanyID; }
        }

        protected void PopulateLocalSourceData()
        {
            Visible = false;

            if (!WebUser.HasLocalSourceDataAccess())
            {
                return;
            }

            CompanyData ocd = GetCompanyData(companyID.ToString(), WebUser, GetDBAccess(), GetObjectMgr());

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", companyID));

            using (IDataReader reader = GetDBAccess().ExecuteReader(SQL_LOCAL_SOURCE, oParameters, CommandBehavior.CloseConnection, null))
            {
                if (reader.Read())
                {
                    SetVisibility();
                    string szAlsoOperates = UIUtils.GetString(reader[0]);

                    //Defect 4478 - force bootstrap wrapping on commas
                    szAlsoOperates = szAlsoOperates.Replace(", ", ",<br/>");

                    AlsoOperates.Text = szAlsoOperates;
                    AlsoOperates2.Text = AlsoOperates.Text;

                    CertifiedOrganic.Text = UIUtils.GetStringFromBool(reader[1]);
                    CertifiedOrganic2.Text = CertifiedOrganic.Text;

                    TotalAcres.Text = UIUtils.GetString(reader[2]);
                    TotalAcres2.Text = TotalAcres.Text;

                    Visible = true;
                }
            }

            if (ocd.bLocalSource)
            {
                //throw new AuthorizationException(GetUnauthorizedForPageMsg());
                if (!SecurityMgr.HasLocalSourceDataAccess(WebUser, ocd.iRegionID).HasPrivilege)
                {
                    throw new AuthorizationException(PageBase.GetUnauthorizedForPageMsg());
                }

                trLocalSource.Visible = false;
            }
        }

        public LocalSourceFormatType Format
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
                case LocalSourceFormatType.FORMAT_BBOS9:
                    pnlLocalSource1.Visible = false;
                    pnlLocalSource2.Visible = true;
                    break;

                default:
                    pnlLocalSource1.Visible = true;
                    pnlLocalSource2.Visible = false;
                    break;
            }
        }
    }
}