/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2023

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: PublishingBase.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using TSI.DataAccess;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This class provides the common functionality for pages
    /// that display PRPublishingArticles
    /// </summary>
    public partial class PublishingBase : PageBase
    {
        protected const string SQL_SELECT_EDITION =
            @"SELECT TOP {0} prpbed_PublicationEditionID, prpbed_Name, prpbed_CoverArtFileName, prpbed_CoverArtThumbFileName, prpbed_PublishDate, prpbar_PublicationArticleID 
                FROM PRPublicationEdition WITH (NOLOCK)
                     INNER JOIN PRPublicationArticle WITH (NOLOCK) ON prpbar_PublicationEditionID = prpbed_PublicationEditionID 
               WHERE prpbed_PublishDate < GETDATE() 
                {1} 
            ORDER BY prpbed_PublishDate DESC";

        /* {0}= ArticleID
           {1}= WebUser.prwu_IndustryType
           {2}=wp_posts, 
           {3}=wp_postmeta
        */
        public const string SQL_SELECT_WORDPRESS_BP_ARTICLE =
        @"SELECT post_date, post_content, post_title, Standfirst, Author, AuthorAbout, ThumbnailImg, Category, BlueprintEdition, [Date], dbo.ufn_GetWordPressCategories2(wp.ID,'{1}') Categories
            FROM {2} wp WITH (NOLOCK)
	        CROSS APPLY CRM.dbo.ufn_GetWordPressPostDetails4(wp.ID,'{1}') wpd 
            WHERE wp.post_status IN ('publish', 'future')		
	        AND wp.ID={0}";

        //protected const string SQL_SELECT_BPO =
        //    @"SELECT TOP {0} prpbar_PublicationArticleID, prpbar_Name, prpbar_CoverArtFileName, prpbar_PublishDate 
        //        FROM PRPublicationArticle WITH (NOLOCK) 
        //       WHERE prpbar_PublicationCode = 'BPO' 
        //   ORDER BY prpbar_PublishDate DESC";

        protected const string SQL_SELECT_EDITION_ARTICLE =
            @"SELECT {0}
                FROM PRPublicationArticle WITH (NOLOCK) 
               WHERE prpbar_PublicationEditionID = {1}
                 AND prpbar_PublicationCode = '{2}'
            ORDER BY prpbar_Sequence";

        protected const string SQL_SELECT_ARTICLE =
            @"SELECT prpbar_FileName, prpbar_CoverArtFileName, prpbar_MediaTypeCode
                FROM PRPublicationArticle WITH (NOLOCK) 
               WHERE prpbar_PublicationArticleID = {0}";

        protected decimal _dTotalPrice = 0M;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
        }

        public static string GetWordPressImageURL(object szThumbnailImg)
        {
            if (szThumbnailImg == DBNull.Value)
                return Utilities.GetConfigValue("DefaultPublishingImage", "en-us/images/icon-download.jpg");

            return (string)szThumbnailImg;
        }
        public static string GetWordPressImageURL_ByPostTitle(object szPostTitle)
        {
            if (szPostTitle == DBNull.Value)
                return Utilities.GetConfigValue("DefaultPublishingImage", "en-us/images/icon-download.jpg");

            string szPostTitle2 = ((string)szPostTitle).Replace(" ", "_").Replace("&amp;", "").Replace("(", "").Replace(")", "").Replace(",","").Replace("__","_").Replace(":","");
            return string.Format("{0}{1}_Thumbnail.jpg", Utilities.GetConfigValue("DefaultPublishingImageFolder", "https://www.producebluebook.com/wp-content/uploads/KYC_images/"), szPostTitle2);
        }

        public static string GetWordPressImageURL_By_KYCThumbnailImage(object szKYCThumbnailImage)
        {
            if (szKYCThumbnailImage == DBNull.Value)
                return Utilities.GetConfigValue("DefaultPublishingImage", "en-us/images/icon-download.jpg");

            return string.Format("{0}{1}", Utilities.GetConfigValue("DefaultPublishingImageFolder", "https://www.producebluebook.com/wp-content/uploads/KYC_images/"), szKYCThumbnailImage);
        }

        public static string GetImageURL(object szFileName)
        {
            if (szFileName == DBNull.Value)
            {
                return Utilities.GetConfigValue("DefaultPublishingImage", "en-us/images/icon-download.jpg");
            }
            return GetImageURL((string)szFileName);
        }

        /// <summary>
        /// Returns the url of an image file.
        /// </summary>
        /// <param name="szFileName"></param>
        /// <returns></returns>
        public static string GetImageURL(string szFileName)
        {
            if (szFileName.StartsWith("http"))
                return szFileName;

            return PageControlBaseCommon.GetVirtualPath() + Utilities.GetConfigValue("LearningCenterVirtualFolder") + szFileName;
        }


        /// <summary>
        /// Helper method returns the file size in a standard format.
        /// </summary>
        /// <param name="articleID"></param>
        /// <returns></returns>
        protected string GetFileSize(int articleID)
        {
            return GetFileSize(GetArticleFileName(articleID, _oLogger));
        }

        protected string GetFileSize(int articleID, object mediaTypeCode)
        {
            if (mediaTypeCode == DBNull.Value)
            {
                return GetFileSize(GetArticleFileName(articleID, _oLogger), "Doc");
            }
            return GetFileSize(GetArticleFileName(articleID, _oLogger), Convert.ToString(mediaTypeCode));
        }

        protected string GetFileSize(string fileName)
        {
            return GetFileSize(fileName, "Doc");
        }

        protected string GetFileSize(string fileName, string mediaTypeCode)
        {
            if (mediaTypeCode != "Doc")
            {
                return string.Empty;
            }

            try
            {
                FileInfo oFileInfo = new FileInfo(Path.Combine(Utilities.GetConfigValue("LearningCenterIndexPath"), fileName));
                return UIUtils.GetFileSize(oFileInfo.Length);
            }
            catch (IOException e)
            {
                LogError(e);
                return string.Empty;
            }
        }

        protected string GetMediaTypeCode(object mediaTypeCode)
        {
            if (mediaTypeCode == DBNull.Value)
            {
                mediaTypeCode = "Doc";
            }

            return GetReferenceValue("prpbar_MediaTypeCode", mediaTypeCode);
        }

        /// <summary>
        /// Returns the article file name.
        /// </summary>
        public static string GetArticleFileName(int publicationArticleID, ILogger oLogger)
        {
            string dummy1 = null;
            string dummy2 = null;
            return GetArticleFileName(publicationArticleID, out dummy1, out dummy2, oLogger);
        }

        public static string GetArticleFileName(int publicationArticleID, out string coverArtFileName, out string mediaTypeCode, ILogger oLogger)
        {
            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            oDBAccess.Logger = oLogger;

            string fileName = null;
            coverArtFileName = null;
            mediaTypeCode = null;

            using (IDataReader reader = oDBAccess.ExecuteReader(string.Format(SQL_SELECT_ARTICLE, publicationArticleID),
                                                                CommandBehavior.CloseConnection))
            {
                if (reader.Read())
                {
                    fileName = oDBAccess.GetString(reader, 0);
                    coverArtFileName = oDBAccess.GetString(reader, 1);
                    mediaTypeCode = oDBAccess.GetString(reader, 2);
                }
            }

            return fileName;
        }

        public static bool SetFlipBookLink(int editionID, HyperLink cover, HyperLink title, Image coverImage)
        {
            bool editionHasFlipbook = false;

            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            oDBAccess.Logger = LoggerFactory.GetLogger();  //_oLogger;

            using (IDataReader reader = oDBAccess.ExecuteReader(string.Format(SQL_SELECT_EDITION_ARTICLE, "prpbar_PublicationArticleID, prpbar_Name, prpbar_CoverArtFileName, prpbar_CoverArtThumbFileName", editionID, "BPFB"),
                                                                CommandBehavior.CloseConnection))
            {
                if (reader.Read())
                {
                    editionHasFlipbook = true;

                    Label lblFlipBookTitle = (Label)title.FindControl("lblFlipBookTitle");
                    lblFlipBookTitle.Text = string.Format(Resources.Global.BlueprintsEditionTitle, reader.GetString(1));

                    title.NavigateUrl = "~/" + PageControlBaseCommon.GetFileDownloadURL(reader.GetInt32(0), editionID, "PRPublicationEdition");
                    title.Target = "_blank";
                    title.Attributes.Add("alt", title.Text);

                    if (cover != null)
                    {
                        if (reader["prpbar_CoverArtFileName"] != DBNull.Value)
                        {
                            coverImage.ImageUrl = PublishingBase.GetImageURL(reader["prpbar_CoverArtFileName"]);
                        }

                        cover.NavigateUrl = title.NavigateUrl;
                        cover.Target = "_blank";
                    }
                }
            }

            return editionHasFlipbook;
        }

        public static int SetFlipBookSupplements(int editionID, Repeater flipBookrepeater, Repeater contentRepeater)
        {
            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            oDBAccess.Logger = LoggerFactory.GetLogger(); //_oLogger;

            DataSet ds = oDBAccess.ExecuteSelect(string.Format(SQL_SELECT_EDITION_ARTICLE, "prpbar_PublicationArticleID, prpbar_Name, prpbar_CoverArtFileName, prpbar_PublicationEditionID", editionID, "BPFBS"));

            flipBookrepeater.DataSource = ds; // oDBAccess.ExecuteReader(string.Format(SQL_SELECT_EDITION_ARTICLE, "prpbar_PublicationArticleID, prpbar_Name, prpbar_CoverArtFileName, prpbar_PublicationEditionID", editionID, "BPFBS"), CommandBehavior.CloseConnection);
            flipBookrepeater.DataBind();

            if (contentRepeater != null)
            {
                contentRepeater.DataSource = ds; // oDBAccess.ExecuteReader(string.Format(SQL_SELECT_EDITION_ARTICLE, "prpbar_PublicationArticleID, prpbar_Name, prpbar_CoverArtFileName, prpbar_PublicationEditionID", editionID, "BPFBS"), CommandBehavior.CloseConnection);
                contentRepeater.DataBind();
            }

            return flipBookrepeater.Items.Count;
        }

        /// <summary>
        /// Returns the appropriate number of indentation tags for
        /// the specified level.  A level of 1 means no indentation.
        /// </summary>
        /// <param name="iLevel"></param>
        /// <param name="bBeginning"></param>
        /// <returns></returns>
        protected string GetIndentation(int iLevel, bool bBeginning)
        {
            string szIndent = string.Empty;

            for (int i = 0; i < (iLevel - 1); i++)
            {
                if (bBeginning)
                {
                    szIndent += "<blockquote>";
                }
                else
                {
                    szIndent += "</blockquote>";
                }
            }

            return szIndent;
        }

        /// <summary>
        /// Only members level 1 or greater can access
        /// this page.
        /// </summary>
        /// <returns></returns>
        protected override bool IsAuthorizedForPage()
        {
            return true;
        }

        protected override bool IsAuthorizedForData()
        {
            return true;
        }

        protected int _iCurrentBPEditionID = -1;
        /// <summary>
        /// Determines if the specified Edition ID is the
        /// current edition.
        /// </summary>
        /// <returns></returns>
        protected bool IsCurrentEdition(int iEditionID)
        {
            if (_iCurrentBPEditionID == -1)
            {
                _iCurrentBPEditionID = GetObjectMgr().GetCurrentBluePrintsEdition();
            }

            if (iEditionID == _iCurrentBPEditionID)
            {
                return true;
            }

            return false;
        }

        /// <summary>
        /// Returns the price for the specified article.  It builds
        /// a list of ServiceUnitPaymentInfo objects for use in communicating
        /// with the ServiceUnitPayment page.
        /// </summary>
        /// <param name="iArticleID"></param>
        /// <param name="oPrice"></param>
        /// <param name="iProductID"></param>
        /// <param name="dtNoChargeExpiration"></param>
        /// <param name="oEditionID"></param>
        /// <returns></returns>
        protected string GetPrice(int iArticleID, object oPrice, object iProductID, object dtNoChargeExpiration, object oEditionID)
        {
            if (oPrice == DBNull.Value)
            {
                return string.Empty;
            }
            decimal dPrice = Convert.ToDecimal(oPrice);

            ServiceUnitPaymentInfo oPaymentInfo = new ServiceUnitPaymentInfo();
            GetServiceUnitPaymentInfo().Add(oPaymentInfo);
            oPaymentInfo.ObjectID = iArticleID;

            // If we don't have a product ID, then there's
            // no charge.
            if ((iProductID == DBNull.Value) ||
                (Convert.ToInt32(iProductID) == 0))
            {
                oPaymentInfo.Charge = false;
                oPaymentInfo.IncludeInRequest = true;
                return string.Empty;
            }

            // If we have a "No Charge" Expiration that is in the 
            // future, then there's no charge.
            if ((dtNoChargeExpiration != DBNull.Value) &&
                (Convert.ToDateTime(dtNoChargeExpiration) >= DateTime.Now))
            {
                oPaymentInfo.Charge = false;
                oPaymentInfo.IncludeInRequest = true;
                return "0";
            }

            // If this article was recently purchased, we won't charge
            // them for it again.
            if (_oUser.IsRecentPurchase(iArticleID, "BP"))
            {
                oPaymentInfo.Charge = false;
                oPaymentInfo.IncludeInRequest = false;
                return "Previously Ordered";
            }

            // If this is for the current edition, then there is
            // no charge.
            if ((oEditionID != DBNull.Value) &&
                (IsCurrentEdition(Convert.ToInt32(oEditionID))))
            {
                oPaymentInfo.Charge = false;
                oPaymentInfo.IncludeInRequest = true;
                return "0";
            }

            // If we made it here, then there must be 
            // a charge.
            _dTotalPrice += dPrice;
            oPaymentInfo.Charge = true;
            oPaymentInfo.IncludeInRequest = true;
            oPaymentInfo.Price = Convert.ToInt32(dPrice);
            oPaymentInfo.ProductID = Convert.ToInt32(iProductID);
            return dPrice.ToString("#0"); ;
        }

        string[] _aszArticleIDs = null;
        protected string IsArticleSelected(int iArticleID)
        {
            if (Session["ArticleIDs"] == null)
            {
                return string.Empty;
            }

            string szArticleID = iArticleID.ToString();
            if (_aszArticleIDs == null)
            {
                _aszArticleIDs = ((string)Session["ArticleIDs"]).Split(',');
            }

            foreach (string szID in _aszArticleIDs)
            {
                if (szArticleID == szID)
                {
                    return " checked ";
                }
            }

            return string.Empty;
        }

        /// <summary>
        /// Returns the thumbnail image associated with the publication article.
        /// If not set, then returns a default image.
        /// </summary>
        /// <param name="imageFile"></param>
        /// <param name="mediaType"></param>
        /// <returns></returns>
        protected string GetThumbnailImage(object imageFile, string mediaType)
        {

            if (imageFile == DBNull.Value || imageFile == null)
            {
                if (mediaType == "Video")
                {
                    //return UIUtils.GetImageURL("training_video.jpg");
                    return UIUtils.GetImageURL("Play_1_Button_sm.png");
                }
                else
                {
                    return UIUtils.GetImageURL("pdf_Thumbnail.jpg");
                }
            }

            return GetImageURL((string)imageFile);
        }

        /// <summary>
        /// Sets up the BluePrints Details sub-menu
        /// </summary>
        protected void SetBlueprintsSubmenu()
        {
            List<SubMenuItem> oMenuItems = new List<SubMenuItem>();

            oMenuItems.Add(new SubMenuItem(Resources.Global.BlueprintQuarterlyJournalTitle, PageConstants.BLUEPRINTS));
            oMenuItems.Add(new SubMenuItem(Resources.Global.LearningCenter, PageConstants.LEARNING_CENTER));
            oMenuItems.Add(new SubMenuItem(Resources.Global.BlueprintsArchive, PageConstants.BLUEPRINTS_ARCHIVE));
            //oMenuItems.Add(new SubMenuItem(Resources.Global.BlueprintsOnline, PageConstants.BLUEPRINTS_ARCHIVE));
            oMenuItems.Add(new SubMenuItem(Resources.Global.BlueprintsFlipbookArchive, PageConstants.BLUEPRINTS_FLIPBOOK_ARCHIVE));

            ((SubMenuBar)Master.FindControl("SubmenuBar")).LoadMenu(oMenuItems);
        }
    }
}
