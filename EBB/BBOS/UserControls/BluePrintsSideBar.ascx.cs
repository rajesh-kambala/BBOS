/***********************************************************************
 Copyright Blue Book Services, Inc. 2023-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: BluePrintsSideBar.ascx.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/

using System;
using System.Data;
using System.Web.UI.WebControls;

namespace PRCo.BBOS.UI.Web.UserControls
{
    public partial class BluePrintsSideBar : System.Web.UI.UserControl
    {
        protected DataSet _oData;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
            }
        }

        protected void PopulateForm()
        {
            DataRow dr = _oData.Tables[0].Rows[0];

            int prpbed_PublicationEditionID = Convert.ToInt32(dr["prpbed_PublicationEditionID"]);
            string prpbed_Name = (string)dr["prpbed_Name"];
            string prpbed_CoverArtFileName = (string)dr["prpbed_CoverArtFileName"];
            string prpbed_CoverArtThumbFileName = UIUtils.GetString(dr["prpbed_CoverArtThumbFileName"]);
            DateTime prpbed_PublishDate = Convert.ToDateTime(dr["prpbed_PublishDate"]);
            int prpbar_PublicationArticleID = Convert.ToInt32(dr["prpbar_PublicationArticleID"]);

            hlFlipBookCover.ToolTip = string.Format("{0} {1}", prpbed_Name, Resources.Global.Edition);
            hlFlipBookTitle.ToolTip = hlFlipBookCover.ToolTip;

            if (!string.IsNullOrEmpty(prpbed_CoverArtThumbFileName))
            {
                imgFlipBookCover.ImageUrl = PublishingBase.GetImageURL(prpbed_CoverArtFileName);
            }

            if (!PublishingBase.SetFlipBookLink(prpbed_PublicationEditionID, hlFlipBookCover, hlFlipBookTitle, imgFlipBookCover))
            {
                tdFlipBook1.Visible = false;
                tdFlipBook2.Visible = false;
            }

            PublishingBase.SetFlipBookSupplements(prpbed_PublicationEditionID, repFlipBookSupplements, null);

            hlFlipBookTitle.ToolTip = lblFlipBookTitle.Text;
            
            hlAdvertise.NavigateUrl = "~/" + Configuration.AdvertiserMediaKitURL;
            hlBluePrintsFlipbookArchive.NavigateUrl = "~/" + PageConstants.BLUEPRINTS_FLIPBOOK_ARCHIVE;
        }

        public DataSet Data
        {
            set
            {
                _oData = value;
                PopulateForm();
            }
        }

        protected void repFlipBookSupplements_ItemDataBound(object sender, System.Web.UI.WebControls.RepeaterItemEventArgs e)
        {
            HyperLink hlFlipBookCover = (HyperLink)e.Item.FindControl("hlFlipBookCover");
            HyperLink hlFPButton = (HyperLink)e.Item.FindControl("hlFPButton");
            Image imgFlipBookCover = (Image)e.Item.FindControl("imgFlipBookCover");

            DataRowView drv = (DataRowView)e.Item.DataItem;

            int prpbar_PublicationEditionID = Convert.ToInt32(drv["prpbar_PublicationEditionID"]);
            int prpbar_PublicationArticleID = Convert.ToInt32(drv["prpbar_PublicationArticleID"]);
            string prpbar_Name = (string)drv["prpbar_Name"];
            object prpbar_CoverArtFileName = drv["prpbar_CoverArtFileName"];

            hlFlipBookCover.ToolTip = string.Format("{0} {1}", prpbar_Name, Resources.Global.Edition);
            hlFlipBookTitle.ToolTip = hlFlipBookCover.ToolTip;

            if (prpbar_CoverArtFileName != null && prpbar_CoverArtFileName != System.DBNull.Value)
            {
                imgFlipBookCover.ImageUrl = PublishingBase.GetImageURL(prpbar_CoverArtFileName);
            }
            else
            {
                hlFlipBookCover.Visible = false;
                imgFlipBookCover.Visible = false;
            }

            hlFlipBookCover.NavigateUrl = "~/" + PageControlBaseCommon.GetFileDownloadURL(prpbar_PublicationArticleID, prpbar_PublicationEditionID, "PRPublicationEdition");
            hlFPButton.NavigateUrl = hlFlipBookCover.NavigateUrl;
        }
    }
}