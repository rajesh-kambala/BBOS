/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2014-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: MembershipOptions.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Web.UI.WebControls;

using PRCo.EBB.BusinessObjects;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web.PublicProfiles
{
    public partial class MembershipOptions : MembershipBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            Master.SetFormClass("member step-2 select-options");

            btnCancel.NavigateUrl = GetMarketingSiteURL() + "/join-today/";

            if (Session["oCreditCardPayment"] == null)
            {
                Response.Redirect("MembershipSelect.aspx" + LangQueryString());
            }

            if (!IsPostBack)
            {
                PopulateForm();
            }
        }

        private int expressUpdateProductID = Utilities.GetIntConfigValue("ExpressUpdateProductID", 21);
        private int bluebookProductID = Utilities.GetIntConfigValue("BlueBookProductID", 17);
        private int blueprintsProductID = Utilities.GetIntConfigValue("BlueprintsProductID", 18);
        private int lssProductID = Utilities.GetIntConfigValue("LSSProductID", 83);
        private int lssAdditionalProductID = Utilities.GetIntConfigValue("LSSAdditionalProductID", 84);
        private int publishedLogoProductID = Utilities.GetIntConfigValue("PublishedLogoProductID", 24);

        protected void PopulateForm()
        {
            SetProductPrice(litExpressUpdatePrice, expressUpdateProductID);
            SetProductPrice(litBlueBookPrice, bluebookProductID);

            SetProductPrice(litLSSPrice, lssProductID);
            SetProductPrice(litLSSAddtionalPrice, lssAdditionalProductID);

            // Produce STANDARD and PREMIUM have differnet formatting for complimentary designation
            if ((string)Session["MembershipProductID"]=="201" || (string)Session["MembershipProductID"]=="202")
            {
                litCompanyLogoTitle.Text = Resources.Global.YourCompanyLogoComplimentary;
                litAnnually.Text = ":";
            }
            else
            {
                litCompanyLogoTitle.Text = Resources.Global.YourCompanyLogo + ", &nbsp;";
                SetProductPrice(litPublishedLogoPrice, publishedLogoProductID);
                litAnnually.Text = "&nbsp;" + Resources.Global.Annually_LC + ":";
            }

            rbExpressUpdateTypeFax.Attributes.Add("onclick", "toggleCompanyUpdates(document.getElementById('" + cbExpressUpdates.ClientID + "'));");
            rbExpressUpdateTypeEmail.Attributes.Add("onclick", "toggleCompanyUpdates(document.getElementById('" + cbExpressUpdates.ClientID + "'));");

            CreditCardProductInfo expressUpdateProductInfo = GetCreditCardProductInfo(expressUpdateProductID, true);
            if (expressUpdateProductInfo != null)
            { 
                cbExpressUpdates.Checked = true;

                if (GetRequestParameter(ADDITIONAL_COMPANY_UPDATES_FAX, false) != null)
                {
                    rbExpressUpdateTypeFax.Checked = true;
                    txtExpressUpdateFaxAreaCode.Text = GetRequestParameter(ADDITIONAL_COMPANY_UPDATES_FAX_AC, false);
                    txtExpressUpdateFaxNumber.Text = GetRequestParameter(ADDITIONAL_COMPANY_UPDATES_FAX_NUMBER, false);
                }
                else
                {
                    rbExpressUpdateTypeEmail.Checked = true;
                    txtExpressUpdateEmail.Text = GetRequestParameter(ADDITIONAL_COMPANY_UPDATES_EMAIL_ADDRESS, false);
                }
            }
            else
            {
                rbExpressUpdateTypeEmail.Checked = true;
            }

            CreditCardProductInfo bluebookProductInfo = GetCreditCardProductInfo(bluebookProductID, true);
            if (bluebookProductInfo != null)
            {
                txtBlueBook.Text = bluebookProductInfo.Quantity.ToString();
            }

            CreditCardProductInfo lssProductInfo = GetCreditCardProductInfo(lssProductID, true);
            if (lssProductInfo != null)
            {
                cbLSS.Checked = true;
            }

            CreditCardProductInfo lssAdditionalProductInfo = GetCreditCardProductInfo(lssAdditionalProductID, true);
            if (lssAdditionalProductInfo != null)
            {
                txtLSSAdditional.Text = lssAdditionalProductInfo.Quantity.ToString();
            }

            if (Utilities.GetConfigValue("IndustryType") == "P")
            {
                trCompanyUpdateEmail.Visible = false;
                trCompanyUpdateFax.Visible = false;
            }
        }

        protected void SetProductPrice(Literal priceControl, int productID)
        {
            decimal price = 0M;
            string taxClass = null;

            GetProductPriceData(productID, out price, out taxClass);
            priceControl.Text = GetFormattedCurrency(price);    
        }

        protected void SaveOptions()
        {
            if (!cbExpressUpdates.Checked)
            {
                RemoveCreditCardProductInfo(expressUpdateProductID);
            } else  {
                CreditCardProductInfo oCCProductInfo = AddCreditCardProductInfo(expressUpdateProductID, 1);

                if (rbExpressUpdateTypeFax.Checked)
                {
                    SetRequestParameter(ADDITIONAL_COMPANY_UPDATES_FAX, rbExpressUpdateTypeFax.Checked.ToString());
                    SetRequestParameter(ADDITIONAL_COMPANY_UPDATES_FAX_AC, txtExpressUpdateFaxAreaCode.Text);
                    SetRequestParameter(ADDITIONAL_COMPANY_UPDATES_FAX_NUMBER, txtExpressUpdateFaxNumber.Text);

                    oCCProductInfo.DeliveryCode = "F";
                    oCCProductInfo.DeliveryDestination = txtExpressUpdateFaxAreaCode.Text + " " + txtExpressUpdateFaxNumber.Text;
                } else {
                    SetRequestParameter(ADDITIONAL_COMPANY_UPDATES_EMAIL, rbExpressUpdateTypeEmail.Checked.ToString());
                    SetRequestParameter(ADDITIONAL_COMPANY_UPDATES_EMAIL_ADDRESS, txtExpressUpdateEmail.Text);

                    oCCProductInfo.DeliveryCode = "E";
                    oCCProductInfo.DeliveryDestination = txtExpressUpdateEmail.Text;
                }
            }

            if (string.IsNullOrEmpty(txtBlueBook.Text))
            {
                RemoveCreditCardProductInfo(bluebookProductID);
            } else {
                AddCreditCardProductInfo(bluebookProductID, Convert.ToInt32(txtBlueBook.Text));
            }

            if (!cbLSS.Checked)
            {
                RemoveCreditCardProductInfo(lssProductID);
                RemoveCreditCardProductInfo(lssAdditionalProductID);
            }
            else
            {
                CreditCardProductInfo oCCProductInfo = AddCreditCardProductInfo(lssProductID, 1);

                if (string.IsNullOrEmpty(txtLSSAdditional.Text))
                {
                    RemoveCreditCardProductInfo(lssAdditionalProductID);
                }
                else
                {
                    AddCreditCardProductInfo(lssAdditionalProductID, Convert.ToInt32(txtLSSAdditional.Text));
                }
            }

            if (!cbPublishedLogo.Checked)
            {
                RemoveCreditCardProductInfo(publishedLogoProductID);
            }
            else
            {
                AddCreditCardProductInfo(publishedLogoProductID, 1);

                if ((string)Session["MembershipProductID"] == "201" || (string)Session["MembershipProductID"] == "202")
                {
                    //STANDARD and PREMIUM get $0 logos
                    CreditCardPaymentInfo oCCPaymentInfo = GetCreditCardPaymentInfo();
                    foreach (CreditCardProductInfo product in oCCPaymentInfo.Products)
                    {
                        if (product.ProductCode == "LOGO")
                            product.Price = 0;
                    }
                }

                Session["PublishedLogoFile"] = fuPublishedLogo.FileBytes;
                Session["PublishedLogoFileName"] = fuPublishedLogo.FileName;
            }
        }

        protected void btnNextOnClick(object sender, EventArgs e)
        {
            SaveOptions();
            Response.Redirect("MembershipUsers.aspx" + LangQueryString());
        }

        protected void btnPreviousOnClick(object sender, EventArgs e)
        {
            SaveOptions();
            Response.Redirect("MembershipSelect.aspx" + LangQueryString());
        }

        protected void btnCancelOnClick(object sender, EventArgs e)
        {
            Session.Remove("oCreditCardPayment");
            Response.Redirect(GetMarketingSiteURL() + "/join-today/");

        }
    }
}