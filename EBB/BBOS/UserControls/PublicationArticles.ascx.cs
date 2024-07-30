/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: PublicationArticles.ascx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web;
using TSI.Arch;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;
using System.Web.UI.HtmlControls;
using TSI.Utils;
using System.IO;
using PRCo.EBB.BusinessObjects;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// User control that displays a list of PRPublication articles
    /// </summary>
    public partial class PublicationArticles : UserControlBase
    {
        protected DataSet _dsArticles;
        protected bool _bDisplayReadMore = true;
        protected bool _bHideDate = false;
        protected bool _bDisplayReadIcon = false;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if (!Page.IsPostBack)
            {
            }
        }

        public DataSet dsArticles
        {
            get { return _dsArticles; }
            set
            {
                _dsArticles = value;

                repSearchResults.DataSource = _dsArticles.Tables[0].Rows;
                repSearchResults.DataBind();
            }
        }

        public bool DisplayReadMore
        {
            get { return _bDisplayReadMore; }
            set { _bDisplayReadMore = value; }
        }

        public bool DisplayReadIcon
        {
            get { return _bDisplayReadIcon; }
            set { _bDisplayReadIcon = value; }
        }

        /// <summary>
        /// Added for Defect 4528 - BBOS: remove date posted on the Blueprints articles. Only show Edition (like Produce Blueprints April 2018 Edition)
        /// </summary>
        public bool HideDate
        {
            get { return _bHideDate; }
            set { _bHideDate = value; }
        }

        public static string TRAINING_VIDEO_URL = "<a href=\"#\" class='explicitlink' onclick=\"openTrainingVideoWindow('{0}')\">{1}</a>";

        public static string GetArticleName(int iArticleID, string szPublicationCode, string szName, object mediaTypeCode)
        {
            if (Convert.ToString(mediaTypeCode) == "Video")
            {
                return string.Format(TRAINING_VIDEO_URL, iArticleID, szName);
            }

            return GetArticleName(iArticleID, szPublicationCode, szName);
        }

        public static string GetWordPressArticleName(string szName, int ArticleID, bool blnUrlOnly = false)
        {
            string strURL = string.Format(PageConstants.BLUEPRINTS_VIEW, ArticleID);
            if (blnUrlOnly)
                return strURL;
            else
                return UIUtils.GetHyperlink(strURL, szName, "explicitlink");
        }

        public string GetWordPressArticleName2(string szName, int ArticleID, bool blnUrlOnly = false)
        {
            //string strURL = string.Format(PageConstants.BLUEPRINTS_VIEW, ArticleID);
            string strURL = string.Format("{0}?p={1}", GetMarketingWebSite(), ArticleID);
            if (blnUrlOnly)
                return strURL;
            else
                return UIUtils.GetHyperlink(strURL, szName, "explicitlink", "target='_blank'");
        }

        private string GetMarketingWebSite()
        {
            string szMarketingWebSite;
            if (WebUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                szMarketingWebSite = Utilities.GetConfigValue("LumberWebSite");
            else
                szMarketingWebSite = Utilities.GetConfigValue("ProduceWebSite");

            return szMarketingWebSite;
        }

        public static string GetWordPressNewsArticleName(string szName, int ArticleID, bool blnUrlOnly = false)
        {
            string strURL = string.Format(PageConstants.NEWS_ARTICLE_VIEW, ArticleID);
            if (blnUrlOnly)
                return strURL;
            else
                return UIUtils.GetHyperlink(strURL, szName, "explicitlink");
        }

        public string GetWordPressNewsArticleName2(string szName, int ArticleID, bool blnUrlOnly = false)
        {
            //string strURL = string.Format(PageConstants.NEWS_ARTICLE_VIEW, ArticleID);
            string strURL = string.Format("{0}?p={1}", GetMarketingWebSite(), ArticleID);
            if (blnUrlOnly)
                return strURL;
            else
                return UIUtils.GetHyperlink(strURL, szName, "explicitlink", "target='_blank'");
        }
        public static string GetWordPressNewsArticleName(string szName, string guid, bool blnUrlOnly = false)
        {
            if (blnUrlOnly)
                return guid;
            else
                return UIUtils.GetHyperlink(guid, szName, "explicitlink", "target='_blank'");
        }

        /// <summary>
        /// Depending upon the publication code, hyperlink the article name to the associated
        /// file.
        /// </summary>
        /// <param name="iArticleID"></param>
        /// <param name="szPublicationCode"></param>
        /// <param name="szName"></param>
        /// <returns></returns>
        protected static string GetArticleName(int iArticleID, string szPublicationCode, string szName)
        {
            return PageConstants.Format(UIUtils.GetHyperlink(GetFileDownloadURL(iArticleID, szPublicationCode), szName, "explicitlink", "target=_blank"), iArticleID);
        }

        /// <summary>
        /// Hyperlink the publication name to the appropriate page.
        /// </summary>
        /// <param name="szPublicationCode"></param>
        /// <param name="szPublicationName"></param>
        /// <param name="oEditionID"></param>
        /// <returns></returns>
        public static string GetPublicationName(string szPublicationCode, string szPublicationName, object oEditionID)
        {
            string szURL = null;
            switch (szPublicationCode)
            {
                case "BBN":
                    szURL = PageConstants.NEWS;
                    break;
                case "BP":
                case "BPS":
                    return szPublicationName;

                case "BBR":
                    szURL = PageConstants.BLUEBOOK_REFERENCE;
                    break;
                case "BBS":
                    szURL = PageConstants.BLUEBOOK_SERVICES;
                    break;
                case "BPO":
                    szURL = PageConstants.BLUEPRINTS_ARCHIVE;
                    break;
                case "BPFB":
                    szURL = PageConstants.BLUEPRINTS_FLIPBOOK_ARCHIVE;
                    break;
                case "KYC":
                    szURL = PageConstants.KNOW_YOUR_COMMODITY;
                    break;
                default:
                    throw new ApplicationUnexpectedException("Invalid Publication Code Found: " + szPublicationCode);
            }

            return UIUtils.GetHyperlink(szURL, szPublicationName);
        }

        public static string GetPublicationName_WordPress(string strMETA, string szCategory)
        {
            //a:1:{i:0;a:1:{s:4:"date";s:9:"July 2017";}}
            //Call this to parse through the complicated wordpress meta tag for BlueprintEdition
            int posLastColon = strMETA.LastIndexOf(":");
            string strTemp = strMETA.Substring(posLastColon+2);
            int posLastQuotes = strTemp.LastIndexOf('"');
            string strMetaAfterLastColon = strTemp.Substring(0, posLastQuotes);
            string strResult = szCategory;
            if (szCategory == PRODUCE_BLUEPRINTS && strMetaAfterLastColon.Length > 0)
                strResult += string.Format(" {0} Edition", strMetaAfterLastColon);

            return strResult;
        }

        const string PRPBAR_PUBLISHDATE = "prpbar_PublishDate";
        const string PRPBAR_PublicationArticleID = "prpbar_PublicationArticleID";
        const string PRPBAR_PublicationCode = "prpbar_PublicationCode";
        const string PRPBAR_MediaTypeCode = "prpbar_MediaTypeCode";
        const string PRPBAR_PublicationEditionID = "prpbar_PublicationEditionID";
        const string PRPBAR_Name = "prpbar_Name";
        const string Publication = "Publication";
        const string Category = "Category";
        const string Categories = "Categories";
        const string USERREADCOUNT = "UserReadCount";
        const string META_VALUE = "meta_value";
        const string PRPBAR_Abstract = "prpbar_Abstract";
        const string PRPBAR_CoverArtFileName = "prpbar_CoverArtFileName";
        const string PRPBAR_FileName = "prpbar_FileName";
        const string GUID = "guid";

        public const string PUBLICATIONCODE_WPBA = "WPBA";
        public const string PUBLICATIONCODE_WPNEWS = "WPNEWS";
        public const string PUBLICATIONCODE_WPKYC= "WPKYC";
        public const string PRODUCE_BLUEPRINTS = "Produce Blueprints";

        protected void repSearchResults_ItemDataBound(object sender, System.Web.UI.WebControls.RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                DataRow drRow = (DataRow)e.Item.DataItem;
                Label lblArticleName = (Label)e.Item.FindControl("lblArticleName");

                //Process parameters since this can be called from different resultsets and some params may be absent
                object oguid = drRow.GetValue(GUID);
                string szGuid = String.Empty;
                if (oguid != null && oguid != DBNull.Value)
                    szGuid = (string)oguid;

                int prpbar_PublicationArticleID = 0;
                object oPublicationArticleID = drRow.GetValue(PRPBAR_PublicationArticleID);
                if (oPublicationArticleID != null && oPublicationArticleID != DBNull.Value)
                    prpbar_PublicationArticleID = Convert.ToInt32(oPublicationArticleID);

                string prpbar_PublicationCode = null;
                object oPublicationCode = drRow.GetValue(PRPBAR_PublicationCode);
                if (oPublicationCode != null && oPublicationCode != DBNull.Value)
                    prpbar_PublicationCode = (string)oPublicationCode;

                string prpbar_Name = null;
                object oName = drRow.GetValue(PRPBAR_Name);
                if (oName != null && oName != DBNull.Value)
                    prpbar_Name = (string)oName;

                string prpbar_MediaTypeCode = null;
                object oMediaTypeCode = drRow.GetValue(PRPBAR_MediaTypeCode);
                if (oMediaTypeCode != null && oMediaTypeCode != DBNull.Value)
                    prpbar_MediaTypeCode = (string)oMediaTypeCode;

                DateTime prpbar_PublishDate = DateTime.MinValue;
                object oPublishDate = drRow.GetValue(PRPBAR_PUBLISHDATE);
                if (oPublishDate != null && oPublishDate != DBNull.Value)
                    prpbar_PublishDate = (DateTime)oPublishDate;

                int prpbar_PublicationEditionID = 0;
                object oPublicationEditionID = drRow.GetValue(PRPBAR_PublicationEditionID);
                if (oPublicationEditionID != null && oPublicationEditionID != DBNull.Value)
                    prpbar_PublicationEditionID = (int)oPublicationEditionID;

                string prpbar_PublicationName = null;
                object oPublicationName = drRow.GetValue(Publication);
                if (oPublicationName != null && oPublicationName != DBNull.Value)
                    prpbar_PublicationName = (string)oPublicationName;

                int iUserReadCount  = 0;
                object oUserReadCount = drRow.GetValue(USERREADCOUNT);
                if (oUserReadCount != null && oUserReadCount != DBNull.Value)
                    iUserReadCount = (int)oUserReadCount;

                string szCategory = null;
                string szCategories = null;
                object oCategory = drRow.GetValue(Category);
                object oCategories = drRow.GetValue(Categories);
                
                if (oCategory != null && oCategory != DBNull.Value)
                    szCategory = (string)oCategory;

                if (oCategories != null && oCategories != DBNull.Value)
                    szCategories = (string)oCategories;

                //Set labels
                HyperLink aReadMore = (HyperLink)e.Item.FindControl("aReadMore");

                if (prpbar_PublicationCode != null && prpbar_PublicationCode == PUBLICATIONCODE_WPBA)
                {
                    //It came from the WordPress wp_posts table
                    if (szCategory == PRODUCE_BLUEPRINTS)
                    {
                        lblArticleName.Text = GetWordPressArticleName2(HttpUtility.HtmlDecode(prpbar_Name), prpbar_PublicationArticleID);
                        aReadMore.NavigateUrl = GetWordPressArticleName2(HttpUtility.HtmlDecode(prpbar_Name), prpbar_PublicationArticleID, blnUrlOnly: true);
                    }
                    else
                    {
                        lblArticleName.Text = GetWordPressNewsArticleName2(HttpUtility.HtmlDecode(prpbar_Name), prpbar_PublicationArticleID);
                        aReadMore.NavigateUrl = GetWordPressNewsArticleName2(HttpUtility.HtmlDecode(prpbar_Name), prpbar_PublicationArticleID, blnUrlOnly: true);
                    }
                }
                else if (prpbar_PublicationCode != null && prpbar_PublicationCode == PUBLICATIONCODE_WPNEWS)
                {
                    if (!string.IsNullOrEmpty(szCategory) && szCategory != PRODUCE_BLUEPRINTS)
                    {
                        prpbar_PublicationCode = PUBLICATIONCODE_WPNEWS;
                    }

                    if (prpbar_PublicationCode != null && prpbar_PublicationCode == PUBLICATIONCODE_WPBA)
                    {
                        //It came from the WordPress wp_posts table
                        lblArticleName.Text = GetWordPressArticleName(HttpUtility.HtmlDecode(prpbar_Name), prpbar_PublicationArticleID);
                        aReadMore.NavigateUrl = GetWordPressArticleName(HttpUtility.HtmlDecode(prpbar_Name), prpbar_PublicationArticleID, blnUrlOnly: true);
                    }
                    else if (prpbar_PublicationCode != null && prpbar_PublicationCode == PUBLICATIONCODE_WPNEWS)
                    {
                        //It came from the WordPress wp_posts table as a News article
                        lblArticleName.Text = GetWordPressNewsArticleName(HttpUtility.HtmlDecode(prpbar_Name), szGuid);
                        aReadMore.NavigateUrl = GetWordPressNewsArticleName(HttpUtility.HtmlDecode(prpbar_Name), szGuid, blnUrlOnly: true);
                    }
                }
                else
                {
                    lblArticleName.Text = GetArticleName(prpbar_PublicationArticleID, prpbar_PublicationCode, HttpUtility.HtmlDecode(prpbar_Name), prpbar_MediaTypeCode);
                    aReadMore.NavigateUrl = GetFileDownloadURL(prpbar_PublicationArticleID, prpbar_PublicationCode);
                }

                if (oPublishDate != null && oPublishDate != DBNull.Value)
                {
                    Label lblPublishDate = (Label)e.Item.FindControl("lblPublishDate");
                    DateTime dtPublishDate = prpbar_PublishDate;

                    if (!HideDate)
                    {
                        //format date like July 31st, 2017
                        lblPublishDate.Text = string.Format("{0:MMMM} {1}{2}, {0:yyyy}", dtPublishDate, dtPublishDate.Day,
                            (
                                (dtPublishDate.Day % 10 == 1 && dtPublishDate.Day != 11) ? "st"
                                : (dtPublishDate.Day % 10 == 2 && dtPublishDate.Day != 12) ? "nd"
                                : (dtPublishDate.Day % 10 == 3 && dtPublishDate.Day != 13) ? "rd"
                                : "th"
                            )
                        );
                    }
                }
                else
                {
                    HtmlGenericControl rowPublishDate = (HtmlGenericControl)e.Item.FindControl("rowPublishDate");
                    rowPublishDate.Visible = false;
                }

                Label lblPublicationName = (Label)e.Item.FindControl("lblPublicationName");

                string szPublicationName = "";

                if (prpbar_PublicationCode != null && prpbar_PublicationCode == PUBLICATIONCODE_WPBA)
                {
                    if(string.IsNullOrEmpty(szCategories))
                        szPublicationName = GetPublicationName_WordPress((string)oPublicationName, szCategory);
                    else
                        szPublicationName = szCategories; // Defect 4666 includes all categories
                }
                else if (oPublicationEditionID != null && oPublicationEditionID != DBNull.Value)
                {
                    szPublicationName = GetPublicationName(prpbar_PublicationCode, prpbar_PublicationName, prpbar_PublicationEditionID);
                }
                else if(szCategory != null && szCategory.Length > 0)
                {
                    szPublicationName = szCategory;
                }

                if(string.IsNullOrEmpty(szPublicationName))
                    lblPublicationName.Text = szCategory;
                else
                    lblPublicationName.Text = " - " + szPublicationName;


                string strPublicationAbstract = HttpUtility.HtmlDecode(UIUtils.GetString(drRow[PRPBAR_Abstract]));
                
                if (strPublicationAbstract.Length > Configuration.PublicationArticleMaxLen)
                {
                    strPublicationAbstract = strPublicationAbstract.Substring(0, Configuration.PublicationArticleMaxLen) + "...";
                }

                //It is possible that closing HTML tags are missing since the abstract
                //string might have been truncated at the first CRLF or 1st paragraph
                //Make sure all HTML tags are closed so that display formatting issues
                //don't occur
                HtmlAgilityPack.HtmlDocument doc = new HtmlAgilityPack.HtmlDocument();
                doc.LoadHtml(strPublicationAbstract);
                doc.OptionAutoCloseOnEnd = true; //close all tags
                //doc.OptionFixNestedTags = true;
                strPublicationAbstract = doc.DocumentNode.OuterHtml; //to grab any auto-closed tags and prevent subsequent rendering format issues

                Label lblAbstract = (Label)e.Item.FindControl("lblAbstract");
                lblAbstract.Text = strPublicationAbstract;

                //Handle flipbook specific stuff
                if (prpbar_PublicationCode == "BPFB")
                {
                    HyperLink hlCover = (HyperLink)e.Item.FindControl("hlCover");
                    HtmlGenericControl hrDivider = (HtmlGenericControl)e.Item.FindControl("hrDivider");

                    aReadMore.Visible = false;

                    hlCover.Visible = true;
                    string szFileRoot = Utilities.GetConfigValue("LearningCenterVirtualFolder");
                    hlCover.ImageUrl = Path.Combine("~", szFileRoot, (string)drRow[PRPBAR_CoverArtFileName]);
                    hlCover.NavigateUrl = Path.Combine("~", GetFileDownloadURL(prpbar_PublicationArticleID, prpbar_PublicationCode));
                    hrDivider.Visible = false;
                }

                //Read indicator (if provided)
                if (DisplayReadIcon)
                {
                    Image imgRead = (Image)e.Item.FindControl("imgRead");
                    imgRead.Visible = true;

                    if (iUserReadCount > 0)
                    {
                        imgRead.ImageUrl = UIUtils.GetImageURL("read.png");
                        imgRead.AlternateText = Resources.Global.Read;
                        imgRead.ToolTip = Resources.Global.Read;
                    }
                    else
                    {
                        imgRead.ImageUrl = UIUtils.GetImageURL("unread.png");
                        imgRead.AlternateText = Resources.Global.Unread;
                        imgRead.ToolTip = Resources.Global.Unread;
                    }
                }
            }
        }
    }
}