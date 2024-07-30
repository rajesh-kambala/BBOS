/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2010-2021

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CompanyDetailsClassifications.aspx
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
    public partial class CompanyDetailsClassifications : CompanyDetailsBase
    {
        CompanyData _ocd;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            // Add company submenu to this page
            SetSubmenu("btnCompanyDetailsClassifications");

            if (!IsPostBack)
            {
                hidCompanyID.Text = hidCompanyID.Text = GetRequestParameter("CompanyID", true, true);
                PopulateForm();
            }
        }

        protected void PopulateForm()
        {
            //Get cached company data
            _ocd = GetCompanyDataFromSession();

            ucClassifications.WebUser = _oUser;
            ucClassifications.CompanyID = hidCompanyID.Text;

            ucCommoditiesList.WebUser = _oUser;
            ucCommoditiesList.IndustryType = _ocd.szIndustryType;
            ucCommoditiesList.CompanyID = hidCompanyID.Text;

            PopulateLicenses();
            PopulateVolume();

            pnlCertifications.Visible = false;
            
            subMenuTabCommodities.Visible = false;
            subMenuTabClassifications.Visible = false;

            if (_ocd.szIndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                // Set page title, sub-title
                SetPageTitle(Resources.Global.CompanyDetails, Resources.Global.ClassificationsProductsServicesSpecies);
                LicensesDIV.Visible = false;

                updpnlProductProvided.Visible = true;
                updpnlServiceProvided.Visible = true;
                updpnlSpecie.Visible = true;

                subMenuTabClassifications.Visible = true;
                subMenuTabProductsServicesSpecies.Visible = true;

                if (!IsPostBack)
                {
                    SetSortField(gvProductProvided, "prprpr_DisplayOrder");
                    SetSortAsc(gvProductProvided, true);

                    SetSortField(gvServiceProvided, "prserpr_DisplayOrder");
                    SetSortAsc(gvServiceProvided, true);

                    SetSortField(gvSpecie, "prspc_DisplayOrder");
                    SetSortAsc(gvSpecie, true);
                }

                PopulateProductProvided();
                PopulateServiceProvided();
                PopulateSpecies();
                PopulateEmployees();
            }
            else
            {
                // Set page title, sub-title
                SetPageTitle(Resources.Global.CompanyDetails, Resources.Global.ClassificationsAndCommodities);

                updpnlProductProvided.Visible = false;
                updpnlServiceProvided.Visible = false;
                updpnlSpecie.Visible = false;
                updpnlEmployees.Visible = false;

                subMenuTabProductsServicesSpecies.Visible = false;

                if (_ocd.szIndustryType == GeneralDataMgr.INDUSTRY_TYPE_PRODUCE)
                {
                    subMenuTabClassifications.Visible = true;
                    subMenuTabCommodities.Visible = true;
                    PopulateCertifications();
                }
                else if(_ocd.szIndustryType == GeneralDataMgr.INDUSTRY_TYPE_TRANSPORTATION)
                {
                    PopulateCertifications();
                }
            }

            if (_ocd.bLocalSource)
            {
                ucCompanyDetailsHeaderMeister.MeisterVisible = true;
            }
        }

        protected const string SQL_LICENSES_SELECT =
       @"SELECT * FROM (
             SELECT dbo.ufn_GetListingLicenseSeq('PACA') AS Seq, 'PACA' AS Name, prpa_LicenseNumber As License
               FROM PRPACALicense WITH(NOLOCK)
             WHERE prpa_CompanyID = {0}
                AND prpa_Deleted IS NULL
                AND prpa_Publish = 'Y'
             UNION
             SELECT dbo.ufn_GetListingLicenseSeq('DRC'), 'DRC', CASE WHEN prdr_LicenseNumber IS NOT NULL THEN 'DRC Member' ELSE NULL END As prdr_LicenseNumber
               FROM PRDRCLicense WITH(NOLOCK)
             WHERE prdr_CompanyID = {0}
                AND prdr_Publish = 'Y'
                AND prdr_Deleted IS NULL
             UNION
             SELECT dbo.ufn_GetListingLicenseSeq(prli_Type),
                       COALESCE(cast(capt_us as varchar) + ' ', ''), prli_Number
               FROM PRCompanyLicense WITH(NOLOCK)
                    INNER JOIN custom_captions on capt_family = 'prli_Type' and capt_code = prli_Type
             WHERE prli_CompanyID = {0}
                AND prli_Publish = 'Y'
                AND prli_Deleted IS NULL
             ) TABLE1
       ORDER BY SEQ";

        /// <summary>
        /// Populates the Licenses portion of the page.
        /// </summary>
        protected void PopulateLicenses()
        {
            string szSQL = string.Format(SQL_LICENSES_SELECT, hidCompanyID.Text);

            gvLicenses.ShowHeaderWhenEmpty = true;
            gvLicenses.EmptyDataText = GetNoResultsFoundMsg(Resources.Global.Licenses);

            gvLicenses.DataSource = GetDBAccess().ExecuteReader(szSQL, null, CommandBehavior.CloseConnection, null);
            gvLicenses.DataBind();
            EnableBootstrapFormatting(gvLicenses);
        }

        protected const string SQL_VOLUME_SELECT =
            @"SELECT prcp_Volume, Capt_US VolumeName FROM PRCompanyProfile WITH(NOLOCK) 
	            INNER JOIN Company WITH(NOLOCK) ON Comp_CompanyId = prcp_CompanyId
	            INNER JOIN Custom_Captions WITH(NOLOCK) ON Capt_Code = prcp_Volume AND Capt_Family= CASE WHEN comp_PRIndustryType='L' THEN 'prcp_VolumeL' ELSE 'prcp_Volume' END
                WHERE prcp_CompanyId = {0}";

        /// <summary>
        /// Populates the Volume portion of the page.
        /// </summary>
        protected void PopulateVolume()
        {
            string szSQL = string.Format(SQL_VOLUME_SELECT, hidCompanyID.Text);

            gvVolume.ShowHeaderWhenEmpty = true;
            gvVolume.EmptyDataText = Resources.Global.NoVolumeFound;

            gvVolume.DataSource = GetDBAccess().ExecuteReader(szSQL, null, CommandBehavior.CloseConnection, null);
            gvVolume.DataBind();
            EnableBootstrapFormatting(gvVolume);
        }

        protected void PopulateProductProvided()
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prcprpr_CompanyID", hidCompanyID.Text));

            string szSQL = GetObjectMgr().FormatSQL("SELECT * FROM vPRCompanyProductProvided WHERE prcprpr_CompanyID={0}", oParameters);
            szSQL += GetOrderByClause(gvProductProvided);

            //((EmptyGridView)gvProductProvided).EmptyTableRowText = GetNoResultsFoundMsg(Resources.Global.Products);
            gvProductProvided.ShowHeaderWhenEmpty = true;
            gvProductProvided.EmptyDataText = GetNoResultsFoundMsg(Resources.Global.Products);

            gvProductProvided.DataSource = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            gvProductProvided.DataBind();
            EnableBootstrapFormatting(gvProductProvided);
        }

        protected void PopulateServiceProvided()
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prcprpr_CompanyID", hidCompanyID.Text));

            string szSQL = GetObjectMgr().FormatSQL("SELECT * FROM vPRCompanyServiceProvided WHERE prcserpr_CompanyID={0}", oParameters);
            szSQL += GetOrderByClause(gvServiceProvided);

            //((EmptyGridView)gvServiceProvided).EmptyTableRowText = GetNoResultsFoundMsg(Resources.Global.Services);
            gvServiceProvided.ShowHeaderWhenEmpty = true;
            gvServiceProvided.EmptyDataText = GetNoResultsFoundMsg(Resources.Global.Services);

            gvServiceProvided.DataSource = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            gvServiceProvided.DataBind();
            EnableBootstrapFormatting(gvServiceProvided);
        }

        protected void PopulateSpecies()
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prcspc_CompanyID", hidCompanyID.Text));

            string szSQL = GetObjectMgr().FormatSQL("SELECT * FROM vPRCompanySpecie WHERE prcspc_CompanyID={0}", oParameters);
            szSQL += GetOrderByClause(gvSpecie);

            //((EmptyGridView)gvSpecie).EmptyTableRowText = GetNoResultsFoundMsg(Resources.Global.Species);
            gvSpecie.ShowHeaderWhenEmpty = true;
            gvSpecie.EmptyDataText = GetNoResultsFoundMsg(Resources.Global.Species);

            gvSpecie.DataSource = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            gvSpecie.DataBind();
            EnableBootstrapFormatting(gvSpecie);
        }

        private const string SQL_NUM_EMPLOYEES =
            @"SELECT comp_CompanyID, prcp_FTEmployees, prcex_Employees, ISNULL(prcp_FTEmployees,prcex_Employees) FTEmployees, capt_us[Meaning]
	            FROM Company
		            LEFT OUTER JOIN PRCompanyExperian WITH(NOLOCK) ON prcex_CompanyId = comp_CompanyID
		            LEFT OUTER JOIN PRCompanyProfile WITH(NOLOCK) ON prcp_CompanyID = comp_CompanyID 
		            LEFT OUTER JOIN Custom_Captions WITH(NOLOCK) ON capt_code = ISNULL(prcp_FTEmployees, prcex_Employees) AND Capt_Family = 'NumEmployees'
                WHERE comp_CompanyID={0}";

        protected void PopulateEmployees()
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("comp_CompanyID", hidCompanyID.Text));
            string szSQL = GetObjectMgr().FormatSQL(SQL_NUM_EMPLOYEES, oParameters);

            using (IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null))
            {
                if(oReader.Read())
                {
                    string szData; 
                    if (oReader["prcex_Employees"] == DBNull.Value && oReader["prcp_FTEmployees"] == DBNull.Value)
                        szData = Resources.Global.NotProvided;
                    else
                        szData = UIUtils.GetString(oReader["Meaning"]);

                    if (oReader["prcp_FTEmployees"] == DBNull.Value && oReader["prcex_Employees"] != DBNull.Value)
                        szData += "<br/><i>" + Resources.Global.DataLicensedFromExperian + "</i>";

                    litNumberofEmployees.Text = szData;
                }
            }
        }

        protected void PopulateCertifications()
        {
            pnlCertifications.Visible = true;
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prcp_CompanyID", hidCompanyID.Text));

            string szSQL = GetObjectMgr().FormatSQL("SELECT prcp_Organic, prcp_FoodSafetyCertified FROM PRCompanyProfile WHERE prcp_CompanyID={0}", oParameters);

            using (IDataReader reader = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null))
            {
                if (reader.Read())
                {
                    litOrganic.Text = UIUtils.GetStringFromBool(reader[0]);
                    litFoodSafetyCertified.Text = UIUtils.GetStringFromBool(reader[1]);
                }
            }

            rowSelfReported.Visible = true; //(!string.IsNullOrEmpty(litOrganic.Text) || !string.IsNullOrEmpty(litFoodSafetyCertified.Text));
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

        override protected bool IsAuthorizedForPage()
        {
            if (_oUser.HasPrivilege(SecurityMgr.Privilege.CompanyDetailsClassificationsCommoditesPage).Enabled ||
                _oUser.HasPrivilege(SecurityMgr.Privilege.CompanyDetailsClassificationsCommoditesProductSerivcesSpeciesPage).Enabled)
            {
                return true;
            }
            return false;
        }
    }
}