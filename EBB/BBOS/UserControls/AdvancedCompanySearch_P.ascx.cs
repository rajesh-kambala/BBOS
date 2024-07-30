using PRCo.EBB.BusinessObjects;
using PRCo.EBB.Util;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

//TODO:JMT remove this from solution when done transfering it

namespace PRCo.BBOS.UI.Web
{
    public partial class AdvancedCompanySearch_P : UserControlBase
    {
        protected CompanySearchCriteria _oCompanySearchCriteria;

        public CompanySearchCriteria CompanySearchCriteria
        {
            get
            {
                return _oCompanySearchCriteria;
            }
            set
            {
                _oCompanySearchCriteria = value;
            }
        }

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if (!IsPostBack)
            {
                PopulateForm();
            }
        }

        public void LoadLookupValues()
        {
            #region "Company Details"
            // Bind Company Type drop-down
            // NOTE: Add "Any" option
            //RadioButtonList rblCompanyType = (RadioButtonList)_oAdvancedCompanySearchControl.FindControl("rblCompanyType");
            PageBase.BindLookupValues(rblCompanyType, GetReferenceData(AdvancedCompanySearchCriteriaControl.REF_DATA_COMPANY_TYPE));
            ListItem oItem = new ListItem(Resources.Global.Any, "");
            rblCompanyType.Items.Insert(0, oItem);

            // Bind Industry Type control
            //BindLookupValues(rblIndustryType, GetReferenceData(REF_DATA_INDUSTRY_TYPE));
            //ModifyIndustryType(rblIndustryType);
            #endregion

            #region "Rating"
            // Bind Industry Type control
            //BindLookupValues(rblIndustryType, GetReferenceData(REF_DATA_INDUSTRY_TYPE));
            //ModifyIndustryType(rblIndustryType);

            // Create Search Type list
            List<ICustom_Caption> lSearchTypeValues = GetSearchTypeValues();

            // Bind Membership Year Search Type drop-down
            //BindLookupValues(ddlMembershipYearSearchType, lSearchTypeValues);

            // Bind BB Score search type drop-down
            PageBase.BindLookupValues(ddlBBScoreSearchType, lSearchTypeValues);

            // Bind Pay Report Count search type drop-down
            //BindLookupValues(ddlPayReportCountSearchType, lSearchTypeValues);

            // Create Membership Year List
            //List<ICustom_Caption> lMembershipYearValues = new List<ICustom_Caption>();
            //for (int i = 1901; i <= DateTime.Now.Year; i++)
            //{
            //ICustom_Caption oCustom_Caption4 = new Custom_Caption();
            //oCustom_Caption4.Code = i.ToString();
            //oCustom_Caption4.Meaning = i.ToString();
            //lMembershipYearValues.Add(oCustom_Caption4);

            // Bind Integrity/Ability Rating controls
            // NOTE: Dynamic control - done in page OnInit to correctly process viewstate

            // Bind Pay Description Controls
            // NOTE: Dynamic control - done in page OnInit to correctly process viewstate

            // Bind Credit Worth Rating Controls
            // NOTE: Dynamic control - done in page OnInit to correctly process viewstate
        }
        #endregion

        public void PopulateForm()
        {
            #region "Company Details"
            txtCompanyName.Attributes.Add("placeholder", Resources.Global.FullOrPartOfTheName);
            txtCompanyName.Attributes.Add("aria-label", Resources.Global.FullOrPartOfTheName);

            txtPhoneNumber.Attributes.Add("placeholder", Resources.Global.EGOrPartOfTheNumber);
            txtPhoneNumber.Attributes.Add("aria-label", Resources.Global.FullOrPartOfThePhoneNumber);

            txtEmail.Attributes.Add("placeholder", Resources.Global.EmailOrPartOfEmail);
            txtEmail.Attributes.Add("aria-label", Resources.Global.FullOrPartOfEmail);

            // Set Company Search Information
            // Industry Type 
            //TODO:JMT handle industry security
            //SetListDefaultValue(rblIndustryType, _oCompanySearchCriteria.IndustryType);

            //ApplySecurity(pnlIndustryType, SecurityMgr.Privilege.CompanySearchByIndustry);

            // Company Name
            txtCompanyName.Text = _oCompanySearchCriteria.CompanyName;

            // Company Type
            foreach (ListItem oItem in rblCompanyType.Items)
            {
                if (oItem.Value == _oCompanySearchCriteria.CompanyType)
                    oItem.Selected = true;
            }

            // Rejected Shipments
            chkHandlesRejectedShipments.Checked = _oCompanySearchCriteria.SalvageDistressedProduce;

            // Company Phone
            txtPhoneNumber.Text = _oCompanySearchCriteria.PhoneNumber;

            // Must have phone
            chkPhoneNotNull.Checked = _oCompanySearchCriteria.PhoneNotNull;

            // Company Email
            txtEmail.Text = _oCompanySearchCriteria.Email;

            chkEmailNotNull.Checked = _oCompanySearchCriteria.EmailNotNull;

            //Rating Tab
            chkTMFMNotNull.Checked = _oCompanySearchCriteria.IsTMFM;
            #endregion

            #region "Rating"
            txtBBScore.Attributes.Add("placeholder", Resources.Global.EnterANumber0To1000);
            txtBBScore.Attributes.Add("aria-label", Resources.Global.EnterANumber0To1000);
            //// Set Rating Criteria Information
            //SetListDefaultValue(rblIndustryType, _oCompanySearchCriteria.IndustryType);

            //// Set Profile Criteria Information
            //if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            //{
            //    // Pay Report Count
            //    SetListDefaultValue(ddlPayReportCountSearchType, _oCompanySearchCriteria.PayReportCountSearchType);
            //    if (_oCompanySearchCriteria.PayReportCount > -1)
            //    {
            //        txtPayReportCount.Text = _oCompanySearchCriteria.PayReportCount.ToString();
            //    }

            //    // Pay Indicator
            //    string[] aszPayIndicator = UIUtils.GetString(_oCompanySearchCriteria.PayIndicator).Split(new char[] { ',' });
            //    SetTableValues(aszPayIndicator, tblPayIndicator, PREFIX_PAYINDICATOR);
            //}
            //else
            //{
            //    chkTMFMNotNull.Checked = _oCompanySearchCriteria.IsTMFM;

            //    // Integrity / Ability Rating
            //    string[] aszIntegrityRating = UIUtils.GetString(_oCompanySearchCriteria.RatingIntegrityIDs).Split(new char[] { ',' });
            //    SetTableValues(aszIntegrityRating, tblIntegrityRating, PREFIX_INTEGRITYRATING);

            //    // Pay Description
            //    string[] aszPayDescriptions = UIUtils.GetString(_oCompanySearchCriteria.RatingPayIDs).Split(new char[] { ',' });
            //    SetTableValues(aszPayDescriptions, tblPayRating, PREFIX_PAYDESCRIPTION);
            //}

            //// BB Score
            PageBase.SetListDefaultValue(ddlBBScoreSearchType, _oCompanySearchCriteria.BBScoreSearchType);
            txtBBScore.Text = UIUtils.GetStringFromInt(_oCompanySearchCriteria.BBScore, true);


            //// Credit Worth Rating
            //string[] aszCreditRatings = UIUtils.GetString(_oCompanySearchCriteria.RatingCreditWorthIDs).Split(new char[] { ',' });
            //if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            //    SetTableValues(aszCreditRatings, tblCreditWorthRatingL, PREFIX_CREDITWORTHRATING);
            //else
            //    SetTableValues(aszCreditRatings, tblCreditWorthRating, PREFIX_CREDITWORTHRATING);
            #endregion

            //Spot1
        }

        /// <summary>
        /// Collects and stores the search criteria on the users current company search
        /// criteria object 
        /// </summary>
        public void StoreCriteria()
        {
            // Save Company Search Criteria

            // Industry Type
            //TODO:JMT segregate by which industry tab they are on
            //if (_oUser.prwu_IndustryType != GeneralDataMgr.INDUSTRY_TYPE_LUMBER) 
            //{
            //_oCompanySearchCriteria.IndustryType = rblIndustryType.SelectedValue;
            //}

            // Company Name 
            _oCompanySearchCriteria.CompanyName = txtCompanyName.Text.Trim();

            // CompanyType, Listing Status
            _oCompanySearchCriteria.CompanyType = rblCompanyType.SelectedValue;

            // Rejected Shipments (aka SalvageDistressedProduce)
            _oCompanySearchCriteria.SalvageDistressedProduce = chkHandlesRejectedShipments.Checked;

            // CompanyPhone
            _oCompanySearchCriteria.PhoneNumber = txtPhoneNumber.Text.Trim();

            // Must have phone number
            _oCompanySearchCriteria.PhoneNotNull = chkPhoneNotNull.Checked;

            //Email
            _oCompanySearchCriteria.Email = txtEmail.Text.Trim();
            _oCompanySearchCriteria.EmailNotNull = chkEmailNotNull.Checked;

            //Rating Tab
            _oCompanySearchCriteria.IsTMFM = chkTMFMNotNull.Checked;
            
            // BBScore
            if (txtBBScore.Text.Length > 0)
                _oCompanySearchCriteria.BBScore = Convert.ToInt32(txtBBScore.Text);
            else
                _oCompanySearchCriteria.BBScore = 0;
            _oCompanySearchCriteria.BBScoreSearchType = ddlBBScoreSearchType.SelectedValue;

            //Spot 2
        }


        /// <summary>
        /// Clears and stores the search criteria on the users current company search
        /// criteria object 
        /// </summary>
        public void ClearCriteria()
        {
            // Clear the corresponding Company Search Criteria object and reload the page

            // Company Name 
            txtCompanyName.Text = "";

            // CompanyType, Listing Status
            rblCompanyType.SelectedIndex = -1;
            chkHandlesRejectedShipments.Checked = false;

            // CompanyPhone
            txtPhoneNumber.Text = "";

            // Phone Not Null
            chkPhoneNotNull.Checked = false;

            //CompanyEmail
            txtEmail.Text = "";
            chkEmailNotNull.Checked = false;

            // Rating tab
            chkTMFMNotNull.Checked = false;

            //Spot 3
        }

        public TextBox PhoneNumber
        {
            get { return txtPhoneNumber; }
        }
        public TextBox Email
        {
            get { return txtEmail; }
        }
    }
}