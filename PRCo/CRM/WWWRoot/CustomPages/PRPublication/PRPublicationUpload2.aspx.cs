using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.IO;

namespace PRCO.BBS.CRM
{
	public partial class PRPublicationUpload2 : System.Web.UI.Page
	{
		// protected override void Page_Load(object sender, EventArgs e)
		protected void Page_Load(object sender, EventArgs e)
		{
			if (Page.IsPostBack)
			{
				bool include_edition = (hdnPublicationCode.Value.ToUpper() == "BP");
				if (upPublicationFile.HasFile)
				{
					string upload_basedir = hdnUploadBaseDir.Value;
					if (upload_basedir.Length > 0)
					{
						upload_basedir += ((! upload_basedir.EndsWith(@"\")) ? @"\" : "");
					}
					string upload_dir = upload_basedir + hdnPublicationCode.Value + @"\" + (include_edition ? hdnPublicationEdition.Value + @"\" : "");

					// Make sure that the directory exists.
					if (! Directory.Exists(upload_dir))
					{
						Directory.CreateDirectory(upload_dir);
					}


					// Check for the old file and delete it
					string old_file = upload_dir + hdnOldUploadFileName.Value;
					if (File.Exists(old_file))
					{
						File.Delete(old_file);
					}

                    // Now save our file.
    				string upload_file = upload_dir + upPublicationFile.FileName;
                    upPublicationFile.SaveAs(upload_file);

					// Update the various fields
					hdnUploadedFileName.Value = upload_file.Substring(upload_basedir.Length);  // without the directory
				}

				hdnSubmitChainFlag.Value = "true";	 // continue submitting
			}
		}
	}
}
