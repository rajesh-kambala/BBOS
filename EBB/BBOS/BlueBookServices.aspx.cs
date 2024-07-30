/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2022

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: BlueBookServices.aspx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Data;
using PRCo.EBB.BusinessObjects;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This page displays all Publication Articles with a code
    /// of "BBS".  They are ordered by the sequence.
    /// </summary>
    public partial class BlueBookServices : PublishingBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            SetPageTitle(Resources.Global.BlueBookServices);

            Advertisement.Logger = _oLogger;
            Advertisement.WebUser = _oUser;
            Advertisement.LoadAds();

            if (!IsPostBack)
            {
                PopulateForm();
            }
        }

        protected const string SQL_SELECT_BLUEBOOKSERVICES_DISTINCT_CATEGORY_CULTURE =
                @"SELECT DISTINCT(CAST(ISNULL({2}, capt_US) as varchar(100))) as Category, Capt_Order
                    FROM PRPublicationArticle WITH (NOLOCK) 
                         LEFT OUTER JOIN Custom_Captions WITH (NOLOCK) ON prpbar_CategoryCode = capt_code AND Capt_Family = 'prpbar_CategoryCodeBBS'
                   WHERE prpbar_PublicationCode = 'BBS' 
                     AND prpbar_IndustryTypeCode LIKE '{0}' 
                     AND prpbar_CommunicationLanguage = '{1}'
                ORDER BY Capt_Order";

        protected const string SQL_SELECT_BLUEBOOKSERVICES_BY_CATEGORY_LANGUAGE =
                @"SELECT prpbar_Name, 
                    prpbar_Abstract, 
                    COALESCE(prpbar_FileName, '') As prpbar_FileName, 
                    COALESCE(prpbar_Level, 1) As prpbar_Level, 
                    prpbar_PublicationArticleID, 
                    CAST({3} as varchar(100)) as Category  
                FROM PRPublicationArticle WITH (NOLOCK) 
                    LEFT OUTER JOIN Custom_Captions WITH (NOLOCK) ON prpbar_CategoryCode = capt_code AND Capt_Family = 'prpbar_CategoryCodeBBS'
                WHERE prpbar_PublicationCode = 'BBS' 
                     AND prpbar_IndustryTypeCode LIKE '{0}' 
                     AND prpbar_CommunicationLanguage = '{1}'
                     AND CAST({3} as varchar(100)) = '{2}'
                ORDER BY Capt_Order, prpbar_Sequence";

        /// <summary>
        /// Populates the forms with the reference material found in
        /// the PRPublicationArticle table.
        /// </summary>
        protected void PopulateForm()
        {
            string szColName;
            if (_oUser.prwu_Culture == SPANISH_CULTURE)
                szColName = "capt_es";
            else
                szColName = "capt_us";

            string szSQL = string.Format(SQL_SELECT_BLUEBOOKSERVICES_DISTINCT_CATEGORY_CULTURE, "%," + _oUser.prwu_IndustryType + ",%", "E", szColName);

            DataSet dsEnglish = GetDBAccess().ExecuteSelect(szSQL);
            repReferencesE.DataSource = dsEnglish;
            repReferencesE.DataBind();
            repReferencesE.EnableViewState = false;

            szSQL = string.Format(SQL_SELECT_BLUEBOOKSERVICES_DISTINCT_CATEGORY_CULTURE, "%," + _oUser.prwu_IndustryType + ",%", "S", szColName);

            DataSet dsSpanish = GetDBAccess().ExecuteSelect(szSQL);
            repReferencesS.DataSource = dsSpanish;
            repReferencesS.DataBind();
            repReferencesS.EnableViewState = false;

            if (repReferencesS.Items.Count == 0 || _oUser.prwu_Culture == ENGLISH_CULTURE)
            {
                fsSpanish.Visible = false;
                aSpanish.Visible = false;
                pnlSubmenu.Visible = false;
            }

            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                LearningCenter.Visible = false;
            }
        }

        string _saveCategory = string.Empty;
        protected string GetCategory(object category)
        {
            if ((category == null) ||
                (category == DBNull.Value))
            {
                return string.Empty;
            }

            if (_saveCategory == category.ToString())
            {
                return string.Empty;
            }

            _saveCategory = category.ToString();
            return "<p>" + _saveCategory + "</p>";
        }

        protected override bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.MembershipGuidePage).HasPrivilege;
        }

        protected void repReferencesE_ItemDataBound(object sender, System.Web.UI.WebControls.RepeaterItemEventArgs e)
        {
            if(e.Item.ItemType == System.Web.UI.WebControls.ListItemType.Item || e.Item.ItemType == System.Web.UI.WebControls.ListItemType.AlternatingItem)
            {
                BindBBServices(e, "E");
            }
        }

        protected void repReferencesS_ItemDataBound(object sender, System.Web.UI.WebControls.RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == System.Web.UI.WebControls.ListItemType.Item || e.Item.ItemType == System.Web.UI.WebControls.ListItemType.AlternatingItem)
            {
                BindBBServices(e, "S");
            }
        }

        private void BindBBServices(System.Web.UI.WebControls.RepeaterItemEventArgs e, string strLanguage)
        {
            PublicationArticles ucPublicationArticles = (PublicationArticles)e.Item.FindControl("ucPublicationArticles");
            DataRowView drv = (DataRowView)e.Item.DataItem;

            ucPublicationArticles.Logger = _oLogger;
            ucPublicationArticles.WebUser = _oUser;

            string szCapt = "capt_us";
            if(_oUser.prwu_Culture=="es-mx")
                szCapt = "capt_es";

            string szSQL = string.Format(SQL_SELECT_BLUEBOOKSERVICES_BY_CATEGORY_LANGUAGE, "%," + _oUser.prwu_IndustryType + ",%", strLanguage, drv["Category"], szCapt);

            DataSet dsFilteredArticles = GetDBAccess().ExecuteSelect(szSQL);
            ucPublicationArticles.DisplayReadMore = false; //Kathi #223 don't display Read More link on this page
            ucPublicationArticles.dsArticles = dsFilteredArticles;
        }
    }
}
