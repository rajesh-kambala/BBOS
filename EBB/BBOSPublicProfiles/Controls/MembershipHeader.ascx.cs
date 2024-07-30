/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2014-2020

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
using PRCo.EBB.BusinessObjects;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web.PublicProfiles.Controls
{
    public partial class MembershipHeader : System.Web.UI.UserControl
    {
        public int CurrentStep;
        public bool HideMembershipSummary = false;

        private int expressUpdateProductID = Utilities.GetIntConfigValue("ExpressUpdateProductID", 21);
        private int bluebookProductID = Utilities.GetIntConfigValue("BlueBookProductID", 17);
        private int blueprintsProductID = Utilities.GetIntConfigValue("BlueprintsProductID", 18);
        private int lssProductID = Utilities.GetIntConfigValue("LSSProductID", 83);
        private int lssAdditionalProductID = Utilities.GetIntConfigValue("LSSAdditionalProductID", 84);

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Utilities.GetConfigValue("IndustryType") == "P")
            {
                tblLumber.Visible = false;

                switch (CurrentStep)
                {
                    case 1:
                        tdStep2.Attributes.Add("class", "step stepBG");
                        tdStep3.Attributes.Add("class", "step stepBG");
                        tdStep4.Attributes.Add("class", "step stepBG");
                        tdStep5.Attributes.Add("class", "step stepBG");
                        break;
                    case 2:
                        tdStep1.Attributes.Add("class", "step stepBG");
                        tdStep3.Attributes.Add("class", "step stepBG");
                        tdStep4.Attributes.Add("class", "step stepBG");
                        tdStep5.Attributes.Add("class", "step stepBG");
                        break;
                    case 3:
                        tdStep1.Attributes.Add("class", "step stepBG");
                        tdStep2.Attributes.Add("class", "step stepBG");
                        tdStep4.Attributes.Add("class", "step stepBG");
                        tdStep5.Attributes.Add("class", "step stepBG");
                        break;
                    case 4:
                        tdStep1.Attributes.Add("class", "step stepBG");
                        tdStep2.Attributes.Add("class", "step stepBG");
                        tdStep3.Attributes.Add("class", "step stepBG");
                        tdStep5.Attributes.Add("class", "step stepBG");
                        break;
                    case 5:
                        tdStep1.Attributes.Add("class", "step stepBG");
                        tdStep2.Attributes.Add("class", "step stepBG");
                        tdStep3.Attributes.Add("class", "step stepBG");
                        tdStep4.Attributes.Add("class", "step stepBG");
                        break;
                }
            }
            else
            {
                tblProduce.Visible = false;

                switch (CurrentStep)
                {
                    case 1:
                        tdLumberStep2.Attributes.Add("class", "step stepBG");
                        tdLumberStep3.Attributes.Add("class", "step stepBG");
                        break;
                    case 3:
                        tdLumberStep1.Attributes.Add("class", "step stepBG");
                        tdLumberStep3.Attributes.Add("class", "step stepBG");
                        break;
                    case 4:
                        tdLumberStep1.Attributes.Add("class", "step stepBG");
                        tdLumberStep2.Attributes.Add("class", "step stepBG");
                        break;
                }

            }

            if (!HideMembershipSummary)
            {
                CreditCardPaymentInfo oCCPayment = (CreditCardPaymentInfo)Session["oCreditCardPayment"];
                if (oCCPayment != null)
                {
                    CreditCardProductInfo membership = GetCreditCardProductInfo(oCCPayment, Convert.ToInt32(Session["MembershipProductID"]));
                    if (membership != null)
                    {
                        pnlMembership.Visible = true;

                        lblMembershipLevel.Text = (string)Session["MembershipName"];
                        lblMembershipFee.Text = membership.FormattedPrice;

                        string membershipUsers = membership.Users.ToString();
                        if (membership.Users == 9999)
                            membershipUsers = "Unlimited";

                        lblNumberofUsers.Text = membershipUsers; 

                        lblBusinessReports.Text = membership.BusinessReports.ToString();
                    }

                    CreditCardProductInfo expressUpdateProductInfo = GetCreditCardProductInfo(oCCPayment, expressUpdateProductID);
                    if (expressUpdateProductInfo != null)
                    {
                        trExpressUpdate.Visible = true;
                        lblExpressUpdate.Text = "Yes";
                    }

                    CreditCardProductInfo blueBookProductInfo = GetCreditCardProductInfo(oCCPayment, bluebookProductID);
                    if (blueBookProductInfo != null)
                    {
                        trBlueBook.Visible = true;
                        lblBlueBook.Text = blueBookProductInfo.Quantity.ToString();
                    }

                    CreditCardProductInfo bluePrintsProductInfo = GetCreditCardProductInfo(oCCPayment, blueprintsProductID);
                    if (bluePrintsProductInfo != null)
                    {
                        trBlueprints.Visible = true;
                        lblBlueprints.Text = bluePrintsProductInfo.Quantity.ToString();
                    }

                    CreditCardProductInfo lssProductInfo = GetCreditCardProductInfo(oCCPayment, lssProductID);
                    if (lssProductInfo != null)
                    {
                        trLSS.Visible = true;
                        int lssCount = 1;

                        CreditCardProductInfo lssAdditionalProductInfo = GetCreditCardProductInfo(oCCPayment, lssAdditionalProductID);
                        if (lssAdditionalProductInfo != null)
                        {
                            lssCount += lssAdditionalProductInfo.Quantity;
                        }

                        lbLSS.Text = lssCount.ToString();
                    }
                }
            }            
        }

        protected CreditCardProductInfo GetCreditCardProductInfo(CreditCardPaymentInfo oCCPayment, int productID)
        {
            foreach (CreditCardProductInfo oCCProductInfo in oCCPayment.Products)
            {
                if (oCCProductInfo.ProductID == productID)
                {
                    return oCCProductInfo;
                }
            }

            return null;
        }
    }
}