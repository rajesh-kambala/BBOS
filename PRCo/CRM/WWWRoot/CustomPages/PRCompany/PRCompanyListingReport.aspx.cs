using System;
using System.IO;
using System.Collections;
//using System.ComponentModel;
using System.Data;
//using System.Drawing;
using System.Web;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Web.Configuration;



namespace PRCo.BBS.CRM.Report
{
    /// <summary>
    /// Summary description for GetBusinessReportWeb.
    /// </summary>
    public partial class PRCompanyListingReport : System.Web.UI.Page
    {
        private void Page_Load(object sender, System.EventArgs e)
        {
            string szBBID = Request.Params["comp_companyid"];
            string szIncludeBranches = Request.Params["includebranches"];
            string szIncludeAffiliations = Request.Params["includeaffiliations"];
            // special string indicating we want to cleanup the file and close the window.
            string szCleanup = Request.Params["cleanup"];
            string szClose = Request.Params["close"];
			string szListingFileVersion = Request.Params["listingfileversion"];

            bool bIncludeBranches = true;
            bool bIncludeAffiliations = true;

            string SID = Request.Params["SID"];

            if ((szBBID == null) ||
                (szBBID.Length == 0))
            {

                Response.Write("No BBID");
                Response.End();
                return;
            }
            if ((szIncludeBranches == null) ||
                (szIncludeBranches.Length == 0))
            {
                bIncludeBranches = false;
            }

            if ((szIncludeAffiliations == null) ||
                (szIncludeAffiliations.Length == 0))
            {
                bIncludeAffiliations = false;
            }


            string filepath = WebConfigurationManager.AppSettings["TempReports"];
			string filename = "";

            if (string.IsNullOrEmpty(filepath)) {
				filepath = Server.MapPath("/CRM/TempReports");
			}
			filename = Path.Combine(filepath, "CompanyListing" + szBBID + "_" + szListingFileVersion + ".pdf");

            if (szCleanup != null && szCleanup == "1")
            {
                if (File.Exists(filename))
                {
                    File.Delete(filename);
                }
                szClose = "1";
            }
            
            if (szClose != null && szClose == "1")
            {
                Response.Write("<script language=javascript >window.close();</script>");
            }
            else
            {

                ReportInterface oRI = new ReportInterface();
                byte[] oReport = oRI.GenerateCompanyListingReport(szBBID, bIncludeBranches, bIncludeAffiliations);

                Response.ClearContent();
                Response.ClearHeaders();
                Response.ContentType = "application/pdf";
                //Response.WriteFile(filename);

                Response.BinaryWrite(oReport);

                Response.Flush();
                Response.Close();

                using (FileStream fs = new FileStream(filename, FileMode.Create))
                {
                    fs.Write(oReport, 0, oReport.Length);
                }
                
                Response.End();
            }

        }

        #region Web Form Designer generated code
        override protected void OnInit(EventArgs e)
        {
            //
            // CODEGEN: This call is required by the ASP.NET Web Form Designer.
            //
            InitializeComponent();
            base.OnInit(e);
        }

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.Load += new System.EventHandler(this.Page_Load);
        }
        #endregion
    }
}
