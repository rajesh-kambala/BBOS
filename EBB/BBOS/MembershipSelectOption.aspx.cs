/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2021
 * 
 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: MembershipSelect.aspx.cs
 Description:	

 Notes:	lblAdditionalBlueBookPrice

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web {

    /// <summary>
    /// Allows the user to select any "add-ons" for the membership
    /// <remarks>
    /// Though the options on this page map to NewProduct records, everything
    /// is hard-coded do to the diverse options and that the order processing
    /// mechanism is slated to change in the next couple of years. 
    /// </remarks>
    /// </summary>
    public partial class MembershipSelectOption : MembershipBase {
        override protected void Page_Load(object sender, EventArgs e) {
            base.Page_Load(sender, e);

            SetPageTitle(Resources.Global.SelectMembershipOptions, Resources.Global.AdditionalOptions);
            EnableFormValidation();
            
            if (!IsPostBack) {
                PopulateForm();
            }

            Page.ClientScript.RegisterStartupScript(this.GetType(), "cbCompanyUpdates", "var cbCompanyUpdates=document.getElementById('" + cbCompanyUpdates.ClientID + "');", true);
        }

        /// <summary>
        /// Populates the form with the currently specified add-on
        /// information.
        /// </summary>
        protected void PopulateForm() {

            AJAXHelper ajaxHelper = new AJAXHelper();
            litShippingRates.Text = ajaxHelper.GetShippingRates();

            ucMembershipSelected.WebUser = _oUser;
            ucMembershipSelected.LoadMembership();
        
            if (GetRequestParameter(MEMBERSHIP_PRODUCT_ID) == Utilities.GetConfigValue("Series100ProductID", "3")) {
                lblSeries100msg.Visible = true;
            }

            PopulateStandardAddOn(Configuration.BlueprintsProductID,
                                  txtBlueprints,
                                  lblBlueprints,
                                  lblBlueprintsPrice,
                                  lblBlueprintsDesc,
                                  Resources.Global.each + " " + Resources.Global.Annually2,
                                  GetRequestParameter(ADDITIONAL_BLUEPRINTS, false),
                                  hidBlueprintsTaxClass);

            PopulateStandardAddOn(Configuration.BlueBookProductID,
                                  txtAdditionalBlueBook,
                                  lblAdditionalBlueBook,
                                  lblAdditionalBlueBookPrice,
                                  lblAdditionalBlueBookDesc,
                                  Resources.Global.ForAprilOctoberBook,
                                  GetRequestParameter(ADDITIONAL_BLUE_BOOKS, false),
                                  hidAdditionalBlueBookTaxClass);
                                  
            PopulateCompanyUpdate();

            PopulateLSS();      
        }

        /// <summary>
        /// Helper method that displays the "standard" control for the 
        /// specified product.
        /// </summary>
        /// <param name="szProductID"></param>
        /// <param name="txtQuantity"></param>
        /// <param name="lblName"></param>
        /// <param name="lblPrice"></param>
        /// <param name="lblDescription"></param>
        /// <param name="szPriceUnits"></param>
        /// <param name="szCurrentValue"></param>
        /// <param name="hidTaxClass"></param>
        protected void PopulateStandardAddOn(string szProductID, 
                                             TextBox txtQuantity, 
                                             Literal lblName, 
                                             Literal lblPrice, 
                                             Literal lblDescription,
                                             string szPriceUnits,
                                             string szCurrentValue,
                                             HiddenField hidTaxClass) {
                                             
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("PricingListID", PRICING_LIST_ONLINE));
            oParameters.Add(new ObjectParameter("prod_ProductID", szProductID));

            string szSQL = string.Format(SQL_SELECT_MEMBERSHIP_PRODUCT,
                                         GetObjectMgr().GetLocalizedColName("prod_Name"),
                                         GetObjectMgr().GetLocalizedColName("prod_PRDescription"));
            using (IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null))
            {
                if (oReader.Read())
                {
                    txtQuantity.Attributes.Add("tsiDisplayName", oReader.GetString(2).Trim());
                    lblName.Text = oReader.GetString(2).Trim();
                    lblPrice.Text = UIUtils.GetFormattedCurrency(oReader.GetDecimal(7)) + " " + szPriceUnits;
                    lblDescription.Text = oReader.GetString(3);
                    hidTaxClass.Value = UIUtils.GetString(oReader[6]);
                }
            }
            
            if (!string.IsNullOrEmpty(szCurrentValue)) {
                txtQuantity.Text = szCurrentValue;
            }
        }

        /// <summary>
        /// Handles the display of the Company Update add-on
        /// product.
        /// </summary>
        protected void PopulateCompanyUpdate()
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("PricingListID", PRICING_LIST_ONLINE));
            oParameters.Add(new ObjectParameter("prod_ProductID", Configuration.ExpressUpdateProductID));

            string szSQL = string.Format(SQL_SELECT_MEMBERSHIP_PRODUCT,
                                         GetObjectMgr().GetLocalizedColName("prod_Name"),
                                         GetObjectMgr().GetLocalizedColName("prod_PRDescription"));
            using (IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null))
            {
                if (oReader.Read())
                {
                    lblCompanyUpdates.Text = oReader.GetString(2).Trim();
                    lblCompanyUpdatesPrice.Text = UIUtils.GetFormattedCurrency(oReader.GetDecimal(7)) + " " + Resources.Global.Annually2;
                    lblCompanyUpdatesDesc.Text = oReader.GetString(3);
                    hidCompanyUpdatesTaxClass.Value = UIUtils.GetString(oReader[6]);
                }
            }
            
            if (GetRequestParameter(ADDITIONAL_COMPANY_UPDATES, false) != null) {
                cbCompanyUpdates.Checked = true;
            }
        }

        /// <summary>
        /// Handles the display of the Company Update add-on
        /// product.
        /// </summary>
        protected void PopulateLSS()
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("PricingListID", PRICING_LIST_ONLINE));
            oParameters.Add(new ObjectParameter("prod_ProductID", Configuration.LSSProductID));

            string szSQL = string.Format(SQL_SELECT_MEMBERSHIP_PRODUCT,
                                         GetObjectMgr().GetLocalizedColName("prod_Name"),
                                         GetObjectMgr().GetLocalizedColName("prod_PRDescription"));
            using (IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null))
            {
                if (oReader.Read())
                {
                    litLSSPrice.Text = UIUtils.GetFormattedCurrency(oReader.GetDecimal(7)) + " " + Resources.Global.Annually2;
                    hidLSSTaxClass.Value = UIUtils.GetString(oReader[6]);
                }
            }

            oParameters.Clear();
            oParameters.Add(new ObjectParameter("PricingListID", PRICING_LIST_ONLINE));
            oParameters.Add(new ObjectParameter("prod_ProductID", Configuration.LSSAdditionalProductID));

            szSQL = string.Format(SQL_SELECT_MEMBERSHIP_PRODUCT,
                                    GetObjectMgr().GetLocalizedColName("prod_Name"),
                                    GetObjectMgr().GetLocalizedColName("prod_PRDescription"));
            using (IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null))
            {
                if (oReader.Read())
                {
                    litLSSAddtionalPrice.Text = UIUtils.GetFormattedCurrency(oReader.GetDecimal(7)) + " " + Resources.Global.Annually2;
                    hidLSSAdditionalTaxClass.Value = UIUtils.GetString(oReader[6]);
                }
            }

            if (GetRequestParameter(ADDITIONAL_LSS, false) != null)
            {
                cbLSS.Checked = true;
                txtLSSAdditional.Text = GetRequestParameter(ADDITIONAL_LSS_LICENSE, false);
            }

            cbLSS.Attributes.Add("onclick", "toggleLSS(this);");
            Page.ClientScript.RegisterStartupScript(this.GetType(), "ToggleLSS", "toggleLSS(document.getElementById('" + cbLSS.ClientID + "'));", true);
        }

        /// <summary>
        /// Stores the selection for use on subsequent pages.
        /// </summary>
        protected void StoreSelections() {
            
            if (string.IsNullOrEmpty(txtAdditionalBlueBook.Text)) {
                RemoveRequestParameter(ADDITIONAL_BLUE_BOOKS);
                RemoveCreditCardProductInfo(Configuration.BlueBookProductID);
            } else {
                SetRequestParameter(ADDITIONAL_BLUE_BOOKS, txtAdditionalBlueBook.Text);
                AddCreditCardProductInfo(Configuration.BlueBookProductID, 
                                         Convert.ToInt32(txtAdditionalBlueBook.Text),
                                         GetProductPrice(Configuration.BlueBookProductID),
                                         hidAdditionalBlueBookTaxClass.Value);
            }

			/*
			 * Reference guide is not an annual service at this time (5/2008), but might be in the future.
            if (string.IsNullOrEmpty(txtAdditionalRefGuide.Text)) {
                RemoveRequestParameter(ADDITIONAL_REF_GUIDE);
                RemoveCreditCardProductInfo(Utilities.GetConfigValue("ReferenceGuideProductID", "25"));
            } else {
                SetRequestParameter(ADDITIONAL_REF_GUIDE, txtAdditionalRefGuide.Text);
                AddCreditCardProductInfo(Utilities.GetConfigValue("ReferenceGuideProductID", "25"),
                               Convert.ToInt32(txtAdditionalRefGuide.Text));
            }
			 */

            if (string.IsNullOrEmpty(txtBlueprints.Text)) {
                RemoveRequestParameter(ADDITIONAL_BLUEPRINTS);
                RemoveCreditCardProductInfo(Configuration.BlueprintsProductID);
            } else {
                SetRequestParameter(ADDITIONAL_BLUEPRINTS, txtBlueprints.Text);
                AddCreditCardProductInfo(Configuration.BlueprintsProductID,
                                         Convert.ToInt32(txtBlueprints.Text),
                                         GetProductPrice(Configuration.BlueprintsProductID),
                                         hidBlueprintsTaxClass.Value);
            }
            
            if (cbCompanyUpdates.Checked) {
                SetRequestParameter(ADDITIONAL_COMPANY_UPDATES, cbCompanyUpdates.Checked.ToString());

                CreditCardProductInfo oCCProductInfo = GetCreditCardProductInfo(Configuration.ExpressUpdateProductID);
                oCCProductInfo.PriceListID = PRICING_LIST_ONLINE;
                oCCProductInfo.Quantity = 1;
                oCCProductInfo.Price = GetProductPrice(Configuration.ExpressUpdateProductID);
                oCCProductInfo.TaxClass = hidCompanyUpdatesTaxClass.Value;

                oCCProductInfo.DeliveryCode = "E";
            } else {
                RemoveCreditCardProductInfo(Configuration.ExpressUpdateProductID);
                RemoveRequestParameter(ADDITIONAL_COMPANY_UPDATES);
            }

            if (!cbLSS.Checked)
            {
                RemoveRequestParameter(ADDITIONAL_LSS);
                RemoveCreditCardProductInfo(Configuration.LSSProductID);

                RemoveRequestParameter(ADDITIONAL_LSS_LICENSE);
                RemoveCreditCardProductInfo(Configuration.LSSAdditionalProductID);
            }
            else
            {
                SetRequestParameter(ADDITIONAL_LSS, cbLSS.Checked.ToString());
                AddCreditCardProductInfo(Configuration.LSSProductID,
                                         1,
                                         GetProductPrice(Configuration.LSSProductID),
                                         hidLSSTaxClass.Value);

                if (string.IsNullOrEmpty(txtLSSAdditional.Text))
                {
                    RemoveRequestParameter(ADDITIONAL_LSS_LICENSE);
                    RemoveCreditCardProductInfo(Configuration.LSSAdditionalProductID);

                }
                else
                {
                    SetRequestParameter(ADDITIONAL_LSS_LICENSE, txtLSSAdditional.Text);
                    AddCreditCardProductInfo(Configuration.LSSAdditionalProductID,
                                             Convert.ToInt32(txtLSSAdditional.Text),
                                             GetProductPrice(Configuration.LSSAdditionalProductID),
                                             hidLSSTaxClass.Value);
                }
            }
        }

        protected void btnNext_Click(object sender, EventArgs e) {

            if ((GetRequestParameter("CurrentProductID") == (string)Session["ProductID"]) &&
                (string.IsNullOrEmpty(txtAdditionalBlueBook.Text)) &&
                (string.IsNullOrEmpty(txtBlueprints.Text)) &&
                (!cbCompanyUpdates.Checked) &&
                (!cbLSS.Checked) &&
                string.IsNullOrEmpty(txtLSSAdditional.Text)) 
            {

                AddUserMessage("Please select either a membership upgrade or addtional products.");
                return;

            }

            StoreSelections();
            Response.Redirect(PageConstants.MEMBERSHIP_ADDTIONAL_LICENSES);
        }

        protected void btnPrevious_Click(object sender, EventArgs e) {
            StoreSelections();
            Response.Redirect(PageConstants.MEMBERSHIP_SELECT);
        }

        public override bool EnableJSClientIDTranslation() {
            return true;
        }
    }
}