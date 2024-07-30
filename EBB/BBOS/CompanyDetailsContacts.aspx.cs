/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2020

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CompanyDetailsContacts.aspx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Displays the associated person and personal contacts for the 
    /// specified company.
    /// </summary>
    public partial class CompanyDetailsContacts : CompanyDetailsBase
    {
        CompanyData _ocd;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            // Set page title, sub-title
            SetPageTitle(Resources.Global.CompanyDetails, Resources.Global.Contacts, true);
            ImageButton btnPrint = ((ImageButton)Master.FindControl("btnPrint"));
            btnPrint.Click += new ImageClickEventHandler(btnPrint_Click);

            // Add company submenu to this page
            SetSubmenu("btnCompanyDetailsContacts");

            ApplySecurity();

            SetPopover();

            if (!IsPostBack)
            {
                LoadLookupValues();
                hidCompanyID.Text = GetRequestParameter("CompanyID", true, true);
                SetSortField(gvContacts, "peli_PRSequence");
                PopulateForm();
            }
        }

        protected void btnPrint_Click(object sender, ImageClickEventArgs e)
        {
            string szScript = "setTimeout(function() { printdiv(); }, 1000);"; //without delay the print window can be a garbled mess
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "printx", string.Format("<script>{0}</script>", szScript), false);
        }

        protected void SetPopover()
        {
            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                WhatIsContactExportCHE.Attributes.Add("data-bs-title", Resources.Global.WhatIsContactExportCHE_L);
                WhatIsContactExportAll.Attributes.Add("data-bs-title", Resources.Global.WhatIsContactExportAll_L);
            }
            else
            {
                WhatIsContactExportCHE.Attributes.Add("data-bs-title", Resources.Global.WhatIsContactExportCHE);
                WhatIsContactExportAll.Attributes.Add("data-bs-title", Resources.Global.WhatIsContactExportAll);
            }
        }

        /// <summary>
        /// Binds the lookup values 
        /// </summary>
        protected void LoadLookupValues()
        {
            BindLookupValues(ddlContactExportFormat, GetReferenceData("ContactExportFormat"), _oUser.prwu_Culture);
        }

        /// <summary>
        /// Populates the page.
        /// </summary>
        protected void PopulateForm()
        {
            PopulatePersons();
            //PopulatePersonalContacts();

            //Get cached company data
            _ocd = GetCompanyDataFromSession();

            if (_ocd.bLocalSource)
            {
                fsContactExportSettings.Visible = false;
                ucCompanyDetailsHeaderMeister.MeisterVisible = true;
            }

            btnGenerateExport.Attributes.Add("onclick", "return confirmOneSelected('export option', 'rbExport')");
        }

        protected const string SQL_SELECT_PERSONS =
            @"SELECT *, 
					 dbo.ufn_GetCustomCaptionValue('pers_TitleCode', peli_PRTitleCode, '{0}') As peli_PRTitleCode, dbo.ufn_HasNote({2}, {3}, pers_PersonID, '{4}') As HasNote  
				FROM vPRBBOSPersonList
			   WHERE peli_CompanyID={1}";
        /// <summary>
        /// Populates the Persons portion of the
        /// page.
        /// </summary>
        protected void PopulatePersons()
        {

            string[] aszParameters = {_oUser.prwu_Culture,
                                      hidCompanyID.Text,
                                      _oUser.UserID,
                                      _oUser.prwu_HQID.ToString(),
                                      "P"};


            string szSQL = string.Format(SQL_SELECT_PERSONS, aszParameters);
            szSQL += GetOrderByClause(gvContacts);

            //((EmptyGridView)gvContacts).EmptyTableRowText = GetNoResultsFoundMsg(Resources.Global.Contacts);
            gvContacts.ShowHeaderWhenEmpty = true;
            gvContacts.EmptyDataText = GetNoResultsFoundMsg(Resources.Global.Contacts);

            gvContacts.DataSource = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection);
            gvContacts.DataBind();
            EnableBootstrapFormatting(gvContacts);

            gvContacts.Columns[0].Visible = _oUser.HasPrivilege(SecurityMgr.Privilege.BusinessReportSurvey).HasPrivilege;

            Session["CompanyDetailsContactsCount"] = gvContacts.Rows.Count;
        }

        protected const string SQL_SELECT_CONTACTS =
            @"SELECT prwuc_WebUserContactID, prwuc_LastName, prwuc_FirstName, dbo.ufn_FormatPerson(prwuc_FirstName, prwuc_LastName, prwuc_MiddleName, null, prwuc_Suffix) as ContactName, prwuc_Title, prwuc_Email, prwuc_PhoneAreaCode, prwuc_PhoneNumber, prwuc_IsPrivate, prwuc_UpdatedDate, dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, pers_PRNickname1, pers_Suffix) As UpdatedBy, dbo.ufn_GetWebUserLocation(prwuc_UpdatedBy) As UpdatedByLocation 
			   FROM PRWebUserContact WITH (NOLOCK)
					INNER JOIN PRWebUser WITH (NOLOCK) on prwuc_WebUserID = prwu_WebUserID 
					INNER JOIN Person_Link WITH (NOLOCK) ON prwu_PersonLinkID = peli_PersonLinkID 
					INNER JOIN Person WITH (NOLOCK) ON peli_PersonID = pers_PersonID 
			  WHERE ((prwuc_HQID = {0}  AND prwuc_IsPrivate IS NULL) OR (prwuc_WebUserID={1} AND prwuc_IsPrivate = 'Y'))
				AND prwuc_AssociatedCompanyID={2}";


        /// <summary>
        /// Redirects to GetVCard.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnVCardOnClick(object sender, EventArgs e)
        {
            ImageButton btnVCard = (ImageButton)sender;
            string szPersonID = btnVCard.Attributes["value"];
            Response.Redirect(PageConstants.Format(PageConstants.GET_VCARD, hidCompanyID.Text, szPersonID));
        }

        /// <summary>
        /// Redirects to GetReport.aspx specifying the Contact Export report with 
        /// the user specified parameters.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnGenerateExportOnClick(object sender, EventArgs e)
        {

            CheckDataExport((int)Session["CompanyDetailsContactsCount"]);

            // CreateRequest (specify appropriate code, Request.Referrer aspx)           
            try
            {
                GetObjectMgr().CreateRequest("CCE", hidCompanyID.Text, "CompanyDetailsContacts.aspx", null);
            }
            catch (Exception eX)
            {
                // There's nothing the end user can do about this so
                // just log it and keep moving.
                LogError(eX);

                if (Configuration.ThrowDevExceptions)
                {
                    throw;
                }
            }

            string contactType = null;
            if (rbExportAC.Checked)
            {
                contactType = "AC";
            }
            else if (rbExportHCO.Checked)
            {
                contactType = "HCO";
            }

            string szReportURL;
            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                szReportURL = PageConstants.Format(PageConstants.GET_REPORT, GetReport.CONTACT_EXPORT_LUMBER);
            }
            else
            {
                szReportURL = PageConstants.Format(PageConstants.GET_REPORT, GetReport.CONTACT_EXPORT);
            }

            szReportURL += "&CompanyIDList=" + hidCompanyID.Text;
            szReportURL += "&ContactType=" + contactType;
            szReportURL += "&ExportType=" + ddlContactExportFormat.SelectedValue;

            Response.Redirect(szReportURL);
        }

        protected void btnAddPersonalContactOnClick(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.Format(PageConstants.USER_CONTACT_ADD, hidCompanyID.Text));
        }


        /// <summary>
        /// Applies the appropriate security to the page.
        /// </summary>
        protected void ApplySecurity()
        {
            ApplySecurity(rbExportAC, SecurityMgr.Privilege.DataExportContactExportAllContacts);
            ApplySecurity(rbExportHCO, SecurityMgr.Privilege.DataExportContactExportHeadExecutive);
            ApplySecurity(fsContactExportSettings, SecurityMgr.Privilege.DataExportPage);

            ApplySecurity(btnGenerateExport, SecurityMgr.Privilege.DataExportPage);

            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                if (_oUser.prwu_AccessLevel < PRWebUser.SECURITY_LEVEL_ADVANCED) //Defect 4474 - lumber 400 can export contact names
                    btnGenerateExport.Enabled = false;
            }
            else
            {
                if (_oUser.prwu_AccessLevel <= PRWebUser.SECURITY_LEVEL_ADVANCED)
                    btnGenerateExport.Enabled = false;
            }
            
            //ApplySecurity(btnAddPersonalContact, SecurityMgr.Privilege.UserContacts);

            //ApplyReadOnlyCheck(btnAddPersonalContact);

            if (_oUser.IsTrialPeriodActive())
            {
                btnGenerateExport.Enabled = false;
            }
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

        protected override bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.CompanyDetailsContactsPage).HasPrivilege;
        }
    }
}
