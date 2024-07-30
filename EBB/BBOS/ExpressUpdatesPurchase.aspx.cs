/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2022-2022

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: ExpressUpdatesPurchase.aspx.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using PRCo.EBB.BusinessObjects;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using TSI.BusinessObjects;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    public partial class ExpressUpdatesPurchase : MembershipBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            SetPageTitle(Resources.Global.ExpressUpdateReports);

            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_FUNCTIONS2_FILE));
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_VALIDATION_FILE));
            btnPurchase.Attributes.Add("onclick", "return confirmSelect('" + Resources.Global.Product + "', 'rbProductID')");
            if (!IsPostBack)
            {
                hidTriggerPage.Text = Request.ServerVariables["SCRIPT_NAME"];
                PopulateForm();
            }
        }

        public class ExpressUpdateItem
        {
            public string ProductName { get; set; }
            public decimal Price { get; set; }
            public string Annually { get; set; }
            public string HasExpressUpdates { get; set; }
        }

        protected void PopulateForm()
        {
            const int EXPRESSUPDATES_PRODUCTID = 21; //EXUPD

            string productCode = null;
            string productName = null;
            string taxClass = null;
            decimal price;
            GetProductPriceData(EXPRESSUPDATES_PRODUCTID, _oUser.prwu_Culture, out price, out taxClass, out productCode, out productName);

            string szHasExpressUpdates="";
            if (HasExpressUpdates(_oUser.prwu_BBID))
                szHasExpressUpdates = "Y";

            gvExpressUpdates.DataSource = new List<ExpressUpdateItem>
            {
                new ExpressUpdateItem {ProductName=productName, Price = price, Annually=Resources.Global.Annually3, HasExpressUpdates=szHasExpressUpdates}
            };
            gvExpressUpdates.DataBind();
            EnableBootstrapFormatting(gvExpressUpdates);

            //Disable if they already have ExpressUpdates
            if (szHasExpressUpdates == "Y")
            {
                gvExpressUpdates.Enabled = false;
                btnPurchase.Enabled = false;
            }
        }

        protected void btnPurchaseOnClick(object sender, EventArgs e)
        {
            //After clicking a “Purchase” button at bottom, the user should go to Terms.aspx which they must accept.
            Session["ExpressUpdatesPurchase"] = "Y";
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
    }
}
