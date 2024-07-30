using System;
using System.IO;
using System.Collections;
using System.Data;
using System.Web;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Web.Configuration;

using PRCo.BBS;

namespace PRCo.BBS.CRM.Report
{
    /// <summary>
    /// Summary description for GetBusinessReportWeb.
    /// </summary>
    public partial class PRCompanyBRReport : System.Web.UI.Page
    {
        private void Page_Load(object sender, System.EventArgs e)
        {
            LogDebugMessage("Page_Load - Start");

            string szBBID = Request.Params["comp_companyid"];
            string szRequestingCompanyId = Request.Params["RequestingCompanyId"];
            string szSaveToFile = Request.Params["SaveToFile"];
            string szCloseWindow = Request.Params["CloseWindow"];
            string szIncSurvey = Request.Params["IncSurvey"];
			string szBRFileVersion = Request.Params["BRFileVersion"];

			if ((szBBID == null) ||
                (szBBID.Length == 0))
            {

                Response.Write("No BBID");
                Response.End();
                return;
            }

            //default is false; values of 1 or true can override
            bool bIncludeSurvey = false;
            if (szIncSurvey != null){
                if (szIncSurvey.Equals("1") || szIncSurvey.Equals("true")){
                    bIncludeSurvey = true;
                }
            }

            byte[] oReport = null;
            try
            {
                LogDebugMessage("Generate Report - Start");
                ReportInterface oRI = new ReportInterface();
                oReport = oRI.GenerateBusinessReport(szBBID, 4, false, bIncludeSurvey, 0);
                LogDebugMessage("Generate Report - End");
            }
            catch (Exception Ex)
            {
                string debugMsg = "<p>";
                debugMsg += "szBBID:" + szBBID + "<br/>";
                debugMsg += "szRequestingCompanyId:" + szRequestingCompanyId + "<br/>";
                debugMsg += "szRequestingCompanyId:" + szRequestingCompanyId + "<br/>";
                debugMsg += "szRequestingCompanyId:" + szRequestingCompanyId + "<br/>";
                debugMsg += "<p>";

                debugMsg += "<p>" + Ex.Message + "</p>";

                lblMessage.Text = debugMsg;
                return;
            }


            if (szCloseWindow != null && szCloseWindow == "1")
            {
                Response.Write("<script language=javascript >window.close();</script>");
            }
            else
            {
                LogDebugMessage("Send Content - Start");
                Response.ClearContent();
                Response.ClearHeaders();

                Response.ContentType = "application/pdf";

                Response.BinaryWrite(oReport);

                Response.Flush();
                Response.Close();

                LogDebugMessage("Send Content - End");
            }

            if (szSaveToFile != null && szSaveToFile.Equals("1"))
            {
                LogDebugMessage("Save To File - Start");
                string filepath = WebConfigurationManager.AppSettings["TempReports"];
                string filename = "";
                if ((filepath == null) || (filepath.Length == 0))
                {
                    filepath = Server.MapPath("/CRM/TempReports");
                }
                string szReportName = "BusinessReportOn" + szBBID;
                if (szRequestingCompanyId != null)
                    szReportName += "For" + szRequestingCompanyId;
                filename = Path.Combine(filepath, szReportName + "_" + szBRFileVersion + ".pdf");

                using (FileStream fs = new FileStream(filename, FileMode.Create))
                {
                    fs.Write(oReport, 0, oReport.Length);
                }
                LogDebugMessage("Save To File - End");
            }

            LogDebugMessage("Page_Load - End");
        }

        //string _szLogFile = @"C:\Temp\CRMLog.txt";
        private void LogDebugMessage(string szMsg)
        {
            //using (StreamWriter sw = File.AppendText(_szLogFile))
            //{
            //    sw.WriteLine(DateTime.Now.ToString("yyyyMMdd-hhmmss-ffff") + "|" +  szMsg);
            //}
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
