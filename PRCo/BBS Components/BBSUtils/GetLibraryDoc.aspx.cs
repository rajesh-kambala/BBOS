/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Company 2010

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Heads and Threads International, LLC is 
 strictly prohibited.

 Confidential, Unpublished Property of Heads and Threads International, LLC
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: GetLibraryDoc
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Web;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;

using TSI.Arch;
using TSI.Utils;

namespace PRCo.BBS.Utils
{
	/// <summary>
	/// Reads the specified logo file from disk and ensures
	/// it is no larger than the specified dimensions.
	/// </summary>
	public partial class GetLibraryDoc : System.Web.UI.Page
	{
		protected ILogger _oLogger;

		protected void Page_Load(object sender, System.EventArgs e)
		{
            Session["RequestName"] = "GetLibraryDoc.aspx";

            try
            {
                if (string.IsNullOrEmpty(Request["File"]))
                {
                    return;
                }

                string szRootPath = Utilities.GetConfigValue("LibraryRootPath", @"D:\Applications\CRM\Library");
                string szFullPath = Path.Combine(szRootPath, Request["File"]);
                if (!File.Exists(szFullPath))
                {
                    throw new ApplicationException("Libary file not found:" + szFullPath);
                }

                string szFileExt = Path.GetExtension(szFullPath).ToLower();

                // Make sure our image is of the correct
                // type.
                if ((szFileExt.Equals(".jpg")) ||
                    (szFileExt.Equals(".jpeg")))
                {
                    szFileExt = "jpeg";
                }
                else if (szFileExt.Equals(".gif"))
                {
                    szFileExt = "gif";
                }
                else if (szFileExt.Equals(".tif"))
                {
                    szFileExt = "tif";
                }
                else if (szFileExt.Equals(".png"))
                {
                    szFileExt = "png";
                }

                else
                {
                    throw new ArgumentException("Unsupported Image Type: " + szFileExt, "File");
                }



                Response.ClearContent();
                Response.ClearHeaders();
                Response.AppendHeader("Content-Disposition", "filename=" + Path.GetFileName(szFullPath));
                Response.ContentType = "image/" + szFileExt;

                Response.WriteFile(szFullPath);
            }
            catch (Exception eX)
            {
                LogException(eX);
            }

            Response.End();
		}

		protected void LogMessage(string szMsg) {
			if (_oLogger == null) {
				_oLogger = (ILogger)Session["Logger"];
                _oLogger.RequestName = "GetLibraryDoc.aspx";
			}

			_oLogger.LogMessage(szMsg);
		}

        protected void LogException(Exception eX)
        {
            if (_oLogger == null)
            {
                _oLogger = (ILogger)Session["Logger"];
                _oLogger.RequestName = "GetLibraryDoc.aspx";
            }

            _oLogger.LogError(eX);

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
		}
		#endregion
	}
}
