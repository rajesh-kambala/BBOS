/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Company 2006-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Heads and Threads International, LLC is 
 strictly prohibited.

 Confidential, Unpublished Property of Heads and Threads International, LLC
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: GetLogo
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Drawing.Drawing2D;
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
    public partial class GetLogo : System.Web.UI.Page
    {
        protected ILogger _oLogger;
        protected const string EMPTY_IMAGE = @"\NoLogo.gif";

        protected void Page_Load(object sender, System.EventArgs e)
        {
            Session["RequestName"] = "GetLogo.aspx";

            try
            {
                bool bUseEmptyImage = false;
                string szRootPath = Utilities.GetConfigValue("BRLogoRootPath", @"\\BHS2\Logos");

                // If this company doesn't have an associated logo, we don't want to throw
                // an exception, just return an empty image.  SRS will hide the image, but it
                // cannot prevent us from attempting to retrieve it.
                string szLogoFile = null;
                if (string.IsNullOrEmpty(Request["LogoFile"]))
                {
                    szLogoFile = string.Concat(szRootPath, EMPTY_IMAGE);
                    bUseEmptyImage = true;
                }
                else
                {
                    szLogoFile = string.Concat(szRootPath, Request["LogoFile"]);
                }

                int iWidth = Utilities.GetIntConfigValue("BRLogoWidth", 100);
                if (!string.IsNullOrEmpty(Request["Width"]))
                {
                    iWidth = Convert.ToInt32(Request["Width"]);
                }

                int iHeight = Utilities.GetIntConfigValue("BRLogoHeight", 100);
                if (!string.IsNullOrEmpty(Request["Height"]))
                {
                    iHeight = Convert.ToInt32(Request["Height"]);
                }

                bool blnRawSize = false;
                if (!string.IsNullOrEmpty(Request["RawSize"]))
                {
                    blnRawSize = true;
                }

			    // Make sure our image is of the correct
			    // type.
			    string szFileExt = Path.GetExtension(szLogoFile).ToLower();
			    ImageFormat oImageFormat = null;
    			
			    // Make sure our image is of the correct
			    // type.
			    if ((szFileExt.Equals(".jpg")) ||
				    (szFileExt.Equals(".jpeg"))) {
				    oImageFormat = ImageFormat.Jpeg;
				    szFileExt = "jpeg";
			    } else if (szFileExt.Equals(".gif")) {
				    oImageFormat = ImageFormat.Gif;
				    szFileExt = "gif";
                } else if (szFileExt.Equals(".png")) {
                    szFileExt = "png";
                }
                else
                {
                    throw new ArgumentException("Unsupported Image Type: " + szFileExt, "File");
                }


                if (!File.Exists(szLogoFile))
                {
                    if (bUseEmptyImage)
                    {
                        return;
                    }
                    else
                    {
                        if (Utilities.GetBoolConfigValue("GetLogoThrowNotFoundException", true))
                        {
                            throw new ApplicationException("Image file not found: " + szLogoFile + "  ROOT PATH=" + szRootPath);
                        }
                        return;
                    }
                }

                FileStream fs = new FileStream(szLogoFile, FileMode.Open, FileAccess.Read);
                System.Drawing.Image oLogoImage = System.Drawing.Image.FromStream(fs);

                System.Drawing.Image oSizedImage = null;

                if (blnRawSize)
                {
                    // Bring back original image so that it's not fuzzy -- client will size it as needed
                    oSizedImage = oLogoImage;
                }
                else
                {
                    if ((oLogoImage.Width > iWidth) ||
                        (oLogoImage.Height > iHeight))
                    {
                        oSizedImage = ResizeImage(oLogoImage, new Size(iWidth, iHeight));
                    }
                    else
                    {
                        oSizedImage = oLogoImage;
                    }
                }
                  
			    Response.ClearContent();
			    Response.ClearHeaders();
    			
			    Response.AppendHeader("Content-Disposition", "filename=" + Path.GetFileName(szLogoFile));
			    Response.ContentType = "image/" + szFileExt;

                oSizedImage.Save(Response.OutputStream, oImageFormat);

                fs.Close();
                oLogoImage.Dispose();
                oSizedImage.Dispose();
            }
            catch (Exception eX)
            {
                LogException(eX);
            }

            Response.End();
        }

        public System.Drawing.Image ResizeImage(System.Drawing.Image image, Size size, bool preserveAspectRatio = true)
        {
            int newWidth;
            int newHeight;
            if (preserveAspectRatio)
            {
                int originalWidth = image.Width;
                int originalHeight = image.Height;
                float percentWidth = (float)size.Width / (float)originalWidth;
                float percentHeight = (float)size.Height / (float)originalHeight;
                float percent = percentHeight < percentWidth ? percentHeight : percentWidth;
                newWidth = (int)(originalWidth * percent);
                newHeight = (int)(originalHeight * percent);
            }
            else
            {
                newWidth = size.Width;
                newHeight = size.Height;
            }

            System.Drawing.Image newImage = new Bitmap(newWidth, newHeight);
            using (Graphics graphicsHandle = Graphics.FromImage(newImage))
            {
                graphicsHandle.SmoothingMode = SmoothingMode.AntiAlias;
                graphicsHandle.InterpolationMode = InterpolationMode.HighQualityBicubic;
                graphicsHandle.PixelOffsetMode = PixelOffsetMode.HighQuality;

                graphicsHandle.DrawImage(image, 0, 0, newWidth, newHeight);
            }
            return newImage;
        }

		protected void LogMessage(string szMsg) {
			if (_oLogger == null) {
				_oLogger = (ILogger)Session["Logger"];
                _oLogger.RequestName = "GetLogo.aspx";
            }

            _oLogger.LogMessage(szMsg);
        }

        protected void LogException(Exception eX)
        {
            if (_oLogger == null)
            {
                _oLogger = (ILogger)Session["Logger"];
                _oLogger.RequestName = "GetLogo.aspx";
            }

            _oLogger.LogError(eX);

        }

        /// <summary>
        /// Delagate required, but not used.
        /// </summary>
        /// <returns></returns>
        public bool ThumbnailCallback()
        {
            return false;
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
