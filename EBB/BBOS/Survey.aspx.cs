/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2012-2018

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
using System.Collections;
using System.Web.UI;
using sstchur.web.survey;
using TSI.BusinessObjects;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This page uses a custom Survey control from 
    /// http://websurvey.codeplex.com
    /// 
    /// </summary>
    public partial class Survey1 : PageBase
    {
        protected string surveyType = null;
        protected string publicationArticleID = null;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            surveyType = GetRequestParameter("Type");

            switch (surveyType)
            {
                case "NHA":
                    ws.SurveyFile = GetSurveyFile("NHA Quiz.xml");
                    ws.AnswersFile = GetSurveyFile("NHA Quiz Repsonse.xml");
                    break;
                case "NHARating":
                    ws.SurveyFile = GetSurveyFile("NHA Rating.xml");
                    ws.AnswersFile = GetSurveyFile("NHA Rating Repsonse.xml");
                    publicationArticleID = GetRequestParameter("PublicationArticleID");
                    break;
                default:
                    throw new ApplicationException("Unexpected survey type found.");
            }
        }

        /// <summary>
        /// The Survey Control isn't initialized with the questions until PreRender, so we
        /// have to interrogate its status here instead of on PageLoad.
        /// </summary>
        /// <param name="e"></param>
        protected override void OnPreRender(EventArgs e)
        {
            if (ws.IsCompleted)
            {
                pnlSurvey.Visible = false;
                pnlCompleted.Visible = true;
                SaveSurveyAnswers();

                if (surveyType == "NHARating")
                {
                    pnlCompleted.Visible = false;
                    Page.ClientScript.RegisterStartupScript(this.GetType(), "CloseWindow", "closeNHARating();", true);
                }
            }
            else
            {
                HiddenWebQuestion webUserID = (HiddenWebQuestion)ws.Questions["WebUserID"];
                if ((webUserID != null) &&
                    (string.IsNullOrEmpty(webUserID.Answer)))
                {
                    webUserID.SetAnswer(_oUser.prwu_WebUserID.ToString());
                    ((HiddenWebQuestion)ws.Questions["CompanyID"]).SetAnswer(_oUser.prwu_BBID.ToString());
                    ((HiddenWebQuestion)ws.Questions["HQID"]).SetAnswer(_oUser.prwu_HQID.ToString());
                    ((HiddenWebQuestion)ws.Questions["Timestamp"]).SetAnswer(DateTime.Now.ToString("yyyy-MM-dd h:mm:ss tt"));

                    if (ws.Questions.ContainsKey("PublicationArticleID"))
                    {
                        ((HiddenWebQuestion)ws.Questions["PublicationArticleID"]).SetAnswer(_oUser.prwu_HQID.ToString());
                    }
                }

                pnlSurvey.Visible = true;
                pnlCompleted.Visible = false;
            }

            base.OnPreRender(e);
        }

        private const string SQL_INSERT_PRSURVEY_RESPONSE =
            @"INSERT INTO PRSurveyResponse (prsr_WebUserID, prsr_CompanyID, prsr_HQID, prsr_SurveyCode, prsr_PublicationArticleID, prsr_CreatedBy, prsr_UpdatedBy)
                VALUES(@WebUserID, @CompanyID, @HQID, @SurveyCode, @PublicationArticleID, @WebUserID, @WebUserID)";

        private const string SQL_INSERT_PRSURVEY_RESPONSE_DETAIL =
            @"INSERT INTO PRSurveyResponseDetail (prsrd_SurveyResponseID, prsad_QuestionID, prsad_Answer, prsrd_CreatedBy, prsrd_UpdatedBy)
                VALUES(@SurveyResponseID, @QuestionID, @Answer, @WebUserID, @WebUserID)";

        private void SaveSurveyAnswers()
        {
            try
            {
                IList parmList = new ArrayList();
                parmList.Add(new ObjectParameter("WebUserID", _oUser.prwu_WebUserID));
                parmList.Add(new ObjectParameter("CompanyID", _oUser.prwu_BBID));
                parmList.Add(new ObjectParameter("HQID", _oUser.prwu_HQID));
                parmList.Add(new ObjectParameter("SurveyCode", surveyType));

                // If we have a publication article, save it
                if (string.IsNullOrEmpty(publicationArticleID))
                {
                    parmList.Add(new ObjectParameter("PublicationArticleID", DBNull.Value));
                }
                else
                {
                    parmList.Add(new ObjectParameter("PublicationArticleID", publicationArticleID));
                }

                object result = GetDBAccess().ExecuteIdentityInsert(SQL_INSERT_PRSURVEY_RESPONSE, null, parmList, null);
                int surveyResponseID = Convert.ToInt32(result);

                foreach (WebQuestion webQuestion in ws.Questions.Values)
                {
                    if (!(webQuestion is HiddenWebQuestion))
                    {
                        parmList.Clear();
                        parmList.Add(new ObjectParameter("SurveyResponseID", surveyResponseID));
                        parmList.Add(new ObjectParameter("QuestionID", webQuestion.Id));
                        parmList.Add(new ObjectParameter("Answer", webQuestion.Answer));
                        parmList.Add(new ObjectParameter("WebUserID", _oUser.prwu_WebUserID));
                        GetDBAccess().ExecuteIdentityInsert(SQL_INSERT_PRSURVEY_RESPONSE_DETAIL, null, parmList, null);
                    }
                }
            }
            catch (Exception eX)
            {
                LogError(eX);

                if (Configuration.ThrowDevExceptions)
                {
                    throw;
                }
            }
        }

        private string GetSurveyFile(string fileName)
        {
            return "LearningCenter/Survey/" + fileName;
        }

        protected override bool IsAuthorizedForData()
        {
            return true;
        }

        protected override bool IsAuthorizedForPage()
        {
            return true;
        }

        public override void PreparePageFooter()
        {
            // Do nothing.  This is a pop-up window
            // so we don't want our standard footre to appear
        }

        override protected bool SessionTimeoutForPageEnabled()
        {
            return false;
        }
    }
}