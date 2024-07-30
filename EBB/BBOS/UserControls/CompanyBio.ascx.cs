/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2024-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CompanyBio.ascx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/

using PRCo.EBB.BusinessObjects;
using System;
using System.Collections;
using System.Data;
using System.Diagnostics;
using System.Security.Cryptography;
using System.Web;
using System.Web.UI.WebControls;
using TSI.BusinessObjects;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web.UserControls
{
    public partial class CompanyBio : UserControlBase
    {
        protected string _szCompanyID;
        protected CompanyData _ocd;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
            PageBase oPage = (PageBase)this.Parent.Page;

            if (!IsPostBack)
            {
                GetOcd();
                PopulateForm();
            }
        }

        public string CompanyID
        {
            get { return _szCompanyID; }
            set { _szCompanyID = value; }
        }

        public CompanyData GetOcd()
        {
            if (_ocd == null)
                _ocd = PageControlBaseCommon.GetCompanyData(CompanyID, WebUser, GetDBAccess(), GetObjectMgr());
            return _ocd;
        }

        protected void PopulateForm()
        {
            switch (_ocd.szIndustryType)
            {
                case GeneralDataMgr.INDUSTRY_TYPE_PRODUCE:
                    litIndustry.Text = Resources.Global.Produce;
                    litIndustryIcon.InnerText = "temp_preferences_eco";
                    break;
                case GeneralDataMgr.INDUSTRY_TYPE_TRANSPORTATION:
                    litIndustry.Text = Resources.Global.Transportation;
                    litIndustryIcon.InnerText = "local_shipping";
                    break;
                case GeneralDataMgr.INDUSTRY_TYPE_SUPPLY:
                    litIndustry.Text = Resources.Global.Supply;
                    litIndustryIcon.InnerText = "conveyor_belt";
                    break;
                default:
                    litIndustry.Text = _ocd.szIndustryTypeName;
                    litIndustryIcon.InnerText = "temp_preferences_eco";
                    break;
            }

            PopulateClassifications();

            if (_ocd.szListingStatus == "LUV")
            {
                ListingpendingVerificationTag.Visible = true;
            }

            litCompanyName.Visible = true;
            litCompanyName.Text = _ocd.szCompanyName;
            string szEmbeddedMap = "";
            litLocation.Text = GetAddressForMap(CompanyID, out szEmbeddedMap);

            if (!string.IsNullOrEmpty(_ocd.szWebAddress))
            {
                hlWebsite.Text = _ocd.szWebAddress;
                string szURL = PageConstants.FormatFromRoot(PageConstants.EXTERNAL_LINK_TRIGGER, hlWebsite.Text, CompanyID, "C", Request.ServerVariables.Get("SCRIPT_NAME"));
                hlWebsite.NavigateUrl = szURL;
                hlWebsite.Enabled = true;
            }

            if (!string.IsNullOrEmpty(_ocd.szEmailAddress))
            {
                hlEmail.Text = _ocd.szEmailAddress;
                hlEmail.NavigateUrl = "mailto:" + hlEmail.Text;
                hlEmail.Enabled = true;
            }

            litPhone.Text = _ocd.szPhone;
            litBBID.Text = CompanyID;
            litBusinessStartDate.Text = _ocd.BusinessStartDate;

            if (_ocd.bPRTMFMAward)
            {
                imgTMFM.Visible = true;

                switch (_ocd.szIndustryType)
                {
                    case GeneralDataMgr.INDUSTRY_TYPE_PRODUCE:
                        imgTMFM.ImageUrl = UIUtils.GetImageURL("seal_trade.svg");
                        lblTMFMMsg.Text = string.Format(Resources.Global.TradingMemberMsg, _ocd.dtPRTMFMAwardDate.Year);
                        break;
                    case GeneralDataMgr.INDUSTRY_TYPE_TRANSPORTATION:
                        imgTMFM.ImageUrl = UIUtils.GetImageURL("seal_transport.svg");
                        lblTMFMMsg.Text = string.Format(Resources.Global.TransportationMemberMsg, _ocd.dtPRTMFMAwardDate.Year);
                        break;
                }
            }
            else
            {
                trTMFM.Visible = false;
            }

            bool unlistedCompany = false;

            // If not listed, then display an icon with text.
            if ((_ocd.szListingStatus == "N3") ||
                (_ocd.szListingStatus == "N4") ||
                (_ocd.szListingStatus == "N5") ||
                (_ocd.szListingStatus == "N6"))
            {
                trMessage.Visible = true;
                if (_ocd.szCompanyType.StartsWith("B"))
                    litMessage.Text = Resources.Global.BranchNoLongerListedMsg; //branch
                else
                    litMessage.Text = Resources.Global.CompanyNoLongerListedMsg; //hq

                if (_ocd.dtDelistedDate != DateTime.MinValue)
                    litMessage.Text += string.Format(" {0} {1}.", Resources.Global.AsOf, _ocd.dtDelistedDate.ToShortDateString());

                unlistedCompany = true;
            }
            else
            {
                // Only display the "Newly Listed" icon if the
                // listed date is within the configured threshold.
                if (_ocd.dtListedDate != DateTime.MinValue)
                {
                    TimeSpan oDiff = DateTime.Today - _ocd.dtListedDate;
                    if (oDiff.Days <= Configuration.NewListingDaysThreshold)
                    {
                        trMessage.Visible = true;
                        if (_ocd.szListingStatus == "LUV")
                        {
                            litMessage.Text = string.Format(Resources.Global.PendingListingMsg, oDiff.Days + 1);

                        } else
                        {
                            litMessage.Text = string.Format(Resources.Global.NewListingMsg, oDiff.Days + 1);

                        }
                    }
                }
            }

            //Indicator buttons
            PopulateIndicatorButtons();
        }

        protected const string SQL_CLASSIFICATIONS_LEVEL1_SELECT =
            @"SELECT DISTINCT b.{0} As Level1
                FROM PRCompanyClassification WITH (NOLOCK)
                INNER JOIN PRClassification a WITH (NOLOCK) ON prc2_ClassificationID = prcl_ClassificationID
                INNER JOIN PRClassification b WITH (NOLOCK) ON CASE WHEN CHARINDEX(',', a.prcl_Path) = 0 THEN a.prcl_Path ELSE LEFT(a.prcl_Path, CHARINDEX(',', a.prcl_Path)-1) END = b.prcl_ClassificationID";

        protected const string SQL_CLASSIFICATIONS_WHERE = " WHERE prc2_CompanyID = {0}";

        protected void PopulateClassifications()
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prc2_CompanyID", _ocd.szCompanyID));

            string szSQL = string.Format(SQL_CLASSIFICATIONS_LEVEL1_SELECT,
                GetObjectMgr().GetLocalizedColName("prcl_Name"));

            szSQL = GetObjectMgr().FormatSQL(szSQL + SQL_CLASSIFICATIONS_WHERE, oParameters);

            repClassificationsLevel1.DataSource = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            repClassificationsLevel1.DataBind();
        }

        protected const string SQL_CATEGORIES =
            @"SELECT prwucl_CategoryIcon, prwucl_Name, prwucl_Pinned
                 FROM PRWebUserList WITH (NOLOCK)
                      INNER JOIN PRWebUserListDetail WITH (NOLOCK) ON prwucl_WebUserListID = prwuld_WebUserListID
                WHERE ((prwucl_HQID = @HQID AND prwucl_IsPrivate IS NULL) OR (prwucl_WebUserID=@WebUserID AND prwucl_IsPrivate = 'Y')) 
                  AND prwuld_AssociatedID = @CompanyID
             ORDER BY prwucl_Name";

        protected int _categoryCount = 0;
        protected int _categoryIndex = 0;
        protected void PopulateCategories()
        {

            IList parmList = new ArrayList();
            parmList.Add(new ObjectParameter("HQID", WebUser.prwu_HQID));
            parmList.Add(new ObjectParameter("WebUserID", WebUser.prwu_WebUserID));
            parmList.Add(new ObjectParameter("CompanyID", Convert.ToInt32(CompanyID)));

            repCategories.DataSource = GetDBAccess().ExecuteReader(SQL_CATEGORIES, parmList, CommandBehavior.CloseConnection, null);
            repCategories.DataBind();

            _categoryCount = repCategories.Items.Count;
            watchdogCount.Text = _categoryCount.ToString();
        }

        protected void PopulateIndicatorButtons()
        {
            PopulateNotes();
            PopulateCategories();
            PopulateChanged();
            PopulateWatchdog();
            PopulateNew();
            PopulateCertified();
            PopulateNewClaim();
        }

        protected void PopulateNotes()
        {
            if (!WebUser.HasPrivilege(SecurityMgr.Privilege.Notes).HasPrivilege)
            {
                return;
            }

            NoteSearchCriteria searchCriteria = new NoteSearchCriteria();
            searchCriteria.WebUser = WebUser;
            searchCriteria.AssociatedID = Convert.ToInt32(CompanyID);
            searchCriteria.AssociatedType = "C";
            IBusinessObjectSet results = new PRWebUserNoteMgr(GetLogger(), WebUser).Search(searchCriteria);

            if (results.Count > 0)
            {
                btnNotes.Visible = true;
                litNoteCount.Text = results.Count.ToString();
            }
        }
        protected void PopulateChanged()
        {
            //Check delisted first
            if (_ocd.dtDelistedDate != DateTime.MinValue
                && (_ocd.szListingStatus == "N3" ||
                    _ocd.szListingStatus == "N4" ||
                    _ocd.szListingStatus == "N5" ||
                    _ocd.szListingStatus == "N6"))
            {
                TimeSpan oTS = DateTime.Now.Subtract(_ocd.dtDelistedDate);
                int iDays = oTS.Days + 1;
                if (iDays < Configuration.CompanyLastChangeThreshold)
                {
                    btnChanged.Visible = true;
                    btnChanged.Attributes["data-bs-title"] = string.Format(Resources.Global.DeListedInLastMsg, iDays);
                    return;
                }
            }

            if (_ocd.dtLastChanged > DateTime.MinValue)
            {
                TimeSpan oTS = DateTime.Now.Subtract(_ocd.dtLastChanged);
                int iDays = oTS.Days + 1;
                if (iDays < Configuration.CompanyLastChangeThreshold)
                {
                    btnChanged.Visible = true;
                    btnChanged.Attributes["data-bs-title"] = string.Format(Resources.Global.CompanyChangedMsg, iDays);
                }
            }
        }

        protected void PopulateNew()
        {
            // Only display the "New" button if the
            // listed date is within the configured threshold.
            // Also make sure it's not delisted
            if (_ocd.dtDelistedDate != DateTime.MinValue && 
                    (_ocd.szListingStatus == "N3" ||
                     _ocd.szListingStatus == "N4" ||
                     _ocd.szListingStatus == "N5" ||
                     _ocd.szListingStatus == "N6")
                )
            {
                btnNew.Visible = false;
            }
            else if (_ocd.dtListedDate != DateTime.MinValue)
            {
                TimeSpan oDiff = DateTime.Today - _ocd.dtListedDate;
                if (oDiff.Days <= Configuration.NewListingDaysThreshold)
                {
                    btnNew.Visible = true;
                    if (_ocd.szListingStatus == "LUV")
                    {
                        btnNew.Attributes["data-bs-title"] = string.Format(Resources.Global.PendingListingMsg, oDiff.Days + 1);
                    }
                    else
                    {
                        btnNew.Attributes["data-bs-title"] = string.Format(Resources.Global.ListedInLastMsg, oDiff.Days + 1);
                    }
                }
            }
        }

        protected void PopulateWatchdog()
        {
            if (_ocd.bOnWatchdogList)
            {
                btnWatchdog.Visible = true;
            }
        }

        protected void PopulateCertified()
        {
            if (_ocd.bIsCertifiedOrganic || _ocd.bIsFoodSafetyCertified)
            {
                btnCertified.Visible = true;

                if (_ocd.bIsCertifiedOrganic && _ocd.bIsFoodSafetyCertified)
                    btnCertified.Attributes["data-bs-title"] = Resources.Global.CertifiedOrganicAndFoodSafety;
                else if (_ocd.bIsCertifiedOrganic)
                    btnCertified.Attributes["data-bs-title"] = Resources.Global.CertifiedOrganic;
                else if (_ocd.bIsFoodSafetyCertified)
                    btnCertified.Attributes["data-bs-title"] = Resources.Global.CertifiedFoodSafety;
            }
        }

        protected const string SQL_KEY_UPDATES =
            @" SELECT DISTINCT prrn_Name, CAST(Capt_US AS VARCHAR(500)) as prrn_Desc
                  FROM PRRatingNumeralAssigned WITH (NOLOCK)
                       INNER JOIN PRRatingNumeral WITH (NOLOCK) ON pran_RatingNumeralId = prrn_RatingNumeralId
                       INNER JOIN PRRating WITH (NOLOCK) ON pran_RatingId = prra_RatingId
                       INNER JOIN Custom_Captions cc WITH (NOLOCK) ON Capt_FamilyType = 'Choices' AND Capt_Family = 'prrn_Name' AND Capt_Code = prrn_Name
                 WHERE prra_CompanyId = @CompanyID
                   AND prra_Current = 'Y'
                   AND prra_Deleted IS NULL";

        protected void PopulateNewClaim()
        {
            if (_ocd.bHasNewClaimActivity)
            {
                btnNewClaim.Visible = true;
            }
        }

        protected void btnNotes_ServerClick(object sender, EventArgs e)
        {
            if (WebUser.HasPrivilege(SecurityMgr.Privilege.CompanyDetailsCustomPage).Enabled)
                Response.Redirect(string.Format(PageConstants.COMPANY_NOTES_BBOS9, CompanyID));
        }

        protected void btnWatchdog_ServerClick(object sender, EventArgs e)
        {
            Response.Redirect(string.Format(PageConstants.BROWSE_COMPANIES));
        }

        protected void btnChanged_ServerClick(object sender, EventArgs e)
        {
            if (WebUser.HasPrivilege(SecurityMgr.Privilege.CompanyDetailsUpdatesPage).Enabled)
                Response.Redirect(string.Format(PageConstants.COMPANY_UPDATES_BBOS9, CompanyID));
        }

        protected void btnNewClaim_ServerClick(object sender, EventArgs e)
        {
            if (WebUser.HasPrivilege(SecurityMgr.Privilege.CompanyDetailsClaimActivityPage).Enabled)
                Response.Redirect(string.Format(PageConstants.COMPANY_CLAIMS_ACTIVITY_BBOS9, CompanyID));
        }


        protected void btnNew_ServerClick(object sender, EventArgs e)
        {
            if (WebUser.HasPrivilege(SecurityMgr.Privilege.CompanyDetailsUpdatesPage).Enabled)
                Response.Redirect(string.Format(PageConstants.COMPANY_UPDATES_BBOS9, CompanyID));
        }
    }
}
