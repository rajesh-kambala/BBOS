/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Service, Inc. 2011

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Blue Book Service, Inc. is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Blue Book Service, Inc.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PRCo.BBS.CRM
{
    public partial class PRCompanyLRL : PageBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                string szBBID = Request.Params["comp_companyid"];

                // special string indicating we want to cleanup the file and close the window.
                string szCleanup = Request.Params["cleanup"];
                string szClose = Request.Params["close"];
                string szListingFileVersion = Request.Params["listingfileversion"];

                if ((szBBID == null) ||
                    (szBBID.Length == 0))
                {
                    Response.Write("No BBID");
                    Response.End();
                    return;
                }


                string filepath = ConfigurationManager.AppSettings["TempReports"];
                if (string.IsNullOrEmpty(filepath))
                {
                    filepath = Server.MapPath("/CRM/TempReports");
                }

                string filename = Path.Combine(filepath, "CompanyLRL" + szBBID + "_" + szListingFileVersion + ".pdf");

                if (szCleanup == "1")
                {
                    if (File.Exists(filename))
                    {
                        File.Delete(filename);
                    }
                    szClose = "1";
                }

                if (szClose == "1")
                {
                    Response.Write("<script type=\"text/javascript\">window.close();</script>");
                }
                else
                {

                    ReportInterface oRI = new ReportInterface();
                    byte[] oReport = oRI.GenerateListingReportLetter(Convert.ToInt32(szBBID));


                    Response.Write("<p>File Path: " + filename + "</p>");

                    File.WriteAllBytes(filename, oReport);

                    //using (FileStream fs = new FileStream(filename, FileMode.Create))
                    //{
                    //    //fs.Write(oReport, 0, oReport.Length);

                    //    using (BinaryWriter bw = new BinaryWriter(fs))
                    //    {
                    //        bw.Write(oReport);
                    //    }
                    //}


                    Response.Write("<p>Wrote File</p>");

                    Response.ClearContent();
                    Response.ClearHeaders();
                    Response.ContentType = "application/pdf";
                    Response.BinaryWrite(oReport);
                    Response.Flush();
                    Response.Close();
                    Response.End();
                }

            }
            catch (Exception Ex)
            {
                Response.Write("<b>Exception:</b><br/>");
                Response.Write("<p>" + Ex.Message + "</p>");
                Response.Write("<p><pre>" + Ex.StackTrace + "</pre></p>");

            }
        }
    }
}