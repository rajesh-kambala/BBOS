/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2018-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: WordPressArticle.ascx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Data;
using System.IO;
using System.Text;
using System.Web.UI;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// User control that displays a wordpress article
    /// </summary>
    public partial class WordPressArticle : UserControlBase
    {
        protected string _szArticleID;
        protected string _szBaseUrl;
        protected int _iPageNum;
        protected bool _bShowDate = true;
        protected string _szDatePrefix;
        protected bool _bShowBackToKYCButton = false;
        protected bool _bIsKYC = false;
        protected ArticleEnum _eArticleType = ArticleEnum.KYC;

        public enum ArticleEnum
        {
            BluePrint,
            KYC,
            News
        }

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if (!Page.IsPostBack)
            {
                PopulateForm();
            }

            btnPrint.OnClientClick = "target='blank'";
        }

        public string ArticleID
        {
            get { return _szArticleID; }
            set { _szArticleID = value; }
        }

        public string BaseUrl
        {
            get { return _szBaseUrl; }
            set { _szBaseUrl = value; }
        }

        public int PageNum
        {
            get { return _iPageNum; }
            set { _iPageNum = value; }
        }

        public bool ShowDate
        {
            get { return _bShowDate; }
            set { _bShowDate = value; }
        }

        public string DatePrefix
        {
            get { return _szDatePrefix; }
            set { _szDatePrefix = value; }
        }

        public bool ShowBackToKYCButton
        {
            get { return _bShowBackToKYCButton; }
            set
            {
                _bShowBackToKYCButton = value;
                btnBackToKYC.Visible = value;
            }
        }

        public bool IsKYC
        {
            get { return _bIsKYC; }
            set { _bIsKYC = value; }
        }

        public ArticleEnum ArticleType
        {
            get { return _eArticleType; }
            set { _eArticleType = value; }
        }

        private void PopulateForm(bool bPrint = false)
        {
            if (ArticleID == null)
                return;

            string szSQL;

            if(WebUser.prwu_IndustryType == "L")
                szSQL = string.Format(PublishingBase.SQL_SELECT_WORDPRESS_BP_ARTICLE, ArticleID, WebUser.prwu_IndustryType, Configuration.WordPressLumber_posts, Configuration.WordPressLumber_postmeta);
            else
                szSQL = string.Format(PublishingBase.SQL_SELECT_WORDPRESS_BP_ARTICLE, ArticleID, WebUser.prwu_IndustryType, Configuration.WordPressProduce_posts, Configuration.WordPressProduce_postmeta);

            DataSet dsArticle = GetDBAccess().ExecuteSelect(szSQL);

            if (dsArticle.Tables[0].Rows.Count == 0)
            {
                litTitle.Text = string.Format(Resources.Global.ArticleNoLongerAvailable, _szArticleID);
                pnlAll.Visible = false; //hide other items that aren't pertinent when article missing
                return;
            }

            DateTime post_date = dsArticle.Tables[0].Rows[0].Field<DateTime>("post_date");

            string post_content_full = dsArticle.Tables[0].Rows[0].Field<string>("post_content");
            
            //Convert CRLF to <p> tags
            //Insert a <p> at position 0.  Append a </p> at the end of the file.  Then replace all CRLF with </p><p>.
            post_content_full = string.Format("<p>{0}</p>", post_content_full).Replace("\r\n", "</p><p>");

            //Injections - do iFrame last because it could contain other elements inside it
            InjectKYCAdvertising(ref post_content_full);
            InjectCaptions(ref post_content_full);
            InjectWPImages(ref post_content_full);

            InjectIFrameTags(ref post_content_full); //DO IFrame last because it could contain other injection elements

            string post_content_page;

            string[] pages = post_content_full.Split(new string[] { "<!--nextpage-->" }, StringSplitOptions.None);
            int totalPages = pages.Length;

            if (totalPages > 1)
            {
                if (PageNum == 0 || PageNum>totalPages)
                    PageNum = 1;

                // This holds the page content to display.
                post_content_page = pages[PageNum - 1];

                // Build our pagination controls.
                lblTotalPages.Text = string.Format("Page {0} of {1}", PageNum, totalPages);

                if (PageNum > 1)
                {
                    //hlPrev.Text = (pageIndex - 1).ToString();
                    hlPrev.NavigateUrl = string.Format("{0}?ArticleID={1}&p={2}", BaseUrl, _szArticleID, PageNum - 1);
                }
                else
                    hlPrev.Visible = false;

                string szPages = string.Empty;
                for (int i = 1; i <= totalPages; i++)
                {
                    if (i == PageNum)
                    {
                        szPages += string.Format("<span class='current'>{0}</span>", i);
                    }
                    else
                    {
                        szPages += string.Format("<a href='{0}?ArticleID={1}&p={2}' title='Page {2}' class='page smaller'>{2}</a>", BaseUrl, _szArticleID, i);
                    }
                }
                lblPages.Text = szPages;

                if (PageNum < totalPages)
                {
                    //hlNext.Text = (PageNum + 1).ToString();
                    hlNext.NavigateUrl = string.Format("{0}?ArticleID={1}&p={2}", BaseUrl, _szArticleID, PageNum + 1);
                }
                else
                    hlNext.Visible = false;
            }
            else
            {
                PageNum = 1;
                post_content_page = post_content_full;
                divPagination.Attributes.Add("class", "hidden");
            }

            string post_title = dsArticle.Tables[0].Rows[0].Field<string>("post_title");
            string standfirst = dsArticle.Tables[0].Rows[0].Field<string>("Standfirst");
            string author = dsArticle.Tables[0].Rows[0].Field<string>("Author");
            string authorAbout = dsArticle.Tables[0].Rows[0].Field<string>("AuthorAbout");

            string thumbnailImg = null;



            if (dsArticle.Tables[0].Rows[0].Field<string>("ThumbnailImg") != null)
            {
                if (WebUser.prwu_IndustryType == "L")
                    thumbnailImg = Path.Combine(Utilities.GetConfigValue("LumberUploadsFolder", "https://www.lumberbluebook.com/wp-content/uploads/"), dsArticle.Tables[0].Rows[0].Field<string>("ThumbnailImg"));
                else
                    thumbnailImg = Path.Combine(Utilities.GetConfigValue("ProduceUploadsFolder", "https://www.producebluebook.com/wp-content/uploads/"), dsArticle.Tables[0].Rows[0].Field<string>("ThumbnailImg"));
            }

                                          
            string BlueprintEdition = dsArticle.Tables[0].Rows[0].Field<string>("BlueprintEdition");
            //string Category = dsArticle.Tables[0].Rows[0].Field<string>("Category");
            string Categories = dsArticle.Tables[0].Rows[0].Field<string>("Categories"); //Defect 4666 list all categories plus blueprintsedition

            //Populate screen
            litTitle.Text = post_title;
            litSubTitle.Text = standfirst;

            if (ShowDate)
            {
                switch (ArticleType)
                {
                    case ArticleEnum.KYC:
                        litDatePrefix.Text = DatePrefix;
                        if(post_date != null)
                            litDate.Text = post_date.ToShortDateString();
                        break;

                    case ArticleEnum.BluePrint:
                        //format date like July 2017 Edition
                        litDate.Text = Categories; //PublicationArticles.GetPublicationName_WordPress(BlueprintEdition, Category);
                        break;

                    case ArticleEnum.News:
                        if (post_date != null)
                        {
                            litDate.Text = string.Format("{0:MMMM} {1}{2}, {0:yyyy}", post_date, post_date.Day,
                                                     (
                                                         (post_date.Day % 10 == 1 && post_date.Day != 11) ? "st"
                                                         : (post_date.Day % 10 == 2 && post_date.Day != 12) ? "nd"
                                                         : (post_date.Day % 10 == 3 && post_date.Day != 13) ? "rd"
                                                         : "th"
                                                     ));
                        }
                        break;
                }
            }
            else
                pnlDate.Visible = false;

            if (bPrint)
                divContentAll.InnerHtml = post_content_full;
            else
                divContent.InnerHtml = post_content_page;

            if (authorAbout == null || PageNum < totalPages)
                divAuthorAbout.Attributes.Add("class", divAuthorAbout.Attributes["class"] + " hidden");
            else
                divAuthorAbout.Attributes.Add("class", divAuthorAbout.Attributes["class"].Replace("hidden", ""));

            litAuthorAbout.Text = authorAbout;

            if (thumbnailImg == null)
                divThumbnail.Visible = false;
            else
                imgThumbnail.ImageUrl = thumbnailImg;

            if(ArticleType == ArticleEnum.BluePrint)
            {
                //Enable social media buttons
                //link them to the ProduceBlueprints url since this is public whereas BBOS is private
                spanSocialMediaButtons.Visible = true;

                string szUrl = string.Format("https://www.producebluebook.com/{0}/{1}/{2}/{3}/",post_date.Year,post_date.Month,post_date.Day,post_title.Replace(" ","-"));
                addtoany_header.Attributes.Add("data-a2a-url", szUrl); //ex: https://www.producebluebook.com/2018/12/14/apple-grower-shipper-work-through-growing-challenges/ 
                addtoany_header.Attributes.Add("data-a2a-title", post_title); //ex: Apple grower-shipper work through growing challenges

                //Facebook
                //ex: https://www.addtoany.com/add_to/facebook?linkurl=https%3A%2F%2Fwww.producebluebook.com%2F2018%2F12%2F14%2Fapple-grower-shipper-work-through-growing-challenges%2F&amp;linkname=Apple%20grower-shipper%20work%20through%20growing%20challenges&amp;linknote=
                string szHrefFacebook = string.Format("https://www.addtoany.com/add_to/facebook?linkurl={0}&linkname={1}&linknote=",
                    Uri.EscapeDataString(szUrl),
                    Uri.EscapeDataString(post_title));
                facebook.Attributes.Add("href", szHrefFacebook);

                //Twitter
                //ex: https://www.addtoany.com/add_to/twitter?linkurl=https%3A%2F%2Fwww.producebluebook.com%2F2018%2F11%2F30%2Fchallenges-await-los-angeles-ports%2F&amp;linkname=Challenges%20await%20Los%20Angeles%20ports&amp;linknote=
                string szHrefTwitter = string.Format("https://www.addtoany.com/add_to/twitter?linkurl={0}&linkname={1}&linknote=",
                    Uri.EscapeDataString(szUrl),
                    Uri.EscapeDataString(post_title));
                twitter.Attributes.Add("href", szHrefTwitter);

                //Email
                //ex: https://www.addtoany.com/add_to/google_plus?linkurl=http%3A%2F%2Fazqa.produce.bluebookservices.com%2F2018%2F12%2F14%2Fapple-grower-shipper-work-through-growing-challenges%2F&amp;linkname=Apple%20grower-shipper%20work%20through%20growing%20challenges&amp;linknote=
                string szHrefEmail = string.Format("https://www.addtoany.com/add_to/email?linkurl={0}&linkname={1}&linknote=",
                    Uri.EscapeDataString(szUrl),
                    Uri.EscapeDataString(post_title));
                email.Attributes.Add("href", szHrefEmail); 

                //Add to any
                //ex: https://www.addtoany.com/share#url=http%3A%2F%2Fazqa.produce.bluebookservices.com%2F2018%2F12%2F14%2Fapple-grower-shipper-work-through-growing-challenges%2F&amp;title=Apple%20grower-shipper%20work%20through%20growing%20challenges
                string szHrefAddToAny = string.Format("https://www.addtoany.com/share#url={0}&title={1}",
                    Uri.EscapeDataString(szUrl),
                    Uri.EscapeDataString(post_title));
                addtoany.Attributes.Add("href", szHrefAddToAny);
            }
        }

        protected const string SQL_KYC_ADVERTISING =
        @"select meta_key, meta_value
                    FROM {0} 
                    WHERE post_id={1}
                        AND meta_key LIKE 'KYCAD%'";

        private void InjectKYCAdvertising(ref string szContent)
        {
            if (!IsKYC)
                return;

            string szSQL = string.Format(SQL_KYC_ADVERTISING, Configuration.WordPressProduce_postmeta, ArticleID);

            using (IDataReader drKYCAd = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection))
            {
                while (drKYCAd.Read())
                {
                    string szMetaKey = (string)drKYCAd["meta_key"];
                    string szFormattedMetaKey = string.Format("{{{{{0}}}}}", szMetaKey);
                    string szMetaValue = (string)drKYCAd["meta_value"];

                    szContent = szContent.Replace(szFormattedMetaKey, szMetaValue);
                }
            }

            //Remove any excess {{KYCADx}} entries if there wasn't an ad for them
            for(int i=1; i<10; i++)
            {
                string szFormattedMetaKey = string.Format("{{{{KYCAD{0}}}}}", i);
                szContent = szContent.Replace(szFormattedMetaKey, "");
            }
        }

        private void InjectIFrameTags(ref string szContent)
        {
            //Ex: [iframe src="https://datawrapper.dwcdn.net/8uvoy/2/" width="600" height="450"]
            //Be sure to do this last after all other injections since it can contain others and mess up the [ and ] calculations
            const string IFRAME_START = "[iframe ";
            const string IFRAME_END = "]";

            StringBuilder sbContent = new StringBuilder(szContent);

            int iTagStartPos = sbContent.ToString().IndexOf(IFRAME_START);

            while (iTagStartPos >= 0)
            {
                int iTagEndPos = sbContent.ToString().IndexOf(IFRAME_END);
                sbContent[iTagStartPos] = '<';

                sbContent.Remove(iTagEndPos, 1);
                sbContent.Insert(iTagEndPos, "></iframe>");

                iTagStartPos = sbContent.ToString().IndexOf(IFRAME_START);
            }

            szContent = sbContent.ToString();
        }

        private void InjectCaptions(ref string szContent)
        {
            //Ex: [caption id="attachment_4735" align="aligncenter" width="300"]  xyz [/caption]
            //
            //becomes......
            //
            //<figure id="attachment_4735" style="max-width: 300px" class="wp-caption aligncenter">
	          //<img class="wp-image-4735 size-medium" src="https://www.producebluebook.com/wp-content/uploads/2018/11/UFFactsOnRetail-300x197.png" alt="" width="300" height="197" srcset="https://www.producebluebook.com/wp-content/uploads/2018/11/UFFactsOnRetail-300x197.png 300w, https://www.producebluebook.com/wp-content/uploads/2018/11/UFFactsOnRetail.png 500w" sizes="(max-width: 300px) 100vw, 300px">
	          //<figcaption class="wp-caption-text">United Fresh members can download a complimentary copy of the report.The non-member price is $50.</figcaption>
            //</figure>
            const string CAPTION_START = "[caption ";
            const string CAPTION_END = "[/caption]";

            int iOpeningTagStartPos = szContent.IndexOf(CAPTION_START);
            int iClosingTagStartPos = szContent.IndexOf(CAPTION_END);

            if (iOpeningTagStartPos == -1 || iClosingTagStartPos == -1)
                return;

            while (iOpeningTagStartPos > -1)
            {
                int iOpeningTagLen = szContent.Substring(iOpeningTagStartPos).IndexOf("]") + 1; //the closing brace on opening tag
                string szOpeningTag = szContent.Substring(iOpeningTagStartPos, iOpeningTagLen);

                int iClosingTagLen = CAPTION_END.Length;
                string szClosingTag = szContent.Substring(iClosingTagStartPos, iClosingTagLen);

                string strMiddleHTML = szContent.Substring(iOpeningTagStartPos + iOpeningTagLen, (iClosingTagStartPos - (iOpeningTagStartPos + iOpeningTagLen)));

                string[] arrNameValuePairs = szOpeningTag.Split(' ');

                string szOpeningTagAlign = "aligncenter"; //default
                string szOpeningTagWidth = "300"; //default

                foreach (string nv in arrNameValuePairs)
                {
                    string nvMin = nv.Replace("]", "").Replace("[", "");
                    string[] arrParam = nvMin.Split('='); //
                    if (arrParam.Length > 1)
                    {
                        arrParam[1] = arrParam[1].Replace("\"", ""); //remove quotes
                        switch (arrParam[0])
                        {
                            case "align":
                                szOpeningTagAlign = arrParam[1];
                                break;
                            case "width":
                                szOpeningTagWidth = arrParam[1];
                                break;
                        }
                    }
                }

                string szContentNew = szContent.Substring(0, iOpeningTagStartPos);
                szContentNew += string.Format("<figure style='max-width: {0}px' class='wp-caption {1}'>", szOpeningTagWidth, szOpeningTagAlign);
                szContentNew += strMiddleHTML;
                szContentNew += "</figure>";

                szContentNew += szContent.Substring(iClosingTagStartPos + iClosingTagLen);

                szContent = szContentNew;

                iOpeningTagStartPos = szContent.IndexOf(CAPTION_START);
                iClosingTagStartPos = szContent.IndexOf(CAPTION_END);
            }
        }

        private void InjectWPImages(ref string szContent)
        {
            //Convert images that have this starting src="/wp-content/uploads/" with
            //src = "https://www.producebluebook.com/wp-content/uploads/whatever
            if (WebUser.prwu_IndustryType == "L")
                szContent = szContent.Replace("src=\"/wp-content/uploads/", string.Format("src=\"{0}", Utilities.GetConfigValue("LumberUploadsFolder",  "https://www.lumberbluebook.com/wp-content/uploads/")));
            else
                szContent = szContent.Replace("src=\"/wp-content/uploads/", string.Format("src=\"{0}", Utilities.GetConfigValue("ProduceUploadsFolder", "https://www.producebluebook.com/wp-content/uploads/")));
        }

        protected void btnPrint_Click(object sender, ImageClickEventArgs e)
        {
            PopulateForm(bPrint:true);
            string szScript = "setTimeout(function() { printdiv(); }, 1000);"; //without delay the print window is a garbled mess
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "printx", string.Format("<script>{0}</script>", szScript), false);
        }
    }
}