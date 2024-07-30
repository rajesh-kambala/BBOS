using PRCo.EBB.BusinessObjects;
using System;
using System.Data;
using System.Diagnostics;
using System.Web.UI.WebControls;
using TSI.BusinessObjects;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web.UserControls
{
    public partial class CompanyHero : UserControlBase
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
                    img_companyHero.Src = "~/images/ProduceCompanyBackdrop.jpg";
                    break;
                case GeneralDataMgr.INDUSTRY_TYPE_SUPPLY:
                    img_companyHero.Src = "~/images/SupplyAndServiceBackdrop.jpg";
                    break;
                case GeneralDataMgr.INDUSTRY_TYPE_TRANSPORTATION:
                    img_companyHero.Src = "~/images/TransportationBackdrop.jpg";
                    break;
                default :
                    img_companyHero.Src = "~/images/ProduceCompanyBackdrop.jpg";
                    break;
            }            
            PopulateLogo();
        }

        protected void PopulateLogo()
        {
            if (!string.IsNullOrEmpty(_ocd.szPRPublishLogo))
            {
                hlLogo.Visible = true;
                hlLogo.ImageUrl = string.Format(Configuration.CompanyLogoURLRawSize, _ocd.szPRLogo);
                if (!string.IsNullOrEmpty(_ocd.szWebAddress))
                {
                    string szURL = PageConstants.FormatFromRoot(PageConstants.EXTERNAL_LINK_TRIGGER, _ocd.szWebAddress, _ocd.szCompanyID, "C", Request.ServerVariables.Get("SCRIPT_NAME"));
                    hlLogo.NavigateUrl = szURL;
                }
            }

            if (hlLogo.Visible == false)
            {
                pnlImage.Visible = false;
            }
        }
    }
}