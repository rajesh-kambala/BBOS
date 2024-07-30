/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2012-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: NewHireAcadmey.aspx.cs
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
    public partial class NewHireAcademy : PublishingBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
            SetPageTitle(Resources.Global.NewHireAcademy);

            if (!IsPostBack)
            {
            }

            PopulateForm();
        }

        protected const string SQL_SELECT_ARTICLES =
            @"SELECT prpbar_PublicationArticleID, prpbar_Name, prpbar_Abstract, prpbar_FileName, prpbar_CoverArtFileName, prpbar_CoverArtThumbFileName, prpbar_Length, prpbar_Sequence, LastReadDate, prpbar_PublicationCode
                FROM PRPublicationArticle WITH (NOLOCK)
                     LEFT OUTER JOIN  (SELECT prpar_PublicationArticleID, prpar_PublicationCode, MAX(prpar_CreatedDate) As LastReadDate
                                         FROM PRPublicationArticleRead WITH (NOLOCK) 
                                        WHERE prpar_WebUserID = {1} 
                                     GROUP BY prpar_PublicationArticleID, prpar_PublicationCode) T1 ON prpar_PublicationArticleID = prpbar_PublicationArticleID 
                                        AND prpar_PublicationCode = prpbar_PublicationCode
               WHERE prpbar_PublicationCode = 'NHA' 
                 AND prpbar_PublishDate < GETDATE()
                 AND prpbar_IndustryTypeCode LIKE '%,{0},%'
            ORDER BY prpbar_Sequence";

        protected const string SQL_SELECT_ARTICLES_READ =
            @"SELECT DISTINCT prpbar_PublicationArticleID
                FROM PRPublicationArticle WITH (NOLOCK)
                    INNER JOIN PRPublicationArticleRead WITH (NOLOCK) ON prpbar_PublicationArticleID = prpar_PublicationArticleID AND prpar_PublicationCode = prpbar_PublicationCode
                WHERE prpar_WebUserID = {1}
                AND prpbar_PublicationCode = 'NHA' 
                AND prpbar_PublishDate < GETDATE()
                AND prpbar_IndustryTypeCode LIKE '%,{0},%'";

        protected const string SQL_SELECT_LAST_QUIZ_DATE =
            @"SELECT MAX(prsr_CreatedDate) As LastQuizDate
                FROM PRSurveyResponse WITH (NOLOCK)
               WHERE prsr_WebUserID = {0}
                 AND prsr_SurveyCode = 'NHA'";

        /// <summary>
        /// Populates the forms with the reference material found in
        /// the PRPublicationArticle table.
        /// </summary>
        protected void PopulateForm()
        {
            repTrainingSessions.DataSource = GetDBAccess().ExecuteReader(string.Format(SQL_SELECT_ARTICLES, _oUser.prwu_IndustryType, _oUser.prwu_WebUserID), CommandBehavior.CloseConnection);
            repTrainingSessions.DataBind();
            repTrainingSessions.EnableViewState = false;

            object result = GetDBAccess().ExecuteScalar(string.Format(SQL_SELECT_LAST_QUIZ_DATE, _oUser.prwu_WebUserID));
            if (result != DBNull.Value)
            {
                litLastQuizMsg.Text = GetStringFromDate(result);
            }

            btnQuiz.Enabled = false; //Disabled = true;
            if (GetObjectMgr().HasRatedAllNHAVideos())
            {
                btnQuiz.Attributes.Add("href", "javascript:openQuiz();");
                btnQuiz.Enabled = true;   //Disabled = false;
            }

            string viewedIDs = string.Empty;
            using (IDataReader reader = GetDBAccess().ExecuteReader(string.Format(SQL_SELECT_ARTICLES_READ, _oUser.prwu_IndustryType, _oUser.prwu_WebUserID), CommandBehavior.CloseConnection))
            {
                while (reader.Read())
                {
                    if (!string.IsNullOrEmpty(viewedIDs))
                    {
                        viewedIDs += ",";
                    }
                    viewedIDs += Convert.ToString(reader.GetInt32(0));
                }
            }
            hidReadArticleIDs.Value = viewedIDs;
        }

        protected override bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.NewHireAcademyPage).HasPrivilege;
        }

        protected override bool IsAuthorizedForData()
        {
            return true;
        }
    }
}