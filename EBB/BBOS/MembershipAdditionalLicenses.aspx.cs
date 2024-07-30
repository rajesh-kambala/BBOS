/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2023

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: MembershipAdditionalLicenses.aspx.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Data;
using System.Collections;
using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Allows the user to purchase additional user liceneses in addtion to
    /// the selected membership.  Only those licenes with the same access level
    /// or lower than the currently selected primary membership are made available.
    /// </summary>
    public partial class MembershipAdditionalLicenses : MembershipBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            SetPageTitle(Resources.Global.SelectMembershipOptions, Resources.Global.AdditionalUsers);
            EnableFormValidation();

            if (!IsPostBack)
            {
                PopulateForm();
            }
        }

        /// <summary>
        /// Populates the grid listing the different additional unit
        /// packages available.
        /// </summary>
        protected void PopulateForm()
        {
            ucMembershipSelected.WebUser = _oUser;
            ucMembershipSelected.LoadMembership();

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("PricingListID", PRICING_LIST_ONLINE));
            oParameters.Add(new ObjectParameter("prod_ProductFamilyID", Utilities.GetIntConfigValue("AdditionalUsersProductFamily", 6)));
            oParameters.Add(new ObjectParameter("prod_IndustryTypeCode", "%," + _oUser.prwu_IndustryType + ",%"));

            string szSQL = string.Format(SQL_SELECT_MEMBERSHIP_PRODUCTS,
                                         GetObjectMgr().GetLocalizedColName("prod_Name"),
                                         GetObjectMgr().GetLocalizedColName("prod_PRDescription"));

            repMemberships.DataSource = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            repMemberships.DataBind();

            if (repMemberships.Items.Count == 0)
            {
                if (Request.UrlReferrer.LocalPath.EndsWith(PageConstants.MEMBERSHIP_USERS))
                {
                    if(_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                        Response.Redirect(PageConstants.MEMBERSHIP_SELECT);
                    else
                        Response.Redirect(PageConstants.MEMBERSHIP_SELECT_OPTION);
                }
                else
                {
                    Response.Redirect(PageConstants.MEMBERSHIP_USERS);
                }
            }

            if (_oUser.prwu_IndustryType != GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                litAdditionalLicenseAccessLevelMsg.Text += "  " + Resources.Global.AdditionalLicensesAccessLevelMsg2;
            }
        }

        protected const string SQL_SELECT_SERVICES_COUNT =
            @"SELECT COUNT(*) FROM PRService WITH (NOLOCK)
	            INNER JOIN NewProduct WITH (NOLOCK) ON prse_ServiceCode = prod_code AND prod_PRRecurring = 'Y' 
              WHERE prse_HQID = @prse_HQID
                AND prod_Code <> 'CSUPD' ";

        private bool HasServices()
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prse_HQID", _oUser.prwu_HQID));

            int count = (int)GetDBAccess().ExecuteScalar(SQL_SELECT_SERVICES_COUNT, oParameters);
            return (count > 0);
        }

        /// <summary>
        /// Store the user selections for use by the CreditCardPayment page.
        /// </summary>
        protected void StoreSelections()
        {
            SortedList slAdditionalLicenses = (SortedList)Session["slAdditionalLiceness"];
            if (slAdditionalLicenses == null)
            {
                slAdditionalLicenses = new SortedList();
                Session["slAdditionalLicenses"] = slAdditionalLicenses;
            }

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("PricingListID", PRICING_LIST_ONLINE));
            oParameters.Add(new ObjectParameter("prod_ProductFamilyID", Utilities.GetIntConfigValue("AdditionalUsersProductFamily", 6)));
            oParameters.Add(new ObjectParameter("prod_IndustryTypeCode", "%," + _oUser.prwu_IndustryType + ",%"));

            string szSQL = string.Format(SQL_SELECT_MEMBERSHIP_PRODUCTS,
                                         GetObjectMgr().GetLocalizedColName("prod_Name"),
                                         GetObjectMgr().GetLocalizedColName("prod_PRDescription"));

            int iAdditionalUsers = 0;
            bool bHasServices = HasServices();

            IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            try
            {
                while (oReader.Read())
                {
                    string szControlName = "txtProductID" + oReader.GetInt32(0).ToString();

                    if (GetRequestParameter(szControlName, false) == null)
                    {

                        // If the user didn't specify any value, make sure
                        // we remove and previously specified information for
                        // this product.
                        if (_oUser.IsLimitado)
                        {
                            //ITA users start with 0 services, so can't remove ccproductinfo because it erases the membership they are trying to upgrade to
                            if(bHasServices)
                                RemoveCreditCardProductInfo(oReader.GetInt32(0).ToString());
                        }
                        else
                        {
                            RemoveCreditCardProductInfo(oReader.GetInt32(0).ToString());
                        }

                        if (slAdditionalLicenses.ContainsKey(oReader.GetInt32(0)))
                        {
                            slAdditionalLicenses.Remove(oReader.GetInt32(0));
                            Session.Remove("lAdditionalUsers_" + oReader.GetInt32(0).ToString());
                        }
                    }
                    else
                    {
                        iAdditionalUsers += Convert.ToInt32(GetRequestParameter(szControlName));
                        AddCreditCardProductInfo(oReader.GetInt32(0).ToString(),
                                                 Convert.ToInt32(GetRequestParameter(szControlName)),
                                                 oReader.GetDecimal(7),
                                                 oReader.GetString(6));

                        slAdditionalLicenses[oReader.GetInt32(0)] = Convert.ToInt32(GetRequestParameter(szControlName));
                        ProcessLicenses("lAdditionalUsers_" + oReader.GetInt32(0).ToString(), Convert.ToInt32(GetRequestParameter(szControlName)), oReader.GetInt32(5));
                    }
                }
            }
            finally
            {
                oReader.Close();
            }

            SetRequestParameter("AdditionalUserCount", iAdditionalUsers.ToString());
        }

        /// <summary>
        /// Helper method returns the current quantity
        /// for the specified product
        /// </summary>
        /// <param name="iProductID"></param>
        /// <returns></returns>
        protected string GetProductQuantity(int iProductID)
        {
            SortedList slAdditionalLicenses = (SortedList)Session["slAdditionalLicenses"];
            if (slAdditionalLicenses == null)
            {
                return string.Empty;
            }

            return Convert.ToString(slAdditionalLicenses[iProductID]);
        }

        /// <summary>
        /// Helper method determines if the product is disabled by checking
        /// it's access level against the primary membership's access level.
        /// </summary>
        /// <param name="iPRWebAccessLevel"></param>
        /// <returns></returns>
        protected string GetDisabled(int iPRWebAccessLevel)
        {
            if (iPRWebAccessLevel <= Convert.ToInt32(GetRequestParameter("MembershipAccessLevel")))
            {
                return string.Empty;
            }

            return " disabled ";
        }

        protected void btnNext_Click(object sender, EventArgs e)
        {
            StoreSelections();
            Response.Redirect(PageConstants.MEMBERSHIP_USERS);
        }

        protected void btnPrevious_Click(object sender, EventArgs e)
        {
            StoreSelections();

            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                Response.Redirect(PageConstants.MEMBERSHIP_SELECT);
            }
            else
            {
                Response.Redirect(PageConstants.MEMBERSHIP_SELECT_OPTION);
            }
        }
    }
}
