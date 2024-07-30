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

 ClassName: CompanyContacts
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
using System.Collections.Generic;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Displays company data and listing.
    /// </summary>
    public partial class CompanyContacts : CompanyDetailsBase
    {
        CompanyData _ocd;
        protected List<int> lstPerson_AC = new List<int>();
        protected List<int> lstPerson_HCO = new List<int>();


        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
            Page.Title = Resources.Global.BlueBookService;
            ((BBOS)Master).HideOldTopMenu();

            ApplySecurity();

            SetPopover();

            if (!IsPostBack)
            {
                LoadLookupValues();
                hidCompanyID.Text = GetRequestParameter("CompanyID", true, true);

                SetSortField(gvContacts, "peli_PRSequence");
                PopulateForm();
            }

            RedirectToHomeIfCompanyMissing(hidCompanyID.Text);

            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_FUNCTIONS2_FILE));
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_VALIDATION_FILE));

            //Set user controls
            ucSidebar.WebUser = _oUser;
            ucSidebar.CompanyID = UIUtils.GetString(hidCompanyID.Text);
            ucCompanyHero.WebUser = _oUser;
            ucCompanyHero.CompanyID = UIUtils.GetString(hidCompanyID.Text);
            ucCompanyBio.WebUser = _oUser;
            ucCompanyBio.CompanyID = UIUtils.GetString(hidCompanyID.Text);
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

            btnGenerateExport.Attributes.Add("onclick", "return confirmOneSelected('export option', 'ctl00$contentLeftSidebar$rbExport')");
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

            //Person Count calculations
            hidPersonIDs_HCO.Value = string.Join<int>(",", lstPerson_HCO);
            hidSelectedCount.Value = lstPerson_HCO.Count.ToString(); //Changes if radio buttons selection changes
            hidPersonIDs_AC.Value = string.Join<int>(",", lstPerson_AC);

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
            int exportCount;
            string szPersonIDs;
            if (rbExportHCO.Checked)
            {
                exportCount = hidPersonIDs_HCO.Value.Split(',').Length;
                szPersonIDs = hidPersonIDs_HCO.Value;
            }
            else
            {
                exportCount = hidPersonIDs_AC.Value.Split(',').Length;
                szPersonIDs = hidPersonIDs_AC.Value;
            }
            
            CheckDataExport(exportCount);

            // CreateRequest (specify appropriate code, Request.Referrer aspx)           
            try
            {
                GetObjectMgr().CreateRequest("PE", szPersonIDs, "CompanyContacts.aspx", null);
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

            //Exports management
            hidExportsPeriod.Value = "D";

            if (_oUser.prwu_BBID == 100002 || _oUser.prwu_BBID == 204482)
            {
                hidExportsMax.Value = "9999999";
                hidExportsUsed.Value = "0";
            }
            else if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                hidExportsMax.Value = GetExportsMax_Lumber().ToString();
                switch (_oUser.prwu_AccessLevel)
                {
                    case PRWebUser.SECURITY_LEVEL_STANDARD:
                        //STANDARD - L200
                        hidExportsUsed.Value = _oUser.GetDataExportCount_Company_Lumber_Current_Month().ToString();
                        hidExportsPeriod.Value = "M";
                        break;
                    case PRWebUser.SECURITY_LEVEL_ADVANCED:
                        //ADVANCED - L300
                        hidExportsUsed.Value = _oUser.GetDataExportCount_Company_Lumber_Current_Day().ToString();
                        hidExportsPeriod.Value = "D";
                        break;
                    default:
                        //BASIC - L100
                        hidExportsUsed.Value = _oUser.GetDataExportCount_Company_Lumber_Current_Day().ToString();
                        hidExportsPeriod.Value = "D";
                        break;
                }

                if (_oUser.prwu_AccessLevel < PRWebUser.SECURITY_LEVEL_ADVANCED) //Defect 4474 - lumber 400 can export contact names
                    btnGenerateExport.Enabled = false;
            }
            else
            {
                hidExportsUsed.Value = _oUser.GetDataExportCount().ToString();
                hidExportsPeriod.Value = "D";
                hidExportsMax.Value = GetExportsMax_Produce().ToString();
                
                if (Convert.ToInt32(hidExportsMax.Value) == 0)
                    btnGenerateExport.Enabled = false;
            }

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
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                int pers_PersonID = Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "pers_PersonID"));
                string peli_PRRole = Convert.ToString(DataBinder.Eval(e.Row.DataItem, "peli_PRRole"));
                lstPerson_AC.Add(pers_PersonID);
                if(peli_PRRole.Contains(",HE,"))
                    lstPerson_HCO.Add(pers_PersonID);
            }
                
        }

        protected override bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.CompanyDetailsContactsPage).HasPrivilege;
        }
    }
}