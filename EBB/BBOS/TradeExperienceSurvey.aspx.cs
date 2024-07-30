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

 ClassName: TradeExperienceSurvey.aspx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using TSI.Arch;
using TSI.BusinessObjects;
using TSI.DataAccess;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{

    /// <summary>
    /// Allows the user to either select a subject company from a previously
    /// sent TES request or specify a specific company to rate.
    /// </summary>
    public partial class TradeExperienceSurvey : PageBase
    {
        List<string> _lstBBScoreControlIDs;

        #region ' SQL QUERIES '

        private const string SQL_GET_KEY_EXPIRATION_DATE = "SELECT prtf_ExpirationDateTime  " +
                                                             "FROM PRTESForm WITH (NOLOCK)  " +
                                                            "WHERE prtf_Key = {0}";

        private const string SQL_GET_TES_ADDRESSEE =
            "SELECT DISTINCT " +
                   "ISNULL(prtesr_OverrideCustomAttention, ISNULL(dbo.ufn_FormatPersonById(orPL.peli_PersonID), Addressee)) As Addressee, " +
                   "ISNULL(prtesr_OverrideAddress, DeliveryAddress) As DeliveryAddress, " +
                   "CASE WHEN prtesr_OverrideCustomAttention IS NOT NULL THEN NULL WHEN orPL.peli_PersonID IS NOT NULL THEN orPL.peli_PRTitle ELSE atPL.peli_PRTitle END As peli_PRTitle, " +
                   "comp_PRBookTradestyle " +
              "FROM PRTESForm WITH (NOLOCK) " +
                   "INNER JOIN PRTESRequest WITH (NOLOCK) ON prtf_TESFormID = prtesr_TESFormID " +
                   "INNER JOIN Company WITH (NOLOCK) ON prtf_CompanyID = comp_CompanyID " +
                   "LEFT OUTER JOIN vPRCompanyAttentionLine ON prtf_CompanyID = prattn_CompanyID AND prattn_ItemCode = 'TES-E'  " +
                   "LEFT OUTER JOIN Person_Link orPL WITH (NOLOCK) ON orPL.peli_PersonId = prtesr_OverridePersonID AND orPL.peli_PRStatus IN (1,2) " +
                   "LEFT OUTER JOIN Person_Link atPL WITH (NOLOCK) ON atPL.peli_PersonId = prattn_PersonID AND atPL.peli_PRStatus IN (1,2) " +
             "WHERE prtf_Key = {0}";


        private const string SQL_GET_TES_REQUESTS_BY_KEY = "SELECT f.prtf_SerialNumber, tr.prtesr_TESRequestID, f.prtf_CompanyId, tr.prtesr_SubjectCompanyID, cl.comp_PRIndustryType, cl.comp_PRBookTradestyle, cl.CityStateCountryShort, prtesr_SecondRequest " +
                                                            "FROM PRTESRequest tr WITH (NOLOCK)  " +
                                                            "INNER JOIN Company c WITH (NOLOCK)  ON c.Comp_CompanyId = tr.prtesr_SubjectCompanyID " +
                                                            "INNER JOIN vPRBBOSCompanyList cl ON tr.prtesr_SubjectCompanyID = cl.comp_CompanyID " +
                                                            "INNER JOIN PRTESForm f WITH (NOLOCK)  ON f.prtf_TESFormId = tr.prtesr_TESFormID " +
                                                            "WHERE f.prtf_Key = {0} " +
                                                            "AND tr.prtesr_Received IS NULL " +
                                                            "ORDER BY prtesr_SentDateTime DESC";

        private const string SQL_GET_COMPANY_FOR_TES = "SELECT c.Comp_CompanyId, cl.comp_PRBookTradestyle, cl.CityStateCountryShort " +
                                                        "FROM Company c WITH (NOLOCK)  " +
                                                        "INNER JOIN vPRBBOSCompanyList cl ON c.comp_CompanyID = cl.comp_CompanyID " +
                                                        "WHERE c.Comp_CompanyId = {0}";

        protected const string SQL_GET_PENDING_TES_REQUESTS =
            @"SELECT f.prtf_SerialNumber, tr.prtesr_TESRequestID, tr.prtesr_SubjectCompanyID, cl.comp_PRBookTradestyle, cl.CityStateCountryShort, prtesr_SecondRequest 
               FROM PRTESRequest tr WITH (NOLOCK) 
                    INNER JOIN vPRBBOSCompanyList_ALL cl ON tr.prtesr_SubjectCompanyID = cl.comp_CompanyID 
                    INNER JOIN (SELECT prtesr_SubjectCompanyID, MAX(prtesr_TESRequestID) as LatestTESRequestID
					              FROM PRTESRequest WITH (NOLOCK) 
					             WHERE prtesr_Received IS NULL
					               AND prtesr_CreatedDate > {0} 
					               AND prtesr_ResponderCompanyID = {1}
                              GROUP BY prtesr_SubjectCompanyID) T1 ON tr.prtesr_TESRequestID = LatestTESRequestID
                    LEFT OUTER JOIN PRTESForm f WITH (NOLOCK) ON f.prtf_TESFormID = tr.prtesr_TESFormID 
              WHERE tr.prtesr_Received IS NULL 
                AND tr.prtesr_CreatedDate > {0} 
                AND tr.prtesr_ResponderCompanyID = {1} 
                ORDER BY tr.prtesr_SentDateTime DESC";

        protected const string SQL_USER_IS_MEMBER = "SELECT 'x' " +
                                                    "FROM PRAttentionLine WITH (NOLOCK) " +
                                                    "INNER JOIN Person_Link WITH (NOLOCK) ON prattn_PersonID = peli_PersonID AND prattn_CompanyID = peli_CompanyID " +
                                                    "INNER JOIN PRWebUser WITH (NOLOCK) ON peli_PersonLinkID = prwu_PersonLinkID " +
                                                    "WHERE prattn_ItemCode = 'TES-E' " +
                                                    "AND prattn_CompanyID = {0}";

        protected const string SQL_INSERT_PRARAGING
            = @"INSERT INTO PRARAging (praa_ARAgingId, praa_CompanyId, praa_PersonId, praa_Date, praa_RunDate, praa_DateSelectionCriteria, praa_ImportedDate, praa_ManualEntry, 
                                       praa_Count, praa_Total, praa_TotalCurrent, praa_Total1to30, praa_Total31to60, praa_Total61to90, praa_Total91Plus,
                                       praa_CreatedBy, praa_CreatedDate, praa_UpdatedBy, praa_UpdatedDate, praa_TimeStamp) 
                VALUES (@praa_ARAgingId,@praa_CompanyId,@praa_PersonId,@praa_Date,@praa_RunDate,@praa_DateSelectionCriteria,@praa_ImportedDate,@praa_ManualEntry,
                        @praa_Count,@praa_Total,@praa_TotalCurrent,@praa_Total1to30,@praa_Total31to60,@praa_Total61to90,@praa_Total91Plus,
                        @praa_CreatedBy,@praa_CreatedDate,@praa_UpdatedBy,@praa_UpdatedDate,@praa_TimeStamp)";

        protected const string SQL_INSERT_PRARAGING_DETAIL =
              @"INSERT INTO PRARAgingDetail (praad_ARAgingDetailId, praad_ARAgingId, praad_ManualCompanyId, praad_CreditTermsText, praad_AmountCurrent, praad_Amount1to30, praad_Amount31to60, praad_Amount61to90, praad_Amount91Plus, praad_CreatedBy, praad_CreatedDate, praad_UpdatedBy, praad_UpdatedDate, praad_TimeStamp) 
                                     VALUES (@praad_ARAgingDetailId,@praad_ARAgingId,@praad_ManualCompanyId,@praad_CreditTermsText,@praad_AmountCurrent,@praad_Amount1to30,@praad_Amount31to60,@praad_Amount61to90,@praad_Amount91Plus,@praad_CreatedBy,@praad_CreatedDate,@praad_UpdatedBy,@praad_UpdatedDate,@praad_TimeStamp)";
        #endregion

        #region ' Class Variables ' 
        private enum KeyStatus { Valid, Invalid, Expired };
        #endregion

        #region ' Overriden Base Methods '
        /// <summary>
        /// Handles page load logic.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            SetPageTitle(Resources.Global.TradeExperienceSurvey2);
            EnableFormValidation();

            if (!IsPostBack)
            {

                //If the user is not logged in and there is no Key parameter redirect to login.
                if (_oUser == null && String.IsNullOrEmpty(GetRequestParameter("Key", false)))
                {
                    //When we have no parameters, the page
                    Response.Redirect(PageConstants.LOGIN);
                }
                else
                {
                    //Render the page based on how the user got here.
                    RenderPage();
                }
            }
        }

        /// <summary>
        /// Checks if the user is authorized for the page.
        /// </summary>
        /// <returns></returns>
        protected override bool IsAuthorizedForPage()
        {
            if (_oUser != null)
                return _oUser.IsInRole(PRWebUser.ROLE_SUBMIT_TES);
            else if (!String.IsNullOrEmpty(GetRequestParameter("Key", false)))
                return true;
            else
                return false;
        }

        /// <summary>
        /// If a CompanyID is specified, makes sure it is for a listed company.
        /// </summary>
        /// <returns></returns>
        protected override bool IsAuthorizedForData()
        {
            // If no company has been specified, then the user will have to
            // select one.
            if (string.IsNullOrEmpty(GetRequestParameter("CompanyID", false)))
            {
                return true;
            }

            int iCompanyID = 0;
            if (!int.TryParse(GetRequestParameter("CompanyID"), out iCompanyID))
            {
                throw new ArgumentException("Invalid CompanyID parameter specified");
            }

            return GetObjectMgr().IsCompanyListed(iCompanyID);
        }
        #endregion

        #region ' Display Logic Methods '
        /// <summary>
        /// Executes a series of logic steps to determine which section of the page to display
        /// and how to handle the gridview data retrieval.
        /// </summary>
        private void RenderPage()
        {
            string key = GetRequestParameter("Key", false);
            string companyIDList = GetRequestParameter("CompanyIDList", false);
            string companyID = GetRequestParameter("CompanyID", false);

            BindLookupValues(ddlViewRecords, GetReferenceData("BBOSTESRequestGridPageSize"));

            //Determine which interface to show based on how we access this page.
            if (!String.IsNullOrEmpty(key))
            {
                //If a key was passed in the querystring see if it exists.
                if (ValidateKey(key) == KeyStatus.Invalid)
                {
                    DisplayInvalidKeyMessage();
                    return;
                }

                //If a key was passed in the querystring see if it has expired.
                if (ValidateKey(key) == KeyStatus.Expired)
                {
                    DisplayExpiredKeyMessage();
                    return;
                }

                GetTESRequestsByKey(key);

                if (!TESRequestsViewStateIsNull())
                {
                    BindRequestGridView();
                    DisplayTESAddresseeInformation(key);
                }
                else
                {
                    DisplayNoRequestsFoundMessage();
                }
            }
            else if (!String.IsNullOrEmpty(companyIDList))
            {
                GetCompanyListDataForTES(companyIDList);

                if (!TESRequestsViewStateIsNull())
                    BindRequestGridView();
                else
                    DisplayNoRequestsFoundMessage();

            }
            else if (!String.IsNullOrEmpty(companyID))
            {
                ValidateCompanyForTES(Convert.ToInt32(companyID));
                GETCompanyDataForTES(Convert.ToInt32(companyID));

                if (!TESRequestsViewStateIsNull())
                    BindRequestGridView();
                else
                    DisplayNoRequestsFoundMessage();

            }
            else
            {
                GetPendingTESRequests();

                if (!TESRequestsViewStateIsNull())
                    BindRequestGridView();
                else
                    DisplayNoRequestsFoundMessage();
            }

            if (pnlRequests.Visible == true)
                ViewState.Add("GridViewPageSize", ddlViewRecords.SelectedValue);
        }

        private bool TESRequestsViewStateIsNull()
        {
            if (ViewState["TESRequests"] != null && ((List<TESRequest>)ViewState["TESRequests"]).Count > 0)
                return false;
            else
                return true;
        }

        /// <summary>
        /// Displays the invalid key message.
        /// </summary>
        private void DisplayInvalidKeyMessage()
        {
            lblKeyMessage.Visible = true;
            lblKeyMessage.Text = Resources.Global.InvalidTESFormKey;

            if (Utilities.GetBoolConfigValue("LogInvalidTESGUIDKey", false))
            {
                LogError(new ApplicationUnexpectedException("Invalid TES GUID Key Provided"));
            }
        }

        /// <summary>
        /// Displays the expired key message.
        /// </summary>
        private void DisplayExpiredKeyMessage()
        {
            lblKeyMessage.Visible = true;
            lblKeyMessage.Text = Resources.Global.ExpiredTESFormKey;
        }

        /// <summary>
        /// Displays the no requests found message.
        /// </summary>
        private void DisplayNoRequestsFoundMessage()
        {
            lblKeyMessage.Visible = true;
            lblKeyMessage.Text = Resources.Global.TESNoPendingRequestsFound;

            //Clear "BBScoreContentIDs" from session to prevent UpdatePanel trigger errors
            Session.Remove(SESSION_BBSCORE);
        }

        /// <summary>
        /// Displays TES Addresse information.
        /// </summary>
        /// <param name="key"></param>
        private void DisplayTESAddresseeInformation(string key)
        {
            ArrayList oParameters = new ArrayList();

            oParameters.Add(new ObjectParameter("prtf_Key", key));
            string szSQL = GetObjectMgr().FormatSQL(SQL_GET_TES_ADDRESSEE, oParameters);

            // Use our own DBAccess object to 
            // avoid conflicts with open readers.
            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            oDBAccess.Logger = _oLogger;

            IDataReader oReader = oDBAccess.ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            try
            {
                if (oReader.Read())
                {
                    lblTesSentToName.Text = oDBAccess.GetString(oReader, "Addressee");
                    lblTesSentToTitle.Text = oDBAccess.GetString(oReader, "peli_PRTitle");
                    lblTesSentToCompany.Text = oDBAccess.GetString(oReader, "comp_PRBookTradestyle");
                    lblTesSentToEmail.Text = oDBAccess.GetString(oReader, "DeliveryAddress");
                }
                pnlKeyScreenBlock.Visible = true;
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }
        }

        /// <summary>
        /// Display completed section.
        /// </summary>
        private void DisplayCompletedSection()
        {
            string key = GetRequestParameter("Key", false);

            if (!String.IsNullOrEmpty(key))
            {
                if (EmailedUserIsMember(key))
                {
                    lblThankYouMessage.Text = Resources.Global.TESThankYouMemberText;
                    btnThankYouAction.Text = Resources.Global.TESThankYouMemberActionBtn;
                }
                else
                {
                    lblThankYouMessage.Text = Resources.Global.TESThankYouNonMemberText;
                    btnThankYouAction.Text = Resources.Global.TESThankYouNonMemberActionBtn;
                }
            }
            else
            {
                lblThankYouMessage.Text = Resources.Global.TESThankYouMsg;
                btnThankYouAction.Text = "Continue";
            }

            pnlKeyScreenBlock.Visible = false;
            pnlRequests.Visible = false;
            pnlComplete.Visible = true;
        }
        #endregion

        #region ' TES Request Data Retrieval Methods '
        /// <summary>
        /// Retrieves all TES requests related to the GUID Key.
        /// </summary>
        /// <param name="key"></param>
        private void GetTESRequestsByKey(string key)
        {
            List<TESRequest> requests = new List<TESRequest>();

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prtf_key", key));
            string szSQL = GetObjectMgr().FormatSQL(SQL_GET_TES_REQUESTS_BY_KEY, oParameters);

            // Use our own DBAccess object to 
            // avoid conflicts with open readers.
            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            oDBAccess.Logger = _oLogger;

            IDataReader oReader = oDBAccess.ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            try
            {
                int i = 0;

                while (oReader.Read())
                {
                    TESRequest request = new TESRequest();
                    request.Index = i;
                    request.Id = GetDBAccess().GetInt32(oReader, "prtesr_TESRequestID");
                    request.SerialNumber = GetDBAccess().GetInt32(oReader, "prtf_SerialNumber");
                    request.BBNumber = GetDBAccess().GetInt32(oReader, "prtesr_SubjectCompanyID");
                    request.CompanyName = GetDBAccess().GetString(oReader, "comp_PRBookTradestyle");
                    request.CompanyLocation = GetDBAccess().GetString(oReader, "CityStateCountryShort");
                    request.SecondRequest = GetDBAccess().GetString(oReader, "prtesr_SecondRequest");

                    //Get the responder companyID
                    if (ViewState["ResponderCompanyID"] == null)
                        ViewState.Add("ResponderCompanyID", GetDBAccess().GetInt32(oReader, "prtf_CompanyId"));

                    //Get the responder companyID Industry type
                    if (ViewState["ResponderCompanyIndustryType"] == null)
                        ViewState.Add("ResponderCompanyIndustryType", GetDBAccess().GetString(oReader, "comp_PRIndustryType"));

                    if (ValidateCompanyForTES(request.BBNumber))
                        requests.Add(request);

                    i++;
                }

                if (requests.Count > 0)
                    ViewState.Add("TESRequests", requests);
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }
        }

        /// <summary>
        /// Retrieves all pending TES Requests.
        /// </summary>
        private void GetPendingTESRequests()
        {
            List<TESRequest> requests = new List<TESRequest>();

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prtf_CreatedDate", DateTime.Now.AddDays(0 - Utilities.GetIntConfigValue("TESSubjectsAgeThreshold", 45))));
            oParameters.Add(new ObjectParameter("prtesr_ResponderCompanyID", GetResponderCompanyID()));
            string szSQL = GetObjectMgr().FormatSQL(SQL_GET_PENDING_TES_REQUESTS, oParameters);

            // Use our own DBAccess object to 
            // avoid conflicts with open readers.
            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            oDBAccess.Logger = _oLogger;

            IDataReader oReader = oDBAccess.ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            try
            {
                int i = 0;

                while (oReader.Read())
                {
                    TESRequest request = new TESRequest();
                    request.Index = i;
                    request.Id = GetDBAccess().GetInt32(oReader, "prtesr_TESRequestID");
                    request.SerialNumber = GetDBAccess().GetInt32(oReader, "prtf_SerialNumber");
                    request.BBNumber = GetDBAccess().GetInt32(oReader, "prtesr_SubjectCompanyID");
                    request.CompanyName = GetDBAccess().GetString(oReader, "comp_PRBookTradestyle");
                    request.CompanyLocation = GetDBAccess().GetString(oReader, "CityStateCountryShort");
                    request.SecondRequest = GetDBAccess().GetString(oReader, "prtesr_SecondRequest");

                    if (ValidateCompanyForTES(request.BBNumber))
                        requests.Add(request);

                    i++;
                }

                ViewState.Add("TESRequests", requests);
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }
        }

        /// <summary>
        /// Gets company information to use for TES.
        /// </summary>
        /// <param name="companyID"></param>
        private void GETCompanyDataForTES(int companyID)
        {
            List<TESRequest> requests = new List<TESRequest>();

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("Comp_CompanyId", companyID));
            string szSQL = GetObjectMgr().FormatSQL(SQL_GET_COMPANY_FOR_TES, oParameters);

            // Use our own DBAccess object to 
            // avoid conflicts with open readers.
            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            oDBAccess.Logger = _oLogger;

            IDataReader oReader = oDBAccess.ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            try
            {
                int i = 0;

                while (oReader.Read())
                {
                    TESRequest request = new TESRequest();
                    request.Index = i;
                    request.BBNumber = GetDBAccess().GetInt32(oReader, "Comp_CompanyId");
                    request.CompanyName = GetDBAccess().GetString(oReader, "comp_PRBookTradestyle");
                    request.CompanyLocation = GetDBAccess().GetString(oReader, "CityStateCountryShort");

                    if (ValidateCompanyForTES(request.BBNumber))
                        requests.Add(request);

                    i++;
                }

                ViewState.Add("TESRequests", requests);
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }
        }

        /// <summary>
        /// Gets company TES requests for the list of companies in the quesrustring.
        /// </summary>
        /// <param name="companyIDList"></param>
        private void GetCompanyListDataForTES(string companyIDList)
        {
            List<TESRequest> requests = new List<TESRequest>();

            string[] arrCompanyIds = companyIDList.Split(',');

            int i = 0;

            foreach (string strCompanyId in arrCompanyIds)
            {
                ArrayList oParameters = new ArrayList();
                oParameters.Add(new ObjectParameter("Comp_CompanyId", Convert.ToInt32(strCompanyId)));
                string szSQL = GetObjectMgr().FormatSQL(SQL_GET_COMPANY_FOR_TES, oParameters);

                // Use our own DBAccess object to 
                // avoid conflicts with open readers.
                IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
                oDBAccess.Logger = _oLogger;

                IDataReader oReader = oDBAccess.ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
                try
                {
                    while (oReader.Read())
                    {
                        TESRequest request = new TESRequest();
                        request.Index = i;
                        request.BBNumber = GetDBAccess().GetInt32(oReader, "Comp_CompanyId");
                        request.CompanyName = GetDBAccess().GetString(oReader, "comp_PRBookTradestyle");
                        request.CompanyLocation = GetDBAccess().GetString(oReader, "CityStateCountryShort");
                        if (ValidateCompanyForTES(request.BBNumber))
                            requests.Add(request);

                        i++;
                    }
                }
                finally
                {
                    if (oReader != null)
                    {
                        oReader.Close();
                    }
                }
            }

            ViewState.Add("TESRequests", requests);
        }
        #endregion

        #region ' Validation Methods '
        /// <summary>
        /// Checks if the GUID Key exists and is valid.
        /// </summary>
        /// <param name="key"></param>
        /// <returns>KeyStatus</returns>
        private KeyStatus ValidateKey(string key)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prtf_Key", key));

            string szSQL = GetObjectMgr().FormatSQL(SQL_GET_KEY_EXPIRATION_DATE, oParameters);
            object oValue = GetDBAccess().ExecuteScalar(szSQL, oParameters);

            if (oValue == null)
                return KeyStatus.Invalid;

            if (DateTime.Compare(Convert.ToDateTime(oValue), DateTime.Today) < 0)
                return KeyStatus.Expired;

            return KeyStatus.Valid;
        }

        protected const string SQL_AFFILIATES =
            @"SELECT 'x' FROM (
                    SELECT CASE WHEN prcr_LeftCompanyID={0} THEN prcr_RightCompanyID ELSE prcr_LeftCompanyID END As CompanyID
                        FROM PRCompanyRelationship WITH (NOLOCK) 
                        WHERE (prcr_LeftCompanyID = {0} OR prcr_RightCompanyID={0})
                        AND prcr_Type IN (27, 28, 29)
                        AND prcr_Active = 'Y'
                        AND prcr_Deleted IS NULL) T1 
                    WHERE CompanyID = {1}";

        /// <summary>
        /// Validates a company before displaying.
        /// </summary>
        /// <param name="subjectCompanyID"></param>
        /// <returns></returns>
        protected bool ValidateCompanyForTES(int subjectCompanyID)
        {
            if (_oUser != null)
            {
                return IsValidTESSubject(_oUser, subjectCompanyID);
            }

            bool bValid = true;

            if (GetResponderCompanyID() == Convert.ToInt32(subjectCompanyID))
            {
                bValid = false;
            }
            else
            {
                ArrayList oParameters = new ArrayList();
                oParameters.Add(new ObjectParameter("CompanyID", GetResponderCompanyID()));
                oParameters.Add(new ObjectParameter("SubjectID", subjectCompanyID));

                string szSQL = GetObjectMgr().FormatSQL(SQL_AFFILIATES, oParameters);
                object oValue = GetDBAccess().ExecuteScalar(szSQL, oParameters);

                if (oValue != null)
                    bValid = false;
            }

            return bValid;
        }

        /// <summary>
        /// Checks if the emailed user (who received the Key) is a member.
        /// </summary>
        /// <param name="key"></param>
        /// <returns></returns>
        private bool EmailedUserIsMember(string key)
        {
            bool isMember = false;

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prattn_CompanyID", GetResponderCompanyID()));

            string szSQL = GetObjectMgr().FormatSQL(SQL_USER_IS_MEMBER, oParameters);
            object oValue = GetDBAccess().ExecuteScalar(szSQL, oParameters);

            if (oValue != null)
                isMember = true;

            return isMember;
        }

        /// <summary>
        /// Checks is the user works in a lumber type industry.
        /// </summary>
        /// <returns></returns>
        private bool IsLumber()
        {
            bool isLumber = false;

            if (_oUser != null)
            {
                if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                    isLumber = true;
            }
            else
            {
                if (ViewState["ResponderCompanyIndustryType"] != null)
                {
                    if (ViewState["ResponderCompanyIndustryType"].ToString() == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                        isLumber = true;
                }
            }

            return isLumber;
        }

        /// <summary>
        /// Checks if a valus is not empty and returns it otherwise it returns null.
        /// </summary>
        /// <param name="szValue"></param>
        /// <returns></returns>
        private string GetValueForDB(string szValue)
        {
            if (string.IsNullOrEmpty(szValue))
            {
                return null;
            }

            return szValue;
        }

        protected decimal GetValueForDBasDecmial(string szValue)
        {
            if (string.IsNullOrEmpty(szValue))
            {
                return 0M;
            }
            return Convert.ToDecimal(szValue);
        }

        /// <summary>
        /// Gets the Responder CompanyID either from the User or the Key (PRTESForm companyId saved in viewstate).
        /// </summary>
        /// <returns></returns>
        private int GetResponderCompanyID()
        {
            if (_oUser != null)
                return _oUser.prwu_BBID;
            else if (ViewState["ResponderCompanyID"] != null)
                return Convert.ToInt32(ViewState["ResponderCompanyID"]);
            else
                throw new ArgumentException("Responder CompanyID could not be retrieved.");
        }

        /// <summary>
        /// Returns either the logged in userID or null.
        /// </summary>
        /// <returns></returns>
        private int? GetWebUserID()
        {
            if (_oUser != null)
                return _oUser.prwu_WebUserID;
            else
                return null;
        }

        /// <summary>
        /// Returns either the logged in user's person link id or null
        /// </summary>
        /// <returns></returns>
        private int? GetUserPersonLinkID()
        {
            if (_oUser != null)
                return _oUser.peli_PersonID;
            else
                return null;
        }
        #endregion

        #region ' Gridview Support Methods '
        const string SESSION_BBSCORE = "BBScoreControlIDs";

        /// <summary>
        /// Binds the gvTESRequest gridview with data and handles the paging and submit buttons display.
        /// </summary>
        private void BindRequestGridView()
        {
            pnlRequests.Visible = true;

            List<TESRequest> requests = (List<TESRequest>)ViewState["TESRequests"];

            int visibleRecordCount = Convert.ToInt32(ddlViewRecords.SelectedValue);

            if (visibleRecordCount > requests.Count)
                visibleRecordCount = requests.Count;

            if (visibleRecordCount != requests.Count)
                gvTESRequests.DataSource = requests.GetRange(0, visibleRecordCount);
            else
                gvTESRequests.DataSource = requests;


            _lstBBScoreControlIDs = new List<string>();
            gvTESRequests.DataBind();
            EnableBootstrapFormatting(gvTESRequests);
            Session.Add(SESSION_BBSCORE, _lstBBScoreControlIDs); 

            RegisterTriggers(); 

            //Display appropriate columns based on industry type.
            if (IsLumber())
            {
                gvTESRequests.Columns[5].Visible = false; 
                gvTESRequests.Columns[6].Visible = true;

                gvTESRequests.Columns[4].Visible = false;  // Integrity/Ability
                gvTESRequests.Columns[7].Visible = false;  // High Credit
            }
            else
            {
                gvTESRequests.Columns[5].Visible = true;
                gvTESRequests.Columns[6].Visible = false;
            }

            if (_oUser == null)
                gvTESRequests.Columns[3].Visible = false; //hide BB Score column if user is not logged in

            lblRecordsDisplayed.Text = visibleRecordCount.ToString();
            lblTotalRemainingRecords.Text = requests.Count.ToString();

            if (requests.Count <= 5)
                lnkBtnSaveAndContinue.Visible = false;
            else
            {
                lnkBtnSaveAndContinue.Visible = true;
            }
        }

        /// <summary>
        /// Handles grid view row data preservation depending on rows displayed.
        /// </summary>
        protected void ManageGridRowValues()
        {
            if (!String.IsNullOrEmpty(ViewState["GridViewPageSize"].ToString()))
            {
                int previousGridViewPageSize = Convert.ToInt32(ViewState["GridViewPageSize"].ToString());
                int newGridViewPageSize = Convert.ToInt32(ddlViewRecords.SelectedValue);

                if (newGridViewPageSize > previousGridViewPageSize)
                {
                    List<TESRequest> requests = (List<TESRequest>)ViewState["TESRequests"];
                    List<TESRequest> visibleRequests = GetVisibleRequests();

                    foreach (TESRequest request in visibleRequests)
                    {
                        TESRequest requestToPreserve = requests.Find(new Predicate<TESRequest>(delegate (TESRequest requestToFind) { return (requestToFind.Index == request.Index); }));
                        requestToPreserve.CompanyIntegrity = request.CompanyIntegrity;
                        requestToPreserve.CompanyPayPerformance = request.CompanyPayPerformance;
                        requestToPreserve.CompanyHighCredit = request.CompanyHighCredit;
                        requestToPreserve.CompanyLastDealt = request.CompanyLastDealt;
                        requestToPreserve.CompanyOutOfBusiness = request.CompanyOutOfBusiness;
                        requestToPreserve.Comments = request.Comments;

                        requestToPreserve.CompanyAmountOwedCurrent = request.CompanyAmountOwedCurrent;
                        requestToPreserve.CompanyAmountOwed1To30 = request.CompanyAmountOwed1To30;
                        requestToPreserve.CompanyAmountOwed31To60 = request.CompanyAmountOwed31To60;
                        requestToPreserve.CompanyAmountOwed61To90 = request.CompanyAmountOwed61To90;
                        requestToPreserve.CompanyAmountOwed91Plus = request.CompanyAmountOwed91Plus;
                    }
                }
                else
                {
                    List<TESRequest> requests = (List<TESRequest>)ViewState["TESRequests"];
                    List<TESRequest> visibleRequests = GetVisibleRequests();

                    int i = 1;

                    foreach (TESRequest request in visibleRequests)
                    {
                        TESRequest requestFound = requests.Find(new Predicate<TESRequest>(delegate (TESRequest requestToFind) { return (requestToFind.Index == request.Index); }));

                        if (i <= newGridViewPageSize)
                        {
                            requestFound.CompanyIntegrity = request.CompanyIntegrity;
                            requestFound.CompanyPayPerformance = request.CompanyPayPerformance;
                            requestFound.CompanyHighCredit = request.CompanyHighCredit;
                            requestFound.CompanyLastDealt = request.CompanyLastDealt;
                            requestFound.CompanyOutOfBusiness = request.CompanyOutOfBusiness;

                            requestFound.CompanyAmountOwedCurrent = request.CompanyAmountOwedCurrent;
                            requestFound.CompanyAmountOwed1To30 = request.CompanyAmountOwed1To30;
                            requestFound.CompanyAmountOwed31To60 = request.CompanyAmountOwed31To60;
                            requestFound.CompanyAmountOwed61To90 = request.CompanyAmountOwed61To90;
                            requestFound.CompanyAmountOwed91Plus = request.CompanyAmountOwed91Plus;
                            requestFound.Comments = request.Comments;
                        }
                        else
                        {
                            requestFound.CompanyIntegrity = string.Empty;
                            requestFound.CompanyPayPerformance = string.Empty;
                            requestFound.CompanyHighCredit = string.Empty;
                            requestFound.CompanyLastDealt = string.Empty;
                            requestFound.CompanyOutOfBusiness = false;
                            requestFound.CompanyAmountOwedCurrent = string.Empty;
                            requestFound.CompanyAmountOwed1To30 = string.Empty;
                            requestFound.CompanyAmountOwed31To60 = string.Empty;
                            requestFound.CompanyAmountOwed61To90 = string.Empty;
                            requestFound.CompanyAmountOwed91Plus = string.Empty;
                            requestFound.Comments = string.Empty;
                        }

                        i++;
                    }
                }

                ViewState["GridViewPageSize"] = newGridViewPageSize;
            }
        }

        /// <summary>
        /// Gets only the visible grid TES Requests.
        /// </summary>
        /// <returns></returns>
        private List<TESRequest> GetVisibleRequests()
        {
            List<TESRequest> visibleRequests = new List<TESRequest>();

            foreach (GridViewRow row in gvTESRequests.Rows)
            {
                if (row.RowType == DataControlRowType.DataRow)
                {
                    TESRequest request = new TESRequest();

                    RadioButtonList rdLstIntegrity = (RadioButtonList)row.FindControl("rdLstIntegrity");
                    RadioButtonList rdLstHighCredit = (RadioButtonList)row.FindControl("rdLstHighCredit");
                    RadioButtonList rdLstLastDealt = (RadioButtonList)row.FindControl("rdLstLastDealt");
                    CheckBox chkOutOfBusiness = (CheckBox)row.FindControl("chkOutOfBusiness");
                    HtmlTextArea txtAreaComments = (HtmlTextArea)row.FindControl("txtAreaComments");

                    request.Index = Convert.ToInt32(gvTESRequests.DataKeys[row.RowIndex].Values[0]);
                    request.Id = Convert.ToInt32(gvTESRequests.DataKeys[row.RowIndex].Values[1]);
                    request.SerialNumber = Convert.ToInt32(gvTESRequests.DataKeys[row.RowIndex].Values[2]);
                    request.BBNumber = Convert.ToInt32(gvTESRequests.DataKeys[row.RowIndex].Values[3]);
                    request.CompanyIntegrity = Request[rdLstIntegrity.UniqueID];
                    request.CompanyHighCredit = Request[rdLstHighCredit.UniqueID];
                    request.CompanyLastDealt = Request[rdLstLastDealt.UniqueID];
                    request.CompanyOutOfBusiness = chkOutOfBusiness.Checked;
                    request.Comments = txtAreaComments.InnerText;

                    if (IsLumber())
                    {
                        TextBox txtAmountOwedCurrent = (TextBox)row.FindControl("txtAmountOwedCurrent");
                        TextBox txtAmountOwed1_30 = (TextBox)row.FindControl("txtAmountOwed1_30");
                        TextBox txtAmountOwed31_60 = (TextBox)row.FindControl("txtAmountOwed31_60");
                        TextBox txtAmountOwed61_90 = (TextBox)row.FindControl("txtAmountOwed61_90");
                        TextBox txtAmountOwed91 = (TextBox)row.FindControl("txtAmountOwed91");

                        request.CompanyAmountOwedCurrent = txtAmountOwedCurrent.Text;
                        request.CompanyAmountOwed1To30 = txtAmountOwed1_30.Text;
                        request.CompanyAmountOwed31To60 = txtAmountOwed31_60.Text;
                        request.CompanyAmountOwed61To90 = txtAmountOwed61_90.Text;
                        request.CompanyAmountOwed91Plus = txtAmountOwed91.Text;
                    }
                    else
                    {
                        RadioButtonList rdLstPayPerformance = (RadioButtonList)row.FindControl("rdLstPayPerformance");
                        request.CompanyPayPerformance = Request[rdLstPayPerformance.UniqueID];
                    }

                    visibleRequests.Add(request);
                }
            }

            return visibleRequests;
        }

        #endregion

        #region ' Data Submission Methods '
        /// <summary>
        /// Adds an online trade report.
        /// </summary>
        /// <param name="request"></param>
        private void AddOnlineTradeReport(TESRequest request)
        {
            bool responded = true;

            //If the request was not filled out do not supply these parameters so that the PRTradeReport is not created.
            if (string.IsNullOrEmpty(request.CompanyLastDealt) &&
                string.IsNullOrEmpty(request.CompanyIntegrity) &&
                string.IsNullOrEmpty(request.CompanyPayPerformance) &&
                string.IsNullOrEmpty(request.CompanyHighCredit) &&
                request.CompanyOutOfBusiness == false &&
                string.IsNullOrEmpty(request.Comments))
            {
                //Remove the request from the viewstate object
                ((List<TESRequest>)ViewState["TESRequests"]).RemoveAll(new Predicate<TESRequest>(delegate (TESRequest requestToRemove) { return (requestToRemove.Index == request.Index); }));
                return;
            }

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("Responder_BBID", GetResponderCompanyID()));
            oParameters.Add(new ObjectParameter("Subject_BBID", request.BBNumber));
            oParameters.Add(new ObjectParameter("PRWebUserID", GetWebUserID()));

            //If the request was not filled out do not supply these parameters so that the PRTradeReport is not created.
            if (responded)
            {
                oParameters.Add(new ObjectParameter("HowRecently", request.CompanyLastDealt));
                oParameters.Add(new ObjectParameter("Integrity", request.CompanyIntegrity));
                oParameters.Add(new ObjectParameter("Pay", request.CompanyPayPerformance));
                oParameters.Add(new ObjectParameter("HighCredit", request.CompanyHighCredit));
                oParameters.Add(new ObjectParameter("OutOfBusiness", GetObjectMgr().GetPIKSCoreBool(request.CompanyOutOfBusiness)));
                oParameters.Add(new ObjectParameter("Summary", request.Comments));
            }

            //If the serial number is not present it means that there is no PRTESForm record and this is a Verbal Investigation Request.
            //In this case we pass in a requestID so that the stored procedure knows where to get the correct data from.
            if (request.SerialNumber != 0)
            {
                oParameters.Add(new ObjectParameter("SerialNumber", request.SerialNumber));
            }
            else
            {
                if (request.Id != 0)
                    oParameters.Add(new ObjectParameter("PRTESRequestID", request.Id));
            }

            GetDBAccess().ExecuteNonQuery("usp_AddOnlineTradeReport", oParameters, null, CommandType.StoredProcedure);

            //Remove the request from the viewstate object
            ((List<TESRequest>)ViewState["TESRequests"]).RemoveAll(new Predicate<TESRequest>(delegate (TESRequest requestToRemove) { return (requestToRemove.Index == request.Index); }));
        }

        /// <summary>
        /// Creates a task related to the "send to other person" form.
        /// </summary>
        private void CreateTaskSendTESToAnotherPerson()
        {
            if (chkMailTESToSomeoneElse.Checked)
            {
                if (txtTESOtherName.Text != string.Empty || txtTESOtherTitle.Text != string.Empty
                    || txtTESOtherEmail.Text != string.Empty || txtTESOtherPhone.Text != string.Empty || txtTESOtherFax.Text != string.Empty)
                {
                    StringBuilder sbMsg = new StringBuilder();

                    sbMsg.Append("User submitted TES Attention Line changes from BBOS:" + Environment.NewLine);
                    sbMsg.Append("BB #: " + GetResponderCompanyID() + Environment.NewLine);
                    sbMsg.Append("Name:" + txtTESOtherName.Text + Environment.NewLine);
                    sbMsg.Append("Title:" + txtTESOtherTitle.Text + Environment.NewLine);
                    sbMsg.Append("Email:" + txtTESOtherEmail.Text + Environment.NewLine);
                    sbMsg.Append("Phone:" + txtTESOtherPhone.Text + Environment.NewLine);
                    sbMsg.Append("Fax:" + txtTESOtherFax.Text + Environment.NewLine);

                    try
                    {
                        GetObjectMgr().CreateTask(GetObjectMgr().GetPRCoSpecialistID(GetResponderCompanyID(), GeneralDataMgr.PRCO_SPECIALIST_CSR, null),
                          "Pending",
                          sbMsg.ToString(),
                          Utilities.GetConfigValue("TESRequestContactChangeCategory", "CS"),
                          Utilities.GetConfigValue("TESRequestContactChangeSubcategory", "ALC"),
                          GetResponderCompanyID(),
                          0,
                          null);

                    }
                    catch (Exception eX)
                    {
                        LogError(eX);

                        if (Configuration.ThrowDevExceptions)
                            throw;
                    }
                    finally
                    {
                        //Reset the form
                        txtTESOtherName.Text = string.Empty;
                        txtTESOtherTitle.Text = string.Empty;
                        txtTESOtherEmail.Text = string.Empty;
                        txtTESOtherPhone.Text = string.Empty;
                        txtTESOtherFax.Text = string.Empty;
                        chkMailTESToSomeoneElse.Checked = false;
                    }
                }
            }
        }

        /// <summary>
        /// Creates lumber specific records.
        /// </summary>
        /// <param name="request"></param>
        private void CheckCreateLumberIndustryRecords(TESRequest request)
        {
            if (IsLumber())
            {
                if ((!string.IsNullOrEmpty(request.CompanyAmountOwedCurrent)) ||
                    (!string.IsNullOrEmpty(request.CompanyAmountOwed1To30)) ||
                    (!string.IsNullOrEmpty(request.CompanyAmountOwed31To60)) ||
                    (!string.IsNullOrEmpty(request.CompanyAmountOwed61To90)) ||
                    (!string.IsNullOrEmpty(request.CompanyAmountOwed91Plus)))
                {
                    ArrayList oParameters = new ArrayList();
                    int iARAgingID = GetObjectMgr().GetRecordID("PRARAging");

                    oParameters.Add(new ObjectParameter("praa_ARAgingId", iARAgingID));
                    oParameters.Add(new ObjectParameter("praa_CompanyId", GetResponderCompanyID()));
                    oParameters.Add(new ObjectParameter("praa_PersonId", GetUserPersonLinkID()));
                    oParameters.Add(new ObjectParameter("praa_Date", DateTime.Now));
                    oParameters.Add(new ObjectParameter("praa_RunDate", DateTime.Today));
                    oParameters.Add(new ObjectParameter("praa_DateSelectionCriteria", "INV"));
                    oParameters.Add(new ObjectParameter("praa_ImportedDate", DateTime.Today));
                    oParameters.Add(new ObjectParameter("praa_ManualEntry", "Y"));

                    oParameters.Add(new ObjectParameter("praa_Count", 1));
                    oParameters.Add(new ObjectParameter("praa_Total", GetValueForDBasDecmial(request.CompanyAmountOwedCurrent) + GetValueForDBasDecmial(request.CompanyAmountOwed1To30) + GetValueForDBasDecmial(request.CompanyAmountOwed31To60) + GetValueForDBasDecmial(request.CompanyAmountOwed61To90) + GetValueForDBasDecmial(request.CompanyAmountOwed91Plus)));
                    oParameters.Add(new ObjectParameter("praa_TotalCurrent", GetValueForDB(request.CompanyAmountOwedCurrent)));
                    oParameters.Add(new ObjectParameter("praa_Total1to30", GetValueForDB(request.CompanyAmountOwed1To30)));
                    oParameters.Add(new ObjectParameter("praa_Total31to60", GetValueForDB(request.CompanyAmountOwed31To60)));
                    oParameters.Add(new ObjectParameter("praa_Total61to90", GetValueForDB(request.CompanyAmountOwed61To90)));
                    oParameters.Add(new ObjectParameter("praa_Total91Plus", GetValueForDB(request.CompanyAmountOwed91Plus)));

                    GetObjectMgr().AddAuditTrailParametersForInsert(oParameters, "praa");
                    GetDBAccess().ExecuteNonQuery(SQL_INSERT_PRARAGING, oParameters, null);

                    oParameters.Clear();
                    oParameters.Add(new ObjectParameter("praad_ARAgingDetailId", GetObjectMgr().GetRecordID("PRARAgingDetail")));
                    oParameters.Add(new ObjectParameter("praad_ARAgingId", iARAgingID));
                    oParameters.Add(new ObjectParameter("praad_ManualCompanyId", request.BBNumber));
                    oParameters.Add(new ObjectParameter("praad_SubjectCompanyId", request.BBNumber));
                    oParameters.Add(new ObjectParameter("praad_CreditTermsText", null));
                    oParameters.Add(new ObjectParameter("praad_AmountCurrent", GetValueForDB(request.CompanyAmountOwedCurrent)));
                    oParameters.Add(new ObjectParameter("praad_Amount1to30", GetValueForDB(request.CompanyAmountOwed1To30)));
                    oParameters.Add(new ObjectParameter("praad_Amount31to60", GetValueForDB(request.CompanyAmountOwed31To60)));
                    oParameters.Add(new ObjectParameter("praad_Amount61to90", GetValueForDB(request.CompanyAmountOwed61To90)));
                    oParameters.Add(new ObjectParameter("praad_Amount91Plus", GetValueForDB(request.CompanyAmountOwed91Plus)));

                    GetObjectMgr().AddAuditTrailParametersForInsert(oParameters, "praad");
                    GetDBAccess().ExecuteNonQuery(SQL_INSERT_PRARAGING_DETAIL, oParameters, null);
                }
            }
        }
        #endregion

        #region ' Event Handlers '
        private string CLEAR = "<div style=\"text-align:left;\" class=\"annotation\"><a href=\"javascript:clear('{0}');\" class='explicitlink'>" + Resources.Global.Clear + "</a></div>";

        /// <summary>
        /// Handles the row databound event of the gcTESRequests.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void gvTESRequests_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                RadioButtonList rdLstIntegrity = (RadioButtonList)e.Row.FindControl("rdLstIntegrity");
                RadioButtonList rdLstHighCredit = (RadioButtonList)e.Row.FindControl("rdLstHighCredit");
                RadioButtonList rdLstLastDealt = (RadioButtonList)e.Row.FindControl("rdLstLastDealt");
                CheckBox chkOutOfBusiness = (CheckBox)e.Row.FindControl("chkOutOfBusiness");
                HtmlTextArea txtAreaComments = (HtmlTextArea)e.Row.FindControl("txtAreaComments");

                BindLookupValues(rdLstIntegrity, GetReferenceData("IntegrityRating3"));
                TableCell cell = e.Row.Cells[4];
                cell.Controls.AddAt(0, new LiteralControl(string.Format(CLEAR, rdLstIntegrity.UniqueID)));

                if (IsLumber())
                {
                    BindLookupValues(rdLstHighCredit, GetReferenceData("prtr_HighCreditL"));
                }
                else
                {
                    BindLookupValues(rdLstHighCredit, GetReferenceData("prtr_HighCreditBBOS"));
                }
                cell = e.Row.Cells[7];
                cell.Controls.AddAt(0, new LiteralControl(string.Format(CLEAR, rdLstHighCredit.UniqueID)));


                BindLookupValues(rdLstLastDealt, GetReferenceData("prtr_LastDealtDate"));
                cell = e.Row.Cells[8];
                cell.Controls.AddAt(0, new LiteralControl(string.Format(CLEAR, rdLstLastDealt.UniqueID)));

                string companyIntegrity = ((TESRequest)e.Row.DataItem).CompanyIntegrity;
                string companyHighCredit = ((TESRequest)e.Row.DataItem).CompanyHighCredit;
                string companyLastDealt = ((TESRequest)e.Row.DataItem).CompanyLastDealt;
                bool companyOutOfBusiness = ((TESRequest)e.Row.DataItem).CompanyOutOfBusiness;
                string comments = ((TESRequest)e.Row.DataItem).Comments;

                if (!String.IsNullOrEmpty(companyIntegrity))
                    rdLstIntegrity.SelectedValue = companyIntegrity;

                if (!String.IsNullOrEmpty(companyHighCredit))
                    rdLstHighCredit.SelectedValue = companyHighCredit;

                if (!String.IsNullOrEmpty(companyLastDealt))
                    rdLstLastDealt.SelectedValue = companyLastDealt;

                if (!String.IsNullOrEmpty(comments))
                    txtAreaComments.InnerText = comments;

                chkOutOfBusiness.Checked = companyOutOfBusiness;

                if (IsLumber())
                {
                    //Find Lumber related controls and populate them.
                    TextBox txtAmountOwedCurrent = (TextBox)e.Row.FindControl("txtAmountOwedCurrent");
                    TextBox txtAmountOwed1_30 = (TextBox)e.Row.FindControl("txtAmountOwed1_30");
                    TextBox txtAmountOwed31_60 = (TextBox)e.Row.FindControl("txtAmountOwed31_60");
                    TextBox txtAmountOwed61_90 = (TextBox)e.Row.FindControl("txtAmountOwed61_90");
                    TextBox txtAmountOwed91 = (TextBox)e.Row.FindControl("txtAmountOwed91");

                    string amountOwedCurrent = ((TESRequest)e.Row.DataItem).CompanyAmountOwedCurrent;
                    string amountOwed1_30 = ((TESRequest)e.Row.DataItem).CompanyAmountOwed1To30;
                    string amountOwed31_60 = ((TESRequest)e.Row.DataItem).CompanyAmountOwed31To60;
                    string amountOwed61_90 = ((TESRequest)e.Row.DataItem).CompanyAmountOwed61To90;
                    string amountOwed91 = ((TESRequest)e.Row.DataItem).CompanyAmountOwed91Plus;

                    if (!String.IsNullOrEmpty(amountOwedCurrent))
                        txtAmountOwedCurrent.Text = amountOwedCurrent;

                    if (!String.IsNullOrEmpty(amountOwed1_30))
                        txtAmountOwed1_30.Text = amountOwed1_30;

                    if (!String.IsNullOrEmpty(amountOwed31_60))
                        txtAmountOwed31_60.Text = amountOwed31_60;

                    if (!String.IsNullOrEmpty(amountOwed61_90))
                        txtAmountOwed61_90.Text = amountOwed61_90;

                    if (!String.IsNullOrEmpty(amountOwed91))
                        txtAmountOwed91.Text = amountOwed91;
                }
                else
                {
                    RadioButtonList rdLstPayPerformance = (RadioButtonList)e.Row.FindControl("rdLstPayPerformance");
                    BindLookupValues(rdLstPayPerformance, GetReferenceData("TESPayRating"));
                    string companyPayPerformance = ((TESRequest)e.Row.DataItem).CompanyPayPerformance;

                    if (!String.IsNullOrEmpty(companyPayPerformance))
                        rdLstPayPerformance.SelectedValue = companyPayPerformance;

                    cell = e.Row.Cells[5];
                    cell.Controls.AddAt(0, new LiteralControl(string.Format(CLEAR, rdLstPayPerformance.UniqueID)));
                }

                string szBBNumber = Convert.ToString(DataBinder.Eval(e.Row.DataItem, "BBNumber"));
                int RatingId;
                string RatingLine;
                string IsHQRating;
                decimal BBScore;
                string prbs_Model;
                string IndustryType;
                string prbs_PRPublish;
                string comp_PRPublishBBScore;

                GetCompanyInfo(szBBNumber, out RatingId, out RatingLine, out IsHQRating, out BBScore, out IndustryType, out prbs_PRPublish, out comp_PRPublishBBScore, out prbs_Model);

                //Rating column
                Label lblRating = (Label)e.Row.FindControl("lblRating");
                lblRating.Text = GetRatingCell(RatingId, RatingLine, IsHQRating);

                //BB Score column
                Literal litBBScore = (Literal)e.Row.FindControl("litBBScore");
                LinkButton lbBBScore = (LinkButton)e.Row.FindControl("lbBBScore");

                //Don't enforce securityEnforce security on BBScore results
                if (BBScore > 0 && prbs_PRPublish == "Y" && comp_PRPublishBBScore == "Y")
                {
                    lbBBScore.Text = BBScore.ToString("###");
                    lbBBScore.CommandArgument = string.Format("{0}|{1}|{2}", szBBNumber, IndustryType, prbs_Model);

                    litBBScore.Text = BBScore.ToString("###");
                    litBBScore.Visible = false;
                }
                else
                {
                    litBBScore.Text = Resources.Global.NotApplicableAbbr;
                    lbBBScore.Visible = false;
                }

                if (!Utilities.GetBoolConfigValue("BBScoreChartEnabled", false))
                {
                    lbBBScore.Visible = false;
                    litBBScore.Visible = true;
                }

                //Build list of unique BBScore linkbuttons that need to be added to updatepanel triggers
                if (lbBBScore.Visible)
                    _lstBBScoreControlIDs.Add(lbBBScore.UniqueID); 
            }
        }

        protected void RegisterTriggers()
        {
            if (Session[SESSION_BBSCORE] == null)
                return;

            List<string> lstBBScoreControlIDs = (List<string>)Session[SESSION_BBSCORE];
            foreach(string bbScoreId in lstBBScoreControlIDs)
            {
                AsyncPostBackTrigger trigger = new AsyncPostBackTrigger();
                trigger.ControlID = bbScoreId;
                trigger.EventName = "Click";
                ucBBScoreChart.updatePanel.Triggers.Add(trigger);
            }
        }

        /// <summary>
        /// This is to handle the dynamic triggers.  When the page first loads, clicking on the BBScore
        /// renders the modal in the update panel.  Without this function, any subsequenct clicks on 
        ///  the BBScore cause a full postback.  This function prevents that.
        /// </summary>
        protected override void CreateChildControls()
        {
            if (Page.IsPostBack)
            {
                this.RegisterTriggers();
            }
            base.CreateChildControls();
        }


        //const string SQL_GET_COMPANY_RATING = "SELECT prcra_RatingId, prcra_RatingLine, prcra_IsHQRating FROM PRCompanyRating WHERE prcra_companyid=@CompanyId";
        const string SQL_GET_COMPANY_INFO = @"SELECT 
	                                            CASE WHEN comp_PRType = 'B' THEN CASE WHEN compRating.prra_RatingID IS NOT NULL THEN compRating.prra_RatingID ELSE hqRating.prra_RatingID END ELSE hqRating.prra_RatingID END AS prra_RatingID,
	                                            CASE WHEN comp_PRType = 'B' THEN CASE WHEN compRating.prra_RatingID IS NOT NULL THEN compRating.prra_RatingLine ELSE hqRating.prra_RatingLine END ELSE hqRating.prra_RatingLine END AS prra_RatingLine,
	                                            CASE WHEN comp_PRType = 'B' THEN CASE WHEN compRating.prra_RatingID IS NOT NULL THEN 'N' ELSE 'Y' END ELSE 'N' END AS IsHQRating,
                                                prbs_BBScore,
                                                prbs_Model,
                                                comp_PRIndustryType,
                                                prbs_PRPublish,
                                                comp_PRPublishBBScore
                                            FROM Company WITH (NOLOCK) 
	                                            LEFT OUTER JOIN vPRCurrentRating compRating WITH (NOLOCK) ON comp_CompanyID = compRating.prra_CompanyID 
	                                            LEFT OUTER JOIN vPRCurrentRating hqRating WITH (NOLOCK) ON comp_PRHQID = hqRating.prra_CompanyID 
	                                            LEFT OUTER JOIN PRBBScore WITH (NOLOCK) ON comp_CompanyID = prbs_CompanyID AND prbs_Current='Y' 
                                            WHERE comp_CompanyID=@CompanyId
";

        protected void GetCompanyInfo(string szRelatedCompanyId, out int RatingId, out string RatingLine, out string IsHQRating, out decimal prbs_BBScore, out string comp_PRIndustryType, out string prbs_PRPublish, out string comp_PRPublishBBScore, out string prbs_Model)
        {
            // Retrieve the company rating for the current row being displayed
            ArrayList oParameters = new ArrayList();

            oParameters.Add(new ObjectParameter("CompanyId", szRelatedCompanyId));
            string szSQL = GetObjectMgr().FormatSQL(SQL_GET_COMPANY_INFO, oParameters);

            // Use our own DBAccess object to avoid conflicts with open readers.
            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            oDBAccess.Logger = _oLogger;

            RatingId = 0;
            RatingLine = "";
            IsHQRating = "";
            prbs_BBScore = 0;
            prbs_Model = "";
            comp_PRIndustryType = "";
            prbs_PRPublish = "";
            comp_PRPublishBBScore = "";

            using (IDataReader oReader = oDBAccess.ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null))
            {
                if (oReader.Read())
                {
                    RatingId = GetDBAccess().GetInt32(oReader, "prra_RatingId");
                    RatingLine = GetDBAccess().GetString(oReader, "prra_RatingLine");
                    IsHQRating = GetDBAccess().GetString(oReader, "IsHQRating");
                    prbs_BBScore = GetDBAccess().GetDecimal(oReader, "prbs_BBScore");
                    prbs_Model = GetDBAccess().GetString(oReader, "prbs_Model");
                    comp_PRIndustryType = GetDBAccess().GetString(oReader, "comp_PRIndustryType");
                    prbs_PRPublish = GetDBAccess().GetString(oReader, "prbs_PRPublish"); ;
                    comp_PRPublishBBScore = GetDBAccess().GetString(oReader, "comp_PRPublishBBScore"); ;
                }
            }
        }

        /// <summary>
        /// Load the BB Score image and force the BBScoreChart popup to open
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void lbBBScore_Click(object sender, EventArgs e)
        {
            LinkButton btn = sender as LinkButton;
            string szBBScore = btn.Text;

            string[] szCommandArg = btn.CommandArgument.Split('|');
            string szRelatedCompanyId = szCommandArg[0];
            string szIndustryType = szCommandArg[1];
            string szModel = szCommandArg[2];

            // We may not have a logged in user for the TES page.
            int accessLevel = PRWebUser.SECURITY_LEVEL_BASIC_ACCESS;
            string szCulture = PageBase.ENGLISH_CULTURE;
            if (_oUser != null)
            {
                accessLevel = _oUser.prwu_AccessLevel;
                szCulture = _oUser.prwu_Culture;
            }

            ucBBScoreChart.industry = szIndustryType;
            PageControlBaseCommon.PopulateBBScoreChart(Convert.ToInt32(szRelatedCompanyId), szIndustryType, ucBBScoreChart.chart, ucBBScoreChart.bbScoreImage, ucBBScoreChart.bbScoreLiteral, accessLevel, szBBScore, szCulture, szModel, false);
            PageControlBaseCommon.RegisterPopupJS(ucBBScoreChart.updatePanel);

            BindRequestGridView();
        }

        /// <summary>
        /// Handles the btnSaveAndContinue click event.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnSaveAndContinueOnClick(object sender, EventArgs e)
        {
            processRequests();

            if (!TESRequestsViewStateIsNull())
                BindRequestGridView();
        }

        /// <summary>
        /// Handles the btnSubmitAndFinish click event.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnSubmitAndFinishOnClick(object sender, EventArgs e)
        {
            processRequests();
            DisplayCompletedSection();
        }

        protected void processRequests()
        {
            List<TESRequest> visibleRequests = GetVisibleRequests();

            foreach (TESRequest request in visibleRequests)
            {
                AddOnlineTradeReport(request);
                CheckCreateLumberIndustryRecords(request);
            }

            CreateTaskSendTESToAnotherPerson();
        }

        /// <summary>
        /// Handles the btnCancelOnClick click event.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnCancelOnClick(object sender, EventArgs e)
        {
            if (_oUser != null)
            {
                Response.Redirect(GetReturnURL(PageConstants.BBOS_HOME));
            }
            else
            {
                Response.Redirect(PageConstants.LOGIN);
            }
        }

        /// <summary>
        /// Handles the btnThankYouAction click event.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnThankYouActionOnClick(object sender, EventArgs e)
        {
            string key = GetRequestParameter("Key", false);

            if (!String.IsNullOrEmpty(key))
            {
                if (EmailedUserIsMember(key))
                    Response.Redirect(PageConstants.BBOS_HOME);
                else
                    Response.Redirect(PageConstants.USER_PROFILE);
            }
            else
            {
                Response.Redirect(GetReturnURL(PageConstants.BBOS_HOME));
            }
        }

        /// <summary>
        /// Handles the ddlViewRecords SelectedIndexChanged event.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void ddlViewRecords_SelectedIndexChanged(object sender, EventArgs e)
        {
            //Preserve values to survive upcoming postback
            ManageGridRowValues();
            BindRequestGridView();
        }

        #endregion

        protected string GetSecondRequestMsg(object secondRequest)
        {
            if ((secondRequest == null) ||
                (secondRequest == DBNull.Value))
            {
                return string.Empty;
            }

            string szSecondRequest = Convert.ToString(secondRequest);
            if (string.IsNullOrEmpty(szSecondRequest))
            {
                return string.Empty;
            }

            return "<br/><span class=\"tesSecondRequest\">Second Request!</span";
        }
    }
}
