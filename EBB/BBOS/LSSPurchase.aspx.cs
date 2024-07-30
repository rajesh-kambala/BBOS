/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2016-2020

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: LSSPurchase.aspx.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using PRCo.EBB.BusinessObjects;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using TSI.BusinessObjects;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    public partial class LSSPurchase : MembershipBase
    {
        private int lssProductID = Utilities.GetIntConfigValue("LSSProductID", 83);
        private int lssAdditionalProductID = Utilities.GetIntConfigValue("LSSAdditionalProductID", 84);

        protected const string SQL_SELECT_PERSON_ACCESS =
            @"SELECT dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, NULL, pers_Suffix) As PersonName, pers_LastName, 
                     dbo.ufn_GetCustomCaptionValue('prwu_AccessLevel', prwu_AccessLevel, @Culture) As prwu_AccessLevel, CityStateCountryShort, 
                     CASE WHEN prwuls_ServiceCode IS NOT NULL THEN 'Y' ELSE NULL END As HasLSSAccess, prwu_WebUserID
                FROM Person WITH (NOLOCK)
                     INNER JOIN Person_Link WITH (NOLOCK) ON pers_PersonID = peli_PersonID 
                     INNER JOIN Company WITH (NOLOCK) on peli_CompanyID = comp_CompanyID 
                     INNER JOIN vPRLocation on comp_PRListingCityID = prci_CityID 
                     INNER JOIN PRWebUser WITH (NOLOCK) ON peli_PersonLinkID = prwu_PersonLinkID 
                     LEFT OUTER JOIN PRWebUserLocalSource WITH (NOLOCK) ON prwu_WebUserID = prwuls_WebUserID
               WHERE comp_prHQID = @comp_HQID 
                 AND comp_PRListingStatus NOT IN ('D', 'N3', 'N5', 'N6') 
                 AND peli_PRStatus IN (1)
                 AND prwu_Disabled IS NULL";

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            SetPageTitle("Purchase Access to Local Source Data");
            if (!IsPostBack)
            {
                SetSortField(gvPersonAccess, "pers_LastName");
                hidTriggerPage.Text = Request.ServerVariables["SCRIPT_NAME"];
                PopulateForm();
            }
        }

        protected void PopulateForm()
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("Culture", _oUser.prwu_Culture));
            oParameters.Add(new ObjectParameter("comp_HQID", _oUser.prwu_HQID));

            string szSQL = SQL_SELECT_PERSON_ACCESS + GetOrderByClause(gvPersonAccess);
            gvPersonAccess.DataSource = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            gvPersonAccess.DataBind();
            EnableBootstrapFormatting(gvPersonAccess);
        }

        protected void btnPurchaseOnClick(object sender, EventArgs e)
        {
            //After clicking a “Purchase” button at bottom, the user should go to Terms.aspx which they must accept.
            Session["LSSPurchase"] = "Y";

            Dictionary<string, string> lstUserID_New = new Dictionary<string, string>();
            Dictionary<string, string> lstUserID_Existing = new Dictionary<string, string>();

            foreach (GridViewRow oRow in gvPersonAccess.Rows)
            {
                HtmlInputCheckBox cbPRWebUserID = (HtmlInputCheckBox)oRow.FindControl("cbPRWebUserID");
                Literal litHasLSSAccess = (Literal)oRow.FindControl("litHasLSSAccess");
                Literal litPersonName = (Literal)oRow.FindControl("litPersonName");

                if (cbPRWebUserID.Checked)
                {
                    if (litHasLSSAccess.Text == "Yes")
                        lstUserID_Existing.Add(cbPRWebUserID.Value, litPersonName.Text);
                    else
                        lstUserID_New.Add(cbPRWebUserID.Value, litPersonName.Text);
                }
            }

            Session["LSSPurchaseUserIDList_New"] = lstUserID_New; 
            Session["LSSPurchaseUserIDList_Existing"] = lstUserID_Existing;

            Response.Redirect(PageConstants.TERMS);
        }

        protected void btnCancelOnClick(object sender, EventArgs e)
        {
            Response.Redirect(GetReturnURL(PageConstants.MEMBERSHIP_SUMMARY));
        }

        protected override bool IsAuthorizedForPage()
        {
            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                return false;
            }

            return true;
        }

        protected override bool IsAuthorizedForData()
        {
            return true;
        }

        protected void gvPersonAccess_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if(e.Row.RowType == DataControlRowType.DataRow)
            {
                HtmlInputCheckBox cbPRWebUserID = (HtmlInputCheckBox)e.Row.FindControl("cbPRWebUserID");

                object HasLSSAccess = DataBinder.Eval(e.Row.DataItem, "HasLSSAccess");

                if (!(HasLSSAccess == null || HasLSSAccess == DBNull.Value))
                {
                    cbPRWebUserID.Checked = true;
                    cbPRWebUserID.Disabled = true;
                }
            }
        }

        protected void gvPersonAccess_Sorting(object sender, GridViewSortEventArgs e)
        {
            SetSortingAttributes((GridView)sender, e);
            PopulateForm();
        }
    }
}
