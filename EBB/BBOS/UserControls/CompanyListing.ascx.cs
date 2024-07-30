/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CompanyListing
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using PRCo.EBB.BusinessObjects;
using System.Collections;
using TSI.BusinessObjects;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// User control that displays the company header, or "banner" information
    /// on each of the company detail pages.
    /// 
    /// NOTE: This user control is also being used to display the company header information
    /// on each of the edit my company wizard pages.
    /// </summary>
    public partial class CompanyListing : UserControlBase
    {
        //protected string _szLocation = null;
        protected string _szCompanyID;
        protected string _szCustomBSClass = null;

        public enum ListingFormatType
        {
            LISTING_FORMAT_ORIG = 1,
            LISTING_FORMAT_BBOS9 = 2
        }
        protected ListingFormatType _eFormat = ListingFormatType.LISTING_FORMAT_ORIG; //default to original style

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if(!Page.IsPostBack)
            {
                if (!string.IsNullOrEmpty(customBSClass))
                {
                    pCompanyListing.Attributes.Add("class", customBSClass);
                    pCompanyListing2.Attributes.Add("class", customBSClass);
                }

                SetVisibility();
            }
            
            string szPostback = Page.ClientScript.GetPostBackEventReference(imgPrint, "onclick");
            string szPostback2 = Page.ClientScript.GetPostBackEventReference(imgPrintBasic, "onclick");
            string szPostback3 = Page.ClientScript.GetPostBackEventReference(imgPrint2, "onclick");
            string szPostback4 = Page.ClientScript.GetPostBackEventReference(imgPrintBasic2, "onclick");

            if (WebUser.IsLimitado)
            {
                imgPrint.Visible = false;
                imgPrint2.Visible = false;
                imgPrintBasic.Visible = true;
                imgPrintBasic2.Visible = true;
            }

            if(Resources.Global.CompanyListingTitle.Length > 30)
            {
                imgPrint.CssClass = "mar_top_5";
                imgPrintBasic.CssClass = "mar_top_5";
            }

            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "imgPrintOnClick", "function imgPrintOnClick() {" + szPostback + "}", true);
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "imgPrintOnClick", "function imgPrintOnClick() {" + szPostback3 + "}", true);
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "imgPrintBasicOnClick", "function imgPrintBasicOnClick() {" + szPostback2 + "}", true);
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "imgPrintBasicOnClick", "function imgPrintBasicOnClick() {" + szPostback4 + "}", true);
        }

        public ListingFormatType Format
        {
            set { 
                _eFormat = value;
                SetVisibility();
            }
            get { return _eFormat; }
        }

        private void SetVisibility()
        {
            switch(Format)
            {
                case ListingFormatType.LISTING_FORMAT_BBOS9:
                    pCompanyListing.Visible = false;
                    pCompanyListing2.Visible = true;
                    break;

                default:
                    pCompanyListing.Visible = true;
                    pCompanyListing2.Visible = false;
                    break;
            }
        }

        public string companyID
        {
            set
            {
                _szCompanyID = value;
                LoadCompanyListing(WebUser);
            }
            get { return _szCompanyID; }
        }

        public string customBSClass
        {
            set { _szCustomBSClass = value; }
            get { return _szCustomBSClass; }
        }

        /// <summary>
        /// Make this string publically available for 
        /// use on the parent pages.
        /// </summary>
        public string Location
        {
            get
            {
                CompanyData ocd = GetCompanyData(_szCompanyID, WebUser, GetDBAccess(), GetObjectMgr());
                return ocd.szLocation;
            }
        }

        public string IncludeBranches
        {
            get { return hidIncludeBranches.Value; }
        }

        public string IncludeAffiliations
        {
            get { return hidIncludeAffiliations.Value; }
        }

        protected const string SQL_GET_LISTING = "SELECT dbo.ufn_GetListingCache({0}, {1})";

        /// <summary>
        /// Populates the header.
        /// </summary>
        public void LoadCompanyListing(IPRWebUser oWebUser)
        {
            CompanyData ocd = GetCompanyData(companyID, oWebUser, GetDBAccess(), GetObjectMgr());

            string szSQL = null;
            ArrayList oParameters = new ArrayList();

            SecurityMgr.SecurityResult privViewListing = oWebUser.HasPrivilege(SecurityMgr.Privilege.ViewCompanyListing);
            if (privViewListing.HasPrivilege)
            {
                oParameters.Clear();
                oParameters.Add(new ObjectParameter("CompanyID", companyID));
                oParameters.Add(new ObjectParameter("FormattingStyle", 0));
                szSQL = GetObjectMgr().FormatSQL(SQL_GET_LISTING, oParameters);

                object oListing = GetDBAccess().ExecuteScalar(szSQL, oParameters);
                string szListing = string.Empty;
                if (oListing != DBNull.Value)
                {
                    szListing = Convert.ToString(oListing);

                    if(WebUser.IsLumber_BASIC() || WebUser.IsLumber_BASIC_PLUS())
                    {
                        const string LUMBER_BASIC_SEPARATOR = "<br/>-----------";
                        if (szListing.IndexOf(LUMBER_BASIC_SEPARATOR) > -1)
                        {
                            //Remove stuff after ---- separator since L100/Basic doesn't have access
                            szListing = szListing.Substring(0, szListing.IndexOf(LUMBER_BASIC_SEPARATOR));
                        }
                    }
                }

                litListing.Text = Location + "<br/>" + szListing;
                litListing2.Text = Location + "<br/>" + szListing;
            }
            else
            {
                litListing.Text = GetBasicListing(companyID);
                litListing2.Text = GetBasicListing(companyID);
            }

            if (!string.IsNullOrEmpty(ocd.szPRPublishLogo))
            {
                hlLogo.Visible = true;
                hlLogo.ImageUrl = string.Format(Configuration.CompanyLogoURL, ocd.szPRLogo);
                if (!string.IsNullOrEmpty(ocd.szWebAddress))
                {
                    string szURL = PageConstants.FormatFromRoot(PageConstants.EXTERNAL_LINK_TRIGGER, ocd.szWebAddress, ocd.szCompanyID, "C", Request.ServerVariables.Get("SCRIPT_NAME"));
                    hlLogo.NavigateUrl = szURL;
                }
            }

            if (hlLogo.Visible == false)
            {
                pnlImage.Visible = false;
            }
        }

        protected void imgPrint_Click(object sender, System.Web.UI.ImageClickEventArgs e)
        {
            Response.Redirect(PageConstants.Format(PageConstants.GET_REPORT, GetReport.COMPANY_LISTING_REPORT) + "&CompanyID=" + companyID + "&IncludeBranches=" + hidIncludeBranches.Value + "&IncludeAffiliations=" + hidIncludeAffiliations.Value);
        }

        protected void imgPrintBasic_Click(object sender, System.Web.UI.ImageClickEventArgs e)
        {
            Response.Redirect(PageConstants.Format(PageConstants.GET_REPORT, GetReport.COMPANY_LISTING_REPORT_BASIC) + "&CompanyID=" + companyID);
        }
    }
}