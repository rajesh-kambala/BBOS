using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PRCo.BBOS.UI.Web
{
    public partial class Corporate : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        public void LumberVisibility(bool blnVisible)
        {
            divLumber.Visible = blnVisible;
        }

        public void SetFormClass(string szClass)
        {
            form1.Attributes.Add("class", szClass);
        }
    }
}