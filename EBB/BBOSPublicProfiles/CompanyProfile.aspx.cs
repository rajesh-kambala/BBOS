/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2011-2023

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CompanyProfile
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Data;
using System.Text;
using System.Web;
using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web.PublicProfiles
{
    public partial class CompanyProfile : PageBase
    {
        protected override void Page_PreInit(object sender, EventArgs e)
        {
            if (GetRequestParameter("p", false) != null)
                this.MasterPageFile = "~/WordPress.Master";
        }

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            Session.Remove("oCreditCardPayment");
            Session["oCreditCardPayment"] = null;

            if ((GetRequestParameter("flushcookies", false) != null) &&
                (GetRequestParameter("flushcookies", false).ToLower() == "y"))
            {
                DeleteVisitorCookies();
                DeleteCookie("BBSi.BBOSLogin");
                DeleteCookie("CompanyID");

                var nameValueCollection = HttpUtility.ParseQueryString(HttpContext.Current.Request.QueryString.ToString());
                nameValueCollection.Remove("flushcookies");
                string url = HttpContext.Current.Request.Path + "?" + nameValueCollection;
                Response.Redirect(url);
            }

            if ((Utilities.GetBoolConfigValue("BBOSLoginRedirectEnabled", true)) &&
                (GetRequestParameter("OverrideRedirect", false) != "Y"))
            {
                if (Request.Cookies != null)
                {
                    if ((Request.Cookies["BBSi.BBOSLogin"] != null) &&
                        (Request.Cookies["BBSi.BBOSLogin"].Value.Length > 0))
                    {
                        InsertWidgetAuditTrail("BBOS");
                        Response.Redirect(string.Format(Utilities.GetConfigValue("BBOSCompanyDetailsURL"), GetRequestParameter("CompanyID")));
                        return;
                    }
                }
            }

            PopulateForm();
        }

        protected const string SQL_SELECT_COMPANY =
            @"SELECT *
                FROM vPRBBOSCompany
               WHERE comp_CompanyID=@CompanyID
                 AND comp_PRIndustryType IN ({0})";

        protected void PopulateForm()
        {
            if (string.IsNullOrEmpty(GetRequestParameter("CompanyID", false)))
            {
                ClientScript.RegisterStartupScript(this.GetType(), "directory", "openDirectory();", true);
                return;
            }

            int companyID = 0;
            if (!int.TryParse(GetRequestParameter("CompanyID"), out companyID))
            {
                ClientScript.RegisterStartupScript(this.GetType(), "directory", "openDirectory();", true);
                return;
            }
                        

            if (Request.RawUrl.Contains("CompanyProfile.aspx"))
            {
                ClientScript.RegisterStartupScript(this.GetType(), "directory", "openDirectory();", true);
                return;
            }

            //if (Request.RawUrl.Contains("CompanyProfile.aspx"))
            //{
            //    ClientScript.RegisterStartupScript(this.GetType(), "directory", "openDirectory();", true);
            //    return;
            //}

            int visitCount = IncrementVisitCount();
            LogMessage($"visitCount={visitCount}");

            if (visitCount >= Utilities.GetIntConfigValue("VistorInfoRequiredThreshold", 3))
            {
                if (Request.Cookies["Visitor"] == null)
                {
                    string wpParm = string.Empty;
                    if (GetRequestParameter("p", false) != null)
                        wpParm = "&p=1";

                    Response.Redirect($"Visitor.aspx?CompanyID={companyID}{wpParm}");
                    return;
                }

                LogVisitor(companyID);
            }

            if (GetIndustryType() == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                HeadingLumber.Visible = true;
                PromoLumber.Visible = true;
                pnlButtonsLumber.Visible = true;
                pnlButtonsProduce.Visible = false;
                ListingMsgLumber.Visible = true;
                litRated.Visible = false;
                imgLumber.Visible = true;
            }
            else
            {
                HeadingProduce.Visible = true;
                PromoProduce.Visible = true;
                pnlButtonsLumber.Visible = false;
                ListingMsgProduce.Visible = true;
                imgProduce.Visible = true;
            }

            Session["CompanyID"] = companyID;
            LogMessage($"CHW Session[\"CompanyID\"]={Session["CompanyID"]}");
            LogMessage($"CHW Session.SessionID={this.Session.SessionID}");
            hlGetBR.NavigateUrl = $"/Payment/?c={companyID}";


            InsertWidgetAuditTrail("PublicProfile");

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", companyID));

            string szSQL = string.Format(SQL_SELECT_COMPANY, Utilities.GetConfigValue("IndustryTypes"));

            using (IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null))
            {
                if (!oReader.Read())
                {
                    pnlNotFound.Visible = true;
                    tblListing.Visible = false;
                    pnlButtonsProduce.Visible = false;
                    return;
                }

                litCompanyName.Text = GetDBAccess().GetString(oReader, "comp_PRCorrTradestyle");
                litLocation.Text = GetDBAccess().GetString(oReader, "CityStateCountryShort");
                litIndustry.Text = GetDBAccess().GetString(oReader, "IndustryType");
                litType.Text = GetDBAccess().GetString(oReader, "PRType");
                litBBID.Text = companyID.ToString();


                if (!string.IsNullOrEmpty(GetDBAccess().GetString(oReader, "comp_PRLegalName"))) {
                    litLegalName.Visible = true;
                    litLegalName.Text = string.Format(litLegalName.Text, GetDBAccess().GetString(oReader, "comp_PRLegalName"));
                }
                
                SetHTMLTitle(litCompanyName.Text + " BBOS Public Profile");

                // If our company is not listed, hide most of the page and display
                // the "Not Listed" message.
                string listingStatus = GetDBAccess().GetString(oReader, "comp_PRListingStatus");
                if ((listingStatus != "L") &&
                    (listingStatus != "H") &&
                    (listingStatus != "LUV")) {

                    lblNotListed.Visible = true;
                    pnlButtonsProduce.Visible = false;
                    trListingInfo.Visible = false;

                    return;
                }

                // Display the Logo
                if (GetObjectMgr().TranslateFromCRMBool(oReader[5]))
                {
                    pnlLogo.Visible = true;
                    hlLogo.ImageUrl = string.Format(Utilities.GetConfigValue("CompanyLogoURL", "https://apps.bluebookservices.com/BBSUtils/GetLogo.aspx?LogoFile={0}"), GetDBAccess().GetString(oReader, "comp_PRLogo"));


                    string szURL = string.Format(Utilities.GetConfigValue("BBOSExternalLinkURL"),
                                                 GetDBAccess().GetString(oReader, "emai_PRWebAddress"),
                                                 companyID, 
                                                 "C", 
                                                 Request.ServerVariables.Get("SCRIPT_NAME"));

                    hlLogo.Attributes.Add("onclick", string.Format("openWindow('{0}')", szURL));
                    hlLogo.NavigateUrl = "#";
                }

                litPrimaryPhone.Text = GetDBAccess().GetString(oReader, "Phone");
                litPrimaryFax.Text = GetDBAccess().GetString(oReader, "Fax");
                litTollFree.Text = GetDBAccess().GetString(oReader, "TolLFree");
                
                if (string.IsNullOrEmpty(GetDBAccess().GetString(oReader, "prra_RatingLine"))) {
                    litRated.Visible = false;               
                }

                switch (GetDBAccess().GetString(oReader, "comp_PRIndustryType")) {
                    case "L":
                        hlBRSampleLumber.Attributes.Add("onclick", "openWindow('" + Utilities.GetConfigValue("LumberBRSample", "https://apps.bluebookservices.com/bbos/downloads/samples/Lumber/BusinessReportSample.pdf") + "');");
                        //hlBRPricingChart.Attributes.Add("onclick", "openWindow('" + Utilities.GetConfigValue("LumberBRPricingChart", "https://apps.bluebookservices.com/bbos/downloads/samples/Lumber/BusinessReportPricingChart.pdf") + "');");
                        break;

                    case "P":
                    case "T":
                        hlBRSample.Attributes.Add("onclick", "openWindow('" + Utilities.GetConfigValue("ProduceBRSample", "https://apps.bluebookservices.com/bbos/downloads/samples/Produce/BusinessReportSample.pdf") + "');");
                        hlBRPricingChart.Attributes.Add("onclick", "openWindow('" + Utilities.GetConfigValue("ProduceBRPricingChart", "https://apps.bluebookservices.com/bbos/downloads/samples/Produce/BusinessReportPricingChart.pdf") + "');");
                        break;
                    case "S":
                        pnlButtonsProduce.Visible = false;
                        break;
                }
            }

            PopulateSocialMedia(companyID);

            if (GetIndustryType() != GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                DisplayClassificationAndCommodityCounts(companyID);
            }
        }

        protected const string SQL_SELECT_CLASS_COUNT =
            @"SELECT COUNT(1)
                FROM PRCompanyClassification WITH (NOLOCK)
               WHERE prc2_CompanyID=@CompanyID";

        protected const string SQL_SELECT_COMMOD_COUNT =
            @"SELECT COUNT(1)
                FROM PRCompanyCommodityAttribute WITH (NOLOCK)
               WHERE prcca_CompanyID=@CompanyID";

        /// <summary>
        /// Populates the Classifcation and Commodity section 
        /// </summary>
        /// <param name="companyID"></param>
        protected void DisplayClassificationAndCommodityCounts(int companyID)
        {
            StringBuilder sbCounts = new StringBuilder();

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", companyID));

            int classificationCount = (int)GetDBAccess().ExecuteScalar(SQL_SELECT_CLASS_COUNT, oParameters);
            int commodityCount = (int)GetDBAccess().ExecuteScalar(SQL_SELECT_COMMOD_COUNT, oParameters);

            if (commodityCount > 0)
            {
                sbCounts.Append(string.Format("{0} commodities handled. ", commodityCount));
            }

            if (classificationCount > 0)
            {
                sbCounts.Append(string.Format("{0} supply chain classifications. ", classificationCount));
            }

            litClassCommodCount.Text = sbCounts.ToString();
        }

        private const string SQL_INSERT_WIDGET_AUDIT_TRAIL =
            @"INSERT INTO PRWidgetAuditTrail (prwat_WidgetKeyID, prwat_SubjectCompanyID, prwat_LandingApplication, prwat_IPAddress, prwat_CreatedBy, prwat_CreatedDate, prwat_UpdatedBy, prwat_UpdatedDate, prwat_Timestamp)
                                      VALUES (@WidgetKey, @SubjectCompanyID, @LandingApplication, @IPAddress, @UserID, GETDATE(), @UserID, GETDATE(), GETDATE());";
        protected void InsertWidgetAuditTrail(string szLandingApplication)
        {
            // Look to see if a WidgetKey parameter is specified.  If so, then let's log
            // the fact the user got here from a widget.
            if (GetRequestParameter("WK", false) == null)
            {
                return;
            }

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("WidgetKey", Convert.ToInt32(GetRequestParameter("WK"))));
            oParameters.Add(new ObjectParameter("SubjectCompanyID", Convert.ToInt32(GetRequestParameter("CompanyID"))));
            oParameters.Add(new ObjectParameter("LandingApplication", szLandingApplication));
            oParameters.Add(new ObjectParameter("IPAddress", Request.ServerVariables["REMOTE_ADDR"]));
            oParameters.Add(new ObjectParameter("UserID", "-1"));

            GetDBAccess().ExecuteNonQuery(SQL_INSERT_WIDGET_AUDIT_TRAIL, oParameters);
        }

        protected const string SOCIAL_MEDIA_CELL =
                    "<a href=\"#\" onclick=\"openWindow('{0}')\"><img src=\"{1}.png\" alt=\"{2}\" border=\"0\" /></a>";
        protected const string SQL_SOCIAL_MEDIA =
            @"SELECT prsm_SocialMediaID, prsm_SocialMediaTypeCode, dbo.ufn_GetCustomCaptionValue('prsm_SocialMediaTypeCode', prsm_SocialMediaTypeCode, 'en-us') As SocialMediaType, prsm_URL 
                FROM PRSocialMedia WITH (NOLOCK) 
               WHERE prsm_CompanyID=@CompanyID 
                 AND prsm_Disabled IS NULL";

        protected void PopulateSocialMedia(int companyID)
        {
            if (!Utilities.GetBoolConfigValue("SocialMediaEnabled", true))
            {
                trSocialMedia.Visible = false;
                return;
            }

            StringBuilder sbSocialMedia = new StringBuilder();

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyID", companyID));

            string imageURL = Utilities.GetConfigValue("ImageRootURL", "https://www.producebluebook.com/ProducePublicProfiles/Images/");

            using (IDataReader oReader = GetDBAccess().ExecuteReader(SQL_SOCIAL_MEDIA, oParameters, CommandBehavior.CloseConnection, null)) { 
                while (oReader.Read())
               {
                    string szURL = string.Format(Utilities.GetConfigValue("BBOSExternalLinkURL"), Server.UrlEncode(oReader.GetString(3)), companyID, "C", Request.ServerVariables.Get("SCRIPT_NAME"));
                    sbSocialMedia.Append(string.Format(SOCIAL_MEDIA_CELL,
                                                       szURL,
                                                       imageURL + oReader.GetString(1),
                                                       oReader.GetString(2)));
                }
            }

            litSocialMedia.Text = sbSocialMedia.ToString();
        }
    }
}
