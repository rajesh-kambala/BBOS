using System;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web.PublicProfiles
{
    public partial class Produce : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
           // Page.Header.DataBind();
        }

        protected string GetMarketingSiteURL()
        {
            return Utilities.GetConfigValue("MarketingSiteURL");
        }

        public void SetFormClass(string szClass)
        {
            Control MasterPageForm = FindControl("form1");
            if (MasterPageForm != null)
                ((HtmlForm)MasterPageForm).Attributes.Add("class", szClass);
        }
    }
}