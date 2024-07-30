/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2011-2018

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Service, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Service, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CompanyAuthorization
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Data;
using TSI.BusinessObjects;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    public partial class CompanyAuthorization : PageBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            SetPageTitle("Company Authentication");

            if (!IsPostBack)
            {
                PopulateForm();
            }
        }

        protected int _iCompanyID = 0;
        protected const string SQL_SELECT_COMPANY =
            @"SELECT comp_CompanyID, comp_PRCorrTradestyle, comp_PRTMFMAward, comp_PRTMFMAwardDate, comp_PRIndustryType, prcse_FullName, prwk_HostName
                FROM Company WITH (NOLOCK)
                     INNER JOIN PRCompanySearch WITH (NOLOCK) ON comp_CompanyID = prcse_CompanyID
                     INNER JOIN PRWidgetKey WITH (NOLOCK) ON comp_CompanyID = prwk_CompanyID AND prwk_WidgetTypeCode = 'CompanyAuth'
               WHERE prwk_LicenseKey = @Key";

        protected void PopulateForm()
        {
            if (_iCompanyID > 0)
            {
                return;
            }

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("Key", GetRequestParameter("Key")));

            IDataReader oReader = GetDBAccess().ExecuteReader(SQL_SELECT_COMPANY, oParameters, CommandBehavior.CloseConnection, null);
            try
            {
                oReader.Read();

                _iCompanyID = GetDBAccess().GetInt32(oReader, "comp_CompanyID");
                lblCompanyName.Text = GetDBAccess().GetString(oReader, "comp_PRCorrTradestyle");

                hlFullCompanyName.Text = GetDBAccess().GetString(oReader, "prcse_FullName");
                lblCompanyName.Text = GetDBAccess().GetString(oReader, "comp_PRCorrTradestyle");
                lblSource.Text = GetDBAccess().GetString(oReader, "prwk_HostName");

                lblMemberYear.Text = GetDBAccess().GetDateTime(oReader, "comp_PRTMFMAwardDate").Year.ToString();

                switch (GetDBAccess().GetString(oReader, "comp_PRIndustryType"))
                {
                    case "P":
                        lblMemberType.Text = "Trading";
                        break;
                    case "T":
                        lblMemberType.Text = "Transporation";
                        break;
                    case "S":
                        lblMemberType.Text = string.Empty;
                        break;
                }
            }
            finally
            {
                oReader.Close();
            }

            hlFullCompanyName.NavigateUrl = PageConstants.Format(PageConstants.COMPANY_DETAILS_SUMMARY, _iCompanyID);
            lblDateTime.Text = DateTime.Now.ToString("MM/dd/yyyy");
            hlLearnMore.NavigateUrl = Utilities.GetConfigValue("CompanyAuthLearnMoreURL", "LearningCenter/BBS/BB Trading and Trans M Standards.pdf");
            hlSealMisuse.NavigateUrl = PageConstants.FEEDBACK + "?FeedbackType=SM";
        }


        protected override string GetWebAuditTrailAssociatedID()
        {
            PopulateForm();
            return _iCompanyID.ToString();
        }

        protected override string GetWebAuditTrailAssociatedType()
        {
            return "C";
        }

        /// <summary>
        /// Check users page level authorization
        /// </summary>
        /// <returns></returns>
        override protected bool IsAuthorizedForPage()
        {
            return true;
        }

        /// <summary>
        /// Check users control/data level authorization
        /// </summary>
        /// <returns></returns>
        protected override bool IsAuthorizedForData()
        {
            return true;
        }
    }
}
