using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PRCo.BBS.CRM.CustomPages.PRGeneral
{
    public partial class FileUpload : System.Web.UI.Page
    {
        public const string TEMP_FILE_PATH = @"D:\Applications\CRM\WWWRoot\TempReports";

        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void AjaxFileUpload1_UploadComplete(object sender, AjaxControlToolkit.AjaxFileUploadEventArgs e)
        {
            string fileNametoupload = Path.Combine(TEMP_FILE_PATH, e.FileName.ToString());
            AjaxFileUpload1.SaveAs(fileNametoupload);
        }
    }
}