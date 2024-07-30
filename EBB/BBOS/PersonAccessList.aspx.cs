/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2019

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: PersonAccessList.aspx.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Data;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    public partial class PersonAccessList : PageBase
    {
        protected const string SQL_SELECT_PERSON_ACCESS =
            @"SELECT dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, NULL, pers_Suffix) As PersonName, pers_LastName, 
                     peli_PREBBPublish, dbo.ufn_GetCustomCaptionValue('peli_PRStatus', peli_PRStatus, @Culture) As peli_PRStatus, 
                     ISNULL(dbo.ufn_GetCustomCaptionValue('prwu_AccessLevel', prwu_AccessLevel, @Culture), '{0}') As prwu_AccessLevel, peli_PRSubmitTES, 
                     peli_PRUpdateCL, peli_PRUseServiceUnits, peli_PRUseSpecialServices, CityStateCountryShort, 
                     CASE WHEN prwuls_ServiceCode IS NOT NULL THEN 'Y' ELSE NULL END As HasLSSAccess
                FROM Person WITH (NOLOCK)
                     INNER JOIN Person_Link WITH (NOLOCK) ON pers_PersonID = peli_PersonID 
                     INNER JOIN Company WITH (NOLOCK) on peli_CompanyID = comp_CompanyID 
                     INNER JOIN vPRLocation on comp_PRListingCityID = prci_CityID 
                     LEFT OUTER JOIN PRWebUser WITH (NOLOCK) ON peli_PersonLinkID = prwu_PersonLinkID 
                     LEFT OUTER JOIN PRWebUserLocalSource WITH (NOLOCK) ON prwu_WebUserID = prwuls_WebUserID
               WHERE comp_prHQID = @comp_HQID 
                 AND comp_PRListingStatus NOT IN ('D', 'N3', 'N5', 'N6') 
                 AND peli_PRStatus IN (1)";


        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            SetPageTitle(Resources.Global.PersonnelList);
            litHeaderMsg.Text = string.Format(Resources.Global.PersonAccessListMsg, Utilities.GetConfigValue("PersonAccessListHelpEmail", "customerservice@bluebookservices.com"));
            if (!IsPostBack)
            {
                SetSortField(gvPersonAccess, "pers_LastName");
                PopulateForm();
            }
        }

        protected void PopulateForm()
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("Culture", _oUser.prwu_Culture));
            oParameters.Add(new ObjectParameter("comp_HQID", _oUser.prwu_HQID));

            string szSQL = string.Format(SQL_SELECT_PERSON_ACCESS, Resources.Global.None) + GetOrderByClause(gvPersonAccess);
            gvPersonAccess.DataSource = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            gvPersonAccess.DataBind();
            EnableBootstrapFormatting(gvPersonAccess);

            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                gvPersonAccess.Columns[7].Visible = false;
                gvPersonAccess.Columns[8].Visible = false;
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

        protected void btnDoneOnClick(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.MEMBERSHIP_SUMMARY);
        }

        protected override bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.PersonAccessListPage).HasPrivilege;
        }

        protected override bool IsAuthorizedForData()
        {
            return true;
        }
    }
}
