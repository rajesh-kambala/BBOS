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

 ClassName: MembershipSelected.ascx.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Data;
using PRCo.EBB.BusinessObjects;
using TSI.Arch;
using TSI.BusinessObjects;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// User control that displays the information about the currently
    /// selected membership.
    /// </summary>
    public partial class MembershipSelected : UserControlBase
    {
        private int expressUpdateProductID = Convert.ToInt32(Configuration.ExpressUpdateProductID);
        private int bluebookProductID = Convert.ToInt32(Configuration.BlueBookProductID);
        private int blueprintsProductID = Convert.ToInt32(Configuration.BlueprintsProductID);
        private int lssProductID = Convert.ToInt32(Configuration.LSSProductID);
        private int lssAdditionalProductID = Convert.ToInt32(Configuration.LSSAdditionalProductID);
        private int itaProductID = Convert.ToInt32(Configuration.ITAProductID);

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if (WebUser.IsLimitado)
                pnlUpgradeMsgs.Visible = false;
        }

        protected const string SQL_SELECT_MEMBERSHIP =
            @"SELECT prod_ProductID, RTRIM(prod_Code) AS prod_Code, RTRIM({0}) as prod_Name, {1} as prod_PRDescription, prod_PRWebUsers, StandardUnitPrice, prod_PRServiceUnits
                FROM NewProduct WITH (NOLOCK)
                     LEFT OUTER JOIN MAS_PRC.dbo.CI_Item WITH (NOLOCK) ON prod_code = ItemCode 
               WHERE prod_ProductID=@prod_ProductID";
        /// <summary>
        /// Loads the control based on the specified produtc ID and
        /// additional user count.
        /// </summary>
        public void LoadMembership()
        {
            if (Session["ProductID"] == null)
            {
                throw new ApplicationUnexpectedException("ProductID Not Found In Session.");
            }

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prod_ProductID", (string)Session["ProductID"]));

            string szSQL = string.Format(SQL_SELECT_MEMBERSHIP,
                                         GetObjectMgr().GetLocalizedColName("prod_Name"),
                                         GetObjectMgr().GetLocalizedColName("prod_PRDescription"));
            IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            try
            {
                if (oReader.Read())
                {
                    //litCurrentProduct.Text = string.Format(Resources.Global.MembershipSelectCurrent, oReader.GetString(2), oReader.GetString(3));
                    lblMembershipLevel.Text = oReader.GetString(2);
                    lblMembershipFee.Text = UIUtils.GetFormattedCurrency(oReader.GetDecimal(5));
                    lbBusinessReports.Text = (oReader.GetInt32(6)).ToString();

                    lblNumberofUsers.Text = "0";

                    string membershipUsers = UIUtils.GetStringFromInt(oReader.GetInt32(4));
                    if (oReader.GetInt32(4) == 9999)
                        membershipUsers = "Unlimited";

                    lblNumberofUsers.Text = membershipUsers;

                }
            }
            finally
            {
                oReader.Close();
            }

            IPRWebUser oUser = (IPRWebUser)Session["oUser"];

            CreditCardPaymentInfo oCCPayment = (CreditCardPaymentInfo)Session["oCreditCardPayment"];
            if (oCCPayment != null)
            {
                //    CreditCardProductInfo membership = GetCreditCardProductInfo(oCCPayment, Convert.ToInt32(Session["ProductID"]));
                //    if (membership != null)
                //    {

                //        lblMembershipLevel.Text = (string)Session["MembershipName"];
                //        lblMembershipFee.Text = membership.FormattedPrice;
                //        lblNumberofUsers.Text = membership.Users.ToString(); ;
                //        lbBusinessReports.Text = membership.BusinessReports.ToString();
                //    }



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
                    lbBlueprints.Text = bluePrintsProductInfo.Quantity.ToString();
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

                CreditCardProductInfo itaProductInfo = GetCreditCardProductInfo(oCCPayment, itaProductID);
                if (itaProductInfo != null)
                {
                    lblMembershipFee.Text = UIUtils.GetFormattedCurrency(itaProductInfo.Price);
                }
            }
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
                return "0";
            }

            if (!slAdditionalLicenses.ContainsKey(iProductID))
            {
                return "0";
            }

            return Convert.ToString(slAdditionalLicenses[iProductID]);
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