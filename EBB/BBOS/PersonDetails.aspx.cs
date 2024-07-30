/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2017

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: PersonDetails
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
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Displays the companies and notes associated with
    /// the specified person.
    /// </summary>
    public partial class PersonDetails : PersonDetailsBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_TOGGLE_FUNCTIONS_FILE));
            SetPageTitle(Resources.Global.PersonDetails);
            if (!IsPostBack)
            {
                hidPersonID.Text = GetRequestParameter("PersonID");
                PopulateForm();
            }
        }

        protected const string SQL_SELECT_PERSON =
            @"SELECT dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, NULL, pers_Suffix) as PersonName, pers_PRLinkedInProfile 
                FROM Person WITH (NOLOCK) 
               WHERE pers_PersonID = {0}";

        /// <summary>
        /// Populates the form.
        /// </summary>
        protected void PopulateForm()
        {
            string linkedInProfileURL = null;

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("pers_PersonID", GetRequestParameter("PersonID")));
            string szSQL = GetObjectMgr().FormatSQL(SQL_SELECT_PERSON, oParameters);

            using (IDataReader reader = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null))
            {
                if (reader.Read())
                {
                    lblPersonName.Text = reader.GetString(0);
                    linkedInProfileURL = GetDBAccess().GetString(reader, 1);
                }
            }

            PopulateNotes();
            PopulateCompanies();
        }

        protected const string SQL_PERSON_COMPANIES =
             @"SELECT pers_PersonID, peli_PRTitle, RTRIM(emai_EmailAddress) As Email, 
                      ISNULL(dbo.ufn_FormatPhone(pphone.phon_CountryCode, pphone.phon_AreaCode, pphone.phon_Number, pphone.phon_PRExtension), dbo.ufn_FormatPhone(cphone.phon_CountryCode, cphone.phon_AreaCode, cphone.phon_Number, cphone.phon_PRExtension)) As Phone, 
                      dbo.ufn_HasNote({1}, {4}, comp_CompanyID, 'C') As HasNote,
                      dbo.ufn_HasNewClaimActivity(comp_PRHQID, {2}) as HasNewClaimActivity, 
                      dbo.ufn_HasMeritoriousClaim(comp_PRHQID, {3}) as HasMeritoriousClaim,
                      dbo.ufn_HasCertification(comp_PRHQID) as HasCertification,
                      dbo.ufn_HasCertification_Organic(comp_PRHQID) as HasCertification_Organic,
                      dbo.ufn_HasCertification_FoodSafety(comp_PRHQID) as HasCertification_FoodSafety,
                      vPRBBOSCompanyList.* 
                FROM Person_Link WITH (NOLOCK) 
                     INNER JOIN Person WITH (NOLOCK) ON peli_PersonID = pers_PersonID 
                     INNER JOIN vPRBBOSCompanyList ON peli_CompanyID = comp_CompanyID 
                     LEFT OUTER JOIN vPRPersonEmail em WITH (NOLOCK) ON peli_PersonID = em.ELink_RecordID AND peli_CompanyID = emai_CompanyID AND em.ELink_Type='E' AND em.emai_PRPreferredPublished='Y' 
                     LEFT OUTER JOIN vPRCompanyPhone cphone WITH (NOLOCK) ON peli_CompanyID = cphone.PLink_RecordID AND cphone.phon_PRIsPhone = 'Y' AND cphone.phon_PRPreferredPublished = 'Y'  
                     LEFT OUTER JOIN vPRPersonPhone pphone WITH (NOLOCK) ON  peli_PersonID = pphone.PLink_RecordID AND peli_CompanyID = pphone.phon_CompanyID AND pphone.phon_PRIsPhone = 'Y' AND pphone.phon_PRPreferredPublished = 'Y'  
               WHERE peli_PersonID = {0} 
                 AND peli_PRStatus = '1' 
                 AND peli_PREBBPublish = 'Y' ";
        /// <summary>
        /// Populates the Companies portion of the page.
        /// </summary>
        protected void PopulateCompanies()
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("PersonID", hidPersonID.Text));
            oParameters.Add(new ObjectParameter("UserID", _oUser.prwu_WebUserID));
            oParameters.Add(new ObjectParameter("NewClaimActivity", DateTime.Today.AddDays(0 - Configuration.ClaimActivityNewThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss")));
            oParameters.Add(new ObjectParameter("MeritoriousClaim", DateTime.Today.AddDays(0 - Configuration.ClaimActivityMeritoriousThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss")));
            oParameters.Add(new ObjectParameter("HQID", _oUser.prwu_HQID));

            string szSQL = GetObjectMgr().FormatSQL(SQL_PERSON_COMPANIES, oParameters);
            szSQL += GetOrderByClause(gvCompanies);

            gvCompanies.DataSource = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            gvCompanies.DataBind();
            EnableBootstrapFormatting(gvCompanies);
            //OptimizeViewState(gvCompanies);

            if (gvCompanies.Rows.Count > 0)
            {
                //Page.ClientScript.RegisterStartupScript(this.GetType(),
                //                                            ID + "EnableRowHighlight",
                //                                        "EnableRowHighlight(document.getElementById('" + gvCompanies.ClientID + "'));",
                //                                        true);
            }
        }

        protected const string SQL_SELECT_NOTES =
             @"SELECT * 
                 FROM vPRWebUserNote 
                WHERE ((prwun_HQID = {0}  AND prwun_IsPrivate IS NULL) OR (prwun_WebUserID={1} AND prwun_IsPrivate = 'Y')) 
                  AND prwun_AssociatedID={2} 
                  AND prwun_AssociatedType={3}";

        /// <summary>
        /// Populates the Notes section of the page
        /// </summary>
        protected void PopulateNotes()
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prwun_HQID", _oUser.prwu_HQID));
            oParameters.Add(new ObjectParameter("prwun_WebUserID", _oUser.prwu_WebUserID));
            oParameters.Add(new ObjectParameter("prwun_AssociatedID", hidPersonID.Text));
            oParameters.Add(new ObjectParameter("prwun_AssociatedType", "P"));

            string szSQL = GetObjectMgr().FormatSQL(SQL_SELECT_NOTES, oParameters);
            IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            try
            {
                while (oReader.Read())
                {
                    if (GetDBAccess().GetString(oReader, "prwun_IsPrivate") == "Y")
                    {
                        litPrivateNote.Text = FormatTextForHTML(GetDBAccess().GetString(oReader, "prwun_Note"));
                        lblPrivateNoteAudit.Text = string.Format("Last Updated {0}",
                                                            GetStringFromDate(GetDBAccess().GetDateTime(oReader, "prwun_UpdatedDate")));

                        Print.CommandArgument = GetDBAccess().GetInt32(oReader, "prwun_WebUserNoteID").ToString();
                    }
                }
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }
        }

        /// <summary>
        /// Generates the Notes report for the selected items.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnNotesReportOnClick(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.Format(PageConstants.GET_REPORT, GetReport.NOTES_REPORT) + "&PersonID=" + hidPersonID.Text);
        }

        /// <summary>
        /// Redirects to GetVCard.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnVCardOnClick(object sender, EventArgs e)
        {
            ImageButton btnVCard = (ImageButton)sender;
            string szCompanyID = btnVCard.Attributes["value"];
            Response.Redirect(PageConstants.Format(PageConstants.GET_VCARD, szCompanyID, hidPersonID.Text));
        }

        protected void btnEditOnClick(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.Format(PageConstants.PERSON_DETAILS_USER_EDIT, hidPersonID.Text));
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
                Literal litLegalName = (Literal)e.Row.FindControl("litLegalName");
                if (string.IsNullOrEmpty(litLegalName.Text) || litLegalName.Text == "<br/>")
                    litLegalName.Visible = false;
            }

        }
    }
}
