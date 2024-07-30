/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CompanyCSG
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using PRCo.EBB.BusinessObjects;
using System;
using System.Collections;
using System.Data;
using System.Diagnostics;
using System.Security.Cryptography;
using System.Web;
using System.Web.UI.WebControls;
using System.Web.UI;
using TSI.BusinessObjects;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Displays company data and listing.
    /// </summary>
    public partial class CompanyCSG : CompanyDetailsBase
    {
        CompanyData _ocd;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
            Page.Title = Resources.Global.BlueBookService;
            ((BBOS)Master).HideOldTopMenu();

            if (!IsPostBack)
            {
                hidCompanyID.Text = GetRequestParameter("CompanyID", true, true);
                PopulateForm();
            }

            RedirectToHomeIfCompanyMissing(hidCompanyID.Text);

            //Set user controls
            ucSidebar.WebUser = _oUser;
            ucSidebar.CompanyID = UIUtils.GetString(hidCompanyID.Text);
            ucCompanyHero.WebUser = _oUser;
            ucCompanyHero.CompanyID = UIUtils.GetString(hidCompanyID.Text);
            ucCompanyBio.WebUser = _oUser;
            ucCompanyBio.CompanyID = UIUtils.GetString(hidCompanyID.Text);

            Advertisement.Logger = _oLogger;
            Advertisement.WebUser = _oUser;
            Advertisement.LoadAds();
        }

        protected override string GetCompanyID()
        {
            if (IsPostBack)
            {
                return hidCompanyID.Text;
            }
            else
            {
                return GetRequestParameter("CompanyID");
            }
        }

        protected override CompanyDetailsHeader GetCompanyDetailsHeader()
        {
            return ucCompanyDetailsHeader;
        }

        protected const string SQL_SELECT_CSG =
            @"SELECT prcsg_TotalUnits, prcsg_TotalSquareFootage
                FROM PRCSG
               WHERE prcsg_CompanyID = @CompanyID";

        protected void PopulateForm()
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", hidCompanyID.Text));

            using (IDataReader reader = GetDBAccess().ExecuteReader(SQL_SELECT_CSG, oParameters, CommandBehavior.CloseConnection, null))
            {
                if (reader.Read())
                {
                    lblTotalUnits.Text = getCSGValue(reader, 0);
                    lblSquareFootage.Text = getCSGValue(reader, 1);
                }
            }

            imgCSGLogo.ImageUrl = UIUtils.GetImageURL("CSGLogo.png");
            displayCSGData(gvTradeNames, "SN", "Trade Names");
            displayCSGData(gvAreasOfOperations, "TA", "Areas of Operation");
            displayCSGData(gvDistributionCenters, "DC", "Distribution Centers");
            displayCSGPersons();
        }

        protected const string SQL_SELECT_CSG_DATA =
            @"SELECT ISNULL(dbo.ufn_GetCSGValueForList(@CompanyID, @Type), @NotProvided) as ValueList";

        protected void displayCSGData(GridView gridView, string typeCode, string title)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", hidCompanyID.Text));
            oParameters.Add(new ObjectParameter("Type", typeCode));
            oParameters.Add(new ObjectParameter("NotProvided", Resources.Global.NotProvided));

            //((EmptyGridView)gridView).EmptyTableRowText = Resources.Global.NotProvided;
            gridView.ShowHeaderWhenEmpty = true;
            gridView.EmptyDataText = Resources.Global.NotProvided;

            gridView.DataSource = GetDBAccess().ExecuteReader(SQL_SELECT_CSG_DATA, oParameters, CommandBehavior.CloseConnection, null);
            gridView.DataBind();
            EnableBootstrapFormatting(gridView);
        }


        protected const string SQL_SELECT_CSG_PERSONS =
            @"SELECT prcsgp_FirstName, 
                   prcsgp_LastName,
                   dbo.ufn_FormatPerson(prcsgp_FirstName, prcsgp_LastName, prcsgp_MiddleInitial, null, prcsgp_Suffix) as Name,
                   prcsgp_Title,
	               prcsgp_Email
              FROM PRCSGPerson WITH (NOLOCK) 
                   INNER JOIN PRCSG WITH (NOLOCK) ON prcsgp_CSGID = prcsg_CSGID
             WHERE prcsg_CompanyID = @CompanyID
            ORDER BY prcsgp_LastName, prcsgp_FirstName";

        protected void displayCSGPersons()
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", hidCompanyID.Text));

            //((EmptyGridView)gvContacts).EmptyTableRowText = Resources.Global.NotProvided;
            gvContacts.ShowHeaderWhenEmpty = true;
            gvContacts.EmptyDataText = Resources.Global.NotProvided;

            gvContacts.DataSource = GetDBAccess().ExecuteReader(SQL_SELECT_CSG_PERSONS, oParameters, CommandBehavior.CloseConnection, null);
            gvContacts.DataBind();
            EnableBootstrapFormatting(gvContacts);
        }

        private string getCSGValue(IDataReader reader, int ordinal)
        {
            if (reader[ordinal] == DBNull.Value)
            {
                return "Not Provided";
            }
            return reader.GetInt32(ordinal).ToString("###,##0");
        }

        override protected bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.CompanyDetailsChainStoreGuidePage).Enabled;
        }
    }
}