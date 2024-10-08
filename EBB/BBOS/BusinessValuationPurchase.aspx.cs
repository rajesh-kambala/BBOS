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

 ClassName: BusValuationPurchase.aspx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Data;
using System.Web.UI;
using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This page allows the user to select a product for 
    /// additional service units.
    /// </summary>
    public partial class BusinessValuationPurchase : PageBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            SetPageTitle(Resources.Global.PurchaseBusinessValuation);
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_FUNCTIONS2_FILE));
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_VALIDATION_FILE));
            btnPurchase.Attributes.Add("onclick", "return confirmSelect('" + Resources.Global.Product + "', 'rbProductID')");
            if (!IsPostBack)
            {
                hidTriggerPage.Text = Request.ServerVariables["SCRIPT_NAME"];
                PopulateForm();
            }
        }

        protected const string SQL_SELECT_BUS_VALUATION =
            @"SELECT prod_ProductID, '{0}' as prod_Name, dbo.ufn_GetProductPrice(prod_ProductID, @PricingListID) as pric_Price
                FROM NewProduct 
               WHERE prod_ProductFamilyID=@prod_ProductFamilyID 
                 AND Prod_ProductID = 109
				 AND prod_IndustryTypeCode LIKE @prod_IndustryTypeCode 
            ORDER BY prod_PRSequence";
        /// <summary>
        /// Populates the grid listing the different additional unit
        /// packages available.
        /// </summary>
        protected void PopulateForm()
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("PricingListID", PRICING_LIST_ONLINE));
            oParameters.Add(new ObjectParameter("prod_ProductFamilyID", 10));
            oParameters.Add(new ObjectParameter("prod_IndustryTypeCode", "%," + _oUser.prwu_IndustryType + ",%"));

            string szSQL = string.Format(SQL_SELECT_BUS_VALUATION,
                                         GetObjectMgr().GetLocalizedColName("prod_Name"));

            gvProducts.DataSource = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            gvProducts.DataBind();
        }

        protected void btnCancelOnClick(object sender, EventArgs e)
        {
            Response.Redirect(GetReturnURL(PageConstants.BUSINESS_VALUATION));
        }

        protected const string SQL_SELECT_ADDL_UNITS_PROD =
            "SELECT prod_ProductID, prod_PRServiceUnits, dbo.ufn_GetProductPrice(prod_ProductID, @PricingListID) as pric_Price, prod_ProductFamilyID FROM NewProduct WHERE prod_ProductID=@prod_ProductID";
        /// <summary>
        /// Creates the CreditCardPayment info for the selected
        /// additional units product and takes the user to the
        /// credit card payment page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnPurchaseOnClick(object sender, EventArgs e)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("PricingListID", PRICING_LIST_ONLINE));
            oParameters.Add(new ObjectParameter("prod_ProductID", GetRequestParameter("rbProductID")));

            IDataReader oReader = GetDBAccess().ExecuteReader(SQL_SELECT_ADDL_UNITS_PROD, oParameters, CommandBehavior.CloseConnection, null);
            try
            {
                oReader.Read();
                CreditCardPaymentInfo oPaymentInfo = new CreditCardPaymentInfo();
                oPaymentInfo.RequestType = "BV";
                oPaymentInfo.AdditionalUnits = 1;
                oPaymentInfo.TriggerPage = hidTriggerPage.Text;
                oPaymentInfo.Products.Add(new CreditCardProductInfo(oReader.GetInt32(0), oReader.GetInt32(3), PRICING_LIST_ONLINE, 1, oReader.GetDecimal(2)));
                oPaymentInfo.SelectedIDs = _oUser.prwu_HQID.ToString();
                Session["oCreditCardPayment"] = oPaymentInfo;
                Response.Redirect(GetFullSSLURL(PageConstants.CREDIT_CARD_PAYMENT));
            }
            finally
            {
                oReader.Close();
            }
        }

        protected override bool IsAuthorizedForPage()
        {
            return true;
        }

        protected override bool IsAuthorizedForData()
        {
            return true;
        }
    }
}
