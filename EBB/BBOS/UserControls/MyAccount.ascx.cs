/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2007-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com
     
 ClassName: MyAccount.ascx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/

using PRCo.EBB.BusinessObjects;
using System;

namespace PRCo.BBOS.UI.Web.UserControls
{
    public partial class MyAccount : UserControlBase
    {
        protected BusinessValuation.BusinessValuationData _oBusinessValuationData;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if (WebUser.IsLimitado)
                pnlPrimary.Style.Add("width", "49%");

            hlCompanyProfileViews.NavigateUrl = "~/" + PageConstants.COMANY_PROFILE_VIEWS;

            if (WebUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                hlCompanyProfileViewsli.Visible = false;

            if (GetObjectMgr().IsCompanyListed(WebUser.prwu_BBID))
                hlMyCompanyProfile.NavigateUrl = PageConstants.FormatFromRoot(PageConstants.COMPANY, WebUser.prwu_BBID);
            else
                hlMyCompanyProfile.NavigateUrl = PageConstants.FormatFromRoot(PageConstants.EMCW_COMPANY_LISTING, "");

            if (!IsPostBack)
            {
                GetBusinessValuationInfo();
            }

            if (IsEligibleToDownloadBusinessValuation())
            {
                liRequestBusinessValuation.Visible = false;
                liDownloadBusinessValuation.Visible = true;
            }
        }
        protected bool IsEligibleToDownloadBusinessValuation()
        {
            //2.1.2.  If a company has a completed valuation for the current year,
            //and the BBOS user’s associated person record has Can View Business Valuations = true,
            //or this is the user that requested the valuation,
            //then display “Download Business Valuation”.  Otherwise display the default text/link.
            if (_oBusinessValuationData == null)
                return false;

            if
            (
                _oBusinessValuationData.StatusCode == BusinessValuation.BUSINESS_VALUATION_STATUS_CODE_SENT
                && 
                (
                    _oBusinessValuationData.CanViewBusinessValuations
                    ||
                    _oBusinessValuationData.CreatedBy == WebUser.prwu_WebUserID
                )
            )
            {
                return true;
            }

            return false;
        }

        protected void GetBusinessValuationInfo()
        {
            _oBusinessValuationData = PageControlBaseCommon.GetBusinessValuationData(WebUser);
        }
    }

}